local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Rank Watch Panel
--------------------------------------------------------------------------------

local function Settings()
	return ns.RankWatchSettings()
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
			ns.RefreshSettings()
		end,
	}
end

-- The player's own class, so the Examples show spells they know. Any class serves where theirs has none.
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

-- The player's own sample where this client's pets have none with two ranks.
local function SamplePetRows(owner)
	for _, ladder in ipairs(ns.RankWatchPetLadders()[owner] or {}) do
		if #ladder.rows > 1 then
			return ladder.rows[1], ladder.rows[#ladder.rows]
		end
	end
	return SampleRows()
end

local function SampleDemonName()
	local info = C_CreatureInfo
		and C_CreatureInfo.GetCreatureFamilyInfo
		and C_CreatureInfo.GetCreatureFamilyInfo(ns.IMP_CREATURE_FAMILY_ID)
	return info and info.name or ns.SAMPLE_PET_NAME
end

-- Through the same builders the real whisper uses.
local TIP_SAMPLES = {
	{
		rows = SampleRows,
	},
	{
		form = "pet",
		rows = function()
			return SamplePetRows("HUNTER")
		end,
		petName = function()
			return ns.SAMPLE_PET_NAME
		end,
	},
	{
		form = "demon",
		rows = function()
			return SamplePetRows("WARLOCK")
		end,
		petName = SampleDemonName,
	},
}

local function TipParts(sample)
	local castRow, betterRow = sample.rows()
	if not castRow then
		return nil
	end
	return ns.RankWatchSpellText(castRow, true),
		ns.RankWatchSpellText(castRow, false),
		betterRow.level,
		sample.petName and sample.petName()
end

local function TipFill(sample)
	return function(text)
		local linked, named, level, petName = TipParts(sample)
		if not linked then
			return ""
		end
		return ns.FillRankWatchTipWhisper(text, linked, named, level, petName)
	end
end

local function TipBuild(sample)
	return function(text)
		local linked, named, level, petName = TipParts(sample)
		if not linked then
			return nil
		end
		return ns:BuildRankWatchTipWhisper(sample.form, text, linked, named, level, petName)
	end
end

local function Tokens(key, ...)
	local tokens = { ... }
	return function()
		local info, help = GetColor("INFO"), GetColor("HELP")
		local drawn = {}
		for index, token in ipairs(tokens) do
			drawn[index] = info .. token .. help
		end
		return L[key]:format(unpack(drawn))
	end
end

-- Borrows a name for a class the house roster has none for.
local function PrintExample()
	local castRow, betterRow, class = SampleRows()
	if not castRow then
		return ns.PrintedExampleLines(nil)
	end
	local name = ns.ClassColoredName(ns.SAMPLE_NAMES[class] or ns.SAMPLE_NAMES.WARRIOR, class)
	return ns.PrintedExampleLines(ns.BuildRankWatchOtherLine(name, castRow, betterRow))
end

-- So an Example never shows a message the player hasn't chosen.
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

-- Only one Rank Watch or Rank Sentinel in a group whispers; read each time the panel draws.
local function WhispererHelper(order, hidden)
	return Kit.Row(order, hidden, {
		Kit.Label(" ", nil, Kit.LABEL_WIDTH),
		Kit.Label(function()
			return Kit.Color("HELP", L["RANK_WATCH_WHO_WHISPERS_FORMAT"]:format(WhispererText()))
		end, nil, Kit.CONTROL_WIDTH),
	})
end

-- Levels off the caster's, so a rank only just reached isn't reported.
local GRACE_MAX = 5

local function GraceValues()
	local values, sorting = {}, {}
	for levels = 0, GRACE_MAX do
		values[levels] = levels == 1 and L["RANK_WATCH_GRACE_LEVEL"] or L["RANK_WATCH_GRACE_LEVELS"]:format(levels)
		sorting[#sorting + 1] = levels
	end
	return values, sorting
end

-- A caption row, so hovering the caption shows the dropdown's tooltip too.
local function GraceRow(args, key, name, desc, order)
	local values, sorting = GraceValues()
	args[key] = Kit.LabelRow(order, nil, L[name], {
		type = "select",
		desc = L[desc],
		values = values,
		sorting = sorting,
		get = function()
			return Settings()[key]
		end,
		set = function(_, value)
			Settings()[key] = value
			ns.RefreshSettings()
		end,
	})
end

local function StandaloneHidden()
	return not ns.RankWatchStandaloneTitle()
end

local function RankWatchOff()
	return not Settings().enabled
end

function ns.BuildRankWatchOptions()
	local options = {
		name = L["TAB_RANK_WATCH"],
		type = "group",
		args = {
			description = Desc(L["OPTIONS_RANK_WATCH_DESCRIPTION"], 1),
			space0 = Spacer(2),
			switch = Kit.FeatureSwitch("rankWatch.enabled", 3),
			standaloneSpace = Spacer(3.1, StandaloneHidden),
			-- Shows only while another add-on changes what this page does.
			standalone = Kit.StatusLine(function()
				if StandaloneHidden() then
					return nil
				end
				return L["RANK_WATCH_STANDALONE"]:format(ns.RankWatchStandaloneTitle() or "")
			end, 3.2),

			graceSpace0 = Spacer(4),
			graceHeader = Header(L["RANK_WATCH_GRACE_HEADER"], 5),
			graceSpace1 = Spacer(5.1),
			graceDescription = Desc(L["RANK_WATCH_GRACE_DESCRIPTION"], 5.2),
			graceSpace2 = Spacer(5.3),
			-- The grace period rows (GraceRow, below) fill 6 and 7.
			graceSpace3 = Spacer(6.5),

			messagesSpace0 = Spacer(9),
			messagesHeader = Header(L["RANK_WATCH_MESSAGES_HEADER"], 10),
			messagesSpace1 = Spacer(10.1),
			messagesDescription = Desc(L["RANK_WATCH_MESSAGES_DESCRIPTION"], 10.2),
			messagesSpace2 = Spacer(10.3),
			whisper = Toggle("whisper", "RANK_WATCH_WHISPER", "RANK_WATCH_WHISPER_DESCRIPTION", 11),
			whisperer = WhispererHelper(11.02, WhisperOff),
			-- 11.1 through 11.49 belong to the tip's whisper composer, added below.
			tipComposerSpace = Spacer(11.05, WhisperOff),
			optOutSpace0 = Spacer(11.6, WhisperOff),
			optOutDescription = Desc(L["RANK_WATCH_OPT_OUT_DESCRIPTION"], 11.7, WhisperOff),
			optOutSpace1 = Spacer(11.8, WhisperOff),
			-- 12 through 12.29 belong to the opt-out whispers' composer, added below.
			whisperSpace = Spacer(13, WhisperOff),
			print = Toggle("print", "RANK_WATCH_PRINT", "RANK_WATCH_PRINT_DESCRIPTION", 14),
			printExample = Kit.Example(15, PrintOff, PrintExample),
		},
	}
	ns.DefineWhisperComposer(options.args, {
		prefix = "tipWhisper",
		hidden = WhisperOff,
		messages = {
			{
				field = "rankWatchTip",
				label = L["WHISPER_TEXT"],
				description = L["RANK_WATCH_TIP_MESSAGE_DESCRIPTION"],
				tokens = Tokens("RANK_WATCH_TIP_TOKENS", "{spell}", "{level}"),
				fill = TipFill(TIP_SAMPLES[1]),
				build = TipBuild(TIP_SAMPLES[1]),
			},
			{
				field = "rankWatchTipPet",
				label = L["RANK_WATCH_TIP_PET_MESSAGE"],
				description = L["RANK_WATCH_TIP_PET_MESSAGE_DESCRIPTION"],
				tokens = Tokens("RANK_WATCH_TIP_PET_TOKENS", "{pet}", "{spell}", "{level}"),
				fill = TipFill(TIP_SAMPLES[2]),
				build = TipBuild(TIP_SAMPLES[2]),
			},
			{
				field = "rankWatchTipDemon",
				label = L["RANK_WATCH_TIP_DEMON_MESSAGE"],
				description = L["RANK_WATCH_TIP_DEMON_MESSAGE_DESCRIPTION"],
				tokens = Tokens("RANK_WATCH_TIP_DEMON_TOKENS", "{pet}", "{spell}", "{level}"),
				fill = TipFill(TIP_SAMPLES[3]),
				build = TipBuild(TIP_SAMPLES[3]),
			},
		},
	}, 11.1)
	-- Send Messages In is already above, with the tip.
	ns.DefineWhisperComposer(options.args, {
		prefix = "optOutWhisper",
		hidden = WhisperOff,
		language = false,
		messages = {
			{
				field = "rankWatchOptOut",
				label = L["RANK_WATCH_OPT_OUT_MESSAGE"],
				description = L["RANK_WATCH_OPT_OUT_MESSAGE_DESCRIPTION"],
				fill = ns.FillOptOutOfferWhisper,
				build = function(text)
					return ns:BuildOptOutOfferWhisper(text)
				end,
			},
			{
				field = "rankWatchOptOutDone",
				label = L["RANK_WATCH_OPT_OUT_DONE_MESSAGE"],
				description = L["RANK_WATCH_OPT_OUT_DONE_MESSAGE_DESCRIPTION"],
				fill = ns.FillOptOutDoneWhisper,
				build = function(text)
					return ns:BuildOptOutDoneWhisper(text)
				end,
			},
		},
	}, 12)
	GraceRow(options.args, "graceMaxLevel", "RANK_WATCH_GRACE_MAX_LEVEL", "RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION", 6)
	GraceRow(options.args, "graceLeveling", "RANK_WATCH_GRACE_LEVELING", "RANK_WATCH_GRACE_LEVELING_DESCRIPTION", 7)
	-- Last: it wraps only args already present.
	Kit.HideAllExcept(
		options.args,
		RankWatchOff,
		{ "description", "space0", "switch", "standaloneSpace", "standalone" }
	)
	return options
end
