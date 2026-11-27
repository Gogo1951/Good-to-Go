local _, ns = ...
local L = ns.L

local MaxAccountMacros = ns.MaxAccountMacros
local OwnedList = ns.OwnedMacroList

-- Another character's own list can't be read from here.
local function MacroList(general)
	local numAccount, numCharacter = GetNumMacros()
	if general then
		return 1, numAccount, ns.db.global.ownedMacros
	end
	local first = MaxAccountMacros() + 1
	return first, first + numCharacter - 1, ns.db.char.ownedMacros
end

-- Needs a handed-out tag and an ownership record both, so a player's macro ending "#end" is never taken.
local function AddonMacroIndexes(general)
	local first, last, owned = MacroList(general)
	local handedOut = {}
	for _, tag in pairs(ns.db.global.macroTags) do
		handedOut[tag] = true
	end
	local found = {}
	for index = last, first, -1 do
		local name, _, body = GetMacroInfo(index)
		local tag = ns.BodyTag(body)
		if tag and handedOut[tag] and owned[name] ~= nil then
			found[#found + 1] = index
		end
	end
	return found, owned
end

function ns.CountAddonMacros(general)
	return #AddonMacroIndexes(general)
end

--[[
	While the Spellbook is on, a sync first tags older page macros so they go too. Ownership records go with
	the names, so a player's macro later given one isn't taken; the page macros keep their tags.
]]
function ns.DeleteAddonMacros(general)
	if InCombatLockdown() then
		ns:PrintMessage(L["ERROR_MACRO_COMBAT"])
		return
	end
	if ns.IsMacroUIOpen() then
		ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_WINDOW_OPEN"])
		return
	end
	if ns.IsSpellbookEnabled() then
		ns:RefreshMacros()
	end
	local indexes, owned = AddonMacroIndexes(general)
	for _, index in ipairs(indexes) do
		owned[GetMacroInfo(index)] = nil
		DeleteMacro(index)
	end
	ns:PrintMessage(#indexes == 1 and L["CHAT_MACROS_DELETED_ONE"] or L["CHAT_MACROS_DELETED"]:format(#indexes))
	ns:RefreshOpenPages()
end

local function DeleteWowMacro(page)
	local index = ns.FindMacroIndex(page)
	if index ~= 0 then
		OwnedList(index)[GetMacroInfo(index)] = nil
		DeleteMacro(index)
	end
end

-- A spell's macro keeps its tag, so one placed again gets it back.
function ns.DeletePageMacro(macro)
	if InCombatLockdown() then
		ns:PrintMessage(L["ERROR_MACRO_COMBAT"])
		return
	end
	if ns.IsMacroUIOpen() then
		ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_WINDOW_OPEN"])
		return
	end
	DeleteWowMacro(macro)
	if macro.copy then
		ns.RemoveMacroCopy(macro)
	else
		ns.ResetMacroOptions(macro)
	end
end

StaticPopupDialogs.GOODTOGO_DELETE_MACRO = {
	text = L["MENU_DELETE_CONFIRM"],
	button1 = L["POPUP_DELETE"],
	button2 = CANCEL,
	OnAccept = function(_, data)
		data()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- unused words the ask for a macro on no bar, which has nothing to take off them.
function ns.ConfirmDelete(name, delete, unused)
	StaticPopupDialogs.GOODTOGO_DELETE_MACRO.text = L[unused and "MENU_DELETE_CONFIRM_UNUSED" or "MENU_DELETE_CONFIRM"]
	StaticPopup_Show("GOODTOGO_DELETE_MACRO", name, nil, delete)
end
