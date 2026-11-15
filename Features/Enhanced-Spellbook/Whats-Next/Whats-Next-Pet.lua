local _, ns = ...

--[[
	The pet abilities for the Pet What's Next? tab (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Page.lua). For a hunter, every
	rank its pets learn (ns.PET_ABILITIES), where the hunter learns it (a pet trainer, or taming a beast that knows
	it), and whether the pet out now knows it, can be taught it with Beast Training, or waits on a level; with no
	pet out, the statuses are the hunter's own Beast Training: what it has learned, and what it can learn by its
	level. On WoW Forever the hunter's own trainer teaches the pet out (HUNTER_TRAINER, with no Beast Training
	spell), so only the pet out says what it knows, and that trainer sells a rank by the hunter's level, not the
	pet's. There a taming rank (TAMING, with no teach) comes only with a newly tamed beast that knows it, so it too
	reads by the hunter's level, the highest beast it can tame. And with no grimoires, its demon trainer teaches a
	demon's rank (DEMON_TRAINER, with no item). For a warlock, every rank its demons learn from a grimoire
	(ns.DEMON_ABILITIES), and whether the demon out knows it, its grimoire is in the bags to use, or it waits on a
	level; with no demon out, nothing reads as known, since only the demon out says what it knows.
]]

local NO_IDS = {}

-- Within this many levels, an ability is Coming Soon rather than Not Yet Available, as on the class tab.
local SOON_LEVELS = 2

--[[
	The statuses in the order Sort By Availability lists them. TEACH is a rank the pet can be taught now (the
	hunter knows it, or the warlock has its grimoire); AVAILABLE one to go and get now; OTHER one the pet's
	family can't learn.
]]
ns.WHATS_NEXT_PET_STATUSES = { "TEACH", "AVAILABLE", "SOON", "LATER", "OTHER", "KNOWN" }

--[[
	The sources the filter offers, in its order. HUNTER_TRAINER is WoW Forever's: the hunter's own class trainer
	teaches the pet out, with no Beast Training spell between.
]]
ns.WHATS_NEXT_PET_SOURCES = { "TRAINER", "HUNTER_TRAINER", "TAMING", "DEMON_TRAINER" }

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

-- Whether the tab also lists the abilities the pet (or, with no pet out, the hunter) already knows.
function ns.WhatsNextPetShowsKnown()
	return ns.db.profile.whatsNextPetShowKnown
end

function ns.SetWhatsNextPetShowKnown(on)
	ns.db.profile.whatsNextPetShowKnown = on
end

-- Whether the tab also lists the abilities the pet's family can't learn.
function ns.WhatsNextPetShowsOtherFamilies()
	return ns.db.profile.whatsNextPetShowOtherFamilies
end

function ns.SetWhatsNextPetShowOtherFamilies(on)
	ns.db.profile.whatsNextPetShowOtherFamilies = on
end

--------------------------------------------------------------------------------
-- The Pet
--------------------------------------------------------------------------------

-- The ability ranks for the player's class: a hunter's pets' or a warlock's demons'; none for another class.
local function ClassAbilities()
	local class = select(2, UnitClass("player"))
	if class == "HUNTER" then
		return ns.PET_ABILITIES or NO_IDS
	elseif class == "WARLOCK" then
		return ns.DEMON_ABILITIES or NO_IDS
	end
	return NO_IDS
end

-- Whether this client's data has abilities for the player's class's pets, so the tab is worth showing.
function ns.HasWhatsNextPet()
	return #ClassAbilities() > 0
end

function ns.IsWhatsNextPetWarlock()
	return select(2, UnitClass("player")) == "WARLOCK"
end

--[[
	Whether a hunter's statuses with no pet out can come from Beast Training: its data has the hunter's teaching
	spells (teach). WoW Forever's has none, so there only the pet out says what it knows.
]]
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

--[[
	Whether a hunter's rank reads against the hunter's level rather than the pet's: WoW Forever's, where the
	hunter's trainer sells a rank by the hunter's level (HUNTER_TRAINER) and, with no Beast Training, a taming rank
	comes only with a newly tamed beast, one no higher than the hunter. beastTraining is
	ns.WhatsNextPetUsesBeastTraining(), passed in by a caller checking many rows.
]]
function ns.WhatsNextPetReadsHunterLevel(row, beastTraining)
	if row.source == "HUNTER_TRAINER" then
		return true
	end
	if beastTraining == nil then
		beastTraining = ns.WhatsNextPetUsesBeastTraining()
	end
	return row.source == "TAMING" and not beastTraining
end

-- Whether any rank in this client's data is limited to some pet families (families), so Other Families has rows.
function ns.WhatsNextPetHasFamilies()
	for _, row in ipairs(ClassAbilities()) do
		if row.families then
			return true
		end
	end
	return false
end

--[[
	The hunter's pet out now, as { name, level, family, familyID }, or nil with none out (a warlock's demon
	or a pet under Eyes of the Beast doesn't count, unless anyPet, as for the Pet Spell Book's footer and a
	warlock's demon). familyID
	is nil where the client doesn't give one.
]]
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

--[[
	The pet's training points: the ones it has left, then its total, or nil where the client has no training
	points.
]]
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
	Every rank, unsorted, as { id, name, icon, subtext, level, source, tp, item, beasts, status, ready }: ready
	is a rank the pet can be taught once its level allows, the hunter's Beast Training spell known or the
	warlock's grimoire in the bags. The statuses read against the pet out's level, or with no pet out against
	level, the level for PLAYER_LEVEL_UP, which defaults to the player's. A rank the hunter gets for the pet
	(ns.WhatsNextPetReadsHunterLevel) always reads against the hunter's level. A rank whose name isn't loaded yet
	is skipped: SPELL_DATA_LOAD_RESULT redraws the tab.
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

	--[[
		A pet's spellbook keeps only the highest rank of each ability, so a rank counts as known to the pet when
		it or a later rank of the same ability is.
	]]
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
				the hunter's Beast Training; a warlock's grimoire is spent on one demon, and a WoW Forever rank goes
				straight to the pet, so nothing reads as known for those
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
