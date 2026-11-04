local _, ns = ...
local Data = ns.Data

local GetCastEntry = ns.GetCastEntry
local HandleTracked = ns.HandleTracked
local IsOnCooldown = ns.IsOnCooldown
local SetCooldown = ns.SetCooldown

--[[
    The buff-reaction engine's event side. Buffs on you are read from the
    combat log in Buff-Tracking-Combat-Log.lua (Classic Era and TBC) or from
    UNIT_AURA in Buff-Tracking-Forever.lua (WoW Forever, which has no combat
    log); each TOC loads only its own. This file watches
    UNIT_SPELLCAST_SUCCEEDED, classifies the source against the lookups in
    Features/Automated-Appreciation/Tracked-Lookups.lua, and hands what
    qualifies to Features/Automated-Appreciation/Praise.lua. Owns the readiness
    timer the others and Good News read; its event handlers attach through
    Core's dispatcher (ns.SetEventHandler), and the events themselves are
    declared in Core's ns.EVENT_NAMES.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local isReady = false
local playerGUID -- cached at login; a character's GUID never changes within a session

--------------------------------------------------------------------------------
-- Safety Timer
--------------------------------------------------------------------------------

--[[
    Suppresses buff reactions until the world settles after login or a loading screen.
    A token invalidates earlier timers: back-to-back loading screens each arm a new
    pause, and only the most recent callback may restore readiness, so a stale timer
    can't flip isReady back on mid-pause.
]]
local safetyToken = 0
local function StartSafetyTimer(duration)
	isReady = false
	safetyToken = safetyToken + 1
	local token = safetyToken
	C_Timer.After(duration or Data.SAFETY_PAUSE, function()
		if token == safetyToken then
			isReady = true
		end
	end)
end

--------------------------------------------------------------------------------
-- Source Resolution
--------------------------------------------------------------------------------

--[[
    A buff's combat-log source can be a pet or guardian (a hunter's Roar of
    Sacrifice, for example). Credit the owner so the message names the player,
    not the pet — owners are found by matching the pet's GUID to a group pet unit.
]]
local function GetPetOwnerUnit(petGUID)
	if UnitGUID("pet") == petGUID then
		return "player"
	end
	for i = 1, 4 do
		if UnitGUID("partypet" .. i) == petGUID then
			return "party" .. i
		end
	end
	for i = 1, 40 do
		if UnitGUID("raidpet" .. i) == petGUID then
			return "raid" .. i
		end
	end
	return nil
end

ns.GetPetOwnerUnit = GetPetOwnerUnit

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--[[
    Group services are announced from UNIT_SPELLCAST_SUCCEEDED, not the combat log:
    portals, summons, feasts and the like are utility casts that don't reliably
    produce a SPELL_CAST_SUCCESS in COMBAT_LOG_EVENT_UNFILTERED, but they DO fire
    this unit event for any unit the client tracks (party/raid, target, focus). A
    service has no per-you target, so crediting the casting unit is all we need --
    which is also why solo casts (Rebirth, Lay on Hands) stay on the combat log,
    where the destination tells us the buff actually landed on you.

    That same breadth is why the caster is filtered to your party or raid below:
    the event's reach is much wider than the feature's, and a service cast by
    someone you merely have targeted was never meant to announce.

    The per-source "service:" cooldown does double duty: it rate-limits a mage
    opening several portals in a row, and it dedupes the multiple tokens a single
    cast can fire (party1 and target for the same caster resolve to one GUID, so the
    second is already on cooldown).
]]
local function OnUnitSpellcastSucceeded(unitTarget, castGUID, spellID)
	-- The Buff Key hears its own casts go off, whether or not tracking is ready.
	if ns.OnBuffKeyCastSucceeded then
		ns.OnBuffKeyCastSucceeded(unitTarget, spellID)
	end
	if ns.OnResurrectCastSucceeded then
		ns.OnResurrectCastSucceeded(unitTarget, spellID)
	end

	if not isReady or not ns.db then
		return
	end

	-- Other players' casts on nameplates and the like arrive with secret ids that can't key a table.
	if not (ns.IsPlain(spellID) and ns.IsPlain(castGUID) and ns.IsPlain(unitTarget)) then
		return
	end

	--[[
	    Good News: a cast of yours that SENT already vetted and named the
	    recipient. Claimed before the service check below, which is about OTHER
	    people's casts.
	]]
	if castGUID then
		ns.ClaimPendingGiven(castGUID)
	end

	local entry = GetCastEntry(spellID)
	if not entry or entry.type ~= Data.BUFF.SERVICE then
		return
	end

	--[[
	    Group members only, never ourselves. The event fires for every unit the
	    client tracks, so without the group test a stranger opening a portal
	    across a capital city reads as a service to us -- and a group service is
	    the whole promise of the Service Alerts panel. Being in the group implies a friendly
	    player; UnitIsPlayer drops group pets, which the group calls don't
	    distinguish. A battleground IS a raid, so it needs no
	    case of its own. A caster whose identity is secret can't be credited.
	]]
	if ns.IsUnitIdentitySecret(unitTarget) then
		return
	end
	if not UnitIsPlayer(unitTarget) then
		return
	end
	if not (UnitInParty(unitTarget) or UnitInRaid(unitTarget)) then
		return
	end
	local creditGUID = UnitGUID(unitTarget)
	if not creditGUID or not ns.IsPlain(creditGUID) or creditGUID == playerGUID then
		return
	end
	local creditName = GetUnitName(unitTarget, true)
	if not creditName or not ns.IsPlain(creditName) then
		return
	end

	local cooldownKey = "service:" .. creditGUID
	if not IsOnCooldown(cooldownKey) then
		HandleTracked(entry, spellID, creditGUID, creditName, nil)
		SetCooldown(cooldownKey)
	end
end

--[[
    UNIT_AURA is subscribed for every unit while Buff Duty is on for your class,
    because it reads the whole group, and otherwise on Forever for you alone
    (ns.UpdateThanksForTheBuffEvents); this handler owns the event and hands it
    on to Buff Duty first. The rest is Forever's buff detection
    (ns.OnForeverPlayerAura), which only ever cares about auras on you.
]]
local function OnUnitAura(unit, updateInfo)
	if ns.OnBuffWindowAura then
		ns.OnBuffWindowAura(unit)
	end
	if not ns.OnForeverPlayerAura or not ns.IsPlain(unit) or unit ~= "player" then
		return
	end
	ns.OnForeverPlayerAura(updateInfo)
end

local function OnLoadingScreenDisabled()
	StartSafetyTimer(Data.SAFETY_PAUSE)
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

-- Good News and Praise read these.
function ns.IsBuffTrackingReady()
	return isReady
end

function ns.GetPlayerGUID()
	return playerGUID
end

--[[
    Run once from Core's login sequence, after the saved variables are live and
    the spell/item APIs return real data. Builds the lookups and display groups,
    seeds the watched list, warms the item cache, and arms the safety timer.
]]
function ns.SetupBuffTracking()
	playerGUID = UnitGUID("player")
	ns.BuildTrackedData()
	StartSafetyTimer(Data.SAFETY_PAUSE)
end

ns.SetEventHandler("UNIT_AURA", OnUnitAura)
ns.SetEventHandler("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)
ns.SetEventHandler("LOADING_SCREEN_DISABLED", OnLoadingScreenDisabled)
