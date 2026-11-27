local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local SetTip = ns.MenuSetTip
local HideTooltip = ns.HideTooltip
local SettingsKey = ns.SettingsKey
local Docked = ns.DockedPanel
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip

local INNER_WIDTH = Docked.INNER_WIDTH
local SLOT_ICON = Widgets.SLOT_ICON
local ROW_HEIGHT, ROW_GAP = 32, 4 -- a tighter gap than a Conditionals row's, so eight steps leave the footer room
local NUMBER_WIDTH = 16
local SLOT_HEIGHT = 32
local SETTING_HEIGHT, SETTING_LABEL_WIDTH = 32, 160

local COLORS = Widgets.COLORS
local PANEL_FILL = COLORS.PANEL_FILL
local ROW_FILL, ROW_EDGE = COLORS.ROW_FILL, COLORS.ROW_EDGE
local MUTED_INK = COLORS.MUTED_INK
local BLOCKED_ALPHA = 0.5 -- the steps while something keeps the sequence from writing (ns.CastSequenceBlockReason)

local panel

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

local function CurrentMacro()
	return Docked.CurrentMacro(panel, ns.OffersCastSequence)
end

local function Change(set)
	Docked.Change(panel, ns.OffersCastSequence, set)
end

function ns.IsCastSequencePanelFor(macro)
	return panel ~= nil and panel:IsShown() and ns.OffersCastSequence(macro) and SettingsKey(macro) == panel.key
end

local function RedrawPage()
	Docked.RedrawPage(panel)
end

local Update -- below; the rows and pick mode call it

-- pick mode's owner
local owner = {
	actionKey = "CAST_SEQUENCE_ACTION_USE",
	cannotPickKey = "CAST_SEQUENCE_CANNOT_PICK",
	pickOf = function(macro)
		return ns.CastSequenceSpellOf(macro)
	end,
	apply = function(index, pick)
		Change(function(macro)
			ns.SetCastSequenceStepSpell(macro, index, pick)
		end)
	end,
	redraw = function()
		RedrawPage()
	end,
	update = function()
		Update()
	end,
}

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

local function NumberText(row, number)
	local text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetTextColor(unpack(MUTED_INK))
	text:SetWidth(NUMBER_WIDTH)
	text:SetJustifyH("CENTER")
	text:SetText(number)
	return text
end

local function CreateSetting(parent, labelKey, openMenu)
	local setting = CreateFrame("Frame", nil, parent)
	setting:SetSize(INNER_WIDTH, SETTING_HEIGHT)
	local label = setting:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("LEFT")
	label:SetWidth(SETTING_LABEL_WIDTH)
	label:SetJustifyH("LEFT")
	label:SetText(GetColor("TITLE") .. L[labelKey] .. "|r")
	local maxWidth = INNER_WIDTH - SETTING_LABEL_WIDTH
	local dropdown, caret = Widgets.CreateDropdown(setting, function(width)
		return math.min(maxWidth, width)
	end, openMenu)
	dropdown.text:SetPoint("RIGHT", caret, "LEFT", -4, 0)
	setting.dropdown = dropdown
	setting.dropdown:SetPoint("LEFT", label, "RIGHT", 0, 0)
	return setting
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

local function OpenEndMenu(menuOwner)
	local macro = CurrentMacro()
	if not macro then
		return
	end
	ns.OpenMacroMenuPanels(menuOwner, function(_, root)
		for _, choice in ipairs({
			{ false, "CAST_SEQUENCE_END_LOOP", "CAST_SEQUENCE_END_LOOP_DESCRIPTION", "CAST_SEQUENCE_END_LOOP" },
			{ true, "CAST_SEQUENCE_END_STOP_SHORT", "CAST_SEQUENCE_END_STOP_DESCRIPTION", "CAST_SEQUENCE_END_STOP" },
		}) do
			local stops = choice[1]
			local element = root:CreateRadio(L[choice[2]], function()
				return ns.CastSequenceStops(macro) == stops
			end, function()
				-- the menu stays open and redraws, the pick moved
				Change(function(own)
					ns.SetCastSequenceStops(own, stops)
				end)
			end)
			-- the tooltip's title names what Stop leaves the macro on (NULL)
			SetTip(element, L[choice[4]], L[choice[3]])
		end
	end, true)
end

local function OpenResetMenu(menuOwner)
	local macro = CurrentMacro()
	if not macro then
		return
	end
	ns.OpenMacroMenuPanels(menuOwner, function(_, root)
		for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
			local key = reset.key
			local element = root:CreateCheckbox(L[reset.labelKey], function()
				return ns.IsCastSequenceReset(macro, key)
			end, function()
				Change(function(own)
					ns.ToggleCastSequenceReset(own, key)
				end)
			end)
			SetTip(element, L[reset.labelKey], L[reset.descKey])
		end
		root:CreateSpacer()
		local secondsMenu = root:CreateButton(L["CAST_SEQUENCE_RESET_SECONDS_MENU"])
		-- the seconds it waits ("5 Seconds"), or Off, gray on the right, as every submenu's value is
		secondsMenu:SetValue(function()
			local seconds = ns.CastSequenceSeconds(macro)
			return seconds and L["CAST_SEQUENCE_RESET_SECONDS_VALUE"]:format(seconds)
				or L["CAST_SEQUENCE_RESET_SECONDS_OFF"]
		end)
		SetTip(secondsMenu, L["CAST_SEQUENCE_RESET_SECONDS_MENU"], L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"])
		local choices = { false }
		for _, seconds in ipairs(ns.CAST_SEQUENCE_SECONDS) do
			choices[#choices + 1] = seconds
		end
		for _, seconds in ipairs(choices) do
			local label = seconds and L["CAST_SEQUENCE_RESET_SECONDS"]:format(seconds)
				or L["CAST_SEQUENCE_RESET_SECONDS_OFF"]
			secondsMenu:CreateRadio(label, function()
				return (ns.CastSequenceSeconds(macro) or false) == seconds
			end, function()
				Change(function(own)
					ns.SetCastSequenceSeconds(own, seconds or nil)
				end)
			end)
		end
	end, true)
end

--------------------------------------------------------------------------------
-- Steps
--------------------------------------------------------------------------------

local function StepAt(index)
	local macro = CurrentMacro()
	return macro, macro and ns.CastSequenceSteps(macro)[index]
end

local function CreateFirst(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	Docked.SetRowPoint(parent, row, 0)
	row:SetAlpha(0.8)
	row:EnableMouse(true)
	Box(row, PANEL_FILL, ROW_EDGE)
	local number = NumberText(row, "1")
	number:SetPoint("LEFT", Widgets.ROW_EDGE + Widgets.GRIP_WIDTH + 8, 0) -- in line with the steps' numbers, after their grips
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(SLOT_ICON, SLOT_ICON)
	row.icon:SetPoint("LEFT", number, "RIGHT", 8, 0)
	local first = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	first:SetTextColor(unpack(MUTED_INK))
	first:SetPoint("RIGHT", -8, 0)
	first:SetText(L["CAST_SEQUENCE_FIRST"])
	row.text = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
	row.text:SetPoint("RIGHT", first, "LEFT", -8, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	row:SetScript("OnEnter", function(self)
		ShowTip(self, L["CAST_SEQUENCE_FIRST"], L["CAST_SEQUENCE_FIRST_DESCRIPTION"])
	end)
	row:SetScript("OnLeave", HideTooltip)
	return row
end

local function CreateSlot(row)
	local slot = Widgets.CreateSlot(row, SLOT_HEIGHT, SLOT_ICON, 8, function()
		return owner
	end)
	slot:SetScript("OnEnter", function(self)
		local _, step = StepAt(row.index)
		if not step then
			return
		end
		if step.spellID then
			ns.SetTooltipOwner(self)
			GameTooltip:SetSpellByID(step.spellID)
		else
			ShowTip(self, L["CONDITIONALS_PICK_SPELL"], L["CAST_SEQUENCE_SLOT_DESCRIPTION"])
		end
		Widgets.AddSlotHints(ns.IsPickingSpellFor(owner, row.index), "CAST_SEQUENCE_ACTION_DROP")
	end)
	return slot
end

local function CreateStep(parent, index)
	local row = CreateFrame("Frame", nil, parent)
	row.index = index
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	Docked.SetRowPoint(parent, row, index * (ROW_HEIGHT + ROW_GAP))
	Box(row, ROW_FILL, ROW_EDGE)
	row.drop = Widgets.CreateDropWash(row)
	row.grip = Widgets.CreateGrip(row, panel, "CAST_SEQUENCE_REORDER_DESCRIPTION", function(from, to)
		Change(function(macro)
			ns.MoveCastSequenceStep(macro, from, to)
		end)
	end, Update)
	local number = NumberText(row, tostring(index + 1))
	number:SetPoint("LEFT", row.grip, "RIGHT", 8, 0)
	row.remove = Widgets.CreateRemove(row, "CAST_SEQUENCE_REMOVE_DESCRIPTION", function()
		Change(function(macro)
			ns.RemoveCastSequenceStep(macro, index)
		end)
	end)
	row.slot = CreateSlot(row)
	row.slot:SetPoint("LEFT", number, "RIGHT", 8, 0)
	row.slot:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
	return row
end

local function UpdateStep(row, step, blocked)
	row:SetAlpha(blocked and BLOCKED_ALPHA or 1)
	local slot = row.slot
	if ns.IsPickingSpellFor(owner, row.index) then
		Widgets.DrawPickingSlot(slot)
	elseif step.spellID then
		local name, rank = ns.ConditionalSpellName(step)
		Widgets.DrawSpellSlot(slot, step.spellID, name, rank)
	else
		Widgets.DrawEmptySlot(slot)
	end
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

-- Closes the panel once its macro has left the page.
Update = function()
	if not panel or not panel:IsShown() then
		return
	end
	local macro = CurrentMacro()
	if not macro then
		panel:Hide()
		return
	end
	Docked.SetHeading(panel, macro, "CAST_SEQUENCE_TITLE")
	local blocked = ns.CastSequenceBlockReason(macro)
	local own = ns.CastSpellName(macro)
	panel.first.icon:SetTexture(C_Spell.GetSpellTexture(own) or macro.icon or ns.QUESTION_MARK_ICON)
	panel.first.text:SetText(GetColor("TITLE") .. own .. "|r")
	local steps = ns.CastSequenceSteps(macro)
	for i, row in ipairs(panel.rows) do
		row:SetShown(steps[i] ~= nil)
		if steps[i] then
			UpdateStep(row, steps[i], blocked)
		end
	end
	local y = (#steps + 1) * (ROW_HEIGHT + ROW_GAP) + 4
	Docked.SetRowPoint(panel, panel.add, y)
	panel.add:SetEnabled(#steps < ns.CAST_SEQUENCE_MAX_STEPS)
	y = y + 22 + 12
	Docked.SetRowPoint(panel, panel.finish, y)
	panel.finish.dropdown:SetLabel(
		L[ns.CastSequenceStops(macro) and "CAST_SEQUENCE_END_STOP_SHORT" or "CAST_SEQUENCE_END_LOOP"]
	)
	y = y + SETTING_HEIGHT + 4
	Docked.SetRowPoint(panel, panel.reset, y)
	local labels = ns.CastSequenceResetLabels(macro)
	panel.reset.dropdown:SetLabel(
		#labels > 0 and table.concat(labels, L["LIST_SEPARATOR"]) or L["CAST_SEQUENCE_RESET_NEVER"]
	)
	y = y + SETTING_HEIGHT + 6
	local warning = blocked
		or (ns.CastSequenceStops(macro) and not ns.CastSequenceResetText(macro) and L["CAST_SEQUENCE_STOP_NO_RESET"])
	Docked.SetRowPoint(panel, panel.warning, y)
	panel.warning:SetShown(warning ~= nil and warning ~= false)
	panel.warning:SetText(warning and GetColor("OFF") .. warning .. "|r" or "")
	Docked.UpdateFooter(panel.footer, macro)
end

local function CreatePanel(page)
	panel = Docked.Create(page, "GoodToGoCastSequencePanel", "CAST_SEQUENCE_HINT")
	owner.panel = panel

	panel.first = CreateFirst(panel)
	panel.rows = {}
	for i = 1, ns.CAST_SEQUENCE_MAX_STEPS do
		panel.rows[i] = CreateStep(panel, i)
	end
	panel.add = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.add:SetSize(160, 22)
	panel.add:SetText(L["CAST_SEQUENCE_ADD"])
	panel.add:SetMotionScriptsWhileDisabled(true)
	-- the new step has no spell yet, so pick mode starts for it at once
	panel.add:SetScript("OnClick", function()
		ns.CancelSpellPick()
		Change(ns.AddCastSequenceStep)
		local macro = CurrentMacro()
		local steps = macro and ns.CastSequenceSteps(macro) or {}
		if #steps > 0 and not steps[#steps].spellID and not InCombatLockdown() then
			ns.StartSpellPick(owner, #steps)
		end
	end)
	panel.add:SetScript("OnEnter", function(self)
		ShowTip(
			self,
			L["CAST_SEQUENCE_ADD"],
			L["CAST_SEQUENCE_ADD_DESCRIPTION"],
			L["CAST_SEQUENCE_ADD_LIMIT"]:format(ns.CAST_SEQUENCE_MAX_STEPS)
		)
	end)
	panel.add:SetScript("OnLeave", HideTooltip)
	panel.finish = CreateSetting(panel, "CAST_SEQUENCE_END", OpenEndMenu)
	panel.reset = CreateSetting(panel, "CAST_SEQUENCE_RESET", OpenResetMenu)
	panel.warning = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	panel.warning:SetWidth(INNER_WIDTH)
	panel.warning:SetJustifyH("LEFT")
	panel.footer = Docked.CreateFooter(panel)
end

function ns.ShowCastSequencePanel(macro, page)
	if not ns.OffersCastSequence(macro) then
		return
	end
	if not panel then
		CreatePanel(page)
	end
	ns.CancelSpellPick()
	-- one panel docks at a time: the Conditionals panel makes way
	ns.HideConditionalsPanel()
	panel.key = SettingsKey(macro)
	panel:Show()
	RedrawPage()
	Update()
end

function ns.HideCastSequencePanel()
	if panel then
		panel:Hide()
	end
end

-- The rebuild makes the page's macros afresh.
ns.OnSpellbookPageRefreshed(function(page)
	if panel and panel.page == page then
		Update()
	end
end)
