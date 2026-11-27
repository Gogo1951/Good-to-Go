local _, ns = ...
local L = ns.L
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    The standalone Rank Sentinel add-on brought home (MIT, Copyright (c) 2021
    Gogo1951; GogoWatch before that).

    Each file hands its handlers here through ns.SetRankWatchHandler, so one
    module subscribes everything and one switch releases it.
    Rank-Watch-Level-Up.lua runs its own module and switch.
]]

local MODULE = "RankWatch"
local handlers = {}

function ns.SetRankWatchHandler(event, handler)
	handlers[event] = handler
end

-- Unit arguments after `enabled` filter it.
function ns.SetRankWatchEvent(event, enabled, ...)
	ns.SetModuleEvent(MODULE, event, enabled, ...)
end

ns.RegisterEventModule(MODULE, function(event, ...)
	local handler = handlers[event]
	if handler then
		handler(...)
	end
end)

function ns.RankWatchSettings()
	local settings = ns.db and ns.db.global.rankWatch
	-- MIGRATION (remove after 2026-12-08): Max-Level Characters Only gave way to the two grace periods.
	if settings and settings.maxLevelOnly ~= nil then
		settings.maxLevelOnly = nil
	end
	return settings
end

--------------------------------------------------------------------------------
-- The Standalone Add-on
--------------------------------------------------------------------------------

--[[
    Two copies watching one group would report every low rank twice, so
    while the standalone add-on runs (until the offered reload), Good to Go's
    stays quiet.
]]
local standaloneTitle

local function FindStandalone()
	for _, folder in ipairs(RANK_WATCH.STANDALONE_FOLDERS) do
		if C_AddOns.IsAddOnLoaded(folder) then
			return C_AddOns.GetAddOnMetadata(folder, "Title") or folder
		end
	end
	return nil
end

function ns.RankWatchStandaloneTitle()
	return standaloneTitle
end

--[[
    MIGRATION (remove after 2026-12-08)
    A player who ran the standalone add-on keeps their choices: once, in a session where it runs (the client
    loads its saved variables only then), its settings for this character are copied in. Its on/off switch is
    handled apart, by TakeOverFromStandalone.
]]
local function StandaloneProfile()
	local db = RankSentinelDB
	if type(db) ~= "table" or type(db.profiles) ~= "table" then
		return nil
	end
	local keys = type(db.profileKeys) == "table" and db.profileKeys or {}
	local profileName = keys[ns.GetCharacterProfileName()]
		or keys[UnitName("player") .. " - " .. GetRealmName()]
		or next(db.profiles)
	return profileName and db.profiles[profileName]
end

local function ImportStandaloneSettings(settings)
	if settings.importedStandalone or not standaloneTitle then
		return
	end
	local profile = StandaloneProfile()
	if type(profile) ~= "table" then
		return
	end
	settings.importedStandalone = true
	if profile.whisper ~= nil then
		settings.whisper = profile.whisper and true or false
	end
	if profile.quietMode ~= nil then
		settings.print = not profile.quietMode
	end
	for guid, name in pairs(type(profile.ignoredPlayers) == "table" and profile.ignoredPlayers or {}) do
		if type(guid) == "string" and type(name) == "string" then
			settings.ignoredPlayers[guid] = name
		end
	end
	for index in pairs(type(profile.announcedSpells) == "table" and profile.announcedSpells or {}) do
		if type(index) == "string" then
			settings.announced[index] = true
		end
	end
end

--[[
    Every login the standalone add-on runs, not once, so a player who turns
    it back on is moved over again; one who had switched it off keeps Rank
    Watch as it was.
]]
local function TakeOverFromStandalone(settings)
	if not standaloneTitle then
		return
	end
	local profile = StandaloneProfile()
	if type(profile) == "table" and profile.enable == false then
		return
	end
	settings.enabled = true
end

--------------------------------------------------------------------------------
-- On and Off
--------------------------------------------------------------------------------

-- On, and the standalone add-on not running.
function ns.IsRankWatchActive()
	local settings = ns.RankWatchSettings()
	return settings ~= nil and settings.enabled and not standaloneTitle
end

-- The detection file the TOC lists subscribes its own (ns.SyncRankWatchDetection).
local EVENTS = {
	"CHAT_MSG_ADDON",
	"GROUP_ROSTER_UPDATE",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_ALIVE",
	"PLAYER_UNGHOST",
	"CHAT_MSG_WHISPER", -- a group member's "Opt Out" (Rank-Watch-Check.lua)
}

function ns.SyncRankWatchEvents()
	local active = ns.IsRankWatchActive()
	for _, event in ipairs(EVENTS) do
		ns.SetModuleEvent(MODULE, event, active)
	end
	ns.SyncRankWatchDetection(active)
	ns.SyncRankWatchCluster(active)
	if not active then
		ns.ClearRankWatchQueue()
	end
end

function ns.SetRankWatchEnabled(value)
	local settings = ns.RankWatchSettings()
	if not settings then
		return
	end
	settings.enabled = value and true or false
	if settings.enabled and standaloneTitle then
		ns:PrintMessage(L["RANK_WATCH_STANDALONE"]:format(standaloneTitle))
	end
	ns.SyncRankWatchEvents()
	ns.RefreshSettings()
end

--------------------------------------------------------------------------------
-- Ignored Players
--------------------------------------------------------------------------------

function ns.RankWatchIgnorableUnit(unit)
	if not UnitExists(unit) then
		return nil
	end
	local guid = UnitGUID(unit)
	if not ns.IsPlain(guid) or not ns.IsPlayerGUID(guid) or guid == UnitGUID("player") then
		return nil
	end
	local name = GetUnitName(unit, true)
	if not ns.IsPlain(name) or not name then
		return nil
	end
	local _, class = UnitClass(unit)
	return guid, name, ns.IsPlain(class) and class or nil
end

local POINTED_UNITS = { "target", "focus", "mouseover" }

-- Ignoring case: a group member first, then the target, focus or mouseover.
local function FindNamedUnit(typed)
	local wanted = typed:lower()
	local function Matches(unit)
		local _, name = ns.RankWatchIgnorableUnit(unit)
		return name ~= nil and (name:lower() == wanted or Ambiguate(name, "short"):lower() == wanted)
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		if Matches(prefix .. i) then
			return prefix .. i
		end
	end
	for _, unit in ipairs(POINTED_UNITS) do
		if Matches(unit) then
			return unit
		end
	end
	return nil
end

--[[
    Keyed by GUID, so a typed name resolves only to someone the client can
    see: a group member or a pointed unit.
]]
function ns.IgnoreRankWatchPlayer(typed)
	local settings = ns.RankWatchSettings()
	if not settings then
		return
	end
	local unit
	if typed == "" then
		unit = "target"
	else
		unit = FindNamedUnit(typed)
	end
	local guid, name, class
	if unit then
		guid, name, class = ns.RankWatchIgnorableUnit(unit)
	end
	if not guid then
		if typed == "" then
			ns:PrintMessage(
				L["RANK_WATCH_IGNORE_NO_TARGET"]:format(ns.GetColor("INFO") .. L["RANK_WATCH_IGNORE_COMMAND"] .. "|r")
			)
		else
			ns:PrintMessage(L["RANK_WATCH_IGNORE_NOT_FOUND"]:format(typed))
		end
		return
	end
	settings.ignoredPlayers[guid] = name
	settings.ignoredClasses[guid] = class
	ns:PrintMessage(L["RANK_WATCH_IGNORE_ADDED"]:format(ns.ClassColoredName(name, class)))
	ns.RefreshSettings()
end

--------------------------------------------------------------------------------
-- Login
--------------------------------------------------------------------------------

-- As the standalone add-on does, so fixed data reports again.
local function ForgetOnNewVersion(settings)
	if settings.announcedVersion ~= ns.Version then
		wipe(settings.announced)
		settings.announcedVersion = ns.Version
	end
end

--[[
    Reset Profile reaches these too (a README-Notes exception): they are
    account-wide, so AceDB's profile reset never would. Kept: Ignored Players
    (built one name at a time), the casts already reported, and the
    migration's bookkeeping.
]]
local RESET_KEYS = {
	"enabled",
	"whisper",
	"print",
	"graceMaxLevel",
	"graceLeveling",
	"levelUpAlerts",
	"levelUpAlertsPast",
	"levelUpAlertsPet",
	"levelUpAlertsPetPast",
}
local resetListener = {}

function resetListener.OnProfileReset()
	local settings = ns.RankWatchSettings()
	local defaults = ns.DATABASE_DEFAULTS.global.rankWatch
	for _, key in ipairs(RESET_KEYS) do
		settings[key] = defaults[key]
	end
	wipe(settings.untracked)
	ns.SyncRankWatchEvents()
	ns.RefreshSettings()
end

local function OnPlayerLogin()
	local settings = ns.RankWatchSettings()
	standaloneTitle = FindStandalone()
	ImportStandaloneSettings(settings) -- MIGRATION (remove after 2026-12-08)
	--[[
	    MIGRATION (remove after 2026-12-15): the opt-out number gave way to a whispered "Opt Out", offered once a
	    session. The saved list of players offered the number goes, and an offer the player wrote around {code}
	    goes back to the default, since it would tell people to send a number that no longer works.
	]]
	settings.optOutOffered = nil
	if type(settings.optOutMessage) == "string" and settings.optOutMessage:find("{code}", 1, true) then
		settings.optOutMessage = nil
	end
	TakeOverFromStandalone(settings)
	ForgetOnNewVersion(settings)
	ns.BuildRankWatchLookups()
	ns.ResetRankWatchSession()
	if settings.enabled and standaloneTitle then
		ns:PrintMessage(L["RANK_WATCH_STANDALONE"]:format(standaloneTitle))
	end
	ns.SyncRankWatchEvents()
	ns.db.RegisterCallback(resetListener, "OnProfileReset")
end
handlers.PLAYER_LOGIN = OnPlayerLogin
ns.SetModuleEvent(MODULE, "PLAYER_LOGIN", true)
