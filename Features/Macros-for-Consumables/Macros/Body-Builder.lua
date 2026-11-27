local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Use Lines
--------------------------------------------------------------------------------

--[[
    Lets the zone-error handler tie an error to the item pressed. A global
    helper, not inline /run code: every body carries this line, so its bytes
    count against the 255-byte ceiling everywhere.
]]
local function StateWriteLine(itemID, outOfCombatID)
	if outOfCombatID then
		return "/run GtGFire(" .. itemID .. "," .. outOfCombatID .. ")\n"
	end
	return "/run GtGFire(" .. itemID .. ")\n"
end

--[[
    One /stopmacro costs fewer bytes than a [combat] guard on each of up to six
    /use lines, and leaves those lines and their trim unchanged.
]]
function ns.OutOfCombatBlock(outOfCombatID, stealthName, corpseName)
	local block = ""
	if corpseName then
		block = "/cast [nocombat,dead] " .. corpseName .. "\n"
	end
	block = block .. "/use [nocombat] item:" .. outOfCombatID .. "\n"
	if stealthName then
		block = block .. "/cast [nocombat,nostealth] " .. stealthName .. "\n"
	end
	return block .. "/stopmacro [nocombat]\n"
end

-- No /stopmacro: a press that cannot cast it falls through to eating or drinking.
local function CorpseBlock(corpseName)
	return "/cast [dead] " .. corpseName .. "\n"
end

local function CombatBlock(combatName)
	return "/cast [combat] " .. combatName .. "\n/stopmacro [combat]\n"
end

local function LeadBlock(leadName)
	return "/cast [nocombat] " .. leadName .. "\n/stopmacro [nocombat]\n"
end

-- With nothing in bags, a press on a corpse already cast the corpse spell, so skip the no-item message.
local function NoItemStop(corpseName)
	return corpseName and "/stopmacro [dead]\n" or ""
end

function ns.OutOfCombatTooltipLine(itemID, outOfCombatID)
	return "#showtooltip [combat] item:" .. itemID .. "; item:" .. outOfCombatID
end

--[[
    Fallback lines for combat, where the macro can't be rewritten: safe only
    because each multi-use type's items share one cooldown, so a press uses
    exactly one. The blocked lines raise a harmless "not ready yet" error.
]]
local function BuildUseBlock(useIDs)
	local lines = {}
	for _, id in ipairs(useIDs) do
		lines[#lines + 1] = "/use item:" .. id
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Conjure Block Builder
--------------------------------------------------------------------------------

-- An unlearned spell's click prints a "you'll get this later" tip instead of casting.
local function BuildConjureBlock(info)
	if not info then
		return ""
	end

	local rightName, middleName = info.rightName, info.middleName
	local rightMiss, middleMiss = info.rightMiss, info.middleMiss

	if not (rightName or middleName or rightMiss or middleMiss) then
		return ""
	end

	local lines = {}

	-- Miss tips first, so their /stopmacro halts before the /cast line.
	if rightMiss then
		lines[#lines + 1] = '/run GtGTipIf("[btn:2]","' .. rightMiss .. '")'
	end
	if middleMiss then
		lines[#lines + 1] = '/run GtGTipIf("[btn:3]","' .. middleMiss .. '")'
	end

	local missStop = ""
	if rightMiss then
		missStop = missStop .. "[btn:2]"
	end
	if middleMiss then
		missStop = missStop .. "[btn:3]"
	end
	if missStop ~= "" then
		lines[#lines + 1] = "/stopmacro " .. missStop
	end

	if rightName or middleName then
		local castLine = ""
		local stopConditions = ""
		if middleName then
			castLine = castLine .. "[btn:3] " .. middleName .. "; "
			stopConditions = stopConditions .. "[btn:3]"
		end
		if rightName then
			castLine = castLine .. "[btn:2] " .. rightName .. "; "
			stopConditions = stopConditions .. "[btn:2]"
		end
		lines[#lines + 1] = "/cast " .. castLine
		lines[#lines + 1] = "/stopmacro " .. stopConditions
	end

	return table.concat(lines, "\n") .. "\n"
end

--------------------------------------------------------------------------------
-- Standard Body Builder
--------------------------------------------------------------------------------

--[[
    The one body layout every standard macro shares: tooltip, conjure clicks,
    corpse/combat/lead casts, GtGFire, the out-of-combat block, the /use lines,
    stacked lines, then the appended line. Over the byte limit it rebuilds with
    one extra dropped at a time, conveniences before consumables.
]]
function ns.BuildStandardBody(
	definition,
	itemID,
	useIDs,
	stackIDs,
	conjureInfo,
	appendText,
	outOfCombatID,
	outOfCombatStealth,
	corpseCast,
	outOfCombatCorpse,
	leadCast,
	combatCast
)
	local tooltipLine, actionBlock

	-- Everything above the /use lines; the macro-length trim rebuilds only what follows it.
	local actionHead = ""
	if itemID then
		actionHead = StateWriteLine(itemID, outOfCombatID)
	elseif outOfCombatID then
		actionHead = StateWriteLine(outOfCombatID)
	end
	if outOfCombatID then
		actionHead = actionHead .. ns.OutOfCombatBlock(outOfCombatID, outOfCombatStealth, outOfCombatCorpse)
	end

	if itemID then
		tooltipLine = "#showtooltip item:" .. itemID .. "\n"

		local customLine = definition.buildUseLine and definition.buildUseLine(itemID) or nil
		if customLine then
			actionBlock = actionHead .. customLine
		elseif useIDs then
			actionBlock = actionHead .. BuildUseBlock(useIDs)
		else
			actionBlock = actionHead .. "/use item:" .. itemID
		end

		if stackIDs then
			actionBlock = actionBlock .. "\n" .. BuildUseBlock(stackIDs)
		end
	elseif conjureInfo and conjureInfo.noItemMiss then
		tooltipLine = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName] .. "\n"
		actionBlock = actionHead .. NoItemStop(corpseCast) .. '/run GtGTip("' .. conjureInfo.noItemMiss .. '")'
	else
		tooltipLine = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName] .. "\n"
		-- The ",1" tells a class that knows the conjure to Right-Click for more.
		local canMake = conjureInfo and conjureInfo.rightName and ",1" or ""
		actionBlock = actionHead
			.. NoItemStop(corpseCast)
			.. '/run GtGNoItem("'
			.. definition.typeName
			.. '"'
			.. canMake
			.. ")"
	end

	if outOfCombatID then
		tooltipLine = ns.OutOfCombatTooltipLine(itemID or ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName], outOfCombatID)
			.. "\n"
	elseif leadCast then
		tooltipLine = "#showtooltip [nocombat] "
			.. leadCast
			.. "; item:"
			.. (itemID or ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName])
			.. "\n"
	elseif combatCast then
		tooltipLine = "#showtooltip [combat] "
			.. combatCast
			.. "; item:"
			.. (itemID or ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName])
			.. "\n"
	elseif corpseCast then
		tooltipLine = "#showtooltip [dead] "
			.. corpseCast
			.. "; item:"
			.. (itemID or ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName])
			.. "\n"
	end

	local conjureBlock = ""
	if conjureInfo then
		conjureBlock = BuildConjureBlock(conjureInfo)
	end
	if corpseCast then
		conjureBlock = conjureBlock .. CorpseBlock(corpseCast)
	end
	if combatCast then
		conjureBlock = conjureBlock .. CombatBlock(combatCast)
	end
	if leadCast then
		conjureBlock = conjureBlock .. LeadBlock(leadCast)
	end

	local appendedBlock = appendText or ""

	local body = tooltipLine .. conjureBlock .. actionBlock .. appendedBlock

	-- Cannibalize goes first: a convenience, not a consumable.
	if #body > ns.MACRO_BODY_MAX_LENGTH and (corpseCast or outOfCombatCorpse) then
		return ns.BuildStandardBody(
			definition,
			itemID,
			useIDs,
			stackIDs,
			conjureInfo,
			appendText,
			outOfCombatID,
			outOfCombatStealth,
			nil,
			nil,
			leadCast,
			combatCast
		)
	end

	--[[
	    Overflow cuts off the last /use line, easily reached in multibyte locales
	    (ruRU spell names). Stacked healthstones go first, then fallbacks from
	    the bottom; rank 1 is never dropped.
	]]
	if useIDs then
		local keepUse = #useIDs
		local keepStack = stackIDs and #stackIDs or 0
		while #body > ns.MACRO_BODY_MAX_LENGTH and (keepStack > 0 or keepUse > 1) do
			if keepStack > 0 then
				keepStack = keepStack - 1
			else
				keepUse = keepUse - 1
			end
			local trimmed = {}
			for rank = 1, keepUse do
				trimmed[rank] = useIDs[rank]
			end
			actionBlock = actionHead .. BuildUseBlock(trimmed)
			if keepStack > 0 then
				local stackTrimmed = {}
				for rank = 1, keepStack do
					stackTrimmed[rank] = stackIDs[rank]
				end
				actionBlock = actionBlock .. "\n" .. BuildUseBlock(stackTrimmed)
			end
			body = tooltipLine .. conjureBlock .. actionBlock .. appendedBlock
		end
	end

	if #body > ns.MACRO_BODY_MAX_LENGTH and outOfCombatStealth then
		return ns.BuildStandardBody(
			definition,
			itemID,
			useIDs,
			stackIDs,
			conjureInfo,
			appendText,
			outOfCombatID,
			nil,
			nil,
			nil,
			leadCast,
			combatCast
		)
	end
	if #body > ns.MACRO_BODY_MAX_LENGTH and outOfCombatID then
		return ns.BuildStandardBody(
			definition,
			itemID,
			useIDs,
			stackIDs,
			conjureInfo,
			appendText,
			nil,
			nil,
			nil,
			nil,
			leadCast,
			combatCast
		)
	end

	if #body > ns.MACRO_BODY_MAX_LENGTH and appendText and appendText ~= "" then
		return ns.BuildStandardBody(
			definition,
			itemID,
			useIDs,
			stackIDs,
			conjureInfo,
			nil,
			nil,
			nil,
			nil,
			nil,
			leadCast,
			combatCast
		)
	end
	if #body > ns.MACRO_BODY_MAX_LENGTH and (combatCast or leadCast) then
		return ns.BuildStandardBody(definition, itemID, useIDs, stackIDs, conjureInfo, nil, nil, nil)
	end
	-- Nothing left to shed: write it anyway, and tell the player once.
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		local macroName = ns.MACRO_CONFIG[definition.typeName].macro
		ns.WarnOnce(
			L["CHAT_CONSUMABLE_MACRO_TOO_LONG"]:format(macroName, #body, ns.MACRO_BODY_MAX_LENGTH),
			"consumableTooLong:" .. macroName
		)
	end

	return body
end

--------------------------------------------------------------------------------
-- State Key Builder
--------------------------------------------------------------------------------

--[[
    Every input that affects the body MUST appear in the key, or macros go stale.
      ITEMIDS(+HS:stackIDs)?(_C(_M:mid)?(_R:rid)?(_MR:key)?(_MM:key)?(_NI:key)?)?(_EX:mode)?(_SM|_SE)?(_OOC:id(:S)?(:CN)?)?(_CN)?(_RR)?(_RC)?
    ITEMIDS is the whole ranked list for multi-use types, so any fallback change
    rewrites. +HS stacked healthstones; _EX Explosive's click layout; _SM/_SE
    the Shadowmeld/Stealth Eating append; _OOC the potion's out-of-combat food
    or water (:S stealth, :CN Cannibalize); _CN own Cannibalize; _RR Bandage's
    lead cast; _RC Food's combat cast. Overrides use their own prefix ("DMH:"),
    so a switch between them always rewrites.
]]

function ns.BuildStateKey(
	definition,
	itemID,
	useIDs,
	stackIDs,
	conjureInfo,
	appendFlag,
	outOfCombatID,
	outOfCombatStealth,
	corpseCast,
	outOfCombatCorpse,
	leadCast,
	combatCast
)
	local itemKey = itemID and tostring(itemID) or "none"
	if useIDs then
		itemKey = table.concat(useIDs, ",")
	end
	if stackIDs then
		itemKey = itemKey .. "+HS:" .. table.concat(stackIDs, ",")
	end
	local stateParts = { itemKey }
	if
		conjureInfo
		and (
			conjureInfo.rightName
			or conjureInfo.middleName
			or conjureInfo.rightMiss
			or conjureInfo.middleMiss
			or conjureInfo.noItemMiss
		)
	then
		stateParts[#stateParts + 1] = "C"
		if conjureInfo.middleName then
			stateParts[#stateParts + 1] = "M:" .. tostring(conjureInfo.middleID)
		end
		if conjureInfo.rightName then
			stateParts[#stateParts + 1] = "R:" .. tostring(conjureInfo.rightID)
		end
		if conjureInfo.rightMiss then
			stateParts[#stateParts + 1] = "MR:" .. conjureInfo.rightMiss
		end
		if conjureInfo.middleMiss then
			stateParts[#stateParts + 1] = "MM:" .. conjureInfo.middleMiss
		end
		if conjureInfo.noItemMiss then
			stateParts[#stateParts + 1] = "NI:" .. conjureInfo.noItemMiss
		end
	end
	if definition.stateExtras then
		definition.stateExtras(stateParts, itemID)
	end
	if appendFlag then
		stateParts[#stateParts + 1] = appendFlag
	end
	if outOfCombatID then
		stateParts[#stateParts + 1] = "OOC:"
			.. outOfCombatID
			.. (outOfCombatStealth and ":S" or "")
			.. (outOfCombatCorpse and ":CN" or "")
	end
	if corpseCast then
		stateParts[#stateParts + 1] = "CN"
	end
	if leadCast then
		stateParts[#stateParts + 1] = "RR"
	end
	if combatCast then
		stateParts[#stateParts + 1] = "RC"
	end
	return table.concat(stateParts, "_")
end
