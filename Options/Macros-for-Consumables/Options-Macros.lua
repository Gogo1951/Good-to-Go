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
    Data/Default-Settings.lua for why each one stays there). Food and drink
    settings have their own page under this one (Options-Food-Water.lua).
]]

local GetSettings = ns.OptionsProfileSettings

-- Everything under the switch hides while Consumable Macros is off.
local function MacrosOff()
	return not (ns.db and ns.db.global.macrosEnabled)
end

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

--[[
    A Mana Gem text naming the two runes, each as its icon and the client's
    name, built when it shows; a rune still loading shows its loading text and
    is warmed so the panel repaints.
]]
local function ManaRuneText(formatKey)
	return function()
		local runeIDs = { ns.DEMONIC_RUNE_ITEM_ID, ns.DARK_RUNE_ITEM_ID }
		local coldItemIDs = {}
		for _, itemID in ipairs(runeIDs) do
			if not C_Item.GetItemInfo(itemID) then
				coldItemIDs[#coldItemIDs + 1] = itemID
			end
		end
		Kit.WarmItems(coldItemIDs, ns.OPTIONS_REGISTRY.Macros)
		return string.format(L[formatKey], Kit.ItemName(runeIDs[1]), Kit.ItemName(runeIDs[2]))
	end
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
    The Open Macros Window button. The Settings window closes first, since the
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
    Everything that shapes the macros Consumable Macros builds, apart from
    food and drink: which macros exist, then how each behaves. Page order is
    the Macros master switch, Macro Names on Buttons, Which Macros to Create
    (with the Open Macros Window button), Potions & Healthstones, Mana Gems &
    Runes, then Explosives, and a line pointing to Food & Water. Food & Water
    (Options-Food-Water.lua), the class and race sections
    (Options-Class-Race.lua) and the Ignore List (Options-Ignore-List.lua)
    have their own panels, nested under this one. While the switch is off,
    only the description and the switch stay (Kit.HideAllExcept).

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

		-- Macro Names on Buttons
		toggleMacroNames = {
			type = "toggle",
			name = L["OPTIONS_MACRO_NAMES"],
			desc = L["OPTIONS_MACRO_NAMES_DESCRIPTION"],
			order = 3,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showMacroNames
			end,
			set = function(_, value)
				ns.ToggleMacroNames(value)
				ns.RefreshSettings()
			end,
		},

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
		openMacroWindow = {
			type = "execute",
			name = L["OPTIONS_OPEN_MACRO_WINDOW"],
			desc = L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"],
			order = 17,
			width = ns.OPTIONS_CONTROL_WIDTH,
			func = OpenMacroWindow,
		},
		-- What a macro prints when your bags hold nothing it can use, as the Food macro prints it.
		exampleNoItem = Kit.Example(19, nil, function()
			return ns.PrintedExampleLines(ns.BuildNoItemLine("Food"))
		end),

		-- Potions & Healthstones
		spacePotions0 = Spacer(40),
		headerPotions = Header(L["OPTIONS_POTIONS_HEADER"], 41),
		spacePotions1 = Spacer(42),
		descPotions = Desc(GetColor("BODY") .. L["OPTIONS_POTIONS_DESCRIPTION"] .. "|r", 43),
		spacePotions2 = Spacer(44),
		togglePotionsUseFoodAndWater = {
			type = "toggle",
			name = L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"],
			desc = L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"],
			order = 45,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.potionsUseFoodAndWater
			end,
			set = function(_, value)
				ns.db.profile.potionsUseFoodAndWater = value
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
			end,
		},
		spacePotions3 = Spacer(46),
		toggleCombineHealthstones = {
			type = "toggle",
			name = L["OPTIONS_COMBINE_HEALTHSTONES"],
			desc = L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"],
			order = 47,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.combineHealthstones
			end,
			set = function(_, value)
				ns.db.profile.combineHealthstones = value
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
			end,
		},

		-- Mana Gems & Runes
		spaceManaGems0 = Spacer(50),
		headerManaGems = Header(L["OPTIONS_MANA_GEMS_HEADER"], 51),
		spaceManaGems1 = Spacer(52),
		descManaGems = Desc(function()
			return GetColor("BODY") .. ManaRuneText("OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT")() .. "|r"
		end, 53),
		spaceManaGems2 = Spacer(54),
		toggleIncludeManaRunes = {
			type = "toggle",
			name = L["OPTIONS_INCLUDE_MANA_RUNES"],
			desc = ManaRuneText("OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"),
			order = 55,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.includeManaRunes
			end,
			set = function(_, value)
				ns.db.profile.includeManaRunes = value
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
			end,
		},

		-- Explosives
		spaceExplosives0 = Spacer(350),
		headerExplosives = Header(L["OPTIONS_EXPLOSIVES_HEADER"], 351),
		spaceExplosives1 = Spacer(352),
		descExplosives = Desc(GetColor("BODY") .. L["OPTIONS_EXPLOSIVES_DESCRIPTION"] .. "|r", 353),
		spaceExplosives2 = Spacer(354),
		labelExplosivesClickMode = Kit.Label(GetColor("BODY") .. L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] .. "|r", 355),
		explosivesClickMode = {
			type = "select",
			name = "",
			desc = L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"],
			order = 356,
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = {
				atplayer = L["EXPLOSIVES_MODE_ATPLAYER"],
				toss = L["EXPLOSIVES_MODE_TOSS"],
			},
			sorting = { "atplayer", "toss" },
			get = function()
				return ns.db.profile.explosivesClickMode
			end,
			set = function(_, value)
				ns.db.profile.explosivesClickMode = value
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
			end,
		},

		-- Where the food and drink settings went: their own page under this one.
		spaceFoodWater = Spacer(360),
		descFoodWater = Desc(Kit.Color("HELP", L["OPTIONS_FOOD_WATER_ELSEWHERE"]), 361),
	}

	Kit.HideAllExcept(args, MacrosOff, { "descIntro", "spaceIntro", "toggleMacrosEnabled" })

	return {
		type = "group",
		name = L["TAB_CONSUMABLE_MACROS"],
		args = args,
	}
end
