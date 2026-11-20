local _, ns = ...

--[[
	What the action bars hold, so the page can mark which of its macros the player has placed.
]]

local NO_INDEXES = {}

local MAX_ACTION_SLOTS = 180 -- Classic has 120; empty or missing slots return nil

--[[
	The name of the macro in an action slot, or nil for a slot holding none. For a macro that shows a spell,
	GetActionInfo gives the spell's id (subtype "spell") rather than the macro's index, so the name is the one
	GetActionText gives.
]]
function ns.ActionMacroName(slot)
	local actionType, id, subType = GetActionInfo(slot)
	if actionType ~= "macro" then
		return nil
	end
	return GetActionText(slot) or (subType ~= "spell" and GetMacroInfo(id)) or nil
end

-- The tag a named WoW macro's body carries, or nil, so a macro the player renamed is still found.
function ns.MacroNameTag(name)
	return ns.BodyTag(GetMacroBody(name))
end

--[[
	The tag the macro in an action slot carries, or nil. Read by the macro's index where the slot gives one:
	names are cut to 16 bytes, so two macros can share one ("-Greater Blessin"), and a lookup by name finds
	only the first.
]]
function ns.ActionMacroTag(slot)
	local actionType, id, subType = GetActionInfo(slot)
	if actionType ~= "macro" then
		return nil
	end
	if subType ~= "spell" and id then
		return ns.BodyTag(GetMacroBody(id))
	end
	local name = ns.ActionMacroName(slot)
	return name and ns.MacroNameTag(name)
end

-- The macro names on the action bars, by slot; a slot holding no macro has none.
function ns.BarMacroNames()
	local names = {}
	for slot = 1, MAX_ACTION_SLOTS do
		names[slot] = ns.ActionMacroName(slot)
	end
	return names
end

--[[
	What is on the action bars: {macros = {[macro name] = true}, spells = {[spell name] = true},
	tags = {[tag] = true}}: a tagged macro by its tag only (see ns.ActionMacroTag), an untagged one by its name
	(see ns.ActionMacroName).
]]
function ns.ScanActionBars()
	local bars = { macros = {}, spells = {}, tags = {} }
	for slot = 1, MAX_ACTION_SLOTS do
		local actionType, id = GetActionInfo(slot)
		if actionType == "macro" then
			-- a tagged macro counts only by its tag: its name may be shared by another cut to the same 16 bytes
			local tag = ns.ActionMacroTag(slot)
			if tag then
				bars.tags[tag] = true
			else
				local name = ns.ActionMacroName(slot)
				if name then
					bars.macros[name] = true
				end
			end
		elseif actionType == "spell" and id then
			-- by name, not ID: the bar can hold any rank of a spell, and every rank has its own ID
			local name = C_Spell.GetSpellName(id)
			if name then
				bars.spells[name] = true
			end
		end
	end
	return bars
end

--[[
	The action slots that hold the WoW macro at index. A tagged macro is matched by its tag, as
	ns.ScanActionBars matches; an untagged one by the name GetActionText gives, or by the index where the slot
	gives one rather than the spell's.
]]
function ns.MacroBarSlots(index)
	local name, _, body = GetMacroInfo(index)
	local tag, slots = ns.BodyTag(body), {}
	for slot = 1, MAX_ACTION_SLOTS do
		local actionType, id, subType = GetActionInfo(slot)
		if actionType == "macro" then
			local matches
			if tag then
				matches = ns.ActionMacroTag(slot) == tag
			else
				matches = GetActionText(slot) == name or (subType ~= "spell" and id == index)
			end
			if matches then
				slots[#slots + 1] = slot
			end
		end
	end
	return slots
end

-- How many action slots hold the WoW macro at index.
function ns.MacroBarCount(index)
	return #ns.MacroBarSlots(index)
end

--[[
	Whether a page macro is on the action bars, scanned by ns.ScanActionBars. A spell macro with no
	options on also counts when its plain spell is on a bar, and with ns.CountsSpellsOnBars() any spell
	macro does. A Duplicate or a rank counts only as its own macro. The Shoot macro's plain spell
	is any of the ranged attacks it stands for.
]]
function ns.IsOnActionBars(macro, bars)
	if bars.macros[ns.WowMacroName(macro)] or bars.tags[ns.MacroTag(macro)] then
		return true
	end
	-- a consumable is placed only as its macro: Feed Pet the spell on a bar is not the Feed Pet macro
	if macro.consumable then
		return false
	end
	local spell = bars.spells[macro.name] and macro.name
	for name in pairs(macro.rangedAttacks or NO_INDEXES) do
		spell = spell or bars.spells[name] and name
	end
	if macro.copy or macro.rank or not spell then
		return false
	end
	return ns.CountsSpellsOnBars() or macro.body == ns.TaggedBody(macro, ns.BareBody(spell))
end
