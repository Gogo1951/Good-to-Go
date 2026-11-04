local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local LabelAndValue = ns.MenuLabelAndValue

--[[
	A page macro's right-click options menu, opened from its button on the page (Features/Spellbook/Macro-Button.lua).
	What the macro's kind is for comes first, as checkboxes: Cast At Cursor on Blizzard, the pet's ability on a
	summon, the stance a spell needs, Never Turn Off on a form, the wand and the pet on a nuke. Then Target,
	Grouped Spells, Rank, Conditionals and Cast Sequence (buttons opening their panels) and the four groups (When, First, Then, Error Messages), each a submenu button with what is on in it on the right, by
	its arrow; then the actions, and the macro text in a submenu of its own. Every option explains itself in its tooltip. The options themselves live in
	Features/Spellbook/Macro-Options.lua. Its tooltips, submenu layout and option tables are shared with a category's
	menu, in Features/Spellbook/Menu-Utilities.lua. The sections from Target to Error Messages are built in
	Features/Spellbook/Macro-Menu-Sections.lua, and the helpers both use live in Features/Spellbook/Macro-Menu-Helpers.lua.
]]

--[[
	Every spell macro has a menu. A focus copy's menu only removes it. The
	menu stays open while options change: the game's checkboxes refresh it by default, and the radio choices
	ask it to. Each change rebuilds the page's macros, so the menu follows the rebuilt entry, and every label
	and the macro text redraw in place.
]]
function ns.ShowMacroMenu(button)
	local macro = button.macro
	if not ns.HasOptions(macro) then
		return
	end
	local page = button.page
	-- the menu its sections build (Features/Spellbook/Macro-Menu-Sections.lua), its macro kept current by change
	local ctx = { button = button, page = page, macro = macro }
	--[[
		runs a setter on the macro and rebuilds the page, which rewrites the macro and its focus copy, then
		points the menu at the rebuilt entry
	]]
	local function change(set)
		set()
		ns.RefreshSpellbookPage(page)
		macro = ns.MacroMenuRebuiltMacro(macro)
		ctx.macro = macro
	end
	ctx.change = change

	MenuUtil.CreateContextMenu(button, function(_, root)
		root:CreateTitle(
			"|T"
				.. (macro.icon or ns.QUESTION_MARK_ICON)
				.. ":16|t "
				.. GetColor("TITLE")
				.. (macro.label or macro.name)
				.. "|r"
		)
		root:CreateDivider()

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
			a submenu whose label shows what is on in it, set again each time the menu redraws; onLabels lists
			the labels of what is on
		]]
		local function group(labelKey, onLabels)
			local menu = root:CreateButton(L[labelKey])
			menu:AddInitializer(function(frame)
				local value = ns.MacroMenuGroupValue(onLabels())
				return LabelAndValue(frame, L[labelKey], value and GetColor("INFO") .. value .. "|r")
			end)
			return menu
		end
		-- the macro text, its length (red over what a macro holds) as the value, the lines in the submenu
		local function addMacroText()
			local menu = root:CreateButton(L["MACRO_TEXT"])
			menu:AddInitializer(function(frame)
				local length = #macro.body
				return LabelAndValue(
					frame,
					L["MACRO_TEXT"],
					GetColor(length > ns.MACRO_BODY_MAX_LENGTH and "OFF" or "HELP")
						.. L["MENU_MACRO_LENGTH"]:format(length, ns.MACRO_BODY_MAX_LENGTH)
						.. "|r"
				)
			end)
			-- the lines as one block, sized to the widest line and the line count
			menu:CreateTitle(""):AddInitializer(function(frame)
				local fontString, lines, width = frame.fontString, ns.MacroMenuBodyLines(macro), 1
				for _, line in ipairs(lines) do
					fontString:SetText(line)
					width = math.max(width, fontString:GetUnboundedStringWidth())
				end
				return ns.MacroMenuTextBlock(fontString, GetColor("TEXT") .. table.concat(lines, "\n") .. "|r", width)
			end)
		end

		--[[
			Delete, with how many action bar slots hold the macro; one in use asks first. It deletes the WoW
			macro and resets every option, so the macro starts over (a Duplicate copy leaves the page).
		]]
		local function addDelete()
			local index = ns.FindMacroIndex(macro)
			local used = index ~= 0 and ns.MacroBarCount(index) or 0
			local label = used == 0 and L["MENU_DELETE"]
				or used == 1 and L["MENU_DELETE_USED_ONE"]
				or L["MENU_DELETE_USED"]:format(used)
			local element = root:CreateButton(label, function()
				local function delete()
					ns.DeletePageMacro(macro)
					ns.RefreshSpellbookPage(page)
				end
				if used > 0 then
					ns.ConfirmDelete(macro.label or macro.name, delete)
				else
					delete()
				end
			end)
			SetTip(
				element,
				L["MENU_DELETE"],
				L[macro.copy and "MENU_DELETE_COPY_DESCRIPTION" or "MENU_DELETE_DESCRIPTION"]
			)
		end

		if macro.focus then
			root:CreateButton(L["MENU_REMOVE_FOCUS"], function()
				change(function()
					ns.SetOption(macro, "focus", false)
				end)
			end)
			root:CreateDivider()
			addMacroText()
			return
		end

		-- what this kind of spell is for, one click away
		local featured = ns.MacroMenuFeaturedOptions(macro)
		local isFeatured = {}
		for _, option in ipairs(featured) do
			local key, label = option[1], option[2]
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

		-- each section below the checkboxes starts with a divider, once something is above it
		local above = #featured > 0
		local function section()
			if above then
				root:CreateDivider()
			end
			above = true
		end
		ctx.root, ctx.checkbox, ctx.radio, ctx.group, ctx.section = root, checkbox, radio, group, section
		ctx.isFeatured = isFeatured

		ns.MacroMenuTarget(ctx)
		ns.MacroMenuGroupedSpells(ctx)
		ns.MacroMenuRank(ctx)
		ns.MacroMenuConditionals(ctx)
		ns.MacroMenuCastSequence(ctx)
		if above then
			root:CreateDivider()
		end
		ns.MacroMenuWhen(ctx)
		ns.MacroMenuFirst(ctx)
		ns.MacroMenuThen(ctx)
		ns.MacroMenuErrorMessages(ctx)

		root:CreateDivider()
		addMacroText()

		--[[
			the actions: Make Default changes a kind's defaults, Duplicate and the focus copy add a macro to the
			page, and Delete takes this one's WoW macro off the bars (and a Duplicate copy off the page)
		]]
		root:CreateDivider()
		local kindRow = macro.kind and ns.KindRow(macro.kind)
		if kindRow then
			local label = L["MENU_MAKE_DEFAULT"]:format(L[kindRow.labelKey])
			local element = root:CreateButton(label, function()
				ns.MacroMenuMakeDefault(macro)
			end)
			SetTip(element, label, L["MENU_MAKE_DEFAULT_DESCRIPTION"]:format(L[kindRow.labelKey]))
		end
		if ns.OffersDuplicate(macro) then
			local element = root:CreateButton(L["MENU_DUPLICATE"], function()
				ns.DuplicateMacro(macro)
				ns.RefreshSpellbookPage(page)
			end)
			SetTip(element, L["MENU_DUPLICATE"], L["MENU_DUPLICATE_DESCRIPTION"])
		end
		if ns.OffersOption(macro, "focus") then
			local on = ns.IsOptionOn(macro, "focus")
			local element = root:CreateButton(L[on and "MENU_REMOVE_FOCUS" or "MENU_ADD_FOCUS"], function()
				change(function()
					ns.ToggleOption(macro, "focus")
				end)
			end)
			SetTip(element, L[on and "MENU_REMOVE_FOCUS" or "MENU_ADD_FOCUS"], L["MENU_FOCUS_DESCRIPTION"])
		end
		addDelete()
	end)
end
