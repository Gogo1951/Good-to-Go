local _, ns = ...

--------------------------------------------------------------------------------
-- Rank Watch Lookups
--------------------------------------------------------------------------------

--[[
    ns.RANK_WATCH_ABILITIES as ladders: one per ability, its ranks in learn-level order, each rank knowing its
    place. Built once at login from the flavor's table.

    A spell that replaces another as the player trains (Demon Skin, then Demon Armor; Frost Armor, then Ice
    Armor) is one ladder, the same groups the Enhanced Spellbook's Grouped Spells uses (ns.SPELL_GROUPS): casting
    Demon Skin once Demon Armor is learned is a low rank like any other. Where the data already lists a group as
    one ability (TBC's sheet joins several), there is nothing to join.

    Each ladder is keyed by its first rank's spell ID, which the Tracked Abilities panel reads.
]]
local ladders = {} -- class token -> { ladder, ... }
local petLadders = {} -- owner's class token -> { ladder, ... }, each with isPet
local bySpell = {} -- spell ID -> { ladder = ladder, index = place on the ladder }

local function LadderHas(ladder, spellID)
	for _, row in ipairs(ladder.rows) do
		if row.id == spellID then
			return true
		end
	end
	return false
end

-- Joins the ladders holding each spell of one ns.SPELL_GROUPS group into the first, ordered by learn level.
local function JoinGroup(list, group)
	local members, seen = {}, {}
	for _, memberID in ipairs(group) do
		for _, ladder in ipairs(list) do
			if not ladder.joined and not seen[ladder] and LadderHas(ladder, memberID) then
				seen[ladder] = true
				members[#members + 1] = ladder
			end
		end
	end
	if #members < 2 then
		return
	end
	local first = members[1]
	for i = 2, #members do
		for _, row in ipairs(members[i].rows) do
			first.rows[#first.rows + 1] = row
		end
		members[i].joined = true
	end
	first.isGroup = true
end

-- Learn level first, then the order the rows arrived in, since table.sort is not stable.
local function SortRows(rows)
	local place = {}
	for i, row in ipairs(rows) do
		place[row] = i
	end
	table.sort(rows, function(a, b)
		local aLevel, bLevel = a.level or 0, b.level or 0
		if aLevel ~= bLevel then
			return aLevel < bLevel
		end
		return place[a] < place[b]
	end)
end

--[[
    A rank this client has no such spell for is left off its ladder. WoW Forever gave some abilities new spell
    IDs (Curse of the Elements is 440892, not 1490), and the Classic IDs its table was built from don't exist
    there: listed, they show as "Spell #1490" on the Tracked Abilities panel and can never be cast. A ladder
    left with one rank stays: the Tracked Abilities panel lists every ability, and a single rank is never reported,
    having nothing above it.
]]
local function OnClient(spellID)
	return C_Spell.DoesSpellExist(spellID)
end

-- One table's abilities as ladders, each rank this client has, keeping every ability with a rank on this client.
local function ReadLadders(class, abilities, isPet)
	local list = {}
	for _, ranks in ipairs(abilities) do
		local rows = {}
		for _, row in ipairs(ranks) do
			if OnClient(row.id) then
				rows[#rows + 1] = row
			end
		end
		if #rows > 0 then
			list[#list + 1] = { class = class, rows = rows, isPet = isPet or nil }
		end
	end
	return list
end

--[[
    Hunter pets' and warlock demons' abilities (ns.RANK_WATCH_PET_ABILITIES), under the owner's class: a pet's
    low rank is its owner's to fix, so the owner hears about it. Nothing joins them; each is its own ladder.
]]
local function BuildPetLadders()
	for class, abilities in pairs(ns.RANK_WATCH_PET_ABILITIES or {}) do
		local list = ReadLadders(class, abilities, true)
		for _, ladder in ipairs(list) do
			SortRows(ladder.rows)
			ladder.id = ladder.rows[1].id
			for index, row in ipairs(ladder.rows) do
				bySpell[row.id] = { ladder = ladder, index = index }
			end
		end
		petLadders[class] = #list > 0 and list or nil
	end
end

function ns.BuildRankWatchLookups()
	wipe(ladders)
	wipe(petLadders)
	wipe(bySpell)
	BuildPetLadders()
	for class, abilities in pairs(ns.RANK_WATCH_ABILITIES) do
		local list = ReadLadders(class, abilities)
		for _, group in ipairs(ns.SPELL_GROUPS[class] or {}) do
			JoinGroup(list, group)
		end
		local kept = {}
		for _, ladder in ipairs(list) do
			if not ladder.joined then
				SortRows(ladder.rows)
				ladder.id = ladder.rows[1].id
				kept[#kept + 1] = ladder
				for index, row in ipairs(ladder.rows) do
					bySpell[row.id] = { ladder = ladder, index = index }
				end
			end
		end
		ladders[class] = #kept > 0 and kept or nil
	end
end

-- The ladder and place of a tracked spell, or nil for any spell Rank Watch doesn't watch.
function ns.RankWatchLookup(spellID)
	return bySpell[spellID]
end

--[[
    The lookup of a tracked rank with a rank above it, the only casts that can ever be low, else nil. Detection
    asks this first: in a raid nearly every cast is a top rank, and turning those away here skips the unit scans.
]]
function ns.RankWatchReportableLookup(spellID)
	local lookup = bySpell[spellID]
	if not lookup or lookup.index == #lookup.ladder.rows then
		return nil
	end
	if not ns.IsRankWatchRankTracked(lookup.ladder.rows[lookup.index]) then
		return nil
	end
	return lookup
end

--[[
    Whether a rank is reported. untracked holds only the player's own choices: true unticked, false ticked. A rank
    they never touched follows the data, where off marks the ranks players lower on purpose so often that they
    start unchecked (Rank 1 Scorch, Frostbolt, Entangling Roots and the like), Rank Sentinel's own default skips.
]]
function ns.IsRankWatchRankTracked(row)
	local choice = ns.RankWatchSettings().untracked[row.id]
	if choice == nil then
		return not row.off
	end
	return not choice
end

-- Records the player's choice, or clears it when it matches the data's default, so the default can still move.
function ns.SetRankWatchRankTracked(row, tracked)
	local untracked = ns.RankWatchSettings().untracked
	if tracked == not row.off then
		untracked[row.id] = nil
	else
		untracked[row.id] = not tracked
	end
end

-- Every class's ladders, by class token.
function ns.RankWatchLadders()
	return ladders
end

-- The pet ladders, by the owner's class token: HUNTER and WARLOCK where the flavor's pets have ranks.
function ns.RankWatchPetLadders()
	return petLadders
end

--[[
    The place of the highest rank on a ladder learned by `level`, or nil when none is. Rows are in learn-level
    order, so the last one at or under the level wins. A rank with no level in the data (a talent the spellbook's
    tables give none) is never the better rank.
]]
function ns.RankWatchBestIndex(ladder, level)
	local best
	for index, row in ipairs(ladder.rows) do
		if row.level then
			if row.level <= level then
				best = index
			else
				break
			end
		end
	end
	return best
end

-- The client's own rank text for a row ("Rank 3"), or nil while it hasn't described the spell yet.
local function ClientRankText(row)
	local subtext = C_Spell.GetSpellSubtext(row.id)
	if ns.IsPlain(subtext) and subtext and subtext ~= "" then
		return subtext
	end
	C_Spell.RequestLoadSpellData(row.id)
	return nil
end

--[[
    A rank as players read it: the client's own rank text ("Rank 3"), and the data's rank where the client
    hasn't described the spell yet. TBC's sheet numbers a joined group's ranks through the whole group, so the
    client's text is preferred, and the data's number is only ever printed, never whispered
    (ns.RankWatchHasRankText).
]]
function ns.RankWatchRankText(row)
	return ClientRankText(row) or ns.L["RANK_WATCH_RANK"]:format(row.rank)
end

-- Whether the client's own rank text for a row is in, asking for it when it isn't.
function ns.RankWatchHasRankText(row)
	return ClientRankText(row) ~= nil
end
