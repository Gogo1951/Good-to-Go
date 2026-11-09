local _, ns = ...
local L = ns.L

--[[
	The Spell Book tab's page order (Features/Enhanced-Spellbook/Spellbook-Page.lua lays it out): the macros sorted
	by school or by category, the filters applied, grouped into the categories the page draws under their headers.
]]

-- Whether one spell name sorts before another, ignoring case and accents where the client can compare UTF-8.
local function NameBefore(a, b)
	if strcmputf8i then
		return strcmputf8i(a, b) < 0
	end
	return a < b
end

--[[
	Whether a macro passes the page's filters: its name holds the filter box's text (filter, folded once by
	PageOrder, or nil for none), and it is in the school the filter dropdown picked under Sort By Category, or in
	the category it picked under Sort By School.
]]
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
	The macros in page order as { macro, header, sub } entries. Sorted by school, that is ns.macros under its
	spellbook tabs. Sorted by category, the spell macros go under their page category (ns.PageCategory), in
	ns.PAGE_CATEGORIES' order and alphabetically within each, any macro without a page category after them
	under its own section, then GtG Consumables (Consumable Macros' macros, see ns.ConsumablePageMacros), and the
	Unlearned section last, those keeping ns.macros' order; a focus, Duplicate or
	rank copy still follows its spell. Within a page category, the spells needing a form (sub, from
	ns.PageSubCategory) follow its own, a run for each form, the forms alphabetically, then the basic attacks. A macro the page hides (a
	grouped spell a later one replaced, see ns.ShowsGroupedSpells) or that the page's filters leave out
	(PassesFilters) is left out.
]]
local function PageOrder(page)
	local entries = {}
	local text = page.filterText
	local filter = text and text ~= "" and ns.FilterLower(text) or nil
	local consumables = ns.ConsumablePageMacros()
	if ns.PageSort() ~= "category" then
		-- GtG Consumables goes in ahead of the Unlearned section, which ns.macros ends with
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

--[[
	The page order as categories, each { name, macros, groups }: its macros in order, and its runs as groups of
	{ sub, macros }, sub the form's name, or nil for the category's own spells.
]]
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

-- The page's macros in page order, as categories (see PageOrder and Categories).
function ns.SpellbookPageCategories(page)
	return Categories(PageOrder(page))
end

-- the What's Next? tab's row order (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Layout.lua) shares the name order
ns.SpellNameBefore = NameBefore
