local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    Buff-Duty-Party-Buffs -- the Buff Duty window's Party-Buffs icons: a raid
    buff, any class's, numbered with how many in your group need it
    (Buff-Duty-Other-Classes.lua counts). Clicking an icon asks the party or
    raid for the buff; right-clicking whispers the players of that class who
    can cast it, when anyone else can. Buff-Duty-Frame.lua places the icons on
    the Party-Buffs header.

    The actions sit on the icon itself, not in a menu: a menu opened by
    hovering closed before the mouse could reach it.

    Hovering shows who needs the buff, party by party: each name on the left
    and the buff's icon on the right, drawn the way the window draws its own --
    grey and faded when they have none, or with a sliver of how much is left
    when it's running low. The two clicks sit at the foot as hints. A cooldown
    swipe can't sit in a GameTooltip line, so this is a small frame of its
    own in GameTooltip's look; it takes no mouse, so it never gets in the way.
]]

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local BACKDROP = Data.BUFF_DUTY_BACKDROP
local PADDING = 8
local LINE_HEIGHT = 18
local COLUMN_GAP = 16
local SECTION_GAP = 6
local FONT = "GameTooltipText"

-- The window's faded look (OUT_OF_RANGE_ALPHA in Buff-Duty-Icon-State.lua), for a buff nobody put on them.
local MISSING_ALPHA = 0.35

--[[
    How often an open tooltip redraws, so a buff that runs out turns grey, a
    hint greyed by its cooldown comes back, and a redraw of the window (new
    count, icon gone) shows up while you hover. The sliver animates on its own.
]]
local REFRESH_INTERVAL = 0.5

local panel, refreshTicker
local panelStrings, usedStrings = {}, 0
local panelIcons, usedIcons = {}, 0
-- The Party-Buffs icons: plain buttons, since a chat line isn't protected.
local otherIcons, usedOtherIcons = {}, 0

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

local function CreatePanel()
	panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	panel:SetFrameStrata("TOOLTIP")
	panel:SetClampedToScreen(true)
	panel:EnableMouse(false)
	panel:SetBackdrop(BACKDROP)
	panel:SetBackdropColor(0, 0, 0, Data.BUFF_DUTY_BACKDROP_ALPHA)
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	panel:Hide()
end

local function AcquireString()
	usedStrings = usedStrings + 1
	local text = panelStrings[usedStrings]
	if not text then
		text = panel:CreateFontString(nil, "OVERLAY", FONT)
		text:SetWordWrap(false)
		panelStrings[usedStrings] = text
	end
	text:ClearAllPoints()
	text:Show()
	return text
end

-- A row's buff icon, with the window's reversed, number-free sliver.
local function AcquireIcon()
	usedIcons = usedIcons + 1
	local icon = panelIcons[usedIcons]
	if not icon then
		icon = CreateFrame("Frame", nil, panel)
		icon:SetSize(ICON_SIZE, ICON_SIZE)
		icon.texture = icon:CreateTexture(nil, "ARTWORK")
		icon.texture:SetAllPoints()
		icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
		icon.cooldown:SetAllPoints()
		icon.cooldown:SetReverse(true)
		icon.cooldown:SetHideCountdownNumbers(true)
		icon.cooldown.noCooldownCount = true
		panelIcons[usedIcons] = icon
	end
	icon:ClearAllPoints()
	icon:Show()
	return icon
end

local function ReleasePanelParts()
	for i = 1, usedStrings do
		panelStrings[i]:Hide()
	end
	for i = 1, usedIcons do
		panelIcons[i].cooldown:Clear()
		panelIcons[i]:Hide()
	end
	usedStrings, usedIcons = 0, 0
end

--[[
    Grey and faded with no buff, or in color with the sliver of what's left.
    A low buff that has since run out turns grey too.
]]
local function SetBuffIcon(icon, texture, expires, duration)
	icon.texture:SetTexture(texture)
	local now = GetTime()
	if expires and expires > now and duration and duration > 0 then
		icon.texture:SetDesaturated(false)
		icon:SetAlpha(1)
		icon.cooldown:SetCooldown(expires - duration, duration)
	else
		icon.texture:SetDesaturated(true)
		icon:SetAlpha(MISSING_ALPHA)
		icon.cooldown:Clear()
	end
end

--[[
    Where a click's ask goes, by name, for its hint: the group chat
    ns:GetGroupChatChannel picks.
]]
local function GroupChatName()
	local channel = ns:GetGroupChatChannel()
	if channel == "RAID" then
		return RAID
	elseif channel == "INSTANCE_CHAT" then
		return ns.IsInPvPInstance() and BATTLEGROUND or INSTANCE or GROUP
	end
	return PARTY
end

local function FillPanel(spec)
	ReleasePanelParts()
	local width, y = 0, 0

	-- A line of text at the left padding; returns its width.
	local function PutLeft(text, top)
		local line = AcquireString()
		line:SetText(text)
		line:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING, -(PADDING + top))
		return line:GetStringWidth()
	end
	-- A line of text against the right padding; returns its width.
	local function PutRight(text, top)
		local line = AcquireString()
		line:SetText(text)
		line:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PADDING, -(PADDING + top))
		return line:GetStringWidth()
	end

	-- The header: the buff's name in gold, then a blank line.
	width = PutLeft(GetColor("TITLE") .. spec.spellName .. "|r", y)
	y = y + LINE_HEIGHT * 2

	-- Party by party: the header in gold, then each name in its class color, the buff's icon on the right.
	local texture = C_Spell.GetSpellTexture(spec.spellId)
	for index, group in ipairs(spec.groups) do
		if index > 1 then
			y = y + SECTION_GAP
		end
		width = math.max(width, PutLeft(GetColor("TITLE") .. group.label .. "|r", y))
		y = y + LINE_HEIGHT
		for row, name in ipairs(group.names) do
			local color = ns.GetClassColor(group.classes[row]) or GetColor("TEXT")
			local nameWidth = PutLeft(color .. name .. "|r", y)
			local icon = AcquireIcon()
			-- Centered on the text's line, which starts at its top.
			icon:SetPoint("RIGHT", panel, "TOPRIGHT", -PADDING, -(PADDING + y + LINE_HEIGHT / 2 - 2))
			SetBuffIcon(icon, texture, group.expires[row], group.durations[row])
			width = math.max(width, nameWidth + COLUMN_GAP + ICON_SIZE)
			y = y + LINE_HEIGHT
		end
	end

	--[[
	    The clicks, both sides in the interaction blue, muted while that ask
	    is still cooling down. Your own class's buff, with nobody else of it
	    in the group, has no one to whisper, so that hint is left out.
	]]
	local function PutHint(keybind, action, ready)
		local color = ready and GetColor("INFO") or GetColor("MUTED")
		width = math.max(width, PutLeft(color .. keybind .. "|r", y) + COLUMN_GAP + PutRight(color .. action .. "|r", y))
		y = y + LINE_HEIGHT
	end
	-- A blank line above the hints.
	y = y + LINE_HEIGHT
	PutHint(L["TOOLTIP_KEY_CLICK"], L["BUFF_DUTY_OTHERS_HINT_ASK"]:format(GroupChatName()), ns.CanAskForBuff("group", spec.key))
	if spec.recipients[1] then
		PutHint(L["TOOLTIP_KEY_RIGHT_CLICK"], L["BUFF_DUTY_OTHERS_HINT_WHISPER"], ns.CanAskForBuff("whisper", spec.key))
	end

	panel:SetSize(math.ceil(width) + PADDING * 2, math.ceil(y) + PADDING * 2)
end

local function StopRefresh()
	if refreshTicker then
		refreshTicker:Cancel()
		refreshTicker = nil
	end
end

function ns.HideBuffDutyRoster()
	StopRefresh()
	if panel then
		panel:Hide()
		panel.owner = nil
	end
end

-- Redraws the open panel from its icon's current spec, or closes it once the mouse has left or the icon is gone.
local function RefreshPanel()
	local owner = panel and panel.owner
	if not owner or not panel:IsShown() or not owner:IsShown() or not owner.spec or not owner:IsMouseOver() then
		ns.HideBuffDutyRoster()
		return
	end
	FillPanel(owner.spec)
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

local function OnOtherIconEnter(self)
	if not self.spec then
		return
	end
	if not panel then
		CreatePanel()
	end
	StopRefresh()
	panel.owner = self
	FillPanel(self.spec)
	-- Where GameTooltip's ANCHOR_RIGHT would put it: up and to the right of the icon.
	panel:ClearAllPoints()
	panel:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
	panel:Show()
	refreshTicker = C_Timer.NewTicker(REFRESH_INTERVAL, RefreshPanel)
end

-- Click asks the group; right-click whispers the class. Each waits out its own cooldown.
local function OnOtherIconClick(self, mouseButton)
	local spec = self.spec
	if not spec then
		return
	end
	if mouseButton == "RightButton" then
		ns.WhisperOtherClassBuff(spec)
	else
		ns.AskGroupForBuff(spec)
	end
	if panel and panel.owner == self and panel:IsShown() then
		FillPanel(spec)
	end
end

-- `parent` is the window's content frame (Buff-Duty-Frame.lua), which every icon sits in.
function ns.AcquireBuffDutyOtherIcon(parent)
	usedOtherIcons = usedOtherIcons + 1
	local button = otherIcons[usedOtherIcons]
	if not button then
		button = CreateFrame("Button", nil, parent)
		button:SetSize(ICON_SIZE, ICON_SIZE)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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
