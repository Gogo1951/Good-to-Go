local _, ns = ...

-- Live reads only: no state, no settings.

--------------------------------------------------------------------------------
-- Group
--------------------------------------------------------------------------------

-- Raid ids cover the player and party ids don't, hence the player up front and the two loop lengths.
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

function ns.GroupHasClass(classToken)
	return AnyGroupMember(function(unit)
		return select(2, UnitClass(unit)) == classToken
	end)
end

-- In a raid the party ids are the player's own subgroup.
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
    UP on anyone, not held: stones in bags resurrect nobody. Out-of-range
    members report no auras, so the failure is a false "missing", never a
    false all-clear; at a ready check the group is usually stacked.
]]
function ns.GroupHasSoulstone()
	return AnyGroupMember(UnitHasSoulstone)
end

-- The stones share one cooldown, so any answers. A secret cooldown (Forever) counts as over.
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
    EVERY helpful aura, not only tracked ones: a raid buff someone else cast is
    as worth catching as your own food. An aura whose whole duration is at or
    under the threshold (a shout, a drink) is skipped, or every check would name it.
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
		return a.name < b.name
	end)

	return expiring
end

--------------------------------------------------------------------------------
-- Flask and Elixirs
--------------------------------------------------------------------------------

--[[
    A flask, or two DIFFERENT elixirs: only one battle and one guardian elixir
    can sit at once, so two are already one of each. Zone-limited auras count
    everywhere: they persist outside their zones, and the check errs toward silence.
]]
function ns.HasFlaskOrElixirs()
	-- Either table empty answers "covered": flasks alone would call a doubly-elixired player unflasked.
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

-- A shield or held-in-off-hand item takes no temporary enchant.
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
    Where enchants stack (Forever), a poison or imbue hand wants two once in
    level: that beside an oil or stone. Counted, not sorted by kind, so it holds
    whatever the client calls a poison.
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

-- An empty slot is never missing anything, which covers a two-hander with no special case.
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

-- Every slot: durability is nil for empty slots and undamageable items, so no slot list to keep in step.
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

-- The panel's Example names it as the damaged gear.
function ns.FirstEquippedLink()
	for slot = 1, LAST_EQUIPMENT_SLOT do
		local link = GetInventoryItemLink("player", slot)
		if link then
			return link
		end
	end
end

-- Numeric ids, never type names, which are localized.
local WEAPON_CLASS_ID = 2
local NON_COMBAT_WEAPON_SUBCLASSES = {
	-- Mining picks, blacksmith hammers, skinning knives, the tournament lances.
	[14] = true,
	[20] = true, -- Fishing poles, every one of them
}

-- The list is for what the rule can't reach: a Riding Crop shares its subclass with every real trinket.
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
    "Fury (0/31/20)"; from MoP on, the specialization's name alone. Nil before
    talent data loads, normal early in a login. Always nil on Forever, which has
    no GetNumTalentTabs.
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

	return string.format(ns.L["NAME_WITH_DETAIL_FORMAT"], best, table.concat(spread, "/"))
end

function ns.CanReportSpecialization()
	return ns.GetNumTalentTabs() ~= nil or ns.EXPANSION >= 5
end

-- Forever has no UnitCharacterPoints, so the line never shows there.
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
    A class set, not UnitPowerType, which answers for the current form: a druid
    in cat form reads as energy. Hunters only before Cataclysm moved them to Focus.
]]
local MANA_CLASSES = {
	DRUID = true,
	HUNTER = true,
	MAGE = true,
	MONK = true,
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
