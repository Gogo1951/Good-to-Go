local _, ns = ...
local L = ns.L

-- Keeps the WoW macros the page creates in step with it, found through Features/Enhanced-Spellbook/Macro-Lookup.lua.

local MaxAccountMacros, MaxCharacterMacros = ns.MaxAccountMacros, ns.MaxCharacterMacros
local OwnedList, OwnerRecord = ns.OwnedMacroList, ns.MacroOwnerRecord
local ReadMacroIndexes = ns.ReadMacroIndexes
-- MIGRATION (remove after 2026-11-23)
local LegacyMacroName = ns.LegacyMacroName
-- MIGRATION (remove after 2026-11-26)
local OldPrefixName, OLD_PREFIX = ns.OldPrefixName, ns.OLD_MACRO_PREFIX

local NO_INDEXES = {}

--[[
	Whether the macro's body fits the game's limit, measured in bytes, which a translated name reaches sooner.
	A longer body would be cut off, so it is never written, and the player is told once per macro, however its
	length changes.
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
	Why the page can't place a macro, or nil when it can: "long", with the body's length in bytes, when the
	body is over what a macro holds. ns.PickupMacro asks the same, so the page's warnings and a click never
	disagree. A macro of the same name never blocks one: the page's macros are told apart by their tags.
]]
function ns.MacroBlockReason(macro)
	if #macro.body > ns.MACRO_BODY_MAX_LENGTH then
		return "long", #macro.body
	end
	return nil
end

--[[
	Whether name is one the add-on gave the same kind of WoW macro (the spell's own, its focus copy or a
	Duplicate) of a spell this macro replaced in its group, which it took over (see ns.HandOverMacro in
	Features/Enhanced-Spellbook/Group-Handover.lua).
]]
local function IsReplacedSpellsName(macro, name)
	if macro.rank then
		return false
	end
	local suffix = macro.copy and " " .. macro.copy or macro.focus and ns.FOCUS_SUFFIX or ""
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
	Rewrites the WoW macro at index if its body differs from the page's and fits. One still under its name
	from before the prefix (MIGRATION (remove after 2026-11-23)), under the old "~" prefix
	(MIGRATION (remove after 2026-11-26)), or under the name of a replaced spell whose macro it took
	over ("-Bear Form", now Dire Bear Form's), is renamed, its ownership record moving with it; a name the
	player gave it is kept, and recorded as the add-on's while the body carries this macro's tag, so Delete
	Macros still finds it. A new name sorts the macro elsewhere in its list, so this returns the index it
	ends up at.
]]
local function SyncAt(macro, index)
	if index == 0 then
		return 0
	end
	local name, icon, body = GetMacroInfo(index)
	local newBody = body ~= macro.body and Fits(macro) and macro.body or nil
	-- only a profession's icon is the add-on's to set (see ns.WowMacroIcon); any other keeps the player's
	local wantIcon = ns.WowMacroIcon(macro)
	local newIcon = wantIcon ~= macro.macroIcon and icon ~= wantIcon and wantIcon or nil
	local renamed = IsReplacedSpellsName(macro, name)
	-- MIGRATION (remove after 2026-11-23)
	renamed = renamed or name == LegacyMacroName(macro)
	-- MIGRATION (remove after 2026-11-26)
	renamed = renamed or name == OldPrefixName(macro)
	if not renamed then
		local owned = OwnedList(index)
		if owned[name] == nil and ns.BodyTag(body) == ns.MacroTag(macro) then
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
	The Blizzard Macro UI saves its edit box back over the selected macro when the selection changes and when it
	hides, which would revert a rewrite made while it is open. So nothing is written while it is shown: a sync
	waits for it to close, and the one-time OnHide hook then rewrites every macro. The frame is load-on-demand,
	so the hook goes in the first time a sync finds it.
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
	Rewrites this character's WoW macro for a page macro if its body has changed, and returns its index. One
	found by name gets its tag line here, and is recorded as the add-on's; indexes, when given, then lists it
	under its tag, so a second page macro of the same name in the same pass doesn't take it too. A rename
	moves macros about, so indexes is then read again.
]]
function ns.SyncMacro(macro, indexes)
	local index, found = ns.FindMacroIndex(macro, indexes)
	if IsMacroUIOpen() then
		return index
	end
	if index ~= 0 and found ~= "tag" then
		local name = GetMacroInfo(index)
		OwnedList(index)[name] = OwnerRecord(index)
		ns.AssignMacroTag(macro)
		if indexes then
			indexes.tags[ns.MacroTag(macro)] = index
			local named = indexes.names[name]
			for i = #named, 1, -1 do
				if named[i] == index then
					table.remove(named, i)
				end
			end
		end
	end
	local moved = SyncAt(macro, index)
	if moved ~= index and indexes then
		local fresh = ReadMacroIndexes()
		indexes.tags, indexes.names = fresh.tags, fresh.names
	end
	return moved
end

--[[
	Creates the macro on first use (character specific, or general once those slots are full), then puts
	it on the cursor so it can be dropped on an action bar. A macro of the same name the add-on didn't make is
	left alone, and the new one sits beside it under the same name.
]]
function ns.PickupMacro(macro)
	if InCombatLockdown() then
		ns.ShowUIError(ERR_NOT_IN_COMBAT)
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
		local numAccount, numCharacter = GetNumMacros()
		local perCharacter = numCharacter < MaxCharacterMacros()
		if not perCharacter and numAccount >= MaxAccountMacros() then
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

--[[
	Rewrites the existing WoW macros whose body no longer matches the page (a setting or config changed). In
	combat it waits for combat to end; while the Blizzard Macro UI is open, for it to close (IsMacroUIOpen).
]]
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
