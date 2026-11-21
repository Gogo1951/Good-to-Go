local ADDON_NAME, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff-Duty-Options-Menu -- the flyout the Options line at the foot of the
    Buff Duty window opens (Buff-Duty-Frame.lua draws the line): the window's
    own switches, without a trip to the settings panel. A Menu Kit panel, the
    one the mini-map menu's flyouts are, so it opens on hover beside its line
    and closes a moment after the cursor leaves both.

      Show in Window   the rows the Buff Duty panel turns on and off; Your
                       Target opens Include NPCs
      Consumables      the Self-Buffs panel's Consumables box, the ones in
                       your bags, and your Soulstone on a warlock; Buff Food
                       opens the buff food in your bags, Scrolls the scroll
                       types you carry
      Weapon Buffs     your class's poisons or imbues, and the oils, stones
                       and lures in your bags
      Window Opacity   opens 0% to 100%: how solid the window's background
                       is, the text left as it is
      All Buff Duty Settings

    A row here is the same setting as on the panels, so each side shows what
    the other set. Every change ends in ns.RefreshBuffDuty, as a panel's does,
    and redraws the flyout. A row with a submenu still flips on a click, and
    hovering it opens its own options in a second flyout beside it, as a
    mini-map menu title opens its flyout.
]]

local Kit = ns.MenuKit
local BuffDuty = ns.BuffDuty
local GetItemCount = C_Item.GetItemCount

local HOVER_CLOSE_DELAY = 0.4

-- Named so Escape closes it, as every menu closes (its submenu goes with it).
local flyout = Kit.CreatePanel(ADDON_NAME .. "BuffDutyOptions", UIParent)
local subFlyout = Kit.CreatePanel(nil, UIParent)
table.insert(UISpecialFrames, flyout:GetName())
local state = { owner = nil, idle = 0, openLeft = false, subKey = nil, preview = nil }

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

local Render

-- A switch: flips the setting, then the window and the flyout redraw. submenu names the flyout its hover opens.
local function Toggle(label, desc, on, set, submenu)
	return {
		kind = "toggle",
		left = label,
		on = on,
		submenu = submenu,
		tooltip = desc and Tooltip(label, desc) or nil,
		onClick = function()
			set(not on)
			ns.RefreshBuffDuty()
			Render()
		end,
	}
end

-- A consumable's switch, " [icon] Name": one space, its icon, then its name; the name alone atop the hover.
local function IconToggle(icon, name, desc, on, set, submenu)
	local entry = Toggle((" |T%s:0|t %s"):format(icon or ns.QUESTION_MARK_ICON, name), desc, on, set, submenu)
	entry.tooltip = desc and Tooltip(name, desc) or nil
	return entry
end

local function ItemIcon(itemId)
	return itemId and C_Item.GetItemIconByID(itemId) or nil
end

--------------------------------------------------------------------------------
-- Show in Window
--------------------------------------------------------------------------------

--[[
    { setting, label, description, submenu }: the Buff Duty panel's Show in
    Window switches, in its order. Your Target opens Include NPCs and Ask
    for Their Buffs.
]]
local WINDOW_ROWS = {
	{ "selfEnabled", "BUFF_DUTY_SELF_ENABLE", "BUFF_DUTY_SELF_ENABLE_DESCRIPTION" },
	{ "weaponEnabled", "BUFF_DUTY_WEAPON_ENABLE", "BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION" },
	{ "askOtherClasses", "BUFF_DUTY_ASK_OTHERS", "BUFF_DUTY_ASK_OTHERS_DESCRIPTION" },
	{ "targetEnabled", "BUFF_DUTY_TARGET_ENABLE", "BUFF_DUTY_TARGET_ENABLE_DESCRIPTION", "target" },
	{ "favorEnabled", "BUFF_DUTY_FAVOR_ENABLE", "BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION" },
}

-- A switch on one of the window's own settings.
local function SettingToggle(key, label, desc, submenu)
	return Toggle(label, desc, Settings()[key] and true or false, function(value)
		Settings()[key] = value
	end, submenu)
end

local function AddWindowRows(entries)
	entries[#entries + 1] = { kind = "section", left = L["BUFF_DUTY_SHOW_HEADER"] }
	for _, row in ipairs(WINDOW_ROWS) do
		entries[#entries + 1] = SettingToggle(row[1], L[row[2]], L[row[3]], row[4])
	end
end

-- Your Target's flyout.
local function TargetEntries()
	return {
		SettingToggle("targetNPCs", L["BUFF_DUTY_TARGET_NPCS"], L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"]),
		SettingToggle("askTarget", L["BUFF_DUTY_ASK_TARGET"], L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"]),
	}
end

--------------------------------------------------------------------------------
-- Consumables
--------------------------------------------------------------------------------

--[[
    On here is the timing it had before it was last turned off here
    (menuSelfRefresh, kept beside the panel's own selfRefresh), or When
    Missing for one never timed, so turning a consumable off and on again
    keeps an "Under 5 Minutes" the player picked on the panel.
]]
local function SetSelfRefresh(key, on)
	local settings = Settings()
	local current = settings.selfRefresh[key]
	if on then
		settings.selfRefresh[key] = settings.menuSelfRefresh[key] or Data.SELF_REFRESH_MISSING
	elseif current ~= Data.SELF_REFRESH_OFF then
		settings.menuSelfRefresh[key] = current
		settings.selfRefresh[key] = Data.SELF_REFRESH_OFF
	end
end

local function SelfRefreshOn(key)
	local when = Settings().selfRefresh[key]
	return when ~= nil and when ~= Data.SELF_REFRESH_OFF
end

-- Named as the Self-Buffs panel names it (Buff-Duty.lua): its own name, or its first spell's.
local function ConsumableName(entry)
	return entry.name or C_Spell.GetSpellName(entry.ids[1]) or tostring(entry.itemId or entry.key)
end

-- The scroll types you carry a scroll of, each to one such scroll's item id, whatever the Ignore List says.
local function CarriedScrollTypes()
	local carried = {}
	for itemId, scrollType in pairs(ns.SCROLL_ITEM_LOOKUP or {}) do
		if GetItemCount(itemId) > 0 then
			carried[scrollType] = itemId
		end
	end
	return carried
end

--[[
    The icon a consumable's line wears: the item's own, a scroll you carry
    for Scrolls, otherwise its first spell's (Well Fed, the Soulstone).
]]
local function ConsumableIcon(entry)
	if entry.itemId then
		return ItemIcon(entry.itemId)
	elseif entry.scrolls then
		local _, itemId = next(CarriedScrollTypes())
		return ItemIcon(itemId)
	end
	local spellId = entry.ids[1] or (entry.ranks and entry.ranks[1] and entry.ranks[1].id)
	return spellId and C_Spell.GetSpellTexture(spellId) or nil
end

--[[
    Whether the window could offer a consumable now: one in your bags (any
    buff food for Well Fed, any scroll for Scrolls). The Soulstone always
    counts, since its icon makes a stone when you have none.
]]
local function Carrying(entry)
	if entry.wellFed then
		return next(ns.carriedBuffFoods or {}) ~= nil
	elseif entry.scrolls then
		return next(CarriedScrollTypes()) ~= nil
	elseif entry.itemId then
		return GetItemCount(entry.itemId) > 0
	end
	return true
end

local function AddConsumableRows(entries)
	local list = {}
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		if Carrying(entry) then
			list[#list + 1] = entry
		end
	end
	local _, playerClass = UnitClass("player")
	local stone = BuffDuty.soulstoneEntry
	if stone and stone.row.class == playerClass then
		list[#list + 1] = stone
	end
	if not list[1] then
		return
	end
	entries[#entries + 1] = { kind = "section", left = L["BUFF_DUTY_SELF_ITEMS_HEADER"] }
	for _, entry in ipairs(list) do
		local key, name = entry.key, ConsumableName(entry)
		local submenu = (entry.wellFed and "buffFood") or (entry.scrolls and "scrolls") or nil
		if entry.wellFed then
			name = L["BUFF_DUTY_MENU_BUFF_FOOD"]
		end
		local desc = entry.desc or L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"]:format(name)
		entries[#entries + 1] = IconToggle(ConsumableIcon(entry), name, desc, SelfRefreshOn(key), function(value)
			SetSelfRefresh(key, value)
		end, submenu)
	end
end

--[[
    Buff Food's flyout: every buff food in your bags the Food macro could
    eat (ns.carriedBuffFoods), by name, each on unless turned off here
    (buffWindow.buffFoodOff). Well Fed's icon offers the best one left on, so
    turning one off hands the icon to the next. A change asks the macros for
    a bag scan, which picks the food again and redraws the window. Then the
    Food & Water page's Eat Buff Food When Already Well Fed.
]]
local function BuffFoodEntries()
	local entries = {}
	local foods = {}
	for itemId in pairs(ns.carriedBuffFoods or {}) do
		local name = C_Item.GetItemNameByID(itemId) or L["TRACKED_ITEM_PENDING"]:format(itemId)
		foods[#foods + 1] = { id = itemId, name = name }
	end
	table.sort(foods, function(a, b)
		return a.name < b.name
	end)
	local wellFed = ns.GetWellFedName()
	local off = Settings().buffFoodOff
	for _, food in ipairs(foods) do
		local id = food.id
		local desc = L["BUFF_DUTY_MENU_FOOD_DESCRIPTION_FORMAT"]:format(food.name, wellFed)
		entries[#entries + 1] = IconToggle(ItemIcon(id), food.name, desc, not off[id], function(value)
			off[id] = not value or nil
			ns.RequestUpdate()
		end)
	end
	if not foods[1] then
		entries[#entries + 1] = { kind = "note", left = L["BUFF_DUTY_MENU_NO_BUFF_FOOD"] }
	end
	-- a line, not a gap: the switch below is a setting, not one of the foods
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = Toggle(
		L["OPTIONS_BUFF_FOOD_WHEN_FED"],
		L["OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT"]:format(wellFed),
		ns.db.profile.useBuffFoodWhenFed and true or false,
		function(value)
			ns.ToggleMacroSetting("useBuffFoodWhenFed", value)
		end
	)
	return entries
end

--[[
    Scrolls' flyout: the scroll types the Self-Buffs page ticks
    (scrollTypes), named as it names them, which the window's scroll icons
    and the Readiness Report both keep to. Only the types you carry a scroll
    of. The Self-Buffs page lists the same types from this table.
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

local function ScrollEntries()
	local entries = {}
	local types = ns.db.profile.scrollTypes
	local carried = CarriedScrollTypes()
	for _, scroll in ipairs(SCROLL_TYPES) do
		local key, label = scroll[1], scroll[2] or scroll[1]
		if carried[key] then
			local desc = L["OPTIONS_BUFF_TYPE_DESCRIPTION"]:format(label)
			local icon = ItemIcon(carried[key])
			entries[#entries + 1] = IconToggle(icon, label, desc, types[key] and true or false, function(value)
				types[key] = value
				ns.RequestUpdate()
			end)
		end
	end
	return entries
end

--------------------------------------------------------------------------------
-- Weapon Buffs
--------------------------------------------------------------------------------

-- Named as the Weapon Buffs panel names it: an item by its name, an imbue by its spell.
local function WeaponName(entry)
	local id = entry.ids[1]
	if entry.items then
		return C_Item.GetItemInfo(id) or L["TRACKED_ITEM_PENDING"]:format(id)
	end
	return C_Spell.GetSpellName(id) or L["TRACKED_SPELL_PENDING"]:format(id)
end

-- An item by its own icon, an imbue or poison spell by its spell's.
local function WeaponIcon(entry)
	local id = entry.ids[1]
	if entry.items then
		return ItemIcon(id)
	end
	return C_Spell.GetSpellTexture(id)
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
    A choice is ticked per hand on the panel. Here it is one switch: on while
    any hand has it, and a flip sets every hand alike.
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

--[[
    Your class's choices, sorted by name, then the oils, stones and lures you
    carry. The panel lists every one there is; the flyout keeps to what the
    window could offer you now.
]]
local function AddWeaponRows(entries)
	local _, playerClass = UnitClass("player")
	local spells, items = {}, {}
	for _, entry in ipairs(BuffDuty.weaponEntries or {}) do
		if entry.row.class == playerClass then
			spells[#spells + 1] = entry
		end
	end
	for _, entry in ipairs(BuffDuty.weaponItemEntries or {}) do
		if Carried(entry) then
			items[#items + 1] = entry
		end
	end
	if not (spells[1] or items[1]) then
		return
	end
	local function ByName(a, b)
		return WeaponName(a) < WeaponName(b)
	end
	table.sort(spells, ByName)
	table.sort(items, ByName)

	entries[#entries + 1] = { kind = "section", left = L["BUFF_DUTY_WEAPON_PANEL_HEADER"] }
	local classHands = ns.BUFF_DUTY_WEAPON_HANDS and ns.BUFF_DUTY_WEAPON_HANDS[playerClass] or {}
	for _, entry in ipairs(spells) do
		entries[#entries + 1] = WeaponRow(entry, Settings().weaponPicks, classHands, function(hand)
			return playerClass .. "_" .. hand
		end)
	end
	for _, entry in ipairs(items) do
		local hands = Data.WEAPON_ITEM_KIND_HANDS[entry.kind] or Data.WEAPON_HAND_ORDER
		entries[#entries + 1] = WeaponRow(entry, Settings().weaponItems, hands, function(hand)
			return hand
		end)
	end
end

--------------------------------------------------------------------------------
-- Window Opacity
--------------------------------------------------------------------------------

local function OpacityText(percent)
	return L["BUFF_DUTY_MENU_OPACITY_PERCENT"]:format(percent)
end

-- A gold heading with the opacity picked on its right; its hover opens the choices.
local function AddOpacityRows(entries)
	entries[#entries + 1] = {
		kind = "submenu",
		left = L["BUFF_DUTY_MENU_OPACITY"],
		right = OpacityText(Settings().windowOpacity),
		submenu = "opacity",
		tooltip = Tooltip(L["BUFF_DUTY_MENU_OPACITY"], L["BUFF_DUTY_MENU_OPACITY_DESCRIPTION"]),
	}
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
				ns.ApplyBuffDutyOpacity()
				Render()
			end,
		}
	end
	return entries
end

--------------------------------------------------------------------------------
-- Flyout
--------------------------------------------------------------------------------

-- Each submenu's rows by its key; a row with that submenu opens them on hover.
local SUBMENUS = {
	target = TargetEntries,
	buffFood = BuffFoodEntries,
	scrolls = ScrollEntries,
	opacity = OpacityEntries,
}

-- Which rows the kit draws the arrow on: a switch whose hover opens its own submenu.
local FLYOUT_CONTEXT = {
	hasFlyout = function(entry)
		return SUBMENUS[entry.submenu] ~= nil
	end,
}

local function BuildEntries()
	local entries = {}
	AddWindowRows(entries)
	AddConsumableRows(entries)
	AddWeaponRows(entries)
	AddOpacityRows(entries)
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = L["BUFF_DUTY_MENU_ALL_SETTINGS"],
		leftColor = "INFO",
		tooltip = Tooltip(L["BUFF_DUTY_MENU_ALL_SETTINGS"], L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"]),
		onClick = function()
			flyout:Hide()
			ns.HideMenu() -- The mini-map menu, when it opened from there
			ns:OpenOptionsPanel("BuffDuty")
		end,
	}
	return entries
end

--[[
    Beside its line, level with it, as a mini-map flyout sits beside its
    title: over the window's right edge, or its left one when the window
    sits on the right half of the screen. gap is from the line's end, so the
    flyout overlaps the window as a flyout overlaps its menu.
]]
local function Position(owner, gap)
	local x = owner:GetCenter()
	local scale = owner:GetEffectiveScale() / UIParent:GetEffectiveScale()
	state.openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
	flyout:ClearAllPoints()
	if state.openLeft then
		flyout:SetPoint("TOPRIGHT", owner, "TOPLEFT", -gap, Kit.FLYOUT_RISE)
	else
		flyout:SetPoint("TOPLEFT", owner, "TOPRIGHT", gap, Kit.FLYOUT_RISE)
	end
	flyout.tooltipAnchor = state.openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

--[[
    The open submenu beside its row, its first row level with it, on the side
    the flyout opened toward. The row keeps its highlight while it's open.
]]
local function RenderSubmenu()
	local key = state.subKey
	local row = key and flyout:SubmenuRow(key)
	local builder = key and SUBMENUS[key]
	if not (row and builder) then
		state.subKey = nil
		subFlyout:Hide()
		return
	end
	subFlyout.tooltipAnchor = flyout.tooltipAnchor
	subFlyout:Render(builder(), FLYOUT_CONTEXT)
	subFlyout:ClearAllPoints()
	if state.openLeft then
		subFlyout:SetPoint("TOPRIGHT", row, "TOPLEFT", -Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	else
		subFlyout:SetPoint("TOPLEFT", row, "TOPRIGHT", Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	end
	subFlyout:SetFrameLevel(flyout:GetFrameLevel() + 20)
	subFlyout:Show()
	row:LockHighlight()
end

function Render()
	if not flyout:IsShown() or not ns.db then
		return
	end
	flyout:Render(BuildEntries(), FLYOUT_CONTEXT)
	RenderSubmenu()
end

-- Entering a row with a submenu opens it, and any other row closes it, the way any game submenu behaves.
flyout.onEnterRow = function(_, entry)
	local key = entry and entry.submenu or nil
	if key ~= state.subKey then
		state.subKey = key
		Render()
	end
end

-- A hovered opacity choice shows on the window; EndPreview puts the saved one back.
subFlyout.onEnterRow = function(_, entry)
	if entry and entry.preview then
		state.preview = entry.preview
		ns.ApplyBuffDutyOpacity(entry.preview)
	end
end

local function EndPreview()
	if state.preview then
		state.preview = nil
		ns.ApplyBuffDutyOpacity()
	end
end

subFlyout:SetScript("OnHide", EndPreview)

--[[
    Opens the flyout beside owner, the Options line, keeping its highlight lit
    while open. gap is how far past the line it starts.
]]
function ns.ShowBuffDutyOptions(owner, gap)
	if not ns.db or not owner then
		return
	end
	state.idle = 0
	if flyout:IsShown() and state.owner == owner then
		return
	end
	state.owner = owner
	Position(owner, gap or Kit.FLYOUT_GAP)
	flyout:SetFrameLevel(owner:GetFrameLevel() + 20)
	flyout:Show()
	Render()
	owner:LockHighlight()
end

-- Closes the flyout when it hangs off a line inside within (the mini-map menu), or any line when within is nil.
function ns.HideBuffDutyOptions(within)
	if flyout:IsShown() and (not within or (state.owner and Kit.IsInside(state.owner, within))) then
		flyout:Hide()
	end
end

-- Whether the cursor is over the flyout or its submenu, so a menu it opened from stays open while it's used.
function ns.IsCursorOverBuffDutyOptions()
	return flyout:IsShown() and (Kit.IsCursorOver(flyout) or Kit.IsCursorOver(subFlyout))
end

-- Closes a moment after the cursor has left the line and the flyout, or at once when the window goes.
flyout:SetScript("OnUpdate", function(self, elapsed)
	local owner = state.owner
	if not owner or not owner:IsVisible() then
		self:Hide()
		return
	end
	if state.preview and not Kit.IsCursorOver(subFlyout) then
		EndPreview()
	end
	if Kit.IsCursorOver(owner) or Kit.IsCursorOver(self) or Kit.IsCursorOver(subFlyout) then
		state.idle = 0
		return
	end
	state.idle = state.idle + elapsed
	if state.idle >= HOVER_CLOSE_DELAY then
		self:Hide()
	end
end)

flyout:SetScript("OnHide", function()
	if state.owner then
		state.owner:UnlockHighlight()
	end
	state.owner = nil
	state.subKey = nil
	subFlyout:Hide()
	local tooltipOwner = GameTooltip:GetOwner()
	if tooltipOwner and (Kit.IsInside(tooltipOwner, flyout) or Kit.IsInside(tooltipOwner, subFlyout)) then
		GameTooltip:Hide()
	end
end)
