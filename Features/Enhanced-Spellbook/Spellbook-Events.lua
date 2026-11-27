local _, ns = ...
local Refresh = ns.RefreshSpellbookPage
local UpdateMacroCount = ns.UpdateSpellbookMacroCount
local pages = ns.spellbookPages

--------------------------------------------------------------------------------
-- Refresh
--------------------------------------------------------------------------------

-- Returns whether a page was open.
function ns:RefreshOpenPages()
	local refreshed = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			Refresh(page)
			refreshed = true
		end
	end
	return refreshed
end

-- With the Spellbook off it does nothing, whoever asks, so the macros stay as they last were.
function ns:RefreshMacros()
	if not ns.IsSpellbookEnabled() then
		return
	end
	if ns:RefreshOpenPages() then
		return
	end
	ns.CollectMacros()
	ns.SyncAllMacros()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
	SPELLS_CHANGED fires several times in a row, so it redraws once per burst. With no page open the list is
	dropped for a lazy rebuild, unless a learned spell takes over a macro or moves a grouped one up, which
	rewrites now. What's Next redraws last: it maps each spell to its page from the new list.
]]
local spellsPending = false
-- the learned professions the last refresh read (OnSpellbookSkillLinesChanged, below)
local lastProfessionsKey
local CurrentProfessionsKey

local function RefreshForSpells()
	spellsPending = false
	lastProfessionsKey = CurrentProfessionsKey()
	ns.InvalidateSpellRankRows()
	local groupChanged = ns.GroupSpellLearned()
	if not ns:RefreshOpenPages() then
		wipe(ns.macros)
		if ns.db and (groupChanged or ns.HandOverDue()) then
			ns:RefreshMacros()
		end
	end
	if ns.RefreshWhatsNext then
		ns.RefreshWhatsNext()
	end
end

function ns:OnSpellsChanged()
	if not spellsPending then
		spellsPending = true
		C_Timer.After(0, RefreshForSpells)
	end
end

--[[
	On the Retail engine a profession learned or dropped arrives only by SKILL_LINES_CHANGED, after
	SPELLS_CHANGED has redrawn without it. It also fires on every weapon skill-up, so the page redraws only when
	the professions or their spells differ from the last read.
]]
local function ProfessionsKey(...)
	local key = ""
	for i = 1, select("#", ...) do
		local index = select(i, ...)
		if index then
			local _, _, _, _, numAbilities, spellOffset, skillLine = GetProfessionInfo(index)
			key = key .. (skillLine or 0) .. ":" .. (numAbilities or 0) .. ":" .. (spellOffset or 0) .. ";"
		else
			key = key .. "-;"
		end
	end
	return key
end

local READS_PROFESSIONS = ns.READS_PROFESSIONS

function CurrentProfessionsKey()
	return READS_PROFESSIONS and ProfessionsKey(GetProfessions()) or nil
end

function ns:OnSpellbookSkillLinesChanged()
	if not READS_PROFESSIONS then
		return
	end
	local key = CurrentProfessionsKey()
	if lastProfessionsKey == nil then
		lastProfessionsKey = key
	elseif key ~= lastProfessionsKey then
		ns:OnSpellsChanged()
	end
end

-- Gear changes Use Items and the Shoot macro, page open or not; a gear set swap fires once per slot.
local gearPending = false

function ns:OnPlayerEquipmentChanged()
	ns:InvalidateUsableSlots()
	if gearPending then
		return
	end
	gearPending = true
	C_Timer.After(0, function()
		gearPending = false
		-- In combat nothing can be written, so only an open page redraws; the rest waits for combat to end.
		if InCombatLockdown() then
			if not ns:RefreshOpenPages() then
				ns.QueueMacroSync()
			end
			return
		end
		ns:RefreshMacros()
	end)
end

-- Only the spells this add-on asked for count, not every load another add-on or a tooltip causes.
local refreshPending = false

function ns:OnSpellDataLoadResult(spellID)
	local pendingRank = ns.TakePendingRank(spellID)
	local wasRequested = ns.TakeRequestedSpell(spellID)
	-- a name that just loaded can complete a row the tooltip's ranks left out
	if wasRequested then
		ns.InvalidateSpellRankRows()
	end
	if refreshPending then
		return
	end
	-- the What's Next? tab lists unlearned spells whatever Show Unlearned Spells says
	local listsUnlearned = ns.ShowsUnlearned() or (ns.IsWhatsNextShown and ns.IsWhatsNextShown())
	if not (pendingRank or (wasRequested and listsUnlearned)) then
		return
	end
	refreshPending = true
	C_Timer.After(0, function()
		refreshPending = false
		ns:RefreshOpenPages()
		if ns.RefreshWhatsNext then
			ns.RefreshWhatsNext()
		end
	end)
end

-- UnitLevel still reports the old level while the event fires, so the tab reads statuses against the event's.
function ns:OnPlayerLevelUp(level)
	if ns.RefreshWhatsNext then
		ns.RefreshWhatsNext(level)
	end
end

--[[
	PET_BAR_UPDATE fires several times in a row, so the pet tabs redraw once per burst. Handlers are named for
	the Spellbook, since ns.OnUnitPet is the Feed Pet macro's.
]]
local petPending = false

local function PetChanged()
	ns.InvalidateSpellRankRows(true)
	if petPending then
		return
	end
	if not (ns.IsWhatsNextPetShown and ns.IsWhatsNextPetShown()) then
		return
	end
	petPending = true
	C_Timer.After(0, function()
		petPending = false
		ns.RefreshWhatsNextPet()
	end)
end

local function IsPlayerOrPet(unit)
	return unit == "player" or unit == "pet"
end

function ns:OnSpellbookUnitPet(unit)
	if IsPlayerOrPet(unit) then
		ns.QueueRankRewriteFor("pet")
		PetChanged()
	end
end

function ns:OnSpellbookUnitLevel(unit)
	if IsPlayerOrPet(unit) then
		ns.QueueRankRewriteFor("pet")
		PetChanged()
	end
end

function ns:OnSpellbookPetBarUpdate()
	PetChanged()
end

function ns:OnSpellbookBagUpdateDelayed()
	PetChanged()
end

-- Placing or removing an action only changes the glows; redraw them once per burst.
local glowsPending = false

local function RedrawGlows()
	glowsPending = false
	local bars
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			bars = bars or ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.UpdateMacroGlow(page.buttons[i], bars)
			end
			ns.UpdateMarkPlacedButton(page, bars)
		end
	end
end

function ns:OnActionbarSlotChanged(slot)
	if slot then
		ns.OnRankBarSlotChanged(slot)
	end
	if not glowsPending then
		glowsPending = true
		C_Timer.After(0, RedrawGlows)
	end
end

-- A pick in progress ends, since its slot can't be filled until combat is over.
function ns:OnPlayerRegenDisabled()
	ns.RewriteRanksBeforeCombat()
	ns.CancelSpellPick()
end

-- Syncing fires one per macro, so the tiles redraw once per burst.
local macrosPending = false

local function RedrawButtons()
	macrosPending = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			local bars = ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.SetMacroButton(page.buttons[i], page.buttons[i].macro, bars)
			end
			UpdateMacroCount(page)
			ns.UpdateMarkPlacedButton(page, bars)
		end
	end
end

function ns:OnUpdateMacros()
	if not macrosPending then
		macrosPending = true
		C_Timer.After(0, RedrawButtons)
	end
end
