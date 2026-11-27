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

-- This panel's settings are account-wide (Data/Default-Settings.lua says why); each macro's page is per profile.
local function MacrosOff()
	return not (ns.db and ns.db.global.macrosEnabled)
end

--[[
    The MACRO_* name minus its leading "- "; LABEL_* can't stand in, since three
    name the item, not the macro. The icon is the macro's empty-bags default,
    as a fresh character's action bar shows it.
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
    Settings closes first, or the Macros window opens behind it. MacroFrame_LoadUI
    is the one loader every client ships. Both windows are protected in combat,
    so a press then gets the options command's own refusal line.
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

function ns.BuildMacrosOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_MACROS_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),
		toggleMacrosEnabled = Kit.FeatureSwitch("macrosEnabled", 2.5),
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
				enableFishingLure = MacroToggle(L["MACRO_FISHING_LURE"], "Fishing Lure", 4),
				enableFood = MacroToggle(L["MACRO_FOOD"], "Food", 5),
				enableHealthPotion = MacroToggle(L["MACRO_HEALTH_POTION"], "Health Potion", 6),
				enableHealthstone = MacroToggle(L["MACRO_HEALTHSTONE"], "Healthstone", 7),
				enableManaGem = MacroToggle(L["MACRO_MANA_GEM"], "Mana Gem", 8),
				enableManaPotion = MacroToggle(L["MACRO_MANA_POTION"], "Mana Potion", 9),
				enablePoisons = MacroToggle(L["MACRO_POISONS"], "Poisons", 10),
				enableSoulstone = MacroToggle(L["MACRO_SOULSTONE"], "Soulstone", 11),
				enableWater = MacroToggle(L["MACRO_WATER"], "Water", 12),
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
		-- Shows the Food macro's line, so it hides while that macro is off.
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
