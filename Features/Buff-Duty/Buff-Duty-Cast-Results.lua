local _, ns = ...

-- What became of the casts the Buff Duty window and its key make: a buff refused for a stronger one, and resurrections.

local BuffDuty = ns.BuffDuty

--------------------------------------------------------------------------------
-- More Powerful Spell
--------------------------------------------------------------------------------

--[[
    How long after a click or Buff Key press a "more powerful spell" refusal
    still belongs to that cast; the error comes back from the server.
]]
local BOUNCE_WINDOW = 2
local lastAttempt -- { guid, unit, key, at }: the last buff cast the window or key made
-- The error type this client gives the refusal, learned from its text, for Diagnostics.
local bounceErrorType

--[[
    Forever has no combat log, so its SPELL_RESURRECT never arrives to keep a
    resurrected player's icon away while they decide to accept
    (BuffDuty.NoteResurrect). There, a resurrection the window or key cast is
    noted from the player's own cast going off instead.
]]
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

-- Called from a window icon's PreClick and the Buff Key's, for every cast they make.
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
		--[[
		    A pet (anything not a player: a party pet's token, or a targeted
		    one) has its cast followed through below, since its buffs reach
		    the client less reliably than a player's.
		]]
		local isPet = false
		if spec.unit and not spec.isGroup and not spec.favorGUID then
			local isPlayer = UnitIsPlayer(spec.unit)
			isPet = ns.IsPlain(isPlayer) and not isPlayer
		end
		local ids = {}
		for _, id in ipairs(spec.castIds or { spec.spellId }) do
			ids[id] = true
		end
		lastAttempt = { guid = guid, unit = spec.unit, key = spec.buffKey, ids = ids, isPet = isPet, at = GetTime() }
	end
end

--[[
    The player's cast going off. One the window or key just aimed at a pet is
    taken at its word (BuffDuty.NotePetCast): the pet isn't offered that buff
    again until it would need a refresh, whether or not its aura ever shows.
]]
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
		BuffDuty.NotePetCast(attempt.guid, attempt.key)
		ns.RequestBuffDutyRefresh()
	end
end

--[[
    The client's own words for a target the spell can never land on, so they
    match in every locale. Only these mark a pet as refused: range, line of
    sight, mana and cooldowns pass and are worth another click.
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

-- Diagnostics' event-log filter asks whether an error type is the one this file acts on.
function ns.IsBuffBounceError(errorType)
	return bounceErrorType ~= nil and errorType == bounceErrorType
end

--[[
    The refusal names no target, so it is pinned on the cast the window or
    the Buff Key just made. A favor's macro leaves them targeted, so a unit
    is found for them by GUID. The text is the client's own
    SPELL_FAILED_AURA_BOUNCED, so it matches in every locale.
]]
local function OnUIErrorMessage(errorType, message)
	if not lastAttempt or not ns.IsPlain(message) then
		return
	end
	--[[
	    A pet the game won't take the buff on at all: it isn't offered that
	    buff again while it stays around (BuffDuty.NotePetRefused).
	]]
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
	    While Forever keeps auras secret the window is hidden, so there is no
	    list to note the bounce on. A unit's GUID can come back secret on its
	    own, one unit at a time, and comparing a secret value errors, so each
	    GUID read is checked before it is compared.
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
