local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    Buff-Duty-Party-Buffs -- the Buff Duty window's Party-Buffs icons: a raid
    buff, any class's, numbered with how many in your group need it
    (Buff-Duty-Other-Classes.lua counts). Hovering an icon opens its menu:
    who needs the buff, then a row that asks the party or raid for it and,
    when someone else can cast it, a row that whispers them. Clicking the
    icon itself does nothing, so nothing is sent by accident.
    Buff-Duty-Frame.lua places the icons on the Party-Buffs header.

    The roster is laid out like the window, two parties to a row, and
    GameTooltip can't line up a second column (its right-hand text hugs the
    right edge), so the icons share a small menu of their own, built from
    pooled font strings in GameTooltip's fonts. It stays open while the
    mouse is on the icon or the menu, closes a moment after it leaves both,
    and closes on Escape.
]]

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local BACKDROP = Data.BUFF_DUTY_BACKDROP
local MENU_NAME = "GoodToGoBuffDutyPartyMenu"
local MENU_PADDING = 8
local LINE_HEIGHT = 16
local COLUMN_GAP = 16
local DIVIDER_GAP = 4
local CLOSE_DELAY = 0.2

local menu
local menuStrings, usedMenuStrings = {}, 0
-- The Party-Buffs icons: plain buttons, since a whisper isn't protected.
local otherIcons, usedOtherIcons = {}, 0

local function AcquireMenuString(font)
	usedMenuStrings = usedMenuStrings + 1
	local text = menuStrings[usedMenuStrings]
	if not text then
		text = menu:CreateFontString(nil, "OVERLAY")
		menuStrings[usedMenuStrings] = text
	end
	text:SetFontObject(font)
	text:SetJustifyH("LEFT")
	text:SetWidth(0)
	text:SetWordWrap(false)
	text:ClearAllPoints()
	text:Show()
	return text
end

function ns.HideBuffDutyRoster()
	if menu then
		menu:Hide()
	end
end

-- Closes the menu once the mouse is on neither it nor the icon that opened it.
local function CloseIfLeft()
	if not menu or not menu:IsShown() then
		return
	end
	local owner = menu.owner
	if menu:IsMouseOver() or (owner and owner:IsShown() and owner:IsMouseOver()) then
		return
	end
	menu:Hide()
end

local function ScheduleClose()
	C_Timer.After(CLOSE_DELAY, CloseIfLeft)
end

-- An action row: its label on the left, a highlight under the mouse, muted while it can't run.
local function CreateRow()
	local row = CreateFrame("Button", nil, menu)
	row:SetHeight(LINE_HEIGHT)
	row.label = row:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	row.label:SetPoint("LEFT", row, "LEFT", 0, 0)
	row.label:SetJustifyH("LEFT")
	row.label:SetWordWrap(false)
	row:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
	row:SetScript("OnLeave", ScheduleClose)
	row:SetScript("OnClick", function(self)
		local spec = menu.spec
		menu:Hide()
		if spec then
			self.action(spec)
		end
	end)
	return row
end

local function CreateMenu()
	menu = CreateFrame("Frame", MENU_NAME, UIParent, "BackdropTemplate")
	menu:SetFrameStrata("TOOLTIP")
	menu:SetClampedToScreen(true)
	menu:EnableMouse(true)
	menu:SetBackdrop(BACKDROP)
	menu:SetBackdropColor(0, 0, 0, 0.9)
	menu:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	menu:SetScript("OnLeave", ScheduleClose)
	menu:Hide()
	table.insert(UISpecialFrames, MENU_NAME)

	menu.dividers = {}
	for index = 1, 2 do
		local divider = menu:CreateTexture(nil, "ARTWORK")
		divider:SetHeight(1)
		divider:SetColorTexture(0.4, 0.4, 0.4, 1)
		menu.dividers[index] = divider
	end

	menu.askRow = CreateRow()
	menu.askRow.action = ns.AskGroupForBuff
	menu.whisperRow = CreateRow()
	menu.whisperRow.action = ns.WhisperOtherClassBuff
end

-- Lays a row's label out and greys it while the same ask is still cooling down.
local function SetRow(row, text, ready, y)
	row.label:SetText((ready and GetColor("TEXT") or GetColor("MUTED")) .. text .. "|r")
	row:SetEnabled(ready)
	row:ClearAllPoints()
	row:SetPoint("TOPLEFT", menu, "TOPLEFT", MENU_PADDING, -(MENU_PADDING + y))
	row:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -MENU_PADDING, -(MENU_PADDING + y))
	row:Show()
	return row.label:GetStringWidth()
end

local function ShowMenu(owner, spec)
	if not menu then
		CreateMenu()
	end
	for i = 1, usedMenuStrings do
		menuStrings[i]:Hide()
	end
	usedMenuStrings = 0
	menu.owner, menu.spec = owner, spec

	--[[
	    How far down the lowest text reaches, so the padding under it matches
	    the padding over the title. A line can stand taller than LINE_HEIGHT,
	    and sizing by the line count alone let the last one sink into the
	    bottom padding.
	]]
	local bottom = 0
	local function Track(line, y)
		bottom = math.max(bottom, y + line:GetStringHeight())
	end

	-- `x` and `y` measured in from the top-left padding; returns the text's width.
	local function Put(text, font, x, y)
		local line = AcquireMenuString(font)
		line:SetText(text)
		line:SetPoint("TOPLEFT", menu, "TOPLEFT", MENU_PADDING + x, -(MENU_PADDING + y))
		Track(line, y)
		return x + line:GetStringWidth()
	end

	local function PutDivider(divider, y)
		divider:ClearAllPoints()
		divider:SetPoint("TOPLEFT", menu, "TOPLEFT", MENU_PADDING, -(MENU_PADDING + y))
		divider:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -MENU_PADDING, -(MENU_PADDING + y))
		return y + 1 + DIVIDER_GAP
	end

	-- The header: the buff's name in gold, the Short Name muted against the right edge.
	local width = Put(GetColor("TITLE") .. spec.spellName .. "|r", "GameTooltipText", 0, 0)
	local short = AcquireMenuString("GameTooltipText")
	short:SetJustifyH("RIGHT")
	short:SetText(GetColor("MUTED") .. L["ADDON_SHORT_NAME"] .. "|r")
	short:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -MENU_PADDING, -MENU_PADDING)
	width = width + COLUMN_GAP + short:GetStringWidth()
	local y = PutDivider(menu.dividers[1], LINE_HEIGHT + DIVIDER_GAP)

	width = math.max(
		width,
		Put(GetColor("HELP") .. L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"]:format(spec.count) .. "|r", "GameTooltipText", 0, y)
	)
	y = y + LINE_HEIGHT

	--[[
	    Party by party, two to a row reading across like the window: the
	    header in gold, then each name a space in, in its class color. Every
	    row starts below the taller of its two, and the right-hand parties
	    all start where the widest left-hand one ends.
	]]
	local function PutGroup(group, x, top)
		local right = Put(GetColor("TITLE") .. group.label .. "|r", "GameTooltipText", x, top)
		for index, name in ipairs(group.names) do
			local color = ns.GetClassColor(group.classes[index]) or GetColor("TEXT")
			right = math.max(right, Put(" " .. color .. name .. "|r", "GameTooltipText", x, top + index * LINE_HEIGHT))
		end
		return right
	end
	local groups, rowTops = spec.groups, {}
	for index = 1, #groups, 2 do
		y = y + DIVIDER_GAP
		rowTops[index] = y
		local lines = 1 + math.max(#groups[index].names, groups[index + 1] and #groups[index + 1].names or 0)
		y = y + lines * LINE_HEIGHT
	end
	local leftWidth = 0
	for index = 1, #groups, 2 do
		leftWidth = math.max(leftWidth, PutGroup(groups[index], 0, rowTops[index]))
	end
	width = math.max(width, leftWidth)
	for index = 2, #groups, 2 do
		width = math.max(width, PutGroup(groups[index], leftWidth + COLUMN_GAP, rowTops[index - 1]))
	end

	--[[
	    The actions. Your own class's buff, with nobody else of it in the
	    group, has no one to whisper, so that row is left out.
	]]
	y = PutDivider(menu.dividers[2], y + DIVIDER_GAP)
	width = math.max(
		width,
		SetRow(
			menu.askRow,
			L["BUFF_DUTY_OTHERS_MENU_ASK_GROUP"]:format(spec.spellName),
			ns.CanAskForBuff("group", spec.key),
			y
		)
	)
	y = y + LINE_HEIGHT
	if spec.recipientNames[1] then
		width = math.max(
			width,
			SetRow(
				menu.whisperRow,
				L["BUFF_DUTY_OTHERS_MENU_WHISPER"]:format(table.concat(spec.recipientNames, L["LIST_SEPARATOR"])),
				ns.CanAskForBuff("whisper", spec.key),
				y
			)
		)
		y = y + LINE_HEIGHT
	else
		menu.whisperRow:Hide()
	end
	bottom = math.max(bottom, y)

	menu:SetSize(math.ceil(width) + MENU_PADDING * 2, math.ceil(bottom) + MENU_PADDING * 2)
	-- Where GameTooltip's ANCHOR_RIGHT would put it: up and to the right of the icon.
	menu:ClearAllPoints()
	menu:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT")
	menu:Show()
end

local function OnOtherIconEnter(self)
	if self.spec then
		ShowMenu(self, self.spec)
	end
end

-- `parent` is the window's content frame (Buff-Duty-Frame.lua), which every icon sits in.
function ns.AcquireBuffDutyOtherIcon(parent)
	usedOtherIcons = usedOtherIcons + 1
	local button = otherIcons[usedOtherIcons]
	if not button then
		button = CreateFrame("Button", nil, parent)
		button:SetSize(ICON_SIZE, ICON_SIZE)
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		-- The count sits in the middle, in the palette's red: it's a gap, not a stack.
		button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
		button.count:SetPoint("CENTER", button, "CENTER", 0, 0)
		local red = ns.COLORS_RGB.OFF
		button.count:SetTextColor(red.r, red.g, red.b)
		button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
		button:SetScript("OnEnter", OnOtherIconEnter)
		button:SetScript("OnLeave", ScheduleClose)
		otherIcons[usedOtherIcons] = button
	end
	return button
end

function ns.SetBuffDutyOtherIcon(button, spec)
	button.spec = spec
	button.icon:SetTexture(C_Spell.GetSpellTexture(spec.spellId))
	button.count:SetText(spec.count)
	button:Show()
end

function ns.ReleaseBuffDutyOtherIcons()
	for i = 1, usedOtherIcons do
		otherIcons[i]:Hide()
		otherIcons[i].spec = nil
	end
	usedOtherIcons = 0
end
