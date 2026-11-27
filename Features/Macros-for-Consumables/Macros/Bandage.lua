local _, ns = ...

--------------------------------------------------------------------------------
-- Bandage Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Bandage",

	-- BG-only bandages win ties through the ladder's hasZones step.
	itemTypes = { bandage = true },
	score = function(data)
		return data.healthValue
	end,

	leadSpell = function()
		return ns.RapidRegenerationBandageCast()
	end,
})
