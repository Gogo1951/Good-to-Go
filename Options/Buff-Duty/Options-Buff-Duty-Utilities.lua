local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetSpellTexture = C_Spell.GetSpellTexture

--[[
    The builders only the Buff Duty panels (Options/Buff-Duty/) use: the
    classes this client has, the refresh choices' labels, and a spell's
    caption-and-dropdown row. The ones every buff panel shares are in
    Options/Automated-Appreciation/Options-Automated-Appreciation-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------

--[[
    Every class this client's data names, sorted by token: the classes this
    game version has. Count as Tanks and Buff Duty's Classes list draw from it.
]]
function ns.OptionsClassList()
	local classes = {}
	for _, list in ipairs({
		ns.TRACKED_ABILITIES,
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
    One spell's row inside a class's inline group: its icon and name as the
    caption, and a dropdown beside it. The Buff Duty panels build their lists
    from these, so every dropdown on them shares one x and one width -- the
    caption takes ns.OPTIONS_INLINE_LABEL_WIDTH, and a row outside a box that
    should line up with these takes ns.OPTIONS_ALIGNED_LABEL_WIDTH.

    Hovering the caption shows the spell's own game tooltip (ns.SpellTooltipLink),
    and hovering the dropdown says what it sets (`desc`).

    `select` carries the dropdown's values, sorting, get and set.
]]
function ns.DefineSpellSelectRow(args, entry, order, desc, select)
	local primary = entry.ids[1]
	local texture = GetSpellTexture(primary)
	local caption = texture and ("|T" .. texture .. ":16|t " .. entry.spellName) or entry.spellName

	args["label_" .. primary] =
		ns.OptionsAbilityLabel(caption, order, ns.OPTIONS_INLINE_LABEL_WIDTH, ns.SpellTooltipLink(entry.ids))
	args["select_" .. primary] = {
		type = "select",
		name = "",
		desc = desc,
		values = select.values,
		sorting = select.sorting,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order + 0.5,
		get = select.get,
		set = select.set,
	}
end
