local _, ns = ...
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH

--------------------------------------------------------------------------------
-- Rank Watch Detection: WoW Forever
--------------------------------------------------------------------------------

--[[
    WoW Forever keeps the combat log from add-ons and hides other players' cast spell IDs, so casts come from
    the player's own SENT/SUCCEEDED pair, the pet's SUCCEEDED, the group's UNIT_AURA (whose aura IDs and
    casters stay readable), and the damage meter. A friendly recipient whose level can't be read drops the
    cast, since a rank the game lowered for a lowbie can't be told from one the caster chose.
]]

local Check = ns.CheckRankWatchCast

--------------------------------------------------------------------------------
-- The Player's Own Casts (WoW Forever)
--------------------------------------------------------------------------------

local pending = {} -- castGUID -> { target name, time }

--[[
    UNIT_SPELLCAST_SENT names the recipient but gives neither unit nor GUID,
    so the name is mapped back to a unit, in the order people cast, then the
    group.
]]
local CAST_AT_UNITS = { "player", "pet", "target", "mouseover", "focus" }

local function ResolveCastTargetUnit(name)
	local short = Ambiguate(name, "short")
	local function Matches(unit)
		if not UnitExists(unit) or ns.IsUnitIdentitySecret(unit) then
			return false
		end
		local unitName = GetUnitName(unit, true)
		return unitName ~= nil and (unitName == name or Ambiguate(unitName, "short") == short)
	end

	for _, unit in ipairs(CAST_AT_UNITS) do
		if Matches(unit) then
			return unit
		end
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		if Matches(prefix .. i) then
			return prefix .. i
		end
	end
	return nil
end

local function SweepPending()
	local cutoff = GetTime() - RANK_WATCH.PENDING_TTL
	for castGUID, cast in pairs(pending) do
		if cast.at < cutoff then
			pending[castGUID] = nil
		end
	end
end

local function OnUnitSpellcastSent(unit, target, castGUID, spellID)
	if unit ~= "player" or not (ns.IsPlain(target) and ns.IsPlain(castGUID) and ns.IsPlain(spellID)) then
		return
	end
	if not castGUID or not ns.RankWatchReportableLookup(spellID) then
		return
	end
	SweepPending()
	pending[castGUID] = { target = target, at = GetTime() }
end
ns.SetRankWatchHandler("UNIT_SPELLCAST_SENT", OnUnitSpellcastSent)

local CheckPetCast -- below, with the group-level helper it caps helpful casts by

--[[
    No name, or the player's own, is a cast on themself; an enemy caps nothing; a friendly player caps the rank
    by their level; anyone the name can't be found for drops the cast.
]]
local function OnUnitSpellcastSucceeded(unit, castGUID, spellID)
	if unit == "pet" then
		CheckPetCast(spellID)
		return
	end
	if unit ~= "player" or not (ns.IsPlain(castGUID) and ns.IsPlain(spellID)) or not castGUID then
		return
	end
	local cast = pending[castGUID]
	pending[castGUID] = nil
	if not cast or not ns.RankWatchReportableLookup(spellID) then
		return
	end
	local recipientLevel
	local castAt = cast.target and cast.target ~= "" and Ambiguate(cast.target, "short")
	if castAt and castAt ~= UnitName("player") and castAt ~= ns.GetPlayerFullName() then
		local recipient = ResolveCastTargetUnit(cast.target)
		if not recipient then
			return
		end
		if
			not ns.IsPlainTrue(UnitIsUnit(recipient, "player"))
			and not ns.IsPlainTrue(UnitCanAttack("player", recipient))
		then
			recipientLevel = ns.RankWatchUnitLevel(recipient)
			if not recipientLevel then
				return
			end
		end
	end
	Check({ guid = UnitGUID("player"), unit = "player", spellID = spellID, recipientLevel = recipientLevel })
end
ns.SetRankWatchHandler("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)

--------------------------------------------------------------------------------
-- Other Players' Buffs (WoW Forever)
--------------------------------------------------------------------------------

local function IsGroupUnit(unit)
	return unit == "player" or unit:find("^party%d$") ~= nil or unit:find("^raid%d+$") ~= nil
end

local function CheckAura(bearer, aura)
	if type(aura) ~= "table" then
		return
	end
	local spellID, source = aura.spellId, aura.sourceUnit
	if not (ns.IsPlain(spellID) and ns.IsPlain(source)) or type(source) ~= "string" then
		return
	end
	if not ns.RankWatchReportableLookup(spellID) then
		return
	end
	-- The player's own casts come through the handshake above, where the recipient is known by name.
	local casterGUID = UnitGUID(source)
	if not ns.IsPlain(casterGUID) or not ns.IsPlayerGUID(casterGUID) or casterGUID == UnitGUID("player") then
		return
	end
	local caster = ns.GetUnitByGUID(casterGUID)
	if not caster or caster == "target" or caster == "focus" or caster == "mouseover" then
		return
	end
	local bearerGUID = UnitGUID(bearer)
	if not ns.IsPlain(bearerGUID) then
		return
	end
	local recipientLevel
	if bearerGUID ~= casterGUID then
		recipientLevel = ns.RankWatchUnitLevel(bearer)
		if not recipientLevel then
			return
		end
	end
	Check({ guid = casterGUID, unit = caster, spellID = spellID, recipientLevel = recipientLevel })
end

local function OnUnitAura(unit, updateInfo)
	if not ns.IsPlain(unit) or type(unit) ~= "string" or not IsGroupUnit(unit) then
		return
	end
	if ns.AreAurasSecret() or not ns.IsPlain(updateInfo) or type(updateInfo) ~= "table" then
		return
	end
	local added = updateInfo.addedAuras
	if not ns.IsPlain(added) or type(added) ~= "table" then
		return
	end
	for _, aura in ipairs(added) do
		CheckAura(unit, aura)
	end
end
ns.SetRankWatchHandler("UNIT_AURA", OnUnitAura)

--------------------------------------------------------------------------------
-- Other Players' Damage and Healing (WoW Forever)
--------------------------------------------------------------------------------

--[[
    The meter lists each member's spells with readable IDs and running totals, read only out of combat. A spell
    counts as cast only when its total moved since the last read; the first read after joining a group, or
    turning on, only takes the totals, so what was cast before isn't mistaken for new.

    A heal's recipient isn't in the meter, so a heal is capped by the lowest level in the group: a heal over
    time is an aura the game lowers for a lowbie like any buff. Damage lands on enemies and caps nothing.
]]
local meterTotals = {}
local needsBaseline = true
local ticker

--[[
    A buff that hits back (Thorns, Retribution Aura, the Imp's Fire Shield) books its damage to whoever wears
    it, under the buff's own spell ID, so the meter would blame the wearer. The real caster is caught by
    UNIT_AURA above. Keyed by each ladder's first rank.
]]
local WORN_DAMAGE = {
	[467] = true, -- Thorns
	[7294] = true, -- Retribution Aura
	[2947] = true, -- Fire Shield
}

local function LowestGroupLevel()
	local lowest = ns.RankWatchUnitLevel("player")
	local prefix, count = "party", GetNumSubgroupMembers()
	if IsInRaid() then
		prefix, count = "raid", GetNumGroupMembers()
	end
	for i = 1, count do
		local level = ns.RankWatchUnitLevel(prefix .. i)
		if level and (not lowest or level < lowest) then
			lowest = level
		end
	end
	return lowest
end

--[[
    No SENT names a pet's recipient. A helpful one (Fire Shield, Blood Pact) may land on a lower-level friend,
    whose rank the game lowers, so it is capped by the lowest level in the group, as the meter's heals are.
]]
local IsSpellHelpful = C_Spell and C_Spell.IsSpellHelpful

CheckPetCast = function(spellID)
	if not ns.IsPlain(spellID) or not spellID then
		return
	end
	local lookup = ns.RankWatchReportableLookup(spellID)
	if not lookup or not lookup.ladder.isPet then
		return
	end
	local petGUID = UnitGUID("pet")
	if not ns.IsPlain(petGUID) or not petGUID then
		return
	end
	local recipientLevel
	if IsInGroup() and IsSpellHelpful and IsSpellHelpful(spellID) then
		recipientLevel = LowestGroupLevel()
		if not recipientLevel then
			return
		end
	end
	Check({
		guid = UnitGUID("player"),
		unit = "player",
		spellID = spellID,
		recipientLevel = recipientLevel,
		petUnit = "pet",
		petGUID = petGUID,
	})
end

--[[
    The meter folds a pet's spells into its owner's list. Nil when the pet is gone by the time the meter is
    read, or its GUID can't be read, and the cast is dropped.
]]
local function PetOf(ownerUnit)
	local petUnit = ownerUnit:gsub("^party(%d)$", "partypet%1"):gsub("^raid(%d+)$", "raidpet%1")
	if petUnit == ownerUnit or not UnitExists(petUnit) then
		return nil
	end
	local petGUID = UnitGUID(petUnit)
	if not ns.IsPlain(petGUID) or not petGUID then
		return nil
	end
	return petUnit, petGUID
end

local function ReadMeterType(meterType, baseline, recipientLevel)
	local sessionType = Enum.DamageMeterSessionType.Current
	local ok, combatSession = pcall(C_DamageMeter.GetCombatSessionFromType, sessionType, meterType)
	local sources = ok and ns.IsPlain(combatSession) and type(combatSession) == "table" and combatSession.combatSources
	if not ns.IsPlain(sources) or type(sources) ~= "table" then
		return
	end
	for _, source in ipairs(sources) do
		local guid = ns.IsPlain(source) and type(source) == "table" and source.sourceGUID
		local unit = ns.IsPlain(guid)
			and ns.IsPlayerGUID(guid)
			and guid ~= UnitGUID("player")
			and ns.GetUnitByGUID(guid)
		if unit then
			local found, detail = pcall(C_DamageMeter.GetCombatSessionSourceFromType, sessionType, meterType, guid)
			local spells = found and ns.IsPlain(detail) and type(detail) == "table" and detail.combatSpells
			if ns.IsPlain(spells) and type(spells) == "table" then
				for _, spell in ipairs(spells) do
					local spellID = ns.IsPlain(spell) and type(spell) == "table" and spell.spellID
					local total = ns.IsPlain(spellID) and spellID and spell.totalAmount
					local lookup = ns.IsPlain(total) and total and ns.RankWatchReportableLookup(spellID)
					if lookup and not WORN_DAMAGE[lookup.ladder.id] then
						local key = guid .. "-" .. spellID
						local moved = meterTotals[key] ~= total
						meterTotals[key] = total
						if moved and not baseline then
							local cast =
								{ guid = guid, unit = unit, spellID = spellID, recipientLevel = recipientLevel }
							if lookup.ladder.isPet then
								cast.petUnit, cast.petGUID = PetOf(unit)
							end
							if cast.petUnit or not lookup.ladder.isPet then
								Check(cast)
							end
						end
					end
				end
			end
		end
	end
end

local function PollMeter()
	if not (C_DamageMeter and Enum.DamageMeterSessionType and Enum.DamageMeterType) or not ns.IsRankWatchActive() then
		return
	end
	-- Mid-fight reads report nothing; the PLAYER_REGEN_ENABLED read below takes the finished fight.
	if InCombatLockdown() then
		return
	end
	if not IsInGroup() then
		-- Out of a group, the last group's totals mean nothing: the next group starts from a fresh baseline.
		wipe(meterTotals)
		needsBaseline = true
		return
	end
	local baseline = needsBaseline
	needsBaseline = false
	ReadMeterType(Enum.DamageMeterType.DamageDone, baseline, nil)
	local lowest = LowestGroupLevel()
	if lowest then
		ReadMeterType(Enum.DamageMeterType.HealingDone, baseline, lowest)
	end
end

local function SyncMeter(active)
	if ticker then
		ticker:Cancel()
		ticker = nil
	end
	wipe(meterTotals)
	needsBaseline = true
	if active and C_DamageMeter then
		ticker = C_Timer.NewTicker(RANK_WATCH.METER_POLL, PollMeter)
		PollMeter()
	end
end

--[[
    Trap: this replaces Rank-Watch-Check.lua's handler for the event (it loads after), so it must send the
    held whispers too. Reads the meter once more before its session moves on.
]]
local function OnPlayerRegenEnabled()
	PollMeter()
	C_Timer.After(RANK_WATCH.AFTER_COMBAT, ns.ProcessRankWatchQueue)
end
ns.SetRankWatchHandler("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)

--------------------------------------------------------------------------------
-- Subscriptions
--------------------------------------------------------------------------------

function ns.SyncRankWatchDetection(active)
	ns.SetRankWatchEvent("UNIT_AURA", active)
	ns.SetRankWatchEvent("UNIT_SPELLCAST_SENT", active, "player")
	ns.SetRankWatchEvent("UNIT_SPELLCAST_SUCCEEDED", active, "player", "pet")
	SyncMeter(active)
end
