local _, ns = ...

--------------------------------------------------------------------------------
-- Menus and Drops
--------------------------------------------------------------------------------

-- The kit menu and the bag pullout: each closes the others as it opens, and the window's hide closes all.
function ns.CloseRestockMenus()
	ns.CloseReputationMenu()
	ns.CloseRestockColumnMenu()
	ns.CloseRestockListMenus()
	ns.CloseRestockManageMenu()
	ns.CloseRestockBagMenu()
end

-- The cursor is cleared either way: a duplicate left on it would read as a missed drop.
function ns.AddRestockItemFromCursor()
	local infoType, _, itemLink = GetCursorInfo()
	if infoType ~= "item" then
		return false
	end
	ns.AddRestockItem(itemLink)
	ClearCursor()
	return true
end

-- A click or drag that brings an item drops it on the list; onClick runs only for an empty-handed click.
function ns.SetRestockControlClick(control, onClick, script)
	control:SetScript(script or "OnClick", function(...)
		if not ns.AddRestockItemFromCursor() and onClick then
			onClick(...)
		end
	end)
	control:SetScript("OnReceiveDrag", function()
		ns.AddRestockItemFromCursor()
	end)
end

--------------------------------------------------------------------------------
-- Menu Fields
--------------------------------------------------------------------------------

--[[
    Read-only (keyboard off, focus bounced), so it draws as a field and acts as
    a button; why not an AceGUI Dropdown is in Restocker-Window-List-Bar.lua.
    The arrow is UIDropDownMenuTemplate's own textures, so it reads as a menu.
]]
function ns.CreateRestockMenuField(parent, arrowSize, onToggle)
	local field = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	field:SetAutoFocus(false)
	field:EnableKeyboard(false)
	field:SetScript("OnEditFocusGained", function(self)
		self:ClearFocus()
	end)
	ns.SetRestockControlClick(field, onToggle, "OnMouseDown")

	local arrow = CreateFrame("Button", nil, field)
	arrow:SetSize(arrowSize, arrowSize)
	arrow:SetPoint("RIGHT", field, "RIGHT", -4, 0)
	arrow:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	arrow:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	arrow:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	ns.SetRestockControlClick(arrow, function()
		onToggle(field)
	end)
	field.arrow = arrow
	return field
end

--------------------------------------------------------------------------------
-- Tooltips
--------------------------------------------------------------------------------

--[[
    Colors are passed explicitly: SetText defaults to gold and AddLine to white,
    so leaving them out swaps title and body. The trailing `true` is textWrap,
    so the client breaks lines at its own width, correct even in locales
    without spaces; nothing hand-measures a width.
]]
local TOOLTIP_TITLE = ns.COLORS_RGB.TITLE
local TOOLTIP_BODY = ns.COLORS_RGB.TEXT

function ns.ShowRestockerTooltip(owner, title, ...)
	ns.SetTooltipOwner(owner)
	GameTooltip:SetText(title, TOOLTIP_TITLE.r, TOOLTIP_TITLE.g, TOOLTIP_TITLE.b, 1, true)
	for i = 1, select("#", ...) do
		if i > 1 then
			GameTooltip:AddLine(" ") -- blank line between each pair, none under the title
		end
		GameTooltip:AddLine((select(i, ...)), TOOLTIP_BODY.r, TOOLTIP_BODY.g, TOOLTIP_BODY.b, true)
	end
	GameTooltip:Show()
end

function ns.SetupRestockerTooltip(control, title, ...)
	local body = { ... }
	control:SetScript("OnEnter", function(self)
		ns.ShowRestockerTooltip(self, title, unpack(body))
	end)
	control:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end
