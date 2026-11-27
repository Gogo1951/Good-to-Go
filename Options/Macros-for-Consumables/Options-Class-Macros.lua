local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

local MacroOptions = ns.MacroOptions
local SpellDescription = ns.OptionsSpellDescription

--------------------------------------------------------------------------------
-- Active-State Predicates
--------------------------------------------------------------------------------

local GetSettings = ns.OptionsProfileSettings

local function DruidMacroHelperActive()
	local settings = GetSettings()
	return settings and settings.enableDruidMacroHelper
end

local function NoPetBuffFoods()
	return next(ns.PET_BUFF_FOODS) == nil
end

local function PetBuffActive()
	local settings = GetSettings()
	return not NoPetBuffFoods() and settings and settings.usePetBuffFood
end

-- Mists has no Poisons skill, so no Poisons macro.
local NO_POISONS = ns.POISONS_SPELL_ID == nil

local function PoisonsMacroOff()
	return not ns.IsMacroEnabled("Poisons")
end

local function PoisonRowsHidden()
	return NO_POISONS or PoisonsMacroOff()
end

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

-- Built from ns.POISON_GROUP_BASE_ITEMS, so a group with no base item in this data folder is never offered.
local function PoisonHandDropdown(description, settingKey)
	local sorting = {}
	for groupID in pairs(ns.POISON_GROUP_BASE_ITEMS) do
		sorting[#sorting + 1] = groupID
	end
	table.sort(sorting)

	return {
		type = "select",
		desc = description,
		values = function()
			local values = {}
			local coldItemIDs = {}
			for groupID, baseItem in pairs(ns.POISON_GROUP_BASE_ITEMS) do
				values[groupID] = ns.GetPoisonGroupName(groupID) or Kit.ItemName(baseItem)
				if not C_Item.GetItemInfo(baseItem) then
					coldItemIDs[#coldItemIDs + 1] = baseItem
				end
			end
			Kit.WarmItems(coldItemIDs, ns.OPTIONS_REGISTRY.ClassMacros)
			return values
		end,
		sorting = sorting,
		get = function()
			return ns.db.profile[settingKey]
		end,
		set = function(_, value)
			ns.db.profile[settingKey] = value
			MacroOptions.Changed()
		end,
	}
end

local function PetBuffTypeToggles()
	local foods = {}
	for itemID, row in pairs(ns.PET_BUFF_FOODS) do
		foods[#foods + 1] = { itemID = itemID, rank = row[2], settingKey = row[3] }
	end
	table.sort(foods, function(a, b)
		return a.rank > b.rank
	end)

	local toggles = {}
	local coldItemIDs = {}
	for order, food in ipairs(foods) do
		local label
		if C_Item.GetItemInfo(food.itemID) then
			label = ns.GetItemLabel(food.itemID)
		else
			coldItemIDs[#coldItemIDs + 1] = food.itemID
			label = Kit.ItemName(food.itemID)
		end
		local key = food.settingKey
		toggles["pet" .. key] = {
			type = "toggle",
			name = label,
			desc = string.format(L["OPTIONS_BUFF_TYPE_DESCRIPTION"], label),
			order = order,
			image = C_Item.GetItemIconByID(food.itemID),
			imageCoords = ns.OPTIONS_ICON_TEXCOORDS,
			dialogControl = ns.ICON_CHECKBOX_WIDGET_TYPE,
			get = function()
				local types = ns.db.profile.petBuffTypes
				return types and types[key]
			end,
			set = function(_, value)
				ns.db.profile.petBuffTypes[key] = value
				MacroOptions.Changed()
			end,
		}
	end
	Kit.WarmItems(coldItemIDs, ns.OPTIONS_REGISTRY.ClassMacros)
	return toggles
end

--------------------------------------------------------------------------------
-- Class Macros Panel
--------------------------------------------------------------------------------

--[[
    Every class section shows on every character (the maintainer's choice). The
    only gates are the flavor's (no pet buff food, no Poisons skill) and the
    Rogue rows, which hide while the Poisons macro is off.
]]
function ns.BuildClassMacrosOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_CLASS_MACROS_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),

		spaceDruid0 = Spacer(9),
		headerDruid = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.DRUID), 10),
		spaceDruid1 = Spacer(11),
		descDruid = Desc(GetColor("BODY") .. L["OPTIONS_DRUID_DESCRIPTION"] .. "|r", 12),
		spaceDruid2 = Spacer(13),
		toggleDruidMacroHelper = Kit.ToggleRow(14, {
			type = "toggle",
			name = L["OPTIONS_DRUID_MACRO_HELPER"],
			desc = L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"],
			get = function()
				return DruidMacroHelperActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("enableDruidMacroHelper", value)
			end,
		}, {
			control = {
				type = "select",
				desc = L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"],
				values = {
					bear = L["DRUID_FORM_BEAR"],
					cat = L["DRUID_FORM_CAT"],
				},
				sorting = { "bear", "cat" },
				get = function()
					return ns.db.profile.druidReturnForm
				end,
				set = function(_, value)
					ns.db.profile.druidReturnForm = value
					MacroOptions.Changed()
				end,
			},
		}),

		spaceHunter0 = Spacer(20, NoPetBuffFoods),
		headerHunter = Header(
			L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.HUNTER),
			21,
			NoPetBuffFoods
		),
		spaceHunter1 = Spacer(22, NoPetBuffFoods),
		descHunter = Desc(GetColor("BODY") .. L["OPTIONS_CLASS_MACROS_HUNTER_SUMMARY"] .. "|r", 22.3, NoPetBuffFoods),
		spaceHunter2 = Spacer(22.6, NoPetBuffFoods),
		togglePetBuffs = {
			type = "toggle",
			name = L["OPTIONS_USE_PET_BUFFS"],
			desc = SpellDescription("OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			order = 23,
			width = "full",
			hidden = NoPetBuffFoods,
			get = function()
				return PetBuffActive()
			end,
			set = function(_, value)
				ns.db.profile.usePetBuffFood = value
				ns.UpdateAuraTracking()
				MacroOptions.Changed()
			end,
		},
		petBuffFoodLevel = MacroOptions.ModeSubRow(
			"petBuffFood",
			MacroOptions.ModeDescription(L["OPTIONS_PET_HEADER"]),
			PetBuffActive,
			24
		),
		spacePetTypes0 = Spacer(25, function()
			return not PetBuffActive()
		end),
		petTypesGroup = {
			type = "group",
			name = L["OPTIONS_PET_BUFF_TYPES"],
			order = 26,
			inline = true,
			hidden = function()
				return not PetBuffActive()
			end,
			args = PetBuffTypeToggles(),
		},

		spaceRogue0 = Spacer(40, NO_POISONS),
		headerRogue = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE), 41, NO_POISONS),
		spaceRogue1 = Spacer(42, NO_POISONS),
		poisonsOff = Kit.StatusLine(function()
			if NO_POISONS or not PoisonsMacroOff() then
				return nil
			end
			return ns.OptionsSwitchOffStatus(L["NOTE_MACRO_POISONS"], L["TAB_CONSUMABLE_MACROS"])
		end, 42.5),
		descPoisons = Desc(GetColor("BODY") .. L["OPTIONS_POISONS_DESCRIPTION"] .. "|r", 43, PoisonRowsHidden),
		spaceRogue2 = Spacer(44, PoisonRowsHidden),
		mainHandPoison = Kit.LabelRow(
			45,
			PoisonRowsHidden,
			GetColor("BODY") .. L["OPTIONS_POISON_MAIN_HAND"] .. "|r",
			PoisonHandDropdown(L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"], "mainHandPoisonGroup")
		),
		spaceRogue3 = Spacer(47, PoisonRowsHidden),
		offHandPoison = Kit.LabelRow(
			48,
			PoisonRowsHidden,
			GetColor("BODY") .. L["OPTIONS_POISON_OFF_HAND"] .. "|r",
			PoisonHandDropdown(L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"], "offHandPoisonGroup")
		),
	}

	MacroOptions.UseWhenGroups(args, "petBuffFood", PetBuffActive, 24.5)

	return MacroOptions.Page(L["TAB_CLASS_MACROS"], args)
end
