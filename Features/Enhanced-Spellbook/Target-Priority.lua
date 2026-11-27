local _, ns = ...
local GetSetting = ns.GetMacroSetting
local StoreSetting = ns.StoreMacroSetting
local NO_SLOTS = ns.NO_SLOTS

--------------------------------------------------------------------------------
-- Target Priority
--------------------------------------------------------------------------------

-- In Target submenu order. Each unit in a list is tried only when it can take the spell, then a plain cast.
ns.TARGET_UNITS = {
	{ "target", "MENU_UNIT_TARGET" },
	{ "player", "MENU_UNIT_SELF" },
	{ "pet", "MENU_UNIT_PET" },
	{ "focus", "MENU_UNIT_FOCUS" },
	{ "targettarget", "MENU_UNIT_TARGETS_TARGET" },
	{ "mouseover", "MENU_UNIT_MOUSEOVER" },
}
ns.TARGET_PRIORITY_SLOTS = 3

local DEFAULT_PRIORITY = { "target" }
-- A heal lands on whoever is under the cursor, else the friendly target, else the player.
local HELPFUL_PRIORITY = { "mouseover", "target", "player" }
local HELPFUL_KINDS = { friendly = true, buff = true, resurrect = true }
-- A resurrection can't raise the player casting it or a pet, nor reach a dead target's target.
local LEFT_OUT_UNITS = {
	enemy = { player = true, pet = true },
	resurrect = { player = true, pet = true, targettarget = true },
}

local PRIORITY_KINDS = { enemy = true, friendly = true, buff = true, resurrect = true, anyone = true }

function ns.KindOffersTargetPriority(kind)
	return PRIORITY_KINDS[kind] == true
end

-- Classic Era has no focus.
function ns.KindOffersUnit(kind, unit)
	if unit == "focus" and ns.FLAVOR == "Vanilla" then
		return false
	end
	return not (LEFT_OUT_UNITS[kind] and LEFT_OUT_UNITS[kind][unit])
end

function ns.OffersTargetPriority(macro)
	return ns.KindOffersTargetPriority(macro.kind)
end

-- The target alone when nothing is left.
local function Usable(list, kind)
	local usable, seen = {}, {}
	for _, unit in ipairs(list) do
		if not seen[unit] and ns.KindOffersUnit(kind, unit) then
			seen[unit] = true
			usable[#usable + 1] = unit
		end
	end
	return #usable > 0 and usable or DEFAULT_PRIORITY
end

function ns.KindTargetPriority(kind)
	local list = ns.db.profile.kindDefaults[kind].targetPriority
	if type(list) ~= "table" then
		return HELPFUL_KINDS[kind] and Usable(HELPFUL_PRIORITY, kind) or DEFAULT_PRIORITY
	end
	return Usable(list, kind)
end

function ns.SetKindTargetPriority(kind, list)
	ns.db.profile.kindDefaults[kind].targetPriority = list
end

-- Don't modify it.
function ns.TargetPriority(macro)
	if not ns.OffersTargetPriority(macro) then
		return NO_SLOTS
	end
	local own = GetSetting(macro, "targetPriority")
	if type(own) == "table" then
		return Usable(own, macro.kind)
	end
	return ns.KindTargetPriority(macro.kind)
end

function ns.TriesUnit(macro, unit)
	for _, tried in ipairs(ns.TargetPriority(macro)) do
		if tried == unit then
			return true
		end
	end
	return false
end

-- The target alone is just the plain cast.
function ns.HasTargetPriority(macro)
	local list = ns.TargetPriority(macro)
	return #list > 1 or (list[1] ~= nil and list[1] ~= "target")
end

local function SameList(a, b)
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

--[[
	A unit taken lower down moves up to place; the rest shift down, the last dropping off past the slots. nil
	(None) ends the list here.
]]
local function PlaceUnit(current, place, unit)
	local list = {}
	for i, tried in ipairs(current) do
		if i < place and tried ~= unit then
			list[#list + 1] = tried
		end
	end
	if unit then
		list[#list + 1] = unit
		for i, tried in ipairs(current) do
			if i >= place and tried ~= unit and #list < ns.TARGET_PRIORITY_SLOTS then
				list[#list + 1] = tried
			end
		end
	end
	return list
end

-- Stored only where it differs from the kind's list.
function ns.SetTargetPriorityUnit(macro, place, unit)
	local list = PlaceUnit(ns.TargetPriority(macro), place, unit)
	StoreSetting(macro, "targetPriority", not SameList(list, ns.KindTargetPriority(macro.kind)) and list or nil)
end
