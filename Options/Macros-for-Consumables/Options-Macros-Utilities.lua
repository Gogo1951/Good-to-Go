local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local GetSettings = ns.OptionsProfileSettings

local MacroOptions = {}
ns.MacroOptions = MacroOptions

function MacroOptions.Changed()
	ns.ResetMacroState()
	ns.RequestUpdate()
	ns.RefreshSettings()
end

-- clears: a setting this one excludes, so the pair acts as radio buttons that can both be off.
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

function MacroOptions.ModeDescription(featureName)
	return string.format(L["OPTIONS_MODE_DESCRIPTION"], featureName)
end

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

function MacroOptions.ModeSubRow(prefix, description, isActive, order)
	return Kit.SubLabelRow(order, function()
		return not isActive()
	end, L["OPTIONS_MODE_CAPTION"], MacroOptions.ModeSelect(prefix, description))
end

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

function MacroOptions.Page(name, args)
	ns.AddFeatureOffLine(args, "macrosEnabled")
	return {
		type = "group",
		name = Kit.SubPanelTitle(L["TAB_CONSUMABLE_MACROS"], name),
		args = args,
	}
end

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

-- For settings that only reshape bodies: no aura tracking, unlike ns.ToggleMacroSetting.
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

function MacroOptions.Body(key)
	return GetColor("BODY") .. L[key] .. "|r"
end
