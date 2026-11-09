local _, ns = ...

--[[
    The bank run's single moves: placing what the cursor holds into the bank or the
    player's bags, issuing one bank-to-bag or bag-to-bank move, and whether the
    bank has room for a stash. Only the bank run (Restocker-Bank-Visit.lua and
    Restocker-Bank-State.lua) calls in; the containers and slot scans are
    Restocker-Bags.lua.
]]

--------------------------------------------------------------------------------
-- Placement
--------------------------------------------------------------------------------

-- Takes cursor item. Drops it into the bank, preferring a free slot.
local function PutItemInBank(bankInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	--[[
	    Drop into a FREE slot first -- that is the reliable move. Only stop once it has ACTUALLY
	    landed: a container's free-slot COUNT can disagree with its per-slot contents -- on Era
	    and TBC the main bank container reports free slots the slot scan can't find -- so a
	    bag may claim room yet fail to take the item. Keep trying the rest; giving up after the
	    first strands the item on the cursor.
	]]
	for _, bag in ipairs(ns.GetRestockBankBags()) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break -- landed
			end
		end
	end

	--[[
	    No free slot took it (bank effectively full). LAST resort: merge into the best partial
	    stack. We AVOID doing this first because merging a just-split cursor item onto an
	    occupied same-item slot can be rejected and BOUNCE the item back to its source, emptying
	    the cursor without it ever landing, which leaves the last unit short. When the bank
	    is full it's the only chance to land the item; if it still bounces, the next re-scan and
	    the watchdog report it honestly.
	]]
	if CursorHasItem() and itemInfo then
		local bestFit = bankInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	--[[
	    CRITICAL: never leave an item stranded on the cursor. A stranded item is what makes
	    the NEXT SplitContainerItem throw "Couldn't split those items".
	]]
	if CursorHasItem() then
		ns.RestockerDebug("TRACE_BANK_NO_ROOM")
		ClearCursor()
		return false
	end

	return true
end

-- Takes cursor item. Drops it into the player bags, preferring a free slot.
local function PutItemInPlayerBag(playerInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	--[[
	    Drop into a FREE slot first -- reliable. Keep trying bags until it actually lands
	    (a bag can claim room it won't grant this item), don't give up after the first.
	]]
	for _, bag in ipairs(ns.restockPlayerBags) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break -- landed
			end
		end
	end

	--[[
	    No free slot took it (bags effectively full). LAST resort: merge into the best partial
	    stack. We AVOID doing this first because merging a just-split cursor item onto an
	    occupied same-item slot can be rejected and BOUNCE the item back to the bank, emptying
	    the cursor without it ever landing, which leaves the last unit short. When bags are full it's the only way to top off a stack; a bounce is caught by the
	    next re-scan and the watchdog.
	]]
	if CursorHasItem() and itemInfo then
		local bestFit = playerInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	--[[
	    CRITICAL: never leave an item stranded on the cursor. A stranded item is what makes
	    the NEXT SplitContainerItem throw "Couldn't split those items".
	]]
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

--[[
    Adds one bag's slots holding itemID to candidates, false while any of them is
    locked. Matched by itemID, which is locale-proof and never confuses two items
    that share a localized name, and read off the client's own slot record first,
    so only a match builds a row.
]]
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
    Issue at most one bank->bag move from the given candidates. No plan bookkeeping is
    deducted here on purpose: the caller re-scans real inventory next step, so a move that
    the server rejected or only partially placed simply shows up as "still short" and is
    retried.

    `overshoot` is the escape hatch for a split that keeps being rejected
    ("Couldn't split those items") -- pull a WHOLE stack instead and go over
    target. UseContainerItem is the one move the server never bounces; overshooting past the
    target is what guarantees it gets reached, and the stash-back pass returns the excess for
    items that stash to bank. Going a little over beats stopping short.
]]
local function MoveOneStackBankToPlayer(playerInventory, candidates, moveAmount, overshoot)
	for _, moveCandidate in ipairs(candidates) do
		-- A whole stack that fits within what we still need
		if moveCandidate.count <= moveAmount then
			ns.RestockerDebug("TRACE_USE_FROM_BANK", moveCandidate.name, moveCandidate.bag, moveCandidate.slot)
			C_Container.UseContainerItem(moveCandidate.bag, moveCandidate.slot, nil, nil)
			return true
		end

		-- Stack is bigger than the remainder: split off exactly what's left to do
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
	--[[
	    Bank bags in reverse: the deepest bag is emptied first. On Era and TBC that
	    keeps the main bank container's free slots for a later stash-back; on
	    Forever it simply empties the last tab first.
	]]
	for _, bag in ipairs(ns.GetRestockBankBagsReversed()) do
		local moveCandidates = ScanBagFor(bag, moveItemID)
		table.sort(moveCandidates, ns.CompareByStackSizeAscending)

		if MoveOneStackBankToPlayer(playerInventory, moveCandidates, moveAmount, overshoot) then
			return true
		end
	end

	return false -- did not move
end

--[[
    Issue at most one bag->bank move. As with ns.MoveRestockItemFromBank, nothing is deducted --
    the next step's re-scan reflects what actually moved.
]]
local function MoveOneStackPlayerToBank(bankInventory, candidates, moveAmount)
	for _, containerItemInfo in ipairs(candidates) do
		if containerItemInfo.count <= moveAmount then
			C_Container.UseContainerItem(containerItemInfo.bag, containerItemInfo.slot, nil, nil)
			return true
		end

		if containerItemInfo.count > moveAmount then
			-- May be nil if the item isn't cached; PutItemInBank then drops it in a free slot
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
	    Candidates come from ALL player bags at once, sorted smallest stack first GLOBALLY.
	    Bag by bag, an early bag's big stack would be SPLIT (the flaky cursor move) even
	    when a later bag holds a loose stack of exactly the excess, which a whole-stack
	    UseContainerItem -- the reliable, server-side deposit -- can move instead.
	]]
	local moveCandidates = ScanBagsFor(ns.restockCountedBags, moveItemID)

	table.sort(moveCandidates, ns.CompareByStackSizeAscending)

	return MoveOneStackPlayerToBank(bankInventory, moveCandidates, moveAmount)
end

--[[
    Whether the bank still has room for a stash: only a free general-purpose
    slot counts, since a free slot in a profession bag cannot take what the run
    stashes. The caller decides what an answer means; this only reports it.
]]
function ns.BankHasRestockSpace()
	return HasFreeBagSlot(ns.GetRestockBankBags(), true)
end
