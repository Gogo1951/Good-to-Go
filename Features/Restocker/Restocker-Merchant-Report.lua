local _, ns = ...
local L = ns.L
local COPPER_PER_GOLD = ns.COPPER_PER_GOLD

--[[
    What a merchant run prints, and the wait for its buys to land before it
    does. Restocker-Merchant.lua sends the run and hands it over through
    ns.AwaitMerchantRun.
]]

--[[
    The line a merchant run prints when gold turned a chunk away. money is the
    purse before the run. When the Gold Reserve is on and the purse started at
    or below it, the line says buying waits on the reserve, naming it, so a
    player who forgot setting it knows why the vendor was skipped; a purse above
    the reserve that simply ran short gets the plain line. The Restocker panel's
    Example draws it too.
]]
function ns.BuildOutOfGoldLine(settings, money)
	if settings.goldReserve and (money or 0) <= (settings.goldReserveAmount or 0) * COPPER_PER_GOLD then
		local reserve = settings.goldReserveAmount .. ns.GOLD_ICON
		return string.format(L["RESTOCKER_OUT_OF_GOLD_RESERVE"], reserve)
	end
	return L["RESTOCKER_OUT_OF_GOLD"]
end

--[[
    What a merchant run prints: filled and partly filled orders, counted apart
    and each silent at zero. The counts are of what arrived in the bags, read
    once the buys have landed (ReportRun), not of what was sent.
]]
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
    The server answers a run's buys after the run has been sent, and may turn
    some away (a limited slot emptied by someone else, a stack refused), so the
    summary waits for the bags: each BAG_UPDATE_DELAYED checks whether every
    order's buys have arrived, and BUY_SETTLE_TIMEOUT seconds report whatever
    has, which is what catches a buy that never comes.
]]
local BUY_SETTLE_TIMEOUT = 3

-- The run whose buys are still landing, or nil.
local pendingRun

-- How much of an order is in the bags now that wasn't when the run began.
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
	    Each order counts once, however many slots it bought from. The > 0 half
	    matters for a zero-amount order, which both the crafting-reagent path and a
	    fully stocked Extra row can create: nothing arriving must never read as an
	    order filled. An Extra row that did clear a slot passes on the same test,
	    since anything at all covers a zero target.
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

	--[[
	    Report what happened, and nothing more. Anything this vendor did not stock
	    is still outstanding, but the mini-map's Restocker Report already says so --
	    the chat line covers the event, the tooltip covers the outstanding state,
	    and neither repeats the other.

	    Filled and partly filled are counted apart and printed apart, so a mixed run
	    needs no combined string and a clean one never mentions partials. Both are
	    silent at zero, which keeps a vendor that stocked nothing on our list quiet.
	]]
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

-- Called on BAG_UPDATE_DELAYED (Restocker-Events.lua): reports the pending run once all its buys are in.
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

--[[
    A run ns.RestockFromMerchant has just sent waits here for its buys to land,
    and reports at once when it sent none.
]]
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
