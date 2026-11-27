local _, ns = ...

--------------------------------------------------------------------------------
-- Profile Changes
--------------------------------------------------------------------------------

-- A profile switch, reset or copy changes every macro option and the What's Next? sort.
function ns.ApplySpellbookProfile()
	if ns.IsSpellbookEnabled() then
		ns.InvalidateSpellRankRows()
		ns:RefreshMacros()
		ns.RefreshWhatsNext()
	end
end

--------------------------------------------------------------------------------
-- Master Switch
--------------------------------------------------------------------------------

local SubscribeSpellbookEvents

function ns.IsSpellbookEnabled()
	return ns.db ~= nil and ns.db.global.spellbookEnabled
end

-- Off drops the events, so the macros freeze as last written; on catches up at once.
function ns.SetSpellbookEnabled(value)
	ns.db.global.spellbookEnabled = value
	SubscribeSpellbookEvents(value)
	if value then
		-- gear and known spells may have changed while their events went unheard
		ns:InvalidateUsableSlots()
		ns.InvalidateSpellRankRows()
		ns:RefreshMacros()
	else
		ns.HideSpellbookWindow()
	end
	if ns.SyncSpellbookHost then
		ns.SyncSpellbookHost()
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- Handler names resolve on ns when the event fires, so files loaded after this one supply them.
local EVENT_HANDLERS = {
	ADDON_LOADED = "OnAddonLoaded",
	SPELLS_CHANGED = "OnSpellsChanged",
	SKILL_LINES_CHANGED = "OnSpellbookSkillLinesChanged",
	PLAYER_EQUIPMENT_CHANGED = "OnPlayerEquipmentChanged",
	SPELL_DATA_LOAD_RESULT = "OnSpellDataLoadResult",
	ACTIONBAR_SLOT_CHANGED = "OnActionbarSlotChanged",
	UPDATE_MACROS = "OnUpdateMacros",
	PLAYER_TARGET_CHANGED = "OnPlayerTargetChanged",
	UNIT_TARGET = "OnSpellbookUnitTarget",
	UPDATE_MOUSEOVER_UNIT = "OnUpdateMouseoverUnit",
	PLAYER_REGEN_ENABLED = "OnPlayerRegenEnabled",
	PLAYER_REGEN_DISABLED = "OnPlayerRegenDisabled",
	TRAINER_SHOW = "OnTrainerShow",
	TRAINER_UPDATE = "OnTrainerUpdate",
	PLAYER_LEVEL_UP = "OnPlayerLevelUp",
	UNIT_PET = "OnSpellbookUnitPet",
	UNIT_LEVEL = "OnSpellbookUnitLevel",
	PET_BAR_UPDATE = "OnSpellbookPetBarUpdate",
	BAG_UPDATE_DELAYED = "OnSpellbookBagUpdateDelayed",
}
-- Only where ns.EVENT_NAMES lists it (Features/Core.lua): Classic Era has no focus.
if ns.FLAVOR ~= "Vanilla" then
	EVENT_HANDLERS.PLAYER_FOCUS_CHANGED = "OnPlayerFocusChanged"
end

-- Trainer-Recording.lua's events subscribe only once login shows its handlers loaded.
local LOGIN_REGISTERED_EVENTS = { TRAINER_SHOW = true, TRAINER_UPDATE = true }
-- Spellbook-Tabs.lua subscribes ADDON_LOADED itself, only where it loads.
local OWNER_REGISTERED_EVENTS = { ADDON_LOADED = true }

-- Heard with the Spellbook off, so the tab is attached when switching on later.
local WHILE_OFF_EVENTS = { ADDON_LOADED = true }

-- UNIT_TARGET on "target" feeds Dynamic Rank's target-of-target.
local EVENT_UNITS = {
	UNIT_PET = { "player" },
	UNIT_LEVEL = { "player", "pet" },
	UNIT_TARGET = { "target" },
}

local MODULE = "Spellbook"

function SubscribeSpellbookEvents(on)
	for event in pairs(EVENT_HANDLERS) do
		local owned = OWNER_REGISTERED_EVENTS[event] or WHILE_OFF_EVENTS[event]
		local ready = not LOGIN_REGISTERED_EVENTS[event] or ns[EVENT_HANDLERS[event]] ~= nil
		if not owned and ready then
			ns.SetModuleEvent(MODULE, event, on, unpack(EVENT_UNITS[event] or {}))
		end
	end
end

local function OnPlayerLogin()
	-- MIGRATION (remove after 2026-11-26): the retired Custom Macros feature's lists, in every profile.
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		profile.customMacros, profile.customMacrosSeeded = nil, nil
	end
	-- MIGRATION (remove after 2026-11-26): the retired Profession Tooltips feature's saved skill levels.
	ns.db.global.professionSkills = nil
	--[[
		MIGRATION (remove after 2026-11-26): each profile's recorded trainer spells, from before they were kept by
		class, move under the class of the character the profile is named for. Where that class isn't known
		they are dropped; the next trainer visit records them again.
	]]
	local classes = ns.GetClassesByProfileName()
	classes[ns.db:GetCurrentProfile()] = select(2, UnitClass("player"))
	for profileName, profile in pairs(ns.db.sv.profiles or {}) do
		local trainerSpells, flat = profile.trainerSpells, {}
		for id, level in pairs(type(trainerSpells) == "table" and trainerSpells or {}) do
			if type(id) == "number" then
				flat[id] = level
			end
		end
		local class = classes[profileName]
		for id, level in pairs(flat) do
			trainerSpells[id] = nil
			if class then
				trainerSpells[class] = trainerSpells[class] or {}
				trainerSpells[class][id] = trainerSpells[class][id] or level
			end
		end
	end
	--[[
		MIGRATION (remove after 2026-12-13): pet abilities a WoW Forever hunter trainer listed, recorded as the
		hunter's own trainer spells before RecordServices (Features/Enhanced-Spellbook/Trainer-Recording.lua) skipped
		them, leave every profile's records.
	]]
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		for _, spells in pairs(type(profile.trainerSpells) == "table" and profile.trainerSpells or {}) do
			if type(spells) == "table" then
				for id in pairs(spells) do
					if ns.IsPetAbilitySpell(id) then
						spells[id] = nil
					end
				end
			end
		end
	end
	--[[
		MIGRATION (remove after 2026-11-26): this character's macro records, from when they were kept under
		ns.db.keys.char, move to ns.MacroOwnerKey where the two differ. Records under a placeholder name can't
		be told apart by character, so they stay where they are.
	]]
	local oldKey, newKey = ns.db.keys.char, ns.MacroOwnerKey()
	if oldKey ~= newKey and ns.SplitCharacterProfileName(oldKey) then
		local tags, prefix, oldIdentities = ns.db.global.macroTags, oldKey .. ":", {}
		for identity in pairs(tags) do
			if identity:sub(1, #prefix) == prefix then
				oldIdentities[#oldIdentities + 1] = identity
			end
		end
		for _, identity in ipairs(oldIdentities) do
			local moved = newKey .. ":" .. identity:sub(#prefix + 1)
			if tags[moved] == nil then
				tags[moved] = tags[identity]
			end
			tags[identity] = nil
		end
		for name, owner in pairs(ns.db.global.ownedMacros) do
			if owner == oldKey then
				ns.db.global.ownedMacros[name] = newKey
			end
		end
	end
	-- MIGRATION (remove after 2026-12-03)
	ns.MigrateSpellbookBinding()
	SubscribeSpellbookEvents(ns.IsSpellbookEnabled())
end

ns.RegisterEventModule(MODULE, function(event, ...)
	if event == "PLAYER_LOGIN" then
		OnPlayerLogin()
		return
	end
	if not ns.IsSpellbookEnabled() and not WHILE_OFF_EVENTS[event] then
		return
	end
	local handlerName = EVENT_HANDLERS[event]
	local handler = handlerName and ns[handlerName]
	if handler then
		handler(ns, ...)
	end
end)

-- The rest wait for login, when the saved switch is known.
ns.SetModuleEvent(MODULE, "PLAYER_LOGIN", true)
