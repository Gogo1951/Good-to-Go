local _, ns = ...

-- [ID] = {Min Damage, Max Damage, Engineering Skill, Required Spell ID, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.EXPLOSIVES = {
	[4380] = { 85, 115, 140, nil, 0, 500, 10, 0 }, -- Big Bronze Bomb
	[4394] = { 149, 201, 190, nil, 0, 750, 10, 0 }, -- Big Iron Bomb
	[4365] = { 51, 69, 75, nil, 0, 75, 20, 0 }, -- Coarse Dynamite
	[16005] = { 225, 675, 285, nil, 0, 1250, 10, 0 }, -- Dark Iron Bomb
	[18641] = { 340, 460, 250, nil, 0, 500, 20, 0 }, -- Dense Dynamite
	[6714] = { 51, 69, 0, nil, 10, 75, 20, 0 }, -- Ez-Thro Dynamite
	[18588] = { 213, 287, 0, nil, 30, 200, 20, 0 }, -- Ez-Thro Dynamite II
	[10646] = { 450, 750, 205, nil, 0, 500, 10, 0 }, -- Goblin Sapper Charge
	[4378] = { 128, 172, 125, nil, 0, 350, 20, 0 }, -- Heavy Dynamite
	[10562] = { 255, 345, 235, nil, 0, 750, 10, 0 }, -- Hi-Explosive Bomb
	[4390] = { 132, 218, 175, nil, 0, 500, 10, 0 }, -- Iron Grenade
	[4370] = { 43, 57, 105, nil, 0, 175, 10, 0 }, -- Large Copper Bomb
	[10514] = { 149, 201, 205, nil, 0, 750, 10, 0 }, -- Mithril Frag Bomb
	[4360] = { 22, 28, 30, nil, 0, 60, 10, 0 }, -- Rough Copper Bomb
	[4358] = { 26, 34, 1, nil, 0, 30, 20, 0 }, -- Rough Dynamite
	[4374] = { 73, 97, 120, nil, 0, 200, 10, 0 }, -- Small Bronze Bomb
	[10507] = { 213, 287, 175, nil, 0, 350, 20, 0 }, -- Solid Dynamite
	[10586] = { 340, 460, 225, nil, 0, 750, 10, 0 }, -- The Big One
	[15993] = { 300, 500, 260, nil, 0, 1500, 10, 0 }, -- Thorium Grenade
	[260792] = { 26, 34, 0, nil, 1, 75, 20, 0 }, -- SAF-T Dynamite
	[260793] = { 22, 28, 0, nil, 1, 60, 10, 0 }, -- SAF-T Copper Bomb
	[260795] = { 43, 57, 0, nil, 1, 175, 10, 0 }, -- EZ-Thro Copper Bomb XL
	[260797] = { 73, 97, 0, nil, 1, 200, 10, 0 }, -- SAF-T Bronze Bomb
	[260798] = { 128, 172, 0, nil, 1, 350, 20, 0 }, -- SAF-T Jumbo Dynamite
	[260803] = { 213, 287, 0, nil, 1, 350, 20, 0 }, -- EZ-Thro Grenade
	[260805] = { 149, 201, 0, nil, 1, 750, 10, 0 }, -- SAF-T Bomb
	[260809] = { 149, 201, 0, nil, 1, 750, 10, 0 }, -- Tru-Trigger Frag Bomb
	[260814] = { 340, 460, 0, nil, 1, 500, 20, 0 }, -- SAF-T Clever Dynamite
	[260816] = { 300, 500, 0, nil, 1, 1500, 10, 0 }, -- EZ-Thro Thorium Grenade
	[260817] = { 225, 675, 0, nil, 1, 1250, 10, 0 }, -- EZ-Thro Dark Bomb
	[284868] = { 300, 500, 0, nil, 0, 1500, 10, 1 }, -- Holy Hand Grenade of Alterac
}

--[[
How We Got the Data

Last Validated
	2026-11-08, WoW Forever 1.60.1.70862

Notes
	- Every Engineering explosive this client knows that deals damage, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Explosive macro. The family is the items sharing Coarse Dynamite's (4365) use category, which on this client is class 0, subclass 0.
	- Min Damage and Max Damage are the use spell's damage range. Engineering Skill is the rank the tooltip requires (0 for none). Required Spell ID, where present, is the Goblin or Gnomish specialization the item needs; no row on this client carries one.
	- Items that share the explosive cooldown but aren't crafted explosives are left out: the Portable Bronze Mortar (a reusable device), Goblin Fishing Pole, Flash Bundle, Explosive Rocket, Magic Candle, Brimstone, Fertile Bulb, M73 Frag Grenade, and the quest items (Crystal Charge, the Holy Waters).
	- Damage on this client is the base points times one plus or minus half the variance, rounded (Rough Dynamite's 25.9999996 is 26). The Scrolls of Cryoblast and Greater Cryoblast (217495, 277499) are left out: they are scrolls, not explosives.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

	SELECT CONCAT(
	    '[', entry, '] = {',
	    MinDamage, ', ', MaxDamage, ', ', RequiredSkillRank,
	    CASE WHEN requiredspell <> 0 THEN CONCAT(', ', requiredspell) ELSE '' END,
	    '}, -- ', name
	) AS LuaLine
	FROM (
	    SELECT
	      i.entry, i.name, i.RequiredSkillRank, i.requiredspell,
	      CASE
	        WHEN s.Effect1 = 2 THEN s.EffectBasePoints1 + 1
	        WHEN s.Effect2 = 2 THEN s.EffectBasePoints2 + 1
	        WHEN s.Effect3 = 2 THEN s.EffectBasePoints3 + 1
	      END AS MinDamage,
	      CASE
	        WHEN s.Effect1 = 2 THEN s.EffectBasePoints1 + s.EffectDieSides1
	        WHEN s.Effect2 = 2 THEN s.EffectBasePoints2 + s.EffectDieSides2
	        WHEN s.Effect3 = 2 THEN s.EffectBasePoints3 + s.EffectDieSides3
	      END AS MaxDamage
	    FROM item_template i
	    JOIN spell_template s ON s.Id = i.spellid_1
	    JOIN (
	        SELECT spellcategory_1 AS cat, class AS cls, subclass AS sub
	        FROM item_template WHERE entry = 4365
	    ) ref
	      ON i.spellcategory_1 = ref.cat AND i.class = ref.cls AND i.subclass = ref.sub
	    WHERE i.name NOT LIKE '%Test%'
	      AND i.name NOT LIKE '%[PH]%'
	      AND (s.Effect1 = 2 OR s.Effect2 = 2 OR s.Effect3 = 2)
	) t
	ORDER BY name;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70450
	https://wago.tools/db2/ItemSparse?build=1.60.1.70450
	https://wago.tools/db2/ItemEffect?build=1.60.1.70450
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70450
	https://wago.tools/db2/Spell?build=1.60.1.70450
	https://wago.tools/db2/SpellEffect?build=1.60.1.70450
	https://wago.tools/db2/SpellMisc?build=1.60.1.70450
	https://wago.tools/db2/SpellDuration?build=1.60.1.70450
	https://wago.tools/db2/Item?build=1.60.1.70862
	https://wago.tools/db2/ItemSparse?build=1.60.1.70862
	https://wago.tools/db2/ItemEffect?build=1.60.1.70862
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70862
	https://wago.tools/db2/SpellEffect?build=1.60.1.70862

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Forever/foreverItemDB.lua
]]
