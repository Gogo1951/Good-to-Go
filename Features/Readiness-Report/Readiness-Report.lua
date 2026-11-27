local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local GroupHasClass = ns.GroupHasClass
local PartyHasClass = ns.PartyHasClass

--[[
    SILENCE IS THE DEFAULT OUTPUT. A section with nothing wrong is not printed,
    and a clean report not at all: no all-clear line. Never add a line that
    fires when something is FINE.

        Good to Go // Readiness Report
        Good to Go // Missing Buffs : ... . Expiring Soon : ...
        Good to Go // Missing Items : ... . Damaged Gear : ...
        Good to Go // Character : ... . Non-combat Gear Equipped : ...

    Every line carries the brand: other add-ons' prints interleave, so an
    unbranded body line reads as someone else's.
]]

--------------------------------------------------------------------------------
-- Line Assembly
--------------------------------------------------------------------------------

-- No trailing stop: ns.ReadinessLine joins clauses with READINESS_CLAUSE_SEPARATOR.
function ns.ReadinessClause(label, values)
	if #values == 0 then
		return nil
	end
	return string.format(
		L["READINESS_CLAUSE_FORMAT"],
		GetColor("TITLE") .. label .. "|r",
		GetColor("TEXT") .. table.concat(values, L["LIST_SEPARATOR"]) .. "|r"
	)
end

--[[
    A |r resets to the default, not the enclosing color, so each clause re-opens
    TEXT after its label instead of relying on ns.PrintMessage's wrapper.
]]
function ns.ReadinessLine(...)
	local clauses = {}
	for index = 1, select("#", ...) do
		local clause = select(index, ...)
		if clause then
			clauses[#clauses + 1] = clause
		end
	end
	if #clauses == 0 then
		return nil
	end
	return table.concat(clauses, GetColor("SEPARATOR") .. L["READINESS_CLAUSE_SEPARATOR"] .. "|r")
end

local Clause = ns.ReadinessClause
local Line = ns.ReadinessLine

--------------------------------------------------------------------------------
-- Which Lines Can Show
--------------------------------------------------------------------------------

-- Shared with the panel's Example, so it never shows a line the real report would keep quiet about.
function ns.ReadinessAsksWellFed(_, reports)
	return reports.readinessWellFed and true or false
end

function ns.ReadinessAsksScrolls(settings, reports)
	if not reports.readinessScrolls then
		return false
	end
	for _, enabled in pairs(settings.scrollTypes or {}) do
		if enabled then
			return true
		end
	end
	return false
end

function ns.ReadinessAsksSoulstone(reports)
	return reports.readinessSoulstone and ns.isWarlock and ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulstone)
		or false
end

function ns.ReadinessAsksManaGem(reports)
	return reports.readinessManaGem and ns.isMage and ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateManaGem) or false
end

--------------------------------------------------------------------------------
-- Missing Buffs
--------------------------------------------------------------------------------

local function BuildMissingBuffs(settings, reports)
	local missing = {}
	local snapshot = ns.GetPlayerBuffSnapshot()

	--[[
	    TBC and later, the maintainer's choice: Era and Forever have flasks, but
	    an Era raid doesn't run on them. The option hides there to match.
	]]
	if reports.readinessFlask and ns.EXPANSION >= 2 and not ns.HasFlaskOrElixirs() then
		missing[#missing + 1] = L["READINESS_FLASK"]
	end

	if ns.ReadinessAsksWellFed(settings, reports) and snapshot.wellFedExpiration == nil then
		missing[#missing + 1] = ns.GetWellFedName()
	end

	-- The macro's gate: never for a Hunter too low for the food, nor a dead pet.
	if reports.readinessPetWellFed and ns.ShouldTrackPetFood() and ns.GetPetFoodBuffExpiration() == nil then
		missing[#missing + 1] = string.format(L["READINESS_PET_FORMAT"], ns.GetWellFedName())
	end

	--[[
	    Never from the bags alone: someone missing the buffs with no scrolls
	    would read as covered. A weaker buff with a stronger scroll carried still asks.
	]]
	if ns.ReadinessAsksScrolls(settings, reports) then
		local uncovered = false
		for scrollType, enabled in pairs(settings.scrollTypes or {}) do
			if enabled then
				local entry = snapshot.scrolls[scrollType]
				if not (entry and (entry.expiration or entry.conflictAmount)) then
					uncovered = true
				end
			end
		end
		if uncovered or ns.FindMissingScrolls(ns.scannedItemCounts, snapshot) then
			missing[#missing + 1] = L["READINESS_SCROLLS"]
		end
	end

	-- Asks the group. Only a Warlock who can put a stone up sees it; anyone else couldn't clear it.
	if ns.ReadinessAsksSoulstone(reports) and not ns.GroupHasSoulstone() and not ns.SoulstonesOnCooldown() then
		missing[#missing + 1] = L["READINESS_SOULSTONE"]
	end

	--[[
	    A Shaman in the player's own party covers the main hand only: their
	    totem's slot, reaching only their party. Not on Forever, where Windfury
	    Totem is a group buff that leaves the weapon alone.
	]]
	if reports.readinessMainHandBuff or reports.readinessOffHandBuff then
		local mainHandMissing, offHandMissing = ns.GetMissingWeaponBuffs()
		local totemCovers = not ns.WEAPON_ENCHANTS_STACK and PartyHasClass("SHAMAN")
		if reports.readinessMainHandBuff and mainHandMissing and not totemCovers then
			missing[#missing + 1] = MAINHANDSLOT
		end
		if reports.readinessOffHandBuff and offHandMissing then
			missing[#missing + 1] = SECONDARYHANDSLOT
		end
	end

	return missing
end

-- Under a minute gets its own phrase: "0 min" would look like a bug.
local function BuildExpiring(reports)
	local expiring = {}

	if not reports.readinessExpiring then
		return expiring
	end

	local threshold = reports.readinessExpiringThreshold
	for _, entry in ipairs(ns.GetExpiringBuffs(threshold)) do
		if entry.remaining < 60 then
			expiring[#expiring + 1] = string.format(L["READINESS_TIME_EXPIRING"], entry.name)
		else
			expiring[#expiring + 1] =
				string.format(L["READINESS_TIME_MINUTES"], entry.name, math.floor(entry.remaining / 60))
		end
	end

	return expiring
end

--------------------------------------------------------------------------------
-- Missing Items
--------------------------------------------------------------------------------

--[[
    The scan fills every category whether or not its macro is on, so this is
    true with a macro off. An ignored item counts as carried: the report never
    names something in the bags.
]]
local function CarryingNone(typeName)
	local selection = ns.bestSelection
	local entry = selection and selection[typeName]
	return entry ~= nil and entry.id == nil and not ns.scannedIgnoredTypes[typeName]
end

--[[
    Raw counts, not the category's winner: runes added to that macro can win it
    or push a held gem out of the ranked slots. Silent before the first scan.
]]
local function CarryingNoManaGem()
	local selection = ns.bestSelection
	if not (selection and selection["Mana Gem"]) then
		return false
	end
	local counts = ns.scannedItemCounts
	for gemID in pairs(ns.MANA_GEMS) do
		if (counts[gemID] or 0) > 0 then
			return false
		end
	end
	return true
end

local function BuildMissingItems(reports)
	local missing = {}

	-- With no Warlock to ask, a missing stone is nothing the player can act on.
	if reports.readinessHealthstone and CarryingNone("Healthstone") and GroupHasClass("WARLOCK") then
		missing[#missing + 1] = L["READINESS_HEALTHSTONE"]
	end

	if ns.ReadinessAsksManaGem(reports) and CarryingNoManaGem() then
		missing[#missing + 1] = L["READINESS_MANA_GEM"]
	end

	if reports.readinessHealingPotion and CarryingNone("Health Potion") then
		missing[#missing + 1] = L["READINESS_HEALING_POTION"]
	end

	if reports.readinessManaPotion and ns.PlayerUsesMana() and CarryingNone("Mana Potion") then
		missing[#missing + 1] = L["READINESS_MANA_POTION"]
	end

	if reports.readinessBandages and CarryingNone("Bandage") then
		missing[#missing + 1] = L["READINESS_BANDAGES"]
	end

	return missing
end

--------------------------------------------------------------------------------
-- Character
--------------------------------------------------------------------------------

local function BuildCharacter(reports, inArena)
	local entries = {}

	if reports.readinessSpec then
		local spec = ns.GetCurrentSpecializationLabel()
		if spec then
			entries[#entries + 1] = spec
		end
		local unspent = ns.GetUnspentTalentPoints()
		if unspent == 1 then
			entries[#entries + 1] = L["READINESS_UNSPENT_TALENTS_ONE"]
		elseif unspent then
			entries[#entries + 1] = string.format(L["READINESS_UNSPENT_TALENTS_MANY"], unspent)
		end
	end

	-- Arenas and battlegrounds flag everyone, so the warning would be one nobody can clear.
	if reports.readinessPvP and not inArena and select(2, IsInInstance()) ~= "pvp" and ns.IsPvPFlagged() then
		entries[#entries + 1] = L["READINESS_PVP_ON"]
	end

	return entries
end

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    Ignores the master switch and is split from printing, so Diagnostics can
    tell "you are ready" from "it never ran". Arenas block potions, buff food
    and scrolls and flag everyone, so inArena keeps only what the prep room can fix.
]]
function ns.BuildReadinessLines(inArena)
	local reports = ns.db and ns.db.global
	local settings = ns.db and ns.db.profile
	if not (reports and settings) then
		return nil
	end

	local buffsLine
	local missingItems = {}
	if not inArena then
		buffsLine = Line(
			Clause(L["READINESS_MISSING_BUFFS"], BuildMissingBuffs(settings, reports)),
			Clause(L["READINESS_EXPIRING"], BuildExpiring(reports))
		)
		missingItems = BuildMissingItems(reports)
	end

	local damaged = reports.readinessDurability and ns.GetDamagedGear(reports.readinessDurabilityThreshold) or {}
	local itemsLine =
		Line(Clause(L["READINESS_MISSING_ITEMS"], missingItems), Clause(L["READINESS_DAMAGED_GEAR"], damaged))

	local questionable = reports.readinessQuestionableGear and ns.GetQuestionableEquipment() or {}
	local characterLine = Line(
		Clause(L["READINESS_CHARACTER"], BuildCharacter(reports, inArena)),
		Clause(L["READINESS_QUESTIONABLE_GEAR"], questionable)
	)

	-- Nil, not an empty table, so no caller can print a header over no lines.
	if not (buffsLine or itemsLine or characterLine) then
		return nil
	end

	-- One at a time, never ipairs over a literal: any can be nil, and ipairs stops at the first hole.
	local lines = {}
	if buffsLine then
		lines[#lines + 1] = buffsLine
	end
	if itemsLine then
		lines[#lines + 1] = itemsLine
	end
	if characterLine then
		lines[#lines + 1] = characterLine
	end
	return lines
end

--[[
    No group test: a ready check never fires solo. While auras are secret
    (Forever, typically mid-pull) comparing one errors, so the report stays
    silent until the next check.
]]
function ns.OnReadyCheck()
	local reports = ns.db and ns.db.global
	if not (reports and reports.readinessReportEnabled) then
		return
	end
	if ns.AreAurasSecret() then
		return
	end

	local lines = ns.BuildReadinessLines(select(2, IsInInstance()) == "arena")
	if not lines then
		return
	end

	ns:PrintMessage(L["READINESS_TITLE"])
	for _, line in ipairs(lines) do
		ns:PrintMessage(line)
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
    Nothing waits for combat: a ready check often fires mid-pull, and the report
    only reads auras and the last bag scan, nothing protected.
]]
local MODULE = "ReadinessReport"

function ns.SyncReadinessReportEvents()
	local reports = ns.db and ns.db.global
	ns.SetModuleEvent(MODULE, "READY_CHECK", reports and reports.readinessReportEnabled and true or false)
end

ns.RegisterEventModule(MODULE, function(event)
	if event == "PLAYER_LOGIN" then
		ns.SyncReadinessReportEvents()
	elseif event == "READY_CHECK" then
		ns.OnReadyCheck()
	end
end)

ns.SetModuleEvent(MODULE, "PLAYER_LOGIN", true)
