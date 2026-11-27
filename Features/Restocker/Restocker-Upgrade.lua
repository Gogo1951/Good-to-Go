local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Consumable Upgrades
--------------------------------------------------------------------------------

--[[
    Only ever forward, to a strictly later tier: an item above the player's
    level was stocked on purpose and moves only once outgrown.
]]

--[[
    A tier's third field is its rank; row order means nothing. Each chain is
    sorted by rank once here, so every walker of chain.tiers sees them in order.
]]
local function ByRank(a, b)
	return a[3] < b[3]
end

-- [itemID] = { chain = <chain>, rank = <the tier's rank> }
local UPGRADE_INDEX = {}
for _, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS) do
	table.sort(chain.tiers, ByRank)
	for _, tier in ipairs(chain.tiers) do
		UPGRADE_INDEX[tier[2]] = { chain = chain, rank = tier[3] }
	end
end

-- A ladder of one tier (the Hearthstone) has nowhere to go, so its tick would never do anything.
function ns.CanUpgradeRestockItem(itemID)
	local entry = itemID ~= nil and UPGRADE_INDEX[itemID]
	return (entry and #entry.chain.tiers > 1) or false
end

-- Rank, not level, settles tiers that share a level (Wrath's level-65 food and water).
local function BestTier(chain, level)
	local best
	for _, tier in ipairs(chain.tiers) do
		if tier[1] <= level and (best == nil or tier[3] > best[3]) then
			best = tier
		end
	end
	return best
end

-- Staples adds through this, so a tick starts on the tier the upgrader would pick.
function ns.BestChainItemID(chain, level)
	local tier = BestTier(chain, level)
	return tier and tier[2]
end

--[[
    Keeps everything the player set on the row. A target already on the list
    merges: the amounts add and the old row goes, so nothing asked for is lost.
]]
local function MoveToTier(list, fromID, toID)
	local item = list[fromID]
	local existing = list[toID]

	if existing then
		existing.amount = (existing.amount or 0) + (item.amount or 0)
	else
		local info = ns.GetItemData(toID)
		item.itemID = toID
		item.itemName = info and info.itemName or ""
		list[toID] = item
	end

	list[fromID] = nil
end

-- A cold target defers the upgrade; the retry rides on GET_ITEM_INFO_RECEIVED, not a timer.
local pendingUpgrade = false

-- Upgrade targets the server said it has no item for; never waited on again this session.
local failedTargets = {}

function ns.DropFailedUpgradeTarget(itemID)
	failedTargets[itemID] = true
end

-- Each swap is { fromLink, fromAmount, toLink, toAmount }.
local function BuildRestockUpgradeLines(swaps)
	local lines = { L["RESTOCKER_UPGRADED"] }
	for _, swap in ipairs(swaps) do
		lines[#lines + 1] =
			string.format(L["RESTOCKER_UPGRADED_ITEM"], swap.fromLink, swap.fromAmount, swap.toLink, swap.toAmount)
	end
	return lines
end

--[[
    PLAYER_LEVEL_UP passes its level through: UnitLevel still reads the old one
    inside that event. Callers clear of the ding pass nothing.
]]
function ns.UpgradeRestockList(newLevel)
	local settings = ns.restockSettings
	local list = settings and settings.lists and settings.lists[settings.currentList]
	if not list then
		return
	end

	local level = newLevel or UnitLevel("player") or 1
	pendingUpgrade = false

	-- Collected before anything moves: MoveToTier adds and deletes keys, undefined under pairs().
	local planned = {}
	for itemID, item in pairs(list) do
		-- Nil means on.
		if item.upgrade ~= false then
			local entry = UPGRADE_INDEX[itemID]
			if entry then
				local best = BestTier(entry.chain, level)
				if best and best[3] > entry.rank then
					local targetID = best[2]
					if ns.GetItemData(targetID) then
						planned[#planned + 1] = { from = itemID, to = targetID }
					elseif not failedTargets[targetID] and C_Item.DoesItemExistByID(targetID) then
						-- Waits for the target's data, so no row ever pairs the old name with the new ID.
						pendingUpgrade = true
						ns.SyncRestockItemInfoSubscription()
					end
				end
			end
		end
	end

	if #planned == 0 then
		return
	end

	-- The amounts are read either side of MoveToTier: they differ when a merge summed them.
	local swaps = {}
	for _, move in ipairs(planned) do
		local from = list[move.from]
		local fromAmount = (from and from.amount) or 0
		local swap = { fromLink = ns.GetItemHyperlink(move.from), fromAmount = fromAmount }
		MoveToTier(list, move.from, move.to)
		local moved = list[move.to]
		swap.toLink = ns.GetItemHyperlink(move.to)
		swap.toAmount = (moved and moved.amount) or fromAmount
		swaps[#swaps + 1] = swap
	end
	for _, line in ipairs(BuildRestockUpgradeLines(swaps)) do
		ns:PrintMessage(line)
	end

	ns.UpdateRestockList()
end

function ns.HasPendingUpgrade()
	return pendingUpgrade
end
