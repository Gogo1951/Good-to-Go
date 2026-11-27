local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local Data = ns.Data
local GetColor = ns.GetColor
local GetSpellTexture = C_Spell.GetSpellTexture

--[[
    Lists your class's group buffs too, since the window offers them to you
    under Self Buffs; Group Buffs says who else gets them. Nothing hides
    behind the category switch: these are choices worth making before
    turning it on.
]]

-- "Hunter · any one aspect counts": a family of two or more says any one up is enough.
local function CategoryName(category)
	local counts, families = {}, {}
	for _, entry in ipairs(category.entries) do
		local family = entry.exclusive
		if family then
			counts[family] = (counts[family] or 0) + 1
			if counts[family] == 2 then
				families[#families + 1] = family
			end
		end
	end
	table.sort(families)

	local name = LOCALIZED_CLASS_NAMES_MALE[category.id] or category.name
	for _, family in ipairs(families) do
		local note = L["BUFF_DUTY_SELF_NOTE_" .. family]
		if note then
			name = name .. " " .. GetColor("MUTED") .. "· " .. note .. "|r"
		end
	end
	return name
end

local function Settings()
	return ns.db.global.buffWindow
end

-- A caption beside its control, at the tree pane's own widths.
local function TreeRow(order, caption, control)
	control.name = ""
	control.width = Kit.TREE_CONTROL_WIDTH
	return Kit.Row(order, nil, { Kit.Label(caption, nil, Kit.TREE_LABEL_WIDTH, control.desc), control })
end

--[[
    A type's own Show in Buff Duty, When to Use, Show and Use with Cast Next
    Buff, as its menu in the window has them, keyed by `prefix`. Takes the
    orders `order` to `order` + 0.4.
]]
local function AddTypeControls(args, prefix, row, order)
	local BuffDuty = ns.BuffDuty
	args[prefix .. "rowOn"] = TreeRow(order, L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY"], {
		type = "toggle",
		desc = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
		get = function()
			return BuffDuty.RowOn(row)
		end,
		set = function(_, value)
			BuffDuty.SetRowOn(row, value)
			ns.RefreshBuffDuty()
		end,
	})
	local values = {}
	for _, value in ipairs(Data.BUFF_DUTY_ROW_WHEN_ORDER) do
		values[value] = L["BUFF_DUTY_ROW_WHEN_" .. value]
	end
	args[prefix .. "rowWhen"] = TreeRow(order + 0.1, L["BUFF_DUTY_ROW_WHEN"], {
		type = "select",
		desc = L["BUFF_DUTY_ROW_WHEN_DESCRIPTION"],
		values = values,
		sorting = Data.BUFF_DUTY_ROW_WHEN_ORDER,
		get = function()
			return Settings().rowWhen[row] or Data.BUFF_DUTY_ROW_WHEN.ALWAYS
		end,
		set = function(_, value)
			Settings().rowWhen[row] = value
			ns.RefreshBuffDuty()
		end,
	})
	args[prefix .. "rowShow"] = TreeRow(order + 0.2, L["BUFF_DUTY_MENU_SHOW"], {
		type = "select",
		desc = L["BUFF_DUTY_ROW_SHOW_DESCRIPTION"],
		values = ns.BuffDutyRefreshValues(Data.BUFF_DUTY_ROW_SHOW_CHOICES),
		sorting = Data.BUFF_DUTY_ROW_SHOW_CHOICES,
		get = function()
			return Settings().rowShow[row] or Data.BUFF_DUTY_ROW_SHOW_DEFAULT
		end,
		set = function(_, value)
			Settings().rowShow[row] = value
			ns.RefreshBuffDuty()
		end,
	})
	args[prefix .. "rowKey"] = TreeRow(order + 0.3, L["BUFF_DUTY_ROW_KEY"]:format(L["BUFF_KEY"]), {
		type = "toggle",
		desc = L["BUFF_DUTY_ROW_KEY_DESCRIPTION"]:format(L["BUFF_KEY"]),
		get = function()
			return Settings().rowKey[row] ~= false
		end,
		set = function(_, value)
			Settings().rowKey[row] = value
			ns.RefreshBuffDuty()
		end,
	})
end

local PICK_NONE = "NONE"

-- A pick-one family (the druid forms) as one dropdown: None, then each of them.
local function AddPickRow(args, prefix, picks, order)
	local family = picks[1].pickOne
	local values, sorting = { [PICK_NONE] = L["BUFF_DUTY_MENU_PICK_NONE"] }, { PICK_NONE }
	local byValue = {}
	for _, entry in ipairs(picks) do
		local value = tostring(entry.key)
		local texture = GetSpellTexture(entry.ids[1])
		values[value] = texture and ("|T" .. texture .. ":16|t " .. entry.spellName) or entry.spellName
		sorting[#sorting + 1] = value
		byValue[value] = entry.key
	end
	args[prefix .. "pick"] = TreeRow(order, L["BUFF_DUTY_SELF_FORM_PICK"], {
		type = "select",
		desc = L["BUFF_DUTY_SELF_FORM_PICK_DESCRIPTION"],
		values = values,
		sorting = sorting,
		get = function()
			for _, entry in ipairs(picks) do
				if ns.BuffDuty.SelfItemOn(entry.key) then
					return tostring(entry.key)
				end
			end
			return PICK_NONE
		end,
		set = function(_, value)
			ns.BuffDuty.PickSelfItem(picks, family, byValue[value])
			ns.RefreshBuffDuty()
		end,
	})
end

function ns.BuildBuffDutySelfBuffsOptions()
	local options = {
		name = Kit.SubPanelTitle(L["TAB_BUFF_DUTY"], L["BUFF_DUTY_SELF_HEADER"]),
		type = "group",
		childGroups = "tree",
		args = {
			descIntro = Kit.Desc(L["BUFF_DUTY_SELF_DESCRIPTION"], 1),
			spaceIntro = Kit.Spacer(1.5),
		},
	}
	-- Each type's own settings are on its class's page, beside its spells.
	options.args.rowOn = {
		type = "toggle",
		name = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY"],
		desc = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
		width = "full",
		order = 2,
		get = function()
			return ns.BuffDuty.RowOn("self")
		end,
		set = function(_, value)
			ns.BuffDuty.SetRowOn("self", value)
			ns.RefreshBuffDuty()
		end,
	}
	options.args.spaceRowOn = Kit.Spacer(2.05)
	-- No page key: the category's switch is on this page, so the line sends you nowhere else.
	ns.AddFeatureOffLine(options.args, "buffWindow.enabled", {
		isOn = function()
			return Settings().selfEnabled
		end,
		name = "BUFF_DUTY_SELF_ENABLE",
	})

	local selfOrder = 10
	for _, category in ipairs(ns.buffDutySelfCategories or {}) do
		-- Keyed by the class token, so the tree can open on yours (Options/Options.lua).
		local page = {
			type = "group",
			name = category.name,
			order = selfOrder,
			args = {
				header = Kit.Header(CategoryName(category), 1),
				spaceHeader = Kit.Spacer(2),
			},
		}
		options.args[category.id] = page

		-- Each type A to Z: its name, its settings, then its spells.
		local entryOrder = 10
		for typeIndex, selfType in ipairs(ns.BuffDuty.SelfTypes(category)) do
			local prefix = selfType.id .. "_"
			if typeIndex > 1 then
				page.args[prefix .. "spaceType"] = Kit.Spacer(entryOrder - 0.5)
			end
			page.args[prefix .. "header"] = Kit.Header(selfType.name, entryOrder - 0.45)
			AddTypeControls(page.args, prefix, ns.BuffDuty.SelfTypeRow(selfType.id, category.id), entryOrder - 0.4)
			page.args[prefix .. "spaceControls"] = Kit.Spacer(entryOrder - 0.05)
			local picks, toggles = {}, {}
			for _, entry in ipairs(ns.SortedEntries(selfType.entries)) do
				table.insert(entry.pickOne and picks or toggles, entry)
			end
			if picks[1] then
				AddPickRow(page.args, prefix, picks, entryOrder)
				entryOrder = entryOrder + 1
			end
			for index, entry in ipairs(toggles) do
				if index > 1 or picks[1] then
					page.args["space" .. entry.key] = Kit.Spacer(entryOrder - 0.25)
				end
				ns.DefineSpellToggleRow(
					page.args,
					entry,
					entryOrder,
					entry.desc or L["BUFF_DUTY_MENU_ITEM_DESCRIPTION_FORMAT"]:format(entry.spellName),
					{
						-- The tree's pane is narrower than the panel: its own caption and control widths.
						labelWidth = Kit.TREE_LABEL_WIDTH,
						width = Kit.TREE_CONTROL_WIDTH,
						get = function()
							return ns.BuffDuty.SelfItemOn(entry.key)
						end,
						set = function(_, value)
							ns.BuffDuty.SetSelfItemOn(entry.key, value)
							ns.RefreshBuffDuty()
						end,
					}
				)
				entryOrder = entryOrder + 1
			end
			entryOrder = entryOrder + 1
		end

		selfOrder = selfOrder + 1
	end

	return options
end
