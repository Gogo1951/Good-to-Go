local _, ns = ...

--[[
	WoW Forever has no Beast Training spell and no grimoires: the hunter's trainer teaches the pet out by the
	hunter's level, a taming rank comes only with a newly tamed beast (so it reads by the hunter's level too), and
	the demon trainer teaches a demon's rank itself. With no demon out, nothing reads as known, since only the
	demon out says what it knows.
]]

local NO_IDS = {}

-- Within this many levels, an ability is Coming Soon rather than Not Yet Available, as on the class tab.
local SOON_LEVELS = 2

--[[
	In Sort By Availability's order. TEACH: the pet can be taught it now; AVAILABLE: one to go and get now;
	OTHER: one the pet's family can't learn.
]]
ns.WHATS_NEXT_PET_STATUSES = { "TEACH", "AVAILABLE", "SOON", "LATER", "OTHER", "KNOWN" }

-- HUNTER_TRAINER is WoW Forever's.
ns.WHATS_NEXT_PET_SOURCES = { "TRAINER", "HUNTER_TRAINER", "TAMING", "DEMON_TRAINER" }

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

function ns.WhatsNextPetShowsKnown()
	return ns.db.profile.whatsNextPetShowKnown
end

function ns.SetWhatsNextPetShowKnown(on)
	ns.db.profile.whatsNextPetShowKnown = on
end

function ns.WhatsNextPetShowsOtherFamilies()
	return ns.db.profile.whatsNextPetShowOtherFamilies
end

function ns.SetWhatsNextPetShowOtherFamilies(on)
	ns.db.profile.whatsNextPetShowOtherFamilies = on
end

--------------------------------------------------------------------------------
-- The Pet
--------------------------------------------------------------------------------

local function ClassAbilities()
	local class = select(2, UnitClass("player"))
	if class == "HUNTER" then
		return ns.PET_ABILITIES or NO_IDS
	elseif class == "WARLOCK" then
		return ns.DEMON_ABILITIES or NO_IDS
	end
	return NO_IDS
end

function ns.HasWhatsNextPet()
	return #ClassAbilities() > 0
end

function ns.IsWhatsNextPetWarlock()
	return select(2, UnitClass("player")) == "WARLOCK"
end

-- WoW Forever's data has no teach spells, so there only the pet out says what it knows.
function ns.WhatsNextPetUsesBeastTraining()
	if ns.IsWhatsNextPetWarlock() then
		return false
	end
	for _, row in ipairs(ClassAbilities()) do
		if row.teach then
			return true
		end
	end
	return false
end

-- beastTraining is ns.WhatsNextPetUsesBeastTraining(), passed in by a caller checking many rows.
function ns.WhatsNextPetReadsHunterLevel(row, beastTraining)
	if row.source == "HUNTER_TRAINER" then
		return true
	end
	if beastTraining == nil then
		beastTraining = ns.WhatsNextPetUsesBeastTraining()
	end
	return row.source == "TAMING" and not beastTraining
end

function ns.WhatsNextPetHasFamilies()
	for _, row in ipairs(ClassAbilities()) do
		if row.families then
			return true
		end
	end
	return false
end

-- A warlock's demon or a pet under Eyes of the Beast counts only with anyPet.
function ns.WhatsNextPet(anyPet)
	if not UnitExists("pet") or not HasPetUI then
		return nil
	end
	local hasUI, isHunterPet = HasPetUI()
	if not hasUI or not (isHunterPet or anyPet) then
		return nil
	end
	local family, familyID = UnitCreatureFamily("pet")
	return {
		name = UnitName("pet"),
		level = UnitLevel("pet"),
		family = family,
		familyID = type(familyID) == "number" and familyID or nil,
	}
end

-- left, total; nil where the client has no training points
function ns.WhatsNextPetTrainingPoints()
	if not GetPetTrainingPoints then
		return nil
	end
	local total, spent = GetPetTrainingPoints()
	if not total then
		return nil
	end
	return total - (spent or 0), total
end

local function PetKnows(id)
	return C_SpellBook.IsSpellKnown(id, Enum.SpellBookSpellBank.Pet)
end

local function Learns(row, familyID)
	if not row.families or not familyID then
		return true
	end
	for _, id in ipairs(row.families) do
		if id == familyID then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
	Unsorted { id, name, icon, subtext, level, source, tp, item, beasts, status, ready }. level is for
	PLAYER_LEVEL_UP. A rank whose name isn't loaded yet is skipped: SPELL_DATA_LOAD_RESULT redraws the tab.
]]
function ns.WhatsNextPetRows(level)
	local warlock = ns.IsWhatsNextPetWarlock()
	-- a warlock's demon is its pet, as a hunter's beast is
	local pet = ns.WhatsNextPet(warlock)
	local playerLevel = level or UnitLevel("player")
	local petLevel = pet and pet.level or playerLevel
	local rows = {}
	for _, data in ipairs(ClassAbilities()) do
		local name = ns.SpellName(data.id)
		if name then
			-- a rank the hunter's own trainer teaches the pet (WoW Forever) has nothing to know first
			local ready = false
			if data.item then
				ready = C_Item.GetItemCount(data.item) > 0
			elseif data.teach then
				ready = ns.IsPlayerSpell(data.teach)
			end
			rows[#rows + 1] = {
				id = data.id,
				name = name,
				icon = C_Spell.GetSpellTexture(data.id),
				subtext = ns.SpellSubtext(data.id),
				level = data.level,
				-- a grimoire's demon trainer; the hunter rows say their own
				source = data.source or "DEMON_TRAINER",
				tp = data.tp,
				item = data.item,
				families = data.families,
				beasts = ns.PET_ABILITY_BEASTS[data.id],
				ready = ready,
			}
		end
	end

	-- a pet's spellbook keeps only the highest rank of each ability
	local highestKnown = {}
	if pet then
		for _, row in ipairs(rows) do
			if PetKnows(row.id) then
				highestKnown[row.name] = math.max(highestKnown[row.name] or 0, row.level)
			end
		end
	end

	local beastTraining = ns.WhatsNextPetUsesBeastTraining()
	for _, row in ipairs(rows) do
		local against = ns.WhatsNextPetReadsHunterLevel(row, beastTraining) and playerLevel or petLevel
		local known
		if pet then
			known = row.level <= (highestKnown[row.name] or -1)
		else
			--[[
				a warlock's grimoire is spent on one demon, and a WoW Forever rank goes straight to the pet, so
				nothing reads as known for those
			]]
			known = not warlock and row.ready
		end
		if pet and not Learns(row, pet.familyID) then
			row.status = "OTHER"
		elseif known then
			row.status = "KNOWN"
		elseif row.level <= against then
			row.status = (pet and row.ready) and "TEACH" or "AVAILABLE"
		elseif row.level <= against + SOON_LEVELS then
			row.status = "SOON"
		else
			row.status = "LATER"
		end
	end
	return rows, pet
end
