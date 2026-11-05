local _, ns = ...

--[[
    Buff-Duty-Events -- Buff Duty's own module in Core's dispatcher, apart
    from Automated Appreciation's, so turning either feature off, or editing
    one, never takes the other's events. Each Buff Duty file attaches its
    handler with ns.SetBuffDutyEventHandler; attaching the same event twice
    replaces the earlier handler -- one owner per event.
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
    window reads the whole group; UNIT_SPELLCAST_SUCCEEDED carries the Buff
    Key's casts and the resurrects; the combat log, never on Forever, says
    when anyone's resurrect lands.
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
}

--[[
    On regardless: login setup, a loading screen's In Instance refresh, item
    names arriving for the Weapon Buffs panel, and combat starting and ending,
    since a change made to the window in combat, switching it off included,
    waits for combat to end.
]]
for _, event in ipairs({
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"GET_ITEM_INFO_RECEIVED",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
}) do
	ns.SetModuleEvent(MODULE, event, true)
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

-- The Buff Key hears its own casts go off, and the resurrect waits hear theirs.
ns.SetBuffDutyEventHandler("UNIT_SPELLCAST_SUCCEEDED", function(unitTarget, _, spellID)
	ns.OnBuffKeyCastSucceeded(unitTarget, spellID)
	ns.OnResurrectCastSucceeded(unitTarget, spellID)
end)

ns.SetBuffDutyEventHandler("UNIT_AURA", function(unit)
	ns.OnBuffDutyAura(unit)
end)

-- A dead player's resurrect icon hides while anyone's offer waits on them.
ns.SetBuffDutyEventHandler("COMBAT_LOG_EVENT_UNFILTERED", function()
	if not ns.IsBuffTrackingReady() then
		return
	end
	local _, subEvent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
	if subEvent == "SPELL_RESURRECT" then
		ns.BuffDuty.NoteResurrect(destGUID)
	end
end)

ns.SetBuffDutyEventHandler("GET_ITEM_INFO_RECEIVED", function(itemId)
	ns.OnBuffDutyItemInfo(itemId)
end)

ns.SetBuffDutyEventHandler("PLAYER_LOGIN", function()
	ns.SetupBuffDuty()
end)

-- In Instance: every way into or out of one is a loading screen.
ns.SetBuffDutyEventHandler("PLAYER_ENTERING_WORLD", function()
	if ns.db then
		ns.RequestBuffDutyRefresh()
	end
end)
