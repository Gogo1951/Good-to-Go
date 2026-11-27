local _, ns = ...
local L = ns.L

--[[
    ns.ELIXIR_BUFF_IDS values name what a buff can't be up beside: a slot
    ("BATTLE" / "GUARDIAN", from TBC on), a non-stacking group, or true for
    itself alone. An elixir is passed over while its slot or group is taken,
    so the section never offers what the game would refuse or overwrite.
    Scrolls (some fill an elixir slot on Mists) and Other Buffs' items keep
    to their own sections.
]]

local BuffDuty = ns.BuffDuty

local GetItemCount = C_Item.GetItemCount

-- Item id -> elixir buff, or false for none. A cold item answers nil uncached and is asked again next time.
local itemBuffs = {}

local function ElixirBuff(itemId)
	local known = itemBuffs[itemId]
	if known ~= nil then
		return known or nil
	end
	local _, spellId = C_Item.GetItemSpell(itemId)
	if not ns.IsPlain(spellId) or not spellId then
		return nil
	end
	local buff = ns.ELIXIR_BUFF_IDS[spellId] and spellId or false
	itemBuffs[itemId] = buff
	return buff or nil
end

local function GroupOf(spellId)
	local group = ns.ELIXIR_BUFF_IDS[spellId]
	return group == true and spellId or group
end

local function OwnRowItems()
	local items = {}
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		if entry.itemId then
			items[entry.itemId] = true
		end
	end
	return items
end

-- One per buff, sorted by name so the section keeps its order as bags change. The Options flyout passes no honorIgnore.
function BuffDuty.CarriedElixirs(honorIgnore)
	local found, seen = {}, {}
	if not ns.ELIXIR_BUFF_IDS or not next(ns.ELIXIR_BUFF_IDS) then
		return found
	end
	local ownRow = OwnRowItems()
	local scrolls = ns.SCROLL_ITEM_LOOKUP or {}
	for _, bagId in ipairs(ns.CARRIED_BAG_IDS) do
		for slot = 1, C_Container.GetContainerNumSlots(bagId) or 0 do
			local itemId = C_Container.GetContainerItemID(bagId, slot)
			if itemId and not seen[itemId] then
				seen[itemId] = true
				if not ownRow[itemId] and not scrolls[itemId] and not (honorIgnore and ns.IsIgnored(itemId)) then
					local spellId = ElixirBuff(itemId)
					if spellId and not seen["spell" .. spellId] then
						seen["spell" .. spellId] = true
						found[#found + 1] = {
							itemId = itemId,
							spellId = spellId,
							name = C_Item.GetItemNameByID(itemId) or "",
						}
					end
				end
			end
		end
	end
	table.sort(found, function(a, b)
		if a.name ~= b.name then
			return a.name < b.name
		end
		return a.itemId < b.itemId
	end)
	return found
end

-- Nil when an aura is secret, so the section stays quiet rather than nag about a buff that may be there.
local function ReadElixirAuras()
	local own, taken = {}, {}
	local flaskFillsSlots = (ns.EXPANSION or 1) >= 2
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not aura then
			break
		end
		local spellId = aura.spellId
		if not ns.IsPlain(spellId) then
			return nil
		end
		if ns.ELIXIR_BUFF_IDS[spellId] then
			own[spellId] = {
				expires = ns.IsPlain(aura.expirationTime) and aura.expirationTime or 0,
				duration = ns.IsPlain(aura.duration) and aura.duration or 0,
			}
			taken[GroupOf(spellId)] = true
		elseif flaskFillsSlots and ns.FLASK_BUFF_IDS and ns.FLASK_BUFF_IDS[spellId] then
			taken.BATTLE, taken.GUARDIAN = true, true
		end
	end
	return own, taken
end

-- Icons sit a hundredth apart past Elixirs' column, so the grid keeps them together and in order.
function BuffDuty.AddElixirIcons(buff, icons)
	if ns.AreAurasSecret() then
		return
	end
	local own, taken = ReadElixirAuras()
	if not own then
		return
	end
	local now = GetTime()
	local name = GetUnitName("player", false) or ""
	local off = ns.db.global.buffWindow.elixirOff
	for index, elixir in ipairs(BuffDuty.CarriedElixirs(true)) do
		local mine = not off[elixir.itemId] and own[elixir.spellId]
		local show, expires, duration
		if mine then
			show = mine.expires ~= 0 and mine.expires - now < buff.refreshSeconds
			expires, duration = mine.expires, mine.duration
		else
			show = not taken[GroupOf(elixir.spellId)]
		end
		if show and not off[elixir.itemId] and GetItemCount(elixir.itemId) > 0 then
			icons[#icons + 1] = BuffDuty.WithTimeLeft({
				itemId = elixir.itemId,
				item = "item:" .. elixir.itemId,
				selfItem = true,
				elixir = true,
				column = buff.column + index / 100,
				unit = "player",
				targetName = name,
				hint = L["BUFF_DUTY_TOOLTIP_USE_ITEM"],
			}, expires, duration)
		end
	end
end

function BuffDuty.ElixirsMissing()
	if ns.AreAurasSecret() then
		return false
	end
	local own, taken = ReadElixirAuras()
	if not own or next(own) or next(taken) then
		return false
	end
	local off = ns.db.global.buffWindow.elixirOff
	for _, elixir in ipairs(BuffDuty.CarriedElixirs(true)) do
		if not off[elixir.itemId] then
			return false
		end
	end
	return true
end
