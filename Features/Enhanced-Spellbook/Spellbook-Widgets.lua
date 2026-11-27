local _, ns = ...
local TITLE, BODY, TEXT = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY, ns.COLORS_RGB.TEXT
local L = ns.L
local HasTemplate = ns.HasTemplate

local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local CONTROLS_LEFT = 64 -- clear of the portrait

-- Builds whose menus can't take a tooltip show the entry bare.
local function AddMenuTooltip(element, labelKey, descKey)
	if not element.SetTooltip then
		return
	end
	element:SetTooltip(function(tooltip)
		tooltip:SetText(L[labelKey], TITLE.r, TITLE.g, TITLE.b, 1, true)
		tooltip:AddLine(L[descKey], BODY.r, BODY.g, BODY.b, true)
	end)
end

--[[
	ElvUI's Skins module is another add-on's API, so each call is guarded: a change to it leaves a control in
	the default art instead of breaking the page.
]]
local function ApplyElvUISkin(page)
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if not skins then
		return
	end
	pcall(skins.HandleEditBox, skins, page.filterBox)
	for _, dropdown in ipairs({ page.filterButton, page.sortButton }) do
		if dropdown.SetupMenu then
			pcall(skins.HandleDropDownBox, skins, dropdown, dropdown:GetWidth())
		else
			pcall(skins.HandleButton, skins, dropdown)
		end
	end
	pcall(skins.HandleButton, skins, page.markPlaced)
end

-- Without the game's dropdown template, a plain button opens the same menu, labeled by the caller.
local function CreateDropdown(parent, width, setup)
	local dropdown
	if HasTemplate("WowStyle1DropdownTemplate") then
		dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		dropdown:SetWidth(width)
		ns.SetupKitDropdown(dropdown, setup)
	else
		dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		dropdown:SetSize(width, 22)
		dropdown:SetScript("OnClick", function(self)
			ns.MenuKit.OpenContextMenu(self, setup)
		end)
	end
	return dropdown
end

-- The hint is white, readable on either box art, and clears as soon as the box takes the cursor.
local function CreateFilterBox(page, hint, onChange)
	local filterBox
	if HasTemplate("SearchBoxTemplate") then
		filterBox = CreateFrame("EditBox", nil, page, "SearchBoxTemplate")
	else
		filterBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
	end
	filterBox:SetAutoFocus(false)
	filterBox:SetSize(160, 16)
	filterBox:SetPoint("LEFT", page, "TOPLEFT", CONTROLS_LEFT + 8, -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2))
	local instructions = filterBox.Instructions
	if instructions then
		instructions:SetText(hint)
		instructions:SetTextColor(TEXT.r, TEXT.g, TEXT.b)
		filterBox:HookScript("OnEditFocusGained", function()
			instructions:Hide()
		end)
		filterBox:HookScript("OnEditFocusLost", function(self)
			instructions:SetShown(self:GetText() == "")
		end)
	end
	filterBox:HookScript("OnTextChanged", function(self)
		-- the template shows the hint again whenever the box empties, even with the cursor in it
		if instructions and self:HasFocus() then
			instructions:Hide()
		end
		onChange(self:GetText():match("^%s*(.-)%s*$"))
	end)
	return filterBox
end

ns.CreateSpellbookFilterBox = CreateFilterBox
ns.CreateSpellbookDropdown = CreateDropdown
ns.AddSpellbookMenuTooltip = AddMenuTooltip
ns.ApplySpellbookElvUISkin = ApplyElvUISkin
