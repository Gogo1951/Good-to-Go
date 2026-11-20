local _, ns = ...

--------------------------------------------------------------------------------
-- Food Macro
--------------------------------------------------------------------------------

--[[
    The busiest macro definition: the food that restores the most, buff food
    with the rest or kept for last (ns.buffFoodRank, from Eat Buff Food When
    Already Well Fed), and a pet-buff-food override when the Hunter feature
    wants the pet fed. Buff Duty offers buff food for the buff, and scrolls:
    its window offers them while they're missing (Buff-Duty-Self.lua).
]]

--[[
    Pet buff override flag — set by modifyItem, read by appendBlock and
    buildUseLine later in the same update iteration (the engine always calls
    modifyItem first). The override replaces the Food slot item with pet food.
]]
local petBuffOverride = false

--[[
    Stealth Eating's spell and state flag, or nil while the option is off or
    the character has no stealth to eat in: Stealth for Rogues, Shadowmeld for
    other Night Elves. One enableStealthEating key serves both.
]]
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

	--[[
	    Selection: any food competes, including the food half of a foodwater
	    hybrid (which also feeds Water), by raw food value. Buff food always
	    competes (except while targeting yourself, ns.excludeBuffFood) and
	    ranks by ns.buffFoodRank: with the rest while Eat Buff Food When
	    Already Well Fed is on, last otherwise, so a bag of only buff food
	    still feeds you. While Use Conjured Food & Water First holds
	    (ns.allowConjuredFirst), conjured food comes next, ahead of anything
	    that restores more. While Use Restock List Food & Water Last holds
	    (ns.allowRestockLast), food off the Restock List beats an equal one
	    on it. Hybrids beat dedicated food on ties — one bag
	    slot covering both needs. The winner record carries the item link,
	    which the scanner publishes as ns.bestFoodLink for the mini-map
	    menu.
	]]
	itemTypes = { food = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and ns.excludeBuffFood)
	end,
	score = function(data)
		return data.healthValue
	end,
	allowBuffFood = true,
	allowConjuredFirst = true,
	allowRestockLast = true,
	preferHybrid = true,
	--[[
	    Only the link: every field the ladder compares is filled by the
	    scanner's FillRecord, for this category and all the others.
	]]
	winnerExtras = function(winner, _, hyperlink)
		winner.link = hyperlink
	end,

	--[[
	    Mage conjure: shared Water/Food resolution (Refreshment Table on
	    middle-click) lives in Tools-Mages.lua; called at update time.
	]]
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

	-- Pet food buffs target the pet.
	buildUseLine = function(itemID)
		if petBuffOverride then
			return "/use [@pet] item:" .. itemID
		end
		return nil
	end,

	--[[
	    Stealth Eating: appends a stealth cast below the food line -- Stealth
	    for Rogues, Shadowmeld for other Night Elves -- so the player stealths
	    while eating. The "SE" flag keeps the append in the state key so
	    toggling the option rewrites the macro. Only a body the player eats
	    from carries it: with no food the press would stealth for nothing, and
	    the pet-buff override feeds the pet rather than the player.
	]]
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

	--[[
	    The Health Potion macro eats this macro's pick out of combat
	    (outOfCombatTypeName), and stealths the same way while it does.
	]]
	stealthSpell = StealthEatingSpell,

	--[[
	    Forsaken Cannibalize Eating: tries Cannibalize first on a dead Humanoid
	    or Undead target, and eats when it cannot cast (Tools-Forsaken.lua). The engine asks
	    only for a body that eats the scanned pick, so the pet-buff override
	    never carries it; the Health Potion macro asks for its out-of-combat
	    food too.
	]]
	corpseSpell = function(entry)
		return ns.CannibalizeCast("enableCannibalizeEating", entry)
	end,

	--[[
	    Troll Rapid Regeneration: a press in combat, where nobody eats, casts
	    it instead (Tools-Troll.lua). Asked under the same rule as corpseSpell,
	    so the pet-buff override never carries it.
	]]
	combatSpell = function()
		return ns.RapidRegenerationCombatCast()
	end,
})
