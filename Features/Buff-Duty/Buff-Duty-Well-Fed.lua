local _, ns = ...
local L = ns.L

local BuffDuty = ns.BuffDuty

local GetItemCount = C_Item.GetItemCount

--------------------------------------------------------------------------------
-- Eating
--------------------------------------------------------------------------------

--[[
    Matched by name, since every food and drink has an aura id of its own:
    the generic Food and Drink, plus the buff food's own spell for one whose
    aura is named for itself.
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

-- Nil while auras are secret. The Buff Key stays silent while eating: a press would restart the meal or stand you up.
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

--------------------------------------------------------------------------------
-- Well Fed
--------------------------------------------------------------------------------

--[[
    Matched by icon too, for a food the tables don't list, as the Food macro
    does. had is nil when an aura is secret, so the window doesn't nag about
    a buff that may be there.
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
    ns.bestBuffFoodID already applies the Ignore List and arena. Nothing while
    eating: Well Fed lands when the meal ends, and another click would spend
    a second food.
]]
function BuffDuty.WellFedIcon(buff)
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

function BuffDuty.FoodMissing()
	local itemId = ns.bestBuffFoodID
	if itemId and GetItemCount(itemId) > 0 then
		return false
	end
	local had, _, _, eating = WellFedAura()
	return had == false and not eating
end

function BuffDuty.WellFedLabel()
	local wellFed = ns.GetWellFedName()
	return wellFed ~= "" and wellFed or L["BUFF_DUTY_MENU_BUFF_FOOD"]
end
