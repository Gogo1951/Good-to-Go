local _, ns = ...
local L = ns.L
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey

--[[
	A page macro's Cast Sequence: the macro's own spell as step 1, then the steps added after it, each pressed
	in turn, as a /castsequence. When the last step has cast, the sequence starts over, or stops on NULL (a
	spell no one knows, so the line casts nothing more) until a reset starts it over: the target changing,
	combat ending, Shift, Ctrl or Alt held on a press, or some seconds without a press. A step that fails (out
	of range, on cooldown) doesn't move the sequence on, so the next press tries it again.

	Three per-spell settings (Features/Enhanced-Spellbook/Macro-Options.lua) hold it, each flat so a Duplicate copy
	gets its own (Features/Enhanced-Spellbook/Macro-Copies.lua): "castSequence" the added steps, "castSequenceEnd"
	"stop" or nil for starting over, and "castSequenceReset" the resets, keys and a number of seconds.
	Features/Enhanced-Spellbook/Macro-Body.lua writes them into the cast line, and
	Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence-Panel.lua is the panel docked beside the Spellbook that sets them.
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
	Every spell macro offers a Cast Sequence but a focus copy, which shares its spell's settings key and casts
	only on the focus; a consumable's, which is Consumable Macros'; and the Shoot macro's, whose attack follows the
	weapon worn by a clause per weapon, which a sequence can't take.
]]
function ns.OffersCastSequence(macro)
	return ns.HasOptions(macro) and not macro.focus and not macro.rangedAttacks
end

--[[
	Why a macro's sequence writes nothing, as the line the panel shows, or nil when it casts. A summon macro
	casting its pet's ability while the pet is out writes a cast line of its own.
]]
function ns.CastSequenceBlockReason(macro)
	if ns.IsOptionOn(macro, "pet") then
		return L["CAST_SEQUENCE_PET_BLOCKED"]:format(macro.petAbility)
	end
	return nil
end

--[[
	The steps after the macro's own, in order, each { spellID, fixed }: spellID the rank's own ID, fixed when
	the step casts that rank rather than the highest known. A step with no spell is waiting for one, and
	writes nothing. Steps are never changed in place, only replaced: the setters store a fresh list.
]]
function ns.CastSequenceSteps(macro)
	if not ns.OffersCastSequence(macro) then
		return NO_STEPS
	end
	local steps = SpellSettings("castSequence")[SettingsKey(macro)]
	return type(steps) == "table" and steps or NO_STEPS
end

-- How many steps after the macro's own have a spell.
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
	Whether the macro casts a sequence: it offers one, nothing blocks it, and a step after its own has a spell or
	it stops on NULL. The macro's own spell then NULL is a sequence of its own: it casts once, then nothing until
	a reset, "/castsequence reset=target Rend, NULL".
]]
function ns.IsCastSequenceOn(macro)
	return (ns.CastSequenceStepCount(macro) > 0 or ns.CastSequenceStops(macro))
		and not ns.CastSequenceBlockReason(macro)
end

-- Whether the sequence stops on NULL when its last step has cast, rather than starting over.
function ns.CastSequenceStops(macro)
	return ns.OffersCastSequence(macro) and SpellSettings("castSequenceEnd")[SettingsKey(macro)] == "stop"
end

-- The sequence's resets, as stored: keys from CAST_SEQUENCE_RESETS and at most one number of seconds.
local function StoredResets(macro)
	local resets = SpellSettings("castSequenceReset")[SettingsKey(macro)]
	return type(resets) == "table" and resets or DEFAULT_RESETS
end

-- Whether the sequence starts over on a reset key ("target", "shift").
function ns.IsCastSequenceReset(macro, key)
	for _, reset in ipairs(StoredResets(macro)) do
		if reset == key then
			return true
		end
	end
	return false
end

-- The seconds without a press after which the sequence starts over, or nil for none.
function ns.CastSequenceSeconds(macro)
	for _, reset in ipairs(StoredResets(macro)) do
		if type(reset) == "number" then
			return reset
		end
	end
	return nil
end

--[[
	What reset= writes for the macro, the seconds first then the keys in the menu's order ("5/target/combat"),
	or nil for none, when the sequence never starts over by itself.
]]
function ns.CastSequenceResetText(macro)
	local parts = { ns.CastSequenceSeconds(macro) }
	for _, reset in ipairs(ns.CAST_SEQUENCE_RESETS) do
		if ns.IsCastSequenceReset(macro, reset.key) then
			parts[#parts + 1] = reset.key
		end
	end
	return #parts > 0 and table.concat(parts, "/") or nil
end

-- The resets by their labels, for the panel's dropdown and the tile's tooltip: "Target Changes, 5 Seconds".
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

-- What a step casts, as the macro text names it: "Corruption", or "Immolate(Rank 1)" for a step fixed to a rank.
local function StepText(step)
	return step.spellID and ns.ConditionalSpellText(step)
end

--[[
	What follows the macro's own spell in its sequence: ", Corruption, Curse of Agony", then ", NULL" where it
	stops. A step whose spell isn't loaded is left out until it is.
]]
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

--[[
	The sequence in short words, for the menu's value and the tile's tooltip: "Fireball, Frostbolt, Stop", the
	macro's own spell first.
]]
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

--[[
	The setters below only change the stored settings; the panel then rebuilds the page, which rewrites the
	macro (ns.RefreshSpellbookPage), as the menu does.
]]

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

-- Adds a step at the end with no spell yet.
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

-- Moves the step at from to the place to, the steps between shifting a place to make room.
function ns.MoveCastSequenceStep(macro, from, to)
	local steps = CopySteps(macro)
	if from == to or not steps[from] or not steps[to] then
		return
	end
	table.insert(steps, to, table.remove(steps, from))
	StoreSteps(macro, steps)
end

-- Sets the spell a step casts, from a { spellID, fixed } pick (ns.CastSequenceSpellOf).
function ns.SetCastSequenceStepSpell(macro, index, pick)
	local steps = CopySteps(macro)
	if not steps[index] then
		return
	end
	steps[index] = { spellID = pick.spellID, fixed = pick.fixed }
	StoreSteps(macro, steps)
end

-- Sets whether the sequence stops on NULL when its last step has cast, or starts over.
function ns.SetCastSequenceStops(macro, stops)
	SpellSettings("castSequenceEnd")[SettingsKey(macro)] = stops and "stop" or nil
end

-- Stores the resets, or nil for the default ones.
local function StoreResets(macro, resets)
	local default = #resets == #DEFAULT_RESETS
	for i, reset in ipairs(DEFAULT_RESETS) do
		default = default and resets[i] == reset
	end
	SpellSettings("castSequenceReset")[SettingsKey(macro)] = not default and resets or nil
end

-- The stored resets with key turned on or off, the keys in the menu's order and the seconds after.
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

-- Sets the seconds without a press after which the sequence starts over, or nil for none.
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

--[[
	The spell a page macro gives a step, as { spellID, fixed }, or nil for one that can't be picked: the ones
	ns.ConditionalSpellOf turns down, and the Shoot macro, whose attack depends on the weapon worn.
]]
function ns.CastSequenceSpellOf(macro)
	local pick = ns.ConditionalSpellOf(macro)
	return pick and not pick.ranged and pick or nil
end
