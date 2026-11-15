local _, ns = ...
local L = ns.L

--[[
    The controls that fill the Restock List grid: the Keep box, the remove
    button and its undo, and the pooled rows holding them. The toggle cells
    and the reputation cell are Restocker-Window-Cells.lua, which loads first.

    The grid itself -- column definitions, widths and shared colors -- is
    Restocker-Window-Columns.lua, which loads first, and its header
    Restocker-Window-Column-Header.lua. The reputation and column
    menus are Restocker-Window-Menus.lua, and the render loop that lays these rows
    out is Restocker-Window-Render.lua.
]]
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

--[[
    Zebra stripe alpha. Deliberately faint: the row already carries quality-colored
    item names and gold check glyphs, and a stripe strong enough to notice on its own
    competes with both. It only has to make the eye's path across seven cells hold
    its line.
]]
local ROW_STRIPE_ALPHA = 0.045

--[[
    An item carried onto a row is being dropped on the list, not aimed at the
    control under it, so every control on a row hands the cursor to the add path
    (ns.AddRestockItemFromCursor in Restocker-Window-Widgets.lua) and acts as itself only
    when the cursor holds no item. This is the drag-release half; each click
    handler makes the same call first.
]]
local function TakeCursorItem()
	ns.AddRestockItemFromCursor()
end

-- The cells' drop handler too (Restocker-Window-Cells.lua).
ns.TakeRestockCursorItem = TakeCursorItem

--[[
    A Keep amount is yellow while the bags hold fewer: the grocery list's line
    not yet crossed off. ns.IsRestockItemShort (Restocker-Shortfall.lua) is the
    test, so the mark goes by the same bag count the merchant restock and the
    orders under the list do -- and by nothing else: a row with Buy off, which
    the bank is meant to fill, is just as short until it has been. The orders
    count under the list is drawn in the same yellow (Restocker-Window-Footer.lua).
]]
local function PaintKeep(editBox, item)
	local tone = ns.IsRestockItemShort(item) and KEEP_SHORT or WHITE
	editBox:SetTextColor(tone.r, tone.g, tone.b)
end

ns.PaintRestockKeep = PaintKeep

--[[
    The Keep box: how many of this item the list keeps in the bags. The caller
    places it and sets its width, since the row lays its controls out from the
    right edge inward and this one hangs off the leftmost column.
]]
local function CreateAmountEditBox(frame)
	local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")

	editBox:SetHeight(ns.restockButtonHeight - 2)
	editBox:SetAutoFocus(false)
	--[[
	    Digits only, and every read still falls back to 0: item.amount is compared
	    against bag counts by the bank restock loop, where a nil target throws and
	    aborts the whole run.
	]]
	editBox:SetNumeric(true)
	editBox:SetMaxLetters(ns.RESTOCK_KEEP_MAX_DIGITS)
	--[[
	    Both handlers read self.item, rebound by ns.UpdateRestockListRow like every
	    other row control -- never GetParent().item, which can point at another
	    item once the row is reused, and removal then fails silently.
	]]
	--[[
	    An emptied box is a slip, not a 0: leaving it (Enter, a click away,
	    Escape) puts back the amount it held when it took focus, saved and
	    painted as usual. Typing 0 still means store all of it at the bank.
	    Hooked, not set, so the template's own focus handling still runs.
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
			--[[
			    Saved as the player types, so closing the window without
			    pressing Enter keeps what the box holds. An empty box saves
			    nothing: leaving it puts the old amount back (above). The
			    amount is live from here, so its mark and the count under the
			    list follow it.
			]]
			if self:GetText() == "" then
				return
			end
			self.item.amount = tonumber(self:GetText()) or 0
			PaintKeep(self, self.item)
			ns.UpdateRestockStatus()
		end
	end)
	--[[
	    An item carried onto the box joins the list, like one dropped anywhere
	    else on the window. The click that dropped it also focused the box, and
	    the redraw may have handed the box a different row, so the focus goes.
	]]
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

--[[
    A remove redraws the list at once, so by a double-click's second click the
    pooled button under the cursor belongs to the next row. A remove this soon
    after the last one is that second click, and is ignored.
]]
local DOUBLE_CLICK_GUARD_SECONDS = 0.4
local lastRemoveTime = -math.huge

-- Reads self.item, which UpdateRestockListRow rebinds like every other row control, never GetParent().item.
local function OnDeleteButtonClick(self)
	-- An item carried onto the button is being dropped on the list, not aimed at this row.
	if ns.AddRestockItemFromCursor() then
		return
	end

	local now = GetTime()
	if now - lastRemoveTime < DOUBLE_CLICK_GUARD_SECONDS then
		return
	end

	-- The list write and its undo live with the other list edits (ns.RemoveRestockItem in Restocker-List.lua).
	if ns.RemoveRestockItem(self.item) then
		lastRemoveTime = now
	end
end

--[[
    The group-loot pass mark is the game's own "get rid of this" icon, and the
    same texture the options panels' item lists (Kit.ItemList, Options/Options-Kit.lua)
    use for their remove column -- so removal looks the same everywhere. Never a
    UIPanelCloseButton: its red X reads as "close the window" on a row, and its
    30px frame is mostly transparent padding.

    The highlight is the normal texture blended additively rather than a separate
    file, which glows on hover without depending on a second art path.
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

function ns.CreateRestockListRow(item)
	--[[
	    Born parented to the hidden frame and positioned by ns.UpdateRestockList, which
	    places every row by absolute index rather than chaining them to each other.
	]]
	local frame = CreateFrame("Frame", nil, ns.restockHiddenFrame)
	frame:SetSize(ns.restockWindow.scrollChild:GetWidth(), ns.restockRowHeight)
	frame.item = item

	--[[
	    The stripe belongs to the POSITION, not the item: rows come from a pool and
	    are reused at whatever index the next render puts them at, so every row owns
	    a stripe and ns.UpdateRestockList decides which ones show.
	]]
	local stripe = frame:CreateTexture(nil, "BACKGROUND")
	stripe:SetAllPoints(frame)
	stripe:SetColorTexture(WHITE.r, WHITE.g, WHITE.b, ROW_STRIPE_ALPHA)
	frame.stripe = stripe

	-- ICON, with an invisible button over it that shows the item tooltip on hover
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", frame, "LEFT", ROW_INSET, 0)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim the default icon border
	frame.icon = icon

	-- RIGHT EDGE: the remove control, then the columns walking left from it.
	frame.removeButton = CreateDeleteButton(frame)
	frame.cells, frame.firstCell = LayoutColumns(frame.removeButton, function(column)
		if column.isText then
			return CreateReputationCell(frame, column)
		end
		return CreateGlyphCell(frame, column)
	end)

	-- The Keep box hangs off the leftmost column, beside the name it belongs to.
	frame.amountBox = CreateAmountEditBox(frame)
	frame.amountBox:SetPoint("RIGHT", frame.firstCell, "LEFT", -KEEP_GAP, 0)
	frame.amountBox:SetWidth(ns.restockAmountWidth)

	--[[
	    ITEM NAME fills whatever the controls leave. Anchored on both sides with no
	    word wrap, so a long name truncates instead of running under the Keep box.
	]]
	local text = frame:CreateFontString(nil, "OVERLAY", nil)
	text:SetFontObject("GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(false)
	text:SetPoint("LEFT", icon, "RIGHT", ICON_TEXT_GAP, 0)
	text:SetPoint("RIGHT", frame.amountBox, "LEFT", -NAME_COLUMN_GAP, 0)
	frame.text = text

	--[[
	    The icon and the name together are the row's tooltip target: a FontString
	    takes no mouse, so an invisible button covers both. It shows the item
	    tooltip, and takes an item dropped on it like the rest of the window does;
	    there is nothing else for a row click to open.
	]]
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
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		-- Prefer the cached colored link; fall back to a bare item: link (always valid)
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

--[[
    The client's name for the item whenever it has one, written onto the row so the
    filter and the sort read it too. Returns the client's item data, or nil while
    it loads, when the row shows the loading placeholder instead.
]]
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
	-- Every control carries its own item rather than resolving through a parent.
	row.removeButton.item = item
	row.amountBox.item = item
	for _, cell in pairs(row.cells) do
		cell.item = item
	end

	--[[
	    Column widths can resolve after a row was built (see
	    ns.RefreshRestockColumnHeader), so re-read them here rather than only at
	    creation -- the Keep box's too, since the item name stops at its left
	    edge. Guarded on a serial, which makes this seven SetWidth calls once and
	    a single comparison thereafter.
	]]
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

	-- Icon + quality-colored name from the item cache, or the loading placeholder until it is known
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

	row.text:SetText(info and item.itemName or string.format(L["LOADING_ITEM"], item.itemID))
	row.amountBox:SetText(tostring(item.amount or 0))
	PaintKeep(row.amountBox, item)
end
