local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Registration
--------------------------------------------------------------------------------

--[[
    For every event the add-on registers (ns.EVENT_NAMES, exported by
    Core.lua), report whether it is valid on this client
    (C_EventUtils.IsEventValid) and whether RegisterEvent succeeds. The probe
    frame registers then immediately unregisters each event with no handler
    attached, so nothing is ever processed. The list is sourced from Core so it
    can never drift from the events the add-on actually uses.
]]

local probeFrame

local function GetProbeFrame()
	if not probeFrame then
		probeFrame = CreateFrame("Frame")
	end
	return probeFrame
end

function ns:RunEventChecks()
	local lines = { GetClientHeader(), "" }
	local hasIsEventValid = type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
	local probe = GetProbeFrame()
	local failures = 0
	for _, event in ipairs(ns.EVENT_NAMES or {}) do
		local valid = "n/a"
		if hasIsEventValid then
			valid = C_EventUtils.IsEventValid(event) and "valid" or "INVALID"
		end
		local ok = pcall(probe.RegisterEvent, probe, event)
		if ok then
			probe:UnregisterEvent(event)
		else
			failures = failures + 1
		end
		lines[#lines + 1] = string.format("[%s] %s (IsEventValid: %s)", ok and "PASS" or "FAIL", event, valid)
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "All events register on this client."
	else
		lines[#lines + 1] = string.format("%d event(s) failed to register.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

function ns:RunApiChecks()
	local lines = { GetClientHeader(), "" }
	for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
		local ok, result = pcall(check[2])
		lines[#lines + 1] = ((ok and result) and "[PASS] " or "[FAIL] ") .. check[1]
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

function ns:BuildLibraryReport()
	local lines = { GetClientHeader(), "" }
	local names = {}
	for name in LibStub:IterateLibraries() do
		names[#names + 1] = name
	end
	table.sort(names)
	for _, name in ipairs(names) do
		lines[#lines + 1] = string.format("%s (minor %s)", name, tostring(LibStub.minors[name]))
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Options Tables
--------------------------------------------------------------------------------

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- The uiName AceConfig wants when asked for a table: any "Name-1.0" shape.
local VALIDATION_UI_NAME = "GoodToGoDiagnostics-1.0"

--[[
    Builds every options panel in ns.OPTIONS_REGISTRY as the Settings window
    would and runs AceConfigRegistry:ValidateOptionsTable over it, so a select
    with no values, or any other bad member, shows here instead of stopping
    the panel from opening. Validation runs directly, not through the getter's
    once-per-session cache, so a rerun checks the table as it is now. A panel
    this flavor never registers (Rank Watch on MoP Classic) is skipped.
]]
function ns:RunOptionsValidation()
	local lines = { GetClientHeader(), "" }
	local appNames = {}
	for _, appName in pairs(ns.OPTIONS_REGISTRY) do
		appNames[#appNames + 1] = appName
	end
	table.sort(appNames)

	local failures = 0
	for _, appName in ipairs(appNames) do
		local getter = AceConfigRegistry:GetOptionsTable(appName)
		if not getter then
			lines[#lines + 1] = string.format("[SKIP] %s (not registered on this client)", appName)
		else
			local ok, problem = pcall(function()
				local options = getter("dialog", VALIDATION_UI_NAME)
				AceConfigRegistry:ValidateOptionsTable(options, appName)
			end)
			if ok then
				lines[#lines + 1] = "[PASS] " .. appName
			else
				failures = failures + 1
				problem = string.gsub(tostring(problem), "^.-ValidateOptionsTable%(%): ", "")
				lines[#lines + 1] = string.format("[FAIL] %s: %s", appName, problem)
			end
		end
	end

	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "Every registered options panel validates on this client."
	else
		lines[#lines + 1] = string.format("%d options panel(s) failed to validate.", failures)
	end
	return table.concat(lines, "\n")
end
