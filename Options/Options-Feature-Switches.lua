local _, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
    The feature switches shared by the General panel and each feature's own
    panel, and the two-to-a-line toggle layout they use. Split from
    Options/Options-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Toggle Pairs
--------------------------------------------------------------------------------

--[[
    Lays toggles out two to a line, each pair in its own unnamed inline group so
    every pair pins its own row. The widths leave slack under
    ns.OPTIONS_ROW_WIDTH: a row summing exactly to the pane sits on the wrap
    boundary and can drop its second toggle onto a line of its own.
]]
local TOGGLE_PAIR_WIDTH = (ns.OPTIONS_ROW_WIDTH - 0.2) / 2

function ns.OptionsTogglePairs(args, keyPrefix, startOrder, toggles)
	for index = 1, #toggles, 2 do
		local pair = {}
		for offset = 0, 1 do
			local toggle = toggles[index + offset]
			if toggle then
				toggle.width = TOGGLE_PAIR_WIDTH
				toggle.order = offset + 1
				pair["toggle" .. (offset + 1)] = toggle
			end
		end
		args[keyPrefix .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = startOrder + index,
			args = pair,
		}
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
    Every feature's on/off switch, drawn twice: in the root panel's Features
    section, two to a line, and atop the feature's own panel. Both copies come
    from here, so they share one caption, one tooltip and one setter, and a
    change repaints every panel so neither copy shows a stale box.

    A switch with `get` and `set` goes through the feature's own functions;
    the rest read and write their own account-wide key.

    `confirmOff` asks before a switch that keeps macros current turns off:
    off stops the updates and leaves every macro as it last was, which a
    player could take for deleting them. The prompt says it doesn't, and turning
    the switch on never asks.

    FEATURE_GROUPS is the order the root panel draws them, left to right then
    down, and the order the settings tree lists the features' panels. Each
    group is a block of rows, with a blank line between blocks.
]]
local FEATURE_SWITCHES = {
	BuffDuty = {
		name = "BUFF_DUTY_ENABLE",
		desc = "SWITCH_BUFF_DUTY_DESCRIPTION",
		get = function()
			return ns.IsBuffDutyOn()
		end,
		-- Repaints every panel itself.
		set = function(value)
			ns.SetBuffDutyOn(value)
		end,
		notifies = true,
	},
	Restocker = {
		key = "restockerEnabled",
		name = "OPTIONS_RESTOCKER_ENABLE",
		desc = "SWITCH_RESTOCKER_DESCRIPTION",
		set = function(value)
			ns.SetRestockerEnabled(value)
			ns.UpdateMinimapIcon()
		end,
	},
	Spellbook = {
		name = "SWITCH_SPELLBOOK",
		desc = "SWITCH_SPELLBOOK_DESCRIPTION",
		confirmOff = "SWITCH_SPELLBOOK_CONFIRM_OFF",
		get = function()
			return ns.IsSpellbookEnabled()
		end,
		set = function(value)
			ns.SetSpellbookEnabled(value)
		end,
	},
	Macros = {
		key = "macrosEnabled",
		name = "SWITCH_MACROS",
		desc = "SWITCH_MACROS_DESCRIPTION",
		confirmOff = "SWITCH_MACROS_CONFIRM_OFF",
		set = function(value)
			ns.SetMacrosEnabled(value)
		end,
	},
	InventoryReport = {
		key = "inventoryReport",
		name = "SWITCH_INVENTORY_REPORT",
		desc = "SWITCH_INVENTORY_REPORT_DESCRIPTION",
		set = function(value)
			ns.SetInventoryReportEnabled(value)
		end,
	},
	ReadinessReport = {
		key = "readinessReportEnabled",
		name = "SWITCH_READINESS_REPORT",
		desc = "SWITCH_READINESS_REPORT_DESCRIPTION",
		set = function(value)
			ns.db.global.readinessReportEnabled = value
			ns.SyncReadinessReportEvents()
		end,
	},
	RankWatch = {
		name = "SWITCH_RANK_WATCH",
		desc = "SWITCH_RANK_WATCH_DESCRIPTION",
		get = function()
			return ns.RankWatchSettings().enabled
		end,
		set = function(value)
			ns.SetRankWatchEnabled(value)
		end,
	},
}

ns.FEATURE_GROUPS = {
	{ "BuffDuty", "Restocker", "Spellbook", "Macros" },
	{ "InventoryReport", "ReadinessReport" },
}

-- Rank Watch, under Consumable Macros, wherever its TOC loads it: Mists has no ranks and leaves it out.
if ns.SetRankWatchEnabled then
	table.insert(ns.FEATURE_GROUPS[1], "RankWatch")
end

local function NotifyAllPanels()
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(name)
	end
end

local function GetSwitch(switch)
	if not ns.db then
		return false
	end
	if switch.get then
		return switch.get()
	end
	return ns.db.global[switch.key]
end

local function SetSwitch(switch, value)
	if switch.set then
		switch.set(value)
	else
		ns.db.global[switch.key] = value
	end
	if not switch.notifies then
		NotifyAllPanels()
	end
end

function ns.OptionsFeatureSwitch(feature, order, width)
	local switch = FEATURE_SWITCHES[feature]
	return {
		type = "toggle",
		name = L[switch.name],
		desc = L[switch.desc],
		order = order,
		width = width or "full",
		-- A string asks first; anything else changes the box at once.
		confirm = switch.confirmOff and function(_, value)
			if not value then
				return L[switch.confirmOff]
			end
		end or nil,
		get = function()
			return GetSwitch(switch)
		end,
		set = function(_, value)
			SetSwitch(switch, value)
		end,
	}
end

--[[
    The root panel's Features section: every switch, two to a line, group by
    group in FEATURE_GROUPS. Each group takes ten orders from startOrder on,
    a blank line opening every group after the first.
]]
function ns.OptionsFeatureSwitchRows(args, keyPrefix, startOrder)
	for groupIndex, group in ipairs(ns.FEATURE_GROUPS) do
		local groupOrder = startOrder + (groupIndex - 1) * 10
		local groupPrefix = keyPrefix .. groupIndex
		if groupIndex > 1 then
			args[groupPrefix .. "Space"] = ns.OptionsSpacer(groupOrder)
		end
		local toggles = {}
		for _, feature in ipairs(group) do
			toggles[#toggles + 1] = ns.OptionsFeatureSwitch(feature)
		end
		ns.OptionsTogglePairs(args, groupPrefix .. "Row", groupOrder, toggles)
	end
end
