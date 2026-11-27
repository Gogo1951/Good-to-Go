local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip
local SettingsKey = ns.SettingsKey
local Docked = ns.DockedPanel
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip

--[[
	A drag from the page picks up the macro, so it can still go on an action bar. Every change rebuilds the page,
	which makes its macros afresh, so the panel holds its macro's settings key and finds it again after each
	refresh.
]]

local INNER_WIDTH = Docked.INNER_WIDTH
local SLOT_ICON = Widgets.SLOT_ICON
local ROW_HEIGHT, ROW_GAP = 32, 8
local OTHERWISE_LABEL_WIDTH = 128

local COLORS = Widgets.COLORS
local PANEL_FILL, ROW_EDGE = COLORS.PANEL_FILL, COLORS.ROW_EDGE
local MUTED_INK, ARROW_INK = COLORS.MUTED_INK, COLORS.ARROW_INK

local TEXTURE_ARROW = "Interface\\ChatFrame\\ChatFrameExpandArrow"

local panel

--[[
	Shared with Conditionals-Rows.lua, which loads after this file and reads it as it loads; this file reaches the
	rows and pick mode only once the panel is built.
]]
local UI = {}
ns.ConditionalsUI = UI
UI.ROW_HEIGHT, UI.ROW_GAP = ROW_HEIGHT, ROW_GAP
UI.TEXTURE_ARROW = TEXTURE_ARROW

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

local function CurrentMacro()
	return Docked.CurrentMacro(panel, ns.OffersConditionals)
end

local function Change(set)
	Docked.Change(panel, ns.OffersConditionals, set)
end

function ns.IsConditionalsPanelFor(macro)
	return panel ~= nil and panel:IsShown() and ns.OffersConditionals(macro) and SettingsKey(macro) == panel.key
end

local function RedrawPage()
	Docked.RedrawPage(panel)
end

UI.CurrentMacro, UI.Change, UI.RedrawPage = CurrentMacro, Change, RedrawPage

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

local function CreateOtherwise(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	row:SetAlpha(0.8)
	Box(row, PANEL_FILL, ROW_EDGE)
	local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetTextColor(unpack(MUTED_INK))
	label:SetPoint("LEFT", 32, 0) -- under the rows' condition dropdowns
	label:SetWidth(OTHERWISE_LABEL_WIDTH)
	label:SetJustifyH("LEFT")
	label:SetText(L["CONDITIONALS_OTHERWISE"])
	local arrow = row:CreateTexture(nil, "ARTWORK")
	arrow:SetTexture(TEXTURE_ARROW)
	arrow:SetVertexColor(unpack(ARROW_INK))
	arrow:SetSize(16, 16)
	arrow:SetPoint("LEFT", label, "RIGHT", 8, 0)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(SLOT_ICON, SLOT_ICON)
	row.icon:SetPoint("LEFT", arrow, "RIGHT", 8, 0)
	row.text = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
	row.text:SetPoint("RIGHT", -8, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	return row
end

-- Closes the panel once its macro has left the page.
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
	local y = math.max(#conditionals, panel.empty:IsShown() and 1 or 0) * (ROW_HEIGHT + ROW_GAP)
	Docked.SetRowPoint(panel, panel.otherwise, y)
	local own = ns.CastSpellName(macro)
	panel.otherwise.icon:SetTexture(C_Spell.GetSpellTexture(own) or macro.icon or ns.QUESTION_MARK_ICON)
	panel.otherwise.text:SetText(GetColor("TITLE") .. own .. "|r")
	Docked.SetRowPoint(panel, panel.add, y + ROW_HEIGHT + ROW_GAP + 4)
	panel.add:SetEnabled(#conditionals < ns.CONDITIONALS_MAX_ROWS)
	Docked.UpdateFooter(panel.footer, macro)
end
UI.Update = Update

local function CreatePanel(page)
	panel = Docked.Create(page, "GoodToGoConditionalsPanel", "CONDITIONALS_HINT")
	UI.panel = panel

	panel.empty = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	Docked.SetRowPoint(panel, panel.empty, 0)
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
	panel.add:SetSize(160, 22)
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

function ns.HideConditionalsPanel()
	if panel then
		panel:Hide()
	end
end

ns.OnSpellbookPageRefreshed(function(page)
	if panel and panel.page == page then
		Update()
	end
end)
