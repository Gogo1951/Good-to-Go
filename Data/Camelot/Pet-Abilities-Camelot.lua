local _, ns = ...

--[[
	level is the level the rank needs, id the pet's spell, source HUNTER_TRAINER or TAMING, families the creature
	families that learn it (none: every family). HUNTER_TRAINER: the hunter's own class trainer teaches it straight
	to the pet out, by the hunter's level, and every family learns it. TAMING: a beast that knows it brings it along
	when tamed; nothing teaches it to a pet later, so it's had by taming a new pet, by the hunter's level too. There's
	no Beast Training spell for the hunter (so no teach) and no training points (so no tp).
]]
ns.PET_ABILITIES = {
	{
		level = 1,
		id = 17253,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 1)
	{ level = 1, id = 7371, source = "TAMING", families = { 5 } }, -- Charge (Rank 1)
	{ level = 1, id = 16827, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 1)
	{ level = 1, id = 24844, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 1)
	{ level = 5, id = 1742, source = "TAMING" }, -- Cower (Rank 1)
	{
		level = 8,
		id = 17255,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 2)
	{ level = 8, id = 16828, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 2)
	{ level = 8, id = 24423, source = "TAMING", families = { 7 } }, -- Demoralizing Screech (Rank 1)
	{ level = 8, id = 24640, source = "TAMING", families = { 20 } }, -- Scorpid Poison (Rank 1)
	{ level = 10, id = 24604, source = "TAMING", families = { 1 } }, -- Furious Howl (Rank 1)
	{ level = 10, id = 4187, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 1)
	{ level = 10, id = 1265054, source = "TAMING", families = { 26 } }, -- Mine! (Rank 1)
	{ level = 10, id = 24545, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 1)
	{ level = 12, id = 26177, source = "TAMING", families = { 5 } }, -- Charge (Rank 2)
	{ level = 12, id = 1264758, source = "TAMING", families = { 6 } }, -- Dismember (Rank 1)
	{ level = 12, id = 1265899, source = "TAMING", families = { 12 } }, -- Dust Cloud (Rank 1)
	{ level = 12, id = 4188, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 2)
	{ level = 12, id = 25008, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 2)
	{ level = 12, id = 24549, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 2)
	{ level = 12, id = 1264735, source = "TAMING", families = { 8 } }, -- Pinch (Rank 1)
	{ level = 12, id = 1265065, source = "TAMING", families = { 11 } }, -- Savage Rend (Rank 1)
	{ level = 12, id = 1264478, source = "TAMING", families = { 24 } }, -- Sonic Blast (Rank 1)
	{ level = 12, id = 1264494, source = "TAMING", families = { 4 } }, -- Swipe (Rank 1)
	{ level = 12, id = 1265038, source = "TAMING", families = { 25 } }, -- Tendon Rip (Rank 1)
	{ level = 12, id = 1265843, source = "TAMING", families = { 3 } }, -- Web (Rank 1)
	{ level = 15, id = 1753, source = "TAMING" }, -- Cower (Rank 2)
	{
		level = 16,
		id = 17256,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 3)
	{ level = 16, id = 16829, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 3)
	{ level = 18, id = 4189, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 3)
	{ level = 18, id = 24550, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 3)
	{ level = 20, id = 24493, source = "HUNTER_TRAINER" }, -- Arcane Resistance (Rank 1)
	{ level = 20, id = 23992, source = "HUNTER_TRAINER" }, -- Fire Resistance (Rank 1)
	{ level = 20, id = 24446, source = "HUNTER_TRAINER" }, -- Frost Resistance (Rank 1)
	{ level = 20, id = 14917, source = "HUNTER_TRAINER" }, -- Growl (Rank 3)
	{ level = 20, id = 1265055, source = "TAMING", families = { 26 } }, -- Mine! (Rank 2)
	{ level = 20, id = 24492, source = "HUNTER_TRAINER" }, -- Nature Resistance (Rank 1)
	{ level = 20, id = 24488, source = "HUNTER_TRAINER" }, -- Shadow Resistance (Rank 1)
	{ level = 20, id = 26064, source = "TAMING", families = { 21 } }, -- Shell Shield (Rank 1)
	{ level = 20, id = 1310612, source = "TAMING", families = { 319 } }, -- Trickster's Dance (Rank 1)
	{
		level = 24,
		id = 17257,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 4)
	{ level = 24, id = 26178, source = "TAMING", families = { 5 } }, -- Charge (Rank 3)
	{ level = 24, id = 16830, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 4)
	{ level = 24, id = 24577, source = "TAMING", families = { 7 } }, -- Demoralizing Screech (Rank 2)
	{ level = 24, id = 1264927, source = "TAMING", families = { 6 } }, -- Dismember (Rank 2)
	{ level = 24, id = 1265901, source = "TAMING", families = { 12 } }, -- Dust Cloud (Rank 2)
	{ level = 24, id = 24605, source = "TAMING", families = { 1 } }, -- Furious Howl (Rank 2)
	{ level = 24, id = 4190, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 4)
	{ level = 24, id = 25009, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 3)
	{ level = 24, id = 24551, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 4)
	{ level = 24, id = 1264736, source = "TAMING", families = { 8 } }, -- Pinch (Rank 2)
	{ level = 24, id = 1265066, source = "TAMING", families = { 11 } }, -- Savage Rend (Rank 2)
	{ level = 24, id = 24583, source = "TAMING", families = { 20 } }, -- Scorpid Poison (Rank 2)
	{ level = 24, id = 1264479, source = "TAMING", families = { 24 } }, -- Sonic Blast (Rank 2)
	{ level = 24, id = 1264497, source = "TAMING", families = { 4 } }, -- Swipe (Rank 2)
	{ level = 24, id = 1265039, source = "TAMING", families = { 25 } }, -- Tendon Rip (Rank 2)
	{ level = 24, id = 1265878, source = "TAMING", families = { 3 } }, -- Web (Rank 2)
	{ level = 25, id = 1754, source = "TAMING" }, -- Cower (Rank 3)
	{ level = 30, id = 24497, source = "HUNTER_TRAINER" }, -- Arcane Resistance (Rank 2)
	{ level = 30, id = 23099, source = "TAMING", families = { 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 20, 21, 25, 319 } }, -- Dash (Rank 1)
	{ level = 30, id = 23145, source = "TAMING", families = { 7, 26, 27 } }, -- Dive (Rank 1)
	{ level = 30, id = 24439, source = "HUNTER_TRAINER" }, -- Fire Resistance (Rank 2)
	{ level = 30, id = 24447, source = "HUNTER_TRAINER" }, -- Frost Resistance (Rank 2)
	{ level = 30, id = 4191, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 5)
	{ level = 30, id = 14918, source = "HUNTER_TRAINER" }, -- Growl (Rank 4)
	{ level = 30, id = 1265056, source = "TAMING", families = { 26 } }, -- Mine! (Rank 3)
	{ level = 30, id = 24552, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 5)
	{ level = 30, id = 24502, source = "HUNTER_TRAINER" }, -- Nature Resistance (Rank 2)
	{ level = 30, id = 24450, source = "TAMING", families = { 2 } }, -- Prowl (Rank 1)
	{ level = 30, id = 24505, source = "HUNTER_TRAINER" }, -- Shadow Resistance (Rank 2)
	{ level = 30, id = 26090, source = "TAMING", families = { 9 } }, -- Thunderstomp (Rank 1)
	{
		level = 32,
		id = 17258,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 5)
	{ level = 32, id = 16831, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 5)
	{ level = 35, id = 1755, source = "TAMING" }, -- Cower (Rank 4)
	{ level = 36, id = 26179, source = "TAMING", families = { 5 } }, -- Charge (Rank 4)
	{ level = 36, id = 1264929, source = "TAMING", families = { 6 } }, -- Dismember (Rank 3)
	{ level = 36, id = 1265902, source = "TAMING", families = { 12 } }, -- Dust Cloud (Rank 3)
	{ level = 36, id = 4192, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 6)
	{ level = 36, id = 25010, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 4)
	{ level = 36, id = 24553, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 6)
	{ level = 36, id = 1264739, source = "TAMING", families = { 8 } }, -- Pinch (Rank 3)
	{ level = 36, id = 1265067, source = "TAMING", families = { 11 } }, -- Savage Rend (Rank 3)
	{ level = 36, id = 1264480, source = "TAMING", families = { 24 } }, -- Sonic Blast (Rank 3)
	{ level = 36, id = 1264498, source = "TAMING", families = { 4 } }, -- Swipe (Rank 3)
	{ level = 36, id = 1265040, source = "TAMING", families = { 25 } }, -- Tendon Rip (Rank 3)
	{ level = 36, id = 1265880, source = "TAMING", families = { 3 } }, -- Web (Rank 3)
	{ level = 40, id = 24500, source = "HUNTER_TRAINER" }, -- Arcane Resistance (Rank 3)
	{
		level = 40,
		id = 17259,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 6)
	{ level = 40, id = 16832, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 6)
	{ level = 40, id = 23109, source = "TAMING", families = { 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 20, 21, 25, 319 } }, -- Dash (Rank 2)
	{ level = 40, id = 23147, source = "TAMING", families = { 7, 24, 26, 27 } }, -- Dive (Rank 2)
	{ level = 40, id = 24444, source = "HUNTER_TRAINER" }, -- Fire Resistance (Rank 3)
	{ level = 40, id = 24448, source = "HUNTER_TRAINER" }, -- Frost Resistance (Rank 3)
	{ level = 40, id = 24603, source = "TAMING", families = { 1 } }, -- Furious Howl (Rank 3)
	{ level = 40, id = 14919, source = "HUNTER_TRAINER" }, -- Growl (Rank 5)
	{ level = 40, id = 1265057, source = "TAMING", families = { 26 } }, -- Mine! (Rank 4)
	{ level = 40, id = 24503, source = "HUNTER_TRAINER" }, -- Nature Resistance (Rank 3)
	{ level = 40, id = 24452, source = "TAMING", families = { 2 } }, -- Prowl (Rank 2)
	{ level = 40, id = 24586, source = "TAMING", families = { 20 } }, -- Scorpid Poison (Rank 3)
	{ level = 40, id = 24506, source = "HUNTER_TRAINER" }, -- Shadow Resistance (Rank 3)
	{ level = 40, id = 26187, source = "TAMING", families = { 9 } }, -- Thunderstomp (Rank 2)
	{ level = 42, id = 4193, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 7)
	{ level = 42, id = 24554, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 7)
	{ level = 45, id = 1756, source = "TAMING" }, -- Cower (Rank 5)
	{
		level = 48,
		id = 17260,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 7)
	{ level = 48, id = 26201, source = "TAMING", families = { 5 } }, -- Charge (Rank 5)
	{ level = 48, id = 3010, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 7)
	{ level = 48, id = 24578, source = "TAMING", families = { 7 } }, -- Demoralizing Screech (Rank 3)
	{ level = 48, id = 1264930, source = "TAMING", families = { 6 } }, -- Dismember (Rank 4)
	{ level = 48, id = 1265903, source = "TAMING", families = { 12 } }, -- Dust Cloud (Rank 4)
	{ level = 48, id = 4194, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 8)
	{ level = 48, id = 444678, source = "TAMING", families = { 312 } }, -- Lava Breath (Rank 1)
	{ level = 48, id = 444681, source = "TAMING", families = { 312 } }, -- Lava Breath (Rank 2)
	{ level = 48, id = 25011, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 5)
	{ level = 48, id = 24555, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 8)
	{ level = 48, id = 1264741, source = "TAMING", families = { 8 } }, -- Pinch (Rank 4)
	{ level = 48, id = 1265068, source = "TAMING", families = { 11 } }, -- Savage Rend (Rank 4)
	{ level = 48, id = 1264481, source = "TAMING", families = { 24 } }, -- Sonic Blast (Rank 4)
	{ level = 48, id = 1264501, source = "TAMING", families = { 4 } }, -- Swipe (Rank 4)
	{ level = 48, id = 1265041, source = "TAMING", families = { 25 } }, -- Tendon Rip (Rank 4)
	{ level = 48, id = 1265881, source = "TAMING", families = { 3 } }, -- Web (Rank 4)
	{ level = 50, id = 24501, source = "HUNTER_TRAINER" }, -- Arcane Resistance (Rank 4)
	{ level = 50, id = 23110, source = "TAMING", families = { 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 20, 21, 25, 319 } }, -- Dash (Rank 3)
	{ level = 50, id = 23148, source = "TAMING", families = { 7, 24, 26, 27 } }, -- Dive (Rank 3)
	{ level = 50, id = 24445, source = "HUNTER_TRAINER" }, -- Fire Resistance (Rank 4)
	{ level = 50, id = 24449, source = "HUNTER_TRAINER" }, -- Frost Resistance (Rank 4)
	{ level = 50, id = 14920, source = "HUNTER_TRAINER" }, -- Growl (Rank 6)
	{ level = 50, id = 1265058, source = "TAMING", families = { 26 } }, -- Mine! (Rank 5)
	{ level = 50, id = 24504, source = "HUNTER_TRAINER" }, -- Nature Resistance (Rank 4)
	{ level = 50, id = 24453, source = "TAMING", families = { 2 } }, -- Prowl (Rank 3)
	{ level = 50, id = 24507, source = "HUNTER_TRAINER" }, -- Shadow Resistance (Rank 4)
	{ level = 50, id = 26188, source = "TAMING", families = { 9 } }, -- Thunderstomp (Rank 3)
	{ level = 54, id = 5041, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 9)
	{ level = 54, id = 24629, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 9)
	{ level = 55, id = 16697, source = "TAMING" }, -- Cower (Rank 6)
	{
		level = 56,
		id = 17261,
		source = "TAMING",
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312, 319 },
	}, -- Bite (Rank 8)
	{ level = 56, id = 3009, source = "TAMING", families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 8)
	{ level = 56, id = 24579, source = "TAMING", families = { 7 } }, -- Demoralizing Screech (Rank 4)
	{ level = 56, id = 24597, source = "TAMING", families = { 1 } }, -- Furious Howl (Rank 4)
	{ level = 56, id = 24587, source = "TAMING", families = { 20 } }, -- Scorpid Poison (Rank 4)
	{ level = 60, id = 27685, source = "TAMING", families = { 5 } }, -- Charge (Rank 6)
	{ level = 60, id = 1264933, source = "TAMING", families = { 6 } }, -- Dismember (Rank 5)
	{ level = 60, id = 1265904, source = "TAMING", families = { 12 } }, -- Dust Cloud (Rank 5)
	{ level = 60, id = 5042, source = "HUNTER_TRAINER" }, -- Great Stamina (Rank 10)
	{ level = 60, id = 14921, source = "HUNTER_TRAINER" }, -- Growl (Rank 7)
	{ level = 60, id = 25012, source = "TAMING", families = { 27 } }, -- Lightning Breath (Rank 6)
	{ level = 60, id = 24630, source = "HUNTER_TRAINER" }, -- Natural Armor (Rank 10)
	{ level = 60, id = 1264742, source = "TAMING", families = { 8 } }, -- Pinch (Rank 5)
	{ level = 60, id = 1265069, source = "TAMING", families = { 11 } }, -- Savage Rend (Rank 5)
	{ level = 60, id = 1264482, source = "TAMING", families = { 24 } }, -- Sonic Blast (Rank 5)
	{ level = 60, id = 1264502, source = "TAMING", families = { 4 } }, -- Swipe (Rank 5)
	{ level = 60, id = 1265042, source = "TAMING", families = { 25 } }, -- Tendon Rip (Rank 5)
	{ level = 60, id = 1264455, source = "TAMING", families = { 9 } }, -- Thunderstomp (Rank 4)
	{ level = 60, id = 1265883, source = "TAMING", families = { 3 } }, -- Web (Rank 5)
}

-- [pet spell ID] = { the tameable beasts that know it (ns.TAMEABLE_BEASTS) }, -- Spell Name (Rank N)
ns.PET_ABILITY_BEASTS = {
	[17253] = { 250873, 1509, 1505, 2958, 30, 1688, 1994, 250868, 1138, 1922, 1999, 1131, 471, 2959, 266851, 3110 }, -- Bite (Rank 1)
	[7371] = {
		3098,
		1984,
		1985,
		2966,
		708,
		2954,
		1125,
		113,
		3099,
		1126,
		390,
		1127,
		524,
		1689,
		3100,
		330,
		3225,
		1190,
		119,
	}, -- Charge (Rank 1)
	[16827] = { 3124, 250926, 250937, 3281, 1995, 3106, 251115, 1129, 250928, 1196, 2970 }, -- Claw (Rank 1)
	[1742] = { 1199, 2042, 251245, 1553, 3035, 3121, 2957, 253282, 276198, 3068, 2070, 2321, 3246 }, -- Cower (Rank 1)
	[17255] = {
		254589,
		1133,
		118,
		268530,
		2960,
		1555,
		2001,
		1132,
		1195,
		834,
		250874,
		1765,
		833,
		7319,
		10359,
		1693,
		442,
		270693,
		3461,
	}, -- Bite (Rank 2)
	[16828] = { 1997, 254588, 822, 3108, 3127, 276189, 250927, 5823, 2163, 1778, 1961, 248299, 1130, 2232 }, -- Claw (Rank 2)
	[24423] = { 2971, 199, 154 }, -- Demoralizing Screech (Rank 1)
	[24640] = { 3127, 5823, 3250, 3252 }, -- Scorpid Poison (Rank 1)
	[24604] = { 1765, 833, 274300, 10644 }, -- Furious Howl (Rank 1)
	[1265054] = { 276101, 270298, 270196 }, -- Mine! (Rank 1)
	[26177] = { 454, 1191, 157, 1192, 547 }, -- Charge (Rank 2)
	[1264758] = { 1693, 270693, 1417, 1400 }, -- Dismember (Rank 1)
	[1265899] = { 3246, 2322, 2172 }, -- Dust Cloud (Rank 1)
	[25008] = { 3630, 3631, 3247, 3424, 5756, 5056, 3249 }, -- Lightning Breath (Rank 2)
	[1264735] = { 2232, 830, 2235, 1216, 2236 }, -- Pinch (Rank 1)
	[1265065] = { 3255 }, -- Savage Rend (Rank 1)
	[1264494] = { 1797, 1188, 259388 }, -- Swipe (Rank 1)
	[1265038] = { 4316, 4127, 4129, 4128 }, -- Tendon Rip (Rank 1)
	[1265843] = { 1780, 1781, 10359, 1184, 4263, 256040, 250484, 4007, 539, 217, 3819, 4040, 1111, 4264 }, -- Web (Rank 1)
	[1753] = { 3245, 2237, 2323, 4067, 2384 }, -- Cower (Rank 2)
	[17256] = { 4005, 1923, 1185, 14266, 505, 3823, 4006, 3653, 2172, 2350, 569, 11921, 2476, 521, 4824, 616, 14279 }, -- Bite (Rank 3)
	[16829] = { 1189, 1216, 6788, 3619, 3812, 1225, 3809, 2351, 4821, 4822 }, -- Claw (Rank 3)
	[26064] = { 3653, 4824, 4887, 4825, 2408, 14223 }, -- Shell Shield (Rank 1)
	[1310612] = { 277645 }, -- Trickster's Dance (Rank 1)
	[17257] = { 628, 1112, 2349, 1258, 4887, 2089, 2348, 4825, 260809, 3825, 260803, 574, 3821, 2408, 14223 }, -- Bite (Rank 4)
	[26178] = { 345, 4511, 4514, 4512 }, -- Charge (Rank 3)
	[16830] = { 4823, 3810, 4696, 4140 }, -- Claw (Rank 4)
	[24577] = { 213795 }, -- Demoralizing Screech (Rank 2)
	[1264927] = { 260796, 260797, 1150 }, -- Dismember (Rank 2)
	[1265901] = { 4724 }, -- Dust Cloud (Rank 2)
	[24605] = { 1258, 3825, 2729, 5287, 2925 }, -- Furious Howl (Rank 2)
	[25009] = { 3472, 4117, 4118, 4119 }, -- Lightning Breath (Rank 3)
	[1264736] = { 4823, 12347 }, -- Pinch (Rank 2)
	[1265066] = { 1015, 1021, 1016, 1017, 1022, 1023, 1018, 260800, 1019, 855 }, -- Savage Rend (Rank 2)
	[24583] = { 4696, 4140, 4139, 7078, 5937, 4699 }, -- Scorpid Poison (Rank 2)
	[1264497] = { 271334, 2356 }, -- Swipe (Rank 2)
	[1265039] = { 4248, 4249, 4548 }, -- Tendon Rip (Rank 2)
	[1265878] = { 949, 3820, 2349, 930 }, -- Web (Rank 2)
	[1754] = { 4126, 2385, 683, 4538, 681, 736, 4539 }, -- Cower (Rank 3)
	[23099] = { 4724, 976, 682, 4304, 4688, 4950, 2727, 767, 2850, 729, 2728, 4662, 2729 }, -- Dash (Rank 1)
	[23145] = { 4538, 2578, 4539, 2579, 6013, 4693, 4861 }, -- Dive (Rank 1)
	[24450] = { 2406, 2731, 684, 768 }, -- Prowl (Rank 1)
	[26090] = { 1108, 1114 }, -- Thunderstomp (Rank 1)
	[17258] = { 2563, 4143, 2565, 4341, 4413, 2727, 4396, 4411, 4412, 4344 }, -- Bite (Rank 5)
	[16831] = { 4697, 5937, 4343, 7022 }, -- Claw (Rank 5)
	[1755] = { 3241, 2731, 4861, 2732 }, -- Cower (Rank 4)
	[25010] = { 5307, 5308 }, -- Lightning Breath (Rank 4)
	[17259] = { 2753, 14233, 769, 4345, 5286, 4400, 1087, 5356, 8211, 4841, 8762, 8959, 14339 }, -- Bite (Rank 6)
	[16832] = { 922, 5422, 5268, 731, 1088, 5352 }, -- Claw (Rank 6)
	[23109] = { 2734, 728, 5286, 5425, 1713, 2730, 8211, 8208, 5426, 2926, 5427 }, -- Dash (Rank 2)
	[23147] = { 5307, 5428, 5429, 5308, 8207, 5430, 7097, 5349 }, -- Dive (Rank 2)
	[24603] = { 5286, 5356, 2924, 8959, 14339 }, -- Furious Howl (Rank 3)
	[24452] = { 2734, 1713, 731 }, -- Prowl (Rank 2)
	[24586] = { 5422, 7405, 5423, 5424, 7803, 8926, 5988, 9691, 9695, 11735 }, -- Scorpid Poison (Rank 3)
	[26187] = { 1557, 5262 }, -- Thunderstomp (Rank 2)
	[1756] = { 2522, 8600, 8601 }, -- Cower (Rank 5)
	[17260] = { 8277, 2505, 8933, 3581, 2681, 8213, 8961, 6585, 1817, 1824 }, -- Bite (Rank 7)
	[26201] = { 5992, 8303 }, -- Charge (Rank 5)
	[3010] = { 5274, 8958, 7099, 14344, 14343, 7444, 8301, 7455, 9695, 1816 }, -- Claw (Rank 7)
	[25011] = { 5349, 8336, 5291, 5708 }, -- Lightning Breath (Rank 5)
	[23110] = { 250619, 2681, 8303, 8300, 9416, 7055, 9696, 10200, 7433, 7432, 11365 }, -- Dash (Rank 3)
	[23148] = { 7099, 8927, 1809, 5708, 7098, 14343, 8299, 8600, 7455, 2931, 7456 }, -- Dive (Rank 3)
	[24453] = { 2522, 7432 }, -- Prowl (Rank 3)
	[26188] = { 6516, 9622 }, -- Thunderstomp (Rank 3)
	[16697] = { 7430, 8602 }, -- Cower (Rank 6)
	[17261] = { 9696 }, -- Bite (Rank 8)
	[3009] = { 7456, 7445 }, -- Claw (Rank 8)
	[24597] = { 9696 }, -- Furious Howl (Rank 4)
	[24587] = { 14476, 9698, 11736, 11737 }, -- Scorpid Poison (Rank 4)
	[27685] = { 16117 }, -- Charge (Rank 6)
	[25012] = { 11357 }, -- Lightning Breath (Rank 6)
}

-- [NPC ID] = { name, lowest level, highest level, zone (AreaTable ID) },
ns.TAMEABLE_BEASTS = {
	[30] = { "Forest Spider", 5, 6, 12 },
	[113] = { "Stonetusk Boar", 5, 6, 12 },
	[118] = { "Prowler", 9, 10, 12 },
	[119] = { "Longsnout", 10, 11, 12 },
	[154] = { "Greater Fleshripper", 16, 17, 40 },
	[157] = { "Goretusk", 14, 15, 40 },
	[199] = { "Young Fleshripper", 10, 11, 40 },
	[217] = { "Venom Web Spider", 19, 20, 10 },
	[330] = { "Princess", 9, 9, 12 },
	[345] = { "Bellygrub", 24, 24, 44 },
	[390] = { "Porcine Entourage", 7, 7, 12 },
	[442] = { "Tarantula", 15, 16, 44 },
	[454] = { "Young Goretusk", 12, 13, 40 },
	[471] = { "Mother Fang", 7, 7, 12 },
	[505] = { "Greater Tarantula", 19, 20, 44 },
	[521] = { "Lupos", 23, 23, 10 },
	[524] = { "Rockhide Boar", 7, 8, 12 },
	[539] = { "Pygmy Venom Web Spider", 18, 19, 10 },
	[547] = { "Great Goretusk", 16, 17, 44 },
	[569] = { "Green Recluse", 21, 22, 10 },
	[574] = { "Naraxis", 27, 27, 10 },
	[616] = { "Chatter", 23, 23, 44 },
	[628] = { "Black Ravager", 24, 25, 10 },
	[681] = { "Young Stranglethorn Tiger", 30, 31, 33 },
	[682] = { "Stranglethorn Tiger", 32, 33, 33 },
	[683] = { "Young Panther", 30, 31, 33 },
	[684] = { "Shadowmaw Panther", 37, 38, 33 },
	[708] = { "Small Crag Boar", 3, 3, 1 },
	[728] = { "Bhag'thera", 40, 40, 33 },
	[729] = { "Sin'Dall", 37, 37, 33 },
	[731] = { "King Bangalash", 43, 43, 33 },
	[736] = { "Panther", 32, 33, 33 },
	[767] = { "Swamp Jaguar", 36, 37, 8 },
	[768] = { "Shadow Panther", 39, 40, 8 },
	[769] = { "Deathstrike Tarantula", 40, 41, 8 },
	[822] = { "Young Forest Bear", 8, 9, 12 },
	[830] = { "Sand Crawler", 13, 14, 40 },
	[833] = { "Coyote Packleader", 11, 12, 40 },
	[834] = { "Coyote", 10, 11, 40 },
	[855] = { "Young Stranglethorn Raptor", 30, 31, 33 },
	[922] = { "Silt Crawler", 40, 41, 8 },
	[930] = { "Black Widow Hatchling", 24, 25, 10 },
	[949] = { "Carrion Recluse", 21, 22, 10 },
	[976] = { "Kurzen War Tiger", 32, 33, 33 },
	[1015] = { "Highland Raptor", 23, 24, 11 },
	[1016] = { "Highland Lashtail", 24, 25, 11 },
	[1017] = { "Highland Scytheclaw", 25, 26, 11 },
	[1018] = { "Highland Razormaw", 27, 28, 11 },
	[1019] = { "Elder Razormaw", 29, 29, 11 },
	[1021] = { "Mottled Screecher", 24, 25, 11 },
	[1022] = { "Mottled Scytheclaw", 25, 26, 11 },
	[1023] = { "Mottled Razormaw", 26, 27, 11 },
	[1087] = { "Sawtooth Snapper", 41, 42, 8 },
	[1088] = { "Monstrous Crawler", 43, 44, 8 },
	[1108] = { "Mistvale Gorilla", 32, 33, 33 },
	[1111] = { "Leech Stalker", 21, 22, 11 },
	[1112] = { "Leech Widow", 24, 24, 11 },
	[1114] = { "Jungle Thunderer", 37, 38, 33 },
	[1125] = { "Crag Boar", 5, 6, 1 },
	[1126] = { "Large Crag Boar", 6, 7, 1 },
	[1127] = { "Elder Crag Boar", 7, 8, 1 },
	[1129] = { "Black Bear", 7, 7, 1 },
	[1130] = { "Bjarn", 12, 12, 1 },
	[1131] = { "Winter Wolf", 7, 8, 1 },
	[1132] = { "Timber", 10, 10, 1 },
	[1133] = { "Starving Winter Wolf", 8, 9, 1 },
	[1138] = { "Snow Tracker Wolf", 6, 7, 1 },
	[1150] = { "River Crocolisk", 30, 31, 33 },
	[1184] = { "Cliff Lurker", 13, 14, 38 },
	[1185] = { "Wood Lurker", 17, 18, 38 },
	[1188] = { "Grizzled Black Bear", 13, 14, 38 },
	[1189] = { "Black Bear Patriarch", 16, 17, 38 },
	[1190] = { "Mountain Boar", 10, 11, 38 },
	[1191] = { "Mangy Mountain Boar", 14, 15, 38 },
	[1192] = { "Elder Mountain Boar", 16, 17, 38 },
	[1195] = { "Forest Lurker", 10, 11, 38 },
	[1196] = { "Ice Claw Bear", 7, 8, 1 },
	[1199] = { "Juvenile Snow Leopard", 5, 6, 1 },
	[1216] = { "Shorecrawler", 17, 18, 40 },
	[1225] = { "Ol' Sooty", 20, 20, 38 },
	[1258] = { "Black Ravager Mastiff", 25, 26, 10 },
	[1400] = { "Wetlands Crocolisk", 23, 24, 11 },
	[1417] = { "Young Wetlands Crocolisk", 21, 22, 11 },
	[1505] = { "Night Web Spider", 3, 4, 85 },
	[1509] = { "Ragged Scavenger", 2, 3, 85 },
	[1553] = { "Greater Duskbat", 6, 7, 85 },
	[1555] = { "Vicious Night Web Spider", 9, 10, 85 },
	[1557] = { "Elder Mistvale Gorilla", 40, 41, 33 },
	[1688] = { "Night Web Matriarch", 5, 5, 85 },
	[1689] = { "Scarred Crag Boar", 9, 10, 1 },
	[1693] = { "Loch Crocolisk", 14, 15, 38 },
	[1713] = { "Elder Shadowmaw Panther", 42, 43, 33 },
	[1765] = { "Worg", 10, 11, 130 },
	[1778] = { "Ferocious Grizzled Bear", 11, 12, 130 },
	[1780] = { "Moss Stalker", 12, 13, 130 },
	[1781] = { "Mist Creeper", 13, 14, 130 },
	[1797] = { "Giant Grizzled Bear", 12, 13, 130 },
	[1809] = { "Carrion Vulture", 50, 52, 28 },
	[1816] = { "Diseased Grizzly", 55, 56, 28 },
	[1817] = { "Diseased Wolf", 53, 54, 28 },
	[1824] = { "Plague Lurker", 54, 55, 28 },
	[1922] = { "Gray Forest Wolf", 7, 8, 12 },
	[1923] = { "Bloodsnout Worg", 16, 17, 130 },
	[1961] = { "Mangeclaw", 11, 11, 1 },
	[1984] = { "Young Thistle Boar", 1, 2, 141 },
	[1985] = { "Thistle Boar", 2, 3, 141 },
	[1994] = { "Githyiss the Vile", 5, 5, 141 },
	[1995] = { "Strigid Owl", 5, 6, 141 },
	[1997] = { "Strigid Hunter", 8, 9, 141 },
	[1999] = { "Webwood Venomfang", 7, 8, 141 },
	[2001] = { "Giant Webwood Spider", 10, 11, 141 },
	[2042] = { "Nightsaber", 5, 6, 141 },
	[2070] = { "Moonstalker Runt", 10, 11, 148 },
	[2089] = { "Giant Wetlands Crocolisk", 25, 26, 11 },
	[2163] = { "Thistle Bear", 11, 12, 148 },
	[2172] = { "Strider Clutchmother", 20, 20, 148 },
	[2232] = { "Tide Crawler", 12, 14, 148 },
	[2235] = { "Reef Crawler", 15, 17, 148 },
	[2236] = { "Raging Reef Crawler", 20, 21, 148 },
	[2237] = { "Moonstalker Sire", 17, 19, 148 },
	[2321] = { "Foreststrider Fledgling", 11, 13, 148 },
	[2322] = { "Foreststrider", 14, 16, 148 },
	[2323] = { "Giant Foreststrider", 17, 19, 148 },
	[2348] = { "Elder Moss Creeper", 26, 27, 267 },
	[2349] = { "Giant Moss Creeper", 24, 25, 267 },
	[2350] = { "Forest Moss Creeper", 20, 21, 267 },
	[2351] = { "Gray Bear", 21, 22, 267 },
	[2356] = { "Elder Gray Bear", 25, 26, 267 },
	[2384] = { "Starving Mountain Lion", 23, 24, 267 },
	[2385] = { "Feral Mountain Lion", 27, 28, 267 },
	[2406] = { "Mountain Lion", 32, 33, 36 },
	[2408] = { "Snapjaw", 30, 31, 267 },
	[2476] = { "Large Loch Crocolisk", 22, 22, 38 },
	[2505] = { "Saltwater Snapjaw", 49, 50, 47 },
	[2522] = { "Jaguero Stalker", 50, 50, 33 },
	[2563] = { "Plains Creeper", 32, 33, 45 },
	[2565] = { "Giant Plains Creeper", 35, 36, 45 },
	[2578] = { "Young Mesa Buzzard", 31, 32, 45 },
	[2579] = { "Mesa Buzzard", 34, 35, 45 },
	[2681] = { "Vilebranch Raiding Wolf", 50, 51, 47 },
	[2727] = { "Crag Coyote", 35, 36, 3 },
	[2728] = { "Feral Crag Coyote", 37, 38, 3 },
	[2729] = { "Elder Crag Coyote", 39, 40, 3 },
	[2730] = { "Rabid Crag Coyote", 42, 43, 3 },
	[2731] = { "Ridge Stalker", 36, 37, 3 },
	[2732] = { "Ridge Huntress", 38, 39, 3 },
	[2734] = { "Ridge Stalker Patriarch", 40, 41, 3 },
	[2753] = { "Barnabus", 38, 38, 3 },
	[2850] = { "Broken Tooth", 37, 37, 3 },
	[2924] = { "Silvermane Wolf", 43, 44, 47 },
	[2925] = { "Silvermane Howler", 45, 46, 47 },
	[2926] = { "Silvermane Stalker", 47, 48, 47 },
	[2931] = { "Zaricotl", 55, 55, 3 },
	[2954] = { "Bristleback Battleboar", 4, 5, 215 },
	[2957] = { "Elder Plainstrider", 8, 9, 215 },
	[2958] = { "Prairie Wolf", 5, 6, 215 },
	[2959] = { "Prairie Stalker", 7, 8, 215 },
	[2960] = { "Prairie Wolf Alpha", 9, 10, 215 },
	[2966] = { "Battleboar", 3, 4, 215 },
	[2970] = { "Swoop", 7, 9, 215 },
	[2971] = { "Taloned Swoop", 8, 10, 215 },
	[3035] = { "Flatland Cougar", 7, 8, 215 },
	[3068] = { "Mazzranache", 9, 9, 215 },
	[3098] = { "Mottled Boar", 1, 2, 14 },
	[3099] = { "Dire Mottled Boar", 6, 7, 14 },
	[3100] = { "Elder Mottled Boar", 9, 10, 14 },
	[3106] = { "Pygmy Surf Crawler", 5, 6, 14 },
	[3108] = { "Encrusted Surf Crawler", 9, 10, 14 },
	[3110] = { "Dreadmaw Crocolisk", 9, 11, 14 },
	[3121] = { "Durotar Tiger", 7, 8, 14 },
	[3124] = { "Scorpid Worker", 3, 3, 14 },
	[3127] = { "Venomtail Scorpid", 9, 10, 14 },
	[3225] = { "Corrupted Mottled Boar", 10, 11, 14 },
	[3241] = { "Savannah Patriarch", 14, 16, 17 },
	[3245] = { "Ornery Plainstrider", 16, 17, 17 },
	[3246] = { "Fleeting Plainstrider", 12, 13, 17 },
	[3247] = { "Thunderhawk Hatchling", 18, 20, 17 },
	[3249] = { "Greater Thunderhawk", 23, 24, 17 },
	[3250] = { "Silithid Creeper", 20, 21, 17 },
	[3252] = { "Sillithid Swarmer", 21, 22, 17 },
	[3255] = { "Sunscale Screecher", 13, 15, 17 },
	[3281] = { "Sarkoth", 4, 4, 14 },
	[3424] = { "Thunderhawk Cloudscraper", 20, 22, 17 },
	[3461] = { "Oasis Snapjaw", 15, 16, 17 },
	[3472] = { "Washte Pawne", 25, 25, 17 },
	[3581] = { "Sewer Beast", 50, 50, 1519 },
	[3619] = { "Ghost Saber", 19, 20, 148 },
	[3630] = { "Deviate Coiler", 15, 16, 17 },
	[3631] = { "Deviate Stinglash", 16, 17, 718 },
	[3653] = { "Kresh", 20, 20, 718 },
	[3809] = { "Ashenvale Bear", 21, 22, 331 },
	[3810] = { "Elder Ashenvale Bear", 25, 26, 331 },
	[3812] = { "Clattering Crawler", 19, 20, 331 },
	[3819] = { "Wildthorn Stalker", 20, 21, 331 },
	[3820] = { "Wildthorn Venomspitter", 24, 25, 331 },
	[3821] = { "Wildthorn Lurker", 28, 29, 331 },
	[3823] = { "Ghostpaw Runner", 19, 20, 331 },
	[3825] = { "Ghostpaw Alpha", 27, 28, 331 },
	[4005] = { "Deepmoss Creeper", 16, 17, 406 },
	[4006] = { "Deepmoss Webspinner", 19, 20, 406 },
	[4007] = { "Deepmoss Venomspitter", 17, 18, 406 },
	[4040] = { "Cave Stalker", 21, 22, 11 },
	[4067] = { "Twilight Runner", 23, 24, 406 },
	[4117] = { "Cloud Serpent", 25, 26, 400 },
	[4118] = { "Venomous Cloud Serpent", 26, 28, 400 },
	[4119] = { "Elder Cloud Serpent", 27, 29, 400 },
	[4126] = { "Crag Stalker", 25, 26, 400 },
	[4127] = { "Hecklefang Hyena", 15, 16, 17 },
	[4128] = { "Hecklefang Stalker", 22, 23, 17 },
	[4129] = { "Hecklefang Snarler", 18, 19, 17 },
	[4139] = { "Scorpid Terror", 33, 34, 400 },
	[4140] = { "Scorpid Reaver", 31, 32, 400 },
	[4143] = { "Sparkleshell Snapper", 34, 35, 400 },
	[4248] = { "Pesterhide Hyena", 26, 27, 400 },
	[4249] = { "Pesterhide Snarler", 28, 29, 400 },
	[4263] = { "Deepmoss Hatchling", 14, 14, 406 },
	[4264] = { "Deepmoss Matriarch", 22, 22, 406 },
	[4304] = { "Scarlet Tracking Hound", 33, 34, 796 },
	[4316] = { "Kolkar Packhound", 13, 13, 17 },
	[4341] = { "Drywallow Crocolisk", 35, 36, 15 },
	[4343] = { "Drywallow Snapper", 37, 38, 15 },
	[4344] = { "Mottled Drywallow Crocolisk", 38, 39, 15 },
	[4345] = { "Drywallow Daggermaw", 40, 41, 15 },
	[4396] = { "Mudrock Tortoise", 36, 37, 15 },
	[4400] = { "Mudrock Snapjaw", 41, 42, 15 },
	[4411] = { "Darkfang Lurker", 36, 37, 15 },
	[4412] = { "Darkfang Creeper", 38, 39, 15 },
	[4413] = { "Darkfang Spider", 35, 36, 15 },
	[4511] = { "Agam'ar", 24, 25, 491 },
	[4512] = { "Rotting Agam'ar", 27, 28, 491 },
	[4514] = { "Raging Agam'ar", 25, 26, 491 },
	[4538] = { "Kraul Bat", 30, 31, 491 },
	[4539] = { "Greater Kraul Bat", 32, 32, 491 },
	[4548] = { "Steelsnap", 30, 30, 400 },
	[4662] = { "Magram Bonepaw", 37, 38, 405 },
	[4688] = { "Bonepaw Hyena", 33, 35, 405 },
	[4693] = { "Dread Flyer", 36, 37, 405 },
	[4696] = { "Scorpashi Snapper", 30, 31, 405 },
	[4697] = { "Scorpashi Lasher", 34, 35, 405 },
	[4699] = { "Scorpashi Venomlash", 38, 39, 405 },
	[4724] = { "Sandstrider", 30, 31, 405 },
	[4821] = { "Skittering Crustacean", 22, 23, 719 },
	[4822] = { "Snapping Crustacean", 22, 23, 719 },
	[4823] = { "Barbed Crustacean", 25, 26, 719 },
	[4824] = { "Aku'mai Fisher", 23, 24, 719 },
	[4825] = { "Aku'mai Snapjaw", 26, 27, 719 },
	[4841] = { "Deadmire", 45, 45, 15 },
	[4861] = { "Shrike Bat", 38, 39, 1337 },
	[4887] = { "Ghamoo-ra", 25, 25, 719 },
	[4950] = { "Spot", 35, 35, 15 },
	[5056] = { "Deviate Dreadfang", 20, 21, 718 },
	[5262] = { "Groddoc Thunderer", 49, 50, 357 },
	[5268] = { "Ironfur Bear", 41, 42, 357 },
	[5274] = { "Ironfur Patriarch", 48, 49, 357 },
	[5286] = { "Longtooth Runner", 40, 41, 357 },
	[5287] = { "Longtooth Howler", 43, 44, 357 },
	[5291] = { "Hakkari Frostwing", 49, 50, 1477 },
	[5307] = { "Vale Screecher", 41, 43, 357 },
	[5308] = { "Rogue Vale Screecher", 44, 46, 357 },
	[5349] = { "Arash-ethis", 49, 49, 357 },
	[5352] = { "Old Grizzlegut", 43, 43, 357 },
	[5356] = { "Snarler", 42, 42, 357 },
	[5422] = { "Scorpid Hunter", 40, 41, 440 },
	[5423] = { "Scorpid Tail Lasher", 43, 44, 440 },
	[5424] = { "Scorpid Dunestalker", 46, 47, 440 },
	[5425] = { "Starving Blisterpaw", 41, 42, 440 },
	[5426] = { "Blisterpaw Hyena", 44, 45, 440 },
	[5427] = { "Rabid Blisterpaw", 47, 48, 440 },
	[5428] = { "Roc", 42, 43, 440 },
	[5429] = { "Fire Roc", 43, 45, 440 },
	[5430] = { "Searing Roc", 47, 49, 440 },
	[5708] = { "Spawn of Hakkar", 51, 51, 1477 },
	[5756] = { "Deviate Venomwing", 20, 21, 718 },
	[5823] = { "Death Flayer", 11, 11, 14 },
	[5937] = { "Vile Sting", 35, 35, 400 },
	[5988] = { "Scorpok Stinger", 50, 51, 4 },
	[5992] = { "Ashmane Boar", 48, 49, 4 },
	[6013] = { "Wayward Buzzard", 35, 37, 3 },
	[6516] = { "Un'Goro Thunderer", 52, 53, 490 },
	[6585] = { "Uhk'loc", 52, 52, 490 },
	[6788] = { "Den Mother", 19, 19, 148 },
	[7022] = { "Venomlash Scorpid", 39, 40, 1337 },
	[7055] = { "Blackrock Worg", 54, 55, 46 },
	[7078] = { "Cleft Scorpid", 35, 36, 1337 },
	[7097] = { "Ironbeak Owl", 48, 49, 361 },
	[7098] = { "Ironbeak Screecher", 52, 53, 361 },
	[7099] = { "Ironbeak Hunter", 50, 51, 361 },
	[7319] = { "Lady Sathrah", 12, 12, 141 },
	[7405] = { "Deadly Cleft Scorpid", 42, 43, 1337 },
	[7430] = { "Frostsaber Cub", 55, 56, 618 },
	[7432] = { "Frostsaber Stalker", 59, 60, 618 },
	[7433] = { "Frostsaber Huntress", 58, 59, 618 },
	[7444] = { "Shardtooth Bear", 53, 54, 618 },
	[7445] = { "Elder Shardtooth", 57, 58, 618 },
	[7455] = { "Winterspring Owl", 54, 56, 618 },
	[7456] = { "Winterspring Screecher", 57, 59, 618 },
	[7803] = { "Scorpid Duneburrower", 46, 47, 440 },
	[8207] = { "Greater Firebird", 46, 46, 440 },
	[8208] = { "Murderous Blisterpaw", 43, 43, 440 },
	[8211] = { "Old Cliff Jumper", 42, 42, 47 },
	[8213] = { "Ironback", 51, 51, 47 },
	[8277] = { "Rekk'tilac", 48, 48, 51 },
	[8299] = { "Spiteflayer", 52, 52, 4 },
	[8300] = { "Ravage", 51, 51, 4 },
	[8301] = { "Clack the Reaver", 53, 53, 4 },
	[8303] = { "Grunter", 50, 50, 4 },
	[8336] = { "Hakkari Sapper", 49, 50, 1477 },
	[8600] = { "Plaguebat", 53, 55, 139 },
	[8601] = { "Noxious Plaguebat", 54, 56, 139 },
	[8602] = { "Monstrous Plaguebat", 56, 58, 139 },
	[8762] = { "Timberweb Recluse", 47, 48, 16 },
	[8926] = { "Deep Stinger", 50, 52, 1584 },
	[8927] = { "Dark Screecher", 50, 52, 1584 },
	[8933] = { "Cave Creeper", 50, 52, 1584 },
	[8958] = { "Angerclaw Mauler", 49, 50, 361 },
	[8959] = { "Felpaw Wolf", 47, 48, 361 },
	[8961] = { "Felpaw Ravager", 51, 52, 361 },
	[9416] = { "Scarshield Worg", 53, 54, 1583 },
	[9622] = { "U'cha", 55, 55, 490 },
	[9691] = { "Venomtip Scorpid", 52, 53, 46 },
	[9695] = { "Deathlash Scorpid", 54, 55, 46 },
	[9696] = { "Bloodaxe Worg", 56, 57, 1583 },
	[9698] = { "Firetail Scorpid", 56, 57, 46 },
	[10200] = { "Rak'Shiri", 57, 57, 618 },
	[10359] = { "Sri'Skulk", 13, 13, 85 },
	[10644] = { "Mist Howler", 22, 22, 331 },
	[11357] = { "Son of Hakkar", 60, 60, 1977 },
	[11365] = { "Zulian Panther", 60, 60, 1977 },
	[11735] = { "Stonelash Scorpid", 54, 55, 1377 },
	[11736] = { "Stonelash Pincer", 56, 57, 1377 },
	[11737] = { "Stonelash Flayer", 58, 59, 1377 },
	[11921] = { "Besseleth", 21, 21, 406 },
	[12347] = { "Enraged Reef Crawler", 30, 32, 405 },
	[14223] = { "Cranky Benj", 32, 32, 36 },
	[14233] = { "Ripscale", 39, 39, 15 },
	[14266] = { "Shanda the Spinner", 19, 19, 38 },
	[14279] = { "Creepthess", 24, 24, 267 },
	[14339] = { "Death Howl", 49, 49, 361 },
	[14343] = { "Olm the Wise", 52, 52, 361 },
	[14344] = { "Mongress", 50, 50, 361 },
	[14476] = { "Krellack", 56, 56, 1377 },
	[16117] = { "Plagued Swine", 60, 60, 139 },
	[213795] = { "Gharrik", 40, 40, 3 },
	[248299] = { "Elmpaw", 12, 12, 12 },
	[250484] = { "Spider", 15, 16, 153 },
	[250619] = { "Broodwidow", 16, 16, 153 },
	[250868] = { "Vuldren", 6, 6, 16593 },
	[250873] = { "Juvenile Vuldren", 1, 1, 16593 },
	[250874] = { "Vuldren Alpha", 10, 10, 16593 },
	[250926] = { "Scrawny Ursera", 3, 4, 16593 },
	[250927] = { "Shadowgale Ursera", 10, 11, 16593 },
	[250928] = { "Highlands Ursera", 7, 8, 16593 },
	[250937] = { "Ursera Scavenger", 4, 4, 16593 },
	[251115] = { "Urs'anah", 5, 5, 16593 },
	[251245] = { "Prideclaw", 5, 5, 16593 },
	[253282] = { "Shriekling Fledgling", 8, 9, 16593 },
	[254588] = { "Windsong Crawler", 8, 9, 16593 },
	[254589] = { "Vulgara the Insatiable", 8, 8, 16593 },
	[256040] = { "Deep Widow", 15, 16, 153 },
	[259388] = { "Mystmane", 13, 13, 16593 },
	[260796] = { "Marsh Crocolisk", 26, 26, 16732 },
	[260797] = { "Elder Crocolisk", 27, 27, 16732 },
	[260800] = { "Thicket Lurker", 27, 27, 16732 },
	[260803] = { "Highland Spider", 27, 28, 11 },
	[260809] = { "Highland Tortoise", 26, 26, 11 },
	[266851] = { "Ukorsbane", 8, 8, 14 },
	[268530] = { "Bloodtalon Matriarch", 9, 9, 14 },
	[270196] = { "Jai'vhanel", 12, 12, 148 },
	[270298] = { "Child of Jai'vhanel", 11, 12, 148 },
	[270693] = { "Daggerfang", 15, 15, 38 },
	[271334] = { "Maddened Rotclaw", 25, 26, 11 },
	[274300] = { "Coldrasp", 12, 12, 85 },
	[276101] = { "Nightscreech", 10, 10, 141 },
	[276189] = { "Matriarch Bristlefur", 10, 10, 12 },
	[276198] = { "Shal'ma", 9, 9, 14 },
	[277645] = { "Gray Fox", 22, 23, 10 },
}

--[[
	The warlock's demon abilities, one row per rank: level is the warlock level the demon trainer offers it at,
	id the demon's spell, source DEMON_TRAINER, families the demons that learn it. WoW Forever has no grimoires
	(so no item): the demon trainer teaches the rank.
]]
ns.DEMON_ABILITIES = {
	{ level = 4, id = 6307, source = "DEMON_TRAINER", families = { 23 } }, -- Blood Pact (Rank 1)
	{ level = 8, id = 7799, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 2)
	{ level = 12, id = 4511, source = "DEMON_TRAINER", families = { 23 } }, -- Phase Shift
	{ level = 14, id = 7804, source = "DEMON_TRAINER", families = { 23 } }, -- Blood Pact (Rank 2)
	{ level = 14, id = 2947, source = "DEMON_TRAINER", families = { 23 } }, -- Fire Shield (Rank 1)
	{ level = 16, id = 7812, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 1)
	{ level = 18, id = 17767, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 1)
	{ level = 18, id = 7800, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 3)
	{ level = 20, id = 7809, source = "DEMON_TRAINER", families = { 16 } }, -- Torment (Rank 2)
	{ level = 22, id = 6360, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Soothing Kiss (Rank 1)
	{ level = 24, id = 8316, source = "DEMON_TRAINER", families = { 23 } }, -- Fire Shield (Rank 2)
	{ level = 24, id = 19438, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 2)
	{ level = 24, id = 17735, source = "DEMON_TRAINER", families = { 16 } }, -- Suffering (Rank 1)
	{ level = 26, id = 7805, source = "DEMON_TRAINER", families = { 23 } }, -- Blood Pact (Rank 3)
	{ level = 26, id = 17850, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 2)
	{ level = 26, id = 6358, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Seduction
	{ level = 28, id = 7801, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 4)
	{ level = 28, id = 7815, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lash of Pain (Rank 2)
	{ level = 30, id = 7810, source = "DEMON_TRAINER", families = { 16 } }, -- Torment (Rank 3)
	{ level = 32, id = 7870, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lesser Invisibility
	{ level = 32, id = 19440, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 3)
	{ level = 32, id = 19478, source = "DEMON_TRAINER", families = { 15 } }, -- Tainted Blood (Rank 1)
	{ level = 34, id = 17851, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 3)
	{ level = 34, id = 8317, source = "DEMON_TRAINER", families = { 23 } }, -- Fire Shield (Rank 3)
	{ level = 34, id = 7813, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Soothing Kiss (Rank 2)
	{ level = 36, id = 7816, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lash of Pain (Rank 3)
	{ level = 36, id = 19244, source = "DEMON_TRAINER", families = { 15 } }, -- Spell Lock (Rank 1)
	{ level = 36, id = 17750, source = "DEMON_TRAINER", families = { 16 } }, -- Suffering (Rank 2)
	{ level = 38, id = 11766, source = "DEMON_TRAINER", families = { 23 } }, -- Blood Pact (Rank 4)
	{ level = 38, id = 19731, source = "DEMON_TRAINER", families = { 15 } }, -- Devour Magic (Rank 2)
	{ level = 38, id = 7802, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 5)
	{ level = 40, id = 19441, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 4)
	{ level = 40, id = 19655, source = "DEMON_TRAINER", families = { 15 } }, -- Tainted Blood (Rank 2)
	{ level = 40, id = 7811, source = "DEMON_TRAINER", families = { 16 } }, -- Torment (Rank 4)
	{ level = 42, id = 17852, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 4)
	{ level = 42, id = 19480, source = "DEMON_TRAINER", families = { 15 } }, -- Paranoia
	{ level = 44, id = 11770, source = "DEMON_TRAINER", families = { 23 } }, -- Fire Shield (Rank 4)
	{ level = 44, id = 11778, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lash of Pain (Rank 4)
	{ level = 46, id = 19734, source = "DEMON_TRAINER", families = { 15 } }, -- Devour Magic (Rank 3)
	{ level = 46, id = 11784, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Soothing Kiss (Rank 3)
	{ level = 48, id = 11762, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 6)
	{ level = 48, id = 19442, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 5)
	{ level = 48, id = 17751, source = "DEMON_TRAINER", families = { 16 } }, -- Suffering (Rank 3)
	{ level = 48, id = 19656, source = "DEMON_TRAINER", families = { 15 } }, -- Tainted Blood (Rank 3)
	{ level = 50, id = 11767, source = "DEMON_TRAINER", families = { 23 } }, -- Blood Pact (Rank 5)
	{ level = 50, id = 17853, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 5)
	{ level = 50, id = 11774, source = "DEMON_TRAINER", families = { 16 } }, -- Torment (Rank 5)
	{ level = 52, id = 11779, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lash of Pain (Rank 5)
	{ level = 52, id = 19647, source = "DEMON_TRAINER", families = { 15 } }, -- Spell Lock (Rank 2)
	{ level = 54, id = 19736, source = "DEMON_TRAINER", families = { 15 } }, -- Devour Magic (Rank 4)
	{ level = 54, id = 11771, source = "DEMON_TRAINER", families = { 23 } }, -- Fire Shield (Rank 5)
	{ level = 56, id = 19443, source = "DEMON_TRAINER", families = { 16 } }, -- Sacrifice (Rank 6)
	{ level = 56, id = 19660, source = "DEMON_TRAINER", families = { 15 } }, -- Tainted Blood (Rank 4)
	{ level = 58, id = 17854, source = "DEMON_TRAINER", families = { 16 } }, -- Consume Shadows (Rank 6)
	{ level = 58, id = 11763, source = "DEMON_TRAINER", families = { 23 } }, -- Firebolt (Rank 7)
	{ level = 58, id = 11785, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Soothing Kiss (Rank 4)
	{ level = 60, id = 11780, source = "DEMON_TRAINER", families = { 17, 302 } }, -- Lash of Pain (Rank 6)
	{ level = 60, id = 17752, source = "DEMON_TRAINER", families = { 16 } }, -- Suffering (Rank 4)
	{ level = 60, id = 11775, source = "DEMON_TRAINER", families = { 16 } }, -- Torment (Rank 6)
}

--[[
How We Got the Data

Last Validated
	2026-11-15, WoW Forever 1.60.1.70938

Notes
	- The hunter pet ability ranks for the Pet What's Next? tab (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Pet.lua), which shows only where this table has rows, and for Ability Alerts While Leveling's pet lines (Features/Rank-Watch/Rank-Watch-Level-Up.lua), which take only the HUNTER_TRAINER rows.
	- On WoW Forever a pet's abilities never rank up on their own as it levels. It gets a rank one of two ways: the hunter's trainer teaches it (HUNTER_TRAINER), or it's a beast that knew the rank when tamed (TAMING).
	- HUNTER_TRAINER rows: Great Stamina, Natural Armor, Growl from Rank 3 and the five resistances. A WoW Forever hunter trainer lists them among its own services, and buying one teaches the pet out; a level 13 fox showed Growl, Great Stamina and Natural Armor at Rank 2 in its spellbook. level is the level the trainer offers the rank, the level each hunter trainer window recorded (Features/Enhanced-Spellbook/Trainer-Recording.lua). It matches SpellLevels on wago.tools but for Great Stamina and Natural Armor Rank 1, which SpellLevels puts at 1 where the trainer offers them at 10, and Shadow Resistance Rank 4 (24507), which SpellLevels puts at 40 where the trainer offers it at 50. The rows began as What's Training's WoW Forever hunter trainer list (Data/LICENSE-Trainer-Data), which had them among the hunter's own spells; Data/Camelot/Trainer-Spells-Camelot.lua leaves them out.
	- TAMING rows: every ranked spell on a hunter pet family's skill line (SkillLineAbility: each CreatureFamily's SkillLine_0, and Pet - Generic, 270, for every family) but the HUNTER_TRAINER abilities and Beast Training's old pet talents (Pet Aggression, Hardiness, Recovery, Resistance). id, rank (Spell's subtext) and level (SpellLevels) are the client's; families are the families whose line has that rank, so Dive's bat line starts at Rank 2. Forever's own families count: Fox (319) and Core Hound (312). Spell 24423 and its ranks are Demoralizing Screech here, Carrion Birds only, not Classic's Screech. Every level matches Petopia's.
	- Compared with Wowhead's list of Forever hunter pet spells (165 IDs): every ability rank there has a row, but Growl Rank 1 and 2 (below). The rest are hidden pet passives (Faster Attack, Slower Attack, Tamed Pet Passive, Hunter Pet Scaling, Summoning). Lava Breath Rank 1 and 2 (444678, 444681) are on the client's Core Hound line, but not on Wowhead's list.
	- ns.PET_ABILITY_BEASTS and ns.TAMEABLE_BEASTS are Petopia Forever's: the NPCs its abilities guide lists under each rank (its Wowhead NPC links), with their levels and zones. A zone is the NPC's zone in Data/Vanilla/Pet-Abilities-Vanilla.lua where Tamed has it, otherwise the lowest AreaTable ID with Petopia's zone name (a dungeon by its own name); where Petopia names two zones, the first. Petopia's data comes from the Forever beta and says it's a work in progress.
	- Ranks with no known beast on Petopia have no PET_ABILITY_BEASTS row (32 of them, mostly the top ranks of Forever's new abilities, and Lightning Breath Rank 1). Sonic Blast (bats) isn't on Petopia at all, so its 5 ranks have none either.
	- Left out: Growl Rank 1 and 2 (2649, 14916), which come with every pet and no trainer offers.
	- DEMON_ABILITIES: WoW Forever has no grimoires; a demon trainer teaches each rank. The rows are Data/Vanilla/Pet-Abilities-Vanilla.lua's DEMON_ABILITIES without item, source DEMON_TRAINER. The client's demon skill lines (SkillLineAbility: Pet - Imp, Felhunter, Voidwalker, Succubus) hold the same spells, and each rank's SpellLevels matches Classic's grimoire level, which stands as the trainer's level until a demon trainer window says otherwise. Every demon ability on Wowhead's list of Forever warlock pet spells has a row but the rank 1s a demon comes with (Firebolt, Torment, Lash of Pain, Devour Magic), as on Classic Era, and two hidden passives (Tamed Pet Passive, Warlock Pet Scaling).
	- Left out of DEMON_ABILITIES: the Felguard's spells (Anguish, Avoidance, Cleave, Intercept) on the client's Pet - Felguard line, Season of Discovery's and not on Wowhead's Forever list.

SQL (CMaNGOS)
	None.


wago.tools
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70888
	https://wago.tools/db2/SpellName?build=1.60.1.70888
	https://wago.tools/db2/Spell?build=1.60.1.70888
	https://wago.tools/db2/SpellLevels?build=1.60.1.70888
	https://wago.tools/db2/CreatureFamily?build=1.60.1.70888
	https://wago.tools/db2/AreaTable?build=1.60.1.70888

Petopia
	https://www.wow-petopia.com/forever/abilities.php (2026-11-15)

Wowhead
	The user's list of Forever hunter pet spell IDs (2026-11-15).
	https://wago.tools/db2/Spell?build=1.60.1.70938

QuestieDB
	None.

Tamed
	Tamed 2.0.1, src/data/TameableNPCs-Vanilla.lua (zones)
]]
