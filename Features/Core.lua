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
    Every event the add-on uses, in one list. The dispatcher below registers
    from it, and Diagnostics' Event Registration check reads the same list, so
    the two can never drift. Each feature subscribes to the events it handles
    with ns.SetModuleEvent; a name missing here stops the load, and fails
    Tests/Run.lua in CI first.
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
    MIGRATION (remove after 2026-12-13)
    Before Send Messages In, Buff Duty's whispered ask and Rank Watch's
    whispers always went out in the client's language. An account that had
    either turned on -- Buff Duty on with Ask Other Classes for Buffs, or Rank
    Watch on with Whisper Group Members -- keeps whispering in that language:
    it gets the client's locale as its message language, when Good to Go
    lists it. A whisper with no saved text follows that language's default,
    so nothing else moves. Read from the raw saved table before AceDB fills
    in defaults, since a value left at its default is simply absent there.
    Runs once per account, stamped (messageLanguageMigrated, right after
    AceDB opens) so a player who later picks English is never switched back.
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

	--[[
	    MIGRATION (remove after 2026-12-13): Send Messages In keeps a whispering account's client language. Before
	    the legacy import, so only what Good to Go itself saved counts.
	]]
	MigrateMessageLanguage()

	-- MIGRATION (remove after 2026-12-08)
	ns.ImportLegacySettings()

	ns.db = LibStub("AceDB-3.0"):New(ns.SAVED_VARIABLES_NAME, ns.DATABASE_DEFAULTS)
	PruneOtherClientCharacters()
	UseOwnProfileWhenUnnamed()

	-- MIGRATION (remove after 2026-12-13): stamps the account so MigrateMessageLanguage runs once, fresh installs included.
	ns.db.global.messageLanguageMigrated = true

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
    re-applies what it applied imperatively (macro bodies, aura tracking), the
    mini-map button re-reads its saved table, and every open options panel,
    the menu and the button's icon redraw through ns.RefreshSettings. The
    Restock List in use is the character's own choice, not the profile's, so
    a switch leaves it alone.
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
		ns.TurnOffReplacedAddons()
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
