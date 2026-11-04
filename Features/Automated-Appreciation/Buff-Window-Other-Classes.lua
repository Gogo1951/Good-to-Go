local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The group's raid buffs, counted along the window's title row: one icon
    per raid-wide buff -- a ns.BUFF_WINDOW_SPELLS row with a group version
    (Mark of the Wild, Arcane Intellect, Fortitude) -- of your class, or of a
    class up and online in your group, numbered with how many members are
    missing it. A buff running low counts as missing under the same Refresh
    Under as your own buffs. Blessings are left out: which one a player gets
    is the paladins' call, not a gap.

    Each buff keeps its Who Gets It setting from the panel, so one set to Off
    isn't counted and one set to Tanks counts only the tanks. A talent buff
    (Divine Spirit) is only counted once someone in the group carries it: a
    raid with no priest who can cast it would otherwise count everyone, for
    good.

    A Left-Click on an icon asks the party or raid for the buff, and a
    Right-Click whispers the same ask to every other player of that class in
    the group (Features/Announcements.lua builds and sends both); one of your
    own class's, with nobody else of it in the group, has no one to whisper.
    The whole row is the panel's Ask Other Classes for Buffs switch. The
    frame draws the icons; this file counts and asks.
]]

local BuffWindow = ns.BuffWindow

--[[
    How long a buff's ask waits before it can go out again the same way, so a
    double click doesn't send everything twice.
]]
local ASK_COOLDOWN = 10
local lastAsked = { group = {}, whisper = {} } -- way -> buff key -> GetTime() of its last ask

--------------------------------------------------------------------------------
-- Counting
--------------------------------------------------------------------------------

-- The raid-wide buffs of every class that the panel hasn't turned off.
local function Candidates()
	local audience = ns.db.global.buffWindow.audience
	local candidates = {}
	for _, entry in ipairs(BuffWindow.entries) do
		local row = entry.row
		local who = audience[entry.key]
		if row.group and not row.exclusive and who and who ~= Data.BUFF_AUDIENCE.OFF then
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
    { key, spellId, spellName, link, class, count, groups, recipients,
    recipientNames }: `groups` the names missing it, party by party, each
    { label, names, classes }, for the tooltip; and `recipients` the other
    players of its class to whisper, which may be none for your own class.
    Empty outside a group, and asked after BuildSections, which sets the
    Refresh Under time Has reads.
]]
function BuffWindow.BuildOtherClassBuffs()
	local summary = {}
	if not IsInGroup() or not ns.db.global.buffWindow.askOtherClasses then
		return summary
	end
	local candidates = Candidates()
	if not candidates[1] then
		return summary
	end

	local buffers, buffersShort = {}, {}
	for _, member in ipairs(BuffWindow.GroupMembers()) do
		local unit = member.unit
		local _, class = UnitClass(unit)
		if class and BuffWindow.CanBuff(unit) then
			local name = GetUnitName(unit, false) or ""
			if not UnitIsUnit(unit, "player") then
				-- The whisper needs the realm of a player from another one; the list doesn't.
				buffers[class] = buffers[class] or {}
				buffersShort[class] = buffersShort[class] or {}
				table.insert(buffers[class], GetUnitName(unit, true) or name)
				table.insert(buffersShort[class], name)
			end
			BuffWindow.ReadAuras(unit)
			local role = BuffWindow.RoleOf(unit, class)
			for _, candidate in ipairs(candidates) do
				local buff = candidate.buff
				candidate.carried = candidate.carried or BuffWindow.Carries(buff)
				if BuffWindow.Wants(buff, class, role) and not BuffWindow.Has(buff, unit) then
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
			local groups = {}
			for subgroup = 1, 8 do
				local names = candidate.names[subgroup]
				if names then
					groups[#groups + 1] = {
						-- Headed like the window's own party sections.
						label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
						names = names,
						classes = candidate.classes[subgroup],
					}
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

-- False while the same ask went out the same way under ASK_COOLDOWN ago.
local function ReadyToAsk(way, key)
	local now = GetTime()
	local last = lastAsked[way][key]
	if last and now - last < ASK_COOLDOWN then
		return false
	end
	lastAsked[way][key] = now
	return true
end

-- The icon's Left-Click: the ask, said to the party or raid.
function ns.AskGroupForBuff(spec)
	if ReadyToAsk("group", spec.key) then
		ns:SayBuffRequest(ns:BuildBuffRequestMessage(spec.class, spec.link))
	end
end

--[[
    The icon's Right-Click: the same ask whispered to every other player of
    the class, then a line in your own chat saying who heard.
]]
function ns.WhisperOtherClassBuff(spec)
	if not spec.recipients[1] or not ReadyToAsk("whisper", spec.key) then
		return
	end
	local message = ns:BuildBuffRequestMessage(spec.class, spec.link)
	for _, target in ipairs(spec.recipients) do
		ns:WhisperBuffRequest(target, message)
	end
	ns:PrintMessage(L["BUFF_WINDOW_OTHERS_SENT"]:format(table.concat(spec.recipientNames, ", "), spec.link))
end
