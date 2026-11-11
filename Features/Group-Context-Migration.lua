local _, ns = ...

--------------------------------------------------------------------------------
-- Group Settings onto Checkboxes
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-12-11)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    three pieces together:
      1. this file
      2. its line in all four flavor TOCs (Good-to-Go_Vanilla.toc, _TBC.toc,
         _Camelot.toc and _Mists.toc)
      3. the ns.MoveGroupSettingsOntoCheckboxes() call in Features/Core.lua
]]

--[[
    Every setting that turns on or off by group became one checkbox per group
    context (Solo, Party, Raid, Battleground; ns.GROUP_CONTEXTS). What each
    setting did before carries over for battlegrounds, which used to count as
    a raid, and as a party or raid. Arenas now follow Battleground: they used
    to count as a party, and no single old answer covers both.

    Buff Duty's When to Show, account-wide: showSolo, showParty and showRaid
    become showIn's solo, party and raid, and Battleground takes Raid's
    answer. showSoloWhere and the rest move into showWhere unchanged.

    Each consumable's when-to-use dropdown (<prefix>Mode), in every profile:
      always    every box ticked
      solo      Solo only
      party     Party, Raid and Battleground ("When in a Party or Raid")
      raid      Raid and Battleground
      leveling  every box ticked, level filter While Leveling
      maxlevel  every box ticked, level filter At Max Level
    An unknown mode reads as always, as ns.IsModeActive read it.

    AceDB saves only what differs from the defaults, so an old key is present
    only when the player set it, and a missing one meant the old default,
    which the new defaults keep meaning. The active tables already carry the
    new defaults; a profile nobody has loaded yet gets only what differs, and
    AceDB fills in the rest when it loads. Each old key goes once it has moved,
    so a second login changes nothing.

    Called from InitializeDatabase in Features/Core.lua, right after AceDB
    loads and before any profile is copied onto another, so every copy is
    already in the new shape.
]]

local BUFF_DUTY_SHOW = {
	solo = { "showSolo", "showSoloWhere" },
	party = { "showParty", "showPartyWhere" },
	raid = { "showRaid", "showRaidWhere" },
}

local USE_WHEN_PREFIXES = { "buffFood", "scrolls", "petBuffFood", "conjuredFirst" }

-- The boxes each old mode leaves unticked.
local UNTICKED_BY_MODE = {
	solo = { "party", "raid", "battleground" },
	party = { "solo" },
	raid = { "solo", "party" },
}

local function SubTable(parent, key)
	local child = rawget(parent, key)
	if type(child) ~= "table" then
		child = {}
		rawset(parent, key, child)
	end
	return child
end

local function MoveBuffDutyShow(buffWindow)
	if type(buffWindow) ~= "table" then
		return
	end
	for context, keys in pairs(BUFF_DUTY_SHOW) do
		local show, where = rawget(buffWindow, keys[1]), rawget(buffWindow, keys[2])
		if show == false then
			SubTable(buffWindow, "showIn")[context] = false
			if context == "raid" then
				SubTable(buffWindow, "showIn").battleground = false
			end
		end
		if type(where) == "string" then
			SubTable(buffWindow, "showWhere")[context] = where
		end
		rawset(buffWindow, keys[1], nil)
		rawset(buffWindow, keys[2], nil)
	end
end

local function MoveUseWhen(profile)
	if type(profile) ~= "table" then
		return
	end
	for _, prefix in ipairs(USE_WHEN_PREFIXES) do
		local modeKey = prefix .. "Mode"
		local mode = rawget(profile, modeKey)
		if mode ~= nil then
			for _, context in ipairs(UNTICKED_BY_MODE[mode] or {}) do
				SubTable(profile, prefix .. "In")[context] = false
			end
			local level = (mode == "leveling" or mode == "maxlevel") and mode or "any"
			rawset(profile, prefix .. "Level", level)
			rawset(profile, modeKey, nil)
		end
	end
end

function ns.MoveGroupSettingsOntoCheckboxes()
	local saved = ns.db.sv
	if type(saved.global) == "table" then
		MoveBuffDutyShow(rawget(saved.global, "buffWindow"))
	end
	if type(saved.profiles) == "table" then
		for _, profile in pairs(saved.profiles) do
			MoveUseWhen(profile)
		end
	end
end
