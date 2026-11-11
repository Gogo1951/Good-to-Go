local _, ns = ...

-- [ID] = {Bandage Amount, First Aid Skill, Vendor Value, {Allowed Zones}, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.BANDAGES = {
	[19307] = { 2000, 225, 100, { 1459 }, 0, 100, 100, 1 }, -- Alterac Heavy Runecloth Bandage
	[20065] = { 1104, 175, 75, { 1461 }, 35, 75, 20, 1 }, -- Arathi Basin Mageweave Bandage
	[20066] = { 2000, 225, 100, { 1461 }, 45, 100, 20, 1 }, -- Arathi Basin Runecloth Bandage
	[20067] = { 640, 125, 50, { 1461 }, 25, 50, 20, 1 }, -- Arathi Basin Silk Bandage
	[23684] = { 2500, 225, 1500, nil, 0, 1500, 20, 0 }, -- Crystal Infused Bandage
	[20232] = { 1104, 175, 75, { 1461 }, 35, 75, 20, 1 }, -- Defiler's Mageweave Bandage
	[20234] = { 2000, 225, 100, { 1461 }, 45, 100, 20, 1 }, -- Defiler's Runecloth Bandage
	[20235] = { 640, 125, 50, { 1461 }, 25, 50, 20, 1 }, -- Defiler's Silk Bandage
	-- Dense Runecloth Bandage (232433) is deliberately absent; it is a Season of Discovery item, and the TBC Anniversary client does not know it.
	[2581] = { 114, 20, 20, nil, 0, 20, 20, 0 }, -- Heavy Linen Bandage
	[8545] = { 1104, 175, 800, nil, 0, 800, 20, 0 }, -- Heavy Mageweave Bandage
	[21991] = { 3400, 325, 3000, nil, 0, 3000, 20, 0 }, -- Heavy Netherweave Bandage
	[14530] = { 2000, 225, 1000, nil, 0, 1000, 20, 0 }, -- Heavy Runecloth Bandage
	[6451] = { 640, 125, 400, nil, 0, 400, 20, 0 }, -- Heavy Silk Bandage
	[3531] = { 301, 75, 57, nil, 0, 57, 20, 0 }, -- Heavy Wool Bandage
	[20237] = { 1104, 175, 75, { 1461 }, 35, 75, 20, 1 }, -- Highlander's Mageweave Bandage
	[20243] = { 2000, 225, 100, { 1461 }, 45, 100, 20, 1 }, -- Highlander's Runecloth Bandage
	[20244] = { 640, 125, 50, { 1461 }, 25, 50, 20, 1 }, -- Highlander's Silk Bandage
	[1251] = { 66, 1, 8, nil, 0, 8, 20, 0 }, -- Linen Bandage
	[8544] = { 800, 150, 340, nil, 0, 340, 20, 0 }, -- Mageweave Bandage
	[21990] = { 2800, 300, 1275, nil, 0, 1275, 20, 0 }, -- Netherweave Bandage
	[14529] = { 1360, 200, 425, nil, 0, 425, 20, 0 }, -- Runecloth Bandage
	[6450] = { 400, 100, 170, nil, 0, 170, 20, 0 }, -- Silk Bandage
	[19067] = { 1104, 175, 75, { 1460 }, 35, 75, 20, 1 }, -- Warsong Gulch Mageweave Bandage
	[19066] = { 2000, 225, 100, { 1460 }, 45, 100, 20, 1 }, -- Warsong Gulch Runecloth Bandage
	[19068] = { 640, 125, 50, { 1460 }, 25, 50, 20, 1 }, -- Warsong Gulch Silk Bandage
	[3530] = { 161, 50, 25, nil, 0, 25, 20, 0 }, -- Wool Bandage
	-- Dense Frostweave Bandage (38640) and Dalaran Bandage (44646) are deliberately absent; the query above excludes them too, so a regeneration will not bring them back.
}

--[[
How We Got the Data

Last Validated
	2026-11-11, TBC Anniversary 2.5.6.70577

Notes
	- Every First Aid bandage on this client, read by the item cache (Features/Macros-for-Consumables/Item-Cache.lua) to rank the Bandage macro's picks.
	- Bandage Amount is the whole heal over the channel, the per-tick heal times the ticks. First Aid Skill is the rank the tooltip requires (0 when it names none). Vendor Value is the sell price in copper.
	- Allowed Zones are uiMapIDs: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin. Each battleground bandage's tooltip says where it works ("Usable only inside Arathi Basin"; Alterac's says "May only be used in Alterac Valley"), and the item is offered nowhere else.
	- Dense Frostweave Bandage (38640) and Dalaran Bandage (44646) are Wrath items, left out; the query below excludes them too.
	- The Anti-Venoms (6452, 6453, 19440), Medicinal Drake Essence (31437) and Amani Hex Stick (33865) share the bandage cooldown but heal nothing, so they are left out.
	- Season of Discovery items are left out; this client doesn't know them. They live only in Data/Discovery/.

SQL (CMaNGOS)
	Database not recorded.

	SELECT
	    CONCAT(
	        '    [',
	        it.entry, '] = {',

	        -- Dynamically calculates the Total Heal amount!
	        (st.EffectBasePoints1 + 1) *
	        CASE
	            WHEN it.RequiredSkillRank < 50 THEN 6   -- Linen (6 ticks)
	            WHEN it.RequiredSkillRank < 100 THEN 7  -- Wool (7 ticks)
	            ELSE 8                                  -- Silk and above (8 ticks)
	        END,

	        ', ', it.RequiredSkillRank,
	        ', ', it.SellPrice,

	        -- Appends the optional Zone restrictions for Battlegrounds
	        CASE
	            WHEN it.entry IN (19307) THEN ', {1459}'
	            WHEN it.entry IN (20065, 20066, 20067, 20232, 20234, 20235, 20237, 20243, 20244) THEN ', {1461}'
	            WHEN it.entry IN (19066, 19067, 19068) THEN ', {1460}'
	            ELSE ''
	        END,

	        '}, -- ', it.name
	    ) AS `ns.RAW_DATA.Bandage`
	FROM item_template it
	JOIN spell_template st ON it.spellid_1 = st.Id
	WHERE it.class = 0
	  AND it.subclass = 7
	  AND it.spellid_1 > 0
	  AND st.EffectBasePoints1 > 0
	  AND it.entry NOT IN (38640, 44646)
	ORDER BY
	  it.RequiredSkillRank DESC,
	  it.entry DESC;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006
	https://wago.tools/db2/SpellCastingRequirements?build=2.5.6.70006
	https://wago.tools/db2/AreaGroupMember?build=2.5.6.70006
	https://wago.tools/db2/UiMapAssignment?build=2.5.6.70006

QuestieDB
	None.
]]
