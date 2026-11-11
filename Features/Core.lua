local ADDON_NAME, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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
    Every event the add-on uses, in one list. The dispatcher below registers
    from it, and Diagnostics' Event Registration check reads the same list, so
    the two can never drift. Each feature subscribes to the events it handles
    with ns.SetModuleEvent; a name missing here stops the load.
]]
ns.EVENT_NAMES = {
	"ACTIONBAR_SLOT_CHANGED",
	"ADDON_LOADED",
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"BANKFRAME_OPENED",
	"CHAT_MSG_ADDON",
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
	"GET_ITEM_INFO_RECEIVED",
	"GROUP_ROSTER_UPDATE",
	"ITEM_PUSH",
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
	"UNIT_INVENTORY_CHANGED",
	"UNIT_LEVEL",
	"UNIT_PET",
	"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UPDATE_BINDINGS",
	"UPDATE_MACROS",
	"UPDATE_MOUSEOVER_UNIT",
	"ZONE_CHANGED_NEW_AREA",
}

-- Forever has no combat log, and registering COMBAT_LOG_EVENT_UNFILTERED there errors.
if ns.FLAVOR ~= "Camelot" then
	table.insert(ns.EVENT_NAMES, "COMBAT_LOG_EVENT_UNFILTERED")
end

local KNOWN_EVENTS = {}
for _, event in ipairs(ns.EVENT_NAMES) do
	KNOWN_EVENTS[event] = true
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

--[[
    One frame for the whole add-on, so the diagnostics event log captures
    everything from a single tap. Each feature is a module with its own
    dispatcher, handed only the events it subscribed to, in the order the
    modules loaded. A module subscribed with units hears only those units' firings;
    the frame itself registers each event once, unit-filtered only while every
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

--[[
    Subscribes or releases one module's interest in one event. Unit arguments
    after `enabled` make the subscription unit-filtered.
]]
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
-- Replaced Add-ons
--------------------------------------------------------------------------------

--[[
    An add-on Good to Go replaces (ns.REPLACED_ADDONS) that runs alongside it
    rewrites the same macros, each undoing the other. So whenever one is
    running at login, it is turned off for every character and the player is
    offered a reload, since the old copy runs on until then. This outlives the
    settings import below: a player can install Good to Go, or turn the old
    add-on back on, long after the import is gone.
]]
-- Titles of the old add-ons turned off this session.
local turnedOff = {}

local function AddOnTitle(folder)
	return C_AddOns.GetAddOnMetadata(folder, "Title") or folder
end

local function JoinTitles(titles)
	return table.concat(titles, L["LIST_SEPARATOR"])
end

local function TurnOffReplacedAddons()
	for _, folder in ipairs(ns.REPLACED_ADDONS) do
		if C_AddOns.IsAddOnLoaded(folder) then
			C_AddOns.DisableAddOn(folder)
			turnedOff[#turnedOff + 1] = AddOnTitle(folder)
		end
	end
end

StaticPopupDialogs.GOODTOGO_REPLACED_RELOAD = {
	text = L["POPUP_REPLACED_RELOAD"],
	button1 = L["POPUP_REPLACED_RELOAD_ACCEPT"],
	button2 = L["POPUP_REPLACED_LATER"],
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Asked once the player is in the world, after the welcome line.
local function OfferReplacedReload()
	if #turnedOff > 0 then
		StaticPopup_Show("GOODTOGO_REPLACED_RELOAD", JoinTitles(turnedOff))
	end
end

--------------------------------------------------------------------------------
-- Legacy Settings
--------------------------------------------------------------------------------

--[[
    MIGRATION (remove after 2026-12-08)
    Bringing players over from the add-ons this one replaces (ns.LEGACY_ADDONS).
    The client loads an add-on's saved variables only while that add-on is
    turned on, so the import can read them only in a session where it runs:

      turned on   Its settings are copied in at login, before AceDB opens the
                  table, once per add-on. They win key by key over what is
                  here, and keys only this add-on has (the Spellbook's, say)
                  are kept, since the copy can land on a profile that has been
                  played. Restock Lists merge by name. Then every old add-on
                  still running is turned off for all characters, and the
                  player is offered a reload so the old copy stops rewriting
                  the same macros. Those in ns.REPLACED_ADDONS are turned off
                  by TurnOffReplacedAddons above, which stays when this goes;
                  the rest are turned off here.
      turned off  The player is asked whether to bring its settings over.
                  Yes turns it on for this character and reloads, which lands
                  in the case above; No is remembered and never asked again;
                  Escape puts the question off to the next login.
                  While the question is open, the Staples window stays shut
                  (ns.IsLegacyImportPending): an import may be about to fill
                  the Restock List.

    Connoisseur & Restocker's table has this one's shape, profile for profile.
    Macro Spellbook's settings are not brought over; it is only turned off.
    Rank Sentinel is only turned off here too: Rank Watch copies its settings
    itself at login (Features/Rank-Watch/Rank-Watch-Core.lua), in the same
    session, since turning it off takes hold only after a reload.
    Thanks for the Buff is not on the list: it is its own add-on, so it is
    never imported or turned off.
]]
local legacyNotices = {}
local legacyToTurnOn = {}
-- Titles of the old add-ons whose settings were copied in this session.
local legacyCopied = {}

--[[
    What an add-on's entry in ns.db.global.legacyImported holds once its
    settings are in: this number, or "declined" for a player who said no. An
    entry from an earlier import rule (true, from the first version, which
    copied only what was missing and so left a fresh install's starter list in
    place of the player's own) runs the import again under this one.
]]
local LEGACY_IMPORT_VERSION = 2

local function IsSettled(entry)
	return entry == LEGACY_IMPORT_VERSION or entry == "declined"
end

local function CopyTable(source)
	if type(source) ~= "table" then
		return source
	end
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = CopyTable(value)
	end
	return copy
end

-- Every key of source onto target, the source winning; except is a set of keys to leave alone.
local function CopyOver(target, source, except)
	for key, value in pairs(source or {}) do
		if not (except and except[key]) then
			target[key] = CopyTable(value)
		end
	end
end

local LEGACY_IMPORTERS = {
	ConnoisseurDB = function(saved, legacy)
		saved.profiles = saved.profiles or {}
		saved.profileKeys = saved.profileKeys or {}
		saved.global = saved.global or {}
		for name, legacyProfile in pairs(legacy.profiles or {}) do
			if type(legacyProfile) == "table" then
				saved.profiles[name] = saved.profiles[name] or {}
				CopyOver(saved.profiles[name], legacyProfile)
			end
		end
		CopyOver(saved.profileKeys, legacy.profileKeys)
		CopyOver(saved.global, legacy.global, { restocker = true, legacyImported = true })
		local restocker = legacy.global and legacy.global.restocker
		if type(restocker) == "table" then
			saved.global.restocker = saved.global.restocker or {}
			CopyOver(saved.global.restocker, restocker, { lists = true })
			saved.global.restocker.lists = saved.global.restocker.lists or {}
			CopyOver(saved.global.restocker.lists, restocker.lists)
		end
	end,
}

local function LegacyTitle(legacy)
	return AddOnTitle(legacy.folder)
end

local function IsReplacedAddon(folder)
	for _, replaced in ipairs(ns.REPLACED_ADDONS) do
		if replaced == folder then
			return true
		end
	end
	return false
end

-- Whether the player switched the old add-on off, so turning it back on lets this session read its settings.
local function IsInstalledButOff(legacy)
	if C_AddOns.IsAddOnLoaded(legacy.folder) then
		return false
	end
	local _, _, _, _, reason = C_AddOns.GetAddOnInfo(legacy.folder)
	return reason == "DISABLED"
end

local function ImportLegacySettings()
	_G[ns.SAVED_VARIABLES_NAME] = _G[ns.SAVED_VARIABLES_NAME] or {}
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	saved.global = saved.global or {}
	saved.global.legacyImported = saved.global.legacyImported or {}
	local imported = saved.global.legacyImported

	for _, legacy in ipairs(ns.LEGACY_ADDONS) do
		local key = legacy.savedVariables
		if C_AddOns.IsAddOnLoaded(legacy.folder) then
			local legacyTable = key and _G[key]
			if key and not IsSettled(imported[key]) then
				if type(legacyTable) == "table" then
					LEGACY_IMPORTERS[key](saved, legacyTable)
					legacyNotices[#legacyNotices + 1] = L["CHAT_LEGACY_IMPORTED"]:format(LegacyTitle(legacy))
					legacyCopied[#legacyCopied + 1] = LegacyTitle(legacy)
				end
				imported[key] = LEGACY_IMPORT_VERSION
			end
			-- TurnOffReplacedAddons has already turned off and listed the ones in ns.REPLACED_ADDONS.
			if not IsReplacedAddon(legacy.folder) then
				C_AddOns.DisableAddOn(legacy.folder)
				turnedOff[#turnedOff + 1] = LegacyTitle(legacy)
			end
		elseif key and not IsSettled(imported[key]) and IsInstalledButOff(legacy) then
			legacyToTurnOn[#legacyToTurnOn + 1] = legacy
		end
	end
end

function ns.IsLegacyImportPending()
	return #legacyToTurnOn > 0
end

StaticPopupDialogs.GOODTOGO_LEGACY_IMPORT = {
	text = L["POPUP_LEGACY_IMPORT_SETTINGS"],
	button1 = L["POPUP_LEGACY_IMPORT_ACCEPT"],
	button2 = L["POPUP_LEGACY_IMPORT_DECLINE"],
	OnAccept = function()
		local character = UnitName("player")
		for _, legacy in ipairs(legacyToTurnOn) do
			C_AddOns.EnableAddOn(legacy.folder, character)
		end
		ReloadUI()
	end,
	OnCancel = function()
		for _, legacy in ipairs(legacyToTurnOn) do
			ns.db.global.legacyImported[legacy.savedVariables] = "declined"
		end
		wipe(legacyToTurnOn)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	noCancelOnEscape = true,
	preferredIndex = 3,
}

--[[
    Asked once the player is in the world, after the welcome line, in place of
    OfferReplacedReload. Returns whether it asked anything: when it didn't,
    OfferReplacedReload offers the plain reload. A reload for an add-on just
    turned off comes before the import question, which waits for the next login.
]]
local function OfferLegacySteps()
	if #legacyCopied > 0 then
		StaticPopupDialogs.GOODTOGO_REPLACED_RELOAD.text = L["POPUP_LEGACY_RELOAD_COPIED"]
		StaticPopup_Show("GOODTOGO_REPLACED_RELOAD", JoinTitles(legacyCopied), JoinTitles(turnedOff))
		return true
	elseif #turnedOff == 0 and #legacyToTurnOn > 0 then
		local titles = {}
		local bringsLists = false
		for index, legacy in ipairs(legacyToTurnOn) do
			titles[index] = LegacyTitle(legacy)
			bringsLists = bringsLists or legacy.savedVariables == "ConnoisseurDB"
		end
		StaticPopupDialogs.GOODTOGO_LEGACY_IMPORT.text = bringsLists and L["POPUP_LEGACY_IMPORT_LISTS"]
			or L["POPUP_LEGACY_IMPORT_SETTINGS"]
		StaticPopup_Show("GOODTOGO_LEGACY_IMPORT", JoinTitles(titles))
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

--[[
    AceDB reads the character's name once, as the library loads, and keeps the
    character's profile choice under it. The newest AceDB among the enabled
    add-ons is the one that loads, and when that happens before the client has
    named the character, the name it read is the client's placeholder. Every
    such login would then share one profile, and with it another character's
    settings and Restock List. By PLAYER_LOGIN the name is known, so the
    character is put on the profile saved under its real name, or on its own.
    The logout half saves the session's choice under the real name and drops
    the placeholder's entry. An AceDB older than the vendored one, which on
    Forever reads a first name and no surname, is caught the same way.
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
    MIGRATION (remove after 2026-12-08)
    Automated Appreciation (Stranger Buffs, Sharing Good News, Combat Buffs,
    Group Service Alerts and the Thank You buttons) is gone: thanking is
    Thanks for the Buff's job, which is its own add-on again. Its settings go,
    and so does the record of an import from it that no longer happens.

    The Thank You macros this add-on made go too, since their commands no
    longer answer: only one whose body is still exactly its button's command,
    and only while no other add-on has taken that command, so a macro the
    player rewrote, or one Thanks for the Buff still answers, stays. Macros
    can't be deleted in combat; a login mid-fight leaves them for the next.
]]
local RETIRED_SETTINGS = {
	"strangers",
	"teammates",
	"services",
	"goodNews",
	"watchedBuffs",
	"slash",
	"slash2",
	"slash3",
	"slash4",
	"slash5",
}

local RETIRED_MACROS = {
	["- Thank"] = "/thankyou",
	["- GtG 2"] = "/thankyou2",
	["- GtG 3"] = "/thankyou3",
	["- GtG 4"] = "/thankyou4",
	["- GtG 5"] = "/thankyou5",
}

local function IsSlashCommandTaken(command)
	for key in pairs(SlashCmdList) do
		local index = 1
		local alias = _G["SLASH_" .. key .. index]
		while alias do
			if type(alias) == "string" and alias:lower() == command then
				return true
			end
			index = index + 1
			alias = _G["SLASH_" .. key .. index]
		end
	end
	return false
end

local function RetireAutomatedAppreciation()
	for _, key in ipairs(RETIRED_SETTINGS) do
		ns.db.global[key] = nil
	end
	local imported = ns.db.global.legacyImported
	if type(imported) == "table" then
		imported.TFTBDB = nil
	end

	if InCombatLockdown() then
		return
	end
	for name, command in pairs(RETIRED_MACROS) do
		local index = GetMacroIndexByName(name)
		if index > 0 then
			local body = select(3, GetMacroInfo(index))
			if body and strtrim(body) == command and not IsSlashCommandTaken(command) then
				DeleteMacro(index)
			end
		end
	end
end

--[[
    Characters from another game version, dropped without a word. AceDB keys
    a character "Name - Realm" on realm clients and "First Last" on the
    realm-free ones (WoW Forever), so a saved key shaped the other way from
    the one being played came from a copied WTF folder: its char section,
    its profile choice and, unless someone still uses it, its own profile go.
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
    The same characters' account-wide leftovers on ns.db.global. A Restock
    List choice is keyed by the AceDB name, so the shape test above settles
    it; its list then has no chooser, and goes at the Restocker's login if it
    is empty (ns.PruneEmptyOrphanRestockLists).

    An Inventory Report record names the character and its realm apart, so
    the name settles it instead. A realm client's names never hold a space,
    and a Forever one is the first name and surname (ns.GetPlayerFullName),
    so a realm client drops every record whose name has one. Forever drops
    the records with no space only when they are on another realm too, so a
    Forever character with no surname on this realm stays.
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

	local inventory = global.inventory
	if type(inventory) ~= "table" then
		return
	end
	local realm = GetRealmName()
	for key, record in pairs(inventory) do
		if type(record) == "table" and type(record.name) == "string" then
			local hasSurname = record.name:find("%s") ~= nil
			if realmClient and hasSurname or not realmClient and not hasSurname and record.realm ~= realm then
				inventory[key] = nil
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
    One account-wide SavedVariable managed by AceDB-3.0, Per-Character: every
    character lands on a profile of its own, named as AceDB names the
    character (its first name and surname on WoW Forever, "Name - Realm" on
    every other flavor). What differs by character rides the profile; what the whole
    account shares -- the Restock Lists, every character's inventory, which
    macros exist, Buff Duty's settings, presentation -- lives on
    ns.db.global, each with its reason (see Data/Default-Settings.lua).
]]
local function InitializeDatabase()
	-- MIGRATION (remove after 2026-12-03)
	MoveRenamedSettings()

	-- MIGRATION (remove after 2026-12-08)
	ImportLegacySettings()

	ns.db = LibStub("AceDB-3.0"):New(ns.SAVED_VARIABLES_NAME, ns.DATABASE_DEFAULTS)
	PruneOtherClientCharacters()
	UseOwnProfileWhenUnnamed()

	-- MIGRATION (remove after 2026-12-11): group settings onto the Solo / Party / Raid / Battleground checkboxes.
	ns.MoveGroupSettingsOntoCheckboxes()

	-- MIGRATION (remove after 2026-12-08)
	RetireAutomatedAppreciation()

	-- MIGRATION (remove after 2026-12-08)
	ns.RetireSavedItemCache()

	--[[
	    MIGRATION (remove after 2026-12-08)
	    Connoisseur & Restocker's saved-data repairs, run on what it copied in:
	    first each Forever character's list choice and Inventory Report
	    record move to its whole-name key, then every
	    character still on the shared Default profile gets one of its own. Both
	    run before the callbacks below are wired, so their profile switch fires
	    no handler halfway through login. Features/Macros-for-Consumables/Character-Key-Migration.lua
	    and Features/Macros-for-Consumables/Default-Profile-Migration.lua list the pieces
	    that come out together.
	]]
	ns.RekeyCharactersByFullName()
	ns.MoveCharactersOntoOwnProfiles()

	for _, message in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
		ns.db.RegisterCallback(ns, message, "ApplyProfile")
	end
end

--[[
    A profile switch, copy or reset swaps every per-character setting at once.
    Settings read live from the database update themselves; each feature
    re-applies what it applied imperatively (macro bodies, aura tracking), and
    every open options panel redraws. The Restock List in use is the
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
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end
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
	for _, notice in ipairs(legacyNotices) do
		ns:PrintMessage(notice)
	end
	-- MIGRATION (remove after 2026-12-08): the OfferLegacySteps test, leaving the OfferReplacedReload call.
	if not OfferLegacySteps() then
		OfferReplacedReload()
	end
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

--[[
    PLAYER_LOGIN is the only place the database initializes: the earliest safe
    point (SavedVariables are loaded) and before the first
    PLAYER_ENTERING_WORLD, which refires on every loading screen. The panels
    register right after, since the Profiles panel binds to ns.db, and only
    then does each module hear PLAYER_LOGIN. None of this touches a protected
    function, so it runs even when the player logs in mid-combat.
]]
eventFrame:SetScript("OnEvent", function(_, event, ...)
	-- Diagnostics event-log tap; the boolean is read first so logging-off is free.
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, ...)
	end

	if event == "PLAYER_LOGIN" then
		TurnOffReplacedAddons()
		InitializeDatabase()
		ns.RegisterOptionsPanels()
		-- The one mini-map button every feature shares; LibDBIcon reads its saved position from ns.db.
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
