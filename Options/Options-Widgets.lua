local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

--[[
    The AceGUI widget types the options panels use: an item row with its
    tooltip, and a checkbox with room for an item icon. Split from
    Options/Options-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Item Link Widget
--------------------------------------------------------------------------------

--[[
    A label that draws an item and shows that item's own tooltip on hover, used
    via dialogControl on the rows ns.BuildItemListOptions emits
    (Options-Item-Lists.lua). AceConfig renders a
    description as a plain Label, which has no mouse scripts at all and so never
    fires an OnEnter; this is that same widget with mouse handling, so the row
    can carry a real GameTooltip. The option's get returns the item id as a
    string and SetText resolves it through ns.GetItemDisplayName.
]]
local ITEM_LINK_WIDGET_VERSION = 1

local function OnItemLinkEnter(frame)
	local widget = frame.obj
	if not widget.itemID then
		return
	end
	--[[
	    The bare "item:id" form rather than the link off C_Item.GetItemInfo, so a row
	    still waiting on its item data gets a tooltip too -- and hovering it pulls
	    the very data the row is waiting for.
	]]
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:" .. widget.itemID)
	GameTooltip:Show()
end

local function OnItemLinkLeave()
	GameTooltip:Hide()
end

local itemLinkMethods = {}

function itemLinkMethods:OnAcquire()
	self.itemID = nil
	self:SetHeight(16)
end

function itemLinkMethods:OnRelease()
	self.itemID = nil
end

function itemLinkMethods:SetText(text)
	local itemID = tonumber(text)
	if itemID then
		self.itemID = itemID
		self.label:SetText(ns.GetItemDisplayName(itemID))
	else
		self.label:SetText(text or "")
	end
end

function itemLinkMethods:GetText()
	return self.itemID and tostring(self.itemID) or ""
end

-- AceConfigDialog drives every input control through these; a row is read-only.
function itemLinkMethods:SetLabel() end

function itemLinkMethods:SetMaxLetters() end

function itemLinkMethods:SetDisabled() end

local function ItemLinkWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetHeight(16)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnItemLinkEnter)
	frame:SetScript("OnLeave", OnItemLinkLeave)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT")
	label:SetPoint("BOTTOMRIGHT")

	local widget = {
		label = label,
		frame = frame,
		type = ns.ITEM_LINK_WIDGET_TYPE,
	}

	for method, func in pairs(itemLinkMethods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(ns.ITEM_LINK_WIDGET_TYPE, ItemLinkWidgetConstructor, ITEM_LINK_WIDGET_VERSION)

--------------------------------------------------------------------------------
-- Icon Checkbox Widget
--------------------------------------------------------------------------------

--[[
    The stock AceGUI checkbox with air between its icon and its label, for a
    toggle that stands for an item: a staple in the staples pop-up, a macro on
    the Consumable Macros panel. The stock widget sets the label a pixel off the image,
    which suits a status glyph and crowds an item icon, so these rows take the
    gap the Restock List's own rows put between an icon and its name.

    AceConfig has no setting for that gap, so this is a widget type of its own:
    the stock checkbox, built by the stock constructor and handed back with its
    label put where the row wants it every time the stock code places it --
    when the image is set, and on the press and the release, which nudge the
    label and put it back. It is registered under a name of ours, so the shared
    CheckBox type, and every other add-on's checkboxes, stay exactly as they
    were.

    A skin that restyles checkboxes does so as the stock constructor registers
    the widget, before it is renamed here, so these rows are skinned like any
    other checkbox.

    A toggle wears it with three fields: image (the item's icon), imageCoords
    (ns.OPTIONS_ICON_TEXCOORDS) and dialogControl (ns.ICON_CHECKBOX_WIDGET_TYPE).
]]
local ICON_CHECKBOX_WIDGET_VERSION = 1
local ICON_LABEL_GAP = ns.RESTOCK_ICON_TEXT_GAP
-- The stock press: the label a pixel right and a pixel down while the mouse is held.
local PRESS_NUDGE = 1

-- The stock icon border, cropped away so an icon sits clean beside its checkbox.
ns.OPTIONS_ICON_TEXCOORDS = { 0.08, 0.92, 0.08, 0.92 }

-- Only a row showing an icon: without one the label sits against the box, where the stock code left it.
local function PlaceIconLabel(widget, nudge)
	if widget.image:GetTexture() then
		widget.text:SetPoint("LEFT", widget.image, "RIGHT", ICON_LABEL_GAP + nudge, -nudge)
	end
end

local function IconCheckBoxConstructor()
	local widget = AceGUI.WidgetRegistry.CheckBox()
	widget.type = ns.ICON_CHECKBOX_WIDGET_TYPE

	local SetImage = widget.SetImage
	function widget:SetImage(...)
		SetImage(self, ...)
		PlaceIconLabel(self, 0)
	end
	-- Hooked, so each runs after the stock handler has placed the label its own way.
	widget.frame:HookScript("OnMouseDown", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, PRESS_NUDGE)
		end
	end)
	widget.frame:HookScript("OnMouseUp", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, 0)
		end
	end)
	return widget
end

--[[
    The name is cleared where there is no stock checkbox to build on, and a
    toggle then asks for no control of its own: AceConfigDialog reports a
    control type it cannot create as an error on every repaint before it falls
    back.
]]
if AceGUI.WidgetRegistry and AceGUI.WidgetRegistry.CheckBox then
	AceGUI:RegisterWidgetType(ns.ICON_CHECKBOX_WIDGET_TYPE, IconCheckBoxConstructor, ICON_CHECKBOX_WIDGET_VERSION)
else
	ns.ICON_CHECKBOX_WIDGET_TYPE = nil
end
