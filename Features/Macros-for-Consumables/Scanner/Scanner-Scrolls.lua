local _, ns = ...

--------------------------------------------------------------------------------
-- Scroll Selection
--------------------------------------------------------------------------------

--[[
    Entry: {itemID, buffID, requiredLevel, amount, class token or nil}. The
    level only orders the list, never gates it. A class scroll is skipped for
    other classes: anyone can carry it, only its class can read it.
]]
function ns.FindBestScroll(scrollType, bagItemCounts)
	local data = ns.SCROLL_DATA and ns.SCROLL_DATA[scrollType]
	if not data or not bagItemCounts then
		return nil, nil
	end

	local _, playerClass = UnitClass("player")
	for _, entry in ipairs(data.items or {}) do
		-- Callers hand raw bag counts, which skip the scanner's ignore filter.
		if (entry[5] == nil or entry[5] == playerClass) and not ns.IsIgnored(entry[1]) then
			if bagItemCounts[entry[1]] and bagItemCounts[entry[1]] > 0 then
				return entry[1], entry[4]
			end
		end
	end

	return nil, nil
end

function ns.FindMissingScrolls(bagItemCounts, currentSnapshot)
	local settings = ns.db and ns.db.profile
	local scrollTypes = settings and settings.scrollTypes
	if not scrollTypes or not bagItemCounts then
		return nil
	end

	local results
	-- One aura walk for the whole set, rather than one per scroll type.
	currentSnapshot = currentSnapshot or ns.GetPlayerBuffSnapshot()

	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER or {}) do
		if scrollTypes[scrollType] then
			local scrollItemID, scrollAmount = ns.FindBestScroll(scrollType, bagItemCounts)
			if scrollItemID and not ns.HasScrollBuff(scrollType, scrollAmount, currentSnapshot) then
				results = results or {}
				results[#results + 1] = scrollItemID
			end
		end
	end

	return results
end
