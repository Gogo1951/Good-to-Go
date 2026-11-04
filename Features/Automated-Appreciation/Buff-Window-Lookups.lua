local _, ns = ...
local L = ns.L

--[[
    The Buff Window's lookups: which of this client's ns.BUFF_WINDOW_SPELLS,
    self buff, weapon enchant, weapon item and Soulstone rows have live ids,
    filled into the tables Buff-Window-Castable.lua keeps on ns.BuffWindow;
    the options panels' class categories; and the item ids whose data the
    Weapon Buffs panel waits on.
]]

local BuffWindow = ns.BuffWindow
local entries = BuffWindow.entries
local lookup = BuffWindow.lookup
local exclusiveIds = BuffWindow.exclusiveIds
local selfEntries = BuffWindow.selfEntries
local selfLookup = BuffWindow.selfLookup
local weaponEntries = BuffWindow.weaponEntries
local weaponLookup = BuffWindow.weaponLookup
local weaponItemEntries = BuffWindow.weaponItemEntries
local weaponByEnchant = BuffWindow.weaponByEnchant

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Every poison, weapon item and Soulstone item id this client's data names.
local itemIds = {}

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

function BuffWindow.BuildLookup()
	wipe(entries)
	wipe(lookup)
	wipe(exclusiveIds)
	for _, row in ipairs(ns.BUFF_WINDOW_SPELLS) do
		local ranks, ids, rankLevels = {}, {}, {}
		for _, rank in ipairs(row.single) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
				ids[#ids + 1] = rank[1]
				rankLevels[rank[1]] = rank[2]
			end
		end
		if ids[1] then
			local groupIds = LiveIds(row.group)
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
				key = ids[1],
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
	for _, row in ipairs(ns.BUFF_WINDOW_SELF_SPELLS) do
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
			local entry =
				{ key = ids[1], row = row, ids = ids, ranks = ranks, rankLevels = rankLevels, auraIds = auraIds }
			selfEntries[#selfEntries + 1] = entry
			selfLookup[entry.key] = entry
		end
	end

	--[[
	    A poison is an item, kept best first by the level it needs; an imbue is
	    a spell, kept like any self buff's ranks. Items aren't checked against
	    the client: a poison it doesn't know is one no bag ever holds. Every
	    rank's enchant id points back at its row (weaponByEnchant), which is how
	    the window tells which of the player's picks a weapon carries. A rank
	    may name several: TBC's Rockbiter lands a different enchant for each
	    weapon speed.
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
	wipe(weaponEntries)
	wipe(weaponLookup)
	wipe(weaponByEnchant)
	for _, row in ipairs(ns.BUFF_WINDOW_WEAPON_ENCHANTS) do
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
			entry = { key = ids[1], row = row, ids = ids, items = items, enchants = enchants }
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
				entry = { key = ids[1], row = row, ids = ids, ranks = ranks, enchants = enchants }
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
	for _, row in ipairs(ns.BUFF_WINDOW_WEAPON_ITEMS or {}) do
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
		}
		weaponItemEntries[#weaponItemEntries + 1] = entry
		weaponByEnchant[row[3]] = weaponByEnchant[row[3]] or entry
	end

	--[[
	    Ask for every poison's, weapon item's and Soulstone's item data now, so
	    the Weapon Buffs panel names each one instead of its "Item #"
	    placeholder; ns.OnBuffWindowItemInfo repaints the panel as each one
	    arrives.
	]]
	wipe(itemIds)
	for _, list in ipairs({ weaponEntries, weaponItemEntries }) do
		for _, entry in ipairs(list) do
			for _, id in ipairs(entry.items and entry.ids or {}) do
				itemIds[id] = true
			end
		end
	end
	for _, id in ipairs(ns.BUFF_WINDOW_SOULSTONE and ns.BUFF_WINDOW_SOULSTONE.items or {}) do
		itemIds[id] = true
	end
	for id in pairs(itemIds) do
		C_Item.RequestLoadItemDataByID(id)
	end

	--[[
	    The Soulstone is offered by its Create Soulstone ranks, counted by its
	    Soulstone Resurrection auras, and named on the panel by the aura.
	]]
	BuffWindow.soulstoneEntry = nil
	local stone = ns.BUFF_WINDOW_SOULSTONE
	if stone then
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
			BuffWindow.soulstoneEntry = {
				key = ranks[1].id,
				row = stone,
				ids = auras,
				ranks = ranks,
				auraIds = auraIds,
				items = stone.items,
			}
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
function BuffWindow.BuildCategories(list)
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

-- Called from Tracked-Lookups' GET_ITEM_INFO_RECEIVED handler, which owns the event.
function ns.OnBuffWindowItemInfo(itemId)
	if itemIds[itemId] then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.BuffWindowWeaponBuffs)
	end
end

-- Diagnostics reads this to log a poison's, weapon item's or Soulstone's item load in full.
function ns.IsBuffWindowItem(itemId)
	return itemIds[itemId] == true
end

--[[
    The options panel reads this to say why the window never shows on a class
    with nothing to give on this client.
]]
function ns.BuffWindowHasClassRows()
	-- Any class can use an oil or a stone.
	if weaponItemEntries[1] then
		return true
	end
	local _, playerClass = UnitClass("player")
	for _, list in ipairs({ entries, selfEntries, weaponEntries, { BuffWindow.soulstoneEntry } }) do
		for _, entry in ipairs(list) do
			if entry.row.class == playerClass then
				return true
			end
		end
	end
	return false
end
