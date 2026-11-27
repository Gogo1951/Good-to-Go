local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- What The List Shows
--------------------------------------------------------------------------------

--[[
    Both walks take a view built once per redraw (ns.BuildRestockView): the sort
    comparator asks for a group on every comparison, which would otherwise cost
    item lookups on every filter keystroke.
]]

--[[
    string.lower folds ASCII only, so the Latin and Cyrillic capitals (2-byte
    UTF-8: U+00C0 to U+00DE, U+0401, U+0410 to U+042F) are mapped here.
]]
local FOLD_UPPER = {}
for code = 0xC0, 0xDE do
	if code ~= 0xD7 then
		FOLD_UPPER[string.char(0xC3, code - 0x40)] = string.char(0xC3, code - 0x20)
	end
end
for code = 0x10, 0x1F do
	FOLD_UPPER[string.char(0xD0, 0x80 + code)] = string.char(0xD0, 0xA0 + code)
end
for code = 0x20, 0x2F do
	FOLD_UPPER[string.char(0xD0, 0x80 + code)] = string.char(0xD1, 0x60 + code)
end
FOLD_UPPER[string.char(0xD0, 0x81)] = string.char(0xD1, 0x91)

local function Fold(text)
	return (text:lower():gsub("[\195\208][\128-\191]", FOLD_UPPER))
end

local function IsNewItem(item)
	return (item.itemID ~= nil) and (ns.restockNewItems[item.itemID] == true)
end

-- GetItemInfoInstant answers without the item cache, so a cold row files under its real group.
function ns.GetRestockItemTypeName(itemID)
	if not itemID then
		return nil
	end
	local _, itemType = C_Item.GetItemInfoInstant(itemID)
	if itemType and itemType ~= "" then
		return itemType
	end
	return nil
end

--[[
    Groups are keyed by classID or a sentinel, never a name: a translated "New"
    or "Other" can equal a client class name, and the two groups would merge.
]]
local GROUP_NEW = "NEW"
local GROUP_OTHER = "OTHER"
ns.RESTOCK_GROUP_NEW = GROUP_NEW

local classLabels = {}

function ns.GetRestockGroupLabel(group)
	if group == GROUP_NEW then
		return L["RESTOCKER_GROUP_NEW"]
	end
	return classLabels[group] or L["RESTOCKER_GROUP_OTHER"]
end

-- Just-added items report the New group until the window closes.
local function ItemGroupOf(item)
	if IsNewItem(item) then
		return GROUP_NEW
	end
	if item.itemID then
		local _, itemType, _, _, _, classID = C_Item.GetItemInfoInstant(item.itemID)
		if classID and itemType and itemType ~= "" then
			classLabels[classID] = itemType
			return classID
		end
	end
	return GROUP_OTHER
end

-- Characters, not bytes: a Cyrillic or accented letter takes two bytes. Counts every byte that doesn't continue one.
local function CharacterCount(text)
	return select(2, text:gsub("[^\128-\191]", ""))
end

-- Rebuilt every redraw, never cached: an item's group moves when its data arrives or it leaves New.
function ns.BuildRestockView(items)
	local filter = ns.restockListFilter
	local view = {
		groups = {},
		filter = (filter and CharacterCount(filter) >= 2) and Fold(filter) or nil,
	}
	for _, item in ipairs(items) do
		view.groups[item] = ItemGroupOf(item)
	end
	return view
end

-- A New item always passes: a row must never vanish the moment it is added.
local function PassesTextFilter(view, item)
	if not view.filter or view.groups[item] == GROUP_NEW then
		return true
	end
	return (Fold(item.itemName or ""):find(view.filter, 1, true) ~= nil)
		or (Fold(ns.GetRestockGroupLabel(view.groups[item])):find(view.filter, 1, true) ~= nil)
		or (tostring(item.itemID or ""):find(view.filter, 1, true) ~= nil)
end

--[[
    Counted after the text filter, so a count always matches what clicking it
    shows. New sorts first: it is where the item just added went.
]]
function ns.BuildRestockGroupList(items, view)
	local counts, order = {}, {}
	local total = 0
	for _, item in ipairs(items) do
		if PassesTextFilter(view, item) then
			local group = view.groups[item]
			if not counts[group] then
				counts[group] = 0
				order[#order + 1] = group
			end
			counts[group] = counts[group] + 1
			total = total + 1
		end
	end

	table.sort(order, function(a, b)
		if (a == GROUP_NEW) ~= (b == GROUP_NEW) then
			return a == GROUP_NEW
		end
		return ns.GetRestockGroupLabel(a) < ns.GetRestockGroupLabel(b)
	end)

	local groups = {}
	for _, group in ipairs(order) do
		groups[#groups + 1] = { group = group, label = ns.GetRestockGroupLabel(group), count = counts[group] }
	end
	return groups, total
end

function ns.BuildRestockRenderList(items, view)
	local selected = ns.restockSelectedGroup
	local kept = {}
	for _, item in ipairs(items) do
		if PassesTextFilter(view, item) and (selected == nil or view.groups[item] == selected) then
			kept[#kept + 1] = item
		end
	end

	-- New ranks ahead of every group; sorting it by label would file it mid-list.
	local groups = view.groups
	table.sort(kept, function(a, b)
		local groupA, groupB = groups[a], groups[b]
		local newA, newB = groupA == GROUP_NEW, groupB == GROUP_NEW
		if newA ~= newB then
			return newA
		end
		if groupA ~= groupB then
			local labelA, labelB = ns.GetRestockGroupLabel(groupA), ns.GetRestockGroupLabel(groupB)
			if labelA ~= labelB then
				return labelA < labelB
			end
			return tostring(groupA) < tostring(groupB)
		end
		local nameA, nameB = a.itemName or "", b.itemName or ""
		if nameA ~= nameB then
			return nameA < nameB
		end
		return (a.itemID or 0) < (b.itemID or 0)
	end)

	return kept
end
