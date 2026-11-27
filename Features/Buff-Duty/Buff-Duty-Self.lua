local _, ns = ...
local L = ns.L

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

-- BuffDuty.BuildLookup sorts the list lowest level first.
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

-- Any version on you counts, whoever's it is.
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

--------------------------------------------------------------------------------
-- Missing Inventory
--------------------------------------------------------------------------------

-- No while auras can't be read, so the line never claims a buff is gone that may be there.
local function OtherMissing(buff)
	if ns.AreAurasSecret() or GetItemCount(buff.itemId) > 0 then
		return false
	end
	return not Has(buff, "player")
end

--------------------------------------------------------------------------------
-- Section
--------------------------------------------------------------------------------

-- The Buff Key reads dutyRow for Use with Cast Next Buff; untagged, a category kept off the key still gets pressed.
local function TagRow(list, row)
	for _, spec in ipairs(list) do
		spec.dutyRow = row
	end
	return list
end

--[[
    Self-Buffs keeps a line per type under its heading, as Weapon Buffs keeps
    one per hand, each type with its own settings (BuffDuty.SelfTypeRow).
]]
local function SelfTypeRows(byType)
	local rows = {}
	for selfType, icons in pairs(byType) do
		local row = BuffDuty.SelfTypeRow(selfType)
		rows[#rows + 1] = {
			id = selfType,
			name = BuffDuty.SelfTypeName(selfType),
			label = BuffDuty.SelfTypeName(selfType),
			icons = TagRow(icons, row),
			grid = "self_type_" .. selfType,
			indent = 0,
			menu = "self:" .. selfType,
			selfType = selfType,
		}
	end
	table.sort(rows, BuffDuty.ByTypeName)
	return rows
end

--[[
    Every category is a "self" section, so the window packs its icons in the
    Buff Key's order. A family you keep one of (an armor, an aspect) asks for
    nothing while any one of yours is up: Has handles that.
]]
function BuffDuty.AddSelfSection(sections)
	if UnitIsDeadOrGhost("player") then
		return
	end
	local selfEnabled = BuffDuty.RowOn("self")
	local byType = {}
	local function Place(selfType, icon)
		if icon and BuffDuty.RowShows(BuffDuty.SelfTypeRow(selfType)) then
			byType[selfType] = byType[selfType] or {}
			table.insert(byType[selfType], icon)
		end
	end

	ReadAuras("player")
	BuffDuty.ForgetRageFirst()
	local name = GetUnitName("player", false) or ""
	for _, buff in ipairs(selfEnabled and selfBuffs or {}) do
		if (HasPet() or not buff.needsPet) and BuffDuty.RowShows(BuffDuty.SelfTypeRow(buff.selfType)) then
			local has, expires, duration = Has(buff, "player")
			if not has then
				local icon = BuffDuty.WithTimeLeft(
					BuffDuty.WithRageFirst(SingleIcon(buff, "player", "player", name)),
					expires,
					duration
				)
				if icon then
					icon.castLast = buff.castLast
					icon.party = buff.party
				end
				Place(buff.selfType, icon)
			end
		end
	end
	local stone = BuffDuty.soulstoneBuff
	if selfEnabled and stone and BuffDuty.RowShows(BuffDuty.SelfTypeRow(stone.selfType)) then
		Place(stone.selfType, SoulstoneIcon())
		-- SoulstoneIcon reads the group's auras: read yours again.
		ReadAuras("player")
	end

	local food, scrolls, elixirs, other, weapons = {}, {}, {}, {}, {}
	local missing = {}
	if BuffDuty.RowShows("weapons") then
		BuffDuty.AddWeaponRows(weapons)
	end
	for _, buff in ipairs(BuffDuty.selfItemBuffs) do
		if buff.wellFed then
			if BuffDuty.RowShows("food") then
				food[#food + 1] = BuffDuty.WellFedIcon(buff)
				missing.food = BuffDuty.RowOut("food") and not food[1] and BuffDuty.FoodMissing()
			end
		elseif buff.scrolls then
			if BuffDuty.RowShows("scrolls") then
				BuffDuty.AddScrollIcons(buff, scrolls)
				missing.scrolls = BuffDuty.RowOut("scrolls") and BuffDuty.ScrollsMissing()
			end
		elseif buff.elixirs then
			if BuffDuty.RowShows("elixirs") then
				BuffDuty.AddElixirIcons(buff, elixirs)
				missing.elixirs = BuffDuty.RowOut("elixirs") and not elixirs[1] and BuffDuty.ElixirsMissing()
			end
		elseif BuffDuty.RowShows("other") then
			local icon = SelfItemIcon(buff)
			other[#other + 1] = icon
			if not icon and BuffDuty.RowOut("other") and OtherMissing(buff) then
				missing.other = true
			end
		end
	end

	local function AddSection(label, list, row, rows)
		if list[1] or (rows and rows[1]) or missing[row] then
			sections[#sections + 1] = {
				kind = "self",
				label = label,
				icons = TagRow(list, row),
				rows = rows or {},
				grid = "self_" .. row,
				menu = not rows and row or nil,
				missing = missing[row] or nil,
			}
		end
	end
	AddSection(L["BUFF_DUTY_SELF_HEADER"], {}, "self", SelfTypeRows(byType))
	AddSection(BuffDuty.WellFedLabel(), food, "food")
	for _, hand in ipairs(weapons) do
		TagRow(hand.icons, "weapons")
	end
	AddSection(L["BUFF_DUTY_WEAPON_PANEL_HEADER"], {}, "weapons", weapons)
	AddSection(L["BUFF_DUTY_SCROLLS"], scrolls, "scrolls")
	AddSection(L["BUFF_DUTY_ROW_ELIXIRS"], elixirs, "elixirs")
	AddSection(L["BUFF_DUTY_ROW_OTHER"], other, "other")
end
