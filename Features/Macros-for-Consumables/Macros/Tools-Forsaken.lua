local _, ns = ...

--------------------------------------------------------------------------------
-- Cannibalize (Forsaken)
--------------------------------------------------------------------------------

--[[
    A macro can't test creature type or cooldown, so those are decided at
    write time; only the death is left to [dead]. The target signature, the
    cast and ns.RacialSpellReady's timer keep the body current.
]]

--------------------------------------------------------------------------------
-- Target
--------------------------------------------------------------------------------

local CANNIBALIZE_CREATURE_TYPES = {}
for _, creatureTypeID in ipairs(ns.CANNIBALIZE_CREATURE_TYPE_IDS) do
	CANNIBALIZE_CREATURE_TYPES[creatureTypeID] = true
end

-- Nil while Forever hides the target's identity, which the target signature reads as unchanged.
function ns.TargetIsCannibalizable()
	if not UnitExists("target") then
		return false
	end
	if ns.IsUnitIdentitySecret("target") then
		return nil
	end
	local _, creatureTypeID = UnitCreatureType("target")
	return CANNIBALIZE_CREATURE_TYPES[creatureTypeID] == true
end

function ns.CannibalizeSwitchedOn()
	local settings = ns.db and ns.db.profile
	if not (ns.isForsaken and settings) then
		return false
	end
	return settings.enableCannibalizeEating
		or (settings.enableCannibalizeDrinking and ns.CANNIBALIZE_RESTORES_MANA)
		or false
end

--------------------------------------------------------------------------------
-- Cast
--------------------------------------------------------------------------------

--[[
    A buff food pick keeps the usual body: only eating it gives Well Fed. The
    cooldown is read last, so its timer is only set for a body that would
    carry the cast.
]]
function ns.CannibalizeCast(settingKey, entry)
	if not ns.isForsaken or not ns.cannibalizeSpellName then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings[settingKey] then
		return nil
	end
	if entry and entry.id and entry.isBuffFood then
		return nil
	end
	if not ns.TargetIsCannibalizable() then
		return nil
	end
	if not ns.RacialSpellReady(ns.CANNIBALIZE_SPELL_ID) then
		return nil
	end
	return ns.cannibalizeSpellName
end
