local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

local format = string.format

--------------------------------------------------------------------------------
-- Mini-map Menu
--------------------------------------------------------------------------------

--[[
    Every row is a plain click, so a controller's cursor reaches all of it.
    Only what this character can use shows (Style Guide → MINIMAP MENU); the
    options panel still lists everything.
]]

-- The kit's own timing (Menu-Kit.lua): this menu keeps its own state on the kit's panels, so it keeps a copy.
local HOVER_CLOSE_DELAY = 0.5
local CLICK_CLOSE_DELAY = 1.0
local SPELLBOOK_SETTING = "spellbookEnabled" -- A block of its own here, so it's left out of More Features
local MENU_GAP = 2 -- From the button's corner to the menu's
local LIST_MAX = 8
local LOADING_RETRY = 0.5 -- Seconds before redrawing rows whose items weren't cached yet

local menu = Kit.CreatePanel(ADDON_NAME .. "Menu", UIParent)
local flyout = Kit.CreatePanel(nil, menu)
flyout:SetFrameLevel(menu:GetFrameLevel() + 20)

table.insert(UISpecialFrames, menu:GetName())

Kit.SetText({
	on = L["MENU_ON"],
	off = L["MENU_OFF"],
	toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"],
	moreFeatures = L["MENU_MORE_FEATURES"],
	featuresOn = L["MENU_FEATURE_COUNT_ON"],
	featuresOff = L["MENU_FEATURE_COUNT_OFF"],
	count = L["ITEM_QUANTITY"],
	loading = L["LOADING_ITEM"],
	shortName = L["ADDON_SHORT_NAME"],
	clicks = { RightButton = L["MENU_CLICK_RIGHT"] },
})

local state = {
	anchor = nil,
	flyoutKey = nil,
	closeDelay = HOVER_CLOSE_DELAY,
	idle = 0,
	openLeft = true,
	openDown = true,
	retryPending = false,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function OptionTooltip(name, desc)
	return function(tooltip)
		tooltip:SetText(name, 1, 0.82, 0, 1, true)
		if desc and desc ~= "" then
			tooltip:AddLine(desc, 1, 1, 1, true)
		end
	end
end

local function ItemRow(itemID, right, count, rightColor)
	return { kind = "item", itemID = itemID, count = count, right = right, rightColor = rightColor }
end

local function OnOff(enabled)
	if enabled then
		return L["MENU_ON"], "ON"
	end
	return L["MENU_OFF"], "MUTED"
end

local function IsFeatureOn(feature)
	return ns.OptionsKit.Get(feature.store, feature.setting)() and true or false
end

local function AfterChange()
	ns.RefreshSettings()
end

local function SetFeature(feature, value)
	if not feature.apply then
		ns.OptionsKit.Set(feature.store, feature.setting)(nil, value) -- Writes it, then refreshes
		return
	end
	feature.apply(value)
	AfterChange()
end

-- Asks before turning off wherever the options switch does, in the same words.
StaticPopupDialogs.GOODTOGO_MENU_FEATURE_OFF = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(_self, feature)
		SetFeature(feature, false)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function FlipFeature(feature, on)
	if on and feature.confirm then
		StaticPopup_Show("GOODTOGO_MENU_FEATURE_OFF", L[feature.confirm], nil, feature)
		return
	end
	SetFeature(feature, not on)
end

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

-- The per-class switch, so turning it off on a rogue leaves it up on a druid.
local function ToggleBuffDuty()
	ns.SetBuffDutyForClass(not ns.IsBuffDutyOnForClass())
end

-- Each Ignore List edit changes what the macros use, so it says so in chat; none asks first.
local function IgnoreCurrentFood()
	local foodID = ns.bestFoodID
	if foodID and ns.IgnoreItem(foodID) then
		ns:PrintMessage(format(L["MESSAGE_IGNORE_ADDED"], ns.GetItemHyperlink(foodID)))
	end
end

local function UnignoreItem(itemID)
	if ns.UnignoreItem(itemID) then
		ns:PrintMessage(format(L["MESSAGE_IGNORE_REMOVED"], ns.GetItemHyperlink(itemID)))
	end
end

local function ClearIgnoreList()
	local cleared = ns.ClearIgnoreList()
	if cleared == 1 then
		ns:PrintMessage(L["MESSAGE_IGNORE_CLEARED_ONE"])
	elseif cleared > 1 then
		ns:PrintMessage(format(L["MESSAGE_IGNORE_CLEARED_MANY"], cleared))
	end
end

local function OpenSpellbook()
	ns.HideMenu()
	GoodToGo_ToggleSpellbook()
end

local function OpenOptions()
	ns.HideMenu()
	ns:OpenOptionsPanel()
end

-- The same as a bare /restock: while the Restocker is off it only says so in chat.
local function OpenRestockList()
	ns.ToggleRestockWindow()
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

-- click is the button's kept click that does the same job ("RightButton"); ns.RunButtonClick runs it.
local function ActionRow(label, run, tooltip, click)
	return {
		kind = "action",
		left = label,
		leftColor = "INFO",
		click = click,
		tooltip = tooltip,
		onClick = function()
			run()
			AfterChange()
		end,
	}
end

local function ToggleRow(flip, tooltip)
	return {
		kind = "action",
		left = L["MENU_TOGGLE"],
		leftColor = "INFO",
		tooltip = tooltip,
		onClick = function()
			flip()
			AfterChange()
		end,
	}
end

local function AddList(entries, rows)
	for index = 1, math.min(#rows, LIST_MAX) do
		entries[#entries + 1] = rows[index]
	end
	if #rows > LIST_MAX then
		entries[#entries + 1] = { kind = "note", left = format(L["MENU_MORE"], #rows - LIST_MAX) }
	end
end

--------------------------------------------------------------------------------
-- Flyouts
--------------------------------------------------------------------------------

-- Each flyout's rows by its submenu key; a submenu row opens the flyout its key names.
local FLYOUTS = {}

-- Buff Duty's title opens the window's own flyout (Buff-Duty-Options-Menu.lua) rather than one built here, so its submenus come with it.
local BUFF_DUTY_WINDOW = "buffDutyWindow"

--[[
    Clicks on the macro, not on this menu, so they sit here as value rows with
    nothing to click. How-to notes stay off the menu (MINIMAP MENU).
]]
function FLYOUTS.macros()
	local entries = {}
	local _, _, blocks = ns.GetClassMacroNotes()
	for _, block in ipairs(blocks or {}) do
		if block.rows then
			entries[#entries + 1] = { kind = "section", left = block.title }
			for _, row in ipairs(block.rows) do
				entries[#entries + 1] = { kind = "value", left = row[2], right = row[1] }
			end
		end
	end
	return entries
end

-- The Enhanced Spellbook has a block of its own, though its record isn't marked as one.
local function MoreFeatures()
	local features = {}
	for _, feature in ipairs(ns.FEATURES or {}) do
		local isBlock = feature.block or feature.setting == SPELLBOOK_SETTING
		if not isBlock and (not feature.gate or feature.gate()) then
			features[#features + 1] = feature
		end
	end
	return features
end

function FLYOUTS.features()
	local rows = {}
	for _, feature in ipairs(MoreFeatures()) do
		local on = IsFeatureOn(feature)
		rows[#rows + 1] = {
			kind = "toggle",
			left = L[feature.name],
			on = on,
			tooltip = OptionTooltip(L[feature.caption], L[feature.desc]),
			onClick = function()
				FlipFeature(feature, on)
			end,
		}
	end
	return rows
end

--------------------------------------------------------------------------------
-- Main Menu
--------------------------------------------------------------------------------

-- Leads, since the button's icon shows it.
local function AddCurrentFood(entries)
	entries[#entries + 1] = { kind = "status", left = L["MINIMAP_BEST_FOOD"] }
	local foodID, foodLink = ns.bestFoodID, ns.bestFoodLink
	if not (foodID and foodLink) then
		entries[#entries + 1] = { kind = "note", left = format(L["MESSAGE_NO_ITEM"], L["LABEL_FOOD"]) }
		return
	end
	entries[#entries + 1] = ItemRow(foodID, nil, C_Item.GetItemCount(foodID))
	entries[#entries + 1] = ActionRow(
		L["MENU_IGNORE"],
		IgnoreCurrentFood,
		OptionTooltip(L["MENU_IGNORE"], L["MENU_IGNORE_DESCRIPTION"]),
		"RightButton"
	)
end

--[[
    While on, its title opens the window's own Options flyout, so the window's
    switches are reachable even while it has hidden itself with nothing to show.
]]
local function AddBuffDuty(entries)
	local feature = ns.FindFeature("buffWindow.enabled")
	local enabled = ns.IsBuffDutyOnForClass() and true or false
	local paused = ns.IsBuffDutyHiddenThisSession()
	local right, rightColor = OnOff(enabled)
	if paused then
		right = L["MENU_BUFF_DUTY_PAUSED"]
	end
	entries[#entries + 1] = {
		kind = enabled and "submenu" or "status",
		left = L["TAB_BUFF_DUTY"],
		right = right,
		rightColor = rightColor,
		submenu = enabled and BUFF_DUTY_WINDOW or nil,
		onClick = enabled and function()
			ns.OpenFlyout(BUFF_DUTY_WINDOW)
		end or nil,
	}
	entries[#entries + 1] = { kind = "description", left = L["BUFF_DUTY_DESCRIPTION"] }
	if paused then
		entries[#entries + 1] = { kind = "note", left = L["MENU_BUFF_DUTY_PAUSED_NOTE"] }
	end
	local className = UnitClass("player")
	local tooltip = feature
		and OptionTooltip(L[feature.caption], format(L["MENU_BUFF_DUTY_TOGGLE_CLASS_DESCRIPTION"], className))
	entries[#entries + 1] = ToggleRow(ToggleBuffDuty, tooltip)
end

--[[
    The same lists as the reminders, so the menu and the entering-town
    reminder can never disagree. Returns whether any item was still loading.
]]
local function AddRestockOrders(entries)
	if ns.IsRestockListEmpty() then
		entries[#entries + 1] = { kind = "note", left = L["MINIMAP_RESTOCKER_EMPTY"] }
		return false
	end

	local out, low = ns.BuildRestockReminderLists()
	local rows, isLoading = {}, false
	for _, list in ipairs({ out, low }) do
		for _, entry in ipairs(list) do
			isLoading = isLoading or not C_Item.GetItemInfo(entry.itemID)
			rows[#rows + 1] = ItemRow(entry.itemID, format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted))
		end
	end

	if #rows > 0 then
		AddList(entries, rows)
	elseif #ns.BuildRestockShortfallList() == 0 then
		entries[#entries + 1] = { kind = "description", left = L["MINIMAP_RESTOCKER_STOCKED"], leftColor = "ON" }
	else
		entries[#entries + 1] = { kind = "note", left = L["MINIMAP_RESTOCKER_NOTHING_LOW"] }
	end
	return isLoading
end

local function AddRestocker(entries)
	local feature = ns.FindFeature("restockerEnabled")
	local enabled = ns.IsRestockerEnabled() and true or false
	local right, rightColor = OnOff(enabled)
	entries[#entries + 1] = { kind = "status", left = L[feature.name], right = right, rightColor = rightColor }
	entries[#entries + 1] = { kind = "description", left = L["MENU_RESTOCKER_DESCRIPTION"] }
	local isLoading = enabled and AddRestockOrders(entries)
	entries[#entries + 1] = ToggleRow(function()
		feature.apply(not enabled)
	end, OptionTooltip(L[feature.caption], L[feature.desc]))
	if enabled then
		entries[#entries + 1] = ActionRow(L["MENU_OPEN"], OpenRestockList)
	else
		-- Gray with nothing to click while the Restocker is off, so the list still has a way in that says why it's shut.
		local open = ActionRow(
			L["MENU_OPEN"],
			OpenRestockList,
			OptionTooltip(L["MENU_OPEN"], L["MENU_RESTOCKER_OPEN_OFF_DESCRIPTION"])
		)
		open.leftColor, open.onClick = "MUTED", nil
		entries[#entries + 1] = open
	end
	return isLoading
end

local function AddSpellbook(entries)
	local feature = ns.FindFeature(SPELLBOOK_SETTING)
	local enabled = ns.IsSpellbookEnabled() and true or false
	local right, rightColor = OnOff(enabled)
	entries[#entries + 1] =
		{ kind = "status", left = L["TAB_ENHANCED_SPELLBOOK"], right = right, rightColor = rightColor }
	entries[#entries + 1] = { kind = "description", left = L["MENU_SPELLBOOK_DESCRIPTION"] }
	entries[#entries + 1] = ToggleRow(function()
		FlipFeature(feature, enabled)
	end, OptionTooltip(L[feature.caption], L[feature.desc]))
	if enabled then
		entries[#entries + 1] = ActionRow(L["MENU_OPEN"], OpenSpellbook)
	end
end

-- A class with no notes, or a character who knows none of their spells yet, gets neither.
local function AddClassMacros(entries)
	local className, classToken, blocks = ns.GetClassMacroNotes()
	if not blocks then
		return
	end
	local hasNotes = false
	for _, block in ipairs(blocks) do
		hasNotes = hasNotes or block.rows ~= nil
	end
	local color = ns.GetClassColor(classToken) or ns.GetColor("TITLE")
	entries[#entries + 1] = {
		kind = hasNotes and "submenu" or "status",
		submenu = hasNotes and "macros" or nil,
		left = color .. format(L["MENU_CLASS_MACROS"], className) .. "|r",
		onClick = hasNotes and function()
			ns.OpenFlyout("macros")
		end or nil,
	}
	for _, block in ipairs(blocks) do
		if not block.rows and block.itemID and block.itemLink then
			entries[#entries + 1] = ItemRow(block.itemID, block.slot)
		end
	end
end

--[[
    This character's list only; the Global list lives in the Ignore List
    panel. Returns whether any item was still loading.
]]
local function AddIgnoreList(entries)
	local ignoreList = ns.GetIgnoreList()
	if not ignoreList or next(ignoreList) == nil then
		return false
	end

	local items, isLoading = {}, false
	for itemID in pairs(ignoreList) do
		local name = C_Item.GetItemInfo(itemID)
		items[#items + 1] = { id = itemID, name = name }
		isLoading = isLoading or not name
	end
	-- Loading items sort last, by ID, so the cached ones keep their places as the rest arrive.
	table.sort(items, function(a, b)
		if (a.name ~= nil) ~= (b.name ~= nil) then
			return a.name ~= nil
		end
		if a.name and a.name ~= b.name then
			return a.name < b.name
		end
		return a.id < b.id
	end)

	local rows = {}
	for _, item in ipairs(items) do
		local row = ItemRow(item.id, Kit.REMOVE_ICON, nil, "MUTED")
		local itemID = item.id
		row.rightOnHover = true
		row.tooltip = function(tooltip)
			tooltip:SetItemByID(itemID)
			tooltip:AddLine(" ")
			tooltip:AddLine(ns.GetColor("HELP") .. L["IGNORE_LIST_CLICK_HINT"] .. "|r")
		end
		row.onClick = function()
			UnignoreItem(itemID)
			AfterChange()
		end
		rows[#rows + 1] = row
	end

	entries[#entries + 1] = { kind = "status", left = L["MINIMAP_IGNORE_LIST"] }
	AddList(entries, rows)
	entries[#entries + 1] = ActionRow(L["MENU_CLEAR_IGNORE"], ClearIgnoreList)
	return isLoading
end

local function AddMoreFeatures(entries)
	local features = MoreFeatures()
	if #features == 0 then
		return
	end
	local on = 0
	for _, feature in ipairs(features) do
		if IsFeatureOn(feature) then
			on = on + 1
		end
	end
	local onText = ns.GetColor("ON") .. format(L["MENU_FEATURE_COUNT_ON"], on) .. "|r"
	local offText = format(L["MENU_FEATURE_COUNT_OFF"], #features - on)
	entries[#entries + 1] = {
		kind = "submenu",
		left = L["MENU_MORE_FEATURES"],
		right = onText .. ns.GetColor("TEXT") .. ",|r " .. offText,
		submenu = "features",
		onClick = function()
			ns.OpenFlyout("features")
		end,
	}
end

local function BuildMainEntries()
	local entries = {
		{ kind = "header", left = L["ADDON_TITLE"], right = ns.Version or "" },
		{ kind = "spacer" },
	}

	AddCurrentFood(entries)
	AddBuffDuty(entries)
	local restockLoading = AddRestocker(entries)
	AddSpellbook(entries)
	AddClassMacros(entries)
	local ignoreLoading = AddIgnoreList(entries)
	AddMoreFeatures(entries)

	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = ActionRow(L["MENU_OPTIONS"], OpenOptions)
	return entries, restockLoading or ignoreLoading
end

--------------------------------------------------------------------------------
-- Button Clicks
--------------------------------------------------------------------------------

--[[
    Runs the main menu row whose `click` names the button, so a click and its
    row can't disagree. True when the click did something.
]]
function ns.RunButtonClick(button)
	if not ns.db then
		return false
	end
	local key = (IsShiftKeyDown() and "Shift" or "") .. button
	for _, entry in ipairs((BuildMainEntries())) do
		if entry.click == key and entry.onClick and not entry.disabled then
			entry.onClick()
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Drawing & Placement
--------------------------------------------------------------------------------

-- On the side the menu opened toward; the title keeps its highlight while it's open.
local function PositionFlyout(row)
	flyout:ClearAllPoints()
	if state.openLeft then
		flyout:SetPoint("TOPRIGHT", row, "TOPLEFT", -Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	else
		flyout:SetPoint("TOPLEFT", row, "TOPRIGHT", Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	end
end

local function RenderFlyout()
	local key = state.flyoutKey
	local row = key and menu:SubmenuRow(key)
	if key == BUFF_DUTY_WINDOW and row then
		flyout:Hide()
		ns.ShowBuffDutyOptions(row)
		return
	end
	ns.HideBuffDutyOptions(menu)
	local builder = key and FLYOUTS[key]
	if not (row and builder) then
		state.flyoutKey = nil
		flyout:Hide()
		return
	end
	flyout.tooltipAnchor = menu.tooltipAnchor
	flyout:Render(builder())
	PositionFlyout(row)
	flyout:Show()
	row:LockHighlight()
end

local Render

-- Cold items draw as placeholders; one redraw once they have had a moment to arrive.
local function RetryLoading()
	state.retryPending = false
	Render()
end

function Render()
	if not menu:IsShown() or not ns.db then
		return
	end
	local entries, isLoading = BuildMainEntries()
	menu:Render(entries)
	RenderFlyout()
	if isLoading and not state.retryPending then
		state.retryPending = true
		C_Timer.After(LOADING_RETRY, RetryLoading)
	end
end

function ns.OpenFlyout(key)
	if key ~= state.flyoutKey then
		state.flyoutKey = key
		Render()
	end
end

menu.onEnterRow = function(_, entry)
	ns.OpenFlyout(entry and entry.submenu or nil)
end

-- Decided once as the menu opens, so it never jumps while open.
local function PositionMenu(anchor)
	local x, y = anchor:GetCenter()
	local scale = anchor:GetEffectiveScale() / UIParent:GetEffectiveScale()
	state.openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
	state.openDown = (y or 0) * scale > UIParent:GetHeight() / 2

	local point = (state.openDown and "TOP" or "BOTTOM") .. (state.openLeft and "RIGHT" or "LEFT")
	local relative = (state.openDown and "BOTTOM" or "TOP") .. (state.openLeft and "LEFT" or "RIGHT")
	menu:ClearAllPoints()
	menu:SetPoint(
		point,
		anchor,
		relative,
		state.openLeft and -MENU_GAP or MENU_GAP,
		state.openDown and -MENU_GAP or MENU_GAP
	)
	menu.tooltipAnchor = state.openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

-- Closes a moment after the cursor has left the button, the menu and the flyout (Buff Duty's too).
menu:SetScript("OnUpdate", function(self, elapsed)
	local anchor = state.anchor
	if not anchor or not anchor:IsVisible() then
		self:Hide()
		return
	end
	if
		Kit.IsCursorOver(anchor)
		or Kit.IsCursorOver(self)
		or Kit.IsCursorOver(flyout)
		or ns.IsCursorOverBuffDutyOptions()
	then
		state.idle = 0
		return
	end
	state.idle = state.idle + elapsed
	if state.idle >= state.closeDelay then
		self:Hide()
	end
end)

menu:SetScript("OnHide", function()
	state.flyoutKey = nil
	state.anchor = nil
	flyout:Hide()
	ns.HideBuffDutyOptions(menu)
	if ns.IsMenuFrame(GameTooltip:GetOwner()) then
		GameTooltip:Hide()
	end
end)

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--[[
    how is "hover" or "click": a click holds it longer, and a click on the
    launcher a click already holds it on closes it. A launcher already showing
    the menu keeps its place and open flyout.
]]
function ns.ShowMenu(anchor, flyoutKey, how)
	if not ns.db or not anchor then
		return
	end
	local reopen = menu:IsShown() and state.anchor == anchor
	if reopen and how == "click" and state.closeDelay == CLICK_CLOSE_DELAY then
		menu:Hide()
		return
	end
	if not reopen then
		state.closeDelay = HOVER_CLOSE_DELAY
		state.flyoutKey = nil
	end
	state.anchor = anchor
	state.idle = 0
	if how == "click" then
		state.closeDelay = CLICK_CLOSE_DELAY
	end
	if flyoutKey then
		state.flyoutKey = flyoutKey
	end
	if not reopen then
		PositionMenu(anchor)
	end
	menu:Show()
	Render()
end

function ns.HideMenu()
	menu:Hide()
end

function ns.RefreshMenu()
	Render()
end

function ns.IsMenuShown()
	return menu:IsShown()
end

function ns.IsMenuFrame(frame)
	return frame ~= nil and Kit.IsInside(frame, menu)
end
