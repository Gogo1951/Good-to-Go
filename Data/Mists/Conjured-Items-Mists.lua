local _, ns = ...

-- [conjureSpellID] = { itemID, ... }, -- Conjured item
ns.CONJURED_ITEM_IDS_BY_SPELL = {
	[6201] = { 5512 }, -- Healthstone
	[759] = { 36799, 81901 }, -- Mana Gem, Brilliant Mana Gem
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Conjure spell ID to the items it makes, read by GetSmartSpell (Features/Macros-for-Consumables/Macros/Smart-Spell.lua) when it is called with checkUnique. A conjure whose item the player already holds is skipped; with one spell per conjure on this client, the fallback then casts the same spell.
	- Create Healthstone makes one item on this client, Healthstone (5512), through Create Healthstone 23517 and 120038.
	- Conjure Mana Gem (759) creates Mana Gem (36799). Another Conjure Mana Gem (119316) creates Brilliant Mana Gem (81901); it is on no skill line, and what swaps it in for 759 (likely a glyph) is unverified, so a held Brilliant Mana Gem counts as 759's item too.
	- Conjure Refreshment has no row: the Food and Water conjures never run with checkUnique. Soulstones have no row: this client's Soulstone makes no item.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631

QuestieDB
	None.
]]
