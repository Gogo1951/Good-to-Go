local _, ns = ...

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local selfBuffs = BuffDuty.selfBuffs
local exclusiveIds = BuffDuty.exclusiveIds
local RankFor = BuffDuty.RankFor

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
    Keyed by GUID so a change reported on any of a player's tokens marks the
    one record, and a raid's aura traffic re-reads only the members it touched.
]]
local auraCache = {}
local dirtyGUIDs = {}
local generation = 0

local function NewRecord()
	return { expires = {}, durations = {}, strengths = {}, mine = {} }
end

-- Read fresh every time: a unit whose GUID can't be read has no record to keep.
local uncachedRecord = NewRecord()

local auraExpires, auraDurations, auraStrengths, auraMine =
	uncachedRecord.expires, uncachedRecord.durations, uncachedRecord.strengths, uncachedRecord.mine

-- A secret spell id skipped: a buff missing from that record may only be one we can't see.
local auraUnreadable = false

-- Talents raise strength, so it is known only once seen on an aura of yours; until then Has compares ranks.
local myStrengths = {}

-- Kept across talent changes: they change strength, not time.
local myDurations = {}

function BuffDuty.ForgetMyStrengths()
	wipe(myStrengths)
end

--[[
    GUID -> buff key -> { aura id -> expiration }: versions the game refused to
    cast over. Classic Era and TBC Anniversary give no strength for another
    caster's buff, so a stronger talented one only shows itself this way.
]]
local bounced = {}

local auraGUID

--[[
    The sum of `points`: every version of a buff (ranks, group, Greater)
    shares one effect layout, so the sums compare across them.
]]
local function AuraStrength(points)
	if not ns.IsPlain(points) or type(points) ~= "table" then
		return nil
	end
	local total = 0
	for _, value in ipairs(points) do
		if not ns.IsPlain(value) or type(value) ~= "number" then
			return nil
		end
		total = total + value
	end
	return total > 0 and total or nil
end

-- Nothing is dropped, so bounces are still known after a loading screen or a spell change.
function BuffDuty.MarkAllAurasDirty()
	wipe(dirtyGUIDs)
	generation = generation + 1
end

-- One dropped by mistake is only read again.
function BuffDuty.PruneAuraCache()
	local keep = {}
	local function Keep(unit)
		local guid = unit and UnitGUID(unit)
		if ns.IsPlain(guid) and guid then
			keep[guid] = true
		end
	end
	Keep("pet")
	Keep("target")
	Keep("targetpet")
	for _, member in ipairs(BuffDuty.GroupMembers()) do
		Keep(member.unit)
		Keep(BuffDuty.PetUnitOf(member.unit))
	end
	for guid in pairs(auraCache) do
		if not keep[guid] then
			auraCache[guid] = nil
			dirtyGUIDs[guid] = nil
		end
	end
	for guid in pairs(bounced) do
		if not keep[guid] then
			bounced[guid] = nil
		end
	end
	BuffDuty.PrunePetHolds(keep)
	BuffDuty.PruneNPCCycles(keep)
end

function BuffDuty.MarkAurasDirty(unit)
	local guid = UnitGUID(unit)
	if ns.IsPlain(guid) and guid then
		dirtyGUIDs[guid] = true
	else
		BuffDuty.MarkAllAurasDirty()
	end
end

-- A death, revive or dropped connection may reach the window with no aura event, so each one re-reads.
function BuffDuty.ReadAuras(unit)
	local guid = UnitGUID(unit)
	local record = uncachedRecord
	auraGUID = nil
	if ns.IsPlain(guid) and guid then
		auraGUID = guid
		local dead = UnitIsDeadOrGhost(unit) and true or false
		local connected = UnitIsConnected(unit) and true or false
		record = auraCache[guid]
		if
			record
			and record.generation == generation
			and not dirtyGUIDs[guid]
			and record.dead == dead
			and record.connected == connected
		then
			auraExpires, auraDurations, auraStrengths, auraMine =
				record.expires, record.durations, record.strengths, record.mine
			auraUnreadable = record.unreadable or false
			return
		end
		record = record or NewRecord()
		record.generation = generation
		record.dead = dead
		record.connected = connected
		auraCache[guid] = record
		dirtyGUIDs[guid] = nil
	end

	auraExpires, auraDurations, auraStrengths, auraMine =
		record.expires, record.durations, record.strengths, record.mine
	wipe(auraExpires)
	wipe(auraDurations)
	wipe(auraStrengths)
	wipe(auraMine)
	record.unreadable = false
	auraUnreadable = false
	for i = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
		if not data then
			return
		end
		if not ns.IsPlain(data.spellId) then
			record.unreadable = true
			auraUnreadable = true
		elseif data.spellId then
			local expires, duration = data.expirationTime, data.duration
			auraExpires[data.spellId] = ns.IsPlain(expires) and expires or 0
			auraDurations[data.spellId] = ns.IsPlain(duration) and duration or 0
			local strength = AuraStrength(data.points)
			auraStrengths[data.spellId] = strength
			local source = data.sourceUnit
			if ns.IsPlain(source) and source == "player" then
				auraMine[data.spellId] = true
				myStrengths[data.spellId] = strength or myStrengths[data.spellId]
				if auraDurations[data.spellId] > 0 then
					myDurations[data.spellId] = auraDurations[data.spellId]
				end
			end
		end
	end
end

function BuffDuty.AurasReadable()
	return not auraUnreadable
end

function BuffDuty.MyDuration(buff)
	local longest
	for id in pairs(buff.auraIds) do
		local duration = myDurations[id]
		if duration and (not longest or duration > longest) then
			longest = duration
		end
	end
	return longest
end

--[[
    Asked after ReadAuras(unit). A buff no longer than the refresh time counts
    only once gone, or a 10-minute Thorns under a 10-minute setting would read
    as missing the moment it landed. A stronger version counts as had however
    little is left (the game refuses to cast over it), a weaker one as missing
    however much is left. Another of your own exclusive family on the unit
    counts as had: casting would replace yours, not add to it. Thorns counts
    as had while an Imp is out: its Fire Shield takes Thorns' place, shown or
    not.
]]
local function Has(buff, unit)
	if buff.yieldsToImp and BuffDuty.ImpOut() then
		return true
	end
	local now = GetTime()
	-- A self buff carries its own time; every other buff uses the window's.
	local threshold = buff.refreshSeconds or BuffDuty.refreshSeconds
	local best = RankFor(buff, unit and UnitLevel(unit))
	local mine = (best and myStrengths[best.id]) or (buff.groupId and myStrengths[buff.groupId])
	local bounce = auraGUID and bounced[auraGUID] and bounced[auraGUID][buff.key]
	if bounce and bounce.others then
		local unchanged = true
		for id, expires in pairs(bounce.others) do
			if auraExpires[id] ~= expires then
				unchanged = false
				break
			end
		end
		if unchanged then
			return true
		end
	end
	local versions = bounce and bounce.versions
	local lowExpires, lowDuration
	for id in pairs(buff.auraIds) do
		local expires = auraExpires[id]
		if expires then
			if versions and versions[id] == expires then
				return true
			end
			local level = buff.rankLevels[id]
			local strength = auraStrengths[id]
			local counts
			if mine and strength then
				if strength > mine then
					return true
				end
				counts = strength == mine
			elseif best and level and level > best.level then
				return true
			else
				counts = not (best and level and level < best.level)
			end
			if counts then
				if expires == 0 or auraDurations[id] <= threshold or expires - now >= threshold then
					return true
				end
				if not lowExpires or expires > lowExpires then
					lowExpires, lowDuration = expires, auraDurations[id]
				end
			end
		end
	end
	if buff.exclusive then
		for id in pairs(exclusiveIds[buff.exclusive]) do
			if auraMine[id] and not buff.auraIds[id] then
				return true
			end
		end
	end
	return false, lowExpires, lowDuration
end
BuffDuty.Has = Has

-- Asked after ReadAuras(unit): any version, however little is left or whoever cast it.
function BuffDuty.Carries(buff)
	for id in pairs(buff.auraIds) do
		if auraExpires[id] then
			return true
		end
	end
	return false
end

--[[
    With no version of the buff on them, the stronger buff is one this data
    doesn't list, so every buff they carry is recorded. Read off the unit, not
    the cache, which may be older.
]]
function BuffDuty.NoteBounce(unit, buffKey)
	if ns.AreAurasSecret() then
		return
	end
	local guid = UnitGUID(unit)
	if not ns.IsPlain(guid) or not guid then
		return
	end
	-- A group buff turned off for others is still offered to you, from Self Buffs.
	for _, list in ipairs({ buffs, selfBuffs }) do
		for _, buff in ipairs(list) do
			if buff.key == buffKey then
				local seen, others = {}, {}
				for i = 1, 40 do
					local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
					if not data then
						break
					end
					local id, expires = data.spellId, data.expirationTime
					if ns.IsPlain(id) and id then
						-- Kept as ReadAuras keeps it, so Has compares like with like.
						expires = ns.IsPlain(expires) and expires or 0
						others[id] = expires
						if buff.auraIds[id] then
							seen[id] = expires
						end
					end
				end
				local record
				if next(seen) then
					record = { versions = seen }
				elseif next(others) then
					record = { others = others }
				end
				if record then
					bounced[guid] = bounced[guid] or {}
					bounced[guid][buffKey] = record
					dirtyGUIDs[guid] = true
				end
				return
			end
		end
	end
end
