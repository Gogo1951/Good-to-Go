local _, ns = ...

--------------------------------------------------------------------------------
-- Recipe Resolution
--------------------------------------------------------------------------------

-- Keyed by the crafted item's ID. Orders are for its reagents only, so a recipe needs no item data.
local buyIngredients = {}

function ns.SetupCraftingRecipes()
	if next(buyIngredients) then
		return
	end

	for _, row in ipairs(ns.POISON_RECIPES) do
		local reagents = {}
		for _, reagent in ipairs(row[2]) do
			reagents[#reagents + 1] = { itemID = reagent[1], count = reagent[2] }
		end
		buyIngredients[row[1]] = { itemID = row[1], reagents = reagents }
	end
end

--------------------------------------------------------------------------------
-- Reagent Purchases
--------------------------------------------------------------------------------

function ns.BuildCraftingPurchaseOrder()
	local purchaseOrder = {}
	local settings = ns.restockSettings

	local list = settings.lists[settings.currentList]

	for _, item in pairs(list) do
		-- A row's Buy toggle governs every purchase it makes, its ingredients included (nil means on).
		local recipe = item.buyFromMerchant ~= false and buyIngredients[item.itemID]
		if recipe then
			--[[
			    Bags only: the bank pile is one the bank run stashes above Keep, so
			    counting it would refuse reagents for crafts still to make. No
			    minimum shortfall: any gap is bought for.
			]]
			local haveCrafted = C_Item.GetItemCount(item.itemID, false, false) or 0
			local craftedMissing = (item.amount or 0) - haveCrafted

			if craftedMissing > 0 then
				for _, reagent in ipairs(recipe.reagents) do
					local amountToGet = reagent.count * craftedMissing
					purchaseOrder[reagent.itemID] = (purchaseOrder[reagent.itemID] or 0) + amountToGet
				end
			end
		end
	end

	--[[
	    Floored at 0: ns.RestockFromMerchant adds these to the list's own orders,
	    where a negative would shrink a row's buy. A listed reagent's own order
	    already counts the bags up to its Keep, so only the rest comes off here.
	]]
	for reagentID, _ in pairs(purchaseOrder) do
		local inBags = C_Item.GetItemCount(reagentID, false) or 0
		local row = list[reagentID]
		if row and row.buyFromMerchant ~= false then
			inBags = math.max(0, inBags - (row.amount or 0))
		end
		if inBags > 0 then
			local remaining = purchaseOrder[reagentID] - inBags
			purchaseOrder[reagentID] = remaining > 0 and remaining or 0
		end
	end

	return purchaseOrder
end
