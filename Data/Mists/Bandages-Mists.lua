local _, ns = ...

-- [ID] = {Bandage Amount, First Aid Skill, Vendor Value, {Allowed Zones}, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.BANDAGES = {
	[19307] = { 1104, 225, 100, { 91 }, 0, 100, 100, 1 }, -- Alterac Heavy Runecloth Bandage
	[20065] = { 1200, 175, 75, { 93 }, 35, 75, 20, 1 }, -- Arathi Basin Mageweave Bandage
	[20066] = { 1416, 225, 100, { 93 }, 45, 100, 20, 1 }, -- Arathi Basin Runecloth Bandage
	[20067] = { 688, 125, 50, { 93 }, 25, 50, 20, 1 }, -- Arathi Basin Silk Bandage
	[63391] = { 35000, 500, 0, { 244, 245 }, 0, 0, 20, 1 }, -- Baradin's Wardens Bandage
	[20232] = { 1200, 175, 75, { 93 }, 35, 75, 20, 1 }, -- Defiler's Mageweave Bandage
	[20234] = { 1416, 225, 100, { 93 }, 45, 100, 20, 1 }, -- Defiler's Runecloth Bandage
	[20235] = { 688, 125, 50, { 93 }, 25, 50, 20, 1 }, -- Defiler's Silk Bandage
	[53051] = { 45448, 500, 1250, nil, 75, 1250, 20, 0 }, -- Dense Embersilk Bandage
	[53049] = { 17400, 425, 1250, nil, 65, 1250, 20, 0 }, -- Embersilk Bandage
	[34721] = { 4800, 350, 1250, nil, 50, 1250, 20, 0 }, -- Frostweave Bandage
	[53050] = { 35000, 475, 1250, nil, 75, 1250, 20, 0 }, -- Heavy Embersilk Bandage
	[34722] = { 5800, 400, 2500, nil, 65, 2500, 20, 0 }, -- Heavy Frostweave Bandage
	[2581] = { 114, 20, 20, nil, 0, 20, 20, 0 }, -- Heavy Linen Bandage
	[8545] = { 1104, 175, 800, nil, 0, 800, 20, 0 }, -- Heavy Mageweave Bandage
	[21991] = { 6496, 325, 3000, nil, 50, 3000, 20, 0 }, -- Heavy Netherweave Bandage
	[14530] = { 2112, 225, 1000, nil, 0, 1000, 20, 0 }, -- Heavy Runecloth Bandage
	[6451] = { 640, 125, 400, nil, 0, 400, 20, 0 }, -- Heavy Silk Bandage
	[72986] = { 32000, 550, 1250, nil, 85, 1250, 20, 0 }, -- Heavy Windwool Bandage
	[3531] = { 301, 75, 57, nil, 0, 57, 20, 0 }, -- Heavy Wool Bandage
	[64995] = { 35000, 500, 0, { 244, 245 }, 0, 0, 20, 1 }, -- Hellscream's Reach Bandage
	[20237] = { 1200, 175, 75, { 93 }, 35, 75, 20, 1 }, -- Highlander's Mageweave Bandage
	[20243] = { 1416, 225, 100, { 93 }, 45, 100, 20, 1 }, -- Highlander's Runecloth Bandage
	[20244] = { 688, 125, 50, { 93 }, 25, 50, 20, 1 }, -- Highlander's Silk Bandage
	[1251] = { 66, 1, 8, nil, 0, 8, 20, 0 }, -- Linen Bandage
	[8544] = { 800, 150, 340, nil, 0, 340, 20, 0 }, -- Mageweave Bandage
	[21990] = { 5352, 300, 1275, nil, 35, 1275, 20, 0 }, -- Netherweave Bandage
	[14529] = { 1376, 200, 425, nil, 0, 425, 20, 0 }, -- Runecloth Bandage
	[6450] = { 400, 100, 170, nil, 0, 170, 20, 0 }, -- Silk Bandage
	[19067] = { 1104, 175, 75, { 92 }, 35, 75, 20, 1 }, -- Warsong Gulch Mageweave Bandage
	[19066] = { 1400, 225, 100, { 92 }, 45, 100, 20, 1 }, -- Warsong Gulch Runecloth Bandage
	[19068] = { 640, 125, 50, { 92 }, 25, 50, 20, 1 }, -- Warsong Gulch Silk Bandage
	[72985] = { 24000, 500, 1250, nil, 85, 1250, 20, 0 }, -- Windwool Bandage
	[3530] = { 161, 50, 25, nil, 0, 25, 20, 0 }, -- Wool Bandage
}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Every First Aid bandage on this client, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) to rank the Bandage macro's picks. The family is the items whose use spell is on the bandage cooldown category (150) and heals over time.
	- Bandage Amount is the whole heal over the channel: the per-tick heal times the ticks (duration over period). From Cataclysm on the per-tick heal is scaled, the coefficient times the SpellScaling game table (gametables/spellscaling.txt, file 1391660) at the spell's MaxScalingLevel; Linen Bandage still comes to 66. Where SpellLevels gives the spell a lower BaseLevel or MaxLevel, the scaling stops there instead, as the client's tooltips show: the Runecloth bandages of Alterac Valley (50), Arathi Basin and Warsong Gulch (45) heal level 35's amount. The Arathi Basin and Warsong Gulch ones carry the client's figures (1,416 and 1,400), which round a point or two away from the tables'. First Aid Skill is the First Aid rank the item requires. Vendor Value is the sell price in copper.
	- Where this client's text states a different heal, the row carries the client's, as Validate Data reported on build 5.5.4.70631: the tables' figure rounds a point or two away on most bandages, and for the Windwool bandages (level 90) it comes out three times the text, so Windwool Bandage holds 24,000 and Heavy Windwool Bandage 32,000.
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
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellCastingRequirements?build=5.5.4.70631
	https://wago.tools/db2/AreaGroupMember?build=5.5.4.70631
	https://wago.tools/db2/UiMapAssignment?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
