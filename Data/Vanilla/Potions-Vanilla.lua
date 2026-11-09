local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.POTIONS = {
	[18839] = { 700, 0, nil, nil, 35, 250, 5, 1 }, -- Combat Healing Potion
	[18841] = { 0, 900, nil, nil, 41, 275, 5, 1 }, -- Combat Mana Potion
	[23578] = { 0, 1350, nil, nil, 49, 0, 10, 0 }, -- Diet McWeaksauce
	[4596] = { 140, 0, nil, nil, 5, 25, 5, 0 }, -- Discolored Healing Potion
	[1072] = { 0, 280, nil, nil, 0, 62, 10, 0 }, -- Full Moonshine
	[1710] = { 455, 0, nil, nil, 21, 125, 5, 0 }, -- Greater Healing Potion
	[6149] = { 0, 700, nil, nil, 31, 120, 5, 0 }, -- Greater Mana Potion
	[929] = { 280, 0, nil, nil, 12, 75, 5, 0 }, -- Healing Potion
	[858] = { 140, 0, nil, nil, 3, 25, 5, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 280, nil, nil, 14, 30, 5, 0 }, -- Lesser Mana Potion
	[17348] = { 980, 0, { 1459, 1460, 1461 }, nil, 45, 250, 10, 1 }, -- Major Healing Draught
	[13446] = { 1050, 0, nil, nil, 45, 1000, 5, 0 }, -- Major Healing Potion
	[17351] = { 0, 980, { 1459, 1460, 1461 }, nil, 45, 250, 10, 1 }, -- Major Mana Draught
	[13444] = { 0, 1350, nil, nil, 49, 1500, 5, 0 }, -- Major Mana Potion
	[18253] = { 1440, 1440, nil, nil, 50, 15, 5, 0 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455, nil, nil, 22, 120, 5, 0 }, -- Mana Potion
	[118] = { 70, 0, nil, nil, 1, 5, 5, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140, nil, nil, 5, 10, 5, 0 }, -- Minor Mana Potion
	[2456] = { 90, 90, nil, nil, 5, 15, 5, 0 }, -- Minor Rejuvenation Potion
	[3087] = { 0, 140, nil, nil, 0, 11, 10, 0 }, -- Mug of Shimmer Stout
	[17349] = { 560, 0, { 1459, 1460, 1461 }, nil, 35, 125, 10, 1 }, -- Superior Healing Draught
	[3928] = { 700, 0, nil, nil, 35, 250, 5, 0 }, -- Superior Healing Potion
	[17352] = { 0, 560, { 1459, 1460, 1461 }, nil, 35, 125, 10, 1 }, -- Superior Mana Draught
	[13443] = { 0, 900, nil, nil, 41, 400, 5, 0 }, -- Superior Mana Potion
	[23579] = { 1050, 0, nil, nil, 45, 0, 10, 0 }, -- The McWeaksauce Classic
	-- Whipper Root Tuber (11951) is absent on purpose: its live row is in Healthstones-Vanilla.lua, sharing the Healthstone cooldown category.
	[9144] = { 1, 1, nil, nil, 35, 250, 5, 0 }, -- Wildvine Potion
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Classic Era 1.15.9.70576

Notes
	- Every potion this client knows that restores health or mana instantly on the potion cooldown, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Health Potion and Mana Potion macros. Healing Amount and Mana Amount are each effect's low end; requiredAlchemy is the Alchemy rank the tooltip requires.
	- Allowed Zones are uiMapIDs. The draughts' text says they work only in PvP battlegrounds: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin.
	- Holy Spring Water (737) is left out on purpose, an oddball on the potion cooldown. Potions that do something else (rage, speed, protection, invisibility) are not in this table. Deprecated Potion of Lesser Invulnerability (Fix) (2462) is a placeholder nothing drops, sells or makes.
	- Wildvine Potion's 0 to 1,500 health and mana is entered as 1 and 1, so it ranks below every other potion.
	- Season of Discovery items are left out even though this client knows their IDs: they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70576
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003
	https://wago.tools/db2/SpellCastingRequirements?build=1.15.9.70003
	https://wago.tools/db2/AreaGroupMember?build=1.15.9.70003
	https://wago.tools/db2/UiMapAssignment?build=1.15.9.70003
	https://wago.tools/db2/SpellName?build=1.15.9.70576

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicItemDB.lua
]]
