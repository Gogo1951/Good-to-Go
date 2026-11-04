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

--[[
    The Restocker's and the Inventory Report's own routes; the container,
    merchant, bank and tooltip calls they share with Connoisseur sit in
    Manifests-Macros-for-Consumables.lua.
]]
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
	-- The buy loop splits a purchase into stacks the vendor allows (Restocker-Merchant.lua).
	{
		"GetMerchantItemMaxStack",
		function()
			return type(GetMerchantItemMaxStack) == "function"
		end,
	},
	-- The Delete List confirm (Restocker-Window-List-Bar.lua).
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
	-- The window's templates; a missing unguarded one stops the window from being built.
	{ "InsetFrameTemplate3", HasTemplate("InsetFrameTemplate3") },
	{ "UIPanelScrollFrameTemplate", HasTemplate("UIPanelScrollFrameTemplate") },
	{ "InputBoxTemplate", HasTemplate("InputBoxTemplate") },
	{ "UICheckButtonTemplate", HasTemplate("UICheckButtonTemplate") },
	{ "SearchBoxTemplate (guarded)", HasTemplate("SearchBoxTemplate") },
	{ "WowStyle1DropdownTemplate (guarded)", HasTemplate("WowStyle1DropdownTemplate") },
})

--------------------------------------------------------------------------------
-- Restocker Context
--------------------------------------------------------------------------------

--[[
    The probe for "the Restocker did nothing" and "the tooltip shows no counts"
    reports: the switches, the list this character shops from, the gold and
    bag space a purchase needs, the windows open now, the open vendor's
    standing, the reagents the list's crafts need, the staples offer's gates,
    what a merchant would buy now, the reminders and their gates, and the
    Inventory Report's hook and records. Read-only.
]]
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

	--[[
	    The row switches each step skips on (Restocker-Merchant.lua,
	    Restocker-Bank-Visit.lua, Restocker-Upgrade.lua): Buy, Take and Store,
	    and Upgrade default on when unset; a row without an item ID can never
	    match a vendor slot; a row needing a standing waits for a vendor who
	    grants it.
	]]
	local buyOff, noID, takeOn, storeOn, upgradeOff, onLadder, unnamed = 0, 0, 0, 0, 0, 0, 0
	local needsStanding = {}
	for id, row in pairs(list or {}) do
		if type(row) == "table" then
			if row.buyFromMerchant == false then
				buyOff = buyOff + 1
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
		"Rows with Buy off: %d // without an item ID: %d // without a name yet: %d // Take from bank on: %d // Store in bank on: %d",
		buyOff,
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
	lines[#lines + 1] = string.format(
		"Waiting on item data: adds %d, rows %d, an upgrade %s, staples %s",
		CountKeys(ns.restockItemWait),
		CountKeys(ns.restockColdRows),
		YesNo(ns.HasPendingUpgrade and ns.HasPendingUpgrade()),
		YesNo(ns.HasPendingStarterAdds and ns.HasPendingStarterAdds())
	)

	-- Plain bags take anything; a specialty bag takes only its own kind (Restocker-Purchase-Space.lua).
	lines[#lines + 1] = string.format("Free bag slots: %d", FreeBagSlots())
	local bagLines = {}
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, family = C_Container.GetContainerNumFreeSlots(bag)
		if C_Container.GetContainerNumSlots(bag) > 0 then
			bagLines[#bagLines + 1] = string.format("%d: %d free, type %s", bag, slots or 0, tostring(family))
		end
	end
	lines[#lines + 1] = "Bags: " .. table.concat(bagLines, " // ")
	lines[#lines + 1] = string.format(
		"Merchant open: %s // buying skipped: %s // Bank open: %s",
		YesNo(ns.merchantIsOpen),
		YesNo(ns.merchantBuyingSkipped),
		YesNo(ns.bankIsOpen)
	)

	--[[
	    What the vendor itself decides (Restocker-Merchant.lua): a row needing a
	    better standing than this vendor's is skipped in silence, and a vendor
	    missing any reagent a craft needs sells none of them.
	]]
	if ns.merchantIsOpen then
		local reaction = UnitReaction("npc", "player") or UnitReaction("target", "player") or 0
		lines[#lines + 1] = string.format(
			"Vendor standing: %d (%s) // items it lists: %d",
			reaction,
			tostring(ns.GetStandingLabel(reaction)),
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

	--[[
	    Each slot of the open vendor that holds a list item or a needed
	    reagent, as the buy loop reads it: a slot sold out, not purchasable, or
	    costing more than gold is passed over, and the reagents sell all or
	    none.
	]]
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

	-- What the bank visit reads, while the bank is open (Restocker-Bags.lua).
	if ns.bankIsOpen and list then
		local bankBags = ns.BankBagIDs()
		lines[#lines + 1] = string.format(
			"Bank containers: %s via %s // bank has a free plain slot: %s // a list item is locked: %s",
			table.concat(bankBags, ","),
			ns.FetchPurchasedBankTabIDs() and "C_Bank tabs" or "BANK_CONTAINER and bank bags",
			YesNo(ns.BankHasRestockSpace()),
			YesNo(ns.IsRestockItemLocked(list))
		)
	end
	lines[#lines + 1] = "Bank trace in the Event Log: " .. OnOff(ns.diagnostics and ns.diagnostics.logging)

	lines[#lines + 1] = string.format(
		"Town reminder: chat %s, sound %s, %s // resting: %s, on a flight: %s",
		OnOff(settings.restockReminderChat),
		OnOff(settings.restockReminderSound),
		tostring(settings.restockReminderMode),
		YesNo(IsResting()),
		YesNo(UnitOnTaxi("player"))
	)
	-- The reminder sound plays on the Master channel (Restocker-Reminders.lua).
	lines[#lines + 1] = string.format(
		"Sound CVars: Sound_EnableAllSound %s, Sound_MasterVolume %s",
		tostring(GetCVar("Sound_EnableAllSound")),
		tostring(GetCVar("Sound_MasterVolume"))
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
		"Window open: %s // opened by a visit: %s // level: %d",
		YesNo(ns.restockWindow and ns.restockWindow:IsShown()),
		YesNo(ns.restockWindowOpenedByVisit),
		UnitLevel("player") or 0
	)
	-- A filter or a picked group can hide every row (Restocker-Window-Filter.lua, Restocker-Window-Categories.lua).
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

	--[[
	    The staples offer opens once, on a fresh login, only when every gate
	    below passes (Restocker-Starter-List.lua): no pending legacy import,
	    level 6 or above, an empty list, a staple offered, and out of combat.
	]]
	local offered = 0
	if ns.restockerLoaded then
		for _, category in ipairs(ns.GetStarterCategories()) do
			if ns.IsStarterCategoryForClass(category) and ns.IsStarterCategoryAvailable(category) then
				offered = offered + 1
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Staples offer: legacy import pending %s // level %d (needs 6) // list empty %s // staples offered %d // in combat %s",
		YesNo(ns.IsLegacyImportPending and ns.IsLegacyImportPending()),
		UnitLevel("player") or 0,
		YesNo(ns.restockerLoaded and ns.IsRestockListEmpty()),
		offered,
		YesNo(InCombatLockdown())
	)

	-- /restock profile use, delete and copy do nothing for a name not saved here.
	local listNames = {}
	for name in pairs(lists) do
		listNames[#listNames + 1] = tostring(name)
	end
	table.sort(listNames)
	lines[#lines + 1] = "List names: " .. (#listNames > 0 and table.concat(listNames, ", ") or "(none)")

	-- What a merchant visit would buy now (the rows short of their Keep amount with Buy on), with what the bags hold.
	local short = {}
	for _, entry in ipairs(ns.BuildGroceryList()) do
		short[#short + 1] =
			string.format("%s %d/%d", tostring(entry.itemName or entry.itemID), entry.have, entry.wanted)
	end
	lines[#lines + 1] =
		string.format("Short now (a merchant would buy): %s", #short > 0 and table.concat(short, ", ") or "(nothing)")

	--[[
	    The Inventory Report's files (Features/Inventory-Report/) are new in a
	    TOC, so a client updated while running reads them only after a restart:
	    until then the feature is absent.
	]]
	local inventory = global.inventory or {}
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Inventory Report --"
	lines[#lines + 1] = string.format(
		"Inventory Report switch: %s // feature loaded: %s",
		OnOff(global.inventoryReport),
		YesNo(ns.InitializeInventoryReport)
	)
	--[[
	    The route ns.AddItemTooltipPostCall picks (Features/Utilities.lua), the
	    same test it makes. The hooks go on a few seconds after login, and only
	    the game's own tooltip and the chat-link tooltip get the counts.
	]]
	lines[#lines + 1] = string.format(
		"Tooltip route: %s (GameTooltip and ItemRefTooltip only)",
		(TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType)
				and "TooltipDataProcessor post-call"
			or "OnTooltipSetItem"
	)
	lines[#lines + 1] = string.format(
		"Record bound this session: %s // bank items held this session: %d",
		YesNo(ns.GetInventoryRecord and ns.GetInventoryRecord()),
		CountKeys(ns.GetInventoryBankCounts and ns.GetInventoryBankCounts() or nil)
	)
	--[[
	    Only characters on this realm are listed, and a bank never opened yet
	    counts as 0 (Inventory-Report-Recording.lua).
	]]
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
