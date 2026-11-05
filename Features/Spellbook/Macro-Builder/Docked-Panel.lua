local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local INFO, OFF, WARNING = ns.COLORS_RGB.INFO, ns.COLORS_RGB.OFF, ns.COLORS_RGB.TITLE
local SizedFontString = ns.SizedFontString
local SettingsKey = ns.SettingsKey
local Widgets = ns.PanelWidgets
local Box = Widgets.Box

--[[
	The shell the Conditionals and Cast Sequence panels share (Features/Spellbook/Macro-Builder/Conditionals-Panel.lua,
	Cast-Sequence-Panel.lua), docked against the Spell Book window's right edge (ns.DockSpellbookPanel, in
	Features/Spellbook/Spellbook-Window.lua), one at a time: the frame, dragged to move the window, with its
	heading, close button and hint; the footer with the macro text; and the panel's macro, found again by its
	settings key after each refresh. Their controls are Features/Spellbook/Macro-Builder/Panel-Widgets.lua.
]]

local PANEL_WIDTH = 470
local DOCK_INSET = 2 -- tucked under the window's border, top and bottom
local PADDING = 16
local HEADER_ICON = 24
local HINT_TOP = 46
local METER_WIDTH, METER_HEIGHT = 120, 6
local METER_WARNING = 0.9 -- the share of what a macro holds past which the meter turns gold
local INNER_WIDTH = PANEL_WIDTH - 2 * PADDING

local COLORS = Widgets.COLORS
local PANEL_FILL, PANEL_EDGE = COLORS.PANEL_FILL, COLORS.PANEL_EDGE
local FIELD_FILL = COLORS.FIELD_FILL
local FOOTER_EDGE, METER_TRACK = COLORS.FOOTER_EDGE, COLORS.METER_TRACK
local MUTED_INK = COLORS.MUTED_INK

local Docked = {}
ns.DockedPanel = Docked
Docked.PADDING, Docked.INNER_WIDTH = PADDING, INNER_WIDTH

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

--[[
	The page macro a panel is open for, found again by its settings key, or nil once it has left the page,
	hidden ones included (a grouped spell's once a later one is learned). offers(macro) says whether a macro
	has the panel's feature.
]]
local function CurrentMacro(panel, offers)
	if not panel or not panel.key then
		return nil
	end
	for _, macro in ipairs(ns.macros) do
		if not macro.focus and not macro.hidden and SettingsKey(macro) == panel.key and offers(macro) then
			return macro
		end
	end
	return nil
end

--[[
	Runs a setter on a panel's macro, set(macro), and rebuilds the page, which rewrites the macro and redraws the
	panel (its ns.OnSpellbookPageRefreshed).
]]
local function Change(panel, offers, set)
	local macro = CurrentMacro(panel, offers)
	if not macro then
		return
	end
	set(macro)
	ns.RefreshSpellbookPage(panel.page)
end

-- Redraws the page's tiles, for their outline and pick-mode dimming, without rebuilding its macros.
local function RedrawPage(panel)
	if panel.page:IsVisible() then
		ns.LayoutSpellbookPage(panel.page)
	end
end

Docked.CurrentMacro, Docked.Change, Docked.RedrawPage = CurrentMacro, Change, RedrawPage

--------------------------------------------------------------------------------
-- Heading and footer
--------------------------------------------------------------------------------

-- The heading: the macro's icon, its name, and the panel's title (titleKey).
local function SetHeading(panel, macro, titleKey)
	panel.icon:SetTexture(macro.icon or ns.QUESTION_MARK_ICON)
	-- a rank's own macro shares its spell's name, so its heading names the rank too
	panel.title:SetText(
		GetColor("TITLE")
			.. (macro.label or macro.name)
			.. (macro.rank and " " .. GetColor("HELP") .. macro.rank .. "|r" or "")
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//|r "
			.. GetColor("TEXT")
			.. L[titleKey]
			.. "|r"
	)
end

-- The footer: "Macro Text", a meter of its length against what a macro holds, the count, and the text itself.
local function CreateFooter(parent)
	local footer = CreateFrame("Frame", nil, parent)
	footer:SetPoint("BOTTOMLEFT", PADDING, PADDING)
	footer:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
	Box(footer, FIELD_FILL, FOOTER_EDGE)
	local title = SizedFontString(footer, "GameFontNormal", 13)
	title:SetPoint("TOPLEFT", 10, -9)
	title:SetText(GetColor("TITLE") .. L["MACRO_TEXT"] .. "|r")
	footer.count = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.count:SetPoint("TOPRIGHT", -10, -10)
	local track = footer:CreateTexture(nil, "ARTWORK")
	track:SetColorTexture(unpack(METER_TRACK))
	track:SetSize(METER_WIDTH, METER_HEIGHT)
	track:SetPoint("RIGHT", footer.count, "LEFT", -10, 0)
	footer.meter = footer:CreateTexture(nil, "OVERLAY")
	footer.meter:SetPoint("TOPLEFT", track)
	footer.meter:SetHeight(METER_HEIGHT)
	footer.body = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.body:SetPoint("TOPLEFT", 10, -30)
	footer.body:SetWidth(INNER_WIDTH - 20)
	footer.body:SetJustifyH("LEFT")
	footer.body:SetWordWrap(true)
	footer.tooLong = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.tooLong:SetPoint("TOPLEFT", footer.body, "BOTTOMLEFT", 0, -6)
	footer.tooLong:SetWidth(INNER_WIDTH - 20)
	footer.tooLong:SetJustifyH("LEFT")
	return footer
end

--[[
	Shows the macro text, its tag line left out though the length counts it, as the menu's Macro Text does. The
	meter is blue, gold once it nears what a macro holds, and red past it, where a line under the text gives the
	length and says to turn an option off to shorten it (TOOLTIP_TOO_LONG), as the tile's tooltip does.
]]
local function UpdateFooter(footer, macro)
	local length, max = #macro.body, ns.MACRO_BODY_MAX_LENGTH
	local over = length > max
	local near = not over and length >= max * METER_WARNING
	footer.count:SetText(GetColor(over and "OFF" or "HELP") .. L["MENU_MACRO_LENGTH"]:format(length, max) .. "|r")
	local color = over and OFF or near and WARNING or INFO
	footer.meter:SetColorTexture(color.r, color.g, color.b)
	footer.meter:SetWidth(math.max(1, METER_WIDTH * math.min(1, length / max)))
	footer.body:SetText((ns.UntaggedBody(macro.body):gsub("|", "||")))
	footer.tooLong:SetShown(over)
	footer.tooLong:SetText(GetColor("OFF") .. L["TOOLTIP_TOO_LONG"]:format(length, max) .. "|r")
	local height = 30 + math.ceil(footer.body:GetStringHeight()) + 10
	if over then
		height = height + 6 + math.ceil(footer.tooLong:GetStringHeight())
	end
	footer:SetHeight(height)
end

Docked.SetHeading, Docked.CreateFooter, Docked.UpdateFooter = SetHeading, CreateFooter, UpdateFooter

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

--[[
	Builds a panel, hidden, named name, docked beside page's window: its heading (panel.icon, panel.title), close
	button and hint (hintKey). It docks while shown, takes the keyboard only in pick mode, and closes with the
	window.
]]
local function Create(page, name, hintKey)
	local window = page:GetParent()
	local panel = CreateFrame("Frame", name, window)
	panel:Hide()
	panel.page = page
	panel:SetWidth(PANEL_WIDTH)
	panel:SetPoint("TOPLEFT", window, "TOPRIGHT", -DOCK_INSET, -DOCK_INSET)
	panel:SetPoint("BOTTOMLEFT", window, "BOTTOMRIGHT", -DOCK_INSET, DOCK_INSET)
	panel:EnableMouse(true)
	-- dragging the panel moves the window it is docked to
	panel:RegisterForDrag("LeftButton")
	panel:SetScript("OnDragStart", function()
		window:StartMoving()
	end)
	panel:SetScript("OnDragStop", function()
		window:StopMovingOrSizing()
	end)
	Box(panel, PANEL_FILL, PANEL_EDGE)

	panel.icon = panel:CreateTexture(nil, "ARTWORK")
	panel.icon:SetSize(HEADER_ICON, HEADER_ICON)
	panel.icon:SetPoint("TOPLEFT", PADDING, -14)
	panel.title = SizedFontString(panel, "GameFontNormalLarge", 16)
	panel.title:SetPoint("LEFT", panel.icon, "RIGHT", 10, 0)
	panel.title:SetWidth(INNER_WIDTH - HEADER_ICON - 10 - 24) -- clear of the close button
	panel.title:SetJustifyH("LEFT")
	panel.title:SetWordWrap(false)
	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -6)
	close:SetScript("OnClick", function()
		panel:Hide()
	end)
	local hint = SizedFontString(panel, "GameFontHighlightSmall", 13)
	hint:SetPoint("TOPLEFT", PADDING, -HINT_TOP)
	hint:SetWidth(INNER_WIDTH)
	hint:SetJustifyH("LEFT")
	hint:SetTextColor(unpack(MUTED_INK))
	hint:SetText(L[hintKey])

	--[[
		the panel takes the keyboard only in pick mode, where Escape ends it and every other key goes on to the
		game; each key sets its own passing on, since that can't be set in combat, which ends pick mode anyway
	]]
	panel:SetScript("OnKeyDown", function(self, key)
		if InCombatLockdown() then
			return
		end
		local cancel = key == "ESCAPE" and ns.IsPickingConditionalSpell()
		self:SetPropagateKeyboardInput(not cancel)
		if cancel then
			ns.CancelConditionalPick()
		end
	end)
	panel:SetScript("OnShow", function()
		ns.DockSpellbookPanel(PANEL_WIDTH)
	end)
	-- the tile's outline goes with the panel
	panel:SetScript("OnHide", function()
		ns.CancelConditionalPick()
		ns.DockSpellbookPanel(0)
		RedrawPage(panel)
	end)
	-- closing the window closes the panel, so it opens again only from a macro's menu
	window:HookScript("OnHide", function()
		panel:Hide()
	end)
	return panel
end

Docked.Create = Create
