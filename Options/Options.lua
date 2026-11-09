local _, ns = ...
local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

local REGISTRY = ns.OPTIONS_REGISTRY

--[[
    Registration is deferred to ns.RegisterOptionsPanels, called once from
    Features/Core.lua after AceDB creates ns.db: the Profiles panel's tree label
    is read from the stock AceDBOptions-3.0 table, which needs the database.

    One panel per feature directly under the root, in the root panel's Features
    order (ns.FEATURE_GROUPS, left to right then down), each followed by its
    sub-panels:

      Good to Go    (welcome, mini-map, Features, Key Bindings, /Commands)
        Buff Duty               Group Buffs, Self-Buffs, Weapon Buffs
        Restocker
        Enhanced Spellbook
        Consumable Macros       Class & Race, Ignore List
        Rank Watch              Reported Ranks, Ignored Players (where the flavor has ranks)
        Inventory Report
        Readiness Report
        Profiles, Feedback & Support, Diagnostic Tools

    Child-panel order is the order of the AddToBlizOptions calls. The third
    argument is the parent: the root's display name by default, or a child's
    category ID to nest a panel a level deeper. AceConfigDialog maps only root
    names to IDs, so a nested panel passes the ID its parent's registration
    returned; the Settings panel finds a category at any depth by ID and
    indents each level.

    Every category ID is kept by registry key, so ns:OpenOptionsPanel can open
    any panel directly; a title lookup fails wherever the ID is a number.
]]
local function RegisterChild(registryKey, builder, displayName, parentID)
	AceConfig:RegisterOptionsTable(REGISTRY[registryKey], builder)
	local _, categoryID =
		AceConfigDialog:AddToBlizOptions(REGISTRY[registryKey], displayName, parentID or L["ADDON_TITLE"])
	ns.optionsFrames.categories[registryKey] = categoryID
	return categoryID
end

--[[
    Each panel with a tracked list gets it as a sub-panel: Group Buffs under
    Buff Duty, Reported Ranks under Rank Watch.
    Sub-panels and panels whose lists exist only after login register their
    builder function, not a built table, so each is rebuilt on open.
]]
local function RegisterBuffDutyPanels()
	local buffDutyID = RegisterChild("BuffDuty", ns.BuildBuffDutyOptions, L["TAB_BUFF_DUTY"])
	RegisterChild("BuffDutyBuffs", ns.BuildBuffDutyBuffsOptions, L["BUFF_DUTY_TRACKED_HEADER"], buffDutyID)
	RegisterChild("BuffDutySelfBuffs", ns.BuildBuffDutySelfBuffsOptions, L["BUFF_DUTY_SELF_HEADER"], buffDutyID)
	RegisterChild(
		"BuffDutyWeaponBuffs",
		ns.BuildBuffDutyWeaponBuffsOptions,
		L["BUFF_DUTY_WEAPON_PANEL_HEADER"],
		buffDutyID
	)
end

--[[
    Consumable Macros -- every macro setting, led by its on/off switch, with
    Class & Race and the Ignore List nested under it: the list only says what
    the macros may offer. The Ignore List registers its builder function, not
    a built table, so it never renders a stale list.
]]
local function RegisterMacrosPanels()
	local macrosID = RegisterChild("Macros", ns.BuildMacrosOptions, L["TAB_CONSUMABLE_MACROS"])
	RegisterChild("ClassRace", ns.BuildClassRaceOptions, L["TAB_CLASS_RACE"], macrosID)
	RegisterChild("IgnoreList", ns.BuildIgnoreListOptions, L["TAB_IGNORE_LIST"], macrosID)

	--[[
	    Seed the Ignore List tree's width (ns.OPTIONS_TREE_WIDTH). AceGUI's
	    SetStatusTable fills treewidth in only when the key is absent -- so
	    seeding it here wins, while a player dragging the splitter still
	    overwrites it from then on.
	]]
	local ignoreStatus = AceConfigDialog:GetStatusTable(REGISTRY.IgnoreList)
	ignoreStatus.groups = ignoreStatus.groups or {}
	ignoreStatus.groups.treewidth = ns.OPTIONS_TREE_WIDTH
end

--[[
    Rank Watch, where its TOC loads it (every flavor with ranks to compare), with its Reported Ranks and
    Ignored Players under it. Reported Ranks is a tree of classes, opened on the player's own and seeded with
    the shared tree width, the way the Ignore List seeds its own; a player dragging the splitter or picking a
    class overwrites either from then on.
]]
local function RegisterRankWatchPanels()
	if not ns.BuildRankWatchOptions then
		return
	end
	local rankWatchID = RegisterChild("RankWatch", ns.BuildRankWatchOptions, L["TAB_RANK_WATCH"])
	RegisterChild("RankWatchTracked", ns.BuildRankWatchTrackedOptions, L["RANK_WATCH_TRACKED_HEADER"], rankWatchID)
	RegisterChild("RankWatchIgnored", ns.BuildRankWatchIgnoredOptions, L["RANK_WATCH_IGNORED_HEADER"], rankWatchID)

	local trackedStatus = AceConfigDialog:GetStatusTable(REGISTRY.RankWatchTracked)
	trackedStatus.groups = trackedStatus.groups or {}
	trackedStatus.groups.treewidth = trackedStatus.groups.treewidth or ns.OPTIONS_TREE_WIDTH
	trackedStatus.groups.selected = trackedStatus.groups.selected or select(2, UnitClass("player"))
end

function ns.RegisterOptionsPanels()
	AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions)
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(REGISTRY.General, L["ADDON_TITLE"])
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID, categories = {} }

	RegisterBuffDutyPanels()
	RegisterChild("Restocker", ns.BuildRestockerOptions, L["TAB_RESTOCKER"])
	RegisterChild("Spellbook", ns.BuildSpellbookOptions, L["TAB_ENHANCED_SPELLBOOK"])
	RegisterMacrosPanels()
	RegisterRankWatchPanels()
	-- Named by the tooltip block's own title, so the panel and the tooltip cannot name it two ways.
	RegisterChild("InventoryReport", ns.BuildInventoryReportOptions, L["INVENTORY_REPORT_TITLE"])
	RegisterChild("ReadinessReport", ns.BuildReadinessReportOptions, L["TAB_READINESS_REPORT"])

	--[[
	    Profiles panel: the stock AceDBOptions-3.0 table, unmodified. Its display
	    name comes already-localized from AceDBOptions, read off the built table
	    so we neither hardcode it nor add a locale key for a stock widget.
	]]
	local profilesOptions = ns.BuildProfilesOptions()
	RegisterChild("Profiles", profilesOptions, profilesOptions.name)

	RegisterChild("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	--[[
	    Diagnostic Tools last so it sits at the bottom of the tree. Registered as
	    the builder, so the tabs come and go with the enable toggle; its display
	    name is a plain English string, never a locale key.
	]]
	RegisterChild("Diagnostics", ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

--[[
    Opens the root panel, or the panel named by an ns.OPTIONS_REGISTRY key.
    Combat first: Blizzard's Settings panel is protected in combat, so every
    route below is blocked and the player would get an ADDON_ACTION_BLOCKED
    error naming the add-on instead of an answer. The gate sits at this single
    entry point, so the slash command and the mini-map button's Shift +
    Middle-Click answer identically. It returns -- never queues the open for
    when combat ends.
]]
function ns:OpenOptionsPanel(panel)
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end
	if not ns.optionsFrames then
		return
	end
	local categoryID = ns.optionsFrames.categories[panel] or ns.optionsFrames.categoryID
	if Settings and Settings.OpenToCategory and categoryID then
		Settings.OpenToCategory(categoryID)
		return
	end
	AceConfigDialog:Open(REGISTRY[panel] or REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

-- "/gtg ignore Name" hands the rest to Rank Watch where it loads (a README-Notes exception); anything else opens the panel.
SLASH_GOODTOGO1 = "/gtg"
SlashCmdList["GOODTOGO"] = function(message)
	local command, rest = strtrim(message or ""):match("^(%S*)%s*(.-)$")
	if command:lower() == "ignore" and ns.IgnoreRankWatchPlayer then
		ns.IgnoreRankWatchPlayer(rest)
		return
	end
	ns:OpenOptionsPanel()
end

--[[
    The Restock List's own command, registered here with the options command
    rather than inside the feature: slash registration is this file's job, and
    the handler stays with the feature that answers it.
]]
SLASH_GOODTOGORESTOCK1 = "/restock"
SlashCmdList["GOODTOGORESTOCK"] = function(message)
	ns.HandleRestockerCommand(message)
end
