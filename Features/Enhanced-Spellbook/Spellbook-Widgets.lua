local _, ns = ...
local TITLE, BODY, TEXT = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY, ns.COLORS_RGB.TEXT
local L = ns.L
local HasTemplate = ns.HasTemplate

--[[
	The controls both of the Spell Book window's controls rows are built from: the Spell Book page's
	(Features/Enhanced-Spellbook/Spellbook-Controls.lua) and the What's Next? tab's
	(Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Controls.lua). The filter box, the dropdowns, a menu
	entry's tooltip and ElvUI's skin.
]]

-- The window's bands, in UI units from its edges, as Features/Enhanced-Spellbook/Spellbook-Page.lua sets them.
local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local CONTROLS_LEFT = 64 -- clear of the portrait

--[[
	Gives a settings menu entry the explanation its Options Interface control shows, as AceConfig shows it: the
	label as a gold title, then a white line. Builds whose menus can't take a tooltip show the entry bare.
]]
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
	With ElvUI loaded, its Skins module dresses the page's top controls as it dresses Blizzard's, so the filter
	box, the dropdowns and the button match the rest of that UI rather than the default art. The module is
	another add-on's API, so each call is guarded: a change to it leaves a control in the default art instead
	of breaking the page.
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

--[[
	A dropdown in the controls row, width wide, whose menu setup builds: the game's dropdown where the build has
	the template, else a plain button that opens the same menu, its label set by the caller.
]]
local function CreateDropdown(parent, width, setup)
	local dropdown
	if HasTemplate("WowStyle1DropdownTemplate") then
		dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		dropdown:SetWidth(width)
		dropdown:SetupMenu(setup)
	else
		dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		dropdown:SetSize(width, 22)
		dropdown:SetScript("OnClick", function(self)
			MenuUtil.CreateContextMenu(self, setup)
		end)
	end
	return dropdown
end

--[[
	The filter box at the controls row's left, with hint as its hint, calling onChange(text) with the trimmed
	text as it is typed. Its hint is white, readable on the dark box ElvUI or the default art gives it, and
	clears as soon as the box takes the cursor rather than once something is typed.
]]
local function CreateFilterBox(page, hint, onChange)
	local filterBox
	if HasTemplate("SearchBoxTemplate") then
		filterBox = CreateFrame("EditBox", nil, page, "SearchBoxTemplate")
	else
		filterBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
	end
	filterBox:SetAutoFocus(false)
	filterBox:SetSize(160, 20)
	filterBox:SetPoint("LEFT", page, "TOPLEFT", CONTROLS_LEFT + 6, -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2))
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

-- For the Spell Book page's controls row and the What's Next? tab's (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Controls.lua).
ns.CreateSpellbookFilterBox = CreateFilterBox
ns.CreateSpellbookDropdown = CreateDropdown
ns.AddSpellbookMenuTooltip = AddMenuTooltip
ns.ApplySpellbookElvUISkin = ApplyElvUISkin
