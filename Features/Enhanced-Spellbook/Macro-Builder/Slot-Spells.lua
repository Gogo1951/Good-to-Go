local _, ns = ...

local NO_ROWS = {}

--------------------------------------------------------------------------------
-- Slot Spells
--------------------------------------------------------------------------------

-- nil while the spell's data isn't loaded; a ranged row names the client's Shoot
function ns.ConditionalSpellName(row)
	if row.ranged then
		return C_Spell.GetSpellName(ns.SHOOT_SPELL_ID), nil
	end
	local name = row.spellID and C_Spell.GetSpellName(row.spellID)
	local rank = name and row.fixed and C_Spell.GetSpellSubtext(row.spellID)
	return name, rank ~= "" and rank or nil
end

-- "Frostbolt", or "Frostbolt(Rank 1)" for a row fixed to a rank
function ns.ConditionalSpellText(row)
	local name, rank = ns.ConditionalSpellName(row)
	return name and name .. (rank and "(" .. rank .. ")" or "")
end

local function IsKnownRank(macro, spellID)
	for _, rank in ipairs(macro.ranks or NO_ROWS) do
		if rank.id == spellID then
			return true
		end
	end
	return false
end

--[[
	{ spellID, fixed, ranged }, or nil for a consumable (an item) or a spell not learned yet. A rank's own macro,
	or one with a Fixed Rank, gives that rank, fixed.
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
	Fixed when it's a lower rank than the highest known, so the rank dragged is the rank cast. The page macro is
	found by the rank's ID among its known ranks, never by name.
]]
function ns.ConditionalPickOfSpell(spellID)
	for _, macro in ipairs(ns.macros or NO_ROWS) do
		if not macro.copy and not macro.rank and IsKnownRank(macro, spellID) then
			if macro.ranks[1].id ~= spellID then
				return { spellID = spellID, fixed = true }
			end
			break
		end
	end
	return { spellID = spellID }
end
