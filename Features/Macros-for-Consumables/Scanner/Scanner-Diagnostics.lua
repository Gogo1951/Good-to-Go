local _, ns = ...

--[[
    Scanner-Diagnostics -- the candidates the bag scan keeps for Diagnostics,
    split from Scanner-Ranking.lua, whose comparator (CompareRecords) and
    ranked lists it reads through ns.ScanRanking, and to which it adds
    RetainCandidate, CaptureDiagnosticCandidates and diagnosticCandidates for
    the scan (Scanner-Inventory.lua) to use.
]]

local Ranking = ns.ScanRanking
local CompareRecords, rankedCandidates = Ranking.CompareRecords, Ranking.rankedCandidates

--------------------------------------------------------------------------------
-- Diagnostic Candidate Retention
--------------------------------------------------------------------------------

--[[
    Feeds the Diagnostic Tools Selection Report, which answers "why that item
    and not this one." Every category keeps its top few candidates with the
    RANKING_PRIORITY step that separated each from the winner.

    Retention runs only while ns.diagnostics.enabled is true, so normal play
    pays one boolean test per candidate and nothing else. The table is runtime
    only: it hangs off ns, is wiped at the start of every scan, and is never
    declared in the defaults or written to SavedVariables.

    Ranked categories need no retention of their own -- RankCandidates already
    sorts their full candidate list into final order, so the runners-up are the
    entries below the winner and CaptureDiagnosticCandidates just copies them.
    Only the single-winner categories, which keep no list, retain as they scan.

    Retention ranks candidates against each other, while the selection ranks
    each candidate against the winner record in `best`. The two agree because
    FillRecord populates both, so no definition has to remember to copy a
    comparison field onto its winner for the two views to stay in step.
]]
local DIAGNOSTIC_CANDIDATE_LIMIT = 5

local diagnosticCandidates = {}
ns.diagnosticCandidates = diagnosticCandidates

--[[
    Carries EVERY field RANKING_PRIORITY compares. A field left out does not
    make its step neutral -- it makes the step decide: a real boolean tests
    unequal to a missing one, so the retained ordering tips on the gap, and two
    copies compared against each other skip the step entirely and report a
    lower one as the decider. Add a ladder step, add it here.
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

--[[
    Ordered insert capped at DIAGNOSTIC_CANDIDATE_LIMIT, ranked by the same
    comparator the selection ran, so entry 1 is always the category's winner
    and the entries below it are the real runners-up rather than whichever
    items the bag walk happened to reach first.
]]
local function RetainCandidate(typeName, record, allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	local list = GetCandidateList(typeName)

	local position = #list + 1
	for i = 1, #list do
		local outranks =
			CompareRecords(record, list[i], allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
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

--[[
    Runs once per scan, after RankCandidates has settled the ranked lists:
    copies the ranked categories' runners-up, then annotates every retained
    runner-up with the step that separated it from its category's winner.
    Ranked categories always compare with buff food, hybrid preference,
    conjured-first and restock-last off, matching CompareRankedCandidates.
]]
local function CaptureDiagnosticCandidates()
	if not ns.diagnostics.enabled then
		return
	end

	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		local list
		local allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast

		if definition.ranked then
			local source = rankedCandidates[definition.typeName]
			list = GetCandidateList(definition.typeName)
			for i = 1, math.min(#source, DIAGNOSTIC_CANDIDATE_LIMIT) do
				list[i] = CopyCandidateRecord(source[i])
			end
			allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast = false, false, false, false
		else
			list = diagnosticCandidates[definition.typeName]
			allowBuffFood = definition.allowBuffFood and ns.allowBuffFood
			preferHybrid = definition.preferHybrid
			allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
			allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
		end

		if list then
			local winner = list[1]
			for i = 2, #list do
				local _, decidedBy =
					CompareRecords(winner, list[i], allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
				list[i].decidedBy = decidedBy
			end
		end
	end
end

Ranking.diagnosticCandidates = diagnosticCandidates
Ranking.RetainCandidate = RetainCandidate
Ranking.CaptureDiagnosticCandidates = CaptureDiagnosticCandidates
