local _, ns = ...

--------------------------------------------------------------------------------
-- Soulstone Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Soulstone",

	itemTypes = { soulstone = true },
	score = function(data)
		return data.healthValue
	end,

	conjure = function()
		return ns.ResolveWarlockSoulstoneConjure()
	end,
})
