local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Restocker Panel
--------------------------------------------------------------------------------

-- Account-wide (ns.db.global.restocker), never ns.db.profile.
local function GetRestockerSettings()
	return ns.restockSettings
end

local function RestockerOff()
	return not (ns.db and ns.db.global.restockerEnabled)
end

local function ReminderOff(enabledKey)
	return function()
		local settings = GetRestockerSettings()
		return not (settings and settings[enabledKey])
	end
end

local RemindHidden = ReminderOff("restockReminderChat")

local function PlayAlert()
	if ns.RESTOCK_ALERT_SOUND then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

local function ReminderModes()
	return {
		[ns.REMINDER_SIMPLE] = L["OPTIONS_RESTOCKER_MODE_SIMPLE"],
		[ns.REMINDER_VERBOSE] = L["OPTIONS_RESTOCKER_MODE_VERBOSE"],
	}
end

local REMINDER_MODE_ORDER = { ns.REMINDER_SIMPLE, ns.REMINDER_VERBOSE }

-- 5 of 20 is low at every threshold offered, so the Example never goes quiet.
local SAMPLE_OUT = { { itemID = ns.SAMPLE_RESTOCK_ITEM_ID, have = 0, wanted = 20 } }
local SAMPLE_LOW = { { itemID = ns.SAMPLE_RESTOCK_ITEM_ID, have = 5, wanted = 20 } }

-- One line: Simple's headline, or the first item line Verbose adds under it.
local function ReminderExample(order, enabledKey, modeKey, headlineFunction)
	return Kit.Example(order, ReminderOff(enabledKey), function()
		local settings = GetRestockerSettings()
		local mode = settings and settings[modeKey]
		local headline = headlineFunction(#SAMPLE_OUT, #SAMPLE_LOW)
		local lines = ns.BuildRestockShortfallLines(headline, mode, SAMPLE_OUT, SAMPLE_LOW)
		return ns.PrintedExampleLines(lines[mode == ns.REMINDER_VERBOSE and 2 or 1])
	end)
end

local function GoldReserveExampleLine()
	local settings = GetRestockerSettings()
	return ns.PrintedExampleLines(ns.BuildOutOfGoldLine(settings or {}, 0))
end

local function GoldReserveOff()
	local settings = GetRestockerSettings()
	return not (settings and settings.goldReserve)
end

local function TownHeadline(outCount, lowCount)
	return ns.RestockTownHeadline(outCount, lowCount)
end

local function ClosingHeadline(outCount, lowCount)
	return ns.RestockClosingHeadline(outCount, lowCount)
end

local function AllRemindersOff()
	local settings = GetRestockerSettings()
	return not (settings and (settings.restockReminderChat or settings.merchantReminder or settings.bankReminder))
end

local function LowThresholds()
	local values = {}
	for _, percent in ipairs(ns.RESTOCK_LOW_THRESHOLDS) do
		values[percent] = percent .. "%"
	end
	return values
end

local function GoldReserveAmounts()
	local values = {}
	for _, amount in ipairs(ns.GOLD_RESERVE_AMOUNTS) do
		values[amount] = amount .. ns.GOLD_ICON
	end
	return values
end

-- Width defaults to the label cell its dropdown sits beside.
local function ReminderToggle(labelKey, descKey, settingKey, order, width)
	return {
		type = "toggle",
		name = L[labelKey],
		desc = L[descKey],
		order = order,
		width = width or ns.OPTIONS_LABEL_WIDTH,
		get = function()
			local settings = GetRestockerSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
			ns.RefreshSettings()
		end,
	}
end

local function ReminderModeRow(settingKey, enabledKey, order)
	return Kit.SubLabelRow(order, ReminderOff(enabledKey), L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"], {
		type = "select",
		desc = L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"],
		values = ReminderModes,
		sorting = REMINDER_MODE_ORDER,
		get = function()
			local settings = GetRestockerSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
			ns.RefreshSettings()
		end,
	})
end

function ns.BuildRestockerOptions()
	local options = {
		type = "group",
		name = L["TAB_RESTOCKER"],
		args = {
			descRestocker = Desc(
				GetColor("BODY")
					.. string.format(
						L["OPTIONS_RESTOCKER_DESCRIPTION"],
						GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
					)
					.. "|r",
				1
			),
			spaceEnabled = Spacer(1.1),
			toggleRestockerEnabled = Kit.FeatureSwitch("restockerEnabled", 1.2),

			spaceGold0 = Spacer(2),
			headerGold = Header(L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"], 2.1),
			spaceGold1 = Spacer(2.2),
			descGold = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] .. "|r", 2.3),
			spaceGold2 = Spacer(4),
			toggleGoldReserve = ReminderToggle(
				"OPTIONS_RESTOCKER_GOLD_RESERVE",
				"OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION",
				"goldReserve",
				5
			),
			amountGoldReserve = {
				type = "select",
				name = "",
				desc = L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"],
				order = 6,
				width = ns.OPTIONS_CONTROL_WIDTH,
				hidden = function()
					local settings = GetRestockerSettings()
					return not (settings and settings.goldReserve)
				end,
				values = GoldReserveAmounts,
				sorting = ns.GOLD_RESERVE_AMOUNTS,
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.goldReserveAmount
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.goldReserveAmount = value
					end
					ns.RefreshSettings()
				end,
			},
			exampleGoldReserve = Kit.Example(6.5, GoldReserveOff, GoldReserveExampleLine),

			-- Reminders
			spaceReminders0 = Spacer(7),
			headerReminders = Header(L["OPTIONS_RESTOCKER_REMINDERS_HEADER"], 8),
			spaceReminders1 = Spacer(9),
			descReminders = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] .. "|r", 9.1),
			spaceReminders2 = Spacer(9.2),

			-- One threshold for all three reminders, so they never disagree about the same bags.
			rowLowThreshold = Kit.LabelRow(9.3, AllRemindersOff, L["OPTIONS_RESTOCKER_LOW_THRESHOLD"], {
				type = "select",
				desc = L["OPTIONS_RESTOCKER_LOW_THRESHOLD_DESCRIPTION"],
				values = LowThresholds,
				sorting = ns.RESTOCK_LOW_THRESHOLDS,
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.restockLowThreshold
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.restockLowThreshold = value
					end
					ns.RefreshSettings()
				end,
			}),
			spaceLowThreshold = Spacer(9.5, AllRemindersOff),

			toggleRestockerRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_REMIND",
				"OPTIONS_RESTOCKER_REMIND_DESCRIPTION",
				"restockReminderChat",
				10,
				"full"
			),
			modeRestockerRemind = ReminderModeRow("restockReminderMode", "restockReminderChat", 11),

			--[[
			    Only the in-town reminder gets a sound: it arrives while you're
			    running around. The others fire on a window you just closed.
			]]
			soundRow = Kit.SubToggleRow(12, RemindHidden, {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_REMIND_SOUND"],
				desc = L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"],
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.restockReminderSound
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.restockReminderSound = value
					end
					ns.RefreshSettings()
				end,
			}, Kit.SoundPreview(PlayAlert)),
			exampleRestockerRemind = ReminderExample(12.5, "restockReminderChat", "restockReminderMode", TownHeadline),

			-- Peers of the in-town reminder, not children: turning that off mustn't silence these.
			spaceMerchant0 = Spacer(13),
			toggleRestockerMerchantRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_MERCHANT_REMIND",
				"OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION",
				"merchantReminder",
				14,
				"full"
			),
			modeRestockerMerchantRemind = ReminderModeRow("merchantReminderMode", "merchantReminder", 15),
			exampleRestockerMerchantRemind = ReminderExample(
				15.5,
				"merchantReminder",
				"merchantReminderMode",
				ClosingHeadline
			),

			spaceBank0 = Spacer(16),
			toggleRestockerBankRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_BANK_REMIND",
				"OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION",
				"bankReminder",
				17,
				"full"
			),
			modeRestockerBankRemind = ReminderModeRow("bankReminderMode", "bankReminder", 18),
			exampleRestockerBankRemind = ReminderExample(18.5, "bankReminder", "bankReminderMode", ClosingHeadline),

			-- Restocker Window
			spaceWindow0 = Spacer(20),
			headerWindow = Header(L["OPTIONS_RESTOCKER_WINDOW_HEADER"], 21),
			spaceWindow1 = Spacer(22),
			descWindow = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] .. "|r", 23),
			spaceWindow2 = Spacer(24),
			toggleRestockerBank = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_BANK"],
				desc = L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"],
				order = 25,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtBank
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtBank = value
					end
					ns.RefreshSettings()
				end,
			},
			spaceWindow3 = Spacer(26),
			toggleRestockerMerchant = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_MERCHANT"],
				desc = L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"],
				order = 27,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtMerchant
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtMerchant = value
					end
					ns.RefreshSettings()
				end,
			},

			spaceWindow4 = Spacer(28),
			resetRestockPosition = Kit.ResetRow(
				29,
				nil,
				L["RESTOCKER_RESET_LIST_POSITION"],
				L["OPTIONS_RESET_POSITION_DESCRIPTION"],
				function()
					return not ns.HasSavedRestockWindowPosition()
				end,
				ns.ResetRestockWindowPosition
			),
			spaceWindow5 = Spacer(30),
			resetStaplesPosition = Kit.ResetRow(
				31,
				nil,
				L["RESTOCKER_RESET_STAPLES_POSITION"],
				L["OPTIONS_RESET_POSITION_DESCRIPTION"],
				function()
					return not ns.HasSavedStaplesPosition()
				end,
				ns.ResetStaplesPosition
			),
		},
	}
	Kit.HideAllExcept(options.args, RestockerOff, { "descRestocker", "spaceEnabled", "toggleRestockerEnabled" })
	return options
end
