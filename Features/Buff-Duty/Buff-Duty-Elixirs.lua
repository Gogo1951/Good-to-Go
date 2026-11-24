local _, ns = ...
local L = ns.L

--[[
    Buff-Duty-Elixirs -- the Buff Duty window's Flasks or Elixirs section: an icon
    for every elixir in your bags whose buff you're missing, or have running
    low by your own time for Elixirs. A click drinks it; the Cast Next Buff key
    leaves them alone unless the category's Use with Cast Next Buff is on.

    An elixir is any bag item whose use spell is a buff in this client's
    ns.ELIXIR_BUFF_IDS, the table those buffs are keyed by. Each buff's value
    there names what it can't be up beside: from TBC on, "BATTLE" or
    "GUARDIAN", the two slots a character has, both filled by a flask; on
    Classic Era and its kin, a group of buffs that don't stack. A buff whose
    value is still plain true stands alone, blocked by nothing but itself. An
    elixir is passed over while another buff of its slot or group is on you,
    so the section never offers what the game would refuse or what would overwrite
    a buff already up. One the category's menu turns off (elixirOff) is
    passed over.

    Left to their own sections: scrolls (some of whose buffs fill an elixir
    slot on Mists of Pandaria) and any consumable with a dropdown of its own
    (Winterfall Firewater, under Other Buffs). Items the Ignore List holds are passed over too.
]]

local BuffDuty = ns.BuffDuty

local GetItemCount = C_Item.GetItemCount

--[[
    Item id -> the buff its use spell gives, or false for an item that gives
    none of the elixir buffs. An item the client hasn't loaded yet answers
    nothing and is asked again next time.
]]
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

-- What a buff can't be up beside: its slot or group, or the buff itself when the data names none.
local function GroupOf(spellId)
	local group = ns.ELIXIR_BUFF_IDS[spellId]
	return group == true and spellId or group
end

-- The items with a dropdown of their own (Other Buffs), which keep to it.
local function OwnRowItems()
	local items = {}
	for _, entry in ipairs(BuffDuty.selfItemEntries) do
		if entry.itemId then
			items[entry.itemId] = true
		end
	end
	return items
end

--[[
    The elixirs in your bags, one per buff, each { itemId, spellId }, sorted
    by item name so the section keeps its order as bags change. honorIgnore
    passes over what the Ignore List holds, as the window does; the Options
    flyout asks without it.
]]
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

--[[
    Your elixir and flask buffs: buff id -> { expires, duration }, and each
    slot or group a buff on you takes. From TBC on a flask takes both slots.
    Nil when your auras can't be read (secret on WoW Forever, in combat), so
    the section stays quiet rather than nag about a buff that may be there.
]]
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

--[[
    The section's icons: an elixir whose own buff is on you shows only once it's
    running low; one whose slot or group another buff takes shows not at
    all; the rest show as missing. Each sits a hundredth past Elixirs'
    column, in the section's own order.
]]
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

--[[
    Flasks or Elixirs' Missing Inventory!: no elixir or flask buff on you,
    and none in your bags that the category's menu leaves on. Says no while
    your auras can't be read.
]]
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
