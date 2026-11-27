local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

-- Not hidden behind the Buff Duty switch: these are choices worth making before turning the window on.
function ns.BuildBuffDutyBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = Kit.SubPanelTitle(L["TAB_BUFF_DUTY"], L["BUFF_DUTY_TRACKED_HEADER"]),
		type = "group",
		args = {
			-- Says "Tanks" and "Healers" once for every dropdown below, rather than in each tooltip.
			descBuffs = Kit.Desc(L["BUFF_DUTY_BUFFS_DESCRIPTION"]:format(MAINTANK), 1),
			space0 = Kit.Spacer(2),
		},
	}
	ns.AddFeatureOffLine(options.args, "buffWindow.enabled")

	-- A class's plain name, gold under a header rather than in its class color.
	local function PlainClassName(class)
		return LOCALIZED_CLASS_NAMES_MALE[class] or class
	end

	-- The client's own duration string, so "5 Minutes" reads right in every locale.
	local refreshValues = {}
	for _, minutes in ipairs(Data.BUFF_DUTY_REFRESH_CHOICES) do
		refreshValues[minutes] = D_MINUTES:format(minutes)
	end
	Kit.Section(options.args, "refresh", 20, L["BUFF_DUTY_REFRESH_HEADER"], L["BUFF_DUTY_REFRESH_SUMMARY"])
	options.args.refreshMinutes = Kit.LabelRow(21, nil, L["BUFF_DUTY_REFRESH"], {
		type = "select",
		desc = L["BUFF_DUTY_REFRESH_DESCRIPTION"],
		values = refreshValues,
		sorting = Data.BUFF_DUTY_REFRESH_CHOICES,
		get = function()
			return Settings().refreshMinutes
		end,
		set = function(_, value)
			Settings().refreshMinutes = value
			ns.RefreshBuffDuty()
		end,
	})
	-- Count as Tanks decides only for a player with no role of their own (RoleOf), so it sits apart from the role note.
	Kit.Section(options.args, "tanks", 28, L["BUFF_DUTY_TANKS_HEADER"], L["BUFF_DUTY_TANKS_DESCRIPTION"])

	local tankValues = {}
	for _, value in ipairs(Data.TANK_WHEN_ORDER) do
		tankValues[value] = L["BUFF_DUTY_TANKS_" .. value]
	end
	local function TankRow(key, caption, desc, order)
		options.args["tankWhen_" .. key] = Kit.LabelRow(order, nil, caption, {
			type = "select",
			desc = desc,
			values = tankValues,
			sorting = Data.TANK_WHEN_ORDER,
			get = function()
				return Settings().tankWhen[key] or Data.TANK_WHEN.NEVER
			end,
			set = function(_, value)
				Settings().tankWhen[key] = value
				ns.RefreshBuffDuty()
			end,
		})
	end

	local tankOrder = 31
	for _, class in ipairs(ns.OptionsClassList()) do
		TankRow(class, PlainClassName(class), L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"], tankOrder)
		tankOrder = tankOrder + 1
	end
	TankRow(Data.TANK_WHEN_PET, L["BUFF_DUTY_TANKS_PETS"], L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"], tankOrder)

	local audienceValues = {}
	for _, value in ipairs(Data.BUFF_AUDIENCE_ORDER) do
		audienceValues[value] = L["BUFF_DUTY_AUDIENCE_" .. value]
	end

	-- After Count as Tanks, which takes up to one order number per class.
	local categoryOrder = 60
	for _, category in ipairs(ns.buffDutyCategories or {}) do
		local groupKey = "cat_" .. category.id
		options.args[groupKey .. "Space0"] = Kit.Spacer(categoryOrder - 0.6)
		options.args[groupKey .. "Header"] = Kit.Header(PlainClassName(category.id), categoryOrder - 0.5)
		options.args[groupKey .. "Space"] = Kit.Spacer(categoryOrder - 0.4)

		local entryOrder = categoryOrder
		for _, entry in ipairs(ns.SortedEntries(category.entries)) do
			local cells = {}
			ns.DefineSpellSelectRow(cells, entry, 1, L["BUFF_DUTY_AUDIENCE_DESCRIPTION"]:format(entry.spellName), {
				labelWidth = Kit.LABEL_WIDTH,
				width = Kit.CONTROL_WIDTH,
				values = audienceValues,
				sorting = Data.BUFF_AUDIENCE_ORDER,
				get = function()
					return Settings().audience[entry.key]
				end,
				set = function(_, value)
					Settings().audience[entry.key] = value
					ns.RefreshBuffDuty()
				end,
			})
			local primary = entry.ids[1]
			options.args[groupKey .. "_" .. primary] = Kit.Row(entryOrder, nil, {
				cells["label_" .. primary],
				cells["select_" .. primary],
			})
			entryOrder = entryOrder + 0.01
		end

		categoryOrder = categoryOrder + 1
	end

	return options
end
