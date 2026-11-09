local _, ns = ...

--[[
    The Restocker's lifecycle: its setup at login, its master switch, and the
    packing of the lists at logout. Restocker-Events.lua holds the event
    handlers and the dispatcher that calls these.
]]

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

ns.restockerLoaded = false

--[[
    A table from the first frame, so the options panel's guarded accessors index
    something rather than nil before login. ns.InitializeRestocker below replaces
    it with the real ns.db.global.restocker.
]]
ns.restockSettings = {}

--[[
    Called from the dispatcher's PLAYER_LOGIN branch (Restocker-Events.lua),
    after ns.db exists and before the Inventory Report, which reads the
    Restock Lists.
]]
function ns.InitializeRestocker()
	ns.restockerLoaded = false

	--[[
	    The subsystem's lists and settings live on ns.db.global.restocker: named
	    shopping lists keyed by itemID, shared by every character. Which list a
	    character uses is its own choice (listChoices on the same table), so a
	    Warrior and a Priest see separate lists. AceDB has already applied the
	    defaults from Data/Default-Settings.lua by this point, so nothing is
	    filled in by hand here.
	]]
	ns.restockSettings = ns.db.global.restocker
	-- MIGRATION (remove after 2026-12-08): the staples window's retired don't-show-again answers.
	ns.restockSettings.starterListDismissed = nil

	ns.restockRowPool = {}
	ns.restockCategoryRowPool = {} -- category pane rows
	ns.restockHiddenFrame = CreateFrame("Frame", nil, UIParent)
	ns.restockHiddenFrame:Hide()

	--[[
	    Unpack the one-line string entries into in-memory tables (and tolerate any tables
	    left by a crash or pasted in by hand).
	]]
	ns.InflateSavedRestockItems(ns.restockSettings)

	ns.InitializeCharacterRestockList()

	ns.PruneEmptyOrphanRestockLists(ns.restockSettings)
	--[[
	    (Re-packing into the one-line form happens in ns.OnRestockerLogout, which calls
	    ns.DeflateRestockItemsForSave just before WoW writes the SavedVariables file.)
	]]

	ns.InitializeRestockerEvents()

	--[[
	    The two modules with real one-time setup, called by name so it stays
	    plain which two they are.
	]]
	ns.InitializeRestockBagDefinitions()
	ns.SetupCraftingRecipes()

	if not ns.restockWindow then
		ns.CreateRestockWindow()
	end

	ns.restockerLoaded = true
end

--------------------------------------------------------------------------------
-- Logout
--------------------------------------------------------------------------------

function ns.OnRestockerLogout()
	-- Position and size together, the same call the drag and resize handlers use.
	ns.SaveRestockWindowGeometry()

	--[[
	    Pack items into the compact one-line-per-item form for the SavedVariables
	    file. Must be last: every list entry is a string from here to the end of the
	    session, so nothing may read one as a table after this runs.
	]]
	ns.DeflateRestockItemsForSave()
	-- The list in use is per session: each login picks it again from listChoices, so it is not saved.
	ns.restockSettings.currentList = nil
end

--------------------------------------------------------------------------------
-- Master Switch
--------------------------------------------------------------------------------

function ns.IsRestockerEnabled()
	return ns.db ~= nil and ns.db.global.restockerEnabled
end

--[[
    Off stops every part of the Restocker. A visit in progress ends here
    rather than at its _CLOSED event, which the switched-off handlers no longer
    see, so no flag is left saying a merchant or bank is open.
]]
function ns.SetRestockerEnabled(value)
	ns.db.global.restockerEnabled = value
	ns.SyncRestockerEvents()
	if value then
		-- What a loading screen would have done while the switched-off handlers slept.
		ns.ArmRestockerReminders()
		ns.UpgradeRestockList()
		return
	end
	ns.CloseStarterListPopup()
	ns.EndRestockBankVisit()
	ns.EndRestockMerchantVisit()
	ns.HideRestockWindow()
end
