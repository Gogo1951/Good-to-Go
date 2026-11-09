local _, ns = ...

-- { buffID = true }
ns.WELL_FED_BUFF_IDS = {
	[18125] = true, -- Blessed Sunfruit
	[18141] = true, -- Blessed Sunfruit Juice
	[18191] = true, -- Increased Stamina (Cooked Glossy Mightfish, Windblossom Berries)
	[18192] = true, -- Increased Agility (Grilled Squid)
	[18193] = true, -- Increased Spirit (Hot Smoked Bass, Marsh Lichen)
	[22730] = true, -- Increased Intellect (Runn Tum Tuber Surprise)
	[23697] = true, -- Alterac Spring Water (Bottled Alterac Spring Water)
	[25661] = true, -- Increased Stamina (Dirge's Kickin' Chimaerok Chops)
	[44097] = true, -- "Well Fed" (Barleybrew Clear, Small Step Brew)
	[44098] = true, -- "Well Fed" (Barleybrew Light, Long Stride Brew)
	[44099] = true, -- "Well Fed" (Barleybrew Dark, Path of Brew)
	[44100] = true, -- "Well Fed" (Jungle River Water, Thunder 45)
	[44101] = true, -- "Well Fed" (Brewdoo Magic, Thunderbrew Ale)
	[44102] = true, -- "Well Fed" (Stout Shrunken Head, Thunderbrew Stout)
	[44104] = true, -- "Well Fed" (Gordok Grog)
	[44105] = true, -- "Well Fed" (Ogre Mead)
	[44106] = true, -- "Well Fed" (Mudder's Milk)
	[45245] = true, -- Well Fed (Hot Apple Cider)
	[65365] = true, -- "Well Fed" (Barleybrew Gold, Chuganpug's Delight, Crimson Stripe)
	[69559] = true, -- "Well Fed" (Promise of the Pandaren, Thunder's Plunder)
	[105225] = true, -- Delusional (Mad Brewer's Breakfast)
	[111840] = true, -- Healthy (Half a Lovely Apple)
	[131828] = true, -- Well Fed (Mah's Warm Yak-Tail Stew)
	[145635] = true, -- Increased Stamina (Dried Fruit Rations, Dried Mushroom Rations, Mightfish Steak)
}

-- Icons the Well Fed buffs show, matched on the aura's icon when its spell ID is in no table.
-- { [iconFileID] = true }
ns.WELL_FED_ICON_IDS = {
	[136000] = true, -- Well Fed
	[133943] = true, -- Well Fed
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- ns.WELL_FED_BUFF_IDS lists food buffs Features/Macros-for-Consumables/Scanner/Scanner-Auras.lua must count as Well Fed although they show another icon, so the buff-food check doesn't nag a player who already has one.
	- ns.WELL_FED_ICON_IDS lists the icons Well Fed buffs show, matched on the aura's icon when its spell ID is in no table. 136000 is the icon of 124 of the buffs the buff foods in Data/Mists/Food-and-Water-Mists.lua grant; 133943 is Juicy Bear Burger's (46687).
	- Built from every buff food in Data/Mists/Food-and-Water-Mists.lua, plus Blessed Sunfruit Juice and Bottled Alterac Spring Water, which that table leaves out: the buffs its spell applies after the delay (a periodic trigger aura) or at once (a triggered spell), and a stat aura on the food spell itself, read with their SpellMisc icons. Every buff on an icon other than the two above is listed by ID. A few foods apply their buff by script with no spell in the tables (Fortune Cookie, the Love is in the Air chocolates, Noblegarden Chocolate, and Grummlecake, whose 127784 picks a random buff); their buffs are left to the icon match.
	- The Brewfest drinks apply a separate buff named "Well Fed" (with quotes) on icon 133696, which "Completely Hammered" also uses, so they are listed by ID rather than matched by icon. This client adds two (65365, 69559) to the older clients' nine.
	- Left out from the older clients' list: Mana Regeneration (18194) and Health Regeneration (18222), which no buff food on this client grants any more, and Fizzy Energy Drink (29040), whose item has no source on this client.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631

QuestieDB
	None.
]]
