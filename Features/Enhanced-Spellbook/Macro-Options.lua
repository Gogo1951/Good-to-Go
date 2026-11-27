local _, ns = ...
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local GetSetting = ns.GetMacroSetting
local StoreSetting = ns.StoreMacroSetting

local function MacroDefault(macro, key)
	return macro.kind ~= nil and ns.KindDefault(macro.kind, key)
end
ns.MacroDefault = MacroDefault

-- Stored only where it differs from the kind's default, so the rest follow a change of default.
local function SetOption(macro, key, on)
	if on == MacroDefault(macro, key) then
		StoreSetting(macro, key, nil)
	else
		StoreSetting(macro, key, on)
	end
end

--[[
	A choice of one among keys (pick nil for none). Off the defaults every key is stored, so a later change of
	default can't turn a second one on beside the pick.
]]
local function SetChoice(macro, keys, pick)
	local isDefault = true
	for _, key in ipairs(keys) do
		if (key == pick) ~= (MacroDefault(macro, key) and true or false) then
			isDefault = false
		end
	end
	for _, key in ipairs(keys) do
		if isDefault then
			StoreSetting(macro, key, nil)
		else
			StoreSetting(macro, key, key == pick)
		end
	end
end

function ns.AnyTargetRank()
	for _, on in pairs(SpellSettings("targetRank")) do
		if on then
			return true
		end
	end
	for _, kind in ipairs(ns.MACRO_KINDS) do
		if ns.KindDefault(kind.key, "targetRank") then
			return true
		end
	end
	return false
end

-- Whatever the class: any class can have a pet out for a while (a Shadowfiend, a mind-controlled enemy).
function ns.OffersPetAttack(macro)
	return macro.target == "harm"
end

function ns.OffersStopCast()
	return true
end

-- Attacking would break the stealth.
function ns.OffersStartAttack(macro)
	return not macro.stealth
end

-- A form or aspect, which casting again would cancel.
function ns.OffersNoToggle(macro)
	return macro.toggles == true
end

local function Always()
	return true
end

-- An auto attack (Attack, Shoot, Auto Shot) hits an enemy too.
local function TargetsHarm(macro)
	return macro.target == "harm" or ns.IsBasicAttack(macro)
end

-- targetFriend picks a living friend, so not on a resurrection.
local function TargetsHelp(macro)
	return ns.TargetsLivingFriend(macro)
end

-- ns.OffersOption offers no key missing here.
local OFFERED = {
	cursor = function(macro)
		return macro.cursor
	end,
	pet = function(macro)
		return macro.petAbility ~= nil
	end,
	stance = function(macro)
		return macro.stances ~= nil
	end,
	petAttack = function(macro)
		return ns.OffersPetAttack(macro)
	end,
	stopCast = function(macro)
		return ns.OffersStopCast(macro)
	end,
	-- melee after a heal, buff or resurrection is almost never wanted; offered there only while on, to turn off
	startAttack = function(macro)
		if not ns.OffersStartAttack(macro) then
			return false
		end
		if macro.kind ~= "friendly" and macro.kind ~= "buff" and macro.kind ~= "resurrect" then
			return true
		end
		local on = GetSetting(macro, "startAttack")
		if on == nil then
			return MacroDefault(macro, "startAttack")
		end
		return on == true
	end,
	noToggle = function(macro)
		return ns.OffersNoToggle(macro)
	end,
	targetRank = function(macro)
		return ns.OffersTargetRank(macro)
	end,
	targetEnemy = TargetsHarm,
	targetFriend = TargetsHelp,
	combatOnly = Always,
	noCombat = Always,
	-- a Cast Sequence's end and resets do this job while on, and Cast If Summoned builds no reset at all
	oncePerCombat = function(macro)
		return not ns.IsCastSequenceOn(macro) and not ns.IsOptionOn(macro, "pet")
	end,
	oncePerTarget = function(macro)
		return not ns.IsCastSequenceOn(macro) and not ns.IsOptionOn(macro, "pet")
	end,
	stopAttack = Always,
	stopIfChanneling = Always,
	stopIfStealthed = Always,
	hideErrors = Always,
	muteErrors = Always,
	-- not on a form itself (a toggle or the stance bar's own), or on stealth, which needs Cat Form
	cancelForm = function(macro)
		return not macro.toggles and not macro.noGlow and not macro.stealth
	end,
	autoShot = function(macro)
		local autoShot = ns.ClassConfig().autoShot
		return autoShot ~= nil and macro.target == "harm" and macro.name ~= autoShot
	end,
	groupVersion = function(macro)
		return ns.RightClickSpell(macro) ~= nil
	end,
}

function ns.OffersOption(macro, key)
	local offered = OFFERED[key]
	return offered ~= nil and offered(macro) and true or false
end

function ns.AutoShotLabelKey()
	return ns.ClassConfig().autoShotLabelKey
end

-- Auto Shot, or the wand's Shoot, or nil
function ns.AutoShotName()
	return ns.ClassConfig().autoShot
end

function ns.RightClickSpell(macro)
	return macro.groupSpell or macro.soloSpell
end

function ns.IsOptionOn(macro, key)
	if not ns.OffersOption(macro, key) then
		return false
	end
	local on = GetSetting(macro, key)
	if on == nil then
		return MacroDefault(macro, key)
	end
	return on == true
end

function ns.OffersUseItems()
	return true
end

local NO_SLOTS = {}

-- Target-Priority.lua returns this same empty list.
ns.NO_SLOTS = NO_SLOTS

-- In the order the player ticked them. Don't modify it.
function ns.UseItemSlots(macro)
	if not ns.OffersUseItems(macro) then
		return NO_SLOTS
	end
	return SpellSettings("useItems")[SettingsKey(macro)] or NO_SLOTS
end

function ns.IsUsingSlot(macro, slot)
	for i, used in ipairs(ns.UseItemSlots(macro)) do
		if used == slot then
			return i
		end
	end
end

-- A consumable's macro is set up on its Consumable Macros panel, so the page offers it no menu.
function ns.HasOptions(macro)
	return not macro.consumable
end

-- The setters only store; the menus then rebuild the page, which rewrites the macros (ns.RefreshSpellbookPage).

function ns.SetOption(macro, key, on)
	SetOption(macro, key, on)
end

function ns.ToggleOption(macro, key)
	SetOption(macro, key, not ns.IsOptionOn(macro, key))
end

local COMBAT_CHECKS = { "combatOnly", "noCombat" }

function ns.CombatCheck(macro)
	for _, key in ipairs(COMBAT_CHECKS) do
		if ns.IsOptionOn(macro, key) then
			return key
		end
	end
	return nil
end

function ns.SetCombatCheck(macro, check)
	SetChoice(macro, COMBAT_CHECKS, check)
end

-- Both on reads as once per combat, as the macro text does; nil casts on every press.
local REPEAT_RULES = { "oncePerCombat", "oncePerTarget" }

function ns.RepeatRule(macro)
	for _, key in ipairs(REPEAT_RULES) do
		if ns.IsOptionOn(macro, key) then
			return key
		end
	end
	return nil
end

function ns.SetRepeatRule(macro, rule)
	SetChoice(macro, REPEAT_RULES, rule)
end

function ns.ToggleUseSlot(macro, slot)
	local slots = {}
	local at = ns.IsUsingSlot(macro, slot)
	for i, used in ipairs(ns.UseItemSlots(macro)) do
		if i ~= at then
			slots[#slots + 1] = used
		end
	end
	if not at then
		slots[#slots + 1] = slot
	end
	SpellSettings("useItems")[SettingsKey(macro)] = #slots > 0 and slots or nil
end
