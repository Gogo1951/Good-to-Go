local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- Poisons Macro (Rogue)
--------------------------------------------------------------------------------

-- Its own update cycle: the body doesn't fit the engine's tooltip, conjure and /use shape.

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentPoisonState = nil

function ns.ResetPoisonMacroState()
	currentPoisonState = nil
end

--------------------------------------------------------------------------------
-- Derived Poison Lookups
--------------------------------------------------------------------------------

-- Sorted once at load, highest required level (rank) first.
local POISONS_BY_GROUP = {}
for itemID, row in pairs(ns.POISON_DATA) do
	local group = row[2]
	local list = POISONS_BY_GROUP[group]
	if not list then
		list = {}
		POISONS_BY_GROUP[group] = list
	end
	list[#list + 1] = { itemID, row[1] }
end
for _, list in pairs(POISONS_BY_GROUP) do
	table.sort(list, function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		end
		return a[1] > b[1]
	end)
end

--------------------------------------------------------------------------------
-- Poison Resolution
--------------------------------------------------------------------------------

-- Nil while the rank-1 item's info is cold; the dropdown shows loading text until Kit.WarmItems repaints.
function ns.GetPoisonGroupName(groupID)
	local baseItem = ns.POISON_GROUP_BASE_ITEMS[groupID]
	return baseItem and (C_Item.GetItemInfo(baseItem))
end

-- Poisons aren't soulbound, so a twink can carry ranks above its level; the level gate skips them.
local function FindBestPoison(groupID)
	local list = POISONS_BY_GROUP[groupID]
	if not list then
		return nil
	end
	local playerLevel = ns.cachedPlayerLevel or 1
	for _, entry in ipairs(list) do
		if entry[2] <= playerLevel and C_Item.GetItemCount(entry[1]) > 0 and not ns.IsIgnored(entry[1]) then
			return entry[1]
		end
	end
	return nil
end

local function BestPoisonForHand(hand)
	local settings = ns.db and ns.db.profile
	local key = (hand == "off") and "offHandPoisonGroup" or "mainHandPoisonGroup"
	return FindBestPoison(settings and settings[key])
end

-- On demand, not published: bags change without a rebuild, and none runs while the macro is off.
function ns.GetBestPoisonForHand(hand)
	local id = BestPoisonForHand(hand)
	if not id then
		return nil, nil
	end
	return id, select(2, C_Item.GetItemInfo(id))
end

-- False where this client's data folder has no Poisons skill to know.
local function KnowsPoisons()
	local poisons = ns.POISONS_SPELL_ID
	return poisons ~= nil and (ns.IsSpellKnown(poisons) or ns.IsPlayerSpell(poisons))
end

--------------------------------------------------------------------------------
-- Poisons Macro Body
--------------------------------------------------------------------------------

--[[
    Right-Click is the Main Hand (slot 16); Left-Click and keybinds the Off Hand
    (17), tested as [btn:1]. GtGReplace confirms the replace-poison popup;
    clearing UIErrorsFrame hides the noise from a missing off hand.
]]
local function BuildPoisonsBody(knows, mainID, offID)
	local tooltipID = mainID or offID or ns.MACRO_DEFAULT_ITEM_IDS["Poisons"]
	local lines = { "#showtooltip item:" .. tooltipID }

	if not knows then
		lines[#lines + 1] = '/run GtGTip("noPoisonsSkill")'
		return table.concat(lines, "\n")
	end

	local poisonsName = ns.POISONS_SPELL_ID and C_Spell.GetSpellName(ns.POISONS_SPELL_ID)
	if poisonsName then
		lines[#lines + 1] = "/cast [btn:3] " .. poisonsName
		lines[#lines + 1] = "/stopmacro [btn:3]"
	end

	if not mainID and not offID then
		lines[#lines + 1] = '/run GtGNoItem("Poisons")'
		return table.concat(lines, "\n")
	end

	if not mainID then
		lines[#lines + 1] = '/run GtGTipIf("[btn:2]","noHandPoison")'
		lines[#lines + 1] = "/stopmacro [btn:2]"
	elseif not offID then
		lines[#lines + 1] = '/run GtGTipIf("[btn:1]","noHandPoison")'
		lines[#lines + 1] = "/stopmacro [btn:1]"
	end

	if mainID and offID then
		lines[#lines + 1] = "/use [btn:2] item:" .. mainID .. "; item:" .. offID
		lines[#lines + 1] = "/use [btn:2] 16; 17"
	elseif mainID then
		lines[#lines + 1] = "/use item:" .. mainID
		lines[#lines + 1] = "/use 16"
	else
		lines[#lines + 1] = "/use item:" .. offID
		lines[#lines + 1] = "/use 17"
	end

	lines[#lines + 1] = "/run GtGReplace()"
	lines[#lines + 1] = "/run UIErrorsFrame:Clear()"

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Poisons Update
--------------------------------------------------------------------------------

local function UpdatePoisonsMacro(forced)
	if forced then
		currentPoisonState = nil
	end

	local config = MACRO_CONFIG["Poisons"]
	if not config then
		return
	end

	local knows = KnowsPoisons()
	local mainID = knows and BestPoisonForHand("main") or nil
	local offID = knows and BestPoisonForHand("off") or nil

	-- Lossless like the standard keys: the resolved items already encode the group picks and bags.
	local stateID = (knows and "K" or "NK")
		.. "_"
		.. (mainID and tostring(mainID) or "none")
		.. "_"
		.. (offID and tostring(offID) or "none")

	if currentPoisonState == stateID and not forced then
		return
	end

	local body = BuildPoisonsBody(knows, mainID, offID)

	if not ns.WriteMacroBody(config.macro, body) then
		currentPoisonState = nil
		return
	end

	currentPoisonState = stateID
end

--------------------------------------------------------------------------------
-- Definition
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Poisons",

	customUpdate = function(forced)
		--[[
		    Deleted on any class: it sits in the shared General tab. A flavor with
		    no Poisons skill (Mists) never makes it.
		]]
		if not (ns.IsMacroEnabled("Poisons") and ns.POISONS_SPELL_ID) then
			local config = MACRO_CONFIG["Poisons"]
			if config then
				ns.DeleteMacroByName(config.macro)
				ns.ResetPoisonMacroState()
			end
			return
		end
		if ns.isRogue then
			UpdatePoisonsMacro(forced)
		end
	end,
})
