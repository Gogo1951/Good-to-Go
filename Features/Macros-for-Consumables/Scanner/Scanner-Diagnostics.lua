local _, ns = ...

local Ranking = ns.ScanRanking
local CompareRecords, rankedCandidates = Ranking.CompareRecords, Ranking.rankedCandidates

--------------------------------------------------------------------------------
-- Diagnostic Candidate Retention
--------------------------------------------------------------------------------

--[[
    Retained only while Diagnostics is on, so normal play pays one boolean per
    candidate. Ranked categories just copy their sorted list; only single-winner
    ones retain as they scan. FillRecord fills both views, so they agree.
]]
local DIAGNOSTIC_CANDIDATE_LIMIT = 5

local diagnosticCandidates = {}
ns.diagnosticCandidates = diagnosticCandidates

--[[
    Must carry EVERY field RANKING_PRIORITY compares. A missing field isn't
    neutral: a boolean tests unequal to nil, so the step decides on the gap.
    Add a ladder step, add it here.
]]
local function CopyCandidateRecord(record)
	return {
		id = record.id,
		value = record.value,
		price = record.price,
		count = record.count,
		isBuffFood = record.isBuffFood,
		isPercent = record.isPercent,
		isConjured = record.isConjured,
		hasZones = record.hasZones,
		isSoulbound = record.isSoulbound,
		isHighStack = record.isHighStack,
		isHybrid = record.isHybrid,
		isOffRestockList = record.isOffRestockList,
	}
end

local function GetCandidateList(typeName)
	local list = diagnosticCandidates[typeName]
	if not list then
		list = {}
		diagnosticCandidates[typeName] = list
	end
	return list
end

-- Ranked by the selection's own comparator, so entry 1 is always the winner.
local function RetainCandidate(typeName, record, buffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	local list = GetCandidateList(typeName)

	local position = #list + 1
	for i = 1, #list do
		local outranks = CompareRecords(record, list[i], buffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
		if outranks then
			position = i
			break
		end
	end

	if position > DIAGNOSTIC_CANDIDATE_LIMIT then
		return
	end

	table.insert(list, position, CopyCandidateRecord(record))
	list[DIAGNOSTIC_CANDIDATE_LIMIT + 1] = nil
end

-- Ranked categories compare with every gate off, matching CompareRankedCandidates.
local function CaptureDiagnosticCandidates()
	if not ns.diagnostics.enabled then
		return
	end

	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		local list
		local buffFood, preferHybrid, allowConjuredFirst, allowRestockLast

		if definition.ranked then
			local source = rankedCandidates[definition.typeName]
			list = GetCandidateList(definition.typeName)
			for i = 1, math.min(#source, DIAGNOSTIC_CANDIDATE_LIMIT) do
				list[i] = CopyCandidateRecord(source[i])
			end
			buffFood, preferHybrid, allowConjuredFirst, allowRestockLast = false, false, false, false
		else
			list = diagnosticCandidates[definition.typeName]
			buffFood = Ranking.BuffFoodRank(definition)
			preferHybrid = definition.preferHybrid
			allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
			allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
		end

		if list then
			local winner = list[1]
			for i = 2, #list do
				local _, decidedBy =
					CompareRecords(winner, list[i], buffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
				list[i].decidedBy = decidedBy
			end
		end
	end
end

Ranking.diagnosticCandidates = diagnosticCandidates
Ranking.RetainCandidate = RetainCandidate
Ranking.CaptureDiagnosticCandidates = CaptureDiagnosticCandidates
