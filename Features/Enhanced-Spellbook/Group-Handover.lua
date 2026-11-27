local _, ns = ...

local NO_IDS = {}

--[[
	Bear Form leaves the book once Dire Bear Form is learned, so its WoW macro would never be rewritten again;
	the new spell takes it over. members is { name, id, learned }; returns names, then Rank 1 IDs.
]]
local function ReplacedSpells(name, members)
	local replaced, ids, at = {}, {}, nil
	for i, member in ipairs(members) do
		if member.name == name then
			at = i
		end
	end
	for i = (at or 1) - 1, 1, -1 do
		if members[i].learned then
			break
		end
		replaced[#replaced + 1] = members[i].name
		ids[#ids + 1] = members[i].id
	end
	return replaced, ids
end

--[[
	Only while the learned spell has no macro of its own. The sync then finds the macros by tag, rewrites and
	renames them (SyncAt reads macro.replaces).
]]
function ns.HandOverMacro(baseID, replacedIds)
	for _, from in ipairs(replacedIds) do
		if ns.HandOverMacroTag(from, baseID, ns.MacroCopies(ns.MacroSpellKey({ baseID = from }))) then
			ns.MoveSpellSettings(from, baseID)
			return
		end
	end
end

-- Read from spell IDs alone, so a spell learned with no page open still takes its macro over.
function ns.HandOverDue()
	local class = select(2, UnitClass("player"))
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for i = #ids, 2, -1 do
			if ns.IsPlayerSpell(ids[i]) and not ns.HasSpellMacroTag(ids[i]) then
				for j = i - 1, 1, -1 do
					if ns.IsPlayerSpell(ids[j]) then
						break
					end
					if ns.HasSpellMacroTag(ids[j]) then
						return true
					end
				end
			end
		end
	end
	return false
end

-- Which of the class's SPELL_GROUPS spells the player knows, as one string of 1s and 0s.
local function GroupSpellsKnown()
	local class = select(2, UnitClass("player"))
	local known = {}
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for _, id in ipairs(ids) do
			known[#known + 1] = ns.IsPlayerSpell(id) and "1" or "0"
		end
	end
	return table.concat(known)
end

local groupSpellsKnown -- as the last call to ns.GroupSpellLearned found them

-- A group spell learned or lost can move a grouped macro to another spell. The first call only takes note.
function ns.GroupSpellLearned()
	local known = GroupSpellsKnown()
	local changed = groupSpellsKnown ~= nil and known ~= groupSpellsKnown
	groupSpellsKnown = known
	return changed
end

ns.ReplacedSpells = ReplacedSpells
