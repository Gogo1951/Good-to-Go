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
    for each thing a player flips mid-session (Buff Food & Scrolls, Buff Duty,
    the Restocker), each a gold title with where it stands on the right, a line
    saying what it does and a blue Toggle row. Then the class's macro notes
    behind a [Class] Macros flyout with the class's live items under it, this
    character's Ignore List, the More Features flyout, and Options last.

    Hovering the button opens it; it closes a moment after the cursor leaves
    the button, the menu and the flyout. Every row is a plain click, so a
    controller's cursor reaches all of it, and the button keeps its six clicks,
    each named on the row that does the same job (Button Clicks, below). Every
    click, row or button, ends in ns.RefreshSettings, which redraws the open
    menu, every open options panel and the button's icon.

    The rules every add-on's menu follows (Style Guide → MINIMAP MENU):
      - Only what this character can use shows: a warrior gets no [Class]
        Macros row. The options panel still lists everything.
      - A Toggle row's tooltip is its Enable option's caption and description;
        a More Features row's is its switch's, and it asks before turning off
        wherever the switch does.
      - A list shows at most LIST_MAX rows, then a note saying how many more.
]]

local HOVER_CLOSE_DELAY = 0.4
local CLICK_CLOSE_DELAY = 1.0
local MENU_GAP = 2 -- From the button's corner to the menu's
local LIST_MAX = 8
local LOADING_RETRY = 0.5 -- Seconds before redrawing rows whose items weren't cached yet

local menu = Kit.CreatePanel(ADDON_NAME .. "Menu", UIParent)
local flyout = Kit.CreatePanel(nil, menu)
flyout:SetFrameLevel(menu:GetFrameLevel() + 20)

-- Escape closes it, as it does any game menu.
table.insert(UISpecialFrames, menu:GetName())

Kit.SetToggleText(L["MENU_ON"], L["MENU_OFF"])

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

-- An item's own tooltip, as hovering it in the bags shows it.
local function ItemTooltip(itemID)
	if not itemID then
		return nil
	end
	return function(tooltip)
		tooltip:SetItemByID(itemID)
	end
end

-- An icon at line height, then the item's name.
local function ItemText(icon, label)
	return format("|T%s:0|t %s", icon or ns.QUESTION_MARK_ICON, label)
end

--[[
    An item row until Menu-Kit v2 brings the `item` kind: an action row with no
    click, so the kit puts no gap above it as it does above a heading, the icon
    and the colored name on its left and its value or slot on the right.
]]
local function ItemRow(left, right, rightColor, itemID)
	return {
		kind = "action",
		left = left,
		right = right,
		rightColor = rightColor,
		tooltip = ItemTooltip(itemID),
	}
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

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

--[[
    Buff Food and Scroll Buffs as one pair. Either one on turns both off, both
    off turns both on, so a click always lands them together; each keeps its
    own When to Use on the Macros page.
]]
local function ToggleBuffFoodAndScrolls()
	local settings = ns.db.profile
	local value = not (settings.useBuffFood or settings.useScrolls)
	ns.ToggleMacroSetting("useBuffFood", value)
	ns.ToggleMacroSetting("useScrolls", value)
end

--[[
    Buff Duty on the class you're playing, the same per-class switch as the
    window's close button, so turning it off on a rogue leaves it up on a druid.
]]
local function ToggleBuffDuty()
	ns.SetBuffDutyForClass(not ns.IsBuffDutyOnForClass())
end

-- Both Ignore List edits change what the macros use, so each says what it did in chat; neither asks first.
local function IgnoreCurrentFood()
	local foodID = ns.bestFoodID
	if foodID and ns.IgnoreItem(foodID) then
		ns:PrintMessage(format(L["MESSAGE_IGNORE_ADDED"], ns.GetItemHyperlink(foodID)))
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

--------------------------------------------------------------------------------
-- Button Clicks
--------------------------------------------------------------------------------

--[[
    One table, both ways: the button's OnClick looks the click up here, and the
    row that does the same job names the click on its right, so a row never
    names a click that does something else. All six clicks have a job, so
    hover alone opens the menu (Minimap-Button.lua).
]]
local CLICKS = {
	buffFood = {
		button = "LeftButton",
		shift = false,
		name = "MENU_CLICK_LEFT",
		run = ToggleBuffFoodAndScrolls,
	},
	ignore = {
		button = "RightButton",
		shift = false,
		name = "MENU_CLICK_RIGHT",
		run = IgnoreCurrentFood,
	},
	clearIgnore = {
		button = "MiddleButton",
		shift = false,
		name = "MENU_CLICK_MIDDLE",
		run = ClearIgnoreList,
	},
	buffDuty = {
		button = "LeftButton",
		shift = true,
		name = "MENU_CLICK_SHIFT_LEFT",
		run = ToggleBuffDuty,
	},
	restockList = {
		button = "RightButton",
		shift = true,
		name = "MENU_CLICK_SHIFT_RIGHT",
		-- The same as a bare /restock: while the Restocker is off it only says so in chat.
		run = function()
			ns.ToggleRestockWindow()
		end,
	},
	options = {
		button = "MiddleButton",
		shift = true,
		name = "MENU_CLICK_SHIFT_MIDDLE",
		run = function()
			ns.HideMenu()
			ns:OpenOptionsPanel()
		end,
	},
}

-- Runs the click's job and redraws the menu and any open options page; false when the click has none.
function ns.RunButtonClick(button)
	local shift = IsShiftKeyDown() and true or false
	for _, click in pairs(CLICKS) do
		if click.button == button and click.shift == shift then
			if not ns.db and click ~= CLICKS.options then
				return true
			end
			click.run()
			AfterChange()
			return true
		end
	end
	return false
end

-- An action row: blue, naming its button click on the right in gray.
local function ClickRow(label, clickKey, tooltip)
	local click = CLICKS[clickKey]
	return {
		kind = "action",
		left = label,
		leftColor = "INFO",
		right = L[click.name],
		rightColor = "MUTED",
		tooltip = tooltip,
		onClick = function()
			click.run()
			AfterChange()
		end,
	}
end

-- A Toggle row with no button click of its own: every click is already taken.
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

--[[
    The class's macro notes, one section per macro: what each click does on
    the left, as a verb, and the click on the right in gray, the same way round
    as an action row and its button click. These are clicks on the macro, not
    on this menu, so they sit here rather than in the main menu. A value row is
    an action row with no click until Menu-Kit v2 brings the `value` kind, so
    the kit puts no gap above each one as it does above a heading.
]]
function FLYOUTS.macros()
	local entries = {}
	local _, _, blocks = ns.GetClassMacroNotes()
	for _, block in ipairs(blocks or {}) do
		if block.rows then
			entries[#entries + 1] = { kind = "section", left = block.title }
			for _, row in ipairs(block.rows) do
				entries[#entries + 1] = {
					kind = "action",
					left = row[2],
					leftColor = "BODY",
					right = row[1],
					rightColor = "MUTED",
				}
			end
			if block.note then
				entries[#entries + 1] = { kind = "note", left = block.note }
			end
		end
	end
	return entries
end

--[[
    More Features: every feature on the options' main page that isn't a block
    in the main menu, one On/Off row each, in the main page's order, with its
    switch's caption and description as the tooltip (ns.FEATURES,
    Options/Options-Feature-Switches.lua). A feature that gates on the
    character shows only where it applies.
]]
local function MoreFeatures()
	local features = {}
	for _, feature in ipairs(ns.FEATURES or {}) do
		if not feature.block and (not feature.gate or feature.gate()) then
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
				if on and feature.confirm then
					StaticPopup_Show("GOODTOGO_MENU_FEATURE_OFF", L[feature.confirm], nil, feature)
					return
				end
				SetFeature(feature, not on)
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
		entries[#entries + 1] = { kind = "description", left = format(L["MESSAGE_NO_ITEM"], L["LABEL_FOOD"]) }
		return
	end
	entries[#entries + 1] =
		ItemRow(ItemText(C_Item.GetItemIconByID(foodID), ns.UnbracketItemLink(foodLink)), nil, nil, foodID)
	entries[#entries + 1] = ClickRow(L["MENU_IGNORE"], "ignore")
end

--[[
    What a switch that is on waits for while its When to Use does not hold:
    the level filter's label when that is what fails (When Leveling), and
    otherwise the contexts it is ticked for (Party, Raid), or Never with none.
]]
local function WaitingLabel(settings, prefix)
	if ns.IsGroupContextOn(settings[prefix .. "In"]) then
		return ns.LEVEL_FILTER_VALUES[settings[prefix .. "Level"]] or L["GROUP_CONTEXT_NEVER"]
	end
	local ticked = {}
	for _, context in ipairs(ns.GROUP_CONTEXTS) do
		if ns.IsGroupContextOn(settings[prefix .. "In"], context) then
			ticked[#ticked + 1] = L["GROUP_CONTEXT_" .. context:upper()]
		end
	end
	if #ticked == 0 then
		return L["GROUP_CONTEXT_NEVER"]
	end
	return table.concat(ticked, L["LIST_SEPARATOR"])
end

--[[
    Buff Food & Scrolls reads On while either switch is on and its When to Use
    holds, Off while both are off, and Paused while one is on but waiting
    (ticked for Raid only, and the player is solo): the Food macro isn't acting
    on it, and a note under the description says what it waits for. It stays
    live while Consumable Macros is switched off, the maintainer's choice:
    these are settings for when it is back on.
]]
local function AddBuffFoodAndScrolls(entries)
	local settings = ns.db.profile
	local right, rightColor = OnOff(false)
	local waiting
	for _, switch in ipairs({ { settings.useBuffFood, "buffFood" }, { settings.useScrolls, "scrolls" } }) do
		if switch[1] then
			if ns.IsUseWhenActive(settings, switch[2]) then
				right, rightColor, waiting = L["MENU_ON"], "ON", nil
				break
			end
			right, rightColor = L["MENU_PAUSED"], "MUTED"
			waiting = waiting or WaitingLabel(settings, switch[2])
		end
	end

	local wellFed = ns.GetWellFedName()
	entries[#entries + 1] =
		{ kind = "status", left = L["MINIMAP_BUFF_FOOD_SCROLLS"], right = right, rightColor = rightColor }
	entries[#entries + 1] =
		{ kind = "description", left = format(L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"], wellFed) }
	if waiting then
		entries[#entries + 1] = { kind = "note", left = format(L["MENU_WAITING_FOR"], waiting) }
	end
	-- Two switches answer to one click, so the tooltip names both, as the Macros page does.
	entries[#entries + 1] = ClickRow(L["MENU_TOGGLE"], "buffFood", function(tooltip)
		tooltip:SetText(L["OPTIONS_BUFF_FOOD"], 1, 0.82, 0, 1, true)
		tooltip:AddLine(format(L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"], wellFed), 1, 1, 1, true)
		tooltip:AddLine(" ")
		tooltip:AddLine(L["OPTIONS_USE_SCROLLS"], 1, 0.82, 0, true)
		tooltip:AddLine(L["OPTIONS_USE_SCROLLS_DESCRIPTION"], 1, 1, 1, true)
	end)
end

-- Buff Duty reads On or Off for the class you're playing, the same switch its click flips.
local function AddBuffDuty(entries)
	local feature = ns.FindFeature("buffWindow.enabled")
	local right, rightColor = OnOff(ns.IsBuffDutyOnForClass())
	entries[#entries + 1] = { kind = "status", left = L["TAB_BUFF_DUTY"], right = right, rightColor = rightColor }
	entries[#entries + 1] = { kind = "description", left = L["BUFF_DUTY_DESCRIPTION"] }
	entries[#entries + 1] =
		ClickRow(L["MENU_TOGGLE"], "buffDuty", feature and OptionTooltip(L[feature.caption], L[feature.desc]))
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
			rows[#rows + 1] = ItemRow(
				ItemText(C_Item.GetItemIconByID(entry.itemID), ns.GetItemLabel(entry.itemID, entry.itemName)),
				format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted),
				"BODY",
				entry.itemID
			)
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
    Open, while it's on, opens the Restock List window, as Shift + Right-Click
    does.
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
		entries[#entries + 1] = ClickRow(L["MENU_OPEN"], "restockList")
	end
	return isLoading
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
			entries[#entries + 1] = ItemRow(
				ItemText(C_Item.GetItemIconByID(block.itemID), ns.UnbracketItemLink(block.itemLink)),
				block.slot,
				"MUTED",
				block.itemID
			)
		end
	end
end

--[[
    This character's own Ignore List, the one Right-Click adds to and
    Middle-Click clears; the Global list lives in the Ignore List panel.
    Sorted by name, each item in its quality color, and only while it holds
    something. Returns whether any item was still loading.
]]
local function AddIgnoreList(entries)
	local ignoreList = ns.GetIgnoreList()
	if not ignoreList or next(ignoreList) == nil then
		return false
	end

	local items, isLoading = {}, false
	for itemID in pairs(ignoreList) do
		local name, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID)
		items[#items + 1] = { id = itemID, name = name, quality = quality, texture = texture }
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
		if item.name then
			local _, _, _, colorHex = C_Item.GetItemQualityColor(item.quality or 1)
			local label = format("|c%s%s|r", colorHex, item.name)
			rows[#rows + 1] = ItemRow(ItemText(item.texture, label), nil, nil, item.id)
		else
			rows[#rows + 1] = ItemRow(format(L["LOADING_ITEM"], item.id), nil, nil, item.id)
			rows[#rows].leftColor = "MUTED"
		end
	end

	entries[#entries + 1] = { kind = "status", left = L["MINIMAP_IGNORE_LIST"] }
	AddList(entries, rows)
	entries[#entries + 1] = ClickRow(L["MENU_CLEAR_IGNORE"], "clearIgnore")
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
	AddBuffFoodAndScrolls(entries)
	AddBuffDuty(entries)
	local restockLoading = AddRestocker(entries)
	AddClassMacros(entries)
	local ignoreLoading = AddIgnoreList(entries)
	AddMoreFeatures(entries)

	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = ClickRow(L["MENU_OPTIONS"], "options")
	return entries, restockLoading or ignoreLoading
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

-- Closes a moment after the cursor has left the button, the menu and the flyout.
menu:SetScript("OnUpdate", function(self, elapsed)
	local anchor = state.anchor
	if not anchor or not anchor:IsVisible() then
		self:Hide()
		return
	end
	if Kit.IsCursorOver(anchor) or Kit.IsCursorOver(self) or Kit.IsCursorOver(flyout) then
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
    once the cursor leaves. flyoutKey opens that title's flyout at once. A
    launcher already showing the menu keeps its place and its open flyout.
]]
function ns.ShowMenu(anchor, flyoutKey, how)
	if not ns.db or not anchor then
		return
	end
	local reopen = menu:IsShown() and state.anchor == anchor
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
