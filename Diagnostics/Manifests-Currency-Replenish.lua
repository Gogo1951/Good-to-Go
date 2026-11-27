local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

local function HasFunction(name)
	return function()
		return type(_G[name]) == "function"
	end
end

--------------------------------------------------------------------------------
-- API Checks
--------------------------------------------------------------------------------

-- GetMoney is in Manifests-Macros-for-Consumables.lua.
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	-- Each mail is cleared, given its gold and sent, one at a time.
	{ "ClearSendMail", HasFunction("ClearSendMail") },
	{ "SetSendMailMoney", HasFunction("SetSendMailMoney") },
	{ "SendMail", HasFunction("SendMail") },
	-- Postage comes off what Send Excess mails, and stops a run the gold can't cover.
	{ "GetSendMailPrice", HasFunction("GetSendMailPrice") },
	-- The bank's gold waiting in an alt's inbox counts as on its way.
	{ "GetInboxNumItems", HasFunction("GetInboxNumItems") },
	{ "GetInboxHeaderInfo", HasFunction("GetInboxHeaderInfo") },
	-- A bank is kept per realm and faction, since mail can cross neither.
	{ "GetRealmName", HasFunction("GetRealmName") },
	{ "UnitFactionGroup", HasFunction("UnitFactionGroup") },
	-- At a mailbox, asked of the interaction manager where the client has one, else MAIL_SHOW and MAIL_CLOSED.
	{
		"C_PlayerInteractionManager.IsInteractingWithNpcOfType (guarded)",
		function()
			return type(C_PlayerInteractionManager) == "table"
				and type(C_PlayerInteractionManager.IsInteractingWithNpcOfType) == "function"
		end,
	},
	{
		"Enum.PlayerInteractionType.MailInfo (guarded)",
		function()
			return type(Enum) == "table"
				and type(Enum.PlayerInteractionType) == "table"
				and Enum.PlayerInteractionType.MailInfo ~= nil
		end,
	},
	-- The tab and the window sit beside Blizzard's mail window, or TSM's in its place.
	{
		"MailFrame",
		function()
			return type(MailFrame) == "table" and type(MailFrame.HookScript) == "function"
		end,
	},
	{
		"Frame:GetSourceLocation (guarded, finds TSM's mail window)",
		function()
			return type(UIParent) == "table" and type(UIParent.GetSourceLocation) == "function"
		end,
	},
	-- Gold is written with thousands separators where the client has them; Forever has no GetCoinTextureString.
	{ "BreakUpLargeNumbers (guarded)", HasFunction("BreakUpLargeNumbers") },
	-- The gold cell's tooltip says how long ago an alt's gold was recorded.
	{ "SecondsToTime", HasFunction("SecondsToTime") },
})

--------------------------------------------------------------------------------
-- Currency Replenish Context
--------------------------------------------------------------------------------

local COPPER_PER_GOLD = 10000

--[[
    MIGRATION (remove after 2026-12-10)
    The test builds' mail subject, which the inbox read still counts as the
    bank's gold (Currency-Replenish-Records.lua).
]]
local OLD_MAIL_SUBJECT = "GtG: Gold"

local function MoneyText(copper)
	if type(copper) ~= "number" then
		return tostring(copper)
	end
	copper = math.floor(copper)
	local gold = math.floor(copper / COPPER_PER_GOLD)
	local silver = math.floor((copper % COPPER_PER_GOLD) / 100)
	return string.format("%dg %02ds %02dc", gold, silver, copper % 100)
end

local function AgoText(seen)
	if type(seen) ~= "number" then
		return tostring(seen)
	end
	return string.format("%d min ago", math.floor((time() - seen) / 60))
end

local function KeepsText(record)
	return record.keeps and (tostring(record.keeps) .. "g") or "off"
end

local function TransitText(record)
	if not record.transit then
		return "none"
	end
	return string.format("%s (recorded gold when sent %s)", MoneyText(record.transit), MoneyText(record.transitBase))
end

-- Reads the host as CR.TabHost does, without calling it: finding TSM's window hooks it.
local function AppendMailbox(lines, CR)
	local manager = C_PlayerInteractionManager
	local kind = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.MailInfo
	local managerAnswer = "(no interaction manager; MAIL_SHOW and MAIL_CLOSED decide)"
	if manager and manager.IsInteractingWithNpcOfType and kind then
		local ok, interacting = pcall(manager.IsInteractingWithNpcOfType, kind)
		managerAnswer = ok and YesNo(interacting) or ("error: " .. tostring(interacting))
	end
	lines[#lines + 1] =
		string.format("At a mailbox: %s // interaction manager says: %s", YesNo(CR.AtMailbox()), managerAnswer)

	local tsmVisible = "TSM not loaded"
	if TSM_API and TSM_API.IsUIVisible then
		local ok, visible = pcall(TSM_API.IsUIVisible, "MAILING")
		tsmVisible = ok and YesNo(visible == true) or ("error: " .. tostring(visible))
	end
	lines[#lines + 1] = string.format(
		"Blizzard mail window shown: %s // TSM mail window up: %s // TSM's window findable on this client: %s",
		YesNo(MailFrame and MailFrame:IsShown()),
		tsmVisible,
		YesNo(UIParent.GetSourceLocation ~= nil)
	)

	local tab = _G.GoodToGoCurrencyReplenishTab
	lines[#lines + 1] = string.format(
		"Tab: %s // window shown: %s // a send running: %s",
		tab and string.format("built, shown %s, lit %s", tostring(tab:IsShown()), tostring(tab:GetChecked()))
			or "not built yet",
		YesNo(CR.WindowShown()),
		YesNo(CR.Mailer and CR.Mailer.busy)
	)
end

-- Readable only at a mailbox, and past the first 50 more may be waiting.
local function AppendInbox(lines, CR)
	if not CR.AtMailbox() then
		lines[#lines + 1] = "Inbox: (not at a mailbox)"
		return
	end
	local shown, total = GetInboxNumItems()
	local waiting, count = 0, 0
	for index = 1, shown or 0 do
		local _, _, _, subject, money = GetInboxHeaderInfo(index)
		if (subject == CR.MAIL_SUBJECT or subject == OLD_MAIL_SUBJECT) and money and money > 0 then
			waiting = waiting + money
			count = count + 1
		end
	end
	lines[#lines + 1] = string.format(
		"Inbox: %s of %s mails loaded // the bank's gold waiting: %d mails, %s (subject %q)",
		tostring(shown),
		tostring(total),
		count,
		MoneyText(waiting),
		tostring(CR.MAIL_SUBJECT)
	)
end

-- In the order the window's SendState asks.
local function SendStateText(CR)
	if CR.Mailer.busy then
		return (CR.IsBank() and "Replenish" or "Send Excess") .. ", disabled: CURRENCY_REPLENISH_REASON_SENDING"
	end
	if not CR.BankRecord() then
		return "Send Excess, disabled: CURRENCY_REPLENISH_REASON_NO_BANK"
	end
	if CR.IsBank() then
		local sends, _, short = CR.ReplenishPlan()
		if #sends == 0 then
			return "Replenish, disabled: "
				.. (#short > 0 and "CURRENCY_REPLENISH_REASON_NO_GOLD" or "CURRENCY_REPLENISH_REASON_FULL")
		end
		return "Replenish, can be pressed"
	end
	local own = CR.OwnRecord()
	if not (own and own.keeps) then
		return "Send Excess, disabled: CURRENCY_REPLENISH_REASON_NO_KEEPS"
	end
	if CR.ExcessAmount() <= 0 then
		return "Send Excess, disabled: CURRENCY_REPLENISH_REASON_AT_KEEPS"
	end
	return "Send Excess, can be pressed"
end

local function AppendSends(lines, CR)
	local postage = GetSendMailPrice()
	lines[#lines + 1] =
		string.format("Postage per mail now: %s // your gold now: %s", MoneyText(postage), MoneyText(GetMoney()))
	lines[#lines + 1] = "Button: " .. SendStateText(CR)
	if not CR.BankRecord() then
		return
	end
	if not CR.IsBank() then
		lines[#lines + 1] = string.format("Send Excess would mail the bank: %s", MoneyText(CR.ExcessAmount()))
		return
	end
	local sends, total, short = CR.ReplenishPlan()
	lines[#lines + 1] = string.format("Replenish would send %d mails, %s in all", #sends, MoneyText(total))
	for _, send in ipairs(sends) do
		lines[#lines + 1] = string.format("  send %s to %s", MoneyText(send.amount), tostring(send.record.name))
	end
	for _, item in ipairs(short) do
		lines[#lines + 1] = string.format("  left short: %s by %s", tostring(item.record.name), MoneyText(item.amount))
	end
end

-- An alt's gold is from its last login; on its way is the bank's mail it hasn't been seen to take.
local function AppendRoster(lines, CR, settings)
	local roster = CR.Roster()
	local bankKey = CR.BankKey()
	local ownKey = CR.OwnKey()
	local others = CountKeys(settings.characters or {}) - #roster
	lines[#lines + 1] = string.format(
		"Characters it can mail (this realm and faction): %d // on other realms or factions: %d",
		#roster,
		others
	)
	for _, item in ipairs(roster) do
		local record = item.record
		local short = ns.GoldMath.Short(record)
		lines[#lines + 1] = string.format(
			"  %s%s%s (%s): gold %s, keeps %s, short %s, on its way %s, recorded %s",
			tostring(record.name),
			item.key == bankKey and " [bank]" or "",
			item.key == ownKey and " [you]" or "",
			tostring(record.class),
			MoneyText(record.money),
			KeepsText(record),
			MoneyText(short),
			TransitText(record),
			AgoText(record.seen)
		)
	end
end

function ns:BuildCurrencyReplenishContextReport()
	local lines = { GetClientHeader(), "" }
	local CR = ns.CurrencyReplenish
	local settings = CR and CR.Settings()
	if not settings then
		lines[#lines + 1] = "Currency Replenish: (database not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = string.format(
		"Currency Replenish: %s (off hides the tab and hears nothing but the login) // Skip Under 1g: %s",
		OnOff(settings.enabled),
		OnOff(settings.skipSmall)
	)
	lines[#lines + 1] = string.format(
		"Records: %d characters, %d banks (one per realm and faction)",
		CountKeys(settings.characters or {}),
		CountKeys(settings.banks or {})
	)

	local realm, faction = GetRealmName(), (UnitFactionGroup("player"))
	local factionKey = (realm or "") .. "|" .. (faction or "")
	local savedBank = settings.banks and settings.banks[factionKey]
	local bank = CR.BankRecord()
	lines[#lines + 1] = string.format(
		"This character: %s // realm %s, faction %s // is the bank: %s",
		tostring(CR.OwnKey()),
		tostring(realm),
		tostring(faction),
		YesNo(CR.IsBank())
	)
	lines[#lines + 1] = string.format(
		"Bank for %q: %s%s",
		factionKey,
		bank and tostring(bank.name) or "(none picked)",
		savedBank and not bank and string.format(" (saved as %s, which has no record)", tostring(savedBank)) or ""
	)
	local own = CR.OwnRecord()
	if own then
		lines[#lines + 1] = string.format(
			"Your record: gold %s, keeps %s, on its way %s, recorded %s",
			MoneyText(own.money),
			KeepsText(own),
			TransitText(own),
			AgoText(own.seen)
		)
	else
		lines[#lines + 1] = "Your record: (none yet; written at login and on a gold change while the feature is on)"
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Mailbox --"
	AppendMailbox(lines, CR)
	AppendInbox(lines, CR)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- What a press would send --"
	AppendSends(lines, CR)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Characters --"
	AppendRoster(lines, CR, settings)

	return (table.concat(lines, "\n"):gsub("|", "||"))
end
