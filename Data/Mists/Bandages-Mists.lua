local _, ns = ...

-- [ID] = {Bandage Amount, First Aid Skill, Vendor Value, {Allowed Zones}}, -- Name
ns.BANDAGES = {
	[19307] = { 2112, 225, 100, { 91 } }, -- Alterac Heavy Runecloth Bandage
	[20065] = { 1196, 175, 75, { 93 } }, -- Arathi Basin Mageweave Bandage
	[20066] = { 2033, 225, 100, { 93 } }, -- Arathi Basin Runecloth Bandage
	[20067] = { 686, 125, 50, { 93 } }, -- Arathi Basin Silk Bandage
	[63391] = { 35000, 500, 0, { 244, 245 } }, -- Baradin's Wardens Bandage
	[20232] = { 1196, 175, 75, { 93 } }, -- Defiler's Mageweave Bandage
	[20234] = { 2033, 225, 100, { 93 } }, -- Defiler's Runecloth Bandage
	[20235] = { 686, 125, 50, { 93 } }, -- Defiler's Silk Bandage
	[53051] = { 45448, 500, 1250 }, -- Dense Embersilk Bandage
	[53049] = { 17399, 425, 1250 }, -- Embersilk Bandage
	[34721] = { 4800, 350, 1250 }, -- Frostweave Bandage
	[53050] = { 34997, 475, 1250 }, -- Heavy Embersilk Bandage
	[34722] = { 5803, 400, 2500 }, -- Heavy Frostweave Bandage
	[2581] = { 114, 20, 20 }, -- Heavy Linen Bandage
	[8545] = { 1104, 175, 800 }, -- Heavy Mageweave Bandage
	[21991] = { 6495, 325, 3000 }, -- Heavy Netherweave Bandage
	[14530] = { 2116, 225, 1000 }, -- Heavy Runecloth Bandage
	[6451] = { 640, 125, 400 }, -- Heavy Silk Bandage
	[72986] = { 96000, 550, 1250 }, -- Heavy Windwool Bandage
	[3531] = { 301, 75, 57 }, -- Heavy Wool Bandage
	[64995] = { 35000, 500, 0, { 244, 245 } }, -- Hellscream's Reach Bandage
	[20237] = { 1196, 175, 75, { 93 } }, -- Highlander's Mageweave Bandage
	[20243] = { 2033, 225, 100, { 93 } }, -- Highlander's Runecloth Bandage
	[20244] = { 686, 125, 50, { 93 } }, -- Highlander's Silk Bandage
	[1251] = { 66, 1, 8 }, -- Linen Bandage
	[8544] = { 800, 150, 340 }, -- Mageweave Bandage
	[21990] = { 5354, 300, 1275 }, -- Netherweave Bandage
	[14529] = { 1380, 200, 425 }, -- Runecloth Bandage
	[6450] = { 400, 100, 170 }, -- Silk Bandage
	[19067] = { 1104, 175, 75, { 92 } }, -- Warsong Gulch Mageweave Bandage
	[19066] = { 2006, 225, 100, { 92 } }, -- Warsong Gulch Runecloth Bandage
	[19068] = { 640, 125, 50, { 92 } }, -- Warsong Gulch Silk Bandage
	[72985] = { 72000, 500, 1250 }, -- Windwool Bandage
	[3530] = { 161, 50, 25 }, -- Wool Bandage
}

--[[
How We Got the Data

Last Validated
	2026-11-04, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Every First Aid bandage on this client, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) to rank the Bandage macro's picks. The family is the items whose use spell is on the bandage cooldown category (150) and heals over time.
	- Bandage Amount is the whole heal over the channel: the per-tick heal times the ticks (duration over period). From Cataclysm on the per-tick heal is scaled, the coefficient times the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel; Linen Bandage still comes to 66. First Aid Skill is the First Aid rank the item requires. Vendor Value is the sell price in copper.
	- Allowed Zones are uiMapIDs, from each spell's required area group: 91 Alterac Valley, 92 Warsong Gulch, 93 Arathi Basin, and 244 Tol Barad with 245 Tol Barad Peninsula for the Baradin's Wardens and Hellscream's Reach bandages.
	- The Anti-Venoms (6452, 6453, 19440), Medicinal Drake Essence (31437), Amani Hex Stick (33865) and Battle Pet Bandage (86143) share the bandage cooldown but heal the player nothing, so they are left out.
	- Left out for having no source (no drop, vendor or quest reward in QuestieDB's MoP item table and no spell that creates it): Dense Frostweave Bandage (38640), Thick Frostweave Bandage (38643), Dalaran Bandage (44646), and the second Windwool and Heavy Windwool Bandage records (82829, 82830; the crafted 72985 and 72986 are kept). Crystal Infused Bandage (23684) is a [PH] item with no use spell on this client, and the Deprecated and [PH] Frostweave and Windwool records heal nothing.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellDuration?build=5.5.4.70631
	https://wago.tools/db2/SpellScaling?build=5.5.4.70631
	https://wago.tools/db2/SpellCastingRequirements?build=5.5.4.70631
	https://wago.tools/db2/AreaGroupMember?build=5.5.4.70631
	https://wago.tools/db2/UiMapAssignment?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
