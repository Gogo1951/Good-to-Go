local _, ns = ...

--[[
	A page macro's right-click menu drawn on Menu-Kit's own panels (Features/Menu-Kit.lua), as Style Guide → MENUS
	asks of every menu: Pretty Wide Quest Log's plate, the kit's row kinds, sub-menus overlapping the menu they open
	from, no skin add-on touching any of it.

	The menu is described the way the game's menus are, so the sections that fill it read as before: a root takes
	CreateButton, CreateCheckbox, CreateRadio, CreateTitle, CreateDivider and CreateSpacer, and an element takes
	SetTooltip and SetEnabled. Four more say what the game's menus drew with an initializer: SetValue (a button's
	right side, already colored), SetNote (an option's gray note), SetLabel (a label read each time the menu draws)
	and, on a root or sub-menu, CreateText (a block of lines) and CreateHeader (the header row).

	A button with children opens a sub-menu: its label gold, its value gray, the arrow, on hover or click. A button
	without is an action, blue, and closes the menu unless its callback answers MenuResponse.Refresh. A checkbox is
	a toggle and a radio a choice; either redraws in place unless its callback answers MenuResponse.CloseAll. Every
	change builds the menu afresh and draws it again where it is, its open sub-menus kept open.
]]

local Kit = ns.MenuKit
local MAX_DEPTH = 4 -- The menu and three sub-menus deep: Target → Second → its units
local CLOSE_DELAY = 0.4
local FLYOUT_ROOM = 280 -- What a sub-menu is likely to need beside the menu, to pick its side once
local MENU_GAP = 2 -- From a gear's or a field's corner to the menu's, as the kit's own menus open

--------------------------------------------------------------------------------
-- The Description
--------------------------------------------------------------------------------

local Element = {}
Element.__index = Element

local function NewElement(kind, label)
	return setmetatable({ kind = kind, label = label, children = {} }, Element)
end

function Element:Add(kind, label)
	local element = NewElement(kind, label)
	self.children[#self.children + 1] = element
	return element
end

function Element:CreateButton(label, onClick)
	local element = self:Add("button", label)
	element.onClick = onClick
	return element
end

function Element:CreateCheckbox(label, isOn, onToggle)
	local element = self:Add("checkbox", label)
	element.isOn, element.onClick = isOn, onToggle
	return element
end

function Element:CreateRadio(label, isOn, onPick)
	local element = self:Add("radio", label)
	element.isOn, element.onClick = isOn, onPick
	return element
end

function Element:CreateTitle(label)
	return self:Add("title", label)
end

function Element:CreateDivider()
	return self:Add("divider")
end

function Element:CreateSpacer()
	return self:Add("spacer")
end

-- The header row: left gold, right (the add-on's short name) gray, a spacer under it.
function Element:CreateHeader(left, right)
	local element = self:Add("header", left)
	element.right = right
	self:CreateSpacer()
	return element
end

-- A block of lines, wrapped to the menu, read each time the menu draws.
function Element:CreateText(text)
	local element = self:Add("text")
	element.text = text
	return element
end

function Element:SetTooltip(tooltip)
	self.tooltip = tooltip
end

function Element:SetEnabled(enabled)
	self.disabled = not enabled
end

function Element:SetValue(value)
	self.value = value
end

function Element:SetNote(note)
	self.note = note
end

function Element:SetLabel(label)
	self.labelFunction = label
end

local function Read(value)
	if type(value) == "function" then
		return value()
	end
	return value
end

-- A sub-menu's key among its siblings, found again after the menu is built afresh.
local function ChildByKey(element, key)
	for _, child in ipairs(element and element.children or {}) do
		if child.kind == "button" and #child.children > 0 and child.label == key then
			return child
		end
	end
end

--------------------------------------------------------------------------------
-- The Panels
--------------------------------------------------------------------------------

local panels = {}
local state = { open = {}, idle = 0 }
local Refresh, Close, OpenFlyout, CloseFrom

-- Runs a row's callback, then redraws or closes, as the game's menus would.
local function Run(element)
	local response = element.onClick and element.onClick()
	local isAction = element.kind == "button" and #element.children == 0
	if isAction then
		if response == MenuResponse.Refresh then
			Refresh()
		else
			Close()
		end
	elseif response == MenuResponse.CloseAll then
		Close()
	else
		Refresh()
	end
end

local function WithNote(label, note)
	if not note then
		return label
	end
	return label .. "  " .. note
end

-- A note as plain text, its own colors taken off, for the right column's gray.
local function Plain(note)
	return (note:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

-- The kit entries one element's children draw as, on the panel at level.
local function Entries(element, level)
	local entries = {}
	for _, child in ipairs(element.children) do
		local kind, label = child.kind, Read(child.labelFunction) or child.label
		local entry
		if kind == "header" then
			entry = { kind = "header", left = label, right = child.right }
		elseif kind == "spacer" then
			entry = { kind = "spacer" }
		elseif kind == "divider" then
			entry = { kind = "separator" }
		elseif kind == "title" then
			entry = { kind = "section", left = label }
		elseif kind == "text" then
			entry = { kind = "note", left = Read(child.text), leftColor = "TEXT" }
		elseif kind == "checkbox" then
			entry = { kind = "toggle", left = WithNote(label, Read(child.note)), on = child.isOn() and true or false }
		elseif kind == "radio" then
			local note, selected = Read(child.note), child.isOn() and true or false
			if note then
				--[[
					A choice with a note (a rank's level, the rank Max Rank casts) keeps the choice's look, with the
					note gray in the right column and the check mark after it once picked.
				]]
				entry = {
					kind = "value",
					left = label,
					leftColor = selected and "TEXT" or "MUTED",
					right = Plain(note) .. (selected and " " .. Kit.CHECK_MARK or ""),
					rightColor = "MUTED",
				}
			else
				entry = { kind = "choice", left = label, selected = selected }
			end
		elseif #child.children > 0 then
			entry =
				{ kind = "action", left = label, leftColor = "TITLE", right = Read(child.value), submenu = child.label }
		else
			entry =
				{ kind = "action", left = label, leftColor = "INFO", right = Read(child.value), rightColor = "MUTED" }
		end
		if child.disabled then
			entry.leftColor = "MUTED"
		elseif kind == "checkbox" or kind == "radio" or kind == "button" then
			entry.onClick = function()
				-- A click on a sub-menu's row opens it, as hovering does.
				if entry.submenu then
					local row = panels[level] and panels[level]:SubmenuRow(entry.submenu)
					if row then
						OpenFlyout(level + 1, row, entry.submenu)
					end
					return
				end
				Run(child)
			end
		end
		entry.tooltip = child.tooltip
		entries[#entries + 1] = entry
	end
	return entries
end

-- Every row that opens a sub-menu carries the arrow, whatever its kind.
local PANEL_CONTEXT = {
	hasFlyout = function(entry)
		return entry.submenu ~= nil
	end,
}

local function Place(panel, row)
	panel:ClearAllPoints()
	if state.side == "left" then
		panel:SetPoint("TOPRIGHT", row, "TOPLEFT", -Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	else
		panel:SetPoint("TOPLEFT", row, "TOPRIGHT", Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	end
end

local function Panel(level)
	local panel = panels[level]
	if panel then
		return panel
	end
	local name = "GoodToGoSpellMenu" .. level
	panel = Kit.CreatePanel(name, UIParent)
	panel:SetFrameStrata("DIALOG")
	panel:SetFrameLevel(10 + 20 * level) -- Each sub-menu over the menu it opens from
	panel.onEnterRow = function(row, entry)
		if entry and entry.submenu then
			OpenFlyout(level + 1, row, entry.submenu)
		else
			CloseFrom(level + 1)
		end
	end
	if level == 1 then
		table.insert(UISpecialFrames, name)
		panel:SetScript("OnHide", function()
			CloseFrom(2)
			state.open, state.root = {}, nil
		end)
		-- Closes once the cursor has been off the menu, its sub-menus and what opened it for a moment.
		panel:SetScript("OnUpdate", function(self, elapsed)
			if not state.owner or not state.owner:IsVisible() then
				self:Hide()
				return
			end
			local over = Kit.IsCursorOver(state.owner)
			for _, shown in ipairs(panels) do
				over = over or Kit.IsCursorOver(shown)
			end
			state.idle = over and 0 or state.idle + elapsed
			if state.idle > CLOSE_DELAY then
				self:Hide()
			end
		end)
	end
	panels[level] = panel
	return panel
end

-- The element the sub-menu open at level shows, found down the open path from the root.
local function ElementAt(level)
	local element = state.root
	for depth = 2, level do
		local open = state.open[depth]
		element = open and ChildByKey(element, open.key)
		if not element then
			return nil
		end
	end
	return element
end

function CloseFrom(level)
	for depth = level, MAX_DEPTH do
		local open = state.open[depth]
		if open and open.row then
			open.row:UnlockHighlight()
		end
		state.open[depth] = nil
		if panels[depth] then
			panels[depth]:Hide()
		end
	end
end

local function Draw(level)
	local element = ElementAt(level)
	local panel = Panel(level)
	if not element then
		CloseFrom(level)
		return false
	end
	panel.tooltipAnchor = state.side == "left" and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
	panel:Render(Entries(element, level), PANEL_CONTEXT)
	return true
end

function OpenFlyout(level, row, key)
	if level > MAX_DEPTH then
		return
	end
	local open = state.open[level]
	if open and open.key == key and open.row == row and panels[level]:IsShown() then
		return
	end
	CloseFrom(level)
	state.open[level] = { key = key, row = row }
	if Draw(level) then
		Place(panels[level], row)
		panels[level]:Show()
		row:LockHighlight()
	end
end

-- Builds the menu afresh and draws every open panel again where it is.
function Refresh()
	if not state.generator or not panels[1] or not panels[1]:IsShown() then
		return
	end
	local root = NewElement("root")
	state.generator(state.owner, root)
	state.root = root
	Draw(1)
	for level = 2, MAX_DEPTH do
		local open = state.open[level]
		if not open then
			break
		end
		local row = panels[level - 1]:SubmenuRow(open.key)
		if not row or not Draw(level) then
			CloseFrom(level)
			break
		end
		open.row = row
		Place(panels[level], row)
		row:LockHighlight()
	end
end

function Close()
	if panels[1] then
		panels[1]:Hide()
	end
end

--[[
	Opens the menu over owner (the button clicked), which keeps it open while the cursor is on it.
	generator(owner, root) fills the root. A right-click menu opens at the cursor, as the game opens its own;
	with beside, a gear's or a field's menu opens off owner's corner, MENU_GAP from it, as the kit's own menus
	open from their buttons, toward the roomier side of the screen.
]]
function ns.OpenMacroMenuPanels(owner, generator, beside)
	Close()
	state.owner, state.generator, state.idle, state.open = owner, generator, 0, {}
	local panel = Panel(1)
	local root = NewElement("root")
	generator(owner, root)
	state.root = root
	local width, height = UIParent:GetWidth(), UIParent:GetHeight()
	local x, y
	if beside then
		local scale = owner:GetEffectiveScale() / UIParent:GetEffectiveScale()
		x, y = owner:GetCenter()
		x, y = (x or 0) * scale, (y or 0) * scale
	else
		local scale = UIParent:GetEffectiveScale()
		x, y = GetCursorPosition()
		x, y = x / scale, y / scale
	end
	local openLeft = beside and x > width / 2
	state.side = openLeft and "left" or "right"
	Draw(1)
	if not beside and x + panel:GetWidth() + FLYOUT_ROOM > width then
		state.side = "left"
		Draw(1)
	end
	panel:ClearAllPoints()
	if beside then
		local openDown = y > height / 2
		local point = (openDown and "TOP" or "BOTTOM") .. (openLeft and "RIGHT" or "LEFT")
		local relative = (openDown and "BOTTOM" or "TOP") .. (openLeft and "LEFT" or "RIGHT")
		panel:SetPoint(point, owner, relative, openLeft and -MENU_GAP or MENU_GAP, openDown and -MENU_GAP or MENU_GAP)
	else
		-- A little up and left of the cursor, so the cursor starts inside it
		panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - Kit.FLYOUT_RISE, y + Kit.FLYOUT_RISE)
	end
	panel:Show()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

ns.CloseMacroMenuPanels = Close

function ns.IsMacroMenuPanelsShown()
	return panels[1] ~= nil and panels[1]:IsShown()
end
