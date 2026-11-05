local _, ns = ...
local L = ns.L
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS
local ReputationTooltipBody = ns.RestockReputationTooltipBody

--[[
    The grid the Restock List is drawn on: which columns exist, how wide each one
    has to be, and where every cell sits.

    Restocker-Window-Rows.lua builds the controls that fill this grid, and
    Restocker-Window-Column-Header.lua the header above it. The split is
    deliberate: the header and the rows have to line up exactly, so the widths,
    the gaps and the colors they share are defined once here, and the layout walk
    that places them is called by both. The reputation wording is
    Restocker-Window-Reputation.lua, which loads before this file.
]]

--------------------------------------------------------------------------------
-- Row Metrics
--------------------------------------------------------------------------------

--[[
    Nothing in a row carries a hardcoded size: a caption that outgrows its button
    is clipped, not wrapped. Every control measures the font it actually draws
    with, so a larger UI font, or a longer word in another locale, widens the
    control instead of overflowing it.

    ns.restockRowHeight and ns.restockButtonHeight start at the stock font's measurements
    and are recomputed by ns.RefreshRestockRowMetrics when the window is built. With the
    stock font the measurement lands back on exactly these numbers.
]]
ns.restockRowHeight = 26
ns.restockButtonHeight = 22

--[[
    A row is one line and shows everything about its item: its six toggles sit in
    fixed columns under a header that names them, five as lit or dim glyphs and
    Rep as its standing's text, so the list
    answers "which of these buy from vendors?" by being looked at. Never hide a
    row's state behind an expander -- with only the open row showing anything, the
    list needs a marker to say which rows are worth opening and a panel to say
    where an open one stops, and it still cannot be read at a glance.
]]
--[[
    The font every control in the window measures itself against, shared with the
    category pane so the two halves cannot drift apart. On ns rather than a
    file-local for that reason alone.
]]
ns.RESTOCK_BUTTON_FONT = "GameFontNormalSmall"
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local BUTTON_PAD_X = 16 -- caption to button edge, both sides together
local BUTTON_PAD_Y = 8
local BUTTON_MIN_WIDTH = 28
local ROW_PAD_Y = 4 -- breathing room above and below the tallest control

-- Scratch FontString used only to measure BUTTON_FONT; never shown.
local measureFontString

local function MeasureFontString()
	if not measureFontString then
		measureFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", BUTTON_FONT)
		measureFontString:Hide()
	end
	return measureFontString
end

local function FontLineHeight()
	local fontString = MeasureFontString()
	fontString:SetText("Wg")
	local lineHeight = fontString:GetStringHeight()
	--[[
	    GetStringHeight reads 0 before the font is resolved; fall back to the
	    height that produces today's 22px button.
	]]
	if not lineHeight or lineHeight <= 0 then
		return 14
	end
	return lineHeight
end

--------------------------------------------------------------------------------
-- Columns
--------------------------------------------------------------------------------

--[[
    One definition drives the header and every row, so the two cannot drift apart:
    each walks this list from the right edge inward, and a column is as wide as
    its own header caption. A longer word in another locale widens that column and
    takes the room out of the item name, which is the only thing on the row that
    can absorb it.

    `gapBefore` opens a wider space where the meaning changes, and `group` names
    the band of columns it opens, drawn once above them. That band is what buys
    the short captions: "Take" and "Store" would be vague on their own and are
    exact under "Bank", and the width they save is width the item name gets. Six
    full-length captions do not fit beside a readable name at the minimum window
    width (they leave the name about 58 pixels), so this is load-bearing, not taste.

    Every column carries its tooltip keys, so the header cell and the row cell
    explain themselves from one place. A body line that names game records is a
    function returning the finished line instead of a key.
]]
local COLUMNS = {
	{
		key = "withdraw",
		caption = "RESTOCKER_COLUMN_WITHDRAW",
		group = "RESTOCKER_ROW_BANK",
		title = "RESTOCKER_WITHDRAW_TOOLTIP_TITLE",
		body = { "RESTOCKER_WITHDRAW_TOOLTIP_BODY" },
	},
	{
		key = "deposit",
		caption = "RESTOCKER_COLUMN_DEPOSIT",
		title = "RESTOCKER_DEPOSIT_TOOLTIP_TITLE",
		body = { "RESTOCKER_DEPOSIT_TOOLTIP_BODY" },
	},
	{
		key = "buy",
		caption = "RESTOCKER_BUY_LABEL",
		group = "RESTOCKER_ROW_MERCHANT",
		title = "RESTOCKER_BUY_TOOLTIP_TITLE",
		body = { "RESTOCKER_BUY_TOOLTIP_BODY" },
		gapBefore = true,
	},
	{
		key = "extra",
		caption = "RESTOCKER_EXTRA_LABEL",
		title = "RESTOCKER_EXTRA_TOOLTIP_TITLE",
		body = { "RESTOCKER_EXTRA_TOOLTIP_STOCK" },
	},
	{
		--[[
		    The only column that draws text rather than a glyph: reputation has five
		    states, not two, so the cell has to name the one it is in.
		]]
		key = "reputation",
		caption = "RESTOCKER_COLUMN_REPUTATION",
		title = "RESTOCKER_REPUTATION_TOOLTIP_TITLE",
		body = { ReputationTooltipBody },
		isText = true,
	},
	{
		key = "upgrade",
		caption = "RESTOCKER_ROW_UPGRADE",
		title = "RESTOCKER_UPGRADE_TOOLTIP_TITLE",
		body = { "RESTOCKER_UPGRADE_TOOLTIP_BODY" },
		gapBefore = true,
	},
}

local COLUMN_GAP = 5 -- between columns inside a group
local COLUMN_GROUP_GAP = 12 -- where the grouping changes
local COLUMN_PAD_X = 8 -- caption to column edge, both sides together
local COLUMN_MIN_WIDTH = 24

--[[
    A starting width, replaced once the font resolves (see ResolveColumns).
    The Keep box -- the row's amount, which is the name the code and the saved
    rows still use for it -- is measured like every other column: against its
    own caption AND against a four-digit count, since the edit box under it has
    to hold what the caption names. A fixed width truncates a longer locale's
    heading, so this one is measured too.

    The count is measured in the font the box DRAWS in, not the captions': an
    InputBoxTemplate field writes in ChatFontNormal, a good deal larger than the
    heading font, and "Keep" is too short a caption to cover for the difference.
    Four digits is what a hunter's ammunition needs.
    The box's own padding is wider than a column's too: the template's border
    art sits inside its right edge.
]]
ns.restockAmountWidth = 44
local AMOUNT_DIGITS_SAMPLE = "8888"
local AMOUNT_BOX_FONT = "ChatFontNormal"
local AMOUNT_BOX_PAD_X = 14 -- digits to box edge, both sides together

--[[
    Starting widths are the English measurement, replaced once the font
    resolves (see ResolveColumns). Cells re-read them on every update (see
    UpdateRestockListRow), and because each cell is anchored to its
    neighbor's edge rather than to a fixed x, setting a new width is all it
    takes to reflow the whole chain.
]]
ns.restockColumnWidths = {
	withdraw = 38,
	deposit = 42,
	buy = 32,
	extra = 40,
	reputation = 54,
	upgrade = 60,
}
ns.restockColumnWidthSerial = 0 -- bumped when the widths change, so rows notice

local columnsResolved = false

-- Scratch FontString used only to measure the Keep box's own font; never shown.
local digitsFontString

local function MeasureDigitsFontString()
	if not digitsFontString then
		digitsFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", AMOUNT_BOX_FONT)
		digitsFontString:Hide()
	end
	return digitsFontString
end

-- Measure every column from its caption, or nil while the font is unresolved.
local function MeasureColumns()
	local fontString = MeasureFontString()
	local widths = {}
	for _, column in ipairs(COLUMNS) do
		fontString:SetText(L[column.caption])
		local width = fontString:GetStringWidth() or 0
		if column.isText then
			--[[
			    A text column has to hold its widest VALUE, not just its caption:
			    "Rep" is three letters and "Exalted" is seven.
			]]
			for _, standing in ipairs(REPUTATION_STANDINGS) do
				fontString:SetText(ns.GetStandingLabel(standing.value))
				local standingWidth = fontString:GetStringWidth() or 0
				if standingWidth > width then
					width = standingWidth
				end
			end
		end
		if width <= 0 then
			return nil -- font not resolved yet; the next list refresh measures again
		end
		widths[column.key] = math.max(COLUMN_MIN_WIDTH, math.ceil(width) + COLUMN_PAD_X)
	end

	fontString:SetText(L["RESTOCKER_COLUMN_AMOUNT"])
	local captionWidth = fontString:GetStringWidth() or 0
	local digits = MeasureDigitsFontString()
	digits:SetText(AMOUNT_DIGITS_SAMPLE)
	local digitsWidth = digits:GetStringWidth() or 0
	if captionWidth <= 0 or digitsWidth <= 0 then
		return nil
	end

	return widths,
		math.max(COLUMN_MIN_WIDTH, math.ceil(captionWidth) + COLUMN_PAD_X, math.ceil(digitsWidth) + AMOUNT_BOX_PAD_X)
end

--[[
    A column's tooltip body, resolved from its locale keys. Cached on the column:
    the strings never change after load, and both the header cell and every pooled
    row cell ask for the same list.
]]
local function TooltipBody(column)
	if not column.bodyText then
		local lines = {}
		for _, line in ipairs(column.body) do
			lines[#lines + 1] = type(line) == "function" and line() or L[line]
		end
		column.bodyText = lines
	end
	return column.bodyText
end

--[[
    Measure the column widths. Until the font resolves this measures again on
    every call (each list refresh makes one); a cheap no-op after that.
]]
local function ResolveColumns()
	if columnsResolved then
		return
	end
	local widths, amountWidth = MeasureColumns()
	if widths then
		ns.restockColumnWidths = widths
		ns.restockAmountWidth = amountWidth
		ns.restockColumnWidthSerial = ns.restockColumnWidthSerial + 1
		columnsResolved = true
	end
end

--[[
    Recompute the row and button heights from the font currently in use. Called
    when the window is built; safe to call again if a font add-on swaps fonts.
]]
function ns.RefreshRestockRowMetrics()
	local line = FontLineHeight()
	ns.restockButtonHeight = math.max(22, math.ceil(line + BUTTON_PAD_Y))
	ns.restockRowHeight = ns.restockButtonHeight + ROW_PAD_Y
	ns.restockColumnHeaderHeight = ns.restockButtonHeight + math.ceil(line) + 2
	ResolveColumns()
end

ns.restockColumnHeaderHeight = 38

--[[
    Size a button to the caption it is currently showing. The button keeps its
    anchor, so a row's controls chain from the right edge and simply push the
    item name's cutoff further left as they grow.
]]
local function FitButton(button)
	local fontString = button:GetFontString()
	if not fontString then
		return
	end
	local width = fontString:GetStringWidth()
	if not width or width <= 0 then
		return -- font not resolved yet; the button keeps the width it already has
	end
	button:SetWidth(math.max(BUTTON_MIN_WIDTH, math.ceil(width) + BUTTON_PAD_X))
	button:SetHeight(ns.restockButtonHeight)
end

ns.FitRestockButton = FitButton

--------------------------------------------------------------------------------
-- Row Shape
--------------------------------------------------------------------------------

--[[
    [icon] Item Name ....  [40]  [Take][Store]  [Buy][Extra][Rep]  [Upgrade] [x]

    The Keep box leads the strip, beside the name it belongs to. It is the one
    number that defines a row, and it turns yellow when the bags hold fewer, so it
    has to sit where the eye already is rather than six columns away.

    Everything right of it is laid out by walking COLUMNS from the remove
    control inward, which is exactly what the header does, so the two line up by
    construction rather than by matching offsets in two places. The Keep box
    then hangs off the leftmost column.

    Each cell anchors to its neighbor's edge, never to a fixed x. That is what
    lets a late column measurement reflow the row with nothing but SetWidth calls,
    and what lets the item name -- anchored on both sides -- absorb whatever the
    columns leave.
]]
local REMOVE_ICON_SIZE = 16
-- The row's inset from both its edges: the icon on the left, this on the right.
local ROW_INSET = 6

local ICON_SIZE = 18
local ICON_TEXT_GAP = 4
local NAME_INSET = ROW_INSET + ICON_SIZE + ICON_TEXT_GAP
local NAME_COLUMN_GAP = 10 -- name to the Keep box

local REMOVE_GAP = 6 -- last column to the remove control

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

--[[
    On is the game's own check glyph in the gold every other lit control uses. Off
    is a short dash rather than an empty cell, so a row reads as a row of answers
    instead of a row of holes, and so the click target is visible before it is
    hovered.

    Not-applicable is a third state, and it is the reason off cannot simply be
    blank: an item with no upgrade ladder and an item with upgrading switched off
    are different facts. It draws the same dash, dimmer, and takes no clicks.
]]
--[[
    Every lit control in the window is the palette's TITLE gold and every plain
    body string its TEXT white. The grays below are not palette roles: they are
    this window's own UI states, and each says something a palette color does not.
]]
local GOLD = ns.COLORS_RGB.TITLE
local WHITE = ns.COLORS_RGB.TEXT
local WINDOW_COLORS = ns.RESTOCKER_WINDOW_COLORS

local DASH_OFF = ns.HexToRGB(WINDOW_COLORS.DASH_OFF)
local DASH_NOT_APPLICABLE = ns.HexToRGB(WINDOW_COLORS.DASH_NOT_APPLICABLE)
local KEEP_SHORT = ns.HexToRGB(WINDOW_COLORS.KEEP_SHORT)

-- The hover highlight every clickable cell and toggle heading shares.
local CELL_HIGHLIGHT = "Interface\\Buttons\\UI-Listbox-Highlight2"
local CELL_HIGHLIGHT_ALPHA = 0.30
local REPUTATION_SET = ns.HexToRGB(WINDOW_COLORS.REPUTATION_SET) -- amber, to stand out

--[[
    Lay the cells out right to left from the remove control, and hand back the
    leftmost one, which the Keep box hangs off (ns.RESTOCK_KEEP_GAP). Used by both
    the rows and the header, which is the whole point: one walk, one set of gaps,
    so a column can never sit in two different places.
]]
local function LayoutColumns(anchorTo, build)
	local cells = {}
	local anchor = anchorTo
	local gap = REMOVE_GAP
	for i = #COLUMNS, 1, -1 do
		local column = COLUMNS[i]
		local cell = build(column)
		cell:SetPoint("RIGHT", anchor, "LEFT", -gap, 0)
		cells[column.key] = cell
		anchor = cell
		gap = column.gapBefore and COLUMN_GROUP_GAP or COLUMN_GAP
	end
	return cells, anchor
end

-- Push the current column widths into a set of cells. Cheap and idempotent.
local function ApplyColumnWidths(cells)
	for _, column in ipairs(COLUMNS) do
		local cell = cells[column.key]
		if cell then
			cell:SetWidth(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH)
		end
	end
end

--------------------------------------------------------------------------------
-- Shared With The Rows And The Header
--------------------------------------------------------------------------------

--[[
    The grid's surface for Restocker-Window-Rows.lua and Restocker-Window-Column-Header.lua.
    Everything else above is private to this file: the measurement and the resolved widths.
]]
ns.RESTOCK_COLUMNS = COLUMNS
ns.RESTOCK_REMOVE_ICON_SIZE = REMOVE_ICON_SIZE
ns.RESTOCK_COLUMN_MIN_WIDTH = COLUMN_MIN_WIDTH
ns.RESTOCK_ROW_INSET = ROW_INSET
ns.RESTOCK_ICON_SIZE = ICON_SIZE
ns.RESTOCK_ICON_TEXT_GAP = ICON_TEXT_GAP
ns.RESTOCK_NAME_COLUMN_GAP = NAME_COLUMN_GAP
ns.RESTOCK_NAME_INSET = NAME_INSET
ns.RESTOCK_KEEP_GAP = COLUMN_GROUP_GAP -- leftmost column to the Keep box
ns.RESTOCK_CELL_GOLD = GOLD
ns.RESTOCK_CELL_WHITE = WHITE
ns.RESTOCK_CELL_DASH_OFF = DASH_OFF
ns.RESTOCK_CELL_DASH_NOT_APPLICABLE = DASH_NOT_APPLICABLE
ns.RESTOCK_CELL_KEEP_SHORT = KEEP_SHORT
ns.RESTOCK_CELL_HIGHLIGHT = CELL_HIGHLIGHT
ns.RESTOCK_CELL_HIGHLIGHT_ALPHA = CELL_HIGHLIGHT_ALPHA
ns.RESTOCK_CELL_REPUTATION_SET = REPUTATION_SET
ns.LayoutRestockColumns = LayoutColumns
ns.ApplyRestockColumnWidths = ApplyColumnWidths
ns.RestockColumnTooltipBody = TooltipBody
ns.ResolveRestockColumns = ResolveColumns
