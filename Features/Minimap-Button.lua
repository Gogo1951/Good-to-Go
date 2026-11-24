local ADDON_NAME, ns = ...
local L = ns.L

local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

-- The button's icon before the first ns.UpdateMinimapIcon, and whenever no food icon resolves.
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_Food_02"

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

--[[
    Hovering opens the menu (Features/Minimap-Menu.lua). Right-Click runs the
    menu row that names it (Ignore, while there is a food to ignore). Any
    Left-Click opens and holds the menu, or closes it when a click holds it.
]]
function ns.HandleLauncherClick(self, button)
	if not ns.RunButtonClick(button) and button == "LeftButton" then
		ns.ShowMenu(self, nil, "click")
	end
end

function ns.HandleLauncherEnter(self)
	ns.ShowMenu(self, nil, "hover")
end

--------------------------------------------------------------------------------
-- LDB Launcher
--------------------------------------------------------------------------------

--[[
    A launcher, not a data source: it carries the icon and the clicks, no
    text. OnEnter rather than OnTooltipShow: LibDBIcon and every LDB display
    call it on hover, and the menu closes itself once the cursor leaves, so
    OnLeave has nothing to do.
]]
ns.dataBrokerObject = LibDataBroker:NewDataObject(ADDON_NAME, {
	type = "launcher",
	label = L["ADDON_TITLE"],
	icon = DEFAULT_ICON,
	OnClick = ns.HandleLauncherClick,
	OnEnter = ns.HandleLauncherEnter,
	OnLeave = function() end,
})

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- Called once at login, after ns.db exists, so LibDBIcon gets the saved button position.
function ns.RegisterMinimapIcon()
	if ns.dataBrokerObject and not ns.minimapIconRegistered then
		LibDBIcon:Register(ADDON_NAME, ns.dataBrokerObject, ns.db.global.minimap)
		ns.minimapIconRegistered = true

		--[[
		    On the Retail engine LibDBIcon leaves the square icon off-center in its ring.
		    Fitted by hand, not SetButtonIcon: its ResetButtonIcon calls icon:UpdateCoord(),
		    which errors when another add-on has replaced the button's icon.
		]]
		local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
		if (ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline") and button and button.icon then
			button.icon:SetSize(20, 20)
			button.icon:ClearAllPoints()
			button.icon:SetPoint("CENTER", 1, -0.35)
			local mask = button:CreateMaskTexture()
			mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
			mask:SetAllPoints(button.icon)
			button.icon:AddMaskTexture(mask)
		end
	end
end

--------------------------------------------------------------------------------
-- Icon
--------------------------------------------------------------------------------

--[[
    The button shows the food the Food macro will eat. Only the LDB object's
    icon is set: LibDBIcon and every LDB display redraw from it, so nothing
    here touches the button's texture. ns.RefreshSettings calls this, and so
    does the macro scan when it picks a new food.
]]
function ns.UpdateMinimapIcon()
	if not ns.dataBrokerObject then
		return
	end
	local iconID = ns.bestFoodID or ns.MACRO_DEFAULT_ITEM_IDS["Food"]
	ns.dataBrokerObject.icon = C_Item.GetItemIconByID(iconID) or DEFAULT_ICON
end

--------------------------------------------------------------------------------
-- Shown or Hidden
--------------------------------------------------------------------------------

--[[
    The one place the button shows or hides. LibDBIcon:Refresh reads `hide`
    from the saved table, which the Enable Mini-map Button toggle writes, and
    re-points the button at the current table. The position is account-wide
    (ns.db.global.minimap), so a profile switch never moves it.
]]
function ns:ApplyMinimapButton()
	if not (ns.db and ns.minimapIconRegistered) then
		return
	end
	LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
end
