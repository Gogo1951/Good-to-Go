local _, ns = ...

local BuffDuty = ns.BuffDuty

--------------------------------------------------------------------------------
-- More Powerful Spell
--------------------------------------------------------------------------------

-- The "more powerful spell" refusal comes back from the server, a moment after the cast.
local BOUNCE_WINDOW = 2
local lastAttempt -- { guid, unit, key, at }: the last buff cast the window or key made
-- The error type this client gives the refusal, learned from its text, for Diagnostics.
local bounceErrorType

-- Forever forbids the combat log, so your own resurrection going off stands in for SPELL_RESURRECT.
local RESURRECT_CAST_SECONDS = 15 -- a resurrection's cast time, with room for lag
local lastResurrect -- { guid, ids, expires }: the last resurrection the window or key cast, on Forever

function ns.OnResurrectCastSucceeded(unit, spellID)
	if not lastResurrect or not ns.IsPlain(unit) or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	if GetTime() > lastResurrect.expires then
		lastResurrect = nil
	elseif lastResurrect.ids[spellID] then
		BuffDuty.NoteResurrect(lastResurrect.guid)
		lastResurrect = nil
	end
end

function ns.NoteBuffCastAttempt(spec)
	lastAttempt = nil
	if ns.FLAVOR == "Camelot" and spec and spec.isResurrection and spec.unit then
		local guid = UnitGUID(spec.unit)
		if ns.IsPlain(guid) and guid then
			local ids = {}
			for _, id in ipairs(spec.castIds or { spec.spellId }) do
				ids[id] = true
			end
			lastResurrect = { guid = guid, ids = ids, expires = GetTime() + RESURRECT_CAST_SECONDS }
		end
	end
	if not spec or not spec.buffKey then
		return
	end
	local guid = spec.favorGUID or (spec.unit and UnitGUID(spec.unit))
	if ns.IsPlain(guid) and guid then
		-- Anything not a player is followed through: its buffs reach the client less reliably than a player's.
		local isPet, isNPC = false, false
		if spec.unit and not spec.isGroup and not spec.favorGUID then
			local isPlayer = UnitIsPlayer(spec.unit)
			isPet = ns.IsPlain(isPlayer) and not isPlayer
			-- A friendly NPC is buffed in a cycle (BuffDuty.NoteNPCCast), not held off like a pet.
			if isPet then
				local controlled = UnitPlayerControlled(spec.unit)
				isNPC = ns.IsPlain(controlled) and not controlled
			end
		end
		local ids = {}
		for _, id in ipairs(spec.castIds or { spec.spellId }) do
			ids[id] = true
		end
		lastAttempt = {
			guid = guid,
			unit = spec.unit,
			key = spec.buffKey,
			ids = ids,
			isPet = isPet,
			isNPC = isNPC,
			at = GetTime(),
		}
	end
end

-- A cast at a pet is taken at its word, whether or not its aura ever shows.
function ns.OnBuffCastSucceeded(unit, spellID)
	local attempt = lastAttempt
	if not attempt or not attempt.isPet or not ns.IsPlain(unit) or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	if GetTime() - attempt.at > BOUNCE_WINDOW then
		return
	end
	if attempt.ids[spellID] then
		lastAttempt = nil
		if attempt.isNPC then
			BuffDuty.NoteNPCCast(attempt.guid, attempt.key)
		else
			BuffDuty.NotePetCast(attempt.guid, attempt.key)
		end
		ns.RequestBuffDutyRefresh()
	end
end

--[[
    The client's own strings, so they match in every locale. Only these mark a
    pet as refused: range, line of sight, mana and cooldowns are worth another
    click.
]]
local PET_REFUSALS = {}
for _, message in ipairs({
	SPELL_FAILED_BAD_TARGETS,
	SPELL_FAILED_BAD_IMPLICIT_TARGETS,
	SPELL_FAILED_TARGET_NOT_IN_PARTY,
	SPELL_FAILED_TARGET_NOT_IN_RAID,
	SPELL_FAILED_TARGET_IS_PLAYER_CONTROLLED,
}) do
	if type(message) == "string" then
		PET_REFUSALS[message] = true
	end
end

function ns.IsBuffBounceError(errorType)
	return bounceErrorType ~= nil and errorType == bounceErrorType
end

-- The refusal names no target, so it is pinned on the last cast; a favor's unit is found by GUID.
local function OnUIErrorMessage(errorType, message)
	if not lastAttempt or not ns.IsPlain(message) then
		return
	end
	if lastAttempt.isPet and PET_REFUSALS[message] then
		local attempt = lastAttempt
		lastAttempt = nil
		if GetTime() - attempt.at <= BOUNCE_WINDOW then
			BuffDuty.NotePetRefused(attempt.guid, attempt.key)
			ns.RequestBuffDutyRefresh()
		end
		return
	end
	if message ~= SPELL_FAILED_AURA_BOUNCED then
		return
	end
	if ns.IsPlain(errorType) and errorType ~= bounceErrorType then
		-- The event log counted this firing before the type was known; log it in full.
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEventNow("UI_ERROR_MESSAGE", errorType, message)
		end
		bounceErrorType = errorType
	end
	local attempt = lastAttempt
	lastAttempt = nil
	if GetTime() - attempt.at > BOUNCE_WINDOW then
		return
	end
	--[[
	    A GUID can come back secret on its own, one unit at a time, and
	    comparing a secret value errors, so each is checked before comparing.
	]]
	if ns.AreAurasSecret() then
		return
	end
	local unit = attempt.unit
	local guid = unit and UnitGUID(unit)
	if not (ns.IsPlain(guid) and guid == attempt.guid) then
		unit = ns.GetUnitByGUID(attempt.guid)
	end
	if unit then
		BuffDuty.NoteBounce(unit, attempt.key)
		ns.RequestBuffDutyRefresh()
	end
end

ns.SetBuffDutyEventHandler("UI_ERROR_MESSAGE", OnUIErrorMessage)
