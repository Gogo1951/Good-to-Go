local _, ns = ...

--[[
    Buff-Duty-Key-Picker -- which icon the Buff Key casts next: every icon it
    could cast, in order (Candidates), weighed for readiness, cooldowns, mana
    and reach, and the first that will go off (BuffDuty.PickBuffKeySpec).
    Buff-Duty-Keys.lua owns the button that casts it and the memory of what a
    press just cast, which it lends this file as BuffDuty.BuffKeySkipped.
]]

local BuffDuty = ns.BuffDuty

local GetItemCooldown = C_Container.GetItemCooldown
local IsSpellUsable = C_Spell.IsSpellUsable
local GetSpellPowerCost = C_Spell.GetSpellPowerCost

-- Whether a press a moment ago already cast this (Buff-Duty-Keys.lua), looked up when asked.
local function Skipped(spec, now)
	return BuffDuty.BuffKeySkipped(spec, now)
end

--------------------------------------------------------------------------------
-- Readiness
--------------------------------------------------------------------------------

-- Whether the global cooldown holds a spell up and nothing else does: no cooldown of its own.
local function OnlyGlobalCooldown(spellId)
	if not GetSpellBaseCooldown then
		return false
	end
	local cooldown, globalCooldown = GetSpellBaseCooldown(spellId)
	if not (ns.IsPlain(cooldown) and ns.IsPlain(globalCooldown)) then
		return false
	end
	return cooldown == 0 and (globalCooldown or 0) > 0
end

-- The spell found last time to read the global cooldown from, kept while the player still knows it.
local globalCooldownReference

--[[
    The spell whose cooldown is the global one: ns.GLOBAL_COOLDOWN_SPELL_ID
    where this client's data folder carries it (the clients with spell 61304).
    Classic Era, Season of Discovery and TBC have no such spell, so there it is
    the first of the player's own Buff Duty spells, buffs and self buffs, that
    the global cooldown holds up and nothing else does. nil when the player
    knows none.
]]
local function GlobalCooldownSpell()
	local fixed = ns.GLOBAL_COOLDOWN_SPELL_ID
	if fixed and C_Spell.DoesSpellExist(fixed) then
		return fixed
	end
	if globalCooldownReference and ns.IsPlayerSpell(globalCooldownReference) then
		return globalCooldownReference
	end
	globalCooldownReference = nil
	local _, playerClass = UnitClass("player")
	for _, rows in ipairs({ ns.BUFF_DUTY_SPELLS, ns.BUFF_DUTY_SELF_SPELLS }) do
		for _, row in ipairs(rows) do
			if row.class == playerClass then
				for _, rank in ipairs(row.single or row.ranks or {}) do
					local spellId = rank[1]
					if ns.IsPlayerSpell(spellId) and OnlyGlobalCooldown(spellId) then
						globalCooldownReference = spellId
						return spellId
					end
				end
			end
		end
	end
	return nil
end

-- When the running global cooldown ends, or 0 when none is running or the client won't say.
local function GlobalCooldownEnd()
	local spellId = GlobalCooldownSpell()
	local info = spellId and C_Spell.GetSpellCooldown(spellId)
	local start, duration = info and info.startTime, info and info.duration
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return 0
	end
	return start + duration
end

--[[
    A spell or item on the global cooldown reports it as a short cooldown of its
    own, so a real cooldown is one that runs past the global one's end. Haste
    shortens the global cooldown, so it is read, never assumed.
]]
local function OnCooldown(start, duration)
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return false
	end
	local ends = start + duration
	return ends > GetTime() and ends > GlobalCooldownEnd()
end

--[[
    "cooldown" for a spell or item that can't go off for a while yet (a used
    Soulstone, Fear Ward), "unusable" for one the client refuses for any
    reason but mana (no reagent, no Soul Shard), otherwise "ready". Short on
    mana still counts as ready: the cast's own error says so.
]]
local function Readiness(spec)
	if spec.itemId then
		if OnCooldown(GetItemCooldown(spec.itemId)) then
			return "cooldown"
		end
		return "ready"
	end
	local info = C_Spell.GetSpellCooldown(spec.spellId)
	if info and OnCooldown(info.startTime, info.duration) then
		return "cooldown"
	end
	local usable, noMana = IsSpellUsable(spec.spellId)
	if ns.IsPlain(usable) and ns.IsPlain(noMana) and not usable and not noMana then
		return "unusable"
	end
	return "ready"
end

--[[
    Whether a spell has a cooldown of its own beyond the global one (Fear
    Ward), ready or not. The key is for buffs you can cast again and again,
    so one with a cooldown is left to its icon. An item's cooldown is the
    item's, not its spell's, so an item says so itself (a Soulstone's
    hasCooldown). GetSpellBaseCooldown's first return already leaves the
    global cooldown out, so anything above zero is the spell's own.
]]
local function HasCooldown(spec)
	if spec.itemId then
		return spec.hasCooldown or false
	end
	if not spec.spellId then
		return false
	end
	local milliseconds = GetSpellBaseCooldown and GetSpellBaseCooldown(spec.spellId)
	return ns.IsPlain(milliseconds) and milliseconds and milliseconds > 0 or false
end

-- The mana a spell costs, or nil when the client doesn't say.
local function ManaCost(spellId)
	local costs = spellId and GetSpellPowerCost(spellId)
	if type(costs) ~= "table" then
		return nil
	end
	for _, cost in ipairs(costs) do
		if ns.IsPlain(cost.type) and cost.type == Enum.PowerType.Mana and ns.IsPlain(cost.cost) then
			return cost.cost
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Candidates
--------------------------------------------------------------------------------

--[[
    Your target, if they're a friendly dead player you can bring back -- in
    your group or not. BuffDuty.ResurrectionIcon says who can take one.
]]
local function ResurrectionSpec()
	if not UnitExists("target") or not UnitIsFriend("player", "target") then
		return nil
	end
	return BuffDuty.ResurrectionIcon("target", "target", GetUnitName("target", false) or "")
end

-- Your target's party, or nil when your target isn't in your group.
local function TargetSubgroup()
	if not UnitExists("target") then
		return nil
	end
	for _, member in ipairs(BuffDuty.GroupMembers()) do
		if UnitIsUnit(member.unit, "target") then
			return member.subgroup
		end
	end
	return nil
end

--[[
    The group buffs worth casting on a party, and the buff columns they
    cover. For each buff it is missing: the members who'd take it, less any
    just given the single version. Range doesn't thin them out: a group buff
    waits for its whole party (Reachable), so it is weighed against buffing
    all of them one at a time. The group version goes out
    when it costs less mana than their single casts together, or when one of
    them is too low for any single rank you know; a client that names no
    costs counts the group version as cheaper once it reaches two. Otherwise,
    or with no reagent for it, the members keep their single icons. A group
    version with no single one to fall back on is always kept, so the key
    can say who it waits on. A group buff a press just cast covers its
    column until the aura shows, so its members aren't given singles over
    it. Pets take singles all the same: the group versions are cast to be
    sure of the players.
]]
local function GroupChoices(section, now)
	local chosen, covered = {}, {}
	for _, group in ipairs(section.icons) do
		local singles = {}
		for _, row in ipairs(section.rows) do
			if not row.pet then
				for _, spec in ipairs(row.icons) do
					if spec.column == group.column and spec.unit then
						singles[spec.unit] = spec
					end
				end
			end
		end
		if Skipped(group, now) then
			covered[group.column] = true
		else
			local reach, singleCost, groupOnly = 0, 0, false
			for _, unit in ipairs(group.members) do
				local single = singles[unit]
				if not (single and Skipped(single, now)) then
					reach = reach + 1
					if single then
						local cost = ManaCost(single.spellId)
						singleCost = singleCost and cost and singleCost + cost or nil
					else
						groupOnly = true
					end
				end
			end
			local groupCost = ManaCost(group.spellId)
			local cheaper
			if groupOnly then
				cheaper = true
			elseif singleCost and groupCost then
				cheaper = groupCost < singleCost
			else
				cheaper = reach >= 2
			end
			if not next(singles) or (reach > 0 and cheaper and Readiness(group) ~= "unusable") then
				chosen[#chosen + 1] = group
				covered[group.column] = true
			end
		end
	end
	return chosen, covered
end

--[[
    Every icon the key could cast, in the order it should: resurrections,
    Return the Favor, your target, self-buffs, then each party -- your
    target's first -- with its group buffs (GroupChoices) and then its
    members' single ones, less those a group buff covers.
]]
local function Candidates(sections, now)
	local list, added = {}, {}
	--[[
	    Weapon icons are never candidates: putting a poison or oil on, and
	    answering the game's "replace your enchant?" question, is a click on
	    the window, not a key run through a list.
	]]
	local function Add(spec)
		if spec and not spec.weapon and not added[spec] then
			added[spec] = true
			list[#list + 1] = spec
		end
	end
	local function AddRows(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				Add(spec)
			end
		end
	end
	local function Each(kind, handler)
		for _, section in ipairs(sections) do
			if section.kind == kind then
				handler(section)
			end
		end
	end

	-- Resurrections before anything else: your dead target, then your group's dead.
	Add(ResurrectionSpec())
	Each("party", function(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if spec.isResurrection then
					Add(spec)
				end
			end
		end
	end)

	Each("favor", AddRows)
	Each("target", AddRows)
	Each("self", function(section)
		for _, spec in ipairs(section.icons) do
			Add(spec)
		end
	end)

	local function AddParty(section)
		local chosen, covered = GroupChoices(section, now)
		for _, spec in ipairs(chosen) do
			Add(spec)
		end
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if row.pet or not covered[spec.column] then
					Add(spec)
				end
			end
		end
	end
	local targetSubgroup = TargetSubgroup()
	Each("party", function(section)
		if section.subgroup == targetSubgroup then
			AddParty(section)
		end
	end)
	Each("party", function(section)
		if section.subgroup ~= targetSubgroup then
			AddParty(section)
		end
	end)
	return list
end

--------------------------------------------------------------------------------
-- Picking
--------------------------------------------------------------------------------

--[[
    Pally Power's test for a member a group buff would miss: out of sight,
    yet neither AFK nor offline (an offline member never gets this far:
    BuffDuty.CanBuff leaves them off the list). One the client won't say
    about doesn't hold anything up.
]]
local function OutOfSight(unit)
	local visible, afk = UnitIsVisible(unit), UnitIsAFK(unit)
	return ns.IsPlain(visible) and ns.IsPlain(afk) and not visible and not afk or false
end

--[[
    Whether the cast can reach anyone it's for, and if not, the name of
    someone it's waiting on. A group buff waits, as Pally Power's Greater
    Blessings do, until every member missing it is in sight -- it reaches
    the whole party, so going out early would leave whoever's away to be
    buffed again by hand -- and then needs one of them in range to cast it
    on.
]]
local function Reachable(spec)
	if spec.members then
		for _, unit in ipairs(spec.members) do
			if OutOfSight(unit) then
				return false, GetUnitName(unit, false)
			end
		end
		for _, unit in ipairs(spec.members) do
			if ns.IsBuffInRange(unit, spec.spellName) then
				return true
			end
		end
		return false, GetUnitName(spec.members[1], false)
	end
	if ns.IsBuffSpecInRange(spec) then
		return true
	end
	return false, spec.targetName
end

--[[
    The first candidate that is ready and in reach. With none, the first one
    the client refuses, so its own error ("Missing reagent") says why the key
    did nothing; failing that, nil and whoever the list is waiting on. A buff
    with a cooldown of its own (HasCooldown) is never a candidate, ready or
    not.
]]
local function PickNext()
	local db = ns.db and ns.db.global.buffWindow
	if not BuffDuty.isSetUp or not db or not db.enabled or ns.AreAurasSecret() then
		return nil
	end
	if not BuffDuty.ShowsHere() then
		return nil
	end
	if UnitIsDeadOrGhost("player") then
		return nil
	end

	local now = GetTime()
	local candidates = Candidates(BuffDuty.BuildSections(), now)
	local refused, waitingOn
	for _, spec in ipairs(candidates) do
		if not Skipped(spec, now) and not HasCooldown(spec) then
			local readiness = Readiness(spec)
			if readiness ~= "cooldown" then
				local inReach, waiting = Reachable(spec)
				if not inReach then
					waitingOn = waitingOn or waiting
				elseif readiness == "ready" then
					return spec
				else
					refused = refused or spec
				end
			end
		end
	end
	return refused, waitingOn
end

BuffDuty.PickBuffKeySpec = PickNext
