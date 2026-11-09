local _, ns = ...

--[[
    Inventory Report -- the block item tooltips gain under the game's own lines:
    the total across every character on the realm, this character on top, then
    one line per other character holding some, each with its bags and bank
    apart.

        GtG // Inventory Report                 Total 82
         Gogodruid                         Bag 7, Bank 18

         Coinpurse                                Bank 30
         Thornhoof                          Bag 7, Bank 20

    The shape is the house one for a branded block: the add-on's short name, the
    separator and a title in the chat prints' own colors (Announcements.lua),
    then double lines, each a space in from the header so the rows read as the
    block's own. The total rides on the header's right, so the block costs one
    line per character and one spacer, and every name wears its class color.

    Two halves. The recording half, this file, keeps a snapshot of every character's bags
    and bank on ns.db.global.inventory, so an alt's counts can show while it is
    logged out. Both are read while the character is playing -- the bags
    whenever they change, the bank whenever its window is open, which is the
    only time an add-on can read it -- and written down at logout. The
    reporting half adds the lines.

    Snapshots, then, for everything but the current character's bags, which are
    read live: an alt's counts are as of its last logout, and a bank's as of its
    last visit. A bank not seen yet, this character's or an alt's, counts as 0
    until it has been opened once.

    Only characters on the current realm are listed, and only those holding the
    item. Items cannot be mailed across realms, so a count there answers nothing
    the player can act on from here.

    Switched off from the Inventory Report panel (ns.db.global.inventoryReport):
    most auction add-ons put their own
    counts on the same tooltips, and two sets of numbers under one item is
    noise.
]]

-- The bank's contents can still be arriving when BANKFRAME_OPENED fires; one late look catches them.
local BANK_SETTLE_DELAY = 0.5

--------------------------------------------------------------------------------
-- Saved Format
--------------------------------------------------------------------------------

--[[
    One saved line per character per place: "itemID:count" pairs, space
    separated and in itemID order. WoW's serializer spreads a table over a line
    per key, and a character's bank can hold a few hundred different items, so
    this keeps the file to one short line each -- the same habit the Restock
    List keeps for its rows (Restocker-Saved-Format.lua).
]]
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

-- The bags the player carries, Forever's reagent bag included (ns.CARRIED_BAG_IDS in Utilities).
local function PlayerBagIDs()
	return ns.CARRIED_BAG_IDS
end

-- The bank's containers, the same list the Restocker reads (ns.BankBagIDs in Restocker-Bags.lua).
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

-- This character's saved entry, bound at login.
local record

--[[
    This character's bags as last read, which is what a logout saves. They are
    read while the character is playing -- on arriving in the world, and at
    every change after that -- and never at the logout itself: on Forever a
    read made at PLAYER_LOGOUT can find nothing, which would save every
    character's bags as empty. nil until a read has been made, so a session that never
    saw its bags leaves the file's last snapshot alone.
]]
local bagCounts

-- A bag change arrived mid-fight; the read it asked for is owed when the fight ends.
local bagsChangedInCombat = false

--[[
    This character's bank: the last visit's snapshot at login, then each scan
    while the window is open. nil until the bank has been seen at all: the
    report counts that as 0, and a logout writes no bank line over it.
]]
local bankCounts

local bankIsOpen = false

--[[
    The backpack has slots whenever the bags can be read at all, so a backpack
    with none is the client not answering, and the last read stands. Bags that
    are empty still have their slots, and are recorded as empty.
]]
local function ScanBags()
	if (C_Container.GetContainerNumSlots(BACKPACK_CONTAINER) or 0) > 0 then
		bagCounts = CountItems(PlayerBagIDs())
	end
end

local function ScanBank()
	bankCounts = CountItems(BankBagIDs())
end

--[[
    Called by the Restocker's PLAYER_LOGIN branch (Restocker-Events.lua), after
    ns.InitializeRestocker.
    Name, realm and class are refreshed every login. A renamed or transferred
    character gets a new key, so its old record, found by the GUID a rename
    keeps, is dropped here; a record saved before the GUID was stored goes only
    once its character logs in under the old key again. The name is the whole
    one, a Forever character's surname included (ns.GetPlayerFullName in
    Utilities). A record under this key with another GUID belonged to a
    deleted character of the same name, so its bags and bank are dropped, and
    a bank this character hasn't seen yet counts as 0.

    The class is read by the Restock List as well, which colors the characters
    on a list by it (Features/Restocker/Restocker-Saved-Lists.lua).
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

	ns.HookInventoryReportTooltipsLater()
end

--[[
    The Inventory Report panel's switch. Off, the recorders stop hearing the bags
    (ns.SyncRestockerEvents); back on, the bags are read at once rather than at
    their next change.
]]
function ns.SetInventoryReportEnabled(value)
	ns.db.global.inventoryReport = value
	ns.SyncRestockerEvents()
	if value then
		ScanBags()
	end
end

--[[
    Drops another character's record, for the Inventory Report panel's Forget: its
    bags and bank leave every tooltip, and its Restock List choice goes with
    it, so its name stops reserving list names. Logging in on it records it
    again.
]]
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

--[[
    Handlers keyed by event name, read by the Restocker's dispatcher (Features/Restocker/Restocker-Events.lua),
    which has no combat guard: every one only reads containers or writes saved
    variables, and a logout mid-combat must still save this character's bags.
]]
ns.inventoryEventHandlers = {
	-- Login and every loading screen after it: the first read, for a session in which the bags never change.
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
	--[[
	    The client also fires this on loading screens with no bank open, which
	    is harmless here: the last scan simply stands.
	]]
	BANKFRAME_CLOSED = function()
		bankIsOpen = false
	end,
	--[[
	    Every change to the bags is read as it lands, so the snapshot is current
	    whenever the session ends. Not mid-fight: a hunter's every shot changes
	    the bags, so a fight's changes are read once, when it is over. A logout
	    taken mid-fight saves the bags as they were when it began.

	    While the bank is open, every move in or out of it -- the Restocker's own
	    or the player's -- lands here too, so the bank's snapshot ends the visit
	    current.
	]]
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
	-- Writes down what was last read: nothing is asked of the client here (see bagCounts).
	PLAYER_LOGOUT = function()
		if not record then
			return
		end
		if bagCounts then
			record.bags = Pack(bagCounts)
		end
		if bankCounts then
			record.bank = Pack(bankCounts)
		end
	end,
}

-- This character's saved entry, its bank as last read, and the saved counts' format, for the tooltip half.
function ns.GetInventoryRecord()
	return record
end

function ns.GetInventoryBankCounts()
	return bankCounts
end

ns.UnpackInventoryCounts = Unpack
