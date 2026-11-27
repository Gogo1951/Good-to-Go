local _, ns = ...
local GetColor = ns.GetColor
local L = ns.L

--------------------------------------------------------------------------------
-- Macro Writing
--------------------------------------------------------------------------------

local macroSlotsWarned = false

local function WarnMacroSlots()
	if not macroSlotsWarned then
		macroSlotsWarned = true
		ns:PrintMessage(L["MESSAGE_MACRO_SLOTS_ARE_FULL"])
	end
end

--[[
    The macros appear silently in a tab most players never open, so say where.
    A timer, not the end of the pass: no single place knows the pass is over.
]]
local readyMessagePending = false

local function AnnounceMacrosReady()
	if readyMessagePending then
		return
	end
	readyMessagePending = true
	C_Timer.After(1, function()
		readyMessagePending = false
		ns:PrintMessage(
			string.format(L["MESSAGE_MACROS_READY_TAB"], GetColor("INFO") .. "/m|r" .. GetColor("TEXT"), GENERAL_MACROS)
		)
	end)
end

--[[
    No perCharacter argument, so the macros land in the General tab. Never pass
    1 to mean General: the client boolean-checks it, and 1 lands there only by
    accident. The last ns.MACRO_SLOT_CUSHION slots stay the player's; pcall and
    the nil check cover a full book (builds differ: error or nil).
]]
function ns.TryCreateMacro(macroName, icon, body)
	local numGeneral = GetNumMacros()
	local cap = MAX_ACCOUNT_MACROS or 120
	if (cap - numGeneral) <= ns.MACRO_SLOT_CUSHION then
		WarnMacroSlots()
		return false
	end

	local ok, newIndex = pcall(CreateMacro, macroName, icon, body)
	if ok and newIndex then
		AnnounceMacrosReady()
		return true
	end
	WarnMacroSlots()
	return false
end

-- On a false return the caller leaves its state key unset, so creation retries once a slot frees.
function ns.WriteMacroBody(macroName, body)
	local index = GetMacroIndexByName(macroName)
	if index == 0 then
		return ns.TryCreateMacro(macroName, ns.QUESTION_MARK_ICON, body)
	end
	if GetMacroBody(macroName) ~= body then
		EditMacro(index, macroName, ns.QUESTION_MARK_ICON, body)
	end
	return true
end

function ns.DeleteMacroByName(macroName)
	local index = GetMacroIndexByName(macroName)
	if index and index > 0 then
		DeleteMacro(index)
	end
end
