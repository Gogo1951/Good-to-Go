local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local SetTip = ns.MenuSetTip
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip
local UI = ns.ConditionalsUI
local CurrentMacro, Change, Update = UI.CurrentMacro, UI.Change, UI.Update

--[[
	The Conditionals panel's rows (Features/Spellbook/Macro-Builder/Conditionals-Panel.lua): a grip to drag a row up or down,
	one or two condition dropdowns joined by "and", the spell the row casts and its remove button, built from the
	controls in Features/Spellbook/Macro-Builder/Panel-Widgets.lua.
]]

local PADDING, INNER_WIDTH = ns.DockedPanel.PADDING, ns.DockedPanel.INNER_WIDTH
local ROWS_TOP, ROW_HEIGHT, ROW_GAP = UI.ROWS_TOP, UI.ROW_HEIGHT, UI.ROW_GAP
local SLOT_ICON, TEXTURE_ARROW = Widgets.SLOT_ICON, UI.TEXTURE_ARROW
local DROPDOWN_MIN_WIDTH = 56
local SLOT_HEIGHT = 28

local COLORS = Widgets.COLORS
local ROW_FILL, ROW_EDGE = COLORS.ROW_FILL, COLORS.ROW_EDGE
local ARROW_INK = COLORS.ARROW_INK
local SKIPPED_ALPHA = 0.5 -- a row the macro text leaves out (ns.ConditionalSkipReason)

-- A condition's label, or a question mark for a key this client doesn't know.
local function ConditionLabel(key)
	local condition = ns.ConditionRow(key)
	return condition and L[condition.labelKey] or "?"
end

-- The macro and the row at index, or nil for either once they are gone.
local function RowAt(index)
	local macro = CurrentMacro()
	return macro, macro and ns.Conditionals(macro)[index]
end

--[[
	A condition dropdown's menu, for the condition at place in the row: every condition offered, less the one
	the row's other place holds and the one that can never match beside it, each explaining itself, a condition
	the macro can't use (ns.ConditionBlockReason) greyed with why. The first dropdown also offers And, a second
	condition, while the row has one; the second offers dropping itself.
]]
local function OpenConditionMenu(owner, index, place)
	local macro = CurrentMacro()
	local row = macro and ns.Conditionals(macro)[index]
	if not row then
		return
	end
	MenuUtil.CreateContextMenu(owner, function(_, root)
		local function addChoices(menu, at)
			local other = row.when[at == 1 and 2 or 1]
			local opposite = other and ns.ConditionRow(other) and ns.ConditionRow(other).opposite
			for _, condition in ipairs(ns.CONDITIONS) do
				local key = condition.key
				local current = row.when[at] == key
				if (current or ns.OffersCondition(key)) and key ~= other and key ~= opposite then
					local label = ns.ConditionMenuLabel(condition)
					local element = menu:CreateRadio(label, function()
						return row.when[at] == key
					end, function()
						Change(function(own)
							ns.SetConditionalCondition(own, index, at, key)
						end)
					end)
					local reason = ns.ConditionBlockReason(macro, key)
					SetTip(element, label, L[condition.descKey], reason)
					if reason and not current then
						element:SetEnabled(false)
					end
				end
			end
		end
		addChoices(root, place)
		if place == 1 and #row.when < ns.CONDITIONALS_MAX_CONDITIONS then
			root:CreateDivider()
			local andMenu = root:CreateButton(L["CONDITIONALS_AND_MENU"])
			SetTip(andMenu, L["CONDITIONALS_AND_MENU"], L["CONDITIONALS_AND_DESCRIPTION"])
			addChoices(andMenu, 2)
		elseif place == 2 then
			root:CreateDivider()
			local element = root:CreateButton(L["CONDITIONALS_DROP_SECOND"], function()
				Change(function(own)
					ns.SetConditionalCondition(own, index, 2, nil)
				end)
			end)
			SetTip(element, L["CONDITIONALS_DROP_SECOND"], L["CONDITIONALS_DROP_SECOND_DESCRIPTION"])
		end
	end)
end

--[[
	A condition dropdown in a row: a dark field with the condition's name and a caret, as wide as its name needs,
	so "Out Of Combat" reads whole and the spell slot keeps the rest of the row.
]]
local function CreateDropdown(row, place)
	local dropdown = Widgets.CreateDropdown(row, function(width)
		return math.max(DROPDOWN_MIN_WIDTH, width)
	end, function(self)
		OpenConditionMenu(self, row.index, place)
	end)
	dropdown:SetScript("OnEnter", function(self)
		local macro, conditional = RowAt(row.index)
		local key = conditional and conditional.when[place]
		local condition = key and ns.ConditionRow(key)
		if condition then
			local reason = ns.ConditionBlockReason(macro, key) or ns.ConditionalSkipReason(macro, row.index)
			ShowTip(self, L[condition.labelKey], L[condition.descKey], reason)
		end
	end)
	dropdown:SetScript("OnLeave", HideTooltip)
	return dropdown
end

-- A row's spell slot: the spell's icon and name, or what to do to give it one.
local function CreateSlot(row)
	local slot = Widgets.CreateSlot(row, SLOT_HEIGHT, SLOT_ICON, 3, UI.PickOwner)
	--[[
		the spell's own tooltip, as a tile shows it, or what to do while the slot is empty; then why the row never
		casts, if it doesn't, and the clicks
	]]
	slot:SetScript("OnEnter", function(self)
		local macro, conditional = RowAt(row.index)
		if not conditional then
			return
		end
		local spellID = ns.ConditionalSpellID(conditional)
		if spellID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(spellID)
		else
			ShowTip(self, L["CONDITIONALS_PICK_SPELL"], L["CONDITIONALS_SLOT_DESCRIPTION"])
		end
		local reason = ns.ConditionalSkipReason(macro, row.index)
		if reason then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GetColor("OFF") .. reason .. "|r", nil, nil, nil, true)
		end
		Widgets.AddSlotHints(UI.IsPicking(row.index), "CONDITIONALS_ACTION_DROP")
	end)
	return slot
end

local function CreateRow(parent, index)
	local row = CreateFrame("Frame", nil, parent)
	row.index = index
	row:SetHeight(ROW_HEIGHT)
	row:SetWidth(INNER_WIDTH)
	row:SetPoint("TOPLEFT", PADDING, -(ROWS_TOP + (index - 1) * (ROW_HEIGHT + ROW_GAP)))
	Box(row, ROW_FILL, ROW_EDGE)
	row.drop = Widgets.CreateDropWash(row)
	row.grip = Widgets.CreateGrip(row, UI.panel, "CONDITIONALS_REORDER_DESCRIPTION", function(from, to)
		Change(function(macro)
			ns.MoveConditional(macro, from, to)
		end)
	end, Update)
	row.first = CreateDropdown(row, 1)
	row.first:SetPoint("LEFT", row.grip, "RIGHT", 6, 0)
	row.andText = SizedFontString(row, "GameFontHighlightSmall", 12)
	row.andText:SetTextColor(unpack(ARROW_INK))
	row.andText:SetPoint("LEFT", row.first, "RIGHT", 6, 0)
	row.andText:SetText(L["CONDITIONALS_AND"])
	row.second = CreateDropdown(row, 2)
	row.second:SetPoint("LEFT", row.andText, "RIGHT", 6, 0)
	row.arrow = row:CreateTexture(nil, "ARTWORK")
	row.arrow:SetTexture(TEXTURE_ARROW)
	row.arrow:SetVertexColor(unpack(ARROW_INK))
	row.arrow:SetSize(12, 12)
	row.remove = Widgets.CreateRemove(row, "CONDITIONALS_REMOVE_DESCRIPTION", function()
		Change(function(macro)
			ns.RemoveConditional(macro, index)
		end)
	end)
	row.slot = CreateSlot(row)
	row.slot:SetPoint("LEFT", row.arrow, "RIGHT", 6, 0)
	row.slot:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
	return row
end

--[[
	Draws a row: its conditions, the "and" and second dropdown only when it has two, and its spell, or the slot
	waiting in pick mode, or the slot asking for one. A row the macro text leaves out (ns.ConditionalSkipReason)
	is drawn faded; its tooltips say why.
]]
local function UpdateRow(row, macro, conditional)
	row:SetAlpha(ns.ConditionalSkipReason(macro, row.index) and SKIPPED_ALPHA or 1)
	local when = conditional.when or {}
	row.first:SetLabel(ConditionLabel(when[1]))
	local two = when[2] ~= nil
	row.andText:SetShown(two)
	row.second:SetShown(two)
	row.second:SetLabel(two and ConditionLabel(when[2]) or "")
	row.arrow:ClearAllPoints()
	row.arrow:SetPoint("LEFT", two and row.second or row.first, "RIGHT", 6, 0)
	local slot = row.slot
	if UI.IsPicking(row.index) then
		Widgets.DrawPickingSlot(slot)
	elseif ns.ConditionalHasSpell(conditional) then
		local name, rank = ns.ConditionalSpellName(conditional)
		local spellID = ns.ConditionalSpellID(conditional)
		Widgets.DrawSpellSlot(slot, spellID, name, rank)
	else
		Widgets.DrawEmptySlot(slot)
	end
end

UI.CreateRow, UI.UpdateRow = CreateRow, UpdateRow
