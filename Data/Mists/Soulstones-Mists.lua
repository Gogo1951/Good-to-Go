local _, ns = ...

-- [ID] = {Rank Value, Min Level, Vendor Price, Max Stack, Bind Type}, -- Name
ns.SOULSTONES = {}

-- buffSpellID, -- Name (cast spell ID)
ns.SOULSTONE_BUFF_SPELL_IDS = {
	20707, -- Soulstone (cast 20707)
}

--[[
How We Got the Data

Last Validated
	2026-11-08, Mists of Pandaria Classic 5.5.4.70631

Notes
	- ns.SOULSTONES is empty: this client's Soulstone (20707) is cast straight on a target and makes no item.
	- ns.SOULSTONE_BUFF_SPELL_IDS holds the aura a Soulstone leaves on its target, read by the Readiness Report. On this client it is the cast spell's own aura: 20707 applies a 15-minute aura (SpellEffect aura 4, SpellDuration 347). Soulstone Resurrection (95750) is the resurrection itself, not an aura.
	- With no stones in ns.SOULSTONES, the Readiness Report's stone-cooldown check (ns.SoulstonesOnCooldown) always answers no; on this client the cooldown to read is the Soulstone spell's.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellDuration?build=5.5.4.70631

QuestieDB
	None.
]]
