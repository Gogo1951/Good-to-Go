local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

-- What the Staples window offers; Restocker-Starter-Window.lua draws it.

--------------------------------------------------------------------------------
-- Choices
--------------------------------------------------------------------------------

-- A countsItems category shows a bare number: "1 Stack" of a thing that can't stack reads as a bug.
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
    Display order is computed, never authored, so every locale reads A to Z:
    dropdown rows, then fixed-amount ones, each by shown name. A name still
    loading sorts last, by item ID, until the repaint.
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

-- From what everyone stocks to what one class does; an empty section is left out, never drawn empty.
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
			-- The Restocker already buys a listed poison's reagents, which a fresh rogue can't know.
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
