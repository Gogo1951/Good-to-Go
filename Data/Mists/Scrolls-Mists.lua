local _, ns = ...

-- [scrollType] = { items = { ... }, conflictSpells = { ... } }
ns.SCROLL_DATA = {
	Agility = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63303, 89343, 80, 100 }, -- Scroll of Agility IX
			{ 43464, 58451, 80, 30 }, -- Scroll of Agility VIII
			{ 43463, 58450, 70, 25 }, -- Scroll of Agility VII
			{ 33457, 43194, 60, 20 }, -- Scroll of Agility VI
			{ 27498, 33077, 50, 15 }, -- Scroll of Agility V
			{ 10309, 12174, 40, 10 }, -- Scroll of Agility IV
			{ 4425, 8117, 30, 8 }, -- Scroll of Agility III
			{ 1477, 8116, 15, 5 }, -- Scroll of Agility II
			{ 3012, 8115, 1, 6 }, -- Scroll of Agility
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105689] = 1000, -- Flask of Spring Blossoms
			[79639] = 320, -- Alchemist's Flask
			[92725] = 300, -- Flask of Battle
			[79471] = 300, -- Flask of the Winds
			[28497] = 45, -- Elixir of Mighty Agility
			[54494] = 30, -- Elixir of Major Agility
			[80532] = 25, -- Elixir of Armor Piercing
			[11334] = 25, -- Elixir of Greater Agility
			[17538] = 25, -- Elixir of the Mongoose
			[10669] = 25, -- Ground Scorpok Assay
			[53749] = 20, -- Guru's Elixir
			[40567] = 20, -- Unstable Flask of the Bandit
			[40572] = 20, -- Unstable Flask of the Beast
			[45373] = 15, -- Bloodberry Elixir
			[11328] = 15, -- Elixir of Agility
			[33726] = 15, -- Elixir of Mastery
			[3160] = 8, -- Elixir of Lesser Agility
			[2374] = 8, -- Elixir of Minor Agility
		},
	},
	Intellect = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63305, 89347, 80, 100 }, -- Scroll of Intellect IX
			{ 37092, 48100, 80, 30 }, -- Scroll of Intellect VIII
			{ 37091, 48099, 70, 25 }, -- Scroll of Intellect VII
			{ 33458, 43195, 60, 20 }, -- Scroll of Intellect VI
			{ 27499, 33078, 50, 15 }, -- Scroll of Intellect V
			{ 10308, 12176, 40, 10 }, -- Scroll of Intellect IV
			{ 4419, 8098, 30, 8 }, -- Scroll of Intellect III
			{ 2290, 8097, 15, 6 }, -- Scroll of Intellect II
			{ 955, 8096, 1, 3 }, -- Scroll of Intellect
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105691] = 1000, -- Flask of the Warm Sun
			[79640] = 320, -- Alchemist's Flask
			[92730] = 300, -- Flask of Battle
			[79470] = 300, -- Flask of the Draconic Mind
			[17627] = 65, -- Flask of Distilled Wisdom
			[10692] = 25, -- Cerebral Cortex Compound
			[11396] = 25, -- Elixir of Greater Intellect
			[40568] = 25, -- Unstable Flask of the Elder
			[54452] = 24, -- Adept's Elixir
			[53749] = 20, -- Guru's Elixir
			[40573] = 20, -- Unstable Flask of the Physician
			[40576] = 20, -- Unstable Flask of the Sorcerer
			[45373] = 15, -- Bloodberry Elixir
			[33726] = 15, -- Elixir of Mastery
			[11390] = 12, -- Arcane Elixir
			[3166] = 8, -- Elixir of Wisdom
		},
	},
	Protection = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63308, 89344, 80, 400 }, -- Scroll of Protection IX
			{ 43467, 58452, 70, 100 }, -- Scroll of Protection VII
			{ 33459, 43196, 60, 20 }, -- Scroll of Protection VI
			{ 27500, 33079, 50, 60 }, -- Scroll of Protection V
			{ 10305, 12175, 40, 40 }, -- Scroll of Protection IV
			{ 4421, 8095, 30, 32 }, -- Scroll of Protection III
			{ 1478, 8094, 15, 20 }, -- Scroll of Protection II
			{ 3013, 8091, 1, 24 }, -- Scroll of Protection
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105681] = 2250, -- Mantid Elixir
			[79480] = 675, -- Elixir of Deep Earth
			[53763] = 220, -- Elixir of Protection
			[15233] = 204, -- Crystal Ward
			[60343] = 180, -- Elixir of Mighty Defense
			[28502] = 140, -- Elixir of Major Defense
			[11348] = 120, -- Elixir of Superior Defense
			[11349] = 100, -- Elixir of Greater Defense
			[673] = 50, -- Elixir of Minor Defense
			[54497] = 50, -- Oil of Olaf
			[3220] = 45, -- Elixir of Defense
		},
	},
	Stamina = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63306, 89345, 80, 150 }, -- Scroll of Stamina IX
			{ 37094, 48102, 80, 30 }, -- Scroll of Stamina VIII
			{ 37093, 48101, 70, 25 }, -- Scroll of Stamina VII
			{ 33461, 43198, 60, 20 }, -- Scroll of Stamina VI
			{ 27502, 33081, 50, 15 }, -- Scroll of Stamina V
			{ 10307, 12178, 40, 10 }, -- Scroll of Stamina IV
			{ 4422, 8101, 30, 8 }, -- Scroll of Stamina III
			{ 1711, 8100, 15, 5 }, -- Scroll of Stamina II
			{ 1180, 8099, 1, 3 }, -- Scroll of Stamina
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105694] = 1500, -- Flask of the Earth
			[79469] = 450, -- Flask of Steelskin
			[92729] = 300, -- Flask of Battle
			[40567] = 30, -- Unstable Flask of the Bandit
			[40572] = 30, -- Unstable Flask of the Beast
			[40568] = 30, -- Unstable Flask of the Elder
			[40573] = 30, -- Unstable Flask of the Physician
			[40575] = 30, -- Unstable Flask of the Soldier
			[10668] = 25, -- Lung Juice Cocktail
			[24382] = 25, -- Spirit of Zanza
			[53749] = 20, -- Guru's Elixir
			[40576] = 20, -- Unstable Flask of the Sorcerer
			[17537] = 18, -- Elixir of Brute Force
			[45373] = 15, -- Bloodberry Elixir
			[33726] = 15, -- Elixir of Mastery
		},
	},
	Spirit = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63307, 89342, 80, 100 }, -- Scroll of Spirit IX
			{ 37098, 48104, 80, 30 }, -- Scroll of Spirit VIII
			{ 37097, 48103, 70, 25 }, -- Scroll of Spirit VII
			{ 33460, 43197, 60, 20 }, -- Scroll of Spirit VI
			{ 27501, 33080, 50, 15 }, -- Scroll of Spirit V
			{ 10306, 12177, 40, 10 }, -- Scroll of Spirit IV
			{ 4424, 8114, 30, 8 }, -- Scroll of Spirit III
			{ 1712, 8113, 15, 5 }, -- Scroll of Spirit II
			{ 1181, 8112, 1, 3 }, -- Scroll of Spirit
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105693] = 1000, -- Flask of Falling Leaves
			[105685] = 750, -- Elixir of Peace
			[94160] = 300, -- Flask of Flowing Water
			[79468] = 225, -- Ghost Elixir
			[54212] = 90, -- Flask of Pure Mojo
			[28519] = 62, -- Flask of Mighty Restoration
			[41605] = 62, -- Shattrath Flask of Mighty Restoration
			[41610] = 62, -- Shattrath Flask of Mighty Restoration
			[53764] = 60, -- Elixir of Mighty Mageblood
			[53747] = 50, -- Elixir of Spirit
			[28509] = 40, -- Elixir of Major Mageblood
			[15231] = 30, -- Crystal Force
			[39627] = 30, -- Elixir of Draenic Wisdom
			[24363] = 30, -- Mageblood Elixir
			[10693] = 25, -- Gizzard Gum
			[24382] = 25, -- Spirit of Zanza
			[40568] = 25, -- Unstable Flask of the Elder
			[28491] = 24, -- Elixir of Healing Power
			[53749] = 20, -- Guru's Elixir
			[17535] = 18, -- Elixir of the Sages
			[45373] = 15, -- Bloodberry Elixir
			[33726] = 15, -- Elixir of Mastery
		},
	},
	Strength = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 63304, 89346, 80, 100 }, -- Scroll of Strength IX
			{ 43466, 58449, 80, 30 }, -- Scroll of Strength VIII
			{ 43465, 58448, 70, 25 }, -- Scroll of Strength VII
			{ 33462, 43199, 60, 20 }, -- Scroll of Strength VI
			{ 27503, 33082, 50, 15 }, -- Scroll of Strength V
			{ 10310, 12179, 40, 10 }, -- Scroll of Strength IV
			{ 4426, 8120, 30, 8 }, -- Scroll of Strength III
			{ 2289, 8119, 15, 6 }, -- Scroll of Strength II
			{ 954, 8118, 1, 3 }, -- Scroll of Strength
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[105696] = 1000, -- Flask of Winter's Bite
			[79638] = 320, -- Alchemist's Flask
			[92731] = 300, -- Flask of Battle
			[79472] = 300, -- Flask of Titanic Strength
			[53748] = 50, -- Elixir of Mighty Strength
			[28490] = 35, -- Elixir of Major Strength
			[11405] = 25, -- Elixir of Giants
			[10667] = 25, -- R.O.I.D.S.
			[53749] = 20, -- Guru's Elixir
			[40572] = 20, -- Unstable Flask of the Beast
			[40575] = 20, -- Unstable Flask of the Soldier
			[17537] = 18, -- Elixir of Brute Force
			[45373] = 15, -- Bloodberry Elixir
			[33726] = 15, -- Elixir of Mastery
			[8212] = 11, -- Elixir of Giant Growth
			[3164] = 8, -- Elixir of Ogre's Strength
			[2367] = 4, -- Elixir of Lion's Strength
		},
	},
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The stat scrolls, read by Features/Macros-for-Consumables/Scanner/Scanner-Auras.lua and Scanner-Scrolls.lua (FindBestScroll) to pick a scroll whose buff the player lacks. Each type lists its scrolls as { itemID, buffID, requiredLevel, amount }: the buff is the aura the scroll leaves, requiredLevel the level the item requires, amount the stat it grants. This client keeps the scrolls through rank IX (Inscription).
	- amount is the buff's scaled value: the coefficient times the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel. The client's data gives a few odd results (Scroll of Agility 6 against Scroll of Agility II 5, Scroll of Protection VI 20 against V's 60); they are kept as the client computes them. FindBestScroll ranks by required level first, so only the conflict check reads them.
	- conflictSpells lists the buffs a scroll is skipped for while one at least as strong is up, keyed by spell ID with the amount each grants: every elixir and flask buff in ns.ELIXIR_BUFF_IDS and ns.FLASK_BUFF_IDS (Data/Mists/Elixirs-Mists.lua) whose own spell, or a spell its text quotes, has a Mod Stat aura (29) for the stat (or for all stats), or a Mod Resistance aura (22) on armor for Protection, at its amount on this build. The other scrolls' buffs are left out, since the scroll's own buff check covers them.
	- No class buffs are listed: on this client Mark of the Wild, Blessing of Kings and Power Word: Fortitude raise stats by a percentage, not a flat amount, and stack with an elixir.
	- From Cataclysm on every scroll counts as an elixir (Battle for Agility, Intellect, Spirit and Strength; Guardian for Protection and Stamina), so on this client a scroll also replaces any elixir or flask in its slot, whatever the stat. This table follows the same-stat rule the other clients use and cannot say that; saying it takes a slot check in ns.HasScrollBuff (Features/Macros-for-Consumables/Scanner/Scanner-Auras.lua), not more rows here.
	- Scroll of Protection VIII (43468) is left out: no drop, vendor or quest reward in QuestieDB's MoP item table and no spell that creates it.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellScaling?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
