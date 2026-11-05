local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
	The words a macro's tile shows for its options (Features/Spellbook/Macro-Button.lua draws the tile): the
	note under its name (ns.MacroOptionSubText), the tooltip's Options On line (ns.MacroOptionsOnLine) and a
	learned spell's "Learn Rank 5" (ns.LearnableRankNote).
]]

--[[
	The options a macro's note and tooltip can name, most telling first, as { key, note key, full label key }:
	the note names up to MAX_NOTES that are on, or counts them when more are; the tooltip lists them all by their
	full labels. A row without keys builds its text from the macro.
]]
local OPTION_SUBTEXTS = {
	{ "conditionals" },
	{ "castSequence" },
	{ "pet", "SUBTEXT_PET", "MENU_CAST_IF_SUMMONED" },
	{ "cursor", "SUBTEXT_CURSOR", "MENU_CAST_AT_CURSOR" },
	{ "targetPriority", "SUBTEXT_TARGET_PRIORITY", "MENU_GROUP_TARGET" },
	{ "stance", "SUBTEXT_STANCE", "MENU_SWITCH_TO" },
	{ "useItems", "SUBTEXT_USE_ITEMS" },
	{ "petAttack", "SUBTEXT_PET_ATTACK", "MENU_START_PET_ATTACK" },
	{ "targetRank", "SUBTEXT_DYNAMIC_RANK", "MENU_DYNAMIC_RANK" },
	{ "fixedRank" },
	{ "targetEnemy", "SUBTEXT_TARGET_ENEMY", "MENU_TARGET_NEAREST_ENEMY" },
	{ "targetFriend", "SUBTEXT_TARGET_FRIEND", "MENU_TARGET_NEAREST_FRIEND" },
	{ "groupVersion", "SUBTEXT_GROUPED_SPELLS", "MENU_RIGHT_CLICK_FOR" },
	{ "groupedSpells", "SUBTEXT_GROUPED_SPELLS" },
	{ "oncePerCombat", "SUBTEXT_ONCE_PER_COMBAT", "MENU_ONCE_PER_COMBAT" },
	{ "oncePerTarget", "SUBTEXT_ONCE_PER_TARGET", "MENU_ONCE_PER_TARGET" },
	{ "combatOnly", "SUBTEXT_COMBAT_ONLY", "MENU_IN_COMBAT" },
	{ "noCombat", "SUBTEXT_NO_COMBAT", "SUBTEXT_NO_COMBAT" },
	{ "cancelForm", "SUBTEXT_LEAVE_FORM", "MENU_LEAVE_FORM_BEFORE" },
	{ "noToggle", "SUBTEXT_NO_TOGGLE", "MENU_NEVER_TURN_OFF" },
	{ "autoShot" },
	{ "startAttack", "SUBTEXT_START_ATTACK", "MENU_START_AUTO_ATTACK" },
	{ "stopAttack", "SUBTEXT_STOP_ATTACK", "MENU_STOP_ATTACK" },
	{ "stopCast", "SUBTEXT_STOP_CASTING", "MENU_STOP_CASTING" },
	{ "stopIfChanneling", "SUBTEXT_STOP_IF_CHANNELING", "MENU_STOP_IF_CHANNELING" },
	{ "stopIfStealthed", "SUBTEXT_STOP_IF_STEALTHED", "MENU_STOP_IF_STEALTHED" },
	{ "hideErrors", "SUBTEXT_HIDE_ERRORS", "MENU_HIDE_ERRORS" },
	{ "muteErrors", "SUBTEXT_MUTE_ERRORS", "MENU_MUTE_ERRORS" },
}

-- Calls fn(entry) for each OPTION_SUBTEXTS row whose option is on for the macro, in order.
local function ForEachOnOption(macro, fn)
	for _, entry in ipairs(OPTION_SUBTEXTS) do
		local key = entry[1]
		local on
		if key == "useItems" then
			on = ns.UseItemSlots(macro)[1] ~= nil
		elseif key == "fixedRank" then
			on = ns.FixedRank(macro) ~= nil
		elseif key == "groupedSpells" then
			on = ns.IsGrouped(macro)
		elseif key == "targetPriority" then
			on = ns.HasTargetPriority(macro)
		elseif key == "conditionals" then
			on = ns.ConditionalCount(macro) > 0
		elseif key == "castSequence" then
			on = ns.IsCastSequenceOn(macro)
		else
			on = ns.IsOptionOn(macro, key)
		end
		if on then
			fn(entry)
		end
	end
end

-- The autoShot note: Auto Shot's own name from the client, or "Wand" rather than the wand's "Shoot".
local function AutoShotSubText()
	if ns.AutoShotLabelKey() == "MENU_START_WAND" then
		return L["SUBTEXT_WAND"]
	end
	return ns.AutoShotName()
end

-- The target priority's note: the first unit it tries other than the target ("Mouseover", "Self").
local function TargetPrioritySubText(macro)
	for _, unit in ipairs(ns.TargetPriority(macro)) do
		for _, row in ipairs(ns.TARGET_UNITS) do
			if row[1] == unit and unit ~= "target" then
				return L[row[2]]
			end
		end
	end
	return L["SUBTEXT_TARGET_PRIORITY"]
end

-- The Conditionals' note and full label: "1 Conditional", "4 Conditionals".
local function ConditionalsSubText(macro)
	local count = ns.ConditionalCount(macro)
	return count == 1 and L["SUBTEXT_CONDITIONALS_ONE"] or L["SUBTEXT_CONDITIONALS"]:format(count)
end

-- MAX_NOTES names fit on a tile's note line ("Max Rank, Grouped, Hide Errors"); more are counted instead.
local MAX_NOTES = 3

--[[
	A spell macro's note: lead (a spell's "Max Rank"), if given, and the options that are on by
	name ("Dynamic Rank, Grouped"), or "N Options" counting them when there are more than MAX_NOTES names, or
	nil when there are none. Options with the same note (Right-Click for and the Grouped Spells ticked, both
	"Grouped") count as one.
]]
local function OptionSubText(macro, lead)
	local notes, count, seen = { lead }, 0, {}
	ForEachOnOption(macro, function(entry)
		local note
		-- a fixed rank's note is the rank's own text ("Rank 3")
		if entry[1] == "fixedRank" then
			note = ns.FixedRank(macro)
		elseif entry[1] == "autoShot" then
			note = AutoShotSubText()
		elseif entry[1] == "targetPriority" then
			note = TargetPrioritySubText(macro)
		elseif entry[1] == "conditionals" then
			note = ConditionalsSubText(macro)
		elseif entry[1] == "castSequence" then
			note = L["SUBTEXT_CAST_SEQUENCE"]:format(ns.CastSequenceStepCount(macro) + 1)
		else
			note = L[entry[2]]
		end
		if not seen[note] then
			seen[note] = true
			count = count + 1
			notes[#notes + 1] = note
		end
	end)
	if #notes > MAX_NOTES then
		return L["SUBTEXT_OPTIONS_COUNT"]:format(count)
	end
	return notes[1] and table.concat(notes, L["LIST_SEPARATOR"]) or nil
end

-- An option's full label, as the tooltip's Options On line shows it.
local function OptionLabel(macro, entry)
	local key = entry[1]
	if key == "useItems" then
		local slots = {}
		for i, slot in ipairs(ns.UseItemSlots(macro)) do
			slots[i] = ns.SlotLabel(slot)
		end
		return table.concat(slots, L["LIST_SEPARATOR"])
	elseif key == "fixedRank" then
		return ns.FixedRank(macro)
	elseif key == "autoShot" then
		return L[ns.AutoShotLabelKey() or "MENU_START_AUTO_SHOT"]
	elseif key == "pet" then
		return L[entry[3]]:format(macro.petAbility)
	elseif key == "stance" then
		return L[entry[3]]:format(macro.stances[1])
	elseif key == "groupVersion" then
		return L[entry[3]]:format(ns.RightClickSpell(macro))
	elseif key == "groupedSpells" then
		return table.concat(ns.GroupedSpells(macro), L["LIST_SEPARATOR"])
	elseif key == "targetPriority" then
		local labels = {}
		for i, unit in ipairs(ns.TargetPriority(macro)) do
			for _, row in ipairs(ns.TARGET_UNITS) do
				if row[1] == unit then
					labels[i] = L[row[2]]
				end
			end
		end
		return L["NAME_WITH_DETAIL_FORMAT"]:format(L[entry[3]], table.concat(labels, L["LIST_SEPARATOR"]))
	elseif key == "conditionals" then
		return L["NAME_WITH_DETAIL_FORMAT"]:format(
			ConditionalsSubText(macro),
			table.concat(ns.ConditionalSummaries(macro), L["LIST_SEPARATOR"])
		)
	elseif key == "castSequence" then
		return L["NAME_WITH_DETAIL_FORMAT"]:format(L["MENU_GROUP_CAST_SEQUENCE"], ns.CastSequenceSummary(macro))
	end
	return L[entry[3]]
end

-- "Options On: Cast at Cursor, Stop Casting", every option that is on by its menu label, or nil for none.
local function OptionsOnLine(macro)
	local labels = {}
	ForEachOnOption(macro, function(entry)
		labels[#labels + 1] = OptionLabel(macro, entry)
	end)
	if #labels == 0 then
		return nil
	end
	return GetColor("TITLE")
		.. L["TOOLTIP_OPTIONS_ON"]:format(GetColor("TEXT") .. table.concat(labels, L["LIST_SEPARATOR"]) .. "|r")
		.. "|r"
end

--[[
	"Learn Rank 5" in the red of a rank to learn (ns.SPELL_RANK_COLORS.LEARNABLE), for a learned spell with a higher
	rank at the player's level that isn't learned yet, so "Max Rank" never says a spell is done while it's a rank
	behind; nil when it's caught up. unknownRanks are the trainer's ranks of a learned spell not learned yet
	(Spell-Ranks.lua), highest first, so the first one reached is the best the character could cast.
]]
function ns.LearnableRankNote(macro)
	local level = UnitLevel("player")
	for _, rank in ipairs(macro.unknownRanks or {}) do
		if rank.level <= level then
			return GetColor(ns.SPELL_RANK_COLORS.LEARNABLE) .. L["SUBTEXT_LEARN_RANK"]:format(rank.text) .. "|r"
		end
	end
	return nil
end

ns.MacroOptionSubText = OptionSubText
ns.MacroOptionsOnLine = OptionsOnLine
