local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

-- A value that may be secret on WoW Forever, as text that never tests it.
local function PlainText(value)
	if ns.IsPlain(value) then
		return tostring(value)
	end
	return "<secret>"
end

--------------------------------------------------------------------------------
-- Buff Duty Context
--------------------------------------------------------------------------------

-- The group the Buff Duty window reads, in its order: the raid by subgroup, or you and your party.
local function GroupUnits()
	local members = {}
	if IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			local _, _, subgroup = GetRaidRosterInfo(index)
			if subgroup then
				members[#members + 1] = { unit = "raid" .. index, subgroup = subgroup }
			end
		end
	else
		members[1] = { unit = "player", subgroup = 1 }
		for index = 1, 4 do
			if UnitExists("party" .. index) then
				members[#members + 1] = { unit = "party" .. index, subgroup = 1 }
			end
		end
	end
	return members
end

local function CountKnown(ids)
	local known = 0
	for _, id in ipairs(ids or {}) do
		if ns.IsPlayerSpell(id) then
			known = known + 1
		end
	end
	return known
end

local function SpellLabel(entry)
	local id = entry.ids[1]
	return string.format("%s (%d)", C_Spell.GetSpellName(id) or "?", id)
end

-- The cooldown left as text: "none", seconds, or <secret> on WoW Forever.
local function CooldownLeft(start, duration)
	if not (ns.IsPlain(start) and ns.IsPlain(duration)) then
		return "<secret>"
	end
	if start and duration and duration > 0 then
		return string.format("%.1fs", start + duration - GetTime())
	end
	return "none"
end

--[[
    The reads the Buff Key weighs a spell by before it presses it: usable (false
    with noMana false is a missing reagent or Soul Shard), the cooldown running
    now (the global one included), the spell's own cooldown in
    milliseconds, which keeps it off the key altogether when above zero, and
    its mana cost, which the key weighs a group version against single casts
    by (nil when the client names none).
]]
local function ManaCost(id)
	local costs = C_Spell.GetSpellPowerCost and C_Spell.GetSpellPowerCost(id)
	if type(costs) ~= "table" then
		return "nil"
	end
	for _, cost in ipairs(costs) do
		if ns.IsPlain(cost.type) and cost.type == Enum.PowerType.Mana then
			return PlainText(cost.cost)
		end
	end
	return "nil"
end

local function SpellReadiness(id)
	if not id then
		return "n/a"
	end
	local usable, noMana = C_Spell.IsSpellUsable(id)
	local info = C_Spell.GetSpellCooldown(id)
	return string.format(
		"usable=%s noMana=%s cooldown=%s ownCooldown=%s manaCost=%s",
		PlainText(usable),
		PlainText(noMana),
		CooldownLeft(info and info.startTime, info and info.duration),
		PlainText(GetSpellBaseCooldown(id)),
		ManaCost(id)
	)
end

-- Ranks you know whose name the client hasn't loaded: the window drops each one until it has.
local function CountUnnamed(ids)
	local unnamed = 0
	for _, id in ipairs(ids or {}) do
		if ns.IsPlayerSpell(id) and not C_Spell.GetSpellName(id) then
			unnamed = unnamed + 1
		end
	end
	return unnamed
end

--[[
    One line per member as the window sees them: class, level, the role a
    Tanks or Healers buff is matched against, whether they can take a buff at
    all, whether they're in range of your first castable buff, whether they're
    in sight and AFK (a group buff on the Buff Key waits for a member out of
    sight unless AFK), whether a dead one gets a resurrection icon (none while
    one is already being cast on them), and their pet, with what keeps one
    off the list: dead, phase-shifted, or a borrowed mob (charmed, or neither
    a known demon nor a Focus beast and with no pet family).
]]
local function PetState(BW, pet)
	if not (pet and UnitExists(pet)) then
		return "none"
	end
	if BW.CanBuffPet(pet) then
		return "buffable"
	end
	return string.format(
		"not buffable (dead=%s phaseShifted=%s charmed=%s ownerClass=%s family=%s)",
		PlainText(UnitIsDeadOrGhost(pet)),
		tostring(BW.IsPhaseShifted(pet)),
		PlainText(UnitIsCharmed(pet)),
		tostring(BW.PetOwnerClass(pet)),
		PlainText(UnitCreatureFamily(pet))
	)
end

local function MemberLine(BW, member, rangeSpell)
	local unit = member.unit
	local _, class = UnitClass(unit)
	local petState = PetState(BW, BW.PetUnitOf(unit))
	local dead = UnitIsDeadOrGhost(unit)
	local resurrection = ""
	if ns.IsPlain(dead) and dead then
		resurrection = string.format(
			" ghost=%s incomingResurrection=%s resurrectable=%s",
			PlainText(UnitIsGhost(unit)),
			PlainText(ns.UnitHasIncomingResurrection(unit)),
			tostring(BW.ResurrectionIcon(unit, unit, "") ~= nil)
		)
	end
	return string.format(
		"  %s (party %d): class=%s level=%s role=%s canBuff=%s connected=%s dead=%s%s inRange=%s visible=%s afk=%s pet=%s",
		unit,
		member.subgroup,
		tostring(class),
		PlainText(UnitLevel(unit)),
		BW.RoleOf(unit, class),
		tostring(BW.CanBuff(unit) and true or false),
		PlainText(UnitIsConnected(unit)),
		PlainText(dead),
		resurrection,
		rangeSpell and tostring(ns.IsBuffInRange(unit, rangeSpell)) or "n/a",
		PlainText(UnitIsVisible(unit)),
		PlainText(UnitIsAFK(unit)),
		petState
	)
end

-- A unit's helpful auras straight off the client: spell id -> seconds left (0 for no timer), and whether you cast it.
local function ReadUnitBuffs(unit)
	local left, mine = {}, {}
	local now = GetTime()
	for index = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex(unit, index, "HELPFUL")
		if not data then
			break
		end
		local spellID, expires = data.spellId, data.expirationTime
		if ns.IsPlain(spellID) and spellID and ns.IsPlain(expires) then
			left[spellID] = (expires and expires > 0) and math.max(1, math.floor(expires - now)) or 0
			mine[spellID] = ns.IsPlain(data.sourceUnit) and data.sourceUnit == "player"
		end
	end
	return left, mine
end

--[[
    What a unit has on of each castable buff in `list` that is offered to it:
    the longest-lasting version and its time left (yours or someone else's), or
    missing with the rank the window would cast at the unit's level, TOO LOW
    when none of yours fits. `class` nil skips the audience check (self buffs).
    The window's own read adds Refresh Under and the blessing families on top
    of this. A plain read of the unit's auras: the window's cache is untouched.
]]
local function BuffStates(BW, unit, class, list)
	local left, mine = ReadUnitBuffs(unit)
	local role = class and BW.RoleOf(unit, class)
	local parts = {}
	for _, buff in ipairs(list) do
		local name = buff.singleName or buff.groupName or "?"
		if class and not BW.Wants(buff, class, role) then
			parts[#parts + 1] = name .. "=not offered"
		else
			local best
			for id in pairs(buff.auraIds) do
				local seconds = left[id]
				if seconds and (not best or seconds == 0 or (left[best] ~= 0 and seconds > left[best])) then
					best = id
				end
			end
			if best then
				local seconds = left[best]
				parts[#parts + 1] = string.format(
					"%s=on %s%s",
					name,
					seconds == 0 and "(no timer)" or (math.floor(seconds / 60) .. "m" .. (seconds % 60) .. "s"),
					mine[best] and " yours" or ""
				)
			else
				local cast = "group version only"
				if buff.singleName then
					local rank = BW.RankFor(buff, UnitLevel(unit))
					cast = rank and rank.castText or "TOO LOW"
				end
				parts[#parts + 1] = string.format("%s=missing cast=%s", name, cast)
			end
		end
	end
	if #parts == 0 then
		return "    buffs: (none castable)"
	end
	return "    buffs: " .. table.concat(parts, " | ")
end

--[[
    The state behind a "the Buff Duty window never shows" or "it doesn't offer
    X" report: whether it set up, every switch and setting, each gate its
    refresh checks (combat, WoW Forever's secret auras, being dead, nothing to
    offer), whether the window is up now, every buff and self buff your class
    has on this client with who it's offered to, the ranks you know, the rank
    and group version the window would cast and whether the Buff Key would
    find each ready; each hand's weapon and what your bags hold for it, the
    Soulstone and who already carries one, and the Buff Key's binding and any
    override taking its key; then every group member and your target as the
    window reads them, each with which of your buffs they have on or are
    missing, and what feeds Return the Favor. The group read is skipped in
    combat, as the window skips it. Existence/value reads only: nothing is cast, targeted or
    redrawn.
]]
function ns:BuildBuffDutyContextReport()
	local lines = { GetClientHeader(), "" }
	local BW = ns.BuffDuty
	local db = ns.db and ns.db.global.buffWindow
	if not BW then
		lines[#lines + 1] = "Buff Duty: not loaded"
		return table.concat(lines, "\n")
	end
	if not db then
		lines[#lines + 1] = "Buff Duty: (database not loaded)"
		return table.concat(lines, "\n")
	end

	local _, class = UnitClass("player")
	lines[#lines + 1] = string.format(
		"Set up: %s  Class: %s  Class has Buff Duty rows: %s",
		tostring(BW.isSetUp),
		tostring(class),
		tostring(ns.BuffDutyHasClassRows and ns.BuffDutyHasClassRows())
	)
	-- On for your class: the switch, and your class not turned off (the close button, Shift+Click on the mini-map button).
	lines[#lines + 1] = string.format(
		"Switches: enabled=%s onForYourClass=%s hideInCombat=%s locked=%s selfBuffs=%s returnTheFavor=%s target=%s askOtherClasses=%s",
		tostring(db.enabled),
		tostring(ns.IsBuffDutyOnForClass and ns.IsBuffDutyOnForClass()),
		tostring(db.hideInCombat),
		tostring(db.locked),
		tostring(db.selfEnabled),
		tostring(db.favorEnabled),
		tostring(db.targetEnabled),
		tostring(db.askOtherClasses)
	)
	local hiddenClasses = {}
	for classToken, shown in pairs(db.showClasses or {}) do
		if shown == false then
			hiddenClasses[#hiddenClasses + 1] = classToken
		end
	end
	table.sort(hiddenClasses)
	-- The read BW.ShowsHere's In Instance takes, and the kind of instance it says this is.
	local inInstance, instanceType = IsInInstance()
	lines[#lines + 1] = string.format(
		"When to Show: solo=%s (%s) party=%s (%s) raid=%s (%s) hiddenClasses=%s inGroup=%s inRaid=%s inInstance=%s (%s) shows here now=%s",
		tostring(db.showSolo),
		tostring(db.showSoloWhere),
		tostring(db.showParty),
		tostring(db.showPartyWhere),
		tostring(db.showRaid),
		tostring(db.showRaidWhere),
		#hiddenClasses > 0 and table.concat(hiddenClasses, ",") or "none",
		tostring(IsInGroup() and true or false),
		tostring(IsInRaid() and true or false),
		tostring(inInstance and true or false),
		tostring(instanceType),
		tostring(BW.ShowsHere and BW.ShowsHere())
	)
	local tankWhen = {}
	for key, when in pairs(db.tankWhen) do
		tankWhen[#tankWhen + 1] = key .. "=" .. tostring(when)
	end
	table.sort(tankWhen)
	lines[#lines + 1] = string.format(
		"Settings: countAsMissingUnder=%s min countAsTanks=%s (unlisted classes NEVER)",
		tostring(db.refreshMinutes),
		#tankWhen > 0 and table.concat(tankWhen, " ") or "none"
	)
	lines[#lines + 1] = string.format(
		"Gates now: inCombat=%s aurasSecret=%s cooldownsSecret=%s youDead=%s anythingToOffer=%s castableBuffs=%d castableSelfBuffs=%d weaponHands=%d soulstone=%s resurrection=%s",
		tostring(InCombatLockdown() and true or false),
		tostring(ns.AreAurasSecret()),
		tostring(ns.AreCooldownsSecret()),
		PlainText(UnitIsDeadOrGhost("player")),
		tostring(BW.HasAnythingToOffer()),
		#BW.buffs,
		#BW.selfBuffs,
		#BW.weaponBuffs,
		tostring(BW.soulstoneBuff ~= nil),
		tostring(BW.resurrection ~= nil)
	)
	--[[
	    Where it stands and whether that is on screen are on the Display Context
	    report. Icons dim while a roster or target change in combat leaves them
	    naming the old one, until the next redraw.
	]]
	local pool = ns.buffDutyIconPool
	local content = pool and pool.content
	lines[#lines + 1] = content
			and string.format(
				"Window now: shown=%s visible=%s icons=%d dimmedForRosterChange=%s",
				tostring(content:IsShown()),
				tostring(content:IsVisible()),
				pool.used or 0,
				tostring(pool.rosterStale)
			)
		or "Window now: (not built yet)"
	lines[#lines + 1] = string.format(
		"Rows live on this client: %d of %d buffs, %d of %d self buffs",
		#BW.entries,
		#(ns.BUFF_DUTY_SPELLS or {}),
		#BW.selfEntries,
		#(ns.BUFF_DUTY_SELF_SPELLS or {})
	)

	local castable = {}
	for _, buff in ipairs(BW.buffs) do
		castable[buff.key] = buff
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Buffs for your class:"
	local any = false
	for _, entry in ipairs(BW.entries) do
		if entry.row.class == class then
			any = true
			local buff = castable[entry.key]
			local line = string.format(
				"  %s: audience=%s ranksKnown=%d/%d unnamed=%d groupKnown=%d/%d unnamed=%d",
				SpellLabel(entry),
				tostring(db.audience[entry.key]),
				CountKnown(entry.ids),
				#entry.ids,
				CountUnnamed(entry.ids),
				CountKnown(entry.groupIds),
				#entry.groupIds,
				CountUnnamed(entry.groupIds)
			)
			if buff then
				line = line
					.. string.format(
						" inWindow=yes cast=%s group=%s",
						buff.ranks[1] and buff.ranks[1].castText or "none",
						tostring(buff.groupName)
					)
			else
				line = line .. " inWindow=NO"
			end
			lines[#lines + 1] = line
			if buff then
				lines[#lines + 1] = "    single: " .. SpellReadiness(buff.ranks[1] and buff.ranks[1].id)
				lines[#lines + 1] = "    group: " .. SpellReadiness(buff.groupId)
			end
		end
	end
	if not any then
		lines[#lines + 1] = "  (none for this class on this client)"
	end

	local castableSelf = {}
	for _, buff in ipairs(BW.selfBuffs) do
		castableSelf[buff.key] = buff
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Self buffs for your class:"
	any = false
	for _, entry in ipairs(BW.selfEntries) do
		if entry.row.class == class then
			any = true
			local buff = castableSelf[entry.key]
			lines[#lines + 1] = string.format(
				"  %s: shows=%s ranksKnown=%d/%d unnamed=%d inWindow=%s%s",
				SpellLabel(entry),
				tostring(db.selfRefresh[entry.key]),
				CountKnown(entry.ids),
				#entry.ids,
				CountUnnamed(entry.ids),
				buff and ("yes cast=" .. tostring(buff.ranks[1] and buff.ranks[1].castText)) or "NO",
				entry.row.needsPet and " needsPet" or ""
			)
			if buff then
				lines[#lines + 1] = "    " .. SpellReadiness(buff.ranks[1] and buff.ranks[1].id)
			end
		end
	end
	if not any then
		lines[#lines + 1] = "  (none for this class on this client)"
	end
	-- A self buff that needs a pet (Soul Link) waits for one that is out and alive.
	local petState = "none"
	if UnitExists("pet") then
		local petDead = UnitIsDeadOrGhost("pet")
		petState = not ns.IsPlain(petDead) and "<secret>" or petDead and "dead" or "out"
	end
	lines[#lines + 1] = "  Your pet: " .. petState
	local aurasSecret = ns.AreAurasSecret()
	if #BW.selfBuffs > 0 then
		lines[#lines + 1] = aurasSecret and "    buffs: (auras secret)" or BuffStates(BW, "player", nil, BW.selfBuffs)
	end

	--[[
	    Each hand as the window sees it: your class's picks ticked or not,
	    the weapon items set apart from the default (ticked), how many made the
	    castable list and how many of those item picks you carry at your level
	    (an oil, stone or lure shows only from your bags), what the slot holds
	    and whether it is a weapon the window asks about (an off hand holding a
	    shield, or a fishing pole for anything but a lure, gets nothing), the
	    temporary enchant's seconds left, and which row's enchant it is; then how
	    many castable picks take that weapon (a sharpening stone wants an edge, a
	    lure a fishing pole) and how many work only somewhere you aren't. Every
	    class has hands, since any class can use an oil; your class's own picks
	    are asked about only on the hands its data names, and an imbue only on
	    the hand it would land on.
	]]
	local classHands = ns.BUFF_DUTY_WEAPON_HANDS and ns.BUFF_DUTY_WEAPON_HANDS[class]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Weapons (switch %s, reapply %s, your class's picks on %s):",
		tostring(db.weaponEnabled),
		tostring(db.weaponRefresh),
		classHands and #classHands > 0 and table.concat(classHands, " ") or "no hand"
	)
	-- An imbue is offered only once you know a rank of it.
	local hasImbues = false
	for _, entry in ipairs(BW.weaponEntries) do
		if entry.row.class == class and entry.ranks then
			hasImbues = true
			lines[#lines + 1] = string.format(
				"  %s: ranksKnown=%d/%d unnamed=%d",
				SpellLabel(entry),
				CountKnown(entry.ids),
				#entry.ids,
				CountUnnamed(entry.ids)
			)
		end
	end
	local level = UnitLevel("player")
	local listed, handBuffs = {}, {}
	for _, buff in ipairs(BW.weaponBuffs) do
		handBuffs[buff.hand] = buff
		local keys, itemPicks, carried = {}, 0, 0
		for _, pick in ipairs(buff.picks) do
			keys[#keys + 1] = tostring(pick.key)
			if pick.items then
				itemPicks = itemPicks + 1
				for _, item in ipairs(pick.items) do
					if (not ns.IsPlain(level) or level >= item.level) and C_Item.GetItemCount(item.id) > 0 then
						carried = carried + 1
						break
					end
				end
			end
		end
		listed[buff.hand] =
			string.format("%d (%s) itemsInBags=%d/%d", #keys, table.concat(keys, " "), carried, itemPicks)
	end
	local weaponClass = Enum.ItemClass and Enum.ItemClass.Weapon or 2
	local fishingPole = Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole or 20
	local function Holds(itemID)
		if not ns.IsPlain(itemID) then
			return "<secret>"
		end
		if not itemID then
			return "nothing"
		end
		local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
		if classID ~= weaponClass then
			return "not a weapon"
		end
		return subclassID == fishingPole and "fishing pole" or ("weapon subclass " .. tostring(subclassID))
	end
	-- The weapon subclass in a slot, or nil for anything but a weapon.
	local function SubclassIn(itemID)
		if not (ns.IsPlain(itemID) and itemID) then
			return nil
		end
		local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
		return classID == weaponClass and subclassID or nil
	end
	-- Where you are, by the instance map GetInstanceInfo reports and the zone map, as a zone-limited item asks.
	local instanceID = select(8, GetInstanceInfo())
	local uiMapID = C_Map.GetBestMapForUnit("player")
	local function InZones(zones)
		return (ns.IsPlain(instanceID) and tContains(zones.instances or {}, instanceID))
			or (ns.IsPlain(uiMapID) and uiMapID ~= nil and tContains(zones.uiMaps or {}, uiMapID))
	end
	-- Each hand's temporary enchants, one per layer where two stack (WoW Forever): seconds, enchant id, its row.
	local worn = BW.ReadWeaponEnchants()
	for _, hand in ipairs(ns.Data.WEAPON_HAND_ORDER) do
		local slot = ns.Data.WEAPON_HAND_SLOTS[hand]
		local wornText = {}
		for _, enchant in ipairs(worn[slot]) do
			local carried = enchant.enchant and BW.weaponByEnchant[enchant.enchant]
			wornText[#wornText + 1] = string.format(
				"%s:%s/%ds (row %s)",
				enchant.layer,
				tostring(enchant.enchant),
				math.floor(enchant.seconds),
				carried and tostring(carried.key) or "none"
			)
		end
		local picks = {}
		for key, when in pairs(db.weaponPicks[class .. "_" .. hand] or {}) do
			picks[#picks + 1] = key .. "=" .. tostring(when)
		end
		table.sort(picks)
		local items = {}
		for key, when in pairs(db.weaponItems[hand] or {}) do
			items[#items + 1] = key .. "=" .. tostring(when)
		end
		table.sort(items)
		local itemID = GetInventoryItemID("player", slot)
		lines[#lines + 1] = string.format(
			"  %s (slot %d): picks=%s items=%s castable=%s item=%s (%s) enchants=%s",
			hand,
			slot,
			#picks > 0 and table.concat(picks, " ") or "none",
			#items > 0 and table.concat(items, " ") or "default",
			listed[hand] or "0",
			PlainText(itemID),
			Holds(itemID),
			#wornText > 0 and table.concat(wornText, " ") or "none"
		)
		local subclass = SubclassIn(itemID)
		local handBuff = handBuffs[hand]
		if handBuff and subclass then
			local fits, outOfZone, layers = 0, 0, {}
			for _, pick in ipairs(handBuff.picks) do
				layers[pick.layer] = (layers[pick.layer] or 0) + 1
				if not pick.types or pick.types == 0 then
					fits = fits + (subclass ~= fishingPole and 1 or 0)
				elseif bit.band(pick.types, bit.lshift(1, subclass)) ~= 0 then
					fits = fits + 1
				end
				if pick.zones and not InZones(pick.zones) then
					outOfZone = outOfZone + 1
				end
			end
			local layerText = {}
			for layer, count in pairs(layers) do
				layerText[#layerText + 1] = layer .. "=" .. count
			end
			table.sort(layerText)
			lines[#lines + 1] = string.format(
				"    picks that take this weapon=%d/%d outOfZone=%d byLayer=%s",
				fits,
				#handBuff.picks,
				outOfZone,
				table.concat(layerText, " ")
			)
		end
	end
	-- An imbue picks its own hand: the main, unless it has an imbue and a bare off-hand weapon waits.
	if hasImbues then
		local landsOn = BW.ImbueLandsOn(worn)
		lines[#lines + 1] = "  next imbue lands on: " .. (landsOn == ns.Data.WEAPON_HAND_SLOTS.OFF and "OFF" or "MAIN")
	end
	lines[#lines + 1] = "  enchants stack (imbue beside oil or stone): " .. tostring(ns.WEAPON_ENCHANTS_STACK == true)
	-- What the Readiness Report would say about each hand, before its switches and the Shaman waiver.
	local mainMissing, offMissing = ns.GetMissingWeaponBuffs()
	lines[#lines + 1] =
		string.format("  readiness missing: MAIN=%s OFF=%s", tostring(mainMissing), tostring(offMissing))

	local stone = BW.soulstoneEntry
	if stone and stone.row.class == class then
		local createIds = {}
		for _, rank in ipairs(stone.ranks) do
			createIds[#createIds + 1] = rank.id
		end
		-- With no stone in your bags the button makes one; with one, it goes on a healer or you.
		local stonesCarried, bestStone = 0, nil
		for _, id in ipairs(stone.items or {}) do
			local count = C_Item.GetItemCount(id)
			stonesCarried = stonesCarried + count
			if count > 0 then
				bestStone = id
			end
		end
		-- The icon stays away while anyone in your group carries a Soulstone, yours or another warlock's.
		local carriers = {}
		if not aurasSecret then
			for _, member in ipairs(GroupUnits()) do
				if BW.CanBuff(member.unit) then
					local left = ReadUnitBuffs(member.unit)
					for id in pairs(stone.auraIds) do
						if left[id] then
							carriers[#carriers + 1] = string.format("%s (%ds)", member.unit, left[id])
							break
						end
					end
				end
			end
		end
		lines[#lines + 1] = ""
		lines[#lines + 1] = string.format(
			"Soulstone: shows=%s createRanksKnown=%d/%d unnamed=%d inWindow=%s stonesInBags=%d carriedBy=%s",
			tostring(db.selfRefresh[stone.key]),
			CountKnown(createIds),
			#createIds,
			CountUnnamed(createIds),
			BW.soulstoneBuff and "yes" or "NO",
			stonesCarried,
			aurasSecret and "(auras secret)" or (#carriers > 0 and table.concat(carriers, " ") or "nobody")
		)
		local create = BW.soulstoneBuff and BW.soulstoneBuff.create
		lines[#lines + 1] = "  create: " .. SpellReadiness(create and create.id)
		if bestStone then
			lines[#lines + 1] = string.format(
				"  best stone %d: cooldown=%s",
				bestStone,
				CooldownLeft(C_Container.GetItemCooldown(bestStone))
			)
		end
	end

	--[[
	    The Buff Key: its binding (unbound, a press can't happen), the hidden
	    button it clicks and a macro's /click reaches, any key still on an old
	    command (the Group Buff key's, or this button's name before GtG; moved
	    at login, out of combat), and the resurrection a press casts on a dead
	    target first. A press also does nothing in combat, while you're dead,
	    and while the window is off, not set up, hidden by When to Show or
	    reading secret auras (the switches and gates above).
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Buff Key: resurrection=%s",
		BW.resurrection
				and string.format(
					"%s (%d) %s",
					tostring(BW.resurrection.name),
					BW.resurrection.id,
					SpellReadiness(BW.resurrection.id)
				)
			or "none known"
	)
	local command = ns.BUFF_KEY_COMMAND
	if command then
		local bound = { GetBindingKey(command) }
		local buttonName = command:match("^CLICK ([^:]+)")
		lines[#lines + 1] = string.format(
			"  %s: bound=%s button=%s",
			command,
			#bound > 0 and table.concat(bound, " ") or "NONE",
			(buttonName and _G[buttonName]) and buttonName or "MISSING"
		)
		-- An override binding, such as another add-on's, takes the key ahead of the saved one.
		for _, key in ipairs(bound) do
			local action = _G.GetBindingAction and _G.GetBindingAction(key, true)
			if action and action ~= command then
				lines[#lines + 1] = string.format("  %s now runs %s instead", key, action ~= "" and action or "nothing")
			end
		end
	else
		lines[#lines + 1] = "  not loaded"
	end
	local oldGroup = { GetBindingKey("CLICK TFTBBuffGroup:LeftButton") }
	if #oldGroup > 0 then
		lines[#lines + 1] = "  old Group Buff key still bound: " .. table.concat(oldGroup, " ")
	end
	local oldKey = { GetBindingKey("CLICK TFTBBuffIndividual:LeftButton") }
	if #oldKey > 0 then
		lines[#lines + 1] = "  old Buff Key command still bound: " .. table.concat(oldKey, " ")
	end

	lines[#lines + 1] = ""
	if InCombatLockdown() then
		lines[#lines + 1] = "Group and target: (in combat; the window reads nobody until combat ends)"
		return table.concat(lines, "\n")
	end
	local members = GroupUnits()
	lines[#lines + 1] = string.format(
		"Group: party=%s raid=%s members read=%d",
		tostring(IsInGroup() and true or false),
		tostring(IsInRaid() and true or false),
		#members
	)
	local first = BW.buffs[1]
	local rangeSpell = first and (first.singleName or first.groupName)
	for _, member in ipairs(members) do
		lines[#lines + 1] = MemberLine(BW, member, rangeSpell)
		if BW.CanBuff(member.unit) then
			local _, memberClass = UnitClass(member.unit)
			lines[#lines + 1] = aurasSecret and "    buffs: (auras secret)"
				or BuffStates(BW, member.unit, memberClass, BW.buffs)
		end
	end

	if not UnitExists("target") then
		lines[#lines + 1] = "Target: none"
	elseif ns.IsUnitIdentitySecret("target") then
		lines[#lines + 1] = "Target: identity secret"
	else
		lines[#lines + 1] = string.format(
			"Target: player=%s inParty=%s inRaid=%s canAssist=%s canBuff=%s petControlledByPlayer=%s",
			PlainText(UnitIsPlayer("target")),
			PlainText(UnitInParty("target")),
			PlainText(UnitInRaid("target") ~= nil),
			PlainText(UnitCanAssist("player", "target")),
			tostring(BW.CanBuff("target") and true or false),
			PlainText(not UnitIsPlayer("target") and UnitPlayerControlled("target"))
		)
		--[[
		    A dead friendly player gets the resurrection alone, a targeted pet its
		    own row, and a targeted player's pet a row under them.
		]]
		local targetIsPlayer = UnitIsPlayer("target")
		lines[#lines + 1] = string.format(
			"  friend=%s dead=%s resurrectable=%s %s=%s",
			PlainText(UnitIsFriend("player", "target")),
			PlainText(UnitIsDeadOrGhost("target")),
			tostring(BW.ResurrectionIcon("target", "target", "") ~= nil),
			(ns.IsPlain(targetIsPlayer) and targetIsPlayer) and "theirPet" or "asPet",
			PetState(BW, (ns.IsPlain(targetIsPlayer) and targetIsPlayer) and "targetpet" or "target")
		)
		if BW.CanBuff("target") then
			local _, targetClass = UnitClass("target")
			lines[#lines + 1] = aurasSecret and "    buffs: (auras secret)"
				or BuffStates(BW, "target", targetClass, BW.buffs)
		end
	end
	lines[#lines + 1] = string.format(
		"Return the Favor: a stranger who buffs you is listed for %d seconds, %d at a time.",
		db.favorSeconds,
		ns.Data.BUFF_DUTY_FAVOR_MAX
	)
	-- Strangers' buffs are heard after the pause that follows login and every loading screen.
	lines[#lines + 1] = string.format(
		"  heard from %s: ready=%s",
		ns.FLAVOR == "Camelot" and "your own auras" or "the combat log",
		tostring(ns.IsBuffDutyReady and ns.IsBuffDutyReady())
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per API Good to Go actually calls or guards, wherever it lives --
    nothing incidental, and nothing the add-on does not use. Buff Duty's own
    reads sit here beside the ones every feature shares.

    Every modern/legacy pair the add-on still picks between is listed as both
    halves: the unit tooltip the Buff Duty window reads a pet's owner from
    (C_TooltipInfo.GetUnit or a hidden tooltip's SetUnit), Validate Data's stat
    read, and its tooltip-text read (C_TooltipInfo.GetItemByID and
    GetSpellByID, or the hidden scan tooltip). The hidden tooltips are probed
    through the GameTooltip methods they inherit, so the check creates nothing.
    A FAIL on one half is the report working rather than a defect: the pair
    tells a bug report which branch that client took.
]]
local function HasFunction(namespace, name)
	return function()
		local library = _G[namespace]
		return type(library) == "table" and type(library[name]) == "function"
	end
end

local function HasGlobalFunction(name)
	return function()
		return type(_G[name]) == "function"
	end
end

-- CreateFrame throws on a template the client doesn't ship, so each one the add-on names gets a row.
local function HasTemplate(name)
	return function()
		local xml = _G.C_XMLUtil
		return type(xml) == "table" and type(xml.GetTemplateInfo) == "function" and xml.GetTemplateInfo(name) ~= nil
	end
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	{ "C_AddOns.GetAddOnMetadata", HasFunction("C_AddOns", "GetAddOnMetadata") },
	{ "C_AddOns.GetNumAddOns", HasFunction("C_AddOns", "GetNumAddOns") },
	{ "C_AddOns.GetAddOnInfo", HasFunction("C_AddOns", "GetAddOnInfo") },
	{ "C_Seasons.GetActiveSeason", HasFunction("C_Seasons", "GetActiveSeason") },
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},
	{ "Settings.OpenToCategory", HasFunction("Settings", "OpenToCategory") },
	{ "InCombatLockdown", HasGlobalFunction("InCombatLockdown") },
	{ "C_Timer.After", HasFunction("C_Timer", "After") },
	{ "C_Timer.NewTicker", HasFunction("C_Timer", "NewTicker") },
	{ "C_EventUtils.IsEventValid", HasFunction("C_EventUtils", "IsEventValid") },
	{ "C_Spell.GetSpellName", HasFunction("C_Spell", "GetSpellName") },
	{ "C_Spell.DoesSpellExist", HasFunction("C_Spell", "DoesSpellExist") },
	{ "C_Spell.GetSpellDescription", HasFunction("C_Spell", "GetSpellDescription") },
	{ "C_Spell.RequestLoadSpellData", HasFunction("C_Spell", "RequestLoadSpellData") },
	{ "C_Spell.IsSpellDataCached", HasFunction("C_Spell", "IsSpellDataCached") },
	{ "C_Spell.GetSpellTexture", HasFunction("C_Spell", "GetSpellTexture") },
	{ "C_Spell.GetSpellLink", HasFunction("C_Spell", "GetSpellLink") },
	{ "C_Spell.GetSpellSubtext", HasFunction("C_Spell", "GetSpellSubtext") },
	{ "C_Item.GetItemInfo", HasFunction("C_Item", "GetItemInfo") },
	{ "C_Item.GetItemIconByID", HasFunction("C_Item", "GetItemIconByID") },
	{ "C_UnitAuras.GetBuffDataByIndex", HasFunction("C_UnitAuras", "GetBuffDataByIndex") },
	{ "C_UnitAuras.GetAuraCasterGUID", HasFunction("C_UnitAuras", "GetAuraCasterGUID") },
	{ "C_Secrets.ShouldUnitIdentityBeSecret", HasFunction("C_Secrets", "ShouldUnitIdentityBeSecret") },
	{ "C_Secrets.ShouldAurasBeSecret", HasFunction("C_Secrets", "ShouldAurasBeSecret") },
	{ "issecretvalue", HasGlobalFunction("issecretvalue") },
	{ "CombatLogGetCurrentEventInfo", HasGlobalFunction("CombatLogGetCurrentEventInfo") },
	{
		"COMBATLOG_OBJECT_* affiliation / reaction / type flags",
		function()
			return COMBATLOG_OBJECT_TYPE_PLAYER ~= nil
				and COMBATLOG_OBJECT_REACTION_FRIENDLY ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_MINE ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_PARTY ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_RAID ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_OUTSIDER ~= nil
		end,
	},
	{
		"bit.band / bit.lshift",
		function()
			return type(bit) == "table" and type(bit.band) == "function" and type(bit.lshift) == "function"
		end,
	},
	{ "GetPlayerInfoByGUID", HasGlobalFunction("GetPlayerInfoByGUID") },
	{ "UnitNameFromGUID", HasGlobalFunction("UnitNameFromGUID") },
	{ "Ambiguate", HasGlobalFunction("Ambiguate") },
	{ "C_ChatInfo.SendChatMessage", HasFunction("C_ChatInfo", "SendChatMessage") },
	{ "UnitIsVisible", HasGlobalFunction("UnitIsVisible") },
	{ "UnitInRange", HasGlobalFunction("UnitInRange") },
	-- The Buff Key holds a group buff for a member out of sight unless they're AFK.
	{ "UnitIsAFK", HasGlobalFunction("UnitIsAFK") },
	-- A borrowed pet (Mind Control, Enslave Demon) takes no Buff Duty buff.
	{ "UnitIsCharmed", HasGlobalFunction("UnitIsCharmed") },
	{ "CreateMacro", HasGlobalFunction("CreateMacro") },
	{ "EditMacro", HasGlobalFunction("EditMacro") },
	{ "DeleteMacro", HasGlobalFunction("DeleteMacro") },
	{ "GetMacroIndexByName", HasGlobalFunction("GetMacroIndexByName") },
	{ "GetNumMacros", HasGlobalFunction("GetNumMacros") },
	{ "GetMacroInfo", HasGlobalFunction("GetMacroInfo") },
	{ "PlaySoundFile", HasGlobalFunction("PlaySoundFile") },
	-- Buff Duty's group read, role guesses and range check, and When to Show's In Instance.
	{ "IsInInstance", HasGlobalFunction("IsInInstance") },
	-- Where a zone-limited weapon item works.
	{ "GetInstanceInfo", HasGlobalFunction("GetInstanceInfo") },
	{ "C_Map.GetBestMapForUnit", HasFunction("C_Map", "GetBestMapForUnit") },
	{ "GetNumGroupMembers", HasGlobalFunction("GetNumGroupMembers") },
	{ "GetRaidRosterInfo", HasGlobalFunction("GetRaidRosterInfo") },
	{ "GetPartyAssignment (guarded)", HasGlobalFunction("GetPartyAssignment") },
	{ "UnitGroupRolesAssigned (guarded)", HasGlobalFunction("UnitGroupRolesAssigned") },
	{ "GetLFGRoles (guarded)", HasGlobalFunction("GetLFGRoles") },
	{ "C_Spell.IsSpellInRange", HasFunction("C_Spell", "IsSpellInRange") },
	{ "UnitPowerType", HasGlobalFunction("UnitPowerType") },
	{
		"Enum.PowerType.Mana / Focus",
		function()
			return type(Enum) == "table"
				and type(Enum.PowerType) == "table"
				and Enum.PowerType.Mana ~= nil
				and Enum.PowerType.Focus ~= nil
		end,
	},
	{ "C_Spell.GetSpellCooldown", HasFunction("C_Spell", "GetSpellCooldown") },
	-- Self Buffs' weapons and Soulstone: what each hand holds and carries, and what your bags hold.
	{ "GetInventoryItemID", HasGlobalFunction("GetInventoryItemID") },
	{ "GetInventoryItemTexture", HasGlobalFunction("GetInventoryItemTexture") },
	{
		"C_Item.GetWeaponEnchantInfo, or GetWeaponEnchantInfo where enchants don't stack",
		function()
			local modern = type(C_Item) == "table"
				and type(C_Item.GetWeaponEnchantInfo) == "function"
				and type(Enum) == "table"
				and type(Enum.ItemEnchantType) == "table"
				and type(Enum.WeaponSlot) == "table"
			if ns.WEAPON_ENCHANTS_STACK then
				return modern
			end
			return modern or type(_G.GetWeaponEnchantInfo) == "function"
		end,
	},
	{
		"Enum.ItemClass.Weapon / Enum.ItemWeaponSubclass.Fishingpole (guarded)",
		function()
			return type(Enum) == "table"
				and type(Enum.ItemClass) == "table"
				and Enum.ItemClass.Weapon ~= nil
				and type(Enum.ItemWeaponSubclass) == "table"
				and Enum.ItemWeaponSubclass.Fishingpole ~= nil
		end,
	},
	{ "C_Item.GetItemCount", HasFunction("C_Item", "GetItemCount") },
	{ "C_Item.IsItemInRange", HasFunction("C_Item", "IsItemInRange") },
	{ "C_Container.GetItemCooldown", HasFunction("C_Container", "GetItemCooldown") },
	-- The game's "replace your enchant?" question, answered when a weapon icon's click asked it.
	{ "C_Item.ReplaceEnchant", HasFunction("C_Item", "ReplaceEnchant") },
	-- A Buff Duty item icon's tooltip.
	{
		"GameTooltip:SetItemByID",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.SetItemByID) == "function"
		end,
	},
	-- Features/Announcements.lua picks the instance channel before party or raid.
	{
		"LE_PARTY_CATEGORY_INSTANCE",
		function()
			return LE_PARTY_CATEGORY_INSTANCE ~= nil
		end,
	},
	{ "StaticPopup_Hide", HasGlobalFunction("StaticPopup_Hide") },
	-- The Buff Key: what a press can cast, and the binding Buff Duty sets.
	{ "C_Spell.IsSpellUsable", HasFunction("C_Spell", "IsSpellUsable") },
	-- Weighs a group buff's mana against its members' single casts.
	{ "C_Spell.GetSpellPowerCost (guarded)", HasFunction("C_Spell", "GetSpellPowerCost") },
	-- Which spells have a cooldown, so the Buff Key passes over them.
	{ "GetSpellBaseCooldown", HasGlobalFunction("GetSpellBaseCooldown") },
	{ "UnitHasIncomingResurrection (guarded)", HasGlobalFunction("UnitHasIncomingResurrection") },
	{ "GetBindingKey", HasGlobalFunction("GetBindingKey") },
	{ "SetBinding", HasGlobalFunction("SetBinding") },
	{ "SaveBindings", HasGlobalFunction("SaveBindings") },
	{ "GetCurrentBindingSet", HasGlobalFunction("GetCurrentBindingSet") },
	{ "C_TooltipInfo.GetUnit", HasFunction("C_TooltipInfo", "GetUnit") },
	{
		"Hidden unit tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetUnit) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	-- Buff Duty's secure buttons and the state driver behind Hide in Combat.
	{ "RegisterStateDriver", HasGlobalFunction("RegisterStateDriver") },
	{ "UnregisterStateDriver", HasGlobalFunction("UnregisterStateDriver") },
	{ "C_XMLUtil.GetTemplateInfo", HasFunction("C_XMLUtil", "GetTemplateInfo") },
	{ "SecureActionButtonTemplate", HasTemplate("SecureActionButtonTemplate") },
	{ "CooldownFrameTemplate", HasTemplate("CooldownFrameTemplate") },
	{ "BackdropTemplate", HasTemplate("BackdropTemplate") },
	{ "UIPanelCloseButton", HasTemplate("UIPanelCloseButton") },
	{ "GameTooltipTemplate", HasTemplate("GameTooltipTemplate") },
	-- Validate Data's reads beyond the reader lists it adds itself.
	{ "C_Item.DoesItemExistByID", HasFunction("C_Item", "DoesItemExistByID") },
	{ "C_Item.RequestLoadItemDataByID", HasFunction("C_Item", "RequestLoadItemDataByID") },
	{ "C_Item.GetItemInfoInstant", HasFunction("C_Item", "GetItemInfoInstant") },
	{ "C_Item.GetItemSpell", HasFunction("C_Item", "GetItemSpell") },
	{ "C_Item.GetDetailedItemLevelInfo", HasFunction("C_Item", "GetDetailedItemLevelInfo") },
	{ "C_Item.GetItemStats", HasFunction("C_Item", "GetItemStats") },
	{ "GetItemStats (legacy)", HasGlobalFunction("GetItemStats") },
	{ "C_Item.GetItemClassInfo", HasFunction("C_Item", "GetItemClassInfo") },
	{ "C_Item.GetItemSubClassInfo", HasFunction("C_Item", "GetItemSubClassInfo") },
	{ "C_TooltipInfo.GetItemByID", HasFunction("C_TooltipInfo", "GetItemByID") },
	{ "C_TooltipInfo.GetSpellByID", HasFunction("C_TooltipInfo", "GetSpellByID") },
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	-- Display Context's screen read, and the taintLog button.
	{ "GetPhysicalScreenSize", HasGlobalFunction("GetPhysicalScreenSize") },
	{ "GetCVar", HasGlobalFunction("GetCVar") },
	{ "SetCVar", HasGlobalFunction("SetCVar") },
})

--------------------------------------------------------------------------------
-- Event Log Correlation
--------------------------------------------------------------------------------

--[[
    The event log's per-id filter asks this whether a firing of an id-filtered
    event (ns.MESSAGE_ID_FILTERED_EVENTS) is one Buff Duty acts on. For
    UNIT_SPELLCAST_SUCCEEDED that is any rank of a spell the window can cast,
    which is what a Buff Key press waits to hear go off (the set built from
    this client's Buff-Duty-Spells data, on the first firing while logging).
    For UI_ERROR_MESSAGE it is the "more powerful spell" refusal, whose error type
    Buff Duty learns from its text the first time it acts on one and logs that
    firing itself (ns.IsBuffBounceError). Everything else is counted.
]]
local IsBuffDutySpell -- defined under Validate Data Sources, from the same collectors

function ns.IsCorrelatedMessage(event, id)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		return IsBuffDutySpell(id)
	end
	if event == "UI_ERROR_MESSAGE" then
		return ns.IsBuffBounceError ~= nil and ns.IsBuffBounceError(id)
	end
	return false
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

local function SortedKeys(set)
	local keys = {}
	for key in pairs(set) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

--[[
    Every record Good to Go shows or matches by the name this client gives it, for
    the Localization tab's Game Names report, built at load from this client's
    data. Each row reads the name exactly as the features do:

    - every ns.GAME_IDS constant, a spell named through C_Spell.GetSpellName
      (what ns.GetSpellLink builds the panel samples from), requested when it
      loads late;
    - every class token this client has, named through
      LOCALIZED_CLASS_NAMES_MALE as the panels show it;
    - the client's duration strings, through ns.FormatDuration as the Buff
      Duty panels use them, with the sample count in the ID cell;
    - the pet-owner tooltip formats Buff Duty turns into patterns to find
      a targeted pet's owner (NIL means that wording is skipped on this client);
    - the group labels the Buff Duty window heads its party sections with, the
      hand names its weapon rows and the Weapon Buffs panel show, the error a
      Buff Key pressed in combat shows, and the "more powerful spell" refusal
      Buff Duty matches by its text (NIL means it never learns a buff bounced).

    Buff Duty names no item by constant: its items' names show on Validate Data.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, {})

do
	local rows = ns.DIAGNOSTIC_NAME_LOOKUPS

	for _, constant in ipairs(SortedKeys(ns.GAME_IDS or {})) do
		local id = ns.GAME_IDS[constant]
		rows[#rows + 1] = {
			constant = constant,
			kind = "spell",
			id = id,
			lookup = function()
				return C_Spell.GetSpellName(id)
			end,
			request = function()
				C_Spell.RequestLoadSpellData(id)
			end,
		}
	end

	local classes = {}
	for class in pairs(ns.CLASS_SPELL_LISTS or {}) do
		classes[class] = true
	end
	for _, list in ipairs({
		ns.BUFF_DUTY_SPELLS or {},
		ns.BUFF_DUTY_SELF_SPELLS or {},
		ns.BUFF_DUTY_WEAPON_ENCHANTS or {},
	}) do
		for _, row in ipairs(list) do
			if row.class then
				classes[row.class] = true
			end
		end
	end
	for _, token in ipairs(SortedKeys(classes)) do
		rows[#rows + 1] = {
			constant = token,
			kind = "class",
			id = token,
			lookup = function()
				return LOCALIZED_CLASS_NAMES_MALE[token]
			end,
		}
	end

	local durations =
		{ { "D_SECONDS", 1 }, { "D_SECONDS", 2 }, { "D_SECONDS", 15 }, { "D_MINUTES", 120 }, { "D_HOURS", 7200 } }
	for _, duration in ipairs(durations) do
		local seconds = duration[2]
		rows[#rows + 1] = {
			constant = duration[1],
			kind = "globalString",
			id = seconds,
			lookup = function()
				return ns.FormatDuration(seconds)
			end,
		}
	end

	for _, constant in ipairs({
		"UNITNAME_TITLE_PET",
		"UNITNAME_TITLE_MINION",
		"UNITNAME_TITLE_GUARDIAN",
		"UNITNAME_TITLE_CREATION",
		"UNITNAME_TITLE_CHARM",
		"UNITNAME_TITLE_COMPANION",
		"GROUP",
		"GROUP_NUMBER",
		"INVTYPE_WEAPONMAINHAND",
		"INVTYPE_WEAPONOFFHAND",
		"ERR_NOT_IN_COMBAT",
		"SPELL_FAILED_AURA_BOUNCED",
	}) do
		rows[#rows + 1] = UiLabel(constant)
	end
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- The longest name a character can have, in letters.
local CHARACTER_NAME_MAX_LETTERS = 12

--[[
    Every chat line and macro Buff Duty sends or writes, for the Localization
    tab's Message Length report, built at report time through the add-on's own
    builders. Returns rows of { label, ceiling, text } and a list of notes.
    The ceiling is in bytes, so the overflow canary is the widest-encoding
    locale, usually ruRU.

    Buff Duty's ask for another class's buff is built for every raid-wide
    buff the window counts, and the longest is kept. It is built whispered:
    the whisper leads with the marker on every flavor, so it is never shorter
    than the line said to the group.

    Buff Duty's Return the Favor buttons cast through a macro naming the
    stranger, one per buff you can give right now, built by ns.BuffDuty's
    own SingleIcon with your top rank's cast text and a 12-letter name on your
    realm.
]]
ns.DIAGNOSTIC_MESSAGES = function()
	local rows, notes = {}, {}
	local BW = ns.BuffDuty
	if BW and BW.entries then
		local longestAsk
		-- the longest names list an ask can carry: as many as it names, each at the game's 12-letter limit
		local longestNames = {}
		for i = 1, ns.BUFF_ASK_MAX_NAMES do
			longestNames[i] = string.rep("W", 12)
		end
		for _, entry in ipairs(BW.entries) do
			local row = entry.row
			if row.group and not row.exclusive then
				local linkId = entry.ids[#entry.ids]
				local link = ns.GetSpellLink(linkId) or C_Spell.GetSpellName(linkId) or ""
				local ask = ns:BuildBuffRequestMessage(longestNames, #longestNames, link, true)
				if not longestAsk or #ask > #longestAsk then
					longestAsk = ask
				end
			end
		end
		if longestAsk then
			rows[#rows + 1] = {
				label = "Buff Duty ask for a buff",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = longestAsk,
			}
		end
	end
	if BW and BW.SingleIcon then
		local realm = _G.GetNormalizedRealmName and _G.GetNormalizedRealmName() or "Realm"
		local fullName = string.rep("W", CHARACTER_NAME_MAX_LETTERS) .. "-" .. tostring(realm)
		for _, buff in ipairs(BW.buffs) do
			if buff.singleName then
				local icon = BW.SingleIcon(buff, nil, nil, fullName, fullName)
				rows[#rows + 1] = {
					label = "Buff Duty favor macro (" .. buff.singleName .. ")",
					ceiling = ns.MACRO_BODY_MAX_LENGTH,
					text = icon and icon.macrotext or "",
				}
			end
		end
		if #BW.buffs == 0 then
			notes[#notes + 1] = "No Buff Duty buff is castable right now, so no favor macro was built."
		end
		notes[#notes + 1] =
			"A character name in a non-Latin script takes 2 or 3 bytes a letter, so a favor macro can run longer than shown."
	end
	return rows, notes
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per data file, and one report row per entry on the Data tab
    (Diagnostics/Options-Diagnostics.lua). Each entry's label is the table-name
    part of its file name, so ns.DataSourceFileName can name the file this
    client's folder built. Each source names the static table on ns and its kind,
    and reaches its ids through collect(tbl), which returns { id, key, row }
    entries. dataColumns carries the shipped row's own values as
    { header, getter(key, row) }, so the export sets what the file says beside
    what the client says.
]]
local function BuffRowField(field)
	return function(_, row)
		return row.row[field]
	end
end

local function FoundField(field)
	return function(_, row)
		return row[field]
	end
end

-- Single-target ranks are { id, level learned }; group ranks are bare ids.
local function CollectBuffDuty(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, rank in ipairs(row.single or {}) do
			found[#found + 1] = { id = rank[1], key = index, row = { row = row, role = "single", level = rank[2] } }
		end
		for _, id in ipairs(row.group or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row, role = "group" } }
		end
		for _, id in ipairs(row.greater or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row, role = "greater" } }
		end
	end
	return found
end

-- Self buffs: every rank, { id, level learned }.
local function CollectSelfBuffs(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, rank in ipairs(row.ranks or {}) do
			found[#found + 1] = { id = rank[1], key = index, row = { row = row, level = rank[2] } }
		end
	end
	return found
end

-- A rank's enchant id, or its list of them (TBC's Rockbiter, one per weapon speed).
local function EnchantText(enchant)
	if type(enchant) == "table" then
		return table.concat(enchant, " ")
	end
	return enchant
end

--[[
    Weapon enchants: an imbue's ranks are spells, a poison's items; `kind`
    picks which, and a row of the other kind adds nothing. A rank with no
    enchant id shows a blank DATA_ENCHANT_ID: Buff Duty can't tell it's
    on a weapon, and keeps offering it.
]]
local function CollectWeaponEnchants(kind)
	return function(rows)
		local found = {}
		for index, row in ipairs(rows) do
			local ranks
			if kind == "item" then
				ranks = row.items
			else
				ranks = row.ranks
			end
			for _, rank in ipairs(ranks or {}) do
				found[#found + 1] = {
					id = rank[1],
					key = index,
					row = { row = row, level = rank[2], enchant = EnchantText(rank[3]) },
				}
			end
		end
		return found
	end
end

-- Weapon items: { item id, level required, enchant id, weapon types, kind, item level }; a blank DATA_ENCHANT_ID is a missing enchant id.
-- A weapon item's zones as one cell, "instances 585 580; uiMaps 1957", or nil for an item that works anywhere.
local function ZonesText(zones)
	if not zones then
		return nil
	end
	local parts = {}
	for _, kind in ipairs({ "instances", "uiMaps" }) do
		if zones[kind] then
			parts[#parts + 1] = kind .. " " .. table.concat(zones[kind], " ")
		end
	end
	return table.concat(parts, "; ")
end

local function CollectWeaponItems(rows)
	local found = {}
	for index, row in ipairs(rows) do
		found[#found + 1] = {
			id = row[1],
			key = index,
			row = {
				level = row[2],
				enchant = row[3],
				types = row[4],
				kind = row[5],
				itemLevel = row[6],
				zones = ZonesText(row[7]),
			},
		}
	end
	return found
end

-- The Soulstone: its Create Soulstone ranks and its auras as spells, its stones as items.
local function CollectSoulstone(kind)
	return function(stone)
		local found = {}
		if kind == "item" then
			for _, id in ipairs(stone.items or {}) do
				found[#found + 1] = { id = id, key = id, row = { role = "stone" } }
			end
			return found
		end
		for _, rank in ipairs(stone.create or {}) do
			found[#found + 1] = { id = rank[1], key = rank[1], row = { role = "create", level = rank[2] } }
		end
		for _, id in ipairs(stone.auras or {}) do
			found[#found + 1] = { id = id, key = id, row = { role = "aura" } }
		end
		return found
	end
end

-- The Buff Key's resurrections: bare rank ids, one row per class.
local function CollectResurrections(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, id in ipairs(row.ranks or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row } }
		end
	end
	return found
end

-- The pet icons' summoning spells: Call Pet for beasts, and one per demon by NPC id.
local function CollectPetIcons(icons)
	local found = {}
	if icons.beast then
		found[#found + 1] = { id = icons.beast, key = "beast", row = { npc = "" } }
	end
	for npc, spell in pairs(icons.demons or {}) do
		found[#found + 1] = { id = spell, key = npc, row = { npc = npc } }
	end
	return found
end

-- Every spell id a Buff Duty data table names, for the event log's filter above.
local buffDutySpells

function IsBuffDutySpell(id)
	if not buffDutySpells then
		buffDutySpells = {}
		for _, source in ipairs({
			{ ns.BUFF_DUTY_SPELLS, CollectBuffDuty },
			{ ns.BUFF_DUTY_SELF_SPELLS, CollectSelfBuffs },
			{ ns.BUFF_DUTY_WEAPON_ENCHANTS, CollectWeaponEnchants("spell") },
			{ ns.BUFF_DUTY_SOULSTONE, CollectSoulstone("spell") },
			{ ns.BUFF_DUTY_RESURRECTIONS, CollectResurrections },
		}) do
			if type(source[1]) == "table" then
				for _, found in ipairs(source[2](source[1])) do
					buffDutySpells[found.id] = true
				end
			end
		end
	end
	return buffDutySpells[id] == true
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	-- { label, sources = { { table, kind, collect, dataColumns } } }
	{
		label = "Game-IDs",
		sources = {
			{
				table = "GAME_IDS",
				kind = "spell",
				collect = function(ids)
					local found = {}
					for constant, id in pairs(ids) do
						found[#found + 1] = { id = id, key = constant, row = id }
					end
					return found
				end,
				dataColumns = {
					{
						"DATA_CONSTANT",
						function(key)
							return key
						end,
					},
				},
			},
		},
	},
	{
		label = "Buff-Duty-Spells",
		sources = {
			{
				table = "BUFF_DUTY_SPELLS",
				kind = "spell",
				collect = CollectBuffDuty,
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_EXCLUSIVE", BuffRowField("exclusive") },
					{ "DATA_MANA_ONLY", BuffRowField("manaOnly") },
					{ "DATA_NO_CASTERS", BuffRowField("noCasters") },
					{ "DATA_DEFAULT", BuffRowField("default") },
				},
			},
			{
				table = "BUFF_DUTY_SELF_SPELLS",
				kind = "spell",
				collect = CollectSelfBuffs,
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_EXCLUSIVE", BuffRowField("exclusive") },
					{ "DATA_DEFAULT", BuffRowField("default") },
				},
			},
			{
				table = "BUFF_DUTY_WEAPON_ENCHANTS",
				kind = "spell",
				collect = CollectWeaponEnchants("spell"),
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
				},
			},
			{
				table = "BUFF_DUTY_WEAPON_ENCHANTS",
				kind = "item",
				collect = CollectWeaponEnchants("item"),
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
				},
			},
			-- Which hands each class is asked about: class tokens, no ids, so the report counts them.
			{ table = "BUFF_DUTY_WEAPON_HANDS", kind = "other" },
			{
				table = "BUFF_DUTY_WEAPON_ITEMS",
				kind = "item",
				collect = CollectWeaponItems,
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
					{ "DATA_WEAPON_TYPES", FoundField("types") },
					{ "DATA_KIND", FoundField("kind") },
					{ "DATA_ITEM_LEVEL", FoundField("itemLevel") },
					{ "DATA_ZONES", FoundField("zones") },
				},
			},
			{
				table = "BUFF_DUTY_SOULSTONE",
				kind = "spell",
				collect = CollectSoulstone("spell"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_LEVEL", FoundField("level") },
				},
			},
			{
				table = "BUFF_DUTY_SOULSTONE",
				kind = "item",
				collect = CollectSoulstone("item"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
				},
			},
			{
				table = "BUFF_DUTY_RESURRECTIONS",
				kind = "spell",
				collect = CollectResurrections,
				dataColumns = {
					{ "DATA_CLASS", BuffRowField("class") },
				},
			},
			{
				table = "BUFF_DUTY_PET_ICONS",
				kind = "spell",
				collect = CollectPetIcons,
				dataColumns = {
					{ "DATA_NPC_ID", FoundField("npc") },
				},
			},
		},
	},
})
