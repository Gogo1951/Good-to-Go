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

local GetSettings = ns.OptionsProfileSettings

local function ConjuredFirstActive()
	local settings = GetSettings()
	return settings and settings.useConjuredFirst
end

local function ReapplyActive()
	local settings = GetSettings()
	return settings and settings.earlyReapply
end

-- Cannibalize restores health only on Classic Era and TBC Anniversary.
local function NoCannibalizeDrinking()
	return not ns.CANNIBALIZE_RESTORES_MANA
end

-- Rapid Regeneration exists only on WoW Forever.
local function NoRapidRegeneration()
	return not ns.RAPID_REGENERATION_SPELL_ID
end

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

local REAPPLY_SECONDS = { 60, 120, 180, 240, 300 }

local function ReapplyThresholdValues()
	local values = { [60] = L["REAPPLY_THRESHOLD_ONE"] }
	for index = 2, #REAPPLY_SECONDS do
		local seconds = REAPPLY_SECONDS[index]
		values[seconds] = string.format(L["REAPPLY_THRESHOLD_MANY"], seconds / 60)
	end
	return values
end

--------------------------------------------------------------------------------
-- Food & Drinks Panel
--------------------------------------------------------------------------------

--[[
    Every section shows on every character; only the flavor gates one. Settings
    stay editable while Consumable Macros is off, so they can be set up first.
]]
function ns.BuildFoodDrinksOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_FOOD_DRINKS_DESCRIPTION"], 1),

		spaceOrder0 = Spacer(10),
		headerOrder = Header(L["OPTIONS_FOOD_ORDER_HEADER"], 11),
		spaceOrder1 = Spacer(12),
		descOrder = Desc(GetColor("BODY") .. L["OPTIONS_FOOD_ORDER_DESCRIPTION"] .. "|r", 13),
		spaceOrder2 = Spacer(14),
		toggleConjuredFirst = Kit.ToggleRow(20, {
			type = "toggle",
			name = L["OPTIONS_CONJURED_FIRST"],
			desc = SpellDescription("OPTIONS_CONJURED_FIRST_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			get = function()
				return ConjuredFirstActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useConjuredFirst", value)
			end,
		}),
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
		spaceReapply = Spacer(26),
		toggleReapply = Kit.ToggleRow(27, {
			type = "toggle",
			name = L["OPTIONS_REAPPLY"],
			desc = SpellDescription("OPTIONS_REAPPLY_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			get = function()
				return ReapplyActive()
			end,
			set = function(_, value)
				ns.db.profile.earlyReapply = value
				MacroOptions.Changed()
			end,
		}, {
			control = {
				type = "select",
				desc = L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"],
				values = ReapplyThresholdValues(),
				sorting = REAPPLY_SECONDS,
				get = function()
					return ns.db.profile.earlyReapplyThreshold
				end,
				set = function(_, value)
					ns.db.profile.earlyReapplyThreshold = value
					MacroOptions.Changed()
				end,
			},
		}),

		--[[
		    The Night Elf twin below writes the same setting. Eating or drinking after
		    stealthing breaks it, so Stealth Eating and Shadowmeld Drinking exclude each other.
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

		-- The client names the race Undead, not Forsaken.
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

		-- The Night Elf header and pick-one summary are added below, at 50.
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

	MacroOptions.UseWhenGroups(args, "conjuredFirst", ConjuredFirstActive, 21)

	return MacroOptions.Page(L["OPTIONS_FOOD_WATER_HEADER"], args)
end
