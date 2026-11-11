local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local format = string.format

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    Dot-defined widget constructors shared by every options panel, with the
    rest of the options infrastructure more than one add-on's panels use below.
    The feature switches, the shared item lists and the widget types have files
    of their own beside this one: Options-Feature-Switches.lua,
    Options-Item-Lists.lua and Options-Widgets.lua.
    A feature's own helpers live beside its panels, in
    Options/<Feature>/Options-<Feature>-Utilities.lua.

    Every section header is a real AceConfig "header" -- the ruled line with
    the title set into it -- and no panel draws its own out of a colored
    description. `hidden` is optional (a function or a boolean) on every one,
    so a gated section collapses whole instead of leaving a stray gap behind.
]]
function ns.OptionsHeader(text, order, hidden)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order, hidden = hidden }
end

function ns.OptionsDesc(text, order, hidden)
	return { type = "description", name = text, fontSize = "medium", order = order, hidden = hidden }
end

function ns.OptionsSpacer(order, hidden)
	return { type = "description", name = " ", order = order, hidden = hidden }
end

--[[
    The left half of a label-beside-control row: this cell, then the control
    with name = "" ordered immediately after it. A caption left on the control
    would put the label back above the widget and break the row. A label has
    no state of its own, so on a panel behind a master switch it takes the
    same `hidden` as the control beside it.
]]
function ns.OptionsRowLabel(text, order, width, hidden)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
		hidden = hidden,
	}
end

--------------------------------------------------------------------------------
-- Sub-Option Rows
--------------------------------------------------------------------------------

--[[
    A sub-option is a control that only means anything while the toggle above it
    is on. A toggle's one dropdown shares its toggle's line instead (the Options
    Layout Grid in Data/Data.lua). What takes this row is a dependent checkbox
    with no line to share, such as the Restock reminder's Play Sound, and each
    setting of a toggle that has more than one, such as Scroll Buffs' dropdown.
    Either is marked two ways at once.

    The row leads with a blank indent cell, which moves the checkbox itself.
    Padding the label instead would indent only the caption -- AceConfig pins a
    checkbox at the left edge of its own widget -- leaving the box lined up with
    its parent's and the words drifting away from it.

    ns.OptionsSubLabel then colors the caption HELP silver against the parent's white, so
    the row reads as subordinate rather than merely shifted.

    The whole row is wrapped in an inline group with no name, which AceConfig
    renders as a bare SimpleGroup -- no border, no title, no padding -- at
    "fill" width. That wrapper is load-bearing, not decoration. Laid out flat,
    the indent and its control are just two more widgets in the panel's flow,
    kept together only by their widths happening to fill the line; the pair
    after them then packs onto whatever space is left and its indent stops
    indenting anything. A fill widget always gets a line to itself, so one group
    per sub-option pins one row per sub-option no matter what the pane is doing.

    Inside the group the controls need slack rather than an exact fit: a row
    summing to the full pane width sits on the wrap boundary, where a pass that
    measures a control before its width is applied tips the control onto its own
    line and strands the indent above it.

    Hiding belongs on the group, never on the controls inside it -- hiding only
    the control would leave its indent cell behind as a blank line.
]]
function ns.OptionsSubRow(order, hidden, controls)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}

	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

--------------------------------------------------------------------------------
-- Example Lines
--------------------------------------------------------------------------------

--[[
    An Example line: one sample of the chat print a feature makes, built by
    ns.BuildPrintLine, under a silver "Example:" label. lineFunction returns
    the print body, or nil, or a list of bodies for a feature whose every line
    the Example shows (the Readiness Report's), each printed on its own line;
    it runs at every draw, so the Example follows the
    settings the moment they change. Silver opens again after the line, for a
    locale whose label continues past its %s.
]]
function ns.OptionsExample(order, lineFunction, hidden)
	return {
		type = "description",
		name = function()
			local body = lineFunction()
			local bodies = type(body) == "table" and body or { body }
			local lines = {}
			for index, text in ipairs(bodies) do
				lines[index] = ns.BuildPrintLine(text)
			end
			local line = table.concat(lines, "\n" .. GetColor("HELP"))
			return GetColor("HELP") .. format(L["SAMPLE_EXAMPLE"], line .. GetColor("HELP")) .. "|r"
		end,
		fontSize = "medium",
		order = order,
		hidden = hidden,
	}
end

-- The character's AceDB profile, the Consumable Macros panels' settings table, or nil before the database is open.
function ns.OptionsProfileSettings()
	return ns.db and ns.db.profile
end

-- A label or hover text that names a spell, formatKey's %s, read from the client when it shows.
function ns.OptionsSpellDescription(formatKey, spellID)
	return function()
		return string.format(L[formatKey], C_Spell.GetSpellName(spellID) or "")
	end
end

-- A sent line's {rtN} target markers as the icons the receiving client draws; panel text needs the texture itself.
function ns.MarkersAsTextures(message)
	return (message:gsub("{rt(%d)}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16|t"))
end

--[[
    A chat type's color as the player chose it (ChatTypeInfo's PARTY, WHISPER), with chat's own default hex
    for a client that hasn't filled ChatTypeInfo in.
]]
local function ChatColor(chatType, defaultHex)
	local info = ChatTypeInfo and ChatTypeInfo[chatType]
	if not info then
		return "|cff" .. defaultHex
	end
	return string.format(
		"|cff%02x%02x%02x",
		math.floor(info.r * 255 + 0.5),
		math.floor(info.g * 255 + 0.5),
		math.floor(info.b * 255 + 0.5)
	)
end

--[[
    A sent line as the players reading it see it, in the chat type's color:
    the client's own line opener (CHAT_WHISPER_GET's "[Name] whispers: ",
    CHAT_PARTY_GET's "[Party] [Name]: "), the sender being the character the
    player is on, in its class color and read when the line is drawn. A chat
    frame falls back to the chat color after a link's |r and a panel falls
    back to white, so the color is opened again after every |r.
]]
local function BuildChatExampleLine(message, chatType, defaultHex, opener)
	local color = ChatColor(chatType, defaultHex)
	local _, class = UnitClass("player")
	local sender = "[" .. (ns.GetClassColor(class) or GetColor("TEXT")) .. (GetUnitName("player") or "") .. "|r]"
	local line = opener:format(sender) .. ns.MarkersAsTextures(message)
	return color .. (line:gsub("|r", "|r" .. color)) .. "|r"
end

function ns.BuildWhisperExampleLine(message)
	return BuildChatExampleLine(message, "WHISPER", "FF80FF", CHAT_WHISPER_GET or "%s whispers: ")
end

-- Party rather than raid: both are drawn the same way, and party is the one every group has.
function ns.BuildPartyExampleLine(message)
	return BuildChatExampleLine(message, "PARTY", "AAAAFF", CHAT_PARTY_GET or "[Party] %s: ")
end

-- An Example line for a whisper; getMessage returns the message exactly as it is sent.
function ns.OptionsWhisperExample(order, getMessage, hidden)
	return {
		type = "description",
		name = function()
			return GetColor("HELP")
				.. format(L["SAMPLE_EXAMPLE"], ns.BuildWhisperExampleLine(getMessage()) .. GetColor("HELP"))
				.. "|r"
		end,
		fontSize = "medium",
		order = order,
		hidden = hidden,
	}
end

--[[
    An Example of one line already drawn the way it arrives (ns.BuildPartyExampleLine,
    ns.BuildWhisperExampleLine, ns.BuildPrintLine); lineFunction runs at every draw.
]]
function ns.OptionsChatExample(order, lineFunction, hidden)
	return {
		type = "description",
		name = function()
			return GetColor("HELP") .. format(L["SAMPLE_EXAMPLE"], (lineFunction() or "") .. GetColor("HELP")) .. "|r"
		end,
		fontSize = "medium",
		order = order,
		hidden = hidden,
	}
end

--------------------------------------------------------------------------------
-- Sound Preview
--------------------------------------------------------------------------------

--[[
    The speaker icon that previews a panel's sound, on the same row right after
    its sound toggle, so that toggle must not be full-width. It plays whatever
    the toggle says: hearing the sound before turning it on is the point. An
    execute carrying an image renders as an AceGUI Icon rather than a captioned
    button, so name stays empty and the label rides in desc, shown on hover. The
    texture is the client's own voice-chat speaker, so it matches the UI in every
    locale without shipping art. description defaults to the buff panels' line.
]]
function ns.DefineSoundPreview(playSound, order, hidden, description)
	return {
		type = "execute",
		name = "",
		desc = description or L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"],
		image = "Interface\\Common\\VoiceChat-Speaker",
		imageWidth = 16,
		imageHeight = 16,
		width = 0.15,
		order = order,
		hidden = hidden,
		func = playSound,
	}
end

--------------------------------------------------------------------------------
-- Shared Values
--------------------------------------------------------------------------------

--[[
    The level filter's labels, shared by every consumable's When to Use
    (Buff Food, Scroll Buffs, Pet Food Buffs, and Use Conjured Food & Water
    First), offered in ns.LEVEL_FILTER_ORDER. Each reads as a state on its own,
    since the mini-map tooltip shows one in place of Enabled while it is what
    holds a switch back.
]]
ns.LEVEL_FILTER_VALUES = {
	any = L["LEVEL_FILTER_ANY"],
	leveling = L["LEVEL_FILTER_LEVELING"],
	maxlevel = L["LEVEL_FILTER_MAX_LEVEL"],
}

--------------------------------------------------------------------------------
-- Group Context Checkboxes
--------------------------------------------------------------------------------

--[[
    The one control for when a feature acts by group: a checkbox per group
    context, always Solo, Party, Raid, Battleground (ns.GROUP_CONTEXTS), with
    the same labels and hover text on every panel. `getTable` returns the
    setting's { solo, party, raid, battleground } table; `onChange` runs after
    a tick changes. A feature that tunes a context further (Buff Duty's
    Anywhere or In Instance) lays its own row out around
    ns.OptionsGroupContextToggle; the rest take the four in one sub-option row
    from ns.OptionsGroupContextRow.
]]
function ns.OptionsGroupContextToggle(context, order, width, getTable, onChange, hidden)
	local key = context:upper()
	return {
		type = "toggle",
		name = L["GROUP_CONTEXT_" .. key],
		desc = L["GROUP_CONTEXT_" .. key .. "_DESCRIPTION"],
		width = width,
		order = order,
		hidden = hidden,
		get = function()
			return ns.IsGroupContextOn(getTable(), context)
		end,
		set = function(_, value)
			getTable()[context] = value
			onChange()
		end,
	}
end

-- Wide enough for the longest label (Battleground) in every locale, with slack under the row.
local GROUP_CONTEXT_TOGGLE_WIDTH = 0.75

function ns.OptionsGroupContextRow(order, hidden, getTable, onChange)
	local toggles = {}
	for index, context in ipairs(ns.GROUP_CONTEXTS) do
		toggles[index] = ns.OptionsGroupContextToggle(context, index, GROUP_CONTEXT_TOGGLE_WIDTH, getTable, onChange)
	end
	return ns.OptionsSubRow(order, hidden, toggles)
end

-- Whether a group context table has no box ticked, so the feature it gates never acts.
function ns.NoGroupContextTicked(showIn)
	for _, context in ipairs(ns.GROUP_CONTEXTS) do
		if ns.IsGroupContextOn(showIn, context) then
			return false
		end
	end
	return true
end

--[[
    The warning under a set of group context checkboxes with none ticked: the
    feature they gate never acts, and the line says so in red. `text` is the
    feature's own sentence; it hides while any box is ticked or `hidden` holds.
]]
function ns.OptionsGroupContextNone(text, order, getTable, hidden)
	return {
		type = "description",
		name = GetColor("OFF") .. text .. "|r",
		fontSize = "medium",
		order = order,
		hidden = function()
			if hidden and hidden() then
				return true
			end
			return not ns.NoGroupContextTicked(getTable())
		end,
	}
end

--------------------------------------------------------------------------------
-- Shared Panel Helpers
--------------------------------------------------------------------------------

--[[
    The title drawn at the top of a sub-panel: "Rank Watch > Tracked
    Abilities", so it is always clear where you are. Only the title carries the
    parent; the settings tree already shows it by nesting, and the tree label is
    the plain name passed to AddToBlizOptions.
]]
function ns.SubPanelTitle(parentName, name)
	return parentName .. " > " .. name
end

--[[
    A row label naming an ability, which shows the game's own tooltip for it
    on hover, the same one an action bar shows. `hyperlink` returns
    "spell:<id>" or "item:<id>". A plain Label takes no mouse, so this one is
    an InteractiveLabel, which AceConfigDialog gives the same hover handler as
    any control, and that handler shows `tooltipHyperlink` when there is one.
]]
function ns.OptionsAbilityLabel(text, order, width, hyperlink)
	local label = ns.OptionsRowLabel(text, order, width)
	label.dialogControl = "InteractiveLabel"
	label.tooltipHyperlink = hyperlink
	return label
end

--[[
    The spell an ability's tooltip quotes: the HIGHEST id in its rank group
    that the client describes, so it reads the rank you actually cast, not rank
    1. Ids are sorted rather than trusted in data order -- rows are not
    reliably rank-ordered (Combustion is { 29977, 11129 }, Vanish
    { 1856, 1857, 27617, 26889, 44290 }). Classic holds tooltip data only for
    spells the character has known, and these panels list every class, so each
    id is requested once here and the pick is made again at every hover, when
    the text has had time to land.
]]
function ns.SpellTooltipLink(ids)
	local ranked = {}
	for i = 1, #ids do
		ranked[i] = ids[i]
		C_Spell.RequestLoadSpellData(ids[i])
	end
	table.sort(ranked)
	return function()
		for i = #ranked, 1, -1 do
			local text = C_Spell.GetSpellDescription(ranked[i])
			if text and text ~= "" then
				return "spell:" .. ranked[i]
			end
		end
		return "spell:" .. ranked[#ranked]
	end
end

--[[
    The displayed name embeds an icon escape (|T...|t), so sorting by it would sort
    by texture path. This returns the clean, lowercased name for comparison only.
]]
local function EntrySortKey(entry)
	local name = entry.label or entry.spellName
	if not name and entry.itemId then
		name = C_Item.GetItemInfo(entry.labelItem or entry.itemId)
	end
	return (name or ""):lower()
end

--[[
    A copy of `entries` ordered alphabetically by display name, with the watched id
    breaking ties for a stable result. Item names resolve lazily, which is why the
    panels register their builders as functions (run on open, when the item cache
    is warm) rather than as prebuilt tables.
]]
function ns.SortedEntries(entries)
	local sorted = {}
	for i = 1, #entries do
		sorted[i] = entries[i]
	end
	table.sort(sorted, function(a, b)
		local keyA, keyB = EntrySortKey(a), EntrySortKey(b)
		if keyA == keyB then
			return (a.ids[1] or 0) < (b.ids[1] or 0)
		end
		return keyA < keyB
	end)
	return sorted
end
