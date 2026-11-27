local ADDON_NAME, ns = ...

ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.Data = {}

local L = ns.L
local Data = ns.Data

--------------------------------------------------------------------------------
-- Identity
--------------------------------------------------------------------------------

ns.ADDON_TITLE = L["ADDON_TITLE"]

-- Must match every TOC's ## SavedVariables line.
ns.SAVED_VARIABLES_NAME = "GoodToGoDB"

--[[
    MIGRATION (remove after 2026-12-03): the table's name before the rename to
    Good to Go, listed second on every TOC's ## SavedVariables line.
]]
ns.OLD_SAVED_VARIABLES_NAME = "BagsBuffsButtonsDB"

--[[
    Add-ons that rewrite the same macros, or report every low rank twice, if
    both run. No migration and no end date: a player can turn the old add-on
    back on long after the settings import below is gone.
]]
ns.REPLACED_ADDONS = { "Consumable-Connoisseur", "Rank-Sentinel", "RankSentinel" }

--[[
    MIGRATION (remove after 2026-12-08): the add-ons Good to Go
    replaces whose settings Legacy-Migration.lua copies in, by folder.
]]
ns.LEGACY_ADDONS = {
	{ folder = "Consumable-Connoisseur", savedVariables = "ConnoisseurDB" },
	{ folder = "MacroSpellbook" },
	-- Rank Sentinel, under either folder name it has shipped with (Data.RANK_WATCH.STANDALONE_FOLDERS).
	{ folder = "Rank-Sentinel" },
	{ folder = "RankSentinel" },
}

--------------------------------------------------------------------------------
-- Brand Colors
--------------------------------------------------------------------------------

-- Raw hex; Utilities.lua derives the escapes, keeping Data files logic-free.
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names, Field Titles
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off (menus show Off in MUTED, never red)
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
	VALUE = "FFFF99", -- Light Yellow: What a Setting Is Set To, in a Menu
}

ns.SPELL_LINK_COLOR = "71D5FF" -- the client's own spell-link blue

--------------------------------------------------------------------------------
-- Class Colors
--------------------------------------------------------------------------------

ns.CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	MONK = "00FF96",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

--------------------------------------------------------------------------------
-- Sample Names
--------------------------------------------------------------------------------

-- Proper names, the same in every locale.
ns.SAMPLE_NAMES = {
	DRUID = "Aero",
	HUNTER = "Spek",
	MAGE = "Portalrico",
	PALADIN = "Aiek",
	PRIEST = "Katz",
	ROGUE = "Fathom",
	SHAMAN = "Moondragon",
	WARLOCK = "Greasy",
	WARRIOR = "Prima",
}

-- A hunter's pet by a proper name; a warlock's demon by the client's name for its family.
ns.SAMPLE_PET_NAME = "Fluffy"

--------------------------------------------------------------------------------
-- URLs
--------------------------------------------------------------------------------

ns.LINKS = {
	CURSEFORGE = "https://www.curseforge.com/wow/addons/good-to-go",
	GITHUB = "https://github.com/Gogo1951/Good-to-Go",
	DISCORD = "https://discord.gg/eh8hKq992Q",
	WAGO = "https://addons.wago.io/addons/good-to-go",
}

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

--[[
    SendChatMessage rejects a longer body outright, and the ceiling is bytes: a
    non-Latin locale spends 2-3 of them per character.
]]
ns.CHAT_MESSAGE_MAX_LENGTH = 255

--[[
    {rt1} Star, {rt2} Circle, {rt3} Diamond, {rt4} Triangle,
    {rt5} Moon, {rt6} Square, {rt7} Cross, {rt8} Skull
]]
ns.TARGET_MARKER = "{rt1}" -- Star

--[[
    The unit is unconfirmed (the macro box caps letters, chat caps bytes), so
    every guard measures #body in bytes, which holds under either reading.
    Never convert one to a character count. ruRU is the overflow canary.
]]
ns.MACRO_BODY_MAX_LENGTH = 255

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

-- Never localized, never built inline.
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME .. "_General",

	BuffDuty = ADDON_NAME .. "_BuffDuty",
	BuffDutyBuffs = ADDON_NAME .. "_BuffDutyBuffs",
	BuffDutySelfBuffs = ADDON_NAME .. "_BuffDutySelfBuffs",
	BuffDutyFood = ADDON_NAME .. "_BuffDutyFood",
	BuffDutyWeaponBuffs = ADDON_NAME .. "_BuffDutyWeaponBuffs",
	BuffDutyScrolls = ADDON_NAME .. "_BuffDutyScrolls",
	BuffDutyElixirs = ADDON_NAME .. "_BuffDutyElixirs",
	BuffDutyOther = ADDON_NAME .. "_BuffDutyOther",
	Restocker = ADDON_NAME .. "_Restocker",
	Spellbook = ADDON_NAME .. "_Spellbook",
	AbilityAlerts = ADDON_NAME .. "_AbilityAlerts",
	Macros = ADDON_NAME .. "_Macros",
	FoodDrinks = ADDON_NAME .. "_FoodDrinks",
	PotionsManaGems = ADDON_NAME .. "_PotionsManaGems",
	Bandages = ADDON_NAME .. "_Bandages",
	Healthstone = ADDON_NAME .. "_Healthstone",
	Explosives = ADDON_NAME .. "_Explosives",
	FishingLure = ADDON_NAME .. "_FishingLure",
	ClassMacros = ADDON_NAME .. "_ClassMacros",
	IgnoreList = ADDON_NAME .. "_IgnoreList",
	RankWatch = ADDON_NAME .. "_RankWatch",
	RankWatchTracked = ADDON_NAME .. "_RankWatchTracked",
	RankWatchIgnored = ADDON_NAME .. "_RankWatchIgnored",
	InventoryReport = ADDON_NAME .. "_InventoryReport",
	ReadinessReport = ADDON_NAME .. "_ReadinessReport",
	CurrencyReplenish = ADDON_NAME .. "_CurrencyReplenish",

	Profiles = ADDON_NAME .. "_Profiles",
	FeedbackSupport = ADDON_NAME .. "_FeedbackSupport",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Options Widgets
--------------------------------------------------------------------------------

-- Derived from ADDON_NAME so it can't collide with another add-on's widget.
ns.ICON_CHECKBOX_WIDGET_TYPE = ADDON_NAME .. "_IconCheckBox"

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

-- Interface\Icons\INV_Misc_QuestionMark
ns.QUESTION_MARK_ICON = 134400

-- The glyphs are white, tinted where they're used.
ns.ICON_ADDON = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Spellbook"
ns.TEXTURE_GEAR = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Gear"

-- White, tinted where it's used.
ns.TEXTURE_RANK_ARROW = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Rank-Arrow"

ns.ICON_RESTOCKER = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Restocker"

--------------------------------------------------------------------------------
-- Consumable Macros & Restocker
--------------------------------------------------------------------------------

-- The sections from here to Spellbook are Consumable Macros & Restocker's.

--------------------------------------------------------------------------------
-- Restock Window Colors
--------------------------------------------------------------------------------

--[[
    Red is kept for errors. A Keep amount the bags are short of is not one,
    so it is yellow: the brand gold's hex, held as a role of its own so the
    mark can change without the headings following it.
]]
ns.RESTOCKER_WINDOW_COLORS = {
	DASH_OFF = "7A7A7A", -- Gray: Settings That Are Off
	DASH_NOT_APPLICABLE = "474747", -- Dark Gray: Settings That Cannot Apply
	BANK_LABEL = "39D5FF", -- Sky Blue: The Bank Band's Name
	BANK_CAPTION = "8BC7D8", -- Soft Blue: Column Headings Under Bank
	MERCHANT_LABEL = "FF4FA3", -- Pink: The Merchant Band's Name
	MERCHANT_CAPTION = "D38EAF", -- Soft Pink: Column Headings Under Merchant
	REPUTATION_SET = "D99959", -- Amber: A Required Reputation
	KEEP_SHORT = "FFD100", -- Yellow: A Keep Amount the Bags Are Short Of, and the Orders Count Under the List
	ADD_NOTICE = "FF5A4E", -- Red: Why an Add Did Not Go Through, in the Add Box
	ROW_LABEL = "C7BDAD", -- Warm Gray: Unselected Types in the Category Pane
	ROW_COUNT = "858075", -- Dim Warm Gray: Their Counts, a Step Quieter
}

--------------------------------------------------------------------------------
-- Ignore List Scopes
--------------------------------------------------------------------------------

--[[
    Every other scope is an AceDB profile name, so the asterisks keep the
    Global list's key from colliding with one: no character's name can hold
    them.
]]
ns.IGNORE_SCOPE_GLOBAL = "**global**"

--------------------------------------------------------------------------------
-- Macro Configuration
--------------------------------------------------------------------------------

-- label: localized display name plugged into MESSAGE_NO_ITEM by GtGNoItem.
ns.MACRO_CONFIG = {
	["Bandage"] = { macro = ns.L["MACRO_BANDAGE"], label = ns.L["LABEL_BANDAGE"] },
	["Explosive"] = { macro = ns.L["MACRO_EXPLOSIVES"], label = ns.L["LABEL_EXPLOSIVE"] },
	["Food"] = { macro = ns.L["MACRO_FOOD"], label = ns.L["LABEL_FOOD"] },
	["Health Potion"] = { macro = ns.L["MACRO_HEALTH_POTION"], label = ns.L["LABEL_HEALTH_POTION"] },
	["Healthstone"] = { macro = ns.L["MACRO_HEALTHSTONE"], label = ns.L["LABEL_HEALTHSTONE"] },
	["Mana Gem"] = { macro = ns.L["MACRO_MANA_GEM"], label = ns.L["LABEL_MANA_GEM"] },
	["Mana Potion"] = { macro = ns.L["MACRO_MANA_POTION"], label = ns.L["LABEL_MANA_POTION"] },
	["Soulstone"] = { macro = ns.L["MACRO_SOULSTONE"], label = ns.L["LABEL_SOULSTONE"] },
	["Water"] = { macro = ns.L["MACRO_WATER"], label = ns.L["LABEL_WATER"] },
	["Feed Pet"] = { macro = ns.L["MACRO_FEED_PET"], label = ns.L["LABEL_PET_FOOD"] },
	["Poisons"] = { macro = ns.L["MACRO_POISONS"], label = ns.L["LABEL_POISON"] },
	-- No label: it skips a step it has nothing for, so it never prints MESSAGE_NO_ITEM.
	["Fishing Lure"] = { macro = ns.L["MACRO_FISHING_LURE"] },
}

--[[
    Ranked /use lines, so a press falls through to the next-best item once
    the best runs out mid-combat, where macros can't be rewritten. Only safe
    for categories whose items share one cooldown, so a press uses one item.
]]
ns.MULTI_USE_MAX_ITEMS = 3

ns.MULTI_USE_MACRO_TYPES = {
	["Health Potion"] = true,
	["Healthstone"] = true,
	["Mana Gem"] = true,
	["Mana Potion"] = true,
}

-- Free General macro slots left untouched for the player.
ns.MACRO_SLOT_CUSHION = 0

--------------------------------------------------------------------------------
-- DruidMacroHelper Integration
--------------------------------------------------------------------------------

ns.DRUID_MACRO_HELPER_TYPES = {
	["Health Potion"] = true,
	["Mana Potion"] = true,
	["Healthstone"] = true,
}

--[[
    From DruidMacroHelper's own example macros. MP skips the mana check: the
    whole point of a mana pot is that the druid is OOM.
]]
ns.DRUID_MACRO_HELPER_GUARDS = {
	["Health Potion"] = { "/dmh start", "/dmh cd pot" },
	["Healthstone"] = { "/dmh start", "/dmh cd hs" },
	["Mana Potion"] = { "/dmh stun gcd cd pot" },
}

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

--[[
    Fired from macro bodies by `/run GtGTip("key")`, beside
    ns.MISSING_SPELL_MESSAGE_IDS, resolved at print time. A key or spell the
    client lacks resolves to nil and the print is skipped, never naming a
    spell the player will never see.
]]
ns.TIP_MESSAGES = {
	noPetFood = ns.L["TIP_PET_NO_FOOD"],
	noHandPoison = ns.L["TIP_NO_HAND_POISON"],
}

--------------------------------------------------------------------------------
-- Group Contexts and Level Filters
--------------------------------------------------------------------------------

-- In the order every panel draws them; labels are GROUP_CONTEXT_<KEY>.
ns.GROUP_CONTEXTS = { "solo", "party", "raid", "battleground" }

-- It can only switch off a context the checkboxes leave on.
ns.LEVEL_FILTER_ORDER = { "any", "leveling", "maxlevel" }

--------------------------------------------------------------------------------
-- Restock Reminders
--------------------------------------------------------------------------------

--[[
    A mode rather than a boolean, so the option reads as a choice and a third
    level could be added without another setting.
]]
ns.REMINDER_SIMPLE = "simple"
ns.REMINDER_VERBOSE = "verbose"

--[[
    Percent of a row's Keep amount below which the reminders call it low; at
    or above it a row stays quiet. The merchant restock ignores it and buys
    every row to its full amount.
]]
ns.RESTOCK_LOW_THRESHOLDS = { 50, 60, 70, 80, 90, 100 }

-- Built from ADDON_NAME so renaming the add-on folder cannot break the path.
ns.RESTOCK_ALERT_SOUND = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Sounds\\Low-Battery.ogg"

--------------------------------------------------------------------------------
-- Gold Reserve
--------------------------------------------------------------------------------

-- Whole gold, Fibonacci, so the steps widen as a purse does.
ns.GOLD_RESERVE_AMOUNTS = { 1, 2, 3, 5, 8, 13, 21, 34, 55 }

-- Written after an amount the way the game writes money, in every locale.
ns.GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

--[[
    `value` is compared against UnitReaction(vendor), 0 for no requirement;
    `discount` is informational only. Neutral is left out: it is the same as
    no requirement.
]]
ns.REPUTATION_STANDINGS = {
	{ value = 0, discount = 0 },
	{ value = 5, discount = 5 },
	{ value = 6, discount = 10 },
	{ value = 7, discount = 15 },
	{ value = 8, discount = 20 },
}

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    GetPetFoodTypes() returns localized names, so the L["DIET_*"] names sit
    on top of the English rows. The English rows stay because the Starter
    List looks diet IDs up by English name.
]]
ns.PET_DIET_MAP = {
	["Meat"] = 1,
	["Fish"] = 2,
	["Bread"] = 3,
	["Cheese"] = 4,
	["Fruit"] = 5,
	["Fungus"] = 6,
}

ns.PET_DIET_MAP[ns.L["DIET_MEAT"]] = 1
ns.PET_DIET_MAP[ns.L["DIET_FISH"]] = 2
ns.PET_DIET_MAP[ns.L["DIET_BREAD"]] = 3
ns.PET_DIET_MAP[ns.L["DIET_CHEESE"]] = 4
ns.PET_DIET_MAP[ns.L["DIET_FRUIT"]] = 5
ns.PET_DIET_MAP[ns.L["DIET_FUNGUS"]] = 6

--------------------------------------------------------------------------------
-- Rogue Poison Groups
--------------------------------------------------------------------------------

-- A group's name is the client's own name for its first item, so no string here names one.
ns.POISON_GROUPS = {
	ANESTHETIC = 1,
	CRIPPLING = 2,
	DEADLY = 3,
	INSTANT = 4,
	MIND_NUMBING = 5,
	WOUND = 6,
	SEBACIOUS = 7,
	NUMBING = 8,
	ATROPHIC = 9,
	OCCULT = 10,
}

--------------------------------------------------------------------------------
-- Scroll Scan Priority
--------------------------------------------------------------------------------

ns.SCROLL_CHECK_ORDER = {
	"Agility",
	"Strength",
	"Protection",
	"Intellect",
	"Spirit",
	"Stamina",
}

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The sections from here to Buff Duty are the Spellbook's.

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

ns.MACRO_NAME_PREFIX = "-" -- so the add-on's macros sort together in /macro
-- With the prefix it fills WoW's 16 bytes, past which CreateMacro truncates and a lookup by name would miss it.
ns.MACRO_NAME_MAX_LENGTH = 16 - #ns.MACRO_NAME_PREFIX

--------------------------------------------------------------------------------
-- Parchment Colors
--------------------------------------------------------------------------------

-- Near black, so it reads on the light parchment.
ns.INK_COLOR = { 0.169, 0.106, 0.043 }
-- Secondary text: about 5:1 on the parchment, lighter than the main ink; opaque so it also works as a |c code.
ns.FADED_INK_COLOR = { 0.34, 0.27, 0.18 }
--[[
    Forever's page art darkens to orange-brown along the top and outer edges,
    where each page's first header sits, and swallows any mid-tone ink (a
    darkened gold read 1.05:1). A deep oxblood stays nearly as dark as the
    spell ink and sets headers apart by hue.
]]
ns.HEADER_INK_COLOR = { 0.30, 0.06, 0.03 }
ns.LABEL_INK_COLOR = ns.HEADER_INK_COLOR

-- The game's status colors darkened until they read on the parchment.
ns.WHATS_NEXT_INKS = {
	AVAILABLE = { 0.05, 0.42, 0.05 },
	SOON = { 0.08, 0.28, 0.6 },
	LATER = { 0.62, 0.09, 0.05 },
	MISSING = { 0.62, 0.33, 0 },
	TALENT = { 0.4, 0.2, 0.55 },
	TEACH = { 0, 0.4, 0.42 },
	OTHER = ns.FADED_INK_COLOR,
	ABILITY = ns.INK_COLOR,
	PASSIVE = ns.FADED_INK_COLOR,
	KNOWN = ns.FADED_INK_COLOR,
}

-- Full brightness, for the dark frame.
ns.WHATS_NEXT_BRIGHT = {
	AVAILABLE = "1EFF00",
	SOON = "71C4FF",
	LATER = "FF3B30",
	MISSING = "FF9A1F",
	TALENT = "C59BFF",
	TEACH = "33E6D9",
	OTHER = "9D9D9D",
	ABILITY = "FFFFFF",
	PASSIVE = "9D9D9D",
	KNOWN = "9D9D9D",
}

--[[
    Green for a rank the character could have now and doesn't, the one thing
    to go and fix; gray for one not yet learnable, since a level still to
    come isn't an error. Keys are ns.RankState's.
]]
ns.SPELL_RANK_COLORS = { KNOWN = "TEXT", LEARNABLE = "ON", NOT_YET = "MUTED" }
ns.SPELL_RANK_SELECTED_COLOR = "INFO"
ns.SPELL_RANK_NOTE_COLORS = { KNOWN = "HELP", LEARNABLE = "ON", NOT_YET = "MUTED" }

-- Dark leather beside the parchment, so the docked panels read as part of the window.
ns.CONDITIONALS_COLORS = {
	PANEL_FILL = "2A241C",
	PANEL_EDGE = "4D4232",
	ROW_FILL = "1F1B15",
	ROW_EDGE = "3D3428",
	FIELD_FILL = "0C0C0E",
	FIELD_EDGE = "5A4D38",
	FOOTER_EDGE = "4A4A4F",
	MUTED_INK = "B8AB8E",
	ARROW_INK = "8A7D64",
	METER_TRACK = "2A2A2E",
}

--------------------------------------------------------------------------------
-- Buff Duty
--------------------------------------------------------------------------------

-- The sections from here to the end are Buff Duty's and Rank Watch's.

--------------------------------------------------------------------------------
-- Buff Duty Audiences
--------------------------------------------------------------------------------

-- Labels are BUFF_DUTY_AUDIENCE_*.
Data.BUFF_AUDIENCE = {
	OFF = "OFF",
	TANK = "TANK",
	HEALER = "HEALER",
	ALL = "ALL",
}
Data.BUFF_AUDIENCE_ORDER = { "OFF", "TANK", "HEALER", "ALL" }

-- Nothing to gain from melee attack power (rows marked noCasters, like Blessing of Might).
Data.CASTER_CLASSES = {
	MAGE = true,
	PRIEST = true,
	WARLOCK = true,
}

Data.NO_MANA_CLASSES = {
	DEATHKNIGHT = true,
	ROGUE = true,
	WARRIOR = true,
}

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Seconds Buff Duty ignores the combat log after login and every loading screen.
Data.SAFETY_PAUSE = 3

--[[
    COMM_PREFIX stays Rank Sentinel's own, so Good to Go and anyone still
    running it elect one whisperer between them. COMM_RELEASE 999 reads to
    Rank Sentinel as a development build equal to its own, so it never tells
    its players to update.

    TARGET_LEVEL_RANGE is the game's rule for a buff on someone else: it
    picks the highest rank that lands, so a low rank on a low-level player is
    never the caster's choice, and never reported.
]]
Data.RANK_WATCH = {
	COMM_PREFIX = "RANKSENTINEL",
	COMM_RELEASE = 999,
	TARGET_LEVEL_RANGE = 10,
	METER_POLL = 15, -- seconds between damage meter reads on WoW Forever
	AFTER_COMBAT = 5, -- seconds after combat (or a release) before held whispers go out
	TARGET_BUSY_RETRY = 10, -- seconds before a whisper held for a target in combat is tried again
	PENDING_TTL = 15, -- seconds a cast of yours waits for its success
	JOIN_DELAY = 2, -- seconds after joining a group before asking who whispers
	STANDALONE_FOLDERS = { "Rank-Sentinel", "RankSentinel" },
}

-- Only for a player with no role of their own. Pets are stored under TANK_WHEN_PET beside the class tokens.
Data.TANK_WHEN = {
	NEVER = "NEVER",
	SOLO = "SOLO",
	ALWAYS = "ALWAYS",
}
Data.TANK_WHEN_ORDER = { "NEVER", "SOLO", "ALWAYS" }
Data.TANK_WHEN_PET = "PET"

-- INSTANCE covers a dungeon, raid, battleground or arena.
Data.BUFF_DUTY_WHERE = {
	ALWAYS = "ALWAYS",
	INSTANCE = "INSTANCE",
}
Data.BUFF_DUTY_WHERE_ORDER = { "ALWAYS", "INSTANCE" }

-- Any saved value but OFF reads as on; the category's Show timing decides when it shows.
Data.SELF_REFRESH_OFF = "OFF"
Data.SELF_REFRESH_MISSING = 0
Data.SELF_REFRESH_CHOICES = { "OFF", 0, 10, 5, 3 }

-- In the order the window draws them.
Data.BUFF_DUTY_ROWS = { "self", "food", "weapons", "scrolls", "elixirs", "other" }
Data.BUFF_DUTY_ROW_WHEN = {
	ALWAYS = "ALWAYS",
	GROUP = "GROUP",
	RAID = "RAID",
}
Data.BUFF_DUTY_ROW_WHEN_ORDER = { "ALWAYS", "GROUP", "RAID" }

-- Which hands a class is offered is the data folder's call: a Classic Era shaman can't dual wield.
Data.WEAPON_HAND_SLOTS = { MAIN = 16, OFF = 17 }
Data.WEAPON_HAND_ORDER = { "MAIN", "OFF" }

--[[
    When Missing (0), or minutes left. No Off: the category has its own
    switch. 3 minutes is about the length of a boss fight.
]]
Data.BUFF_DUTY_ROW_SHOW_CHOICES = { 0, 10, 5, 3 }
Data.BUFF_DUTY_ROW_SHOW_DEFAULT = 3

-- The items any class can use, in panel order.
Data.WEAPON_ITEM_KINDS = { "OIL", "STONE", "LURE" }
-- A fishing pole is always two-handed, so a lure is main hand only.
Data.WEAPON_ITEM_KIND_HANDS = { LURE = { "MAIN" } }

--[[
    On WoW Forever an IMBUE (a poison, a shaman imbue, a Firestone) sits
    beside a TEMPORARY oil or stone. Every other client has the one slot, and
    everything goes in TEMPORARY.
]]
Data.WEAPON_LAYERS = { IMBUE = "IMBUE", TEMPORARY = "TEMPORARY" }

-- Minutes.
Data.BUFF_DUTY_REFRESH_CHOICES = { 3, 5, 10 }

-- Percent of a solid background.
Data.BUFF_DUTY_OPACITY_CHOICES = { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }

-- Seconds. Short on purpose: past a few seconds a stranger who buffed you has usually walked on.
Data.BUFF_DUTY_FAVOR_CHOICES = { 20, 40, 60 }
Data.BUFF_DUTY_FAVOR_MAX = 5

Data.BUFF_DUTY_ICON_SIZE = 20
-- Sized to the text rather than the buttons.
Data.BUFF_DUTY_LABEL_ICON_SIZE = 16
