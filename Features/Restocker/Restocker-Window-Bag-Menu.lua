local _, ns = ...
local L = ns.L
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Add Item From Bags
--------------------------------------------------------------------------------

-- Built on every open from the bags and the list in use, so nothing has to be kept in step with either.
local ARROW_SIZE = 16 -- the height of the row's fields
local MENU_WIDTH = 288 -- an icon and an item's whole name
local MENU_MAX_HEIGHT = 352 -- about twenty items, and the pullout scrolls past that
local UNKNOWN_ICON = ns.QUESTION_MARK_ICON -- the list's own stand-in for an icon it cannot name

--------------------------------------------------------------------------------
-- Items
--------------------------------------------------------------------------------

local function ItemsToAdd()
	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]

	local items = {}
	for _, item in ipairs(ns.GetRestockBagItems()) do
		if list[item.itemID] == nil then
			items[#items + 1] = item
		end
	end

	table.sort(items, function(a, b)
		local left, right = a.name or "", b.name or ""
		if left ~= right then
			return left < right
		end
		return a.itemID < b.itemID
	end)
	return items
end

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

--[[
    Built once and reused: an Execute item closes its own pullout from inside
    its OnClick, so items are cleared at the next open, never at close.
]]
local bagPullout
local bagPulloutOpen = false

local function CloseBagMenu()
	if bagPullout and bagPulloutOpen then
		bagPulloutOpen = false
		bagPullout:Close()
	end
end

ns.CloseRestockBagMenu = CloseBagMenu

local function OpenBagMenu(anchor)
	if not bagPullout then
		bagPullout = AceGUI:Create("Dropdown-Pullout")
		bagPullout:SetMaxHeight(MENU_MAX_HEIGHT)
		bagPullout:SetCallback("OnClose", function()
			bagPulloutOpen = false
		end)
		-- The kit plates a dropdown's pullout; this one stands alone and is never released, so it's plated once.
		ns.MenuKit.PlatePullout({ pullout = bagPullout })
	end
	bagPullout:Clear()
	-- A reused pullout keeps its scroll, and each open lists different items, so it starts at the top.
	bagPullout.slider:SetValue(0)

	local items = ItemsToAdd()
	for _, item in ipairs(items) do
		local entry = AceGUI:Create("Dropdown-Item-Execute")
		-- The pullout stays AceGUI's: it scrolls past MENU_MAX_HEIGHT, where the kit's menu doesn't.
		local name = ns.UnbracketItemLink(item.link)
		local carried = C_Item.GetItemCount(item.itemID, false, false) or 0
		local count = ns.MenuKit.Color("TEXT", string.format(L["ITEM_QUANTITY"], carried))
		entry:SetText(string.format("|T%s:0|t %s %s", item.icon or UNKNOWN_ICON, name, count)) -- the icon at line height
		entry:SetCallback("OnClick", function()
			ns.AddRestockItem(item.itemID)
		end)
		entry:SetCallback("OnEnter", function(widget)
			ns.SetTooltipOwner(widget.frame)
			if item.link then
				GameTooltip:SetHyperlink(item.link)
			else
				GameTooltip:SetItemByID(item.itemID)
			end
			GameTooltip:Show()
		end)
		entry:SetCallback("OnLeave", function()
			GameTooltip:Hide()
		end)
		bagPullout:AddItem(entry)
	end

	-- Still opens, on one line that can't be picked, so the click doesn't look broken.
	if #items == 0 then
		local nothing = AceGUI:Create("Dropdown-Item-Execute")
		nothing:SetText(L["RESTOCKER_ADD_FROM_BAGS_NONE"])
		nothing:SetDisabled(true)
		bagPullout:AddItem(nothing)
	end

	bagPulloutOpen = true
	bagPullout:SetWidth(MENU_WIDTH)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	bagPullout:Open("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

local function ToggleBagMenu(anchor)
	if bagPulloutOpen then
		CloseBagMenu()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()
	OpenBagMenu(anchor)
end

--------------------------------------------------------------------------------
-- Widget
--------------------------------------------------------------------------------

function ns.CreateRestockBagMenu(addonFrame, parent)
	local field = ns.CreateRestockMenuField(parent, ARROW_SIZE, ToggleBagMenu)

	--[[
	    White, as the filter's hint is (the maintainer's ruling): a menu reads as
	    something to open, where the add box's gray reads as somewhere to type.
	    No wrap, so a longer locale truncates before the arrow.
	]]
	local caption = field:CreateFontString(nil, "OVERLAY")
	caption:SetFontObject("GameFontHighlight")
	caption:SetPoint("LEFT", field, "LEFT", 4, 0)
	caption:SetPoint("RIGHT", field.arrow, "LEFT", -2, 0)
	caption:SetJustifyH("LEFT")
	caption:SetWordWrap(false)
	caption:SetText(L["RESTOCKER_ADD_FROM_BAGS"])
	field.caption = caption

	ns.SetupRestockerTooltip(field, L["RESTOCKER_ADD_FROM_BAGS"], L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"])

	addonFrame.bagMenu = field
	return field
end
