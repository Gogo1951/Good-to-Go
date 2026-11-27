local _, ns = ...

--[[
    Pure: every amount is copper and handed in, so Tests/Run.lua runs this file
    with no game around it.

    A character's record (Currency-Replenish-Records.lua) is the shape read here:
      keeps        whole gold it keeps; nil leaves it out of everything
      money        copper, as last recorded on that character
      transit      copper the bank mailed it that it hasn't been seen to receive
      transitBase  its recorded money when that mail went out
]]

local GoldMath = {}
ns.GoldMath = GoldMath

local COPPER_PER_GOLD = 10000
GoldMath.COPPER_PER_GOLD = COPPER_PER_GOLD

-- The Skip Under 1g switch's line: a top-up smaller than this waits.
GoldMath.SMALLEST_TOP_UP = COPPER_PER_GOLD

function GoldMath.Excess(money, keeps, postage)
	if not keeps then
		return 0
	end
	local amount = (money or 0) - keeps * COPPER_PER_GOLD - (postage or 0)
	return amount > 0 and amount or 0
end

function GoldMath.Short(record)
	if not record.keeps then
		return 0
	end
	local short = record.keeps * COPPER_PER_GOLD - (record.money or 0) - (record.transit or 0)
	return short > 0 and short or 0
end

-- Fills the list top to bottom, never skipping ahead: once one doesn't fit, it and every short one after are left short.
function GoldMath.Plan(records, bankMoney, bankKeeps, postage, skipSmall)
	local room = (bankMoney or 0) - (bankKeeps or 0) * COPPER_PER_GOLD
	postage = postage or 0
	local sends, short, total = {}, {}, 0
	local ranOut = false
	for _, record in ipairs(records) do
		local need = GoldMath.Short(record)
		if need > 0 and not (skipSmall and need < GoldMath.SMALLEST_TOP_UP) then
			if not ranOut and room - postage >= need then
				room = room - need - postage
				total = total + need
				sends[#sends + 1] = { record = record, amount = need }
			else
				ranOut = true
				short[#short + 1] = { record = record, amount = need }
			end
		end
	end
	return sends, total, short
end

-- The first mail on its way notes the recorded money, so arriving gold can be told from what it had.
function GoldMath.AddTransit(record, amount)
	if not record.transit then
		record.transitBase = record.money or 0
		record.transit = 0
	end
	record.transit = record.transit + amount
end

function GoldMath.SettleTransit(record, money)
	if record.transit and money >= (record.transitBase or 0) + record.transit then
		record.transit = nil
		record.transitBase = nil
		return true
	end
	return false
end

-- The bank's mails still in its inbox: whatever is gone was taken, so what waits is the gold on its way from now.
function GoldMath.SetWaiting(record, waiting, money)
	if waiting > 0 then
		record.transit = waiting
		record.transitBase = money
	else
		record.transit = nil
		record.transitBase = nil
	end
end
