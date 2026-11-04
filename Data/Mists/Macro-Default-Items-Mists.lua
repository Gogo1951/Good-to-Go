local _, ns = ...

-- [macroType] = itemID, -- Item Name
ns.MACRO_DEFAULT_ITEM_IDS = {
	["Bandage"] = 1251, -- Linen Bandage
	["Explosive"] = 4358, -- Rough Dynamite
	["Food"] = 5349, -- Conjured Muffin
	["Health Potion"] = 118, -- Minor Healing Potion
	["Healthstone"] = 5512, -- Healthstone
	["Mana Gem"] = 36799, -- Mana Gem
	["Mana Potion"] = 2455, -- Minor Mana Potion
	["Soulstone"] = 5232, -- Soulstone
	["Water"] = 5350, -- Conjured Water
	["Feed Pet"] = 117, -- Tough Jerky
	["Poisons"] = 6947, -- Empty Poison Vial
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- The item each macro shows (#showtooltip) while the bags hold nothing it can use, keyed by ns.MACRO_CONFIG's macro type (Data/Data.lua). Read by the macro body builder, the mini-map tooltip, the rogue tools and the Macros options panel. Each only has to exist on this client for its icon and tooltip; none has to be obtainable.
	- Kept from the other clients: Linen Bandage, Rough Dynamite, Conjured Muffin, Minor Healing Potion, Healthstone (5512, the one healthstone a spell still makes on this client, Create Healthstone's 23517), Minor Mana Potion, Conjured Water and Tough Jerky.
	- Mana Gem is 36799, the gem Conjure Mana Gem (759) makes on this client, in place of Mana Agate (5514), which this client keeps only as an unusable armor record.
	- Soulstone (5232) still exists and uses the Soulstone spell (20707), though from Cataclysm on warlocks cast Soulstone directly and no spell makes the item.
	- Poisons is 6947, which this client renames Empty Poison Vial: from Mists of Pandaria on rogue poisons are spells, not items, and no poison item a rogue can apply is left. The record still exists, so the tooltip line stays valid.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631

QuestieDB
	None.
]]
