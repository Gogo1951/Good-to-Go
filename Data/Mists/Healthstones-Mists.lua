local _, ns = ...

-- [ID] = {Healthstone Amount, Required Level}, -- Name
ns.HEALTHSTONES = {
	[5512] = { 20, 1 }, -- Healthstone
}

--[[
How We Got the Data

Last Validated
	2026-11-04, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Every item that heals instantly on the healthstone cooldown, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Healthstone and Health Potion macros. Required Level is the level the tooltip requires (0 for none).
	- On this client the healthstone cooldown is the "Item - Healing" category (SpellCategory 30), not the one Charged Crystal Focus uses (now 1153, "Item - Combat Cons. (Non-Aggressive)"), so the list was rebuilt from category 30 (ItemEffect.SpellCategoryID).
	- Healthstone (5512) is the warlock's only stone here. Its heal (6262) has base points 20, which on this client is a share of maximum health rather than a flat amount; the column holds 20. It ranks only against other healthstones, of which there are none.
	- Left out of category 30: Orb of Life (82460, a 60% heal whose source is unverified), Mummified Eye (82463, no heal effect) and DEPRECATED Flame Red Ejector Seat (40754).

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
