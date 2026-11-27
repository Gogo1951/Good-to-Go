local _, ns = ...

local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local MacroSpellKey = ns.MacroSpellKey
local CopySettingsKey = ns.CopySettingsKey

local NO_COPIES = {}

--[[
	ns.db.profile.macroCopies holds each spell key's copy numbers ("Drain Soul 2"). A removed number is never
	reused while a later one stands, so a copy keeps its name.
]]
local COPIED_SETTINGS = {
	"pet",
	"stance",
	"fixedRank",
	"useItems",
	"groupedSpells",
	"targetPriority",
	"conditionals",
	"castSequence",
	"castSequenceEnd",
	"castSequenceReset",
}
for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
	COPIED_SETTINGS[#COPIED_SETTINGS + 1] = key
end

-- Kept by the middle-click reset, which leaves the WoW macro where it is.
local KEPT_SETTINGS = { "macroTab" }
local OWN_SETTINGS = {}
for _, key in ipairs(COPIED_SETTINGS) do
	OWN_SETTINGS[#OWN_SETTINGS + 1] = key
end
for _, key in ipairs(KEPT_SETTINGS) do
	OWN_SETTINGS[#OWN_SETTINGS + 1] = key
end

-- Lowest first. Don't modify it.
function ns.MacroCopies(spellKey)
	return ns.db.profile.macroCopies[spellKey] or NO_COPIES
end

-- A learned spell's own macro or one of its copies, never a rank's.
function ns.OffersDuplicate(macro)
	return not macro.unlearned and not macro.rank
end

function ns.DuplicateMacro(macro)
	local copies, spellKey = ns.db.profile.macroCopies, MacroSpellKey(macro)
	local list = copies[spellKey] or {}
	local number = (list[#list] or 1) + 1
	list[#list + 1] = number
	copies[spellKey] = list
	local from, to = SettingsKey(macro), CopySettingsKey(spellKey, number)
	for _, key in ipairs(OWN_SETTINGS) do
		local value = SpellSettings(key)[from]
		if type(value) == "table" then
			local slots = {}
			for i, slot in ipairs(value) do
				slots[i] = slot
			end
			value = slots
		end
		SpellSettings(key)[to] = value
	end
end

-- The menu's Delete.
function ns.ResetMacroOptions(macro)
	local key = SettingsKey(macro)
	for _, setting in ipairs(OWN_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
end

-- The middle-click reset on a tile, and a category's reset.
function ns.ResetMacroSettings(macro)
	local key = SettingsKey(macro)
	for _, setting in ipairs(COPIED_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
end

-- Only where the second key has none; the first's are dropped either way.
local function MoveSettings(keys, from, to)
	for _, key in ipairs(keys) do
		local settings = SpellSettings(key)
		if settings[to] == nil then
			settings[to] = settings[from]
		end
		settings[from] = nil
	end
end

--[[
	Duplicates go too, each keeping its number and settings, unless the new spell has Duplicates of its own.
	fromID and toID are Rank 1 IDs.
]]
function ns.MoveSpellSettings(fromID, toID)
	local from, to = MacroSpellKey({ baseID = fromID }), MacroSpellKey({ baseID = toID })
	MoveSettings(OWN_SETTINGS, from, to)
	local copies = ns.db.profile.macroCopies
	if copies[from] and not copies[to] then
		for _, number in ipairs(copies[from]) do
			MoveSettings(OWN_SETTINGS, CopySettingsKey(from, number), CopySettingsKey(to, number))
		end
		copies[to], copies[from] = copies[from], nil
	end
end

function ns.RemoveMacroCopy(macro)
	local copies, spellKey = ns.db.profile.macroCopies, MacroSpellKey(macro)
	local list = copies[spellKey] or {}
	for i = #list, 1, -1 do
		if list[i] == macro.copy then
			table.remove(list, i)
		end
	end
	copies[spellKey] = #list > 0 and list or nil
	local key = SettingsKey(macro)
	for _, setting in ipairs(OWN_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
end
