local _, ns = ...

--------------------------------------------------------------------------------
-- Best Item Tracking
--------------------------------------------------------------------------------

-- Built lazily on the first scan: the definitions register after this file loads.
local best = {}

-- Refilled in place every pass, so readers always see the last scan. Read-only outside the scanner.
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
    The one ranking order, for both IsBetter and the ranked sort; reordering a
    step is the only edit needed. A step with buffFood, gatedOnAllowConjuredFirst
    or gatedOnAllowRestockLast runs only when the caller passes that gate.

    Booleans compare RAW (~=), never coerced: FillRecord builds both sides from
    the cache's true/false flags, so a nil never reaches a step. A new flag
    must keep that true.
]]

local RANKING_PRIORITY = {
	-- "last": buff food is eaten only when it's all the bags hold, rather than the macro coming up empty.
	{ field = "isBuffFood", kind = "bool", buffFood = "first" },
	{ field = "isBuffFood", kind = "bool", buffFood = "last", falsyWins = true },

	--[[
	    The one burn-first reason above the restore steps, and only by the
	    player's choice: conjured items are free and vanish at logout.
	]]
	{ field = "isConjured", kind = "bool", gatedOnAllowConjuredFirst = true },

	{ field = "isPercent", kind = "bool" },

	{ field = "value", kind = "higher" },

	-- Below value, so it never picks the weaker item.
	{ field = "isOffRestockList", kind = "bool", gatedOnAllowRestockLast = true },

	--[[
	    Burn-first, by shelf life: conjured (gone at logout), zone-locked (dead
	    weight elsewhere), soulbound (this character only). BELOW value on
	    purpose, or a zone-locked Superior Mana Draught (560) beats a Super Mana
	    Potion (1800) in a battleground. Steps, never bonuses folded into value:
	    a bonus can outweigh a real restore gap of 1 or 2.
	]]
	{ field = "isConjured", kind = "bool" },
	{ field = "hasZones", kind = "bool" },
	{ field = "isSoulbound", kind = "bool" },

	-- Above isHighStack: a 0 price forgoes nothing, so the Auchenai potions burn ahead of the injectors.
	{ field = "price", kind = "lower" },

	-- Bag economy, the weakest reason: injectors (stack 20) ahead of the potions they're made from.
	{ field = "isHighStack", kind = "bool" },

	{ field = "isHybrid", kind = "bool", truthyWinsWhenPreferHybrid = true },

	{ field = "count", kind = "lower" },

	-- Never equal: pairs() and table.sort order aren't stable, so a full tie would flip picks and churn rewrites.
	{ field = "id", kind = "lower" },
}

-- The second return, the deciding field, is for Diagnostics; every other caller takes the first value alone.
local function CompareRecords(a, b, buffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	for i = 1, #RANKING_PRIORITY do
		local step = RANKING_PRIORITY[i]
		if
			not (step.buffFood and step.buffFood ~= buffFood)
			and not (step.gatedOnAllowConjuredFirst and not allowConjuredFirst)
			and not (step.gatedOnAllowRestockLast and not allowRestockLast)
		then
			local valueA, valueB = a[step.field], b[step.field]
			if valueA ~= valueB then
				if step.kind == "higher" then
					return valueA > valueB, step.field
				elseif step.kind == "lower" then
					return valueA < valueB, step.field
				elseif step.falsyWins then
					return not valueA, step.field
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

-- The scan and Diagnostics both ask here, so they always rank the same way.
local function BuffFoodRank(definition)
	if definition.buffFoodFirstWhenUnfed and ns.buffFoodFirst then
		return "first"
	end
	return definition.allowBuffFood and ns.buffFoodRank
end

--[[
    THE one place a comparison field is derived, so both sides of every
    comparison match. A new ladder step goes in RANKING_PRIORITY, here,
    ResetBest and CopyCandidateRecord.
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

-- Reused across the scan: FillRecord writes every field, so nothing leaks between candidates.
local candidateRecord = {}

local function IsBetter(
	candidate,
	candidateCount,
	candidatePrice,
	currentBest,
	score,
	buffFood,
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
		buffFood,
		preferHybrid,
		allowConjuredFirst,
		allowRestockLast
	)
	return better
end

--------------------------------------------------------------------------------
-- Ranked Candidates (Multi-Use Macros)
--------------------------------------------------------------------------------

-- Slots reuse last scan's records: FillRecord writes every field, and Diagnostics copies before keeping.
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
	BuffFoodRank = BuffFoodRank,
	FillRecord = FillRecord,
	IsBetter = IsBetter,
	AddRankedCandidate = AddRankedCandidate,
	RankCandidates = RankCandidates,
	SetScanRestockList = SetScanRestockList,
}
