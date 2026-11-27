local _, ns = ...

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

ns.restockerLoaded = false

-- A table until login, so the options panel's guarded accessors index something.
ns.restockSettings = {}

-- Runs before the Inventory Report, which reads the Restock Lists.
function ns.InitializeRestocker()
	ns.restockerLoaded = false

	ns.restockSettings = ns.db.global.restocker
	-- MIGRATION (remove after 2026-12-08): the staples window's retired don't-show-again answers.
	ns.restockSettings.starterListDismissed = nil

	ns.restockRowPool = {}
	ns.restockCategoryRowPool = {} -- category pane rows
	ns.restockHiddenFrame = CreateFrame("Frame", nil, UIParent)
	ns.restockHiddenFrame:Hide()

	ns.InflateSavedRestockItems(ns.restockSettings)

	ns.InitializeCharacterRestockList()

	ns.PruneEmptyOrphanRestockLists(ns.restockSettings)

	ns.InitializeRestockerEvents()

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
	-- The size only: the spot is saved when the window is dragged, so one never dragged keeps none.
	ns.SaveRestockWindowGeometry(true)

	-- Every list entry is a string from here on, so nothing after this may read one as a table.
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

-- Off ends a visit here: the switched-off handlers never see its _CLOSED, so the open flag would stick.
function ns.SetRestockerEnabled(value)
	ns.db.global.restockerEnabled = value
	ns.SyncRestockerEvents()
	if value then
		-- What a loading screen would have done while the switched-off handlers slept.
		-- MIGRATION (remove after 2026-12-13): absent after a /reload until a restart (Restocker-Town-Reminder.lua is new).
		if ns.ArmRestockerReminders then
			ns.ArmRestockerReminders()
		end
		ns.UpgradeRestockList()
		return
	end
	ns.CloseStarterListPopup()
	ns.EndRestockBankVisit()
	ns.EndRestockMerchantVisit()
	ns.HideRestockWindow()
end
