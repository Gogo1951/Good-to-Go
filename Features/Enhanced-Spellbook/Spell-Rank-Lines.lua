local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

-- The spacer is the arrow cropped to its clear top-left pixel, so every rank's text starts in the same place.
local SELECTED = ns.COLORS_RGB[ns.SPELL_RANK_SELECTED_COLOR]
local RANK_MARKER = ("|T%s:0:0:0:0:32:32:0:32:0:32:%d:%d:%d|t "):format(
	ns.TEXTURE_RANK_ARROW,
	SELECTED.r * 255 + 0.5,
	SELECTED.g * 255 + 0.5,
	SELECTED.b * 255 + 0.5
)
local RANK_SPACER = ("|T%s:0:0:0:0:32:32:0:1:0:1|t "):format(ns.TEXTURE_RANK_ARROW)

local function ByLevel(a, b)
	if (a.level or 0) ~= (b.level or 0) then
		return (a.level or 0) < (b.level or 0)
	end
	return a.id < b.id
end
ns.SpellRankByLevel = ByLevel

-- Same-name rows, whatever a page's filters hide; an extraSpells row (Polymorph (Pig)) isn't its namesake's rank.
local function RankRows(rows, row)
	local ranks = {}
	for _, other in ipairs(rows) do
		if other.name == row.name and (not other.extra) == not row.extra then
			ranks[#ranks + 1] = other
		end
	end
	table.sort(ranks, ByLevel)
	return ranks
end
ns.SpellRankRows = RankRows

-- A talent not taken is NOT_YET, not LEARNABLE: a choice, not something missed.
local function RankState(status)
	if status == "KNOWN" then
		return "KNOWN"
	elseif status == "AVAILABLE" or status == "TEACH" then
		return "LEARNABLE"
	end
	return "NOT_YET"
end
ns.RankState = RankState

-- Only a pet ability's row has a ready.
local function SourceLabel(rank)
	if not rank.source then
		return nil
	end
	return L[(rank.ready ~= nil and "WHATS_NEXT_PET_SOURCE_" or "WHATS_NEXT_SOURCE_") .. rank.source]
end

local function RankNote(rank)
	local state = RankState(rank.status)
	local level = rank.level and L["SUBTEXT_LEARN_LEVEL"]:format(rank.level)
	local note
	if state == "KNOWN" then
		note = level
	elseif state == "LEARNABLE" then
		if rank.status == "TEACH" then
			note = rank.item and L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] or L["SUBTEXT_TEACH_PET"]
		else
			note = SourceLabel(rank) or level
		end
	else
		local source = rank.source ~= "TRAINER" and rank.source ~= "START" and SourceLabel(rank)
		note = source and level and L["SUBTEXT_SOURCE_LEVEL"]:format(source, level) or source or level
	end
	return note and GetColor(ns.SPELL_RANK_NOTE_COLORS[state]) .. note .. "|r"
end
ns.RankNote = RankNote

local function RankLabel(rank, text)
	return GetColor(ns.SPELL_RANK_COLORS[RankState(rank.status)]) .. text .. "|r"
end
ns.RankLabel = RankLabel

local function AddRankLinesFor(row, ranks)
	ns.AddSpellbookTooltipTitle(L["WHATS_NEXT_TOOLTIP_RANKS"]:format(row.name))
	for _, rank in ipairs(ranks) do
		local label = (rank.subtext and rank.subtext ~= "") and rank.subtext or rank.name
		GameTooltip:AddDoubleLine(
			rank == row and RANK_MARKER .. GetColor(ns.SPELL_RANK_SELECTED_COLOR) .. label .. "|r"
				or RANK_SPACER .. RankLabel(rank, label),
			RankNote(rank) or ""
		)
	end
end

-- What's Next? rows read their ranks once with ns.SpellRankRows and pass them in.
ns.AddSpellRankLines = AddRankLinesFor
