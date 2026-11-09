local _, ns = ...

--[[
    Scanner-Character -- reads the character's own facts: profession skills and
    the session constants (race and class, spell-name caches, the conjure-spell
    cache). Which buffs the character still needs is Scanner-Auras.lua's job.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.currentFirstAidSkill = 0
ns.currentAlchemySkill = 0
ns.currentEngineeringSkill = 0

--------------------------------------------------------------------------------
-- Profession Skills
--------------------------------------------------------------------------------

--[[
    The professions whose ranks the scanner's usability gates read, each by its
    skill line ID (Game-IDs) and the ns field that holds its rank. 0 while
    unlearned.
]]
local PROFESSIONS = {
	{ idKey = "FIRST_AID_SKILL_LINE_ID", field = "currentFirstAidSkill" },
	{ idKey = "ALCHEMY_SKILL_LINE_ID", field = "currentAlchemySkill" },
	{ idKey = "ENGINEERING_SKILL_LINE_ID", field = "currentEngineeringSkill" },
}

--[[
    Forever answers by ID (C_SkillInfo.GetSkillLineInfoByID), so no name is
    read and a collapsed header changes nothing. Era and TBC have no such call
    and search the skill list by the name the client gives that skill line, so
    it matches in every locale. Never a spell's name: a profession's spell can
    be named apart from its skill line (French First Aid is "Premiers soins" as
    a spell but "Secourisme" as a skill line).

    That list leaves out the lines under a collapsed header. When a profession
    is missing and a header is collapsed, the read opens the collapsed headers,
    reads, and closes the same headers again, so the Skills tab looks as the
    player left it. Headers are opened only out of combat with the Skills tab
    closed; otherwise the last ranks stand until combat ends or the next skill
    change.

    Opening and closing a header fires SKILL_LINES_CHANGED, which reads the
    skills again. isOpeningHeaders turns away the events fired during the read
    itself. An event the client delivers later lands inside REOPEN_INTERVAL,
    whose read does not open the headers again, and so does not fire another
    event. A rank such a read can't see keeps its last value.
]]
local GetSkillLineInfoByID = C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID

local REOPEN_INTERVAL = 0.5

local isOpeningHeaders = false
local rereadPending = false
local lastOpenedAt

-- The ranks of the skill lines the list shows, by name, and whether a header is collapsed.
local function ReadListedRanks()
	local ranks, anyCollapsed = {}, false
	for index = 1, ns.GetNumSkillLines() or 0 do
		local skillName, isHeader, isExpanded, skillRank = ns.GetSkillLineInfo(index)
		if isHeader then
			if not isExpanded then
				anyCollapsed = true
			end
		elseif skillName then
			ranks[skillName] = skillRank
		end
	end
	return ranks, anyCollapsed
end

--[[
    Back to front both ways: opening or closing a header adds or removes the
    lines after it, which leaves the indices before it where they were.
]]
local function OpenCollapsedHeaders(opened)
	for index = ns.GetNumSkillLines() or 0, 1, -1 do
		local skillName, isHeader, isExpanded = ns.GetSkillLineInfo(index)
		if isHeader and not isExpanded and skillName then
			opened[skillName] = true
			ns.ExpandSkillHeader(index)
		end
	end
end

local function CloseHeaders(opened)
	for index = ns.GetNumSkillLines() or 0, 1, -1 do
		local skillName, isHeader, isExpanded = ns.GetSkillLineInfo(index)
		if isHeader and isExpanded and opened[skillName] then
			ns.CollapseSkillHeader(index)
		end
	end
end

--[[
    Ranks by skill line name for the names given. The second value is whether
    the whole list was read: when false, a name missing from the ranks may sit
    under a collapsed header rather than be unlearned.
]]
local function ReadRanksByName(names)
	local ranks, anyCollapsed = ReadListedRanks()
	if not anyCollapsed then
		rereadPending = false
		return ranks, true
	end

	local anyMissing = false
	for _, name in ipairs(names) do
		if ranks[name] == nil then
			anyMissing = true
			break
		end
	end
	if not anyMissing then
		rereadPending = false
		return ranks, true
	end

	if not (ns.ExpandSkillHeader and ns.CollapseSkillHeader) then
		return ranks, false
	end
	if lastOpenedAt and GetTime() - lastOpenedAt < REOPEN_INTERVAL then
		return ranks, false
	end
	if InCombatLockdown() or (SkillFrame and SkillFrame:IsShown()) then
		rereadPending = true
		return ranks, false
	end

	isOpeningHeaders = true
	local opened = {}
	OpenCollapsedHeaders(opened)
	local openedRanks = ReadListedRanks()
	CloseHeaders(opened)
	isOpeningHeaders = false
	lastOpenedAt = GetTime()
	rereadPending = false

	return openedRanks, true
end

-- Stores one profession's rank, and returns whether it changed.
local function SetRank(field, rank)
	if rank ~= ns[field] then
		ns[field] = rank
		return true
	end
	return false
end

-- Reads every profession's rank and returns whether any changed.
function ns.UpdateProfessionSkills()
	if isOpeningHeaders then
		return false
	end

	local changed = false
	if GetSkillLineInfoByID then
		for _, profession in ipairs(PROFESSIONS) do
			local info = GetSkillLineInfoByID(ns[profession.idKey])
			changed = SetRank(profession.field, info and info.rank or 0) or changed
		end
		return changed
	end

	local names, nameOf = {}, {}
	for _, profession in ipairs(PROFESSIONS) do
		local name = C_TradeSkillUI.GetTradeSkillDisplayName(ns[profession.idKey])
		if name and name ~= "" then
			names[#names + 1] = name
			nameOf[profession] = name
		end
	end

	local ranks, complete = ReadRanksByName(names)
	for _, profession in ipairs(PROFESSIONS) do
		local name = nameOf[profession]
		local rank = name and ranks[name]
		if rank == nil then
			-- Missing from a list read in part: keep the last rank rather than reading it as unlearned.
			rank = (name and not complete) and ns[profession.field] or 0
		end
		changed = SetRank(profession.field, rank) or changed
	end
	return changed
end

-- Puts the read off until ns.RereadProfessionSkillsIfPending, which PLAYER_REGEN_ENABLED calls.
function ns.DeferProfessionSkillsRead()
	rereadPending = true
end

-- Reads the ranks again when a read was put off for combat or the open Skills tab, and returns whether any changed.
function ns.RereadProfessionSkillsIfPending()
	if not rereadPending then
		return false
	end
	rereadPending = false
	return ns.UpdateProfessionSkills()
end

--------------------------------------------------------------------------------
-- Session Constants
--------------------------------------------------------------------------------

--[[
    One-time, session-constant character setup: race/class detection,
    spell-name caches, the conjure-spell existence cache, and profession skills.
    None of these change during a session, so they resolve once and the event
    handlers (PLAYER_LEVEL_UP, SPELLS_CHANGED, SKILL_LINES_CHANGED) keep the
    level-dependent pieces fresh afterward. Called once at login, after ns.db
    exists.
]]
function ns.InitializeCharacterConstants()
	local _, raceToken = UnitRace("player")
	ns.isNightElf = (raceToken == "NightElf")

	if ns.isNightElf then
		ns.shadowmeldSpellName = C_Spell.GetSpellName(ns.SHADOWMELD_SPELL_ID)
	end

	-- The Forsaken race token is "Scourge"; resolve Cannibalize the same way.
	ns.isForsaken = (raceToken == "Scourge")
	if ns.isForsaken then
		ns.cannibalizeSpellName = C_Spell.GetSpellName(ns.CANNIBALIZE_SPELL_ID)
	end

	-- Rapid Regeneration exists only where the data folder names it (WoW Forever).
	ns.isTroll = (raceToken == "Troll")
	if ns.isTroll and ns.RAPID_REGENERATION_SPELL_ID then
		ns.rapidRegenerationSpellName = C_Spell.GetSpellName(ns.RAPID_REGENERATION_SPELL_ID)
	end

	--[[
	    Class detection. Used by macro builders to decide which conjure
	    branches the player could *eventually* know — so a low-level mage
	    gets "You don't currently know Conjure Food." while a hunter sees no
	    message at all (they'll never learn that spell).
	]]
	local _, classToken = UnitClass("player")
	ns.isHunter = (classToken == "HUNTER")
	ns.isDruid = (classToken == "DRUID")
	ns.isMage = (classToken == "MAGE")
	ns.isWarlock = (classToken == "WARLOCK")
	ns.isRogue = (classToken == "ROGUE")

	if ns.isRogue then
		ns.stealthSpellName = C_Spell.GetSpellName(ns.STEALTH_SPELL_ID)
	end

	if ns.isHunter then
		ns.ResolveHunterSpells()
		ns.petDeadDismissed = false
	end

	ns.spellCache = {}
	for _, spellList in pairs(ns.CONJURE_SPELLS) do
		for _, data in ipairs(spellList) do
			local spellID = data[1]
			if C_Spell.GetSpellName(spellID) then
				ns.spellCache[spellID] = true
			end
		end
	end

	ns.UpdateProfessionSkills()
end
