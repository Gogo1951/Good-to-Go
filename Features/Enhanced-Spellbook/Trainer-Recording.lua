local _, ns = ...

--[[
	Records the spells class trainers offer, per character, so the page can list unlearned spells that the
	bundled data (Data/) misses. Trainer lists live on the server, so a trainer window is the only place the
	game shows them.
]]

local NO_SPELLS = {}

local petAbilityIds

--[[
	Whether a spell is one of the pet's or a demon's abilities in this client's data (ns.PET_ABILITIES,
	ns.DEMON_ABILITIES), never a class spell of the player's. WoW Forever's demon trainer teaches the demon's
	ranks with no grimoire between, so a trainer window can list them.
]]
function ns.IsPetAbilitySpell(id)
	if not petAbilityIds then
		petAbilityIds = {}
		for _, list in ipairs({ ns.PET_ABILITIES or NO_SPELLS, ns.DEMON_ABILITIES or NO_SPELLS }) do
			for _, row in ipairs(list) do
				petAbilityIds[row.id] = true
			end
		end
	end
	return petAbilityIds[id] == true
end

--[[
	The character profile's trainerSpells for this character's class: spell id -> required level, for each
	spell a trainer offered (every rank: Features/Enhanced-Spellbook/Unlearned-Spells.lua keeps rank 1). Kept by class
	token, so a profile copied from another class's character never lists that class's spells. Don't modify
	it unless create is set, which makes the class's table if there is none. The pet's abilities
	(ns.PET_ABILITIES) never belong in it: RecordServices skips them.
]]
local function Recorded(create)
	local byClass, class = ns.db.profile.trainerSpells, select(2, UnitClass("player"))
	if create and not byClass[class] then
		byClass[class] = {}
	end
	return byClass[class] or NO_SPELLS
end

ns.RecordedTrainerSpellLevels = Recorded

-- The recorded trainer spells as Data/ style entries ({level, id}), lowest level first.
function ns.RecordedTrainerSpells()
	local spells = {}
	for id, level in pairs(Recorded()) do
		spells[#spells + 1] = { level = level, id = id }
	end
	table.sort(spells, function(a, b)
		if a.level ~= b.level then
			return a.level < b.level
		end
		return a.id < b.id
	end)
	return spells
end

local function IsClassTrainer()
	if IsTradeskillTrainer and IsTradeskillTrainer() then
		return false
	end
	if C_Trainer and C_Trainer.GetTrainerType and Enum.TrainerType then
		local trainerType = C_Trainer.GetTrainerType()
		if Enum.TrainerType.Class then
			return trainerType == Enum.TrainerType.Class
		end
		return trainerType ~= Enum.TrainerType.Pet
	end
	return true
end

--[[
	Records the services the trainer window lists (with its current filters: by default the available and
	unavailable ones, which are the unlearned spells). A Hunter trainer also lists the pet abilities it
	teaches (Growl and the like), which belong to the pet, so those are skipped: by the client's flag where it
	gives one, and by the pet data (ns.IsPetAbilitySpell) where it doesn't (WoW Forever).
]]
local function IsPetService(index)
	if not IsTrainerServiceLearnSpell then
		return false
	end
	local _, isPetLearnSpell = IsTrainerServiceLearnSpell(index)
	return isPetLearnSpell and true or false
end

local function RecordServices()
	if not ns.db or not IsClassTrainer() then
		return
	end
	local spells = Recorded(true)
	for index = 1, GetNumTrainerServices() or 0 do
		local id = not IsPetService(index) and ns.GetTrainerServiceSpellId(index)
		if id and not ns.IsPetAbilitySpell(id) then
			spells[id] = GetTrainerServiceLevelReq(index) or spells[id] or 0
		end
	end
	ns.InvalidateSpellRankRows()
end

-- TRAINER_UPDATE also fires when the window's filters change.
function ns:OnTrainerShow()
	RecordServices()
end

function ns:OnTrainerUpdate()
	RecordServices()
end
