local _, ns = ...

local function RankOf(id)
	local subtext = C_Spell.GetSpellSubtext(id)
	return subtext and tonumber(subtext:match("%d+"))
end

-- Nil while a required spell's name isn't loaded.
local function IsHigherRank(spell, name)
	if (RankOf(spell.id) or 1) > 1 then
		return true
	end
	for _, id in ipairs(spell.requires or {}) do
		local required = ns.SpellName(id)
		if not required then
			return nil
		end
		if required == name then
			return true
		end
	end
	return false
end

--[[
	fn(name, icon, id, level, talent) per unlearned spell's rank 1. Data/ includes the rank 1 of each talent that
	has trainer ranks; talents without trainer ranks need an extraSpells entry. Spells whose data isn't loaded
	yet are skipped: the page refreshes on SPELL_DATA_LOAD_RESULT.
]]
function ns.ForEachUnlearnedSpell(fn, learned)
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	local seen = {}
	local spells = {}
	local recorded = ns.RecordedTrainerSpells and ns.RecordedTrainerSpells() or {}
	for _, list in ipairs({ ns.TRAINER_SPELLS[select(2, UnitClass("player"))] or {}, recorded }) do
		for _, spell in ipairs(list) do
			spells[#spells + 1] = spell
		end
	end
	local sources = ns.EXTRA_SPELL_SOURCES or {}
	for _, entry in ipairs(ns.ClassExtraSpells()) do
		local id = type(entry) == "table" and entry[1] or entry
		local source, level = unpack(sources[id] or {})
		if not level then
			level = C_Spell.GetSpellLevelLearned(id)
		end
		spells[#spells + 1] = { id = id, level = level and level > 0 and level or nil, talent = source == "TALENT" }
	end
	-- a level tie keeps list order, so a trainer row stays ahead of an extraSpells entry
	local order = {}
	for i, spell in ipairs(spells) do
		order[spell] = i
	end
	table.sort(spells, function(a, b)
		if a.level ~= b.level then
			if not a.level or not b.level then
				return b.level == nil
			end
			return a.level < b.level
		end
		return order[a] < order[b]
	end)
	for _, spell in ipairs(spells) do
		if (not spell.faction or spell.faction == faction) and (not spell.race or spell.race == race) then
			local name = ns.SpellName(spell.id)
			if name and not seen[name] then
				local higherRank = IsHigherRank(spell, name)
				if higherRank == false then
					seen[name] = true
					if not learned[name] and not C_Spell.IsSpellPassive(spell.id) then
						fn(name, C_Spell.GetSpellTexture(spell.id), spell.id, spell.level, spell.talent == true)
					end
				end
			end
		end
	end
end
