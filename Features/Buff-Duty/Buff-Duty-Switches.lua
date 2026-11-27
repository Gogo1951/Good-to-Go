local _, ns = ...
local L = ns.L

--[[
    Never saved: login or reload, joining a group from none, or turning Buff
    Duty on by any switch brings the window back.
]]
local hiddenThisSession = false

local wasInGroup = false

function ns.ShowBuffDutyAgain()
	hiddenThisSession = false
end

--[[
    Turning the window's events on passes resync, to catch up on the group
    you're already in without counting it as a join.
]]
function ns.NoteBuffDutyGroup(resync)
	local inGroup = IsInGroup()
	local joined = inGroup and not wasInGroup and not resync
	wasInGroup = inGroup
	if joined and hiddenThisSession then
		hiddenThisSession = false
		return true
	end
	return false
end

function ns.IsBuffDutyOn()
	return ns.db.global.buffWindow.enabled and true or false
end

-- The one setter for both copies of the feature switch and the per-class calls below.
function ns.SetBuffDutyOn(value)
	ns.db.global.buffWindow.enabled = value
	if value then
		hiddenThisSession = false
	end
	ns.RefreshBuffDuty()
end

-- Events, backstop and the Buff Key follow this, not OnForClass, so the key casts from fresh auras after a close.
function ns.IsBuffDutyTrackingForClass()
	local _, class = UnitClass("player")
	return ns.IsBuffDutyOn() and ns.db.global.buffWindow.showClasses[class] ~= false
end

function ns.IsBuffDutyOnForClass()
	return not hiddenThisSession and ns.IsBuffDutyTrackingForClass()
end

-- The mini-map menu calls this Paused.
function ns.IsBuffDutyHiddenThisSession()
	return hiddenThisSession and ns.IsBuffDutyTrackingForClass()
end

function ns.SetBuffDutyForClass(on)
	local _, class = UnitClass("player")
	ns.db.global.buffWindow.showClasses[class] = on
	ns.SetBuffDutyOn(on or ns.IsBuffDutyOn())
end

function ns.CloseBuffDuty()
	hiddenThisSession = true
	ns.RefreshBuffDuty()
	local _, class = UnitClass("player")
	ns:PrintMessage(
		L["BUFF_DUTY_CLOSED"]:format(
			ns.ClassName(class),
			ns.ClassName(class),
			L["BUFF_DUTY_WHEN_HEADER"],
			ns.GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r"
		)
	)
end
