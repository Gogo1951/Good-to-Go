local _, ns = ...
local L = ns.L

-- Whether one spell name sorts before another, ignoring case and accents where the client can compare UTF-8.
local function NameBefore(a, b)
	if strcmputf8i then
		return strcmputf8i(a, b) < 0
	end
	return a < b
end

-- filter is folded once by PageOrder, or nil for none.
local function PassesFilters(page, filter, macro)
	if filter and not ns.FilterLower(macro.label or macro.name):find(filter, 1, true) then
		return false
	end
	local picked = page.groupFilter
	if not picked then
		return true
	elseif ns.PageSort() == "category" then
		return macro.category == picked
	end
	return not macro.unlearned and ns.PageCategory(macro) == picked
end

-- Past every section a spellbook tab can make (#ns.PAGE_CATEGORIES + its tab's rank), short of Unlearned's.
local CONSUMABLES_RANK = 1000000

--[[
	{ macro, header, sub } entries. By category: ns.PAGE_CATEGORIES order, then macros with no page category,
	then Consumable Macros, then Unlearned. A Duplicate or rank copy follows its spell; within a category, each
	form's run follows its own spells, then the basic attacks.
]]
local function PageOrder(page)
	local entries = {}
	local text = page.filterText
	local filter = text and text ~= "" and ns.FilterLower(text) or nil
	local consumables = ns.ConsumablePageMacros()
	if ns.PageSort() ~= "category" then
		-- Consumable Macros goes in ahead of the Unlearned section, which ns.macros ends with
		local function addConsumables()
			for _, macro in ipairs(consumables) do
				if PassesFilters(page, filter, macro) then
					entries[#entries + 1] = { macro = macro, header = macro.category }
				end
			end
			consumables = {}
		end
		for _, macro in ipairs(ns.macros) do
			if macro.unlearned then
				addConsumables()
			end
			if not macro.hidden and PassesFilters(page, filter, macro) then
				entries[#entries + 1] = { macro = macro, header = macro.category }
			end
		end
		addConsumables()
		return entries
	end
	local labels, ranks = {}, {}
	for i, row in ipairs(ns.PAGE_CATEGORIES) do
		labels[row.key], ranks[row.key] = L[row.labelKey], i
	end
	local knownForms = ns.KnownForms()
	for i, macro in ipairs(ns.macros) do
		local entry = { macro = macro, index = i }
		local category = not macro.unlearned and ns.PageCategory(macro)
		if macro.unlearned then
			entry.rank, entry.header = math.huge, macro.category
		elseif category then
			entry.rank, entry.header = ranks[category], labels[category]
			entry.sub, entry.subRank = ns.PageSubCategory(macro, knownForms)
		else
			entry.rank, entry.header = #ns.PAGE_CATEGORIES + macro.categoryRank, macro.category
		end
		if not macro.hidden and PassesFilters(page, filter, macro) then
			entries[#entries + 1] = entry
		end
	end
	-- after every section but Unlearned, in the Consumable Macros panel's order
	for position, macro in ipairs(consumables) do
		if PassesFilters(page, filter, macro) then
			entries[#entries + 1] = {
				macro = macro,
				index = #ns.macros + position,
				rank = CONSUMABLES_RANK,
				header = macro.category,
			}
		end
	end
	table.sort(entries, function(a, b)
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		-- the category's own spells, then each form's, then the basic attacks
		if a.subRank ~= b.subRank then
			return (a.subRank or 0) < (b.subRank or 0)
		end
		if a.sub ~= b.sub then
			return NameBefore(a.sub, b.sub)
		end
		-- a page category's spells alphabetically by the name the page shows, each copy after its spell
		local aName, bName = a.macro.sortName or a.macro.name, b.macro.sortName or b.macro.name
		if a.rank <= #ns.PAGE_CATEGORIES and aName ~= bName then
			return NameBefore(aName, bName)
		end
		return a.index < b.index
	end)
	return entries
end

-- Each { name, macros, groups }; a group is { sub, macros }, sub nil for the category's own spells.
local function Categories(entries)
	local categories, category, group = {}, nil, nil
	for _, entry in ipairs(entries) do
		if not category or entry.header ~= category.name then
			category = { name = entry.header, macros = {}, groups = {} }
			categories[#categories + 1] = category
			group = nil
		end
		if not group or group.sub ~= entry.sub then
			group = { sub = entry.sub, macros = {} }
			category.groups[#category.groups + 1] = group
		end
		group.macros[#group.macros + 1] = entry.macro
		category.macros[#category.macros + 1] = entry.macro
	end
	return categories
end

function ns.SpellbookPageCategories(page)
	return Categories(PageOrder(page))
end

-- shared with the What's Next? rows
ns.SpellNameBefore = NameBefore
