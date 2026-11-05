local _, ns = ...

ns.CANNIBALIZE_CREATURE_TYPE_IDS = {}

ns.BASIC_ATTACK_SPELL_IDS = {}

-- { id = spellId, subclass = the weapon's Enum.ItemWeaponSubclass }, in the order the Shoot macro tries them.
ns.RANGED_ATTACKS = {}

-- [itemID] = { buffSpellID, rank, settingKey, requiredLevel }, -- Item Name
ns.PET_BUFF_FOODS = {}

-- [constant] = spell id, -- Spell Name
ns.GAME_IDS = {}

-- { texture file ID, button it starts on }, -- Icon File Name
ns.THANK_YOU_MACRO_ICONS = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Declared empty because Retail ships no TOC yet, so feature code can read the tables without checking which flavor built it. The rows come when this flavor's data is built from a Validate Data report on a Retail client.
	- Only the tables are declared. The single-ID constants beside them in Data/Vanilla/Game-IDs-Vanilla.lua (SHADOWMELD_SPELL_ID, STEALTH_SPELL_ID, CANNIBALIZE_SPELL_ID, CANNIBALIZE_RESTORES_MANA, NIGHT_ELF_RACE_ID, UNDEAD_RACE_ID, DRUID_DIRE_BEAR_FORM_SPELL_ID, DRUID_BEAR_FORM_SPELL_ID, DRUID_CAT_FORM_SPELL_ID, POISONS_SPELL_ID, CALL_PET_SPELL_ID, DISMISS_PET_SPELL_ID, FEED_PET_SPELL_ID, MEND_PET_SPELL_ID, REVIVE_PET_SPELL_ID, WELL_FED_SPELL_ID, SHOOT_SPELL_ID, CALL_PET_FLYOUT_ID, SOD_FIRST_SPELL_ID, SAMPLE_RESTOCK_ITEM_ID, DEMONIC_RUNE_ITEM_ID, DARK_RUNE_ITEM_ID, FIRST_AID_SKILL_LINE_ID, ALCHEMY_SKILL_LINE_ID, ENGINEERING_SKILL_LINE_ID, GOBLIN_ENGINEER_SPELL_ID) get their values when this flavor's data is built.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
