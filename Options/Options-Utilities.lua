local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Layout Grid
--------------------------------------------------------------------------------

-- The grid itself is the Options-Kit's; these widths are Good to Go's own, built on it.

ns.OPTIONS_PROMOTE_WIDTH = 0.9

ns.OPTIONS_LINK_WIDTH = ns.OPTIONS_ROW_WIDTH / 3

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

Kit.SetText({
	example = L["SAMPLE_EXAMPLE"],
	loading = L["LOADING_ITEM"],
	soundPreview = L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"],
	inCombat = L["CHAT_OPTIONS_IN_COMBAT"],
	reset = L["OPTIONS_RESET"],
})

-- The Consumable Macros panels' settings table.
function ns.OptionsProfileSettings()
	return ns.db and ns.db.profile
end

function ns.OptionsSpellDescription(formatKey, spellID)
	return function()
		return string.format(L[formatKey], C_Spell.GetSpellName(spellID) or "")
	end
end

-- bodies is one body, a list of them (an Example showing several lines), or nil for none.
function ns.PrintedExampleLines(bodies)
	local lines = {}
	for index, body in ipairs(type(bodies) == "table" and bodies or { bodies }) do
		lines[index] = Kit.PrintedLine(ns.BuildPrintLine(body))
	end
	return lines
end

--------------------------------------------------------------------------------
-- Group Context Checkboxes
--------------------------------------------------------------------------------

--[[
    The one control for when a feature acts by group, same labels on every
    panel. A feature that tunes a context further (Buff Duty's Anywhere or In
    Instance) lays out its own row around this; the rest use
    ns.OptionsGroupContextRow.
]]
function ns.OptionsGroupContextToggle(context, order, width, getTable, onChange, hidden)
	local key = context:upper()
	return {
		type = "toggle",
		name = L["GROUP_CONTEXT_" .. key],
		desc = L["GROUP_CONTEXT_" .. key .. "_DESCRIPTION"],
		width = width,
		order = order,
		hidden = hidden,
		get = function()
			return ns.IsGroupContextOn(getTable(), context)
		end,
		set = function(_, value)
			getTable()[context] = value
			onChange()
		end,
	}
end

-- Wide enough for the longest label (Battleground) in every locale, with slack under the row.
local GROUP_CONTEXT_TOGGLE_WIDTH = 0.75

-- name and page arrive localized; page is optional.
function ns.OptionsSwitchOffStatus(name, page)
	local title = Kit.Color("TITLE", name) .. ns.GetColor("HELP")
	if not page then
		return L["OPTIONS_SWITCH_OFF_HERE"]:format(title)
	end
	return L["OPTIONS_FEATURE_OFF_STATUS"]:format(title, page)
end

-- The settings under the line stay editable while the feature is off, so they can be set up first.
function ns.AddFeatureOffLine(args, setting, pageSwitch)
	local feature = ns.FindFeature(setting)
	local isOn = Kit.Get(feature.store, feature.setting)
	local function FeatureOn()
		return isOn() and true or false
	end
	--[[
	    pageSwitch { isOn, name, page }, for a sub-page switch under the
	    feature's: name is a locale key, or a function for a client-supplied
	    name (Well Fed); page is left out when the switch is on this page.
	]]
	local function PageOn()
		return not pageSwitch or pageSwitch.isOn()
	end
	local function SwitchName()
		local name = pageSwitch.name
		return type(name) == "function" and name() or L[name]
	end
	local StatusOff = ns.OptionsSwitchOffStatus
	args.featureOff = Kit.StatusLine(function()
		if not FeatureOn() then
			local name = L[feature.name]
			return StatusOff(name, name)
		end
		if not PageOn() then
			return StatusOff(SwitchName(), pageSwitch.page and L[pageSwitch.page])
		end
		return nil
	end, 0.1)
	args.featureOffSpace = Kit.Spacer(0.2, function()
		return FeatureOn() and PageOn()
	end)
end

function ns.OptionsGroupContextRow(order, hidden, getTable, onChange)
	local toggles = {}
	for index, context in ipairs(ns.GROUP_CONTEXTS) do
		toggles[index] = ns.OptionsGroupContextToggle(context, index, GROUP_CONTEXT_TOGGLE_WIDTH, getTable, onChange)
	end
	return Kit.SubRow(order, hidden, toggles)
end

function ns.NoGroupContextTicked(showIn)
	for _, context in ipairs(ns.GROUP_CONTEXTS) do
		if ns.IsGroupContextOn(showIn, context) then
			return false
		end
	end
	return true
end

-- With no box ticked the gated feature never acts, so a red line says so.
function ns.OptionsGroupContextNone(text, order, getTable, hidden)
	return Kit.WarningLine(text, function()
		if hidden and hidden() then
			return false
		end
		return ns.NoGroupContextTicked(getTable())
	end, order)
end
