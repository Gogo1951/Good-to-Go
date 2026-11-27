local _, ns = ...

local BuffDuty = ns.BuffDuty

-- Ahead of every buff's column (which count from 1), so a resurrection always lines up on the left.
local RESURRECTION_COLUMN = 0

-- The minute the game gives a resurrected player to accept.
local RESURRECT_PENDING_SECONDS = 60
local pendingResurrects = {} -- GUID -> GetTime() the offer runs out

--[[
    SPELL_RESURRECT fires as the cast lands, before the dead player accepts;
    without this the icon would invite a second healer to resurrect someone
    already waiting. On Forever, which forbids the combat log, your own
    resurrection going off stands in (ns.OnResurrectCastSucceeded).
]]
function BuffDuty.NoteResurrect(guid)
	if not ns.IsPlain(guid) or not guid then
		return
	end
	local now = GetTime()
	for key, expires in pairs(pendingResurrects) do
		if expires <= now then
			pendingResurrects[key] = nil
		end
	end
	pendingResurrects[guid] = now + RESURRECT_PENDING_SECONDS
	if ns.RequestBuffDutyRefresh then
		ns.RequestBuffDutyRefresh()
	end
end

-- A released ghost has no corpse here to cast on.
local function CanResurrect(unit)
	if not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
		return false
	end
	if not UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
		return false
	end
	local incoming = ns.UnitHasIncomingResurrection(unit)
	if ns.IsPlain(incoming) and incoming then
		return false
	end
	local guid = UnitGUID(unit)
	local expires = ns.IsPlain(guid) and guid and pendingResurrects[guid]
	return not (expires and expires > GetTime())
end

-- castIds lets the Buff Key match the cast whichever rank goes off.
function BuffDuty.ResurrectionIcon(unit, castUnit, targetName)
	local resurrection = BuffDuty.resurrection
	if not resurrection or BuffDuty.ShutOut(resurrection) or not CanResurrect(unit) then
		return nil
	end
	return {
		spellId = resurrection.id,
		column = RESURRECTION_COLUMN,
		spellName = resurrection.name,
		castSpell = resurrection.castText,
		castIds = resurrection.ids,
		unit = castUnit,
		targetName = targetName,
		isResurrection = true,
	}
end

-- Ranks come sorted lowest first (BuffDuty.BuildLookup).
local function HighestKnown(ids)
	for i = #ids, 1, -1 do
		if ns.IsPlayerSpell(ids[i]) then
			return ids[i]
		end
	end
	return nil
end

-- Cast with its rank: on Classic Era every rank shares one name, and a bare-name cast can pick Rank 1.
function BuffDuty.PickResurrection(playerClass)
	BuffDuty.resurrection = nil
	for _, row in ipairs(BuffDuty.resurrections) do
		if row.class == playerClass then
			local id = HighestKnown(row.ranks)
			local name = id and C_Spell.GetSpellName(id)
			if name then
				BuffDuty.resurrection = {
					id = id,
					name = name,
					castText = BuffDuty.CastText(id, name),
					ids = row.ranks,
					noShadowform = row.noShadowform,
				}
			end
		end
	end
end
