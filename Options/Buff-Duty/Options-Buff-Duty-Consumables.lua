local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

-- Which buff food, scrolls and elixirs the window passes over is set only in its category menus (README-Notes).

-- switchName is a locale key, or a function for a name the client supplies (Well Fed).
local function BuildPage(title, intro, row, switchName)
	local options = {
		name = Kit.SubPanelTitle(L["TAB_BUFF_DUTY"], title),
		type = "group",
		args = {
			descIntro = Kit.Desc(intro, 1),
			spaceIntro = Kit.Spacer(1.5),
		},
	}
	ns.AddBuffDutyRowControls(options.args, row, 2)
	ns.AddFeatureOffLine(options.args, "buffWindow.enabled", {
		isOn = function()
			return ns.BuffDuty.RowOn(row)
		end,
		name = switchName,
		page = "TAB_BUFF_DUTY",
	})
	return options
end

function ns.BuildBuffDutyFoodOptions()
	return BuildPage(ns.BuffDuty.WellFedLabel(), L["BUFF_DUTY_FOOD_PAGE_DESCRIPTION"], "food", ns.BuffDuty.WellFedLabel)
end

-- scrollTypes rides the profile, since scrolls worth offering differ per character (README-Notes).
function ns.BuildBuffDutyScrollsOptions()
	local options =
		BuildPage(L["BUFF_DUTY_SCROLLS"], L["BUFF_DUTY_SCROLLS_PAGE_DESCRIPTION"], "scrolls", "BUFF_DUTY_SCROLLS")
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
	options.args.spaceScrolls = Kit.Spacer(900)
	options.args.scrollTypes = {
		type = "group",
		name = L["BUFF_DUTY_SCROLL_TYPES"],
		order = 901,
		inline = true,
		args = toggles,
	}
	return options
end

function ns.BuildBuffDutyElixirsOptions()
	return BuildPage(
		L["BUFF_DUTY_ROW_ELIXIRS"],
		L["BUFF_DUTY_ELIXIRS_PAGE_DESCRIPTION"],
		"elixirs",
		"BUFF_DUTY_ROW_ELIXIRS"
	)
end

function ns.BuildBuffDutyOtherOptions()
	local options =
		BuildPage(L["BUFF_DUTY_ROW_OTHER"], L["BUFF_DUTY_OTHER_PAGE_DESCRIPTION"], "other", "BUFF_DUTY_ROW_OTHER")
	local order = 10
	for index, entry in ipairs(ns.BuffDuty.selfItemEntries) do
		if not (entry.wellFed or entry.scrolls or entry.elixirs) then
			local spellName = entry.name or C_Spell.GetSpellName(entry.ids[1]) or tostring(entry.itemId)
			local row = { key = entry.key, ids = entry.ids, spellName = spellName }
			if order > 10 then
				options.args["space" .. index] = Kit.Spacer(order - 0.25)
			end
			ns.DefineSpellToggleRow(
				options.args,
				row,
				order,
				entry.desc or L["BUFF_DUTY_MENU_ITEM_DESCRIPTION_FORMAT"]:format(spellName),
				{
					get = function()
						return ns.BuffDuty.SelfItemOn(entry.key)
					end,
					set = function(_, value)
						ns.BuffDuty.SetSelfItemOn(entry.key, value)
						ns.RefreshBuffDuty()
					end,
				}
			)
			order = order + 1
		end
	end
	return options
end
