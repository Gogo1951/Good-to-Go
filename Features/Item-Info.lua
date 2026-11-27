local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Info Waiters
--------------------------------------------------------------------------------

--[[
    GET_ITEM_INFO_RECEIVED floods during a login, so it is registered only while
    a waiter exists. Keyed rather than counted: a waiter that asks twice must
    not need to release twice.
]]
local itemInfoWaiters = {}

-- Beside the waiters, which decide how long a miss can be trusted (Session Item Data below).
local rememberedMisses = {}

local MODULE = "ItemInfo"

local OnWindowItemInfoReceived -- Window Item Warming, below

-- The Restocker goes first: it forgets the item's remembered miss before anything retries.
ns.RegisterEventModule(MODULE, function(_, itemID, success)
	if ns.OnRestockerItemInfoReceived then
		ns.OnRestockerItemInfoReceived(itemID, success)
	end
	OnWindowItemInfoReceived(itemID, success)
	if ns.OnConsumableItemInfoReceived then
		ns.OnConsumableItemInfoReceived(itemID, success)
	end
	if ns.OnWhatsNextItemInfoReceived then
		ns.OnWhatsNextItemInfoReceived(itemID, success)
	end
end)

function ns.RequestItemInfoEvents(key)
	itemInfoWaiters[key] = true
	ns.SetModuleEvent(MODULE, "GET_ITEM_INFO_RECEIVED", true)
end

function ns.ReleaseItemInfoEvents(key)
	if itemInfoWaiters[key] == nil then
		return
	end
	itemInfoWaiters[key] = nil
	if next(itemInfoWaiters) == nil then
		ns.SetModuleEvent(MODULE, "GET_ITEM_INFO_RECEIVED", false)
		rememberedMisses = {}
	end
end

--------------------------------------------------------------------------------
-- Window Item Warming
--------------------------------------------------------------------------------

--[[
    A window holds a waiter while any cold id it handed in is outstanding. An
    id that is unknown, already failed or already cached is never requested:
    no answer may come, and a wait on it would hold the event all session.
]]

-- windowKey -> { [itemID] = true }
local warming = {}

-- windowKey -> repaint function
local arriveHandlers = {}

local failedItemIDs = {}

local function WaiterKey(windowKey)
	return "window:" .. windowKey
end

function ns.WarmItemCache(itemIDs, windowKey, onArrive)
	assert(type(onArrive) == "function", "ns.WarmItemCache needs the window's repaint")
	if not (itemIDs and itemIDs[1] and windowKey) then
		return
	end
	arriveHandlers[windowKey] = onArrive

	local pending = warming[windowKey] or {}
	local requested = false
	for _, itemID in ipairs(itemIDs) do
		local cold = not C_Item.IsItemDataCachedByID(itemID)
		if cold and not failedItemIDs[itemID] and C_Item.DoesItemExistByID(itemID) then
			pending[itemID] = true
			C_Item.RequestLoadItemDataByID(itemID)
			requested = true
		end
	end
	if requested then
		warming[windowKey] = pending
		ns.RequestItemInfoEvents(WaiterKey(windowKey))
	end
end

-- A failed answer settles the wait too, and is remembered so the repaint does not ask again.
function OnWindowItemInfoReceived(itemID, success)
	if success ~= true then
		failedItemIDs[itemID] = true
	end
	for windowKey, pending in pairs(warming) do
		if pending[itemID] then
			pending[itemID] = nil
			arriveHandlers[windowKey]()
			if next(pending) == nil then
				warming[windowKey] = nil
				ns.ReleaseItemInfoEvents(WaiterKey(windowKey))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Session Item Data
--------------------------------------------------------------------------------

--[[
    Any item, session-only. The consumable cache (Item-Cache.lua) holds only
    consumables' own facts; reach here for a name, an icon or a link.
]]

-- Keyed by whatever was asked for: an id on the hot paths, an item link at a merchant.
local getItemInfoCache = {}

--[[
    A miss is remembered only while a waiter listens, when every answer re-runs
    the parked asks and a login floods with repeat calls. With nobody listening
    the client's one answer lands unheard, so a remembered miss would strand
    the item for the session; the last waiter out drops them all for the same
    reason.

    Trap: scoping a miss to a frame by GetTime() fails too. The clock can read
    the same across frames, so a miss outlives its unheard answer.

    Only id-keyed misses: the event reports an id, the only key
    ns.ForgetItemDataMiss can clear.
]]
function ns.ForgetItemDataMiss(itemID)
	rememberedMisses[itemID] = nil
end

function ns.GetItemData(request)
	local cached = getItemInfoCache[request]
	if cached ~= nil then
		return cached
	end
	if rememberedMisses[request] then
		return nil
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
		C_Item.GetItemInfo(request)
	if itemName == nil then
		if type(request) == "number" and next(itemInfoWaiters) ~= nil then
			rememberedMisses[request] = true
		end
		return nil
	end

	local cacheItem = {
		itemID = tonumber(string.match(itemLink, "item:(%d+)")),
		itemName = itemName,
		itemLink = itemLink,
		itemRarity = itemRarity,
		itemLevel = itemLevel,
		itemMinLevel = itemMinLevel,
		itemType = itemType,
		itemSubType = itemSubType,
		itemStackCount = itemStackCount,
		itemEquipLoc = itemEquipLoc,
		itemTexture = itemTexture,
		itemSellPrice = itemSellPrice,
	}
	getItemInfoCache[request] = cacheItem
	return cacheItem
end

--[[
    Always a working link: while the item is cold, one built by hand from the
    id, which the client resolves on hover. It is white because quality color
    is the one thing unknowable without the cache.
]]
function ns.GetItemHyperlink(itemID, fallbackName)
	local info = itemID and ns.GetItemData(itemID) or nil
	if info and info.itemLink then
		return info.itemLink
	end

	if itemID then
		local label = (fallbackName and fallbackName ~= "") and fallbackName or L["LOADING_ITEM"]:format(itemID)
		return GetColor("TEXT") .. "|Hitem:" .. itemID .. "|h[" .. label .. "]|h|r"
	end

	return fallbackName or "?"
end

--[[
    For the add-on's own windows, panels and tooltips: brackets beside an icon
    are clutter. Chat keeps them, since that is how chat marks a link.
]]
function ns.UnbracketItemLink(link)
	return (link:gsub("|h%[(.-)%]|h", "|h%1|h"))
end

function ns.GetItemLabel(itemID, fallbackName)
	return ns.UnbracketItemLink(ns.GetItemHyperlink(itemID, fallbackName))
end
