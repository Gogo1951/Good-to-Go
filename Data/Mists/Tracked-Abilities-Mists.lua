local _, ns = ...
local Data = ns.Data
local L = ns.L

local SOLO, GROUP, SERVICE = Data.BUFF.SOLO, Data.BUFF.GROUP, Data.BUFF.SERVICE
local AURA, CAST, RESURRECT = Data.DETECT.AURA, Data.DETECT.CAST, Data.DETECT.RESURRECT

-- { name, labelItem, class, type, detect, opened, noDuration, received, given, triggers = { { spell, aura, item } } }, -- Name
ns.TRACKED_ABILITIES = {
	-- Death Knight --------------------------------------------------------------
	{
		class = "DEATHKNIGHT",
		type = SOLO,
		detect = CAST,
		received = 1,
		given = 1,
		triggers = { { spell = 61999 } },
	}, -- Raise Ally
	-- Druid ---------------------------------------------------------------------
	{
		class = "DRUID",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 29166 } },
	}, -- Innervate
	{
		class = "DRUID",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 102342 } },
	}, -- Ironbark
	{
		class = "DRUID",
		type = SOLO,
		detect = CAST,
		received = 1,
		given = 1,
		triggers = { { spell = 20484 } },
	}, -- Rebirth
	-- Hunter --------------------------------------------------------------------
	{
		class = "HUNTER",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 34477, aura = 35079 } },
	}, -- Misdirection
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 80353 } },
	}, -- Time Warp
	{
		class = "MAGE",
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = { { spell = 43987 } },
	}, -- Conjure Refreshment Table
	{
		name = L["GROUP_PORTALS"],
		class = "MAGE",
		type = SERVICE,
		detect = CAST,
		opened = true,
		received = 1,
		triggers = {
			{ spell = 10059 },
			{ spell = 11416 },
			{ spell = 11417 },
			{ spell = 11418 },
			{ spell = 11419 },
			{ spell = 11420 },
			{ spell = 32266 },
			{ spell = 32267 },
			{ spell = 33691 },
			{ spell = 35717 },
			{ spell = 49360 },
			{ spell = 49361 },
			{ spell = 53142 },
			{ spell = 88345 },
			{ spell = 88346 },
			{ spell = 120146 },
			{ spell = 132620 },
			{ spell = 132626 },
		},
	}, -- Portals
	-- Monk ----------------------------------------------------------------------
	{
		class = "MONK",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 116849 } },
	}, -- Life Cocoon
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 31821 } },
	}, -- Devotion Aura
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1044 } },
	}, -- Hand of Freedom
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1022 } },
	}, -- Hand of Protection
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 114039 } },
	}, -- Hand of Purity
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 6940 } },
	}, -- Hand of Sacrifice
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1038 } },
	}, -- Hand of Salvation
	{
		class = "PALADIN",
		type = SOLO,
		detect = CAST,
		received = 1,
		given = 1,
		triggers = { { spell = 633 } },
	}, -- Lay on Hands
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 6346 } },
	}, -- Fear Ward
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 47788 } },
	}, -- Guardian Spirit
	{
		class = "PRIEST",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 64901, aura = 64904 } },
	}, -- Hymn of Hope
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 33206 } },
	}, -- Pain Suppression
	-- Rogue ---------------------------------------------------------------------
	{
		class = "ROGUE",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 57934, aura = 57933 } },
	}, -- Tricks of the Trade
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 2825 } },
	}, -- Bloodlust
	{
		class = "SHAMAN",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 32182 } },
	}, -- Heroism
	{
		class = "SHAMAN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 546 } },
	}, -- Water Walking
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 20707 } },
	}, -- Soulstone
	{
		class = "WARLOCK",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 5697 } },
	}, -- Unending Breath
	{
		class = "WARLOCK",
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = { { spell = 29893 } },
	}, -- Create Soulwell
	{
		class = "WARLOCK",
		type = SERVICE,
		detect = CAST,
		opened = true,
		received = 1,
		triggers = { { spell = 698 } },
	}, -- Ritual of Summoning
	-- Warrior -------------------------------------------------------------------
	{
		class = "WARRIOR",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 3411, aura = 147833 } },
	}, -- Intervene
	{
		class = "WARRIOR",
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 97462, aura = 97463 } },
	}, -- Rallying Cry
	{
		class = "WARRIOR",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 114029 } },
	}, -- Safeguard
	{
		class = "WARRIOR",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 114030 } },
	}, -- Vigilance
	-- Drums (item) --------------------------------------------------------------
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 29529, spell = 35476 } },
	}, -- Drums of Battle
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 102351, spell = 146555 } },
	}, -- Drums of Rage
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 29531, spell = 35478 } },
	}, -- Drums of Restoration
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 29530, spell = 35477 } },
	}, -- Drums of Speed
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 29528, spell = 35475 } },
	}, -- Drums of War
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 185848, spell = 351355 } },
	}, -- Greater Drums of Battle
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 185850, spell = 351358 } },
	}, -- Greater Drums of Restoration
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 185851, spell = 351359 } },
	}, -- Greater Drums of Speed
	{
		type = GROUP,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { item = 185852, spell = 351360 } },
	}, -- Greater Drums of War
	-- Feasts (item) -------------------------------------------------------------
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87226, spell = 126492 } } }, -- Banquet of the Grill
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87230, spell = 126495 } } }, -- Banquet of the Wok
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87234, spell = 126497 } } }, -- Banquet of the Pot
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87238, spell = 126499 } } }, -- Banquet of the Steamer
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87242, spell = 126501 } } }, -- Banquet of the Oven
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87246, spell = 126503 } } }, -- Banquet of the Brew
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 62289, spell = 87643 } } }, -- Broiled Dragon Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 43015, spell = 57426 } } }, -- Fish Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 33052, spell = 33258 } } }, -- Fisherman's Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 43478, spell = 58465 } } }, -- Gigantic Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87228, spell = 126494 } } }, -- Great Banquet of the Grill
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87232, spell = 126496 } } }, -- Great Banquet of the Wok
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87236, spell = 126498 } } }, -- Great Banquet of the Pot
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87240, spell = 126500 } } }, -- Great Banquet of the Steamer
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87244, spell = 126502 } } }, -- Great Banquet of the Oven
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 87248, spell = 126504 } } }, -- Great Banquet of the Brew
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 34753, spell = 57301 } } }, -- Great Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 75016, spell = 105193 } } }, -- Great Pandaren Banquet
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 74919, spell = 104958 } } }, -- Pandaren Banquet
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 62290, spell = 87644 } } }, -- Seafood Magnifique Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 43480, spell = 58474 } } }, -- Small Feast
	-- Cauldrons (item) ----------------------------------------------------------
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 62288, spell = 92649 } } }, -- Cauldron of Battle
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 65460, spell = 92712 } } }, -- Big Cauldron of Battle
	{
		name = L["GROUP_RESISTANCE_CAULDRONS"],
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = {
			{ item = 32839, spell = 41443 },
			{ item = 32849, spell = 41494 },
			{ item = 32850, spell = 41495 },
			{ item = 32851, spell = 41497 },
			{ item = 32852, spell = 41498 },
		},
	}, -- Resistance Cauldrons
	-- Stat Scrolls (item) -------------------------------------------------------
	{
		labelItem = 1181,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 1181, spell = 8112 },
			{ item = 1712, spell = 8113 },
			{ item = 4424, spell = 8114 },
			{ item = 10306, spell = 12177 },
			{ item = 27501, spell = 33080 },
			{ item = 33460, spell = 43197 },
			{ item = 37097, spell = 48103 },
			{ item = 37098, spell = 48104 },
			{ item = 63307, spell = 89342 },
		},
	}, -- Scroll of Spirit
	{
		labelItem = 1180,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 1180, spell = 8099 },
			{ item = 1711, spell = 8100 },
			{ item = 4422, spell = 8101 },
			{ item = 10307, spell = 12178 },
			{ item = 27502, spell = 33081 },
			{ item = 33461, spell = 43198 },
			{ item = 37093, spell = 48101 },
			{ item = 37094, spell = 48102 },
			{ item = 63306, spell = 89345 },
		},
	}, -- Scroll of Stamina
	{
		labelItem = 954,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 954, spell = 8118 },
			{ item = 2289, spell = 8119 },
			{ item = 4426, spell = 8120 },
			{ item = 10310, spell = 12179 },
			{ item = 27503, spell = 33082 },
			{ item = 33462, spell = 43199 },
			{ item = 43465, spell = 58448 },
			{ item = 43466, spell = 58449 },
			{ item = 63304, spell = 89346 },
		},
	}, -- Scroll of Strength
	{
		labelItem = 3013,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 3013, spell = 8091 },
			{ item = 1478, spell = 8094 },
			{ item = 4421, spell = 8095 },
			{ item = 10305, spell = 12175 },
			{ item = 27500, spell = 33079 },
			{ item = 33459, spell = 43196 },
			{ item = 43467, spell = 58452 },
			{ item = 43468, spell = 58453 },
			{ item = 63308, spell = 89344 },
		},
	}, -- Scroll of Protection
	{
		labelItem = 955,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 955, spell = 8096 },
			{ item = 2290, spell = 8097 },
			{ item = 4419, spell = 8098 },
			{ item = 10308, spell = 12176 },
			{ item = 27499, spell = 33078 },
			{ item = 33458, spell = 43195 },
			{ item = 37091, spell = 48099 },
			{ item = 37092, spell = 48100 },
			{ item = 63305, spell = 89347 },
		},
	}, -- Scroll of Intellect
	{
		labelItem = 3012,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 3012, spell = 8115 },
			{ item = 1477, spell = 8116 },
			{ item = 4425, spell = 8117 },
			{ item = 10309, spell = 12174 },
			{ item = 27498, spell = 33077 },
			{ item = 33457, spell = 43194 },
			{ item = 43463, spell = 58450 },
			{ item = 43464, spell = 58451 },
			{ item = 63303, spell = 89343 },
		},
	}, -- Scroll of Agility
	-- Repair & Utility (item) ---------------------------------------------------
	{
		name = L["GROUP_REPAIR_BOTS"],
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = { { item = 34113, spell = 44389 }, { item = 18232, spell = 22700 }, { item = 49040, spell = 67826 } },
	}, -- Repair Bots
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 10725, spell = 23133 } } }, -- Gnomish Battle Chicken
	{
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 23060 } },
	}, -- Battle Squawk
	{
		labelItem = 7148,
		type = SOLO,
		detect = RESURRECT,
		received = 1,
		given = 1,
		triggers = {
			{ item = 7148, spell = 8342 },
			{ item = 18587, spell = 22999 },
		},
	}, -- Goblin Jumper Cables
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Built offline from this client's game tables, not yet checked against a Validate Data run from a Mists client. Every spell is in this build's SpellName and every item in its ItemSparse, under the name its comment gives; each item's spell is the one its ItemEffect row casts.
	- The buffs, cooldowns and services other players spend on you, behind the Buffs from Teammates, Group Services and Good News panels. Buffs from Strangers has no list: any helpful buff from a player outside your group counts.
	- Hand-picked, not queried. One entry is one checkbox. The name after each entry is for people; the panels take names, icons and tooltips from the game. StyLua spreads long entries over several lines, so find one by the name on its closing brace.
	- name is a locale string (L["GROUP_*"]) for a group whose members have different names (Portals, Repair Bots, Resistance Cauldrons). Without it the toggle shows the first trigger's name in the player's language.
	- labelItem is an item whose game name labels a group named after one of its own items (the stat scrolls, Jumper Cables), so the label is the game's own in every locale. It takes the place of name.
	- class is the class heading on the Buffs from Teammates panel. Without one the row sits in the generic Items or Group Services list.
	- type is SOLO (cast on you), GROUP (cast on your whole party: Bloodlust, Heroism, Time Warp, Devotion Aura, Rallying Cry, Hymn of Hope, the drums) or SERVICE (set out for the group), from Data.BUFF in Data/Data.lua.
	- detect is AURA, CAST or RESURRECT, from Data.DETECT in Data/Data.lua, as on TBC. This client has a combat log, so every row is receivable.
	- opened makes a service announce as "opened" (portals, summons) instead of "set out" (feasts, soulwells, repair bots).
	- noDuration marks a buff spent by an event rather than by time: Fear Ward, Misdirection, Tricks of the Trade, Intervene, Safeguard.
	- received and given are the defaults for the thank-you and Good News lists: 1 starts the checkbox on, 0 off. Services leave given out.
	- triggers names an aura where the recipient carries a different ID from the cast, from SpellEffect: Misdirection's 35079, as on TBC; Tricks of the Trade's 57933 (the damage buff the recipient gets; 59628 is the rogue's own); Intervene's 147833, the intercept aura its dummy cast puts on the ally; Rallying Cry's 97463 and Hymn of Hope's 64904, put on the group by a dummy cast or a channel. Intervene, Rallying Cry and Hymn of Hope go through a script or a channel, so which aura lands is read from the tables, not seen in game.
	- Changed from TBC: one spell per ability, no ranks. Soulstone is a spell cast on you (20707), not a stone item. Ritual of Refreshment is Conjure Refreshment Table (43987) and Ritual of Souls is Create Soulwell (29893). Blessings of Freedom, Protection and Sacrifice are Hands, and Hand of Salvation and Hand of Purity (a talent) join them. The Portals add Dalaran, Ancient Dalaran, Tol Barad and the Vale of Eternal Blossoms (each faction's), every Portal on the mage skill line (SkillLineAbility); Portal: Karazhan is on no skill line here, so stays out.
	- Added: Raise Ally, Ironbark (Restoration), Time Warp, Life Cocoon (Mistweaver), Devotion Aura (now a raid cooldown), Guardian Spirit (Holy), Hymn of Hope, Tricks of the Trade, Rallying Cry, Safeguard and Vigilance (talents), Drums of Rage, the Northrend, Cataclysm and Pandaria feasts, and the Cauldron and Big Cauldron of Battle. Jeeves joins the Repair Bots.
	- Left out: Power Infusion, self-only on this client (its aura's target is the caster in SpellEffect); Amplify Magic, Dampen Magic and Divine Intervention, gone; Leap of Faith, which pulls rather than helps; totems, as on TBC; hunter pet abilities; Drums of Forgotten Kings, whose item spell is a script (SCRIPT_EFFECT) naming no aura to watch, Drums of the Wild, whose aura targets only the caster's area, and Drums of the Burning Wild, which no profession makes here; Jillian's Gourmet Fish Feast and Bountiful Feast, which no profession makes here; the Domination Point and Lion's Landing Banquets; Gorzeeki's Jumper Cables.
	- Every item kept is made by a profession on this client (a recipe spell on a profession skill line in SkillLineAbility creates it), except the Scrolls of Protection I to VIII, which no profession makes and which are kept as on TBC; whether they still drop here isn't checked.
	- Jumper Cables takes its label from item 7148's client name (labelItem), because both cables cast a spell named Defibrillate; only the item names differ.
	- Battle Squawk and Gnomish Battle Chicken are two rows because they're two events for two audiences, as on TBC.
	- The file is self-contained: tune a default by changing a digit here, without touching any other file.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellCooldowns?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/SkillLine?build=5.5.4.70631
	https://wago.tools/db2/SpecializationSpells?build=5.5.4.70631
	https://wago.tools/db2/Talent?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631

QuestieDB
	None.
]]
