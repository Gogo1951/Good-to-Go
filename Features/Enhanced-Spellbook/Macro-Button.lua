local _, ns = ...
local BODY = ns.COLORS_RGB.BODY
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip

local TILE_WIDTH, TILE_HEIGHT, ICON_SIZE = 224, 32, 32
ns.TILE_WIDTH, ns.TILE_HEIGHT = TILE_WIDTH, TILE_HEIGHT

local INK_COLOR = ns.INK_COLOR
local INFO = ns.COLORS_RGB.INFO
local EDITING_FILL_ALPHA = 0.12 -- the wash inside the outline on the tile the Conditionals panel is open for
local PICK_DIMMED_ALPHA = 0.35 -- a tile pick mode can't take
local FADED_INK_COLOR = ns.FADED_INK_COLOR

--[[
	Camelot's SpellBookItemTemplate atlases, anchored as offsets from the icon; each falls back to an old file
	texture where this build lacks it.
]]
local ATLAS_FRAME = "spellbook-item-iconframe"
local ATLAS_FRAME_INACTIVE = "spellbook-item-iconframe-inactive"
local ATLAS_FRAME_HOVER = "spellbook-item-iconframe-hover"
local ATLAS_GLOW = "spellbook-item-unassigned-glow"
local ATLAS_MASK = "spellbook-item-spellicon-mask"

local function HasAtlas(atlas)
	return C_Texture.GetAtlasInfo(atlas) ~= nil
end

local function SetAroundIcon(texture, icon, left, top, right, bottom)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", icon, "TOPLEFT", -left, top)
	texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", right, -bottom)
end

-- Returns true when the atlas was used.
local function SetAtlasOr(texture, atlas, file, scale, icon)
	if HasAtlas(atlas) then
		texture:SetAtlas(atlas, false)
		return true
	end
	if file then
		texture:SetTexture(file)
		texture:SetSize(ICON_SIZE * scale, ICON_SIZE * scale)
		texture:SetPoint("CENTER", icon)
	end
	return false
end

--[[
	A fixed rank first, else a learned spell by name, so its highest known rank shows; an unlearned one by ID.
	nil for a consumable, which leads with its item's tooltip.
]]
local function TooltipSpellID(macro)
	if macro.consumable then
		return nil
	elseif macro.unlearned then
		return macro.spellID
	end
	local fixedID = not macro.rangedAttacks and ns.FixedRankID(macro)
	if fixedID then
		return fixedID
	end
	local name = macro.name
	if macro.rangedAttacks then
		name = ns.CastSpellName(macro) -- the Shoot macro shows the attack for the weapon equipped
	end
	local info = name and C_Spell.GetSpellInfo(name)
	return info and info.spellID or macro.spellID
end

local function MenuOpen()
	return ns.IsMacroMenuPanelsShown() or (Menu ~= nil and Menu.GetManager ~= nil and Menu.GetManager():IsAnyMenuOpen())
end

-- Middle-click's reset; data is the macro.
StaticPopupDialogs.GOODTOGO_RESET_MACRO = {
	text = L["MENU_RESET_MACRO_CONFIRM"],
	button1 = L["POPUP_RESET"],
	button2 = CANCEL,
	OnAccept = function(_, macro)
		ns.ResetMacroSettings(macro)
		ns:RefreshMacros()
		ns:PrintMessage(L["CHAT_MACRO_OPTIONS_RESET"]:format(macro.label or macro.name))
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function ResetOptions(macro)
	StaticPopup_Show("GOODTOGO_RESET_MACRO", macro.label or macro.name, nil, macro)
end

-- Tiles are reused across refreshes; SetMacro points one at a macro.
local function CreateMacroButton(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(TILE_WIDTH, TILE_HEIGHT)
	button.icon = button:CreateTexture(nil, "ARTWORK", nil, -1)
	button.icon:SetSize(ICON_SIZE, ICON_SIZE)
	button.icon:SetPoint("LEFT", 0, 0)
	if HasAtlas(ATLAS_MASK) then
		local mask = button:CreateMaskTexture()
		mask:SetAtlas(ATLAS_MASK, false)
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
	-- the frame's curl hangs off the icon's bottom left
	button.border = button:CreateTexture(nil, "OVERLAY", nil, 1)
	if SetAtlasOr(button.border, ATLAS_FRAME, "Interface\\Buttons\\UI-Quickslot2", 1.6, button.icon) then
		SetAroundIcon(button.border, button.icon, 11, 3, 3, 8)
	end
	-- glow on a macro that isn't on the action bars yet, like the native page's unassigned spells
	button.glow = button:CreateTexture(nil, "OVERLAY", nil, 5)
	if SetAtlasOr(button.glow, ATLAS_GLOW, "Interface\\Buttons\\UI-ActionButton-Border", 1.8, button.icon) then
		SetAroundIcon(button.glow, button.icon, 5, 4, 4, 4)
	else
		button.glow:SetBlendMode("ADD")
		button.glow:SetVertexColor(1, 0.82, 0) -- the texture is white; Blizzard tints it per use
	end
	button.glow:Hide()
	-- the open docked panel's outline and wash, as the tile's own textures so the wash sits under icon and name
	button.editing = {}
	local wash = button:CreateTexture(nil, "BACKGROUND", nil, -8)
	wash:SetColorTexture(INFO.r, INFO.g, INFO.b, EDITING_FILL_ALPHA)
	wash:SetPoint("TOPLEFT", -4, 4)
	wash:SetPoint("BOTTOMRIGHT", 4, -4)
	button.editing[1] = wash
	for _, edge in ipairs({
		{ "TOPLEFT", "TOPRIGHT", "SetHeight" },
		{ "BOTTOMLEFT", "BOTTOMRIGHT", "SetHeight" },
		{ "TOPLEFT", "BOTTOMLEFT", "SetWidth" },
		{ "TOPRIGHT", "BOTTOMRIGHT", "SetWidth" },
	}) do
		local line = button:CreateTexture(nil, "OVERLAY", nil, 7)
		line:SetColorTexture(INFO.r, INFO.g, INFO.b)
		line:SetPoint(edge[1], wash, edge[1])
		line:SetPoint(edge[2], wash, edge[2])
		line[edge[3]](line, 2)
		button.editing[#button.editing + 1] = line
	end
	-- fades in and out like the spellbook's glow on new spells; UpdateGlow starts it
	button.pulse = button.glow:CreateAnimationGroup()
	button.pulse:SetLooping("BOUNCE")
	local fade = button.pulse:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0.2)
	fade:SetDuration(0.5)
	fade:SetSmoothing("IN_OUT")
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	if HasAtlas(ATLAS_FRAME_HOVER) then
		highlight:SetAtlas(ATLAS_FRAME_HOVER, false)
	else
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetBlendMode("ADD")
	end
	SetAroundIcon(highlight, button.icon, 2, 2, 2, 2)

	--[[
		no font shadow, which reads as a smudge on parchment; always high by the icon, so it sits in the same place
		with a note under it or none
	]]
	button.name = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	button.name:SetShadowOffset(0, 0)
	button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 8, -2)
	button.name:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -3)
	button.name:SetJustifyH("LEFT")
	button.name:SetWordWrap(false)
	-- the line's box drops a unit below the icon, its descender room, so the letters' foot meets the icon's bottom
	button.subText = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	button.subText:SetShadowOffset(0, 0)
	button.subText:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 8, -1)
	button.subText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.subText:SetJustifyH("LEFT")
	button.subText:SetWordWrap(false)

	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", function(self)
		ns.PickupMacro(self.macro)
	end)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	button:SetScript("OnClick", function(self, mouseButton)
		-- in pick mode a click gives the panel this spell and any other button cancels; a drag still places the macro
		if ns.IsPickingSpell() then
			HideTooltip(self)
			if mouseButton == "LeftButton" then
				ns.PickSpell(self.macro)
			else
				ns.CancelSpellPick()
			end
			return
		end
		if mouseButton == "RightButton" then
			HideTooltip(self)
			ns.ShowMacroMenu(self)
		elseif mouseButton == "MiddleButton" then
			if ns.HasOptions(self.macro) then
				HideTooltip(self)
				ResetOptions(self.macro)
			end
		else
			ns.PickupMacro(self.macro)
		end
	end)
	button:SetScript("OnEnter", function(self)
		-- an open menu stands alone: no macro's tooltip shows over or beside it
		if MenuOpen() then
			return
		end
		ns.SetTooltipOwner(self)
		local spellID = TooltipSpellID(self.macro)
		if self.macro.itemLink then
			GameTooltip:SetHyperlink(self.macro.itemLink)
		elseif spellID then
			-- the tile adds its own ranks, marking the one it casts, so the tooltip hook stays out
			ns.spellTooltipHasOwnRanks = true
			GameTooltip:SetSpellByID(spellID)
			if GameTooltip:NumLines() == 0 then
				GameTooltip:SetHyperlink("spell:" .. spellID)
			end
			ns.spellTooltipHasOwnRanks = nil
			if not self.macro.consumable and ns.AddSpellRanksTooltip then
				ns.AddSpellRanksTooltip(spellID, nil, GameTooltip:NumLines() > 0)
			end
		end
		if GameTooltip:NumLines() > 0 then
			GameTooltip:AddLine(" ")
		end
		ns.AddSpellbookTooltipTitle(L["TOOLTIP_MACRO_HEADING"]:format(self.macro.label or self.macro.name))
		-- what the macro does beyond its text, set off by a blank line above
		local notes = {}
		if not self.macro.consumable then
			notes[#notes + 1] = ns.MacroOptionsOnLine(self.macro)
		end
		if #notes > 0 then
			GameTooltip:AddLine(" ")
			for _, note in ipairs(notes) do
				GameTooltip:AddLine(note, nil, nil, nil, true)
			end
		end
		-- the macro text always has a blank line above it, notes or none
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(ns.UntaggedBody(self.macro.body), BODY.r, BODY.g, BODY.b, true)
		GameTooltip:AddLine(" ")
		-- a consumable's class notes, as the mini-map button's tooltip shows them ("Mage", Food & Water Macros)
		if self.macro.consumable and ns.AddConsumableMacroNotes(GameTooltip, self.macro.type) then
			GameTooltip:AddLine(" ")
		end
		if self.blockReason == "long" then
			local line = L["TOOLTIP_TOO_LONG"]:format(self.blockLength, ns.MACRO_BODY_MAX_LENGTH)
			GameTooltip:AddLine(GetColor("OFF") .. line .. "|r", nil, nil, nil, true)
			GameTooltip:AddLine(" ")
		elseif self.macro.unlearned then
			GameTooltip:AddLine(GetColor("OFF") .. L["TOOLTIP_NOT_LEARNED"] .. "|r", nil, nil, nil, true)
			local when = self.macro.learnTalent and L["TOOLTIP_LEARN_TALENT"]
				or self.macro.learnLevel and L["TOOLTIP_LEARN_LEVEL"]:format(self.macro.learnLevel)
			if when then
				GameTooltip:AddLine(GetColor("HELP") .. when .. "|r", nil, nil, nil, true)
			end
			GameTooltip:AddLine(" ")
		elseif self.glow:IsShown() then
			GameTooltip:AddLine(GetColor("HELP") .. L["TOOLTIP_NOT_ON_BARS"] .. "|r", nil, nil, nil, true)
			GameTooltip:AddLine(" ")
		end
		-- in pick mode a click picks the spell, or can't, and a right-click cancels
		if ns.IsPickingSpell() then
			if ns.PickSpellOf(self.macro) then
				ns.AddSpellbookClickLine(ns.PickActionText(), L["TOOLTIP_KEY_CLICK"])
			else
				GameTooltip:AddLine(GetColor("OFF") .. ns.CannotPickText() .. "|r", nil, nil, nil, true)
			end
			ns.AddSpellbookClickLine(L["CONDITIONALS_ACTION_CANCEL"], L["TOOLTIP_KEY_RIGHT_CLICK"])
			GameTooltip:Show()
			return
		end
		ns.AddSpellbookClickLine(L["TOOLTIP_ACTION_PLACE_ON_BAR"], L["TOOLTIP_KEY_CLICK_DRAG"])
		if ns.HasOptions(self.macro) then
			ns.AddSpellbookClickLine(L["TOOLTIP_ACTION_MACRO_OPTIONS"], L["TOOLTIP_KEY_RIGHT_CLICK"])
			ns.AddSpellbookClickLine(L["TOOLTIP_ACTION_RESET_OPTIONS"], L["TOOLTIP_KEY_MIDDLE_CLICK"])
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", HideTooltip)
	button:SetScript("OnHide", HideTooltip)
	return button
end

-- The stance bar's forms (noGlow) and macros marked placed never glow.
function ns.MacroGlows(macro, bars)
	return not macro.noGlow
		and not macro.unlearned
		and not ns.IsMarkedPlaced(macro)
		and not ns.IsOnActionBars(macro, bars)
end

-- On any page: when Mark All Spells as Placed has work to do.
function ns.AnyMacroGlows(bars)
	for _, macro in ipairs(ns.macros) do
		if ns.MacroGlows(macro, bars) then
			return true
		end
	end
	for _, macro in ipairs(ns.ConsumablePageMacros()) do
		if ns.MacroGlows(macro, bars) then
			return true
		end
	end
	return false
end

local function UpdateGlow(button, bars)
	local shown = ns.MacroGlows(button.macro, bars)
	button.glow:SetShown(shown)
	if not shown then
		button.pulse:Stop()
	elseif not button.pulse:IsPlaying() then
		button.pulse:Play()
	end
end

local function NoteText(button, macro)
	if button.blockReason then
		return GetColor("OFF") .. L["SUBTEXT_TOO_LONG"] .. "|r"
	elseif macro.consumable then
		return L[macro.dynamicRank and "SUBTEXT_DYNAMIC_RANK_ITEM" or "SUBTEXT_DYNAMIC_ITEM"]
	end
	-- "Max Rank", since the macro casts the highest rank known, unless a fixed or dynamic rank names its own
	local spellID = TooltipSpellID(macro)
	local spellSubText = spellID and C_Spell.GetSpellSubtext(spellID) or ""
	local maxRank = not macro.unlearned
		and spellSubText:match("%d")
		and not ns.FixedRank(macro)
		and not ns.IsOptionOn(macro, "targetRank")
	local lead = maxRank and (ns.LearnableRankNote(macro) or L["SUBTEXT_MAX_RANK"]) or nil
	local subText = ns.MacroOptionSubText(macro, lead)
	if subText then
		return subText
	elseif macro.unlearned and (macro.learnTalent or macro.learnLevel) then
		-- when it can be learned, in place of its "Rank 1"
		return macro.learnTalent and L["SUBTEXT_TALENT"] or L["SUBTEXT_LEARN_LEVEL"]:format(macro.learnLevel)
	elseif spellSubText ~= "" then
		return spellSubText
	end
	return nil
end

-- bars is a ns.ScanActionBars() result, read here when nil.
local function SetMacro(button, macro, bars)
	-- Consumable Macros rewrites a consumable's macro as the bags change, so its item is read again at each draw
	if macro.consumable then
		ns.ReadConsumableMacro(macro)
	end
	button.macro = macro
	button.blockReason, button.blockLength = ns.MacroBlockReason(macro)
	UpdateGlow(button, bars or ns.ScanActionBars())
	button.icon:SetTexture(macro.icon)
	button.icon:SetDesaturated(macro.unlearned == true)
	local frameAtlas = macro.unlearned and ATLAS_FRAME_INACTIVE or ATLAS_FRAME
	if HasAtlas(frameAtlas) then
		button.border:SetAtlas(frameAtlas, false)
	end
	-- a Duplicate copy shows its number, a profession its specialization; rank versions keep the spell's name
	button.name:SetText(macro.label or macro.name)
	button.name:SetTextColor(unpack(macro.unlearned and FADED_INK_COLOR or INK_COLOR))
	button.subText:SetText(NoteText(button, macro))
	button.subText:SetTextColor(unpack(FADED_INK_COLOR))
	local editing = ns.IsConditionalsPanelFor(macro) or (ns.IsCastSequencePanelFor and ns.IsCastSequencePanelFor(macro))
	for _, texture in ipairs(button.editing) do
		texture:SetShown(editing)
	end
	button:SetAlpha(ns.IsPickingSpell() and not ns.PickSpellOf(macro) and PICK_DIMMED_ALPHA or 1)
end

ns.CreateMacroButton = CreateMacroButton
ns.UpdateMacroGlow = UpdateGlow
ns.SetMacroButton = SetMacro
