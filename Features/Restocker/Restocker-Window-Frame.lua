local _, ns = ...

--------------------------------------------------------------------------------
-- Window Frame
--------------------------------------------------------------------------------

--[[
    Shared by the Restock List and Staples, matching the Spellbook's window.
    Parented to UIParent and anchored by the caller, so nothing Blizzard owns is
    written to.

      title     TITLE_HEIGHT across the top, the frame's own title bar
      header    CONTROLS_HEIGHT under it, from clear of the portrait
                (CONTROLS_LEFT) to the frame's right
      body      an inset from under the header to the footer
      footer    FOOTER_HEIGHT along the bottom, inside FRAME_BORDER
]]
ns.RESTOCK_WINDOW_BANDS = {
	TITLE_HEIGHT = 24,
	CONTROLS_HEIGHT = 32,
	CONTROLS_LEFT = 64,
	FOOTER_HEIGHT = 32,
	FRAME_BORDER = 4,
	INSET_LEFT = 4, -- the portrait frame's border, as ButtonFrameTemplate places its own inset
	INSET_RIGHT = 4,
}

local BANDS = ns.RESTOCK_WINDOW_BANDS

-- Shared by the list bar and the status line on the footer row.
ns.RESTOCK_FOOTER_X = 16

ns.RESTOCK_HEADER_CENTER_Y = -(BANDS.TITLE_HEIGHT + BANDS.CONTROLS_HEIGHT / 2)

-- A client without the portrait template gets the plain frame and no portrait.
function ns.CreateRestockerPortraitFrame(name, title)
	local template = ns.HasTemplate("PortraitFrameTemplate") and "PortraitFrameTemplate" or "BasicFrameTemplate"
	local frame = CreateFrame("Frame", name, UIParent, template)
	local text = ns.MenuKit.WindowTitle(title)
	if frame.SetTitle then
		frame:SetTitle(text)
	elseif frame.TitleText then
		frame.TitleText:SetText(text)
	end
	if frame.SetPortraitToAsset then
		frame:SetPortraitToAsset(ns.ICON_RESTOCKER)
	end
	return frame
end

-- noControls (Staples) puts the inset straight under the title bar.
function ns.CreateRestockerBodyInset(frame, noControls)
	local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
	local top = BANDS.TITLE_HEIGHT + (noControls and 0 or BANDS.CONTROLS_HEIGHT)
	inset:SetPoint("TOPLEFT", frame, "TOPLEFT", BANDS.INSET_LEFT, -top)
	inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BANDS.INSET_RIGHT, BANDS.FRAME_BORDER + BANDS.FOOTER_HEIGHT)
	return inset
end

local HEADER_BUTTON_HEIGHT = 22
local HEADER_BUTTON_PADDING = 32

function ns.CreateRestockerHeaderButton(parent, text)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetText(text)
	button:SetHeight(HEADER_BUTTON_HEIGHT)
	ns.FitRestockerHeaderButton(button)
	return button
end

-- A font not yet loaded at login measures 0, so a zero width is left alone rather than collapsing the button.
function ns.FitRestockerHeaderButton(button)
	local width = button:GetFontString() and button:GetFontString():GetStringWidth() or 0
	if width > 0 then
		button:SetWidth(width + HEADER_BUTTON_PADDING)
	end
end

--------------------------------------------------------------------------------
-- ElvUI
--------------------------------------------------------------------------------

-- ElvUI's Skins module is another add-on's API, so each call is guarded: a change there leaves default art, not a broken window.
function ns.ApplyRestockerElvUISkin(editBoxes, buttons, checkBoxes)
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if not skins then
		return
	end
	for _, box in ipairs(editBoxes or {}) do
		pcall(skins.HandleEditBox, skins, box)
	end
	for _, button in ipairs(buttons or {}) do
		pcall(skins.HandleButton, skins, button)
	end
	for _, checkBox in ipairs(checkBoxes or {}) do
		pcall(skins.HandleCheckBox, skins, checkBox)
	end
end
