local _, ns = ...

--[[
    Restocker-Bank-Tidy -- the bank restock's tidy phase: once every item is at
    target, merge the partial stacks of maintained items that a run leaves
    behind. The run itself, and the watchdog that ends this phase, are
    Restocker-Bank-Visit.lua.
]]

--[[
    The largest stack an item allows, or nil when it doesn't stack (or isn't cached yet),
    which the tidy phase reads as "leave it alone".
]]
local function MaxStackOf(itemID)
	local info = ns.GetItemData(itemID)
	local maxStack = info and info.itemStackCount
	if maxStack and maxStack > 1 then
		return maxStack
	end
	return nil
end

--[[
    How many PARTIAL stacks of maintained items the bags and the bank hold, used as the
    tidy-phase progress signal. Every tidy move leaves at least one fewer partial stack
    behind -- a whole-stack merge empties one, a top-off fills one -- so this strictly
    decreases while consolidation is making headway and plateaus when done (or if a merge
    bounces), which the tidy watchdog uses to stop. Counting all stacks would miss a top-off,
    which fills one stack without removing any.
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
    Merge one pair of partial stacks of a maintained item within one inventory (the player
    bags or the bank, never across), to undo the fragmentation that free-slot-first placement
    and exact splits leave behind -- in the bags 10 + 9 + 1 -> 20, and in the bank the
    5 + 5 + 4 + 2 a run of small pulls carves out of full stacks.

    The smallest partial stack is the source. A whole-stack merge comes first: pick it all up
    and drop it onto the largest partial that has room for ALL of it, no split involved --
    the reliable manual consolidation move. Only when no stack can take it whole (4 + 2 with
    a stack size of 5) does it top off the largest partial with an exact split, which the
    server can bounce; a bounce is caught by the tidy watchdog, and the cursor is never left
    holding the split.
]]
function ns.ConsolidateRestockStacks(inventory)
	for itemID, slots in pairs(inventory.slots) do
		local maxStack = MaxStackOf(itemID)
		if maxStack then
			-- slots are sorted smallest-first (SortSlots), so partials are too
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
						C_Container.PickupContainerItem(source.bag, source.slot) -- pick up whole stack
						C_Container.PickupContainerItem(destination.bag, destination.slot) -- drop onto it -> merges
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
