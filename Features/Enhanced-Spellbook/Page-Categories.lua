local _, ns = ...

--[[
	In page order. Unlike its kind (who the spell is cast on, which builds its macro), this is only the page's
	heading for it.
]]
ns.PAGE_CATEGORIES = {
	{ key = "attack", labelKey = "CATEGORY_ATTACKS" },
	{ key = "curse", labelKey = "CATEGORY_CURSES" },
	{ key = "finisher", labelKey = "CATEGORY_FINISHERS" },
	{ key = "shock", labelKey = "CATEGORY_SHOCKS" },
	{ key = "seal", labelKey = "CATEGORY_SEALS" },
	{ key = "hybrid", labelKey = "CATEGORY_HYBRID" },
	{ key = "heal", labelKey = "CATEGORY_HEALS" },
	{ key = "selfBuff", labelKey = "CATEGORY_SELF_BUFFS" },
	{ key = "totem", labelKey = "CATEGORY_TOTEMS" },
	{ key = "buff", labelKey = "CATEGORY_BUFFS" },
	{ key = "blessing", labelKey = "CATEGORY_BLESSINGS" },
	{ key = "offensive", labelKey = "CATEGORY_OFFENSIVE_COOLDOWNS" },
	{ key = "defensive", labelKey = "CATEGORY_DEFENSIVE_COOLDOWNS" },
	{ key = "crowdControl", labelKey = "CATEGORY_CROWD_CONTROL" },
	{ key = "utility", labelKey = "CATEGORY_UTILITY" },
	{ key = "threat", labelKey = "CATEGORY_THREAT" },
	{ key = "trap", labelKey = "CATEGORY_TRAPS" },
	{ key = "aspect", labelKey = "CATEGORY_ASPECTS" },
	{ key = "aura", labelKey = "CATEGORY_AURAS" },
	{ key = "stance", labelKey = "CATEGORY_STANCES" },
	{ key = "form", labelKey = "CATEGORY_FORMS" },
	{ key = "pet", labelKey = "CATEGORY_PETS" },
	{ key = "tracking", labelKey = "CATEGORY_TRACKING" },
	{ key = "resurrect", labelKey = "KIND_RESURRECT" },
	{ key = "teleport", labelKey = "CATEGORY_TELEPORTS" },
	{ key = "racial", labelKey = "CATEGORY_RACIALS" },
	{ key = "profession", labelKey = "CATEGORY_PROFESSIONS" },
}

-- A page tag files a spell whatever its kind.
local TAG_CATEGORIES = {
	racials = "racial",
	professions = "profession",
	tracking = "tracking",
	threat = "threat",
	traps = "trap",
	totems = "totem",
	seals = "seal",
	blessings = "blessing",
	curses = "curse",
	shocks = "shock",
	finishers = "finisher",
	pets = "pet",
	teleports = "teleport",
	heals = "heal",
	crowdControl = "crowdControl",
	attacks = "attack",
	offensives = "offensive",
	defensives = "defensive",
	selfBuffs = "selfBuff",
	pageBuffs = "buff",
	noCooldown = "utility",
}

local KIND_CATEGORIES = {
	enemy = "attack",
	anyone = "hybrid",
	friendly = "heal",
	buff = "buff",
}

--[[
	By what the class calls them. A stealth spell goes with them even off the stance bar, as Prowl is in Classic.
	A Mists paladin's stance bar holds its seals, which the class lists' seals file under Seals first.
]]
local FORM_CATEGORIES = {
	WARRIOR = "stance",
	MONK = "stance",
	DEATHKNIGHT = "stance",
	PALADIN = "aura",
	HUNTER = "aspect",
}

-- A base cooldown this long or longer makes a spell that isn't an attack or a heal an offensive cooldown.
local COOLDOWN_MS = 60 * 1000

local function HasLongCooldown(id)
	local ms = id and GetSpellBaseCooldown and GetSpellBaseCooldown(id)
	return ms ~= nil and ms >= COOLDOWN_MS
end

--[[
	nil for a macro with no kind, which goes under its own section after the categories. A resurrection wins over
	its tag; a ground or self spell that hurts is an attack even utility-tagged; a utility-tagged or harmless
	ground or self spell is an offensive cooldown at a minute's base cooldown (Arcane Power), else Utility.
]]
function ns.PageCategory(macro)
	local kind = macro.kind
	if kind == nil then
		return nil
	end
	if ns.IsBasicAttack(macro) then
		return "attack"
	end
	if kind == "resurrect" then
		return "resurrect"
	end
	local tagged = TAG_CATEGORIES[macro.pageTag]
	if tagged then
		return tagged
	end
	if (kind == "form" or macro.stealth) and macro.pageTag ~= "utility" then
		return FORM_CATEGORIES[select(2, UnitClass("player"))] or "form"
	end
	if KIND_CATEGORIES[kind] and macro.pageTag ~= "utility" then
		return KIND_CATEGORIES[kind]
	end
	local untargeted = kind == "ground" or kind == "self"
	if untargeted and macro.spellID and C_Spell.IsSpellHarmful(macro.spellID) == true then
		return "attack"
	end
	return HasLongCooldown(macro.spellID) and "offensive" or "utility"
end

local NO_FORMS = {}

--[[
	Never the tooltip's Requires line: it names each form as a form, which some locales name apart from the
	form's spell (zhCN Cat Form, esES Battle Stance), so it can't match the stance bar's spell names.
]]
local function RequiredForms(spellID)
	local names = {}
	for _, formSpellID in ipairs(ns.ClassConfig().requiredForms[spellID] or NO_FORMS) do
		local name = C_Spell.GetSpellName(formSpellID)
		if name then
			names[#names + 1] = name
		end
	end
	return names
end

function ns.KnownForms()
	local names = {}
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		local name = spellID and C_Spell.GetSpellName(spellID)
		if name then
			names[name] = true
		end
	end
	for name in pairs(ns.ClassConfig().stanceIds) do
		names[name] = true
	end
	return names
end

-- Always under Attacks, in a Basic Attacks run at its end; names read once.
local basicAttacks

function ns.IsBasicAttack(macro)
	if not basicAttacks then
		basicAttacks = {}
		for _, id in ipairs(ns.BASIC_ATTACK_SPELL_IDS) do
			local name = C_Spell.GetSpellName(id)
			if name then
				basicAttacks[name] = true
			end
		end
	end
	return basicAttacks[macro.name] == true
end

-- Where a run of a page category's spells goes in it: its own spells, then each form's, then the basic attacks.
local SUB_OWN, SUB_FORM, SUB_BASIC = 1, 2, 3

local function FormSub(form)
	if form then
		return form, SUB_FORM
	end
	return nil, SUB_OWN
end

--[[
	Only forms in knownForms count. A druid's spell goes under the first form it lists (Maul under Bear Form,
	though Dire Bear Form takes it too); anyone else's under its form only when it needs just the one.
]]
function ns.PageSubCategory(macro, knownForms)
	if ns.IsBasicAttack(macro) then
		return ns.L["SUBCATEGORY_BASIC_ATTACKS"], SUB_BASIC
	end
	if macro.stances then
		return FormSub(#macro.stances == 1 and macro.stances[1] or nil)
	end
	local forms = {}
	for _, name in ipairs(macro.spellID and RequiredForms(macro.spellID) or NO_FORMS) do
		if knownForms[name] then
			forms[#forms + 1] = name
		end
	end
	if #forms == 1 or select(2, UnitClass("player")) == "DRUID" then
		return FormSub(forms[1])
	end
	return nil, SUB_OWN
end
