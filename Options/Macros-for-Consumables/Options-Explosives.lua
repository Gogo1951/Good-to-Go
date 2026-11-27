local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local Body = MacroOptions.Body

local function ExplosivesMacroOff()
	return not ns.IsMacroEnabled("Explosive")
end

function ns.BuildExplosivesOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_EXPLOSIVES_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		explosivesOff = Kit.StatusLine(function()
			if not ExplosivesMacroOff() then
				return nil
			end
			return ns.OptionsSwitchOffStatus(L["NOTE_MACRO_EXPLOSIVES"], L["TAB_CONSUMABLE_MACROS"])
		end, 2.5),
		-- A caption row, so hovering the caption shows the dropdown's tooltip too.
		explosivesClickMode = Kit.LabelRow(3, ExplosivesMacroOff, Body("OPTIONS_EXPLOSIVES_CLICK_LAYOUT"), {
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
