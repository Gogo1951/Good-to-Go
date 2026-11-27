local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local SetTip = ns.MenuSetTip
local HideTooltip = ns.HideTooltip
local Widgets = ns.PanelWidgets
local Box, ShowTip = Widgets.Box, Widgets.ShowTip
local UI = ns.ConditionalsUI
local CurrentMacro, Change, RedrawPage, Update = UI.CurrentMacro, UI.Change, UI.RedrawPage, UI.Update

local INNER_WIDTH = ns.DockedPanel.INNER_WIDTH
local ROW_HEIGHT, ROW_GAP = UI.ROW_HEIGHT, UI.ROW_GAP
local SLOT_ICON, TEXTURE_ARROW = Widgets.SLOT_ICON, UI.TEXTURE_ARROW
local DROPDOWN_MIN_WIDTH = 64
local SLOT_HEIGHT = 32

local COLORS = Widgets.COLORS
local ROW_FILL, ROW_EDGE = COLORS.ROW_FILL, COLORS.ROW_EDGE
local ARROW_INK = COLORS.ARROW_INK
local SKIPPED_ALPHA = 0.5 -- a row the macro text leaves out (ns.ConditionalSkipReason)

-- pick mode's owner
local conditionals = {
	actionKey = "CONDITIONALS_ACTION_USE",
	cannotPickKey = "CONDITIONALS_CANNOT_PICK",
	pickOf = function(macro)
		return ns.ConditionalSpellOf(macro)
	end,
	apply = function(index, pick)
		Change(function(own)
			ns.SetConditionalSpell(own, index, pick)
		end)
	end,
	redraw = function()
		RedrawPage()
	end,
	update = function()
		Update()
	end,
}

-- Read when pick mode starts: the panel's frame is built only when it first opens.
local function Conditionals()
	conditionals.panel = UI.panel
	return conditionals
end

function UI.IsPicking(index)
	return ns.IsPickingSpellFor(conditionals, index)
end

UI.SetPicking = function(index)
	ns.SetSpellPicking(index, Conditionals())
end
UI.PickOwner = Conditionals

local function ConditionLabel(key)
	local condition = ns.ConditionRow(key)
	return condition and L[condition.labelKey] or "?"
end

local function RowAt(index)
	local macro = CurrentMacro()
	return macro, macro and ns.Conditionals(macro)[index]
end

-- Leaves out the row's other condition and the one that can never match beside it.
local function OpenConditionMenu(owner, index, place)
	if not select(2, RowAt(index)) then
		return
	end
	-- the row is read afresh each time it draws, since a pick redraws it in place
	ns.OpenMacroMenuPanels(owner, function(_, root)
		local macro, row = RowAt(index)
		if not row then
			return
		end
		local function AddChoices(menu, at)
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
		AddChoices(root, place)
		-- a gap before the And submenu, a group of its own; a gap and a line before Drop, an action at the foot
		if place == 1 and #row.when < ns.CONDITIONALS_MAX_CONDITIONS then
			root:CreateSpacer()
			local andMenu = root:CreateButton(L["CONDITIONALS_AND_MENU"])
			SetTip(andMenu, L["CONDITIONALS_AND_MENU"], L["CONDITIONALS_AND_DESCRIPTION"])
			AddChoices(andMenu, 2)
		elseif place == 2 then
			root:CreateSpacer()
			root:CreateDivider()
			local element = root:CreateButton(L["CONDITIONALS_DROP_SECOND"], function()
				Change(function(own)
					ns.SetConditionalCondition(own, index, 2, nil)
				end)
			end)
			SetTip(element, L["CONDITIONALS_DROP_SECOND"], L["CONDITIONALS_DROP_SECOND_DESCRIPTION"])
		end
	end, true)
end

-- As wide as its name needs, so "Out Of Combat" reads whole and the spell slot keeps the rest of the row.
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

local function CreateSlot(row)
	local slot = Widgets.CreateSlot(row, SLOT_HEIGHT, SLOT_ICON, 8, UI.PickOwner)
	slot:SetScript("OnEnter", function(self)
		local macro, conditional = RowAt(row.index)
		if not conditional then
			return
		end
		local spellID = ns.ConditionalSpellID(conditional)
		if spellID then
			ns.SetTooltipOwner(self)
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
	ns.DockedPanel.SetRowPoint(parent, row, (index - 1) * (ROW_HEIGHT + ROW_GAP))
	Box(row, ROW_FILL, ROW_EDGE)
	row.drop = Widgets.CreateDropWash(row)
	row.grip = Widgets.CreateGrip(row, UI.panel, "CONDITIONALS_REORDER_DESCRIPTION", function(from, to)
		Change(function(macro)
			ns.MoveConditional(macro, from, to)
		end)
	end, Update)
	row.first = CreateDropdown(row, 1)
	row.first:SetPoint("LEFT", row.grip, "RIGHT", 8, 0)
	row.andText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	row.andText:SetTextColor(unpack(ARROW_INK))
	row.andText:SetPoint("LEFT", row.first, "RIGHT", 8, 0)
	row.andText:SetText(L["CONDITIONALS_AND"])
	row.second = CreateDropdown(row, 2)
	row.second:SetPoint("LEFT", row.andText, "RIGHT", 8, 0)
	row.arrow = row:CreateTexture(nil, "ARTWORK")
	row.arrow:SetTexture(TEXTURE_ARROW)
	row.arrow:SetVertexColor(unpack(ARROW_INK))
	row.arrow:SetSize(16, 16)
	row.remove = Widgets.CreateRemove(row, "CONDITIONALS_REMOVE_DESCRIPTION", function()
		Change(function(macro)
			ns.RemoveConditional(macro, index)
		end)
	end)
	row.slot = CreateSlot(row)
	row.slot:SetPoint("LEFT", row.arrow, "RIGHT", 8, 0)
	row.slot:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
	return row
end

local function UpdateRow(row, macro, conditional)
	row:SetAlpha(ns.ConditionalSkipReason(macro, row.index) and SKIPPED_ALPHA or 1)
	local when = conditional.when or {}
	row.first:SetLabel(ConditionLabel(when[1]))
	local two = when[2] ~= nil
	row.andText:SetShown(two)
	row.second:SetShown(two)
	row.second:SetLabel(two and ConditionLabel(when[2]) or "")
	row.arrow:ClearAllPoints()
	row.arrow:SetPoint("LEFT", two and row.second or row.first, "RIGHT", 8, 0)
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
