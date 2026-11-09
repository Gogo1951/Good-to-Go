local _, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Rank Watch Panel
--------------------------------------------------------------------------------

--[[
    The switch and the two grace periods, how Rank Watch speaks up, how a player opts out, and who reports for
    the group. Which ranks
    it watches and the players it leaves alone are the Tracked Abilities and Ignored Players panels under this
    one. Every setting is
    account-wide (ns.db.global.rankWatch; Data/Default-Settings.lua says why). The messages are fixed: one
    whisper and one print, with no flavors to pick and no template to edit.
]]

local function Settings()
	return ns.RankWatchSettings()
end

local function Refresh()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.RankWatch)
end

local function Toggle(key, name, desc, order)
	return {
		type = "toggle",
		name = L[name],
		desc = L[desc],
		order = order,
		width = "full",
		get = function()
			return Settings()[key]
		end,
		set = function(_, value)
			Settings()[key] = value
			if key == "whisper" then
				ns.SyncRankWatchEvents()
			end
			Refresh()
		end,
	}
end

--[[
    The Examples' sample cast: the lowest and highest ranks of one of the player's own class's abilities, so the
    lines show spells the player knows, and the class they belong to. Any class serves where theirs has none.
]]
local function SampleRows()
	local ladders = ns.RankWatchLadders()
	local _, playerClass = UnitClass("player")
	local otherClass, otherList = next(ladders)
	for _, candidate in ipairs({ { playerClass, ladders[playerClass] }, { otherClass, otherList } }) do
		local class, list = candidate[1], candidate[2]
		for _, ladder in ipairs(list or {}) do
			if #ladder.rows > 1 then
				return ladder.rows[1], ladder.rows[#ladder.rows], class
			end
		end
	end
	return nil
end

local function WhisperExample()
	local castRow, betterRow = SampleRows()
	return castRow and ns.BuildRankWatchWhisper(castRow, betterRow) or ""
end

-- The caster is the house roster's name for the sample spell's class, borrowing a name for a class with none.
local function PrintExample()
	local castRow, betterRow, class = SampleRows()
	if not castRow then
		return nil
	end
	local name = ns.ClassColoredName(ns.SAMPLE_NAMES[class] or ns.SAMPLE_NAMES.WARRIOR, class)
	return ns.BuildRankWatchOtherLine(name, castRow, betterRow)
end

-- The opt-out whisper as it would go to the player themself, with their own number.
local function OptOutExample()
	return ns.BuildRankWatchOptOutWhisper(UnitName("player"))
end

-- An Example shows only while its message is on, so it never shows a message the player hasn't chosen.
local function WhisperOff()
	return not Settings().whisper
end

local function PrintOff()
	return not Settings().print
end

local function WhispererText()
	local whisperer = ns.RankWatchWhisperer()
	if whisperer == "self" then
		return L["RANK_WATCH_WHISPERER_SELF"]
	elseif whisperer then
		return L["RANK_WATCH_WHISPERER_OTHER"]:format(whisperer)
	end
	return L["RANK_WATCH_WHISPERER_NONE"]
end

--[[
    A grace period: a label, then a dropdown of 0 to 5 levels beside it. The check takes this many levels off the
    caster's level before asking which rank they could have, so a rank only just reached isn't reported.
]]
local GRACE_MAX = 5

local function GraceValues()
	local values, sorting = {}, {}
	for levels = 0, GRACE_MAX do
		values[levels] = levels == 1 and L["RANK_WATCH_GRACE_LEVEL"] or L["RANK_WATCH_GRACE_LEVELS"]:format(levels)
		sorting[#sorting + 1] = levels
	end
	return values, sorting
end

local function GraceRow(args, key, name, desc, order)
	local values, sorting = GraceValues()
	args[key .. "Label"] = ns.OptionsRowLabel(L[name], order)
	args[key] = {
		type = "select",
		name = "",
		desc = L[desc],
		order = order + 0.01,
		width = ns.OPTIONS_CONTROL_WIDTH,
		values = values,
		sorting = sorting,
		get = function()
			return Settings()[key]
		end,
		set = function(_, value)
			Settings()[key] = value
			Refresh()
		end,
	}
end

-- The standalone add-on's notice and the space above it, shown only while that add-on runs.
local function StandaloneHidden()
	return not ns.RankWatchStandaloneTitle()
end

function ns.BuildRankWatchOptions()
	local options = {
		name = L["TAB_RANK_WATCH"],
		type = "group",
		args = {
			description = Desc(L["OPTIONS_RANK_WATCH_DESCRIPTION"], 1),
			space0 = Spacer(2),
			switch = ns.OptionsFeatureSwitch("RankWatch", 3),
			standaloneSpace = Spacer(3.1, StandaloneHidden),
			standalone = Desc(function()
				return L["RANK_WATCH_STANDALONE"]:format(ns.RankWatchStandaloneTitle() or "")
			end, 3.2, StandaloneHidden),

			graceSpace0 = Spacer(4),
			graceHeader = Header(L["RANK_WATCH_GRACE_HEADER"], 5),
			graceSpace1 = Spacer(5.1),
			graceDescription = Desc(L["RANK_WATCH_GRACE_DESCRIPTION"], 5.2),
			graceSpace2 = Spacer(5.3),
			-- The two grace period rows (GraceRow, below) at 6 and 7, a blank line between them.
			graceSpace3 = Spacer(6.5),

			messagesSpace0 = Spacer(9),
			messagesHeader = Header(L["RANK_WATCH_MESSAGES_HEADER"], 10),
			messagesSpace1 = Spacer(10.1),
			messagesDescription = Desc(L["RANK_WATCH_MESSAGES_DESCRIPTION"], 10.2),
			messagesSpace2 = Spacer(10.3),
			whisper = Toggle("whisper", "RANK_WATCH_WHISPER", "RANK_WATCH_WHISPER_DESCRIPTION", 11),
			whisperExample = ns.OptionsWhisperExample(12, WhisperExample, WhisperOff),
			whisperSpace = Spacer(13, WhisperOff),
			print = Toggle("print", "RANK_WATCH_PRINT", "RANK_WATCH_PRINT_DESCRIPTION", 14),
			printExample = ns.OptionsExample(15, PrintExample, PrintOff),

			optOutSpace0 = Spacer(16),
			optOutHeader = Header(L["RANK_WATCH_OPT_OUT_HEADER"], 17),
			optOutSpace1 = Spacer(17.1),
			optOutDescription = Desc(L["RANK_WATCH_OPT_OUT_DESCRIPTION"], 17.2),
			optOutSpace2 = Spacer(17.3, WhisperOff),
			optOutExample = ns.OptionsWhisperExample(18, OptOutExample, WhisperOff),

			whispererSpace0 = Spacer(19),
			whispererHeader = Header(L["RANK_WATCH_WHISPERER_HEADER"], 20),
			whispererSpace1 = Spacer(20.1),
			whispererDescription = Desc(L["RANK_WATCH_WHISPERER_DESCRIPTION"], 20.2),
			whispererSpace2 = Spacer(20.3),
			whisperer = Desc(WhispererText, 21),
		},
	}
	GraceRow(options.args, "graceMaxLevel", "RANK_WATCH_GRACE_MAX_LEVEL", "RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION", 6)
	GraceRow(options.args, "graceLeveling", "RANK_WATCH_GRACE_LEVELING", "RANK_WATCH_GRACE_LEVELING_DESCRIPTION", 7)
	return options
end
