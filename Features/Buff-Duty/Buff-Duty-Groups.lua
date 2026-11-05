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
		if CanBuff(unit) then
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
				if buff.groupName and missing and grouped then
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
				sections[#sections + 1] = {
					kind = "party",
					subgroup = subgroup,
					label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
					icons = icons,
					rows = party.rows,
					-- The frame lays parties out two to a row.
					party = true,
				}
			end
		end
	end
end
