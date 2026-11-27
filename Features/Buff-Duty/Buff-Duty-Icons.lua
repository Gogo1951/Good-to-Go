local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE

local ASK_MARK_TEXTURE = "Interface/GossipFrame/GossipGossipIcon"
local ASK_MARK_SIZE = 8 -- on the Spacing Scale, small enough to leave the icon readable under it

local pool = ns.buffDutyIconPool
local icons = pool.buttons

local function OnIconEnter(self)
	local spec = self.spec
	if not spec then
		return
	end
	ns.SetTooltipOwner(self)
	if spec.itemId then
		GameTooltip:SetItemByID(spec.itemId)
	else
		GameTooltip:SetSpellByID(spec.spellId)
	end
	GameTooltip:AddLine(" ")
	-- sectionTitle is nil on a party's rows, so a party member's icons go by their name.
	GameTooltip:AddLine(GetColor("TITLE") .. (spec.sectionTitle or spec.targetName or "") .. "|r")
	-- Names who needs it, since the raid group's rows may be folded away or covered by it.
	if spec.count and spec.needs then
		GameTooltip:AddLine(L["BUFF_DUTY_TOOLTIP_NEEDS"]:format(ns.JoinNames(spec.needs)), 1, 1, 1, true)
	end
	if spec.ask then
		local hint
		local at = ns.BuffDuty.AskedAt(spec.ask.guid, spec.askKey)
		if at then
			local minutes = math.ceil((at + ns.BuffDuty.ASK_TARGET_COOLDOWN - GetTime()) / 60)
			hint = L["BUFF_DUTY_TOOLTIP_ASKED"]:format(spec.targetName, minutes)
		else
			hint = L["BUFF_DUTY_TOOLTIP_ASK_TARGET"]:format(spec.targetName)
		end
		GameTooltip:AddLine(GetColor("HELP") .. hint .. "|r", 1, 1, 1, true)
	elseif spec.hint then
		GameTooltip:AddLine(GetColor("HELP") .. spec.hint .. "|r", 1, 1, 1, true)
	else
		local job = spec.isGroup and L["BUFF_DUTY_TOOLTIP_GROUP"] or L["BUFF_DUTY_TOOLTIP_CAST"]
		GameTooltip:AddDoubleLine(
			GetColor("INFO") .. job:format(spec.targetName) .. "|r",
			GetColor("MUTED") .. L["TOOLTIP_KEY_CLICK"] .. "|r"
		)
		if spec.favorGUID then
			GameTooltip:AddDoubleLine(
				GetColor("INFO") .. L["BUFF_DUTY_TOOLTIP_TAKE_OFF"] .. "|r",
				GetColor("MUTED") .. L["TOOLTIP_KEY_RIGHT_CLICK"] .. "|r"
			)
		end
	end
	GameTooltip:Show()
end

local function OnIconLeave()
	GameTooltip:Hide()
end

-- PreClick, never PostClick: the secure click raises "replace your enchant?" before PostClick runs.
local function OnIconPreClick(self, button, down)
	if button ~= "LeftButton" or not self.spec then
		return
	end
	-- An ask casts nothing; it whispers on the up half only, since the button hears both.
	if self.spec.ask then
		if not down then
			ns.AskTargetForBuffs(self.spec)
		end
		return
	end
	if self.spec.pvpFlagged then
		if not down then
			ns:PrintMessage(L["BUFF_DUTY_PVP_FLAGGED"]:format(self.spec.pvpFlagged))
		end
		return
	end
	if self.spec.confirmReplace then
		ns.ExpectReplaceEnchant()
	end
	ns.NoteBuffCastAttempt(self.spec)
end

-- Up half only: buttons register both up and down.
local function OnIconPostClick(self, button, down)
	if button == "RightButton" and not down and self.spec and self.spec.favorGUID then
		ns.DismissFavor(self.spec.favorGUID)
	end
end

function ns.AcquireBuffDutyIcon()
	pool.used = pool.used + 1
	local button = icons[pool.used]
	if not button then
		button = CreateFrame("Button", nil, pool.content, "SecureActionButtonTemplate")
		button:SetSize(ICON_SIZE, ICON_SIZE)
		--[[
		    Both halves: the template acts on the one ActionButtonUseKeyDown names,
		    so "AnyUp" alone leaves the button dead for anyone casting on key down.
		]]
		button:RegisterForClicks("AnyUp", "AnyDown")
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		-- Trims the baked-in border every spell icon carries.
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		-- A plain child of the secure button, so it updates freely in combat.
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cooldown:SetAllPoints()
		button.cooldown:SetHideCountdownNumbers(false)
		-- The template's numbers are sized for a 36-pixel bar button; ours is 20 (Data.BUFF_DUTY_ICON_SIZE).
		if button.cooldown.SetCountdownFont then
			button.cooldown:SetCountdownFont("GameFontHighlightSmallOutline")
		end
		-- Red and centered: the count is a gap, not a stack. Over the swipe, so a group running low still shows it.
		local over = CreateFrame("Frame", nil, button)
		over:SetAllPoints()
		over:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
		button.count = over:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		button.count:SetPoint("CENTER", button, "CENTER", 0, 0)
		local red = ns.COLORS_RGB.OFF
		button.count:SetTextColor(red.r, red.g, red.b)
		button.askMark = over:CreateTexture(nil, "OVERLAY")
		button.askMark:SetSize(ASK_MARK_SIZE, ASK_MARK_SIZE)
		button.askMark:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
		button.askMark:SetTexture(ASK_MARK_TEXTURE)
		button.askMark:Hide()
		button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
		button:SetScript("OnEnter", OnIconEnter)
		button:SetScript("OnLeave", OnIconLeave)
		button:SetScript("PreClick", OnIconPreClick)
		button:SetScript("PostClick", OnIconPostClick)
		icons[pool.used] = button
	end
	return button
end

function ns.SetBuffDutyIcon(button, spec)
	button.spec = spec
	if spec.itemId then
		button.icon:SetTexture(C_Item.GetItemIconByID(spec.itemId))
	else
		button.icon:SetTexture(C_Spell.GetSpellTexture(spec.spellId))
	end
	button.count:SetText(spec.count or "")
	button.askMark:SetShown(spec.ask ~= nil)
	spec.pvpFlagged = ns.BuffDuty.PvPFlaggedTarget(spec)
	ns.SetBuffButtonAttributes(button, spec)
	button:Show()
end
