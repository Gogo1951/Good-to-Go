local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions

--[[
    The Bandages page under Consumable Macros. It opens with what its macros
    do, then the settings that shape them; the macros themselves are
    switched on and off on Consumable Macros. Every setting lives on the
    AceDB profile. The page carries the off line while Consumable Macros is
    off (MacroOptions.Page), and its settings stay editable so they can be
    set up first. Registered as a builder function (Options/Options.lua), so
    AceConfig rebuilds it on every open and NotifyChange.
]]

-- Nothing to set yet: what the Bandage macro picks, and that the Ignore List keeps one out.
function ns.BuildBandagesOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_BANDAGES_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		descWhere = Desc(GetColor("BODY") .. L["OPTIONS_BANDAGES_SUMMARY"] .. "|r", 3),
	}
	return MacroOptions.Page(L["TAB_BANDAGES"], args)
end
