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

--[[
    Every setting here lives on the AceDB profile, which is the character's own
    unless the player put it on another, and reads the settings table that
    InitializeDatabase in Features/Core.lua guarantees.
]]

local GetSettings = ns.OptionsProfileSettings

local function DruidMacroHelperActive()
	local settings = GetSettings()
	return settings and settings.enableDruidMacroHelper
end

-- A flavor whose data folder has no pet buff food shows no Pet Food Buffs rows.
local function NoPetBuffFoods()
	return next(ns.PET_BUFF_FOODS) == nil
end

local function PetBuffActive()
	local settings = GetSettings()
	return not NoPetBuffFoods() and settings and settings.usePetBuffFood
end

local function ReapplyActive()
	local settings = GetSettings()
	return settings and settings.earlyReapply
end

-- No Poisons skill on this flavor (Mists), so no Poisons macro for these rows to set up.
local NO_POISONS = ns.POISONS_SPELL_ID == nil

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

--[[
    Poison-group dropdown shared by the Main Hand and Off Hand rows. Values
    resolve through ns.GetPoisonGroupName each time the dialog renders, and any
    base item still uncached is warmed so the panel repaints with the client's
    own names. The order and the values both come from
    ns.POISON_GROUP_BASE_ITEMS, so a group the loaded data folder has no base
    item for is never offered.
]]
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

--[[
    One pet food toggle per row of the flavor folder's ns.PET_BUFF_FOODS, best
    rank first. Each stands for an item, so it wears the item's icon on the
    icon checkbox (Options-Widgets.lua) and names it in its quality color,
    as the Which Macros to Create rows do. A name still uncached shows as loading text
    and is warmed so the panel repaints.
]]
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

local REAPPLY_SECONDS = { 60, 120, 180, 240, 300 }

local function ReapplyThresholdValues()
	local values = { [60] = L["REAPPLY_THRESHOLD_ONE"] }
	for index = 2, #REAPPLY_SECONDS do
		local seconds = REAPPLY_SECONDS[index]
		values[seconds] = string.format(L["REAPPLY_THRESHOLD_MANY"], seconds / 60)
	end
	return values
end

--------------------------------------------------------------------------------
-- Class Macros Panel
--------------------------------------------------------------------------------

--[[
    The macro options that belong to one class, nested under Consumable
    Macros (Options/Options.lua): Druid (DruidMacroHelper on the potion and
    Healthstone macros), Hunter (Pet Food Buffs in the Food macro, and when a
    pet food buff counts as worn off), and Rogue (the Poisons macro's hands).
    The Feed Pet, Soulstone and Poisons macros themselves are switched on and
    off on Consumable Macros; Stealth Eating is with the food, on Food &
    Drinks. Every section shows on every character, the maintainer's choice;
    the only gates are flavor ones (no pet buff food, no Poisons skill).

    Order values are spaced blocks so a section can be reordered or extended
    without renumbering its neighbors. Registered as this builder function
    rather than a built table (see Options/Options.lua), so AceConfig
    re-invokes it on every open and every NotifyChange.
]]
function ns.BuildClassMacrosOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_CLASS_MACROS_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),

		-- Druids, with a spacer above as every class section has; the return form sits beside the switch.
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

		--[[
		    Hunters -- Pet Food Buffs: pet buff food in the Food macro while the
		    pet lacks the buff, with its When to Use and the food types, then
		    Refresh Pet Food Under, which sets when that buff counts as worn
		    off. Hidden where the flavor has no pet buff food.
		]]
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
		spacePet = Spacer(27, NoPetBuffFoods),
		-- Its dropdown keys are the threshold in seconds, stored directly in earlyReapplyThreshold.
		toggleReapply = Kit.ToggleRow(28, {
			type = "toggle",
			name = L["OPTIONS_REAPPLY"],
			desc = L["OPTIONS_REAPPLY_DESCRIPTION"],
			get = function()
				return ReapplyActive()
			end,
			set = function(_, value)
				ns.db.profile.earlyReapply = value
				MacroOptions.Changed()
			end,
		}, {
			control = {
				type = "select",
				desc = L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"],
				values = ReapplyThresholdValues(),
				sorting = REAPPLY_SECONDS,
				get = function()
					return ns.db.profile.earlyReapplyThreshold
				end,
				set = function(_, value)
					ns.db.profile.earlyReapplyThreshold = value
					MacroOptions.Changed()
				end,
			},
			hidden = NoPetBuffFoods,
		}),

		--[[
		    Rogues -- the Poisons macro's poison group per weapon hand. Group
		    names come from the client's own item names
		    (ns.GetPoisonGroupName), so the dropdown labels localize for free.
		    Where the flavor has no Poisons skill (Mists) there is no Poisons
		    macro, so the section hides.
		]]
		spaceRogue0 = Spacer(40, NO_POISONS),
		headerRogue = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE), 41, NO_POISONS),
		spaceRogue1 = Spacer(42, NO_POISONS),
		descPoisons = Desc(GetColor("BODY") .. L["OPTIONS_POISONS_DESCRIPTION"] .. "|r", 43, NO_POISONS),
		spaceRogue2 = Spacer(44, NO_POISONS),
		-- Label-beside-control rows: the caption, then the unlabeled dropdown, one row wide together.
		mainHandPoison = Kit.LabelRow(
			45,
			NO_POISONS,
			GetColor("BODY") .. L["OPTIONS_POISON_MAIN_HAND"] .. "|r",
			PoisonHandDropdown(L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"], "mainHandPoisonGroup")
		),
		spaceRogue3 = Spacer(47, NO_POISONS),
		offHandPoison = Kit.LabelRow(
			48,
			NO_POISONS,
			GetColor("BODY") .. L["OPTIONS_POISON_OFF_HAND"] .. "|r",
			PoisonHandDropdown(L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"], "offHandPoisonGroup")
		),
	}

	-- Pet Food Buffs' group context checkboxes, under its level filter.
	MacroOptions.UseWhenGroups(args, "petBuffFood", PetBuffActive, 24.5)

	return MacroOptions.Page(L["TAB_CLASS_MACROS"], args)
end
