local _, ns = ...

-- [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name
ns.FISHING_POLES = {
	[6256] = { 0, 0, 0 }, -- Fishing Pole
	[45120] = { 0, 0, 0 }, -- Basic Fishing Pole
	[12225] = { 3, 1, 0 }, -- Blump Family Fishing Pole
	[46337] = { 3, 1, 0 }, -- Staats' Fishing Pole
	[52678] = { 3, 1, 0 }, -- Jonathan's Fishing Pole
	[6365] = { 5, 10, 5 }, -- Strong Fishing Pole
	[84660] = { 10, 0, 0 }, -- Pandaren Fishing Pole
	[6366] = { 15, 50, 15 }, -- Darkwood Fishing Pole
	[6367] = { 20, 100, 25 }, -- Big Iron Fishing Pole
	[19022] = { 20, 100, 0 }, -- Nat Pagle's Extreme Angler FC-5000
	[25978] = { 20, 200, 0 }, -- Seth's Graphite Fishing Pole
	[45858] = { 25, 225, 0 }, -- Nat's Lucky Fishing Pole
	[45991] = { 30, 300, 0 }, -- Bone Fishing Pole
	[45992] = { 30, 300, 0 }, -- Jeweled Fishing Pole
	[44050] = { 30, 300, 80 }, -- Mastercraft Kalu'ak Fishing Pole
	[84661] = { 30, 525, 0 }, -- Dragon Fishing Pole
	[19970] = { 40, 300, 0 }, -- Arcanite Fishing Pole
}

-- [ID] = {Fishing Bonus, Required Fishing}, -- Name
ns.FISHING_LURES = {
	[67404] = { 15, 0 }, -- Glass Fishing Bobber
	[6529] = { 25, 0 }, -- Shiny Bauble
	[6530] = { 50, 50 }, -- Nightcrawlers
	[6811] = { 50, 50 }, -- Aquadynamic Fish Lens
	[6532] = { 75, 100 }, -- Bright Baubles
	[7307] = { 75, 100 }, -- Flesh Eating Worm
	[6533] = { 100, 100 }, -- Aquadynamic Fish Attractor
	[34861] = { 100, 100 }, -- Sharpened Fish Hook
	[62673] = { 100, 100 }, -- Feathered Lure
	[46006] = { 100, 100 }, -- Glow Worm
	[68049] = { 150, 250 }, -- Heat-Treated Spinning Lure
}

-- [slot] = { [ID] = {Fishing Bonus, Required Fishing, Required Level}, -- Name }
ns.FISHING_GEAR = {
	head = {
		[19972] = { 5, 1, 0 }, -- Lucky Fishing Hat
		[7996] = { 5, 1, 15 }, -- Worn Fishing Hat
		[33820] = { 5, 0, 0 }, -- Weather-Beaten Fishing Hat
		[88710] = { 5, 0, 0 }, -- Nat's Hat
		[93732] = { 5, 0, 0 }, -- Darkmoon Fishing Cap
	},
	feet = {
		[50287] = { 15, 200, 0 }, -- Boots of the Bay
		[19969] = { 5, 1, 35 }, -- Nat Pagle's Extreme Anglin' Boots
	},
}

-- [enchantID] = true, -- Name
ns.FISHING_GLOVE_ENCHANT_IDS = {
	[2603] = true, -- +2 Fishing
	[4732] = true, -- +5 Fishing
}

-- No food on this client gives a Fishing bonus.
ns.FISHING_FOODS = {}
ns.FISHING_WELL_FED_BUFF_IDS = {}

--[[
How We Got the Data

Last Validated
	2026-11-27, wago.tools, Mists of Pandaria Classic 5.5.4.71089

Notes
	- What the Fishing Lure macro (Features/Macros-for-Consumables/Macros/Fishing-Lure.lua) puts on and applies, each table ranked by its Fishing Bonus.
	- A pole's or gear piece's bonus is its equip spell's Fishing skill value (aura 30, misc 356). Required Fishing is ItemSparse's RequiredSkillRank for skill 356. On this client Nat Pagle's Extreme Angler FC-5000 gives +20 and Arcanite Fishing Pole +40, as Wowhead's MoP Classic tooltips agree. Crafty's Pole (43651, +1000) is a developer item and left out.
	- Lures are the items whose use spell puts a temporary enchant (SpellEffect 54) on the weapon carrying a Fishing skill spell. Left out: Corpse Worm (69907, a quest item), Ninja Hook [PH] (35713), the Ancient Pandaren Fishing Charm (85973, a toy with no skill bonus), the hat lures that work only while worn (33820, 88710), and Reinforced Fishing Line (68796, permanent).
	- The glove enchants differ from the older clients: Enchant Gloves - Fishing (13620) puts on 2603 and Enchant Gloves - Angler (71692) puts on 4732. Here 846 is High Test Eternium Fishing Line's pole enchant.
	- Spearfisher's Waders are WoW Forever's alone, so this client has no legs row.
	- Gear rows are the hats and boots with a Fishing equip bonus that QuestieDB's MoP table gives a source: Lucky Fishing Hat and Nat Pagle's boots (quests), Worn Fishing Hat (quest 8226), Weather-Beaten Fishing Hat (drops), Nat's Hat (vendor), Boots of the Bay (quest 24803). Darkmoon Fishing Cap (93732, +5, no requirements) has no source in that table, but Wowhead MoP Classic shows it fished up on Darkmoon Island.
	- Nat Pagle's Extreme Angler FC-5000 is a quest reward for both factions here: Snapjaws, Mon! (26211, Horde) and Snapjaws, Lad! (26485, Alliance).

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	https://nether.wowhead.com/mop-classic/tooltip/item/19022
	https://nether.wowhead.com/mop-classic/tooltip/item/19970
	https://www.wowhead.com/mop-classic/item=93732

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.71089
	https://wago.tools/db2/Item?build=5.5.4.71089
	https://wago.tools/db2/ItemEffect?build=5.5.4.71089
	https://wago.tools/db2/SpellEffect?build=5.5.4.71089
	https://wago.tools/db2/SpellItemEnchantment?build=5.5.4.71089
	https://wago.tools/db2/SpellName?build=5.5.4.71089

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
