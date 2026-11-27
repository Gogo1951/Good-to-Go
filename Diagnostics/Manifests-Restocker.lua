local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

local function ItemText(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	return string.format("%d (%s)", itemID, name or "name not loaded")
end

local function HasTemplate(name)
	return function()
		return type(C_XMLUtil) == "table" and C_XMLUtil.GetTemplateInfo(name) ~= nil
	end
end

local function HasScripts(frameName, ...)
	local scripts = { ... }
	return function()
		local frame = _G[frameName]
		if type(frame) ~= "table" or type(frame.HasScript) ~= "function" then
			return false
		end
		for _, script in ipairs(scripts) do
			if not frame:HasScript(script) then
				return false
			end
		end
		return true
	end
end

--------------------------------------------------------------------------------
-- API Checks
--------------------------------------------------------------------------------

-- Calls shared with the Consumable Macros sit in Manifests-Macros-for-Consumables.lua.
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	-- ns.AddItemTooltipPostCall takes the post-call route only with this enum too (Features/Utilities.lua).
	{
		"Enum.TooltipDataType.Item",
		function()
			return type(Enum) == "table" and type(Enum.TooltipDataType) == "table" and Enum.TooltipDataType.Item ~= nil
		end,
	},
	-- The legacy route reads each tooltip's item, and the Inventory Report clears its line on OnTooltipCleared.
	{
		"GameTooltip:GetItem (legacy)",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.GetItem) == "function"
		end,
	},
	{ "GameTooltip OnTooltipCleared", HasScripts("GameTooltip", "OnTooltipCleared") },
	{ "ItemRefTooltip OnTooltipCleared", HasScripts("ItemRefTooltip", "OnTooltipCleared") },
	{ "ItemRefTooltip OnTooltipSetItem (legacy)", HasScripts("ItemRefTooltip", "OnTooltipSetItem") },
	-- Forever's bank tabs are fetched for the character's bank (ns.FetchPurchasedBankTabIDs).
	{
		"Enum.BankType.Character",
		function()
			return type(Enum) == "table" and type(Enum.BankType) == "table" and Enum.BankType.Character ~= nil
		end,
	},
	-- Only Forever has a reagent bag; the Restocker and the Inventory Report read it there.
	{
		"NUM_REAGENTBAG_SLOTS (WoW Forever)",
		function()
			return type(NUM_REAGENTBAG_SLOTS) == "number" and NUM_REAGENTBAG_SLOTS > 0
		end,
	},
	-- The Inventory Report's Example picks a consumable from the bags (Inventory-Report-Tooltip.lua).
	{
		"C_Container.GetContainerItemID",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerItemID) == "function"
		end,
	},
	{
		"Enum.ItemClass.Consumable (guarded)",
		function()
			return type(Enum) == "table" and type(Enum.ItemClass) == "table" and Enum.ItemClass.Consumable ~= nil
		end,
	},
	-- The buy loop splits a purchase into stacks the vendor allows (Restocker-Merchant.lua).
	{
		"GetMerchantItemMaxStack",
		function()
			return type(GetMerchantItemMaxStack) == "function"
		end,
	},
	-- The Delete List confirm (Restocker-Window-List-Manage.lua).
	{
		"StaticPopup_Show",
		function()
			return type(StaticPopup_Show) == "function"
		end,
	},
	-- The footer sizes its labels by their full text width (Restocker-Window-Footer.lua).
	{
		"FontString:GetUnboundedStringWidth",
		function()
			-- Asked of a font string the game already made, so the check creates nothing.
			local fontString = _G.GameTooltipTextLeft1
			return type(fontString) == "table" and type(fontString.GetUnboundedStringWidth) == "function"
		end,
	},
	-- The window is built on first open, so until then this asks for the template; it creates nothing.
	{
		"Restock window SetTitle and SetPortraitToAsset (guarded)",
		function()
			local frame = _G.GoodToGoRestockFrame
			if type(frame) ~= "table" then
				return ns.HasTemplate("PortraitFrameTemplate")
			end
			return type(frame.SetTitle) == "function" and type(frame.SetPortraitToAsset) == "function"
		end,
	},
	-- The window's templates; a missing unguarded one stops the window from being built.
	{ "InsetFrameTemplate3", HasTemplate("InsetFrameTemplate3") },
	{ "UIPanelScrollFrameTemplate", HasTemplate("UIPanelScrollFrameTemplate") },
	{ "InputBoxTemplate", HasTemplate("InputBoxTemplate") },
	{ "UICheckButtonTemplate", HasTemplate("UICheckButtonTemplate") },
	{ "SearchBoxTemplate (guarded)", HasTemplate("SearchBoxTemplate") },
	{ "WowStyle1DropdownTemplate (guarded)", HasTemplate("WowStyle1DropdownTemplate") },
})

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

-- ns.GetItemLabel always has text, so this reads ns.GetItemData, nil until the client has the item.
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, {
	{
		constant = "HEARTHSTONE_ITEM_ID",
		kind = "item",
		id = ns.HEARTHSTONE_ITEM_ID,
		lookup = function()
			local info = ns.GetItemData(ns.HEARTHSTONE_ITEM_ID)
			return info and info.itemName
		end,
		request = function()
			C_Item.RequestLoadItemDataByID(ns.HEARTHSTONE_ITEM_ID)
		end,
	},
})

--------------------------------------------------------------------------------
-- Restocker Context
--------------------------------------------------------------------------------

-- For "the Restocker did nothing" and "the tooltip shows no counts" reports. Read-only.
local function MoneyText(copper)
	copper = copper or 0
	return string.format("%dg %ds %dc", math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end

-- Free slots in the carried bags that take any item (bag family 0).
local function FreeBagSlots()
	local free = 0
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, family = C_Container.GetContainerNumFreeSlots(bag)
		if family == 0 then
			free = free + (slots or 0)
		end
	end
	return free
end

--[[
    Counts read these by item ID, but the bank run skips a slot without a link,
    and a merchant run counts no room in their partial stacks.
]]
local function UnlinkedListSlots(bagIDs, list)
	local count = 0
	for _, bag in ipairs(bagIDs) do
		for slot = 1, C_Container.GetContainerNumSlots(bag) or 0 do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID and list[info.itemID] ~= nil and not info.hyperlink then
				count = count + 1
			end
		end
	end
	return count
end

local function FrameShown(name)
	local frame = _G[name]
	return type(frame) == "table" and type(frame.IsShown) == "function" and frame:IsShown() and true or false
end

-- Not through ns.BuildRestockShortfallList, which writes the item name onto each row.
local function ShortRows(list)
	local rows = {}
	for _, row in pairs(list or {}) do
		if type(row) == "table" and ns.IsRestockItemShort(row) then
			rows[#rows + 1] = {
				itemID = row.itemID,
				have = C_Item.GetItemCount(row.itemID, false, false) or 0,
				wanted = row.amount,
				buys = row.buyFromMerchant ~= false,
			}
		end
	end
	table.sort(rows, function(a, b)
		return a.itemID < b.itemID
	end)
	return rows
end

-- A tier is { level, itemID, rank }.
local function RowsDueUpgrade(list, level)
	local index = {}
	for _, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS or {}) do
		for _, tier in ipairs(chain.tiers) do
			index[tier[2]] = { chain = chain, rank = tier[3] }
		end
	end
	local due = {}
	for itemID, row in pairs(list or {}) do
		local entry = index[itemID]
		if type(row) == "table" and row.upgrade ~= false and entry then
			local best
			for _, tier in ipairs(entry.chain.tiers) do
				if tier[1] <= level and (best == nil or tier[3] > best[3]) then
					best = tier
				end
			end
			if best and best[3] > entry.rank then
				due[#due + 1] = string.format("%s to %s", ItemText(itemID), ItemText(best[2]))
			end
		end
	end
	table.sort(due)
	return due
end

function ns:BuildRestockerContextReport()
	local lines = { GetClientHeader(), "" }
	local global = ns.db and ns.db.global
	if not global then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end
	local settings = global.restocker or {}
	local lists = settings.lists or {}
	local list = settings.currentList and lists[settings.currentList]
	local characterKey = ns.GetCharacterKey()

	lines[#lines + 1] = "-- Restocker --"
	lines[#lines + 1] = string.format(
		"Restocker switch: %s (off stops the window, /restock, the reminders and every purchase) // started: %s",
		OnOff(global.restockerEnabled),
		YesNo(ns.restockerLoaded)
	)
	-- ns.restockSettings is an empty table until login binds it.
	lines[#lines + 1] = string.format(
		"Settings bound to the saved table: %s // window built: %s",
		YesNo(ns.restockSettings == settings),
		YesNo(ns.restockWindow)
	)
	lines[#lines + 1] = string.format(
		"List in use: %s // this character picks: %s // exists: %s // rows: %d // lists saved: %d",
		tostring(settings.currentList),
		tostring(ns.GetChosenRestockList()),
		YesNo(list),
		CountKeys(list),
		CountKeys(lists)
	)
	local reserve = settings.goldReserve and (settings.goldReserveAmount or 0) * 10000 or 0
	lines[#lines + 1] = string.format(
		"Gold Reserve: %s, %s gold // money now: %s // spendable above the reserve: %s",
		OnOff(settings.goldReserve),
		tostring(settings.goldReserveAmount),
		MoneyText(GetMoney()),
		MoneyText(math.max(0, GetMoney() - reserve))
	)

	-- A row without an item ID never matches a vendor slot; one needing a standing waits for a vendor who grants it.
	local buyOff, noID, takeOn, storeOn, upgradeOff, onLadder, unnamed, keepNone = 0, 0, 0, 0, 0, 0, 0, 0
	local extraOn, notCached = 0, 0
	-- An uncached item has no stack size or bag family to go on.
	local IsCached = type(C_Item.IsItemDataCachedByID) == "function" and C_Item.IsItemDataCachedByID
	local needsStanding = {}
	for id, row in pairs(list or {}) do
		if type(row) == "table" then
			if row.buyFromMerchant == false then
				buyOff = buyOff + 1
			end
			-- A Keep of 0 orders nothing unless Extra is on.
			if (row.amount or 0) <= 0 then
				keepNone = keepNone + 1
			end
			if row.buyExtra == true then
				extraOn = extraOn + 1
			end
			if IsCached and row.itemID and not IsCached(row.itemID) then
				notCached = notCached + 1
			end
			if not row.itemID then
				noID = noID + 1
			end
			if row.restockFromBank then
				takeOn = takeOn + 1
			end
			if row.stashToBank then
				storeOn = storeOn + 1
			end
			if row.upgrade == false then
				upgradeOff = upgradeOff + 1
			end
			if ns.CanUpgradeRestockItem and ns.CanUpgradeRestockItem(row.itemID or id) then
				onLadder = onLadder + 1
			end
			if not row.itemName or row.itemName == "" then
				unnamed = unnamed + 1
			end
			if (row.reaction or 0) > 0 then
				needsStanding[#needsStanding + 1] =
					string.format("%s needs %s", ItemText(row.itemID), tostring(ns.GetStandingLabel(row.reaction)))
			end
		end
	end
	table.sort(needsStanding)
	lines[#lines + 1] = string.format(
		"Rows with Buy off: %d // Keep 0: %d // Extra on: %d // without an item ID: %d // without a name yet: %d // Take from bank on: %d // Store in bank on: %d",
		buyOff,
		keepNone,
		extraOn,
		noID,
		unnamed,
		takeOn,
		storeOn
	)
	lines[#lines + 1] = string.format(
		"Rows on an upgrade ladder: %d // with Upgrade off: %d // needing a standing: %s",
		onLadder,
		upgradeOff,
		#needsStanding > 0 and table.concat(needsStanding, ", ") or "(none)"
	)
	-- A row still listed here after a level-up, a login or the switch going on is waiting on its target's item data.
	local due = RowsDueUpgrade(list, UnitLevel("player") or 1)
	lines[#lines + 1] = string.format(
		"Rows due an upgrade at level %d: %s",
		UnitLevel("player") or 0,
		#due > 0 and table.concat(due, ", ") or "(none)"
	)
	lines[#lines + 1] = string.format(
		"Waiting on item data: adds %d, rows %d, an upgrade %s, staples %s // rows not in the item cache: %s",
		CountKeys(ns.restockItemWait),
		CountKeys(ns.restockColdRows),
		YesNo(ns.HasPendingUpgrade and ns.HasPendingUpgrade()),
		YesNo(ns.HasPendingStarterAdds and ns.HasPendingStarterAdds()),
		IsCached and tostring(notCached) or "(no API)"
	)

	-- A specialty bag takes only its own kind; the reagent bag is counted but never bought into.
	lines[#lines + 1] = string.format(
		"Free bag slots: %d // bags the buy loop reads: %d // bags counted: %d // reagent bag: %s // list items in the bags without a link yet: %d",
		FreeBagSlots(),
		#(ns.restockPlayerBags or {}),
		#(ns.restockCountedBags or {}),
		tostring(ns.GetReagentBagID() or "(none)"),
		list and UnlinkedListSlots(ns.CARRIED_BAG_IDS, list) or 0
	)
	local bagLines = {}
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, family = C_Container.GetContainerNumFreeSlots(bag)
		if C_Container.GetContainerNumSlots(bag) > 0 then
			bagLines[#bagLines + 1] = string.format("%d: %d free, type %s", bag, slots or 0, tostring(family))
		end
	end
	lines[#lines + 1] = "Bags: " .. table.concat(bagLines, " // ")
	-- A stale merchant flag stops the bank run; a flag never set skips the closing reminder.
	lines[#lines + 1] = string.format(
		"Merchant open: %s (game's window shown: %s) // buying skipped (Shift held): %s // Bank open: %s (game's window shown: %s)",
		YesNo(ns.merchantIsOpen),
		YesNo(FrameShown("MerchantFrame")),
		YesNo(ns.merchantBuyingSkipped),
		YesNo(ns.bankIsOpen),
		YesNo(FrameShown("BankFrame"))
	)

	-- A row needing better standing is skipped in silence; a vendor missing any reagent of a craft sells none.
	if ns.merchantIsOpen then
		local reaction = UnitReaction("npc", "player") or UnitReaction("target", "player") or 0
		local plainReaction = ns.IsPlain(reaction)
		lines[#lines + 1] = string.format(
			"Vendor standing: %s (%s) // items it lists: %d",
			plainReaction and tostring(reaction) or "(secret)",
			plainReaction and tostring(ns.GetStandingLabel(reaction)) or "(secret)",
			GetMerchantNumItems() or 0
		)
	end
	local reagents, reagentOrder = {}, {}
	if ns.restockerLoaded and list then
		reagentOrder = ns.BuildCraftingPurchaseOrder()
		for reagentID, count in pairs(reagentOrder) do
			if count > 0 then
				reagents[#reagents + 1] = string.format("%s x%d", ItemText(reagentID), count)
			end
		end
		table.sort(reagents)
	end
	lines[#lines + 1] = string.format(
		"Reagents the list's crafts need now: %s",
		#reagents > 0 and table.concat(reagents, ", ") or "(none)"
	)

	-- The buy loop passes over a slot sold out, not purchasable, or costing more than gold.
	if ns.merchantIsOpen then
		local sold, stocked = {}, {}
		for index = 1, GetMerchantNumItems() or 0 do
			local itemID = ns.GetMerchantItemID(index)
				or tonumber((GetMerchantItemLink(index) or ""):match("item:(%d+)"))
			if itemID and ((list and list[itemID]) or (reagentOrder[itemID] or 0) > 0) then
				local _, _, _, _, available, purchasable, _, extendedCost = ns.GetMerchantItemInfo(index)
				sold[#sold + 1] = string.format(
					"%s (stock %s, purchasable %s, extra cost %s)",
					ItemText(itemID),
					tostring(available),
					YesNo(purchasable),
					YesNo(extendedCost)
				)
				if purchasable and not extendedCost and available ~= 0 then
					stocked[itemID] = true
				end
			end
		end
		table.sort(sold)
		lines[#lines + 1] = string.format(
			"List items and reagents this vendor sells: %s",
			#sold > 0 and table.concat(sold, ", ") or "(none)"
		)
		local missingReagents = 0
		for reagentID, count in pairs(reagentOrder) do
			if count > 0 and not stocked[reagentID] then
				missingReagents = missingReagents + 1
			end
		end
		lines[#lines + 1] = string.format(
			"Vendor stocks every needed reagent: %s",
			#reagents == 0 and "(none needed)" or YesNo(missingReagents == 0)
		)
	end

	-- Forever's tab list can be empty as the bank opens, so a run holding none asks again every step.
	if ns.bankIsOpen and list then
		local bankBags = ns.BankBagIDs()
		lines[#lines + 1] = string.format(
			"Bank containers: %s via %s // loaded for the run: %d // bank has a free plain slot: %s // a list item is locked: %s",
			table.concat(bankBags, ","),
			ns.FetchPurchasedBankTabIDs() and "C_Bank tabs" or "BANK_CONTAINER and bank bags",
			#ns.GetRestockBankBags(),
			YesNo(ns.BankHasRestockSpace()),
			YesNo(ns.IsRestockItemLocked(list))
		)
		lines[#lines + 1] =
			string.format("List items in the bank without a link yet: %d", UnlinkedListSlots(bankBags, list))
		local function OnList(itemID)
			return list[itemID] ~= nil
		end
		local inBags = ns.GetRestockItemsInBags(OnList).summary
		local inBank = ns.GetRestockItemsInBank(OnList).summary
		local canTake, canStore = 0, 0
		for itemID, row in pairs(list) do
			if type(row) == "table" then
				local wanted, bagCount = row.amount or 0, inBags[itemID] or 0
				if row.restockFromBank and wanted > bagCount and (inBank[itemID] or 0) > 0 then
					canTake = canTake + 1
				end
				if row.stashToBank and bagCount > wanted then
					canStore = canStore + 1
				end
			end
		end
		-- A run waits out an item on the cursor that is not on the list.
		local cursorType, cursorID = GetCursorInfo()
		lines[#lines + 1] = string.format(
			"Take rows the bank can fill now: %d // Store rows above Keep now: %d // on the cursor: %s",
			canTake,
			canStore,
			CursorHasItem() and string.format("%s %s", tostring(cursorType), tostring(cursorID)) or "(nothing)"
		)
	end
	-- One move per step: three round trips of the slower connection, never under 0.14s.
	local _, _, latencyHome, latencyWorld = GetNetStats()
	lines[#lines + 1] = string.format(
		"Bank trace in the Event Log: %s // latency home %s ms, world %s ms // a bank step every %.2fs",
		OnOff(ns.diagnostics and ns.diagnostics.logging),
		tostring(latencyHome),
		tostring(latencyWorld),
		math.max(0.140, math.max(latencyHome or 0, latencyWorld or 0) * 3 / 1000)
	)

	lines[#lines + 1] = string.format(
		"Town reminder: chat %s, sound %s, %s // resting: %s, on a flight: %s",
		OnOff(settings.restockReminderChat),
		OnOff(settings.restockReminderSound),
		tostring(settings.restockReminderMode),
		YesNo(IsResting()),
		YesNo(UnitOnTaxi("player"))
	)
	-- A file added to the TOC loads only after a restart, not a /reload.
	local handlers = ns.restockerEventHandlers or {}
	lines[#lines + 1] = string.format(
		"Town reminder file loaded: %s // handlers for walking in: %s, landing: %s, loading screens: %s",
		YesNo(ns.OnRestockerArrival),
		YesNo(handlers.PLAYER_UPDATE_RESTING),
		YesNo(handlers.PLAYER_CONTROL_GAINED),
		YesNo(handlers.PLAYER_ENTERING_WORLD)
	)
	-- The reminder sound plays on the Master channel.
	lines[#lines + 1] = string.format(
		"Sound CVars: Sound_EnableAllSound %s, Sound_MasterVolume %s, Sound_EnableSoundWhenGameIsInBG %s // alert sound file set: %s",
		tostring(GetCVar("Sound_EnableAllSound")),
		tostring(GetCVar("Sound_MasterVolume")),
		tostring(GetCVar("Sound_EnableSoundWhenGameIsInBG")),
		YesNo(ns.RESTOCK_ALERT_SOUND)
	)
	lines[#lines + 1] = string.format(
		"Merchant reminder: %s, %s // auto-open at merchant: %s",
		OnOff(settings.merchantReminder),
		tostring(settings.merchantReminderMode),
		OnOff(settings.autoOpenAtMerchant)
	)
	lines[#lines + 1] = string.format(
		"Bank reminder: %s, %s // auto-open at bank: %s",
		OnOff(settings.bankReminder),
		tostring(settings.bankReminderMode),
		OnOff(settings.autoOpenAtBank)
	)
	lines[#lines + 1] = string.format(
		"Reminders call a row low under: %s%% // moved onto Simple: %s",
		tostring(settings.restockLowThreshold),
		YesNo(settings.remindersMovedOntoSimple)
	)
	-- With both counts 0 no reminder prints.
	local shortRows = ShortRows(list)
	local out, low = ns.SplitRestockShortfall(shortRows, settings.restockLowThreshold)
	lines[#lines + 1] = string.format(
		"A reminder now would name: %d out, %d low // short but at or above the low line, never named: %d",
		#out,
		#low,
		#shortRows - #out - #low
	)
	lines[#lines + 1] = string.format(
		"Window open: %s // opened by a visit: %s // level: %d",
		YesNo(ns.restockWindow and ns.restockWindow:IsShown()),
		YesNo(ns.restockWindowOpenedByVisit),
		UnitLevel("player") or 0
	)
	-- A filter or a picked group can hide every row.
	lines[#lines + 1] = string.format(
		"Filter: %q // group: %s // rows shown: %d",
		tostring(ns.restockListFilter or ""),
		tostring(ns.restockSelectedGroup),
		ns.GetRestockShownItems and #ns.GetRestockShownItems() or 0
	)
	local position = settings.framePosition
	if type(position) == "table" then
		lines[#lines + 1] = string.format(
			"Window saved at: %s %s %s,%s size %sx%s",
			tostring(position.point),
			tostring(position.relativePoint),
			tostring(position.xOffset),
			tostring(position.yOffset),
			tostring(position.width),
			tostring(position.height)
		)
	end
	if ns.restockerLoaded and settings.currentList then
		local users = ns.GetRestockListUsers(settings.currentList)
		local names = {}
		for _, user in ipairs(users or {}) do
			names[#names + 1] = type(user) == "table" and tostring(user.name or user.key) or tostring(user)
		end
		lines[#lines + 1] = "Characters on this list: " .. (#names > 0 and table.concat(names, ", ") or "(none)")
	end

	-- The staples offer opens once, on a fresh login (never a /reload), only when every gate below passes.
	local classToken = select(2, UnitClass("player"))
	local offered, preTicked = 0, 0
	if ns.restockerLoaded then
		for _, category in ipairs(ns.GetStarterCategories()) do
			if ns.IsStarterCategoryForClass(category) and ns.IsStarterCategoryAvailable(category) then
				offered = offered + 1
				local defaultFor = category.defaultFor
				if defaultFor == "all" or (type(defaultFor) == "table" and defaultFor[classToken]) then
					preTicked = preTicked + 1
				end
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Staples offer: legacy import pending %s // level %d (needs 6) // list exists %s, empty %s // class %s, staples offered %d // in combat %s",
		YesNo(ns.IsLegacyImportPending and ns.IsLegacyImportPending()),
		UnitLevel("player") or 0,
		YesNo(list),
		YesNo(ns.restockerLoaded and ns.IsRestockListEmpty()),
		tostring(classToken),
		offered,
		YesNo(InCombatLockdown())
	)
	-- A staple whose ladder this client's folder lacks is dropped at load.
	lines[#lines + 1] = string.format(
		"Staples on this client: %d of %d // pre-ticked for this class: %d",
		#ns.GetStarterCategories(),
		#(ns.STARTER_LIST_CATEGORIES or {}),
		preTicked
	)
	lines[#lines + 1] = string.format(
		"Staples window: built this session %s // open now %s",
		YesNo(_G.GoodToGoStaplesFrame),
		YesNo(FrameShown("GoodToGoStaplesFrame"))
	)

	-- /restock profile use, delete and copy do nothing for a name not saved here.
	local listNames = {}
	for name in pairs(lists) do
		listNames[#listNames + 1] = tostring(name)
	end
	table.sort(listNames)
	lines[#lines + 1] = "List names: " .. (#listNames > 0 and table.concat(listNames, ", ") or "(none)")
	-- Another add-on registering /restock can take the command over.
	local claimants = {}
	for key, value in pairs(_G) do
		if
			type(key) == "string"
			and string.sub(key, 1, 6) == "SLASH_"
			and key ~= "SLASH_GOODTOGORESTOCK1"
			and type(value) == "string"
			and string.lower(value) == "/restock"
		then
			claimants[#claimants + 1] = key
		end
	end
	table.sort(claimants)
	-- The chat box runs whatever its command cache holds, filled the first time a slash command is typed.
	local slashCache = _G.hash_SlashCmdList
	local cached = type(slashCache) == "table" and slashCache["/RESTOCK"] or nil
	lines[#lines + 1] = string.format(
		"/restock registered: %s // other add-ons claiming /restock: %s // the chat box runs ours: %s",
		YesNo(_G.SLASH_GOODTOGORESTOCK1 == "/restock" and type(SlashCmdList.GOODTOGORESTOCK) == "function"),
		#claimants > 0 and table.concat(claimants, ", ") or "(none)",
		cached == nil and "(not cached yet)" or YesNo(cached == SlashCmdList.GOODTOGORESTOCK)
	)

	local short = {}
	for _, entry in ipairs(shortRows) do
		if entry.buys then
			short[#short + 1] = string.format("%s %d/%d", ItemText(entry.itemID), entry.have, entry.wanted)
		end
	end
	lines[#lines + 1] =
		string.format("Short now (a merchant would buy): %s", #short > 0 and table.concat(short, ", ") or "(nothing)")

	local inventory = global.inventory or {}
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Inventory Report --"
	lines[#lines + 1] = string.format(
		"Inventory Report switch: %s // feature loaded: %s",
		OnOff(global.inventoryReport),
		YesNo(ns.InitializeInventoryReport)
	)
	-- The same test ns.AddItemTooltipPostCall makes. The hooks go on a few seconds after login.
	lines[#lines + 1] = string.format(
		"Tooltip route: %s (GameTooltip and ItemRefTooltip only) // GameTooltip forbidden now: %s",
		(TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType)
				and "TooltipDataProcessor post-call"
			or "OnTooltipSetItem",
		YesNo(type(GameTooltip.IsForbidden) == "function" and GameTooltip:IsForbidden())
	)
	lines[#lines + 1] = string.format(
		"Record bound this session: %s // bank items held this session: %d",
		YesNo(ns.GetInventoryRecord and ns.GetInventoryRecord()),
		CountKeys(ns.GetInventoryBankCounts and ns.GetInventoryBankCounts() or nil)
	)
	local sampleID
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID then
				sampleID = info.itemID
				break
			end
		end
		if sampleID then
			break
		end
	end
	local sampleLines = sampleID and ns.GetInventoryReportLines and ns.GetInventoryReportLines(sampleID)
	lines[#lines + 1] = string.format(
		"Tooltip block for %s: %s",
		ItemText(sampleID),
		sampleLines and string.format("%d lines", #sampleLines) or "none"
	)
	-- Only this realm's characters are listed; a bank never opened counts as 0.
	local realm = GetRealmName()
	local onRealm = 0
	for _, entry in pairs(inventory) do
		if entry.realm == realm and entry.name then
			onRealm = onRealm + 1
		end
	end
	local own = inventory[characterKey]
	lines[#lines + 1] = string.format(
		"This character recorded: %s (%s) // bags saved: %s // bank saved by an earlier session: %s",
		YesNo(own),
		characterKey,
		YesNo(own and own.bags),
		YesNo(own and own.bank)
	)
	lines[#lines + 1] = string.format("Characters recorded: %d // on this realm: %d", CountKeys(inventory), onRealm)
	-- A secret GUID skips both login checks (rename, deleted namesake).
	local guid = UnitGUID("player")
	local guidReadable = guid ~= nil and ns.IsPlain(guid)
	local sharing = 0
	if guidReadable then
		for key, entry in pairs(inventory) do
			if key ~= characterKey and type(entry) == "table" and entry.guid == guid then
				sharing = sharing + 1
			end
		end
	end
	lines[#lines + 1] = string.format(
		"GUID readable: %s // this record's GUID matches: %s // other records with this GUID: %d",
		YesNo(guidReadable),
		(not guidReadable or not (own and own.guid)) and "(not compared)" or YesNo(own.guid == guid),
		sharing
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Account --"
	lines[#lines + 1] = string.format(
		"Welcome message: %s // Macro names on buttons: %s // Readiness Report: %s",
		OnOff(global.showWelcome),
		OnOff(global.showMacroNames),
		OnOff(global.readinessReportEnabled)
	)
	return (table.concat(lines, "\n"):gsub("|", "||"))
end
