local _, ns = ...
local L = ns.L
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey

--[[
	NULL is a spell no one knows, so the line casts nothing more until a reset. Three per-spell settings hold it,
	each flat so a Duplicate copy gets its own: "castSequence" the added steps, "castSequenceEnd" "stop" or nil,
	and "castSequenceReset" the reset keys and seconds.
]]

local NO_STEPS = {}

-- The most steps after the macro's own, which is what the panel has room for.
ns.CAST_SEQUENCE_MAX_STEPS = 7

--[[
	The resets a sequence can take, in the order its menu lists them, as { key, what reset= writes and what is
	stored; labelKey; descKey, the explanation }; a number of seconds without a press is the other kind, from
	CAST_SEQUENCE_SECONDS.
]]
ns.CAST_SEQUENCE_RESETS = {
	{ key = "target", labelKey = "CAST_SEQUENCE_RESET_TARGET", descKey = "CAST_SEQUENCE_RESET_TARGET_DESCRIPTION" },
	{ key = "combat", labelKey = "CAST_SEQUENCE_RESET_COMBAT", descKey = "CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION" },
	{ key = "shift", labelKey = "CAST_SEQUENCE_RESET_SHIFT", descKey = "CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION" },
	{ key = "ctrl", labelKey = "CAST_SEQUENCE_RESET_CTRL", descKey = "CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION" },
	{ key = "alt", labelKey = "CAST_SEQUENCE_RESET_ALT", descKey = "CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION" },
}
ns.CAST_SEQUENCE_SECONDS = { 3, 5, 10, 30 }

-- A new sequence starts over when the target changes or combat ends, which a rotation on one target wants.
local DEFAULT_RESETS = { "target", "combat" }

local RESET_KEYS = {}
for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
	RESET_KEYS[reset.key] = true
end

--------------------------------------------------------------------------------
-- Reading
--------------------------------------------------------------------------------

--[[
	A consumable's is Consumable Macros'; the Shoot macro's attack follows the weapon worn by a clause per weapon,
	which a sequence can't take.
]]
function ns.OffersCastSequence(macro)
	return ns.HasOptions(macro) and not macro.rangedAttacks
end

-- A summon macro casting its pet's ability while the pet is out writes a cast line of its own.
function ns.CastSequenceBlockReason(macro)
	if ns.IsOptionOn(macro, "pet") then
		return L["CAST_SEQUENCE_PET_BLOCKED"]:format(macro.petAbility)
	end
	return nil
end

--[[
	Each { spellID, fixed }: fixed casts that rank rather than the highest known. Steps are never changed in
	place, only replaced: the setters store a fresh list.
]]
function ns.CastSequenceSteps(macro)
	if not ns.OffersCastSequence(macro) then
		return NO_STEPS
	end
	local steps = SpellSettings("castSequence")[SettingsKey(macro)]
	return type(steps) == "table" and steps or NO_STEPS
end

function ns.CastSequenceStepCount(macro)
	local count = 0
	for _, step in ipairs(ns.CastSequenceSteps(macro)) do
		if step.spellID then
			count = count + 1
		end
	end
	return count
end

--[[
	The macro's own spell then NULL is a sequence of its own: it casts once, then nothing until a reset,
	"/castsequence reset=target Rend, NULL".
]]
function ns.IsCastSequenceOn(macro)
	return (ns.CastSequenceStepCount(macro) > 0 or ns.CastSequenceStops(macro))
		and not ns.CastSequenceBlockReason(macro)
end

function ns.CastSequenceStops(macro)
	return ns.OffersCastSequence(macro) and SpellSettings("castSequenceEnd")[SettingsKey(macro)] == "stop"
end

-- Keys from CAST_SEQUENCE_RESETS and at most one number of seconds.
local function StoredResets(macro)
	local resets = SpellSettings("castSequenceReset")[SettingsKey(macro)]
	return type(resets) == "table" and resets or DEFAULT_RESETS
end

function ns.IsCastSequenceReset(macro, key)
	for _, reset in ipairs(StoredResets(macro)) do
		if reset == key then
			return true
		end
	end
	return false
end

function ns.CastSequenceSeconds(macro)
	for _, reset in ipairs(StoredResets(macro)) do
		if type(reset) == "number" then
			return reset
		end
	end
	return nil
end

-- "5/target/combat": the seconds first, then the keys in the menu's order.
function ns.CastSequenceResetText(macro)
	local parts = { ns.CastSequenceSeconds(macro) }
	for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
		if ns.IsCastSequenceReset(macro, reset.key) then
			parts[#parts + 1] = reset.key
		end
	end
	return #parts > 0 and table.concat(parts, "/") or nil
end

-- "Target Changes, 5 Seconds"
function ns.CastSequenceResetLabels(macro)
	local labels = {}
	for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
		if ns.IsCastSequenceReset(macro, reset.key) then
			labels[#labels + 1] = L[reset.labelKey]
		end
	end
	local seconds = ns.CastSequenceSeconds(macro)
	if seconds then
		labels[#labels + 1] = L["CAST_SEQUENCE_RESET_SECONDS"]:format(seconds)
	end
	return labels
end

-- "Corruption", or "Immolate(Rank 1)" for a step fixed to a rank
local function StepText(step)
	return step.spellID and ns.ConditionalSpellText(step)
end

-- ", Corruption, Curse of Agony, NULL"; a step whose spell isn't loaded is left out until it is.
function ns.CastSequenceTail(macro)
	local tail = {}
	for _, step in ipairs(ns.CastSequenceSteps(macro)) do
		local text = StepText(step)
		if text then
			tail[#tail + 1] = ", " .. text
		end
	end
	if ns.CastSequenceStops(macro) then
		tail[#tail + 1] = ", NULL"
	end
	return table.concat(tail)
end

-- "Fireball, Frostbolt, Stop"
function ns.CastSequenceSummary(macro)
	local names = { ns.CastSpellName(macro) }
	for _, step in ipairs(ns.CastSequenceSteps(macro)) do
		local name = step.spellID and C_Spell.GetSpellName(step.spellID)
		if name then
			names[#names + 1] = name
		end
	end
	if ns.CastSequenceStops(macro) then
		names[#names + 1] = L["CAST_SEQUENCE_END_STOP_SHORT"]
	end
	return table.concat(names, L["LIST_SEPARATOR"])
end

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

-- The setters only change the stored settings; the panel then rebuilds the page, which rewrites the macro.

local function CopySteps(macro)
	local steps = {}
	for i, step in ipairs(ns.CastSequenceSteps(macro)) do
		steps[i] = { spellID = step.spellID, fixed = step.fixed }
	end
	return steps
end

local function StoreSteps(macro, steps)
	SpellSettings("castSequence")[SettingsKey(macro)] = #steps > 0 and steps or nil
end

function ns.AddCastSequenceStep(macro)
	local steps = CopySteps(macro)
	if #steps >= ns.CAST_SEQUENCE_MAX_STEPS then
		return
	end
	steps[#steps + 1] = {}
	StoreSteps(macro, steps)
end

function ns.RemoveCastSequenceStep(macro, index)
	local steps = CopySteps(macro)
	table.remove(steps, index)
	StoreSteps(macro, steps)
end

function ns.MoveCastSequenceStep(macro, from, to)
	local steps = CopySteps(macro)
	if from == to or not steps[from] or not steps[to] then
		return
	end
	table.insert(steps, to, table.remove(steps, from))
	StoreSteps(macro, steps)
end

-- pick is { spellID, fixed }
function ns.SetCastSequenceStepSpell(macro, index, pick)
	local steps = CopySteps(macro)
	if not steps[index] then
		return
	end
	steps[index] = { spellID = pick.spellID, fixed = pick.fixed }
	StoreSteps(macro, steps)
end

function ns.SetCastSequenceStops(macro, stops)
	SpellSettings("castSequenceEnd")[SettingsKey(macro)] = stops and "stop" or nil
end

-- nil for the default ones
local function StoreResets(macro, resets)
	local default = #resets == #DEFAULT_RESETS
	for i, reset in ipairs(DEFAULT_RESETS) do
		default = default and resets[i] == reset
	end
	SpellSettings("castSequenceReset")[SettingsKey(macro)] = not default and resets or nil
end

-- Stored with the keys in the menu's order and the seconds after.
function ns.ToggleCastSequenceReset(macro, key)
	if not RESET_KEYS[key] then
		return
	end
	local on = not ns.IsCastSequenceReset(macro, key)
	local resets = {}
	for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
		local want = reset.key == key and on or (reset.key ~= key and ns.IsCastSequenceReset(macro, reset.key))
		if want then
			resets[#resets + 1] = reset.key
		end
	end
	resets[#resets + 1] = ns.CastSequenceSeconds(macro)
	StoreResets(macro, resets)
end

function ns.SetCastSequenceSeconds(macro, seconds)
	local resets = {}
	for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
		if ns.IsCastSequenceReset(macro, reset.key) then
			resets[#resets + 1] = reset.key
		end
	end
	resets[#resets + 1] = seconds
	StoreResets(macro, resets)
end

-- The Shoot macro can't be picked: its attack depends on the weapon worn.
function ns.CastSequenceSpellOf(macro)
	local pick = ns.ConditionalSpellOf(macro)
	return pick and not pick.ranged and pick or nil
end
