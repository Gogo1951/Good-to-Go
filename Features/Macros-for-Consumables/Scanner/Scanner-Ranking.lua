local _, ns = ...

--[[
    Scanner-Ranking -- how the bag scan (Features/Macros-for-Consumables/Scanner/Scanner-Inventory.lua)
    picks between items: the best item per macro category, the RANKING_PRIORITY
    tiebreak ladder and the ranked candidate lists of the multi-use macros.
    Shared with the scan as ns.ScanRanking, to which Scanner-Diagnostics.lua
    adds the candidates Diagnostics keeps.
]]

--------------------------------------------------------------------------------
-- Best Item Tracking
--------------------------------------------------------------------------------

--[[
    Per-category winner records and ranked-candidate lists, built from the
    definition registry (ns.REGISTERED_MACRO_DEFINITIONS) instead of hardcoded here:
    every registered definition with an itemTypes set gets a winner record,
    and ranked definitions also get a topIDs list plus a candidate
    collector. Definitions register from Features/Macros-for-Consumables/Macros/*.lua, which load
    after this file, so the tables are built lazily on the first scan
    (BuildSelectionTables below) — every scan happens long after load.
]]
local best = {}

--[[
    Expose the scanner's live best table for diagnostics. ScanBags resets and
    repopulates these entries in place every pass, so the reference always
    reflects the last scan. Read-only for consumers (Diagnostics' context
    report); the scanner itself owns all writes. This is what lets the context
    report show the per-category winner for every type, not just bestFoodID.
]]
ns.bestSelection = best

local rankedCandidates = {}

local function ResetBest(entry)
	entry.id = nil
	entry.value = 0
	entry.price = 0
	entry.count = 0
	entry.link = nil
	entry.isBuffFood = false
	entry.isPercent = false
	entry.isHybrid = false
	entry.isConjured = false
	entry.hasZones = false
	entry.isSoulbound = false
	entry.isHighStack = false
	entry.isOffRestockList = false
	if entry.topIDs then
		wipe(entry.topIDs)
	end
end

local selectionTablesBuilt = false

local function BuildSelectionTables()
	if selectionTablesBuilt then
		return
	end
	selectionTablesBuilt = true
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		if definition.itemTypes then
			local entry = {}
			if definition.ranked then
				entry.topIDs = {}
				rankedCandidates[definition.typeName] = {}
			end
			ResetBest(entry)
			best[definition.typeName] = entry
		end
	end
end

--------------------------------------------------------------------------------
-- Comparison Logic
--------------------------------------------------------------------------------

--[[
    RANKING_PRIORITY is the single source of truth for how consumables are
    ranked. Both comparator forms — IsBetter's single-winner test and the
    ranked lists' pairwise sort (CompareRankedCandidates) — are generated from
    this one ordered list by CompareRecords, so reordering a step here is the
    only edit needed to change the ranking everywhere.

    Step shape:
      field — record field to compare
      kind  — "bool" (truthy side wins), "higher", or "lower"
      gatedOnAllowBuffFood       — step runs only when the caller allows buff
                                   food (the Food macro path)
      gatedOnAllowConjuredFirst  — step runs only when the caller allows
                                   conjured-first (Food and Water, while Use
                                   Conjured Food & Water First holds)
      gatedOnAllowRestockLast    — step runs only when the caller allows
                                   restock-last (Food and Water, while Use
                                   Restock List Food & Water Last holds)
      truthyWinsWhenPreferHybrid — direction flag for the hybrid step: truthy
                                   wins when the caller prefers hybrids (Food);
                                   falsy wins otherwise (Water, ranked potions)

    Boolean fields are compared RAW (~=), never coerced. Both sides are
    FillRecord output, built from the item cache's own true/false flags, so a
    nil never reaches a step; a new flag has to keep that true.
]]

local RANKING_PRIORITY = {
	-- Buff food first when the Food macro wants one.
	{ field = "isBuffFood", kind = "bool", gatedOnAllowBuffFood = true },

	--[[
	    Conjured food and water next, when the player asked for it (Use
	    Conjured Food & Water First, on Food and Water only). The one place
	    a burn-first reason outranks the restore steps, and only by that
	    choice: conjured items cost nothing and vanish at logout, so a player
	    handed a weaker conjured water would rather drink it than buy the
	    vendor one. Buff food stays above it so Buff Food still lands Well
	    Fed. Gated off, the ordinary isConjured tiebreak below still applies.
	    It is the only way a macro passes over its best item: potions, pet
	    food and every other macro always use the best, and there are no
	    custom sort orders or second-best rules.
	]]
	{ field = "isConjured", kind = "bool", gatedOnAllowConjuredFirst = true },

	-- Percent-based restores beat flat values.
	{ field = "isPercent", kind = "bool" },

	--[[
	    Higher restore/damage, raw from the item data. No bonuses are folded
	    in, so this compares exactly what the item restores.
	]]
	{ field = "value", kind = "higher" },

	--[[
	    Off the Restock List next, when the player asked for it (Use Restock
	    List Food & Water Last, on Food and Water only): of two items that
	    restore the same amount, eat the one not on the Restock List, and
	    keep the list's stock for later. Below value, so it never picks
	    the weaker item.
	]]
	{ field = "isOffRestockList", kind = "bool", gatedOnAllowRestockLast = true },

	--[[
	    THE BURN-FIRST LADDER. Three tiebreaks among items that restore the
	    SAME amount, ordered by SHELF LIFE -- spend the copy that will be
	    worth the least to you soonest:

	      isConjured  -- gone at logout, so its shelf life is this session
	                     and nothing else on the list expires on a timer.
	                     Free to replace, too, so spending it costs nothing.
	      hasZones    -- survives logout, but is dead weight the moment you
	                     leave the zone. Spend it while it still does
	                     something.
	      isSoulbound -- keeps its value indefinitely, but only for THIS
	                     character: it cannot be mailed to an alt, traded,
	                     or sold.

	    Then price, then isHighStack -- both below, with their own notes. They
	    rank lower because neither is about shelf life: an item that vendors
	    for nothing has simply already lost its gold value, and stack size is
	    pure bag economy.

	    This ORDER is the whole specification. Moving a line changes the
	    preference; nothing else needs to change with it.

	    They sit BELOW value deliberately. Promote any of them above it and a
	    zone-locked Superior Mana Draught (560) beats a Super Mana Potion
	    (1800) in a battleground -- "worthless elsewhere" is a reason to spend
	    a tie, never a reason to drink the weaker potion.

	    The three above plus isHighStack are ladder steps, never numeric
	    bonuses added into value: a bonus can outweigh a genuine restore
	    difference of 1 or 2, and two equal bonuses cancel each other instead
	    of ranking.

	    Uniform inside a category is a no-op, which covers most of them:
	    zones and binding only really vary across the potion and bandage
	    families. Note isConjured is set from the food/water data alone, so
	    every healthstone, soulstone and mana gem candidate reads false,
	    conjured or not -- harmless, because a step that reads the same for
	    every candidate in a category never separates two of them.
	]]
	{ field = "isConjured", kind = "bool" },
	{ field = "hasZones", kind = "bool" },
	{ field = "isSoulbound", kind = "bool" },

	--[[
	    Cheaper wins, and it sits ABOVE isHighStack because a 0 here does not
	    mean "cheap", it means the item has NO vendor price at all: drinking
	    it forgoes nothing, which outweighs any bag-space argument. The
	    Auchenai potions are the live case -- they vendor for nothing, so
	    they burn ahead of the injectors.

	    A separate "has no sell price" step would be redundant. Ascending
	    price already sorts the zero-price items to the front; only a step
	    ranked above this one, such as isHighStack, can keep them behind.
	]]
	{ field = "price", kind = "lower" },

	--[[
	    Bag economy, and the weakest reason on the list: injectors (stack 20)
	    ahead of the potions they are made from spares the reagents and the
	    slot. Last of the burn-first steps, so it only separates items already
	    equal on restore, shelf life AND price.
	]]
	{ field = "isHighStack", kind = "bool" },

	--[[
	    Hybrid food/water: the Food macro prefers hybrids; Water and the
	    ranked potion lists prefer dedicated items.
	]]
	{ field = "isHybrid", kind = "bool", truthyWinsWhenPreferHybrid = true },

	-- Fewer copies in bags: burn the smaller pile first.
	{ field = "count", kind = "lower" },

	--[[
	    Final, never-equal tiebreak. Without it, two items that match on every
	    other field compare equal, so the winner is whichever the pairs() scan
	    over slotItems happened to reach first. That order is not stable
	    between an in-session rescan (a wiped-and-rebuilt table) and a fresh
	    table after /reload, so the selection could flip for identical bags —
	    the item would only "update" after a reload. Comparing itemID last
	    makes the pick deterministic, so a buy-triggered rescan and a reload
	    always agree; it also keeps table.sort's instability from reordering
	    equal ranks between scans and churning macro rewrites.
	]]
	{ field = "id", kind = "lower" },
}

--[[
    Returns true when record `a` outranks record `b` under RANKING_PRIORITY,
    plus the field name of the step that decided it (nil when every step
    compared equal). Only the diagnostics Selection Report reads the second
    value -- it is what turns "this item lost" into "it lost on price" -- and
    returning it costs nothing on the hot path, but every other caller must
    take the first value alone so the extra return can never leak into a
    boolean or a table constructor.
]]
local function CompareRecords(a, b, allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	for i = 1, #RANKING_PRIORITY do
		local step = RANKING_PRIORITY[i]
		if
			not (step.gatedOnAllowBuffFood and not allowBuffFood)
			and not (step.gatedOnAllowConjuredFirst and not allowConjuredFirst)
			and not (step.gatedOnAllowRestockLast and not allowRestockLast)
		then
			local valueA, valueB = a[step.field], b[step.field]
			if valueA ~= valueB then
				if step.kind == "higher" then
					return valueA > valueB, step.field
				elseif step.kind == "lower" then
					return valueA < valueB, step.field
				elseif step.truthyWinsWhenPreferHybrid and not preferHybrid then
					return not valueA, step.field
				else
					return (valueA and true or false), step.field
				end
			end
		end
	end
	return false, nil
end

--[[
    THE one place a comparison field is derived. The running winner, the
    ranked candidate lists and the diagnostics retention all fill through
    here, so both sides of every comparison are built the same way by
    construction -- there is no second reading of an item to drift from the
    first. A new ladder step goes in the step list above, this function,
    ResetBest and CopyCandidateRecord.

    score arrives as a parameter rather than being read off the item because
    each category picks its own field (health, mana, damage) in its score()
    hook. isOffRestockList reads scanRestockList, the current Restock List
    ScanBags captures before its bag walk.
]]
local scanRestockList = {}

local function FillRecord(record, candidate, candidateCount, candidatePrice, score)
	record.isBuffFood = candidate.isBuffFood
	record.isPercent = candidate.isPercent
	record.value = score
	record.isConjured = candidate.isConjured
	record.hasZones = (candidate.zones ~= nil)
	record.isSoulbound = candidate.isSoulbound
	record.isHighStack = (candidate.maxStack or 1) > 10
	record.isOffRestockList = (scanRestockList[candidate.itemID] == nil)
	record.price = candidatePrice
	record.isHybrid = (candidate.healthValue > 0 and candidate.manaValue > 0)
	record.count = candidateCount
	record.id = candidate.itemID
	return record
end

--[[
    Single-winner form: does this bag item beat the current best entry? Both
    sides are FillRecord output, so CompareRecords reads the same field names
    on each. The scratch record is reused across the whole scan -- FillRecord
    writes every field, so nothing leaks from one candidate to the next.
]]
local candidateRecord = {}

local function IsBetter(
	candidate,
	candidateCount,
	candidatePrice,
	currentBest,
	score,
	allowBuffFood,
	preferHybrid,
	allowConjuredFirst,
	allowRestockLast
)
	if not currentBest.id then
		return true
	end

	-- First value only: CompareRecords also returns the deciding field.
	local better = CompareRecords(
		FillRecord(candidateRecord, candidate, candidateCount, candidatePrice, score),
		currentBest,
		allowBuffFood,
		preferHybrid,
		allowConjuredFirst,
		allowRestockLast
	)
	return better
end

--------------------------------------------------------------------------------
-- Ranked Candidates (Multi-Use Macros)
--------------------------------------------------------------------------------

--[[
    The ranked definitions (ranked = true — the ns.MULTI_USE_MACRO_TYPES
    categories) stack up to ns.MULTI_USE_MAX_ITEMS /use lines per macro, so
    instead of tracking a single running winner they collect every usable
    candidate during the scan into rankedCandidates (declared above, keyed
    by typeName from the registry) and are ranked once it completes. The
    other categories keep the single-winner IsBetter path.
]]

--[[
    Each list slot reuses its record from the scan before, kept per type in
    rankedRecordPools: FillRecord writes every field, and the diagnostics copy
    a record before they keep it.
]]
local rankedRecordPools = {}

local function AddRankedCandidate(typeName, data, score, count)
	local list = rankedCandidates[typeName]
	local pool = rankedRecordPools[typeName]
	if not pool then
		pool = {}
		rankedRecordPools[typeName] = pool
	end
	local index = #list + 1
	local record = pool[index]
	if not record then
		record = {}
		pool[index] = record
	end
	list[index] = FillRecord(record, data, count, data.price, score)
end

--[[
    Pairwise sort form for the ranked categories — the same RANKING_PRIORITY
    chain with allowBuffFood, preferHybrid, allowConjuredFirst and
    allowRestockLast always false: percent heals first, then higher value,
    the burn-first steps, price, non-hybrid, fewer copies, itemID. Ranked
    records come from FillRecord like every other record, so the isBuffFood,
    conjured-first and restock-last steps are gated off rather than absent.
]]
local function CompareRankedCandidates(a, b)
	-- First value only: table.sort must see a plain boolean comparator.
	local outranks = CompareRecords(a, b, false, false, false, false)
	return outranks
end

local function RankCandidates()
	for typeName, list in pairs(rankedCandidates) do
		table.sort(list, CompareRankedCandidates)

		local entry = best[typeName]
		local winner = list[1]
		if winner then
			entry.id = winner.id
			entry.value = winner.value
			entry.price = winner.price
			entry.count = winner.count
		end
		for rank = 1, math.min(#list, ns.MULTI_USE_MAX_ITEMS) do
			entry.topIDs[rank] = list[rank].id
		end
	end
end

-- The current Restock List, which FillRecord reads; ns.ScanBags sets it before its bag walk.
local function SetScanRestockList(list)
	scanRestockList = list
end

ns.ScanRanking = {
	best = best,
	rankedCandidates = rankedCandidates,
	candidateRecord = candidateRecord,
	ResetBest = ResetBest,
	BuildSelectionTables = BuildSelectionTables,
	CompareRecords = CompareRecords,
	FillRecord = FillRecord,
	IsBetter = IsBetter,
	AddRankedCandidate = AddRankedCandidate,
	RankCandidates = RankCandidates,
	SetScanRestockList = SetScanRestockList,
}
