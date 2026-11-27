local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- Fishing Lure Macro
--------------------------------------------------------------------------------

--[[
    The body is the first step the character still misses (gear, then fishing
    food, then lure), so each press does one step and a done step drops out.
    What it reads beyond the bags is watched here, since no bag event covers it.
]]

local HANDS_SLOT = 10
local MAIN_HAND_SLOT = 16
local WEAPON_CLASS_ID = 2
local FISHING_POLE_SUBCLASS = 20

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentState = nil
local eventsRegistered = false
local gearSignature = nil
local lureTimerGeneration = 0

function ns.ResetFishingLureMacroState()
	currentState = nil
end

-- Read by ns.UpdateAuraTracking.
ns.watchFishingFed = false

--------------------------------------------------------------------------------
-- Ranked Lookups
--------------------------------------------------------------------------------

local function RankByBonus(source, skillColumn, levelColumn)
	local list = {}
	for itemID, row in pairs(source) do
		list[#list + 1] = {
			itemID = itemID,
			bonus = row[1],
			skill = skillColumn and row[skillColumn] or 0,
			level = levelColumn and row[levelColumn] or 0,
		}
	end
	table.sort(list, function(a, b)
		if a.bonus ~= b.bonus then
			return a.bonus > b.bonus
		end
		return a.itemID > b.itemID
	end)
	return list
end

local RANKED_POLES = RankByBonus(ns.FISHING_POLES, 2, 3)
local RANKED_LURES = RankByBonus(ns.FISHING_LURES, 2, nil)
local RANKED_FOODS = RankByBonus(ns.FISHING_FOODS, nil, 2)

local POLE_BONUS = {}
for _, entry in ipairs(RANKED_POLES) do
	POLE_BONUS[entry.itemID] = entry.bonus
end

local RANKED_GEAR = {}
for gearKey, pieces in pairs(ns.FISHING_GEAR) do
	RANKED_GEAR[gearKey] = RankByBonus(pieces, 2, 3)
end

--------------------------------------------------------------------------------
-- Reading the Character
--------------------------------------------------------------------------------

local function Settings()
	return ns.db and ns.db.profile
end

local function FishingSkill()
	return ns.currentFishingSkill or 0
end

local function IsFishingPole(itemID)
	if not itemID then
		return false
	end
	local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
	return classID == WEAPON_CLASS_ID and subclassID == FISHING_POLE_SUBCLASS
end

local function WornPoleID()
	local itemID = GetInventoryItemID("player", MAIN_HAND_SLOT)
	return IsFishingPole(itemID) and itemID or nil
end

-- On a fishing pole, the main hand's temporary enchant is the lure.
local function LureOnPole()
	local main = ns.GetWeaponEnchants().main
	local entry = main and main[1]
	if entry then
		return true, entry.timeLeft
	end
	return false, nil
end

local function PlayerLevel()
	return ns.cachedPlayerLevel or UnitLevel("player")
end

local function BestCarried(list)
	local skill, level = FishingSkill(), PlayerLevel()
	for _, entry in ipairs(list) do
		if
			entry.skill <= skill
			and entry.level <= level
			and C_Item.GetItemCount(entry.itemID) > 0
			and not ns.IsIgnored(entry.itemID)
		then
			return entry
		end
	end
	return nil
end

local function LinkEnchantID(itemLink)
	local enchant = itemLink and itemLink:match("item:%-?%d+:(%-?%d*)")
	return tonumber(enchant)
end

local function HasFishingEnchant(itemLink)
	local enchantID = LinkEnchantID(itemLink)
	return enchantID ~= nil and ns.FISHING_GLOVE_ENCHANT_IDS[enchantID] == true
end

-- Equipped by bag slot, so the enchanted pair is the one put on.
local function FindFishingGloves()
	for _, bag in ipairs(ns.CARRIED_BAG_IDS) do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local itemLink = C_Container.GetContainerItemLink(bag, slot)
			if itemLink and HasFishingEnchant(itemLink) then
				local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemLink)
				if equipLoc == "INVTYPE_HAND" then
					return bag, slot
				end
			end
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- The Steps
--------------------------------------------------------------------------------

local GEAR_ROWS = {
	{ setting = "fishingEquipPants", gearKey = "legs", slot = 7 },
	{ setting = "fishingEquipHat", gearKey = "head", slot = 1 },
	{ setting = "fishingEquipBoots", gearKey = "feet", slot = 8 },
}

local function WornGearBonus(row)
	local worn = GetInventoryItemID("player", row.slot)
	local pieces = ns.FISHING_GEAR[row.gearKey]
	local piece = worn and pieces and pieces[worn]
	return piece and piece[1] or -1
end

-- Every piece in one press: equipping takes no cast.
local function GearLines(settings)
	local lines, keyParts, firstItem = {}, {}, nil

	if settings.fishingEquipPole then
		local worn = WornPoleID()
		local wornBonus = worn and (POLE_BONUS[worn] or 0) or -1
		local best = BestCarried(RANKED_POLES)
		if best and best.bonus > wornBonus then
			lines[#lines + 1] = "/equip item:" .. best.itemID
			keyParts[#keyParts + 1] = "P" .. best.itemID
			firstItem = firstItem or best.itemID
		end
	end

	for _, row in ipairs(GEAR_ROWS) do
		local ranked = RANKED_GEAR[row.gearKey]
		local best = settings[row.setting] and ranked and BestCarried(ranked)
		if best and best.bonus > WornGearBonus(row) then
			lines[#lines + 1] = "/equip item:" .. best.itemID
			keyParts[#keyParts + 1] = row.gearKey .. best.itemID
			firstItem = firstItem or best.itemID
		end
	end

	if settings.fishingEquipGloves and not HasFishingEnchant(GetInventoryItemLink("player", HANDS_SLOT)) then
		local bag, slot = FindFishingGloves()
		if bag then
			lines[#lines + 1] = "/use " .. bag .. " " .. slot
			keyParts[#keyParts + 1] = "G" .. bag .. "." .. slot
			firstItem = firstItem or C_Container.GetContainerItemID(bag, slot)
		end
	end

	return lines, table.concat(keyParts, ","), firstItem
end

local function HasFishingWellFed()
	return ns.HasFishingWellFed(ns.GetPlayerBuffSnapshot())
end

-- Ignores the buff, so the Well Fed watch stays on while the step could act.
local function CarriedFishingFood(settings)
	if not settings.fishingUseFood or #RANKED_FOODS == 0 then
		return nil
	end
	local best = BestCarried(RANKED_FOODS)
	return best and best.itemID
end

local function LureToApply(settings)
	if not settings.fishingUseLure or not WornPoleID() or LureOnPole() then
		return nil
	end
	local best = BestCarried(RANKED_LURES)
	return best and best.itemID
end

--------------------------------------------------------------------------------
-- Body
--------------------------------------------------------------------------------

-- The key names every input the body is built from.
local function BuildBody(settings)
	local defaultID = ns.MACRO_DEFAULT_ITEM_IDS["Fishing Lure"]

	local gearLines, gearKey, gearItem = GearLines(settings)
	if #gearLines > 0 then
		local lines = { "#showtooltip item:" .. (gearItem or defaultID) }
		for _, line in ipairs(gearLines) do
			lines[#lines + 1] = line
		end
		return table.concat(lines, "\n"), "GEAR_" .. gearKey
	end

	local foodID = CarriedFishingFood(settings)
	if foodID and not HasFishingWellFed() then
		return "#showtooltip item:" .. foodID .. "\n/use item:" .. foodID, "FOOD_" .. foodID
	end

	local lureID = LureToApply(settings)
	if lureID then
		return "#showtooltip item:" .. lureID .. "\n/use item:" .. lureID .. "\n/use " .. MAIN_HAND_SLOT,
			"LURE_" .. lureID
	end

	return "#showtooltip item:" .. defaultID, "NONE"
end

--------------------------------------------------------------------------------
-- Watching Gear and the Lure
--------------------------------------------------------------------------------

local function ReadGearSignature()
	-- An empty slot returns no value at all, which tostring refuses.
	local parts = { tostring(GetInventoryItemID("player", MAIN_HAND_SLOT) or 0), LureOnPole() and "L" or "-" }
	for _, row in ipairs(GEAR_ROWS) do
		parts[#parts + 1] = RANKED_GEAR[row.gearKey] and tostring(GetInventoryItemID("player", row.slot) or 0) or "x"
	end
	parts[#parts + 1] = HasFishingEnchant(GetInventoryItemLink("player", HANDS_SLOT)) and "G" or "-"
	return table.concat(parts, ":")
end

-- UNIT_INVENTORY_CHANGED also fires for durability and charges, so only a real change rebuilds.
function ns.FishingGearChanged()
	local signature = ReadGearSignature()
	if signature ~= gearSignature then
		gearSignature = signature
		return true
	end
	return false
end

-- Nothing is promised to fire when a lure wears off. A newer timer makes an older one do nothing.
local function WatchLureEnd()
	lureTimerGeneration = lureTimerGeneration + 1
	local hasLure, timeLeft = LureOnPole()
	if not (hasLure and timeLeft and timeLeft > 0) then
		return
	end
	local generation = lureTimerGeneration
	C_Timer.After(timeLeft / 1000 + 1, function()
		if generation == lureTimerGeneration and ns.FishingGearChanged() then
			ns.RequestUpdate()
		end
	end)
end

local function SetEventsRegistered(enabled)
	if enabled == eventsRegistered then
		return
	end
	eventsRegistered = enabled
	ns.SetEventRegistered("PLAYER_EQUIPMENT_CHANGED", enabled)
	if enabled then
		ns.SetEventRegistered("UNIT_INVENTORY_CHANGED", true, "player")
		gearSignature = ReadGearSignature()
	else
		ns.SetEventRegistered("UNIT_INVENTORY_CHANGED", false)
		gearSignature = nil
	end
end

local function SetFedWatch(enabled)
	if ns.watchFishingFed ~= enabled then
		ns.watchFishingFed = enabled
		ns.UpdateAuraTracking()
	end
end

--------------------------------------------------------------------------------
-- Update
--------------------------------------------------------------------------------

local function UpdateFishingLureMacro(forced)
	if forced then
		currentState = nil
	end

	local config = MACRO_CONFIG["Fishing Lure"]
	local settings = Settings()
	if not (config and settings) then
		return
	end

	SetEventsRegistered(true)
	SetFedWatch(CarriedFishingFood(settings) ~= nil)
	WatchLureEnd()

	local body, stateID = BuildBody(settings)
	if currentState == stateID and not forced then
		return
	end

	if not ns.WriteMacroBody(config.macro, body) then
		currentState = nil
		return
	end

	currentState = stateID
end

--------------------------------------------------------------------------------
-- Definition
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Fishing Lure",

	customUpdate = function(forced)
		if not ns.IsMacroEnabled("Fishing Lure") then
			local config = MACRO_CONFIG["Fishing Lure"]
			if config then
				ns.DeleteMacroByName(config.macro)
			end
			ns.ResetFishingLureMacroState()
			SetEventsRegistered(false)
			SetFedWatch(false)
			return
		end
		UpdateFishingLureMacro(forced)
	end,
})
