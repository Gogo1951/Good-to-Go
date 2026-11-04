local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local SetTip = ns.MenuSetTip
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local SettingsKey = ns.SettingsKey
local Docked = ns.DockedPanel
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip

--[[
	The Cast Sequence panel, docked against the Spell Book window's right edge where the Conditionals panel docks
	(one at a time), and opened from a macro's menu (Features/Spellbook/Macro-Menu.lua). It lists the sequence
	(Features/Spellbook/Macro-Builder/Cast-Sequence.lua) top to bottom: the macro's own spell, fixed as the first step, then
	each step added, with a grip to drag it up or down, its spell and its remove button. Under them the Add Step
	button, what happens after the last step (Start Over, or Stop on NULL), when the sequence starts over, and
	the macro text with its length against what a macro holds, which follow every change.

	A step's spell slot takes a spell as a Conditionals row's does, by pick mode or a drag
	(Features/Spellbook/Macro-Builder/Conditionals-Pick.lua). Every change rebuilds the page (ns.RefreshSpellbookPage), which
	rewrites the macro; the panel holds its macro's settings key and finds it again after each refresh.
	The frame, its heading and footer are Features/Spellbook/Macro-Builder/Docked-Panel.lua, shared with the
	Conditionals panel, as are the controls in Features/Spellbook/Macro-Builder/Panel-Widgets.lua.
]]

local PADDING, INNER_WIDTH = Docked.PADDING, Docked.INNER_WIDTH
local SLOT_ICON = Widgets.SLOT_ICON
local ROWS_TOP = 72
local ROW_HEIGHT, ROW_GAP = 30, 4 -- shorter than a Conditionals row, so eight steps leave the footer room
local NUMBER_WIDTH = 18
local SLOT_HEIGHT = 24
local SETTING_HEIGHT, SETTING_LABEL_WIDTH = 28, 150

local COLORS = Widgets.COLORS
local PANEL_FILL = COLORS.PANEL_FILL
local ROW_FILL, ROW_EDGE = COLORS.ROW_FILL, COLORS.ROW_EDGE
local MUTED_INK = COLORS.MUTED_INK
local BLOCKED_ALPHA = 0.5 -- the steps while something keeps the sequence from writing (ns.CastSequenceBlockReason)

local panel

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

-- The page macro the panel is open for, found again by its settings key, or nil once it has left the page.
local function CurrentMacro()
	return Docked.CurrentMacro(panel, ns.OffersCastSequence)
end

-- Runs a setter on the macro, set(macro), and rebuilds the page, which rewrites the macro and redraws the panel.
local function Change(set)
	Docked.Change(panel, ns.OffersCastSequence, set)
end

-- Whether the panel is open for a page macro, so its tile is outlined on the page.
function ns.IsCastSequencePanelFor(macro)
	return panel ~= nil and panel:IsShown() and ns.OffersCastSequence(macro) and SettingsKey(macro) == panel.key
end

-- Redraws the page's tiles, for their outline and pick-mode dimming, without rebuilding its macros.
local function RedrawPage()
	Docked.RedrawPage(panel)
end

local Update -- below; the rows and pick mode call it

-- The panel as pick mode's owner (Features/Spellbook/Macro-Builder/Conditionals-Pick.lua): a step's spell slot.
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

-- A step's number at a row's left, in the muted ink.
local function NumberText(row, number)
	local text = SizedFontString(row, "GameFontHighlightSmall", 12)
	text:SetTextColor(unpack(MUTED_INK))
	text:SetWidth(NUMBER_WIDTH)
	text:SetJustifyH("CENTER")
	text:SetText(number)
	return text
end

-- A setting's line under the steps: its label on the left and its dropdown after it.
local function CreateSetting(parent, labelKey, openMenu)
	local setting = CreateFrame("Frame", nil, parent)
	setting:SetSize(INNER_WIDTH, SETTING_HEIGHT)
	local label = SizedFontString(setting, "GameFontNormal", 13)
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

-- After The Last Step: Start Over, or Stop on NULL.
local function OpenEndMenu(owner_)
	local macro = CurrentMacro()
	if not macro then
		return
	end
	MenuUtil.CreateContextMenu(owner_, function(_, root)
		for _, choice in ipairs({
			{ false, "CAST_SEQUENCE_END_LOOP", "CAST_SEQUENCE_END_LOOP_DESCRIPTION" },
			{ true, "CAST_SEQUENCE_END_STOP", "CAST_SEQUENCE_END_STOP_DESCRIPTION" },
		}) do
			local stops = choice[1]
			local element = root:CreateRadio(L[choice[2]], function()
				return ns.CastSequenceStops(macro) == stops
			end, function()
				Change(function(own)
					ns.SetCastSequenceStops(own, stops)
				end)
			end)
			SetTip(element, L[choice[2]], L[choice[3]])
		end
	end)
end

-- Start Over When: each reset key, ticked on or off, then the seconds idle, a choice of one.
local function OpenResetMenu(owner_)
	local macro = CurrentMacro()
	if not macro then
		return
	end
	MenuUtil.CreateContextMenu(owner_, function(_, root)
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
		root:CreateDivider()
		local secondsMenu = root:CreateButton(L["CAST_SEQUENCE_RESET_SECONDS_MENU"])
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
	end)
end

--------------------------------------------------------------------------------
-- Steps
--------------------------------------------------------------------------------

-- The macro and the step at index, or nil for either once they are gone.
local function StepAt(index)
	local macro = CurrentMacro()
	return macro, macro and ns.CastSequenceSteps(macro)[index]
end

-- The first step, the macro's own spell: drawn muted, with no controls.
local function CreateFirst(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	row:SetPoint("TOPLEFT", PADDING, -ROWS_TOP)
	row:SetAlpha(0.8)
	row:EnableMouse(true)
	Box(row, PANEL_FILL, ROW_EDGE)
	local number = NumberText(row, "1")
	number:SetPoint("LEFT", 6 + 12 + 6, 0) -- in line with the steps' numbers, after their grips
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(SLOT_ICON, SLOT_ICON)
	row.icon:SetPoint("LEFT", number, "RIGHT", 9, 0)
	local first = SizedFontString(row, "GameFontHighlightSmall", 12)
	first:SetTextColor(unpack(MUTED_INK))
	first:SetPoint("RIGHT", -10, 0)
	first:SetText(L["CAST_SEQUENCE_FIRST"])
	row.text = SizedFontString(row, "GameFontNormal", 13)
	row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.text:SetPoint("RIGHT", first, "LEFT", -8, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	row:SetScript("OnEnter", function(self)
		ShowTip(self, L["CAST_SEQUENCE_FIRST"], L["CAST_SEQUENCE_FIRST_DESCRIPTION"])
	end)
	row:SetScript("OnLeave", HideTooltip)
	return row
end

-- A step's spell slot: the spell's icon and name, or what to do to give it one.
local function CreateSlot(row)
	local slot = Widgets.CreateSlot(row, SLOT_HEIGHT, SLOT_ICON - 2, 2, function()
		return owner
	end)
	-- the spell's own tooltip, or what to do while the slot is empty; then the clicks
	slot:SetScript("OnEnter", function(self)
		local _, step = StepAt(row.index)
		if not step then
			return
		end
		if step.spellID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(step.spellID)
		else
			ShowTip(self, L["CONDITIONALS_PICK_SPELL"], L["CONDITIONALS_SLOT_DESCRIPTION"])
		end
		Widgets.AddSlotHints(ns.IsPickingSpellFor(owner, row.index), "CAST_SEQUENCE_ACTION_DROP")
	end)
	return slot
end

local function CreateStep(parent, index)
	local row = CreateFrame("Frame", nil, parent)
	row.index = index
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	row:SetPoint("TOPLEFT", PADDING, -(ROWS_TOP + index * (ROW_HEIGHT + ROW_GAP)))
	Box(row, ROW_FILL, ROW_EDGE)
	row.drop = Widgets.CreateDropWash(row)
	row.grip = Widgets.CreateGrip(row, panel, "CAST_SEQUENCE_REORDER_DESCRIPTION", function(from, to)
		Change(function(macro)
			ns.MoveCastSequenceStep(macro, from, to)
		end)
	end, Update)
	local number = NumberText(row, tostring(index + 1))
	number:SetPoint("LEFT", row.grip, "RIGHT", 6, 0)
	row.remove = Widgets.CreateRemove(row, "CAST_SEQUENCE_REMOVE_DESCRIPTION", function()
		Change(function(macro)
			ns.RemoveCastSequenceStep(macro, index)
		end)
	end)
	row.slot = CreateSlot(row)
	row.slot:SetPoint("LEFT", number, "RIGHT", 6, 0)
	row.slot:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
	return row
end

-- Draws a step: its spell, or the slot waiting in pick mode, or the slot asking for one.
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

--[[
	Redraws the panel for its macro: the heading, the first step and the steps after it, the Add Step button
	under the last, the end and reset settings, a red line where the sequence stops for good or can't write, and
	the footer. Closes it once its macro has left the page.
]]
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
	local y = ROWS_TOP + (#steps + 1) * (ROW_HEIGHT + ROW_GAP) + 4
	panel.add:SetPoint("TOPLEFT", PADDING, -y)
	panel.add:SetEnabled(#steps < ns.CAST_SEQUENCE_MAX_STEPS)
	y = y + 22 + 12
	panel.finish:SetPoint("TOPLEFT", PADDING, -y)
	panel.finish.dropdown:SetLabel(
		L[ns.CastSequenceStops(macro) and "CAST_SEQUENCE_END_STOP" or "CAST_SEQUENCE_END_LOOP"]
	)
	y = y + SETTING_HEIGHT + 4
	panel.reset:SetPoint("TOPLEFT", PADDING, -y)
	local labels = ns.CastSequenceResetLabels(macro)
	panel.reset.dropdown:SetLabel(#labels > 0 and table.concat(labels, ", ") or L["CAST_SEQUENCE_RESET_NEVER"])
	y = y + SETTING_HEIGHT + 6
	local warning = blocked
		or (ns.CastSequenceStops(macro) and not ns.CastSequenceResetText(macro) and L["CAST_SEQUENCE_STOP_NO_RESET"])
	panel.warning:SetPoint("TOPLEFT", PADDING, -y)
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
	panel.add:SetSize(150, 22)
	panel.add:SetText(L["CAST_SEQUENCE_ADD"])
	panel.add:SetMotionScriptsWhileDisabled(true)
	-- the new step has no spell yet, so pick mode starts for it at once
	panel.add:SetScript("OnClick", function()
		ns.CancelConditionalPick()
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
	panel.warning = SizedFontString(panel, "GameFontHighlightSmall", 12)
	panel.warning:SetWidth(INNER_WIDTH)
	panel.warning:SetJustifyH("LEFT")
	panel.footer = Docked.CreateFooter(panel)
end

-- Opens the panel for a page macro (from its menu), or moves it to that macro when it is open for another.
function ns.ShowCastSequencePanel(macro, page)
	if not ns.OffersCastSequence(macro) then
		return
	end
	if not panel then
		CreatePanel(page)
	end
	ns.CancelConditionalPick()
	-- one panel docks at a time: the Conditionals panel makes way
	ns.HideConditionalsPanel()
	panel.key = SettingsKey(macro)
	panel:Show()
	RedrawPage()
	Update()
end

-- Closes the panel, for the window's switch to another tab and the Conditionals panel opening.
function ns.HideCastSequencePanel()
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
