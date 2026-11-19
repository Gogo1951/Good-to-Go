local _, ns = ...
local Data = ns.Data

--[[
    Buff Duty's castable list: the buffs this character can cast right
    now, rank by rank. Creates ns.BuffDuty, the table the other Buff Duty
    files share their state and helpers through, and the lookup tables
    Buff-Duty-Lookups.lua fills from this client's ns.BUFF_DUTY_SPELLS
    rows; who each is offered to is Buff-Duty-Settings.lua.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local BuffDuty = {}
ns.BuffDuty = BuffDuty

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
    The same three for self buffs (ns.BUFF_DUTY_SELF_SPELLS), whose setting is
    when each one shows rather than who it is for. selfBuffs also holds your
    class's group buffs on yourself, which BuildBuffs adds after the self-only
    ones.
]]
local selfEntries, selfLookup, selfBuffs = {}, {}, {}
--[[
    One per ns.BUFF_DUTY_SELF_ITEMS row, the consumables any class keeps up
    on itself (Winterfall Firewater): { key, row, itemId, ids, auraIds }, ids
    being its auras. selfItemBuffs holds the ones turned on, offered while
    one is in your bags.
]]
local selfItemEntries, selfItemBuffs = {}, {}
--[[
    The same three for weapon enchants (ns.BUFF_DUTY_WEAPON_ENCHANTS), the
    poisons and imbues. Their setting is what goes on each hand, so the
    castable list holds one per hand rather than one per row.
]]
local weaponEntries, weaponLookup, weaponBuffs = {}, {}, {}
--[[
    One per ns.BUFF_DUTY_WEAPON_ITEMS row, the oils, stones and lures any
    class can use, shaped like a poison's entry: { key, row, ids, items,
    enchants, types, kind, itemLevel, zones, layer }. Picked per hand, not
    per class.
]]
local weaponItemEntries = {}
--[[
    Enchant id (what GetWeaponEnchantInfo reports) -> an entry that puts it
    on: its layer files an enchant on the weapon, and Diagnostics names it.
    Two items can share one (a Season of Discovery copy of Blessed Wizard
    Oil), so the window asks each pick's own enchants set which pick it is.
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
--[[
    The Soulstone (ns.BUFF_DUTY_SOULSTONE): its entry, and the buff the
    window offers when nobody in your group carries one. Both are replaced
    rather than refilled, so read them off BuffDuty at the time.
]]
BuffDuty.soulstoneEntry = nil
BuffDuty.soulstoneBuff = nil
-- The resurrection the Buff Key casts on a dead target, { id, name, ids }, or nil.
BuffDuty.resurrection = nil
--[[
    Seconds left under which a buff counts as missing; set from the
    account-wide Buff Duty settings each time BuffDuty.BuildSections runs.
]]
BuffDuty.refreshSeconds = 0
BuffDuty.isSetUp = false

--------------------------------------------------------------------------------
-- Castable Buffs
--------------------------------------------------------------------------------

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

local GetSpellSubtext = C_Spell.GetSpellSubtext

--[[
    What a macro types to cast exactly this rank: "Prayer of Fortitude(Rank 2)",
    or the bare name for a spell with no rank text.
]]
local function CastText(id, name)
	local subtext = GetSpellSubtext(id)
	return (subtext and subtext ~= "") and (name .. "(" .. subtext .. ")") or name
end
BuffDuty.CastText = CastText

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
BuffDuty.KnownRanks = KnownRanks

--[[
    Rebuilt at setup, on SPELLS_CHANGED (a new rank, or the group version at its
    level) and when a setting on the panel changes.
]]
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
					pets = entry.row.pets,
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
	    Your class's group buffs on yourself (Fortitude, Mark of the Wild, a
	    blessing): Self Buffs offers them, timed by the Self-Buffs panel, and
	    the party sections leave you out (Buff-Duty-Groups.lua), so Group
	    Buffs' "who" is for everyone else. Each casts its single-target rank on
	    you, and carries its group version so Has weighs your own Prayer of
	    Fortitude by the strength it landed with. Built before the Soulstone
	    and the self items, whose columns follow these.
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
					ranks = ranks,
					singleName = ranks[1].name,
					groupId = HighestKnown(entry.groupIds),
					refreshSeconds = when * 60,
					isGroupBuff = true,
				}
			end
		end
	end

	-- One per hand with anything ticked (Buff-Duty-Weapons.lua).
	BuffDuty.BuildWeaponBuffs(playerClass)

	--[[
	    Shaped like a self buff so Has can read it on anyone in the group: no
	    ranks of its own to weigh against theirs, only its auras. The button
	    makes a stone with the best Create Soulstone you know, cast by its bare
	    name -- Classic Era names each tier its own spell, and a "(Rank 1)"
	    added to one of those names a spell that doesn't exist.
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
				refreshSeconds = stoneWhen * 60,
			}
		end
	end

	--[[
	    Self items are for any class, after the Soulstone's column. Shaped like
	    the Soulstone: no ranks, only auras, so any version on you counts.
	]]
	wipe(selfItemBuffs)
	for _, entry in ipairs(selfItemEntries) do
		local when = selfRefresh[entry.key]
		if when and when ~= Data.SELF_REFRESH_OFF then
			selfItemBuffs[#selfItemBuffs + 1] = {
				column = #selfBuffs + 2 + #selfItemBuffs,
				key = entry.key,
				itemId = entry.itemId,
				wellFed = entry.wellFed,
				scrolls = entry.scrolls,
				auraIds = entry.auraIds,
				rankLevels = {},
				ranks = {},
				refreshSeconds = when * 60,
			}
		end
	end

	-- The Buff Key's resurrection (Buff-Duty-Resurrections.lua).
	BuffDuty.PickResurrection(playerClass)
end

-- Whether this character has anything at all the window could offer.
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
