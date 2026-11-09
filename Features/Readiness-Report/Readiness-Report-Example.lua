local _, ns = ...
local L = ns.L
local Clause = ns.ReadinessClause
local Line = ns.ReadinessLine

--[[
    Readiness-Report-Example -- the Readiness Report panel's Example: every
    line the report would print with something wrong for every switch that is
    on (buffs, items, character; the title alone when none is), so each switch
    turned on visibly adds to it, built with the same clauses and keys as
    ns.BuildReadinessLines (Readiness-Report.lua). Well Fed stands under
    Expiring Soon while that switch is on, rather than under Missing Buffs as
    well, so no buff is listed as both missing and running out. A switch the panel hides on
    this client (flask, pet, spec) never shows here either, and nor does a line
    the real report keeps to a class this character isn't: the Soulstone
    (Warlocks), the Mana Gem (Mages) and a mana potion (classes that use mana).
    Well Fed, the pet's food, scrolls, the Soulstone and the Mana Gem go
    through the real report's own checks (ns.ReadinessAsksWellFed,
    ns.ShouldTrackPetFood and the rest), so a macro switched off, a pet not
    out or a conjure spell not yet learned keeps them out of here too.
]]

local function FirstQuestionableLink()
	local lowest
	for itemID in pairs(ns.QUESTIONABLE_EQUIPMENT) do
		if not lowest or itemID < lowest then
			lowest = itemID
		end
	end
	return lowest and ns.GetItemHyperlink(lowest)
end

local function AddIf(values, enabled, value)
	if enabled and value then
		values[#values + 1] = value
	end
end

function ns.BuildReadinessSampleLines()
	local reports = ns.db and ns.db.global
	local settings = ns.db and ns.db.profile
	if not reports or not settings then
		return nil
	end

	local buffs = {}
	AddIf(buffs, reports.readinessFlask and ns.EXPANSION >= 2, L["READINESS_FLASK"])
	AddIf(buffs, ns.ReadinessAsksWellFed(settings, reports) and not reports.readinessExpiring, ns.GetWellFedName())
	AddIf(
		buffs,
		reports.readinessPetWellFed and ns.ShouldTrackPetFood(),
		string.format(L["READINESS_PET_FORMAT"], ns.GetWellFedName())
	)
	AddIf(buffs, ns.ReadinessAsksScrolls(settings, reports), L["READINESS_SCROLLS"])
	AddIf(buffs, ns.ReadinessAsksSoulstone(reports), L["READINESS_SOULSTONE"])
	AddIf(buffs, reports.readinessMainHandBuff, MAINHANDSLOT)
	AddIf(buffs, reports.readinessOffHandBuff, SECONDARYHANDSLOT)

	-- The most the real report can print: a buff just under the threshold, and under a minute reads as such.
	local expiring = {}
	local minutes = math.floor((reports.readinessExpiringThreshold - 1) / 60)
	local expiringLine = minutes > 0 and string.format(L["READINESS_TIME_MINUTES"], ns.GetWellFedName(), minutes)
		or string.format(L["READINESS_TIME_EXPIRING"], ns.GetWellFedName())
	AddIf(expiring, reports.readinessExpiring, expiringLine)

	local items = {}
	AddIf(items, reports.readinessHealthstone, L["READINESS_HEALTHSTONE"])
	AddIf(items, ns.ReadinessAsksManaGem(reports), L["READINESS_MANA_GEM"])
	AddIf(items, reports.readinessHealingPotion, L["READINESS_HEALING_POTION"])
	AddIf(items, reports.readinessManaPotion and ns.PlayerUsesMana(), L["READINESS_MANA_POTION"])
	AddIf(items, reports.readinessBandages, L["READINESS_BANDAGES"])

	local damaged = {}
	AddIf(damaged, reports.readinessDurability, ns.FirstEquippedLink())

	local character = {}
	AddIf(character, reports.readinessSpec and ns.CanReportSpecialization(), ns.GetCurrentSpecializationLabel())
	AddIf(character, reports.readinessPvP, L["READINESS_PVP_ON"])

	local questionable = {}
	AddIf(questionable, reports.readinessQuestionableGear, FirstQuestionableLink())

	local lines = {}
	AddIf(lines, true, Line(Clause(L["READINESS_MISSING_BUFFS"], buffs), Clause(L["READINESS_EXPIRING"], expiring)))
	AddIf(lines, true, Line(Clause(L["READINESS_MISSING_ITEMS"], items), Clause(L["READINESS_DAMAGED_GEAR"], damaged)))
	AddIf(
		lines,
		true,
		Line(Clause(L["READINESS_CHARACTER"], character), Clause(L["READINESS_QUESTIONABLE_GEAR"], questionable))
	)
	if not lines[1] then
		lines[1] = L["READINESS_TITLE"]
	end
	return lines
end
