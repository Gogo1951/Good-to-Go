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
    Every sub-option hides until its toggle is on. A toggle's one dropdown
    then appears on its toggle's line (Kit.ToggleRow). Scroll Buffs and Pet
    Food Buffs, which also carry a block of type checkboxes, put their
    dropdown on a captioned sub-option row under the toggle (ModeSubRow), with
    the checkboxes beneath it. Every When to Use dropdown has the group context
    checkboxes on a row under it (UseWhenGroups). These read the profile's
    settings table that InitializeDatabase in Features/Core.lua guarantees.
]]

local GetSettings = ns.OptionsProfileSettings

local function ConjuredFirstActive()
	local settings = GetSettings()
	return settings and settings.useConjuredFirst
end

local function BuffFoodActive()
	local settings = GetSettings()
	return settings and settings.useBuffFood
end

local function ScrollsActive()
	local settings = GetSettings()
	return settings and settings.useScrolls
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

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

--[[
    Every consumable's When to Use -- Buff Food, Scroll Buffs, Pet Food Buffs,
    and conjured food and water first -- is the same pair, named by its
    settings' prefix (ns.IsUseWhenActive): the level filter dropdown,
    ns.LEVEL_FILTER_VALUES in ns.LEVEL_FILTER_ORDER, on its toggle's line or
    on a sub-option row through ModeSubRow below, then the shared group
    context checkboxes on a sub-option row of their own (UseWhenGroups), with
    a red line under them while none is ticked. All of it hides until the
    toggle is on. Any change rewrites the macros under the throttle.
]]
local function UseWhenChanged()
	ns.ResetMacroState()
	ns.RequestUpdate()
	ns.RefreshSettings()
end

local function FeatureModeSelect(prefix, description)
	local settingKey = prefix .. "Level"
	return {
		type = "select",
		desc = description,
		values = ns.LEVEL_FILTER_VALUES,
		sorting = ns.LEVEL_FILTER_ORDER,
		get = function()
			return ns.db.profile[settingKey]
		end,
		set = function(_, value)
			ns.db.profile[settingKey] = value
			UseWhenChanged()
		end,
	}
end

-- The group context checkboxes and their none-ticked warning, at `order` and just after it.
local function UseWhenGroups(args, prefix, isActive, order)
	local function GetTable()
		return ns.db.profile[prefix .. "In"]
	end
	local function Inactive()
		return not isActive()
	end
	args[prefix .. "In"] = ns.OptionsGroupContextRow(order, Inactive, GetTable, UseWhenChanged)
	args[prefix .. "InNone"] = ns.OptionsGroupContextNone(L["OPTIONS_GROUPS_NONE"], order + 0.01, GetTable, Inactive)
end

--[[
    The same dropdown for a toggle with more than one setting: on a sub-option
    row of its own, under a silver caption (Kit.SubLabelRow), since it no
    longer shares the toggle's line. The dropdown keeps the control column.
]]
local function ModeSubRow(prefix, description, isActive, order)
	return Kit.SubLabelRow(order, function()
		return not isActive()
	end, L["OPTIONS_MODE_CAPTION"], FeatureModeSelect(prefix, description))
end

-- Hover text for a level filter dropdown choosing when the Food macro offers a feature.
local function ModeDescription(featureName)
	return string.format(L["OPTIONS_MODE_DESCRIPTION"], featureName)
end

local SpellDescription = ns.OptionsSpellDescription

-- Toggle for one entry inside a profile settings subtable (scroll/pet types).
local function SubsetToggle(subtableKey, key, label, order)
	return {
		type = "toggle",
		name = label,
		desc = string.format(L["OPTIONS_BUFF_TYPE_DESCRIPTION"], label),
		order = order,
		get = function()
			local subtable = ns.db.profile[subtableKey]
			return subtable and subtable[key]
		end,
		set = function(_, value)
			ns.db.profile[subtableKey][key] = value
			ns.ResetMacroState()
			ns.RequestUpdate()
			ns.RefreshSettings()
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
		local toggle = SubsetToggle("petBuffTypes", food.settingKey, label, order)
		toggle.image = C_Item.GetItemIconByID(food.itemID)
		toggle.imageCoords = ns.OPTIONS_ICON_TEXCOORDS
		toggle.dialogControl = ns.ICON_CHECKBOX_WIDGET_TYPE
		toggles["pet" .. food.settingKey] = toggle
	end
	Kit.WarmItems(coldItemIDs, ns.OPTIONS_REGISTRY.FoodWater)
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
-- Food & Water Panel
--------------------------------------------------------------------------------

--[[
    Everything that decides what the Food and Water macros eat and drink, on a
    page of its own under Consumable Macros, in two sections:

      Buffs Before You Eat -- Prioritize Buff Food, Eat Buff Food When Already
        Well Fed, Scroll Buffs, Pet Food Buffs, then Reapply Expiring Buffs,
        which sets when all three buffs count as worn off.
      Which Food Comes First -- conjured food and water first, Restock List
        food and water last.

    Opens with the off line while Consumable Macros is off; the settings stay
    editable so they can be set up first. Order values are spaced blocks so a
    row can be added without renumbering its neighbors. Registered as this
    builder function, so AceConfig rebuilds it on every open and NotifyChange.
]]
function ns.BuildFoodWaterOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_FOOD_WATER_PANEL_DESCRIPTION"], 1),

		-- Buffs Before You Eat
		spaceBuffs0 = Spacer(10),
		headerBuffs = Header(L["OPTIONS_FOOD_BUFFS_HEADER"], 11),
		spaceBuffs1 = Spacer(12),
		descBuffs = Desc(function()
			return GetColor("BODY")
				.. string.format(L["OPTIONS_FOOD_BUFFS_DESCRIPTION_FORMAT"], ns.GetWellFedName())
				.. "|r"
		end, 13),
		spaceBuffs2 = Spacer(14),
		toggleBuffFood = Kit.ToggleRow(20, {
			type = "toggle",
			name = L["OPTIONS_BUFF_FOOD"],
			desc = SpellDescription("OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			get = function()
				return BuffFoodActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useBuffFood", value)
			end,
		}, { control = FeatureModeSelect("buffFood", ModeDescription(L["FEATURE_BUFF_FOOD"])) }),
		spaceBuffFood = Spacer(22),
		toggleScrolls = {
			type = "toggle",
			name = L["OPTIONS_USE_SCROLLS"],
			desc = L["OPTIONS_USE_SCROLLS_DESCRIPTION"],
			order = 30,
			width = "full",
			get = function()
				return ScrollsActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useScrolls", value)
			end,
		},
		scrollsLevel = ModeSubRow("scrolls", ModeDescription(L["FEATURE_SCROLL_BUFFS"]), ScrollsActive, 31),
		spaceScrolls = Spacer(32, function()
			return not ScrollsActive()
		end),
		scrollTypesGroup = {
			type = "group",
			name = L["OPTIONS_SCROLL_TYPES"],
			order = 33,
			inline = true,
			hidden = function()
				return not ScrollsActive()
			end,
			args = {
				scrollAgility = SubsetToggle("scrollTypes", "Agility", SPELL_STAT2_NAME, 1),
				scrollIntellect = SubsetToggle("scrollTypes", "Intellect", SPELL_STAT4_NAME, 2),
				scrollProtection = SubsetToggle("scrollTypes", "Protection", L["OPTIONS_SCROLL_PROTECTION"], 3),
				scrollSpirit = SubsetToggle("scrollTypes", "Spirit", SPELL_STAT5_NAME, 4),
				scrollStamina = SubsetToggle("scrollTypes", "Stamina", SPELL_STAT3_NAME, 5),
				scrollStrength = SubsetToggle("scrollTypes", "Strength", SPELL_STAT1_NAME, 6),
			},
		},
		spaceScrollTypes = Spacer(34),
		togglePetBuffs = {
			type = "toggle",
			name = L["OPTIONS_USE_PET_BUFFS"],
			desc = SpellDescription("OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT", ns.WELL_FED_SPELL_ID),
			order = 40,
			width = "full",
			hidden = NoPetBuffFoods,
			get = function()
				return PetBuffActive()
			end,
			set = function(_, value)
				ns.db.profile.usePetBuffFood = value
				ns.UpdateAuraTracking()
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
			end,
		},
		petBuffFoodLevel = ModeSubRow("petBuffFood", ModeDescription(L["OPTIONS_PET_HEADER"]), PetBuffActive, 41),
		spacePetTypes0 = Spacer(42, function()
			return not PetBuffActive()
		end),
		petTypesGroup = {
			type = "group",
			name = L["OPTIONS_PET_BUFF_TYPES"],
			order = 43,
			inline = true,
			hidden = function()
				return not PetBuffActive()
			end,
			args = PetBuffTypeToggles(),
		},
		spacePet = Spacer(44, NoPetBuffFoods),

		--[[
		    Reapply Expiring Buffs closes the section, under the three buffs it
		    times: its dropdown keys are the threshold in seconds, stored
		    directly in earlyReapplyThreshold.
		]]
		toggleReapply = Kit.ToggleRow(50, {
			type = "toggle",
			name = L["OPTIONS_REAPPLY"],
			desc = L["OPTIONS_REAPPLY_DESCRIPTION"],
			get = function()
				return ReapplyActive()
			end,
			set = function(_, value)
				ns.db.profile.earlyReapply = value
				ns.ResetMacroState()
				ns.RequestUpdate()
				ns.RefreshSettings()
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
					ns.ResetMacroState()
					ns.RequestUpdate()
					ns.RefreshSettings()
				end,
			},
		}),

		-- Which Food Comes First
		spaceOrder0 = Spacer(60),
		headerOrder = Header(L["OPTIONS_FOOD_ORDER_HEADER"], 61),
		spaceOrder1 = Spacer(62),
		descOrder = Desc(GetColor("BODY") .. L["OPTIONS_FOOD_ORDER_DESCRIPTION"] .. "|r", 63),
		spaceOrder2 = Spacer(64),
		toggleConjuredFirst = Kit.ToggleRow(70, {
			type = "toggle",
			name = L["OPTIONS_CONJURED_FIRST"],
			desc = L["OPTIONS_CONJURED_FIRST_DESCRIPTION"],
			get = function()
				return ConjuredFirstActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useConjuredFirst", value)
			end,
		}, { control = FeatureModeSelect("conjuredFirst", L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"]) }),
		spaceConjuredFirst = Spacer(72),
		toggleRestockLast = {
			type = "toggle",
			name = L["OPTIONS_RESTOCK_LAST"],
			desc = L["OPTIONS_RESTOCK_LAST_DESCRIPTION"],
			order = 73,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.useRestockLast
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useRestockLast", value)
			end,
		},
	}

	-- Each When to Use's group context checkboxes, under its level filter.
	UseWhenGroups(args, "buffFood", BuffFoodActive, 21)
	UseWhenGroups(args, "scrolls", ScrollsActive, 31.5)
	UseWhenGroups(args, "petBuffFood", PetBuffActive, 41.5)
	UseWhenGroups(args, "conjuredFirst", ConjuredFirstActive, 71)

	ns.AddFeatureOffLine(args, "macrosEnabled")

	return {
		type = "group",
		name = Kit.SubPanelTitle(L["TAB_CONSUMABLE_MACROS"], L["OPTIONS_FOOD_WATER_HEADER"]),
		args = args,
	}
end
