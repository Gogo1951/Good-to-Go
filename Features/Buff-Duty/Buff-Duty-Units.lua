local _, ns = ...
local Data = ns.Data

local BuffDuty = ns.BuffDuty
local RankFor = BuffDuty.RankFor

--------------------------------------------------------------------------------
-- Unit Reads
--------------------------------------------------------------------------------

function BuffDuty.CanBuff(unit)
	return UnitExists(unit) and UnitIsPlayer(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

local heldMembers

-- A raid token the client won't compare plainly counts as someone else.
function BuffDuty.GroupMembers()
	if heldMembers then
		return heldMembers
	end
	local members = {}
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local _, _, subgroup = GetRaidRosterInfo(i)
			if subgroup then
				local unit = "raid" .. i
				local isPlayer = UnitIsUnit(unit, "player")
				members[#members + 1] =
					{ unit = unit, subgroup = subgroup, isPlayer = ns.IsPlain(isPlayer) and isPlayer or false }
			end
		end
	else
		members[1] = { unit = "player", subgroup = 1, isPlayer = true }
		for i = 1, 4 do
			if UnitExists("party" .. i) then
				members[#members + 1] = { unit = "party" .. i, subgroup = 1 }
			end
		end
	end
	return members
end

--[[
    While held, GroupMembers hands every caller one roster read. Hold only
    around one synchronous redraw, where the roster can't change.
]]
function BuffDuty.HoldGroupMembers(hold)
	heldMembers = nil
	if hold then
		heldMembers = BuffDuty.GroupMembers()
	end
end

-- SOLO is the Solo group context.
local function CountsAsTank(key)
	local when = key and ns.db.global.buffWindow.tankWhen[key]
	return when == Data.TANK_WHEN.ALWAYS or (when == Data.TANK_WHEN.SOLO and ns.GetGroupContext() == "solo")
end
BuffDuty.CountsAsTank = CountsAsTank

--[[
    An actual role always wins over Count as Tanks. In a raid only the Main
    Tank mark makes a tank: a Tank role there is self-ticked, not the raid's
    call. The mark is asked for exactly, or GetPartyAssignment also says yes
    to anyone whose role is Tank.
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
		if ns.IsPlainTrue(UnitIsUnit(unit, "player")) then
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

-- A live buff can report 0 (no timer), so nil-check the result rather than test it for truthiness.
local function GetBuffDuration(unit, spellId)
	for i = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
		if not data then
			return nil
		end
		if ns.IsPlain(data.spellId) and data.spellId == spellId then
			return data.duration or 0
		end
	end
	return nil
end

--[[
    A Phase Shifted imp can't be targeted however close it stands. Kept per
    frame: the range ticker asks once per icon, and one pet can have several.
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
		phaseShifted[unit] = GetBuffDuration(unit, spellId) ~= nil
	end
	return phaseShifted[unit]
end
BuffDuty.IsPhaseShifted = IsPhaseShifted

--------------------------------------------------------------------------------
-- PvP Flags
--------------------------------------------------------------------------------

local function FlaggedName(unit)
	if not unit or not UnitExists(unit) then
		return nil
	end
	local isSelf = UnitIsUnit(unit, "player")
	if not ns.IsPlain(isSelf) or isSelf then
		return nil
	end
	local flagged = UnitIsPVP(unit)
	if not ns.IsPlain(flagged) or not flagged then
		return nil
	end
	local name = GetUnitName(unit, false)
	return ns.IsPlain(name) and name or nil
end

--[[
    Buffing a PvP-flagged player flags you too. A group buff lands on the
    whole party, and a party self-buff (Battle Shout) on yours. A favor out of
    sight has no unit token to ask.
]]
function BuffDuty.PvPFlaggedTarget(spec)
	if not spec or spec.ask or ns.db.global.buffWindow.buffPvPFlagged then
		return nil
	end
	local mine = UnitIsPVP("player")
	if not ns.IsPlain(mine) or mine then
		return nil
	end
	local subgroup = spec.isGroup and spec.subgroup
	if spec.party then
		for _, member in ipairs(BuffDuty.GroupMembers()) do
			if member.isPlayer then
				subgroup = member.subgroup
			end
		end
	end
	if subgroup then
		for _, member in ipairs(BuffDuty.GroupMembers()) do
			if member.subgroup == subgroup and not member.isPlayer then
				local name = FlaggedName(member.unit)
				if name then
					return name
				end
			end
		end
	end
	return FlaggedName(spec.unit)
end

--[[
    An unknown or secret answer reads as in range: the fade is a hint, and a
    wrong "out of range" would hide a buff the player could have cast.
    UnitInRange only knows group members.
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

-- Cut from the 64-pixel sheet in pixels, as the |T escape wants: left, right, top, bottom.
local ROLE_ICON_SHEET = "Interface/LFGFrame/UI-LFG-ICON-PORTRAITROLES"
local ROLE_ICON_COORDS = {
	TANK = "0:19:22:41",
	HEALER = "20:39:1:20",
	DAMAGER = "20:39:22:41",
}

local function RoleIcon(role)
	return ("|T%s:%d:%d:0:0:64:64:%s|t "):format(
		ROLE_ICON_SHEET,
		Data.BUFF_DUTY_LABEL_ICON_SIZE,
		Data.BUFF_DUTY_LABEL_ICON_SIZE,
		ROLE_ICON_COORDS[role]
	)
end

-- The color already says the class, so the icon says the role. A stranger out of sight shows as damage.
function BuffDuty.PlayerLabel(name, class, unit)
	return RoleIcon(BuffDuty.RoleOf(unit, class)) .. (ns.GetClassColor(class) or ns.GetColor("TEXT")) .. name .. "|r"
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

--[[
    A /targetexact miss leaves the old target, so clearing first lets [help]
    stop the cast rather than fall through to them or you. The found player is
    left targeted on purpose: that is how the window sees the buff land.
]]
local function TargetMacro(name, castText)
	return "/cleartarget\n/targetexact " .. name .. "\n/cast [help] " .. castText
end

--[[
    Cast by rank text, "Power Word: Fortitude(Rank 2)": a bare name casts your
    highest rank and fails on anyone too low for it, and a spell ID casts
    nothing on Classic Era. Without castUnit the button targets `fullName` by
    macro.
]]
local function SingleIcon(buff, unit, castUnit, targetName, fullName, favorGUID)
	if BuffDuty.ShutOut(buff) then
		return nil
	end
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

function BuffDuty.WithTimeLeft(icon, expires, duration)
	if icon and expires and duration and duration > 0 then
		icon.buffExpires, icon.buffDuration = expires, duration
	end
	return icon
end
