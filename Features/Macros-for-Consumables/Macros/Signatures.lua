local _, ns = ...

--------------------------------------------------------------------------------
-- Target Helpers
--------------------------------------------------------------------------------

local function HasFriendlyPlayerTarget()
	return UnitExists("target") and UnitIsFriend("player", "target") and UnitIsPlayer("target")
end
ns.HasFriendlyPlayerTarget = HasFriendlyPlayerTarget

--------------------------------------------------------------------------------
-- Target and Group Tracking
--------------------------------------------------------------------------------

--[[
    Busy events rescan only on a real change. Anything new that reads the
    target MUST join this signature (friendly player, self, friendly level,
    cannibalizable) or its macro goes stale. Nil until the first firing, so the
    first reading always counts as a change.
]]
local lastTargetFriendly, lastTargetIsSelf, lastTargetLevel, lastTargetCannibalizable
local lastGroupContext
local targetReadPending = false

--[[
    A restricted comparison (Forever, in combat) returns a secret that errors
    when tested, so a hidden reading keeps its last value: unchanged, never a
    flip. A hidden identity owes the whole reading until combat ends.
]]
function ns.TargetSignatureChanged()
	if ns.IsUnitIdentitySecret("target") then
		targetReadPending = true
		return false
	end
	targetReadPending = false
	local isFriendly = HasFriendlyPlayerTarget() and true or false
	local isSelf = lastTargetIsSelf
	if ns.CanCompareUnitTokens("target", "player") then
		isSelf = (UnitExists("target") and UnitIsUnit("target", "player")) and true or false
	end
	local level = isFriendly and UnitLevel("target") or nil
	local cannibalizable = false
	if ns.CannibalizeSwitchedOn() then
		cannibalizable = ns.TargetIsCannibalizable()
		if cannibalizable == nil then
			cannibalizable = lastTargetCannibalizable
		end
	end

	local changed = isFriendly ~= lastTargetFriendly
		or isSelf ~= lastTargetIsSelf
		or level ~= lastTargetLevel
		or cannibalizable ~= lastTargetCannibalizable
	lastTargetFriendly, lastTargetIsSelf, lastTargetLevel = isFriendly, isSelf, level
	lastTargetCannibalizable = cannibalizable
	return changed
end

function ns.RereadTargetIfPending()
	if not targetReadPending then
		return false
	end
	return ns.TargetSignatureChanged()
end

function ns.GroupSignatureChanged()
	local context = ns.GetGroupContext()
	local changed = context ~= lastGroupContext
	lastGroupContext = context
	return changed
end

function ns.ResetTargetTracking()
	lastTargetFriendly, lastTargetIsSelf, lastTargetLevel, lastTargetCannibalizable = nil, nil, nil, nil
	lastGroupContext = nil
	targetReadPending = false
end
