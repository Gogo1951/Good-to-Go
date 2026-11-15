local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Layout Grid
--------------------------------------------------------------------------------

--[[
    The grid itself (ns.OPTIONS_ROW_WIDTH, ns.OPTIONS_LABEL_WIDTH,
    ns.OPTIONS_CONTROL_WIDTH and the rest) is the Options-Kit's
    (Options/Options-Kit.lua), which loads first in the Options group. These
    widths are Good to Go's own, built on it, and only its options panels read
    them.
]]

-- The item lists' promote column, sized to hold its button caption.
ns.OPTIONS_PROMOTE_WIDTH = 0.9

--[[
    The same row inside an inline group (a class's box of buffs). The box insets
    its content 10 pixels -- in width units, where AceConfigDialog makes 1 unit
    170 pixels -- and its border takes room besides, so the label gives back 0.3
    or the control wraps under it. A row outside a box that should line up with
    the boxed ones below it uses the inset label width: same control, same x.
]]
ns.OPTIONS_INLINE_LABEL_WIDTH = ns.OPTIONS_LABEL_WIDTH - 0.3
ns.OPTIONS_INLINE_INSET_WIDTH = 10 / 170
ns.OPTIONS_ALIGNED_LABEL_WIDTH = ns.OPTIONS_INLINE_LABEL_WIDTH + ns.OPTIONS_INLINE_INSET_WIDTH

-- A spell or item link cell, three to a row.
ns.OPTIONS_LINK_WIDTH = ns.OPTIONS_ROW_WIDTH / 3

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    The standard pieces every panel is built from (headers, rows, switches,
    Example lines, item lists, registration) are the Options-Kit's
    (Options/Options-Kit.lua). This file hands the kit its strings and holds
    the helpers only Good to Go's panels share. The feature switches, the
    widget types and the whisper composer have files of their own beside this
    one: Options-Feature-Switches.lua, Options-Widgets.lua and
    Options-Message-Composer.lua. A feature's own helpers live beside its
    panels, in Options/<Feature>/Options-<Feature>-Utilities.lua.
]]
Kit.SetText({
	example = L["SAMPLE_EXAMPLE"],
	loading = L["LOADING_ITEM"],
	soundPreview = L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"],
	inCombat = L["CHAT_OPTIONS_IN_COMBAT"],
	reset = L["OPTIONS_RESET"],
})

-- The character's AceDB profile, the Consumable Macros panels' settings table, or nil before the database is open.
function ns.OptionsProfileSettings()
	return ns.db and ns.db.profile
end

-- A label or hover text that names a spell, formatKey's %s, read from the client when it shows.
function ns.OptionsSpellDescription(formatKey, spellID)
	return function()
		return string.format(L[formatKey], C_Spell.GetSpellName(spellID) or "")
	end
end

--[[
    A print-out's Example lines, for Kit.Example: each body as ns.BuildPrintLine
    prints it, drawn through Kit.PrintedLine. bodies is one body, a list of
    them (a feature whose Example shows several lines), or nil for none.
]]
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
    The one control for when a feature acts by group: a checkbox per group
    context, always Solo, Party, Raid, Battleground (ns.GROUP_CONTEXTS), with
    the same labels and hover text on every panel. `getTable` returns the
    setting's { solo, party, raid, battleground } table; `onChange` runs after
    a tick changes. A feature that tunes a context further (Buff Duty's
    Anywhere or In Instance) lays its own row out around
    ns.OptionsGroupContextToggle; the rest take the four in one sub-option row
    from ns.OptionsGroupContextRow.
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

--[[
    The line a sub-page opens with while its parent feature is off, and the blank
    line under it; both go while the feature is on, so the page then starts at its
    description. The settings stay editable, so they can be set up first. `setting`
    is the feature's ns.FEATURES setting; its name leads the line in gold.
]]
function ns.AddFeatureOffLine(args, setting)
	local feature = ns.FindFeature(setting)
	local isOn = Kit.Get(feature.store, feature.setting)
	local function FeatureOn()
		return isOn() and true or false
	end
	args.featureOff = Kit.StatusLine(function()
		if FeatureOn() then
			return nil
		end
		local name = L[feature.name]
		return L["OPTIONS_FEATURE_OFF_STATUS"]:format(Kit.Color("TITLE", name) .. ns.GetColor("HELP"), name)
	end, 0.1)
	args.featureOffSpace = Kit.Spacer(0.2, FeatureOn)
end

function ns.OptionsGroupContextRow(order, hidden, getTable, onChange)
	local toggles = {}
	for index, context in ipairs(ns.GROUP_CONTEXTS) do
		toggles[index] = ns.OptionsGroupContextToggle(context, index, GROUP_CONTEXT_TOGGLE_WIDTH, getTable, onChange)
	end
	return Kit.SubRow(order, hidden, toggles)
end

-- Whether a group context table has no box ticked, so the feature it gates never acts.
function ns.NoGroupContextTicked(showIn)
	for _, context in ipairs(ns.GROUP_CONTEXTS) do
		if ns.IsGroupContextOn(showIn, context) then
			return false
		end
	end
	return true
end

--[[
    The warning under a set of group context checkboxes with none ticked: the
    feature they gate never acts, and the line says so in red (Kit.WarningLine).
    `text` is the feature's own sentence; it hides while any box is ticked or
    `hidden` holds.
]]
function ns.OptionsGroupContextNone(text, order, getTable, hidden)
	return Kit.WarningLine(text, function()
		if hidden and hidden() then
			return false
		end
		return ns.NoGroupContextTicked(getTable())
	end, order)
end
