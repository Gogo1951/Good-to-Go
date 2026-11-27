local _, ns = ...

local NO_IDS = {}

--[[
	Only the player's class is ever read, so the others are emptied at load (some 400 KB on Classic Era). Each
	keeps its key, so code listing the flavor's classes (Buff Duty) still sees every class. Validate Data checks
	the player's class only as a result.
]]
do
	local class = select(2, UnitClass("player"))
	for _, data in ipairs({ ns.CLASS_SPELL_LISTS or NO_IDS, ns.TRAINER_SPELLS or NO_IDS }) do
		for token in pairs(data) do
			if token ~= class then
				data[token] = {}
			end
		end
	end
end

local AUTO_SHOT_LABEL_KEYS = {
	HUNTER = "MENU_START_AUTO_SHOT",
	MAGE = "MENU_START_WAND",
	PRIEST = "MENU_START_WAND",
	WARLOCK = "MENU_START_WAND",
}

local SpellName = ns.SpellName

--[[
	name -> position. An entry is a spell ID, or every rank's ID where some locales name the ranks differently,
	so each rank's name matches.
]]
local function NameIndex(entries)
	local index = {}
	for position, entry in ipairs(entries or NO_IDS) do
		for _, id in ipairs(type(entry) == "table" and entry or { entry }) do
			local name = SpellName(id)
			if name and not index[name] then
				index[name] = position
			end
		end
	end
	return index
end

-- A spell on two of these takes the first.
local PAGE_TAGS = {
	"racials",
	"professions",
	"tracking",
	"threat",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"heals",
	"crowdControl",
	"attacks",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"noCooldown",
	"utility",
}

local function PageTags(lists)
	local tags = {}
	for _, key in ipairs(PAGE_TAGS) do
		for _, entries in ipairs({ ns.SHARED_PAGE_SPELLS[key] or NO_IDS, lists[key] or NO_IDS }) do
			for name in pairs(NameIndex(entries)) do
				tags[name] = tags[name] or key
			end
		end
	end
	return tags
end

local config -- the player's class lists, resolved to this client's names by ns.CollectMacros

local function ResolveClassConfig()
	local class = select(2, UnitClass("player"))
	local lists = ns.CLASS_SPELL_LISTS[class] or {}
	config = {
		autoShot = lists.autoShot and SpellName(lists.autoShot),
		autoShotLabelKey = lists.autoShot and AUTO_SHOT_LABEL_KEYS[class],
		groupSpells = {},
		soloSpells = {},
		spellGroups = {}, -- each grouped spell's name -> its group's names, in the order they are learned
		spellGroupIds = {}, -- each grouped spell's name -> its group's Rank 1 IDs, in the same order
		categoryRankByName = {}, -- each spellbook tab's name -> its section rank, filled by ns.CollectMacros
		extraSpells = lists.extraSpells or NO_IDS,
		petAbilities = {},
		stances = {},
		stanceIds = {}, -- each stance's name -> its spell ID, so its stance bar slot is found by ID
		stanceSlots = {},
		hasStances = lists.stances ~= nil,
		formSpells = {},
		requiredForms = lists.forms or NO_IDS, -- spell ID -> the spell IDs of the forms it needs
		enemySpells = NameIndex(lists.mouseoverEnemy),
		friendSpells = NameIndex(lists.mouseoverFriend),
		buffSpells = NameIndex(lists.buffs),
		resurrectSpells = NameIndex(lists.resurrect),
		pageTags = PageTags(lists),
		cursorSpells = NameIndex(lists.cursor),
		stealthSpells = NameIndex(lists.stealth),
		toggleSpells = NameIndex(lists.noToggle),
	}
	for summonId, pet in pairs(lists.petAbilities or NO_IDS) do
		local summon, ability = SpellName(summonId), SpellName(pet.abilityId)
		local family = C_CreatureInfo.GetCreatureFamilyInfo(pet.familyId)
		if summon and ability and family and family.name then
			config.petAbilities[summon] = { ability = ability, family = family.name }
		end
	end
	for spellId, stanceIds in pairs(lists.stances or NO_IDS) do
		local name, stances = SpellName(spellId), {}
		for _, stanceId in ipairs(stanceIds) do
			local stance = SpellName(stanceId)
			stances[#stances + 1] = stance
			if stance then
				config.stanceIds[stance] = stanceId
			end
		end
		if name and #stances == #stanceIds then
			config.stances[name] = stances
		end
	end
	for slot, stanceId in ipairs(lists.stanceSlots or NO_IDS) do
		local name = SpellName(stanceId)
		if name then
			config.stanceSlots[name] = slot
			config.stanceIds[name] = config.stanceIds[name] or stanceId
		end
	end
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or NO_IDS) do
		local single, group = C_Spell.GetSpellName(singleId), C_Spell.GetSpellName(groupId)
		if single and group then
			config.groupSpells[single] = group
			config.soloSpells[group] = single
		end
	end
	-- a group whose names aren't all loaded yet waits for the next build, so no spell drops out of it
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		local names = {}
		for _, id in ipairs(ids) do
			names[#names + 1] = SpellName(id)
		end
		if #names == #ids then
			for _, name in ipairs(names) do
				config.spellGroups[name] = names
				config.spellGroupIds[name] = ids
			end
		end
	end
	--[[
		the stance bar's forms are placed there already, so never glow; they cancel when cast again, except the
		Warrior stances, which never do, and stealth, which Stop Macro If Stealthed keeps on
	]]
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		local name = spellID and C_Spell.GetSpellName(spellID)
		if name then
			config.formSpells[name] = true
		end
		if name and not config.stanceSlots[name] and not config.stealthSpells[name] then
			config.toggleSpells[name] = true
		end
	end
	return config
end

-- Resolved on first use, and again by each ns.CollectMacros.
local function ClassConfig()
	return config or ResolveClassConfig()
end

ns.ClassConfig = ClassConfig

-- Spells to list until learned that no trainer data covers.
function ns.ClassExtraSpells()
	return ClassConfig().extraSpells
end

-- Self-centered AoE (Arcane Explosion, Hellfire) has no range, so it is left out.
local function TargetsEnemy(id)
	return id ~= nil and C_Spell.IsSpellHarmful(id) == true and C_Spell.SpellHasRange(id) == true
end

-- The conditional its target priority casts with; nil for spells without a target.
local function TargetOf(name, id)
	local c = ClassConfig()
	local enemy = c.enemySpells[name] or (not c.cursorSpells[name] and TargetsEnemy(id))
	local friend = c.friendSpells[name]
	if enemy and friend then
		return "exists"
	end
	if enemy then
		return "harm"
	end
	if friend then
		return "help"
	end
end

ns.ResolveClassConfig = ResolveClassConfig
ns.TargetOf = TargetOf
