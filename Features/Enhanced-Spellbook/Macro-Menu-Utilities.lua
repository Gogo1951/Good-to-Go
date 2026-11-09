local _, ns = ...
local L = ns.L

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local AutoShotLabel = ns.MenuAutoShotLabel

--[[
	The helpers of a page macro's right-click menu (Features/Enhanced-Spellbook/Macro-Menu.lua and its sections in
	Features/Enhanced-Spellbook/Macro-Menu-Sections.lua).
]]

-- the classes whose enemy spells offer Start Pet Attack at the top, since their pet is always out
local PET_CLASSES = { HUNTER = true, WARLOCK = true }

--[[
	Lays text out in a menu title's font string as a left-aligned block width wide, wrapping as it needs, and
	returns the block's size for the menu to take. The menu gives a title's text a fixed 20 high, which
	would cut it to one line, so the height is freed before the text is measured.
]]
local function TextBlock(fontString, text, width)
	width = math.ceil(width)
	fontString:SetJustifyH("LEFT")
	fontString:SetWordWrap(true)
	if fontString.SetMaxLines then
		fontString:SetMaxLines(0)
	end
	fontString:SetWidth(width)
	fontString:SetHeight(0)
	fontString:SetText(text)
	local height = math.ceil(fontString:GetStringHeight())
	fontString:SetHeight(height)
	return width, height
end

--[[
	What is on in a group, its value: "In Combat" for one, "2 Options" for more, nil for none, so a group left
	alone says nothing.
]]
local function GroupValue(on)
	if #on == 0 then
		return nil
	end
	return #on == 1 and on[1] or L["MENU_OPTIONS_COUNT"]:format(#on)
end

--[[
	The macro text's lines, for the Macro Text submenu, with pipes escaped so the text shows as written. The
	tag line is left out, though the length counts it.
]]
local function BodyLines(macro)
	local lines = {}
	for line in (ns.UntaggedBody(macro.body) .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = line:gsub("|", "||")
	end
	return lines
end

--[[
	The options a macro's kind is for, shown at the top as checkboxes, as { key, label }: Cast At Cursor
	(who it casts on is the Target submenu's), the spell's own extras (pet ability, stance, Never Turn Off) and, on an enemy spell,
	the wand or Auto Shot and, for a class with a pet, Start Pet Attack.
]]
local function FeaturedOptions(macro)
	local featured = {}
	local function add(key, label)
		if ns.OffersOption(macro, key) then
			featured[#featured + 1] = { key, label }
		end
	end
	add("cursor", L["MENU_CAST_AT_CURSOR"])
	if macro.petAbility then
		add("pet", L["MENU_CAST_IF_SUMMONED"]:format(macro.petAbility))
	end
	if macro.stances then
		add("stance", L["MENU_SWITCH_TO"]:format(macro.stances[1]))
	end
	add("noToggle", L["MENU_NEVER_TURN_OFF"])
	if macro.kind == "enemy" then
		if ns.AutoShotLabelKey() then
			add("autoShot", AutoShotLabel())
		end
		if PET_CLASSES[select(2, UnitClass("player"))] then
			add("petAttack", L["MENU_START_PET_ATTACK"])
		end
	end
	return featured
end

-- The tooltip of a featured option that has no explanation of its own in DESCRIPTIONS.
local function FeaturedTip(element, macro, key, label)
	if key == "pet" then
		SetTip(element, label, L["MENU_PET_DESCRIPTION"]:format(macro.petFamily, macro.petAbility))
	elseif key == "stance" then
		SetTip(element, label, L["MENU_STANCE_DESCRIPTION"]:format(macro.stances[1]))
	else
		OptionTip(element, key, label)
	end
end

--[[
	Makes this macro's options its kind's defaults, its target priority among them; read every value first,
	since a default moves what follows it. A macro of the kind with a Conditional on Right-Click keeps
	Right-Click For off, by a setting of its own, when the default turns it on.
]]
local function MakeDefault(macro)
	if ns.OffersTargetPriority(macro) then
		ns.MakeTargetPriorityDefault(macro)
	end
	local values = {}
	for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
		if ns.OffersOption(macro, key) then
			values[key] = ns.IsOptionOn(macro, key)
		end
	end
	local keepOff = {}
	if values.groupVersion then
		for _, other in ipairs(ns.macros) do
			local off = not ns.IsOptionOn(other, "groupVersion")
			if other.kind == macro.kind and off and ns.ConditionalsUseRightClick(other) then
				keepOff[#keepOff + 1] = other
			end
		end
	end
	for key, on in pairs(values) do
		ns.SetKindDefault(macro.kind, key, on)
		ns.ClearOwnSetting(macro, key)
	end
	for _, other in ipairs(keepOff) do
		ns.SetOption(other, "groupVersion", false)
	end
	ns:RefreshMacros()
	ns:PrintMessage(L["MENU_DEFAULT_SET"]:format(L[ns.KindRow(macro.kind).labelKey]))
end

--[[
	The page's macro for the one a menu was opened on, after a rebuild has replaced every entry in ns.macros:
	the same settings key, and a focus copy for a focus copy. The old entry where the rebuild dropped it.
]]
local function RebuiltMacro(old)
	local key = ns.SettingsKey(old)
	for _, macro in ipairs(ns.macros) do
		if ns.SettingsKey(macro) == key and (macro.focus and true or false) == (old.focus and true or false) then
			return macro
		end
	end
	return old
end

ns.MacroMenuTextBlock, ns.MacroMenuGroupValue, ns.MacroMenuBodyLines = TextBlock, GroupValue, BodyLines
ns.MacroMenuFeaturedOptions, ns.MacroMenuFeaturedTip = FeaturedOptions, FeaturedTip
ns.MacroMenuMakeDefault, ns.MacroMenuRebuiltMacro = MakeDefault, RebuiltMacro
