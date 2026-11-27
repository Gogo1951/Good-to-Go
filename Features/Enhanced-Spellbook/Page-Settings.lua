local _, ns = ...

function ns.ShowsAllRanks()
	return ns.HAS_SPELL_RANKS and ns.db.profile.showAllRanks
end

function ns.SetShowAllRanks(on)
	ns.db.profile.showAllRanks = on
end

-- Spells left off the page still have their WoW macros rewritten.
function ns.ShowsGroupedSpells()
	return ns.db.profile.showGroupedSpells
end

function ns.SetShowGroupedSpells(on)
	ns.db.profile.showGroupedSpells = on
end

function ns.ShowsUnlearned()
	return ns.db.profile.showUnlearned
end

function ns.SetShowUnlearned(on)
	ns.db.profile.showUnlearned = on
end

-- Nothing turns it off: it is the saved default, on, kept as a setting so Diagnostics can show it.
function ns.CountsSpellsOnBars()
	return ns.db.profile.countSpellsOnBars
end

-- "category" or "school"
function ns.PageSort()
	return ns.db.profile.pageSort
end

function ns.SetPageSort(sort)
	ns.db.profile.pageSort = sort
end

-- Keyed by ns.MacroIdentity, so two spells whose shortened names match never share a mark.
function ns.IsMarkedPlaced(macro)
	local marks = ns.db.profile.markedPlaced
	if marks[ns.MacroIdentity(macro)] == true then
		return true
	end
	-- MIGRATION (remove after 2026-12-08): marks saved by WoW macro name
	return marks[macro.macroName] == true
end

function ns.MarkAllPlaced()
	local marks = ns.db.profile.markedPlaced
	for _, macro in ipairs(ns.macros) do
		if not macro.unlearned then
			marks[ns.MacroIdentity(macro)] = true
		end
	end
	for _, macro in ipairs(ns.ConsumablePageMacros()) do
		marks[ns.MacroIdentity(macro)] = true
	end
end

function ns.ClearPlacedMarks()
	wipe(ns.db.profile.markedPlaced)
end

function ns.HasPlacedMarks()
	return next(ns.db.profile.markedPlaced) ~= nil
end
