local _, ns = ...

local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local NO_SLOTS = ns.NO_SLOTS

-- The macro casts the last learned of the ticked spells, so it moves up as the player trains.
function ns.OffersGroupedSpells(macro)
	return macro.groupMembers ~= nil
end

-- The default ticks.
local function GroupNames(macro)
	local names = {}
	for i, member in ipairs(macro.groupMembers) do
		names[i] = member.name
	end
	return names
end

-- Saved by Rank 1 ID, so the ticks hold in any game language.
function ns.GroupedSpells(macro)
	if not ns.OffersGroupedSpells(macro) then
		return NO_SLOTS
	end
	local ids = SpellSettings("groupedSpells")[SettingsKey(macro)]
	if not ids then
		return GroupNames(macro)
	end
	local ticked = {}
	for _, id in ipairs(ids) do
		ticked[id] = true
	end
	local names = {}
	for _, member in ipairs(macro.groupMembers) do
		if ticked[member.id] then
			names[#names + 1] = member.name
		end
	end
	return names
end

function ns.IsGroupedSpellOn(macro, name)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked == name then
			return true
		end
	end
	return false
end

-- Only a tick besides its own spell changes the macro.
function ns.IsGrouped(macro)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked ~= macro.name then
			return true
		end
	end
	return false
end

-- Unticking the last ticks the macro's own spell again; the whole group ticked is stored as nil.
function ns.ToggleGroupedSpell(macro, name)
	local on = not ns.IsGroupedSpellOn(macro, name)
	local list = {}
	for _, member in ipairs(macro.groupMembers) do
		local ticked = on
		if member.name ~= name then
			ticked = ns.IsGroupedSpellOn(macro, member.name)
		end
		if ticked then
			list[#list + 1] = member.id
		end
	end
	if #list == 0 then
		list[1] = macro.baseID
	end
	SpellSettings("groupedSpells")[SettingsKey(macro)] = #list < #macro.groupMembers and list or nil
end

-- Shoot casts the equipped ranged weapon's attack; else the last learned of the ticked spells, else its own.
function ns.CastSpellName(macro)
	if macro.rangedAttacks then
		return ns.EquippedRangedAttack(macro)
	end
	local ticked = {}
	for _, name in ipairs(ns.GroupedSpells(macro)) do
		ticked[name] = true
	end
	local cast
	for _, member in ipairs(ns.OffersGroupedSpells(macro) and macro.groupMembers or NO_SLOTS) do
		if member.learned and ticked[member.name] then
			cast = member.name
		end
	end
	return cast or macro.name
end
