local _, ns = ...
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local GetSetting = ns.GetMacroSetting
local StoreSetting = ns.StoreMacroSetting

--[[
	The per-spell macro options: which options a page macro offers and which the player turned on, over the
	defaults each kind of macro starts from (Features/Enhanced-Spellbook/Macro-Kinds.lua). Features/Enhanced-Spellbook/Macro-Body.lua
	turns them into macro text. The
	page categories are Features/Enhanced-Spellbook/Page-Categories.lua, and the target priority
	Features/Enhanced-Spellbook/Target-Priority.lua. Where the settings are stored is
	Features/Enhanced-Spellbook/Macro-Settings.lua, and the ability rank choice
	Features/Enhanced-Spellbook/Macro-Rank-Option.lua.
]]

-- The default a macro follows for an option it has no setting of its own for.
local function MacroDefault(macro, key)
	return macro.kind ~= nil and ns.KindDefault(macro.kind, key)
end
ns.MacroDefault = MacroDefault

--[[
	Sets an option on a macro, stored only where it differs from the macro kind's default, so the rest follow
	a change of default.
]]
local function SetOption(macro, key, on)
	if on == MacroDefault(macro, key) then
		StoreSetting(macro, key, nil)
	else
		StoreSetting(macro, key, on)
	end
end

--[[
	Sets a choice of one among sibling options (keys) to pick, or to none when pick is nil. Where the whole
	choice matches the kind's defaults every key follows them; otherwise every key is stored, true for the
	pick and false for the rest, so a later change of default can't turn a second one on beside it.
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

-- Whether any macro turns "targetRank" on, by its own setting or its kind's default.
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

--[[
	Enemy spell macros offer "petAttack", whatever the class: any class can have a pet out for a while (a
	Shadowfiend, a mind-controlled enemy). A focus copy shares its spell's setting.
]]
function ns.OffersPetAttack(macro)
	return macro.target == "harm"
end

--[[
	Every spell macro offers "startAttack" except a stealth spell's: attacking would break the stealth. Every
	spell macro offers "stopCast" too, whatever the class. A focus copy shares its spell's settings.
]]
function ns.OffersStopCast()
	return true
end

function ns.OffersStartAttack(macro)
	return not macro.stealth
end

-- A form or aspect, which casting again would cancel, offers "noToggle".
function ns.OffersNoToggle(macro)
	return macro.toggles == true
end

-- An option every spell macro offers.
local function Always()
	return true
end

-- An enemy spell offers "targetEnemy".
local function TargetsHarm(macro)
	return macro.target == "harm"
end

-- A friendly spell offers "targetFriend", which picks a living friend, so not a resurrection.
local function TargetsHelp(macro)
	return ns.TargetsLivingFriend(macro)
end

-- Whether each option is offered on a macro, by key; ns.OffersOption offers no key missing here.
local OFFERED = {
	-- the Classic Era client, Season of Discovery included, has no focus target, so no focus copy; nor has a duplicate or a rank
	focus = function(macro)
		return macro.target ~= nil and ns.FLAVOR ~= "Vanilla" and not macro.copy and not macro.rank
	end,
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
	--[[
		melee after a heal, buff or resurrection is almost never wanted, so those kinds leave it out, except
		where it is on already, so it can be turned off
	]]
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
	--[[
		a Cast Sequence's end and resets do their work while it's on (Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence.lua),
		and Cast If Summoned builds no reset at all (Features/Enhanced-Spellbook/Macro-Body.lua)
	]]
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
	--[[
		whatever the class; leaving a form makes no sense on a form itself (a toggle or the stance bar's own), or
		on stealth, which needs Cat Form
	]]
	cancelForm = function(macro)
		return not macro.toggles and not macro.noGlow and not macro.stealth
	end,
	-- a ranged enemy spell, but not the ranged attack itself
	autoShot = function(macro)
		local autoShot = ns.ClassConfig().autoShot
		return autoShot ~= nil and macro.target == "harm" and macro.name ~= autoShot
	end,
	--[[
		a single-target spell whose group version (Prayer of Fortitude, Portal: Ironforge) is learned, or a group
		spell whose single version is
	]]
	groupVersion = function(macro)
		return ns.RightClickSpell(macro) ~= nil
	end,
}

-- Whether a macro offers an option (a key of OFFERED).
function ns.OffersOption(macro, key)
	local offered = OFFERED[key]
	return offered ~= nil and offered(macro) and true or false
end

-- The full label of the "autoShot" option for the player's class (Auto Shot, or the wand), or nil.
function ns.AutoShotLabelKey()
	return ns.ClassConfig().autoShotLabelKey
end

-- The client's name for the ranged attack the "autoShot" option starts (Auto Shot, or the wand's Shoot), or nil.
function ns.AutoShotName()
	return ns.ClassConfig().autoShot
end

-- The spell the "groupVersion" option casts on a right-click: the group version, or a group spell's single version.
function ns.RightClickSpell(macro)
	return macro.groupSpell or macro.soloSpell
end

-- Whether a macro offers an option (see ns.OffersOption) and the player turned it on.
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

-- Every spell macro offers using equipped items before the cast. A focus copy shares its spell's slots.
function ns.OffersUseItems()
	return true
end

local NO_SLOTS = {}

-- Shared with Features/Enhanced-Spellbook/Target-Priority.lua, so the empty list it returns is this same one.
ns.NO_SLOTS = NO_SLOTS

-- The equipment slots a macro uses before its cast, in the order the player ticked them. Don't modify it.
function ns.UseItemSlots(macro)
	if not ns.OffersUseItems(macro) then
		return NO_SLOTS
	end
	return SpellSettings("useItems")[SettingsKey(macro)] or NO_SLOTS
end

-- A slot's place in a macro's UseItemSlots, or nil when the macro doesn't use it.
function ns.IsUsingSlot(macro, slot)
	for i, used in ipairs(ns.UseItemSlots(macro)) do
		if used == slot then
			return i
		end
	end
end

--[[
	Whether a macro has an options menu: every spell macro does, since every one offers stopCast. A
	consumable's macro is Consumable Macros', set up on its Consumable Macros panel, so the page offers it no menu.
]]
function ns.HasOptions(macro)
	return not macro.consumable
end

--[[
	The setters below only change the stored settings; the menus then rebuild the page, which rewrites every
	macro already made (ns.RefreshSpellbookPage).
]]

-- Sets a setting (any ns.OffersOption key) on or off.
function ns.SetOption(macro, key, on)
	SetOption(macro, key, on)
end

function ns.ToggleOption(macro, key)
	SetOption(macro, key, not ns.IsOptionOn(macro, key))
end

--[[
	The macro's combat check, a choice of one: "combatOnly" (it casts only in combat), "noCombat" (only out
	of combat), or nil for neither, the default.
]]
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

--[[
	How often the macro casts, a choice of one: "oncePerCombat" (once until combat ends or the target
	changes), "oncePerTarget" (once until the target changes), or nil for every press, the default. Both on
	is read as once per combat, as the macro text reads it.
]]
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

-- Adds an equipment slot to the end of the macro's useItems list, or removes it.
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
