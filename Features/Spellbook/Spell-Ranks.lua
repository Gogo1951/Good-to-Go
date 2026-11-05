local _, ns = ...

--[[
	The spell ranks the player knows and the levels the rest are learned at, read from the spellbook and the
	trainer data for Features/Spellbook/Macro-Builder/Macro-Builder.lua.
]]

local SpellName = ns.SpellName
local NO_IDS = {}

-- The class's trainer data rows this character can learn: those for any faction and race, or for its own.
function ns.ClassTrainerRows()
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	local rows = {}
	for _, row in ipairs(ns.TRAINER_SPELLS and ns.TRAINER_SPELLS[select(2, UnitClass("player"))] or NO_IDS) do
		if (not row.faction or row.faction == faction) and (not row.race or row.race == race) then
			rows[#rows + 1] = row
		end
	end
	return rows
end

--[[
	Each spell id's learn level: the class's trainer data (ns.ClassTrainerRows), then the trainers this
	character recorded. A rank 1 the class starts with (Frost Armor, Fireball) has no
	trainer row, only its Rank 2's requires, so a required spell of the same name without a level of its own
	is learned at level 1. The client's own answer (C_Spell.GetSpellLevelLearned, where it has one) fills the
	rest.
]]
local function LearnLevels()
	local levels, rows = {}, ns.ClassTrainerRows()
	for _, row in ipairs(rows) do
		levels[row.id] = row.level
	end
	for id, level in pairs(ns.RecordedTrainerSpellLevels()) do
		levels[id] = levels[id] or level
	end
	for _, row in ipairs(rows) do
		for _, id in ipairs(row.requires or NO_IDS) do
			if not levels[id] then
				local name = SpellName(id)
				if name and name == SpellName(row.id) then
					levels[id] = 1
				end
			end
		end
	end
	return levels
end

--[[
	Trainer rank ids whose names weren't loaded when the spellbook was last read, so their ranks were left out;
	SPELL_DATA_LOAD_RESULT redraws the open page as each arrives (see ns.TakePendingRank).
]]
local pendingRanks = {}

-- Whether id is a rank ReadSpellbook left out for want of its name; clears it, so it redraws the page once.
function ns.TakePendingRank(id)
	local pending = pendingRanks[id] == true
	pendingRanks[id] = nil
	return pending
end

--[[
	One pass over the spellbook: the ranks of each learned spell with more than one, as
	name -> { known = { { text = "Rank 4", level = 38, id = 8417 }, ... }, unknown = { ... } or nil }, each list highest
	first (a rank whose learn level isn't known is left out), and every learned spell's name, as name -> true.
	Classic's book lists only each spell's highest rank unless Show All Spell Ranks is ticked, so the known
	trainer ranks are added from their ids as well, then the trainer ranks not learned yet.
]]
local function ReadSpellbook()
	local levels, byName, learned, listed = LearnLevels(), {}, {}, {}
	local levelLearned = C_Spell.GetSpellLevelLearned
	local function addRank(name, subName, level, id, unknown)
		if name and subName and subName ~= "" and level and level > 0 and not listed[name .. subName] then
			listed[name .. subName] = true
			byName[name] = byName[name] or {}
			table.insert(byName[name], { text = subName, level = level, id = id, unknown = unknown })
		end
	end
	ns.ForEachClassSpell(function(name, _, id, _, _, subName)
		if name then
			learned[name] = true
		end
		addRank(name, subName, id and (levels[id] or (levelLearned and levelLearned(id))), id)
	end)
	for id, level in pairs(levels) do
		if ns.IsPlayerSpell(id) then
			local name = SpellName(id)
			if learned[name] then
				addRank(name, C_Spell.GetSpellSubtext(id), level, id)
			end
		end
	end
	-- after the known ranks, so a known rank's text is never taken by an unknown id of the same name
	wipe(pendingRanks)
	for id, level in pairs(levels) do
		if not ns.IsPlayerSpell(id) then
			local name = SpellName(id)
			if not name then
				pendingRanks[id] = true
			elseif learned[name] then
				addRank(name, C_Spell.GetSpellSubtext(id), level, id, true)
			end
		end
	end
	local ranks = {}
	for name, list in pairs(byName) do
		if #list > 1 then
			table.sort(list, function(a, b)
				return a.level > b.level
			end)
			local known, unknown = {}, {}
			for _, rank in ipairs(list) do
				if not rank.unknown then
					table.insert(known, rank)
				end
			end
			--[[
				A rank at or below the highest known one was learned and then replaced: a client whose spellbook
				keeps only the highest rank (Forever) no longer reports it, so it isn't one still to learn (as
				What's Next? reads it, Whats-Next.lua SetStatuses). It isn't added to known either, since the
				client no longer holds it to cast.
			]]
			local highestKnown = known[1] and known[1].level or 0
			for _, rank in ipairs(list) do
				if rank.unknown and rank.level > highestKnown then
					table.insert(unknown, rank)
				end
			end
			if #known > 0 then
				ranks[name] = { known = known, unknown = #unknown > 0 and unknown or nil }
			end
		end
	end
	return ranks, learned
end

ns.ReadSpellbook = ReadSpellbook
