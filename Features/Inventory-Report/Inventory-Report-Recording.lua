local _, ns = ...

--[[
        Inventory Report                            GtG
         Gogodruid                         7 Bag, 18 Bank
         Coinpurse                                30 Bank
         Thornhoof                          7 Bag, 20 Bank
         Total                                         82

    Snapshots for all but this character's bags, which are live. The bank can
    be read only while its window is open. Same realm only: items can't be
    mailed across realms. The switch exists because most auction add-ons put
    their own counts on the same tooltips.
]]

-- The bank's contents can still be arriving when BANKFRAME_OPENED fires; one late look catches them.
local BANK_SETTLE_DELAY = 0.5

--------------------------------------------------------------------------------
-- Saved Format
--------------------------------------------------------------------------------

-- One line per place: WoW's serializer gives a table a line per key, and a bank can hold hundreds of items.
local function Pack(counts)
	local itemIDs = {}
	for itemID in pairs(counts) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)

	local parts = {}
	for index, itemID in ipairs(itemIDs) do
		parts[index] = itemID .. ":" .. counts[itemID]
	end
	return table.concat(parts, " ")
end

local function Unpack(text)
	local counts = {}
	for itemID, count in string.gmatch(text or "", "(%d+):(%d+)") do
		counts[tonumber(itemID)] = tonumber(count)
	end
	return counts
end

--------------------------------------------------------------------------------
-- Containers
--------------------------------------------------------------------------------

local function PlayerBagIDs()
	return ns.CARRIED_BAG_IDS
end

local BankBagIDs = ns.BankBagIDs

local function CountItems(bagIDs)
	local counts = {}
	for _, bagID in ipairs(bagIDs) do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
			local info = C_Container.GetContainerItemInfo(bagID, slot)
			if info and info.itemID then
				counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 1)
			end
		end
	end
	return counts
end

--------------------------------------------------------------------------------
-- Recording
--------------------------------------------------------------------------------

local record

--[[
    What a logout saves, never read at the logout itself: on Forever a read at
    PLAYER_LOGOUT can find nothing and would save empty bags. Nil until read, so
    the last snapshot stands.
]]
local bagCounts

local bagsChangedInCombat = false

-- Nil until the bank has been seen: the report counts 0 and a logout writes no bank line.
local bankCounts

local bankIsOpen = false

-- A backpack with no slots is the client not answering, so the last read stands.
local function ScanBags()
	if (C_Container.GetContainerNumSlots(BACKPACK_CONTAINER) or 0) > 0 then
		bagCounts = CountItems(PlayerBagIDs())
	end
end

local function ScanBank()
	bankCounts = CountItems(BankBagIDs())
end

--[[
    On AceDB's OnDatabaseShutdown, not PLAYER_LOGOUT: AceDB's logout handler
    runs first and strips defaults, inventoryReport = true among them, so a
    PLAYER_LOGOUT handler would read the switch as off. This fires before the strip.
]]
local function SaveSnapshot()
	if not (record and ns.db.global.inventoryReport) then
		return
	end
	if bagCounts then
		record.bags = Pack(bagCounts)
	end
	if bankCounts then
		record.bank = Pack(bankCounts)
	end
end

-- RegisterCallback replaces an earlier one under the same owner, so a second login adds none.
local shutdownListener = {}

--[[
    A rename or transfer gets a new key; the GUID it keeps finds the old record
    to drop. This key with another GUID was a deleted namesake, so its bags and
    bank go.
]]
function ns.InitializeInventoryReport()
	local inventory = ns.db.global.inventory
	local key = ns.GetCharacterKey()
	record = inventory[key] or {}
	inventory[key] = record

	local _, classToken = UnitClass("player")
	record.name = ns.GetPlayerFullName()
	record.realm = GetRealmName()
	record.class = classToken

	local guid = UnitGUID("player")
	if guid and not ns.IsSecretValue(guid) then
		if record.guid and record.guid ~= guid then
			record.bags = nil
			record.bank = nil
		end
		record.guid = guid
		for otherKey, entry in pairs(inventory) do
			if otherKey ~= key and entry.guid == guid then
				inventory[otherKey] = nil
			end
		end
	end

	bagCounts = nil
	bagsChangedInCombat = false
	bankCounts = record.bank and Unpack(record.bank) or nil

	ns.db.RegisterCallback(shutdownListener, "OnDatabaseShutdown", SaveSnapshot)
	ns.HookInventoryReportTooltipsLater()
end

-- Back on, the bags are read at once rather than at their next change.
function ns.SetInventoryReportEnabled(value)
	ns.db.global.inventoryReport = value
	ns.SyncRestockerEvents()
	if value then
		ScanBags()
	end
end

-- Its Restock List choice goes too, so its name stops reserving list names.
function ns.ForgetRecordedCharacter(key)
	local inventory = ns.db.global.inventory
	local forgotten = inventory[key]
	if key == ns.GetCharacterKey() or type(forgotten) ~= "table" then
		return
	end
	inventory[key] = nil
	if forgotten.name and forgotten.realm then
		ns.db.global.restocker.listChoices[ns.ProfileNameForCharacter(forgotten.name, forgotten.realm)] = nil
	end
	ns.ResetInventoryReportOthers()
end

-- No combat guard needed: every handler only reads containers or writes saved variables.
ns.inventoryEventHandlers = {
	-- The first read, for a session in which the bags never change.
	PLAYER_ENTERING_WORLD = function()
		ScanBags()
	end,
	BANKFRAME_OPENED = function()
		bankIsOpen = true
		ScanBank()
		C_Timer.After(BANK_SETTLE_DELAY, function()
			if bankIsOpen then
				ScanBank()
			end
		end)
	end,
	-- Also fires on loading screens with no bank open; harmless, the last scan stands.
	BANKFRAME_CLOSED = function()
		bankIsOpen = false
	end,
	-- Not mid-fight: a hunter's every shot changes the bags, so a fight's changes are read once it ends.
	BAG_UPDATE_DELAYED = function()
		if InCombatLockdown() then
			bagsChangedInCombat = true
		else
			ScanBags()
		end
		if bankIsOpen then
			ScanBank()
		end
	end,
	PLAYER_REGEN_ENABLED = function()
		if bagsChangedInCombat then
			bagsChangedInCombat = false
			ScanBags()
		end
	end,
}

function ns.GetInventoryRecord()
	return record
end

function ns.GetInventoryBankCounts()
	return bankCounts
end

ns.UnpackInventoryCounts = Unpack
