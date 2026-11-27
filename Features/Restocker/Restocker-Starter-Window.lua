local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local StackChoices = ns.StarterStackChoices
local StackLabel = ns.StarterStackLabel
local OfferedSections = ns.StarterOfferedSections

--------------------------------------------------------------------------------
-- Staples Window
--------------------------------------------------------------------------------

--[[
    No don't-show-again: the window adds only what is ticked, and a player who
    wants none of it turns the Restocker off.
]]

local BANDS = ns.RESTOCK_WINDOW_BANDS

--[[
    Two staples side by side with the scroll bar showing. The height fits what
    is offered, which class, level and the locale's intro decide, up to the cap.
]]
local WINDOW_WIDTH = 688
local WINDOW_MAX_HEIGHT = 640
local WINDOW_MIN_HEIGHT = 256

local CONTENT_PADDING = 16 -- inside the inset, around everything it holds
local SCROLL_BAR_SPACE = 32
local PARAGRAPH_GAP = 8
local SECTION_GAP = 16
local HEADER_HEIGHT = 16
local HEADER_GAP = 8 -- a section's name to its first row
local ROW_HEIGHT = 32
local COLUMN_GAP = 32

local CHECKBOX_SIZE = 16
local ICON_SIZE = 20
local ICON_GAP = 4
local NAME_GAP = 8
local DROPDOWN_WIDTH = 128
local DROPDOWN_GAP = 8
-- The height snaps to whole steps.
local HEIGHT_STEP = 16

local WARM_KEY = "StaplesWindow"

local window
local openedFromLogin = false

local function LoadingText(itemID)
	return GetColor("MUTED") .. string.format(L["LOADING_ITEM"], itemID) .. "|r"
end

-- Repaints once a frame however many item answers land in it, not once per item.
local layoutPending = false

local function LayoutNextFrame()
	if layoutPending then
		return
	end
	layoutPending = true
	C_Timer.After(0, function()
		layoutPending = false
		if window and window:IsShown() then
			window:Layout()
		end
	end)
end

local function WarmOfferedItems()
	local coldItemIDs, seen = {}, {}
	local function Cold(itemID)
		if itemID and not seen[itemID] then
			seen[itemID] = true
			coldItemIDs[#coldItemIDs + 1] = itemID
		end
	end
	for _, category in ipairs(ns.GetStarterCategories()) do
		if ns.IsStarterCategoryForClass(category) and ns.IsStarterCategoryAvailable(category) then
			if not ns.GetStarterCategoryStackSize(category) then
				Cold(ns.GetStarterCategoryItemID(category))
			end
			if not ns.GetStarterCategoryName(category) then
				Cold(ns.GetStarterCategoryNameItemID(category))
			end
		end
	end
	ns.WarmItemCache(coldItemIDs, WARM_KEY, LayoutNextFrame)
end

--------------------------------------------------------------------------------
-- Pools
--------------------------------------------------------------------------------

-- Acquire hands out pooled frames in order; Release hides the ones the last layout used.
local function Pool(create)
	local pool = { used = 0 }
	function pool.Acquire()
		pool.used = pool.used + 1
		local item = pool[pool.used]
		if not item then
			item = create()
			pool[pool.used] = item
		end
		item:Show()
		return item
	end
	function pool.Release()
		for index = 1, #pool do
			pool[index]:Hide()
		end
		pool.used = 0
	end
	return pool
end

--------------------------------------------------------------------------------
-- Stacks Dropdown
--------------------------------------------------------------------------------

--[[
    On the kit's menu, never WowStyle1DropdownTemplate or the game's context
    menu: the maintainer's choice for every menu the add-on opens.
]]
local function StacksEntries(category)
	local entries = {}
	for _, stacks in ipairs(StackChoices(category)) do
		local selected = ns.GetStarterCategoryStacks(category) == stacks
		entries[#entries + 1] = ns.RestockChoiceRow(StackLabel(category, stacks), nil, selected, function()
			ns.SetStarterCategoryStacks(category, stacks)
			-- Picking a count can tick the box opposite.
			if window and window:IsShown() then
				window:Layout()
			end
		end)
	end
	return entries
end

local function CreateStacksDropdown(parent)
	local dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	dropdown:SetSize(DROPDOWN_WIDTH, 22)
	dropdown:SetScript("OnClick", function(self)
		if not self.category then
			return
		end
		-- The control's own tooltip would sit over the menu it opened.
		GameTooltip:Hide()
		ns.RestockMenu:Open(self, StacksEntries(self.category), nil, nil, "click")
	end)
	-- Hooked, so the template's hover highlight survives.
	dropdown:HookScript("OnEnter", function(self)
		local category = self.category
		local text
		if category.countsItems then
			text = L["STARTER_POPUP_COUNT_DESCRIPTION"]
		else
			local stackSize = ns.GetStarterCategoryStackSize(category)
			text = stackSize and string.format(L["STARTER_POPUP_STACKS_DESCRIPTION"], stackSize)
				or LoadingText(ns.GetStarterCategoryItemID(category))
		end
		ns.ShowRestockerTooltip(self, text)
	end)
	dropdown:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return dropdown
end

local function RefreshStacksDropdown(dropdown, category)
	dropdown.category = category
	dropdown:SetText(StackLabel(category, ns.GetStarterCategoryStacks(category)))
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

-- The icon shows which item a kind-named row (Bread) is today, and never waits on the server.
local function CreateStapleCell(content)
	local cell = CreateFrame("Frame", nil, content)
	cell:SetHeight(ROW_HEIGHT)

	local checkbox = CreateFrame("CheckButton", nil, cell, "UICheckButtonTemplate")
	checkbox:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
	checkbox:SetPoint("LEFT", cell, "LEFT", 0, 0)
	checkbox:SetScript("OnClick", function(self)
		local checked = self:GetChecked() and true or false
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		ns.SetStarterCategory(cell.category, checked)
		window:Layout()
	end)
	cell.checkbox = checkbox

	local icon = cell:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", checkbox, "RIGHT", ICON_GAP, 0)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	cell.icon = icon

	local dropdown = CreateStacksDropdown(cell)
	dropdown:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
	cell.dropdown = dropdown

	-- A button only so a click on the name ticks the box, as a checkbox label does.
	local label = CreateFrame("Button", nil, cell)
	label:SetPoint("LEFT", icon, "LEFT", 0, 0)
	label:SetHeight(ROW_HEIGHT)
	local name = label:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	name:SetPoint("LEFT", icon, "RIGHT", NAME_GAP, 0)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	cell.name = name
	cell.label = label
	label:SetScript("OnClick", function()
		checkbox:Click()
	end)
	label:SetScript("OnEnter", function(self)
		local category = cell.category
		local title, body = ns.DescribeStarterCategory(category)
		if title then
			ns.ShowRestockerTooltip(self, title, body)
		else
			ns.ShowRestockerTooltip(self, LoadingText(ns.GetStarterCategoryItemID(category)))
		end
	end)
	label:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	ns.ApplyRestockerElvUISkin(nil, nil, { checkbox })
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if skins then
		pcall(skins.HandleDropDownBox, skins, dropdown, DROPDOWN_WIDTH)
	end
	return cell
end

local function FillStapleCell(cell, category, width)
	cell.category = category
	cell:SetWidth(width)
	cell.checkbox:SetChecked(ns.IsStarterCategoryChecked(category))

	local itemID = ns.GetStarterCategoryItemID(category)
	cell.icon:SetTexture(itemID and C_Item.GetItemIconByID(itemID) or ns.QUESTION_MARK_ICON)
	cell.name:SetText(ns.GetStarterCategoryName(category) or LoadingText(ns.GetStarterCategoryNameItemID(category)))

	local hasDropdown = not category.fixedAmount
	cell.dropdown:SetShown(hasDropdown)
	if hasDropdown then
		RefreshStacksDropdown(cell.dropdown, category)
		cell.name:SetPoint("RIGHT", cell.dropdown, "LEFT", -DROPDOWN_GAP, 0)
		cell.label:SetPoint("RIGHT", cell.dropdown, "LEFT", -DROPDOWN_GAP, 0)
	else
		cell.name:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
		cell.label:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
	end
end

-- Set off by space rather than a line.
local function CreateSectionHeader(content)
	local header = CreateFrame("Frame", nil, content)
	header:SetHeight(HEADER_HEIGHT)
	local text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("LEFT", header, "LEFT", 0, 0)
	header.text = text
	return header
end

local function CreateParagraph(content)
	local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(true)
	return text
end

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

--[[
    By route: login fires only over an empty list and pre-ticks it, while Pick
    Staples opens over whatever the list already has.
]]
local function IntroText()
	local introKey = "STARTER_POPUP_INTRO_STOCKED"
	if openedFromLogin then
		introKey = "STARTER_POPUP_INTRO_LOGIN"
	elseif ns.IsRestockListEmpty() then
		introKey = "STARTER_POPUP_INTRO_EMPTY"
	end
	return GetColor("BODY") .. L[introKey] .. " " .. L["STARTER_POPUP_INTRO_HOW"] .. "|r"
end

-- Also run on every tick, since a tick can change which item a row names.
local function Layout(frame)
	local content = frame.content
	frame.headers.Release()
	frame.cells.Release()
	frame.paragraphs.Release()

	local width = frame.scrollFrame:GetWidth()
	content:SetWidth(width)
	local inner = width - 2 * CONTENT_PADDING
	local columnWidth = (inner - COLUMN_GAP) / 2
	local y = CONTENT_PADDING

	local function Paragraph(text)
		local paragraph = frame.paragraphs.Acquire()
		paragraph:ClearAllPoints()
		paragraph:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING, -y)
		paragraph:SetWidth(inner)
		paragraph:SetText(text)
		y = y + paragraph:GetStringHeight() + PARAGRAPH_GAP
	end

	Paragraph(IntroText())

	-- No sections means nothing to offer yet: said, rather than an empty box.
	local sections = OfferedSections()
	if #sections == 0 then
		y = y + SECTION_GAP - PARAGRAPH_GAP
		Paragraph(GetColor("MUTED") .. L["STARTER_NOTHING_TO_OFFER"] .. "|r")
	end

	for _, section in ipairs(sections) do
		y = y + SECTION_GAP - PARAGRAPH_GAP
		local header = frame.headers.Acquire()
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING, -y)
		header:SetWidth(inner)
		header.text:SetText(section.title)
		y = y + HEADER_HEIGHT + HEADER_GAP

		if section.note then
			Paragraph(GetColor("BODY") .. section.note .. "|r")
		end

		for index, category in ipairs(section.categories) do
			local column = (index - 1) % 2
			local cell = frame.cells.Acquire()
			cell:ClearAllPoints()
			cell:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING + column * (columnWidth + COLUMN_GAP), -y)
			FillStapleCell(cell, category, columnWidth)
			if column == 1 or index == #section.categories then
				y = y + ROW_HEIGHT
			end
		end
	end

	y = y + CONTENT_PADDING
	content:SetHeight(y)

	local chrome = BANDS.TITLE_HEIGHT + BANDS.FOOTER_HEIGHT + BANDS.FRAME_BORDER + 8
	local height = math.ceil((y + chrome) / HEIGHT_STEP) * HEIGHT_STEP
	frame:SetHeight(math.max(WINDOW_MIN_HEIGHT, math.min(WINDOW_MAX_HEIGHT, height)))
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

--[[
    On the login route only, Done opens the Restock List and the hint names the
    command to get it back; from Pick Staples the player already knows the way.
]]
local FOOTER_GAP = 16 -- between the hint's end and the Done button

local function CreateFooter(frame)
	local centerY = BANDS.FRAME_BORDER + BANDS.FOOTER_HEIGHT / 2
	local done = ns.CreateRestockerHeaderButton(frame, L["STARTER_POPUP_DONE"])
	done:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -ns.RESTOCK_FOOTER_X, centerY)
	done:SetScript("OnClick", function()
		local fromLogin = openedFromLogin
		frame:Hide()
		if fromLogin then
			ns.ShowRestockWindow()
		end
	end)
	ns.ApplyRestockerElvUISkin(nil, { done })
	frame.doneButton = done

	local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	hint:SetPoint("LEFT", frame, "BOTTOMLEFT", ns.RESTOCK_FOOTER_X, centerY)
	hint:SetPoint("RIGHT", done, "LEFT", -FOOTER_GAP, 0)
	hint:SetJustifyH("LEFT")
	hint:SetWordWrap(false)
	frame.footerHint = hint
end

local function PlaceWindow(frame)
	local position = ns.restockSettings.staplesPosition
	frame:ClearAllPoints()
	if position and position.point then
		frame:SetPoint(position.point, UIParent, position.relativePoint, position.xOffset, position.yOffset)
	else
		frame:SetPoint("CENTER")
	end
end

-- Written whole: AceDB can clear an empty staplesPosition at logout.
local function SavePosition(frame)
	local point, _, relativePoint, xOffset, yOffset = frame:GetPoint(frame:GetNumPoints())
	ns.restockSettings.staplesPosition =
		{ point = point, relativePoint = relativePoint, xOffset = xOffset, yOffset = yOffset }
end

function ns.HasSavedStaplesPosition()
	local position = ns.restockSettings and ns.restockSettings.staplesPosition
	return position ~= nil and position.point ~= nil
end

function ns.ResetStaplesPosition()
	ns.restockSettings.staplesPosition = {}
	if window then
		PlaceWindow(window)
	end
end

local function CreateWindow()
	local frame = ns.CreateRestockerPortraitFrame("GoodToGoStaplesFrame", L["STARTER_POPUP_TITLE"])
	frame:SetSize(WINDOW_WIDTH, WINDOW_MAX_HEIGHT)
	PlaceWindow(frame)
	-- Over the Restock List, when it is open behind it.
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		SavePosition(self)
	end)
	table.insert(UISpecialFrames, frame:GetName())
	frame:Hide()

	local inset = ns.CreateRestockerBodyInset(frame, true)
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", inset, "TOPLEFT", 4, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -SCROLL_BAR_SPACE, 4)
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(1, 1)
	scrollFrame:SetScrollChild(content)
	frame.scrollFrame = scrollFrame
	frame.content = content

	frame.headers = Pool(function()
		return CreateSectionHeader(content)
	end)
	frame.cells = Pool(function()
		return CreateStapleCell(content)
	end)
	frame.paragraphs = Pool(function()
		return CreateParagraph(content)
	end)
	CreateFooter(frame)
	frame.Layout = Layout

	--[[
	    Escape goes back to the list a frame later: this hide runs inside
	    CloseSpecialWindows, still walking UISpecialFrames, which would close the
	    list too.
	]]
	frame:SetScript("OnHide", function()
		openedFromLogin = false
		C_Timer.After(0, function()
			if not frame:IsShown() then
				ns.SetRestockWindowClosesOnEscape(true)
			end
		end)
		ns.ClearRestockNewItems()
		ns.UpdateRestockList()
	end)

	return frame
end

function ns.ShowStarterListPopup(fromLogin)
	window = window or CreateWindow()
	openedFromLogin = fromLogin == true
	window.footerHint:SetText(
		openedFromLogin
				and string.format(
					L["STARTER_POPUP_COMMAND_HINT"],
					GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
				)
			or ""
	)
	-- A font not loaded when the button was made measures as nothing.
	ns.FitRestockerHeaderButton(window.doneButton)
	-- A removed row's Undo would sit behind this window, so it goes now.
	ns.ForgetRestockRemoval()
	-- So Escape closes this window alone; OnHide hands Escape back to the list.
	ns.SetRestockWindowClosesOnEscape(false)
	window:Show()
	window:Raise()
	WarmOfferedItems()
	window:Layout()
	window.scrollFrame:SetVerticalScroll(0)
end

function ns.CloseStarterListPopup()
	if window and window:IsShown() then
		window:Hide()
	end
end
