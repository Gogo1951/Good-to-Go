local _, ns = ...

-- [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name
ns.FISHING_POLES = {
	[6256] = { 0, 0, 0 }, -- Fishing Pole
	[12225] = { 3, 1, 0 }, -- Blump Family Fishing Pole
	[6365] = { 5, 10, 5 }, -- Strong Fishing Pole
	[6366] = { 15, 50, 15 }, -- Darkwood Fishing Pole
	[6367] = { 20, 100, 25 }, -- Big Iron Fishing Pole
	[25978] = { 20, 200, 0 }, -- Seth's Graphite Fishing Pole
	[19022] = { 25, 100, 0 }, -- Nat Pagle's Extreme Angler FC-5000
	[19970] = { 35, 300, 0 }, -- Arcanite Fishing Pole
}

-- [ID] = {Fishing Bonus, Required Fishing}, -- Name
ns.FISHING_LURES = {
	[6529] = { 25, 0 }, -- Shiny Bauble
	[6530] = { 50, 50 }, -- Nightcrawlers
	[6811] = { 50, 50 }, -- Aquadynamic Fish Lens
	[6532] = { 75, 100 }, -- Bright Baubles
	[7307] = { 75, 100 }, -- Flesh Eating Worm
	[6533] = { 100, 100 }, -- Aquadynamic Fish Attractor
	[34861] = { 100, 100 }, -- Sharpened Fish Hook
}

-- [slot] = { [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name }
ns.FISHING_GEAR = {
	head = {
		[19972] = { 5, 1, 0 }, -- Lucky Fishing Hat
	},
	feet = {
		[19969] = { 5, 1, 0 }, -- Nat Pagle's Extreme Anglin' Boots
	},
}

-- [enchantID] = true, -- Name
ns.FISHING_GLOVE_ENCHANT_IDS = {
	[846] = true, -- +2 Fishing
}

-- No food on this client gives a Fishing bonus.
ns.FISHING_FOODS = {}
ns.FISHING_WELL_FED_BUFF_IDS = {}

--[[
How We Got the Data

Last Validated
	2026-11-26, wago.tools, TBC Anniversary 2.5.6.70577

Notes
	- What the Fishing Lure macro (Features/Macros-for-Consumables/Macros/Fishing-Lure.lua) puts on and applies, each table ranked by its Fishing Bonus.
	- A pole's or gear piece's bonus is its equip spell's Fishing skill value (aura 30, misc 356); this client stores it as EffectBasePoints + 1. Required Fishing is ItemSparse's RequiredSkillRank for skill 356.
	- Lures are the items whose use spell puts a temporary enchant (SpellEffect 54) on the weapon carrying a Fishing skill spell. Left out: Ninja Hook [PH] (35713, a placeholder), QAEnchant Gloves +5 Fishing (23727, a QA item), Weather-Beaten Fishing Hat (33820, whose lure works only while worn), and the permanent lines (19971, 34836).
	- Captain Rumsey's Lager (34832) buffs the player (+10 Fishing), not the pole, and isn't Well Fed, so no row.
	- Spearfisher's Waders are WoW Forever's alone, so this client has no legs row.
	- Worn Fishing Hat (7996, +5 Fishing, level 15) and Weather-Beaten Fishing Hat (33820, +5 Fishing) are left out of the gear: QuestieDB's TBC table names no drop, vendor or quest for either and no spell makes them, so they're likely unobtainable here.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=2.5.6.70577
	https://wago.tools/db2/Item?build=2.5.6.70577
	https://wago.tools/db2/ItemEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellItemEnchantment?build=2.5.6.70577
	https://wago.tools/db2/SpellName?build=2.5.6.70577

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcItemDB.lua
]]
