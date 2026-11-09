local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent drops before recording. The dispatcher only ever hands
    LogEvent the events the add-on registers (Core's ns.EVENT_NAMES).
    SPELL_UPDATE_COOLDOWN is dropped outright: it fires on every global
    cooldown and carries no id to classify by, and all it drives is the Buff
    Duty window's cooldown swipes, which show on the window itself. The other
    firehoses are classified per firing below, never dropped.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	SPELL_UPDATE_COOLDOWN = true,
}

--[[
    Events that carry an id worth classifying, and the argument position it
    arrives in, for ns:SuppressUncorrelatedMessage to classify per firing
    rather than drop wholesale. A firing logs in full when a feature
    correlates it (Buff Duty's ns.IsCorrelatedMessage, or Consumable Macros'
    and Rank Watch's checks below), and every other firing is counted.

    - UNIT_SPELLCAST_SUCCEEDED fires for every unit the client tracks, so in a
      group or a city it is a firehose; its id is the spell id.
    - GET_ITEM_INFO_RECEIVED fires for every item any add-on or the game's own
      UI loads, so a bag or auction add-on can send hundreds; its id is the
      item id, and only a consumable's matters.
    - UI_ERROR_MESSAGE fires on every red error the game shows; its id is the
      error type. "A more powerful spell is already active" matters, which
      Buff Duty acts on, and so do the two the consumable macros read by text.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	UNIT_SPELLCAST_SUCCEEDED = 3,
	GET_ITEM_INFO_RECEIVED = 1,
	UI_ERROR_MESSAGE = 1,
}

-- The counter id a secret id (WoW Forever) folds into, since a secret can't key a table.
local SECRET_ID = 0

-- The counter id a gated firehose's ignored firings fold into, with the reason as their text.
local GATED_ID = -1

-- Whether Rank Watch is loaded on this flavor and watching right now (Features/Rank-Watch/Rank-Watch-Core.lua).
local function RankWatchListening()
	return ns.db ~= nil and ns.IsRankWatchActive ~= nil and ns.IsRankWatchActive()
end

-- A Rank Watch rank with a higher one above it, the only casts Rank Watch's detection ever acts on.
local function IsRankWatchReportable(spellID)
	return ns.IsPlain(spellID) and type(spellID) == "number" and ns.RankWatchReportableLookup(spellID) ~= nil
end

--[[
    Rank Watch's correlation, beside Buff Duty's and Consumable Macros': on
    WoW Forever, Features/Rank-Watch/Rank-Watch-Detection-Forever.lua checks
    your own and your pet's UNIT_SPELLCAST_SUCCEEDED for a rank it watches.
]]
local function RankWatchCorrelates(event, id)
	return event == "UNIT_SPELLCAST_SUCCEEDED"
		and ns.FLAVOR == "Camelot"
		and RankWatchListening()
		and IsRankWatchReportable(id)
end

local band = bit.band
local GROUP_AFFILIATION = 0x00000007 -- COMBATLOG_OBJECT_AFFILIATION_MINE, _PARTY and _RAID

-- The combat-log firings a handler acts on, decoded: Buff Duty's resurrects and strangers' buffs, Rank Watch's casts.
local function DecodeCombatLog()
	local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, spellID, spellName, _, auraType =
		CombatLogGetCurrentEventInfo()
	local flags = sourceFlags or 0
	if ns.db ~= nil and ns.IsBuffDutyOnForClass() and ns.IsBuffDutyReady() then
		if subevent == "SPELL_RESURRECT" then
			return { n = 5, "Buff Duty", subevent, sourceName, destName, spellName }
		end
		if
			(subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
			and auraType == "BUFF"
			and sourceGUID
			and sourceGUID ~= destGUID
			and destGUID == UnitGUID("player")
			and band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
			and band(flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) ~= 0
		then
			return { n = 5, "Buff Duty", subevent, sourceName, destName, spellName }
		end
	end
	if
		subevent == "SPELL_CAST_SUCCESS"
		and band(flags, GROUP_AFFILIATION) ~= 0
		and RankWatchListening()
		and IsRankWatchReportable(spellID)
	then
		return { n = 6, "Rank Watch", subevent, sourceName, destName, spellID, spellName }
	end
	return nil
end

-- A group member's unit token, the only bearers Rank Watch's aura detection reads.
local function IsGroupUnit(unit)
	return unit == "player" or unit:find("^party%d$") ~= nil or unit:find("^raid%d+$") ~= nil
end

-- On WoW Forever, the ranks Rank Watch watches among a group member's added auras, each with who cast it.
local function DecodeRankWatchAuras(unit, updateInfo)
	if ns.FLAVOR ~= "Camelot" or not RankWatchListening() then
		return nil
	end
	if not ns.IsPlain(unit) or type(unit) ~= "string" or not IsGroupUnit(unit) then
		return nil
	end
	if ns.AreAurasSecret() or not ns.IsPlain(updateInfo) or type(updateInfo) ~= "table" then
		return nil
	end
	local added = updateInfo.addedAuras
	if not ns.IsPlain(added) or type(added) ~= "table" then
		return nil
	end
	local found = {}
	for _, aura in ipairs(added) do
		if type(aura) == "table" then
			local spellID, source = aura.spellId, aura.sourceUnit
			if ns.IsPlain(source) and type(source) == "string" and IsRankWatchReportable(spellID) then
				found[#found + 1] = spellID .. " from " .. source
			end
		end
	end
	if #found == 0 then
		return nil
	end
	return { n = 3, "Rank Watch", unit, table.concat(found, "; ") }
end

--[[
    Firehoses that carry no id, each with the test its handler makes before
    acting on a firing. A firing the handler would ignore folds into the
    counters under GATED_ID with the reason. One it acts on logs in full, or,
    for an event whose arguments say nothing as text, is written decoded
    through ns:LogEventNow, led by the feature that acts on it.

    - UPDATE_MOUSEOVER_UNIT fires for every unit the cursor crosses, and the
      Spellbook's Features/Enhanced-Spellbook/Dynamic-Rank.lua queues a
      rewrite only while the Spellbook is on, out of combat, and any macro has
      Dynamic Rank on, by its own setting or its kind's default (its
      RanksRewritable), so the test makes those same calls. RanksRewritable's
      last check, a placed macro that tries the mouseover, is private to that
      file, so a firing it would still turn away logs in full rather than
      being lost.
    - COMBAT_LOG_EVENT_UNFILTERED, registered on every flavor but Forever while
      Buff Duty or Rank Watch is on, carries its payload in
      CombatLogGetCurrentEventInfo: Buff Duty acts on a resurrect and on a
      stranger's buff landing on you (Buff-Duty-Events.lua,
      ns.NoteFavorFromCombatLog), Rank Watch on a group member's cast of a
      rank it watches (Rank-Watch-Detection-Combat-Log.lua).
    - UNIT_AURA, registered for every unit while Buff Duty or Rank Watch is on,
      and by Consumable Macros for you and your pet while a macro needs it:
      its update table can't be logged as text. On Forever, Rank Watch reads
      the ranks it watches among a group member's added auras
      (Rank-Watch-Detection-Forever.lua). Consumable Macros logs each firing
      that changes a macro itself (ns.OnUnitAura in Scanner-Auras.lua), and
      the Buff Duty window's reads show on the Buff Duty Context report.
    - CHAT_MSG_ADDON fires for every add-on message any add-on in the group
      sends; Rank Watch reads only its own prefix (Rank-Watch-Cluster.lua).
]]
local GATED_EVENTS = {
	UPDATE_MOUSEOVER_UNIT = {
		reason = "Spellbook off, in combat, or no Dynamic Rank macro",
		acts = function()
			return ns.db ~= nil and ns.IsSpellbookEnabled() and not InCombatLockdown() and ns.AnyTargetRank()
		end,
	},
	COMBAT_LOG_EVENT_UNFILTERED = {
		reason = "not a resurrect, a stranger's buff on you, or a Rank Watch cast",
		decode = DecodeCombatLog,
	},
	UNIT_AURA = {
		reason = "no Rank Watch rank added (Consumable Macros logs its own)",
		decode = DecodeRankWatchAuras,
	},
	CHAT_MSG_ADDON = {
		reason = "another add-on's message",
		acts = function(prefix)
			return RankWatchListening() and ns.IsPlain(prefix) and prefix == ns.Data.RANK_WATCH.COMM_PREFIX
		end,
	},
}

--[[
    Consumable Macros' correlations, beside Buff Duty's
    ns.IsCorrelatedMessage, each the exact test its live handler makes: the
    two errors the consumable macros read by text, ERR_ITEM_WRONG_ZONE
    (Features/Macros-for-Consumables/Macros/Runtime.lua) and SPELL_FAILED_TARGETS_DEAD
    (Features/Macros-for-Consumables/Macros/Tools-Hunters.lua); a consumable's item info,
    which can change a macro (ns.HasRawData); and a cast of the player's that
    changes what a macro holds (ns.SpellCastChangesMacros).
]]
local function ConnoisseurCorrelates(event, id, text)
	if event == "UI_ERROR_MESSAGE" then
		return ns.IsPlain(text) and (text == ERR_ITEM_WRONG_ZONE or text == SPELL_FAILED_TARGETS_DEAD)
	end
	if event == "GET_ITEM_INFO_RECEIVED" then
		return ns.HasRawData(id)
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		return ns.SpellCastChangesMacros(id)
	end
	return false
end

--[[
    Folds one uncorrelated firing into its counter: the first-seen text plus a
    count, rendered as one block at the end of the report. Counters are keyed
    by event, then id, so one id arriving on two events stays two rows. A
    secret id counts under SECRET_ID with the text <secret>. Counts only while
    logging, like ns:LogEventNow.
]]
function ns:CountUncorrelated(event, id, text)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed or not ns.diagnostics.logging then
		return
	end
	if not ns.IsPlain(id) then
		id, text = SECRET_ID, "<secret>"
	elseif not ns.IsPlain(text) then
		text = "<secret>"
	end
	local counters = suppressed[event]
	if not counters then
		counters = {}
		suppressed[event] = counters
	end
	local entry = counters[id]
	if entry then
		entry.count = entry.count + 1
		return
	end
	local raw = string.sub(tostring(text or ""), 1, EVENT_LOG_MAX_ARG_LENGTH)
	counters[id] = { text = (raw:gsub("|", "||")), count = 1 }
end

--[[
    Per-firing filter for the events above. A firing whose id the add-on
    correlates (ns.IsCorrelatedMessage) logs in full; any other folds into its
    counter, so firehose traffic can't evict the entries the log exists to
    carry. A secret id counts too. A plain firing carrying no numeric id in the
    filtered position is unclassifiable, and unclassifiable is signal: it logs
    verbatim. The counter's text is the argument after the id, or blank when
    none follows.

    Returns true when the firing was counted and must not reach the buffer.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local gated = GATED_EVENTS[event]
	if gated and gated.decode then
		local decoded = gated.decode(...)
		if decoded then
			ns:LogEventNow(event, unpack(decoded, 1, decoded.n))
		else
			ns:CountUncorrelated(event, GATED_ID, gated.reason)
		end
		return true
	end
	if gated then
		if gated.acts(...) then
			return false
		end
		ns:CountUncorrelated(event, GATED_ID, gated.reason)
		return true
	end
	local idPosition = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	if not idPosition then
		return false
	end
	local messageID = select(idPosition, ...)
	local text
	if select("#", ...) > idPosition then
		text = select(idPosition + 1, ...)
	end
	if ns.IsPlain(messageID) then
		if type(messageID) ~= "number" then
			return false
		end
		if
			ns.IsCorrelatedMessage(event, messageID)
			or ConnoisseurCorrelates(event, messageID, text)
			or RankWatchCorrelates(event, messageID)
		then
			return false
		end
	end
	ns:CountUncorrelated(event, messageID, text)
	return true
end

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
    One entry in the buffer, for ns:LogEvent and ns:LogEventNow below.
    Snapshots arguments to strings immediately -- never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and per-argument byte length so a single entry can't run away.
    A secret argument (WoW Forever) can't be turned into text, so it records as
    <secret>.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox instead of rendering as a clickable item
    swatch. Escaping last also means the cut can never leave a dangling pipe that
    would eat the following ", " separator.
]]
local function AppendEntry(event, ...)
	local log = ns.diagnostics.log
	if not log then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		local value = select(index, ...)
		if ns.IsPlain(value) then
			local raw = string.sub(tostring(value), 1, EVENT_LOG_MAX_ARG_LENGTH)
			parts[index] = (raw:gsub("|", "||"))
		else
			parts[index] = "<secret>"
		end
	end
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

-- Called by Core's central dispatcher for every event while logging is active.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	if ns:SuppressUncorrelatedMessage(event, ...) then
		return
	end
	AppendEntry(event, ...)
end

--[[
    The way back in for an excluded firehose that is sometimes signal: the
    handler that decides a firing mattered calls this with the event and its
    arguments, and it is recorded as the dispatcher would have, past the
    exclude list. Feature code calls it, so it carries the dispatcher's own
    single boolean check before any work.
]]
function ns:LogEventNow(event, ...)
	if not ns.diagnostics.logging then
		return
	end
	AppendEntry(event, ...)
end

--[[
    Renders the suppressed-traffic counters as one compact block, biggest
    offender first. This is also how a tester discovers a message id the add-on
    should be correlating but isn't.
]]
local function AppendSuppressedSummary(lines)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local rows = {}
	for event, counters in pairs(suppressed) do
		for id, entry in pairs(counters) do
			rows[#rows + 1] = { event = event, id = id, entry = entry }
		end
	end
	if #rows == 0 then
		return
	end
	table.sort(rows, function(a, b)
		if a.entry.count ~= b.entry.count then
			return a.entry.count > b.entry.count
		end
		if a.event ~= b.event then
			return a.event < b.event
		end
		return a.id < b.id
	end)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Suppressed uncorrelated traffic:"
	for _, row in ipairs(rows) do
		if row.id == SECRET_ID then
			lines[#lines + 1] = string.format("%s(<secret>) x%d", row.event, row.entry.count)
		else
			lines[#lines + 1] = string.format("%s(%d, %s) x%d", row.event, row.id, row.entry.text, row.entry.count)
		end
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	AppendSuppressedSummary(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
    The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
    both blocked actions and accesses to tainted globals; 0 is off. This is the
    only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
