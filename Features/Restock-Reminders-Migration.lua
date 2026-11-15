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

    The reminders became one line each -- low and out counts -- with Verbose
    the opt-in, and every reminder ships Simple. The in-town reminder used to
    ship Verbose, and a player could have picked Verbose on any of the three,
    so each of the three modes goes back to its default once, for everyone.
    A player who wants Verbose again picks it, and the marker keeps this from
    undoing that on the next login.

    The Restocker's settings are account-wide (ns.db.global.restocker), so
    there is one table to fix, not one per profile. AceDB has already copied
    the defaults into the active table, so each mode is written as Simple
    rather than cleared -- a cleared key would read as nil until the next
    login -- and AceDB drops it from saved data on logout, since it now
    matches the default.

    Called from InitializeDatabase in Features/Core.lua, right after AceDB
    loads.
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
