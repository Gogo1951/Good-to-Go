local _, ns = ...

local Ranking = ns.ScanRanking
local best, rankedCandidates = Ranking.best, Ranking.rankedCandidates
local diagnosticCandidates, candidateRecord = Ranking.diagnosticCandidates, Ranking.candidateRecord
local ResetBest, BuildSelectionTables = Ranking.ResetBest, Ranking.BuildSelectionTables
local FillRecord, IsBetter, RetainCandidate = Ranking.FillRecord, Ranking.IsBetter, Ranking.RetainCandidate
local AddRankedCandidate, RankCandidates = Ranking.AddRankedCandidate, Ranking.RankCandidates
local BuffFoodRank = Ranking.BuffFoodRank
local CaptureDiagnosticCandidates = Ranking.CaptureDiagnosticCandidates

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.bestFoodID = nil
ns.bestFoodLink = nil
-- Buff Duty's Well Fed pick, ranked as the Food macro ranks buff food first.
ns.bestBuffFoodID = nil
local bestBuffFood = {}
-- Every carried buff food, which Buff Duty's flyout lists so each can be turned off.
local carriedBuffFoods = {}
ns.carriedBuffFoods = carriedBuffFoods

--------------------------------------------------------------------------------
-- Bag Scanning
--------------------------------------------------------------------------------

local itemCounts = {}
local slotItems = {}
local ignoredTypes = {}

--[[
    Refilled in place every scan: current only inside the pass that made them.
    Read, never retain, never write from outside ScanBags. ignoredTypes lets
    the Readiness Report count an ignored item as carried.
]]
ns.scannedItemCounts = itemCounts
ns.scannedItemLinks = slotItems
ns.scannedIgnoredTypes = ignoredTypes

function ns.ScanBags()
	-- ZONE_CHANGED_NEW_AREA is swallowed in combat, so the map is reread here.
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	-- Group, checkbox and level changes flip Pet Food Buffs with no call of their own.
	ns.UpdateAuraTracking()

	local playerLevel = ns.cachedPlayerLevel
	local currentMap = ns.cachedMapID
	-- Live instance type, not a zone list, so every arena is covered.
	local inArena = select(2, IsInInstance()) == "arena"
	-- Forever hides auras even out of combat (a battleground); the macros then keep plain bodies.
	local aurasHidden = ns.AreAurasSecret()
	local firstAidSkill = ns.currentFirstAidSkill or 0
	local alchemySkill = ns.currentAlchemySkill or 0
	local engineeringSkill = ns.currentEngineeringSkill or 0
	local settings = (ns.db and ns.db.profile) or {}

	-- Testing aid: targeting yourself keeps buff food out. A restricted comparison counts as not.
	local targetingSelf = ns.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")

	-- Eating for the buff is Buff Duty's job, so while Well Fed the macros never put buff food first.
	ns.buffFoodRank = (not settings.useBuffFoodWhenFed) and "last" or false
	ns.excludeBuffFood = targetingSelf and true or false

	-- So eating to heal also lands the buff. Hidden auras keep the usual order.
	ns.buffFoodFirst = not ns.wellFedState and not aurasHidden

	ns.allowConjuredFirst = settings.useConjuredFirst and ns.IsUseWhenActive(settings, "conjuredFirst")

	-- A list edit requests its own rescan through ns.UpdateRestockList.
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

	-- Wiped even while Diagnostics is off, so a later report never shows a stale list as current.
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

	if inArena or aurasHidden then
		ns.petBuffOverrideID = nil
	else
		ns.petBuffOverrideID = ns.FindPetBuffOverride(itemCounts)
	end

	-- An ignored item still resolves, but only marks the categories it would have competed in.
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	for id, hyperlink in pairs(slotItems) do
		local ignored = characterIgnoreList[id] or globalIgnoreList[id]
		-- Scrolls are Buff Duty's.
		if not (ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[id]) then
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

				-- Live, not cached: a specialization can be learned mid-session. Passives sit on either API by client.
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

				-- An arena blocks potions and all food and drink but conjured and arena-only.
				if usable and inArena then
					local itemType = data.itemType
					local isFoodOrWater = (itemType == "food" or itemType == "water" or itemType == "foodwater")
					if itemType == "potion" or (isFoodOrWater and not data.arenaUsable) then
						usable = false
					end
				end

				if usable then
					local totalCount = itemCounts[id]

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

					-- Not first-match-wins: a hybrid potion feeds both potion macros, foodwater both Food and Water.
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
								local buffFood = BuffFoodRank(definition)
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

	-- Well Fed changes what the Food macro eats only while the bags hold buff food.
	local carriesBuffFood = next(carriedBuffFoods) ~= nil
	if carriesBuffFood ~= ns.carriesBuffFood then
		ns.carriesBuffFood = carriesBuffFood
		ns.UpdateAuraTracking()
	end

	return best, dataRetry
end
