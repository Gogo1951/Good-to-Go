local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local Kit = ns.OptionsKit

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
    Each row shows the key the player bound, or a muted Not Bound, and a Set Key
    button that opens the game's Key Bindings list through ns:OpenKeyBindings
    (Features/Key-Bindings.lua), so the key is set where the game's own are.
    The binding name is Bindings.xml's name attribute; the caption is the same
    string the Key Bindings list prints. OnUpdateBindings (Features/Key-Bindings.lua)
    repaints this panel
    when the player changes a key.

    The descKey line says what the key does. Cast Next Buff's then has the
    macro line that presses the same key in a box of its own, a spacer
    above and below, to click and copy. It is passed in as the line's %s too,
    for a translation still written around it.
]]
local function KeyBindings()
	return {
		-- { bindingName, captionKey, descKey, descArgument }
		{ ns.BUFF_KEY_COMMAND, "BUFF_KEY", "OPTIONS_KEY_BINDING_BUFF_DESCRIPTION", ns.BUFF_KEY_MACRO },
		{ "GOODTOGO_TOGGLE_SPELLBOOK", "BINDING_TOGGLE_PAGE", "OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION" },
	}
end

--[[
    The caption takes the grid's label width, so the key lines up with every
    other row's control, and the key and Set Key share the control column.
]]
local KEY_STATUS_WIDTH = 0.75
local KEY_BUTTON_WIDTH = 0.55

local function GetBindingStatus(bindingName)
	local key = GetBindingKey(bindingName)
	if not key then
		return GetColor("MUTED") .. NOT_BOUND .. "|r"
	end
	local text = (GetBindingText and GetBindingText(key)) or key
	return GetColor("TEXT") .. text .. "|r"
end

local function KeyBindingDescription(descKey, argument)
	local text = L[descKey]
	if argument then
		text = text:format(GetColor("INFO") .. argument .. "|r" .. GetColor("HELP"))
	end
	return GetColor("HELP") .. text .. "|r"
end

-- Each binding is its row (caption, key, Set Key), then its description under it.
local function AddKeyBindingRows(args, startOrder)
	local order = startOrder

	for index, entry in ipairs(KeyBindings()) do
		local bindingName, captionKey, descKey, descArgument = entry[1], entry[2], entry[3], entry[4]

		if index > 1 then
			args["spacerKeyBinding" .. index] = Spacer(order)
			order = order + 0.01
		end

		args["rowKeyBinding" .. index] = Kit.Row(order, nil, {
			Kit.Label(GetColor("INFO") .. L[captionKey] .. "|r", nil, Kit.LABEL_WIDTH),
			{
				type = "description",
				name = function()
					return GetBindingStatus(bindingName)
				end,
				fontSize = "medium",
				width = KEY_STATUS_WIDTH,
			},
			{
				type = "execute",
				name = L["OPTIONS_KEY_SET"],
				desc = L["OPTIONS_KEY_SET_DESCRIPTION"],
				width = KEY_BUTTON_WIDTH,
				func = function()
					ns:OpenKeyBindings()
				end,
			},
		})
		order = order + 0.01

		args["descKeyBinding" .. index] = Desc(KeyBindingDescription(descKey, descArgument), order)
		order = order + 0.01

		if descArgument then
			args["spaceKeyMacro" .. index] = Spacer(order)
			order = order + 0.01
			args["inputKeyMacro" .. index] = {
				type = "input",
				name = "",
				order = order,
				width = ns.OPTIONS_ROW_WIDTH,
				get = function()
					return descArgument
				end,
				set = function() end,
			}
			order = order + 0.01
			args["spaceKeyMacroAfter" .. index] = Spacer(order)
			order = order + 0.01
		end
	end
end

--------------------------------------------------------------------------------
-- General Panel
--------------------------------------------------------------------------------

--[[
    The root page, in the Style Guide's Main Page Layout order: intro, Welcome
    Message, Mini-map Button, Features (every feature's on/off switch, two to a
    line), Key Bindings and /Commands. Every toggle on this page is account-wide
    (ns.db.global). Each Features switch is the same toggle that heads its
    feature's own panel (Kit.FeatureSwitch, from ns.FEATURES).

    Order values are grouped in spaced blocks so sections can be reordered or
    extended without renumbering their neighbors.
]]
function ns.BuildGeneralOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),

		-- Welcome Message
		spaceWelcome0 = Spacer(10),
		toggleWelcomeMessage = {
			type = "toggle",
			name = L["OPTIONS_WELCOME_MESSAGE"],
			desc = L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"],
			order = 11,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showWelcome
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.showWelcome = value
				end
				ns.RefreshSettings()
			end,
		},

		-- Mini-map Button
		toggleMinimapButton = {
			type = "toggle",
			name = L["OPTIONS_MINIMAP_BUTTON"],
			desc = L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"],
			order = 13,
			width = "full",
			get = function()
				return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.minimap.hide = not value
					ns:ApplyMinimapButton()
				end
				ns.RefreshSettings()
			end,
		},

		-- Features
		spaceFeatures0 = Spacer(20),
		headerFeatures = Header(L["OPTIONS_FEATURES_HEADER"], 21),
		spaceFeatures1 = Spacer(22),
		switchesFeatures = Kit.FeatureSwitches(23),

		-- Key Bindings: the rows fill 63 onward.
		spaceKeyBindings0 = Spacer(60),
		headerKeyBindings = Header(L["OPTIONS_KEY_BINDINGS_HEADER"], 61),
		spaceKeyBindings1 = Spacer(62),

		-- /Commands
		spaceCommands0 = Spacer(90),
		headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 91),
		spaceCommands1 = Spacer(92),
		descCommands = Desc(
			GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
			93
		),
		spaceCommands2 = Spacer(94),
		descCommandsRestocker = Desc(
			GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. "  " .. L["RESTOCKER_COMMAND_DESCRIPTION"],
			95
		),
	}

	-- Rank Watch's ignore command, wherever its TOC loads it.
	if ns.IgnoreRankWatchPlayer then
		args.spaceCommands3 = Spacer(96)
		args.descCommandsRankWatchIgnore = Desc(
			GetColor("INFO")
				.. L["RANK_WATCH_IGNORE_COMMAND"]
				.. "|r"
				.. "  "
				.. L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"],
			97
		)
	end

	AddKeyBindingRows(args, 63)

	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = args,
	}
end
