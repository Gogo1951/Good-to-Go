local ADDON_NAME, ns = ...
local L = ns.L

local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

-- Also shown whenever no food icon resolves.
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_Food_02"

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

-- A click no menu row names (Left-Click) opens and holds the menu, or closes it when a click holds it.
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
    OnEnter rather than OnTooltipShow: every LDB display calls it on hover.
    The menu closes itself once the cursor leaves, so there is no OnLeave.
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

-- After ns.db exists, so LibDBIcon gets the saved button position.
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

-- Only the LDB object's icon is set: LibDBIcon and every LDB display redraw from it.
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

-- The position is account-wide (ns.db.global.minimap), so a profile switch never moves it.
function ns:ApplyMinimapButton()
	if not (ns.db and ns.minimapIconRegistered) then
		return
	end
	LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
end
