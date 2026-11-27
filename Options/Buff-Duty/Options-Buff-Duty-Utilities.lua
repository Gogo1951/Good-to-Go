local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetSpellTexture = C_Spell.GetSpellTexture

--------------------------------------------------------------------------------
-- Ability Rows
--------------------------------------------------------------------------------

--[[
    An InteractiveLabel, since a plain Label takes no mouse; AceConfigDialog's
    hover handler shows its `tooltipHyperlink`.
]]
function ns.OptionsAbilityLabel(text, order, width, hyperlink)
	local label = Kit.Label(text, order, width)
	label.dialogControl = "InteractiveLabel"
	label.tooltipHyperlink = hyperlink
	return label
end

--[[
    The highest described id, so the tooltip reads the rank you cast. Ids are
    sorted, since data rows aren't reliably rank-ordered. Classic holds tooltip
    data only for spells the character has known, so each id is requested once
    and the pick is made again at every hover, once the text has landed.
]]
function ns.SpellTooltipLink(ids)
	local ranked = {}
	for i = 1, #ids do
		ranked[i] = ids[i]
		C_Spell.RequestLoadSpellData(ids[i])
	end
	table.sort(ranked)
	return function()
		for i = #ranked, 1, -1 do
			local text = C_Spell.GetSpellDescription(ranked[i])
			if text and text ~= "" then
				return "spell:" .. ranked[i]
			end
		end
		return "spell:" .. ranked[#ranked]
	end
end

local function EntrySortKey(entry)
	return (entry.spellName or ""):lower()
end

-- The watched id breaks ties, for a stable order.
function ns.SortedEntries(entries)
	local sorted = {}
	for i = 1, #entries do
		sorted[i] = entries[i]
	end
	table.sort(sorted, function(a, b)
		local keyA, keyB = EntrySortKey(a), EntrySortKey(b)
		if keyA == keyB then
			return (a.ids[1] or 0) < (b.ids[1] or 0)
		end
		return keyA < keyB
	end)
	return sorted
end

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------

-- CLASS_SPELL_LISTS is keyed by every class the flavor has.
function ns.OptionsClassList()
	local classes = {}
	for class in pairs(ns.CLASS_SPELL_LISTS) do
		classes[class] = true
	end
	for _, list in ipairs({
		ns.BUFF_DUTY_SPELLS,
		ns.BUFF_DUTY_SELF_SPELLS,
		ns.BUFF_DUTY_WEAPON_ENCHANTS,
	}) do
		for _, row in ipairs(list) do
			if row.class then
				classes[row.class] = true
			end
		end
	end
	local classNames = {}
	for class in pairs(classes) do
		classNames[#classNames + 1] = class
	end
	table.sort(classNames)
	return classNames
end

--------------------------------------------------------------------------------
-- Spell Dropdown Rows
--------------------------------------------------------------------------------

-- "Under 5 Minutes" is built from the client's own duration string.
function ns.BuffDutyRefreshValues(choices)
	local values = {}
	for _, choice in ipairs(choices) do
		if choice == Data.SELF_REFRESH_OFF then
			values[choice] = L["BUFF_DUTY_SELF_REFRESH_OFF"]
		elseif choice == Data.SELF_REFRESH_MISSING then
			values[choice] = L["BUFF_DUTY_SELF_REFRESH_MISSING"]
		else
			values[choice] = L["BUFF_DUTY_SELF_REFRESH_UNDER"]:format(D_MINUTES:format(choice))
		end
	end
	return values
end

-- `select` may carry labelWidth and width, for a row in a tree's narrower pane.
function ns.DefineSpellSelectRow(args, entry, order, desc, select)
	local primary = entry.ids[1]
	local texture = GetSpellTexture(primary)
	local caption = texture and ("|T" .. texture .. ":16|t " .. entry.spellName) or entry.spellName

	args["label_" .. primary] =
		ns.OptionsAbilityLabel(caption, order, select.labelWidth or Kit.LABEL_WIDTH, ns.SpellTooltipLink(entry.ids))
	args["select_" .. primary] = {
		type = "select",
		name = "",
		desc = desc,
		values = select.values,
		sorting = select.sorting,
		width = select.width or ns.OPTIONS_CONTROL_WIDTH,
		order = order + 0.5,
		get = select.get,
		set = select.set,
	}
end

-- `toggle` may carry labelWidth, for a row in a tree's narrower pane.
function ns.DefineSpellToggleRow(args, entry, order, desc, toggle)
	local primary = entry.ids[1]
	local texture = GetSpellTexture(primary)
	local caption = texture and ("|T" .. texture .. ":16|t " .. entry.spellName) or entry.spellName

	args["label_" .. primary] =
		ns.OptionsAbilityLabel(caption, order, toggle.labelWidth or Kit.LABEL_WIDTH, ns.SpellTooltipLink(entry.ids))
	args["toggle_" .. primary] = {
		type = "toggle",
		name = "",
		desc = desc,
		width = toggle.width or ns.OPTIONS_CONTROL_WIDTH,
		order = order + 0.5,
		get = toggle.get,
		set = toggle.set,
	}
end

--------------------------------------------------------------------------------
-- Row Controls
--------------------------------------------------------------------------------

--[[
    The same settings as the category's menu in the window. Show Missing
    Inventory is left off Self-Buffs, whose spells need no bags. Takes the
    orders `order` to `order` + 0.4.
]]
function ns.AddBuffDutyRowControls(args, row, order)
	local BuffDuty = ns.BuffDuty
	local function Settings()
		return ns.db.global.buffWindow
	end
	args.rowOn = {
		type = "toggle",
		name = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY"],
		desc = L["BUFF_DUTY_MENU_SHOW_IN_BUFF_DUTY_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return BuffDuty.RowOn(row)
		end,
		set = function(_, value)
			BuffDuty.SetRowOn(row, value)
			ns.RefreshBuffDuty()
		end,
	}
	args.spaceRowOn = Kit.Spacer(order + 0.05)
	local values = {}
	for _, value in ipairs(Data.BUFF_DUTY_ROW_WHEN_ORDER) do
		values[value] = L["BUFF_DUTY_ROW_WHEN_" .. value]
	end
	args.rowWhen = Kit.LabelRow(order + 0.1, nil, L["BUFF_DUTY_ROW_WHEN"], {
		type = "select",
		desc = L["BUFF_DUTY_ROW_WHEN_DESCRIPTION"],
		values = values,
		sorting = Data.BUFF_DUTY_ROW_WHEN_ORDER,
		get = function()
			return Settings().rowWhen[row]
		end,
		set = function(_, value)
			Settings().rowWhen[row] = value
			ns.RefreshBuffDuty()
		end,
	})
	args.spaceRowWhen = Kit.Spacer(order + 0.12)
	args.rowShow = Kit.LabelRow(order + 0.15, nil, L["BUFF_DUTY_MENU_SHOW"], {
		type = "select",
		desc = L["BUFF_DUTY_ROW_SHOW_DESCRIPTION"],
		values = ns.BuffDutyRefreshValues(Data.BUFF_DUTY_ROW_SHOW_CHOICES),
		sorting = Data.BUFF_DUTY_ROW_SHOW_CHOICES,
		get = function()
			return Settings().rowShow[row]
		end,
		set = function(_, value)
			Settings().rowShow[row] = value
			ns.RefreshBuffDuty()
		end,
	})
	args.spaceRowShow = Kit.Spacer(order + 0.2)
	args.rowKey = {
		type = "toggle",
		name = L["BUFF_DUTY_ROW_KEY"]:format(L["BUFF_KEY"]),
		desc = L["BUFF_DUTY_ROW_KEY_DESCRIPTION"]:format(L["BUFF_KEY"]),
		width = "full",
		order = order + 0.25,
		get = function()
			return Settings().rowKey[row] ~= false
		end,
		set = function(_, value)
			Settings().rowKey[row] = value
			ns.RefreshBuffDuty()
		end,
	}
	if row ~= "self" then
		args.rowOut = {
			type = "toggle",
			name = L["BUFF_DUTY_MENU_SHOW_MISSING_INVENTORY"],
			desc = L["BUFF_DUTY_ROW_OUT_DESCRIPTION"],
			width = "full",
			order = order + 0.3,
			get = function()
				return Settings().rowOut[row] == true
			end,
			set = function(_, value)
				Settings().rowOut[row] = value
				ns.RefreshBuffDuty()
			end,
		}
	end
	args.spaceRowKey = Kit.Spacer(order + 0.35)
end
