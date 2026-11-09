local _, ns = ...

ns.CONJURE_SPELLS = {
	MageCreateTable = {
		-- {Spell ID, Spell Learn Level}
		{ 43987, 72 }, -- Conjure Refreshment Table
	},
	MageCreateWater = {
		-- {Spell ID, Conjured Item Usage Level}, -- Spell Name
		{ 42955, 38 }, -- Conjure Refreshment
	},
	MageCreateFood = {
		-- {Spell ID, Conjured Item Usage Level}, -- Spell Name
		{ 42955, 38 }, -- Conjure Refreshment
	},
	MageCreateManaGem = {
		-- {Spell ID, Spell Learn Level}, -- Spell Name
		{ 759, 47 }, -- Conjure Mana Gem
	},
	WarlockCreateSoulwell = {
		-- {Spell ID, Spell Learn Level}
		{ 29893, 68 }, -- Create Soulwell
	},
	WarlockCreateHealthstone = {
		-- {Spell ID, Conjured Item Usage Level}, -- Conjured Item
		{ 6201, 1 }, -- Healthstone
	},
	WarlockCreateSoulstone = {
		-- {Spell ID, Spell Learn Level}, -- Spell Name
		{ 20707, 18 }, -- Soulstone
	},
}

ns.MISSING_SPELL_MESSAGE_IDS = {
	-- Mage conjures
	noConjureWater = 42955, -- Conjure Refreshment
	noConjureFood = 42955, -- Conjure Refreshment
	noConjureManaGem = 759, -- Conjure Mana Gem
	noRitualOfRefreshment = 43987, -- Conjure Refreshment Table
	-- Warlock conjures
	noCreateHealthstone = 6201, -- Create Healthstone
	noCreateSoulstone = 20707, -- Soulstone
	noRitualOfSouls = 29893, -- Create Soulwell
	-- Hunter pet spells
	noMendPet = 136, -- Mend Pet
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The mage and warlock conjure spells the macros cast, one list per conjure, read by Features/Macros-for-Consumables/Macros/Smart-Spell.lua (GetSmartSpell), the Food and Water macros, the class tools, the Readiness Report and the mini-map tooltip. Smart-Spell sorts each list by its level column, highest first, at load, so row order carries no meaning.
	- This client has no spell ranks: each conjure is one spell, the one on its class skill line (SkillLineAbility: mage 904, warlock 849), cast bare, so no row carries a rank column. Every level column is that spell's base level (SpellLevels) except Create Healthstone's, which is the level its stone needs (Healthstone, 5512, requires level 1).
	- Conjure Refreshment (42955) replaces Conjure Water and Conjure Food: it makes one conjured item that is both, chosen by the mage's level (the Conjure Refreshment spells that create items 34062, 43518, 43523, 65499, 65500, 65515, 65516, 65517, 80610 and 80618). So it fills both MageCreateWater and MageCreateFood, and a lower-level target cannot downrank it: with the target below 38, GetSmartSpell's fallback casts the same spell.
	- Conjure Mana Gem (759) creates Mana Gem (36799) directly. Conjure Refreshment Table (43987) is the old Ritual of Refreshment; Create Soulwell (29893) is the old Ritual of Souls (60429, on no skill line here).
	- Create Healthstone (6201) is a script effect; Create Healthstone 23517 and 120038 are the spells in this client's tables that create Healthstone (5512).
	- Soulstone (20707) is cast straight on a target and makes no item: it puts a 15-minute aura on the target (SpellEffect aura 4, SpellDuration 347). The warlock tools' right-click casts it bare, on the player's target.
	- ns.MISSING_SPELL_MESSAGE_IDS holds the spells GtGTip names at print time (Features/Macros-for-Consumables/Macros/Runtime.lua): one per conjure list, and Mend Pet. The rogue's Poisons skill (2842) is left out: this client doesn't have it, and a tip key with no entry prints nothing.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellDuration?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631

QuestieDB
	None.
]]
