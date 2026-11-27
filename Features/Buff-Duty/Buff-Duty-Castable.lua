local _, ns = ...
local Data = ns.Data

-- Creates ns.BuffDuty; the lookup tables are wiped and refilled in place, so other files may capture them.

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local BuffDuty = {}
ns.BuffDuty = BuffDuty

-- One per data row with live ids; rankLevels maps each single-target rank's id to its learn level.
local entries = {}
local lookup = {} -- setting key (a row's first live single-target id) -> its entry
-- Exclusive family ("BLESSING") -> every aura id in it.
local exclusiveIds = {}
local buffs = {} -- the entries this character can cast right now, built by BuildBuffs
-- selfBuffs also holds your class's group buffs on yourself, after the self-only ones.
local selfEntries, selfLookup, selfBuffs = {}, {}, {}
-- A self item's ids are its auras.
local selfItemEntries, selfItemBuffs = {}, {}
-- weaponBuffs holds one per hand rather than one per row: the setting is what goes on each hand.
local weaponEntries, weaponLookup, weaponBuffs = {}, {}, {}
-- Shaped like a poison's entry, but picked per hand, not per class.
local weaponItemEntries = {}
--[[
    Enchant id -> an entry that puts it on. Two items can share one (a Season
    of Discovery copy of Blessed Wizard Oil), so the window asks each pick's
    own enchants which pick it is.
]]
local weaponByEnchant = {}

BuffDuty.entries = entries
BuffDuty.lookup = lookup
BuffDuty.exclusiveIds = exclusiveIds
BuffDuty.buffs = buffs
BuffDuty.selfEntries = selfEntries
BuffDuty.selfLookup = selfLookup
BuffDuty.selfBuffs = selfBuffs
BuffDuty.selfItemEntries = selfItemEntries
BuffDuty.selfItemBuffs = selfItemBuffs
BuffDuty.weaponEntries = weaponEntries
BuffDuty.weaponLookup = weaponLookup
BuffDuty.weaponBuffs = weaponBuffs
BuffDuty.weaponItemEntries = weaponItemEntries
BuffDuty.weaponByEnchant = weaponByEnchant
-- Replaced rather than refilled, so read these off BuffDuty at the time, never from a captured local.
BuffDuty.soulstoneEntry = nil
BuffDuty.soulstoneBuff = nil
BuffDuty.resurrection = nil
BuffDuty.resurrections = {}
-- Set each time BuffDuty.BuildSections runs.
BuffDuty.refreshSeconds = 0
BuffDuty.isSetUp = false

--------------------------------------------------------------------------------
-- Castable Buffs
--------------------------------------------------------------------------------

-- BuffDuty.BuildLookup sorts ids lowest level first.
local function HighestKnown(ids)
	for index = #ids, 1, -1 do
		if ns.IsPlayerSpell(ids[index]) then
			return ids[index]
		end
	end
	return nil
end

local GetSpellSubtext = C_Spell.GetSpellSubtext

-- "Prayer of Fortitude(Rank 2)", or the bare name for a spell with no rank text.
local function CastText(id, name)
	local subtext = GetSpellSubtext(id)
	return (subtext and subtext ~= "") and (name .. "(" .. subtext .. ")") or name
end
BuffDuty.CastText = CastText

-- Highest first. Ranks with different names (the three Detect Invisibility spells) carry their own.
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
BuffDuty.KnownRanks = KnownRanks

function BuffDuty.BuildBuffs()
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
					-- Shared by single and group icons, so a group buff sits over the single it replaces.
					column = #buffs + 1,
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					manaOnly = entry.row.manaOnly,
					noCasters = entry.row.noCasters,
					pets = entry.row.pets,
					noShadowform = entry.row.noShadowform,
					exclusive = entry.row.exclusive,
					ranks = ranks,
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
	local selfShow = BuffDuty.RowShowSeconds("self")
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
					refreshSeconds = selfShow,
					-- Soul Link only means anything with a demon out.
					needsPet = entry.row.needsPet,
					-- Shadowform: the Buff Key casts it after everything else.
					castLast = entry.row.castLast,
					noShadowform = entry.row.noShadowform,
					-- Battle Shout: it lands on your party too (BuffDuty.PvPFlaggedTarget).
					party = entry.row.party,
				}
			end
		end
	end

	--[[
	    Your group buffs on yourself: the party sections leave you out. Each
	    carries its group version so Has weighs your own Prayer of Fortitude by
	    its strength. Built before the Soulstone and self items, whose columns
	    follow these.
	]]
	for _, entry in ipairs(entries) do
		local when = selfRefresh[entry.key]
		local row = entry.row
		if
			row.class == playerClass
			and when
			and when ~= Data.SELF_REFRESH_OFF
			and not (row.manaOnly and Data.NO_MANA_CLASSES[playerClass])
			and not (row.noCasters and Data.CASTER_CLASSES[playerClass])
		then
			local ranks = KnownRanks(entry)
			if ranks[1] then
				selfBuffs[#selfBuffs + 1] = {
					column = #selfBuffs + 1,
					key = entry.key,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					exclusive = row.exclusive,
					noShadowform = row.noShadowform,
					ranks = ranks,
					singleName = ranks[1].name,
					groupId = HighestKnown(entry.groupIds),
					refreshSeconds = selfShow,
					isGroupBuff = true,
				}
			end
		end
	end

	BuffDuty.BuildWeaponBuffs(playerClass)

	--[[
	    Create Soulstone casts by bare name: Classic Era names each tier its own
	    spell, and a "(Rank 1)" added to one names a spell that doesn't exist.
	]]
	BuffDuty.soulstoneBuff = nil
	local stone = BuffDuty.soulstoneEntry
	local stoneWhen = stone and selfRefresh[stone.key]
	if stone and stone.row.class == playerClass and stoneWhen and stoneWhen ~= Data.SELF_REFRESH_OFF then
		local known = KnownRanks(stone)
		if known[1] then
			BuffDuty.soulstoneBuff = {
				column = #selfBuffs + 1,
				key = stone.key,
				auraIds = stone.auraIds,
				rankLevels = {},
				ranks = {},
				create = known[1],
				items = stone.items,
				refreshSeconds = selfShow,
			}
		end
	end

	-- No ranks, only auras, so any version on you counts.
	wipe(selfItemBuffs)
	for _, entry in ipairs(selfItemEntries) do
		local row = entry.wellFed and "food" or entry.scrolls and "scrolls" or entry.elixirs and "elixirs" or "other"
		if BuffDuty.RowOn(row) and (row ~= "other" or BuffDuty.SelfItemOn(entry.key)) then
			selfItemBuffs[#selfItemBuffs + 1] = {
				column = #selfBuffs + 2 + #selfItemBuffs,
				key = entry.key,
				itemId = entry.itemId,
				wellFed = entry.wellFed,
				scrolls = entry.scrolls,
				elixirs = entry.elixirs,
				auraIds = entry.auraIds,
				rankLevels = {},
				ranks = {},
				refreshSeconds = BuffDuty.RowShowSeconds(row),
			}
		end
	end

	BuffDuty.PickResurrection(playerClass)
end

function BuffDuty.HasAnythingToOffer()
	return #buffs > 0
		or #selfBuffs > 0
		or #selfItemBuffs > 0
		or #weaponBuffs > 0
		or BuffDuty.soulstoneBuff ~= nil
		or BuffDuty.resurrection ~= nil
end

--------------------------------------------------------------------------------
-- Ranks
--------------------------------------------------------------------------------

-- Further below a rank's learn level, the cast fails with "Target is too low level".
local RANK_LEVEL_GAP = 10

-- The rule went with spell ranks: from Cataclysm on any buff goes on a target of any level.
local HAS_RANK_LEVEL_GAP = ns.EXPANSION <= 3

-- An unknown level (UnitLevel's -1) takes the top rank: there is nothing lower to fall back to.
function BuffDuty.RankFor(buff, level)
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
