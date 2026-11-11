local _, ns = ...
local Data = ns.Data

local ALL, TANK, OFF = Data.BUFF_AUDIENCE.ALL, Data.BUFF_AUDIENCE.TANK, Data.BUFF_AUDIENCE.OFF
local BLESSING = "BLESSING"
local ASPECT, MAGE_ARMOR = "ASPECT", "MAGE_ARMOR"
local SHAMAN_SHIELD = "SHAMAN_SHIELD"
local MISSING = Data.SELF_REFRESH_MISSING
local MAIN, OFF_HAND = "MAIN", "OFF"

-- { class, single = { { spell id, level learned } }, group = { spell ids }, greater = { spell ids }, exclusive, manaOnly, noCasters, talent, default }, -- Name
ns.BUFF_DUTY_SPELLS = {
	-- Druid ---------------------------------------------------------------------
	{
		class = "DRUID",
		single = { { 1126, 62 } },
		group = { 1126 },
		greater = { 20217, 117666, 117667, 90363 },
		default = ALL,
	}, -- Mark of the Wild
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		single = { { 1459, 58 }, { 61316, 80 } },
		group = { 1459, 61316 },
		default = ALL,
	}, -- Arcane Brilliance, Dalaran Brilliance
	-- Monk ----------------------------------------------------------------------
	{
		class = "MONK",
		single = { { 115921, 22 } },
		group = { 115921 },
		greater = { 117666, 117667, 1126, 20217, 90363 },
		default = ALL,
	}, -- Legacy of the Emperor
	{
		class = "MONK",
		single = { { 116781, 81 } },
		group = { 116781 },
		greater = { 24932, 1459, 61316, 126309, 24604, 90309, 126373 },
		talent = true,
		default = ALL,
	}, -- Legacy of the White Tiger
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		single = { { 20217, 30 } },
		greater = { 1126, 117666, 117667, 90363 },
		exclusive = BLESSING,
		default = ALL,
	}, -- Blessing of Kings
	{
		class = "PALADIN",
		single = { { 19740, 81 } },
		greater = { 116956, 93435 },
		exclusive = BLESSING,
		default = ALL,
	}, -- Blessing of Might
	{
		class = "PALADIN",
		single = { { 53563, 39 } },
		default = OFF,
	}, -- Beacon of Light
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		single = { { 21562, 22 } },
		group = { 21562 },
		greater = { 469, 109773, 90364 },
		default = ALL,
	}, -- Power Word: Fortitude
	{
		class = "PRIEST",
		single = { { 6346, 54 } },
		default = TANK,
	}, -- Fear Ward
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		single = { { 974, 26 } },
		default = OFF,
	}, -- Earth Shield
	{
		class = "SHAMAN",
		single = { { 546, 24 } },
		default = OFF,
	}, -- Water Walking
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		single = { { 109773, 82 } },
		group = { 109773 },
		default = ALL,
	}, -- Dark Intent
	{
		class = "WARLOCK",
		single = { { 5697, 24 } },
		default = OFF,
	}, -- Unending Breath
}

-- { beast = spell id, demons = { [npc id] = spell id } }: the icon a pet's row wears, from its summoning spell
ns.BUFF_DUTY_PET_ICONS = {
	beast = 883, -- Call Pet 1
	demons = {
		[416] = 688, -- Imp: Summon Imp
		[1860] = 697, -- Voidwalker: Summon Voidwalker
		[1863] = 712, -- Succubus: Summon Succubus
		[185317] = 713, -- Incubus: Summon Incubus
		[417] = 691, -- Felhunter: Summon Felhunter
		[17252] = 30146, -- Felguard: Summon Felguard
		[58959] = 112866, -- Fel Imp: Summon Fel Imp
		[58960] = 112867, -- Voidlord: Summon Voidlord
		[58963] = 112868, -- Shivarra: Summon Shivarra
		[58964] = 112869, -- Observer: Summon Observer
		[58965] = 112870, -- Wrathguard: Summon Wrathguard
	},
}

-- { class, ranks = { { spell id, level learned } }, auras, exclusive, needsPet, default (minutes left, MISSING or OFF) }, -- Name
ns.BUFF_DUTY_SELF_SPELLS = {
	-- Hunter --------------------------------------------------------------------
	{
		class = "HUNTER",
		ranks = { { 13165, 12 }, { 109260, 45 } },
		exclusive = ASPECT,
		default = MISSING,
	}, -- Aspect of the Hawk, Aspect of the Iron Hawk
	{
		class = "HUNTER",
		ranks = { { 5118, 24 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Cheetah
	{
		class = "HUNTER",
		ranks = { { 13159, 56 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Pack
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		ranks = { { 7302, 54 } },
		exclusive = MAGE_ARMOR,
		default = MISSING,
	}, -- Frost Armor
	{
		class = "MAGE",
		ranks = { { 30482, 34 } },
		exclusive = MAGE_ARMOR,
		default = MISSING,
	}, -- Molten Armor
	{
		class = "MAGE",
		ranks = { { 6117, 80 } },
		exclusive = MAGE_ARMOR,
		default = MISSING,
	}, -- Mage Armor
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		ranks = { { 105361, 3 }, { 31801, 24 } },
		default = MISSING,
	}, -- Seal of Command, Seal of Truth
	{
		class = "PALADIN",
		ranks = { { 20165, 32 } },
		default = OFF,
	}, -- Seal of Insight
	{
		class = "PALADIN",
		ranks = { { 20154, 42 } },
		default = OFF,
	}, -- Seal of Righteousness
	{
		class = "PALADIN",
		ranks = { { 20164, 70 } },
		default = OFF,
	}, -- Seal of Justice
	{
		class = "PALADIN",
		ranks = { { 25780, 12 } },
		default = OFF,
	}, -- Righteous Fury
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		ranks = { { 588, 9 } },
		default = MISSING,
	}, -- Inner Fire
	{
		class = "PRIEST",
		ranks = { { 73413, 80 } },
		default = OFF,
	}, -- Inner Will
	{
		class = "PRIEST",
		ranks = { { 15473, 24 } },
		default = MISSING,
	}, -- Shadowform
	-- Rogue ---------------------------------------------------------------------
	{
		class = "ROGUE",
		ranks = { { 2823, 10 } },
		default = 3,
	}, -- Deadly Poison
	{
		class = "ROGUE",
		ranks = { { 8679, 30 } },
		default = OFF,
	}, -- Wound Poison
	{
		class = "ROGUE",
		ranks = { { 3408, 20 } },
		default = 3,
	}, -- Crippling Poison
	{
		class = "ROGUE",
		ranks = { { 5761, 28 } },
		default = OFF,
	}, -- Mind-numbing Poison
	{
		class = "ROGUE",
		ranks = { { 108211, 45 } },
		default = OFF,
	}, -- Leeching Poison
	{
		class = "ROGUE",
		ranks = { { 108215, 75 } },
		default = OFF,
	}, -- Paralytic Poison
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		ranks = { { 324, 8 } },
		exclusive = SHAMAN_SHIELD,
		default = 3,
	}, -- Lightning Shield
	{
		class = "SHAMAN",
		ranks = { { 52127, 20 } },
		exclusive = SHAMAN_SHIELD,
		default = 3,
	}, -- Water Shield
}

-- { class, duration (minutes), ranks = { { spell id, level learned, enchant id } } or items = { { item id, level required, enchant id } } }, -- Name
ns.BUFF_DUTY_WEAPON_ENCHANTS = {
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		duration = 60,
		ranks = { { 51730, 30, 3345 } },
	}, -- Earthliving Weapon
	{
		class = "SHAMAN",
		duration = 60,
		ranks = { { 8024, 10, 5 } },
	}, -- Flametongue Weapon
	{
		class = "SHAMAN",
		duration = 60,
		ranks = { { 8033, 46, 2 } },
	}, -- Frostbrand Weapon
	{
		class = "SHAMAN",
		duration = 60,
		ranks = { { 8017, 75, 3021 } },
	}, -- Rockbiter Weapon
	{
		class = "SHAMAN",
		duration = 60,
		ranks = { { 8232, 30, 283 } },
	}, -- Windfury Weapon
}

-- The weapons each class keeps a poison or imbue on.
ns.BUFF_DUTY_WEAPON_HANDS = {
	SHAMAN = { MAIN, OFF_HAND },
}

--[[
    Every other temporary weapon enchant, for any class: oils, sharpening
    stones, weightstones, fishing lures. weapon types is the item spell's
    weapon-subclass mask (0 for any weapon but a fishing pole); kind is the
    Weapon Buffs panel group it's listed under, and item level ranks it there
    and in the window, strongest first.
]]
local OIL, STONE, LURE = "OIL", "STONE", "LURE"
local ON_QUEL_DANAS = { instances = { 585, 580 }, uiMaps = { 122 } } -- Magisters' Terrace, Sunwell Plateau; Isle of Quel'Danas

-- { item id, level required, enchant id, weapon types, kind, item level, zones }, -- Name
ns.BUFF_DUTY_WEAPON_ITEMS = {
	{ 23529, 60, 2713, 33219, STONE, 70 }, -- Adamantite Sharpening Stone
	{ 28421, 60, 2955, 9264, STONE, 70 }, -- Adamantite Weightstone
	{ 6533, 0, 266, 1048576, LURE, 30 }, -- Aquadynamic Fish Attractor
	{ 6811, 0, 264, 1048576, LURE, 20 }, -- Aquadynamic Fish Lens
	{ 34538, 70, 3265, 0, OIL, 70, ON_QUEL_DANAS }, -- Blessed Weapon Coating
	{ 23123, 50, 3592, 0, OIL, 55 }, -- Blessed Wizard Oil
	{ 31535, 0, 3102, 173555, OIL, 105 }, -- Bloodboil Poison
	{ 6532, 0, 265, 1048576, LURE, 30 }, -- Bright Baubles
	{ 20748, 45, 2629, 0, OIL, 55 }, -- Brilliant Mana Oil
	{ 20749, 45, 2628, 0, OIL, 55 }, -- Brilliant Wizard Oil
	{ 2863, 5, 13, 33219, STONE, 15 }, -- Coarse Sharpening Stone
	{ 3240, 5, 20, 9264, STONE, 15 }, -- Coarse Weightstone
	{ 23122, 50, 3593, 1097203, STONE, 55 }, -- Consecrated Sharpening Stone
	{ 12404, 35, 1643, 33219, STONE, 45 }, -- Dense Sharpening Stone
	{ 12643, 35, 1703, 9264, STONE, 45 }, -- Dense Weightstone
	{ 18262, 50, 2506, 41411, STONE, 60 }, -- Elemental Sharpening Stone
	{ 36899, 72, 3298, 0, OIL, 80 }, -- Exceptional Mana Oil
	{ 62673, 0, 266, 1048576, LURE, 80 }, -- Feathered Lure
	{ 23528, 50, 2712, 33219, STONE, 60 }, -- Fel Sharpening Stone
	{ 28420, 50, 2954, 9264, STONE, 60 }, -- Fel Weightstone
	{ 7307, 0, 265, 1048576, LURE, 30 }, -- Flesh Eating Worm
	{ 3829, 30, 26, 173555, OIL, 40 }, -- Frost Oil
	{ 67404, 0, 4264, 1048576, LURE, 1 }, -- Glass Fishing Bobber
	{ 46006, 0, 3868, 1048576, LURE, 30 }, -- Glow Worm
	{ 68049, 0, 4225, 1048576, LURE, 81 }, -- Heat-Treated Spinning Lure
	{ 2871, 15, 14, 33219, STONE, 25 }, -- Heavy Sharpening Stone
	{ 3241, 15, 21, 9264, STONE, 25 }, -- Heavy Weightstone
	{ 20747, 40, 2625, 0, OIL, 50 }, -- Lesser Mana Oil
	{ 20746, 30, 2626, 0, OIL, 40 }, -- Lesser Wizard Oil
	{ 20745, 20, 2624, 0, OIL, 30 }, -- Minor Mana Oil
	{ 20744, 5, 2623, 0, OIL, 15 }, -- Minor Wizard Oil
	{ 6530, 0, 264, 1048576, LURE, 20 }, -- Nightcrawlers
	{ 34539, 70, 3266, 0, OIL, 70, ON_QUEL_DANAS }, -- Righteous Weapon Coating
	{ 2862, 1, 40, 33219, STONE, 5 }, -- Rough Sharpening Stone
	{ 3239, 1, 19, 9264, STONE, 5 }, -- Rough Weightstone
	{ 30696, 0, 3093, 173555, OIL, 52 }, -- Scourgebane
	{ 3824, 24, 25, 173555, OIL, 34 }, -- Shadow Oil
	{ 34861, 0, 266, 1048576, LURE, 30 }, -- Sharpened Fish Hook
	{ 6529, 0, 263, 1048576, LURE, 10 }, -- Shiny Bauble
	{ 7964, 25, 483, 33219, STONE, 35 }, -- Solid Sharpening Stone
	{ 7965, 25, 484, 9264, STONE, 35 }, -- Solid Weightstone
	{ 22521, 52, 2677, 0, OIL, 62 }, -- Superior Mana Oil
	{ 22522, 58, 2678, 0, OIL, 68 }, -- Superior Wizard Oil
	{ 20750, 40, 2627, 0, OIL, 50 }, -- Wizard Oil
}

-- { class, create = { { spell id, level learned } }, auras, items (lowest rank first), default }
ns.BUFF_DUTY_SOULSTONE = {
	class = "WARLOCK",
	create = {},
	auras = {},
	items = {},
	default = 3,
}

-- { class, ranks = { spell ids } }, -- Name
ns.BUFF_DUTY_RESURRECTIONS = {
	{ class = "DRUID", ranks = { 50769 } }, -- Revive
	{ class = "MONK", ranks = { 115178 } }, -- Resuscitate
	{ class = "PALADIN", ranks = { 7328 } }, -- Redemption
	{ class = "PRIEST", ranks = { 2006 } }, -- Resurrection
	{ class = "SHAMAN", ranks = { 2008 } }, -- Ancestral Spirit
}

--[[
How We Got the Data

Last Validated
	2026-11-11, Mists of Pandaria Classic 5.5.4.70631

Notes
	- Built offline from this client's game tables, not yet checked against a Validate Data run from a Mists client. Every ID below is in this build's SpellName or ItemSparse, under the name its comment gives.
	- Every buff one player can put on another that lasts more than two minutes, as on the other flavors. This client has no ranks: each buff is one spell, and the raid buffs reach the whole party or raid when cast on any member of it ("If target is in your party or raid, all party and raid members will be affected").
	- So a raid buff's single and group are the same spell. single makes the row and its per-member icons; group makes it a raid-wide buff for the party headers and the Party-Buffs Ask Other Classes count (Features/Buff-Duty/Buff-Duty-Other-Classes.lua), as a TBC group version does. Mark of the Wild, Arcane Brilliance, Legacy of the Emperor, Legacy of the White Tiger, Power Word: Fortitude and Dark Intent carry one. The Blessings don't, being exclusive: a target holds one Blessing from each paladin, as on TBC.
	- greater, as on TBC, only counts toward "already has it" and is never cast. Here it lists the other spells that fill the same raid-buff slot and don't stack with the row's: the 5% stats of Mark of the Wild, Blessing of Kings, Legacy of the Emperor and the Shale Spider's Embrace of the Shale Spider; Power Word: Fortitude's Stamina from Commanding Shout, Dark Intent and the Silithid's Qiraji Fortitude; Blessing of Might's Mastery from Grace of Air and Roar of Courage; Legacy of the White Tiger's critical strike from Leader of the Pack, Arcane Brilliance, Dalaran Brilliance, Still Water, Furious Howl, Terrifying Roar and Fearless Roar. Each is listed by the aura ID the target carries, from SpellEffect (APPLY_AURA or APPLY_AREA_AURA_RAID with the same aura type). Arcane Brilliance and Dark Intent each fill two slots (spell power with critical strike, spell power with Stamina), so neither carries a greater list: no one other spell covers both.
	- Legacy of the Emperor's cast (115921) is a dummy: the target keeps 117666 (raid) or 117667 (single), both in its greater list, so the row counts them.
	- Arcane Brilliance and Dalaran Brilliance share a row, as ranks with different names do: the same buff, Dalaran Brilliance (61316) replacing it for an Arcane mage. 61316's skill line row has no learn method, so where it comes from is unverified; the row offers only the spells the player knows.
	- talent marks Legacy of the White Tiger, a Windwalker spell, so Party-Buffs counts it only once someone in the group carries it.
	- Each single carries its learn level from SpellLevels.BaseLevel (Specialization spells and talents too), which Validate Data's SPELL_LEVEL_LEARNED column hasn't confirmed yet on this client. Features/Buff-Duty/Buff-Duty-Castable.lua's RankFor still applies Classic's "Target is too low level" gap of 10 below that level, which this client no longer has.
	- default: the raid buffs start on ALL (Kings and Might both, the paladin picking), Fear Ward on TANK, and the situational ones OFF. Beacon of Light and Earth Shield go on one target per caster, so they start OFF, as Earth Shield does on TBC.
	- Left out of the single buffs: anything under two minutes (Hand spells, Power Infusion, Innervate, Pain Suppression, Guardian Spirit, Life Cocoon, Ironbark, Vigilance); passive auras (Trueshot Aura, Leader of the Pack, Grace of Air, Unholy Aura, Moonkin and Shadowform's haste); hunter pet buffs; Battle Shout, Commanding Shout and Horn of Winter, which have a cooldown of their own (60, 60 and 20 seconds in SpellCooldowns.CategoryRecoveryTime) and that GetSpellBaseCooldown may not report, so the Buff Key could spend them; Symbiosis, whose target buff depends on the target's class; and Soulstone, now a spell cast on a target with a 10-minute cooldown (see BUFF_DUTY_SOULSTONE). Thorns, Amplify Magic, Dampen Magic, Shadow Protection, Divine Spirit, Water Breathing, Detect Invisibility, Arcane Intellect, the other Blessings and every group version are gone from this client.
	- BUFF_DUTY_PET_ICONS: a demon wears its own summoning spell's icon, matched by creature ID, which is the SUMMON_PET effect's misc value in SpellEffect. The Grimoire of Supremacy demons (Fel Imp, Voidlord, Shivarra, Observer, Wrathguard) and the Incubus are added. The Grimoire of Service demons, the Infernal and the Doomguard are temporary and left out, as on TBC.
	- BUFF_DUTY_SELF_SPELLS: the long self buffs. Aspect of the Iron Hawk shares Hawk's row, since the talent replaces it (Talent.OverridesSpellID 13165) and lands in tier 3, level 45 (CLASS_TALENT_LEVELS in the client's FrameXML Constants.lua). Mage armors, Inner Fire, Inner Will, Shadowform, the seals and the aspects have no timer here (SpellDuration -1), so they default to MISSING or OFF; Lightning Shield, Water Shield and the poisons last an hour.
	- A rogue's poisons are self buffs on this client: each one's cast puts an hour-long aura on the rogue (APPLY_AURA, PROC_TRIGGER_SPELL), not a weapon enchant. Leeching Poison (tier 3, level 45) and Paralytic Poison (tier 5, level 75) are talents.
	- The seals, Inner Fire and Inner Will, and the lethal and non-lethal poisons each allow only one up at a time, but they carry no exclusive family: the Self-Buffs panel names a family of two or more by L["BUFF_DUTY_SELF_NOTE_<family>"], and this locale has no such entry for them yet, so a new family would raise a missing-entry error. Instead one of each starts on (Seal of Truth, Inner Fire, Deadly Poison, Crippling Poison) and the rest start OFF. Seal of Command shares Seal of Truth's row: Truth replaces it at 24 (SkillLineAbility.SupercedesSpell).
	- Left out of the self buffs: stances, presences (Death Knight) and Monk stances, as Warrior stances are on TBC; Omen of Clarity, now passive; forms, tracking and mounts; Grimoire of Sacrifice and Soul Link, which have cooldowns; Battle Shout, which now has a cooldown. Druid, Death Knight, Monk, Warlock and Warrior have no rows here.
	- BUFF_DUTY_WEAPON_ENCHANTS: the shaman imbues, one spell each, with the enchant ID from SpellEffect's ENCHANT_ITEM_TEMPORARY misc value and their 60-minute duration from each spell's description ("Lasts 60 minutes"). Rockbiter names one enchant (3021) here, where TBC's named one per weapon speed. Earthliving (Restoration) and Windfury (Enhancement) are Specialization spells.
	- BUFF_DUTY_WEAPON_HANDS: shamans only, both hands (Enhancement dual wields). Rogues have no weapon row: their poisons are self buffs.
	- BUFF_DUTY_WEAPON_ITEMS: every item this client's tables say puts a temporary enchant on a hand weapon or fishing pole (ItemEffect to a spell with ENCHANT_ITEM_TEMPORARY), with SpellEquippedItems' subclass mask, ItemSparse's required level and item level, and the same kinds as TBC. Changed from TBC: Blessed Wizard Oil's enchant (3592), Consecrated Sharpening Stone's (3593), Elemental Sharpening Stone's weapon types (41411), and Isle of Quel'Danas, UiMap 122 here. Added: Exceptional Mana Oil, Feathered Lure, Glass Fishing Bobber (a drop in QuestieDB's MoP item table), Glow Worm and Heat-Treated Spinning Lure. Left out: Weather-Beaten Fishing Hat and Nat's Hat (worn lures), Ninja Hook [PH] and Test Sharpening Stone (placeholders), armor items (Comfortable Insoles, Runes of Warding), and Corpse Worm (69907), a quest bait that only catches Corpse-Fed Pike in Brightwater Lake. Whether the older items still drop or sell on this client isn't checked: those with a crafting spell on a profession skill line are craftable here.
	- BUFF_DUTY_SOULSTONE is declared with no spells: on this client Soulstone (20707) is cast straight on a party member, with no stone item and a 10-minute cooldown, which the Soulstone reminder (Features/Buff-Duty/Buff-Duty-Self.lua) doesn't handle. Its fields are empty lists so every reader skips it.
	- BUFF_DUTY_RESURRECTIONS: one spell per class, now with Druid (Revive) and Monk (Resuscitate). Rebirth and Raise Ally stay out (combat resurrections on a cooldown), as does Mass Resurrection (83968, a 10-minute cooldown).

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/Spell?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellDuration?build=5.5.4.70631
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellCooldowns?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/SkillLine?build=5.5.4.70631
	https://wago.tools/db2/SpecializationSpells?build=5.5.4.70631
	https://wago.tools/db2/ChrSpecialization?build=5.5.4.70631
	https://wago.tools/db2/Talent?build=5.5.4.70631
	https://wago.tools/db2/SpellItemEnchantment?build=5.5.4.70631
	https://wago.tools/db2/SpellEquippedItems?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/Item?build=5.5.4.70631
	https://wago.tools/db2/Map?build=5.5.4.70631
	https://wago.tools/db2/UiMap?build=5.5.4.70631

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/MoP/mopItemDB.lua
]]
