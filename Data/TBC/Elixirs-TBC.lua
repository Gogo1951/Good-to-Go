local _, ns = ...

-- { [buffSpellID] = true }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[28521] = true, -- Flask of Blinding Light
	[17629] = true, -- Flask of Chromatic Resistance
	[42735] = true, -- Flask of Chromatic Wonder
	[17627] = true, -- Flask of Distilled Wisdom
	[28518] = true, -- Flask of Fortification
	[28519] = true, -- Flask of Mighty Restoration
	[17624] = true, -- Flask of Petrification
	[28540] = true, -- Flask of Pure Death
	[28520] = true, -- Flask of Relentless Assault
	[17628] = true, -- Flask of Supreme Power
	[17626] = true, -- Flask of the Titans
	[46839] = true, -- Shattrath Flask of Blinding Light
	[41609] = true, -- Shattrath Flask of Fortification
	[41610] = true, -- Shattrath Flask of Mighty Restoration
	[46837] = true, -- Shattrath Flask of Pure Death
	[41608] = true, -- Shattrath Flask of Relentless Assault
	[41611] = true, -- Shattrath Flask of Supreme Power
	[40567] = true, -- Unstable Flask of the Bandit
	[40572] = true, -- Unstable Flask of the Beast
	[40568] = true, -- Unstable Flask of the Elder
	[40573] = true, -- Unstable Flask of the Physician
	[40575] = true, -- Unstable Flask of the Soldier
	[40576] = true, -- Unstable Flask of the Sorcerer
	[33053] = true, -- Mr Pinchy's Blessing (buff with no matching item)
}

-- { [buffSpellID] = "BATTLE" or "GUARDIAN" }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[11390] = "BATTLE", -- Arcane Elixir
	[45373] = "BATTLE", -- Bloodberry Elixir
	[27653] = "GUARDIAN", -- Bloodkelp Elixir of Dodging
	[27652] = "GUARDIAN", -- Bloodkelp Elixir of Resistance
	[10692] = "GUARDIAN", -- Cerebral Cortex Compound
	[15231] = "GUARDIAN", -- Crystal Force
	[15233] = "GUARDIAN", -- Crystal Ward
	[11328] = "BATTLE", -- Elixir of Agility
	[39626] = "GUARDIAN", -- Earthen Elixir
	[17537] = "BATTLE", -- Elixir of Brute Force
	[3220] = "GUARDIAN", -- Elixir of Defense
	[11406] = "BATTLE", -- Elixir of Demonslaying
	[39627] = "GUARDIAN", -- Elixir of Draenic Wisdom
	[28514] = "GUARDIAN", -- Elixir of Empowerment
	[7844] = "BATTLE", -- Elixir of Firepower
	[3593] = "GUARDIAN", -- Elixir of Fortitude
	[21920] = "BATTLE", -- Elixir of Frost Power
	[8212] = "BATTLE", -- Elixir of Giant Growth
	[11405] = "BATTLE", -- Elixir of Giants
	[11334] = "BATTLE", -- Elixir of Greater Agility
	[11349] = "GUARDIAN", -- Elixir of Greater Defense
	[26276] = "BATTLE", -- Elixir of Greater Firepower
	[11396] = "GUARDIAN", -- Elixir of Greater Intellect
	[28491] = "BATTLE", -- Elixir of Healing Power
	[39628] = "GUARDIAN", -- Elixir of Ironskin
	[3160] = "BATTLE", -- Elixir of Lesser Agility
	[2367] = "BATTLE", -- Elixir of Lion's Strength
	[28502] = "GUARDIAN", -- Elixir of Major Defense
	[28501] = "BATTLE", -- Elixir of Major Firepower
	[39625] = "GUARDIAN", -- Elixir of Major Fortitude
	[28493] = "BATTLE", -- Elixir of Major Frost Power
	[28509] = "GUARDIAN", -- Elixir of Major Mageblood
	[28503] = "BATTLE", -- Elixir of Major Shadow Power
	[28490] = "BATTLE", -- Elixir of Major Strength
	[33726] = "BATTLE", -- Elixir of Mastery
	[28497] = "BATTLE", -- Elixir of Major Agility
	[2374] = "BATTLE", -- Elixir of Minor Agility
	[673] = "GUARDIAN", -- Elixir of Minor Defense
	[2378] = "GUARDIAN", -- Elixir of Minor Fortitude
	[3164] = "BATTLE", -- Elixir of Ogre's Strength
	[11474] = "BATTLE", -- Elixir of Shadow Power
	[11348] = "GUARDIAN", -- Elixir of Superior Defense
	[17538] = "BATTLE", -- Elixir of the Mongoose
	[17535] = "GUARDIAN", -- Elixir of the Sages
	[11319] = "GUARDIAN", -- Elixir of Water Walking
	[3166] = "GUARDIAN", -- Elixir of Wisdom
	[38954] = "BATTLE", -- Fel Strength Elixir
	[11371] = "GUARDIAN", -- Gift of Arthas
	[10693] = "GUARDIAN", -- Gizzard Gum
	[29348] = "GUARDIAN", -- Goldenmist Special Brew
	[17539] = "BATTLE", -- Greater Arcane Elixir
	[10669] = "BATTLE", -- Ground Scorpok Assay
	[16325] = "GUARDIAN", -- Juju Chill
	[16326] = "GUARDIAN", -- Juju Ember
	[16321] = "GUARDIAN", -- Juju Escape
	[16322] = "BATTLE", -- Juju Flurry
	[16327] = "GUARDIAN", -- Juju Guile
	[16329] = "BATTLE", -- Juju Might
	[16323] = "BATTLE", -- Juju Power
	[10668] = "GUARDIAN", -- Lung Juice Cocktail
	[24363] = "GUARDIAN", -- Mageblood Potion
	[11364] = "GUARDIAN", -- Magic Resistance Potion
	[3223] = "GUARDIAN", -- Mighty Troll's Blood Potion
	[24361] = "GUARDIAN", -- Major Troll's Blood Potion
	[2380] = "GUARDIAN", -- Minor Magic Resistance Potion
	[33720] = "BATTLE", -- Onslaught Elixir
	[10667] = "BATTLE", -- R.O.I.D.S.
	[28486] = "BATTLE", -- Scourgebane Draught
	[28488] = "BATTLE", -- Scourgebane Infusion
	[24417] = "GUARDIAN", -- Sheen of Zanza
	[33721] = "BATTLE", -- Adept's Elixir
	[24382] = "GUARDIAN", -- Spirit of Zanza
	[3222] = "GUARDIAN", -- Strong Troll's Blood Potion
	[24383] = "GUARDIAN", -- Swiftness of Zanza
	[3219] = "GUARDIAN", -- Weak Troll's Blood Potion
	[17038] = "BATTLE", -- Winterfall Firewater
}

--[[
How We Got the Data

Last Validated
	2026-11-27, wago.tools, TBC Anniversary 2.5.6.70577

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. The report reads only whether a buff is in a table, never its value.
	- Each elixir row's value is the slot its buff fills: "BATTLE" or "GUARDIAN". Buff Duty reads it to hide an elixir in the bags when a buff already on the player fills that slot; a flask fills both, so ns.FLASK_BUFF_IDS keeps plain true. The slot can't be read off an aura at runtime, which is why it is stored. No row fills both or neither.
	- The slot comes from the spell_elixir mask in CMaNGOS tbc-db (Full_DB TBCDB 1.11.0, no later update touches the table): mask 1 is BATTLE, 2 is GUARDIAN, per the mask defines in mangos-tbc's SpellMgr.h (3 = both, a flask; 4 = Unstable, 8 = Shattrath, 16 = well fed). Checked 2026-11-22 against this client's own spell text (Spell, 2.5.6.70577): 69 of the 76 buffs name the same slot there ("Battle Elixir" / "Guardian Elixir") and none disagrees. The other 7 name no slot in their text, so their slot rests on the mask alone: Bloodkelp Elixir of Dodging (27653), Bloodkelp Elixir of Resistance (27652), Goldenmist Special Brew (29348), Magic Resistance Potion (11364) and Minor Magic Resistance Potion (2380) are GUARDIAN; Scourgebane Draught (28486) and Scourgebane Infusion (28488) are BATTLE.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- Season of Discovery items are left out; this client doesn't know them. They live only in Data/Discovery/.

SQL (CMaNGOS)
	Database not recorded.

	SELECT se.mask, se.entry AS buffSpellId, it.name
	FROM spell_elixir se
	LEFT JOIN item_template it ON it.spellid_1 = se.entry
	ORDER BY se.mask, it.name;

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
	https://wago.tools/db2/SpellCategories?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70577
	https://wago.tools/db2/Item?build=2.5.6.70577
	https://wago.tools/db2/ItemEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellEffect?build=2.5.6.70577
	https://wago.tools/db2/Spell?build=2.5.6.70577
	https://wago.tools/db2/SpellName?build=2.5.6.70577

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcItemDB.lua
]]
