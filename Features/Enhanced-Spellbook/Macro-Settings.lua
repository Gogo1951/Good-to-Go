local _, ns = ...

--[[
	Where the per-spell macro options are stored: each option's table on the character's profile, the key a
	macro's own settings sit under (its spell's, a Duplicate's or a rank's), and reading, storing and dropping
	one macro's setting for an option.
]]

--[[
	Per-spell settings, on the character's profile, each a table keyed by the macro's settings key
	(SettingsKey, built from the spell's Rank 1 ID, so the same in every language): "cursor" (macro casts a ground-targeted
	spell where the cursor points), "pet" (a summon macro casts the pet's ability while that pet is out), "stance" (the macro switches to a stance the spell can be cast in first), "petAttack"
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
	"macroTab" holds "general" where the macro's WoW macro is kept in the General list, and nil for the
	character's own, the default (see Features/Enhanced-Spellbook/Macro-Tab.lua).
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
