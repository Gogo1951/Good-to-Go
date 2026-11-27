local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentMacroState = {}

--------------------------------------------------------------------------------
-- Macro Enablement
--------------------------------------------------------------------------------

-- Account-wide like the General-tab macros, so a character switch only rewrites bodies.
function ns.IsMacroEnabled(typeName)
	local enabled = ns.db and ns.db.global.enabledMacros
	if not enabled then
		return true
	end
	return enabled[typeName] ~= false
end

local function DeleteMacroIfExists(macroName, typeName)
	ns.DeleteMacroByName(macroName)
	currentMacroState[typeName] = nil
end

--------------------------------------------------------------------------------
-- Macro Writing
--------------------------------------------------------------------------------

-- The state key is recorded only when the write landed, or a full tab would block every retry.
local function WriteMacro(macroName, body, stateKey, typeName)
	if ns.WriteMacroBody(macroName, body) then
		currentMacroState[typeName] = stateKey
	else
		currentMacroState[typeName] = nil
	end
end

--------------------------------------------------------------------------------
-- Macro Update Loop
--------------------------------------------------------------------------------

--[[
    MacroFrame saves its edit box back on close, reverting a write the state
    keys already recorded, so its OnHide drops every key. Tried on EVERY pass
    (the frame is load-on-demand): armed only from the shown-frame branch, a
    short visit that requests no update would never arm it. A first open and
    close before any update is the one gap.
]]
local macroUIHooked = false

local function EnsureMacroUIHook()
	if macroUIHooked or not MacroFrame then
		return
	end
	macroUIHooked = true
	MacroFrame:HookScript("OnHide", function()
		ns.ResetMacroState()
		ns.RequestUpdate()
	end)
end

function ns.UpdateMacros(forced)
	EnsureMacroUIHook()

	-- Wiped before the deferral guards: the deferred pass runs unforced, so only the wipe keeps the force.
	if forced then
		wipe(currentMacroState)
	end

	if InCombatLockdown() then
		ns.RequestUpdate()
		return
	end

	--[[
	    Never write while the Macro UI is open: its save-back would revert the
	    write and leave a state key for a body that's gone. The OnHide hook,
	    armed just above, replays the pass.
	]]
	if MacroFrame and MacroFrame:IsShown() then
		ns.MarkUpdatePending()
		return
	end

	local best, dataRetry = ns.ScanBags()

	if dataRetry then
		ns.RegisterDataRetry()
	else
		ns.UnregisterDataRetry()
	end

	-- Off, the macros stay as they are, but the scan still feeds the Readiness Report and the mini-map.
	if not ns.db.global.macrosEnabled then
		if ns.isHunter then
			ns.ScanPetFood()
		end
		ns.UpdateMinimapIcon()
		ns.RefreshMenu()
		return
	end

	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		local typeName = definition.typeName
		local config = MACRO_CONFIG[typeName]

		if not ns.IsMacroEnabled(typeName) then
			DeleteMacroIfExists(config.macro, typeName)
		else
			local bestEntry = best[typeName]
			local itemID = bestEntry and bestEntry.id

			if definition.modifyItem then
				itemID = definition.modifyItem(itemID)
			end

			-- Only for the scanned pick: a swapped item (Food's pet-buff override) feeds the pet.
			local corpseCast
			if definition.corpseSpell and itemID == (bestEntry and bestEntry.id) then
				corpseCast = definition.corpseSpell(bestEntry)
			end

			local leadCast
			if definition.leadSpell and itemID == (bestEntry and bestEntry.id) then
				leadCast = definition.leadSpell(bestEntry)
			end

			local combatCast
			if definition.combatSpell and itemID == (bestEntry and bestEntry.id) then
				combatCast = definition.combatSpell(bestEntry)
			end

			local useIDs
			if itemID and ns.MULTI_USE_MACRO_TYPES[typeName] and bestEntry.topIDs and #bestEntry.topIDs > 0 then
				useIDs = bestEntry.topIDs
			end

			--[[
			    With no main item the stack becomes the whole body (a Health Potion
			    macro in every TBC arena still uses the stones), and the
			    DruidMacroHelper guards follow what the body now uses.
			]]
			local stackIDs
			local overrideTypeName = typeName
			if definition.getStackIDs then
				local stacked = definition.getStackIDs(best)
				if itemID then
					stackIDs = stacked
				elseif stacked and #stacked > 0 then
					itemID, useIDs = stacked[1], stacked
					overrideTypeName = definition.stackTypeName or typeName
				end
			end

			-- That type's scanned pick, buff food included, whether or not its own macro is on.
			local outOfCombatID, outOfCombatStealth, outOfCombatCorpse
			if definition.outOfCombatTypeName and ns.db.profile.potionsUseFoodAndWater then
				local outOfCombatEntry = best[definition.outOfCombatTypeName]
				outOfCombatID = outOfCombatEntry and outOfCombatEntry.id

				local source = ns.MacroDefinitionByType(definition.outOfCombatTypeName)
				if outOfCombatID and source and source.stealthSpell then
					outOfCombatStealth = source.stealthSpell()
				end
				if outOfCombatID and source and source.corpseSpell then
					outOfCombatCorpse = source.corpseSpell(outOfCombatEntry)
				end
			end

			local classBody, classStateID
			if itemID then
				classBody, classStateID = ns.BuildDruidMacroOverride(
					overrideTypeName,
					itemID,
					useIDs,
					stackIDs,
					outOfCombatID,
					outOfCombatStealth
				)
			end

			if classBody then
				-- Override keys MUST carry their own prefix ("DMH:"), so a switch to or from one always rewrites.
				if currentMacroState[typeName] ~= classStateID or forced then
					WriteMacro(config.macro, classBody, classStateID, typeName)
				end
			else
				local conjureInfo = definition.conjure and definition.conjure() or nil

				local appendText, appendFlag
				if definition.appendBlock then
					appendText, appendFlag = definition.appendBlock(itemID)
				end

				local stateID = ns.BuildStateKey(
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

				if currentMacroState[typeName] ~= stateID or forced then
					local body = ns.BuildStandardBody(
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
					WriteMacro(config.macro, body, stateID, typeName)
				end
			end
		end
	end

	for _, definition in ipairs(ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS) do
		definition.customUpdate(forced)
	end

	ns.UpdateMinimapIcon()
	ns.RefreshMenu()
end

function ns.ResetMacroState()
	wipe(currentMacroState)
	ns.ResetHunterMacroState()
	ns.ResetPoisonMacroState()
	ns.ResetFishingLureMacroState()
	ns.ResetScrollBuffTracking()
	ns.ResetTargetTracking()
end

--------------------------------------------------------------------------------
-- Feature Toggles
--------------------------------------------------------------------------------

-- Repaints the panels too: a Buff Duty flyout click has nothing else to ask for one.
function ns.ToggleMacroSetting(key, value)
	ns.db.profile[key] = value
	ns.ResetMacroState()
	ns.RequestUpdate()
	ns.RefreshSettings()
end

-- Cannibalize and Rapid Regeneration count because their cooldowns take their lines out of the bodies.
function ns.SpellCastChangesMacros(spellID)
	return (ns.spellCache ~= nil and ns.spellCache[spellID] ~= nil)
		or (ns.isForsaken and spellID == ns.CANNIBALIZE_SPELL_ID)
		or (ns.isTroll and spellID == ns.RAPID_REGENERATION_SPELL_ID)
		or false
end

function ns.SetMacrosEnabled(value)
	ns.db.global.macrosEnabled = value
	if value then
		ns.ResetMacroState()
		ns.RequestUpdate()
	end
end
