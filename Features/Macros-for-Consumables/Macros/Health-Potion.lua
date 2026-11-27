local _, ns = ...

--------------------------------------------------------------------------------
-- Health Potion Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Health Potion",

	itemTypes = { potion = true },
	accepts = function(data)
		return data.healthValue > 0
	end,
	score = function(data)
		return data.healthValue
	end,
	ranked = true,

	outOfCombatTypeName = "Food",

	--[[
	    Potions and healthstones have separate cooldowns, so one press fires one
	    of each. The Healthstone topIDs are scanned whether or not its own macro
	    is on.
	]]
	stackTypeName = "Healthstone",
	getStackIDs = function(best)
		local settings = ns.db and ns.db.profile
		if not (settings and settings.combineHealthstones) then
			return nil
		end
		local healthstoneEntry = best["Healthstone"]
		if healthstoneEntry and healthstoneEntry.topIDs and #healthstoneEntry.topIDs > 0 then
			return healthstoneEntry.topIDs
		end
		return nil
	end,
})
