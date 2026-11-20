local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local BodyToggle = MacroOptions.BodyToggle
local Body = MacroOptions.Body

--[[
    The Potions & Mana Gems page under Consumable Macros. It opens with what
    its macros do, then the settings that shape them; the macros themselves
    are switched on and off on Consumable Macros. Every setting lives on the
    AceDB profile. The page carries the off line while Consumable Macros is
    off (MacroOptions.Page), and its settings stay editable so they can be
    set up first. Registered as a builder function (Options/Options.lua), so
    AceConfig rebuilds it on every open and NotifyChange.
]]

-- Potions, how they hold up in combat and their out-of-combat food, then the Mana Gem macro's runes.
function ns.BuildPotionsManaGemsOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_POTIONS_MANA_GEMS_DESCRIPTION"], 1),

		-- Potions
		spacePotions0 = Spacer(10),
		headerPotions = Header(L["OPTIONS_POTIONS_HEADER"], 11),
		spacePotions1 = Spacer(12),
		descPotions = Desc(Body("OPTIONS_POTIONS_DESCRIPTION"), 13),
		spacePotions2 = Spacer(14),
		togglePotionsUseFoodAndWater = BodyToggle(
			"potionsUseFoodAndWater",
			L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"],
			L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"],
			15
		),

		-- Mana Gems & Runes
		spaceManaGems0 = Spacer(20),
		headerManaGems = Header(L["OPTIONS_MANA_GEMS_HEADER"], 21),
		spaceManaGems1 = Spacer(22),
		descManaGems = Desc(function()
			return GetColor("BODY") .. MacroOptions.ManaRuneText("OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT")() .. "|r"
		end, 23),
		spaceManaGems2 = Spacer(24),
		toggleIncludeManaRunes = BodyToggle(
			"includeManaRunes",
			L["OPTIONS_INCLUDE_MANA_RUNES"],
			MacroOptions.ManaRuneText("OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"),
			25
		),
	}
	return MacroOptions.Page(L["TAB_POTIONS_MANA_GEMS"], args)
end
