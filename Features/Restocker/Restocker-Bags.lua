local _, ns = ...

--[[
    The player's own bags and the bank's containers, and the slot scans over them.
    ns.restockPlayerBags are the places an item may be put: the merchant run's bag
    budget and the bank run's pulls. ns.restockCountedBags adds the reagent bag,
    which holds only reagents and so is never a destination, for everything that
    counts, locks or stashes what the player carries. The bank run's moves are
    Restocker-Bank-Moves.lua, which reads the bank orderings through
    ns.GetRestockBankBags and ns.GetRestockBankBagsReversed.
]]
ns.restockPlayerBags = {}
ns.restockCountedBags = {}

local BagDefinition = {}
BagDefinition.__index = BagDefinition

local bankBags = {} -- filled by ns.LoadRestockBankBags
local bankBagsReversed = {} -- filled by ns.LoadRestockBankBags

-- Defined near the end of this file; forward-declared for the slot scans that call it first.
local GetRestockContainerItemInfo

--------------------------------------------------------------------------------
-- Bag Definitions
--------------------------------------------------------------------------------

--[[
    A container the restocker moves items through. `location` is a label for the debug
    log only -- every container is filled the same way, by naming an empty slot (see
    BagDefinition:PutCursorItem). No inventory-slot id is kept: its only use would be
    PutItemInBag, which this file must never call.
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

-- Bank bag ids follow the player's own, offset by NUM_BAG_SLOTS: 5..10 on Classic Era (six slots), 5..11 on TBC.
local BANK_BAG_COUNT = 7

--[[
    The character bank's container IDs, the main bank first. The layout is chosen
    once, by whether the client has bank tabs at all, never by what the tab list
    answers: Forever's is the C_Bank tabs the player has bought, which can change
    at any visit, and none (an empty list) while that answer isn't in yet; Era
    and TBC have BANK_CONTAINER and seven bank bag IDs, TBC's count, whose
    seventh holds no slots on Era and so reads as empty. The Inventory Report
    reads the bank through the same list.
]]
if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
	function ns.BankBagIDs()
		return ns.FetchPurchasedBankTabIDs() or {}
	end
else
	function ns.BankBagIDs()
		local bagIDs = { BANK_CONTAINER }
		for index = 1, BANK_BAG_COUNT do
			bagIDs[#bagIDs + 1] = NUM_BAG_SLOTS + index
		end
		return bagIDs
	end
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

--[[
    Whether a container of this type may hold the item. A free-slot count alone is not
    enough: a specialty bag (quiver, soul/herb/enchanting bag) reports free slots that a
    regular item can never occupy.
]]
local function BagTypeAccepts(bagType, itemInfo)
	if not bagType or bagType == 0 then
		return true -- regular container takes anything
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

--[[
    True if this container has a free slot AND is allowed to hold the given item.

    A shortcut, not a safety net: placement names the slot itself, so a container that
    refuses the item leaves it on the cursor and the caller simply tries the next one;
    skipping the bags that were never going to take it just saves the trip.
]]
function BagDefinition:CanAcceptItem(itemInfo)
	local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(self.bagID)
	if numberOfFreeSlots <= 0 then
		return false
	end
	return BagTypeAccepts(bagType, itemInfo)
end

--[[
    Drop into the first genuinely-empty slot of this container, naming the slot
    ourselves. Detect empty with GetContainerItemInfo -- it returns nil ONLY when the
    slot is truly empty, whereas GetContainerItemLink is also nil for a not-yet-cached
    item, so testing the link would place onto an occupied slot and strand the item.

    EVERY container goes through this, player bags included. The two APIs that let the
    SERVER pick the slot -- PutItemInBackpack and PutItemInBag(invslot) -- clear the
    cursor the moment they are called, whether or not the drop is accepted. That makes
    the caller's "did it land?" test (CursorHasItem) answer "yes" even when the server
    refused and bounced the item back to its source, so the caller stops early, never
    tries the remaining bags, and the re-scan finds the item still missing. Naming the
    slot keeps the item on the cursor on a refusal, which is what makes that test true.
]]
function BagDefinition:PutCursorItem()
	for slot = 1, C_Container.GetContainerNumSlots(self.bagID) do
		if not C_Container.GetContainerItemInfo(self.bagID, slot) then
			ns.RestockerDebug("TRACE_PUT_CURSOR_ITEM", self.location, self.bagID, slot)
			C_Container.PickupContainerItem(self.bagID, slot)
			return
		end
	end

	--[[
	    No empty slot, so nothing was attempted and the cursor still holds the item --
	    deliberately, so the caller can try the next bag. Never ClearCursor here.
	]]
	ns.RestockerDebug("TRACE_PUT_CURSOR_NO_SLOT", self.location, self.bagID)
end

--------------------------------------------------------------------------------
-- Scanning
--------------------------------------------------------------------------------

--[[
    True if any slot we care about is still mid-move (locked). A locked slot means the last
    move hasn't settled on the server yet -- issuing the next one now is exactly what gets a
    split rejected with "Couldn't split those items".

    `list` narrows "we care about" to the items on the current list. Only OUR items may
    stall a restock: an unrelated locked item, something
    the player is equipping or a pending trade, would otherwise hold it up forever.
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

--[[
    Every different item in the player's bags, once each, as the Add Item From
    Bags menu draws them (Restocker-Window-Bag-Menu.lua): the first slot's
    record for each, which carries the name, link and icon. A slot whose item
    the client has not resolved has no link to name it by and is left out; it
    is there the next time the menu opens.
]]
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
	--[[
	    hyperlink can be nil for a not-yet-cached item; skip the slot rather than erroring
	    on string.match(nil, ...). Matching is done by itemID, so a skipped slot is harmless.
	]]
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
