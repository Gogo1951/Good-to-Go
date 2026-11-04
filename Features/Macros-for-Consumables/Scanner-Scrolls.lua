local _, ns = ...

--[[
    Scanner-Scrolls -- picks the best scroll in the bags for each enabled
    scroll type and resolves the scroll override list: the scrolls whose buff
    the player still lacks. Whether a scroll buff is already covered is
    ns.HasScrollBuff in Scanner-Auras.lua.
]]

--------------------------------------------------------------------------------
-- Scroll Selection
--------------------------------------------------------------------------------

--[[
    Finds the best available scroll for a type from bag contents.
    Scroll entries: {[1] itemID, [2] buffID, [3] requiredLevel, [4] amount,
    [5] class token or nil}; a scroll with a class token is skipped for every
    other class, since anyone can carry one but only that class can read it.
    Returns itemID, amount (or nil, nil if nothing usable is found).
]]
local function FindBestScroll(scrollType, bagItemCounts)
	if not ns.SCROLL_DATA[scrollType] then
		return nil, nil
	end

	local playerLevel = ns.cachedPlayerLevel or 1
	local _, playerClass = UnitClass("player")
	local items = ns.SCROLL_DATA[scrollType].items
	for _, entry in ipairs(items) do
		--[[
		    The scroll override path never passes the scanner's ignore filter
		    (it reads the raw bag counts), so it honors the Ignore List itself.
		]]
		if entry[3] <= playerLevel and (entry[5] == nil or entry[5] == playerClass) and not ns.IsIgnored(entry[1]) then
			if bagItemCounts[entry[1]] and bagItemCounts[entry[1]] > 0 then
				return entry[1], entry[4]
			end
		end
	end

	return nil, nil
end

--[[
    Written by ScanBags on every rescan (forced nil in a PvP Arena); the Food
    macro's scroll-only mode, the Readiness Report and Diagnostics read it.
]]
ns.scrollOverrideIDs = nil

--[[
    Returns an ordered list of scroll item IDs the player should use, or nil
    if none apply. Order follows ns.SCROLL_CHECK_ORDER, which is the order the
    scroll-only body fires them in. currentSnapshot is the player snapshot the
    caller already took this pass, when it has one.
]]
function ns.FindScrollOverrides(bagItemCounts, currentSnapshot)
	local settings = ns.db and ns.db.profile
	if not settings or not settings.useScrolls then
		return nil
	end
	if not ns.IsModeActive(settings.scrollsMode) then
		return nil
	end

	local scrollTypes = settings.scrollTypes
	if not scrollTypes then
		return nil
	end

	local results

	--[[
	    One aura walk for the whole set, and none at all when the bag scan
	    already took one. Letting each ns.HasScrollBuff call take its own
	    snapshot re-reads the player's 40 aura slots once per enabled scroll
	    type, on a path that re-runs with every bag scan.
	]]
	currentSnapshot = currentSnapshot or ns.GetPlayerBuffSnapshot()

	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		if scrollTypes[scrollType] then
			local scrollItemID, scrollAmount = FindBestScroll(scrollType, bagItemCounts)
			if scrollItemID and not ns.HasScrollBuff(scrollType, scrollAmount, currentSnapshot) then
				results = results or {}
				results[#results + 1] = scrollItemID
			end
		end
	end

	return results
end
