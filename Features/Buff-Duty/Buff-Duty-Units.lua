local _, ns = ...
local Data = ns.Data

--[[
    Buff Duty's unit reads: whether a unit can take a buff, the role and
    class it is buffed as, how far away it is, a player's row label, and the
    icons that cast at it. What it has on is Buff-Duty-Auras.lua's; a dead
    player's resurrection is Buff-Duty-Resurrections.lua's and a pet's row
    Buff-Duty-Pets.lua's. Shared with the other Buff Duty files through
    ns.BuffDuty.
]]

local BuffDuty = ns.BuffDuty
local RankFor = BuffDuty.RankFor

--------------------------------------------------------------------------------
-- Unit Reads
--------------------------------------------------------------------------------

function BuffDuty.CanBuff(unit)
	return UnitExists(unit) and UnitIsPlayer(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

-- Your group as { unit, subgroup }: the raid by roster order, or you and your party.
function BuffDuty.GroupMembers()
	local members = {}
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local _, _, subgroup = GetRaidRosterInfo(i)
			if subgroup then
				members[#members + 1] = { unit = "raid" .. i, subgroup = subgroup }
			end
		end
	else
		members[1] = { unit = "player", subgroup = 1 }
		for i = 1, 4 do
			if UnitExists("party" .. i) then
				members[#members + 1] = { unit = "party" .. i, subgroup = 1 }
			end
		end
	end
	return members
end

-- Whether a Count as Tanks entry (a class token, or Data.TANK_WHEN_PET) applies right now.
local function CountsAsTank(key)
	local when = key and ns.db.global.buffWindow.tankWhen[key]
	return when == Data.TANK_WHEN.ALWAYS or (when == Data.TANK_WHEN.SOLO and not IsInGroup())
end
BuffDuty.CountsAsTank = CountsAsTank

--[[
    The role a player is buffed as, for a buff offered to Tanks or Healers: the
    raid's Main Tank mark, then the role assigned in the group finder (damage
    included, so an assigned role always beats a ticked box). For you alone,
    with no role assigned, the roles ticked in the group finder's own listing (Era's solo
    Tank / Healer / DPS boxes, which never assign a role), the first ticked of
    Tank, then Healer -- a tank's buffs matter most. Anyone with none of these -- a
    low-level player who can't pick a role yet, a group that never set one, or
    a stranger (`unit` nil when out of sight) -- counts as a tank when the
    player's Count as Tanks setting says their `class` does right now, and
    otherwise as damage. An actual role always wins over the class setting.
    In a raid only the Main Tank mark makes a tank: a Tank role or box there is
    one a player ticked for themselves in the group finder, not the raid's
    call. The mark is asked for exactly -- without that, GetPartyAssignment
    also says yes to anyone whose role is Tank. A client without one of the
    group calls answers nil from its accessor, so it simply skips to the next.
]]
function BuffDuty.RoleOf(unit, class)
	if unit then
		if ns.GetPartyAssignment("MAINTANK", unit, true) then
			return "TANK"
		end
		local inRaid = IsInRaid()
		local role = ns.UnitGroupRolesAssigned(unit)
		if ns.IsPlain(role) and ((role == "TANK" and not inRaid) or role == "HEALER" or role == "DAMAGER") then
			return role
		end
		if UnitIsUnit(unit, "player") then
			local _, tank, healer = ns.GetLFGRoles()
			if tank and not inRaid then
				return "TANK"
			elseif healer then
				return "HEALER"
			end
		end
	end
	if CountsAsTank(class) then
		return "TANK"
	end
	return "DAMAGER"
end

-- Is this player someone the buff is offered to at all, whatever they have on?
function BuffDuty.Wants(buff, class, role)
	if buff.manaOnly and Data.NO_MANA_CLASSES[class] then
		return false
	end
	if buff.noCasters and Data.CASTER_CLASSES[class] then
		return false
	end
	if buff.audience == Data.BUFF_AUDIENCE.TANK then
		return role == "TANK"
	elseif buff.audience == Data.BUFF_AUDIENCE.HEALER then
		return role == "HEALER"
	end
	return true
end

--[[
    A pet in Phase Shift (a warlock's imp) can't be targeted, so no buff
    reaches it until it phases back in, however close it stands. Secret auras
    on WoW Forever read as not shifted. Each unit's answer is kept for the
    frame it was read in: the range ticker asks once per icon, and one pet can
    have several.
]]
local phaseShifted, phaseShiftedAt = {}, nil

local function IsPhaseShifted(unit)
	local spellId = ns.GAME_IDS.PHASE_SHIFT_SPELL_ID
	if not spellId or ns.AreAurasSecret() then
		return false
	end
	local isPlayer = UnitIsPlayer(unit)
	if not ns.IsPlain(isPlayer) or isPlayer then
		return false
	end
	local now = GetTime()
	if phaseShiftedAt ~= now then
		wipe(phaseShifted)
		phaseShiftedAt = now
	end
	if phaseShifted[unit] == nil then
		phaseShifted[unit] = ns.GetBuffDuration(unit, spellId) ~= nil
	end
	return phaseShifted[unit]
end
BuffDuty.IsPhaseShifted = IsPhaseShifted

--[[
    Is `unit` close enough to take `spellName`? A phase-shifted pet never is.
    Otherwise the spell's own range check first; when it has no answer,
    UnitInRange's group-wide ~40 yards, which only knows about group members. A unit we can't ask about reads as in range, and so does any
    secret answer (WoW Forever's for a stranger): the fade is a hint, and a
    wrong "out of range" would hide a buff the player could have cast.
]]
function ns.IsBuffInRange(unit, spellName)
	if not unit or not ns.CanCompareUnitTokens(unit, "player") then
		return true
	end
	local isPlayer = UnitIsUnit(unit, "player")
	if not ns.IsPlain(isPlayer) or isPlayer then
		return true
	end
	if IsPhaseShifted(unit) then
		return false
	end
	if spellName then
		local inRange = C_Spell.IsSpellInRange(spellName, unit)
		if ns.IsPlain(inRange) and inRange ~= nil then
			return inRange and true or false
		end
	end
	local visible = UnitIsVisible(unit)
	if not ns.IsPlain(visible) then
		return true
	end
	if not visible then
		return false
	end
	local inRange, checked = UnitInRange(unit)
	if ns.IsPlain(checked) and ns.IsPlain(inRange) and checked then
		return inRange and true or false
	end
	return true
end

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------
--[[
    The group finder's round role icons, cut from its 64-pixel sheet (as pixels,
    the way the |T escape wants them): left, right, top, bottom.
]]
local ROLE_ICON_SHEET = "Interface/LFGFrame/UI-LFG-ICON-PORTRAITROLES"
local ROLE_ICON_COORDS = {
	TANK = "0:19:22:41",
	HEALER = "20:39:1:20",
	DAMAGER = "20:39:22:41",
}

local function RoleIcon(role)
	return ("|T%s:%d:%d:0:0:64:64:%s|t "):format(
		ROLE_ICON_SHEET,
		Data.BUFF_DUTY_ICON_SIZE,
		Data.BUFF_DUTY_ICON_SIZE,
		ROLE_ICON_COORDS[role]
	)
end

--[[
    A player's row label: role icon, then the name in its class color -- the
    color already says the class, so the icon says the role. `unit` is nil for
    a stranger out of sight, who is shown as damage.
]]
function BuffDuty.PlayerLabel(name, class, unit)
	return RoleIcon(BuffDuty.RoleOf(unit, class)) .. (ns.GetClassColor(class) or ns.GetColor("TEXT")) .. name .. "|r"
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

--[[
    /targetexact finds a nearby player by name with no unit token, and a miss
    leaves the old target in place. Clearing first means a miss leaves nothing
    targeted, so [help] stops the cast instead of falling through to whoever
    you had targeted or to yourself. Leaving the found player targeted is
    deliberate: it is how the window sees the buff land and drops the icon.
]]
local function TargetMacro(name, castText)
	return "/cleartarget\n/targetexact " .. name .. "\n/cast [help] " .. castText
end

--[[
    One single-target icon, sized to the target: `unit` is who it is for (nil
    when out of sight), `castUnit` the token the button casts at. Without a
    castUnit the button targets `fullName` by macro instead. The button casts
    the chosen rank by its rank text, "Power Word: Fortitude(Rank 2)": a bare
    name casts your highest rank and fails on anyone too low for it, and a
    spell ID did nothing at all on Classic Era. Nil when the target is too low
    for any rank.
]]
local function SingleIcon(buff, unit, castUnit, targetName, fullName, favorGUID)
	local rank = RankFor(buff, unit and UnitLevel(unit))
	if not rank then
		return nil
	end
	return {
		spellId = rank.id,
		column = buff.column,
		spellName = rank.name,
		castSpell = rank.castText,
		unit = castUnit,
		targetName = targetName,
		macrotext = not castUnit and TargetMacro(fullName, rank.castText) or nil,
		favorGUID = favorGUID,
		buffKey = buff.key,
	}
end
BuffDuty.SingleIcon = SingleIcon

--[[
    Stamps an icon with the version running low that Has reported, so the
    window draws how much of it is left; an icon for a buff that is gone
    entirely carries none and draws whole. Returns the icon.
]]
function BuffDuty.WithTimeLeft(icon, expires, duration)
	if icon and expires and duration and duration > 0 then
		icon.buffExpires, icon.buffDuration = expires, duration
	end
	return icon
end
