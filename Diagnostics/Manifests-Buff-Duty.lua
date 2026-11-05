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
	local enchants = { GetWeaponEnchantInfo() }
	local stride = select("#", GetWeaponEnchantInfo()) >= 8 and 4 or 3
	local enchanted = {}
	for _, hand in ipairs(ns.Data.WEAPON_HAND_ORDER) do
		local slot = ns.Data.WEAPON_HAND_SLOTS[hand]
		local base = (ns.Data.WEAPON_HAND_ORDER[1] == hand and 0 or 1) * stride
		local expiration = enchants[base + 1] and enchants[base + 2]
		local enchant = enchants[base + 1] and stride == 4 and enchants[base + 4]
		local carried = ns.IsPlain(enchant) and enchant and BW.weaponByEnchant[enchant]
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
			"  %s (slot %d): picks=%s items=%s castable=%s item=%s (%s) enchantLeft=%s enchant=%s (row %s)",
			hand,
			slot,
			#picks > 0 and table.concat(picks, " ") or "none",
			#items > 0 and table.concat(items, " ") or "default",
			listed[hand] or "0",
			PlainText(itemID),
			Holds(itemID),
			ns.IsPlain(expiration) and expiration and (math.floor(expiration / 1000) .. "s") or "none",
			PlainText(enchant),
			carried and tostring(carried.key) or "not a Buff Duty row"
		)
		enchanted[hand] = ns.IsPlain(enchants[base + 1]) and enchants[base + 1] and true or false
		local subclass = SubclassIn(itemID)
		local handBuff = handBuffs[hand]
		if handBuff and subclass then
			local fits, outOfZone = 0, 0
			for _, pick in ipairs(handBuff.picks) do
				if not pick.types or pick.types == 0 then
					fits = fits + (subclass ~= fishingPole and 1 or 0)
				elseif bit.band(pick.types, bit.lshift(1, subclass)) ~= 0 then
					fits = fits + 1
				end
				if pick.zones and not InZones(pick.zones) then
					outOfZone = outOfZone + 1
				end
			end
			lines[#lines + 1] =
				string.format("    picks that take this weapon=%d/%d outOfZone=%d", fits, #handBuff.picks, outOfZone)
		end
	end
	-- An imbue picks its own hand: the main, unless it has an enchant and a bare off-hand weapon waits.
	if hasImbues then
		local offSubclass = SubclassIn(GetInventoryItemID("player", ns.Data.WEAPON_HAND_SLOTS.OFF))
		local offWeapon = offSubclass ~= nil and offSubclass ~= fishingPole
		lines[#lines + 1] = "  next imbue lands on: "
			.. ((enchanted.MAIN and not enchanted.OFF and offWeapon) and "OFF" or "MAIN")
	end

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
	-- Buff tracking hears a stranger's buff only while one of these features keeps its events on.
	local IsOn = ns.IsFeatureOn
	lines[#lines + 1] = string.format(
		"  heard while Stranger Buffs or Combat Buffs%s is on: strangerBuffs=%s combatBuffs=%s sharingGoodNews=%s buffTrackingReady=%s",
		ns.FLAVOR == "Camelot" and "" or " or Sharing Good News",
		tostring(IsOn and IsOn("strangers")),
		tostring(IsOn and IsOn("teammates")),
		tostring(IsOn and IsOn("goodNews")),
		tostring(ns.IsBuffTrackingReady and ns.IsBuffTrackingReady())
	)

	return table.concat(lines, "\n")
end
