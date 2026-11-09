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

-- A rank as the Tracked Abilities panel shows it: the client's name and rank text, and its learn level.
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

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Gates --"
	local _, class = UnitClass("player")
	local level, maxLevel = UnitLevel("player"), ns.GetMaxPlayerLevel()
	lines[#lines + 1] = string.format("You: %s, level %s of %s", tostring(class), tostring(level), tostring(maxLevel))
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
			"Auras secret now (group members' buffs go unread): %s // damage meter present: %s (read every %d seconds, never in combat)",
			YesNo(ns.AreAurasSecret()),
			YesNo(C_DamageMeter and Enum.DamageMeterSessionType and Enum.DamageMeterType),
			RANK_WATCH.METER_POLL
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
		"Tracked Abilities choices: ranks unticked %d // ranks ticked that the data leaves off %d",
		unticked,
		ticked
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
