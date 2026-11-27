local _, ns = ...

--------------------------------------------------------------------------------
-- Rapid Regeneration (Troll)
--------------------------------------------------------------------------------

--[[
    A macro can't test a cooldown, so the Bandage line is decided at write
    time; the cast and ns.RacialSpellReady's timer keep it current. The Food
    combat line ignores the cooldown: a body can't change once combat starts.
]]

local function RapidRegenerationFor(settingKey)
	if not ns.isTroll or not ns.rapidRegenerationSpellName then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings[settingKey] then
		return nil
	end
	return ns.rapidRegenerationSpellName
end

-- The cooldown is read last, so its rebuild timer is only set for a body that would carry the cast.
function ns.RapidRegenerationBandageCast()
	local spellName = RapidRegenerationFor("enableRapidRegenerationBandage")
	if not spellName or not ns.RacialSpellReady(ns.RAPID_REGENERATION_SPELL_ID) then
		return nil
	end
	return spellName
end

function ns.RapidRegenerationCombatCast()
	return RapidRegenerationFor("enableRapidRegenerationEating")
end
