local _, ns = ...

--------------------------------------------------------------------------------
-- Grocery List
--------------------------------------------------------------------------------

-- have and wanted ride along for the reminders' low/out split and Verbose lines.
local function BuildShortRows(buyOnly)
	local settings = ns.restockSettings
	local restockList = settings and settings.lists and settings.lists[settings.currentList]
	local list = {}
	if not restockList then
		return list
	end

	for _, record in pairs(restockList) do
		-- Nil means on, as ns.RestockFromMerchant reads it.
		local buys = record.buyFromMerchant == nil or record.buyFromMerchant
		if ns.IsRestockItemShort(record) and (buys or not buyOnly) then
			local have = C_Item.GetItemCount(record.itemID, false, false) or 0
			-- Sorted by the client's name, not a saved one gone stale.
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

-- Buy on or off, as the window marks them: a row the bank should fill still counts when the bank had none.
function ns.BuildRestockShortfallList()
	return BuildShortRows(false)
end

-- Diagnostics' shopping list: with no vendor, there is no reputation gate and no reagents, which depend on one.
function ns.BuildGroceryList()
	return BuildShortRows(true)
end

-- Bags only, by item ID. A Keep of 0 asks for nothing, so it is never short (with Store, it banks everything).
function ns.IsRestockItemShort(record)
	local wanted = record.amount or 0
	local itemID = record.itemID
	return itemID ~= nil and wanted > 0 and (C_Item.GetItemCount(itemID, false, false) or 0) < wanted
end

-- One pass, building no list: the status line asks on every redraw and bag change while the window is open.
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
    Bank moves settle on BAG_UPDATE, which can land after the window closes, so
    a same-frame read would count items already held as missing. A merchant's
    buys are waited out first (ns.AfterMerchantBuysLand).
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
