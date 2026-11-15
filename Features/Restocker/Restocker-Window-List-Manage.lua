local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local AceGUI = LibStub("AceGUI-3.0")

local JoinUsers = ns.JoinRestockListUsers

--[[
    The Restock window footer's Manage Lists button and what hangs off it:
    its menu (New, Copy, Rename, Delete), the Delete confirm, and the rename
    field with its Rename and Cancel buttons, which take the list selector's
    place while a rename is under way. Restocker-Window-List-Bar.lua builds
    the rest of the footer's list controls and places these among them.
]]
local LIST_SELECTOR_WIDTH = ns.RESTOCK_LIST_SELECTOR_WIDTH
local BAR_ITEM_GAP = ns.RESTOCK_LIST_BAR_ITEM_GAP
local BUTTON_GAP = 4
local MANAGE_MENU_WIDTH = 288 -- holds "Copy This List into a New One" whole

-- Built on first use and reused, as the list menu's pullout is (Restocker-Window-List-Bar.lua).
local managePullout
local managePulloutOpen = false

local function CloseManageMenu()
	if managePullout and managePulloutOpen then
		managePulloutOpen = false
		managePullout:Close()
	end
end

ns.CloseRestockManageMenu = CloseManageMenu

--------------------------------------------------------------------------------
-- Delete
--------------------------------------------------------------------------------

--[[
    Confirmation for the Manage Lists menu's Delete. The whole message is composed at show
    time and handed in as text_arg1, because how much it has to say depends on
    the list: who else is on it, and the list this character lands on
    afterward. StaticPopup_Show's fourth argument carries the list's name
    through as the dialog's data, and OnAccept deletes THAT name rather than
    re-reading currentList.

    Load-bearing: the dialog does not lock the window behind it, so a list
    switched in the selector while the confirm is open would otherwise redirect
    the delete onto a list the player was never asked about -- and a Restock
    List has no undo. ns.DeleteRestockList ignores a nil or already-deleted
    name, and moves the character only when the list deleted is the one in use.
]]
StaticPopupDialogs["GOODTOGO_RESTOCKER_DELETE_LIST"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(_self, data)
		ns.DeleteRestockList(data)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

--[[
    What the confirm says, a paragraph to a fact: the question, the list's name
    in gold, what happens next, and that it is final.

    "What happens next" must be said before the player agrees. Every other
    character pointed at the list starts its next login on an empty list of the
    same name (ns.InitializeCharacterRestockList recreates a missing one), so they are
    named here while the player can still say no. This character's own landing
    place is named with them: the top list, which may be one another character
    uses and so is worth seeing before agreeing, or -- when this is the last
    list -- a new, empty one.
]]
local function DeleteConfirmText(listName)
	local consequences = {}
	local others = ns.GetRestockListUsers(listName, true)
	if #others > 0 then
		local key = (#others == 1) and "RESTOCKER_DELETE_LIST_SHARED_ONE" or "RESTOCKER_DELETE_LIST_SHARED_MANY"
		consequences[#consequences + 1] = string.format(L[key], JoinUsers(others, GetColor("TEXT")))
	end
	local landing = ns.GetRestockListAfterDelete(listName)
	if landing then
		consequences[#consequences + 1] =
			string.format(L["RESTOCKER_DELETE_LIST_SWITCH"], GetColor("TITLE") .. landing .. "|r")
	else
		consequences[#consequences + 1] = L["RESTOCKER_DELETE_LIST_LAST"]
	end

	return table.concat({
		L["RESTOCKER_DELETE_LIST_QUESTION"],
		GetColor("TITLE") .. listName .. "|r",
		table.concat(consequences, " "),
		L["RESTOCKER_DELETE_LIST_FINAL"],
	}, "|n|n")
end

local function ConfirmDeleteCurrentList()
	local listName = ns.restockSettings.currentList
	if not listName then
		return
	end
	StaticPopup_Show("GOODTOGO_RESTOCKER_DELETE_LIST", DeleteConfirmText(listName), nil, listName)
end

--------------------------------------------------------------------------------
-- Manage Lists Menu
--------------------------------------------------------------------------------

--[[
    Every entry is an Execute: each performs an action and closes the menu.
    Delete sits under a rule of its own, the way a destructive entry does in
    the game's own menus.
]]
local MANAGE_ENTRIES = {
	{
		label = "RESTOCKER_NEW_PROFILE",
		run = function()
			ns.CreateRestockList()
		end,
	},
	{
		label = "RESTOCKER_MANAGE_COPY",
		run = function()
			ns.CloneCurrentRestockList()
		end,
	},
	{
		label = "RESTOCKER_RENAME_PROFILE",
		run = function()
			ns.BeginRestockListRename()
		end,
	},
	{ isRule = true },
	{ label = "RESTOCKER_MANAGE_DELETE", run = ConfirmDeleteCurrentList },
}

local function OpenManagePullout(anchor)
	if not managePullout then
		managePullout = AceGUI:Create("Dropdown-Pullout")
		managePullout:SetCallback("OnClose", function()
			managePulloutOpen = false
		end)
	end
	managePullout:Clear()

	for _, entry in ipairs(MANAGE_ENTRIES) do
		if entry.isRule then
			managePullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))
		else
			local item = AceGUI:Create("Dropdown-Item-Execute")
			item:SetText(L[entry.label])
			item:SetCallback("OnClick", entry.run)
			managePullout:AddItem(item)
		end
	end

	managePulloutOpen = true
	managePullout:SetWidth(MANAGE_MENU_WIDTH)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	-- Opening upward, as the list menu does from the footer.
	managePullout:Open("BOTTOMLEFT", anchor, "TOPLEFT", 0, 0)
end

local function ToggleManagePullout(anchor)
	if managePulloutOpen then
		CloseManageMenu()
		return
	end
	ns.CloseRestockMenus()
	OpenManagePullout(anchor)
end

--------------------------------------------------------------------------------
-- Rename
--------------------------------------------------------------------------------

--[[
    Renaming swaps the selector for a field holding the list's name, selected
    and ready to type over, with Rename and Cancel beside it. The field exists
    only while a rename is under way, so text sitting in it can never be
    mistaken for the name the list actually has.

    Enter and the Rename button commit. Escape, Cancel and clicking away
    discard, and so does any list event, since ns.RefreshRestockListBar ends
    the rename before it repaints. A Button click does not pull keyboard focus
    off an EditBox, so pressing Rename does not trip the discard -- its OnClick
    reads what was typed.

    New List and Copy both land here: each makes a list under a generated name
    and opens the rename over it, so the real name is one line of typing away.
    They pass the list the character was on, and Escape or Cancel then takes
    the made list back off and returns there, so backing out of a new list
    leaves nothing behind -- unless something was put on it meanwhile, which
    keeps it (ns.DiscardMadeRestockList). Clicking away only ends the rename and keeps the
    list under its generated name, the way it keeps a plain rename's old name.
]]
local isRenaming = false
local madeFromList

-- The rename field and its buttons take the selector's place and Manage Lists' room; "Used by" steps aside too.
local function SetRenameShown(bar, shown)
	bar.selector:SetShown(not shown)
	bar.manageButton:SetShown(not shown)
	bar.users:SetShown(not shown)
	bar.renameBox:SetShown(shown)
	bar.renameButton:SetShown(shown)
	bar.cancelButton:SetShown(shown)
end

ns.SetRestockRenameShown = SetRenameShown

local function EndRename()
	if not isRenaming then
		return
	end
	isRenaming = false
	madeFromList = nil
	SetRenameShown(ns.restockWindow.listBar, false)
end

ns.EndRestockListRename = EndRename

-- Escape and Cancel: a list New List or Copy just made, still as made, goes again, and the character returns to its list.
local function CancelRename()
	local previousList = madeFromList
	EndRename()
	if previousList then
		ns.DiscardMadeRestockList(previousList)
	end
end

-- previousList is the list the character was on when New List or Copy made the current one; nil for a plain rename.
function ns.BeginRestockListRename(previousList)
	local bar = ns.restockWindow.listBar
	ns.CloseRestockMenus()
	isRenaming = true
	madeFromList = previousList
	SetRenameShown(bar, true)
	bar.renameBox:SetText(ns.restockSettings.currentList or "")
	bar.renameBox:SetFocus()
	bar.renameBox:HighlightText()
end

-- Every path through ns.RenameCurrentRestockList repaints the bar, which ends the rename.
local function CommitRename()
	ns.RenameCurrentRestockList(ns.restockWindow.listBar.renameBox:GetText())
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

-- Beside the selector, the list it acts on.
local function CreateManageButton(bar)
	local button = ns.CreateRestockerHeaderButton(bar, L["RESTOCKER_MANAGE"])
	button:SetPoint("LEFT", bar.selector, "RIGHT", BAR_ITEM_GAP, 0)
	ns.SetRestockControlClick(button, function(self)
		ToggleManagePullout(self)
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_MANAGE"], L["RESTOCKER_MANAGE_TOOLTIP"])
	bar.manageButton = button
end

-- The rename field and its two buttons, in the selector's place; hidden until a rename begins.
local function CreateRenameControls(bar)
	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", bar.label, "RIGHT", BAR_ITEM_GAP, 0)
	box:SetWidth(LIST_SELECTOR_WIDTH)
	box:SetHeight(20)
	box:SetAutoFocus(false)
	box:SetScript("OnEnterPressed", CommitRename)
	box:SetScript("OnEscapePressed", CancelRename)
	box:SetScript("OnEditFocusLost", EndRename)

	local renameButton = ns.CreateRestockerHeaderButton(bar, L["RESTOCKER_RENAME_LABEL"])
	renameButton:SetPoint("LEFT", box, "RIGHT", BUTTON_GAP + 4, 0)
	ns.SetRestockControlClick(renameButton, CommitRename)
	ns.SetupRestockerTooltip(renameButton, L["RESTOCKER_RENAME_LABEL"], L["RESTOCKER_RENAME_TOOLTIP"])

	local cancelButton = ns.CreateRestockerHeaderButton(bar, CANCEL)
	cancelButton:SetPoint("LEFT", renameButton, "RIGHT", BUTTON_GAP, 0)
	ns.SetRestockControlClick(cancelButton, CancelRename)

	bar.renameBox = box
	bar.renameButton = renameButton
	bar.cancelButton = cancelButton
end

-- Manage Lists beside the selector, and the rename field with its buttons; Restocker-Window-List-Bar.lua places the rest.
function ns.CreateRestockManageControls(bar)
	CreateManageButton(bar)
	CreateRenameControls(bar)
end
