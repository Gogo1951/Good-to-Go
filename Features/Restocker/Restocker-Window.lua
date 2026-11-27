local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Window Geometry
--------------------------------------------------------------------------------

--[[
    Account-wide, so no profile switch moves it. MIN_WIDTH is set by the list:

      the category pane   its widest ALLOWED width (176) plus the gap (16)
      the table           598, which holds the item name at its readable floor
                          and brings the sum to 832, on the Spacing Scale
      window chrome       the inset (ns.RESTOCK_WINDOW_BANDS: 4 left, 4 right), its
                          padding (8), the scroll bar (26)

    It uses the pane's cap, so raising the cap means raising this. The header's
    floor sits about 60 pixels under it in English, room for longer captions.
    MAX_* only guards a corrupt saved value. Heights include title and header.
]]
local DEFAULT_WIDTH = 864
local DEFAULT_HEIGHT = 448
local BANDS = ns.RESTOCK_WINDOW_BANDS
local MIN_WIDTH = 176 + 16 + 598 + BANDS.INSET_LEFT + BANDS.INSET_RIGHT + 8 + 26
local MIN_HEIGHT = 304
local MAX_WIDTH = 1600
local MAX_HEIGHT = 1200

local function Clamp(value, minimum, maximum, fallback)
	value = tonumber(value)
	if not value then
		return fallback
	end
	return math.max(minimum, math.min(maximum, value))
end

--[[
	Written whole: AceDB can clear an empty framePosition at logout first.
	sizeOnly keeps the saved spot, so a never-dragged window still has none.
]]
function ns.SaveRestockWindowGeometry(sizeOnly)
	local frame = ns.restockWindow
	if not frame then
		return
	end
	local point, _, relativePoint, xOffset, yOffset = frame:GetPoint(frame:GetNumPoints())
	if sizeOnly then
		local saved = ns.restockSettings.framePosition or {}
		point, relativePoint, xOffset, yOffset = saved.point, saved.relativePoint, saved.xOffset, saved.yOffset
	end
	ns.restockSettings.framePosition = {
		point = point,
		relativePoint = relativePoint,
		xOffset = xOffset,
		yOffset = yOffset,
		width = math.floor(frame:GetWidth() + 0.5),
		height = math.floor(frame:GetHeight() + 0.5),
	}
end

local function PlaceFrame(frame)
	local position = ns.restockSettings.framePosition
	frame:ClearAllPoints()
	frame:SetPoint(
		position.point or "RIGHT",
		UIParent,
		position.relativePoint or "RIGHT",
		position.xOffset or -4,
		position.yOffset or 0
	)
end

function ns.HasSavedRestockWindowPosition()
	local settings = ns.restockSettings
	return settings ~= nil and settings.framePosition.point ~= nil
end

-- Keeps the size.
function ns.ResetRestockWindowPosition()
	local position = ns.restockSettings.framePosition
	ns.restockSettings.framePosition = { width = position.width, height = position.height }
	if ns.restockWindow then
		PlaceFrame(ns.restockWindow)
	end
end

-- Forward-declared, or the closures below would compile them as nil globals.
local RelayoutFrame
local RefitGroupPane

local function CreateAddonFrame()
	local settings = ns.restockSettings
	local addonFrame = ns.CreateRestockerPortraitFrame("GoodToGoRestockFrame", L["RESTOCKER_WINDOW_TITLE"])
	addonFrame:SetSize(
		Clamp(settings.framePosition.width, MIN_WIDTH, MAX_WIDTH, DEFAULT_WIDTH),
		Clamp(settings.framePosition.height, MIN_HEIGHT, MAX_HEIGHT, DEFAULT_HEIGHT)
	)
	PlaceFrame(addonFrame)
	addonFrame:SetFrameStrata("HIGH")
	-- A saved position from another resolution or UI scale must not open off-screen.
	addonFrame:SetClampedToScreen(true)
	addonFrame:SetMovable(true)
	addonFrame:SetResizable(true)
	addonFrame:EnableMouse(true)
	addonFrame:RegisterForDrag("LeftButton")
	addonFrame:SetScript("OnDragStart", addonFrame.StartMoving)
	addonFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ns.SaveRestockWindowGeometry()
	end)

	addonFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)

	-- Children anchor to corners; only the sized scroll child and rows need telling.
	addonFrame:SetScript("OnSizeChanged", function(self)
		RelayoutFrame(self)
	end)

	-- Nothing repaints the bag-read marks while hidden, so every route in redraws.
	addonFrame:SetScript("OnShow", function(self)
		RefitGroupPane(self)
		ns.UpdateRestockList()
	end)

	--[[
	    On OnHide, since the X and Escape never reach ns.HideRestockWindow. Menus
	    are parented to UIParent and would outlive the window.
	]]
	addonFrame:SetScript("OnHide", function()
		ns.CloseRestockMenus()
		ns.EndRestockListRename()
		ns.ClearRestockAddNotice()
		ns.ClearRestockNewItems()
		ns.ClearRestockGroupSelection()
		ns.restockWindowOpenedByVisit = false
		if next(ns.restockColdRows) ~= nil then
			wipe(ns.restockColdRows)
			ns.SyncRestockItemInfoSubscription()
		end
	end)

	-- A drop anywhere joins the list; controls take the mouse first, and each makes this same call.
	local function TakeCursorItem()
		ns.AddRestockItemFromCursor()
	end
	addonFrame:SetScript("OnMouseUp", TakeCursorItem)
	addonFrame:SetScript("OnReceiveDrag", TakeCursorItem)
	return addonFrame
end

-- Runs every frame of a resize drag, so it only sets widths.
function RelayoutFrame(addonFrame)
	local scrollChild = addonFrame.scrollChild
	if not scrollChild then
		return -- still being built; ns.CreateRestockWindow lays out once at the end
	end

	local rowWidth = addonFrame.scrollFrame:GetWidth()
	scrollChild:SetWidth(rowWidth)
	for _, row in ipairs(ns.restockRowPool) do
		row:SetWidth(rowWidth)
	end
end

-- A child button, so it takes the mouse before the window's drag-to-move.
local function CreateResizeGrip(addonFrame)
	local grip = CreateFrame("Button", nil, addonFrame)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -4, 4)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetScript("OnMouseDown", function()
		addonFrame:StartSizing("BOTTOMRIGHT")
	end)
	grip:SetScript("OnMouseUp", function()
		addonFrame:StopMovingOrSizing()
		RelayoutFrame(addonFrame)
		ns.SaveRestockWindowGeometry()
	end)
	addonFrame.resizeGrip = grip
	return grip
end

local function CreateListInset(addonFrame)
	local listInset = ns.CreateRestockerBodyInset(addonFrame)
	addonFrame.listInset = listInset
	return listInset
end

local LIST_TOP_GAP = 8
local LIST_BOTTOM_MARGIN = 8 -- nothing else shares the list's inset

-- Shared so category rows and item rows sit on the same baseline.
local function ListTopInset()
	return LIST_TOP_GAP + ns.restockColumnHeaderHeight + ns.RESTOCK_COLUMN_HEADER_GAP
end

-- Shared so both panes end on the same line.
ns.RESTOCK_LIST_BOTTOM_INSET = LIST_BOTTOM_MARGIN

local function CreateScrollFrame(addonFrame, listInset)
	local scrollFrame = CreateFrame("ScrollFrame", nil, addonFrame, "UIPanelScrollFrameTemplate")
	-- 26 on the right for the scroll bar.
	local left = 8 + ns.restockGroupPaneWidth + ns.RESTOCK_GROUP_PANE_GAP
	scrollFrame:SetPoint("TOPLEFT", listInset, "TOPLEFT", left, -ListTopInset())
	scrollFrame:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -26, ns.RESTOCK_LIST_BOTTOM_INSET)
	addonFrame.scrollFrame = scrollFrame
	return scrollFrame
end

local function CreateScrollChild(scrollFrame, addonFrame)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(scrollFrame:GetWidth())
	scrollChild:SetHeight(scrollFrame:GetHeight() - 8)
	addonFrame.scrollChild = scrollChild

	scrollFrame:SetScrollChild(scrollChild)
	return scrollChild
end

--------------------------------------------------------------------------------
-- Empty List
--------------------------------------------------------------------------------

--[[
    A bare header over no rows reads as a failed load. The stack hangs from its
    title, so a longer locale pushes the button down; the offset centers the
    three lines English wraps to. No mouse, so drops fall through to the window.
]]
local EMPTY_BODY_WIDTH = 448
local EMPTY_TITLE_OFFSET = 64 -- the title's foot above the area's center, which centers the stack
local EMPTY_GAP = 8
local EMPTY_BUTTON_WIDTH = 144
local EMPTY_BUTTON_HEIGHT = 32

local function CreateEmptyState(addonFrame, listInset)
	local panel = CreateFrame("Frame", nil, addonFrame)
	panel:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -LIST_TOP_GAP)
	panel:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -8, ns.RESTOCK_LIST_BOTTOM_INSET)
	panel:Hide()

	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("BOTTOM", panel, "CENTER", 0, EMPTY_TITLE_OFFSET)
	title:SetText(L["RESTOCKER_EMPTY_TITLE"])

	local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	body:SetPoint("TOP", title, "BOTTOM", 0, -EMPTY_GAP)
	body:SetWidth(EMPTY_BODY_WIDTH)
	body:SetJustifyH("CENTER")
	body:SetText(L["RESTOCKER_EMPTY_BODY"])

	local button = ns.CreateRestockerHeaderButton(panel, L["RESTOCKER_PICK_STAPLES_BUTTON"])
	button:SetPoint("TOP", body, "BOTTOM", 0, -EMPTY_GAP * 2)
	-- The screen's one action, so it stays larger than the header's buttons.
	button:SetSize(math.max(EMPTY_BUTTON_WIDTH, button:GetWidth()), EMPTY_BUTTON_HEIGHT)
	panel.button = button
	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)

	local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	hint:SetPoint("TOP", button, "BOTTOM", 0, -EMPTY_GAP)
	hint:SetText(L["RESTOCKER_EMPTY_DROP_HINT"])

	addonFrame.emptyState = panel
	return panel
end

local function CreateNothingShownText(addonFrame)
	local text = addonFrame.scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	text:SetPoint("TOP", addonFrame.scrollFrame, "TOP", 0, -16)
	text:Hide()
	addonFrame.nothingShownText = text
	return text
end

-- The column header and category pane are the scroll frame's siblings, so each is switched by name.
function ns.UpdateRestockEmptyState(listIsEmpty, nothingShown)
	local window = ns.restockWindow
	window.emptyState:SetShown(listIsEmpty)
	window.scrollFrame:SetShown(not listIsEmpty)
	ns.restockColumnHeader:SetShown(not listIsEmpty)
	ns.restockGroupPane:SetShown(not listIsEmpty)

	window.nothingShownText:SetShown(nothingShown ~= nil)
	if nothingShown then
		window.nothingShownText:SetText(nothingShown)
	end
end

-- Staples takes the window off UISpecialFrames while open, or one Escape would close both.
function ns.SetRestockWindowClosesOnEscape(closes)
	for index = #UISpecialFrames, 1, -1 do
		if UISpecialFrames[index] == "GoodToGoRestockFrame" then
			table.remove(UISpecialFrames, index)
		end
	end
	if closes then
		table.insert(UISpecialFrames, "GoodToGoRestockFrame")
	end
end

-- On every open: a font can measure zero at login, and new item types may have arrived.
function RefitGroupPane(addonFrame)
	local before = ns.restockGroupPaneWidth
	ns.ResolveRestockGroupPaneWidth()
	if ns.restockGroupPaneWidth == before then
		return
	end
	ns.restockGroupPane:SetWidth(ns.restockGroupPaneWidth)
	local left = 8 + ns.restockGroupPaneWidth + ns.RESTOCK_GROUP_PANE_GAP
	addonFrame.scrollFrame:SetPoint("TOPLEFT", addonFrame.listInset, "TOPLEFT", left, -ListTopInset())
	RelayoutFrame(addonFrame)
end

function ns.CreateRestockWindow()
	-- Both before anything is built: heights come from the font, and the table anchors past the pane.
	ns.RefreshRestockRowMetrics()
	ns.ResolveRestockGroupPaneWidth()

	local addonFrame = CreateAddonFrame()
	local listInset = CreateListInset(addonFrame)
	local scrollFrame = CreateScrollFrame(addonFrame, listInset)
	CreateScrollChild(scrollFrame, addonFrame)
	ns.CreateRestockColumnHeader(addonFrame, scrollFrame)
	ns.CreateRestockGroupPane(addonFrame, listInset, ListTopInset())
	CreateEmptyState(addonFrame, listInset)
	CreateNothingShownText(addonFrame)
	local header = ns.CreateRestockHeader(addonFrame)
	addonFrame.staplesButton = header.staplesButton

	-- Order matters: each adder anchors off the one before, right to left.
	ns.CreateRestockAddButton(addonFrame, header)
	ns.CreateRestockAddBox(addonFrame, header)
	ns.PlaceRestockBagMenu(addonFrame, header)
	local bar = ns.CreateRestockListBar(addonFrame)
	-- No Settings button, on purpose: settings live in the options panel.
	ns.CreateRestockWindowFooter(addonFrame)
	CreateResizeGrip(addonFrame)
	ns.ApplyRestockerElvUISkin({
		addonFrame.filterBox,
		bar.selector,
		bar.renameBox,
		addonFrame.bagMenu,
		addonFrame.editBox,
	}, {
		bar.manageButton,
		header.staplesButton,
		bar.renameButton,
		bar.cancelButton,
		addonFrame.addButton,
		addonFrame.emptyState.button,
	})

	ns.SetRestockWindowClosesOnEscape(true)
	addonFrame:Hide()

	ns.restockWindow = addonFrame
	RelayoutFrame(addonFrame)
	return ns.restockWindow
end

-- Every player route in ends here or in ns.ToggleRestockWindow, so both answer the master switch.
local function RestockerSwitchedOff()
	if ns.IsRestockerEnabled() then
		return false
	end
	ns:PrintMessage(L["RESTOCKER_DISABLED"])
	return true
end

function ns.ShowRestockWindow()
	if RestockerSwitchedOff() then
		return
	end
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		-- Opening redraws by itself (OnShow); a window already open is redrawn here.
		if menu:IsShown() then
			ns.UpdateRestockList()
			return
		end
		menu:Show()
	end
end

function ns.HideRestockWindow()
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		menu:Hide()
	end
end

-- A visit closes the window only if it opened it; a player-opened window stays.
ns.restockWindowOpenedByVisit = false

function ns.ShowRestockWindowForVisit()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		return
	end
	ns.ShowRestockWindow()
	ns.restockWindowOpenedByVisit = ns.restockWindow ~= nil and ns.restockWindow:IsShown()
end

function ns.HideRestockWindowAfterVisit()
	if ns.restockWindowOpenedByVisit then
		ns.HideRestockWindow()
	end
end

function ns.ToggleRestockWindow()
	if RestockerSwitchedOff() then
		return
	end
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		menu:SetShown(not menu:IsShown())
	end
end
