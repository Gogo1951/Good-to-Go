local _, ns = ...

--------------------------------------------------------------------------------
-- Item Cache
--------------------------------------------------------------------------------

-- Never saved: every fact comes from this load's data tables or the server, so a new release or data folder starts clean.
local itemCache = {}

function ns.GetCachedItemData(itemID)
	return itemCache[itemID]
end

function ns.CountCachedItems()
	local count = 0
	for _ in pairs(itemCache) do
		count = count + 1
	end
	return count
end

-- Each table with the column where its Min Level, Vendor Price, Max Stack and Bind Type start.
local CONSUMABLE_TABLES = {
	{ "FOOD_AND_WATER", 8 },
	{ "POTIONS", 5 },
	{ "HEALTHSTONES", 3 },
	{ "SOULSTONES", 2 },
	{ "BANDAGES", 5 },
	{ "MANA_GEMS", 2 },
	{ "MANA_RUNES", 2 },
	{ "EXPLOSIVES", 5 },
}

local function FindConsumableRow(itemID)
	for _, entry in ipairs(CONSUMABLE_TABLES) do
		local row = ns[entry[1]][itemID]
		if row then
			return row, entry[2]
		end
	end
end

--[[
    MIGRATION (remove after 2026-12-08)
    Releases before this one saved the item cache on every profile, with its
    itemCacheVersion and itemCacheFolder stamps. InitializeDatabase in
    Features/Core.lua clears them from every profile at every login, which is
    harmless to repeat once they are gone.
]]
function ns.RetireSavedItemCache()
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		if type(profile) == "table" then
			profile.itemCache = nil
			profile.itemCacheVersion = nil
			profile.itemCacheFolder = nil
		end
	end
end

function ns.HasRawData(itemID)
	return FindConsumableRow(itemID) ~= nil
end

--------------------------------------------------------------------------------
-- Cold Item Retry
--------------------------------------------------------------------------------

-- Sized to cover a slow login.
local DATA_RETRY_MAX_ATTEMPTS = 10
local dataRetryAttempts = 0

--[[
    Budgeted: an ID the server never answers would loop scan → timer → scan
    forever. The event stays registered past the budget so a late answer still
    rebuilds.
]]
function ns.RegisterDataRetry()
	ns.RequestItemInfoEvents("scan")

	if dataRetryAttempts >= DATA_RETRY_MAX_ATTEMPTS then
		return
	end
	dataRetryAttempts = dataRetryAttempts + 1

	C_Timer.After(2, function()
		ns.RequestUpdate()
	end)
end

function ns.UnregisterDataRetry()
	dataRetryAttempts = 0
	ns.ReleaseItemInfoEvents("scan")
end

--------------------------------------------------------------------------------
-- Zone Helpers
--------------------------------------------------------------------------------

local function BuildZoneSet(rawZoneArray)
	if not rawZoneArray then
		return nil
	end
	local set = {}
	for _, mapID in ipairs(rawZoneArray) do
		set[mapID] = true
	end
	return set
end

--------------------------------------------------------------------------------
-- Item Data Caching
--------------------------------------------------------------------------------

--[[
    A non-consumable returns "IGNORE" with no C_Item.GetItemInfo call, so it
    never arms a rescan. A row added since the last Validate Data run has no
    item facts yet; GetItemInfo stands in and returns nil while cold.
]]
function ns.CacheItemData(itemID)
	local cached = itemCache[itemID]
	if cached then
		return cached
	end

	local row, factsColumn = FindConsumableRow(itemID)
	if not row then
		return "IGNORE"
	end

	local minLevel, vendorPrice, maxStack, bindType =
		row[factsColumn], row[factsColumn + 1], row[factsColumn + 2], row[factsColumn + 3]
	if minLevel == nil then
		local name, _
		name, _, _, _, minLevel, _, _, maxStack, _, _, vendorPrice, _, _, bindType = C_Item.GetItemInfo(itemID)
		if not name then
			return nil
		end
	end

	local rawFoodAndWater = ns.FOOD_AND_WATER[itemID]
	local rawPotion = ns.POTIONS[itemID]
	local rawHealthstone = ns.HEALTHSTONES[itemID]
	local rawSoulstone = ns.SOULSTONES[itemID]
	local rawBandage = ns.BANDAGES[itemID]
	local rawManaGem = ns.MANA_GEMS[itemID]
	local rawManaRune = ns.MANA_RUNES[itemID]
	local rawExplosive = ns.EXPLOSIVES[itemID]

	local data = {
		itemID = itemID,
		itemType = "",
		healthValue = 0,
		manaValue = 0,
		damageValue = 0,
		requiredLevel = minLevel or 0,
		requiredFirstAid = 0,
		requiredAlchemy = 0,
		requiredEngineering = 0,
		requiredSpellID = nil,
		price = vendorPrice or 0,
		maxStack = maxStack or 1,
		--[[
		    OnAcquire (1): a carried copy is always bound, so no per-slot lookup.
		    Bind-on-use (3) stays tradeable until consumed, so it isn't soulbound.
		]]
		isSoulbound = (bindType == 1),
		isBuffFood = false,
		isPercent = false,
		zones = nil,
		arenaOnly = false,
		arenaUsable = false,
		isConjured = false,
	}

	if rawFoodAndWater then
		local isBuffFoodType = (rawFoodAndWater[1] == 1)
		data.isBuffFood = isBuffFoodType
		data.zones = BuildZoneSet(rawFoodAndWater[6])

		-- Column 7: 1 = arena only, 2 = conjured (also arena-usable).
		local arenaFlag = rawFoodAndWater[7]
		data.arenaOnly = (arenaFlag == 1)
		data.arenaUsable = (arenaFlag ~= nil)
		--[[
		    Only flag 2 is conjured: food that sells for nothing or says Conjured
		    Item with no arena value (Harvest Bread, Winter Veil Loaf) is ordinary
		    food to Use Conjured Food & Water First.
		]]
		data.isConjured = (arenaFlag == 2)

		local hasFood = false
		local hasWater = false

		if rawFoodAndWater[2] > 0 then
			hasFood = true
			data.healthValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[3] > 0 then
			hasFood = true
			data.healthValue = rawFoodAndWater[3]
		end

		if rawFoodAndWater[4] > 0 then
			hasWater = true
			data.manaValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[5] > 0 then
			hasWater = true
			data.manaValue = rawFoodAndWater[5]
		end

		if isBuffFoodType and not hasFood and not hasWater then
			hasFood = true
		end

		if hasFood and hasWater then
			data.itemType = "foodwater"
		elseif hasFood then
			data.itemType = "food"
		else
			data.itemType = "water"
		end
	elseif rawPotion then
		data.itemType = "potion"
		data.healthValue = rawPotion[1]
		data.manaValue = rawPotion[2]
		data.zones = BuildZoneSet(rawPotion[3])
		data.requiredAlchemy = rawPotion[4] or 0
	elseif rawHealthstone then
		data.itemType = "healthstone"
		data.healthValue = rawHealthstone[1]
		data.requiredLevel = rawHealthstone[2] or data.requiredLevel
	elseif rawSoulstone then
		data.itemType = "soulstone"
		data.healthValue = rawSoulstone[1]
	elseif rawBandage then
		-- Bandage row shape: {healAmount, requiredSkill, sellPrice, {zones}, item facts}
		data.itemType = "bandage"
		data.healthValue = rawBandage[1]
		data.requiredFirstAid = rawBandage[2] or 0
		data.zones = BuildZoneSet(rawBandage[4])
	elseif rawManaGem then
		data.itemType = "managem"
		data.manaValue = rawManaGem[1]
	elseif rawManaRune then
		data.itemType = "manarune"
		data.manaValue = rawManaRune[1]
	elseif rawExplosive then
		-- Explosive row shape: {minDamage, maxDamage, requiredSkill, requiredSpellID, item facts}
		data.itemType = "explosive"
		data.damageValue = rawExplosive[1]
		data.requiredEngineering = rawExplosive[3] or 0
		-- An Engineering specialization (Goblin Engineer for the Global Thermal Sapper Charge).
		data.requiredSpellID = rawExplosive[4]
	end

	itemCache[itemID] = data
	return data
end
