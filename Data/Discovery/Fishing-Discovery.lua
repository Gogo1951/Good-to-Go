local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name
ns.FISHING_POLES = {
	[6256] = { 0, 0, 0 }, -- Fishing Pole
	[12225] = { 3, 1, 0 }, -- Blump Family Fishing Pole
	[6365] = { 5, 10, 5 }, -- Strong Fishing Pole
	[6366] = { 15, 50, 15 }, -- Darkwood Fishing Pole
	[6367] = { 20, 100, 25 }, -- Big Iron Fishing Pole
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
	[846] = true, -- Fishing +2
}

-- No food on this client gives a Fishing bonus.
ns.FISHING_FOODS = {}
ns.FISHING_WELL_FED_BUFF_IDS = {}

--[[
How We Got the Data

Last Validated
	2026-11-26, wago.tools, Season of Discovery 1.15.9.70576

Notes
	- What the Fishing Lure macro (Features/Macros-for-Consumables/Macros/Fishing-Lure.lua) puts on and applies, each table ranked by its Fishing Bonus.
	- Season of Discovery shares the Classic Era client, and its tables hold no season item (ID 200000 or more) with a Fishing skill spell, a lure enchant or a Fishing requirement, so these lists match Data/Vanilla/Fishing-Vanilla.lua. A season item the server sends without a client row can't be seen this way.
	- A pole's or gear piece's bonus is its equip spell's Fishing skill value (aura 30, misc 356); this client stores it as EffectBasePoints + 1. Required Fishing is ItemSparse's RequiredSkillRank for skill 356.
	- Spearfisher's Waders are WoW Forever's alone, so this client has no legs row.
	- Worn Fishing Hat (7996, +5 Fishing, level 15) is left out: QuestieDB's Classic table and sodBaseItems name no drop, vendor or quest for it and no spell makes it, so it's likely unobtainable here.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/Item?build=1.15.9.70576
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellItemEnchantment?build=1.15.9.70576
	https://wago.tools/db2/SpellName?build=1.15.9.70576

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicItemDB.lua
	https://raw.githubusercontent.com/Questie/QuestieDB/master/src/corrections/Sod/sodBaseItems.lua
]]
