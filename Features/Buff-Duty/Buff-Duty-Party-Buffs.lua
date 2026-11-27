local _, ns = ...
local Data = ns.Data
local L = ns.L

local Kit = ns.MenuKit

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE

-- The Menu Kit's HOVER_CLOSE_DELAY, so the mouse can reach the menu's rows.
local CLOSE_DELAY = 0.5

-- The Menu Kit's MENU_GAP.
local MENU_GAP = 2

-- So minutes count down and a cooling ask comes back while the menu is open.
local REFRESH_INTERVAL = 0.5

local menu
local state = { owner = nil, idle = 0, sinceRefresh = 0 }
-- Plain buttons, since a chat line isn't protected.
local otherIcons, usedOtherIcons = {}, 0

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

local function GroupChatName()
	local channel = ns:GetGroupChatChannel()
	if channel == "RAID" then
		return RAID
	elseif channel == "INSTANCE_CHAT" then
		return ns.IsInPvPInstance() and BATTLEGROUND or INSTANCE or GROUP
	end
	return PARTY
end

-- More players than this are counted instead of named on the whisper row.
local WHISPER_MAX_NAMES = 2

local function WhisperTargets(recipients)
	if #recipients <= WHISPER_MAX_NAMES then
		return ns.JoinNames(recipients)
	end
	return L["BUFF_DUTY_OTHERS_ASK_PEOPLE"]:format(#recipients)
end

local function TimeLeft(expires)
	local now = GetTime()
	if expires and expires > now then
		return L["BUFF_DUTY_OTHERS_MINUTES"]:format(math.ceil((expires - now) / 60)), "VALUE"
	end
	return L["BUFF_DUTY_OTHERS_MISSING"], "MUTED"
end

local Render

local function AskRow(text, shortcut, ready, run)
	return {
		kind = "action",
		left = text,
		disabled = not ready,
		tooltip = function(tooltip)
			local help = ns.COLORS_RGB.HELP
			tooltip:SetText(shortcut, help.r, help.g, help.b, 1, true)
		end,
		onClick = function()
			run()
			menu:Hide()
		end,
	}
end

local function BuildEntries(spec)
	local texture = C_Spell.GetSpellTexture(spec.spellId)
	local entries = {
		{
			kind = "header",
			left = (texture and "|T" .. texture .. ":0|t " or "") .. spec.spellName,
			right = L["ADDON_SHORT_NAME"],
		},
	}
	for _, group in ipairs(spec.groups) do
		entries[#entries + 1] = { kind = "section", left = group.label }
		for row, name in ipairs(group.names) do
			local color = ns.GetClassColor(group.classes[row]) or ns.GetColor("TEXT")
			local right, rightColor = TimeLeft(group.expires[row])
			entries[#entries + 1] = {
				kind = "value",
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
		L["BUFF_DUTY_OTHERS_SHORTCUT_LEFT"],
		ns.CanAskForBuff("group", spec.key),
		function()
			ns.AskGroupForBuff(spec)
		end
	)
	-- Your own class's buff, with nobody else of it in the group, has no one to whisper.
	if spec.recipients[1] then
		entries[#entries + 1] = AskRow(
			L["BUFF_DUTY_OTHERS_HINT_WHISPER"]:format(WhisperTargets(spec.recipients)),
			L["BUFF_DUTY_OTHERS_SHORTCUT_RIGHT"],
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
		-- Away from the screen's nearest edges, as the mini-map menu opens off its button.
		local x, y = self:GetCenter()
		local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
		local openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
		local openDown = (y or 0) * scale > UIParent:GetHeight() / 2
		menu:ClearAllPoints()
		menu:SetPoint(
			(openDown and "TOP" or "BOTTOM") .. (openLeft and "RIGHT" or "LEFT"),
			self,
			(openDown and "BOTTOM" or "TOP") .. (openLeft and "LEFT" or "RIGHT"),
			openLeft and -MENU_GAP or MENU_GAP,
			openDown and -MENU_GAP or MENU_GAP
		)
		menu.tooltipAnchor = openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
	end
	menu:Show()
	Render()
end

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

function ns.AcquireBuffDutyOtherIcon(parent)
	usedOtherIcons = usedOtherIcons + 1
	local button = otherIcons[usedOtherIcons]
	if not button then
		button = CreateFrame("Button", nil, parent)
		-- Over a line's menu row, as the cast icons are.
		button:SetFrameLevel(parent:GetFrameLevel() + ns.buffDutyLayout.ABOVE_ROWS)
		button:SetSize(ICON_SIZE, ICON_SIZE)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		-- Red and centered: the count is a gap, not a stack.
		button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
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
