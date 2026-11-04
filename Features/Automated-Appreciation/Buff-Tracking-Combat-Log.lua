local _, ns = ...
local Data = ns.Data

local GetAuraEntry = ns.GetAuraEntry
local GetCastEntry = ns.GetCastEntry
local HandleStrangersBuff = ns.HandleStrangersBuff
local HandleTracked = ns.HandleTracked
local GetPetOwnerUnit = ns.GetPetOwnerUnit

--[[
    Buff detection on Classic Era and TBC: the combat log's auras landing on
    you, casts and resurrects, credited to whoever cast them. WoW Forever has
    no combat log for an add-on, so its TOC loads Buff-Tracking-Forever.lua in
    this file's place. The rest of the engine is Buff-Tracking.lua's.
]]

--[[
    Credit for a buff goes to a player or to nobody. A pet/guardian source is
    traded for its owner; when that lookup fails -- group pet tokens are missing
    more often than you'd think (a raid pet out of range, a pet the client hasn't
    loaded) -- we return nil so the caller drops the event entirely. Trap: do NOT
    fall back to the pet itself. Its name is not a player's, so the thank-you
    whisper bounces ("No player named 'Woofbark' is currently playing") and the
    print credits an animal; and because a pet inherits its owner's PARTY/RAID
    affiliation, nothing downstream would catch it.
]]
local function ResolveSource(sourceGUID, sourceName)
	if ns.IsPlayerGUID(sourceGUID) then
		return sourceGUID, sourceName
	end
	local ownerUnit = GetPetOwnerUnit(sourceGUID)
	if ownerUnit then
		return UnitGUID(ownerUnit), GetUnitName(ownerUnit, true)
	end
	return nil
end

--[[
    Which tracked entry, if any, this combat-log event proves. The subevent has to
    match the entry's own detect mode, not merely find an id in a lookup: a
    resurrect-detect entry shares the cast lookup with ordinary casts (so the panel,
    the watched list and the seeds all keep working unchanged) but must ignore the
    SPELL_CAST_SUCCESS that an ordinary cast entry lives on, because a cast
    succeeding never proves the revive took. The reverse guard matters too: a
    CAST entry must not be triggered by a stray SPELL_RESURRECT.
]]
local function MatchTracked(spellID, isAura, isCast, isResurrect)
	if isAura then
		return GetAuraEntry(spellID)
	end
	local entry = GetCastEntry(spellID)
	if not entry then
		return nil
	end
	if entry.detect == Data.DETECT.RESURRECT then
		return isResurrect and entry or nil
	end
	return isCast and entry or nil
end

local function OnCombatLogEventUnfiltered()
	if not ns.IsBuffTrackingReady() or not ns.db then
		return
	end
	local playerGUID = ns.GetPlayerGUID()

	local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellID =
		CombatLogGetCurrentEventInfo()

	--[[
	    REFRESH counts as an aura landing: recasting a buff the target already has
	    emits SPELL_AURA_REFRESH, not APPLIED, and a rebuff earns the same thanks.
	]]
	local isAura = (subEvent == "SPELL_AURA_APPLIED") or (subEvent == "SPELL_AURA_REFRESH")
	local isCast = (subEvent == "SPELL_CAST_SUCCESS")
	--[[
	    The only event that proves a revive actually took: goblin jumper cables and
	    Defibrillate report a successful CAST on every attempt, including the ones
	    that leave the target dead.
	]]
	local isResurrect = (subEvent == "SPELL_RESURRECT")
	if not isAura and not isCast and not isResurrect then
		return
	end

	--[[
	    Diagnostics probe: log raw cast-success and resurrect events (portals,
	    summons, feasts, jumper cables), and every aura landing on you, before the
	    guards below drop anything, so even your own test casts and events that get
	    filtered out are still visible in the event log. Untracked casts are counted
	    by spell id in the log's summary rather than logged in full. Resurrects are
	    logged alongside casts specifically so a failed jolt and a working one can
	    be told apart by eye -- a cable that revives nobody logs CAST with no REZ
	    following it. See ns:LogCombatCast.
	]]
	local isAuraOnYou = isAura and destGUID == playerGUID
	if (isCast or isResurrect or isAuraOnYou) and ns.diagnostics and ns.diagnostics.logging then
		local tracked
		if isAura then
			tracked = GetAuraEntry(spellID) ~= nil
		else
			tracked = GetCastEntry(spellID) ~= nil
		end
		ns:LogCombatCast(
			spellID,
			sourceName,
			sourceFlags,
			tracked,
			ns.db.global.watchedBuffs and ns.db.global.watchedBuffs[spellID],
			(isResurrect and "REZ") or (isCast and "CAST") or "AURA"
		)
	end

	--[[
	    Good News for a resurrect-detect cast of YOURS. It has to be claimed above
	    the own-casts return below, which is otherwise the end of the line for
	    anything you did yourself.
	]]
	if isResurrect and sourceGUID == playerGUID then
		ns.ClaimPendingResurrect(destGUID, spellID)
	end

	-- Buff Duty hides a dead player's resurrect icon while anyone's offer waits on them.
	if isResurrect and ns.BuffWindow and ns.BuffWindow.NoteResurrect then
		ns.BuffWindow.NoteResurrect(destGUID)
	end

	--[[
	    Your own casts are Good News's business, and it runs off the cast events
	    instead (Features/Automated-Appreciation/Good-News.lua); everything below reacts to what OTHERS
	    do to you.
	]]
	if not sourceGUID or sourceGUID == playerGUID then
		return
	end

	local entry = MatchTracked(spellID, isAura, isCast, isResurrect)

	--[[
	    Service casts (portals, summons, feasts) are announced from
	    UNIT_SPELLCAST_SUCCEEDED instead -- they don't reliably reach the combat log
	    -- so drop any that surface here, both to avoid a double announce and because
	    the combat log can't be relied on to carry them at all.
	]]
	if entry and entry.type == Data.BUFF.SERVICE then
		entry = nil
	end

	--[[
        A stranger buff is a HELPFUL aura that lands on you from a friendly
        player outside your group. Combat doesn't suppress stranger messages
        (only the emote, which is dropped in combat -- see HandleStrangersBuff),
        but the source/group resolution below is still gated: react only to a
        tracked spell or to a stranger buff on you. Everything else -- including
        group members' untracked buffs in a raid -- bails here so combat log
        processing stays cheap, using the affiliation flag instead of a UnitIn*
        scan to recognize an outsider.

        Ordered cheapest first, so a cast event or an aura landing on anyone but
        you stops at a comparison before the GUID check allocates. Only that GUID
        check proves the source is a player (a pet's doesn't, whatever its flags
        claim); the flags then say whose side they're on and which group.
    ]]
	local maybeStranger = isAura
		and destGUID == playerGUID
		and ns.IsPlayerGUID(sourceGUID)
		and bit.band(sourceFlags or 0, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
		and bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0

	if not entry and not maybeStranger then
		return
	end

	local creditGUID, creditName = ResolveSource(sourceGUID, sourceName)
	if not creditName then
		return
	end

	--[[
        Trap: a name lookup misses cross-realm sources, whose combat-log name is
        "Name-Realm". Classify by affiliation flags instead. MINE/PARTY/RAID cover
        group members and their pets, which inherit the owner's affiliation. MINE
        also covers the player's own pet, so the creditGUID guard stops a self-cast
        (a hunter's Roar of Sacrifice on themselves) from crediting the player.
    ]]
	local sourceIsGroupMember = creditGUID ~= playerGUID
		and (
			bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
			or bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0
			or bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0
		)

	if sourceIsGroupMember then
		if entry then
			HandleTracked(entry, spellID, creditGUID, creditName, destGUID)
		end
	elseif maybeStranger then
		HandleStrangersBuff(sourceGUID, sourceName, spellID)
		if ns.NoteFavor then
			ns.NoteFavor(sourceGUID, sourceName)
		end
	end
end

ns.SetEventHandler("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered)
