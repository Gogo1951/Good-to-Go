local _, ns = ...

--[[
    Readiness-Report-Probes -- the live reads behind the Readiness Report's
    lines: who is in the group and whether a soulstone is up, what is about to
    lapse, what the weapons are carrying, what the character is wearing and
    specced into.

    Every function here answers about the player or the group right now and
    nothing else. No state, no settings: which of these the report asks for is
    Readiness-Report.lua's business, and each of these only has to answer
    honestly when asked.
]]

--------------------------------------------------------------------------------
-- Group
--------------------------------------------------------------------------------

--[[
    Walks every group member, the player included. Raid unit ids already cover
    the player, party ids do not, so the player is tested up front and the loop
    length differs between the two.
]]
local function AnyGroupMember(test)
	if test("player") then
		return true
	end

	local members = GetNumGroupMembers() or 0
	local inRaid = IsInRaid()
	local prefix = inRaid and "raid" or "party"
	local count = inRaid and members or (members - 1)

	for index = 1, count do
		if test(prefix .. index) then
			return true
		end
	end

	return false
end

--[[
    Whether anyone present is of a class, the player included -- AnyGroupMember
    tests "player" first, so "in the group" always covers "is you".

    A Warlock is who produces a Healthstone, so with none present that entry
    is not actionable.
]]
function ns.GroupHasClass(classToken)
	return AnyGroupMember(function(unit)
		return select(2, UnitClass(unit)) == classToken
	end)
end

--[[
    The same, for the player's own party only: in a raid the party ids are the
    player's own subgroup. A Shaman's Windfury Totem reaches only that party,
    which is what makes the Main Hand line moot; see its caller in
    Readiness-Report.lua.
]]
function ns.PartyHasClass(classToken)
	if select(2, UnitClass("player")) == classToken then
		return true
	end
	for index = 1, 4 do
		local unit = "party" .. index
		if UnitExists(unit) and select(2, UnitClass(unit)) == classToken then
			return true
		end
	end
	return false
end

local SOULSTONE_BUFF_LOOKUP = {}
for _, spellID in ipairs(ns.SOULSTONE_BUFF_SPELL_IDS) do
	SOULSTONE_BUFF_LOOKUP[spellID] = true
end

local function UnitHasSoulstone(unit)
	if not UnitExists(unit) then
		return false
	end

	for index = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex(unit, index, "HELPFUL")
		if not aura then
			return false
		end
		if SOULSTONE_BUFF_LOOKUP[aura.spellId] then
			return true
		end
	end

	return false
end

--[[
    Whether a soulstone is UP on anyone in the group, which is the only thing a
    raid actually cares about. Deliberately NOT "does someone hold a stone":
    seven unused stones in seven bags resurrect nobody, and one deployed on the
    healer covers the pull.

    LIMITATION: the aura APIs only answer for members the client can see.
    Someone in another room or out of range reports no auras at all, so a stone
    on them reads as absent. That makes the failure a false "missing", never a
    false "all clear" -- and at a ready check the group is normally stacked up
    for the pull, which is the one moment this runs.
]]
function ns.GroupHasSoulstone()
	return AnyGroupMember(UnitHasSoulstone)
end

--[[
    Whether the stones' shared use cooldown is running, which is when no stone
    can go up however many the Warlock carries: after a stoned player rose, for
    the rest of the half hour since the stone was used. The stones share the
    one cooldown, so any of them on it answers. A cooldown the client keeps
    secret (Forever) counts as over, and the entry reports as it always has.
]]
function ns.SoulstonesOnCooldown()
	if ns.AreCooldownsSecret() then
		return false
	end
	for itemID in pairs(ns.SOULSTONES) do
		local _, duration = C_Container.GetItemCooldown(itemID)
		-- A stone on the global cooldown alone reads as on cooldown too: close enough, as it is ready by the next check.
		if duration and duration > 0 then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Expiring Buffs
--------------------------------------------------------------------------------

--[[
    Every helpful aura on the player with less than `threshold` seconds left,
    soonest first.

    Deliberately EVERY aura rather than the ones the add-on tracks. The rest of
    the report answers "did you bring it"; this one answers "is anything about
    to fall off", and a raid buff someone else cast is exactly as worth catching
    as your own food. Auras carrying no duration (expirationTime 0) never
    expire, so they are skipped rather than reported as expiring in a moment.
    So is an aura whose whole duration is at or under the threshold (a
    two-minute shout, a drink): it is always under it, so it would be named on
    every ready check.
]]
function ns.GetExpiringBuffs(threshold)
	local expiring = {}
	local now = GetTime()

	for index = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", index, "HELPFUL")
		if not aura then
			break
		end
		local expiration = aura.expirationTime or 0
		if expiration > 0 and (aura.duration or 0) > threshold then
			local remaining = expiration - now
			if remaining > 0 and remaining < threshold then
				expiring[#expiring + 1] = { name = aura.name, remaining = remaining }
			end
		end
	end

	table.sort(expiring, function(a, b)
		if a.remaining ~= b.remaining then
			return a.remaining < b.remaining
		end
		-- Never-equal tiebreak, so two auras sharing a tick do not reorder between reports.
		return a.name < b.name
	end)

	return expiring
end

--------------------------------------------------------------------------------
-- Flask and Elixirs
--------------------------------------------------------------------------------

--[[
    Covered means a flask, or two DIFFERENT elixirs. Counting distinct auras is
    the whole test: the client only lets one battle and one guardian elixir sit
    on a character at once, so two elixir auras are already one of each and
    nothing here needs to know which kind either one is (see Data/{Game}/Elixirs-{Game}.lua).
    The zone-limited flask and elixir auras (the Unstable and Shattrath flasks,
    and Bloodberry) count everywhere: they persist outside their zones, and
    the check errs toward silence.

    Returns true when either data table is empty, so the check reads as
    "nothing to report": an empty table cannot tell a flasked player from an
    unflasked one, and of the two silences that is the right one.
]]
function ns.HasFlaskOrElixirs()
	--[[
	    Both halves are needed for a verdict, so an empty table on either side
	    answers "covered" and the line stays silent. Flasks alone would call a
	    doubly-elixired player unflasked, which is the false alarm that gets a
	    switch turned off for good.
	]]
	if next(ns.FLASK_BUFF_IDS) == nil or next(ns.ELIXIR_BUFF_IDS) == nil then
		return true
	end

	local elixirs = 0
	local seen = {}

	for index = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", index, "HELPFUL")
		if not aura then
			break
		end
		local spellID = aura.spellId
		if ns.FLASK_BUFF_IDS[spellID] then
			return true
		end
		-- Distinct ids only: one elixir reported twice must never read as two.
		if ns.ELIXIR_BUFF_IDS[spellID] and not seen[spellID] then
			seen[spellID] = true
			elixirs = elixirs + 1
			if elixirs >= 2 then
				return true
			end
		end
	end

	return false
end

--------------------------------------------------------------------------------
-- Weapon Buffs
--------------------------------------------------------------------------------

--[[
    Only these two off-hand kinds can carry a temporary enchant. A shield or a
    held-in-off-hand item takes none, so an empty off hand and a shield are the
    same answer here: there is nothing to report missing.
]]
local ENCHANTABLE_OFF_HAND = {
	INVTYPE_WEAPON = true,
	INVTYPE_WEAPONOFFHAND = true,
}

local MAIN_HAND_SLOT = 16
local OFF_HAND_SLOT = 17

local function SlotHoldsEnchantableOffHand()
	local link = GetInventoryItemLink("player", OFF_HAND_SLOT)
	if not link then
		return false
	end
	local _, _, _, equipLoc = C_Item.GetItemInfoInstant(link)
	return ENCHANTABLE_OFF_HAND[equipLoc] == true
end

--[[
    How many temporary enchants a hand should carry. One, of any kind, on
    every client but WoW Forever. There (ns.WEAPON_ENCHANTS_STACK) a hand
    your class keeps a poison or imbue on (ns.BUFF_DUTY_WEAPON_HANDS: a
    Rogue's two, a Shaman's main hand) wants two once you're level for one,
    that beside an oil or stone. Counted rather than sorted by kind, so it
    holds whatever the client calls a poison.
]]
local function EnchantsWanted(hand)
	if not ns.WEAPON_ENCHANTS_STACK then
		return 1
	end
	local _, class = UnitClass("player")
	local level = UnitLevel("player")
	if not (ns.IsPlain(level) and level) or not tContains(ns.BUFF_DUTY_WEAPON_HANDS[class] or {}, hand) then
		return 1
	end
	for _, row in ipairs(ns.BUFF_DUTY_WEAPON_ENCHANTS) do
		if row.class == class then
			for _, use in ipairs(row.items or row.ranks) do
				if use[2] <= level then
					return 2
				end
			end
		end
	end
	return 1
end

--[[
    Whether each weapon slot wants a buff and is missing one, as
    (mainHandMissing, offHandMissing).

    Buff Duty's reader answers for both slots at once, each a list of the
    enchants it carries, and needs no buff data; the off hand's equip slot
    comes from C_Item.GetItemInfoInstant, which never waits on the item
    cache. A slot with no weapon in it is never missing anything -- that is
    what makes a two-hander read correctly with no two-hand special case,
    since its off hand is empty by definition.
]]
function ns.GetMissingWeaponBuffs()
	local worn = ns.BuffDuty.ReadWeaponEnchants()

	local mainHandMissing = (GetInventoryItemLink("player", MAIN_HAND_SLOT) ~= nil)
		and #worn[MAIN_HAND_SLOT] < EnchantsWanted("MAIN")
	local offHandMissing = SlotHoldsEnchantableOffHand() and #worn[OFF_HAND_SLOT] < EnchantsWanted("OFF")

	return mainHandMissing, offHandMissing
end

--------------------------------------------------------------------------------
-- Gear
--------------------------------------------------------------------------------

--[[
    Every equipped item below `percent` durability, as item links, in slot order.

    Walked by slot rather than by a list of which slots have durability:
    GetInventoryItemDurability answers nil for a slot holding nothing and for an
    item that cannot be damaged, so rings, trinkets and the tabard filter
    themselves out and no table has to stay in step with the client.
]]
local LAST_EQUIPMENT_SLOT = 19

function ns.GetDamagedGear(percent)
	local damaged = {}

	for slot = 1, LAST_EQUIPMENT_SLOT do
		local current, maximum = GetInventoryItemDurability(slot)
		if current and maximum and maximum > 0 and (current / maximum) * 100 < percent then
			local link = GetInventoryItemLink("player", slot)
			if link then
				damaged[#damaged + 1] = link
			end
		end
	end

	return damaged
end

-- The first item worn, in slot order: the Readiness Report panel's Example names it as the damaged gear.
function ns.FirstEquippedLink()
	for slot = 1, LAST_EQUIPMENT_SLOT do
		local link = GetInventoryItemLink("player", slot)
		if link then
			return link
		end
	end
end

--[[
    Two weapon subclasses are non-combat gear in their entirety, so the check
    reads them off the item rather than off a list: nothing in either belongs in
    a fight, no table has to be kept in step with the client, and a pole added
    in a later patch is covered the day it ships.

    Read as the numeric class and subclass from C_Item.GetItemInfoInstant, never as type NAMES,
    which are localized -- matching on "Fishing Pole" would answer correctly in
    English and nowhere else.
]]
local WEAPON_CLASS_ID = 2
local NON_COMBAT_WEAPON_SUBCLASSES = {
	-- Mining picks, blacksmith hammers, skinning knives, the tournament lances.
	[14] = true,
	[20] = true, -- Fishing poles, every one of them
}

--[[
    Equipped items that do not belong in a fight, as item links, in slot order.
    Two ways in: the subclass rule above, and ns.QUESTIONABLE_EQUIPMENT for the
    exceptions it cannot reach -- a Riding Crop shares its subclass with every
    real trinket, so only a hand-kept list of item IDs can tell them apart.
]]
function ns.GetQuestionableEquipment()
	local wrong = {}

	for slot = 1, LAST_EQUIPMENT_SLOT do
		local link = GetInventoryItemLink("player", slot)
		if link then
			local itemID = tonumber(link:match("item:(%d+)"))
			local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(link)

			local byRule = classID == WEAPON_CLASS_ID and NON_COMBAT_WEAPON_SUBCLASSES[subclassID] == true
			local byList = itemID ~= nil and ns.QUESTIONABLE_EQUIPMENT[itemID] == true

			if byRule or byList then
				wrong[#wrong + 1] = link
			end
		end
	end

	return wrong
end

--------------------------------------------------------------------------------
-- Character
--------------------------------------------------------------------------------

--[[
    The character's talent spread as "Fury (0/31/20)", named for whichever tree
    holds the most points. Ties fall to the earlier tree, which is the same
    order the talent frame draws them in.

    Returns nil before the talent data is available, which is normal early in a
    login -- the caller drops the line rather than printing a half-answer. Always
    nil on Forever, whose Retail-style talents have no GetNumTalentTabs.

    From MoP on there are no points in trees: the character picks one
    specialization, so the label is its name alone.
]]
function ns.GetCurrentSpecializationLabel()
	if ns.EXPANSION >= 5 then
		local index = C_SpecializationInfo.GetSpecialization()
		return index and select(2, C_SpecializationInfo.GetSpecializationInfo(index)) or nil
	end

	local tabs = ns.GetNumTalentTabs()
	if not tabs or tabs == 0 then
		return nil
	end

	local best, bestPoints, spread = nil, -1, {}

	for index = 1, tabs do
		local _, name, _, _, _, _, pointsSpent = C_SpecializationInfo.GetSpecializationInfo(index)
		pointsSpent = pointsSpent or 0
		spread[#spread + 1] = pointsSpent
		if pointsSpent > bestPoints then
			best, bestPoints = name, pointsSpent
		end
	end

	if not best or bestPoints <= 0 then
		return nil
	end

	return string.format(ns.L["READINESS_SPECIALIZATION_FORMAT"], best, table.concat(spread, "/"))
end

--[[
    Whether ns.GetCurrentSpecializationLabel can ever answer on this client: the
    classic talent trees, or the specializations of MoP and later. Never on
    Forever, whose talents are Retail's.
]]
function ns.CanReportSpecialization()
	return ns.GetNumTalentTabs() ~= nil or ns.EXPANSION >= 5
end

--[[
    Talent points the character has not spent, or nil when there are none to
    spend. Forever has no UnitCharacterPoints, so the line never shows there.
]]
function ns.GetUnspentTalentPoints()
	local unspent = ns.UnitCharacterPoints("player") or 0
	if unspent <= 0 then
		return nil
	end
	return unspent
end

function ns.IsPvPFlagged()
	return UnitIsPVP("player") and true or false
end

--[[
    Whether this character has a mana bar worth reporting a Mana Potion for.
    A static class set rather than UnitPowerType, which answers for the CURRENT
    form -- a druid in cat form reads as energy and would drop the line for
    exactly the character most likely to want it. Hunters count only before
    Cataclysm, which moved them to Focus.
]]
local MANA_CLASSES = {
	DRUID = true,
	HUNTER = true,
	MAGE = true,
	PALADIN = true,
	PRIEST = true,
	SHAMAN = true,
	WARLOCK = true,
}

function ns.PlayerUsesMana()
	local _, classToken = UnitClass("player")
	if classToken == "HUNTER" and ns.EXPANSION >= 4 then
		return false
	end
	return MANA_CLASSES[classToken] == true
end
