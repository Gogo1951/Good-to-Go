local _, ns = ...
local L = ns.L

--[[
    Restocker-Bank-State -- what a bank restock run knows: whether a bank
    window is open, the run's state (the list it works to, and the bags and
    bank as this step scanned them), the work still owed and why a stuck run
    stopped, and the bank window's open and close. The moves and the timer
    that paces them are Restocker-Bank-Visit.lua; the tidy phase's stack
    helpers are Restocker-Bank-Tidy.lua.
]]

-- Read across files as the "a bank window is open" gate.
ns.bankIsOpen = false

--[[
    After this many consecutive steps that fail to reduce the outstanding work (a move that
    keeps being rejected, or an item stuck locked), stop and report what's still short --
    instead of retrying forever. Retrying a handful of times first rides out transient
    "Couldn't split those items" races without ever bothering the user.
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
    The Keep amount this run works to, read once per row: as the run starts, or
    when a row added since first turns up. The Keep box saves every keystroke,
    so a live read would act on a number half typed (clearing the box reads 0,
    which stores the whole stack); Enter restarts the run with the new number
    (Restocker-Window-Rows.lua).

    A hand-edited save can leave amount nil; comparing that against a count
    throws inside the coroutine and kills the whole run, so it reads as 0.
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
    Whether the cursor is clear enough to snapshot over, clearing it where that is ours to do.

    An item on the cursor is uncounted, so a scan taken across one reads short and moves
    things that are already fine. Only OUR strays are cleared outright: every move a restock run
    issues is of a maintained item, so a cursor holding anything else belongs to the player --
    picked up to move it by hand -- and clearing it would snap their drag back within a tick.
    A foreign item is waited out for the same MAX_STUCK_STEPS budget the watchdog spends, then
    cleared anyway, so a parked cursor can never hold a run open forever.
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
    Refresh the list and re-scan bags + bank. Called at the START OF EVERY restock step,
    so the plan is always derived from what is actually in the containers right now. That way
    a move the server rejected or only partially placed shows up as "still short" on the
    next step and gets retried, instead of being assumed done. Never
    deduct from a plan optimistically: a move that does not fully land leaves the item short
    in silence. Recomputing every step is safe only because the watchdog in RunRestockLogic
    stops the run once it stops making progress; without that guard it spins on "Couldn't
    split those items" forever.

    Returns false when the cursor made this step unsafe to read, which is the caller's cue to
    do nothing this tick. The list is resolved before that test, because deciding whose
    item is on the cursor needs it -- and it leaves the inventories from the previous scan
    untouched rather than half-updated.
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

--[[
    How much moving is still owed: shortfalls the bank can supply, plus excesses to stash.
    Zero means done -- either everything is at target, or the only gaps left are items the
    bank has none of (nothing more we can do).
]]
function RestockState:RemainingWork()
	local work = 0
	for itemID, eachItem in pairs(self.currentList) do
		local haveInBag = self.playerInventory.summary[itemID] or 0
		local haveInBank = self.bankInventory.summary[itemID] or 0
		local wanted = self:Wanted(itemID, eachItem)

		if eachItem.restockFromBank and wanted > haveInBag and haveInBank > 0 then
			work = work + math.min(wanted - haveInBag, haveInBank)
		end
		--[[
		    Overshoot excess counts as stash work even without stashToBank: the add-on created it
		    (whole-stack fallback pull), so the add-on returns it.
		]]
		if (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			work = work + (haveInBag - wanted)
		end
	end
	return work
end

--[[
    Bag+bank total for each maintained item, from this step's scan. Used by the in-flight
    gate in RunRestockLogic: a DROP versus the last accepted scan means an item is mid-move.
]]
function RestockState:ComputeTotals()
	local totals = {}
	for itemID in pairs(self.currentList) do
		totals[itemID] = (self.playerInventory.summary[itemID] or 0) + (self.bankInventory.summary[itemID] or 0)
	end
	return totals
end

--[[
    Whether the player's bags have a free slot that can take any of these items: a free
    slot in a soul bag or quiver is no room for water.
]]
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

--[[
    A user-facing message for why we stopped when work still remains. Blames a full
    bag or bank only for a direction that has a stuck row (a withdrawal needs bag
    room that can take one of the stuck items, a deposit needs bank room); otherwise
    lists exactly what we couldn't move.
]]
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
				ns.GetItemHyperlink(itemID, eachItem.itemName)
			)
		elseif (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			depositStuck = true
			parts[#parts + 1] = string.format(
				L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"],
				haveInBag - wanted,
				ns.GetItemHyperlink(itemID, eachItem.itemName)
			)
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

--[[
    Is this bag/bank item one we maintain? Lists are keyed by itemID, so this is
    an O(1) lookup instead of scanning the whole list by name for every bag
    slot. Hoisted out of UpdateInventory, which runs on every restock step: it
    reads the list off this upvalue rather than closing over a fresh one each time.
]]
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

--[[
    One bank visit: a Shift held as the bank opens skips its run for the whole
    visit, and the close reminder follows only a visit whose run started.
]]
local bankRestockSkipped = false
local bankRestockStarted = false

function ns.OnRestockerBankFrameOpened()
	ns.bankIsOpen = true
	bankRestockSkipped = IsShiftKeyDown()
	bankRestockStarted = false
	ns.OnRestockerBankOpen()
end

-- Also run while the bank is open, when the list in use or a Keep amount changes.
function ns.OnRestockerBankOpen()
	ns.LoadRestockBankBags()

	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]

	-- An empty list has nothing to move, so the run would only announce a restock that never happened.
	if bankRestockSkipped or list == nil or next(list) == nil then
		return
	end

	if settings.autoOpenAtBank then
		ns.ShowRestockWindowForVisit()
	end

	bankRestockStarted = true
	ns.RestartBankRestock()
end

-- Keyed off the tracked open flag, as the merchant's close is (see ns.OnRestockerMerchantClose).
function ns.OnRestockerBankClose()
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
