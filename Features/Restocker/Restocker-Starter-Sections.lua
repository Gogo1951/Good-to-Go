local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    What the Staples window offers: the stack counts a staple's dropdown lists
    and how each reads, and the sections this character is offered, each with
    its categories in display order. Restocker-Starter-Window.lua draws them.
]]

--------------------------------------------------------------------------------
-- Choices
--------------------------------------------------------------------------------

--[[
    The counts a staple's dropdown offers, in offered order: every number up to
    its cap, or the category's own choices where it lists them (Soul Shards
    step in fours). A stack is whatever its item stacks to, so the label says
    stacks and the tooltip says how many; a category that counts items
    instead (countsItems) shows a bare number, since "1 Stack" of a thing that
    cannot stack reads as a bug.
]]
local function StackChoices(category)
	local offered = category.choices
	if not offered then
		offered = {}
		for stacks = 1, category.maxStacks do
			offered[stacks] = stacks
		end
	end
	return offered
end

local function StackLabel(category, stacks)
	if category.countsItems then
		return tostring(stacks)
	end
	if stacks == 1 then
		return L["STARTER_POPUP_STACK_ONE"]
	end
	return string.format(L["STARTER_POPUP_STACK_MANY"], stacks)
end

--[[
    One section's categories in display order, holding only the ones this
    class is offered right now -- Restocker-Starter-List.lua's class and
    availability rules keep another class's reagents, a not-yet-trained
    spell's reagent, and items this client's folder does not carry out.

    Display order is computed, never authored: the staples with a stacks
    dropdown lead, the fixed-amount singles follow, and each run sorts
    alphabetically by the name it shows, so every locale reads A to Z. A row
    whose name is still loading sorts after the named ones, by item ID, and
    takes its place when the window repaints with the name.
]]
local function SectionCategories(section)
	local categories = {}
	for _, category in ipairs(ns.GetStarterCategories()) do
		if
			category.section == section
			and ns.IsStarterCategoryForClass(category)
			and ns.IsStarterCategoryAvailable(category)
		then
			categories[#categories + 1] = category
		end
	end

	local names = {}
	for _, category in ipairs(categories) do
		names[category] = ns.GetStarterCategoryName(category) or false
	end
	table.sort(categories, function(a, b)
		local aFixed = a.fixedAmount ~= nil
		local bFixed = b.fixedAmount ~= nil
		if aFixed ~= bFixed then
			return bFixed
		end
		local aName, bName = names[a], names[b]
		if aName and bName then
			return aName < bName
		end
		if aName or bName then
			return aName ~= false
		end
		return ns.GetStarterCategoryNameItemID(a) < ns.GetStarterCategoryNameItemID(b)
	end)
	return categories
end

--[[
    The sections this character is offered, top to bottom from what everyone
    stocks to what one class does: food and water (water as the block's last
    cell, under a heading naming both), the rogue's poisons with their note,
    ammo, then the class reagents and tools, where the Hearthstone closes the
    window as the one row that is nobody's consumable. A section with nothing
    to offer is left out rather than drawn empty.
]]
local function OfferedSections()
	local sections = {}

	local provisions = SectionCategories("food")
	local waterCategories = SectionCategories("water")
	for _, category in ipairs(waterCategories) do
		provisions[#provisions + 1] = category
	end
	if #provisions > 0 then
		sections[#sections + 1] = {
			title = (#waterCategories > 0) and L["STARTER_POPUP_FOOD_AND_WATER_HEADER"]
				or L["STARTER_POPUP_FOOD_HEADER"],
			categories = provisions,
		}
	end

	local poisons = SectionCategories("poisons")
	if #poisons > 0 then
		sections[#sections + 1] = {
			title = L["STARTER_POPUP_POISONS_HEADER"],
			--[[
			    The crafting-reagent half of the Restocker already shops for a
			    listed poison's makings, and a fresh rogue has no way to know
			    that, so the section says so, opening with the class-colored
			    class name the mini-map menu's notes open with.
			]]
			note = string.format(
				L["STARTER_POPUP_POISONS_NOTE"],
				ns.GetClassColor("ROGUE") .. UnitClass("player") .. "|r" .. GetColor("BODY")
			),
			categories = poisons,
		}
	end

	local ammo = SectionCategories("ammo")
	if #ammo > 0 then
		sections[#sections + 1] = { title = L["STARTER_POPUP_AMMO_HEADER"], categories = ammo }
	end

	local reagents = SectionCategories("reagents")
	if #reagents > 0 then
		sections[#sections + 1] = { title = L["STARTER_POPUP_REAGENTS_HEADER"], categories = reagents }
	end
	return sections
end

ns.StarterStackChoices = StackChoices
ns.StarterStackLabel = StackLabel
ns.StarterOfferedSections = OfferedSections
