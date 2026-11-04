local _, ns = ...

-- [ID] = {Min Damage, Max Damage, Engineering Skill, Required Spell ID}, -- Name
ns.EXPLOSIVES = {
	[23737] = { 450, 750, 325 }, -- Adamantite Grenade
	[4380] = { 89, 121, 140 }, -- Big Bronze Bomb
	[63396] = { 3750, 6250, 440, 20222 }, -- Big Daddy
	[4394] = { 155, 210, 190 }, -- Big Iron Bomb
	[4365] = { 89, 89, 75 }, -- Coarse Dynamite
	[40771] = { 75, 100, 330 }, -- Cobalt Frag Bomb
	[16005] = { 63, 189, 285 }, -- Dark Iron Bomb
	[18641] = { 345, 467, 250 }, -- Dense Dynamite
	[6714] = { 69, 93, 0 }, -- Ez-Thro Dynamite
	[18588] = { 212, 288, 0 }, -- Ez-Thro Dynamite II
	[23736] = { 330, 770, 300 }, -- Fel Iron Bomb
	[32413] = { 75, 125, 325 }, -- Frost Grenade
	[42641] = { 2188, 2813, 400, 20222 }, -- Global Thermal Sapper Charge
	[10646] = { 452, 754, 205 }, -- Goblin Sapper Charge
	[4378] = { 150, 150, 125 }, -- Heavy Dynamite
	[10562] = { 255, 345, 235 }, -- Hi-Explosive Bomb
	[4390] = { 133, 221, 175 }, -- Iron Grenade
	[4370] = { 43, 59, 105 }, -- Large Copper Bomb
	[10514] = { 176, 176, 205 }, -- Mithril Frag Bomb
	[4360] = { 25, 35, 30 }, -- Rough Copper Bomb
	[4358] = { 76, 104, 1 }, -- Rough Dynamite
	[41119] = { 1149, 1501, 350 }, -- Saronite Bomb
	[4374] = { 71, 96, 120 }, -- Small Bronze Bomb
	[10507] = { 215, 291, 175 }, -- Solid Dynamite
	[23827] = { 900, 1500, 340 }, -- Super Sapper Charge
	[10586] = { 343, 464, 225 }, -- The Big One
	[23826] = { 600, 1000, 325 }, -- The Bigger One
	[15993] = { 299, 499, 260 }, -- Thorium Grenade
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Every Engineering explosive this client knows that deals damage, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) for the Explosive macro. The family is the items sharing Coarse Dynamite's (4365) use category (24) and its class and subclass (Trade Goods, Explosives).
	- Min Damage and Max Damage are the use spell's damage range: the effect's value times one minus and one plus half its variance. From Cataclysm on the value is scaled, the coefficient times the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel. Engineering Skill is the Engineering rank the item requires (0 for none).
	- Required Spell ID is the specialization the item needs: Goblin Engineer (20222) for the Global Thermal Sapper Charge and Big Daddy.
	- Items in the family that deal no damage are left out: Explosive Sheep, Goblin Land Mine, Flash Bomb, Arcane Bomb, Gnomish Flame Turret, Saronite Grenade, Explosive Decoy and The Naked Bomb. Test Sapper Charge (23418) and Ninja Grenade [PH] (35499) are test items. Shrapnel Grenade (44598) and Crafty Bomb (50422) have no source: no drop, vendor or quest reward in QuestieDB's MoP item table and no spell that creates them.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellScaling?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
