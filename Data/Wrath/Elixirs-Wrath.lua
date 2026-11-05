local _, ns = ...

-- { [buffSpellID] = true }, -- Flask Name
ns.FLASK_BUFF_IDS = {}

-- { [buffSpellID] = true }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Declared empty because Wrath ships no TOC yet, so feature code can read the tables without checking which flavor built it. The rows come when this flavor's data is built from a Validate Data report on a Wrath client.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
