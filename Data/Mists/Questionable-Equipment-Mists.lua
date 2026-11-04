local _, ns = ...

-- [itemID] = true, -- Item Name
ns.QUESTIONABLE_EQUIPMENT = {
	[11122] = true, -- Carrot on a Stick
	[25653] = true, -- Riding Crop
	[32863] = true, -- Skybreaker Whip
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Items that are fine to own and wrong to be wearing when a pull starts, read by the Non-combat Gear Equipped check in Features/Readiness-Report/Readiness-Report-Probes.lua.
	- This table is the exceptions, not the list. Nearly everything worth catching is a whole weapon subclass (every fishing pole, mining pick and skinning knife, the tournament lances), and the check answers those from the equipped item's own class and subclass, so they need no rows here. What is left is the handful that share a subclass with real gear: trinkets. No property tells a mount-speed trinket from a raid trinket, so those are named.
	- The mount-speed trinkets on this client: every trinket whose equip spell is Mount Speed (48776, 48777). Each has a source (Riding Crop is crafted, the other two are quest rewards in QuestieDB's MoP item table). Their text says they stop working above level 70, which makes them no better to wear at a pull.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
