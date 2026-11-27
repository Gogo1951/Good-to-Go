local _, ns = ...

local BagTypeAccepts = ns.BagTypeAccepts

--------------------------------------------------------------------------------
-- Purchase Space
--------------------------------------------------------------------------------

--[[
    Read once when the run starts: a purchase lands only on BAG_UPDATE, after the
    whole run is sent, so the live counts never move mid-run and ns.ClaimBagSpace
    spends this copy down instead.
]]
function ns.NewBagSpace(bags)
	local space = { bags = {}, partialRoom = {} }
	for _, bag in ipairs(bags) do
		local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(bag.bagID)
		space.bags[#space.bags + 1] = { bagID = bag.bagID, free = numberOfFreeSlots, bagType = bagType or 0 }
	end
	return space
end

local function PartialStackRoom(space, itemID, stackSize)
	local room = 0
	for _, bag in ipairs(space.bags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			-- The client's own slot record: this only counts, so it builds no row of its own.
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
			if itemInfo and itemInfo.hyperlink and itemInfo.itemID == itemID and itemInfo.stackCount < stackSize then
				room = room + stackSize - itemInfo.stackCount
			end
		end
	end
	return room
end

-- A matching specialty bag first (a quiver for arrows), so the regular slots stay free for the rest.
local function FindFreeBag(space, itemInfo)
	for _, bag in ipairs(space.bags) do
		if bag.free > 0 and bag.bagType ~= 0 and BagTypeAccepts(bag.bagType, itemInfo) then
			return bag
		end
	end
	for _, bag in ipairs(space.bags) do
		if bag.free > 0 and bag.bagType == 0 then
			return bag
		end
	end
	return nil
end

--[[
    One purchase of at most a stack. The game tops up partial stacks first and
    only the overflow takes a free slot. False when nothing can take it. An
    uncached item has no stack size, so each purchase of it takes a whole slot.
]]
function ns.ClaimBagSpace(space, itemInfo, count)
	local itemID = itemInfo and itemInfo.itemID
	local stackSize = itemInfo and itemInfo.itemStackCount or 1
	local room = 0
	if itemID then
		room = space.partialRoom[itemID] or PartialStackRoom(space, itemID, stackSize)
	end
	if count <= room then
		space.partialRoom[itemID] = room - count
		return true
	end

	local bag = FindFreeBag(space, itemInfo)
	if not bag then
		return false
	end
	bag.free = bag.free - 1
	if itemID then
		space.partialRoom[itemID] = stackSize - (count - room)
	end
	return true
end
