local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- List Bar
--------------------------------------------------------------------------------

--[[
    Header:  [filter] ...... [Add Item From Bags v]  [add box....] [Add] [Pick Staples]
    Footer:  List [selector....v] [Manage Lists] Used by Mossbark, Thornhoof ...   (the orders, at the right)

      Restocker-Window-Header.lua   the whole header: the bar, the filter, the
                                    bag menu's place, the add box, Add, and
                                    Pick Staples (the bag menu itself is
                                    Restocker-Window-Bag-Menu.lua's)
      this file                     the footer's list controls: the label, the
                                    selector and "Used by"
      Restocker-Window-List-Manage.lua
                                    Manage Lists, its menu and Delete confirm,
                                    and the rename field with its two buttons
      Restocker-Window-Footer.lua   the orders at the footer's right

    The window's list management lives along the bottom-left of its footer:
    which Restock List this character is on, the button that acts on a whole
    list, and who else is on it.

    "Used by" is the line that makes a shared list visible. Lists are shared on
    purpose (one Druid list for every Druid), and sharing is silent everywhere
    else: nothing on a row says an edit here lands on another character too.
    It takes whatever the footer has left between Manage Lists and the orders
    at its right, and truncates first.

    New, Copy, Rename and Delete sit behind one Manage Lists button rather than
    out as four. They are rare, they act on the whole list, and Delete in
    particular should not be one stray click from the controls used every
    visit.

    The list selector is an InputBoxTemplate field, not an AceGUI Dropdown.
    Every other control in this window is a Blizzard template, so an AceGUI
    widget reads as foreign -- and skins that restyle AceGUI globally (ElvUI
    ships one) restyle it and nothing around it, moving the geometry its
    neighbors are positioned against.

    It opens the window's kit menu on click (ns.RestockMenu, in
    Restocker-Window-Menus.lua), as the reputation and column menus do:
    Blizzard's UIDropDownMenu drives shared global frames its own secure code
    uses and leaves taint behind, and the kit's frames are its own. Manage
    Lists opens the same menu.
]]
local BAR_HEIGHT = ns.RESTOCK_BAR_HEIGHT -- the header's, so the two bars match (Restocker-Window-Header.lua)
local BAR_INSET_RIGHT = ns.RESTOCK_BAR_INSET_RIGHT
local FOOTER_X = ns.RESTOCK_FOOTER_X
local LIST_SELECTOR_WIDTH = 192 -- holds a full Name-Realm, which an old list can be named
local SELECTOR_ARROW_SIZE = 16
-- The list picker and the rename box in its place, on the Spacing Scale.
ns.RESTOCK_BAR_FIELD_HEIGHT = 16
local BAR_ITEM_GAP = 16
-- Shared with the Manage Lists button and the rename field (Restocker-Window-List-Manage.lua).
ns.RESTOCK_LIST_SELECTOR_WIDTH = LIST_SELECTOR_WIDTH
ns.RESTOCK_LIST_BAR_ITEM_GAP = BAR_ITEM_GAP

--------------------------------------------------------------------------------
-- Used By
--------------------------------------------------------------------------------

--[[
    A list's characters as one run of text, each name in its class color, or
    nil when no character is on it. A character is its class color wherever the
    add-on names one (the Inventory Report does the same), which is what lets a
    list's line be read at a glance.

    plain is the color the run sits in. It draws the separators, and any name
    whose class the add-on has not recorded yet (ns.GetRestockListUsers), so
    each caller says what an uncolored name looks like beside its own text.
]]
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

-- Also names the other characters in the Delete confirm (Restocker-Window-List-Manage.lua).
ns.JoinRestockListUsers = JoinUsers

--[[
    The bar's "Used by" line for the list in use. Normally this character is among
    them, since the window shows the list it is on; a character whose key changed
    mid-session (a placeholder name resolved late) can leave it empty, which reads
    as no names rather than an error.
]]
local function UsedByText(listName)
	local names = JoinUsers(ns.GetRestockListUsers(listName), GetColor("TEXT")) or ""
	-- Muted is opened again behind the names, for whatever a locale's wording puts after them.
	return GetColor("MUTED") .. string.format(L["RESTOCKER_USED_BY"], names .. GetColor("MUTED")) .. "|r"
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

--[[
    The list menu and Manage Lists' menu (Restocker-Window-List-Manage.lua)
    both open the window's one kit menu, so only one is ever up. Each closes
    it only while it is open for its own anchor, so closing this one never
    shuts a menu something else opened.
]]
local listAnchor

local function CloseListMenus()
	if listAnchor and ns.RestockMenu:IsOpenFor(listAnchor) then
		ns.RestockMenu:Close()
	end
end

ns.CloseRestockListMenus = CloseListMenus

--[[
    The selector's menu: every saved list with the characters on it, then a
    rule, then New List.

    Rebuilt on every open rather than cached, so a rename or a delete needs
    nothing kept in sync -- the next open reads the lists as they now are.

    The characters ride on each row's right because they are what a list's name
    leaves out: "Druid" and "Druid (2)" say nothing about whose each one is,
    and switching onto a list another character uses means editing theirs.
    Each is in its class color, and muted until its class is known, so a name
    never reads as part of the list's own, which is white.
]]
local function OpenListPullout(anchor)
	local settings = ns.restockSettings
	-- No header: the selector names the list (Style Guide → MENUS).
	local entries = {}

	-- In the shared A-to-Z order, whose first entry is also where a delete lands (ns.GetRestockListAfterDelete).
	for _, name in ipairs(ns.GetRestockListNames()) do
		local users = JoinUsers(ns.GetRestockListUsers(name), GetColor("MUTED"))
		entries[#entries + 1] = ns.RestockChoiceRow(name, users, name == settings.currentList, function()
			-- The list already in use only closes the menu: a switch would clear New and rerun the restock.
			if name ~= ns.restockSettings.currentList then
				ns.SwitchRestockList(name)
			end
		end)
	end

	-- A gap and a rule between the lists and the action under them.
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
	-- Opening upward: the selector sits in the footer, so a menu below it would leave the window.
	ns.RestockMenu:Open(anchor, entries, nil, true)
end

-- The selector and its arrow open the menu, and close it again when it is already open.
local function ToggleListPullout(anchor)
	if ns.RestockMenu:IsOpenFor(anchor) then
		ns.RestockMenu:Close()
		return
	end
	-- One menu at a time: each open clears the rest.
	ns.CloseRestockMenus()
	OpenListPullout(anchor)
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

--[[
    The closed selector: the window's menu field (ns.CreateRestockMenuField in
    Restocker-Window-Widgets.lua), showing the active list as its text.
]]
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

--[[
    Anchored on both sides with no wrap, the way a row's item name is: the line
    takes the room between Manage Lists and the footer's orders, and a list
    with more characters than fit truncates instead of running under them.
    ns.SetRestockUsersLineEnd moves its right end as the orders change width.
]]
local function CreateUsersLine(bar)
	local users = bar:CreateFontString(nil, "OVERLAY")
	users:SetFontObject("GameFontHighlightSmall")
	users:SetJustifyH("LEFT")
	users:SetWordWrap(false)
	users:SetPoint("LEFT", bar.manageButton, "RIGHT", BAR_ITEM_GAP, 0)
	users:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	bar.users = users
end

-- Ends the "Used by" line short of edge, the leftmost thing on the footer's right; nil ends it at the footer's end.
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

--[[
    Show the active list and its characters, ending any rename in progress.
    Called whenever a list is added, renamed, copied, deleted or switched
    (ns.UpdateRestockListWidgets in Restocker-Saved-Lists.lua).
]]
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

--[[
    The footer's list controls in one call, so Restocker-Window.lua assembles
    the window from parts (the header is ns.CreateRestockHeader's, in
    Restocker-Window-Header.lua). Returns the bar, which is also
    addonFrame.listBar.

    Every control is a child of the bar, never of the window: a control
    anchored to the window lands at its middle and disappears behind the list.
]]
function ns.CreateRestockListBar(addonFrame)
	-- The footer's left run, 8 up from the window's bottom edge, level with the Short on line (Restocker-Window-Footer.lua).
	local bottom = 8
	local bar = CreateFrame("Frame", nil, addonFrame)
	bar:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, bottom)
	bar:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -BAR_INSET_RIGHT, bottom)
	bar:SetHeight(BAR_HEIGHT)
	CreateListSelector(bar)
	ns.CreateRestockManageControls(bar)
	CreateUsersLine(bar)
	ns.SetRestockRenameShown(bar, false)

	--[[
	    Painted by hand this once: ns.RefreshRestockListBar reads the bar back off
	    ns.restockWindow, which is not set until the whole window is assembled.
	]]
	local listName = ns.restockSettings.currentList or ""
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))

	addonFrame.listBar = bar
	return bar
end
