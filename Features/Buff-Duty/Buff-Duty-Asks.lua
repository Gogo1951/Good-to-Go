local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    Ask Your Target for Buffs: Return the Favor the other way round. When your
    target is a player outside your group whose class casts a buff you're
    missing, the Target section lists it on a row of its own, "Ask Kiib",
    and a click on one of its icons, or the Buff Key, whispers them a polite
    ask naming every buff on the row: "Hey Mate, any chance I could snag a
    [Fortitude] or [Shadow Protection]? Pretty please // GtG".

    What counts as one they can give: a buff of their class with a
    single-target version, that your own Who Gets It setting offers you (a
    buff set to Tanks only while you count as one), that you lack or have
    running under Refresh Under, and whose lowest rank their level has
    reached. A talent buff (Divine Spirit) only once they carry it
    themselves, which shows they can cast it. One Blessing at most, the
    first your settings want. Your own class's buffs are yours to cast, so
    they're never asked for, nor is a buff its caster keeps for one player
    at a time (noAsk: Fear Ward, Earth Shield).

    Manners: no ask while either of you is in combat, or while they're AFK
    or DND, and each player is asked for each buff at most once every
    ASK_COOLDOWN; the icon shows the wait as a cooldown swipe. Nothing is
    printed: the whisper itself shows in your chat.
]]

local BuffDuty = ns.BuffDuty
-- a secret answer on WoW Forever counts as no, rather than erroring when tested
local Yes = ns.IsPlainYes

-- How long a player waits before they can be asked for the same buff again.
local ASK_COOLDOWN = 300
BuffDuty.ASK_TARGET_COOLDOWN = ASK_COOLDOWN

local asked = {} -- "<GUID>:<buff key>" -> GetTime() of the ask

--------------------------------------------------------------------------------
-- Cooldown
--------------------------------------------------------------------------------

local function AskKey(guid, key)
	return guid .. ":" .. key
end

-- When this player was asked for this buff, while that was under ASK_COOLDOWN ago; otherwise nil.
function BuffDuty.AskedAt(guid, key)
	local at = asked[AskKey(guid, key)]
	if at and GetTime() - at < ASK_COOLDOWN then
		return at
	end
	return nil
end

-- Whether an ask icon's buff can be asked for now. The Buff Key passes over one that can't.
function BuffDuty.CanAskTarget(spec)
	local ask = spec and spec.ask
	return ask ~= nil and not InCombatLockdown() and not BuffDuty.AskedAt(ask.guid, spec.askKey)
end

--------------------------------------------------------------------------------
-- Which Buffs
--------------------------------------------------------------------------------

-- Not now: someone fighting, away or busy isn't asked for anything.
local function Approachable(unit)
	return not Yes(UnitAffectingCombat(unit))
		and not Yes(UnitAffectingCombat("player"))
		and not Yes(UnitIsAFK(unit))
		and not (UnitIsDND and Yes(UnitIsDND(unit)))
end

-- Whether a player of `level` has learned the buff's lowest rank (BuffDuty.BuildLookup sorts them); an unknown level (UnitLevel's -1) may have.
local function LevelAllows(entry, level)
	local lowest = entry.ranks[1]
	if not lowest or not ns.IsPlain(level) or not level or level <= 0 then
		return true
	end
	return level >= lowest.level
end

--[[
    Every buff of `class` your settings offer anyone, shaped like a castable
    buff so Wants and Has can read it. No ranks of yours to weigh theirs
    against, so any version on you counts, by its time left.
]]
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

--[[
    The Target section's ask row for your target, or nil when there is
    nothing to ask them for. `class` and `short` are theirs. Asked while
    BuildSections runs, which sets the Refresh Under time Has reads.
]]
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
				-- The top rank (the ids are sorted lowest first), for the icon, its tooltip and the whisper's link.
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

--[[
    An ask icon's click and the Buff Key: one whisper naming every buff on
    the row not asked for in the last ASK_COOLDOWN, in the player's own
    words (the Buff Duty panel's composer) or the chosen language's default.
    Linked buffs that won't fit the chat ceiling go by name instead. An
    emptied whisper sends nothing. Only while they're still your target,
    out of combat. Returns whether it sent.
]]
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
	-- The wait shows at once as each icon's cooldown swipe.
	ns.UpdateBuffDutyCooldowns()
	return true
end
