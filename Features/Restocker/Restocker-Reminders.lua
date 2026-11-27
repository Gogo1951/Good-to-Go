local _, ns = ...
local L = ns.L

--[[
    A row at or above the threshold is in neither list: topping off is the
    merchant's job, not a nag. Whole-number math (15 of 20 is under 80%, 16 is
    not), so there is no rounding.
]]
function ns.SplitRestockShortfall(groceries, threshold)
	threshold = threshold or 80
	local out, low = {}, {}
	for _, entry in ipairs(groceries) do
		if entry.have <= 0 then
			out[#out + 1] = entry
		elseif entry.have * 100 < entry.wanted * threshold then
			low[#low + 1] = entry
		end
	end
	return out, low
end

function ns.BuildRestockReminderLists()
	local settings = ns.restockSettings
	return ns.SplitRestockShortfall(ns.BuildRestockShortfallList(), settings and settings.restockLowThreshold)
end

--[[
    "You're out of 4 items, and low on 3." Out leads, as an empty slot bites
    first. Only the out count carries a noun when both are present, so there are
    two "both" strings, not four.
]]
local COUNT_KEYS = {
	[false] = {
		lowOne = "RESTOCKER_LOW_ONE",
		lowMany = "RESTOCKER_LOW_MANY",
		outOne = "RESTOCKER_OUT_ONE",
		outMany = "RESTOCKER_OUT_MANY",
		bothOne = "RESTOCKER_OUT_AND_LOW_ONE",
		bothMany = "RESTOCKER_OUT_AND_LOW_MANY",
	},
	[true] = {
		lowOne = "RESTOCKER_STILL_LOW_ONE",
		lowMany = "RESTOCKER_STILL_LOW_MANY",
		outOne = "RESTOCKER_STILL_OUT_ONE",
		outMany = "RESTOCKER_STILL_OUT_MANY",
		bothOne = "RESTOCKER_STILL_OUT_AND_LOW_ONE",
		bothMany = "RESTOCKER_STILL_OUT_AND_LOW_MANY",
	},
}

function ns.RestockReminderCounts(outCount, lowCount, still)
	local keys = COUNT_KEYS[still and true or false]
	if outCount > 0 and lowCount > 0 then
		if outCount == 1 then
			return string.format(L[keys.bothOne], lowCount)
		end
		return string.format(L[keys.bothMany], outCount, lowCount)
	end
	if outCount > 0 then
		return outCount == 1 and L[keys.outOne] or string.format(L[keys.outMany], outCount)
	end
	return lowCount == 1 and L[keys.lowOne] or string.format(L[keys.lowMany], lowCount)
end

function ns.RestockTownHeadline(outCount, lowCount)
	return string.format(L["RESTOCKER_TOWN_REMINDER"], ns.RestockReminderCounts(outCount, lowCount, false))
end

-- The merchant and bank reminders print the "still" form, since you have just shopped.
function ns.RestockClosingHeadline(outCount, lowCount)
	return ns.RestockReminderCounts(outCount, lowCount, true)
end

-- Verbose lists the same rows the headline counts, so the two never disagree.
function ns.BuildRestockShortfallLines(headline, mode, out, low)
	local lines = { headline }
	if mode == ns.REMINDER_VERBOSE then
		for _, group in ipairs({ out, low }) do
			for _, entry in ipairs(group) do
				lines[#lines + 1] = string.format(
					L["RESTOCKER_REMINDER_ITEM"],
					entry.have,
					entry.wanted,
					ns.GetItemHyperlink(entry.itemID)
				)
			end
		end
	end
	return lines
end

function ns.PrintRestockShortfall(headline, mode, out, low)
	for _, line in ipairs(ns.BuildRestockShortfallLines(headline, mode, out, low)) do
		ns:PrintMessage(line)
	end
end

--[[
    The window's status line counts rows, not units, and every short row
    whatever the reminders' threshold: the window is the full picture, the
    reminders the nudge.
]]
function ns.RestockShortfallHeadline(short, buy)
	if buy == 0 then
		if short == 1 then
			return L["RESTOCKER_SHORT_ONE_NONE_TO_BUY"]
		end
		return string.format(L["RESTOCKER_SHORT_NONE_TO_BUY"], short)
	end
	if short == 1 then
		return L["RESTOCKER_SHORT_ONE_BUY"]
	end
	return string.format(L["RESTOCKER_SHORT_BUY"], short, buy)
end
