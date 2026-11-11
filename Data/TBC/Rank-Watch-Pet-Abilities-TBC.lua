local _, ns = ...

-- [ownerClassToken] = { { { id, rank, level }, ... }, ... }, -- each pet ability's ranks, lowest first
ns.RANK_WATCH_PET_ABILITIES = {
	HUNTER = {
		{
			{ id = 17253, rank = 1, level = 1 },
			{ id = 17255, rank = 2, level = 8 },
			{ id = 17256, rank = 3, level = 16 },
			{ id = 17257, rank = 4, level = 24 },
			{ id = 17258, rank = 5, level = 32 },
			{ id = 17259, rank = 6, level = 40 },
			{ id = 17260, rank = 7, level = 48 },
			{ id = 17261, rank = 8, level = 56 },
			{ id = 27050, rank = 9, level = 64 },
		}, -- Bite
		{
			{ id = 7371, rank = 1, level = 1 },
			{ id = 26177, rank = 2, level = 12 },
			{ id = 26178, rank = 3, level = 24 },
			{ id = 26201, rank = 5, level = 48 },
			{ id = 27685, rank = 6, level = 60 },
		}, -- Charge
		{
			{ id = 16827, rank = 1, level = 1 },
			{ id = 16828, rank = 2, level = 8 },
			{ id = 16829, rank = 3, level = 16 },
			{ id = 16830, rank = 4, level = 24 },
			{ id = 16831, rank = 5, level = 32 },
			{ id = 16832, rank = 6, level = 40 },
			{ id = 3010, rank = 7, level = 48 },
			{ id = 3009, rank = 8, level = 56 },
			{ id = 27049, rank = 9, level = 64 },
		}, -- Claw
		{
			{ id = 1742, rank = 1, level = 5 },
			{ id = 1753, rank = 2, level = 15 },
			{ id = 1754, rank = 3, level = 25 },
			{ id = 1755, rank = 4, level = 35 },
			{ id = 1756, rank = 5, level = 45 },
			{ id = 16697, rank = 6, level = 55 },
			{ id = 27048, rank = 7, level = 65 },
		}, -- Cower
		{
			{ id = 23099, rank = 1, level = 30 },
			{ id = 23109, rank = 2, level = 40 },
			{ id = 23110, rank = 3, level = 50 },
		}, -- Dash
		{
			{ id = 23145, rank = 1, level = 30 },
			{ id = 23147, rank = 2, level = 40 },
			{ id = 23148, rank = 3, level = 50 },
		}, -- Dive
		{
			{ id = 34889, rank = 1, level = 1 },
			{ id = 35323, rank = 2, level = 60 },
		}, -- Fire Breath
		{
			{ id = 24604, rank = 1, level = 10 },
			{ id = 24605, rank = 2, level = 24 },
			{ id = 24603, rank = 3, level = 40 },
			{ id = 24597, rank = 4, level = 56 },
		}, -- Furious Howl
		{
			{ id = 35290, rank = 1, level = 1 },
			{ id = 35291, rank = 2, level = 8 },
			{ id = 35292, rank = 3, level = 16 },
			{ id = 35293, rank = 4, level = 24 },
			{ id = 35296, rank = 7, level = 48 },
			{ id = 35297, rank = 8, level = 56 },
			{ id = 35298, rank = 9, level = 63 },
		}, -- Gore
		{
			{ id = 2649, rank = 1, level = 1 },
			{ id = 14916, rank = 2, level = 10 },
			{ id = 14917, rank = 3, level = 20 },
			{ id = 14918, rank = 4, level = 30 },
			{ id = 14919, rank = 5, level = 40 },
			{ id = 14920, rank = 6, level = 50 },
			{ id = 14921, rank = 7, level = 60 },
			{ id = 27047, rank = 8, level = 70 },
		}, -- Growl
		{
			{ id = 24844, rank = 1, level = 1 },
			{ id = 25008, rank = 2, level = 12 },
			{ id = 25009, rank = 3, level = 24 },
			{ id = 25010, rank = 4, level = 36 },
			{ id = 25011, rank = 5, level = 48 },
			{ id = 25012, rank = 6, level = 60 },
		}, -- Lightning Breath
		{
			{ id = 35387, rank = 1, level = 15 },
			{ id = 35389, rank = 2, level = 45 },
			{ id = 35392, rank = 3, level = 60 },
		}, -- Poison Spit
		{
			{ id = 24450, rank = 1, level = 30 },
			{ id = 24452, rank = 2, level = 40 },
			{ id = 24453, rank = 3, level = 50 },
		}, -- Prowl
		{
			{ id = 24640, rank = 1, level = 8 },
			{ id = 24583, rank = 2, level = 24 },
			{ id = 24586, rank = 3, level = 40 },
			{ id = 24587, rank = 4, level = 56 },
			{ id = 27060, rank = 5, level = 64 },
		}, -- Scorpid Poison
		{
			{ id = 24423, rank = 1, level = 8 },
			{ id = 24577, rank = 2, level = 24 },
			{ id = 24578, rank = 3, level = 40 },
			{ id = 24579, rank = 4, level = 56 },
			{ id = 27051, rank = 5, level = 64 },
		}, -- Screech
		{
			{ id = 26090, rank = 1, level = 30 },
			{ id = 26187, rank = 2, level = 40 },
			{ id = 26188, rank = 3, level = 50 },
		}, -- Thunderstomp
	},
	WARLOCK = {
		{
			{ id = 33698, rank = 1, level = 50 },
			{ id = 33699, rank = 2, level = 60 },
			{ id = 33700, rank = 3, level = 70 },
		}, -- Anguish
		{
			{ id = 6307, rank = 1, level = 4 },
			{ id = 7804, rank = 2, level = 14 },
			{ id = 7805, rank = 3, level = 26 },
			{ id = 11766, rank = 4, level = 38 },
			{ id = 11767, rank = 5, level = 50 },
			{ id = 27268, rank = 6, level = 62 },
		}, -- Blood Pact
		{
			{ id = 30213, rank = 1, level = 50 },
			{ id = 30219, rank = 2, level = 60 },
			{ id = 30223, rank = 3, level = 68 },
		}, -- Cleave
		{
			{ id = 17767, rank = 1, level = 18 },
			{ id = 17850, rank = 2, level = 26 },
			{ id = 17851, rank = 3, level = 34 },
			{ id = 17852, rank = 4, level = 42 },
			{ id = 17853, rank = 5, level = 50 },
			{ id = 17854, rank = 6, level = 58 },
			{ id = 27272, rank = 7, level = 66 },
		}, -- Consume Shadows
		{
			{ id = 19505, rank = 1, level = 30 },
			{ id = 19731, rank = 2, level = 38 },
			{ id = 19734, rank = 3, level = 46 },
			{ id = 19736, rank = 4, level = 54 },
			{ id = 27276, rank = 5, level = 62 },
			{ id = 27277, rank = 6, level = 70 },
		}, -- Devour Magic
		{
			{ id = 2947, rank = 1, level = 14 },
			{ id = 8316, rank = 2, level = 24 },
			{ id = 8317, rank = 3, level = 34 },
			{ id = 11770, rank = 4, level = 44 },
			{ id = 11771, rank = 5, level = 54 },
			{ id = 27269, rank = 6, level = 64 },
		}, -- Fire Shield
		{
			{ id = 3110, rank = 1, level = 1 },
			{ id = 7799, rank = 2, level = 8 },
			{ id = 7800, rank = 3, level = 18 },
			{ id = 7801, rank = 4, level = 28 },
			{ id = 7802, rank = 5, level = 38 },
			{ id = 11762, rank = 6, level = 48 },
			{ id = 11763, rank = 7, level = 58 },
			{ id = 27267, rank = 8, level = 68 },
		}, -- Firebolt
		{
			{ id = 30151, rank = 1, level = 52 },
			{ id = 30194, rank = 2, level = 61 },
			{ id = 30198, rank = 3, level = 69 },
		}, -- Intercept
		{
			{ id = 7814, rank = 1, level = 20 },
			{ id = 7815, rank = 2, level = 28 },
			{ id = 7816, rank = 3, level = 36 },
			{ id = 11778, rank = 4, level = 44 },
			{ id = 11779, rank = 5, level = 52 },
			{ id = 11780, rank = 6, level = 60 },
			{ id = 27274, rank = 7, level = 68 },
		}, -- Lash of Pain
		{
			{ id = 7812, rank = 1, level = 16 },
			{ id = 19438, rank = 2, level = 24 },
			{ id = 19440, rank = 3, level = 32 },
			{ id = 19441, rank = 4, level = 40 },
			{ id = 19442, rank = 5, level = 48 },
			{ id = 19443, rank = 6, level = 56 },
			{ id = 27273, rank = 7, level = 64 },
		}, -- Sacrifice
		{
			{ id = 6360, rank = 1, level = 22 },
			{ id = 7813, rank = 2, level = 34 },
			{ id = 11784, rank = 3, level = 46 },
			{ id = 11785, rank = 4, level = 58 },
			{ id = 27275, rank = 5, level = 70 },
		}, -- Soothing Kiss
		{
			{ id = 19244, rank = 1, level = 36 },
			{ id = 19647, rank = 2, level = 52 },
		}, -- Spell Lock
		{
			{ id = 17735, rank = 1, level = 24 },
			{ id = 17750, rank = 2, level = 36 },
			{ id = 17751, rank = 3, level = 48 },
			{ id = 17752, rank = 4, level = 60 },
			{ id = 27271, rank = 5, level = 63 },
			{ id = 33701, rank = 6, level = 69 },
		}, -- Suffering
		{
			{ id = 19478, rank = 1, level = 32 },
			{ id = 19655, rank = 2, level = 40 },
			{ id = 19656, rank = 3, level = 48 },
			{ id = 19660, rank = 4, level = 56 },
			{ id = 27280, rank = 5, level = 64 },
		}, -- Tainted Blood
		{
			{ id = 3716, rank = 1, level = 10 },
			{ id = 7809, rank = 2, level = 20 },
			{ id = 7810, rank = 3, level = 30 },
			{ id = 7811, rank = 4, level = 40 },
			{ id = 11774, rank = 5, level = 50 },
			{ id = 11775, rank = 6, level = 60 },
			{ id = 27270, rank = 7, level = 70 },
		}, -- Torment
	},
}

--[[
How We Got the Data

Last Validated
	2026-11-11, TBC Anniversary 2.5.6.70577

Notes
	- Built by Tools/Build-Rank-Watch-Pet-Abilities.py from Pet-Abilities-TBC.lua: PET_ABILITIES under HUNTER, DEMON_ABILITIES under WARLOCK, grouped by each row's comment.
	- level is the pet's level: a hunter pet's own, and for a demon its warlock's, which a demon is summoned at.
	- Passive abilities and abilities with one rank are left out. Each demon's summon-time rank (Firebolt Rank 1, Torment Rank 1, Lash of Pain Rank 1, Devour Magic Rank 1) is added, since no grimoire teaches it.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
