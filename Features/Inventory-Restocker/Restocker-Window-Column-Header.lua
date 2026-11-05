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

--[[
    The header above the Restock List grid: the column captions, the Keep
    heading and the group bands, laid out by the same walk as the rows.

    The grid it is drawn on -- column definitions, widths and shared colors --
    is Restocker-Window-Columns.lua, which loads first.
]]

--------------------------------------------------------------------------------
-- Column Header
--------------------------------------------------------------------------------

--[[
    Column headings are colored by the band they belong to, so the eye can see
    where Bank stops and Merchant starts without a rule between them. The three
    columns in no band -- Item, Keep, Upgrade -- take the brand gold every
    other heading in the add-on already uses. Gold on the outside is what lets
    the two colored bands read as a pair set into ordinary chrome rather than as
    three groups competing with one another.

    Each band carries TWO tones: the brighter `label` for the band's own name,
    the softer `caption` for the column headings under it. That step down is what
    makes the label read as the parent of the columns it spans instead of as one
    more heading sitting in the same row as them.

    Neither band uses a brand color. ns.COLORS_RGB.INFO and .ON already mean
    something everywhere else -- interactive, and on -- and a static heading must
    not borrow it; the brand green directly above a column of on/off ticks reads
    as a state rather than as a label. They stay clear of the item-quality
    colors the list draws names in (uncommon 1eff00, rare 0070dd) for the same
    reason. These are chrome, and have to look like it.
]]
local HEADER_CAPTION_UNGROUPED = ns.COLORS_RGB.TITLE -- Item, Keep, Upgrade

local GROUP_TONE = {
	RESTOCKER_ROW_BANK = {
		label = ns.HexToRGB(WINDOW_COLORS.BANK_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.BANK_CAPTION),
	},
	RESTOCKER_ROW_MERCHANT = {
		label = ns.HexToRGB(WINDOW_COLORS.MERCHANT_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.MERCHANT_CAPTION),
	},
}

--[[
    Which tone each column's caption takes, and which its band label takes. A
    column carrying `group` opens a band and every column after it inherits that
    band's caption tone until the next boundary; `gapBefore` without a `group`
    closes the band and falls back to the ungrouped gold, which is how Upgrade,
    sitting alone after Merchant, gets its color.

    BAND_LABEL_TONE is keyed by the column that OPENS each band, because that is
    the key the band-drawing loop below already has in hand.

    Both are derived from GROUP_TONE rather than declared per column, so the Bank
    columns and the "Bank" label over them read from one entry and cannot drift
    apart. A band added to COLUMNS with no tone comes out gold rather than
    silently inheriting its neighbor's color.
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
    Anchored to the scroll frame's top corners so it inherits the same width and,
    crucially, the same RIGHT edge as the rows inside it -- rows are sized to the
    scroll frame, and both lay out from that edge. Nothing here knows an x
    coordinate.

    It sits outside the scroll frame rather than at the top of the list, so it
    stays put while the list scrolls under it.
]]
function ns.CreateRestockColumnHeader(parent, scrollFrame)
	local header = CreateFrame("Frame", nil, parent)
	header:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 0, 2)
	header:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, 2)
	header:SetHeight(ns.restockColumnHeaderHeight)

	local rule = header:CreateTexture(nil, "ARTWORK")
	rule:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
	rule:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
	rule:SetHeight(1)
	rule:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.20)

	--[[
	    The lower tier is its own frame so everything in it centers vertically by
	    itself, exactly the way a row does. The group bands then have the whole
	    remaining height above it and never have to be positioned against a
	    caption's baseline.
	]]
	local captionRow = CreateFrame("Frame", nil, header)
	captionRow:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 2)
	captionRow:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 2)
	captionRow:SetHeight(ns.restockButtonHeight)

	-- The upper tier, the rest of the height: the group bands' line, and the undo offer's (Restocker-Window-Footer.lua).
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

	--[[
	    A stand-in for the remove control, which has no caption but does take up the
	    width the rows give it. Without it every heading would sit one icon too far
	    right.
	]]
	local removeSpacer = CreateFrame("Frame", nil, captionRow)
	removeSpacer:SetSize(REMOVE_ICON_SIZE, 1)
	removeSpacer:SetPoint("RIGHT", captionRow, "RIGHT", -ROW_INSET, 0)

	--[[
	    Captions ride on buttons of their column's width: a FontString takes no
	    mouse, and hovering a heading has to give the same explanation as hovering a
	    cell under it. That is what lets the cells be glyphs instead of repeating
	    the words on every row.

	    A toggle column's heading also acts: a click offers to switch that column
	    on or off for every row shown (ns.OpenRestockColumnMenu in
	    Restocker-Window-Menus.lua), so its tooltip ends with a line saying so and
	    it lights on hover like the cells under it. Reputation names one of five
	    standings rather than on or off, so its heading only explains.
	]]
	local firstCell
	header.cells, firstCell = LayoutColumns(removeSpacer, function(column)
		local button = CreateFrame("Button", nil, captionRow)
		button:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)
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

	--[[
	    The Keep heading, over the box that leads the strip. A button for the same
	    reason the column headings are: it carries the box's own tooltip.
	]]
	local amount = CreateFrame("Button", nil, captionRow)
	amount:SetSize(ns.restockAmountWidth, ns.restockButtonHeight)
	amount:SetPoint("RIGHT", firstCell, "LEFT", -KEEP_GAP, 0)
	Caption(amount, L["RESTOCKER_COLUMN_AMOUNT"], HEADER_CAPTION_UNGROUPED):SetPoint("CENTER")
	ns.SetupRestockerTooltip(amount, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])
	ns.SetRestockControlClick(amount)
	header.amountCaption = amount

	--[[
	    GROUP BANDS

	    Each band anchors to the LEFT of its group's first column and the RIGHT of
	    its last, so it centers itself over exactly the columns it covers and
	    re-spans on its own whenever those columns are re-measured. No band is ever
	    told a width.

	    A column with no `group` (Upgrade) gets no band -- its own caption is
	    already the whole word.
	]]
	for i, column in ipairs(COLUMNS) do
		if column.group then
			--[[
			    A band runs until the next column STARTS one. `gapBefore` is that signal
			    as much as `group` is -- Upgrade opens its own band and carries no label,
			    so stopping only at the next labeled column would swallow it into
			    Merchant and draw "Merchant" over the Upgrade column.
			]]
			local last = column
			for j = i + 1, #COLUMNS do
				if COLUMNS[j].group or COLUMNS[j].gapBefore then
					break
				end
				last = COLUMNS[j]
			end
			local band = Caption(header, L[column.group], BAND_LABEL_TONE[column.key])
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

--[[
    Re-sync the header to the current column widths, measuring first if the
    font had not resolved when the window was built. Called from
    ns.UpdateRestockList, which is where a late measurement first shows up.
]]
function ns.RefreshRestockColumnHeader()
	ResolveColumns()
	local header = ns.restockColumnHeader
	if header and header.cells then
		ApplyColumnWidths(header.cells)
		-- The Keep heading is not one of the laid-out cells, so it re-widths here.
		header.amountCaption:SetWidth(ns.restockAmountWidth)
	end
end
