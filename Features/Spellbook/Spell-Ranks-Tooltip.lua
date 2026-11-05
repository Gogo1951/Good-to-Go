local _, ns = ...
local L = ns.L

--[[
	A spell's ranks and the level each needs, "GtG // Firebolt Ranks" and a line for each (ns.AddSpellRanksTooltip;
	the What's Next? rows, Features/Spellbook/Whats-Next/Whats-Next-Page.lua, use ns.SpellRankRows and ns.AddSpellRankLines),
	under every spell tooltip the game shows: action bars, the game's own spell book, other add-ons. Tooltips that
	add the ranks themselves (the Spell Book page's tiles, the What's Next? rows) set ns.spellTooltipHasOwnRanks
	around their SetSpellByID so the lines aren't doubled.
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
	return note and ns.GetColor(ns.SPELL_RANK_NOTE_COLORS[state]) .. note .. "|r"
end
ns.RankNote = RankNote

-- A rank's label in its state's color.
local function RankLabel(rank, text)
	return ns.GetColor(ns.SPELL_RANK_COLORS[RankState(rank.status)]) .. text .. "|r"
end
ns.RankLabel = RankLabel

--[[
	"GtG // Firebolt Ranks", then each of ranks (RankRows) in its ns.SPELL_RANK_COLORS color, row's own rank
	marked, with its note (RankNote) on the right.
]]
local function AddRankLinesFor(row, ranks)
	GameTooltip:AddLine(
		ns.GetColor("INFO")
			.. L["ADDON_SHORT_NAME"]
			.. "|r "
			.. ns.GetColor("SEPARATOR")
			.. "//|r "
			.. ns.GetColor("TEXT")
			.. L["WHATS_NEXT_TOOLTIP_RANKS"]:format(row.name)
			.. "|r"
	)
	for _, rank in ipairs(ranks) do
		local label = (rank.subtext and rank.subtext ~= "") and rank.subtext or rank.name
		GameTooltip:AddDoubleLine(
			rank == row and RANK_MARKER .. ns.GetColor(ns.SPELL_RANK_SELECTED_COLOR) .. label .. "|r"
				or RANK_SPACER .. RankLabel(rank, label),
			RankNote(rank) or ""
		)
	end
end

-- The same for row's spell among rows, for the What's Next? rows (Whats-Next-Page.lua).
function ns.AddSpellRankLines(rows, row)
	AddRankLinesFor(row, RankRows(rows, row))
end

--------------------------------------------------------------------------------
-- Rows Cache
--------------------------------------------------------------------------------

--[[
	An action bar's tooltip refreshes several times a second, so the What's Next? rows behind it are built once
	and kept, with each spell's row by ID and each spell's ranks by name, until something they read changes.
	Spellbook-Events.lua, Trainer-Recording.lua and Spellbook-Core.lua call ns.InvalidateSpellRankRows on those
	changes: a spell learned, a spell's data loading, the pet changing, a trainer's list recorded, a profile
	change, the Spellbook switched back on after its events went unheard. A level
	gained is caught here instead, by the level each set was built at, since UnitLevel still reports the old
	level while PLAYER_LEVEL_UP fires.
]]
local cache = {}

function ns.InvalidateSpellRankRows(petOnly)
	cache.pet = nil
	if not petOnly then
		cache.class = nil
	end
end

local function RankKey(name, extra)
	return (extra and "extra:" or "rank:") .. name
end

local function BuildIndex(rows)
	local byId, ranks = {}, {}
	for _, row in ipairs(rows) do
		byId[row.id] = byId[row.id] or row
		local key = RankKey(row.name, row.extra)
		ranks[key] = ranks[key] or {}
		table.insert(ranks[key], row)
	end
	for _, list in pairs(ranks) do
		table.sort(list, ByLevel)
	end
	return { rows = rows, byId = byId, ranks = ranks }
end

local function CachedIndex(pet)
	local key = pet and "pet" or "class"
	local level = UnitLevel("player")
	local petLevel = pet and UnitLevel("pet") or nil
	local entry = cache[key]
	if not entry or entry.level ~= level or entry.petLevel ~= petLevel then
		entry = BuildIndex(pet and ns.WhatsNextPetRows() or ns.WhatsNextRows())
		entry.level, entry.petLevel = level, petLevel
		cache[key] = entry
	end
	return entry
end

--[[
	Adds the ranks of spellID's spell to GameTooltip, for a tooltip outside the What's Next? tabs: mostly the
	game's own spell tooltips (AddRanks, below, hooked onto every one), and also the Spell Book page's tiles
	(Features/Spellbook/Macro-Button.lua) and the Pet Spell Book's rows. pet reads the pet's
	abilities (ns.WhatsNextPetRows) rather than the class's (ns.WhatsNextRows); blankFirst puts a blank line
	above them. Returns whether it added any: nothing for a spell the rows don't hold or with one rank.
]]
function ns.AddSpellRanksTooltip(spellID, pet, blankFirst)
	local index = CachedIndex(pet)
	local row = index.byId[spellID]
	-- a spell the rows don't list by this ID (a rank the data leaves out) still finds its namesakes
	if not row then
		local name = ns.SpellName(spellID)
		row = name and { id = spellID, name = name } or nil
	end
	local ranks = row and index.ranks[RankKey(row.name, row.extra)]
	if not ranks or #ranks < 2 then
		return false
	end
	if blankFirst then
		GameTooltip:AddLine(" ")
	end
	AddRankLinesFor(row, ranks)
	return true
end

--[[
	The class's What's Next? row for spellID, else the lowest-level row named name, or nil: what gives a macro
	menu's ranks and grouped spells (Features/Spellbook/Macro-Menu-Sections.lua) the same status and source as the
	tooltip's.
]]
function ns.ClassRankRow(spellID, name)
	local index = CachedIndex(false)
	if spellID and index.byId[spellID] then
		return index.byId[spellID]
	end
	local found
	for _, row in ipairs(index.rows) do
		if name and row.name == name and (not found or (row.level or 0) < (found.level or 0)) then
			found = row
		end
	end
	return found
end

-- One set of rank lines per showing, though the client may report the same spell more than once.
local added = false

local function AddRanks(tooltip, spellID)
	if tooltip ~= GameTooltip or added or ns.spellTooltipHasOwnRanks or not ns.IsSpellbookEnabled() then
		return
	end
	-- the Enhanced Spellbook panel's What's Next Ability Tooltips switch
	if not ns.db.global.abilityTooltipRanks then
		return
	end
	-- in combat a spell's tooltip stays the game's own, short
	if InCombatLockdown() then
		return
	end
	if not spellID or not ns.IsPlain(spellID) then
		return
	end
	-- the class's spells first, then a hunter's beast's or a warlock's demon's abilities
	if
		ns.AddSpellRanksTooltip(spellID, false, true)
		or (ns.HasWhatsNextPet() and ns.AddSpellRanksTooltip(spellID, true, true))
	then
		added = true
		tooltip:Show()
	end
end

GameTooltip:HookScript("OnTooltipCleared", function()
	added = false
end)

ns.AddSpellTooltipPostCall(AddRanks)
