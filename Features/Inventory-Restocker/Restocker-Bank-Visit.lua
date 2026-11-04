local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local CountPartialStacks = ns.CountRestockPartialStacks
local ConsolidateOne = ns.ConsolidateRestockStacks
local MAX_STUCK_STEPS = ns.RESTOCK_MAX_STUCK_STEPS

--[[
    Restocker-Bank-Visit -- the bank restock run itself: one stash or pull per
    tick, the watchdogs that end it, the tidy phase once every item is at
    target, and the OnUpdate timer that paces the moves to the connection.
    What the run knows about the bags and bank, and the bank window's open and
    close, are Restocker-Bank-State.lua.
]]

local currentlyRestocking = false
local restockState = nil
-- The OnUpdate timer's frame, created below once OnBankRestockUpdate exists.
local restockUpdateFrame
local updateTimer = 0
--[[
    Starts at the floor so the OnUpdate handler never compares against nil; the real
    connection-paced value is seeded in ns.RestartBankRestock.
]]
local updateInterval = 0.140

--[[
    A maintained item's bag+bank TOTAL can only drop while a move is in transit: the source
    slot is already empty but the destination hasn't been credited yet, and NOTHING is locked
    in that window, so the lock gate in OnBankRestockUpdate can't see it. A scan taken there
    under-counts and must not be acted on. Wait at most this many steps for the total to
    recover before accepting it as the new reality (item genuinely consumed or destroyed).
]]
local MAX_INFLIGHT_STEPS = 3

--------------------------------------------------------------------------------
-- Restock Steps
--------------------------------------------------------------------------------

--[[
    Issue one stash move: find the first over-stocked item and send some to the bank. The
    excess is computed fresh from this step's scan, not from a running tally.
]]
local function StashToBank()
	local state = restockState

	for itemID, eachItem in pairs(state.currentList) do
		if eachItem.stashToBank or state.overshotItems[itemID] then
			local haveInBag = state.playerInventory.summary[itemID] or 0
			local wanted = state:Wanted(itemID, eachItem)
			local excess = haveInBag - wanted
			if excess > 0 then
				ns.RestockerDebug("TRACE_TOO_MANY", eachItem.itemName, haveInBag, wanted)
				if ns.MoveRestockItemToBank(state.bankInventory, itemID, excess) then
					state.movedAny = true
					return true -- issued one move; caller yields and re-scans next step
				end
			end
		end
	end

	return false
end

--[[
    Issue one restock move: find the first under-stocked item the bank can supply and pull
    some in. The shortfall is computed fresh from this step's scan.
]]
local function RestockFromBank()
	local state = restockState

	for itemID, eachItem in pairs(state.currentList) do
		if eachItem.restockFromBank then
			local haveInBag = state.playerInventory.summary[itemID] or 0
			local haveInBank = state.bankInventory.summary[itemID] or 0
			local wanted = state:Wanted(itemID, eachItem)
			local short = wanted - haveInBag
			if short > 0 and haveInBank > 0 then
				ns.RestockerDebug("TRACE_TOO_FEW", eachItem.itemName, haveInBag, wanted)
				--[[
				    stuckSteps > 0 means the previous step's move never landed -- in practice the
				    flaky exact split. Switch to whole-stack overshoot, which always lands; the
				    watchdog would otherwise burn its retries on the same bounced split and give up
				    short (the "couldn't move: 2x ..." stop).
				]]
				local overshoot = state.stuckSteps > 0
				if
					ns.MoveRestockItemFromBank(state.playerInventory, itemID, math.min(short, haveInBank), overshoot)
				then
					state.movedAny = true
					if overshoot then
						--[[
						    The whole-stack pull may go past the target. That excess is the add-on's
						    doing, not the player's stock -- trim it back even without stashToBank.
						]]
						state.overshotItems[itemID] = true
					end
					return true -- issued one move; caller yields and re-scans next step
				end
			end
		end
	end

	return false
end

-- The finished run's line itself; the options panel's Example draws through it too.
function ns.BuildBankRestockCompleteLine()
	return string.format(
		L["RESTOCKER_COMPLETE"],
		GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("TEXT")
	)
end

--[[
    The line a finished run prints, or nil for a visit that took nothing out
    and stored nothing: the same three sentences at every bank visit would turn
    into noise and stop being read. Merging partial stacks alone does not count.
]]
local function CompletionMessage()
	if not restockState.movedAny then
		return nil
	end
	return ns.BuildBankRestockCompleteLine()
end

local function FinishRestocking(message)
	currentlyRestocking = false
	restockUpdateFrame:Hide() -- stop the periodic OnUpdate timer
	if message then
		ns:PrintMessage(message)
	end
end

--[[
    The bank window closing, from outside this file. The run is abandoned rather
    than finished, so it says nothing: the closing handler reports the shortfall.
]]
function ns.StopBankRestock()
	FinishRestocking(nil)
end

--[[
    Run a single restock step: re-scan reality, then issue at most one move. The coroutine
    calls this once per eligible tick (only after the previous move has settled -- see the
    lock gate in OnBankRestockUpdate) and yields between calls.
]]
local function RunRestockLogic()
	local state = restockState

	--[[
	    HARD SAFETY INVARIANT: never sell at a merchant. The moves below use
	    C_Container.UseContainerItem to shift whole stacks, and that call SELLS the item when a
	    merchant window is open (it only moves to the bank when a BANK is open). A bank and a
	    merchant can't normally both be open, but if the merchant flag is set -- a stale flag, or
	    an odd BANKFRAME/MERCHANT event order -- issuing a stash here would vendor the player's
	    "too many" excess. Refuse to act: bail cleanly, and the next real bank visit restarts.
	]]
	if ns.merchantIsOpen then
		ns.RestockerDebug("TRACE_MERCHANT_OPEN")
		FinishRestocking(nil)
		return true
	end

	--[[
	    Reconcile against reality every step: re-derive the outstanding work from what's
	    actually in the bags/bank right now. A move that was rejected or only partially placed
	    simply reappears as remaining work and gets retried; a move that worked shrinks the
	    work for real.

	    A declined rescan (the player is holding something of their own) is a skipped tick,
	    not a stalled run: nothing below has read this step's inventories yet, and the step
	    is deliberately not counted against the watchdog, since no move was attempted.
	]]
	if not state:Rescan() then
		return false
	end

	--[[
	    In-flight gate: a maintained item's bag+bank total can only DROP while a move is in
	    transit (source slot already empty, destination not yet credited -- and nothing is
	    locked in that window, so the lock gate in OnBankRestockUpdate can't hold us back). A scan
	    taken there under-counts: acting on it pulls a duplicate stack, and when the
	    in-transit stack is the bank's LAST one, prints "Finished restocking" with the pull
	    still in the air -- skipping the stash-back. Don't move and don't finish
	    off a scan like that; wait for the total to recover. If it stays down past
	    MAX_INFLIGHT_STEPS, the item really left (consumed/destroyed) -- accept the new
	    baseline and continue.
	]]
	local totals = state:ComputeTotals()
	if state.lastTotals ~= nil and state.suspectSteps < MAX_INFLIGHT_STEPS then
		for itemID, previousTotal in pairs(state.lastTotals) do
			if (totals[itemID] or 0) < previousTotal then
				state.suspectSteps = state.suspectSteps + 1
				local listItem = state.currentList[itemID]
				ns.RestockerDebug(
					"TRACE_IN_TRANSIT",
					listItem and listItem.itemName or tostring(itemID),
					totals[itemID] or 0,
					previousTotal
				)
				return false
			end
		end
	end
	state.suspectSteps = 0
	state.lastTotals = totals

	local remaining = state:RemainingWork()

	if remaining > 0 then
		state.consolidating = false -- still moving; tidy phase (below) hasn't started

		--[[
		    Watchdog. We normally get here with locks already settled (OnBankRestockUpdate gates on
		    that, until one of ours has stayed locked for MAX_STUCK_STEPS ticks), so if the
		    outstanding work did NOT shrink since last step, the last move genuinely didn't land --
		    a rejected split, an item stuck locked, or something we can't place. Retry a few times to absorb
		    transient races, then give up with a clear message. With it the run neither spins
		    forever on a move that never lands nor reports success while still short.
		]]
		if remaining < state.lastRemainingWork then
			state.stuckSteps = 0
		else
			state.stuckSteps = state.stuckSteps + 1
			if state.stuckSteps >= MAX_STUCK_STEPS then
				FinishRestocking(state:StuckMessage())
				return true
			end
		end
		state.lastRemainingWork = remaining

		--[[
		    ONE move per tick: stash an over-stocked item or pull an under-stocked one. Doing
		    only one keeps a stash and a restock from firing in the same tick and fighting over
		    the cursor. ALWAYS keep going (return false) even if nothing was issued -- a slot may
		    still be locked from the previous move; the watchdog above is what stops us if we're
		    genuinely stuck. Stashing runs first so it can free a bag slot for restocking, except
		    while the bank has no free general-purpose slot: a stash cannot land then, and retrying it would
		    starve every pull, so restocking runs first, and a whole stack taken out frees the
		    slot the stash needs.
		]]
		local bankHasSpace = ns.BankHasRestockSpace()
		if bankHasSpace then
			if not StashToBank() then
				RestockFromBank()
			end
		elseif not RestockFromBank() then
			StashToBank()
		end
		return false
	end

	--[[
	    All items are at target. TIDY PHASE (best-effort): merge the partial stacks that
	    free-slot-first placement and exact splits leave behind, in the bags and then the bank. This can never leave an item short (totals are
	    already correct) -- the worst case is that a merge doesn't take and we simply stop.
	]]
	-- Tidies every item on the list, whatever its Take and Store settings: the maintainer's choice.
	if not state.consolidating then
		state.consolidating = true -- entering tidy phase; start its watchdog fresh
		state.lastStackCount = math.huge
		state.tidySteps = 0
	end

	--[[
	    Tidy watchdog: each successful merge leaves one fewer partial stack, so the partial
	    stack count strictly drops while we're making progress. If it stops dropping (fully
	    consolidated, or a merge got bounced), finish cleanly -- restocking already succeeded,
	    so this is a normal "Finished", not a problem to report.
	]]
	local stacks = CountPartialStacks(state.playerInventory, state.bankInventory)
	if stacks < state.lastStackCount then
		state.tidySteps = 0
	else
		state.tidySteps = state.tidySteps + 1
		if state.tidySteps >= MAX_STUCK_STEPS then
			FinishRestocking(CompletionMessage())
			return true
		end
	end
	state.lastStackCount = stacks

	if ConsolidateOne(state.playerInventory) or ConsolidateOne(state.bankInventory) then
		return false -- merged a pair; re-scan next tick and keep tidying
	end

	-- Nothing left to merge: genuinely done.
	FinishRestocking(CompletionMessage())
	return true
end

local function RunRestockCoroutine()
	while RunRestockLogic() == false and ns.bankIsOpen do
		coroutine.yield()
	end
end

local restockCoroutine = coroutine.create(RunRestockCoroutine)

local function MaintainAndResumeCoroutine()
	if restockCoroutine == nil or coroutine.status(restockCoroutine) == "dead" then
		ns.RestockerDebug("TRACE_CREATE_COROUTINE")
		restockCoroutine = coroutine.create(RunRestockCoroutine)
	end

	local ok, errorMessage = coroutine.resume(restockCoroutine)

	if not ok then
		--[[
		    Surface the error to the user instead of letting it vanish, then stop so we don't
		    respawn the coroutine and re-trigger the same error every tick. Reopening the bank
		    (ns.RestartBankRestock) creates a fresh coroutine and retries.
		]]
		ns:PrintMessage(string.format(L["RESTOCKER_STOPPED_ERROR"], tostring(errorMessage)))
		FinishRestocking(nil)
		restockCoroutine = nil
	end
end

--------------------------------------------------------------------------------
-- Move Timer
--------------------------------------------------------------------------------

--[[
    One move is issued per tick. Pace ticks to the connection so a move has time to be
    confirmed by the server before the next one: wait ~3x the round-trip, but never faster
    than 0.140s. GetNetStats only refreshes its figures every ~30s, so this is called once
    per tick (and once at restock start) rather than on every OnUpdate frame.
]]
local function ComputeUpdateInterval()
	local _, _, pingHome, pingWorld = GetNetStats()
	local maxPing = math.max(pingHome, pingWorld)
	return math.max(0.140, (maxPing * 3) / 1000)
end

local function OnBankRestockUpdate(_frame, elapsed)
	if ns.bankIsOpen == false then
		restockUpdateFrame:Hide()
		return
	end

	updateTimer = updateTimer + elapsed

	if updateTimer >= updateInterval then
		updateTimer = 0
		updateInterval = ComputeUpdateInterval() -- pace the NEXT tick

		if currentlyRestocking then
			--[[
			    Wait until the previous move has FULLY settled (no slot still locked) before
			    issuing the next one. Firing a split while the server is still consolidating the
			    item from a move ~140ms ago is what gets rejected with "Couldn't split those
			    items". The fixed tick interval alone isn't enough on a laggy connection. Only wait
			    on OUR items -- an unrelated locked slot must not stall the restock forever.

			    One of ours can stay locked too (held on the cursor, or a lock the server never
			    clears). After MAX_STUCK_STEPS locked ticks the gate stops waiting and resumes, so
			    ClearCursorForScan can clear our own stray and the watchdog can count the steps
			    that land nothing and stop with StuckMessage.
			]]
			if restockState and ns.IsRestockItemLocked(restockState.currentList) then
				restockState.lockedTicks = restockState.lockedTicks + 1
				if restockState.lockedTicks < MAX_STUCK_STEPS then
					return
				end
			elseif restockState then
				restockState.lockedTicks = 0
			end
			MaintainAndResumeCoroutine()
		end
	end
end

function ns.RestartBankRestock()
	restockState = ns.NewRestockState()
	currentlyRestocking = true
	updateInterval = ComputeUpdateInterval() -- pace the first tick off a fresh reading
	restockCoroutine = coroutine.create(RunRestockCoroutine) -- fresh run for this bank visit
	restockUpdateFrame:Show() -- start the periodic timer in the update frame
end

restockUpdateFrame = CreateFrame("Frame")
restockUpdateFrame:SetScript("OnUpdate", OnBankRestockUpdate)
-- A new frame starts shown; the timer runs only between ns.RestartBankRestock and the bank closing.
restockUpdateFrame:Hide()

--[[
    There is no manual re-trigger for a restock, and there must not be one on the
    Diagnostic Tools panel: that panel is read-only by rule, and a restock moves
    the player's items. Closing and reopening the bank restarts a run, and the
    step-by-step trace behind ns.RestockerDebug is what actually explains a stuck
    one.
]]
