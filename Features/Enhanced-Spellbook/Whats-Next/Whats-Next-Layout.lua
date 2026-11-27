local _, ns = ...
local L = ns.L
local NameBefore = ns.SpellNameBefore

local HEADER_HEIGHT, HEADER_GAP, SECTION_GAP = 16, 8, 16
local ROW_HEIGHT = 32
ns.WHATS_NEXT_METRICS = { HEADER_HEIGHT = HEADER_HEIGHT, HEADER_GAP = HEADER_GAP, ROW_HEIGHT = ROW_HEIGHT }

--------------------------------------------------------------------------------
-- Order
--------------------------------------------------------------------------------

local function PassesFilters(page, model, row)
	local text = page.filterText
	if text and text ~= "" and not ns.FilterLower(row.name):find(ns.FilterLower(text), 1, true) then
		return false
	end
	if page.sourceFilter and row.source ~= page.sourceFilter then
		return false
	end
	return model.shows(row)
end

-- Rows without a level sort as level 0: nothing holds them back.
local function LevelOf(row)
	return row.level or 0
end

local function ByName(a, b)
	if a.name ~= b.name then
		return NameBefore(a.name, b.name)
	end
	return a.id < b.id
end

-- Each { name, status, rows }; status is for the header's ink, nil under a level.
function ns.WhatsNextSections(page, model)
	local STATUS_RANK = {}
	for rank, status in ipairs(model.statuses) do
		STATUS_RANK[status] = rank
	end
	local rows = {}
	for _, row in ipairs(page.rows) do
		if PassesFilters(page, model, row) then
			rows[#rows + 1] = row
		end
	end
	local byLevel = model.sortDescription and ns.WhatsNextSort() == "level"
	table.sort(rows, function(a, b)
		local aStatus, bStatus = STATUS_RANK[a.status], STATUS_RANK[b.status]
		if byLevel then
			if LevelOf(a) ~= LevelOf(b) then
				return LevelOf(a) < LevelOf(b)
			end
			if aStatus ~= bStatus then
				return aStatus < bStatus
			end
			return ByName(a, b)
		end
		if aStatus ~= bStatus then
			return aStatus < bStatus
		end
		if LevelOf(a) ~= LevelOf(b) then
			return LevelOf(a) < LevelOf(b)
		end
		return ByName(a, b)
	end)
	local sections, section = {}, nil
	for _, row in ipairs(rows) do
		local name
		if byLevel then
			name = row.level and L["SUBTEXT_LEARN_LEVEL"]:format(row.level) or L["WHATS_NEXT_ANY_LEVEL"]
		else
			name = model.statusLabel(row.status)
		end
		if not section or section.name ~= name then
			section = { name = name, status = not byLevel and row.status or nil, rows = {} }
			sections[#sections + 1] = section
		end
		section.rows[#section.rows + 1] = row
	end
	return sections
end

--------------------------------------------------------------------------------
-- Columns
--------------------------------------------------------------------------------

--[[
	Blocks are { section, first, last, continued, y }. A section that overflows carries on under its header again,
	marked continued; it moves whole when not even its header and one row fit.
]]
function ns.WhatsNextPaginate(sections, height)
	local columns, column, y = {}, nil, 0
	local function nextColumn()
		column, y = {}, 0
		columns[#columns + 1] = column
	end
	nextColumn()
	for _, section in ipairs(sections) do
		local first, continued = 1, false
		while first <= #section.rows do
			local gap = #column > 0 and SECTION_GAP or 0
			local fit = math.floor((height - y - gap - HEADER_HEIGHT - HEADER_GAP) / ROW_HEIGHT)
			if fit < 1 and #column > 0 then
				nextColumn()
			else
				-- an empty column always takes at least one row, so a section can never stall
				local last = math.min(#section.rows, first + math.max(fit, 1) - 1)
				column[#column + 1] =
					{ section = section, first = first, last = last, continued = continued, y = y + gap }
				y = y + gap + HEADER_HEIGHT + HEADER_GAP + (last - first + 1) * ROW_HEIGHT
				first = last + 1
				if first <= #section.rows then
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
