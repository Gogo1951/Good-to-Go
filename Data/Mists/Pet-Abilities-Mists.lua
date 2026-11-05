local _, ns = ...

ns.PET_ABILITIES = {}
ns.PET_ABILITY_BEASTS = {}
ns.TAMEABLE_BEASTS = {}
ns.DEMON_ABILITIES = {}

--[[
How We Got the Data

Last Validated
	2026-11-04, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The hunter pet ability ranks and the warlock's demon ability ranks for the Pet What's Next? tab (Features/Spellbook/Whats-Next/Whats-Next-Pet.lua), which shows only where this table has rows.
	- Empty: from Wrath on a pet learns its abilities as it levels, with no training points, Beast Training or grimoires to teach them, so this client has no rows. Data/Vanilla/Pet-Abilities-Vanilla.lua shows the row format.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
