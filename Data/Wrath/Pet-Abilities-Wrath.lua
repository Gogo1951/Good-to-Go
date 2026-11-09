local _, ns = ...

-- None: this client's pets have no Beast Training or grimoires to teach them abilities (Data/Vanilla/ has the format).
ns.PET_ABILITIES = {}
ns.PET_ABILITY_BEASTS = {}
ns.TAMEABLE_BEASTS = {}
ns.DEMON_ABILITIES = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- The hunter pet ability ranks and the warlock's demon ability ranks for the Pet What's Next? tab (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Pet.lua), which shows only where this table has rows.
	- Empty: from Wrath on a pet learns its abilities as it levels, with no training points, Beast Training or grimoires, and WoW Forever's pets are Retail's. Tamed has no data for Forever either.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
