local _, ns = ...

--[[
    Buff-Duty-Groups -- your group's sections of the Buff Duty window, one per
    party with something missing; Buff-Duty.lua's BuffDuty.BuildSections adds
    them after your own and the outsiders'.
]]

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local GroupMembers = BuffDuty.GroupMembers
local CanBuff = BuffDuty.CanBuff
local ReadAuras = BuffDuty.ReadAuras
local RoleOf = BuffDuty.RoleOf
local Wants = BuffDuty.Wants
local Has = BuffDuty.Has
local SingleIcon = BuffDuty.SingleIcon
local ResurrectionIcon = BuffDuty.ResurrectionIcon
local PlayerLabel = BuffDuty.PlayerLabel
local PetRow = BuffDuty.PetRow
local PetUnitOf = BuffDuty.PetUnitOf

--------------------------------------------------------------------------------
-- Group Sections
--------------------------------------------------------------------------------

--[[
    A group buff lands on its target's party, so any member who needs it will
    do; one in range is the one worth clicking.
]]
local function PickGroupTarget(units, spellName)
	for _, unit in ipairs(units) do
		if ns.IsBuffInRange(unit, spellName) then
			return unit
		end
	end
	return units[1]
end

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------

--[[
    In a raid every group starts folded to its header: only the group-level
    buffs it still needs, each with a count of who needs it. Clicking the
    header (Buff-Duty-Layout.lua's fold buttons) unfolds it to its members.
    Kept for the session until you leave the raid (BuffDuty.ResetGroupFolds,
    from Buff-Duty.lua's roster handler), so a raid's roster churn or the
    window hiding doesn't fold a group you opened.
]]
local unfolded = {}

function BuffDuty.ToggleGroupFold(subgroup)
	if InCombatLockdown() then
		return
	end
	unfolded[subgroup] = not unfolded[subgroup] or nil
	ns.RequestBuffDutyRefresh()
end

function BuffDuty.ResetGroupFolds()
	wipe(unfolded)
end

-- A dead member's resurrection row, which stays on a folded group: bringing them back comes first.
local function ResurrectionRows(rows)
	local kept = {}
	for _, row in ipairs(rows) do
		local first = row.icons[1]
		if not row.pet and first and first.isResurrection then
			kept[#kept + 1] = row
		end
	end
	return kept
end

--[[
    A folded group's header: the group icons the Buff Key would choose, then
    one icon for each other buff a member still needs (Thorns, or a group
    buff not worth casting), counted like them. That icon is one member's own single cast, in range if any is, so
    each click buffs the next one and the count drops. Sorted by column, so
    the Buff Key weighs them in the window's order.
]]
local function FoldedIcons(icons, rows)
	local grouped, singles, order = {}, {}, {}
	for _, spec in ipairs(icons) do
		grouped[spec.column] = true
	end
	for _, row in ipairs(rows) do
		if not row.pet then
			for _, spec in ipairs(row.icons) do
				if not grouped[spec.column] and not spec.isResurrection then
					local list = singles[spec.column]
					if not list then
						list = {}
						singles[spec.column] = list
						order[#order + 1] = spec.column
					end
					list[#list + 1] = spec
				end
			end
		end
	end
	local folded = { unpack(icons) }
	for _, column in ipairs(order) do
		local list = singles[column]
		local pick = list[1]
		for _, spec in ipairs(list) do
			if ns.IsBuffSpecInRange(spec) then
				pick = spec
				break
			end
		end
		local needs = {}
		for _, spec in ipairs(list) do
			needs[#needs + 1] = spec.targetName
		end
		local header = {}
		for key, value in pairs(pick) do
			header[key] = value
		end
		header.count, header.needs = #list, needs
		folded[#folded + 1] = header
	end
	table.sort(folded, function(a, b)
		return a.column < b.column
	end)
	return folded
end

--[[
    An unfolded raid group's rows less the single icons the group casts it
    shows cover (BuffDuty.GroupChoices). A member left with nothing drops off,
    unless their pet's row follows: it keeps them listed, as it always has.
]]
local function UncoveredRows(rows, covered)
	local kept = {}
	for index, row in ipairs(rows) do
		if row.pet then
			kept[#kept + 1] = row
		else
			local icons = {}
			for _, spec in ipairs(row.icons) do
				if not covered[spec.column] then
					icons[#icons + 1] = spec
				end
			end
			local nextRow = rows[index + 1]
			if #icons > 0 or (nextRow and nextRow.pet) then
				kept[#kept + 1] = { label = row.label, icons = icons }
			end
		end
	end
	return kept
end

--[[
    One section per party with something missing: the party's group-buff icons
    on its header, then a row per member with their single-target icons. Every
    party gets its own group icon once any of its members is missing the buff
    -- a raid buffs party by party, so a party of one in a raid still needs its
    own. Only solo, outside any group, is there none: the single version does
    the same for no reagent.

    A member's pet sits on its own row under them, and keeps the member listed
    -- with no icons of their own, if they need nothing -- until the pet is
    buffed too. Pets don't count toward a group icon: the group versions are
    cast to be sure of the players.

    A dead member you can resurrect gets a row with that one icon, in its own
    column on the left, and drops off once they're back up (or a resurrection
    is waiting on them to accept).

    You are left out: your own buffs show under Self Buffs (Buff-Duty-Self.lua).

    A raid is drawn smaller: each group icon carries a count of the members
    who need it. Both kinds show only the group casts the Buff Key would
    choose: a folded group (Folding, above) adds one counted icon per other
    buff (FoldedIcons), and an unfolded one takes the singles they cover off
    its rows.
]]
function BuffDuty.AddGroupSections(sections)
	local grouped = IsInGroup()
	local raid = IsInRaid()
	local parties = {}

	for _, member in ipairs(GroupMembers()) do
		local party = parties[member.subgroup]
		if not party then
			party = { missing = {}, low = {}, rows = {} }
			parties[member.subgroup] = party
		end

		local unit = member.unit
		local _, class = UnitClass(unit)
		local name = GetUnitName(unit, false) or ""
		local row
		--[[
		    Your own buffs are the Self Buffs section's, by the Self-Buffs
		    panel's timing (BuffDuty.BuildBuffs), so your row here only holds
		    your pet's place, and you never count toward a group icon.
		]]
		if member.isPlayer then
			row = nil
		elseif CanBuff(unit) then
			ReadAuras(unit)
			local role = RoleOf(unit, class)
			for _, buff in ipairs(buffs) do
				local has, expires, duration = true, nil, nil
				if Wants(buff, class, role) then
					has, expires, duration = Has(buff, unit)
				end
				if not has then
					local missing = party.missing[buff] or {}
					party.missing[buff] = missing
					missing[#missing + 1] = unit
					--[[
					    The group icon shows time left only while every member it
					    is for has some: the soonest of theirs. One with none
					    makes it whole.
					]]
					local low = party.low[buff] or { count = 0 }
					party.low[buff] = low
					if expires then
						low.count = low.count + 1
						if not low.expires or expires < low.expires then
							low.expires, low.duration = expires, duration
						end
					end
					local icon = buff.singleName and SingleIcon(buff, unit, unit, name)
					if icon then
						row = row or { label = PlayerLabel(name, class, unit), icons = {} }
						row.icons[#row.icons + 1] = BuffDuty.WithTimeLeft(icon, expires, duration)
					end
				end
			end
		else
			local icon = ResurrectionIcon(unit, unit, name)
			if icon then
				row = { label = PlayerLabel(name, class, unit), icons = { icon } }
			end
		end

		local petRow = PetRow(PetUnitOf(unit), PetUnitOf(unit), class)
		if petRow then
			row = row or { label = PlayerLabel(name, class, unit), icons = {} }
		end
		if row then
			party.rows[#party.rows + 1] = row
		end
		if petRow then
			party.rows[#party.rows + 1] = petRow
		end
	end

	for subgroup = 1, 8 do
		local party = parties[subgroup]
		if party then
			local icons = {}
			for _, buff in ipairs(buffs) do
				local missing = party.missing[buff]
				if buff.groupName and missing and grouped and not BuffDuty.ShutOut(buff) then
					local target = PickGroupTarget(missing, buff.groupName)
					local low = party.low[buff]
					local partial = low.count == #missing
					icons[#icons + 1] = BuffDuty.WithTimeLeft({
						spellId = buff.groupId,
						castIds = buff.groupIds,
						column = buff.column,
						spellName = buff.groupName,
						castSpell = buff.groupCastText,
						unit = target,
						targetName = GetUnitName(target, false) or "",
						isGroup = true,
						buffKey = buff.key,
						--[[
						    For the Buff Key, which weighs this against the
						    members' single casts (GroupChoices).
						]]
						subgroup = subgroup,
						members = missing,
					}, partial and low.expires, partial and low.duration)
				end
			end
			if #icons > 0 or #party.rows > 0 then
				local section = {
					kind = "party",
					subgroup = subgroup,
					label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
					icons = icons,
					rows = party.rows,
					-- The frame lays parties out two to a row.
					party = true,
				}
				if raid then
					for _, spec in ipairs(icons) do
						spec.count = #spec.members
						spec.needs = {}
						for _, unit in ipairs(spec.members) do
							spec.needs[#spec.needs + 1] = GetUnitName(unit, false) or ""
						end
					end
					section.foldable = true
					if unfolded[subgroup] then
						local chosen, covered = BuffDuty.GroupChoices(section)
						section.icons = chosen
						section.rows = UncoveredRows(party.rows, covered)
					else
						section.folded = true
						-- Weighed against the members' singles before folding drops their rows.
						local chosen = BuffDuty.GroupChoices({ icons = icons, rows = party.rows })
						section.icons = FoldedIcons(chosen, party.rows)
						section.rows = ResurrectionRows(party.rows)
					end
				end
				sections[#sections + 1] = section
			end
		end
	end
end
