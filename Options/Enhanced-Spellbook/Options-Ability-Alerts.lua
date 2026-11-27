local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Ability Alerts While Leveling Panel
--------------------------------------------------------------------------------

--[[
	The level-up prints have nothing to do with other players' ranks and run whether Rank Watch is on or not, so
	they have their own switch and panel. Every setting is account-wide, beside Rank Watch's own.
]]

local function Settings()
	return ns.RankWatchSettings()
end

local function AlertsOff()
	return not Settings().levelUpAlerts
end

local function PetOff()
	return AlertsOff() or not Settings().levelUpAlertsPet
end

local function SubToggle(key, name, desc, order, hidden)
	return Kit.SubToggleRow(order, hidden, {
		type = "toggle",
		name = L[name],
		desc = L[desc],
		get = function()
			return Settings()[key]
		end,
		set = function(_, value)
			Settings()[key] = value
			ns.RefreshSettings()
		end,
	})
end

local function Example()
	return ns.PrintedExampleLines(ns.LevelUpAlertExample())
end

function ns.BuildAbilityAlertsOptions()
	return {
		name = Kit.SubPanelTitle(L["TAB_ENHANCED_SPELLBOOK"], L["RANK_WATCH_LEVEL_UP_HEADER"]),
		type = "group",
		args = {
			description = Desc(L["ABILITY_ALERTS_DESCRIPTION"], 1),
			space0 = Spacer(2),
			switch = Kit.FeatureSwitch("rankWatch.levelUpAlerts", 3),
			past = SubToggle(
				"levelUpAlertsPast",
				"RANK_WATCH_LEVEL_UP_PAST",
				"RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION",
				4,
				AlertsOff
			),
			pet = SubToggle(
				"levelUpAlertsPet",
				"RANK_WATCH_LEVEL_UP_PET",
				"RANK_WATCH_LEVEL_UP_PET_DESCRIPTION",
				5,
				AlertsOff
			),
			petPast = SubToggle(
				"levelUpAlertsPetPast",
				"RANK_WATCH_LEVEL_UP_PET_PAST",
				"RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION",
				6,
				PetOff
			),
			example = Kit.Example(7, AlertsOff, Example),
		},
	}
end
