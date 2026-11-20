local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local GetSettings = ns.OptionsProfileSettings

--[[
    Helpers the pages under Consumable Macros share (ns.MacroOptions),
    loaded before every page: a checkbox on one profile setting, and a When
    to Use -- the level filter dropdown (LEVEL_FILTER_VALUES in
    ns.LEVEL_FILTER_ORDER), on its toggle's line or on a captioned
    sub-option row of its own, then the group context checkboxes on a row
    under it with a red line while none is ticked (ns.IsUseWhenActive reads
    both). Any change rewrites the macros under the throttle.
]]
local MacroOptions = {}
ns.MacroOptions = MacroOptions

function MacroOptions.Changed()
	ns.ResetMacroState()
	ns.RequestUpdate()
	ns.RefreshSettings()
end

--[[
    A checkbox for one profile setting the macros read, written through
    ns.ToggleMacroSetting. clears, when given, is a setting this one cannot
    share the macros with: checking this box unchecks that one, so the pair
    behaves like radio buttons that can also both be off.
]]
function MacroOptions.Toggle(settingKey, label, description, order, hidden, clears)
	return {
		type = "toggle",
		name = label,
		desc = description,
		order = order,
		width = "full",
		hidden = hidden,
		get = function()
			local settings = GetSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			if value and clears then
				local settings = GetSettings()
				if settings then
					settings[clears] = false
				end
			end
			ns.ToggleMacroSetting(settingKey, value)
		end,
	}
end

-- Hover text for a level filter dropdown choosing when a macro offers a feature.
function MacroOptions.ModeDescription(featureName)
	return string.format(L["OPTIONS_MODE_DESCRIPTION"], featureName)
end

-- The level filter's labels, offered in ns.LEVEL_FILTER_ORDER.
local LEVEL_FILTER_VALUES = {
	any = L["LEVEL_FILTER_ANY"],
	leveling = L["LEVEL_FILTER_LEVELING"],
	maxlevel = L["LEVEL_FILTER_MAX_LEVEL"],
}

function MacroOptions.ModeSelect(prefix, description)
	local settingKey = prefix .. "Level"
	return {
		type = "select",
		desc = description,
		values = LEVEL_FILTER_VALUES,
		sorting = ns.LEVEL_FILTER_ORDER,
		get = function()
			return ns.db.profile[settingKey]
		end,
		set = function(_, value)
			ns.db.profile[settingKey] = value
			MacroOptions.Changed()
		end,
	}
end

-- The level filter on a sub-option row of its own, under a silver caption, for a toggle with more under it.
function MacroOptions.ModeSubRow(prefix, description, isActive, order)
	return Kit.SubLabelRow(order, function()
		return not isActive()
	end, L["OPTIONS_MODE_CAPTION"], MacroOptions.ModeSelect(prefix, description))
end

-- The group context checkboxes and their none-ticked warning, at `order` and just after it.
function MacroOptions.UseWhenGroups(args, prefix, isActive, order)
	local function GetTable()
		return ns.db.profile[prefix .. "In"]
	end
	local function Inactive()
		return not isActive()
	end
	args[prefix .. "In"] = ns.OptionsGroupContextRow(order, Inactive, GetTable, MacroOptions.Changed)
	args[prefix .. "InNone"] = ns.OptionsGroupContextNone(L["OPTIONS_GROUPS_NONE"], order + 0.01, GetTable, Inactive)
end

-- A page under Consumable Macros: its title, its args, and the off line while Consumable Macros is off.
function MacroOptions.Page(name, args)
	ns.AddFeatureOffLine(args, "macrosEnabled")
	return {
		type = "group",
		name = Kit.SubPanelTitle(L["TAB_CONSUMABLE_MACROS"], name),
		args = args,
	}
end

--[[
    A Mana Gem text naming the two runes, each as its icon and the client's
    name, built when it shows; a rune still loading shows its loading text and
    is warmed so the panel repaints.
]]
function MacroOptions.ManaRuneText(formatKey)
	return function()
		local runeIDs = { ns.DEMONIC_RUNE_ITEM_ID, ns.DARK_RUNE_ITEM_ID }
		local coldItemIDs = {}
		for _, itemID in ipairs(runeIDs) do
			if not C_Item.GetItemInfo(itemID) then
				coldItemIDs[#coldItemIDs + 1] = itemID
			end
		end
		Kit.WarmItems(coldItemIDs, ns.OPTIONS_REGISTRY.PotionsManaGems)
		return string.format(L[formatKey], Kit.ItemName(runeIDs[1]), Kit.ItemName(runeIDs[2]))
	end
end

-- A checkbox on a profile setting that only reshapes macro bodies (no aura tracking).
function MacroOptions.BodyToggle(settingKey, label, description, order)
	return {
		type = "toggle",
		name = label,
		desc = description,
		order = order,
		width = "full",
		get = function()
			local settings = ns.OptionsProfileSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			ns.db.profile[settingKey] = value
			MacroOptions.Changed()
		end,
	}
end

-- A line of body text from a locale key.
function MacroOptions.Body(key)
	return GetColor("BODY") .. L[key] .. "|r"
end
