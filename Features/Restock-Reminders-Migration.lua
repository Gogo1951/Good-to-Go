local _, ns = ...

--------------------------------------------------------------------------------
-- Restock Reminders onto Simple
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-12-13)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    three pieces together:
      1. this file
      2. its line in all four flavor TOCs (Good-to-Go_Vanilla.toc, _TBC.toc,
         _Camelot.toc and _Mists.toc)
      3. the ns.MoveRestockRemindersOntoSimple() call in Features/Core.lua
    The remindersMovedOntoSimple marker it leaves in saved data is harmless
    once the shim is gone.

    Every reminder ships Simple, so each of the three modes goes back to
    Simple once, for everyone; the marker keeps a later Verbose pick from
    being undone on the next login.

    The settings are account-wide (ns.db.global.restocker): one table, not one
    per profile. AceDB has already copied the defaults into the active table,
    so each mode is written as Simple rather than cleared (a cleared key reads
    nil until the next login); AceDB drops it on logout as it matches the
    default.
]]

local MODE_KEYS = { "restockReminderMode", "merchantReminderMode", "bankReminderMode" }

function ns.MoveRestockRemindersOntoSimple()
	local restocker = ns.db.global.restocker
	if type(restocker) ~= "table" or rawget(restocker, "remindersMovedOntoSimple") then
		return
	end
	for _, key in ipairs(MODE_KEYS) do
		rawset(restocker, key, ns.REMINDER_SIMPLE)
	end
	rawset(restocker, "remindersMovedOntoSimple", true)
end
