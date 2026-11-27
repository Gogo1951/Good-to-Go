local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local Toggle = MacroOptions.Toggle

local function FishingLureMacroOff()
	return not ns.IsMacroEnabled("Fishing Lure")
end

local function GearToggle(settingKey, gearKey, order, nameKey)
	return Toggle(settingKey, L[nameKey], L[nameKey .. "_DESCRIPTION"], order, ns.FISHING_GEAR[gearKey] == nil)
end

-- Each spacer sits above its box and hides with it, so a box this flavor lacks leaves no gap.
function ns.BuildFishingLureOptions()
	local noPants = ns.FISHING_GEAR.legs == nil
	local noHat = ns.FISHING_GEAR.head == nil
	local noBoots = ns.FISHING_GEAR.feet == nil
	local noFood = next(ns.FISHING_FOODS) == nil

	local args = {
		descIntro = Desc(L["OPTIONS_FISHING_LURE_DESCRIPTION"], 1),
		spaceOff = Spacer(1.5, function()
			return not FishingLureMacroOff()
		end),
		fishingLureOff = Kit.StatusLine(function()
			if not FishingLureMacroOff() then
				return nil
			end
			return ns.OptionsSwitchOffStatus(L["NOTE_MACRO_FISHING_LURE"], L["TAB_CONSUMABLE_MACROS"])
		end, 1.6),
		equipPole = Toggle(
			"fishingEquipPole",
			L["OPTIONS_FISHING_EQUIP_POLE"],
			L["OPTIONS_FISHING_EQUIP_POLE_DESCRIPTION"],
			3
		),
		spacePants = Spacer(3.9, noPants),
		equipPants = GearToggle("fishingEquipPants", "legs", 4, "OPTIONS_FISHING_EQUIP_PANTS"),
		spaceHat = Spacer(4.9, noHat),
		equipHat = GearToggle("fishingEquipHat", "head", 5, "OPTIONS_FISHING_EQUIP_HAT"),
		spaceBoots = Spacer(5.9, noBoots),
		equipBoots = GearToggle("fishingEquipBoots", "feet", 6, "OPTIONS_FISHING_EQUIP_BOOTS"),
		spaceGloves = Spacer(6.9),
		equipGloves = Toggle(
			"fishingEquipGloves",
			L["OPTIONS_FISHING_EQUIP_GLOVES"],
			L["OPTIONS_FISHING_EQUIP_GLOVES_DESCRIPTION"],
			7
		),
		useFood = Toggle(
			"fishingUseFood",
			L["OPTIONS_FISHING_USE_FOOD"],
			L["OPTIONS_FISHING_USE_FOOD_DESCRIPTION"],
			9,
			noFood
		),
		useLure = Toggle(
			"fishingUseLure",
			L["OPTIONS_FISHING_USE_LURE"],
			L["OPTIONS_FISHING_USE_LURE_DESCRIPTION"],
			11
		),
	}
	Kit.Section(args, "gear", 2, L["OPTIONS_FISHING_HEADER_GEAR"])
	Kit.Section(args, "food", 8, L["OPTIONS_FISHING_HEADER_FOOD"], nil, noFood)
	Kit.Section(args, "lures", 10, L["OPTIONS_FISHING_HEADER_LURES"])
	return MacroOptions.Page(L["TAB_FISHING_LURE"], args)
end
