local ADDON_NAME, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
    The dispatcher and Diagnostics' Event Registration check both read this
    list, so the two can't drift. A name missing here stops the load (and
    fails Tests/Run.lua first).
]]
ns.EVENT_NAMES = {
	"ACTIONBAR_SLOT_CHANGED",
	"ADDON_LOADED",
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"BANKFRAME_OPENED",
	"CHAT_MSG_ADDON",
	"CHAT_MSG_WHISPER",
	"GET_ITEM_INFO_RECEIVED",
	"GROUP_ROSTER_UPDATE",
	"ITEM_PUSH",
	"MAIL_CLOSED",
	"MAIL_FAILED",
	"MAIL_INBOX_UPDATE",
	"MAIL_SHOW",
	"MAIL_SUCCESS",
	"MERCHANT_CLOSED",
	"MERCHANT_SHOW",
	"PET_BAR_UPDATE",
	"PLAYER_ALIVE",
	"PLAYER_CONTROL_GAINED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_EQUIPMENT_CHANGED",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_LOGOUT",
	"PLAYER_MONEY",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_UNGHOST",
	"PLAYER_UPDATE_RESTING",
	"QUEST_LOG_UPDATE",
	"READY_CHECK",
	"REPLACE_ENCHANT",
	"SKILL_LINES_CHANGED",
	"SPELL_DATA_LOAD_RESULT",
	"SPELL_UPDATE_COOLDOWN",
	"SPELLS_CHANGED",
	"TRAINER_SHOW",
	"TRAINER_UPDATE",
	"UI_ERROR_MESSAGE",
	"UNIT_AURA",
	"UNIT_FLAGS",
	"UNIT_INVENTORY_CHANGED",
	"UNIT_LEVEL",
	"UNIT_PET",
	"UNIT_POWER_UPDATE",
	"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_TARGET",
	"UPDATE_BINDINGS",
	"UPDATE_MACROS",
	"UPDATE_MOUSEOVER_UNIT",
	"ZONE_CHANGED_NEW_AREA",
}

-- Forever has a combat log, but registering COMBAT_LOG_EVENT_UNFILTERED there raises ADDON_ACTION_FORBIDDEN.
if ns.FLAVOR ~= "Camelot" then
	table.insert(ns.EVENT_NAMES, "COMBAT_LOG_EVENT_UNFILTERED")
end

-- Classic Era has no focus, and registering an event its client lacks throws.
if ns.FLAVOR ~= "Vanilla" then
	table.insert(ns.EVENT_NAMES, "PLAYER_FOCUS_CHANGED")
end

local KNOWN_EVENTS = {}
for _, event in ipairs(ns.EVENT_NAMES) do
	KNOWN_EVENTS[event] = true
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

--[[
    One frame for the whole add-on, so the diagnostics event log taps
    everything once. Each event registers once, unit-filtered only while every
    subscriber filters to the same two units or fewer.
]]
local eventFrame = CreateFrame("Frame")
local modules = {}
local modulesByName = {}

-- The lifecycle events Core handles itself, before any module, so they stay registered whoever subscribes.
local CORE_EVENTS = { PLAYER_LOGIN = true, PLAYER_ENTERING_WORLD = true, PLAYER_LOGOUT = true }

function ns.RegisterEventModule(name, dispatch)
	local module = { name = name, dispatch = dispatch, events = {} }
	modules[#modules + 1] = module
	modulesByName[name] = module
end

local function RefreshRegistration(event)
	local unfiltered, wanted = CORE_EVENTS[event] or false, CORE_EVENTS[event] or false
	local units, seen = {}, {}
	for _, module in ipairs(modules) do
		local subscription = module.events[event]
		if subscription == true then
			wanted, unfiltered = true, true
		elseif subscription then
			wanted = true
			for unit in pairs(subscription) do
				if not seen[unit] then
					seen[unit] = true
					units[#units + 1] = unit
				end
			end
		end
	end
	eventFrame:UnregisterEvent(event)
	if not wanted then
		return
	end
	if unfiltered or #units > 2 then
		eventFrame:RegisterEvent(event)
	else
		eventFrame:RegisterUnitEvent(event, unpack(units))
	end
end

-- Unit arguments after `enabled` make the subscription unit-filtered.
function ns.SetModuleEvent(name, event, enabled, ...)
	assert(KNOWN_EVENTS[event], "Event missing from ns.EVENT_NAMES: " .. tostring(event))
	local module = assert(modulesByName[name], "Unknown event module: " .. tostring(name))
	if not enabled then
		module.events[event] = nil
	elseif select("#", ...) > 0 then
		local units = {}
		for index = 1, select("#", ...) do
			units[select(index, ...)] = true
		end
		module.events[event] = units
	else
		module.events[event] = true
	end
	RefreshRegistration(event)
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

--[[
    Trap: AceDB reads the character's name once, as the newest copy among the
    enabled add-ons loads, which can be before the client names the
    character, so every such login would share the placeholder's profile. By
    PLAYER_LOGIN the name is known, so the character goes on the profile saved
    under its real name; logout saves under it and drops the placeholder. An
    older AceDB reading Forever's first name alone is caught the same way.
]]
local realProfileKey

local function UseOwnProfileWhenUnnamed()
	local profileKey = ns.db.keys.char
	local ownProfileKey = ns.GetCharacterProfileName()
	if not ownProfileKey or profileKey == ownProfileKey or ns.SplitCharacterProfileName(profileKey) then
		return
	end
	realProfileKey = ownProfileKey
	ns.db:SetProfile(ns.db.sv.profileKeys[ownProfileKey] or ownProfileKey)
end

local function SaveProfileChoiceWhenUnnamed()
	if not realProfileKey then
		return
	end
	local profileKeys = ns.db.sv.profileKeys
	profileKeys[realProfileKey] = ns.db:GetCurrentProfile()
	profileKeys[ns.db.keys.char] = nil
end

--[[
    MIGRATION (remove after 2026-12-03)
    The settings saved before the rename to Good to Go, under
    ns.OLD_SAVED_VARIABLES_NAME, become this add-on's table, and the old one is
    emptied so it is no longer written. They move only while this add-on's own
    table is missing or empty; when both hold settings, neither is touched.
    The client reads the old table only from Good-to-Go.lua, so a player's
    Bags-Buffs-Buttons.lua must be renamed to that first.
]]
local function MoveRenamedSettings()
	local old = _G[ns.OLD_SAVED_VARIABLES_NAME]
	if type(old) ~= "table" then
		return
	end
	local current = _G[ns.SAVED_VARIABLES_NAME]
	if current ~= nil and (type(current) ~= "table" or next(current) ~= nil) then
		return
	end
	_G[ns.SAVED_VARIABLES_NAME] = old
	_G[ns.OLD_SAVED_VARIABLES_NAME] = nil
end

--[[
    AceDB keys a character "Name - Realm" on realm clients and "First Last" on
    Forever, so a key shaped the other way came from a copied WTF folder: its
    char section, profile choice and (unless still in use) its profile go.
]]
local REALM_KEY_SEPARATOR = " - "

--[[
    MIGRATION (remove after 2026-12-08, with Default-Profile-Migration.lua)
    One "Name - Realm" shape is Forever's own: an older AceDB's name for a
    Forever character, its first name and the rule set ("Gogodruid - PvE").
    Forever's Older Names in that file reads it after this prune, and every
    character on the account takes its copy at its own login, so every rule
    set's keys stay, not just this one's. These are the vendored AceDB's own
    rule-set names. Once this comes out, the next login prunes them.
]]
local FOREVER_RULE_SETS = { Hardcore = true, ["RP-PvP"] = true, RP = true, PvP = true, PvE = true }

---@param characterKey string
---@return boolean
local function IsOlderForeverKey(characterKey)
	local firstName, ruleSet = characterKey:match("^(%S+) %- (.+)$")
	return firstName ~= nil and FOREVER_RULE_SETS[ruleSet] == true
end

---@param characterKey any
---@param realmClient boolean
---@return boolean
local function IsOtherClientKey(characterKey, realmClient)
	if type(characterKey) ~= "string" then
		return true
	end
	-- MIGRATION (remove after 2026-12-08)
	if not realmClient and IsOlderForeverKey(characterKey) then
		return false
	end
	return (characterKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil) ~= realmClient
end

---@param sv table # the saved table, or one of its namespaces
---@param realmClient boolean
---@param profilesInUse table<string, boolean>
---@return nil
local function PruneSavedTable(sv, realmClient, profilesInUse)
	local pruned = {}
	for _, section in ipairs({ "char", "profileKeys" }) do
		local characters = sv[section]
		if type(characters) == "table" then
			for characterKey in pairs(characters) do
				if IsOtherClientKey(characterKey, realmClient) then
					characters[characterKey] = nil
					pruned[characterKey] = true
				end
			end
		end
	end
	if type(sv.profiles) == "table" then
		for characterKey in pairs(pruned) do
			if not profilesInUse[characterKey] then
				sv.profiles[characterKey] = nil
			end
		end
	end
end

--[[
    The same characters' leftovers on ns.db.global. A Restock List choice is
    keyed by the AceDB name, so the shape test settles it. Inventory Report
    and Currency Replenish records name character and realm apart: a realm
    client's names never hold a space, so a realm client drops every name with
    one; Forever drops a spaceless name only on another realm, so a Forever
    character with no surname here stays.
]]
---@param realmClient boolean
---@return nil
local function PruneOtherClientGlobals(realmClient)
	local global = ns.db.global
	local listChoices = type(global.restocker) == "table" and global.restocker.listChoices
	if type(listChoices) == "table" then
		for characterKey in pairs(listChoices) do
			if IsOtherClientKey(characterKey, realmClient) then
				listChoices[characterKey] = nil
			end
		end
	end

	-- The Inventory Report's records and Currency Replenish's carry the same name and realm, so one test fits both.
	local realm = GetRealmName()
	local replenish = type(global.currencyReplenish) == "table" and global.currencyReplenish.characters
	for _, records in ipairs({ global.inventory, replenish }) do
		if type(records) == "table" then
			for key, record in pairs(records) do
				if type(record) == "table" and type(record.name) == "string" then
					local hasSurname = record.name:find("%s") ~= nil
					if realmClient and hasSurname or not realmClient and not hasSurname and record.realm ~= realm then
						records[key] = nil
					end
				end
			end
		end
	end
end

---@return nil
local function PruneOtherClientCharacters()
	local currentKey = ns.db.keys and ns.db.keys.char
	local sv = ns.db.sv
	if type(currentKey) ~= "string" or type(sv) ~= "table" then
		return
	end
	local realmClient = currentKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil
	local profilesInUse = { [ns.db.keys.profile or ""] = true }
	for characterKey, profileName in pairs(sv.profileKeys or {}) do
		if not IsOtherClientKey(characterKey, realmClient) then
			profilesInUse[profileName] = true
		end
	end
	PruneSavedTable(sv, realmClient, profilesInUse)
	for _, namespace in pairs(sv.namespaces or {}) do
		if type(namespace) == "table" then
			PruneSavedTable(namespace, realmClient, profilesInUse)
		end
	end
	PruneOtherClientGlobals(realmClient)
end

--[[
    MIGRATION (remove after 2026-12-13)
    An account already whispering (Buff Duty asks or Rank Watch whispers on)
    keeps the client's language as its message language. Reads the raw saved
    table before AceDB fills in defaults, since a value at its default is
    absent there. Stamped once per account (messageLanguageMigrated), so a
    later pick of English is never switched back.
]]
local function MigrateMessageLanguage()
	local sv = _G[ns.SAVED_VARIABLES_NAME]
	if type(sv) ~= "table" or next(sv) == nil then
		return
	end
	if sv.global ~= nil and type(sv.global) ~= "table" then
		return
	end
	local global = sv.global or {}
	if global.messageLanguageMigrated or global.messageLanguage ~= nil then
		return
	end
	local locale = GetLocale()
	if locale == ns.Data.DEFAULT_MESSAGE_LANGUAGE or not ns.GetMessageLanguageInfo(locale) then
		return
	end
	local buffWindow = type(global.buffWindow) == "table" and global.buffWindow or {}
	local rankWatch = type(global.rankWatch) == "table" and global.rankWatch or {}
	local asking = buffWindow.enabled ~= false and buffWindow.askOtherClasses ~= false
	local tipping = rankWatch.enabled == true and rankWatch.whisper ~= false
	if asking or tipping then
		global.messageLanguage = locale
		sv.global = global
	end
end

--[[
    MIGRATION (remove after 2026-12-19)
    Poisons is off by default for new players. An existing account's Poisons
    left at the old default (absent from the raw saved table) gets an explicit
    true, so the new default doesn't pull a macro off someone's bar. A table
    holding only legacyImported is a fresh install. Stamped once per account
    (poisonsDefaultMigrated), so a later uncheck stays.
]]
local function HasSavedSettings(sv)
	for key in pairs(sv) do
		if key ~= "global" then
			return true
		end
	end
	for key in pairs(type(sv.global) == "table" and sv.global or {}) do
		if key ~= "legacyImported" then
			return true
		end
	end
	return false
end

local function KeepPoisonsMacro()
	local sv = _G[ns.SAVED_VARIABLES_NAME]
	if type(sv) ~= "table" or not HasSavedSettings(sv) then
		return
	end
	if sv.global ~= nil and type(sv.global) ~= "table" then
		return
	end
	local global = sv.global or {}
	if global.poisonsDefaultMigrated then
		return
	end
	if global.enabledMacros ~= nil and type(global.enabledMacros) ~= "table" then
		return
	end
	local enabled = global.enabledMacros or {}
	if enabled["Poisons"] == nil then
		enabled["Poisons"] = true
		global.enabledMacros = enabled
		sv.global = global
	end
end

--[[
    Per-Character: every character gets a profile of its own. What the whole
    account shares lives on ns.db.global, each with its reason in
    Data/Default-Settings.lua.
]]
local function InitializeDatabase()
	-- MIGRATION (remove after 2026-12-03)
	MoveRenamedSettings()

	--[[
	    MIGRATION (remove after 2026-12-13): Send Messages In keeps a whispering account's client language. Before
	    the legacy import, so only what Good to Go itself saved counts.
	]]
	MigrateMessageLanguage()

	-- MIGRATION (remove after 2026-12-08)
	ns.ImportLegacySettings()

	-- MIGRATION (remove after 2026-12-19): an account that had Good to Go, or Connoisseur before it, keeps its Poisons macro.
	KeepPoisonsMacro()

	ns.db = LibStub("AceDB-3.0"):New(ns.SAVED_VARIABLES_NAME, ns.DATABASE_DEFAULTS)
	PruneOtherClientCharacters()
	UseOwnProfileWhenUnnamed()

	-- MIGRATION (remove after 2026-12-13): stamps the account so MigrateMessageLanguage runs once, fresh installs included.
	ns.db.global.messageLanguageMigrated = true
	-- MIGRATION (remove after 2026-12-19): stamps the account so KeepPoisonsMacro runs once, fresh installs included.
	ns.db.global.poisonsDefaultMigrated = true

	-- MIGRATION (remove after 2026-12-11): group settings onto the Solo / Party / Raid / Battleground checkboxes.
	ns.MoveGroupSettingsOntoCheckboxes()

	--[[
	    MIGRATION (remove after 2026-12-13): every restock reminder back onto Simple, once. Tested for: a /reload
	    doesn't load files added to the TOC since the game started, so after an update with the game running this
	    file's absent until a restart, and the move waits for it.
	]]
	if ns.MoveRestockRemindersOntoSimple then
		ns.MoveRestockRemindersOntoSimple()
	end

	-- MIGRATION (remove after 2026-12-08)
	ns.RetireAutomatedAppreciation()

	-- MIGRATION (remove after 2026-12-08)
	ns.RetireSavedItemCache()

	--[[
	    MIGRATION (remove after 2026-12-08)
	    Before the callbacks below are wired, so their profile switch fires no
	    handler halfway through login. Character-Key-Migration.lua and
	    Default-Profile-Migration.lua list the pieces that come out together.
	]]
	ns.RekeyCharactersByFullName()
	ns.MoveCharactersOntoOwnProfiles()

	for _, message in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
		ns.db.RegisterCallback(ns, message, "ApplyProfile")
	end
end

--[[
    Settings read live update themselves; each feature re-applies what it set
    imperatively (macro bodies, aura tracking). The Restock List in use is the
    character's own choice, not the profile's, so a switch leaves it alone.
]]
function ns:ApplyProfile()
	if ns.ApplyConsumableMacrosProfile then
		ns.ApplyConsumableMacrosProfile()
	end
	if ns.ApplyBuffDutyProfile then
		ns.ApplyBuffDutyProfile()
	end
	if ns.ApplySpellbookProfile then
		ns.ApplySpellbookProfile()
	end
	ns:ApplyMinimapButton()
	ns.RefreshSettings()
end

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------

-- Once per session: PLAYER_ENTERING_WORLD refires on every loading screen.
local welcomePrinted = false

function ns:PrintWelcome()
	if welcomePrinted then
		return
	end
	welcomePrinted = true
	if ns.db.global.showWelcome then
		ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
	end
	-- MIGRATION (remove after 2026-12-08)
	ns.PrintLegacyNotices()
	-- MIGRATION (remove after 2026-12-08): the OfferLegacySteps test, leaving the OfferReplacedReload call.
	if not ns.OfferLegacySteps() then
		ns.OfferReplacedReload()
	end
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

--[[
    The database initializes only at PLAYER_LOGIN, before any module hears it.
    Nothing here is protected, so it runs on a mid-combat login too.
]]
eventFrame:SetScript("OnEvent", function(_, event, ...)
	-- Diagnostics event-log tap; the boolean is read first so logging-off is free.
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, ...)
	end

	if event == "PLAYER_LOGIN" then
		ns.TurnOffReplacedAddons()
		InitializeDatabase()
		ns.RegisterOptionsPanels()
		-- After ns.db: LibDBIcon reads its saved position from it.
		ns.RegisterMinimapIcon()
	elseif event == "PLAYER_ENTERING_WORLD" then
		ns:PrintWelcome()
	elseif event == "PLAYER_LOGOUT" then
		SaveProfileChoiceWhenUnnamed()
	end

	local unit = ...
	for _, module in ipairs(modules) do
		local subscription = module.events[event]
		if subscription == true or (subscription and subscription[unit]) then
			module.dispatch(event, ...)
		end
	end
end)

for event in pairs(CORE_EVENTS) do
	eventFrame:RegisterEvent(event)
end
