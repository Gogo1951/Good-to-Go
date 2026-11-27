local _, ns = ...

-- The pet's commands (Attack, Follow, Stay, the stances) are left out: they're the pet bar's, not spells.

ns.PET_SPELLBOOK_STATUSES = { "ABILITY", "PASSIVE" }

-- A mage's is the Water Elemental, which came with The Burning Crusade.
local PET_CLASSES = { HUNTER = true, WARLOCK = true, DEATHKNIGHT = true, MAGE = ns.EXPANSION >= 2 }

function ns.HasPetSpellbook()
	return PET_CLASSES[select(2, UnitClass("player"))] == true
end

-- { id, name, subtext, icon, status, slot, autocastAllowed, autocastOn } rows, unsorted, and the pet for the footer.
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

function ns.PickupPetSpell(slot)
	ns.PickupPetSpellBookItem(slot)
end
