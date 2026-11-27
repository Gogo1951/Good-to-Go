local _, ns = ...

--------------------------------------------------------------------------------
-- Mage Conjure Resolution
--------------------------------------------------------------------------------

function ns.ResolveMageWaterOrFoodConjure(rightList, rightMissKey)
	if not ns.isMage then
		return nil
	end

	local info = {}

	if ns.KnowsAny(rightList) then
		info.rightName, info.rightID = ns.GetSmartSpell(rightList)
	else
		info.rightMiss = rightMissKey
		info.noItemMiss = rightMissKey
	end

	-- The table serves the whole raid, so a low-level target never downranks it.
	if ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateTable) then
		info.middleName, info.middleID = ns.GetSmartSpell(ns.CONJURE_SPELLS.MageCreateTable, true)
	elseif #ns.CONJURE_SPELLS.MageCreateTable > 0 then
		info.middleMiss = "noRitualOfRefreshment"
	end

	return info
end

-- Mana gems are unique, so checkUnique conjures the next rank down instead of a duplicate.
function ns.ResolveMageManaGemConjure()
	if not ns.isMage then
		return nil
	end

	local info = {}
	if ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateManaGem) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.MageCreateManaGem, true, true)
	else
		info.rightMiss = "noConjureManaGem"
		info.noItemMiss = "noConjureManaGem"
	end
	return info
end
