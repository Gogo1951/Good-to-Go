local _, ns = ...

local SLOTS, GAP_X = ns.SPELLBOOK_SLOTS, ns.SPELLBOOK_GAP_X
local TILE_WIDTH = ns.TILE_WIDTH
local HEADER_HEIGHT, ROW_HEIGHT = ns.SPELLBOOK_HEADER_HEIGHT, ns.SPELLBOOK_ROW_HEIGHT

-- At least as much air above a header as below it, so each name reads with the spells under it.
local CATEGORY_GAP = 32

--[[
	A run starts in the very next free slot, so two runs can share a row; a run that wraps carries on as a
	continued segment.
]]
local function PackRows(groups)
	local rows, row, used = {}, nil, 0
	for _, group in ipairs(groups) do
		local i, continued = 1, false
		while i <= #group.macros do
			if not row or used == SLOTS then
				row = { segments = {} }
				rows[#rows + 1] = row
				used = 0
			end
			local take = math.min(SLOTS - used, #group.macros - i + 1)
			local segment = { group = group, sub = group.sub, continued = continued, macros = {} }
			for k = i, i + take - 1 do
				segment.macros[#segment.macros + 1] = group.macros[k]
			end
			row.segments[#row.segments + 1] = segment
			used, i, continued = used + take, i + take, true
		end
	end
	return rows
end

local function BlockHeight(first, last)
	return HEADER_HEIGHT + (last - first + 1) * ROW_HEIGHT
end

--[[
	A category takes the rows the column has room for and carries on, under its header again, in the next. It
	moves whole only when not even its header and first row fit, so no header sits alone at a column's foot.
]]
local function Paginate(categories, height)
	local columns = { {} }
	local column, y = columns[1], 0
	local function nextColumn()
		column, y = {}, 0
		columns[#columns + 1] = column
	end
	for _, category in ipairs(categories) do
		local rows = category.rows
		local first, continued = 1, false
		while first <= #rows do
			local gap = #column > 0 and CATEGORY_GAP or 0
			local room = height - y - gap
			local last = first - 1
			while last < #rows and BlockHeight(first, last + 1) <= room do
				last = last + 1
			end
			-- an empty column always takes at least one row, so a category can never stall
			if last < first and #column == 0 then
				last = first
			end
			if last < first then
				nextColumn()
			else
				column[#column + 1] =
					{ category = category, first = first, last = last, continued = continued, y = y + gap }
				y = y + gap + BlockHeight(first, last)
				first = last + 1
				if first <= #rows then
					continued = true
					nextColumn()
				end
			end
		end
	end
	if #column == 0 and #columns > 1 then
		columns[#columns] = nil
	end
	return columns
end

local function RunWidth(n)
	return n * TILE_WIDTH + (n - 1) * GAP_X
end

-- slot counts from 0; nil past the row's last tile
local function SegmentAt(row, slot)
	local start = 0
	for _, segment in ipairs(row.segments) do
		if slot < start + #segment.macros then
			return segment
		end
		start = start + #segment.macros
	end
	return nil
end

--[[
	Always where the run starts; where it carries on, only when the tile above its first slot belongs to another
	run or isn't there (a column's first row).
]]
local function NeedsLabel(segment, above, slot)
	if not segment.continued or not above then
		return true
	end
	local over = SegmentAt(above, slot)
	return over == nil or over.group ~= segment.group
end

ns.PackSpellbookRows = PackRows
ns.PaginateSpellbook = Paginate
ns.SpellbookRunWidth = RunWidth
ns.SpellbookNeedsLabel = NeedsLabel
