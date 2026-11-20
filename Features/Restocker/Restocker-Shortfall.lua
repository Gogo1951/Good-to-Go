local _, ns = ...

--[[
    How short the bags are of the Restock List, with no merchant involved: the
    shortfall list the reminders and the mini-map menu read (every short
    row, also behind the window's footer count and tooltip), the grocery list
    Diagnostics reads (the short rows with Buy on), and the one-row test behind the Keep box's mark. The merchant restock
    itself is Restocker-Merchant.lua.
]]

--------------------------------------------------------------------------------
-- Grocery List
--------------------------------------------------------------------------------

--[[
    The rows of the current list the bags are short of right now, sorted by
    name: every one ns.IsRestockItemShort calls short, or with buyOnly only
    those with Buy on. Each is {itemID, itemName, have, wanted, needed}; have
    and wanted ride along for the reminders, whose low/out split reads the
    ratio (ns.SplitRestockShortfall) and whose Verbose mode prints it.
]]
local function BuildShortRows(buyOnly)
	local settings = ns.restockSettings
	local restockList = settings and settings.lists and settings.lists[settings.currentList]
	local list = {}
	if not restockList then
		return list
	end

	for _, record in pairs(restockList) do
		-- nil buyFromMerchant defaults to true, the same rule ns.RestockFromMerchant uses
		local buys = record.buyFromMerchant == nil or record.buyFromMerchant
		if ns.IsRestockItemShort(record) and (buys or not buyOnly) then
			local have = C_Item.GetItemCount(record.itemID, false, false) or 0
			-- sorted by the client's name, not a saved one gone stale (Restocker-Saved-Format.lua)
			ns.RefreshRestockItemName(record)
			list[#list + 1] = {
				itemID = record.itemID,
				itemName = record.itemName,
				have = have,
				wanted = record.amount,
				needed = record.amount - have,
			}
		end
	end

	table.sort(list, function(a, b)
		local nameA, nameB = a.itemName or "", b.itemName or ""
		if nameA ~= nameB then
			return nameA < nameB
		end
		return a.itemID < b.itemID
	end)
	return list
end

--[[
    Every row the current list is short of right now, Buy on or off, as the
    Restock window marks them: a row the bank is meant to fill still counts
    when the bank had none. Used by the entering-town reminder, the reminders
    after a merchant or bank window closes, and the mini-map menu, so all of
    them agree with the window.
]]
function ns.BuildRestockShortfallList()
	return BuildShortRows(false)
end

--[[
    What a merchant would be asked for right now: the short rows with Buy on,
    the same shortfall BuildPurchaseOrder computes, minus the vendor. Read by
    Diagnostics' Restocker report.

    Two differences from a real purchase order, both because there is no vendor:
    the required-reputation gate is skipped (it depends on which vendor you walk
    up to), and crafting reagents are left out (ns.BuildCraftingPurchaseOrder
    resolves those against the merchant's stock). So this answers "what am I low on", which is
    what a shopping list is, rather than "what will this vendor sell me".

    Counts are bags only -- C_Item.GetItemCount(id, false, false) -- matching what the
    merchant restock compares against, so the list agrees with what would
    actually be bought.
]]
function ns.BuildGroceryList()
	return BuildShortRows(true)
end

--[[
    Do the bags hold fewer of this row's item than its Keep amount? The test
    behind both lists above, asked of one row: the Restock window marks every
    short row, not only the ones a merchant would be asked for, so a row the
    bank is meant to fill is marked too.

    Bags only and counted by itemID like the list above, so a row this calls
    short with Buy on is always an order there. A row with no itemID is never
    short, since nothing can buy it. A Keep of 0 asks for nothing and is
    never short; with Store on it sends the whole stock to the bank.
]]
function ns.IsRestockItemShort(record)
	local wanted = record.amount or 0
	local itemID = record.itemID
	return itemID ~= nil and wanted > 0 and (C_Item.GetItemCount(itemID, false, false) or 0) < wanted
end

--[[
    The grocery list's length and how many rows are short at all, Buy or not,
    in one pass and without building either list: the window's status line asks
    on every redraw and every bag change while it is open. Counts by the same
    rules as ns.BuildGroceryList and ns.IsRestockItemShort, so the three always
    agree: short is ns.BuildRestockShortfallList's length.
]]
function ns.CountRestockOrders(restockList)
	local orders, short = 0, 0
	for _, record in pairs(restockList) do
		if ns.IsRestockItemShort(record) then
			short = short + 1
			if record.buyFromMerchant == nil or record.buyFromMerchant then
				orders = orders + 1
			end
		end
	end
	return orders, short
end

--------------------------------------------------------------------------------
-- After A Visit
--------------------------------------------------------------------------------

--[[
    Leaving a merchant or a bank is the last moment you can still do something
    about a short list, so both close handlers (Restocker-Merchant.lua and
    Restocker-Bank-State.lua) report what is left on the way out. Silent when nothing
    is low or out -- a report with nothing in it is just noise.

    The short delay is for bag counts. Bank moves settle on BAG_UPDATE, which can
    land after the window closes; reading the shortfall on the same frame would
    count items you are already holding as missing. A merchant's buys are waited
    out before this is called (ns.AfterMerchantBuysLand), and the delay then
    covers the last of their bag updates.
]]
local SETTLE_DELAY = 0.3

function ns.RemindRestockShortfallAfterVisit(enabled, mode)
	if not enabled then
		return
	end
	C_Timer.After(SETTLE_DELAY, function()
		local out, low = ns.BuildRestockReminderLists()
		if #out == 0 and #low == 0 then
			return
		end
		ns.PrintRestockShortfall(ns.RestockClosingHeadline(#out, #low), mode, out, low)
	end)
end
