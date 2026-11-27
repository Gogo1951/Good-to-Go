local _, ns = ...
local Data = ns.Data

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local SingleIcon = BuffDuty.SingleIcon
local IsHeld = BuffDuty.IsHeld

--[[
    GUID -> buff key -> true for this round. An NPC is buffed in a cycle, not
    by what it wears: quests want the same buff cast again and again, and its
    auras say little about that.
]]
local cycled = {}

function BuffDuty.NoteNPCCast(guid, key)
	if not (ns.IsPlain(guid) and guid and key) then
		return
	end
	cycled[guid] = cycled[guid] or {}
	cycled[guid][key] = true
end

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

-- Only a readable "yes" from UnitCanAssist lets it on, so no hostile or neutral mob is ever offered a buff.
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

-- Every buff regardless of audience: you target an NPC to buff it, usually for a quest.
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
    A refused cast holds that buff while the NPC stays targeted, so a
    quest-giver who can't take buffs stops being offered them. Marked `npc`
    so the Buff Key casts it last: its cycle never empties.
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
