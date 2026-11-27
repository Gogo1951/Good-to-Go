local _, ns = ...
local L = ns.L

-- The bank run's hard gate: UseContainerItem sells while a merchant is open.
ns.merchantIsOpen = false
ns.merchantBuyingSkipped = false

-- MERCHANT_SHOW can fire twice a visit. Closing resets it, so the next visit buys however soon.
local lastTimeRestocked = -math.huge

function ns.ResetMerchantRestockThrottle()
	lastTimeRestocked = -math.huge
end

local COPPER_PER_GOLD = 10000
ns.COPPER_PER_GOLD = COPPER_PER_GOLD

local NewPurchaseOrder

local function CountTableItems(theTable)
	if not theTable then
		return 0
	end

	local count = 0
	for _, _ in pairs(theTable) do
		count = count + 1
	end
	return count
end

-- Never sells: too many of an item is left alone, and there is no sell path.

--------------------------------------------------------------------------------
-- Buy Extra
--------------------------------------------------------------------------------

--[[
    Extra clears a limited slot (scarce potions that trickle back) on every pass
    instead of topping up to a number, so it gets an order even at zero owed. The
    amount stays the real shortfall, never a guess at stock, so partial-fill
    reports still work.
]]
local function BuildPurchaseOrder(purchaseOrders, eachRestockRecord, vendorReaction)
	local itemID = eachRestockRecord.itemID
	if not itemID then
		return
	end

	-- By itemID, as BuildGroceryList and the crafting order count, so all three agree.
	local haveInBag = C_Item.GetItemCount(itemID, false, false) or 0
	local amount = eachRestockRecord.amount or 0
	local requiredReaction = eachRestockRecord.reaction or 0
	local buyExtra = eachRestockRecord.buyExtra == true

	-- Skipped in silence below the standing: naming every gated item at every vendor would flood chat.
	if requiredReaction <= vendorReaction and (amount > 0 or buyExtra) then
		-- A negative amount would shrink the order it merges into.
		local toBuy = math.max(0, amount - haveInBag)

		if toBuy > 0 or buyExtra then
			local purchaseOrder = purchaseOrders[itemID]
			if not purchaseOrder then
				purchaseOrder = NewPurchaseOrder(toBuy, itemID)
				purchaseOrders[itemID] = purchaseOrder
			else
				purchaseOrder.amount = purchaseOrder.amount + toBuy
				purchaseOrder.remaining = purchaseOrder.remaining + toBuy
			end

			-- On the order, since a crafting reagent can merge into the same entry.
			if buyExtra then
				purchaseOrder.buyExtra = true
			end
		end
	end
end

local function UpdatePurchaseOrdersWithCraftingReagents(purchaseOrders, reagentID, toBuy)
	if not purchaseOrders[reagentID] then
		purchaseOrders[reagentID] = NewPurchaseOrder(toBuy, reagentID)
	else
		local purchase = purchaseOrders[reagentID]
		purchase.amount = purchase.amount + toBuy
		purchase.remaining = purchase.remaining + toBuy
	end
end

-- The ID comes off the slot where it can: a slot's link is nil until its item resolves.
local function MerchantSlotItemID(index)
	local link = GetMerchantItemLink(index)
	local itemID = ns.GetMerchantItemID(index)
	return itemID or (link and tonumber(link:match("item:(%d+)"))), link
end

--------------------------------------------------------------------------------
-- All or Nothing Reagents
--------------------------------------------------------------------------------

--[[
    Reagents are bought only where every one still needed is buyable now for
    gold: vials without dust craft nothing. A sold-out limited slot isn't
    stocked; a short one is (4 of 6 dust still crafts 4). Listed items are
    bought regardless.
]]
local function VendorStocksAllReagents(craftingPurchaseOrder)
	local needed = {}
	local neededCount = 0
	for reagentID, amount in pairs(craftingPurchaseOrder) do
		if amount > 0 then
			needed[reagentID] = true
			neededCount = neededCount + 1
		end
	end

	if neededCount == 0 then
		return true, false
	end

	local stockedCount = 0
	for i = 1, GetMerchantNumItems() do
		local _, _, _, _, numAvailable, isPurchasable, _, hasExtendedCost = ns.GetMerchantItemInfo(i)
		local itemID = MerchantSlotItemID(i)
		if
			itemID
			and needed[itemID]
			and isPurchasable
			and not hasExtendedCost
			and (numAvailable == -1 or numAvailable > 0)
		then
			needed[itemID] = nil -- count each reagent once, however many slots carry it
			stockedCount = stockedCount + 1
			if stockedCount == neededCount then
				return true, true
			end
		end
	end

	return false, stockedCount > 0
end

--[[
    Counts units, never calls. Buys from remaining, since one item can sit in
    several slots sharing one order. A chunk the budget can't pay for or carry
    is never sent. Slots the server would refuse, or that cost more than gold,
    are passed over.
]]
local function PurchaseMerchantItem(i, purchaseOrders, budget)
	local _, _, price, batchQuantity, merchantAvailable, isPurchasable, _, hasExtendedCost = ns.GetMerchantItemInfo(i)
	if not isPurchasable or hasExtendedCost then
		return
	end
	local itemID, itemLink = MerchantSlotItemID(i)

	local buyItem = itemID and purchaseOrders[itemID]
	local unitsOrdered = 0

	if buyItem then
		--[[
		    Until the record arrives the slot's stack size stands in, with a bare
		    record so bag space still counts partial stacks; failing both, single units.
		]]
		local itemInfo = ns.GetItemData(itemLink or itemID)
		if not itemInfo then
			local maxStack = GetMerchantItemMaxStack(i)
			if maxStack and maxStack > 0 then
				itemInfo = { itemID = itemID, itemStackCount = maxStack }
			end
		end
		local stackCount = itemInfo and itemInfo.itemStackCount or 1
		-- A slot's own cap can be below the item's stack.
		local slotMaxStack = GetMerchantItemMaxStack(i)
		if slotMaxStack and slotMaxStack > 0 then
			stackCount = math.min(stackCount, slotMaxStack)
		end
		if stackCount < 1 then
			stackCount = 1
		end

		--[[
		    Everything goes through the chunked loop: one call for more than a stack
		    is rejected yet would credit the full amount. Only a positive count is a
		    limited slot (-1 unlimited, 0 sold out). Extra takes a limited slot's whole
		    count and does nothing on an unlimited one, which never runs out.
		]]
		local wanted = buyItem.remaining
		if merchantAvailable > 0 then
			if buyItem.buyExtra then
				wanted = merchantAvailable
			elseif wanted > merchantAvailable then
				wanted = merchantAvailable
			end
		end

		-- A sold-out slot adds nothing, so it can't announce a partial fill.
		if merchantAvailable ~= 0 then
			-- The slot's price buys its batch quantity (arrows come by the 200).
			local unitPrice = (price or 0) / math.max(batchQuantity or 1, 1)
			for n = wanted, 1, -stackCount do
				local chunk = (n > stackCount) and stackCount or n
				local cost = math.ceil(unitPrice * chunk)
				if cost > budget.money then
					budget.outOfGold = true
					break
				end
				if not ns.ClaimBagSpace(budget.space, itemInfo, chunk) then
					budget.outOfSpace = true
					break
				end
				BuyMerchantItem(i, chunk)
				budget.money = budget.money - cost
				unitsOrdered = unitsOrdered + chunk
			end
		end

		buyItem.remaining = math.max(0, buyItem.remaining - unitsOrdered)
		buyItem.bought = buyItem.bought + unitsOrdered
	end
end

-- One visit, never saved. startCount is what arrivals are read against once the server answers.
function NewPurchaseOrder(amount, itemID)
	return {
		amount = amount,
		remaining = amount,
		bought = 0,
		itemID = itemID,
		startCount = C_Item.GetItemCount(itemID, false, false) or 0,
	}
end

function ns.RestockFromMerchant()
	local settings = ns.restockSettings
	if CountTableItems(settings.lists[settings.currentList]) == 0 then
		return
	end

	if GetTime() - lastTimeRestocked < 1 then
		return
	end

	lastTimeRestocked = GetTime()

	-- A run still waiting on its buys reports now, so its counts aren't read against this run's.
	ns.ReportPendingMerchantRun()

	if settings.autoOpenAtMerchant then
		ns.ShowRestockWindowForVisit()
	end

	local craftingPurchaseOrder = ns.BuildCraftingPurchaseOrder() or {}

	-- Said only where the vendor stocked some: at one with none, a skip isn't news.
	local allReagentsStocked, anyReagentStocked = VendorStocksAllReagents(craftingPurchaseOrder)
	if not allReagentsStocked then
		if anyReagentStocked then
			ns:PrintMessage(L["RESTOCKER_REAGENTS_SKIPPED"])
		end
		craftingPurchaseOrder = {}
	end

	local purchaseOrders = {}
	local restockList = settings.lists[settings.currentList]
	-- "npc" is the vendor being talked to; it is usually not targeted.
	local vendorReaction = UnitReaction("npc", "player") or UnitReaction("target", "player") or 0

	for _, eachRestockRecord in pairs(restockList) do
		if eachRestockRecord.buyFromMerchant or eachRestockRecord.buyFromMerchant == nil then -- nil defaults to true
			BuildPurchaseOrder(purchaseOrders, eachRestockRecord, vendorReaction)
		end
	end

	for reagentID, toBuy in pairs(craftingPurchaseOrder) do
		UpdatePurchaseOrdersWithCraftingReagents(purchaseOrders, reagentID, toBuy)
	end

	-- Purse and bags don't change until the server answers, so both are read once and spent down here.
	local startingMoney = GetMoney()
	local budget = { money = startingMoney, space = ns.NewBagSpace(ns.restockPlayerBags) }

	-- A purse at or under the reserve pauses all buying; the bank run, which costs nothing, carries on.
	if settings.goldReserve then
		local reserve = settings.goldReserveAmount * COPPER_PER_GOLD
		budget.money = math.max(0, budget.money - reserve)
	end

	for i = 1, GetMerchantNumItems() do
		PurchaseMerchantItem(i, purchaseOrders, budget)
	end

	local run = {
		orders = purchaseOrders,
		outOfGold = budget.outOfGold,
		outOfSpace = budget.outOfSpace,
		settings = settings,
		startingMoney = startingMoney,
		waiters = {},
	}
	ns.AwaitMerchantRun(run)
end

--------------------------------------------------------------------------------
-- Merchant Window
--------------------------------------------------------------------------------

function ns.OnRestockerMerchantShow()
	ns.merchantIsOpen = true

	if IsShiftKeyDown() then
		ns.merchantBuyingSkipped = true
		return
	end

	ns.merchantBuyingSkipped = false
	ns.RestockFromMerchant()
end

--[[
    Loading screens fire _CLOSED events with no open, sometimes twice, so the
    reminder and the window close key off the tracked open flag.
]]
function ns.OnRestockerMerchantClosed()
	local merchantWasOpen = ns.merchantIsOpen
	ns.merchantIsOpen = false
	ns.merchantBuyingSkipped = false
	ns.ResetMerchantRestockThrottle()
	if merchantWasOpen then
		ns.HideRestockWindowAfterVisit()
	end

	-- After the visit's own summary, which can still be waiting on its buys.
	local settings = ns.restockSettings
	if settings and merchantWasOpen then
		ns.AfterMerchantBuysLand(function()
			ns.RemindRestockShortfallAfterVisit(settings.merchantReminder, settings.merchantReminderMode)
		end)
	end
end

-- The Restocker switched off mid-visit: no _CLOSED event will reach the switched-off handlers.
function ns.EndRestockMerchantVisit()
	ns.merchantIsOpen = false
	ns.merchantBuyingSkipped = false
end
