local _, ns = ...
local L = ns.L
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey

--[[
	A per-spell setting, "conditionals", so a Duplicate copy keeps its own and Delete and the middle-click reset
	drop them with the rest.
]]

--------------------------------------------------------------------------------
-- Conditions
--------------------------------------------------------------------------------

--[[
	Every condition a row can check, in the order its dropdown lists them, as { key, the macro conditional it
	writes, its label key, its short label key for the menu's value, its explanation key }. combat marks the two
	a macro's own combat check makes pointless, spec the two only a character with dual spec is offered (specGroup
	the talent group each matches), and opposite the condition that can never match alongside it, which a row's
	second dropdown leaves out.
]]
ns.CONDITIONS = {
	{
		key = "shift",
		clause = "mod:shift",
		labelKey = "CONDITION_SHIFT",
		shortKey = "CONDITION_SHIFT_SHORT",
		descKey = "CONDITION_SHIFT_DESCRIPTION",
	},
	{
		key = "ctrl",
		clause = "mod:ctrl",
		labelKey = "CONDITION_CTRL",
		shortKey = "CONDITION_CTRL_SHORT",
		descKey = "CONDITION_CTRL_DESCRIPTION",
	},
	{
		key = "alt",
		clause = "mod:alt",
		labelKey = "CONDITION_ALT",
		shortKey = "CONDITION_ALT_SHORT",
		descKey = "CONDITION_ALT_DESCRIPTION",
	},
	{
		key = "rightClick",
		clause = "btn:2",
		labelKey = "CONDITION_RIGHT_CLICK",
		shortKey = "CONDITION_RIGHT_CLICK",
		descKey = "CONDITION_RIGHT_CLICK_DESCRIPTION",
	},
	{
		key = "combat",
		clause = "combat",
		labelKey = "CONDITION_IN_COMBAT",
		shortKey = "CONDITION_IN_COMBAT",
		descKey = "CONDITION_IN_COMBAT_DESCRIPTION",
		combat = true,
		opposite = "noCombat",
	},
	{
		key = "noCombat",
		clause = "nocombat",
		labelKey = "CONDITION_OUT_OF_COMBAT",
		shortKey = "CONDITION_OUT_OF_COMBAT",
		descKey = "CONDITION_OUT_OF_COMBAT_DESCRIPTION",
		combat = true,
		opposite = "combat",
	},
	{
		key = "spec1",
		clause = "spec:1",
		specGroup = 1,
		labelKey = "CONDITION_SPEC_1",
		shortKey = "CONDITION_SPEC_1",
		descKey = "CONDITION_SPEC_1_DESCRIPTION",
		spec = true,
		opposite = "spec2",
	},
	{
		key = "spec2",
		clause = "spec:2",
		specGroup = 2,
		labelKey = "CONDITION_SPEC_2",
		shortKey = "CONDITION_SPEC_2",
		descKey = "CONDITION_SPEC_2_DESCRIPTION",
		spec = true,
		opposite = "spec1",
	},
}

local BY_KEY = {}
for _, condition in ipairs(ns.CONDITIONS) do
	BY_KEY[condition.key] = condition
end

-- nil for a key no client knows
function ns.ConditionRow(key)
	return BY_KEY[key]
end

--[[
	The most rows a macro takes, which is what the panel has room for, and the most conditions a row joins. Every
	row repeats its whole condition, so a full list runs into the macro's 255 bytes well before this.
]]
ns.CONDITIONALS_MAX_ROWS = 8
ns.CONDITIONALS_MAX_CONDITIONS = 2

-- [spec:2] can only match with dual spec on the client and learned.
function ns.HasDualSpec()
	return (ns.GetNumSpecGroups() or 1) >= 2
end

-- 1 or 2, or nil on a client that can't say
local function ActiveSpecGroup()
	return ns.GetActiveSpecGroup()
end

function ns.ConditionMenuLabel(condition)
	local label = L[condition.labelKey]
	if condition.specGroup and condition.specGroup == ActiveSpecGroup() then
		return L["CONDITION_SPEC_CURRENT"]:format(label)
	end
	return label
end

function ns.OffersCondition(key)
	local condition = BY_KEY[key]
	return condition ~= nil and (not condition.spec or ns.HasDualSpec())
end

--[[
	The combat check's /stopmacro makes In Combat always match and Out Of Combat never, or the other way about.
	Right-Click For writes btn:2 clauses of its own and wins the right-click, since it is a kind default on buffs;
	the menus, in turn, won't turn it on while a row uses Right-Click.
]]
function ns.ConditionBlockReason(macro, key)
	local condition = BY_KEY[key]
	if not condition then
		return nil
	end
	if condition.combat and ns.CombatCheck(macro) then
		return L["CONDITION_COMBAT_BLOCKED"]
	end
	if key == "rightClick" and ns.IsOptionOn(macro, "groupVersion") then
		return L["CONDITION_RIGHT_CLICK_BLOCKED"]:format(ns.RightClickSpell(macro))
	end
	return nil
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

-- A consumable's are Consumable Macros'.
function ns.OffersConditionals(macro)
	return ns.HasOptions(macro)
end

local NO_ROWS = {}

--[[
	Each { when = { condition keys }, spellID, fixed, ranged }: fixed casts that rank rather than the highest known;
	ranged follows the weapon worn. A row with neither ID nor ranged writes nothing. Rows are never changed in
	place, only replaced: the setters store a fresh list of fresh rows.
]]
function ns.Conditionals(macro)
	if not ns.OffersConditionals(macro) then
		return NO_ROWS
	end
	local rows = SpellSettings("conditionals")[SettingsKey(macro)]
	return type(rows) == "table" and rows or NO_ROWS
end

local function CopyRows(macro)
	local rows = {}
	for i, row in ipairs(ns.Conditionals(macro)) do
		local when = {}
		for k, key in ipairs(row.when or NO_ROWS) do
			when[k] = key
		end
		rows[i] = { when = when, spellID = row.spellID, fixed = row.fixed, ranged = row.ranged }
	end
	return rows
end

local function StoreRows(macro, rows)
	SpellSettings("conditionals")[SettingsKey(macro)] = #rows > 0 and rows or nil
end

local function KnownConditions(row)
	local known = {}
	for _, key in ipairs(row.when or NO_ROWS) do
		if BY_KEY[key] then
			known[#known + 1] = key
		end
	end
	return known
end

local function RowBlockReason(macro, row)
	for _, key in ipairs(KnownConditions(row)) do
		local reason = ns.ConditionBlockReason(macro, key)
		if reason then
			return reason
		end
	end
	return nil
end

function ns.ConditionalHasSpell(row)
	return row.spellID ~= nil or row.ranged == true
end
local HasSpell = ns.ConditionalHasSpell

-- Whether every condition of one row is among another's, so whenever the second matches the first does too.
local function Within(row, other)
	local checks = {}
	for _, key in ipairs(KnownConditions(other)) do
		checks[key] = true
	end
	for _, key in ipairs(KnownConditions(row)) do
		if not checks[key] then
			return false
		end
	end
	return true
end

--[[
	An earlier row that matches whenever this one does (Shift above Shift and Alt) always casts first. An earlier
	ranged row never shadows one: its clauses also check the weapon worn, so with none it falls through. The macro
	text leaves a skipped row out, which saves its bytes.
]]
function ns.ConditionalSkipReason(macro, index)
	local rows = ns.Conditionals(macro)
	local row = rows[index]
	if not row then
		return nil
	end
	local blocked = RowBlockReason(macro, row)
	if blocked then
		return blocked
	end
	for i = 1, index - 1 do
		local earlier = rows[i]
		local casts = HasSpell(earlier) and not earlier.ranged
		if casts and #KnownConditions(earlier) > 0 and not RowBlockReason(macro, earlier) then
			if Within(earlier, row) then
				return L["CONDITIONALS_SHADOWED"]:format(i)
			end
		end
	end
	return nil
end

-- Whether a row of the macro checks Right-Click, which keeps Grouped Spells' Right-Click For off.
function ns.ConditionalsUseRightClick(macro)
	for _, row in ipairs(ns.Conditionals(macro)) do
		for _, key in ipairs(row.when or NO_ROWS) do
			if key == "rightClick" then
				return true
			end
		end
	end
	return false
end

function ns.ConditionalCount(macro)
	local count = 0
	for _, row in ipairs(ns.Conditionals(macro)) do
		if HasSpell(row) then
			count = count + 1
		end
	end
	return count
end

function ns.ConditionalSpellID(row)
	if row.ranged then
		return ns.WornRangedAttackID()
	end
	return row.spellID
end

-- "Shift: Frost Nova", or "Spec 2 + Alt: Blizzard"
function ns.ConditionalSummaries(macro)
	local summaries = {}
	for _, row in ipairs(ns.Conditionals(macro)) do
		local text = ns.ConditionalSpellText(row)
		if text then
			local labels = {}
			for i, key in ipairs(KnownConditions(row)) do
				labels[i] = L[BY_KEY[key].shortKey]
			end
			local when = labels[1] or ""
			for i = 2, #labels do
				when = L["CONDITIONALS_JOIN"]:format(when, labels[i])
			end
			summaries[#summaries + 1] = L["CONDITIONALS_SUMMARY"]:format(when, text)
		end
	end
	return summaries
end

--[[
	Each casts on a plain target, never the macro's Target priority, since every clause would repeat the row's
	whole condition and fill the 255 bytes fast. A ranged row writes one clause per ranged attack by [worn:], so a
	weapon swapped mid-fight needs no rewrite.
]]
function ns.ConditionalClauses(macro)
	local clauses = {}
	for index, row in ipairs(ns.Conditionals(macro)) do
		local known = KnownConditions(row)
		if HasSpell(row) and #known > 0 and not ns.ConditionalSkipReason(macro, index) then
			local parts = {}
			for i, key in ipairs(known) do
				parts[i] = BY_KEY[key].clause
			end
			local condition = table.concat(parts, ",")
			if row.ranged then
				for _, attack in ipairs(ns.KnownRangedAttacks()) do
					clauses[#clauses + 1] = { condition .. ",worn:" .. attack.wornName, nil, attack.name }
				end
			else
				local text = ns.ConditionalSpellText(row)
				if text then
					clauses[#clauses + 1] = { condition, nil, text }
				end
			end
		end
	end
	return clauses
end

-- The setters only change the stored rows; the panel then rebuilds the page, which rewrites the macro.

-- Skips a condition a row already checks alone, since a second such row would never cast.
function ns.AddConditional(macro)
	local rows = CopyRows(macro)
	if #rows >= ns.CONDITIONALS_MAX_ROWS then
		return
	end
	local taken = {}
	for _, row in ipairs(rows) do
		if #row.when == 1 then
			taken[row.when[1]] = true
		end
	end
	local first = "shift"
	for _, condition in ipairs(ns.CONDITIONS) do
		local key = condition.key
		if not taken[key] and ns.OffersCondition(key) and not ns.ConditionBlockReason(macro, key) then
			first = key
			break
		end
	end
	rows[#rows + 1] = { when = { first } }
	StoreRows(macro, rows)
end

function ns.RemoveConditional(macro, index)
	local rows = CopyRows(macro)
	table.remove(rows, index)
	StoreRows(macro, rows)
end

function ns.MoveConditional(macro, from, to)
	local rows = CopyRows(macro)
	if from == to or not rows[from] or not rows[to] then
		return
	end
	local row = table.remove(rows, from)
	table.insert(rows, to, row)
	StoreRows(macro, rows)
end

-- place is 1 or 2; a nil key drops the second.
function ns.SetConditionalCondition(macro, index, place, key)
	local rows = CopyRows(macro)
	local row = rows[index]
	if not row then
		return
	end
	if key then
		row.when[math.min(place, #row.when + 1)] = key
	elseif place > 1 then
		row.when[place] = nil
	end
	StoreRows(macro, rows)
end

-- pick is { spellID, fixed, ranged }
function ns.SetConditionalSpell(macro, index, pick)
	local rows = CopyRows(macro)
	local row = rows[index]
	if not row then
		return
	end
	row.spellID, row.fixed, row.ranged = pick.spellID, pick.fixed, pick.ranged
	StoreRows(macro, rows)
end
