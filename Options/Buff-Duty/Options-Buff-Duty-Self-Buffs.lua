local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--[[
    "Self-Buffs" panel, under Buff Duty: every buff you can put on yourself,
    each On or Off; the category's Show, at the top, says how soon each
    shows. That's the self-only buffs (armors, auras,
    aspects, Inner Fire) and the class's group buffs (Fortitude, Mark of the
    Wild, the blessings), which the window offers you under Self Buffs and
    leaves off your party row; Group Buffs says who ELSE gets those.

    Laid out as a tree: the classes down the left, opened on your own (the
    settings are account-wide, so every class is listed), and the chosen
    class's buffs on the right. Above the tree, the Self-Buffs category's
    own settings (ns.AddBuffDutyRowControls). The
    consumables any class can use have pages of their own, one per window
    row (Options-Buff-Duty-Consumables.lua).

    Its Show in Buff Duty switch is twinned on the Buff Duty panel with the
    window's other rows. Like the Group Buffs panel, nothing here hides behind it:
    these are choices worth making before turning the row on. Weapons have a
    panel of their own (Options-Buff-Duty-Weapon-Buffs.lua).
]]

--[[
    "Hunter · any one aspect counts", the header over a class's page: a class
    with two or more buffs from one exclusive family says so after its name,
    since any one of them up is enough. A family of one (Lightning Shield
    alone) needs no note.
]]
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

	-- the class's plain name, gold like every header, and its notes gray beside it
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
	--[[
	    With Buff Duty on, the line names this page's own switch while that is off.
	    The switch is on this page (Show in Buff Duty, above), so the line sends you
	    nowhere else.
	]]
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
			-- A blank line between rows, so each checkbox has room around it.
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
