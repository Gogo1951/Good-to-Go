local _, ns = ...

--[[
    The fields a definition passed to ns.RegisterMacroType may carry:

    Selection (the scanner; one item may feed several definitions)
      typeName                key into ns.MACRO_CONFIG (required)
      itemTypes               set of ns.CacheItemData itemType strings claimed
      accepts(data)           extra gate on the cached item data
      score(data)             raw value for the ladder; burn-first prefs are ladder steps, not bonuses
      ranked                  rank every candidate into topIDs (multi-use types)
      allowBuffFood, buffFoodFirstWhenUnfed, allowConjuredFirst, allowRestockLast
                              open the matching gated ladder steps
      preferHybrid            true prefers food/water hybrids (Food), false dedicated items (Water)
      winnerExtras(w, data, link)  non-comparison fields only; FillRecord fills the rest

    Body
      conjure()               the Conjure Protocol table below, or nil
      modifyItem(id)          swap the scanned item (Food's pet-buff override)
      buildUseLine(id)        custom /use line(s); nil falls back to the standard block
      getStackIDs(best), stackTypeName  ids stacked below the main block, and their type
      outOfCombatTypeName     the type whose scanned pick this body uses out of combat
      stealthSpell()          (name, flag) cast while eating or drinking, or nil
      corpseSpell(entry)      tried first on a dead target, falling through
      leadSpell(entry)        cast instead out of combat, then stop
      combatSpell(entry)      cast instead in combat, then stop
      stateExtras(parts, id)  extra state-key parts
      appendBlock(id)         (text, flag) appended after the action block
      customUpdate(forced)    owns its whole update; skipped by the standard loop
]]

--------------------------------------------------------------------------------
-- Definition Registry
--------------------------------------------------------------------------------

local macroDefinitions = {}
local customDefinitions = {}

ns.REGISTERED_MACRO_DEFINITIONS = macroDefinitions

ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS = customDefinitions

local definitionsByType = {}

function ns.MacroDefinitionByType(typeName)
	return definitionsByType[typeName]
end

function ns.RegisterMacroType(definition)
	definitionsByType[definition.typeName] = definition
	if definition.customUpdate then
		customDefinitions[#customDefinitions + 1] = definition
	else
		macroDefinitions[#macroDefinitions + 1] = definition
	end
end

--------------------------------------------------------------------------------
-- Conjure Protocol
--------------------------------------------------------------------------------

--[[
    A `conjure` hook returns nil (plain /use body) or, every field optional:
      rightName, rightID      /cast on [btn:2]
      middleName, middleID    /cast on [btn:3]
      rightMiss, middleMiss   GtGTip key for that click while its spell is unlearned
      noItemMiss              GtGTip key replacing the no-item line while the conjure is learnable
]]
