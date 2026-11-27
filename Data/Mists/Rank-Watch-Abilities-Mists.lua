local _, ns = ...

-- [classToken] = { { { id, rank, level, off }, ... }, ... }, -- each ability's ranks, lowest first; level: nil where no table gives one; off: unchecked until the player ticks it
ns.RANK_WATCH_ABILITIES = {}

--[[
How We Got the Data

Last Validated
	2026-11-27, wago.tools, Mists of Pandaria Classic 5.5.4.71089

Notes
	- Empty: Rank Watch reports a rank lower than the caster could have, and this flavor has no ranks to compare, or no TOC lists this folder.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Spell?build=5.5.4.71089
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.71089

QuestieDB
	None.
]]
