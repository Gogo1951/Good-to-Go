local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local BodyToggle = MacroOptions.BodyToggle

--[[
    The Healthstone page under Consumable Macros. It opens with what its
    macros do, then the settings that shape them; the macros themselves are
    switched on and off on Consumable Macros. Every setting lives on the
    AceDB profile. The page carries the off line while Consumable Macros is
    off (MacroOptions.Page), and its settings stay editable so they can be
    set up first. Registered as a builder function (Options/Options.lua), so
    AceConfig rebuilds it on every open and NotifyChange.
]]

-- What the Healthstone macro does, then folding a Healthstone into the Health Potion macro.
function ns.BuildHealthstoneOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_HEALTHSTONE_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		toggleCombineHealthstones = BodyToggle(
			"combineHealthstones",
			L["OPTIONS_COMBINE_HEALTHSTONES"],
			L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"],
			3
		),
	}
	return MacroOptions.Page(L["TAB_HEALTHSTONE"], args)
end
