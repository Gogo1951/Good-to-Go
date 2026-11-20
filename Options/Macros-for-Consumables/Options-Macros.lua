local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Active-State Predicates
--------------------------------------------------------------------------------

--[[
    Settings live on the AceDB profile, which is the character's own unless
    the player put it on another. The exceptions on this panel are
    account-wide and read ns.db.global directly: the Macros master switch,
    Macro Names on Buttons and the Which Macros to Create toggles (see
    Data/Default-Settings.lua for why each one stays there). Each macro's own
    settings are on a page of its own under this one.
]]

-- Everything under the switch hides while Consumable Macros is off.
local function MacrosOff()
	return not (ns.db and ns.db.global.macrosEnabled)
end

--[[
    One factory for the Which Macros to Create toggles.

    macroName is the macro's own MACRO_* name, shown without the "- " every
    locale leads it with: the macros keep the dash, the panel drops it. The
    LABEL_* strings can't stand in, since three of them name the item rather
    than the macro (Explosive, Pet Food, Poison).

    The row wears the macro's default icon between the box and the name: the
    icon of the item the macro shows while the bags hold nothing it can use
    (ns.MACRO_DEFAULT_ITEM_IDS, keyed by the same macro type as `key`), which
    is how the macro looks on a fresh character's action bar. The checkbox is
    the icon checkbox (Options-Widgets.lua), for the gap between the two.
]]
local function MacroToggle(macroName, key, order)
	return {
		type = "toggle",
		name = (macroName:gsub("^%- ", "")),
		desc = L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"],
		image = function()
			local itemID = ns.MACRO_DEFAULT_ITEM_IDS[key]
			return itemID and C_Item.GetItemIconByID(itemID) or nil
		end,
		imageCoords = ns.OPTIONS_ICON_TEXCOORDS,
		dialogControl = ns.ICON_CHECKBOX_WIDGET_TYPE,
		order = order,
		width = "normal",
		-- Mists has no Poisons skill, so no Poisons macro to turn on.
		hidden = key == "Poisons" and ns.POISONS_SPELL_ID == nil,
		get = function()
			return ns.IsMacroEnabled(key)
		end,
		set = function(_, value)
			ns.db.global.enabledMacros[key] = value
			ns.ResetMacroState()
			ns.RequestUpdate()
			ns.RefreshSettings()
		end,
	}
end

--[[
    The Macros Window row's Open button. The Settings window closes first, since the
    Macros window would otherwise open behind it. MacroFrame_LoadUI is the
    loader every client ships (Classic's UIParent and Forever's MacroUI
    bootstrap; Classic has no ShowMacroFrame), and the window always opens on
    its General tab (MacroFrameMixin:OnShow). A panel opened before a fight
    stays open into it, and both windows are protected in combat, so a press
    then is refused with the same message the options command gives.
]]
local function OpenMacroWindow()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end
	if SettingsPanel and SettingsPanel:IsShown() then
		HideUIPanel(SettingsPanel)
	end
	MacroFrame_LoadUI()
	if MacroFrame then
		ShowUIPanel(MacroFrame)
	end
end

--------------------------------------------------------------------------------
-- Consumable Macros Panel
--------------------------------------------------------------------------------

--[[
    Which macros Consumable Macros builds: the Macros master switch, then
    Which Macros to Create with the Macros Window row and an example (hidden
    while the Food macro is off, since it shows that macro's line), and
    Action Bars at the foot with Macro Names on Buttons. How each macro picks its item is on a page of its
    own nested under this one: Food & Drinks (Options-Food-Drinks.lua);
    Potions & Mana Gems, Bandages, Healthstone and Explosives (a file each,
    as Options-Bandages.lua); Class Macros (Options-Class-Macros.lua); and
    the Ignore List (Options-Ignore-List.lua). While the switch is off, only
    the description, the switch and Action Bars stay (Kit.HideAllExcept):
    the names switch hides every button's name, not only this feature's, and
    applies at once and at each login whether the feature is on or off.

    Order values are spaced blocks so a section can be reordered or extended
    without renumbering its neighbors. The switch atop the panel is also in the
    root panel's Features section, as Enable Consumable Macros.

    Registered as this builder function rather than a built table (see
    Options/Options.lua), so AceConfig re-invokes it on every open and every
    NotifyChange, matching how every panel here registers.
]]

function ns.BuildMacrosOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_MACROS_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		toggleMacrosEnabled = Kit.FeatureSwitch("macrosEnabled", 2.5),
		-- Which Macros to Create
		spaceEnable0 = Spacer(10),
		headerEnableMacros = Header(L["OPTIONS_MACROS_TO_CREATE_HEADER"], 11),
		spaceEnable1 = Spacer(12),
		descEnableMacros = Desc(GetColor("BODY") .. L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] .. "|r", 13),
		spaceEnable2 = Spacer(14),
		enableMacrosGroup = {
			type = "group",
			name = "",
			order = 15,
			inline = true,
			args = {
				enableBandage = MacroToggle(L["MACRO_BANDAGE"], "Bandage", 1),
				enableExplosive = MacroToggle(L["MACRO_EXPLOSIVES"], "Explosive", 2),
				enableFeedPet = MacroToggle(L["MACRO_FEED_PET"], "Feed Pet", 3),
				enableFood = MacroToggle(L["MACRO_FOOD"], "Food", 4),
				enableHealthPotion = MacroToggle(L["MACRO_HEALTH_POTION"], "Health Potion", 5),
				enableHealthstone = MacroToggle(L["MACRO_HEALTHSTONE"], "Healthstone", 6),
				enableManaGem = MacroToggle(L["MACRO_MANA_GEM"], "Mana Gem", 7),
				enableManaPotion = MacroToggle(L["MACRO_MANA_POTION"], "Mana Potion", 8),
				enablePoisons = MacroToggle(L["MACRO_POISONS"], "Poisons", 9),
				enableSoulstone = MacroToggle(L["MACRO_SOULSTONE"], "Soulstone", 10),
				enableWater = MacroToggle(L["MACRO_WATER"], "Water", 11),
			},
		},
		spaceEnable3 = Spacer(16),
		-- In the control column, as every button on a page sits, not a lone button at the left edge.
		openMacroWindow = Kit.LabelRow(17, nil, L["OPTIONS_MACROS_WINDOW"], {
			type = "execute",
			name = L["OPTIONS_OPEN"],
			desc = L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"],
			func = OpenMacroWindow,
		}),
		-- What a macro prints when your bags hold nothing it can use, as the Food macro prints it; gone while the Food macro is off.
		exampleNoItem = Kit.Example(19, function()
			return not ns.IsMacroEnabled("Food")
		end, function()
			return ns.PrintedExampleLines(ns.BuildNoItemLine("Food"))
		end),

		-- Action Bars: shown even while Consumable Macros is off, since the names it hides aren't only this feature's.
		toggleMacroNames = {
			type = "toggle",
			name = L["OPTIONS_MACRO_NAMES"],
			desc = L["OPTIONS_MACRO_NAMES_DESCRIPTION"],
			order = 31,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showMacroNames
			end,
			set = function(_, value)
				ns.ToggleMacroNames(value)
				ns.RefreshSettings()
			end,
		},
	}
	Kit.Section(args, "actionBars", 30, L["OPTIONS_ACTION_BARS_HEADER"])

	Kit.HideAllExcept(args, MacrosOff, {
		"descIntro",
		"spaceIntro",
		"toggleMacrosEnabled",
		"actionBarsSpace0",
		"actionBarsHeader",
		"actionBarsSpace1",
		"toggleMacroNames",
	})

	return {
		type = "group",
		name = L["TAB_CONSUMABLE_MACROS"],
		args = args,
	}
end
