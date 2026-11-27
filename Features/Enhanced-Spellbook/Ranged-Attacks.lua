local _, ns = ...

local MacroBody = ns.MacroBody
local SpellName = ns.SpellName

local WEAPON_CLASS = 2 -- Enum.ItemClass.Weapon
local RANGED_SLOT = 18

-- The client's own subclass name ("Bows"), which [worn:] matches in every locale; nil when it can't name it.
function ns.RangedWornName(attack)
	return (C_Item.GetItemSubClassInfo(WEAPON_CLASS, attack.subclass))
end

--[[
	For the icon, tooltip and #showtooltip only: the cast line tries each attack by the weapon worn, so it never
	waits on this.
]]
local function EquippedRangedAttack(macro)
	local link = GetInventoryItemLink("player", RANGED_SLOT)
	local subclass = link and select(7, C_Item.GetItemInfoInstant(link))
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = attack.subclass == subclass and ns.SpellName(attack.id)
		if name and macro.rangedAttacks[name] then
			return name
		end
	end
	return macro.name
end

ns.EquippedRangedAttack = EquippedRangedAttack

-- A weapon the client can't name is left out, rather than given an English condition that never matches.
function ns.KnownRangedAttacks()
	local known = {}
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = ns.IsPlayerSpell(attack.id) and SpellName(attack.id)
		local wornName = ns.RangedWornName(attack)
		if name and wornName then
			known[#known + 1] = { name = name, wornName = wornName, id = attack.id }
		end
	end
	return known
end

-- The attack for the ranged weapon worn now, by spell ID, or the first one known; nil when none is.
function ns.WornRangedAttackID()
	local link = GetInventoryItemLink("player", RANGED_SLOT)
	local subclass = link and select(7, C_Item.GetItemInfoInstant(link))
	local first
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		if ns.IsPlayerSpell(attack.id) then
			if attack.subclass == subclass then
				return attack.id
			end
			first = first or attack.id
		end
	end
	return first
end

--[[
	Only the attack for the weapon worn works, so one Shoot macro tries each by [worn:]. The carrier keeps its
	settings, copies and WoW macro whatever is equipped or learned next; the others are hidden but still synced.
]]
local function FoldRangedAttacks()
	local own = {}
	for _, macro in ipairs(ns.macros) do
		if not macro.copy and not macro.rank and not macro.unlearned then
			own[macro.name] = macro
		end
	end
	local folded = {}
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = SpellName(attack.id)
		if name and own[name] then
			folded[#folded + 1] = name
		end
	end
	if #folded < 2 then
		return
	end
	local carrier, attacks = nil, {}
	for _, name in ipairs(folded) do
		attacks[name] = true
		if not carrier and ns.HasSpellMacroTag(own[name].baseID) then
			carrier = name
		end
	end
	carrier = carrier or folded[1]
	-- the client's own name for Shoot, or the carrier's while that spell's data hasn't loaded
	local label = C_Spell.GetSpellName(ns.SHOOT_SPELL_ID) or carrier
	for _, macro in ipairs(ns.macros) do
		if macro.name == carrier and not macro.unlearned then
			macro.rangedAttacks = attacks
			macro.label = label .. (macro.copy and " " .. macro.copy or "")
			macro.sortName = label
			macro.icon = C_Spell.GetSpellTexture(ns.CastSpellName(macro)) or macro.icon
			macro.body = MacroBody(macro)
		elseif attacks[macro.name] and not macro.unlearned then
			macro.hidden = true
		end
	end
end

ns.FoldRangedAttacks = FoldRangedAttacks
