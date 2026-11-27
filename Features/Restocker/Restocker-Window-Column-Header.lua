local _, ns = ...
local L = ns.L
local COLUMNS = ns.RESTOCK_COLUMNS
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local REMOVE_ICON_SIZE = ns.RESTOCK_REMOVE_ICON_SIZE
local COLUMN_MIN_WIDTH = ns.RESTOCK_COLUMN_MIN_WIDTH
local ROW_INSET = ns.RESTOCK_ROW_INSET
local NAME_INSET = ns.RESTOCK_NAME_INSET
local KEEP_GAP = ns.RESTOCK_KEEP_GAP
local GOLD = ns.RESTOCK_CELL_GOLD
local CELL_HIGHLIGHT = ns.RESTOCK_CELL_HIGHLIGHT
local CELL_HIGHLIGHT_ALPHA = ns.RESTOCK_CELL_HIGHLIGHT_ALPHA
local WINDOW_COLORS = ns.RESTOCKER_WINDOW_COLORS
local LayoutColumns = ns.LayoutRestockColumns
local ApplyColumnWidths = ns.ApplyRestockColumnWidths
local TooltipBody = ns.RestockColumnTooltipBody
local ResolveColumns = ns.ResolveRestockColumns
-- The caption tier's height: the header's 32 is this under the group bands' line.
local CAPTION_HEIGHT = 16
-- The space between the captions and the first row, in place of a rule; Restocker-Window.lua reserves it too.
local HEADER_GAP = 16
ns.RESTOCK_COLUMN_HEADER_GAP = HEADER_GAP

--------------------------------------------------------------------------------
-- Column Header
--------------------------------------------------------------------------------

--[[
    Headings take their band's tone, so Bank and Merchant part without a rule; a
    band's label is a step brighter than its captions, so it reads as their
    parent. Never INFO or ON (they mean interactive and on) or an item-quality
    color: these are chrome.
]]
local HEADER_CAPTION_UNGROUPED = ns.COLORS_RGB.TITLE -- Item, Keep, Upgrade

-- Each band's label is the client's own word for the window it belongs to (GAME NAMES).
local GROUP_TONE = {
	BANK = {
		text = BANK,
		label = ns.HexToRGB(WINDOW_COLORS.BANK_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.BANK_CAPTION),
	},
	MERCHANT = {
		text = MERCHANT,
		label = ns.HexToRGB(WINDOW_COLORS.MERCHANT_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.MERCHANT_CAPTION),
	},
}

--[[
    Derived from GROUP_TONE, so a band's captions and label can't drift apart.
    `gapBefore` without `group` closes a band, which is how Upgrade gets gold.
]]
local COLUMN_TONE = {}
local BAND_LABEL_TONE = {}
do
	local tone = HEADER_CAPTION_UNGROUPED
	for _, column in ipairs(COLUMNS) do
		if column.group then
			local band = GROUP_TONE[column.group]
			tone = (band and band.caption) or HEADER_CAPTION_UNGROUPED
			BAND_LABEL_TONE[column.key] = (band and band.label) or HEADER_CAPTION_UNGROUPED
		elseif column.gapBefore then
			tone = HEADER_CAPTION_UNGROUPED
		end
		COLUMN_TONE[column.key] = tone
	end
end

--[[
    Anchored to the scroll frame's top corners, so it shares the rows' right
    edge, which both lay out from; outside it, so it stays put while the list
    scrolls.
]]
function ns.CreateRestockColumnHeader(parent, scrollFrame)
	local header = CreateFrame("Frame", nil, parent)
	header:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 0, HEADER_GAP)
	header:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, HEADER_GAP)
	header:SetHeight(ns.restockColumnHeaderHeight)

	-- Its own frame, so the captions center as a row's cells do and the bands get the height above.
	local captionRow = CreateFrame("Frame", nil, header)
	captionRow:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
	captionRow:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
	captionRow:SetHeight(CAPTION_HEIGHT)

	local bandRow = CreateFrame("Frame", nil, header)
	bandRow:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
	bandRow:SetPoint("BOTTOMRIGHT", captionRow, "TOPRIGHT", 0, 0)
	header.bandRow = bandRow

	local function Caption(parentFrame, text, tone, width)
		local fontString = parentFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetFontObject(BUTTON_FONT)
		fontString:SetTextColor(tone.r, tone.g, tone.b)
		fontString:SetText(text)
		if width then
			fontString:SetWidth(width)
			fontString:SetJustifyH("CENTER")
		end
		return fontString
	end

	-- Holds the remove control's width, or every heading would sit one icon too far right.
	local removeSpacer = CreateFrame("Frame", nil, captionRow)
	removeSpacer:SetSize(REMOVE_ICON_SIZE, 1)
	removeSpacer:SetPoint("RIGHT", captionRow, "RIGHT", -ROW_INSET, 0)

	--[[
	    Buttons, since a FontString takes no mouse and a heading's hover explains
	    its column, which lets the cells be glyphs. Reputation isn't on or off, so
	    its heading only explains.
	]]
	local firstCell
	header.cells, firstCell = LayoutColumns(removeSpacer, function(column)
		local button = CreateFrame("Button", nil, captionRow)
		button:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, CAPTION_HEIGHT)
		local fontString = button:CreateFontString(nil, "OVERLAY")
		fontString:SetFontObject(BUTTON_FONT)
		local tone = COLUMN_TONE[column.key]
		fontString:SetTextColor(tone.r, tone.g, tone.b)
		fontString:SetText(L[column.caption])
		fontString:SetPoint("CENTER")

		if column.isText then
			ns.SetupRestockerTooltip(button, L[column.title], unpack(TooltipBody(column)))
			ns.SetRestockControlClick(button)
			return button
		end

		local body = { unpack(TooltipBody(column)) }
		body[#body + 1] = L["RESTOCKER_COLUMN_BULK_HINT"]
		ns.SetupRestockerTooltip(button, L[column.title], unpack(body))

		button:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
		local highlight = button:GetHighlightTexture()
		if highlight then
			highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
		end
		ns.SetRestockControlClick(button, function(self)
			ns.OpenRestockColumnMenu(column, self)
		end)
		return button
	end)

	local amount = CreateFrame("Button", nil, captionRow)
	amount:SetSize(ns.restockAmountWidth, CAPTION_HEIGHT)
	amount:SetPoint("RIGHT", firstCell, "LEFT", -KEEP_GAP, 0)
	Caption(amount, L["RESTOCKER_COLUMN_AMOUNT"], HEADER_CAPTION_UNGROUPED):SetPoint("CENTER")
	ns.SetupRestockerTooltip(amount, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])
	ns.SetRestockControlClick(amount)
	header.amountCaption = amount

	-- Each band anchors to its first and last columns, so it re-spans whenever they're re-measured.
	for i, column in ipairs(COLUMNS) do
		if column.group then
			-- `gapBefore` ends a band too, or Merchant would swallow the unlabeled Upgrade column.
			local last = column
			for j = i + 1, #COLUMNS do
				if COLUMNS[j].group or COLUMNS[j].gapBefore then
					break
				end
				last = COLUMNS[j]
			end
			local band = Caption(header, GROUP_TONE[column.group].text, BAND_LABEL_TONE[column.key])
			band:SetJustifyH("CENTER")
			band:SetPoint("LEFT", header.cells[column.key], "LEFT", 0, 0)
			band:SetPoint("RIGHT", header.cells[last.key], "RIGHT", 0, 0)
			band:SetPoint("TOP", header, "TOP", 0, -1)
		end
	end

	local item = Caption(captionRow, L["RESTOCKER_COLUMN_ITEM"], HEADER_CAPTION_UNGROUPED)
	item:SetPoint("LEFT", captionRow, "LEFT", NAME_INSET, 0)

	ns.restockColumnHeader = header
	return header
end

-- Measures first if the font hadn't loaded when the window was built.
function ns.RefreshRestockColumnHeader()
	ResolveColumns()
	local header = ns.restockColumnHeader
	if header and header.cells then
		ApplyColumnWidths(header.cells)
		-- The Keep heading is not one of the laid-out cells, so it re-widths here.
		header.amountCaption:SetWidth(ns.restockAmountWidth)
	end
end
