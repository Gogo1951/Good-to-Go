local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local CountPartialStacks = ns.CountRestockPartialStacks
local ConsolidateOne = ns.ConsolidateRestockStacks
local MAX_STUCK_STEPS = ns.RESTOCK_MAX_STUCK_STEPS

local currentlyRestocking = false
local restockState = nil
local restockUpdateFrame
local updateTimer = 0
-- The floor, so OnUpdate never compares against nil before ns.RestartBankRestock sets it.
local updateInterval = 0.140

--[[
    Steps to wait for a dropped bag-plus-bank total to recover before taking it
    as real (the item was used or destroyed).
]]
local MAX_INFLIGHT_STEPS = 3

-- The bank can read empty just after BANKFRAME_OPENED, so a run can't finish this soon.
local BANK_SETTLE_DELAY = 0.5

--------------------------------------------------------------------------------
-- Restock Steps
--------------------------------------------------------------------------------

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
					return true
				end
			end
		end
	end

	return false
end

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
				    A stuck step means the last split bounced; a whole stack always lands,
				    where retrying the split would spend the watchdog and stop short.
				]]
				local overshoot = state.stuckSteps > 0
				if
					ns.MoveRestockItemFromBank(state.playerInventory, itemID, math.min(short, haveInBank), overshoot)
				then
					state.movedAny = true
					if overshoot then
						state.overshotItems[itemID] = true
					end
					return true
				end
			end
		end
	end

	return false
end

local function BuildBankRestockCompleteLine()
	return string.format(
		L["RESTOCKER_COMPLETE"],
		GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("TEXT")
	)
end

--[[
    Nil for a visit that took and stored nothing (merges don't count): the same
    lines at every bank visit would stop being read.
]]
local function CompletionMessage()
	if not restockState.movedAny then
		return nil
	end
	return BuildBankRestockCompleteLine()
end

local function FinishRestocking(message)
	currentlyRestocking = false
	restockUpdateFrame:Hide()
	if message then
		ns:PrintMessage(message)
	end
end

-- Silent: the closing handler reports the shortfall.
function ns.StopBankRestock()
	FinishRestocking(nil)
end

local function RunRestockLogic()
	local state = restockState

	--[[
	    Never at a merchant: UseContainerItem sells there, so a stale merchant flag
	    or an odd event order would vendor the excess.
	]]
	if ns.merchantIsOpen then
		ns.RestockerDebug("TRACE_MERCHANT_OPEN")
		FinishRestocking(nil)
		return true
	end

	--[[
	    Forever's bank tab list can be empty when the bank opens, so it is asked
	    again each step. A declined rescan skips the tick without counting against
	    the watchdog.
	]]
	if #ns.GetRestockBankBags() == 0 then
		ns.LoadRestockBankBags()
	end
	if not state:Rescan() then
		return false
	end

	--[[
	    In-flight gate: mid-move the source is empty, the destination not yet
	    credited and nothing locked, so the lock gate misses it. Acting on that scan
	    pulls a duplicate stack, or finishes before the stash-back.
	]]
	local totals = state:ComputeTotals()
	if state.lastTotals ~= nil and state.suspectSteps < MAX_INFLIGHT_STEPS then
		for itemID, previousTotal in pairs(state.lastTotals) do
			if (totals[itemID] or 0) < previousTotal then
				state.suspectSteps = state.suspectSteps + 1
				local listItem = state.currentList[itemID]
				ns.RestockerDebug(
					"TRACE_IN_TRANSIT",
					listItem and listItem.itemName or itemID,
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
		state.consolidating = false

		--[[
		    Watchdog: locks have settled by now, so unchanged work means the last move
		    didn't land. Grown work is change: the bank arriving late, or an overshoot
		    turning into stash work.
		]]
		if remaining ~= state.lastRemainingWork then
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
		    One move per tick, so a stash and a pull never fight over the cursor; the
		    watchdog, not this, ends the run. Stash first to free bag room, unless the
		    bank is full: then a failing stash would starve every pull, and a pulled
		    whole stack frees the slot the stash needs.
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

	if GetTime() - state.startedAt < BANK_SETTLE_DELAY then
		return false
	end

	-- Tidy phase: totals are already right, so a merge that fails can't leave anything short.
	-- Tidies every item on the list, whatever its Take and Store settings: the maintainer's choice.
	if not state.consolidating then
		state.consolidating = true
		state.lastStackCount = math.huge
		state.tidySteps = 0
	end

	-- Each merge drops the partial-stack count; when it stops dropping, the run finishes normally.
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
		return false
	end

	FinishRestocking(CompletionMessage())
	return true
end

local function RunRestockCoroutine()
	while RunRestockLogic() == false and ns.bankIsOpen do
		coroutine.yield()
	end
end

local restockCoroutine

local function MaintainAndResumeCoroutine()
	if restockCoroutine == nil or coroutine.status(restockCoroutine) == "dead" then
		ns.RestockerDebug("TRACE_CREATE_COROUTINE")
		restockCoroutine = coroutine.create(RunRestockCoroutine)
	end

	local ok, errorMessage = coroutine.resume(restockCoroutine)

	if not ok then
		-- Stops rather than respawning the same error every tick; reopening the bank retries.
		ns:PrintMessage(string.format(L["RESTOCKER_STOPPED_ERROR"], tostring(errorMessage)))
		FinishRestocking(nil)
		restockCoroutine = nil
	end
end

--------------------------------------------------------------------------------
-- Move Timer
--------------------------------------------------------------------------------

-- Three round trips, so the server confirms a move before the next; read once per tick, not per frame.
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
		updateInterval = ComputeUpdateInterval()

		if currentlyRestocking then
			--[[
			    A split while the last move is still locked fails with "Couldn't split
			    those items", and the tick alone isn't enough on a laggy connection. Only
			    list items count; after MAX_STUCK_STEPS locked ticks it resumes so the
			    cursor clear and the watchdog can act.
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

--[[
    A restart within the visit carries over the overshoots still owed a
    stash-back, and whether anything moved, which earns the completion line.
]]
function ns.RestartBankRestock()
	local previous = currentlyRestocking and ns.bankIsOpen and restockState or nil
	restockState = ns.NewRestockState()
	restockState.startedAt = GetTime()
	if previous then
		restockState.overshotItems = previous.overshotItems
		restockState.movedAny = previous.movedAny
	end
	currentlyRestocking = true
	updateInterval = ComputeUpdateInterval()
	restockCoroutine = coroutine.create(RunRestockCoroutine)
	restockUpdateFrame:Show()
end

restockUpdateFrame = CreateFrame("Frame")
restockUpdateFrame:SetScript("OnUpdate", OnBankRestockUpdate)
-- A new frame starts shown.
restockUpdateFrame:Hide()

--[[
    No manual restock trigger, and none on the Diagnostic Tools panel: that panel
    is read-only, and a restock moves items.
]]
