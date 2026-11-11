local _, ns = ...

-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.POTIONS = {
	[76094] = { 38000, 9500, nil, 500, 85, 250, 20, 0 }, -- Alchemist's Rejuvenation
	[32947] = { 1500, 0, nil, nil, 55, 0, 20, 0 }, -- Auchenai Healing Potion
	[32948] = { 0, 1800, nil, nil, 55, 0, 20, 0 }, -- Auchenai Mana Potion
	[63144] = { 6750, 0, { 244, 245 }, nil, 0, 460, 20, 1 }, -- Baradin's Wardens Healing Potion
	[63145] = { 0, 6750, { 244, 245 }, nil, 0, 0, 20, 1 }, -- Baradin's Wardens Mana Potion
	[32783] = { 0, 1800, { 330 }, nil, 70, 690, 20, 1 }, -- Blue Ogre Brew
	[32909] = { 0, 1800, { 330 }, nil, 70, 690, 20, 1 }, -- Blue Ogre Brew Special
	[32902] = { 0, 1800, { 1555, 266, 267, 268, 269, 270, 271, 334 }, nil, 55, 0, 20, 0 }, -- Bottled Nethergon Energy
	[32905] = { 1500, 0, { 1555, 266, 267, 268, 269, 270, 271, 334 }, nil, 55, 0, 20, 0 }, -- Bottled Nethergon Vapor
	[32904] = { 1500, 0, { 332, 1554, 263, 264, 262, 265 }, nil, 55, 0, 20, 1 }, -- Cenarion Healing Salve
	[32903] = { 0, 1800, { 332, 1554, 263, 264, 262, 265 }, nil, 55, 0, 20, 1 }, -- Cenarion Mana Salve
	[18839] = { 861, 0, nil, nil, 35, 250, 20, 1 }, -- Combat Healing Potion
	[18841] = { 0, 929, nil, nil, 41, 250, 20, 1 }, -- Combat Mana Potion
	[40077] = { 3100, 4200, nil, 400, 70, 2500, 20, 0 }, -- Crazy Alchemist's Potion
	[33934] = { 1500, 0, nil, nil, 55, 0, 20, 1 }, -- Crystal Healing Potion
	[33935] = { 0, 1800, nil, nil, 55, 0, 20, 1 }, -- Crystal Mana Potion
	[4596] = { 140, 0, nil, nil, 5, 25, 20, 0 }, -- Discolored Healing Potion
	[67415] = { 22500, 9250, { 91, 92, 93, 112, 128, 169, 206, 275, 397, 417, 423, 449, 519 }, nil, 80, 6000, 20, 0 }, -- Draught of War
	[43569] = { 1500, 0, nil, 400, 0, 0, 1, 1 }, -- Endless Healing Potion
	[43570] = { 0, 1800, nil, 400, 0, 0, 1, 1 }, -- Endless Mana Potion
	[80040] = { 40000, 0, nil, 550, 85, 0, 1, 1 }, -- Endless Master Healing Potion
	[1710] = { 493, 0, nil, nil, 21, 125, 20, 0 }, -- Greater Healing Potion
	[6149] = { 0, 705, nil, nil, 31, 300, 20, 0 }, -- Greater Mana Potion
	[929] = { 280, 0, nil, nil, 12, 75, 20, 0 }, -- Healing Potion
	[33092] = { 1500, 0, nil, nil, 55, 5000, 20, 0 }, -- Healing Potion Injector
	[64994] = { 6750, 0, { 244, 245 }, nil, 0, 460, 20, 1 }, -- Hellscream's Reach Healing Potion
	[64993] = { 0, 6750, { 244, 245 }, nil, 0, 0, 20, 1 }, -- Hellscream's Reach Mana Potion
	[40067] = { 0, 1800, nil, nil, 65, 5000, 20, 0 }, -- Icy Mana Potion
	[858] = { 140, 0, nil, nil, 3, 25, 20, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 334, nil, nil, 14, 30, 20, 0 }, -- Lesser Mana Potion
	[34440] = { 1650, 1650, nil, 315, 60, 7000, 20, 0 }, -- Mad Alchemist's Potion
	[31838] = { 1050, 0, nil, nil, 61, 0, 20, 1 }, -- Major Combat Healing Potion
	[31839] = { 1050, 0, nil, nil, 61, 0, 20, 1 }, -- Major Combat Healing Potion
	[31852] = { 1050, 0, nil, nil, 61, 0, 20, 1 }, -- Major Combat Healing Potion
	[31853] = { 1050, 0, nil, nil, 61, 1000, 20, 1 }, -- Major Combat Healing Potion
	[31840] = { 0, 1350, nil, nil, 61, 0, 20, 1 }, -- Major Combat Mana Potion
	[31841] = { 0, 1350, nil, nil, 61, 0, 20, 1 }, -- Major Combat Mana Potion
	[31854] = { 0, 1350, nil, nil, 61, 0, 20, 1 }, -- Major Combat Mana Potion
	[31855] = { 0, 1350, nil, nil, 61, 1000, 20, 1 }, -- Major Combat Mana Potion
	[17348] = { 705, 0, { 91, 92, 93, 112, 128, 169, 206, 275, 397, 417, 423, 449, 519 }, nil, 45, 250, 20, 1 }, -- Major Healing Draught
	[13446] = { 1050, 0, nil, nil, 45, 1000, 20, 0 }, -- Major Healing Potion
	[17351] = { 0, 982, { 91, 92, 93, 112, 128, 169, 206, 275, 397, 417, 423, 449, 519 }, nil, 45, 250, 20, 1 }, -- Major Mana Draught
	[13444] = { 0, 1350, nil, nil, 49, 1500, 20, 0 }, -- Major Mana Potion
	[18253] = { 766, 766, nil, nil, 50, 1000, 20, 0 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455, nil, nil, 22, 120, 20, 0 }, -- Mana Potion
	[33093] = { 0, 1800, nil, nil, 55, 5000, 20, 0 }, -- Mana Potion Injector
	[76097] = { 40000, 0, nil, nil, 85, 6000, 20, 0 }, -- Master Healing Potion
	[76098] = { 0, 9500, nil, nil, 85, 6000, 20, 0 }, -- Master Mana Potion
	[57193] = { 9000, 9000, nil, nil, 80, 5000, 20, 0 }, -- Mighty Rejuvenation Potion
	[118] = { 70, 0, nil, nil, 1, 5, 20, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140, nil, nil, 5, 10, 20, 0 }, -- Minor Mana Potion
	[2456] = { 90, 90, nil, nil, 5, 15, 20, 0 }, -- Minor Rejuvenation Potion
	[3087] = { 0, 163, nil, nil, 0, 11, 20, 0 }, -- Mug of Shimmer Stout
	[57191] = { 22500, 0, nil, nil, 80, 6000, 20, 0 }, -- Mythical Healing Potion
	[57192] = { 0, 9250, nil, nil, 80, 6000, 20, 0 }, -- Mythical Mana Potion
	[39327] = { 1500, 0, nil, nil, 55, 0, 20, 1 }, -- Noth's Special Brew
	[40087] = { 2475, 2475, nil, nil, 70, 5000, 20, 0 }, -- Powerful Rejuvenation Potion
	[32784] = { 1050, 0, { 330 }, nil, 70, 460, 20, 1 }, -- Red Ogre Brew
	[32910] = { 1050, 0, { 330 }, nil, 70, 460, 20, 1 }, -- Red Ogre Brew Special
	[39671] = { 1500, 0, nil, nil, 65, 5000, 20, 0 }, -- Resurgent Healing Potion
	[63300] = { 22500, 0, nil, nil, 80, 6000, 20, 1 }, -- Rogue's Draught
	[41166] = { 2700, 0, nil, nil, 70, 3750, 20, 0 }, -- Runic Healing Injector
	[33447] = { 2700, 0, nil, nil, 70, 6000, 20, 0 }, -- Runic Healing Potion
	[42545] = { 0, 4200, nil, nil, 70, 3750, 20, 0 }, -- Runic Mana Injector
	[33448] = { 0, 4200, nil, nil, 70, 6000, 20, 0 }, -- Runic Mana Potion
	[22829] = { 1500, 0, nil, nil, 55, 5000, 20, 0 }, -- Super Healing Potion
	[22832] = { 0, 1800, nil, nil, 55, 5000, 20, 0 }, -- Super Mana Potion
	[22850] = { 2100, 2100, nil, nil, 65, 7000, 20, 0 }, -- Super Rejuvenation Potion
	[17349] = { 564, 0, { 91, 92, 93, 112, 128, 169, 206, 275, 397, 417, 423, 449, 519 }, nil, 35, 125, 20, 1 }, -- Superior Healing Draught
	[3928] = { 861, 0, nil, nil, 35, 250, 20, 0 }, -- Superior Healing Potion
	[17352] = { 0, 644, { 91, 92, 93, 112, 128, 169, 206, 275, 397, 417, 423, 449, 519 }, nil, 35, 125, 20, 1 }, -- Superior Mana Draught
	[13443] = { 0, 929, nil, nil, 41, 400, 20, 0 }, -- Superior Mana Potion
	[28101] = { 0, 1350, nil, nil, 55, 1500, 20, 0 }, -- Unstable Mana Potion
	[28100] = { 1050, 0, nil, nil, 55, 1000, 20, 0 }, -- Volatile Healing Potion
	[9144] = { 759, 759, nil, nil, 35, 250, 20, 0 }, -- Wildvine Potion
}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Every potion this client knows that restores health or mana instantly on the potion cooldown (category 4), read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Health Potion and Mana Potion macros. requiredAlchemy is the Alchemy rank the item requires (the Endless potions and the Alchemist's potions).
	- Healing Amount and Mana Amount are each effect's low end: the effect's value times one minus half its variance. From Cataclysm on the value is scaled, the coefficient times the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel, which is at or below the potion's required level; this reproduces the older clients' numbers (Major Healing Potion 1050, Super Healing Potion 1500). Where SpellLevels gives the spell a lower BaseLevel or MaxLevel, the scaling stops there instead, as the client's tooltips show: Major Healing Draught (21393) and Major Rejuvenation Potion (22729) scale to 45 and 50 but restore level 35's amount. Major Healing Draught carries the client's 705, a point above the tables' 704.
	- Where this client's text states a different low end, the row carries the client's, as Validate Data reported on build 5.5.4.70631: a point off on a few older potions, and a third of the tables' figure on the level-85 potions (Master Healing Potion and Endless Master Healing Potion 40,000, Master Mana Potion 9,500, Alchemist's Rejuvenation 38,000 and 9,500).
	- Allowed Zones are uiMapIDs. The Tol Barad potions carry a required area (244 Tol Barad, 245 Tol Barad Peninsula). The rest come from their text, as on the other clients. The draughts say PvP Battlegrounds: every battleground map this client has (91 Alterac Valley, 92 Warsong Gulch, 93 Arathi Basin, 112 and 397 Eye of the Storm, 128 Strand of the Ancients, 169 Isle of Conquest, 206 Twin Peaks, 275 The Battle for Gilneas, 417 and 449 Temple of Kotmogu, 423 Silvershard Mines, 519 Deepwind Gorge). Draught of War says non-rated battlegrounds and carries the same list: a rated battleground is played on the same maps, and nothing in the data tells the two apart. Bottled Nethergon Energy and Vapor work inside Tempest Keep's four wings, the Cenarion salves inside Coilfang's four.
	- The Ogre Brews say only the Blade's Edge Plateaus, which have no map of their own on this client (Classic's 1949 is gone and 105 is all of Blade's Edge Mountains), so they keep only Gruul's Lair (330), where they also work. Outside it the macro never offers them.
	- Left out: Holy Spring Water (737), an oddball on the potion cooldown, and potions that do something else (rage, speed, protection, invisibility). Items named Deprecated, DEPCREATED or PLACEHOLDER are left out.
	- Every row has a source: a drop, vendor or quest reward in QuestieDB's MoP item table, or a spell that creates it. Left out for having neither: Full Moonshine (1072), Diet McWeaksauce (23578), The McWeaksauce Classic (23579), the first Healing and Mana Potion Injectors (23822, 23823; the 33092 and 33093 copies are kept), Rulkster's Brain Juice and Secret Sauce (32762, 32763), Runic Battle Potion (39971), Argent Healing and Mana Potion (43531, 43530), Jillian's Genius Juice and Savior Sauce (45276, 45277), Mythical Battle Draught (67416), Adrenaline Shot (88416) and Brawler's Healing Potion (92954).

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellScaling?build=5.5.4.70631
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellCastingRequirements?build=5.5.4.70631
	https://wago.tools/db2/AreaGroupMember?build=5.5.4.70631
	https://wago.tools/db2/UiMapAssignment?build=5.5.4.70631
	https://wago.tools/db2/UiMap?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
