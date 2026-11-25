local _, ns = ...
local L = ns.L

--[[
	Which of the game's macro lists a page macro's WoW macro is kept in: the character's own (the default,
	"character"), or the General list every character on the account shares ("general"), chosen per macro from
	its menu's Macro Storage (Features/Enhanced-Spellbook/Macro-Menu.lua). The choice is stored in the "macroTab"
	setting (Features/Enhanced-Spellbook/Macro-Settings.lua) under the macro's settings key. A General macro still belongs to the character that made it:
	its tag is that character's (ns.MacroTag), so no other character finds or rewrites it.
]]

local MaxAccountMacros, MaxCharacterMacros = ns.MaxAccountMacros, ns.MaxCharacterMacros
local OwnedList, OwnerRecord = ns.OwnedMacroList, ns.MacroOwnerRecord
local SettingsKey = ns.SettingsKey

local GENERAL, CHARACTER = "general", "character"
ns.MACRO_TAB_GENERAL, ns.MACRO_TAB_CHARACTER = GENERAL, CHARACTER

-- The list a page macro's WoW macro is kept in: GENERAL or CHARACTER.
function ns.MacroTab(macro)
	return ns.GetMacroSetting(macro, "macroTab") == GENERAL and GENERAL or CHARACTER
end

-- The list the WoW macro at index is in: indexes run General first, then the character's.
local function TabOf(index)
	return index <= MaxAccountMacros() and GENERAL or CHARACTER
end

local function FreeSlots(tab)
	local numAccount, numCharacter = GetNumMacros()
	if tab == GENERAL then
		return MaxAccountMacros() - numAccount
	end
	return MaxCharacterMacros() - numCharacter
end

--[[
	CreateMacro's perCharacter argument, a real boolean, for a new WoW macro for the page macro: its own list
	while that has a free slot, else the other one; nil when both are full.
]]
function ns.MacroCreatePerCharacter(macro)
	local first = ns.MacroTab(macro)
	local second = first == GENERAL and CHARACTER or GENERAL
	for _, tab in ipairs({ first, second }) do
		if FreeSlots(tab) > 0 then
			return tab == CHARACTER
		end
	end
	return nil
end

-- The page macros that share the macro's settings key, so its choice.
local function SharingMacros(macro)
	local key, list = SettingsKey(macro), {}
	for _, other in ipairs(ns.macros) do
		if not other.consumable and SettingsKey(other) == key then
			list[#list + 1] = other
		end
	end
	if #list == 0 then
		list[1] = macro
	end
	return list
end

--[[
	Moves the WoW macro at index into the other list: a new macro with the same name and text there, put back
	in every action slot that held the old one, which is then deleted with its ownership record. The icon is the
	add-on's (ns.WowMacroIcon), since GetMacroInfo gives the spell's icon for a question-mark macro, which would
	stop it following the spell. Creating a macro in one list never shifts the other list's indexes, so index
	still points at the old macro once the new one exists.
]]
local function MoveTo(page, index, tab)
	local name, _, body = GetMacroInfo(index)
	local slots = ns.MacroBarSlots(index)
	local newIndex = CreateMacro(name, ns.WowMacroIcon(page), body, tab == CHARACTER)
	if not newIndex or newIndex == 0 then
		return false
	end
	OwnedList(index)[name] = nil
	OwnedList(newIndex)[name] = OwnerRecord(newIndex)
	ClearCursor()
	for _, slot in ipairs(slots) do
		PickupMacro(newIndex)
		PlaceAction(slot)
		ClearCursor()
	end
	DeleteMacro(index)
	return true
end

--[[
	The menu's Macro Storage: stores the choice and moves the macro's WoW macro into that list now,
	keeping it on the action bars. A macro not made yet just goes there when it is placed. Refused,
	with the choice left as it was, in combat, while the Blizzard Macro UI is open, or when the list has too few
	free slots for the macros to move.
]]
function ns.SetMacroTab(macro, tab)
	if ns.MacroTab(macro) == tab then
		return
	end
	if InCombatLockdown() then
		ns:PrintMessage(L["ERROR_MACRO_COMBAT"])
		return
	end
	if ns.IsMacroUIOpen() then
		ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_WINDOW_OPEN"])
		return
	end
	local moving, indexes = {}, ns.ReadMacroIndexes()
	for _, page in ipairs(SharingMacros(macro)) do
		local index = ns.FindMacroIndex(page, indexes)
		if index ~= 0 and TabOf(index) ~= tab then
			moving[#moving + 1] = page
		end
	end
	if #moving > FreeSlots(tab) then
		ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_SLOTS_FULL"])
		return
	end
	ns.StoreMacroSetting(macro, "macroTab", tab == GENERAL and GENERAL or nil)
	for _, page in ipairs(moving) do
		-- found again, since the move before it shifted the indexes in the list it went to
		local index = ns.FindMacroIndex(page)
		if index ~= 0 and TabOf(index) ~= tab then
			MoveTo(page, index, tab)
		end
	end
	if #moving > 0 then
		ns.ForgetPlacedRankMacros()
	end
end
