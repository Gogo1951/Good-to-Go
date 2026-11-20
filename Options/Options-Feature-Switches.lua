local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    Every feature's on/off switch, in the kit's record shape (Options-Kit.lua →
    Features). Kit.FeatureSwitch draws it atop the feature's own panel and
    Kit.FeatureSwitches on the root panel's Features section, two to a line, so
    both copies share one caption, one tooltip, one confirm and one setter.

    The order is the mini-map menu's: its blocks first (Buff Duty, Restocker),
    then More Features. The settings tree lists the features' panels in the
    same order.

    Each switch lives in ns.db.global at `setting`; `apply` runs the feature's
    own setter, which writes it and does its side effects. `confirm` asks
    before a switch that keeps macros current turns off: off stops the updates
    and leaves every macro as it last was, which a player could take for
    deleting them. The prompt says it doesn't, and turning the switch on never
    asks.
]]
ns.FEATURES = {
	{
		store = "global",
		setting = "buffWindow.enabled",
		name = "TAB_BUFF_DUTY",
		caption = "BUFF_DUTY_ENABLE",
		desc = "SWITCH_BUFF_DUTY_DESCRIPTION",
		block = true,
		apply = function(value)
			ns.SetBuffDutyOn(value)
		end,
	},
	{
		store = "global",
		setting = "restockerEnabled",
		name = "TAB_RESTOCKER",
		caption = "OPTIONS_RESTOCKER_ENABLE",
		desc = "SWITCH_RESTOCKER_DESCRIPTION",
		block = true,
		apply = function(value)
			ns.SetRestockerEnabled(value)
		end,
	},
	{
		store = "global",
		setting = "spellbookEnabled",
		name = "TAB_ENHANCED_SPELLBOOK",
		caption = "SWITCH_SPELLBOOK",
		desc = "SWITCH_SPELLBOOK_DESCRIPTION",
		confirm = "SWITCH_SPELLBOOK_CONFIRM_OFF",
		apply = function(value)
			ns.SetSpellbookEnabled(value)
		end,
	},
	{
		store = "global",
		setting = "macrosEnabled",
		name = "TAB_CONSUMABLE_MACROS",
		caption = "SWITCH_MACROS",
		desc = "SWITCH_MACROS_DESCRIPTION",
		confirm = "SWITCH_MACROS_CONFIRM_OFF",
		apply = function(value)
			ns.SetMacrosEnabled(value)
		end,
	},
	{
		store = "global",
		setting = "inventoryReport",
		name = "INVENTORY_REPORT_TITLE",
		caption = "SWITCH_INVENTORY_REPORT",
		desc = "SWITCH_INVENTORY_REPORT_DESCRIPTION",
		apply = function(value)
			ns.SetInventoryReportEnabled(value)
		end,
	},
	{
		store = "global",
		setting = "readinessReportEnabled",
		name = "TAB_READINESS_REPORT",
		caption = "SWITCH_READINESS_REPORT",
		desc = "SWITCH_READINESS_REPORT_DESCRIPTION",
		apply = function(value)
			ns.db.global.readinessReportEnabled = value
			ns.SyncReadinessReportEvents()
		end,
	},
}

--[[
    Wherever Rank Watch's TOC loads it (Mists has no ranks and leaves it out): Ability Alerts While Leveling
    after Enhanced Spellbook, whose panel it sits under, then Rank Watch after Consumable Macros. The level-up
    prints run whether Rank Watch is on or not, so their switch only writes its setting.
]]
if ns.SetRankWatchEnabled then
	table.insert(ns.FEATURES, 4, {
		store = "global",
		setting = "rankWatch.levelUpAlerts",
		name = "RANK_WATCH_LEVEL_UP_HEADER",
		caption = "SWITCH_ABILITY_ALERTS",
		desc = "SWITCH_ABILITY_ALERTS_DESCRIPTION",
	})
	table.insert(ns.FEATURES, 6, {
		store = "global",
		setting = "rankWatch.enabled",
		name = "TAB_RANK_WATCH",
		caption = "SWITCH_RANK_WATCH",
		desc = "SWITCH_RANK_WATCH_DESCRIPTION",
		apply = function(value)
			ns.SetRankWatchEnabled(value)
		end,
	})
end

--[[
    The ns.FEATURES record for a setting, for its name, its switch's strings and its setter. An unknown setting
    is a typo in the caller, so it errors. Read when a panel or the mini-map menu is drawn, after every file
    has loaded, so Features/Minimap-Menu.lua (loaded before this) can call it too.
]]
function ns.FindFeature(setting)
	for _, feature in ipairs(ns.FEATURES) do
		if feature.setting == setting then
			return feature
		end
	end
	error(ADDON_NAME .. ": no ns.FEATURES entry for " .. tostring(setting), 2)
end
