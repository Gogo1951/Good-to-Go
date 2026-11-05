local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    Buff-Duty-Party-Buffs -- the Buff Duty window's Party-Buffs icons: a raid
    buff, any class's, numbered with how many in your group need it
    (Buff-Duty-Other-Classes.lua counts). Hovering lists them; a Left-Click
    asks the party or raid for it, and a Right-Click whispers that class's
    players. Buff-Duty-Frame.lua places the icons on the Party-Buffs header.

    The list is laid out like the window, two parties to a row, and
    GameTooltip can't line up a second column (its right-hand text hugs the
    right edge), so the icons share a small tooltip of their own, built
    from pooled font strings in GameTooltip's fonts.
]]

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local BACKDROP = Data.BUFF_DUTY_BACKDROP
local ROSTER_PADDING = 10
local ROSTER_LINE_HEIGHT = 14
local ROSTER_TITLE_HEIGHT = 18
local ROSTER_COLUMN_GAP = 16

local roster
local rosterStrings, usedRosterStrings = {}, 0
-- The Party-Buffs icons: plain buttons, since a whisper isn't protected.
local otherIcons, usedOtherIcons = {}, 0

local function AcquireRosterString(font)
	usedRosterStrings = usedRosterStrings + 1
	local text = rosterStrings[usedRosterStrings]
	if not text then
		text = roster:CreateFontString(nil, "OVERLAY")
		rosterStrings[usedRosterStrings] = text
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
	if roster then
		roster:Hide()
	end
end

local function ShowRoster(owner, spec)
	if not roster then
		roster = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		roster:SetFrameStrata("TOOLTIP")
		roster:SetClampedToScreen(true)
		roster:SetBackdrop(BACKDROP)
		roster:SetBackdropColor(0, 0, 0, 0.9)
		roster:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	end
	for i = 1, usedRosterStrings do
		rosterStrings[i]:Hide()
	end
	usedRosterStrings = 0

	-- `x` and `y` measured in from the top-left padding; returns the text's width.
	local function Put(text, font, x, y)
		local line = AcquireRosterString(font)
		line:SetText(text)
		line:SetPoint("TOPLEFT", roster, "TOPLEFT", ROSTER_PADDING + x, -(ROSTER_PADDING + y))
		return x + line:GetStringWidth()
	end

	local width = Put(spec.spellName, "GameTooltipHeaderText", 0, 0)
	local y = ROSTER_TITLE_HEIGHT
	width = math.max(width, Put(L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"]:format(spec.count), "GameTooltipText", 0, y))
	y = y + ROSTER_LINE_HEIGHT

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
			right = math.max(
				right,
				Put(" " .. color .. name .. "|r", "GameTooltipText", x, top + index * ROSTER_LINE_HEIGHT)
			)
		end
		return right
	end
	local groups, rowTops = spec.groups, {}
	for index = 1, #groups, 2 do
		y = y + ROSTER_LINE_HEIGHT
		rowTops[index] = y
		local lines = 1 + math.max(#groups[index].names, groups[index + 1] and #groups[index + 1].names or 0)
		y = y + lines * ROSTER_LINE_HEIGHT
	end
	local leftWidth = 0
	for index = 1, #groups, 2 do
		leftWidth = math.max(leftWidth, PutGroup(groups[index], 0, rowTops[index]))
	end
	width = math.max(width, leftWidth)
	for index = 2, #groups, 2 do
		width = math.max(width, PutGroup(groups[index], leftWidth + ROSTER_COLUMN_GAP, rowTops[index - 1]))
	end

	--[[
	    What each click does, the click on the left and its action against
	    the right edge, like GameTooltip's double lines. Your own class's
	    buff, with nobody else of it in the group, has no one to whisper.
	]]
	y = y + ROSTER_LINE_HEIGHT
	local function PutHint(keybind, action)
		local right = Put(GetColor("INFO") .. keybind .. "|r", "GameTooltipText", 0, y)
		local text = AcquireRosterString("GameTooltipText")
		text:SetJustifyH("RIGHT")
		text:SetText(GetColor("INFO") .. action .. "|r")
		text:SetPoint("TOPRIGHT", roster, "TOPRIGHT", -ROSTER_PADDING, -(ROSTER_PADDING + y))
		width = math.max(width, right + ROSTER_COLUMN_GAP + text:GetStringWidth())
		y = y + ROSTER_LINE_HEIGHT
	end
	PutHint(L["MINIMAP_LEFT_CLICK"], L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_GROUP"])
	if spec.recipientNames[1] then
		PutHint(L["MINIMAP_RIGHT_CLICK"], L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_WHISPER"])
	end

	roster:SetSize(math.ceil(width) + ROSTER_PADDING * 2, math.ceil(y) + ROSTER_PADDING)
	-- Where GameTooltip's ANCHOR_RIGHT would put it: up and to the right of the icon.
	roster:ClearAllPoints()
	roster:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT")
	roster:Show()
end

local function OnOtherIconEnter(self)
	if self.spec then
		ShowRoster(self, self.spec)
	end
end

local function OnOtherIconClick(self, button)
	if not self.spec then
		return
	end
	if button == "RightButton" then
		ns.WhisperOtherClassBuff(self.spec)
	else
		ns.AskGroupForBuff(self.spec)
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
		button:SetScript("OnLeave", ns.HideBuffDutyRoster)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("OnClick", OnOtherIconClick)
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
