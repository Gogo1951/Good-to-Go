local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local HasTemplate = ns.HasTemplate

--[[
	The page's window, GoodToGoSpellbookFrame, which every host opens from its tab on the game's spellbook: the
	Blizzard portrait frame (the gold book in its portrait, the title, the close button) holding the page
	Features/Enhanced-Spellbook/Spellbook-Page.lua builds. It stays clear of the book, so UI skins that restyle the book leave it
	alone, and it is parented to UIParent, so nothing Blizzard owns is written to.
]]

local ICON_ADDON = ns.ICON_ADDON

--[[
	A 100% UI is 768 points tall, so this size shows unscaled there with the screen margin to spare; smaller UIs
	shrink it to fit.
]]
local WINDOW_WIDTH, WINDOW_HEIGHT = 1056, 640
local SCREEN_MARGIN = 32 -- kept clear around the window when it is scaled down to fit
-- the tabs hanging under the window's bottom edge, as the game's character window has them
local TAB_HEIGHT, TAB_LEFT, TAB_TOP = 32, 11, 2
-- the gap between tabs: the old tab art has clear margins the next tab tucks into, the atlas art none
local TAB_SPACING_OLD_ART, TAB_SPACING_ATLAS_ART = -16, 3
--[[
	Each tab is its label's width plus this padding, at least TAB_MIN_WIDTH. The Classic tab template sizes
	itself again on every show, capping the label at its parent's maxTabWidth (88 when unset), which cut off the
	longer labels, so the window sets a cap that fits them.
]]
local TAB_PADDING, TAB_MIN_WIDTH, TAB_MAX_TEXT_WIDTH = 20, 60, 220

--[[
	The window's tabs, in order, each { title key, builder, refresh as it shows, shown }: the Spell Book page,
	the What's Next? page where its file loaded (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Page.lua), which refreshes
	itself, then for a class with a pet the Pet Spell Book page, and for a hunter or warlock on a client whose
	pets are trained (Beast Training, grimoires) the Pet What's Next? page. shown, where given, says whether this character gets the tab at all.
]]
local TABS = {
	{ "TAB_ENHANCED_SPELLBOOK", ns.BuildSpellbookPage, ns.RefreshSpellbookPage },
	{ "WHATS_NEXT_TITLE", ns.BuildWhatsNextPage },
	{ "PET_SPELLBOOK_TITLE", ns.BuildPetSpellbookPage, nil, ns.HasPetSpellbook },
	{ "WHATS_NEXT_PET_TITLE", ns.BuildWhatsNextPetPage, nil, ns.HasWhatsNextPet },
}

local window
local listeners = {} -- the hosts' tabs, told when the window shows or hides
local dockWidth = 0 -- the panel docked at the window's right edge (ns.DockSpellbookPanel), or 0 for none
local tabPages = {} -- the page each tab shows
local selectedTab = 1 -- kept while the window is closed, so it opens again on the tab it closed on

--[[
	Shrinks the window, never grows it, so the whole spread fits on screen at any resolution or UI scale, a docked
	panel and the tabs under it included.
]]
local function FitToScreen()
	local scale = math.min(
		1,
		(UIParent:GetWidth() - 2 * SCREEN_MARGIN) / (WINDOW_WIDTH + dockWidth),
		(UIParent:GetHeight() - 2 * SCREEN_MARGIN) / (WINDOW_HEIGHT + TAB_HEIGHT)
	)
	window:SetScale(scale)
end

-- Keeps the docked panel and the tabs on screen as the window is dragged.
local function SetClampInsets()
	window:SetClampRectInsets(0, dockWidth, 0, #tabPages > 1 and -TAB_HEIGHT or 0)
end

local function Notify()
	for _, listener in ipairs(listeners) do
		listener()
	end
end

-- "Enhanced Spellbook // Good to Go" in the add-ons' shared colors: the page white, the slashes gray, the name blue
local function SetTitle(titleKey)
	local title = GetColor("TEXT")
		.. L[titleKey]
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//|r "
		.. GetColor("INFO")
		.. L["ADDON_TITLE"]
		.. "|r"
	if window.SetTitle then
		window:SetTitle(title)
	else
		window.TitleText:SetText(title)
	end
end

--[[
	Shows the tab's page and lights its tab; leaving the Spell Book closes the Conditionals or Cast Sequence panel
	docked beside it.
]]
local function SelectTab(index)
	selectedTab = index
	for i, page in pairs(tabPages) do
		page:SetShown(i == index)
	end
	for _, tab in ipairs(window.Tabs or {}) do
		if tab:GetID() == index then
			PanelTemplates_SelectTab(tab)
		else
			PanelTemplates_DeselectTab(tab)
		end
	end
	SetTitle(TABS[index][1])
	if index ~= 1 and ns.HideConditionalsPanel then
		ns.HideConditionalsPanel()
	end
	if index ~= 1 and ns.HideCastSequencePanel then
		ns.HideCastSequencePanel()
	end
end

--[[
	The Classic engine's own windows (Collections, Friends) hang their tabs from CharacterFrameTabButtonTemplate,
	whose unselected tabs tuck under the window's border. Its PanelTabButtonTemplate is newer art that raises
	itself over the border, so it's only the fallback, for the Retail engine, which lacks the older one.
]]
local function TabTemplate()
	for _, template in ipairs({ "CharacterFrameTabButtonTemplate", "PanelTabButtonTemplate" }) do
		if HasTemplate(template) then
			return template
		end
	end
end

-- The tabs under the window's bottom edge, one per page, when there's more than one page and a tab template.
local function CreateTabs()
	local template = TabTemplate()
	if #tabPages < 2 or not template or not PanelTemplates_SelectTab then
		return
	end
	local tabs = {}
	window.maxTabWidth = TAB_MAX_TEXT_WIDTH
	local function resize(button)
		PanelTemplates_TabResize(button, TAB_PADDING, nil, TAB_MIN_WIDTH, TAB_MAX_TEXT_WIDTH)
	end
	for i, tab in ipairs(TABS) do
		if tabPages[i] then
			local button = CreateFrame("Button", window:GetName() .. "Tab" .. i, window, template)
			button:SetID(i)
			button:SetText(L[tab[1]])
			if i == 1 then
				button:SetPoint("TOPLEFT", window, "BOTTOMLEFT", TAB_LEFT, TAB_TOP)
			else
				local left = tabs[#tabs].Left
				local atlasArt = left and left.GetAtlas and left:GetAtlas() ~= nil
				local spacing = atlasArt and TAB_SPACING_ATLAS_ART or TAB_SPACING_OLD_ART
				button:SetPoint("LEFT", tabs[#tabs], "RIGHT", spacing, 0)
			end
			button:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				SelectTab(i)
			end)
			if PanelTemplates_TabResize then
				resize(button)
				-- after the template's own OnShow resize, which has no padding
				button:HookScript("OnShow", resize)
			end
			tabs[#tabs + 1] = button
		end
	end
	window.Tabs = tabs
	window.numTabs = #tabs
end

local function CreateWindow()
	local template = HasTemplate("PortraitFrameTemplate") and "PortraitFrameTemplate" or "BasicFrameTemplate"
	window = CreateFrame("Frame", "GoodToGoSpellbookFrame", UIParent, template)
	window:Hide()
	window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
	window:SetPoint("CENTER")
	window:SetFrameStrata("HIGH")
	window:SetToplevel(true)
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	if window.SetPortraitToAsset then
		window:SetPortraitToAsset(ICON_ADDON)
	end
	-- Escape closes it, like the book
	table.insert(UISpecialFrames, window:GetName())
	window:HookScript("OnShow", function()
		FitToScreen()
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		Notify()
		-- the window takes the book's place, so the host closes the game's own book behind it
		if ns.CloseGameSpellbook then
			ns.CloseGameSpellbook()
		end
	end)
	window:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE)
		Notify()
	end)

	--[[
		each tab's page covers the whole window; it draws its controls, parchment and footer inside the frame's
		border, and refreshes as it shows
	]]
	for i, tab in ipairs(TABS) do
		local build, refresh, shown = tab[2], tab[3], tab[4]
		if build and (not shown or shown()) then
			local page = CreateFrame("Frame", nil, window)
			page:SetAllPoints()
			page:Hide()
			build(page)
			if refresh then
				page:SetScript("OnShow", refresh)
			end
			tabPages[i] = page
		end
	end
	CreateTabs()
	SetClampInsets()
	SelectTab(selectedTab)
end

function ns.ToggleSpellbookWindow()
	if not ns.IsSpellbookEnabled() then
		ns:PrintMessage(L["SPELLBOOK_IS_OFF"])
		return
	end
	if not window then
		CreateWindow()
	end
	window:SetShown(not window:IsShown())
end

function ns.IsSpellbookWindowShown()
	return window ~= nil and window:IsShown()
end

-- Calls fn whenever the window shows or hides, so a host's tab can show it as selected.
function ns.OnSpellbookWindowToggled(fn)
	listeners[#listeners + 1] = fn
end

--[[
	Closes the window, for the Spellbook's switch turning off (ns.SetSpellbookEnabled).
]]
function ns.HideSpellbookWindow()
	if window then
		window:Hide()
	end
end

--[[
	Docks a panel width wide against the window's right edge, the Conditionals or Cast Sequence panel
	(Features/Enhanced-Spellbook/Macro-Builder/Conditionals-Panel.lua, Cast-Sequence-Panel.lua), or none with 0: the window
	shrinks to fit both, and keeps the panel on screen as it is dragged, pulled back in at once if it hangs off
	the edge now.
]]
function ns.DockSpellbookPanel(width)
	dockWidth = width
	if not window then
		return
	end
	SetClampInsets()
	FitToScreen()
	local point, relativeTo, relativePoint, x, y = window:GetPoint()
	if point then
		window:ClearAllPoints()
		window:SetPoint(point, relativeTo, relativePoint, x, y)
	end
end

-- The key binding's toggle (Features/Enhanced-Spellbook/Key-Bindings.lua), the same as a click on a host's tab.
ns.ToggleSpellbookPage = ns.ToggleSpellbookWindow
