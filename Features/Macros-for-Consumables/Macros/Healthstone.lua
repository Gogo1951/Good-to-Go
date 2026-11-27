local _, ns = ...

--------------------------------------------------------------------------------
-- Healthstone Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Healthstone",

	-- topIDs also feed Health Potion's healthstone stacking.
	itemTypes = { healthstone = true },
	score = function(data)
		return data.healthValue
	end,
	ranked = true,

	conjure = function()
		return ns.ResolveWarlockHealthstoneConjure()
	end,
})
