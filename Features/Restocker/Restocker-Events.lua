local _, ns = ...

-- Handlers take the event's own arguments, no event name. Item answers come through Features/Item-Info.lua.
ns.restockerEventHandlers = {}

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

-- Repaints only while the window is shown: it redraws itself on the way back in.
function ns.OnRestockerBagUpdateDelayed()
	ns.SettleMerchantBuys()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		ns.RefreshRestockShortfall()
	end
end

--------------------------------------------------------------------------------
-- Level
--------------------------------------------------------------------------------

-- The level is passed on: UnitLevel still returns the previous one during this event.
function ns.OnRestockerLevelUp(newLevel)
	ns.UpgradeRestockList(newLevel)
end

--------------------------------------------------------------------------------
-- Entering The World
--------------------------------------------------------------------------------

-- The one PLAYER_ENTERING_WORLD handler: the arrival check, the Starter List pop-up and the upgrade catch-up.
function ns.OnRestockerEnteringWorld(isInitialLogin, isReloadingUi)
	-- MIGRATION (remove after 2026-12-13): Restocker-Town-Reminder.lua is new, so absent after a /reload until a restart.
	if ns.OnRestockerArrival then
		ns.OnRestockerArrival(isInitialLogin, isReloadingUi)
	end
	ns.OnStarterListEnteringWorld(isInitialLogin, isReloadingUi)

	--[[
	    Catch-up: levels gained with the add-on off, or a list copied from a
	    higher character, would otherwise strand an entry, since nothing else
	    re-checks.
	]]
	ns.UpgradeRestockList()
end

--------------------------------------------------------------------------------
-- Handlers
--------------------------------------------------------------------------------

local function WhileEnabled(handler)
	return function(...)
		if ns.IsRestockerEnabled() then
			return handler(...)
		end
	end
end

--[[
    One handler per event: a second use calls from the existing handler, as
    ns.OnRestockerEnteringWorld does. Only logout runs while the Restocker is
    off, since it still packs the lists.

    MIGRATION (remove after 2026-12-13): the in-town handlers are
    Restocker-Town-Reminder.lua's, new this release, so a /reload after an
    update with the game running has none of them until a restart, and their
    events go unhandled until then.
]]
function ns.InitializeRestockerEvents()
	ns.restockerEventHandlers = {
		MERCHANT_SHOW = WhileEnabled(ns.OnRestockerMerchantShow),
		MERCHANT_CLOSED = WhileEnabled(ns.OnRestockerMerchantClosed),
		BANKFRAME_OPENED = WhileEnabled(ns.OnRestockerBankFrameOpened),
		BANKFRAME_CLOSED = WhileEnabled(ns.OnRestockerBankFrameClosed),
		BAG_UPDATE_DELAYED = WhileEnabled(ns.OnRestockerBagUpdateDelayed),
		PLAYER_LOGOUT = ns.OnRestockerLogout,
		PLAYER_UPDATE_RESTING = ns.OnRestockerUpdateResting and WhileEnabled(ns.OnRestockerUpdateResting),
		PLAYER_CONTROL_GAINED = ns.OnRestockerControlGained and WhileEnabled(ns.OnRestockerControlGained),
		PLAYER_LEVEL_UP = WhileEnabled(ns.OnRestockerLevelUp),
		PLAYER_ENTERING_WORLD = WhileEnabled(ns.OnRestockerEnteringWorld),
	}
	ns.SyncRestockItemInfoSubscription()
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

local MODULE = "Restocker"

-- The Restocker's and the Inventory Report's; PLAYER_REGEN_ENABLED is the report's alone.
local EVENTS = {
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"BANKFRAME_OPENED",
	"MERCHANT_CLOSED",
	"MERCHANT_SHOW",
	"PLAYER_CONTROL_GAINED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_LOGOUT",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_UPDATE_RESTING",
}

-- No combat guard: nothing here touches a protected function, and a mid-combat logout must still pack.
ns.RegisterEventModule(MODULE, function(event, ...)
	if event == "PLAYER_LOGIN" then
		ns.InitializeRestocker()
		--[[
		    After the Restocker, whose settings the report reads for a list
		    item's Keep amount. MIGRATION (remove after 2026-12-08): tested
		    for, since the client reads a TOC's file list only at startup, so a
		    player who updates with the game running and reloads gets this file
		    without Inventory-Report-Recording.lua until the next restart. The
		    report just stays off until then.
		]]
		if ns.InitializeInventoryReport then
			ns.InitializeInventoryReport()
		end
		ns.SyncRestockerEvents()
		return
	end

	local handler = ns.restockerEventHandlers[event]
	if handler then
		handler(...)
	end

	-- ns.db is nil at logout when login setup errored first, so that logout leaves the file alone.
	local inventoryHandler = ns.inventoryEventHandlers and ns.inventoryEventHandlers[event]
	if inventoryHandler and ns.db and ns.db.global.inventoryReport then
		inventoryHandler(...)
	end
end)

local ALWAYS_EVENTS = { PLAYER_LOGIN = true, PLAYER_LOGOUT = true }

-- So neither feature reads the bags while it is off.
function ns.SyncRestockerEvents()
	local restocker = ns.IsRestockerEnabled() and ns.restockerEventHandlers
	local report = ns.db and ns.db.global.inventoryReport and ns.inventoryEventHandlers
	for _, event in ipairs(EVENTS) do
		local wanted = ALWAYS_EVENTS[event]
			or (restocker and restocker[event] ~= nil)
			or (report and report[event] ~= nil)
		ns.SetModuleEvent(MODULE, event, wanted and true or false)
	end
end

for event in pairs(ALWAYS_EVENTS) do
	ns.SetModuleEvent(MODULE, event, true)
end
