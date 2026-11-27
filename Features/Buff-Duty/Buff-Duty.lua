local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    No rebuild in combat: the window's secure buttons can't be redrawn there,
    so a change mid-fight waits for PLAYER_REGEN_ENABLED. Range and cooldown
    reads still run.
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
    For what no event reaches: a buff running down under Refresh Under, and a
    member dying, reviving or dropping offline. Neither needs a full re-read.
]]
local BACKSTOP_INTERVAL = 3

--------------------------------------------------------------------------------
-- Refresh
--------------------------------------------------------------------------------

-- Shadowform shuts out Holy spells; read once per build.
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

function BuffDuty.ShutOut(buff)
	return BuffDuty.inShadowform and buff.noShadowform or false
end

-- The Buff Key reads this same list, so it casts only what the window offers.
function BuffDuty.BuildSections()
	BuffDuty.refreshSeconds = ns.db.global.buffWindow.refreshMinutes * 60
	BuffDuty.inShadowform = InShadowform()
	local sections = {}
	BuffDuty.AddSelfSection(sections)
	BuffDuty.AddOutsiderSections(sections)
	BuffDuty.AddGroupSections(sections)
	return sections
end

-- The Buff Key asks the same, so it casts nothing the window hides.
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

-- Needs nothing castable of yours, so a class with no buffs to give still sees what the group is missing.
local function WatchesPartyBuffs()
	return IsInGroup() and ns.db.global.buffWindow.askOtherClasses
end

-- Needs nothing castable of yours either, so a warrior can still ask a priest for Fortitude.
local function WatchesTargetAsks()
	local db = ns.db.global.buffWindow
	return db.targetEnabled and db.askTarget
end

local function HasAnythingToShow()
	return HasAnythingToOffer() or WatchesPartyBuffs() or WatchesTargetAsks()
end

local function Refresh()
	if not BuffDuty.isSetUp or not ns.db then
		return
	end
	if inCombat or InCombatLockdown() then
		return
	end

	if not ns.IsBuffDutyOnForClass() or not HasAnythingToShow() or not BuffDuty.ShowsHere() then
		ns.HideBuffDuty()
		return
	end
	-- With auras hidden (WoW Forever, in places such as battlegrounds), say so once rather than vanish without a word.
	if ns.AreAurasSecret() then
		ns.WarnOnce(L["BUFF_DUTY_AURAS_HIDDEN"], "BUFF_DUTY_AURAS_HIDDEN")
		ns.HideBuffDuty()
		return
	end

	--[[
	    An error hides the window rather than leave the last one up: its
	    buttons would cast at whoever "target" names now.
	]]
	local sections, otherBuffs
	BuffDuty.HoldGroupMembers(true)
	local built = xpcall(function()
		sections = BuffDuty.BuildSections()
		otherBuffs = BuffDuty.BuildOtherClassBuffs()
	end, geterrorhandler())
	BuffDuty.HoldGroupMembers(false)
	if not built or (#sections == 0 and #otherBuffs == 0) then
		ns.HideBuffDuty()
	elseif not xpcall(ns.RenderBuffDuty, geterrorhandler(), sections, otherBuffs) then
		ns.HideBuffDuty()
	end
end

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

function ns.QueueBuffDutySettings()
	settingsPending = true
end

function ns.RefreshBuffDuty()
	if not BuffDuty.isSetUp then
		ns.RefreshSettings()
		return
	end
	BuffDuty.BuildBuffs()
	ApplySettings()
	MarkAllAurasDirty()
	ns.RequestBuffDutyRefresh()
	ns.UpdateBuffDutyEvents()
	ns.RefreshSettings()
end

-- A profile switch, copy or reset can change what it offers, so the window never reads a stale table.
function ns.ApplyBuffDutyProfile()
	if not BuffDuty.isSetUp then
		return
	end
	ns.PopulateBuffDutyAudience()
	ns.RefreshBuffDuty()
end

local function RequestFullRefresh()
	MarkAllAurasDirty()
	ns.RequestBuffDutyRefresh()
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--[[
    UNIT_AURA is subscribed unfiltered, so nameplates arrive too. Nothing
    queued while off or in combat is lost: turning on and
    PLAYER_REGEN_ENABLED each read everyone fresh.
]]
local WATCHED_UNITS = { player = true, target = true, targetpet = true, pet = true }
for i = 1, 4 do
	WATCHED_UNITS["party" .. i], WATCHED_UNITS["partypet" .. i] = true, true
end
for i = 1, 40 do
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

-- Closed window or not. Turning it on re-reads everyone, so nothing skipped while off is missed.
local function IsWatching()
	return BuffDuty.isSetUp and ns.IsBuffDutyTrackingForClass()
end

--[[
    The aura cache is keyed by GUID, so a roster change needs no re-read: a
    token that now names someone else finds that player's own record. A
    roster change mid-fight dims every icon, since the secure buttons still
    point at the old roster.
]]
local function OnGroupRosterUpdate()
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
    Out of combat the old target's icons go at once and the window redraws
    now, not after REFRESH_DELAY: in between, a click on them would cast at
    the new target.
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
		ns.SyncBuffDutyCombatLog()
		RequestFullRefresh()
	end
end

-- Weapon buffs and bag items, which no aura event reaches.
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

-- Coming back on re-reads your spells: SPELLS_CHANGED wasn't heard while off.
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

function ns.SetupBuffDuty()
	inCombat = InCombatLockdown() and true or false
	BuffDuty.BuildLookup()
	ns.buffDutyCategories = BuffDuty.BuildCategories(BuffDuty.entries)
	-- The Self-Buffs panel also lists your group buffs (timed for you) and the Soulstone.
	local selfListed = { unpack(BuffDuty.selfEntries) }
	for _, entry in ipairs(BuffDuty.entries) do
		selfListed[#selfListed + 1] = entry
	end
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
