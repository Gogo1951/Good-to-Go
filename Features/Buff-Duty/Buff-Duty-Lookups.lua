local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Buff Duty's lookups: which of this client's ns.BUFF_DUTY_SPELLS,
    self buff, self item, weapon enchant, weapon item and Soulstone rows have live ids,
    filled into the tables Buff-Duty-Castable.lua keeps on ns.BuffDuty; and
    the options panels' class categories.
]]

local BuffDuty = ns.BuffDuty
local entries = BuffDuty.entries
local lookup = BuffDuty.lookup
local exclusiveIds = BuffDuty.exclusiveIds
local selfEntries = BuffDuty.selfEntries
local selfLookup = BuffDuty.selfLookup
local weaponEntries = BuffDuty.weaponEntries
local weaponLookup = BuffDuty.weaponLookup
local weaponItemEntries = BuffDuty.weaponItemEntries
local weaponByEnchant = BuffDuty.weaponByEnchant
local selfItemEntries = BuffDuty.selfItemEntries

--------------------------------------------------------------------------------
-- Lookups
--------------------------------------------------------------------------------

local function LiveIds(ids)
	local live = {}
	for _, id in ipairs(ids or {}) do
		if C_Spell.DoesSpellExist(id) then
			live[#live + 1] = id
		end
	end
	return live
end

--[[
    Row order in the data never says which rank is higher, so every list a
    reader takes a rank from by position is sorted here, once, lowest level
    first; rows on one level keep the data's order. levelOf reads an item's
    level.
]]
local function SortByLevel(list, levelOf)
	local order = {}
	for index, item in ipairs(list) do
		order[item] = index
	end
	table.sort(list, function(a, b)
		local left, right = levelOf(a), levelOf(b)
		if left ~= right then
			return left < right
		end
		return order[a] < order[b]
	end)
	return list
end

local function RankLevel(rank)
	return rank.level
end

-- A spell id with no level in the data, by the level the client says it is learned at.
local function LearnedLevel(id)
	return C_Spell.GetSpellLevelLearned(id) or 0
end

-- A rank list's ids, in the ranks' (sorted) order.
local function RankIds(ranks)
	local ids = {}
	for index, rank in ipairs(ranks) do
		ids[index] = rank.id
	end
	return ids
end

function BuffDuty.BuildLookup()
	wipe(entries)
	wipe(lookup)
	wipe(exclusiveIds)
	for _, row in ipairs(ns.BUFF_DUTY_SPELLS) do
		local ranks, ids, rankLevels = {}, {}, {}
		for _, rank in ipairs(row.single) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
				ids[#ids + 1] = rank[1]
				rankLevels[rank[1]] = rank[2]
			end
		end
		if ids[1] then
			-- The key stays the data's first live rank, so saved settings keep finding it.
			local key = ids[1]
			SortByLevel(ranks, RankLevel)
			ids = RankIds(ranks)
			local groupIds = SortByLevel(LiveIds(row.group), LearnedLevel)
			--[[
			    Any version counts as buffed: each rank's aura carries its own id.
			    Has drops a single-target rank below the one you'd cast. A Greater
			    Blessing only ever counts, never casts.
			]]
			local auraIds = {}
			for _, list in ipairs({ ids, groupIds, LiveIds(row.greater) }) do
				for _, id in ipairs(list) do
					auraIds[id] = true
				end
			end
			if row.exclusive then
				exclusiveIds[row.exclusive] = exclusiveIds[row.exclusive] or {}
				for id in pairs(auraIds) do
					exclusiveIds[row.exclusive][id] = true
				end
			end
			local entry = {
				key = key,
				row = row,
				ids = ids,
				ranks = ranks,
				rankLevels = rankLevels,
				groupIds = groupIds,
				auraIds = auraIds,
			}
			entries[#entries + 1] = entry
			lookup[entry.key] = entry
		end
	end

	wipe(selfEntries)
	wipe(selfLookup)
	for _, row in ipairs(ns.BUFF_DUTY_SELF_SPELLS) do
		local ranks, ids, auraIds, rankLevels = {}, {}, {}, {}
		for _, rank in ipairs(row.ranks) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
				ids[#ids + 1] = rank[1]
				auraIds[rank[1]] = true
				rankLevels[rank[1]] = rank[2]
			end
		end
		if ids[1] then
			local key = ids[1]
			SortByLevel(ranks, RankLevel)
			ids = RankIds(ranks)
			-- A buff whose aura isn't its cast (Demonic Sacrifice's four) names its auras.
			for _, id in ipairs(LiveIds(row.auras)) do
				auraIds[id] = true
			end
			if row.exclusive then
				exclusiveIds[row.exclusive] = exclusiveIds[row.exclusive] or {}
				for id in pairs(auraIds) do
					exclusiveIds[row.exclusive][id] = true
				end
			end
			local entry = { key = key, row = row, ids = ids, ranks = ranks, rankLevels = rankLevels, auraIds = auraIds }
			selfEntries[#selfEntries + 1] = entry
			selfLookup[entry.key] = entry
		end
	end

	--[[
	    A poison is an item, kept best first by the level it needs; an imbue is
	    a spell, kept like any self buff's ranks. Items aren't checked against
	    the client: a poison it doesn't know is one no bag ever holds. Every
	    rank's enchant id points back at its row (weaponByEnchant), for
	    Diagnostics; the window reads each pick's own enchants. A rank may name
	    several: TBC's Rockbiter lands a different enchant for each weapon
	    speed.
	]]
	local function AddEnchants(enchants, value)
		if type(value) == "table" then
			for _, enchant in ipairs(value) do
				enchants[enchant] = true
			end
		elseif value then
			enchants[value] = true
		end
	end
	--[[
	    Which layer each entry's enchant lands in (Data.WEAPON_LAYERS): on a
	    client where two stack, a poison, an imbue and the data's imbue items
	    in one, the oils, stones and lures in the other. Everywhere else the
	    one slot.
	]]
	local IMBUE, TEMPORARY = Data.WEAPON_LAYERS.IMBUE, Data.WEAPON_LAYERS.TEMPORARY
	local stack = ns.WEAPON_ENCHANTS_STACK == true
	local imbueItems = {}
	for _, itemId in ipairs(ns.BUFF_DUTY_WEAPON_IMBUE_ITEMS or {}) do
		imbueItems[itemId] = true
	end
	wipe(weaponEntries)
	wipe(weaponLookup)
	wipe(weaponByEnchant)
	for _, row in ipairs(ns.BUFF_DUTY_WEAPON_ENCHANTS) do
		local entry
		local enchants = {}
		if row.items then
			local items, ids = {}, {}
			for _, item in ipairs(row.items) do
				items[#items + 1] = { id = item[1], level = item[2] }
				ids[#ids + 1] = item[1]
				AddEnchants(enchants, item[3])
			end
			table.sort(items, function(a, b)
				return a.level > b.level
			end)
			-- A warlock's stone line also names the spells that conjure it, offered while none is in the bags.
			local create = {}
			for _, rank in ipairs(row.create or {}) do
				if C_Spell.DoesSpellExist(rank[1]) then
					create[#create + 1] = { id = rank[1], level = rank[2] }
				end
			end
			entry = {
				key = ids[1],
				row = row,
				ids = ids,
				items = items,
				create = create[1] and create or nil,
				enchants = enchants,
				layer = stack and IMBUE or TEMPORARY,
			}
		else
			local ranks, ids = {}, {}
			for _, rank in ipairs(row.ranks) do
				AddEnchants(enchants, rank[3])
				if C_Spell.DoesSpellExist(rank[1]) then
					ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
					ids[#ids + 1] = rank[1]
				end
			end
			if ids[1] then
				entry = {
					key = ids[1],
					row = row,
					ids = ids,
					ranks = ranks,
					enchants = enchants,
					layer = stack and IMBUE or TEMPORARY,
				}
			end
		end
		if entry then
			weaponEntries[#weaponEntries + 1] = entry
			weaponLookup[entry.key] = entry
			for enchant in pairs(enchants) do
				weaponByEnchant[enchant] = entry
			end
		end
	end

	--[[
	    Every other weapon item, one entry each: its enchant, the weapon types
	    it takes (a subclass mask, 0 for any weapon), and the only places it
	    works, for an item that has them.
	]]
	wipe(weaponItemEntries)
	for _, row in ipairs(ns.BUFF_DUTY_WEAPON_ITEMS) do
		local itemId = row[1]
		local entry = {
			key = itemId,
			row = row,
			ids = { itemId },
			items = { { id = itemId, level = row[2], itemLevel = row[6] } },
			enchants = { [row[3]] = true },
			types = row[4],
			kind = row[5],
			itemLevel = row[6],
			zones = row[7],
			layer = (stack and imbueItems[itemId]) and IMBUE or TEMPORARY,
		}
		weaponItemEntries[#weaponItemEntries + 1] = entry
		weaponByEnchant[row[3]] = weaponByEnchant[row[3]] or entry
	end

	--[[
	    A self item is counted by its auras and named on the panel by the
	    first. Its key is "item:<id>", so it can't meet a spell id among the
	    selfRefresh keys. Items aren't checked against the client, as with
	    poisons: one it doesn't know is one no bag ever holds.
	]]
	wipe(selfItemEntries)
	for _, row in ipairs(ns.BUFF_DUTY_SELF_ITEMS or {}) do
		local auras = LiveIds(row.auras)
		if auras[1] then
			local auraIds = {}
			for _, id in ipairs(auras) do
				auraIds[id] = true
			end
			selfItemEntries[#selfItemEntries + 1] =
				{ key = "item:" .. row[1], row = row, itemId = row[1], ids = auras, auraIds = auraIds }
		end
	end

	--[[
	    Well Fed, for any class, wherever the flavor knows the buff: offered
	    with whatever buff food the Food macro would eat (ns.bestBuffFoodID),
	    so it has no item of its own, and counted by every Well Fed aura, which
	    the window reads itself (Buff-Duty-Self.lua). Named on the panel by
	    the Well Fed spell. Shows When Missing by default where the flavor's
	    data sets ns.BUFF_DUTY_ITEM_BUFFS_SHOWN (WoW Forever, where buff food is
	    nearly all anyone carries), and is off elsewhere.
	]]
	if ns.WELL_FED_SPELL_ID and (next(ns.WELL_FED_BUFF_IDS or {}) or next(ns.WELL_FED_ICON_IDS or {})) then
		local default = ns.BUFF_DUTY_ITEM_BUFFS_SHOWN and Data.SELF_REFRESH_MISSING or Data.SELF_REFRESH_OFF
		selfItemEntries[#selfItemEntries + 1] = {
			key = "wellFed",
			row = { default = default },
			wellFed = true,
			ids = { ns.WELL_FED_SPELL_ID },
			auraIds = {},
			desc = L["BUFF_DUTY_WELL_FED_DESCRIPTION_FORMAT"]:format(ns.GetWellFedName()),
		}
	end

	--[[
	    Scrolls, for any class, wherever the flavor has them: one entry for
	    every scroll type, offered as an icon per type (Buff-Duty-Self.lua).
	    Named on the panel as Scrolls, with the buff of the first type's scroll
	    needing the lowest level for its icon. Shows When Missing by default where Well
	    Fed does (ns.BUFF_DUTY_ITEM_BUFFS_SHOWN), and is off elsewhere.
	]]
	local firstScroll = ns.SCROLL_DATA and ns.SCROLL_DATA[ns.SCROLL_CHECK_ORDER[1]]
	local lowestScroll
	for _, item in ipairs(firstScroll and firstScroll.items or {}) do
		if not lowestScroll or item[3] < lowestScroll[3] then
			lowestScroll = item
		end
	end
	local scrollIds = lowestScroll and LiveIds({ lowestScroll[2] }) or {}
	if scrollIds[1] then
		selfItemEntries[#selfItemEntries + 1] = {
			key = "scrolls",
			row = { default = ns.BUFF_DUTY_ITEM_BUFFS_SHOWN and Data.SELF_REFRESH_MISSING or Data.SELF_REFRESH_OFF },
			scrolls = true,
			name = L["BUFF_DUTY_SCROLLS"],
			ids = scrollIds,
			auraIds = {},
			desc = L["BUFF_DUTY_SCROLLS_DESCRIPTION"],
		}
	end

	--[[
	    The Soulstone is offered by its Create Soulstone ranks, counted by its
	    Soulstone Resurrection auras, and named on the panel by the aura. Its
	    stones are kept as item ids, lowest level first.
	]]
	BuffDuty.soulstoneEntry = nil
	local stone = ns.BUFF_DUTY_SOULSTONE
	local ranks, auraIds = {}, {}
	for _, rank in ipairs(stone.create) do
		if C_Spell.DoesSpellExist(rank[1]) then
			ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
		end
	end
	local auras = LiveIds(stone.auras)
	for _, id in ipairs(auras) do
		auraIds[id] = true
	end
	if ranks[1] and auras[1] then
		local key = ranks[1].id
		local stones = {}
		for _, item in ipairs(stone.items) do
			stones[#stones + 1] = { id = item[1], level = item[2] }
		end
		BuffDuty.soulstoneEntry = {
			key = key,
			row = stone,
			ids = auras,
			ranks = SortByLevel(ranks, RankLevel),
			auraIds = auraIds,
			items = RankIds(SortByLevel(stones, RankLevel)),
		}
	end

	--[[
	    Each class's resurrection, its live ranks lowest first by the level the
	    client says each is learned at (the data carries none), for the Buff Key
	    (BuffDuty.PickResurrection).
	]]
	BuffDuty.resurrections = {}
	for _, row in ipairs(ns.BUFF_DUTY_RESURRECTIONS) do
		local live = SortByLevel(LiveIds(row.ranks), LearnedLevel)
		if live[1] then
			BuffDuty.resurrections[#BuffDuty.resurrections + 1] = { class = row.class, ranks = live }
		end
	end
end

--------------------------------------------------------------------------------
-- Display Categories
--------------------------------------------------------------------------------

--[[
    One class-colored category per class with live rows, each entry the
    { key, ids, spellName } the panel's audience dropdown needs. Every class is
    listed, not just yours, because these settings are account-wide.
    Only the single-target ids are carried: the dropdown should show and
    describe the buff, not its group version.
]]
function BuffDuty.BuildCategories(list)
	local buckets = {}
	for _, entry in ipairs(list) do
		local class = entry.row.class
		buckets[class] = buckets[class] or {}
		local bucket = buckets[class]
		bucket[#bucket + 1] = {
			key = entry.key,
			ids = entry.ids,
			spellName = C_Spell.GetSpellName(entry.ids[1]) or L["TRACKED_SPELL_PENDING"]:format(entry.ids[1]),
			exclusive = entry.row.exclusive,
		}
	end

	local classNames = {}
	for class in pairs(buckets) do
		classNames[#classNames + 1] = class
	end
	table.sort(classNames)

	local categories = {}
	for _, class in ipairs(classNames) do
		local label = ns.ClassName(class)
		categories[#categories + 1] = { id = class, name = label, entries = buckets[class] }
	end
	return categories
end

--[[
    The options panel reads this to say why the window never shows on a class
    with nothing to give on this client.
]]
function ns.BuffDutyHasClassRows()
	-- Any class can use an oil, a stone or a self item.
	if weaponItemEntries[1] or selfItemEntries[1] then
		return true
	end
	local _, playerClass = UnitClass("player")
	for _, list in ipairs({ entries, selfEntries, weaponEntries, { BuffDuty.soulstoneEntry } }) do
		for _, entry in ipairs(list) do
			if entry.row.class == playerClass then
				return true
			end
		end
	end
	return false
end
