local _, ns = ...
local Data = ns.Data

--[[
    The Buff Window's settings: who each buff is offered to, when each self
    buff shows, and the weapon choices and timing, seeded into the profile
    from each row's default and cleaned of values the dropdowns don't offer.
]]

local BuffWindow = ns.BuffWindow
local lookup = BuffWindow.lookup
local selfLookup = BuffWindow.selfLookup

--------------------------------------------------------------------------------
-- Audience Settings
--------------------------------------------------------------------------------

--[[
    Seed what the player never set from the row's default, drop any value that isn't a choice the dropdown
    offers, and never touch a key this client lacks. Re-run on profile changes.
]]
local function PopulateBuffWindowAudience()
	local tankWhen = ns.db.global.buffWindow.tankWhen

	-- MIGRATION (remove after 2026-11-18): the 2026.10.19.A pets toggle and its "when" became tankWhen.PET.
	local legacy = ns.db.global.buffWindow
	if legacy.petsAsTanks ~= nil or legacy.petsAsTanksWhen ~= nil then
		if legacy.petsAsTanks == false then
			tankWhen[Data.TANK_WHEN_PET] = Data.TANK_WHEN.NEVER
		elseif legacy.petsAsTanksWhen == Data.TANK_WHEN.ALWAYS then
			tankWhen[Data.TANK_WHEN_PET] = Data.TANK_WHEN.ALWAYS
		end
		legacy.petsAsTanks = nil
		legacy.petsAsTanksWhen = nil
	end

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
	local stone = BuffWindow.soulstoneEntry
	if stone and selfRefresh[stone.key] == nil then
		selfRefresh[stone.key] = stone.row.default
	end

	--[[
	    MIGRATION (remove after 2026-11-21): self buffs whose default went from 5
	    minutes to 3 move a stored 5 to 3, and the Soulstone moves When Missing
	    to 3. Each key moves once, recorded in selfRefreshMigrated, so a player
	    who picks 5 again keeps it. A key this client lacks waits for the client
	    that has it: Classic Era and Season of Discovery share these settings.
	]]
	local migrated = ns.db.global.buffWindow.selfRefreshMigrated
	for key, entry in pairs(selfLookup) do
		if not migrated[key] then
			if entry.row.default == 3 and selfRefresh[key] == 5 then
				selfRefresh[key] = 3
			end
			migrated[key] = true
		end
	end
	if stone and not migrated[stone.key] then
		if selfRefresh[stone.key] == Data.SELF_REFRESH_MISSING then
			selfRefresh[stone.key] = 3
		end
		migrated[stone.key] = true
	end

	--[[
	    Weapon choices are ticked or not per hand (true or false; unset reads
	    as ticked, WeaponChoiceOn), so anything else stored is dropped. A
	    stored id this client has no row for is kept: Classic Era and Season
	    of Discovery share these settings, and an Occult Poison ticked on one is
	    the other's to keep. The one timing falls back to the default when it
	    isn't a choice the dropdown offers.
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
	if not tContains(Data.WEAPON_REFRESH_CHOICES, settings.weaponRefresh) then
		settings.weaponRefresh = Data.WEAPON_REFRESH_DEFAULT
	end
end
ns.PopulateBuffWindowAudience = PopulateBuffWindowAudience

--------------------------------------------------------------------------------
-- Weapon Choices
--------------------------------------------------------------------------------

--[[
    Whether a weapon choice is ticked for a hand. `list` is weaponPicks
    (keyed "ROGUE_MAIN" and so on) or weaponItems (keyed "MAIN" or "OFF");
    one never set reads as ticked, so a new row reaches every player on.
]]
function BuffWindow.WeaponChoiceOn(list, handKey, key)
	local hand = list[handKey]
	return not hand or hand[key] ~= false
end
