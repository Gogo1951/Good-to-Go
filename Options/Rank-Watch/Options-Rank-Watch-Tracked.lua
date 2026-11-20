local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Rank Watch Reported Ranks Panel
--------------------------------------------------------------------------------

--[[
    "Reported Ranks", under Rank Watch: every ability it watches, class by class down the tree on the left
    (alphabetical), and under each ability a checkbox for each of its ranks. Unticking a rank
    means a cast of that rank is never reported, so a player who lowers a spell on purpose can say so. The ranks
    the data marks off (Rank 1 Scorch and the like) start unticked; see ns.IsRankWatchRankTracked.

    Every ability the class has is listed, one-rank spells and talents too; those Rank Sentinel never watched
    (heals, Shadowform, utility) start with every rank unticked. A ladder's top rank is listed grayed: nothing is
    higher, so it is never reported, but it shows how many ranks the ability has. Spells joined by ns.SPELL_GROUPS
    share one box, the Enhanced Spellbook's own groups, and their ranks carry the spell's name too.

    Not hidden behind the Rank Watch switch, like the Group Buffs panel under Buff Duty: these are choices worth
    making before turning it on, and the page opens with a line saying so while it's off (ns.AddFeatureOffLine). Registered as a function, so names the client loads later fill in on reopen.
]]

local function SpellName(spellID)
	local name = C_Spell.GetSpellName(spellID)
	if not name then
		C_Spell.RequestLoadSpellData(spellID)
	end
	return name or L["TRACKED_SPELL_PENDING"]:format(spellID)
end

-- The ability's box title: its icon, then each distinct spell name on the ladder, joined.
local function LadderTitle(ladder)
	local names, seen = {}, {}
	for _, row in ipairs(ladder.rows) do
		local name = SpellName(row.id)
		if not seen[name] then
			seen[name] = true
			names[#names + 1] = name
		end
	end
	local title = table.concat(names, L["LIST_SEPARATOR"])
	local texture = C_Spell.GetSpellTexture(ladder.rows[#ladder.rows].id)
	if texture then
		title = "|T" .. texture .. ":16|t " .. title
	end
	return title
end

-- "Rank 3 (Level 20)", with the spell's name first in a joined group, where ranks of two spells sit side by side.
local GetSpellLevelLearned = C_Spell.GetSpellLevelLearned

local function RankLabel(ladder, row)
	local level = row.level or (GetSpellLevelLearned and GetSpellLevelLearned(row.id))
	local label = ns.RankWatchRankText(row)
	if level and level > 0 then
		label = L["RANK_WATCH_RANK_LEVEL"]:format(label, level)
	end
	if ladder.isGroup then
		label = SpellName(row.id) .. " " .. label
	end
	return label
end

local function SetLadder(ladder, tracked)
	for i = 1, #ladder.rows - 1 do
		ns.SetRankWatchRankTracked(ladder.rows[i], tracked)
	end
end

--[[
    The top rank's row is grayed, since nothing above it can be reported, and checked while any rank below it is:
    it reads as the ability being watched. A one-rank ability, or one whose ranks all start off (heals, talents,
    everything Rank Sentinel never watched), shows it unchecked.
]]
local function LadderWatched(ladder)
	for i = 1, #ladder.rows - 1 do
		if ns.IsRankWatchRankTracked(ladder.rows[i]) then
			return true
		end
	end
	return false
end

-- Whether any rank below a page's tops reads as `tracked`: true means Check All (or Uncheck All) has something to change.
local function AnyRankIs(sorted, tracked)
	for _, entry in ipairs(sorted) do
		local rows = entry.ladder.rows
		for i = 1, #rows - 1 do
			if (ns.IsRankWatchRankTracked(rows[i]) and true or false) == tracked then
				return true
			end
		end
	end
	return false
end

local function AbilityGroup(ladder, order)
	local args = {}
	for i, row in ipairs(ladder.rows) do
		local isTop = i == #ladder.rows
		args["rank" .. i] = {
			type = "toggle",
			name = RankLabel(ladder, row),
			desc = L[isTop and "RANK_WATCH_TOP_RANK_DESCRIPTION" or "RANK_WATCH_RANK_DESCRIPTION"],
			tooltipHyperlink = "spell:" .. row.id,
			order = i,
			width = ladder.isGroup and 1.5 or "normal",
			disabled = isTop,
			get = function()
				if isTop then
					return LadderWatched(ladder)
				end
				return ns.IsRankWatchRankTracked(row)
			end,
			set = function(_, value)
				ns.SetRankWatchRankTracked(row, value)
				ns.RefreshSettings()
			end,
		}
	end
	return { type = "group", name = LadderTitle(ladder), inline = true, order = order, args = args }
end

--[[
    One page of the tree: Check All and Uncheck All, then one box per ability, alphabetical. A class's page, and
    right after Hunter and Warlock a Hunter Pets or Warlock Pets page for their pets' and demons', the owner's to
    fix and so listed beside the owner's class, where the flavor's pets have ranks at all. Check All on either page
    sets that page's abilities only, asks first with the page's plain name (plainName) filled in, and grays out
    while every box it would tick is ticked already; Uncheck All likewise.
]]
-- The title as read, for sorting: no icon, no color codes, case folded.
local function SortKey(title)
	return (title:gsub("|T.-|t", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s+", ""):lower())
end

local function AbilityPage(name, plainName, list, order)
	local sorted = {}
	for _, ladder in ipairs(list or {}) do
		local title = LadderTitle(ladder)
		sorted[#sorted + 1] = { ladder = ladder, title = title, key = SortKey(title) }
	end
	table.sort(sorted, function(a, b)
		if a.key ~= b.key then
			return a.key < b.key
		end
		return a.ladder.id < b.ladder.id
	end)
	-- Check All in the pane's label column and Uncheck All in its control column, one row, not two lone buttons.
	local args = {
		buttons = Kit.Row(1, nil, {
			{
				type = "execute",
				name = L["RANK_WATCH_TRACK_ALL"],
				desc = L["RANK_WATCH_TRACK_ALL_DESCRIPTION"],
				width = Kit.TREE_LABEL_WIDTH,
				confirm = function()
					return L["RANK_WATCH_TRACK_ALL_CONFIRM"]:format(plainName)
				end,
				disabled = function()
					return not AnyRankIs(sorted, false)
				end,
				func = function()
					for _, entry in ipairs(sorted) do
						SetLadder(entry.ladder, true)
					end
					ns.RefreshSettings()
				end,
			},
			{
				type = "execute",
				name = L["RANK_WATCH_TRACK_NONE"],
				desc = L["RANK_WATCH_TRACK_NONE_DESCRIPTION"],
				width = Kit.TREE_CONTROL_WIDTH,
				confirm = function()
					return L["RANK_WATCH_UNTRACK_ALL_CONFIRM"]:format(plainName)
				end,
				disabled = function()
					return not AnyRankIs(sorted, true)
				end,
				func = function()
					for _, entry in ipairs(sorted) do
						SetLadder(entry.ladder, false)
					end
					ns.RefreshSettings()
				end,
			},
		}),
	}
	for index, entry in ipairs(sorted) do
		args["ability" .. entry.ladder.id] = AbilityGroup(entry.ladder, 10 + index)
	end
	return { type = "group", name = name, order = order, args = args }
end

-- "Hunter Pets", plain for the Check All question, and in the class color for the tree, like the class's own entry above it.
local function PlainPetsName(class)
	return L["RANK_WATCH_PETS"]:format(LOCALIZED_CLASS_NAMES_MALE[class] or class)
end

local function PetsName(class)
	local color = ns.GetClassColor(class) or ns.GetColor("TEXT")
	return color .. PlainPetsName(class) .. "|r"
end

function ns.BuildRankWatchTrackedOptions()
	local options = {
		name = Kit.SubPanelTitle(L["TAB_RANK_WATCH"], L["RANK_WATCH_TRACKED_HEADER"]),
		type = "group",
		childGroups = "tree",
		args = {
			description = Kit.Desc(L["RANK_WATCH_TRACKED_DESCRIPTION"], 1),
		},
	}
	ns.AddFeatureOffLine(options.args, "rankWatch.enabled")
	local classes, seen = {}, {}
	for _, byClass in ipairs({ ns.RankWatchLadders(), ns.RankWatchPetLadders() }) do
		for class in pairs(byClass) do
			if not seen[class] then
				seen[class] = true
				classes[#classes + 1] = class
			end
		end
	end
	table.sort(classes, function(a, b)
		return (LOCALIZED_CLASS_NAMES_MALE[a] or a) < (LOCALIZED_CLASS_NAMES_MALE[b] or b)
	end)
	local pets = ns.RankWatchPetLadders()
	for index, class in ipairs(classes) do
		local plainName = LOCALIZED_CLASS_NAMES_MALE[class] or class
		options.args[class] = AbilityPage(ns.ClassName(class), plainName, ns.RankWatchLadders()[class], index * 2)
		if pets[class] then
			options.args[class .. "_PETS"] =
				AbilityPage(PetsName(class), PlainPetsName(class), pets[class], index * 2 + 1)
		end
	end
	return options
end
