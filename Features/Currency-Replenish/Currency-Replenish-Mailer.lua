local _, ns = ...
local L = ns.L

--[[
    The game can't send mail in a loop: the next waits for MAIL_SUCCESS,
    MAIL_FAILED or a mail error on screen. No answer in RESULT_TIMEOUT counts as
    a failure, so a lost answer can't hold the button. Each bank mail marks its
    gold on its way (GoldMath.AddTransit), so a second Replenish before the alt
    logs in sends it nothing more.
]]

local CR = ns.CurrencyReplenish
local GoldMath = ns.GoldMath

local RESULT_TIMEOUT = 30
-- A short pause before the next mail, so the game has finished with the last one.
local NEXT_MAIL_DELAY = 0.5

local Mailer = { busy = false }
CR.Mailer = Mailer

local queue, position, finish
local awaiting = false
-- Raised on every send, so a timer or a pause left over from an earlier mail does nothing.
local run = 0

local function Done(failure)
	CR.HearSendResults(false)
	Mailer.busy = false
	awaiting = false
	local sent = {}
	for index = 1, position - 1 do
		sent[#sent + 1] = queue[index]
	end
	local failed = failure and queue[position] or nil
	local callback = finish
	queue, finish = nil, nil
	if callback then
		callback(sent, failed, failure)
	end
	CR.Changed()
end

local function SendNext()
	local job = queue[position]
	if not job then
		return Done(nil)
	end
	if not CR.AtMailbox() then
		return Done("mailbox")
	end
	if GetMoney() < job.amount + GetSendMailPrice() then
		return Done("gold")
	end
	pcall(ClearSendMail)
	pcall(SetSendMailMoney, job.amount)
	run = run + 1
	local token = run
	awaiting = true
	if not pcall(SendMail, job.recipient, CR.MAIL_SUBJECT, "") then
		return Done("failed")
	end
	C_Timer.After(RESULT_TIMEOUT, function()
		if awaiting and run == token then
			Done("failed")
		end
	end)
end

local function Result(ok)
	if not awaiting then
		return
	end
	awaiting = false
	if not ok then
		return Done("failed")
	end
	local job = queue[position]
	if job.onSent then
		job.onSent(job)
	end
	position = position + 1
	local token = run
	C_Timer.After(NEXT_MAIL_DELAY, function()
		if Mailer.busy and run == token then
			SendNext()
		end
	end)
end

-- onFinish(sent, failed, reason): failed is nil when all went; reason is "failed", "mailbox" or "gold".
function Mailer.Start(jobs, onFinish)
	if Mailer.busy or #jobs == 0 then
		return
	end
	Mailer.busy = true
	queue, position, finish = jobs, 1, onFinish
	CR.HearSendResults(true)
	CR.Changed()
	SendNext()
end

CR.On("MAIL_SUCCESS", function()
	Result(true)
end)

CR.On("MAIL_FAILED", function()
	Result(false)
end)

--[[
    Gathered from the client's ERR_MAIL strings, so they match in every
    language. One with a %s arrives filled in and could never match.
]]
local mailErrors

local function IsMailError(message)
	if not mailErrors then
		mailErrors = {}
		for name, value in pairs(_G) do
			if
				type(name) == "string"
				and type(value) == "string"
				and name:find("^ERR_MAIL")
				and not value:find("%%")
			then
				mailErrors[value] = true
			end
		end
		local wrongFaction = _G.ERR_PLAYER_WRONG_FACTION
		if type(wrongFaction) == "string" and not wrongFaction:find("%%") then
			mailErrors[wrongFaction] = true
		end
	end
	return mailErrors[message] == true
end

-- A refusal can come only as an error on screen, with no MAIL_FAILED after it.
CR.On("UI_ERROR_MESSAGE", function(_, message)
	if awaiting and type(message) == "string" and IsMailError(message) then
		Result(false)
	end
end)

--------------------------------------------------------------------------------
-- Chat
--------------------------------------------------------------------------------

local Money = CR.Money

local function Name(record)
	return ns.ClassColoredName(record.name or "?", record.class)
end

local function PrintSent(sent)
	for _, job in ipairs(sent) do
		ns:PrintMessage(L["CURRENCY_REPLENISH_SENT"]:format(Money(job.amount), Name(job.record)))
	end
end

local STOP_REASONS = {
	failed = "CURRENCY_REPLENISH_STOPPED_FAILED",
	mailbox = "CURRENCY_REPLENISH_STOPPED_MAILBOX",
	gold = "CURRENCY_REPLENISH_STOPPED_GOLD",
}

local function PrintStopped(failed, reason)
	if failed then
		ns:PrintMessage(L[STOP_REASONS[reason] or STOP_REASONS.failed]:format(Name(failed.record)))
	end
end

-- "Out of gold. Selwyn is 80g short, Tamsin is 84g 60s short."
local function PrintShort(short)
	if #short == 0 then
		return
	end
	local parts = {}
	for index, item in ipairs(short) do
		parts[index] = L["CURRENCY_REPLENISH_SHORT_BY"]:format(Name(item.record), Money(item.amount))
	end
	ns:PrintMessage(L["CURRENCY_REPLENISH_OUT_OF_GOLD"]:format(table.concat(parts, ", ")))
end

--------------------------------------------------------------------------------
-- The Two Sends
--------------------------------------------------------------------------------

function CR.ExcessAmount()
	local own = CR.OwnRecord()
	if not own then
		return 0
	end
	return GoldMath.Excess(GetMoney(), own.keeps, GetSendMailPrice())
end

function CR.SendExcess()
	local bank = CR.BankRecord()
	if Mailer.busy or not bank or CR.IsBank() then
		return
	end
	local amount = CR.ExcessAmount()
	if amount <= 0 then
		return
	end
	Mailer.Start({ { recipient = bank.name, record = bank, amount = amount } }, function(sent, failed, reason)
		PrintSent(sent)
		PrintStopped(failed, reason)
	end)
end

function CR.ReplenishPlan()
	local settings = CR.Settings()
	local bank = CR.BankRecord()
	return GoldMath.Plan(
		CR.ReplenishRecords(),
		GetMoney(),
		bank and bank.keeps,
		GetSendMailPrice(),
		settings and settings.skipSmall
	)
end

-- Printed once the run is over, so the total is what really went.
function CR.Replenish()
	if Mailer.busy or not CR.IsBank() then
		return
	end
	local sends, _, short = CR.ReplenishPlan()
	if #sends == 0 then
		PrintShort(short)
		return
	end
	local jobs = {}
	for index, send in ipairs(sends) do
		jobs[index] = {
			recipient = send.record.name,
			record = send.record,
			amount = send.amount,
			onSent = function(job)
				GoldMath.AddTransit(job.record, job.amount)
			end,
		}
	end
	Mailer.Start(jobs, function(sent, failed, reason)
		local total = 0
		for _, job in ipairs(sent) do
			total = total + job.amount
		end
		if #sent > 0 then
			local key = #sent == 1 and "CURRENCY_REPLENISH_REPLENISHED_ONE" or "CURRENCY_REPLENISH_REPLENISHED"
			ns:PrintMessage(L[key]:format(#sent, Money(total)))
		end
		PrintSent(sent)
		PrintStopped(failed, reason)
		if not failed then
			PrintShort(short)
		end
	end)
end
