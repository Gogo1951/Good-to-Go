local _, ns = ...
local ByLevel = ns.SpellRankByLevel
local AddRankLinesFor = ns.AddSpellRankLines

--[[
	A spell's ranks and the level each needs, "Firebolt Ranks … GtG" and a line for each (ns.AddSpellRanksTooltip;
	the What's Next? rows, Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Page.lua, use ns.SpellRankRows and ns.AddSpellRankLines),
	under every spell tooltip the game shows: action bars, the game's own spell book, other add-ons. Tooltips that
	add the ranks themselves (the Spell Book page's tiles, the What's Next? rows) set ns.spellTooltipHasOwnRanks
	around their SetSpellByID so the lines aren't doubled. The rank lines themselves are Spell-Rank-Lines.lua.
]]

--------------------------------------------------------------------------------
-- Rows Cache
--------------------------------------------------------------------------------

--[[
	An action bar's tooltip refreshes several times a second, so the What's Next? rows behind it are built once
	and kept, with each spell's row by ID and each spell's ranks by name, until something they read changes.
	Spellbook-Events.lua, Trainer-Recording.lua and Spellbook-Core.lua call ns.InvalidateSpellRankRows on those
	changes: a spell learned, a spell's data loading, the pet changing, a trainer's list recorded, a profile
	change, the Spellbook switched back on after its events went unheard. A level
	gained is caught here instead, by the level each set was built at, since UnitLevel still reports the old
	level while PLAYER_LEVEL_UP fires.
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

--[[
	Adds the ranks of spellID's spell to GameTooltip, for a tooltip outside the What's Next? tabs: mostly the
	game's own spell tooltips (AddRanks, below, hooked onto every one), and also the Spell Book page's tiles
	(Features/Enhanced-Spellbook/Macro-Button.lua) and the Pet Spell Book's rows. pet reads the pet's
	abilities (ns.WhatsNextPetRows) rather than the class's (ns.WhatsNextRows); blankFirst puts a blank line
	above them. Returns whether it added any: nothing for a spell the rows don't hold or with one rank.
]]
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

--[[
	The class's What's Next? row for spellID, else the lowest-level row named name, or nil: what gives a macro
	menu's ranks and grouped spells (Features/Enhanced-Spellbook/Macro-Menu-Sections.lua) the same status and source as the
	tooltip's.
]]
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
