local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- List Bar
--------------------------------------------------------------------------------

--[[
    Header:  [filter] ...... [Add Item From Bags v]  [add box....] [Add] [Pick Staples]
    Footer:  List [selector....v] [Manage Lists] Used by Mossbark, Thornhoof ...   (the orders, at the right)

    "Used by" makes a shared list visible: sharing is on purpose and silent
    everywhere else. It truncates first. New, Copy, Rename and Delete hide
    behind Manage Lists so Delete is never one stray click from everyday
    controls.

    The selector is a Blizzard template, not an AceGUI Dropdown, which reads as
    foreign and which ElvUI's AceGUI skin would restyle alone, moving its
    neighbors' geometry. It opens the kit menu: UIDropDownMenu's shared frames
    leave taint.
]]
local BAR_HEIGHT = ns.RESTOCK_BAR_HEIGHT
local BAR_INSET_RIGHT = ns.RESTOCK_BAR_INSET_RIGHT
local FOOTER_X = ns.RESTOCK_FOOTER_X
local LIST_SELECTOR_WIDTH = 192 -- holds a full Name-Realm, which an old list can be named
local SELECTOR_ARROW_SIZE = 16
ns.RESTOCK_BAR_FIELD_HEIGHT = 16
local BAR_ITEM_GAP = 16
ns.RESTOCK_LIST_SELECTOR_WIDTH = LIST_SELECTOR_WIDTH
ns.RESTOCK_LIST_BAR_ITEM_GAP = BAR_ITEM_GAP

--------------------------------------------------------------------------------
-- Used By
--------------------------------------------------------------------------------

-- `plain` draws the separators and any name whose class isn't recorded yet.
local function JoinUsers(users, plain)
	if #users == 0 then
		return nil
	end
	local names = {}
	for index, user in ipairs(users) do
		names[index] = (ns.GetClassColor(user.class) or plain) .. user.name .. "|r"
	end
	return table.concat(names, plain .. L["LIST_SEPARATOR"] .. "|r")
end

ns.JoinRestockListUsers = JoinUsers

-- A key that changed mid-session (a placeholder resolved late) can leave it empty, which reads as no names.
local function UsedByText(listName)
	local names = JoinUsers(ns.GetRestockListUsers(listName), GetColor("TEXT")) or ""
	-- Muted is opened again behind the names, for whatever a locale's wording puts after them.
	return GetColor("MUTED") .. string.format(L["RESTOCKER_USED_BY"], names .. GetColor("MUTED")) .. "|r"
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

-- Closes the shared menu only while it is open for this anchor, never one something else opened.
local listAnchor

local function CloseListMenus()
	if listAnchor and ns.RestockMenu:IsOpenFor(listAnchor) then
		ns.RestockMenu:Close()
	end
end

ns.CloseRestockListMenus = CloseListMenus

--[[
    Rebuilt on every open, so nothing needs syncing. Characters ride on the
    right because a list's name doesn't say whose it is, and switching onto
    another character's list means editing theirs.
]]
local function OpenListPullout(anchor)
	local settings = ns.restockSettings
	-- No header: the selector names the list (Style Guide → MENUS).
	local entries = {}

	for _, name in ipairs(ns.GetRestockListNames()) do
		local users = JoinUsers(ns.GetRestockListUsers(name), GetColor("MUTED"))
		entries[#entries + 1] = ns.RestockChoiceRow(name, users, name == settings.currentList, function()
			-- The list already in use only closes the menu: a switch would clear New and rerun the restock.
			if name ~= ns.restockSettings.currentList then
				ns.SwitchRestockList(name)
			end
		end)
	end

	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = L["RESTOCKER_NEW_PROFILE"],
		onClick = function()
			ns.CreateRestockList()
		end,
	}

	listAnchor = anchor
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	-- Upward: below the footer would leave the window.
	ns.RestockMenu:Open(anchor, entries, nil, true, "click")
end

local function ToggleListPullout(anchor)
	if ns.RestockMenu:IsOpenFor(anchor) then
		ns.RestockMenu:Close()
		return
	end
	ns.CloseRestockMenus()
	OpenListPullout(anchor)
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

local function CreateListSelector(bar)
	local label = bar:CreateFontString(nil, "OVERLAY")
	label:SetPoint("LEFT", bar, "LEFT", 0, 0)
	label:SetFontObject("GameFontNormal")
	label:SetText(L["RESTOCKER_PROFILE_LABEL"])
	bar.label = label

	local selector = ns.CreateRestockMenuField(bar, SELECTOR_ARROW_SIZE, ToggleListPullout)
	selector:SetPoint("LEFT", label, "RIGHT", BAR_ITEM_GAP, 0)
	selector:SetWidth(LIST_SELECTOR_WIDTH)
	selector:SetHeight(ns.RESTOCK_BAR_FIELD_HEIGHT)

	ns.SetupRestockerTooltip(selector, L["RESTOCKER_PROFILE_LABEL"], L["RESTOCKER_PROFILE_TOOLTIP"])
	bar.selector = selector
end

-- Anchored on both sides with no wrap, so a long run truncates instead of running under the orders.
local function CreateUsersLine(bar)
	local users = bar:CreateFontString(nil, "OVERLAY")
	users:SetFontObject("GameFontHighlight")
	users:SetJustifyH("LEFT")
	users:SetWordWrap(false)
	users:SetPoint("LEFT", bar.manageButton, "RIGHT", BAR_ITEM_GAP, 0)
	users:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	bar.users = users
end

-- Nil ends it at the footer's end.
function ns.SetRestockUsersLineEnd(edge)
	local bar = ns.restockWindow and ns.restockWindow.listBar
	if not bar then
		return
	end
	bar.users:ClearAllPoints()
	bar.users:SetPoint("LEFT", bar.manageButton, "RIGHT", BAR_ITEM_GAP, 0)
	if edge then
		bar.users:SetPoint("RIGHT", edge, "LEFT", -BAR_ITEM_GAP * 2, 0)
	else
		bar.users:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	end
end

function ns.RefreshRestockListBar()
	local bar = ns.restockWindow.listBar
	local listName = ns.restockSettings.currentList or ""
	ns.EndRestockListRename()
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

-- Controls are children of the bar: one on the window lands mid-window, behind the list.
function ns.CreateRestockListBar(addonFrame)
	-- Level with the Short on line.
	local bottom = 8
	local bar = CreateFrame("Frame", nil, addonFrame)
	bar:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, bottom)
	bar:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -BAR_INSET_RIGHT, bottom)
	bar:SetHeight(BAR_HEIGHT)
	CreateListSelector(bar)
	ns.CreateRestockManageControls(bar)
	CreateUsersLine(bar)
	ns.SetRestockRenameShown(bar, false)

	-- By hand once: ns.RefreshRestockListBar needs ns.restockWindow, set only after assembly.
	local listName = ns.restockSettings.currentList or ""
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))

	addonFrame.listBar = bar
	return bar
end
