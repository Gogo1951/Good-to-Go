local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Header
--------------------------------------------------------------------------------

-- Bindings.xml names this global as every binding's category, giving Good to Go its own section.
BINDING_HEADER_GOODTOGO = L["ADDON_TITLE"]

--------------------------------------------------------------------------------
-- Opening Key Bindings
--------------------------------------------------------------------------------

--[[
	The clients disagree on how the Key Bindings list is reached, so each route
	is tried in turn at click time, not load: a Settings category can register
	after login. The Diagnostic Tools API report has a row per route.
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

-- The client's own label, so the fallback line matches what the player sees in every locale.
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
	Heard whatever features are on: the root panel's rows show every binding's
	key. Buff Duty redraws too: its Cast Next Buff tip shows only while that
	key is unbound.
]]
local function OnUpdateBindings()
	ns.RefreshSettings()
	ns.RequestBuffDutyRefresh()
end

ns.RegisterEventModule(MODULE, function(event)
	if event == "UPDATE_BINDINGS" then
		OnUpdateBindings()
	end
end)

ns.SetModuleEvent(MODULE, "UPDATE_BINDINGS", true)
