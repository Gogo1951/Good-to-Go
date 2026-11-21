local _, ns = ...
local L = ns.L

local turnedOff = ns.turnedOffAddOnTitles
local AddOnTitle = ns.AddOnTitle
local JoinTitles = ns.JoinAddOnTitles

--[[
    MIGRATION (remove after 2026-12-08)
    The import from the add-ons Good to Go replaces (ns.LEGACY_ADDONS), with
    its chat notices and its login questions, and the retirement of Automated
    Appreciation's settings and Thank You macros. Features/Core.lua calls
    these at login and once the player is in the world.
]]

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
                  by ns.TurnOffReplacedAddons (Features/Replaced-Addons.lua),
                  which stays when this goes; the rest are turned off here.
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
		-- Connoisseur's Poisons macro was on by default, so an unset entry meant on.
		if type(saved.global.enabledMacros) ~= "table" then
			saved.global.enabledMacros = {}
		end
		if saved.global.enabledMacros["Poisons"] == nil then
			saved.global.enabledMacros["Poisons"] = true
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

function ns.ImportLegacySettings()
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

-- The notices of settings copied in this session, printed after the welcome line.
function ns.PrintLegacyNotices()
	for _, notice in ipairs(legacyNotices) do
		ns:PrintMessage(notice)
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
function ns.OfferLegacySteps()
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
-- Automated Appreciation
--------------------------------------------------------------------------------

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

function ns.RetireAutomatedAppreciation()
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
