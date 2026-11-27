local _, ns = ...
local L = ns.L

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local AutoShotLabel = ns.MenuAutoShotLabel

-- the classes whose enemy spells offer Start Pet Attack at the top, since their pet is always out
local PET_CLASSES = { HUNTER = true, WARLOCK = true }

-- "In Combat", "2 Options", or nil, so a group left alone says nothing.
local function GroupValue(on)
	if #on == 0 then
		return nil
	end
	return #on == 1 and on[1] or L["MENU_OPTIONS_COUNT"]:format(#on)
end

-- Pipes escaped so the text shows as written; the tag line is left out, though the length counts it.
local function BodyLines(macro)
	local lines = {}
	for line in (ns.UntaggedBody(macro.body) .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = line:gsub("|", "||")
	end
	return lines
end

-- { key, label } pairs shown at the top as checkboxes.
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

-- Found by settings key after a rebuild replaced every entry; the old entry where the rebuild dropped it.
local function RebuiltMacro(old)
	local key = ns.SettingsKey(old)
	for _, macro in ipairs(ns.macros) do
		if ns.SettingsKey(macro) == key then
			return macro
		end
	end
	return old
end

ns.MacroMenuGroupValue, ns.MacroMenuBodyLines = GroupValue, BodyLines
ns.MacroMenuFeaturedOptions, ns.MacroMenuFeaturedTip = FeaturedOptions, FeaturedTip
ns.MacroMenuRebuiltMacro = RebuiltMacro
