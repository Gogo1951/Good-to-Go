local _, ns = ...
local L = ns.L
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS
local ReputationTooltipBody = ns.RestockReputationTooltipBody

--[[
    Header and rows must line up exactly, so their widths, gaps and colors are
    defined once here and one layout walk places both. Loads after
    Restocker-Window-Reputation.lua.
]]

--------------------------------------------------------------------------------
-- Row Metrics
--------------------------------------------------------------------------------

--[[
    Controls measure the font they draw with, so a larger UI font or a longer
    locale word widens them instead of clipping. These starting values are what
    the stock font measures to.
]]
ns.restockRowHeight = 32
ns.restockButtonHeight = 22

-- Shared with the category pane so the two halves can't drift apart.
ns.RESTOCK_BUTTON_FONT = "GameFontNormal"
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local BUTTON_PAD_X = 16 -- caption to button edge, both sides together
local BUTTON_PAD_Y = 8
local BUTTON_MIN_WIDTH = 32
local ROW_PAD_Y = 4 -- breathing room above and below the tallest control
local ROW_MIN_HEIGHT = 32 -- the row's floor, on the spacing scale; a larger font grows it past

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
	-- 0 before the font resolves; 14 gives the stock 22px button.
	if not lineHeight or lineHeight <= 0 then
		return 14
	end
	return lineHeight
end

--------------------------------------------------------------------------------
-- Columns
--------------------------------------------------------------------------------

--[[
    A column is as wide as its caption; the item name absorbs the rest. The
    `group` band is load-bearing, not taste: "Take" and "Store" are exact only
    under "Bank", and six full captions leave the name about 58 pixels at the
    minimum width.

    Never hide a row's state behind an expander: the list must read at a glance.
    A body line naming game records is a function, not a key.
]]
local COLUMNS = {
	{
		key = "withdraw",
		caption = "RESTOCKER_COLUMN_WITHDRAW",
		group = "BANK",
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
		group = "MERCHANT",
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
		-- Text, not a glyph: five states, not two.
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

local COLUMN_GAP = 4 -- between columns inside a group
local COLUMN_GROUP_GAP = 16 -- where the grouping changes
local COLUMN_PAD_X = 8 -- caption to column edge, both sides together
local COLUMN_MIN_WIDTH = 24

--[[
    Keep (the row's `amount`) is measured against its caption and four digits in
    ChatFontNormal, the larger font the box draws in. Four digits is what a
    hunter's ammo needs; the padding is wider for the template's border art.
]]
ns.restockAmountWidth = 44
ns.RESTOCK_KEEP_MAX_DIGITS = 4
local AMOUNT_DIGITS_SAMPLE = string.rep("8", ns.RESTOCK_KEEP_MAX_DIGITS)
local AMOUNT_BOX_FONT = "ChatFontNormal"
local AMOUNT_BOX_PAD_X = 16 -- digits to box edge, both sides together

-- English starting widths until the font resolves; cells chain off each other, so SetWidth reflows the row.
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

local digitsFontString

local function MeasureDigitsFontString()
	if not digitsFontString then
		digitsFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", AMOUNT_BOX_FONT)
		digitsFontString:Hide()
	end
	return digitsFontString
end

-- Nil while the font is unresolved.
local function MeasureColumns()
	local fontString = MeasureFontString()
	local widths = {}
	for _, column in ipairs(COLUMNS) do
		fontString:SetText(L[column.caption])
		local width = fontString:GetStringWidth() or 0
		if column.isText then
			-- Its widest value too: "Rep" is three letters, "Exalted" seven.
			for _, standing in ipairs(REPUTATION_STANDINGS) do
				fontString:SetText(ns.GetStandingLabel(standing.value))
				local standingWidth = fontString:GetStringWidth() or 0
				if standingWidth > width then
					width = standingWidth
				end
			end
		end
		if width <= 0 then
			return nil -- the next list refresh measures again
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

-- Cached: the strings never change after load, and header and every row cell ask.
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

-- Measures on every list refresh until the font resolves; a no-op after.
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

function ns.RefreshRestockRowMetrics()
	local line = FontLineHeight()
	ns.restockButtonHeight = math.max(22, math.ceil(line + BUTTON_PAD_Y))
	ns.restockRowHeight = math.max(ROW_MIN_HEIGHT, ns.restockButtonHeight + ROW_PAD_Y)
	-- The group bands' line over the 16 caption tier (Restocker-Window-Column-Header.lua).
	ns.restockColumnHeaderHeight = 32
	ResolveColumns()
end

ns.restockColumnHeaderHeight = 32

local function FitButton(button)
	local fontString = button:GetFontString()
	if not fontString then
		return
	end
	local width = fontString:GetStringWidth()
	if not width or width <= 0 then
		return -- font unresolved; keeps its width
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

    Keep sits beside the name: it defines the row and turns yellow when short,
    so it belongs where the eye already is. Cells anchor to neighbors, never a
    fixed x.
]]
local REMOVE_ICON_SIZE = 16
-- The row's inset from both its edges: the icon on the left, this on the right.
local ROW_INSET = 16

local ICON_SIZE = 20
local ICON_TEXT_GAP = 8
local NAME_INSET = ROW_INSET + ICON_SIZE + ICON_TEXT_GAP
local NAME_COLUMN_GAP = 8 -- name to the Keep box

local REMOVE_GAP = 8 -- last column to the remove control

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

--[[
    Off is a dash, not blank: a row reads as answers, the target shows before
    hover, and not-applicable (a dimmer dash, no clicks) stays a different fact.
    The grays are this window's own states, not palette roles.
]]
local GOLD = ns.COLORS_RGB.TITLE
local WHITE = ns.COLORS_RGB.TEXT
local WINDOW_COLORS = ns.RESTOCKER_WINDOW_COLORS

local DASH_OFF = ns.HexToRGB(WINDOW_COLORS.DASH_OFF)
local DASH_NOT_APPLICABLE = ns.HexToRGB(WINDOW_COLORS.DASH_NOT_APPLICABLE)
local KEEP_SHORT = ns.HexToRGB(WINDOW_COLORS.KEEP_SHORT)

local CELL_HIGHLIGHT = "Interface\\Buttons\\UI-Listbox-Highlight2"
local CELL_HIGHLIGHT_ALPHA = 0.30
local REPUTATION_SET = ns.HexToRGB(WINDOW_COLORS.REPUTATION_SET) -- amber, to stand out

-- The one walk rows and header share, so a column can't sit in two places. Returns the leftmost cell.
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
