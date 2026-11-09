local _, ns = ...

-- { craftedItemID, { { reagentID, count }, ... } }, -- Crafted item
ns.POISON_RECIPES = {}

--[[
How We Got the Data

Last Validated
	2026-11-04, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Empty: this client has no poison crafting. The Poisons skill line (40) has no abilities, the TBC crafting spells are gone, and the poisons are spells rather than items (Poisons-Mists.lua).
	- Read by Features/Restocker/Restocker-Crafting-Reagents.lua, which then turns no shortfall into a reagent order.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/SpellName?build=5.5.4.70631

QuestieDB
	None.
]]
