local _, ns = ...

-- [classToken] = { { { id, rank, level, off }, ... }, ... }, -- each ability's ranks, lowest first; level: nil where no table gives one; off: unchecked until the player ticks it
ns.RANK_WATCH_ABILITIES = {
	DRUID = {
		{
			{ id = 5211, rank = 1, level = 14 },
			{ id = 6798, rank = 2, level = 30 },
			{ id = 8983, rank = 3, level = 46 },
		}, -- Bash
		{
			{ id = 1082, rank = 1, level = 20 },
			{ id = 3029, rank = 2, level = 28 },
			{ id = 5201, rank = 3, level = 38 },
			{ id = 9849, rank = 4, level = 48 },
			{ id = 9850, rank = 5, level = 58 },
		}, -- Claw
		{
			{ id = 8998, rank = 1, level = 28 },
			{ id = 9000, rank = 2, level = 40 },
			{ id = 9892, rank = 3, level = 52 },
		}, -- Cower
		{
			{ id = 1850, rank = 1, level = 26 },
			{ id = 9821, rank = 2, level = 46 },
		}, -- Dash
		{
			{ id = 99, rank = 1, level = 10 },
			{ id = 1735, rank = 2, level = 20 },
			{ id = 9490, rank = 3, level = 32 },
			{ id = 9747, rank = 4, level = 42 },
			{ id = 9898, rank = 5, level = 52 },
		}, -- Demoralizing Roar
		{
			{ id = 339, rank = 1, level = 8, off = true },
			{ id = 1062, rank = 2, level = 18 },
			{ id = 5195, rank = 3, level = 28 },
			{ id = 5196, rank = 4, level = 38 },
			{ id = 9852, rank = 5, level = 48 },
			{ id = 9853, rank = 6, level = 58 },
		}, -- Entangling Roots
		{
			{ id = 770, rank = 1, level = 18 },
			{ id = 778, rank = 2, level = 30 },
			{ id = 9749, rank = 3, level = 42 },
			{ id = 9907, rank = 4, level = 54 },
		}, -- Faerie Fire
		{
			{ id = 22568, rank = 2, level = 32 },
			{ id = 22827, rank = 3, level = 40 },
			{ id = 22828, rank = 4, level = 48 },
			{ id = 22829, rank = 5, level = 56 },
			{ id = 31018, rank = 6, level = 60 },
		}, -- Ferocious Bite
		{
			{ id = 22842, rank = 1, level = 36 },
		}, -- Frenzied Regeneration
		{
			{ id = 21849, rank = 1, level = 50 },
			{ id = 21850, rank = 2, level = 60 },
		}, -- Gift of the Wild
		{
			{ id = 2637, rank = 1, level = 18 },
			{ id = 18657, rank = 2, level = 38 },
			{ id = 18658, rank = 3, level = 58 },
		}, -- Hibernate
		{
			{ id = 16914, rank = 1, level = 40 },
			{ id = 17401, rank = 2, level = 50 },
			{ id = 17402, rank = 3, level = 60 },
		}, -- Hurricane
		{
			{ id = 5570, rank = 1, level = 30 },
			{ id = 24974, rank = 2, level = 30 },
			{ id = 24975, rank = 3, level = 40 },
			{ id = 24976, rank = 4, level = 50 },
			{ id = 24977, rank = 5, level = 60 },
		}, -- Insect Swarm
		{
			{ id = 1126, rank = 1, level = 1 },
			{ id = 5232, rank = 2, level = 10 },
			{ id = 6756, rank = 3, level = 20 },
			{ id = 5234, rank = 4, level = 30 },
			{ id = 8907, rank = 5, level = 40 },
			{ id = 9884, rank = 6, level = 50 },
			{ id = 9885, rank = 7, level = 60 },
		}, -- Mark of the Wild
		{
			{ id = 6807, rank = 1, level = 10 },
			{ id = 6808, rank = 2, level = 18 },
			{ id = 6809, rank = 3, level = 26 },
			{ id = 8972, rank = 4, level = 34 },
			{ id = 9745, rank = 5, level = 42 },
			{ id = 9880, rank = 6, level = 50 },
			{ id = 9881, rank = 7, level = 58 },
		}, -- Maul
		{
			{ id = 8921, rank = 1, level = 4, off = true },
			{ id = 8924, rank = 2, level = 10 },
			{ id = 8925, rank = 3, level = 16 },
			{ id = 8926, rank = 4, level = 22 },
			{ id = 8927, rank = 5, level = 28 },
			{ id = 8928, rank = 6, level = 34 },
			{ id = 8929, rank = 7, level = 40 },
			{ id = 9833, rank = 8, level = 46 },
			{ id = 9834, rank = 9, level = 52 },
			{ id = 9835, rank = 10, level = 58 },
		}, -- Moonfire
		{
			{ id = 16689, rank = 1, level = 10, off = true },
			{ id = 16810, rank = 2, level = 18 },
			{ id = 16811, rank = 3, level = 28 },
			{ id = 16812, rank = 4, level = 38 },
			{ id = 16813, rank = 5, level = 48 },
			{ id = 17329, rank = 6, level = 58 },
		}, -- Nature's Grasp
		{
			{ id = 9005, rank = 1, level = 36 },
			{ id = 9823, rank = 2, level = 46 },
			{ id = 9827, rank = 3, level = 56 },
		}, -- Pounce
		{
			{ id = 5215, rank = 1, level = 20 },
			{ id = 6783, rank = 2, level = 40 },
			{ id = 9913, rank = 3, level = 60 },
		}, -- Prowl
		{
			{ id = 1822, rank = 1, level = 24 },
			{ id = 1823, rank = 2, level = 34 },
			{ id = 1824, rank = 3, level = 44 },
			{ id = 9904, rank = 4, level = 54 },
		}, -- Rake
		{
			{ id = 6785, rank = 1, level = 32 },
			{ id = 6787, rank = 2, level = 42 },
			{ id = 9866, rank = 3, level = 50 },
			{ id = 9867, rank = 4, level = 58 },
		}, -- Ravage
		{
			{ id = 20484, rank = 1, level = 20 },
			{ id = 20739, rank = 2, level = 30 },
			{ id = 20742, rank = 3, level = 40 },
			{ id = 20747, rank = 4, level = 50 },
			{ id = 20748, rank = 5, level = 60 },
		}, -- Rebirth
		{
			{ id = 1079, rank = 1, level = 20 },
			{ id = 9492, rank = 2, level = 28 },
			{ id = 9493, rank = 3, level = 36 },
			{ id = 9752, rank = 4, level = 44 },
			{ id = 9894, rank = 5, level = 52 },
			{ id = 9896, rank = 6, level = 60 },
		}, -- Rip
		{
			{ id = 5221, rank = 1, level = 20 },
			{ id = 6800, rank = 2, level = 30 },
			{ id = 8992, rank = 3, level = 38 },
			{ id = 9829, rank = 4, level = 46 },
			{ id = 9830, rank = 5, level = 54 },
		}, -- Shred
		{
			{ id = 2908, rank = 1, level = 22 },
			{ id = 8955, rank = 2, level = 38 },
			{ id = 9901, rank = 3, level = 54 },
		}, -- Soothe Animal
		{
			{ id = 2912, rank = 1, level = 20 },
			{ id = 8949, rank = 2, level = 26 },
			{ id = 8950, rank = 3, level = 34 },
			{ id = 8951, rank = 4, level = 42 },
			{ id = 9875, rank = 5, level = 50 },
			{ id = 9876, rank = 6, level = 58 },
		}, -- Starfire
		{
			{ id = 779, rank = 1, level = 16 },
			{ id = 780, rank = 2, level = 24 },
			{ id = 769, rank = 3, level = 34 },
			{ id = 9754, rank = 4, level = 44 },
			{ id = 9908, rank = 5, level = 54 },
		}, -- Swipe
		{
			{ id = 467, rank = 1, level = 6 },
			{ id = 782, rank = 2, level = 14 },
			{ id = 1075, rank = 3, level = 24 },
			{ id = 8914, rank = 4, level = 34 },
			{ id = 9756, rank = 5, level = 44 },
			{ id = 9910, rank = 6, level = 54 },
		}, -- Thorns
		{
			{ id = 5217, rank = 1, level = 24 },
		}, -- Tiger's Fury
		{
			{ id = 740, rank = 1, level = 30 },
			{ id = 8918, rank = 2, level = 40 },
			{ id = 9862, rank = 3, level = 50 },
			{ id = 9863, rank = 4, level = 60 },
		}, -- Tranquility
		{
			{ id = 5176, rank = 1, level = 1 },
			{ id = 5177, rank = 2, level = 6 },
			{ id = 5178, rank = 3, level = 14 },
			{ id = 5179, rank = 4, level = 22 },
			{ id = 5180, rank = 5, level = 30 },
			{ id = 6780, rank = 6, level = 38 },
			{ id = 8905, rank = 7, level = 46 },
			{ id = 9912, rank = 8, level = 54 },
		}, -- Wrath
		{
			{ id = 2893, rank = 1, level = 26, off = true },
		}, -- Abolish Poison
		{
			{ id = 1066, rank = 1, level = 16, off = true },
		}, -- Aquatic Form
		{
			{ id = 22812, rank = 1, level = 44, off = true },
		}, -- Barkskin
		{
			{ id = 5487, rank = 1, level = 10, off = true },
		}, -- Bear Form
		{
			{ id = 768, rank = 1, level = 20, off = true },
		}, -- Cat Form
		{
			{ id = 5209, rank = 1, level = 28, off = true },
		}, -- Challenging Roar
		{
			{ id = 8946, rank = 1, level = 14, off = true },
		}, -- Cure Poison
		{
			{ id = 9634, rank = 1, level = 40, off = true },
		}, -- Dire Bear Form
		{
			{ id = 5229, rank = 1, level = 12, off = true },
		}, -- Enrage
		{
			{ id = 16979, rank = 1, off = true },
		}, -- Feral Charge
		{
			{ id = 6795, rank = 1, off = true },
		}, -- Growl
		{
			{ id = 5185, rank = 1, level = 1, off = true },
			{ id = 5186, rank = 2, level = 8, off = true },
			{ id = 5187, rank = 3, level = 14, off = true },
			{ id = 5188, rank = 4, level = 20, off = true },
			{ id = 5189, rank = 5, level = 26, off = true },
			{ id = 6778, rank = 6, level = 32, off = true },
			{ id = 8903, rank = 7, level = 38, off = true },
			{ id = 9758, rank = 8, level = 44, off = true },
			{ id = 9888, rank = 9, level = 50, off = true },
			{ id = 9889, rank = 10, level = 56, off = true },
		}, -- Healing Touch
		{
			{ id = 29166, rank = 1, level = 40, off = true },
		}, -- Innervate
		{
			{ id = 414644, rank = 3, level = 42, off = true },
			{ id = 1235826, rank = 4, level = 50, off = true },
			{ id = 1235827, rank = 5, level = 58, off = true },
		}, -- Lacerate
		{
			{ id = 24858, rank = 1, off = true },
		}, -- Moonkin Form
		{
			{ id = 17116, rank = 1, off = true },
		}, -- Nature's Swiftness
		{
			{ id = 16864, rank = 1, level = 20, off = true },
		}, -- Omen of Clarity
		{
			{ id = 407995, rank = 1, level = 36, off = true },
			{ id = 1238069, rank = 2, level = 50, off = true },
			{ id = 1238070, rank = 3, level = 60, off = true },
		}, -- Primal Bite
		{
			{ id = 8936, rank = 1, level = 12, off = true },
			{ id = 8938, rank = 2, level = 18, off = true },
			{ id = 8939, rank = 3, level = 24, off = true },
			{ id = 8940, rank = 4, level = 30, off = true },
			{ id = 8941, rank = 5, level = 36, off = true },
			{ id = 9750, rank = 6, level = 42, off = true },
			{ id = 9856, rank = 7, level = 48, off = true },
			{ id = 9857, rank = 8, level = 54, off = true },
			{ id = 9858, rank = 9, level = 60, off = true },
		}, -- Regrowth
		{
			{ id = 774, rank = 1, level = 4, off = true },
			{ id = 1058, rank = 2, level = 10, off = true },
			{ id = 1430, rank = 3, level = 16, off = true },
			{ id = 2090, rank = 4, level = 22, off = true },
			{ id = 2091, rank = 5, level = 28, off = true },
			{ id = 3627, rank = 6, level = 34, off = true },
			{ id = 8910, rank = 7, level = 40, off = true },
			{ id = 9839, rank = 8, level = 46, off = true },
			{ id = 9840, rank = 9, level = 52, off = true },
			{ id = 9841, rank = 10, level = 58, off = true },
		}, -- Rejuvenation
		{
			{ id = 2782, rank = 1, level = 24, off = true },
		}, -- Remove Curse
		{
			{ id = 437138, rank = 1, level = 12, off = true },
			{ id = 1237948, rank = 2, level = 24, off = true },
			{ id = 1237949, rank = 3, level = 36, off = true },
			{ id = 1237950, rank = 4, level = 48, off = true },
			{ id = 1237951, rank = 5, level = 60, off = true },
		}, -- Revive
		{
			{ id = 18562, rank = 1, off = true },
		}, -- Swiftmend
		{
			{ id = 18960, rank = 1, level = 10, off = true },
		}, -- Teleport: Moonglade
		{
			{ id = 5225, rank = 1, level = 32, off = true },
		}, -- Track Humanoids
		{
			{ id = 783, rank = 1, level = 30, off = true },
		}, -- Travel Form
		{
			{ id = 408120, rank = 1, level = 50, off = true },
			{ id = 1238214, rank = 2, level = 50, off = true },
			{ id = 1238215, rank = 3, level = 60, off = true },
		}, -- Wild Growth
	},
	HUNTER = {
		{
			{ id = 19434, rank = 1, level = 20 },
			{ id = 20900, rank = 2, level = 28 },
			{ id = 20901, rank = 3, level = 36 },
			{ id = 20902, rank = 4, level = 44 },
			{ id = 20903, rank = 5, level = 52 },
			{ id = 20904, rank = 6, level = 60 },
		}, -- Aimed Shot
		{
			{ id = 3044, rank = 1, level = 6, off = true },
			{ id = 14281, rank = 2, level = 12 },
			{ id = 14282, rank = 3, level = 20 },
			{ id = 14283, rank = 4, level = 28 },
			{ id = 14284, rank = 5, level = 36 },
			{ id = 14285, rank = 6, level = 44 },
			{ id = 14286, rank = 7, level = 52 },
			{ id = 14287, rank = 8, level = 60 },
		}, -- Arcane Shot
		{
			{ id = 13165, rank = 1, level = 10 },
			{ id = 14318, rank = 2, level = 18 },
			{ id = 14319, rank = 3, level = 28 },
			{ id = 14320, rank = 4, level = 38 },
			{ id = 14321, rank = 5, level = 48 },
			{ id = 14322, rank = 6, level = 58 },
		}, -- Aspect of the Hawk
		{
			{ id = 20043, rank = 1, level = 46 },
			{ id = 20190, rank = 2, level = 56 },
		}, -- Aspect of the Wild
		{
			{ id = 19306, rank = 1, level = 30 },
			{ id = 1242634, rank = 2, level = 30 },
			{ id = 20909, rank = 3, level = 42 },
			{ id = 20910, rank = 4, level = 54 },
		}, -- Counterattack
		{
			{ id = 781, rank = 1, level = 20 },
			{ id = 14272, rank = 2, level = 34 },
			{ id = 14273, rank = 3, level = 48 },
		}, -- Disengage
		{
			{ id = 20736, rank = 1, level = 12 },
			{ id = 14274, rank = 2, level = 20 },
			{ id = 15629, rank = 3, level = 30 },
			{ id = 15630, rank = 4, level = 40 },
			{ id = 15631, rank = 5, level = 50 },
			{ id = 15632, rank = 6, level = 60 },
		}, -- Distracting Shot
		{
			{ id = 13813, rank = 1, level = 34 },
			{ id = 14316, rank = 2, level = 44 },
			{ id = 14317, rank = 3, level = 54 },
		}, -- Explosive Trap
		{
			{ id = 1499, rank = 1, level = 20 },
			{ id = 14310, rank = 2, level = 40 },
			{ id = 14311, rank = 3, level = 60 },
		}, -- Freezing Trap
		{
			{ id = 1130, rank = 1, level = 6 },
			{ id = 14323, rank = 2, level = 22 },
			{ id = 14324, rank = 3, level = 40 },
			{ id = 14325, rank = 4, level = 58 },
		}, -- Hunter's Mark
		{
			{ id = 13795, rank = 1, level = 16 },
			{ id = 14302, rank = 2, level = 26 },
			{ id = 14303, rank = 3, level = 36 },
			{ id = 14304, rank = 4, level = 46 },
			{ id = 14305, rank = 5, level = 56 },
		}, -- Immolation Trap
		{
			{ id = 136, rank = 1, level = 12 },
			{ id = 3111, rank = 2, level = 20 },
			{ id = 3661, rank = 3, level = 28 },
			{ id = 3662, rank = 4, level = 36 },
			{ id = 13542, rank = 5, level = 44 },
			{ id = 13543, rank = 6, level = 52 },
			{ id = 13544, rank = 7, level = 60 },
		}, -- Mend Pet
		{
			{ id = 1495, rank = 1, level = 16 },
			{ id = 14269, rank = 2, level = 30 },
			{ id = 14270, rank = 3, level = 44 },
			{ id = 14271, rank = 4, level = 58 },
		}, -- Mongoose Bite
		{
			{ id = 2643, rank = 1, level = 18 },
		}, -- Multi-Shot
		{
			{ id = 2973, rank = 1, level = 1 },
			{ id = 14260, rank = 2, level = 8 },
			{ id = 14261, rank = 3, level = 16 },
			{ id = 14262, rank = 4, level = 24 },
			{ id = 14263, rank = 5, level = 32 },
			{ id = 14264, rank = 6, level = 40 },
			{ id = 14265, rank = 7, level = 48 },
			{ id = 14266, rank = 8, level = 56 },
		}, -- Raptor Strike
		{
			{ id = 1513, rank = 1, level = 14 },
			{ id = 14326, rank = 2, level = 30 },
			{ id = 14327, rank = 3, level = 46 },
		}, -- Scare Beast
		{
			{ id = 3043, rank = 1, level = 22 },
		}, -- Scorpid Sting
		{
			{ id = 13549, rank = 2, level = 10 },
			{ id = 13550, rank = 3, level = 18 },
			{ id = 13551, rank = 4, level = 26 },
			{ id = 13552, rank = 5, level = 34 },
			{ id = 13553, rank = 6, level = 42 },
			{ id = 13554, rank = 7, level = 50 },
			{ id = 13555, rank = 8, level = 58 },
		}, -- Serpent Sting
		{
			{ id = 3034, rank = 1, level = 36 },
			{ id = 14279, rank = 2, level = 46 },
			{ id = 14280, rank = 3, level = 56 },
		}, -- Viper Sting
		{
			{ id = 1510, rank = 1, level = 40 },
			{ id = 14294, rank = 2, level = 50 },
			{ id = 14295, rank = 3, level = 58 },
		}, -- Volley
		{
			{ id = 2974, rank = 1, level = 12, off = true },
			{ id = 14267, rank = 2, level = 38 },
			{ id = 14268, rank = 3, level = 60 },
		}, -- Wing Clip
		{
			{ id = 13161, rank = 1, level = 30, off = true },
			{ id = 1299445, rank = 2, level = 40, off = true },
			{ id = 1299446, rank = 3, level = 50, off = true },
			{ id = 1299447, rank = 4, level = 60, off = true },
		}, -- Aspect of the Beast
		{
			{ id = 5118, rank = 1, level = 20, off = true },
		}, -- Aspect of the Cheetah
		{
			{ id = 469145, rank = 1, off = true },
		}, -- Aspect of the Falcon
		{
			{ id = 13163, rank = 1, level = 4, off = true },
		}, -- Aspect of the Monkey
		{
			{ id = 13159, rank = 1, level = 40, off = true },
		}, -- Aspect of the Pack
		{
			{ id = 415423, rank = 1, off = true },
		}, -- Aspect of the Viper
		{
			{ id = 1462, rank = 1, level = 24, off = true },
		}, -- Beast Lore
		{
			{ id = 5149, rank = 1, level = 10, off = true },
		}, -- Beast Training
		{
			{ id = 19574, rank = 1, off = true },
		}, -- Bestial Wrath
		{
			{ id = 883, rank = 1, level = 10, off = true },
		}, -- Call Pet
		{
			{ id = 5116, rank = 1, level = 8, off = true },
		}, -- Concussive Shot
		{
			{ id = 19263, rank = 1, off = true },
		}, -- Deterrence
		{
			{ id = 2641, rank = 1, level = 10, off = true },
		}, -- Dismiss Pet
		{
			{ id = 6197, rank = 1, level = 14, off = true },
		}, -- Eagle Eye
		{
			{ id = 1002, rank = 1, level = 14, off = true },
		}, -- Eyes of the Beast
		{
			{ id = 6991, rank = 1, level = 10, off = true },
		}, -- Feed Pet
		{
			{ id = 5384, rank = 1, level = 30, off = true },
		}, -- Feign Death
		{
			{ id = 1543, rank = 1, level = 32, off = true },
		}, -- Flare
		{
			{ id = 13809, rank = 1, level = 28, off = true },
		}, -- Frost Trap
		{
			{ id = 19577, rank = 1, off = true },
		}, -- Intimidation
		{
			{ id = 3045, rank = 1, level = 26, off = true },
		}, -- Rapid Fire
		{
			{ id = 982, rank = 1, level = 10, off = true },
		}, -- Revive Pet
		{
			{ id = 19503, rank = 1, off = true },
		}, -- Scatter Shot
		{
			{ id = 1310687, rank = 1, level = 48, off = true },
			{ id = 1310785, rank = 2, level = 48, off = true },
			{ id = 1310786, rank = 3, level = 58, off = true },
		}, -- Sniper Shot
		{
			{ id = 1293241, rank = 1, level = 36, off = true },
			{ id = 1293525, rank = 2, level = 36, off = true },
			{ id = 1293526, rank = 3, level = 48, off = true },
			{ id = 1293527, rank = 4, level = 60, off = true },
		}, -- Summon Hawk
		{
			{ id = 1515, rank = 1, level = 10, off = true },
		}, -- Tame Beast
		{
			{ id = 1494, rank = 1, level = 1, off = true },
		}, -- Track Beasts
		{
			{ id = 19878, rank = 1, level = 32, off = true },
		}, -- Track Demons
		{
			{ id = 19879, rank = 1, level = 50, off = true },
		}, -- Track Dragonkin
		{
			{ id = 19880, rank = 1, level = 26, off = true },
		}, -- Track Elementals
		{
			{ id = 19882, rank = 1, level = 40, off = true },
		}, -- Track Giants
		{
			{ id = 19885, rank = 1, level = 24, off = true },
		}, -- Track Hidden
		{
			{ id = 19883, rank = 1, level = 10, off = true },
		}, -- Track Humanoids
		{
			{ id = 19884, rank = 1, level = 18, off = true },
		}, -- Track Undead
		{
			{ id = 19801, rank = 1, off = true },
		}, -- Tranquilizing Shot
		{
			{ id = 1299346, rank = 1, level = 32, off = true },
			{ id = 1299348, rank = 2, level = 32, off = true },
			{ id = 19506, rank = 3, level = 40, off = true },
			{ id = 20905, rank = 4, level = 50, off = true },
			{ id = 20906, rank = 5, level = 60, off = true },
		}, -- Trueshot Aura
		{
			{ id = 24335, rank = 1, off = true },
		}, -- Wyvern Sting
	},
	MAGE = {
		{
			{ id = 1008, rank = 1, level = 18 },
			{ id = 8455, rank = 2, level = 30 },
			{ id = 10169, rank = 3, level = 42 },
			{ id = 10170, rank = 4, level = 54 },
		}, -- Amplify Magic
		{
			{ id = 8437, rank = 2, level = 22 },
			{ id = 8438, rank = 3, level = 30 },
			{ id = 8439, rank = 4, level = 38 },
			{ id = 10201, rank = 5, level = 46 },
			{ id = 10202, rank = 6, level = 54 },
		}, -- Arcane Explosion
		{
			{ id = 1459, rank = 1, level = 1 },
			{ id = 1460, rank = 2, level = 14 },
			{ id = 1461, rank = 3, level = 28 },
			{ id = 10156, rank = 4, level = 42 },
			{ id = 10157, rank = 5, level = 56 },
		}, -- Arcane Intellect
		{
			{ id = 5143, rank = 1, level = 8 },
			{ id = 5144, rank = 2, level = 16 },
			{ id = 5145, rank = 3, level = 24 },
			{ id = 8416, rank = 4, level = 32 },
			{ id = 8417, rank = 5, level = 40 },
			{ id = 10211, rank = 6, level = 48 },
			{ id = 10212, rank = 7, level = 56 },
		}, -- Arcane Missiles
		{
			{ id = 11113, rank = 1, level = 36 },
			{ id = 13018, rank = 2, level = 36 },
			{ id = 13019, rank = 3, level = 44 },
			{ id = 13020, rank = 4, level = 52 },
			{ id = 13021, rank = 5, level = 60 },
		}, -- Blast Wave
		{
			{ id = 8492, rank = 2, level = 34 },
			{ id = 10159, rank = 3, level = 42 },
			{ id = 10160, rank = 4, level = 50 },
			{ id = 10161, rank = 5, level = 58 },
		}, -- Cone of Cold
		{
			{ id = 604, rank = 1, level = 12 },
			{ id = 8450, rank = 2, level = 24 },
			{ id = 8451, rank = 3, level = 36 },
			{ id = 10173, rank = 4, level = 48 },
			{ id = 10174, rank = 5, level = 60 },
		}, -- Dampen Magic
		{
			{ id = 2136, rank = 1, level = 6 },
			{ id = 2137, rank = 2, level = 14 },
			{ id = 2138, rank = 3, level = 22 },
			{ id = 8412, rank = 4, level = 30 },
			{ id = 8413, rank = 5, level = 38 },
			{ id = 10197, rank = 6, level = 46 },
			{ id = 10199, rank = 7, level = 54 },
		}, -- Fire Blast
		{
			{ id = 543, rank = 1, level = 20 },
			{ id = 8457, rank = 2, level = 30 },
			{ id = 8458, rank = 3, level = 40 },
			{ id = 10223, rank = 4, level = 50 },
			{ id = 10225, rank = 5, level = 60 },
		}, -- Fire Ward
		{
			{ id = 133, rank = 1, level = 1 },
			{ id = 143, rank = 2, level = 6 },
			{ id = 145, rank = 3, level = 12 },
			{ id = 3140, rank = 4, level = 18 },
			{ id = 8400, rank = 5, level = 24 },
			{ id = 8401, rank = 6, level = 30 },
			{ id = 8402, rank = 7, level = 36 },
			{ id = 10148, rank = 8, level = 42 },
			{ id = 10149, rank = 9, level = 48 },
			{ id = 10150, rank = 10, level = 54 },
			{ id = 10151, rank = 11, level = 60 },
		}, -- Fireball
		{
			{ id = 168, rank = 1, level = 1 },
			{ id = 7300, rank = 2, level = 10 },
			{ id = 7301, rank = 3, level = 20 },
		}, -- Frost Armor
		{
			{ id = 122, rank = 1, level = 10, off = true },
			{ id = 865, rank = 2, level = 26 },
			{ id = 6131, rank = 3, level = 40 },
			{ id = 10230, rank = 4, level = 54 },
		}, -- Frost Nova
		{
			{ id = 6143, rank = 1, level = 22 },
			{ id = 8461, rank = 2, level = 32 },
			{ id = 8462, rank = 3, level = 42 },
			{ id = 10177, rank = 4, level = 52 },
			{ id = 28609, rank = 5, level = 60 },
		}, -- Frost Ward
		{
			{ id = 116, rank = 1, level = 4, off = true },
			{ id = 205, rank = 2, level = 8 },
			{ id = 837, rank = 3, level = 14 },
			{ id = 7322, rank = 4, level = 20 },
			{ id = 8406, rank = 5, level = 26 },
			{ id = 8407, rank = 6, level = 32 },
			{ id = 8408, rank = 7, level = 38 },
			{ id = 10179, rank = 8, level = 44 },
			{ id = 10180, rank = 9, level = 50 },
			{ id = 10181, rank = 10, level = 56 },
		}, -- Frostbolt
		{
			{ id = 7302, rank = 1, level = 30 },
			{ id = 7320, rank = 2, level = 40 },
			{ id = 10219, rank = 3, level = 50 },
			{ id = 10220, rank = 4, level = 60 },
		}, -- Ice Armor
		{
			{ id = 11426, rank = 1, level = 46 },
			{ id = 13031, rank = 2, level = 46 },
			{ id = 13032, rank = 3, level = 52 },
			{ id = 13033, rank = 4, level = 58 },
		}, -- Ice Barrier
		{
			{ id = 6117, rank = 1, level = 34 },
			{ id = 22782, rank = 2, level = 46 },
			{ id = 22783, rank = 3, level = 58 },
		}, -- Mage Armor
		{
			{ id = 1463, rank = 1, level = 20 },
			{ id = 8494, rank = 2, level = 28 },
			{ id = 8495, rank = 3, level = 36 },
			{ id = 10191, rank = 4, level = 44 },
			{ id = 10192, rank = 5, level = 52 },
			{ id = 10193, rank = 6, level = 60 },
		}, -- Mana Shield
		{
			{ id = 11366, rank = 1, level = 24 },
			{ id = 12505, rank = 2, level = 24 },
			{ id = 12522, rank = 3, level = 30 },
			{ id = 12523, rank = 4, level = 36 },
			{ id = 12524, rank = 5, level = 42 },
			{ id = 12525, rank = 6, level = 48 },
			{ id = 12526, rank = 7, level = 54 },
			{ id = 18809, rank = 8, level = 60 },
		}, -- Pyroblast
		{
			{ id = 2948, rank = 1, level = 22, off = true },
			{ id = 8444, rank = 2, level = 28 },
			{ id = 8445, rank = 3, level = 34 },
			{ id = 8446, rank = 4, level = 40 },
			{ id = 10205, rank = 5, level = 46 },
			{ id = 10206, rank = 6, level = 52 },
			{ id = 10207, rank = 7, level = 58 },
		}, -- Scorch
		{
			{ id = 400574, rank = 1, level = 30, off = true },
			{ id = 1239696, rank = 2, level = 30, off = true },
			{ id = 1239697, rank = 3, level = 40, off = true },
			{ id = 1239699, rank = 4, level = 50, off = true },
			{ id = 1239700, rank = 5, level = 60, off = true },
		}, -- Arcane Blast
		{
			{ id = 23028, rank = 1, off = true },
		}, -- Arcane Brilliance
		{
			{ id = 12042, rank = 1, off = true },
		}, -- Arcane Power
		{
			{ id = 1953, rank = 1, level = 20, off = true },
		}, -- Blink
		{
			{ id = 10, rank = 1, level = 20, off = true },
			{ id = 6141, rank = 2, level = 28, off = true },
			{ id = 8427, rank = 3, level = 36, off = true },
			{ id = 10185, rank = 4, level = 44, off = true },
			{ id = 10186, rank = 5, level = 52, off = true },
			{ id = 10187, rank = 6, level = 60, off = true },
		}, -- Blizzard
		{
			{ id = 12472, rank = 1, off = true },
		}, -- Cold Snap
		{
			{ id = 11129, rank = 1, off = true },
		}, -- Combustion
		{
			{ id = 1296017, rank = 1, level = 6, off = true },
		}, -- Comprehend Scroll
		{
			{ id = 587, rank = 1, level = 6, off = true },
			{ id = 597, rank = 2, level = 12, off = true },
			{ id = 990, rank = 3, level = 22, off = true },
			{ id = 6129, rank = 4, level = 32, off = true },
			{ id = 10144, rank = 5, level = 42, off = true },
			{ id = 10145, rank = 6, level = 52, off = true },
		}, -- Conjure Food
		{
			{ id = 759, rank = 1, level = 28, off = true },
		}, -- Conjure Mana Agate
		{
			{ id = 10053, rank = 1, level = 48, off = true },
		}, -- Conjure Mana Citrine
		{
			{ id = 3552, rank = 1, level = 38, off = true },
		}, -- Conjure Mana Jade
		{
			{ id = 10054, rank = 1, level = 58, off = true },
		}, -- Conjure Mana Ruby
		{
			{ id = 5504, rank = 1, level = 4, off = true },
			{ id = 5505, rank = 2, level = 10, off = true },
			{ id = 5506, rank = 3, level = 20, off = true },
			{ id = 6127, rank = 4, level = 30, off = true },
			{ id = 10138, rank = 5, level = 40, off = true },
			{ id = 10139, rank = 6, level = 50, off = true },
		}, -- Conjure Water
		{
			{ id = 2139, rank = 1, level = 24, off = true },
		}, -- Counterspell
		{
			{ id = 12051, rank = 1, level = 20, off = true },
		}, -- Evocation
		{
			{ id = 2120, rank = 1, level = 16, off = true },
			{ id = 2121, rank = 2, level = 24, off = true },
			{ id = 8422, rank = 3, level = 32, off = true },
			{ id = 8423, rank = 4, level = 40, off = true },
			{ id = 10215, rank = 5, level = 48, off = true },
			{ id = 10216, rank = 6, level = 56, off = true },
		}, -- Flamestrike
		{
			{ id = 401502, rank = 1, level = 40, off = true },
			{ id = 1237312, rank = 2, level = 50, off = true },
			{ id = 1237313, rank = 3, level = 60, off = true },
		}, -- Frostfire Bolt
		{
			{ id = 11958, rank = 1, off = true },
		}, -- Ice Block
		{
			{ id = 1312002, rank = 1, level = 28, off = true },
			{ id = 400640, rank = 2, level = 28, off = true },
			{ id = 1240044, rank = 3, level = 34, off = true },
			{ id = 1240045, rank = 4, level = 42, off = true },
			{ id = 1240046, rank = 5, level = 48, off = true },
			{ id = 1240047, rank = 6, level = 56, off = true },
		}, -- Ice Lance
		{
			{ id = 118, rank = 1, level = 8, off = true },
			{ id = 12824, rank = 2, level = 20, off = true },
			{ id = 12825, rank = 3, level = 40, off = true },
			{ id = 12826, rank = 4, level = 60, off = true },
		}, -- Polymorph
		{
			{ id = 28272, rank = 1, level = 60, off = true },
		}, -- Polymorph (Pig)
		{
			{ id = 28270, rank = 1, off = true },
		}, -- Polymorph: Cow
		{
			{ id = 11419, rank = 1, level = 50, off = true },
		}, -- Portal: Darnassus
		{
			{ id = 11416, rank = 1, level = 40, off = true },
		}, -- Portal: Ironforge
		{
			{ id = 11417, rank = 1, level = 40, off = true },
		}, -- Portal: Orgrimmar
		{
			{ id = 10059, rank = 1, level = 40, off = true },
		}, -- Portal: Stormwind
		{
			{ id = 11420, rank = 1, level = 50, off = true },
		}, -- Portal: Thunder Bluff
		{
			{ id = 11418, rank = 1, level = 40, off = true },
		}, -- Portal: Undercity
		{
			{ id = 12043, rank = 1, off = true },
		}, -- Presence of Mind
		{
			{ id = 475, rank = 1, level = 18, off = true },
		}, -- Remove Lesser Curse
		{
			{ id = 130, rank = 1, level = 12, off = true },
		}, -- Slow Fall
		{
			{ id = 3565, rank = 1, level = 30, off = true },
		}, -- Teleport: Darnassus
		{
			{ id = 3562, rank = 1, level = 20, off = true },
		}, -- Teleport: Ironforge
		{
			{ id = 3567, rank = 1, level = 20, off = true },
		}, -- Teleport: Orgrimmar
		{
			{ id = 3561, rank = 1, level = 20, off = true },
		}, -- Teleport: Stormwind
		{
			{ id = 3566, rank = 1, level = 30, off = true },
		}, -- Teleport: Thunder Bluff
		{
			{ id = 3563, rank = 1, level = 20, off = true },
		}, -- Teleport: Undercity
	},
	PALADIN = {
		{
			{ id = 19740, rank = 1, level = 4 },
			{ id = 19834, rank = 2, level = 12 },
			{ id = 19835, rank = 3, level = 22 },
			{ id = 19836, rank = 4, level = 32 },
			{ id = 19837, rank = 5, level = 42 },
			{ id = 19838, rank = 6, level = 52 },
		}, -- Blessing of Might
		{
			{ id = 1022, rank = 1, level = 10 },
			{ id = 5599, rank = 2, level = 24 },
			{ id = 10278, rank = 3, level = 38 },
		}, -- Blessing of Protection
		{
			{ id = 6940, rank = 1, level = 46 },
			{ id = 20729, rank = 2, level = 54 },
		}, -- Blessing of Sacrifice
		{
			{ id = 19742, rank = 1, level = 14 },
			{ id = 19850, rank = 2, level = 24 },
			{ id = 19852, rank = 3, level = 34 },
			{ id = 19853, rank = 4, level = 44 },
			{ id = 19854, rank = 5, level = 54 },
		}, -- Blessing of Wisdom
		{
			{ id = 465, rank = 1, level = 1 },
			{ id = 10290, rank = 2, level = 10 },
			{ id = 643, rank = 3, level = 20 },
			{ id = 10291, rank = 4, level = 30 },
			{ id = 1032, rank = 5, level = 40 },
			{ id = 10292, rank = 6, level = 50 },
			{ id = 10293, rank = 7, level = 60 },
		}, -- Devotion Aura
		{
			{ id = 498, rank = 1, level = 6 },
			{ id = 5573, rank = 2, level = 18 },
		}, -- Divine Protection
		{
			{ id = 642, rank = 1, level = 34 },
			{ id = 1020, rank = 2, level = 50 },
		}, -- Divine Shield
		{
			{ id = 879, rank = 1, level = 20 },
			{ id = 5614, rank = 2, level = 28 },
			{ id = 5615, rank = 3, level = 36 },
			{ id = 10312, rank = 4, level = 44 },
			{ id = 10313, rank = 5, level = 52 },
			{ id = 10314, rank = 6, level = 60 },
		}, -- Exorcism
		{
			{ id = 19891, rank = 1, level = 36 },
			{ id = 19899, rank = 2, level = 48 },
			{ id = 19900, rank = 3, level = 60 },
		}, -- Fire Resistance Aura
		{
			{ id = 19888, rank = 1, level = 32 },
			{ id = 19897, rank = 2, level = 44 },
			{ id = 19898, rank = 3, level = 56 },
		}, -- Frost Resistance Aura
		{
			{ id = 25782, rank = 1, level = 52 },
			{ id = 25916, rank = 2, level = 60 },
		}, -- Greater Blessing of Might
		{
			{ id = 25894, rank = 1, level = 54 },
			{ id = 25918, rank = 2, level = 60 },
		}, -- Greater Blessing of Wisdom
		{
			{ id = 853, rank = 1, level = 8 },
			{ id = 5588, rank = 2, level = 24 },
			{ id = 5589, rank = 3, level = 40 },
			{ id = 10308, rank = 4, level = 54 },
		}, -- Hammer of Justice
		{
			{ id = 24275, rank = 1, level = 44 },
			{ id = 24274, rank = 2, level = 52 },
			{ id = 24239, rank = 3, level = 60 },
		}, -- Hammer of Wrath
		{
			{ id = 2812, rank = 1, level = 50 },
			{ id = 10318, rank = 2, level = 60 },
		}, -- Holy Wrath
		{
			{ id = 633, rank = 1, level = 10 },
			{ id = 2800, rank = 2, level = 30 },
			{ id = 10310, rank = 3, level = 50 },
		}, -- Lay on Hands
		{
			{ id = 7328, rank = 1, level = 12 },
			{ id = 10322, rank = 2, level = 24 },
			{ id = 10324, rank = 3, level = 36 },
			{ id = 20772, rank = 4, level = 48 },
			{ id = 20773, rank = 5, level = 60 },
		}, -- Redemption
		{
			{ id = 7294, rank = 1, level = 16 },
			{ id = 10298, rank = 2, level = 26 },
			{ id = 10299, rank = 3, level = 36 },
			{ id = 10300, rank = 4, level = 46 },
			{ id = 10301, rank = 5, level = 56 },
		}, -- Retribution Aura
		{
			{ id = 20165, rank = 1, level = 30 },
			{ id = 20347, rank = 2, level = 40 },
			{ id = 20348, rank = 3, level = 50 },
			{ id = 20349, rank = 4, level = 60 },
		}, -- Seal of Light
		{
			{ id = 20154, rank = 1, level = 1 },
			{ id = 21084, rank = 1, level = 1 },
			{ id = 20287, rank = 2, level = 10 },
			{ id = 20288, rank = 3, level = 18 },
			{ id = 20289, rank = 4, level = 26 },
			{ id = 20290, rank = 5, level = 34 },
			{ id = 20291, rank = 6, level = 42 },
			{ id = 20292, rank = 7, level = 50 },
			{ id = 20293, rank = 8, level = 58 },
		}, -- Seal of Righteousness
		{
			{ id = 20166, rank = 1, level = 38 },
			{ id = 20356, rank = 2, level = 48 },
			{ id = 20357, rank = 3, level = 58 },
		}, -- Seal of Wisdom
		{
			{ id = 21082, rank = 1, level = 6 },
			{ id = 20162, rank = 2, level = 12 },
			{ id = 20305, rank = 3, level = 22 },
			{ id = 20306, rank = 4, level = 32 },
			{ id = 20307, rank = 5, level = 42 },
			{ id = 20308, rank = 6, level = 52 },
		}, -- Seal of the Crusader
		{
			{ id = 19876, rank = 1, level = 28 },
			{ id = 19895, rank = 2, level = 40 },
			{ id = 19896, rank = 3, level = 52 },
		}, -- Shadow Resistance Aura
		{
			{ id = 2878, rank = 1, level = 24 },
			{ id = 5627, rank = 2, level = 38 },
			{ id = 10326, rank = 3, level = 52 },
		}, -- Turn Undead
		{
			{ id = 1044, rank = 1, level = 18, off = true },
		}, -- Blessing of Freedom
		{
			{ id = 20217, rank = 1, level = 20, off = true },
		}, -- Blessing of Kings
		{
			{ id = 4987, rank = 1, level = 42, off = true },
		}, -- Cleanse
		{
			{ id = 19746, rank = 1, level = 22, off = true },
		}, -- Concentration Aura
		{
			{ id = 26573, rank = 1, level = 20, off = true },
			{ id = 20116, rank = 2, level = 30, off = true },
			{ id = 20922, rank = 3, level = 40, off = true },
			{ id = 20923, rank = 4, level = 50, off = true },
			{ id = 20924, rank = 5, level = 60, off = true },
		}, -- Consecration
		{
			{ id = 20216, rank = 1, off = true },
		}, -- Divine Favor
		{
			{ id = 19752, rank = 1, level = 30, off = true },
		}, -- Divine Intervention
		{
			{ id = 19750, rank = 1, level = 20, off = true },
			{ id = 19939, rank = 2, level = 26, off = true },
			{ id = 19940, rank = 3, level = 34, off = true },
			{ id = 19941, rank = 4, level = 42, off = true },
			{ id = 19942, rank = 5, level = 50, off = true },
			{ id = 19943, rank = 6, level = 58, off = true },
		}, -- Flash of Light
		{
			{ id = 25898, rank = 1, level = 60, off = true },
		}, -- Greater Blessing of Kings
		{
			{ id = 639, rank = 2, level = 6, off = true },
			{ id = 647, rank = 3, level = 14, off = true },
			{ id = 1026, rank = 4, level = 22, off = true },
			{ id = 1042, rank = 5, level = 30, off = true },
			{ id = 3472, rank = 6, level = 38, off = true },
			{ id = 10328, rank = 7, level = 46, off = true },
			{ id = 10329, rank = 8, level = 54, off = true },
		}, -- Holy Light
		{
			{ id = 20925, rank = 1, level = 50, off = true },
		}, -- Holy Shield
		{
			{ id = 1311606, rank = 1, level = 40, off = true },
			{ id = 20473, rank = 2, level = 40, off = true },
			{ id = 20929, rank = 3, level = 48, off = true },
			{ id = 20930, rank = 4, level = 56, off = true },
		}, -- Holy Shock
		{
			{ id = 679, rank = 1, level = 6, off = true },
			{ id = 678, rank = 2, level = 12, off = true },
			{ id = 1866, rank = 3, level = 20, off = true },
			{ id = 680, rank = 4, level = 28, off = true },
			{ id = 2495, rank = 5, level = 36, off = true },
			{ id = 5569, rank = 6, level = 44, off = true },
			{ id = 10332, rank = 7, level = 52, off = true },
			{ id = 10333, rank = 8, level = 60, off = true },
		}, -- Holy Strike
		{
			{ id = 20271, rank = 1, level = 4, off = true },
		}, -- Judgement
		{
			{ id = 1310911, rank = 1, level = 50, off = true },
			{ id = 1311590, rank = 2, level = 50, off = true },
			{ id = 1311595, rank = 3, level = 60, off = true },
		}, -- Light's Vigil
		{
			{ id = 1152, rank = 1, level = 8, off = true },
		}, -- Purify
		{
			{ id = 20066, rank = 1, off = true },
		}, -- Repentance
		{
			{ id = 25780, rank = 1, level = 10, off = true },
		}, -- Righteous Fury
		{
			{ id = 20218, rank = 1, level = 30, off = true },
		}, -- Sanctity Aura
		{
			{ id = 20375, rank = 1, level = 30, off = true },
			{ id = 20915, rank = 2, level = 30, off = true },
			{ id = 20918, rank = 3, level = 40, off = true },
			{ id = 20919, rank = 4, level = 50, off = true },
			{ id = 20920, rank = 5, level = 60, off = true },
		}, -- Seal of Command
		{
			{ id = 1311649, rank = 1, level = 10, off = true },
			{ id = 1311656, rank = 2, level = 18, off = true },
			{ id = 20163, rank = 3, level = 26, off = true },
			{ id = 20419, rank = 4, level = 34, off = true },
			{ id = 20421, rank = 5, level = 42, off = true },
			{ id = 20422, rank = 6, level = 50, off = true },
			{ id = 20423, rank = 7, level = 58, off = true },
		}, -- Seal of Fury
		{
			{ id = 20164, rank = 1, level = 22, off = true },
		}, -- Seal of Justice
		{
			{ id = 5502, rank = 1, level = 20, off = true },
		}, -- Sense Undead
		{
			{ id = 23214, rank = 1, level = 60, off = true },
		}, -- Summon Charger
		{
			{ id = 13819, rank = 1, level = 40, off = true },
		}, -- Summon Warhorse
		{
			{ id = 1310994, rank = 1, off = true },
		}, -- Swift Judgement
		{
			{ id = 1311015, rank = 1, off = true },
		}, -- Templar's Bulwark
	},
	PRIEST = {
		{
			{ id = 13908, rank = 1, level = 10 },
			{ id = 19236, rank = 2, level = 18 },
			{ id = 19238, rank = 3, level = 26 },
			{ id = 19240, rank = 4, level = 34 },
			{ id = 19241, rank = 5, level = 42 },
			{ id = 19242, rank = 6, level = 50 },
			{ id = 19243, rank = 7, level = 58 },
		}, -- Desperate Prayer
		{
			{ id = 2944, rank = 1, level = 20 },
			{ id = 19276, rank = 2, level = 28 },
			{ id = 19277, rank = 3, level = 36 },
			{ id = 19278, rank = 4, level = 44 },
			{ id = 19279, rank = 5, level = 52 },
			{ id = 19280, rank = 6, level = 60 },
		}, -- Devouring Plague
		{
			{ id = 14752, rank = 1, level = 30 },
			{ id = 14818, rank = 2, level = 40 },
			{ id = 14819, rank = 3, level = 50 },
			{ id = 27841, rank = 4, level = 60 },
		}, -- Divine Spirit
		{
			{ id = 2651, rank = 1, level = 20 },
		}, -- Elune's Grace
		{
			{ id = 586, rank = 1, level = 8 },
			{ id = 9578, rank = 2, level = 20 },
			{ id = 9579, rank = 3, level = 30 },
			{ id = 9592, rank = 4, level = 40 },
			{ id = 10941, rank = 5, level = 50 },
			{ id = 10942, rank = 6, level = 60 },
		}, -- Fade
		{
			{ id = 13896, rank = 1, level = 20 },
			{ id = 19271, rank = 2, level = 30 },
			{ id = 19273, rank = 3, level = 40 },
			{ id = 19274, rank = 4, level = 50 },
			{ id = 19275, rank = 5, level = 60 },
		}, -- Feedback
		{
			{ id = 9035, rank = 1, level = 10 },
			{ id = 19281, rank = 2, level = 20 },
			{ id = 19282, rank = 3, level = 30 },
			{ id = 19283, rank = 4, level = 40 },
			{ id = 19284, rank = 5, level = 50 },
			{ id = 19285, rank = 6, level = 60 },
		}, -- Hex of Weakness
		{
			{ id = 14914, rank = 1, level = 20 },
			{ id = 15262, rank = 2, level = 24 },
			{ id = 15263, rank = 3, level = 30 },
			{ id = 15264, rank = 4, level = 36 },
			{ id = 15265, rank = 5, level = 42 },
			{ id = 15266, rank = 6, level = 48 },
			{ id = 15267, rank = 7, level = 54 },
			{ id = 15261, rank = 8, level = 60 },
		}, -- Holy Fire
		{
			{ id = 588, rank = 1, level = 12 },
			{ id = 7128, rank = 2, level = 20 },
			{ id = 602, rank = 3, level = 30 },
			{ id = 1006, rank = 4, level = 40 },
			{ id = 10951, rank = 5, level = 50 },
			{ id = 10952, rank = 6, level = 60 },
		}, -- Inner Fire
		{
			{ id = 8129, rank = 1, level = 24 },
			{ id = 8131, rank = 2, level = 32 },
			{ id = 10874, rank = 3, level = 40 },
			{ id = 10875, rank = 4, level = 48 },
			{ id = 10876, rank = 5, level = 56 },
		}, -- Mana Burn
		{
			{ id = 8092, rank = 1, level = 10 },
			{ id = 8102, rank = 2, level = 16 },
			{ id = 8103, rank = 3, level = 22 },
			{ id = 8104, rank = 4, level = 28 },
			{ id = 8105, rank = 5, level = 34 },
			{ id = 8106, rank = 6, level = 40 },
			{ id = 10945, rank = 7, level = 46 },
			{ id = 10946, rank = 8, level = 52 },
			{ id = 10947, rank = 9, level = 58 },
		}, -- Mind Blast
		{
			{ id = 605, rank = 1, level = 30 },
			{ id = 10911, rank = 2, level = 44 },
			{ id = 10912, rank = 3, level = 58 },
		}, -- Mind Control
		{
			{ id = 15407, rank = 1, level = 28 },
			{ id = 17311, rank = 2, level = 28 },
			{ id = 17312, rank = 3, level = 36 },
			{ id = 17313, rank = 4, level = 44 },
			{ id = 17314, rank = 5, level = 52 },
			{ id = 18807, rank = 6, level = 60 },
		}, -- Mind Flay
		{
			{ id = 453, rank = 1, level = 20 },
			{ id = 8192, rank = 2, level = 36 },
			{ id = 10953, rank = 3, level = 52 },
		}, -- Mind Soothe
		{
			{ id = 2096, rank = 1, level = 22 },
			{ id = 10909, rank = 2, level = 44 },
		}, -- Mind Vision
		{
			{ id = 1243, rank = 1, level = 1 },
			{ id = 1244, rank = 2, level = 12 },
			{ id = 1245, rank = 3, level = 24 },
			{ id = 2791, rank = 4, level = 36 },
			{ id = 10937, rank = 5, level = 48 },
			{ id = 10938, rank = 6, level = 60 },
		}, -- Power Word: Fortitude
		{
			{ id = 17, rank = 1, level = 6 },
			{ id = 592, rank = 2, level = 12 },
			{ id = 600, rank = 3, level = 18 },
			{ id = 3747, rank = 4, level = 24 },
			{ id = 6065, rank = 5, level = 30 },
			{ id = 6066, rank = 6, level = 36 },
			{ id = 10898, rank = 7, level = 42 },
			{ id = 10899, rank = 8, level = 48 },
			{ id = 10900, rank = 9, level = 54 },
			{ id = 10901, rank = 10, level = 60 },
		}, -- Power Word: Shield
		{
			{ id = 21562, rank = 1, level = 48 },
			{ id = 21564, rank = 2, level = 60 },
		}, -- Prayer of Fortitude
		{
			{ id = 8122, rank = 1, level = 14, off = true },
			{ id = 8124, rank = 2, level = 28 },
			{ id = 10888, rank = 3, level = 42 },
			{ id = 10890, rank = 4, level = 56 },
		}, -- Psychic Scream
		{
			{ id = 2006, rank = 1, level = 10 },
			{ id = 2010, rank = 2, level = 22 },
			{ id = 10880, rank = 3, level = 34 },
			{ id = 10881, rank = 4, level = 46 },
			{ id = 20770, rank = 5, level = 58 },
		}, -- Resurrection
		{
			{ id = 9484, rank = 1, level = 20 },
			{ id = 9485, rank = 2, level = 40 },
			{ id = 10955, rank = 3, level = 60 },
		}, -- Shackle Undead
		{
			{ id = 976, rank = 1, level = 30 },
			{ id = 10957, rank = 2, level = 42 },
			{ id = 10958, rank = 3, level = 56 },
		}, -- Shadow Protection
		{
			{ id = 589, rank = 1, level = 4 },
			{ id = 594, rank = 2, level = 10 },
			{ id = 970, rank = 3, level = 18 },
			{ id = 992, rank = 4, level = 26 },
			{ id = 2767, rank = 5, level = 34 },
			{ id = 10892, rank = 6, level = 42 },
			{ id = 10893, rank = 7, level = 50 },
			{ id = 10894, rank = 8, level = 58 },
		}, -- Shadow Word: Pain
		{
			{ id = 18137, rank = 1, level = 20 },
			{ id = 19308, rank = 2, level = 28 },
			{ id = 19309, rank = 3, level = 36 },
			{ id = 19310, rank = 4, level = 44 },
			{ id = 19311, rank = 5, level = 52 },
			{ id = 19312, rank = 6, level = 60 },
		}, -- Shadowguard
		{
			{ id = 585, rank = 1, level = 1 },
			{ id = 591, rank = 2, level = 6 },
			{ id = 598, rank = 3, level = 14 },
			{ id = 984, rank = 4, level = 22 },
			{ id = 1004, rank = 5, level = 30 },
			{ id = 6060, rank = 6, level = 38 },
			{ id = 10933, rank = 7, level = 46 },
			{ id = 10934, rank = 8, level = 54 },
		}, -- Smite
		{
			{ id = 10797, rank = 1, level = 10 },
			{ id = 19296, rank = 2, level = 18 },
			{ id = 19299, rank = 3, level = 26 },
			{ id = 19302, rank = 4, level = 34 },
			{ id = 19303, rank = 5, level = 42 },
			{ id = 19304, rank = 6, level = 50 },
			{ id = 19305, rank = 7, level = 58 },
		}, -- Starshards
		{
			{ id = 2652, rank = 1, level = 10 },
			{ id = 19261, rank = 2, level = 20 },
			{ id = 19262, rank = 3, level = 30 },
			{ id = 19264, rank = 4, level = 40 },
			{ id = 19265, rank = 5, level = 50 },
			{ id = 19266, rank = 6, level = 60 },
		}, -- Touch of Weakness
		{
			{ id = 552, rank = 1, level = 32, off = true },
		}, -- Abolish Disease
		{
			{ id = 401937, rank = 1, level = 32, off = true },
		}, -- Binding Heal
		{
			{ id = 1277331, rank = 1, level = 20, off = true },
			{ id = 1277332, rank = 2, level = 30, off = true },
			{ id = 1277333, rank = 3, level = 40, off = true },
			{ id = 1277334, rank = 4, level = 50, off = true },
			{ id = 1277335, rank = 5, level = 60, off = true },
		}, -- Chastise
		{
			{ id = 1277634, rank = 2, level = 30, off = true },
			{ id = 1277638, rank = 3, level = 40, off = true },
			{ id = 1277639, rank = 4, level = 50, off = true },
			{ id = 1277640, rank = 5, level = 60, off = true },
		}, -- Contingency Plan
		{
			{ id = 528, rank = 1, level = 14, off = true },
		}, -- Cure Disease
		{
			{ id = 1277325, rank = 2, level = 30, off = true },
			{ id = 1277326, rank = 3, level = 40, off = true },
			{ id = 1277327, rank = 4, level = 50, off = true },
			{ id = 1277328, rank = 5, level = 60, off = true },
		}, -- Dark Sacrifice
		{
			{ id = 527, rank = 1, level = 18, off = true },
			{ id = 988, rank = 2, level = 36, off = true },
		}, -- Dispel Magic
		{
			{ id = 1277371, rank = 2, level = 18, off = true },
			{ id = 1277372, rank = 3, level = 26, off = true },
			{ id = 1277374, rank = 4, level = 34, off = true },
			{ id = 1277376, rank = 5, level = 42, off = true },
			{ id = 1277377, rank = 6, level = 50, off = true },
			{ id = 1277378, rank = 7, level = 58, off = true },
		}, -- Divine Grace
		{
			{ id = 6346, rank = 1, level = 20, off = true },
		}, -- Fear Ward
		{
			{ id = 2061, rank = 1, level = 20, off = true },
			{ id = 9472, rank = 2, level = 26, off = true },
			{ id = 9473, rank = 3, level = 32, off = true },
			{ id = 9474, rank = 4, level = 38, off = true },
			{ id = 10915, rank = 5, level = 44, off = true },
			{ id = 10916, rank = 6, level = 50, off = true },
			{ id = 10917, rank = 7, level = 56, off = true },
		}, -- Flash Heal
		{
			{ id = 2060, rank = 1, level = 40, off = true },
			{ id = 10963, rank = 2, level = 46, off = true },
			{ id = 10964, rank = 3, level = 52, off = true },
			{ id = 10965, rank = 4, level = 58, off = true },
		}, -- Greater Heal
		{
			{ id = 2054, rank = 1, level = 16, off = true },
			{ id = 2055, rank = 2, level = 22, off = true },
			{ id = 6063, rank = 3, level = 28, off = true },
			{ id = 6064, rank = 4, level = 34, off = true },
		}, -- Heal
		{
			{ id = 15237, rank = 1, level = 28, off = true },
			{ id = 15430, rank = 2, level = 28, off = true },
			{ id = 15431, rank = 3, level = 36, off = true },
			{ id = 27799, rank = 4, level = 44, off = true },
			{ id = 27800, rank = 5, level = 52, off = true },
			{ id = 27801, rank = 6, level = 60, off = true },
		}, -- Holy Nova
		{
			{ id = 14751, rank = 1, off = true },
		}, -- Inner Focus
		{
			{ id = 2050, rank = 1, level = 1, off = true },
			{ id = 2052, rank = 2, level = 4, off = true },
			{ id = 2053, rank = 3, level = 10, off = true },
		}, -- Lesser Heal
		{
			{ id = 1706, rank = 1, level = 34, off = true },
		}, -- Levitate
		{
			{ id = 724, rank = 1, off = true },
		}, -- Lightwell
		{
			{ id = 402174, rank = 1, level = 40, off = true },
			{ id = 1240720, rank = 2, level = 40, off = true },
			{ id = 1240721, rank = 3, level = 50, off = true },
			{ id = 1316995, rank = 4, level = 60, off = true },
		}, -- Penance
		{
			{ id = 10060, rank = 1, off = true },
		}, -- Power Infusion
		{
			{ id = 596, rank = 1, level = 30, off = true },
			{ id = 996, rank = 2, level = 40, off = true },
			{ id = 10960, rank = 3, level = 50, off = true },
			{ id = 10961, rank = 4, level = 60, off = true },
		}, -- Prayer of Healing
		{
			{ id = 401859, rank = 1, level = 50, off = true },
			{ id = 1240826, rank = 2, level = 50, off = true },
			{ id = 1240827, rank = 3, level = 60, off = true },
		}, -- Prayer of Mending
		{
			{ id = 27683, rank = 1, off = true },
		}, -- Prayer of Shadow Protection
		{
			{ id = 27681, rank = 1, level = 60, off = true },
		}, -- Prayer of Spirit
		{
			{ id = 139, rank = 1, level = 8, off = true },
			{ id = 6074, rank = 2, level = 14, off = true },
			{ id = 6075, rank = 3, level = 20, off = true },
			{ id = 6076, rank = 4, level = 26, off = true },
			{ id = 6077, rank = 5, level = 32, off = true },
			{ id = 6078, rank = 6, level = 38, off = true },
			{ id = 10927, rank = 7, level = 44, off = true },
			{ id = 10928, rank = 8, level = 50, off = true },
			{ id = 10929, rank = 9, level = 56, off = true },
		}, -- Renew
		{
			{ id = 1309595, rank = 1, level = 32, off = true },
			{ id = 1309633, rank = 2, level = 40, off = true },
			{ id = 1309635, rank = 3, level = 48, off = true },
			{ id = 1309636, rank = 4, level = 56, off = true },
		}, -- Shadow Word: Death
		{
			{ id = 15473, rank = 1, level = 40, off = true },
		}, -- Shadowform
		{
			{ id = 15487, rank = 1, off = true },
		}, -- Silence
		{
			{ id = 15286, rank = 1, off = true },
		}, -- Vampiric Embrace
	},
	ROGUE = {
		{
			{ id = 8676, rank = 1, level = 18 },
			{ id = 8724, rank = 2, level = 26 },
			{ id = 8725, rank = 3, level = 34 },
			{ id = 11267, rank = 4, level = 42 },
			{ id = 11268, rank = 5, level = 50 },
			{ id = 11269, rank = 6, level = 58 },
		}, -- Ambush
		{
			{ id = 53, rank = 1, level = 4 },
			{ id = 2589, rank = 2, level = 12 },
			{ id = 2590, rank = 3, level = 20 },
			{ id = 2591, rank = 4, level = 28 },
			{ id = 8721, rank = 5, level = 36 },
			{ id = 11279, rank = 6, level = 44 },
			{ id = 11280, rank = 7, level = 52 },
			{ id = 11281, rank = 8, level = 60 },
		}, -- Backstab
		{
			{ id = 2098, rank = 1, level = 1 },
			{ id = 6760, rank = 2, level = 8 },
			{ id = 6761, rank = 3, level = 16 },
			{ id = 6762, rank = 4, level = 24 },
			{ id = 8623, rank = 5, level = 32 },
			{ id = 8624, rank = 6, level = 40 },
			{ id = 11299, rank = 7, level = 48 },
			{ id = 11300, rank = 8, level = 56 },
			{ id = 31016, rank = 9, level = 60 },
		}, -- Eviscerate
		{
			{ id = 8647, rank = 1, level = 14 },
			{ id = 8649, rank = 2, level = 26 },
			{ id = 8650, rank = 3, level = 36 },
			{ id = 11197, rank = 4, level = 46 },
			{ id = 11198, rank = 5, level = 56 },
		}, -- Expose Armor
		{
			{ id = 1966, rank = 1, level = 16 },
			{ id = 6768, rank = 2, level = 28 },
			{ id = 8637, rank = 3, level = 40 },
			{ id = 11303, rank = 4, level = 52 },
		}, -- Feint
		{
			{ id = 703, rank = 1, level = 14 },
			{ id = 8631, rank = 2, level = 22 },
			{ id = 8632, rank = 3, level = 30 },
			{ id = 8633, rank = 4, level = 38 },
			{ id = 11289, rank = 5, level = 46 },
			{ id = 11290, rank = 6, level = 54 },
		}, -- Garrote
		{
			{ id = 1776, rank = 1, level = 6 },
			{ id = 1777, rank = 2, level = 18 },
			{ id = 8629, rank = 3, level = 32 },
			{ id = 11285, rank = 4, level = 46 },
			{ id = 11286, rank = 5, level = 60 },
		}, -- Gouge
		{
			{ id = 16511, rank = 1, level = 30 },
		}, -- Hemorrhage
		{
			{ id = 1766, rank = 1, level = 12 },
			{ id = 1767, rank = 2, level = 26 },
			{ id = 1768, rank = 3, level = 42 },
			{ id = 1769, rank = 4, level = 58 },
		}, -- Kick
		{
			{ id = 408, rank = 1, level = 30 },
			{ id = 8643, rank = 2, level = 50 },
		}, -- Kidney Shot
		{
			{ id = 1943, rank = 1, level = 20 },
			{ id = 8639, rank = 2, level = 28 },
			{ id = 8640, rank = 3, level = 36 },
			{ id = 11273, rank = 4, level = 44 },
			{ id = 11274, rank = 5, level = 52 },
			{ id = 11275, rank = 6, level = 60 },
		}, -- Rupture
		{
			{ id = 6770, rank = 1, level = 10 },
			{ id = 2070, rank = 2, level = 28 },
			{ id = 11297, rank = 3, level = 48 },
		}, -- Sap
		{
			{ id = 1752, rank = 1, level = 1 },
			{ id = 1757, rank = 2, level = 6 },
			{ id = 1758, rank = 3, level = 14 },
			{ id = 1759, rank = 4, level = 22 },
			{ id = 1760, rank = 5, level = 30 },
			{ id = 8621, rank = 6, level = 38 },
			{ id = 11293, rank = 7, level = 46 },
			{ id = 11294, rank = 8, level = 54 },
		}, -- Sinister Strike
		{
			{ id = 5171, rank = 1, level = 10 },
			{ id = 6774, rank = 2, level = 42 },
		}, -- Slice and Dice
		{
			{ id = 2983, rank = 1, level = 10 },
			{ id = 8696, rank = 2, level = 34 },
			{ id = 11305, rank = 3, level = 58 },
		}, -- Sprint
		{
			{ id = 1784, rank = 1, level = 1 },
			{ id = 1785, rank = 2, level = 20 },
			{ id = 1786, rank = 3, level = 40 },
			{ id = 1787, rank = 4, level = 60 },
		}, -- Stealth
		{
			{ id = 1856, rank = 1, level = 22 },
			{ id = 1857, rank = 2, level = 42 },
		}, -- Vanish
		{
			{ id = 13750, rank = 1, off = true },
		}, -- Adrenaline Rush
		{
			{ id = 13877, rank = 1, off = true },
		}, -- Blade Flurry
		{
			{ id = 2094, rank = 1, off = true },
		}, -- Blind
		{
			{ id = 1833, rank = 1, level = 26, off = true },
		}, -- Cheap Shot
		{
			{ id = 14177, rank = 1, off = true },
		}, -- Cold Blood
		{
			{ id = 2836, rank = 1, level = 24, off = true },
		}, -- Detect Traps
		{
			{ id = 1842, rank = 1, level = 30, off = true },
		}, -- Disarm Trap
		{
			{ id = 1725, rank = 1, level = 22, off = true },
		}, -- Distract
		{
			{ id = 5277, rank = 1, level = 8, off = true },
		}, -- Evasion
		{
			{ id = 14278, rank = 1, off = true },
		}, -- Ghostly Strike
		{
			{ id = 1804, rank = 1, level = 16, off = true },
		}, -- Pick Lock
		{
			{ id = 921, rank = 1, level = 4, off = true },
		}, -- Pick Pocket
		{
			{ id = 14183, rank = 1, off = true },
		}, -- Premeditation
		{
			{ id = 14185, rank = 1, off = true },
		}, -- Preparation
		{
			{ id = 14251, rank = 1, off = true },
		}, -- Riposte
		{
			{ id = 1860, rank = 1, level = 40, off = true },
		}, -- Safe Fall
		{
			{ id = 1310703, rank = 1, off = true },
		}, -- Venom
	},
	SHAMAN = {
		{
			{ id = 2008, rank = 1, level = 12 },
			{ id = 20609, rank = 2, level = 24 },
			{ id = 20610, rank = 3, level = 36 },
			{ id = 20776, rank = 4, level = 48 },
			{ id = 20777, rank = 5, level = 60 },
		}, -- Ancestral Spirit
		{
			{ id = 421, rank = 1, level = 32 },
			{ id = 930, rank = 2, level = 40 },
			{ id = 2860, rank = 3, level = 48 },
			{ id = 10605, rank = 4, level = 56 },
		}, -- Chain Lightning
		{
			{ id = 8042, rank = 1, level = 4, off = true },
			{ id = 8044, rank = 2, level = 8 },
			{ id = 8045, rank = 3, level = 14 },
			{ id = 8046, rank = 4, level = 24 },
			{ id = 10412, rank = 5, level = 36 },
			{ id = 10413, rank = 6, level = 48 },
			{ id = 10414, rank = 7, level = 60 },
		}, -- Earth Shock
		{
			{ id = 8184, rank = 1, level = 28 },
			{ id = 10537, rank = 2, level = 42 },
			{ id = 10538, rank = 3, level = 58 },
		}, -- Fire Resistance Totem
		{
			{ id = 8050, rank = 1, level = 10 },
			{ id = 8052, rank = 2, level = 18 },
			{ id = 8053, rank = 3, level = 28 },
			{ id = 10447, rank = 4, level = 40 },
			{ id = 10448, rank = 5, level = 52 },
			{ id = 29228, rank = 6, level = 60 },
		}, -- Flame Shock
		{
			{ id = 8227, rank = 1, level = 28 },
			{ id = 8249, rank = 2, level = 38 },
			{ id = 10526, rank = 3, level = 48 },
			{ id = 16387, rank = 4, level = 58 },
		}, -- Flametongue Totem
		{
			{ id = 8024, rank = 1, level = 10 },
			{ id = 8027, rank = 2, level = 18 },
			{ id = 8030, rank = 3, level = 26 },
			{ id = 16339, rank = 4, level = 36 },
			{ id = 16341, rank = 5, level = 46 },
			{ id = 16342, rank = 6, level = 56 },
		}, -- Flametongue Weapon
		{
			{ id = 8181, rank = 1, level = 24 },
			{ id = 10478, rank = 2, level = 38 },
			{ id = 10479, rank = 3, level = 54 },
		}, -- Frost Resistance Totem
		{
			{ id = 8056, rank = 1, level = 20, off = true },
			{ id = 8058, rank = 2, level = 34 },
			{ id = 10472, rank = 3, level = 46 },
			{ id = 10473, rank = 4, level = 58 },
		}, -- Frost Shock
		{
			{ id = 8033, rank = 1, level = 20 },
			{ id = 8038, rank = 2, level = 28 },
			{ id = 10456, rank = 3, level = 38 },
			{ id = 16355, rank = 4, level = 48 },
			{ id = 16356, rank = 5, level = 58 },
		}, -- Frostbrand Weapon
		{
			{ id = 8835, rank = 1, level = 42 },
			{ id = 10627, rank = 2, level = 56 },
		}, -- Grace of Air Totem
		{
			{ id = 5394, rank = 1, level = 20 },
			{ id = 6375, rank = 2, level = 30 },
			{ id = 6377, rank = 3, level = 40 },
			{ id = 10462, rank = 4, level = 50 },
			{ id = 10463, rank = 5, level = 60 },
		}, -- Healing Stream Totem
		{
			{ id = 403, rank = 1, level = 1, off = true },
			{ id = 529, rank = 2, level = 8 },
			{ id = 548, rank = 3, level = 14 },
			{ id = 915, rank = 4, level = 20 },
			{ id = 943, rank = 5, level = 26 },
			{ id = 6041, rank = 6, level = 32 },
			{ id = 10391, rank = 7, level = 38 },
			{ id = 10392, rank = 8, level = 44 },
			{ id = 15207, rank = 9, level = 50 },
			{ id = 15208, rank = 10, level = 56 },
		}, -- Lightning Bolt
		{
			{ id = 324, rank = 1, level = 8 },
			{ id = 325, rank = 2, level = 16 },
			{ id = 905, rank = 3, level = 24 },
			{ id = 945, rank = 4, level = 32 },
			{ id = 8134, rank = 5, level = 40 },
			{ id = 10431, rank = 6, level = 48 },
			{ id = 10432, rank = 7, level = 56 },
		}, -- Lightning Shield
		{
			{ id = 8190, rank = 1, level = 26 },
			{ id = 10585, rank = 2, level = 36 },
			{ id = 10586, rank = 3, level = 46 },
			{ id = 10587, rank = 4, level = 56 },
		}, -- Magma Totem
		{
			{ id = 5675, rank = 1, level = 26 },
			{ id = 10495, rank = 2, level = 36 },
			{ id = 10496, rank = 3, level = 46 },
			{ id = 10497, rank = 4, level = 56 },
		}, -- Mana Spring Totem
		{
			{ id = 16190, rank = 1, level = 48 },
			{ id = 17354, rank = 2, level = 38 },
			{ id = 17359, rank = 3, level = 48 },
			{ id = 1325256, rank = 4, level = 58 },
		}, -- Mana Tide Totem
		{
			{ id = 10595, rank = 1, level = 30 },
			{ id = 10600, rank = 2, level = 44 },
			{ id = 10601, rank = 3, level = 60 },
		}, -- Nature Resistance Totem
		{
			{ id = 8017, rank = 1, level = 1 },
			{ id = 8018, rank = 2, level = 8 },
			{ id = 8019, rank = 3, level = 16 },
			{ id = 10399, rank = 4, level = 24 },
			{ id = 16314, rank = 5, level = 34 },
			{ id = 16315, rank = 6, level = 44 },
			{ id = 16316, rank = 7, level = 54 },
		}, -- Rockbiter Weapon
		{
			{ id = 3599, rank = 1, level = 10 },
			{ id = 6363, rank = 2, level = 20 },
			{ id = 6364, rank = 3, level = 30 },
			{ id = 6365, rank = 4, level = 40 },
			{ id = 10437, rank = 5, level = 50 },
			{ id = 10438, rank = 6, level = 60 },
		}, -- Searing Totem
		{
			{ id = 5730, rank = 1, level = 8 },
			{ id = 6390, rank = 2, level = 18 },
			{ id = 6391, rank = 3, level = 28 },
			{ id = 6392, rank = 4, level = 38 },
			{ id = 10427, rank = 5, level = 48 },
			{ id = 10428, rank = 6, level = 58 },
		}, -- Stoneclaw Totem
		{
			{ id = 8071, rank = 1, level = 4 },
			{ id = 8154, rank = 2, level = 14 },
			{ id = 8155, rank = 3, level = 24 },
			{ id = 10406, rank = 4, level = 34 },
			{ id = 10407, rank = 5, level = 44 },
			{ id = 10408, rank = 6, level = 54 },
		}, -- Stoneskin Totem
		{
			{ id = 8075, rank = 1, level = 10 },
			{ id = 8160, rank = 2, level = 24 },
			{ id = 8161, rank = 3, level = 38 },
			{ id = 10442, rank = 4, level = 52 },
		}, -- Strength of Earth Totem
		{
			{ id = 8512, rank = 1, level = 32 },
			{ id = 10613, rank = 2, level = 42 },
			{ id = 10614, rank = 3, level = 52 },
		}, -- Windfury Totem
		{
			{ id = 8232, rank = 1, level = 30 },
			{ id = 8235, rank = 2, level = 40 },
			{ id = 10486, rank = 3, level = 50 },
			{ id = 16362, rank = 4, level = 60 },
		}, -- Windfury Weapon
		{
			{ id = 15107, rank = 1, level = 36 },
			{ id = 15111, rank = 2, level = 46 },
			{ id = 15112, rank = 3, level = 56 },
		}, -- Windwall Totem
		{
			{ id = 556, rank = 1, level = 30, off = true },
		}, -- Astral Recall
		{
			{ id = 66843, rank = 1, level = 30, off = true },
		}, -- Call of the Ancestors
		{
			{ id = 66842, rank = 1, level = 20, off = true },
		}, -- Call of the Elements
		{
			{ id = 66844, rank = 1, level = 40, off = true },
		}, -- Call of the Spirits
		{
			{ id = 1064, rank = 1, level = 40, off = true },
			{ id = 10622, rank = 2, level = 46, off = true },
			{ id = 10623, rank = 3, level = 54, off = true },
		}, -- Chain Heal
		{
			{ id = 2870, rank = 1, level = 22, off = true },
		}, -- Cure Disease
		{
			{ id = 526, rank = 1, level = 16, off = true },
		}, -- Cure Poison
		{
			{ id = 8170, rank = 1, level = 38, off = true },
		}, -- Disease Cleansing Totem
		{
			{ id = 2484, rank = 1, level = 6, off = true },
		}, -- Earthbind Totem
		{
			{ id = 16166, rank = 1, off = true },
		}, -- Elemental Mastery
		{
			{ id = 6196, rank = 1, level = 26, off = true },
		}, -- Far Sight
		{
			{ id = 408341, rank = 1, level = 12, off = true },
			{ id = 408342, rank = 2, level = 22, off = true },
			{ id = 408343, rank = 3, level = 32, off = true },
			{ id = 408344, rank = 4, level = 42, off = true },
			{ id = 408345, rank = 5, level = 52, off = true },
		}, -- Fire Nova
		{
			{ id = 2645, rank = 1, level = 20, off = true },
		}, -- Ghost Wolf
		{
			{ id = 8177, rank = 1, level = 30, off = true },
		}, -- Grounding Totem
		{
			{ id = 331, rank = 1, level = 1, off = true },
			{ id = 332, rank = 2, level = 6, off = true },
			{ id = 547, rank = 3, level = 12, off = true },
			{ id = 913, rank = 4, level = 18, off = true },
			{ id = 939, rank = 5, level = 24, off = true },
			{ id = 959, rank = 6, level = 32, off = true },
			{ id = 8005, rank = 7, level = 40, off = true },
			{ id = 10395, rank = 8, level = 48, off = true },
			{ id = 10396, rank = 9, level = 56, off = true },
		}, -- Healing Wave
		{
			{ id = 408490, rank = 1, level = 50, off = true },
		}, -- Lava Burst
		{
			{ id = 8004, rank = 1, level = 20, off = true },
			{ id = 8008, rank = 2, level = 28, off = true },
			{ id = 8010, rank = 3, level = 36, off = true },
			{ id = 10466, rank = 4, level = 44, off = true },
			{ id = 10467, rank = 5, level = 52, off = true },
			{ id = 10468, rank = 6, level = 60, off = true },
		}, -- Lesser Healing Wave
		{
			{ id = 16188, rank = 1, off = true },
		}, -- Nature's Swiftness
		{
			{ id = 8166, rank = 1, level = 22, off = true },
		}, -- Poison Cleansing Totem
		{
			{ id = 370, rank = 1, level = 12, off = true },
			{ id = 8012, rank = 2, level = 32, off = true },
		}, -- Purge
		{
			{ id = 20608, rank = 1, level = 30, off = true },
		}, -- Reincarnation
		{
			{ id = 408521, rank = 1, level = 50, off = true },
			{ id = 1239242, rank = 2, level = 50, off = true },
			{ id = 1239243, rank = 3, level = 60, off = true },
		}, -- Riptide
		{
			{ id = 6495, rank = 1, level = 34, off = true },
		}, -- Sentry Totem
		{
			{ id = 17364, rank = 1, off = true },
		}, -- Stormstrike
		{
			{ id = 437009, rank = 1, level = 22, off = true },
		}, -- Totemic Projection
		{
			{ id = 36936, rank = 1, level = 20, off = true },
		}, -- Totemic Recall
		{
			{ id = 8143, rank = 1, level = 18, off = true },
		}, -- Tremor Totem
		{
			{ id = 131, rank = 1, level = 22, off = true },
		}, -- Water Breathing
		{
			{ id = 408510, rank = 1, level = 20, off = true },
		}, -- Water Shield
		{
			{ id = 546, rank = 1, level = 28, off = true },
		}, -- Water Walking
	},
	WARLOCK = {
		{
			{ id = 980, rank = 1, level = 8 },
			{ id = 1014, rank = 2, level = 18 },
			{ id = 6217, rank = 3, level = 28 },
			{ id = 11711, rank = 4, level = 38 },
			{ id = 11712, rank = 5, level = 48 },
			{ id = 11713, rank = 6, level = 58 },
		}, -- Bane of Agony
		{
			{ id = 17962, rank = 3, level = 40 },
			{ id = 18930, rank = 4, level = 48 },
			{ id = 18931, rank = 5, level = 54 },
			{ id = 18932, rank = 6, level = 60 },
		}, -- Conflagrate
		{
			{ id = 172, rank = 1, level = 4 },
			{ id = 6222, rank = 2, level = 14 },
			{ id = 6223, rank = 3, level = 24 },
			{ id = 7648, rank = 4, level = 34 },
			{ id = 11671, rank = 5, level = 44 },
			{ id = 11672, rank = 6, level = 54 },
		}, -- Corruption
		{
			{ id = 704, rank = 1, level = 14 },
			{ id = 7658, rank = 2, level = 28 },
			{ id = 7659, rank = 3, level = 42 },
			{ id = 11717, rank = 4, level = 56 },
		}, -- Curse of Recklessness
		{
			{ id = 1714, rank = 1, level = 26 },
			{ id = 11719, rank = 2, level = 50 },
		}, -- Curse of Tongues
		{
			{ id = 702, rank = 1, level = 4 },
			{ id = 1108, rank = 2, level = 12 },
			{ id = 6205, rank = 3, level = 22 },
			{ id = 7646, rank = 4, level = 32 },
			{ id = 11707, rank = 5, level = 42 },
			{ id = 11708, rank = 6, level = 52 },
		}, -- Curse of Weakness
		{
			{ id = 6789, rank = 1, level = 42 },
			{ id = 17925, rank = 2, level = 50 },
			{ id = 17926, rank = 3, level = 58 },
		}, -- Death Coil
		{
			{ id = 706, rank = 1, level = 20 },
			{ id = 1086, rank = 2, level = 30 },
			{ id = 11733, rank = 3, level = 40 },
			{ id = 11734, rank = 4, level = 50 },
			{ id = 11735, rank = 5, level = 60 },
		}, -- Demon Armor
		{
			{ id = 687, rank = 1, level = 1 },
			{ id = 696, rank = 2, level = 10 },
		}, -- Demon Skin
		{
			{ id = 5138, rank = 1, level = 24 },
			{ id = 6226, rank = 2, level = 34 },
			{ id = 11703, rank = 3, level = 44 },
			{ id = 11704, rank = 4, level = 54 },
		}, -- Drain Mana
		{
			{ id = 1120, rank = 1, level = 10, off = true },
			{ id = 8288, rank = 2, level = 24 },
			{ id = 8289, rank = 3, level = 38 },
			{ id = 11675, rank = 4, level = 52 },
		}, -- Drain Soul
		{
			{ id = 5782, rank = 1, level = 8 },
			{ id = 6213, rank = 2, level = 32 },
			{ id = 6215, rank = 3, level = 56 },
		}, -- Fear
		{
			{ id = 755, rank = 1, level = 12 },
			{ id = 3698, rank = 2, level = 20 },
			{ id = 3699, rank = 3, level = 28 },
			{ id = 3700, rank = 4, level = 36 },
			{ id = 11693, rank = 5, level = 44 },
			{ id = 11694, rank = 6, level = 52 },
			{ id = 11695, rank = 7, level = 60 },
		}, -- Health Funnel
		{
			{ id = 1949, rank = 1, level = 30, off = true },
			{ id = 11683, rank = 2, level = 42 },
			{ id = 11684, rank = 3, level = 54 },
		}, -- Hellfire
		{
			{ id = 5484, rank = 1, level = 40 },
			{ id = 17928, rank = 2, level = 54 },
		}, -- Howl of Terror
		{
			{ id = 348, rank = 1, level = 1 },
			{ id = 707, rank = 2, level = 10 },
			{ id = 1094, rank = 3, level = 20 },
			{ id = 2941, rank = 4, level = 30 },
			{ id = 11665, rank = 5, level = 40 },
			{ id = 11667, rank = 6, level = 50 },
			{ id = 11668, rank = 7, level = 60 },
		}, -- Immolate
		{
			{ id = 5740, rank = 1, level = 20, off = true },
			{ id = 6219, rank = 2, level = 34 },
			{ id = 11677, rank = 3, level = 46 },
			{ id = 11678, rank = 4, level = 58 },
		}, -- Rain of Fire
		{
			{ id = 5676, rank = 1, level = 18 },
			{ id = 17919, rank = 2, level = 26 },
			{ id = 17920, rank = 3, level = 34 },
			{ id = 17921, rank = 4, level = 42 },
			{ id = 17922, rank = 5, level = 50 },
			{ id = 17923, rank = 6, level = 58 },
		}, -- Searing Pain
		{
			{ id = 686, rank = 1, level = 1 },
			{ id = 695, rank = 2, level = 6 },
			{ id = 705, rank = 3, level = 12 },
			{ id = 1088, rank = 4, level = 20 },
			{ id = 1106, rank = 5, level = 28 },
			{ id = 7641, rank = 6, level = 36 },
			{ id = 11659, rank = 7, level = 44 },
			{ id = 11660, rank = 8, level = 52 },
			{ id = 11661, rank = 9, level = 60 },
		}, -- Shadow Bolt
		{
			{ id = 6229, rank = 1, level = 32 },
			{ id = 11739, rank = 2, level = 42 },
			{ id = 11740, rank = 3, level = 52 },
			{ id = 28610, rank = 4, level = 60 },
		}, -- Shadow Ward
		{
			{ id = 17877, rank = 1, level = 24 },
			{ id = 18867, rank = 2, level = 24 },
			{ id = 18868, rank = 3, level = 32 },
			{ id = 18869, rank = 4, level = 40 },
			{ id = 18870, rank = 5, level = 48 },
			{ id = 18871, rank = 6, level = 56 },
		}, -- Shadowburn
		{
			{ id = 18265, rank = 1, level = 38 },
			{ id = 18879, rank = 2, level = 38 },
			{ id = 18880, rank = 3, level = 48 },
			{ id = 18881, rank = 4, level = 58 },
		}, -- Siphon Life
		{
			{ id = 6353, rank = 1, level = 48 },
			{ id = 17924, rank = 2, level = 56 },
		}, -- Soul Fire
		{
			{ id = 1098, rank = 1, level = 30 },
			{ id = 11725, rank = 2, level = 44 },
			{ id = 11726, rank = 3, level = 58 },
		}, -- Subjugate Demon
		{
			{ id = 18288, rank = 1, off = true },
		}, -- Amplify Curse
		{
			{ id = 603, rank = 1, level = 60, off = true },
		}, -- Bane of Doom
		{
			{ id = 1225228, rank = 1, off = true },
		}, -- Bane of Havoc
		{
			{ id = 710, rank = 1, level = 28, off = true },
			{ id = 18647, rank = 2, level = 48, off = true },
		}, -- Banish
		{
			{ id = 6366, rank = 1, level = 28, off = true },
			{ id = 17951, rank = 2, level = 36, off = true },
			{ id = 17952, rank = 3, level = 46, off = true },
			{ id = 17953, rank = 4, level = 56, off = true },
		}, -- Create Firestone
		{
			{ id = 6201, rank = 1, level = 10, off = true },
			{ id = 6202, rank = 2, level = 22, off = true },
			{ id = 5699, rank = 3, level = 34, off = true },
			{ id = 11729, rank = 4, level = 46, off = true },
			{ id = 11730, rank = 5, level = 58, off = true },
		}, -- Create Healthstone
		{
			{ id = 693, rank = 1, level = 18, off = true },
			{ id = 20752, rank = 2, level = 30, off = true },
			{ id = 20755, rank = 3, level = 40, off = true },
			{ id = 20756, rank = 4, level = 50, off = true },
			{ id = 20757, rank = 5, level = 60, off = true },
		}, -- Create Soulstone
		{
			{ id = 2362, rank = 1, level = 36, off = true },
			{ id = 17727, rank = 2, level = 48, off = true },
			{ id = 17728, rank = 3, level = 60, off = true },
		}, -- Create Spellstone
		{
			{ id = 18223, rank = 1, off = true },
		}, -- Curse of Exhaustion
		{
			{ id = 1010, rank = 1, off = true },
		}, -- Curse of Idiocy
		{
			{ id = 440892, rank = 1, level = 20, off = true },
			{ id = 1311676, rank = 2, level = 30, off = true },
			{ id = 1311677, rank = 3, level = 40, off = true },
			{ id = 1311680, rank = 4, level = 50, off = true },
		}, -- Curse of the Elements
		{
			{ id = 18788, rank = 1, off = true },
		}, -- Demonic Sacrifice
		{
			{ id = 132, rank = 1, level = 26, off = true },
			{ id = 2970, rank = 2, level = 38, off = true },
			{ id = 11743, rank = 3, level = 50, off = true },
		}, -- Detect Invisibility
		{
			{ id = 689, rank = 1, level = 14, off = true },
			{ id = 699, rank = 2, level = 22, off = true },
			{ id = 709, rank = 3, level = 30, off = true },
			{ id = 7651, rank = 4, level = 38, off = true },
			{ id = 11699, rank = 5, level = 46, off = true },
			{ id = 11700, rank = 6, level = 54, off = true },
		}, -- Drain Life
		{
			{ id = 126, rank = 1, level = 22, off = true },
		}, -- Eye of Kilrogg
		{
			{ id = 18708, rank = 1, off = true },
		}, -- Fel Domination
		{
			{ id = 412758, rank = 1, level = 50, off = true },
			{ id = 1293812, rank = 2, level = 50, off = true },
			{ id = 1293813, rank = 3, level = 60, off = true },
		}, -- Incinerate
		{
			{ id = 1122, rank = 1, level = 50, off = true },
		}, -- Inferno
		{
			{ id = 1454, rank = 1, level = 6, off = true },
			{ id = 1455, rank = 2, level = 16, off = true },
			{ id = 1456, rank = 3, level = 26, off = true },
			{ id = 11687, rank = 4, level = 36, off = true },
			{ id = 11688, rank = 5, level = 46, off = true },
			{ id = 11689, rank = 6, level = 56, off = true },
		}, -- Life Tap
		{
			{ id = 18540, rank = 1, level = 60, off = true },
		}, -- Ritual of Doom
		{
			{ id = 698, rank = 1, level = 20, off = true },
		}, -- Ritual of Summoning
		{
			{ id = 5500, rank = 1, level = 24, off = true },
		}, -- Sense Demons
		{
			{ id = 19028, rank = 1, off = true },
		}, -- Soul Link
		{
			{ id = 691, rank = 1, level = 30, off = true },
		}, -- Summon Felhunter
		{
			{ id = 688, rank = 1, off = true },
		}, -- Summon Imp
		{
			{ id = 713, rank = 1, level = 20, off = true },
		}, -- Summon Incubus
		{
			{ id = 712, rank = 1, level = 20, off = true },
		}, -- Summon Succubus
		{
			{ id = 697, rank = 1, level = 10, off = true },
		}, -- Summon Voidwalker
		{
			{ id = 5697, rank = 1, level = 16, off = true },
		}, -- Unending Breath
		{
			{ id = 1316697, rank = 1, off = true },
		}, -- Wrack
	},
	WARRIOR = {
		{
			{ id = 6673, rank = 1, level = 1 },
			{ id = 5242, rank = 2, level = 12 },
			{ id = 6192, rank = 3, level = 22 },
			{ id = 11549, rank = 4, level = 32 },
			{ id = 11550, rank = 5, level = 42 },
			{ id = 11551, rank = 6, level = 52 },
		}, -- Battle Shout
		{
			{ id = 23881, rank = 1, level = 48 },
			{ id = 23892, rank = 2, level = 48 },
			{ id = 23893, rank = 3, level = 54 },
			{ id = 23894, rank = 4, level = 60 },
		}, -- Bloodthirst
		{
			{ id = 100, rank = 1, level = 4 },
			{ id = 6178, rank = 2, level = 26 },
			{ id = 11578, rank = 3, level = 46 },
		}, -- Charge
		{
			{ id = 845, rank = 1, level = 20 },
			{ id = 7369, rank = 2, level = 30 },
			{ id = 11608, rank = 3, level = 40 },
			{ id = 11609, rank = 4, level = 50 },
			{ id = 20569, rank = 5, level = 60 },
		}, -- Cleave
		{
			{ id = 1160, rank = 1, level = 14 },
			{ id = 6190, rank = 2, level = 24 },
			{ id = 11554, rank = 3, level = 34 },
			{ id = 11555, rank = 4, level = 44 },
			{ id = 11556, rank = 5, level = 54 },
		}, -- Demoralizing Shout
		{
			{ id = 5308, rank = 1, level = 24 },
			{ id = 20658, rank = 2, level = 32 },
			{ id = 20660, rank = 3, level = 40 },
			{ id = 20661, rank = 4, level = 48 },
			{ id = 20662, rank = 5, level = 56 },
		}, -- Execute
		{
			{ id = 1715, rank = 1, level = 8 },
			{ id = 7372, rank = 2, level = 32 },
			{ id = 7373, rank = 3, level = 54 },
		}, -- Hamstring
		{
			{ id = 78, rank = 1, level = 1 },
			{ id = 284, rank = 2, level = 8 },
			{ id = 285, rank = 3, level = 16 },
			{ id = 1608, rank = 4, level = 24 },
			{ id = 11564, rank = 5, level = 32 },
			{ id = 11565, rank = 6, level = 40 },
			{ id = 11566, rank = 7, level = 48 },
			{ id = 11567, rank = 8, level = 56 },
		}, -- Heroic Strike
		{
			{ id = 20252, rank = 1, level = 30 },
			{ id = 20616, rank = 2, level = 42 },
			{ id = 20617, rank = 3, level = 52 },
		}, -- Intercept
		{
			{ id = 694, rank = 1, level = 16 },
			{ id = 7400, rank = 2, level = 26 },
			{ id = 7402, rank = 3, level = 36 },
			{ id = 20559, rank = 4, level = 46 },
			{ id = 20560, rank = 5, level = 56 },
		}, -- Mocking Blow
		{
			{ id = 12294, rank = 1, level = 48 },
			{ id = 21551, rank = 2, level = 48 },
			{ id = 21552, rank = 3, level = 54 },
			{ id = 21553, rank = 4, level = 60 },
		}, -- Mortal Strike
		{
			{ id = 7384, rank = 1, level = 12 },
			{ id = 7887, rank = 2, level = 28 },
			{ id = 11584, rank = 3, level = 44 },
			{ id = 11585, rank = 4, level = 60 },
		}, -- Overpower
		{
			{ id = 6552, rank = 1, level = 38 },
			{ id = 6554, rank = 2, level = 58 },
		}, -- Pummel
		{
			{ id = 772, rank = 1, level = 4 },
			{ id = 6546, rank = 2, level = 10 },
			{ id = 6547, rank = 3, level = 20 },
			{ id = 6548, rank = 4, level = 30 },
			{ id = 11572, rank = 5, level = 40 },
			{ id = 11573, rank = 6, level = 50 },
			{ id = 11574, rank = 7, level = 60 },
		}, -- Rend
		{
			{ id = 6572, rank = 1, level = 14 },
			{ id = 6574, rank = 2, level = 24 },
			{ id = 7379, rank = 3, level = 34 },
			{ id = 11600, rank = 4, level = 44 },
			{ id = 11601, rank = 5, level = 54 },
		}, -- Revenge
		{
			{ id = 72, rank = 1, level = 12 },
			{ id = 1671, rank = 2, level = 32 },
			{ id = 1672, rank = 3, level = 52 },
		}, -- Shield Bash
		{
			{ id = 23922, rank = 1, level = 48 },
			{ id = 23923, rank = 2, level = 48 },
			{ id = 23924, rank = 3, level = 54 },
			{ id = 23925, rank = 4, level = 60 },
		}, -- Shield Slam
		{
			{ id = 1464, rank = 2, level = 30 },
			{ id = 8820, rank = 3, level = 38 },
			{ id = 11604, rank = 4, level = 46 },
			{ id = 11605, rank = 5, level = 54 },
		}, -- Slam
		{
			{ id = 7386, rank = 1, level = 10 },
			{ id = 7405, rank = 2, level = 22 },
			{ id = 8380, rank = 3, level = 34 },
			{ id = 11596, rank = 4, level = 46 },
			{ id = 11597, rank = 5, level = 58 },
		}, -- Sunder Armor
		{
			{ id = 6343, rank = 1, level = 6 },
			{ id = 8198, rank = 2, level = 18 },
			{ id = 8204, rank = 3, level = 28 },
			{ id = 8205, rank = 4, level = 38 },
			{ id = 11580, rank = 5, level = 48 },
			{ id = 11581, rank = 6, level = 58 },
		}, -- Thunder Clap
		{
			{ id = 18499, rank = 1, level = 30, off = true },
		}, -- Berserker Rage
		{
			{ id = 2458, rank = 1, level = 30, off = true },
		}, -- Berserker Stance
		{
			{ id = 2687, rank = 1, level = 10, off = true },
		}, -- Bloodrage
		{
			{ id = 1161, rank = 1, level = 26, off = true },
		}, -- Challenging Shout
		{
			{ id = 12809, rank = 1, off = true },
		}, -- Concussion Blow
		{
			{ id = 12328, rank = 1, off = true },
		}, -- Death Wish
		{
			{ id = 71, rank = 1, level = 10, off = true },
		}, -- Defensive Stance
		{
			{ id = 676, rank = 1, level = 18, off = true },
		}, -- Disarm
		{
			{ id = 5246, rank = 1, level = 22, off = true },
		}, -- Intimidating Shout
		{
			{ id = 12323, rank = 1, off = true },
		}, -- Piercing Howl
		{
			{ id = 1719, rank = 1, level = 50, off = true },
		}, -- Recklessness
		{
			{ id = 20230, rank = 1, level = 20, off = true },
		}, -- Retaliation
		{
			{ id = 2565, rank = 1, level = 16, off = true },
		}, -- Shield Block
		{
			{ id = 871, rank = 1, level = 28, off = true },
		}, -- Shield Wall
		{
			{ id = 1310222, rank = 1, off = true },
		}, -- Spearing Strike
		{
			{ id = 12292, rank = 1, off = true },
		}, -- Sweeping Strikes
		{
			{ id = 1310185, rank = 1, level = 14, off = true },
		}, -- Tactical Mastery
		{
			{ id = 355, rank = 1, level = 10, off = true },
		}, -- Taunt
		{
			{ id = 402927, rank = 1, level = 20, off = true },
		}, -- Victory Rush
		{
			{ id = 1680, rank = 1, level = 36, off = true },
		}, -- Whirlwind
	},
}

--[[
How We Got the Data

Last Validated
	2026-11-08, WoW Forever 1.60.1.70862

Notes
	- Built by Tools/Build-Rank-Watch-Abilities.py from Rank Sentinel's AbilityData/Classic.lua (MIT, Copyright (c) 2021 Gogo1951), the abilities its "Include" column keeps: heals and other spells players lower on purpose are left out there, not here.
	- Each ability sits under the class whose Trainer-Spells-Camelot.lua row teaches it, named by that row's comment, and takes the trainer row's learn level where the two disagree.
	- rank is the spell's own rank number, so an ability whose first ranks Rank Sentinel leaves out starts above 1.
	- Features/Rank-Watch/Rank-Watch-Lookups.lua joins abilities that ns.SPELL_GROUPS lists as one group (Demon Skin, then Demon Armor) into one ladder, ordered by learn level.
	- The higher ranks of a talent whose trainer teaches them (its Trainer-Spells row carries talent) were added from this client's SkillLineAbility, Spell and SpellLevels tables on wago.tools, since Trainer-Spells leaves those ranks out and the build had only rank 1: Counterattack, Sniper Shot, Summon Hawk, Holy Shock, Light's Vigil, Seal of Command, Arcane Blast, Ice Lance, Holy Nova, Penance, Prayer of Mending, Incinerate, Primal Bite, Wild Growth, Mana Tide Totem and Riptide. Each takes its ladder's off flag and its level from SpellLevels. Holy Shield's are not added: its trainer row puts the first trainer rank at 50, where the tables put rank 2 at 40.
	- Shred (5221), Righteous Fury (25780) and Seal of Fury rank 3 (20163) follow their trainer rows' corrected levels, 20, 10 and 26, which Validate Data's SPELL_LEVEL_LEARNED also states.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.60.1.70862
	https://wago.tools/db2/Spell?build=1.60.1.70862
	https://wago.tools/db2/SpellLevels?build=1.60.1.70862
	https://wago.tools/db2/SpellMisc?build=1.60.1.70862
	https://wago.tools/db2/SpellEffect?build=1.60.1.70862
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70862

QuestieDB
	None.
]]
