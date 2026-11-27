local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Icon Checkbox Widget
--------------------------------------------------------------------------------

--[[
    The stock checkbox sets its label a pixel off the image, which crowds an
    item icon, and AceConfig has no setting for the gap. So this is the stock
    widget re-registered under our own name (the shared CheckBox type stays
    untouched), its label re-placed each time the stock code places it: on
    image set, press and release. A skin hooks the stock constructor, so these
    rows are still skinned.

    A toggle wears it with image, imageCoords (ns.OPTIONS_ICON_TEXCOORDS) and
    dialogControl (ns.ICON_CHECKBOX_WIDGET_TYPE).
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
    With no stock checkbox the name is cleared so a toggle asks for no control:
    AceConfigDialog errors on every repaint for a type it cannot create.
]]
if AceGUI.WidgetRegistry and AceGUI.WidgetRegistry.CheckBox then
	AceGUI:RegisterWidgetType(ns.ICON_CHECKBOX_WIDGET_TYPE, IconCheckBoxConstructor, ICON_CHECKBOX_WIDGET_VERSION)
else
	ns.ICON_CHECKBOX_WIDGET_TYPE = nil
end
