local _, ns = ...
local L = ns.L
local HasTemplate = ns.HasTemplate

--[[
	Kept clear of the game's book, so skins that restyle the book leave it alone, and parented to UIParent, so
	nothing Blizzard owns is written to.
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
	The Classic tab template resizes itself on every show, capping the label at its parent's maxTabWidth (88 when
	unset), so the window sets a cap that fits the longer labels.
]]
local TAB_PADDING, TAB_MIN_WIDTH, TAB_MAX_TEXT_WIDTH = 16, 64, 224

-- Each { title key, builder, refresh as it shows, shown }; shown, where given, gates the tab for this character.
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

-- Only shrinks, never grows, counting a docked panel and the tabs.
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

local function SetTitle(titleKey)
	local title = ns.MenuKit.WindowTitle(L[titleKey])
	if window.SetTitle then
		window:SetTitle(title)
	else
		window.TitleText:SetText(title)
	end
end

-- Leaving the Spell Book closes a docked panel.
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

-- Says whether the window has the tab.
function ns.ShowSpellbookTab(index)
	if not tabPages[index] then
		return false
	end
	SelectTab(index)
	return true
end
ns.SPELLBOOK_TAB_BOOK, ns.SPELLBOOK_TAB_PET_BOOK = 1, 3

--[[
	CharacterFrameTabButtonTemplate's unselected tabs tuck under the window's border; PanelTabButtonTemplate
	raises itself over it, so it's only the fallback, for the Retail engine, which lacks the older one.
]]
local function TabTemplate()
	for _, template in ipairs({ "CharacterFrameTabButtonTemplate", "PanelTabButtonTemplate" }) do
		if HasTemplate(template) then
			return template
		end
	end
end

-- Only with more than one page and a tab template.
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

local function PlaceWindow()
	local position = ns.db.global.windowPosition
	window:ClearAllPoints()
	if position and position.point then
		window:SetPoint(position.point, UIParent, position.relativePoint, position.xOffset, position.yOffset)
	else
		window:SetPoint("CENTER")
	end
end

-- Written whole: AceDB can clear an empty windowPosition at logout.
local function SavePosition()
	local point, _, relativePoint, xOffset, yOffset = window:GetPoint(window:GetNumPoints())
	ns.db.global.windowPosition = { point = point, relativePoint = relativePoint, xOffset = xOffset, yOffset = yOffset }
end

ns.SaveSpellbookWindowPosition = SavePosition

function ns.HasSavedSpellbookWindowPosition()
	local position = ns.db and ns.db.global.windowPosition
	return position ~= nil and position.point ~= nil
end

-- Moves an open window back to the middle too.
function ns.ResetSpellbookWindowPosition()
	ns.db.global.windowPosition = {}
	if window then
		PlaceWindow()
	end
end

local function CreateWindow()
	local template = HasTemplate("PortraitFrameTemplate") and "PortraitFrameTemplate" or "BasicFrameTemplate"
	window = CreateFrame("Frame", "GoodToGoSpellbookFrame", UIParent, template)
	window:Hide()
	window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
	PlaceWindow()
	window:SetFrameStrata("HIGH")
	window:SetToplevel(true)
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		SavePosition()
	end)
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

	-- each page covers the whole window and draws inside the frame's border
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

function ns.OnSpellbookWindowToggled(fn)
	listeners[#listeners + 1] = fn
end

function ns.HideSpellbookWindow()
	if window then
		window:Hide()
	end
end

-- 0 undocks. Re-placing the window pulls it back in at once if it now hangs off the edge.
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

-- the key binding's toggle
ns.ToggleSpellbookPage = ns.ToggleSpellbookWindow
