local _, ns = ...

--------------------------------------------------------------------------------
-- Entering Town
--------------------------------------------------------------------------------

--[[
    Resting is the game's own "somewhere with vendors" signal, so there is no
    zone list. Only a not-resting to resting edge counts. PLAYER_ENTERING_WORLD
    also checks, since no resting event follows a loading screen.
]]
local wasResting = nil

--[[
    The resting flag flickers along a flight path, so a taxi counts as not in
    town and the recorded state is forced to match, leaving a real edge for the
    landing to trip.
]]
local function OnTaxi()
	return UnitOnTaxi("player") and true or false
end

--[[
    Arrivals cluster (a hearth into an inn inside a city), and that is one trip.
    Measured from the last reminder, so a check that printed nothing never
    starts the clock.
]]
local REMINDER_COOLDOWN = 60
local lastReminderAt = nil

--[[
    Resting and bag counts land after a loading screen, and the taxi flag clears
    a moment after control returns; reading early reports the trip just left. A
    login waits longer, past the item data RequestListItems asks for, so a
    Verbose reminder prints real links.
]]
local ARRIVAL_SETTLE_DELAY = 2
local LOGIN_SETTLE_DELAY = 5

--------------------------------------------------------------------------------
-- Arming
--------------------------------------------------------------------------------

--[[
    Nothing reminds until PLAYER_ENTERING_WORLD says what kind of entry this
    was: a login is an arrival, a /reload only records where the character is.
    Until then the check records nothing, or a resting event mid-load would
    consume the edge the login is about to report.
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

	ns.PrintRestockShortfall(ns.RestockTownHeadline(#out, #low), settings.restockReminderMode, out, low)

	if settings.restockReminderSound then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

function ns.OnRestockerUpdateResting()
	CheckResting()
end

-- Delayed, because UnitOnTaxi clears a moment after control returns.
function ns.OnRestockerControlGained()
	C_Timer.After(ARRIVAL_SETTLE_DELAY, CheckResting)
end

-- Arms the reminders without reporting where the character already is, as a /reload does.
function ns.ArmRestockerReminders()
	wasResting = IsResting() and true or false
	remindersArmed = true
end

-- A chat line printed with a "Loading item" link never updates.
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
    Every loading screen but a /reload is an arrival. Both branches wait out the
    settle before touching the resting flag, so a resting event that beat the
    seeding can't remind on a /reload.
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
