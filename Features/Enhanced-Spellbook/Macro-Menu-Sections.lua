local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local SetTip = ns.MenuSetTip
local LabelAndValue = ns.MenuLabelAndValue
local DESCRIPTIONS, NOTES = ns.MENU_DESCRIPTIONS, ns.MENU_NOTES
local COMBAT, REPEAT, FIRST, ERRORS = ns.MENU_COMBAT, ns.MENU_REPEAT, ns.MENU_FIRST, ns.MENU_ERRORS

--[[
	The sections of a page macro's right-click menu (Features/Enhanced-Spellbook/Macro-Menu.lua) from Target to Error Messages,
	each added to the menu in turn by ns.ShowMacroMenu. Each takes menuState, the menu being built: its root, the macro
	(which change points at the rebuilt entry), its button and page, and the checkbox, radio, group, section and
	change helpers ns.ShowMacroMenu makes.
]]

--[[
	Target: who the macro tries, in turn, as up to three priorities, each a submenu of the units it can
	pick. A lower priority leaves out the units a higher one took, and Third waits for Second. The menu
	can't drop an entry once drawn, so a pick reopens it, drawn afresh.
]]
function ns.MacroMenuTarget(menuState)
	local section, group, change, button = menuState.section, menuState.group, menuState.change, menuState.button
	if ns.OffersTargetPriority(menuState.macro) then
		section()
		local function unitLabel(unit)
			for _, row in ipairs(ns.TARGET_UNITS) do
				if row[1] == unit then
					return L[row[2]]
				end
			end
		end
		local targetMenu = group("MENU_GROUP_TARGET", function()
			local on = {}
			if ns.HasTargetPriority(menuState.macro) then
				local labels = {}
				for i, unit in ipairs(ns.TargetPriority(menuState.macro)) do
					labels[i] = unitLabel(unit)
				end
				on[1] = table.concat(labels, L["LIST_SEPARATOR"])
			end
			return on
		end)
		local list = ns.TargetPriority(menuState.macro)
		local function pick(place, unit)
			return function()
				change(function()
					ns.SetTargetPriorityUnit(menuState.macro, place, unit)
				end)
				C_Timer.After(0, function()
					ns.ShowMacroMenu(button)
				end)
				return MenuResponse.CloseAll
			end
		end
		-- an empty priority after the last to fill, but none after Self, since nothing after the player is ever tried
		local places = #list + (list[#list] == "player" and 0 or 1)
		for place = 1, math.min(places, ns.TARGET_PRIORITY_SLOTS) do
			local placeKey = "MENU_PRIORITY_" .. place
			local slotMenu = targetMenu:CreateButton(L[placeKey])
			slotMenu:AddInitializer(function(frame)
				local unit = ns.TargetPriority(menuState.macro)[place]
				return LabelAndValue(
					frame,
					L[placeKey],
					GetColor("INFO") .. (unitLabel(unit) or L["MENU_UNIT_NONE"]) .. "|r"
				)
			end)
			SetTip(slotMenu, L[placeKey], L["MENU_PRIORITY_DESCRIPTION"])
			local taken = {}
			for i = 1, place - 1 do
				taken[list[i]] = true
			end
			if place > 1 then
				local element = slotMenu:CreateRadio(L["MENU_UNIT_NONE"], function()
					return ns.TargetPriority(menuState.macro)[place] == nil
				end, pick(place, nil))
				SetTip(element, L["MENU_UNIT_NONE"], L["MENU_UNIT_NONE_DESCRIPTION"])
			end
			for _, row in ipairs(ns.TARGET_UNITS) do
				local unit = row[1]
				if not taken[unit] and ns.KindOffersUnit(menuState.macro.kind, unit) then
					local element = slotMenu:CreateRadio(L[row[2]], function()
						return ns.TargetPriority(menuState.macro)[place] == unit
					end, pick(place, unit))
					SetTip(element, L[row[2]], L[row[2] .. "_DESCRIPTION"])
				end
			end
		end
	end
end

--[[
	The ranks a group's spells or a spell's ranks are, for the Grouped Spells and Rank submenus: the class's
	What's Next? row for id (or the spell named name) when there is one, so each reads as the tooltip's ranks
	do (ns.RankState, ns.RankLabel, ns.RankNote); else known, or one the trainer teaches at level.
]]
local function MenuRank(known, id, name, level)
	if known then
		return { status = "KNOWN", level = level }
	end
	local row = ns.ClassRankRow and ns.ClassRankRow(id, name)
	if row then
		return row
	end
	local reached = level and level <= UnitLevel("player")
	return { status = reached and "AVAILABLE" or "LATER", source = "TRAINER", level = level }
end

-- Puts a rank's note at the right of its checkbox or radio (ns.MenuChoiceNote), where it has one.
local function AddRankNote(element, rank)
	local note = rank.status ~= "KNOWN" and ns.RankNote(rank)
	if note then
		element:AddInitializer(function(frame)
			return ns.MenuChoiceNote(frame, note)
		end)
	end
end

--[[
	Grouped Spells: Right-Click for the group (or single) version, and the spells of its SPELL_GROUPS
	group, each a checkbox in its rank color with its note, as a spell's ranks are (MenuRank), so they can be
	ticked ahead of learning them
]]
function ns.MacroMenuGroupedSpells(menuState)
	local section, group, change = menuState.section, menuState.group, menuState.change
	local rightClick = ns.RightClickSpell(menuState.macro)
	local offersRightClick = ns.OffersOption(menuState.macro, "groupVersion")
	if offersRightClick or ns.OffersGroupedSpells(menuState.macro) then
		section()
		local groupedMenu = group("MENU_GROUP_GROUPED", function()
			local on = ns.IsOptionOn(menuState.macro, "groupVersion") or ns.IsGrouped(menuState.macro)
			return on and { L["MENU_ENABLED"] } or {}
		end)
		if offersRightClick then
			local label = L["MENU_RIGHT_CLICK_FOR"]:format(rightClick)
			local element = groupedMenu:CreateCheckbox(label, function()
				return ns.IsOptionOn(menuState.macro, "groupVersion")
			end, function()
				change(function()
					ns.ToggleOption(menuState.macro, "groupVersion")
				end)
			end)
			-- off while a Conditionals row checks Right-Click, which has the right-click already (see ns.ConditionBlockReason)
			local taken = not ns.IsOptionOn(menuState.macro, "groupVersion")
				and ns.ConditionalsUseRightClick(menuState.macro)
			SetTip(
				element,
				label,
				L["MENU_GROUP_VERSION_DESCRIPTION"]:format(rightClick, menuState.macro.name),
				taken and L["MENU_RIGHT_CLICK_TAKEN"] or nil
			)
			if taken then
				element:SetEnabled(false)
			end
		end
		if ns.OffersGroupedSpells(menuState.macro) then
			if offersRightClick then
				groupedMenu:CreateDivider()
			end
			for _, member in ipairs(menuState.macro.groupMembers) do
				local name = member.name
				local rank = MenuRank(member.learned, nil, name)
				local element = groupedMenu:CreateCheckbox(ns.RankLabel(rank, name), function()
					return ns.IsGroupedSpellOn(menuState.macro, name)
				end, function()
					change(function()
						ns.ToggleGroupedSpell(menuState.macro, name)
					end)
				end)
				SetTip(
					element,
					name,
					L["MENU_GROUPED_SPELL_DESCRIPTION"]:format(name),
					not member.learned and L["MENU_GROUPED_SPELL_NOT_LEARNED"] or nil
				)
				AddRankNote(element, rank)
			end
		end
	end
end

--[[
	Rank: Highest, naming the rank it casts now, Dynamic (a friendly spell's Dynamic Rank), or a known rank; the
	rest unclickable, each in its rank color with its note (MenuRank): red with where to learn it for one the
	character could have now, gray with its level for one still to come
]]
function ns.MacroMenuRank(menuState)
	local section, group, radio = menuState.section, menuState.group, menuState.radio
	if ns.OffersFixedRank(menuState.macro) or ns.OffersTargetRank(menuState.macro) then
		section()
		local rankMenu = group("MENU_GROUP_RANK", function()
			local rank = ns.AbilityRank(menuState.macro)
			return { rank == "targetRank" and L["MENU_RANK_DYNAMIC"] or rank or L["MENU_HIGHEST"] }
		end)
		local function isRank(choice)
			return function()
				return ns.AbilityRank(menuState.macro) == choice
			end
		end
		local function setRank(choice)
			return function()
				ns.SetAbilityRank(menuState.macro, choice)
			end
		end
		local highest = radio(rankMenu, L["MENU_HIGHEST"], isRank(nil), setRank(nil), L["MENU_HIGHEST_DESCRIPTION"])
		-- the rank Highest casts today, so a rank still to learn reads as not in use yet (ranks lists highest first)
		local casts = menuState.macro.ranks and menuState.macro.ranks[1]
		if casts then
			highest:AddInitializer(function(frame)
				return ns.MenuChoiceNote(frame, GetColor("HELP") .. casts.text .. "|r")
			end)
		end
		if ns.OffersTargetRank(menuState.macro) then
			radio(
				rankMenu,
				L["MENU_RANK_DYNAMIC"],
				isRank("targetRank"),
				setRank("targetRank"),
				L[DESCRIPTIONS.targetRank],
				L[NOTES.targetRank]
			)
		end
		if menuState.macro.ranks then
			rankMenu:CreateDivider()
		end
		local all = {}
		for _, list in ipairs({ menuState.macro.ranks or {}, menuState.macro.unknownRanks or {} }) do
			for _, rank in ipairs(list) do
				all[#all + 1] = rank
			end
		end
		table.sort(all, function(a, b) -- up from Rank 1
			return a.level < b.level
		end)
		for _, rank in ipairs(all) do
			if rank.unknown then
				local state = MenuRank(false, rank.id, nil, rank.level)
				local element = rankMenu:CreateRadio(ns.RankLabel(state, rank.text), isRank(rank.text), function() end)
				element:SetEnabled(false)
				AddRankNote(element, state)
			else
				radio(
					rankMenu,
					rank.text,
					isRank(rank.text),
					setRank(rank.text),
					L["MENU_FIXED_RANK_DESCRIPTION"]:format(rank.text)
				)
			end
		end
	end
end

--[[
	Conditionals: opens the panel docked beside the window (Features/Enhanced-Spellbook/Macro-Builder/Conditionals-Panel.lua), where
	the rows are set; the value names the one set ("Shift: Frost Nova") or counts them
]]
function ns.MacroMenuConditionals(menuState)
	local section, root, page = menuState.section, menuState.root, menuState.page
	if ns.OffersConditionals(menuState.macro) then
		section()
		local element = root:CreateButton(L["MENU_GROUP_CONDITIONALS"], function()
			ns.ShowConditionalsPanel(menuState.macro, page)
		end)
		element:AddInitializer(function(frame)
			local value = ns.MacroMenuGroupValue(ns.ConditionalSummaries(menuState.macro))
			return LabelAndValue(frame, L["MENU_GROUP_CONDITIONALS"], value and GetColor("INFO") .. value .. "|r")
		end)
		SetTip(element, L["MENU_GROUP_CONDITIONALS"], L["MENU_CONDITIONALS_DESCRIPTION"])
	end
end

--[[
	Cast Sequence: opens its panel, docked where the Conditionals panel docks
	(Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence-Panel.lua); the value counts the steps, the macro's own included
]]
function ns.MacroMenuCastSequence(menuState)
	local section, root, page = menuState.section, menuState.root, menuState.page
	if ns.OffersCastSequence(menuState.macro) then
		section()
		local element = root:CreateButton(L["MENU_GROUP_CAST_SEQUENCE"], function()
			ns.ShowCastSequencePanel(menuState.macro, page)
		end)
		element:AddInitializer(function(frame)
			local count = ns.IsCastSequenceOn(menuState.macro) and ns.CastSequenceStepCount(menuState.macro) + 1
			-- the spell then NULL alone reads "Rend, Stop" rather than a count of one
			local text = count
				and (
					count > 1 and L["MENU_CAST_SEQUENCE_STEPS"]:format(count) or ns.CastSequenceSummary(menuState.macro)
				)
			local value = text and GetColor("INFO") .. text .. "|r"
			return LabelAndValue(frame, L["MENU_GROUP_CAST_SEQUENCE"], value)
		end)
		SetTip(element, L["MENU_GROUP_CAST_SEQUENCE"], L["MENU_CAST_SEQUENCE_DESCRIPTION"])
	end
end

-- When: the combat check, how often it casts, and when it does nothing
function ns.MacroMenuWhen(menuState)
	local group, radio, checkbox = menuState.group, menuState.radio, menuState.checkbox
	local whenMenu = group("MENU_GROUP_WHEN", function()
		local on = {}
		for _, choice in ipairs(COMBAT) do
			if choice[1] and ns.CombatCheck(menuState.macro) == choice[1] then
				on[#on + 1] = L[choice[2]]
			end
		end
		for _, choice in ipairs(REPEAT) do
			if
				choice[1]
				and ns.OffersOption(menuState.macro, "oncePerTarget")
				and ns.RepeatRule(menuState.macro) == choice[1]
			then
				on[#on + 1] = L[choice[2]]
			end
		end
		for _, key in ipairs({ "stopIfChanneling", "stopIfStealthed" }) do
			if ns.IsOptionOn(menuState.macro, key) then
				on[#on + 1] = L[key == "stopIfChanneling" and "MENU_STOP_IF_CHANNELING" or "MENU_STOP_IF_STEALTHED"]
			end
		end
		return on
	end)
	for _, choice in ipairs(COMBAT) do
		local check = choice[1]
		radio(whenMenu, L[choice[2]], function()
			return ns.CombatCheck(menuState.macro) == check
		end, function()
			ns.SetCombatCheck(menuState.macro, check)
		end, L[choice[3]])
	end
	if ns.OffersOption(menuState.macro, "oncePerTarget") then
		whenMenu:CreateDivider()
		for _, choice in ipairs(REPEAT) do
			local rule = choice[1]
			radio(whenMenu, L[choice[2]], function()
				return ns.RepeatRule(menuState.macro) == rule
			end, function()
				ns.SetRepeatRule(menuState.macro, rule)
			end, L[choice[3]])
		end
	end
	whenMenu:CreateDivider()
	checkbox(whenMenu, "stopIfChanneling", L["MENU_STOP_IF_CHANNELING"])
	checkbox(whenMenu, "stopIfStealthed", L["MENU_STOP_IF_STEALTHED"])
end

--[[
	First: what runs before the cast, the items last, each labeled with its place in the order. The
	slots are the equipped on-use items, plus any slot already ticked so it can be unticked after a gear
	swap.
]]
function ns.MacroMenuFirst(menuState)
	local group, checkbox, change = menuState.group, menuState.checkbox, menuState.change
	local slots = {}
	if ns.OffersUseItems(menuState.macro) then
		local listed = {}
		for _, usable in ipairs(ns.UsableSlots()) do
			slots[#slots + 1], listed[usable.slot] = usable.slot, true
		end
		for _, slot in ipairs(ns.UseItemSlots(menuState.macro)) do
			if not listed[slot] then
				slots[#slots + 1] = slot
			end
		end
	end
	local firstOffered = #slots > 0
	for _, option in ipairs(FIRST) do
		firstOffered = firstOffered or ns.OffersOption(menuState.macro, option[1])
	end
	if firstOffered then
		local firstMenu = group("MENU_GROUP_FIRST", function()
			local on = {}
			for _, option in ipairs(FIRST) do
				if ns.IsOptionOn(menuState.macro, option[1]) then
					on[#on + 1] = L[option[2]]
				end
			end
			for _, slot in ipairs(ns.UseItemSlots(menuState.macro)) do
				on[#on + 1] = ns.SlotName(slot)
			end
			return on
		end)
		local offered = false
		for _, option in ipairs(FIRST) do
			if ns.OffersOption(menuState.macro, option[1]) then
				checkbox(firstMenu, option[1], L[option[2]])
				offered = true
			end
		end
		if offered and #slots > 0 then
			firstMenu:CreateDivider()
		end
		for _, slot in ipairs(slots) do
			local element = firstMenu:CreateCheckbox(ns.SlotLabel(slot), function()
				return ns.IsUsingSlot(menuState.macro, slot) ~= nil
			end, function()
				change(function()
					ns.ToggleUseSlot(menuState.macro, slot)
				end)
			end)
			-- the icon, and the slot's place in the order, set each time the menu redraws
			element:AddInitializer(function(frame)
				local at = ns.IsUsingSlot(menuState.macro, slot)
				local icon = GetInventoryItemTexture("player", slot)
				frame.fontString:SetTextToFit(
					(icon and "|T" .. icon .. ":16|t " or "")
						.. (at and L["NAME_WITH_DETAIL_FORMAT"]:format(ns.SlotLabel(slot), at) or ns.SlotLabel(slot))
				)
			end)
			SetTip(element, ns.SlotLabel(slot), L["MENU_USE_ITEM_DESCRIPTION"])
		end
	end
end

-- Then: what runs after the cast, less what sits at the top already
function ns.MacroMenuThen(menuState)
	local group, checkbox, isFeatured = menuState.group, menuState.checkbox, menuState.isFeatured
	local THEN = ns.MenuThenOptions()
	local thenOptions = {}
	for _, option in ipairs(THEN) do
		if option[2] and not isFeatured[option[1]] and ns.OffersOption(menuState.macro, option[1]) then
			thenOptions[#thenOptions + 1] = option
		end
	end
	if #thenOptions > 0 then
		local thenMenu = group("MENU_GROUP_THEN", function()
			local on = {}
			for _, option in ipairs(thenOptions) do
				if ns.IsOptionOn(menuState.macro, option[1]) then
					on[#on + 1] = option[2]
				end
			end
			return on
		end)
		for _, option in ipairs(thenOptions) do
			checkbox(thenMenu, option[1], option[2])
		end
	end
end

function ns.MacroMenuErrorMessages(menuState)
	local group, checkbox = menuState.group, menuState.checkbox
	local errorsMenu = group("MENU_GROUP_ERRORS", function()
		local on = {}
		for _, option in ipairs(ERRORS) do
			if ns.IsOptionOn(menuState.macro, option[1]) then
				on[#on + 1] = L[option[2]]
			end
		end
		return on
	end)
	for _, option in ipairs(ERRORS) do
		checkbox(errorsMenu, option[1], L[option[2]])
	end
end
