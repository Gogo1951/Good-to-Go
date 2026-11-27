local _, ns = ...

--------------------------------------------------------------------------------
-- Restock Trace
--------------------------------------------------------------------------------

--[[
    The bank run's trace, into the Event Log only, while logging is on (a
    session flag that starts off at every login). Takes a TRACE_* key and its
    arguments, never built text, so a run with logging off does no string work.
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
