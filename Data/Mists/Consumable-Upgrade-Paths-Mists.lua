local _, ns = ...

local WATER, MEAT, FISH, BREAD, CHEESE, FRUIT, FUNGUS = 0, 1, 2, 3, 4, 5, 6

-- { kind, diet / group / reagent, tiers = { { minLevel, itemID, rank }, -- Name } }
ns.CONSUMABLE_UPGRADE_CHAINS = {
	{
		kind = "water",
		diet = WATER,
		tiers = {
			{ 1, 159, 1 }, -- Refreshing Spring Water
			{ 5, 1179, 2 }, -- Ice Cold Milk
			{ 15, 1205, 3 }, -- Melon Juice
			{ 25, 1708, 4 }, -- Sweet Nectar
			{ 35, 1645, 5 }, -- Moonberry Juice
			{ 45, 8766, 6 }, -- Morning Glory Dew
			{ 60, 28399, 7 }, -- Filtered Draenic Water
			{ 65, 27860, 8 }, -- Purified Draenic Water
			{ 65, 35954, 9 }, -- Sweetened Goat's Milk
			{ 70, 33444, 10 }, -- Pungent Seal Whey
			{ 75, 33445, 11 }, -- Honeymint Tea
			{ 80, 58256, 12 }, -- Sparkling Oasis Water
			{ 85, 58257, 13 }, -- Highland Spring Water
			{ 85, 74636, 14 }, -- Golden Carp Consomme
		},
	},
	{
		kind = "food",
		diet = MEAT,
		tiers = {
			{ 1, 117, 1 }, -- Tough Jerky
			{ 5, 2287, 2 }, -- Haunch of Meat
			{ 15, 3770, 3 }, -- Mutton Chop
			{ 25, 3771, 4 }, -- Wild Hog Shank
			{ 35, 4599, 5 }, -- Cured Ham Steak
			{ 45, 8952, 6 }, -- Roasted Quail
			{ 55, 27854, 7 }, -- Smoked Talbuk Venison
			{ 65, 29451, 8 }, -- Clefthoof Ribs
			{ 65, 33454, 9 }, -- Salted Venison
			{ 75, 35953, 10 }, -- Mead Basted Caribou
			{ 80, 58268, 11 }, -- Roasted Beef
			{ 85, 58269, 12 }, -- Massive Turkey Leg
		},
	},
	{
		kind = "food",
		diet = FISH,
		tiers = {
			{ 1, 787, 1 }, -- Slitherskin Mackerel
			{ 5, 4592, 2 }, -- Longjaw Mud Snapper
			{ 15, 4593, 3 }, -- Bristle Whisker Catfish
			{ 25, 4594, 4 }, -- Rockscale Cod
			{ 35, 21552, 5 }, -- Striped Yellowtail
			{ 45, 8957, 6 }, -- Spinefin Halibut
			{ 55, 27858, 7 }, -- Sunspring Carp
			{ 65, 29452, 8 }, -- Zangar Trout
			{ 65, 33451, 9 }, -- Fillet of Icefin
			{ 75, 35951, 10 }, -- Poached Emperor Salmon
			{ 80, 58262, 11 }, -- Sliced Raw Billfish
			{ 85, 58263, 12 }, -- Grilled Shark
		},
	},
	{
		kind = "food",
		diet = BREAD,
		tiers = {
			{ 1, 4540, 1 }, -- Tough Hunk of Bread
			{ 5, 4541, 2 }, -- Freshly Baked Bread
			{ 15, 4542, 3 }, -- Moist Cornbread
			{ 25, 4544, 4 }, -- Mulgore Spice Bread
			{ 35, 4601, 5 }, -- Soft Banana Bread
			{ 45, 8950, 6 }, -- Homemade Cherry Pie
			{ 55, 27855, 7 }, -- Mag'har Grainbread
			{ 65, 29449, 8 }, -- Bladespire Bagel
			{ 65, 33449, 9 }, -- Crusty Flatbread
			{ 75, 35950, 10 }, -- Sweet Potato Bread
			{ 80, 58260, 11 }, -- Pine Nut Bread
			{ 85, 58261, 12 }, -- Buttery Wheat Roll
			{ 90, 82451, 13 }, -- Frybread
		},
	},
	{
		kind = "food",
		diet = CHEESE,
		tiers = {
			{ 1, 2070, 1 }, -- Darnassian Bleu
			{ 5, 414, 2 }, -- Dalaran Sharp
			{ 15, 422, 3 }, -- Dwarven Mild
			{ 25, 1707, 4 }, -- Stormwind Brie
			{ 35, 3927, 5 }, -- Fine Aged Cheddar
			{ 45, 8932, 6 }, -- Alterac Swiss
			{ 55, 27857, 7 }, -- Garadar Sharp
			{ 65, 29448, 8 }, -- Mag'har Mild Cheese
			{ 65, 33443, 9 }, -- Sour Goat Cheese
			{ 75, 35952, 10 }, -- Briny Hardcheese
			{ 80, 58258, 11 }, -- Smoked String Cheese
			{ 85, 58259, 12 }, -- Highland Sheep Cheese
		},
	},
	{
		kind = "food",
		diet = FRUIT,
		tiers = {
			{ 1, 4536, 1 }, -- Shiny Red Apple
			{ 5, 4537, 2 }, -- Tel'Abim Banana
			{ 15, 4538, 3 }, -- Snapvine Watermelon
			{ 25, 4539, 4 }, -- Goldenbark Apple
			{ 35, 4602, 5 }, -- Moon Harvest Pumpkin
			{ 45, 8953, 6 }, -- Deep Fried Plantains
			{ 55, 27856, 7 }, -- Skethyl Berries
			{ 65, 29450, 8 }, -- Telaari Grapes
			{ 65, 35949, 9 }, -- Tundra Berries
			{ 75, 35948, 10 }, -- Savory Snowplum
			{ 80, 58264, 11 }, -- Sour Green Apple
			{ 85, 58265, 12 }, -- Highland Pomegranate
		},
	},
	{
		kind = "food",
		diet = FUNGUS,
		tiers = {
			{ 1, 4604, 1 }, -- Forest Mushroom Cap
			{ 5, 4605, 2 }, -- Red-Speckled Mushroom
			{ 15, 4606, 3 }, -- Spongy Morel
			{ 25, 4607, 4 }, -- Delicious Cave Mold
			{ 35, 4608, 5 }, -- Raw Black Truffle
			{ 45, 8948, 6 }, -- Dried King Bolete
			{ 55, 27859, 7 }, -- Zangar Caps
			{ 65, 29453, 8 }, -- Sporeggar Mushroom
			{ 65, 33452, 9 }, -- Honey-Spiced Lichen
			{ 75, 35947, 10 }, -- Sparkling Frostcap
			{ 80, 58266, 11 }, -- Violet Morel
			{ 85, 58267, 12 }, -- Scarlet Polypore
		},
	},

	{
		kind = "arrow",
		tiers = {},
	},
	{
		kind = "bullet",
		tiers = {},
	},

	{
		kind = "poison",
		group = 1,
		tiers = {},
	},
	{
		kind = "poison",
		group = 2,
		tiers = {},
	},
	{
		kind = "poison",
		group = 3,
		tiers = {},
	},
	{
		kind = "poison",
		group = 4,
		tiers = {},
	},
	{
		kind = "poison",
		group = 5,
		tiers = {},
	},
	{
		kind = "poison",
		group = 6,
		tiers = {},
	},

	{
		kind = "reagent",
		reagent = "hearthstone",
		tiers = {
			{ 1, 6948, 1 }, -- Hearthstone
		},
	},
	{
		kind = "reagent",
		reagent = "corpse-dust",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "wilds",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "seeds",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "arcane-powder",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "light-feather",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "rune-of-teleportation",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "rune-of-portals",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "symbol-of-divinity",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "symbol-of-kings",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "candles",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "thieves-tools",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "flash-powder",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "blinding-powder",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "ankh",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "fish-scales",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "fish-oil",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "earth-totem",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "fire-totem",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "water-totem",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "air-totem",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "demonic-figurine",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "infernal-stone",
		tiers = {},
	},
	{
		kind = "reagent",
		reagent = "soul-shard",
		tiers = {},
	},

	{
		kind = "healing-potion",
		tiers = {
			{ 1, 118, 1 }, -- Minor Healing Potion
			{ 3, 858, 2 }, -- Lesser Healing Potion
			{ 12, 929, 3 }, -- Healing Potion
			{ 21, 1710, 4 }, -- Greater Healing Potion
			{ 35, 3928, 5 }, -- Superior Healing Potion
			{ 45, 13446, 6 }, -- Major Healing Potion
			{ 55, 22829, 7 }, -- Super Healing Potion
			{ 70, 33447, 8 }, -- Runic Healing Potion
			{ 80, 57191, 9 }, -- Mythical Healing Potion
			{ 85, 76097, 10 }, -- Master Healing Potion
		},
	},
	{
		kind = "mana-potion",
		tiers = {
			{ 5, 2455, 1 }, -- Minor Mana Potion
			{ 14, 3385, 2 }, -- Lesser Mana Potion
			{ 22, 3827, 3 }, -- Mana Potion
			{ 31, 6149, 4 }, -- Greater Mana Potion
			{ 41, 13443, 5 }, -- Superior Mana Potion
			{ 49, 13444, 6 }, -- Major Mana Potion
			{ 55, 22832, 7 }, -- Super Mana Potion
			{ 70, 33448, 8 }, -- Runic Mana Potion
			{ 80, 57192, 9 }, -- Mythical Mana Potion
			{ 85, 76098, 10 }, -- Master Mana Potion
		},
	},
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The staple ladders, read by Features/Restocker/Restocker-Upgrade.lua and the Starter List (Restocker-Starter-List.lua). Same chains, keys and row format as the other clients; see Consumable-Upgrade-Paths-TBC.lua for why this is a table of its own.
	- Each tier is { minLevel, itemID, rank }. minLevel is the item's required level on this client (from Cataclysm on a food's required level equals its item level). rank follows minLevel; where two tiers share a level, the newer item carries the higher rank, so the upgrader moves an older item onto it.
	- Food and water: the TBC tiers carry over unchanged (same IDs, names and required levels on this client; Red-speckled Mushroom is now spelled Red-Speckled Mushroom). Added from Wrath on, each the plain food or drink at that level sold by the most vendors in QuestieDB's MoP item table, with a buy price on this client: the Northrend level-65 staples beside the TBC ones (Salted Venison, Fillet of Icefin, Crusty Flatbread, Sour Goat Cheese, Tundra Berries, Honey-Spiced Lichen, Sweetened Goat's Milk), Pungent Seal Whey at 70, the level-75 Northrend staples and Honeymint Tea, the Cataclysm level-80 and level-85 staples, and Golden Carp Consomme (85) and Frybread (90) from Pandaria. Fresh Water and Hardtack (Cataclysm, level 75) lose to Honeymint Tea and Sweet Potato Bread on vendor count.
	- Pandaria's other vendor food and drink (81400-81414, Pounded Rice Cake to Pearl Milk Tea, Roasted Barley Tea among them, the two alcoholic drinks aside) give a Well Fed buff, so they aren't staples, and no other diet gets a level-90 tier.
	- Not checked: stock limits and extended costs. QuestieDB records who sells an item, not how, so a tier could be a limited-stock line on some vendors. The diet of the post-TBC tiers comes from the item's name (Massive Turkey Leg is meat, Scarlet Polypore is fungus), since this client's tables carry no FoodType; diet here only says which Starter List row a ladder serves.
	- Arrows and bullets: empty. Cataclysm removed ammo; every arrow and bullet the other clients list is a junk item (class 15) on this client.
	- Poisons: every chain empty. From Mists of Pandaria on rogue poisons are spells, and the old poison items are renamed Empty Poison Vial. This matches ns.POISON_DATA in Poisons-Mists.lua, which is empty.
	- Class reagents: every chain empty except the Hearthstone. No spell a class learns on this client (SkillLineAbility) uses any of the reagents in SpellReagents or SpellTotems: Rebirth, Levitate, Slow Fall, the mage teleports, Pick Lock, Summon Infernal and the warlock summons all cast without them. The only rows naming them are NPC or crafting spells.
	- The potion ladders extend the TBC ones with Runic (70), Mythical (80) and Master (85) Healing and Mana Potions; ns.POTIONS (Potions-Mists.lua) confirms the order (healing 70/140/279/493/861/1050/1500/2700/22500/120000, mana 140/333/455/704/928/1350/1800/4200/9250/28500). Like the other clients' potions, these have little or no vendor stock, so their Buy toggle often has nothing to buy.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/SpellReagents?build=5.5.4.70631
	https://wago.tools/db2/SpellTotems?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
