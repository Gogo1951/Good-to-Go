local _, ns = ...

--------------------------------------------------------------------------------
-- Warlock Conjure Resolution
--------------------------------------------------------------------------------

--[[
    Ranked vs bare stone casts differ per flavor, and that split is data, not
    code: read the RECURRING BUG note on WarlockCreateHealthstone in
    Data/{Game}/Conjure-Spells-{Game}.lua before touching rank handling.
]]

-- Healthstones are unique per tier, so checkUnique conjures the next rank down instead of a duplicate.
function ns.ResolveWarlockHealthstoneConjure()
	if not ns.isWarlock then
		return nil
	end

	local info = {}

	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateHealthstone) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateHealthstone, false, true)
	else
		info.rightMiss = "noCreateHealthstone"
		info.noItemMiss = "noCreateHealthstone"
	end

	-- The Soulwell serves the whole raid, so a low-level target never downranks it.
	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulwell) then
		info.middleName, info.middleID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateSoulwell, true)
	elseif #ns.CONJURE_SPELLS.WarlockCreateSoulwell > 0 then
		info.middleMiss = "noRitualOfSouls"
	end

	return info
end

--[[
    No checkUnique: soulstones share a 30-minute cooldown, so a lower rank
    beside the best one would only waste a shard. No target downrank: the best
    rank already meets every max-target-level cap.
]]
function ns.ResolveWarlockSoulstoneConjure()
	if not ns.isWarlock then
		return nil
	end

	local info = {}

	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulstone) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateSoulstone, true, false)
	else
		info.rightMiss = "noCreateSoulstone"
		info.noItemMiss = "noCreateSoulstone"
	end

	return info
end
