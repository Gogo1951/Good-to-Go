local _, ns = ...
local L = ns.L

local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

--[[
    Registration waits for ns.db (ns.RegisterOptionsPanels, from Core.lua): the
    Profiles panel's tree label is read from the AceDBOptions table, which needs
    it. Tree order is Kit.RegisterPanel call order; each panel registers its
    builder, not a built table, so it is rebuilt on every repaint.
]]
local function RegisterBuffDutyPanels()
	Kit.RegisterPanel("BuffDuty", ns.BuildBuffDutyOptions, L["TAB_BUFF_DUTY"])
	Kit.RegisterPanel("BuffDutyBuffs", ns.BuildBuffDutyBuffsOptions, L["BUFF_DUTY_TRACKED_HEADER"], "BuffDuty")
	Kit.RegisterPanel("BuffDutySelfBuffs", ns.BuildBuffDutySelfBuffsOptions, L["BUFF_DUTY_SELF_HEADER"], "BuffDuty")
	-- A tree of classes, reopening on the player's own (or the first class, for one with none listed).
	Kit.PrepareTree("BuffDutySelfBuffs", function()
		return select(2, UnitClass("player"))
	end)
	-- A page per category, in the window's order.
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

local function RegisterMacrosPanels()
	Kit.RegisterPanel("Macros", ns.BuildMacrosOptions, L["TAB_CONSUMABLE_MACROS"])
	Kit.RegisterPanel("FoodDrinks", ns.BuildFoodDrinksOptions, L["OPTIONS_FOOD_WATER_HEADER"], "Macros")
	Kit.RegisterPanel("PotionsManaGems", ns.BuildPotionsManaGemsOptions, L["TAB_POTIONS_MANA_GEMS"], "Macros")
	Kit.RegisterPanel("Bandages", ns.BuildBandagesOptions, L["TAB_BANDAGES"], "Macros")
	Kit.RegisterPanel("Healthstone", ns.BuildHealthstoneOptions, L["TAB_HEALTHSTONE"], "Macros")
	Kit.RegisterPanel("Explosives", ns.BuildExplosivesOptions, L["OPTIONS_EXPLOSIVES_HEADER"], "Macros")
	Kit.RegisterPanel("FishingLure", ns.BuildFishingLureOptions, L["TAB_FISHING_LURE"], "Macros")
	Kit.RegisterPanel("ClassMacros", ns.BuildClassMacrosOptions, L["TAB_CLASS_MACROS"], "Macros")
	Kit.RegisterPanel("IgnoreList", ns.BuildIgnoreListOptions, L["TAB_IGNORE_LIST"], "Macros")
	Kit.PrepareTree("IgnoreList", function()
		return ns.db:GetCurrentProfile()
	end)
end

-- Only where Rank Watch loads (every flavor with ranks to compare).
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
    Ability Alerts sits under Enhanced Spellbook: the level-up prints read its
    What's Next? rows. Both load only with Rank Watch (every flavor but Mists).
]]
local function RegisterSpellbookPanels()
	Kit.RegisterPanel("Spellbook", ns.BuildSpellbookOptions, L["TAB_ENHANCED_SPELLBOOK"])
	if ns.BuildAbilityAlertsOptions then
		Kit.RegisterPanel("AbilityAlerts", ns.BuildAbilityAlertsOptions, L["RANK_WATCH_LEVEL_UP_HEADER"], "Spellbook")
	end
end

function ns.RegisterOptionsPanels()
	Kit.RegisterPanel("General", ns.BuildGeneralOptions, L["ADDON_TITLE"])

	-- In ns.FEATURES order, as the Features switches and the menu list them.
	RegisterBuffDutyPanels()
	Kit.RegisterPanel("Restocker", ns.BuildRestockerOptions, L["TAB_RESTOCKER"])
	RegisterSpellbookPanels()
	RegisterMacrosPanels()
	RegisterRankWatchPanels()
	-- Named by the tooltip block's own title, so the panel and the tooltip cannot name it two ways.
	Kit.RegisterPanel("InventoryReport", ns.BuildInventoryReportOptions, L["INVENTORY_REPORT_TITLE"])
	Kit.RegisterPanel("ReadinessReport", ns.BuildReadinessReportOptions, L["TAB_READINESS_REPORT"])
	Kit.RegisterPanel("CurrencyReplenish", ns.BuildCurrencyReplenishOptions, L["TAB_CURRENCY_REPLENISH"])

	-- The name comes localized from AceDBOptions, read off one built table.
	Kit.RegisterPanel("Profiles", ns.BuildProfilesOptions, ns.BuildProfilesOptions().name)

	Kit.RegisterPanel("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	-- Last, at the bottom of the tree. Its name is plain English, never a locale key.
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

-- Slash registration is this file's job; the handler stays with the feature that answers it.
SLASH_GOODTOGORESTOCK1 = "/restock"
SlashCmdList["GOODTOGORESTOCK"] = function(message)
	ns.HandleRestockerCommand(message)
end
