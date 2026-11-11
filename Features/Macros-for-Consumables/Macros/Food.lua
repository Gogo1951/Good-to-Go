local _, ns = ...

--------------------------------------------------------------------------------
-- Food Macro
--------------------------------------------------------------------------------

--[[
    The busiest macro definition: plain food by default, buff food when the
    live ns.allowBuffFood preference allows it (the scanner computes that
    flag from setting/When to Use/Well Fed/arena state; the selection fields below
    declare how it applies), a pet-buff-food override when the Hunter
    feature wants the pet fed, and a full-body scroll-only mode when scroll
    buffs are missing.
]]

--[[
    Pet buff override flag — set by modifyItem, read by appendBlock and
    buildUseLine later in the same update iteration (the engine always calls
    modifyItem first). The override replaces the Food slot item with pet food.
    It never shares a body with scrolls: scroll-only mode replaces the whole
    body, pet line included, until the scrolls are applied.
]]
local petBuffOverride = false

--[[
    When the player has missing scroll buffs and is not targeting a friendly
    player, the Food macro becomes a dedicated scroll-fire macro. The body
    is just `#showtooltip` plus one /use [@player] item:NNN line per scroll
    in ns.SCROLL_CHECK_ORDER priority. No food, no conjure, no state-write —
    the user taps once to apply scrolls; the next tap (with all scrolls
    applied) sees the macro flip back to its normal food form. WoW Forever is
    the exception: scrolls trigger the global cooldown there, so one press
    lands one scroll, and the body holds only the first missing scroll until
    it lands.

    Bare `#showtooltip` lets the action bar resolve the icon from the first
    usable line — the first scroll — which is exactly what the user should
    see when the button is about to fire scrolls.

    All scrolls fit comfortably under the 255 macro ceiling: 14 bytes for
    the tooltip line + at most 6 scrolls × ~25 bytes ≈ 164 bytes. The lines are
    pure ASCII (no localized names), so the count cannot grow in another locale.

    A Troll with Rapid Regeneration on (only on WoW Forever, where the body
    holds one scroll) gets the combat cast ahead of the scroll, like the
    eating body; the spell name is the one localized line, and one scroll
    leaves it well over 150 bytes of room. combatCast is that name or nil.
]]
local function BuildScrollOnlyBody(scrollList, combatCast)
	local lines = { "#showtooltip" }
	if combatCast then
		lines[1] = "#showtooltip [combat] " .. combatCast .. "; item:" .. scrollList[1]
		lines[#lines + 1] = "/cast [combat] " .. combatCast
		lines[#lines + 1] = "/stopmacro [combat]"
	end
	local count = (ns.FLAVOR == "Camelot") and 1 or #scrollList
	for index = 1, count do
		lines[#lines + 1] = "/use [@player] item:" .. scrollList[index]
	end
	return table.concat(lines, "\n") .. "\n"
end

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
	    hybrid (which also feeds Water), by raw food value. Buff food only
	    competes while the scanner's live ns.allowBuffFood preference is on
	    (setting + When to Use + not Well Fed + not self-targeting + not arena),
	    and the allowBuffFood flag additionally makes the ladder prefer buff
	    food outright when it is. While Use Conjured Food & Water First holds
	    (ns.allowConjuredFirst), conjured food comes next, ahead of anything
	    that restores more. While Use Restock List Food & Water Last holds
	    (ns.allowRestockLast), food off the Restock List beats an equal one
	    on it. Hybrids beat dedicated food on ties — one bag
	    slot covering both needs. The winner record carries the item link,
	    which the scanner publishes as ns.bestFoodLink for the mini-map
	    tooltip.
	]]
	itemTypes = { food = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and not ns.allowBuffFood)
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
	    Scroll mode. The "SCROLLS:" state-key prefix can never collide with
	    the standard ITEMID-prefixed key, which guarantees a rewrite happens
	    at every transition into and out of scroll mode (target-change,
	    scroll-applied, bag scan removing the last scroll item, etc).
	]]
	buildModeOverride = function(context)
		local scrollIDs = context.activeScrollIDs
		if not scrollIDs or #scrollIDs == 0 then
			return nil
		end
		local combatCast = ns.RapidRegenerationCombatCast()
		return BuildScrollOnlyBody(scrollIDs, combatCast),
			"SCROLLS:" .. table.concat(scrollIDs, ",") .. (combatCast and ":RC" or "")
	end,

	--[[
	    Stealth Eating: appends a stealth cast below the food line -- Stealth
	    for Rogues, Shadowmeld for other Night Elves -- so the player stealths
	    while eating. The "SE" flag keeps the append in the state key so
	    toggling the option rewrites the macro. Only a body the player eats
	    from carries it: with no food the press would stealth for nothing, and
	    the pet-buff override feeds the pet rather than the player. Scroll-only
	    mode bypasses this too (mode overrides never reach appendBlock), which
	    is correct: a scroll tap is not a meal.
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
	    Troll Rapid Regeneration: while it is off cooldown the body casts it
	    instead of eating (Tools-Troll.lua). Asked under the same rule as
	    corpseSpell, so the pet-buff override never carries it.
	]]
	leadSpell = function(entry)
		return ns.RapidRegenerationCast(entry)
	end,

	--[[
	    And on a press in combat, where nobody eats, the eating body casts it
	    instead, cooldown or not (Tools-Troll.lua).
	]]
	combatSpell = function()
		return ns.RapidRegenerationCombatCast()
	end,
})
