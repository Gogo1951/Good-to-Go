local _, ns = ...
local L = ns.L

--[[
    Buff-Duty-Switches -- Buff Duty's on and off: the feature switch, the
    per-class switch the mini-map menu's Toggle uses, whether it tracks the class
    you're playing, and the window's close button, which hides it for the
    rest of the session or until you join a group.
]]

--[[
    Whether the window's close button hid Buff Duty for the rest of this
    session. Never saved: a login or reload brings the window back, and so does
    joining a group (from none: a raid forming out of your party, or one
    member swapping for another, leaves it closed) and turning Buff Duty on by
    any switch (the mini-map menu's Toggle, the feature switch, or ticking your class).
]]
local hiddenThisSession = false

-- Whether you were in a group at the last roster change Buff Duty heard.
local wasInGroup = false

function ns.ShowBuffDutyAgain()
	hiddenThisSession = false
end

--[[
    Buff Duty's roster handler calls this on every GROUP_ROSTER_UPDATE, which
    a closed window still hears (the Buff Key needs it). Returns true when you
    just joined a group and that brought a closed window back. The window's
    events are off while Buff Duty isn't tracking your class, so turning them
    on (ns.UpdateBuffDutyEvents) passes resync to catch up on the group you're
    in without counting it as a join.
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

--[[
    Buff Duty's feature switch, the one setter both copies of its options
    toggle and the per-class calls below use: ns.RefreshBuffDuty redraws the
    window, every open panel and the menu. Turning it on clears the close
    button's hide.
]]
function ns.IsBuffDutyOn()
	return ns.db.global.buffWindow.enabled and true or false
end

function ns.SetBuffDutyOn(value)
	ns.db.global.buffWindow.enabled = value
	if value then
		hiddenThisSession = false
	end
	ns.RefreshBuffDuty()
end

--[[
    Whether Buff Duty keeps its data up for the class you're playing: the
    feature switch on and your class ticked under Classes. The window's
    events, its backstop and the Buff Key follow this, so the key still casts
    from fresh auras after the close button hides the window.
]]
function ns.IsBuffDutyTrackingForClass()
	local _, class = UnitClass("player")
	return ns.IsBuffDutyOn() and ns.db.global.buffWindow.showClasses[class] ~= false
end

--[[
    Buff Duty's window on the class you're playing: tracking, and the window
    not closed this session. The mini-map menu's Toggle works per class through
    these, so turning it off on a rogue leaves it up on a druid. Turning it on
    ticks your class and flips the switch on with it, which also undoes a close.
]]
function ns.IsBuffDutyOnForClass()
	return not hiddenThisSession and ns.IsBuffDutyTrackingForClass()
end

-- Whether the close button has hidden a window that's otherwise on for your class: the menu calls it Paused.
function ns.IsBuffDutyHiddenThisSession()
	return hiddenThisSession and ns.IsBuffDutyTrackingForClass()
end

function ns.SetBuffDutyForClass(on)
	local _, class = UnitClass("player")
	ns.db.global.buffWindow.showClasses[class] = on
	ns.SetBuffDutyOn(on or ns.IsBuffDutyOn())
end

--[[
    The window's close button. Hides Buff Duty until you join a group or the
    next login or reload, saving nothing, and says how to bring it back now or
    keep it off for your class. In combat the window stays up until combat
    ends, like any other change to it.
]]
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
