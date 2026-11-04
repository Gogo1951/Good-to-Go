local _, ns = ...

--[[
	The Spell Book page's flow (Features/Spellbook/Spellbook-Page.lua): a category's runs packed into rows of
	tiles, the rows filled into columns page by page, and where a form's label shows again over a row.
]]

-- The flow inside a column, as Features/Spellbook/Spellbook-Page.lua sets it.
local SLOTS, GAP_X = ns.SPELLBOOK_SLOTS, ns.SPELLBOOK_GAP_X
local TILE_WIDTH = ns.TILE_WIDTH
local HEADER_HEIGHT, ROW_HEIGHT = ns.SPELLBOOK_HEADER_HEIGHT, ns.SPELLBOOK_ROW_HEIGHT

--[[
	CATEGORY_GAP is the clear space over a category's header, from the tiles of the one before. A header's name
	sits about 30 above its first tiles (the header's lower half and a row strip), so the gap is wider than that:
	more air above a header than below it, so each name reads with the spells under it.
]]
local CATEGORY_GAP = 34

--[[
	A category's runs packed into rows of SLOTS tiles, each { segments }. A run starts in the very next free
	slot, so two runs can share a row; a run that wraps carries on as a segment marked continued at the start of
	the next row.
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

-- The height of a category's header and its rows first to last.
local function BlockHeight(first, last)
	return HEADER_HEIGHT + (last - first + 1) * ROW_HEIGHT
end

--[[
	Fills columns in order (page 1 left, page 1 right, page 2 left, ...) with category blocks, each
	{ category, first, last, continued, y }. A category starts right under the one before and takes as many
	of its rows as the column has room for; the rest carry on at the top of the next column, under its header
	again, marked continued. It moves whole to the next column only when not even its header and first row fit,
	so a category never leaves a header alone at a column's foot, and one more row above only pushes the last
	row on.
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

-- The width of a run of n tiles.
local function RunWidth(n)
	return n * TILE_WIDTH + (n - 1) * GAP_X
end

-- The segment of a row that holds a slot (0 for the first), or nil past its last tile.
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
	Whether a form's run shows its label at this row, starting at slot: always where the run starts, and where
	it carries on only when that isn't plain from the tile above its first slot, which belongs to another run
	or isn't there (the first row of a column, under the header again). So "BASIC ATTACKS" shows again over a
	row whose first tile sits under a Defensive Stance spell, but not over the next row, under its own.
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
