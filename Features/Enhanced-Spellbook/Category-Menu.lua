local _, ns = ...
local L = ns.L
-- From Menu-Utilities.lua, which loads first.
local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local DESCRIPTIONS, NOTES = ns.MENU_DESCRIPTIONS, ns.MENU_NOTES
local COMBAT, REPEAT, FIRST, ERRORS = ns.MENU_COMBAT, ns.MENU_REPEAT, ns.MENU_FIRST, ns.MENU_ERRORS

-- A category's name for its gear's tooltip and its menu's header: "All 6 Heals", or This Spell for one.
function ns.CategoryMenuTitle(name, count)
	if count == 1 then
		return L["PAGE_CATEGORY_SETTINGS_ONE"]
	end
	return L["MENU_CATEGORY_TITLE"]:format(count, name)
end

-- data is the reset to run.
StaticPopupDialogs.GOODTOGO_RESET_CATEGORY = {
	text = L["MENU_RESET_CATEGORY_CONFIRM"],
	button1 = L["POPUP_RESET"],
	button2 = CANCEL,
	OnAccept = function(_, data)
		data()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

--[[
	Each option applies to every macro here that offers it, ticked only when all have it. Each spell's own
	choices (fixed rank, grouped spells, pet ability, stance) and the actions stay on its own menu.
]]
function ns.ShowCategoryMenu(owner, name, macros, onChange)
	local list = {}
	for _, macro in ipairs(macros) do
		if ns.HasOptions(macro) then
			list[#list + 1] = macro
		end
	end
	if #list == 0 then
		return
	end
	local function offering(test)
		local found = {}
		for _, macro in ipairs(list) do
			if test(macro) then
				found[#found + 1] = macro
			end
		end
		return found
	end
	local function offeringOption(key)
		return offering(function(macro)
			return ns.OffersOption(macro, key)
		end)
	end
	local function all(targets, test)
		for _, macro in ipairs(targets) do
			if not test(macro) then
				return false
			end
		end
		return true
	end
	-- one redraw for all: it rewrites every macro already made, so none is rewritten on its own first
	local function apply(targets, set)
		for _, macro in ipairs(targets) do
			set(macro)
		end
		onChange()
	end

	ns.OpenMacroMenuPanels(owner, function(_, root)
		root:CreateHeader(ns.CategoryMenuTitle(name, #macros), L["ADDON_SHORT_NAME"])
		-- groups of rows sit apart by a gap, as the mini-map menu's do; the reset sits under a line as well
		local function gap()
			root:CreateSpacer()
		end

		-- what each submenu has on for every macro, by label, for its button's value as the single-spell menu shows
		local picked = {}
		local function track(menu, label, isOn)
			picked[menu] = picked[menu] or {}
			table.insert(picked[menu], { label = label, isOn = isOn })
		end
		local function pickedLabels(menu)
			local labels = {}
			for _, entry in ipairs(picked[menu] or {}) do
				if entry.isOn() then
					labels[#labels + 1] = entry.label
				end
			end
			return labels
		end

		-- labelsOf lists the labels its value shows, its own picks unless given
		local function submenu(parent, label, labelsOf)
			local button = parent:CreateButton(label)
			button:SetValue(function()
				return ns.MacroMenuGroupValue((labelsOf or pickedLabels)(button))
			end)
			return button
		end

		-- on every macro offering it, or on targets when given; returns whether it was added
		local function checkbox(menu, key, label, targets)
			targets = targets or offeringOption(key)
			if #targets == 0 then
				return false
			end
			local function isOn()
				return all(targets, function(macro)
					return ns.IsOptionOn(macro, key)
				end)
			end
			local element = menu:CreateCheckbox(label, isOn, function()
				local on = not isOn()
				apply(targets, function(macro)
					ns.SetOption(macro, key, on)
				end)
			end)
			OptionTip(element, key, label)
			track(menu, label, isOn)
			return true
		end
		-- a choice of one for targets: picked when each of them has it, and set on all of them
		local function radio(menu, label, targets, isOn, set, tip, note)
			local function isPicked()
				return all(targets, isOn)
			end
			local element = menu:CreateRadio(label, isPicked, function()
				apply(targets, set)
				return MenuResponse.Refresh
			end)
			SetTip(element, label, tip, note)
			track(menu, label, isPicked)
		end
		local function anyOffered(options)
			for _, option in ipairs(options) do
				if option[2] and #offeringOption(option[1]) > 0 then
					return true
				end
			end
			return false
		end

		local above = false
		for _, option in ipairs({ { "cursor", L["MENU_CAST_AT_CURSOR"] }, { "noToggle", L["MENU_NEVER_TURN_OFF"] } }) do
			above = checkbox(root, option[1], option[2]) or above
		end
		-- Target, Grouped and Rank are one group, opened by a gap below the checkboxes
		local opened = false
		local function section()
			if above and not opened then
				gap()
			end
			above, opened = true, true
		end

		-- Target
		local prioritized = offering(ns.OffersTargetPriority)
		if #prioritized > 0 then
			section()
			local slotMenus = {}
			local targetMenu = submenu(root, L["MENU_GROUP_TARGET"], function()
				local units = {}
				for _, slotMenu in ipairs(slotMenus) do
					local unit = pickedLabels(slotMenu)[1]
					if unit and unit ~= L["MENU_UNIT_NONE"] then
						units[#units + 1] = unit
					end
				end
				return #units > 0 and { table.concat(units, L["LIST_SEPARATOR"]) } or {}
			end)
			for place = 1, ns.TARGET_PRIORITY_SLOTS do
				local placeKey = "MENU_PRIORITY_" .. place
				local slotMenu = submenu(targetMenu, L[placeKey])
				slotMenus[place] = slotMenu
				SetTip(slotMenu, L[placeKey], L["MENU_PRIORITY_DESCRIPTION"])
				if place > 1 then
					radio(slotMenu, L["MENU_UNIT_NONE"], prioritized, function(macro)
						return ns.TargetPriority(macro)[place] == nil
					end, function(macro)
						ns.SetTargetPriorityUnit(macro, place, nil)
					end, L["MENU_UNIT_NONE_DESCRIPTION"])
				end
				for _, row in ipairs(ns.TARGET_UNITS) do
					local unit = row[1]
					local targets = offering(function(macro)
						return ns.OffersTargetPriority(macro) and ns.KindOffersUnit(macro.kind, unit)
					end)
					if #targets > 0 then
						radio(slotMenu, L[row[2]], targets, function(macro)
							return ns.TargetPriority(macro)[place] == unit
						end, function(macro)
							ns.SetTargetPriorityUnit(macro, place, unit)
						end, L[row[2] .. "_DESCRIPTION"])
					end
				end
			end
		end

		-- Grouped: skips macros with a Right-Click Conditional, as the single-spell menu does
		local rightClick = offering(function(macro)
			return ns.OffersOption(macro, "groupVersion") and not ns.ConditionalsUseRightClick(macro)
		end)
		if #rightClick > 0 then
			section()
			local groupedMenu = submenu(root, L["MENU_GROUP_GROUPED"])
			checkbox(groupedMenu, "groupVersion", L["MENU_RIGHT_CLICK_GROUP"], rightClick)
		end

		-- Rank: Highest or Dynamic only
		local ranked = offering(function(macro)
			return ns.OffersFixedRank(macro) or ns.OffersTargetRank(macro)
		end)
		if #ranked > 0 then
			section()
			local rankMenu = submenu(root, L["MENU_GROUP_RANK"])
			radio(rankMenu, L["MENU_HIGHEST"], ranked, function(macro)
				return ns.AbilityRank(macro) == nil
			end, function(macro)
				ns.SetAbilityRank(macro, nil)
			end, L["MENU_HIGHEST_DESCRIPTION"])
			local dynamic = offering(ns.OffersTargetRank)
			if #dynamic > 0 then
				radio(rankMenu, L["MENU_DYNAMIC_RANK"], dynamic, function(macro)
					return ns.AbilityRank(macro) == "targetRank"
				end, function(macro)
					ns.SetAbilityRank(macro, "targetRank")
				end, L[DESCRIPTIONS.targetRank], L[NOTES.targetRank])
			end
		end
		if above then
			gap()
		end

		-- When
		local whenMenu = submenu(root, L["MENU_GROUP_WHEN"])
		local checked = offeringOption("combatOnly")
		for _, choice in ipairs(COMBAT) do
			local check = choice[1]
			radio(whenMenu, L[choice[2]], checked, function(macro)
				return ns.CombatCheck(macro) == check
			end, function(macro)
				ns.SetCombatCheck(macro, check)
			end, L[choice[3]])
		end
		local repeating = offeringOption("oncePerTarget")
		if #repeating > 0 then
			whenMenu:CreateSpacer()
			for _, choice in ipairs(REPEAT) do
				local rule = choice[1]
				radio(whenMenu, L[choice[2]], repeating, function(macro)
					return ns.RepeatRule(macro) == rule
				end, function(macro)
					ns.SetRepeatRule(macro, rule)
				end, L[choice[3]])
			end
		end
		whenMenu:CreateSpacer()
		checkbox(whenMenu, "stopIfChanneling", L["MENU_STOP_IF_CHANNELING"])
		checkbox(whenMenu, "stopIfStealthed", L["MENU_STOP_IF_STEALTHED"])

		-- First, a group apart from When
		local itemUsers = offering(ns.OffersUseItems)
		local slots = #itemUsers > 0 and ns.UsableSlots() or {}
		if anyOffered(FIRST) or #slots > 0 then
			gap()
			local firstMenu = submenu(root, L["MENU_GROUP_FIRST"])
			local offered = false
			for _, option in ipairs(FIRST) do
				offered = checkbox(firstMenu, option[1], L[option[2]]) or offered
			end
			if offered and #slots > 0 then
				firstMenu:CreateSpacer()
			end
			for _, usable in ipairs(slots) do
				local slot = usable.slot
				local function isOn()
					return all(itemUsers, function(macro)
						return ns.IsUsingSlot(macro, slot) ~= nil
					end)
				end
				local icon = GetInventoryItemTexture("player", slot)
				local label = (icon and "|T" .. icon .. ":0|t " or "") .. ns.SlotLabel(slot)
				local element = firstMenu:CreateCheckbox(label, isOn, function()
					local on = not isOn()
					apply(itemUsers, function(macro)
						if (ns.IsUsingSlot(macro, slot) ~= nil) ~= on then
							ns.ToggleUseSlot(macro, slot)
						end
					end)
				end)
				SetTip(element, ns.SlotLabel(slot), L["MENU_USE_ITEM_DESCRIPTION"])
				track(firstMenu, ns.SlotLabel(slot), isOn)
			end
		end

		-- Then
		local THEN = ns.MenuThenOptions()
		if anyOffered(THEN) then
			local thenMenu = submenu(root, L["MENU_GROUP_THEN"])
			for _, option in ipairs(THEN) do
				if option[2] then
					checkbox(thenMenu, option[1], option[2])
				end
			end
		end

		gap()
		local errorsMenu = submenu(root, L["MENU_GROUP_ERRORS"])
		for _, option in ipairs(ERRORS) do
			checkbox(errorsMenu, option[1], L[option[2]])
		end

		-- last, apart from the options: every macro here back to its kind's defaults, as a tile's middle-click
		gap()
		root:CreateDivider()
		-- a whole category's hand-set options take real effort to set again, so it asks first
		local resetLabel = #macros == 1 and L["TOOLTIP_ACTION_RESET_OPTIONS"]
			or L["TOOLTIP_ACTION_RESET_CATEGORY"]:format(#macros, name)
		local reset = root:CreateButton(resetLabel, function()
			StaticPopup_Show("GOODTOGO_RESET_CATEGORY", name, nil, function()
				for _, macro in ipairs(list) do
					ns.ResetMacroSettings(macro)
				end
				onChange()
				ns:PrintMessage(L["CHAT_CATEGORY_OPTIONS_RESET"]:format(name))
			end)
		end)
		SetTip(reset, resetLabel, L["MENU_RESET_CATEGORY_DESCRIPTION"])
	end, true)
end
