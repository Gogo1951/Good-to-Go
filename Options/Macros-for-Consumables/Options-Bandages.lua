local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions

function ns.BuildBandagesOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_BANDAGES_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		descWhere = Desc(GetColor("BODY") .. L["OPTIONS_BANDAGES_SUMMARY"] .. "|r", 3),
	}
	return MacroOptions.Page(L["TAB_BANDAGES"], args)
end
