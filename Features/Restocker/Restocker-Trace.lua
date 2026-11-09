local _, ns = ...

--------------------------------------------------------------------------------
-- Restock Trace
--------------------------------------------------------------------------------

--[[
    The bank restock's step-by-step trace, written into the Diagnostic Tools
    Event Log as RESTOCKER_TRACE entries, never into chat. Gated on the log's
    runtime flag, which lives in memory and starts false at every login, so a
    player can never leave this on -- and the boolean is read before any string
    work, so a run with logging off pays one comparison per call.

    Developer-facing, so the text stays plain English and out of Locales/: each
    message is a TRACE_* format in ns.DiagnosticsStrings (Diagnostics/Diagnostics-Core.lua),
    passed here by key and looked up only once the gate is open.

    Called from Restocker-Bags.lua, Restocker-Bank-Moves.lua, Restocker-Bank-State.lua,
    Restocker-Bank-Visit.lua, Restocker-Bank-Tidy.lua and
    Restocker-Inventory-Model.lua.

    Takes the format's arguments rather than a pre-concatenated string, so the
    (potentially expensive) build only happens when the gate is open: prefer
    ns.RestockerDebug("TRACE_X", v) over building the text at the call site.
]]
function ns.RestockerDebug(key, ...)
	if not (ns.diagnostics and ns.diagnostics.logging) then
		return
	end
	local message = ns.DiagnosticsStrings[key]
	local count = select("#", ...)
	if count > 0 then
		-- Every value but a number goes through tostring: a nil reaching %s would throw inside the bank run.
		local args = { ... }
		for index = 1, count do
			if type(args[index]) ~= "number" then
				args[index] = tostring(args[index])
			end
		end
		message = string.format(message, unpack(args, 1, count))
	end
	ns:LogEventNow("RESTOCKER_TRACE", tostring(message))
end
