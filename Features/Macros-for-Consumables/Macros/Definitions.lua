local _, ns = ...

--[[
    Definitions -- the definition protocol every consumable macro follows,
    and the registry Engine.lua's update loop and the scanner read it from.

    Per-macro behavior lives in Features/Macros-for-Consumables/Macros/<Name>.lua files, each of
    which calls ns.RegisterMacroType with a definition table:

      typeName          -- key into ns.MACRO_CONFIG (required)

    Selection fields — how the scanner picks this category's item. A
    definition with an itemTypes set participates in ScanBags: every usable
    bag item is dispatched to each definition claiming its cached itemType
    (more than one may claim the same item — a hybrid potion feeds Health
    Potion and Mana Potion, a foodwater item feeds Food and Water). The
    shared tiebreak ladder (RANKING_PRIORITY) stays in Scanner-Ranking.

      itemTypes         -- set of ns.CacheItemData itemType strings this
                           category consumes, e.g. {potion = true}
      accepts(data)     -- optional extra gate on the cached item data
                           (Health Potion: data.healthValue > 0)
      score(data)       -- the raw restore/damage value fed to the ladder's
                           value step, e.g. data.healthValue. Burn-first
                           preferences (conjured, zone-locked, soulbound,
                           high-stack) are ladder steps, not score bonuses
      ranked            -- true: collect all candidates and rank into the
                           winner's topIDs (the multi-use types); otherwise
                           a single running winner is kept
      allowBuffFood     -- true: compare with the scanner's live
                           ns.allowBuffFood preference (Food, Water); absent:
                           the ladder's buff-food step stays gated off
      allowConjuredFirst -- true: compare with the scanner's live
                           ns.allowConjuredFirst preference (Food, Water);
                           absent: the ladder's conjured-first step stays
                           gated off
      allowRestockLast  -- true: compare with the scanner's live
                           ns.allowRestockLast preference (Food, Water);
                           absent: the ladder's restock-last step stays
                           gated off
      preferHybrid      -- direction of the ladder's hybrid step: true
                           prefers hybrid food/water (Food), false prefers
                           dedicated items (Water)
      winnerExtras(winner, data, hyperlink) -- store NON-comparison fields on
                           the winning record (Food: link, for
                           ns.bestFoodLink). Everything the ladder compares is
                           filled by the scanner's FillRecord

    Body hooks — what the written macro looks like.

      conjure()         -- class conjure resolver; returns the info table
                           documented under Conjure Protocol below, or nil
                           when this character has no conjure semantics
                           (Mage Food/Water/Mana Gem, Warlock Healthstone/
                           Soulstone)
      modifyItem(id)    -- replace the scanned best item before body assembly
                           (Food's pet-buff override)
      buildUseLine(id)  -- custom /use line(s) for the item; nil falls back to
                           the standard single- or multi-use block (Explosive's
                           click layout, Food's [@pet] line)
      getStackIDs(best) -- ranked ids appended below the main block, or the
                           whole body when there is no main item (Health
                           Potion's healthstone stacking)
      stackTypeName     -- the macro type those ids belong to, whose
                           DruidMacroHelper guards a stack-only body takes
                           (Health Potion: "Healthstone")
      outOfCombatTypeName -- the macro type whose scanned best item this body
                           uses instead while out of combat, behind
                           potionsUseFoodAndWater (Health Potion: "Food",
                           Mana Potion: "Water"). The scanned item only: no
                           scrolls, pet food or conjure clicks. Its stealth
                           and Cannibalize come along, from that type's
                           stealthSpell and corpseSpell
      stealthSpell()    -- (spellName, stateFlag) the definition's macro casts
                           while eating or drinking, or nil while off: Food's
                           Stealth Eating, Water's Stealth Drinking. Read by
                           a potion macro whose outOfCombatTypeName names it
      corpseSpell(entry) -- a spell name the body tries first on a dead target,
                           falling through to eating or drinking when it
                           cannot cast, or nil: Food's and Water's Forsaken
                           Cannibalize. entry is the scanned pick; the
                           engine asks only when the body uses that pick, and
                           a potion macro asks its outOfCombatTypeName's
      buildModeOverride(context) -- full-body takeover; returns body, stateKey
                           or nil (Food's scroll-only mode). Mode state keys
                           MUST use their own prefix (e.g. "SCROLLS:") so they
                           can never collide with standard ITEMID-keys — a
                           transition into or out of the mode always rewrites.
      stateExtras(parts, id) -- append extra state-key parts (Explosive's
                           "EX:mode" click layout)
      appendBlock(id)   -- returns (text, stateFlag) appended after the action
                           block, given the item the body uses (after
                           modifyItem; nil when there is none): Water's
                           Shadowmeld line (flag "SM") and Food's Stealth
                           Eating line (flag "SE")
      customUpdate(forced) -- the definition owns its whole update; it is
                           skipped by the standard loop (Feed Pet, which
                           routes to the Hunter builder, and Poisons, which
                           routes to the Rogue builder)
]]

--------------------------------------------------------------------------------
-- Definition Registry
--------------------------------------------------------------------------------

local macroDefinitions = {}
local customDefinitions = {}

--[[
    The scanner and Engine.lua read the standard definitions' selection
    fields at scan and update time (the scanner loads before this file, so
    it cannot see the local directly; every scan happens long after all
    registrations).
]]
ns.REGISTERED_MACRO_DEFINITIONS = macroDefinitions

--[[
    The custom definitions, exposed on the same terms for diagnostics only.
    They own their whole update and never reach the scanner's ranking ladder,
    so the Selection Report names them as resolved elsewhere rather than
    leaving the reader to wonder why Feed Pet and Poisons are missing from it.
]]
ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS = customDefinitions

-- Every definition by typeName, so a potion macro can reach its outOfCombatTypeName's hooks.
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
    A definition's `conjure` hook is a function returning a table:

      {
        rightName, rightID,    -- /cast spell on [btn:2] (or nil)
        middleName, middleID,  -- /cast spell on [btn:3] (or nil)
        rightMiss,             -- GtGTip key to fire on [btn:2] when right
                                  is not yet learned (or nil)
        middleMiss,            -- GtGTip key to fire on [btn:3] when middle
                                  is not yet learned (or nil)
        noItemMiss,            -- GtGTip key to fire on left-click when there
                                  is no item to /use AND the class can learn
                                  the conjure (replaces the generic no-item
                                  message). (or nil)
      }

    Returning nil from the resolver means "no conjure semantics for this
    macro type for this player" — leave the macro body as plain /use item.
    Class gating (ns.isMage / ns.isWarlock) lives inside each resolver.
]]
