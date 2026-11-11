local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff Duty -- who in your group is missing a buff YOU can give.

    Reads this client's ns.BUFF_DUTY_SPELLS, keeps the rows for your class
    whose spells you know, and on every roster or aura change works out, per
    party, which members lack each buff. What it finds goes to
    Features/Buff-Duty/Buff-Duty-Frame.lua as plain section tables to draw; no logic
    file draws the window. A member only appears while they are
    missing something, and a party only while one of its members is, so a fully
    buffed raid shows no window at all.

    The other Buff Duty files share state through ns.BuffDuty; this file owns
    the refresh, the When to Show check and setup.

    Nothing is read in combat: the window's buttons are secure and can't be
    redrawn there anyway (see the frame file), so a change mid-fight waits for
    PLAYER_REGEN_ENABLED.
]]

local BuffDuty = ns.BuffDuty
local HasAnythingToOffer = BuffDuty.HasAnythingToOffer
local PetUnitOf = BuffDuty.PetUnitOf
local MarkAurasDirty = BuffDuty.MarkAurasDirty
local MarkAllAurasDirty = BuffDuty.MarkAllAurasDirty

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local inCombat = false
local settingsPending = false
local refreshQueued = false

-- Long enough to fold a raid-wide buff landing on 40 people into one redraw.
local REFRESH_DELAY = 0.3

--[[
    A redraw on a timer, for the changes no event reaches the window with: a
    buff running down under Refresh Under, and a member dying, reviving or
    dropping offline. Neither needs a full re-read: Has compares cached
    expirations with the clock, and ReadAuras re-reads a record whose unit has
    died, revived or changed connection since it was read.
]]
local BACKSTOP_INTERVAL = 3

--------------------------------------------------------------------------------
-- Refresh
--------------------------------------------------------------------------------

--[[
    Every section the window would show, in display order: your own buffs,
    then the players outside your group (Target, Return the Favor), then the
    parties, which the frame lays out two to a row in a raid. The Buff
    Key reads the same list, so it casts only what the window offers, but for
    a dead friendly target, whom it resurrects even with the Target list off.
]]
function BuffDuty.BuildSections()
	BuffDuty.refreshSeconds = ns.db.global.buffWindow.refreshMinutes * 60
	local sections = {}
	BuffDuty.AddSelfSection(sections)
	BuffDuty.AddOutsiderSections(sections)
	BuffDuty.AddGroupSections(sections)
	return sections
end

--[[
    When to Show: your class ticked, then Solo, In Party or In Raid, whichever
    you are now, switched on, and In Instance kept to dungeons, raids,
    battlegrounds and arenas. The Buff Key asks the same, so it casts nothing the window
    hides.
]]
function BuffDuty.ShowsHere()
	local db = ns.db.global.buffWindow
	local _, class = UnitClass("player")
	if db.showClasses[class] == false then
		return false
	end
	local show, where
	if IsInRaid() then
		show, where = db.showRaid, db.showRaidWhere
	elseif IsInGroup() then
		show, where = db.showParty, db.showPartyWhere
	else
		show, where = db.showSolo, db.showSoloWhere
	end
	if not show then
		return false
	end
	return where ~= Data.BUFF_DUTY_WHERE.INSTANCE or (IsInInstance())
end

--[[
    Whether the Party-Buffs row could have anything to count: in a group, with
    Ask Other Classes for Buffs on. It needs nothing castable of yours, so a
    class with no buffs to give still sees what the group is missing.
]]
local function WatchesPartyBuffs()
	return IsInGroup() and ns.db.global.buffWindow.askOtherClasses
end

local function Refresh()
	if not BuffDuty.isSetUp or not ns.db then
		return
	end
	-- Combat: the buttons can't be redrawn, and REGEN_ENABLED re-runs this.
	if inCombat or InCombatLockdown() then
		return
	end

	local db = ns.db.global.buffWindow
	if
		not db.enabled
		or not (HasAnythingToOffer() or WatchesPartyBuffs())
		or ns.AreAurasSecret()
		or not BuffDuty.ShowsHere()
	then
		ns.HideBuffDuty()
		return
	end

	local sections = BuffDuty.BuildSections()
	-- The raid buffs the group is missing ride along as Party-Buffs (Buff-Duty-Other-Classes.lua).
	local otherBuffs = BuffDuty.BuildOtherClassBuffs()
	-- Either one keeps the window up: Party-Buffs alone still shows it.
	if #sections == 0 and #otherBuffs == 0 then
		ns.HideBuffDuty()
	else
		ns.RenderBuffDuty(sections, otherBuffs)
	end
end

-- Every trigger funnels through here, so a burst of them costs one Refresh.
function ns.RequestBuffDutyRefresh()
	if refreshQueued then
		return
	end
	refreshQueued = true
	C_Timer.After(REFRESH_DELAY, function()
		refreshQueued = false
		Refresh()
	end)
end

local function ApplySettings()
	settingsPending = not ns.ApplyBuffDutySettings()
end

-- Re-applies the window's settings, its position included, once combat ends.
function ns.QueueBuffDutySettings()
	settingsPending = true
end

-- The options panel's entry point after any Buff Duty setting changes.
function ns.RefreshBuffDuty()
	if not BuffDuty.isSetUp then
		return
	end
	BuffDuty.BuildBuffs()
	ApplySettings()
	MarkAllAurasDirty()
	ns.RequestBuffDutyRefresh()
	-- Your class ticked or unticked turns the window's events on or off with it.
	ns.UpdateBuffDutyEvents()
end

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
    Buff Duty on the class you're playing: the feature switch on, your class
    ticked under Classes, and the window not closed this session. The mini-map
    button works per class through these, so turning it off on a rogue leaves
    it up on a druid. Turning it on ticks your class and flips the switch on
    with it, which also undoes a close.
]]
function ns.IsBuffDutyOnForClass()
	local _, class = UnitClass("player")
	return not hiddenThisSession and ns.IsBuffDutyOn() and ns.db.global.buffWindow.showClasses[class] ~= false
end

function ns.SetBuffDutyForClass(on)
	local _, class = UnitClass("player")
	ns.db.global.buffWindow.showClasses[class] = on
	ns.SetBuffDutyOn(on or ns.IsBuffDutyOn())
end

--[[
    Buff Duty's settings are account-wide, so a profile switch, copy or reset
    leaves them as they were; Features/Core.lua calls this anyway so a Reset
    never leaves the window reading a stale table.
]]
function ns.ApplyBuffDutyProfile()
	if not BuffDuty.isSetUp then
		return
	end
	ns.PopulateBuffDutyAudience()
	ns.RefreshBuffDuty()
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

-- A change that can move who a unit token names, or what the window offers.
local function RequestFullRefresh()
	MarkAllAurasDirty()
	ns.RequestBuffDutyRefresh()
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--[[
    Called from Buff-Duty-Events.lua's UNIT_AURA handler. It is
    subscribed unfiltered while Buff Duty is on for your class, so nameplates
    arrive here too; only the units the window reads are worth a refresh.
    Nothing is queued while the window is off for your class or in combat:
    turning it on and PLAYER_REGEN_ENABLED each request a fresh read.
]]
function ns.OnBuffDutyUnitAura(unit)
	if not BuffDuty.isSetUp or inCombat or not ns.IsPlain(unit) or not unit then
		return
	end
	-- The unit first: nameplates make most of these, and the string tests are cheaper than the class check.
	if
		not (
			unit == "player"
			or unit == "target"
			or unit == "targetpet"
			or unit == "pet"
			or unit:find("^party%d")
			or unit:find("^raid%d")
			or unit:find("^partypet%d")
			or unit:find("^raidpet%d")
		)
	then
		return
	end
	if ns.IsBuffDutyOnForClass() and (HasAnythingToOffer() or WatchesPartyBuffs()) then
		MarkAurasDirty(unit)
		ns.RequestBuffDutyRefresh()
	end
end

--[[
    Whether the window has anything to keep up: set up, and Buff Duty on for your
    class. Turning it on runs ns.RefreshBuffDuty, which re-reads everyone, so
    nothing these handlers skip while it is off is missed.
]]
local function IsWatching()
	return BuffDuty.isSetUp and ns.IsBuffDutyOnForClass()
end

--[[
    The aura cache is keyed by GUID, so a roster change or a new target needs no
    re-read of anyone already read: a token that now names someone else finds
    that player's own record. A player the window hasn't read yet is read
    fresh anyway. In combat these wait: PLAYER_REGEN_ENABLED prunes the cache
    and reads everyone fresh. A roster change mid-fight also dims every icon,
    since the secure buttons still point at the old roster until then.
]]
local function OnGroupRosterUpdate()
	if not IsWatching() then
		return
	end
	if inCombat then
		ns.MarkBuffDutyRosterStale()
		return
	end
	BuffDuty.PruneAuraCache()
	ns.RequestBuffDutyRefresh()
end

local function OnUnitPet(unit)
	if not IsWatching() or inCombat then
		return
	end
	local pet = ns.IsPlain(unit) and unit and PetUnitOf(unit)
	if pet and UnitExists(pet) then
		MarkAurasDirty(pet)
	end
	ns.RequestBuffDutyRefresh()
end

-- A new target mid-fight dims the icons as a roster change does: the target's row still names the old one.
local function OnPlayerTargetChanged()
	if not IsWatching() then
		return
	end
	if inCombat then
		ns.MarkBuffDutyRosterStale()
		return
	end
	for _, unit in ipairs({ "target", "targetpet" }) do
		if UnitExists(unit) then
			MarkAurasDirty(unit)
		end
	end
	ns.RequestBuffDutyRefresh()
end

local function OnSpellsChanged()
	if BuffDuty.isSetUp then
		BuffDuty.ForgetMyStrengths()
		BuffDuty.BuildBuffs()
		RequestFullRefresh()
	end
end

--[[
    A poison, imbue or oil going on or wearing off, a weapon swapped, and an
    item used up or bought: the Self Buffs icons read your weapons and bags,
    which no aura event reaches.
]]
local function RefreshForInventory()
	if IsWatching() and not inCombat then
		ns.RequestBuffDutyRefresh()
	end
end

local function OnUnitInventoryChanged()
	RefreshForInventory()
end

local function OnBagUpdateDelayed()
	RefreshForInventory()
end

local function OnPlayerRegenDisabled()
	inCombat = true
end

local function OnPlayerRegenEnabled()
	inCombat = false
	if not BuffDuty.isSetUp then
		return
	end
	if settingsPending then
		ApplySettings()
	end
	BuffDuty.PruneAuraCache()
	RequestFullRefresh()
end

-- The backstop's tick, which skips the redraw while the window is off for your class or in combat.
local function OnBackstopTick()
	if inCombat or not ns.IsBuffDutyOnForClass() then
		return
	end
	BuffDuty.PruneAuraCache()
	ns.RequestBuffDutyRefresh()
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

local backstop

--[[
    Starts the backstop while Buff Duty is on for your class and stops it while
    it is off, for ns.UpdateBuffDutyEvents, which drops the window's
    events along with it. Coming back on, the window re-reads your spells,
    since SPELLS_CHANGED was not heard while it was off.
]]
function ns.SetBuffDutyWatching(on)
	if not BuffDuty.isSetUp then
		return
	end
	if on and not backstop then
		backstop = C_Timer.NewTicker(BACKSTOP_INTERVAL, OnBackstopTick)
		OnSpellsChanged()
	elseif not on and backstop then
		backstop:Cancel()
		backstop = nil
	end
end

-- Run once from Core's login sequence, after the saved variables are live.
function ns.SetupBuffDuty()
	inCombat = InCombatLockdown() and true or false
	BuffDuty.BuildLookup()
	ns.buffDutyCategories = BuffDuty.BuildCategories(BuffDuty.entries)
	-- The Self-Buffs panel lists the Soulstone with the warlock's self buffs.
	local selfListed = { unpack(BuffDuty.selfEntries) }
	selfListed[#selfListed + 1] = BuffDuty.soulstoneEntry
	ns.buffDutySelfCategories = BuffDuty.BuildCategories(selfListed)
	ns.PopulateBuffDutyAudience()
	BuffDuty.BuildBuffs()
	ns.CreateBuffDutyFrame()
	ApplySettings()
	-- MIGRATION (remove after 2026-12-03): keys bound to the Buff Key's old commands move to its current one.
	ns.MigrateBuffKeys()
	BuffDuty.isSetUp = true
	ns.RequestBuffDutyRefresh()
	ns.UpdateBuffDutyEvents()
end

ns.SetBuffDutyEventHandler("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
ns.SetBuffDutyEventHandler("UNIT_PET", OnUnitPet)
ns.SetBuffDutyEventHandler("PLAYER_TARGET_CHANGED", OnPlayerTargetChanged)
ns.SetBuffDutyEventHandler("SPELLS_CHANGED", OnSpellsChanged)
ns.SetBuffDutyEventHandler("UNIT_INVENTORY_CHANGED", OnUnitInventoryChanged)
ns.SetBuffDutyEventHandler("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
ns.SetBuffDutyEventHandler("PLAYER_REGEN_DISABLED", OnPlayerRegenDisabled)
ns.SetBuffDutyEventHandler("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)
