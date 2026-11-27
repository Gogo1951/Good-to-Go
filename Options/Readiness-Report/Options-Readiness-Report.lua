local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Readiness Report Panel
--------------------------------------------------------------------------------

--[[
    Every switch may only ADD a line about something wrong; see the silence
    rule in Readiness-Report.lua. Rows are built from SECTIONS so every one gets
    the same parts in the same rhythm.
]]

local function ReportsHidden()
	return not (ns.db and ns.db.global.readinessReportEnabled)
end

-- Matches the check: Era raids don't run on flasks (the maintainer's choice).
local function FlaskHidden()
	return ReportsHidden() or ns.EXPANSION < 2
end

local function PetWellFedHidden()
	return ReportsHidden() or next(ns.PET_BUFF_FOODS) == nil
end

local function SpecHidden()
	return ReportsHidden() or not ns.CanReportSpecialization()
end

--------------------------------------------------------------------------------
-- Reset
--------------------------------------------------------------------------------

--[[
    Its own Reset: these are account-wide, and ResetProfile reaches only the
    profile. Keys come from ns.DATABASE_DEFAULTS, so a new readiness key joins
    for free. All are scalars, so writing the default across is safe; a table
    default would alias the defaults table.
]]
local READINESS_KEY_PATTERN = "^readiness"
local MASTER_SWITCH_KEY = "readinessReportEnabled"

local function ReadinessAtDefaults()
	local defaults = ns.DATABASE_DEFAULTS and ns.DATABASE_DEFAULTS.global
	if not (ns.db and defaults) then
		return true
	end
	for key, value in pairs(defaults) do
		if key ~= MASTER_SWITCH_KEY and key:find(READINESS_KEY_PATTERN) and ns.db.global[key] ~= value then
			return false
		end
	end
	return true
end

local function ResetReadinessSettings()
	local defaults = ns.DATABASE_DEFAULTS and ns.DATABASE_DEFAULTS.global
	if not (ns.db and defaults) then
		return
	end

	for key, value in pairs(defaults) do
		if key ~= MASTER_SWITCH_KEY and key:find(READINESS_KEY_PATTERN) then
			ns.db.global[key] = value
		end
	end
end

--------------------------------------------------------------------------------
-- Thresholds
--------------------------------------------------------------------------------

-- Seconds, labeled as minutes.
local EXPIRING_SECONDS = { 60, 120, 150, 180, 300, 480 }

local function ExpiringValues()
	local values = {}
	for _, seconds in ipairs(EXPIRING_SECONDS) do
		local minutes = seconds / 60
		if minutes == 1 then
			-- Its own key: no plural template renders the one-minute entry grammatically.
			values[seconds] = L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"]
		else
			-- Trims a whole number's ".0" without rounding the half minute away.
			local label = (minutes % 1 == 0) and tostring(math.floor(minutes))
				or (tostring(minutes):gsub("%.", L["DECIMAL_SEPARATOR"]))
			values[seconds] = string.format(L["OPTIONS_READINESS_EXPIRING_MINUTES"], label)
		end
	end
	return values
end

local DURABILITY_PERCENTS = { 10, 20, 30, 40, 50 }

local function DurabilityValues()
	local values = {}
	for _, percent in ipairs(DURABILITY_PERCENTS) do
		values[percent] = string.format(L["OPTIONS_READINESS_DURABILITY_PERCENT"], percent)
	end
	return values
end

-- No caption: the switch's label reads straight into it ("Damaged Gear Below 20%").
local EXPIRING_THRESHOLD = {
	key = "readinessExpiringThreshold",
	description = "OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION",
	values = ExpiringValues,
	sorting = EXPIRING_SECONDS,
}

local DURABILITY_THRESHOLD = {
	key = "readinessDurabilityThreshold",
	description = "OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION",
	values = DurabilityValues,
	sorting = DURABILITY_PERCENTS,
}

--------------------------------------------------------------------------------
-- Panel Contents
--------------------------------------------------------------------------------

--[[
    In the report's print order. Locale keys, resolved at build. `nameArg` and
    `descriptionArg` fill a key's %s with the client's name for a game record;
    a function in place of a key is the text itself.
]]
local SECTIONS = {
	{
		key = "Buffs",
		title = "OPTIONS_READINESS_BUFFS_HEADER",
		summary = "OPTIONS_READINESS_BUFFS_SUMMARY",
		rows = {
			{
				key = "readinessFlask",
				name = "READINESS_FLASK",
				description = "OPTIONS_READINESS_FLASK_DESCRIPTION",
				hidden = FlaskHidden,
			},
			{
				key = "readinessWellFed",
				name = ns.GetWellFedName,
				description = "OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT",
				descriptionArg = ns.GetWellFedName,
			},
			{
				key = "readinessPetWellFed",
				name = "READINESS_PET_FORMAT",
				nameArg = ns.GetWellFedName,
				description = "OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT",
				descriptionArg = ns.GetWellFedName,
				hidden = PetWellFedHidden,
			},
			{
				key = "readinessScrolls",
				name = "FEATURE_SCROLL_BUFFS",
				description = "OPTIONS_READINESS_SCROLLS_DESCRIPTION",
			},
			{
				key = "readinessSoulstone",
				name = "READINESS_SOULSTONE",
				description = "OPTIONS_READINESS_SOULSTONE_DESCRIPTION",
			},
			{
				key = "readinessMainHandBuff",
				name = "OPTIONS_READINESS_MAIN_HAND",
				description = ns.WEAPON_ENCHANTS_STACK and "OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"
					or "OPTIONS_READINESS_MAIN_HAND_DESCRIPTION",
			},
			{
				key = "readinessOffHandBuff",
				name = "OPTIONS_READINESS_OFF_HAND",
				description = ns.WEAPON_ENCHANTS_STACK and "OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"
					or "OPTIONS_READINESS_OFF_HAND_DESCRIPTION",
			},
			{
				key = "readinessExpiring",
				name = "OPTIONS_READINESS_EXPIRING",
				description = "OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION",
				threshold = EXPIRING_THRESHOLD,
			},
		},
	},
	{
		key = "Items",
		title = "OPTIONS_READINESS_ITEMS_HEADER",
		summary = "OPTIONS_READINESS_ITEMS_SUMMARY",
		rows = {
			{
				key = "readinessHealthstone",
				name = "READINESS_HEALTHSTONE",
				description = "OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION",
			},
			{
				key = "readinessManaGem",
				name = "READINESS_MANA_GEM",
				description = "OPTIONS_READINESS_MANA_GEM_DESCRIPTION",
			},
			{
				key = "readinessHealingPotion",
				name = "READINESS_HEALING_POTION",
				description = "OPTIONS_READINESS_HEALING_POTION_DESCRIPTION",
			},
			{
				key = "readinessManaPotion",
				name = "READINESS_MANA_POTION",
				description = "OPTIONS_READINESS_MANA_POTION_DESCRIPTION",
			},
			{
				key = "readinessBandages",
				name = "READINESS_BANDAGES",
				description = "OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION",
				descriptionArg = ns.GetFirstAidName,
			},
			{
				key = "readinessDurability",
				name = "OPTIONS_READINESS_DURABILITY",
				description = "OPTIONS_READINESS_DURABILITY_DESCRIPTION",
				threshold = DURABILITY_THRESHOLD,
			},
		},
	},
	{
		key = "Character",
		title = "OPTIONS_READINESS_CHARACTER_HEADER",
		summary = "OPTIONS_READINESS_CHARACTER_SUMMARY",
		rows = {
			{
				key = "readinessSpec",
				name = "OPTIONS_READINESS_SPECIALIZATION",
				description = "OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION",
				hidden = SpecHidden,
			},
			{
				key = "readinessPvP",
				name = "READINESS_PVP_ON",
				description = "OPTIONS_READINESS_PVP_DESCRIPTION",
			},
			{
				key = "readinessQuestionableGear",
				name = "OPTIONS_READINESS_QUESTIONABLE_GEAR",
				description = "OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION",
			},
		},
	},
}

--------------------------------------------------------------------------------
-- Row Builders
--------------------------------------------------------------------------------

-- Every row ends with its own break, so only the first section adds one above its header.
local function AddSection(args, section, order, isFirst)
	if isFirst then
		args["space" .. section.key .. "Top"] = Spacer(order, ReportsHidden)
	end
	args["header" .. section.key] = Header(L[section.title], order + 1, ReportsHidden)
	args["space" .. section.key .. "Under"] = Spacer(order + 2, ReportsHidden)
	args["desc" .. section.key] = Desc(L[section.summary], order + 3, ReportsHidden)
	args["space" .. section.key .. "Summary"] = Spacer(order + 4, ReportsHidden)
	return order + 5
end

local function RowText(text, arg)
	if type(text) == "function" then
		return text
	end
	if arg then
		return function()
			return string.format(L[text], arg())
		end
	end
	return L[text]
end

-- Every part carries the row's `hidden`, so a row not offered (Flask on Era) takes its break with it.
local function AddReportRow(args, row, order)
	local hidden = row.hidden or ReportsHidden
	local key = row.key
	local description = RowText(row.description, row.descriptionArg)
	local threshold = row.threshold

	args["toggle" .. key] = {
		type = "toggle",
		name = RowText(row.name, row.nameArg),
		desc = description,
		order = order,
		width = threshold and ns.OPTIONS_LABEL_WIDTH or "full",
		hidden = hidden,
		get = function()
			return ns.db and ns.db.global[key]
		end,
		set = function(_, value)
			ns.db.global[key] = value
			ns.RefreshSettings()
		end,
	}
	order = order + 1

	if threshold then
		args["value" .. key] = {
			type = "select",
			name = "",
			desc = L[threshold.description],
			order = order,
			width = ns.OPTIONS_CONTROL_WIDTH,
			hidden = function()
				return hidden() or not (ns.db and ns.db.global[key])
			end,
			values = threshold.values,
			sorting = threshold.sorting,
			get = function()
				return ns.db.global[threshold.key]
			end,
			set = function(_, value)
				ns.db.global[threshold.key] = value
				ns.RefreshSettings()
			end,
		}
		order = order + 1
	end

	args["space" .. key] = Spacer(order, hidden)
	return order + 1
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

function ns.BuildReadinessReportOptions()
	local args = {}
	local order = 1

	args.descIntro = Desc(L["OPTIONS_READINESS_DESCRIPTION"], order)
	order = order + 1
	args.spaceIntro = Spacer(order)
	order = order + 1
	args.toggleReadiness = Kit.FeatureSwitch("readinessReportEnabled", order)
	order = order + 1

	for index, section in ipairs(SECTIONS) do
		order = AddSection(args, section, order, index == 1)
		for _, row in ipairs(section.rows) do
			order = AddReportRow(args, row, order)
		end
	end

	args.exampleReadiness = Kit.Example(order, ReportsHidden, function()
		return ns.PrintedExampleLines(ns.BuildReadinessSampleLines())
	end)
	order = order + 1

	-- Not gated on the switch: the categories keep their values while the report is off.
	args.spaceReset = Spacer(order)
	order = order + 1
	args.resetReadiness = Kit.ResetRow(
		order,
		nil,
		L["OPTIONS_READINESS_RESET"],
		L["OPTIONS_READINESS_RESET_DESCRIPTION"],
		ReadinessAtDefaults,
		ResetReadinessSettings,
		L["OPTIONS_READINESS_RESET_CONFIRM"]
	)

	return {
		type = "group",
		name = L["TAB_READINESS_REPORT"],
		args = args,
	}
end
