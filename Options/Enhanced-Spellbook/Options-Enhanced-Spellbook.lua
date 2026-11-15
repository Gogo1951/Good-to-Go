local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Delete Macros
--------------------------------------------------------------------------------

--[[
	A button deleting the Spellbook's macros from one list (ns.DeleteAddonMacros), behind a confirm, and
	grayed out while the list holds none, on a row of its own in the control column. Every panel repaints
	after, so the button grays out at once.
]]
local function DeleteMacrosButton(general, nameKey, descKey, confirmKey, order)
	return Kit.Row(order, nil, {
		Kit.Label(" ", nil, Kit.LABEL_WIDTH),
		{
			type = "execute",
			name = L[nameKey],
			desc = L[descKey],
			width = Kit.CONTROL_WIDTH,
			confirm = true,
			confirmText = L[confirmKey],
			disabled = function()
				return ns.CountAddonMacros(general) == 0
			end,
			func = function()
				ns.DeleteAddonMacros(general)
				ns.RefreshSettings()
			end,
		},
	})
end

--------------------------------------------------------------------------------
-- Enhanced Spellbook Panel
--------------------------------------------------------------------------------

local function SpellbookOff()
	return not ns.IsSpellbookEnabled()
end

--[[
	The Spellbook's page in the settings tree. Its settings live on the Spellbook itself, so this holds only
	what can't: the on/off switch, what the ability tooltips' ranks are for and their own switch (shown only while it's on), and the buttons that delete the
	macros it made. The key that opens it is on the root panel, with every other key binding.
]]
function ns.BuildSpellbookOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_SPELLBOOK_DESCRIPTION"], 1),
		spaceEnable = Spacer(2),
		toggleSpellbookEnabled = Kit.FeatureSwitch("spellbookEnabled", 3),

		--[[
		    What's Next ability tooltips: the ranks under every spell's tooltip
		    (Features/Enhanced-Spellbook/Spell-Ranks-Tooltip.lua). The whole section is hidden while the
		    Spellbook is off, since no tooltip gets ranks then.
		]]
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
			end,
		},

		-- Delete Macros
		spacerDeleteMacros0 = Spacer(60),
		headerDeleteMacros = Header(L["OPTIONS_DELETE_MACROS_HEADER"], 61),
		spacerDeleteMacros1 = Spacer(62),
		descDeleteMacros = Desc(L["OPTIONS_DELETE_MACROS_DESCRIPTION"], 63),
		spacerDeleteMacros2 = Spacer(64),
		deleteCharacterMacros = DeleteMacrosButton(
			false,
			"OPTIONS_DELETE_CHARACTER_MACROS",
			"OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION",
			"OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM",
			65
		),
		deleteGeneralMacros = DeleteMacrosButton(
			true,
			"OPTIONS_DELETE_GENERAL_MACROS",
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
