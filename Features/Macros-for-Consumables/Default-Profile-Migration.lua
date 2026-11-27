local _, ns = ...

--------------------------------------------------------------------------------
-- Moving Every Character Off Default
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-12-08)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    five pieces together:
      1. this file
      2. its tagged line in all four flavor TOCs (Good-to-Go_Vanilla.toc,
         _TBC.toc, _Camelot.toc and _Mists.toc)
      3. the ns.MoveCharactersOntoOwnProfiles() call in Features/Core.lua
      4. the tagged noDefaultProfiles argument in Options/Options-Profiles.lua,
         and the sentence about it in that file's comment
      5. the tagged FOREVER_RULE_SETS / IsOlderForeverKey exemption in
         Features/Core.lua, which keeps the older Forever names below from
         being pruned as another client's
]]

--[[
    Every character gets its own profile, named as AceDB names it (the
    maintainer's ruling: consumable choices differ per character). Characters
    on Default move to a copy of it, logged-out ones too; list choices move
    from profile.restockList and listsByCharacter into listChoices; a Forever
    character takes its older-name profile's settings. Runs before the profile
    callbacks are wired, so the switches fire no handler mid-login.
]]

local DEFAULT_PROFILE = "Default"

-- Any key counts: ns.RetireSavedItemCache has already cleared the derived item cache from every profile.
local function HoldsSettings(profile)
	return type(profile) == "table" and next(profile) ~= nil
end

local function CopySettings(profile)
	local copy = {}
	for key, value in pairs(profile or {}) do
		copy[key] = type(value) == "table" and CopyTable(value) or value
	end
	return copy
end

local function SubTable(parent, key)
	if type(parent[key]) ~= "table" then
		parent[key] = {}
	end
	return parent[key]
end

--------------------------------------------------------------------------------
-- Characters
--------------------------------------------------------------------------------

-- AceDB's own key is wrong when it loaded before the client named the character, so ask the client first.
local function OwnProfileKey()
	return ns.GetCharacterProfileName() or ns.db.keys.char
end

-- A Forever profile key holds no realm, but the whole name is unique across the region, so a prefix match is safe.
local function FindCharacterEntry(keyed, profileKey)
	local name, realm = ns.SplitCharacterProfileName(profileKey)
	if not name then
		return nil
	end
	if realm then
		local characterKey = name .. "-" .. (realm:gsub("%s+", ""))
		return keyed[characterKey] ~= nil and characterKey or nil
	end

	local prefix = name .. "-"
	for characterKey in pairs(keyed) do
		if type(characterKey) == "string" and characterKey:sub(1, #prefix) == prefix then
			return characterKey
		end
	end
	return nil
end

--[[
    AceDB's "Unknown" placeholder keys: left pointing at Default they would stop
    Default being deleted. Older Forever "First - RuleSet" keys stay.
]]
local function DropUnnamedCharacters(profileKeys, ownProfileKey)
	for profileKey in pairs(profileKeys) do
		if
			profileKey ~= ownProfileKey
			and profileKey ~= ns.db.keys.char
			and not ns.SplitCharacterProfileName(profileKey)
		then
			local name = profileKey:match("^(.-) %- ")
			if name == nil or name == UNKNOWNOBJECT then
				profileKeys[profileKey] = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Forever's Older Names
--------------------------------------------------------------------------------

--[[
    An AceDB before minor 39 keyed a Forever character "First - RuleSet";
    ns.db.keys.realm still reads the rule set, so the key rebuilds exactly. The
    older name and profile stay: namesakes on one rule set shared it, and each
    takes its copy at its own login. Nothing has read the own profile yet, so
    defaults don't count as settings.
]]
local function CarryOlderForeverSettings(profiles, profileKeys, ownProfileKey)
	local firstName = UnitName("player")
	-- Era and TBC have one name, which AceDB has always keyed the same way.
	if not firstName or ns.GetPlayerFullName() == firstName then
		return
	end

	local olderProfileName = profileKeys[firstName .. " - " .. ns.db.keys.realm]
	local olderProfile = olderProfileName and profiles[olderProfileName]
	if HoldsSettings(olderProfile) and not HoldsSettings(profiles[ownProfileKey]) then
		profiles[ownProfileKey] = CopySettings(olderProfile)
	end
end

--------------------------------------------------------------------------------
-- Off Default
--------------------------------------------------------------------------------

local function MoveCharactersOffDefault(profiles, profileKeys, ownProfileKey)
	local default = profiles[DEFAULT_PROFILE]

	-- Collected first: a table cannot take new keys while it is being walked.
	local moving = {}
	for profileKey, profileName in pairs(profileKeys) do
		if profileName == DEFAULT_PROFILE and ns.SplitCharacterProfileName(profileKey) then
			moving[#moving + 1] = profileKey
		end
	end

	for _, profileKey in ipairs(moving) do
		if not HoldsSettings(profiles[profileKey]) then
			profiles[profileKey] = CopySettings(default)
		end

		profileKeys[profileKey] = profileKey
		if profileKey == ownProfileKey then
			ns.db:SetProfile(profileKey)
		end
	end

	--[[
	    A Default the player emptied by hand, settings still in it, is theirs to
	    keep. Read again: the switch above makes AceDB build a Default.
	]]
	default = profiles[DEFAULT_PROFILE]
	if type(default) ~= "table" or not (#moving > 0 or not HoldsSettings(default)) then
		return
	end
	for _, profileName in pairs(profileKeys) do
		if profileName == DEFAULT_PROFILE then
			return
		end
	end
	ns.db:DeleteProfile(DEFAULT_PROFILE, true)
end

--------------------------------------------------------------------------------
-- Restock List Choices
--------------------------------------------------------------------------------

--[[
    The profile's choice is newer than listsByCharacter, so it goes first. The
    character playing is read through ns.db.profile: when AceDB could not name
    it, its key reaches profileKeys only at logout.
]]
local function CarryListChoices(profiles, profileKeys, ownProfileKey)
	local restocker = ns.db.global.restocker
	local listChoices = SubTable(restocker, "listChoices")

	if listChoices[ownProfileKey] == nil then
		listChoices[ownProfileKey] = ns.db.profile.restockList
	end
	for profileKey, profileName in pairs(profileKeys) do
		local profile = profiles[profileName]
		if listChoices[profileKey] == nil and ns.SplitCharacterProfileName(profileKey) and type(profile) == "table" then
			listChoices[profileKey] = profile.restockList
		end
	end

	local listsByCharacter = restocker.listsByCharacter
	if listsByCharacter == nil then
		return
	end

	if type(listsByCharacter) == "table" then
		local ownKey = ns.GetCharacterKey()
		if listsByCharacter[ownKey] ~= nil then
			if listChoices[ownProfileKey] == nil then
				listChoices[ownProfileKey] = listsByCharacter[ownKey]
			end
			listsByCharacter[ownKey] = nil
		end

		for profileKey in pairs(profileKeys) do
			local characterKey = profileKey ~= ownProfileKey and FindCharacterEntry(listsByCharacter, profileKey)
			if characterKey then
				if listChoices[profileKey] == nil then
					listChoices[profileKey] = listsByCharacter[characterKey]
				end
				listsByCharacter[characterKey] = nil
			end
		end

		if next(listsByCharacter) ~= nil then
			return
		end
	end

	restocker.listsByCharacter = nil
end

--[[
    Left in place, Profiles → Copy From would carry restockList on for good.
    It stays where an older Forever key still points (a namesake's copy not yet
    taken), and where it's the only key, which would otherwise read as no
    settings and take the older Forever copy again next login.
]]
local function RetireProfileRestockLists(profiles, profileKeys, ownProfileKey)
	local listChoices = ns.db.global.restocker.listChoices or {}
	local keep, retire = {}, {}
	-- The character playing may reach profileKeys only at logout.
	local current = ns.db:GetCurrentProfile()
	if listChoices[ownProfileKey] ~= nil then
		retire[current] = true
	else
		keep[current] = true
	end
	for profileKey, profileName in pairs(profileKeys) do
		if ns.SplitCharacterProfileName(profileKey) and listChoices[profileKey] ~= nil then
			retire[profileName] = true
		else
			keep[profileName] = true
		end
	end
	for profileName in pairs(retire) do
		local profile = profiles[profileName]
		if not keep[profileName] and type(profile) == "table" and profile.restockList ~= nil then
			local onlyKey = next(profile) == "restockList" and next(profile, "restockList") == nil
			if not onlyKey then
				profile.restockList = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Migration
--------------------------------------------------------------------------------

function ns.MoveCharactersOntoOwnProfiles()
	local profileKeys = ns.db.sv.profileKeys
	if type(profileKeys) ~= "table" then
		return
	end
	local profiles = SubTable(ns.db.sv, "profiles")
	local ownProfileKey = OwnProfileKey()

	CarryOlderForeverSettings(profiles, profileKeys, ownProfileKey)
	DropUnnamedCharacters(profileKeys, ownProfileKey)
	MoveCharactersOffDefault(profiles, profileKeys, ownProfileKey)
	CarryListChoices(profiles, profileKeys, ownProfileKey)
	RetireProfileRestockLists(profiles, profileKeys, ownProfileKey)
end
