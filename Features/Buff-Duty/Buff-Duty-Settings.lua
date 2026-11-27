local _, ns = ...
local Data = ns.Data

local BuffDuty = ns.BuffDuty
local lookup = BuffDuty.lookup
local selfLookup = BuffDuty.selfLookup

--------------------------------------------------------------------------------
-- Audience Settings
--------------------------------------------------------------------------------

-- Never touches a key this client lacks. Re-run on profile changes.
local function PopulateBuffDutyAudience()
	local tankWhen = ns.db.global.buffWindow.tankWhen

	for key, value in pairs(tankWhen) do
		if not Data.TANK_WHEN[value] then
			tankWhen[key] = nil
		end
	end

	local audience = ns.db.global.buffWindow.audience
	for key, value in pairs(audience) do
		if not Data.BUFF_AUDIENCE[value] then
			audience[key] = nil
		end
	end
	for key, entry in pairs(lookup) do
		if audience[key] == nil then
			audience[key] = entry.row.default
		end
	end

	local valid = {}
	for _, choice in ipairs(Data.SELF_REFRESH_CHOICES) do
		valid[choice] = true
	end
	local selfRefresh = ns.db.global.buffWindow.selfRefresh
	for key, value in pairs(selfRefresh) do
		if not valid[value] then
			selfRefresh[key] = nil
		end
	end
	for key, entry in pairs(selfLookup) do
		if selfRefresh[key] == nil then
			selfRefresh[key] = entry.row.default
		end
	end
	-- Seeded from the row's default audience, never the player's own pick.
	for key, entry in pairs(lookup) do
		if selfRefresh[key] == nil then
			local row = entry.row
			local default = row.selfDefault
			if default == nil then
				default = row.default == Data.BUFF_AUDIENCE.ALL and 3 or Data.SELF_REFRESH_OFF
			end
			selfRefresh[key] = default
		end
	end
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		if selfRefresh[entry.key] == nil then
			selfRefresh[entry.key] = entry.row.default
		end
	end
	local stone = BuffDuty.soulstoneEntry
	if stone and selfRefresh[stone.key] == nil then
		selfRefresh[stone.key] = stone.row.default
	end

	--[[
	    A stored id this client has no row for is kept: Classic Era and Season
	    of Discovery share these settings, and one client's poison is the
	    other's to keep.
	]]
	local settings = ns.db.global.buffWindow
	for _, list in ipairs({ settings.weaponPicks, settings.weaponItems }) do
		for _, hand in pairs(list) do
			for key, value in pairs(hand) do
				if type(value) ~= "boolean" then
					hand[key] = nil
				end
			end
		end
	end

	for _, row in ipairs(Data.BUFF_DUTY_ROWS) do
		if not tContains(Data.BUFF_DUTY_ROW_SHOW_CHOICES, settings.rowShow[row]) then
			settings.rowShow[row] = Data.BUFF_DUTY_ROW_SHOW_DEFAULT
		end
	end
	for _, list in ipairs({ settings.rowOn, settings.rowOut, settings.elixirOff, settings.scrollOff }) do
		for key, value in pairs(list) do
			if type(value) ~= "boolean" then
				list[key] = nil
			end
		end
	end
	-- A consumable category never set is seeded from its selfRefresh switch.
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		local row = entry.wellFed and "food" or entry.scrolls and "scrolls" or entry.elixirs and "elixirs"
		if row and settings.rowOn[row] == nil then
			settings.rowOn[row] = BuffDuty.SelfItemOn(entry.key)
		end
	end

	for key, value in pairs(settings.rowWhen) do
		if not Data.BUFF_DUTY_ROW_WHEN[value] then
			settings.rowWhen[key] = nil
		end
	end
	for key, value in pairs(settings.rowKey) do
		if type(value) ~= "boolean" then
			settings.rowKey[key] = nil
		end
	end

	--[[
	    Each Self-Buffs type starts from the one set Self-Buffs had before it
	    split, so nothing changes until the player changes it. Show in Buff Duty
	    needs no seed: unset reads as on.
	]]
	for key in pairs(settings.rowShow) do
		if BuffDuty.IsSelfTypeRow(key) and not tContains(Data.BUFF_DUTY_ROW_SHOW_CHOICES, settings.rowShow[key]) then
			settings.rowShow[key] = nil
		end
	end
	for _, list in ipairs({ lookup, selfLookup, { BuffDuty.soulstoneEntry } }) do
		for _, entry in pairs(list) do
			local row = BuffDuty.SelfTypeRow(entry.selfType, entry.row.class)
			if settings.rowWhen[row] == nil then
				settings.rowWhen[row] = settings.rowWhen.self
			end
			if settings.rowShow[row] == nil then
				settings.rowShow[row] = settings.rowShow.self
			end
			if settings.rowKey[row] == nil then
				settings.rowKey[row] = settings.rowKey.self
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

-- A battleground's group counts as a raid.
function BuffDuty.RowShows(row)
	if not BuffDuty.RowOn(row) then
		return false
	end
	local when = ns.db.global.buffWindow.rowWhen[row]
	if when == Data.BUFF_DUTY_ROW_WHEN.RAID then
		return IsInRaid() and true or false
	elseif when == Data.BUFF_DUTY_ROW_WHEN.GROUP then
		return IsInGroup() and true or false
	end
	return true
end

function BuffDuty.RowOnKey(row)
	return ns.db.global.buffWindow.rowKey[row] ~= false
end

-- Self-Buffs and Weapon Buffs keep selfEnabled and weaponEnabled; the rest use rowOn, where unset reads as on.
function BuffDuty.RowOn(row)
	local settings = ns.db.global.buffWindow
	if row == "self" then
		return settings.selfEnabled and true or false
	elseif row == "weapons" then
		return settings.weaponEnabled and true or false
	end
	return settings.rowOn[row] ~= false
end

function BuffDuty.SetRowOn(row, value)
	local settings = ns.db.global.buffWindow
	if row == "self" then
		settings.selfEnabled = value
	elseif row == "weapons" then
		settings.weaponEnabled = value
	else
		settings.rowOn[row] = value
	end
end

-- 0 for When Missing.
function BuffDuty.RowShowSeconds(row)
	return (ns.db.global.buffWindow.rowShow[row] or Data.BUFF_DUTY_ROW_SHOW_DEFAULT) * 60
end

-- Self-Buffs are spells: nothing to run out of.
function BuffDuty.RowOut(row)
	return row ~= "self" and not BuffDuty.IsSelfTypeRow(row) and ns.db.global.buffWindow.rowOut[row] == true
end

-- So a menu leaves out a category this client could never fill.
function BuffDuty.RowExists(row)
	if row == "scrolls" then
		return ns.SCROLL_TYPE_LABELS ~= nil and #ns.SCROLL_TYPE_LABELS > 0
	elseif row == "elixirs" then
		return ns.ELIXIR_BUFF_IDS ~= nil and next(ns.ELIXIR_BUFF_IDS) ~= nil
	elseif row == "other" then
		for _, entry in ipairs(BuffDuty.selfItemEntries) do
			if not (entry.wellFed or entry.scrolls or entry.elixirs) then
				return true
			end
		end
		return false
	elseif row == "weapons" then
		if BuffDuty.weaponItemEntries and #BuffDuty.weaponItemEntries > 0 then
			return true
		end
		local _, class = UnitClass("player")
		for _, entry in ipairs(BuffDuty.weaponEntries or {}) do
			if entry.row.class == class then
				return true
			end
		end
		return false
	end
	return true
end

-- selfRefresh values only say on or off (a stored 3 or 5 is just on); the category's Show has the timing.
function BuffDuty.SelfItemOn(key)
	local when = ns.db.global.buffWindow.selfRefresh[key]
	return when ~= nil and when ~= Data.SELF_REFRESH_OFF
end

function BuffDuty.SetSelfItemOn(key, value)
	ns.db.global.buffWindow.selfRefresh[key] = value and Data.SELF_REFRESH_MISSING or Data.SELF_REFRESH_OFF
end

-- A pick-one family (the druid forms): `key` goes on and the rest of the family off; nil picks none.
function BuffDuty.PickSelfItem(entries, family, key)
	for _, entry in ipairs(entries) do
		if entry.pickOne == family then
			BuffDuty.SetSelfItemOn(entry.key, entry.key == key)
		end
	end
end
ns.PopulateBuffDutyAudience = PopulateBuffDutyAudience

--------------------------------------------------------------------------------
-- Weapon Choices
--------------------------------------------------------------------------------

-- One never set reads as ticked, so a new row reaches every player on.
function BuffDuty.WeaponChoiceOn(list, handKey, key)
	local hand = list[handKey]
	return not hand or hand[key] ~= false
end
