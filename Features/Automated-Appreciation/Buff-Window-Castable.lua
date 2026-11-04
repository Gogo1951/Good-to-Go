local _, ns = ...
local Data = ns.Data

--[[
    The Buff Window's castable list: the buffs this character can cast right
    now, rank by rank. Creates ns.BuffWindow, the table the other Buff Window
    files share their state and helpers through, and the lookup tables
    Buff-Window-Lookups.lua fills from this client's ns.BUFF_WINDOW_SPELLS
    rows; who each is offered to is Buff-Window-Settings.lua.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local BuffWindow = {}
ns.BuffWindow = BuffWindow

--[[
    One per data row with live ids: { key, row, ids, ranks, rankLevels, groupIds,
    auraIds }. rankLevels maps each single-target rank's id to its learn level.
]]
local entries = {}
local lookup = {} -- setting key (a row's first live single-target id) -> its entry
--[[
    Exclusive family ("BLESSING") -> every aura id in it, so a buff can ask
    whether the target carries another of yours from the same family.
]]
local exclusiveIds = {}
local buffs = {} -- the entries this character can cast right now, built by BuildBuffs
--[[
    The same three for self buffs (ns.BUFF_WINDOW_SELF_SPELLS), whose setting is
    when each one shows rather than who it is for.
]]
local selfEntries, selfLookup, selfBuffs = {}, {}, {}
--[[
    The same three for weapon enchants (ns.BUFF_WINDOW_WEAPON_ENCHANTS), the
    poisons and imbues. Their setting is what goes on each hand, so the
    castable list holds one per hand rather than one per row.
]]
local weaponEntries, weaponLookup, weaponBuffs = {}, {}, {}
--[[
    One per ns.BUFF_WINDOW_WEAPON_ITEMS row, the oils, stones and lures any
    class can use, shaped like a poison's entry: { key, row, ids, items,
    enchants, types, kind, itemLevel }. Picked per hand, not per class.
]]
local weaponItemEntries = {}
--[[
    Enchant id (what GetWeaponEnchantInfo reports) -> an entry that puts it
    on, for Diagnostics. Two items can share one (a Season of Discovery copy
    of Blessed Wizard Oil), so the window asks each pick's own enchants set.
]]
local weaponByEnchant = {}

BuffWindow.entries = entries
BuffWindow.lookup = lookup
BuffWindow.exclusiveIds = exclusiveIds
BuffWindow.buffs = buffs
BuffWindow.selfEntries = selfEntries
BuffWindow.selfLookup = selfLookup
BuffWindow.selfBuffs = selfBuffs
BuffWindow.weaponEntries = weaponEntries
BuffWindow.weaponLookup = weaponLookup
BuffWindow.weaponBuffs = weaponBuffs
BuffWindow.weaponItemEntries = weaponItemEntries
BuffWindow.weaponByEnchant = weaponByEnchant
--[[
    The Soulstone (ns.BUFF_WINDOW_SOULSTONE): its entry, and the buff the
    window offers when nobody in your group carries one. Both are replaced
    rather than refilled, so read them off BuffWindow at the time.
]]
BuffWindow.soulstoneEntry = nil
BuffWindow.soulstoneBuff = nil
-- The resurrection the Buff Key casts on a dead target, { id, name, ids }, or nil.
BuffWindow.resurrection = nil
--[[
    Seconds left under which a buff counts as missing; set from the profile at
    the start of each Refresh.
]]
BuffWindow.refreshSeconds = 0
BuffWindow.isSetUp = false

--------------------------------------------------------------------------------
-- Castable Buffs
--------------------------------------------------------------------------------

--[[
    Any known rank of a resurrection will do: its key casts by name, which
    resolves to the highest rank you know.
]]
local function FirstKnown(ids)
	for _, id in ipairs(ids) do
		if ns.IsPlayerSpell(id) then
			return id
		end
	end
	return nil
end

--[[
    The highest group version you know. The data lists them lowest first, so
    the last known one; the tooltip shows it and the button casts it by rank.
]]
local function HighestKnown(ids)
	for index = #ids, 1, -1 do
		if ns.IsPlayerSpell(ids[index]) then
			return ids[index]
		end
	end
	return nil
end

-- The client's spell subtext ("Rank 3").
local GetSpellSubtext = C_Spell.GetSpellSubtext

--[[
    What a macro types to cast exactly this rank: "Prayer of Fortitude(Rank 2)",
    or the bare name for a spell with no rank text.
]]
local function CastText(id, name)
	local subtext = GetSpellSubtext(id)
	return (subtext and subtext ~= "") and (name .. "(" .. subtext .. ")") or name
end

--[[
    The single-target ranks you know, highest first, each with what a macro
    types to cast exactly that rank: "Power Word: Fortitude(Rank 3)", or the bare
    name for a spell with no rank text. Ranks with different names (the three
    Detect Invisibility spells) carry their own.
]]
local function KnownRanks(entry)
	local known = {}
	for _, rank in ipairs(entry.ranks) do
		if ns.IsPlayerSpell(rank.id) then
			local name = C_Spell.GetSpellName(rank.id)
			if name then
				known[#known + 1] =
					{ id = rank.id, level = rank.level, name = name, castText = CastText(rank.id, name) }
			end
		end
	end
	table.sort(known, function(a, b)
		return a.level > b.level
	end)
	return known
end

--[[
    Rebuilt at setup, on SPELLS_CHANGED (a new rank, or the group version at its
    level) and when a setting on the panel changes.
]]
function BuffWindow.BuildBuffs()
	wipe(buffs)
	local _, playerClass = UnitClass("player")
	local audience = ns.db.global.buffWindow.audience
	for _, entry in ipairs(entries) do
		local who = audience[entry.key]
		if entry.row.class == playerClass and who and who ~= Data.BUFF_AUDIENCE.OFF then
			local ranks, groupId = KnownRanks(entry), HighestKnown(entry.groupIds)
			local groupName = groupId and C_Spell.GetSpellName(groupId)
			if ranks[1] or groupId then
				buffs[#buffs + 1] = {
					--[[
					    The buff's column in the window, shared by its single and
					    group icons so a party's group buff sits over the single
					    one it replaces.
					]]
					column = #buffs + 1,
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					manaOnly = entry.row.manaOnly,
					noCasters = entry.row.noCasters,
					exclusive = entry.row.exclusive,
					ranks = ranks,
					-- Set when you know any single-target rank at all.
					singleName = ranks[1] and ranks[1].name,
					groupId = groupId,
					groupIds = entry.groupIds,
					groupName = groupName,
					-- "Prayer of Fortitude(Rank 2)": the bare name can cast Rank 1.
					groupCastText = groupName and CastText(groupId, groupName),
				}
			end
		end
	end

	wipe(selfBuffs)
	local selfRefresh = ns.db.global.buffWindow.selfRefresh
	for _, entry in ipairs(selfEntries) do
		local when = selfRefresh[entry.key]
		if entry.row.class == playerClass and when and when ~= Data.SELF_REFRESH_OFF then
			local ranks = KnownRanks(entry)
			if ranks[1] then
				selfBuffs[#selfBuffs + 1] = {
					-- Self Buffs keeps its own grid, so its columns count from 1.
					column = #selfBuffs + 1,
					key = entry.key,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					exclusive = entry.row.exclusive,
					ranks = ranks,
					singleName = ranks[1].name,
					-- Its own "count as missing under", in seconds; 0 waits for it to drop.
					refreshSeconds = when * 60,
					-- Soul Link only means anything with a demon out.
					needsPet = entry.row.needsPet,
				}
			end
		end
	end

	--[[
	    One per hand with anything ticked, each its own row under Self Buffs:
	    the picks, all on the one Reapply timing -- your class's poisons or
	    imbues (classPick), and the oils, stones and lures any class can use.
	    The row orders its icons as it draws them, by the item or rank each
	    one uses (Buff-Window-Weapons.lua). An imbue needs a known rank; an item
	    is looked for in your bags at each refresh, since that changes without
	    SPELLS_CHANGED. Nothing while Weapon Buffs is off.
	]]
	wipe(weaponBuffs)
	local settings = ns.db.global.buffWindow
	local classHands = {}
	for _, hand in ipairs(ns.BUFF_WINDOW_WEAPON_HANDS[playerClass] or {}) do
		classHands[hand] = true
	end
	for _, hand in ipairs(settings.weaponEnabled and Data.WEAPON_HAND_ORDER or {}) do
		local chosen = {}
		local when = settings.weaponRefresh
		local function Choose(entry, ranks, classPick)
			chosen[#chosen + 1] = {
				key = entry.key,
				ranks = ranks,
				items = entry.items,
				enchants = entry.enchants,
				types = entry.types,
				zones = entry.zones,
				refreshSeconds = when * 60,
				durationSeconds = entry.row.duration and entry.row.duration * 60,
				classPick = classPick,
			}
		end
		for _, entry in ipairs(classHands[hand] and weaponEntries or {}) do
			local ranks = entry.ranks and KnownRanks(entry)
			if
				entry.row.class == playerClass
				and BuffWindow.WeaponChoiceOn(settings.weaponPicks, playerClass .. "_" .. hand, entry.key)
				and (entry.items or ranks[1])
			then
				Choose(entry, ranks, true)
			end
		end
		for _, entry in ipairs(weaponItemEntries) do
			local kindHands = Data.WEAPON_ITEM_KIND_HANDS[entry.kind]
			if
				(not kindHands or tContains(kindHands, hand))
				and BuffWindow.WeaponChoiceOn(settings.weaponItems, hand, entry.key)
			then
				Choose(entry)
			end
		end
		if chosen[1] then
			weaponBuffs[#weaponBuffs + 1] = {
				hand = hand,
				slot = Data.WEAPON_HAND_SLOTS[hand],
				picks = chosen,
			}
		end
	end

	--[[
	    Shaped like a self buff so Has can read it on anyone in the group: no
	    ranks of its own to weigh against theirs, only its auras. The button
	    makes a stone with the best Create Soulstone you know, cast by its bare
	    name -- Classic Era names each tier its own spell, and a "(Rank 1)"
	    added to one of those names a spell that doesn't exist.
	]]
	BuffWindow.soulstoneBuff = nil
	local stone = BuffWindow.soulstoneEntry
	local stoneWhen = stone and selfRefresh[stone.key]
	if stone and stone.row.class == playerClass and stoneWhen and stoneWhen ~= Data.SELF_REFRESH_OFF then
		local known = KnownRanks(stone)
		if known[1] then
			BuffWindow.soulstoneBuff = {
				column = #selfBuffs + 1,
				key = stone.key,
				auraIds = stone.auraIds,
				rankLevels = {},
				ranks = {},
				create = known[1],
				items = stone.items,
				refreshSeconds = stoneWhen * 60,
			}
		end
	end

	--[[
	    The Buff Key's resurrection (ns.BUFF_WINDOW_RESURRECTIONS): any rank
	    you know, cast by its bare name, which resolves to your highest.
	]]
	BuffWindow.resurrection = nil
	for _, row in ipairs(ns.BUFF_WINDOW_RESURRECTIONS or {}) do
		if row.class == playerClass then
			local id = FirstKnown(row.ranks)
			local name = id and C_Spell.GetSpellName(id)
			if name then
				BuffWindow.resurrection = { id = id, name = name, ids = row.ranks }
			end
		end
	end
end

-- Whether this character has anything at all the window could offer.
function BuffWindow.HasAnythingToOffer()
	return #buffs > 0
		or #selfBuffs > 0
		or #weaponBuffs > 0
		or BuffWindow.soulstoneBuff ~= nil
		or BuffWindow.resurrection ~= nil
end

--------------------------------------------------------------------------------
-- Ranks
--------------------------------------------------------------------------------

--[[
    A rank can go on a player at most this many levels below the level it is
    learned at; lower than that, the cast fails with "Target is too low level".
]]
local RANK_LEVEL_GAP = 10

-- The rule went with spell ranks: from Cataclysm on any buff goes on a target of any level.
local HAS_RANK_LEVEL_GAP = ns.EXPANSION <= 3

--[[
    The highest rank you know that a target of `level` can take, or nil when
    even your lowest is too high for them. An unknown level -- a stranger out of
    sight, or one too far above you to show (UnitLevel's -1) -- takes the top
    rank: there is nothing lower to fall back to.
]]
function BuffWindow.RankFor(buff, level)
	if not HAS_RANK_LEVEL_GAP or not ns.IsPlain(level) or not level or level <= 0 then
		return buff.ranks[1]
	end
	for _, rank in ipairs(buff.ranks) do
		if level >= rank.level - RANK_LEVEL_GAP then
			return rank
		end
	end
	return nil
end
