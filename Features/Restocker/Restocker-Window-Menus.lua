local _, ns = ...
local L = ns.L

-- One kit menu serves every Restock List menu: its own frames, never the game's shared dropdowns, which taint.

--[[
    menu:Open(anchor, entries, onClose, upward, how): a click on the open anchor
    closes it, and a row's click closes the menu unless the entry sets keepOpen.
]]
-- The kit's MENU_GAP (Features/Menu-Kit.lua), which the kit keeps to itself: a menu opens 2 points off its control.
local MENU_GAP_POINTS = 2

local function CreateDropdownMenu(name)
	local shown = { entries = nil, onClose = nil }
	local kitMenu = ns.MenuKit.CreateMenu({
		name = name,
		publish = false,
		build = function()
			return shown.entries or {}
		end,
	})
	local frame = kitMenu.frame
	frame:SetFrameStrata("FULLSCREEN_DIALOG") -- In front of the window it drops from
	frame:HookScript("OnHide", function()
		local onClose = shown.onClose
		shown.entries, shown.onClose = nil, nil
		if onClose then
			onClose()
		end
	end)

	local menu = {}

	function menu:Close()
		kitMenu:Hide()
	end

	function menu:IsOpenFor(anchor)
		return kitMenu:IsShown() and kitMenu.state.anchor == anchor
	end

	function menu:Open(anchor, entries, onClose, upward, how)
		if menu:IsOpenFor(anchor) then
			kitMenu:Hide()
			return
		end
		kitMenu:Hide()
		local list = {}
		for index, entry in ipairs(entries) do
			if entry.onClick and not entry.keepOpen and not entry.closes then
				local copy = {}
				for key, value in pairs(entry) do
					copy[key] = value
				end
				copy.closes = true
				entry = copy
			end
			list[index] = entry
		end
		shown.entries, shown.onClose = list, onClose
		kitMenu:Show(anchor, how or "hover")
		-- Straight under or over its field, not off a corner.
		frame:ClearAllPoints()
		if upward then
			frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, MENU_GAP_POINTS)
		else
			frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -MENU_GAP_POINTS)
		end
	end

	return menu
end

ns.RestockMenu = CreateDropdownMenu("GoodToGoRestockMenu")

function ns.RestockChoiceRow(left, right, selected, onClick)
	return { kind = "choice", left = left, right = right, selected = selected, onClick = onClick }
end
local RestockMenu = ns.RestockMenu
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS
local ReputationMenuText = ns.RestockReputationMenuText
local COLUMN_STATE = ns.RESTOCK_COLUMN_STATE
local CELL_NOT_APPLICABLE = ns.RESTOCK_CELL_NOT_APPLICABLE

--------------------------------------------------------------------------------
-- Reputation Menu
--------------------------------------------------------------------------------

--[[
    Pooled rows rebind on a redraw, so ns.UpdateRestockList closing this first
    is load-bearing. The pick is also pinned to the item it opened for, so a
    missed close writes nothing.
]]
local function CloseReputationMenu()
	RestockMenu:Close()
end

ns.CloseReputationMenu = CloseReputationMenu

local function OpenReputationMenu(cell, row)
	-- A click on the open menu's own cell closes it rather than reopening it.
	if RestockMenu:IsOpenFor(cell) then
		RestockMenu:Close()
		return
	end
	ns.CloseRestockMenus()

	local openedForItem = cell.item
	if not openedForItem then
		return
	end

	-- No header: the Rep field names the list (Style Guide → MENUS).
	local entries = {}
	for _, standing in ipairs(REPUTATION_STANDINGS) do
		local label, discount = ReputationMenuText(standing)
		entries[#entries + 1] = ns.RestockChoiceRow(
			label,
			discount,
			(openedForItem.reaction or 0) == standing.value,
			function()
				if cell.item == openedForItem then
					-- "Any" saves nil.
					openedForItem.reaction = (standing.value > 0) and standing.value or nil
					ns.UpdateRestockListRow(row, openedForItem)
				end
			end
		)
	end
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	RestockMenu:Open(cell, entries, nil, nil, "click")
end

ns.OpenRestockReputationMenu = OpenReputationMenu

--------------------------------------------------------------------------------
-- Column Menus
--------------------------------------------------------------------------------

-- Always an explicit boolean: nil means unset, and a column the player just set is not.
local COLUMN_SET = {
	withdraw = function(item, isOn)
		item.restockFromBank = isOn
	end,
	deposit = function(item, isOn)
		item.stashToBank = isOn
	end,
	buy = function(item, isOn)
		item.buyFromMerchant = isOn
	end,
	extra = function(item, isOn)
		item.buyExtra = isOn
	end,
	upgrade = function(item, isOn)
		item.upgrade = isOn
	end,
}

local function CloseColumnMenu()
	RestockMenu:Close()
end

ns.CloseRestockColumnMenu = CloseColumnMenu

-- Rows where the column can't apply are left out, so the count is the rows it will set.
local function CountSettableRows(key)
	local count = 0
	for _, item in ipairs(ns.GetRestockShownItems()) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			count = count + 1
		end
	end
	return count
end

-- Whether a row applies is read before the write: Extra applies only where Buy is already on.
local function SetColumnOnShownRows(key, isOn)
	for _, item in ipairs(ns.GetRestockShownItems()) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			COLUMN_SET[key](item, isOn)
		end
	end
	ns.UpdateRestockList()
end

function ns.OpenRestockColumnMenu(column, anchor)
	-- A click on the open menu's own heading closes it rather than reopening it.
	if RestockMenu:IsOpenFor(anchor) then
		RestockMenu:Close()
		return
	end
	ns.CloseRestockMenus()

	local count = CountSettableRows(column.key)
	-- No header: the column's heading names the list (Style Guide → MENUS).
	local entries = {}
	for _, choice in ipairs({
		{ label = "RESTOCKER_BULK_ON", isOn = true },
		{ label = "RESTOCKER_BULK_OFF", isOn = false },
	}) do
		entries[#entries + 1] = {
			kind = "action",
			left = L[choice.label],
			right = L["RESTOCKER_BULK_SHOWN"]:format(count),
			disabled = count == 0,
			onClick = count > 0 and function()
				SetColumnOnShownRows(column.key, choice.isOn)
			end or nil,
		}
	end
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	RestockMenu:Open(anchor, entries, nil, nil, "click")
end
