local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local TITLE, BODY, INFO = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY, ns.COLORS_RGB.INFO
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local PixelInset = ns.PixelInset

--[[
	The controls the panels docked beside the Spell Book share (Features/Spellbook/Macro-Builder/Docked-Panel.lua):
	the Conditionals panel and its rows (Features/Spellbook/Macro-Builder/Conditionals-Panel.lua,
	Conditionals-Rows.lua) and the Cast Sequence panel (Features/Spellbook/Macro-Builder/Cast-Sequence-Panel.lua).
	Their colours, a box, a tooltip, a dropdown, the grip a row is dragged by and the wash on the row it will land
	on, a spell slot and how it draws, and a row's remove button. They load before the panels, which read them as
	they load.
]]

local SLOT_ICON = 22
local DROPDOWN_HEIGHT = 24
local DROPDOWN_TEXT_LEFT, CARET_SIZE, CARET_RIGHT = 8, 12, 5
local REMOVE_SIZE = 20
local HIGHLIGHT_ALPHA = 0.08
local DROP_ALPHA = 0.18 -- the wash on the row a dragged row will land on

local TEXTURE_CARET = "Interface\\Buttons\\Arrow-Down-Up"
local TEXTURE_REMOVE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local TEXTURE_REMOVE_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
local TEXTURE_REMOVE_HIGHLIGHT = "Interface\\Buttons\\UI-GroupLoot-Pass-Highlight"

-- The panels' own dark leather (Data/Data.lua), so they read as part of the window rather than the parchment, as
-- the {r, g, b} lists the texture calls unpack.
local COLORS = {}
for key, hex in pairs(ns.CONDITIONALS_COLORS) do
	local rgb = ns.HexToRGB(hex)
	COLORS[key] = { rgb.r, rgb.g, rgb.b }
end
local FIELD_FILL, FIELD_EDGE = COLORS.FIELD_FILL, COLORS.FIELD_EDGE
local ARROW_INK = COLORS.ARROW_INK

local Widgets = {}
ns.PanelWidgets = Widgets
Widgets.SLOT_ICON, Widgets.COLORS = SLOT_ICON, COLORS

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

-- A box on frame: a one-pixel edge in one colour around a fill in another.
local function Box(frame, fill, edge)
	local edgeTexture = frame:CreateTexture(nil, "BACKGROUND")
	edgeTexture:SetAllPoints()
	edgeTexture:SetColorTexture(unpack(edge))
	local fillTexture = frame:CreateTexture(nil, "BORDER")
	fillTexture:SetColorTexture(unpack(fill))
	PixelInset(fillTexture, frame, 1)
	return edgeTexture, fillTexture
end

-- A tooltip on owner, its title gold and its lines white, then, if given, why it does nothing, in red.
local function ShowTip(owner, title, body, reason)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
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

-- The faint wash a box's button shows under the cursor.
local function AddHighlight(button)
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetColorTexture(1, 1, 1, HIGHLIGHT_ALPHA)
	PixelInset(highlight, button, 1)
end

-- A keybind and what it does, both in the interaction blue, as a pair across the tooltip, as a tile's are.
local function AddHint(keybind, action)
	GameTooltip:AddDoubleLine(GetColor("INFO") .. keybind .. "|r", GetColor("INFO") .. action .. "|r")
end

Widgets.Box, Widgets.ShowTip = Box, ShowTip

--------------------------------------------------------------------------------
-- Controls
--------------------------------------------------------------------------------

--[[
	A dark field with a value and a caret, as wide as its value needs, passed through fit(width), opening a menu
	on a click (openMenu(dropdown)). Returns the dropdown and its caret.
]]
local function CreateDropdown(parent, fit, openMenu)
	local dropdown = CreateFrame("Button", nil, parent)
	dropdown:SetHeight(DROPDOWN_HEIGHT)
	Box(dropdown, FIELD_FILL, FIELD_EDGE)
	AddHighlight(dropdown)
	local caret = dropdown:CreateTexture(nil, "ARTWORK")
	caret:SetTexture(TEXTURE_CARET)
	caret:SetSize(CARET_SIZE, CARET_SIZE)
	caret:SetPoint("RIGHT", -CARET_RIGHT, 0)
	dropdown.text = SizedFontString(dropdown, "GameFontHighlightSmall", 12)
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

-- The wash on a row a dragged row will land on, hidden until then.
local function CreateDropWash(row)
	local drop = row:CreateTexture(nil, "ARTWORK")
	drop:SetColorTexture(INFO.r, INFO.g, INFO.b, DROP_ALPHA)
	PixelInset(drop, row, 1)
	drop:Hide()
	return drop
end

--[[
	The grip at a row's left: six dots, dragged to move the row to the row of panel.rows it is let go over, by
	move(from, to); let go anywhere else, update() draws the panel again. descKey is its tooltip's line.
]]
local function CreateGrip(row, panel, descKey, move, update)
	local grip = CreateFrame("Button", nil, row)
	grip:SetSize(12, 18)
	grip:SetPoint("LEFT", 6, 0)
	for column = 0, 1 do
		for line = 0, 2 do
			local dot = grip:CreateTexture(nil, "ARTWORK")
			dot:SetColorTexture(unpack(ARROW_INK))
			dot:SetSize(2, 2)
			dot:SetPoint("TOPLEFT", 3 + column * 4, -(3 + line * 5))
		end
	end
	-- the row under the cursor, other than the one dragged, or nil
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
		-- the row it would land on shows a wash while the drag goes on
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
			ns.CancelConditionalPick()
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

--[[
	A row's spell slot: the spell's icon and name, or what to do to give it one. A click starts or ends pick mode
	for it, or drops the spell on the cursor, as does a drag let go on it, for the owner ownerOf() returns
	(Features/Spellbook/Macro-Builder/Conditionals-Pick.lua). Its panel sets its tooltip.
]]
local function CreateSlot(row, height, iconSize, iconLeft, ownerOf)
	local slot = CreateFrame("Button", nil, row)
	slot:SetHeight(height)
	slot.edge = Box(slot, FIELD_FILL, FIELD_EDGE)
	AddHighlight(slot)
	slot.icon = slot:CreateTexture(nil, "ARTWORK")
	slot.icon:SetSize(iconSize, iconSize)
	slot.icon:SetPoint("LEFT", iconLeft, 0)
	slot.text = SizedFontString(slot, "GameFontNormal", 13)
	slot.text:SetPoint("LEFT", slot.icon, "RIGHT", 6, 0)
	slot.text:SetPoint("RIGHT", -6, 0)
	slot.text:SetJustifyH("LEFT")
	slot.text:SetWordWrap(false)
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	slot:SetScript("OnClick", function(self, mouseButton)
		HideTooltip(self)
		if mouseButton == "RightButton" then
			ns.CancelConditionalPick()
		elseif GetCursorInfo() and ns.DropSpellOnSlot(ownerOf(), row.index) then
			return
		elseif ns.IsPickingSpellFor(ownerOf(), row.index) then
			ns.CancelConditionalPick()
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

-- A slot's tooltip ends with its clicks, in pick mode or not, and what a drop does (dropKey).
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

-- Draws a slot waiting in pick mode.
local function DrawPickingSlot(slot)
	slot.edge:SetColorTexture(INFO.r, INFO.g, INFO.b)
	slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(true)
	slot.text:SetText(GetColor("INFO") .. L["CONDITIONALS_PICKING"] .. "|r")
end

-- Draws a slot's spell: spellID's icon, or a question mark without one, and its name and rank.
local function DrawSpellSlot(slot, spellID, name, rank)
	slot.edge:SetColorTexture(unpack(FIELD_EDGE))
	slot.icon:SetTexture(spellID and C_Spell.GetSpellTexture(spellID) or ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(false)
	slot.text:SetText(
		GetColor("TITLE") .. (name or "") .. (rank and " " .. GetColor("HELP") .. rank .. "|r" or "") .. "|r"
	)
end

-- Draws a slot asking for a spell.
local function DrawEmptySlot(slot)
	slot.edge:SetColorTexture(unpack(FIELD_EDGE))
	slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
	slot.icon:SetDesaturated(true)
	slot.text:SetText(GetColor("MUTED") .. L["CONDITIONALS_PICK_SPELL"] .. "|r")
end

-- A row's remove button at its right; a click ends pick mode and calls remove(). descKey is its tooltip's line.
local function CreateRemove(row, descKey, remove)
	local button = CreateFrame("Button", nil, row)
	button:SetSize(REMOVE_SIZE, REMOVE_SIZE)
	button:SetPoint("RIGHT", -6, 0)
	button:SetNormalTexture(TEXTURE_REMOVE)
	button:SetPushedTexture(TEXTURE_REMOVE_DOWN)
	button:SetHighlightTexture(TEXTURE_REMOVE_HIGHLIGHT, "ADD")
	button:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.CancelConditionalPick()
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
