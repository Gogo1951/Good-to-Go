local _, ns = ...

-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.POTIONS = {
	[32947] = { 1500, 0, nil, nil, 55, 0, 5, 0 }, -- Auchenai Healing Potion
	[32948] = { 0, 1800, nil, nil, 55, 0, 5, 0 }, -- Auchenai Mana Potion
	[32783] = { 0, 1800, { 1949, 330 }, nil, 70, 690, 5, 1 }, -- Blue Ogre Brew
	[32909] = { 0, 1800, { 1949, 330 }, nil, 70, 690, 5, 1 }, -- Blue Ogre Brew Special
	[32902] = { 0, 1800, { 1555, 266, 267, 268, 269, 270, 271, 334 }, nil, 55, 0, 15, 0 }, -- Bottled Nethergon Energy
	[32905] = { 1500, 0, { 1555, 266, 267, 268, 269, 270, 271, 334 }, nil, 55, 0, 15, 0 }, -- Bottled Nethergon Vapor
	[32904] = { 1500, 0, { 332, 1554, 263, 264, 262, 265 }, nil, 55, 0, 15, 1 }, -- Cenarion Healing Salve
	[32903] = { 0, 1800, { 332, 1554, 263, 264, 262, 265 }, nil, 55, 0, 15, 1 }, -- Cenarion Mana Salve
	[18839] = { 700, 0, nil, nil, 35, 250, 10, 1 }, -- Combat Healing Potion
	[18841] = { 0, 900, nil, nil, 41, 250, 10, 1 }, -- Combat Mana Potion
	[33934] = { 1500, 0, nil, nil, 55, 11500, 5, 1 }, -- Crystal Healing Potion
	[33935] = { 0, 1800, nil, nil, 55, 11500, 5, 1 }, -- Crystal Mana Potion
	[23578] = { 0, 1350, nil, nil, 49, 0, 10, 0 }, -- Diet McWeaksauce
	[4596] = { 140, 0, nil, nil, 5, 25, 5, 0 }, -- Discolored Healing Potion
	-- Enriched Lasher Root (23329) is absent on purpose: its live row is in Healthstones-TBC.lua, sharing the Healthstone cooldown category.
	[1072] = { 0, 280, nil, nil, 0, 62, 10, 0 }, -- Full Moonshine
	[1710] = { 455, 0, nil, nil, 21, 125, 5, 0 }, -- Greater Healing Potion
	[6149] = { 0, 700, nil, nil, 31, 120, 5, 0 }, -- Greater Mana Potion
	[929] = { 280, 0, nil, nil, 12, 75, 5, 0 }, -- Healing Potion
	[23822] = { 1500, 0, nil, nil, 55, 100000, 1, 0 }, -- Healing Potion Injector
	[33092] = { 1500, 0, nil, nil, 55, 5000, 20, 0 }, -- Healing Potion Injector
	[858] = { 140, 0, nil, nil, 3, 25, 5, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 280, nil, nil, 14, 30, 5, 0 }, -- Lesser Mana Potion
	-- Luminous Bluetail (35287) is absent on purpose: its live row is in Mana-Gems-TBC.lua, sharing the Mana Gem cooldown category.
	[31853] = { 1050, 0, nil, nil, 61, 1000, 10, 1 }, -- Major Combat Healing Potion
	[31838] = { 1050, 0, nil, nil, 61, 0, 10, 1 }, -- Major Combat Healing Potion
	[31839] = { 1050, 0, nil, nil, 61, 0, 10, 1 }, -- Major Combat Healing Potion
	[31852] = { 1050, 0, nil, nil, 61, 0, 10, 1 }, -- Major Combat Healing Potion
	[31855] = { 0, 1350, nil, nil, 61, 1000, 10, 1 }, -- Major Combat Mana Potion
	[31840] = { 0, 1350, nil, nil, 61, 0, 10, 1 }, -- Major Combat Mana Potion
	[31841] = { 0, 1350, nil, nil, 61, 0, 10, 1 }, -- Major Combat Mana Potion
	[31854] = { 0, 1350, nil, nil, 61, 0, 10, 1 }, -- Major Combat Mana Potion
	[17348] = { 980, 0, { 1459, 1460, 1461, 1956 }, nil, 45, 250, 10, 1 }, -- Major Healing Draught
	[13446] = { 1050, 0, nil, nil, 45, 1000, 5, 0 }, -- Major Healing Potion
	[17351] = { 0, 980, { 1459, 1460, 1461, 1956 }, nil, 45, 250, 10, 1 }, -- Major Mana Draught
	[13444] = { 0, 1350, nil, nil, 49, 1500, 5, 0 }, -- Major Mana Potion
	[18253] = { 1440, 1440, nil, nil, 50, 15, 5, 0 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455, nil, nil, 22, 120, 5, 0 }, -- Mana Potion
	[23823] = { 0, 1800, nil, nil, 55, 100000, 1, 0 }, -- Mana Potion Injector
	[33093] = { 0, 1800, nil, nil, 55, 5000, 20, 0 }, -- Mana Potion Injector
	[118] = { 70, 0, nil, nil, 1, 5, 5, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140, nil, nil, 5, 10, 5, 0 }, -- Minor Mana Potion
	[2456] = { 90, 90, nil, nil, 5, 15, 5, 0 }, -- Minor Rejuvenation Potion
	[3087] = { 0, 140, nil, nil, 0, 11, 10, 0 }, -- Mug of Shimmer Stout
	[32784] = { 1050, 0, { 1949, 330 }, nil, 70, 460, 5, 1 }, -- Red Ogre Brew
	[32910] = { 1050, 0, { 1949, 330 }, nil, 70, 460, 5, 1 }, -- Red Ogre Brew Special
	[32762] = { 0, 1800, nil, nil, 55, 50, 5, 0 }, -- Rulkster's Brain Juice
	[32763] = { 1500, 0, nil, nil, 55, 50, 5, 0 }, -- Rulkster's Secret Sauce
	[22829] = { 1500, 0, nil, nil, 55, 5000, 5, 0 }, -- Super Healing Potion
	[22832] = { 0, 1800, nil, nil, 55, 5000, 5, 0 }, -- Super Mana Potion
	[22850] = { 1650, 1650, nil, nil, 65, 7000, 5, 0 }, -- Super Rejuvenation Potion
	[17349] = { 560, 0, { 1459, 1460, 1461, 1956 }, nil, 35, 125, 10, 1 }, -- Superior Healing Draught
	[3928] = { 700, 0, nil, nil, 35, 250, 5, 0 }, -- Superior Healing Potion
	[17352] = { 0, 560, { 1459, 1460, 1461, 1956 }, nil, 35, 125, 10, 1 }, -- Superior Mana Draught
	[13443] = { 0, 900, nil, nil, 41, 400, 5, 0 }, -- Superior Mana Potion
	[23579] = { 1050, 0, nil, nil, 45, 0, 10, 0 }, -- The McWeaksauce Classic
	[28101] = { 0, 1350, nil, nil, 55, 1500, 5, 0 }, -- Unstable Mana Potion
	[28100] = { 1050, 0, nil, nil, 55, 1000, 5, 0 }, -- Volatile Healing Potion
	[9144] = { 1, 1, nil, nil, 35, 250, 5, 0 }, -- Wildvine Potion
	[34440] = { 1650, 1650, nil, 315, 60, 7000, 5, 0 }, -- Mad Alchemist's Potion
	-- Whipper Root Tuber (11951) is absent on purpose: its live row is in Healthstones-TBC.lua, sharing the Healthstone cooldown category.
}

--[[
How We Got the Data

Last Validated
	2026-11-11, TBC Anniversary 2.5.6.70577

Notes
	- Every potion this client knows that restores health or mana instantly on the potion cooldown, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Health Potion and Mana Potion macros. Healing Amount and Mana Amount are each effect's low end; requiredAlchemy is the Alchemy rank the tooltip requires.
	- Allowed Zones are uiMapIDs. The draughts' text says they work only in PvP battlegrounds: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin, 1956 Eye of the Storm.
	- Holy Spring Water (737) is left out on purpose, an oddball on the potion cooldown. Potions that do something else (rage, speed, protection, invisibility) are not in this table. Deprecated Potion of Lesser Invulnerability (Fix) (2462) is a placeholder nothing drops, sells or makes.
	- The TBC zone potions have no area requirement in this client's tables; their zones come from their text. The Ogre Brews say only the Blade's Edge Plateaus (1949), and keep Gruul's Lair (330) too: they work there. Bottled Nethergon Energy and Vapor work inside Tempest Keep's four wings, and the Cenarion salves inside Coilfang's four.
	- Season of Discovery items are left out; this client doesn't know them. They live only in Data/Discovery/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006
	https://wago.tools/db2/SpellCastingRequirements?build=2.5.6.70006
	https://wago.tools/db2/AreaGroupMember?build=2.5.6.70006
	https://wago.tools/db2/UiMapAssignment?build=2.5.6.70006

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcItemDB.lua
]]
