local _, ns = ...
local L = ns.L
local Clause = ns.ReadinessClause
local Line = ns.ReadinessLine

--[[
    Readiness-Report-Example -- the Readiness Report panel's Example: the
    title, then the report's lines as they would read with something wrong for
    every switch that is on, built with the same clauses and keys as
    ns.BuildReadinessLines (Readiness-Report.lua). A switch the panel hides on
    this client (flask, pet, spec) never shows here either, and nor does a line
    the real report keeps to a class this character isn't: the pet's food
    (Hunters), the Soulstone (Warlocks), the Mana Gem (Mages) and a mana potion
    (classes that use mana).
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
	if not reports then
		return {}
	end

	local buffs = {}
	AddIf(buffs, reports.readinessFlask and ns.EXPANSION >= 2, L["READINESS_FLASK"])
	AddIf(buffs, reports.readinessWellFed, ns.GetWellFedName())
	AddIf(
		buffs,
		reports.readinessPetWellFed and ns.isHunter and next(ns.PET_BUFF_FOODS) ~= nil,
		string.format(L["READINESS_PET_FORMAT"], ns.GetWellFedName())
	)
	AddIf(buffs, reports.readinessScrolls, L["READINESS_SCROLLS"])
	AddIf(buffs, reports.readinessSoulstone and ns.isWarlock, L["READINESS_SOULSTONE"])
	AddIf(buffs, reports.readinessMainHandBuff, MAINHANDSLOT)
	AddIf(buffs, reports.readinessOffHandBuff, SECONDARYHANDSLOT)

	local expiring = {}
	local minutes = math.max(1, math.floor((reports.readinessExpiringThreshold or 60) / 60))
	AddIf(expiring, reports.readinessExpiring, string.format(L["READINESS_TIME_MINUTES"], ns.GetWellFedName(), minutes))

	local items = {}
	AddIf(items, reports.readinessHealthstone, L["READINESS_HEALTHSTONE"])
	AddIf(items, reports.readinessManaGem and ns.isMage, L["READINESS_MANA_GEM"])
	AddIf(items, reports.readinessHealingPotion, L["READINESS_HEALING_POTION"])
	AddIf(items, reports.readinessManaPotion and ns.PlayerUsesMana(), L["READINESS_MANA_POTION"])
	AddIf(items, reports.readinessBandages, L["READINESS_BANDAGES"])

	local damaged = {}
	AddIf(damaged, reports.readinessDurability, ns.FirstEquippedLink())

	local character = {}
	AddIf(character, reports.readinessSpec and ns.GetNumTalentTabs() ~= nil, ns.GetCurrentSpecializationLabel())
	AddIf(character, reports.readinessPvP, L["READINESS_PVP_ON"])

	local questionable = {}
	AddIf(questionable, reports.readinessQuestionableGear, FirstQuestionableLink())

	local lines = { L["READINESS_TITLE"] }
	for _, line in ipairs({
		Line(Clause(L["READINESS_MISSING_BUFFS"], buffs), Clause(L["READINESS_EXPIRING"], expiring)) or false,
		Line(Clause(L["READINESS_MISSING_ITEMS"], items), Clause(L["READINESS_DAMAGED_GEAR"], damaged)) or false,
		Line(Clause(L["READINESS_CHARACTER"], character), Clause(L["READINESS_QUESTIONABLE_GEAR"], questionable))
			or false,
	}) do
		if line then
			lines[#lines + 1] = line
		end
	end
	return lines
end
