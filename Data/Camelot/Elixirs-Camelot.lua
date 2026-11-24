local _, ns = ...

-- { [buffSpellID] = "GROUP" }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[17629] = "FLASK", -- Flask of Chromatic Resistance
	[17627] = "FLASK", -- Flask of Distilled Wisdom
	[17624] = "FLASK", -- Flask of Petrification
	[17628] = "FLASK", -- Flask of Supreme Power
	[17626] = "FLASK", -- Flask of the Titans
	[1293740] = "FLASK", -- Flask of Natural Accuracy
	[1293741] = "FLASK", -- Flask of Natural Aggression
	[1293742] = "FLASK", -- Flask of Natural Precision
	[1293743] = "FLASK", -- Flask of Natural Swiftness
}

-- { [buffSpellID] = "GROUP" }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[11390] = "ARCANE", -- Arcane Elixir
	[27653] = "BLOODKELP_DODGING", -- Bloodkelp Elixir of Dodging
	[27652] = "BLOODKELP_RESISTANCE", -- Bloodkelp Elixir of Resistance
	[10692] = "ZANZA_BLASTED_LANDS", -- Cerebral Cortex Compound
	[15231] = "CRYSTAL_FORCE", -- Crystal Force
	[15233] = "CRYSTAL_WARD", -- Crystal Ward
	[11328] = "AGILITY", -- Elixir of Agility
	[17537] = "BRUTE_FORCE", -- Elixir of Brute Force
	[3220] = "ARMOR", -- Elixir of Lesser Defense
	[11406] = "DEMONSLAYING", -- Potion of Demon Slaying
	[7844] = "FIRE_POWER", -- Elixir of Fire Power
	[3593] = "HEALTH", -- Elixir of Lesser Fortitude
	[21920] = "FROST_POWER", -- Elixir of Frost Power
	[8212] = "GIANT_GROWTH", -- Elixir of Giant Growth
	[11405] = "GIANTS", -- Elixir of Greater Strength
	[11334] = "AGILITY", -- Elixir of Greater Agility
	[11349] = "ARMOR", -- Elixir of Defense
	[26276] = "FIRE_POWER", -- Greater Firepower (no Forever item grants it: Elixir of Greater Firepower became Elixir of Holy Power)
	[11396] = "GREATER_INTELLECT", -- Elixir of Greater Intellect
	[3160] = "AGILITY", -- Elixir of Lesser Agility
	[2367] = "LESSER_STRENGTH", -- Elixir of Minor Strength
	[2374] = "AGILITY", -- Elixir of Minor Agility
	[673] = "ARMOR", -- Elixir of Minor Defense
	[2378] = "HEALTH", -- Elixir of Minor Fortitude
	[3164] = "LESSER_STRENGTH", -- Elixir of Ogre Strength
	[11474] = "SHADOW_POWER", -- Elixir of Shadow Power
	[11348] = "ARMOR", -- Elixir of Greater Defense
	[17538] = "AGILITY", -- Elixir of the Mongoose
	[17535] = "SAGES", -- Elixir of the Sages
	[11319] = "WATER_WALKING", -- Draught of Water Walking
	[3166] = "WISDOM", -- Elixir of Wisdom
	[11371] = "GIFT_OF_ARTHAS", -- Gift of Arthas
	[10693] = "ZANZA_BLASTED_LANDS", -- Gizzard Gum
	[17539] = "ARCANE", -- Greater Arcane Elixir
	[10669] = "ZANZA_BLASTED_LANDS", -- Ground Scorpok Assay
	[16325] = "JUJU_CHILL", -- Juju Chill
	[16326] = "JUJU_EMBER", -- Juju Ember
	[16321] = "JUJU_ESCAPE", -- Juju Escape
	[16322] = "JUJU_FLURRY", -- Juju Flurry
	[16327] = "JUJU_GUILE", -- Juju Guile
	[16329] = "ATTACK_POWER", -- Juju Might
	[16323] = "GIANTS", -- Juju Power
	[10668] = "ZANZA_BLASTED_LANDS", -- Lung Juice Cocktail
	[24363] = "MAGEBLOOD", -- Mageblood Elixir
	[11364] = "MAGIC_RESISTANCE", -- Magic Resistance Potion
	[3223] = "TROLLS_BLOOD", -- Troll's Blood Elixir
	[24361] = "TROLLS_BLOOD", -- Major Troll's Blood Elixir
	[2380] = "MINOR_MAGIC_RESISTANCE", -- Minor Magic Resistance Potion
	[10667] = "ZANZA_BLASTED_LANDS", -- R.O.I.D.S.
	[24417] = "ZANZA_BLASTED_LANDS", -- Sheen of Zanza
	[24382] = "ZANZA_BLASTED_LANDS", -- Spirit of Zanza
	[3222] = "TROLLS_BLOOD", -- Lesser Troll's Blood Elixir
	[24383] = "ZANZA_BLASTED_LANDS", -- Swiftness of Zanza
	[3219] = "TROLLS_BLOOD", -- Minor Troll's Blood Elixir
	[17038] = "ATTACK_POWER", -- Winterfall Firewater
	[1245244] = "MINOR_ARCANE", -- Minor Arcane Elixir
	[1245249] = "MINOR_FORCE", -- Elixir of Minor Force
	[1250918] = "CUNNING", -- Elixir of Cunning
	[1250920] = "PHALANX", -- Elixir of the Phalanx
	[1250922] = "MINOR_CLERIC", -- Minor Cleric's Elixir
	[1250924] = "LESSER_CLERIC", -- Lesser Cleric's Elixir
	[1250925] = "CLERIC", -- Cleric's Elixir
	[1250926] = "GREATER_CLERIC", -- Greater Cleric's Elixir
	[1250928] = "FORTITUDE", -- Elixir of Fortitude
	[1250931] = "GREATER_FORTITUDE", -- Elixir of Greater Fortitude
	[1250932] = "WICKED_REGENERATION", -- Elixir of Wicked Regeneration
	[1250940] = "OWL", -- Elixir of the Owl
	[1250941] = "SPIRIT_SAGES", -- Elixir of Sages
	[1250942] = "MINOR_MAGEBLOOD", -- Minor Mageblood Elixir
	[1250944] = "LESSER_MAGEBLOOD", -- Lesser Mageblood Elixir
	[1250948] = "GREATER_MAGEBLOOD", -- Greater Mageblood Elixir
	[1250971] = "LESSER_ARCANE", -- Lesser Arcane Elixir
	[1250972] = "NATURE_POWER", -- Elixir of Nature Power
	[1250974] = "MINOR_SPIRIT", -- Elixir of Minor Spirit
	[1250976] = "LESSER_SPIRIT", -- Elixir of Lesser Spirit
	[1250978] = "SPIRIT", -- Elixir of Spirit
	[1250979] = "GREATER_SPIRIT", -- Elixir of Greater Spirit
	[1250981] = "WHALE", -- Elixir of the Whale
	[1250984] = "STRENGTH", -- Elixir of Strength
	[1250985] = "FEROCITY", -- Elixir of Ferocity
	[1250986] = "GRIZZLY", -- Elixir of the Grizzly
	[1250988] = "LESSER_INTELLECT", -- Elixir of Lesser Intellect
	[1250989] = "INTELLECT", -- Elixir of Intellect
	[1310077] = "HOLY_POWER", -- Elixir of Holy Power
}

--[[
How We Got the Data

Last Validated
	2026-11-24, Validate Data, WoW Forever 1.60.1.71037

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. The report reads only whether a buff is listed, never its group.
	- Each row's value is its stacking group, for Buff Duty's Flasks or Elixirs row (Features/Buff-Duty/Buff-Duty-Elixirs.lua). This client has no battle or guardian slots; instead some consumable buffs can't be up together, and buffs that share a group are those. An elixir is left off the row while another buff of its group is on the player, since the game would refuse it, overwrite the buff that's up, or add nothing. A buff with a group of its own stacks with every other buff listed, as far as the sources show. Where nothing settles a pair, each buff keeps its own group, so no icon is hidden on a guess.
	- The buffs this client shares with Classic Era keep Data/Vanilla/'s groups, on that file's evidence: VMaNGOS's world database, Classic Era player testing and guides, and the Classic Era client's text and item data. None of it was tested on WoW Forever. This client's own text agrees where it speaks: one flask at a time, and one type of Zanza potion at a time (Sheen of Zanza). The groups carry Forever's names in the row comments: AGILITY (Minor, Lesser, plain and Greater Agility, Mongoose), LESSER_STRENGTH (Minor and Ogre Strength), GIANTS (Greater Strength, which is Classic's Elixir of Giants, with Juju Power), ARMOR (Minor, Lesser, plain and Greater Defense), HEALTH (Minor and Lesser Fortitude), TROLLS_BLOOD (the four Troll's Blood elixirs), ARCANE, FIRE_POWER (Fire Power with the Greater Firepower buff no item grants here), ATTACK_POWER (Juju Might, Winterfall Firewater), ZANZA_BLASTED_LANDS.
	- FLASK also holds the four Natural flasks: each one's text says only one flask works at a time. A flask stacks with elixirs here, so Buff Duty never lets one block an elixir.
	- Every WoW Forever elixir (IDs above 1240000) has a group of its own: nothing found says what they stack with, not even the tiers of one line (Minor, Lesser, plain and Greater Cleric's, Mageblood, Spirit; Fortitude and Greater Fortitude; Elixir of Strength between Ogre Strength and Greater Strength; Minor and Lesser Arcane below Arcane; Lesser Intellect and Intellect beside Greater Intellect and Wisdom). One that lies between two Classic tiers would be the first to check in game.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- The buffs of WoW Forever's own elixirs and flasks (IDs above 1240000) are each item's use spell in this client's tables on wago.tools. Flask of Petrification (17624) is here because this client's text for it says only one flask works at a time. Elixir of Greater Firepower became Elixir of Holy Power (buff 1310077) on this client.
	- Lesser Arcane Elixir (217398) is left out: it is a Season of Discovery item this client also knows.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

	SELECT se.mask, se.entry AS buffSpellId, it.name
	FROM spell_elixir se
	LEFT JOIN item_template it ON it.spellid_1 = se.entry
	ORDER BY se.mask, it.name;

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
	https://wago.tools/db2/SpellCategories?build=1.60.1.70450
	https://wago.tools/db2/Item?build=1.60.1.70862
	https://wago.tools/db2/ItemSparse?build=1.60.1.70862
	https://wago.tools/db2/ItemEffect?build=1.60.1.70862
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70862
	https://wago.tools/db2/SpellName?build=1.60.1.70862
	https://wago.tools/db2/SpellEffect?build=1.60.1.70862
	https://wago.tools/db2/ItemSparse?build=1.60.1.70938
	https://wago.tools/db2/Item?build=1.60.1.70938
	https://wago.tools/db2/ItemEffect?build=1.60.1.70938
	https://wago.tools/db2/SpellEffect?build=1.60.1.70938
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70938
	https://wago.tools/db2/Spell?build=1.60.1.70938
	https://wago.tools/db2/SpellName?build=1.60.1.70959
	https://wago.tools/db2/Spell?build=1.60.1.70959
	https://wago.tools/db2/SpellMisc?build=1.60.1.70959
	https://wago.tools/db2/SpellEffect?build=1.60.1.70959
	https://wago.tools/db2/SpellLevels?build=1.60.1.70959
	https://wago.tools/db2/Spell?build=1.60.1.71037
	https://wago.tools/db2/SpellEffect?build=1.60.1.71037
	https://wago.tools/db2/SpellCategories?build=1.60.1.71037
	https://wago.tools/db2/SpellName?build=1.60.1.71037

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Forever/foreverItemDB.lua
]]
