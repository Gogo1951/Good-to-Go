local _, ns = ...
local Data = ns.Data

local BuffDuty = ns.BuffDuty

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local favors = {} -- stranger GUID -> { name, short, class, at, given = { [buff key] = true } }

function BuffDuty.FavorOf(guid)
	return favors[guid]
end

-- A favor may be forgotten while the loop runs.
function BuffDuty.EachFavor()
	return next, favors, nil
end

-- No redraw: called while the list draws.
function BuffDuty.ForgetFavor(guid)
	favors[guid] = nil
end

--------------------------------------------------------------------------------
-- Return the Favor
--------------------------------------------------------------------------------

function ns.NoteFavor(guid, name)
	if not BuffDuty.isSetUp or not ns.db or not ns.db.global.buffWindow.favorEnabled then
		return
	end
	if not (ns.IsPlain(guid) and ns.IsPlain(name)) or not ns.IsPlayerGUID(guid) or not name then
		return
	end

	local favor = favors[guid]
	if favor then
		favor.at = GetTime()
	else
		local _, class = GetPlayerInfoByGUID(guid)
		favors[guid] = {
			name = name,
			short = Ambiguate(name, "short"),
			class = ns.IsPlain(class) and class or nil,
			at = GetTime(),
			given = {},
		}
		local count, oldestGUID, oldestAt = 0, nil, nil
		for key, entry in pairs(favors) do
			count = count + 1
			if not oldestAt or entry.at < oldestAt then
				oldestGUID, oldestAt = key, entry.at
			end
		end
		if count > Data.BUFF_DUTY_FAVOR_MAX then
			favors[oldestGUID] = nil
		end
	end
	ns.RequestBuffDutyRefresh()
end

function ns.DismissFavor(guid)
	favors[guid] = nil
	ns.RequestBuffDutyRefresh()
end

--[[
    Source flags, not a name lookup, say friendly and outside your group, since
    cross-realm names break lookups; ns.NoteFavor's GUID check drops a pet.
]]
local band = bit.band
local playerGUID -- read on the first line, since a character's GUID never changes in a session

function ns.NoteFavorFromCombatLog(sourceGUID, sourceName, sourceFlags, destGUID, auraType)
	playerGUID = playerGUID or UnitGUID("player")
	if auraType ~= "BUFF" or not sourceGUID or destGUID ~= playerGUID or sourceGUID == destGUID then
		return
	end
	local flags = sourceFlags or 0
	if
		band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0
		or band(flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0
	then
		return
	end
	ns.NoteFavor(sourceGUID, sourceName)
end

-- A stranger with no nameplate has no sourceUnit, so the caster is read by GUID instead.
local function FavorCaster(aura)
	local unit = aura.sourceUnit
	local guid
	if unit ~= nil then
		if not ns.IsPlain(unit) then
			return nil
		end
		guid = UnitGUID(unit)
	else
		local instanceID = aura.auraInstanceID
		if not ns.IsPlain(instanceID) or not instanceID then
			return nil
		end
		local ok, casterGUID = pcall(C_UnitAuras.GetAuraCasterGUID, "player", instanceID)
		if not ok then
			return nil
		end
		guid = casterGUID
		unit = ns.GetUnitByGUID(guid)
	end
	if not ns.IsPlain(guid) or not guid or not ns.IsPlayerGUID(guid) then
		return nil
	end

	if unit then
		if
			ns.IsPlainYes(UnitIsUnit(unit, "player"))
			or ns.IsPlainYes(UnitInParty(unit))
			or ns.IsPlainYes(UnitInRaid(unit))
		then
			return nil
		end
		local isFriend = UnitIsFriend("player", unit)
		if not (ns.IsPlain(isFriend) and isFriend) then
			return nil
		end
		local name = GetUnitName(unit, true)
		if not ns.IsPlain(name) then
			return nil
		end
		return guid, name
	end

	--[[
	    No friendliness check: the other faction can't cast a helpful buff on
	    you. Whispers need "Name-Realm" across realms, with the realm's spaces
	    stripped.
	]]
	local name, realm = UnitNameFromGUID(guid)
	if not ns.IsPlain(name) or not name or name == "" then
		return nil
	end
	if realm and ns.IsPlain(realm) and realm ~= "" then
		name = name .. "-" .. realm:gsub("%s", "")
	end
	return guid, name
end

--[[
    WoW Forever forbids the combat log, so added auras are read off UNIT_AURA.
    A recast of a buff you already have adds nothing to see.
]]
function ns.NoteFavorFromAuras(updateInfo)
	if not BuffDuty.isSetUp or not ns.db.global.buffWindow.favorEnabled then
		return
	end
	if InCombatLockdown() or ns.AreAurasSecret() then
		return
	end
	if not updateInfo or not ns.IsPlain(updateInfo.isFullUpdate) or updateInfo.isFullUpdate then
		return
	end
	local added = updateInfo.addedAuras
	if not ns.IsPlain(added) or not added then
		return
	end
	for _, aura in ipairs(added) do
		if ns.IsPlain(aura.isHelpful) and aura.isHelpful then
			local guid, name = FavorCaster(aura)
			if guid then
				ns.NoteFavor(guid, name)
			end
		end
	end
end
