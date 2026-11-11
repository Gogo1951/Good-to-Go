local _, ns = ...

-- [itemID] = true, -- Item Name
ns.QUESTIONABLE_EQUIPMENT = {
	[11122] = true, -- Carrot on a Stick
	[25653] = true, -- Riding Crop
	[32481] = true, -- Charm of Swift Flight
	[32863] = true, -- Skybreaker Whip
}

--[[
How We Got the Data

Last Validated
	2026-11-11, TBC Anniversary 2.5.6.70577

Notes
	- Items that are fine to own and wrong to be wearing when a pull starts, read by the Non-combat Gear Equipped check in Features/Readiness-Report/Readiness-Report-Probes.lua.
	- This table is the exceptions, not the list. Nearly everything worth catching is a whole weapon subclass (every fishing pole, mining pick and skinning knife, the tournament lances), and the check answers those from the equipped item's own class and subclass, so they need no rows here and a pole added later is covered the day it ships. What is left is the handful that share a subclass with real gear: trinkets. No property tells a mount-speed trinket from a raid trinket, so those are named.
	- The named trinkets are every trinket (InventoryType 12) whose equip spell raises mounted or flight-form speed on this build (SpellEffect auras 130, 171 and 172 with 208, 209 or 211): Carrot on a Stick, Riding Crop, Charm of Swift Flight and Skybreaker Whip. Carrot on a Stick, Charm of Swift Flight and Skybreaker Whip are quest rewards in QuestieDB (quests 2770, 10992 and 11071), and Leatherworking makes the Riding Crop.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70577
	https://wago.tools/db2/ItemSparse?build=2.5.6.70577
	https://wago.tools/db2/ItemEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellEffect?build=2.5.6.70577
	https://wago.tools/db2/SpellName?build=2.5.6.70577
	https://wago.tools/db2/SkillLineAbility?build=2.5.6.70577

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcItemDB.lua
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcQuestDB.lua
]]
