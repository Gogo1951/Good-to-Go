local _, ns = ...

--[[
    Buff-Duty-Resurrections -- a dead player's resurrection icon, and the
    minute a resurrection already cast keeps it away. Shared with the other
    Buff Duty files through ns.BuffDuty.
]]

local BuffDuty = ns.BuffDuty

--[[
    A dead player's resurrection sits in a column of its own, ahead of every
    buff's (which count from 1), so it always lines up on the left.
]]
local RESURRECTION_COLUMN = 0

--[[
    How long a resurrection that went off -- yours or another healer's -- keeps
    its target's icon away: the minute the game gives them to accept it.
]]
local RESURRECT_PENDING_SECONDS = 60
local pendingResurrects = {} -- GUID -> GetTime() the offer runs out

--[[
    Called from Buff-Tracking-Combat-Log.lua on every SPELL_RESURRECT, which
    fires as the cast lands, before the dead player accepts, and on Forever,
    which has no combat log, from your own resurrection going off
    (ns.OnResurrectCastSucceeded, in Buff-Duty-Cast-Results.lua). Without it
    the icon would stay up through that minute and invite a second healer to
    spend ten seconds on a resurrection already waiting.
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

--[[
    A dead player you can bring back: not you, still connected, and lying
    there -- a released ghost has no corpse here to cast on. One with a
    resurrection already being cast, or one waiting to accept, needs no second.
]]
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

--[[
    The icon that resurrects `unit`, cast at `castUnit`, or nil when you have
    no resurrection or they can't take one. Cast by its bare name, which
    resolves to the highest rank you know; castIds lets the Buff Key match
    the cast whichever rank that is.
]]
function BuffDuty.ResurrectionIcon(unit, castUnit, targetName)
	local resurrection = BuffDuty.resurrection
	if not resurrection or not CanResurrect(unit) then
		return nil
	end
	return {
		spellId = resurrection.id,
		column = RESURRECTION_COLUMN,
		spellName = resurrection.name,
		castSpell = resurrection.name,
		castIds = resurrection.ids,
		unit = castUnit,
		targetName = targetName,
		isResurrection = true,
	}
end
