local _, ns = ...

-- [classToken] = { { { id, rank, level, off }, ... }, ... }, -- each ability's ranks, lowest first; level: nil where no table gives one; off: unchecked until the player ticks it
ns.RANK_WATCH_ABILITIES = {}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Empty: Rank Watch reports a rank lower than the caster could have, and this flavor has no ranks to compare, or no TOC lists this folder.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
