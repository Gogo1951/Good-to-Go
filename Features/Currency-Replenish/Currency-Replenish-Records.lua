local _, ns = ...

--[[
    Account-wide, so the bank sees an alt's gold while the alt is logged out. A
    bank is kept per realm and faction, since mail crosses neither.
]]

local GoldMath = ns.GoldMath

local CR = {}
ns.CurrencyReplenish = CR

local MODULE = "CurrencyReplenish"

--[[
    How an inbox tells the bank's gold from other mail. A fixed tag, never
    translated, so a client in another language still finds it.
]]
CR.MAIL_SUBJECT = "Currency Replenish // GtG"

--[[
    MIGRATION (remove after 2026-12-10)
    The test builds' subject, so gold the bank mailed under it still counts
    as on its way until it's taken.
]]
local OLD_MAIL_SUBJECT = "GtG: Gold"

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- Run in the order added.
local listeners = {}

function CR.On(event, handler)
	listeners[event] = listeners[event] or {}
	table.insert(listeners[event], handler)
end

ns.RegisterEventModule(MODULE, function(event, ...)
	for _, handler in ipairs(listeners[event] or {}) do
		handler(...)
	end
end)

-- Heard only while the feature is on; the send events only during a send.
local FEATURE_EVENTS = { "PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "MAIL_SHOW", "MAIL_CLOSED", "MAIL_INBOX_UPDATE" }
local SEND_EVENTS = { "MAIL_SUCCESS", "MAIL_FAILED", "UI_ERROR_MESSAGE" }

function CR.HearSendResults(enabled)
	for _, event in ipairs(SEND_EVENTS) do
		ns.SetModuleEvent(MODULE, event, enabled)
	end
end

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

function CR.Settings()
	return ns.db and ns.db.global.currencyReplenish
end

function CR.IsEnabled()
	local settings = CR.Settings()
	return settings ~= nil and settings.enabled == true
end

function CR.Changed()
	if CR.onChange then
		CR.onChange()
	end
end

--------------------------------------------------------------------------------
-- Money Text
--------------------------------------------------------------------------------

local COIN_ICONS = {
	"|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t",
	"|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t",
	"|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t",
}

--[[
    1 [g] 00 [s] 00 [c], 28 [s] 92 [c], 05 [c]. Built here because Forever has
    no GetCoinTextureString.
]]
function CR.Money(copper)
	copper = math.floor(copper or 0)
	local gold = math.floor(copper / GoldMath.COPPER_PER_GOLD)
	local silver = math.floor((copper % GoldMath.COPPER_PER_GOLD) / 100)
	local cents = copper % 100
	if gold > 0 then
		local number = BreakUpLargeNumbers and BreakUpLargeNumbers(gold) or tostring(gold)
		return ("%s%s %02d%s %02d%s"):format(number, COIN_ICONS[1], silver, COIN_ICONS[2], cents, COIN_ICONS[3])
	elseif silver > 0 then
		return ("%d%s %02d%s"):format(silver, COIN_ICONS[2], cents, COIN_ICONS[3])
	end
	return ("%02d%s"):format(cents, COIN_ICONS[3])
end

--------------------------------------------------------------------------------
-- This Character
--------------------------------------------------------------------------------

local function FactionKey(realm, faction)
	return (realm or "") .. "|" .. (faction or "")
end

local function OwnFactionKey()
	return FactionKey(GetRealmName(), (UnitFactionGroup("player")))
end

function CR.OwnKey()
	return ns.GetCharacterKey()
end

local function Record()
	local settings = CR.Settings()
	if not settings then
		return nil
	end
	local key = CR.OwnKey()
	local record = settings.characters[key] or {}
	settings.characters[key] = record
	local _, classToken = UnitClass("player")
	record.name = ns.GetPlayerFullName()
	record.realm = GetRealmName()
	record.class = classToken
	record.faction = (UnitFactionGroup("player"))
	record.money = GetMoney()
	record.seen = time()
	GoldMath.SettleTransit(record, record.money)
	return record
end
CR.Record = Record

function CR.OwnRecord()
	local settings = CR.Settings()
	return settings and settings.characters[CR.OwnKey()]
end

--------------------------------------------------------------------------------
-- The Bank and the List
--------------------------------------------------------------------------------

-- Nil when none is picked, or its record is gone.
function CR.BankKey()
	local settings = CR.Settings()
	local key = settings and settings.banks[OwnFactionKey()]
	if key and settings.characters[key] then
		return key
	end
	return nil
end

function CR.BankRecord()
	local key = CR.BankKey()
	return key and CR.Settings().characters[key] or nil
end

function CR.IsBank()
	return CR.BankKey() == CR.OwnKey()
end

-- The bank's own Target Amount is Off: it is the one sending.
function CR.SetBank(key)
	local settings = CR.Settings()
	settings.banks[OwnFactionKey()] = key
	local record = settings.characters[key]
	if record then
		record.keeps = nil
	end
	CR.Changed()
end

-- Whole gold, or nil to leave the character out.
function CR.SetKeeps(key, gold)
	local record = CR.Settings().characters[key]
	if record then
		record.keeps = gold
		CR.Changed()
	end
end

-- Also clears its place as the bank wherever it was one.
function CR.RemoveCharacter(key)
	local settings = CR.Settings()
	if not (settings and settings.characters[key]) then
		return
	end
	settings.characters[key] = nil
	for factionKey, bankKey in pairs(settings.banks) do
		if bankKey == key then
			settings.banks[factionKey] = nil
		end
	end
	CR.Changed()
end

local function SortName(record)
	return (record.name or ""):lower()
end

-- This realm and faction only, the ones the bank can mail; A to Z, each { key, record }.
function CR.Roster()
	local settings = CR.Settings()
	if not settings then
		return {}
	end
	local realm, faction = GetRealmName(), (UnitFactionGroup("player"))
	local list = {}
	for key, record in pairs(settings.characters) do
		if type(record) == "table" and record.realm == realm and record.faction == faction then
			list[#list + 1] = { key = key, record = record }
		end
	end
	table.sort(list, function(a, b)
		local nameA, nameB = SortName(a.record), SortName(b.record)
		if nameA ~= nameB then
			return nameA < nameB
		end
		return a.key < b.key
	end)
	return list
end

function CR.ReplenishRecords()
	local bankKey = CR.BankKey()
	local records = {}
	for _, item in ipairs(CR.Roster()) do
		if item.key ~= bankKey then
			records[#records + 1] = item.record
		end
	end
	return records
end

--------------------------------------------------------------------------------
-- The Mailbox
--------------------------------------------------------------------------------

-- Set by MAIL_SHOW and MAIL_CLOSED, for a client whose interaction manager can't say.
local mailboxOpen = false

-- Never the mail window's visibility: TSM and the Who panel hide it.
function CR.AtMailbox()
	local manager = C_PlayerInteractionManager
	local kind = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.MailInfo
	if manager and manager.IsInteractingWithNpcOfType and kind then
		local ok, interacting = pcall(manager.IsInteractingWithNpcOfType, kind)
		if ok then
			return interacting and true or false
		end
	end
	return mailboxOpen
end

-- Past the 50 mails the client loads, more may wait, so the gold on its way is then only raised.
local function ReadInbox()
	local record = CR.OwnRecord()
	if not record or CR.IsBank() then
		return
	end
	local shown, total = GetInboxNumItems()
	local waiting = 0
	for index = 1, shown or 0 do
		local _, _, _, subject, money = GetInboxHeaderInfo(index)
		if (subject == CR.MAIL_SUBJECT or subject == OLD_MAIL_SUBJECT) and money and money > 0 then
			waiting = waiting + money
		end
	end
	if (total or 0) > (shown or 0) and waiting < (record.transit or 0) then
		return
	end
	GoldMath.SetWaiting(record, waiting, GetMoney())
	CR.Changed()
end

--------------------------------------------------------------------------------
-- Wiring
--------------------------------------------------------------------------------

function ns.SyncCurrencyReplenishEvents()
	local enabled = CR.IsEnabled()
	for _, event in ipairs(FEATURE_EVENTS) do
		ns.SetModuleEvent(MODULE, event, enabled)
	end
	if enabled then
		Record()
	end
end

CR.On("PLAYER_LOGIN", ns.SyncCurrencyReplenishEvents)

CR.On("PLAYER_ENTERING_WORLD", function()
	Record()
	CR.Changed()
end)

CR.On("PLAYER_MONEY", function()
	Record()
	CR.Changed()
end)

CR.On("MAIL_SHOW", function()
	mailboxOpen = true
end)

CR.On("MAIL_CLOSED", function()
	mailboxOpen = false
end)

CR.On("MAIL_INBOX_UPDATE", ReadInbox)

ns.SetModuleEvent(MODULE, "PLAYER_LOGIN", true)
