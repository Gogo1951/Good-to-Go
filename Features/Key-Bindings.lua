local _, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
	The key bindings every feature shares: the header the game's Key Bindings list files Bindings.xml's
	bindings under, the route the General panel's Set Key buttons take to that list, and the repaint that keeps
	the panel's Key Bindings rows current. Each feature names its own binding beside its code.
]]

--------------------------------------------------------------------------------
-- Header
--------------------------------------------------------------------------------

-- Titles Good to Go's own section in the Key Bindings list: Bindings.xml names this global as every binding's category.
BINDING_HEADER_GOODTOGO = L["ADDON_TITLE"]

--------------------------------------------------------------------------------
-- Opening Key Bindings
--------------------------------------------------------------------------------

--[[
	The General panel's Set Key buttons. The clients disagree on how the game's Key Bindings list is reached,
	so the routes are tried in order, at click time rather than at load, since a Settings category can
	register after login:

	  1. Settings.KEYBINDINGS_CATEGORY_ID, where the client names it outright.
	  2. The Settings panel's own category list, searched for the category carrying the game's Key Bindings
	     title (KEY_BINDINGS, or SETTINGS_KEYBINDINGS_LABEL where that's the one in use).
	  3. The older standalone KeyBindingFrame, loaded on demand.

	When nothing works, a chat line says where to find the list by hand. The Diagnostic Tools API report has
	a row for each route, so a bug report says which one the client took.
]]
local function FindKeyBindingsCategoryID()
	if Settings and Settings.KEYBINDINGS_CATEGORY_ID then
		return Settings.KEYBINDINGS_CATEGORY_ID
	end

	if not (SettingsPanel and SettingsPanel.GetCategoryList) then
		return nil
	end

	local list = SettingsPanel:GetCategoryList()
	local categories = list and list.GetAllCategories and list:GetAllCategories()
	for _, category in ipairs(categories or {}) do
		local name = category.GetName and category:GetName()
		if name and (name == KEY_BINDINGS or name == SETTINGS_KEYBINDINGS_LABEL) and category.GetID then
			return category:GetID()
		end
	end
	return nil
end

--[[
	The fallback line names the menus by the client's own labels, so it matches what the player sees in every
	locale. All three clients label the list SETTINGS_KEYBINDINGS_LABEL; KEY_BINDINGS stands in where that is
	missing.
]]
local KEY_BINDINGS_LABEL = SETTINGS_KEYBINDINGS_LABEL ~= nil and SETTINGS_KEYBINDINGS_LABEL or KEY_BINDINGS

function ns:OpenKeyBindings()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_KEY_BINDINGS_IN_COMBAT"])
		return
	end

	local categoryId = FindKeyBindingsCategoryID()
	if categoryId and Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(categoryId)
		return
	end

	if not KeyBindingFrame and type(KeyBindingFrame_LoadUI) == "function" then
		KeyBindingFrame_LoadUI()
	end
	if type(KeyBindingFrame) == "table" and type(ShowUIPanel) == "function" then
		ShowUIPanel(KeyBindingFrame)
		return
	end

	ns:PrintMessage(L["KEY_BINDINGS_LOCATION"]:format(GAMEMENU_OPTIONS, KEY_BINDINGS_LABEL))
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local MODULE = "KeyBindings"

--[[
	UPDATE_BINDINGS. The root panel's Key Bindings rows show each binding's key or Not Bound, and the player
	changes it in the game's own Key Bindings list, so repaint the panel when they come back from it. Heard
	whatever features are on, since the rows show every binding. The Buff Duty window redraws too, since it
	shows a Buff Button tip only while that key is unbound (Buff-Duty-Frame.lua).
]]
local function OnUpdateBindings()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
	ns.RequestBuffDutyRefresh()
end

ns.RegisterEventModule(MODULE, function(event)
	if event == "UPDATE_BINDINGS" then
		OnUpdateBindings()
	end
end)

ns.SetModuleEvent(MODULE, "UPDATE_BINDINGS", true)
