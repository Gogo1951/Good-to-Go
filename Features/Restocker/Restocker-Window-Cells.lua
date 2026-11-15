local _, ns = ...
local L = ns.L

--[[
    The Restock List grid's cells: each toggle column's state read off an item
    and flipped by a click, the reputation cell, how each is painted (on, off,
    or not applicable on its row), and their tooltips. Restocker-Window-Rows.lua
    builds them into its pooled rows and repaints them per item.
]]
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local COLUMN_MIN_WIDTH = ns.RESTOCK_COLUMN_MIN_WIDTH
local GOLD = ns.RESTOCK_CELL_GOLD
local DASH_OFF = ns.RESTOCK_CELL_DASH_OFF
local DASH_NOT_APPLICABLE = ns.RESTOCK_CELL_DASH_NOT_APPLICABLE
local REPUTATION_SET = ns.RESTOCK_CELL_REPUTATION_SET
local CELL_HIGHLIGHT = ns.RESTOCK_CELL_HIGHLIGHT
local CELL_HIGHLIGHT_ALPHA = ns.RESTOCK_CELL_HIGHLIGHT_ALPHA
local TooltipBody = ns.RestockColumnTooltipBody
local ReputationStandingByValue = ns.RestockReputationStandingByValue

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

local CELL_ON, CELL_OFF, CELL_NOT_APPLICABLE = "on", "off", "na"

local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local CHECK_SIZE = 16
local DASH_WIDTH = 8
local DASH_HEIGHT = 2

--[[
    Reading and writing one item flag per column, so a cell needs no knowledge of
    which one it is beyond its key.

    The nil defaults are load-bearing and differ per flag: buyFromMerchant and
    upgrade default ON when unset, buyExtra defaults OFF. A plain `not` on the
    first two would read nil as false and switch them on, which is backward.
]]
local COLUMN_STATE = {
	withdraw = function(item)
		return item.restockFromBank and CELL_ON or CELL_OFF
	end,
	deposit = function(item)
		return item.stashToBank and CELL_ON or CELL_OFF
	end,
	buy = function(item)
		return (item.buyFromMerchant == nil or item.buyFromMerchant) and CELL_ON or CELL_OFF
	end,
	extra = function(item)
		--[[
		    Extra rides on top of Buy: ns.RestockFromMerchant never reaches an item
		    with Buy off, so the cell says "not applicable" rather than "off".
		]]
		if not (item.buyFromMerchant == nil or item.buyFromMerchant) then
			return CELL_NOT_APPLICABLE
		end
		return item.buyExtra and CELL_ON or CELL_OFF
	end,
	upgrade = function(item)
		--[[
		    Only vendor-sold staples sit on a ladder; most of a real list cannot
		    upgrade at all, which is not the same as choosing not to.
		]]
		if not ns.CanUpgradeRestockItem(item.itemID) then
			return CELL_NOT_APPLICABLE
		end
		return (item.upgrade ~= false) and CELL_ON or CELL_OFF
	end,
}

-- Read by the column menus (Restocker-Window-Menus.lua), which set a column only where it applies.
ns.RESTOCK_COLUMN_STATE = COLUMN_STATE
ns.RESTOCK_CELL_NOT_APPLICABLE = CELL_NOT_APPLICABLE

local COLUMN_TOGGLE = {
	withdraw = function(item)
		item.restockFromBank = not item.restockFromBank
	end,
	deposit = function(item)
		item.stashToBank = not item.stashToBank
	end,
	buy = function(item)
		if item.buyFromMerchant == nil then
			item.buyFromMerchant = false -- nil defaults to true, so toggle to false
		else
			item.buyFromMerchant = not item.buyFromMerchant
		end
	end,
	extra = function(item)
		item.buyExtra = not item.buyExtra -- nil defaults to false
	end,
	upgrade = function(item)
		if item.upgrade == nil then
			item.upgrade = false -- nil defaults to true, so toggle to false
		else
			item.upgrade = not item.upgrade
		end
	end,
}

-- Attach the shared hover highlight used by every clickable cell.
local function AddCellHighlight(cell)
	cell:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
	end
end

--[[
    Why a cell cannot be set on its row, by column. A dead cell's tooltip says
    this in place of the column's general explanation, which would describe a
    switch the row does not have.
]]
local NOT_APPLICABLE_REASON = {
	extra = "RESTOCKER_EXTRA_NOT_APPLICABLE",
	reputation = "RESTOCKER_REPUTATION_NOT_APPLICABLE",
	upgrade = "RESTOCKER_UPGRADE_NOT_APPLICABLE",
}

--[[
    The part of a cell's state every column shares: whether it takes clicks, and
    the dash's tone. The cell's tooltip reads the same flag, to give the reason
    above in place of the column's explanation (SetupCellTooltip).

    Alpha rather than Disable() on the highlight: a dead cell still has to answer
    "why can this not be set?", and Disable() would take the tooltip away with the
    clicks.
]]
local function SetCellActive(cell, isActive)
	cell.isActive = isActive
	local tone = isActive and DASH_OFF or DASH_NOT_APPLICABLE
	cell.dash:SetColorTexture(tone.r, tone.g, tone.b, 1)
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetAlpha(isActive and 1 or 0)
	end
end

-- Paint a glyph cell for one of the three states.
local function SetCell(cell, state)
	cell.check:SetShown(state == CELL_ON)
	cell.dash:SetShown(state ~= CELL_ON)
	SetCellActive(cell, state ~= CELL_NOT_APPLICABLE)
end

--[[
    Paint the reputation cell. It names its standing only when one is set, in
    amber so a gated row stands out. With none it draws the dash every other
    column draws for off, rather than a word: "Any" is the absence of a
    requirement, and a column of thirty identical words buries the one row that
    sets one.

    It rides on Buy the way Extra does -- a standing only gates buying -- so with
    Buy off it is not applicable: the dimmer dash, and no menu. The standing
    itself stays on the row, and shows again when Buy comes back on.
]]
local function SetReputationCell(cell, item)
	local buys = item.buyFromMerchant == nil or item.buyFromMerchant
	local isSet = buys and (item.reaction or 0) > 0
	cell.text:SetShown(isSet)
	cell.dash:SetShown(not isSet)
	if isSet then
		cell.text:SetText(ns.GetStandingLabel(ReputationStandingByValue(item.reaction).value))
		cell.text:SetTextColor(REPUTATION_SET.r, REPUTATION_SET.g, REPUTATION_SET.b)
	end
	SetCellActive(cell, buys)
end

--[[
    A cell's tooltip: its column's title and explanation, or -- on a row where the
    cell cannot be set -- the title and the reason why not.
]]
local function SetupCellTooltip(cell, column)
	local reason = NOT_APPLICABLE_REASON[column.key]
	cell:SetScript("OnEnter", function(self)
		if reason and not self.isActive then
			ns.ShowRestockerTooltip(self, L[column.title], L[reason])
		else
			ns.ShowRestockerTooltip(self, L[column.title], unpack(TooltipBody(column)))
		end
	end)
	cell:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

local function CreateGlyphCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)

	local check = cell:CreateTexture(nil, "ARTWORK")
	check:SetTexture(CHECK_TEXTURE)
	check:SetSize(CHECK_SIZE, CHECK_SIZE)
	check:SetPoint("CENTER")
	check:SetVertexColor(GOLD.r, GOLD.g, GOLD.b)
	cell.check = check

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	local toggle = COLUMN_TOGGLE[column.key]
	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		-- Reads self.item, rebound by UpdateRestockListRow like every other control
		if not (self.isActive and self.item) then
			return
		end
		toggle(self.item)
		ns.UpdateRestockListRow(row, self.item)
		-- Buy decides whether a short row is an order, so the count under the list can move.
		ns.UpdateRestockStatus()
	end)
	cell:SetScript("OnReceiveDrag", ns.TakeRestockCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

--[[
    The reputation cell. A menu, not a toggle, so it names the standing it
    requires and opens the standings list on click. SetReputationCell above
    paints it.
]]
local function CreateReputationCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)
	cell.isActive = true

	local fontString = cell:CreateFontString(nil, "ARTWORK", BUTTON_FONT)
	fontString:SetPoint("CENTER")
	cell.text = fontString

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		if not (self.isActive and self.item) then
			return
		end
		ns.OpenRestockReputationMenu(self, row)
	end)
	cell:SetScript("OnReceiveDrag", ns.TakeRestockCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

ns.SetRestockCell = SetCell
ns.SetRestockReputationCell = SetReputationCell
ns.CreateRestockGlyphCell = CreateGlyphCell
ns.CreateRestockReputationCell = CreateReputationCell
