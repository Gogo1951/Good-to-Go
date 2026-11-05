local _, ns = ...

--------------------------------------------------------------------------------
-- Profile Changes
--------------------------------------------------------------------------------

--[[
    Automated Appreciation's settings are account-wide, so a profile switch, copy
    or reset leaves them as they were; this re-seeds the watched-buff lists and
    brings Buff Duty and the Thank You macros in line anyway, so a Reset
    never leaves them reading a stale table.
    Features/Core.lua calls this and then redraws every open panel.
]]
function ns.ApplyAutomatedAppreciationProfile()
	ns.UpdateAutomatedAppreciationEvents()
	if ns.PopulateWatchedBuffs then
		ns.PopulateWatchedBuffs()
	end
	if ns.PopulateBuffDutyAudience then
		ns.PopulateBuffDutyAudience()
		ns.RefreshBuffDuty()
	end
	if ns.ReconcileMacros then
		ns.ReconcileMacros()
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
    The on/off field of each Automated Appreciation feature. Its options toggles,
    caption and tooltip included, are built with every other feature's in
    Options/Options-Utilities.lua (ns.OptionsFeatureSwitch); this table is what
    the feature code needs to read and flip them.
]]
ns.FEATURE_SWITCHES = {
	--[[
	    key: the account-wide subtable, setting: its on/off field,
	    onChange: present only for a feature that must react the moment it flips.
	]]
	{ key = "strangers", setting = "enabled" },
	{ key = "teammates", setting = "enabled" },
	{ key = "goodNews", setting = "whisperEnabled" },
	{ key = "services", setting = "enabled" },
	{
		key = "buffWindow",
		setting = "enabled",
		onChange = function()
			ns.RefreshBuffDuty()
		end,
	},
}

local function NotifyAllPanels()
	local registry = LibStub("AceConfigRegistry-3.0")
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		registry:NotifyChange(name)
	end
end

function ns.GetFeatureSwitch(key)
	for _, feature in ipairs(ns.FEATURE_SWITCHES) do
		if feature.key == key then
			return feature
		end
	end
	return nil
end

function ns.IsFeatureOn(key)
	local feature = ns.GetFeatureSwitch(key)
	return ns.db.global[key][feature.setting] and true or false
end

--[[
    Flips a feature from anywhere -- either copy of its options toggle, the mini-map
    button, the Buff Duty window's close button -- so each one reacts and every
    open panel repaints the same way.
]]
function ns.SetFeatureSwitch(key, value)
	local feature = ns.GetFeatureSwitch(key)
	ns.db.global[key][feature.setting] = value
	ns.UpdateAutomatedAppreciationEvents()
	if feature.onChange then
		feature.onChange()
	end
	NotifyAllPanels()
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

--[[
    Every event Automated Appreciation handles. Each feature file attaches its
    handler with ns.SetEventHandler; attaching the same event twice replaces
    the earlier handler -- one owner per event. Buff Duty has a module of its
    own (Features/Buff-Duty/Buff-Duty-Events.lua).
]]
local EVENTS = {
	"PLAYER_LOGIN",
	"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_SUCCEEDED",
	"LOADING_SCREEN_DISABLED",
	"UNIT_AURA",
	"GET_ITEM_INFO_RECEIVED",
}

-- Forever has no combat log, and registering COMBAT_LOG_EVENT_UNFILTERED there errors.
if ns.FLAVOR ~= "Camelot" then
	table.insert(EVENTS, "COMBAT_LOG_EVENT_UNFILTERED")
end

--[[
    Unit events Automated Appreciation only ever needs for these units. UNIT_AURA
    is set in ns.UpdateAutomatedAppreciationEvents instead: the player alone, for
    Forever's praise. Every other event subscribes unfiltered.
]]
local EVENT_UNITS = {
	UNIT_SPELLCAST_SENT = { "player", "pet" },
}

local MODULE = "AutomatedAppreciation"
local eventHandlers = {}

function ns.SetEventHandler(event, handler)
	eventHandlers[event] = handler
end

ns.RegisterEventModule(MODULE, function(event, ...)
	local handler = eventHandlers[event]
	if handler then
		handler(...)
	end
end)

--[[
    The firehoses, each subscribed only while a feature that reads it is on:

      COMBAT_LOG_EVENT_UNFILTERED  Stranger and Teammate praise, and Good
                                   News's resurrects. Never on Forever.
      UNIT_SPELLCAST_SENT          Good News, naming who a cast of yours is for.
      UNIT_SPELLCAST_SUCCEEDED     Good News and Service Alerts.
      UNIT_AURA                    On Forever, your own auras for Stranger and
                                   Teammate praise.
]]
local FEATURE_EVENTS = {
	COMBAT_LOG_EVENT_UNFILTERED = true,
	UNIT_SPELLCAST_SENT = true,
	UNIT_SPELLCAST_SUCCEEDED = true,
	UNIT_AURA = true,
}

for _, event in ipairs(EVENTS) do
	if not FEATURE_EVENTS[event] then
		ns.SetModuleEvent(MODULE, event, true, unpack(EVENT_UNITS[event] or {}))
	end
end

function ns.UpdateAutomatedAppreciationEvents()
	if not (ns.db and ns.db.global) then
		return
	end
	local IsOn = ns.IsFeatureOn
	local praise = IsOn("strangers") or IsOn("teammates")
	local goodNews, services = IsOn("goodNews"), IsOn("services")
	local wanted = {
		COMBAT_LOG_EVENT_UNFILTERED = praise or goodNews,
		UNIT_SPELLCAST_SENT = goodNews,
		UNIT_SPELLCAST_SUCCEEDED = goodNews or services,
	}
	-- EVENTS, not wanted: on Forever the combat log is never in the list.
	for _, event in ipairs(EVENTS) do
		if FEATURE_EVENTS[event] and event ~= "UNIT_AURA" then
			ns.SetModuleEvent(MODULE, event, wanted[event], unpack(EVENT_UNITS[event] or {}))
		end
	end
	ns.SetModuleEvent(MODULE, "UNIT_AURA", praise and ns.OnForeverPlayerAura ~= nil, "player")
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

--[[
    Login-time setup, once Features/Core.lua has opened the database and
    registered the panels, which draw the display groups on open and so need
    nothing from here. This handler calls each feature's setup hook, in order.
]]
ns.SetEventHandler("PLAYER_LOGIN", function()
	ns.UpdateAutomatedAppreciationEvents()
	if ns.SetupBuffTracking then
		ns.SetupBuffTracking()
	end
	if ns.CreateAutoMacro then
		ns:CreateAutoMacro()
	end
end)
