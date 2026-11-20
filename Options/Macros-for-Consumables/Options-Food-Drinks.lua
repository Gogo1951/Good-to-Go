local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local SpellDescription = ns.OptionsSpellDescription

--------------------------------------------------------------------------------
-- Active-State Predicates
--------------------------------------------------------------------------------

--[[
    Every setting here lives on the AceDB profile, which is the character's own
    unless the player put it on another, and reads the settings table that
    InitializeDatabase in Features/Core.lua guarantees.
]]

local GetSettings = ns.OptionsProfileSettings

local function ConjuredFirstActive()
	local settings = GetSettings()
	return settings and settings.useConjuredFirst
end

-- Cannibalize restores health only on Classic Era and TBC Anniversary, so drinking is offered where it restores mana.
local function NoCannibalizeDrinking()
	return not ns.CANNIBALIZE_RESTORES_MANA
end

-- Rapid Regeneration exists only on WoW Forever, so the Troll section shows only there.
local function NoRapidRegeneration()
	return not ns.RAPID_REGENERATION_SPELL_ID
end

--------------------------------------------------------------------------------
-- Food & Drinks Panel
--------------------------------------------------------------------------------

--[[
    Everything that decides what the Food and Water macros eat and drink, on a
    page of its own under Consumable Macros:

      Which Food Comes First -- conjured food and water first, Restock List
        food and water last, and buff food with the rest or kept for last.
      Stealth and racial eating -- Rogue and Night Elf Stealth Eating,
        Night Elf Stealth Drinking, Forsaken Cannibalize, Troll Rapid
        Regeneration (in the Food and Bandage macros), each under its
        class's or race's header.

    Buff food for the buff and scrolls are Buff Duty's (its Self-Buffs page);
    the Food macro only eats. Every section shows on every character; the
    only gates are flavor ones. Opens with the off line while Consumable
    Macros is off; the settings stay editable so they can be set up first.
    Order values are spaced blocks so a row can be added without renumbering
    its neighbors. Registered as this builder function, so AceConfig rebuilds
    it on every open and NotifyChange.
]]
function ns.BuildFoodDrinksOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_FOOD_DRINKS_DESCRIPTION"], 1),

		-- Which Food Comes First
		spaceOrder0 = Spacer(10),
		headerOrder = Header(L["OPTIONS_FOOD_ORDER_HEADER"], 11),
		spaceOrder1 = Spacer(12),
		descOrder = Desc(GetColor("BODY") .. L["OPTIONS_FOOD_ORDER_DESCRIPTION"] .. "|r", 13),
		spaceOrder2 = Spacer(14),
		toggleConjuredFirst = Kit.ToggleRow(20, {
			type = "toggle",
			name = L["OPTIONS_CONJURED_FIRST"],
			desc = L["OPTIONS_CONJURED_FIRST_DESCRIPTION"],
			get = function()
				return ConjuredFirstActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useConjuredFirst", value)
			end,
		}),
		-- Its level filter on a row of its own under the switch, then the group checkboxes under that.
		modeConjuredFirst = MacroOptions.ModeSubRow(
			"conjuredFirst",
			L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"],
			ConjuredFirstActive,
			20.5
		),
		spaceConjuredFirst = Spacer(22),
		toggleRestockLast = MacroOptions.Toggle(
			"useRestockLast",
			L["OPTIONS_RESTOCK_LAST"],
			L["OPTIONS_RESTOCK_LAST_DESCRIPTION"],
			23
		),
		spaceRestockLast = Spacer(24),
		toggleBuffFoodWhenFed = MacroOptions.Toggle(
			"useBuffFoodWhenFed",
			L["OPTIONS_BUFF_FOOD_WHEN_FED"],
			SpellDescription("OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			25
		),

		--[[
		    Rogues: Stealth Eating. Its Night Elf twin below writes the same
		    setting, read as Stealth or Shadowmeld. Eating or drinking after
		    you stealth breaks it, so Stealth Eating and Shadowmeld Drinking
		    are a pair only one of which can be on: checking either unchecks
		    the other, here and below.
		]]
		spaceRogue0 = Spacer(30),
		headerRogue = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE), 31),
		spaceRogue1 = Spacer(32),
		descRogue = Desc(GetColor("BODY") .. L["OPTIONS_FOOD_DRINKS_ROGUE_SUMMARY"] .. "|r", 32.3),
		spaceRogue2 = Spacer(32.6),
		toggleStealthEatingRogue = MacroOptions.Toggle(
			"enableStealthEating",
			L["OPTIONS_STEALTH_EATING"],
			SpellDescription("OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION", ns.STEALTH_SPELL_ID),
			33,
			nil,
			"enableShadowmeldDrinking"
		),

		--[[
		    Forsaken -- Cannibalize in the Food macro, and in the Water macro
		    where it restores mana. Headed with the client's name for the race,
		    which is Undead.
		]]
		spaceForsaken0 = Spacer(40),
		headerForsaken = Header(
			L["OPTIONS_RACE_HEADER_FORMAT"]:format(C_CreatureInfo.GetRaceInfo(ns.UNDEAD_RACE_ID).raceName),
			41
		),
		spaceForsaken1 = Spacer(42),
		descCannibalize = Desc(function()
			return GetColor("BODY")
				.. SpellDescription("OPTIONS_CANNIBALIZE_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID)()
				.. "|r"
		end, 43),
		spaceForsaken2 = Spacer(44),
		toggleCannibalizeEating = MacroOptions.Toggle(
			"enableCannibalizeEating",
			SpellDescription("OPTIONS_CANNIBALIZE_EATING", ns.CANNIBALIZE_SPELL_ID),
			SpellDescription("OPTIONS_CANNIBALIZE_EATING_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID),
			45
		),
		spaceCannibalize = Spacer(45.5, NoCannibalizeDrinking),
		toggleCannibalizeDrinking = MacroOptions.Toggle(
			"enableCannibalizeDrinking",
			SpellDescription("OPTIONS_CANNIBALIZE_DRINKING", ns.CANNIBALIZE_SPELL_ID),
			SpellDescription("OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID),
			46,
			NoCannibalizeDrinking
		),

		-- Night Elves: the section and its pick-one summary are added below, at 50.
		toggleShadowmeldDrinking = MacroOptions.Toggle(
			"enableShadowmeldDrinking",
			L["OPTIONS_STEALTH_DRINKING"],
			SpellDescription("OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION", ns.SHADOWMELD_SPELL_ID),
			55,
			nil,
			"enableStealthEating"
		),
		spaceStealthNightElf = Spacer(55.5),
		toggleStealthEatingNightElf = MacroOptions.Toggle(
			"enableStealthEating",
			L["OPTIONS_STEALTH_EATING"],
			SpellDescription("OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION", ns.SHADOWMELD_SPELL_ID),
			56,
			nil,
			"enableShadowmeldDrinking"
		),

		-- Trolls -- Rapid Regeneration in the Food and Bandage macros, on WoW Forever only.
		spaceTroll0 = Spacer(60, NoRapidRegeneration),
		headerTroll = Header(
			L["OPTIONS_RACE_HEADER_FORMAT"]:format(C_CreatureInfo.GetRaceInfo(ns.TROLL_RACE_ID).raceName),
			61,
			NoRapidRegeneration
		),
		spaceTroll1 = Spacer(62, NoRapidRegeneration),
		descRapidRegeneration = Desc(function()
			return GetColor("BODY")
				.. SpellDescription("OPTIONS_RAPID_REGENERATION_DESCRIPTION", ns.RAPID_REGENERATION_SPELL_ID)()
				.. "|r"
		end, 63, NoRapidRegeneration),
		spaceTroll2 = Spacer(64, NoRapidRegeneration),
		toggleRapidRegenerationEating = MacroOptions.Toggle(
			"enableRapidRegenerationEating",
			SpellDescription("OPTIONS_RAPID_REGENERATION_EATING", ns.RAPID_REGENERATION_SPELL_ID),
			SpellDescription("OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION", ns.RAPID_REGENERATION_SPELL_ID),
			65,
			NoRapidRegeneration
		),
		spaceRapidRegeneration = Spacer(65.5, NoRapidRegeneration),
		toggleRapidRegenerationBandage = MacroOptions.Toggle(
			"enableRapidRegenerationBandage",
			SpellDescription("OPTIONS_RAPID_REGENERATION_BANDAGE", ns.RAPID_REGENERATION_SPELL_ID),
			SpellDescription("OPTIONS_RAPID_REGENERATION_BANDAGE_DESCRIPTION", ns.RAPID_REGENERATION_SPELL_ID),
			66,
			NoRapidRegeneration
		),
	}

	Kit.Section(
		args,
		"nightElf",
		50,
		L["OPTIONS_RACE_HEADER_FORMAT"]:format(C_CreatureInfo.GetRaceInfo(ns.NIGHT_ELF_RACE_ID).raceName),
		L["OPTIONS_STEALTH_PICK_ONE"]
	)

	-- Conjured first's group context checkboxes, under its level filter.
	MacroOptions.UseWhenGroups(args, "conjuredFirst", ConjuredFirstActive, 21)

	return MacroOptions.Page(L["OPTIONS_FOOD_WATER_HEADER"], args)
end
