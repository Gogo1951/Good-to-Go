local _, ns = ...

--[[
    The reagent bag holds only reagents, so it is counted (restockCountedBags)
    but never a destination (restockPlayerBags).
]]
ns.restockPlayerBags = {}
ns.restockCountedBags = {}

local BagDefinition = {}
BagDefinition.__index = BagDefinition

local bankBags = {}
local bankBagsReversed = {}

-- Defined near the end of this file; forward-declared for the slot scans that call it first.
local GetRestockContainerItemInfo

--------------------------------------------------------------------------------
-- Bag Definitions
--------------------------------------------------------------------------------

--[[
    `location` labels the trace only. No inventory-slot id is kept: its only use
    would be PutItemInBag, which must never be called here (see PutCursorItem).
]]
local function NewBagDefinition(location, bagID)
	local result = {}
	result.location = location
	result.bagID = bagID
	setmetatable(result, BagDefinition)
	return result
end

local function CreateBackpack()
	return NewBagDefinition("backpack", BACKPACK_CONTAINER)
end

local function CreateBag(bag)
	return NewBagDefinition("bag", bag)
end

-- Read afresh at every bank visit, since Forever's tabs can change between them.
function ns.LoadRestockBankBags()
	local bagIDs = ns.BankBagIDs()
	bankBags = {}
	bankBagsReversed = {}
	for index, bagID in ipairs(bagIDs) do
		bankBags[index] = NewBagDefinition("bank", bagID)
		bankBagsReversed[#bagIDs - index + 1] = NewBagDefinition("bank", bagID)
	end
end

-- Both orderings are rebuilt at every visit, so callers ask for them each time rather than keeping one.
function ns.GetRestockBankBags()
	return bankBags
end

function ns.GetRestockBankBagsReversed()
	return bankBagsReversed
end

function ns.InitializeRestockBagDefinitions()
	ns.LoadRestockBankBags()

	ns.restockPlayerBags = { CreateBackpack(), CreateBag(1), CreateBag(2), CreateBag(3), CreateBag(4) }
	ns.restockCountedBags = { unpack(ns.restockPlayerBags) }
	local reagentBagID = ns.GetReagentBagID()
	if reagentBagID then
		ns.restockCountedBags[#ns.restockCountedBags + 1] = CreateBag(reagentBagID)
	end
end

-- A specialty bag (quiver, soul or herb bag) reports free slots a regular item can never take.
local function BagTypeAccepts(bagType, itemInfo)
	if not bagType or bagType == 0 then
		return true
	end
	if not itemInfo then
		return false -- unknown item: only trust regular containers
	end
	if itemInfo.itemEquipLoc == "INVTYPE_BAG" then
		return false -- equippable bags can only be stored in regular containers
	end
	local itemFamily = C_Item.GetItemFamily(itemInfo.itemID)
	return itemFamily ~= nil and itemFamily ~= 0 and bit.band(itemFamily, bagType) ~= 0
end

ns.BagTypeAccepts = BagTypeAccepts

-- A shortcut, not a safety net: a bag that refuses leaves the item on the cursor for the next.
function BagDefinition:CanAcceptItem(itemInfo)
	local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(self.bagID)
	if numberOfFreeSlots <= 0 then
		return false
	end
	return BagTypeAccepts(bagType, itemInfo)
end

--[[
    Every container names its own empty slot: PutItemInBackpack and PutItemInBag
    clear the cursor even when the server refuses, so "did it land" would always
    read yes. Empty is tested by GetContainerItemInfo, since the link is nil for
    a cold item too.
]]
function BagDefinition:PutCursorItem()
	for slot = 1, C_Container.GetContainerNumSlots(self.bagID) do
		if not C_Container.GetContainerItemInfo(self.bagID, slot) then
			ns.RestockerDebug("TRACE_PUT_CURSOR_ITEM", self.location, self.bagID, slot)
			C_Container.PickupContainerItem(self.bagID, slot)
			return
		end
	end

	-- The cursor keeps the item so the caller can try the next bag. Never ClearCursor here.
	ns.RestockerDebug("TRACE_PUT_CURSOR_NO_SLOT", self.location, self.bagID)
end

--------------------------------------------------------------------------------
-- Scanning
--------------------------------------------------------------------------------

--[[
    A locked slot means the last move hasn't settled, and the next would be
    refused ("Couldn't split those items"). Only list items count, so the
    player's own unrelated lock can't stall the run.
]]
local function AnyRestockItemLocked(bags, list)
	for _, bag in ipairs(bags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
			if
				itemInfo
				and itemInfo.isLocked
				and (list == nil or (itemInfo.itemID and list[itemInfo.itemID] ~= nil))
			then
				return true
			end
		end
	end
	return false
end

function ns.IsRestockItemLocked(list)
	return AnyRestockItemLocked(ns.restockCountedBags, list) or AnyRestockItemLocked(bankBagsReversed, list)
end

function ns.GetRestockItemsInBags(predicate)
	local result = ns.NewRestockInventory()

	for _, bag in ipairs(ns.restockCountedBags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)

			-- Keyed by itemID: unambiguous, locale-proof, and matches the list's keys
			if itemInfo and itemInfo.itemID then
				local id = itemInfo.itemID

				if predicate == nil or predicate(id) == true then
					result.summary[id] = (result.summary[id] or 0) + itemInfo.stackCount

					result.slots[id] = result.slots[id] or {}
					table.insert(result.slots[id], ns.NewRestockInventorySlot(bag.bagID, slot, itemInfo.stackCount))
				end
			end
		end
	end

	result:SortSlots()
	return result
end

-- A slot the client hasn't resolved has no link and is left out until the menu next opens.
function ns.GetRestockBagItems()
	local items, seen = {}, {}
	for _, bag in ipairs(ns.restockCountedBags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local containerItemInfo = GetRestockContainerItemInfo(bag.bagID, slot)
			if containerItemInfo and containerItemInfo.itemID and not seen[containerItemInfo.itemID] then
				seen[containerItemInfo.itemID] = true
				items[#items + 1] = containerItemInfo
			end
		end
	end
	return items
end

function ns.GetRestockItemsInBank(predicate)
	local result = ns.NewRestockInventory()

	for _, bag in ipairs(bankBagsReversed) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
			if itemInfo and itemInfo.itemID then
				local id = itemInfo.itemID

				if predicate == nil or predicate(id) == true then
					result.summary[id] = (result.summary[id] or 0) + itemInfo.stackCount

					result.slots[id] = result.slots[id] or {}
					table.insert(result.slots[id], ns.NewRestockInventorySlot(bag.bagID, slot, itemInfo.stackCount))
				end
			end
		end
	end

	result:SortSlots()
	return result
end

function GetRestockContainerItemInfo(bagID, slot)
	local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
	-- A cold item's hyperlink can be nil; matching is by itemID, so skipping the slot is harmless.
	if not itemInfo or not itemInfo.hyperlink then
		return nil
	end
	local itemName = string.match(itemInfo.hyperlink, "%[(.*)%]")

	return {
		bag = bagID,
		slot = slot,
		icon = itemInfo.iconFileID,
		count = itemInfo.stackCount,
		locked = itemInfo.isLocked,
		link = itemInfo.hyperlink,
		itemID = itemInfo.itemID,
		name = itemName,
	}
end

ns.GetRestockContainerItemInfo = GetRestockContainerItemInfo

function ns.CompareByStackSizeAscending(a, b)
	return a.count < b.count
end
