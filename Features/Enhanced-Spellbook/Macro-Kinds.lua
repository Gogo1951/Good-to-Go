local _, ns = ...

-- A spell's kind decides most of its menu: who it can be cast on, or where.
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

-- In order: cursor, buff, resurrect, enemy / friend / either, form (stance, aura, aspect), then self.
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

-- Left out: options that belong to one spell, not a kind (pet ability, stance, fixed rank, items used first).
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

function ns.KindDefault(kind, key)
	return DEFAULTABLE[key] == true and ns.db.profile.kindDefaults[kind][key] == true
end
