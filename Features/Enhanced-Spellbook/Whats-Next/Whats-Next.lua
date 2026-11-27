local _, ns = ...

local NO_IDS = {}

-- Within this many levels of the player's, an unlearned spell is Coming Soon rather than Not Yet Available.
local SOON_LEVELS = 2

--[[
	In Sort By Availability's order. MISSING needs another spell first, at any level; TALENT is a talent not
	taken, a choice rather than something coming.
]]
ns.WHATS_NEXT_STATUSES = { "AVAILABLE", "SOON", "LATER", "MISSING", "TALENT", "KNOWN" }

ns.WHATS_NEXT_SOURCES = { "START", "TRAINER", "BOOK", "QUEST", "TALENT", "RUNE" }

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

-- "availability" or "level"
function ns.WhatsNextSort()
	return ns.db.profile.whatsNextSort
end

function ns.SetWhatsNextSort(sort)
	ns.db.profile.whatsNextSort = sort
end

function ns.WhatsNextShowsKnown()
	return ns.db.profile.whatsNextShowKnown
end

function ns.SetWhatsNextShowKnown(on)
	ns.db.profile.whatsNextShowKnown = on
end

-- Season of Discovery's runes count as talents.
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
	By talent name: a point a level from 10, and five in the tree for each tier down. Empty from MoP on, whose
	talents have no such tree.
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
	A talent row on Season of Discovery is one of WoW Forever's talents that reuses a rune spell, which this
	client learns by engraving, so it's a rune unless the talent tree has it.
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
	Unsorted { id, name, icon, subtext, level, source, requires, extra, ids }. An extraSpells entry listing
	alternatives ({ 13819, 34769 }: Summon Warhorse and its Blood Elf version) is one row with every alternative in
	ids, so whichever the character knows counts. A spell whose data isn't loaded yet is skipped:
	SPELL_DATA_LOAD_RESULT redraws the tab.
]]
local function CollectRows(talentLevels)
	local rows, seen = {}, {}
	local function add(id, source, level, requires, extra, ids)
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
			subtext = ns.SpellSubtext(id),
			level = level,
			source = source,
			requires = requires or NO_IDS,
			extra = extra,
			ids = ids,
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
	for _, entry in ipairs(ns.ClassExtraSpells()) do
		local ids = type(entry) == "table" and entry or { entry }
		local id = ids[1]
		local known = ns.EXTRA_SPELL_SOURCES[id] or NO_IDS
		local source, level = known[1], known[2]
		if source == "TALENT" then
			local name = ns.SpellName(id)
			level = name and talentLevels[name]
		end
		if not level then
			level = C_Spell.GetSpellLevelLearned(id)
		end
		add(id, source, level and level > 0 and level or nil, nil, true, ids)
	end
	--[[
		A rank's earlier rank is in its requires under the same name. An extraSpells row there (a class quest's
		rank 1: Redemption, Searing Totem) is one of the spell's ranks, not an extra; one no list has is a spell
		the class starts with (Shadow Bolt, Fireball) unless ns.EXTRA_SPELL_SOURCES says otherwise.
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

local function AnyKnown(ids)
	for _, id in ipairs(ids or NO_IDS) do
		if ns.IsPlayerSpell(id) then
			return true
		end
	end
	return false
end

--[[
	MISSING where a spell it needs can't come first (a talent not taken, or one from another source), at any level.
	A rank whose earlier rank the same trainer teaches now is AVAILABLE too: both are learned in the one visit.
]]
local function SetStatuses(rows, level)
	--[[
		A later rank known counts: a client whose spellbook keeps only the highest rank no longer reports the ones
		it replaced. Only trainer rows count, since an extraSpells entry can share a trainer spell's name
		(Polymorph (Pig) and Polymorph) without being one of its ranks.
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
		if isKnown(row.id) or AnyKnown(row.ids) then
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

-- level is for PLAYER_LEVEL_UP, whose new level UnitLevel doesn't report yet.
function ns.WhatsNextRows(level)
	local rows = CollectRows(TalentLevels())
	SetStatuses(rows, level or UnitLevel("player"))
	return rows
end
