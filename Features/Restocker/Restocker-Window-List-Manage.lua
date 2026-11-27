local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local JoinUsers = ns.JoinRestockListUsers

local LIST_SELECTOR_WIDTH = ns.RESTOCK_LIST_SELECTOR_WIDTH
local BAR_ITEM_GAP = ns.RESTOCK_LIST_BAR_ITEM_GAP
local BUTTON_GAP = 4

local manageAnchor

local function CloseManageMenu()
	if manageAnchor and ns.RestockMenu:IsOpenFor(manageAnchor) then
		ns.RestockMenu:Close()
	end
end

ns.CloseRestockManageMenu = CloseManageMenu

--------------------------------------------------------------------------------
-- Delete
--------------------------------------------------------------------------------

--[[
    OnAccept deletes the name carried as the dialog's data, never currentList:
    the dialog doesn't lock the window, so a switch while it is open would
    redirect a delete that has no undo.
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
    Names, before the player agrees, the other characters who will log in to an
    empty list of that name, and where this one lands, which may be another
    character's list.
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

-- Also asked by /restock profile delete.
function ns.ConfirmDeleteRestockList(listName)
	if not listName then
		return
	end
	StaticPopup_Show("GOODTOGO_RESTOCKER_DELETE_LIST", DeleteConfirmText(listName), nil, listName)
end

-- /restock profile copy has no undo. The target rides in the data, so a switch meanwhile copies nothing.
StaticPopupDialogs["GOODTOGO_RESTOCKER_COPY_LIST"] = {
	text = "%s",
	button1 = L["RESTOCKER_REPLACE"],
	button2 = CANCEL,
	OnAccept = function(_self, data)
		if data and ns.restockSettings.currentList == data.target then
			ns.CopyIntoCurrentRestockList(data.source)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function ns.ConfirmCopyIntoCurrentRestockList(listToCopy)
	local target = ns.restockSettings.currentList
	if listToCopy == target then
		ns.CopyIntoCurrentRestockList(listToCopy)
		return
	end
	local gold = GetColor("TITLE")
	local text = string.format(L["RESTOCKER_PROFILE_COPY_CONFIRM"], gold .. target .. "|r", gold .. listToCopy .. "|r")
	local others = ns.GetRestockListUsers(target, true)
	if #others > 0 then
		text = text
			.. " "
			.. string.format(
				L["RESTOCKER_PROFILE_COPY_CONFIRM_ALSO_USED_BY"],
				gold .. target .. "|r",
				JoinUsers(others, GetColor("TEXT"))
			)
	end
	StaticPopup_Show("GOODTOGO_RESTOCKER_COPY_LIST", text, nil, { source = listToCopy, target = target })
end

local function ConfirmDeleteCurrentList()
	ns.ConfirmDeleteRestockList(ns.restockSettings.currentList)
end

--------------------------------------------------------------------------------
-- Manage Lists Menu
--------------------------------------------------------------------------------

-- Delete sits under a rule of its own, as destructive entries do in the game's menus.
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
	local entries = {
		{ kind = "header", left = L["RESTOCKER_MANAGE"], right = L["ADDON_SHORT_NAME"] },
	}
	for _, entry in ipairs(MANAGE_ENTRIES) do
		if entry.isRule then
			entries[#entries + 1] = { kind = "spacer" }
			entries[#entries + 1] = { kind = "separator" }
		else
			local row = { kind = "action", left = L[entry.label], onClick = entry.run }
			if entry.run == ConfirmDeleteCurrentList then
				local users = ns.GetRestockListUsers(ns.restockSettings.currentList)
				row.right = string.format(L["RESTOCKER_LIST_USED_BY_COUNT"], #users)
			end
			entries[#entries + 1] = row
		end
	end

	manageAnchor = anchor
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	ns.RestockMenu:Open(anchor, entries, nil, true, "click")
end

local function ToggleManagePullout(anchor)
	if ns.RestockMenu:IsOpenFor(anchor) then
		ns.RestockMenu:Close()
		return
	end
	ns.CloseRestockMenus()
	OpenManagePullout(anchor)
end

--------------------------------------------------------------------------------
-- Rename
--------------------------------------------------------------------------------

--[[
    The field exists only during a rename, so its text is never mistaken for the
    list's name. A Button click doesn't take focus from an EditBox, so pressing
    Rename doesn't trip the focus-loss discard. Clicking away only ends
    the rename; only Escape and Cancel take a made list back.
]]
local isRenaming = false
local madeFromList

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

local function CancelRename()
	local previousList = madeFromList
	EndRename()
	if previousList then
		ns.DiscardMadeRestockList(previousList)
	end
end

-- previousList: the list before New List or Copy; nil for a plain rename.
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

local function CreateManageButton(bar)
	local button = ns.CreateRestockerHeaderButton(bar, L["RESTOCKER_MANAGE"])
	button:SetPoint("LEFT", bar.selector, "RIGHT", BAR_ITEM_GAP, 0)
	ns.SetRestockControlClick(button, function(self)
		ToggleManagePullout(self)
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_MANAGE"], L["RESTOCKER_MANAGE_TOOLTIP"])
	bar.manageButton = button
end

local function CreateRenameControls(bar)
	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", bar.label, "RIGHT", BAR_ITEM_GAP, 0)
	box:SetWidth(LIST_SELECTOR_WIDTH)
	box:SetHeight(ns.RESTOCK_BAR_FIELD_HEIGHT)
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

function ns.CreateRestockManageControls(bar)
	CreateManageButton(bar)
	CreateRenameControls(bar)
end
