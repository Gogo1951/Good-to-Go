local _, ns = ...

local NO_ROWS = {}

--[[
	The spells in the docked panels' slots, a Conditionals row's and a Cast Sequence step's: what one casts, read
	from the client now, and the pick a page macro or a dragged spell gives it.
]]

--------------------------------------------------------------------------------
-- Slot Spells
--------------------------------------------------------------------------------

--[[
	What a row casts, read from the client now: its name and, for a row fixed to a rank, that rank's text, or nil
	while the spell's data isn't loaded. A ranged row names the client's Shoot.
]]
function ns.ConditionalSpellName(row)
	if row.ranged then
		return C_Spell.GetSpellName(ns.SHOOT_SPELL_ID), nil
	end
	local name = row.spellID and C_Spell.GetSpellName(row.spellID)
	local rank = name and row.fixed and C_Spell.GetSpellSubtext(row.spellID)
	return name, rank ~= "" and rank or nil
end

-- What a row casts, as the macro text names it: "Frostbolt", or "Frostbolt(Rank 1)" for a row fixed to a rank.
function ns.ConditionalSpellText(row)
	local name, rank = ns.ConditionalSpellName(row)
	return name and name .. (rank and "(" .. rank .. ")" or "")
end

-- Whether a spell ID is one of the macro's known ranks.
local function IsKnownRank(macro, spellID)
	for _, rank in ipairs(macro.ranks or NO_ROWS) do
		if rank.id == spellID then
			return true
		end
	end
	return false
end

--[[
	The spell a page macro gives a row, as { spellID, fixed, ranged }, or nil for one that can't be picked: a
	consumable's, which is an item, and a spell not learned yet. A rank's own macro, or one with a Fixed Rank,
	gives that rank, fixed; the Shoot macro gives ranged, the attack for whatever ranged weapon is worn.
]]
function ns.ConditionalSpellOf(macro)
	if macro.consumable or macro.unlearned then
		return nil
	end
	if macro.rangedAttacks then
		return { ranged = true }
	end
	local fixedID = ns.FixedRankID(macro)
	if fixedID then
		return { spellID = fixedID, fixed = true }
	end
	local top = macro.ranks and macro.ranks[1]
	return { spellID = top and top.id or macro.spellID }
end

--[[
	A spell from a spellbook or an action bar, by its ID, as a row's pick: fixed when it's a lower rank than the
	highest its page macro knows, so the rank dragged is the rank cast. The page macro is found by the rank's ID
	among its known ranks, never by name.
]]
function ns.ConditionalPickOfSpell(spellID)
	for _, macro in ipairs(ns.macros or NO_ROWS) do
		if not macro.copy and not macro.focus and not macro.rank and IsKnownRank(macro, spellID) then
			if macro.ranks[1].id ~= spellID then
				return { spellID = spellID, fixed = true }
			end
			break
		end
	end
	return { spellID = spellID }
end
