local _, ns = ...

-- The kinds of spell macro.

-- Every kind, by key. A spell's kind is what decides most of its menu: who it can be cast on, or where.
ns.MACRO_KINDS = {
	{ key = "enemy" },
	{ key = "friendly" },
	{ key = "buff" },
	{ key = "resurrect" },
	{ key = "anyone" },
	{ key = "ground" },
	{ key = "form" },
	{ key = "self" },
}

local TARGET_KINDS = { harm = "enemy", help = "friendly", exists = "anyone" }

--[[
	A spell macro's kind, from the fields Macro-Builder.lua gives it: a ground-targeted spell, then a buff cast
	on a friend (the class lists' buffs), then a resurrection cast on a dead friend (the class lists'
	resurrect), then one cast on an enemy, a friend or either, then a form, stance,
	aura or aspect (the stance bar's forms and the spells that cancel when cast again), and every other spell,
	cast on the player or around them.
]]
function ns.MacroKind(macro)
	if macro.cursor then
		return "ground"
	end
	if macro.buff and macro.target == "help" then
		return "buff"
	end
	if macro.resurrect and macro.target == "help" then
		return "resurrect"
	end
	if macro.target then
		return TARGET_KINDS[macro.target]
	end
	if macro.noGlow or macro.toggles then
		return "form"
	end
	return "self"
end

--[[
	The options a kind can turn on by default. The ones left out belong to one spell rather than a kind: the
	pet's ability, the stance, a fixed rank and the items used first.
]]
ns.DEFAULTABLE_OPTIONS = {
	"cursor",
	"groupVersion",
	"targetRank",
	"stopAttack",
	"stopCast",
	"stopIfChanneling",
	"stopIfStealthed",
	"cancelForm",
	"targetEnemy",
	"targetFriend",
	"startAttack",
	"autoShot",
	"petAttack",
	"oncePerTarget",
	"oncePerCombat",
	"noToggle",
	"combatOnly",
	"noCombat",
	"hideErrors",
	"muteErrors",
}

local DEFAULTABLE = {}
for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
	DEFAULTABLE[key] = true
end

-- Whether a kind ("enemy", "friendly", ...) turns an option on by default.
function ns.KindDefault(kind, key)
	return DEFAULTABLE[key] == true and ns.db.profile.kindDefaults[kind][key] == true
end
