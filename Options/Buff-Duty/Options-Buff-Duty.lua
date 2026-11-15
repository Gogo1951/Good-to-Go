local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--[[
    "Buff Duty" panel -- the click-to-cast list of group members missing a buff
    you can give (Features/Buff-Duty/Buff-Duty.lua, data in this client's
    Data/{Game}/Buff-Duty-Spells-{Game}.lua). The enable switch at the top,
    twinned in the root panel's Features section, is the master; everything
    below it hides while it is off. Each optional row of the window has its
    switch here, Self Buffs and Weapon Buffs included. The Cast Next Buff key's
    binding is on the root panel, with every other key binding. What each buff
    is offered to lives in three sub-panels of this one: Group Buffs
    (Options-Buff-Duty-Buffs.lua), Self-Buffs
    (Options-Buff-Duty-Self-Buffs.lua) and Weapon Buffs
    (Options-Buff-Duty-Weapon-Buffs.lua). The ask whispered to other classes
    is the player's to word, in the whisper composer under Ask Other Classes
    for Buffs (Options/Options-Message-Composer.lua).

    Every window setting's setter ends in ns.RefreshBuffDuty, which rebuilds
    the castable list and redraws the window.
]]

function ns.BuildBuffDutyOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end
	local function Hidden()
		return not Settings().enabled
	end

	local function Toggle(key, name, desc, order, width)
		return {
			type = "toggle",
			name = name,
			desc = desc,
			width = width or "full",
			order = order,
			hidden = Hidden,
			get = function()
				return Settings()[key]
			end,
			set = function(_, value)
				Settings()[key] = value
				ns.RefreshBuffDuty()
			end,
		}
	end

	--[[
	    The asks' sample buff: the Mage's raid buff where this client has one,
	    else the first raid buff in its data, linked at its top rank the way
	    the window links it. Nil where the client has no raid buff.
	]]
	local function SampleAskLink()
		local pick
		for _, entry in ipairs(ns.BuffDuty.entries) do
			if entry.row.group and not entry.row.exclusive then
				if entry.row.class == "MAGE" then
					pick = entry
					break
				end
				pick = pick or entry
			end
		end
		if not pick then
			return nil
		end
		local id = pick.ids[#pick.ids]
		return ns.GetSpellLink(id) or C_Spell.GetSpellName(id) or ""
	end

	-- Two of the sample names, missing the sample buff.
	local function SampleAskNames()
		return { ns.SAMPLE_NAMES.PRIEST, ns.SAMPLE_NAMES.SHAMAN }
	end

	-- The Example line for the ask the Party-Buffs hover menu's Ask row sends, as the group reads it.
	local function AskExample()
		local names = SampleAskNames()
		return Kit.SentLine("PARTY", ns:BuildBuffRequestMessage(names, #names, SampleAskLink() or ""))
	end

	local function AskHidden()
		return Hidden() or not Settings().askOtherClasses
	end

	-- No Example where the client has no raid buff to ask for.
	local function AskExampleHidden()
		return AskHidden() or not SampleAskLink()
	end

	--[[
	    When to Show's rows: the shared group context checkboxes
	    (ns.OptionsGroupContextToggle), one to a row. Solo, Party and Raid each
	    take a where dropdown on their row (Kit.ToggleRow), Anywhere or In
	    Instance, shown only while the box beside it is ticked, like Return the
	    Favor's. Battleground has none: a battleground or arena is always an
	    instance.
	]]
	local function ShowIn()
		return Settings().showIn
	end
	local whereValues = {}
	for _, value in ipairs(Data.BUFF_DUTY_WHERE_ORDER) do
		whereValues[value] = L["BUFF_DUTY_WHERE_" .. value]
	end
	local function ShowInRow(context, order)
		local where = {
			type = "select",
			desc = L["BUFF_DUTY_WHERE_DESCRIPTION"],
			values = whereValues,
			sorting = Data.BUFF_DUTY_WHERE_ORDER,
			get = function()
				return Settings().showWhere[context]
			end,
			set = function(_, value)
				Settings().showWhere[context] = value
				ns.RefreshBuffDuty()
			end,
		}
		local toggle = ns.OptionsGroupContextToggle(context, nil, nil, ShowIn, ns.RefreshBuffDuty)
		return Kit.ToggleRow(order, toggle, { control = where, hidden = Hidden })
	end

	-- How long a stranger who buffed you stays listed: Return the Favor's setting.
	local function FavorSeconds()
		return {
			type = "select",
			desc = L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"],
			values = function()
				local values = {}
				for _, seconds in ipairs(ns.Data.BUFF_DUTY_FAVOR_CHOICES) do
					values[seconds] = ns.FormatDuration(seconds)
				end
				return values
			end,
			sorting = ns.Data.BUFF_DUTY_FAVOR_CHOICES,
			get = function()
				return Settings().favorSeconds
			end,
			set = function(_, value)
				Settings().favorSeconds = value
				ns.RefreshBuffDuty()
			end,
		}
	end

	local options = {
		name = L["TAB_BUFF_DUTY"],
		type = "group",
		args = {
			descIntro = Kit.Desc(L["BUFF_DUTY_DESCRIPTION"], 1),
			space0 = Kit.Spacer(2),
			enable = Kit.FeatureSwitch("buffWindow.enabled", 3),
			--[[
			    A status line, shown only on a class with nothing on the list: the
			    switch above is on, and the window will still never appear.
			]]
			noBuffs = Kit.StatusLine(function()
				if Hidden() or ns.BuffDutyHasClassRows() then
					return nil
				end
				return L["BUFF_DUTY_NO_BUFFS"]
			end, 4),
			space1 = Kit.Spacer(5, Hidden),

			--[[
			    When the window may show at all: in which group contexts, and on
			    which classes. The class toggles are added to `classes` below.
			]]
			headerWhen = Kit.Header(L["BUFF_DUTY_WHEN_HEADER"], 5.1, Hidden),
			spaceWhen0 = Kit.Spacer(5.11, Hidden),
			descWhen = Kit.Desc(L["BUFF_DUTY_WHEN_DESCRIPTION"], 5.12, Hidden),
			spaceWhen1 = Kit.Spacer(5.13, Hidden),
			showSolo = ShowInRow("solo", 5.14),
			spaceWhen2 = Kit.Spacer(5.16, Hidden),
			showParty = ShowInRow("party", 5.17),
			spaceWhen3 = Kit.Spacer(5.18, Hidden),
			showRaid = ShowInRow("raid", 5.185),
			spaceWhen4 = Kit.Spacer(5.1925, Hidden),
			showBattleground = ns.OptionsGroupContextToggle(
				"battleground",
				5.1935,
				"full",
				ShowIn,
				ns.RefreshBuffDuty,
				Hidden
			),
			noneWhen = ns.OptionsGroupContextNone(L["BUFF_DUTY_WHEN_NONE"], 5.194, ShowIn, Hidden),
			spaceWhen5 = Kit.Spacer(5.195, Hidden),
			descClasses = Kit.Desc(L["BUFF_DUTY_CLASSES_DESCRIPTION"], 5.2, Hidden),
			spaceClasses0 = Kit.Spacer(5.21, Hidden),
			classes = {
				type = "group",
				name = "",
				order = 5.3,
				inline = true,
				hidden = Hidden,
				args = {},
			},
			spaceClasses1 = Kit.Spacer(5.4, Hidden),

			--[[
			    The window's optional rows, in the order it shows them: your self
			    buffs above the group, the players outside it below.
			]]
			headerShow = Kit.Header(L["BUFF_DUTY_SHOW_HEADER"], 6, Hidden),
			space2 = Kit.Spacer(7, Hidden),
			descShow = Kit.Desc(L["BUFF_DUTY_SHOW_DESCRIPTION"], 7.3, Hidden),
			spaceShow = Kit.Spacer(7.6, Hidden),
			selfEnabled = Toggle("selfEnabled", L["BUFF_DUTY_SELF_ENABLE"], L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"], 8),
			spaceWeapon = Kit.Spacer(8.3, Hidden),
			weaponEnabled = Toggle(
				"weaponEnabled",
				L["BUFF_DUTY_WEAPON_ENABLE"],
				L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"],
				8.6
			),
			space3 = Kit.Spacer(9, Hidden),
			--[[
			    The toggle and how long a stranger stays listed, on one row
			    (Kit.ToggleRow); the dropdown appears only while the toggle is on.
			    Labeled with the client's own duration strings, so "1 Minute" reads
			    right in every locale without a string of ours.
			]]
			favorEnabled = Kit.ToggleRow(
				10,
				Toggle("favorEnabled", L["BUFF_DUTY_FAVOR_ENABLE"], L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"]),
				{ control = FavorSeconds(), hidden = Hidden }
			),
			space4 = Kit.Spacer(11, Hidden),
			targetEnabled = Toggle(
				"targetEnabled",
				L["BUFF_DUTY_TARGET_ENABLE"],
				L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"],
				12
			),
			spaceAsk = Kit.Spacer(12.3, Hidden),
			askOtherClasses = Toggle(
				"askOtherClasses",
				L["BUFF_DUTY_ASK_OTHERS"],
				L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"],
				12.5
			),
			askExample = Kit.Example(12.7, AskExampleHidden, AskExample),
			-- 12.8 through 12.99 belong to the whisper composer, added below.
			askComposerSpace = Kit.Spacer(12.75, AskHidden),
			space5 = Kit.Spacer(13, Hidden),

			headerWindow = Kit.Header(L["BUFF_DUTY_HEADER"], 14, Hidden),
			space6 = Kit.Spacer(15, Hidden),
			descWindow = Kit.Desc(L["BUFF_DUTY_WINDOW_DESCRIPTION"], 15.3, Hidden),
			spaceWindow = Kit.Spacer(15.6, Hidden),
			locked = Toggle("locked", L["BUFF_DUTY_LOCK"], L["BUFF_DUTY_LOCK_DESCRIPTION"], 16),
			space7 = Kit.Spacer(17, Hidden),
			hideInCombat = Toggle(
				"hideInCombat",
				L["BUFF_DUTY_HIDE_IN_COMBAT"],
				L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"],
				18
			),
			space8 = Kit.Spacer(19, Hidden),
		},
	}

	--[[
	    The whispered ask's composer, following the ask toggle: the ask a
	    Party-Buffs icon's right-click whispers, with the panel's sample buff
	    and names.
	]]
	ns.DefineWhisperComposer(options.args, {
		prefix = "askWhisper",
		hidden = AskHidden,
		messages = {
			{
				field = "buffAsk",
				label = L["WHISPER_TEXT"],
				description = L["BUFF_DUTY_ASK_MESSAGE_DESCRIPTION"],
				tokens = function()
					local info, help = GetColor("INFO"), GetColor("HELP")
					return L["BUFF_DUTY_ASK_TOKENS"]:format(info .. "{names}" .. help, info .. "{spell}" .. help)
				end,
				fill = function(text)
					local names = SampleAskNames()
					return ns.FillBuffAskWhisper(text, names, #names, SampleAskLink())
				end,
				build = function(text)
					local names = SampleAskNames()
					return ns:BuildBuffAskWhisper(text, names, #names, SampleAskLink())
				end,
			},
		},
	}, 12.8)

	--[[
	    One toggle per class this client has, each with the game's class icon
	    beside its name, flowing three to a row in an unnamed inline group.
	    Unset reads as ticked, so a class the account-wide settings have never
	    seen shows the window.
	]]
	for index, class in ipairs(ns.OptionsClassList()) do
		options.args.classes.args[class] = {
			type = "toggle",
			name = ns.ClassName(class),
			desc = L["BUFF_DUTY_CLASS_DESCRIPTION"],
			image = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",
			imageCoords = CLASS_ICON_TCOORDS[class],
			width = "normal",
			order = index,
			get = function()
				return Settings().showClasses[class] ~= false
			end,
			set = function(_, value)
				Settings().showClasses[class] = value
				-- Ticking your own class brings back a window its close button hid this session.
				if value and class == select(2, UnitClass("player")) then
					ns.ShowBuffDutyAgain()
				end
				ns.RefreshBuffDuty()
			end,
		}
	end

	return options
end
