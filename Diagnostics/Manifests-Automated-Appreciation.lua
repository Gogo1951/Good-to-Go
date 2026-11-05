local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per API Good to Go actually calls or guards, wherever it lives --
    nothing incidental, and nothing the add-on does not use.

    Every modern/legacy pair the add-on still picks between is listed as both
    halves: the unit tooltip the Buff Duty window reads a pet's owner from
    (C_TooltipInfo.GetUnit or a hidden tooltip's SetUnit), Validate Data's stat
    read, and its tooltip-text read (C_TooltipInfo.GetItemByID and
    GetSpellByID, or the hidden scan tooltip). The hidden tooltips are probed
    through the GameTooltip methods they inherit, so the check creates nothing.
    A FAIL on one half is the report working rather than a defect: the pair
    tells a bug report which branch that client took.
]]
local function HasFunction(namespace, name)
	return function()
		local library = _G[namespace]
		return type(library) == "table" and type(library[name]) == "function"
	end
end

local function HasGlobalFunction(name)
	return function()
		return type(_G[name]) == "function"
	end
end

-- CreateFrame throws on a template the client doesn't ship, so each one the add-on names gets a row.
local function HasTemplate(name)
	return function()
		local xml = _G.C_XMLUtil
		return type(xml) == "table" and type(xml.GetTemplateInfo) == "function" and xml.GetTemplateInfo(name) ~= nil
	end
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	{ "C_AddOns.GetAddOnMetadata", HasFunction("C_AddOns", "GetAddOnMetadata") },
	{ "C_AddOns.GetNumAddOns", HasFunction("C_AddOns", "GetNumAddOns") },
	{ "C_AddOns.GetAddOnInfo", HasFunction("C_AddOns", "GetAddOnInfo") },
	{ "C_Seasons.GetActiveSeason", HasFunction("C_Seasons", "GetActiveSeason") },
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},
	{ "Settings.OpenToCategory", HasFunction("Settings", "OpenToCategory") },
	{ "InCombatLockdown", HasGlobalFunction("InCombatLockdown") },
	{ "C_Timer.After", HasFunction("C_Timer", "After") },
	{ "C_Timer.NewTicker", HasFunction("C_Timer", "NewTicker") },
	{ "C_EventUtils.IsEventValid", HasFunction("C_EventUtils", "IsEventValid") },
	{ "C_Spell.GetSpellName", HasFunction("C_Spell", "GetSpellName") },
	{ "C_Spell.DoesSpellExist", HasFunction("C_Spell", "DoesSpellExist") },
	{ "C_Spell.GetSpellDescription", HasFunction("C_Spell", "GetSpellDescription") },
	{ "C_Spell.RequestLoadSpellData", HasFunction("C_Spell", "RequestLoadSpellData") },
	{ "C_Spell.IsSpellDataCached", HasFunction("C_Spell", "IsSpellDataCached") },
	{ "C_Spell.GetSpellTexture", HasFunction("C_Spell", "GetSpellTexture") },
	{ "C_Spell.GetSpellLink", HasFunction("C_Spell", "GetSpellLink") },
	{ "C_Spell.GetSpellSubtext", HasFunction("C_Spell", "GetSpellSubtext") },
	{ "C_Item.GetItemInfo", HasFunction("C_Item", "GetItemInfo") },
	{ "C_Item.GetItemIconByID", HasFunction("C_Item", "GetItemIconByID") },
	{ "C_UnitAuras.GetBuffDataByIndex", HasFunction("C_UnitAuras", "GetBuffDataByIndex") },
	{ "C_UnitAuras.GetAuraCasterGUID", HasFunction("C_UnitAuras", "GetAuraCasterGUID") },
	{ "C_Secrets.ShouldUnitIdentityBeSecret", HasFunction("C_Secrets", "ShouldUnitIdentityBeSecret") },
	{ "C_Secrets.ShouldAurasBeSecret", HasFunction("C_Secrets", "ShouldAurasBeSecret") },
	{ "issecretvalue", HasGlobalFunction("issecretvalue") },
	{ "CombatLogGetCurrentEventInfo", HasGlobalFunction("CombatLogGetCurrentEventInfo") },
	{
		"COMBATLOG_OBJECT_* affiliation / reaction / type flags",
		function()
			return COMBATLOG_OBJECT_TYPE_PLAYER ~= nil
				and COMBATLOG_OBJECT_REACTION_FRIENDLY ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_MINE ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_PARTY ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_RAID ~= nil
				and COMBATLOG_OBJECT_AFFILIATION_OUTSIDER ~= nil
		end,
	},
	{
		"bit.band / bit.lshift",
		function()
			return type(bit) == "table" and type(bit.band) == "function" and type(bit.lshift) == "function"
		end,
	},
	{ "GetPlayerInfoByGUID", HasGlobalFunction("GetPlayerInfoByGUID") },
	{ "UnitNameFromGUID", HasGlobalFunction("UnitNameFromGUID") },
	{ "Ambiguate", HasGlobalFunction("Ambiguate") },
	{ "C_ChatInfo.SendChatMessage", HasFunction("C_ChatInfo", "SendChatMessage") },
	{ "C_ChatInfo.PerformEmote", HasFunction("C_ChatInfo", "PerformEmote") },
	-- The emote catalog reads both when present and falls back without them.
	{
		"MAXEMOTEINDEX (guarded)",
		function()
			return type(MAXEMOTEINDEX) == "number"
		end,
	},
	{
		"TextEmoteSpeechList (guarded)",
		function()
			return type(TextEmoteSpeechList) == "table"
		end,
	},
	{ "UnitIsVisible", HasGlobalFunction("UnitIsVisible") },
	{ "UnitInRange", HasGlobalFunction("UnitInRange") },
	-- The Buff Key holds a group buff for a member out of sight unless they're AFK.
	{ "UnitIsAFK", HasGlobalFunction("UnitIsAFK") },
	-- A borrowed pet (Mind Control, Enslave Demon) takes no Buff Duty buff.
	{ "UnitIsCharmed", HasGlobalFunction("UnitIsCharmed") },
	{ "CreateMacro", HasGlobalFunction("CreateMacro") },
	{ "EditMacro", HasGlobalFunction("EditMacro") },
	{ "DeleteMacro", HasGlobalFunction("DeleteMacro") },
	{ "GetMacroIndexByName", HasGlobalFunction("GetMacroIndexByName") },
	{ "GetNumMacros", HasGlobalFunction("GetNumMacros") },
	{ "GetMacroInfo", HasGlobalFunction("GetMacroInfo") },
	{ "PlaySoundFile", HasGlobalFunction("PlaySoundFile") },
	-- Buff Duty's group read, role guesses and range check, and When to Show's In Instance.
	{ "IsInInstance", HasGlobalFunction("IsInInstance") },
	-- Where a zone-limited weapon item works.
	{ "GetInstanceInfo", HasGlobalFunction("GetInstanceInfo") },
	{ "C_Map.GetBestMapForUnit", HasFunction("C_Map", "GetBestMapForUnit") },
	{ "GetNumGroupMembers", HasGlobalFunction("GetNumGroupMembers") },
	{ "GetRaidRosterInfo", HasGlobalFunction("GetRaidRosterInfo") },
	{ "GetPartyAssignment (guarded)", HasGlobalFunction("GetPartyAssignment") },
	{ "UnitGroupRolesAssigned (guarded)", HasGlobalFunction("UnitGroupRolesAssigned") },
	{ "GetLFGRoles (guarded)", HasGlobalFunction("GetLFGRoles") },
	{ "C_Spell.IsSpellInRange", HasFunction("C_Spell", "IsSpellInRange") },
	{ "UnitPowerType", HasGlobalFunction("UnitPowerType") },
	{
		"Enum.PowerType.Mana / Focus",
		function()
			return type(Enum) == "table"
				and type(Enum.PowerType) == "table"
				and Enum.PowerType.Mana ~= nil
				and Enum.PowerType.Focus ~= nil
		end,
	},
	{ "C_Spell.GetSpellCooldown", HasFunction("C_Spell", "GetSpellCooldown") },
	-- Self Buffs' weapons and Soulstone: what each hand holds and carries, and what your bags hold.
	{ "GetInventoryItemID", HasGlobalFunction("GetInventoryItemID") },
	{ "GetInventoryItemTexture", HasGlobalFunction("GetInventoryItemTexture") },
	{ "GetWeaponEnchantInfo", HasGlobalFunction("GetWeaponEnchantInfo") },
	{
		"Enum.ItemClass.Weapon / Enum.ItemWeaponSubclass.Fishingpole (guarded)",
		function()
			return type(Enum) == "table"
				and type(Enum.ItemClass) == "table"
				and Enum.ItemClass.Weapon ~= nil
				and type(Enum.ItemWeaponSubclass) == "table"
				and Enum.ItemWeaponSubclass.Fishingpole ~= nil
		end,
	},
	{ "C_Item.GetItemCount", HasFunction("C_Item", "GetItemCount") },
	{ "C_Item.IsItemInRange", HasFunction("C_Item", "IsItemInRange") },
	{ "C_Container.GetItemCooldown", HasFunction("C_Container", "GetItemCooldown") },
	-- The game's "replace your enchant?" question, answered when a weapon icon's click asked it.
	{ "C_Item.ReplaceEnchant", HasFunction("C_Item", "ReplaceEnchant") },
	-- A Buff Duty item icon's tooltip.
	{
		"GameTooltip:SetItemByID",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.SetItemByID) == "function"
		end,
	},
	-- Features/Announcements.lua picks the instance channel before party or raid.
	{
		"LE_PARTY_CATEGORY_INSTANCE",
		function()
			return LE_PARTY_CATEGORY_INSTANCE ~= nil
		end,
	},
	{ "StaticPopup_Hide", HasGlobalFunction("StaticPopup_Hide") },
	-- The Buff Key: what a press can cast, and the binding Buff Duty sets.
	{ "C_Spell.IsSpellUsable", HasFunction("C_Spell", "IsSpellUsable") },
	-- Weighs a group buff's mana against its members' single casts.
	{ "C_Spell.GetSpellPowerCost (guarded)", HasFunction("C_Spell", "GetSpellPowerCost") },
	-- Which spells have a cooldown, so the Buff Key passes over them.
	{ "GetSpellBaseCooldown", HasGlobalFunction("GetSpellBaseCooldown") },
	{ "UnitHasIncomingResurrection (guarded)", HasGlobalFunction("UnitHasIncomingResurrection") },
	{ "GetBindingKey", HasGlobalFunction("GetBindingKey") },
	{ "SetBinding", HasGlobalFunction("SetBinding") },
	{ "SaveBindings", HasGlobalFunction("SaveBindings") },
	{ "GetCurrentBindingSet", HasGlobalFunction("GetCurrentBindingSet") },
	{ "C_TooltipInfo.GetUnit", HasFunction("C_TooltipInfo", "GetUnit") },
	{
		"Hidden unit tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetUnit) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	-- Buff Duty's secure buttons and the state driver behind Hide in Combat.
	{ "RegisterStateDriver", HasGlobalFunction("RegisterStateDriver") },
	{ "UnregisterStateDriver", HasGlobalFunction("UnregisterStateDriver") },
	{ "C_XMLUtil.GetTemplateInfo", HasFunction("C_XMLUtil", "GetTemplateInfo") },
	{ "SecureActionButtonTemplate", HasTemplate("SecureActionButtonTemplate") },
	{ "CooldownFrameTemplate", HasTemplate("CooldownFrameTemplate") },
	{ "BackdropTemplate", HasTemplate("BackdropTemplate") },
	{ "UIPanelCloseButton", HasTemplate("UIPanelCloseButton") },
	{ "GameTooltipTemplate", HasTemplate("GameTooltipTemplate") },
	-- Validate Data's reads beyond the reader lists it adds itself.
	{ "C_Item.DoesItemExistByID", HasFunction("C_Item", "DoesItemExistByID") },
	{ "C_Item.RequestLoadItemDataByID", HasFunction("C_Item", "RequestLoadItemDataByID") },
	{ "C_Item.GetItemInfoInstant", HasFunction("C_Item", "GetItemInfoInstant") },
	{ "C_Item.GetItemSpell", HasFunction("C_Item", "GetItemSpell") },
	{ "C_Item.GetDetailedItemLevelInfo", HasFunction("C_Item", "GetDetailedItemLevelInfo") },
	{ "C_Item.GetItemStats", HasFunction("C_Item", "GetItemStats") },
	{ "GetItemStats (legacy)", HasGlobalFunction("GetItemStats") },
	{ "C_Item.GetItemClassInfo", HasFunction("C_Item", "GetItemClassInfo") },
	{ "C_Item.GetItemSubClassInfo", HasFunction("C_Item", "GetItemSubClassInfo") },
	{ "C_TooltipInfo.GetItemByID", HasFunction("C_TooltipInfo", "GetItemByID") },
	{ "C_TooltipInfo.GetSpellByID", HasFunction("C_TooltipInfo", "GetSpellByID") },
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	-- Display Context's screen read, and the taintLog button.
	{ "GetPhysicalScreenSize", HasGlobalFunction("GetPhysicalScreenSize") },
	{ "GetCVar", HasGlobalFunction("GetCVar") },
	{ "SetCVar", HasGlobalFunction("SetCVar") },
})

--------------------------------------------------------------------------------
-- Thanks and Good News Context
--------------------------------------------------------------------------------

--[[
    The probes read feature state through the accessors the feature files
    expose (ns.IsBuffTrackingReady, ns.GetPraiseCooldownState, ns.BuffDuty
    and the like), so a report shows the values the features act on rather
    than a copy of their logic.
]]

--[[
    This file appends no spell rows. At login
    Features/Automated-Appreciation/Tracked-Lookups.lua replaces
    ns.DIAGNOSTIC_SPELLS with a per-class table of the tracked spells, built
    from ns.TRACKED_ABILITIES, which the class readout below reads; the rows
    other manifests append stay reachable as ns.DIAGNOSTIC_SPELL_ROWS
    (Diagnostics/Manifests.lua).
]]

-- Tracked-trigger coverage on the running client, filled at login by
-- Features/Automated-Appreciation/Tracked-Lookups.lua.
ns.DIAGNOSTIC_TRACKED = { entriesLive = 0, entriesTotal = 0, auraIds = 0, castIds = 0 }

--[[
    How many of a panel's toggles are on, out of how many it shows. A toggle
    carries every live id of one entry and switches them together, so it reads
    on when any of its ids is watched.
]]
local function IsToggleOn(toggle, watched)
	for _, id in ipairs(toggle.ids or {}) do
		if watched and watched[id] then
			return true
		end
	end
	return false
end

local function CountToggles(toggles, watched)
	local on = 0
	for _, toggle in ipairs(toggles or {}) do
		if IsToggleOn(toggle, watched) then
			on = on + 1
		end
	end
	return on, #(toggles or {})
end

local function CountCategoryToggles(categories, watched)
	local on, total = 0, 0
	for _, category in ipairs(categories or {}) do
		local categoryOn, categoryTotal = CountToggles(category.entries, watched)
		on, total = on + categoryOn, total + categoryTotal
	end
	return on, total
end

-- A toggle's name as its panel shows it, without the icon: a spell's name, a group's label, or its item's name.
local function ToggleName(toggle)
	if toggle.spellName then
		return toggle.spellName
	end
	if toggle.label then
		return toggle.label
	end
	local item = toggle.labelItem or toggle.itemId
	return C_Item.GetItemInfo(item) or ("item " .. tostring(item))
end

--[[
    The toggles a panel has switched off, by name, so a buff that lands and
    is never answered can be found here: a buff whose toggle is off is
    dropped before any print, sound, whisper or emote.
]]
local function UnwatchedText(categories, watched)
	local names = {}
	for _, category in ipairs(categories or {}) do
		for _, toggle in ipairs(category.entries or {}) do
			if not IsToggleOn(toggle, watched) then
				names[#names + 1] = ToggleName(toggle)
			end
		end
	end
	if #names == 0 then
		return "none"
	end
	return table.concat(names, ", ")
end

--[[
    How many of the curated emotes a panel has picked, out of how many there
    are, and how many of those picks this client can't perform: the random pick
    can land on one, and then no emote plays.
]]
local function EmotesPicked(emotes)
	local picked, missing = 0, 0
	if type(emotes) == "table" then
		for _, data in ipairs(ns.Data.EMOTES) do
			if emotes[data.token] then
				picked = picked + 1
				if not ns.IsClientEmote(data.token) then
					missing = missing + 1
				end
			end
		end
	end
	local text = string.format("%d/%d", picked, #ns.Data.EMOTES)
	if missing > 0 then
		text = text .. string.format(" (%d NOT ON CLIENT)", missing)
	end
	return text
end

local function KnowsAny(ids)
	for _, id in ipairs(ids or {}) do
		if ns.IsPlayerSpell(id) then
			return true
		end
	end
	return false
end

local function OnOff(value)
	return value and "on" or "off"
end

-- A value that may be secret on WoW Forever, as text that never tests it.
local function PlainText(value)
	if ns.IsPlain(value) then
		return tostring(value)
	end
	return "<secret>"
end

--[[
    Whether Good News watches a tracked spell you cast: the first of its cast
    ids that Good News knows decides, through the same watchedId the panel's
    toggle writes. n/a for a spell Good News doesn't offer (a service).
]]
local function GoodNewsState(ids, goodNews)
	for _, id in ipairs(ids or {}) do
		local entry = ns.GetGivenEntry and ns.GetGivenEntry(id)
		if entry then
			return OnOff(goodNews.watched and goodNews.watched[entry.watchedId])
		end
	end
	return "n/a"
end

-- How many of a recipient's Good News whispers are held back by the per-recipient-and-spell dedupe right now.
local function GoodNewsDedupCount(guid)
	local count = 0
	for _, entry in ipairs(ns.TRACKED_ABILITIES or {}) do
		for _, trigger in ipairs(entry.triggers or {}) do
			if ns.GetGivenEntry(trigger.spell) and ns.IsOnCooldown("goodnews:" .. guid .. ":" .. trigger.spell) then
				count = count + 1
			end
		end
	end
	return count
end

--[[
    Who the player has targeted and whether Good to Go would act on them right
    now: the Thank You Button's player, self and faction checks, whether
    they're friendly (on WoW Forever a stranger buff from a unit that isn't is
    dropped), whether they're in your party or raid (Sharing Good News on
    Only Group Members whispers no one else, Group Service Alerts and Combat
    Buffs hear no one else, and Stranger Buffs hears no one in it), the owner
    a pet's buff would be credited to (none drops the buff), whether they
    could see an emote (a praise emote skips a unit that isn't visible, or a
    group member out of range), and the per-source praise, whisper, service
    and Good News throttles for that GUID. A target whose identity is secret
    (WoW Forever) is reported as such and never read further.
]]
local function CurrentTargetLine()
	if not UnitExists("target") then
		return "Current target: none"
	end
	if ns.IsUnitIdentitySecret("target") then
		return "Current target: identity secret (the Thank You Button emotes but never whispers)"
	end
	local playerFaction, targetFaction = UnitFactionGroup("player"), UnitFactionGroup("target")
	local sameFaction = "<secret>"
	if ns.IsPlain(playerFaction) and ns.IsPlain(targetFaction) then
		sameFaction = tostring(playerFaction == targetFaction)
	end
	local inParty, inRaid = UnitInParty("target"), UnitInRaid("target")
	local inGroup = "<secret>"
	if ns.IsPlain(inParty) and ns.IsPlain(inRaid) then
		inGroup = tostring((inParty or inRaid) and true or false)
	end
	local inRange, checkedRange = UnitInRange("target")
	local isPlayer = UnitIsPlayer("target")
	local line = string.format(
		"Current target: player=%s self=%s friendly=%s sameFaction=%s inGroup=%s visible=%s inRange=%s (checked=%s)",
		PlainText(isPlayer),
		PlainText(UnitIsUnit("target", "player")),
		PlainText(UnitIsFriend("player", "target")),
		sameFaction,
		inGroup,
		PlainText(UnitIsVisible("target")),
		PlainText(inRange),
		PlainText(checkedRange)
	)
	local guid = UnitGUID("target")
	if guid and ns.IsPlain(guid) then
		if ns.IsPlain(isPlayer) and not isPlayer and ns.GetPetOwnerUnit then
			line = line .. string.format(" petOwner=%s", tostring(ns.GetPetOwnerUnit(guid) or "none"))
		end
		local _, source, whisper = ns.GetPraiseCooldownState(guid)
		line = line
			.. string.format(
				" praiseCooldown=%s whisperCooldown=%s serviceCooldown=%s goodNewsHeld=%d",
				tostring(source),
				tostring(whisper),
				tostring(ns.IsOnCooldown("service:" .. guid) and true or false),
				GoodNewsDedupCount(guid)
			)
	end
	return line
end

--[[
    Who cast a buff on you, as the aura names them: its caster's unit token
    and whether that is you, a group member, a player outside your group, or
    not a player (a pet is credited to its owner, or the buff is dropped).
    With no token, WoW Forever reads the caster's GUID off the aura the way
    its buff detection does, and a stranger known only by GUID is still
    thanked; elsewhere the combat log, not the aura, names the caster.
]]
local function AuraCaster(data)
	local unit = data.sourceUnit
	if not ns.IsPlain(unit) then
		return "<secret>"
	end
	if not unit then
		local instanceID = data.auraInstanceID
		if ns.FLAVOR == "Camelot" and ns.IsPlain(instanceID) and instanceID then
			local ok, guid = pcall(C_UnitAuras.GetAuraCasterGUID, "player", instanceID)
			if ok and ns.IsPlain(guid) and guid then
				return ns.IsPlayerGUID(guid) and "player by GUID only" or "non-player by GUID only"
			end
		end
		return "unknown"
	end
	if ns.IsUnitIdentitySecret(unit) then
		return unit .. " (identity secret)"
	end
	local kind = "not a player"
	if UnitIsUnit(unit, "player") then
		kind = "you"
	elseif UnitInParty(unit) or UnitInRaid(unit) then
		kind = "group"
	elseif UnitIsPlayer(unit) then
		kind = "outside group"
	end
	return unit .. " (" .. kind .. ")"
end

--[[
    The helpful auras on you right now, read through the same
    C_UnitAuras.GetBuffDataByIndex walk ns.GetBuffDuration makes (Stranger
    Buffs drops a buff that walk can't find): each one's name and id, its
    duration against Stranger Buffs' minimum, who cast it, and the type and
    watched state Combat Buffs or Group Service Alerts track it under. A
    secret field (WoW Forever) reads <secret> and keys no lookup.
]]
local function BuffsOnYouLines(lines, db)
	if not (type(C_UnitAuras) == "table" and C_UnitAuras.GetBuffDataByIndex) then
		lines[#lines + 1] = "  C_UnitAuras.GetBuffDataByIndex is missing"
		return
	end
	local minimum = db and db.strangers and db.strangers.minBuffDuration
	local watched = db and db.watchedBuffs or {}
	local count = 0
	for index = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex("player", index, "HELPFUL")
		if not ns.IsPlain(data) then
			lines[#lines + 1] = "  <secret aura data>"
			return
		end
		if not data then
			break
		end
		count = count + 1
		local spellID, duration = data.spellId, data.duration
		local name, tracked, isWatched, tooShort = "?", "no", "n/a", "<secret>"
		if ns.IsPlain(spellID) and spellID then
			name = C_Spell.GetSpellName(spellID) or "?"
			local entry = ns.GetAuraEntry(spellID)
			if entry then
				tracked = tostring(entry.type)
				isWatched = OnOff(watched[spellID])
			end
		end
		if ns.IsPlain(duration) then
			tooShort = tostring(
				(minimum and minimum > 0 and duration and duration > 0 and duration < minimum) and true or false
			)
		end
		lines[#lines + 1] = string.format(
			"  %s (%s) duration=%s tooShortForStrangers=%s from=%s tracked=%s watched=%s",
			name,
			PlainText(spellID),
			PlainText(duration),
			tooShort,
			AuraCaster(data),
			tracked,
			isWatched
		)
	end
	if count == 0 then
		lines[#lines + 1] = "  (none read)"
	end
end

--[[
    The state most likely to explain a "nothing happens when I get buffed"
    report: who the player is and which profile they're on, whether the buff
    engine ever set up and how buffs are detected on this flavor, whether that
    path is open right now (the post-loading-screen pause, combat, WoW
    Forever's secret auras, and on Forever the first gate that stops an aura
    read), every panel's switches and picked emotes, how many of each panel's
    toggles are on and which are off, the praise throttles and what would
    hold back each feature for your target, the buffs on you and how each
    would be classified, the sound settings the Master channel answers to,
    how much of the tracked data is live on this client, which tracked spells
    of their class they know and whether Sharing Good News watches each one,
    where /gtg goes, and what stops each Thank You button: its command, its
    saved settings, its toggle, its macro and the icon it wears, its whisper
    text and its emotes.
]]
function ns:BuildContextReport()
	local lines = { GetClientHeader(), "" }
	local db = ns.db and ns.db.global

	local _, class = UnitClass("player")
	lines[#lines + 1] = string.format(
		"Player: %s  Class: %s  Level: %s  Faction: %s",
		UnitName("player") or "?",
		tostring(class),
		tostring(UnitLevel("player") or 0),
		tostring(UnitFactionGroup("player") or "?")
	)
	if db then
		lines[#lines + 1] = string.format(
			"Active profile: %s  Welcome message: %s",
			tostring(ns.db:GetCurrentProfile()),
			tostring(db.showWelcome)
		)
	end
	-- The route ns:OpenOptionsPanel takes for /gtg.
	local categoryID = ns.optionsFrames and ns.optionsFrames.categoryID
	lines[#lines + 1] = string.format(
		"Options panel: category id %s, opened through %s",
		tostring(categoryID),
		(type(Settings) == "table" and Settings.OpenToCategory and categoryID) and "Settings.OpenToCategory"
			or "AceConfigDialog:Open"
	)
	lines[#lines + 1] = string.format(
		"Grouped: party=%s raid=%s  InCombat=%s",
		tostring(IsInGroup() and true or false),
		tostring(IsInRaid() and true or false),
		tostring(InCombatLockdown() and true or false)
	)
	-- A nil player GUID means the login setup never ran, and with it no lookup, list or timer.
	lines[#lines + 1] = string.format(
		"Buff tracking set up: %s  Ready (past the %ss post-loading-screen pause): %s",
		tostring(ns.GetPlayerGUID and ns.GetPlayerGUID() ~= nil),
		tostring(ns.Data.SAFETY_PAUSE),
		tostring(ns.IsBuffTrackingReady and ns.IsBuffTrackingReady())
	)
	if ns.FLAVOR == "Camelot" then
		lines[#lines + 1] =
			"Buff detection: UNIT_AURA (WoW Forever has no combat log; skipped in combat and while auras are secret, and a rebuff of a buff you already have is not seen)"
		-- The same gate the engine checks before it reads an aura update.
		if ns.BuffAuraGate then
			lines[#lines + 1] = string.format("Aura reads now: %s", ns.BuffAuraGate() or "open")
		end
	else
		lines[#lines + 1] = "Buff detection: combat log"
	end
	lines[#lines + 1] = string.format("Auras secret now: %s", tostring(ns.AreAurasSecret()))
	lines[#lines + 1] = string.format(
		"Sound: Sound_EnableAllSound=%s Sound_MasterVolume=%s",
		tostring(GetCVar("Sound_EnableAllSound")),
		tostring(GetCVar("Sound_MasterVolume"))
	)

	if db then
		local strangers, teammates, services = db.strangers or {}, db.teammates or {}, db.services or {}
		lines[#lines + 1] = string.format(
			"Stranger Buffs: enabled=%s print=%s whisper=%s emotes=%s emotesPicked=%s sound=%s  praiseDelay=%s/%s praiseCooldown=%s minDuration=%s cooldown=%s",
			tostring(strangers.enabled),
			tostring(strangers.printEnabled),
			tostring(strangers.whisperEnabled),
			tostring(strangers.emotesEnabled),
			EmotesPicked(strangers.emotes),
			tostring(strangers.soundEnabled),
			tostring(strangers.praiseDelayEnabled),
			tostring(strangers.praiseDelay),
			tostring(strangers.praiseCooldown),
			tostring(strangers.minBuffDuration),
			tostring(strangers.cooldown)
		)
		local teammatesOn, teammatesTotal = CountCategoryToggles(ns.TeammateCategories, db.watchedBuffs)
		lines[#lines + 1] = string.format(
			"Combat Buffs: enabled=%s print=%s whisper=%s emotes=%s emotesPicked=%s sound=%s  praiseDelay=%s/%s watched=%d/%d",
			tostring(teammates.enabled),
			tostring(teammates.printEnabled),
			tostring(teammates.whisperEnabled),
			tostring(teammates.emotesEnabled),
			EmotesPicked(teammates.emotes),
			tostring(teammates.soundEnabled),
			tostring(teammates.praiseDelayEnabled),
			tostring(teammates.praiseDelay),
			teammatesOn,
			teammatesTotal
		)
		lines[#lines + 1] = "  Not watched: " .. UnwatchedText(ns.TeammateCategories, db.watchedBuffs)
		local servicesOn, servicesTotal = CountToggles(ns.ServiceEntries, db.watchedBuffs)
		lines[#lines + 1] = string.format(
			"Group Service Alerts: enabled=%s print=%s whisper=%s emotes=%s emotesPicked=%s sound=%s  praiseDelay=%s/%s watched=%d/%d",
			tostring(services.enabled),
			tostring(services.printEnabled),
			tostring(services.whisperEnabled),
			tostring(services.emotesEnabled),
			EmotesPicked(services.emotes),
			tostring(services.soundEnabled),
			tostring(services.praiseDelayEnabled),
			tostring(services.praiseDelay),
			servicesOn,
			servicesTotal
		)
		lines[#lines + 1] = "  Not watched: " .. UnwatchedText({ { entries = ns.ServiceEntries } }, db.watchedBuffs)

		-- A blank saved template sends the default, so it reads as default here too.
		local goodNews = db.goodNews or {}
		local goodNewsOn, goodNewsTotal = CountCategoryToggles(ns.GoodNewsCategories, goodNews.watched)
		local message = goodNews.message
		local template = "default"
		local default = ns.DATABASE_DEFAULTS.global.goodNews.message
		if type(message) == "string" and not message:match("^%s*$") and message ~= default then
			template = string.format("custom (%d bytes)", #message)
		end
		lines[#lines + 1] = string.format(
			"Sharing Good News: whisper=%s scope=%s watched=%d/%d template=%s",
			tostring(goodNews.whisperEnabled),
			tostring(goodNews.scope),
			goodNewsOn,
			goodNewsTotal,
			template
		)
		lines[#lines + 1] = "  Not watched: " .. UnwatchedText(ns.GoodNewsCategories, goodNews.watched)
	else
		lines[#lines + 1] = "Saved variables not initialized."
	end

	local tracked = ns.DIAGNOSTIC_TRACKED
	lines[#lines + 1] = string.format(
		"Tracked triggers live on this client: %d / %d entries  (aura ids=%d, cast ids=%d)",
		tracked.entriesLive or 0,
		tracked.entriesTotal or 0,
		tracked.auraIds or 0,
		tracked.castIds or 0
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Praise cooldowns:"
	if ns.GetPraiseCooldownState then
		lines[#lines + 1] =
			string.format("  Overall praise cooldown active: %s", tostring(ns.GetPraiseCooldownState(nil)))
	end
	lines[#lines + 1] = "  " .. CurrentTargetLine()

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Buffs on you now:"
	BuffsOnYouLines(lines, db)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Tracked spells for your class (known / Good News):"
	local classSpells = class and ns.DIAGNOSTIC_SPELLS[class]
	if classSpells then
		local goodNews = db and db.goodNews or {}
		for _, spellData in ipairs(classSpells) do
			lines[#lines + 1] = string.format(
				"  %s = known:%s goodNews:%s",
				spellData.name,
				tostring(KnowsAny(spellData.ids)),
				GoodNewsState(spellData.ids, goodNews)
			)
		end
	else
		lines[#lines + 1] = "  (no tracked spells for this class)"
	end

	-- Read only: the macros are looked up by name, never created or deleted here.
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Thank You buttons:"
	if db then
		lines[#lines + 1] = string.format(
			"  Account macros: %s / %d (Good to Go creates a Thank You macro only while the list is under the cap, and never in combat)",
			tostring(GetNumMacros()),
			ns.Data.MAX_GLOBAL_MACROS
		)
		for index, button in ipairs(ns.Data.THANK_YOU_BUTTONS) do
			-- With no saved settings the command stops silently once its target checks pass.
			local settings = db[button.profileKey] and "saved" or "MISSING"
			local config = db[button.profileKey] or {}
			local message = config.message
			local whisper = "none"
			if type(message) == "string" and message ~= "" then
				whisper = string.format("%d bytes", #message)
			end
			local emote
			if button.singleEmote then
				local token = config.emote
				emote = string.format(
					"emote=%s valid=%s",
					(token and token ~= "") and tostring(token) or "none",
					tostring(ns.IsClientEmote(token))
				)
			else
				emote = "emotesPicked=" .. EmotesPicked(config.emotes)
			end
			-- A macro the player edited no longer runs the command, so the button does nothing.
			local macroIndex = GetMacroIndexByName(button.macroName) or 0
			local macro = "missing"
			if macroIndex > 0 then
				local _, _, body = _G.GetMacroInfo(macroIndex)
				macro = (body and body:gsub("%s+$", "") == button.command) and "runs command" or "BODY EDITED"
			end
			lines[#lines + 1] = string.format(
				"  %s (%s): command=%s settings=%s createMacro=%s macro=%s icon=%s whisper=%s %s",
				button.command,
				button.macroName,
				SlashCmdList["GOODTOGO_THANKYOU" .. index] and "registered" or "MISSING",
				settings,
				tostring(config.createMacro),
				macro,
				tostring(ns.GetThankYouIcon and ns.GetThankYouIcon(config)),
				whisper,
				emote
			)
		end
	else
		lines[#lines + 1] = "  Saved variables not initialized."
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Emote Extract
--------------------------------------------------------------------------------

--[[
    Every emote this client can perform, as a tab-separated table. The catalog
    is read from the running client's own globals, so running this on another
    flavor extracts that build's list with no code change. The voice column
    comes from the client's speech list, the only place an add-on can see it.
]]
function ns:BuildEmoteReport()
	local catalog = ns.GetEmoteCatalog()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format("%d emotes", #catalog)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "index\ttoken\tcommands\tvoice"
	for _, emote in ipairs(catalog) do
		lines[#lines + 1] =
			string.format("%d\t%s\t%s\t%s", emote.index, emote.token, emote.aliases, emote.voice and "voice" or "")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Combat Cast Probe
--------------------------------------------------------------------------------

--[[
    The event log's per-id filter asks this whether a firing of an id-filtered
    event (ns.MESSAGE_ID_FILTERED_EVENTS) is one Good to Go acts on. For
    UNIT_SPELLCAST_SUCCEEDED that is a spell id the live lookups hold -- a
    service or other cast entry, or a buff you can give for Good News -- the
    same lookups the handlers match against, or any rank of a spell the Buff
    Window can cast, which is what a Buff Key press waits to hear go off (the
    set built from this client's Buff-Duty-Spells data, on the first firing
    while logging). For GET_ITEM_INFO_RECEIVED it is an item of a tracked
    trigger, the set the panels' repaint watches (built from
    ns.TRACKED_ABILITIES the same way), or one Buff Duty uses. For
    UI_ERROR_MESSAGE it is the "more powerful spell" refusal, whose error type
    Buff Duty learns from its text the first time it acts on one and logs that
    firing itself (ns.IsBuffBounceError). Everything else is counted.
]]
local trackedItems
local IsBuffDutySpell -- defined under Validate Data Sources, from the same collectors

local function IsTrackedItem(itemID)
	if not trackedItems then
		trackedItems = {}
		for _, entry in ipairs(ns.TRACKED_ABILITIES or {}) do
			for _, trigger in ipairs(entry.triggers or {}) do
				if trigger.item then
					trackedItems[trigger.item] = true
				end
			end
		end
	end
	return trackedItems[itemID] == true
end

function ns.IsCorrelatedMessage(event, id)
	if event == "GET_ITEM_INFO_RECEIVED" then
		return IsTrackedItem(id) or (ns.IsBuffDutyItem ~= nil and ns.IsBuffDutyItem(id))
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		return ns.GetCastEntry(id) ~= nil or ns.GetGivenEntry(id) ~= nil or IsBuffDutySpell(id)
	end
	if event == "UI_ERROR_MESSAGE" then
		return ns.IsBuffBounceError ~= nil and ns.IsBuffBounceError(id)
	end
	return false
end

--[[
    The "why isn't this cast announced" and "why wasn't I thanked for that
    buff" cases (portals, summons, feasts, jumper cables, buffs on you).
    COMBAT_LOG_EVENT_UNFILTERED is excluded from the log as a firehose, so the
    buff engine calls this for each SPELL_CAST_SUCCESS and SPELL_RESURRECT, and
    for each SPELL_AURA_APPLIED or SPELL_AURA_REFRESH that lands on you
    (labeled AURA), while logging is on, before any of its own filtering.

    An aura on you, every revive (Buff Duty hides the revived player's
    resurrect icon on any of them), and a cast Good to Go acts on (a tracked entry,
    a buff you give for Good News), records in full:
    spell id and name, source, the decoded affiliation/reaction flags, and
    whether the add-on tracks and watches that id. tracked=true watched=true
    means the cast reached the add-on and the issue is downstream. A cable that
    revives nobody logs CAST with no REZ after it. Every other cast is counted
    by spell id in the log's summary instead, so a busy raid can't push the
    signal out of the buffer; a portal missing from the data still shows its id
    and name there.
]]
function ns:LogCombatCast(spellID, sourceName, sourceFlags, tracked, watched, label)
	label = label or "CAST"
	local name = C_Spell.GetSpellName(spellID) or "?"
	local correlated = label ~= "CAST" or tracked or ns.GetGivenEntry(spellID) ~= nil
	if not correlated then
		ns:CountUncorrelated("COMBAT_LOG_EVENT_UNFILTERED", spellID, label .. " " .. name)
		return
	end

	local flags = sourceFlags or 0
	local affiliation = (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 and "MINE")
		or (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 and "PARTY")
		or (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0 and "RAID")
		or (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0 and "OUTSIDER")
		or "?"
	ns:LogEventNow(
		"COMBAT_LOG_EVENT_UNFILTERED",
		label,
		spellID,
		name,
		sourceName,
		string.format(
			"player=%s friendly=%s aff=%s",
			tostring(bit.band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0),
			tostring(bit.band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0),
			affiliation
		),
		"tracked=" .. tostring(tracked and true or false),
		"watched=" .. tostring(watched and true or false)
	)
end

--[[
    Forever's version of the case above: UNIT_AURA is excluded from the log
    because its update table can't be written as text, so the buff engine calls
    this for each helpful aura added to you (or one whose helpfulness is
    secret), and once for a full update, while logging is on, through
    ns:LogAuraUpdateInfo below. verdict is the
    first gate that stops the update -- not ready, no db, in combat, auras
    secret, full update -- or read when the aura goes on to be classified.
    tracked=true watched=true with verdict read means the buff reached the
    add-on and the issue is downstream. A secret value is never tested here:
    ns:LogEventNow writes it as <secret>, and the id-keyed reads are skipped.
]]
function ns:LogAuraUpdate(verdict, aura)
	if not ns.IsPlain(aura) then
		ns:LogEventNow("UNIT_AURA", "ADDED", verdict, aura)
		return
	end
	if aura == nil then
		ns:LogEventNow("UNIT_AURA", "FULL", verdict)
		return
	end
	local spellID = aura.spellId
	local name, tracked, watched = nil, "?", "?"
	if ns.IsPlain(spellID) and spellID then
		name = C_Spell.GetSpellName(spellID)
		tracked = tostring(ns.GetAuraEntry(spellID) ~= nil)
		watched = tostring(ns.db and ns.db.global.watchedBuffs[spellID] and true or false)
	end
	ns:LogEventNow(
		"UNIT_AURA",
		"ADDED",
		verdict,
		spellID,
		name or "?",
		aura.sourceUnit,
		"tracked=" .. tracked,
		"watched=" .. watched
	)
end

--[[
    The buff engine's one call into the log for Forever's UNIT_AURA: names the
    gate that stops this update (ns.BuffAuraGate, the same check the engine
    makes), then logs a full update once, or each added helpful aura (and any
    whose helpfulness is secret), before any gate runs. A secret value is
    checked with ns.IsPlain before it is tested.
]]
function ns:LogAuraUpdateInfo(updateInfo)
	if not ns.IsPlain(updateInfo) or not updateInfo then
		return
	end
	local verdict = ns.BuffAuraGate()

	local isFullUpdate = updateInfo.isFullUpdate
	if not ns.IsPlain(isFullUpdate) or isFullUpdate then
		ns:LogAuraUpdate(verdict or "full update", nil)
		return
	end
	local added = updateInfo.addedAuras
	if not ns.IsPlain(added) or not added then
		return
	end
	for _, aura in ipairs(added) do
		local helpful = ns.IsPlain(aura) and aura.isHelpful
		if not ns.IsPlain(aura) or not ns.IsPlain(helpful) or helpful then
			ns:LogAuraUpdate(verdict or "read", aura)
		end
	end
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

local function SortedKeys(set)
	local keys = {}
	for key in pairs(set) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

-- The command this client gives an emote token, the same catalog the emote checks read; nil when it has none.
local function EmoteCommand(token)
	for _, emote in ipairs(ns.GetEmoteCatalog()) do
		if emote.token == token then
			return emote.command
		end
	end
	return nil
end

--[[
    Every record Good to Go shows or matches by the name this client gives it, for
    the Localization tab's Game Names report, built at load from this client's
    data. Each row reads the name exactly as the features do:

    - every ns.GAME_IDS constant, a spell named through C_Spell.GetSpellName
      (what ns.GetSpellLink builds the panel samples from), requested when it
      loads late;
    - every class token this client's tracked and Buff Duty
      data carries, named through LOCALIZED_CLASS_NAMES_MALE as the panels show
      it;
    - the client's duration strings, through ns.FormatDuration as the Good News
      whisper uses them, with the sample count in the ID cell;
    - the pet-owner tooltip formats Buff Duty turns into patterns to find
      a targeted pet's owner (NIL means that wording is skipped on this client);
    - the group labels the Buff Duty window heads its party sections with, the
      hand names its weapon rows and the Weapon Buffs panel show, the error a
      Buff Key pressed in combat shows, and the "more powerful spell" refusal
      Buff Duty matches by its text (NIL means it never learns a buff bounced);
    - every curated emote token the praise panels pick from, named by the
      command this client gives it (NIL means the client has no such emote, so
      a pick of it never plays).

    Good to Go names no item by constant: tracked items' names show on Validate Data.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, {})

do
	local rows = ns.DIAGNOSTIC_NAME_LOOKUPS

	for _, constant in ipairs(SortedKeys(ns.GAME_IDS or {})) do
		local id = ns.GAME_IDS[constant]
		rows[#rows + 1] = {
			constant = constant,
			kind = "spell",
			id = id,
			lookup = function()
				return C_Spell.GetSpellName(id)
			end,
			request = function()
				C_Spell.RequestLoadSpellData(id)
			end,
		}
	end

	local classes = {}
	for _, entry in ipairs(ns.TRACKED_ABILITIES or {}) do
		if entry.class then
			classes[entry.class] = true
		end
	end
	for _, list in ipairs({
		ns.BUFF_DUTY_SPELLS or {},
		ns.BUFF_DUTY_SELF_SPELLS or {},
		ns.BUFF_DUTY_WEAPON_ENCHANTS or {},
	}) do
		for _, row in ipairs(list) do
			if row.class then
				classes[row.class] = true
			end
		end
	end
	for _, token in ipairs(SortedKeys(classes)) do
		rows[#rows + 1] = {
			constant = token,
			kind = "class",
			id = token,
			lookup = function()
				return LOCALIZED_CLASS_NAMES_MALE[token]
			end,
		}
	end

	local durations =
		{ { "D_SECONDS", 1 }, { "D_SECONDS", 2 }, { "D_SECONDS", 15 }, { "D_MINUTES", 120 }, { "D_HOURS", 7200 } }
	for _, duration in ipairs(durations) do
		local seconds = duration[2]
		rows[#rows + 1] = {
			constant = duration[1],
			kind = "globalString",
			id = seconds,
			lookup = function()
				return ns.FormatDuration(seconds)
			end,
		}
	end

	for _, constant in ipairs({
		"UNITNAME_TITLE_PET",
		"UNITNAME_TITLE_MINION",
		"UNITNAME_TITLE_GUARDIAN",
		"UNITNAME_TITLE_CREATION",
		"UNITNAME_TITLE_CHARM",
		"UNITNAME_TITLE_COMPANION",
		"GROUP",
		"GROUP_NUMBER",
		"INVTYPE_WEAPONMAINHAND",
		"INVTYPE_WEAPONOFFHAND",
		"ERR_NOT_IN_COMBAT",
		"SPELL_FAILED_AURA_BOUNCED",
	}) do
		rows[#rows + 1] = UiLabel(constant)
	end

	for _, emote in ipairs(ns.Data.EMOTES) do
		local token = emote.token
		rows[#rows + 1] = {
			constant = token,
			kind = "emote",
			id = token,
			lookup = function()
				return EmoteCommand(token)
			end,
		}
	end
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- A macro body's ceiling, measured in bytes with #body, as the Style Guide's Message Length rule asks.
local MACRO_MAX_LENGTH = 255

-- The longest name a character can have, in letters.
local CHARACTER_NAME_MAX_LETTERS = 12

--[[
    Every whisper and macro Good to Go sends or writes, for the Localization tab's
    Message Length report, built at report time through the add-on's own
    builders with the longest names this client's data holds in this locale.
    Returns rows of { label, ceiling, text } and a list of notes. The ceiling
    is in bytes, so the overflow canary is the widest-encoding locale, usually
    ruRU.

    The longest link is the longest of ns.GetBuffLink over every trigger live
    on this client, the same link the thank-you whisper carries; Good News
    links the cast id, so its longest is taken over the triggers it whispers
    for, by cast id. An item link is only as long as its cached name, so items
    not loaded yet are counted into a note.

    Buff Duty's ask for another class's buff, said to the group or
    whispered, is built for every raid-wide buff the window counts, and the
    longest is kept.

    Buff Duty's Return the Favor buttons cast through a macro naming the
    stranger, one per buff you can give right now, built by ns.BuffDuty's
    own SingleIcon with your top rank's cast text and a 12-letter name on your
    realm.
]]
ns.DIAGNOSTIC_MESSAGES = function()
	local longestLink, longestGivenLink, unloaded = "", "", 0
	for _, entry in ipairs(ns.TRACKED_ABILITIES or {}) do
		for _, trigger in ipairs(entry.triggers or {}) do
			local watched = trigger.aura or trigger.spell
			if C_Spell.DoesSpellExist(trigger.spell) or C_Spell.DoesSpellExist(watched) then
				if trigger.item and not select(2, C_Item.GetItemInfo(trigger.item)) then
					unloaded = unloaded + 1
				end
				local link = ns.GetBuffLink({ itemId = trigger.item }, watched)
				if #link > #longestLink then
					longestLink = link
				end
				if ns.GetGivenEntry(trigger.spell) then
					local givenLink = ns.GetBuffLink({ itemId = trigger.item }, trigger.spell)
					if #givenLink > #longestGivenLink then
						longestGivenLink = givenLink
					end
				end
			end
		end
	end

	-- Every duration under a minute is tried: in a Slavic locale the plural form, not the count, decides the width.
	local goodNews = ""
	for seconds = 1, 59 do
		local text = ns:BuildGoodNewsMessage(longestGivenLink, seconds)
		if #text > #goodNews then
			goodNews = text
		end
	end

	local rows = {
		{
			label = "Thank-you whisper",
			ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
			text = ns:BuildAnnounceMessage("MESSAGE_WHISPER_THANKS", longestLink),
		},
		{
			label = "Good News whisper",
			ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
			text = goodNews,
		},
	}

	local profile = ns.db and ns.db.global
	for _, button in ipairs(ns.Data.THANK_YOU_BUTTONS) do
		local config = profile and profile[button.profileKey]
		local message = config and config.message
		if type(message) == "string" and message ~= "" then
			rows[#rows + 1] = {
				label = "Thank You whisper (" .. button.command .. ")",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = message,
			}
		end
	end
	for _, button in ipairs(ns.Data.THANK_YOU_BUTTONS) do
		rows[#rows + 1] = {
			label = "Thank You macro (" .. button.macroName .. ")",
			ceiling = MACRO_MAX_LENGTH,
			text = button.command,
		}
	end

	local notes = {}
	local BW = ns.BuffDuty
	if BW and BW.entries then
		local longestAsk
		-- the longest names list an ask can carry: as many as it names, each at the game's 12-letter limit
		local longestNames = {}
		for i = 1, ns.BUFF_ASK_MAX_NAMES do
			longestNames[i] = string.rep("W", 12)
		end
		for _, entry in ipairs(BW.entries) do
			local row = entry.row
			if row.group and not row.exclusive then
				local linkId = entry.ids[#entry.ids]
				local link = ns.GetSpellLink(linkId) or C_Spell.GetSpellName(linkId) or ""
				local ask = ns:BuildBuffRequestMessage(longestNames, #longestNames, link)
				if not longestAsk or #ask > #longestAsk then
					longestAsk = ask
				end
			end
		end
		if longestAsk then
			rows[#rows + 1] = {
				label = "Buff Duty ask for a buff",
				ceiling = ns.CHAT_MESSAGE_MAX_LENGTH,
				text = longestAsk,
			}
		end
	end
	if BW and BW.SingleIcon then
		local realm = _G.GetNormalizedRealmName and _G.GetNormalizedRealmName() or "Realm"
		local fullName = string.rep("W", CHARACTER_NAME_MAX_LETTERS) .. "-" .. tostring(realm)
		for _, buff in ipairs(BW.buffs) do
			if buff.singleName then
				local icon = BW.SingleIcon(buff, nil, nil, fullName, fullName)
				rows[#rows + 1] = {
					label = "Buff Duty favor macro (" .. buff.singleName .. ")",
					ceiling = MACRO_MAX_LENGTH,
					text = icon and icon.macrotext or "",
				}
			end
		end
		if #BW.buffs == 0 then
			notes[#notes + 1] = "No Buff Duty buff is castable right now, so no favor macro was built."
		end
		notes[#notes + 1] =
			"A character name in a non-Latin script takes 2 or 3 bytes a letter, so a favor macro can run longer than shown."
	end
	if unloaded > 0 then
		notes[#notes + 1] = string.format("%d items not loaded yet; the longest link may be understated.", unloaded)
	end
	return rows, notes
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per data file, and one report row per entry on the Data tab
    (Diagnostics/Options-Diagnostics.lua). Each entry's label is the table-name
    part of its file name, so ns.DataSourceFileName can name the file this
    client's folder built. Each source names the static table on ns and its kind,
    and reaches its ids through collect(tbl), which returns { id, key, row }
    entries. dataColumns carries the shipped row's own values as
    { header, getter(key, row) }, so the export sets what the file says beside
    what the client says.
]]
local function TrackedCollector(kind)
	return function(entries)
		local found = {}
		for index, entry in ipairs(entries) do
			for _, trigger in ipairs(entry.triggers or {}) do
				local roles = kind == "item" and { item = trigger.item }
					or { cast = trigger.spell, aura = trigger.aura }
				for role, id in pairs(roles) do
					found[#found + 1] =
						{ id = id, key = index, row = { entry = entry, trigger = trigger, role = role } }
				end
			end
		end
		return found
	end
end

local function EntryField(field)
	return function(_, row)
		return row.entry[field]
	end
end

local function BuffRowField(field)
	return function(_, row)
		return row.row[field]
	end
end

local function FoundField(field)
	return function(_, row)
		return row[field]
	end
end

-- Single-target ranks are { id, level learned }; group ranks are bare ids.
local function CollectBuffDuty(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, rank in ipairs(row.single or {}) do
			found[#found + 1] = { id = rank[1], key = index, row = { row = row, role = "single", level = rank[2] } }
		end
		for _, id in ipairs(row.group or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row, role = "group" } }
		end
		for _, id in ipairs(row.greater or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row, role = "greater" } }
		end
	end
	return found
end

-- Self buffs: every rank, { id, level learned }.
local function CollectSelfBuffs(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, rank in ipairs(row.ranks or {}) do
			found[#found + 1] = { id = rank[1], key = index, row = { row = row, level = rank[2] } }
		end
	end
	return found
end

-- A rank's enchant id, or its list of them (TBC's Rockbiter, one per weapon speed).
local function EnchantText(enchant)
	if type(enchant) == "table" then
		return table.concat(enchant, " ")
	end
	return enchant
end

--[[
    Weapon enchants: an imbue's ranks are spells, a poison's items; `kind`
    picks which, and a row of the other kind adds nothing. A rank with no
    enchant id shows a blank DATA_ENCHANT_ID: Buff Duty can't tell it's
    on a weapon, and keeps offering it.
]]
local function CollectWeaponEnchants(kind)
	return function(rows)
		local found = {}
		for index, row in ipairs(rows) do
			local ranks
			if kind == "item" then
				ranks = row.items
			else
				ranks = row.ranks
			end
			for _, rank in ipairs(ranks or {}) do
				found[#found + 1] = {
					id = rank[1],
					key = index,
					row = { row = row, level = rank[2], enchant = EnchantText(rank[3]) },
				}
			end
		end
		return found
	end
end

-- Weapon items: { item id, level required, enchant id, weapon types, kind, item level }; a blank DATA_ENCHANT_ID is a missing enchant id.
-- A weapon item's zones as one cell, "instances 585 580; uiMaps 1957", or nil for an item that works anywhere.
local function ZonesText(zones)
	if not zones then
		return nil
	end
	local parts = {}
	for _, kind in ipairs({ "instances", "uiMaps" }) do
		if zones[kind] then
			parts[#parts + 1] = kind .. " " .. table.concat(zones[kind], " ")
		end
	end
	return table.concat(parts, "; ")
end

local function CollectWeaponItems(rows)
	local found = {}
	for index, row in ipairs(rows) do
		found[#found + 1] = {
			id = row[1],
			key = index,
			row = {
				level = row[2],
				enchant = row[3],
				types = row[4],
				kind = row[5],
				itemLevel = row[6],
				zones = ZonesText(row[7]),
			},
		}
	end
	return found
end

-- The Soulstone: its Create Soulstone ranks and its auras as spells, its stones as items.
local function CollectSoulstone(kind)
	return function(stone)
		local found = {}
		if kind == "item" then
			for _, id in ipairs(stone.items or {}) do
				found[#found + 1] = { id = id, key = id, row = { role = "stone" } }
			end
			return found
		end
		for _, rank in ipairs(stone.create or {}) do
			found[#found + 1] = { id = rank[1], key = rank[1], row = { role = "create", level = rank[2] } }
		end
		for _, id in ipairs(stone.auras or {}) do
			found[#found + 1] = { id = id, key = id, row = { role = "aura" } }
		end
		return found
	end
end

-- The Buff Key's resurrections: bare rank ids, one row per class.
local function CollectResurrections(rows)
	local found = {}
	for index, row in ipairs(rows) do
		for _, id in ipairs(row.ranks or {}) do
			found[#found + 1] = { id = id, key = index, row = { row = row } }
		end
	end
	return found
end

-- The pet icons' summoning spells: Call Pet for beasts, and one per demon by NPC id.
local function CollectPetIcons(icons)
	local found = {}
	if icons.beast then
		found[#found + 1] = { id = icons.beast, key = "beast", row = { npc = "" } }
	end
	for npc, spell in pairs(icons.demons or {}) do
		found[#found + 1] = { id = spell, key = npc, row = { npc = npc } }
	end
	return found
end

-- Every spell id a Buff Duty data table names, for the event log's filter above.
local buffDutySpells

function IsBuffDutySpell(id)
	if not buffDutySpells then
		buffDutySpells = {}
		for _, source in ipairs({
			{ ns.BUFF_DUTY_SPELLS, CollectBuffDuty },
			{ ns.BUFF_DUTY_SELF_SPELLS, CollectSelfBuffs },
			{ ns.BUFF_DUTY_WEAPON_ENCHANTS, CollectWeaponEnchants("spell") },
			{ ns.BUFF_DUTY_SOULSTONE, CollectSoulstone("spell") },
			{ ns.BUFF_DUTY_RESURRECTIONS, CollectResurrections },
		}) do
			if type(source[1]) == "table" then
				for _, found in ipairs(source[2](source[1])) do
					buffDutySpells[found.id] = true
				end
			end
		end
	end
	return buffDutySpells[id] == true
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	-- { label, sources = { { table, kind, collect, dataColumns } } }
	{
		label = "Tracked-Abilities",
		sources = {
			{
				table = "TRACKED_ABILITIES",
				kind = "spell",
				collect = TrackedCollector("spell"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_TYPE", EntryField("type") },
					{ "DATA_DETECT", EntryField("detect") },
					{ "DATA_CLASS", EntryField("class") },
					{ "DATA_RECEIVED", EntryField("received") },
					{ "DATA_GIVEN", EntryField("given") },
					{ "DATA_RECEIVABLE", EntryField("receivable") },
					{ "DATA_NO_DURATION", EntryField("noDuration") },
					{ "DATA_OPENED", EntryField("opened") },
				},
			},
			{
				table = "TRACKED_ABILITIES",
				kind = "item",
				collect = TrackedCollector("item"),
				dataColumns = {
					{
						"DATA_SPELL_ID",
						function(_, row)
							return row.trigger.spell
						end,
					},
					{ "DATA_TYPE", EntryField("type") },
				},
			},
		},
	},
	{
		label = "Game-IDs",
		sources = {
			{
				table = "GAME_IDS",
				kind = "spell",
				collect = function(ids)
					local found = {}
					for constant, id in pairs(ids) do
						found[#found + 1] = { id = id, key = constant, row = id }
					end
					return found
				end,
				dataColumns = {
					{
						"DATA_CONSTANT",
						function(key)
							return key
						end,
					},
				},
			},
			-- Texture file IDs, which no client API looks up, so the report counts them.
			{ table = "THANK_YOU_MACRO_ICONS", kind = "other" },
		},
	},
	{
		label = "Buff-Duty-Spells",
		sources = {
			{
				table = "BUFF_DUTY_SPELLS",
				kind = "spell",
				collect = CollectBuffDuty,
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_EXCLUSIVE", BuffRowField("exclusive") },
					{ "DATA_MANA_ONLY", BuffRowField("manaOnly") },
					{ "DATA_NO_CASTERS", BuffRowField("noCasters") },
					{ "DATA_DEFAULT", BuffRowField("default") },
				},
			},
			{
				table = "BUFF_DUTY_SELF_SPELLS",
				kind = "spell",
				collect = CollectSelfBuffs,
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_EXCLUSIVE", BuffRowField("exclusive") },
					{ "DATA_DEFAULT", BuffRowField("default") },
				},
			},
			{
				table = "BUFF_DUTY_WEAPON_ENCHANTS",
				kind = "spell",
				collect = CollectWeaponEnchants("spell"),
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
				},
			},
			{
				table = "BUFF_DUTY_WEAPON_ENCHANTS",
				kind = "item",
				collect = CollectWeaponEnchants("item"),
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_CLASS", BuffRowField("class") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
				},
			},
			-- Which hands each class is asked about: class tokens, no ids, so the report counts them.
			{ table = "BUFF_DUTY_WEAPON_HANDS", kind = "other" },
			{
				table = "BUFF_DUTY_WEAPON_ITEMS",
				kind = "item",
				collect = CollectWeaponItems,
				dataColumns = {
					{ "DATA_LEVEL", FoundField("level") },
					{ "DATA_ENCHANT_ID", FoundField("enchant") },
					{ "DATA_WEAPON_TYPES", FoundField("types") },
					{ "DATA_KIND", FoundField("kind") },
					{ "DATA_ITEM_LEVEL", FoundField("itemLevel") },
					{ "DATA_ZONES", FoundField("zones") },
				},
			},
			{
				table = "BUFF_DUTY_SOULSTONE",
				kind = "spell",
				collect = CollectSoulstone("spell"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
					{ "DATA_LEVEL", FoundField("level") },
				},
			},
			{
				table = "BUFF_DUTY_SOULSTONE",
				kind = "item",
				collect = CollectSoulstone("item"),
				dataColumns = {
					{ "DATA_ROLE", FoundField("role") },
				},
			},
			{
				table = "BUFF_DUTY_RESURRECTIONS",
				kind = "spell",
				collect = CollectResurrections,
				dataColumns = {
					{ "DATA_CLASS", BuffRowField("class") },
				},
			},
			{
				table = "BUFF_DUTY_PET_ICONS",
				kind = "spell",
				collect = CollectPetIcons,
				dataColumns = {
					{ "DATA_NPC_ID", FoundField("npc") },
				},
			},
		},
	},
})
