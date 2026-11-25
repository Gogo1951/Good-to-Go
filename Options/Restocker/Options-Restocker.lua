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

--[[
    The Restocker's settings live on ns.db.global.restocker, bound to
    ns.restockSettings at PLAYER_LOGIN. They are account-wide rather than
    per-character, which is why these controls read through this accessor
    instead of ns.db.profile -- each character still defaults to its own
    restock list, but the toggles below are one choice for the account.
]]
local function GetRestockerSettings()
	return ns.restockSettings
end

-- Everything under the switch hides while the Restocker is off.
local function RestockerOff()
	return not (ns.db and ns.db.global.restockerEnabled)
end

--[[
    Hides a reminder's own rows (its How Much to Say row, its Example) while
    its switch is off.
]]
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

--[[
    The merchant and bank reminders are each a toggle with the dropdown
    choosing how much it says on the same line, sized like every other
    toggle-and-dropdown row (the kit's grid) so the two rows end together.
]]
local function ReminderModes()
	return {
		[ns.REMINDER_SIMPLE] = L["OPTIONS_RESTOCKER_MODE_SIMPLE"],
		[ns.REMINDER_VERBOSE] = L["OPTIONS_RESTOCKER_MODE_VERBOSE"],
	}
end

local REMINDER_MODE_ORDER = { ns.REMINDER_SIMPLE, ns.REMINDER_VERBOSE }

--[[
    The staples a reminder's Example counts: one out, one low. 5 of 20 is low
    at every threshold the dropdown offers, so the Example never goes quiet.
]]
local SAMPLE_OUT = { { itemID = ns.SAMPLE_RESTOCK_ITEM_ID, have = 0, wanted = 20 } }
local SAMPLE_LOW = { { itemID = ns.SAMPLE_RESTOCK_ITEM_ID, have = 5, wanted = 20 } }

--[[
    A reminder's Example, drawn through the same builder the reminder prints
    with, in the mode its dropdown has chosen: one line. Simple says only the
    headline, so that is its Example. Verbose's Example shows the first item
    line under the headline, the part Verbose adds.
]]
local function ReminderExample(order, enabledKey, modeKey, headlineFunction)
	return Kit.Example(order, ReminderOff(enabledKey), function()
		local settings = GetRestockerSettings()
		local mode = settings and settings[modeKey]
		local headline = headlineFunction(#SAMPLE_OUT, #SAMPLE_LOW)
		local lines = ns.BuildRestockShortfallLines(headline, mode, SAMPLE_OUT, SAMPLE_LOW)
		return ns.PrintedExampleLines(lines[mode == ns.REMINDER_VERBOSE and 2 or 1])
	end)
end

-- The Gold Reserve's line, at the amount its dropdown has chosen, as an empty purse sees it.
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

-- The threshold row means nothing while every reminder is off.
local function AllRemindersOff()
	local settings = GetRestockerSettings()
	return not (settings and (settings.restockReminderChat or settings.merchantReminder or settings.bankReminder))
end

-- The thresholds as percentages, the same in every locale.
local function LowThresholds()
	local values = {}
	for _, percent in ipairs(ns.RESTOCK_LOW_THRESHOLDS) do
		values[percent] = percent .. "%"
	end
	return values
end

-- The Gold Reserve amounts as the game writes money: the number and the gold coin.

local function GoldReserveAmounts()
	local values = {}
	for _, amount in ipairs(ns.GOLD_RESERVE_AMOUNTS) do
		values[amount] = amount .. ns.GOLD_ICON
	end
	return values
end

--[[
    A reminder's on/off toggle, and the Gold Reserve's; width defaults to the
    label cell its dropdown sits beside. It ends in ns.RefreshSettings, which
    also reveals or hides the rows that hang off it.
]]
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

--[[
    A reminder's How Much to Say row: the Simple/Verbose dropdown on an
    indented sub-row under its switch, hidden with the reminder off -- how
    loudly a silent reminder speaks is not a question. A change redraws the
    reminder's Example.
]]
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

--[[
    Page order: the description, the Restocker's master switch, then the Gold Reserve, Reminders and window
    sections, each laid out spacer, header, spacer, description, spacer, controls, all hidden while the switch is
    off. The Inventory Report has its own page under this one in the tree (Options/Inventory-Report/Options-Inventory-Report.lua).

    The three reminders are peers under their header. The merchant and bank
    reminders each take a full-width switch with its How Much to Say row
    indented under it; the in-town reminder adds its sound on a switch row of
    its own under that.
]]
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

			--[[
			    The Gold Reserve: the floor the merchant restock never spends
			    below. Built like a reminder row, the toggle with its dropdown on
			    the same line, and like theirs the dropdown hides while the
			    toggle is off.
			]]
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

			--[[
			    What counts as low, for all three reminders at once: one answer,
			    so the three can never disagree about the same bags. Above the
			    reminders it governs, and hidden with all three off.
			]]
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

			--[[
			    In-Town Reminders. Both the chat line and the sound fire on the
			    same signal -- the game's resting status, which turns on in inns
			    and cities -- and only when something on the Restock List is low
			    or out (Low Means Under). All three reminders ship on, in Simple
			    mode (Data/Default-Settings.lua).
			]]
			toggleRestockerRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_REMIND",
				"OPTIONS_RESTOCKER_REMIND_DESCRIPTION",
				"restockReminderChat",
				10,
				"full"
			),
			modeRestockerRemind = ReminderModeRow("restockReminderMode", "restockReminderChat", 11),

			--[[
			    The sound's switch, indented under the reminder it rides with,
			    with its speaker past the row's end (Kit.SubToggleRow,
			    Kit.SoundPreview).

			    Only the in-town reminder gets a sound: it arrives while you are
			    running around, where a chat line is easy to miss. The merchant
			    and bank reminders fire on a window you just closed, so you are
			    already looking at the screen.
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

			--[[
			    Closing-window reminders. Peers of the in-town one, not children
			    of it -- each answers a different moment, and turning off the
			    nudge you get walking into town should not silence the report
			    you get walking away from a vendor. Both stay quiet unless
			    something is low or out.
			]]
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

			--[[
			    Reset Position for each of the Restocker's two windows, captioned
			    as that window's position: forgets where it was dragged and moves
			    it back if open. Grayed while it has never been dragged.
			]]
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
