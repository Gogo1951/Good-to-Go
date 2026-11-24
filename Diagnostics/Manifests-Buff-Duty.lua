local ADDON_NAME, ns = ...

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
    a known demon nor a Focus beast and with no pet family). A buffable pet
    also names the buffs held off it: one cast that went off, trusted until
    it would need a refresh, or one the game refused, held while it stays.
]]
-- The buffs Buff Duty holds off a pet or NPC (BuffDuty.IsHeld), by name.
local function HeldBuffs(BW, unit)
	local guid = UnitGUID(unit)
	if not (ns.IsPlain(guid) and guid) then
		return "none"
	end
	local held = {}
	for _, buff in ipairs(BW.buffs) do
		if BW.IsHeld(guid, buff.key) then
			held[#held + 1] = buff.singleName or buff.groupName or "?"
		end
	end
	return #held > 0 and table.concat(held, ",") or "none"
end

local function PetState(BW, pet)
	if not (pet and UnitExists(pet)) then
		return "none"
	end
	if BW.CanBuffPet(pet) then
		BW.ReadAuras(pet)
		return string.format("buffable aurasReadable=%s held=%s", tostring(BW.AurasReadable()), HeldBuffs(BW, pet))
	end
	return string.format(
		"not buffable (identitySecret=%s visible=%s canAssist=%s dead=%s phaseShifted=%s charmed=%s ownerClass=%s family=%s)",
		tostring(ns.IsUnitIdentitySecret(pet) and true or false),
		PlainText(UnitIsVisible(pet)),
		PlainText(UnitCanAssist("player", pet)),
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
		"  %s (party %d): class=%s level=%s role=%s canBuff=%s connected=%s dead=%s%s inRange=%s visible=%s afk=%s pvpFlagged=%s pet=%s",
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
		PlainText(UnitIsPVP(unit)),
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
    Where the window's own verdict (BuffDuty.Has, after it reads the unit into
    its aura cache) differs, it is said: one on but offered (running under
    Refresh Under, or a weaker rank than yours), or one missing but skipped
    (another of your blessings is on them).
]]
local function BuffStates(BW, unit, class, list)
	local left, mine = ReadUnitBuffs(unit)
	BW.ReadAuras(unit)
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
			local windowHas = BW.Has(buff, unit)
			if best then
				local seconds = left[best]
				parts[#parts + 1] = string.format(
					"%s=on %s%s%s",
					name,
					seconds == 0 and "(no timer)" or (math.floor(seconds / 60) .. "m" .. (seconds % 60) .. "s"),
					mine[best] and " yours" or "",
					windowHas and "" or " (window offers it)"
				)
			else
				local cast = "group version only"
				if buff.singleName then
					local rank = BW.RankFor(buff, UnitLevel(unit))
					cast = rank and rank.castText or "TOO LOW"
				end
				parts[#parts + 1] =
					string.format("%s=missing cast=%s%s", name, cast, windowHas and " (window skips it)" or "")
			end
		end
	end
	if #parts == 0 then
		return "    buffs: (none castable)"
	end
	return "    buffs: " .. table.concat(parts, " | ")
end

-- Seconds left as "4m10s", "(no timer)" for 0, or "missing" for nil.
local function TimeLeftText(expires)
	if expires == nil then
		return "missing"
	end
	if expires == 0 then
		return "(no timer)"
	end
	local seconds = math.max(0, math.floor(expires - GetTime()))
	return math.floor(seconds / 60) .. "m" .. (seconds % 60) .. "s"
end

--[[
    Well Fed on you as the window reads it: the longest Well Fed aura, by
    spell id or icon, and whether the buff food's own eating aura is on you
    (the icon waits while you eat). nil for had when an aura is secret.
]]
local function ReadWellFed(eatingSpellId)
	local had, expires, duration, eating = false, nil, nil, false
	for index = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", index, "HELPFUL")
		if not aura then
			break
		end
		local spellId, icon = aura.spellId, aura.icon
		if not (ns.IsPlain(spellId) and ns.IsPlain(icon)) then
			return nil, nil, nil, false
		end
		if eatingSpellId and spellId == eatingSpellId then
			eating = true
		end
		if (ns.WELL_FED_BUFF_IDS or {})[spellId] or (ns.WELL_FED_ICON_IDS or {})[icon] then
			local auraExpires = ns.IsPlain(aura.expirationTime) and aura.expirationTime or 0
			if not had or auraExpires == 0 or (expires ~= 0 and auraExpires > expires) then
				expires = auraExpires
				duration = ns.IsPlain(aura.duration) and aura.duration or 0
			end
			had = true
		end
	end
	return had, expires, duration, eating
end

--[[
    Well Fed's icon: the buff food the Food macro's bag scan picked
    (ns.bestBuffFoodID, nil with none in your bags or in an arena), less any
    the Options flyout turned off (buffFoodOff), whether you still carry it,
    the spell its eating aura carries, every buff food the scan found, then
    Well Fed on you now and whether the icon shows by your timing for it.
]]
local function WellFedLines(lines, db, buff)
	local food = ns.bestBuffFoodID
	local eatingSpell
	if food and C_Item.GetItemSpell then
		local _, spellId = C_Item.GetItemSpell(food)
		eatingSpell = ns.IsPlain(spellId) and spellId or nil
	end
	local carried, off = {}, {}
	for itemId in pairs(ns.carriedBuffFoods or {}) do
		carried[#carried + 1] = tostring(itemId)
	end
	table.sort(carried)
	for itemId, isOff in pairs(db.buffFoodOff or {}) do
		if isOff then
			off[#off + 1] = tostring(itemId)
		end
	end
	table.sort(off)
	lines[#lines + 1] = string.format(
		"    buff food: best=%s inBags=%s eatingSpell=%s carried=%s turnedOff=%s",
		tostring(food),
		food and tostring(C_Item.GetItemCount(food)) or "n/a",
		tostring(eatingSpell),
		#carried > 0 and table.concat(carried, " ") or "none",
		#off > 0 and table.concat(off, " ") or "none"
	)
	local had, expires, duration, eating = ReadWellFed(eatingSpell)
	local shows = "yes"
	if not buff then
		shows = "no (Well Fed off)"
	elseif not food or C_Item.GetItemCount(food) == 0 then
		shows = "no (no buff food)"
	elseif had == nil then
		shows = "no (auras secret)"
	elseif eating then
		shows = "no (eating)"
	elseif had and (expires == 0 or duration <= buff.refreshSeconds or expires - GetTime() >= buff.refreshSeconds) then
		shows = "no (on)"
	end
	lines[#lines + 1] = string.format(
		"    Well Fed now: %s eatingNow=%s shows=%s",
		had == nil and "(auras secret)" or (had and TimeLeftText(expires) or "missing"),
		tostring(eating),
		shows
	)
end

--[[
    Scrolls' icons, one per type in the Food macro's order: whether this
    character ticks it (scrollTypes, on the profile), how many scrolls of it
    you carry and how many of those the window passes over (on the Ignore
    List, another class's, or turned off in the Scrolls menu: scrollOff),
    the strongest it would read and its amount,
    the type's scroll buff on you and the strongest elixir or class buff
    covering it, and whether the window offers it now. Nothing shows while
    auras are secret.
]]
local function ScrollLines(lines, buff, aurasSecret)
	local types = ns.db.profile.scrollTypes or {}
	local ticked = {}
	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER or {}) do
		if types[scrollType] then
			ticked[#ticked + 1] = scrollType
		end
	end
	lines[#lines + 1] = "    types ticked (this character): " .. (#ticked > 0 and table.concat(ticked, " ") or "none")
	if aurasSecret then
		lines[#lines + 1] = "    (auras secret: no scroll icon shows)"
		return
	end
	-- Read as the window reads them (Buff-Duty-Self.lua): a scroll the Scrolls menu turned off counts as none.
	local scrollOff = ns.db.global.buffWindow.scrollOff or {}
	local counts = setmetatable({}, {
		__index = function(_, itemId)
			if scrollOff[itemId] then
				return 0
			end
			return C_Item.GetItemCount(itemId)
		end,
	})
	local _, playerClass = UnitClass("player")
	local snapshot = ns.GetPlayerBuffSnapshot()
	local now = GetTime()
	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER or {}) do
		local data = ns.SCROLL_DATA and ns.SCROLL_DATA[scrollType]
		local carried, passed = 0, 0
		for _, item in ipairs(data and data.items or {}) do
			if C_Item.GetItemCount(item[1]) > 0 then
				carried = carried + 1
				if scrollOff[item[1]] or ns.IsIgnored(item[1]) or (item[5] ~= nil and item[5] ~= playerClass) then
					passed = passed + 1
				end
			end
		end
		local itemId, amount = ns.FindBestScroll(scrollType, counts)
		local aura = snapshot.scrolls[scrollType] or {}
		local covered = aura.conflictAmount and aura.conflictAmount >= (amount or 0) or false
		local shows = "no"
		if not types[scrollType] then
			shows = "no (unticked)"
		elseif not itemId then
			shows = "no (none to read)"
		elseif covered then
			shows = "no (covered)"
		elseif not buff then
			shows = "no (Scrolls off)"
		elseif aura.expiration == nil or (aura.expiration ~= 0 and aura.expiration - now < buff.refreshSeconds) then
			shows = "yes"
		end
		lines[#lines + 1] = string.format(
			"    %s: carried=%d passedOver=%d best=%s amount=%s buff=%s coveredBy=%s shows=%s",
			scrollType,
			carried,
			passed,
			tostring(itemId),
			tostring(amount),
			TimeLeftText(aura.expiration),
			tostring(aura.conflictAmount),
			shows
		)
	end
end

--[[
    Ask Your Target for Buffs, as BuffDuty.TargetAskRow weighs it: the
    switches, a target of your own class or one fighting, AFK or DND (or you
    fighting) gets no row, a name the client won't give plainly gets none;
    then each buff of their class with why it is or isn't asked for, in the
    row's order. A buff its caster keeps for one player (noAsk) or set to Off
    is never asked for, nor one whose lowest rank their level hasn't reached;
    a talent buff only once they carry it; one Blessing at most; then your
    own Who Gets It, whether you have it, and each buff's five-minute wait
    since you last asked them for it.
]]
local function AskLines(lines, BW, db, targetClass)
	local _, playerClass = UnitClass("player")
	local fullName = GetUnitName("target", true)
	lines[#lines + 1] = string.format(
		"  ask: switch=%s sameClass=%s targetInCombat=%s youInCombat=%s afk=%s dnd=%s nameReadable=%s",
		tostring(db.askTarget),
		tostring(targetClass == playerClass),
		PlainText(UnitAffectingCombat("target")),
		PlainText(UnitAffectingCombat("player")),
		PlainText(UnitIsAFK("target")),
		UnitIsDND and PlainText(UnitIsDND("target")) or "n/a",
		tostring((ns.IsPlain(fullName) and fullName) and true or false)
	)
	if not targetClass or targetClass == playerClass then
		return
	end
	local guid = UnitGUID("target")
	guid = ns.IsPlain(guid) and guid or nil
	local level = UnitLevel("target")
	local candidates = {}
	for _, entry in ipairs(BW.entries) do
		local row = entry.row
		if row.class == targetClass then
			local who = db.audience[entry.key]
			local lowest = entry.ranks[1]
			local state
			if row.noAsk then
				state = "never asked (one player at a time)"
			elseif not who or who == ns.Data.BUFF_AUDIENCE.OFF then
				state = "off"
			elseif lowest and ns.IsPlain(level) and level and level > 0 and level < lowest.level then
				state = "their level too low"
			end
			candidates[#candidates + 1] = {
				entry = entry,
				state = state,
				buff = {
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					ranks = {},
					manaOnly = row.manaOnly,
					noCasters = row.noCasters,
				},
			}
		end
	end
	BW.ReadAuras("target")
	for _, candidate in ipairs(candidates) do
		candidate.carried = BW.Carries(candidate.buff)
	end
	BW.ReadAuras("player")
	local role = BW.RoleOf("player", playerClass)
	local picked, parts = {}, {}
	for _, candidate in ipairs(candidates) do
		local entry, buff = candidate.entry, candidate.buff
		local family = entry.row.exclusive
		local state = candidate.state
		if not state then
			if entry.row.talent and not candidate.carried then
				state = "talent, not on them"
			elseif family and picked[family] then
				state = "one of its family already asked"
			elseif not BW.Wants(buff, playerClass, role) then
				state = "not offered to you"
			elseif BW.Has(buff, "player") then
				state = "on you"
			else
				if family then
					picked[family] = true
				end
				local at = guid and BW.AskedAt(guid, buff.key)
				state = at and string.format("asked %ds ago", math.floor(GetTime() - at)) or "asks"
			end
		end
		local spellId = entry.ids[#entry.ids]
		parts[#parts + 1] = string.format("%s=%s", C_Spell.GetSpellName(spellId) or tostring(spellId), state)
	end
	lines[#lines + 1] = "    their buffs: "
		.. (#parts > 0 and table.concat(parts, " | ") or "(none of their class here)")
end

--[[
    The state behind a "the Buff Duty window never shows" or "it doesn't offer
    X" report: whether it set up, every switch and setting, each gate its
    refresh checks (combat, WoW Forever's secret auras, being dead, nothing to
    offer or ask for), whether the window and its Options flyout are up now,
    every buff and self buff your class has on this client with who it's
    offered to, the ranks you know, the rank and group version the window
    would cast and whether the Buff Key would find each ready, and a
    warrior's Bloodrage; each hand's weapon and what your bags hold for it,
    the Soulstone and who already carries one, the consumables (Well Fed's
    buff food and each scroll type, what you carry and why each shows or
    doesn't), and the Buff Key's binding and any override taking its key;
    then every group member and your target as the window reads them, their
    PvP flags and yours, each with which of your buffs they have on or are
    missing and where the
    window's own verdict differs, what a pet or a friendly NPC target is held
    off or takes, which of a stranger target's buffs you'd ask them for, the
    other classes' buffs Party-Buffs counts, and what feeds Return the Favor.
    The group read is skipped in combat, as the window skips it.
    Existence/value reads only: nothing is cast, targeted or redrawn.
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
	--[[
	    On for your class: the switch, your class not turned off (Classes, or
	    Shift+Click on the mini-map button), and the window not closed this
	    session. The close button saves nothing and lasts until a login, a
	    reload or joining a group; the mini-map menu shows that close as
	    Paused, from the same read (ns.IsBuffDutyHiddenThisSession).
	]]
	local onForClass = ns.IsBuffDutyOnForClass and ns.IsBuffDutyOnForClass()
	lines[#lines + 1] = string.format(
		"Switches: enabled=%s onForYourClass=%s closedThisSession (menu: Paused)=%s hideInCombat=%s locked=%s selfBuffs=%s returnTheFavor=%s target=%s targetNPCs=%s askTarget=%s askOtherClasses=%s buffPvPFlagged=%s",
		tostring(db.enabled),
		tostring(onForClass),
		tostring(ns.IsBuffDutyHiddenThisSession and ns.IsBuffDutyHiddenThisSession() and true or false),
		tostring(db.hideInCombat),
		tostring(db.locked),
		tostring(db.selfEnabled),
		tostring(db.favorEnabled),
		tostring(db.targetEnabled),
		tostring(db.targetNPCs),
		tostring(db.askTarget),
		tostring(db.askOtherClasses),
		tostring(db.buffPvPFlagged)
	)
	lines[#lines + 1] = string.format(
		"Whispered ask: %s // Ask your target: %s // Send Messages In: %s",
		db.askMessage == nil and "default" or (db.askMessage == "" and "emptied (sends nothing)" or "edited"),
		db.askTargetMessage == nil and "default"
			or (db.askTargetMessage == "" and "emptied (sends nothing)" or "edited"),
		ns.GetMessageLanguage()
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
	local showIn, showWhere = db.showIn or {}, db.showWhere or {}
	lines[#lines + 1] = string.format(
		"When to Show: solo=%s (%s) party=%s (%s) raid=%s (%s) battleground=%s hiddenClasses=%s context=%s inGroup=%s inRaid=%s inInstance=%s (%s) shows here now=%s",
		tostring(ns.IsGroupContextOn(showIn, "solo")),
		tostring(showWhere.solo),
		tostring(ns.IsGroupContextOn(showIn, "party")),
		tostring(showWhere.party),
		tostring(ns.IsGroupContextOn(showIn, "raid")),
		tostring(showWhere.raid),
		tostring(ns.IsGroupContextOn(showIn, "battleground")),
		#hiddenClasses > 0 and table.concat(hiddenClasses, ",") or "none",
		ns.GetGroupContext(),
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
	--[[
	    This flavor's data switches: whether the consumable icons (Well Fed,
	    scrolls) start as Missing rather than off (Buff-Duty-Lookups.lua), and
	    whether a pet takes only the buffs its data row marks (Buff-Duty-Pets.lua).
	]]
	lines[#lines + 1] = string.format(
		"Flavor data: consumablesShownByDefault=%s petsTakeMarkedBuffsOnly=%s",
		tostring(ns.BUFF_DUTY_ITEM_BUFFS_SHOWN),
		tostring(ns.BUFF_DUTY_PETS_FLAGGED_ONLY)
	)
	--[[
	    While you aren't PvP-flagged and Buff PvP-Flagged Players is off, a cast
	    that would reach a flagged player (its target, anyone in a group buff's
	    party, or your party for Battle Shout) is held back on the window and
	    passed over by the Buff Key (BuffDuty.PvPFlaggedTarget). Each member's
	    and your target's flag shows on their line below.
	]]
	lines[#lines + 1] = string.format(
		"Gates now: inCombat=%s aurasSecret=%s cooldownsSecret=%s youDead=%s youPvPFlagged=%s anythingToOffer=%s castableBuffs=%d castableSelfBuffs=%d castableConsumables=%d weaponHands=%d soulstone=%s resurrection=%s",
		tostring(InCombatLockdown() and true or false),
		tostring(ns.AreAurasSecret()),
		tostring(ns.AreCooldownsSecret()),
		PlainText(UnitIsDeadOrGhost("player")),
		PlainText(UnitIsPVP("player")),
		tostring(BW.HasAnythingToOffer()),
		#BW.buffs,
		#BW.selfBuffs,
		#BW.selfItemBuffs,
		#BW.weaponBuffs,
		tostring(BW.soulstoneBuff ~= nil),
		tostring(BW.resurrection ~= nil)
	)
	--[[
	    The refresh hides the window unless one of these holds: something of
	    yours to cast or use, Missing Party Buffs watching (in a group, with
	    Ask for Buffs on), or Ask Your Target for Buffs watching (Your Target
	    and its Ask switch both on).
	]]
	lines[#lines + 1] = string.format(
		"Anything to show: yoursToCast=%s partyBuffsWatching=%s targetAsksWatching=%s",
		tostring(BW.HasAnythingToOffer()),
		tostring((IsInGroup() and db.askOtherClasses) and true or false),
		tostring((db.targetEnabled and db.askTarget) and true or false)
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
	--[[
	    The Options line at the window's foot, and each category line's
	    arrow, open the one menu on hover or click, only while the window is
	    on screen. Its Show in Window rows are each category's switch, read
	    under each Row below.
	]]
	local flyout = _G[ADDON_NAME .. "BuffDutyOptions"]
	lines[#lines + 1] = string.format(
		"Options menu: built=%s shown=%s",
		tostring(flyout ~= nil),
		tostring(flyout ~= nil and flyout:IsShown())
	)
	lines[#lines + 1] = string.format(
		"Rows live on this client: %d of %d buffs, %d of %d self buffs, %d consumables",
		#BW.entries,
		#(ns.BUFF_DUTY_SPELLS or {}),
		#BW.selfEntries,
		#(ns.BUFF_DUTY_SELF_SPELLS or {}),
		#BW.selfItemEntries
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
	-- Your group buffs on yourself: Self Buffs offers them by the Self-Buffs panel's timing, never your party row.
	for _, entry in ipairs(BW.entries) do
		if entry.row.class == class then
			any = true
			local buff = castableSelf[entry.key]
			lines[#lines + 1] = string.format(
				"  %s (group buff, on you): shows=%s inWindow=%s",
				SpellLabel(entry),
				tostring(db.selfRefresh[entry.key]),
				buff and ("yes cast=" .. tostring(buff.ranks[1] and buff.ranks[1].castText)) or "NO"
			)
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
	--[[
	    A warrior's self buff short on rage (Battle Shout) has its icon cast
	    Bloodrage first, while Bloodrage is known and off its own cooldown;
	    rage is heard (UNIT_POWER_UPDATE) for a warrior alone. A client
	    without Bloodrage leaves its ID out, and the line is skipped.
	]]
	if class == "WARRIOR" and ns.BLOODRAGE_SPELL_ID then
		local bloodrage = ns.BLOODRAGE_SPELL_ID
		local info = C_Spell.GetSpellCooldown(bloodrage)
		lines[#lines + 1] = string.format(
			"  Bloodrage first: known=%s rage=%s bloodrageCooldown=%s",
			tostring(ns.IsPlayerSpell(bloodrage)),
			PlainText(UnitPower("player", Enum.PowerType.Rage)),
			CooldownLeft(info and info.startTime, info and info.duration)
		)
	end
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
		"Weapons (switch %s, show %s, your class's picks on %s):",
		tostring(db.weaponEnabled),
		tostring(db.rowShow.weapons),
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
		-- A warlock stone line: its Create ranks, which the icon casts while none is in the bags.
		if entry.row.class == class and entry.create then
			local createIds = {}
			for _, rank in ipairs(entry.create) do
				createIds[#createIds + 1] = rank.id
			end
			lines[#lines + 1] = string.format(
				"  item %s: createRanksKnown=%d/%d unnamed=%d",
				tostring(entry.key),
				CountKnown(createIds),
				#createIds,
				CountUnnamed(createIds)
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
	    The consumables any class keeps up, each in its own category: each
	    one's stored switch (Off keeps an Other Buffs one out of the window;
	    Well Fed, Scrolls and Flasks or Elixirs keep to their category's), and
	    whether it made the castable list. An item
	    shows while one is in your bags and its buff is missing or low; Well
	    Fed and Scrolls read further below. Well Fed has no row without its
	    spell and aura tables, and Scrolls none without the first type's
	    lowest scroll's buff on this client.
	]]
	local castableItems = {}
	for _, buff in ipairs(BW.selfItemBuffs) do
		castableItems[buff.key] = buff
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Consumables:"
	local hasWellFed, hasScrolls = false, false
	for _, entry in ipairs(BW.selfItemEntries) do
		local buff = castableItems[entry.key]
		local name = entry.name or C_Spell.GetSpellName(entry.ids[1]) or tostring(entry.itemId or entry.key)
		lines[#lines + 1] = string.format(
			"  %s (%s): stored=%s inWindow=%s",
			name,
			tostring(entry.key),
			tostring(db.selfRefresh[entry.key]),
			buff and "yes" or "NO"
		)
		if entry.wellFed then
			hasWellFed = true
			WellFedLines(lines, db, buff)
		elseif entry.scrolls then
			hasScrolls = true
			ScrollLines(lines, buff, aurasSecret)
		elseif entry.itemId then
			local onFor = "(auras secret)"
			if not aurasSecret then
				local left = ReadUnitBuffs("player")
				local best
				for id in pairs(entry.auraIds) do
					if left[id] and (best == nil or left[id] == 0 or (best ~= 0 and left[id] > best)) then
						best = left[id]
					end
				end
				onFor = best == nil and "missing"
					or (best == 0 and "(no timer)" or (math.floor(best / 60) .. "m" .. (best % 60) .. "s"))
			end
			lines[#lines + 1] =
				string.format("    item %d: inBags=%d buff=%s", entry.itemId, C_Item.GetItemCount(entry.itemId), onFor)
		elseif entry.elixirs then
			--[[
			    Each elixir in your bags (the Ignore List aside), the slot or group its buff takes, whether the
			    category's menu turned it off (elixirOff), and whether that buff is on you.
			]]
			local left = aurasSecret and {} or ReadUnitBuffs("player")
			local carried = BW.CarriedElixirs()
			local elixirOff = db.elixirOff or {}
			for _, elixir in ipairs(carried) do
				lines[#lines + 1] = string.format(
					"    item %d (%s): buff %d group=%s ignored=%s turnedOff=%s on=%s",
					elixir.itemId,
					elixir.name,
					elixir.spellId,
					tostring(ns.ELIXIR_BUFF_IDS[elixir.spellId]),
					tostring(ns.IsIgnored(elixir.itemId)),
					tostring(elixirOff[elixir.itemId] == true),
					aurasSecret and "(auras secret)" or tostring(left[elixir.spellId] ~= nil)
				)
			end
			if not carried[1] then
				lines[#lines + 1] = "    no elixir in bags"
			end
		end
	end
	if not hasWellFed then
		lines[#lines + 1] = "  Well Fed: no row on this client"
	end
	if not hasScrolls then
		lines[#lines + 1] = "  Scrolls: no row on this client"
	end
	-- Each category's switch, When to Use, Show, Missing Inventory, whether it shows here, and whether the Buff Key uses it.
	for _, row in ipairs(ns.Data.BUFF_DUTY_ROWS) do
		lines[#lines + 1] = string.format(
			"  Row %s: on=%s when=%s show=%s missingInventory=%s showsHere=%s onKey=%s",
			row,
			tostring(BW.RowOn(row)),
			tostring(db.rowWhen[row]),
			tostring(db.rowShow[row]),
			tostring(BW.RowOut(row)),
			tostring(BW.RowShows(row)),
			tostring(BW.RowOnKey(row))
		)
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
		--[[
		    What the last press set the button to cast. A cast on someone else
		    is a macro that targets them first (TargetWhoItsFor in
		    Buff-Duty-Keys.lua), so a changed target after a press shows here.
		]]
		local keyButton = buttonName and _G[buttonName]
		if keyButton then
			local macrotext = keyButton:GetAttribute("macrotext")
			lines[#lines + 1] = string.format(
				"  last press set: type=%s spell=%s item=%s unit=%s macro=%s",
				tostring(keyButton:GetAttribute("type1")),
				tostring(keyButton:GetAttribute("spell")),
				tostring(keyButton:GetAttribute("item")),
				tostring(keyButton:GetAttribute("unit")),
				type(macrotext) == "string" and ns.DiagnosticShownText(macrotext) or "nil"
			)
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
	--[[
	    In a raid each group starts folded to its header (its group icons and
	    a counted icon per buff with no group version) until its header is
	    clicked open; which ones are open isn't readable here.
	]]
	lines[#lines + 1] = string.format(
		"Group: party=%s raid=%s members read=%d%s",
		tostring(IsInGroup() and true or false),
		tostring(IsInRaid() and true or false),
		#members,
		IsInRaid() and " (groups fold to their header until clicked open)" or ""
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

	--[[
	    Party-Buffs: every class's raid-wide buff (blessings aside) with its
	    Who Gets It, less your own castable ones (yours), counted in a group
	    with Ask Other Classes on, once its class is up and online in the
	    group, and a talent buff once anyone carries it; then how many icons
	    it would draw now. It alone keeps the window up for a class with
	    nothing to offer.
	]]
	local partyBuffRows = {}
	for _, entry in ipairs(BW.entries) do
		local row = entry.row
		if row.group and not row.exclusive then
			partyBuffRows[#partyBuffRows + 1] = string.format(
				"%s (%s)=%s%s",
				C_Spell.GetSpellName(entry.key) or "?",
				tostring(row.class),
				castable[entry.key] and "yours" or tostring(db.audience[entry.key]),
				row.talent and " talent" or ""
			)
		end
	end
	local watchesPartyBuffs = (IsInGroup() and db.askOtherClasses) and true or false
	lines[#lines + 1] = string.format(
		"Party-Buffs: watching=%s iconsNow=%s rows=%s",
		tostring(watchesPartyBuffs),
		(watchesPartyBuffs and not aurasSecret) and tostring(#BW.BuildOtherClassBuffs()) or "n/a",
		#partyBuffRows > 0 and table.concat(partyBuffRows, " | ") or "none on this client"
	)

	if not UnitExists("target") then
		lines[#lines + 1] = "Target: none"
	elseif ns.IsUnitIdentitySecret("target") then
		lines[#lines + 1] = "Target: identity secret"
	else
		lines[#lines + 1] = string.format(
			"Target: player=%s inParty=%s inRaid=%s canAssist=%s canBuff=%s petControlledByPlayer=%s pvpFlagged=%s",
			PlainText(UnitIsPlayer("target")),
			PlainText(UnitInParty("target")),
			PlainText(UnitInRaid("target") ~= nil),
			PlainText(UnitCanAssist("player", "target")),
			tostring(BW.CanBuff("target") and true or false),
			PlainText(not UnitIsPlayer("target") and UnitPlayerControlled("target")),
			PlainText(UnitIsPVP("target"))
		)
		--[[
		    Who the Target list takes: a player outside your group who isn't
		    you, or a pet outside it that isn't yours and whose owner isn't in
		    your group (a group's own sit under their owners).
		]]
		lines[#lines + 1] = string.format(
			"  outsider: isYou=%s isYourPet=%s playerOrPetInParty=%s playerOrPetInRaid=%s",
			PlainText(UnitIsUnit("target", "player")),
			PlainText(UnitIsUnit("target", "pet")),
			PlainText(UnitPlayerOrPetInParty("target")),
			PlainText(UnitPlayerOrPetInRaid("target"))
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
			-- The ask row is for a player outside your group alone: a group member's buffs are Party-Buffs'.
			local inGroup = ns.IsPlainYes(UnitInParty("target")) or ns.IsPlainYes(UnitInRaid("target"))
			if aurasSecret then
				lines[#lines + 1] = "  ask: (auras secret)"
			elseif inGroup or ns.IsPlainYes(UnitIsUnit("target", "player")) then
				lines[#lines + 1] = "  ask: none (in your group, or you)"
			else
				AskLines(lines, BW, db, targetClass)
			end
		end
		--[[
		    A friendly NPC (a quest's wounded soldier) gets the Target list's
		    row: not a player or anyone's pet, alive, in sight, and one you can
		    help. It is offered every single-target buff you have on, whatever
		    it wears and whoever the buff is set for, one after another in a
		    cycle (which buff the cycle has reached isn't readable here); a
		    Mana-only buff still wants a mana bar, Blessing of Might skips a
		    caster's class, and a buff the game refused on it stays held off
		    while it's around.
		]]
		local canBuffNPC = BW.CanBuffNPC and BW.CanBuffNPC("target") or false
		local npcClass = select(2, UnitClass("target"))
		local npcPower = UnitPowerType("target")
		lines[#lines + 1] = string.format(
			"  npc: canBuffNPC=%s powerType=%s class=%s",
			tostring(canBuffNPC),
			PlainText(npcPower),
			PlainText(npcClass)
		)
		if canBuffNPC then
			local npcGUID = UnitGUID("target")
			npcGUID = ns.IsPlain(npcGUID) and npcGUID or nil
			local casters = ns.Data.CASTER_CLASSES or {}
			local takes = {}
			for _, buff in ipairs(BW.buffs) do
				local state = "takes"
				if not buff.singleName then
					state = "group version only"
				elseif buff.noCasters and ns.IsPlain(npcClass) and npcClass and casters[npcClass] then
					state = "caster class"
				elseif buff.manaOnly and not (ns.IsPlain(npcPower) and npcPower == Enum.PowerType.Mana) then
					state = "no mana"
				elseif npcGUID and BW.IsHeld(npcGUID, buff.key) then
					state = "held (refused)"
				end
				takes[#takes + 1] = (buff.singleName or buff.groupName or "?") .. "=" .. state
			end
			lines[#lines + 1] = "    takes: " .. (#takes > 0 and table.concat(takes, " | ") or "(none castable)")
		end
	end
	lines[#lines + 1] = string.format(
		"Return the Favor: a stranger who buffs you is listed for %d seconds, %d at a time.",
		db.favorSeconds,
		ns.Data.BUFF_DUTY_FAVOR_MAX
	)
	--[[
	    Strangers' buffs are heard after the pause that follows login and every
	    loading screen, and then how many strangers are kept inside that time.
	]]
	local favorsKept, now = 0, GetTime()
	if BW.EachFavor then
		for _, favor in BW.EachFavor() do
			if now - favor.at <= db.favorSeconds then
				favorsKept = favorsKept + 1
			end
		end
	end
	lines[#lines + 1] = string.format(
		"  heard from %s: ready=%s strangersKept=%d",
		ns.FLAVOR == "Camelot" and "your own auras" or "the combat log",
		tostring(ns.IsBuffDutyReady and ns.IsBuffDutyReady()),
		favorsKept
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
	-- Ask Your Target for Buffs leaves a player who is DND alone.
	{ "UnitIsDND (guarded)", HasGlobalFunction("UnitIsDND") },
	-- A warrior's self buff short on rage casts Bloodrage first.
	{
		"Enum.PowerType.Rage",
		function()
			return type(Enum) == "table" and type(Enum.PowerType) == "table" and Enum.PowerType.Rage ~= nil
		end,
	},
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
      loads late, and Bloodrage, which a warrior's self-buff icon casts by
      that name (Buff-Duty-Self.lua);
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

	local spellConstants = {}
	for constant, id in pairs(ns.GAME_IDS or {}) do
		spellConstants[constant] = id
	end
	spellConstants.BLOODRAGE_SPELL_ID = ns.BLOODRAGE_SPELL_ID
	for _, constant in ipairs(SortedKeys(spellConstants)) do
		local id = spellConstants[constant]
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
    buff the window counts, and the longest is kept: once as said to the
    group, and once whispered, in the player's saved text (or the Send
    Messages In language's default), through ns:BuildBuffAskWhisper. A
    whisper the player emptied sends nothing, and the notes say so. The ask
    to your target is built per class at its widest the same way, through
    ns:BuildBuffAskTargetWhisper.

    Buff Duty's Return the Favor buttons cast through a macro naming the
    stranger, one per buff you can give right now, built by ns.BuffDuty's
    own SingleIcon with your top rank's cast text and a 12-letter name on your
    realm.
]]
ns.DIAGNOSTIC_MESSAGES = function()
	local rows, notes = {}, {}
	local BW = ns.BuffDuty
	if BW and BW.entries then
		local longestAsk, longestWhisper
		local template = ns.GetMessageText("buffAsk")
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
				local ask = ns:BuildBuffRequestMessage(longestNames, #longestNames, link)
				if not longestAsk or #ask > #longestAsk then
					longestAsk = ask
				end
				local whisper = ns:BuildBuffAskWhisper(template, longestNames, #longestNames, link)
				if whisper and (not longestWhisper or #whisper > #longestWhisper) then
					longestWhisper = whisper
				end
			end
		end
		if longestAsk then
			rows[#rows + 1] = {
				label = "Buff Duty ask for a buff, said to the group",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = longestAsk,
			}
		end
		if longestWhisper then
			rows[#rows + 1] = {
				label = "Buff Duty ask for a buff, whispered (" .. ns.GetMessageLanguage() .. ")",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = longestWhisper,
			}
		elseif longestAsk then
			notes[#notes + 1] = "The whispered ask is emptied on the Buff Duty panel, so nothing is whispered."
		end

		--[[
		    The ask to your target, at its widest: every buff of one class it
		    could name (one per exclusive family, as the Ask row picks), to a
		    12-letter name, for the class that makes it longest.
		]]
		local targetTemplate = ns.GetMessageText("buffAskTarget")
		local byClass, families = {}, {}
		for _, entry in ipairs(BW.entries) do
			local row = entry.row
			local family = row.exclusive and (row.class .. row.exclusive)
			if row.class and not (family and families[family]) then
				if family then
					families[family] = true
				end
				local linkId = entry.ids[#entry.ids]
				byClass[row.class] = byClass[row.class] or {}
				table.insert(byClass[row.class], ns.GetSpellLink(linkId) or C_Spell.GetSpellName(linkId) or "")
			end
		end
		local longestTarget, anyClass
		for _, links in pairs(byClass) do
			anyClass = true
			local whisper = ns:BuildBuffAskTargetWhisper(targetTemplate, string.rep("W", 12), links)
			if whisper and (not longestTarget or #whisper > #longestTarget) then
				longestTarget = whisper
			end
		end
		if longestTarget then
			rows[#rows + 1] = {
				label = "Buff Duty ask to your target, whispered (" .. ns.GetMessageLanguage() .. ")",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = longestTarget,
			}
		elseif anyClass then
			notes[#notes + 1] =
				"The ask to your target is emptied on the Buff Duty panel, or too long even linked by name, so nothing is whispered."
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
			-- A warlock stone's Create spells are spells too; they put on no enchant themselves.
			if kind ~= "item" then
				for _, rank in ipairs(row.create or {}) do
					found[#found + 1] =
						{ id = rank[1], key = index, row = { row = row, level = rank[2], enchant = "create" } }
				end
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
			for _, item in ipairs(stone.items or {}) do
				found[#found + 1] = { id = item[1], key = item[1], row = { role = "stone", level = item[2] } }
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

-- The Self-Buffs consumables: each item, and the auras it leaves as spells.
local function CollectSelfItems(kind)
	return function(rows)
		local found = {}
		for index, row in ipairs(rows) do
			if kind == "item" then
				found[#found + 1] = { id = row[1], key = index, row = { role = "item", default = row.default } }
			else
				for _, id in ipairs(row.auras or {}) do
					found[#found + 1] = { id = id, key = index, row = { role = "aura" } }
				end
			end
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
			{ ns.BUFF_DUTY_SELF_ITEMS, CollectSelfItems("spell") },
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
					{ "DATA_LEVEL", FoundField("level") },
				},
			},
			{
				table = "BUFF_DUTY_SELF_ITEMS",
				kind = "item",
				collect = CollectSelfItems("item"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_DEFAULT", FoundField("default") },
				},
			},
			{
				table = "BUFF_DUTY_SELF_ITEMS",
				kind = "spell",
				collect = CollectSelfItems("spell"),
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

--[[
    Only a client whose weapons carry an imbue beside an oil or stone
    (ns.WEAPON_ENCHANTS_STACK, WoW Forever) ships the items that put on an
    imbue, so only there does the table get its row: elsewhere it is rightly
    absent, not a missing table.
]]
if ns.WEAPON_ENCHANTS_STACK then
	ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
		{
			label = "Buff-Duty-Spells",
			sources = {
				{
					table = "BUFF_DUTY_WEAPON_IMBUE_ITEMS",
					kind = "item",
					collect = function(itemIds)
						local found = {}
						for _, id in ipairs(itemIds) do
							found[#found + 1] = { id = id, row = id }
						end
						return found
					end,
				},
			},
		},
	})
end
