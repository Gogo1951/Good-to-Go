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
    Features/Core.lua (MoveRenamedSettings) moves it over at login and empties it.
]]
ns.OLD_SAVED_VARIABLES_NAME = "BagsBuffsButtonsDB"

--[[
    The add-ons Good to Go replaces that rewrite its macros, or report every
    low rank twice, if both run, by installed folder (Rank Sentinel under
    either folder name it has shipped with, Data.RANK_WATCH.STANDALONE_FOLDERS).
    Features/Replaced-Addons.lua turns any of them that is
    running off at login and offers a reload. This is no migration and has no end date: a
    player can install Good to Go, or turn the old add-on back on, long after
    the settings import below is gone.
]]
ns.REPLACED_ADDONS = { "Consumable-Connoisseur", "Rank-Sentinel", "RankSentinel" }

--[[
    MIGRATION (remove after 2026-12-08): the add-ons Good to Go
    replaces, by installed folder. Features/Legacy-Migration.lua copies the settings of the
    ones with a saved-variables table here from their own table, which the
    client loads only while that add-on is enabled, then turns every one of
    them off itself and offers a reload. The ones also in ns.REPLACED_ADDONS
    are turned off by that, which stays when this goes.
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

--[[
    Raw hex palette. Features/Utilities.lua derives the |cff-prefixed COLORS
    table and the ns.GetColor accessor from this, keeping Data files logic-free.
]]
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names, Field Titles
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
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

-- The house roster the Example lines name, by class; proper names, the same in every locale.
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

--[[
    The pets the Example lines name: a hunter's pet by its own name, a proper
    name the same in every locale, and a warlock's demon by its kind, the
    client's name for its creature family (ns.IMP_CREATURE_FAMILY_ID).
]]
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
    The ceiling every macro body is trimmed against. The unit is unconfirmed:
    Blizzard's macro edit box caps with letters="255" while the chat box uses
    SetMaxBytes, so the two may not agree. Every guard therefore measures #body
    in BYTES, which is never smaller than a character count and so holds under
    either reading -- never convert one to a character count. ruRU is the
    overflow canary.
]]
ns.MACRO_BODY_MAX_LENGTH = 255

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

--[[
    Stable AceConfig appName per options panel, derived from ADDON_NAME. Read by
    Options/*.lua for RegisterOptionsTable / AddToBlizOptions. Never localized,
    never built inline. Listed in the order the panels appear in Blizzard's
    tree (see ns.RegisterOptionsPanels).
]]
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME .. "_General",

	-- Each feature's panel, then its sub-panels, in the root panel's Features order
	BuffDuty = ADDON_NAME .. "_BuffDuty",
	BuffDutyBuffs = ADDON_NAME .. "_BuffDutyBuffs",
	BuffDutySelfBuffs = ADDON_NAME .. "_BuffDutySelfBuffs",
	BuffDutyWeaponBuffs = ADDON_NAME .. "_BuffDutyWeaponBuffs",
	Restocker = ADDON_NAME .. "_Restocker",
	Spellbook = ADDON_NAME .. "_Spellbook",
	AbilityAlerts = ADDON_NAME .. "_AbilityAlerts",
	Macros = ADDON_NAME .. "_Macros",
	FoodDrinks = ADDON_NAME .. "_FoodDrinks",
	PotionsManaGems = ADDON_NAME .. "_PotionsManaGems",
	Bandages = ADDON_NAME .. "_Bandages",
	Healthstone = ADDON_NAME .. "_Healthstone",
	Explosives = ADDON_NAME .. "_Explosives",
	ClassMacros = ADDON_NAME .. "_ClassMacros",
	IgnoreList = ADDON_NAME .. "_IgnoreList",
	RankWatch = ADDON_NAME .. "_RankWatch",
	RankWatchTracked = ADDON_NAME .. "_RankWatchTracked",
	RankWatchIgnored = ADDON_NAME .. "_RankWatchIgnored",
	InventoryReport = ADDON_NAME .. "_InventoryReport",
	ReadinessReport = ADDON_NAME .. "_ReadinessReport",

	Profiles = ADDON_NAME .. "_Profiles",
	FeedbackSupport = ADDON_NAME .. "_FeedbackSupport",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Options Widgets
--------------------------------------------------------------------------------

--[[
    dialogControl names for the add-on's own AceGUI widgets, each registered in
    Options/Options-Widgets.lua, which builds them. Derived from ADDON_NAME so none
    can collide with another add-on's widget of the same shape.

      ICON_CHECKBOX_WIDGET_TYPE  The stock checkbox with a gap between its icon
                                 and its label, cleared again where there is no
                                 stock checkbox to build on.
]]
ns.ICON_CHECKBOX_WIDGET_TYPE = ADDON_NAME .. "_IconCheckBox"

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

-- Interface\Icons\INV_Misc_QuestionMark
ns.QUESTION_MARK_ICON = 134400

--[[
    The Spellbook's own textures: the gold book on the window portrait and
    spellbook tab, and the category and settings buttons. The glyphs are white, tinted where they're used.
]]
ns.ICON_ADDON = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Spellbook"
ns.TEXTURE_GEAR = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Gear"

-- The arrow before the hovered rank in a spell tooltip's ranks; white, tinted where it's used.
ns.TEXTURE_RANK_ARROW = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Rank-Arrow"

-- The gold bag the Restock List and Staples windows wear in their portrait.
ns.ICON_RESTOCKER = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Restocker"

--------------------------------------------------------------------------------
-- Consumable Macros & Restocker
--------------------------------------------------------------------------------

-- The sections from here to Spellbook are Consumable Macros & Restocker's.

--------------------------------------------------------------------------------
-- Restock Window Colors
--------------------------------------------------------------------------------

--[[
    The Restock window's own UI states, which no brand color names. Raw hex like
    ns.PALETTE; the window's files convert them with ns.HexToRGB.

    Red is kept for errors. An add that did not go through is one. A Keep
    amount the bags are short of is not, so that mark is yellow, and the orders
    count under the list wears the same yellow, which is what tells a player
    what the mark means. It is the brand gold's hex, held as a role of its own
    so the mark can change without the headings following it.
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
    The Ignore List panel names one scope per list on the account. Every scope
    but one is an AceDB profile name (a character's, or one the player typed),
    so the Global list needs a key that no profile can collide with -- hence
    the asterisks, which no character's name can hold and nobody types as a
    profile name. Read by ns.GetIgnoreListForScope in Features/Macros-for-Consumables/Ignore-List.lua.
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
}

--[[
    Macro types whose macros stack up to MULTI_USE_MAX_ITEMS ranked /use
    lines, best item first. Once the best item runs out mid-combat — where
    macros cannot be rewritten — the press falls through to the next-best
    item. Only safe for categories whose items all share an item cooldown,
    so a single press still consumes exactly one item.
]]
ns.MULTI_USE_MAX_ITEMS = 3

ns.MULTI_USE_MACRO_TYPES = {
	["Health Potion"] = true,
	["Healthstone"] = true,
	["Mana Gem"] = true,
	["Mana Potion"] = true,
}

--[[
    Number of free General macro slots Consumable Macros leaves untouched for the
    player. At 0 nothing is reserved, so macro creation pauses only when the
    General macro book is completely full. When it pauses, a once-per-session
    chat message fires and creation resumes automatically once a slot frees
    up. See ns.TryCreateMacro in Macros/Writer.lua.
]]
ns.MACRO_SLOT_CUSHION = 0

--------------------------------------------------------------------------------
-- DruidMacroHelper Integration
--------------------------------------------------------------------------------

-- Which macro types are eligible for DMH wrapping when the druid toggle is on.
ns.DRUID_MACRO_HELPER_TYPES = {
	["Health Potion"] = true,
	["Mana Potion"] = true,
	["Healthstone"] = true,
}

--[[
    The /dmh guard prefix lines prepended to each DMH-wrapped macro body.
    Copied from the DruidMacroHelper add-on's own example macros:
      HP / HS  → "/dmh start" (stun + GCD + mana) plus a "/dmh cd <token>" line
      MP       → "/dmh stun gcd cd pot" (skips the mana check, since the
                 whole point of a mana pot is that the druid is OOM)
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
    Canned chat messages the macro bodies can fire via `/run GtGTip("key")`.
    GtGTip (in Features/Macros-for-Consumables/Macros/Runtime.lua) consults two tables:
      ns.TIP_MESSAGES        → static message text
      ns.MISSING_SPELL_MESSAGE_IDS → spell IDs (the flavor folder's Conjure-Spells file) that
                                   GtGTip resolves at print time
                                   via C_Spell.GetSpellName, producing "You don't
                                   currently know <Localized Spell Name>."
    A key the flavor folder leaves out, or a spell ID the current client
    doesn't know, resolves to nil, so GtGTip silently skips the print
    rather than naming a spell the player will never see. The noPetSkills tip
    names four pet spells, so Runtime.lua builds it at print time too.
]]
ns.TIP_MESSAGES = {
	noPetFood = ns.L["TIP_PET_NO_FOOD"],
	noHandPoison = ns.L["TIP_NO_HAND_POISON"],
}

--------------------------------------------------------------------------------
-- Group Contexts and Level Filters
--------------------------------------------------------------------------------

--[[
    The four places a group setting can tick, in the order every panel draws
    them: Solo, Party, Raid, Battleground (ns.GetGroupContext says which one
    the player is in). A setting saves one boolean per context under these
    keys, and its labels are GROUP_CONTEXT_<KEY> in the locale.
]]
ns.GROUP_CONTEXTS = { "solo", "party", "raid", "battleground" }

--[[
    The level filter a consumable's When to Use adds beneath its checkboxes:
    any level, below the client's max level, or at it. It can only switch off
    a context the checkboxes leave on (ns.IsUseWhenActive).
]]
ns.LEVEL_FILTER_ORDER = { "any", "leveling", "maxlevel" }

--------------------------------------------------------------------------------
-- Restock Reminders
--------------------------------------------------------------------------------

--[[
    Every restock reminder is either a headline on its own or a headline plus one
    line per item it counts as low or out. Stored as a mode rather than a boolean so the
    option reads as a choice ("Simple" or "Verbose") instead of an unlabeled
    switch, and so a third level could be added without another setting.
]]
ns.REMINDER_SIMPLE = "simple"
ns.REMINDER_VERBOSE = "verbose"

--[[
    What "low" means to the reminders, as a percentage of a row's Keep amount:
    an item counts as low while the bags hold less than this share of it, and
    as out at none. Anything at or above the line is left out of the reminders
    entirely, so a list that is merely topped-off-short stays quiet. 100 counts
    any shortfall at all. The merchant restock ignores it and still buys every
    row up to its full amount. Ships at 80 (Data/Default-Settings.lua).
]]
ns.RESTOCK_LOW_THRESHOLDS = { 50, 60, 70, 80, 90, 100 }

--[[
    Alert played when you reach an inn or city with something left to restock.
    Built from ADDON_NAME so renaming the add-on folder cannot break the path.
]]
ns.RESTOCK_ALERT_SOUND = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Sounds\\Low-Battery.ogg"

--------------------------------------------------------------------------------
-- Gold Reserve
--------------------------------------------------------------------------------

--[[
    The amounts, in whole gold, the Restocker panel's Gold Reserve dropdown
    offers: the Fibonacci run, so the steps widen as a purse does, from the
    1 gold the setting ships on to 55. The merchant restock never spends below
    the one chosen (Features/Restocker/Restocker-Merchant.lua).
]]
ns.GOLD_RESERVE_AMOUNTS = { 1, 2, 3, 5, 8, 13, 21, 34, 55 }

--[[
    The gold coin, written after an amount the way the game writes money, so
    the reserve reads the same in the dropdown and in chat, in every locale.
]]
ns.GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

--[[
    Required-reputation choices for the per-row dropdown. `value` is the item.reaction
    code the merchant logic compares against UnitReaction(vendor) -- 0 means "no
    requirement". `discount` is the standard Classic faction-vendor price saving for
    that standing, shown for reference (it is informational, not enforced here).
    "Neutral" is omitted: requiring Neutral is the same as no requirement ("Any"), since
    you can already buy from any vendor you're at least Neutral with. Labels come from
    ns.GetStandingLabel, which reads the client's own standing names.
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
    Maps diet names from GetPetFoodTypes() to internal diet IDs. The API
    returns LOCALIZED names ("Fleisch" on deDE), so the localized names from
    the L["DIET_*"] locale keys are layered on top of the English baseline.
    The English rows add no match of their own, since an untranslated DIET_*
    key already falls back to English; they stay because the Starter List
    categories look diet IDs up by English name.
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

--[[
    The canonical group numbering, keyed off by the poison tables and by the
    Starter List. A group's name is the client's own name for its first item
    (ns.GetPoisonGroupName), so no string here names one.
]]
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

ns.MACRO_NAME_PREFIX = "-" -- starts every WoW macro's name, so the add-on's macros sort together in /macro
-- a page macro's name; with the prefix it fills WoW's 16 bytes, past which CreateMacro truncates and a lookup by name would miss it
ns.MACRO_NAME_MAX_LENGTH = 16 - #ns.MACRO_NAME_PREFIX

--------------------------------------------------------------------------------
-- Parchment Colors
--------------------------------------------------------------------------------

-- parchment ink: spell names and category headers, near black so they read on the light parchment
ns.INK_COLOR = { 0.169, 0.106, 0.043 }
--[[
    faded ink for secondary text on the parchment (a tile's options note, rank and source text, page numbers):
    dark ink at 75% over the parchment, about 5:1 against it so it reads while staying lighter than the main
    ink; opaque so it also works as a |c code
]]
ns.FADED_INK_COLOR = { 0.34, 0.27, 0.18 }
--[[
    header ink for category and section headers and a form's label over its tiles (BATTLE STANCE): a deep
    oxblood, a manuscript's red heading ink. Forever's page art darkens to orange-brown along its top and outer
    edges, where the first header of each page sits, and any mid-tone ink (a darkened gold read 1.05:1 there)
    disappears into it; this stays nearly as dark as the spell ink (about 2:1 on that band, 6:1 mid-page) and
    sets headers apart from the near-black spell names by hue.
]]
ns.HEADER_INK_COLOR = { 0.30, 0.06, 0.03 }
ns.LABEL_INK_COLOR = ns.HEADER_INK_COLOR

--[[
    The What's Next? tabs' status inks, by status (ns.WHATS_NEXT_STATUSES and
    ns.WHATS_NEXT_PET_STATUSES): the game's green, blue, red and orange
    darkened until they read on the parchment, a muted purple for talents not
    taken, teal for a pet ability ready to teach, and Known and another pet
    family's abilities in faded ink. The Pet Spell Book's abilities are in
    plain ink and its passives faded (ns.PET_SPELLBOOK_STATUSES).
]]
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

-- The same statuses at full brightness, for the tooltip and the footer's counts on the dark frame.
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
    A spell's ranks wherever they're listed: the ranks section of a spell's
    tooltip ("GtG // Fear Ranks"), the macro menu's Rank and Grouped Spells
    submenus, and the Spell Book tile's note. White (TEXT) once known; green
    (ON) for one the character could have now and doesn't, the one thing to
    go and fix, green like What's Next?'s Available Now; gray (MUTED) for one it can't learn yet, like a disabled
    entry, since a level still to come isn't an error. The note beside each
    (its level, or where to learn it) is silver (HELP) for a known rank and
    takes the rank's own color otherwise. Keys are ns.RankState's. The
    tooltip's hovered rank and its arrow are blue (INFO) instead, reading
    as "selected"; its note keeps the state color, so its state still shows.
]]
ns.SPELL_RANK_COLORS = { KNOWN = "TEXT", LEARNABLE = "ON", NOT_YET = "MUTED" }
ns.SPELL_RANK_SELECTED_COLOR = "INFO"
ns.SPELL_RANK_NOTE_COLORS = { KNOWN = "HELP", LEARNABLE = "ON", NOT_YET = "MUTED" }

--[[
    The Conditionals panel's own dark leather beside the parchment, so it reads
    as part of the window: its fill and edge, each row's, each dropdown's and
    spell slot's field, the footer's edge, the muted and arrow inks, and the
    length meter's track. Raw hex like ns.PALETTE, converted with ns.HexToRGB
    for both docked panels in Features/Enhanced-Spellbook/Macro-Builder/Panel-Widgets.lua.
]]
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

--[[
    Who a Buff Duty buff is offered to, one choice per buff.
    BUFF_AUDIENCE_ORDER is the dropdown's order; the labels come from the locale
    (BUFF_DUTY_AUDIENCE_*).
]]
Data.BUFF_AUDIENCE = {
	OFF = "OFF",
	TANK = "TANK",
	HEALER = "HEALER",
	ALL = "ALL",
}
Data.BUFF_AUDIENCE_ORDER = { "OFF", "TANK", "HEALER", "ALL" }

--[[
    Classes with nothing to gain from melee attack power, so a Buff Duty window row
    marked noCasters (Blessing of Might) skips them.
]]
Data.CASTER_CLASSES = {
	MAGE = true,
	PRIEST = true,
	WARLOCK = true,
}

-- Classes with no mana, so a Buff Duty window row marked manaOnly skips them.
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
    Rank Watch (Features/Rank-Watch/), the standalone Rank Sentinel add-on brought home.

    COMM_PREFIX stays the standalone Rank Sentinel add-on's own prefix, string.upper of its name, so Good to Go
    and anyone still running Rank Sentinel elect one whisperer between them and never both whisper.
    COMM_RELEASE is the version number sent with LEAD and JOIN: Rank Sentinel reads 999 as a development build
    equal to its own, so it never tells its players to update.

    TARGET_LEVEL_RANGE is the game's own rule for a buff cast on someone else: a rank lands only on a target no
    more than 10 levels below the rank's learn level, and the game picks the highest rank that fits by itself.
    A low rank on a low-level player is the game's choice, not the caster's, so it is never reported.
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

--[[
    When a class, or pets, count as tanks on the Buff Duty window ("Count as
    Tanks"): NEVER, SOLO while you're not in a party or raid, or ALWAYS. Only
    for a player with no role of their own. TANK_WHEN_ORDER is the dropdown's
    order; the labels come from the locale (BUFF_DUTY_TANKS_*). Pets are
    stored under TANK_WHEN_PET beside the class tokens.
]]
Data.TANK_WHEN = {
	NEVER = "NEVER",
	SOLO = "SOLO",
	ALWAYS = "ALWAYS",
}
Data.TANK_WHEN_ORDER = { "NEVER", "SOLO", "ALWAYS" }
Data.TANK_WHEN_PET = "PET"

--[[
    Where the Buff Duty window shows while Solo, In Party or In Raid lets it
    show at all ("When to Show"): ALWAYS, or INSTANCE for inside a dungeon,
    raid, battleground or arena only. BUFF_DUTY_WHERE_ORDER is the dropdown's
    order; the labels come from the locale (BUFF_DUTY_WHERE_*).
]]
Data.BUFF_DUTY_WHERE = {
	ALWAYS = "ALWAYS",
	INSTANCE = "INSTANCE",
}
Data.BUFF_DUTY_WHERE_ORDER = { "ALWAYS", "INSTANCE" }

--[[
    When a self buff or the Soulstone shows on the Buff Duty window: OFF, MISSING
    (only once it's gone), or a number of minutes left. Doubles as the
    dropdown's order. The Weapon Buffs dropdown reuses MISSING for When
    Missing.
]]
Data.SELF_REFRESH_OFF = "OFF"
Data.SELF_REFRESH_MISSING = 0
Data.SELF_REFRESH_CHOICES = { "OFF", 0, 10, 5, 3 }

--[[
    The weapon hands a poison or imbue can go on, by the inventory slot each
    names. Which hands a class is offered is the data folder's call
    (BUFF_DUTY_WEAPON_HANDS): a Classic Era shaman can't dual wield.
]]
Data.WEAPON_HAND_SLOTS = { MAIN = 16, OFF = 17 }
Data.WEAPON_HAND_ORDER = { "MAIN", "OFF" }

--[[
    The Weapon Buffs panel's one Reapply timing, for every poison, imbue,
    oil, stone and lure: When Missing, or minutes left. No Off: each choice
    has its own checkboxes for that.
]]
Data.WEAPON_REFRESH_CHOICES = { 0, 10, 5, 3 }
Data.WEAPON_REFRESH_DEFAULT = 3

-- The Weapon Buffs panel's boxes for the items any class can use, in order (BUFF_DUTY_WEAPON_ITEMS' kind).
Data.WEAPON_ITEM_KINDS = { "OIL", "STONE", "LURE" }
-- A kind that only one hand can carry: a fishing pole is always two-handed, so a lure is main hand only.
Data.WEAPON_ITEM_KIND_HANDS = { LURE = { "MAIN" } }

--[[
    The temporary enchants a weapon holds side by side, each asked about on
    its own. On WoW Forever (ns.WEAPON_ENCHANTS_STACK) an IMBUE (a poison, a
    shaman imbue, a Firestone) sits beside a TEMPORARY oil or stone. Every
    other client has the one slot, and everything goes in TEMPORARY.
]]
Data.WEAPON_LAYERS = { IMBUE = "IMBUE", TEMPORARY = "TEMPORARY" }

--[[
    Buff Duty's "Refresh Under" choices, in minutes: a buff with
    less than this left is offered again.
]]
Data.BUFF_DUTY_REFRESH_CHOICES = { 3, 5, 10 }

-- The Buff Duty window's Window Opacity choices, in percent of a solid background.
Data.BUFF_DUTY_OPACITY_CHOICES = { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }

--[[
    How long a stranger who buffed you can stay on the Buff Duty window's Return the
    Favor list, in seconds (the player picks one), and how many of them it
    holds at once. Short on purpose: past a few seconds
    they have usually walked on.
]]
Data.BUFF_DUTY_FAVOR_CHOICES = { 20, 40, 60 }
Data.BUFF_DUTY_FAVOR_MAX = 5

-- The Buff Duty window's buff buttons.
Data.BUFF_DUTY_ICON_SIZE = 20
--[[
    The small icons inside its names, sized to the text rather than the
    buttons: the role icon in front of each name, a pet's family, a weapon
    hand's item, and a raid group's fold plus or minus.
]]
Data.BUFF_DUTY_LABEL_ICON_SIZE = 16
