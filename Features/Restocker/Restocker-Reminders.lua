local _, ns = ...
local L = ns.L

--[[
    What the reminders report, split out of the shortfall list
    (ns.BuildRestockShortfallList, every short row, Buy on or off): out is every row the bags hold none of, low every row they hold some of but
    less than the threshold's share of its amount (restockLowThreshold, one of
    ns.RESTOCK_LOW_THRESHOLDS). A row at or above the line is in neither, so it
    is never mentioned -- topping off is the merchant restock's job, not a nag.

    Whole numbers only: under 80% of 20 is have * 100 < 20 * 80, so 15 is low
    and 16 is not, with no rounding to argue about. Both lists keep the
    shortfall list's order, by name.
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

-- The split for the reminders, at the account's threshold.
function ns.BuildRestockReminderLists()
	local settings = ns.restockSettings
	return ns.SplitRestockShortfall(ns.BuildRestockShortfallList(), settings and settings.restockLowThreshold)
end

--[[
    The counts sentence every reminder's headline is built on: "You're out of 4
    items, and low on 3." Out leads, because an empty slot is the one that bites
    first. The merchant and bank reminders print the "still" form on its own,
    since you have just shopped; the in-town reminder puts the plain form after
    RESTOCKER_TOWN_REMINDER. Only the out count carries a noun when both are
    present, so there are two of those strings, not four.
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

-- The in-town reminder's headline: the nudge, then the counts.
function ns.RestockTownHeadline(outCount, lowCount)
	return string.format(L["RESTOCKER_TOWN_REMINDER"], ns.RestockReminderCounts(outCount, lowCount, false))
end

-- The merchant and bank reminders' headline, printed as you leave.
function ns.RestockClosingHeadline(outCount, lowCount)
	return ns.RestockReminderCounts(outCount, lowCount, true)
end

--[[
    A reminder's print bodies: the headline, then in verbose mode a line per
    item it counted, out first and then low -- the same rows the headline
    counts, so the two never disagree. The options panel's Examples draw
    through it too.
]]
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

-- Print a reminder. Callers pass the lists they already split, so nothing is counted twice.
function ns.PrintRestockShortfall(headline, mode, out, low)
	for _, line in ipairs(ns.BuildRestockShortfallLines(headline, mode, out, low)) do
		ns:PrintMessage(line)
	end
end

--[[
    The Restock window's status line (Restocker-Window-Footer.lua): how many
    rows are short, Buy on or off, and how many of those a merchant would be
    asked for ("Short on 3 items, 2 to buy."), or, with none to buy, that the
    rest come from the bank. The counts are of rows, not of missing units.
    Every short row counts here, whatever the reminders' threshold: the window
    is the full picture, the reminders the nudge.
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
