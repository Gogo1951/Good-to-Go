local _, ns = ...

-- Stealth Abilities
ns.SHADOWMELD_SPELL_ID = 58984

ns.STEALTH_SPELL_ID = 1784

-- Cannibalize (Forsaken)
ns.CANNIBALIZE_SPELL_ID = 20577
ns.CANNIBALIZE_CREATURE_TYPE_IDS = { 6, 7 }
ns.CANNIBALIZE_RESTORES_MANA = true

-- Races
ns.NIGHT_ELF_RACE_ID = 4
ns.UNDEAD_RACE_ID = 5

-- Druid Forms
-- This client has no Dire Bear Form, so Bear Form stands in: the return-form list stays free of holes.
ns.DRUID_DIRE_BEAR_FORM_SPELL_ID = 5487
ns.DRUID_BEAR_FORM_SPELL_ID = 5487
ns.DRUID_CAT_FORM_SPELL_ID = 768

-- Hunter Pet Spells
ns.CALL_PET_SPELL_ID = 883
ns.DISMISS_PET_SPELL_ID = 2641
ns.FEED_PET_SPELL_ID = 6991
ns.MEND_PET_SPELL_ID = 136
ns.REVIVE_PET_SPELL_ID = 982

-- Well Fed Buff
-- A "Well Fed" food buff, read for the buff's name; it is named Well Fed in every locale on every client.
ns.WELL_FED_SPELL_ID = 19705

-- Global Cooldown
-- Read for the global cooldown's own timer, which a cooldown check compares against.
ns.GLOBAL_COOLDOWN_SPELL_ID = 61304

-- Ranged Attack
-- Shoot, read for the one label the page gives its folded ranged-attack macro.
ns.SHOOT_SPELL_ID = 5019

-- Auto Attacks
-- Auto Attack, Auto Shot and Shoot (a wand): the page's Basic Attacks.
ns.BASIC_ATTACK_SPELL_IDS = { 6603, 75, 5019 }

-- Ranged Weapon Attacks
-- { id = spellId, subclass = the weapon's Enum.ItemWeaponSubclass }, in the order the Shoot macro tries them.
-- None: this client has no Throw, Shoot Bow, Shoot Gun or Shoot Crossbow for any class to learn.
ns.RANGED_ATTACKS = {}

-- Call Pet Flyout
-- MoP Classic's spellbook holds Call Pet as this flyout; a book without one never matches it.
ns.CALL_PET_FLYOUT_ID = 9

-- Season of Discovery Spells
-- Season of Discovery's spell IDs start here, the same cut the Vanilla data tables make.
ns.SOD_FIRST_SPELL_ID = 300000

-- Restocker Example
-- Refreshing Spring Water, the staple the Restocker page's Example lines show short.
ns.SAMPLE_RESTOCK_ITEM_ID = 159

-- Mana Runes
-- The two runes the Mana Gem panel names, read for their names.
ns.DEMONIC_RUNE_ITEM_ID = 12662
ns.DARK_RUNE_ITEM_ID = 20520

-- Pet Buff Food
-- [itemID] = { buffSpellID, rank, settingKey, requiredLevel }, -- Item Name
ns.PET_BUFF_FOODS = {}

-- Professions
-- The profession skill lines the usability gates read ranks from. Each is found
-- in the skill list by the name the client gives its ID.
ns.FIRST_AID_SKILL_LINE_ID = 129
ns.ALCHEMY_SKILL_LINE_ID = 171
ns.ENGINEERING_SKILL_LINE_ID = 202

-- The Engineering specialization Diagnostics checks the player for.
ns.GOBLIN_ENGINEER_SPELL_ID = 20222

-- Thanks for the Buff
-- [constant] = spell id, -- Spell Name
-- No PHASE_SHIFT_SPELL_ID: this client's imp has no Phase Shift.
ns.GAME_IDS = {
	SAMPLE_BUFF_SPELL_ID = 1459, -- Arcane Brilliance
	SAMPLE_COMBAT_BUFF_SPELL_ID = 1044, -- Hand of Freedom
	SAMPLE_GOOD_NEWS_SPELL_ID = 10060, -- Power Infusion
	SAMPLE_SERVICE_SPELL_ID = 10059, -- Portal: Stormwind
}

-- { texture file ID, button it starts on }, -- Icon File Name
ns.THANK_YOU_MACRO_ICONS = {
	{ 135453, 2 }, -- inv_valentinescard01
	{ 134141, 3 }, -- inv_misc_gift_02
	{ 134927, 4 }, -- inv_rosebouquet01
	{ 133783, 5 }, -- inv_misc_celebrationcake_01
	{ 135767 }, -- spell_brokenheart
	{ 133939 }, -- inv_misc_flower_02
	{ 135263 }, -- inv_summerfest_fireflower
	{ 133196 }, -- inv_holiday_beerfestpretzel01
	{ 133201 }, -- inv_holiday_brewfestbuff_01
	{ 134505 }, -- inv_misc_toy_01
	{ 135448 }, -- inv_valentinepinkrocket
	{ 132387 }, -- inv_ammo_snowball
	{ 133785 }, -- inv_misc_coin_02
	{ 134237 }, -- inv_misc_key_03
	{ 133471 }, -- inv_letter_15
	{ 134481 }, -- inv_misc_ticket_darkmoon_01
	{ 134333 }, -- inv_misc_orb_01
	{ 133730 }, -- inv_misc_bone_humanskull_01
	{ 134153 }, -- inv_misc_head_dragon_01
	{ 132834 }, -- inv_egg_03
}

--[[
How We Got the Data

Last Validated
	2026-11-04, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Single spell, item, race and skill-line IDs the feature code reads by name, grouped by use. The client supplies every name the player sees from these IDs.
	- Shadowmeld and Stealth are the spells the Food and Water macros cast for Stealth Eating and Shadowmeld Drinking. Shadowmeld is 58984 on this client, the Night Elf racial on its skill line; 20580 is gone. Stealth has no ranks here.
	- Cannibalize is the Forsaken racial, which channels off a corpse of the creature types listed (6 Undead, 7 Humanoid). Its channel (20578) restores 7% of health and 7% of mana on this client (SpellEffect auras 20 and 21), so CANNIBALIZE_RESTORES_MANA is true and the Water macro may cast it.
	- Dire Bear Form (9634) doesn't exist on this client. Bear Form fills both constants so the Druid Macro Helper's bear list holds no nil.
	- This client has no Poisons skill (2842 is absent, and the Poisons skill line 40 has no abilities): a rogue's poisons are spells in the Poisons flyout (66), and the old poison items are Empty Poison Vials with no use. So there is no POISONS_SPELL_ID here, and with none the item-based Poisons macro and the mini-map's rogue notes stay off. Making the macro cast the poison spells is a code change, not data.
	- Throw (2764) is still in the spell tables but on no skill line, and Shoot Bow, Shoot Gun and Shoot Crossbow are gone, so RANGED_ATTACKS is empty and the Basic Attacks are Auto Attack, Auto Shot and Shoot (a wand, skill line 228).
	- The Call Pet flyout is SpellFlyout 9, holding Call Pet 1 to 5 (883, 83242-83245).
	- SOD_FIRST_SPELL_ID is read only where the Vanilla client hides Season of Discovery spells; it is declared here so every folder holds the same constants.
	- Well Fed (19705) is read for the buff's name, which is Well Fed in every locale on every client. The two mana runes are read for the names the Mana Gem panel shows; both items are still on this client.
	- ns.PET_BUFF_FOODS is empty: Kibler's Bits (33874) now only makes a pet bigger (65247), and Sporeling Snack (27656) has no use.
	- The profession skill lines are the ones the usability gates read ranks from; each is found in the skill list by the name the client gives its ID. All three are on this client. The Goblin Engineer specialization is what Diagnostics checks the player for.
	- Thanks for the Buff: Spell IDs that feature code needs by name rather than from a list: the sample spells the options panels use for their preview messages. 1459 is named Arcane Brilliance on this client.
	- Thanks for the Buff: PHASE_SHIFT_SPELL_ID is left out: the imp's abilities on this client (skill line 188) have no Phase Shift, and the Buff Window reads a missing ID as never shifted.
	- Thanks for the Buff: SAMPLE_GOOD_NEWS_SPELL_ID (Power Infusion) is the spell linked in the Good News sample whisper (Options/Automated-Appreciation/Options-Send-Good-News.lua).
	- Thanks for the Buff: SAMPLE_COMBAT_BUFF_SPELL_ID (Hand of Freedom) is the spell linked in the Combat Buffs sample whisper and print out, cast by a sample Paladin (Options/Automated-Appreciation/Options-Teammate-Buffs.lua): a buff cast in a fight, unlike SAMPLE_BUFF_SPELL_ID's Arcane Intellect, which the Stranger Buffs samples use.
	- Thanks for the Buff: THANK_YOU_MACRO_ICONS are the icons a Thank You Button macro can wear (Options/Automated-Appreciation/Options-Thank-You-Button.lua). All twenty are in this client's ManifestInterfaceData under the same IDs.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/SkillLine?build=5.5.4.70631
	https://wago.tools/db2/SpellFlyout?build=5.5.4.70631
	https://wago.tools/db2/SpellFlyoutItem?build=5.5.4.70631
	https://wago.tools/db2/ChrRaces?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/ManifestInterfaceData?build=5.5.4.70631

QuestieDB
	None.
]]
