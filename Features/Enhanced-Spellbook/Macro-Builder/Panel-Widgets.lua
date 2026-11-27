local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local TITLE, BODY, INFO = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY, ns.COLORS_RGB.INFO
local HideTooltip = ns.HideTooltip
local PixelInset = ns.PixelInset

-- Loads before the panels, which read it as they load.

local SLOT_ICON = 16
local DROPDOWN_HEIGHT = 32
local DROPDOWN_TEXT_LEFT, CARET_SIZE, CARET_RIGHT = 8, 16, 4
local ROW_EDGE = 8 -- a row's edge to the grip at its left and the remove button at its right
local SLOT_TEXT_GAP = 8 -- a slot's icon to its text, and its text to the slot's right edge
local REMOVE_SIZE = 16
local HIGHLIGHT_ALPHA = 0.08
local GRIP_WIDTH, GRIP_HEIGHT = 8, 16
local DROP_ALPHA = 0.18 -- the wash on the row a dragged row will land on

local TEXTURE_CARET = "Interface\\Buttons\\Arrow-Down-Up"
local TEXTURE_REMOVE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local TEXTURE_REMOVE_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
local TEXTURE_REMOVE_HIGHLIGHT = "Interface\\Buttons\\UI-GroupLoot-Pass-Highlight"

-- Dark leather, so the panels read as part of the window rather than the parchment.
local COLORS = {}
for key, hex in pairs(ns.CONDITIONALS_COLORS) do
	COLORS[key] = ns.HexToColorList(hex)
end
local FIELD_FILL, FIELD_EDGE = COLORS.FIELD_FILL, COLORS.FIELD_EDGE
local ARROW_INK = COLORS.ARROW_INK

local Widgets = {}
ns.PanelWidgets = Widgets
Widgets.SLOT_ICON, Widgets.COLORS = SLOT_ICON, COLORS
Widgets.ROW_EDGE, Widgets.GRIP_WIDTH = ROW_EDGE, GRIP_WIDTH

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

local function Box(frame, fill, edge)
	local edgeTexture = frame:CreateTexture(nil, "BACKGROUND")
	edgeTexture:SetAllPoints()
	edgeTexture:SetColorTexture(unpack(edge))
	local fillTexture = frame:CreateTexture(nil, "BORDER")
	fillTexture:SetColorTexture(unpack(fill))
	PixelInset(fillTexture, frame, 1)
	return edgeTexture, fillTexture
end

local function ShowTip(owner, title, body, reason)
	ns.SetTooltipOwner(owner)
	GameTooltip:SetText(title, TITLE.r, TITLE.g, TITLE.b, 1, true)
	if body then
		GameTooltip:AddLine(body, BODY.r, BODY.g, BODY.b, true)
	end
	if reason then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(GetColor("OFF") .. reason .. "|r", nil, nil, nil, true)
	end
	GameTooltip:Show()
end

local function AddHighlight(button)
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetColorTexture(1, 1, 1, HIGHLIGHT_ALPHA)
	PixelInset(highlight, button, 1)
end

local function AddHint(keybind, action)
	GameTooltip:AddDoubleLine(GetColor("INFO") .. keybind .. "|r", GetColor("INFO") .. action .. "|r")
end

Widgets.Box, Widgets.ShowTip = Box, ShowTip

--------------------------------------------------------------------------------
-- Controls
--------------------------------------------------------------------------------

-- As wide as its value needs, passed through fit(width).
local function CreateDropdown(parent, fit, openMenu)
	local dropdown = CreateFrame("Button", nil, parent)
	dropdown:SetHeight(DROPDOWN_HEIGHT)
	Box(dropdown, FIELD_FILL, FIELD_EDGE)
	AddHighlight(dropdown)
	local caret = dropdown:CreateTexture(nil, "ARTWORK")
	caret:SetTexture(TEXTURE_CARET)
	caret:SetSize(CARET_SIZE, CARET_SIZE)
	caret:SetPoint("RIGHT", -CARET_RIGHT, 0)
	dropdown.text = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	dropdown.text:SetPoint("LEFT", DROPDOWN_TEXT_LEFT, 0)
	dropdown.text:SetJustifyH("LEFT")
	dropdown.text:SetWordWrap(false)
	function dropdown:SetLabel(label)
		self.text:SetText(label)
		local width = DROPDOWN_TEXT_LEFT + math.ceil(self.text:GetUnboundedStringWidth()) + 4 + CARET_SIZE + CARET_RIGHT
		self:SetWidth(fit(width))
	end
	dropdown:SetScript("OnClick", function(self)
		HideTooltip(self)
		openMenu(self)
	end)
	return dropdown, caret
end

local function CreateDropWash(row)
	local drop = row:CreateTexture(nil, "ARTWORK")
	drop:SetColorTexture(INFO.r, INFO.g, INFO.b, DROP_ALPHA)
	PixelInset(drop, row, 1)
	drop:Hide()
	return drop
end

-- Let go anywhere but over another row, update() draws the panel again.
local function CreateGrip(row, panel, descKey, move, update)
	local grip = CreateFrame("Button", nil, row)
	grip:SetSize(GRIP_WIDTH, GRIP_HEIGHT)
	grip:SetPoint("LEFT", ROW_EDGE, 0)
	for column = 0, 1 do
		for line = 0, 2 do
			local dot = grip:CreateTexture(nil, "ARTWORK")
			dot:SetColorTexture(unpack(ARROW_INK))
			dot:SetSize(2, 2)
			dot:SetPoint("TOPLEFT", 1 + column * 4, -(3 + line * 4))
		end
	end
	local function Target()
		for i, other in ipairs(panel.rows) do
			if i ~= row.index and other:IsShown() and other:IsMouseOver() then
				return i
			end
		end
		return nil
	end
	grip:RegisterForDrag("LeftButton")
	grip:SetScript("OnDragStart", function()
		HideTooltip(grip)
		panel.dragFrom = row.index
		row:SetAlpha(0.6)
		panel:SetScript("OnUpdate", function()
			local to = Target()
			for i, other in ipairs(panel.rows) do
				other.drop:SetShown(i == to)
			end
		end)
	end)
	grip:SetScript("OnDragStop", function()
		panel:SetScript("OnUpdate", nil)
		for _, other in ipairs(panel.rows) do
			other.drop:Hide()
		end
		local from, to = panel.dragFrom, Target()
		panel.dragFrom = nil
		if from and to then
			ns.CancelSpellPick()
			move(from, to)
		else
			update()
		end
	end)
	grip:SetScript("OnEnter", function(self)
		ShowTip(self, L["CONDITIONALS_REORDER"], L[descKey])
	end)
	grip:SetScript("OnLeave", HideTooltip)
	return grip
end

-- Its panel sets its tooltip.
local function CreateSlot(row, height, iconSize, iconLeft, ownerOf)
	local slot = CreateFrame("Button", nil, row)
	slot:SetHeight(height)
	slot.edge = Box(slot, FIELD_FILL, FIELD_EDGE)
	AddHighlight(slot)
	slot.icon = slot:CreateTexture(nil, "ARTWORK")
	slot.icon:SetSize(iconSize, iconSize)
	slot.icon:SetPoint("LEFT", iconLeft, 0)
	slot.text = slot:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	slot.text:SetPoint("LEFT", slot.icon, "RIGHT", SLOT_TEXT_GAP, 0)
	slot.text:SetPoint("RIGHT", -SLOT_TEXT_GAP, 0)
	slot.text:SetJustifyH("LEFT")
	slot.text:SetWordWrap(false)
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	slot:SetScript("OnClick", function(self, mouseButton)
		HideTooltip(self)
		if mouseButton == "RightButton" then
			ns.CancelSpellPick()
		elseif GetCursorInfo() and ns.DropSpellOnSlot(ownerOf(), row.index) then
			return
		elseif ns.IsPickingSpellFor(ownerOf(), row.index) then
			ns.CancelSpellPick()
		else
			ns.StartSpellPick(ownerOf(), row.index)
		end
	end)
	slot:SetScript("OnReceiveDrag", function()
		ns.DropSpellOnSlot(ownerOf(), row.index)
	end)
	slot:SetScript("OnLeave", HideTooltip)
	return slot
end

local function AddSlotHints(picking, dropKey)
	GameTooltip:AddLine(" ")
	if picking then
		AddHint(L["TOOLTIP_KEY_RIGHT_CLICK"], L["CONDITIONALS_ACTION_CANCEL"])
	else
		AddHint(L["TOOLTIP_KEY_CLICK"], L["CONDITIONALS_ACTION_PICK"])
	end
	GameTooltip:AddLine(" ")
	AddHint(L["CONDITIONALS_KEY_DRAG"], L[dropKey])
	GameTooltip:Show()
end

local function DrawPickingSlot(slot)
	slot.edge:SetColorTexture(INFO.r, INFO.g, INFO.b)
	slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(true)
	slot.text:SetText(GetColor("INFO") .. L["CONDITIONALS_PICKING"] .. "|r")
end

local function DrawSpellSlot(slot, spellID, name, rank)
	slot.edge:SetColorTexture(unpack(FIELD_EDGE))
	slot.icon:SetTexture(spellID and C_Spell.GetSpellTexture(spellID) or ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(false)
	slot.text:SetText(
		GetColor("TITLE") .. (name or "") .. (rank and " " .. GetColor("HELP") .. rank .. "|r" or "") .. "|r"
	)
end

local function DrawEmptySlot(slot)
	slot.edge:SetColorTexture(unpack(FIELD_EDGE))
	slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(true)
	slot.text:SetText(GetColor("MUTED") .. L["CONDITIONALS_PICK_SPELL"] .. "|r")
end

local function CreateRemove(row, descKey, remove)
	local button = CreateFrame("Button", nil, row)
	button:SetSize(REMOVE_SIZE, REMOVE_SIZE)
	button:SetPoint("RIGHT", -ROW_EDGE, 0)
	button:SetNormalTexture(TEXTURE_REMOVE)
	button:SetPushedTexture(TEXTURE_REMOVE_DOWN)
	button:SetHighlightTexture(TEXTURE_REMOVE_HIGHLIGHT, "ADD")
	button:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.CancelSpellPick()
		remove()
	end)
	button:SetScript("OnEnter", function(self)
		ShowTip(self, L["CONDITIONALS_REMOVE"], L[descKey])
	end)
	button:SetScript("OnLeave", HideTooltip)
	return button
end

Widgets.CreateDropdown, Widgets.CreateDropWash, Widgets.CreateGrip = CreateDropdown, CreateDropWash, CreateGrip
Widgets.CreateSlot, Widgets.AddSlotHints = CreateSlot, AddSlotHints
Widgets.DrawPickingSlot, Widgets.DrawSpellSlot, Widgets.DrawEmptySlot = DrawPickingSlot, DrawSpellSlot, DrawEmptySlot
Widgets.CreateRemove = CreateRemove
