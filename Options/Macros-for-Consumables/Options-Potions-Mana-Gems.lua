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

function ns.BuildPotionsManaGemsOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_POTIONS_MANA_GEMS_DESCRIPTION"], 1),

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
