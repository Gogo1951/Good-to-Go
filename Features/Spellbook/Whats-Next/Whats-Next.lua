local _, ns = ...

--[[
	The class spells for the What's Next? tab (Features/Spellbook/Whats-Next/Whats-Next-Page.lua): every rank the class
	trainers, books, quests and talents teach this character, each with where it's learned, the level it asks
	for, and whether it can be learned now. The rows come from the trainer data (Data/), the trainers this
	character recorded (Features/Spellbook/Trainer-Recording.lua), and the class lists' extraSpells with their
	sources (ns.EXTRA_SPELL_SOURCES).
]]

local NO_IDS = {}

-- Within this many levels of the player's, an unlearned spell is Coming Soon rather than Not Yet Available.
local SOON_LEVELS = 2

--[[
	The statuses in the order Sort By Availability lists them: the spells to go and learn first, Known last.
	MISSING is a spell whose level is reached but that needs another spell first (or a talent not taken);
	TALENT a talent not taken, which is a choice rather than something coming.
]]
ns.WHATS_NEXT_STATUSES = { "AVAILABLE", "SOON", "LATER", "MISSING", "TALENT", "KNOWN" }

-- The sources the filter offers, in its order.
ns.WHATS_NEXT_SOURCES = { "START", "TRAINER", "BOOK", "QUEST", "TALENT", "RUNE" }

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

--[[
	How the tab orders its spells: "availability", under each status in ns.WHATS_NEXT_STATUSES' order, or
	"level", under each learn level.
]]
function ns.WhatsNextSort()
	return ns.db.profile.whatsNextSort
end

function ns.SetWhatsNextSort(sort)
	ns.db.profile.whatsNextSort = sort
end

-- Whether the tab also lists the spells already learned, under Known.
function ns.WhatsNextShowsKnown()
	return ns.db.profile.whatsNextShowKnown
end

function ns.SetWhatsNextShowKnown(on)
	ns.db.profile.whatsNextShowKnown = on
end

-- Whether the tab also lists the talents (and Season of Discovery's runes) not taken.
function ns.WhatsNextShowsTalents()
	return ns.db.profile.whatsNextShowTalents
end

function ns.SetWhatsNextShowTalents(on)
	ns.db.profile.whatsNextShowTalents = on
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
	The level a talent's tier opens at, by the talent's name, from the client's talent tree: a point a level
	from 10, and five in the tree for each tier down. Empty from MoP on, whose talents have no such tree.
]]
local function TalentLevels()
	local levels = {}
	local tabs = ns.GetNumTalentTabs()
	if not tabs or not GetNumTalents or not GetTalentInfo then
		return levels
	end
	for tab = 1, tabs do
		for index = 1, GetNumTalents(tab) or 0 do
			local name, _, tier = GetTalentInfo(tab, index)
			if name and tier then
				levels[name] = 10 + (tier - 1) * 5
			end
		end
	end
	return levels
end

--[[
	A row's source: a book, a quest (a rank only a class quest teaches) or a talent, as the trainer data marks
	it, else the trainer. A talent row on Season of Discovery is one of WoW Forever's talents that reuses a rune
	spell, which this client learns by engraving, so it's a rune unless the talent tree has it.
]]
local function RowSource(row, name, talentLevels)
	if row.book then
		return "BOOK"
	elseif row.quest then
		return "QUEST"
	elseif row.talent then
		if ns.IS_DISCOVERY and not talentLevels[name] then
			return "RUNE"
		end
		return "TALENT"
	end
	return "TRAINER"
end

--[[
	Every row for this character, unsorted, as { id, name, icon, subtext, level, source, requires, extra }: the
	trainer data's rows for its faction and race, the recorded trainer spells the data lacks, the extraSpells
	entries (extra), and the rank 1s no list names. A spell whose data isn't loaded yet is skipped:
	SPELL_DATA_LOAD_RESULT redraws the tab.
]]
local function CollectRows(talentLevels)
	local rows, seen = {}, {}
	local function add(id, source, level, requires, extra)
		if seen[id] then
			return
		end
		seen[id] = true
		local name = ns.SpellName(id)
		if not name then
			return
		end
		rows[#rows + 1] = {
			id = id,
			name = name,
			icon = C_Spell.GetSpellTexture(id),
			subtext = C_Spell.GetSpellSubtext(id),
			level = level,
			source = source,
			requires = requires or NO_IDS,
			extra = extra,
		}
	end
	for _, row in ipairs(ns.ClassTrainerRows()) do
		local name = ns.SpellName(row.id)
		local source = RowSource(row, name, talentLevels)
		-- a talent's level is the tier it sits in, where the tree says, else the row's
		local level = source == "TALENT" and name and talentLevels[name] or row.level
		add(row.id, source, level, row.requires)
	end
	for _, row in ipairs(ns.RecordedTrainerSpells and ns.RecordedTrainerSpells() or NO_IDS) do
		add(row.id, "TRAINER", row.level)
	end
	local levelLearned = C_Spell.GetSpellLevelLearned
	for _, entry in ipairs(ns.ClassExtraSpells()) do
		local id = type(entry) == "table" and entry[1] or entry
		local known = ns.EXTRA_SPELL_SOURCES[id] or NO_IDS
		local source, level = known[1], known[2]
		if source == "TALENT" then
			local name = ns.SpellName(id)
			level = name and talentLevels[name]
		end
		if not level and levelLearned then
			level = levelLearned(id)
		end
		add(id, source, level and level > 0 and level or nil, nil, true)
	end
	--[[
		A rank's earlier rank is in its requires under the same name. Where that's an extraSpells row (a rank 1
		a class quest teaches: Redemption, Searing Totem) it is one of the spell's ranks, not an extra; where no
		list has it, it's one the class starts with (Shadow Bolt, Fireball) unless ns.EXTRA_SPELL_SOURCES says
		otherwise, as Features/Spellbook/Spell-Ranks.lua reads it too.
	]]
	local byId = {}
	for _, row in ipairs(rows) do
		byId[row.id] = row
	end
	for i = 1, #rows do
		local row = rows[i]
		if not row.extra then
			for _, id in ipairs(row.requires) do
				if ns.SpellName(id) == row.name then
					if byId[id] then
						byId[id].extra = nil
					elseif not seen[id] then
						local known, count = ns.EXTRA_SPELL_SOURCES[id] or NO_IDS, #rows
						add(id, known[1] or "START", known[2] or 1)
						if #rows > count then
							byId[id] = rows[#rows]
						end
					end
				end
			end
		end
	end
	return rows
end

--[[
	Gives each row its status for a character at level, and the rows it waits on (row.waitsOn, the spells its
	requires names that aren't known): KNOWN once learned; TALENT for a talent or rune not taken; MISSING
	where a spell it needs can't come first (a talent not taken, or a spell from another source not learned
	yet), at any level, since it can't be learned until that changes; then by level, AVAILABLE once reached,
	SOON within SOON_LEVELS, LATER beyond. A rank whose earlier rank the same trainer teaches now is
	AVAILABLE too: both are learned in the one visit.
]]
local function SetStatuses(rows, level)
	--[[
		A rank counts as known when it is, or when a later rank of the same spell is: a client whose spellbook
		keeps only the highest rank no longer reports the ones it replaced. Only the ranks of the trainer rows
		count: an extraSpells entry can share a trainer spell's name (Polymorph (Pig) and Polymorph) without
		being one of its ranks.
	]]
	local byId, highestKnown = {}, {}
	for _, row in ipairs(rows) do
		byId[row.id] = row
		if row.level and not row.extra and ns.IsPlayerSpell(row.id) then
			highestKnown[row.name] = math.max(highestKnown[row.name] or 0, row.level)
		end
	end
	local function isKnown(id)
		if ns.IsPlayerSpell(id) then
			return true
		end
		local row = byId[id]
		return row ~= nil and not row.extra and row.level ~= nil and row.level <= (highestKnown[row.name] or 0)
	end
	local function status(row)
		if row.status then
			return row.status
		end
		row.status = "PENDING" -- a requires loop ends here rather than recursing forever
		local result
		if isKnown(row.id) then
			result = "KNOWN"
		elseif row.source == "TALENT" or row.source == "RUNE" then
			result = "TALENT"
		else
			row.waitsOn = {}
			local blocked = false
			for _, id in ipairs(row.requires) do
				if not isKnown(id) then
					row.waitsOn[#row.waitsOn + 1] = id
					local required = byId[id]
					local requiredStatus = required and status(required)
					-- learnable alongside it only when the same trainer teaches it by now
					local alongside = requiredStatus == "AVAILABLE" and required.source == "TRAINER"
					local coming = requiredStatus == "SOON" or requiredStatus == "LATER"
					if not alongside and not coming then
						blocked = true
					end
				end
			end
			if blocked then
				result = "MISSING"
			elseif not row.level or row.level <= level then
				result = "AVAILABLE"
			elseif row.level <= level + SOON_LEVELS then
				result = "SOON"
			else
				result = "LATER"
			end
		end
		row.status = result
		return result
	end
	for _, row in ipairs(rows) do
		status(row)
	end
end

--[[
	The rows for this character as { id, name, icon, subtext, level, source, status, waitsOn }, unsorted.
	level is the level to read the statuses against, for PLAYER_LEVEL_UP, whose new level UnitLevel doesn't
	report yet; it defaults to the player's.
]]
function ns.WhatsNextRows(level)
	local rows = CollectRows(TalentLevels())
	SetStatuses(rows, level or UnitLevel("player"))
	return rows
end
