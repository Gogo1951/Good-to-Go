local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Starter Restock List
--------------------------------------------------------------------------------

--[[
    Every staple comes from ns.CONSUMABLE_UPGRADE_CHAINS, so none is offered that
    the upgrader won't then maintain. Closing with the pre-ticks kept fills the
    list, so the window doesn't return; unticking them all brings it back.
]]

-- No potions: past the first tiers they are Alchemy goods no vendor restock can rely on.
local CHAINS_BY_KEY = {}
for _, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS) do
	if chain.kind == "food" then
		CHAINS_BY_KEY["food:" .. chain.diet] = chain
	elseif chain.kind == "poison" then
		CHAINS_BY_KEY["poison:" .. chain.group] = chain
	elseif chain.kind == "reagent" then
		CHAINS_BY_KEY["reagent:" .. chain.reagent] = chain
	else
		CHAINS_BY_KEY[chain.kind] = chain
	end
end

-- A row whose ladder this flavor lacks is dropped here rather than breaking the popup.
local STARTER_CATEGORIES = {}
for _, row in ipairs(ns.STARTER_LIST_CATEGORIES) do
	local chain = CHAINS_BY_KEY[row.chainKey]
	if chain then
		row.chain = chain
		row.chainKey = nil
		STARTER_CATEGORIES[#STARTER_CATEGORIES + 1] = row
	end
end

function ns.GetStarterCategories()
	return STARTER_CATEGORIES
end

function ns.IsStarterCategoryForClass(category)
	if category.classes == nil then
		return true
	end
	local _, classToken = UnitClass("player")
	return category.classes[classToken] == true
end

-- Hides reagents for spells not yet trainable and ladders this flavor holds empty.
function ns.IsStarterCategoryAvailable(category)
	return ns.BestChainItemID(category.chain, UnitLevel("player") or 1) ~= nil
end

--------------------------------------------------------------------------------
-- Ticking a Staple
--------------------------------------------------------------------------------

local function CurrentList()
	local settings = ns.restockSettings
	return settings and settings.lists and settings.lists[settings.currentList]
end

function ns.IsRestockListEmpty()
	local list = CurrentList()
	return list == nil or next(list) == nil
end

-- Any tier, not today's best, so the box stays ticked after an upgrade moves the entry.
local function ChainItemOnList(list, chain)
	for _, tier in ipairs(chain.tiers) do
		if list[tier[2]] ~= nil then
			return tier[2]
		end
	end
	return nil
end

--[[
    [itemID] = category for ticks whose item is cold: adding now would write a
    nameless row. The box reads ticked meanwhile, so the click visibly takes.
]]
local pendingStarterAdds = {}

function ns.HasPendingStarterAdds()
	return next(pendingStarterAdds) ~= nil
end

function ns.DropPendingStarterAdd(itemID)
	pendingStarterAdds[itemID] = nil
end

function ns.RetryPendingStarterAdds()
	local retry = pendingStarterAdds
	pendingStarterAdds = {}
	for _, category in pairs(retry) do
		ns.AddStarterCategory(category)
	end
end

-- Nil until the item resolves, unless the category counts single items.
local function StepSize(category, stackSize)
	if category.countsItems then
		return 1
	end
	return stackSize
end

local function CategoryAmount(category, stackSize)
	if category.fixedAmount then
		return category.fixedAmount
	end
	local step = StepSize(category, stackSize)
	return step and ns.GetStarterCategoryStacks(category) * step
end

function ns.AddStarterCategory(category)
	local list = CurrentList()
	if not list or ChainItemOnList(list, category.chain) then
		return
	end

	local itemID = ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
	if not itemID then
		return
	end

	local info = ns.GetItemData(itemID)
	if not info then
		-- An item this client has none of never resolves, so it is not waited on.
		if C_Item.DoesItemExistByID(itemID) then
			pendingStarterAdds[itemID] = category
			ns.SyncRestockItemInfoSubscription()
		end
		return
	end

	-- The hand-add defaults (ns.AddRestockItem); only the amount differs.
	list[itemID] = {
		itemName = info.itemName,
		itemID = itemID,
		amount = CategoryAmount(category, math.max(1, info.itemStackCount or 1)),
		buyFromMerchant = true,
		stashToBank = true,
		restockFromBank = true,
	}

	ns.restockNewItems[itemID] = true

	ns.UpdateRestockList()
end

function ns.RemoveStarterCategory(category)
	-- A pending add must be canceled too, or it would land after the untick.
	for itemID, pending in pairs(pendingStarterAdds) do
		if pending == category then
			pendingStarterAdds[itemID] = nil
		end
	end

	local list = CurrentList()
	if not list then
		return
	end

	local removed = false
	for _, tier in ipairs(category.chain.tiers) do
		local itemID = tier[2]
		if list[itemID] ~= nil then
			list[itemID] = nil
			ns.restockNewItems[itemID] = nil
			removed = true
		end
	end
	if removed then
		ns.UpdateRestockList()
	end
end

function ns.SetStarterCategory(category, checked)
	if checked then
		ns.AddStarterCategory(category)
	else
		ns.RemoveStarterCategory(category)
	end
end

function ns.IsStarterCategoryChecked(category)
	local list = CurrentList()
	if list and ChainItemOnList(list, category.chain) then
		return true
	end
	for _, pending in pairs(pendingStarterAdds) do
		if pending == category then
			return true
		end
	end
	return false
end

--[[
    The count lives on the listed row's amount while ticked (rounded to whole
    stacks, so a hand edit reads sensibly), and here otherwise: never saved, so
    a count can be picked before ticking. A listed row whose item is cold takes
    no write. fixedAmount rows answer 1 and ignore writes.
]]
local selectedStacks = {} -- [category.key] = stacks, while the staple is not on the list

-- With choices (Soul Shards), snaps up to the smallest offer covering the count, so a hand edit never blanks it.
local function SnapStacks(category, count)
	local choices = category.choices
	if not choices then
		return math.max(1, math.min(category.maxStacks, count))
	end
	for _, offered in ipairs(choices) do
		if count <= offered then
			return offered
		end
	end
	return choices[#choices]
end

-- The listed tier while ticked, since its amount is what the dropdown reads; else what a tick would add.
function ns.GetStarterCategoryItemID(category)
	local list = CurrentList()
	return (list and ChainItemOnList(list, category.chain))
		or ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
end

-- A poison row is named by its first tier, whose name is the type's ("Instant Poison").
function ns.GetStarterCategoryNameItemID(category)
	if category.namesFirstTier then
		return category.chain.tiers[1][2]
	end
	return ns.GetStarterCategoryItemID(category)
end

-- The client's item name needs no translation. Nil while cold; the pop-up repaints when it warms.
function ns.GetStarterCategoryName(category)
	if category.label then
		return category.label
	end
	return (C_Item.GetItemInfo(ns.GetStarterCategoryNameItemID(category)))
end

-- Nil until the item resolves.
function ns.GetStarterCategoryStackSize(category)
	local itemID = ns.GetStarterCategoryItemID(category)
	local stackSize = itemID and select(8, C_Item.GetItemInfo(itemID))
	return stackSize and math.max(1, stackSize)
end

function ns.GetStarterCategoryStacks(category)
	if category.fixedAmount then
		return 1
	end
	local list = CurrentList()
	local listedID = list and ChainItemOnList(list, category.chain)
	local step = listedID and StepSize(category, ns.GetStarterCategoryStackSize(category))
	if step then
		local amount = list[listedID].amount or step
		return SnapStacks(category, math.floor(amount / step + 0.5))
	end
	return selectedStacks[category.key] or category.defaultStacks or 1
end

function ns.SetStarterCategoryStacks(category, stacks)
	if category.fixedAmount then
		return
	end
	stacks = SnapStacks(category, math.floor(stacks))
	selectedStacks[category.key] = stacks

	local list = CurrentList()
	local listedID = list and ChainItemOnList(list, category.chain)
	if listedID then
		local step = StepSize(category, ns.GetStarterCategoryStackSize(category))
		if step then
			list[listedID].amount = stacks * step
			ns.UpdateRestockList()
		end
		return
	end

	-- Picking a count ticks the staple: otherwise the list staying empty would read as broken.
	ns.AddStarterCategory(category)
end

--[[
    Nil until the item resolves, tested with C_Item.GetItemInfo because
    ns.GetItemLabel names a cold item from a hand-built link.
]]
function ns.DescribeStarterCategory(category)
	local itemID = ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
	local amount = CategoryAmount(category, ns.GetStarterCategoryStackSize(category))
	local name = itemID and C_Item.GetItemInfo(itemID)
	if not (amount and name) then
		return nil
	end
	local template = (#category.chain.tiers > 1) and L["STARTER_POPUP_ITEM_DESCRIPTION"]
		or L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"]
	return name, string.format(template, ns.GetItemLabel(itemID, nil), amount)
end

--------------------------------------------------------------------------------
-- Login Trigger
--------------------------------------------------------------------------------

-- At 5 a character is still on starter-zone money; by 6 they have met vendors worth a list.
local STARTER_MIN_LEVEL = 6

-- Past the loading-screen flurry, as the Consumable Macros' settle timer is.
local STARTER_POPUP_DELAY = 3

local function IsDefaultCategory(category)
	local defaultFor = category.defaultFor
	if defaultFor == nil then
		return false
	end
	if defaultFor == "all" then
		return true
	end
	local _, classToken = UnitClass("player")
	return defaultFor[classToken] == true
end

function ns.MaybeShowStarterListPopup()
	-- Read again: the switch can flip during the login delay.
	if not ns.restockerLoaded or not ns.IsRestockerEnabled() then
		return
	end
	-- MIGRATION (remove after 2026-12-08): an old add-on's Restock Lists may be about to come over.
	if ns.IsLegacyImportPending() then
		return
	end
	if (UnitLevel("player") or 1) < STARTER_MIN_LEVEL then
		return
	end

	local list = CurrentList()
	if not list or next(list) ~= nil then
		return
	end

	-- Keeps a data change from opening an empty window. Mid-combat skips this login only.
	local level = UnitLevel("player") or 1
	local anyOffered = false
	for _, category in ipairs(STARTER_CATEGORIES) do
		if ns.IsStarterCategoryForClass(category) and ns.BestChainItemID(category.chain, level) then
			anyOffered = true
			break
		end
	end
	if not anyOffered or InCombatLockdown() then
		return
	end

	-- Only here: a player who never sees the popup never has a list written for them.
	for _, category in ipairs(STARTER_CATEGORIES) do
		if
			IsDefaultCategory(category)
			and ns.IsStarterCategoryForClass(category)
			and ns.IsStarterCategoryAvailable(category)
		then
			ns.AddStarterCategory(category)
		end
	end

	-- Alone, one window to read at a time; on this route Done opens the list and the footer names the command.
	ns.ShowStarterListPopup(true)
end

-- Fresh logins only: a /reload or loading screen would reopen a window already closed this sitting.
function ns.OnStarterListEnteringWorld(isInitialLogin, _isReloadingUi)
	if not isInitialLogin then
		return
	end
	C_Timer.After(STARTER_POPUP_DELAY, ns.MaybeShowStarterListPopup)
end
