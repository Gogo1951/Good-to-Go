local _, ns = ...

--------------------------------------------------------------------------------
-- Rapid Regeneration (Troll)
--------------------------------------------------------------------------------

--[[
    Rapid Regeneration is the Troll racial on WoW Forever; no other client
    has it, and ns.RAPID_REGENERATION_SPELL_ID is nil there. It heals in
    combat, where eating can't, so two options put it on two macros:

      Instead of Eating in Combat (enableRapidRegenerationEating)
          The Food macro carries a combat line ahead of its eating:

              /cast [combat] Rapid Regeneration
              /stopmacro [combat]

          A press in combat casts it, or shows the game's cooldown error
          while it is cooling down, and never reaches the food below. Out of
          combat the macro eats as usual. A macro cannot be rewritten in
          combat, so the line ignores the cooldown: the body written before
          the pull is the one the press meets. The pet-food override body
          does not carry it.

      Instead of Bandaging out of Combat (enableRapidRegenerationBandage)
          A macro cannot test a cooldown, so the add-on decides it at write
          time. While Rapid Regeneration is off cooldown, the Bandage macro
          carries an out-of-combat line ahead of its bandage:

              #showtooltip [nocombat] Rapid Regeneration; item:<bandage>
              /cast [nocombat] Rapid Regeneration
              /stopmacro [nocombat]

          so a press out of combat casts it and saves the bandage. On
          cooldown the line is left out and the macro bandages as usual, and
          in combat it always bandages, cooldown or not.

    What keeps the Bandage body current: the cast itself rebuilds through
    UNIT_SPELLCAST_SUCCEEDED (Macros-for-Consumables-Core.lua), and the end of
    the cooldown rebuilds through ns.RacialSpellReady's timer
    (Macros-for-Consumables-Utilities.lua).
]]

-- The Rapid Regeneration name while the character has it and settingKey is on, else nil.
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

--[[
    The Rapid Regeneration name the Bandage body casts out of combat in place
    of bandaging, or nil while it should bandage. The cooldown is read last,
    so its rebuild timer is only set for a body that would carry the cast.
]]
function ns.RapidRegenerationBandageCast()
	local spellName = RapidRegenerationFor("enableRapidRegenerationBandage")
	if not spellName or not ns.RacialSpellReady(ns.RAPID_REGENERATION_SPELL_ID) then
		return nil
	end
	return spellName
end

-- The Rapid Regeneration name the Food body casts on a press in combat, or nil while the option is off.
function ns.RapidRegenerationCombatCast()
	return RapidRegenerationFor("enableRapidRegenerationEating")
end
