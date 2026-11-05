local _, ns = ...

-- { kind, diet / group / reagent, tiers = { { minLevel, itemID, rank }, -- Name } }
ns.CONSUMABLE_UPGRADE_CHAINS = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Declared empty because Wrath ships no TOC yet, so feature code can read the table without checking which flavor built it. The rows come when this flavor's data is built from a Validate Data report on a Wrath client.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
