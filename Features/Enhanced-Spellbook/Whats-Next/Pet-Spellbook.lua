local _, ns = ...

--[[
	The pet's spellbook for the Pet Spell Book tab (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Page.lua): the abilities and
	passives the pet out now knows, read from its spellbook. Its commands (Attack, Follow, Stay, the stances)
	are left out: they're the pet bar's, not spells. Each row can be dragged to an action bar.
]]

-- The statuses the tab files its rows under, in order: the pet's abilities, then its passives.
ns.PET_SPELLBOOK_STATUSES = { "ABILITY", "PASSIVE" }

--[[
	The classes with a pet spellbook, so the tab is worth showing. A mage's is the Water Elemental, which came
	with The Burning Crusade, so Classic Era and Forever mages have none.
]]
local PET_CLASSES = { HUNTER = true, WARLOCK = true, DEATHKNIGHT = true, MAGE = ns.EXPANSION >= 2 }

function ns.HasPetSpellbook()
	return PET_CLASSES[select(2, UnitClass("player"))] == true
end

--[[
	The pet's spells, unsorted, as { id, name, subtext, icon, status, slot, autocastAllowed, autocastOn }, and the
	pet out (ns.WhatsNextPet's) for the footer; none with no pet out.
]]
function ns.PetSpellbookRows()
	local rows = {}
	if not UnitExists("pet") then
		return rows, nil
	end
	local count = ns.GetNumPetSpells() or 0
	for slot = 1, count do
		local info = ns.GetPetSpellBookSlot(slot)
		if info then
			info.slot = slot
			info.status = info.passive and "PASSIVE" or "ABILITY"
			rows[#rows + 1] = info
		end
	end
	return rows, ns.WhatsNextPet(true)
end

-- Puts a row's spell on the cursor, for dropping on an action bar.
function ns.PickupPetSpell(slot)
	ns.PickupPetSpellBookItem(slot)
end
