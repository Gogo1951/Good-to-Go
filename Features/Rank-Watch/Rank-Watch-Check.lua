local _, ns = ...
local L = ns.L
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH

--------------------------------------------------------------------------------
-- Rank Watch Check
--------------------------------------------------------------------------------

--[[
    One cast, seen by a Rank-Watch-Detection file, judged here: was it a rank lower than the caster could have
    cast, and if so, who hears about it.

    A cast is low when its ladder has a higher rank learned at or under its ceiling, the lowest of:
      - the caster's level, less the grace period: Grace Period at Max Level for an owner at the cap (0 by
        default), Grace Period While Leveling below it (4), so a rank the caster only just reached waits for
        their next trainer visit;
      - the level they were first seen at this session, less the same grace period, so a player who levels
        mid-session isn't told about the rank that level just brought before they've had a chance to train it;
      - the recipient's level plus Data.RANK_WATCH.TARGET_LEVEL_RANGE, for a cast on someone else. The game
        lowers a buff's rank on its own to fit a low-level target, so a rank lowered for a lowbie is never
        reported. Detection passes the recipient's level only when it knows the cast landed on another friendly
        player, and drops the cast outright when it can't tell how low that player is.

    Once per caster and ladder a session, and once per caster, level and spell for good (settings.announced,
    shared through NOTIFY with every Rank Watch and Rank Sentinel in the group).
]]

local session = {
	firstLevel = {}, -- caster GUID -> level first seen at this session
	notified = {}, -- "<caster GUID>:<ladder ID>" -> true
	queue = {}, -- whispers held for combat, death or a busy target
}

function ns.ResetRankWatchSession()
	wipe(session.firstLevel)
	wipe(session.notified)
	wipe(session.queue)
end

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- "[Arcane Intellect] (Rank 3)", or the name alone where the client can't build a link.
local function RankLink(row, withLink)
	local name = withLink and ns.GetSpellLink(row.id) or C_Spell.GetSpellName(row.id) or tostring(row.id)
	return L["RANK_WATCH_SPELL_RANK"]:format(name, ns.RankWatchRankText(row))
end

--[[
    A pet as its owner's messages name it: { name, isDemon }. A hunter pet by its own name ("your pet Fluffy"),
    a demon by its kind ("your Imp"), since a warlock rarely knows their demon's name.
]]
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

-- The key for a message, its pet form when a pet cast: RANK_WATCH_PRINT_SELF, _PET or _DEMON.
local function MessageKey(key, pet)
	return pet and (key .. (pet.isDemon and "_DEMON" or "_PET")) or key
end

--[[
    The whisper, led by the marker, never over the chat ceiling: the cast linked, then its name alone. It is
    never cut, since a cut could break a link. A pet's whisper names the pet first.
]]
function ns.BuildRankWatchWhisper(castRow, betterRow, pet)
	local key = MessageKey("RANK_WATCH_MESSAGE_WHISPER", pet)
	local message
	for _, withLink in ipairs({ true, false }) do
		if pet then
			message = ns:BuildWhisperMessage(key, pet.name, RankLink(castRow, withLink), betterRow.level)
		else
			message = ns:BuildWhisperMessage(key, RankLink(castRow, withLink), betterRow.level)
		end
		if #message <= ns.CHAT_MESSAGE_MAX_LENGTH then
			return message
		end
	end
	return message
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
    Whispers wait while the player is in combat or dead, and while their target is in combat, as the standalone
    add-on's did; a whisper mid-pull is noise the reader can't act on. They go out through the add-on's shared
    whisper queue, a beat apart from every other whisper, so a burst never trips the server's chat squelch.
    A whisper also waits for the client's text for the rank it names (ns.RankWatchHasRankText), and is built
    only then: the data's number can disagree with the reader's spellbook. After RANK_TEXT_TRIES tries a
    second apart it is dropped rather than sent with that number.
]]
local RANK_TEXT_RETRY = 1
local RANK_TEXT_TRIES = 10

local retryArmed = false

--[[
    The first whisper a player ever gets from this account is followed by a second one with their opt-out number:
    say it and they go on Ignored Players. Once per player for good (settings.optOutOffered), so nobody is told
    twice.

    The number is made from the player's name alone (ns.RankWatchOptOutCode), so every copy of Good to Go
    works out the same one: a player told it by one person can say it to anyone else running Rank Watch. It
    counts from that player only, in a whisper or any chat this client hears, at any time.
]]
local codes = {} -- short name -> its opt-out number, as a string

-- A player's four-digit opt-out number, 1000 to 9999, from their name without its realm.
function ns.RankWatchOptOutCode(name)
	local short = Ambiguate(name, "short")
	local code = codes[short]
	if not code then
		local hash = 5381
		for index = 1, #short do
			hash = (hash * 33 + short:byte(index)) % 2147483647
		end
		code = tostring(1000 + hash % 9000)
		codes[short] = code
	end
	return code
end

function ns.BuildRankWatchOptOutWhisper(name)
	return ns:BuildWhisperMessage("RANK_WATCH_MESSAGE_OPT_OUT", ns.RankWatchOptOutCode(name))
end

local function OfferOptOut(guid, target)
	local offered = ns.RankWatchSettings().optOutOffered
	if offered[guid] then
		return
	end
	offered[guid] = true
	ns:QueueAutomatedWhisper(target, ns.BuildRankWatchOptOutWhisper(target))
end

--[[
    Whether a line says the number as a word of its own: "4821", "4821!", "ok 4821", never "48210" or "4821g".
    Links and color codes are dropped first, so a spell or item ID inside one never counts.
]]
local function SaysCode(text, code)
	local plain = text:gsub("|H.-|h(.-)|h", "%1"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	return plain:find("%f[%w]" .. code .. "%f[%W]") ~= nil
end

local function OnChatMessage(isWhisper, text, sender, ...)
	local guid = select(10, ...)
	if not ns.IsPlain(text) or not ns.IsPlain(sender) or not ns.IsPlain(guid) then
		return
	end
	if not text or not sender or sender == "" or not guid or guid == UnitGUID("player") then
		return
	end
	local settings = ns.RankWatchSettings()
	if settings.ignoredPlayers[guid] or not ns.IsPlayerGUID(guid) or not text:find("%d%d%d%d") then
		return
	end
	if not SaysCode(text, ns.RankWatchOptOutCode(sender)) then
		return
	end
	local name = Ambiguate(sender, "none")
	local _, class = GetPlayerInfoByGUID(guid)
	class = ns.IsPlain(class) and class or nil
	settings.ignoredPlayers[guid] = name
	settings.ignoredClasses[guid] = class
	-- Only a whisper is answered: said in group chat, every Rank Watch in the group would answer at once.
	if isWhisper then
		ns:QueueAutomatedWhisper(sender, ns:BuildWhisperMessage("RANK_WATCH_MESSAGE_OPT_OUT_DONE"))
	end
	ns:PrintMessage(L["RANK_WATCH_OPT_OUT_ADDED"]:format(ns.ClassColoredName(name, class)))
	LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.RankWatchIgnored)
end

for _, event in ipairs(ns.RANK_WATCH_CHAT_EVENTS) do
	local isWhisper = event == "CHAT_MSG_WHISPER"
	ns.SetRankWatchHandler(event, function(...)
		OnChatMessage(isWhisper, ...)
	end)
end

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
	for _, whisper in ipairs(session.queue) do
		local unit = ns.GetUnitByGUID(whisper.guid)
		if unit and UnitAffectingCombat(unit) then
			held[#held + 1] = whisper
			retry = retry or RANK_WATCH.TARGET_BUSY_RETRY
		elseif not ns.RankWatchHasRankText(whisper.castRow) then
			whisper.tries = whisper.tries + 1
			if whisper.tries < RANK_TEXT_TRIES then
				held[#held + 1] = whisper
				retry = RANK_TEXT_RETRY
			end
		else
			local message = ns.BuildRankWatchWhisper(whisper.castRow, whisper.betterRow, whisper.pet)
			ns:QueueAutomatedWhisper(whisper.target, message)
			OfferOptOut(whisper.guid, whisper.target)
		end
	end
	session.queue = held
	if retry then
		ArmRetry(retry)
	end
end

local function QueueWhisper(guid, target, castRow, betterRow, pet)
	session.queue[#session.queue + 1] =
		{ guid = guid, target = target, castRow = castRow, betterRow = betterRow, pet = pet, tries = 0 }
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

-- The name a whisper reaches: the whole name on WoW Forever, Name-Realm across realms elsewhere.
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

-- A unit's level, or nil when it can't be read; the detection files read recipients' levels through it too.
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
    cast = { guid, unit, spellID, recipientLevel, petUnit, petGUID }: the caster's GUID and a unit token holding
    them now, the spell cast, and the level of the friendly player it landed on when that was someone else (nil
    otherwise). A pet's cast names its owner as the caster, with the pet's own unit and GUID beside: the pet's
    level is the ceiling, since a hunter pet can trail its hunter, and the owner is the one ignored, whose level
    picks the grace period, and told.
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
