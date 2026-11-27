local _, ns = ...

--------------------------------------------------------------------------------
-- DruidMacroHelper Integration
--------------------------------------------------------------------------------

--[[
    The return form is a setting, not tracked: a macro can't be rewritten after
    a mid-combat form change. Without DruidMacroHelper loaded the standard body
    is written; the "DMH:" key prefix makes loading or dropping it rewrite.
]]

local DRUID_MACRO_HELPER_FOLDER = "DruidMacroHelper"

local function ShouldUseDruidMacroHelper(typeName)
	if not ns.isDruid then
		return false
	end
	if not ns.DRUID_MACRO_HELPER_TYPES[typeName] then
		return false
	end
	if not C_AddOns.IsAddOnLoaded(DRUID_MACRO_HELPER_FOLDER) then
		return false
	end
	local settings = ns.db and ns.db.profile
	return settings and settings.enableDruidMacroHelper and true or false
end

-- Best first. The client names these spells whether learned or not, so the pick tests what is known.
local RETURN_FORM_SPELL_IDS = {
	bear = { ns.DRUID_DIRE_BEAR_FORM_SPELL_ID, ns.DRUID_BEAR_FORM_SPELL_ID },
	cat = { ns.DRUID_CAT_FORM_SPELL_ID },
}

local function GetDruidReturnForm()
	local settings = ns.db and ns.db.profile
	local key = settings and settings.druidReturnForm
	if key ~= "cat" then
		key = "bear"
	end
	for _, spellID in ipairs(RETURN_FORM_SPELL_IDS[key]) do
		if ns.KnowsAny({ { spellID } }) then
			return key, spellID, C_Spell.GetSpellName(spellID)
		end
	end
	return key, nil, nil
end

local function BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, outOfCombatID, outOfCombatStealth)
	local lines = {
		"#showtooltip item:" .. useIDs[1],
		"/run GtGFire(" .. useIDs[1] .. ")",
	}
	-- Above the guards, so an out-of-combat press never starts a powershift.
	if outOfCombatID then
		lines[1] = ns.OutOfCombatTooltipLine(useIDs[1], outOfCombatID)
		lines[2] = "/run GtGFire(" .. useIDs[1] .. "," .. outOfCombatID .. ")"
		lines[3] = "/use [nocombat] item:" .. outOfCombatID
		if outOfCombatStealth then
			lines[#lines + 1] = "/cast [nocombat,nostealth] " .. outOfCombatStealth
		end
		lines[#lines + 1] = "/stopmacro [nocombat]"
	end
	for _, guard in ipairs(ns.DRUID_MACRO_HELPER_GUARDS[typeName]) do
		lines[#lines + 1] = guard
	end
	local firstUse = #lines + 1
	for _, id in ipairs(useIDs) do
		lines[#lines + 1] = "/use item:" .. id
	end
	-- Inside the powershift, before the return /cast, so one shift fires a potion and a stone.
	if stackIDs then
		for _, id in ipairs(stackIDs) do
			lines[#lines + 1] = "/use item:" .. id
		end
	end
	lines[#lines + 1] = "/cast !" .. formName
	lines[#lines + 1] = "/dmh end"
	local body = table.concat(lines, "\n") .. "\n"

	-- Overflow would chop the trailing /dmh end and leave the guards dangling; rank 1 is never dropped.
	while #body > ns.MACRO_BODY_MAX_LENGTH and #lines > firstUse + 2 do
		table.remove(lines, #lines - 2)
		body = table.concat(lines, "\n") .. "\n"
	end
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		return nil
	end
	return body
end

--------------------------------------------------------------------------------
-- Public Hook
--------------------------------------------------------------------------------

--[[
    Nil means the standard body: also when no DMH body fits, or the return form
    isn't learned. The key carries the form's spell ID, so learning Dire Bear
    Form rewrites a body that returns to Bear Form.
]]
function ns.BuildDruidMacroOverride(typeName, itemID, rankedIDs, stackIDs, outOfCombatID, outOfCombatStealth)
	if not itemID then
		return nil
	end
	if not ShouldUseDruidMacroHelper(typeName) then
		return nil
	end

	local formKey, formSpellID, formName = GetDruidReturnForm()
	if not formName then
		return nil
	end

	local useIDs = rankedIDs
	if not useIDs or #useIDs == 0 then
		useIDs = { itemID }
	end

	local body = BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, outOfCombatID, outOfCombatStealth)
	if not body and outOfCombatStealth then
		outOfCombatStealth = nil
		body = BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, outOfCombatID, nil)
	end
	if not body and outOfCombatID then
		outOfCombatID = nil
		body = BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, nil, nil)
	end
	if not body then
		return nil
	end
	local stateID = "DMH:" .. formKey .. ":" .. formSpellID .. ":" .. table.concat(useIDs, ",")
	if stackIDs then
		stateID = stateID .. "+HS:" .. table.concat(stackIDs, ",")
	end
	if outOfCombatID then
		stateID = stateID .. "+OOC:" .. outOfCombatID .. (outOfCombatStealth and ":S" or "")
	end
	return body, stateID
end
