local _, ns = ...
local Data = ns.Data

--[[
    Buff-Duty-NPCs -- a targeted friendly NPC's row on Buff Duty's Target
    list: whether you can buff it, which buffs it takes, and the cycle that
    walks it through each of them in turn. Shared with the other Buff Duty
    files through ns.BuffDuty.
]]

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local SingleIcon = BuffDuty.SingleIcon
local IsHeld = BuffDuty.IsHeld

--[[
    GUID -> buff key -> true: the buffs a targeted friendly NPC has had from you
    this time round. An NPC is buffed in a cycle, not by what it wears: quests
    want the same buff cast on it again and again, and an NPC's auras say
    little about that. Each cast moves its row on to the next buff; once every
    one has been cast the cycle starts over (BuffDuty.NPCRow).
]]
local cycled = {}

function BuffDuty.NoteNPCCast(guid, key)
	if not (ns.IsPlain(guid) and guid and key) then
		return
	end
	cycled[guid] = cycled[guid] or {}
	cycled[guid][key] = true
end

-- Drops every NPC's cycle but those on the GUIDs in `keep`, from BuffDuty.PruneAuraCache.
function BuffDuty.PruneNPCCycles(keep)
	for guid in pairs(cycled) do
		if not keep[guid] then
			cycled[guid] = nil
		end
	end
end

--------------------------------------------------------------------------------
-- Friendly NPCs
--------------------------------------------------------------------------------

--[[
    A friendly NPC you have targeted, one you could buff right now: not a
    player or anyone's pet, alive, in sight, and one the game says you can
    help. Quests ask for this (a priest's Power Word: Fortitude on a wounded
    soldier), so a targeted NPC gets the Target list's row like a player does.
    Here only a readable "yes" from UnitCanAssist lets it on, so no hostile
    or neutral mob is ever offered a buff.
]]
function BuffDuty.CanBuffNPC(unit)
	if not UnitExists(unit) or UnitIsPlayer(unit) or UnitPlayerControlled(unit) or UnitIsDeadOrGhost(unit) then
		return false
	end
	if ns.IsUnitIdentitySecret(unit) then
		return false
	end
	local visible = UnitIsVisible(unit)
	if ns.IsPlain(visible) and not visible then
		return false
	end
	local canAssist = UnitCanAssist("player", unit)
	return ns.IsPlain(canAssist) and canAssist and true or false
end

--[[
    An NPC takes every buff you have on, whoever it is set for: you target one
    to buff it, usually for a quest, so a buff kept for Tanks shouldn't hide.
    Mana-only buffs go by its power bar, and Blessing of Might skips an NPC
    whose class is a caster's (NPCs have classes too).
]]
local function NPCWants(buff, unit)
	if buff.noCasters then
		local _, class = UnitClass(unit)
		if ns.IsPlain(class) and class and Data.CASTER_CLASSES[class] then
			return false
		end
	end
	if buff.manaOnly then
		local powerType = UnitPowerType(unit)
		return ns.IsPlain(powerType) and powerType == Enum.PowerType.Mana
	end
	return true
end

-- The NPC's icons this time round: each buff it takes that it hasn't had from you yet in this cycle.
local function CycleIcons(unit, castUnit, name, guid)
	local done = guid and cycled[guid]
	local icons = {}
	for _, buff in ipairs(buffs) do
		if buff.singleName and NPCWants(buff, unit) and not IsHeld(guid, buff.key) then
			if not (done and done[buff.key]) then
				icons[#icons + 1] = SingleIcon(buff, unit, castUnit, name)
			end
		end
	end
	return icons
end

--[[
    A targeted NPC's row, cast at `castUnit`: a cycle through every buff it
    takes, whatever it already wears (see `cycled`), starting over once each
    has been cast. Nil when it takes none of yours. Casts on it are followed
    like a pet's (anything not a player is, in Buff-Duty-Cast-Results.lua): one
    the game refuses outright holds that buff while the NPC stays targeted
    (BuffDuty.PruneAuraCache drops the hold once it isn't), so a quest-giver
    who can't take buffs doesn't keep offering them.
    The row is marked `npc`, so the Buff Key casts it only after everyone else.
]]
function BuffDuty.NPCRow(unit, castUnit)
	if not BuffDuty.CanBuffNPC(unit) then
		return nil
	end
	local guid = UnitGUID(unit)
	guid = ns.IsPlain(guid) and guid or nil
	local name = GetUnitName(unit, false) or ""
	local icons = CycleIcons(unit, castUnit, name, guid)
	if #icons == 0 and guid and cycled[guid] then
		cycled[guid] = nil
		icons = CycleIcons(unit, castUnit, name, guid)
	end
	if #icons == 0 then
		return nil
	end
	return { label = ns.GetColor("HELP") .. name .. "|r", icons = icons, npc = true }
end
