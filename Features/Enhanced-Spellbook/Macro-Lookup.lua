local _, ns = ...

-- Finds the WoW macros the page creates (Features/Enhanced-Spellbook/Macro-Sync.lua writes them). Reads only.

--[[
	The macro slot limits. The Retail engine has them in Constants.MacroConsts; the Classic engine's
	UIParent sets the MAX_ACCOUNT_MACROS and MAX_CHARACTER_MACROS globals. Every flavor is 120 general
	and 30 character today, the fallback if neither is there.
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
	The WoW macros the add-on writes carry a tag line (ns.MacroTag), which is how the page finds them. Macros
	from before the tags are found by name instead, and only those the add-on created, by name: character
	ones listed in ns.db.char (as true), general ones in ns.db.global as the key of the character that created
	it, the only character that rewrites it. The next sync tags each one it finds, so a player's own macro that
	happens to share a spell's name is never touched. Macro indexes run general first, then character, so the
	index says which list a macro belongs to. New macros are still recorded, so one whose tag line the player
	deletes is found by name again. The records are kept by WoW macro name, prefix and all.
]]

--[[
	The name the WoW macro for a page macro takes: the page macro's own behind ns.MACRO_NAME_PREFIX
	("-Divine Spirit"), so the add-on's macros sort together in /macro. A consumable's is Consumable Macros' own
	(Features/Enhanced-Spellbook/Consumable-Macros.lua).
]]
function ns.WowMacroName(macro)
	return macro.wowName or ns.MACRO_NAME_PREFIX .. macro.macroName
end

--[[
	The icon a page macro's WoW macro is written with. Most keep the question mark, so #showtooltip shows the
	spell's own icon; a profession's takes the icon its tile shows (a specialization's, once folded in), since
	the game resolves a profession's name to the wrong icon (a gem or an anvil, on Forever).
]]
function ns.WowMacroIcon(macro)
	if macro.pageTag == "professions" and macro.icon and macro.icon ~= ns.QUESTION_MARK_ICON then
		return macro.icon
	end
	return macro.macroIcon
end

--[[
	MIGRATION (remove after 2026-11-23): the name the add-on gave a WoW macro before the prefix, when names ran
	to the full 16 bytes: a spell macro's name cut to 16, a focus copy's or a Duplicate's cut to fit
	its suffix in 16.
]]
local LEGACY_NAME_MAX_LENGTH = 16

--[[
	MIGRATION (remove after 2026-11-26): the prefix the Spellbook's macros had before Good to Go gave
	every one of its macros a leading "-". A macro still under it is renamed on its next sync.
]]
local OLD_PREFIX = "~"

-- MIGRATION (remove after 2026-11-26)
local function OldPrefixName(macro)
	return OLD_PREFIX .. macro.macroName
end

-- MIGRATION (remove after 2026-11-23)
local function LegacyMacroName(macro)
	if macro.copy then
		local suffix = " " .. macro.copy
		return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH - #suffix) .. suffix
	elseif macro.focus then
		return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH - #ns.FOCUS_SUFFIX) .. ns.FOCUS_SUFFIX
	end
	return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH)
end

local function IsGeneral(index)
	return index <= MaxAccountMacros()
end

local function OwnedList(index)
	return IsGeneral(index) and ns.db.global.ownedMacros or ns.db.char.ownedMacros
end

ns.MaxAccountMacros, ns.MaxCharacterMacros = MaxAccountMacros, MaxCharacterMacros
ns.OwnedMacroList = OwnedList

-- The record a macro the add-on creates at index takes in its OwnedList.
local function OwnerRecord(index)
	if IsGeneral(index) then
		return ns.MacroOwnerKey()
	end
	return true
end

--[[
	How a page macro stands to the untagged WoW macro of its name at index: "owned" (recorded as the add-on's,
	for this character), "claim" (MIGRATION (remove after 2026-11-23): a general macro recorded true
	before owners were, which the first character to find it claims),
	"adopt" (MIGRATION (remove after 2026-11-23): unrecorded, from before ownership tracking, but its text
	is the page's own), or nil (the player's own, or another character's). Reads only; ns.SyncMacro records a
	claim or adoption.
]]
function ns.LegacyOwnership(macro, index)
	local name, _, body = GetMacroInfo(index)
	local record = OwnedList(index)[name]
	-- MIGRATION (remove after 2026-11-23)
	if record == true and IsGeneral(index) then
		return "claim"
	end
	if record ~= nil then
		return record == OwnerRecord(index) and "owned" or nil
	end
	-- MIGRATION (remove after 2026-11-23)
	if body and (ns.TaggedBody(macro, body) == macro.body or body == ns.BareBody(macro.name)) then
		return "adopt"
	end
	return nil
end

local NO_INDEXES = {}

--[[
	Where the WoW macros are, read in one pass over them: tags maps each tag to the first macro carrying it,
	and names each name to the untagged macros of that name, character ones first, as the page's lookups by
	name have always preferred them.
]]
local function ReadMacroIndexes()
	local indexes = { tags = {}, names = {} }
	local numAccount, numCharacter = GetNumMacros()
	local function read(index)
		local name, _, body = GetMacroInfo(index)
		local tag = ns.BodyTag(body)
		if tag then
			indexes.tags[tag] = indexes.tags[tag] or index
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

-- The first untagged WoW macro called name that ns.LegacyOwnership says is the page macro's, and how.
local function FindByName(macro, indexes, name)
	for _, named in ipairs(name and indexes.names[name] or NO_INDEXES) do
		local ownership = ns.LegacyOwnership(macro, named)
		if ownership then
			return named, ownership
		end
	end
	return nil
end

--[[
	The WoW macro that is a page macro's: the one carrying its tag, else an untagged one of its name the
	add-on created (see ns.LegacyOwnership), under its name or, from before the prefix, its old one. Returns
	the index, 0 for none, and how it was found: "tag", or the ownership answer. Reads only. indexes is a
	ReadMacroIndexes result, read here when nil.
]]
function ns.FindMacroIndex(macro, indexes)
	indexes = indexes or ReadMacroIndexes()
	local index = indexes.tags[ns.MacroTag(macro)]
	if index then
		return index, "tag"
	end
	local ownership
	index, ownership = FindByName(macro, indexes, ns.WowMacroName(macro))
	if not index then
		-- MIGRATION (remove after 2026-11-26)
		index, ownership = FindByName(macro, indexes, OldPrefixName(macro))
	end
	if not index then
		-- MIGRATION (remove after 2026-11-23)
		index, ownership = FindByName(macro, indexes, LegacyMacroName(macro))
	end
	return index or 0, ownership
end

ns.MacroOwnerRecord = OwnerRecord
-- MIGRATION (remove after 2026-11-23)
ns.LegacyMacroName = LegacyMacroName
-- MIGRATION (remove after 2026-11-26)
ns.OldPrefixName, ns.OLD_MACRO_PREFIX = OldPrefixName, OLD_PREFIX
