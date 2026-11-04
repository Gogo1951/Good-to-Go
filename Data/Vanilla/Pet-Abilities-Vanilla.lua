local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

--[[
	level is the pet's level, id the pet's spell, teach the hunter's Beast Training spell that teaches it, source
	TRAINER (a pet trainer) or TAMING, tp the training points, families the creature families that learn it
	(none: every family).
]]
ns.PET_ABILITIES = {
	{
		level = 1,
		id = 17253,
		teach = 17254,
		source = "TAMING",
		tp = 1,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 1)
	{ level = 1, id = 7371, teach = 7370, source = "TAMING", tp = 5, families = { 5 } }, -- Charge (Rank 1)
	{ level = 1, id = 16827, teach = 2980, source = "TAMING", tp = 1, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 1)
	{ level = 1, id = 2649, teach = 1853, source = "TRAINER" }, -- Growl (Rank 1)
	{ level = 1, id = 24844, teach = 24845, source = "TAMING", tp = 1, families = { 27 } }, -- Lightning Breath (Rank 1)
	{ level = 5, id = 1742, teach = 1747, source = "TAMING", tp = 8 }, -- Cower (Rank 1)
	{
		level = 8,
		id = 17255,
		teach = 17262,
		source = "TAMING",
		tp = 4,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 2)
	{ level = 8, id = 16828, teach = 2981, source = "TAMING", tp = 4, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 2)
	{ level = 8, id = 24640, teach = 24641, source = "TAMING", tp = 10, families = { 20 } }, -- Scorpid Poison (Rank 1)
	{ level = 8, id = 24423, teach = 24424, source = "TAMING", tp = 10, families = { 7, 24, 26 } }, -- Screech (Rank 1)
	{ level = 10, id = 24604, teach = 24609, source = "TAMING", tp = 10, families = { 1 } }, -- Furious Howl (Rank 1)
	{ level = 10, id = 4187, teach = 4195, source = "TRAINER" }, -- Great Stamina (Rank 1)
	{ level = 10, id = 14916, teach = 14922, source = "TRAINER" }, -- Growl (Rank 2)
	{ level = 10, id = 24545, teach = 24547, source = "TRAINER" }, -- Natural Armor (Rank 1)
	{ level = 12, id = 26177, teach = 26184, source = "TAMING", tp = 9, families = { 5 } }, -- Charge (Rank 2)
	{ level = 12, id = 4188, teach = 4196, source = "TRAINER" }, -- Great Stamina (Rank 2)
	{ level = 12, id = 25008, teach = 25013, source = "TAMING", tp = 5, families = { 27 } }, -- Lightning Breath (Rank 2)
	{ level = 12, id = 24549, teach = 24556, source = "TRAINER" }, -- Natural Armor (Rank 2)
	{ level = 15, id = 1753, teach = 1748, source = "TAMING", tp = 10 }, -- Cower (Rank 2)
	{
		level = 16,
		id = 17256,
		teach = 17263,
		source = "TAMING",
		tp = 7,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 3)
	{ level = 16, id = 16829, teach = 2982, source = "TAMING", tp = 7, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 3)
	{ level = 18, id = 4189, teach = 4197, source = "TRAINER" }, -- Great Stamina (Rank 3)
	{ level = 18, id = 24550, teach = 24557, source = "TRAINER" }, -- Natural Armor (Rank 3)
	{ level = 20, id = 24493, teach = 24495, source = "TRAINER" }, -- Arcane Resistance (Rank 1)
	{ level = 20, id = 23992, teach = 24440, source = "TRAINER" }, -- Fire Resistance (Rank 1)
	{ level = 20, id = 24446, teach = 24475, source = "TRAINER" }, -- Frost Resistance (Rank 1)
	{ level = 20, id = 14917, teach = 14923, source = "TRAINER" }, -- Growl (Rank 3)
	{ level = 20, id = 24492, teach = 24494, source = "TRAINER" }, -- Nature Resistance (Rank 1)
	{ level = 20, id = 24488, teach = 24490, source = "TRAINER" }, -- Shadow Resistance (Rank 1)
	{ level = 20, id = 26064, teach = 26065, source = "TAMING", tp = 15, families = { 21 } }, -- Shell Shield (Rank 1)
	{
		level = 24,
		id = 17257,
		teach = 17264,
		source = "TAMING",
		tp = 10,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 4)
	{ level = 24, id = 26178, teach = 26185, source = "TAMING", tp = 13, families = { 5 } }, -- Charge (Rank 3)
	{ level = 24, id = 16830, teach = 3667, source = "TAMING", tp = 10, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 4)
	{ level = 24, id = 24605, teach = 24608, source = "TAMING", tp = 15, families = { 1 } }, -- Furious Howl (Rank 2)
	{ level = 24, id = 4190, teach = 4198, source = "TRAINER" }, -- Great Stamina (Rank 4)
	{ level = 24, id = 25009, teach = 25014, source = "TAMING", tp = 10, families = { 27 } }, -- Lightning Breath (Rank 3)
	{ level = 24, id = 24551, teach = 24558, source = "TRAINER" }, -- Natural Armor (Rank 4)
	{ level = 24, id = 24583, teach = 24584, source = "TAMING", tp = 15, families = { 20 } }, -- Scorpid Poison (Rank 2)
	{ level = 24, id = 24577, teach = 24580, source = "TAMING", tp = 15, families = { 7, 24, 26 } }, -- Screech (Rank 2)
	{ level = 25, id = 1754, teach = 1749, source = "TAMING", tp = 12 }, -- Cower (Rank 3)
	{ level = 30, id = 24497, teach = 24508, source = "TRAINER" }, -- Arcane Resistance (Rank 2)
	{ level = 30, id = 23099, teach = 23100, source = "TAMING", tp = 15, families = { 1, 2, 5, 12, 25 } }, -- Dash (Rank 1)
	{ level = 30, id = 23145, teach = 23146, source = "TAMING", tp = 15, families = { 7, 24, 26, 27 } }, -- Dive (Rank 1)
	{ level = 30, id = 24439, teach = 24441, source = "TRAINER" }, -- Fire Resistance (Rank 2)
	{ level = 30, id = 24447, teach = 24476, source = "TRAINER" }, -- Frost Resistance (Rank 2)
	{ level = 30, id = 4191, teach = 4199, source = "TRAINER" }, -- Great Stamina (Rank 5)
	{ level = 30, id = 14918, teach = 14924, source = "TRAINER" }, -- Growl (Rank 4)
	{ level = 30, id = 24552, teach = 24559, source = "TRAINER" }, -- Natural Armor (Rank 5)
	{ level = 30, id = 24502, teach = 24511, source = "TRAINER" }, -- Nature Resistance (Rank 2)
	{ level = 30, id = 24450, teach = 24451, source = "TAMING", tp = 15, families = { 2 } }, -- Prowl (Rank 1)
	{ level = 30, id = 24505, teach = 24514, source = "TRAINER" }, -- Shadow Resistance (Rank 2)
	{ level = 30, id = 26090, teach = 26094, source = "TAMING", tp = 15, families = { 9 } }, -- Thunderstomp (Rank 1)
	{
		level = 32,
		id = 17258,
		teach = 17265,
		source = "TAMING",
		tp = 13,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 5)
	{ level = 32, id = 16831, teach = 2975, source = "TAMING", tp = 13, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 5)
	{ level = 35, id = 1755, teach = 1750, source = "TAMING", tp = 14 }, -- Cower (Rank 4)
	{ level = 36, id = 4192, teach = 4200, source = "TRAINER" }, -- Great Stamina (Rank 6)
	{ level = 36, id = 25010, teach = 25015, source = "TAMING", tp = 15, families = { 27 } }, -- Lightning Breath (Rank 4)
	{ level = 36, id = 24553, teach = 24560, source = "TRAINER" }, -- Natural Armor (Rank 6)
	{ level = 40, id = 24500, teach = 24509, source = "TRAINER" }, -- Arcane Resistance (Rank 3)
	{
		level = 40,
		id = 17259,
		teach = 17266,
		source = "TAMING",
		tp = 17,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 6)
	{ level = 40, id = 16832, teach = 2976, source = "TAMING", tp = 17, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 6)
	{ level = 40, id = 23109, teach = 23111, source = "TAMING", tp = 20, families = { 1, 2, 5, 12, 25 } }, -- Dash (Rank 2)
	{ level = 40, id = 23147, teach = 23149, source = "TAMING", tp = 20, families = { 7, 24, 26, 27 } }, -- Dive (Rank 2)
	{ level = 40, id = 24444, teach = 24463, source = "TRAINER" }, -- Fire Resistance (Rank 3)
	{ level = 40, id = 24448, teach = 24477, source = "TRAINER" }, -- Frost Resistance (Rank 3)
	{ level = 40, id = 24603, teach = 24607, source = "TAMING", tp = 20, families = { 1 } }, -- Furious Howl (Rank 3)
	{ level = 40, id = 14919, teach = 14925, source = "TRAINER" }, -- Growl (Rank 5)
	{ level = 40, id = 24503, teach = 24512, source = "TRAINER" }, -- Nature Resistance (Rank 3)
	{ level = 40, id = 24452, teach = 24454, source = "TAMING", tp = 20, families = { 2 } }, -- Prowl (Rank 2)
	{ level = 40, id = 24586, teach = 24588, source = "TAMING", tp = 20, families = { 20 } }, -- Scorpid Poison (Rank 3)
	{ level = 40, id = 24578, teach = 24581, source = "TAMING", tp = 20, families = { 7, 24, 26 } }, -- Screech (Rank 3)
	{ level = 40, id = 24506, teach = 24515, source = "TRAINER" }, -- Shadow Resistance (Rank 3)
	{ level = 40, id = 26187, teach = 26189, source = "TAMING", tp = 20, families = { 9 } }, -- Thunderstomp (Rank 2)
	{ level = 42, id = 4193, teach = 4201, source = "TRAINER" }, -- Great Stamina (Rank 7)
	{ level = 42, id = 24554, teach = 24561, source = "TRAINER" }, -- Natural Armor (Rank 7)
	{ level = 45, id = 1756, teach = 1751, source = "TAMING", tp = 16 }, -- Cower (Rank 5)
	{
		level = 48,
		id = 17260,
		teach = 17267,
		source = "TAMING",
		tp = 21,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 7)
	{ level = 48, id = 26201, teach = 26202, source = "TAMING", tp = 25, families = { 5 } }, -- Charge (Rank 5)
	{ level = 48, id = 3010, teach = 2977, source = "TAMING", tp = 21, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 7)
	{ level = 48, id = 4194, teach = 4202, source = "TRAINER" }, -- Great Stamina (Rank 8)
	{ level = 48, id = 25011, teach = 25016, source = "TAMING", tp = 20, families = { 27 } }, -- Lightning Breath (Rank 5)
	{ level = 48, id = 24555, teach = 24562, source = "TRAINER" }, -- Natural Armor (Rank 8)
	{ level = 50, id = 24501, teach = 24510, source = "TRAINER" }, -- Arcane Resistance (Rank 4)
	{ level = 50, id = 23110, teach = 23112, source = "TAMING", tp = 25, families = { 1, 2, 5, 12, 25 } }, -- Dash (Rank 3)
	{ level = 50, id = 23148, teach = 23150, source = "TAMING", tp = 25, families = { 7, 24, 26, 27 } }, -- Dive (Rank 3)
	{ level = 50, id = 24445, teach = 24464, source = "TRAINER" }, -- Fire Resistance (Rank 4)
	{ level = 50, id = 24449, teach = 24478, source = "TRAINER" }, -- Frost Resistance (Rank 4)
	{ level = 50, id = 14920, teach = 14926, source = "TRAINER" }, -- Growl (Rank 6)
	{ level = 50, id = 24504, teach = 24513, source = "TRAINER" }, -- Nature Resistance (Rank 4)
	{ level = 50, id = 24453, teach = 24455, source = "TAMING", tp = 25, families = { 2 } }, -- Prowl (Rank 3)
	{ level = 50, id = 24507, teach = 24516, source = "TRAINER" }, -- Shadow Resistance (Rank 4)
	{ level = 50, id = 26188, teach = 26190, source = "TAMING", tp = 25, families = { 9 } }, -- Thunderstomp (Rank 3)
	{ level = 54, id = 5041, teach = 5048, source = "TRAINER" }, -- Great Stamina (Rank 9)
	{ level = 54, id = 24629, teach = 24631, source = "TRAINER" }, -- Natural Armor (Rank 9)
	{ level = 55, id = 16697, teach = 16698, source = "TAMING", tp = 18 }, -- Cower (Rank 6)
	{
		level = 56,
		id = 17261,
		teach = 17268,
		source = "TAMING",
		tp = 25,
		families = { 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 21, 24, 25, 27, 312 },
	}, -- Bite (Rank 8)
	{ level = 56, id = 3009, teach = 3666, source = "TAMING", tp = 25, families = { 2, 4, 7, 8, 11, 20, 26 } }, -- Claw (Rank 8)
	{ level = 56, id = 24597, teach = 24599, source = "TAMING", tp = 25, families = { 1 } }, -- Furious Howl (Rank 4)
	{ level = 56, id = 24587, teach = 24589, source = "TAMING", tp = 25, families = { 20 } }, -- Scorpid Poison (Rank 4)
	{ level = 56, id = 24579, teach = 24582, source = "TAMING", tp = 25, families = { 7, 24, 26 } }, -- Screech (Rank 4)
	{ level = 60, id = 27685, teach = 28343, source = "TAMING", tp = 29, families = { 5 } }, -- Charge (Rank 6)
	{ level = 60, id = 5042, teach = 5049, source = "TRAINER" }, -- Great Stamina (Rank 10)
	{ level = 60, id = 14921, teach = 14927, source = "TRAINER" }, -- Growl (Rank 7)
	{ level = 60, id = 25012, teach = 25017, source = "TAMING", tp = 25, families = { 27 } }, -- Lightning Breath (Rank 6)
	{ level = 60, id = 24630, teach = 24632, source = "TRAINER" }, -- Natural Armor (Rank 10)
}

-- [pet spell ID] = { the tameable beasts that know it (ns.TAMEABLE_BEASTS) }, -- Spell Name (Rank N)
ns.PET_ABILITY_BEASTS = {
	[17253] = { 1509, 1505, 30, 1688, 1994, 2958, 1138, 1131, 1922, 1999, 2959, 3110 }, -- Bite (Rank 1)
	[7371] = {
		1984,
		3098,
		1985,
		708,
		2966,
		2954,
		113,
		1125,
		1126,
		3099,
		390,
		524,
		1127,
		3100,
		330,
		1689,
		119,
		1190,
		3225,
	}, -- Charge (Rank 1)
	[16827] = { 3124, 3281, 1995, 3106, 1196 }, -- Claw (Rank 1)
	[24844] = { 20797 }, -- Lightning Breath (Rank 1)
	[1742] = { 1199, 2042, 1553, 3035, 3121, 2957, 3068, 2070, 2321, 3246 }, -- Cower (Rank 1)
	[17255] = { 1133, 2000, 118, 1555, 2960, 834, 1132, 1195, 1765, 2001, 833, 7319, 1693, 442, 3461 }, -- Bite (Rank 2)
	[16828] = { 822, 1997, 3108, 3127, 1778, 1961, 2163, 5823, 1130, 2232 }, -- Claw (Rank 2)
	[24640] = { 3127, 3226, 5823, 3250, 3252 }, -- Scorpid Poison (Rank 1)
	[24423] = { 154 }, -- Screech (Rank 1)
	[24604] = { 1765, 833, 10644 }, -- Furious Howl (Rank 1)
	[26177] = { 454, 157, 1191, 547, 1192 }, -- Charge (Rank 2)
	[25008] = { 3630, 3631, 3247, 5056, 5756, 3424, 3249 }, -- Lightning Breath (Rank 2)
	[1753] = { 3241, 3245, 2237, 2323, 2384, 4067 }, -- Cower (Rank 2)
	[17256] = { 1923, 4005, 1185, 5053, 505, 3823, 4006, 14266, 2350, 3653, 569, 11921, 2476, 4824, 521, 616, 14279 }, -- Bite (Rank 3)
	[16829] = { 1189, 1216, 6788, 3619, 3812, 1225, 2351, 3809, 4821, 4822 }, -- Claw (Rank 3)
	[26064] = { 3653, 4824, 4825, 4887, 2408, 14223, 8213 }, -- Shell Shield (Rank 1)
	[17257] = { 4825, 4887, 628, 1112, 2349, 1258, 2089, 2348, 574, 3825, 3821, 2408, 14223 }, -- Bite (Rank 4)
	[26178] = { 345, 4511, 4514, 4512 }, -- Charge (Rank 3)
	[16830] = { 4823, 3810, 4696, 4140 }, -- Claw (Rank 4)
	[24605] = { 1258, 3825, 2729, 2925 }, -- Furious Howl (Rank 2)
	[25009] = { 3472, 4117, 4118, 4119 }, -- Lightning Breath (Rank 3)
	[24583] = { 4696, 4140, 4139, 4697, 5937, 7078, 4699 }, -- Scorpid Poison (Rank 2)
	[24577] = { 4158, 4861, 4694 }, -- Screech (Rank 2)
	[1754] = { 4126, 4538, 2385, 4425, 681, 683, 736 }, -- Cower (Rank 3)
	[23099] = { 682, 976, 4304, 4688, 2727, 4950, 767, 729, 2728, 2850, 4662, 2729 }, -- Dash (Rank 1)
	[23145] = { 4539, 4425, 2578, 2579, 4346, 6013, 4693, 4347, 4861, 4348 }, -- Dive (Rank 1)
	[24450] = { 2406, 2731, 684, 768 }, -- Prowl (Rank 1)
	[26090] = { 1108, 1114 }, -- Thunderstomp (Rank 1)
	[17258] = { 2563, 4143, 2565, 2727, 4341, 4343, 4412, 2753, 4344 }, -- Bite (Rank 5)
	[16831] = { 4697, 5937, 7022 }, -- Claw (Rank 5)
	[1755] = { 2731, 4861, 2732 }, -- Cower (Rank 4)
	[25010] = { 4347, 4348, 5307, 5308 }, -- Lightning Breath (Rank 4)
	[17259] = { 14233, 4345, 769, 5286, 1087, 4841, 5356, 8211, 13599, 8762, 8959, 14339 }, -- Bite (Rank 6)
	[16832] = { 922, 5422, 5268, 731, 1088, 5352 }, -- Claw (Rank 6)
	[23109] = { 728, 2734, 5286, 5425, 1713, 2730, 8211, 731, 8208, 5426, 2926, 5427 }, -- Dash (Rank 2)
	[23147] = { 5307, 5428, 5429, 5308, 8207, 5430, 7097, 5349 }, -- Dive (Rank 2)
	[24603] = { 5286, 5356, 2924, 5287, 8959, 14339 }, -- Furious Howl (Rank 3)
	[24452] = { 2734, 1713 }, -- Prowl (Rank 2)
	[24586] = { 7405, 5422, 5423, 5424, 5988, 7803, 8926, 9691, 9695, 11735 }, -- Scorpid Poison (Rank 3)
	[24578] = { 7097, 1809, 8927 }, -- Screech (Rank 3)
	[26187] = { 1557, 5262 }, -- Thunderstomp (Rank 2)
	[1756] = { 2522, 8927, 8600, 8601 }, -- Cower (Rank 5)
	[17260] = { 8277, 2505, 2681, 3581, 8933, 8213, 8961, 6585, 1817, 1824 }, -- Bite (Rank 7)
	[26201] = { 5992, 8303 }, -- Charge (Rank 5)
	[3010] = { 5274, 8958, 7099, 14344, 14343, 7444, 8301, 7455, 9695, 1816 }, -- Claw (Rank 7)
	[25011] = { 5291, 8336, 5349, 5708 }, -- Lightning Breath (Rank 5)
	[23110] = { 2681, 8303, 8300, 9416, 7055, 9696, 10200, 7433, 7432, 11365, 15067 }, -- Dash (Rank 3)
	[23148] = { 5708, 1809, 7099, 8927, 7098, 8299, 14343, 8600, 7455, 2931, 7456 }, -- Dive (Rank 3)
	[24453] = { 2522, 7432, 15067 }, -- Prowl (Rank 3)
	[26188] = { 6516, 9622 }, -- Thunderstomp (Rank 3)
	[16697] = { 7430, 8602 }, -- Cower (Rank 6)
	[17261] = { 9696, 11370 }, -- Bite (Rank 8)
	[3009] = { 7445, 7456 }, -- Claw (Rank 8)
	[24597] = { 9696 }, -- Furious Howl (Rank 4)
	[24587] = { 9698, 11736, 14476, 11737 }, -- Scorpid Poison (Rank 4)
	[24579] = { 8602, 7456 }, -- Screech (Rank 4)
	[27685] = { 16117 }, -- Charge (Rank 6)
	[25012] = { 11357, 11359 }, -- Lightning Breath (Rank 6)
}

-- [NPC ID] = { name, lowest level, highest level, zone (AreaTable ID) },
ns.TAMEABLE_BEASTS = {
	[30] = { "Forest Spider", 5, 6, 12 },
	[113] = { "Stonetusk Boar", 5, 6, 12 },
	[118] = { "Prowler", 9, 10, 12 },
	[119] = { "Longsnout", 10, 11, 12 },
	[154] = { "Greater Fleshripper", 16, 17, 40 },
	[157] = { "Goretusk", 14, 15, 40 },
	[330] = { "Princess", 9, 9, 12 },
	[345] = { "Bellygrub", 24, 24, 44 },
	[390] = { "Porcine Entourage", 7, 7, 12 },
	[442] = { "Tarantula", 15, 16, 44 },
	[454] = { "Young Goretusk", 12, 13, 40 },
	[505] = { "Greater Tarantula", 19, 20, 44 },
	[521] = { "Lupos", 23, 23, 10 },
	[524] = { "Rockhide Boar", 7, 8, 12 },
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
	[833] = { "Coyote Packleader", 11, 12, 40 },
	[834] = { "Coyote", 10, 11, 40 },
	[922] = { "Silt Crawler", 40, 41, 8 },
	[976] = { "Kurzen War Tiger", 32, 33, 33 },
	[1087] = { "Sawtooth Snapper", 41, 42, 8 },
	[1088] = { "Monstrous Crawler", 43, 44, 8 },
	[1108] = { "Mistvale Gorilla", 32, 33, 33 },
	[1112] = { "Leech Widow", 24, 24, 11 },
	[1114] = { "Jungle Thunderer", 37, 38, 33 },
	[1125] = { "Crag Boar", 5, 6, 1 },
	[1126] = { "Large Crag Boar", 6, 7, 1 },
	[1127] = { "Elder Crag Boar", 7, 8, 1 },
	[1130] = { "Bjarn", 12, 12, 1 },
	[1131] = { "Winter Wolf", 7, 8, 1 },
	[1132] = { "Timber", 10, 10, 1 },
	[1133] = { "Starving Winter Wolf", 8, 9, 1 },
	[1138] = { "Snow Tracker Wolf", 6, 7, 1 },
	[1185] = { "Wood Lurker", 17, 18, 38 },
	[1189] = { "Black Bear Patriarch", 16, 17, 38 },
	[1190] = { "Mountain Boar", 10, 11, 38 },
	[1191] = { "Mangy Mountain Boar", 14, 15, 38 },
	[1192] = { "Elder Mountain Boar", 16, 17, 38 },
	[1195] = { "Forest Lurker", 10, 11, 38 },
	[1196] = { "Ice Claw Bear", 7, 8, 1 },
	[1199] = { "Juvenile Snow Leopard", 5, 6, 1 },
	[1216] = { "Shore Crawler", 17, 18, 40 },
	[1225] = { "Ol' Sooty", 20, 20, 38 },
	[1258] = { "Black Ravager Mastiff", 25, 26, 10 },
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
	[2000] = { "Webwood Silkspinner", 8, 9, 141 },
	[2001] = { "Giant Webwood Spider", 10, 11, 141 },
	[2042] = { "Nightsaber", 5, 6, 141 },
	[2070] = { "Moonstalker Runt", 10, 17, 148 },
	[2089] = { "Giant Wetlands Crocolisk", 25, 26, 11 },
	[2163] = { "Thistle Bear", 11, 12, 148 },
	[2232] = { "Tide Crawler", 12, 14, 148 },
	[2237] = { "Moonstalker Sire", 17, 18, 148 },
	[2321] = { "Foreststrider Fledgling", 11, 13, 148 },
	[2323] = { "Giant Foreststrider", 17, 19, 148 },
	[2348] = { "Elder Moss Creeper", 26, 27, 267 },
	[2349] = { "Giant Moss Creeper", 24, 25, 267 },
	[2350] = { "Forest Moss Creeper", 20, 21, 267 },
	[2351] = { "Gray Bear", 21, 22, 267 },
	[2384] = { "Starving Mountain Lion", 23, 24, 267 },
	[2385] = { "Feral Mountain Lion", 27, 28, 267 },
	[2406] = { "Mountain Lion", 32, 33, 36 },
	[2408] = { "Snapjaw", 30, 31, 267 },
	[2476] = { "Large Loch Crocolisk", 22, 22, 38 },
	[2505] = { "Saltwater Snapjaw", 49, 50, 47 },
	[2522] = { "Jaguero Stalker", 41, 41, 33 },
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
	[3035] = { "Flatland Cougar", 7, 8, 215 },
	[3068] = { "Mazzranache", 9, 9, 215 },
	[3098] = { "Mottled Boar", 1, 2, 14 },
	[3099] = { "Dire Mottled Boar", 6, 7, 14 },
	[3100] = { "Elder Mottled Boar", 8, 9, 14 },
	[3106] = { "Pygmy Surf Crawler", 5, 6, 14 },
	[3108] = { "Encrusted Surf Crawler", 9, 10, 14 },
	[3110] = { "Dreadmaw Crocolisk", 9, 11, 14 },
	[3121] = { "Durotar Tiger", 7, 8, 14 },
	[3124] = { "Scorpid Worker", 3, 3, 14 },
	[3127] = { "Venomtail Scorpid", 9, 10, 14 },
	[3225] = { "Corrupted Mottled Boar", 10, 11, 14 },
	[3226] = { "Corrupted Scorpid", 10, 11, 14 },
	[3241] = { "Savannah Patriarch", 15, 16, 17 },
	[3245] = { "Ornery Plainstrider", 16, 17, 17 },
	[3246] = { "Fleeting Plainstrider", 12, 13, 17 },
	[3247] = { "Thunderhawk Hatchling", 18, 20, 17 },
	[3249] = { "Greater Thunderhawk", 23, 24, 17 },
	[3250] = { "Silithid Creeper", 20, 21, 17 },
	[3252] = { "Silithid Swarmer", 21, 22, 17 },
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
	[3821] = { "Wildthorn Lurker", 28, 29, 331 },
	[3823] = { "Ghostpaw Runner", 19, 20, 331 },
	[3825] = { "Ghostpaw Alpha", 27, 28, 331 },
	[4005] = { "Deepmoss Creeper", 16, 17, 406 },
	[4006] = { "Deepmoss Webspinner", 19, 20, 406 },
	[4067] = { "Twilight Runner", 23, 24, 406 },
	[4117] = { "Cloud Serpent", 25, 26, 400 },
	[4118] = { "Venomous Cloud Serpent", 26, 28, 400 },
	[4119] = { "Elder Cloud Serpent", 27, 29, 400 },
	[4126] = { "Crag Stalker", 25, 26, 400 },
	[4139] = { "Scorpid Terror", 33, 34, 400 },
	[4140] = { "Scorpid Reaver", 31, 32, 400 },
	[4143] = { "Sparkleshell Snapper", 34, 35, 400 },
	[4158] = { "Salt Flats Vulture", 32, 34, 400 },
	[4304] = { "Scarlet Tracking Hound", 33, 33, 796 },
	[4341] = { "Drywallow Crocolisk", 35, 36, 15 },
	[4343] = { "Drywallow Snapper", 37, 38, 15 },
	[4344] = { "Mottled Drywallow Crocolisk", 38, 39, 15 },
	[4345] = { "Drywallow Daggermaw", 39, 40, 15 },
	[4346] = { "Noxious Flayer", 35, 36, 15 },
	[4347] = { "Noxious Reaver", 37, 38, 15 },
	[4348] = { "Noxious Shredder", 38, 39, 15 },
	[4412] = { "Darkfang Creeper", 37, 38, 15 },
	[4425] = { "Blind Hunter", 27, 27, 491 },
	[4511] = { "Agam'ar", 24, 25, 491 },
	[4512] = { "Rotting Agam'ar", 26, 26, 491 },
	[4514] = { "Raging Agam'ar", 25, 25, 491 },
	[4538] = { "Kraul Bat", 26, 26, 491 },
	[4539] = { "Greater Kraul Bat", 26, 26, 491 },
	[4662] = { "Magram Bonepaw", 37, 38, 405 },
	[4688] = { "Bonepaw Hyena", 33, 35, 405 },
	[4693] = { "Dread Flyer", 36, 37, 405 },
	[4694] = { "Dread Ripper", 39, 40, 405 },
	[4696] = { "Scorpashi Snapper", 30, 31, 405 },
	[4697] = { "Scorpashi Lasher", 34, 35, 405 },
	[4699] = { "Scorpashi Venomlash", 38, 39, 405 },
	[4821] = { "Skittering Crustacean", 22, 22, 719 },
	[4822] = { "Snapping Crustacean", 22, 23, 719 },
	[4823] = { "Barbed Crustacean", 23, 23, 719 },
	[4824] = { "Aku'mai Fisher", 22, 23, 719 },
	[4825] = { "Aku'mai Snapjaw", 23, 23, 719 },
	[4841] = { "Deadmire", 41, 41, 15 },
	[4861] = { "Shrike Bat", 37, 38, 1337 },
	[4887] = { "Ghamoo-ra", 23, 23, 719 },
	[4950] = { "Spot", 35, 35, 15 },
	[5053] = { "Deviate Crocolisk", 18, 19, 718 },
	[5056] = { "Deviate Dreadfang", 19, 19, 718 },
	[5262] = { "Groddoc Thunderer", 49, 50, 357 },
	[5268] = { "Ironfur Bear", 41, 42, 357 },
	[5274] = { "Ironfur Patriarch", 48, 49, 357 },
	[5286] = { "Longtooth Runner", 40, 41, 357 },
	[5287] = { "Longtooth Howler", 43, 44, 357 },
	[5291] = { "Hakkari Frostwing", 48, 49, 1477 },
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
	[5428] = { "Roc", 41, 43, 440 },
	[5429] = { "Fire Roc", 43, 45, 440 },
	[5430] = { "Searing Roc", 47, 49, 440 },
	[5708] = { "Spawn of Hakkar", 49, 49, 1477 },
	[5756] = { "Deviate Venomwing", 19, 19, 718 },
	[5823] = { "Death Flayer", 11, 11, 14 },
	[5937] = { "Vile Sting", 35, 35, 400 },
	[5988] = { "Scorpok Stinger", 46, 47, 4 },
	[5992] = { "Ashmane Boar", 48, 49, 4 },
	[6013] = { "Wayward Buzzard", 35, 37, 3 },
	[6516] = { "Un'Goro Thunderer", 52, 53, 490 },
	[6585] = { "Uhk'loc", 52, 53, 490 },
	[6788] = { "Den Mother", 18, 19, 148 },
	[7022] = { "Venomlash Scorpid", 37, 38, 1337 },
	[7055] = { "Blackrock Worg", 54, 55, 46 },
	[7078] = { "Cleft Scorpid", 36, 36, 1337 },
	[7097] = { "Ironbeak Owl", 48, 49, 361 },
	[7098] = { "Ironbeak Screecher", 52, 53, 361 },
	[7099] = { "Ironbeak Hunter", 50, 51, 361 },
	[7319] = { "Lady Sathrah", 12, 12, 141 },
	[7405] = { "Deadly Cleft Scorpid", 37, 38, 1337 },
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
	[8336] = { "Hakkari Sapper", 48, 49, 1477 },
	[8600] = { "Plaguebat", 53, 55, 139 },
	[8601] = { "Noxious Plaguebat", 54, 56, 139 },
	[8602] = { "Monstrous Plaguebat", 56, 58, 139 },
	[8762] = { "Timberweb Recluse", 47, 48, 16 },
	[8926] = { "Deep Stinger", 50, 51, 1584 },
	[8927] = { "Dark Screecher", 50, 51, 1584 },
	[8933] = { "Cave Creeper", 50, 51, 1584 },
	[8958] = { "Angerclaw Mauler", 49, 50, 361 },
	[8959] = { "Felpaw Wolf", 47, 48, 361 },
	[8961] = { "Felpaw Ravager", 51, 52, 361 },
	[9416] = { "Scarshield Worg <Scarshield Legion>", 53, 54, 1583 },
	[9622] = { "U'cha", 55, 55, 490 },
	[9691] = { "Venomtip Scorpid", 52, 53, 46 },
	[9695] = { "Deathlash Scorpid", 54, 55, 46 },
	[9696] = { "Bloodaxe Worg <Scarshield Legion>", 56, 57, 1583 },
	[9698] = { "Firetail Scorpid", 56, 57, 46 },
	[10200] = { "Rak'shiri", 57, 57, 618 },
	[10644] = { "Mist Howler", 22, 22, 331 },
	[11357] = { "Son of Hakkar", 60, 60, 1977 },
	[11359] = { "Soulflayer", 61, 61, 1977 },
	[11365] = { "Zulian Panther", 60, 60, 1977 },
	[11370] = { "Razzashi Broodwidow", 56, 61, 1977 },
	[11735] = { "Stonelash Scorpid", 54, 55, 1377 },
	[11736] = { "Stonelash Pincer", 56, 56, 1377 },
	[11737] = { "Stonelash Flayer", 57, 58, 1377 },
	[11921] = { "Besseleth", 21, 21, 406 },
	[13599] = { "Stolid Snapjaw", 45, 46, 2100 },
	[14223] = { "Cranky Benj", 32, 32, 36 },
	[14233] = { "Ripscale", 37, 37, 15 },
	[14266] = { "Shanda the Spinner", 19, 19, 38 },
	[14279] = { "Creepthess", 24, 24, 267 },
	[14339] = { "Death Howl", 49, 49, 361 },
	[14343] = { "Olm the Wise", 52, 52, 361 },
	[14344] = { "Mongress", 50, 50, 361 },
	[14476] = { "Krellack", 56, 56, 1377 },
	[15067] = { "Zulian Stalker", 61, 61, 1977 },
	[16117] = { "Plagued Swine", 60, 60, 139 },
	[20797] = { "Deviate Coiler Hatchling", 11, 11, 17 },
}

--[[
	The warlock's demon abilities, one row per rank: level is the warlock level its grimoire needs, id the demon's
	spell, item the grimoire that teaches it, families the demons that learn it.
]]
ns.DEMON_ABILITIES = {
	{ level = 4, id = 6307, item = 16321, families = { 23 } }, -- Blood Pact (Rank 1)
	{ level = 8, id = 7799, item = 16302, families = { 23 } }, -- Firebolt (Rank 2)
	{ level = 12, id = 4511, item = 16331, families = { 23 } }, -- Phase Shift
	{ level = 14, id = 7804, item = 16322, families = { 23 } }, -- Blood Pact (Rank 2)
	{ level = 14, id = 2947, item = 16326, families = { 23 } }, -- Fire Shield (Rank 1)
	{ level = 16, id = 7812, item = 16351, families = { 16 } }, -- Sacrifice (Rank 1)
	{ level = 18, id = 17767, item = 16357, families = { 16 } }, -- Consume Shadows (Rank 1)
	{ level = 18, id = 7800, item = 16316, families = { 23 } }, -- Firebolt (Rank 3)
	{ level = 20, id = 7809, item = 16346, families = { 16 } }, -- Torment (Rank 2)
	{ level = 22, id = 6360, item = 16375, families = { 17, 302 } }, -- Soothing Kiss (Rank 1)
	{ level = 24, id = 8316, item = 16327, families = { 23 } }, -- Fire Shield (Rank 2)
	{ level = 24, id = 19438, item = 16352, families = { 16 } }, -- Sacrifice (Rank 2)
	{ level = 24, id = 17735, item = 16363, families = { 16 } }, -- Suffering (Rank 1)
	{ level = 26, id = 7805, item = 16323, families = { 23 } }, -- Blood Pact (Rank 3)
	{ level = 26, id = 17850, item = 16358, families = { 16 } }, -- Consume Shadows (Rank 2)
	{ level = 26, id = 6358, item = 16379, families = { 17, 302 } }, -- Seduction
	{ level = 28, id = 7801, item = 16317, families = { 23 } }, -- Firebolt (Rank 4)
	{ level = 28, id = 7815, item = 16368, families = { 17, 302 } }, -- Lash of Pain (Rank 2)
	{ level = 30, id = 7810, item = 16347, families = { 16 } }, -- Torment (Rank 3)
	{ level = 32, id = 7870, item = 16380, families = { 17, 302 } }, -- Lesser Invisibility
	{ level = 32, id = 19440, item = 16353, families = { 16 } }, -- Sacrifice (Rank 3)
	{ level = 32, id = 19478, item = 16384, families = { 15 } }, -- Tainted Blood (Rank 1)
	{ level = 34, id = 17851, item = 16359, families = { 16 } }, -- Consume Shadows (Rank 3)
	{ level = 34, id = 8317, item = 16328, families = { 23 } }, -- Fire Shield (Rank 3)
	{ level = 34, id = 7813, item = 16376, families = { 17, 302 } }, -- Soothing Kiss (Rank 2)
	{ level = 36, id = 7816, item = 16371, families = { 17, 302 } }, -- Lash of Pain (Rank 3)
	{ level = 36, id = 19244, item = 16388, families = { 15 } }, -- Spell Lock (Rank 1)
	{ level = 36, id = 17750, item = 16364, families = { 16 } }, -- Suffering (Rank 2)
	{ level = 38, id = 11766, item = 16324, families = { 23 } }, -- Blood Pact (Rank 4)
	{ level = 38, id = 19731, item = 16381, families = { 15 } }, -- Devour Magic (Rank 2)
	{ level = 38, id = 7802, item = 16318, families = { 23 } }, -- Firebolt (Rank 5)
	{ level = 40, id = 19441, item = 16354, families = { 16 } }, -- Sacrifice (Rank 4)
	{ level = 40, id = 19655, item = 16385, families = { 15 } }, -- Tainted Blood (Rank 2)
	{ level = 40, id = 7811, item = 16348, families = { 16 } }, -- Torment (Rank 4)
	{ level = 42, id = 17852, item = 16360, families = { 16 } }, -- Consume Shadows (Rank 4)
	{ level = 42, id = 19480, item = 16390, families = { 15 } }, -- Paranoia
	{ level = 44, id = 11770, item = 16329, families = { 23 } }, -- Fire Shield (Rank 4)
	{ level = 44, id = 11778, item = 16372, families = { 17, 302 } }, -- Lash of Pain (Rank 4)
	{ level = 46, id = 19734, item = 16382, families = { 15 } }, -- Devour Magic (Rank 3)
	{ level = 46, id = 11784, item = 16377, families = { 17, 302 } }, -- Soothing Kiss (Rank 3)
	{ level = 48, id = 11762, item = 16319, families = { 23 } }, -- Firebolt (Rank 6)
	{ level = 48, id = 19442, item = 16355, families = { 16 } }, -- Sacrifice (Rank 5)
	{ level = 48, id = 17751, item = 16365, families = { 16 } }, -- Suffering (Rank 3)
	{ level = 48, id = 19656, item = 16386, families = { 15 } }, -- Tainted Blood (Rank 3)
	{ level = 50, id = 11767, item = 16325, families = { 23 } }, -- Blood Pact (Rank 5)
	{ level = 50, id = 17853, item = 16361, families = { 16 } }, -- Consume Shadows (Rank 5)
	{ level = 50, id = 11774, item = 16349, families = { 16 } }, -- Torment (Rank 5)
	{ level = 52, id = 11779, item = 16373, families = { 17, 302 } }, -- Lash of Pain (Rank 5)
	{ level = 52, id = 19647, item = 16389, families = { 15 } }, -- Spell Lock (Rank 2)
	{ level = 54, id = 19736, item = 16383, families = { 15 } }, -- Devour Magic (Rank 4)
	{ level = 54, id = 11771, item = 16330, families = { 23 } }, -- Fire Shield (Rank 5)
	{ level = 56, id = 19443, item = 16356, families = { 16 } }, -- Sacrifice (Rank 6)
	{ level = 56, id = 19660, item = 16387, families = { 15 } }, -- Tainted Blood (Rank 4)
	{ level = 58, id = 17854, item = 16362, families = { 16 } }, -- Consume Shadows (Rank 6)
	{ level = 58, id = 11763, item = 16320, families = { 23 } }, -- Firebolt (Rank 7)
	{ level = 58, id = 11785, item = 16378, families = { 17, 302 } }, -- Soothing Kiss (Rank 4)
	{ level = 60, id = 11780, item = 16374, families = { 17, 302 } }, -- Lash of Pain (Rank 6)
	{ level = 60, id = 17752, item = 16366, families = { 16 } }, -- Suffering (Rank 4)
	{ level = 60, id = 11775, item = 16350, families = { 16 } }, -- Torment (Rank 6)
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Classic Era 1.15.9.70576

Notes
	- Every hunter pet ability rank this client's pets can learn, for the Pet What's Next? tab (Features/Spellbook/Whats-Next-Pet.lua): one row per rank, with the beasts that teach the ranks learned by taming.
	- id is the pet's own spell, the one its spellbook lists. teach is the hunter's Beast Training spell for that rank: the hunter learns it, from a pet trainer or by taming a beast that knows the rank, and casts it on the pet to teach it. The tab reads the hunter's knowledge from teach and the pet's from id. Found as the spells on the Beast Training skill line (SkillLineAbility 261) whose Learn Spell effect targets the pet (SpellEffect, effect 36, target 5).
	- level is the pet level the rank needs: the Beast Training spell's level (SpellLevels).
	- families are the creature families that learn the rank, from the pet spell's skill lines (SkillLineAbility, CreatureFamily SkillLine_0). A rank on the general pet skill line (270) every family learns, so it has none.
	- source TRAINER is a rank a pet trainer teaches (CMaNGOS classic-db npc_trainer rows of the creatures with TrainerType 3, followed through the teaching spell's Learn Spell effect), TAMING a rank a tameable beast knows (Tamed's NPC data). A rank with neither is left out: Harass (unused), Cobra Reflexes (TBC's), Charge rank 26179 (no beast knows it), and Season of Discovery's Lava Breath.
	- tp is the training point cost, from Tamed's ability data. The client's tables don't hold it, and Tamed has none for the pet trainer's ranks, so those rows have no tp.
	- Screech rank 3 (24578) needs pet level 40 here; Tamed says 48. The client's level stands.
	- ns.PET_ABILITY_BEASTS and ns.TAMEABLE_BEASTS are Tamed's tameable NPCs, their level ranges and zones (AreaTable IDs, which C_Map.GetAreaInfo names), and the ranks each knows. The client can't name an NPC from its ID until it has seen one, so the names are Tamed's enUS ones.
	- ns.DEMON_ABILITIES is the warlock's side, for the same tab: each demon spell a grimoire teaches (a spell whose Learn Spell effect targets the pet, SpellEffect effect 36 target 5, off the Beast Training skill line), the grimoire (ItemEffect), the grimoire's RequiredLevel (ItemSparse) and the demons whose skill line has the spell (CreatureFamily; Succubus and Incubus share one). All 59 grimoires are on the demon trainers' lists (CMaNGOS classic-db npc_vendor of the creatures titled Demon Trainer). The rank 1 of each demon's first spells comes with the demon, so it has no grimoire and no row.
	- Tamed (https://github.com/moody/Tamed) is MIT licensed; its notice is in Data/LICENSE-Pet-Data.
	- Made by script from the tables below; the rows are regenerated, not edited by hand.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=1.15.9.70576
	https://wago.tools/db2/SpellEffect?build=1.15.9.70576
	https://wago.tools/db2/SpellLevels?build=1.15.9.70576
	https://wago.tools/db2/SpellName?build=1.15.9.70576
	https://wago.tools/db2/Spell?build=1.15.9.70576
	https://wago.tools/db2/ItemEffect?build=1.15.9.70576
	https://wago.tools/db2/ItemSparse?build=1.15.9.70576
	https://wago.tools/db2/CreatureFamily?build=1.15.9.70576

QuestieDB
	None.

Tamed
	Tamed 2.0.1, src/data/TameableAbilities-Vanilla.lua and src/data/TameableNPCs-Vanilla.lua
]]
