local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    "Buff Duty" panel -- the click-to-cast list of group members missing a buff
    you can give (Features/Buff-Duty/Buff-Duty.lua, data in this client's
    Data/{Game}/Buff-Duty-Spells-{Game}.lua). The enable switch at the top,
    twinned in the root panel's Features section, is the master; everything
    below it hides while it is off. Each optional row of the window has its
    switch here, Self Buffs and Weapon Buffs included. The Buff Button's key
    binding is on the root panel, with every other key binding. What each buff
    is offered to lives in three sub-panels of this one: Tracked Abilities
    (Options-Buff-Duty-Buffs.lua), Self-Buffs
    (Options-Buff-Duty-Self-Buffs.lua) and Weapon Buffs
    (Options-Buff-Duty-Weapon-Buffs.lua).

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
	    The Example line for the ask a Party-Buffs Left-Click sends, as the
	    group reads it: for the Mage's raid buff where this client has one, else
	    the first raid buff in its data, linked at its top rank the way the
	    window links it, with two of the sample names missing it.
	]]
	local function AskExample()
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
		local link = ns.GetSpellLink(id) or C_Spell.GetSpellName(id) or ""
		local names = { ns.SAMPLE_NAMES.PRIEST, ns.SAMPLE_NAMES.SHAMAN }
		return ns.BuildPartyExampleLine(ns:BuildBuffRequestMessage(names, #names, link))
	end

	--[[
	    The right half of a Solo, In Party or In Raid row: where the window
	    shows, Always or In Instance. Like Return the Favor's, it appears only
	    while the toggle beside it is on.
	]]
	local whereValues = {}
	for _, value in ipairs(Data.BUFF_DUTY_WHERE_ORDER) do
		whereValues[value] = L["BUFF_DUTY_WHERE_" .. value]
	end
	local function Where(toggleKey, key, order)
		return {
			type = "select",
			name = "",
			desc = L["BUFF_DUTY_WHERE_DESCRIPTION"],
			values = whereValues,
			sorting = Data.BUFF_DUTY_WHERE_ORDER,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			hidden = function()
				return Hidden() or not Settings()[toggleKey]
			end,
			get = function()
				return Settings()[key]
			end,
			set = function(_, value)
				Settings()[key] = value
				ns.RefreshBuffDuty()
			end,
		}
	end

	local options = {
		name = L["TAB_BUFF_DUTY"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["BUFF_DUTY_DESCRIPTION"], 1),
			space0 = ns.OptionsSpacer(2),
			enable = ns.OptionsFeatureSwitch("BuffDuty", 3),
			--[[
			    A status line, shown only on a class with nothing on the list: the
			    switch above is on, and the window will still never appear.
			]]
			noBuffs = {
				type = "description",
				name = GetColor("HELP") .. L["BUFF_DUTY_NO_BUFFS"] .. "|r",
				fontSize = "medium",
				order = 4,
				hidden = function()
					return Hidden() or ns.BuffDutyHasClassRows()
				end,
			},
			space1 = ns.OptionsSpacer(5, Hidden),

			--[[
			    When the window may show at all: solo, in a party or in a raid,
			    and on which classes. The class toggles are added to `classes`
			    below.
			]]
			headerWhen = ns.OptionsHeader(L["BUFF_DUTY_WHEN_HEADER"], 5.1, Hidden),
			spaceWhen0 = ns.OptionsSpacer(5.11, Hidden),
			descWhen = ns.OptionsDesc(L["BUFF_DUTY_WHEN_DESCRIPTION"], 5.12, Hidden),
			spaceWhen1 = ns.OptionsSpacer(5.13, Hidden),
			showSolo = Toggle(
				"showSolo",
				L["BUFF_DUTY_WHEN_SOLO"],
				L["BUFF_DUTY_WHEN_SOLO_DESCRIPTION"],
				5.14,
				ns.OPTIONS_LABEL_WIDTH
			),
			showSoloWhere = Where("showSolo", "showSoloWhere", 5.15),
			spaceWhen2 = ns.OptionsSpacer(5.16, Hidden),
			showParty = Toggle(
				"showParty",
				L["BUFF_DUTY_WHEN_PARTY"],
				L["BUFF_DUTY_WHEN_PARTY_DESCRIPTION"],
				5.17,
				ns.OPTIONS_LABEL_WIDTH
			),
			showPartyWhere = Where("showParty", "showPartyWhere", 5.175),
			spaceWhen3 = ns.OptionsSpacer(5.18, Hidden),
			showRaid = Toggle(
				"showRaid",
				L["BUFF_DUTY_WHEN_RAID"],
				L["BUFF_DUTY_WHEN_RAID_DESCRIPTION"],
				5.185,
				ns.OPTIONS_LABEL_WIDTH
			),
			showRaidWhere = Where("showRaid", "showRaidWhere", 5.19),
			spaceWhen4 = ns.OptionsSpacer(5.195, Hidden),
			descClasses = ns.OptionsDesc(L["BUFF_DUTY_CLASSES_DESCRIPTION"], 5.2, Hidden),
			spaceClasses0 = ns.OptionsSpacer(5.21, Hidden),
			classes = {
				type = "group",
				name = "",
				order = 5.3,
				inline = true,
				hidden = Hidden,
				args = {},
			},
			spaceClasses1 = ns.OptionsSpacer(5.4, Hidden),

			--[[
			    The window's optional rows, in the order it shows them: your self
			    buffs above the group, the players outside it below.
			]]
			headerShow = ns.OptionsHeader(L["BUFF_DUTY_SHOW_HEADER"], 6, Hidden),
			space2 = ns.OptionsSpacer(7, Hidden),
			descShow = ns.OptionsDesc(L["BUFF_DUTY_SHOW_DESCRIPTION"], 7.3, Hidden),
			spaceShow = ns.OptionsSpacer(7.6, Hidden),
			selfEnabled = Toggle("selfEnabled", L["BUFF_DUTY_SELF_ENABLE"], L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"], 8),
			spaceWeapon = ns.OptionsSpacer(8.3, Hidden),
			weaponEnabled = Toggle(
				"weaponEnabled",
				L["BUFF_DUTY_WEAPON_ENABLE"],
				L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"],
				8.6
			),
			space3 = ns.OptionsSpacer(9, Hidden),
			favorEnabled = Toggle(
				"favorEnabled",
				L["BUFF_DUTY_FAVOR_ENABLE"],
				L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"],
				10,
				ns.OPTIONS_LABEL_WIDTH
			),
			--[[
			    The toggle and how long a stranger stays listed, on one row; the
			    dropdown appears only while the toggle is on. Labeled with the
			    client's own duration strings, so "1 Minute" reads right in every
			    locale without a string of ours.
			]]
			favorSeconds = {
				type = "select",
				name = "",
				desc = L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"],
				values = function()
					local values = {}
					for _, seconds in ipairs(ns.Data.BUFF_DUTY_FAVOR_CHOICES) do
						values[seconds] = ns.FormatDuration(seconds)
					end
					return values
				end,
				sorting = ns.Data.BUFF_DUTY_FAVOR_CHOICES,
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 10.1,
				hidden = function()
					return Hidden() or not Settings().favorEnabled
				end,
				get = function()
					return Settings().favorSeconds
				end,
				set = function(_, value)
					Settings().favorSeconds = value
					ns.RefreshBuffDuty()
				end,
			},
			space4 = ns.OptionsSpacer(11, Hidden),
			targetEnabled = Toggle(
				"targetEnabled",
				L["BUFF_DUTY_TARGET_ENABLE"],
				L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"],
				12
			),
			spaceAsk = ns.OptionsSpacer(12.3, Hidden),
			askOtherClasses = Toggle(
				"askOtherClasses",
				L["BUFF_DUTY_ASK_OTHERS"],
				L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"],
				12.5
			),
			askExample = ns.OptionsChatExample(12.7, AskExample, function()
				return Hidden() or not Settings().askOtherClasses
			end),
			space5 = ns.OptionsSpacer(13, Hidden),

			headerWindow = ns.OptionsHeader(L["BUFF_DUTY_HEADER"], 14, Hidden),
			space6 = ns.OptionsSpacer(15, Hidden),
			descWindow = ns.OptionsDesc(L["BUFF_DUTY_WINDOW_DESCRIPTION"], 15.3, Hidden),
			spaceWindow = ns.OptionsSpacer(15.6, Hidden),
			locked = Toggle("locked", L["BUFF_DUTY_LOCK"], L["BUFF_DUTY_LOCK_DESCRIPTION"], 16),
			space7 = ns.OptionsSpacer(17, Hidden),
			hideInCombat = Toggle(
				"hideInCombat",
				L["BUFF_DUTY_HIDE_IN_COMBAT"],
				L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"],
				18
			),
			space8 = ns.OptionsSpacer(19, Hidden),
		},
	}

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
				ns.RefreshBuffDuty()
			end,
		}
	end

	return options
end
