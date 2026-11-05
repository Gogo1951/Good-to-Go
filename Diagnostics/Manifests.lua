local _, ns = ...

--------------------------------------------------------------------------------
-- Manifests
--------------------------------------------------------------------------------

--[[
    The manifest tables the framework reads. Each feature's
    Diagnostics/Manifests-<Feature>.lua appends its own rows, so every report
    covers the whole add-on and a feature's rows sit beside the probes that
    describe it:

      ns.DIAGNOSTIC_API_CHECKS     { label, check } per API the add-on calls or guards
      ns.DIAGNOSTIC_SPELLS         the spells the context probes report on
      ns.DIAGNOSTIC_NAME_LOOKUPS   every game record a player sees named by ID
      ns.DIAGNOSTIC_DATA_SOURCES   one Validate Data report per data file

    Two features shipping tables in one data file (Game-IDs) each name it with
    the same label, and their rows become one report: the later row's sources
    join the earlier one's.
]]
ns.DIAGNOSTIC_API_CHECKS = {}
ns.DIAGNOSTIC_SPELLS = {}
--[[
    The same spell rows, held under a second name the probes read: Automated
    Appreciation's Features/Automated-Appreciation/Tracked-Lookups.lua replaces
    ns.DIAGNOSTIC_SPELLS at login with its own per-class table, which its
    context report reads by class, so the rows appended here at load would
    otherwise be gone by the time a report runs.
]]
ns.DIAGNOSTIC_SPELL_ROWS = ns.DIAGNOSTIC_SPELLS
ns.DIAGNOSTIC_NAME_LOOKUPS = {}
ns.DIAGNOSTIC_DATA_SOURCES = {}

--[[
    An API check another feature's file already added under the same label is
    skipped, so a function two features both call prints once.
]]
local function IsRepeatedApiCheck(target, row)
	if type(row) ~= "table" or type(row[1]) ~= "string" or type(row[2]) ~= "function" then
		return false
	end
	for _, existing in ipairs(target) do
		if type(existing) == "table" and existing[1] == row[1] and type(existing[2]) == "function" then
			return true
		end
	end
	return false
end

function ns.AppendDiagnosticRows(target, rows)
	for _, row in ipairs(rows) do
		local merged = IsRepeatedApiCheck(target, row)
		if not merged and type(row) == "table" and row.label and row.sources then
			for _, existing in ipairs(target) do
				if existing.label == row.label and existing.sources then
					for _, source in ipairs(row.sources) do
						existing.sources[#existing.sources + 1] = source
					end
					merged = true
					break
				end
			end
		end
		if not merged then
			target[#target + 1] = row
		end
	end
end
