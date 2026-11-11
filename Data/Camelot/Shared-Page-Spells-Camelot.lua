local _, ns = ...

-- [pageTag] = { spellId or { spellId, ... }, ... }, -- Spell Name
ns.SHARED_PAGE_SPELLS = {
	racials = {
		20600, -- Perception
		1259718, -- Will to Survive
		20594, -- Stoneform
		2481, -- Find Treasure
		20580, -- Shadowmeld
		20589, -- Escape Artist
		1259812, -- Eureka!
		20572, -- Blood Fury
		7744, -- Will of the Forsaken
		20577, -- Cannibalize
		20549, -- War Stomp
		20554, -- Berserking
		1260270, -- Rapid Regeneration
	},
	professions = {
		2259, -- Alchemy
		2018, -- Blacksmithing
		7411, -- Enchanting
		4036, -- Engineering
		2108, -- Leatherworking
		3908, -- Tailoring
		2550, -- Cooking
		3273, -- First Aid
		7620, -- Fishing
		2366, -- Herbalism
		2575, -- Mining
		2656, -- Smelting
		8613, -- Skinning
		13262, -- Disenchant
		818, -- Basic Campfire
		20219, -- Gnomish Engineer
		20222, -- Goblin Engineer
		10656, -- Dragonscale Leatherworking
		10658, -- Elemental Leatherworking
		10660, -- Tribal Leatherworking
		9787, -- Weaponsmith
		9788, -- Armorsmith
		17039, -- Master Swordsmith
		17040, -- Master Hammersmith
		17041, -- Master Axesmith
	},
	tracking = {
		2383, -- Find Herbs
		2580, -- Find Minerals
		43308, -- Find Fish
		1494, -- Track Beasts
		{ 19883, 5225 }, -- Track Humanoids
		19884, -- Track Undead
		19885, -- Track Hidden
		19880, -- Track Elementals
		19878, -- Track Demons
		19882, -- Track Giants
		19879, -- Track Dragonkin
		5502, -- Sense Undead
		5500, -- Sense Demons
	},
	-- the melee swing the General tab lists, which the game doesn't call harmful
	attacks = {
		6603, -- Attack
	},
}

-- { professionSpellId, specializationSpellId, ... }, -- Profession: Specializations
ns.PROFESSION_SPECIALIZATIONS = {
	{ 4036, 20219, 20222 }, -- Engineering: Gnomish Engineer, Goblin Engineer
	{ 2018, 9788, 9787, 17039, 17040, 17041 }, -- Blacksmithing: Armorsmith, Weaponsmith, Master Swordsmith, Master Hammersmith, Master Axesmith
	{ 2108, 10656, 10658, 10660 }, -- Leatherworking: Dragonscale, Elemental, Tribal Leatherworking
}

--[[
How We Got the Data

Last Validated
	2026-11-11, WoW Forever 1.60.1.70888

Notes
	- SHARED_PAGE_SPELLS holds the spells every class shares, which the Spell Book page files under its own headings whatever their spellbook tab: each race's spells (racials, which Sort By Category gives a Racials section), the profession and tracking spells the General tab lists (professions, tracking), and its Attack (attacks). ns.PageCategory and the page-tag lookup in Features/Enhanced-Spellbook/Macro-Builder/Macro-Builder.lua read it.
	- An entry is a spell ID, or a list of the IDs one spell has across clients. Each is matched by name, so an ID this client doesn't have is skipped.
	- PROFESSION_SPECIALIZATIONS lists each profession's spell, then its specializations: passives the spellbook lists beside the profession that do nothing when cast. When one is learned, the page shows the profession's macro under the specialization's name and icon ("Goblin Engineer", still opening Engineering) and leaves the specialization's own off. A later one in the row wins, so a Master Swordsmith beats the Weaponsmith it builds on. FoldSpecializations in Features/Enhanced-Spellbook/Macro-Builder/Macro-Builder.lua reads it.
	- The rows began as one shared table copied to every folder. This client's Validate Data report pruned the IDs it doesn't have: the later expansions' racials, professions and profession spells, and the Alchemy and Tailoring specializations, which leaves those two professions out of PROFESSION_SPECIALIZATIONS.
	- WoW Forever's own racials, from the racial skill lines in this client's SkillLineAbility on wago.tools: Will to Survive (Human), Eureka! (Gnome) and Rapid Regeneration (Troll). Eureka! has one spell per power type (1259812, 1259813, 1259817, 1259821, 1259823), all named alike, so one ID matches them all.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.60.1.70862
	https://wago.tools/db2/Spell?build=1.60.1.70862
	https://wago.tools/db2/SpellMisc?build=1.60.1.70862
	https://wago.tools/db2/SpellCooldowns?build=1.60.1.70862
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70862
	https://wago.tools/db2/SkillLine?build=1.60.1.70862

QuestieDB
	None.
]]
