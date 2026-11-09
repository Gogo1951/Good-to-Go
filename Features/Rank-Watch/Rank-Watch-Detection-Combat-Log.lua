local _, ns = ...

--------------------------------------------------------------------------------
-- Rank Watch Detection: Combat Log
--------------------------------------------------------------------------------

--[[
    Casts from the combat log, listed by every TOC but WoW Forever's, which keeps the combat log from add-ons
    (Rank-Watch-Detection-Forever.lua reads casts there). The log names the caster and the recipient of every
    cast in the group, pets' casts included: a hunter pet's or demon's goes to its owner. Every cast ends in
    ns.CheckRankWatchCast, with the recipient's level when it landed on another friendly player, none when it
    landed on the caster, an enemy or nobody, and dropped when that friendly player's level can't be read.
]]

local Check = ns.CheckRankWatchCast

local band = bit.band
local GROUP_AFFILIATION = 0x00000007 -- COMBATLOG_OBJECT_AFFILIATION_MINE, _PARTY and _RAID
local FRIENDLY_REACTION = 0x00000010 -- COMBATLOG_OBJECT_REACTION_FRIENDLY

--[[
    A pet in the group and its owner, by the pet's GUID: the player's own "pet", then partypetN with partyN or
    raidpetN with raidN. A pet whose owner isn't in the group (a stranger's, a charmed mob) finds nothing.
]]
local function PetAndOwner(petGUID)
	local guid = UnitGUID("pet")
	if ns.IsPlain(guid) and guid == petGUID then
		return "pet", "player"
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		local petUnit = prefix .. "pet" .. i
		guid = UnitGUID(petUnit)
		if ns.IsPlain(guid) and guid == petGUID then
			return petUnit, prefix .. i
		end
	end
	return nil
end

-- The friendly player a cast landed on, when that was someone other than the caster: their level, or false
-- when it can't be read (the cast is dropped), or nil for no such recipient.
local function RecipientLevel(destGUID, destFlags, ...)
	if not destGUID or destGUID == "" or band(destFlags or 0, FRIENDLY_REACTION) == 0 then
		return nil
	end
	for i = 1, select("#", ...) do
		if destGUID == select(i, ...) then
			return nil
		end
	end
	return ns.RankWatchUnitLevel(ns.GetUnitByGUID(destGUID)) or false
end

ns.SetRankWatchHandler("COMBAT_LOG_EVENT_UNFILTERED", function()
	local _, subevent, _, sourceGUID, _, sourceFlags, _, destGUID, _, destFlags, _, spellID =
		CombatLogGetCurrentEventInfo()
	if subevent ~= "SPELL_CAST_SUCCESS" or band(sourceFlags or 0, GROUP_AFFILIATION) == 0 then
		return
	end
	local lookup = ns.RankWatchReportableLookup(spellID)
	if not lookup then
		return
	end

	-- A pet's cast goes to its owner.
	if lookup.ladder.isPet then
		local petUnit, ownerUnit = PetAndOwner(sourceGUID)
		local ownerGUID = ownerUnit and UnitGUID(ownerUnit)
		if not ns.IsPlain(ownerGUID) or not ownerGUID then
			return
		end
		local recipientLevel = RecipientLevel(destGUID, destFlags, sourceGUID, ownerGUID)
		if recipientLevel == false then
			return
		end
		Check({
			guid = ownerGUID,
			unit = ownerUnit,
			spellID = spellID,
			recipientLevel = recipientLevel,
			petUnit = petUnit,
			petGUID = sourceGUID,
		})
		return
	end

	if not ns.IsPlayerGUID(sourceGUID) then
		return
	end
	local unit = ns.GetUnitByGUID(sourceGUID)
	if not unit then
		return
	end
	local recipientLevel = RecipientLevel(destGUID, destFlags, sourceGUID)
	if recipientLevel == false then
		return
	end
	Check({ guid = sourceGUID, unit = unit, spellID = spellID, recipientLevel = recipientLevel })
end)

function ns.SyncRankWatchDetection(active)
	ns.SetRankWatchEvent("COMBAT_LOG_EVENT_UNFILTERED", active)
end
