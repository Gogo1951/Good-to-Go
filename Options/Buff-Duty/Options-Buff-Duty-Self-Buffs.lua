local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

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

function ns.BuildBuffDutySelfBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = Kit.SubPanelTitle(L["TAB_BUFF_DUTY"], L["BUFF_DUTY_SELF_HEADER"]),
		type = "group",
		childGroups = "tree",
		args = {
			descIntro = Kit.Desc(L["BUFF_DUTY_SELF_DESCRIPTION"], 1),
			spaceIntro = Kit.Spacer(1.5),
		},
	}
	ns.AddBuffDutyRowControls(options.args, "self", 2)
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

		local entryOrder = 10
		for index, entry in ipairs(ns.SortedEntries(category.entries)) do
			if index > 1 then
				page.args["space" .. index] = Kit.Spacer(entryOrder - 0.25)
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

		selfOrder = selfOrder + 1
	end

	return options
end
