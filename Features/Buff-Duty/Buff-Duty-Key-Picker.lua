local _, ns = ...

local BuffDuty = ns.BuffDuty

local GetItemCooldown = C_Container.GetItemCooldown
local IsSpellUsable = C_Spell.IsSpellUsable
local GetSpellPowerCost = C_Spell.GetSpellPowerCost

-- Looked up at call time: Buff-Duty-Keys.lua loads after this file.
local function Skipped(spec, now)
	return BuffDuty.BuffKeySkipped(spec, now)
end

--------------------------------------------------------------------------------
-- Readiness
--------------------------------------------------------------------------------

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

local globalCooldownReference

--[[
    Classic Era, Season of Discovery and TBC have no GCD spell (61304), so
    there it is the first of your own Buff Duty spells whose only cooldown is
    the global one.
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

-- 0 when none is running or the client won't say.
function BuffDuty.GlobalCooldownEnd()
	local spellId = GlobalCooldownSpell()
	local info = spellId and C_Spell.GetSpellCooldown(spellId)
	local start, duration = info and info.startTime, info and info.duration
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return 0
	end
	return start + duration
end

--[[
    A spell on the global cooldown reports it as its own, so a real cooldown
    runs past the GCD's end. Haste shortens the GCD, so it is read, never
    assumed.
]]
local function OnCooldown(start, duration)
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return false
	end
	local ends = start + duration
	return ends > GetTime() and ends > BuffDuty.GlobalCooldownEnd()
end

-- Short on mana still counts as ready: the cast's own error says so.
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
    The key is for buffs you can cast again and again, so one with its own
    cooldown (Fear Ward) is left to its icon. An item's cooldown is the
    item's, so it says so itself (hasCooldown). GetSpellBaseCooldown already
    leaves the GCD out.
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

-- In your group or not, even with the Target list off.
local function ResurrectionSpec()
	if not UnitExists("target") or not ns.IsPlainYes(UnitIsFriend("player", "target")) then
		return nil
	end
	return BuffDuty.ResurrectionIcon("target", "target", GetUnitName("target", false) or "")
end

local function TargetSubgroup()
	if not UnitExists("target") then
		return nil
	end
	for _, member in ipairs(BuffDuty.GroupMembers()) do
		if ns.IsPlainYes(UnitIsUnit(member.unit, "target")) then
			return member.subgroup
		end
	end
	return nil
end

--[[
    Range doesn't thin the members out: a group buff waits for its whole
    party (Reachable), so it is weighed against singles for all of them. One
    with no single to fall back on is always kept, so the key can say who it
    waits on. The window passes no `now`, so its raid headers skip the press
    memory.
]]
local function GroupChoices(section, now)
	local chosen, covered = {}, {}
	for _, group in ipairs(section.icons) do
		-- A folded raid group's header also holds single casts (Buff-Duty-Groups.lua's FoldedIcons): nothing to weigh.
		if group.isGroup then
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
			if now and Skipped(group, now) then
				covered[group.column] = true
			else
				local reach, singleCost, groupOnly = 0, 0, false
				for _, unit in ipairs(group.members) do
					local single = singles[unit]
					if not (single and now and Skipped(single, now)) then
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
	end
	return chosen, covered
end

BuffDuty.GroupChoices = GroupChoices

-- A category whose Use with Cast Next Buff is off gives none of its icons; they stay a click on the window.
local function Candidates(sections, now)
	local list, added = {}, {}
	-- Consumables and weapon buffs are each added in their own place below, never with the casts.
	local function Add(spec, allowItem)
		if
			spec
			and (allowItem or not (spec.weapon or spec.selfItem))
			and not added[spec]
			and not (spec.dutyRow and not BuffDuty.RowOnKey(spec.dutyRow))
		then
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
	local function EachSelfIcon(test)
		Each("self", function(section)
			for _, spec in ipairs(section.icons) do
				if test(spec) then
					Add(spec, true)
				end
			end
			for _, row in ipairs(section.rows) do
				for _, spec in ipairs(row.icons) do
					if test(spec) then
						Add(spec, true)
					end
				end
			end
		end)
	end

	-- 1. Resurrections before anything else: your dead target, then your group's dead.
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

	-- 2. Asking your target: a whisper, sent with the same press's cast.
	Each("target", function(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if spec.ask then
					Add(spec)
				end
			end
		end
	end)

	--[[
	    3. Your own casts, your target first. Return the Favor comes after:
	    its macro clears your target to find the stranger by name.
	]]
	Each("target", function(section)
		for _, row in ipairs(section.rows) do
			if not row.npc then
				for _, spec in ipairs(row.icons) do
					Add(spec)
				end
			end
		end
	end)
	Each("favor", AddRows)
	-- Self-Buffs' type lines in the order the buffs were built, as when they shared one line.
	Each("self", function(section)
		for _, spec in ipairs(section.icons) do
			if not spec.castLast then
				Add(spec)
			end
		end
		local typed = {}
		for _, row in ipairs(section.rows) do
			if row.selfType then
				for _, spec in ipairs(row.icons) do
					if not spec.castLast then
						typed[#typed + 1] = spec
					end
				end
			end
		end
		table.sort(typed, function(a, b)
			return a.column < b.column
		end)
		for _, spec in ipairs(typed) do
			Add(spec)
		end
	end)

	local function AddParty(section)
		local chosen, covered = GroupChoices(section, now)
		for _, spec in ipairs(chosen) do
			Add(spec)
		end
		-- A folded raid group's counted single casts (Thorns) sit on its header.
		for _, spec in ipairs(section.icons) do
			if not spec.isGroup then
				Add(spec)
			end
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

	-- Shadowform shuts out Holy spells, so it goes up once the rest are out.
	EachSelfIcon(function(spec)
		return spec.castLast
	end)

	-- 4. Scrolls, in the window's order.
	EachSelfIcon(function(spec)
		return spec.scroll
	end)

	-- 5. Weapon buffs: each hand's row, its best icon first.
	Each("self", function(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if spec.weapon then
					Add(spec, true)
				end
			end
		end
	end)

	-- 6. Elixirs, then Other Buffs, each while its category is on the key.
	EachSelfIcon(function(spec)
		return spec.dutyRow == "elixirs"
	end)
	EachSelfIcon(function(spec)
		return spec.dutyRow == "other"
	end)

	-- 7. Well Fed after the casts: eating sits you down, and the next cast would stand you back up.
	EachSelfIcon(function(spec)
		return spec.wellFed
	end)

	-- 8. A targeted NPC's row cycles forever, so any sooner it would keep the key from reaching what follows.
	Each("target", function(section)
		for _, row in ipairs(section.rows) do
			if row.npc then
				for _, spec in ipairs(row.icons) do
					Add(spec)
				end
			end
		end
	end)
	return list
end

-- For the window's packed lines; no `now`, so no press memory.
function BuffDuty.CastOrder(sections)
	return Candidates(sections)
end

--------------------------------------------------------------------------------
-- Picking
--------------------------------------------------------------------------------

-- Pally Power's test: out of sight yet not AFK. One the client won't say about holds nothing up.
local function OutOfSight(unit)
	local visible, afk = UnitIsVisible(unit), UnitIsAFK(unit)
	return ns.IsPlain(visible) and ns.IsPlain(afk) and not visible and not afk or false
end

--[[
    A group buff waits until every member missing it is in sight: going out
    early would leave whoever's away to be buffed again by hand.
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
    With nothing ready, the first refused one, so its own error ("Missing
    reagent") says why. An ask comes back fourth, beside the pick, so one
    press both whispers and casts.
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
	local refused, waitingOn, flagged, askSpec
	for _, spec in ipairs(candidates) do
		local flaggedName = not spec.ask and BuffDuty.PvPFlaggedTarget(spec)
		-- An ask waits only on that player's ask cooldown, not your range, mana or cooldowns.
		if spec.ask then
			if not askSpec and BuffDuty.CanAskTarget(spec) then
				askSpec = spec
			end
		elseif flaggedName then
			-- Passed over so it can't hold up the rest; the press names them if nothing else is left.
			flagged = flagged or flaggedName
		elseif not Skipped(spec, now) and not HasCooldown(spec) then
			local readiness = Readiness(spec)
			if readiness ~= "cooldown" then
				local inReach, waiting = Reachable(spec)
				if not inReach then
					waitingOn = waitingOn or waiting
				elseif readiness == "ready" then
					return spec, nil, nil, askSpec
				else
					refused = refused or spec
				end
			end
		end
	end
	return refused, waitingOn, flagged, askSpec
end

BuffDuty.PickBuffKeySpec = PickNext
