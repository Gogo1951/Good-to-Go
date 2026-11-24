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

-- { [buffSpellID] = "BATTLE" or "GUARDIAN" }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[54452] = "BATTLE", -- Adept's Elixir
	[11390] = "BATTLE", -- Arcane Elixir
	[45373] = "BATTLE", -- Bloodberry Elixir
	[46352] = "BATTLE", -- Burning Blossom (Fire Festival Fury)
	[12608] = "GUARDIAN", -- Catseye Elixir
	[10692] = "GUARDIAN", -- Cerebral Cortex Compound
	[15231] = "BATTLE", -- Crystal Force
	[15233] = "GUARDIAN", -- Crystal Ward
	[109933] = "BATTLE", -- Darkmoon Firewater
	[39626] = "GUARDIAN", -- Earthen Elixir
	[60340] = "BATTLE", -- Elixir of Accuracy
	[11328] = "BATTLE", -- Elixir of Agility
	[80532] = "BATTLE", -- Elixir of Armor Piercing
	[17537] = "BATTLE", -- Elixir of Brute Force
	[60341] = "BATTLE", -- Elixir of Deadly Strikes
	[79480] = "GUARDIAN", -- Elixir of Deep Earth
	[3220] = "GUARDIAN", -- Elixir of Defense
	[11406] = "BATTLE", -- Elixir of Demonslaying
	[39627] = "BATTLE", -- Elixir of Draenic Wisdom
	[134870] = "BATTLE", -- Elixir of Empowerment
	[60344] = "BATTLE", -- Elixir of Expertise
	[7844] = "BATTLE", -- Elixir of Firepower
	[3593] = "GUARDIAN", -- Elixir of Fortitude
	[21920] = "BATTLE", -- Elixir of Frost Power
	[8212] = "BATTLE", -- Elixir of Giant Growth
	[11405] = "BATTLE", -- Elixir of Giants
	[11334] = "BATTLE", -- Elixir of Greater Agility
	[11349] = "GUARDIAN", -- Elixir of Greater Defense
	[26276] = "BATTLE", -- Elixir of Greater Firepower
	[11396] = "BATTLE", -- Elixir of Greater Intellect
	[28491] = "BATTLE", -- Elixir of Healing Power
	[79481] = "BATTLE", -- Elixir of Impossible Accuracy
	[39628] = "GUARDIAN", -- Elixir of Ironskin
	[3160] = "BATTLE", -- Elixir of Lesser Agility
	[60346] = "BATTLE", -- Elixir of Lightning Speed
	[2367] = "BATTLE", -- Elixir of Lion's Strength
	[54494] = "BATTLE", -- Elixir of Major Agility
	[28502] = "GUARDIAN", -- Elixir of Major Defense
	[28501] = "BATTLE", -- Elixir of Major Firepower
	[39625] = "GUARDIAN", -- Elixir of Major Fortitude
	[28493] = "BATTLE", -- Elixir of Major Frost Power
	[28509] = "BATTLE", -- Elixir of Major Mageblood
	[28503] = "BATTLE", -- Elixir of Major Shadow Power
	[28490] = "BATTLE", -- Elixir of Major Strength
	[33726] = "BATTLE", -- Elixir of Mastery
	[28497] = "BATTLE", -- Elixir of Mighty Agility
	[60343] = "GUARDIAN", -- Elixir of Mighty Defense
	[53751] = "GUARDIAN", -- Elixir of Mighty Fortitude
	[53764] = "BATTLE", -- Elixir of Mighty Mageblood
	[79632] = "BATTLE", -- Elixir of Mighty Speed
	[53748] = "BATTLE", -- Elixir of Mighty Strength
	[60347] = "GUARDIAN", -- Elixir of Mighty Thoughts
	[63729] = "BATTLE", -- Elixir of Minor Accuracy
	[2374] = "BATTLE", -- Elixir of Minor Agility
	[673] = "GUARDIAN", -- Elixir of Minor Defense
	[2378] = "GUARDIAN", -- Elixir of Minor Fortitude
	[105687] = "GUARDIAN", -- Elixir of Mirrors
	[3164] = "BATTLE", -- Elixir of Ogre's Strength
	[105685] = "BATTLE", -- Elixir of Peace
	[105686] = "BATTLE", -- Elixir of Perfection
	[53763] = "GUARDIAN", -- Elixir of Protection
	[11474] = "BATTLE", -- Elixir of Shadow Power
	[53747] = "BATTLE", -- Elixir of Spirit
	[11348] = "GUARDIAN", -- Elixir of Superior Defense
	[79477] = "BATTLE", -- Elixir of the Cobra
	[79635] = "BATTLE", -- Elixir of the Master
	[17538] = "BATTLE", -- Elixir of the Mongoose
	[79474] = "BATTLE", -- Elixir of the Naga
	[105684] = "BATTLE", -- Elixir of the Rapids
	[17535] = "BATTLE", -- Elixir of the Sages
	[11319] = "GUARDIAN", -- Elixir of Water Walking
	[105683] = "BATTLE", -- Elixir of Weaponry
	[3166] = "BATTLE", -- Elixir of Wisdom
	[38954] = "BATTLE", -- Fel Strength Elixir
	[79468] = "BATTLE", -- Ghost Elixir
	[11371] = "GUARDIAN", -- Gift of Arthas
	[10693] = "BATTLE", -- Gizzard Gum
	[29348] = "GUARDIAN", -- Goldenmist Special Brew
	[17539] = "BATTLE", -- Greater Arcane Elixir
	[10669] = "BATTLE", -- Ground Scorpok Assay
	[53749] = "BATTLE", -- Guru's Elixir
	[10668] = "GUARDIAN", -- Lung Juice Cocktail
	[105682] = "BATTLE", -- Mad Hozen Elixir
	[24363] = "BATTLE", -- Mageblood Elixir
	[3223] = "GUARDIAN", -- Major Troll's Blood Elixir
	[105681] = "GUARDIAN", -- Mantid Elixir
	[24361] = "GUARDIAN", -- Mighty Troll's Blood Elixir
	[105688] = "BATTLE", -- Monk's Elixir
	[54497] = "GUARDIAN", -- Oil of Olaf
	[33720] = "BATTLE", -- Onslaught Elixir
	[134873] = "GUARDIAN", -- Prismatic Elixir
	[10667] = "BATTLE", -- R.O.I.D.S.
	[8115] = "BATTLE", -- Scroll of Agility
	[8116] = "BATTLE", -- Scroll of Agility II
	[8117] = "BATTLE", -- Scroll of Agility III
	[12174] = "BATTLE", -- Scroll of Agility IV
	[89343] = "BATTLE", -- Scroll of Agility IX
	[33077] = "BATTLE", -- Scroll of Agility V
	[43194] = "BATTLE", -- Scroll of Agility VI
	[58450] = "BATTLE", -- Scroll of Agility VII
	[58451] = "BATTLE", -- Scroll of Agility VIII
	[8096] = "BATTLE", -- Scroll of Intellect
	[8097] = "BATTLE", -- Scroll of Intellect II
	[8098] = "BATTLE", -- Scroll of Intellect III
	[12176] = "BATTLE", -- Scroll of Intellect IV
	[89347] = "BATTLE", -- Scroll of Intellect IX
	[33078] = "BATTLE", -- Scroll of Intellect V
	[43195] = "BATTLE", -- Scroll of Intellect VI
	[48099] = "BATTLE", -- Scroll of Intellect VII
	[48100] = "BATTLE", -- Scroll of Intellect VIII
	[8091] = "GUARDIAN", -- Scroll of Protection
	[8094] = "GUARDIAN", -- Scroll of Protection II
	[8095] = "GUARDIAN", -- Scroll of Protection III
	[12175] = "GUARDIAN", -- Scroll of Protection IV
	[89344] = "GUARDIAN", -- Scroll of Protection IX
	[33079] = "GUARDIAN", -- Scroll of Protection V
	[43196] = "GUARDIAN", -- Scroll of Protection VI
	[58452] = "GUARDIAN", -- Scroll of Protection VII
	[8112] = "BATTLE", -- Scroll of Spirit
	[8113] = "BATTLE", -- Scroll of Spirit II
	[8114] = "BATTLE", -- Scroll of Spirit III
	[12177] = "BATTLE", -- Scroll of Spirit IV
	[89342] = "BATTLE", -- Scroll of Spirit IX
	[33080] = "BATTLE", -- Scroll of Spirit V
	[43197] = "BATTLE", -- Scroll of Spirit VI
	[48103] = "BATTLE", -- Scroll of Spirit VII
	[48104] = "BATTLE", -- Scroll of Spirit VIII
	[8099] = "GUARDIAN", -- Scroll of Stamina
	[8100] = "GUARDIAN", -- Scroll of Stamina II
	[8101] = "GUARDIAN", -- Scroll of Stamina III
	[12178] = "GUARDIAN", -- Scroll of Stamina IV
	[89345] = "GUARDIAN", -- Scroll of Stamina IX
	[33081] = "GUARDIAN", -- Scroll of Stamina V
	[43198] = "GUARDIAN", -- Scroll of Stamina VI
	[48101] = "GUARDIAN", -- Scroll of Stamina VII
	[48102] = "GUARDIAN", -- Scroll of Stamina VIII
	[8118] = "BATTLE", -- Scroll of Strength
	[8119] = "BATTLE", -- Scroll of Strength II
	[8120] = "BATTLE", -- Scroll of Strength III
	[12179] = "BATTLE", -- Scroll of Strength IV
	[89346] = "BATTLE", -- Scroll of Strength IX
	[33082] = "BATTLE", -- Scroll of Strength V
	[43199] = "BATTLE", -- Scroll of Strength VI
	[58448] = "BATTLE", -- Scroll of Strength VII
	[58449] = "BATTLE", -- Scroll of Strength VIII
	[24417] = "GUARDIAN", -- Sheen of Zanza
	[33721] = "BATTLE", -- Spellpower Elixir
	[24382] = "BATTLE", -- Spirit of Zanza
	[3222] = "GUARDIAN", -- Strong Troll's Blood Elixir
	[24383] = "GUARDIAN", -- Swiftness of Zanza
	[3219] = "GUARDIAN", -- Weak Troll's Blood Elixir
	[17038] = "BATTLE", -- Winterfall Firewater
	[53746] = "BATTLE", -- Wrath Elixir
}

--[[
How We Got the Data

Last Validated
	2026-11-24, wago.tools, Mists of Pandaria Classic 5.5.4.71089

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. The report reads only whether a buff is in a table, never its value.
	- Each elixir row's value is the slot its buff fills: "BATTLE" or "GUARDIAN". Buff Duty reads it to hide an elixir in the bags when a buff already on the player fills that slot; a flask fills both, so ns.FLASK_BUFF_IDS keeps plain true. The slot can't be read off an aura at runtime, which is why it is stored. It is the slot the buff spell's own text names on this client (Spell, 5.5.4.71060, checked 2026-11-22): every one of the 153 buffs names exactly one, 104 Battle and 49 Guardian, so none rests on another source. Scrolls of Protection and Stamina are Guardian, the other scrolls Battle. Nine buffs that are Guardian in Data/TBC/ are Battle here, the Intellect, Spirit and mana-regeneration ones, and take this client's word: Crystal Force, Elixir of Draenic Wisdom, Elixir of Greater Intellect, Elixir of Major Mageblood, Elixir of the Sages, Elixir of Wisdom, Gizzard Gum, Mageblood Elixir and Spirit of Zanza.
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
	https://wago.tools/db2/SpellName?build=5.5.4.70960
	https://wago.tools/db2/Spell?build=5.5.4.70960
	https://wago.tools/db2/SpellMisc?build=5.5.4.70960
	https://wago.tools/db2/SpellEffect?build=5.5.4.70960
	https://wago.tools/db2/SpellLevels?build=5.5.4.70960
	https://wago.tools/db2/SpellName?build=5.5.4.71060
	https://wago.tools/db2/Spell?build=5.5.4.71060
	https://wago.tools/db2/ItemEffect?build=5.5.4.71060
	https://wago.tools/db2/SpellName?build=5.5.4.71089

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopQuestDB.lua
]]
