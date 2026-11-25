local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

local format = string.format

--------------------------------------------------------------------------------
-- Mini-map Menu
--------------------------------------------------------------------------------

--[[
    The mini-map button's menu, drawn on the shared Menu Kit
    (Features/Menu-Kit.lua): the add-on's name, then Current Food, then a block
    for each thing a player flips mid-session (Buff Duty, the Restocker, the
    Enhanced Spellbook), each a gold title with where it stands on the right, a line
    saying what it does and a blue Toggle row. Then the class's macro notes
    behind a [Class] Macros flyout with the class's live items under it, this
    character's Ignore List, the More Features flyout, and Options last.

    Hovering the button opens it; it closes a moment after the cursor leaves
    the button, the menu and the flyout. A Left-Click holds it open, and a
    second Left-Click closes it. Every row is a plain click, so a controller's
    cursor reaches all of it. The button keeps one click of its own,
    Right-Click to ignore the current food, named in gray on the Ignore row's
    right side (Button Clicks, below). Every click, row or button, ends in
    ns.RefreshSettings, which redraws the open menu, every open options panel
    and the button's icon.

    The rules every add-on's menu follows (Style Guide → MINIMAP MENU):
      - Only what this character can use shows: a warrior gets no [Class]
        Macros row. The options panel still lists everything.
      - A Toggle row's tooltip is its Enable option's caption and description;
        a More Features row's is its switch's, and it asks before turning off
        wherever the switch does.
      - A list shows at most LIST_MAX rows, then a note saying how many more.
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

-- Escape closes it, as it does any game menu.
table.insert(UISpecialFrames, menu:GetName())

-- Every string the kit draws, localized, handed over once (Menu-Kit.lua → Text).
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

-- An option's caption and tooltip, drawn the way the options panel draws them.
local function OptionTooltip(name, desc)
	return function(tooltip)
		tooltip:SetText(name, 1, 0.82, 0, 1, true)
		if desc and desc ~= "" then
			tooltip:AddLine(desc, 1, 1, 1, true)
		end
	end
end

--[[
    An item row: the kit draws the icon and the name in its quality color, 4 in
    under its heading, with the count after the name when there is one, and
    shows the item's own tooltip on hover. right is its value or slot, which
    the kit draws light yellow unless rightColor says otherwise.
]]
local function ItemRow(itemID, right, count, rightColor)
	return { kind = "item", itemID = itemID, count = count, right = right, rightColor = rightColor }
end

-- The right side of a feature's title: On in green, Off in gray.
local function OnOff(enabled)
	if enabled then
		return L["MENU_ON"], "ON"
	end
	return L["MENU_OFF"], "MUTED"
end

-- A feature switch's saved value, through the options kit, which reads a dotted path ("buffWindow.enabled").
local function IsFeatureOn(feature)
	return ns.OptionsKit.Get(feature.store, feature.setting)() and true or false
end

-- Every row click and button click ends here: the menu, any open options page and the button's icon redraw.
local function AfterChange()
	ns.RefreshSettings()
end

-- A feature switch flipped from the menu, the same way its options switch flips it.
local function SetFeature(feature, value)
	if not feature.apply then
		ns.OptionsKit.Set(feature.store, feature.setting)(nil, value) -- Writes it, then refreshes
		return
	end
	feature.apply(value)
	AfterChange()
end

-- A More Features switch whose options toggle asks before turning off asks the same here, in the same words.
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

-- A feature switch flipped from the menu, More Features' rows and the Enhanced Spellbook's Toggle alike; on is where it stands now.
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

--[[
    Buff Duty on the class you're playing, the same per-class switch as the
    window's close button, so turning it off on a rogue leaves it up on a druid.
]]
local function ToggleBuffDuty()
	ns.SetBuffDutyForClass(not ns.IsBuffDutyOnForClass())
end

-- Every Ignore List edit changes what the macros use, so each says what it did in chat; none asks first.
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

-- What the Enhanced Spellbook's key binding does; opening a window closes the menu.
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

--[[
    An action row: blue. click is the button's kept click that does the same
    job ("RightButton"): the kit names it in gray on the row's right side, and
    ns.RunButtonClick runs the row it's on. Without one, its right side is
    empty.
]]
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

-- A Toggle row: the feature's switch, with no button click of its own.
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

-- The first LIST_MAX rows, then a note saying how many more there are.
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
    The class's macro notes, one section per macro: what each click does on
    the left, as a verb, and the click on the right in light yellow, as a
    value row draws it. These are clicks on the macro, not on this menu, so
    they sit here rather than in the main menu, as value rows with nothing to
    click. A block's how-to note stays off the menu
    (MINIMAP MENU: no how-to notes); its options page and the macro's Spellbook
    tooltip say it.
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

--[[
    More Features: every feature on the options' main page that isn't a block
    in the main menu, one On/Off row each, in the main page's order, with its
    switch's caption and description as the tooltip (ns.FEATURES,
    Options/Options-Feature-Switches.lua). The Enhanced Spellbook has a block
    in the main menu too, though its record isn't marked as one. A feature
    that gates on the character shows only where it applies.
]]
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

--[[
    Current Food leads, since the button's icon shows it: the food the Food
    macro eats, or the "no suitable food" line while nothing resolves (or the
    item cache is still cold), and Ignore while there is a food to ignore.
]]
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
    Buff Duty reads On or Off for the class you're playing, the same switch its
    Toggle flips. While it's on, its title opens the window's own Options
    flyout, as every feature's title opens its flyout, so the window's
    switches are reachable even while it has hidden itself with nothing to
    show; while it's off the title is a plain heading. Its Toggle's tooltip is
    the feature's Enable option, with a line saying it's this class's switch.
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
    The Restocker's orders, inside its own block while it's on: what the
    reminders would mention (ns.BuildRestockReminderLists), the out rows and
    then the low rows, so the menu and the entering-town reminder can never
    disagree. Each is the item and have/wanted, its name read even while the
    item cache is cold (ns.GetItemLabel). With nothing short at all it
    says so in green; with rows short but none under the threshold, or a list
    with no rows, a gray note says which. Returns whether any item was still
    loading.
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

--[[
    The Restocker, titled with the feature's name as the root panel's switch
    names it. Its Toggle row is the feature switch, with no click of its own;
    Open, while it's on, opens the Restock List window.
]]
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

--[[
    The Enhanced Spellbook: its name with On or Off on the right, a line saying
    what it's for, and its Toggle row, the feature switch, which asks before
    turning off as More Features' rows and its options switch do. While it's
    on, Open opens its window, as its key binding does.
]]
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

--[[
    [Class] Macros, in the class color, opens the flyout of the class's macro
    notes; under it, the items the class's own macros will use, each with what
    it is for on the right. A class with no notes, or a character who knows
    none of their spells yet, gets neither.
]]
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
    This character's own Ignore List, the one Right-Click adds to and Clear
    Ignore List empties; the Global list lives in the Ignore List panel.
    Sorted by name, each item in its quality color, and only while it holds
    something. A click on an item takes it off the list (MINIMAP MENU →
    Editable list), the delete icon showing on the right while it's hovered
    and its tooltip saying so under the item's own lines.
    Returns whether any item was still loading.
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

-- More Features, last before Options: its right side counts the flyout's switches, the On count green.
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
    The button's one kept click runs the main menu row whose `click` names it,
    the way the kit's own menus route a click (Menu-Kit.lua → HandleClick), so
    the click and its row can't disagree: Right-Click runs Ignore, while
    there's a food to ignore. Left-Click has no row: it falls through to
    ns.ShowMenu, which opens, holds or closes the menu (Minimap-Button.lua).
    Middle-Click and the Shift clicks have no job. True when the click did
    something.
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

--[[
    The flyout beside its title, its first row level with the title, on the
    side the menu opened toward. The title keeps its highlight while it's open.
]]
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

-- An item not yet in the client's cache draws as a placeholder; one redraw once it has had a moment to arrive.
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

-- Entering a title opens its flyout, and any other row closes it, the way any game submenu behaves.
menu.onEnterRow = function(_, entry)
	ns.OpenFlyout(entry and entry.submenu or nil)
end

--[[
    Hangs off the button's corner, away from the screen's edges: left of the
    button on the right half of the screen, below it on the top half. Decided
    once as the menu opens, so it never jumps while open.
]]
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
    Opens the menu from a launcher: the mini-map button or any LDB display's
    frame. how is "hover" or "click"; a click keeps it open a little longer
    once the cursor leaves, and a click on a launcher whose click already
    holds the menu closes it, as the kit's own menus do (Menu-Kit.lua →
    HandleClick). flyoutKey opens that title's flyout at once. A launcher
    already showing the menu keeps its place and its open flyout.
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

-- Redraws the menu in place while it is open; a no-op otherwise.
function ns.RefreshMenu()
	Render()
end

function ns.IsMenuShown()
	return menu:IsShown()
end

-- True for the menu, its flyout, and anything inside them.
function ns.IsMenuFrame(frame)
	return frame ~= nil and Kit.IsInside(frame, menu)
end
