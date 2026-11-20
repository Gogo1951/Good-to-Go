local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Status Line
--------------------------------------------------------------------------------

--[[
    (list controls) ...                                  Short on 7 items, 5 to buy.

    The right of the window's bottom line, under the list; its left holds the
    list controls (Restocker-Window-List-Bar.lua).

    At the right end is the answer the list exists to give: how many items
    the bags are short of, Buy on or off, and how many of those a merchant
    would be asked for (ns.RestockShortfallHeadline); with none to buy it says
    to take them from the bank. Hovering it lists every short item the way the
    mini-map's Restocker Report does -- icon, name, have/keep -- capped, so a
    long list cannot run the tooltip off the screen.

    The counts come from ns.CountRestockOrders and the tooltip from
    ns.BuildRestockShortfallList, so the two agree about what is short. The
    mini-map menu and the chat reminders list only what is low or out
    (ns.SplitRestockShortfall), so they can differ from this list: a row
    nearly topped off counts here and stays out of both. The line is drawn in
    the yellow of the Keep marks it counts (KEEP_SHORT in Data/Data.lua): it
    is where a player learns what a yellow Keep number means. Red is kept for
    errors, and being short of something is not one. The congratulation is
    kept for a list with no mark on it at all.

    An empty list says nothing here: the invitation in its place already does.

    Anchor footer controls to the row, never to the WINDOW: a control anchored
    to the window lands at its middle and disappears behind the list.
]]
local FOOTER_X = ns.RESTOCK_FOOTER_X
local FOOTER_RIGHT_INSET = 32 -- clear of the resize grip
local FOOTER_ROW_HEIGHT = 22
-- Centered in the window's footer band (ns.RESTOCK_WINDOW_BANDS), as the Spell Book's legend is.
local FOOTER_Y = ns.RESTOCK_WINDOW_BANDS.FRAME_BORDER + (ns.RESTOCK_WINDOW_BANDS.FOOTER_HEIGHT - FOOTER_ROW_HEIGHT) / 2

-- The most short items the hover lists one per row; past it, one closing line counts the rest.
local ORDERS_TOOLTIP_MAX_ROWS = 20

local TITLE = ns.COLORS_RGB.TITLE
-- The Keep marks' own color, as an escape for the orders count. Append |r at the point of use.
local SHORT = "|cff" .. ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT

--------------------------------------------------------------------------------
-- Orders Tooltip
--------------------------------------------------------------------------------

--[[
    An item as this line and its tooltip name one: its icon, then its name in
    its quality color, with no brackets (ns.GetItemLabel, which shows the
    loading placeholder while the cache is cold).
]]
local UNKNOWN_ICON = ns.QUESTION_MARK_ICON

local function ItemWithIcon(itemID)
	local icon = itemID and C_Item.GetItemIconByID(itemID) or UNKNOWN_ICON
	return string.format("|T%s:16:16|t %s", icon, ns.GetItemLabel(itemID))
end

--[[
    Every short item, Buy on or off, in the mini-map Restocker Report's row form
    under "Short Items": the item, then have/keep, the ratio the verbose
    reminder prints.

    Built on hover rather than kept, so it is as current as the bags are.
    Nothing to list draws no tooltip: the line above has already said so.
]]
local function ShowOrdersTooltip(owner)
	local groceries = ns.BuildRestockShortfallList()
	if #groceries == 0 then
		return
	end

	GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
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
			GetColor("MUTED") .. string.format(L["RESTOCKER_REPORT_MORE"], #groceries - ORDERS_TOOLTIP_MAX_ROWS) .. "|r"
		)
	end
	GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Status Text
--------------------------------------------------------------------------------

-- Every short row, Buy or not, as the rows' Keep marks show, and how many of them it buys.
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

--[[
    Repaint the line. Called at the end of every redraw, and on its own wherever
    the count can move without the rows moving: a Buy cell clicked, a Keep amount
    typed, the bags changing with the window open.

    The count's button is sized to its text, so the hover is over the words
    and not over the empty run of footer beside them. The "Used by" line on
    the left then ends short of it.
]]
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

	--[[
	    A button only so it can be hovered: a FontString takes no mouse. A click
	    does nothing but take an item dropped on it.
	]]
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
