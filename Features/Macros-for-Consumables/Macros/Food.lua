local _, ns = ...

--------------------------------------------------------------------------------
-- Food Macro
--------------------------------------------------------------------------------

-- Set by modifyItem, which the engine always calls first, and read later in the same pass.
local petBuffOverride = false

-- One enableStealthEating key serves both Stealth (Rogues) and Shadowmeld (other Night Elves).
local function StealthEatingSpell()
	local settings = ns.db and ns.db.profile
	if not settings or not settings.enableStealthEating then
		return nil
	end
	if ns.isRogue and ns.stealthSpellName then
		return ns.stealthSpellName, "SE"
	end
	if ns.isNightElf and ns.shadowmeldSpellName then
		return ns.shadowmeldSpellName, "SE"
	end
	return nil
end

ns.RegisterMacroType({
	typeName = "Food",

	-- Buff food ranks last rather than out, so a bag of only buff food still feeds you.
	itemTypes = { food = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and ns.excludeBuffFood)
	end,
	score = function(data)
		return data.healthValue
	end,
	allowBuffFood = true,
	buffFoodFirstWhenUnfed = true,
	allowConjuredFirst = true,
	allowRestockLast = true,
	preferHybrid = true,
	winnerExtras = function(winner, _, hyperlink)
		winner.link = hyperlink
	end,

	conjure = function()
		return ns.ResolveMageWaterOrFoodConjure(ns.CONJURE_SPELLS.MageCreateFood, "noConjureFood")
	end,

	modifyItem = function(itemID)
		petBuffOverride = false
		if ns.petBuffOverrideID then
			petBuffOverride = true
			return ns.petBuffOverrideID
		end
		return itemID
	end,

	buildUseLine = function(itemID)
		if petBuffOverride then
			return "/use [@pet] item:" .. itemID
		end
		return nil
	end,

	-- Only on a body the player eats from: no food, or the pet-buff override, would stealth for nothing.
	appendBlock = function(itemID)
		if not itemID or petBuffOverride then
			return nil
		end
		local spellName, flag = StealthEatingSpell()
		if spellName then
			return "\n/cast [nostealth] " .. spellName, flag
		end
		return nil
	end,

	stealthSpell = StealthEatingSpell,

	corpseSpell = function(entry)
		return ns.CannibalizeCast("enableCannibalizeEating", entry)
	end,

	combatSpell = function()
		return ns.RapidRegenerationCombatCast()
	end,
})
