local _, ns = ...

--------------------------------------------------------------------------------
-- Explosive Macro
--------------------------------------------------------------------------------

-- Keybind presses register as left-click, so "atplayer" also drops keybound charges at the player's feet.
local function GetExplosiveClickMode()
	local settings = ns.db and ns.db.profile
	if settings and settings.explosivesClickMode == "toss" then
		return "toss"
	end
	return "atplayer"
end

local function BuildExplosiveUseLine(itemID)
	if GetExplosiveClickMode() == "toss" then
		return "/use [btn:2,@player] item:" .. itemID .. "; item:" .. itemID
	end
	return "/use [btn:2] item:" .. itemID .. "; [@player] item:" .. itemID
end

ns.RegisterMacroType({
	typeName = "Explosive",

	itemTypes = { explosive = true },
	score = function(data)
		return data.damageValue
	end,

	buildUseLine = BuildExplosiveUseLine,

	-- The click layout shapes the body, so it must be in the state key or a dropdown flip won't rewrite it.
	stateExtras = function(parts, itemID)
		if itemID then
			parts[#parts + 1] = "EX:" .. GetExplosiveClickMode()
		end
	end,
})
