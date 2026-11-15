local _, ns = ...

--[[
    The in-town reminder: on arriving somewhere resting (an inn or a city),
    while anything on the list is low or out, the counts and, in verbose mode,
    each item, with the reminder sound if it is on. Also the arming that keeps
    a /reload from counting as an arrival.
]]

--------------------------------------------------------------------------------
-- Entering Town
--------------------------------------------------------------------------------

--[[
    Resting status is the game's own "you are somewhere with vendors" signal --
    it turns on in inns and cities and nowhere else -- so it is what the reminder
    keys off rather than a zone list we would have to maintain.

    Only a not-resting to resting transition counts, so this reminds you on
    ARRIVING in town rather than every time the flag twitches while you are in
    one -- and logging in counts as arriving, see the arming block below.

    Three things reach the check, because one signal does not cover every way of
    arriving:

      PLAYER_UPDATE_RESTING  -- walking in. Fires on both edges and can repeat,
                                which the transition rule already absorbs.
      PLAYER_ENTERING_WORLD  -- logging in, hearthing, portalling, or stepping
                                out of an instance. The resting flag is part of
                                the state the client syncs across a loading
                                screen, so no update event follows and
                                walking-in was the only arrival that ever fired.
      PLAYER_CONTROL_GAINED  -- landing off a flight path; see the taxi rule.

    Both halves are gated on something being low or out (ns.SplitRestockShortfall):
    a reminder to restock when there is nothing worth a trip is noise too. Both its switches ship on.
]]
local wasResting = nil

--[[
    A flight path crosses inns and towns the whole way, and the resting flag
    flickers on and off with them. None of those is an arrival -- you cannot
    shop from the back of a gryphon -- so a taxi counts as NOT IN TOWN for as
    long as it lasts, and the recorded state is forced to match. That is what
    leaves a genuine not-resting to resting edge for the landing to trip:
    PLAYER_CONTROL_GAINED re-checks once control is back and UnitOnTaxi has
    cleared, so touching down at a town flight master still reminds you.
]]
local function OnTaxi()
	return UnitOnTaxi("player") and true or false
end

--[[
    The quiet window after a reminder. Arrivals cluster -- a hearth lands you in
    an inn inside a city, and a quick errand in and out of an instance re-crosses
    the same boundary -- and each of those is one trip to town, not three
    reminders. Measured from the reminder, not from the arrival, so a suppressed
    check (nothing short, everything off) never starts the clock.
]]
local REMINDER_COOLDOWN = 60
local lastReminderAt = nil

--[[
    How long to let an arrival settle before reading it. Resting status and the
    bag counts the shortfall is built from both land after the loading screen,
    and after a flight the taxi flag clears a moment behind control returning --
    reading either too early reports the trip you just left.

    A login settles slower than a zone change and waits longer still -- past the
    loading-screen flurry, past the add-on's own post-login work, and well past
    the item data the login asks for (RequestListItems), so a Verbose reminder
    prints each entry's real link rather than "Loading item". The shortfall
    is read at the END of that pause, not the start, so a bag that finishes
    filling in the meantime is counted and a list that is no longer short says
    nothing.
]]
local ARRIVAL_SETTLE_DELAY = 2
local LOGIN_SETTLE_DELAY = 5

--------------------------------------------------------------------------------
-- Arming
--------------------------------------------------------------------------------

--[[
    Nothing reminds until PLAYER_ENTERING_WORLD has said what kind of entry this
    was, because the two kinds want opposite things and the resting events during
    a load arrive too early to tell them apart:

      Logging in IS an arrival -- you have just walked up to the game -- so a
      character who logs in resting gets the reminder. The gate keeps that
      consistent: an inn fires a late PLAYER_UPDATE_RESTING and a city does
      not, so without it the same standing-in-town login would remind you or
      not depending on which side of the door you logged out on.

      A /reload is NOT an arrival. It records where the character already is --
      so the next real arrival still has an edge to trip -- and says nothing,
      which is the whole reason the flag is seeded rather than simply cleared.

    Left false until then, the check does nothing at all rather than recording
    state: a resting event landing mid-load would otherwise consume the very
    transition the login is about to report.
]]
local remindersArmed = false

local function CheckResting()
	-- The delayed checks can land after the Restocker was switched off; they do nothing then.
	if not ns.restockerLoaded or not remindersArmed or not ns.IsRestockerEnabled() then
		return
	end

	if OnTaxi() then
		wasResting = false
		return
	end

	local resting = IsResting() and true or false
	if resting == wasResting then
		return
	end
	wasResting = resting

	if not resting then
		return
	end

	local settings = ns.restockSettings
	if not settings then
		return
	end
	if not settings.restockReminderChat then
		return
	end

	if lastReminderAt and (GetTime() - lastReminderAt) < REMINDER_COOLDOWN then
		return
	end

	local out, low = ns.BuildRestockReminderLists()
	if #out == 0 and #low == 0 then
		return
	end

	lastReminderAt = GetTime()

	--[[
	    Unlike the closing-window reminders, this one leads with its own nudge:
	    it is a prompt on arrival rather than a report on the way out. The sound
	    is the reminder's sub-option and plays only with it.
	]]
	ns.PrintRestockShortfall(ns.RestockTownHeadline(#out, #low), settings.restockReminderMode, out, low)

	if settings.restockReminderSound then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

function ns.OnRestockerUpdateResting()
	CheckResting()
end

--[[
    Arriving under your own steam: off a flight path (the common case for this
    event) or out of anything else that took control away. Delayed like the
    loading-screen arrivals, because UnitOnTaxi clears a moment after control
    returns and an immediate read would still call it a flight.
]]
function ns.OnRestockerControlGained()
	C_Timer.After(ARRIVAL_SETTLE_DELAY, CheckResting)
end

-- Arms the reminders without reporting where the character already is, as a /reload does.
function ns.ArmRestockerReminders()
	wasResting = IsResting() and true or false
	remindersArmed = true
end

--[[
    Asks the client for every item on the current Restock List it hasn't cached,
    at login, so the links are ready when LOGIN_SETTLE_DELAY ends: a chat line
    printed with a "Loading item" link never updates.
]]
local function RequestListItems()
	local settings = ns.restockSettings
	local restockList = settings and settings.lists and settings.lists[settings.currentList]
	for _, record in pairs(restockList or {}) do
		local itemID = record.itemID
		if itemID and not C_Item.IsItemDataCachedByID(itemID) and C_Item.DoesItemExistByID(itemID) then
			C_Item.RequestLoadItemDataByID(itemID)
		end
	end
end

--[[
    The arrival check's part of PLAYER_ENTERING_WORLD (ns.OnRestockerEnteringWorld
    in Restocker-Events.lua). isReloadingUi is the only entry that is not an
    arrival: a login is one, and so is any other loading screen -- a hearth, a
    portal, an instance door. Both branches wait out the same settle before
    touching the resting flag, so a /reload cannot be reminded on by a resting
    event that beat the seeding.
]]
function ns.OnRestockerArrival(isInitialLogin, isReloadingUi)
	local delay = isInitialLogin and LOGIN_SETTLE_DELAY or ARRIVAL_SETTLE_DELAY
	if isInitialLogin then
		RequestListItems()
	end

	C_Timer.After(delay, function()
		if isReloadingUi then
			ns.ArmRestockerReminders()
			return
		end

		remindersArmed = true
		CheckResting()
	end)
end
