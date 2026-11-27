local _, ns = ...

--------------------------------------------------------------------------------
-- Derived Scroll Lookups
--------------------------------------------------------------------------------

-- Routes scroll items away from normal consumable processing.
ns.SCROLL_ITEM_LOOKUP = {}

-- A missing table or list reads as no scrolls rather than erroring; Diagnostics prints what was filled in.
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

-- Lists, not single owners: a conflict buff like Elixir of the Sages covers two stats.
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
    Crossing the threshold fires no UNIT_AURA, so a timer requests the rebuild.
    C_Timer.After can't be canceled: nextRecheckAt keeps the earliest, and
    stale later timers do nothing.
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
    Raw expiration times, never a verdict (nil absent, 0 no duration), so the
    Readiness Report reads them with no side effects. One shared buffer reused
    in place: never hold it across another call. While auras are secret
    (Forever) the last snapshot is returned untouched; a reset one would read
    as "no buffs" and rebuild around a buff the player still has.
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
	snapshot.fishingFed = false
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

		if ns.FISHING_WELL_FED_BUFF_IDS[spellID] then
			snapshot.fishingFed = true
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

-- Any time left counts: the Fishing Lure macro eats only once it's gone.
function ns.HasFishingWellFed(currentSnapshot)
	return currentSnapshot.fishingFed == true
end

local function WellFedFromSnapshot(currentSnapshot)
	local expiration = currentSnapshot.wellFedExpiration
	return expiration ~= nil and BuffCountsAsActive(expiration)
end

--------------------------------------------------------------------------------
-- Scroll Buffs
--------------------------------------------------------------------------------

-- A scroll buff of any rank covers; a conflict buff covers only at an equal or larger amount.
function ns.HasScrollBuff(scrollType, scrollAmount, callerSnapshot)
	if not ns.SCROLL_DATA[scrollType] then
		return true
	end

	local entry = (callerSnapshot or ns.GetPlayerBuffSnapshot()).scrolls[scrollType]

	if entry.expiration ~= nil and BuffCountsAsActive(entry.expiration) then
		return true
	end

	-- No early re-application here: a stronger buff can't be overwritten, so the scroll would error.
	return entry.conflictAmount ~= nil and entry.conflictAmount >= (scrollAmount or 0)
end

--------------------------------------------------------------------------------
-- Pet Food Buffs
--------------------------------------------------------------------------------

local PET_BUFF_FOOD_SPELL_IDS = {}
local PET_BUFF_FOOD_MIN_LEVEL
for _, row in pairs(ns.PET_BUFF_FOODS) do
	PET_BUFF_FOOD_SPELL_IDS[row[1]] = true
	PET_BUFF_FOOD_MIN_LEVEL = math.min(PET_BUFF_FOOD_MIN_LEVEL or row[4], row[4])
end

local HAS_PET_BUFF_FOODS = next(ns.PET_BUFF_FOODS) ~= nil

--[[
    No class test: a Warlock's demon eats it too. Shared with the Readiness
    Report on purpose: apart, it could ask for a buff the macro never applies.
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

-- Same conventions as the player snapshot, including the last reading while auras are secret.
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

local lastPetFoodBuff

-- So nothing is compared against a reading taken under the old settings.
function ns.ResetScrollBuffTracking()
	lastPetFoodBuff = nil
end

--------------------------------------------------------------------------------
-- Aura Tracking
--------------------------------------------------------------------------------

local auraEventRegistered

local lastFishingFed

-- Re-registers only when the wanted units change: every bag scan passes through here.
function ns.UpdateAuraTracking()
	local settings = ns.db.profile
	local petBuffActive = HAS_PET_BUFF_FOODS and settings.usePetBuffFood and ns.IsUseWhenActive(settings, "petBuffFood")

	ns.wellFedState = WellFedFromSnapshot(ns.GetPlayerBuffSnapshot())

	if petBuffActive and ns.ShouldTrackPetFood() then
		lastPetFoodBuff = ns.HasPetFoodBuff()
	else
		lastPetFoodBuff = nil
	end

	if ns.watchFishingFed then
		lastFishingFed = ns.HasFishingWellFed(ns.GetPlayerBuffSnapshot())
	else
		lastFishingFed = nil
	end

	local watchPlayer = (ns.carriesBuffFood or ns.watchFishingFed) and true or false
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

-- A busy event and a rebuild is a full rescan, so each side diffs only the one thing it reads.
function ns.OnUnitAura(unit)
	local needsUpdate = false
	-- Logged from here, not the capture tap, which runs first and can't know which firings mattered.
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
		if ns.watchFishingFed then
			local fishingFed = ns.HasFishingWellFed(ns.GetPlayerBuffSnapshot())
			if fishingFed ~= lastFishingFed then
				lastFishingFed = fishingFed
				needsUpdate = true
				reason = reason or "fishingfed"
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
