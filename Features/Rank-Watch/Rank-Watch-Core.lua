local _, ns = ...
local L = ns.L
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch, the standalone Rank Sentinel add-on brought home (MIT, Copyright (c) 2021 Gogo1951; GogoWatch before
    that): it watches the group for a spell cast at a rank lower than the caster could have, and lets them know a
    higher rank is waiting at their trainer. Off until the player turns it on.

    The files, in load order:
      Rank-Watch-Core.lua        Settings, the event module and its subscriptions, the standalone add-on
      Rank-Watch-Lookups.lua     ns.RANK_WATCH_ABILITIES as ladders, joined by ns.SPELL_GROUPS
      Rank-Watch-Check.lua       Whether a cast was low, and the whisper or print that says so
      Rank-Watch-Cluster.lua     The RANKSENTINEL add-on messages that pick one whisperer per group
      Rank-Watch-Detection-Combat-Log.lua   Casts from the combat log, in every TOC but WoW Forever's
      Rank-Watch-Detection-Forever.lua      Casts on WoW Forever: the player's own, auras and the damage meter

    Each file hands its event handlers to this one through ns.SetRankWatchHandler, the pattern Buff Duty uses,
    so one module subscribes everything and one switch releases it.
]]

local MODULE = "RankWatch"
local handlers = {}

function ns.SetRankWatchHandler(event, handler)
	handlers[event] = handler
end

-- Subscribes or releases one of Rank Watch's events; unit arguments after `enabled` filter it.
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
    Two copies watching one group would report every low rank twice, so while the standalone Rank Sentinel runs,
    Good to Go's stays quiet, and says so once a session when the player has it turned on. Good to Go replaces it,
    so Features/Core.lua turns it off at login (ns.LEGACY_ADDONS) and offers a reload; it runs on until then, and
    Rank Watch is switched on to take over after it (TakeOverFromStandalone).
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

-- The standalone add-on's title while it runs, else nil.
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
    Rank Watch takes over the watching: in every session where the standalone add-on runs, which is a session
    where Features/Core.lua turns it off, Rank Watch is switched on, so a player who ran it isn't left with
    nothing watching after the reload. A player who had switched Rank Sentinel off keeps Rank Watch as it was.
    This runs every such login, not once, so a player who turns Rank Sentinel back on is moved over again.
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

-- Whether Rank Watch is watching right now: on, and the standalone add-on not running.
function ns.IsRankWatchActive()
	local settings = ns.RankWatchSettings()
	return settings ~= nil and settings.enabled and not standaloneTitle
end

-- The events every flavor needs; the detection file its TOC lists subscribes its own (ns.SyncRankWatchDetection).
local EVENTS = {
	"CHAT_MSG_ADDON",
	"GROUP_ROSTER_UPDATE",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_ALIVE",
	"PLAYER_UNGHOST",
}

-- Every chat a player can say their opt-out number in (Rank-Watch-Check.lua listens to them all).
ns.RANK_WATCH_CHAT_EVENTS = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_YELL",
}

function ns.SyncRankWatchEvents()
	local active = ns.IsRankWatchActive()
	for _, event in ipairs(EVENTS) do
		ns.SetModuleEvent(MODULE, event, active)
	end
	for _, event in ipairs(ns.RANK_WATCH_CHAT_EVENTS) do
		ns.SetModuleEvent(MODULE, event, active)
	end
	ns.SyncRankWatchDetection(active)
	ns.SyncRankWatchCluster(active)
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
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.RankWatch)
end

--------------------------------------------------------------------------------
-- Ignored Players
--------------------------------------------------------------------------------

-- A unit's GUID, full name and class token when it is another player who can be ignored, else nil.
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

-- The unit a typed name belongs to, ignoring case: a group member first, then the target, focus or mouseover.
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
    /gtg ignore Name adds that player to Ignored Players, and /gtg ignore alone adds the target. The list is
    keyed by GUID, so a typed name resolves only to someone the client can see: a group member or a pointed unit.
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
			ns:PrintMessage(L["RANK_WATCH_IGNORE_NO_TARGET"])
		else
			ns:PrintMessage(L["RANK_WATCH_IGNORE_NOT_FOUND"]:format(typed))
		end
		return
	end
	settings.ignoredPlayers[guid] = name
	settings.ignoredClasses[guid] = class
	ns:PrintMessage(L["RANK_WATCH_IGNORE_ADDED"]:format(ns.ClassColoredName(name, class)))
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.RankWatchIgnored)
end

--------------------------------------------------------------------------------
-- Login
--------------------------------------------------------------------------------

-- Reported casts are forgotten on a new version, as the standalone add-on forgets them, so fixed data reports again.
local function ForgetOnNewVersion(settings)
	if settings.announcedVersion ~= ns.Version then
		wipe(settings.announced)
		settings.announcedVersion = ns.Version
	end
end

--[[
    Reset Profile on the Profiles panel puts Rank Watch back to its defaults too: switched off, both messages on,
    the default grace periods, and every rank on Tracked Abilities following the data again. Rank Watch's settings
    are account-wide, so AceDB's reset, which clears the profile alone, never reaches them by itself. Kept: the
    Ignored Players list (a list the player built, one name at a time), the casts already reported, the
    players already offered the opt-out, and the migration's own bookkeeping.
]]
local RESET_KEYS = { "enabled", "whisper", "print", "graceMaxLevel", "graceLeveling" }
local resetListener = {}

function resetListener.OnProfileReset()
	local settings = ns.RankWatchSettings()
	local defaults = ns.DATABASE_DEFAULTS.global.rankWatch
	for _, key in ipairs(RESET_KEYS) do
		settings[key] = defaults[key]
	end
	wipe(settings.untracked)
	ns.SyncRankWatchEvents()
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end
end

local function OnPlayerLogin()
	local settings = ns.RankWatchSettings()
	standaloneTitle = FindStandalone()
	ImportStandaloneSettings(settings) -- MIGRATION (remove after 2026-12-08)
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
