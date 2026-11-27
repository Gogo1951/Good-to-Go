local _, ns = ...
local L = ns.L
local Kit = ns.MenuKit

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip

function ns.ShowMacroMenu(button)
	local macro = button.macro
	if not ns.HasOptions(macro) then
		return
	end
	local page = button.page
	local menuState = { button = button, page = page, macro = macro }
	-- the rebuild replaces every macro entry, so the menu re-finds its own
	local function change(set)
		set()
		ns.RefreshSpellbookPage(page)
		macro = ns.MacroMenuRebuiltMacro(macro)
		menuState.macro = macro
	end
	menuState.change = change

	ns.OpenMacroMenuPanels(button, function(_, root)
		root:CreateHeader(macro.label or macro.name, L["ADDON_SHORT_NAME"])
		-- groups of rows sit apart by a gap, as the mini-map menu's do; the actions sit under a line as well
		local function gap()
			root:CreateSpacer()
		end

		local function checkbox(menu, key, label)
			local element = menu:CreateCheckbox(label, function()
				return ns.IsOptionOn(macro, key)
			end, function()
				change(function()
					ns.ToggleOption(macro, key)
				end)
			end)
			OptionTip(element, key, label)
			return element
		end
		-- keeps the menu open
		local function radio(menu, label, isOn, set, tip, note)
			local element = menu:CreateRadio(label, isOn, function()
				change(set)
				return MenuResponse.Refresh
			end)
			SetTip(element, label, tip, note)
			return element
		end
		-- onLabels lists what is on, re-read on each redraw; color, when given, is a palette key for the value
		local function group(labelKey, onLabels, color)
			local menu = root:CreateButton(L[labelKey])
			menu:SetSetting()
			menu:SetValue(function()
				local value = ns.MacroMenuGroupValue(onLabels())
				return value and color and Kit.Color(color, value) or value
			end)
			return menu
		end
		local function addMacroText()
			local menu = root:CreateButton(L["MACRO_TEXT"])
			menu:SetValue(function()
				local length = #macro.body
				return Kit.Color(
					length > ns.MACRO_BODY_MAX_LENGTH and "OFF" or "VALUE",
					L["MENU_MACRO_LENGTH"]:format(length, ns.MACRO_BODY_MAX_LENGTH)
				)
			end)
			menu:CreateText(function()
				return table.concat(ns.MacroMenuBodyLines(macro), "\n")
			end)
		end

		local function addMacroStorage()
			local menu = group("MENU_GROUP_MACRO_STORAGE", function()
				local general = ns.MacroTab(macro) == ns.MACRO_TAB_GENERAL
				return { L[general and "MENU_MACRO_TAB_GENERAL" or "MENU_MACRO_TAB_CHARACTER"] }
			end)
			for _, choice in ipairs({
				{ ns.MACRO_TAB_CHARACTER, "MENU_MACRO_TAB_CHARACTER" },
				{ ns.MACRO_TAB_GENERAL, "MENU_MACRO_TAB_GENERAL" },
			}) do
				local tab, labelKey = choice[1], choice[2]
				radio(menu, L[labelKey], function()
					return ns.MacroTab(macro) == tab
				end, function()
					ns.SetMacroTab(macro, tab)
				end, L[labelKey .. "_DESCRIPTION"], L["MENU_MACRO_TAB_NOTE"])
			end
		end

		-- always asked first, the ask saying whether it comes off the bars
		local function addDelete()
			local index = ns.FindMacroIndex(macro)
			local used = index ~= 0 and ns.MacroBarCount(index) or 0
			local note = used == 1 and L["MENU_DELETE_USED_ONE"] or used > 1 and L["MENU_DELETE_USED"]:format(used)
			local element = root:CreateButton(L["MENU_DELETE"], function()
				ns.ConfirmDelete(macro.label or macro.name, function()
					ns.DeletePageMacro(macro)
					ns.RefreshSpellbookPage(page)
				end, used == 0)
			end)
			element:SetValue(note)
			SetTip(
				element,
				L["MENU_DELETE"],
				L[macro.copy and "MENU_DELETE_COPY_DESCRIPTION" or "MENU_DELETE_DESCRIPTION"]
			)
		end

		-- groups up to When sit a gap apart; sections within a group follow straight on
		local above, opened = false, false
		local function section()
			if above and not opened then
				gap()
			end
			above, opened = true, true
		end
		local function closeGroup()
			opened = false
		end
		local isFeatured = {}
		menuState.root, menuState.checkbox, menuState.radio, menuState.group, menuState.section =
			root, checkbox, radio, group, section
		menuState.isFeatured = isFeatured

		ns.MacroMenuConditionals(menuState)
		ns.MacroMenuCastSequence(menuState)
		closeGroup()

		-- what this kind of spell is for, one click away
		for _, option in ipairs(ns.MacroMenuFeaturedOptions(macro)) do
			local key, label = option[1], option[2]
			section()
			isFeatured[key] = true
			local element = root:CreateCheckbox(label, function()
				return ns.IsOptionOn(macro, key)
			end, function()
				change(function()
					ns.ToggleOption(macro, key)
				end)
			end)
			ns.MacroMenuFeaturedTip(element, macro, key, label)
		end
		closeGroup()

		ns.MacroMenuTarget(menuState)
		ns.MacroMenuGroupedSpells(menuState)
		ns.MacroMenuRank(menuState)
		-- When alone, First and Then together, Error Messages alone, each group a gap apart
		if above then
			gap()
		end
		ns.MacroMenuWhen(menuState)
		gap()
		local first = ns.MacroMenuFirst(menuState)
		if ns.MacroMenuThen(menuState) or first then
			gap()
		end
		ns.MacroMenuErrorMessages(menuState)

		gap()
		addMacroStorage()
		addMacroText()

		gap()
		root:CreateDivider()
		if ns.OffersDuplicate(macro) then
			local element = root:CreateButton(L["MENU_DUPLICATE"], function()
				ns.DuplicateMacro(macro)
				ns.RefreshSpellbookPage(page)
			end)
			SetTip(element, L["MENU_DUPLICATE"], L["MENU_DUPLICATE_DESCRIPTION"])
		end
		addDelete()
	end)
end
