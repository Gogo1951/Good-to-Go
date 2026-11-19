local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff-Duty-Options-Menu -- the flyout the Options line at the foot of the
    Buff Duty window opens (Buff-Duty-Frame.lua draws the line): the window's
    own switches, without a trip to the settings panel. A Menu Kit panel, the
    one the mini-map menu's flyouts are, so it opens on hover beside its line
    and closes a moment after the cursor leaves both.

      Show in Window   the rows the Buff Duty panel turns on and off
      Consumables      the Self-Buffs panel's Consumables box, and your
                       Soulstone on a warlock
      Weapon Buffs     your class's poisons or imbues, and the oils, stones
                       and lures in your bags
      All Buff Duty Settings

    A row here is the same setting as on the panels, so each side shows what
    the other set. Every change ends in ns.RefreshBuffDuty, as a panel's does,
    and redraws the flyout.
]]

local Kit = ns.MenuKit
local BuffDuty = ns.BuffDuty
local GetItemCount = C_Item.GetItemCount

local HOVER_CLOSE_DELAY = 0.4

local flyout = Kit.CreatePanel(nil, UIParent)
local state = { owner = nil, idle = 0, openLeft = false }

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

-- A switch: flips the setting, then the window and the flyout redraw.
local function Toggle(label, desc, on, set)
	return {
		kind = "toggle",
		left = label,
		on = on,
		tooltip = desc and Tooltip(label, desc) or nil,
		onClick = function()
			set(not on)
			ns.RefreshBuffDuty()
			Render()
		end,
	}
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

local function AddWindowRows(entries)
	entries[#entries + 1] = { kind = "section", left = L["BUFF_DUTY_SHOW_HEADER"] }
	for _, row in ipairs(WINDOW_ROWS) do
		local key = row[1]
		entries[#entries + 1] = Toggle(L[row[2]], L[row[3]], Settings()[key] and true or false, function(value)
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

local function AddConsumableRows(entries)
	local list = { unpack(BuffDuty.selfItemEntries) }
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
		local desc = entry.desc or L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"]:format(name)
		entries[#entries + 1] = Toggle(name, desc, SelfRefreshOn(key), function(value)
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
local function WeaponRow(entry, list, hands, handKey)
	local name = WeaponName(entry)
	local on = false
	for _, hand in ipairs(hands) do
		if BuffDuty.WeaponChoiceOn(list, handKey(hand), entry.key) then
			on = true
		end
	end
	return Toggle(name, L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"]:format(name), on, function(value)
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
-- Flyout
--------------------------------------------------------------------------------

local function BuildEntries()
	local entries = {}
	AddWindowRows(entries)
	AddConsumableRows(entries)
	AddWeaponRows(entries)
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = L["BUFF_DUTY_MENU_ALL_SETTINGS"],
		leftColor = "INFO",
		right = L["TOOLTIP_KEY_CLICK"],
		rightColor = "MUTED",
		tooltip = Tooltip(L["BUFF_DUTY_MENU_ALL_SETTINGS"], L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"]),
		onClick = function()
			flyout:Hide()
			ns:OpenOptionsPanel("BuffDuty")
		end,
	}
	return entries
end

--[[
    Beside its line, level with it, as a mini-map flyout sits beside its
    title: past the window's right edge, or its left one when the window sits
    on the right half of the screen. gap clears the window's own padding.
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

function Render()
	if not flyout:IsShown() or not ns.db then
		return
	end
	flyout:Render(BuildEntries())
end

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

-- Closes a moment after the cursor has left the line and the flyout, or at once when the window goes.
flyout:SetScript("OnUpdate", function(self, elapsed)
	local owner = state.owner
	if not owner or not owner:IsVisible() then
		self:Hide()
		return
	end
	if Kit.IsCursorOver(owner) or Kit.IsCursorOver(self) then
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
	if GameTooltip:GetOwner() and Kit.IsInside(GameTooltip:GetOwner(), flyout) then
		GameTooltip:Hide()
	end
end)
