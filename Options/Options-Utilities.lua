local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local format = string.format

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    Dot-defined widget constructors shared by every options panel, with the
    rest of the options infrastructure more than one add-on's panels use below.
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
    ns.BuildPrintLine, under a silver "Example:" label. An Example is a single
    line, even for a feature that prints several. lineFunction returns the
    print body, or nil, and runs at every draw, so the Example follows the
    settings the moment they change. Silver opens again after the line, for a
    locale whose label continues past its %s.
]]
function ns.OptionsExample(order, lineFunction, hidden)
	return {
		type = "description",
		name = function()
			local body = lineFunction()
			local line = body and ns.BuildPrintLine(body) or ""
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
	return (message:gsub("{rt(%d)}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:14|t"))
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
		imageWidth = 18,
		imageHeight = 18,
		width = 0.15,
		order = order,
		hidden = hidden,
		func = playSound,
	}
end

--------------------------------------------------------------------------------
-- Toggle Pairs
--------------------------------------------------------------------------------

--[[
    Lays toggles out two to a line, each pair in its own unnamed inline group so
    every pair pins its own row. The widths leave slack under
    ns.OPTIONS_ROW_WIDTH: a row summing exactly to the pane sits on the wrap
    boundary and can drop its second toggle onto a line of its own.
]]
local TOGGLE_PAIR_WIDTH = (ns.OPTIONS_ROW_WIDTH - 0.2) / 2

function ns.OptionsTogglePairs(args, keyPrefix, startOrder, toggles)
	for index = 1, #toggles, 2 do
		local pair = {}
		for offset = 0, 1 do
			local toggle = toggles[index + offset]
			if toggle then
				toggle.width = TOGGLE_PAIR_WIDTH
				toggle.order = offset + 1
				pair["toggle" .. (offset + 1)] = toggle
			end
		end
		args[keyPrefix .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = startOrder + index,
			args = pair,
		}
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
    Every feature's on/off switch, drawn twice: in the root panel's Features
    section, two to a line, and atop the feature's own panel. Both copies come
    from here, so they share one caption, one tooltip and one setter, and a
    change repaints every panel so neither copy shows a stale box.

    A switch on an Automated Appreciation feature (`appreciation`, its key in
    ns.FEATURE_SWITCHES) goes through ns.SetFeatureSwitch, the one setter the
    mini-map button and the Buff Duty window's close button use too. The rest
    read and write their own account-wide key.

    `confirmOff` asks before a switch that keeps macros current turns off:
    off stops the updates and leaves every macro as it last was, which a
    player could take for deleting them. The prompt says it doesn't, and turning
    the switch on never asks.

    FEATURE_GROUPS is the order the root panel draws them, left to right then
    down, and the order the settings tree lists the features' panels. Each
    group is a block of rows, with a blank line between blocks.
]]
local FEATURE_SWITCHES = {
	BuffDuty = {
		appreciation = "buffWindow",
		name = "BUFF_DUTY_ENABLE",
		desc = "SWITCH_BUFF_DUTY_DESCRIPTION",
	},
	Restocker = {
		key = "restockerEnabled",
		name = "OPTIONS_RESTOCKER_ENABLE",
		desc = "SWITCH_RESTOCKER_DESCRIPTION",
		set = function(value)
			ns.SetRestockerEnabled(value)
			ns.UpdateMinimapIcon()
		end,
	},
	Spellbook = {
		name = "SWITCH_SPELLBOOK",
		desc = "SWITCH_SPELLBOOK_DESCRIPTION",
		confirmOff = "SWITCH_SPELLBOOK_CONFIRM_OFF",
		get = function()
			return ns.IsSpellbookEnabled()
		end,
		set = function(value)
			ns.SetSpellbookEnabled(value)
		end,
	},
	Macros = {
		key = "macrosEnabled",
		name = "SWITCH_MACROS",
		desc = "SWITCH_MACROS_DESCRIPTION",
		confirmOff = "SWITCH_MACROS_CONFIRM_OFF",
		set = function(value)
			ns.SetMacrosEnabled(value)
		end,
	},
	InventoryReport = {
		key = "inventoryReport",
		name = "SWITCH_INVENTORY_REPORT",
		desc = "SWITCH_INVENTORY_REPORT_DESCRIPTION",
		set = function(value)
			ns.SetInventoryReportEnabled(value)
		end,
	},
	ReadinessReport = {
		key = "readinessReportEnabled",
		name = "SWITCH_READINESS_REPORT",
		desc = "SWITCH_READINESS_REPORT_DESCRIPTION",
		set = function(value)
			ns.db.global.readinessReportEnabled = value
			ns.SyncReadinessReportEvents()
		end,
	},
	StrangerBuffs = {
		appreciation = "strangers",
		name = "STRANGERS_ENABLE",
		desc = "SWITCH_STRANGER_BUFFS_DESCRIPTION",
	},
	GoodNews = {
		appreciation = "goodNews",
		name = "SWITCH_GOOD_NEWS",
		desc = "SWITCH_GOOD_NEWS_DESCRIPTION",
	},
	CombatBuffs = {
		appreciation = "teammates",
		name = "SWITCH_COMBAT_BUFFS",
		desc = "SWITCH_COMBAT_BUFFS_DESCRIPTION",
	},
	ServiceAlerts = {
		appreciation = "services",
		name = "SWITCH_SERVICE_ALERTS",
		desc = "SWITCH_SERVICE_ALERTS_DESCRIPTION",
	},
}

ns.FEATURE_GROUPS = {
	{ "BuffDuty", "Restocker", "Spellbook", "Macros" },
	{ "InventoryReport", "ReadinessReport" },
	{ "StrangerBuffs", "GoodNews", "CombatBuffs", "ServiceAlerts" },
}

local function NotifyAllPanels()
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(name)
	end
end

local function GetSwitch(switch)
	if not ns.db then
		return false
	end
	if switch.get then
		return switch.get()
	end
	if switch.appreciation then
		return ns.IsFeatureOn(switch.appreciation)
	end
	return ns.db.global[switch.key]
end

local function SetSwitch(switch, value)
	if switch.appreciation then
		-- Repaints every panel itself.
		ns.SetFeatureSwitch(switch.appreciation, value)
		return
	end
	if switch.set then
		switch.set(value)
	else
		ns.db.global[switch.key] = value
	end
	NotifyAllPanels()
end

function ns.OptionsFeatureSwitch(feature, order, width)
	local switch = FEATURE_SWITCHES[feature]
	return {
		type = "toggle",
		name = L[switch.name],
		desc = L[switch.desc],
		order = order,
		width = width or "full",
		-- A string asks first; anything else changes the box at once.
		confirm = switch.confirmOff and function(_, value)
			if not value then
				return L[switch.confirmOff]
			end
		end or nil,
		get = function()
			return GetSwitch(switch)
		end,
		set = function(_, value)
			SetSwitch(switch, value)
		end,
	}
end

--[[
    The root panel's Features section: every switch, two to a line, group by
    group in FEATURE_GROUPS. Each group takes ten orders from startOrder on,
    a blank line opening every group after the first.
]]
function ns.OptionsFeatureSwitchRows(args, keyPrefix, startOrder)
	for groupIndex, group in ipairs(ns.FEATURE_GROUPS) do
		local groupOrder = startOrder + (groupIndex - 1) * 10
		local groupPrefix = keyPrefix .. groupIndex
		if groupIndex > 1 then
			args[groupPrefix .. "Space"] = ns.OptionsSpacer(groupOrder)
		end
		local toggles = {}
		for _, feature in ipairs(group) do
			toggles[#toggles + 1] = ns.OptionsFeatureSwitch(feature)
		end
		ns.OptionsTogglePairs(args, groupPrefix .. "Row", groupOrder, toggles)
	end
end

--------------------------------------------------------------------------------
-- Shared Values
--------------------------------------------------------------------------------

--[[
    When-to-use mode labels, by group or by level, shared by every mode
    dropdown: Buff Food, Scroll Buffs, Pet Food Buffs, and Use Conjured Food &
    Water First. Every dropdown offers all six in this order, none trimmed per
    feature even where one reads oddly, and one choice is one condition:
    group and level never combine.
]]
ns.MODE_VALUES = {
	always = L["MODE_ALWAYS"],
	solo = L["MODE_SOLO"],
	party = L["MODE_PARTY"],
	raid = L["MODE_RAID"],
	leveling = L["MODE_LEVELING"],
	maxlevel = L["MODE_MAX_LEVEL"],
}

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    C_Item.GetItemInfo answers nil for an item the client has not cached yet, which is
    the normal state for a list of item ids on a fresh login -- nothing has put
    those items in front of the player, so nothing has pulled their data. A panel
    that lists items renders those rows as L["LOADING_ITEM"] and hands the cold
    ids here.

    Each id is requested from the server, and the panel's registry name holds a
    GET_ITEM_INFO_RECEIVED waiter (ns.RequestItemInfoEvents) while any id it
    handed in is still outstanding. The shared item-info dispatcher
    (Features/Item-Info.lua) passes every answer to
    ns.OnOptionsItemInfoReceived below, which repaints the panels waiting on
    that id and releases a panel's waiter once nothing it asked about is left.
    A repaint that re-enters with still-cold ids, or a row added mid-load, just
    adds to the panel's pending set. An id the client has no item for, one
    whose answer already failed, or one already cached is never requested: no
    answer may come for it, so a wait on it could hold the event for the rest
    of the session.

    A window that is not an AceConfig panel (the Staples window) passes its own
    key and an onArrive to call in place of the repaint.
]]

-- registryName -> { [itemID] = true }, the ids each panel still waits on.
local warming = {}

-- registryName -> the function a non-AceConfig window repaints itself with.
local arriveHandlers = {}

-- [itemID] = true for every id whose answer came back failed this session.
local failedItemIDs = {}

local function WaiterKey(registryName)
	return "options:" .. registryName
end

function ns.WarmItemCache(itemIDs, registryName, onArrive)
	if not (itemIDs and itemIDs[1] and registryName) then
		return
	end
	arriveHandlers[registryName] = onArrive

	local pending = warming[registryName] or {}
	local requested = false
	for _, itemID in ipairs(itemIDs) do
		local cold = not C_Item.IsItemDataCachedByID(itemID)
		if cold and not failedItemIDs[itemID] and C_Item.DoesItemExistByID(itemID) then
			pending[itemID] = true
			C_Item.RequestLoadItemDataByID(itemID)
			requested = true
		end
	end
	if requested then
		warming[registryName] = pending
		ns.RequestItemInfoEvents(WaiterKey(registryName))
	end
end

--[[
    One GET_ITEM_INFO_RECEIVED answer, handed on by Features/Item-Info.lua's dispatcher
    after the Restocker has forgotten the item's remembered miss. A failed answer settles
    the wait too, and is remembered so the repaint that follows does not ask
    again: its row keeps its loading text.
]]
function ns.OnOptionsItemInfoReceived(itemID, success)
	if success ~= true then
		failedItemIDs[itemID] = true
	end
	for registryName, pending in pairs(warming) do
		if pending[itemID] then
			pending[itemID] = nil
			if arriveHandlers[registryName] then
				arriveHandlers[registryName]()
			else
				AceConfigRegistry:NotifyChange(registryName)
			end
			if next(pending) == nil then
				warming[registryName] = nil
				ns.ReleaseItemInfoEvents(WaiterKey(registryName))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

--[[
    Two shapes reach an add box: a bare id the player looked up, and a whole item
    link, which is what shift-clicking an item link in chat drops into a focused
    edit box. Anything else is rejected, so a stray word never becomes a row that
    renders as an unresolvable id forever.
]]
function ns.ParseItemInput(rawInput)
	if type(rawInput) ~= "string" then
		return nil
	end

	local itemID = tonumber(rawInput:match("item:(%d+)") or rawInput:match("^%s*(%d+)%s*$"))
	if itemID and itemID > 0 then
		return itemID
	end
	return nil
end

--------------------------------------------------------------------------------
-- Item Identifier Sort
--------------------------------------------------------------------------------

--[[
    Sorted by name, because a list ordered by id reads as random to the player.
    Items the client has not cached yet have no name to sort on, so they fall to
    the bottom by id rather than clustering under an empty string at the top;
    they re-sort into place as the panel repaints. Equal names tie-break on id,
    which makes the comparator a total order -- without it two identically named
    items compare equal and their rows reshuffle on every repaint.
]]
function ns.SortItemIdentifiersByName(identifiers)
	table.sort(identifiers, function(a, b)
		local nameA = C_Item.GetItemInfo(a) or ""
		local nameB = C_Item.GetItemInfo(b) or ""
		if nameA == nameB then
			return a < b
		end
		if nameA == "" then
			return false
		end
		if nameB == "" then
			return true
		end
		return nameA < nameB
	end)
end

--------------------------------------------------------------------------------
-- Item Display
--------------------------------------------------------------------------------

--[[
    One row's item, rendered for the ItemLink widget below: icon plus the item's
    name in its link's own color, so quality reads at a glance, and without the
    link's brackets (ns.UnbracketItemLink), which the icon makes redundant. An
    id the client has not answered for yet shows as loading text instead --
    ns.WarmItemCache repaints the panel as the data lands.
]]
function ns.GetItemDisplayName(itemID)
	local _, itemLink, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)

	if itemLink and icon then
		return format("|T%s:16|t %s", icon, ns.UnbracketItemLink(itemLink))
	elseif itemLink then
		return ns.UnbracketItemLink(itemLink)
	end

	return GetColor("MUTED") .. format(L["LOADING_ITEM"], itemID) .. "|r"
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
--------------------------------------------------------------------------------

--[[
    Every player-managed item list renders through here, so lists add and remove
    the same way in every panel. The caller supplies the labels, the source
    table, and the callbacks; this owns the shape. Spec:

      getSourceTable: function returning the table of itemID keys to list
      onAdd: function(itemID) adding an item to that source
      onRemove: function(itemID) removing one
      notifyKey: AceConfigRegistry name to NotifyChange on every mutation
      labels: { addName, addHelp, addInvalid, removeDesc, empty }
      rowWidth: optional total row budget, default ns.OPTIONS_ROW_WIDTH
      startOrder: optional first order, so a panel can seat its own head above
      actionColumn: optional per-row button, { width, name, desc, func(itemID) }
        (the Ignore List's Global button)
      addFromBags: optional true to put an Add from Bags picker above the add
        box, listing what the player carries that isn't on the list yet
        (labels then carry fromBagsName and fromBagsDesc)
      onClear: optional function emptying the list, for a Clear List button
        under the rows (labels then carry clearName, clearDesc, clearConfirm)

    Restore Defaults is deliberately absent: it belongs to lists that ship
    defaults, and every list here starts empty, so Clear List is what returns
    one to its default.
]]

--[[
    Remove is an icon, not a labeled button. An execute carrying an image renders
    as an AceGUI Icon; the stock Button insets its font string 15px from each
    edge, which in a column this narrow clips a caption to a sliver. The
    group-loot pass texture is already the game's own "get rid of this" mark, and
    name stays empty so the Icon draws no caption -- the label rides in desc,
    which AceConfigDialog shows on hover.
]]
local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
local REMOVE_ICON_SIZE = 16

-- A row's remove icon; confirmText, when given, asks first.
function ns.OptionsRemoveIcon(desc, order, func, confirmText)
	return {
		type = "execute",
		name = "",
		desc = desc,
		image = REMOVE_ICON,
		imageWidth = REMOVE_ICON_SIZE,
		imageHeight = REMOVE_ICON_SIZE,
		width = ns.OPTIONS_REMOVE_ICON_WIDTH,
		order = order,
		confirm = confirmText ~= nil,
		confirmText = confirmText,
		func = func,
	}
end

--[[
    The Add from Bags picker's choices: one entry per distinct item in the
    carried bags that the list doesn't hold yet, as icon and link, sorted by
    name. Built on every repaint, which the list panels get after each edit; an
    item looted while the panel stays open shows up on the next one. The game
    closes the bags when the options open, so this is the only way to pick an
    item without knowing its id.
]]
local function GetCarriedItemChoices(sourceTable)
	local values, sorting, seen = {}, {}, {}

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local itemID = info and info.itemID
			if itemID and not seen[itemID] and not (sourceTable and sourceTable[itemID]) then
				seen[itemID] = true
				values[itemID] = ns.GetItemDisplayName(itemID)
				sorting[#sorting + 1] = itemID
			end
		end
	end

	ns.SortItemIdentifiersByName(sorting)
	return values, sorting
end

function ns.BuildItemListOptions(spec)
	local labels = spec.labels
	local rowWidth = spec.rowWidth or ns.OPTIONS_ROW_WIDTH
	local args = {}
	local order = spec.startOrder or 1

	--[[
	    Clear List goes last, under the rows, at normal width: the top of a list
	    is for finding and adding, and a rarely used reset shouldn't be the first
	    thing there. Ordered far past any row so it lands last however long the
	    list is, and shown only while the list holds something.
	]]
	if spec.onClear and next(spec.getSourceTable() or {}) ~= nil then
		args.spacerClear = ns.OptionsSpacer(9998)
		args.clearList = {
			type = "execute",
			name = labels.clearName,
			desc = labels.clearDesc,
			confirm = true,
			confirmText = labels.clearConfirm,
			order = 10000,
			func = function()
				spec.onClear()
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
	end

	--[[
	    The add rows' controls keep the standard control width, as Magic Eraser's
	    do, so a picked item's name has room; the label takes what the list's own
	    row budget leaves, so each row still ends where the item rows below it end.
	]]
	local addLabelWidth = rowWidth - ns.OPTIONS_CONTROL_WIDTH

	if spec.addFromBags then
		local values, sorting = GetCarriedItemChoices(spec.getSourceTable())

		args.addFromBagsLabel = ns.OptionsRowLabel(labels.fromBagsName, order, addLabelWidth)
		order = order + 1

		-- get returns nil so the picker reads empty again after each add.
		args.addFromBagsSelect = {
			type = "select",
			name = "",
			desc = labels.fromBagsDesc,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			values = values,
			sorting = sorting,
			disabled = function()
				return sorting[1] == nil
			end,
			get = function()
				return nil
			end,
			set = function(_, itemID)
				spec.onAdd(itemID)
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
		order = order + 1
	end

	args.addItemLabel = ns.OptionsRowLabel(labels.addName, order, addLabelWidth)
	order = order + 1

	--[[
	    get returns empty so the box clears itself on the repaint that follows
	    each add. validate rejects anything ParseItemInput cannot read and any id
	    this client has no item for, which is what keeps a typo out of the list
	    rather than into it as a dead row.
	]]
	args.addItemInput = {
		type = "input",
		name = "",
		desc = labels.addHelp,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		validate = function(_, value)
			local itemID = ns.ParseItemInput(value)
			return (itemID and C_Item.DoesItemExistByID(itemID)) and true or labels.addInvalid
		end,
		get = function()
			return ""
		end,
		set = function(_, value)
			local itemID = ns.ParseItemInput(value)
			if not itemID then
				return
			end
			spec.onAdd(itemID)
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end,
	}
	order = order + 1

	args.spacerRows = ns.OptionsSpacer(order)
	order = order + 1

	local identifiers = {}
	for itemID in pairs(spec.getSourceTable() or {}) do
		identifiers[#identifiers + 1] = itemID
	end

	if #identifiers == 0 then
		args.descEmpty = ns.OptionsDesc(GetColor("HELP") .. labels.empty .. "|r", order)
		return args
	end

	ns.SortItemIdentifiersByName(identifiers)

	local actionColumn = spec.actionColumn
	local itemWidth = rowWidth - ns.OPTIONS_REMOVE_ICON_WIDTH
	if actionColumn then
		itemWidth = itemWidth - actionColumn.width
	end

	local coldItemIDs = {}

	for _, itemID in ipairs(identifiers) do
		local capturedID = itemID

		if not C_Item.GetItemInfo(capturedID) then
			coldItemIDs[#coldItemIDs + 1] = capturedID
		end

		--[[
		    AceGUI's flow layout has no notion of a row: it packs widgets left to
		    right and wraps only when the next will not fit, so laid out flat,
		    cells from different items run together the moment the leftover space
		    takes the next item's name. An inline group with an empty name renders
		    as a bare SimpleGroup -- no border, no title, no padding -- at "fill"
		    width, and the flow layout always gives a fill widget its own line. The
		    cells then flow inside it, so every row breaks at the same points.
		]]
		local cells = {
			item = {
				type = "input",
				name = "",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				width = itemWidth,
				order = 1,
				get = function()
					return tostring(capturedID)
				end,
				set = function() end,
			},
		}

		if actionColumn then
			cells.action = {
				type = "execute",
				name = actionColumn.name,
				desc = actionColumn.desc,
				width = actionColumn.width,
				order = 2,
				func = function()
					actionColumn.func(capturedID)
					AceConfigRegistry:NotifyChange(spec.notifyKey)
				end,
			}
		end

		-- Removing one row takes one click and no confirm.
		cells.remove = ns.OptionsRemoveIcon(labels.removeDesc, 3, function()
			spec.onRemove(capturedID)
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end)

		args["item_" .. tostring(capturedID)] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = cells,
		}
		order = order + 1
	end

	ns.WarmItemCache(coldItemIDs, spec.notifyKey)

	return args
end

--------------------------------------------------------------------------------
-- Item Link Widget
--------------------------------------------------------------------------------

--[[
    A label that draws an item and shows that item's own tooltip on hover, used
    via dialogControl on the rows the builder above emits. AceConfig renders a
    description as a plain Label, which has no mouse scripts at all and so never
    fires an OnEnter; this is that same widget with mouse handling, so the row
    can carry a real GameTooltip. The option's get returns the item id as a
    string and SetText resolves it through ns.GetItemDisplayName.
]]
local ITEM_LINK_WIDGET_VERSION = 1

local function OnItemLinkEnter(frame)
	local widget = frame.obj
	if not widget.itemID then
		return
	end
	--[[
	    The bare "item:id" form rather than the link off C_Item.GetItemInfo, so a row
	    still waiting on its item data gets a tooltip too -- and hovering it pulls
	    the very data the row is waiting for.
	]]
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:" .. widget.itemID)
	GameTooltip:Show()
end

local function OnItemLinkLeave()
	GameTooltip:Hide()
end

local itemLinkMethods = {}

function itemLinkMethods:OnAcquire()
	self.itemID = nil
	self:SetHeight(20)
end

function itemLinkMethods:OnRelease()
	self.itemID = nil
end

function itemLinkMethods:SetText(text)
	local itemID = tonumber(text)
	if itemID then
		self.itemID = itemID
		self.label:SetText(ns.GetItemDisplayName(itemID))
	else
		self.label:SetText(text or "")
	end
end

function itemLinkMethods:GetText()
	return self.itemID and tostring(self.itemID) or ""
end

-- AceConfigDialog drives every input control through these; a row is read-only.
function itemLinkMethods:SetLabel() end

function itemLinkMethods:SetMaxLetters() end

function itemLinkMethods:SetDisabled() end

local function ItemLinkWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetHeight(20)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnItemLinkEnter)
	frame:SetScript("OnLeave", OnItemLinkLeave)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT")
	label:SetPoint("BOTTOMRIGHT")

	local widget = {
		label = label,
		frame = frame,
		type = ns.ITEM_LINK_WIDGET_TYPE,
	}

	for method, func in pairs(itemLinkMethods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(ns.ITEM_LINK_WIDGET_TYPE, ItemLinkWidgetConstructor, ITEM_LINK_WIDGET_VERSION)

--------------------------------------------------------------------------------
-- Icon Checkbox Widget
--------------------------------------------------------------------------------

--[[
    The stock AceGUI checkbox with air between its icon and its label, for a
    toggle that stands for an item: a staple in the staples pop-up, a macro on
    the Consumable Macros panel. The stock widget sets the label a pixel off the image,
    which suits a status glyph and crowds an item icon, so these rows take the
    gap the Restock List's own rows put between an icon and its name.

    AceConfig has no setting for that gap, so this is a widget type of its own:
    the stock checkbox, built by the stock constructor and handed back with its
    label put where the row wants it every time the stock code places it --
    when the image is set, and on the press and the release, which nudge the
    label and put it back. It is registered under a name of ours, so the shared
    CheckBox type, and every other add-on's checkboxes, stay exactly as they
    were.

    A skin that restyles checkboxes does so as the stock constructor registers
    the widget, before it is renamed here, so these rows are skinned like any
    other checkbox.

    A toggle wears it with three fields: image (the item's icon), imageCoords
    (ns.OPTIONS_ICON_TEXCOORDS) and dialogControl (ns.ICON_CHECKBOX_WIDGET_TYPE).
]]
local ICON_CHECKBOX_WIDGET_VERSION = 1
local ICON_LABEL_GAP = ns.RESTOCK_ICON_TEXT_GAP
-- The stock press: the label a pixel right and a pixel down while the mouse is held.
local PRESS_NUDGE = 1

-- The stock icon border, cropped away so an icon sits clean beside its checkbox.
ns.OPTIONS_ICON_TEXCOORDS = { 0.08, 0.92, 0.08, 0.92 }

-- Only a row showing an icon: without one the label sits against the box, where the stock code left it.
local function PlaceIconLabel(widget, nudge)
	if widget.image:GetTexture() then
		widget.text:SetPoint("LEFT", widget.image, "RIGHT", ICON_LABEL_GAP + nudge, -nudge)
	end
end

local function IconCheckBoxConstructor()
	local widget = AceGUI.WidgetRegistry.CheckBox()
	widget.type = ns.ICON_CHECKBOX_WIDGET_TYPE

	local SetImage = widget.SetImage
	function widget:SetImage(...)
		SetImage(self, ...)
		PlaceIconLabel(self, 0)
	end
	-- Hooked, so each runs after the stock handler has placed the label its own way.
	widget.frame:HookScript("OnMouseDown", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, PRESS_NUDGE)
		end
	end)
	widget.frame:HookScript("OnMouseUp", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, 0)
		end
	end)
	return widget
end

--[[
    The name is cleared where there is no stock checkbox to build on, and a
    toggle then asks for no control of its own: AceConfigDialog reports a
    control type it cannot create as an error on every repaint before it falls
    back.
]]
if AceGUI.WidgetRegistry and AceGUI.WidgetRegistry.CheckBox then
	AceGUI:RegisterWidgetType(ns.ICON_CHECKBOX_WIDGET_TYPE, IconCheckBoxConstructor, ICON_CHECKBOX_WIDGET_VERSION)
else
	ns.ICON_CHECKBOX_WIDGET_TYPE = nil
end

--------------------------------------------------------------------------------
-- Shared Panel Helpers
--------------------------------------------------------------------------------

--[[
    The title drawn at the top of a sub-panel: "Combat Buffs > Tracked
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
