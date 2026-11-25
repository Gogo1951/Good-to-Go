local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
	A spell's rank lines: its ranks among the What's Next? rows by level (ns.SpellRankRows), each rank's state,
	note and colored label (ns.RankState, ns.RankNote, ns.RankLabel), and "Firebolt Ranks … GtG" with a line
	for each, added to GameTooltip (ns.AddSpellRankLines). Spell-Ranks-Tooltip.lua puts them under every spell
	tooltip; the What's Next? rows add them to their own.
]]

--[[
	Before the hovered rank in the tooltip's list of ranks, the white arrow (ns.TEXTURE_RANK_ARROW) tinted the
	selected blue (ns.SPELL_RANK_SELECTED_COLOR); before every other rank a gap as wide: the same arrow cropped
	to its clear top-left pixel, so each rank's text starts in the same place.
]]
local SELECTED = ns.COLORS_RGB[ns.SPELL_RANK_SELECTED_COLOR]
local RANK_MARKER = ("|T%s:0:0:0:0:32:32:0:32:0:32:%d:%d:%d|t "):format(
	ns.TEXTURE_RANK_ARROW,
	SELECTED.r * 255 + 0.5,
	SELECTED.g * 255 + 0.5,
	SELECTED.b * 255 + 0.5
)
local RANK_SPACER = ("|T%s:0:0:0:0:32:32:0:1:0:1|t "):format(ns.TEXTURE_RANK_ARROW)

-- Lowest level first, then lowest ID: the order a spell's ranks are listed in.
local function ByLevel(a, b)
	if (a.level or 0) ~= (b.level or 0) then
		return (a.level or 0) < (b.level or 0)
	end
	return a.id < b.id
end
ns.SpellRankByLevel = ByLevel

--[[
	The ranks of row's spell among rows, by level: the rows of the same name (an extraSpells row, Polymorph
	(Pig), isn't one of its namesake's ranks), from all of them, whatever a page's filters hide.
]]
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

--[[
	A rank's state, from its What's Next? status (Whats-Next.lua, Whats-Next-Pet.lua), for its color
	(ns.SPELL_RANK_COLORS): KNOWN; LEARNABLE, one the character could have now and doesn't (a trainer's, a
	book's or a quest's at its level, or a pet's to teach now); else NOT_YET, a level still to come, a talent
	not taken (a choice, not something missed), one waiting on another spell, or a pet's its family can't learn.
	The statuses already read a pet's rank against the pet's level.
]]
local function RankState(status)
	if status == "KNOWN" then
		return "KNOWN"
	elseif status == "AVAILABLE" or status == "TEACH" then
		return "LEARNABLE"
	end
	return "NOT_YET"
end
ns.RankState = RankState

-- Where a rank is learned, as the What's Next? source filter names it; a pet ability's row has a ready, a class spell's none.
local function SourceLabel(rank)
	if not rank.source then
		return nil
	end
	return L[(rank.ready ~= nil and "WHATS_NEXT_PET_SOURCE_" or "WHATS_NEXT_SOURCE_") .. rank.source]
end

--[[
	The note beside a rank, colored (ns.SPELL_RANK_NOTE_COLORS), or nil: the level a known rank asks for; for one
	to learn now, where ("Trainer", "Book", "Quest", or teaching the pet); for one not yet, its level, after where
	it's learned unless that's a trainer ("Talent, Level 40").
]]
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

-- A rank's label in its state's color.
local function RankLabel(rank, text)
	return GetColor(ns.SPELL_RANK_COLORS[RankState(rank.status)]) .. text .. "|r"
end
ns.RankLabel = RankLabel

--[[
	"Firebolt Ranks … GtG", then each of ranks (RankRows) in its ns.SPELL_RANK_COLORS color, row's own rank
	marked, with its note (RankNote) on the right.
]]
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

-- The same for the What's Next? rows (Whats-Next-Page.lua), which read ranks once with ns.SpellRankRows.
ns.AddSpellRankLines = AddRankLinesFor
