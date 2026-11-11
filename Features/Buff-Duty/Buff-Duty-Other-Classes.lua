local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The group's raid buffs, counted under the window's Party-Buffs: one icon
    per raid-wide buff -- a ns.BUFF_DUTY_SPELLS row with a group version
    (Mark of the Wild, Arcane Intellect, Fortitude) -- of your class, or of a
    class up and online in your group, numbered with how many members are
    missing it. One you can cast yourself is left out, since your own party
    sections list it (a priest's Fortitude), but your class's talent buff you
    lack (Divine Spirit) stays. A buff running low counts as missing under the same Refresh
    Under as your own buffs. Blessings are left out: which one a player gets
    is the paladins' call, not a gap.

    Each buff keeps its Who Gets It setting from the panel, so one set to Off
    isn't counted and one set to Tanks counts only the tanks. A talent buff
    (Divine Spirit) is only counted once someone in the group carries it: a
    raid with no priest who can cast it would otherwise count everyone, for
    good.

    An icon's menu (Buff-Duty-Party-Buffs.lua) asks the party or raid for the
    buff, or whispers the same ask to every other player of that class in
    the group (Features/Announcements.lua builds and sends both); one of your
    own class's, with nobody else of it in the group, has no one to whisper.
    The whole row is the panel's Ask Other Classes for Buffs switch. The
    frame draws the icons; this file counts and asks.
]]

local BuffDuty = ns.BuffDuty

--[[
    How long a buff's ask waits before it can go out again the same way, so
    the group isn't asked twice in a row.
]]
local ASK_COOLDOWN = 10
local lastAsked = { group = {}, whisper = {} } -- way -> buff key -> GetTime() of its last ask

--------------------------------------------------------------------------------
-- Counting
--------------------------------------------------------------------------------

--[[
    The raid-wide buffs of every class that the panel hasn't turned off, less
    the ones you can cast yourself (BuffDuty.buffs): the window's party
    sections already list who needs those, with an icon to cast each.
]]
local function Candidates()
	local audience = ns.db.global.buffWindow.audience
	local yours = {}
	for _, buff in ipairs(BuffDuty.buffs) do
		yours[buff.key] = true
	end
	local candidates = {}
	for _, entry in ipairs(BuffDuty.entries) do
		local row = entry.row
		local who = audience[entry.key]
		if row.group and not row.exclusive and who and who ~= Data.BUFF_AUDIENCE.OFF and not yours[entry.key] then
			candidates[#candidates + 1] = {
				--[[
				    Shaped like a castable buff so Wants and Has can read it. No
				    ranks of yours to weigh theirs against, so any version on a
				    member counts, by its time left.
				]]
				buff = {
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					ranks = {},
					manaOnly = row.manaOnly,
					noCasters = row.noCasters,
				},
				-- The data lists ranks lowest first; the whisper links the top one.
				linkId = entry.ids[#entry.ids],
				class = row.class,
				talent = row.talent,
				carried = false,
				count = 0,
				names = {}, -- subgroup -> the names missing it there
				classes = {}, -- subgroup -> each of those names' class, in step
			}
		end
	end
	return candidates
end

--[[
    The icons to draw, in data order (druids, mages, priests), each one
    { key, spellId, spellName, link, class, count, groups, missing, recipients,
    recipientNames }: `groups` the names missing it, party by party, each
    { label, names, classes }, for the menu; `missing` the same names in
    one list, for the ask; and `recipients` the other
    players of its class to whisper, which may be none for your own class.
    Empty outside a group, and asked after BuildSections, which sets the
    Refresh Under time Has reads.
]]
function BuffDuty.BuildOtherClassBuffs()
	local summary = {}
	if not IsInGroup() or not ns.db.global.buffWindow.askOtherClasses then
		return summary
	end
	local candidates = Candidates()
	if not candidates[1] then
		return summary
	end

	local buffers, buffersShort = {}, {}
	for _, member in ipairs(BuffDuty.GroupMembers()) do
		local unit = member.unit
		local _, class = UnitClass(unit)
		if class and BuffDuty.CanBuff(unit) then
			local name = GetUnitName(unit, false) or ""
			if not UnitIsUnit(unit, "player") then
				-- The whisper needs the realm of a player from another one; the list doesn't.
				buffers[class] = buffers[class] or {}
				buffersShort[class] = buffersShort[class] or {}
				table.insert(buffers[class], GetUnitName(unit, true) or name)
				table.insert(buffersShort[class], name)
			end
			BuffDuty.ReadAuras(unit)
			local role = BuffDuty.RoleOf(unit, class)
			for _, candidate in ipairs(candidates) do
				local buff = candidate.buff
				candidate.carried = candidate.carried or BuffDuty.Carries(buff)
				if BuffDuty.Wants(buff, class, role) and not BuffDuty.Has(buff, unit) then
					candidate.count = candidate.count + 1
					local names = candidate.names[member.subgroup] or {}
					local classes = candidate.classes[member.subgroup] or {}
					candidate.names[member.subgroup] = names
					candidate.classes[member.subgroup] = classes
					names[#names + 1] = name
					classes[#classes + 1] = class
				end
			end
		end
	end

	local raid = IsInRaid()
	local _, playerClass = UnitClass("player")
	for _, candidate in ipairs(candidates) do
		local key = candidate.buff.key
		local present = buffers[candidate.class] or candidate.class == playerClass
		if candidate.count > 0 and present and (candidate.carried or not candidate.talent) then
			local groups, missing = {}, {}
			for subgroup = 1, 8 do
				local names = candidate.names[subgroup]
				if names then
					groups[#groups + 1] = {
						-- Headed like the window's own party sections.
						label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
						names = names,
						classes = candidate.classes[subgroup],
					}
					for _, name in ipairs(names) do
						missing[#missing + 1] = name
					end
				end
			end
			local spellName = C_Spell.GetSpellName(key) or ""
			summary[#summary + 1] = {
				key = key,
				spellId = key,
				spellName = spellName,
				link = ns.GetSpellLink(candidate.linkId) or spellName,
				class = candidate.class,
				count = candidate.count,
				groups = groups,
				missing = missing,
				recipients = buffers[candidate.class] or {},
				recipientNames = buffersShort[candidate.class] or {},
			}
		end
	end
	return summary
end

--------------------------------------------------------------------------------
-- Asking
--------------------------------------------------------------------------------

-- False while the same ask went out the same way under ASK_COOLDOWN ago. The Party-Buffs menu greys its rows by it.
function ns.CanAskForBuff(way, key)
	local last = lastAsked[way][key]
	return not (last and GetTime() - last < ASK_COOLDOWN)
end

-- As ns.CanAskForBuff, and when it can, starts the cooldown.
local function ReadyToAsk(way, key)
	if not ns.CanAskForBuff(way, key) then
		return false
	end
	lastAsked[way][key] = GetTime()
	return true
end

-- The menu's Ask row: the ask, said to the party or raid.
function ns.AskGroupForBuff(spec)
	if ReadyToAsk("group", spec.key) then
		ns:SayBuffRequest(ns:BuildBuffRequestMessage(spec.missing, spec.count, spec.link))
	end
end

--[[
    The menu's Whisper row: the same ask whispered to every other player of
    the class, then a line in your own chat saying who heard.
]]
function ns.WhisperOtherClassBuff(spec)
	if not spec.recipients[1] or not ReadyToAsk("whisper", spec.key) then
		return
	end
	local message = ns:BuildBuffRequestMessage(spec.missing, spec.count, spec.link, true)
	for _, target in ipairs(spec.recipients) do
		ns:QueueAutomatedWhisper(target, message)
	end
	-- Every recipient is of the buff's class, so each name takes its color.
	local names = {}
	for index, name in ipairs(spec.recipientNames) do
		names[index] = ns.ClassColoredName(name, spec.class)
	end
	ns:PrintMessage(L["BUFF_DUTY_OTHERS_SENT"]:format(table.concat(names, L["LIST_SEPARATOR"]), spec.link))
end
