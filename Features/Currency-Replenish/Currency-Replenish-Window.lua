local _, ns = ...
local L = ns.L

local Kit = ns.MenuKit
local CR = ns.CurrencyReplenish

--[[
        Currency Replenish // GtG                       [x]
        Bank                                    Goldhoard >
        Character      Current Amount      Target Amount
        Goldhoard      4,210g 55s 00c      1,000g 00s 00c >
        Selwyn         20g 00s 00c         100g 00s 00c >
        Pennyroot      3g 00s 00c          Off >
          Everyone is full.                     [ Replenish ]
        ---------------------------------------------------
        Options                                           >
]]

local PADDING = Kit.WINDOW_EDGE
local WINDOW_STEP = 16
--[[
    Every row: the maintainer's row height, a line with 8 above and 8 below. Set
    here, not read from the kit, so it holds whatever the kit's rows become.
]]
local ROW_HEIGHT = 28
local ROW_INSET = Kit.WINDOW_EDGE - Kit.FLYOUT_OVERLAP -- a row's highlight reaches this far past its text, as the menus' do
-- A line's room, as a menu's spacer: one after the title, one after the Bank line.
local LINE_BREAK = 16
local TITLE_GAP = 16 + LINE_BREAK
local GROUP_GAP = 8 + LINE_BREAK
local SECTION_GAP = 16
local BUTTON_HEIGHT = 22
local DIVIDER_ABOVE = 16
local DIVIDER_BELOW = 8
-- Under the Options row: the row's own 8 below its text makes up PADDING.
local FOOT = PADDING - 8
local COLUMN_GAP = 32 -- between the columns, so one amount doesn't run into the next
local ARROW_WIDTH = 12

-- Room for a Forever name and surname; the check's column comes first on every row, so names line up.
local MIN_NAME_WIDTH = 208
local CHECK_COLUMN = 16
local CHECK_GAP = 4
local NAME_START = CHECK_COLUMN + CHECK_GAP
-- 10,000g 99s 99c: the amount columns hold still so the window doesn't resize as gold changes.
local WIDEST_AMOUNT = (10000 * 100 + 99) * 100 + 99
local KEEPS_ARROW_GAP = 4

local anchor, content
local bankLine, bankValue
local heads = {}
local rows = {}
local sendButton, reasonText
local footer, footerDivider
local bankMenu, keepsMenu

--------------------------------------------------------------------------------
-- Text
--------------------------------------------------------------------------------

local Money = CR.Money
local Gold = CR.Gold

local function Muted(text)
	return Kit.Color("MUTED", text)
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

local function Refresh()
	if anchor and anchor:IsShown() then
		CR.RenderWindow()
	end
end

local measure

local function AfterChange()
	Refresh()
	if ns.RefreshSettings then
		ns.RefreshSettings()
	end
	if footer and footer.menu then
		footer.menu:Refresh()
	end
end

--------------------------------------------------------------------------------
-- Building
--------------------------------------------------------------------------------

local function Highlight(frame)
	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetColorTexture(1, 0.82, 0, 0.16)
end

local function Text(parent, justify)
	local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetJustifyH(justify or "LEFT")
	text:SetWordWrap(false)
	return text
end

local function HideTooltip()
	GameTooltip:Hide()
end

local function OpenKeeps(row)
	CR.keepsFor = row.key
	keepsMenu:Show(row, "line")
end

-- The age shows above the amount, clear of the Keeps list.
local function EnterGold(cell)
	local row = cell.row
	row:LockHighlight()
	OpenKeeps(row)
	local record = row.record
	if not (record and record.seen) or row.isSelf then
		return
	end
	GameTooltip:SetOwner(cell, "ANCHOR_TOP")
	GameTooltip:SetText(
		L["CURRENCY_REPLENISH_RECORDED_AGO"]:format(SecondsToTime(math.max(time() - record.seen, 1))),
		1,
		1,
		1
	)
	GameTooltip:Show()
end

local function LeaveGold(cell)
	cell.row:UnlockHighlight()
	HideTooltip()
end

local function Row(index)
	if rows[index] then
		return rows[index]
	end
	local row = CreateFrame("Button", nil, content)
	row:SetHeight(ROW_HEIGHT)
	row:RegisterForClicks("LeftButtonUp")
	row:SetScript("OnEnter", OpenKeeps)
	row:SetScript("OnClick", OpenKeeps)
	row.window = content
	Highlight(row)

	row.check = Text(row)
	row.check:SetPoint("LEFT", ROW_INSET, 0)
	row.check:SetWidth(CHECK_COLUMN)
	row.check:SetText(Kit.CHECK_MARK)
	row.name = Text(row)
	row.name:SetPoint("LEFT", ROW_INSET + NAME_START, 0)

	local gold = CreateFrame("Frame", nil, row)
	gold:SetHeight(ROW_HEIGHT)
	gold:EnableMouse(true)
	gold:SetScript("OnEnter", EnterGold)
	gold:SetScript("OnLeave", LeaveGold)
	gold:SetScript("OnMouseUp", function()
		OpenKeeps(row)
	end)
	gold.row = row
	gold.text = Text(gold, "RIGHT")
	gold.text:SetAllPoints()
	row.gold = gold

	local keeps = CreateFrame("Frame", nil, row)
	keeps:SetHeight(ROW_HEIGHT)
	keeps:SetPoint("LEFT", gold, "RIGHT", COLUMN_GAP, 0)
	keeps.arrow = Text(keeps, "RIGHT")
	keeps.arrow:SetPoint("RIGHT", 0, 0)
	keeps.arrow:SetText(Kit.SUBMENU_ARROW)
	keeps.text = Text(keeps, "RIGHT")
	keeps.text:SetPoint("RIGHT", keeps.arrow, "LEFT", -KEEPS_ARROW_GAP, 0)
	row.keeps = keeps

	rows[index] = row
	return row
end

local function NameText(item)
	return ns.ClassColoredName(item.record.name or "?", item.record.class)
end

-- Class color; the value color for a class the table does not hold.
local function BankText(bank)
	local color = ns.GetClassColor(bank.class)
	return color and (color .. bank.name .. "|r") or Kit.Color("VALUE", bank.name)
end

local function Widest(texts, least)
	local widest = least
	for _, text in ipairs(texts) do
		measure:SetText(text)
		widest = math.max(widest, math.ceil(measure:GetStringWidth()))
	end
	return widest
end

local function Build()
	anchor = CreateFrame("Frame", "GoodToGoCurrencyReplenishWindow", UIParent)
	anchor:SetFrameStrata("HIGH")
	anchor:SetToplevel(true)
	anchor:SetClampedToScreen(true)
	anchor:EnableMouse(true)
	anchor:Hide()
	table.insert(UISpecialFrames, "GoodToGoCurrencyReplenishWindow")
	content = anchor
	measure = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	measure:Hide()
	Kit.AddPlate(content)
	Kit.AddWindowHeader(content, L["CURRENCY_REPLENISH"], CR.CloseWindow)

	bankMenu = Kit.CreateMenu({ publish = false, build = CR.BankEntries, afterChange = AfterChange })
	keepsMenu = Kit.CreateMenu({ publish = false, build = CR.KeepsEntries, afterChange = AfterChange })

	bankLine = CreateFrame("Button", nil, content)
	bankLine:SetHeight(ROW_HEIGHT)
	bankLine:RegisterForClicks("LeftButtonUp")
	bankLine.window = content
	Highlight(bankLine)
	local label = Text(bankLine)
	label:SetPoint("LEFT", ROW_INSET, 0)
	label:SetText(L["CURRENCY_REPLENISH_BANK"])
	local arrow = Text(bankLine, "RIGHT")
	arrow:SetPoint("RIGHT", -ROW_INSET, 0)
	arrow:SetText(Kit.SUBMENU_ARROW)
	bankValue = Text(bankLine, "RIGHT")
	bankValue:SetPoint("RIGHT", arrow, "LEFT", -4, 0)
	local function OpenBank(self)
		bankMenu:Show(self, "line")
	end
	bankLine:SetScript("OnEnter", OpenBank)
	bankLine:SetScript("OnClick", OpenBank)

	for index, key in ipairs({
		"CURRENCY_REPLENISH_CHARACTER",
		"CURRENCY_REPLENISH_GOLD_NOW",
		"CURRENCY_REPLENISH_KEEPS",
	}) do
		heads[index] = Text(content, index == 1 and "LEFT" or "RIGHT")
		heads[index]:SetText(Kit.Color("TITLE", L[key]))
	end

	sendButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
	sendButton:SetHeight(BUTTON_HEIGHT)
	sendButton:SetScript("OnClick", function()
		if CR.IsBank() then
			CR.Replenish()
		else
			CR.SendExcess()
		end
	end)
	reasonText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reasonText:SetJustifyH("LEFT")
	reasonText:SetWordWrap(false)

	footer, footerDivider = Kit.AddOptionsLine(content, L["CURRENCY_REPLENISH_OPTIONS"], CR.OptionsEntries, AfterChange)
	footer:SetHeight(ROW_HEIGHT)

	-- However it closes (X, Escape, leaving the mailbox), its menus go and the tab goes dark.
	anchor:SetScript("OnHide", function()
		bankMenu:Hide()
		keepsMenu:Hide()
		footer.menu:Hide()
		StaticPopup_Hide(CR.KEEPS_POPUP)
		CR.SyncTab()
	end)
end

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

-- The rest are gray.
local REASON_COLORS = {
	CURRENCY_REPLENISH_REASON_FULL = "ON",
	CURRENCY_REPLENISH_REASON_NO_GOLD = "OFF",
}

-- Label, then the reason it is disabled (nil when enabled) and that reason's color.
local function SendState()
	if CR.Mailer.busy then
		return CR.IsBank() and L["CURRENCY_REPLENISH_REPLENISH"] or L["CURRENCY_REPLENISH_SEND_EXCESS"],
			L["CURRENCY_REPLENISH_REASON_SENDING"]
	end
	local bank = CR.BankRecord()
	if not bank then
		return L["CURRENCY_REPLENISH_SEND_EXCESS"], L["CURRENCY_REPLENISH_REASON_NO_BANK"]
	end
	if CR.IsBank() then
		local sends, _, short = CR.ReplenishPlan()
		if #sends == 0 then
			local reason = #short > 0 and "CURRENCY_REPLENISH_REASON_NO_GOLD" or "CURRENCY_REPLENISH_REASON_FULL"
			return L["CURRENCY_REPLENISH_REPLENISH"], L[reason], REASON_COLORS[reason]
		end
		return L["CURRENCY_REPLENISH_REPLENISH"]
	end
	local own = CR.OwnRecord()
	if not (own and own.keeps) then
		return L["CURRENCY_REPLENISH_SEND_EXCESS"], L["CURRENCY_REPLENISH_REASON_NO_KEEPS"]
	end
	local amount = CR.ExcessAmount()
	if amount <= 0 then
		return L["CURRENCY_REPLENISH_SEND_EXCESS"], L["CURRENCY_REPLENISH_REASON_AT_KEEPS"]:format(Gold(own.keeps))
	end
	return L["CURRENCY_REPLENISH_SEND_EXCESS"]
end

local function SnapUp(value)
	return math.ceil(value / WINDOW_STEP) * WINDOW_STEP
end

function CR.RenderWindow()
	local bank = CR.BankRecord()
	local ownKey = CR.OwnKey()

	local roster = CR.Roster()
	local cells = { names = {}, gold = {}, keeps = {} }
	for index, item in ipairs(roster) do
		local record = item.record
		cells.names[index] = NameText(item)
		cells.gold[index] = Money(item.key == ownKey and GetMoney() or record.money or 0)
		cells.keeps[index] = record.keeps and Gold(record.keeps) or Muted(L["MENU_OFF"])
	end
	local nameWidth = NAME_START + Widest(cells.names, MIN_NAME_WIDTH - NAME_START)
	local fixedAmount = Widest({ Money(WIDEST_AMOUNT) }, 0)
	local goldWidth = Widest({ heads[2]:GetText() }, fixedAmount)
	local amountWidth = Widest({ heads[3]:GetText() }, fixedAmount)
	local keepsWidth = amountWidth + KEEPS_ARROW_GAP + ARROW_WIDTH
	local columns = nameWidth + COLUMN_GAP + goldWidth + COLUMN_GAP + keepsWidth
	local label, reason, reasonColor = SendState()
	sendButton:SetText(label)
	local buttonWidth = math.max(sendButton:GetFontString():GetStringWidth() + 2 * PADDING, 160)
	local inner = math.max(columns, buttonWidth)
	local width = SnapUp(inner + 2 * PADDING)
	inner = width - 2 * PADDING
	local rowWidth = inner + 2 * ROW_INSET

	local y = -(PADDING + Kit.WINDOW_HEADER_HEIGHT + TITLE_GAP)

	bankLine:ClearAllPoints()
	bankLine:SetPoint("TOPLEFT", PADDING - ROW_INSET, y)
	bankLine:SetWidth(rowWidth)
	bankValue:SetText(bank and BankText(bank) or Muted(L["CURRENCY_REPLENISH_NO_BANK"]))
	y = y - ROW_HEIGHT - GROUP_GAP

	local x = PADDING
	local widths = { nameWidth, goldWidth, keepsWidth }
	for index, head in ipairs(heads) do
		head:ClearAllPoints()
		head:SetWidth(widths[index])
		head:SetPoint("TOPLEFT", content, "TOPLEFT", x, y - (ROW_HEIGHT - 12) / 2)
		x = x + widths[index] + COLUMN_GAP
	end
	-- Character starts past the check's column; Keeps lines up with the amounts, not the arrows.
	heads[1]:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING + NAME_START, y - (ROW_HEIGHT - 12) / 2)
	heads[1]:SetWidth(nameWidth - NAME_START)
	heads[3]:SetWidth(amountWidth)
	y = y - ROW_HEIGHT

	for index, item in ipairs(roster) do
		local row = Row(index)
		local record = item.record
		local isSelf = item.key == ownKey
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", PADDING - ROW_INSET, y)
		row:SetWidth(rowWidth)
		row.check:SetShown(isSelf)
		row.name:SetWidth(nameWidth - NAME_START)
		row.name:SetText(cells.names[index])
		row.gold:ClearAllPoints()
		row.gold:SetPoint("LEFT", ROW_INSET + nameWidth + COLUMN_GAP, 0)
		row.gold:SetWidth(goldWidth)
		row.gold.text:SetText(cells.gold[index])
		row.key, row.record, row.isSelf = item.key, record, isSelf
		row.keeps:SetWidth(keepsWidth)
		row.keeps.text:SetText(cells.keeps[index])
		row:Show()
		y = y - ROW_HEIGHT
	end
	for index = #roster + 1, #rows do
		rows[index]:Hide()
	end

	y = y - SECTION_GAP
	sendButton:ClearAllPoints()
	sendButton:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PADDING, y)
	sendButton:SetWidth(buttonWidth)
	sendButton:SetEnabled(reason == nil)
	if reason then
		reasonText:ClearAllPoints()
		reasonText:SetPoint("LEFT", content, "TOPLEFT", PADDING + NAME_START, y - BUTTON_HEIGHT / 2)
		reasonText:SetPoint("RIGHT", sendButton, "LEFT", -COLUMN_GAP, 0)
		reasonText:SetText(Kit.Color(reasonColor or "MUTED", reason))
		reasonText:Show()
	else
		reasonText:Hide()
	end
	y = y - BUTTON_HEIGHT

	-- The footer is measured first, so the height's rounding widens the gap above it, not the foot.
	local rawHeight = -y + DIVIDER_ABOVE + 1 + DIVIDER_BELOW + ROW_HEIGHT + FOOT
	local height = SnapUp(rawHeight)
	y = y - DIVIDER_ABOVE - (height - rawHeight)
	footerDivider:ClearAllPoints()
	footerDivider:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, y)
	footerDivider:SetWidth(inner)
	y = y - 1 - DIVIDER_BELOW
	footer:ClearAllPoints()
	footer:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING - ROW_INSET, y)
	footer:SetWidth(rowWidth)

	anchor:SetSize(width, height)
end

--------------------------------------------------------------------------------
-- Opening and Closing
--------------------------------------------------------------------------------

function CR.WindowShown()
	return anchor ~= nil and anchor:IsShown() == true
end

function CR.OpenWindow()
	local host = CR.TabHost()
	if not host then
		return
	end
	if not anchor then
		Build()
	end
	CR.Record()
	anchor:ClearAllPoints()
	anchor:SetPoint("TOPLEFT", host, "TOPRIGHT", CR.TAB_SIZE + 8, -CR.TAB_TOP)
	anchor:Show()
	CR.RenderWindow()
	CR.SyncTab()
end

function CR.CloseWindow()
	if anchor then
		anchor:Hide()
	end
end

function CR.ToggleWindow()
	if CR.WindowShown() then
		CR.CloseWindow()
	else
		CR.OpenWindow()
	end
end

CR.onChange = Refresh
