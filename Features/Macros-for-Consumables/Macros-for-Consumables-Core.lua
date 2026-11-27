local _, ns = ...

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame")

--[[
    Two flags, not one: RequestUpdate re-arms whenever the tick is disarmed, so
    a pending update can never be stranded with no OnUpdate attached, even if a
    combat-exit replay is missed.
]]
local isUpdatePending = false
local isTickScheduled = false
local updateTimer = 0
local UPDATE_THROTTLE = 0.5

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local sessionConstantsInitialized = false

local function InitializeConsumableMacros()
	if not sessionConstantsInitialized then
		sessionConstantsInitialized = true
		ns.InitializeCharacterConstants()
		-- Only a conjure, Cannibalize or Rapid Regeneration cast can change a macro.
		if ns.isMage or ns.isWarlock or ns.isForsaken or (ns.isTroll and ns.rapidRegenerationSpellName) then
			ns.SetEventRegistered("UNIT_SPELLCAST_SUCCEEDED", true, "player")
		end
		-- A hunter's Call Pet and Revive Pet tell a dead pet from a dead target (Tools-Hunters.lua).
		if ns.isHunter then
			ns.SetEventRegistered("UNIT_SPELLCAST_SENT", true, "player")
			ns.SetEventRegistered("UNIT_SPELLCAST_SUCCEEDED", true, "player")
		end
	end
end

-- Bodies only: which macros exist (enabledMacros) is account-wide, like the macros themselves.
function ns.ApplyConsumableMacrosProfile()
	ns.ResetMacroState()
	ns.UpdateAuraTracking()
	ns.RequestUpdate()
end

-- Must run after InitializeConsumableMacros, which resolves ns.isHunter.
local function RefreshArrivalState()
	ns.cachedPlayerLevel = UnitLevel("player") or 1
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	-- Busy event; only hunter pet-food quest skipping reads it.
	ns.SetEventRegistered("QUEST_LOG_UPDATE", ns.isHunter)
end

--------------------------------------------------------------------------------
-- Update Throttling
--------------------------------------------------------------------------------

local function OnUpdateHandler(_, elapsed)
	if InCombatLockdown() then
		-- The work stays pending; PLAYER_REGEN_ENABLED re-arms the tick.
		frame:SetScript("OnUpdate", nil)
		isTickScheduled = false
		return
	end

	updateTimer = updateTimer + elapsed
	if updateTimer > UPDATE_THROTTLE then
		frame:SetScript("OnUpdate", nil)
		isTickScheduled = false
		isUpdatePending = false
		ns.UpdateMacros()
	end
end

function ns.RequestUpdate()
	isUpdatePending = true

	if InCombatLockdown() then
		return
	end

	--[[
	    Gate on isTickScheduled, not isUpdatePending, or a stranded pending flag
	    swallows every update until a /reload. The timer resets only on a fresh
	    arm, so a burst fires after its first request, not its last.
	]]
	if not isTickScheduled then
		isTickScheduled = true
		updateTimer = 0
		frame:SetScript("OnUpdate", OnUpdateHandler)
	end
end

-- For a deferral something else is sure to replay.
function ns.MarkUpdatePending()
	isUpdatePending = true
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

--[[
    Events above the combat guard touch nothing protected and must not wait
    for combat to end; RequestUpdate still defers the macro write itself.
]]
local function OnEvent(event, ...)
	-- A login straight into combat (a battleground in progress) must still initialize.
	if event == "PLAYER_LOGIN" then
		InitializeConsumableMacros()
		RefreshArrivalState()
		return
	end

	-- The wrong-zone error mostly fires when a zone-locked potion is pressed mid-fight.
	if event == "UI_ERROR_MESSAGE" then
		local _, message = ...

		ns.OnHunterUiErrorMessage(message)

		ns.OnMacroUiErrorMessage(message)
		return
	end

	-- A pet revived mid-fight must clear the dead-pet flag then.
	if event == "UNIT_PET" then
		ns.OnUnitPet(...)
		return
	end

	--[[
	    A killing-blow ding fires in combat. The level comes off the event:
	    UnitLevel("player") still reads the old level here, which would leave
	    every macro built one level behind.
	]]
	if event == "PLAYER_LEVEL_UP" then
		local newLevel = ...
		ns.cachedPlayerLevel = newLevel or UnitLevel("player") or ns.cachedPlayerLevel or 1
		if ns.isHunter then
			ns.ResolveHunterSpells()
		end
		ns.ResetMacroState()
		ns.RequestUpdate()
		return
	end

	-- A /reload mid-combat still fires it, and the prune must still run.
	if event == "PLAYER_LOGOUT" then
		ns.OnIgnoreListPlayerLogout()
		return
	end

	--[[
	    Behind the guard, a mid-fight change would leave the signature at its
	    pre-fight reading, and changing back after combat would read as no
	    change, leaving the macros built for the fight.
	]]
	if event == "PLAYER_TARGET_CHANGED" then
		if ns.TargetSignatureChanged() then
			ns.RequestUpdate()
		end
		return
	end

	if event == "GROUP_ROSTER_UPDATE" then
		if ns.GroupSignatureChanged() then
			ns.RequestUpdate()
		end
		return
	end

	-- Behind the guard, every cast in a fight would mark a rebuild pending.
	if event == "UNIT_SPELLCAST_SENT" then
		local _, _, _, spellID = ...
		ns.OnHunterSpellcastSent(spellID)
		return
	end

	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		if ns.isHunter then
			ns.OnHunterSpellcastSucceeded(spellID)
		end
		-- A secret spellID (Forever) errors as a table key, so rebuild in case it mattered.
		if ns.IsSecretValue(spellID) then
			ns.RequestUpdate()
			return
		end
		if ns.SpellCastChangesMacros(spellID) then
			ns.RequestUpdate()
		end
		return
	end

	-- A bandage mid-fight raises First Aid; in combat the read is put off to PLAYER_REGEN_ENABLED.
	if event == "SKILL_LINES_CHANGED" then
		if InCombatLockdown() then
			ns.DeferProfessionSkillsRead()
		elseif ns.UpdateProfessionSkills() then
			ns.RequestUpdate()
		end
		return
	end

	-- Font-string alpha is allowed in combat, so a mid-fight login still hides macro names.
	if event == "PLAYER_ENTERING_WORLD" then
		ns.ApplyMacroNameVisibility()
	end

	if InCombatLockdown() then
		isUpdatePending = true
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		if ns.RereadProfessionSkillsIfPending() then
			isUpdatePending = true
		end
		if ns.RereadTargetIfPending() then
			isUpdatePending = true
		end
		if isUpdatePending then
			ns.RequestUpdate()
		end
		return
	end

	if event == "QUEST_LOG_UPDATE" then
		if ns.PetFoodQuestsChanged() then
			ns.RequestUpdate()
		end
		return
	end

	if
		event == "BAG_UPDATE_DELAYED"
		or event == "ITEM_PUSH"
		or event == "PLAYER_ALIVE"
		or event == "PLAYER_UNGHOST"
	then
		ns.RequestUpdate()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		ns.cachedMapID = C_Map.GetBestMapForUnit("player")
		ns.RequestUpdate()
	elseif event == "SPELLS_CHANGED" then
		if ns.isHunter then
			ns.ResolveHunterSpells()
		end
		ns.RequestUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		RefreshArrivalState()
		ns.UpdateAuraTracking()
		ns.RequestUpdate()
		-- Item info and auras can arrive late after a loading screen.
		C_Timer.After(3, function()
			ns.RequestUpdate()
		end)
	elseif event == "UNIT_AURA" then
		ns.OnUnitAura(...)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "UNIT_INVENTORY_CHANGED" then
		-- Subscribed only while the Fishing Lure macro is on (Macros/Fishing-Lure.lua).
		if ns.FishingGearChanged() then
			ns.RequestUpdate()
		end
	end
end

local MODULE = "ConsumableMacros"
ns.RegisterEventModule(MODULE, OnEvent)

-- Every feature's item-info answer arrives here; only a consumable's can change a macro.
function ns.OnConsumableItemInfoReceived(itemID)
	if ns.HasRawData(itemID) then
		ns.RequestUpdate()
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- DEFERRED_EVENTS subscribe only while needed, each from its own feature file.
local EVENTS = {
	"BAG_UPDATE_DELAYED",
	"ITEM_PUSH",
	"PLAYER_ALIVE",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_LOGOUT",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_UNGHOST",
	"UI_ERROR_MESSAGE",
	"ZONE_CHANGED_NEW_AREA",
	"SKILL_LINES_CHANGED",
	"SPELLS_CHANGED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_PET",
	"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_AURA",
	"QUEST_LOG_UPDATE",
	"PLAYER_EQUIPMENT_CHANGED",
	"UNIT_INVENTORY_CHANGED",
}

local DEFERRED_EVENTS = {
	UNIT_PET = true,
	UNIT_SPELLCAST_SENT = true,
	UNIT_SPELLCAST_SUCCEEDED = true,
	UNIT_AURA = true,
	QUEST_LOG_UPDATE = true,
	PLAYER_EQUIPMENT_CHANGED = true,
	UNIT_INVENTORY_CHANGED = true,
}

-- Unit arguments after `enabled` make the subscription unit-filtered.
function ns.SetEventRegistered(event, enabled, ...)
	ns.SetModuleEvent(MODULE, event, enabled, ...)
end

for _, event in ipairs(EVENTS) do
	if not DEFERRED_EVENTS[event] then
		ns.SetEventRegistered(event, true)
	end
end

ns.SetEventRegistered("UNIT_PET", true, "player")
