local _, ns = ...
local L = ns.L

local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

--[[
    Registration is deferred to ns.RegisterOptionsPanels, called once from
    Features/Core.lua after AceDB creates ns.db: the Profiles panel's tree label
    is read from the stock AceDBOptions-3.0 table, which needs the database.

    One panel per feature directly under the root, in the root panel's Features
    order (ns.FEATURES), each followed by its sub-panels:

      Good to Go    (welcome, mini-map, Features, Key Bindings, /Commands)
        Buff Duty               Group Buffs, Self-Buffs, Well Fed, Weapon Buffs, Scrolls,
                                Flasks or Elixirs, Other Buffs
        Restocker
        Enhanced Spellbook      Ability Alerts While Leveling (where Rank Watch loads)
        Consumable Macros       Food & Drinks, Potions & Mana Gems, Bandages,
                                Healthstone, Explosives, Class Macros, Ignore List
        Rank Watch              Reported Ranks, Ignored Players (where the flavor has ranks)
        Inventory Report
        Readiness Report
        Profiles, Feedback & Support, Diagnostic Tools

    Child-panel order is the order of the Kit.RegisterPanel calls, which keeps
    every panel's category ID by registry key, so ns:OpenOptionsPanel (the
    kit's) opens any panel directly. A sub-panel names its parent's key. Each
    panel registers its builder function, not a built table, so it is rebuilt
    on every repaint.
]]
local function RegisterBuffDutyPanels()
	Kit.RegisterPanel("BuffDuty", ns.BuildBuffDutyOptions, L["TAB_BUFF_DUTY"])
	Kit.RegisterPanel("BuffDutyBuffs", ns.BuildBuffDutyBuffsOptions, L["BUFF_DUTY_TRACKED_HEADER"], "BuffDuty")
	Kit.RegisterPanel("BuffDutySelfBuffs", ns.BuildBuffDutySelfBuffsOptions, L["BUFF_DUTY_SELF_HEADER"], "BuffDuty")
	-- A tree of classes, reopening on the player's own (or the first class, for one with none listed).
	Kit.PrepareTree("BuffDutySelfBuffs", function()
		return select(2, UnitClass("player"))
	end)
	-- Then a page per category, in the window's order (Options-Buff-Duty-Consumables.lua).
	Kit.RegisterPanel("BuffDutyFood", ns.BuildBuffDutyFoodOptions, ns.BuffDuty.WellFedLabel(), "BuffDuty")
	Kit.RegisterPanel(
		"BuffDutyWeaponBuffs",
		ns.BuildBuffDutyWeaponBuffsOptions,
		L["BUFF_DUTY_WEAPON_PANEL_HEADER"],
		"BuffDuty"
	)
	Kit.RegisterPanel("BuffDutyScrolls", ns.BuildBuffDutyScrollsOptions, L["BUFF_DUTY_SCROLLS"], "BuffDuty")
	Kit.RegisterPanel("BuffDutyElixirs", ns.BuildBuffDutyElixirsOptions, L["BUFF_DUTY_ROW_ELIXIRS"], "BuffDuty")
	Kit.RegisterPanel("BuffDutyOther", ns.BuildBuffDutyOtherOptions, L["BUFF_DUTY_ROW_OTHER"], "BuffDuty")
end

--[[
    Consumable Macros -- its on/off switch and which macros to create, with a
    page per macro family nested under it (Food & Drinks, Potions & Mana Gems,
    Bandages, Healthstone, Explosives, Class Macros), then the Ignore List,
    which only says what the macros may offer. The Ignore List's tree takes the kit's 176-point
    sidebar (Kit.PrepareTree) and reopens on the character being played.
]]
local function RegisterMacrosPanels()
	Kit.RegisterPanel("Macros", ns.BuildMacrosOptions, L["TAB_CONSUMABLE_MACROS"])
	Kit.RegisterPanel("FoodDrinks", ns.BuildFoodDrinksOptions, L["OPTIONS_FOOD_WATER_HEADER"], "Macros")
	Kit.RegisterPanel("PotionsManaGems", ns.BuildPotionsManaGemsOptions, L["TAB_POTIONS_MANA_GEMS"], "Macros")
	Kit.RegisterPanel("Bandages", ns.BuildBandagesOptions, L["TAB_BANDAGES"], "Macros")
	Kit.RegisterPanel("Healthstone", ns.BuildHealthstoneOptions, L["TAB_HEALTHSTONE"], "Macros")
	Kit.RegisterPanel("Explosives", ns.BuildExplosivesOptions, L["OPTIONS_EXPLOSIVES_HEADER"], "Macros")
	Kit.RegisterPanel("ClassMacros", ns.BuildClassMacrosOptions, L["TAB_CLASS_MACROS"], "Macros")
	Kit.RegisterPanel("IgnoreList", ns.BuildIgnoreListOptions, L["TAB_IGNORE_LIST"], "Macros")
	Kit.PrepareTree("IgnoreList", function()
		return ns.db:GetCurrentProfile()
	end)
end

--[[
    Rank Watch, where its TOC loads it (every flavor with ranks to compare), with its Reported Ranks and
    Ignored Players under it. Reported Ranks is a tree of classes on the shared tree width, reopening on the
    player's own class every time the panel opens (Kit.PrepareTree).
]]
local function RegisterRankWatchPanels()
	if not ns.BuildRankWatchOptions then
		return
	end
	Kit.RegisterPanel("RankWatch", ns.BuildRankWatchOptions, L["TAB_RANK_WATCH"])
	Kit.RegisterPanel("RankWatchTracked", ns.BuildRankWatchTrackedOptions, L["RANK_WATCH_TRACKED_HEADER"], "RankWatch")
	Kit.RegisterPanel("RankWatchIgnored", ns.BuildRankWatchIgnoredOptions, L["RANK_WATCH_IGNORED_HEADER"], "RankWatch")
	Kit.PrepareTree("RankWatchTracked", function()
		return select(2, UnitClass("player"))
	end)
end

--[[
    Enhanced Spellbook, with Ability Alerts While Leveling under it: the level-up prints read the Spellbook's
    What's Next? rows. Its files load with Rank Watch's (every flavor but Mists), so it registers only there.
]]
local function RegisterSpellbookPanels()
	Kit.RegisterPanel("Spellbook", ns.BuildSpellbookOptions, L["TAB_ENHANCED_SPELLBOOK"])
	if ns.BuildAbilityAlertsOptions then
		Kit.RegisterPanel("AbilityAlerts", ns.BuildAbilityAlertsOptions, L["RANK_WATCH_LEVEL_UP_HEADER"], "Spellbook")
	end
end

function ns.RegisterOptionsPanels()
	Kit.RegisterPanel("General", ns.BuildGeneralOptions, L["ADDON_TITLE"])

	-- The features in ns.FEATURES order (Options/Options-Feature-Switches.lua), as the Features switches and the menu list them.
	RegisterBuffDutyPanels()
	Kit.RegisterPanel("Restocker", ns.BuildRestockerOptions, L["TAB_RESTOCKER"])
	RegisterSpellbookPanels()
	RegisterMacrosPanels()
	RegisterRankWatchPanels()
	-- A feature with its own switch, so a page of its own. Named by the tooltip block's own title, so the panel and the tooltip cannot name it two ways.
	Kit.RegisterPanel("InventoryReport", ns.BuildInventoryReportOptions, L["INVENTORY_REPORT_TITLE"])
	Kit.RegisterPanel("ReadinessReport", ns.BuildReadinessReportOptions, L["TAB_READINESS_REPORT"])

	--[[
	    Profiles panel: the stock AceDBOptions-3.0 table, unmodified. Its display
	    name comes already-localized from AceDBOptions, read off one built table
	    so we neither hardcode it nor add a locale key for a stock widget.
	]]
	Kit.RegisterPanel("Profiles", ns.BuildProfilesOptions, ns.BuildProfilesOptions().name)

	Kit.RegisterPanel("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	--[[
	    Diagnostic Tools last so it sits at the bottom of the tree. Registered as
	    the builder, so the tabs come and go with the enable toggle; its display
	    name is a plain English string, never a locale key.
	]]
	Kit.RegisterPanel("Diagnostics", ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
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
