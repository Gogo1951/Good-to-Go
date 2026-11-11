local _, ns = ...
local L = ns.L

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Print Outs (Player Only)
--------------------------------------------------------------------------------

-- The "Good to Go // " brand that opens every print: the Full Name, never the Short Name.
local function GetPrintPrefix()
	return GetColor("INFO") .. L["ADDON_TITLE"] .. "|r " .. GetColor("SEPARATOR") .. "//" .. "|r "
end

--[[
    A player-only print as chat will show it, without printing it, so the
    options panels' Example lines draw exactly what chat shows. The body is
    white; colors a message embeds (links, class-colored names) sit inside it.
]]
function ns.BuildPrintLine(text)
	return GetPrintPrefix() .. GetColor("TEXT") .. text .. "|r"
end

-- Format: |cff[INFO]Good to Go|r |cff[SEPARATOR]//|r |cff[TEXT]Message|r
function ns:PrintMessage(message)
	print(ns.BuildPrintLine(message))
end

local warned = {}

-- Prints a config problem once per session: once per key, or per message when no key is given.
function ns.WarnOnce(message, key)
	key = key or message
	if warned[key] then
		return
	end
	warned[key] = true
	ns:PrintMessage(message)
end

--------------------------------------------------------------------------------
-- Sent Messages (Other Players)
--------------------------------------------------------------------------------

--[[
    Branded sent messages -- Rank Watch's whispers and Buff Duty's buff asks:
    {rt1} Message // GtG. The body carries a spell link, and MarkerPrefix adds
    the leading raid-target marker; the chat system renders both on send (the
    marker becomes the Star icon), so the pipes and braces pass through unchanged. WoW Forever blocks
    raid-marker tokens in group and channel chat but allows them in whispers, so
    there the marker leads whispers only.
]]
local function MarkerPrefix(isWhisper)
	if ns.FLAVOR == "Camelot" and not isWhisper then
		return ""
	end
	return ns.TARGET_MARKER .. " "
end

--[[
    The name signs off a sent message, so the body gives up its closing
    punctuation: "Katz is missing [Arcane Intellect] // GtG", never "...! //
    GtG". Translations still carry their own (Spanish opens with an inverted
    mark, CJK closes with a full-width one),
    so the trim covers those too. Marks are matched as whole UTF-8 sequences,
    never as a byte class, so a multi-byte character is never cut in half.
]]
local CLOSING_MARKS = { "!", ".", "?", "\239\188\129", "\227\128\130", "\239\188\159" } -- ! . ? and full-width ！ 。 ？
local OPENING_MARKS = { "\194\161", "\194\191" } -- ¡ ¿

local function TrimSentBody(body)
	local trimmed = true
	while trimmed do
		trimmed = false
		body = body:gsub("%s+$", "")
		for _, mark in ipairs(CLOSING_MARKS) do
			if body:sub(-#mark) == mark then
				body = body:sub(1, -#mark - 1)
				trimmed = true
			end
		end
	end
	for _, mark in ipairs(OPENING_MARKS) do
		if body:sub(1, #mark) == mark then
			body = body:sub(#mark + 1)
		end
	end
	return body
end

local function SignOff(body, isWhisper)
	return MarkerPrefix(isWhisper) .. TrimSentBody(body) .. " // " .. L["ADDON_SHORT_NAME"]
end

-- L[formatKey] formatted and signed off, or nil for a key with no text. Bodies carry links, so pipes stay.
local function BuildSent(isWhisper, formatKey, ...)
	local template = L[formatKey]
	if not template then
		return nil
	end
	return SignOff(string.format(template, ...), isWhisper)
end

--[[
    A sent line for group chat, built without sending so a caller can measure
    it first. On WoW Forever it carries no marker (MarkerPrefix).
]]
function ns:BuildAnnounceMessage(formatKey, ...)
	return BuildSent(false, formatKey, ...)
end

-- An automated whisper: led by the marker on every flavor, WoW Forever included.
function ns:BuildWhisperMessage(formatKey, ...)
	return BuildSent(true, formatKey, ...)
end

-- Every chat line the add-on sends goes through here, which sends nothing without a channel and a message.
local function Send(message, channel, target)
	if not channel or not message or message == "" then
		return
	end
	C_ChatInfo.SendChatMessage(message, channel, nil, target)
end

--------------------------------------------------------------------------------
-- Whisper Queue
--------------------------------------------------------------------------------

--[[
    Whispers sent in a burst are queued with a small gap instead of sent
    inline: a burst of same-frame whispers risks the server-side chat squelch.
    An empty queue still sends immediately, so the common one-recipient case
    feels instant.
]]
local WHISPER_GAP = 0.35
local nextWhisperAt = 0
local function QueueWhisper(target, message)
	local now = GetTime()
	local delay = nextWhisperAt - now
	if delay < 0 then
		delay = 0
	end
	nextWhisperAt = now + delay + WHISPER_GAP
	if delay == 0 then
		Send(message, "WHISPER", target)
	else
		C_Timer.After(delay, function()
			Send(message, "WHISPER", target)
		end)
	end
end

-- A finished line to its channel: a whisper through the queue, anything else at once.
local function Deliver(channel, target, message)
	if not channel or not message then
		return
	end
	if channel == "WHISPER" then
		QueueWhisper(target, message)
	else
		Send(message, channel, target)
	end
end

--[[
    Resolve the client's plural escape to plain text.

    Trap: WoW's own duration strings (D_MINUTES == "%d |4minute:minutes;") carry
    a |4 escape that the UI expands only at render time. It looks right in a
    print, but SendChatMessage rejects any message still holding one -- "Invalid
    escape code in chat message" -- and silently drops the whole line. Resolving
    it here is what lets the units come from the client's own localization in
    every language it ships, instead of the add-on carrying its own copies.

    Slavic locales list a third form (one/few/many) and get their rule; two-form
    languages take a simple count check; languages that don't inflect (zhCN,
    koKR) carry no escape at all, so the gsub finds nothing to do.
]]
local function ResolvePlurals(text)
	return (
		text:gsub("(%d+)(%s*)|4([^;]*);", function(count, gap, body)
			local forms = {}
			for form in body:gmatch("[^:]+") do
				forms[#forms + 1] = form
			end
			if #forms == 0 then
				return count .. gap
			end

			local number = tonumber(count) or 0
			local pick
			if #forms >= 3 then
				local mod10, mod100 = number % 10, number % 100
				if mod10 == 1 and mod100 ~= 11 then
					pick = forms[1] -- 1, 21, 31...
				elseif mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
					pick = forms[2] -- 2-4, 22-24...
				else
					pick = forms[3]
				end
			else
				pick = (number == 1) and forms[1] or (forms[2] or forms[1])
			end
			return count .. gap .. pick
		end)
	)
end

--[[
    Durations run to round numbers, so the largest whole unit states one exactly.
    `forceSeconds` keeps the seconds wording whatever the size: the rounding is
    right for a duration read as a length ("1 Minute" for 89s) but wrong for a
    fixed menu choice, where 89 would print as "1 Minute" directly beneath "55
    Seconds". Return the Favor's 60-second choice reads as a minute. The hour
    rung stays because this formats whatever duration it is handed, and a later
    caller re-deriving the ladder would walk back into the plural-escape trap
    that ResolvePlurals exists to solve.
]]
local function FormatDuration(seconds, forceSeconds)
	seconds = math.floor((seconds or 0) + 0.5)
	local template, count
	if not forceSeconds and seconds >= 3600 then
		template, count = D_HOURS, math.floor(seconds / 3600 + 0.5)
	elseif not forceSeconds and seconds >= 60 then
		template, count = D_MINUTES, math.floor(seconds / 60 + 0.5)
	else
		template, count = D_SECONDS, seconds
	end
	return ResolvePlurals(template:format(count))
end
ns.FormatDuration = FormatDuration

--------------------------------------------------------------------------------
-- Buff Requests
--------------------------------------------------------------------------------

-- Up to this many players are named in a buff ask; more are counted instead.
local ASK_MAX_NAMES = 5

--[[
    Names joined the way a sentence lists them: "Katz", "Katz and Aero",
    "Katz, Aero, and Spek".
]]
local function JoinNames(names)
	if #names == 1 then
		return names[1]
	elseif #names == 2 then
		return L["LIST_PAIR_FORMAT"]:format(names[1], names[2])
	end
	local head = table.concat(names, L["LIST_SEPARATOR"], 1, #names - 1)
	return L["LIST_LAST_FORMAT"]:format(head, names[#names])
end

--[[
    Buff Duty's ask for a raid buff (an icon under the window's Party-Buffs),
    signed off like every sent message: "Katz and Aero are missing [Arcane
    Intellect] // GtG" while ASK_MAX_NAMES or fewer are missing it, and "7
    people are missing the [Arcane Intellect] buff // GtG" past that. `names`
    are the missing players' names without their realms, `count` how many.
    A statement, not a question, so the sign-off reads cleanly after it.
    `isWhisper` builds the whispered ask, which leads with the marker on
    WoW Forever too; the group's follows the group-chat rule (MarkerPrefix).
]]
function ns:BuildBuffRequestMessage(names, count, link, isWhisper)
	names = names or {}
	local build = isWhisper and ns.BuildWhisperMessage or ns.BuildAnnounceMessage
	if count > ASK_MAX_NAMES or #names ~= count or count == 0 then
		return build(ns, "BUFF_DUTY_OTHERS_ASK_COUNT", count, link)
	elseif count == 1 then
		return build(ns, "BUFF_DUTY_OTHERS_ASK_ONE", names[1], link)
	end
	return build(ns, "BUFF_DUTY_OTHERS_ASK_NAMES", JoinNames(names), link)
end

ns.BUFF_ASK_MAX_NAMES = ASK_MAX_NAMES

--[[
    The chat the whole group reads: an instance group's own (a battleground's,
    say) first, since raid and party chat do not reach it, then raid, then
    party. Nil when the player is in no group.
]]
function ns:GetGroupChatChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
	return nil
end

--[[
    The one entry point for a sent line built from a locale key: formatted,
    signed off (a whisper by the whisper rule, MarkerPrefix) and delivered. A
    nil channel, or a key with no text, sends nothing.
]]
function ns:Announce(channel, target, formatKey, ...)
	Deliver(channel, target, BuildSent(channel == "WHISPER", formatKey, ...))
end

-- A Party-Buffs icon's click, to the whole group: a line already built, so its length was measured.
function ns:SayBuffRequest(message)
	Deliver(ns:GetGroupChatChannel(), nil, message)
end

--[[
    An automated whisper already built (a buff ask from a Party-Buffs icon's
    right-click, a Rank Watch report), queued so a burst of them is spaced out.
]]
function ns:QueueAutomatedWhisper(target, message)
	Deliver("WHISPER", target, message)
end
