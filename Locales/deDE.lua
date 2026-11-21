local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "deDE")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Brand
--------------------------------------------------------------------------------

--[[
    The add-on has two names. ADDON_TITLE, the full name, is for window
    titles, the front of every chat print ("Good to Go // ..."),
    and anywhere the add-on is talked about; ADDON_SHORT_NAME is for tooltip
    lines and the end of every sent message ("... // GtG"). Both are proper nouns and
    stay as written in every locale, as does the full name inside any
    sentence below.
]]
L["ADDON_TITLE"] = "Good to Go"
L["ADDON_SHORT_NAME"] = "GtG"

L["CHAT_LOADED"] =
	"Version %s. Die Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findest du unter Optionen > AddOns > Good to Go. Gefällt dir dieses Add-on? Erzähl einem Freund davon, markiere es auf CurseForge als Favorit oder gib ihm auf GitHub einen Stern. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Hilf Good to Go beim Leveln"
L["OPTIONS_LEVEL_UP_THANKS"] = "Danke, dass du dich für Good to Go entschieden hast!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Verband"
L["MACRO_EXPLOSIVES"] = "- Sprengstoff"
L["MACRO_FEED_PET"] = "- Tier füttern"
L["MACRO_FOOD"] = "- Essen"
L["MACRO_HEALTH_POTION"] = "- Heiltrank"
L["MACRO_HEALTHSTONE"] = "- GS"
L["MACRO_MANA_GEM"] = "- Manastein"
L["MACRO_MANA_POTION"] = "- Manatrank"
L["MACRO_POISONS"] = "- Gifte"
L["MACRO_SOULSTONE"] = "- Seelenstein"
L["MACRO_WATER"] = "- Wasser"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names or spells in a sentence, such as a buff ask or a level-up line ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s und %s"
-- Joins the last one to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s und %s"
-- Joins two choices in a sentence, such as the buffs an ask to your target names ("[Fortitude] or [Shadow Protection]").
L["LIST_OR_PAIR_FORMAT"] = "%s oder %s"
-- Joins the last choice to the ones before it, already joined with LIST_SEPARATOR ("[Fortitude], [Shadow Protection], or [Divine Spirit]").
L["LIST_OR_LAST_FORMAT"] = "%s oder %s"
-- Closes a hover list cut short: %d is how many more it holds, such as the Restock List's Short Items or the beasts that know a pet ability.
L["LIST_MORE_SENTENCE"] = "Und %d weitere."
--[[
    A name with a detail after it: a Spellbook note and its settings ("Target (Mouseover, Self)"), a pet and
    its owner, a spell and its rank in Rank Watch ("[Arcane Intellect] (Rank 3)"), a beast and its level or
    level range in Pet What's Next? ("Forest Spider (5-6)"), or the Readiness Report's main talent tree and
    its point spread ("Frost (0/11/40)").
]]
L["NAME_WITH_DETAIL_FORMAT"] = "%s (%s)"
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = ","

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    Diet names as returned by the pet diet reader, which is localized. These
    values MUST match the client's strings exactly (verify in-game with a pet
    out: /dump GetPetFoodTypes() on Era and TBC,
    /dump C_PetInfo.GetPetFoodTypes() on Forever). Used to build
    ns.PET_DIET_MAP in Data/Data.lua.

    They are ALSO the food checkbox labels in the staples pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Brot"
L["DIET_CHEESE"] = "Käse"
L["DIET_FISH"] = "Fisch"
L["DIET_FRUIT"] = "Obst"
L["DIET_FUNGUS"] = "Fungus"
L["DIET_MEAT"] = "Fleisch"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sieht aus, als hättest du einen Bug gefunden! %s (%s) kann in %s > %s (%s) nicht verwendet werden. Bitte melde das, damit wir es beheben können. Danke! %s"
L["MESSAGE_NO_ITEM"] = "Kein geeigneter Gegenstand vom Typ %s in deinen Taschen gefunden."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Einige Makros von Good to Go konnten nicht erstellt werden, weil deine Makroplätze voll sind. Mach einen Platz frei, indem du Makros löschst, die du nicht mehr brauchst, oder schalte nicht benötigte Makros von Good to Go unter Optionen > AddOns > Good to Go > Verbrauchsgüter-Makros ab."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Deine Makros sind bereit. Gib %s ein, öffne den Reiter %s und ziehe - Essen, - Wasser und die übrigen auf deine Aktionsleisten."
-- The mini-map button's Right-Click, or the menu's Ignore row. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s steht jetzt auf der Ignorierliste dieses Charakters."
-- A click on an item in the mini-map menu's Ignore List. %s is the item's link.
L["MESSAGE_IGNORE_REMOVED"] = "%s steht nicht mehr auf der Ignorierliste dieses Charakters."
-- The mini-map button's Middle-Click: %d is how many items it took off the list, exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "1 Gegenstand von der Ignorierliste dieses Charakters entfernt."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "%d Gegenstände von der Ignorierliste dieses Charakters entfernt."

L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann das Optionsmenü im Kampf nicht geöffnet werden."

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    Printed when a ready check starts, as a header plus up to three lines. Each
    line is a set of "Label: a, b, c" clauses joined by ". ", and every part of
    it is dropped when it has nothing to say -- a clean character prints nothing
    at all, so there is no all-clear string here and must not be one.

    The joins are keys of their own so a locale can use its own punctuation:
    READINESS_CLAUSE_FORMAT puts a clause's label before its items, the items
    are joined with LIST_SEPARATOR, and the clauses with
    READINESS_CLAUSE_SEPARATOR.
]]

L["READINESS_TITLE"] = "Bereitschaftsbericht"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Fehlende Buffs:"
L["READINESS_EXPIRING"] = "Läuft bald ab:"
L["READINESS_MISSING_ITEMS"] = "Fehlende Gegenstände:"
L["READINESS_DAMAGED_GEAR"] = "Beschädigte Ausrüstung:"
L["READINESS_CHARACTER"] = "Charakter:"
L["READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt:"

--[[
    What the report calls each thing. The Readiness Report panel labels its
    switches with these same keys, so a switch names exactly the line it
    controls; a switch that needs other words than its line (Main Hand Weapon
    Buff, PvP Flag On, Scroll Buffs) keeps a label of its own.
    Well Fed, Main Hand and Off Hand are the client's own names (the buff,
    MAINHANDSLOT and SECONDARYHANDSLOT), so they have no keys here, and
    READINESS_PET_FORMAT puts Well Fed in the pet's line (%s is that name).

    Deliberately its own set rather than the shared LABEL_* keys the macro
    messages use: those name an item you are being offered ("Health Potion"),
    these name a gap in your preparation ("Healing Potion"), and the two want
    to be reworded independently.
]]
L["READINESS_FLASK"] = "Fläschchen oder 2x Elixiere"
L["READINESS_PET_FORMAT"] = "%s (Tier)"
L["READINESS_SCROLLS"] = "Schriftrollen"
-- The switch for the Scrolls line.
L["FEATURE_SCROLL_BUFFS"] = "Schriftrollen-Buffs"
L["READINESS_SOULSTONE"] = "Seelenstein inaktiv"
L["READINESS_HEALTHSTONE"] = "Gesundheitsstein"
L["READINESS_MANA_GEM"] = "Manastein"
L["READINESS_HEALING_POTION"] = "Heiltrank"
L["READINESS_MANA_POTION"] = "Manatrank"
L["READINESS_BANDAGES"] = "Verbände"
L["READINESS_PVP_ON"] = "PvP aktiv"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d Min."
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s unter 1 Min."
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 nicht verteilter Talentpunkt"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d nicht verteilte Talentpunkte"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Du hast derzeit kein nützliches Futter für dein Tier."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Du kennst derzeit keinen der Zauber %s, %s, %s oder %s."
L["TIP_NO_HAND_POISON"] = "Für diese Waffe ist das gewählte Gift aufgebraucht."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Du kennst %s derzeit nicht."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "Kein %s in deinen Taschen. Rechtsklicke auf %s, um mehr herbeizuzaubern."
L["TIP_EMPTY_CREATE"] = "Kein %s in deinen Taschen. Rechtsklicke auf %s, um einen herzustellen."

--------------------------------------------------------------------------------
-- Mini-map Menu
--------------------------------------------------------------------------------

--[[
    In every *_FORMAT key below that names the buff, %s is the client's name
    for "Well Fed". Buff Duty's mini-map block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]

--[[
    The heading over the food the Food macro eats, at the top of the mini-map
    menu, with the item on the row beneath; with nothing to show,
    MESSAGE_NO_ITEM takes the item's row.
]]
L["MINIMAP_BEST_FOOD"] = "Aktuelles Essen"

-- The Ignore List block: its heading, the row that ignores the current food, and the row that clears the list.
L["MINIMAP_IGNORE_LIST"] = "Ignorierliste"
L["MENU_IGNORE"] = "Ignorieren"
L["MENU_CLEAR_IGNORE"] = "Ignorierliste leeren"

--[[
    The orders inside the mini-map menu's Restocker block, while it's on: one
    item per row, up to eight, then MENU_MORE. An order is one Restock List row
    with Buy switched on that is still short in your bags.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.

    STOCKED takes the place of the rows, in green, when nothing at all is
    short, on a wrapping line of its own, so it can be a full sentence. EMPTY
    is the line when the list holds nothing at all, which is not the same as
    being stocked, and NOTHING_LOW the line when rows are short but none is
    under the Low Means Under threshold.
]]
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Glückwunsch, deine Vorräte sind vollständig aufgefüllt!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Deine Liste ist leer."
L["MINIMAP_RESTOCKER_NOTHING_LOW"] = "Nichts ist knapp oder aufgebraucht."

--[[
    The mini-map menu's Restocker block: a line saying what the list is
    for, and the click its Open row names.
    "Your list" in the description and in MINIMAP_RESTOCKER_EMPTY is this
    list. The Options row is always the menu's last, its click on its right.
]]
L["MENU_RESTOCKER_DESCRIPTION"] = "Kauft die Gegenstände auf deiner Liste und lagert sie in der Bank."
L["MENU_CLICK_SHIFT_RIGHT"] = "Shift + Rechtsklick"
L["MENU_OPTIONS"] = "GtG-Optionen"
L["MENU_CLICK_SHIFT_LEFT"] = "Shift + Linksklick"
L["MENU_CLICK_SHIFT_MIDDLE"] = "Shift + Mittelklick"
-- The Restocker block's Open row hover while the Restocker is off.
L["MENU_RESTOCKER_OPEN_OFF_DESCRIPTION"] = "Öffnet deine Nachschubliste. Schalte den Restocker ein, um sie zu nutzen."

-- Buff Duty's block in the menu while its close button has hidden it: the word on its right, and the note under it.
L["MENU_BUFF_DUTY_PAUSED"] = "Pausiert"
L["MENU_BUFF_DUTY_PAUSED_NOTE"] = "Ausgeblendet, bis du einer Gruppe beitrittst, dich erneut einloggst oder neu lädst."

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The mini-map menu's [Class] Macros flyout, and one macro's worth under a
    consumable macro's tooltip on the Spellbook page. MENU_CLASS_MACROS, with
    the UI Labels, titles the flyout with the client's name for the player's
    class. The items the class's own macros will use (a Hunter's pet food, a
    Rogue's two poisons) list under that title in the menu, each beside the
    client's slot name or LABEL_PET_FOOD.
]]

--[[
    A group is the macro's name, then one row per click: in the menu's flyout,
    what it does on the left and the click on the right; under a Spellbook
    tooltip, the other way round. Neither side wraps, so each stays a few
    words. A spell the row casts is named by the client (Mend Pet, Ritual of
    Refreshment, Ritual of Souls) and has no key here, and a plain click
    reuses MENU_CLICK_LEFT, MENU_CLICK_RIGHT or MENU_CLICK_MIDDLE.
]]
L["NOTE_MACRO_FEED_PET"] = "Tier-füttern-Makro"
L["NOTE_MACRO_FOOD_WATER"] = "Essen- und Wasser-Makros"
L["NOTE_MACRO_MANA_GEM"] = "Manastein-Makro"
L["NOTE_MACRO_HEALTHSTONE"] = "Gesundheitsstein-Makro"
L["NOTE_MACRO_SOULSTONE"] = "Seelenstein-Makro"
L["NOTE_MACRO_POISONS"] = "Gifte-Makro"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Rufen, füttern oder wiederbeleben"
L["NOTE_PET_MEND_CLICK"] = "Rechtsklick oder im Kampf"
L["NOTE_HOLD_SHIFT"] = "Shift halten"
L["NOTE_PET_FORCE_REVIVE"] = "Wiederbeleben erzwingen"
L["NOTE_HOLD_CONTROL"] = "Strg halten"
L["NOTE_PET_DISMISS"] = "Freigeben"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down (NOTE_CONJURE_LOWER_RANK, NOTE_CREATE_LOWER_RANK), since the bags
    hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Herbeizaubern"
L["NOTE_CREATE"] = "Herstellen"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Erneuter Rechtsklick"
L["NOTE_CONJURE_LOWER_RANK"] = "Niedrigeren Rang herbeizaubern"
L["NOTE_CREATE_LOWER_RANK"] = "Niedrigeren Rang herstellen"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um Essen oder Wasser für dessen Stufe herbeizuzaubern."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um einen Gesundheitsstein für dessen Stufe herzustellen."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Gifte-Fenster"
L["NOTE_POISONS_REPLACED"] = "Ersetzt alte Gifte automatisch."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map menu. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Verband"
L["LABEL_EXPLOSIVE"] = "Sprengstoff"
L["LABEL_FOOD"] = "Essen"
L["LABEL_HEALTH_POTION"] = "Heiltrank"
L["LABEL_HEALTHSTONE"] = "Gesundheitsstein"
L["LABEL_MANA_GEM"] = "Manastein"
L["LABEL_MANA_POTION"] = "Manatrank"
L["LABEL_PET_FOOD"] = "Tierfutter"
L["LABEL_POISON"] = "Gift"
L["LABEL_SOULSTONE"] = "Seelenstein"
L["LABEL_WATER"] = "Wasser"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map menu: the Toggle and Open rows, and the button clicks rows name on their right.

L["MENU_TOGGLE"] = "Umschalten"
L["MENU_OPEN"] = "Öffnen"
L["MENU_CLICK_LEFT"] = "Linksklick"
L["MENU_CLICK_RIGHT"] = "Rechtsklick"
L["MENU_CLICK_MIDDLE"] = "Mittelklick"

-- The words on the right of a block's title.
L["MENU_ON"] = "An"
L["MENU_OFF"] = "Aus"

-- The note after a list cut short at eight rows: %d is how many more there are, so it is never one.
L["MENU_MORE"] = "%d weitere"

--[[
    More Features, the row that opens the flyout of every feature without a
    block of its own, and its right side: how many of those are on and off,
    side by side ("4 On, 3 Off"), so the On count can take its own color.
]]
L["MENU_MORE_FEATURES"] = "Weitere Funktionen"
L["MENU_FEATURE_COUNT_ON"] = "%d an"
L["MENU_FEATURE_COUNT_OFF"] = "%d aus"

-- The mini-map menu's Enhanced Spellbook block, above the class macros: a line saying what it's for, then Open (MENU_OPEN),
-- as Shift + Left-Click on the button does. MENU_OPEN_SPELLBOOK is the click line on the spellbook tab's tooltip.
L["MENU_SPELLBOOK_DESCRIPTION"] = "Mouseover-Makros für jeden Zauber, mit einem Klick erstellt."
L["MENU_OPEN_SPELLBOOK"] = "Erweitertes Zauberbuch öffnen"

-- The body of Buff Duty's Toggle tooltip in the mini-map menu, under the Enable option's name. %s is the client's name for the player's class.
L["MENU_BUFF_DUTY_TOGGLE_CLASS_DESCRIPTION"] =
	"Schaltet den Buff-Dienst ein oder aus, solange du die Klasse %s spielst. Deine anderen Klassen behalten ihre eigene Einstellung."

-- The row opening the class's macro notes, in the class color. %s is the client's name for the player's class.
L["MENU_CLASS_MACROS"] = "%s-Makros"

--------------------------------------------------------------------------------
-- Group Contexts
--------------------------------------------------------------------------------

--[[
    The checkboxes for when a feature acts by group, on every panel that has
    them, always in this order. Each description is the checkbox's hover text,
    saying when that context holds: a battleground or arena is always
    Battleground, even though its group is a raid.
]]
L["GROUP_CONTEXT_SOLO"] = "Solo"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "Während du in keiner Gruppe und keinem Schlachtzug bist."
L["GROUP_CONTEXT_PARTY"] = "Gruppe"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] = "Während du in einer Gruppe bist, auch in einem Dungeon über die Gruppensuche."
L["GROUP_CONTEXT_RAID"] = "Schlachtzug"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] =
	"Während du in einem Schlachtzug bist. Der Schlachtzug eines Schlachtfelds zählt als Schlachtfeld."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Schlachtfeld"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] =
	"Während du auf einem Schlachtfeld oder in einer Arena bist, egal in welcher Gruppe."

--------------------------------------------------------------------------------
-- When to Use
--------------------------------------------------------------------------------

--[[
    Every consumable's When to Use (Use Pet Food Buffs and Use Conjured Food
    & Water First): the level filter dropdown, then the group context
    checkboxes (GROUP_CONTEXT_*) under it. %s in OPTIONS_MODE_DESCRIPTION is
    the feature's name, OPTIONS_PET_HEADER; the conjured dropdown has hover
    text of its own. Each level value carries its own "when", since most
    dropdowns sit beside their toggle with no caption. Leveling means below
    the client's max level. OPTIONS_GROUPS_NONE shows in red under the
    checkboxes while none is ticked.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	'Legt fest, auf welchen Stufen dein Essen-Makro "%s" anbietet: auf jeder Stufe, nur beim Leveln oder nur auf Höchststufe. Die Kästchen darunter legen fest, in welchen Gruppen.'
L["OPTIONS_MODE_CAPTION"] = "Wann verwenden"
L["OPTIONS_GROUPS_NONE"] = "Nichts ist angehakt, daher wird dies nie verwendet."
L["LEVEL_FILTER_ANY"] = "Auf jeder Stufe"
L["LEVEL_FILTER_LEVELING"] = "Beim Leveln"
L["LEVEL_FILTER_MAX_LEVEL"] = "Auf Höchststufe"

--------------------------------------------------------------------------------
-- Inventory Report
--------------------------------------------------------------------------------

--[[
    The block Features/Inventory-Report/Inventory-Report-Tooltip.lua adds under an item's own tooltip
    lines. Its header is "GtG // Inventory Report": ADDON_SHORT_NAME, then the
    title, in the chat prints' branded colors, with the total at its right
    edge. Under it, one line per character, this one first: the name on the
    left (the client's own character names, so no keys here), its counts at
    the right edge.

    Keep the counts short: they share a line with a name, and the tooltip is
    as wide as its longest line.
]]
L["INVENTORY_REPORT_TITLE"] = "Inventarbericht"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Taschen %s, Bank %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Taschen %s"
L["INVENTORY_REPORT_BANK"] = "Bank %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Gesamt %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Sich selbst aktualisierende Makros für dein bestes Essen, Wasser, Tränke und Gesundheitssteine, eine Nachschubliste, die Reagenzien und Munition automatisch kauft und einlagert, fehlende Buffs per Klick, Hinweise auf niedrige Zauberränge und Mouseover-Makros für jeden Zauber."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Erweitertes Zauberbuch"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Mouseover-, Cursor- und Selbstzauber-Makros für jeden Klassenzauber, mit einem Klick in einem neuen Zauberbuch-Reiter erstellt, ganz ohne Makrosyntax. Sie bleiben aktuell, wenn du aufsteigst, trainierst oder die Skillung wechselst. Per Rechtsklick kommen Fokus, Zaubern abbrechen, automatischer Angriff, Begleiterangriff oder Schmuckstücke dazu."
L["SPELLBOOK_IS_OFF"] =
	"Erweitertes Zauberbuch ist aus. Schalte es unter Optionen > AddOns > Good to Go > Erweitertes Zauberbuch ein."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Gibt beim Anmelden eine Willkommensnachricht im Chat aus."

-- Mini-map Button
L["OPTIONS_MINIMAP_BUTTON"] = "Minikarten-Button aktivieren"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Zeigt den Minikarten-Button an."

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    The root panel's Features section: every feature's on/off switch, two to a
    line, each the same toggle that heads its feature's own panel. Enable Buff
    Duty and Enable Restocker keep their original keys (BUFF_DUTY_ENABLE,
    OPTIONS_RESTOCKER_ENABLE), with the Buff Duty and Restocker strings.

    The two *_CONFIRM_OFF prompts appear only when the switch is turned off,
    and must say plainly that turning it off does not delete any macro.
]]
L["OPTIONS_FEATURES_HEADER"] = "Funktionen"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Zeigt ein Fenster mit allen in deiner Gruppe, denen ein Buff fehlt, den du geben kannst. Klicke auf ein Symbol, um ihn zu wirken."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Hält deine Taschen anhand deiner Nachschubliste gefüllt, kauft bei Händlern ein, verschiebt Gegenstände zwischen Taschen und Bank und erinnert dich, wenn etwas knapp wird. Ausgeschaltet stoppt all das, einschließlich des Fensters der Nachschubliste. Deine Listen bleiben gespeichert."
L["SWITCH_SPELLBOOK"] = "Erweitertes Zauberbuch aktivieren"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Fügt deinem Zauberbuch einen Reiter hinzu, der Mouseover-, Cursor- und Selbstzauber-Makros für deine Zauber erstellt und sie aktuell hält, während du aufsteigst und trainierst. Ausgeschaltet verschwindet der Reiter und die Aktualisierungen stoppen. Es löscht nie ein Makro; das erledigen die Schaltflächen unter Makros löschen auf der Seite Erweitertes Zauberbuch."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Erweitertes Zauberbuch ausschalten? Sein Reiter verschwindet aus deinem Zauberbuch, und die erstellten Makros werden nicht mehr aktualisiert, wenn du aufsteigst und trainierst. Gelöscht werden sie dadurch nicht: Sie bleiben so auf deinen Aktionsleisten, wie sie jetzt sind."
L["SWITCH_MACROS"] = "Verbrauchsgüter-Makros aktivieren"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Richtet deine Makros für Essen, Wasser, Tränke und andere Verbrauchsgüter immer auf den besten Gegenstand in deinen Taschen aus, während sich deine Taschen ändern. Ausgeschaltet stoppen die Aktualisierungen, und jedes Makro bleibt, wie es zuletzt war. Es löscht nie ein Makro; das geschieht, wenn du eines unter Zu erstellende Makros auf der Seite Verbrauchsgüter-Makros abwählst."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Verbrauchsgüter-Makros ausschalten? Deine Makros werden nicht mehr aktualisiert, wenn sich deine Taschen ändern, sodass ein Button womöglich weiter nach einem Gegenstand greift, den du aufgebraucht hast. Gelöscht werden sie dadurch nicht: Sie bleiben so auf deinen Aktionsleisten, wie sie jetzt sind."
L["SWITCH_INVENTORY_REPORT"] = "Inventarbericht aktivieren"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Ergänzt den Tooltip eines Gegenstands darum, wie viele du in deinen Taschen, in deiner Bank und auf deinen anderen Charakteren dieses Realms hast. Schalte ihn ab, wenn ein anderes Add-on diese Zahlen bereits anzeigt."
L["SWITCH_READINESS_REPORT"] = "Bereitschaftsbericht aktivieren"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Gibt beim Start eines Bereitschaftschecks eine private Liste mit allem aus, was du noch beheben musst, etwa ein fehlender Buff, ein fehlender Trank oder beschädigte Ausrüstung. Bleibt still, wenn du bereit bist."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Restocker aktivieren"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Beispiel"

-- A Reset button, which puts the settings it sits under, or the whisper box beside it, back to their defaults.
L["OPTIONS_RESET"] = "Zurücksetzen"
L["OPTIONS_FEATURE_OFF_STATUS"] =
	"Die Funktion %s ist aus, daher werden diese Einstellungen nicht verwendet. Ihr Schalter ist auf der Seite %s."

--[[
    The whisper composer around every whisper a player words themselves, on the Buff Duty and Rank Watch
    panels: the language they go out in, the caption and Reset button (OPTIONS_RESET) beside each box, the
    tooltip on the marker and the "// GtG" either side of it, the line shown when a whisper is too long, and the
    test button.
    The whispers' default text lives in Data/Message-Languages.lua, not here.
]]
L["SEND_MESSAGES_IN"] = "Nachrichten senden auf"
L["SEND_MESSAGES_IN_DESCRIPTION"] =
	"Legt fest, in welcher Sprache Good to Go anderen Spielern flüstert. Wählst du eine andere Sprache, wird deren Standardtext eingesetzt, außer du hast einen eigenen geschrieben."
L["WHISPER_TEXT"] = "Flüsternachricht"
L["WHISPER_TEXT_RESET_DESCRIPTION"] =
	"Setzt diese Flüsternachricht auf den Standardtext in deiner Sendesprache zurück."
L["WHISPER_SIGN_OFF_DESCRIPTION"] =
	"Wird an jede Flüsternachricht von Good to Go angehängt, damit andere Spieler erkennen, dass sie von einem Add-on kommt."
L["WHISPER_TOO_LONG"] = "Zu lang, daher wird stattdessen der Standardtext gesendet."
L["WHISPER_TEST"] = "Test an mich senden"
L["WHISPER_TEST_DESCRIPTION"] = "Flüstert dir das Beispiel, damit du es genau so siehst wie andere Spieler."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsmenü dieses Add-ons."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Öffnet deine Nachschubliste."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Dieses Add-on wurde von Spielern entwickelt, die dieses Spiel lieben und es für alle so unterhaltsam wie möglich machen wollen. Wir werden nie um Spenden bitten. Die wahre Genugtuung liegt darin, zu wissen, dass unsere Arbeit das Spiel für dich ein kleines bisschen besser macht. Wenn das so ist, würden wir uns freuen, davon zu hören!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Hier sind ein paar Möglichkeiten, wie du uns helfen kannst, mehr Spieler zu erreichen."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Feedback geben: Einen Fehler gefunden oder eine Idee? Sag es uns auf Discord. Dein Feedback hilft uns, das Add-on zu verbessern, und Pull-Requests sind jederzeit willkommen."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Einem Freund erzählen: Kennst du jemanden, dem dieses Add-on gefallen könnte? Erzähl ihm davon. Mundpropaganda hilft mehr Spielern, großartige Add-ons zu entdecken."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorit auf CurseForge: Öffne unten den CurseForge-Link, melde dich an und klicke auf den Stern unter der Schaltfläche Download. Favoriten helfen mehr Spielern, das Add-on zu entdecken."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star auf GitHub: Öffne unten den GitHub-Link, melde dich an und klicke oben rechts auf Star. Sterne helfen dem Projekt, sich für weitere kostenlose Entwicklerwerkzeuge zu qualifizieren."

L["OPTIONS_FEEDBACK"] = "Feedback und Unterstützung"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Links für Feedback und Unterstützung"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Um einen Link zu kopieren, klicke in sein Feld und drücke dann Strg+A und Strg+C."
L["OPTIONS_VERSION"] = "Version %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's headerless Enable Consumable Macros toggle; Enable
    Macro Names on Buttons sits under Action Bars at the foot of the page.
]]
L["TAB_CONSUMABLE_MACROS"] = "Verbrauchsgüter-Makros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go erstellt ein Makro pro Verbrauchsgut und hält es aktuell, während sich deine Taschen ändern, damit der Button auf deiner Leiste immer zum besten Gegenstand greift, den du dabeihast. Wähle unten, welche Makros erstellt werden; die Einstellungen jedes Makros stehen auf einer eigenen Seite unter dieser."

-- Action Bars, at the foot of the Consumable Macros page: Macro Names on Buttons
L["OPTIONS_ACTION_BARS_HEADER"] = "Aktionsleisten"
L["OPTIONS_MACRO_NAMES"] = "Makronamen auf Buttons aktivieren"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Zeigt den Makronamen-Text auf den Buttons deiner Aktionsleisten an, den Good to Go standardmäßig ausblendet."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Zu erstellende Makros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Wähle, welche Makros Good to Go erstellt und pflegt. Wenn du eines deaktivierst, wird es auch entfernt. Du findest sie im Reiter Allgemeine Makros des Makrofensters, bereit zum Ziehen auf deine Aktionsleisten."
L["OPTIONS_MACROS_WINDOW"] = "Makrofenster"
L["OPTIONS_OPEN"] = "Öffnen"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Öffnet das Makrofenster des Spiels im Reiter Allgemeine Makros, wo diese Makros liegen."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"Erstellt und pflegt dieses Makro und entfernt es, wenn du das Kästchen abwählst."

--[[
    Food & Drinks, the page under Consumable Macros (Options-Food-Drinks.lua).
    OPTIONS_FOOD_WATER_HEADER is its label in the settings tree and the end of
    its title. Its sections: Which Food Comes First (Use Conjured Food & Water
    First, Use Restock List Food & Water Last, Eat Buff Food When Already Well
    Fed), then the class and race options that change how you eat and drink.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Essen und Trinken"
L["OPTIONS_FOOD_DRINKS_DESCRIPTION"] =
	"Deine Essen- und Wasser-Makros essen und trinken das Beste, was du dabeihast. Diese Optionen ändern, was als das Beste gilt und wie du isst und trinkst. Buff-Essen und Schriftrollen, die du für ihre Buffs nutzt, findest du auf der Seite Selbstbuffs des Buff-Dienstes."
L["OPTIONS_FOOD_ORDER_HEADER"] = "Welches Essen zuerst kommt"
L["OPTIONS_FOOD_ORDER_DESCRIPTION"] =
	"Von zwei Speisen oder Getränken verwenden deine Makros das, was am meisten wiederherstellt. Diese Optionen ändern diese Reihenfolge."

--[[
    Eat Buff Food When Already Well Fed, last under Which Food Comes First,
    and in Buff Duty's Buff Food flyout. %s in its hover text is the client's
    name for the Well Fed buff.
]]
L["OPTIONS_BUFF_FOOD_WHEN_FED"] = "Buff-Essen auch essen, wenn schon satt"
L["OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT"] =
	'Deine Essen- und Wasser-Makros behandeln Buff-Essen wie jedes andere Essen und essen, was am meisten wiederherstellt. Aus hebt es für den Buff-Dienst auf, der es anbietet, wenn du "%s" brauchst, außer es ist alles, was du dabeihast.'

-- The scroll types on Buff Duty's Self-Buffs page. The other five are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_TYPES"] = "Schriftrollentypen in Prüfung einschließen"
L["OPTIONS_SCROLL_PROTECTION"] = "Schutz"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Schließt "%s" in die Prüfung auf fehlende Buffs ein.'

-- Use Conjured Food & Water First, the first option under Which Food Comes First.
L["OPTIONS_CONJURED_FIRST"] = "Herbeigezaubertes Essen und Wasser zuerst verwenden"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	"Deine Essen- und Wasser-Makros verwenden herbeigezaubertes Essen und Wasser vor allem anderen, auch wenn etwas in deinen Taschen mehr wiederherstellt, denn es kostet nichts und verschwindet kurz nach dem Ausloggen."
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Legt fest, auf welchen Stufen herbeigezaubertes Essen und Wasser Vorrang haben: auf jeder Stufe, nur beim Leveln oder nur auf Höchststufe. Die Kästchen darunter legen fest, in welchen Gruppen."

-- Use Restock List Food & Water Last, the second option under Which Food Comes First.
L["OPTIONS_RESTOCK_LAST"] = "Essen und Wasser der Nachschubliste zuletzt verwenden"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Von zwei Speisen oder Getränken, die gleich viel wiederherstellen, verwenden deine Essen- und Wasser-Makros das, was nicht auf deiner Nachschubliste steht. So bleibt, was der Restocker kauft, für später."

--[[
    The pages under Consumable Macros for the smaller macro families
    (Options-Potions-Mana-Gems.lua and its neighbors): each TAB_* is its label in the settings tree
    and the end of its title, and each *_DESCRIPTION the intro under it.
    Explosives takes OPTIONS_EXPLOSIVES_HEADER.
]]
L["TAB_POTIONS_MANA_GEMS"] = "Tränke und Manasteine"
L["OPTIONS_POTIONS_MANA_GEMS_DESCRIPTION"] =
	"Deine Heiltrank-, Manatrank- und Manastein-Makros verwenden das Beste, was du dabeihast, mit Ersatz für den Fall, dass es ausgeht."
L["TAB_BANDAGES"] = "Verbände"
L["OPTIONS_BANDAGES_DESCRIPTION"] =
	"Dein Verband-Makro verwendet den Verband, der am meisten heilt, unter denen, die deine Erste-Hilfe-Fertigkeit erlaubt."
-- The Bandages page's line under its description, pointing at the settings that change the Bandage macro.
L["OPTIONS_BANDAGES_SUMMARY"] =
	"Um einen Verband aus dem Makro herauszuhalten, setze ihn auf die Ignorierliste. Die Wahl für die Schnelle Regeneration der Trolle findest du auf der Seite Essen und Trinken."
L["TAB_HEALTHSTONE"] = "Gesundheitsstein"
L["OPTIONS_HEALTHSTONE_DESCRIPTION"] =
	"Dein Gesundheitsstein-Makro verwendet deinen besten Gesundheitsstein, mit Ersatz. Bei einem Hexenmeister erschafft ein Rechtsklick einen und ein Mittelklick einen Seelenbrunnen, sofern du ihn kennst."

-- Potions & Healthstones, the first section on Potions & Mana Gems.
L["OPTIONS_POTIONS_HEADER"] = "Tränke und Gesundheitssteine"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden (dies ist eine Blizzard-Einschränkung). Daher wird jedes Trank- und Gesundheitsstein-Makro im Voraus mit deinem besten Gegenstand und bis zu zwei Ersatzgegenständen erstellt. Bei längeren Kämpfen können das Symbol und der Tooltip veralten und den falschen Gegenstand anzeigen, aber ein Klick auf das Makro verwendet immer den besten Gegenstand, den du tatsächlich in deinen Taschen hast."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Essen und Wasser außerhalb des Kampfes in Trank-Makros verwenden"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Außerhalb des Kampfes isst du mit deinem Heiltrank-Makro dein bestes Essen und trinkst mit deinem Manatrank-Makro dein bestes Wasser. Im Kampf verwenden die Makros wie bisher deine Tränke. Tierfutter und das Herbeizaubern bleiben bei den Essen- und Wasser-Makros."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Gesundheitssteine mit Heiltrank-Makro kombinieren"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Fügt deinen besten Gesundheitsstein unten an das Heiltrank-Makro an, sodass ein Tastendruck einen Trank und einen Gesundheitsstein verwendet."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Manasteine und Runen"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s und einige andere Mana-Gegenstände teilen sich die Abklingzeit mit Manasteinen. Die Runen kosten bei der Verwendung Gesundheit, daher lässt das Manastein-Makro all diese Gegenstände weg, solange du sie nicht hinzufügst."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Runen und andere Mana-Gegenstände zum Manastein-Makro hinzufügen"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Nimmt %s, %s sowie jeden anderen Mana-Gegenstand, der sich die Abklingzeit mit Manasteinen teilt, in die Rangfolge deiner Manasteine auf, sodass das Manastein-Makro einen davon verwendet, wenn das deine beste Wahl ist oder du keine Manasteine mehr hast."

-- Refresh Pet Food Under, closing the Hunter section on Class Macros: "Refresh Under", as Buff Duty names its timing.
L["OPTIONS_REAPPLY"] = "Begleiterfutter auffrischen unter"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Behandelt den Futter-Buff deines Begleiters als abgelaufen, wenn er weniger Restzeit als deinen Schwellenwert hat, sodass dein Essen-Makro vor dem Pull einen frischen anbietet."
--[[
    Threshold dropdown, beside the Refresh Pet Food Under toggle, whose label
    carries the "under", so the values are plain durations.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen darf, bevor deine Makros einen frischen anbieten."
L["REAPPLY_THRESHOLD_ONE"] = "1 Minute"
L["REAPPLY_THRESHOLD_MANY"] = "%d Minuten"

-- Pet Food Buffs, in the Hunter section on Class Macros. OPTIONS_PET_HEADER names the feature in its When to Use hover text.
L["OPTIONS_PET_HEADER"] = "Tierfutter-Buffs"
-- The summary line under Class Macros' Hunter header.
L["OPTIONS_CLASS_MACROS_HUNTER_SUMMARY"] = "Halte deinen Begleiter über dein Essen-Makro satt."
L["OPTIONS_USE_PET_BUFFS"] = "Tierfutter-Buffs verwenden"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Fügt deinem Essen-Makro Tierfutter hinzu, wenn deinem Tier der "%s"-Buff fehlt, außer in Arenen.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Tierfutter-Arten in Prüfung einschließen"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Sprengstoff"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"Die @player-Option überspringt den Zielkreis und zündet den Sprengstoff direkt zu deinen Füßen. Ideal, wenn dein Ziel in Nahkampfreichweite ist. Der andere Klick wirft ihn wie gewohnt."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Klickbelegung"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Legt fest, welcher Klick den Sprengstoff wirft und welcher ihn zu deinen Füßen zündet."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Linksklick @player"
L["EXPLOSIVES_MODE_TOSS"] = "Linksklick Werfen"

--[[
    Class Macros panel (Options-Class-Macros.lua), nested under Consumable Macros. TAB_CLASS_MACROS
    is its label in the settings tree and the end of its title; OPTIONS_CLASS_MACROS_DESCRIPTION is the
    intro beneath it. The class and race headers below also head Food & Drinks' racial sections.
]]
L["TAB_CLASS_MACROS"] = "Klassenmakros"
L["OPTIONS_CLASS_MACROS_DESCRIPTION"] =
	"Diese Optionen gestalten die Makros einer bestimmten Klasse: Tier füttern, Seelenstein und Gifte werden unter Verbrauchsgüter-Makros eingeschaltet, und jeder Abschnitt wird auf jedem Charakter angezeigt."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Klassenoptionen: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Volksoptionen: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Benötigt das Add-on DruidMacroHelper. Eingeschaltet holen dich deine Heiltrank-, Manatrank- und Gesundheitsstein-Makros per Powershifting aus der Gestalt, verwenden den Gegenstand und versetzen dich zurück in Bärengestalt oder Katzengestalt, je nachdem, was du neben dem Kontrollkästchen wählst."
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper nutzen"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Erstellt Powershifting-Makros für Heiltränke, Manatränke und Gesundheitssteine mithilfe von DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Legt fest, in welche Gestalt dich deine Powershifting-Makros nach dem Verwenden des Gegenstands zurückverwandeln."
L["DRUID_FORM_BEAR"] = "Zurück in Bärengestalt"
L["DRUID_FORM_CAT"] = "Zurück in Katzengestalt"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Hält das Gifte-Makro mit dem besten nutzbaren Rang jedes Gifttyps bestückt. Linksklick trägt auf die Schildhand auf, Rechtsklick auf die Waffenhand; vorhandene Gifte werden automatisch ersetzt."
L["OPTIONS_POISON_MAIN_HAND"] = "Gifttyp Waffenhand"
L["OPTIONS_POISON_OFF_HAND"] = "Gifttyp Schildhand"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Rechtsklick auf deine Waffenhand aufträgt."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Linksklick auf deine Schildhand aufträgt."
-- The summary line under Food & Drinks' Rogue header.
L["OPTIONS_FOOD_DRINKS_ROGUE_SUMMARY"] = "Geh beim Hinsetzen zum Essen in Verstohlenheit, damit du ungesehen rastest."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating and
    drinking toggles. In both hover texts %s is the client's name for the
    spell the macro appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Verstohlenes Essen aktivieren"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Essen-Makro hinzu, damit du beim Essen verborgen bist."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Verstohlenes Trinken aktivieren"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Wasser-Makro hinzu, damit du beim Trinken verborgen bist."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Wähle eines. Du kannst gleichzeitig essen und trinken, aber Essen oder Trinken nach dem Verstecken beendet deine Tarnung."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Nimm einen getöteten Humanoiden oder Untoten ins Ziel, und dein Makro wirkt %s, solange der Zauber bereit ist, und spart so dein Essen und Trinken. Geht das nicht (die Leiche ist außer Reichweite oder der Zauber hat Abklingzeit), isst oder trinkt es wie gewohnt."
L["OPTIONS_CANNIBALIZE_EATING"] = "%s statt Essen verwenden"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Essen-Makro ihn, statt zu essen. Sonst isst es wie gewohnt."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "%s statt Trinken verwenden"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Wasser-Makro ihn, statt zu trinken. Sonst trinkt es wie gewohnt. Buff-Getränke haben weiterhin Vorrang."

--[[
    Trolls, headed with the client's name for the race. In the five texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"%s heilt dich auch im Kampf, wo du nicht essen kannst. Dein Essen-Makro kann den Zauber im Kampf wirken und dein Verband-Makro außerhalb des Kampfes, was deine Verbände spart."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "Im Kampf %s statt Essen verwenden"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"Im Kampf, wo du nicht essen kannst, wirkt dein Essen-Makro stattdessen %s. Außerhalb des Kampfes isst es wie gewohnt."
L["OPTIONS_RAPID_REGENERATION_BANDAGE"] = "Außerhalb des Kampfes %s statt Verband verwenden"
L["OPTIONS_RAPID_REGENERATION_BANDAGE_DESCRIPTION"] =
	"Außerhalb des Kampfes wirkt dein Verband-Makro %s, solange der Zauber bereit ist, und spart so deine Verbände. Bei Abklingzeit oder im Kampf verbindet es wie gewohnt."

--[[
    Ignore List panel (Options-Ignore-List.lua). One tree scope per list: the
    Global list, then the character playing and every other character with
    something ignored, each under its profile's name, which is never
    translated and has no key here. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map menu, the Macros
    panel, and the staples pop-up use it too). The mini-map menu's section
    keeps its own MINIMAP_IGNORE_LIST and MENU_CLEAR_IGNORE keys.
]]
L["TAB_IGNORE_LIST"] = "Ignorierliste"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ignorierte Gegenstände werden von keinem Makro ausgewählt. Essen, Wasser, Tränke, alles. Die Global-Liste gilt für jeden Charakter; die Liste eines Charakters gilt nur für diesen einen. Rechtsklicke auf den Minikarten-Button, um dein aktuell bestes Essen zu ignorieren."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Verschiebt diesen Gegenstand auf die Global-Liste, sodass er auf jedem Charakter ignoriert wird."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Wähle etwas aus, das du bei dir trägst. Die Taschen schließen sich, wenn das Optionsmenü geöffnet wird, daher ersetzt dies das Hineinziehen eines Gegenstands."
L["OPTIONS_IGNORE_ADD_ID"] = "Per Gegenstands-ID hinzufügen"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat, während dieses Feld ausgewählt ist."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat."
L["OPTIONS_IGNORE_REMOVE"] = "Entfernen"
L["OPTIONS_IGNORE_EMPTY"] = "Diese Liste ist leer."
L["OPTIONS_IGNORE_CLEAR"] = "Liste leeren"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Entfernt alle Gegenstände aus dieser Liste. Ein Charakter mit leerer Liste verschwindet aus der Liste links, außer es ist der, den du gerade spielst."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] =
	"Alle Gegenstände aus dieser Liste entfernen? Das lässt sich nicht rückgängig machen."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Lade ID: %d"
-- %d is how many of an item you carry, after its name in a menu ("x12").
L["ITEM_QUANTITY"] = "x%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Hält deine Taschen anhand deiner Nachschubliste gefüllt, indem automatisch bei Händlern eingekauft und Gegenstände zwischen Taschen und Bank verschoben werden. Gib %s ein, um die Liste zu öffnen."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Bei der Bank öffnen"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du die Bank besuchst."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Beim Händler öffnen"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du einen Händler besuchst."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Erinnerungen"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"Wähle, wann du einen Hinweis bekommst, dass auf deiner Nachschubliste etwas knapp wird."
-- Low Means Under, the dropdown above the three reminders: the share of a row's amount below which they call it low. Its values are percentages, written the same in every locale.
L["OPTIONS_RESTOCKER_LOW_THRESHOLD"] = "Knapp heißt unter"
L["OPTIONS_RESTOCKER_LOW_THRESHOLD_DESCRIPTION"] =
	"Ein Gegenstand gilt als knapp, wenn du weniger als diesen Anteil der Menge auf deiner Nachschubliste hast, und als aufgebraucht, wenn du keinen mehr hast. Darüber wird er nicht erwähnt."
L["OPTIONS_RESTOCKER_REMIND"] = "Nachschub-Erinnerungen in der Stadt aktivieren"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Gibt eine Chat-Erinnerung aus, wenn etwas auf deiner Nachschubliste knapp oder aufgebraucht ist und du ein Gasthaus oder eine Stadt erreichst oder dich beim Anmelden bereits dort befindest."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Nachschub-Erinnerungen beim Händler aktivieren"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Meldet, was noch knapp oder aufgebraucht ist, wenn du ein Händlerfenster schließt."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Nachschub-Erinnerungen bei der Bank aktivieren"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Meldet, was noch knapp oder aufgebraucht ist, wenn du die Bank schließt."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Goldreserve"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"Lege Gold zurück, das beim Einkaufen bei Händlern nie ausgegeben wird."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Goldreserve aktivieren"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"Beim Auffüllen wird das Gold, das du hier zurücklegst, nie ausgegeben."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Legt fest, wie viel Gold dir beim Auffüllen immer bleibt."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item it counted (out, then low), showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown under each reminder,
    beside its How Much to Say caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Legt fest, ob die Erinnerung nur eine Zeile umfasst oder für jeden knappen oder aufgebrauchten Gegenstand eine Zeile hinzufügt."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Wie ausführlich"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Einfach"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Ausführlich"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Ton abspielen"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Spielt zusätzlich zur Erinnerung einen Hinweiston ab, falls im Chat gerade viel los ist."
L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"] = "Spielt diesen Ton sofort ab, ob der Ton eingeschaltet ist oder nicht."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenster der Nachschubliste"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Wähle, wann sich deine Nachschubliste von selbst öffnet."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description. Its switch is SWITCH_INVENTORY_REPORT, under Features.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Zeigt im Tooltip eines Gegenstands an, wie viele davon du auf all deinen Charakteren dieses Realms besitzt."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Erfasste Charaktere"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Vergessen"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"%s vergessen? Taschen und Bank dieses Charakters verschwinden aus allen Gegenstands-Tooltips, und seine Wahl der Nachschubliste wird zurückgesetzt. Meldest du dich mit ihm an, wird er erneut erfasst."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Bereitschaftsbericht"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Gibt beim Start eines Bereitschaftschecks eine private Liste dessen aus, was noch behoben werden muss, und bleibt komplett still, wenn du bereit bist."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Bereitschaftsbericht-Einstellungen zurücksetzen"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Setzt jedes Kontrollkästchen und beide Schwellenwerte auf dieser Seite auf ihre Standardwerte zurück."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Alle Einstellungen des Bereitschaftsberichts auf ihre Standardwerte zurücksetzen?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Fehlende Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Fehlende Gegenstände"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Charakter"
-- The summary line under each of the Readiness Report's three headers.
L["OPTIONS_READINESS_BUFFS_SUMMARY"] = "Buffs, die du vor dem Pull haben solltest."
L["OPTIONS_READINESS_ITEMS_SUMMARY"] =
	"Verbrauchsgüter, die du dabeihaben solltest, und Ausrüstung, die eine Reparatur wert ist."
L["OPTIONS_READINESS_CHARACTER_SUMMARY"] = "Einstellungen an deinem Charakter, die man leicht vergisst."

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Meldet ein fehlendes Fläschchen. Ein Fläschchen oder je ein Kampf- und ein Wächterelixier gelten als abgedeckt."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] = 'Meldet einen fehlenden "%s"-Buff.'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Meldet einen fehlenden "%s"-Buff deines Begleiters. Dazu muss "Tierfutter-Buffs verwenden" auf der Seite Klassenmakros aktiviert sein, und dein Begleiter muss draußen sein.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Meldet fehlende Schriftrollen-Buffs, für die Schriftrollenarten, die auf der Seite Selbstbuffs des Buff-Dienstes angehakt sind."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Meldet sich, wenn auf niemandem in deiner Gruppe ein Seelenstein aktiv ist; einer in einer Tasche zählt nicht. Wird nur einem Hexenmeister gemeldet, der einen herstellen kann."
L["OPTIONS_READINESS_MAIN_HAND"] = "Waffenbuff (Waffenhand)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Waffenhand ohne temporäre Verzauberung. Jede Verzauberung zählt, und der Bericht schweigt dazu, wenn ein Schamane in deiner Gruppe ist."
L["OPTIONS_READINESS_OFF_HAND"] = "Waffenbuff (Schildhand)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Schildhand ohne temporäre Verzauberung. Jede Verzauberung zählt: ein Stein, ein Öl, ein Gift oder ein Schamanen-Waffenbuff."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Meldet eine Waffe in der Waffenhand, der eine temporäre Verzauberung fehlt. Schurken und Schamanen brauchen zwei, ein Gift oder eine Waffenverzauberung neben einem Öl oder Stein; alle anderen eine beliebige."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Meldet eine Waffe in der Schildhand, der eine temporäre Verzauberung fehlt. Schurken brauchen zwei, ein Gift neben einem Öl oder Stein; alle anderen eine beliebige."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Class Macros page has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Ablaufende Buffs innerhalb von"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	'Nennt jeden Buff auf dir, der bald abläuft, nicht nur die, die Good to Go anwendet, und ist unabhängig von "Ablaufende Buffs erneuern" auf der Seite Klassenmakros.'
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s Minuten"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 Minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen muss, damit der Bericht ihn nennt."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Gesundheitsstein dabeihast. Wird nur gemeldet, wenn ein Hexenmeister in deiner Gruppe ist, den man fragen kann, oder wenn du selbst der Hexenmeister bist."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manastein dabeihast. Wird nur einem Magier gemeldet, der einen herbeizaubern kann."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Heiltrank dabeihast, denn mitten im Kampf kann dir niemand einen reichen."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manatrank dabeihast. Wird nur gemeldet, wenn du eine Klasse spielst, die Mana verwendet."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Verband dabeihast, den du mit deiner Fertigkeit %s verwenden kannst."
L["OPTIONS_READINESS_DURABILITY"] = "Beschädigte Ausrüstung unter"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Verlinkt jeden angelegten Gegenstand unter dieser Haltbarkeit, pro Gegenstand gemessen, damit auch eine einzelne kaputte Waffe auftaucht."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie tief die Haltbarkeit eines Gegenstands sinken muss, damit der Bericht ihn verlinkt."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Aktuelle Skillung"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Gibt deine Talentverteilung aus sowie alle Punkte, die du noch nicht verteilt hast."
L["OPTIONS_READINESS_PVP"] = "PvP-Status aktiv"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Warnt, wenn dein PvP-Status aktiv ist."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Verlinkt angelegte Gegenstände, die nicht in einen Kampf gehören, etwa Reit- oder Angelausrüstung."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its whispers are the
    player's to word on the Rank Watch panel, with their default text in Data/Message-Languages.lua; its prints
    are fixed. Rank Sentinel is the standalone add-on Rank Watch replaces; its name stays as written in every
    locale.
]]
L["TAB_RANK_WATCH"] = "Rangwache"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Achtet in deiner Gruppe auf Zauber, die mit einem niedrigeren Rang gewirkt werden, als möglich wäre, und lässt den Wirkenden wissen, dass bei seinem Lehrer ein höherer Rang wartet. Ein Rang, den das Spiel von selbst senkt, etwa bei einem Buff auf einem Spieler niedriger Stufe, wird nie gemeldet."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s läuft noch, daher bleibt die Rangwache von Good to Go still, damit deine Gruppe nicht jeden niedrigen Rang doppelt gemeldet bekommt. Good to Go hat dieses Add-on abgeschaltet und seine eigene Rangwache eingeschaltet; lade neu, damit die Rangwache von Good to Go übernimmt."

-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Rang %d"

-- Printed when a group member whispers "Opt Out". %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'%s hat dir "Opt Out" geflüstert, daher ignoriert Rangwache diesen Spieler jetzt. Unter Rangwache > Ignorierte Spieler lässt sich das rückgängig machen.'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"Du hast %s gewirkt, und %s ist ab Stufe %d verfügbar. Besuche deinen Lehrer oder aktualisiere deine Aktionsleisten."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "Dein Begleiter %s hat %s gewirkt, und %s ist ab Begleiterstufe %d verfügbar."
L["RANK_WATCH_PRINT_SELF_DEMON"] = "Dein Dämon %s hat %s gewirkt, und %s ist ab Stufe %d verfügbar."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s hat %s gewirkt, und %s ist für diesen Spieler ab Stufe %d verfügbar."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"Der Begleiter %2$s von %1$s hat %3$s gewirkt, und %4$s ist für ihn ab Begleiterstufe %5$d verfügbar."
L["RANK_WATCH_PRINT_OTHER_DEMON"] =
	"Der Dämon %2$s von %1$s hat %3$s gewirkt, und %4$s ist für ihn ab Stufe %5$d verfügbar."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s übernimmt das Anflüstern."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Rangwache aktivieren"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Sagt dir Bescheid und flüstert deine Gruppenmitglieder an, wenn jemand einen Zauber mit einem niedrigeren Rang wirkt, als möglich wäre, damit er weiß, dass er zu seinem Lehrer sollte."

L["RANK_WATCH_MESSAGES_HEADER"] = "Benachrichtigungen"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] =
	"Wie Rangwache einen Spieler darauf hinweist, dass er einen niedrigen Rang gewirkt hat."
L["RANK_WATCH_WHISPER"] = "Gruppenmitglieder anflüstern"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Flüstert ein Gruppenmitglied an, das einen niedrigen Rang gewirkt hat. Nutzen mehrere Spieler in deiner Gruppe Rangwache oder Rank Sentinel, flüstert nur einer von ihnen."
--[[
    The tip's whisper composer, under the whisper toggle: one box for the caster's own low rank, one for a
    hunter's pet, one for a warlock's demon.
    TRANSLATORS: keep {spell}, {level} and {pet} exactly as written; they are the tokens players type into the
    whisper. In the TOKENS lines each %s is a token, in the order shown, drawn in blue.
]]
L["RANK_WATCH_TIP_MESSAGE_DESCRIPTION"] =
	"Legt fest, was Good to Go einem Gruppenmitglied flüstert, das einen niedrigen Rang gewirkt hat. {spell} wird zum gewirkten Zauber samt Rang, {level} zur Stufe, ab der es einen neueren Rang gibt. Leer lassen, um nichts zu flüstern."
L["RANK_WATCH_TIP_TOKENS"] = "Platzhalter: %s der gewirkte Zauber samt Rang, %s die Stufe des neueren Rangs"
L["RANK_WATCH_TIP_PET_MESSAGE"] = "Begleiter-Flüstern"
L["RANK_WATCH_TIP_PET_MESSAGE_DESCRIPTION"] =
	"Legt fest, was Good to Go einem Jäger flüstert, dessen Begleiter einen niedrigen Rang gewirkt hat. {pet} wird zum Namen des Begleiters, {spell} zum gewirkten Zauber samt Rang und {level} zur Begleiterstufe, ab der es einen neueren Rang gibt. Leer lassen, um nichts zu flüstern."
L["RANK_WATCH_TIP_PET_TOKENS"] =
	"Platzhalter: %s der Name des Begleiters, %s der Zauber samt Rang, %s die Begleiterstufe des neueren Rangs"
L["RANK_WATCH_TIP_DEMON_MESSAGE"] = "Dämonen-Flüstern"
L["RANK_WATCH_TIP_DEMON_MESSAGE_DESCRIPTION"] =
	"Legt fest, was Good to Go einem Hexenmeister flüstert, dessen Dämon einen niedrigen Rang gewirkt hat. {pet} wird zur Dämonenart, etwa Wichtel, {spell} zum gewirkten Zauber samt Rang und {level} zur Stufe, ab der es einen neueren Rang gibt. Leer lassen, um nichts zu flüstern."
L["RANK_WATCH_TIP_DEMON_TOKENS"] =
	"Platzhalter: %s die Dämonenart, %s der Zauber samt Rang, %s die Stufe des neueren Rangs"
L["RANK_WATCH_PRINT"] = "Niedrige Ränge der Gruppe ausgeben"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"Gibt den niedrigen Rang eines Gruppenmitglieds in deinem Chat aus. Deine eigenen niedrigen Ränge werden immer ausgegeben."
L["RANK_WATCH_GRACE_HEADER"] = "Schonfrist"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"Ein neuer Rang wird erst gemeldet, wenn der Wirkende seine Stufe um so viele Stufen überschritten hat, damit niemand von einem Rang hört, den er gerade erst erreicht und noch nicht trainieren konnte."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Schonfrist auf Höchststufe"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"Lässt bei einem Charakter auf Höchststufe jeden Rang in Ruhe, der innerhalb so vieler Stufen vor der Höchststufe erlernt wird. Bei 0 wird jeder Rang gemeldet, den er haben könnte."
L["RANK_WATCH_GRACE_LEVELING"] = "Schonfrist beim Leveln"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"Lässt bei einem Charakter, der noch levelt, jeden Rang in Ruhe, der höchstens so viele Stufen unter seiner eigenen erlernt wird, damit er Zeit hat, zu einem Lehrer zu kommen."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 Stufe"
L["RANK_WATCH_GRACE_LEVELS"] = "%d Stufen"

--[[
    The opt-out whispers' composer, under the tip's, while Whisper Group Members is on: the offer sent with a
    player's second tip in a session, and the reply to a group member who whispers "Opt Out" back.
    TRANSLATORS: keep "Opt Out" in English; it is the words a player whispers back, and Good to Go listens for
    exactly those.
]]
L["RANK_WATCH_OPT_OUT_MESSAGE"] = "Abmeldeangebot"
L["RANK_WATCH_OPT_OUT_MESSAGE_DESCRIPTION"] =
	'Legt fest, was Good to Go einem Spieler direkt nach seinem zweiten Rang-Tipp in einer Sitzung flüstert. Sag ihm, er soll mit "Opt Out" antworten. Leer lassen, um kein Angebot zu senden.'
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE"] = "Abmeldeantwort"
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE_DESCRIPTION"] =
	'Legt fest, was Good to Go einem Gruppenmitglied zurückflüstert, das "Opt Out" flüstert. Leer lassen, um keine Antwort zu senden.'
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'Wenn Rangwache jemanden in einer Sitzung zum zweiten Mal anflüstert, erklärt sie danach, wie man sich abmeldet. Flüstert er dir "Opt Out", während er in deiner Gruppe ist, landet er unter Ignorierte Spieler, du antwortest mit einer Bestätigung, und er hört von dir nie wieder etwas über Ränge. Um selbst jemanden in Ruhe zu lassen, nimm ihn ins Ziel und gib /gtg ignore ein.'
--[[
    Who whispers for your group: a silver line under Whisper Group Members. %s is one of the three answers
    below, RANK_WATCH_WHISPERER_SELF, _OTHER or _NONE.
]]
L["RANK_WATCH_WHO_WHISPERS_FORMAT"] = "Wer gerade für deine Gruppe flüstert: %s"
L["RANK_WATCH_WHISPERER_SELF"] = "Du selbst."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s, daher siehst du nur die Chatmeldung."
L["RANK_WATCH_WHISPERER_NONE"] = 'Niemand: "Gruppenmitglieder anflüstern" ist aus.'

--[[
    Ability Alerts While Leveling: the panel for the level-up prints (LEVEL_UP_SPELLS and the rest), under
    Enhanced Spellbook. RANK_WATCH_LEVEL_UP_HEADER is its name in the settings tree, the page title and the
    mini-map menu; its switch is SWITCH_ABILITY_ALERTS, also in the root panel's Features section.
]]
L["RANK_WATCH_LEVEL_UP_HEADER"] = "Fähigkeitshinweise beim Leveln"
L["ABILITY_ALERTS_DESCRIPTION"] =
	"Wenn du eine Stufe aufsteigst, listet der Chat die Fähigkeiten auf, die dein Klassenlehrer für dich hat, jede mit Symbol und einem Link, über den du fahren kannst."
L["SWITCH_ABILITY_ALERTS"] = "Fähigkeitshinweise beim Leveln aktivieren"
L["SWITCH_ABILITY_ALERTS_DESCRIPTION"] =
	"Listet im Chat die Fähigkeiten auf, die dein Klassenlehrer für dich hat, wenn du eine Stufe aufsteigst."
L["RANK_WATCH_LEVEL_UP_PAST"] = "Übersprungene Fähigkeiten einbeziehen"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] =
	"Fügt eine Zeile für Fähigkeiten früherer Stufen hinzu, die du noch nicht erlernt hast."
L["RANK_WATCH_LEVEL_UP_PET"] = "Begleiterfähigkeiten einbeziehen"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] =
	"Fügt die Fähigkeiten des Tierausbilders für Jäger oder die Grimoires des Dämonenausbilders für Hexenmeister hinzu, die mit deiner neuen Stufe verfügbar werden."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "Übersprungene Begleiterfähigkeiten einbeziehen"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] =
	"Nur Jäger: Fügt eine Zeile für Fähigkeiten des Tierausbilders früherer Stufen hinzu, die du noch nicht erlernt hast. Hexenmeister erhalten diese Zeile nicht, da das Spiel nicht verrät, welche Grimoires ein Dämon gelernt hat, solange er nicht beschworen ist."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Ignorierte Spieler"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "Rangwache meldet diese Spieler nie."
L["RANK_WATCH_IGNORED_NONE"] = "Noch niemand."
L["RANK_WATCH_IGNORED_REMOVE"] = "Nicht mehr ignorieren"
L["RANK_WATCH_IGNORE_TARGET"] = "Ziel ignorieren"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "Fügt den Spieler, den du im Ziel hast, der Liste hinzu."
L["RANK_WATCH_IGNORE_ADDED"] = "Rangwache ignoriert jetzt %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"%s nicht gefunden. Geh mit diesem Spieler in eine Gruppe oder nimm ihn ins Ziel und versuch es dann erneut."
-- %s is the command, /gtg ignore Name (RANK_WATCH_IGNORE_COMMAND), drawn in blue.
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Nimm einen Spieler ins Ziel oder gib %s ein."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Name"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"Rangwache meldet diesen Spieler nicht mehr. Ohne Namen wird dein Ziel ignoriert."

-- Reported Ranks, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"Die Ränge, die Rangwache meldet, nach Klasse sortiert. Wähle einen niedrigen Rang ab, den du absichtlich nutzt, und Rangwache lässt ihn in Ruhe. Jede Fähigkeit ist aufgeführt. Die, die Rangwache standardmäßig nicht überwacht, etwa Heilungen, Talente und Versengen Rang 1, sind anfangs abgewählt. Der höchste Rang einer Fähigkeit ist ausgegraut, da nichts darüber liegt."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (Stufe %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "Meldet diesen Rang, wenn ein höherer verfügbar ist."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "Der höchste Rang. Darüber gibt es nichts, daher wird er nie gemeldet."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s-Begleiter"
L["RANK_WATCH_TRACK_ALL"] = "Alle anhaken"
L["RANK_WATCH_TRACK_ALL_DESCRIPTION"] = "Meldet jeden Rang unterhalb des höchsten auf dieser Seite."
-- Asked before Check All or Uncheck All goes through; %s is the page's class, or its pets ("Hunter Pets").
L["RANK_WATCH_TRACK_ALL_CONFIRM"] = "Jeden Rang unterhalb des höchsten auf der Seite %s melden?"
L["RANK_WATCH_UNTRACK_ALL_CONFIRM"] = "Keinen Rang auf der Seite %s mehr melden?"
L["RANK_WATCH_TRACK_NONE"] = "Alle abwählen"
L["RANK_WATCH_TRACK_NONE_DESCRIPTION"] = "Meldet keinen Rang auf dieser Seite mehr."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Eine Liste namens "%s" existiert bereits.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Kein Gegenstand mit ID %d."
L["RESTOCKER_DISABLED"] = "Der Restocker ist aus. Schalte ihn unter Optionen > AddOns > Good to Go > Restocker ein."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = 'Keine Nachschubliste namens "%s".'
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Auffüllen abgeschlossen. Halte Shift beim Öffnen der Bank, um das Auffüllen zu überspringen. Gib %s ein, um deine Nachschubliste zu bearbeiten."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Auffüllen gestoppt. Deine Taschen und deine Bank sind voll."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Auffüllen gestoppt. Deine Bank ist voll; mache einen Platz frei und öffne sie erneut."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Auffüllen gestoppt. Deine Taschen sind voll; mache einen Platz frei und öffne die Bank erneut."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Auffüllen gestoppt. Es konnte kein Fortschritt erzielt werden."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Auffüllen gestoppt. Konnte nicht verschieben: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (überschüssig)"
L["RESTOCKER_STOPPED_ERROR"] = "Auffüllen wegen eines Fehlers gestoppt: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Dieser Händler führt nicht alle Zutaten, die deine Gifte benötigen. Es wird keine davon gekauft."
-- Printed on reaching an inn or a city while something on the Restock List is low or out. %s is the counts sentence (RESTOCKER_LOW_ONE and the rest, below).
L["RESTOCKER_TOWN_REMINDER"] = "Denk daran, deine Vorräte aufzufüllen, solange du in der Stadt bist! %s"

--[[
    The Restock window's status line (Restocker-Window-Footer.lua): every row
    still short in your bags, Buy on or off, whatever the reminders' Low Means
    Under threshold, then how many of those a merchant would buy. The window
    is the full picture; the reminders say only what is low or out, in the
    counts sentence below.

    TRANSLATORS: the counts are of Restock List rows ("items"), each short by
    anything from one to a full stack. In SHORT_BUY the first %d is the short
    rows and the second the ones with Buy on. With none to buy, the rest come
    from the bank. SHORT_ITEMS_TITLE titles the line's hover, which lists
    every short item with have/keep.
]]
L["RESTOCKER_SHORT_BUY"] = "%d Gegenstände fehlen, %d zu kaufen."
L["RESTOCKER_SHORT_ONE_BUY"] = "1 Gegenstand fehlt, 1 zu kaufen."
L["RESTOCKER_SHORT_NONE_TO_BUY"] = "%d Gegenstände fehlen. Hol sie aus deiner Bank."
L["RESTOCKER_SHORT_ONE_NONE_TO_BUY"] = "1 Gegenstand fehlt. Hol ihn aus deiner Bank."
L["RESTOCKER_SHORT_ITEMS_TITLE"] = "Fehlende Gegenstände"

--[[
    The counts sentence every reminder's headline is built on
    (ns.RestockReminderCounts). OUT counts rows the bags hold none of; LOW
    counts rows they hold some of but less than the Low Means Under share of
    (restockLowThreshold). Rows at or above that line are never mentioned.
    Out leads, so an empty slot is the first thing read.

    The plain forms follow RESTOCKER_TOWN_REMINDER on arriving in town; the
    STILL forms stand alone after closing a merchant or the bank, since you
    have just shopped. When both counts are present only the out count takes
    a noun, so OUT_AND_LOW_ONE is "out of 1 item" and the low %d needs none;
    a locale whose grammar wants a noun on both can add one in its own words.
]]
L["RESTOCKER_LOW_ONE"] = "Bei 1 Gegenstand wird es knapp."
L["RESTOCKER_LOW_MANY"] = "Bei %d Gegenständen wird es knapp."
L["RESTOCKER_OUT_ONE"] = "1 Gegenstand ist aufgebraucht."
L["RESTOCKER_OUT_MANY"] = "%d Gegenstände sind aufgebraucht."
L["RESTOCKER_OUT_AND_LOW_ONE"] = "1 Gegenstand ist aufgebraucht, und bei %d wird es knapp."
L["RESTOCKER_OUT_AND_LOW_MANY"] = "%d Gegenstände sind aufgebraucht, und bei %d wird es knapp."
L["RESTOCKER_STILL_LOW_ONE"] = "Bei 1 Gegenstand ist es noch knapp."
L["RESTOCKER_STILL_LOW_MANY"] = "Bei %d Gegenständen ist es noch knapp."
L["RESTOCKER_STILL_OUT_ONE"] = "1 Gegenstand ist noch immer aufgebraucht."
L["RESTOCKER_STILL_OUT_MANY"] = "%d Gegenstände sind noch immer aufgebraucht."
L["RESTOCKER_STILL_OUT_AND_LOW_ONE"] = "1 Gegenstand ist noch immer aufgebraucht, und bei %d ist es knapp."
L["RESTOCKER_STILL_OUT_AND_LOW_MANY"] = "%d Gegenstände sind noch immer aufgebraucht, und bei %d ist es knapp."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Deine Nachschubliste wurde aufgewertet."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d wird zu %sx%d."

--[[
    Verbose follow-up line, one per item the headline counted, out first and
    then low: { have, wanted, item link }.
    Shared by all three reminders. Wordless on purpose -- the headline above it
    supplies the context, so there is nothing here to translate. It stays a
    locale key anyway so a locale that needs a different order can reorder it
    (same as RESTOCKER_STUCK_ITEM_FORMAT).
]]
L["RESTOCKER_REMINDER_ITEM"] = "%d/%d %s"

--[[
    Printed after buying at a vendor. Counts restocking orders FILLED -- Restock
    List rows and poison ingredients whose whole requested amount was ordered --
    not BuyMerchantItem calls. Forty juice bought in two stacks of twenty is one
    order filled; six of a requested twenty is not one at all, and belongs to
    the partial line below.

    The claim has to be earned: PurchaseMerchantItem returns nothing, and the
    caller decides filled or partly filled once per order, after the last slot,
    from the units that order bought. What the vendor did not stock is
    deliberately not mentioned here: the mini-map menu's Restocker block owns the
    outstanding state, this line owns the event, and neither repeats the other.
]]
L["RESTOCKER_RESTOCKED_ONE"] = "1 Nachschubposten erfüllt."
L["RESTOCKER_RESTOCKED_MANY"] = "%d Nachschubposten erfüllt."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 Nachschubposten teilweise erfüllt."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d Nachschubposten teilweise erfüllt."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Deine Taschen waren voll, bevor alles gekauft war."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "Nicht genug Gold, um das Auffüllen abzuschließen."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing was bought at this merchant; the second sentence says where
    the reserve is changed, by the options panel's own path.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Du hast weniger als %s, deine zurückgelegte Goldreserve, daher wurde nichts gekauft. Ändere sie unter Optionen > AddOns > Good to Go > Restocker."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[Name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Legt eine Liste mit diesem Namen an."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Löscht die Liste mit diesem Namen."
-- Printed for a /restock word the command doesn't know, before the command list. The first %s is the word typed, the second /restock help, drawn in blue.
L["RESTOCKER_SLASH_UNKNOWN"] = 'Unbekannter Restocker-Befehl "%s". Gib %s ein, um die Liste zu sehen.'
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Benennt die aktuelle Liste auf diesen Namen um."
L["RESTOCKER_HELP_PROFILE_COPY"] =
	"Ersetzt nach einer Rückfrage die aktuelle Liste durch eine Kopie der Liste mit diesem Namen."
--[[
    TRANSLATORS: /restock profile copy's confirm. The first %s is the list in
    use, which is replaced, the second the list copied, both in gold.
    ALSO_USED_BY follows it when another character uses the list in use: the
    first %s is the list, the second their names, joined like the window's
    Used By line. REPLACE is the confirm's button.
]]
L["RESTOCKER_PROFILE_COPY_CONFIRM"] =
	"Alles auf %s durch eine Kopie von %s ersetzen? Das lässt sich nicht rückgängig machen."
L["RESTOCKER_PROFILE_COPY_CONFIRM_ALSO_USED_BY"] = "%s wird auch von %s genutzt."
L["RESTOCKER_REPLACE"] = "Ersetzen"
L["RESTOCKER_HELP_PROFILE_USE"] = "Weist diesem Charakter die Liste mit diesem Namen zu."

--[[
    Starter List pop-up, the staples window: offers staples at login when the
    Restock List is empty, and on demand from the Restock List window's Pick
    Staples button. The staples logic is in
    Features/Restocker/Restocker-Starter-List.lua, the window in
    Features/Restocker/Restocker-Starter-Window.lua. The six
    food staples reuse the DIET_ keys above, so each food row carries the
    client's own pet diet name.

    The title is its own, and the call site puts the add-on's full name
    after it (STARTER_POPUP_TITLE // ADDON_TITLE): at login this window
    opens with nothing else of the add-on's on screen, so its title bar is
    all that says whose it is.

    The intro is one paragraph: an opening sentence that answers to how the
    window was reached (LOGIN when it opened by itself at login, which checks
    a few staples before it opens; otherwise EMPTY over an empty list and
    STOCKED over one that has items), then HOW, which says what a check
    does. The two are run together with a space at the call site, so each
    has to stand as whole sentences.
    The way back in (COMMAND_HINT) is a second paragraph, shown only when the
    window opened by itself at login; from the Pick Staples button the list it
    names is open right behind it.
]]
L["STARTER_POPUP_TITLE"] = "Grundvorräte"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Fertig"
-- Gray, in the Staples window's body when no staple fits this character yet.
L["STARTER_NOTHING_TO_OFFER"] = "Für deine Klasse und Stufe gibt es noch nichts hinzuzufügen."
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Wir haben ein paar Grundvorräte für deine Klasse auf deine Nachschubliste gesetzt. Entferne den Haken bei allem, was du nicht willst."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Deine Nachschubliste ist leer, also lass uns ein paar Gegenstände hinzufügen, damit du loslegen kannst."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Wähle die Grundvorräte, die aufgefüllt bleiben sollen."
L["STARTER_POPUP_INTRO_HOW"] =
	"Alles, was du anhakst, wird automatisch aufgefüllt, sobald du einen Händler oder deine Bank öffnest. Die meisten Grundvorräte werten sich mit deiner Stufe von selbst auf, sodass du immer das Beste dabeihast."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Du kannst diese Liste jederzeit anpassen oder später weitere Gegenstände hinzufügen, indem du %s eingibst."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Essen und Wasser"
L["STARTER_POPUP_FOOD_HEADER"] = "Essen"
L["STARTER_POPUP_AMMO_HEADER"] = "Munition"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Kugeln"
L["STARTER_POPUP_ARROWS"] = "Pfeile"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenzien und Werkzeuge"
L["STARTER_POPUP_POISONS_HEADER"] = "Gifte"
-- %s is the client's name for the Rogue class, rogue-colored, and the colon follows it directly.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s: Setze das fertige Gift auf deine Liste, und Good to Go kauft die Zutaten automatisch bei jedem Händler, der sie alle führt."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Fügt %s zu deiner Nachschubliste hinzu, hält %d davon in deinen Taschen und wertet sie mit deiner Stufe auf."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Fügt %s zu deiner Nachschubliste hinzu und hält %d in deinen Taschen bereit."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 Stapel"
L["STARTER_POPUP_STACK_MANY"] = "%d Stapel"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Wie viele Stapel vorrätig bleiben sollen, wobei ein Stapel %d Stück umfasst."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Wie viele vorrätig bleiben sollen, jeweils auf einem eigenen Taschenplatz, da sie sich nicht stapeln lassen."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Nachschubliste"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Gegenstände filtern..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Leeren"
L["RESTOCKER_ADD_BUTTON"] = "Hinzufügen"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Grundvorräte wählen"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Wähle aus den Grundvorräten für deine Klasse und Stufe: Essen, Wasser, Munition, Gifte und Reagenzien. Was du anhakst, wird dieser Liste hinzugefügt, und was du abwählst, wird entfernt."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Gegenstand hinzufügen"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Ziehe einen Gegenstand aus deinen Taschen hierher oder irgendwo auf dieses Fenster, oder gib eine Gegenstands-ID ein und drücke Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Ziehen oder ID eingeben"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Stattdessen ID eingeben."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Schon auf dieser Liste."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Gegenstand aus Taschen hinzufügen"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Alle Gegenstände in deinen Taschen, die noch nicht auf dieser Liste stehen, bereit zum Hinzufügen."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nichts in deinen Taschen zum Hinzufügen"

--[[
    The list bar across the top of the window: the selector, the characters on
    the list, and Manage Lists.

    USED_BY's %s is those characters, the client's own names joined with
    LIST_SEPARATOR, which also joins them on the selector's menu and in the
    delete confirmation. Each name is colored by its class at the call site.
    Keep USED_BY short: the line shares its row with the selector and the
    Manage Lists button, and truncates when it outgrows the space. MANAGE is
    that button's caption and the title of its tooltip.
]]
L["RESTOCKER_PROFILE_LABEL"] = "Liste"
L["RESTOCKER_PROFILE_TOOLTIP"] = "Weist diesem Charakter eine andere Nachschubliste zu oder legt eine neue an."
L["RESTOCKER_USED_BY"] = "Genutzt von %s"
L["RESTOCKER_MANAGE"] = "Listen verwalten"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Lege eine neue Liste an oder kopiere diese, benenne sie um oder lösche sie."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Neue Liste"
L["RESTOCKER_MANAGE_COPY"] = "Diese Liste in eine neue kopieren"
L["RESTOCKER_RENAME_PROFILE"] = "Diese Liste umbenennen"
L["RESTOCKER_MANAGE_DELETE"] = "Diese Liste löschen"
-- TRANSLATORS: gray on Delete This List's right, how many characters use the list ("Used by 2").
L["RESTOCKER_LIST_USED_BY_COUNT"] = "Genutzt von %d"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Kopie"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Umbenennen"
L["RESTOCKER_RENAME_TOOLTIP"] = "Benennt diese Liste für jeden Charakter um, der sie verwendet."
--[[
    The delete confirmation, a paragraph per fact, joined with blank lines in
    code: QUESTION, the list's name (colored at the call site), what happens
    next, and FINAL.

    "What happens next" is SHARED followed by SWITCH or LAST, run together as
    one paragraph, so each has to stand as a full sentence. SHARED appears only
    when other characters are on the list; its %s is their names, joined with
    LIST_SEPARATOR, and ONE or MANY follows how many there are.

    SWITCH says where this character lands: %s is the top list in the List
    selector, colored at the call site. LAST stands in for it when the list
    being deleted is the only one, which is the one delete that makes a list.
]]
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Möchtest du diese Liste wirklich löschen?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s nutzt sie ebenfalls und findet beim nächsten Anmelden eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s nutzen sie ebenfalls und finden beim nächsten Anmelden jeweils eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Du wechselst dann zu %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es ist die einzige verbliebene Liste, daher beginnst du mit einer neuen, leeren."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Das kann nicht rückgängig gemacht werden."
--[[
    The Upgrade toggle. One string serves both the column heading and every
    row's checkbox, so it has to read for a single item and for the whole
    column at once -- which is why it names categories rather than "this item".

    The categories are exactly the ladder kinds in each flavor folder's
    Consumable-Upgrade-Paths-{Game}.lua: food, water, arrow and bullet, poison,
    healing and mana potion, and the class reagents. Naming anything else here
    promises an upgrade that never arrives, since the toggle is disabled on any
    item that is not on a ladder -- which on a real list is most of them.
]]
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mit steigender Stufe aufwerten"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Erlaubt Good to Go, Essen, Wasser, Munition, Gifte, Tränke und Klassenreagenzien mit steigender Stufe auf bessere Gegenstände aufzuwerten."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Aufwertung"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Gegenstand"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Holen"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Lagern"
L["RESTOCKER_COLUMN_REPUTATION"] = "Ruf"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Behalten"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens; SHOWN, gray on their right, is how many of the items shown
    the column can be set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Die Überschrift legt dies für alle angezeigten Gegenstände fest."
L["RESTOCKER_BULK_ON"] = "Einschalten"
L["RESTOCKER_BULK_OFF"] = "Ausschalten"
L["RESTOCKER_BULK_SHOWN"] = "%d angezeigt"

L["RESTOCKER_GROUP_OTHER"] = "Sonstiges"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Neu"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Alle Gegenstände"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Noch nichts auf dieser Liste"
L["RESTOCKER_EMPTY_BODY"] =
	"Wähle Grundvorräte wie Essen, Wasser oder Klassenreagenzien, oder füge über das Menü oben beliebige Gegenstände aus deinen Taschen hinzu. Gegenstände auf dieser Liste werden automatisch aufgefüllt oder in deiner Bank eingelagert, damit deine Taschen aufgeräumt bleiben."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Gegenstände, die du irgendwo auf dieses Fenster ziehst, werden auch hinzugefügt."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nichts auf dieser Liste passt zu deinem Filter."
L["RESTOCKER_NO_MATCH_GROUP"] = "In dieser Kategorie ist nichts mehr übrig."

--[[
    The status line under the list. Its counts are RESTOCKER_SHORT_BUY and the
    rest above, and the all-stocked line is MINIMAP_RESTOCKER_STOCKED, so the
    window and the mini-map menu say the same thing in the same words.

    LIST_MORE_SENTENCE closes the Short Items tooltip when the list is longer than
    it shows. REMOVED_ITEM is a removed row's text, gray
    in its place on the list: %s is the item's name. UNDO is the button where
    its remove button was, which puts the item back; UNDO_TOOLTIP renders in
    the title slot.
]]
L["RESTOCKER_REMOVED_ITEM"] = "%s entfernt."
L["RESTOCKER_UNDO"] = "Rückgängig"
L["RESTOCKER_UNDO_TOOLTIP"] = "Diesen Gegenstand wieder auf die Liste setzen"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Diesen Gegenstand von der Nachschubliste entfernen"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Du kannst das in seiner Zeile rückgängig machen, bis sich die Liste ändert."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "In deinen Taschen behalten"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Wie viele du in deinen Taschen behalten willst. Die Zahl wird gelb, solange deine Taschen weniger enthalten, und eine 0 schickt bei aktiviertem Lagern alles in die Bank."
L["RESTOCKER_BUY_LABEL"] = "Kaufen"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Beim Händler kaufen"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Kauft die benötigte Menge beim Händler, wenn das Händlerfenster geöffnet ist."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Extra kaufen"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Kauft den gesamten begrenzten Vorrat eines Händlers an diesem Gegenstand, also Ware, die er nur nach und nach wieder auffüllt, auch über deinen Behalten-Wert hinaus."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "In der Bank lagern"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Lagert überschüssige Gegenstände in der Bank, wenn die Bank geöffnet ist, oder alle, wenn in der Behalten-Spalte 0 steht."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Aus der Bank holen"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Holt benötigte Gegenstände aus der Bank, wenn die Bank geöffnet ist."

-- Required-reputation control (per-item vendor gate).
--[[
    A standing's discount, gray on its row's right in the standings menu. The
    standings are the client's own labels (FACTION_STANDING_LABEL5 to 8), so
    only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT"] = "%d%% Rabatt"
L["RESTOCKER_REPUTATION_ANY"] = "Beliebig"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Benötigter Ruf beim Händler"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Legt fest, welchen Ruf ein Händler voraussetzt, bevor Good to Go bei ihm kauft, was auch den Preis senkt: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Mit einem Strich wird bei jedem Händler gekauft."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also gibt es nichts extra zu kaufen."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also spielt der Ruf keine Rolle."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Für diesen Gegenstand gibt es keine bessere Version zum Aufwerten."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go hat %s abgeschaltet, das es ersetzt. Jetzt neu laden, damit die alte Version nicht mehr läuft?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Jetzt neu laden"
L["POPUP_REPLACED_LATER"] = "Später"
-- The Spellbook's confirm buttons, each naming what it does; the other button is the client's Cancel.
L["POPUP_DELETE"] = "Löschen"
L["POPUP_RESET"] = "Zurücksetzen"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Deine Einstellungen aus %s wurden kopiert."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go hat deine Einstellungen aus %s kopiert und %s abgeschaltet, das es ersetzt. Jetzt neu laden, damit die alte Version nicht mehr läuft?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go hat %s gefunden, installiert, aber deaktiviert. Die Einstellungen übernehmen? Dabei werden die alten Add-ons wieder aktiviert und dein Interface neu geladen, danach wird ein weiteres Neuladen angeboten, um sie wieder abzuschalten."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go hat %s gefunden, installiert, aber deaktiviert. Die Einstellungen und Nachschublisten übernehmen? Dabei werden die alten Add-ons wieder aktiviert und dein Interface neu geladen, danach wird ein weiteres Neuladen angeboten, um sie wieder abzuschalten."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Übernehmen"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "Nein, danke"

--------------------------------------------------------------------------------
-- Options: Group Buffs and Reported Ranks
--------------------------------------------------------------------------------

-- The Group Buffs and Reported Ranks panels' titles, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Gruppenbuffs"
L["RANK_WATCH_TRACKED_HEADER"] = "Gemeldete Ränge"
L["TRACKED_ITEM_PENDING"] = "Gegenstand #%d"
L["TRACKED_SPELL_PENDING"] = "Zauber #%d"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Buff-Dienst"
L["BUFF_DUTY_DESCRIPTION"] = "Zeigt, wem deine Buffs fehlen. Klicke auf ein Symbol, um zu wirken."
L["BUFF_DUTY_ENABLE"] = "Buff-Dienst aktivieren"
L["BUFF_DUTY_NO_BUFFS"] =
	"Deine Klasse hat keine Buffs auf dieser Liste, daher erscheint das Fenster bei diesem Charakter nie."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Wann anzeigen"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Legt fest, wann das Fenster erscheinen kann."
L["BUFF_DUTY_WHEN_NONE"] = "Nichts ist angehakt, daher erscheint das Fenster nie."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"Buff-Dienst ist hier ausgeblendet. Das Spiel lässt Add-ons in diesem Gebiet keine Buffs sehen, daher kann er nicht erkennen, wem einer fehlt."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Legt fest, wo das Fenster erscheint: überall oder nur in einer Instanz, etwa einem Dungeon oder Schlachtzug."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Überall"
L["BUFF_DUTY_WHERE_INSTANCE"] = "In Instanz"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Zeigt das Fenster, wenn du eine dieser Klassen spielst."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Zeigt das Fenster, während du diese Klasse spielst."
L["BUFF_DUTY_HEADER"] = "Fenster"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Lass das Fenster dort, wo du es abgelegt hast, oder halte es im Kampf aus dem Weg."
L["BUFF_DUTY_LOCK"] = "Fenster sperren"
L["BUFF_DUTY_LOCK_DESCRIPTION"] =
	"Verhindert, dass das Fenster verschoben wird. Entsperrt lässt es sich an seinem Hintergrund ziehen."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Im Kampf ausblenden"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Blendet das Fenster während des Kampfes aus. Im Kampf kann die Liste nicht aktualisiert werden, daher behält ein sichtbar gelassenes Fenster seinen letzten Stand, bis der Kampf endet."
L["BUFF_DUTY_SHOW_HEADER"] = "Im Fenster anzeigen"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Fügt dem Fenster deine eigenen Buffs, die Fremden, die dich gebufft haben, und dein Ziel hinzu."
-- Return the Favor, Your Target and Ask for Buffs each name both their switch and the window row it adds.
L["BUFF_DUTY_FAVOR_ENABLE"] = "Gefallen erwidern"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Listet die Fremden auf, die dich kürzlich gebufft haben, samt den Buffs, die du ihnen zurückgeben kannst. Rechtsklicke auf ein Symbol, um jemanden von der Liste zu nehmen."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Legt fest, wie lange ein Fremder nach seinem letzten Buff auf der Liste bleibt."
L["BUFF_DUTY_TARGET_ENABLE"] = "Dein Ziel"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Listet dein Ziel auf, wenn es ein Spieler außerhalb deiner Gruppe ist, dem ein Buff fehlt, den du geben kannst."
L["BUFF_DUTY_TARGET_NPCS"] = "NPCs einbeziehen"
L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"] =
	"Listet auch einen freundlichen NPC auf, den du anvisierst, etwa den verwundeten Soldaten einer Quest, mit den Buffs, die du ihm geben kannst."
-- Under Your Target: an Ask row of the buffs of theirs you're missing, whispered for on a click or Cast Next Buff.
L["BUFF_DUTY_ASK_TARGET"] = "Dein Ziel um Buffs bitten"
L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"] =
	'Kann dein Ziel dir einen fehlenden Buff geben, steht er in einer Bitten-Zeile darunter. Klicke ihn an oder drücke "Nächsten Buff wirken", um höflich per Flüstern zu fragen. Niemand wird öfter als alle 5 Minuten um denselben Buff gebeten.'
--[[
    The ask to your target's composer, under Ask Your Target for Buffs.
    TRANSLATORS: keep {name} and {spells} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {name} then {spells}, drawn in blue.
]]
L["BUFF_DUTY_ASK_TARGET_MESSAGE_DESCRIPTION"] =
	"Legt fest, was Good to Go deinem Ziel flüstert, wenn du es über die Fragen-Zeile um einen Buff bittest. {name} wird zu seinem Namen und {spells} zu den erbetenen Buffs. Leer lassen, um nichts zu flüstern."
L["BUFF_DUTY_ASK_TARGET_TOKENS"] = "Platzhalter: %s sein Name, %s die Buffs"
L["BUFF_DUTY_ASK_OTHERS"] = "Um Buffs bitten"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	'Fügt dem Fenster eine Zeile "Um Buffs bitten" hinzu: die Schlachtzugsbuffs, die deiner Gruppe fehlen, und wie viele Spieler jeweils einen brauchen. Linksklicke auf einen, um deine Gruppe darum zu bitten, oder rechtsklicke, um die Spieler anzuflüstern, die ihn wirken können.'
--[[
    The whispered ask's composer, under Ask for Buffs.
    TRANSLATORS: keep {names} and {spell} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {names} then {spell}, drawn in blue.
]]
L["BUFF_DUTY_ASK_MESSAGE_DESCRIPTION"] =
	'Legt fest, was Good to Go den Spielern flüstert, die einen fehlenden Buff wirken können, wenn du ihn unter "Um Buffs bitten" rechtsklickst. {names} wird zu den Spielern, denen er fehlt, oder zu ihrer Anzahl, und {spell} zum Buff. Leer lassen, um nichts zu flüstern.'
L["BUFF_DUTY_ASK_TOKENS"] = "Platzhalter: %s die Spieler, denen er fehlt, oder ihre Anzahl, %s der Buff"
-- Group Buffs page: the Refresh section around Refresh Under.
L["BUFF_DUTY_REFRESH_HEADER"] = "Auffrischen"
L["BUFF_DUTY_REFRESH_SUMMARY"] = "Einen Buff erneut anbieten, bevor er ausläuft."
L["BUFF_DUTY_REFRESH"] = "Auffrischen unter"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Legt fest, wie wenig Restzeit ein Buff haben darf, bevor er als fehlend gilt, damit du ihn auffrischen kannst, bevor er ausläuft. Ein Buff, der nicht länger als diese Zeit hält, zählt erst, wenn er abgelaufen ist."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Als Tanks zählen"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Wer die Buffs erhält, die du für Tanks anbietest, etwa Dornen, wenn er keine eigene Rolle hat."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Legt fest, wann Spieler dieser Klasse als Tanks zählen. Eine Tank- oder Heilerrolle, die sie haben, geht immer vor."
L["BUFF_DUTY_TANKS_PETS"] = "Begleiter"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Legt fest, wann Begleiter als Tanks zählen. Begleiter erhalten außerdem die Buffs, die du für Alle anbietest."
L["BUFF_DUTY_TANKS_NEVER"] = "Nie"
L["BUFF_DUTY_TANKS_SOLO"] = "Beim Solospiel"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Immer"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Aus"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Tanks"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Heiler"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Alle"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Legt fest, wem %s angeboten wird."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Wähle für jeden Buff, wem er angeboten wird. Tanks und Heiler richten sich nach der Gruppenrolle, im Schlachtzug zählen aber nur Spieler, die als %s eingeteilt sind, als Tanks. Wer keine Rolle hat, zählt als Schaden, sofern Als Tanks zählen weiter unten nichts anderes festlegt."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Selbstbuffs"
L["BUFF_DUTY_SELF_DESCRIPTION"] =
	"Jeder Buff, den du dir selbst geben kannst, oben im Fenster angeheftet. Auch deine Gruppenbuffs stehen hier, für dich selbst: Wer sie sonst bekommt, legst du unter Gruppenbuffs fest."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "ein beliebiger Aspekt genügt"
L["BUFF_DUTY_SELF_NOTE_BLESSING"] = "einer deiner Segen genügt"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "eine beliebige Rüstung genügt"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "eine beliebige Aura genügt"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "ein beliebiger Schild genügt"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "eine beliebige Rüstung genügt"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "einer der beiden Dämonenbuffs genügt"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Aus"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Bei Fehlen"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Unter %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Legt fest, wann %s angezeigt wird: nie, nach dem Ablaufen oder wenn weniger als diese Zeit übrig ist."
-- The Self-Buffs panel's last box: consumables any class keeps up on itself (Winterfall Firewater), with a muted note after its name.
L["BUFF_DUTY_SELF_ITEMS_HEADER"] = "Verbrauchsgüter"
L["BUFF_DUTY_SELF_ITEMS_NOTE"] = "wenn eins in deinen Taschen ist"
--[[
    Hover text on the Consumables box's Well Fed row, whose buff food is
    whichever the Food macro would eat. %s is the client's name for Well Fed.
]]
L["BUFF_DUTY_WELL_FED_DESCRIPTION_FORMAT"] =
	'Wird angezeigt, solange dir "%s" fehlt und du Buff-Essen dabeihast. Klicke im Fenster darauf, um dein bestes zu essen.'
-- The Consumables box's Scrolls row: one icon per scroll buff you're missing, for the types checked under it.
L["BUFF_DUTY_SCROLLS"] = "Schriftrollen"
L["BUFF_DUTY_SCROLLS_DESCRIPTION"] =
	"Zeigt eine Schriftrolle für jeden fehlenden Schriftrollen-Buff, solange du diese Schriftrolle dabeihast. Klicke im Fenster auf eine, um sie zu lesen. Beobachtet werden die unten angehakten Schriftrollenarten."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Waffenbuffs"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Hake an, was jede Waffe tragen soll. Das Fenster bietet es an, wenn es fehlt oder bald abläuft, sofern es in deinen Taschen ist und zur Waffe passt."
-- The one timing for every weapon buff, at the top of the panel, captioned Refresh Under (BUFF_DUTY_REFRESH).
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Legt fest, wann ein Waffenbuff erneut angeboten wird: nach dem Ablaufen oder wenn weniger als diese Zeit übrig ist."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Öle"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Steine"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Köder"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Bietet %s für die Waffe in deiner %s an. Solange die Waffe keine deiner angehakten Optionen trägt, wird jede angeboten, die du hast."
L["BUFF_DUTY_SELF_ENABLE"] = "Deine Selbstbuffs"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Zeigt oben im Fenster deine eigenen Buffs, wenn sie fehlen oder bald ablaufen: die, die nur du dir selbst geben kannst, etwa eine Rüstung oder Inneres Feuer, und deine Gruppenbuffs auf dir. Welche, legst du unter Selbstbuffs fest."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Deine Waffenbuffs"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Zeigt die Gifte, Waffenverzauberungen, Öle, Steine und Köder, die deinen Waffen fehlen oder bald ablaufen, zusammen mit deinen Selbstbuffs oben im Fenster. Klicke auf einen Eintrag, um ihn aufzutragen. Welche, legst du unter Waffenbuffs fest."

-- The window itself
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Wirkt auf %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Trägt es auf die Waffe in deiner %s auf."
L["BUFF_DUTY_TOOLTIP_USE"] = "Niemand in deiner Gruppe hat einen Seelenstein. Wendet einen auf %s an."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Niemand in deiner Gruppe hat einen Seelenstein. Stellt einen her."
-- A Firestone or Spellstone icon with none in the bags conjures one.
L["BUFF_DUTY_TOOLTIP_CREATE_WEAPON"] = "Keiner in deinen Taschen. Stellt einen her."
-- A Self-Buffs consumable's icon (Winterfall Firewater).
L["BUFF_DUTY_TOOLTIP_USE_ITEM"] = "Benutzt eins aus deinen Taschen."
L["BUFF_DUTY_TOOLTIP_READ"] = "Liest eine aus deinen Taschen."
--[[
    The Options line at the foot of the Buff Duty window, and the menu it opens: the window's switches, its
    consumables and weapon buffs. %s in the weapon row's hover is the poison, imbue, oil, stone or lure.
]]
L["BUFF_DUTY_MENU_OPTIONS"] = "Optionen"
L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"] = "Bietet %s im Fenster an, wenn einer Waffe ihr Buff fehlt."
L["BUFF_DUTY_MENU_ALL_SETTINGS"] = "Alle Buff-Dienst-Einstellungen"
L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"] =
	"Öffnet die Einstellungen des Buff-Dienstes, mit jedem Zeitpunkt, jeder Klasse und jedem Buff, den das Fenster zeigen kann."
-- The Options menu's Window Opacity row, and its flyout of 0% to 100%. %d is the percent.
L["BUFF_DUTY_MENU_OPACITY"] = "Fensterdeckkraft"
L["BUFF_DUTY_MENU_OPACITY_DESCRIPTION"] =
	"Legt fest, wie deckend der Hintergrund des Buff-Dienst-Fensters ist. Text und Symbole bleiben, wie sie sind."
L["BUFF_DUTY_MENU_OPACITY_PERCENT"] = "%d%%"
-- The Options menu's Buff Food row, and its flyout of the buff food in your bags. In the food row's hover, the first %s is the food, the second the Well Fed buff's name.
L["BUFF_DUTY_MENU_BUFF_FOOD"] = "Buff-Essen"
L["BUFF_DUTY_MENU_FOOD_DESCRIPTION_FORMAT"] =
	'Bietet %s an, wenn du "%s" brauchst. Aus überspringt es zugunsten des nächstbesten Buff-Essens in deinen Taschen.'
L["BUFF_DUTY_MENU_NO_BUFF_FOOD"] = "Kein Buff-Essen in deinen Taschen."
-- The Self-Buffs buff food icon, while you aren't Well Fed.
L["BUFF_DUTY_TOOLTIP_EAT"] = "Isst eines aus deinen Taschen. Bleib sitzen, bis du satt bist."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Wirkt auf %s samt Gruppe."
-- A raid group icon's tooltip, its last line: the members who need it (%s, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT).
L["BUFF_DUTY_TOOLTIP_NEEDS"] = "Braucht ihn: %s."
-- A Return the Favor icon: the click targets them and casts; a right-click drops them from the list.
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Nimmt %s ins Ziel und wirkt. Rechtsklick nimmt diesen Spieler von der Liste."
-- The Ask row under Target: its label (%s is the target's name in their class color), and its icons' tooltip: who the whisper goes to, or, once asked, who and the whole minutes until they can be asked again.
L["BUFF_DUTY_ASK_TARGET_ROW"] = "%s fragen"
L["BUFF_DUTY_TOOLTIP_ASK_TARGET"] = "Flüstert %s an und fragt danach."
L["BUFF_DUTY_TOOLTIP_ASKED"] = "%s gefragt. Erneut fragen in %d Min."
-- An Ask for Buffs icon's menu, its ask rows: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it: %s is one or two names (LIST_PAIR_FORMAT), or BUFF_DUTY_OTHERS_ASK_PEOPLE past two.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "Buff anfragen (%s)"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "%s anflüstern"
-- An Ask for Buffs menu's name row, on the right: the whole minutes left on that player's buff, or Missing once there is none.
L["BUFF_DUTY_OTHERS_MINUTES"] = "%d Min."
L["BUFF_DUTY_OTHERS_MISSING"] = "Fehlt"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s fehlt %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s fehlt %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d Spielern fehlt der Buff %s."
-- The whispered ask's {names} past five missing players, when the player has written their own whisper, and the Ask for Buffs menu's whisper row past two players. %d is how many.
L["BUFF_DUTY_OTHERS_ASK_PEOPLE"] = "%d Spieler"
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"Buff-Dienst ist ausgeblendet, bis du einer Gruppe beitrittst, dich erneut einloggst oder neu lädst. Um ihn sofort zurückzuholen, mache einen Linksklick auf den Minikarten-Button. Um ihn für die Klasse %s ausgeschaltet zu lassen, entferne den Haken bei %s unter %s in %s."

-- The Cast Next Buff key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Nächsten Buff wirken"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Warte darauf, dass %s in Reichweite kommt."
L["BUFF_KEY_DONE"] = "Nichts mehr zu buffen."
L["BUFF_KEY_OFF"] = "Buff-Dienst ist aus."
--[[
    The Buff Duty window's last line, under Options, while the Cast Next Buff key has none: the options
    command (OPTIONS_COMMAND), then the key's name (BUFF_KEY). Kept to about three lines at the window's
    narrowest, with the command near the start so a line never breaks inside it.
]]
L["BUFF_DUTY_KEY_TIP"] = "Belege in %s eine Taste mit %s, um diese Buffs mit einer Taste zu wirken."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Nicht erlernt"
L["SECTION_CONSUMABLES"] = "Verbrauchsgüter-Makros"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Makrotext"
L["MENU_GROUP_MACRO_STORAGE"] = "Makro-Speicherort"
L["MENU_MACRO_TAB_CHARACTER"] = "Charakter"
L["MENU_MACRO_TAB_CHARACTER_DESCRIPTION"] =
	"Speichert dieses Makro bei den Makros deines Charakters, die nur dieser Charakter sieht. Nutzt Allgemein, solange diese Plätze voll sind."
L["MENU_MACRO_TAB_GENERAL"] = "Allgemein"
L["MENU_MACRO_TAB_GENERAL_DESCRIPTION"] =
	"Speichert dieses Makro bei den allgemeinen Makros, die dein ganzer Account teilt, und spart so Charakterplätze. Nutzt die deines Charakters, solange Allgemein voll ist."
L["MENU_MACRO_TAB_NOTE"] = "Verschiebt das Makro sofort und behält es auf deinen Aktionsleisten."
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Dynamischer Rang"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Der dynamische Rang richtet sich nach der Stufe eines freundlichen Spielers und wird nur außerhalb des Kampfes aktualisiert."
L["MENU_CAST_AT_CURSOR"] = "Am Cursor wirken"
L["MENU_TARGET_NEAREST_ENEMY"] = "Nächsten Feind anvisieren"
L["MENU_TARGET_NEAREST_FRIEND"] = "Nächsten Verbündeten anvisieren"
L["MENU_CAST_IF_SUMMONED"] = "%s wirken, wenn beschworen"
L["MENU_NEVER_TURN_OFF"] = "Nie ausschalten"
L["MENU_LEAVE_FORM_BEFORE"] = "Vor dem Wirken Gestalt verlassen"
L["MENU_RIGHT_CLICK_FOR"] = "Rechtsklick für %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Rechtsklick für Gruppenversion"
-- TRANSLATORS: the category menu's title and its gear's tooltip; %d is how many spells it lists, %s its name ("All 6 Heals").
L["MENU_CATEGORY_TITLE"] = "Alle %d %s"
L["MENU_ONCE_PER_COMBAT"] = "Einmal pro Kampf wirken"
L["MENU_ONCE_PER_TARGET"] = "Einmal pro Ziel wirken"
L["MENU_HIDE_ERRORS"] = "Fehler ausblenden"
L["MENU_MUTE_ERRORS"] = "Fehler stummschalten"
L["MENU_SWITCH_TO"] = "Zu %s wechseln"
L["MENU_START_AUTO_ATTACK"] = "Automatischen Angriff starten"
L["MENU_STOP_ATTACK"] = "Angriff beenden"
L["MENU_START_AUTO_SHOT"] = "Automatischen Schuss starten"
L["MENU_START_PET_ATTACK"] = "Begleiterangriff starten"
L["MENU_START_WAND"] = "Zauberstab starten"
L["MENU_STOP_CASTING"] = "Zaubern abbrechen"
L["MENU_STOP_CASTING_NOTE"] =
	"Nutze Zaubern abbrechen für Zauber, die nicht warten können, etwa Unterbrechungen und Bannzauber."
L["MENU_STOP_IF_CHANNELING"] = "Nicht beim Kanalisieren"
L["MENU_STOP_IF_STEALTHED"] = "Nicht in Verstohlenheit"
L["MENU_DUPLICATE"] = "Duplizieren"
L["MENU_DELETE"] = "Löschen"
L["MENU_DELETE_USED_ONE"] = "Auf 1 Leiste"
L["MENU_DELETE_USED"] = "Auf %d Leisten"
L["MENU_DELETE_DESCRIPTION"] =
	"Löscht dieses Makro, wodurch es von deinen Aktionsleisten verschwindet, und setzt alle seine Optionen zurück. Klicke oder ziehe es auf der Seite, um es neu zu erstellen."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Nimmt diese Kopie von der Seite und löscht sie aus deinen Makros, wodurch sie von deinen Aktionsleisten verschwindet."
L["MENU_DELETE_CONFIRM"] =
	"%s löschen? Es verschwindet von deinen Aktionsleisten, und seine Optionen werden zurückgesetzt."
-- The same ask for a macro on none of your bars.
L["MENU_DELETE_CONFIRM_UNUSED"] = "%s löschen? Seine Optionen werden zurückgesetzt."
L["MENU_GROUP_RANK"] = "Rang"
L["MENU_GROUP_WHEN"] = "Wann"
L["MENU_GROUP_FIRST"] = "Zuerst"
L["MENU_GROUP_THEN"] = "Danach"
L["MENU_GROUP_ERRORS"] = "Fehlermeldungen"
L["MENU_GROUP_GROUPED"] = "Gruppierte Zauber"
L["MENU_GROUP_TARGET"] = "Ziel"
L["MENU_PRIORITY_1"] = "Erste Priorität"
L["MENU_PRIORITY_2"] = "Zweite Priorität"
L["MENU_PRIORITY_3"] = "Dritte Priorität"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Wen das Makro der Reihe nach versucht. Wer den Zauber nicht erhalten kann, wird übersprungen, und kann es keiner, wirkt es wie der einfache Zauber."
L["MENU_UNIT_NONE"] = "Keine"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Beendet die Liste hier."
L["MENU_UNIT_TARGET"] = "Ziel"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Wirkt auf dein Ziel, wenn es den Zauber erhalten kann."
L["MENU_UNIT_SELF"] = "Selbst"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"Wirkt auf dich. Du kannst ihn immer erhalten, daher wird nach Selbst nichts mehr versucht."
L["MENU_UNIT_PET"] = "Begleiter"
L["MENU_UNIT_PET_DESCRIPTION"] = "Wirkt auf deinen Begleiter, wenn er draußen ist und den Zauber erhalten kann."
L["MENU_UNIT_FOCUS"] = "Fokus"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "Wirkt auf deinen Fokus, wenn du einen hast und er den Zauber erhalten kann."
L["MENU_UNIT_TARGETS_TARGET"] = "Ziel des Ziels"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Wirkt auf das Ziel deines Ziels, etwa den Tank, auf den der Feind in deinem Ziel einschlägt, wenn es den Zauber erhalten kann."
L["MENU_UNIT_MOUSEOVER"] = "Mauszeiger"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Wirkt auf den, der unter deinem Mauszeiger ist, in der Welt oder auf einem Einheitenfenster, wenn er den Zauber erhalten kann."
L["MENU_OPTIONS_COUNT"] = "%d Optionen"
L["MENU_HIGHEST"] = "Höchster Rang"
L["MENU_HIGHEST_DESCRIPTION"] = "Wirkt den höchsten Rang, den du kennst."
L["MENU_FIXED_RANK_DESCRIPTION"] = "Wirkt immer %s, auf jeder Stufe."
L["MENU_ANY_TIME"] = "Jederzeit"
L["MENU_ANY_TIME_DESCRIPTION"] = "Wirkt im Kampf und außerhalb des Kampfes."
L["MENU_IN_COMBAT"] = "Im Kampf"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Wirkt nur im Kampf. Außerhalb des Kampfes tut das Makro nichts, auch seine Gegenstände nicht."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Wirkt nur außerhalb des Kampfes. Im Kampf tut das Makro nichts, auch seine Gegenstände nicht."
L["MENU_EVERY_PRESS"] = "Bei jedem Drücken"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Wirkt jedes Mal, wenn du es drückst."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "Ein Rechtsklick wirkt %s. Ein Linksklick wirkt weiterhin %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Lässt das Makro %s wirken. Von den hier angehakten Zaubern wirkt es den, den du zuletzt erlernt hast, sodass es mit deinem Training aufsteigt."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] =
	"Noch nicht erlernt. Hake ihn jetzt an, und das Makro übernimmt ihn, sobald du ihn erlernst."
L["MENU_PET_DESCRIPTION"] = "Solange dein %s draußen ist, wirkt das Makro %s, statt ihn erneut zu beschwören."
L["MENU_STANCE_DESCRIPTION"] = "Wechselt zuerst zu %s, sofern du nicht schon darin bist."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Benutzt ihn vor dem Zauber. Gegenstände werden in der Reihenfolge benutzt, in der du sie anhakst, und die Zahl dahinter zeigt ihren Platz."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "%s benutzen"
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Fügt der Seite eine weitere Kopie dieses Makros mit diesen Optionen hinzu, damit du sie anders einrichten kannst."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Bedingungen"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Öffnet neben dem Fenster des Erweiterten Zauberbuchs den Bereich Bedingungen, in dem das Makro einen anderen Zauber wirken kann, wenn eine Bedingung zutrifft, etwa gehaltenes Shift oder Skillung 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "Eine Bedingung nutzt den Rechtsklick. Entferne sie, um dies einzuschalten."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Bedingungen"
L["CONDITIONALS_HINT"] = "Von oben nach unten geprüft; die erste, die zutrifft, wird gewirkt."
L["CONDITIONALS_OTHERWISE"] = "Sonst"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "und"
L["CONDITIONALS_AND_MENU"] = "Zweite Bedingung hinzufügen"
L["CONDITIONALS_AND_DESCRIPTION"] = "Fügt eine zweite Bedingung hinzu. Die Zeile wirkt nur, wenn beide zutreffen."
L["CONDITIONALS_DROP_SECOND"] = "Diese Bedingung entfernen"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "Die Zeile prüft wieder nur ihre erste Bedingung."
L["CONDITIONALS_ADD"] = "+ Bedingung hinzufügen"
L["CONDITIONALS_ADD_DESCRIPTION"] =
	"Fügt unten eine Zeile hinzu. Wähle ihre Bedingung und dann den Zauber, den sie wirkt."
L["CONDITIONALS_ADD_LIMIT"] = "Bis zu %d Zeilen. Jede verlängert den Makrotext, der 255 Bytes fasst."
L["CONDITIONALS_PICK_SPELL"] = "Zauber wählen"
L["CONDITIONALS_PICKING"] = "Zauber auf der Seite anklicken"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Klicke hier und dann auf einen Zauber auf der Seite, um ihn in dieser Zeile zu wirken. Oder ziehe einen Zauber von der Seite auf dieses Feld."
L["CONDITIONALS_PICK_BANNER"] = "Klicke auf einen Zauber, um ihn zu verwenden. Esc oder Rechtsklick bricht ab."
L["CONDITIONALS_CANNOT_PICK"] = "Nur ein erlernter Zauber kann von einer Bedingung gewirkt werden."
L["CONDITIONALS_EMPTY"] =
	"Noch keine Bedingungen. Füge eine hinzu, um bei gehaltenem Shift, im Kampf und mehr einen anderen Zauber zu wirken."
L["CONDITIONALS_SHADOWED"] =
	"Wird nie gewirkt: Zeile %d darüber trifft immer zu, wenn diese zutrifft, und wird zuerst gewirkt."
L["CONDITIONALS_KEY_DRAG"] = "Zauber hierher ziehen"
L["CONDITIONALS_ACTION_DROP"] = "In dieser Zeile wirken"
L["CONDITIONALS_ACTION_PICK"] = "Von der Seite wählen"
L["CONDITIONALS_ACTION_USE"] = "In Bedingung verwenden"
L["CONDITIONALS_ACTION_CANCEL"] = "Auswahl abbrechen"
L["CONDITIONALS_REMOVE"] = "Entfernen"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Entfernt diese Zeile."
L["CONDITIONALS_REORDER"] = "Umsortieren"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Ziehe sie auf eine andere Zeile, um sie dorthin zu verschieben. Die erste Zeile, die zutrifft, wird gewirkt."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Shift gehalten"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "Trifft zu, wenn du beim Drücken des Makros Shift hältst."
L["CONDITION_CTRL"] = "Strg gehalten"
L["CONDITION_CTRL_SHORT"] = "Strg"
L["CONDITION_CTRL_DESCRIPTION"] = "Trifft zu, wenn du beim Drücken des Makros Strg hältst."
L["CONDITION_ALT"] = "Alt gehalten"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Trifft zu, wenn du beim Drücken des Makros Alt hältst."
L["CONDITION_RIGHT_CLICK"] = "Rechtsklick"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "Trifft zu, wenn du das Makro auf deiner Aktionsleiste rechtsklickst."
L["CONDITION_IN_COMBAT"] = "Im Kampf"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Trifft zu, während du im Kampf bist."
L["CONDITION_OUT_OF_COMBAT"] = "Außerhalb des Kampfes"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Trifft zu, während du nicht im Kampf bist."
L["CONDITION_SPEC_1"] = "Skillung 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Trifft zu, während deine erste Skillung aktiv ist."
L["CONDITION_SPEC_2"] = "Skillung 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Trifft zu, während deine zweite Skillung aktiv ist."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (aktuell)"
L["CONDITION_COMBAT_BLOCKED"] =
	"Nicht verfügbar, solange Wann auf Im Kampf oder Außerhalb des Kampfes steht. Das Makro tut auf der anderen Seite ohnehin nichts, also würde dies immer oder nie zutreffen."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"Nicht verfügbar, solange unter Gruppierte Zauber Rechtsklick für %s aktiv ist, das den Rechtsklick bereits belegt. Schalte das ab, um hier den Rechtsklick zu nutzen."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 Bedingung"
L["SUBTEXT_CONDITIONALS"] = "%d Bedingungen"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Zauberfolge"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Öffnet neben dem Fenster des Erweiterten Zauberbuchs den Bereich Zauberfolge, in dem jedes Drücken des Makros den nächsten Zauber der Reihe nach wirkt, etwa Verderbnis, dann Fluch der Pein, dann Feuerbrand."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d Schritte"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Zauberfolge"
L["CAST_SEQUENCE_HINT"] =
	"Jedes Drücken wirkt den nächsten Schritt. Ein fehlgeschlagener Schritt wird beim nächsten Drücken erneut versucht."
L["CAST_SEQUENCE_FIRST"] = "Zuerst"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "Der eigene Zauber des Makros kommt immer zuerst."
L["CAST_SEQUENCE_ADD"] = "+ Schritt hinzufügen"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Fügt am Ende einen Schritt hinzu. Wähle dann den Zauber, den er wirkt."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Bis zu %d Schritte nach dem eigenen Zauber des Makros. Jeder verlängert den Makrotext, der 255 Bytes fasst."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"Nur ein erlernter Zauber, und nicht Schießen, kann ein Schritt einer Zauberfolge sein."
L["CAST_SEQUENCE_ACTION_DROP"] = "In diesem Schritt wirken"
L["CAST_SEQUENCE_ACTION_USE"] = "In Zauberfolge verwenden"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Entfernt diesen Schritt."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Ziehe ihn auf einen anderen Schritt, um ihn dorthin zu verschieben."
L["CAST_SEQUENCE_END"] = "Nach dem letzten Schritt"
L["CAST_SEQUENCE_END_LOOP"] = "Von vorn beginnen"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"Das nächste Drücken wirkt wieder den eigenen Zauber des Makros, und die Folge beginnt von vorn."
L["CAST_SEQUENCE_END_STOP"] = "Stopp (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Endet auf NULL, einem Zauber, den niemand kennt, sodass weiteres Drücken nichts wirkt, bis ein Zurücksetzen die Folge neu startet."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Stopp"
L["CAST_SEQUENCE_RESET"] = "Neu starten, wenn"
L["CAST_SEQUENCE_RESET_NEVER"] = "Nie"
L["CAST_SEQUENCE_RESET_TARGET"] = "Ziel wechselt"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "Startet die Folge beim ersten Schritt neu, wenn du das Ziel wechselst."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Kampf endet"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] = "Startet die Folge beim ersten Schritt neu, wenn du den Kampf verlässt."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Shift gehalten"
L["CAST_SEQUENCE_RESET_CTRL"] = "Strg gehalten"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt gehalten"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Drückst du das Makro mit dieser gehaltenen Taste, startet die Folge neu und wirkt ihren ersten Schritt."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Sekunden ohne Drücken"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Startet die Folge neu, wenn das Makro so lange nicht gedrückt wurde."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Aus"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d Sekunden ohne Drücken"
-- TRANSLATORS: the Seconds Idle row's value, the seconds it waits ("5 Seconds").
L["CAST_SEQUENCE_RESET_SECONDS_VALUE"] = "%d Sekunden"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	'Stoppt endgültig: Ohne etwas, das sie neu startet, bleibt die Folge auf NULL, bis sich das Makro ändert oder du dein Interface neu lädst. Wähle unter "Neu starten, wenn" einen Auslöser.'
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'Wartet, solange "Wirken, wenn beschworen" %s wirkt, das eine eigene Zauberzeile schreibt. Schalte das ab, um die Folge zu nutzen.'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Klicke hier und dann auf einen Zauber auf der Seite, um ihn in diesem Schritt zu wirken. Oder ziehe einen Zauber von der Seite auf dieses Feld."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d-Schritt-Folge"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Alle Zauberränge anzeigen"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Gruppierte Zauber anzeigen"
L["SETTINGS_SHOW_UNLEARNED"] = "Nicht erlernte Zauber anzeigen"
L["SETTINGS_MARK_ALL_PLACED"] = "Alle Zauber als platziert markieren"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	'Kein Makro auf dieser Seite leuchtet mehr, ob es auf deinen Leisten liegt oder nicht. Ein Zauber, den du später erlernst, leuchtet weiter, bis du ihn platzierst. "Nicht platzierte Zauber wieder hervorheben" im Zahnradmenü macht das rückgängig.'
L["SETTINGS_HIGHLIGHT_AGAIN"] = "Nicht platzierte Zauber wieder hervorheben"
L["SETTINGS_HIGHLIGHT_AGAIN_DESCRIPTION"] =
	'Macht "Alle Zauber als platziert markieren" rückgängig, sodass jeder Zauber, der nicht auf deinen Leisten liegt, wieder leuchtet.'
L["SORT_BY_CATEGORY"] = "Nach Kategorie sortieren"
L["SORT_BY_SCHOOL"] = "Nach Schule sortieren"
L["SORT_DESCRIPTION"] =
	"Gruppiert die Makros der Seite nach Kategorie, also wofür ein Zauber da ist, etwa Angriffe, Heilungen oder Defensive Abklingzeiten, oder nach Schule, also den Zauberbuch-Reitern, aus denen sie stammen."
L["CATEGORY_ATTACKS"] = "Angriffe"
L["CATEGORY_FINISHERS"] = "Finishing-Moves"
L["CATEGORY_CROWD_CONTROL"] = "Massenkontrolle"
L["CATEGORY_HYBRID"] = "Hybridzauber"
L["CATEGORY_HEALS"] = "Heilungen"
L["CATEGORY_BUFFS"] = "Stärkungszauber"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Offensive Abklingzeiten"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Defensive Abklingzeiten"
L["CATEGORY_SELF_BUFFS"] = "Selbstbuffs"
L["CATEGORY_SHOCKS"] = "Schocks"
L["CATEGORY_TRAPS"] = "Fallen"
L["CATEGORY_TOTEMS"] = "Totems"
L["CATEGORY_SEALS"] = "Siegel"
L["CATEGORY_BLESSINGS"] = "Segen"
L["CATEGORY_CURSES"] = "Flüche"
L["CATEGORY_PETS"] = "Begleiter"
L["KIND_RESURRECT"] = "Wiederbelebungen"
L["CATEGORY_TELEPORTS"] = "Teleporte und Portale"
L["CATEGORY_UTILITY"] = "Nützliches"
L["CATEGORY_THREAT"] = "Spott und Bedrohung"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Standardangriffe"
L["CATEGORY_STANCES"] = "Haltungen"
L["CATEGORY_FORMS"] = "Gestalten"
L["CATEGORY_AURAS"] = "Auren"
L["CATEGORY_ASPECTS"] = "Aspekte"
L["CATEGORY_RACIALS"] = "Volksfähigkeiten"
L["CATEGORY_TRACKING"] = "Aufspüren"
L["CATEGORY_PROFESSIONS"] = "Berufe"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_PET"] = "Begleiter"
L["SUBTEXT_CURSOR"] = "Am Cursor"
L["SUBTEXT_STANCE"] = "Haltung"
L["SUBTEXT_USE_ITEMS"] = "Gegenstände"
L["SUBTEXT_PET_ATTACK"] = "Begleiterangriff"
L["SUBTEXT_DYNAMIC_RANK"] = "Dyn. Rang"
L["SUBTEXT_DYNAMIC_ITEM"] = "Dyn. Gegenstand"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Dyn. Rang, Dyn. Gegenstand"
L["SUBTEXT_MAX_RANK"] = "Höchster Rang"
L["SUBTEXT_TARGET_ENEMY"] = "Nächster Feind"
L["SUBTEXT_TARGET_FRIEND"] = "Nächster Verbündeter"
L["SUBTEXT_TARGET_PRIORITY"] = "Ziel"
L["SUBTEXT_GROUPED_SPELLS"] = "Gruppiert"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1x pro Kampf"
L["SUBTEXT_ONCE_PER_TARGET"] = "1x pro Ziel"
L["SUBTEXT_COMBAT_ONLY"] = "Nur im Kampf"
L["SUBTEXT_NO_COMBAT"] = "Außer Kampf"
L["SUBTEXT_LEAVE_FORM"] = "Gestalt verlassen"
L["SUBTEXT_NO_TOGGLE"] = "Nie ausschalten"
L["SUBTEXT_WAND"] = "Zauberstab"
L["SUBTEXT_START_ATTACK"] = "Auto-Angriff"
L["SUBTEXT_STOP_ATTACK"] = "Angriff aus"
L["SUBTEXT_STOP_CASTING"] = "Zauber abbr."
L["SUBTEXT_STOP_IF_CHANNELING"] = "Nicht beim Kanalisieren"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Nicht in Verstohlenheit"
L["SUBTEXT_HIDE_ERRORS"] = "Fehler aus"
L["SUBTEXT_MUTE_ERRORS"] = "Fehler stumm"
L["SUBTEXT_OPTIONS_COUNT"] = "%d Optionen"
L["SUBTEXT_TOO_LONG"] = "Zu lang"
L["SUBTEXT_LEARN_LEVEL"] = "Stufe %d"
L["SUBTEXT_TALENT"] = "Talent"
L["SUBTEXT_LEARN_RANK"] = "%s erlernen"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Begleiter lehren"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Noch nicht erlernt"
L["TOOLTIP_LEARN_LEVEL"] = "Dein Klassenlehrer bringt ihn dir auf Stufe %d bei."
L["TOOLTIP_LEARN_TALENT"] = "Wird über deine Talente erlernt."
L["TOOLTIP_NOT_ON_BARS"] = "Nicht auf deinen Aktionsleisten"
L["TOOLTIP_TOO_LONG"] = "Zu lang: %d / %d Bytes. Schalte eine Option ab, um es zu kürzen."
L["TOOLTIP_OPTIONS_ON"] = "Aktive Optionen: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Klicken oder ziehen"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Auf deine Aktionsleisten legen"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Rechtsklick"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Makrooptionen"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Mittelklick"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Makrooptionen zurücksetzen"
-- TRANSLATORS: the category menu's last action; %d and %s as in MENU_CATEGORY_TITLE ("Reset All 6 Heals").
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Alle %d %s zurücksetzen"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s hat wieder seine Standardoptionen."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Jedes Makro in %s hat wieder seine Standardoptionen."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Verwirft die Optionen, die du bei jedem Zauber hier eingestellt hast, sodass alle wieder ihren Standards folgen. Fokus-Kopien und Duplikate bleiben erhalten."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Die Optionen zurücksetzen, die du bei jedem Zauber in %s eingestellt hast? Alle folgen dann wieder ihren Standards."
-- A middle-click on a macro, asked first. %s is the macro.
L["MENU_RESET_MACRO_CONFIRM"] = "Die Optionen von %s zurücksetzen? Es folgt dann wieder seinen Standards."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s-Makro"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Die Zauber deiner Klasse als Ein-Klick-Makros."
-- The click line beneath it reuses MENU_OPEN_SPELLBOOK.
L["TOOLTIP_KEY_CLICK"] = "Klicken"
-- What's Next rows' click lines: a spell row turns the Enhanced Spellbook to its tile, a pet ability row opens the Pet Spellbook tab.
L["WHATS_NEXT_CLICK_SPELL"] = "Im Erweiterten Zauberbuch zeigen"
L["WHATS_NEXT_CLICK_PET"] = "Im Begleiter-Zauberbuch zeigen"

-- Page: Layout
L["PAGE_EMPTY"] = "Noch keine Makros. Besuche deinen Klassenlehrer, um deine ersten Zauber zu erlernen."
L["PAGE_NO_MATCHES"] = "Keine Makros passen zum Filter. Leere das Filterfeld, um alle zu sehen."
L["PAGE_FILTER"] = "Zauber filtern"
L["FILTER_ALL_SCHOOLS"] = "Alle Schulen"
L["FILTER_ALL_CATEGORIES"] = "Alle Kategorien"
L["PAGE_MACRO_SLOTS"] = "Makroplätze"
L["TOOLTIP_MACRO_SLOTS"] =
	"Jedes Makro, das du platzierst, belegt einen Makroplatz. Charakterplätze gehören diesem Charakter und werden zuerst belegt. Allgemeine Plätze teilen sich alle Charaktere deines Accounts."
L["PAGE_MACRO_GENERAL"] = "Allgemein"
L["PAGE_MACRO_CHARACTER"] = "Charakter"
L["PAGE_NO_MATCHES_FOR"] = 'Keine Zauber passen zu "%s".'
-- A category gear's tooltip and menu title for a category of one spell; more take MENU_CATEGORY_TITLE.
L["PAGE_CATEGORY_SETTINGS_ONE"] = "Optionen für diesen Zauber"
-- The body of the page's Settings gear tooltip, under its title SETTINGS.
L["TOOLTIP_PAGE_SETTINGS_DESCRIPTION"] = "Wähle, welche Zauber die Seite zeigt."
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Schaltet eine Option für jeden Zauber dieser Kategorie auf einmal ein oder aus. Zauber, die noch nicht auf deinen Leisten liegen, behalten die Einstellung für den Moment, in dem du sie platzierst."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(Fortsetzung)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Was kommt als Nächstes?"
L["WHATS_NEXT_EMPTY"] = "Keine Zauber aufzulisten."
-- The same page while Show Known Spells is off: %s is that toggle's name (WHATS_NEXT_SHOW_KNOWN).
L["WHATS_NEXT_EMPTY_KNOWN_HIDDEN"] =
	"Gerade gibt es nichts Neues zu lernen. Hake %s im Zahnradmenü an, um zu sehen, was du schon gelernt hast."
L["WHATS_NEXT_ALL_SOURCES"] = "Alle Quellen"
L["WHATS_NEXT_ANY_LEVEL"] = "Jede Stufe"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LIST_PAIR_FORMAT or LIST_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), and [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "Du kannst jetzt %s erlernen."
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "Nicht vergessen: Du kannst auch %s erlernen."
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "Dein Begleiter kann jetzt %s erlernen."
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "Nicht vergessen: Dein Begleiter kann auch %s erlernen."
L["LEVEL_UP_DEMON_SPELLS"] = "Deine Dämonen können jetzt %s erlernen."

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Jetzt verfügbar"
L["WHATS_NEXT_STATUS_SOON"] = "Bald verfügbar"
L["WHATS_NEXT_STATUS_LATER"] = "Noch nicht verfügbar"
L["WHATS_NEXT_STATUS_MISSING"] = "Braucht anderen Zauber"
L["WHATS_NEXT_STATUS_TALENT"] = "Nicht gewählte Talente"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Nicht gewählte Talente und Runen"
L["WHATS_NEXT_STATUS_KNOWN"] = "Bekannt"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Jetzt verfügbar"
L["WHATS_NEXT_SHORT_SOON"] = "Bald verfügbar"
L["WHATS_NEXT_SHORT_LATER"] = "Noch nicht"
L["WHATS_NEXT_SHORT_MISSING"] = "Braucht anderen Zauber"
L["WHATS_NEXT_SHORT_TALENT"] = "Nicht gewählt"
L["WHATS_NEXT_SHORT_KNOWN"] = "Bekannt"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Startzauber"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Lehrer"
L["WHATS_NEXT_SOURCE_BOOK"] = "Buch"
L["WHATS_NEXT_SOURCE_QUEST"] = "Quest"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talent"
L["WHATS_NEXT_SOURCE_RUNE"] = "Rune"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Erlernt durch"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Benötigte Stufe"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Deine Klasse beginnt damit."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Dein Klassenlehrer bringt ihn dir bei."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "Ein Gegenstand lehrt ihn, etwa ein Buch aus einem Dungeon oder Schlachtzug."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "Eine Klassenquest lehrt ihn. Dein Klassenlehrer kann dir den Weg dorthin zeigen."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Gib einen Talentpunkt dafür aus, um ihn zu erlernen."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Graviere seine Rune ein, um ihn zu erlernen."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Erlerne zuerst %s."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "Ränge von %s"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + Klick"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Im Chat verlinken"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Nach Verfügbarkeit sortieren"
L["WHATS_NEXT_SORT_LEVEL"] = "Nach Stufe sortieren"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Nach Verfügbarkeit sortieren listet die Zauber, die du jetzt erlernen kannst, zuerst und die bekannten zuletzt. Nach Stufe sortieren listet jeden Zauber unter der Stufe, auf der er erlernt wird."
L["WHATS_NEXT_SHOW_KNOWN"] = "Bekannte Zauber anzeigen"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Listet auch die Zauber, die du bereits erlernt hast, nach den übrigen."
L["WHATS_NEXT_SHOW_TALENTS"] = "Nicht gewählte Talente anzeigen"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Nicht gewählte Talente und Runen anzeigen"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Listet auch die Talentzauber, die du nicht gewählt hast. Diese erlernst du, indem du Talentpunkte ausgibst, nicht bei einem Lehrer."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Begleiter-Zauberbuch"
L["PET_SPELLBOOK_EMPTY"] = "Dein Begleiter hat keine Zauber aufzulisten."
L["PET_SPELLBOOK_NO_PET"] = "Kein Begleiter draußen. Beschwöre deinen Begleiter, um seine Zauber zu sehen."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Fähigkeiten"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Passiv"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Autozauber an"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Autozauber aus"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Begleiter: Was kommt als Nächstes?"
L["WHATS_NEXT_PET_EMPTY"] = "Keine Begleiterfähigkeiten aufzulisten."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%1$s, %3$s der Stufe %2$d"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Trainingspunkte: %d von %d"
L["WHATS_NEXT_PET_NO_PET"] = "Kein Begleiter draußen: Angezeigt wird, was du mit Wildtierausbildung gelernt hast."
L["WHATS_NEXT_PET_NO_PET_SUMMON"] = "Kein Begleiter draußen: Rufe deinen Begleiter, um zu sehen, was er bereits kann."
L["WHATS_NEXT_PET_NO_DEMON"] = "Kein Dämon draußen: Beschwöre einen, um zu sehen, was er bereits kann."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Bereit zum Lehren"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Fähigkeiten anderer Familien"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Bereit zum Lehren"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Andere Familie"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Tierausbilder"
L["WHATS_NEXT_PET_SOURCE_HUNTER_TRAINER"] = "Jägerlehrer"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Zähmen"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Dämonenausbilder"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Benötigte Begleiterstufe"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Trainingspunkte"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Ein Tierausbilder bringt sie dir bei. Lehre sie dann deinem Begleiter mit Wildtierausbildung."
L["WHATS_NEXT_PET_TOOLTIP_HOW_HUNTER_TRAINER"] = "Dein Jägerlehrer bringt sie dem Begleiter bei, den du draußen hast."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Zähme ein Wildtier, das sie kennt, und kämpfe an seiner Seite, bis du sie erlernst. Lehre sie dann mit Wildtierausbildung jedem Begleiter, der sie lernen kann."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING_NEW_PET"] =
	"Zähme ein Wildtier, das sie kennt, dann bringt dein neuer Begleiter sie mit. Einem Begleiter, den du schon hast, bringt sie nichts mehr bei."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "Du kennst sie. Lehre sie deinem Begleiter mit Wildtierausbildung."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Kauf ihr Grimoire bei einem Dämonenausbilder und benutze es, während der Dämon beschworen ist, der sie lernt."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER_TEACHES"] = "Dein Dämonenausbilder bringt sie bei."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimoire"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Ihr Grimoire ist in deinen Taschen. Benutze es, während dieser Dämon beschworen ist."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Dein Begleiter kann sie nicht lernen."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Wildtiere, die sie kennen"

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Nach Verfügbarkeit sortieren listet die Fähigkeiten, die dein Begleiter jetzt lernen kann, zuerst und die bekannten zuletzt. Nach Stufe sortieren listet jede Fähigkeit unter der Begleiterstufe, die sie braucht."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Bekannte Fähigkeiten anzeigen"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Listet auch die Fähigkeiten, die dein Begleiter bereits kennt, nach den übrigen. Ein Jäger ohne Begleiter sieht die, die er selbst gelernt hat."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Fähigkeiten anderer Familien anzeigen"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Listet auch die Fähigkeiten, die dein Begleiter nicht lernen kann, etwa Schleichen einer Katze für einen Wolf oder die eines anderen Dämons."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Tastenbelegung"
L["OPTIONS_KEY_SET"] = "Taste festlegen"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Öffnet die Tastenbelegung des Spiels, in der Good to Go einen eigenen Abschnitt hat."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Öffnet und schließt das Erweiterte Zauberbuch. Es hat außerdem einen eigenen Reiter in deinem Zauberbuch."
-- The macro line, /click GtGBuffKey, sits in a box under this to copy (a translation may still place it with %s).
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Wirkt außerhalb des Kampfes den nächsten Buff, den dein Buff-Dienst-Fenster anbietet, einen pro Tastendruck. Um die Taste aus einem Makro zu drücken, kopiere die Zeile unten hinein: Klicke sie an und drücke dann Strg+A und Strg+C."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Zauberrang-Tooltips"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"Der Tooltip jeder Fähigkeit listet ihre Ränge und die Stufe, die jeder braucht: weiß für Ränge, die du kennst, grün für Ränge, die du jetzt trainieren könntest, und grau für Ränge, die noch kommen. So prüfst du schnell selbst, ob du deinen besten Rang nutzt, damit du immer dein Bestes geben kannst. Im Kampf werden die Ränge nicht angezeigt, damit deine Tooltips kurz bleiben, wenn es darauf ankommt."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Zauberrang-Tooltips aktivieren"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Fügt die Ränge jeder Fähigkeit ihrem Tooltip auf deinen Aktionsleisten, im Zauberbuch des Spiels und in anderen Add-ons hinzu. Ausgeschaltet bleiben diese Tooltips so, wie das Spiel sie zeigt. Das eigene Fenster des Erweiterten Zauberbuchs zeigt die Ränge in jedem Fall."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Makros löschen"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Löscht die Makros, die das Erweiterte Zauberbuch erstellt hat, und nimmt sie damit auch von deinen Aktionsleisten. Deine eigenen Makros bleiben unberührt, und die Seite erstellt jedes davon neu, wenn du es anklickst oder ziehst."
-- The two rows' captions, each beside a Delete button (OPTIONS_DELETE).
L["OPTIONS_DELETE_CHARACTER_MACROS_CAPTION"] = "Makros dieses Charakters"
L["OPTIONS_DELETE_GENERAL_MACROS_CAPTION"] = "Allgemeine Makros"
L["OPTIONS_DELETE"] = "Löschen"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Löscht die Makros des Erweiterten Zauberbuchs aus dem Makro-Reiter dieses Charakters. Deine anderen Charaktere behalten ihre, bis du dort dasselbe tust."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Alle Makros des Erweiterten Zauberbuchs auf diesem Charakter löschen? Sie verschwinden auch von deinen Aktionsleisten."
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Löscht die Makros des Erweiterten Zauberbuchs aus dem Reiter Allgemeine Makros, den alle Charaktere deines Accounts teilen, sodass auch deine anderen Charaktere ihre dort verlieren."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Alle allgemeinen Makros des Erweiterten Zauberbuchs löschen? Alle Charaktere deines Accounts verlieren sie, und sie verschwinden auch von deinen Aktionsleisten."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Listet nach dem Zauber selbst ein Makro für jeden niedrigeren Rang auf, den du von ihm kennst, und jedes wirkt immer seinen Rang."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Listet jeden Zauber auf, den du aus einer Zaubergruppe kennst, etwa Läutern und Reinigung des Glaubens. Ausgeschaltet wird nur der zuletzt erlernte aufgelistet, die Makros der anderen werden aber weiterhin aktualisiert."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Listet die Klassenzauber, die du noch nicht erlernt hast, im Abschnitt Nicht erlernt auf, damit du ihre Makros schon vorher platzieren kannst."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Setzt den Zauber dorthin, wo dein Cursor hinzeigt, ohne Zielkreis."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] =
	"Wirkt den höchsten Rang, den die Stufe des freundlichen Spielers zulässt."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Bricht zuerst ab, was du gerade wirkst, damit dieser Zauber sofort losgeht."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Beendet zuerst deinen automatischen Nahkampfangriff."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Tut nichts, während du einen Zauber kanalisierst, damit ein Tastendruck das Kanalisieren nie unterbricht."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Tut nichts, während du verstohlen bist, damit ein Tastendruck Verstohlenheit oder Schleichen nie beendet."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Verlässt zuerst deine aktuelle Gestalt, damit der Zauber gewirkt werden kann."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Visiert zuerst den nächsten Feind an, wenn du keinen lebenden Feind im Ziel hast."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Visiert zuerst den nächsten Verbündeten an, wenn du keinen lebenden Verbündeten im Ziel hast."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Schickt auch deinen Begleiter los, um dein Ziel anzugreifen."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Startet nach dem Wirken deinen automatischen Nahkampfangriff."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Startet nach dem Wirken den Automatischen Schuss oder deinen Zauberstab."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Wirkt einmal und dann erst wieder, wenn dein Ziel wechselt."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Wirkt einmal und dann erst wieder, wenn der Kampf endet oder dein Ziel wechselt."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Lässt Gestalt oder Aspekt an, wenn du das Makro erneut drückst, statt sie auszuschalten."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] =
	"Entfernt den roten Fehlertext, den das Makro auf dem Bildschirm hinterlässt."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Schaltet das Fehlergeräusch stumm, während das Makro läuft."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Erweitertes Zauberbuch ein-/ausblenden"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "Aus Sicherheitsgründen kann die Tastenbelegung im Kampf nicht geöffnet werden."
L["KEY_BINDINGS_LOCATION"] = "Öffne das Spielmenü, dann %s, dann %s, und suche den Abschnitt Good to Go."

-- Macro errors and prints: the Enhanced Spellbook's, then the Consumable Macros' too-long notice.
L["ERROR_MACRO_SLOTS_FULL"] = "Keine freien Makroplätze. Lösche ein paar deiner Makros in /m, um Platz zu schaffen."
L["ERROR_MACRO_WINDOW_OPEN"] = "Schließe zuerst das Makrofenster."
L["CHAT_MACROS_DELETED"] = "%d Makros gelöscht."
L["CHAT_MACROS_DELETED_ONE"] = "1 Makro gelöscht."
L["CHAT_MACRO_TOO_LONG"] =
	'Das Makro "%s" ist mit seinen Optionen %d Bytes lang, mehr als die %d, die ein Makro fasst. Schalte eine Option ab, um es zu kürzen.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'Das Makro "%s" ist %d Bytes lang, mehr als die %d, die ein Makro fasst, daher wird seine letzte Zeile abgeschnitten.'
