local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Restock Lists
--------------------------------------------------------------------------------

--[[
    Account-wide, never AceDB profiles, so Reset Profile can't reach them. Each
    character's choice is its own, so two sharing a profile keep separate lists.
]]

--------------------------------------------------------------------------------
-- List Choices
--------------------------------------------------------------------------------

--[[
    Named as profileKeys names it. The client is asked first: AceDB's own key is
    a placeholder when the library loaded before the character was named.
]]
local function OwnCharacterKey()
	return ns.GetCharacterProfileName() or ns.db.keys.char
end

-- Nil before the first login has picked one.
function ns.GetChosenRestockList()
	return ns.db.global.restocker.listChoices[OwnCharacterKey()]
end

--------------------------------------------------------------------------------
-- Add List
--------------------------------------------------------------------------------

local IsListNameTaken

function ns.AddRestockList(newListName)
	local settings = ns.restockSettings

	-- Without this an existing list would be replaced by an empty one, past recovery.
	if IsListNameTaken(settings, newListName) then
		ns:PrintMessage(string.format(L["RESTOCKER_PROFILE_EXISTS"], newListName))
		return
	end

	settings.lists[newListName] = {}
	ns.UseRestockList(newListName)

	local menu = ns.restockWindow or ns.CreateRestockWindow()
	menu:Show()
	ns.UpdateRestockList()

	ns.UpdateRestockListWidgets()

	if ns.bankIsOpen then
		ns.StartRestockBankRun()
	end
end

--------------------------------------------------------------------------------
-- Default List Names
--------------------------------------------------------------------------------

--[[
    A new list is named for the class, which decides a shopping list. A list of
    that name is never joined: its owner's Staples picks and upgrades would write
    into it uninvited, so the name is numbered ("Warrior (2)").
]]

--[[
    A name another character still points at is taken too: that character
    remakes the list at login and would join a fresh list that took the name.
]]
function IsListNameTaken(settings, name)
	if settings.lists[name] ~= nil then
		return true
	end
	local ownKey = OwnCharacterKey()
	for characterKey, listName in pairs(settings.listChoices) do
		if characterKey ~= ownKey and listName == name then
			return true
		end
	end
	return false
end

local function FreeClassListName(settings)
	local className = UnitClass("player")
	local name = className
	local suffix = 2
	while IsListNameTaken(settings, name) do
		name = L["RESTOCKER_LIST_NAME_NUMBERED"]:format(className, suffix)
		suffix = suffix + 1
	end
	return name
end

--------------------------------------------------------------------------------
-- List Order
--------------------------------------------------------------------------------

-- The one A-to-Z order: "the top list" must be the same list to the menu and to a delete.
function ns.GetRestockListNames()
	local names = {}
	for name in pairs(ns.restockSettings.lists) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

--------------------------------------------------------------------------------
-- List Users
--------------------------------------------------------------------------------

--[[
    { key, name, class }, A to Z; class is nil when unrecorded. A deleted
    character stays listed, since nothing tells an add-on it is gone. This
    character is read from the client, and AceDB's placeholder key is skipped.
]]
function ns.GetRestockListUsers(listName, othersOnly)
	local users = {}
	local listChoices = ns.restockSettings.listChoices
	local ownKey = OwnCharacterKey()

	if not othersOnly and listChoices[ownKey] == listName then
		local _, classToken = UnitClass("player")
		users[1] = { key = ownKey, name = ns.GetPlayerFullName() or UNKNOWNOBJECT, class = classToken }
	end

	local ownRealm = GetRealmName()
	local classes = ns.GetClassesByProfileName()
	for characterKey, chosen in pairs(listChoices) do
		local name, realm = ns.SplitCharacterProfileName(characterKey)
		if name and characterKey ~= ownKey and characterKey ~= ns.db.keys.char and chosen == listName then
			if realm and realm ~= ownRealm then
				name = name .. "-" .. (realm:gsub("%s+", ""))
			end
			users[#users + 1] = { key = characterKey, name = name, class = classes[characterKey] }
		end
	end
	-- By the name shown; the key only settles two characters shown alike.
	table.sort(users, function(a, b)
		if a.name ~= b.name then
			return a.name < b.name
		end
		return a.key < b.key
	end)
	return users
end

--------------------------------------------------------------------------------
-- Delete List
--------------------------------------------------------------------------------

--[[
    The top remaining list, or nil for the last. The maintainer's ruling: a
    delete never makes a list while another exists, or deleting "Druid (2)" would
    make "Druid (3)". The top list can be another character's, so the confirm
    names it.
]]
function ns.GetRestockListAfterDelete(listName)
	for _, name in ipairs(ns.GetRestockListNames()) do
		if name ~= listName then
			return name
		end
	end
	return nil
end

function ns.DeleteRestockList(listName)
	local settings = ns.restockSettings
	if listName == nil or settings.lists[listName] == nil then
		return
	end
	-- For deleting another list, which ns.UseRestockList never sees.
	ns.ClearRestockNewItems()

	local wasCurrent = settings.currentList == listName
	local landing = ns.GetRestockListAfterDelete(listName)
	settings.lists[listName] = nil

	if wasCurrent then
		if not landing then
			-- Named after the old name is freed, so an only "Druid" leaves an empty "Druid", not "Druid (2)".
			landing = FreeClassListName(settings)
			settings.lists[landing] = {}
		end
		--[[
		    Landed on, not picked: no rerun of the bank or merchant buy. A bank run
		    already going stops, since it rereads the list in use every step.
		]]
		ns.StopBankRestock()
		ns.UseRestockList(landing)
	end

	if not ns.restockWindow then
		ns.CreateRestockWindow()
	end
	ns.UpdateRestockListWidgets()
	ns.UpdateRestockList()
end

--------------------------------------------------------------------------------
-- List Widgets
--------------------------------------------------------------------------------

function ns.UpdateRestockListWidgets()
	if ns.restockWindow then
		ns.RefreshRestockListBar()
	end
end

--------------------------------------------------------------------------------
-- Rename List
--------------------------------------------------------------------------------

-- The list New List or Copy just made, with its rows as made, so a backed-out rename can tell if it was used.
local madeList

local function RememberMadeList(settings)
	local name = settings.currentList
	madeList = { name = name, rows = CopyTable(settings.lists[name]) }
end

local function SameValue(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	for key, value in pairs(a) do
		if not SameValue(value, b[key]) then
			return false
		end
	end
	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end
	return true
end

function ns.RenameCurrentRestockList(newName)
	local settings = ns.restockSettings
	local currentListName = settings.currentList

	newName = (newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if newName == "" or newName == currentListName then
		ns.UpdateRestockListWidgets()
		return
	end
	if IsListNameTaken(settings, newName) then
		ns:PrintMessage(string.format(L["RESTOCKER_PROFILE_EXISTS"], newName))
		ns.UpdateRestockListWidgets()
		return
	end

	madeList = nil
	settings.lists[newName] = settings.lists[currentListName]
	settings.lists[currentListName] = nil

	-- Otherwise their choice would dangle and remake an empty list under the old name.
	for characterKey, listName in pairs(settings.listChoices) do
		if listName == currentListName then
			settings.listChoices[characterKey] = newName
		end
	end

	ns.UseRestockList(newName)
	ns.UpdateRestockListWidgets()
	-- ns.UseRestockList cleared the New flags and undo, which stay drawn until a repaint.
	ns.UpdateRestockList()
end

-- The rename is told the list left behind, so Cancel can take the new one back.
function ns.CreateRestockList()
	local previousList = ns.restockSettings.currentList
	ns.AddRestockList(FreeClassListName(ns.restockSettings))
	RememberMadeList(ns.restockSettings)
	ns.BeginRestockListRename(previousList)
end

function ns.CloneCurrentRestockList()
	local settings = ns.restockSettings
	local sourceName = settings.currentList
	local source = sourceName and settings.lists[sourceName]
	if not source then
		return
	end

	local base = string.format(L["RESTOCKER_PROFILE_COPY_NAME"], sourceName)
	local name = base
	local suffix = 2
	while IsListNameTaken(settings, name) do
		name = L["RESTOCKER_LIST_NAME_COPY"]:format(base, suffix)
		suffix = suffix + 1
	end

	settings.lists[name] = CopyTable(source)
	ns.UseRestockList(name)

	local menu = ns.restockWindow or ns.CreateRestockWindow()
	menu:Show()
	ns.UpdateRestockList()
	ns.UpdateRestockListWidgets()
	RememberMadeList(settings)
	ns.BeginRestockListRename(sourceName)

	if ns.bankIsOpen then
		ns.StartRestockBankRun()
	end
end

--[[
    Escape or Cancel deletes the made list, unconfirmed, only while its rows are
    as made. Once used it stays: Escape is as likely meant for another window.
]]
function ns.DiscardMadeRestockList(previousList)
	local settings = ns.restockSettings
	local made = madeList
	madeList = nil
	local name = settings.currentList
	if not made or made.name ~= name or name == previousList or settings.lists[previousList] == nil then
		return
	end
	if not SameValue(settings.lists[name], made.rows) then
		return
	end
	settings.lists[name] = nil
	ns.SwitchRestockList(previousList)
end

--------------------------------------------------------------------------------
-- Change List
--------------------------------------------------------------------------------

function ns.SwitchRestockList(newListName)
	if newListName == nil or newListName == "" then
		return
	end
	-- A typed `/restock profile use` name can miss; pointing the character at no list breaks every list read.
	if ns.restockSettings.lists[newListName] == nil then
		return
	end
	ns.UseRestockList(newListName)

	ns.UpdateRestockListWidgets()
	ns.UpdateRestockList()

	if ns.bankIsOpen then
		ns.StartRestockBankRun()
	end

	--[[
	    After the last run's buys land, or it would buy them again. Not through
	    ns.OnRestockerMerchantShow, whose throttle and Shift check would swallow
	    the switch.
	]]
	if ns.merchantIsOpen and not ns.merchantBuyingSkipped then
		ns.AfterMerchantBuysLand(function()
			if ns.merchantIsOpen and not ns.merchantBuyingSkipped then
				ns.ResetMerchantRestockThrottle()
				ns.RestockFromMerchant()
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- Copy List
--------------------------------------------------------------------------------

function ns.CopyIntoCurrentRestockList(listToCopy)
	local settings = ns.restockSettings

	if listToCopy == nil or settings.lists[listToCopy] == nil then
		return
	end

	local copiedList = CopyTable(settings.lists[listToCopy])
	settings.lists[settings.currentList] = copiedList

	-- No ns.UseRestockList runs here to clear them.
	ns.ClearRestockNewItems()
	ns.UpdateRestockList()

	if ns.bankIsOpen then
		ns.StartRestockBankRun()
	end
end

--------------------------------------------------------------------------------
-- This Character's List
--------------------------------------------------------------------------------

--[[
    The only writer of currentList and the character's choice. Switching
    profiles leaves the list alone: a bank alt on its main's profile hasn't asked
    to share a list.
]]
function ns.UseRestockList(name)
	if name == nil or name == "" then
		return
	end
	--[[
	    Every list event passes here, a rename included. Each list opens on All at
	    the top: the last list's category and scroll say nothing about this one.
	]]
	ns.ClearRestockNewItems()
	ns.ClearRestockGroupSelection()
	local scrollFrame = ns.restockWindow and ns.restockWindow.scrollFrame
	if scrollFrame then
		scrollFrame:SetVerticalScroll(0)
	end
	local settings = ns.restockSettings
	settings.currentList = name
	settings.listChoices[OwnCharacterKey()] = name
end

--[[
    Only a character with no choice gets a class-named list. A missing chosen
    list is remade, since another character can delete it between logins.
]]
function ns.InitializeCharacterRestockList()
	local settings = ns.restockSettings
	local listName = ns.GetChosenRestockList() or FreeClassListName(settings)

	if settings.lists[listName] == nil then
		settings.lists[listName] = {}
	end
	ns.UseRestockList(listName)
end

-- Empty lists no character has chosen; the one in use is kept too.
function ns.PruneEmptyOrphanRestockLists(db)
	local keep = {}
	for _, listName in pairs(db.listChoices or {}) do
		keep[listName] = true
	end
	--[[
	    MIGRATION (remove after 2026-12-08): an empty legacy "Name-Realm" list
	    still named for a character AceDB knows is kept too -- older versions
	    made one per character, and a player who kept theirs must not lose it to
	    a prune. A leftover "default" list from those versions goes like any
	    other empty orphan.
	]]
	for profileKey in pairs(ns.db.sv.profileKeys or {}) do
		local name, realm = ns.SplitCharacterProfileName(profileKey)
		if name and realm then
			keep[name .. "-" .. (realm:gsub("%s+", ""))] = true
		end
	end
	if db.currentList then
		keep[db.currentList] = true
	end
	for name, list in pairs(db.lists or {}) do
		if not keep[name] and next(list) == nil then
			db.lists[name] = nil
		end
	end
end
