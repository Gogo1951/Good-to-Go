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
local ICON_GAP = 4
-- An icon plus the same 4-pixel gap between rows as between icons.
local ROW_HEIGHT = ICON_SIZE + ICON_GAP
--[[
    Extra room under each section (a party, Return the Favor, Target), so one
    party's last member doesn't crowd the next party's header.
]]
local SECTION_GAP = 4
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
		end
	end
	for _, section in ipairs(sections) do
		parts[#parts + 1] = "#" .. (section.grid or "") .. section.label
		AddIcons(section.icons)
		for _, row in ipairs(section.rows) do
			parts[#parts + 1] = (row.pet and ">>" or ">") .. (row.grid or "") .. row.label
			AddIcons(row.icons)
		end
	end
	return table.concat(parts, "|")
end

--[[
    `offsets` maps a buff's column to how far its icon sits from the grid's
    first, in pixels. `x` is the left edge of the window column the row sits
    in, `y` the row's middle.
]]
local function PlaceRow(line, x, y, nameWidth, offsets)
	local content = pool.content
	local label, indent = line.label, line.indent
	label:ClearAllPoints()
	label:SetPoint("LEFT", content, "TOPLEFT", x + indent, y)
	label:SetWidth(nameWidth - indent)
	label:Show()

	local left = x + nameWidth + NAME_GAP
	for _, spec in ipairs(line.specs) do
		local button = AcquireIcon()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + offsets[spec.column], y)
		SetIcon(button, spec)
	end
	-- The Party-Buffs header's icons: plain buttons, side by side from the first icon column.
	for index, spec in ipairs(line.partyBuffs or {}) do
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
local function PlaceLines(lines, x, y, nameWidth, offsetsByGrid)
	local bottom = y
	for _, line in ipairs(lines) do
		if line.spaceBefore then
			y = y - ROW_HEIGHT
		end
		PlaceRow(line, x, y, nameWidth, offsetsByGrid[line.grid])
		bottom = y - ICON_SIZE / 2
		y = y - ROW_HEIGHT
		if line.sectionEnd then
			y = y - SECTION_GAP
		end
		if line.spaceAfter then
			y = y - ROW_HEIGHT
		end
	end
	return y, bottom
end

Layout.ICON_GAP = ICON_GAP
Layout.ROW_HEIGHT = ROW_HEIGHT
Layout.NAME_GAP = NAME_GAP
Layout.MAIN_GRID = MAIN_GRID
Layout.held = held
Layout.Signature = Signature
Layout.GridSlots = GridSlots
Layout.PlaceLines = PlaceLines
