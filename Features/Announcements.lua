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

-- Built without printing, so the panels' Example lines draw exactly what chat shows.
function ns.BuildPrintLine(text)
	return GetPrintPrefix() .. GetColor("TEXT") .. text .. "|r"
end

-- Format: |cff[INFO]Good to Go|r |cff[SEPARATOR]//|r |cff[TEXT]Message|r
function ns:PrintMessage(message)
	print(ns.BuildPrintLine(message))
end

local warned = {}

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
    Every line to other players is "{rt1} body // GtG". The marker and name are
    added here, never part of a player's saved text. WoW Forever blocks marker
    tokens only in numbered channels, which the add-on never sends to.
]]

--[[
    The sign-off ends the line, so the body drops a closing "!" or "." (an ask
    keeps its "?"). Marks are matched as whole UTF-8 sequences, never a byte
    class, so a multi-byte character is never cut in half.
]]
local CLOSING_MARKS = { "!", ".", "\239\188\129", "\227\128\130" } -- ! . and full-width ！ 。
local OPENING_MARKS = { "\194\161" } -- ¡

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

-- Built without sending, so a caller can measure it first.
function ns:BuildAnnounceMessage(formatKey, ...)
	return BuildSent(formatKey, ...)
end

-- Every chat line the add-on sends goes through here.
local function Send(message, channel, target)
	if not channel or not message or message == "" then
		return
	end
	C_ChatInfo.SendChatMessage(message, channel, nil, target)
end

--------------------------------------------------------------------------------
-- Whisper Queue
--------------------------------------------------------------------------------

-- A burst of same-frame whispers risks the server's chat squelch; an empty queue still sends at once.
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

-- Fixed-key lines only; editable whispers have their own builders and go through ns:QueueAutomatedWhisper.
function ns:Announce(channel, target, formatKey, ...)
	if not channel then
		return
	end
	Deliver(channel, target, BuildSent(formatKey, ...))
end

--------------------------------------------------------------------------------
-- Buff Requests
--------------------------------------------------------------------------------

local ASK_MAX_NAMES = 5

-- "Katz", "Katz and Aero", "Katz, Aero, and Spek". Exposed for the Party Buffs menu's whisper row.
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

local function AsksByCount(names, count)
	return count > ASK_MAX_NAMES or #names ~= count or count == 0
end

-- names are without realms. "Could someone give 7 people [Arcane Intellect], please?" past ASK_MAX_NAMES.
local function BuffRequestParts(names, count, link)
	names = names or {}
	if AsksByCount(names, count) then
		return "BUFF_DUTY_OTHERS_ASK_COUNT", count, link
	elseif count == 1 then
		return "BUFF_DUTY_OTHERS_ASK_ONE", names[1], link
	end
	return "BUFF_DUTY_OTHERS_ASK_NAMES", JoinNames(names), link
end

function ns:BuildBuffRequestMessage(names, count, link)
	return ns:BuildAnnounceMessage(BuffRequestParts(names, count, link))
end

function ns:SayBuffRequest(names, count, link)
	ns:Announce(ns:GetGroupChatChannel(), nil, BuffRequestParts(names, count, link))
end

ns.BUFF_ASK_MAX_NAMES = ASK_MAX_NAMES

--------------------------------------------------------------------------------
-- Editable Whispers
--------------------------------------------------------------------------------

--[[
    {word} tokens swap through gsub with a function, never format codes, so a
    stray % can't break the send. A token the whisper doesn't list stays as
    typed.

    Each whisper has two builders: fill builds as typed, any length, so the
    panel can flag Too Long; build is what sends (see BuildEditable).
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

-- Nil for empty text; past the ceiling the language's default goes instead, or nil when even it is too long.
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
    While the text is still the default, one player and a count take their own
    default forms (buffAskOne, buffAskCount), so the grammar fits the count.
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
    The fill tries the linked spell, then the bare name when the link won't
    fit, and never cuts the message, since a cut could break a link.
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

function ns.FillOptOutOfferWhisper(template)
	return SignOff(template)
end

function ns:BuildOptOutOfferWhisper(template)
	return BuildEditable(template, ns.FillOptOutOfferWhisper, "rankWatchOptOut")
end

function ns.FillOptOutDoneWhisper(template)
	return SignOff(template)
end

function ns:BuildOptOutDoneWhisper(template)
	return BuildEditable(template, ns.FillOptOutDoneWhisper, "rankWatchOptOutDone")
end

-- An instance group's own chat first: raid and party chat do not reach it.
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

function ns:QueueAutomatedWhisper(target, message)
	Deliver("WHISPER", target, message)
end

-- Send Test to Me goes to the player's own character, so real chat draws the marker and links.
function ns:WhisperTestToSelf(message)
	local me = GetUnitName("player", true)
	if message and me then
		Send(message, "WHISPER", me)
	end
end
