local _, ns = ...
local L = ns.L

-- The class lists hold spell IDs; every name comes from the client, so the page builds the same in every locale.

local MacroBody = ns.MacroBody
local StancesOf = ns.StancesOf
local SpellName = ns.SpellName
local ClassConfig = ns.ClassConfig
local ResolveClassConfig = ns.ResolveClassConfig
local TargetOf = ns.TargetOf
local ReadSpellbook = ns.ReadSpellbook
local ReplacedSpells = ns.ReplacedSpells
local FoldRangedAttacks = ns.FoldRangedAttacks

local UNLISTED = math.huge -- the Unlearned section sorts after everything else
local NO_IDS = {}

-- Rebuilt when the page draws, the spells change, or Dynamic Rank finds it empty.
ns.macros = {}

--[[
	Settings, tag and Duplicates are keyed by the Rank 1 ID, so they outlast a rank trained and a change of game
	language. ranks.baseID is recorded before replaced ranks are dropped.
]]
local function BaseSpellID(name, id, ranks, members)
	for _, member in ipairs(members or NO_IDS) do
		if member.name == name then
			return member.id
		end
	end
	if ranks and ranks.baseID then
		return ranks.baseID
	end
	local lowest
	for _, list in ipairs({ ranks and ranks.known or NO_IDS, ranks and ranks.unknown or NO_IDS }) do
		for _, rank in ipairs(list) do
			if not lowest or rank.level < lowest.level then
				lowest = rank
			end
		end
	end
	return lowest and lowest.id or id
end

--[[
	section is { rank, name, priority }. grouped is { groupSpell, soloSpell (what a right-click casts),
	rightClickRanks, groupMembers ({ name, id, learned } in learn order) }. The caller sets replaces after.
]]
local function MakeMacro(name, icon, unlearned, id, section, ranks, grouped)
	local config = ClassConfig()
	local pet = config.petAbilities[name]
	local macro = {
		name = name,
		spellID = id,
		baseID = BaseSpellID(name, id, ranks, grouped.groupMembers),
		unlearned = unlearned,
		categoryRank = section[1],
		priority = section[3],
		category = section[2],
		noGlow = config.formSpells[name] == true,
		target = TargetOf(name, id),
		buff = config.buffSpells[name] ~= nil,
		resurrect = config.resurrectSpells[name] ~= nil,
		pageTag = config.pageTags[name], -- what the spell is for, which sorts the page (see ns.PageCategory)
		cursor = config.cursorSpells[name] ~= nil,
		petAbility = pet and pet.ability,
		petFamily = pet and pet.family,
		stealth = config.stealthSpells[name] ~= nil,
		stances = StancesOf(name),
		toggles = config.toggleSpells[name] ~= nil,
		ranks = ranks and ranks.known,
		unknownRanks = ranks and ranks.unknown,
		groupSpell = grouped.groupSpell,
		soloSpell = grouped.soloSpell,
		rightClickRanks = grouped.rightClickRanks,
		groupMembers = grouped.groupMembers,
		macroName = ns.TrimMacroName(name),
		-- the question mark icon lets #showtooltip show the spell's own icon on the action bar
		macroIcon = ns.QUESTION_MARK_ICON,
		icon = icon or ns.QUESTION_MARK_ICON,
	}
	macro.kind = ns.MacroKind(macro)
	macro.body = MacroBody(macro)
	return macro
end

local function MakeCopyMacro(macro, number)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	local suffix = " " .. number
	copy.copy = number
	copy.label = macro.name .. suffix
	copy.macroName = ns.TrimMacroName(macro.name, ns.MACRO_NAME_MAX_LENGTH - #suffix) .. suffix
	copy.body = MacroBody(copy)
	return copy
end

-- A rank copy casts only its own spell, with no group and no right-click.
local function MakeRankMacro(macro, rank, rankIndex)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	local suffix = L["MACRO_NAME_RANK_SUFFIX"]:format(rank:match("%d+") or rank)
	copy.rank = rank
	copy.rankIndex = rankIndex
	copy.rankID = macro.ranks[rankIndex].id
	copy.groupMembers, copy.groupSpell, copy.soloSpell, copy.rightClickRanks = nil, nil, nil, nil
	copy.macroName = ns.TrimMacroName(macro.name, ns.MACRO_NAME_MAX_LENGTH - #suffix) .. suffix
	copy.body = MacroBody(copy)
	return copy
end

-- Cleanse, for Purify
local function LaterGroupSpellLearned(name, members)
	local after = false
	for _, member in ipairs(members or NO_IDS) do
		if after and member.learned then
			return true
		end
		after = after or member.name == name
	end
	return false
end

--[[
	The profession's macro takes the specialization's name and icon but still casts the profession; the
	specialization, a passive that does nothing when cast, goes off the page. Its Duplicates keep their own names.
]]
local function FoldSpecializations()
	local own = {}
	for _, macro in ipairs(ns.macros) do
		if not macro.copy and not macro.rank then
			own[macro.name] = macro
		end
	end
	local folded = {}
	for _, ids in ipairs(ns.PROFESSION_SPECIALIZATIONS or NO_IDS) do
		local profession, shown = own[SpellName(ids[1])], nil
		for i = 2, #ids do
			local specialization = own[SpellName(ids[i])]
			if specialization and profession then
				folded[specialization.name] = true
				shown = specialization
			end
		end
		if shown then
			profession.label, profession.sortName, profession.icon = shown.name, shown.name, shown.icon
		end
	end
	for _, macro in ipairs(ns.macros) do
		if folded[macro.name] then
			macro.hidden = true
		end
	end
end

function ns.CollectMacros()
	wipe(ns.macros)
	ns.MarkRankBodiesStale()
	ResolveClassConfig()
	local taken, seen = {}, {}
	local ranks, learned = ReadSpellbook()
	local function AddMacro(name, icon, unlearned, id, section, learnLevel, learnTalent)
		local config = ClassConfig()
		local groupSpell, soloSpell, members = config.groupSpells[name], config.soloSpells[name], nil
		local groupIds = config.spellGroupIds[name]
		for i, member in ipairs(config.spellGroups[name] or NO_IDS) do
			members = members or {}
			members[#members + 1] = { name = member, id = groupIds[i], learned = learned[member] == true }
		end
		-- before the macro is made, so its text carries the macro and settings it takes over
		local replaced, replacedIds = NO_IDS, NO_IDS
		if not unlearned and members then
			replaced, replacedIds = ReplacedSpells(name, members)
		end
		ns.HandOverMacro(BaseSpellID(name, id, nil, members), replacedIds)
		groupSpell = groupSpell and learned[groupSpell] and groupSpell or nil
		soloSpell = soloSpell and learned[soloSpell] and soloSpell or nil
		local rightClick = groupSpell or soloSpell
		local macro = MakeMacro(name, icon, unlearned, id, section, not unlearned and ranks[name] or nil, {
			groupSpell = groupSpell,
			soloSpell = soloSpell,
			rightClickRanks = rightClick and ranks[rightClick] and ranks[rightClick].known,
			groupMembers = members,
		})
		macro.replaces = replaced[1] and replaced or nil
		macro.learnLevel, macro.learnTalent = learnLevel, learnTalent
		-- off the page, but still rewritten, with its copies; before they are made, so they carry it
		macro.hidden = not unlearned and not ns.ShowsGroupedSpells() and LaterGroupSpellLearned(name, members)
		taken[macro.macroName] = true
		ns.macros[#ns.macros + 1] = macro
		if not unlearned then
			for _, number in ipairs(ns.MacroCopies(ns.MacroSpellKey(macro))) do
				local copy = MakeCopyMacro(macro, number)
				taken[copy.macroName] = true
				ns.macros[#ns.macros + 1] = copy
			end
		end
		-- the spell's own macro casts the highest
		if not unlearned and ns.ShowsAllRanks() then
			for i = 2, #(macro.ranks or NO_IDS) do
				local copy = MakeRankMacro(macro, macro.ranks[i].text, i)
				if not taken[copy.macroName] then
					taken[copy.macroName] = true
					ns.macros[#ns.macros + 1] = copy
				end
			end
		end
	end
	local position = 0
	local tabRanks = ClassConfig().categoryRankByName
	ns.ForEachClassSpell(function(name, icon, id, lineName, line)
		tabRanks[lineName] = tabRanks[lineName] or line
		if name and not seen[name] then -- older books list each rank separately
			seen[name] = true
			position = position + 1
			AddMacro(name, icon, nil, id, { line, lineName, position })
		end
	end)
	FoldSpecializations()
	FoldRangedAttacks()
	if ns.ShowsUnlearned() and ns.ForEachUnlearnedSpell then
		ns.ForEachUnlearnedSpell(function(name, icon, id, level, talent)
			position = position + 1
			AddMacro(name, icon, true, id, { UNLISTED, L["SECTION_UNLEARNED"], position }, level, talent)
		end, seen)
	end
	local function CopyOrder(macro)
		return macro.rankIndex and (1 + macro.rankIndex) or 0
	end
	-- a spell's own macro, then its rank copies highest first, then its Duplicates by number
	table.sort(ns.macros, function(a, b)
		if a.categoryRank ~= b.categoryRank then
			return a.categoryRank < b.categoryRank
		end
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		if a.name ~= b.name then
			return a.name < b.name
		end
		if (a.copy or 1) ~= (b.copy or 1) then
			return (a.copy or 1) < (b.copy or 1)
		end
		return CopyOrder(a) < CopyOrder(b)
	end)
end
