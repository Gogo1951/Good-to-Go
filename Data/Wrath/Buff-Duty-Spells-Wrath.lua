local _, ns = ...

-- Whether Well Fed and Scrolls show on the Self-Buffs list When Missing by default (else Off).
ns.BUFF_DUTY_ITEM_BUFFS_SHOWN = false

-- { class, single = { { spell id, level learned } }, group = { spell ids }, greater = { spell ids }, exclusive, manaOnly, noCasters, talent, noAsk, default, selfDefault }, -- Name
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

-- The weapon items whose enchant goes in the imbue layer. None here: a weapon holds one temporary enchant on this client.
ns.BUFF_DUTY_WEAPON_IMBUE_ITEMS = {}

-- { item id, auras = { spell ids }, default (minutes left, MISSING or OFF) }, -- Name
ns.BUFF_DUTY_SELF_ITEMS = {}

-- { class, create = { { spell id, level learned } }, auras, items = { { item id, level its create rank is learned } }, default }
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
