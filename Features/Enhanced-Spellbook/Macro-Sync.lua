local _, ns = ...
local L = ns.L

local OwnedList, OwnerRecord = ns.OwnedMacroList, ns.MacroOwnerRecord
local ReadMacroIndexes = ns.ReadMacroIndexes
-- MIGRATION (remove after 2026-11-26)
local OldPrefixName, OLD_PREFIX = ns.OldPrefixName, ns.OLD_MACRO_PREFIX

local NO_INDEXES = {}

--[[
	Measured in bytes, which a translated name reaches sooner. A longer body would be cut off, so it is never
	written, and the player is told once per macro however its length changes.
]]
local function Fits(macro)
	if #macro.body <= ns.MACRO_BODY_MAX_LENGTH then
		return true
	end
	ns.WarnOnce(
		L["CHAT_MACRO_TOO_LONG"]:format(macro.label or macro.name, #macro.body, ns.MACRO_BODY_MAX_LENGTH),
		"tooLong:" .. ns.MacroIdentity(macro)
	)
	return false
end

--[[
	ns.PickupMacro asks the same, so the page's warnings and a click never disagree. A same-named macro never
	blocks one: tags tell them apart.
]]
function ns.MacroBlockReason(macro)
	if #macro.body > ns.MACRO_BODY_MAX_LENGTH then
		return "long", #macro.body
	end
	return nil
end

-- A name the add-on gave the same kind of macro (own or Duplicate) of a spell this one replaced and took over.
local function IsReplacedSpellsName(macro, name)
	if macro.rank then
		return false
	end
	local suffix = macro.copy and " " .. macro.copy or ""
	for _, replaced in ipairs(macro.replaces or NO_INDEXES) do
		local trimmed = ns.TrimMacroName(replaced, ns.MACRO_NAME_MAX_LENGTH - #suffix) .. suffix
		-- MIGRATION (remove after 2026-11-26): OLD_PREFIX
		if name == ns.MACRO_NAME_PREFIX .. trimmed or name == OLD_PREFIX .. trimmed then
			return true
		end
	end
	return false
end

--[[
	Rewrites the WoW macro at index if its body differs from the page's and fits. One still under the old
	"~" prefix (MIGRATION (remove after 2026-11-26)), or under the name of a replaced spell whose macro it took
	over ("-Bear Form", now Dire Bear Form's), is renamed, its ownership record moving with it; a name the
	player gave it is kept, and recorded as the add-on's while the body carries this macro's tag, so Delete
	Macros still finds it. A new name sorts the macro elsewhere in its list, so this returns the index it
	ends up at. shared says other macros carry the same tag: the player pasted the text, so the tag alone no
	longer says this one is the add-on's, and no record is written for a name the player gave.
]]
local function SyncAt(macro, index, shared)
	if index == 0 then
		return 0
	end
	local name, icon, body = GetMacroInfo(index)
	local newBody = body ~= macro.body and Fits(macro) and macro.body or nil
	-- only a profession's icon is the add-on's to set (see ns.WowMacroIcon); any other keeps the player's
	local wantIcon = ns.WowMacroIcon(macro)
	local newIcon = wantIcon ~= macro.macroIcon and icon ~= wantIcon and wantIcon or nil
	local renamed = IsReplacedSpellsName(macro, name)
	-- MIGRATION (remove after 2026-11-26)
	renamed = renamed or name == OldPrefixName(macro)
	if not renamed then
		local owned = OwnedList(index)
		if owned[name] == nil and not shared and ns.BodyTag(body) == ns.MacroTag(macro) then
			owned[name] = OwnerRecord(index)
		end
		if newBody or newIcon then
			EditMacro(index, nil, newIcon, newBody)
		end
		return index
	end
	local wowName = ns.WowMacroName(macro)
	local owned = OwnedList(index)
	owned[name] = nil
	owned[wowName] = OwnerRecord(index)
	return EditMacro(index, wowName, newIcon, newBody) or index
end

--[[
	The Macro UI saves its edit box back over the selected macro on selection change and hide, reverting a
	rewrite, so nothing is written while it is shown. It loads on demand, so the OnHide hook goes in on first sight.
]]
local macroUIHooked = false

local function IsMacroUIOpen()
	if not MacroFrame then
		return false
	end
	if not macroUIHooked then
		macroUIHooked = true
		MacroFrame:HookScript("OnHide", function()
			ns.MarkRankBodiesStale()
			ns:RefreshMacros()
		end)
	end
	return MacroFrame:IsShown()
end

ns.IsMacroUIOpen = IsMacroUIOpen

--[[
	One found by name gets its tag here, and indexes then lists it under the tag, so a same-named page macro in
	the same pass doesn't take it too. A rename moves macros about, so indexes is then read again.
]]
function ns.SyncMacro(macro, indexes)
	local index, found, shared = ns.FindMacroIndex(macro, indexes)
	if IsMacroUIOpen() then
		return index
	end
	if index ~= 0 and found ~= "tag" then
		local name = GetMacroInfo(index)
		OwnedList(index)[name] = OwnerRecord(index)
		ns.AssignMacroTag(macro)
		if indexes then
			indexes.tags[ns.MacroTag(macro)] = { index }
			local named = indexes.names[name]
			for i = #named, 1, -1 do
				if named[i] == index then
					table.remove(named, i)
				end
			end
		end
	end
	local moved = SyncAt(macro, index, shared)
	if moved ~= index and indexes then
		local fresh = ReadMacroIndexes()
		indexes.tags, indexes.names = fresh.tags, fresh.names
	end
	return moved
end

-- A same-named macro the add-on didn't make is left alone, and the new one sits beside it.
function ns.PickupMacro(macro)
	if InCombatLockdown() then
		ns:PrintMessage(L["ERROR_MACRO_COMBAT"])
		return
	end
	-- a consumable's macro is Consumable Macros' to write, so the page only picks it up
	if macro.consumable then
		local index = GetMacroIndexByName(macro.wowName)
		if index > 0 then
			PickupMacro(index)
		end
		return
	end
	if ns.MacroBlockReason(macro) then
		Fits(macro) -- tells the player, once
		return
	end
	local index = ns.FindMacroIndex(macro)
	if index == 0 then
		if IsMacroUIOpen() then
			ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_WINDOW_OPEN"])
			return
		end
		local perCharacter = ns.MacroCreatePerCharacter(macro)
		if perCharacter == nil then
			ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_SLOTS_FULL"])
			return
		end
		ns.AssignMacroTag(macro)
		-- a tag that grows to three characters adds a byte, so the tagged body is measured again
		if not Fits(macro) then
			return
		end
		index = CreateMacro(ns.WowMacroName(macro), ns.WowMacroIcon(macro), macro.body, perCharacter)
		if not index or index == 0 then
			return
		end
		OwnedList(index)[ns.WowMacroName(macro)] = OwnerRecord(index)
		ns.ForgetPlacedRankMacros()
	else
		index = ns.SyncMacro(macro)
	end
	PickupMacro(index)
end

-- Macros can't be edited in combat, so a rewrite asked for then waits for combat to end.
local syncPending = false

function ns.QueueMacroSync()
	syncPending = true
end

function ns:OnPlayerRegenEnabled()
	if syncPending then
		syncPending = false
		ns:RefreshMacros()
	end
	-- Dynamic Rank rewrites wait out combat too, and the target or mouseover may have changed meanwhile.
	ns.QueueRankRewriteAll()
end

function ns.SyncAllMacros()
	if InCombatLockdown() then
		ns.QueueMacroSync()
		return
	end
	if IsMacroUIOpen() then
		return
	end
	local indexes = ReadMacroIndexes()
	for _, macro in ipairs(ns.macros) do
		ns.SyncMacro(macro, indexes)
	end
end
