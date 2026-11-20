local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--[[
    "Self-Buffs" panel, under Buff Duty: every buff you can put on yourself,
    one dropdown each picking when it shows -- Off, When Missing, or a few
    minutes before it runs out. That's the self-only buffs (armors, auras,
    aspects, Inner Fire) and the class's group buffs (Fortitude, Mark of the
    Wild, the blessings), which the window offers you under Self Buffs and
    leaves off your party row; Group Buffs says who ELSE gets those. Its own
    time per buff rather than Group Buffs' one "Refresh Under", since a
    30-minute armor and a 10-minute Thorns want different warnings.

    Laid out as a tree: the classes down the left, opened on your own (the
    settings are account-wide, so every class is listed), and the chosen
    class's buffs on the right. The consumables any class can use (Winterfall
    Firewater) come last, as a page of their own, closing with the scroll
    types the window's Scrolls row and the Readiness Report check.

    The switch for the window's Self-Buffs row lives on the Buff Duty panel with
    the window's other rows. Like the Group Buffs panel, nothing here hides behind it:
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
	-- The consumables' page says they only show while you carry one.
	if category.id == "ITEMS" then
		name = name .. " " .. GetColor("MUTED") .. "· " .. L["BUFF_DUTY_SELF_ITEMS_NOTE"] .. "|r"
	end
	for _, family in ipairs(families) do
		local note = L["BUFF_DUTY_SELF_NOTE_" .. family]
		if note then
			name = name .. " " .. GetColor("MUTED") .. "· " .. note .. "|r"
		end
	end
	return name
end

--[[
    The scroll types on the Consumables page, one checkbox each, named as
    Buff Duty's Scrolls flyout names them (ns.SCROLL_TYPE_LABELS). A flavor
    with no consumable buffs still gets the page, for the scrolls alone.
    scrollTypes is on the AceDB profile: which scrolls are worth offering
    differs from character to character (a README-Notes exception).
]]
local function AddScrollTypes(args, order)
	local page = args.ITEMS
	if not page then
		page = {
			type = "group",
			name = L["BUFF_DUTY_SELF_ITEMS_HEADER"],
			order = order,
			args = { header = Kit.Header(L["BUFF_DUTY_SELF_ITEMS_HEADER"], 1), spaceHeader = Kit.Spacer(2) },
		}
		args.ITEMS = page
	end

	local toggles = {}
	for index, scroll in ipairs(ns.SCROLL_TYPE_LABELS or {}) do
		local key, label = scroll[1], scroll[2] or scroll[1]
		toggles[key] = {
			type = "toggle",
			name = label,
			desc = L["OPTIONS_BUFF_TYPE_DESCRIPTION"]:format(label),
			order = index,
			get = function()
				local types = ns.db.profile.scrollTypes
				return types and types[key]
			end,
			set = function(_, value)
				ns.db.profile.scrollTypes[key] = value
				ns.RefreshBuffDuty()
			end,
		}
	end
	page.args.spaceScrolls = Kit.Spacer(900)
	page.args.scrollTypes = {
		type = "group",
		name = L["OPTIONS_SCROLL_TYPES"],
		order = 901,
		inline = true,
		args = toggles,
	}
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
		},
	}
	-- With Buff Duty on, the line names this page's own switch, on the Buff Duty page, while that is off.
	ns.AddFeatureOffLine(options.args, "buffWindow.enabled", {
		isOn = function()
			return Settings().selfEnabled
		end,
		name = "BUFF_DUTY_SELF_ENABLE",
		page = "TAB_BUFF_DUTY",
	})

	local refreshValues = ns.BuffDutyRefreshValues(Data.SELF_REFRESH_CHOICES)
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
			-- A blank line between rows, so each dropdown has room around it.
			if index > 1 then
				page.args["space" .. index] = Kit.Spacer(entryOrder - 0.25)
			end
			ns.DefineSpellSelectRow(
				page.args,
				entry,
				entryOrder,
				entry.desc or L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"]:format(entry.spellName),
				{
					values = refreshValues,
					sorting = Data.SELF_REFRESH_CHOICES,
					-- The tree's pane is narrower than the panel: its own caption and dropdown widths.
					labelWidth = Kit.TREE_LABEL_WIDTH,
					width = Kit.TREE_CONTROL_WIDTH,
					get = function()
						return Settings().selfRefresh[entry.key]
					end,
					set = function(_, value)
						Settings().selfRefresh[entry.key] = value
						ns.RefreshBuffDuty()
					end,
				}
			)
			entryOrder = entryOrder + 1
		end

		selfOrder = selfOrder + 1
	end

	AddScrollTypes(options.args, selfOrder)
	return options
end
