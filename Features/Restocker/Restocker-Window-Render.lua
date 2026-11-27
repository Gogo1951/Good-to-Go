local _, ns = ...
local L = ns.L

local PaintKeep = ns.PaintRestockKeep
local RefreshItemName = ns.RefreshRestockItemName

local restockItemList = {}

-- Kept from the render, so a column menu's "every item shown" is exactly what the player sees.
local shownItems = {}

-- Read-only for callers.
function ns.GetRestockShownItems()
	return shownItems
end

--------------------------------------------------------------------------------
-- Update
--------------------------------------------------------------------------------

-- Only what the bags decide: a full redraw would close an open menu for nothing.
function ns.RefreshRestockShortfall()
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse then
			PaintKeep(row.amountBox, row.item)
		end
	end
	ns.UpdateRestockStatus()
end

-- Use Restock List Food & Water Last reads the list's members, so a change asks for a macro rebuild.
local lastListName
local lastListMembers = {}

local function ListMembershipChanged(listName, list)
	local changed = listName ~= lastListName
	local count = 0
	for itemID in pairs(list) do
		count = count + 1
		if not lastListMembers[itemID] then
			changed = true
		end
	end
	for _ in pairs(lastListMembers) do
		count = count - 1
	end
	if not changed and count == 0 then
		return false
	end

	lastListName = listName
	wipe(lastListMembers)
	for itemID in pairs(list) do
		lastListMembers[itemID] = true
	end
	return true
end

-- Item names are left out, since the client fills them in as they load.
local function ListSignature(list)
	local parts = { tostring(ns.restockListFilter or ""), tostring(ns.restockSelectedGroup or "") }
	local itemIDs = {}
	for itemID in pairs(list) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)
	for _, itemID in ipairs(itemIDs) do
		local fields = {}
		for key, value in pairs(list[itemID]) do
			if key ~= "itemName" and type(value) ~= "table" then
				fields[#fields + 1] = key .. "=" .. tostring(value)
			end
		end
		table.sort(fields)
		parts[#parts + 1] = itemID .. ":" .. table.concat(fields, ",")
	end
	return table.concat(parts, "|")
end

function ns.RepaintRestockRows(itemID)
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse and row.item and row.item.itemID == itemID then
			ns.UpdateRestockListRow(row, row.item)
		end
	end
end

function ns.UpdateRestockList()
	--[[
	    Rows are about to rebind: a reputation pick would land on another item, a
	    column menu's count goes stale, and the bag menu offers what the list lacked.
	]]
	ns.CloseReputationMenu()
	ns.CloseRestockColumnMenu()
	ns.CloseRestockBagMenu()

	local settings = ns.restockSettings
	local currentList = settings.lists[settings.currentList]

	local removed = ns.restockLastRemoved
	if removed and removed.signature and removed.signature ~= ListSignature(currentList) then
		ns.restockLastRemoved, removed = nil, nil
	end

	-- Every list edit redraws through here.
	if ListMembershipChanged(settings.currentList, currentList) and ns.db.profile.useRestockLast then
		ns.RequestUpdate()
	end

	local watchColdRows = ns.restockWindow and ns.restockWindow:IsShown()
	local wasWatching = next(ns.restockColdRows) ~= nil
	wipe(ns.restockColdRows)
	wipe(restockItemList)
	for _, item in pairs(currentList) do
		if not RefreshItemName(item) and watchColdRows then
			ns.restockColdRows[item.itemID] = true
		end
		table.insert(restockItemList, item)
	end
	if wasWatching ~= (next(ns.restockColdRows) ~= nil) then
		ns.SyncRestockItemInfoSubscription()
	end

	-- The removed row is drawn in place but counts in no category and no column menu.
	local removedItem = removed
		and removed.listName == settings.currentList
		and currentList[removed.item.itemID] == nil
		and removed.item
	local drawList = restockItemList
	if removedItem then
		drawList = { unpack(restockItemList) }
		drawList[#drawList + 1] = removedItem
	end
	local view = ns.BuildRestockView(drawList)
	ns.UpdateRestockGroupPane(restockItemList, view)
	local renderList = ns.BuildRestockRenderList(drawList, view)

	--[[
	    A Keep box drops its item and focus first, or the next keystroke would set
	    another item's amount; the box now showing the typed item takes focus back
	    below, cursor at the end, so the next digit adds on.
	]]
	local typingItem
	for _, row in ipairs(ns.restockRowPool) do
		if row.amountBox:HasFocus() then
			typingItem = row.amountBox.item
			row.amountBox:ClearFocus()
		end
		row.amountBox.item = nil
		row.isInUse = false
		row:SetParent(ns.restockHiddenFrame)
		row:Hide()
	end

	local scrollChild = ns.restockWindow.scrollChild
	local offset = 0
	-- A late column measurement lands here first; the rows pick it up below.
	ns.RefreshRestockColumnHeader()
	wipe(shownItems)
	for index, item in ipairs(renderList) do
		local row = ns.AcquireRestockListRow(item)

		if item ~= removedItem then
			shownItems[#shownItems + 1] = item
		end
		row.isInUse = true
		row:SetParent(scrollChild)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -offset)
		row:SetSize(scrollChild:GetWidth(), ns.restockRowHeight)
		-- Every second row, counting the first as bare so the list starts flush.
		row.stripe:SetShown(index % 2 == 0)
		ns.UpdateRestockListRow(row, item)
		row:Show()
		if typingItem and item == typingItem then
			row.amountBox:SetFocus()
			row.amountBox:HighlightText(0, 0)
			row.amountBox:SetCursorPosition(#row.amountBox:GetText())
		end
		offset = offset + ns.restockRowHeight
	end

	scrollChild:SetHeight(math.max(1, offset))

	-- A list with items showing none says why: the filter, or a category just emptied.
	local nothingShown = nil
	if #renderList == 0 and #restockItemList > 0 then
		nothingShown = view.filter and L["RESTOCKER_NO_MATCH_FILTER"] or L["RESTOCKER_NO_MATCH_GROUP"]
	end
	-- The last item's removed row holds the list open, so its Undo stays in reach.
	ns.UpdateRestockEmptyState(#restockItemList == 0 and not removedItem, nothingShown)
	ns.UpdateRestockStatus()
	if ns.restockLastRemoved then
		ns.restockLastRemoved.signature = ListSignature(currentList)
	end
end

--------------------------------------------------------------------------------
-- Row Pool
--------------------------------------------------------------------------------

function ns.AcquireRestockListRow(item)
	for _, frame in ipairs(ns.restockRowPool) do
		if not frame.isInUse then
			return frame
		end
	end
	return ns.CreateRestockListRow(item)
end
