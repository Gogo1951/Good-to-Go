local _, ns = ...
local Data = ns.Data

local AcquireIcon = ns.AcquireBuffDutyIcon
local SetIcon = ns.SetBuffDutyIcon
local AcquireOtherIcon = ns.AcquireBuffDutyOtherIcon
local SetOtherIcon = ns.SetBuffDutyOtherIcon

local Kit = ns.MenuKit

local Layout = {}
ns.buffDutyLayout = Layout

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local LABEL_ICON_SIZE = Data.BUFF_DUTY_LABEL_ICON_SIZE
local ICON_GAP = 4
local NAME_GAP = 8
-- Fold buttons, like the icons, sit over the window's rows (Kit.AddWindowRow), which sit one above the window.
local ABOVE_ROWS = 2

--[[
    Held while the window stays up for the same group, so it keeps its width
    as buffs are cast: a buffed column stays empty rather than pulling the
    icons left under the cursor.
]]
local held = { columns = {}, nameWidth = 0, partyBuffs = 0 }

local pool = ns.buffDutyIconPool

--[[
    Everything a redraw would write, so an unchanged list (a raid's usual aura
    traffic) skips the redraw. A field left out keeps stale attributes or
    names on screen.
]]
local function Signature(sections, otherBuffs)
	local parts = {}
	-- The names too: the hover list is read off the spec the last redraw set.
	for _, spec in ipairs(otherBuffs) do
		parts[#parts + 1] = "!" .. spec.key .. ":" .. table.concat(spec.recipients, ",")
		for _, group in ipairs(spec.groups) do
			parts[#parts + 1] = group.label .. ":" .. table.concat(group.names, ",")
		end
	end
	local function AddIcons(list)
		for _, spec in ipairs(list) do
			parts[#parts + 1] = spec.column
				.. ":"
				.. (spec.castSpell or spec.spellName or spec.item or ("item:" .. tostring(spec.itemId)))
				.. "@"
				.. (spec.unit or "")
				.. (spec.targetSlot or "")
				.. (spec.macrotext or "")
				.. "~"
				.. (spec.buffExpires or "")
				.. "x"
				.. (spec.count or "")
				.. "p"
				.. tostring(ns.BuffDuty.PvPFlaggedTarget(spec) or "")
		end
	end
	for _, section in ipairs(sections) do
		parts[#parts + 1] = "#"
			.. (section.grid or "")
			.. section.label
			.. (section.foldable and (section.folded and "+" or "-") or "")
			.. (section.menu and ("^" .. section.menu) or "")
			.. (section.missing and "!" or "")
		AddIcons(section.icons)
		for _, row in ipairs(section.rows) do
			parts[#parts + 1] = (row.pet and ">>" or ">")
				.. (row.grid or "")
				.. row.label
				.. (row.menu and ("^" .. row.menu) or "")
				.. (row.missing and "!" or "")
			AddIcons(row.icons)
		end
	end
	return table.concat(parts, "|")
end

-- Fold buttons are plain, not secure: they only ask for a redraw, and a click in combat is ignored.
local FOLD_TEXTURES = {
	[true] = "Interface/Buttons/UI-PlusButton-Up",
	[false] = "Interface/Buttons/UI-MinusButton-Up",
}
local foldButtons, usedFoldButtons = {}, 0

local function OnFoldClick(self)
	ns.BuffDuty.ToggleGroupFold(self.subgroup)
end

-- A drag that starts on a header still moves the window.
local function OnFoldDragStart()
	local content = pool.content
	content:GetScript("OnDragStart")(content)
end

local function OnFoldDragStop()
	local content = pool.content
	content:GetScript("OnDragStop")(content)
end

local function AcquireFoldButton()
	usedFoldButtons = usedFoldButtons + 1
	local button = foldButtons[usedFoldButtons]
	if not button then
		button = CreateFrame("Button", nil, pool.content)
		button:SetFrameLevel(pool.content:GetFrameLevel() + ABOVE_ROWS)
		button:SetHeight(Kit.ROW_HEIGHT)
		button:RegisterForClicks("LeftButtonUp")
		button:RegisterForDrag("LeftButton")
		button.glyph = button:CreateTexture(nil, "ARTWORK")
		button.glyph:SetSize(LABEL_ICON_SIZE, LABEL_ICON_SIZE)
		button.glyph:SetPoint("LEFT")
		button:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
		button:SetScript("OnClick", OnFoldClick)
		button:SetScript("OnDragStart", OnFoldDragStart)
		button:SetScript("OnDragStop", OnFoldDragStop)
		foldButtons[usedFoldButtons] = button
	end
	return button
end

local function ReleaseFoldButtons()
	for i = 1, usedFoldButtons do
		foldButtons[i]:Hide()
	end
	usedFoldButtons = 0
end

--[[
    A line with a menu is one window row across the window, lit end to end,
    opening its menu on hover anywhere on it (Kit.AddWindowRow). The rows
    share Buff Duty's one menu by key, so each opens it through
    ns.ShowBuffDutyMenu, which keeps the row lit as Kit.OpenRowMenu does.
    Rows are plain, so they work in combat, and kept by the menu they open
    rather than pooled by place, so an open menu stays on its line across a
    redraw. The line's name is Buff Duty's own label, so the row's sides stay
    empty; its icons sit over it at a higher frame level, so a click on one
    still casts.
]]
local menuRows = {}

local function OpenLineMenu(self)
	ns.ShowBuffDutyMenu(self, self.menuKey)
end

local function AcquireMenuRow(key)
	local row = menuRows[key]
	if not row then
		row = Kit.AddWindowRow(pool.content, ns.buffDutyOptionsMenu)
		row:SetScript("OnEnter", OpenLineMenu)
		row:SetScript("OnClick", OpenLineMenu)
		row:RegisterForDrag("LeftButton")
		row:SetScript("OnDragStart", OnFoldDragStart)
		row:SetScript("OnDragStop", OnFoldDragStop)
		row.menuKey = key
		menuRows[key] = row
	end
	return row
end

local function ReleaseMenuButtons()
	for _, row in pairs(menuRows) do
		row:Hide()
	end
end

--[[
    `offsets` maps a buff's column to pixels from the grid's first icon; `x`
    and `right` are the window column's edges, `top` the row's top. Every
    line is a Kit.ROW_HEIGHT row, its name and icons centered on it. A packed
    line skips the columns, its icons side by side against the right edge, so
    a cast leaves no gap. withMenus places a line's menu row across the window.
]]
local function PlaceRow(line, x, right, top, nameWidth, offsets, gridWidth, withMenus)
	local content = pool.content
	local y = top - Kit.ROW_HEIGHT / 2
	local label, indent = line.label, line.indent
	label:ClearAllPoints()
	label:SetPoint("LEFT", content, "TOPLEFT", x + indent, y)
	label:SetWidth(nameWidth - indent)
	label:Show()

	if line.menu and withMenus then
		local row = AcquireMenuRow(line.menu)
		Kit.PlaceWindowRow(row, top)
		row:Show()
	end

	-- Missing Inventory! sits at the line's right end, after any icons, which move left to make room.
	if line.missingLabel then
		local missing = line.missingLabel
		missing:ClearAllPoints()
		missing:SetPoint("RIGHT", content, "TOPLEFT", right, y)
		missing:Show()
		right = right - line.missingWidth - ICON_GAP
	end

	if line.fold then
		local button = AcquireFoldButton()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", x, y)
		button:SetWidth(nameWidth)
		button.subgroup = line.fold.subgroup
		button.glyph:SetTexture(FOLD_TEXTURES[line.fold.folded])
		button:Show()
	end

	local specs = line.specs
	local left = right - (gridWidth or 0)
	local packedLeft = right - (#specs * (ICON_SIZE + ICON_GAP) - ICON_GAP)
	for index, spec in ipairs(specs) do
		local button = AcquireIcon()
		button:ClearAllPoints()
		local iconX = line.packed and packedLeft + (index - 1) * (ICON_SIZE + ICON_GAP) or left + offsets[spec.column]
		button:SetPoint("LEFT", content, "TOPLEFT", iconX, y)
		SetIcon(button, spec)
	end
	local partyBuffs = line.partyBuffs or {}
	left = right - (#partyBuffs * (ICON_SIZE + ICON_GAP) - ICON_GAP)
	for index, spec in ipairs(partyBuffs) do
		local button = AcquireOtherIcon(content)
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + (index - 1) * (ICON_SIZE + ICON_GAP), y)
		SetOtherIcon(button, spec)
	end
end

--[[
    One column per buff, so a party's group buff sits over the single it
    replaces; only used columns are kept. A section or row can name its own
    grid, so columns unlike the parties' aren't pushed right by them.
]]
local MAIN_GRID = "main"

local function GridSlots(sections)
	local used = held.columns
	local function Mark(grid, list)
		used[grid] = used[grid] or {}
		for _, spec in ipairs(list) do
			used[grid][spec.column] = true
		end
	end
	for _, section in ipairs(sections) do
		local grid = section.grid or MAIN_GRID
		Mark(grid, section.icons)
		for _, row in ipairs(section.rows) do
			Mark(row.grid or grid, row.icons)
		end
	end

	local offsetsByGrid, widths = {}, {}
	for grid, columnSet in pairs(used) do
		local columns = {}
		for column in pairs(columnSet) do
			columns[#columns + 1] = column
		end
		table.sort(columns)
		local offsets, x = {}, 0
		for slot, column in ipairs(columns) do
			if slot > 1 then
				x = x + ICON_SIZE + ICON_GAP
			end
			offsets[column] = x
		end
		offsetsByGrid[grid] = offsets
		widths[grid] = #columns > 0 and x + ICON_SIZE or 0
	end
	return offsetsByGrid, widths
end

-- Rows stack edge to edge; a section's end adds a spacer. Returns the next run's top and this run's lowest row edge.
local function PlaceLines(lines, x, right, top, nameWidth, offsetsByGrid, widths, withMenus)
	local bottom = top
	for _, line in ipairs(lines) do
		PlaceRow(line, x, right, top, nameWidth, offsetsByGrid[line.grid], widths[line.grid], withMenus)
		bottom = top - Kit.ROW_HEIGHT
		top = bottom
		if line.sectionEnd then
			top = top - Kit.WINDOW_SPACER
		end
	end
	return top, bottom
end

Layout.ICON_GAP = ICON_GAP
Layout.FOLD_INDENT = LABEL_ICON_SIZE
Layout.NAME_GAP = NAME_GAP
Layout.MAIN_GRID = MAIN_GRID
Layout.held = held
Layout.Signature = Signature
Layout.GridSlots = GridSlots
Layout.PlaceLines = PlaceLines
Layout.ReleaseFoldButtons = ReleaseFoldButtons
Layout.ReleaseMenuButtons = ReleaseMenuButtons
Layout.ABOVE_ROWS = ABOVE_ROWS
