local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Whisper Composer
--------------------------------------------------------------------------------

--[[
    The composer for every whisper a player words themselves.

    - The Star marker and "// GtG" sign-off are captions beside the box, not
      part of it: the build adds them to whatever is typed, so they can't be
      deleted.
    - The chat ceiling is in bytes, so Cyrillic, Korean and Chinese reach it
      sooner. No live count: the panel redraws only on save, so one would lag
      the typing.
    - The Example and Send Test to Me are built by the same code that sends.

    `spec` says what the composer edits:
    - prefix: starts every arg key, so two composers can share a panel.
    - hidden(): true hides the whole composer (its send toggle is off).
    - language: false leaves out Send Messages In.
    - messages: one entry per whisper, each with
        field: its field in Data.MESSAGE_LANGUAGES and Data.EDITABLE_MESSAGES;
        label, description: the row's caption and the box's tooltip;
        tokens(): the tokens line, or nil for a whisper with none;
        fill(text): the message as typed with the sample parts, for measuring;
        build(text): the message as sent with the sample parts, or nil.
]]
local LABEL_WIDTH = 0.9
local MARKER_WIDTH = 0.15
local SIGN_OFF_WIDTH = 0.35
local RESET_WIDTH = 0.5
local INPUT_WIDTH = ns.OPTIONS_ROW_WIDTH - LABEL_WIDTH - MARKER_WIDTH - SIGN_OFF_WIDTH - RESET_WIDTH
-- The hint rows' first cell spans the label and the marker, so their second starts under the box.
local HINT_INDENT = LABEL_WIDTH + MARKER_WIDTH
local TEST_WIDTH = 1.0

-- Chat draws the marker as its icon; the panel needs the texture itself (Kit.Markers sizes to inline text).
local MARKER_TEXTURE = (ns.TARGET_MARKER:gsub("{rt(%d)}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16|t"))

local languageValues, languageSorting

local function LanguageChoices()
	if not languageValues then
		languageValues, languageSorting = {}, {}
		for _, language in ipairs(Data.MESSAGE_LANGUAGES) do
			languageValues[language.locale] = language.name
			languageSorting[#languageSorting + 1] = language.locale
		end
	end
	return languageValues, languageSorting
end

local function Label(text, order, width, hidden, desc)
	local label = Kit.Label(text, order, width, desc)
	label.hidden = hidden
	return label
end

-- One whisper's rows, filling `order` through `order + 0.09`.
local function DefineMessageRows(args, spec, message, key, order)
	local hidden = spec.hidden
	local function Text()
		return ns.GetMessageText(message.field)
	end
	local function MessageHidden()
		return hidden() or Text() == ""
	end

	args[key .. "Label"] = Label(message.label, order, LABEL_WIDTH, hidden, message.description)
	args[key .. "Marker"] = Label(MARKER_TEXTURE, order + 0.01, MARKER_WIDTH, hidden, L["WHISPER_SIGN_OFF_DESCRIPTION"])
	args[key] = {
		type = "input",
		name = "",
		desc = message.description,
		width = INPUT_WIDTH,
		order = order + 0.02,
		hidden = hidden,
		get = Text,
		set = function(_, value)
			ns.SetMessageText(message.field, value or "")
			ns.RefreshSettings()
		end,
	}
	args[key .. "SignOff"] = Label(
		GetColor("SEPARATOR") .. "// " .. L["ADDON_SHORT_NAME"] .. "|r",
		order + 0.03,
		SIGN_OFF_WIDTH,
		hidden,
		L["WHISPER_SIGN_OFF_DESCRIPTION"]
	)
	args[key .. "Reset"] = {
		type = "execute",
		name = L["OPTIONS_RESET"],
		desc = L["WHISPER_TEXT_RESET_DESCRIPTION"],
		width = RESET_WIDTH,
		order = order + 0.04,
		hidden = hidden,
		disabled = function()
			return Text() == ns.GetDefaultMessage(message.field)
		end,
		func = function()
			ns.SetMessageText(message.field, nil)
			ns.RefreshSettings()
		end,
	}

	-- A blank cell holds the tokens line clear of the label column.
	if message.tokens then
		args[key .. "TokensIndent"] = Label(" ", order + 0.05, HINT_INDENT, hidden)
		args[key .. "Tokens"] = {
			type = "description",
			name = function()
				return GetColor("HELP") .. message.tokens() .. "|r"
			end,
			width = ns.OPTIONS_ROW_WIDTH - HINT_INDENT,
			fontSize = "medium",
			order = order + 0.051,
			hidden = hidden,
		}
	end

	local function FitsHidden()
		return MessageHidden() or #message.fill(Text()) <= ns.CHAT_MESSAGE_MAX_LENGTH
	end
	args[key .. "TooLongIndent"] = Label(" ", order + 0.06, HINT_INDENT, FitsHidden)
	args[key .. "TooLong"] = {
		type = "description",
		name = GetColor("OFF") .. L["WHISPER_TOO_LONG"] .. "|r",
		width = ns.OPTIONS_ROW_WIDTH - HINT_INDENT,
		fontSize = "medium",
		order = order + 0.061,
		hidden = FitsHidden,
	}

	args[key .. "Example"] = Kit.Example(order + 0.071, MessageHidden, function()
		return Kit.SentLine("WHISPER", message.build(Text()) or "")
	end)
	args[key .. "TestSpace"] = Kit.Spacer(order + 0.08, MessageHidden)
	args[key .. "Test"] = {
		type = "execute",
		name = L["WHISPER_TEST"],
		desc = L["WHISPER_TEST_DESCRIPTION"],
		width = TEST_WIDTH,
		order = order + 0.081,
		hidden = MessageHidden,
		func = function()
			ns:WhisperTestToSelf(message.build(Text()))
		end,
	}
end

--[[
    Fills `order` through `order + 0.1 * #spec.messages + 0.09`: Send Messages
    In first, then each whisper a tenth further on, a blank line between two.
]]
function ns.DefineWhisperComposer(args, spec, order)
	local prefix = spec.prefix
	-- Two composers on one panel each show Send Messages In only while the other is hidden.
	local languageHidden = spec.languageHidden or spec.hidden

	if spec.language ~= false then
		-- A setting like any other dropdown on the page, so it takes the house caption-and-control row.
		args[prefix .. "Language"] = Kit.LabelRow(order, languageHidden, L["SEND_MESSAGES_IN"], {
			type = "select",
			desc = L["SEND_MESSAGES_IN_DESCRIPTION"],
			values = function()
				return (LanguageChoices())
			end,
			sorting = select(2, LanguageChoices()),
			get = function()
				return ns.GetMessageLanguage()
			end,
			set = function(_, value)
				ns.SetMessageLanguage(value)
				ns.RefreshSettings()
			end,
		})
		args[prefix .. "LanguageSpace"] = Kit.Spacer(order + 0.05, languageHidden)
	end

	for index, message in ipairs(spec.messages) do
		local messageOrder = order + 0.1 * index
		if index > 1 then
			args[prefix .. index .. "Space"] = Kit.Spacer(messageOrder - 0.01, spec.hidden)
		end
		DefineMessageRows(args, spec, message, prefix .. index, messageOrder)
	end
end
