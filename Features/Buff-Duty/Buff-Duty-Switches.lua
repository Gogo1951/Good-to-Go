local _, ns = ...
local L = ns.L

--[[
    Buff-Duty-Switches -- Buff Duty's on and off: the feature switch, the
    per-class switch the mini-map button uses, whether it tracks the class
    you're playing, and the window's close button, which hides it for the
    rest of the session.
]]

--[[
    Whether the window's close button hid Buff Duty for the rest of this
    session. Never saved: a login or reload brings the window back, and so does
    turning Buff Duty on by any switch (the mini-map button, the feature switch,
    or ticking your class).
]]
local hiddenThisSession = false

function ns.ShowBuffDutyAgain()
	hiddenThisSession = false
end

--[[
    Buff Duty's feature switch, the one setter both copies of its options
    toggle and the per-class calls below use: it redraws the window and
    repaints every open panel. Turning it on clears the close button's hide.
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
	local registry = LibStub("AceConfigRegistry-3.0")
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		registry:NotifyChange(name)
	end
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
    not closed this session. The mini-map button works per class through
    these, so turning it off on a rogue leaves it up on a druid. Turning it on
    ticks your class and flips the switch on with it, which also undoes a close.
]]
function ns.IsBuffDutyOnForClass()
	return not hiddenThisSession and ns.IsBuffDutyTrackingForClass()
end

function ns.SetBuffDutyForClass(on)
	local _, class = UnitClass("player")
	ns.db.global.buffWindow.showClasses[class] = on
	ns.SetBuffDutyOn(on or ns.IsBuffDutyOn())
end

--[[
    The window's close button. Hides Buff Duty until the next login or reload,
    saving nothing, and says how to bring it back now or keep it off for your
    class. In combat the window stays up until combat ends, like any other
    change to it.
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
