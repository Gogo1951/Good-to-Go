local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- A value that may be secret on WoW Forever, as text that never tests it.
local function PlainText(value)
	if ns.IsPlain(value) then
		return tostring(value)
	end
	return "<secret>"
end

--------------------------------------------------------------------------------
-- Rank Watch Context
--------------------------------------------------------------------------------

-- A rank as the Reported Ranks panel shows it: the client's name and rank text, and its learn level.
local function RankText(row)
	local name = C_Spell.GetSpellName(row.id) or ("spell #" .. row.id)
	return string.format("%s (%s, %s, level %s)", name, ns.RankWatchRankText(row), row.id, tostring(row.level))
end

-- How many ranks a Rank Watch data table holds, across every class.
local function CountDataRanks(classes)
	local count = 0
	for _, abilities in pairs(classes or {}) do
		for _, ranks in ipairs(abilities) do
			count = count + #ranks
		end
	end
	return count
end

-- Classes, abilities and ranks across a set of ladders keyed by class token.
local function CountLadders(byClass)
	local classes, abilities, ranks = 0, 0, 0
	for _, list in pairs(byClass) do
		classes = classes + 1
		abilities = abilities + #list
		for _, ladder in ipairs(list) do
			ranks = ranks + #ladder.rows
		end
	end
	return classes, abilities, ranks
end

-- The group as Rank Watch reads it: you, then party1-4 or raid1-40.
local function GroupUnits()
	local units = {}
	if IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			units[#units + 1] = "raid" .. index
		end
	else
		units[1] = "player"
		for index = 1, GetNumSubgroupMembers() do
			units[#units + 1] = "party" .. index
		end
	end
	return units
end

-- One group member: name, class, the level Rank Watch reads (a cast is dropped without one), and whether ignored.
local function MemberLine(settings, unit)
	local guid = UnitGUID(unit)
	local _, class = UnitClass(unit)
	local level = ns.RankWatchUnitLevel(unit)
	local pet = unit == "player" and "pet" or unit:gsub("^party(%d)$", "partypet%1"):gsub("^raid(%d+)$", "raidpet%1")
	local petLevel = UnitExists(pet) and ns.RankWatchUnitLevel(pet)
	return string.format(
		"%s: %s, %s, level %s%s // ignored: %s // name hidden: %s",
		unit,
		PlainText(GetUnitName(unit, true)),
		PlainText(class),
		level and tostring(level) or "UNREADABLE (casts dropped)",
		UnitExists(pet) and string.format(" // pet level %s", petLevel and tostring(petLevel) or "UNREADABLE") or "",
		YesNo(ns.IsPlain(guid) and settings.ignoredPlayers[guid]),
		YesNo(ns.IsUnitIdentitySecret(unit))
	)
end

-- One of your class's abilities: its ranks on this client, the best one your level allows, and how many are tracked.
local function LadderLine(ladder, ceiling)
	local tracked = 0
	for _, row in ipairs(ladder.rows) do
		if ns.IsRankWatchRankTracked(row) then
			tracked = tracked + 1
		end
	end
	local best = ns.RankWatchBestIndex(ladder, ceiling)
	return string.format(
		"%s%s: %d ranks, %d tracked // best at level %d: %s",
		ladder.isPet and "pet: " or "",
		C_Spell.GetSpellName(ladder.id) or ("spell #" .. ladder.id),
		#ladder.rows,
		tracked,
		ceiling,
		best and RankText(ladder.rows[best]) or "(none)"
	)
end

-- A hunter tames its first pet at 10, so no pet line prints before then (Rank-Watch-Level-Up.lua's HUNTER_PET_LEVEL).
local HUNTER_PET_LEVEL = 10

-- What the next ding's pet lines would name, read as LevelUpLines reads ns.WhatsNextPetRows.
local function NextPetLine(warlock, nextLevel)
	if not warlock and nextLevel < HUNTER_PET_LEVEL then
		return string.format("Next level's pet lines: none before level %d", HUNTER_PET_LEVEL)
	end
	if not ns.WhatsNextPetRows then
		return "Next level's pet lines: the Spellbook's What's Next? pet rows aren't loaded"
	end
	local ok, rows, pet = pcall(ns.WhatsNextPetRows, nextLevel)
	if not ok then
		return "Next level's pet lines: (read failed: " .. PlainText(rows) .. ")"
	end
	local opened, waiting = 0, 0
	for _, row in ipairs(rows) do
		local fromTrainer, ready = warlock, true
		if row.source == "TRAINER" then
			fromTrainer = not row.ready
		elseif row.source == "HUNTER_TRAINER" then
			fromTrainer = row.status ~= "KNOWN" and row.status ~= "OTHER"
			ready = pet ~= nil and row.status == "AVAILABLE"
		end
		if fromTrainer and row.level == nextLevel then
			opened = opened + 1
		elseif fromTrainer and ready and not warlock and row.level and row.level < nextLevel then
			waiting = waiting + 1
		end
	end
	return string.format(
		"Next level's pet lines (%d): %d new, %d earlier ones not yet learned%s (a line prints only when its count is above 0)",
		nextLevel,
		opened,
		waiting,
		warlock and " (never printed for a warlock)" or ""
	)
end

--[[
    Answers "Rank Watch never says anything": every switch and gate that keeps it quiet (Rank-Watch-Core.lua,
    Rank-Watch-Check.lua), who whispers for the group (Rank-Watch-Cluster.lua), how this flavor sees casts
    (Rank-Watch-Detection-Combat-Log.lua, or Rank-Watch-Detection-Forever.lua on WoW Forever), what it watches,
    each group member's readable level, and your own class's abilities with the rank your level allows.
]]
function ns:BuildRankWatchContextReport()
	local lines = { GetClientHeader(), "" }
	if not ns.RankWatchSettings then
		lines[#lines + 1] = "Rank Watch is not part of this flavor."
		return table.concat(lines, "\n")
	end
	-- Read straight from the saved table: ns.RankWatchSettings also runs a migration, and a probe never writes.
	local settings = ns.db and ns.db.global.rankWatch
	if not settings then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end
	local RANK_WATCH = ns.Data.RANK_WATCH

	lines[#lines + 1] = "-- Switches --"
	lines[#lines + 1] = string.format(
		"Rank Watch: %s // Rank Sentinel running (Rank Watch stays quiet while it does): %s // watching now: %s",
		OnOff(settings.enabled),
		tostring(ns.RankWatchStandaloneTitle() or "no"),
		YesNo(ns.IsRankWatchActive())
	)
	lines[#lines + 1] = string.format(
		"Whisper: %s // Print: %s // Grace Period at Max Level: %s // Grace Period While Leveling: %s",
		OnOff(settings.whisper),
		OnOff(settings.print),
		tostring(settings.graceMaxLevel),
		tostring(settings.graceLeveling)
	)
	lines[#lines + 1] = string.format("Rank Sentinel's settings brought over: %s", YesNo(settings.importedStandalone))
	-- Each whisper's own text: unset follows the Send Messages In language's default, empty sends nothing.
	local function TextState(key)
		local saved = settings[key]
		return saved == nil and "default" or (saved == "" and "emptied" or "edited")
	end
	lines[#lines + 1] = string.format(
		"Send Messages In: %s // tip: %s // pet tip: %s // demon tip: %s // opt-out offer: %s // opt-out reply: %s",
		ns.GetMessageLanguage(),
		TextState("tipMessage"),
		TextState("tipMessagePet"),
		TextState("tipMessageDemon"),
		TextState("optOutMessage"),
		TextState("optOutDoneMessage")
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Gates --"
	local _, class = UnitClass("player")
	local level, maxLevel = UnitLevel("player"), ns.GetMaxPlayerLevel()
	lines[#lines + 1] = string.format("You: %s, level %s of %s", tostring(class), tostring(level), tostring(maxLevel))
	lines[#lines + 1] = string.format(
		"A cast on another player is judged against their level + %d at most (the game lowers a rank for a low-level target), and dropped when their level can't be read",
		RANK_WATCH.TARGET_LEVEL_RANGE
	)
	local _, instanceType = IsInInstance()
	lines[#lines + 1] = string.format(
		"In a group: %s (%s, %d members) // in a battleground or arena (nothing is reported or sent there): %s (%s)",
		YesNo(IsInGroup()),
		IsInRaid() and "raid" or "party",
		GetNumGroupMembers(),
		YesNo(ns.IsInPvPInstance()),
		tostring(instanceType)
	)
	lines[#lines + 1] = string.format(
		"In combat: %s // dead or a ghost: %s (whispers wait for both, then %d seconds more)",
		YesNo(InCombatLockdown()),
		YesNo(UnitIsDeadOrGhost("player")),
		RANK_WATCH.AFTER_COMBAT
	)
	local whisperer = ns.RankWatchWhisperer()
	lines[#lines + 1] = string.format(
		"Who whispers for the group: %s // leader: %s",
		whisperer == "self" and "you" or (whisperer or "nobody (you lead with Whisper off)"),
		tostring(ns.RankWatchLeadName())
	)
	lines[#lines + 1] = string.format(
		"Add-on message prefix %s registered: %s",
		RANK_WATCH.COMM_PREFIX,
		YesNo(C_ChatInfo.IsAddonMessagePrefixRegistered(RANK_WATCH.COMM_PREFIX))
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- How Casts Are Seen --"
	if ns.FLAVOR == "Camelot" then
		lines[#lines + 1] =
			"WoW Forever: your own and your pet's casts, group members' buffs, and their damage and healing from the damage meter."
		lines[#lines + 1] = string.format(
			"Auras secret now (group members' buffs go unread): %s // damage meter present: %s (read every %d seconds in a group, never in combat; the first read after joining or turning on only takes the totals)",
			YesNo(ns.AreAurasSecret()),
			YesNo(C_DamageMeter and Enum.DamageMeterSessionType and Enum.DamageMeterType),
			RANK_WATCH.METER_POLL
		)
		-- The cap Rank-Watch-Detection-Forever.lua's LowestGroupLevel puts on meter heals and your pet's helpful casts.
		local lowest
		for _, unit in ipairs(IsInGroup() and GroupUnits() or {}) do
			local unitLevel = ns.RankWatchUnitLevel(unit)
			if unitLevel and (not lowest or unitLevel < lowest) then
				lowest = unitLevel
			end
		end
		lines[#lines + 1] = string.format(
			"Lowest readable level in your group (group members' heals and your pet's helpful casts are judged against it + %d): %s",
			RANK_WATCH.TARGET_LEVEL_RANGE,
			IsInGroup() and tostring(lowest or "none readable, heals dropped") or "not in a group"
		)
	else
		lines[#lines + 1] = "Combat log: every group member's casts, their pets' included."
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- What It Watches --"
	local classes, abilities, ranks = CountLadders(ns.RankWatchLadders())
	local _, petAbilities, petRanks = CountLadders(ns.RankWatchPetLadders())
	local dataRanks = CountDataRanks(ns.RANK_WATCH_ABILITIES) + CountDataRanks(ns.RANK_WATCH_PET_ABILITIES)
	lines[#lines + 1] = string.format(
		"Built: classes %d, abilities %d, ranks %d // pets: abilities %d, ranks %d // ranks in the data this client lacks (left off): %d",
		classes,
		abilities,
		ranks,
		petAbilities,
		petRanks,
		dataRanks - ranks - petRanks
	)
	local unticked, ticked = 0, 0
	for _, choice in pairs(settings.untracked) do
		if choice then
			unticked = unticked + 1
		else
			ticked = ticked + 1
		end
	end
	lines[#lines + 1] = string.format(
		"Reported Ranks choices: ranks unticked %d // ranks ticked that the data leaves off %d",
		unticked,
		ticked
	)
	-- A whisper waits for the client's rank text of the rank it names, then is dropped (ns.ProcessRankWatchQueue).
	local reportable, noText = 0, 0
	for _, byClass in ipairs({ ns.RankWatchLadders(), ns.RankWatchPetLadders() }) do
		for _, list in pairs(byClass) do
			for _, ladder in ipairs(list) do
				for index = 1, #ladder.rows - 1 do
					local row = ladder.rows[index]
					if ns.IsRankWatchRankTracked(row) then
						reportable = reportable + 1
						if not ns.RankWatchHasRankText(row) then
							noText = noText + 1
						end
					end
				end
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Reportable ranks with no rank text from the client yet (a whisper naming one waits, then is dropped): %d of %d (asked for now; run again to see what loaded)",
		noText,
		reportable
	)
	lines[#lines + 1] = string.format(
		"Casts already reported (never reported again): %d // forgotten on a new version: kept for %s, running %s",
		CountKeys(settings.announced),
		tostring(settings.announcedVersion),
		tostring(ns.Version)
	)
	local ignored = {}
	for _, name in pairs(settings.ignoredPlayers) do
		ignored[#ignored + 1] = tostring(name)
	end
	table.sort(ignored)
	lines[#lines + 1] =
		string.format("Ignored Players: %d%s", #ignored, #ignored > 0 and (" // " .. table.concat(ignored, ", ")) or "")

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Your Group --"
	if IsInGroup() then
		for _, unit in ipairs(GroupUnits()) do
			if UnitExists(unit) then
				lines[#lines + 1] = MemberLine(settings, unit)
			end
		end
	else
		lines[#lines + 1] = "Not in a group: only your own low ranks are reported."
	end

	--[[
	    The ceiling a cast of yours is judged against (ns.CheckRankWatchCast), leaving out the level you were
	    first seen at this session and the recipient's level, which only the cast itself knows.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Your Abilities --"
	local grace = (level >= maxLevel) and settings.graceMaxLevel or settings.graceLeveling
	local ceiling = level - (grace or 0)
	local mine = {}
	for _, ladder in ipairs(ns.RankWatchLadders()[class] or {}) do
		mine[#mine + 1] = ladder
	end
	for _, ladder in ipairs(ns.RankWatchPetLadders()[class] or {}) do
		mine[#mine + 1] = ladder
	end
	if #mine == 0 then
		lines[#lines + 1] = "None on this client."
	end
	for _, ladder in ipairs(mine) do
		lines[#lines + 1] = LadderLine(ladder, ceiling)
	end

	--[[
	    Ability Alerts While Leveling (Features/Rank-Watch/Rank-Watch-Level-Up.lua): its switches, and the pet's
	    spells among the class rows it reads, which its "you can also learn" line would name as the player's.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Ability Alerts While Leveling --"
	lines[#lines + 1] = string.format(
		"Alerts: %s // skipped spells: %s // pet: %s // pet's skipped spells: %s // Pet What's Next? data for this class: %s",
		OnOff(settings.levelUpAlerts),
		OnOff(settings.levelUpAlertsPast),
		OnOff(settings.levelUpAlertsPet),
		OnOff(settings.levelUpAlertsPetPast),
		YesNo(ns.HasWhatsNextPet and ns.HasWhatsNextPet())
	)
	if ns.PetSpellsInClassRowsLine then
		lines[#lines + 1] = ns.PetSpellsInClassRowsLine()
	end
	-- What the next ding's first two lines would name, read as LevelUpLines reads them: class trainer spells ready to learn.
	if level >= maxLevel then
		lines[#lines + 1] = "Next level: none, you are at the level cap, so no alert prints"
	elseif ns.WhatsNextRows then
		local nextLevel = level + 1
		local ok, rows = pcall(ns.WhatsNextRows, nextLevel)
		if ok then
			local opened, waiting = 0, 0
			for _, row in ipairs(rows) do
				if row.source == "TRAINER" and row.status == "AVAILABLE" then
					if row.level == nextLevel then
						opened = opened + 1
					else
						waiting = waiting + 1
					end
				end
			end
			lines[#lines + 1] = string.format(
				"Next level (%d): %d new trainer spells, %d earlier ones not yet learned (a line prints only when its count is above 0)",
				nextLevel,
				opened,
				waiting
			)
		else
			lines[#lines + 1] = "Next level: (read failed: " .. PlainText(rows) .. ")"
		end
	else
		lines[#lines + 1] = "Next level: the Spellbook's What's Next? rows aren't loaded, so no alert can print"
	end
	if level < maxLevel and settings.levelUpAlertsPet and ns.HasWhatsNextPet and ns.HasWhatsNextPet() then
		lines[#lines + 1] = NextPetLine(class == "WARLOCK", level + 1)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

local function HasFunction(namespace, name)
	return function()
		local library = _G[namespace]
		return type(library) == "table" and type(library[name]) == "function"
	end
end

-- Only where this flavor's TOC loads Rank Watch: Mists ships its empty data files alone.
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, not ns.RankWatchSettings and {} or {
	-- One whisperer per group, agreed over add-on messages (Rank-Watch-Cluster.lua).
	{ "C_ChatInfo.RegisterAddonMessagePrefix", HasFunction("C_ChatInfo", "RegisterAddonMessagePrefix") },
	{ "C_ChatInfo.SendAddonMessage", HasFunction("C_ChatInfo", "SendAddonMessage") },
	{ "C_ChatInfo.IsAddonMessagePrefixRegistered", HasFunction("C_ChatInfo", "IsAddonMessagePrefixRegistered") },
	-- Every flavor but WoW Forever reads casts from the combat log (Rank-Watch-Detection-Combat-Log.lua).
	{
		"CombatLogGetCurrentEventInfo (every flavor but WoW Forever)",
		function()
			return ns.FLAVOR == "Camelot" or type(CombatLogGetCurrentEventInfo) == "function"
		end,
	},
	--[[
	    WoW Forever reads other players' damage and healing from Blizzard's damage meter, and caps a pet's helpful
	    cast by the group's lowest level (Rank-Watch-Detection-Forever.lua). Both are guarded, so a FAIL on Forever
	    means those casts go unseen; elsewhere they aren't used.
	]]
	{
		"C_DamageMeter session reads (WoW Forever, guarded)",
		function()
			if ns.FLAVOR ~= "Camelot" then
				return true
			end
			return type(C_DamageMeter) == "table"
				and type(C_DamageMeter.GetCombatSessionFromType) == "function"
				and type(C_DamageMeter.GetCombatSessionSourceFromType) == "function"
				and type(Enum.DamageMeterSessionType) == "table"
				and type(Enum.DamageMeterType) == "table"
		end,
	},
	{ "C_Spell.IsSpellHelpful (guarded)", HasFunction("C_Spell", "IsSpellHelpful") },
})

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    Every rank Rank Watch can name for your class and its pets: the spell's name and the client's rank text,
    each through the call the whispers and the Reported Ranks panel make (ns.RankWatchSpellText,
    ClientRankText in Rank-Watch-Lookups.lua). Scoped to your class as the Spellbook's rows are; a non-English
    tester on each class covers the rest. Then the demon kind the warlock's Example names.
]]
local function RankWatchNameRows()
	local rows, seen = {}, { spell = {}, spellRank = {} }
	local _, class = UnitClass("player")
	local function Add(constant, kind, id, read)
		if seen[kind][id] then
			return
		end
		seen[kind][id] = true
		rows[#rows + 1] = {
			constant = constant,
			kind = kind,
			id = id,
			lookup = function()
				return read(id)
			end,
			request = function()
				C_Spell.RequestLoadSpellData(id)
			end,
		}
	end
	for _, constant in ipairs({ "RANK_WATCH_ABILITIES", "RANK_WATCH_PET_ABILITIES" }) do
		for _, ranks in ipairs((ns[constant] or {})[class] or {}) do
			for _, rank in ipairs(ranks) do
				Add(constant, "spell", rank.id, C_Spell.GetSpellName)
				Add(constant, "spellRank", rank.id, C_Spell.GetSpellSubtext)
			end
		end
	end
	rows[#rows + 1] = {
		constant = "SAMPLE_DEMON_FAMILY_ID",
		kind = "creatureFamily",
		id = ns.SAMPLE_DEMON_FAMILY_ID,
		lookup = function()
			local info = C_CreatureInfo.GetCreatureFamilyInfo(ns.SAMPLE_DEMON_FAMILY_ID)
			return info and info.name
		end,
	}
	return rows
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, not ns.RankWatchSettings and {} or RankWatchNameRows())

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    Validate Data's reports for the two Rank Watch files: every rank of every ability, looked up on this client,
    with its class, rank and learn level beside it, so a rank this client lacks or a level that drifted shows in
    the Data Review. Pets' ranks sit under their owner's class.
]]
local function CollectRanks(classes)
	local found = {}
	for class, abilities in pairs(classes) do
		for index, ranks in ipairs(abilities) do
			for _, rank in ipairs(ranks) do
				found[#found + 1] = { id = rank.id, key = class .. index, row = { class = class, rank = rank } }
			end
		end
	end
	return found
end

local RANK_COLUMNS = {
	{
		"DATA_CLASS",
		function(_, row)
			return row.class
		end,
	},
	{
		"DATA_RANK",
		function(_, row)
			return row.rank.rank
		end,
	},
	{
		"DATA_LEVEL",
		function(_, row)
			return row.rank.level
		end,
	},
}

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	{
		label = "Rank-Watch-Abilities",
		sources = {
			{ table = "RANK_WATCH_ABILITIES", kind = "spell", collect = CollectRanks, dataColumns = RANK_COLUMNS },
		},
	},
	{
		label = "Rank-Watch-Pet-Abilities",
		sources = {
			{ table = "RANK_WATCH_PET_ABILITIES", kind = "spell", collect = CollectRanks, dataColumns = RANK_COLUMNS },
		},
	},
})
