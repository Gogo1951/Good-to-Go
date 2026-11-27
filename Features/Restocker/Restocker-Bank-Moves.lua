local _, ns = ...

--------------------------------------------------------------------------------
-- Placement
--------------------------------------------------------------------------------

local function PutItemInBank(bankInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	--[[
	    Free slots first, trying every bag until it lands: on Era and TBC the main
	    bank container reports free slots the slot scan can't find.
	]]
	for _, bag in ipairs(ns.GetRestockBankBags()) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break
			end
		end
	end

	--[[
	    Merging is the last resort: a split item merged onto a partial stack can
	    bounce back to its source, leaving the last unit short.
	]]
	if CursorHasItem() and itemInfo then
		local bestFit = bankInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	-- An item left on the cursor makes the next split fail with "Couldn't split those items".
	if CursorHasItem() then
		ns.RestockerDebug("TRACE_BANK_NO_ROOM")
		ClearCursor()
		return false
	end

	return true
end

-- Same order as PutItemInBank: free slots in every bag, then a merge, then clear.
local function PutItemInPlayerBag(playerInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	for _, bag in ipairs(ns.restockPlayerBags) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break
			end
		end
	end

	if CursorHasItem() and itemInfo then
		local bestFit = playerInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	if CursorHasItem() then
		ns.RestockerDebug("TRACE_BAG_NO_ROOM")
		ClearCursor()
		return false
	end

	return true
end

-- generalOnly counts only general-purpose bags: a herb, enchanting or soul bag takes only its own kind.
local function HasFreeBagSlot(bags, generalOnly)
	for _, bag in ipairs(bags) do
		local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(bag.bagID)
		if numberOfFreeSlots > 0 and (not generalOnly or (bagType or 0) == 0) then
			return true
		end
	end
	return false
end

-- False while any matching slot is locked. Matched by itemID, never by localized name.
local function AddSlotsHolding(bag, itemID, candidates)
	for slot = 1, C_Container.GetContainerNumSlots(bag.bagID), 1 do
		local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
		if itemInfo and itemInfo.itemID == itemID then
			local containerItemInfo = ns.GetRestockContainerItemInfo(bag.bagID, slot)
			if containerItemInfo then
				if containerItemInfo.locked then
					return false
				end
				candidates[#candidates + 1] = containerItemInfo
			end
		end
	end
	return true
end

-- Every slot in bags holding itemID, or none while any of them is locked.
local function ScanBagsFor(bags, itemID)
	local itemCandidates = {}
	for _, bag in ipairs(bags) do
		if not AddSlotsHolding(bag, itemID, itemCandidates) then
			return {}
		end
	end
	return itemCandidates
end

-- One bag's slots holding itemID, or none while any of them is locked.
local function ScanBagFor(bag, itemID)
	local itemCandidates = {}
	if not AddSlotsHolding(bag, itemID, itemCandidates) then
		return {}
	end
	return itemCandidates
end

--------------------------------------------------------------------------------
-- Moving Items
--------------------------------------------------------------------------------

--[[
    `overshoot` answers a split that keeps failing: a whole stack goes over target,
    since UseContainerItem never bounces, and the stash-back returns the excess.
]]
local function MoveOneStackBankToPlayer(playerInventory, candidates, moveAmount, overshoot)
	for _, moveCandidate in ipairs(candidates) do
		if moveCandidate.count <= moveAmount then
			ns.RestockerDebug("TRACE_USE_FROM_BANK", moveCandidate.name, moveCandidate.bag, moveCandidate.slot)
			C_Container.UseContainerItem(moveCandidate.bag, moveCandidate.slot, nil, nil)
			return true
		end

		if moveCandidate.count > moveAmount then
			if overshoot then
				ns.RestockerDebug(
					"TRACE_OVERSHOOT_FROM_BANK",
					moveCandidate.name,
					moveCandidate.bag,
					moveCandidate.slot
				)
				C_Container.UseContainerItem(moveCandidate.bag, moveCandidate.slot, nil, nil)
				return true
			end

			local itemInfo = ns.GetItemData(moveCandidate.itemID)
			ns.RestockerDebug("TRACE_SPLIT_FROM_BANK", moveCandidate.name, moveCandidate.bag, moveCandidate.slot)
			C_Container.SplitContainerItem(moveCandidate.bag, moveCandidate.slot, moveAmount)
			PutItemInPlayerBag(playerInventory, itemInfo, moveAmount)
			return true
		end
	end

	return false
end

function ns.MoveRestockItemFromBank(playerInventory, moveItemID, moveAmount, overshoot)
	-- Deepest bag first: on Era and TBC that keeps the main container's free slots for a stash-back.
	for _, bag in ipairs(ns.GetRestockBankBagsReversed()) do
		local moveCandidates = ScanBagFor(bag, moveItemID)
		table.sort(moveCandidates, ns.CompareByStackSizeAscending)

		if MoveOneStackBankToPlayer(playerInventory, moveCandidates, moveAmount, overshoot) then
			return true
		end
	end

	return false
end

local function MoveOneStackPlayerToBank(bankInventory, candidates, moveAmount)
	for _, containerItemInfo in ipairs(candidates) do
		if containerItemInfo.count <= moveAmount then
			C_Container.UseContainerItem(containerItemInfo.bag, containerItemInfo.slot, nil, nil)
			return true
		end

		if containerItemInfo.count > moveAmount then
			-- Nil while uncached; PutItemInBank then only tries free slots.
			local itemInfo = ns.GetItemData(containerItemInfo.itemID)

			C_Container.SplitContainerItem(containerItemInfo.bag, containerItemInfo.slot, moveAmount)
			PutItemInBank(bankInventory, itemInfo, moveAmount)
			return true
		end
	end

	return false
end

function ns.MoveRestockItemToBank(bankInventory, moveItemID, moveAmount)
	--[[
	    Sorted across all bags at once: bag by bag, an early big stack would be split
	    even when a later bag holds a stack that moves whole, which never bounces.
	]]
	local moveCandidates = ScanBagsFor(ns.restockCountedBags, moveItemID)

	table.sort(moveCandidates, ns.CompareByStackSizeAscending)

	return MoveOneStackPlayerToBank(bankInventory, moveCandidates, moveAmount)
end

-- Only a free general-purpose slot counts: a profession bag can't take what the run stashes.
function ns.BankHasRestockSpace()
	return HasFreeBagSlot(ns.GetRestockBankBags(), true)
end
