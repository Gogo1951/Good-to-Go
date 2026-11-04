local _, ns = ...

-- [groupID] = base item of the series (the group's runtime display name)
ns.POISON_GROUP_BASE_ITEMS = {}

-- [ID] = {Required Level, Poison Group}, -- Item Name
ns.POISON_DATA = {}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Both tables are empty: this client has no rogue poison items. A rogue's poisons are spells in the Poisons flyout (SpellFlyout 66): Deadly Poison (2823), Wound Poison (8679), Crippling Poison (3408), Mind-numbing Poison (5761), and the talents Leeching Poison (108211) and Paralytic Poison (108215).
	- The old poison items are now Empty Poison Vials with no use (6947, 2892, 3775, 5237, 10918, 22054 and the rest), and Anesthetic Poison (21835) uses a spell (26785) this client doesn't have.
	- The Poisons macro (Features/Macros-for-Consumables/Macros/Tools-Rogues.lua) applies items, so it has nothing to apply here; it stays on its no-skill stub (POISONS_SPELL_ID in Game-IDs-Mists.lua).

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellFlyout?build=5.5.4.70631
	https://wago.tools/db2/SpellFlyoutItem?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631

QuestieDB
	None.
]]
