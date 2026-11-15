local _, ns = ...
local Data = ns.Data
local L = ns.L

local Kit = ns.MenuKit

--[[
    Buff-Duty-Party-Buffs -- the Buff Duty window's Party-Buffs icons: a raid
    buff, any class's, numbered with how many in your group need it
    (Buff-Duty-Other-Classes.lua counts). Clicking an icon asks the party or
    raid for the buff; right-clicking whispers the players of that class who
    can cast it, when anyone else can. Buff-Duty-Layout.lua places the icons on
    the Party-Buffs header.

    Hovering opens a menu on the mini-map menu's kit (Features/Menu-Kit.lua):
    the buff, then who needs it party by party, each name in its class color
    with the minutes left on the right, or Missing; then the two asks as rows,
    each naming the click that does the same on the icon. It stays open while
    the cursor is over the icon or the menu and closes a moment after it
    leaves both, so the mouse can reach its rows. The icon's own clicks still
    work without it.
]]

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE

-- How long the menu waits after the cursor leaves the icon and the menu, as the mini-map menu does.
local CLOSE_DELAY = 0.4

--[[
    How often an open menu redraws, so the minutes count down, a buff that runs
    out turns to Missing, an ask greyed by its cooldown comes back, and a redraw
    of the window (new count, icon gone) shows up while it's open.
]]
local REFRESH_INTERVAL = 0.5

local menu
local state = { owner = nil, idle = 0, sinceRefresh = 0 }
-- The Party-Buffs icons: plain buttons, since a chat line isn't protected.
local otherIcons, usedOtherIcons = {}, 0

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

--[[
    Where a click's ask goes, by name, for its row: the group chat
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

-- Up to this many players are named on the whisper row; more are counted instead.
local WHISPER_MAX_NAMES = 2

-- Who the whisper row reaches: one or two names, or how many past that.
local function WhisperTargets(recipients)
	if #recipients <= WHISPER_MAX_NAMES then
		return ns.JoinNames(recipients)
	end
	return L["BUFF_DUTY_OTHERS_ASK_PEOPLE"]:format(#recipients)
end

-- What a name's row says on the right: the whole minutes left, silver, or Missing in gray once it has run out.
local function TimeLeft(expires)
	local now = GetTime()
	if expires and expires > now then
		return L["BUFF_DUTY_OTHERS_MINUTES"]:format(math.ceil((expires - now) / 60)), "HELP"
	end
	return L["BUFF_DUTY_OTHERS_MISSING"], "MUTED"
end

local Render

--[[
    An ask as a row, both sides in the interaction blue, muted while that ask
    is still cooling down; clicking it does what the icon's click does.
]]
local function AskRow(text, keybind, ready, run)
	local color = ready and "INFO" or "MUTED"
	return {
		kind = "action",
		left = text,
		right = keybind,
		leftColor = color,
		rightColor = color,
		onClick = function()
			run()
			Render()
		end,
	}
end

local function BuildEntries(spec)
	local texture = C_Spell.GetSpellTexture(spec.spellId)
	local entries = {
		{ kind = "header", left = (texture and "|T" .. texture .. ":0|t " or "") .. spec.spellName },
	}
	for _, group in ipairs(spec.groups) do
		entries[#entries + 1] = { kind = "section", left = group.label }
		for row, name in ipairs(group.names) do
			local color = ns.GetClassColor(group.classes[row]) or ns.GetColor("TEXT")
			local right, rightColor = TimeLeft(group.expires[row])
			entries[#entries + 1] = {
				kind = "action",
				left = color .. name .. "|r",
				right = right,
				rightColor = rightColor,
			}
		end
	end

	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = AskRow(
		L["BUFF_DUTY_OTHERS_HINT_ASK"]:format(GroupChatName()),
		L["TOOLTIP_KEY_CLICK"],
		ns.CanAskForBuff("group", spec.key),
		function()
			ns.AskGroupForBuff(spec)
		end
	)
	-- Your own class's buff, with nobody else of it in the group, has no one to whisper, so that row is left out.
	if spec.recipients[1] then
		entries[#entries + 1] = AskRow(
			L["BUFF_DUTY_OTHERS_HINT_WHISPER"]:format(WhisperTargets(spec.recipients)),
			L["TOOLTIP_KEY_RIGHT_CLICK"],
			ns.CanAskForBuff("whisper", spec.key),
			function()
				ns.WhisperOtherClassBuff(spec)
			end
		)
	end
	return entries
end

function ns.HideBuffDutyRoster()
	if menu then
		menu:Hide()
	end
end

-- Redraws the open menu from its icon's current spec, or closes it once the icon is gone.
function Render()
	local owner = state.owner
	if not menu or not menu:IsShown() then
		return
	end
	if not owner or not owner:IsVisible() or not owner.spec then
		menu:Hide()
		return
	end
	state.sinceRefresh = 0
	menu:Render(BuildEntries(owner.spec))
end

local function OnMenuUpdate(self, elapsed)
	local owner = state.owner
	if not owner or not owner:IsVisible() or not owner.spec then
		self:Hide()
		return
	end
	if Kit.IsCursorOver(owner) or Kit.IsCursorOver(self) then
		state.idle = 0
	else
		state.idle = state.idle + elapsed
		if state.idle >= CLOSE_DELAY then
			self:Hide()
			return
		end
	end
	state.sinceRefresh = state.sinceRefresh + elapsed
	if state.sinceRefresh >= REFRESH_INTERVAL then
		Render()
	end
end

local function CreateMenu()
	menu = Kit.CreatePanel("GoodToGoPartyBuffsMenu", UIParent)
	-- Escape closes it, as it does any game menu.
	table.insert(UISpecialFrames, menu:GetName())
	menu:SetScript("OnUpdate", OnMenuUpdate)
	menu:SetScript("OnHide", function()
		state.owner = nil
	end)
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

local function OnOtherIconEnter(self)
	if not self.spec then
		return
	end
	if not menu then
		CreateMenu()
	end
	state.idle = 0
	if state.owner ~= self or not menu:IsShown() then
		state.owner = self
		-- Up and to the right of the icon, where GameTooltip's ANCHOR_RIGHT would put a tooltip.
		menu:ClearAllPoints()
		menu:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
	end
	menu:Show()
	Render()
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
	if state.owner == self then
		Render()
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
