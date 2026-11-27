local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local BodyToggle = MacroOptions.BodyToggle

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
