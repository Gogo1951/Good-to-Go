local _, ns = ...

-- The bank run's tidy phase; its watchdog lives in Restocker-Bank-Visit.lua.

-- Nil for an item that doesn't stack or isn't cached yet, which the tidy phase leaves alone.
local function MaxStackOf(itemID)
	local info = ns.GetItemData(itemID)
	local maxStack = info and info.itemStackCount
	if maxStack and maxStack > 1 then
		return maxStack
	end
	return nil
end

--[[
    The tidy watchdog's progress signal: every tidy move leaves one fewer partial
    stack, so this falls while merging works and stops when done or bounced.
    Counting all stacks would miss a top-off, which removes none.
]]
function ns.CountRestockPartialStacks(playerInventory, bankInventory)
	local partials = 0
	for _, inventory in ipairs({ playerInventory, bankInventory }) do
		for itemID, slots in pairs(inventory.slots) do
			local maxStack = MaxStackOf(itemID)
			if maxStack then
				for _, slot in ipairs(slots) do
					if slot.count < maxStack then
						partials = partials + 1
					end
				end
			end
		end
	end
	return partials
end

--[[
    One merge of two partial stacks within one inventory, never across. The
    smallest moves whole onto the largest that has room for all of it, since a
    whole-stack merge needs no split. Only when none can does it top off the
    largest with an exact split, which the server can bounce.
]]
function ns.ConsolidateRestockStacks(inventory)
	for itemID, slots in pairs(inventory.slots) do
		local maxStack = MaxStackOf(itemID)
		if maxStack then
			-- Slots are sorted smallest first (SortSlots), so partials are too.
			local partials = {}
			for _, slot in ipairs(slots) do
				if slot.count < maxStack then
					partials[#partials + 1] = slot
				end
			end

			if #partials >= 2 then
				local source = partials[1]
				for i = #partials, 2, -1 do
					local destination = partials[i]
					if source.count + destination.count <= maxStack then
						ns.RestockerDebug(
							"TRACE_CONSOLIDATE",
							tostring(itemID),
							source.count,
							source.bag,
							source.slot,
							destination.bag,
							destination.slot
						)
						C_Container.PickupContainerItem(source.bag, source.slot)
						C_Container.PickupContainerItem(destination.bag, destination.slot)
						return true
					end
				end

				local destination = partials[#partials]
				local room = maxStack - destination.count
				ns.RestockerDebug(
					"TRACE_TOP_OFF",
					tostring(itemID),
					room,
					source.bag,
					source.slot,
					destination.bag,
					destination.slot
				)
				C_Container.SplitContainerItem(source.bag, source.slot, room)
				C_Container.PickupContainerItem(destination.bag, destination.slot)
				if CursorHasItem() then
					ClearCursor() -- a bounced drop must not strand the split for the next move
				end
				return true
			end
		end
	end

	return false
end
