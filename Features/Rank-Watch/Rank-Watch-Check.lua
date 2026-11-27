local _, ns = ...
local L = ns.L
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH

--------------------------------------------------------------------------------
-- Rank Watch Check
--------------------------------------------------------------------------------

--[[
    A cast is low when its ladder has a higher rank learned at or under its ceiling, the lowest of:
      - the caster's level, less the grace period: Grace Period at Max Level for an owner at the cap (0 by
        default), Grace Period While Leveling below it (4), so a rank the caster only just reached waits for
        their next trainer visit;
      - the level they were first seen at this session, less the same grace period, so a player who levels
        mid-session isn't told about the rank that level just brought before they've had a chance to train it;
      - the recipient's level plus Data.RANK_WATCH.TARGET_LEVEL_RANGE, for a cast on someone else. The game
        lowers a buff's rank on its own to fit a low-level target, so a rank lowered for a lowbie is never
        reported. Detection passes the recipient's level only when it knows the cast landed on another friendly
        player or a group member's pet, and drops the cast outright when it can't tell how low that recipient is.

    Once per caster and ladder a session, and once per caster, level and spell until the next version (settings.announced,
    shared through NOTIFY with every Rank Watch and Rank Sentinel in the group).
]]

local session = {
	firstLevel = {}, -- caster GUID -> level first seen at this session
	notified = {}, -- "<caster GUID>:<ladder ID>" -> true
	queue = {}, -- whispers held for combat, death or a busy target
	reminders = {}, -- caster GUID -> reminders whispered to them
	offered = {}, -- caster GUID -> true, sent the opt-out offer
}

function ns.ResetRankWatchSession()
	wipe(session.firstLevel)
	wipe(session.notified)
	wipe(session.queue)
	wipe(session.reminders)
	wipe(session.offered)
end

-- So no held whisper goes out after Rank Watch is switched off and on again.
function ns.ClearRankWatchQueue()
	wipe(session.queue)
end

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- "[Arcane Intellect] (Rank 3)", or the name alone where the client can't build a link or `withLink` is false.
function ns.RankWatchSpellText(row, withLink)
	local name = withLink and ns.GetSpellLink(row.id) or C_Spell.GetSpellName(row.id) or tostring(row.id)
	return L["NAME_WITH_DETAIL_FORMAT"]:format(name, ns.RankWatchRankText(row))
end

local RankLink = ns.RankWatchSpellText

-- A demon by its kind ("your Imp"), since a warlock rarely knows their demon's name.
function ns.RankWatchPetInfo(ladder, petUnit)
	local isDemon = ladder.class == "WARLOCK"
	local name = isDemon and UnitCreatureFamily(petUnit) or UnitName(petUnit)
	if not ns.IsPlain(name) or not name or name == "" then
		name = UnitName(petUnit)
	end
	if not ns.IsPlain(name) or not name then
		name = ""
	end
	return { name = name, isDemon = isDemon }
end

local function MessageKey(key, pet)
	return pet and (key .. (pet.isDemon and "_DEMON" or "_PET")) or key
end

-- nil for the caster's own, "pet" or "demon" for a pet's.
function ns.RankWatchTipForm(pet)
	return pet and (pet.isDemon and "demon" or "pet") or nil
end

-- Nil when the player emptied the form's text.
function ns.BuildRankWatchWhisper(castRow, betterRow, pet)
	local form = ns.RankWatchTipForm(pet)
	return ns:BuildRankWatchTipWhisper(
		form,
		ns.GetMessageText(ns.RankWatchTipField(form)),
		RankLink(castRow, true),
		RankLink(castRow, false),
		betterRow.level,
		pet and pet.name
	)
end

function ns.BuildRankWatchSelfLine(castRow, betterRow, pet)
	local cast, better = RankLink(castRow, true), RankLink(betterRow, true)
	if pet then
		return L[MessageKey("RANK_WATCH_PRINT_SELF", pet)]:format(pet.name, cast, better, betterRow.level)
	end
	return L["RANK_WATCH_PRINT_SELF"]:format(cast, better, betterRow.level)
end

function ns.BuildRankWatchOtherLine(name, castRow, betterRow, whisperer, pet)
	local cast, better = RankLink(castRow, true), RankLink(betterRow, true)
	local line
	if pet then
		line = L[MessageKey("RANK_WATCH_PRINT_OTHER", pet)]:format(name, pet.name, cast, better, betterRow.level)
	else
		line = L["RANK_WATCH_PRINT_OTHER"]:format(name, cast, better, betterRow.level)
	end
	if whisperer then
		line = line .. " " .. L["RANK_WATCH_PRINT_WHISPERER"]:format(whisperer)
	end
	return line
end

--------------------------------------------------------------------------------
-- Whispers
--------------------------------------------------------------------------------

--[[
    Held in combat, while dead, or while the recipient fights: a whisper
    mid-pull is noise the reader can't act on. Built only once the client's
    rank text is in, since the data's number can disagree with the reader's
    spellbook; after RANK_TEXT_TRIES (timed from the first check, so combat
    doesn't use it up) it is dropped rather than sent with that number. Each
    is checked again as it would go: ignored since, Whisper off, or another
    copy leading drops it.
]]
local RANK_TEXT_RETRY = 1
local RANK_TEXT_TRIES = 10

local retryArmed = false

--[[
    The offer follows a player's second reminder, never the first, so a
    player told once isn't asked to do anything. Only a group member's
    whisper counts: a stranger in Trade has nothing to opt out of.
]]
local OPT_OUT_WORDS = "opt out"

-- Nil when the player emptied it.
function ns.BuildRankWatchOptOutWhisper()
	return ns:BuildOptOutOfferWhisper(ns.GetMessageText("rankWatchOptOut"))
end

local function AfterReminder(guid, target)
	local count = (session.reminders[guid] or 0) + 1
	session.reminders[guid] = count
	if count < 2 or session.offered[guid] then
		return
	end
	local message = ns.BuildRankWatchOptOutWhisper()
	if message then
		session.offered[guid] = true
		ns:QueueAutomatedWhisper(target, message)
	end
end

-- "Opt Out", "opt out", " OPT OUT ", never "opt out please".
local function SaysOptOut(text)
	return text:match("^%s*(.-)%s*$"):lower() == OPT_OUT_WORDS
end

local function OnChatMsgWhisper(text, sender, ...)
	local guid = select(10, ...)
	if not ns.IsPlain(text) or not ns.IsPlain(sender) or not ns.IsPlain(guid) then
		return
	end
	if not text or not sender or sender == "" or not guid or guid == UnitGUID("player") then
		return
	end
	local settings = ns.RankWatchSettings()
	if settings.ignoredPlayers[guid] or not ns.IsPlayerGUID(guid) or not SaysOptOut(text) then
		return
	end
	-- A party or raid unit, not someone only targeted, focused or under the mouse.
	local unit = ns.GetUnitByGUID(guid)
	if not unit or not (unit:find("^party") or unit:find("^raid")) then
		return
	end
	local name = Ambiguate(sender, "none")
	local _, class = GetPlayerInfoByGUID(guid)
	class = ns.IsPlain(class) and class or nil
	settings.ignoredPlayers[guid] = name
	settings.ignoredClasses[guid] = class
	ns:QueueAutomatedWhisper(sender, ns:BuildOptOutDoneWhisper(ns.GetMessageText("rankWatchOptOutDone")))
	ns:PrintMessage(L["RANK_WATCH_OPT_OUT_ADDED"]:format(ns.ClassColoredName(name, class)))
	ns.RefreshSettings()
end
ns.SetRankWatchHandler("CHAT_MSG_WHISPER", OnChatMsgWhisper)

local function ArmRetry(seconds)
	if retryArmed then
		return
	end
	retryArmed = true
	C_Timer.After(seconds, function()
		retryArmed = false
		ns.ProcessRankWatchQueue()
	end)
end

function ns.ProcessRankWatchQueue()
	if #session.queue == 0 or not ns.IsRankWatchActive() then
		return
	end
	if InCombatLockdown() or UnitIsDeadOrGhost("player") then
		return
	end
	local held, retry = {}, nil
	local settings = ns.RankWatchSettings()
	local whispering = ns.RankWatchWhisperer() == "self"
	for _, whisper in ipairs(session.queue) do
		if whispering and not settings.ignoredPlayers[whisper.guid] then
			local unit = ns.GetUnitByGUID(whisper.guid)
			if unit and UnitAffectingCombat(unit) then
				held[#held + 1] = whisper
				retry = retry or RANK_WATCH.TARGET_BUSY_RETRY
			elseif not ns.RankWatchHasRankText(whisper.castRow) then
				whisper.firstTry = whisper.firstTry or GetTime()
				if GetTime() - whisper.firstTry < RANK_TEXT_TRIES * RANK_TEXT_RETRY then
					held[#held + 1] = whisper
					retry = RANK_TEXT_RETRY
				end
			else
				local message = ns.BuildRankWatchWhisper(whisper.castRow, whisper.betterRow, whisper.pet)
				-- An emptied tip sends nothing, and so counts toward no opt-out offer either.
				if message then
					ns:QueueAutomatedWhisper(whisper.target, message)
					AfterReminder(whisper.guid, whisper.target)
				end
			end
		end
	end
	session.queue = held
	if retry then
		ArmRetry(retry)
	end
end

local function QueueWhisper(guid, target, castRow, betterRow, pet)
	session.queue[#session.queue + 1] =
		{ guid = guid, target = target, castRow = castRow, betterRow = betterRow, pet = pet }
	ns.ProcessRankWatchQueue()
end

-- After combat or a release, held whispers wait a few seconds more, so they don't land mid-loot or mid-rez.
local function ProcessQueueSoon()
	C_Timer.After(RANK_WATCH.AFTER_COMBAT, ns.ProcessRankWatchQueue)
end

local function OnPlayerRegenEnabled()
	ProcessQueueSoon()
end

local function OnPlayerAlive()
	ProcessQueueSoon()
end

local function OnPlayerUnghost()
	ProcessQueueSoon()
end

ns.SetRankWatchHandler("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)
ns.SetRankWatchHandler("PLAYER_ALIVE", OnPlayerAlive)
ns.SetRankWatchHandler("PLAYER_UNGHOST", OnPlayerUnghost)

--------------------------------------------------------------------------------
-- The Check
--------------------------------------------------------------------------------

-- The whole name on WoW Forever, Name-Realm across realms elsewhere.
local function WhisperName(unit, guid)
	local name = GetUnitName(unit, true)
	if ns.IsPlain(name) and name and name ~= "" then
		return name
	end
	local _, _, _, _, _, guidName, realm = GetPlayerInfoByGUID(guid)
	if ns.IsPlain(guidName) and guidName then
		if realm and realm ~= "" then
			return guidName .. "-" .. realm
		end
		return guidName
	end
	return nil
end

local function Ceiling(guid, casterLevel, recipientLevel, grace)
	session.firstLevel[guid] = session.firstLevel[guid] or casterLevel
	local ceiling = math.min(casterLevel, session.firstLevel[guid]) - grace
	if recipientLevel then
		ceiling = math.min(ceiling, recipientLevel + RANK_WATCH.TARGET_LEVEL_RANGE)
	end
	return ceiling
end

-- Nil when it can't be read.
function ns.RankWatchUnitLevel(unit)
	if not unit or ns.IsUnitIdentitySecret(unit) then
		return nil
	end
	local level = UnitLevel(unit)
	if not ns.IsPlain(level) or not level or level <= 0 then
		return nil
	end
	return level
end

--[[
    cast = { guid, unit, spellID, recipientLevel, petUnit, petGUID }; recipientLevel only for a cast on
    someone else. A pet's cast names its owner: the pet's level is the ceiling, since a hunter pet can trail
    its hunter, while the owner picks the grace period, is ignored, and is told.
]]
function ns.CheckRankWatchCast(cast)
	local settings = ns.RankWatchSettings()
	local lookup = ns.RankWatchLookup(cast.spellID)
	if not lookup or not ns.IsRankWatchActive() or not ns.IsRankWatchRankTracked(lookup.ladder.rows[lookup.index]) then
		return
	end
	local ladder = lookup.ladder
	if (ladder.isPet and true or false) ~= (cast.petUnit ~= nil) then
		return
	end
	local guid, unit = cast.guid, cast.unit
	if not ns.IsPlayerGUID(guid) or settings.ignoredPlayers[guid] or ns.IsInPvPInstance() then
		return
	end
	if ns.IsPlainTrue(UnitIsCharmed(unit)) or ns.IsPlainTrue(UnitIsEnemy("player", unit)) then
		return
	end

	local ownerLevel = ns.RankWatchUnitLevel(unit)
	if not ownerLevel then
		return
	end
	local grace = ownerLevel >= ns.GetMaxPlayerLevel() and settings.graceMaxLevel or settings.graceLeveling
	local casterGUID, casterLevel = guid, ownerLevel
	if cast.petUnit then
		casterGUID, casterLevel = cast.petGUID, ns.RankWatchUnitLevel(cast.petUnit)
		if not casterLevel then
			return
		end
	end

	local best = ns.RankWatchBestIndex(ladder, Ceiling(casterGUID, casterLevel, cast.recipientLevel, grace))
	if not best or best <= lookup.index then
		return
	end

	local ladderKey = guid .. ":" .. ladder.id
	local announcedKey = guid .. "-" .. casterLevel .. "-" .. cast.spellID
	if session.notified[ladderKey] or settings.announced[announcedKey] then
		return
	end
	session.notified[ladderKey] = true
	settings.announced[announcedKey] = true
	ns.BroadcastRankWatchNotify(announcedKey)

	local castRow, betterRow = ladder.rows[lookup.index], ladder.rows[best]
	local pet = cast.petUnit and ns.RankWatchPetInfo(ladder, cast.petUnit) or nil
	local isPlayer = guid == UnitGUID("player")
	local shortName = UnitName(unit)
	local _, casterClass = UnitClass(unit)

	if isPlayer then
		ns:PrintMessage(ns.BuildRankWatchSelfLine(castRow, betterRow, pet))
		return
	end

	local whisperer = ns.RankWatchWhisperer()
	local target = whisperer == "self" and WhisperName(unit, guid)
	if target then
		QueueWhisper(guid, target, castRow, betterRow, pet)
	end
	if settings.print then
		local other = whisperer ~= "self" and whisperer or nil
		local name = ns.ClassColoredName(shortName, ns.IsPlain(casterClass) and casterClass or nil)
		ns:PrintMessage(ns.BuildRankWatchOtherLine(name, castRow, betterRow, other, pet))
	end
end
