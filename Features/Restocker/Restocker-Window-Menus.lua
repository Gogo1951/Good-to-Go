local _, ns = ...
local L = ns.L

--[[
    The Restock List's two menus: the standings menu a row's reputation cell
    opens, and the menu a toggle column's heading opens to set that column on
    every row shown. The cells that open them are Restocker-Window-Cells.lua,
    the headings Restocker-Window-Column-Header.lua.

    Both are the one kit dropdown every Restock List menu shares (the list
    bar's and Manage Lists' too): its own frames, never the game's shared
    dropdown frames, so nothing here taints them. It closes 0.4 s after the
    cursor leaves it and what opened it, on Escape, on a pick, when the window
    hides, and on ns.UpdateRestockList.
]]

--[[
    The dropdown on the kit's own menu (Kit.CreateMenu), with the shape every
    Restock List control calls: menu:Open(anchor, entries, onClose, upward)
    shows entries under anchor, or over it when upward (a click on the open
    anchor again closes it); menu:Close(); and menu:IsOpenFor(anchor). A row's
    click closes the menu first, unless the entry sets keepOpen. onClose runs
    whenever it hides.
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

	function menu:Open(anchor, entries, onClose, upward)
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
		kitMenu:Show(anchor, "hover")
		--[[
		    A dropdown's list hangs straight under its field, or over it, not off
		    a corner, MENU_GAP_POINTS clear of it as every kit menu opens.
		]]
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

--[[
    A dropdown's choice: the kit's choice row, the pick light yellow with a
    check and the rest white. One with something to say beside it (a
    reputation's discount, a list's characters) is a value row dressed the same
    way, since a choice row's right side holds only the check: the pick's name
    light yellow, the rest white, the words on the right light yellow with the
    check after them once picked.
]]
function ns.RestockChoiceRow(left, right, selected, onClick)
	if not right then
		return { kind = "choice", left = left, selected = selected, onClick = onClick }
	end
	return {
		kind = "value",
		left = left,
		leftColor = selected and "VALUE" or nil,
		right = right .. (selected and " " .. ns.MenuKit.CHECK_MARK or ""),
		onClick = onClick,
	}
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
    Update closing it is the load-bearing close. Rows come from a pool, so any
    redraw can put a different item under an open menu -- and the menu has to
    be gone before that row is rebound, or a pick lands on an item the player
    never opened. The pick is pinned to the item the menu was opened for as a
    second guard, so a close that is ever missed writes nothing rather than
    writing to whatever row drifted underneath.
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
	-- One menu at a time.
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
					-- Store nil for "Any" so nothing is persisted; otherwise the standing code.
					openedForItem.reaction = (standing.value > 0) and standing.value or nil
					ns.UpdateRestockListRow(row, openedForItem)
				end
			end
		)
	end
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	RestockMenu:Open(cell, entries)
end

ns.OpenRestockReputationMenu = OpenReputationMenu

--------------------------------------------------------------------------------
-- Column Menus
--------------------------------------------------------------------------------

--[[
    Writing one flag outright, for the column menus, which set a whole column
    rather than flipping each row. Always an explicit boolean: the nil defaults
    COLUMN_STATE reads (Restocker-Window-Cells.lua) mean "unset", and a column
    the player just set is not unset.
]]
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

--[[
    A toggle column's heading opens this: switch the column on, or off, for every
    row shown. With a category picked or the filter typed in, that is "stop
    buying every quest item" in two clicks rather than one per row.

    Rows where the column cannot apply are left alone and left out of the count,
    so the number on the menu is the number of rows it will change the state of
    or confirm: an item with no upgrade ladder has nothing to switch, and Extra
    rides on Buy.

    Each row names its count on the right in light yellow; with nothing to set,
    both rows are the kit's disabled rows, gray, and do nothing.
]]
local function CloseColumnMenu()
	RestockMenu:Close()
end

ns.CloseRestockColumnMenu = CloseColumnMenu

-- How many of the rows shown this column can be set on.
local function CountSettableRows(key)
	local count = 0
	for _, item in ipairs(ns.GetRestockShownItems()) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			count = count + 1
		end
	end
	return count
end

--[[
    Set one column on every row shown. Each column writes only its own flag, and
    whether it applies is read from the row as it stands before the write: Extra
    applies only where Buy is already on.
]]
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
	RestockMenu:Open(anchor, entries)
end
