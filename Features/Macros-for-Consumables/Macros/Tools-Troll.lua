local _, ns = ...

--------------------------------------------------------------------------------
-- Rapid Regeneration (Troll)
--------------------------------------------------------------------------------

--[[
    Rapid Regeneration is the Troll racial on WoW Forever; no other client
    has it, and ns.RAPID_REGENERATION_SPELL_ID is nil there. A macro cannot
    test a cooldown, so the add-on decides it at write time:

      Rapid Regeneration off cooldown
          #showtooltip Rapid Regeneration
          <conjure clicks>
          /cast Rapid Regeneration    and nothing below it: no eating
      on cooldown
          the usual body

    So every press while the spell is ready casts it instead of eating, and
    once it is on cooldown the macro eats as usual. Scrolls come first
    (scroll-only mode replaces the body), and so does buff food: a buff food
    pick keeps the usual body, since only eating it gives Well Fed.

    What keeps the body current: the cast itself rebuilds through
    UNIT_SPELLCAST_SUCCEEDED (Macros-for-Consumables-Core.lua), and the end of
    the cooldown rebuilds through ns.RacialSpellReady's timer
    (Tools-Forsaken.lua).
]]

--[[
    The Rapid Regeneration name the Food body casts in place of eating, or
    nil while it should eat. entry is the scanned Food pick, or nil when the
    bags hold none, in which case the body still casts it.

    The cooldown is read last, so its rebuild timer is only set for a body
    that would carry the cast.
]]
function ns.RapidRegenerationCast(entry)
	if not ns.isTroll or not ns.rapidRegenerationSpellName then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings.enableRapidRegenerationEating then
		return nil
	end
	if entry and entry.id and entry.isBuffFood then
		return nil
	end
	if not ns.RacialSpellReady(ns.RAPID_REGENERATION_SPELL_ID) then
		return nil
	end
	return ns.rapidRegenerationSpellName
end
