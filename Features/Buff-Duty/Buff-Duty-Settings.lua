local _, ns = ...
local Data = ns.Data

--[[
    Buff Duty's settings: who each buff is offered to, which self buffs
    show, each category's switch and Show timing, and the weapon choices, seeded into the
    account-wide settings from each row's default and cleaned of values the dropdowns don't offer.
]]

local BuffDuty = ns.BuffDuty
local lookup = BuffDuty.lookup
local selfLookup = BuffDuty.selfLookup

--------------------------------------------------------------------------------
-- Audience Settings
--------------------------------------------------------------------------------

--[[
    Seed what the player never set from the row's default, drop any value that isn't a choice the dropdown
    offers, and never touch a key this client lacks. Re-run on profile changes.
]]
local function PopulateBuffDutyAudience()
	local tankWhen = ns.db.global.buffWindow.tankWhen

	-- A value the Count as Tanks dropdowns don't offer reads as its default again.
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

	--[[
	    When each self buff shows, seeded from the row's default; a value the
	    dropdown doesn't offer is dropped and reseeded.
	]]
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
	--[[
	    A group buff on yourself: the row's selfDefault, or else 3 minutes for
	    one the data offers to everyone and Off for the rest (Tanks and
	    situational buffs), from the row's default, never the player's own
	    audience pick.
	]]
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
	    Weapon choices are ticked or not per hand (true or false; unset reads
	    as ticked, WeaponChoiceOn), so anything else stored is dropped. A
	    stored id this client has no row for is kept: Classic Era and Season
	    of Discovery share these settings, and an Occult Poison ticked on one is
	    the other's to keep.
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

	-- A category's Show timing that isn't a choice falls back to the default; a switch that isn't true or false reads as its default.
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
	--[[
	    Well Fed, Scrolls and Flasks or Elixirs each had a switch of their
	    own on the Self-Buffs list before they were categories; a category
	    never set takes that switch's answer, seeded above from the flavor's
	    default.
	]]
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		local row = entry.wellFed and "food" or entry.scrolls and "scrolls" or entry.elixirs and "elixirs"
		if row and settings.rowOn[row] == nil then
			settings.rowOn[row] = BuffDuty.SelfItemOn(entry.key)
		end
	end

	-- A row's When to Use the dropdown doesn't offer, or a Buff Key answer that isn't one, reads as its default again.
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
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
    Whether a category (one of Data.BUFF_DUTY_ROWS) shows here, by its
    When to Use: always, in any party or raid, or only in a raid. A
    battleground's group is a raid.
]]
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

-- Whether the Cast Next Buff key uses a category's icons.
function BuffDuty.RowOnKey(row)
	return ns.db.global.buffWindow.rowKey[row] ~= false
end

--[[
    A category's Show in Buff Duty switch. Self-Buffs and Weapon Buffs keep
    theirs where they always have, selfEnabled and weaponEnabled; the rest
    in rowOn, where unset reads as on.
]]
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

-- A category's Show timing in seconds: 0 for When Missing.
function BuffDuty.RowShowSeconds(row)
	return (ns.db.global.buffWindow.rowShow[row] or Data.BUFF_DUTY_ROW_SHOW_DEFAULT) * 60
end

-- Whether a category shows Missing Inventory! once its buff is gone and nothing in your bags gives it.
function BuffDuty.RowOut(row)
	return row ~= "self" and ns.db.global.buffWindow.rowOut[row] == true
end

--[[
    Whether this client has anything for a category, so a menu leaves out
    one that could never show: Scrolls where the client has no scroll types,
    Flasks or Elixirs where it has no elixir buffs, Other Buffs where it has
    no consumable of that kind, Weapon Buffs where your class has no
    choices and the client no oils, stones or lures.
]]
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

-- Whether a self buff, group buff on you, the Soulstone or a consumable with a switch of its own is on.
function BuffDuty.SelfItemOn(key)
	local when = ns.db.global.buffWindow.selfRefresh[key]
	return when ~= nil and when ~= Data.SELF_REFRESH_OFF
end

-- Turn one on or off. On stores When Missing, a value that reads as on; the category's Show has the timing.
function BuffDuty.SetSelfItemOn(key, value)
	ns.db.global.buffWindow.selfRefresh[key] = value and Data.SELF_REFRESH_MISSING or Data.SELF_REFRESH_OFF
end
ns.PopulateBuffDutyAudience = PopulateBuffDutyAudience

--------------------------------------------------------------------------------
-- Weapon Choices
--------------------------------------------------------------------------------

--[[
    Whether a weapon choice is ticked for a hand. `list` is weaponPicks
    (keyed "ROGUE_MAIN" and so on) or weaponItems (keyed "MAIN" or "OFF");
    one never set reads as ticked, so a new row reaches every player on.
]]
function BuffDuty.WeaponChoiceOn(list, handKey, key)
	local hand = list[handKey]
	return not hand or hand[key] ~= false
end
