local _, ns = ...

-- [ID] = {Buff Food, Food %, Food Amount, Water %, Water Amount, {Allowed Zones} or nil, Arena or nil, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.FOOD_AND_WATER = {
	[19301] = { 0, 0, 4240, 0, 4240, nil, nil, 51, 350, 20, 1 }, -- Alterac Manna Biscuit
	[8932] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Alterac Swiss
	[20062] = { 0, 0, 2065, 0, 4240, { 1461 }, nil, 45, 100, 20, 1 }, -- Arathi Basin Enriched Ration
	[20063] = { 0, 0, 1032, 0, 2117, { 1461 }, nil, 25, 50, 20, 1 }, -- Arathi Basin Field Ration
	[20064] = { 0, 0, 1546, 0, 3178, { 1461 }, nil, 35, 75, 20, 1 }, -- Arathi Basin Iron Ration
	[13935] = { 1, 0, 2065, 0, 0, nil, nil, 45, 10, 20, 0 }, -- Baked Salmon
	[4457] = { 1, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Barbecued Buzzard Wing
	[250067] = { 1, 0, 2065, 0, 0, nil, nil, 45, 10, 20, 0 }, -- Bat Hachee
	[16166] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Bean Soup
	[250074] = { 1, 0, 841, 0, 0, nil, nil, 25, 125, 20, 0 }, -- Bear Brisket
	[250070] = { 1, 0, 2065, 0, 0, nil, nil, 45, 25, 20, 0 }, -- Bear Bruscitti
	[2888] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Beer Basted Boar Ribs
	[18635] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Bellara's Nutterbar
	[3726] = { 1, 0, 234, 0, 0, nil, nil, 5, 125, 20, 0 }, -- Big Bear Steak
	[17404] = { 0, 0, 0, 0, 437, nil, nil, 5, 6, 20, 0 }, -- Blended Bean Brew
	[13810] = { 1, 0, 1858, 0, 0, nil, nil, 45, 300, 20, 1 }, -- Blessed Sunfruit
	-- Blessed Sunfruit Juice (13813) is deliberately absent; its Well Fed buff is still recognized via ns.WELL_FED_BUFF_IDS in Well-Fed-Buffs-Camelot.lua.
	[3220] = { 1, 0, 234, 0, 0, nil, nil, 5, 40, 20, 0 }, -- Blood Sausage
	[13546] = { 0, 0, 1338, 0, 0, nil, nil, 25, 62, 20, 0 }, -- Bloodbelly Fish
	[20516] = { 1, 2, 0, 0, 0, nil, nil, 0, 0, 5, 1 }, -- Bobbing Apple
	[5525] = { 0, 0, 58, 0, 0, nil, nil, 1, 20, 20, 0 }, -- Boiled Clams
	-- Bottled Alterac Spring Water (19318) is deliberately absent; its Well Fed buff is still recognized via ns.WELL_FED_BUFF_IDS in Well-Fed-Buffs-Camelot.lua.
	[1119] = { 0, 0, 530, 0, 0, nil, nil, 0, 50, 10, 0 }, -- Bottled Spirits
	[19300] = { 0, 0, 0, 0, 1915, nil, nil, 35, 100, 20, 0 }, -- Bottled Winterspring Water
	[278119] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Bread with Butter
	[250080] = { 1, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Breakfast Omelette
	[6290] = { 1, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Brilliant Smallfish
	[274971] = { 1, 0, 841, 0, 0, nil, nil, 25, 12, 20, 0 }, -- Briny Seafood Stew
	[4593] = { 1, 0, 530, 0, 0, nil, nil, 15, 4, 20, 0 }, -- Bristle Whisker Catfish
	[9451] = { 0, 0, 0, 0, 835, nil, nil, 15, 25, 20, 0 }, -- Bubbling Water
	[21031] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Cabbage Kimchi
	[11584] = { 1, 0, 58, 0, 0, nil, nil, 0, 1, 20, 0 }, -- Cactus Apple Surprise
	[249874] = { 1, 0, 0, 0, 1344, nil, nil, 25, 1, 20, 0 }, -- Calcified Smoothie
	[260623] = { 0, 0, 841, 0, 0, nil, nil, 25, 62, 20, 0 }, -- Candied Fruit Sampler
	[20390] = { 0, 3, 0, 3, 0, nil, nil, 0, 0, 20, 1 }, -- Candy Bar
	[7807] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Candy Bar
	[17344] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Candy Cane
	[20389] = { 0, 3, 0, 3, 0, nil, nil, 0, 0, 20, 1 }, -- Candy Corn
	[12213] = { 1, 0, 234, 0, 0, nil, nil, 5, 300, 20, 0 }, -- Carrion Surprise
	[278122] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Carrot Salad
	[2679] = { 0, 0, 58, 0, 0, nil, nil, 1, 5, 20, 0 }, -- Charred Wolf Meat
	[7808] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Chocolate Square
	[5526] = { 0, 0, 234, 0, 0, nil, nil, 5, 75, 20, 0 }, -- Clam Chowder
	[250081] = { 0, 0, 2065, 0, 0, nil, nil, 45, 10, 20, 0 }, -- Clam Linguine
	[16971] = { 1, 0, 1338, 0, 0, nil, nil, 40, 300, 20, 0 }, -- Clamlette Surprise
	[8683] = { 0, 0, 28, 0, 0, nil, nil, 1, 1, 20, 1 }, -- Clara's Fresh Apple
	[1113] = { 0, 0, 234, 0, 0, nil, 2, 5, 0, 20, 0 }, -- Conjured Bread
	[22895] = { 0, 0, 3057, 0, 0, nil, 2, 55, 0, 20, 0 }, -- Conjured Cinnamon Roll
	[8079] = { 0, 0, 0, 0, 4038, nil, 2, 55, 0, 20, 0 }, -- Conjured Crystal Water
	[2288] = { 0, 0, 0, 0, 437, nil, 2, 5, 0, 20, 0 }, -- Conjured Fresh Water
	[8077] = { 0, 0, 0, 0, 1915, nil, 2, 35, 0, 20, 0 }, -- Conjured Mineral Water
	-- Mountain Spring Water (231778) is deliberately absent; it is a Season of Discovery item that Validate Data still reports OK on Forever.
	[5349] = { 0, 0, 58, 0, 0, nil, 2, 1, 0, 20, 0 }, -- Conjured Muffin
	[1487] = { 0, 0, 841, 0, 0, nil, 2, 25, 0, 20, 0 }, -- Conjured Pumpernickel
	[2136] = { 0, 0, 0, 0, 835, nil, 2, 15, 0, 20, 0 }, -- Conjured Purified Water
	[1114] = { 0, 0, 530, 0, 0, nil, 2, 15, 0, 20, 0 }, -- Conjured Rye
	[8075] = { 0, 0, 1338, 0, 0, nil, 2, 35, 0, 20, 0 }, -- Conjured Sourdough
	[8078] = { 0, 0, 0, 0, 2821, nil, 2, 45, 0, 20, 0 }, -- Conjured Sparkling Water
	[3772] = { 0, 0, 0, 0, 1344, nil, 2, 25, 0, 20, 0 }, -- Conjured Spring Water
	[8076] = { 0, 0, 2065, 0, 0, nil, 2, 45, 0, 20, 0 }, -- Conjured Sweet Roll
	[5350] = { 0, 0, 0, 0, 151, nil, 2, 1, 0, 20, 0 }, -- Conjured Water
	[2682] = { 1, 0, 58, 0, 0, nil, nil, 1, 25, 20, 0 }, -- Cooked Crab Claw
	[13927] = { 1, 0, 1338, 0, 0, nil, nil, 35, 8, 20, 0 }, -- Cooked Glossy Mightfish
	[2684] = { 1, 0, 234, 0, 0, nil, nil, 5, 20, 20, 0 }, -- Coyote Steak
	[2683] = { 1, 0, 234, 0, 0, nil, nil, 5, 25, 20, 0 }, -- Crab Cake
	[252031] = { 0, 0, 0, 0, 151, nil, nil, 1, 1, 20, 0 }, -- Crisp Spring Water
	[12224] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Crispy Bat Wing
	[5479] = { 1, 0, 234, 0, 0, nil, nil, 5, 125, 20, 0 }, -- Crispy Lizard Tail
	[3664] = { 1, 0, 530, 0, 0, nil, nil, 15, 100, 20, 0 }, -- Crocolisk Gumbo
	[3662] = { 1, 0, 234, 0, 0, nil, nil, 5, 25, 20, 0 }, -- Crocolisk Steak
	[19306] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Crunchy Frog
	[4599] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Cured Ham Steak
	[3665] = { 1, 0, 530, 0, 0, nil, nil, 15, 150, 20, 0 }, -- Curiously Tasty Omelet
	[414] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Dalaran Sharp
	[13888] = { 0, 0, 1338, 0, 0, nil, nil, 45, 12, 20, 0 }, -- Darkclaw Lobster
	[19223] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Darkmoon Dog
	[12238] = { 0, 0, 234, 0, 0, nil, nil, 5, 2, 20, 0 }, -- Darkshore Grouper
	[272055] = { 0, 0, 2065, 0, 4240, { 2524 }, nil, 45, 100, 20, 1 }, -- Darkspear Islands Enriched Ration
	[272053] = { 0, 0, 1032, 0, 2117, { 2524 }, nil, 25, 50, 20, 1 }, -- Darkspear Islands Field Ration
	[272054] = { 0, 0, 1546, 0, 3178, { 2524 }, nil, 35, 75, 20, 1 }, -- Darkspear Islands Iron Ration
	[2070] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Darnassian Bleu
	[21030] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Darnassus Kimchi Pie
	[19225] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Deep Fried Candybar
	[8953] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Deep Fried Plantains
	[17119] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Deeprun Rat Kabob
	[20222] = { 0, 0, 2065, 0, 4240, { 1461 }, nil, 45, 100, 20, 1 }, -- Defiler's Enriched Ration
	[20223] = { 0, 0, 1032, 0, 2117, { 1461 }, nil, 25, 50, 20, 1 }, -- Defiler's Field Ration
	[20224] = { 0, 0, 1546, 0, 3178, { 1461 }, nil, 35, 75, 20, 1 }, -- Defiler's Iron Ration
	[4607] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Delicious Cave Mold
	[5478] = { 0, 0, 530, 0, 0, nil, nil, 15, 70, 20, 0 }, -- Dig Rat Stew
	[21023] = { 1, 0, 2451, 0, 0, nil, nil, 45, 250, 20, 0 }, -- Dirge's Kickin' Chimaerok Chops
	[8948] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Dried King Bolete
	[2687] = { 1, 0, 234, 0, 0, nil, nil, 5, 25, 20, 0 }, -- Dry Pork Ribs
	[422] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Dwarven Mild
	[17198] = { 1, 0, 58, 0, 0, nil, nil, 1, 9, 20, 0 }, -- Egg Nog
	[4791] = { 0, 0, 0, 0, 1344, nil, nil, 25, 133, 20, 0 }, -- Enchanted Water
	[13724] = { 0, 0, 2065, 0, 4240, nil, nil, 45, 300, 20, 0 }, -- Enriched Manna Biscuit
	[20031] = { 0, 0, 2451, 0, 4240, nil, nil, 55, 0, 20, 1 }, -- Essence Mango
	[268912] = { 1, 0, 234, 0, 0, nil, 2, 5, 0, 5, 0 }, -- Expiring Crab Cake
	[268913] = { 1, 0, 234, 0, 0, nil, 2, 5, 0, 5, 0 }, -- Expiring Crocolisk Steak
	[251917] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 1 }, -- Falorne's Homemade Tart
	[21537] = { 0, 4, 0, 4, 0, nil, nil, 0, 0, 20, 1 }, -- Festival Dumplings
	-- Filet o' Flank (238638) is deliberately absent; it is a Season of Discovery item the Forever client still knows.
	[13930] = { 1, 0, 1338, 0, 0, nil, nil, 35, 5, 20, 0 }, -- Filet of Redgill
	[5476] = { 1, 0, 234, 0, 0, nil, nil, 5, 3, 20, 0 }, -- Fillet of Frenzy
	[3927] = { 0, 0, 1338, 0, 0, nil, nil, 35, 150, 20, 0 }, -- Fine Aged Cheddar
	[5066] = { 0, 0, 234, 0, 0, nil, nil, 5, 21, 10, 0 }, -- Fissure Plant
	[23176] = { 1, 0, 807, 0, 1211, nil, nil, 0, 3, 20, 1 }, -- Fizzy Energy Drink
	[19299] = { 0, 0, 0, 0, 835, nil, nil, 15, 25, 20, 0 }, -- Fizzy Faire Drink
	[250069] = { 1, 0, 2065, 0, 0, nil, nil, 45, 25, 20, 0 }, -- Flank au Poivre
	[5845] = { 0, 0, 530, 0, 0, nil, nil, 15, 0, 10, 4 }, -- Flank of Meat
	[4604] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Forest Mushroom Cap
	[252028] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Fresh Gustberry Bread
	[4541] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Freshly Baked Bread
	[23161] = { 0, 0, 0, 0, 2821, nil, nil, 45, 200, 20, 1 }, -- Freshly-Squeezed Lemonade
	[23160] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 1 }, -- Friendship Bread
	[6807] = { 0, 0, 841, 0, 0, nil, nil, 0, 62, 20, 0 }, -- Frog Leg Stew
	[278120] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Fruit Platter
	[252022] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Galestrider Jerky
	[267474] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Galeswept Forestshroom
	[260625] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Garnished Rice Cake
	[6038] = { 1, 0, 841, 0, 0, nil, nil, 25, 312, 20, 0 }, -- Giant Clam Scorcho
	[250078] = { 1, 0, 841, 0, 0, nil, nil, 25, 18, 20, 0 }, -- Giant Scrambled Eggs
	[17197] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Gingerbread Cookie
	[5527] = { 1, 0, 530, 0, 0, nil, nil, 15, 95, 20, 0 }, -- Goblin Deviled Clams
	[4539] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Goldenbark Apple
	[10841] = { 1, 0, 0, 0, 1344, nil, nil, 25, 85, 20, 0 }, -- Goldthorn Tea
	[3666] = { 1, 0, 530, 0, 0, nil, nil, 15, 100, 20, 0 }, -- Gooey Spider Cake
	[724] = { 1, 0, 234, 0, 0, nil, nil, 5, 25, 20, 0 }, -- Goretusk Liver Pie
	[17407] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Graccu's Homemade Meat Pie
	[21215] = { 0, 5, 0, 5, 0, nil, nil, 40, 0, 20, 1 }, -- Graccu's Mince Meat Fruitcake
	[17405] = { 0, 0, 0, 0, 1344, nil, nil, 25, 50, 20, 0 }, -- Green Garden Tea
	[9681] = { 0, 0, 1338, 0, 0, nil, nil, 35, 50, 20, 0 }, -- Grilled King Crawler Legs
	[13928] = { 1, 0, 2065, 0, 0, nil, nil, 35, 8, 20, 0 }, -- Grilled Squid
	[287974] = { 1, 0, 2065, 0, 0, nil, nil, 1, 8, 20, 1 }, -- Grilled Squid
	[11444] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Grim Guzzler Boar
	[252027] = { 0, 0, 0, 0, 437, nil, nil, 5, 5, 20, 0 }, -- Gustberry Juice
	[252026] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Gustberry Pie
	[278117] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Hard Boiled Eggs
	[19995] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Harvest Boar
	[19696] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Harvest Bread
	[19996] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Harvest Fish
	[19994] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Harvest Fruit
	[19997] = { 0, 0, 0, 2, 0, nil, nil, 0, 0, 20, 1 }, -- Harvest Nectar
	[2287] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Haunch of Meat
	[961] = { 0, 0, 58, 0, 0, nil, nil, 0, 2, 10, 0 }, -- Healing Herb
	[16168] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Heaven Peach
	[20074] = { 1, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Heavy Crocolisk Stew
	[12215] = { 1, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Heavy Kodo Stew
	[6888] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Herb Baked Egg
	[20225] = { 0, 0, 2065, 0, 4240, { 1461 }, nil, 45, 100, 20, 1 }, -- Highlander's Enriched Ration
	[20226] = { 0, 0, 1032, 0, 2117, { 1461 }, nil, 25, 50, 20, 1 }, -- Highlander's Field Ration
	[20227] = { 0, 0, 1546, 0, 3178, { 1461 }, nil, 35, 75, 20, 1 }, -- Highlander's Iron Ration
	[252029] = { 0, 0, 234, 0, 0, nil, nil, 5, 30, 20, 0 }, -- Hippogryph Flank
	[17406] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Holiday Cheesewheel
	[8950] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Homemade Cherry Pie
	[3727] = { 1, 0, 530, 0, 0, nil, nil, 15, 125, 20, 0 }, -- Hot Lion Chops
	[13929] = { 1, 0, 2065, 0, 0, nil, nil, 35, 10, 20, 0 }, -- Hot Smoked Bass
	[13851] = { 1, 0, 841, 0, 0, nil, nil, 25, 312, 20, 0 }, -- Hot Wolf Ribs
	[249796] = { 0, 0, 1338, 0, 0, nil, nil, 45, 150, 20, 0 }, -- Hyjal Berries
	[18300] = { 0, 0, 0, 0, 4038, nil, nil, 55, 200, 20, 0 }, -- Hyjal Nectar
	[1179] = { 0, 0, 0, 0, 437, nil, nil, 5, 6, 20, 0 }, -- Ice Cold Milk
	[12212] = { 1, 0, 1338, 0, 0, nil, nil, 35, 300, 20, 0 }, -- Jungle Stew
	[5472] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Kaldorei Spider Kabob
	[262433] = { 0, 0, 4240, 0, 4240, nil, nil, 0, 200, 20, 1 }, -- Ketharas' Hyjal Stew
	[13893] = { 0, 0, 1338, 0, 0, nil, nil, 45, 15, 20, 0 }, -- Large Raw Mightfish
	[5480] = { 1, 0, 530, 0, 0, nil, nil, 15, 95, 20, 0 }, -- Lean Venison
	[12209] = { 1, 0, 530, 0, 0, nil, nil, 15, 95, 20, 0 }, -- Lean Wolf Steak
	[7097] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Leg Meat
	[248613] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Lightning in a Bottle
	[13933] = { 1, 0, 2065, 0, 0, nil, nil, 45, 14, 20, 0 }, -- Lobster Stew
	[6316] = { 1, 0, 58, 0, 0, nil, nil, 5, 3, 20, 0 }, -- Loch Frenzy Delight
	[20388] = { 0, 3, 0, 3, 0, nil, nil, 0, 0, 20, 1 }, -- Lollipop
	[7806] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Lollipop
	[4592] = { 1, 0, 530, 0, 0, nil, nil, 5, 1, 20, 0 }, -- Longjaw Mud Snapper
	[1205] = { 0, 0, 0, 0, 835, nil, nil, 15, 25, 20, 0 }, -- Melon Juice
	[13934] = { 1, 0, 2065, 0, 0, nil, nil, 45, 18, 20, 0 }, -- Mightfish Steak
	[8364] = { 1, 0, 841, 0, 0, nil, nil, 25, 6, 20, 0 }, -- Mithril Head Trout
	[11415] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Mixed Berries
	[4542] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Moist Cornbread
	[12218] = { 1, 0, 1338, 0, 0, nil, nil, 35, 300, 20, 0 }, -- Monster Omelet
	[4602] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Moon Harvest Pumpkin
	[1645] = { 0, 0, 0, 0, 1915, nil, nil, 35, 100, 20, 0 }, -- Moonberry Juice
	[18632] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Moonbrook Riot Taffy
	[8766] = { 0, 0, 0, 0, 2821, nil, nil, 45, 200, 20, 0 }, -- Morning Glory Dew
	[287964] = { 0, 0, 0, 0, 2821, nil, nil, 1, 200, 20, 1 }, -- Morning Glory Dew
	[249873] = { 1, 0, 0, 0, 835, nil, nil, 15, 1, 20, 0 }, -- Mrrggl Smrrthle
	[4544] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Mulgore Spice Bread
	[3663] = { 1, 0, 58, 0, 0, nil, nil, 1, 125, 20, 0 }, -- Murloc Fin Soup
	[3770] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Mutton Chop
	[12214] = { 1, 0, 530, 0, 0, nil, nil, 15, 300, 20, 0 }, -- Mystery Stew
	[13931] = { 1, 0, 1338, 0, 0, nil, nil, 35, 12, 20, 0 }, -- Nightfin Soup
	[278265] = { 0, 0, 28, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Nutritious Slime Sludge
	[6458] = { 0, 0, 58, 0, 0, nil, nil, 5, 1, 20, 0 }, -- Oil Covered Fish
	[249865] = { 1, 0, 0, 0, 151, nil, nil, 1, 1, 20, 0 }, -- Peace Tea
	[19305] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Pickled Kodo Foot
	[263512] = { 1, 0, 58, 0, 0, nil, nil, 5, 100, 20, 0 }, -- Pincer Bites
	[274976] = { 1, 0, 841, 0, 0, nil, nil, 25, 75, 20, 0 }, -- Plain Ol' Paletusk
	[286152] = { 1, 0, 1338, 0, 0, nil, nil, 35, 8, 20, 0 }, -- Plated Armorfish
	[13932] = { 1, 0, 2065, 0, 0, nil, nil, 35, 12, 20, 0 }, -- Poached Sunscale Salmon
	[250075] = { 1, 0, 2065, 0, 0, nil, nil, 45, 10, 20, 0 }, -- Prehistoric Pulled Raptor
	[260624] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Pristine Peach
	[252030] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Pungent Skycheddar
	[21033] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Radish Kimchi
	[250073] = { 1, 0, 841, 0, 0, nil, nil, 25, 125, 20, 0 }, -- Raging Raptor Ribs
	[5095] = { 1, 0, 58, 0, 0, nil, nil, 5, 3, 20, 0 }, -- Rainbow Fin Albacore
	[250076] = { 1, 0, 1338, 0, 0, nil, nil, 35, 10, 20, 0 }, -- Raptor Rouladen
	[4608] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Raw Black Truffle
	[6291] = { 0, 0, 28, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Raw Brilliant Smallfish
	[6308] = { 0, 0, 234, 0, 0, nil, nil, 15, 2, 20, 0 }, -- Raw Bristle Whisker Catfish
	[13754] = { 0, 0, 841, 0, 0, nil, nil, 35, 6, 20, 0 }, -- Raw Glossy Mightfish
	[21153] = { 0, 0, 545, 0, 848, nil, nil, 30, 125, 20, 0 }, -- Raw Greater Sagefish
	[6317] = { 0, 0, 58, 0, 0, nil, nil, 5, 2, 20, 0 }, -- Raw Loch Frenzy
	[6289] = { 0, 0, 58, 0, 0, nil, nil, 5, 1, 20, 0 }, -- Raw Longjaw Mud Snapper
	[8365] = { 0, 0, 530, 0, 0, nil, nil, 25, 4, 20, 0 }, -- Raw Mithril Head Trout
	[13759] = { 0, 0, 841, 0, 0, nil, nil, 35, 10, 20, 0 }, -- Raw Nightfin Snapper
	[6361] = { 0, 0, 58, 0, 0, nil, nil, 5, 2, 20, 0 }, -- Raw Rainbow Fin Albacore
	[13758] = { 0, 0, 841, 0, 0, nil, nil, 35, 4, 20, 0 }, -- Raw Redgill
	[6362] = { 0, 0, 530, 0, 0, nil, nil, 25, 4, 20, 0 }, -- Raw Rockscale Cod
	[21071] = { 0, 0, 149, 0, 302, nil, nil, 10, 25, 20, 0 }, -- Raw Sagefish
	[6303] = { 0, 0, 28, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Raw Slitherskin Mackerel
	[8959] = { 0, 0, 1338, 0, 0, nil, nil, 45, 160, 20, 0 }, -- Raw Spinefin Halibut
	[4603] = { 0, 0, 841, 0, 0, nil, nil, 35, 4, 20, 0 }, -- Raw Spotted Yellowtail
	[13756] = { 0, 0, 841, 0, 0, nil, nil, 35, 9, 20, 0 }, -- Raw Summer Bass
	[13760] = { 0, 0, 841, 0, 0, nil, nil, 35, 10, 20, 0 }, -- Raw Sunscale Salmon
	[13889] = { 0, 0, 1338, 0, 0, nil, nil, 45, 5, 20, 0 }, -- Raw Whitescale Salmon
	[252032] = { 0, 0, 234, 0, 0, nil, nil, 5, 30, 20, 0 }, -- Red Delicious Stormapple
	[19224] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Red Hot Wings
	[4605] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Red-speckled Mushroom
	[1082] = { 1, 0, 234, 0, 0, nil, nil, 5, 150, 20, 0 }, -- Redridge Goulash
	[23172] = { 0, 4, 0, 4, 0, nil, nil, 0, 0, 20, 1 }, -- Refreshing Red Apple
	[159] = { 0, 0, 0, 0, 151, nil, nil, 1, 1, 20, 0 }, -- Refreshing Spring Water
	[282018] = { 0, 5, 0, 5, 0, nil, nil, 1, 1, 20, 1 }, -- Restorative Bread
	[278118] = { 0, 0, 841, 0, 0, nil, nil, 25, 62, 20, 0 }, -- Rich Broth
	[5057] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Ripe Watermelon
	[12210] = { 1, 0, 530, 0, 0, nil, nil, 15, 300, 20, 0 }, -- Roast Raptor
	[2681] = { 1, 0, 58, 0, 0, nil, nil, 1, 6, 20, 0 }, -- Roasted Boar Meat
	[5474] = { 1, 0, 58, 0, 0, nil, nil, 1, 9, 20, 0 }, -- Roasted Kodo Meat
	[8952] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Roasted Quail
	[287963] = { 0, 0, 2065, 0, 0, nil, nil, 1, 200, 20, 1 }, -- Roasted Quail
	[4594] = { 1, 0, 841, 0, 0, nil, nil, 25, 6, 20, 0 }, -- Rockscale Cod
	[249867] = { 1, 0, 0, 0, 835, nil, nil, 15, 1, 20, 0 }, -- Root Tea
	[249866] = { 1, 0, 0, 0, 437, nil, nil, 5, 1, 20, 0 }, -- Royal Tea
	[18255] = { 0, 0, 1338, 0, 0, nil, nil, 45, 15, 20, 0 }, -- Runn Tum Tuber
	[18254] = { 1, 0, 1338, 0, 0, nil, nil, 35, 18, 20, 0 }, -- Runn Tum Tuber Surprise
	[249870] = { 1, 0, 0, 0, 2821, nil, nil, 45, 1, 20, 0 }, -- Sage's Tea
	[21217] = { 1, 0, 530, 0, 0, nil, nil, 30, 125, 20, 0 }, -- Sagefish Delight
	[1326] = { 0, 0, 234, 0, 0, nil, nil, 0, 10, 20, 0 }, -- Sauteed Sunfish
	[260627] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Savory Shen'dralar Steak
	[250065] = { 1, 0, 1338, 0, 0, nil, nil, 35, 150, 20, 0 }, -- Savory Stag Sliders
	[250068] = { 1, 0, 2065, 0, 0, nil, nil, 45, 6, 20, 0 }, -- Savory Turtle Stew
	[275893] = { 0, 0, 234, 0, 0, nil, nil, 0, 45, 20, 0 }, -- Searing Gourd
	[1017] = { 1, 0, 530, 0, 0, nil, nil, 15, 100, 20, 0 }, -- Seasoned Wolf Kabob
	[3448] = { 0, 0, 282, 0, 282, nil, nil, 0, 6, 20, 0 }, -- Senggin Root
	[16171] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Shinsollo
	[4536] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Shiny Red Apple
	[6299] = { 0, 0, 28, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Sickly Looking Fish
	-- Skullfish Soup (33825) is deliberately absent; an oddity of a buff drink we leave out of the running.
	[263509] = { 1, 0, 58, 0, 0, nil, nil, 5, 100, 20, 0 }, -- Skywall Souffle
	[249872] = { 1, 0, 0, 0, 437, nil, nil, 5, 1, 20, 0 }, -- Slimy Smoothie
	[787] = { 1, 0, 234, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Slitherskin Mackerel
	[4656] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Small Pumpkin
	[6890] = { 1, 0, 58, 0, 0, nil, nil, 1, 6, 20, 0 }, -- Smoked Bear Meat
	[20452] = { 1, 0, 2065, 0, 0, nil, nil, 45, 250, 20, 0 }, -- Smoked Desert Dumplings
	[21072] = { 1, 0, 234, 0, 0, nil, nil, 10, 40, 20, 0 }, -- Smoked Sagefish
	[278121] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Smoked Sausage
	[4538] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Snapvine Watermelon
	[250066] = { 1, 0, 2065, 0, 0, nil, nil, 45, 5, 20, 0 }, -- Soaring Pamplona
	[4601] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Soft Banana Bread
	[3729] = { 1, 0, 530, 0, 0, nil, nil, 15, 300, 20, 0 }, -- Soothing Turtle Bisque
	[11109] = { 0, 0, 28, 0, 0, nil, nil, 1, 6, 1, 0 }, -- Special Chicken Feed
	[19304] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Spiced Beef Jerky
	[12216] = { 1, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Spiced Chili Crab
	[2680] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Spiced Wolf Meat
	[17408] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Spicy Beefstick
	[249875] = { 1, 0, 0, 0, 1915, nil, nil, 35, 1, 20, 0 }, -- Spicy Smoothie
	[17222] = { 1, 0, 1338, 0, 0, nil, nil, 35, 300, 20, 0 }, -- Spider Sausage
	[8957] = { 1, 0, 1338, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Spinefin Halibut
	[4606] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Spongy Morel
	[6887] = { 1, 0, 1338, 0, 0, nil, nil, 35, 5, 20, 0 }, -- Spotted Yellowtail
	[16170] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Steamed Mandu
	[250071] = { 1, 0, 2065, 0, 0, nil, nil, 45, 10, 20, 0 }, -- Steaming Stag Steak
	[1707] = { 0, 0, 841, 0, 0, nil, nil, 25, 62, 20, 0 }, -- Stormwind Brie
	[5477] = { 1, 0, 58, 0, 0, nil, nil, 1, 18, 20, 0 }, -- Strider Stew
	[21552] = { 0, 0, 1338, 0, 0, nil, nil, 35, 5, 20, 0 }, -- Striped Yellowtail
	[260628] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Stuffed Pumpkin
	[18633] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Styleen's Sour Suckerpop
	[2685] = { 1, 0, 530, 0, 0, nil, nil, 15, 75, 20, 0 }, -- Succulent Pork Ribs
	[249869] = { 1, 0, 0, 0, 1915, nil, nil, 35, 1, 20, 0 }, -- Sunny Tea
	[1708] = { 0, 0, 0, 0, 1344, nil, nil, 25, 50, 20, 0 }, -- Sweet Nectar
	[267341] = { 1, 0, 2065, 0, 0, nil, nil, 55, 200, 20, 0 }, -- Sweetpaw Jam
	[250072] = { 1, 0, 2065, 0, 0, nil, nil, 45, 40, 20, 0 }, -- Swiftstrike Steak
	[3728] = { 1, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Tasty Lion Steak
	[250079] = { 1, 0, 58, 0, 0, nil, nil, 1, 10, 20, 0 }, -- Tasty Raptor Bites
	[23175] = { 0, 0, 2123, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Tasty Summer Treat
	[4537] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Tel'Abim Banana
	[18045] = { 1, 0, 1338, 0, 0, nil, nil, 35, 300, 20, 0 }, -- Tender Wolf Steak
	[287973] = { 1, 0, 1338, 0, 0, nil, nil, 1, 300, 20, 1 }, -- Tender Wolf Steak
	[7228] = { 0, 0, 530, 0, 0, nil, nil, 15, 25, 20, 0 }, -- Tigule's Strawberry Ice Cream
	[4540] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Tough Hunk of Bread
	[117] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Tough Jerky
	[249868] = { 1, 0, 0, 0, 1344, nil, nil, 25, 1, 20, 0 }, -- Triage Tea
	[250077] = { 1, 0, 234, 0, 0, nil, nil, 5, 9, 20, 0 }, -- Twice-Spiced Raptor Slice
	[12763] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Un'Goro Etherfruit
	[16766] = { 0, 0, 1338, 0, 0, nil, nil, 35, 100, 20, 0 }, -- Undermine Clam Chowder
	[8543] = { 0, 0, 841, 0, 0, nil, nil, 25, 300, 20, 0 }, -- Underwater Mushroom Cap
	[21238] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- UNUSED ITEM
	[249871] = { 1, 0, 0, 0, 151, nil, nil, 1, 1, 20, 0 }, -- Venomous Smoothie
	[16167] = { 0, 0, 234, 0, 0, nil, nil, 5, 6, 20, 0 }, -- Versicolor Treat
	[285359] = { 0, 0, 0, 0, 2821, nil, nil, 45, 200, 20, 0 }, -- Warm Apple Juice
	[19060] = { 0, 0, 2065, 0, 4240, { 1460 }, nil, 45, 100, 20, 1 }, -- Warsong Gulch Enriched Ration
	[19062] = { 0, 0, 1032, 0, 2117, { 1460 }, nil, 25, 50, 20, 1 }, -- Warsong Gulch Field Ration
	[19061] = { 0, 0, 1546, 0, 3178, { 1460 }, nil, 35, 75, 20, 1 }, -- Warsong Gulch Iron Ration
	[733] = { 1, 0, 234, 0, 0, nil, nil, 5, 100, 20, 0 }, -- Westfall Stew
	[249876] = { 1, 0, 0, 0, 2821, nil, nil, 45, 1, 20, 0 }, -- Wicked Smoothie
	[3771] = { 0, 0, 841, 0, 0, nil, nil, 25, 50, 20, 0 }, -- Wild Hog Shank
	[16169] = { 0, 0, 841, 0, 0, nil, nil, 25, 62, 20, 0 }, -- Wild Ricecake
	[11950] = { 1, 0, 1858, 0, 0, nil, nil, 45, 0, 20, 1 }, -- Windblossom Berries
	[22324] = { 0, 0, 2065, 0, 0, nil, nil, 45, 200, 20, 0 }, -- Winter Kimchi
	[13755] = { 0, 0, 841, 0, 0, nil, nil, 35, 7, 20, 0 }, -- Raw Winter Squid
	[21240] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- UNUSED ITEM
	[21254] = { 1, 2, 0, 0, 0, nil, nil, 0, 0, 5, 1 }, -- Winter Veil Cookie
	[21241] = { 0, 0, 0, 2, 0, nil, nil, 0, 0, 20, 1 }, -- Winter Veil Eggnog
	[21236] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- UNUSED ITEM
	[21235] = { 0, 2, 0, 0, 0, nil, nil, 0, 0, 20, 1 }, -- Winter Veil Roast
	[278569] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Yesterday's Leftovers
	[252023] = { 0, 0, 58, 0, 0, nil, nil, 1, 1, 20, 0 }, -- Zaalanarr Sharp
}

--[[
How We Got the Data

Last Validated
	2026-11-11, WoW Forever 1.60.1.70888

Notes
	- Every food and drink this client knows that restores health or mana while seated, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Food and Water macros and the buff-food choices.
	- Buff Food is 1 when eating gives a Well Fed buff (the text says "well fed", "also increases" or the like). Food % and Water % are percent of health or mana per second (100% over 20 sec is 5). Food Amount and Water Amount are the whole restore over the meal.
	- Allowed Zones are uiMapIDs: 1460 Warsong Gulch, 1461 Arathi Basin and 2524 Darkspear Islands. Each zone-locked ration's text says where it works.
	- Arena (column 7) is a fixed per-item property: 1 = offered only inside a PvP Arena. 2 = a conjured item, so it also works inside an arena. Harvest Bread and Winter Veil Loaf say Conjured Item but carry no arena value, as on TBC, whose client doesn't flag them usable in arenas. Whether an item is actually offered is gated live on IsInInstance() at scan time (ns.CacheItemData and ns.ScanBags); no arena zone IDs are kept.
	- Left out on purpose: Scorpid Surprise (5473) and Green Tea Leaf (1401), oddballs that share the food cooldown, and items that share it but restore nothing (alcohol, Deviate fish, holiday novelties, feasts that place a table).
	- WoW Forever reworked much of the cooked food into Well Fed foods (a Well Fed aura on icon 133943) and changed many amounts. An over-time amount is the per-5-second value times the duration in seconds, divided by 5.2 and rounded down for foods; drinks follow their own text, some divided by 5 and some by 5.2, so a drink's figure comes from the client's text, or from a row sharing its spell.
	- Roasted Quail (287963), Morning Glory Dew (287964), Tender Wolf Steak (287973) and Grilled Squid (287974) are WoW Forever's level-1 copies of the originals, with the same use spells and the originals' values, which Validate Data confirmed on build 1.60.1.70450.
	- Tasty Summer Treat's text says only "It's so good, you'll glow."; its 2123 is the use spell's restore in this client's tables. Lightning in a Bottle restores health only; its spell gives no Well Fed buff.
	- Blessed Sunfruit Juice (13813) and Bottled Alterac Spring Water (19318) are left out; their Well Fed buffs are still recognized through ns.WELL_FED_BUFF_IDS.
	- Skullfish Soup (33825) is left out, an oddity of a buff drink.
	- Deprecated Creeper Cakes (4418) and Scooby Snack (8243) are left out: this client's tables give them a restore, but nothing drops, sells or rewards either one (QuestieDB). Thistle Tea (7676) is left out too; it restores energy, not health or mana.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.
	- Cleansing Stew (252683) is left out though a Cooking recipe in this client's tables makes it (1255241): the item has no ItemSparse row on this build, and the recipe needs 252948, a quest item with neither an ItemSparse row nor a QuestieDB source, so it looks unreleased.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70450
	https://wago.tools/db2/ItemSparse?build=1.60.1.70450
	https://wago.tools/db2/ItemEffect?build=1.60.1.70450
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70450
	https://wago.tools/db2/Spell?build=1.60.1.70450
	https://wago.tools/db2/SpellEffect?build=1.60.1.70450
	https://wago.tools/db2/SpellMisc?build=1.60.1.70450
	https://wago.tools/db2/SpellDuration?build=1.60.1.70450
	https://wago.tools/db2/SpellCastingRequirements?build=1.60.1.70450
	https://wago.tools/db2/AreaGroupMember?build=1.60.1.70450
	https://wago.tools/db2/UiMapAssignment?build=1.60.1.70450
	https://wago.tools/db2/Item?build=1.60.1.70862
	https://wago.tools/db2/ItemSparse?build=1.60.1.70862
	https://wago.tools/db2/ItemEffect?build=1.60.1.70862
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70862
	https://wago.tools/db2/ItemSearchName?build=1.60.1.70862
	https://wago.tools/db2/SpellName?build=1.60.1.70862
	https://wago.tools/db2/SpellEffect?build=1.60.1.70862
	https://wago.tools/db2/SpellMisc?build=1.60.1.70862
	https://wago.tools/db2/SpellDuration?build=1.60.1.70862
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70862
	https://wago.tools/db2/SpellReagents?build=1.60.1.70862

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Forever/foreverItemDB.lua
]]
