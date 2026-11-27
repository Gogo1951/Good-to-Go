local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- Hunter Tools
--------------------------------------------------------------------------------

-- Pet food scanning and the pet-buff override, which the bag scan reads too, are in Tools-Hunters-Pet-Food.lua.

--------------------------------------------------------------------------------
-- Pet Spell Resolution
--------------------------------------------------------------------------------

-- C_Spell.GetSpellName names unlearned spells too, which would write casts the hunter can't make.
local function ResolveIfKnown(spellID)
	if ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID) then
		return C_Spell.GetSpellName(spellID)
	end
	return nil
end

function ns.ResolveHunterSpells()
	if not ns.isHunter then
		return
	end
	ns.feedPetSpellName = ResolveIfKnown(ns.FEED_PET_SPELL_ID)
	ns.revivePetSpellName = ResolveIfKnown(ns.REVIVE_PET_SPELL_ID)
	ns.mendPetSpellName = ResolveIfKnown(ns.MEND_PET_SPELL_ID)
	ns.callPetSpellName = ResolveIfKnown(ns.CALL_PET_SPELL_ID)
	ns.dismissPetSpellName = ResolveIfKnown(ns.DISMISS_PET_SPELL_ID)
end

--------------------------------------------------------------------------------
-- UI Error Handling (Hunter)
--------------------------------------------------------------------------------

--[[
    A failed Call Pet on a dead, dismissed pet shows SPELL_FAILED_TARGETS_DEAD,
    but so does any spell aimed at a dead unit, so the error counts only just
    after Call Pet was sent.
]]
local CALL_PET_ERROR_WINDOW = 1
local callPetSentAt

-- A secret spell ID (Forever) is treated as not Call Pet.
function ns.OnHunterSpellcastSent(spellID)
	if not ns.IsSecretValue(spellID) and spellID == ns.CALL_PET_SPELL_ID then
		callPetSentAt = GetTime()
	end
end

function ns.OnHunterSpellcastSucceeded(spellID)
	if ns.IsSecretValue(spellID) or not ns.petDeadDismissed then
		return
	end
	if spellID == ns.CALL_PET_SPELL_ID or spellID == ns.REVIVE_PET_SPELL_ID then
		ns.petDeadDismissed = false
		ns.RequestUpdate()
	end
end

function ns.OnHunterUiErrorMessage(message)
	if not ns.isHunter then
		return
	end
	if UnitExists("pet") or not message then
		return
	end
	if not callPetSentAt or GetTime() - callPetSentAt > CALL_PET_ERROR_WINDOW then
		return
	end
	local deadMessage = SPELL_FAILED_TARGETS_DEAD
	if deadMessage and message == deadMessage then
		callPetSentAt = nil
		ns.petDeadDismissed = true
		ns.RequestUpdate()
	end
end

--------------------------------------------------------------------------------
-- Pet State Events (Hunter)
--------------------------------------------------------------------------------

function ns.OnUnitPet(unit)
	if unit ~= "player" then
		return
	end
	if ns.isHunter and UnitExists("pet") and not UnitIsDead("pet") then
		ns.petDeadDismissed = false
	end
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentPetFoodState = nil

function ns.ResetHunterMacroState()
	currentPetFoodState = nil
end

--------------------------------------------------------------------------------
-- Feed Pet Macro Body
--------------------------------------------------------------------------------

--[[
    Tier A (a pet spell besides Mend missing): tip only. Tier B (no Mend Pet):
    the cascade plus a tip on [btn:2][combat]. Tier C: the full cascade.
      [mod:ctrl] Dismiss; [mod:shift][@pet,dead] Revive; [nopet] Call (Revive
      when dead-dismissed); [btn:2][combat] Mend; else Feed Pet + /use food.

    Trap: overflow cuts the trailing /use food line, silently dropping the
    feed. Five localized spell names push ruRU past 300 bytes, so Dismiss goes
    first, then Revive; the summon, Mend, Feed and food line never do.
]]
local function ComposeFeedPetBody(tier, itemID, includeDismiss, includeRevive)
	local feedName = ns.feedPetSpellName
	local reviveName = ns.revivePetSpellName
	local callName = ns.callPetSpellName
	local dismissName = ns.dismissPetSpellName
	local mendName = ns.mendPetSpellName -- nil in Tier B

	local nopetSpell = (ns.petDeadDismissed and reviveName) or callName

	local castClauses = {}
	if includeDismiss then
		castClauses[#castClauses + 1] = "[mod:ctrl] " .. dismissName
	end
	if includeRevive then
		castClauses[#castClauses + 1] = "[mod:shift][@pet,dead] " .. reviveName
	end
	castClauses[#castClauses + 1] = "[nopet] " .. nopetSpell
	if mendName then
		castClauses[#castClauses + 1] = "[btn:2][combat] " .. mendName
	end
	castClauses[#castClauses + 1] = feedName

	local lines = { "#showtooltip" }

	if tier == "B" then
		-- Halt too, or the press would /cast Feed Pet in combat, where it fails.
		lines[#lines + 1] = '/run GtGTipIf("[btn:2][combat]","noMendPet")'
		lines[#lines + 1] = "/stopmacro [btn:2][combat]"
	end

	lines[#lines + 1] = "/cast " .. table.concat(castClauses, "; ")

	--[[
	    Each token only while its branch exists; modifiers named singly, so an
	    Alt-click still falls through to Feed Pet. Keep the order: changing it
	    rewrites every Feed Pet macro for no change in behavior.
	]]
	local stopTokens = {}
	if includeDismiss and includeRevive then
		stopTokens[#stopTokens + 1] = "[mod:shift][mod:ctrl]"
	elseif includeRevive then
		stopTokens[#stopTokens + 1] = "[mod:shift]"
	elseif includeDismiss then
		stopTokens[#stopTokens + 1] = "[mod:ctrl]"
	end
	if mendName then
		stopTokens[#stopTokens + 1] = "[btn:2]"
	end
	stopTokens[#stopTokens + 1] = "[nopet]"
	if includeRevive then
		stopTokens[#stopTokens + 1] = "[@pet,dead]"
	end
	if mendName then
		stopTokens[#stopTokens + 1] = "[combat]"
	end
	lines[#lines + 1] = "/stopmacro " .. table.concat(stopTokens, "")

	if itemID then
		lines[#lines + 1] = "/use item:" .. itemID
	else
		lines[#lines + 1] = '/run GtGTip("noPetFood")'
	end

	return table.concat(lines, "\n")
end

local function BuildFeedPetBody(tier, itemID)
	if tier == "A" then
		return table.concat({
			"#showtooltip",
			'/run GtGTip("noPetSkills")',
		}, "\n")
	end

	local body = ComposeFeedPetBody(tier, itemID, true, true)
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		body = ComposeFeedPetBody(tier, itemID, false, true)
	end
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		body = ComposeFeedPetBody(tier, itemID, false, false)
	end
	return body
end

--------------------------------------------------------------------------------
-- Feed Pet Update
--------------------------------------------------------------------------------

local function UpdateFeedPetMacro(forced)
	if forced then
		currentPetFoodState = nil
	end

	local config = MACRO_CONFIG["Feed Pet"]
	if not config then
		return
	end
	local macroName = config.macro

	-- The cast line concatenates all four names, so any one missing must fall back to the stub.
	local tier
	if not (ns.feedPetSpellName and ns.revivePetSpellName and ns.callPetSpellName and ns.dismissPetSpellName) then
		tier = "A"
	elseif not ns.mendPetSpellName then
		tier = "B"
	else
		tier = "C"
	end

	local itemID = (tier ~= "A") and ns.bestPetFoodID or nil

	local stateID = tier
		.. "_"
		.. (itemID and tostring(itemID) or "none")
		.. "_"
		.. (ns.petDeadDismissed and "DD" or "ND")

	if currentPetFoodState == stateID and not forced then
		return
	end

	local body = BuildFeedPetBody(tier, itemID)

	if not ns.WriteMacroBody(macroName, body) then
		currentPetFoodState = nil
		return
	end

	currentPetFoodState = stateID
end

--------------------------------------------------------------------------------
-- Definition
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Feed Pet",

	customUpdate = function(forced)
		-- Ahead of the enabled check: the mini-map and Diagnostics read the pick with the macro off too.
		if ns.isHunter then
			ns.ScanPetFood()
		end

		-- Deleted on any class: it sits in the shared General tab.
		if not ns.IsMacroEnabled("Feed Pet") then
			local config = MACRO_CONFIG["Feed Pet"]
			if config then
				ns.DeleteMacroByName(config.macro)
				ns.ResetHunterMacroState()
			end
			return
		end

		if ns.isHunter then
			UpdateFeedPetMacro(forced)
		end
	end,
})
