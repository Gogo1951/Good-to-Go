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
    {rt1} Message // GtG. The editable whispers (Editable Whispers, below) are
    signed off here too, so the marker and the name are never part of the
    player's saved text. The body carries a spell link, and SignOff adds
    the leading raid-target marker; the chat system renders both on send (the
    marker becomes the Star icon), so the pipes and braces pass through unchanged.
    WoW Forever blocks raid-marker tokens only in numbered channels, which the
    add-on never sends to.
]]

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

local function SignOff(body)
	return ns.TARGET_MARKER .. " " .. TrimSentBody(body) .. " // " .. L["ADDON_SHORT_NAME"]
end

-- L[formatKey] formatted and signed off, or nil for a key with no text. Bodies carry links, so pipes stay.
local function BuildSent(formatKey, ...)
	local template = L[formatKey]
	if not template or template == "" then
		return nil
	end
	return SignOff(string.format(template, ...))
end

--[[
    A sent line for group chat, built without sending so a caller can measure
    it first.
]]
function ns:BuildAnnounceMessage(formatKey, ...)
	return BuildSent(formatKey, ...)
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
    Every message to other players built from a fixed L key goes through here:
    L[formatKey] formatted, signed off for its channel and delivered. Sends
    nothing without a channel, or for a key with no text. Editable whispers
    keep their own build functions and go through ns:QueueAutomatedWhisper.
]]
function ns:Announce(channel, target, formatKey, ...)
	if not channel then
		return
	end
	Deliver(channel, target, BuildSent(formatKey, ...))
end

--------------------------------------------------------------------------------
-- Buff Requests
--------------------------------------------------------------------------------

-- Up to this many players are named in a buff ask; more are counted instead.
local ASK_MAX_NAMES = 5

--[[
    Names joined the way a sentence lists them: "Katz", "Katz and Aero",
    "Katz, Aero, and Spek". Exposed for the Party Buffs menu's whisper row.
]]
local function JoinNames(names, pairFormat, lastFormat)
	if #names == 1 then
		return names[1]
	elseif #names == 2 then
		return L[pairFormat or "LIST_PAIR_FORMAT"]:format(names[1], names[2])
	end
	local head = table.concat(names, L["LIST_SEPARATOR"], 1, #names - 1)
	return L[lastFormat or "LIST_LAST_FORMAT"]:format(head, names[#names])
end
ns.JoinNames = JoinNames

-- Choices joined the same way with "or": "[Fortitude] or [Shadow Protection]".
local function JoinChoices(names)
	return JoinNames(names, "LIST_OR_PAIR_FORMAT", "LIST_OR_LAST_FORMAT")
end

-- Whether an ask counts its players rather than naming them: past ASK_MAX_NAMES, or without a name for each.
local function AsksByCount(names, count)
	return count > ASK_MAX_NAMES or #names ~= count or count == 0
end

--[[
    Buff Duty's ask for a raid buff said to the group (a click on an icon
    under the window's Party-Buffs), signed off like every sent message:
    "Katz and Aero are missing [Arcane Intellect] // GtG" while ASK_MAX_NAMES
    or fewer are missing it, and "7 people are missing the [Arcane Intellect]
    buff // GtG" past that. `names` are the missing players' names without
    their realms, `count` how many. A statement, not a question, so the
    sign-off reads cleanly after it. The whispered ask is the player's own
    text (ns:BuildBuffAskWhisper, below).
]]
local function BuffRequestParts(names, count, link)
	names = names or {}
	if AsksByCount(names, count) then
		return "BUFF_DUTY_OTHERS_ASK_COUNT", count, link
	elseif count == 1 then
		return "BUFF_DUTY_OTHERS_ASK_ONE", names[1], link
	end
	return "BUFF_DUTY_OTHERS_ASK_NAMES", JoinNames(names), link
end

-- The ask built without sending, for the panel's Example and the diagnostics to measure.
function ns:BuildBuffRequestMessage(names, count, link)
	return ns:BuildAnnounceMessage(BuffRequestParts(names, count, link))
end

-- A Party-Buffs icon's click: the ask said to the whole group.
function ns:SayBuffRequest(names, count, link)
	ns:Announce(ns:GetGroupChatChannel(), nil, BuffRequestParts(names, count, link))
end

ns.BUFF_ASK_MAX_NAMES = ASK_MAX_NAMES

--------------------------------------------------------------------------------
-- Editable Whispers
--------------------------------------------------------------------------------

--[[
    The whispers a player words themselves on the options panels: Buff Duty's
    whispered ask, and Rank Watch's tip, opt-out offer and opt-out reply. The
    saved text holds {word} tokens, swapped with gsub and never format codes,
    so a stray % can't break the send; each value goes in through a function,
    which gsub takes literally, % included. A token the whisper doesn't list
    stays as typed.

    Each whisper has two builders. Its fill function builds the message as
    typed, however long, so the panel can tell when it runs past the chat
    ceiling. Its build function is what sends: nil for empty text, which sends
    no whisper, and the default text of the language whispers go out in
    (ns.GetDefaultMessage) when the player's own runs past the ceiling, or nil
    again when even the default does, since the game rejects the line. The
    Example lines, the Too Long lines, Send Test to Me and the real sends all
    go through them.
]]
local function FillTokens(template, values)
	return (
		template:gsub("{(%a+)}", function(token)
			local value = values[token]
			if value ~= nil then
				return tostring(value)
			end
		end)
	)
end

-- The default text when `template` is too long to send, else nil for empty text, else the message as filled; nil when even the default is too long.
local function BuildEditable(template, fill, field)
	if not template or template == "" then
		return nil
	end
	local message = fill(template)
	if #message > ns.CHAT_MESSAGE_MAX_LENGTH then
		message = fill(ns.GetDefaultMessage(field))
		if #message > ns.CHAT_MESSAGE_MAX_LENGTH then
			return nil
		end
	end
	return message
end

--[[
    Buff Duty's whispered ask (a right-click on an icon under the window's
    Party-Buffs). {names} is the missing players' names joined as a sentence
    lists them, or "7 people" past ASK_MAX_NAMES, and {spell} the buff's link.

    While the text is the chosen language's default, one missing player and a
    count each take their own default form (buffAskOne, buffAskCount), so the
    grammar matches the ask said to the group: "Katz is missing", "7 people
    are missing the ... buff".
]]
function ns.FillBuffAskWhisper(template, names, count, link)
	names = names or {}
	local values = { spell = link or "" }
	if template == ns.GetDefaultMessage("buffAsk") and (count == 1 or AsksByCount(names, count)) then
		template = ns.GetDefaultMessage(count == 1 and #names == 1 and "buffAskOne" or "buffAskCount")
		values.count = count
	end
	if AsksByCount(names, count) then
		values.names = L["BUFF_DUTY_OTHERS_ASK_PEOPLE"]:format(count)
	else
		values.names = JoinNames(names)
	end
	return SignOff(FillTokens(template, values))
end

function ns:BuildBuffAskWhisper(template, names, count, link)
	return BuildEditable(template, function(text)
		return ns.FillBuffAskWhisper(text, names, count, link)
	end, "buffAsk")
end

--[[
    Buff Duty's ask to your target for the buffs of theirs you're missing (a
    click on an ask icon under Target, or the Buff Key). {name} is their name
    without the realm, and {spells} the buffs, linked or named, offered as
    choices: "any chance I could snag a [Fortitude] or [Shadow Protection]".
]]
function ns.FillBuffAskTargetWhisper(template, name, spells)
	local joined = spells and spells[1] and JoinChoices(spells) or ""
	return SignOff(FillTokens(template, { name = name or "", spells = joined }))
end

function ns:BuildBuffAskTargetWhisper(template, name, spells)
	return BuildEditable(template, function(text)
		return ns.FillBuffAskTargetWhisper(text, name, spells)
	end, "buffAskTarget")
end

--[[
    Rank Watch's tip to a player who cast a low rank: {spell} is the cast and
    its rank, {level} the level a newer rank comes at, and {pet} the pet (its
    name) or demon (its kind) in those two forms. `form` is nil, "pet" or
    "demon". `linkedSpell` is the cast linked and `namedSpell` its name alone:
    the fill takes the link, then the name when the link won't fit the chat
    ceiling, and never cuts the message, since a cut could break a link.
]]
local TIP_FIELDS = { pet = "rankWatchTipPet", demon = "rankWatchTipDemon" }

function ns.RankWatchTipField(form)
	return TIP_FIELDS[form] or "rankWatchTip"
end

function ns.FillRankWatchTipWhisper(template, linkedSpell, namedSpell, level, petName)
	local message
	for _, spell in ipairs({ linkedSpell or "", namedSpell or "" }) do
		message = SignOff(FillTokens(template, { spell = spell, level = level, pet = petName }))
		if #message <= ns.CHAT_MESSAGE_MAX_LENGTH then
			return message
		end
	end
	return message
end

function ns:BuildRankWatchTipWhisper(form, template, linkedSpell, namedSpell, level, petName)
	return BuildEditable(template, function(text)
		return ns.FillRankWatchTipWhisper(text, linkedSpell, namedSpell, level, petName)
	end, ns.RankWatchTipField(form))
end

-- Rank Watch's opt-out offer, with a player's second tip in a session. It has no tokens.
function ns.FillOptOutOfferWhisper(template)
	return SignOff(template)
end

function ns:BuildOptOutOfferWhisper(template)
	return BuildEditable(template, ns.FillOptOutOfferWhisper, "rankWatchOptOut")
end

-- Rank Watch's reply to a group member who whispered "Opt Out". It has no tokens.
function ns.FillOptOutDoneWhisper(template)
	return SignOff(template)
end

function ns:BuildOptOutDoneWhisper(template)
	return BuildEditable(template, ns.FillOptOutDoneWhisper, "rankWatchOptOutDone")
end

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
    An automated whisper already built (a buff ask from a Party-Buffs icon's
    right-click, a Rank Watch report), queued so a burst of them is spaced out.
]]
function ns:QueueAutomatedWhisper(target, message)
	Deliver("WHISPER", target, message)
end

--[[
    The options panels' Send Test to Me: an editable whisper exactly as another
    player gets it, sent to the player's own character, so they see the marker
    and the links drawn by real chat rather than by the panel.
]]
function ns:WhisperTestToSelf(message)
	local me = GetUnitName("player", true)
	if message and me then
		Send(message, "WHISPER", me)
	end
end
