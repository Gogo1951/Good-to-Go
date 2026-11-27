local _, ns = ...

--[[
    A warrior short on rage for a self buff casts Bloodrage, then the buff,
    from one macro. The rage often isn't there yet for the buff's line on
    that press, so the next press casts it; Bloodrage on its cooldown by then
    just errors and the buff still goes off.
]]

local BuffDuty = ns.BuffDuty

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

-- The client's own answer first, then the rage cost against your rage, for a client that leaves either unread.
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
    Spell id -> the NeedsRageFirst answer each icon was drawn with. The
    window isn't redrawn on rage alone, so CheckRageFirst asks for a redraw
    only when one of these would change.
]]
local rageFirstDrawn = {}

function BuffDuty.CheckRageFirst()
	if InCombatLockdown() then
		return
	end
	for spellId, drawn in pairs(rageFirstDrawn) do
		if NeedsRageFirst(spellId) ~= drawn then
			ns.RequestBuffDutyRefresh()
			return
		end
	end
end

function BuffDuty.ForgetRageFirst()
	wipe(rageFirstDrawn)
end

function BuffDuty.WithRageFirst(spec)
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
