local _, ns = ...
local Data = ns.Data

-- One handler per event: attaching the same event twice replaces the earlier handler.

local MODULE = "BuffDuty"
local eventHandlers = {}

function ns.SetBuffDutyEventHandler(event, handler)
	eventHandlers[event] = handler
end

ns.RegisterEventModule(MODULE, function(event, ...)
	local handler = eventHandlers[event]
	if handler then
		handler(...)
	end
end)

-- On while Buff Duty tracks your class. UNIT_AURA is unfiltered, since the window reads the whole group.
local WINDOW_EVENTS = {
	"GROUP_ROSTER_UPDATE",
	"UNIT_PET",
	"PLAYER_TARGET_CHANGED",
	"SPELLS_CHANGED",
	"UNIT_INVENTORY_CHANGED",
	"BAG_UPDATE_DELAYED",
	"SPELL_UPDATE_COOLDOWN",
	"REPLACE_ENCHANT",
	"UI_ERROR_MESSAGE",
	"UNIT_AURA",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_POWER_UPDATE",
	"UNIT_FLAGS",
}

-- Forever has a combat log, but registering COMBAT_LOG_EVENT_UNFILTERED there raises ADDON_ACTION_FORBIDDEN.
local READS_COMBAT_LOG = ns.FLAVOR ~= "Camelot"

local EVENT_UNITS = {
	UNIT_INVENTORY_CHANGED = { "player" },
	UNIT_SPELLCAST_SUCCEEDED = { "player" },
	UNIT_POWER_UPDATE = { "player" },
}

-- Always on: a change made to the window in combat, switching it off included, waits for combat to end.
for _, event in ipairs({
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
}) do
	ns.SetModuleEvent(MODULE, event, true)
end

--[[
    Login and every loading screen replay the auras already on you as new, so
    Return the Favor and the resurrect waits pause after each. A token voids
    earlier timers, so only the latest pause can end it.
]]
local isReady = false
local safetyToken = 0

local function StartSafetyPause()
	isReady = false
	safetyToken = safetyToken + 1
	local token = safetyToken
	C_Timer.After(Data.SAFETY_PAUSE, function()
		if token == safetyToken then
			isReady = true
		end
	end)
end

function ns.IsBuffDutyReady()
	return isReady
end

--[[
    The combat log runs a line for every hit in a raid, so it is heard only
    while Return the Favor is on or you know a resurrection. A new consumer
    must widen this.
]]
local function SyncCombatLog(on)
	if not READS_COMBAT_LOG then
		return
	end
	local wanted = on and (ns.db.global.buffWindow.favorEnabled or ns.BuffDuty.resurrection ~= nil)
	ns.SetModuleEvent(MODULE, "COMBAT_LOG_EVENT_UNFILTERED", wanted and true or false)
end

function ns.SyncBuffDutyCombatLog()
	if ns.db and ns.db.global then
		SyncCombatLog(ns.IsBuffDutyTrackingForClass())
	end
end

-- So turning the events on can catch up on the group you're in.
local windowEventsOn = false

-- A closed window keeps its events, so the Buff Key still reads fresh auras.
function ns.UpdateBuffDutyEvents()
	if not (ns.db and ns.db.global) then
		return
	end
	local on = ns.IsBuffDutyTrackingForClass()
	for _, event in ipairs(WINDOW_EVENTS) do
		local wanted = on
		-- Rage is only read for a warrior's Bloodrage (Buff-Duty-Rage.lua); anyone else's mana ticks are left unheard.
		if event == "UNIT_POWER_UPDATE" then
			wanted = on and select(2, UnitClass("player")) == "WARRIOR"
		end
		ns.SetModuleEvent(MODULE, event, wanted, unpack(EVENT_UNITS[event] or {}))
	end
	SyncCombatLog(on)
	ns.SetBuffDutyWatching(on)
	if on and not windowEventsOn then
		ns.NoteBuffDutyGroup(true)
	end
	windowEventsOn = on
end

local function OnUnitSpellcastSucceeded(unitTarget, _, spellID)
	ns.OnBuffKeyCastSucceeded(unitTarget, spellID)
	ns.OnResurrectCastSucceeded(unitTarget, spellID)
	ns.OnBuffCastSucceeded(unitTarget, spellID)
end
ns.SetBuffDutyEventHandler("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)

local function OnUnitPowerUpdate(_, powerType)
	if powerType == "RAGE" then
		ns.BuffDuty.CheckRageFirst()
	end
end
ns.SetBuffDutyEventHandler("UNIT_POWER_UPDATE", OnUnitPowerUpdate)

--[[
    UNIT_FLAGS fires for every flag, combat's included, and for nameplates,
    so only a change to a watched unit's PvP flag redraws.
]]
local pvpFlags = {}

local function WatchesFlagsOf(unit)
	return unit == "player" or unit == "target" or unit:find("^party%d") or unit:find("^raid%d")
end

local function OnUnitFlags(unit)
	if not ns.IsPlain(unit) or not unit or not WatchesFlagsOf(unit) then
		return
	end
	local flagged = UnitIsPVP(unit)
	if not ns.IsPlain(flagged) then
		return
	end
	flagged = flagged and true or false
	if pvpFlags[unit] ~= flagged then
		pvpFlags[unit] = flagged
		ns.RequestBuffDutyRefresh()
	end
end
ns.SetBuffDutyEventHandler("UNIT_FLAGS", OnUnitFlags)

local function OnUnitAura(unit, updateInfo)
	ns.OnBuffDutyUnitAura(unit)
	if ns.FLAVOR == "Camelot" and isReady and unit == "player" then
		ns.NoteFavorFromAuras(updateInfo)
	end
end
ns.SetBuffDutyEventHandler("UNIT_AURA", OnUnitAura)

local function OnCombatLogEventUnfiltered()
	if not isReady then
		return
	end
	local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, _, _, _, auraType =
		CombatLogGetCurrentEventInfo()
	if subEvent == "SPELL_RESURRECT" then
		ns.BuffDuty.NoteResurrect(destGUID)
	elseif subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
		ns.NoteFavorFromCombatLog(sourceGUID, sourceName, sourceFlags, destGUID, auraType)
	end
end
ns.SetBuffDutyEventHandler("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered)

local function OnPlayerLogin()
	ns.SetupBuffDuty()
end
ns.SetBuffDutyEventHandler("PLAYER_LOGIN", OnPlayerLogin)

-- In Instance: every way into or out of one is a loading screen.
local function OnPlayerEnteringWorld()
	StartSafetyPause()
	if ns.db then
		ns.RequestBuffDutyRefresh()
	end
end
ns.SetBuffDutyEventHandler("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
