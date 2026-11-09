local _, ns = ...

--[[
	The per-spell macro options: which options a page macro offers and which the player turned on, over the
	defaults each kind of macro starts from (Features/Enhanced-Spellbook/Macro-Kinds.lua). Features/Enhanced-Spellbook/Macro-Body.lua
	turns them into macro text. The
	page categories are Features/Enhanced-Spellbook/Page-Categories.lua, and the target priority
	Features/Enhanced-Spellbook/Target-Priority.lua.
]]

--[[
	Per-spell settings, on the character's profile, each a table keyed by the macro's settings key
	(SettingsKey, built from the spell's Rank 1 ID, so the same in every language): "cursor" (macro casts a ground-targeted
	spell where the cursor points), "focus" (the page also lists a copy of the macro that casts on the focus
	target), "pet" (a summon macro casts the pet's ability while that pet is out), "stance" (the macro switches to a stance the spell can be cast in first), "petAttack"
	(the macro also sends the pet to attack), "stopCast" (the macro stops the current cast first),
	"startAttack" (the macro starts melee auto-attack after the cast), "noToggle" (a form or aspect's macro
	casts "!Name", which never cancels it when it is already on), "targetRank" (a ranked friendly spell's macro
	casts the highest rank its target's level can take, rewritten as the target changes), "fixedRank" (a
	ranked spell's macro always casts this rank, by the rank's own spell ID), "targetEnemy" (an enemy spell's
	macro targets the nearest enemy first when there is no living hostile target), "targetFriend" (a
	friendly spell's macro targets the nearest friend first when there is no living friendly target), "combatOnly" (the macro
	casts only in combat), "noCombat" (only out of combat; see ns.CombatCheck), "oncePerCombat" (the macro casts once until combat ends or the target changes),
	"oncePerTarget" (the macro casts once until the target changes), "stopAttack" (the macro stops melee
	first), "stopIfChanneling" (the macro does nothing while any spell is channeling), "stopIfStealthed" (the macro does nothing while the player is stealthed), "hideErrors" (the macro clears the error text after), "muteErrors" (the macro mutes error sounds while it runs), "cancelForm" (the macro leaves a form first), "autoShot" (the macro starts Auto Shot,
	or the wand, after the cast) or "groupVersion" (a right-click casts the spell's group version, or a group
	spell's single version). Each is true
	or false where the player set it, overriding the macro kind's default (see KindDefault), and nil where the
	macro follows that default, except "fixedRank", which holds the rank's spell ID, or nil for the highest rank.
	"useItems" holds a list of equipment slots instead of a flag: the macro uses
	each slot's item, in that order, before the cast. "groupedSpells" holds a list of Rank 1 spell IDs: the
	spells of the macro's SPELL_GROUPS group ticked in its Grouped Spells submenu (see ns.CastSpellName), and
	"targetPriority" a list of units, who it casts on in turn (see ns.TargetPriority), and "conditionals" a list
	of rows, each a spell cast in the macro's place when its conditions match (see ns.Conditionals).
	"castSequence" holds the Cast Sequence's steps after the macro's own, "castSequenceEnd" "stop" where it
	stops on NULL, and "castSequenceReset" its resets (see Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence.lua).
]]
local function SpellSettings(key)
	return ns.db.profile[key]
end

ns.SpellSettings = SpellSettings

--[[
	What a macro's saved data is keyed by, the same in every language and through every rank trained: its
	spell's Rank 1 ID (macro.baseID, see BaseSpellID in Features/Enhanced-Spellbook/Macro-Builder/Macro-Builder.lua), as
	a string, so it never reads as a list index. A consumable's macro casts no spell, so it goes by its macro
	type ("consumable:Food").
]]
local function MacroSpellKey(macro)
	if macro.baseID then
		return tostring(macro.baseID)
	end
	return "consumable:" .. tostring(macro.type)
end

ns.MacroSpellKey = MacroSpellKey

-- A Duplicate's settings key: its spell's key and its number ("1120#2").
function ns.CopySettingsKey(spellKey, number)
	return spellKey .. "#" .. number
end

--[[
	The key a macro's own settings sit under: its spell's key (MacroSpellKey), or for a copy made with Duplicate
	that key and its number ("1120#2"), and for a rank's macro (Show All Spell Ranks) that key and the rank's own
	spell ID ("133@8400"), so a copy's settings are its own.
]]
local function SettingsKey(macro)
	local key = MacroSpellKey(macro)
	if macro.copy then
		return ns.CopySettingsKey(key, macro.copy)
	elseif macro.rankID then
		return key .. "@" .. macro.rankID
	end
	return key
end

ns.SettingsKey = SettingsKey

-- A macro's own setting for an option: true, false, or nil where it follows the default.
local function GetSetting(macro, key)
	return SpellSettings(key)[SettingsKey(macro)]
end

-- Stores a macro's own setting for an option; nil drops it.
local function StoreSetting(macro, key, value)
	SpellSettings(key)[SettingsKey(macro)] = value
end

-- Both read by the target priority (Features/Enhanced-Spellbook/Target-Priority.lua), which stores a list the same way.
ns.GetMacroSetting = GetSetting
ns.StoreMacroSetting = StoreSetting

-- Drops a macro's own setting for an option, so it follows its kind's default.
function ns.ClearOwnSetting(macro, key)
	StoreSetting(macro, key, nil)
end

-- The default a macro follows for an option it has no setting of its own for.
local function MacroDefault(macro, key)
	return macro.kind ~= nil and ns.KindDefault(macro.kind, key)
end

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

--[[
	Whether a spell can be cast on a living friend (not a resurrection, whose dead friend is never the player)
	or on anyone, which is what Target Rank needs (ns.OffersTargetRank).
]]
local function TargetsLivingFriend(macro)
	return macro.target == "help" and macro.kind ~= "resurrect"
end

local function TargetsFriendOrAnyone(macro)
	return TargetsLivingFriend(macro) or macro.target == "exists"
end

--[[
	A friendly spell with more than one rank known offers "targetRank", and so does one whose right-click
	spell has (Arcane Brilliance, right-clicking for Arcane Intellect), which takes its ranks the same way. A
	focus copy shares its setting.
]]
function ns.OffersTargetRank(macro)
	local function ranked(ranks)
		return ranks ~= nil and #ranks > 1
	end
	return not macro.rank
		and TargetsFriendOrAnyone(macro)
		and (ranked(macro.ranks) or (ns.RightClickSpell(macro) ~= nil and ranked(macro.rightClickRanks)))
end

--[[
	A spell with more than one rank, known or not, offers a fixed rank (see ns.AbilityRank); only its known
	ranks (macro.ranks) can be chosen, the rest (macro.unknownRanks) are listed as not known. A rank's own
	macro is fixed to its rank, so offers no choice.
]]
function ns.OffersFixedRank(macro)
	return not macro.rank and macro.ranks ~= nil
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
	return TargetsLivingFriend(macro)
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
	-- a Cast Sequence's end and resets do their work while it's on (Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence.lua)
	oncePerCombat = function(macro)
		return not ns.IsCastSequenceOn(macro)
	end,
	oncePerTarget = function(macro)
		return not ns.IsCastSequenceOn(macro)
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

--[[
	The known rank the macro is fixed to, from its saved spell ID, or nil when it isn't, or that rank isn't among
	its known ranks. A rank's own macro is always fixed to its rank.
]]
local function FixedRankEntry(macro)
	local id = macro.rankID or (ns.OffersFixedRank(macro) and SpellSettings("fixedRank")[SettingsKey(macro)])
	for _, rank in ipairs(id and macro.ranks or NO_SLOTS) do
		if rank.id == id then
			return rank
		end
	end
	return nil
end

-- The text of the rank the macro is fixed to ("Rank 3"), as this client words it, or nil.
function ns.FixedRank(macro)
	if macro.rank then
		return macro.rank
	end
	local rank = FixedRankEntry(macro)
	return rank and rank.text
end

-- The spell ID of the rank the macro is fixed to, or nil.
function ns.FixedRankID(macro)
	local rank = FixedRankEntry(macro)
	return rank and rank.id
end

--[[
	The macro's ability rank, a choice of one: a known rank's text it always casts (see ns.FixedRank),
	"targetRank" (by the level of who it casts on), or nil for the highest rank, the default.
]]
function ns.AbilityRank(macro)
	return ns.IsOptionOn(macro, "targetRank") and "targetRank" or ns.FixedRank(macro)
end

--[[
	choice is as ns.AbilityRank gives it; a fixed rank is saved by its spell ID, not its text. "targetRank" is
	stored explicitly unless the whole choice matches the kind's default (Dynamic Rank, or the highest rank),
	so a fixed rank stays fixed when Dynamic Rank later becomes the default.
]]
function ns.SetAbilityRank(macro, choice)
	local isTarget = choice == "targetRank"
	local isDefault = (choice == nil or isTarget) and isTarget == (MacroDefault(macro, "targetRank") and true or false)
	if isDefault then
		StoreSetting(macro, "targetRank", nil)
	else
		StoreSetting(macro, "targetRank", isTarget)
	end
	local id
	for _, rank in ipairs(choice and choice ~= "targetRank" and macro.ranks or NO_SLOTS) do
		if rank.text == choice then
			id = rank.id
		end
	end
	SpellSettings("fixedRank")[SettingsKey(macro)] = id
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
