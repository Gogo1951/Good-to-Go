local _, ns = ...

--[[
    Scanner-Inventory -- scans the player's bags and selects the best item per
    macro category, applying scoring, ranking, and usability gates. WHAT each
    category consumes and HOW it scores is declared by the macro definitions
    themselves (itemTypes / accepts / score / ranked / ... — see the
    definition protocol in Features/Macros-for-Consumables/Macros/Definitions.lua); this file owns the
    usability gates and the scan loop that dispatches each bag item to every
    matching definition. How two items compare (the RANKING_PRIORITY tiebreak
    ladder) is Features/Macros-for-Consumables/Scanner/Scanner-Ranking.lua's.
]]

local Ranking = ns.ScanRanking
local best, rankedCandidates = Ranking.best, Ranking.rankedCandidates
local diagnosticCandidates, candidateRecord = Ranking.diagnosticCandidates, Ranking.candidateRecord
local ResetBest, BuildSelectionTables = Ranking.ResetBest, Ranking.BuildSelectionTables
local FillRecord, IsBetter, RetainCandidate = Ranking.FillRecord, Ranking.IsBetter, Ranking.RetainCandidate
local AddRankedCandidate, RankCandidates = Ranking.AddRankedCandidate, Ranking.RankCandidates
local CaptureDiagnosticCandidates = Ranking.CaptureDiagnosticCandidates

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.bestFoodID = nil
ns.bestFoodLink = nil
--[[
    The buff food the Food macro would eat while it puts buff food first: the
    best one in the bags by the same ladder, ignored items aside. Buff Duty's
    Well Fed icon uses it (Features/Buff-Duty/Buff-Duty-Self.lua). nil when
    the bags hold none, including in an arena, where none can be eaten.
]]
ns.bestBuffFoodID = nil
local bestBuffFood = {}
--[[
    Every buff food the bags hold that the Food macro could eat, ignored
    items aside, by item id: the Buff Duty Options flyout lists them so each
    can be turned off there (buffWindow.buffFoodOff), and bestBuffFoodID
    passes over the ones turned off. The last scan's, refilled in place.
]]
local carriedBuffFoods = {}
ns.carriedBuffFoods = carriedBuffFoods

--------------------------------------------------------------------------------
-- Bag Scanning
--------------------------------------------------------------------------------

local itemCounts = {}
local slotItems = {}
local ignoredTypes = {}

--[[
    The bag walk, published so a second consumer does not have to repeat it.
    itemCounts is stack totals by itemID across ns.CARRIED_BAG_IDS; slotItems
    is one hyperlink per itemID, from the first slot holding it; ignoredTypes
    names every category a usable item on either Ignore List would have
    competed in, so the Readiness Report can count it as carried.

    Assigned once here, and wiped-and-refilled in place by every scan, so the
    reference stays valid while the contents do not: these are the LAST scan's
    snapshot and are only current inside the update pass that produced them.
    Read them, never retain them, and never write to them from outside ScanBags.
]]
ns.scannedItemCounts = itemCounts
ns.scannedItemLinks = slotItems
ns.scannedIgnoredTypes = ignoredTypes

function ns.ScanBags()
	--[[
	    Refresh the zone at scan time. A zone change during combat is gated out
	    by the lockdown guard in the module's dispatcher
	    (Macros-for-Consumables-Core.lua), so ZONE_CHANGED_NEW_AREA
	    never updates the cache mid-fight; reading it here keeps zone-restricted
	    item filtering from running against a stale map after combat drops.
	]]
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	--[[
	    Party/raid-restricted Pet Food Buffs go stale when group composition,
	    the group checkboxes or the level filter change — those flip whether
	    the feature is active but have no dedicated UpdateAuraTracking call, so
	    UNIT_AURA registration would otherwise drift. ScanBags is the single
	    point every rescan passes through, so reconcile aura tracking here.
	]]
	ns.UpdateAuraTracking()

	local playerLevel = ns.cachedPlayerLevel
	local currentMap = ns.cachedMapID
	--[[
	    Arena-only consumables (e.g. Star's Tears) are gated on the live
	    instance type instead of a zone-ID list, so every arena is covered with
	    no map IDs to maintain. IsInInstance is safe on Era (returns "none").
	    ScanBags re-runs on PLAYER_ENTERING_WORLD and ZONE_CHANGED_NEW_AREA, so
	    this refreshes on every arena entry and exit.
	]]
	local inArena = select(2, IsInInstance()) == "arena"
	--[[
	    On Forever auras can be secret even out of combat (a battleground, for one), so the buff a pet buff
	    food choice reads can't be seen: the macros keep their plain eat/drink bodies rather than acting on
	    the last buffs they saw.
	]]
	local aurasHidden = ns.AreAurasSecret()
	local firstAidSkill = ns.currentFirstAidSkill or 0
	local alchemySkill = ns.currentAlchemySkill or 0
	local engineeringSkill = ns.currentEngineeringSkill or 0
	local settings = (ns.db and ns.db.profile) or {}

	--[[
	    Testing aid: targeting yourself forces the Food macro into plain-food
	    mode — no buff food, just the best non-buff food. Useful for verifying
	    what the macro picks without re-toggling settings. On Forever the
	    comparison can come back secret, so C_Secrets is asked first and a
	    restricted read counts as not targeting yourself.
	]]
	local targetingSelf = ns.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")

	--[[
	    How the Food and Water ladders treat buff food (RANKING_PRIORITY).
	    Eating it for the buff is Buff Duty's job (its Well Fed icon), so
	    the macros never put it first: false while Eat Buff Food When Already
	    Well Fed is on, so it competes on what it restores, or "last", so plain
	    food wins and buff food is still eaten when it's all the bags hold.
	    Targeting yourself is the plain-food testing aid above, so it keeps
	    buff food out entirely (the Food and Water accepts hooks read
	    ns.excludeBuffFood). Arenas need nothing here: the usable gate below
	    already drops food that can't be eaten there, buff food included.
	]]
	ns.buffFoodRank = (not settings.useBuffFoodWhenFed) and "last" or false
	ns.excludeBuffFood = targetingSelf and true or false

	--[[
	    Use Conjured Food & Water First: the setting and its When to Use
	    checkboxes and level filter (the default level is "leveling", below
	    max level). Group reads join the group signature and
	    a level-up rebuilds every macro, so a When to Use flipping always rescans. It needs no arena or self-target exception: an arena already
	    leaves only conjured food and water and the arena drinks, and
	    targeting yourself is the buff-food testing aid.
	]]
	ns.allowConjuredFirst = settings.useConjuredFirst and ns.IsUseWhenActive(settings, "conjuredFirst")

	--[[
	    Use Restock List Food & Water Last: no When to Use, on whenever ticked. The
	    current list is captured here for FillRecord; every list edit redraws
	    through ns.UpdateRestockList, which requests a rescan while it is on
	    and the list's items have changed.
	]]
	ns.allowRestockLast = settings.useRestockLast
	local restockSettings = ns.restockSettings
	Ranking.SetScanRestockList(
		restockSettings and restockSettings.lists and restockSettings.lists[restockSettings.currentList] or {}
	)

	BuildSelectionTables()

	for _, entry in pairs(best) do
		ResetBest(entry)
	end
	ResetBest(bestBuffFood)
	wipe(carriedBuffFoods)
	local buffWindow = ns.db.global and ns.db.global.buffWindow
	local buffFoodOff = buffWindow and buffWindow.buffFoodOff or {}

	for _, list in pairs(rankedCandidates) do
		wipe(list)
	end

	--[[
	    Wiped unconditionally, not just while diagnostics are enabled, so
	    turning the panel off leaves no stale candidate list behind for the
	    next report to present as current.
	]]
	for _, list in pairs(diagnosticCandidates) do
		wipe(list)
	end

	local dataRetry = false
	wipe(itemCounts)
	wipe(slotItems)
	wipe(ignoredTypes)

	for _, bag in ipairs(ns.CARRIED_BAG_IDS) do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID then
				local id = info.itemID
				itemCounts[id] = (itemCounts[id] or 0) + info.stackCount
				if not slotItems[id] then
					slotItems[id] = info.hyperlink
				end
			end
		end
	end

	--[[
	    The pet buff override is checked before the standard consumable scan.
	    Skipped in a PvP Arena, where pet buff food can't be used, and while
	    auras are hidden (aurasHidden above), where the buff it keys on can't
	    be read: it stays nil and the Food macro keeps its plain food/conjure
	    form.
	]]
	if inArena or aurasHidden then
		ns.petBuffOverrideID = nil
	else
		ns.petBuffOverrideID = ns.FindPetBuffOverride(itemCounts)
	end

	--[[
	    Both halves of the Ignore List hide an item from every macro's selection.
	    An ignored item is still resolved like any other, but where it would
	    compete it only marks its categories in ignoredTypes.
	]]
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	for id, hyperlink in pairs(slotItems) do
		local ignored = characterIgnoreList[id] or globalIgnoreList[id]
		--[[
		    Scroll items skip normal consumable processing: scrolls are Buff
		    Duty's (Buff-Duty-Self.lua).
		]]
		if not (ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[id]) then
			-- The session's record, built here the first time the scan meets the item (Item-Cache.lua).
			local data = ns.CacheItemData(id)

			if not data then
				dataRetry = true
			elseif data ~= "IGNORE" then
				local usable = true

				if data.requiredLevel > playerLevel then
					usable = false
				end

				if usable and data.requiredFirstAid > 0 and data.requiredFirstAid > firstAidSkill then
					usable = false
				end

				if usable and (data.requiredAlchemy or 0) > 0 and (data.requiredAlchemy or 0) > alchemySkill then
					usable = false
				end

				if
					usable
					and (data.requiredEngineering or 0) > 0
					and (data.requiredEngineering or 0) > engineeringSkill
				then
					usable = false
				end

				--[[
				    Engineering specialization gate (Global Thermal Sapper
				    Charge requires Goblin Engineer). Checked live rather
				    than cached at login because the specialization can be
				    learned mid-session; SPELLS_CHANGED triggers the rescan.
				    Same ns.IsSpellKnown + ns.IsPlayerSpell pair as
				    GetSmartSpell — profession passives can live on either
				    surface depending on client.
				]]
				if usable and data.requiredSpellID then
					local spellID = data.requiredSpellID
					if not (ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)) then
						usable = false
					end
				end

				if usable and data.zones then
					usable = (currentMap ~= nil) and (data.zones[currentMap] == true)
				end

				if usable and data.arenaOnly and not inArena then
					usable = false
				end

				--[[
				    A PvP Arena blocks potions and regular food and drink: of
				    the food and drink, only conjured food/water and the
				    arena-only drinks (Star's Tears/Lament) can be consumed.
				    Healthstones, Mana Gems, bandages and explosives still work.
				    Gate the blocked ones out so the macro never selects an item
				    that fails on press in the arena. Ranking within what
				    survives is unchanged (RANKING_PRIORITY).
				]]
				if usable and inArena then
					local itemType = data.itemType
					local isFoodOrWater = (itemType == "food" or itemType == "water" or itemType == "foodwater")
					if itemType == "potion" or (isFoodOrWater and not data.arenaUsable) then
						usable = false
					end
				end

				if usable then
					local totalCount = itemCounts[id]

					--[[
					    The best buff food for Buff Duty, ranked as the Food
					    macro ranks it while putting buff food first, of the
					    ones the Options flyout leaves on.
					]]
					local isBuffFood = data.isBuffFood
						and not ignored
						and (data.itemType == "food" or data.itemType == "foodwater")
					if isBuffFood then
						carriedBuffFoods[id] = true
					end
					if
						isBuffFood
						and not buffFoodOff[id]
						and IsBetter(
							data,
							totalCount,
							data.price,
							bestBuffFood,
							data.healthValue,
							"first",
							true,
							ns.allowConjuredFirst,
							ns.allowRestockLast
						)
					then
						FillRecord(bestBuffFood, data, totalCount, data.price, data.healthValue)
					end

					--[[
					    Dispatch the item to every registered definition
					    whose itemTypes set claims its cached itemType.
					    Deliberately not first-match-wins: more than one
					    category may consume the same item — a potion
					    with both health and mana values feeds Health
					    Potion and Mana Potion, and a foodwater hybrid
					    feeds Food and Water.
					]]
					for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
						if
							definition.itemTypes
							and definition.itemTypes[data.itemType]
							and (not definition.accepts or definition.accepts(data))
						then
							local score = definition.score(data)
							if ignored then
								ignoredTypes[definition.typeName] = true
							elseif definition.ranked then
								AddRankedCandidate(definition.typeName, data, score, totalCount)
							else
								local entry = best[definition.typeName]
								--[[
								    buffFood, allowConjuredFirst and
								    allowRestockLast defs track the live
								    scan preferences;
								    everyone else compares with those
								    steps gated off.
								]]
								local buffFood = definition.allowBuffFood and ns.buffFoodRank
								local allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
								local allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
								if
									IsBetter(
										data,
										totalCount,
										data.price,
										entry,
										score,
										buffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								then
									FillRecord(entry, data, totalCount, data.price, score)
									if definition.winnerExtras then
										definition.winnerExtras(entry, data, hyperlink)
									end
								end

								if ns.diagnostics.enabled then
									RetainCandidate(
										definition.typeName,
										FillRecord(candidateRecord, data, totalCount, data.price, score),
										buffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								end
							end
						end
					end
				end
			end
		end
	end

	RankCandidates()
	CaptureDiagnosticCandidates()

	ns.bestFoodID = best["Food"].id
	ns.bestFoodLink = best["Food"].link
	if bestBuffFood.id ~= ns.bestBuffFoodID then
		ns.bestBuffFoodID = bestBuffFood.id
		ns.RequestBuffDutyRefresh()
	end

	return best, dataRetry
end
