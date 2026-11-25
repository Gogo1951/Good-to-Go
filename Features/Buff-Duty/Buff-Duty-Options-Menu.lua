local ADDON_NAME, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff-Duty-Options-Menu -- the menus the Buff Duty window's lines open
    (Buff-Duty-Frame.lua and Buff-Duty-Layout.lua draw the lines): one Menu
    Kit menu, so each opens on hover beside its line, overlapping the
    window's edge, and closes a moment after the cursor leaves.

    A category's line ends in an arrow that opens that category's menu, the
    same for every category, in blocks:

      Show in Buff Duty
      When to Use (Always, In Party or Raid, In Raid) and Show (When
      Missing, or Under 10, 5 or 3 Minutes): the category's one timing
      Use with Cast Next Buff, and Show Missing Inventory (not on Self-Buffs)
      What it uses, each On or Off: Your Spells for Self-Buffs; for the
      rest, In Your Bags. Scrolls first lists every kind of scroll, and a
      rogue's or shaman's hand every one of the class's choices, carried or
      not, since the window uses the best of each in your bags.
      Well Fed then ends with Eat Buff Food When Already Well Fed.

    A weapon hand's line opens Weapon Buffs for that hand alone. The Options
    line at the window's foot (and the mini-map menu's Buff Duty row) opens
    the window's own switches:

      Show in Window   the six categories, each its Show in Buff Duty, its
                       hover opening its menu (for both hands, on Weapon Buffs)
      Other Players    Ask for Buffs, Your Target (Include NPCs, Ask Your
                       Target for Buffs), Return the Favor, Buff PvP-Flagged
                       Players
      Window           Window Opacity, 0% to 100%: how solid the window's
                       background is
      All Buff Duty Settings

    A row here is the same setting as on the settings pages, so each side
    shows what the other set. Every change ends in ns.RefreshBuffDuty, as a
    page's does, and redraws the menu.
]]

local Kit = ns.MenuKit
local BuffDuty = ns.BuffDuty
local GetItemCount = C_Item.GetItemCount

local menu

local function Settings()
	return ns.db.global.buffWindow
end

-- A row's hover: its name in gold, then what it does.
local function Tooltip(title, body)
	return function(tooltip)
		tooltip:SetText(title, ns.COLORS_RGB.TITLE.r, ns.COLORS_RGB.TITLE.g, ns.COLORS_RGB.TITLE.b, 1, true)
		tooltip:AddLine(body, ns.COLORS_RGB.BODY.r, ns.COLORS_RGB.BODY.g, ns.COLORS_RGB.BODY.b, true)
	end
end

-- A switch: flips the setting; the menu's afterChange redraws the window and the menu. submenu names the flyout its hover opens.
local function Toggle(label, desc, on, set, submenu)
	return {
		kind = "toggle",
		left = label,
		on = on and true or false,
		submenu = submenu,
		tooltip = desc and Tooltip(label, desc) or nil,
		onClick = function()
			set(not on)
		end,
	}
end

-- A switch for one thing a category uses, " [icon] Name": one space, its icon, then its name; the name alone atop the hover.
local function IconToggle(icon, name, desc, on, set)
	local entry = Toggle((" |T%s:0|t %s"):format(icon or ns.QUESTION_MARK_ICON, name), desc, on, set)
	entry.tooltip = desc and Tooltip(name, desc) or nil
	return entry
end

local function ItemIcon(itemId)
	return itemId and C_Item.GetItemIconByID(itemId) or nil
end

local function ItemName(itemId)
	return C_Item.GetItemNameByID(itemId) or L["LOADING_ITEM"]:format(itemId)
end

-- An item's switch: on unless off[itemId]. A change asks the macros for a bag scan when `rescan`, which redraws the window too.
local function ItemToggle(itemId, name, off, rescan)
	local desc = L["BUFF_DUTY_MENU_ITEM_DESCRIPTION_FORMAT"]:format(name)
	return IconToggle(ItemIcon(itemId), name, desc, not off[itemId], function(value)
		off[itemId] = not value or nil
		if rescan then
			ns.RequestUpdate()
		end
	end)
end

local function ByName(a, b)
	if a.name ~= b.name then
		return a.name < b.name
	end
	return a.id < b.id
end

--------------------------------------------------------------------------------
-- Categories
--------------------------------------------------------------------------------

-- Each category's name, as its line and its page under Buff Duty name it.
local function CategoryName(row)
	if row == "self" then
		return L["BUFF_DUTY_SELF_HEADER"]
	elseif row == "food" then
		return BuffDuty.WellFedLabel()
	elseif row == "weapons" then
		return L["BUFF_DUTY_WEAPON_PANEL_HEADER"]
	elseif row == "scrolls" then
		return L["BUFF_DUTY_SCROLLS"]
	elseif row == "elixirs" then
		return L["BUFF_DUTY_ROW_ELIXIRS"]
	end
	return L["BUFF_DUTY_ROW_OTHER"]
end

-- "When Missing", or "Under 3 Minutes" from the client's own duration string.
local function ShowText(minutes)
	if minutes == 0 then
		return L["BUFF_DUTY_SELF_REFRESH_MISSING"]
	end
	return L["BUFF_DUTY_SELF_REFRESH_UNDER"]:format(D_MINUTES:format(minutes))
end

local function SectionHeader(entries, text)
	entries[#entries + 1] = { kind = "section", left = text }
end

local function NoneInBags(entries)
	entries[#entries + 1] = { kind = "note", left = L["BUFF_DUTY_MENU_NONE_IN_BAGS"] }
end

--[[
    Self-Buffs: your class's buffs, as its Self-Buffs page lists them --
    the ones only you can put on yourself, your group buffs on you, and a
    warlock's Soulstone.
]]
local function AddSpellRows(entries)
	SectionHeader(entries, L["BUFF_DUTY_MENU_YOUR_SPELLS"])
	local _, playerClass = UnitClass("player")
	local any = false
	for _, category in ipairs(ns.buffDutySelfCategories or {}) do
		if category.id == playerClass then
			for _, entry in ipairs(ns.SortedEntries(category.entries)) do
				local key = entry.key
				local desc = entry.desc or L["BUFF_DUTY_MENU_ITEM_DESCRIPTION_FORMAT"]:format(entry.spellName)
				entries[#entries + 1] = IconToggle(
					C_Spell.GetSpellTexture(entry.ids[1]),
					entry.spellName,
					desc,
					BuffDuty.SelfItemOn(key),
					function(value)
						BuffDuty.SetSelfItemOn(key, value)
					end
				)
				any = true
			end
		end
	end
	if not any then
		entries[#entries + 1] = { kind = "note", left = L["BUFF_DUTY_MENU_NO_SPELLS"] }
	end
end

--[[
    Well Fed: every buff food in your bags the Food macro could eat
    (ns.carriedBuffFoods), each on unless turned off (buffFoodOff). The
    window offers the best one left on, so turning one off hands its place
    to the next; a change asks the macros for a bag scan, which picks the
    food again and redraws the window. Then the Food & Water page's Eat Buff
    Food When Already Well Fed.
]]
local function AddFoodRows(entries)
	SectionHeader(entries, L["BUFF_DUTY_MENU_IN_YOUR_BAGS"])
	local foods = {}
	for itemId in pairs(ns.carriedBuffFoods or {}) do
		foods[#foods + 1] = { id = itemId, name = ItemName(itemId) }
	end
	table.sort(foods, ByName)
	local off = Settings().buffFoodOff
	for _, food in ipairs(foods) do
		entries[#entries + 1] = ItemToggle(food.id, food.name, off, true)
	end
	if not foods[1] then
		NoneInBags(entries)
	end
	local wellFed = ns.GetWellFedName()
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = Toggle(
		L["OPTIONS_BUFF_FOOD_WHEN_FED"],
		L["OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT"]:format(wellFed),
		ns.db.profile.useBuffFoodWhenFed,
		function(value)
			ns.ToggleMacroSetting("useBuffFoodWhenFed", value)
		end
	)
end

--[[
    The kinds of scroll, named as the Scrolls page names them. scrollTypes
    is on the AceDB profile: which scrolls are worth reading differs from
    character to character (a README-Notes exception). The window and the
    Readiness Report both keep to them.
]]
local SCROLL_TYPES = {
	{ "Agility", SPELL_STAT2_NAME },
	{ "Intellect", SPELL_STAT4_NAME },
	{ "Protection", L["OPTIONS_SCROLL_PROTECTION"] },
	{ "Spirit", SPELL_STAT5_NAME },
	{ "Stamina", SPELL_STAT3_NAME },
	{ "Strength", SPELL_STAT1_NAME },
}
ns.SCROLL_TYPE_LABELS = SCROLL_TYPES

--[[
    Scrolls: every kind, carried or not, each On or Off, since the window
    reads the best scroll of each kind left on in your bags; then the scrolls
    in your bags, each on unless turned off here (scrollOff), whatever the
    Ignore List says.
]]
local function AddScrollRows(entries)
	SectionHeader(entries, L["BUFF_DUTY_SCROLL_TYPES"])
	local types = ns.db.profile.scrollTypes
	local iconFor = {}
	for itemId, scrollType in pairs(ns.SCROLL_ITEM_LOOKUP or {}) do
		iconFor[scrollType] = iconFor[scrollType] or ItemIcon(itemId)
	end
	for _, scroll in ipairs(SCROLL_TYPES) do
		local key, label = scroll[1], scroll[2] or scroll[1]
		entries[#entries + 1] = IconToggle(
			iconFor[key],
			label,
			L["OPTIONS_BUFF_TYPE_DESCRIPTION"]:format(label),
			types and types[key],
			function(value)
				types[key] = value
				ns.RequestUpdate()
			end
		)
	end

	SectionHeader(entries, L["BUFF_DUTY_MENU_IN_YOUR_BAGS"])
	local scrolls = {}
	for itemId in pairs(ns.SCROLL_ITEM_LOOKUP or {}) do
		if GetItemCount(itemId) > 0 then
			scrolls[#scrolls + 1] = { id = itemId, name = ItemName(itemId) }
		end
	end
	table.sort(scrolls, ByName)
	local off = Settings().scrollOff
	for _, scroll in ipairs(scrolls) do
		entries[#entries + 1] = ItemToggle(scroll.id, scroll.name, off)
	end
	if not scrolls[1] then
		NoneInBags(entries)
	end
end

-- Flasks or Elixirs: every elixir in your bags, whatever the Ignore List says, each on unless turned off here (elixirOff).
local function AddElixirRows(entries)
	SectionHeader(entries, L["BUFF_DUTY_MENU_IN_YOUR_BAGS"])
	local off = Settings().elixirOff
	local elixirs = BuffDuty.CarriedElixirs()
	for _, elixir in ipairs(elixirs) do
		entries[#entries + 1] = ItemToggle(elixir.itemId, ItemName(elixir.itemId), off)
	end
	if not elixirs[1] then
		NoneInBags(entries)
	end
end

-- Other Buffs: the ones in your bags (Winterfall Firewater), each its own switch.
local function AddOtherRows(entries)
	SectionHeader(entries, L["BUFF_DUTY_MENU_IN_YOUR_BAGS"])
	local any = false
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		if entry.itemId and GetItemCount(entry.itemId) > 0 then
			local key, name = entry.key, ItemName(entry.itemId)
			local desc = L["BUFF_DUTY_MENU_ITEM_DESCRIPTION_FORMAT"]:format(name)
			entries[#entries + 1] = IconToggle(
				ItemIcon(entry.itemId),
				name,
				desc,
				BuffDuty.SelfItemOn(key),
				function(value)
					BuffDuty.SetSelfItemOn(key, value)
				end
			)
			any = true
		end
	end
	if not any then
		NoneInBags(entries)
	end
end

--------------------------------------------------------------------------------
-- Weapon Buffs
--------------------------------------------------------------------------------

-- Named as the Weapon Buffs page names it: a poison line or an item by its first item, an imbue by its spell.
local function WeaponName(entry)
	local id = entry.ids[1]
	if entry.items then
		return C_Item.GetItemInfo(id) or L["LOADING_ITEM"]:format(id)
	end
	return C_Spell.GetSpellName(id) or L["TRACKED_SPELL_PENDING"]:format(id)
end

local function WeaponIcon(entry)
	if entry.items then
		return ItemIcon(entry.ids[1])
	end
	return C_Spell.GetSpellTexture(entry.ids[1])
end

local function Carried(entry)
	for _, item in ipairs(entry.items or {}) do
		if GetItemCount(item.id) > 0 then
			return true
		end
	end
	return false
end

--[[
    A choice is ticked per hand on the page. From a hand's line it's that
    hand's tick; from Options, one switch for every hand it can go on: on
    while any hand has it, and a flip sets them all.
]]
local function WeaponRow(entry, list, hands, handKey)
	local name = WeaponName(entry)
	local on = false
	for _, hand in ipairs(hands) do
		if BuffDuty.WeaponChoiceOn(list, handKey(hand), entry.key) then
			on = true
		end
	end
	local desc = L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"]:format(name)
	return IconToggle(WeaponIcon(entry), name, desc, on, function(value)
		for _, hand in ipairs(hands) do
			local key = handKey(hand)
			list[key] = list[key] or {}
			list[key][entry.key] = value
		end
	end)
end

-- The hands of `hands` that `hand` allows: just it, when it's one of them, or all of them for no hand.
local function HandsFor(hands, hand)
	if not hand then
		return hands
	end
	return tContains(hands, hand) and { hand } or {}
end

--[[
    Your class's choices (a rogue's poisons, a shaman's imbues, a warlock's
    stones on WoW Forever), every one whatever you carry, under the class's
    name: the window uses the best rank of each in your bags. Then the oils,
    stones and lures in your bags.
]]
local function AddWeaponRows(entries, hand)
	local _, playerClass = UnitClass("player")
	local classHands = HandsFor(ns.BUFF_DUTY_WEAPON_HANDS and ns.BUFF_DUTY_WEAPON_HANDS[playerClass] or {}, hand)
	local spells, items = {}, {}
	local coldIds = {}
	if classHands[1] then
		for _, entry in ipairs(BuffDuty.weaponEntries or {}) do
			if entry.row.class == playerClass then
				spells[#spells + 1] = { entry = entry, name = WeaponName(entry), id = entry.ids[1] }
				if entry.items and not C_Item.GetItemInfo(entry.ids[1]) then
					coldIds[#coldIds + 1] = entry.ids[1]
				end
			end
		end
	end
	if coldIds[1] then
		ns.WarmItemCache(coldIds, "BuffDutyWeaponMenu", function()
			if menu then
				menu:Refresh()
			end
		end)
	end
	for _, entry in ipairs(BuffDuty.weaponItemEntries or {}) do
		local hands = HandsFor(Data.WEAPON_ITEM_KIND_HANDS[entry.kind] or Data.WEAPON_HAND_ORDER, hand)
		if hands[1] and Carried(entry) then
			items[#items + 1] = { entry = entry, name = WeaponName(entry), id = entry.ids[1], hands = hands }
		end
	end
	table.sort(spells, ByName)
	table.sort(items, ByName)

	if spells[1] then
		SectionHeader(entries, LOCALIZED_CLASS_NAMES_MALE[playerClass] or playerClass)
		for _, spell in ipairs(spells) do
			entries[#entries + 1] = WeaponRow(spell.entry, Settings().weaponPicks, classHands, function(each)
				return playerClass .. "_" .. each
			end)
		end
	end
	SectionHeader(entries, L["BUFF_DUTY_MENU_IN_YOUR_BAGS"])
	for _, item in ipairs(items) do
		entries[#entries + 1] = WeaponRow(item.entry, Settings().weaponItems, item.hands, function(each)
			return each
		end)
	end
	if not items[1] then
		NoneInBags(entries)
	end
end

--------------------------------------------------------------------------------
-- A Category's Menu
--------------------------------------------------------------------------------

local ITEM_ROWS = {
	self = AddSpellRows,
	food = AddFoodRows,
	scrolls = AddScrollRows,
	elixirs = AddElixirRows,
	other = AddOtherRows,
}

local function CategoryEntries(row, hand)
	local settings = Settings()
	local entries = {}
	entries[#entries + 1] = Toggle(
		L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY"],
		L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
		BuffDuty.RowOn(row),
		function(value)
			BuffDuty.SetRowOn(row, value)
		end
	)
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = {
		kind = "value",
		left = L["BUFF_DUTY_ROW_WHEN"],
		leftColor = "TEXT",
		right = L["BUFF_DUTY_ROW_WHEN_" .. (settings.rowWhen[row] or "ALWAYS")],
		submenu = "when:" .. row,
		tooltip = Tooltip(L["BUFF_DUTY_ROW_WHEN"], L["BUFF_DUTY_ROW_WHEN_DESCRIPTION"]),
	}
	entries[#entries + 1] = {
		kind = "value",
		left = L["BUFF_DUTY_MENU_SHOW"],
		leftColor = "TEXT",
		right = ShowText(settings.rowShow[row] or Data.BUFF_DUTY_ROW_SHOW_DEFAULT),
		submenu = "show:" .. row,
		tooltip = Tooltip(L["BUFF_DUTY_MENU_SHOW"], L["BUFF_DUTY_ROW_SHOW_DESCRIPTION"]),
	}
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = Toggle(
		L["BUFF_DUTY_ROW_KEY"]:format(L["BUFF_KEY"]),
		L["BUFF_DUTY_ROW_KEY_DESCRIPTION"]:format(L["BUFF_KEY"]),
		BuffDuty.RowOnKey(row),
		function(value)
			settings.rowKey[row] = value
		end
	)
	-- Self-Buffs are spells: nothing to run out of.
	if row ~= "self" then
		entries[#entries + 1] = Toggle(
			L["BUFF_DUTY_MENU_SHOW_MISSING_INVENTORY"],
			L["BUFF_DUTY_ROW_OUT_DESCRIPTION"],
			BuffDuty.RowOut(row),
			function(value)
				settings.rowOut[row] = value
			end
		)
	end
	entries[#entries + 1] = { kind = "spacer" }
	if row == "weapons" then
		AddWeaponRows(entries, hand)
	else
		ITEM_ROWS[row](entries)
	end
	return entries
end

-- When to Use's choices: Always, In Party or Raid, In Raid.
local function WhenEntries(row)
	local entries = {}
	local current = Settings().rowWhen[row]
	for _, value in ipairs(Data.BUFF_DUTY_ROW_WHEN_ORDER) do
		entries[#entries + 1] = {
			kind = "choice",
			left = L["BUFF_DUTY_ROW_WHEN_" .. value],
			selected = value == current,
			onClick = function()
				Settings().rowWhen[row] = value
			end,
		}
	end
	return entries
end

-- Show's choices: When Missing, then Under 10, 5 or 3 Minutes.
local function ShowEntries(row)
	local entries = {}
	local current = Settings().rowShow[row]
	for _, minutes in ipairs(Data.BUFF_DUTY_ROW_SHOW_CHOICES) do
		entries[#entries + 1] = {
			kind = "choice",
			left = ShowText(minutes),
			selected = minutes == current,
			onClick = function()
				Settings().rowShow[row] = minutes
			end,
		}
	end
	return entries
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

-- A switch on one of the window's own settings.
local function SettingToggle(key, label, desc, submenu)
	return Toggle(label, desc, Settings()[key], function(value)
		Settings()[key] = value
	end, submenu)
end

-- Your Target's flyout.
local function TargetEntries()
	return {
		SettingToggle("targetNPCs", L["BUFF_DUTY_TARGET_NPCS"], L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"]),
		SettingToggle("askTarget", L["BUFF_DUTY_ASK_TARGET"], L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"]),
	}
end

local function OpacityText(percent)
	return L["BUFF_DUTY_MENU_OPACITY_PERCENT"]:format(percent)
end

--[[
    Window Opacity's flyout: 0% to 100%, the one picked checked. Only the
    window's background changes. Hovering a choice shows it on the window
    (preview) until the cursor leaves the flyout, which puts the saved one
    back; a click keeps it.
]]
local function OpacityEntries()
	local entries = {}
	local current = Settings().windowOpacity
	for _, percent in ipairs(Data.BUFF_DUTY_OPACITY_CHOICES) do
		entries[#entries + 1] = {
			kind = "choice",
			left = OpacityText(percent),
			selected = percent == current,
			preview = percent,
			onClick = function()
				Settings().windowOpacity = percent
			end,
		}
	end
	return entries
end

-- { setting, label, description, submenu }: the Other Players block, in the Buff Duty page's order.
local OTHER_PLAYERS = {
	{ "askOtherClasses", "BUFF_DUTY_ASK_OTHERS", "BUFF_DUTY_ASK_OTHERS_DESCRIPTION" },
	{ "targetEnabled", "BUFF_DUTY_TARGET_ENABLE", "BUFF_DUTY_TARGET_ENABLE_DESCRIPTION", "target" },
	{ "favorEnabled", "BUFF_DUTY_FAVOR_ENABLE", "BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION" },
	{ "buffPvPFlagged", "BUFF_DUTY_BUFF_PVP_FLAGGED", "BUFF_DUTY_BUFF_PVP_FLAGGED_DESCRIPTION" },
}

local function OptionsEntries()
	local entries = {}
	SectionHeader(entries, L["BUFF_DUTY_SHOW_HEADER"])
	for _, row in ipairs(Data.BUFF_DUTY_ROWS) do
		if BuffDuty.RowExists(row) then
			entries[#entries + 1] = Toggle(
				CategoryName(row),
				L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
				BuffDuty.RowOn(row),
				function(value)
					BuffDuty.SetRowOn(row, value)
				end,
				"cat:" .. row
			)
		end
	end
	SectionHeader(entries, L["BUFF_DUTY_MENU_OTHER_PLAYERS"])
	for _, row in ipairs(OTHER_PLAYERS) do
		entries[#entries + 1] = SettingToggle(row[1], L[row[2]], L[row[3]], row[4])
	end
	SectionHeader(entries, L["BUFF_DUTY_HEADER"])
	entries[#entries + 1] = {
		kind = "value",
		left = L["BUFF_DUTY_MENU_OPACITY"],
		right = OpacityText(Settings().windowOpacity),
		submenu = "opacity",
		tooltip = Tooltip(L["BUFF_DUTY_MENU_OPACITY"], L["BUFF_DUTY_MENU_OPACITY_DESCRIPTION"]),
	}
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = L["BUFF_DUTY_MENU_ALL_SETTINGS"],
		leftColor = "INFO",
		closes = true,
		tooltip = Tooltip(L["BUFF_DUTY_MENU_ALL_SETTINGS"], L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"]),
		onClick = function()
			ns.HideMenu() -- The mini-map menu, when it opened from there
			ns:OpenOptionsPanel("BuffDuty")
		end,
	}
	return entries
end

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

--[[
    What a menu key opens: "options", "cat:<row>" or "cat:weapons:<hand>"
    for a category, "when:<row>" and "show:<row>" for its When to Use and Show,
    "target", or "opacity".
]]
local function EntriesFor(key)
	if key == "options" then
		return OptionsEntries()
	elseif key == "target" then
		return TargetEntries()
	elseif key == "opacity" then
		return OpacityEntries()
	end
	local kind, row, hand = strsplit(":", key)
	if kind == "cat" then
		return CategoryEntries(row, hand)
	elseif kind == "when" then
		return WhenEntries(row)
	elseif kind == "show" then
		return ShowEntries(row)
	end
	return {}
end

-- The open menu's own key, set as its line opens it.
local rootKey = "options"

-- Every flyout by its key, built when asked for.
local flyouts = setmetatable({}, {
	__index = function(_, key)
		return function()
			return EntriesFor(key)
		end
	end,
})

-- The line whose highlight stays lit while its menu is open, and the panel showing a hovered opacity.
local lit, previewPanel

local function EndPreview()
	if previewPanel then
		previewPanel = nil
		ns.ApplyBuffDutyOpacity()
	end
end

-- A hovered opacity choice shows on the window; any other row, or leaving its panel, puts the saved one back.
local function OnEnterRow(row, entry)
	if entry and entry.preview then
		previewPanel = row:GetParent()
		ns.ApplyBuffDutyOpacity(entry.preview)
	else
		EndPreview()
	end
end

menu = Kit.CreateMenu({
	-- Named so Escape closes it, as every menu closes.
	name = ADDON_NAME .. "BuffDutyOptions",
	publish = false,
	build = function()
		return EntriesFor(rootKey)
	end,
	flyouts = flyouts,
	afterChange = function()
		previewPanel = nil
		ns.ApplyBuffDutyOpacity()
		ns.RefreshBuffDuty()
		menu:Refresh()
	end,
})

-- Each panel, sub-menus included, takes the opacity preview as the kit makes it.
local KitRender = menu.Render
function menu:Render()
	KitRender(self)
	for _, panel in ipairs(self.panels) do
		panel.onEnterRow = OnEnterRow
	end
end

menu.frame:HookScript("OnUpdate", function()
	if previewPanel and not (previewPanel:IsShown() and Kit.IsCursorOver(previewPanel)) then
		EndPreview()
	end
end)

menu.frame:HookScript("OnHide", function()
	EndPreview()
	if lit then
		lit:UnlockHighlight()
		lit = nil
	end
end)

local function Open(owner, key)
	if not ns.db or not owner then
		return
	end
	rootKey = key
	if lit and lit ~= owner then
		lit:UnlockHighlight()
	end
	lit = owner
	menu:Show(owner, "line")
	owner:LockHighlight()
end

-- A category line's menu, beside its arrow: key is a Data.BUFF_DUTY_ROWS row, or "weapons:<hand>".
function ns.ShowBuffDutyMenu(owner, key)
	Open(owner, "cat:" .. key)
end

-- The Options menu, beside the window's Options line or the mini-map menu's Buff Duty row.
function ns.ShowBuffDutyOptions(owner)
	Open(owner, "options")
end

-- Closes the menu when it hangs off a line inside within (the mini-map menu), or any line when within is nil.
function ns.HideBuffDutyOptions(within)
	local owner = menu.state.anchor
	if menu:IsShown() and (not within or (owner and Kit.IsInside(owner, within))) then
		menu:Hide()
	end
end

-- Whether the cursor is over the menu or a sub-menu, so a menu it opened from stays open while it's used.
function ns.IsCursorOverBuffDutyOptions()
	return menu:IsShown() and menu:IsCursorOver()
end
