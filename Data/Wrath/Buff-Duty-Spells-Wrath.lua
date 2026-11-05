local _, ns = ...

-- { class, single = { { spell id, level learned } }, group = { spell ids }, greater = { spell ids }, exclusive, manaOnly, noCasters, talent, default }, -- Name
ns.BUFF_DUTY_SPELLS = {}

-- { beast = spell id, demons = { [npc id] = spell id } }: the icon a pet's row wears, from its summoning spell
ns.BUFF_DUTY_PET_ICONS = {}

-- { class, ranks = { { spell id, level learned } }, auras, exclusive, needsPet, default (minutes left, MISSING or OFF) }, -- Name
ns.BUFF_DUTY_SELF_SPELLS = {}

-- { class, duration (minutes), ranks = { { spell id, level learned, enchant id } } or items = { { item id, level required, enchant id } } }, -- Name
ns.BUFF_DUTY_WEAPON_ENCHANTS = {}

ns.BUFF_DUTY_WEAPON_HANDS = {}

-- { item id, level required, enchant id, weapon types, kind, item level, zones }, -- Name
ns.BUFF_DUTY_WEAPON_ITEMS = {}

-- { class, create = { { spell id, level learned } }, auras, items (lowest rank first), default }
ns.BUFF_DUTY_SOULSTONE = {}

-- { class, ranks = { spell ids } }, -- Name
ns.BUFF_DUTY_RESURRECTIONS = {}

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
