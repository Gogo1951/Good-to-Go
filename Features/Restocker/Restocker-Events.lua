local _, ns = ...

--[[
    Handlers keyed by event name, read by the Restocker's dispatcher at the end
    of this file. Each takes the event's own arguments with no leading
    event-name. Filled by ns.InitializeRestockerEvents. GET_ITEM_INFO_RECEIVED
    is the one exception: the item cache's owner hands it on in a fixed order
    (Features/Item-Info.lua).
]]
ns.restockerEventHandlers = {}

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

--[[
    The open window's yellow Keep marks and the orders counted under its list are
    read from the bags, so they follow the bags: a merchant or bank visit fills
    them with the window up, and the marks should clear as it does. A repaint of
    those two things only (ns.RefreshRestockShortfall), and none while the window
    is shut -- it redraws itself on the way back in. A merchant run waiting on
    its buys is checked first, window or not (ns.SettleMerchantBuys).
]]
function ns.OnRestockerBagUpdateDelayed()
	ns.SettleMerchantBuys()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		ns.RefreshRestockShortfall()
	end
end

--------------------------------------------------------------------------------
-- Level
--------------------------------------------------------------------------------

--[[
    A ding is the usual thing that moves a staple onto its next tier. The new
    level is handed on rather than read back off the player: UnitLevel("player")
    still returns the PREVIOUS level during this event (see
    ns.UpgradeRestockList), so reading it here makes the ding a no-op.

    Classic Era's ladders top out at level 60, so a Classic character sees this a
    handful of times and then never again: each flavor folder holds only the tiers
    its own client sells.
]]
function ns.OnRestockerLevelUp(newLevel)
	ns.UpgradeRestockList(newLevel)
end

--------------------------------------------------------------------------------
-- Entering The World
--------------------------------------------------------------------------------

-- The one PLAYER_ENTERING_WORLD handler: the arrival check, the Starter List pop-up and the upgrade catch-up.
function ns.OnRestockerEnteringWorld(isInitialLogin, isReloadingUi)
	ns.OnRestockerArrival(isInitialLogin, isReloadingUi)
	ns.OnStarterListEnteringWorld(isInitialLogin, isReloadingUi)

	--[[
	    Catch-up for a list that is behind the player's level. A ding is not the
	    only way that happens -- levels gained with the add-on disabled, a list
	    copied off a higher character, a ding that arrived while the list was
	    mid-load -- and without this, a single missed level-up would strand the
	    entry for good, since nothing else re-checks.

	    Safe here: ns.InflateSavedRestockItems has already turned the saved one-line entries back
	    into tables (it runs at PLAYER_LOGIN, ahead of this event), and the check
	    is silent and free once nothing is behind, so the zone-in case costs a walk
	    of the list. A cold item cache at login needs no special handling: the move
	    defers and rides GET_ITEM_INFO_RECEIVED like any other.
	]]
	ns.UpgradeRestockList()
end

--------------------------------------------------------------------------------
-- Handlers
--------------------------------------------------------------------------------

-- A handler that runs only while the Restocker is on.
local function WhileEnabled(handler)
	return function(...)
		if ns.IsRestockerEnabled() then
			return handler(...)
		end
	end
end

--[[
    This table holds ONE handler per event name, so anything else wanting an
    event already in it shares the existing entry rather than adding a second
    one. That is why the arrival check, the Starter List pop-up and the
    upgrade catch-up all hang off ns.OnRestockerEnteringWorld: each is called from
    inside that handler rather than registering a second one of its own.

    Every handler but one stops while the Restocker is off: the logout handler
    still packs the lists for the saved-variables file. Item answers reach the
    Restocker through Features/Item-Info.lua, not this table.
]]
function ns.InitializeRestockerEvents()
	ns.restockerEventHandlers = {
		MERCHANT_SHOW = WhileEnabled(ns.OnRestockerMerchantShow),
		MERCHANT_CLOSED = WhileEnabled(ns.OnRestockerMerchantClosed),
		BANKFRAME_OPENED = WhileEnabled(ns.OnRestockerBankFrameOpened),
		BANKFRAME_CLOSED = WhileEnabled(ns.OnRestockerBankFrameClosed),
		BAG_UPDATE_DELAYED = WhileEnabled(ns.OnRestockerBagUpdateDelayed),
		PLAYER_LOGOUT = ns.OnRestockerLogout,
		PLAYER_UPDATE_RESTING = WhileEnabled(ns.OnRestockerUpdateResting),
		PLAYER_CONTROL_GAINED = WhileEnabled(ns.OnRestockerControlGained),
		PLAYER_LEVEL_UP = WhileEnabled(ns.OnRestockerLevelUp),
		PLAYER_ENTERING_WORLD = WhileEnabled(ns.OnRestockerEnteringWorld),
	}
	ns.SyncRestockItemInfoSubscription()
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

local MODULE = "Restocker"

--[[
    Every event the Restocker and the Inventory Report handle. Login and logout
    are heard for as long as the add-on runs; the rest only while a feature
    that handles them is switched on (ns.SyncRestockerEvents).
]]
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

--[[
    The Restocker's dispatcher. Features/Core.lua hands it every event it
    subscribed to, after Core's own handling: by PLAYER_LOGIN the database
    exists. Nothing here touches a protected function -- a merchant or bank
    window cannot open in combat, and a logout mid-combat must still pack the
    Restock List and this character's bags for the saved-variables file -- so
    there is no combat guard.
]]
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

	--[[
	    The Inventory Report's recorders only read containers and write saved
	    variables. ns.db is nil at logout when PLAYER_LOGIN's setup errored
	    before the database opened, so that logout leaves the file alone.
	]]
	local inventoryHandler = ns.inventoryEventHandlers and ns.inventoryEventHandlers[event]
	if inventoryHandler and ns.db and ns.db.global.inventoryReport then
		inventoryHandler(...)
	end
end)

local ALWAYS_EVENTS = { PLAYER_LOGIN = true, PLAYER_LOGOUT = true }

--[[
    Subscribes each event while the Restocker or the Inventory Report handles
    it and is switched on, so neither reads the bags while it is off. Called at
    login, once both have built their handler tables, and by each switch.
]]
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
