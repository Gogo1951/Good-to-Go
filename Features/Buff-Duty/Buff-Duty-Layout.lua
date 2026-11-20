local _, ns = ...
local Data = ns.Data

local AcquireIcon = ns.AcquireBuffDutyIcon
local SetIcon = ns.SetBuffDutyIcon
local AcquireOtherIcon = ns.AcquireBuffDutyOtherIcon
local SetOtherIcon = ns.SetBuffDutyOtherIcon

--[[
    Buff-Duty-Layout -- the Buff Duty window's layout math, shared on
    ns.buffDutyLayout: the redraw signature, the icon grid's columns, and
    placing a run of lines with their icons. Buff-Duty-Frame.lua measures the
    names, sizes the window and calls these, out of combat only.
]]

local Layout = {}
ns.buffDutyLayout = Layout

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local LABEL_ICON_SIZE = Data.BUFF_DUTY_LABEL_ICON_SIZE
local ICON_GAP = 4
-- An icon plus the same 4-pixel gap between rows as between icons.
local ROW_HEIGHT = ICON_SIZE + ICON_GAP
--[[
    The space between sections (Self-Buffs, Ask for Buffs, Target, Return
    the Favor, each party), edge to edge: the Spacing Scale's 16, four times
    the gap between rows, so a section's last row never reads as the next
    one's first.
]]
local SECTION_SPACE = 16
-- Room between the end of the longest name and the first icon.
local NAME_GAP = 8

--[[
    What the window holds on to while it stays up for the same group, so it
    keeps its width as buffs are cast: every grid's columns any icon has used
    (a buff cast on everyone leaves its column empty rather than pulling the
    icons left under the cursor), the widest name column, and the most
    Party-Buffs icons. Let go when the window hides (everything's buffed), the
    group's size changes, or a setting changes (ns.ApplyBuffDutySettings).
]]
local held = { columns = {}, nameWidth = 0, partyBuffs = 0 }

-- The list's icons and the frame they sit in (Buff-Duty-Icon-State.lua).
local pool = ns.buffDutyIconPool

--[[
    Everything a redraw would write, as one string, so an unchanged list (the
    usual result of a raid's constant aura traffic) skips the redraw entirely.
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
		end
	end
	for _, section in ipairs(sections) do
		parts[#parts + 1] = "#"
			.. (section.grid or "")
			.. section.label
			.. (section.foldable and (section.folded and "+" or "-") or "")
		AddIcons(section.icons)
		for _, row in ipairs(section.rows) do
			parts[#parts + 1] = (row.pet and ">>" or ">") .. (row.grid or "") .. row.label
			AddIcons(row.icons)
		end
	end
	return table.concat(parts, "|")
end

--[[
    A raid group's header is a button over its label: a plus before the name
    while the group is folded, a minus while it's open, and a click toggles it
    (BuffDuty.ToggleGroupFold). Plain buttons, not secure ones: they only ask
    for a redraw, and a click in combat is ignored. Pooled like the
    icons, and released with them (ReleaseFoldButtons).
]]
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
		button:SetHeight(ICON_SIZE)
		button:RegisterForClicks("LeftButtonUp")
		button:RegisterForDrag("LeftButton")
		button.glyph = button:CreateTexture(nil, "ARTWORK")
		button.glyph:SetSize(LABEL_ICON_SIZE, LABEL_ICON_SIZE)
		button.glyph:SetPoint("LEFT")
		-- The quest log's own header highlight, so a mouse or controller cursor shows where it is.
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
    `offsets` maps a buff's column to how far its icon sits from the grid's
    first, in pixels, and `gridWidth` is the grid's whole width. `x` and
    `right` are the left and right edges of the window column the row sits
    in, `y` the row's middle. The icons sit against the right edge, under the
    close button, rather than floating wherever the names end; a grid keeps
    its columns, so a buff still lines up down the window.
]]
local function PlaceRow(line, x, right, y, nameWidth, offsets, gridWidth)
	local content = pool.content
	local label, indent = line.label, line.indent
	label:ClearAllPoints()
	label:SetPoint("LEFT", content, "TOPLEFT", x + indent, y)
	label:SetWidth(nameWidth - indent)
	label:Show()

	if line.fold then
		local button = AcquireFoldButton()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", x, y)
		button:SetWidth(nameWidth)
		button.subgroup = line.fold.subgroup
		button.glyph:SetTexture(FOLD_TEXTURES[line.fold.folded])
		button:Show()
	end

	local left = right - (gridWidth or 0)
	for _, spec in ipairs(line.specs) do
		local button = AcquireIcon()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + offsets[spec.column], y)
		SetIcon(button, spec)
	end
	-- The Ask for Buffs header's icons: plain buttons, side by side, ending at the right edge too.
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
    The icons sit in a grid: one column per buff, so a buff lines up down the
    whole window and a party's group buff sits over the single one it
    replaces. A member who doesn't need a buff leaves its cell empty. Only the
    columns some icon uses are kept, in buff order, so a buff nobody needs
    leaves no gap.

    A section can name its own grid (Self Buffs does): its columns are other
    buffs than the parties', so lining them up with the parties' would only
    push them right. A row can name one too (each weapon hand does), so its
    icons start at the left whatever the header's hold. Returns grid ->
    (column -> pixels from the first icon), and grid -> the icons' whole
    width. The party columns share one grid, so a buff sits at the same place
    in each. The columns the window holds (held.columns) are kept too.
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

--[[
    Places a run of lines down from `y`, the first one's middle. Returns where
    the next run's first middle goes, and the lowest edge this run drew.
]]
local function PlaceLines(lines, x, right, y, nameWidth, offsetsByGrid, widths)
	local bottom = y
	for _, line in ipairs(lines) do
		PlaceRow(line, x, right, y, nameWidth, offsetsByGrid[line.grid], widths[line.grid])
		bottom = y - ICON_SIZE / 2
		y = y - ROW_HEIGHT
		if line.sectionEnd then
			y = y - (SECTION_SPACE - ICON_GAP)
		end
	end
	return y, bottom
end

Layout.ICON_GAP = ICON_GAP
Layout.SECTION_SPACE = SECTION_SPACE
-- How far a raid group's name sits in, past its fold glyph: the Spacing Scale's 16, the glyph's own width.
Layout.FOLD_INDENT = LABEL_ICON_SIZE
Layout.ROW_HEIGHT = ROW_HEIGHT
Layout.NAME_GAP = NAME_GAP
Layout.MAIN_GRID = MAIN_GRID
Layout.held = held
Layout.Signature = Signature
Layout.GridSlots = GridSlots
Layout.PlaceLines = PlaceLines
Layout.ReleaseFoldButtons = ReleaseFoldButtons
