local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Status Line
--------------------------------------------------------------------------------

--[[
    Drawn in the Keep marks' yellow, so this is where a player learns what a
    yellow Keep means; red is kept for errors, and being short isn't one.
    Anchor footer controls to the row, never the window, or they land
    mid-window behind the list.
]]
local FOOTER_X = ns.RESTOCK_FOOTER_X
local FOOTER_RIGHT_INSET = 32 -- clear of the resize grip
local FOOTER_ROW_HEIGHT = 22
-- 8 up from the window's bottom edge, the Spacing Scale's step nearest the centered 9, level with the List row.
local FOOTER_Y = 8

-- The most short items the hover lists one per row; past it, one closing line counts the rest.
local ORDERS_TOOLTIP_MAX_ROWS = 20

local TITLE = ns.COLORS_RGB.TITLE
-- Append |r at the point of use.
local SHORT = "|cff" .. ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT

--------------------------------------------------------------------------------
-- Orders Tooltip
--------------------------------------------------------------------------------

local UNKNOWN_ICON = ns.QUESTION_MARK_ICON

local function ItemWithIcon(itemID)
	local icon = itemID and C_Item.GetItemIconByID(itemID) or UNKNOWN_ICON
	return string.format("|T%s:16:16|t %s", icon, ns.GetItemLabel(itemID))
end

-- Built on hover, so it is as current as the bags. Nothing to list draws no tooltip.
local function ShowOrdersTooltip(owner)
	local groceries = ns.BuildRestockShortfallList()
	if #groceries == 0 then
		return
	end

	ns.SetTooltipOwner(owner)
	GameTooltip:SetText(L["RESTOCKER_SHORT_ITEMS_TITLE"], TITLE.r, TITLE.g, TITLE.b)
	for index = 1, math.min(#groceries, ORDERS_TOOLTIP_MAX_ROWS) do
		local entry = groceries[index]
		GameTooltip:AddDoubleLine(
			ItemWithIcon(entry.itemID),
			GetColor("BODY") .. string.format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted) .. "|r"
		)
	end
	if #groceries > ORDERS_TOOLTIP_MAX_ROWS then
		GameTooltip:AddLine(
			GetColor("MUTED") .. string.format(L["LIST_MORE_SENTENCE"], #groceries - ORDERS_TOOLTIP_MAX_ROWS) .. "|r"
		)
	end
	GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Status Text
--------------------------------------------------------------------------------

local function StatusText(list)
	if next(list) == nil then
		return ""
	end

	local orders, short = ns.CountRestockOrders(list)
	if short > 0 then
		return SHORT .. ns.RestockShortfallHeadline(short, orders) .. "|r"
	end
	return GetColor("ON") .. L["MINIMAP_RESTOCKER_STOCKED"] .. "|r"
end

-- Sized to its text, so the hover sits on the words and the "Used by" line ends short of them.
function ns.UpdateRestockStatus()
	local window = ns.restockWindow
	local footer = window.footer
	local settings = ns.restockSettings

	local text = StatusText(settings.lists[settings.currentList])
	footer.statusText:SetText(text)
	footer.status:SetWidth(math.max(1, footer.statusText:GetStringWidth()))
	ns.SetRestockUsersLineEnd((text ~= "") and footer.status or nil)
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

function ns.CreateRestockWindowFooter(addonFrame)
	local footer = CreateFrame("Frame", nil, addonFrame)
	footer:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, FOOTER_Y)
	footer:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -FOOTER_RIGHT_INSET, FOOTER_Y)
	footer:SetHeight(FOOTER_ROW_HEIGHT)

	-- A button only so it can be hovered: a FontString takes no mouse.
	local status = CreateFrame("Button", nil, footer)
	status:SetPoint("RIGHT", footer, "RIGHT", 0, 0)
	status:SetHeight(FOOTER_ROW_HEIGHT)
	local statusText = status:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	statusText:SetPoint("RIGHT", status, "RIGHT", 0, 0)
	status:SetScript("OnEnter", ShowOrdersTooltip)
	status:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	ns.SetRestockControlClick(status)

	footer.status = status
	footer.statusText = statusText
	addonFrame.footer = footer
	return footer
end
