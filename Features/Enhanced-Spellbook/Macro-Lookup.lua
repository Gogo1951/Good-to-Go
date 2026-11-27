local _, ns = ...

--[[
	The Retail engine has the slot limits in Constants.MacroConsts, the Classic engine in MAX_ACCOUNT_MACROS and
	MAX_CHARACTER_MACROS; every flavor is 120 and 30 today, the fallback.
]]
local MACRO_CONSTS = Constants and Constants.MacroConsts or {}

local function MaxCharacterMacros()
	return MACRO_CONSTS.MAX_CHARACTER_MACROS or MAX_CHARACTER_MACROS or 30
end

local function MaxAccountMacros()
	return MACRO_CONSTS.MAX_ACCOUNT_MACROS or MAX_ACCOUNT_MACROS or 120
end

-- The macros in use and the slots there are: general used, general max, character used, character max.
function ns.MacroCounts()
	local numAccount, numCharacter = GetNumMacros()
	return numAccount, MaxAccountMacros(), numCharacter, MaxCharacterMacros()
end

--[[
	Untagged macros are found by name, but only those the add-on recorded creating, so a player's macro sharing
	a spell's name is never touched. New macros are still recorded, so one whose tag line the player deletes is
	found by name again. Records are keyed by WoW macro name, prefix and all.
]]

-- The prefix ("-Divine Spirit") sorts the add-on's macros together in /macro.
function ns.WowMacroName(macro)
	return macro.wowName or ns.MACRO_NAME_PREFIX .. macro.macroName
end

--[[
	The question mark lets #showtooltip show the spell's icon. A profession takes its tile's icon, since the game
	resolves a profession's name to the wrong one (a gem or an anvil, on Forever).
]]
function ns.WowMacroIcon(macro)
	if macro.pageTag == "professions" and macro.icon and macro.icon ~= ns.QUESTION_MARK_ICON then
		return macro.icon
	end
	return macro.macroIcon
end

--[[
	MIGRATION (remove after 2026-11-26): the prefix the Spellbook's macros had before Good to Go gave
	every one of its macros a leading "-". A macro still under it is renamed on its next sync.
]]
local OLD_PREFIX = "~"

-- MIGRATION (remove after 2026-11-26)
local function OldPrefixName(macro)
	return OLD_PREFIX .. macro.macroName
end

local function IsGeneral(index)
	return index <= MaxAccountMacros()
end

local function OwnedList(index)
	return IsGeneral(index) and ns.db.global.ownedMacros or ns.db.char.ownedMacros
end

ns.MaxAccountMacros, ns.MaxCharacterMacros = MaxAccountMacros, MaxCharacterMacros
ns.OwnedMacroList = OwnedList

local function OwnerRecord(index)
	if IsGeneral(index) then
		return ns.MacroOwnerKey()
	end
	return true
end

-- "owned", or nil for the player's own (whatever its text) or another character's.
function ns.LegacyOwnership(index)
	local name = GetMacroInfo(index)
	local record = OwnedList(index)[name]
	if record ~= nil then
		return record == OwnerRecord(index) and "owned" or nil
	end
	return nil
end

local NO_INDEXES = {}

--[[
	A tag can map to several macros when the player pasted an add-on macro's text into their own. Both lists put
	character macros first.
]]
local function ReadMacroIndexes()
	local indexes = { tags = {}, names = {} }
	local numAccount, numCharacter = GetNumMacros()
	local function read(index)
		local name, _, body = GetMacroInfo(index)
		local tag = ns.BodyTag(body)
		if tag then
			indexes.tags[tag] = indexes.tags[tag] or {}
			table.insert(indexes.tags[tag], index)
		elseif name then
			indexes.names[name] = indexes.names[name] or {}
			table.insert(indexes.names[name], index)
		end
	end
	local first = MaxAccountMacros()
	for index = first + 1, first + numCharacter do
		read(index)
	end
	for index = 1, numAccount do
		read(index)
	end
	return indexes
end

ns.ReadMacroIndexes = ReadMacroIndexes

local function FindByName(indexes, name)
	for _, named in ipairs(name and indexes.names[name] or NO_INDEXES) do
		local ownership = ns.LegacyOwnership(named)
		if ownership then
			return named, ownership
		end
	end
	return nil
end

--[[
	The one under its name, else the one recorded as this character's, else the first. The others are copies the
	player pasted, and stay theirs.
]]
local function PickTagged(macro, tagged)
	local wowName = ns.WowMacroName(macro)
	for _, index in ipairs(tagged) do
		if GetMacroInfo(index) == wowName then
			return index
		end
	end
	for _, index in ipairs(tagged) do
		if ns.LegacyOwnership(index) == "owned" then
			return index
		end
	end
	return tagged[1]
end

--[[
	Returns the index (0 for none), how it was found ("tag", or the ownership answer), and for "tag" whether
	other macros carry the same tag. indexes is a ReadMacroIndexes result, read here when nil.
]]
function ns.FindMacroIndex(macro, indexes)
	indexes = indexes or ReadMacroIndexes()
	local tagged = indexes.tags[ns.MacroTag(macro)]
	if tagged then
		return PickTagged(macro, tagged), "tag", #tagged > 1
	end
	local index, ownership = FindByName(indexes, ns.WowMacroName(macro))
	if not index then
		-- MIGRATION (remove after 2026-11-26)
		index, ownership = FindByName(indexes, OldPrefixName(macro))
	end
	return index or 0, ownership
end

ns.MacroOwnerRecord = OwnerRecord
-- MIGRATION (remove after 2026-11-26)
ns.OldPrefixName, ns.OLD_MACRO_PREFIX = OldPrefixName, OLD_PREFIX
