local _, ns = ...
local L = ns.L

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

-- buyFromMerchant and upgrade default on when nil, buyExtra off: a plain `not` reads the first two backward.
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
		-- The merchant run never reaches an item with Buy off, so Extra is not applicable, not off.
		if not (item.buyFromMerchant == nil or item.buyFromMerchant) then
			return CELL_NOT_APPLICABLE
		end
		return item.buyExtra and CELL_ON or CELL_OFF
	end,
	upgrade = function(item)
		-- An item with no ladder can't upgrade at all, which is not the same as choosing not to.
		if not ns.CanUpgradeRestockItem(item.itemID) then
			return CELL_NOT_APPLICABLE
		end
		return (item.upgrade ~= false) and CELL_ON or CELL_OFF
	end,
}

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
			item.buyFromMerchant = false
		else
			item.buyFromMerchant = not item.buyFromMerchant
		end
	end,
	extra = function(item)
		item.buyExtra = not item.buyExtra
	end,
	upgrade = function(item)
		if item.upgrade == nil then
			item.upgrade = false
		else
			item.upgrade = not item.upgrade
		end
	end,
}

local function AddCellHighlight(cell)
	cell:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
	end
end

-- A dead cell's tooltip gives this, since the column's explanation describes a switch the row lacks.
local NOT_APPLICABLE_REASON = {
	extra = "RESTOCKER_EXTRA_NOT_APPLICABLE",
	reputation = "RESTOCKER_REPUTATION_NOT_APPLICABLE",
	upgrade = "RESTOCKER_UPGRADE_NOT_APPLICABLE",
}

-- Alpha rather than Disable(): a dead cell still has to explain itself, and Disable() takes the tooltip too.
local function SetCellActive(cell, isActive)
	cell.isActive = isActive
	local tone = isActive and DASH_OFF or DASH_NOT_APPLICABLE
	cell.dash:SetColorTexture(tone.r, tone.g, tone.b, 1)
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetAlpha(isActive and 1 or 0)
	end
end

local function SetCell(cell, state)
	cell.check:SetShown(state == CELL_ON)
	cell.dash:SetShown(state ~= CELL_ON)
	SetCellActive(cell, state ~= CELL_NOT_APPLICABLE)
end

--[[
    No standing draws a dash, not "Any": a column of identical words buries the
    one row that sets one. With Buy off it is not applicable, since a standing
    only gates buying; the saved standing stays and shows again with Buy.
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
		-- self.item, never the row's: pooled rows rebind.
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
