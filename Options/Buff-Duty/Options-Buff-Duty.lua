local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

-- Every window setting's setter ends in ns.RefreshBuffDuty, which rebuilds the castable list and redraws.

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

	-- Nil where the client has no raid buff.
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

	local function SampleAskNames()
		return { ns.SAMPLE_NAMES.PRIEST, ns.SAMPLE_NAMES.SHAMAN }
	end

	local function AskExample()
		local names = SampleAskNames()
		return Kit.SentLine("PARTY", ns:BuildBuffRequestMessage(names, #names, SampleAskLink() or ""))
	end

	local function AskHidden()
		return Hidden() or not Settings().askOtherClasses
	end

	local function AskTargetHidden()
		return Hidden() or not Settings().targetEnabled or not Settings().askTarget
	end

	local function SampleTargetSpells()
		local spells = {}
		for _, entry in ipairs(ns.BuffDuty.entries) do
			if entry.row.class == "PRIEST" and not entry.row.talent and #spells < 2 then
				local id = entry.ids[#entry.ids]
				spells[#spells + 1] = ns.GetSpellLink(id) or C_Spell.GetSpellName(id) or ""
			end
		end
		if not spells[1] then
			spells[1] = SampleAskLink() or ""
		end
		return spells
	end

	local function AskExampleHidden()
		return AskHidden() or not SampleAskLink()
	end

	-- Battleground takes no where dropdown: a battleground or arena is always an instance.
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

	-- Hidden where this client has nothing for the category.
	local function CategoryToggle(row, name, order)
		return {
			type = "toggle",
			name = name,
			desc = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
			width = "full",
			order = order,
			hidden = function()
				return Hidden() or not ns.BuffDuty.RowExists(row)
			end,
			get = function()
				return ns.BuffDuty.RowOn(row)
			end,
			set = function(_, value)
				ns.BuffDuty.SetRowOn(row, value)
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
			-- The switch is on, yet on a class with nothing to list the window never appears.
			noBuffs = Kit.StatusLine(function()
				if Hidden() or ns.BuffDutyHasClassRows() then
					return nil
				end
				return L["BUFF_DUTY_NO_BUFFS"]
			end, 4),
			space1 = Kit.Spacer(5, Hidden),

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

			-- In the window's order and under its Options menu's own headers.
			headerShow = Kit.Header(L["BUFF_DUTY_SHOW_HEADER"], 6, Hidden),
			space2 = Kit.Spacer(7, Hidden),
			descShow = Kit.Desc(L["BUFF_DUTY_SHOW_DESCRIPTION"], 7.3, Hidden),
			spaceShow = Kit.Spacer(7.6, Hidden),
			selfEnabled = Toggle("selfEnabled", L["BUFF_DUTY_SELF_ENABLE"], L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"], 8),
			spaceFood = Kit.Spacer(8.1, Hidden),
			rowOnFood = CategoryToggle("food", ns.BuffDuty.WellFedLabel(), 8.2),
			spaceWeapon = Kit.Spacer(8.3, Hidden),
			weaponEnabled = Toggle(
				"weaponEnabled",
				L["BUFF_DUTY_WEAPON_ENABLE"],
				L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"],
				8.6
			),
			spaceScrolls = Kit.Spacer(8.65, Hidden),
			rowOnScrolls = CategoryToggle("scrolls", L["BUFF_DUTY_SCROLLS"], 8.7),
			spaceElixirs = Kit.Spacer(8.75, Hidden),
			rowOnElixirs = CategoryToggle("elixirs", L["BUFF_DUTY_ROW_ELIXIRS"], 8.8),
			spaceOther = Kit.Spacer(8.85, Hidden),
			rowOnOther = CategoryToggle("other", L["BUFF_DUTY_ROW_OTHER"], 8.9),
			space3 = Kit.Spacer(9, Hidden),
			headerOthers = Kit.Header(L["BUFF_DUTY_MENU_OTHER_PLAYERS"], 9.1, Hidden),
			spaceOthers0 = Kit.Spacer(9.2, Hidden),
			descOthers = Kit.Desc(L["BUFF_DUTY_OTHERS_DESCRIPTION"], 9.3, Hidden),
			spaceOthers1 = Kit.Spacer(9.4, Hidden),
			askOtherClasses = Toggle(
				"askOtherClasses",
				L["BUFF_DUTY_ASK_OTHERS"],
				L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"],
				10
			),
			-- 10.3 through 10.49 belong to the whisper composer, added below; the Example closes the field set.
			askComposerSpace = Kit.Spacer(10.25, AskHidden),
			askExample = Kit.Example(10.495, AskExampleHidden, AskExample),
			space4 = Kit.Spacer(11, Hidden),
			targetEnabled = Toggle(
				"targetEnabled",
				L["BUFF_DUTY_TARGET_ENABLE"],
				L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"],
				12
			),
			-- Shown only while Your Target is on: friendly NPCs are part of that row.
			targetNPCs = Kit.SubToggleRow(12.1, function()
				return Hidden() or not Settings().targetEnabled
			end, Toggle("targetNPCs", L["BUFF_DUTY_TARGET_NPCS"], L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"])),
			askTarget = Kit.SubToggleRow(12.12, function()
				return Hidden() or not Settings().targetEnabled
			end, Toggle("askTarget", L["BUFF_DUTY_ASK_TARGET"], L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"])),
			-- 12.2 through 12.39 belong to the ask-your-target whisper composer, added below.
			askTargetComposerSpace = Kit.Spacer(12.15, AskTargetHidden),
			spaceFavor = Kit.Spacer(12.4, Hidden),
			-- The client's own duration strings, so "1 Minute" reads right in every locale.
			favorEnabled = Kit.ToggleRow(
				12.5,
				Toggle("favorEnabled", L["BUFF_DUTY_FAVOR_ENABLE"], L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"]),
				{ control = FavorSeconds(), hidden = Hidden }
			),
			spacePvP = Kit.Spacer(12.6, Hidden),
			buffPvPFlagged = Toggle(
				"buffPvPFlagged",
				L["BUFF_DUTY_BUFF_PVP_FLAGGED"],
				L["BUFF_DUTY_BUFF_PVP_FLAGGED_DESCRIPTION"],
				12.7
			),
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
			-- Grayed while the window has never been dragged, and in combat, when the window can't move.
			spaceResetPosition = Kit.Spacer(18.3, Hidden),
			resetPosition = Kit.ResetRow(
				18.6,
				Hidden,
				L["OPTIONS_RESET_POSITION"],
				L["OPTIONS_RESET_POSITION_DESCRIPTION"],
				function()
					return InCombatLockdown() or not ns.HasSavedBuffDutyPosition()
				end,
				ns.ResetBuffDutyPosition
			),
			space8 = Kit.Spacer(19, Hidden),
		},
	}

	-- Send Messages In shows on whichever of the two composers comes first.
	ns.DefineWhisperComposer(options.args, {
		prefix = "askTargetWhisper",
		hidden = AskTargetHidden,
		languageHidden = function()
			return AskTargetHidden() or not AskHidden()
		end,
		messages = {
			{
				field = "buffAskTarget",
				label = L["WHISPER_TEXT"],
				description = L["BUFF_DUTY_ASK_TARGET_MESSAGE_DESCRIPTION"],
				tokens = function()
					local info, help = GetColor("INFO"), GetColor("HELP")
					return L["BUFF_DUTY_ASK_TARGET_TOKENS"]:format(info .. "{name}" .. help, info .. "{spells}" .. help)
				end,
				fill = function(text)
					return ns.FillBuffAskTargetWhisper(text, ns.SAMPLE_NAMES.PRIEST, SampleTargetSpells())
				end,
				build = function(text)
					return ns:BuildBuffAskTargetWhisper(text, ns.SAMPLE_NAMES.PRIEST, SampleTargetSpells())
				end,
			},
		},
	}, 12.2)

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
	}, 10.3)

	-- Unset reads as ticked, so a class the account-wide settings have never seen shows the window.
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
