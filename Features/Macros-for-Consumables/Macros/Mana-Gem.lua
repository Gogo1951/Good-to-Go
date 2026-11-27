local _, ns = ...

--------------------------------------------------------------------------------
-- Mana Gem Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Mana Gem",

	-- Runes share the gems' cooldown, so they compete in one ranked list rather than stacking.
	itemTypes = { managem = true, manarune = true },
	accepts = function(data)
		if data.itemType ~= "manarune" then
			return true
		end
		local settings = ns.db and ns.db.profile
		return settings and settings.includeManaRunes and true or false
	end,
	score = function(data)
		return data.manaValue
	end,
	ranked = true,

	conjure = function()
		return ns.ResolveMageManaGemConjure()
	end,
})
