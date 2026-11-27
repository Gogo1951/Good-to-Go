local _, ns = ...

-- [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name
ns.FISHING_POLES = {
	[6256] = { 0, 0, 0 }, -- Fishing Pole
	[12225] = { 3, 1, 0 }, -- Blump Family Fishing Pole
	[6365] = { 5, 10, 5 }, -- Strong Fishing Pole
	[285094] = { 15, 50, 20 }, -- Ravaged Fishing Pole
	[6367] = { 20, 100, 25 }, -- Big Iron Fishing Pole
	[19022] = { 25, 100, 0 }, -- Nat Pagle's Extreme Angler FC-5000
	[19970] = { 35, 300, 0 }, -- Arcanite Fishing Pole
}

-- [ID] = {Fishing Bonus, Required Fishing}, -- Name
ns.FISHING_LURES = {
	[6529] = { 25, 0 }, -- Shiny Bauble
	[268880] = { 25, 0 }, -- "Secret" Bait
	[6530] = { 50, 50 }, -- Nightcrawlers
	[6811] = { 50, 50 }, -- Aquadynamic Fish Lens
	[291005] = { 60, 50 }, -- Camper's Lure
	[6532] = { 75, 100 }, -- Bright Baubles
	[7307] = { 75, 100 }, -- Flesh Eating Worm
	[6533] = { 100, 100 }, -- Aquadynamic Fish Attractor
}

-- [slot] = { [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name }
ns.FISHING_GEAR = {
	legs = {
		[287031] = { 8, 0, 53 }, -- Spearfisher's Waders
	},
	head = {
		[19972] = { 5, 1, 0 }, -- Lucky Fishing Hat
	},
	feet = {
		[19969] = { 5, 1, 0 }, -- Nat Pagle's Extreme Anglin' Boots
	},
}

-- [enchantID] = true, -- Name
ns.FISHING_GLOVE_ENCHANT_IDS = {
	[846] = true, -- Fishing +2
}

-- [ID] = {Fishing Bonus, Required Level}, -- Name
ns.FISHING_FOODS = {
	[6316] = { 3, 5 }, -- Loch Frenzy Delight
	[5476] = { 5, 5 }, -- Fillet of Frenzy
	[4593] = { 8, 15 }, -- Bristle Whisker Catfish
	[4594] = { 12, 25 }, -- Rockscale Cod
	[13930] = { 18, 35 }, -- Filet of Redgill
	[8957] = { 18, 45 }, -- Spinefin Halibut
}

-- [buffID] = true, -- Name
ns.FISHING_WELL_FED_BUFF_IDS = {
	[1249521] = true, -- Well Fed
}

--[[
How We Got the Data

Last Validated
	2026-11-26, wago.tools, WoW Forever 1.60.1.71139

Notes
	- What the Fishing Lure macro (Features/Macros-for-Consumables/Macros/Fishing-Lure.lua) puts on, eats and applies, each table ranked by its Fishing Bonus.
	- Poles and gear on this client carry their Fishing bonus as item stat 117 in ItemSparse, stored as a budget share rather than a number, so every pole's and gear piece's bonus is read from its Wowhead Forever tooltip. Required Fishing and Required Level are ItemSparse's, except where noted.
	- Ravaged Fishing Pole (285094) and Spearfisher's Waders (287031) have an Item row but no ItemSparse row on 71139, so their name, bonus and requirements are from Wowhead. Darkwood Fishing Pole (6366) is gone on this client (no ItemSparse row; Wowhead Forever doesn't know it).
	- Lures are the items whose use spell puts a temporary enchant (SpellEffect 54) on the weapon carrying a Fishing skill spell (aura 30, misc 356). Camper's Lure and "Secret" Bait are this client's own. Wide-Brimmed Fishing Hat (259846) is left out: its lure works only while the hat is worn.
	- Shiny Silver Coin (286732) is left out: it buffs the player (+30 Fishing), not the pole.
	- Worn Fishing Hat (7996, level 15) is left out: its only source is quest 8226 (Rare Fish - Pale Ghoulfish), which has no quest giver on Wowhead and isn't in QuestieDB, so it's unobtainable here.
	- Nat Pagle's Extreme Angler FC-5000 binds on pickup and comes only from Snapjaws, Mon! (7815), a Horde quest (QuestieDB required races 178), so only Horde characters carry it.
	- The glove enchant is what Enchant Gloves - Fishing (13620) puts on. Enchant 2603 (the Eternium line) goes on the pole, not the gloves.
	- Fishing foods are the foods whose Well Fed carries a Fishing skill bonus. All six give the one aura, 1249521 (aura 30, misc 356, icon 133943), triggered by each food's own "Nutritious Food" spell, whose base points set the amount. Required Level is ItemSparse's. Food spell 1249517 (+25) has no item on this build, so no row.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	https://nether.wowhead.com/forever/tooltip/item/285094
	https://nether.wowhead.com/forever/tooltip/item/287031
	https://nether.wowhead.com/forever/tooltip/item/19022
	https://nether.wowhead.com/forever/tooltip/item/19972
	https://nether.wowhead.com/forever/tooltip/item/19969
	https://www.wowhead.com/forever/guide/professions/fishing/overview-leveling

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.71139
	https://wago.tools/db2/ItemSparse?build=1.60.1.71139
	https://wago.tools/db2/ItemEffect?build=1.60.1.71139
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.71139
	https://wago.tools/db2/SpellEffect?build=1.60.1.71139
	https://wago.tools/db2/SpellItemEnchantment?build=1.60.1.71139
	https://wago.tools/db2/SpellName?build=1.60.1.71139
	https://wago.tools/db2/SpellMisc?build=1.60.1.71139

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicItemDB.lua
]]
