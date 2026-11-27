local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Delete Macros
--------------------------------------------------------------------------------

-- Every panel repaints after, so the button grays out at once.
local function DeleteMacrosButton(general, caption, descKey, confirmKey, order)
	return Kit.ButtonRow(order, nil, {
		type = "execute",
		name = L["OPTIONS_DELETE"],
		desc = L[descKey],
		confirm = true,
		confirmText = L[confirmKey],
		disabled = function()
			return ns.CountAddonMacros(general) == 0
		end,
		func = function()
			ns.DeleteAddonMacros(general)
			ns.RefreshSettings()
		end,
	}, caption)
end

--------------------------------------------------------------------------------
-- Enhanced Spellbook Panel
--------------------------------------------------------------------------------

local function SpellbookOff()
	return not ns.IsSpellbookEnabled()
end

--[[
	The Spellbook's settings live on the Spellbook itself, so this holds only what can't. The key that opens it
	is on the root panel, with every other key binding.
]]
function ns.BuildSpellbookOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_SPELLBOOK_DESCRIPTION"], 1),
		spaceEnable = Spacer(2),
		toggleSpellbookEnabled = Kit.FeatureSwitch("spellbookEnabled", 3),
		spaceResetPosition = Spacer(4, SpellbookOff),
		resetPosition = Kit.ResetRow(
			5,
			SpellbookOff,
			L["OPTIONS_RESET_POSITION"],
			L["OPTIONS_RESET_POSITION_DESCRIPTION"],
			function()
				return not ns.HasSavedSpellbookWindowPosition()
			end,
			ns.ResetSpellbookWindowPosition
		),

		-- hidden while the Spellbook is off, since no tooltip gets ranks then
		spacerAbilityTooltips0 = Spacer(50, SpellbookOff),
		headerAbilityTooltips = Header(L["OPTIONS_ABILITY_TOOLTIPS_HEADER"], 51, SpellbookOff),
		spacerAbilityTooltips1 = Spacer(52, SpellbookOff),
		descAbilityTooltips = Desc(L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"], 53, SpellbookOff),
		spacerAbilityTooltips2 = Spacer(54, SpellbookOff),
		toggleAbilityTooltips = {
			type = "toggle",
			name = L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"],
			desc = L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"],
			order = 55,
			width = "full",
			hidden = SpellbookOff,
			get = function()
				return ns.db and ns.db.global.abilityTooltipRanks
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.abilityTooltipRanks = value
				end
				ns.RefreshSettings()
			end,
		},

		spacerDeleteMacros0 = Spacer(60),
		headerDeleteMacros = Header(L["OPTIONS_DELETE_MACROS_HEADER"], 61),
		spacerDeleteMacros1 = Spacer(62),
		descDeleteMacros = Desc(L["OPTIONS_DELETE_MACROS_DESCRIPTION"], 63),
		spacerDeleteMacros2 = Spacer(64),
		deleteCharacterMacros = DeleteMacrosButton(
			false,
			L["OPTIONS_DELETE_CHARACTER_MACROS_CAPTION"],
			"OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION",
			"OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM",
			65
		),
		spacerDeleteMacros3 = Spacer(65.5),
		deleteGeneralMacros = DeleteMacrosButton(
			true,
			GENERAL_MACROS,
			"OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION",
			"OPTIONS_DELETE_GENERAL_MACROS_CONFIRM",
			66
		),
	}
	return {
		type = "group",
		name = L["TAB_ENHANCED_SPELLBOOK"],
		args = args,
	}
end
