local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local Body = MacroOptions.Body

--[[
    The Explosives page under Consumable Macros. It opens with what its
    macros do, then the settings that shape them; the macros themselves are
    switched on and off on Consumable Macros. Every setting lives on the
    AceDB profile. The page carries the off line while Consumable Macros is
    off (MacroOptions.Page), and its settings stay editable so they can be
    set up first. Registered as a builder function (Options/Options.lua), so
    AceConfig rebuilds it on every open and NotifyChange.
]]

-- Which click tosses the explosive and which sets it off at your feet.
function ns.BuildExplosivesOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_EXPLOSIVES_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		-- A caption row, so hovering the caption shows the dropdown's tooltip too.
		explosivesClickMode = Kit.LabelRow(3, nil, Body("OPTIONS_EXPLOSIVES_CLICK_LAYOUT"), {
			type = "select",
			desc = L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"],
			values = {
				atplayer = L["EXPLOSIVES_MODE_ATPLAYER"],
				toss = L["EXPLOSIVES_MODE_TOSS"],
			},
			sorting = { "atplayer", "toss" },
			get = function()
				return ns.db.profile.explosivesClickMode
			end,
			set = function(_, value)
				ns.db.profile.explosivesClickMode = value
				MacroOptions.Changed()
			end,
		}),
	}
	return MacroOptions.Page(L["OPTIONS_EXPLOSIVES_HEADER"], args)
end
