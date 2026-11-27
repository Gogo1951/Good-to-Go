local _, ns = ...
local L = ns.L
local COPPER_PER_GOLD = ns.COPPER_PER_GOLD

--[[
    A purse that started at or under the Gold Reserve gets a line naming the
    reserve, so a player who forgot setting it knows why the vendor was skipped.
]]
function ns.BuildOutOfGoldLine(settings, money)
	if settings.goldReserve and (money or 0) <= (settings.goldReserveAmount or 0) * COPPER_PER_GOLD then
		local reserve = settings.goldReserveAmount .. ns.GOLD_ICON
		return string.format(L["RESTOCKER_OUT_OF_GOLD_RESERVE"], reserve)
	end
	return L["RESTOCKER_OUT_OF_GOLD"]
end

-- The counts are of what arrived in the bags once the buys landed, not of what was sent.
local function BuildRestockSummaryLines(ordersFilled, ordersPartlyFilled)
	local lines = {}
	if ordersFilled == 1 then
		lines[#lines + 1] = L["RESTOCKER_RESTOCKED_ONE"]
	elseif ordersFilled > 1 then
		lines[#lines + 1] = string.format(L["RESTOCKER_RESTOCKED_MANY"], ordersFilled)
	end
	if ordersPartlyFilled == 1 then
		lines[#lines + 1] = L["RESTOCKER_RESTOCKED_PARTIAL_ONE"]
	elseif ordersPartlyFilled > 1 then
		lines[#lines + 1] = string.format(L["RESTOCKER_RESTOCKED_PARTIAL_MANY"], ordersPartlyFilled)
	end
	return lines
end

--------------------------------------------------------------------------------
-- Waiting For The Buys
--------------------------------------------------------------------------------

--[[
    The server answers after the run is sent and may turn buys away, so the
    summary waits for the bags; the timeout reports whatever arrived, which
    catches a buy that never comes.
]]
local BUY_SETTLE_TIMEOUT = 3

local pendingRun

local function OrderDelivered(order)
	return math.max(0, (C_Item.GetItemCount(order.itemID, false, false) or 0) - order.startCount)
end

local function AllBuysLanded(run)
	for _, order in pairs(run.orders) do
		if order.bought > 0 and OrderDelivered(order) < order.bought then
			return false
		end
	end
	return true
end

local function ReportRun(run)
	if pendingRun == run then
		pendingRun = nil
	end

	--[[
	    The > 0 test guards a zero-amount order (a reagent, or a fully stocked
	    Extra row): nothing arriving must never read as an order filled.
	]]
	local ordersFilled = 0
	local ordersPartlyFilled = 0
	for _, order in pairs(run.orders) do
		local delivered = order.bought > 0 and OrderDelivered(order) or 0
		if delivered > 0 then
			if delivered >= order.amount then
				ordersFilled = ordersFilled + 1
			else
				ordersPartlyFilled = ordersPartlyFilled + 1
			end
		end
	end

	-- This run only: what is still outstanding is the closing reminder's job, so the summary never repeats it.
	for _, line in ipairs(BuildRestockSummaryLines(ordersFilled, ordersPartlyFilled)) do
		ns:PrintMessage(line)
	end

	-- Silent unless gold actually turned a chunk away, so a vendor that stocks nothing on the list says nothing.
	if run.outOfGold then
		ns:PrintMessage(ns.BuildOutOfGoldLine(run.settings, run.startingMoney))
	end

	if run.outOfSpace then
		ns:PrintMessage(L["RESTOCKER_BAGS_FULL_PARTIAL"])
	end

	for _, callback in ipairs(run.waiters) do
		callback()
	end
end

function ns.SettleMerchantBuys()
	if pendingRun and AllBuysLanded(pendingRun) then
		ReportRun(pendingRun)
	end
end

-- Runs callback once the pending run has reported, or now when none is pending.
function ns.AfterMerchantBuysLand(callback)
	if pendingRun then
		pendingRun.waiters[#pendingRun.waiters + 1] = callback
	else
		callback()
	end
end

-- A run still waiting on its buys reports now, so its counts aren't read against the next run's.
function ns.ReportPendingMerchantRun()
	if pendingRun then
		ReportRun(pendingRun)
	end
end

function ns.AwaitMerchantRun(run)
	local anySent = false
	for _, order in pairs(run.orders) do
		if order.bought > 0 then
			anySent = true
		end
	end
	if not anySent then
		ReportRun(run)
		return
	end
	pendingRun = run
	C_Timer.After(BUY_SETTLE_TIMEOUT, function()
		if pendingRun == run then
			ReportRun(run)
		end
	end)
end
