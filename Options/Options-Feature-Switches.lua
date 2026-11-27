local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    Every feature's on/off switch, in the kit's record shape (Options-Kit.lua →
    Features), drawn both atop the feature's panel and on the root panel.
    Order matches the mini-map menu: its blocks first, then More Features.

    `confirm` asks before a macro-keeping switch turns off: off leaves every
    macro as it last was, which a player could take for deleting them.
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
	{
		store = "global",
		setting = "currencyReplenish.enabled",
		name = "CURRENCY_REPLENISH",
		caption = "SWITCH_CURRENCY_REPLENISH",
		desc = "SWITCH_CURRENCY_REPLENISH_DESCRIPTION",
		apply = function(value)
			ns.db.global.currencyReplenish.enabled = value
			ns.SyncCurrencyReplenishEvents()
			if not value then
				ns.CurrencyReplenish.CloseWindow()
			end
			ns.CurrencyReplenish.SyncTab()
		end,
	},
}

--[[
    Only where Rank Watch loads (Mists has no ranks). The level-up prints run
    whether Rank Watch is on or not, so their switch only writes its setting.
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
    An unknown setting is a caller typo, so it errors. Called only at draw
    time, so files loaded before this one (Minimap-Menu.lua) can use it too.
]]
function ns.FindFeature(setting)
	for _, feature in ipairs(ns.FEATURES) do
		if feature.setting == setting then
			return feature
		end
	end
	error(ADDON_NAME .. ": no ns.FEATURES entry for " .. tostring(setting), 2)
end
