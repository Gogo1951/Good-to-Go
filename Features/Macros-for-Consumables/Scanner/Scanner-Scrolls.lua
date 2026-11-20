local _, ns = ...

--[[
    Scanner-Scrolls -- picks the best scroll in the bags for each enabled
    scroll type and lists the scrolls whose buff the player still lacks. Whether a scroll buff is already covered is
    ns.HasScrollBuff in Scanner-Auras.lua.
]]

--------------------------------------------------------------------------------
-- Scroll Selection
--------------------------------------------------------------------------------

--[[
    Finds the best scroll for a type in the bags: the strongest one carried.
    Scroll entries: {[1] itemID, [2] buffID, [3] requiredLevel, [4] amount,
    [5] class token or nil}. The required level only orders the list
    (Scanner-Auras.lua sorts it highest first); it never gates a scroll, so
    a scroll in the bags is a scroll Buff Duty offers, at any level. A scroll
    with a class token is skipped for every other class, since anyone can
    carry one but only that class can read it. Returns itemID, amount (or
    nil, nil if nothing usable is found). Diagnostics reads the same pick.
]]
function ns.FindBestScroll(scrollType, bagItemCounts)
	local data = ns.SCROLL_DATA and ns.SCROLL_DATA[scrollType]
	if not data or not bagItemCounts then
		return nil, nil
	end

	local _, playerClass = UnitClass("player")
	for _, entry in ipairs(data.items or {}) do
		--[[
		    Scrolls never pass the scanner's ignore filter (callers hand raw
		    bag counts), so this honors the Ignore List itself.
		]]
		if (entry[5] == nil or entry[5] == playerClass) and not ns.IsIgnored(entry[1]) then
			if bagItemCounts[entry[1]] and bagItemCounts[entry[1]] > 0 then
				return entry[1], entry[4]
			end
		end
	end

	return nil, nil
end

--[[
    The scrolls you could read now: for each type Buff Duty's Self-Buffs page
    ticks (scrollTypes), the best one in the bags whose buff you still lack, in
    ns.SCROLL_CHECK_ORDER. nil when there are none. currentSnapshot is a
    player snapshot the caller already took, when it has one. The Readiness
    Report and Diagnostics ask; Buff Duty's window reads the same pieces per
    type (Buff-Duty-Self.lua).
]]
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
