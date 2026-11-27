local _, ns = ...
local L = ns.L

-- Loads after Restocker-Window-Columns.lua and Restocker-Window-Cells.lua.
local COLUMNS = ns.RESTOCK_COLUMNS
local REMOVE_ICON_SIZE = ns.RESTOCK_REMOVE_ICON_SIZE
local ROW_INSET = ns.RESTOCK_ROW_INSET
local ICON_SIZE = ns.RESTOCK_ICON_SIZE
local ICON_TEXT_GAP = ns.RESTOCK_ICON_TEXT_GAP
local NAME_COLUMN_GAP = ns.RESTOCK_NAME_COLUMN_GAP
local KEEP_GAP = ns.RESTOCK_KEEP_GAP
local WHITE = ns.RESTOCK_CELL_WHITE
local KEEP_SHORT = ns.RESTOCK_CELL_KEEP_SHORT
local LayoutColumns = ns.LayoutRestockColumns
local ApplyColumnWidths = ns.ApplyRestockColumnWidths
local COLUMN_STATE = ns.RESTOCK_COLUMN_STATE
local SetCell = ns.SetRestockCell
local SetReputationCell = ns.SetRestockReputationCell
local CreateGlyphCell = ns.CreateRestockGlyphCell
local CreateReputationCell = ns.CreateRestockReputationCell

-- Faint on purpose: a stronger stripe competes with the quality colors and gold glyphs.
local ROW_STRIPE_ALPHA = 0.045
local UNDO_HEIGHT = 16
local KEEP_BOX_HEIGHT = 16 -- on the Spacing Scale, shorter than the row so it centers in it
local MUTED = ns.COLORS_RGB.MUTED

--[[
    An item carried onto any row control is dropped on the list, not aimed at
    the control. This is the drag-release half; click handlers make the same
    call first.
]]
local function TakeCursorItem()
	ns.AddRestockItemFromCursor()
end

ns.TakeRestockCursorItem = TakeCursorItem

-- Yellow while the bags hold fewer, by the merchant's own bag count; a Buy-off row is short too.
local function PaintKeep(editBox, item)
	local tone = ns.IsRestockItemShort(item) and KEEP_SHORT or WHITE
	editBox:SetTextColor(tone.r, tone.g, tone.b)
end

ns.PaintRestockKeep = PaintKeep

-- The caller places and sizes it.
local function CreateAmountEditBox(frame)
	local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")

	editBox:SetHeight(KEEP_BOX_HEIGHT)
	editBox:SetAutoFocus(false)
	-- Every read still falls back to 0: a nil amount would kill the bank run.
	editBox:SetNumeric(true)
	editBox:SetMaxLetters(ns.RESTOCK_KEEP_MAX_DIGITS)
	--[[
	    Handlers read self.item, never GetParent().item, which can name another
	    item once the row is reused.

	    An emptied box is a slip, not a 0: leaving it puts back the amount it had.
	    Typing 0 still means store it all. Hooked, so the template's focus
	    handling still runs.
	]]
	editBox:HookScript("OnEditFocusGained", function(self)
		self.amountBefore = self.item and self.item.amount
	end)
	editBox:HookScript("OnEditFocusLost", function(self)
		if self:GetText() ~= "" or not self.item then
			return
		end
		self.item.amount = self.amountBefore or self.item.amount or 0
		self:SetText(tostring(self.item.amount))
		PaintKeep(self, self.item)
		ns.UpdateRestockList()
	end)
	editBox:SetScript("OnEnterPressed", function(self)
		if self:GetText() == "" then
			self:ClearFocus() -- OnEditFocusLost puts the old amount back
			return
		end
		local amount = tonumber(self:GetText()) or 0

		if self.item then
			self.item.amount = amount
		end
		editBox:ClearFocus()
		self:SetText(tostring(amount))
		ns.UpdateRestockList()
		if ns.bankIsOpen then
			ns.StartRestockBankRun()
		end
	end)
	editBox:SetScript("OnKeyUp", function(self)
		if self.item then
			-- Saved per keystroke, so closing without Enter keeps it. An empty box saves nothing.
			if self:GetText() == "" then
				return
			end
			self.item.amount = tonumber(self:GetText()) or 0
			PaintKeep(self, self.item)
			ns.UpdateRestockStatus()
		end
	end)
	-- The drop's click focused the box, and the redraw may give it another row, so focus goes.
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	editBox:SetScript("OnMouseUp", TakeDroppedItem)
	editBox:SetScript("OnReceiveDrag", TakeDroppedItem)

	-- No "press Enter" line: OnKeyUp above has already saved the amount.
	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])

	return editBox
end

-- A remove redraws at once, so a double-click's second click would hit the next row's button.
local DOUBLE_CLICK_GUARD_SECONDS = 0.4
local lastRemoveTime = -math.huge

local function OnDeleteButtonClick(self)
	if ns.AddRestockItemFromCursor() then
		return
	end

	local now = GetTime()
	if now - lastRemoveTime < DOUBLE_CLICK_GUARD_SECONDS then
		return
	end

	if ns.RemoveRestockItem(self.item) then
		lastRemoveTime = now
	end
end

--[[
    The group-loot pass, as the options panels' item lists use, so removal looks
    the same everywhere. Never UIPanelCloseButton: its red X reads as "close the
    window", and its frame is mostly padding.
]]
local REMOVE_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local REMOVE_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

local function CreateDeleteButton(frame)
	local button = CreateFrame("Button", nil, frame)

	button:SetPoint("RIGHT", frame, "RIGHT", -ROW_INSET, 0)
	button:SetSize(REMOVE_ICON_SIZE, REMOVE_ICON_SIZE)
	button:SetNormalTexture(REMOVE_ICON)
	button:SetPushedTexture(REMOVE_ICON_DOWN)
	button:SetHighlightTexture(REMOVE_ICON, "ADD")
	button:SetScript("OnClick", OnDeleteButtonClick)
	button:SetScript("OnReceiveDrag", TakeCursorItem)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_REMOVE_TOOLTIP"], L["RESTOCKER_REMOVE_TOOLTIP_UNDO"])
	return button
end

local function CreateUndoButton(frame)
	local undo = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	undo:SetPoint("RIGHT", frame, "RIGHT", -ROW_INSET, 0)
	undo:SetHeight(UNDO_HEIGHT)
	undo:SetText(L["RESTOCKER_UNDO"])
	ns.SetRestockControlClick(undo, function()
		-- The click hides the button under the mouse, which would leave its tooltip up.
		GameTooltip:Hide()
		ns.UndoRestockRemove()
	end)
	ns.SetupRestockerTooltip(undo, L["RESTOCKER_UNDO_TOOLTIP"])
	ns.ApplyRestockerElvUISkin(nil, { undo })
	undo:Hide()
	return undo
end

function ns.CreateRestockListRow(item)
	local frame = CreateFrame("Frame", nil, ns.restockHiddenFrame)
	frame:SetSize(ns.restockWindow.scrollChild:GetWidth(), ns.restockRowHeight)
	frame.item = item

	-- The stripe belongs to the position, not the item, so the render decides which show.
	local stripe = frame:CreateTexture(nil, "BACKGROUND")
	stripe:SetAllPoints(frame)
	stripe:SetColorTexture(WHITE.r, WHITE.g, WHITE.b, ROW_STRIPE_ALPHA)
	frame.stripe = stripe

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", frame, "LEFT", ROW_INSET, 0)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim the default icon border
	frame.icon = icon

	frame.removeButton = CreateDeleteButton(frame)
	frame.undoButton = CreateUndoButton(frame)
	frame.cells, frame.firstCell = LayoutColumns(frame.removeButton, function(column)
		if column.isText then
			return CreateReputationCell(frame, column)
		end
		return CreateGlyphCell(frame, column)
	end)

	frame.amountBox = CreateAmountEditBox(frame)
	frame.amountBox:SetPoint("RIGHT", frame.firstCell, "LEFT", -KEEP_GAP, 0)
	frame.amountBox:SetWidth(ns.restockAmountWidth)

	-- No wrap, so a long name truncates before the Keep box.
	local text = frame:CreateFontString(nil, "OVERLAY", nil)
	text:SetFontObject("GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(false)
	text:SetPoint("LEFT", icon, "RIGHT", ICON_TEXT_GAP, 0)
	frame.text = text

	-- A FontString takes no mouse, so an invisible button over icon and name carries the tooltip.
	local nameButton = CreateFrame("Button", nil, frame)
	nameButton:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	nameButton:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", 0, 0)
	nameButton:SetScript("OnClick", TakeCursorItem)
	nameButton:SetScript("OnReceiveDrag", TakeCursorItem)
	nameButton:SetScript("OnEnter", function(button)
		local rowItem = frame.item
		if not (rowItem and rowItem.itemID) then
			return
		end
		ns.SetTooltipOwner(button)
		local info = ns.GetItemData(rowItem.itemID)
		GameTooltip:SetHyperlink((info and info.itemLink) or ("item:" .. rowItem.itemID))
		GameTooltip:Show()
	end)
	nameButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.nameButton = nameButton

	table.insert(ns.restockRowPool, frame)
	return frame
end

-- Written onto the row so the filter and sort read it too; nil while the item loads.
local function RefreshItemName(item)
	local info = ns.GetItemData(item.itemID)
	if info and info.itemName and info.itemName ~= "" then
		item.itemName = info.itemName
	end
	return info
end

ns.RefreshRestockItemName = RefreshItemName

function ns.UpdateRestockListRow(row, item)
	row.item = item
	row.removeButton.item = item
	row.amountBox.item = item
	for _, cell in pairs(row.cells) do
		cell.item = item
	end

	-- Widths can resolve after the row was built; the serial makes this one comparison after.
	if row.columnSerial ~= ns.restockColumnWidthSerial then
		row.columnSerial = ns.restockColumnWidthSerial
		row.amountBox:SetWidth(ns.restockAmountWidth)
		ApplyColumnWidths(row.cells)
	end

	for _, column in ipairs(COLUMNS) do
		if not column.isText then
			SetCell(row.cells[column.key], COLUMN_STATE[column.key](item))
		end
	end
	SetReputationCell(row.cells.reputation, item)

	local removed = ns.restockLastRemoved
	local isRemoved = removed ~= nil and removed.item == item
	for _, cell in pairs(row.cells) do
		cell:SetShown(not isRemoved)
	end
	row.amountBox:SetShown(not isRemoved)
	row.removeButton:SetShown(not isRemoved)
	row.undoButton:SetShown(isRemoved)
	row.icon:SetDesaturated(isRemoved)
	row.text:ClearAllPoints()
	row.text:SetPoint("LEFT", row.icon, "RIGHT", ICON_TEXT_GAP, 0)
	if isRemoved then
		-- A font unresolved at build time measures as nothing.
		ns.FitRestockButton(row.undoButton)
		row.text:SetPoint("RIGHT", row.undoButton, "LEFT", -NAME_COLUMN_GAP, 0)
	else
		row.text:SetPoint("RIGHT", row.amountBox, "LEFT", -NAME_COLUMN_GAP, 0)
	end

	local info = RefreshItemName(item)
	if info then
		row.icon:SetTexture(info.itemTexture)
		local quality = ITEM_QUALITY_COLORS[info.itemRarity or 1]
		if quality then
			row.text:SetTextColor(quality.r, quality.g, quality.b)
		else
			row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
		end
	else
		row.icon:SetTexture(ns.QUESTION_MARK_ICON)
		row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
	end

	local name = info and item.itemName or string.format(L["LOADING_ITEM"], item.itemID)
	if isRemoved then
		row.text:SetTextColor(MUTED.r, MUTED.g, MUTED.b)
		row.text:SetText(string.format(L["RESTOCKER_REMOVED_ITEM"], name))
		return
	end
	row.text:SetText(name)
	row.amountBox:SetText(tostring(item.amount or 0))
	PaintKeep(row.amountBox, item)
end
