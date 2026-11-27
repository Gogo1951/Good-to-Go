local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- { [buffSpellID] = "GROUP" }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[17629] = "FLASK", -- Flask of Chromatic Resistance
	[17627] = "FLASK", -- Flask of Distilled Wisdom
	[17624] = "FLASK", -- Flask of Petrification
	[17628] = "FLASK", -- Flask of Supreme Power
	[17626] = "FLASK", -- Flask of the Titans
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
	2026-11-27, wago.tools, Classic Era 1.15.9.70576

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. The report reads only whether a buff is listed, never its group.
	- Each row's value is its stacking group, for Buff Duty's Flasks or Elixirs row (Features/Buff-Duty/Buff-Duty-Elixirs.lua). This client has no battle or guardian slots; instead some consumable buffs can't be up together, and buffs that share a group are those. An elixir is left off the row while another buff of its group is on the player, since the game would refuse it, overwrite the buff that's up, or add nothing. A buff with a group of its own stacks with every other buff listed, as far as the sources show. Where nothing settles a pair, each buff keeps its own group, so no icon is hidden on a guess.
	- Every flask is FLASK: each flask's own text in this client says only one flask works at a time, and VMaNGOS marks all five as flasks (spell_elixir mask 3). A flask stacks with elixirs here, so Buff Duty never lets one block an elixir.
	- Sources for the groups. VMaNGOS's world database (world_full_14_june_2021, plus every vmangos/core migration since; none touches these groups): spell_group 1003 (the three Zanzas), 1004 (Spirit of Zanza with Gizzard Gum and Lung Juice Cocktail), 1008 (the five Blasted Lands buffs), 1022 (Minor Defense, Defense and Greater Defense, with the Protection scrolls), 1023 (Arcane and Greater Arcane Elixir), 1024 (Firepower and Greater Firepower), 1072 (Juju Might and Winterfall Firewater); and its rule that two potion buffs with the same icon and visual don't stack, which pairs the four Agility elixirs, the two lesser Strength elixirs, the three upper Defense elixirs, the two Fortitude elixirs (HEALTH), the four Troll's Blood potions, and each Zanza with its Permanent copy. This client's own text: Sheen of Zanza and the Permanent Zanzas say only one type of Zanza potion at a time. This client's item data: the five Blasted Lands items share one hour-long cooldown (spell category 103), as long as their buffs last.
	- Where official Classic Era differs from VMaNGOS, Era player testing and guides win: Elixir of the Mongoose doesn't stack with Elixir of Greater Agility (Wowhead Classic comment, 2019; Classic consumable guides); Juju Power doesn't stack with Elixir of Giants (Classic guides; 2006 comments that the Juju replaced the elixir); and any Blasted Lands buff knocks off a Zanza buff, not just Gizzard Gum and Lung Juice (Wowhead Classic comments, 2020 and 2025), which is why Zanza and Blasted Lands are one group. VMaNGOS lets all three pairs stack except Spirit of Zanza with those two. CMaNGOS lets potion-family buffs stack freely, so it settled nothing here beyond one flask at a time.
	- Uncertain, so left apart: Elixir of Giants and Juju Power against Lion's and Ogre's Strength; Giant Growth against the Strength elixirs (one Season of Discovery comment says its Strength doesn't add to Ogre's Strength, while its size does); Elixir of Wisdom, Elixir of the Sages and Greater Intellect against each other (2005 comments disagree); Minor Magic Resistance against Magic Resistance (different visuals in VMaNGOS, no test found); Crystal Ward against the Defense elixirs (a 2006 test says it doesn't stack with Superior Defense, no Classic Era test found); Brute Force against Elixir of Giants (a 2021 Classic comment says they stack).
	- One known cost of the AGILITY group: drunk over Greater Agility, Mongoose's Agility adds nothing, but its crit chance may still apply; the group hides Mongoose while Greater Agility is up.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- Season of Discovery items are left out even though this client knows their IDs: they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

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
	https://www.wowhead.com/classic/item=8411/lung-juice-cocktail
	https://www.wowhead.com/classic/item=20079/spirit-of-zanza
	https://www.wowhead.com/classic/item=13453/elixir-of-brute-force
	https://www.wowhead.com/classic/item=13447/elixir-of-the-sages
	https://www.wowhead.com/classic/item=11564/crystal-ward
	https://www.wowhead.com/classic/item=6662/elixir-of-giant-growth

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70576
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/Spell?build=1.15.9.70576
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellMisc?build=1.15.9.70576
	https://wago.tools/db2/SpellDuration?build=1.15.9.70576
	https://wago.tools/db2/SpellCategories?build=1.15.9.70576
	https://wago.tools/db2/SpellName?build=1.15.9.70576
	https://wago.tools/db2/SpellCategory?build=1.15.9.70576

QuestieDB
	None.
]]
