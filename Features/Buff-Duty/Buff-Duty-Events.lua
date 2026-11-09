local _, ns = ...
local Data = ns.Data

--[[
    Buff-Duty-Events -- Buff Duty's own module in Core's dispatcher. Each Buff
    Duty file attaches its handler with ns.SetBuffDutyEventHandler; attaching
    the same event twice replaces the earlier handler -- one owner per event.
]]

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

--[[
    On while Buff Duty is on for your class. UNIT_AURA is unfiltered, since the
    window reads the whole group; UNIT_SPELLCAST_SUCCEEDED, the player's only,
    carries the Buff Key's casts and the resurrects; the combat log, never on Forever, says
    when anyone's resurrect lands and which strangers buff you (Return the
    Favor), which Forever reads off your own UNIT_AURA instead.
]]
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
}

-- Forever has no combat log, and registering COMBAT_LOG_EVENT_UNFILTERED there errors.
if ns.FLAVOR ~= "Camelot" then
	table.insert(WINDOW_EVENTS, "COMBAT_LOG_EVENT_UNFILTERED")
end

local EVENT_UNITS = {
	UNIT_INVENTORY_CHANGED = { "player" },
	UNIT_SPELLCAST_SUCCEEDED = { "player" },
}

--[[
    On regardless: login setup, a loading screen's In Instance refresh, and
    combat starting and ending, since a change made to the window in combat,
    switching it off included, waits for combat to end.
]]
for _, event in ipairs({
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
}) do
	ns.SetModuleEvent(MODULE, event, true)
end

--[[
    Login and every loading screen replay the auras already on you as if they
    had just landed, so Return the Favor and the resurrect waits ignore the
    combat log for a moment after each. A token voids earlier timers, so only
    the latest loading screen's pause can end it.
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

-- Subscribes the window's events while Buff Duty is on for your class and releases them while it is off.
function ns.UpdateBuffDutyEvents()
	if not (ns.db and ns.db.global) then
		return
	end
	local on = ns.IsBuffDutyOnForClass()
	for _, event in ipairs(WINDOW_EVENTS) do
		ns.SetModuleEvent(MODULE, event, on, unpack(EVENT_UNITS[event] or {}))
	end
	ns.SetBuffDutyWatching(on)
end

-- The player's own casts: the Buff Key hears its casts go off, and the resurrect waits hear theirs.
local function OnUnitSpellcastSucceeded(unitTarget, _, spellID)
	ns.OnBuffKeyCastSucceeded(unitTarget, spellID)
	ns.OnResurrectCastSucceeded(unitTarget, spellID)
	ns.OnBuffCastSucceeded(unitTarget, spellID)
end
ns.SetBuffDutyEventHandler("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)

local function OnUnitAura(unit, updateInfo)
	ns.OnBuffDutyUnitAura(unit)
	if ns.FLAVOR == "Camelot" and isReady and unit == "player" then
		ns.NoteFavorFromAuras(updateInfo)
	end
end
ns.SetBuffDutyEventHandler("UNIT_AURA", OnUnitAura)

--[[
    A dead player's resurrect icon hides while anyone's offer waits on them,
    and a stranger's buff on you lists them under Return the Favor.
]]
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
