local _, ns = ...
local L = ns.L
local Kit = ns.MenuKit

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip

--[[
	A page macro's right-click options menu, opened from its button on the page (Features/Enhanced-Spellbook/Macro-Button.lua).
	What the macro's kind is for comes first, as checkboxes: Cast At Cursor on Blizzard, the pet's ability on a
	summon, the stance a spell needs, Never Turn Off on a form, the wand and the pet on a nuke. Then Target,
	Grouped Spells, Rank, Conditionals and Cast Sequence (the last two buttons opening their panels), then the four groups,
	each a submenu button with what is on in it on the right, by its arrow: When alone, First and Then together, Error
	Messages alone; then Macro Storage (the list it is kept in) and the macro text, and under a line the actions. Every option explains itself in its tooltip. The options themselves live in
	Features/Enhanced-Spellbook/Macro-Options.lua, their kinds' defaults in Features/Enhanced-Spellbook/Macro-Kinds.lua. Its tooltips, submenu layout and option tables are shared with a category's
	menu, in Features/Enhanced-Spellbook/Menu-Utilities.lua. The sections from Conditionals to Error Messages are built in
	Features/Enhanced-Spellbook/Macro-Menu-Sections.lua, and the helpers both use live in Features/Enhanced-Spellbook/Macro-Menu-Utilities.lua.
]]

--[[
	Every spell macro has a menu. The menu stays open while options change: a switch or a choice redraws it in place, with its open sub-menus,
	and an action closes it. Each change rebuilds the page's macros, so the menu follows the rebuilt entry, and
	every label and the macro text redraw in place.
]]
function ns.ShowMacroMenu(button)
	local macro = button.macro
	if not ns.HasOptions(macro) then
		return
	end
	local page = button.page
	-- the menu its sections build (Features/Enhanced-Spellbook/Macro-Menu-Sections.lua), its macro kept current by change
	local menuState = { button = button, page = page, macro = macro }
	--[[
		runs a setter on the macro and rebuilds the page, which rewrites the macro, then points the menu at the rebuilt entry
	]]
	local function change(set)
		set()
		ns.RefreshSpellbookPage(page)
		macro = ns.MacroMenuRebuiltMacro(macro)
		menuState.macro = macro
	end
	menuState.change = change

	-- drawn on Menu-Kit's panels (Features/Enhanced-Spellbook/Macro-Menu-Panels.lua), described as the game's menus are
	ns.OpenMacroMenuPanels(button, function(_, root)
		-- the header: the macro's name, and the add-on's short name in gray, with a gap under it
		root:CreateHeader(macro.label or macro.name, L["ADDON_SHORT_NAME"])
		-- groups of rows sit apart by a gap, as the mini-map menu's do; the actions sit under a line as well
		local function gap()
			root:CreateSpacer()
		end

		-- a checkbox turning an option on or off, with its tooltip
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
		-- a choice of one: radio buttons that keep the menu open
		local function radio(menu, label, isOn, set, tip, note)
			local element = menu:CreateRadio(label, isOn, function()
				change(set)
				return MenuResponse.Refresh
			end)
			SetTip(element, label, tip, note)
			return element
		end
		--[[
			a setting's submenu whose label shows what is on in it, set again each time the menu redraws; onLabels
			lists the labels of what is on; the value light yellow, or in color (a palette key) when given
		]]
		local function group(labelKey, onLabels, color)
			local menu = root:CreateButton(L[labelKey])
			menu:SetSetting()
			menu:SetValue(function()
				local value = ns.MacroMenuGroupValue(onLabels())
				return value and color and Kit.Color(color, value) or value
			end)
			return menu
		end
		-- the macro text, its length (light yellow, red over what a macro holds) as the value, the lines in the submenu
		local function addMacroText()
			local menu = root:CreateButton(L["MACRO_TEXT"])
			menu:SetValue(function()
				local length = #macro.body
				return Kit.Color(
					length > ns.MACRO_BODY_MAX_LENGTH and "OFF" or "VALUE",
					L["MENU_MACRO_LENGTH"]:format(length, ns.MACRO_BODY_MAX_LENGTH)
				)
			end)
			-- the lines as one block
			menu:CreateText(function()
				return table.concat(ns.MacroMenuBodyLines(macro), "\n")
			end)
		end

		--[[
			Macro Storage: which macro list the WoW macro is kept in, the character's own or General, as radio
			buttons; choosing one moves the WoW macro there now (ns.SetMacroTab)
		]]
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

		--[[
			Delete, with how many action bar slots hold the macro light yellow on its right, always asked first, the ask
			saying whether it comes off the bars. It deletes the WoW macro and resets every option, so the macro
			starts over (a Duplicate copy leaves the page).
		]]
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

		--[[
			the groups up to When, each a gap below what is above it: Conditionals and Cast Sequence under the
			header, then the checkboxes, then Target, Grouped Spells and Rank; within a group each section after
			the first follows straight on
		]]
		local above, opened = false, false
		local function section()
			if above and not opened then
				gap()
			end
			above, opened = true, true
		end
		-- the next section opens a group of its own
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

		--[[
			the actions: Duplicate adds a macro to the page, and Delete takes this one's WoW macro off the bars (and a
			Duplicate copy off the page)
		]]
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
