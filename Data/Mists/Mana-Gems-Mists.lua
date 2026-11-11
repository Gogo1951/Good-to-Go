local _, ns = ...

-- [ID] = {Mana Amount, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.MANA_GEMS = {
	[36799] = { 42750, 0, 0, 1, 1 }, -- Mana Gem
	[81901] = { 42750, 0, 0, 1, 1 }, -- Brilliant Mana Gem
}

-- [ID] = {Mana Amount, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.MANA_RUNES = {
	[20520] = { 900, 0, 2000, 20, 0 }, -- Dark Rune
	[12662] = { 908, 0, 600, 20, 1 }, -- Demonic Rune
	[35287] = { 455, 55, 50, 20, 0 }, -- Luminous Bluetail
}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- ns.MANA_GEMS holds the mage's mana gems, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Mana Gem macro and by the Readiness Report. Mana Gem (36799) is what Conjure Mana Gem (759) makes; Brilliant Mana Gem (81901) is what Conjure Mana Gem 119316 makes. Both restore through a scripted effect whose base points are 1 (5405 and 119313), so the column holds the low end their text states, 42,750 each (Validate Data, build 5.5.4.70631), and neither outranks the other. A mage holds only one of the two.
	- ns.MANA_RUNES holds the Demonic and Dark Runes, which restore mana at the cost of life, and Luminous Bluetail. The Mana Gem macro ranks them in with the gems when the player opts in (Features/Macros-for-Consumables/Macros/Mana-Gem.lua). The mana column is the low end: the effect's value times one minus half its variance, the value scaled by the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel (Dark Rune 900, Demonic Rune 908, Luminous Bluetail 455).
	- Unlike TBC, the gems and the runes no longer share a cooldown on this client: the gems are on "Item - Mana Gem" (SpellCategory 100), the runes and Luminous Bluetail on "Item - Combat Cons. (Non-Aggressive)" (1153). Their restores are also tiny at this client's mana pools. The rows stay so the include-runes option keeps working as on every other client.
	- Left out of the mana gem cooldown (SpellCategory 100): Mana Jade (5513), Mana Citrine (8007), Mana Ruby (8008) and Mana Sapphire (33312), with no source in QuestieDB's MoP item table and no spell that creates them; Mana Emerald (22044), made only by a test spell (44587); and Mana Agate (5514), an armor record on this client whose one QuestieDB source, a drop from Vultros (462), is unlikely for a conjured gem.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellScaling?build=5.5.4.70631
	https://wago.tools/db2/SpellCategory?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
