local _, ns = ...

--------------------------------------------------------------------------------
-- Water Macro
--------------------------------------------------------------------------------

-- Night Elves only, Rogues included, though every character sees the toggle.
local function ShadowmeldDrinkingSpell()
	if not ns.isNightElf then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings.enableShadowmeldDrinking then
		return nil
	end
	if not ns.shadowmeldSpellName then
		return nil
	end
	return ns.shadowmeldSpellName, "SM"
end

ns.RegisterMacroType({
	typeName = "Water",

	itemTypes = { water = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and ns.excludeBuffFood)
	end,
	score = function(data)
		return data.manaValue
	end,
	allowBuffFood = true,
	allowConjuredFirst = true,
	allowRestockLast = true,
	-- A hybrid is better saved for the Food macro.
	preferHybrid = false,
	conjure = function()
		return ns.ResolveMageWaterOrFoodConjure(ns.CONJURE_SPELLS.MageCreateWater, "noConjureWater")
	end,

	appendBlock = function(itemID)
		if not itemID then
			return nil
		end
		local spellName, flag = ShadowmeldDrinkingSpell()
		if spellName then
			return "\n/cast [nostealth] " .. spellName, flag
		end
		return nil
	end,

	stealthSpell = ShadowmeldDrinkingSpell,

	-- Elsewhere the toggle is hidden, so a stale saved value must never fire.
	corpseSpell = function(entry)
		if not ns.CANNIBALIZE_RESTORES_MANA then
			return nil
		end
		return ns.CannibalizeCast("enableCannibalizeDrinking", entry)
	end,
})
