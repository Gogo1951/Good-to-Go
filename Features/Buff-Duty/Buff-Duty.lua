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
    the refresh, the When to Show check and setup. The feature and per-class
    switches and the close button's hide are Buff-Duty-Switches.lua.

    The list isn't rebuilt in combat: the window's buttons are secure and can't
    be redrawn there anyway (see the frame file), so a change mid-fight waits
    for PLAYER_REGEN_ENABLED. Range and cooldown reads still run.
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
    Shadowform shuts out Holy spells. It is read once per build, so the icons
    below can leave out anything marked noShadowform (Fortitude, Divine
    Spirit, Fear Ward, Inner Fire, Resurrection) while you are in it.
]]
local SHADOWFORM_SPELL_ID = 15473

local function InShadowform()
	for i = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not data then
			return false
		end
		if ns.IsPlain(data.spellId) and data.spellId == SHADOWFORM_SPELL_ID then
			return true
		end
	end
	return false
end

-- Whether `buff` (or the resurrection) can't be cast in the form you are in.
function BuffDuty.ShutOut(buff)
	return BuffDuty.inShadowform and buff.noShadowform or false
end

--[[
    Every section the window would show, in display order: your own buffs,
    then the players outside your group (Target, Return the Favor), then the
    parties, which the frame lays out two to a row in a raid. The Buff
    Key reads the same list, so it casts only what the window offers, but for
    a dead friendly target, whom it resurrects even with the Target list off.
]]
function BuffDuty.BuildSections()
	BuffDuty.refreshSeconds = ns.db.global.buffWindow.refreshMinutes * 60
	BuffDuty.inShadowform = InShadowform()
	local sections = {}
	BuffDuty.AddSelfSection(sections)
	BuffDuty.AddOutsiderSections(sections)
	BuffDuty.AddGroupSections(sections)
	return sections
end

--[[
    When to Show: your class ticked, then the group context you are in now
    (ns.GetGroupContext: Solo, Party, Raid or Battleground) ticked, and for
    the first three, In Instance kept to inside an instance. A battleground is
    always one, so it has no where of its own. The Buff Key asks the same, so
    it casts nothing the window hides.
]]
function BuffDuty.ShowsHere()
	local db = ns.db.global.buffWindow
	local _, class = UnitClass("player")
	if db.showClasses[class] == false then
		return false
	end
	local context = ns.GetGroupContext()
	if not ns.IsGroupContextOn(db.showIn, context) then
		return false
	end
	return db.showWhere[context] ~= Data.BUFF_DUTY_WHERE.INSTANCE or (IsInInstance())
end

--[[
    Whether the Party-Buffs row could have anything to count: in a group, with
    Ask for Buffs on. It needs nothing castable of yours, so a
    class with no buffs to give still sees what the group is missing.
]]
local function WatchesPartyBuffs()
	return IsInGroup() and ns.db.global.buffWindow.askOtherClasses
end

--[[
    Whether the Target row could ask your target for a buff of theirs
    (Buff-Duty-Asks.lua): Your Target and Ask Your Target for Buffs both on. Like
    Party-Buffs, it needs nothing castable of yours, so a warrior can still
    ask a priest for Fortitude.
]]
local function WatchesTargetAsks()
	local db = ns.db.global.buffWindow
	return db.targetEnabled and db.askTarget
end

-- Whether the window could have anything to show: something of yours to cast, or something to ask for.
local function HasAnythingToShow()
	return HasAnythingToOffer() or WatchesPartyBuffs() or WatchesTargetAsks()
end

local function Refresh()
	if not BuffDuty.isSetUp or not ns.db then
		return
	end
	-- Combat: the buttons can't be redrawn, and REGEN_ENABLED re-runs this.
	if inCombat or InCombatLockdown() then
		return
	end

	-- The close button hides the window for the session (ns.IsBuffDutyOnForClass) while its data keeps up.
	if not ns.IsBuffDutyOnForClass() or not HasAnythingToShow() or not BuffDuty.ShowsHere() then
		ns.HideBuffDuty()
		return
	end
	--[[
	    Where the game hides auras from add-ons (WoW Forever, in places such as
	    battlegrounds), the window can't tell who is missing what. A window
	    that When to Show lets appear, and that its close button hasn't hidden
	    this session, says so once a session instead of staying away without
	    a word.
	]]
	if ns.AreAurasSecret() then
		ns.WarnOnce(L["BUFF_DUTY_AURAS_HIDDEN"], "BUFF_DUTY_AURAS_HIDDEN")
		ns.HideBuffDuty()
		return
	end

	--[[
	    A read or redraw that errors hides the window rather than leave the
	    last one up: its buttons would cast at whoever "target" names now.
	    The error still reaches the error handler (BugSack and the like).
	]]
	local sections, otherBuffs
	-- One read of the roster serves every section (BuffDuty.HoldGroupMembers).
	BuffDuty.HoldGroupMembers(true)
	local built = xpcall(function()
		sections = BuffDuty.BuildSections()
		-- The raid buffs the group is missing ride along as Party-Buffs (Buff-Duty-Other-Classes.lua).
		otherBuffs = BuffDuty.BuildOtherClassBuffs()
	end, geterrorhandler())
	BuffDuty.HoldGroupMembers(false)
	-- Either one keeps the window up: Party-Buffs alone still shows it.
	if not built or (#sections == 0 and #otherBuffs == 0) then
		ns.HideBuffDuty()
	elseif not xpcall(ns.RenderBuffDuty, geterrorhandler(), sections, otherBuffs) then
		ns.HideBuffDuty()
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

-- The options panel's entry point after any Buff Duty setting changes; it ends in ns.RefreshSettings.
function ns.RefreshBuffDuty()
	if not BuffDuty.isSetUp then
		ns.RefreshSettings()
		return
	end
	BuffDuty.BuildBuffs()
	ApplySettings()
	MarkAllAurasDirty()
	ns.RequestBuffDutyRefresh()
	-- Your class ticked or unticked turns the window's events on or off with it.
	ns.UpdateBuffDutyEvents()
	ns.RefreshSettings()
end

--[[
    Buff Duty's settings are account-wide except its Scrolls choices, which
    ride the profile, so a profile switch, copy or reset can change what it
    offers; Features/Core.lua calls this so the window never reads a stale
    table.
]]
function ns.ApplyBuffDutyProfile()
	if not BuffDuty.isSetUp then
		return
	end
	ns.PopulateBuffDutyAudience()
	ns.RefreshBuffDuty()
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
    subscribed unfiltered while Buff Duty tracks your class, so nameplates
    arrive here too; only the units the window reads are worth a refresh.
    Nothing is queued while Buff Duty is off for your class or in combat:
    turning it on and PLAYER_REGEN_ENABLED each request a fresh read.
]]
local WATCHED_UNITS = { player = true, target = true, targetpet = true, pet = true }
for i = 1, 4 do
	WATCHED_UNITS["party" .. i], WATCHED_UNITS["partypet" .. i] = true, true
end
for i = 1, 40 do -- a raid's most members
	WATCHED_UNITS["raid" .. i], WATCHED_UNITS["raidpet" .. i] = true, true
end

function ns.OnBuffDutyUnitAura(unit)
	if not BuffDuty.isSetUp or inCombat or not ns.IsPlain(unit) or not unit then
		return
	end
	-- The unit first: nameplates make most of these, and one lookup is cheaper than the class check.
	if not WATCHED_UNITS[unit] then
		return
	end
	if ns.IsBuffDutyTrackingForClass() and HasAnythingToShow() then
		MarkAurasDirty(unit)
		ns.RequestBuffDutyRefresh()
	end
end

--[[
    Whether Buff Duty has anything to keep up: set up, and tracking your
    class, closed window or not. Turning it on runs ns.RefreshBuffDuty, which
    re-reads everyone, so nothing these handlers skip while it is off is missed.
]]
local function IsWatching()
	return BuffDuty.isSetUp and ns.IsBuffDutyTrackingForClass()
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
	-- Leaving the raid (or it turning into a party) folds every group again for the next one.
	if not IsInRaid() then
		BuffDuty.ResetGroupFolds()
	end
	-- Joining a group brings back a window the close button hid.
	if ns.NoteBuffDutyGroup() then
		ns.RefreshBuffDuty()
	end
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

--[[
    A new target mid-fight dims the icons as a roster change does: the target's
    row still names the old one. Out of combat the old target's icons go at
    once and the window redraws now, not after REFRESH_DELAY: in between, a
    click on them would cast at the new target.
]]
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
	ns.DropBuffDutyTargetIcons()
	Refresh()
end

local function OnSpellsChanged()
	if BuffDuty.isSetUp then
		BuffDuty.ForgetMyStrengths()
		BuffDuty.BuildBuffs()
		-- a resurrection learned or lost turns the combat log on or off with it
		ns.SyncBuffDutyCombatLog()
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

-- The backstop's tick, which skips the redraw while Buff Duty is off for your class or in combat.
local function OnBackstopTick()
	if inCombat or not ns.IsBuffDutyTrackingForClass() then
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
    Starts the backstop while Buff Duty tracks your class and stops it while
    it doesn't, for ns.UpdateBuffDutyEvents, which drops the window's
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
	--[[
	    The Self-Buffs panel lists every buff you can put on yourself: your
	    class's self buffs, its group buffs (timed for you; Group Buffs says
	    who else gets them), and the Soulstone with the warlock's.
	]]
	local selfListed = { unpack(BuffDuty.selfEntries) }
	for _, entry in ipairs(BuffDuty.entries) do
		selfListed[#selfListed + 1] = entry
	end
	selfListed[#selfListed + 1] = BuffDuty.soulstoneEntry
	ns.buffDutySelfCategories = BuffDuty.BuildCategories(selfListed)
	-- The consumables any class can use have pages of their own (Options-Buff-Duty-Consumables.lua).
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
