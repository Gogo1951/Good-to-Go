local _, ns = ...

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

function ns.GetWellFedName()
	return C_Spell.GetSpellName(ns.WELL_FED_SPELL_ID) or ""
end

function ns.GetFirstAidName()
	return C_TradeSkillUI.GetTradeSkillDisplayName(ns.FIRST_AID_SKILL_LINE_ID) or ""
end

--------------------------------------------------------------------------------
-- Game-State Predicates
--------------------------------------------------------------------------------

-- Blizzard's own rule (GameRulesUtil.GetEffectiveMaxLevelForPlayer): the smaller of the two caps.
function ns.GetMaxPlayerLevel()
	return math.min(GetMaxLevelForPlayerExpansion(), GetMaxPlayerLevel())
end

--[[
    Every group read here must stay inside ns.GroupSignatureChanged, or a join,
    leave or battleground never rescans. Keys are built once per prefix: this
    runs on every pet aura change and bag scan.
]]
local useWhenKeys = {}

function ns.IsUseWhenActive(settings, prefix)
	local keys = useWhenKeys[prefix]
	if not keys then
		keys = { prefix .. "In", prefix .. "Level" }
		useWhenKeys[prefix] = keys
	end
	if not ns.IsGroupContextOn(settings[keys[1]]) then
		return false
	end
	local level = settings[keys[2]]
	if level == "leveling" or level == "maxlevel" then
		local atMaxLevel = (ns.cachedPlayerLevel or UnitLevel("player")) >= ns.GetMaxPlayerLevel()
		if level == "maxlevel" then
			return atMaxLevel
		end
		return not atMaxLevel
	end
	return true
end

function ns.KnowsAny(spellList)
	if not spellList then
		return false
	end
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return true
		end
	end
	return false
end

-- Keyed by spell so a second read of the same cooldown never stacks another timer.
local rebuildAt = {}

local function RebuildWhenReady(spellID, readyAt)
	if rebuildAt[spellID] == readyAt then
		return
	end
	rebuildAt[spellID] = readyAt
	C_Timer.After(math.max(readyAt - GetTime(), 0) + 0.1, function()
		if rebuildAt[spellID] == readyAt then
			rebuildAt[spellID] = nil
			ns.RequestUpdate()
		end
	end)
end

-- A hidden cooldown counts as on cooldown: the body without the racial is always safe.
function ns.RacialSpellReady(spellID)
	if ns.IsSpellCooldownSecret(spellID) then
		return false
	end
	local cooldown = C_Spell.GetSpellCooldown(spellID)
	if not cooldown then
		return true
	end
	local startTime, duration = cooldown.startTime, cooldown.duration
	-- A GCD reading counts as on cooldown and times the rebuild for its end.
	if not duration or duration <= 0 then
		return true
	end
	local readyAt = startTime + duration
	if readyAt <= GetTime() then
		return true
	end
	RebuildWhenReady(spellID, readyAt)
	return false
end
