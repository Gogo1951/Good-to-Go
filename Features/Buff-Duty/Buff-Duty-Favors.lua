local _, ns = ...
local Data = ns.Data

--[[
    Return the Favor's memory: the strangers outside your group who just buffed
    you, heard from the combat log or, on WoW Forever, from your own UNIT_AURA.
    Each is kept for favorSeconds from their latest buff, up to
    Data.BUFF_DUTY_FAVOR_MAX of them. Buff-Duty-Outsiders.lua draws the list.
]]

local BuffDuty = ns.BuffDuty

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local favors = {} -- stranger GUID -> { name, short, class, at, given = { [buff key] = true } }

-- The favor kept for a stranger, or nil.
function BuffDuty.FavorOf(guid)
	return favors[guid]
end

-- Every favor kept, as guid, favor; a favor may be forgotten while the loop runs.
function BuffDuty.EachFavor()
	return next, favors, nil
end

-- Drops a favor without a redraw, for the Return the Favor list as it draws.
function BuffDuty.ForgetFavor(guid)
	favors[guid] = nil
end

--------------------------------------------------------------------------------
-- Return the Favor
--------------------------------------------------------------------------------

--[[
    Called for every helpful buff a player outside your group puts on you,
    from the combat log (ns.NoteFavorFromCombatLog) or, on WoW Forever, from
    your own UNIT_AURA (ns.NoteFavorFromAuras). Kept for the player's
    favorSeconds from their latest buff.
]]
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
		-- Over the cap, the stranger who buffed you longest ago makes room.
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

-- The favor icons' right-click.
function ns.DismissFavor(guid)
	favors[guid] = nil
	ns.RequestBuffDutyRefresh()
end

--[[
    A buff landing on you in the combat log, where there is one. The source's
    flags say friendly and outside your group, so a cross-realm "Name-Realm"
    needs no name lookup; ns.NoteFavor's GUID check then drops a pet, whatever
    its flags claim.
]]
local band = bit.band

function ns.NoteFavorFromCombatLog(sourceGUID, sourceName, sourceFlags, destGUID, auraType)
	if auraType ~= "BUFF" or not sourceGUID or destGUID ~= UnitGUID("player") or sourceGUID == destGUID then
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

--[[
    Who put an aura on you, as a GUID and a whisperable name, when it was a
    friendly player outside your group; nil for anyone else. The aura's own
    sourceUnit comes first; without one (a stranger with no nameplate) the
    caster is read by GUID and named with UnitNameFromGUID.
]]
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
		if UnitIsUnit(unit, "player") or UnitInParty(unit) or UnitInRaid(unit) then
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
	    Known by GUID alone: a helpful buff on you is something the other
	    faction can't cast, so no friendliness check is needed. Whispers need
	    "Name-Realm" across realms, and a realm name has no spaces there.
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
    WoW Forever has no combat log, so the auras just added to you are read
    off UNIT_AURA instead. Nothing is read in combat or while auras are
    secret, and a recast of a buff you already have adds nothing to see.
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
