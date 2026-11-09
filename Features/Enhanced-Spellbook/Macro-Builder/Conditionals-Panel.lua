local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local SettingsKey = ns.SettingsKey
local Docked = ns.DockedPanel
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip

--[[
	The Conditionals panel, docked against the Spell Book window's right edge (ns.DockSpellbookPanel, in
	Features/Enhanced-Spellbook/Spellbook-Window.lua) and opened from a macro's menu (Features/Enhanced-Spellbook/Macro-Menu.lua). It
	lists the macro's rows (Features/Enhanced-Spellbook/Macro-Builder/Conditionals.lua) top to bottom: a grip to drag a row up or down, one
	or two condition dropdowns joined by "and", the spell the row casts and its remove button. Under them the
	macro's own spell as the fixed Otherwise row, the Add Condition button, and the macro text with its length
	against what a macro holds, which follow every change.

	A row's spell slot takes a spell two ways: a click puts the page in pick mode, where the next spell clicked
	on the page fills the slot and Escape or a right-click cancels; or a spell dragged from the page (or the
	game's own spellbook, or an action bar) is dropped on it. A drag from the page picks up the macro, so it can
	go on an action bar. Add Condition starts pick mode for the new row straight away. The page
	outlines the tile the panel is open for, and in pick mode dims the ones that can't be picked
	(Features/Enhanced-Spellbook/Macro-Button.lua asks ns.IsConditionalsPanelFor and ns.IsPickingSpell).
	The rows are Features/Enhanced-Spellbook/Macro-Builder/Conditionals-Rows.lua and pick mode Features/Enhanced-Spellbook/Macro-Builder/Spell-Pick.lua.
	The frame, its heading and footer are Features/Enhanced-Spellbook/Macro-Builder/Docked-Panel.lua, shared with the Cast
	Sequence panel, as are the controls in Features/Enhanced-Spellbook/Macro-Builder/Panel-Widgets.lua.

	Every change rebuilds the page, as the menu's do (ns.RefreshSpellbookPage), which rewrites the macro; the
	rebuild makes the page's macros afresh, so the panel holds its macro's settings key and finds it again after
	each refresh (ns.OnSpellbookPageRefreshed).
]]

local PADDING, INNER_WIDTH = Docked.PADDING, Docked.INNER_WIDTH
local SLOT_ICON = Widgets.SLOT_ICON
local ROWS_TOP = 72
local ROW_HEIGHT, ROW_GAP = 32, 8
local OTHERWISE_LABEL_WIDTH = 96

local COLORS = Widgets.COLORS
local PANEL_FILL, ROW_EDGE = COLORS.PANEL_FILL, COLORS.ROW_EDGE
local MUTED_INK, ARROW_INK = COLORS.MUTED_INK, COLORS.ARROW_INK

local TEXTURE_ARROW = "Interface\\ChatFrame\\ChatFrameExpandArrow"

local panel

--[[
	What the panel shares with its rows (Conditionals-Rows.lua) and pick mode (Spell-Pick.lua), which
	load after this file and read it as they load; this file reaches the rows and pick mode only once the
	panel is built.
]]
local UI = {}
ns.ConditionalsUI = UI
UI.ROWS_TOP, UI.ROW_HEIGHT, UI.ROW_GAP = ROWS_TOP, ROW_HEIGHT, ROW_GAP
UI.TEXTURE_ARROW = TEXTURE_ARROW

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

-- The page macro the panel is open for, found again by its settings key, or nil once it has left the page.
local function CurrentMacro()
	return Docked.CurrentMacro(panel, ns.OffersConditionals)
end

--[[
	Runs a setter on the macro, set(macro), and rebuilds the page, which rewrites the macro and redraws the
	panel (see ns.OnSpellbookPageRefreshed below).
]]
local function Change(set)
	Docked.Change(panel, ns.OffersConditionals, set)
end

--[[
	Whether the panel is open for a page macro, so its tile is outlined on the page. A focus copy shares its
	spell's settings key but has no Conditionals, so it is never the one.
]]
function ns.IsConditionalsPanelFor(macro)
	return panel ~= nil and panel:IsShown() and ns.OffersConditionals(macro) and SettingsKey(macro) == panel.key
end

-- Redraws the page's tiles, for their outline and pick-mode dimming, without rebuilding its macros.
local function RedrawPage()
	Docked.RedrawPage(panel)
end

UI.CurrentMacro, UI.Change, UI.RedrawPage = CurrentMacro, Change, RedrawPage

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

-- The fixed last row, the macro's own spell, cast when no row above matches; drawn muted, with no controls.
local function CreateOtherwise(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	row:SetAlpha(0.8)
	Box(row, PANEL_FILL, ROW_EDGE)
	local label = SizedFontString(row, "GameFontHighlightSmall", 13)
	label:SetTextColor(unpack(MUTED_INK))
	label:SetPoint("LEFT", 24, 0)
	label:SetWidth(OTHERWISE_LABEL_WIDTH)
	label:SetJustifyH("LEFT")
	label:SetText(L["CONDITIONALS_OTHERWISE"])
	local arrow = row:CreateTexture(nil, "ARTWORK")
	arrow:SetTexture(TEXTURE_ARROW)
	arrow:SetVertexColor(unpack(ARROW_INK))
	arrow:SetSize(12, 12)
	arrow:SetPoint("LEFT", label, "RIGHT", 6, 0)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(SLOT_ICON, SLOT_ICON)
	row.icon:SetPoint("LEFT", arrow, "RIGHT", 9, 0)
	row.text = SizedFontString(row, "GameFontNormal", 13)
	row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.text:SetPoint("RIGHT", -6, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	return row
end

--[[
	Redraws the panel for its macro: the heading, the rows, the Otherwise row and the Add Condition button under
	the last row, and the footer. Closes it once its macro has left the page.
]]
local function Update()
	if not panel or not panel:IsShown() then
		return
	end
	local macro = CurrentMacro()
	if not macro then
		panel:Hide()
		return
	end
	Docked.SetHeading(panel, macro, "CONDITIONALS_TITLE")
	local conditionals = ns.Conditionals(macro)
	for i, row in ipairs(panel.rows) do
		local conditional = conditionals[i]
		row:SetShown(conditional ~= nil)
		if conditional then
			UI.UpdateRow(row, macro, conditional)
		end
	end
	-- with no rows yet, a line saying what one does stands where they go
	panel.empty:SetShown(#conditionals == 0)
	local y = ROWS_TOP + math.max(#conditionals, panel.empty:IsShown() and 1 or 0) * (ROW_HEIGHT + ROW_GAP)
	panel.otherwise:SetPoint("TOPLEFT", PADDING, -y)
	local own = ns.CastSpellName(macro)
	panel.otherwise.icon:SetTexture(C_Spell.GetSpellTexture(own) or macro.icon or ns.QUESTION_MARK_ICON)
	panel.otherwise.text:SetText(GetColor("TITLE") .. own .. "|r")
	panel.add:SetPoint("TOPLEFT", PADDING, -(y + ROW_HEIGHT + ROW_GAP + 4))
	panel.add:SetEnabled(#conditionals < ns.CONDITIONALS_MAX_ROWS)
	Docked.UpdateFooter(panel.footer, macro)
end
UI.Update = Update

local function CreatePanel(page)
	panel = Docked.Create(page, "GoodToGoConditionalsPanel", "CONDITIONALS_HINT")
	UI.panel = panel

	panel.empty = SizedFontString(panel, "GameFontHighlightSmall", 13)
	panel.empty:SetPoint("TOPLEFT", PADDING, -ROWS_TOP)
	panel.empty:SetSize(INNER_WIDTH, ROW_HEIGHT)
	panel.empty:SetJustifyH("LEFT")
	panel.empty:SetJustifyV("MIDDLE")
	panel.empty:SetText(GetColor("MUTED") .. L["CONDITIONALS_EMPTY"] .. "|r")

	panel.rows = {}
	for i = 1, ns.CONDITIONALS_MAX_ROWS do
		panel.rows[i] = UI.CreateRow(panel, i)
	end
	panel.otherwise = CreateOtherwise(panel)
	panel.add = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.add:SetSize(150, 22)
	panel.add:SetText(L["CONDITIONALS_ADD"])
	panel.add:SetMotionScriptsWhileDisabled(true)
	-- the new row has no spell yet, so pick mode starts for it at once
	panel.add:SetScript("OnClick", function()
		ns.CancelSpellPick()
		Change(ns.AddConditional)
		local macro = CurrentMacro()
		local count = macro and #ns.Conditionals(macro) or 0
		if count > 0 and not ns.ConditionalHasSpell(ns.Conditionals(macro)[count]) and not InCombatLockdown() then
			UI.SetPicking(count)
		end
	end)
	panel.add:SetScript("OnEnter", function(self)
		ShowTip(
			self,
			L["CONDITIONALS_ADD"],
			L["CONDITIONALS_ADD_DESCRIPTION"],
			L["CONDITIONALS_ADD_LIMIT"]:format(ns.CONDITIONALS_MAX_ROWS)
		)
	end)
	panel.add:SetScript("OnLeave", HideTooltip)
	panel.footer = Docked.CreateFooter(panel)
end

-- Opens the panel for a page macro (from its menu), or moves it to that macro when it is open for another.
function ns.ShowConditionalsPanel(macro, page)
	if not ns.OffersConditionals(macro) then
		return
	end
	if not panel then
		CreatePanel(page)
	end
	ns.CancelSpellPick()
	-- one panel docks at a time: the Cast Sequence panel makes way
	if ns.HideCastSequencePanel then
		ns.HideCastSequencePanel()
	end
	panel.key = SettingsKey(macro)
	panel:Show()
	RedrawPage()
	Update()
end

--[[
	Closes the panel, for the window's switch to a tab other than the Spell Book
	(Features/Enhanced-Spellbook/Spellbook-Window.lua) and for the Cast Sequence panel opening in its place
	(Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence-Panel.lua).
]]
function ns.HideConditionalsPanel()
	if panel then
		panel:Hide()
	end
end

-- The page rebuilt its macros: draw the panel again from the new ones.
ns.OnSpellbookPageRefreshed(function(page)
	if panel and panel.page == page then
		Update()
	end
end)
