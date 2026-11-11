local _, ns = ...

-- { [buffSpellID] = true }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[79638] = true, -- Alchemist's Flask
	[79639] = true, -- Alchemist's Flask
	[79640] = true, -- Alchemist's Flask
	[92725] = true, -- Flask of Battle
	[92729] = true, -- Flask of Battle
	[92730] = true, -- Flask of Battle
	[92731] = true, -- Flask of Battle
	[28521] = true, -- Flask of Blinding Light
	[17627] = true, -- Flask of Distilled Wisdom
	[105693] = true, -- Flask of Falling Leaves
	[94160] = true, -- Flask of Flowing Water
	[28518] = true, -- Flask of Fortification
	[28519] = true, -- Flask of Mighty Restoration
	[28540] = true, -- Flask of Pure Death
	[54212] = true, -- Flask of Pure Mojo
	[28520] = true, -- Flask of Relentless Assault
	[105689] = true, -- Flask of Spring Blossoms
	[79469] = true, -- Flask of Steelskin
	[17628] = true, -- Flask of Supreme Power
	[79470] = true, -- Flask of the Draconic Mind
	[105694] = true, -- Flask of the Earth
	[17626] = true, -- Flask of the Titans
	[105691] = true, -- Flask of the Warm Sun
	[79471] = true, -- Flask of the Winds
	[79472] = true, -- Flask of Titanic Strength
	[105696] = true, -- Flask of Winter's Bite
	[53760] = true, -- Jillian's Tonic of Endless Rage, Flask of Endless Rage
	[53758] = true, -- Jillian's Tonic of Stoneblood, Flask of Stoneblood
	[53755] = true, -- Jillian's Tonic of the Frost Wyrm, Flask of the Frost Wyrm
	[53752] = true, -- Lesser Flask of Toughness
	[46839] = true, -- Shattrath Flask of Blinding Light
	[46840] = true, -- Shattrath Flask of Blinding Light
	[41607] = true, -- Shattrath Flask of Fortification
	[41609] = true, -- Shattrath Flask of Fortification
	[41605] = true, -- Shattrath Flask of Mighty Restoration
	[41610] = true, -- Shattrath Flask of Mighty Restoration
	[46837] = true, -- Shattrath Flask of Pure Death
	[46838] = true, -- Shattrath Flask of Pure Death
	[41606] = true, -- Shattrath Flask of Relentless Assault
	[41608] = true, -- Shattrath Flask of Relentless Assault
	[41604] = true, -- Shattrath Flask of Supreme Power
	[41611] = true, -- Shattrath Flask of Supreme Power
	[40567] = true, -- Unstable Flask of the Bandit
	[40572] = true, -- Unstable Flask of the Beast
	[40568] = true, -- Unstable Flask of the Elder
	[40573] = true, -- Unstable Flask of the Physician
	[40575] = true, -- Unstable Flask of the Soldier
	[40576] = true, -- Unstable Flask of the Sorcerer
}

-- { [buffSpellID] = true }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[54452] = true, -- Adept's Elixir
	[11390] = true, -- Arcane Elixir
	[45373] = true, -- Bloodberry Elixir
	[46352] = true, -- Burning Blossom (Fire Festival Fury)
	[12608] = true, -- Catseye Elixir
	[10692] = true, -- Cerebral Cortex Compound
	[15231] = true, -- Crystal Force
	[15233] = true, -- Crystal Ward
	[109933] = true, -- Darkmoon Firewater
	[39626] = true, -- Earthen Elixir
	[60340] = true, -- Elixir of Accuracy
	[11328] = true, -- Elixir of Agility
	[80532] = true, -- Elixir of Armor Piercing
	[17537] = true, -- Elixir of Brute Force
	[60341] = true, -- Elixir of Deadly Strikes
	[79480] = true, -- Elixir of Deep Earth
	[3220] = true, -- Elixir of Defense
	[11406] = true, -- Elixir of Demonslaying
	[39627] = true, -- Elixir of Draenic Wisdom
	[134870] = true, -- Elixir of Empowerment
	[60344] = true, -- Elixir of Expertise
	[7844] = true, -- Elixir of Firepower
	[3593] = true, -- Elixir of Fortitude
	[21920] = true, -- Elixir of Frost Power
	[8212] = true, -- Elixir of Giant Growth
	[11405] = true, -- Elixir of Giants
	[11334] = true, -- Elixir of Greater Agility
	[11349] = true, -- Elixir of Greater Defense
	[26276] = true, -- Elixir of Greater Firepower
	[11396] = true, -- Elixir of Greater Intellect
	[28491] = true, -- Elixir of Healing Power
	[79481] = true, -- Elixir of Impossible Accuracy
	[39628] = true, -- Elixir of Ironskin
	[3160] = true, -- Elixir of Lesser Agility
	[60346] = true, -- Elixir of Lightning Speed
	[2367] = true, -- Elixir of Lion's Strength
	[54494] = true, -- Elixir of Major Agility
	[28502] = true, -- Elixir of Major Defense
	[28501] = true, -- Elixir of Major Firepower
	[39625] = true, -- Elixir of Major Fortitude
	[28493] = true, -- Elixir of Major Frost Power
	[28509] = true, -- Elixir of Major Mageblood
	[28503] = true, -- Elixir of Major Shadow Power
	[28490] = true, -- Elixir of Major Strength
	[33726] = true, -- Elixir of Mastery
	[28497] = true, -- Elixir of Mighty Agility
	[60343] = true, -- Elixir of Mighty Defense
	[53751] = true, -- Elixir of Mighty Fortitude
	[53764] = true, -- Elixir of Mighty Mageblood
	[79632] = true, -- Elixir of Mighty Speed
	[53748] = true, -- Elixir of Mighty Strength
	[60347] = true, -- Elixir of Mighty Thoughts
	[63729] = true, -- Elixir of Minor Accuracy
	[2374] = true, -- Elixir of Minor Agility
	[673] = true, -- Elixir of Minor Defense
	[2378] = true, -- Elixir of Minor Fortitude
	[105687] = true, -- Elixir of Mirrors
	[3164] = true, -- Elixir of Ogre's Strength
	[105685] = true, -- Elixir of Peace
	[105686] = true, -- Elixir of Perfection
	[53763] = true, -- Elixir of Protection
	[11474] = true, -- Elixir of Shadow Power
	[53747] = true, -- Elixir of Spirit
	[11348] = true, -- Elixir of Superior Defense
	[79477] = true, -- Elixir of the Cobra
	[79635] = true, -- Elixir of the Master
	[17538] = true, -- Elixir of the Mongoose
	[79474] = true, -- Elixir of the Naga
	[105684] = true, -- Elixir of the Rapids
	[17535] = true, -- Elixir of the Sages
	[11319] = true, -- Elixir of Water Walking
	[105683] = true, -- Elixir of Weaponry
	[3166] = true, -- Elixir of Wisdom
	[38954] = true, -- Fel Strength Elixir
	[79468] = true, -- Ghost Elixir
	[11371] = true, -- Gift of Arthas
	[10693] = true, -- Gizzard Gum
	[29348] = true, -- Goldenmist Special Brew
	[17539] = true, -- Greater Arcane Elixir
	[10669] = true, -- Ground Scorpok Assay
	[53749] = true, -- Guru's Elixir
	[10668] = true, -- Lung Juice Cocktail
	[105682] = true, -- Mad Hozen Elixir
	[24363] = true, -- Mageblood Elixir
	[3223] = true, -- Major Troll's Blood Elixir
	[105681] = true, -- Mantid Elixir
	[24361] = true, -- Mighty Troll's Blood Elixir
	[105688] = true, -- Monk's Elixir
	[54497] = true, -- Oil of Olaf
	[33720] = true, -- Onslaught Elixir
	[134873] = true, -- Prismatic Elixir
	[10667] = true, -- R.O.I.D.S.
	[8115] = true, -- Scroll of Agility
	[8116] = true, -- Scroll of Agility II
	[8117] = true, -- Scroll of Agility III
	[12174] = true, -- Scroll of Agility IV
	[89343] = true, -- Scroll of Agility IX
	[33077] = true, -- Scroll of Agility V
	[43194] = true, -- Scroll of Agility VI
	[58450] = true, -- Scroll of Agility VII
	[58451] = true, -- Scroll of Agility VIII
	[8096] = true, -- Scroll of Intellect
	[8097] = true, -- Scroll of Intellect II
	[8098] = true, -- Scroll of Intellect III
	[12176] = true, -- Scroll of Intellect IV
	[89347] = true, -- Scroll of Intellect IX
	[33078] = true, -- Scroll of Intellect V
	[43195] = true, -- Scroll of Intellect VI
	[48099] = true, -- Scroll of Intellect VII
	[48100] = true, -- Scroll of Intellect VIII
	[8091] = true, -- Scroll of Protection
	[8094] = true, -- Scroll of Protection II
	[8095] = true, -- Scroll of Protection III
	[12175] = true, -- Scroll of Protection IV
	[89344] = true, -- Scroll of Protection IX
	[33079] = true, -- Scroll of Protection V
	[43196] = true, -- Scroll of Protection VI
	[58452] = true, -- Scroll of Protection VII
	[8112] = true, -- Scroll of Spirit
	[8113] = true, -- Scroll of Spirit II
	[8114] = true, -- Scroll of Spirit III
	[12177] = true, -- Scroll of Spirit IV
	[89342] = true, -- Scroll of Spirit IX
	[33080] = true, -- Scroll of Spirit V
	[43197] = true, -- Scroll of Spirit VI
	[48103] = true, -- Scroll of Spirit VII
	[48104] = true, -- Scroll of Spirit VIII
	[8099] = true, -- Scroll of Stamina
	[8100] = true, -- Scroll of Stamina II
	[8101] = true, -- Scroll of Stamina III
	[12178] = true, -- Scroll of Stamina IV
	[89345] = true, -- Scroll of Stamina IX
	[33081] = true, -- Scroll of Stamina V
	[43198] = true, -- Scroll of Stamina VI
	[48101] = true, -- Scroll of Stamina VII
	[48102] = true, -- Scroll of Stamina VIII
	[8118] = true, -- Scroll of Strength
	[8119] = true, -- Scroll of Strength II
	[8120] = true, -- Scroll of Strength III
	[12179] = true, -- Scroll of Strength IV
	[89346] = true, -- Scroll of Strength IX
	[33082] = true, -- Scroll of Strength V
	[43199] = true, -- Scroll of Strength VI
	[58448] = true, -- Scroll of Strength VII
	[58449] = true, -- Scroll of Strength VIII
	[24417] = true, -- Sheen of Zanza
	[33721] = true, -- Spellpower Elixir
	[24382] = true, -- Spirit of Zanza
	[3222] = true, -- Strong Troll's Blood Elixir
	[24383] = true, -- Swiftness of Zanza
	[3219] = true, -- Weak Troll's Blood Elixir
	[17038] = true, -- Winterfall Firewater
	[53746] = true, -- Wrath Elixir
}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. Each row's comment names the item or items that grant the buff.
	- This client has no server elixir table, so the split comes from the buff spell's own text, which on this client names its slot on every elixir and flask: "Counts as both a Battle and Guardian elixir" is a flask (ns.FLASK_BUFF_IDS); "Battle Elixir" or "Guardian Elixir" alone is an elixir (ns.ELIXIR_BUFF_IDS). A buff is listed when an obtainable consumable reaches it: the item's use spell, a spell it triggers, or a spell its text quotes.
	- From Cataclysm on the stat scrolls say "This effect counts as a Battle Elixir" (Protection and Stamina say Guardian), so their buffs are in ns.ELIXIR_BUFF_IDS: on this client a scroll fills an elixir slot like any elixir. So do the Blasted Lands and Zul'Gurub buffs (R.O.I.D.S., Gizzard Gum, the Zanza potions), Oil of Olaf and Elixir of Water Walking, whose text now names a slot.
	- Two flasks pick their buff by script, so their buffs are listed by hand: Alchemist's Flask (75525) gives Enhanced Strength, Agility or Intellect (79638, 79639, 79640), by the drinker's highest stat; Flask of Battle (65455) gives one of 92725, 92729, 92730 and 92731, the four Cataclysm flask buffs re-issued under its own duration (its text quotes 92725's; the other three carry the same names and text as the Cataclysm flasks and sit beside it). The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked.
	- Left out for having no source (no drop, vendor or quest reward in QuestieDB's MoP item table and no spell that creates them): the Flaskataur's flasks (32764-32767, whose buffs are listed anyway through the real flasks), Jillian's Tonic of Pure Mojo (45007, same), Worg's Blood Elixir (37878), Scroll of Protection VIII (43468, buff 58453) and Crystal of Insanity (86569, buff 127230, Visions of Insanity). Deprecated Alchemy Elixir Template (36845) shares buff 11328 with Elixir of Agility, which is kept.
	- Crystal Force and Crystal Ward (11563, 11564; rewards for Un'Goro's crystal quests 24726 and 24728) and Burning Blossom's Fire Festival Fury (46352, Midsummer) name a Battle or Guardian Elixir in their text, so their buffs are listed. The Juju items (12450-12460) are left out: QuestieDB's MoP quest table marks the Winterspring quests that reward them unavailable (quest flag 0x4000) or lacks them.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopQuestDB.lua
]]
