local _, ns = ...
local L = ns.L

--[[
    The "New" group: items added this sitting, on this list. Never saved. Cleared,
    with the Undo row and a selected New group, when the window or Staples closes
    and on every list event, including the delete and copy that skip
    ns.UseRestockList.
]]
ns.restockNewItems = {}

function ns.ClearRestockNewItems()
	wipe(ns.restockNewItems)
	ns.restockLastRemoved = nil
	if ns.restockSelectedGroup == ns.RESTOCK_GROUP_NEW then
		ns.ClearRestockGroupSelection()
	end
end

--------------------------------------------------------------------------------
-- Item Lookups
--------------------------------------------------------------------------------

-- Adds parked on a cold item, keyed by itemID.
ns.restockItemWait = {}

-- Rows the open window drew before their item resolved, keyed by itemID; emptied when it hides.
ns.restockColdRows = {}

--[[
    GET_ITEM_INFO_RECEIVED floods during login, so it is heard only while one of
    the four queues waits. Call after adding to any of them.
]]
function ns.SyncRestockItemInfoSubscription()
	local waiting = next(ns.restockItemWait) ~= nil
		or ns.HasPendingUpgrade()
		or ns.HasPendingStarterAdds()
		or next(ns.restockColdRows) ~= nil

	if waiting then
		ns.RequestItemInfoEvents("restocker")
	else
		ns.ReleaseItemInfoEvents("restocker")
	end
end

function ns.OnRestockerItemInfoReceived(itemID, success)
	if success == nil then
		return
	end

	-- First, or every retry below is still told the item is missing.
	ns.ForgetItemDataMiss(itemID)

	-- A parked add is told rather than retried, which would only park it again.
	if success == false then
		ns.DropFailedUpgradeTarget(itemID)
		ns.DropPendingStarterAdd(itemID)
		if ns.restockItemWait[itemID] then
			ns.restockItemWait[itemID] = nil
			ns.ShowRestockAddNotice(string.format(L["RESTOCKER_UNKNOWN_ITEM"], itemID))
		end
	end

	if ns.restockColdRows[itemID] then
		ns.restockColdRows[itemID] = nil
		ns.RepaintRestockRows(itemID)
	end

	if ns.restockItemWait[itemID] then
		ns.restockItemWait[itemID] = nil
		ns.AddRestockItem(itemID)
	end

	if ns.HasPendingUpgrade() then
		ns.UpgradeRestockList()
	end

	if ns.HasPendingStarterAdds() then
		ns.RetryPendingStarterAdds()
	end

	ns.SyncRestockItemInfoSubscription()
end

--------------------------------------------------------------------------------
-- Adding An Item
--------------------------------------------------------------------------------

function ns.AddRestockItem(text)
	local settings = ns.restockSettings
	local currentList = settings.lists[settings.currentList]

	if type(text) == "string" and text:match("^%s*$") then
		return
	end

	if tonumber(text) then
		text = tonumber(text)
	end

	-- An ID with no item is never answered, so parking it would hold the event all session.
	if type(text) == "number" and not C_Item.DoesItemExistByID(text) then
		ns.ShowRestockAddNotice(string.format(L["RESTOCKER_UNKNOWN_ITEM"], text))
		return
	end

	local itemInfo = ns.GetItemData(text)
	if itemInfo == nil then
		--[[
		    Parked under the numeric itemID the event hands back, never a raw link.
		    Input with no itemID can never be answered, so it gets a notice instead
		    of holding the event all session.
		]]
		local waitKey = text
		if type(text) == "string" then
			waitKey = tonumber(text:match("item:(%d+)"))
		end
		if waitKey == nil then
			ns.ShowRestockAddNotice(L["RESTOCKER_ADD_NOT_FOUND"])
			return
		end
		ns.restockItemWait[waitKey] = true
		ns.SyncRestockItemInfoSubscription()
		return
	end

	local itemID = itemInfo.itemID

	-- Said, since a dropped item has already left the cursor.
	if currentList[itemID] ~= nil then
		ns.ShowRestockAddNotice(L["RESTOCKER_ADD_DUPLICATE"])
		return
	end

	local buyItem = {}

	buyItem.itemName = itemInfo.itemName
	buyItem.itemID = itemID
	-- One stack, not one unit: a single juice reads as a typo. Non-stacking items land at 1.
	buyItem.amount = math.max(1, itemInfo.itemStackCount or 1)
	buyItem.buyFromMerchant = true
	buyItem.stashToBank = true
	buyItem.restockFromBank = true

	currentList[itemID] = buyItem

	ns.restockNewItems[itemID] = true
	--[[
	    New is selected, not All: a row that vanished from the shown category on
	    adding would look lost, and New shows it alone at the top.
	]]
	ns.restockSelectedGroup = ns.RESTOCK_GROUP_NEW

	ns.UpdateRestockList()

	local scrollFrame = ns.restockWindow and ns.restockWindow.scrollFrame
	if scrollFrame then
		scrollFrame:SetVerticalScroll(0)
	end
end

--------------------------------------------------------------------------------
-- Removing An Item
--------------------------------------------------------------------------------

--[[
    The removed row, drawn grayed in place with Undo. One step deep; dropped on
    the next change to the list, filter or category, with the New flags, and when
    Staples opens.
]]
ns.restockLastRemoved = nil

function ns.RemoveRestockItem(item)
	if not (item and item.itemID) then
		return false
	end
	local settings = ns.restockSettings
	settings.lists[settings.currentList][item.itemID] = nil
	ns.restockLastRemoved = { item = item, listName = settings.currentList }
	ns.UpdateRestockList()
	return true
end

function ns.ForgetRestockRemoval()
	if not ns.restockLastRemoved then
		return
	end
	ns.restockLastRemoved = nil
	if ns.restockWindow and ns.restockWindow:IsShown() then
		ns.UpdateRestockList()
	end
end

--[[
    Quietly refused when the list is gone or holds the item again (added back by
    hand, the newer intent). Either way the offer is spent.
]]
function ns.UndoRestockRemove()
	local removed = ns.restockLastRemoved
	ns.restockLastRemoved = nil
	if not removed then
		return
	end

	local list = ns.restockSettings.lists[removed.listName]
	if list and list[removed.item.itemID] == nil then
		list[removed.item.itemID] = removed.item
	end
	ns.UpdateRestockList()
end
