local _, ns = ...

--[[
    Scanner-Auras -- reads live player/pet auras and decides which buffs the
    character still needs: aura probes (Well Fed, scroll, and pet-food buffs),
    early re-application, and the UNIT_AURA handler. Scrolls are Buff Duty's
    (Buff-Duty-Self.lua), which reads Scanner-Scrolls.lua.
]]

--------------------------------------------------------------------------------
-- Derived Scroll Lookups
--------------------------------------------------------------------------------

--[[
    Built once at load from ns.SCROLL_DATA (Data/{Game}/Scrolls-{Game}.lua, which
    loads before this file). ns.SCROLL_ITEM_LOOKUP maps each scroll itemID to its
    scroll type so the bag scanners route scroll items away from normal
    consumable processing. Each type's items are sorted by required level,
    highest first, so ns.FindBestScroll's first usable hit is the best scroll
    whatever the data's row order. Every consumer reads these from inside a
    function (runtime), so the build only needs to finish before the first scan.
]]
ns.SCROLL_ITEM_LOOKUP = {}

--[[
    A flavor with no scroll file, or a type missing either list, reads as no
    scrolls rather than erroring: every walk below and in Scanner-Scrolls.lua
    runs ipairs/pairs on these lists. ns.SCROLL_DATA_GAPS records what was
    filled in, and Diagnostics' context report prints it.
]]
ns.SCROLL_DATA_GAPS = {}
if type(ns.SCROLL_DATA) ~= "table" then
	ns.SCROLL_DATA = {}
	ns.SCROLL_DATA_GAPS[#ns.SCROLL_DATA_GAPS + 1] = "no SCROLL_DATA table"
end
for scrollType, data in pairs(ns.SCROLL_DATA) do
	if type(data.items) ~= "table" then
		data.items = {}
		ns.SCROLL_DATA_GAPS[#ns.SCROLL_DATA_GAPS + 1] = tostring(scrollType) .. " has no items"
	end
	if type(data.conflictSpells) ~= "table" then
		data.conflictSpells = {}
		ns.SCROLL_DATA_GAPS[#ns.SCROLL_DATA_GAPS + 1] = tostring(scrollType) .. " has no conflictSpells"
	end
end

local function ByRequiredLevelDescending(a, b)
	if a[3] ~= b[3] then
		return a[3] > b[3]
	end
	return a[4] > b[4]
end

--[[
    Reverse maps from a spell ID back to the scroll type(s) it covers, so the
    aura walk below resolves each aura in one lookup instead of testing every
    type. Both hold lists: several conflict buffs (Elixir of the Sages) cover
    two stats, and each registers against every type it covers rather than
    silently claiming one.
]]
local scrollBuffOwners = {}
local scrollConflictOwners = {}

for scrollType, data in pairs(ns.SCROLL_DATA) do
	table.sort(data.items, ByRequiredLevelDescending)
	local buffIDs = {}
	for _, entry in ipairs(data.items) do
		ns.SCROLL_ITEM_LOOKUP[entry[1]] = scrollType
		buffIDs[entry[2]] = true
	end

	for spellID in pairs(buffIDs) do
		local owners = scrollBuffOwners[spellID] or {}
		owners[#owners + 1] = scrollType
		scrollBuffOwners[spellID] = owners
	end
	for spellID, amount in pairs(data.conflictSpells) do
		local owners = scrollConflictOwners[spellID] or {}
		owners[#owners + 1] = { scrollType = scrollType, amount = amount }
		scrollConflictOwners[spellID] = owners
	end
end

--------------------------------------------------------------------------------
-- Early Re-Application
--------------------------------------------------------------------------------

--[[
    With Re-Apply Expiring Buffs on, a tracked buff whose remaining time is
    under the profile threshold counts as already expired, so the macros offer
    a fresh application before the pull. Auras without a duration
    (expirationTime 0) never count as expiring.

    Crossing the threshold fires no UNIT_AURA event, so when a scan finds a
    buff still above it, a one-shot timer requests a rebuild for the moment
    the buff crosses. C_Timer.After cannot be canceled, so nextRecheckAt
    tracks the earliest pending fire time and later-firing stale timers
    no-op; a duplicate rebuild within the epsilon is harmless (RequestUpdate
    is throttled).
]]
local nextRecheckAt

local function ScheduleExpiryRecheck(delay)
	local fireAt = GetTime() + delay
	if nextRecheckAt and nextRecheckAt <= fireAt then
		return
	end
	nextRecheckAt = fireAt
	C_Timer.After(delay, function()
		if not nextRecheckAt or GetTime() + 0.5 < nextRecheckAt then
			return
		end
		nextRecheckAt = nil
		ns.RequestUpdate()
	end)
end

local function BuffCountsAsActive(expirationTime)
	local settings = ns.db and ns.db.profile
	if not (settings and settings.earlyReapply) then
		return true
	end
	if not expirationTime or expirationTime == 0 then
		return true
	end
	local remaining = expirationTime - GetTime()
	local threshold = settings.earlyReapplyThreshold
	if remaining < threshold then
		return false
	end
	ScheduleExpiryRecheck(remaining - threshold + 1)
	return true
end

--------------------------------------------------------------------------------
-- Player Aura Snapshot
--------------------------------------------------------------------------------

--[[
    One walk of the player's helpful auras, shared by the Well Fed and scroll
    probes below and by the readiness report (Features/Readiness-Report/Readiness-Report.lua).
    The snapshot holds raw expiration times, never a verdict: the probes apply
    BuffCountsAsActive, which owns the early re-application threshold and its
    rebuild timer, while the report reads the same numbers with no side
    effects of its own.

    Expiration convention, shared with the pet probe below: nil means the buff
    is absent, 0 means the aura carries no duration.

    Per buff we keep the longest-lasting match, and a 0 outranks any timed one.
    BuffCountsAsActive is monotonic in remaining time, so testing the longest
    match answers "does any match count as active" exactly as testing every
    match would. Neither Well Fed nor a scroll buff stacks with itself, so in
    practice there is only ever one match to choose from.

    Scroll entries also keep the largest conflicting buff amount seen (a class
    buff or a same-stat elixir), so the scroll probe can settle "is a
    conflicting buff already at least as good as the scroll I would use"
    without a second pass; that comparison needs the scroll's own amount,
    which is per-call.

    The table is reused in place rather than rebuilt, because UNIT_AURA is a
    firehose and the Well Fed probe runs on every tick. That makes the return
    value a single shared buffer, not a private copy: a caller must not hold it
    across another call to this function, and one that needs several answers
    takes one snapshot and passes it down (see ns.FindMissingScrolls).

    While the client restricts aura data (Forever, which is Retail's engine),
    every field read comes back secret and comparing one errors, so the walk is
    skipped and the previous snapshot is returned untouched. An unchanged
    snapshot reads as "nothing moved"; a reset one would read as "no buffs"
    and rebuild the macros around a buff the player still has.
]]
local snapshot = { scrolls = {} }
for scrollType in pairs(ns.SCROLL_DATA) do
	snapshot.scrolls[scrollType] = {}
end

local function IsLongerExpiration(candidate, current)
	if current == nil then
		return true
	end
	if current == 0 then
		return false
	end
	return candidate == 0 or candidate > current
end

function ns.GetPlayerBuffSnapshot()
	if ns.AreAurasSecret() then
		return snapshot
	end

	snapshot.wellFedExpiration = nil
	for _, entry in pairs(snapshot.scrolls) do
		entry.expiration = nil
		entry.conflictAmount = nil
	end

	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not aura then
			break
		end
		local icon, spellID = aura.icon, aura.spellId
		local expirationTime = aura.expirationTime or 0

		if ns.WELL_FED_ICON_IDS[icon] or ns.WELL_FED_BUFF_IDS[spellID] then
			if IsLongerExpiration(expirationTime, snapshot.wellFedExpiration) then
				snapshot.wellFedExpiration = expirationTime
			end
		end

		local buffOwners = scrollBuffOwners[spellID]
		if buffOwners then
			for _, scrollType in ipairs(buffOwners) do
				local entry = snapshot.scrolls[scrollType]
				if IsLongerExpiration(expirationTime, entry.expiration) then
					entry.expiration = expirationTime
				end
			end
		end

		local conflictOwners = scrollConflictOwners[spellID]
		if conflictOwners then
			for _, owner in ipairs(conflictOwners) do
				local entry = snapshot.scrolls[owner.scrollType]
				if not entry.conflictAmount or owner.amount > entry.conflictAmount then
					entry.conflictAmount = owner.amount
				end
			end
		end
	end

	return snapshot
end

--------------------------------------------------------------------------------
-- Well Fed
--------------------------------------------------------------------------------

--[[
    Whether you have Well Fed, from a snapshot, for the Food macro's buff food
    first (ns.buffFoodFirst in Scanner-Inventory.lua). Re-Apply Expiring Buffs
    counts a Well Fed under its threshold as gone, as it does the pet's.
]]
local function WellFedFromSnapshot(currentSnapshot)
	local expiration = currentSnapshot.wellFedExpiration
	return expiration ~= nil and BuffCountsAsActive(expiration)
end

--------------------------------------------------------------------------------
-- Scroll Buffs
--------------------------------------------------------------------------------

--[[
    A scroll buff of any rank counts as covered. A conflict spell (e.g. Fort,
    or Elixir of the Mongoose for Agility) only counts as covered if its base
    amount is at least as large as the scroll we would use — otherwise the
    scroll would still improve the stat.

    callerSnapshot is an optional snapshot from ns.GetPlayerBuffSnapshot.
    Callers asking about more than one scroll type pass one in, so a single
    walk of the player's auras serves the whole set; omitting it takes a
    fresh one.
]]
function ns.HasScrollBuff(scrollType, scrollAmount, callerSnapshot)
	if not ns.SCROLL_DATA[scrollType] then
		return true
	end

	local entry = (callerSnapshot or ns.GetPlayerBuffSnapshot()).scrolls[scrollType]

	if entry.expiration ~= nil and BuffCountsAsActive(entry.expiration) then
		return true
	end

	--[[
	    Check conflict spells — only block the scroll if the conflicting
	    buff provides at least as much stat as our best scroll would.
	    Exempt from the early re-application threshold: a still-active
	    stronger buff cannot be overwritten, so treating it as expired
	    would build a scroll line that errors on use.
	]]
	return entry.conflictAmount ~= nil and entry.conflictAmount >= (scrollAmount or 0)
end

--------------------------------------------------------------------------------
-- Pet Food Buffs
--------------------------------------------------------------------------------

--[[
    The buffs ns.PET_BUFF_FOODS grant, matched against the pet's auras, and the
    lowest level any of the foods can be used at.
]]
local PET_BUFF_FOOD_SPELL_IDS = {}
local PET_BUFF_FOOD_MIN_LEVEL
for _, row in pairs(ns.PET_BUFF_FOODS) do
	PET_BUFF_FOOD_SPELL_IDS[row[1]] = true
	PET_BUFF_FOOD_MIN_LEVEL = math.min(PET_BUFF_FOOD_MIN_LEVEL or row[4], row[4])
end

-- A flavor whose data folder has no pet buff food runs none of this feature.
local HAS_PET_BUFF_FOODS = next(ns.PET_BUFF_FOODS) ~= nil

--[[
    Whether pet buff food applies to this character right now: this flavor has
    one, the feature is on, its group restriction is satisfied, the player is
    high enough level for the food to exist, and there is a live pet to feed.
    No class test: a Hunter's beast and a Warlock's demon both eat it, and a
    character with no pet out (a Warlock who sacrificed the demon) fails the
    live-pet test anyway.

    Single source of truth on purpose. Both ns.FindPetBuffOverride
    (Macros/Tools-Hunters-Pet-Food.lua), which decides whether to splice the feed line
    into the Food macro, and the readiness report (Features/Readiness-Report/Readiness-Report.lua)
    have to agree: apart, the report can ask a level-30 Hunter for a buff its
    own macro will never apply, with no way to satisfy it.
]]
function ns.ShouldTrackPetFood()
	if not HAS_PET_BUFF_FOODS then
		return false
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings.usePetBuffFood then
		return false
	end
	if not ns.IsUseWhenActive(settings, "petBuffFood") then
		return false
	end
	if (ns.cachedPlayerLevel or 1) < PET_BUFF_FOOD_MIN_LEVEL then
		return false
	end
	if not UnitExists("pet") or UnitIsDead("pet") or UnitIsGhost("pet") then
		return false
	end
	return true
end

--[[
    The pet is a separate unit and so a separate walk from the player snapshot
    above, but it follows the same expiration convention: nil when the buff is
    absent, 0 when the aura carries no duration. Consumed by
    ns.FindPetBuffOverride (Macros/Tools-Hunters-Pet-Food.lua) and by the readiness
    report; the probe lives here because BuffCountsAsActive is private to this
    file. Like the player snapshot, it answers with its last reading while the
    client restricts aura data.
]]
local lastPetFoodBuffExpiration

function ns.GetPetFoodBuffExpiration()
	if not UnitExists("pet") then
		lastPetFoodBuffExpiration = nil
		return nil
	end
	if ns.AreAurasSecret() then
		return lastPetFoodBuffExpiration
	end
	local best
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("pet", i, "HELPFUL")
		if not aura then
			break
		end
		if PET_BUFF_FOOD_SPELL_IDS[aura.spellId] then
			local expirationTime = aura.expirationTime or 0
			if IsLongerExpiration(expirationTime, best) then
				best = expirationTime
			end
		end
	end
	lastPetFoodBuffExpiration = best
	return best
end

function ns.HasPetFoodBuff()
	local expiration = ns.GetPetFoodBuffExpiration()
	return expiration ~= nil and BuffCountsAsActive(expiration)
end

--------------------------------------------------------------------------------
-- Pet Food Reading
--------------------------------------------------------------------------------

-- The pet food decision's last reading: nil until a scan or the handler records one.
local lastPetFoodBuff

--[[
    Called from ns.ResetMacroState: a forced rebuild drops the pet food
    reading so nothing is compared against one taken under the old settings.
    The next scan records a fresh one, and an aura event that arrives first
    counts as a change.
]]
function ns.ResetScrollBuffTracking()
	lastPetFoodBuff = nil
end

--------------------------------------------------------------------------------
-- Aura Tracking
--------------------------------------------------------------------------------

local auraEventRegistered

--[[
    Reads Well Fed for the scan (ns.wellFedState) and keeps UNIT_AURA on for
    the player while the bags hold buff food (ns.carriesBuffFood, from the
    scan before), and for the pet while Pet Food Buffs is live, recording the
    readings the aura handler diffs against. Scrolls are Buff Duty's, which
    watches its own auras. UNIT_AURA is only re-registered when the wanted
    units change, since every bag scan passes through here.
]]
function ns.UpdateAuraTracking()
	local settings = ns.db.profile
	local petBuffActive = HAS_PET_BUFF_FOODS and settings.usePetBuffFood and ns.IsUseWhenActive(settings, "petBuffFood")

	ns.wellFedState = WellFedFromSnapshot(ns.GetPlayerBuffSnapshot())

	if petBuffActive and ns.ShouldTrackPetFood() then
		lastPetFoodBuff = ns.HasPetFoodBuff()
	else
		lastPetFoodBuff = nil
	end

	local watchPlayer = ns.carriesBuffFood and true or false
	local wantAuraEvent = (watchPlayer and petBuffActive and "player+pet")
		or (watchPlayer and "player")
		or (petBuffActive and "pet")
		or false
	if wantAuraEvent ~= auraEventRegistered then
		auraEventRegistered = wantAuraEvent
		if wantAuraEvent == "player+pet" then
			ns.SetEventRegistered("UNIT_AURA", true, "player", "pet")
		elseif wantAuraEvent then
			ns.SetEventRegistered("UNIT_AURA", true, wantAuraEvent)
		else
			ns.SetEventRegistered("UNIT_AURA", false)
		end
	end
end

--------------------------------------------------------------------------------
-- Aura Event Handler
--------------------------------------------------------------------------------

--[[
    UNIT_AURA handler routed from Core's dispatcher, registered for the player
    and the pet as ns.UpdateAuraTracking wants them. Each side diffs the one
    thing its decision reads, whether Well Fed or the pet food buff is up:
    UNIT_AURA is a firehose, a rebuild is a full bag rescan, and a raid's buff
    round lands blessings and totems on both.
]]
function ns.OnUnitAura(unit)
	local needsUpdate = false
	--[[
	    What made this firing worth acting on. UNIT_AURA is a firehose, so the
	    diagnostics capture tap can only count it -- it runs before this handler
	    and cannot yet know. This is the end that does know, so the signal
	    firings are logged from here (see ns:LogEventNow in
	    Diagnostics/Event-Log.lua), which keeps the event log from disagreeing
	    with what the add-on actually reacted to.
	]]
	local reason

	if unit == "player" then
		if ns.carriesBuffFood then
			local wellFedState = WellFedFromSnapshot(ns.GetPlayerBuffSnapshot())
			if wellFedState ~= ns.wellFedState then
				ns.wellFedState = wellFedState
				needsUpdate = true
				reason = "wellfed"
			end
		end
	elseif unit == "pet" then
		if ns.ShouldTrackPetFood() then
			local hasPetFoodBuff = ns.HasPetFoodBuff()
			if hasPetFoodBuff ~= lastPetFoodBuff then
				lastPetFoodBuff = hasPetFoodBuff
				needsUpdate = true
				reason = "petbuff"
			end
		end
	end

	if needsUpdate then
		ns:LogEventNow("UNIT_AURA", unit, reason)
		ns.RequestUpdate()
	end
end
