local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--[[
    The pages for the consumables any class keeps up, one per category (and
    section of the Buff Duty window), under Buff Duty: Well Fed, Scrolls (with
    the scroll types the window and the Readiness Report check), Flasks or
    Elixirs, and Other Buffs (Winterfall Firewater). Each opens with the
    category's own settings (ns.AddBuffDutyRowControls); Other Buffs then
    has an On and Off per consumable. Which buff food, scrolls and elixirs
    in your bags the window passes over is the window's menus' to say: each
    category's line opens its own.
]]

--[[
    A page: its title, intro, then the category's settings. While Buff Duty is
    off, or it's on and the category's switch on the Buff Duty page is off, the
    page opens with a line saying so (ns.AddFeatureOffLine). switchName is that
    switch's name as the Buff Duty page has it: a locale key, or a function for
    a name the client supplies (Well Fed).
]]
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

--[[
    The scroll types, one checkbox each, named as Buff Duty's Scrolls flyout
    names them (ns.SCROLL_TYPE_LABELS). scrollTypes is on the AceDB profile:
    which scrolls are worth offering differs from character to character (a
    README-Notes exception).
]]
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
		name = L["OPTIONS_SCROLL_TYPES"],
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

-- The consumables with a switch of their own (Winterfall Firewater), each On or Off.
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
