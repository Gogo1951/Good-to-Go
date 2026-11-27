local _, ns = ...
local ByLevel = ns.SpellRankByLevel
local AddRankLinesFor = ns.AddSpellRankLines

--[[
	Tooltips that add the ranks themselves set ns.spellTooltipHasOwnRanks around their SetSpellByID, so the
	lines aren't doubled.
]]

--------------------------------------------------------------------------------
-- Rows Cache
--------------------------------------------------------------------------------

--[[
	An action bar's tooltip refreshes several times a second, so the rows are kept until
	ns.InvalidateSpellRankRows. A level gained is caught here, by the level each set was built at, since UnitLevel
	still reports the old level while PLAYER_LEVEL_UP fires.
]]
local cache = {}

function ns.InvalidateSpellRankRows(petOnly)
	cache.pet = nil
	if not petOnly then
		cache.class = nil
	end
end

local function RankKey(name, extra)
	return (extra and "extra:" or "rank:") .. name
end

local function BuildIndex(rows)
	local byId, ranks = {}, {}
	for _, row in ipairs(rows) do
		byId[row.id] = byId[row.id] or row
		local key = RankKey(row.name, row.extra)
		ranks[key] = ranks[key] or {}
		table.insert(ranks[key], row)
	end
	for _, list in pairs(ranks) do
		table.sort(list, ByLevel)
	end
	return { rows = rows, byId = byId, ranks = ranks }
end

local function CachedIndex(pet)
	local key = pet and "pet" or "class"
	local level = UnitLevel("player")
	local petLevel = pet and UnitLevel("pet") or nil
	local entry = cache[key]
	if not entry or entry.level ~= level or entry.petLevel ~= petLevel then
		entry = BuildIndex(pet and ns.WhatsNextPetRows() or ns.WhatsNextRows())
		entry.level, entry.petLevel = level, petLevel
		cache[key] = entry
	end
	return entry
end

-- pet reads the pet's abilities. Returns whether it added any: none for a spell with one rank or no rows.
function ns.AddSpellRanksTooltip(spellID, pet, blankFirst)
	local index = CachedIndex(pet)
	local row = index.byId[spellID]
	-- a spell the rows don't list by this ID (a rank the data leaves out) still finds its namesakes
	if not row then
		local name = ns.SpellName(spellID)
		row = name and { id = spellID, name = name } or nil
	end
	local ranks = row and index.ranks[RankKey(row.name, row.extra)]
	if not ranks or #ranks < 2 then
		return false
	end
	if blankFirst then
		GameTooltip:AddLine(" ")
	end
	AddRankLinesFor(row, ranks)
	return true
end

-- Gives a macro menu's ranks and grouped spells the same status and source as the tooltip's.
function ns.ClassRankRow(spellID, name)
	local index = CachedIndex(false)
	if spellID and index.byId[spellID] then
		return index.byId[spellID]
	end
	local found
	for _, row in ipairs(index.rows) do
		if name and row.name == name and (not found or (row.level or 0) < (found.level or 0)) then
			found = row
		end
	end
	return found
end

-- One set of rank lines per showing, though the client may report the same spell more than once.
local added = false

local function AddRanks(tooltip, spellID)
	if tooltip ~= GameTooltip or added or ns.spellTooltipHasOwnRanks or not ns.IsSpellbookEnabled() then
		return
	end
	-- the Enhanced Spellbook panel's What's Next Ability Tooltips switch
	if not ns.db.global.abilityTooltipRanks then
		return
	end
	-- in combat a spell's tooltip stays the game's own, short
	if InCombatLockdown() then
		return
	end
	if not spellID or not ns.IsPlain(spellID) then
		return
	end
	-- the class's spells first, then a hunter's beast's or a warlock's demon's abilities
	if
		ns.AddSpellRanksTooltip(spellID, false, true)
		or (ns.HasWhatsNextPet() and ns.AddSpellRanksTooltip(spellID, true, true))
	then
		added = true
		tooltip:Show()
	end
end

GameTooltip:HookScript("OnTooltipCleared", function()
	added = false
end)

ns.AddSpellTooltipPostCall(AddRanks)
