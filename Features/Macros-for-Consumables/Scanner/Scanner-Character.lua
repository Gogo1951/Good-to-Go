local _, ns = ...

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.currentFirstAidSkill = 0
ns.currentAlchemySkill = 0
ns.currentEngineeringSkill = 0
ns.currentFishingSkill = 0

--------------------------------------------------------------------------------
-- Profession Skills
--------------------------------------------------------------------------------

local PROFESSIONS = {
	{ idKey = "FIRST_AID_SKILL_LINE_ID", field = "currentFirstAidSkill" },
	{ idKey = "ALCHEMY_SKILL_LINE_ID", field = "currentAlchemySkill" },
	{ idKey = "ENGINEERING_SKILL_LINE_ID", field = "currentEngineeringSkill" },
	{ idKey = "FISHING_SKILL_LINE_ID", field = "currentFishingSkill" },
}

--[[
    Era and TBC search the skill list by the skill line's own name, never a
    spell's: French First Aid is "Premiers soins" as a spell, "Secourisme" as
    a skill line. The list hides lines under a collapsed header, so the read
    opens and re-closes them, only out of combat with the Skills tab shut.
    That fires SKILL_LINES_CHANGED: isOpeningHeaders turns away the ones
    during the read, and REOPEN_INTERVAL stops a late one from looping.
]]
local GetSkillLineInfoByID = C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID

local REOPEN_INTERVAL = 0.5

local isOpeningHeaders = false
local rereadPending = false
local lastOpenedAt

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

-- Back to front: a header change shifts only the lines after it.
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

-- The second value is false when a missing name may sit under a collapsed header rather than be unlearned.
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

local function SetRank(field, rank)
	if rank ~= ns[field] then
		ns[field] = rank
		return true
	end
	return false
end

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

function ns.DeferProfessionSkillsRead()
	rereadPending = true
end

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

function ns.InitializeCharacterConstants()
	local _, raceToken = UnitRace("player")
	ns.isNightElf = (raceToken == "NightElf")

	if ns.isNightElf then
		ns.shadowmeldSpellName = C_Spell.GetSpellName(ns.SHADOWMELD_SPELL_ID)
	end

	-- The Forsaken race token is "Scourge".
	ns.isForsaken = (raceToken == "Scourge")
	if ns.isForsaken then
		ns.cannibalizeSpellName = C_Spell.GetSpellName(ns.CANNIBALIZE_SPELL_ID)
	end

	-- Rapid Regeneration exists only where the data folder names it (WoW Forever).
	ns.isTroll = (raceToken == "Troll")
	if ns.isTroll and ns.RAPID_REGENERATION_SPELL_ID then
		ns.rapidRegenerationSpellName = C_Spell.GetSpellName(ns.RAPID_REGENERATION_SPELL_ID)
	end

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
