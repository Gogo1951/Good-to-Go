local _, ns = ...

-- [groupID] = base item of the series (the group's runtime display name)
ns.POISON_GROUP_BASE_ITEMS = {}

-- [ID] = {Required Level, Poison Group}, -- Item Name
ns.POISON_DATA = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Declared empty because Retail ships no TOC yet, so feature code can read the tables without checking which flavor built it. The rows come when this flavor's data is built from a Validate Data report on a Retail client.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
