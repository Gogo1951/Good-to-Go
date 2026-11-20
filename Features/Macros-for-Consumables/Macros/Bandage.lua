local _, ns = ...

--------------------------------------------------------------------------------
-- Bandage Macro
--------------------------------------------------------------------------------

-- Standard single-item macro; its one hook is the Troll's Rapid Regeneration.
ns.RegisterMacroType({
	typeName = "Bandage",

	--[[
	    Selection: best bandage by raw heal; the BG-only bandages win ties
	    through the ladder's hasZones step.
	]]
	itemTypes = { bandage = true },
	score = function(data)
		return data.healthValue
	end,

	--[[
	    Troll Rapid Regeneration: out of combat, while it is off cooldown, a
	    press casts it instead of bandaging (Tools-Troll.lua). In combat the
	    macro always bandages.
	]]
	leadSpell = function()
		return ns.RapidRegenerationBandageCast()
	end,
})
