local _, ns = ...

--------------------------------------------------------------------------------
-- Mana Potion Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Mana Potion",

	itemTypes = { potion = true },
	accepts = function(data)
		return data.manaValue > 0
	end,
	score = function(data)
		return data.manaValue
	end,
	ranked = true,

	outOfCombatTypeName = "Water",
})
