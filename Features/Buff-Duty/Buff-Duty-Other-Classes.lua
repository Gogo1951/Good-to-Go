local _, ns = ...
local Data = ns.Data

--[[
    Blessings (exclusive rows) are left out: which one a player gets is the
    paladins' call, not a gap. A talent buff (Divine Spirit) counts only once
    someone in the group carries it, or a raid with no priest who can cast it
    would count everyone for good.
]]

local BuffDuty = ns.BuffDuty

-- Per way and buff, so the group isn't asked twice in a row.
local ASK_COOLDOWN = 10
local lastAsked = { group = {}, whisper = {} } -- way -> buff key -> GetTime() of its last ask

--------------------------------------------------------------------------------
-- Counting
--------------------------------------------------------------------------------

-- Less the buffs you can cast yourself: the window's party sections already list who needs those.
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
				-- Shaped like a castable buff for Wants and Has; empty ranks, so any version counts by time left.
				buff = {
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					ranks = {},
					manaOnly = row.manaOnly,
					noCasters = row.noCasters,
				},
				-- BuffDuty.BuildLookup sorts the ranks lowest first; the whisper links the top one.
				linkId = entry.ids[#entry.ids],
				class = row.class,
				talent = row.talent,
				carried = false,
				count = 0,
				names = {}, -- subgroup -> the names missing it there
				classes = {}, -- subgroup -> each of those names' class, in step
				expires = {}, -- subgroup -> when each one's low buff runs out (GetTime), 0 when missing, in step
				durations = {}, -- subgroup -> that low buff's full duration, 0 when missing, in step
			}
		end
	end
	return candidates
end

-- Called after BuildSections, which sets the refresh time Has reads.
function BuffDuty.BuildOtherClassBuffs()
	local summary = {}
	if not IsInGroup() or not ns.db.global.buffWindow.askOtherClasses then
		return summary
	end
	local candidates = Candidates()
	if not candidates[1] then
		return summary
	end

	local buffers = {}
	for _, member in ipairs(BuffDuty.GroupMembers()) do
		local unit = member.unit
		local _, class = UnitClass(unit)
		if class and BuffDuty.CanBuff(unit) then
			local name = GetUnitName(unit, false) or ""
			if not member.isPlayer then
				-- The whisper needs the realm of a player from another one.
				buffers[class] = buffers[class] or {}
				table.insert(buffers[class], GetUnitName(unit, true) or name)
			end
			BuffDuty.ReadAuras(unit)
			local role = BuffDuty.RoleOf(unit, class)
			for _, candidate in ipairs(candidates) do
				local buff = candidate.buff
				candidate.carried = candidate.carried or BuffDuty.Carries(buff)
				local has, lowExpires, lowDuration
				if BuffDuty.Wants(buff, class, role) then
					has, lowExpires, lowDuration = BuffDuty.Has(buff, unit)
				else
					has = true
				end
				if not has then
					candidate.count = candidate.count + 1
					local subgroup = member.subgroup
					local names = candidate.names[subgroup] or {}
					local classes = candidate.classes[subgroup] or {}
					local expires = candidate.expires[subgroup] or {}
					local durations = candidate.durations[subgroup] or {}
					candidate.names[subgroup] = names
					candidate.classes[subgroup] = classes
					candidate.expires[subgroup] = expires
					candidate.durations[subgroup] = durations
					names[#names + 1] = name
					classes[#classes + 1] = class
					expires[#expires + 1] = lowExpires or 0
					durations[#durations + 1] = lowDuration or 0
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
						label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
						names = names,
						classes = candidate.classes[subgroup],
						expires = candidate.expires[subgroup],
						durations = candidate.durations[subgroup],
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
			}
		end
	end
	return summary
end

--------------------------------------------------------------------------------
-- Asking
--------------------------------------------------------------------------------

function ns.CanAskForBuff(way, key)
	local last = lastAsked[way][key]
	return not (last and GetTime() - last < ASK_COOLDOWN)
end

local function ReadyToAsk(way, key)
	if not ns.CanAskForBuff(way, key) then
		return false
	end
	lastAsked[way][key] = GetTime()
	return true
end

function ns.AskGroupForBuff(spec)
	if ReadyToAsk("group", spec.key) then
		ns:SayBuffRequest(spec.missing, spec.count, spec.link)
	end
end

-- An emptied whisper sends nothing. Nothing is printed: the whispers show in your own chat.
function ns.WhisperOtherClassBuff(spec)
	if not spec.recipients[1] or not ReadyToAsk("whisper", spec.key) then
		return
	end
	local message = ns:BuildBuffAskWhisper(ns.GetMessageText("buffAsk"), spec.missing, spec.count, spec.link)
	if not message then
		return
	end
	for _, target in ipairs(spec.recipients) do
		ns:QueueAutomatedWhisper(target, message)
	end
end
