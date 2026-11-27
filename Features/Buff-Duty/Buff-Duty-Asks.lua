local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    A talent buff (Divine Spirit) is asked for only once the target carries it,
    which shows they can cast it. Never a noAsk buff, which its caster keeps
    for one player at a time (Fear Ward, Earth Shield).
]]

local BuffDuty = ns.BuffDuty
-- a secret answer on WoW Forever counts as no, rather than erroring when tested
local Yes = ns.IsPlainYes

-- Per player and buff.
local ASK_COOLDOWN = 300
BuffDuty.ASK_TARGET_COOLDOWN = ASK_COOLDOWN

local asked = {} -- "<GUID>:<buff key>" -> GetTime() of the ask

--------------------------------------------------------------------------------
-- Cooldown
--------------------------------------------------------------------------------

local function AskKey(guid, key)
	return guid .. ":" .. key
end

function BuffDuty.AskedAt(guid, key)
	local at = asked[AskKey(guid, key)]
	if at and GetTime() - at < ASK_COOLDOWN then
		return at
	end
	return nil
end

function BuffDuty.CanAskTarget(spec)
	local ask = spec and spec.ask
	return ask ~= nil and not InCombatLockdown() and not BuffDuty.AskedAt(ask.guid, spec.askKey)
end

--------------------------------------------------------------------------------
-- Which Buffs
--------------------------------------------------------------------------------

local function Approachable(unit)
	return not Yes(UnitAffectingCombat(unit))
		and not Yes(UnitAffectingCombat("player"))
		and not Yes(UnitIsAFK(unit))
		and not (UnitIsDND and Yes(UnitIsDND(unit)))
end

-- An unknown level (UnitLevel's -1) may have learned it.
local function LevelAllows(entry, level)
	local lowest = entry.ranks[1]
	if not lowest or not ns.IsPlain(level) or not level or level <= 0 then
		return true
	end
	return level >= lowest.level
end

-- Shaped like a castable buff for Wants and Has; empty ranks, so any version counts by time left.
local function Candidates(class, level)
	local audience = ns.db.global.buffWindow.audience
	local candidates = {}
	for _, entry in ipairs(BuffDuty.entries) do
		local row = entry.row
		local who = audience[entry.key]
		if
			row.class == class
			and not row.noAsk
			and who
			and who ~= Data.BUFF_AUDIENCE.OFF
			and LevelAllows(entry, level)
		then
			candidates[#candidates + 1] = {
				entry = entry,
				buff = {
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					ranks = {},
					manaOnly = row.manaOnly,
					noCasters = row.noCasters,
				},
			}
		end
	end
	return candidates
end

-- Called while BuildSections runs, which sets the refresh time Has reads.
function BuffDuty.TargetAskRow(class, short)
	local db = ns.db.global.buffWindow
	if not db.askTarget or not class then
		return nil
	end
	local _, playerClass = UnitClass("player")
	if class == playerClass or not Approachable("target") then
		return nil
	end
	local guid = UnitGUID("target")
	local fullName = GetUnitName("target", true)
	if not (ns.IsPlain(guid) and guid and ns.IsPlain(fullName) and fullName) then
		return nil
	end
	local candidates = Candidates(class, UnitLevel("target"))
	if not candidates[1] then
		return nil
	end

	-- What they carry first: a talent buff is only theirs to give once it's on them.
	BuffDuty.ReadAuras("target")
	for _, candidate in ipairs(candidates) do
		candidate.carried = BuffDuty.Carries(candidate.buff)
	end

	BuffDuty.ReadAuras("player")
	local role = BuffDuty.RoleOf("player", playerClass)
	-- Shared by the row's icons: a click on any one asks for all of them.
	local ask = { guid = guid, name = fullName, short = short, specs = {} }
	local picked = {} -- exclusive family -> true once one of it is on the row
	for _, candidate in ipairs(candidates) do
		local entry, buff = candidate.entry, candidate.buff
		local family = entry.row.exclusive
		if
			(candidate.carried or not entry.row.talent)
			and not (family and picked[family])
			and BuffDuty.Wants(buff, playerClass, role)
		then
			local has, expires, duration = BuffDuty.Has(buff, "player")
			if not has then
				if family then
					picked[family] = true
				end
				-- The top rank: ids are sorted lowest first.
				local spellId = entry.ids[#entry.ids]
				ask.specs[#ask.specs + 1] = BuffDuty.WithTimeLeft({
					ask = ask,
					askKey = buff.key,
					buffKey = buff.key,
					spellId = spellId,
					spellName = C_Spell.GetSpellName(spellId),
					column = #ask.specs + 1,
					unit = "target",
					targetName = short,
				}, expires, duration)
			end
		end
	end
	if not ask.specs[1] then
		return nil
	end
	local label =
		L["BUFF_DUTY_ASK_TARGET_ROW"]:format((ns.GetClassColor(class) or ns.GetColor("TEXT")) .. short .. "|r")
	-- A grid of its own: its columns are their class's buffs, not the ones you cast.
	return { label = label, icons = ask.specs, grid = "ask" }
end

--------------------------------------------------------------------------------
-- Asking
--------------------------------------------------------------------------------

-- Returns whether it sent. An emptied whisper sends nothing; nothing is printed, since the whisper shows in chat.
function ns.AskTargetForBuffs(spec)
	local ask = spec and spec.ask
	if not ask or InCombatLockdown() then
		return false
	end
	local guid = UnitGUID("target")
	if not ns.IsPlain(guid) or guid ~= ask.guid then
		return false
	end
	local links, names, keys = {}, {}, {}
	for _, icon in ipairs(ask.specs) do
		if not BuffDuty.AskedAt(ask.guid, icon.askKey) then
			names[#names + 1] = icon.spellName or ""
			links[#links + 1] = ns.GetSpellLink(icon.spellId) or names[#names]
			keys[#keys + 1] = icon.askKey
		end
	end
	if not keys[1] then
		return false
	end
	local template = ns.GetMessageText("buffAskTarget")
	local message = ns:BuildBuffAskTargetWhisper(template, ask.short, links)
		or ns:BuildBuffAskTargetWhisper(template, ask.short, names)
	if not message then
		return false
	end
	local now = GetTime()
	for _, key in ipairs(keys) do
		asked[AskKey(ask.guid, key)] = now
	end
	ns:QueueAutomatedWhisper(ask.name, message)
	ns.UpdateBuffDutyCooldowns()
	return true
end
