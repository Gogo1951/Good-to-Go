local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff-Duty-Options-Menu -- the menu the Options line at the foot of the Buff
    Duty window opens (Buff-Duty-Frame.lua draws the line): the window's own
    switches, without a trip to the settings panel.

      Show in Window   the rows the Buff Duty panel turns on and off
      Consumables      the Self-Buffs panel's Consumables box, and your
                       Soulstone on a warlock
      Weapon Buffs     your class's poisons or imbues, and the oils, stones
                       and lures in your bags
      All Buff Duty Settings

    A row here is the same setting as on the panels, so each side shows what
    the other set. Every change ends in ns.RefreshBuffDuty, as a panel's does.
]]

local BuffDuty = ns.BuffDuty
local GetItemCount = C_Item.GetItemCount

local TITLE = ns.COLORS_RGB.TITLE
local BODY = ns.COLORS_RGB.BODY

local function Settings()
	return ns.db.global.buffWindow
end

-- A row's hover: its name in gold, then what it does.
local function SetTip(element, title, body)
	if not element.SetTooltip or not body then
		return
	end
	element:SetTooltip(function(tooltip)
		tooltip:SetText(title, TITLE.r, TITLE.g, TITLE.b, 1, true)
		tooltip:AddLine(body, BODY.r, BODY.g, BODY.b, true)
	end)
end

-- A switch that keeps the menu open, so several can be flipped in one visit.
local function Checkbox(root, label, desc, isOn, set)
	local element = root:CreateCheckbox(label, isOn, function()
		set(not isOn())
		ns.RefreshBuffDuty()
		return MenuResponse.Refresh
	end)
	SetTip(element, label, desc)
	return element
end

--------------------------------------------------------------------------------
-- Show in Window
--------------------------------------------------------------------------------

-- { setting, label, description }: the Buff Duty panel's Show in Window switches, in its order.
local WINDOW_ROWS = {
	{ "selfEnabled", "BUFF_DUTY_SELF_ENABLE", "BUFF_DUTY_SELF_ENABLE_DESCRIPTION" },
	{ "weaponEnabled", "BUFF_DUTY_WEAPON_ENABLE", "BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION" },
	{ "askOtherClasses", "BUFF_DUTY_PARTY_BUFFS_HEADER", "BUFF_DUTY_ASK_OTHERS_DESCRIPTION" },
	{ "favorEnabled", "BUFF_DUTY_FAVOR_ENABLE", "BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION" },
	{ "targetEnabled", "BUFF_DUTY_TARGET_ENABLE", "BUFF_DUTY_TARGET_ENABLE_DESCRIPTION" },
}

local function AddWindowRows(root)
	root:CreateTitle(L["BUFF_DUTY_SHOW_HEADER"])
	for _, row in ipairs(WINDOW_ROWS) do
		local key = row[1]
		Checkbox(root, L[row[2]], L[row[3]], function()
			return Settings()[key] and true or false
		end, function(value)
			Settings()[key] = value
		end)
	end
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
		local remembered = settings.menuSelfRefresh and settings.menuSelfRefresh[key]
		settings.selfRefresh[key] = remembered or Data.SELF_REFRESH_MISSING
	elseif current ~= Data.SELF_REFRESH_OFF then
		settings.menuSelfRefresh = settings.menuSelfRefresh or {}
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

local function AddConsumableRows(root)
	local list = { unpack(BuffDuty.selfItemEntries) }
	local _, playerClass = UnitClass("player")
	local stone = BuffDuty.soulstoneEntry
	if stone and stone.row.class == playerClass then
		list[#list + 1] = stone
	end
	if not list[1] then
		return
	end
	root:CreateSpacer(ns.MenuKit.MENU_GAP)
	root:CreateTitle(L["BUFF_DUTY_SELF_ITEMS_HEADER"])
	for _, entry in ipairs(list) do
		local key, name = entry.key, ConsumableName(entry)
		Checkbox(root, name, entry.desc or L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"]:format(name), function()
			return SelfRefreshOn(key)
		end, function(value)
			SetSelfRefresh(key, value)
		end)
	end
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
local function WeaponRow(root, entry, list, hands, handKey)
	local name = WeaponName(entry)
	Checkbox(root, name, L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"]:format(name), function()
		for _, hand in ipairs(hands) do
			if BuffDuty.WeaponChoiceOn(list(), handKey(hand), entry.key) then
				return true
			end
		end
		return false
	end, function(value)
		local settings = list()
		for _, hand in ipairs(hands) do
			local key = handKey(hand)
			settings[key] = settings[key] or {}
			settings[key][entry.key] = value
		end
	end)
end

--[[
    Your class's choices, sorted by name, then the oils, stones and lures you
    carry. The panel lists every one there is; the menu keeps to what the
    window could offer you now.
]]
local function AddWeaponRows(root)
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

	root:CreateSpacer(ns.MenuKit.MENU_GAP)
	root:CreateTitle(L["BUFF_DUTY_WEAPON_PANEL_HEADER"])
	local function Picks()
		return Settings().weaponPicks
	end
	local function Items()
		return Settings().weaponItems
	end
	local classHands = ns.BUFF_DUTY_WEAPON_HANDS and ns.BUFF_DUTY_WEAPON_HANDS[playerClass] or {}
	for _, entry in ipairs(spells) do
		WeaponRow(root, entry, Picks, classHands, function(hand)
			return playerClass .. "_" .. hand
		end)
	end
	for _, entry in ipairs(items) do
		local hands = Data.WEAPON_ITEM_KIND_HANDS[entry.kind] or Data.WEAPON_HAND_ORDER
		WeaponRow(root, entry, Items, hands, function(hand)
			return hand
		end)
	end
end

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

function ns.OpenBuffDutyOptionsMenu(owner)
	ns.MenuKit.OpenContextMenu(owner, function(_, root)
		AddWindowRows(root)
		AddConsumableRows(root)
		AddWeaponRows(root)
		root:CreateDivider()
		local settings = root:CreateButton(L["BUFF_DUTY_MENU_ALL_SETTINGS"], function()
			ns:OpenOptionsPanel("BuffDuty")
		end)
		SetTip(settings, L["BUFF_DUTY_MENU_ALL_SETTINGS"], L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"])
	end)
end
