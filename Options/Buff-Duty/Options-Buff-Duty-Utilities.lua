local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

local GetSpellTexture = C_Spell.GetSpellTexture

--[[
    The builders only the Buff Duty panels (Options/Buff-Duty/) use: the
    classes this client has, the refresh choices' labels, a spell's
    caption-and-dropdown row, and the ability labels, tooltip links and sorted
    entries those rows are built from.
]]

--------------------------------------------------------------------------------
-- Ability Rows
--------------------------------------------------------------------------------

--[[
    A row label naming an ability, which shows the game's own tooltip for it
    on hover, the same one an action bar shows. `hyperlink` returns
    "spell:<id>" or "item:<id>". A plain Label takes no mouse, so this one is
    an InteractiveLabel, which AceConfigDialog gives the same hover handler as
    any control, and that handler shows `tooltipHyperlink` when there is one.
]]
function ns.OptionsAbilityLabel(text, order, width, hyperlink)
	local label = Kit.Label(text, order, width)
	label.dialogControl = "InteractiveLabel"
	label.tooltipHyperlink = hyperlink
	return label
end

--[[
    The spell an ability's tooltip quotes: the HIGHEST id in its rank group
    that the client describes, so it reads the rank you actually cast, not rank
    1. Ids are sorted rather than trusted in data order -- rows are not
    reliably rank-ordered (Combustion is { 29977, 11129 }, Vanish
    { 1856, 1857, 27617, 26889, 44290 }). Classic holds tooltip data only for
    spells the character has known, and these panels list every class, so each
    id is requested once here and the pick is made again at every hover, when
    the text has had time to land.
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

-- The lowercased spell name an entry sorts by.
local function EntrySortKey(entry)
	return (entry.spellName or ""):lower()
end

-- A copy of `entries` ordered alphabetically by spell name, with the watched id breaking ties for a stable result.
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

--[[
    Every class this client's data names, sorted by token: the classes this
    game version has. Count as Tanks and Buff Duty's Classes list draw from it.
    CLASS_SPELL_LISTS is keyed by every class the flavor has.
]]
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

--[[
    The Off / When Missing / Under labels for a list of choices the Self-Buffs
    and Weapon Buffs panels share, "Under 5 Minutes" built from the client's
    own duration string.
]]
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

--[[
    One spell's row: its icon and name as the caption, and a dropdown beside
    it. The Buff Duty panels build their lists from these, so every dropdown on
    a page shares one x and one width -- the page's label and control columns
    (Kit.LABEL_WIDTH, Kit.CONTROL_WIDTH), or a tree pane's narrower ones.

    Hovering the caption shows the spell's own game tooltip (ns.SpellTooltipLink),
    and hovering the dropdown says what it sets (`desc`).

    `select` carries the dropdown's values, sorting, get and set, and
    optionally labelWidth and width, for a row in a tree's narrower pane.
]]
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
