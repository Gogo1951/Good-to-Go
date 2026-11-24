local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- { [buffSpellID] = "GROUP" }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[1213892] = "FLASK", -- Flask of Ancient Knowledge
	[17629] = "FLASK", -- Flask of Chromatic Resistance
	[17627] = "FLASK", -- Flask of Distilled Wisdom
	[446228] = "NIGHTMARE_FLASK", -- Flask of Everlasting Nightmares
	[1213897] = "FLASK", -- Flask of Madness
	[17624] = "FLASK", -- Flask of Petrification
	[448084] = "NIGHTMARE_FLASK", -- Flask of Restless Dreams
	[17628] = "FLASK", -- Flask of Supreme Power
	[1213901] = "FLASK", -- Flask of the Old Gods
	[17626] = "FLASK", -- Flask of the Titans
	[1213886] = "FLASK", -- Flask of Unyielding Sorrow
}

-- { [buffSpellID] = "GROUP" }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[11390] = "ARCANE", -- Arcane Elixir
	[446256] = "ATALAI", -- Atal'ai Mojo of Forbidden Magic
	[446396] = "ATALAI", -- Atal'ai Mojo of Life
	[446336] = "ATALAI", -- Atal'ai Mojo of War
	[27653] = "BLOODKELP_DODGING", -- Bloodkelp Elixir of Dodging
	[27652] = "BLOODKELP_RESISTANCE", -- Bloodkelp Elixir of Resistance
	[10692] = "ZANZA_BLASTED_LANDS", -- Cerebral Cortex Compound
	[15231] = "CRYSTAL_FORCE", -- Crystal Force
	[15233] = "CRYSTAL_WARD", -- Crystal Ward
	[11328] = "AGILITY", -- Elixir of Agility
	[17537] = "BRUTE_FORCE", -- Elixir of Brute Force
	[3220] = "ARMOR", -- Elixir of Defense
	[11406] = "DEMONSLAYING", -- Elixir of Demonslaying
	[7844] = "FIRE_POWER", -- Elixir of Firepower
	[3593] = "HEALTH", -- Elixir of Fortitude
	[21920] = "FROST_POWER", -- Elixir of Frost Power
	[8212] = "GIANT_GROWTH", -- Elixir of Giant Growth
	[11405] = "GIANTS", -- Elixir of Giants
	[11334] = "AGILITY", -- Elixir of Greater Agility
	[11349] = "ARMOR", -- Elixir of Greater Defense
	[26276] = "FIRE_POWER", -- Elixir of Greater Firepower
	[11396] = "GREATER_INTELLECT", -- Elixir of Greater Intellect
	[3160] = "AGILITY", -- Elixir of Lesser Agility
	[2367] = "LESSER_STRENGTH", -- Elixir of Lion's Strength
	[2374] = "AGILITY", -- Elixir of Minor Agility
	[673] = "ARMOR", -- Elixir of Minor Defense
	[2378] = "HEALTH", -- Elixir of Minor Fortitude
	[3164] = "LESSER_STRENGTH", -- Elixir of Ogre's Strength
	[11474] = "SHADOW_POWER", -- Elixir of Shadow Power
	[11348] = "ARMOR", -- Elixir of Superior Defense
	[1213904] = "HONEY_BADGER", -- Elixir of the Honey Badger
	[1213917] = "ARMOR", -- Elixir of the Ironside
	[1213914] = "MAGE_LORD", -- Elixir of the Mage-Lord
	[17538] = "AGILITY", -- Elixir of the Mongoose
	[17535] = "SAGES", -- Elixir of the Sages
	[11319] = "WATER_WALKING", -- Elixir of Water Walking
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
	[439959] = "LESSER_ARCANE", -- Lesser Arcane Elixir
	[10668] = "ZANZA_BLASTED_LANDS", -- Lung Juice Cocktail
	[24363] = "MAGEBLOOD", -- Mageblood Potion
	[11364] = "MAGIC_RESISTANCE", -- Magic Resistance Potion
	[3223] = "TROLLS_BLOOD", -- Mighty Troll's Blood Potion
	[24361] = "TROLLS_BLOOD", -- Major Troll's Blood Potion
	[2380] = "MINOR_MAGIC_RESISTANCE", -- Minor Magic Resistance Potion
	[30331] = "ZANZA_BLASTED_LANDS", -- Permanent Sheen of Zanza
	[30336] = "ZANZA_BLASTED_LANDS", -- Permanent Spirit of Zanza
	[30338] = "ZANZA_BLASTED_LANDS", -- Permanent Swiftness of Zanza
	[10667] = "ZANZA_BLASTED_LANDS", -- R.O.I.D.S.
	[24417] = "ZANZA_BLASTED_LANDS", -- Sheen of Zanza
	[24382] = "ZANZA_BLASTED_LANDS", -- Spirit of Zanza
	[3222] = "TROLLS_BLOOD", -- Strong Troll's Blood Potion
	[24383] = "ZANZA_BLASTED_LANDS", -- Swiftness of Zanza
	[3219] = "TROLLS_BLOOD", -- Weak Troll's Blood Potion
	[17038] = "ATTACK_POWER", -- Winterfall Firewater
}

--[[
How We Got the Data

Last Validated
	2026-11-24, wago.tools, Season of Discovery 1.15.9.70576

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. The report reads only whether a buff is listed, never its group.
	- Each row's value is its stacking group, for Buff Duty's Flasks or Elixirs row (Features/Buff-Duty/Buff-Duty-Elixirs.lua). This client has no battle or guardian slots; instead some consumable buffs can't be up together, and buffs that share a group are those. An elixir is left off the row while another buff of its group is on the player, since the game would refuse it, overwrite the buff that's up, or add nothing. A buff with a group of its own stacks with every other buff listed, as far as the sources show. Where nothing settles a pair, each buff keeps its own group, so no icon is hidden on a guess.
	- The groups the Classic Era buffs share here are the same as in Data/Vanilla/, on the same evidence: VMaNGOS's world database (world_full_14_june_2021 plus every vmangos/core migration since) for the Zanzas, Blasted Lands buffs, Defense, Arcane, Firepower, Juju Might with Winterfall Firewater, and its same-icon rule for the Agility, lesser Strength, Fortitude (HEALTH) and Troll's Blood lines; this client's own text for one flask and one Zanza at a time; one shared hour-long cooldown (spell category 103) on the Blasted Lands items; and Classic player testing and guides where official Era differs from VMaNGOS (Mongoose with Greater Agility, Juju Power with Elixir of Giants, Blasted Lands with every Zanza). Data/Vanilla/ lists the uncertain pairs, all left apart.
	- FLASK holds the Classic flasks and the four Ahn'Qiraj flasks (Ancient Knowledge, Madness, the Old Gods, Unyielding Sorrow): each one's text in this client says only one flask works at a time. The two Nightmare flasks (Everlasting Nightmares, Restless Dreams) are NIGHTMARE_FLASK: their text says nothing about other flasks, and a 2024 Wowhead comment says they replace each other. Whether they stack with the other flasks is unsettled. A flask stacks with elixirs here, so Buff Duty never lets one block an elixir.
	- ATALAI is the three Atal'ai Mojos: each one's text says only one Atal'ai potion at a time. Two 2024 Wowhead comments say any Blasted Lands buff knocks a Mojo off; one group per buff can't say that as well as Blasted Lands with Zanza, so a Blasted Lands icon still shows while a Mojo is up.
	- Elixir of the Ironside is ARMOR: a 2024 Wowhead comment says it doesn't stack with Superior, Greater, plain or Minor Defense.
	- Uncertain, so left apart: Elixir of the Honey Badger against the Agility elixirs, Elixir of the Mage-Lord and Lesser Arcane Elixir against the Arcane elixirs, the Mojos against the Zanzas, and Mojo of War against Juju Might and Winterfall Firewater. No test was found for any of them.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- Season of Discovery's own flasks and elixirs (the Nightmare and Old Gods flasks, the Atal'ai Mojos, the Honey Badger, Mage-Lord and Ironside elixirs, Lesser Arcane Elixir), plus Flask of Petrification and the three Permanent Zanza buffs, came from the Classic Era tables on wago.tools (build 1.15.9.70003): each is the use spell of an item in the elixir spell category (79). They await the next Season of Discovery Validate Data run. The Mojos, like the Zanza buffs, allow one of their kind at a time.
	- Elixir of Alacrity (1213922, run speed only) and the two Draughts of the Sands (1217084, 1218485, damage against creatures in four zones) share that category but are left out: neither is a stat elixir the Flask or 2x Elixirs check is about.

SQL (CMaNGOS)
	Database not recorded.

	SELECT se.mask, se.entry AS buffSpellId, it.name
	FROM spell_elixir se
	LEFT JOIN item_template it ON it.spellid_1 = se.entry
	ORDER BY se.mask, it.name;

Wowhead
	https://www.wowhead.com/classic/item=13452/elixir-of-the-mongoose
	https://www.wowhead.com/classic/item=9187/elixir-of-greater-agility
	https://www.wowhead.com/classic/item=12451/juju-power
	https://www.wowhead.com/classic/item=12460/juju-might
	https://www.wowhead.com/classic/item=8410/r-o-i-d-s
	https://www.wowhead.com/classic/item=8412/ground-scorpok-assay
	https://www.wowhead.com/classic/item=20079/spirit-of-zanza
	https://www.wowhead.com/classic/item=233969/elixir-of-the-ironside
	https://www.wowhead.com/classic/item=221024/flask-of-everlasting-nightmares
	https://www.wowhead.com/classic/item=222952/flask-of-restless-dreams
	https://www.wowhead.com/classic/item=221196/atalai-mojo-of-war

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003
	https://wago.tools/db2/SpellCategories?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/Item?build=1.15.9.70576
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellName?build=1.15.9.70576
	https://wago.tools/db2/Spell?build=1.15.9.70576
	https://wago.tools/db2/SpellCategory?build=1.15.9.70576
	https://wago.tools/db2/SpellCategories?build=1.15.9.70576

QuestieDB
	None.
]]
