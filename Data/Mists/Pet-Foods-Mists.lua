local _, ns = ...

-- [itemID] = { itemLevel, dietID, sellPrice, questIDs or nil }, -- Name
ns.PET_FOOD_DATA = {
	-- Meat
	[117] = { 1, 1, 1, nil }, -- Tough Jerky
	[2679] = { 1, 1, 5, nil }, -- Charred Wolf Meat
	[2681] = { 1, 1, 6, nil }, -- Roasted Boar Meat
	[4739] = { 1, 1, 0, { 747 } }, -- Plainstrider Meat
	[5051] = { 1, 1, 1, { 862 } }, -- Dig Rat
	[7097] = { 1, 1, 1, nil }, -- Leg Meat
	[19223] = { 1, 1, 1, nil }, -- Darkmoon Dog
	[23495] = { 1, 1, 0, nil }, -- Springpaw Appetizer
	[23676] = { 1, 1, 5, { 9454 } }, -- Moongraze Stag Tenderloin
	[769] = { 5, 1, 3, { 317 } }, -- Chunk of Boar Meat
	[2287] = { 5, 1, 6, nil }, -- Haunch of Meat
	[2672] = { 5, 1, 4, nil }, -- Stringy Wolf Meat
	[2886] = { 5, 1, 5, nil }, -- Crag Boar Rib
	[5465] = { 5, 1, 3, { 4161 } }, -- Small Spider Leg
	[6890] = { 5, 1, 6, nil }, -- Smoked Bear Meat
	[12223] = { 5, 1, 4, nil }, -- Meaty Bat Wing
	[17119] = { 5, 1, 6, nil }, -- Deeprun Rat Kabob
	[19304] = { 5, 1, 6, nil }, -- Spiced Beef Jerky
	[27668] = { 5, 1, 5, nil }, -- Lynx Meat
	[27669] = { 5, 1, 5, nil }, -- Bat Flesh
	[729] = { 10, 1, 17, nil }, -- Stringy Vulture Meat
	[2673] = { 10, 1, 10, nil }, -- Coyote Meat
	[5467] = { 10, 1, 7, nil }, -- Kodo Meat
	[5469] = { 10, 1, 9, { 2178 } }, -- Strider Meat
	[3173] = { 11, 1, 15, { 418 } }, -- Bear Meat
	[723] = { 12, 1, 15, { 22 } }, -- Goretusk Liver
	[731] = { 12, 1, 27, nil }, -- Goretusk Snout
	[2677] = { 14, 1, 15, nil }, -- Boar Ribs
	[2924] = { 14, 1, 16, { 385 } }, -- Crocolisk Meat
	[733] = { 15, 1, 100, nil }, -- Westfall Stew
	[1081] = { 15, 1, 50, { 92 } }, -- Crisp Spider Meat
	[2685] = { 15, 1, 75, nil }, -- Succulent Pork Ribs
	[3770] = { 15, 1, 25, nil }, -- Mutton Chop
	[5478] = { 15, 1, 70, nil }, -- Dig Rat Stew
	[19305] = { 15, 1, 25, nil }, -- Pickled Kodo Foot
	[22644] = { 15, 1, 12, { 9171 } }, -- Crunchy Spider Leg
	[1015] = { 19, 1, 24, { 90 } }, -- Lean Wolf Flank
	[3730] = { 21, 1, 45, nil }, -- Big Bear Meat
	[5470] = { 22, 1, 28, nil }, -- Thunder Lizard Tail
	[3667] = { 23, 1, 25, nil }, -- Tender Crocolisk Meat
	[3731] = { 23, 1, 55, nil }, -- Lion Meat
	[5471] = { 23, 1, 30, nil }, -- Stag Meat
	[3771] = { 25, 1, 50, nil }, -- Wild Hog Shank
	[19224] = { 25, 1, 50, nil }, -- Red Hot Wings
	[3712] = { 30, 1, 87, nil }, -- Turtle Meat
	[12037] = { 30, 1, 87, nil }, -- Mystery Meat
	[12184] = { 30, 1, 87, nil }, -- Raptor Flesh
	[12202] = { 30, 1, 87, nil }, -- Tiger Meat
	[12203] = { 30, 1, 87, nil }, -- Red Wolf Meat
	[3404] = { 35, 1, 181, { 703 } }, -- Buzzard Wing
	[4599] = { 35, 1, 100, nil }, -- Cured Ham Steak
	[9681] = { 35, 1, 50, nil }, -- Grilled King Crawler Legs
	[12204] = { 35, 1, 112, nil }, -- Heavy Kodo Meat
	[19306] = { 35, 1, 100, nil }, -- Crunchy Frog
	[12205] = { 40, 1, 112, nil }, -- White Spider Meat
	[12208] = { 40, 1, 150, nil }, -- Tender Wolf Meat
	[8952] = { 45, 1, 200, nil }, -- Roasted Quail
	[11444] = { 45, 1, 200, nil }, -- Grim Guzzler Boar
	[20424] = { 55, 1, 175, nil }, -- Sandworm Meat
	[27854] = { 55, 1, 280, nil }, -- Smoked Talbuk Venison
	[30610] = { 55, 1, 280, nil }, -- Smoked Black Bear Meat
	[27671] = { 60, 1, 200, nil }, -- Buzzard Meat
	[27674] = { 60, 1, 200, nil }, -- Ravager Flesh
	[27677] = { 60, 1, 200, nil }, -- Chunk o' Basilisk
	[27678] = { 60, 1, 200, nil }, -- Clefthoof Meat
	[27681] = { 60, 1, 200, nil }, -- Warped Flesh
	[27682] = { 60, 1, 200, nil }, -- Talbuk Venison
	[29451] = { 65, 1, 400, nil }, -- Clefthoof Ribs
	-- Fish
	[787] = { 1, 2, 1, nil }, -- Slitherskin Mackerel
	[6290] = { 1, 2, 1, nil }, -- Brilliant Smallfish
	[15924] = { 1, 2, 0, { 6142 } }, -- Soft-Shelled Clam Meat
	[1326] = { 5, 2, 10, nil }, -- Sauteed Sunfish
	[2682] = { 5, 2, 25, nil }, -- Cooked Crab Claw
	[4592] = { 5, 2, 1, nil }, -- Longjaw Mud Snapper
	[5095] = { 5, 2, 3, { 8524, 8525 } }, -- Rainbow Fin Albacore
	[6291] = { 5, 2, 1, nil }, -- Raw Brilliant Smallfish
	[6303] = { 5, 2, 1, nil }, -- Raw Slitherskin Mackerel
	[6316] = { 5, 2, 3, nil }, -- Loch Frenzy Delight
	[2675] = { 13, 2, 11, nil }, -- Crawler Claw
	[5503] = { 14, 2, 16, nil }, -- Clam Meat
	[4593] = { 15, 2, 4, nil }, -- Bristle Whisker Catfish
	[5468] = { 15, 2, 12, nil }, -- Soft Frenzy Flesh
	[5526] = { 15, 2, 75, nil }, -- Clam Chowder
	[6289] = { 15, 2, 1, nil }, -- Raw Longjaw Mud Snapper
	[6317] = { 15, 2, 2, nil }, -- Raw Loch Frenzy
	[6361] = { 15, 2, 2, nil }, -- Raw Rainbow Fin Albacore
	[6458] = { 15, 2, 1, nil }, -- Oil Covered Fish
	[21071] = { 20, 2, 25, nil }, -- Raw Sagefish
	[5504] = { 23, 2, 22, nil }, -- Tangy Clam Meat
	[4594] = { 25, 2, 6, nil }, -- Rockscale Cod
	[6308] = { 25, 2, 2, nil }, -- Raw Bristle Whisker Catfish
	[8364] = { 25, 2, 6, nil }, -- Mithril Head Trout
	[4655] = { 35, 2, 71, nil }, -- Giant Clam Meat
	[6362] = { 35, 2, 4, nil }, -- Raw Rockscale Cod
	[6887] = { 35, 2, 5, { 8528, 8529, 8613, 8614 } }, -- Spotted Yellowtail
	[13546] = { 35, 2, 62, { 5386 } }, -- Bloodbelly Fish
	[13930] = { 35, 2, 5, nil }, -- Filet of Redgill
	[16766] = { 35, 2, 100, nil }, -- Undermine Clam Chowder
	[21552] = { 35, 2, 5, nil }, -- Striped Yellowtail
	[12206] = { 40, 2, 112, nil }, -- Tender Crab Meat
	[21153] = { 40, 2, 125, nil }, -- Raw Greater Sagefish
	[4603] = { 45, 2, 4, nil }, -- Raw Spotted Yellowtail
	[7974] = { 45, 2, 50, { 6610 } }, -- Zesty Clam Meat
	[8957] = { 45, 2, 200, nil }, -- Spinefin Halibut
	[13758] = { 45, 2, 4, nil }, -- Raw Redgill
	[13933] = { 45, 2, 14, nil }, -- Lobster Stew
	[13935] = { 45, 2, 10, { 8615, 8616 } }, -- Baked Salmon
	[8959] = { 55, 2, 160, nil }, -- Raw Spinefin Halibut
	[13889] = { 55, 2, 5, nil }, -- Raw Whitescale Salmon
	[27661] = { 55, 2, 150, nil }, -- Blackened Trout
	[27858] = { 55, 2, 280, nil }, -- Sunspring Carp
	[27422] = { 60, 2, 8, nil }, -- Barbed Gill Trout
	[27425] = { 60, 2, 8, nil }, -- Spotted Feltail
	[27429] = { 60, 2, 8, nil }, -- Zangarian Sporefish
	[27435] = { 60, 2, 8, nil }, -- Figluster's Mudfish
	[27437] = { 60, 2, 8, nil }, -- Icefin Bluefish
	[27438] = { 60, 2, 8, nil }, -- Golden Darter
	[27439] = { 60, 2, 8, nil }, -- Furious Crawdad
	[29452] = { 65, 2, 400, nil }, -- Zangar Trout
	[33048] = { 65, 2, 200, nil }, -- Stewed Trout
	[33053] = { 65, 2, 200, nil }, -- Hot Buttered Trout
	-- Bread
	[4540] = { 1, 3, 1, nil }, -- Tough Hunk of Bread
	[5349] = { 1, 3, 0, nil }, -- Conjured Muffin
	[20857] = { 1, 3, 1, nil }, -- Honey Bread
	[30816] = { 1, 3, 5, { 29355, 29357 } }, -- Spice Bread
	[4541] = { 5, 3, 6, nil }, -- Freshly Baked Bread
	[30817] = { 5, 3, 1, { 12177 } }, -- Simple Flour
	[4542] = { 15, 3, 25, nil }, -- Moist Cornbread
	[4544] = { 25, 3, 50, nil }, -- Mulgore Spice Bread
	[16169] = { 25, 3, 62, nil }, -- Wild Ricecake
	[4601] = { 35, 3, 100, nil }, -- Soft Banana Bread
	[23160] = { 45, 3, 200, nil }, -- Friendship Bread
	[27855] = { 55, 3, 280, nil }, -- Mag'har Grainbread
	[28486] = { 55, 3, 280, nil }, -- Moser's Magnificent Muffin
	[29394] = { 65, 3, 400, nil }, -- Lyribread
	[29449] = { 65, 3, 400, nil }, -- Bladespire Bagel
	-- Cheese
	[2070] = { 1, 4, 1, nil }, -- Darnassian Bleu
	[414] = { 5, 4, 6, nil }, -- Dalaran Sharp
	[17406] = { 5, 4, 6, nil }, -- Holiday Cheesewheel
	[422] = { 15, 4, 25, nil }, -- Dwarven Mild
	[1707] = { 25, 4, 62, nil }, -- Stormwind Brie
	[3927] = { 35, 4, 150, { 6610 } }, -- Fine Aged Cheddar
	[8932] = { 45, 4, 200, nil }, -- Alterac Swiss
	[27857] = { 55, 4, 280, nil }, -- Garadar Sharp
	[30458] = { 55, 4, 280, nil }, -- Stromgarde Muenster
	[29448] = { 65, 4, 400, nil }, -- Mag'har Mild Cheese
	-- Fruit
	[4536] = { 1, 5, 1, nil }, -- Shiny Red Apple
	[4656] = { 1, 5, 1, nil }, -- Small Pumpkin
	[4537] = { 5, 5, 6, nil }, -- Tel'Abim Banana
	[24072] = { 5, 5, 6, nil }, -- Sand Pear Pie
	[4538] = { 15, 5, 25, nil }, -- Snapvine Watermelon
	[4539] = { 25, 5, 50, nil }, -- Goldenbark Apple
	[4602] = { 35, 5, 100, nil }, -- Moon Harvest Pumpkin
	[16168] = { 35, 5, 100, nil }, -- Heaven Peach
	[21030] = { 35, 5, 100, nil }, -- Darnassus Kimchi Pie
	[8950] = { 45, 3, 200, nil }, -- Homemade Cherry Pie (bread, diet 3: the database files it as fruit)
	[8953] = { 45, 5, 200, nil }, -- Deep Fried Plantains
	[21031] = { 45, 5, 200, nil }, -- Cabbage Kimchi
	[21033] = { 45, 5, 200, nil }, -- Radish Kimchi
	[27856] = { 55, 5, 280, nil }, -- Skethyl Berries
	[29393] = { 55, 5, 280, nil }, -- Diamond Berries
	[29450] = { 65, 5, 400, nil }, -- Telaari Grapes
	-- Fungus
	[4604] = { 1, 6, 1, nil }, -- Forest Mushroom Cap
	[3448] = { 5, 6, 6, nil }, -- Senggin Root
	[4605] = { 5, 6, 6, nil }, -- Red-Speckled Mushroom
	[4606] = { 15, 6, 25, nil }, -- Spongy Morel
	[4607] = { 25, 6, 50, nil }, -- Delicious Cave Mold
	[4608] = { 35, 6, 100, nil }, -- Raw Black Truffle
	[8948] = { 45, 6, 200, nil }, -- Dried King Bolete
	[27859] = { 55, 6, 280, nil }, -- Zangar Caps
	[29453] = { 65, 6, 400, nil }, -- Sporeggar Mushroom
	-- Underspore Pod (28112) is deliberately absent; it sells for nothing, so Feed Pet would spend it before ordinary food.
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The foods a hunter's pet eats, for Feed Pet support (Features/Macros-for-Consumables/Macros/Tools-Hunters-Pet-Food.lua). Diet IDs follow ns.PET_DIET_MAP in Data/Data.lua: 1 Meat, 2 Fish, 3 Bread, 4 Cheese, 5 Fruit, 6 Fungus. On this client Feed Pet (6991) restores a share of the pet's health; there is no happiness.
	- itemLevel is the client's item level. From Cataclysm on a plain food's item level equals its required level, so most foods sit ten levels lower than on the TBC client (Haunch of Meat 5, not 15). sellPrice is the vendor sell value per unit in copper. questIDs lists the quests in QuestieDB's MoP quest table that take the item as an objective, or nil.
	- This client's tables carry no pet diet, and QuestieDB's MoP item table leaves foodType empty, so nothing here can name a diet for a food the TBC client didn't have. Every row is a TBC row whose item still exists on this client under the same name (ignoring case), still has a source, and keeps the diet the TBC file gives it. Item level, sell price and quests are re-read from this client.
	- Left out for having no source in QuestieDB's MoP tables and no spell that creates them: Darkshore Grouper (12238), Raw Mithril Head Trout (8365), Raw Glossy Mightfish (13754), Winter Squid (13755), Raw Summer Bass (13756), Raw Nightfin Snapper (13759), Raw Sunscale Salmon (13760), Darkclaw Lobster (13888), Large Raw Mightfish (13893), Jaggal Clam Meat (24477), Ripe Watermelon (5057) and the conjured breads from Conjured Bread up (1113, 1114, 1487, 8075, 8076, 22895, 22019). The fish are fishing catches, which QuestieDB doesn't record, so some may still be obtainable.
	- Not added: the Wrath, Cataclysm and Pandaria plain foods (no Well Fed buff, sell for something, no zone limit), for want of a diet. There are 63 of them on this client, from Northern Stew (34747) to Frybread (82451); the full list is in the notes that came with this file. Without them the highest food here is level 65, so the Feed Pet macro's ten-level bracket finds nothing for a pet above level 75.
	- Left out on purpose, as on every client: foods that give the player a Well Fed buff, special foods that sell for nothing, and battleground or zone rations. Feed Pet feeds the cheapest food first, so it would spend those before ordinary food.

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

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopQuestDB.lua
]]
