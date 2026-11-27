local _, ns = ...
local L = ns.L

-- Read across files as the "a bank window is open" gate.
ns.bankIsOpen = false

--[[
    Steps with the remaining work unchanged (growth counts as change) before the
    run stops and reports. A few retries ride out "Couldn't split those items"
    races unseen.
]]
local MAX_STUCK_STEPS = 5
ns.RESTOCK_MAX_STUCK_STEPS = MAX_STUCK_STEPS

--------------------------------------------------------------------------------
-- Restock State
--------------------------------------------------------------------------------

local RestockState = {}
RestockState.__index = RestockState

function ns.NewRestockState()
	local state = {}
	state.lastRemainingWork = math.huge
	state.stuckSteps = 0
	state.consolidating = false
	state.lastStackCount = math.huge
	state.tidySteps = 0
	state.lastTotals = nil
	state.suspectSteps = 0
	state.cursorSteps = 0
	state.lockedTicks = 0
	state.overshotItems = {}
	state.amounts = {}
	-- Set by the first stash or pull; a run that moved nothing finishes without a word (CompletionMessage).
	state.movedAny = false

	setmetatable(state, RestockState)

	state:Rescan()
	for itemID, eachItem in pairs(state.currentList) do
		state:Wanted(itemID, eachItem)
	end

	return state
end

--[[
    Read once per row per run: the Keep box saves every keystroke, so a live read
    would act on a half-typed number; Enter restarts the run. A hand-edited nil
    reads as 0, since comparing nil would kill the coroutine.
]]
function RestockState:Wanted(itemID, eachItem)
	local wanted = self.amounts[itemID]
	if wanted == nil then
		wanted = eachItem.amount or 0
		self.amounts[itemID] = wanted
	end
	return wanted
end

--[[
    A scan across an item on the cursor reads short. Only list items are cleared
    at once; anything else is the player's drag, waited out for MAX_STUCK_STEPS
    and then cleared, so a parked cursor can't hold the run open.
]]
function RestockState:ClearCursorForScan()
	if not CursorHasItem() then
		self.cursorSteps = 0
		return true
	end

	local infoType, cursorItemID = GetCursorInfo()
	local isOurs = infoType == "item"
		and cursorItemID ~= nil
		and self.currentList ~= nil
		and self.currentList[cursorItemID] ~= nil

	if not isOurs and self.cursorSteps < MAX_STUCK_STEPS then
		self.cursorSteps = self.cursorSteps + 1
		ns.RestockerDebug("TRACE_CURSOR_FOREIGN_ITEM", self.cursorSteps, MAX_STUCK_STEPS)
		return false
	end

	self.cursorSteps = 0
	ClearCursor()
	return true
end

--[[
    Every step rescans, so a rejected or partial move shows as still short and is
    retried, never deducted optimistically; the watchdog ends a run that stops
    progressing. The list resolves before the cursor test, which needs it.
]]
function RestockState:Rescan()
	local settings = ns.restockSettings
	self.currentList = settings.lists[settings.currentList]

	if not self:ClearCursorForScan() then
		return false
	end

	self:UpdateInventory()
	return true
end

-- Zero when everything is at target or the only gaps are items the bank has none of.
function RestockState:RemainingWork()
	local work = 0
	for itemID, eachItem in pairs(self.currentList) do
		local haveInBag = self.playerInventory.summary[itemID] or 0
		local haveInBank = self.bankInventory.summary[itemID] or 0
		local wanted = self:Wanted(itemID, eachItem)

		if eachItem.restockFromBank and wanted > haveInBag and haveInBank > 0 then
			work = work + math.min(wanted - haveInBag, haveInBank)
		end
		-- An overshoot goes back even without Store: the add-on made it.
		if (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			work = work + (haveInBag - wanted)
		end
	end
	return work
end

-- For the in-flight gate: a drop against the last accepted scan means an item is mid-move.
function RestockState:ComputeTotals()
	local totals = {}
	for itemID in pairs(self.currentList) do
		totals[itemID] = (self.playerInventory.summary[itemID] or 0) + (self.bankInventory.summary[itemID] or 0)
	end
	return totals
end

-- A free slot in a soul bag or quiver is no room for water.
local function BagsHaveRoomFor(itemIDs)
	for _, bag in ipairs(ns.restockPlayerBags) do
		local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(bag.bagID)
		if numberOfFreeSlots > 0 then
			for _, itemID in ipairs(itemIDs) do
				if ns.BagTypeAccepts(bagType, ns.GetItemData(itemID)) then
					return true
				end
			end
		end
	end
	return false
end

-- Blames a full bag or bank only for a direction with a stuck row; otherwise names what couldn't move.
function RestockState:StuckMessage()
	local parts = {}
	local withdrawStuck, depositStuck = {}, false
	for itemID, eachItem in pairs(self.currentList) do
		local haveInBag = self.playerInventory.summary[itemID] or 0
		local haveInBank = self.bankInventory.summary[itemID] or 0
		local wanted = self:Wanted(itemID, eachItem)

		if eachItem.restockFromBank and wanted > haveInBag and haveInBank > 0 then
			withdrawStuck[#withdrawStuck + 1] = itemID
			parts[#parts + 1] = string.format(
				L["RESTOCKER_STUCK_ITEM_FORMAT"],
				math.min(wanted - haveInBag, haveInBank),
				ns.GetItemHyperlink(itemID)
			)
		elseif (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			depositStuck = true
			parts[#parts + 1] =
				string.format(L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"], haveInBag - wanted, ns.GetItemHyperlink(itemID))
		end
	end

	local bankHasSpace = ns.BankHasRestockSpace()
	local bagBlocked = #withdrawStuck > 0 and not BagsHaveRoomFor(withdrawStuck)
	local bankBlocked = depositStuck and not bankHasSpace
	if bagBlocked and bankBlocked then
		return L["RESTOCKER_STOPPED_BOTH_FULL"]
	elseif bankBlocked then
		return L["RESTOCKER_STOPPED_BANK_FULL"]
	elseif bagBlocked then
		return L["RESTOCKER_STOPPED_BAG_FULL"]
	end

	if #parts == 0 then
		return L["RESTOCKER_STOPPED_NO_PROGRESS"]
	end
	return string.format(L["RESTOCKER_STOPPED_COULD_NOT_MOVE"], table.concat(parts, L["LIST_SEPARATOR"]))
end

-- A file-level upvalue, so UpdateInventory, run every step, builds no closure.
local maintainedList

local function IsMaintainedItem(itemID)
	return maintainedList[itemID] ~= nil
end

function RestockState:UpdateInventory()
	local settings = ns.restockSettings
	maintainedList = settings.lists[settings.currentList]

	self.playerInventory = ns.GetRestockItemsInBags(IsMaintainedItem)
	self.bankInventory = ns.GetRestockItemsInBank(IsMaintainedItem)
end

--------------------------------------------------------------------------------
-- Bank Window
--------------------------------------------------------------------------------

-- Shift as the bank opens skips the whole visit; the close reminder follows only a run that started.
local bankRestockSkipped = false
local bankRestockStarted = false

function ns.OnRestockerBankFrameOpened()
	ns.bankIsOpen = true
	bankRestockSkipped = IsShiftKeyDown()
	bankRestockStarted = false
	ns.StartRestockBankRun()
end

-- Also restarts while the bank is open, whenever the list in use or a Keep amount changes.
function ns.StartRestockBankRun()
	ns.LoadRestockBankBags()

	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]

	-- An empty list would only announce a restock that never happened; a run already going stops.
	if bankRestockSkipped or list == nil or next(list) == nil then
		if bankRestockStarted then
			ns.StopBankRestock()
		end
		return
	end

	if settings.autoOpenAtBank then
		ns.ShowRestockWindowForVisit()
	end

	bankRestockStarted = true
	ns.RestartBankRestock()
end

-- Keyed off the tracked open flag, as the merchant's close is (see ns.OnRestockerMerchantClosed).
function ns.OnRestockerBankFrameClosed()
	local bankWasOpen = ns.bankIsOpen
	local restockStarted = bankRestockStarted
	ns.bankIsOpen = false
	bankRestockSkipped = false
	bankRestockStarted = false
	ns.StopBankRestock()
	if bankWasOpen then
		ns.HideRestockWindowAfterVisit()
	end

	local settings = ns.restockSettings
	if settings and restockStarted then
		ns.RemindRestockShortfallAfterVisit(settings.bankReminder, settings.bankReminderMode)
	end
end

-- The Restocker switched off mid-visit: no _CLOSED event will reach the switched-off handlers.
function ns.EndRestockBankVisit()
	ns.StopBankRestock()
	ns.bankIsOpen = false
	bankRestockSkipped = false
	bankRestockStarted = false
end
