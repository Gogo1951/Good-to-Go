local _, ns = ...
local L = ns.L

-- Shared with the footer's list controls.
local BAR_HEIGHT = 22
local BAR_INSET_LEFT = 16 -- past the portrait's clearance
local BAR_INSET_RIGHT = 16
ns.RESTOCK_BAR_HEIGHT = BAR_HEIGHT
ns.RESTOCK_BAR_INSET_RIGHT = BAR_INSET_RIGHT

--[[
    A text box reports no click, so a drop is taken on mouse-up or drag release.
    That click focused the box, so focus goes back to the game after.
]]
local function SetBoxTakesDrops(box)
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	box:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			TakeDroppedItem(self)
		end
	end)
	box:SetScript("OnReceiveDrag", TakeDroppedItem)
end

local EDIT_BOX_HEIGHT = 16 -- all three fields, shorter than the header's buttons so they center beside them
--[[
    Each field is only as wide as its job, so the header fits at the narrowest
    window; the add hint and its notices are kept to a phrase for that reason.
    Slack collects between the filter and the adders.
]]
local FILTER_BOX_WIDTH = 160
local BAG_MENU_WIDTH = 160
local ADD_BOX_WIDTH = 160
-- An InputBoxTemplate border draws about 4px left of its edge (measured on Forever), eating into this.
local CONTROL_ITEM_GAP = 16
local ADD_BUTTON_WIDTH = 64
local STAPLES_GAP = 8 -- between the header's buttons, and between the add box and Add

--[[
    Without SearchBoxTemplate, the plain filter draws its pieces itself. The
    clear mark is the group-loot pass the rows use for removal, so removal looks
    the same everywhere.
]]
local ROW_ICON_SIZE = 16
local ROW_ICON_GAP = 8
local FILTER_ICON = "Interface\\Common\\UI-Searchbox-Icon"
local CLEAR_BUTTON_SIZE = 16
local CLEAR_BUTTON_INSET = 4
local CLEAR_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local CLEAR_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

-- The adders run left to right from least typing to most: bags, add box, then Pick Staples.

-- The category pane's counts answer to the filter too, not just the rows.
local function ApplyFilter(text)
	ns.restockListFilter = text
	ns.UpdateRestockList()
end

local function CreateSearchFilterBox(bar)
	local box = CreateFrame("EditBox", nil, bar, "SearchBoxTemplate")
	box:SetSize(FILTER_BOX_WIDTH, EDIT_BOX_HEIGHT)
	box:SetPoint("LEFT", bar, "LEFT", 0, 0)
	box:SetAutoFocus(false)
	local hint = box.Instructions
	-- White reads on the dark box ElvUI and the default art both give it.
	if hint then
		hint:SetText(L["RESTOCKER_FILTER_PLACEHOLDER"])
		local white = ns.COLORS_RGB.TEXT
		hint:SetTextColor(white.r, white.g, white.b)
	end
	box:HookScript("OnTextChanged", function(self)
		ApplyFilter(self:GetText() or "")
	end)
	return box
end

local function CreatePlainFilterBox(bar)
	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
	icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
	icon:SetTexture(FILTER_ICON)

	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", icon, "RIGHT", ROW_ICON_GAP, 0)
	box:SetSize(FILTER_BOX_WIDTH, EDIT_BOX_HEIGHT)
	box:SetAutoFocus(false)
	-- Keep typed text off the clear button below; the placeholder never meets it.
	box:SetTextInsets(0, CLEAR_BUTTON_SIZE + CLEAR_BUTTON_INSET, 0, 0)

	-- Only blanks the text: OnTextChanged empties the filter, so the two ways out can't drift.
	local clearButton = CreateFrame("Button", nil, box)
	clearButton:SetSize(CLEAR_BUTTON_SIZE, CLEAR_BUTTON_SIZE)
	clearButton:SetPoint("RIGHT", box, "RIGHT", -CLEAR_BUTTON_INSET, 0)
	clearButton:SetNormalTexture(CLEAR_ICON)
	clearButton:SetPushedTexture(CLEAR_ICON_DOWN)
	clearButton:SetHighlightTexture(CLEAR_ICON, "ADD")
	clearButton:Hide()
	ns.SetRestockControlClick(clearButton, function()
		box:SetText("")
		box:ClearFocus()
	end)
	ns.SetupRestockerTooltip(clearButton, L["RESTOCKER_FILTER_CLEAR_TOOLTIP"])

	--[[
	    A placeholder is a FontString, so nothing clips it: anchored on both sides,
	    a long hint truncates inside the field instead of running over its neighbor.
	]]
	local placeholder = box:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisable")
	placeholder:SetPoint("LEFT", box, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", box, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_FILTER_PLACEHOLDER"])

	box:SetScript("OnTextChanged", function(self)
		local text = self:GetText() or ""
		placeholder:SetShown(text == "")
		clearButton:SetShown(text ~= "")
		ApplyFilter(text)
	end)
	box:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	return box
end

local function CreateFilterBox(addonFrame, bar)
	local box = ns.HasTemplate("SearchBoxTemplate") and CreateSearchFilterBox(bar) or CreatePlainFilterBox(bar)
	box:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	SetBoxTakesDrops(box)
	addonFrame.filterBox = box
	return box
end

-- Here too, so Staples is a tool to come back to rather than a greeting caught or missed.
local function CreateStaplesButton(header)
	local button = ns.CreateRestockerHeaderButton(header, L["RESTOCKER_PICK_STAPLES_BUTTON"])
	button:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_PICK_STAPLES_BUTTON"], L["RESTOCKER_PICK_STAPLES_TOOLTIP"])
	header.staplesButton = button
end

-- Controls are children of the bar: one on the window lands mid-window, behind the list.
function ns.CreateRestockHeader(addonFrame)
	local bands = ns.RESTOCK_WINDOW_BANDS
	local top = ns.RESTOCK_HEADER_CENTER_Y + BAR_HEIGHT / 2
	local header = CreateFrame("Frame", nil, addonFrame)
	header:SetPoint("TOPLEFT", addonFrame, "TOPLEFT", bands.CONTROLS_LEFT + BAR_INSET_LEFT, top)
	header:SetPoint("TOPRIGHT", addonFrame, "TOPRIGHT", -BAR_INSET_RIGHT, top)
	header:SetHeight(BAR_HEIGHT)
	header.leading = CreateFilterBox(addonFrame, header)
	CreateStaplesButton(header)

	addonFrame.header = header
	return header
end

local function CreateAddButton(addonFrame, header)
	local addButton = ns.CreateRestockerHeaderButton(header, L["RESTOCKER_ADD_BUTTON"])
	addButton:SetPoint("RIGHT", header.staplesButton, "LEFT", -STAPLES_GAP, 0)
	addButton:SetWidth(math.max(ADD_BUTTON_WIDTH, addButton:GetWidth()))
	-- Captured, never found through GetParent: the box isn't this button's child.
	ns.SetRestockControlClick(addButton, function()
		local editBox = addonFrame.editBox
		local text = editBox:GetText()

		ns.AddRestockItem(text)

		editBox:SetText("")
		editBox:ClearFocus()
	end)
	-- The box's tooltip: the two are halves of one control.
	ns.SetupRestockerTooltip(addButton, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.addButton = addButton
	return addButton
end

ns.CreateRestockAddButton = CreateAddButton

-- The placeholder doubles as the notice line; its own tone is read back from its font.
local NOTICE_TONE = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ADD_NOTICE)
local placeholderTone

local function CreateEditBox(addonFrame, header)
	local editBox = CreateFrame("EditBox", nil, header, "InputBoxTemplate")
	-- Spaced, not flush: the border arts would clash.
	editBox:SetPoint("RIGHT", addonFrame.addButton, "LEFT", -STAPLES_GAP, 0)
	editBox:SetWidth(ADD_BOX_WIDTH)
	editBox:SetAutoFocus(false)
	editBox:SetHeight(EDIT_BOX_HEIGHT)
	--[[
	    No Shift + Click insert: it routes through ChatFrameUtil.InsertLink, which
	    can't be claimed without overwriting a Blizzard function.
	]]
	editBox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		ns.AddRestockItem(text)
		self:SetText("")
		self:ClearFocus()
	end)
	SetBoxTakesDrops(editBox)

	-- Anchored on both sides like the filter's: the longest hint here, and what ADD_BOX_WIDTH fits.
	local placeholder = editBox:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisable")
	placeholder:SetPoint("LEFT", editBox, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", editBox, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	addonFrame.addPlaceholder = placeholder
	placeholderTone = { placeholder:GetTextColor() }
	editBox:SetScript("OnTextChanged", function(self)
		local isEmpty = (self:GetText() or "") == ""
		-- Not on emptying: both add paths empty the box right after raising a notice.
		if not isEmpty then
			ns.ClearRestockAddNotice()
		end
		placeholder:SetShown(isEmpty)
	end)

	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.editBox = editBox
	return editBox
end

ns.CreateRestockAddBox = CreateEditBox

local function PlaceBagMenu(addonFrame, header)
	local bagMenu = ns.CreateRestockBagMenu(addonFrame, header)
	bagMenu:SetPoint("RIGHT", addonFrame.editBox, "LEFT", -CONTROL_ITEM_GAP, 0)
	bagMenu:SetSize(BAG_MENU_WIDTH, EDIT_BOX_HEIGHT)
	addonFrame.bagMenu = bagMenu
	return bagMenu
end

ns.PlaceRestockBagMenu = PlaceBagMenu

--------------------------------------------------------------------------------
-- Add Notices
--------------------------------------------------------------------------------

--[[
    Said in the add box, where the player is looking; a chat line is easy to
    miss behind the window. Chat only while the window is shut.
]]
local addNoticeShown = false

function ns.ShowRestockAddNotice(message)
	local window = ns.restockWindow
	if not (window and window:IsShown()) then
		ns:PrintMessage(message)
		return
	end
	addNoticeShown = true
	window.addPlaceholder:SetText(message)
	window.addPlaceholder:SetTextColor(NOTICE_TONE.r, NOTICE_TONE.g, NOTICE_TONE.b)
end

function ns.ClearRestockAddNotice()
	if not addNoticeShown then
		return
	end
	addNoticeShown = false
	local placeholder = ns.restockWindow.addPlaceholder
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	placeholder:SetTextColor(unpack(placeholderTone))
end
