local _, ns = ...

-- [ID] = {Mana Amount}, -- Name
ns.MANA_GEMS = {
	[36799] = { 1 }, -- Mana Gem
	[81901] = { 1 }, -- Brilliant Mana Gem
}

-- [ID] = {Mana Amount}, -- Name
ns.MANA_RUNES = {
	[20520] = { 900 }, -- Dark Rune
	[12662] = { 900 }, -- Demonic Rune
	[35287] = { 455 }, -- Luminous Bluetail
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- ns.MANA_GEMS holds the mage's mana gems, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Mana Gem macro and by the Readiness Report. Mana Gem (36799) is what Conjure Mana Gem (759) makes; Brilliant Mana Gem (81901) is what Conjure Mana Gem 119316 makes. Both restore through a scripted effect whose base points are 1 (5405 and 119313), so the column holds 1 for each and carries no ranking. A mage holds only one of the two.
	- ns.MANA_RUNES holds the Demonic and Dark Runes, which restore mana at the cost of life, and Luminous Bluetail. The Mana Gem macro ranks them in with the gems when the player opts in (Features/Macros-for-Consumables/Macros/Mana-Gem.lua). The mana column is the low end (base points 899 and 454, plus 1).
	- Unlike TBC, the gems and the runes no longer share a cooldown on this client: the gems are on "Item - Mana Gem" (SpellCategory 100), the runes and Luminous Bluetail on "Item - Combat Cons. (Non-Aggressive)" (1153). Their restores are also tiny at this client's mana pools. The rows stay so the include-runes option keeps working as on every other client.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellCategory?build=5.5.4.70631

QuestieDB
	None.
]]
