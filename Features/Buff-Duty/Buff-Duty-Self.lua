local _, ns = ...
local L = ns.L

--[[
    The Buff Duty window's Self Buffs section, as icons on the Self Buffs
    header in a grid of its own: your self-only buffs; your class's group buffs
    on you, timed by the Self-Buffs panel and left off your party row; a
    Soulstone while nobody in your group carries one; and the consumables any
    class keeps up (Winterfall Firewater, buff food, scrolls) while one is in
    your bags. Then a row
    per hand for the poison, imbue, oil, stone or lure each weapon needs, each
    row in a grid of its own (Buff-Duty-Weapons.lua). Shared with the other
    Buff Duty files through ns.BuffDuty.
]]

local BuffDuty = ns.BuffDuty
local selfBuffs = BuffDuty.selfBuffs
local CanBuff = BuffDuty.CanBuff
local GroupMembers = BuffDuty.GroupMembers
local ReadAuras = BuffDuty.ReadAuras
local RoleOf = BuffDuty.RoleOf
local Has = BuffDuty.Has
local SingleIcon = BuffDuty.SingleIcon

local GetItemCount = C_Item.GetItemCount
local IsItemInRange = C_Item.IsItemInRange

--------------------------------------------------------------------------------
-- Self Buffs
--------------------------------------------------------------------------------

local function HasPet()
	return UnitExists("pet") and not UnitIsDeadOrGhost("pet")
end

--------------------------------------------------------------------------------
-- Soulstone
--------------------------------------------------------------------------------

-- The best stone in your bags; BuffDuty.BuildLookup sorts the list lowest level first.
local function BestStone(items)
	for index = #items, 1, -1 do
		if GetItemCount(items[index]) > 0 then
			return items[index]
		end
	end
	return nil
end

-- A unit the client can't answer for counts as in range, as in IsBuffInRange.
local function StoneInRange(itemId, unit)
	local inRange = IsItemInRange(itemId, unit)
	return not ns.IsPlain(inRange) or inRange ~= false
end

--[[
    Nothing while anyone in your group carries a Soulstone, yours or another
    warlock's. Otherwise the stone in your bags goes on a healer, one in range
    if any is, or on you when the group has none (or you have no group). With
    no stone in your bags, the button makes one. A stone running low on
    someone shows its time left on the icon.
]]
local function SoulstoneIcon()
	local buff = BuffDuty.soulstoneBuff
	if not buff then
		return nil
	end
	local healers = {}
	local lowExpires, lowDuration
	for _, member in ipairs(GroupMembers()) do
		local unit = member.unit
		if CanBuff(unit) then
			ReadAuras(unit)
			local has, expires, duration = Has(buff, unit)
			if has then
				return nil
			end
			if expires and (not lowExpires or expires > lowExpires) then
				lowExpires, lowDuration = expires, duration
			end
			if RoleOf(unit) == "HEALER" then
				healers[#healers + 1] = unit
			end
		end
	end

	local itemId = BestStone(buff.items)
	-- The Buff Key casts this one on purpose, making a stone when none exists; only using one is left to its icon (hasCooldown below).
	if not itemId then
		return BuffDuty.WithTimeLeft({
			spellId = buff.create.id,
			column = buff.column,
			spellName = buff.create.name,
			castSpell = buff.create.name,
			unit = "player",
			targetName = GetUnitName("player", false) or "",
			hint = L["BUFF_DUTY_TOOLTIP_CREATE"],
		}, lowExpires, lowDuration)
	end
	local target = "player"
	for _, unit in ipairs(healers) do
		if StoneInRange(itemId, unit) then
			target = unit
			break
		end
	end
	if target == "player" and healers[1] then
		target = healers[1]
	end
	local targetName = GetUnitName(target, false) or ""
	return BuffDuty.WithTimeLeft({
		itemId = itemId,
		item = "item:" .. itemId,
		-- Every stone shares a long cooldown, so the Buff Key leaves this one to its icon.
		hasCooldown = true,
		column = buff.column,
		unit = target,
		targetName = targetName,
		hint = L["BUFF_DUTY_TOOLTIP_USE"]:format(targetName),
	}, lowExpires, lowDuration)
end

--------------------------------------------------------------------------------
-- Self Items
--------------------------------------------------------------------------------

--[[
    A consumable any class keeps up on itself (Winterfall Firewater): offered
    while one is in your bags and its buff is missing or running low, by your
    own time for it. Any version on you counts, whoever's it is.
]]
local function SelfItemIcon(buff)
	if GetItemCount(buff.itemId) == 0 then
		return nil
	end
	local has, expires, duration = Has(buff, "player")
	if has then
		return nil
	end
	return BuffDuty.WithTimeLeft({
		itemId = buff.itemId,
		item = "item:" .. buff.itemId,
		selfItem = true,
		column = buff.column,
		unit = "player",
		targetName = GetUnitName("player", false) or "",
		hint = L["BUFF_DUTY_TOOLTIP_USE_ITEM"],
	}, expires, duration)
end

--[[
    Eating or drinking: the aura a meal or a drink puts on you while you sit.
    Matched by name, since every food and drink has an aura id of its own:
    the generic Food and Drink nearly all of them show, and the buff food's
    own spell (by id and name) for one whose aura is named for itself.
]]
local function EatingMatcher()
	local names = {}
	for _, id in ipairs({ ns.FOOD_SPELL_ID, ns.DRINK_SPELL_ID }) do
		local name = C_Spell.GetSpellName(id)
		if ns.IsPlain(name) and name then
			names[name] = true
		end
	end
	local foodSpellId
	local itemId = ns.bestBuffFoodID
	if itemId then
		local name, id = C_Item.GetItemSpell(itemId)
		if ns.IsPlain(name) and name then
			names[name] = true
		end
		foodSpellId = ns.IsPlain(id) and id or nil
	end
	return function(aura)
		local spellId, name = aura.spellId, aura.name
		return (foodSpellId and spellId == foodSpellId) or (ns.IsPlain(name) and name and names[name]) or false
	end
end

--[[
    Whether you're eating or drinking right now; nil when your auras can't be
    read (secret on WoW Forever, in combat). The Buff Key does nothing while
    you are (Buff-Duty-Keys.lua): another press would start the meal over,
    or stand you up for a cast.
]]
function BuffDuty.IsEating()
	if ns.AreAurasSecret() then
		return nil
	end
	local IsEatingAura = EatingMatcher()
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not aura then
			return false
		end
		if not ns.IsPlain(aura.spellId) then
			return nil
		end
		if IsEatingAura(aura) then
			return true
		end
	end
	return false
end

--[[
    Well Fed's time left on you: the longest Well Fed aura, matched by spell
    id or, for a food the tables don't list, by its icon, as the Food macro
    matches it (Scanner-Auras.lua). Returns had, expires, duration, eating;
    had is nil when an aura can't be read (secret on WoW Forever), so the
    window doesn't nag about a buff that may be there. eating is true while
    you're eating or drinking (EatingMatcher), before Well Fed lands.
]]
local function WellFedAura()
	local had, expires, duration, eating = false, nil, nil, false
	local IsEatingAura = EatingMatcher()
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not aura then
			break
		end
		local spellId, icon = aura.spellId, aura.icon
		if not (ns.IsPlain(spellId) and ns.IsPlain(icon)) then
			return nil
		end
		if IsEatingAura(aura) then
			eating = true
		end
		if ns.WELL_FED_BUFF_IDS[spellId] or ns.WELL_FED_ICON_IDS[icon] then
			local auraExpires = ns.IsPlain(aura.expirationTime) and aura.expirationTime or 0
			if not had or auraExpires == 0 or (expires ~= 0 and auraExpires > expires) then
				expires = auraExpires
				duration = ns.IsPlain(aura.duration) and aura.duration or 0
			end
			had = true
		end
	end
	return had, expires, duration, eating
end

--[[
    Well Fed: offered while it's missing or running low, by your own time for
    it, with the buff food the Food macro would eat. It uses that item, so
    the Ignore List and the arena already keep it out (ns.bestBuffFoodID).
    Nothing while you're eating it: Well Fed lands when the meal ends, and
    another bite would only spend a second one. The Buff Key eats it too,
    last of all (wellFed, Buff-Duty-Key-Picker.lua).
]]
local function WellFedIcon(buff)
	local itemId = ns.bestBuffFoodID
	if not itemId or GetItemCount(itemId) == 0 then
		return nil
	end
	local had, expires, duration, eating = WellFedAura()
	if had == nil or eating then
		return nil
	end
	if had then
		local threshold = buff.refreshSeconds
		if expires == 0 or duration <= threshold or expires - GetTime() >= threshold then
			return nil
		end
	else
		expires, duration = nil, nil
	end
	return BuffDuty.WithTimeLeft({
		itemId = itemId,
		item = "item:" .. itemId,
		selfItem = true,
		column = buff.column,
		unit = "player",
		targetName = GetUnitName("player", false) or "",
		wellFed = true,
		hint = L["BUFF_DUTY_TOOLTIP_EAT"],
	}, expires, duration)
end

--[[
    Bag counts read live, in the shape ns.FindBestScroll takes, so a scroll
    just looted or read counts on the next redraw (BAG_UPDATE_DELAYED asks
    for one) without waiting on the macros' bag scan.
]]
local liveItemCounts = setmetatable({}, {
	__index = function(_, itemId)
		return GetItemCount(itemId)
	end,
})

--[[
    Scrolls: an icon per scroll type you carry and lack the buff of, or have
    it running low by your own time for Scrolls, in the Food macro's order
    (ns.SCROLL_CHECK_ORDER). Only the types Buff Duty's Self-Buffs page ticks count,
    by default the ones your class gets use from. Each reads the strongest
    scroll of its type in your bags (ns.FindBestScroll, which keeps to the
    Ignore List), and a stronger elixir or class buff already on you covers
    its type, as it does for the macro. Nothing while auras can't be read
    (WoW Forever), as with Well Fed. The icons share Scrolls' column, a
    tenth apart, so the grid keeps them together and in order.
]]
local function AddScrollIcons(buff, icons)
	local types = ns.db.profile.scrollTypes
	if not types or ns.AreAurasSecret() then
		return
	end
	local snapshot = ns.GetPlayerBuffSnapshot()
	local now = GetTime()
	local name = GetUnitName("player", false) or ""
	for index, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local itemId, amount
		if types[scrollType] then
			itemId, amount = ns.FindBestScroll(scrollType, liveItemCounts)
		end
		local aura = itemId and snapshot.scrolls[scrollType]
		local covered = aura and aura.conflictAmount and aura.conflictAmount >= (amount or 0)
		local expires = aura and aura.expiration
		if aura and not covered and (expires == nil or (expires ~= 0 and expires - now < buff.refreshSeconds)) then
			icons[#icons + 1] = {
				itemId = itemId,
				item = "item:" .. itemId,
				selfItem = true,
				column = buff.column + index / 10,
				unit = "player",
				targetName = name,
				scroll = true,
				hint = L["BUFF_DUTY_TOOLTIP_READ"],
			}
		end
	end
end

--[[
    Bloodrage first, as a warlock's Soulstone icon conjures the stone it
    lacks: a warrior without the rage for a self buff that costs it (Battle
    Shout) has its icon cast Bloodrage, then the buff, from one macro. The
    rage often isn't there yet for the buff's line on that same press, so
    the next press casts it; Bloodrage on its cooldown by then just errors
    and the buff still goes off. Read when the window draws and at each Buff
    Key press; while Bloodrage is on its own cooldown, the icon casts the
    buff alone.
]]

local function RageCost(spellId)
	local costs = spellId and C_Spell.GetSpellPowerCost(spellId)
	if type(costs) ~= "table" then
		return nil
	end
	for _, cost in ipairs(costs) do
		if ns.IsPlain(cost.type) and cost.type == Enum.PowerType.Rage and ns.IsPlain(cost.cost) then
			return cost.cost
		end
	end
	return nil
end

--[[
    Short on rage for it: the client's own answer first (usable false,
    noMana true, as the Buff Key reads it), then the spell's rage cost
    against your rage, for a client that leaves either unread.
]]
local function ShortOnRage(spellId)
	local usable, noMana = C_Spell.IsSpellUsable(spellId)
	if ns.IsPlain(usable) and ns.IsPlain(noMana) and noMana and not usable then
		return RageCost(spellId) ~= nil or UnitPowerType("player") == Enum.PowerType.Rage
	end
	local cost = RageCost(spellId)
	local rage = UnitPower("player", Enum.PowerType.Rage)
	return cost ~= nil and cost > 0 and ns.IsPlain(rage) and rage < cost
end

-- A client without Bloodrage leaves its ID out, which reads as never known.
local function KnowsBloodrage()
	return ns.BLOODRAGE_SPELL_ID ~= nil and ns.IsPlayerSpell(ns.BLOODRAGE_SPELL_ID)
end

-- Whether a press should Bloodrage first: short on rage for the spell, with Bloodrage known and off its own cooldown.
local function NeedsRageFirst(spellId)
	if not KnowsBloodrage() or not ShortOnRage(spellId) then
		return false
	end
	if ns.AreCooldownsSecret() then
		return false
	end
	local info = C_Spell.GetSpellCooldown(ns.BLOODRAGE_SPELL_ID)
	local start, duration = info and info.startTime, info and info.duration
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return true
	end
	return start + duration <= BuffDuty.GlobalCooldownEnd()
end

--[[
    Spell id -> the NeedsRageFirst answer the window drew each rage-costing
    self buff's icon with. The window isn't redrawn on rage alone, so rage
    decaying after a fight, or Bloodrage coming off its cooldown, asks for a
    redraw only when one of these answers would change
    (BuffDuty.CheckRageFirst).
]]
local rageFirstDrawn = {}

function BuffDuty.CheckRageFirst()
	for spellId, drawn in pairs(rageFirstDrawn) do
		if NeedsRageFirst(spellId) ~= drawn then
			ns.RequestBuffDutyRefresh()
			return
		end
	end
end

local function WithRageFirst(spec)
	if not spec or spec.macrotext or not KnowsBloodrage() then
		return spec
	end
	if not RageCost(spec.spellId) and UnitPowerType("player") ~= Enum.PowerType.Rage then
		return spec
	end
	local needs = NeedsRageFirst(spec.spellId)
	rageFirstDrawn[spec.spellId] = needs
	local bloodrage = needs and C_Spell.GetSpellName(ns.BLOODRAGE_SPELL_ID)
	if not bloodrage then
		return spec
	end
	spec.macrotext = "/cast " .. bloodrage .. "\n/cast " .. (spec.castSpell or spec.spellName)
	spec.rageFirst = true
	return spec
end

--------------------------------------------------------------------------------
-- Section
--------------------------------------------------------------------------------

--[[
    Each self buff casts your highest rank on yourself. A family you keep one
    of (an armor, an aura, an aspect, a shield) asks for nothing while any one
    of yours is up -- Has handles that, as it does for blessings. Soul Link
    waits for a demon to link to. The weapons have their own switch
    (weaponBuffs is empty while it's off) and show as rows under the same
    header, which stands even with no self buff of its own to offer.
]]
function BuffDuty.AddSelfSection(sections)
	if UnitIsDeadOrGhost("player") then
		return
	end
	local selfEnabled = ns.db.global.buffWindow.selfEnabled
	local icons, rows = {}, {}

	ReadAuras("player")
	wipe(rageFirstDrawn)
	local name = GetUnitName("player", false) or ""
	for _, buff in ipairs(selfEnabled and selfBuffs or {}) do
		if HasPet() or not buff.needsPet then
			local has, expires, duration = Has(buff, "player")
			if not has then
				local icon =
					BuffDuty.WithTimeLeft(WithRageFirst(SingleIcon(buff, "player", "player", name)), expires, duration)
				if icon then
					icon.castLast = buff.castLast
				end
				icons[#icons + 1] = icon
			end
		end
	end

	BuffDuty.AddWeaponRows(rows)

	if selfEnabled then
		icons[#icons + 1] = SoulstoneIcon()
		-- SoulstoneIcon reads the group's auras: read yours again.
		ReadAuras("player")
		for _, buff in ipairs(BuffDuty.selfItemBuffs) do
			if buff.wellFed then
				icons[#icons + 1] = WellFedIcon(buff)
			elseif buff.scrolls then
				AddScrollIcons(buff, icons)
			else
				icons[#icons + 1] = SelfItemIcon(buff)
			end
		end
	end

	if #icons > 0 or #rows > 0 then
		sections[#sections + 1] =
			{ kind = "self", label = L["BUFF_DUTY_SELF_HEADER"], icons = icons, rows = rows, grid = "self" }
	end
end
