local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    Buff-Duty-Icons -- the Buff Duty window's list icons: the secure
    click-to-cast buttons, made once and kept in the shared pool
    (ns.buffDutyIconPool), and their tooltip and click scripts.
    ns.AcquireBuffDutyIcon hands out the next free button; ns.SetBuffDutyIcon
    points it at a buff. Buff-Duty-Layout.lua places them.
]]

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE

-- The gossip window's speech bubble, marking an icon that whispers an ask rather than casting.
local ASK_MARK_TEXTURE = "Interface/GossipFrame/GossipGossipIcon"
local ASK_MARK_SIZE = 8 -- on the Spacing Scale, small enough to leave the icon readable under it

-- The list's icons, shared with the window and the cooldown and range passes (Buff-Duty-Icon-State.lua).
local pool = ns.buffDutyIconPool
local icons = pool.buttons

local function OnIconEnter(self)
	local spec = self.spec
	if not spec then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if spec.itemId then
		GameTooltip:SetItemByID(spec.itemId)
	else
		GameTooltip:SetSpellByID(spec.spellId)
	end
	GameTooltip:AddLine(" ")
	--[[
	    Who the click lands on, not which click: every icon here casts on a
	    click. A Self Buffs weapon or Soulstone icon brings its own line, already
	    worded.
	]]
	local hint = spec.hint
	if spec.ask then
		-- An ask: who the whisper goes to, or how long until they can be asked again.
		local at = ns.BuffDuty.AskedAt(spec.ask.guid, spec.askKey)
		if at then
			local minutes = math.ceil((at + ns.BuffDuty.ASK_TARGET_COOLDOWN - GetTime()) / 60)
			hint = L["BUFF_DUTY_TOOLTIP_ASKED"]:format(spec.targetName, minutes)
		else
			hint = L["BUFF_DUTY_TOOLTIP_ASK_TARGET"]:format(spec.targetName)
		end
	elseif not hint then
		local text = (spec.favorGUID and L["BUFF_DUTY_TOOLTIP_FAVOR"])
			or (spec.isGroup and L["BUFF_DUTY_TOOLTIP_GROUP"])
			or L["BUFF_DUTY_TOOLTIP_CAST"]
		hint = text:format(spec.targetName)
	end
	GameTooltip:AddLine(GetColor("HELP") .. hint .. "|r", 1, 1, 1, true)
	-- A raid group icon names who needs it (Buff-Duty-Groups.lua's spec.needs), since its rows may be folded away or covered by it.
	if spec.count and spec.needs then
		GameTooltip:AddLine(
			GetColor("HELP") .. L["BUFF_DUTY_TOOLTIP_NEEDS"]:format(ns.JoinNames(spec.needs)) .. "|r",
			1,
			1,
			1,
			true
		)
	end
	GameTooltip:Show()
end

local function OnIconLeave()
	GameTooltip:Hide()
end

--[[
    PreClick, because the secure click fires the game's "replace your
    enchant?" question before PostClick runs (Buff-Duty-Weapons.lua answers it).
    Every cast is noted too, so a "more powerful spell" refusal can be pinned
    on who it was aimed at (ns.NoteBuffCastAttempt).
]]
local function OnIconPreClick(self, button, down)
	if button ~= "LeftButton" or not self.spec then
		return
	end
	--[[
	    An ask casts nothing (its attributes are cleared): the whisper goes
	    out here, on the up half only, since the button hears both.
	]]
	if self.spec.ask then
		if not down then
			ns.AskTargetForBuffs(self.spec)
		end
		return
	end
	if self.spec.confirmReplace then
		ns.ExpectReplaceEnchant()
	end
	ns.NoteBuffCastAttempt(self.spec)
end

--[[
    Right-click on a favor drops that stranger from the list. Buttons register
    both up and down (below), so this answers the up half only.
]]
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
		    Both halves: the secure template acts on the one ActionButtonUseKeyDown
		    names and ignores the other, so registering only "AnyUp" leaves the
		    button dead for anyone casting on key down.
		]]
		button:RegisterForClicks("AnyUp", "AnyDown")
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		-- Trims the baked-in border every spell icon carries.
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		--[[
		    The action bar's own swipe and countdown, so a buff still on cooldown
		    reads exactly as it would on a bar (OmniCC and friends pick it up too).
		    A plain child of the secure button, so it updates freely in combat.
		]]
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cooldown:SetAllPoints()
		button.cooldown:SetHideCountdownNumbers(false)
		-- The template's numbers are sized for a 36-pixel bar button; ours is 20 (Data.BUFF_DUTY_ICON_SIZE).
		if button.cooldown.SetCountdownFont then
			button.cooldown:SetCountdownFont("GameFontHighlightSmallOutline")
		end
		--[[
		    A raid group icon's count of members who need it, in the middle in
		    the palette's red like the Ask for Buffs icons: it's a gap, not a stack.
		    On a frame over the swipe, so a group running low still shows it.
		]]
		local over = CreateFrame("Frame", nil, button)
		over:SetAllPoints()
		over:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
		button.count = over:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		button.count:SetPoint("CENTER", button, "CENTER", 0, 0)
		local red = ns.COLORS_RGB.OFF
		button.count:SetTextColor(red.r, red.g, red.b)
		-- An ask icon's speech bubble, in the corner over the swipe, so it never reads as a cast.
		button.askMark = over:CreateTexture(nil, "OVERLAY")
		button.askMark:SetSize(ASK_MARK_SIZE, ASK_MARK_SIZE)
		button.askMark:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
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
	ns.SetBuffButtonAttributes(button, spec)
	button:Show()
end
