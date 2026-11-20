local _, ns = ...
local TITLE, BODY, HELP = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY, ns.COLORS_RGB.HELP
local L = ns.L

--[[
	What a macro's menu (Features/Enhanced-Spellbook/Macro-Menu.lua, with Macro-Menu-Sections.lua and
	Macro-Menu-Utilities.lua) and a category's menu (Features/Enhanced-Spellbook/Category-Menu.lua) share: the
	options' explanations and tooltips, and the option tables of the When, First and Error Messages groups.
]]

-- Each option's explanation, and a note for the two that need one.
local DESCRIPTIONS = {
	cursor = "OPTIONS_DEFAULT_CURSOR_DESCRIPTION",
	targetRank = "OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION",
	stopCast = "OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION",
	stopAttack = "OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION",
	stopIfChanneling = "OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION",
	stopIfStealthed = "OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION",
	cancelForm = "OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION",
	targetEnemy = "OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION",
	targetFriend = "OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION",
	petAttack = "OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION",
	startAttack = "OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION",
	autoShot = "OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION",
	oncePerTarget = "OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION",
	oncePerCombat = "OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION",
	noToggle = "OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION",
	hideErrors = "OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION",
	muteErrors = "OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION",
}
local NOTES = { targetRank = "MENU_DYNAMIC_RANK_NOTE", stopCast = "MENU_STOP_CASTING_NOTE" }
ns.MENU_DESCRIPTIONS, ns.MENU_NOTES = DESCRIPTIONS, NOTES

--[[
	Gives a menu element a tooltip: its label as a gold title, a white explanation and, where there is one, a
	silver note. Builds whose menus can't take a tooltip show the element bare.
]]
local function SetTip(element, title, body, note)
	if not element.SetTooltip or not body then
		return
	end
	element:SetTooltip(function(tooltip)
		tooltip:SetText(title, TITLE.r, TITLE.g, TITLE.b, 1, true)
		tooltip:AddLine(body, BODY.r, BODY.g, BODY.b, true)
		if note then
			tooltip:AddLine(note, HELP.r, HELP.g, HELP.b, true)
		end
	end)
end

local function OptionTip(element, key, title)
	SetTip(element, title, L[DESCRIPTIONS[key]], NOTES[key] and L[NOTES[key]])
end

ns.MenuSetTip, ns.MenuOptionTip = SetTip, OptionTip

-- The ranged attack's label for the player's class: Start Wand, or Start Auto Shot.
local function AutoShotLabel()
	return L[ns.AutoShotLabelKey() or "MENU_START_AUTO_SHOT"]
end

ns.MenuAutoShotLabel = AutoShotLabel

--[[
	The Then group's options, what runs after the cast, as { option key, label }: a label is nil for an option the
	player's class can't use. Read when a menu opens, since the ranged attack's label waits on the class lists.
]]
function ns.MenuThenOptions()
	return {
		{ "startAttack", L["MENU_START_AUTO_ATTACK"] },
		{ "autoShot", ns.AutoShotLabelKey() and AutoShotLabel() },
		{ "petAttack", L["MENU_START_PET_ATTACK"] },
	}
end

-- The When group's two choices of one, as { option key or nil for the default, label key, explanation key }.
local COMBAT = {
	{ nil, "MENU_ANY_TIME", "MENU_ANY_TIME_DESCRIPTION" },
	{ "combatOnly", "MENU_IN_COMBAT", "MENU_IN_COMBAT_DESCRIPTION" },
	{ "noCombat", "SUBTEXT_NO_COMBAT", "MENU_OUT_OF_COMBAT_DESCRIPTION" },
}
local REPEAT = {
	{ nil, "MENU_EVERY_PRESS", "MENU_EVERY_PRESS_DESCRIPTION" },
	{ "oncePerTarget", "MENU_ONCE_PER_TARGET", DESCRIPTIONS.oncePerTarget },
	{ "oncePerCombat", "MENU_ONCE_PER_COMBAT", DESCRIPTIONS.oncePerCombat },
}
-- The First group's checkboxes, before the items, and the Error Messages group's, as { option key, label key }.
local FIRST = {
	{ "stopCast", "MENU_STOP_CASTING" },
	{ "stopAttack", "MENU_STOP_ATTACK" },
	{ "cancelForm", "MENU_LEAVE_FORM_BEFORE" },
	{ "targetEnemy", "MENU_TARGET_NEAREST_ENEMY" },
	{ "targetFriend", "MENU_TARGET_NEAREST_FRIEND" },
}
local ERRORS = { { "hideErrors", "MENU_HIDE_ERRORS" }, { "muteErrors", "MENU_MUTE_ERRORS" } }
ns.MENU_COMBAT, ns.MENU_REPEAT, ns.MENU_FIRST, ns.MENU_ERRORS = COMBAT, REPEAT, FIRST, ERRORS
