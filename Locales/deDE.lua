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
-- Consumable Macros & Restocker
--------------------------------------------------------------------------------

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
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s und %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s und %s"
-- A name with a detail after it: a Spellbook note and its settings ("Target (Mouseover, Self)"), or a pet and its owner.
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
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s steht jetzt auf der Ignorierliste dieses Charakters."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "1 Gegenstand von der Ignorierliste dieses Charakters entfernt."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "%d Gegenstände von der Ignorierliste dieses Charakters entfernt."

L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann das Optionsmenü im Kampf nicht geöffnet werden."

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    Printed when a ready check starts, as a header plus up to three lines. Each
    line is a set of "Label : a, b, c" clauses joined by ". ", and every part of
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
    Buff, PvP Flag On) keeps an OPTIONS_READINESS_* label of its own, and
    Scroll Buffs borrows FEATURE_SCROLL_BUFFS, the Macros feature it needs.
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
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
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
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Buff-Essen"
L["FEATURE_SCROLL_BUFFS"] = "Schriftrollen-Buffs"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Buff-Essen und Schriftrollen"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Verwendet Essen mit "%s" und wendet fehlende Schriftrollen-Buffs an, bevor du isst.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Aktuelles Essen"
L["MINIMAP_BEST_PET_FOOD"] = "Aktuelles Tierfutter"
L["MINIMAP_MAIN_HAND_POISON"] = "Waffenhand-Gift"
L["MINIMAP_OFF_HAND_POISON"] = "Schildhand-Gift"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Ignorierliste"
L["MINIMAP_IGNORE_COUNT"] = "%d Gegenstände"
L["MENU_IGNORE"] = "Ignorieren"
L["MENU_CLEAR_IGNORE"] = "Ignorierliste leeren"

--[[
    Restocker Report block in the mini-map tooltip. While the outstanding
    restocking orders are few enough to fit, it lists them under the header,
    one item per row; past that it shows only how many there are, beside the
    header. An order is one Restock List row with Buy switched on that is still
    short in your bags, so the count is of rows and not of missing units -- nine
    outstanding orders can be nine single juices or nine full stacks. The header
    beside it supplies the "restocking", so the count only needs the noun.

    The count only ever stands in for a list too long to show, so it is never
    one and needs no singular.

    The count sits in the tooltip's right column, beside the header, so it has
    to stay short enough to read as a value rather than a sentence. The
    all-stocked case has no header and no count: STOCKED replaces the whole
    row, on a wrapping line of its own, so it can be a full sentence. EMPTY is
    the line under the header when the list holds nothing at all, which is not
    the same as being stocked.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.
]]
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker-Bericht"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d offene Posten"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Glückwunsch, deine Vorräte sind vollständig aufgefüllt!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Deine Liste ist leer."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Nachschubliste"
L["MENU_RESTOCKER_DESCRIPTION"] = "Kauft die Gegenstände auf deiner Liste und lagert sie in der Bank."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + Rechtsklick"
L["MENU_OPTIONS"] = "GtG-Optionen"
L["MENU_OPTIONS_KEYBIND"] = "Shift + Mittelklick"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, which is
    the client's name for the player's class and has no key here, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
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
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Herbeizaubern"
L["NOTE_CREATE"] = "Herstellen"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Erneuter Rechtsklick"
L["NOTE_LOWER_RANK_BACKUP"] = "Ersatz niedrigeren Ranges"
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
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
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

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Aktiviert"
L["MINIMAP_DISABLED"] = "Deaktiviert"
L["MINIMAP_TOGGLE"] = "Umschalten"
L["MINIMAP_OPEN"] = "Öffnen"
L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_MIDDLE_CLICK"] = "Mittelklick"
L["MINIMAP_SHIFT_LEFT"] = "Shift + Linksklick"

--------------------------------------------------------------------------------
-- Mode Values
--------------------------------------------------------------------------------

--[[
    The one when-to-use list, offered by every mode dropdown: Prioritize Buff
    Food, Enable Scroll Buffs, Use Pet Food Buffs, and Use Conjured Food &
    Water First. %s in OPTIONS_MODE_DESCRIPTION is the feature's name,
    FEATURE_BUFF_FOOD, FEATURE_SCROLL_BUFFS or OPTIONS_PET_HEADER; the
    conjured dropdown has hover text of its own. Each value carries its own
    "when", since most dropdowns sit beside their toggle with no caption.
    Leveling means below the client's max level.

    In the mini-map tooltip, the Buff Food & Scrolls block, while a switch is
    on but no choice applies, shows that choice's label in place of
    MINIMAP_ENABLED, so every label has to read as a state too.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	'Legt fest, wann dein Essen-Makro "%s" anbietet: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe.'
L["OPTIONS_MODE_CAPTION"] = "Wann verwenden"
L["MODE_ALWAYS"] = "Immer"
L["MODE_SOLO"] = "Beim Solospiel"
L["MODE_PARTY"] = "In Gruppe oder Schlachtzug"
L["MODE_RAID"] = "Im Schlachtzug"
L["MODE_LEVELING"] = "Beim Leveln"
L["MODE_MAX_LEVEL"] = "Auf Höchststufe"

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
	"Sich selbst aktualisierende Makros für dein bestes Essen, Wasser, Tränke und Gesundheitssteine, eine Nachschubliste, die Reagenzien und Munition automatisch kauft und einlagert, fehlende Buffs per Klick, automatisches Dankesflüstern und Mouseover-Makros für jeden Zauber."

-- Options: tree labels
L["TAB_ENHANCED_SPELLBOOK"] = "Erweitertes Zauberbuch"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Mouseover-, Cursor- und Selbstzauber-Makros für jeden Klassenzauber, mit einem Klick in einem neuen Zauberbuch-Reiter erstellt, ganz ohne Makrosyntax. Sie bleiben aktuell, wenn du aufsteigst, trainierst oder die Skillung wechselst. Per Rechtsklick kommen Fokus, Zaubern abbrechen, automatischer Angriff, Begleiterangriff oder Schmuckstücke dazu."
L["SPELLBOOK_IS_OFF"] =
	"Das Erweiterte Zauberbuch ist aus. Schalte es unter Optionen > AddOns > Good to Go > Erweitertes Zauberbuch ein."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Gibt beim Anmelden eine Willkommensnachricht im Chat aus."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Minikarten-Button aktivieren"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Zeigt den Minikarten-Button an."

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    The root panel's Features section: every feature's on/off switch, two to a
    line, each the same toggle that heads its feature's own panel. Enable Buff
    Duty, Enable Restocker and Enable Thanks for Stranger Buffs keep their
    original keys (BUFF_DUTY_ENABLE, OPTIONS_RESTOCKER_ENABLE, STRANGERS_ENABLE),
    with the Buff Duty, Restocker and Stranger Buffs strings.

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
	"Fügt deinem Zauberbuch einen Reiter hinzu, der Mouseover-, Cursor- und Selbstzauber-Makros für deine Zauber erstellt und sie aktuell hält, während du aufsteigst und trainierst. Ausgeschaltet verschwindet der Reiter und die Aktualisierungen stoppen. Es löscht nie ein Makro; das erledigen die Schaltflächen unter Makros löschen im Bereich Erweitertes Zauberbuch."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Erweitertes Zauberbuch ausschalten? Sein Reiter verschwindet aus deinem Zauberbuch, und die erstellten Makros werden nicht mehr aktualisiert, wenn du aufsteigst und trainierst. Gelöscht werden sie dadurch nicht: Sie bleiben so auf deinen Aktionsleisten, wie sie jetzt sind."
L["SWITCH_MACROS"] = "Verbrauchsgüter-Makros aktivieren"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Richtet deine Makros für Essen, Wasser, Tränke und andere Verbrauchsgüter immer auf den besten Gegenstand in deinen Taschen aus, während sich deine Taschen ändern. Ausgeschaltet stoppen die Aktualisierungen, und jedes Makro bleibt, wie es zuletzt war. Es löscht nie ein Makro; das geschieht, wenn du eines unter Zu erstellende Makros im Bereich Verbrauchsgüter-Makros abwählst."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Verbrauchsgüter-Makros ausschalten? Deine Makros werden nicht mehr aktualisiert, wenn sich deine Taschen ändern, sodass ein Button womöglich weiter nach einem Gegenstand greift, den du aufgebraucht hast. Gelöscht werden sie dadurch nicht: Sie bleiben so auf deinen Aktionsleisten, wie sie jetzt sind."
L["SWITCH_INVENTORY_REPORT"] = "Inventarbericht aktivieren"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Ergänzt den Tooltip eines Gegenstands darum, wie viele du in deinen Taschen, in deiner Bank und auf deinen anderen Charakteren dieses Realms hast. Schalte ihn ab, wenn ein anderes Add-on diese Zahlen bereits anzeigt."
L["SWITCH_READINESS_REPORT"] = "Bereitschaftsbericht aktivieren"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Gibt beim Start eines Bereitschaftschecks eine private Liste mit allem aus, was du noch beheben musst, etwa ein fehlender Buff, ein fehlender Trank oder beschädigte Ausrüstung. Bleibt still, wenn du bereit bist."
L["SWITCH_STRANGER_BUFFS_DESCRIPTION"] =
	"Dankt Spielern außerhalb deiner Gruppe mit einem Flüstern, einem Emote oder beidem, wenn sie dich draußen in der Welt buffen."
L["SWITCH_GOOD_NEWS"] = "Gute Neuigkeiten teilen aktivieren"
L["SWITCH_GOOD_NEWS_DESCRIPTION"] =
	"Flüstert den Spielern, die du buffst, was du auf sie gewirkt hast, und bei kurzen Buffs auch, wie lange sie halten."
L["SWITCH_COMBAT_BUFFS"] = "Dank für Kampf-Buffs aktivieren"
L["SWITCH_COMBAT_BUFFS_DESCRIPTION"] =
	"Dankt deinen Gruppen- und Schlachtzugsmitgliedern mit einem Flüstern, einem Emote oder beidem, wenn sie einen Buff oder eine Abklingzeit auf dich wirken."
L["SWITCH_SERVICE_ALERTS"] = "Gruppendienst-Hinweise aktivieren"
L["SWITCH_SERVICE_ALERTS_DESCRIPTION"] =
	"Sagt dir Bescheid und dankt dem Spieler, wenn jemand ein Festmahl, einen Seelenbrunnen, ein Portal oder einen Reparaturbot für deine Gruppe aufstellt."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Restocker aktivieren"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Beispiel: %s"

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
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "Verbrauchsgüter-Makros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go erstellt ein Makro pro Verbrauchsgut und hält es aktuell, während sich deine Taschen ändern, damit der Button auf deiner Leiste immer zum besten Gegenstand greift, den du dabeihast. Wähle unten, welche Makros erstellt werden, und lege dann fest, wie jedes seinen Gegenstand auswählt."

-- Macro Names on Buttons
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
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Makrofenster öffnen"
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
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Essen und Wasser"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Deine Essen- und Wasser-Makros verwenden das beste Essen und die besten Getränke in deinen Taschen. Diese Optionen können Buff-Essen, Schriftrollen oder herbeigezaubertes Essen und Wasser an die erste Stelle und Essen und Wasser der Nachschubliste an die letzte Stelle setzen."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Buff-Essen bevorzugen"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Bevorzugt Essen, das den "%s"-Buff gewährt, wenn der Buff fehlt, außer in Arenen.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Schriftrollen-Buffs aktivieren"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Dein Essen-Makro wendet beim ersten Drücken fehlende Schriftrollen an und lässt dich beim nächsten essen, überspringt die Schriftrollen aber, wenn du einen befreundeten Spieler anvisierst oder in einer Arena bist."
L["OPTIONS_SCROLL_TYPES"] = "Schriftrollentypen in Prüfung einschließen"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Schutz"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Schließt "%s" in die Prüfung auf fehlende Buffs ein.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Herbeigezaubertes Essen und Wasser zuerst verwenden"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Deine Essen- und Wasser-Makros verwenden herbeigezaubertes Essen und Wasser vor allem anderen, auch wenn etwas in deinen Taschen mehr wiederherstellt, denn es kostet nichts und verschwindet kurz nach dem Ausloggen. Buff-Essen hat weiterhin Vorrang, solange "Buff-Essen bevorzugen" aktiviert ist.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Legt fest, wann herbeigezaubertes Essen und Wasser Vorrang haben: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Essen und Wasser der Nachschubliste zuletzt verwenden"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Von zwei Speisen oder Getränken, die gleich viel wiederherstellen, verwenden deine Essen- und Wasser-Makros das, was nicht auf deiner Nachschubliste steht. So bleibt, was der Restocker kauft, für später."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Tränke und Gesundheitssteine"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden (dies ist eine Blizzard-Einschränkung). Daher wird jedes Trank- und Gesundheitsstein-Makro im Voraus mit deinem besten Gegenstand und bis zu zwei Ersatzgegenständen erstellt. Bei längeren Kämpfen können das Symbol und der Tooltip veralten und den falschen Gegenstand anzeigen, aber ein Klick auf das Makro verwendet immer den besten Gegenstand, den du tatsächlich in deinen Taschen hast."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Essen und Wasser außerhalb des Kampfes in Trank-Makros verwenden"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Außerhalb des Kampfes isst du mit deinem Heiltrank-Makro dein bestes Essen und trinkst mit deinem Manatrank-Makro dein bestes Wasser. Im Kampf verwenden die Makros wie bisher deine Tränke. Schriftrollen, Tierfutter und das Herbeizaubern bleiben bei den Essen- und Wasser-Makros."
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

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Buff-Erneuerung"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden, daher bleibt ein Buff, der mitten im Kampf abläuft, bis zum Ende des Kampfes weg."
L["OPTIONS_REAPPLY"] = "Ablaufende Buffs erneuern"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Behandelt Buff-Essen, Schriftrollen-Buffs und Tierfutter-Buffs mit weniger Restzeit als deinem Schwellenwert als abgelaufen, sodass deine Makros vor dem Pull einen frischen anbieten."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen darf, bevor deine Makros einen frischen anbieten."
L["REAPPLY_THRESHOLD_ONE"] = "Wenn < 1 Minute übrig"
L["REAPPLY_THRESHOLD_MANY"] = "Wenn < %d Minuten übrig"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Tierfutter-Buffs"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'Ein paar Futtersorten verleihen deinem Tier einen eigenen "%s"-Buff.'
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
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Klasse und Volk"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Diese Optionen passen deine Makros für eine Klasse oder ein Volk an. Jeder Abschnitt wird bei jedem Charakter angezeigt."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Klassenoptionen: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Volksoptionen: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Benötigt das Add-on DruidMacroHelper. Eingeschaltet holen dich deine Heiltrank-, Manatrank- und Gesundheitsstein-Makros per Powershifting aus der Gestalt, verwenden den Gegenstand und versetzen dich zurück in Bärengestalt oder Katzengestalt, je nachdem, was du neben dem Kontrollkästchen wählst."
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper-Integration aktivieren"
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
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Verstohlenes Essen aktivieren"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Essen-Makro hinzu, damit du beim Essen verborgen bist."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Verstohlenes Trinken aktivieren"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Wasser-Makro hinzu, damit du beim Trinken verborgen bist."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Profi-Tipp: Wähle eines. Du kannst gleichzeitig essen und trinken, aber Essen oder Trinken nach dem Verstecken beendet deine Tarnung."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Nimm einen getöteten Humanoiden oder Untoten ins Ziel, und dein Makro wirkt %s, solange der Zauber bereit ist, und spart so dein Essen und Trinken. Geht das nicht (die Leiche ist außer Reichweite oder der Zauber hat Abklingzeit), isst oder trinkt es wie gewohnt."
L["OPTIONS_CANNIBALIZE_EATING"] = "%s statt Essen verwenden"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Essen-Makro ihn, statt zu essen. Sonst isst es wie gewohnt. Schriftrollen und Buff-Essen haben weiterhin Vorrang."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "%s statt Trinken verwenden"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Wasser-Makro ihn, statt zu trinken. Sonst trinkt es wie gewohnt. Buff-Getränke haben weiterhin Vorrang."

--[[
    Ignore List panel (Options-Ignore-List.lua). One tree scope per list: the
    Global list, then the character playing and every other character with
    something ignored, each under its profile's name, which is never
    translated and has no key here. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map tooltip, the Macros
    panel, and the staples pop-up use it too). The mini-map tooltip's section
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
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Erinnerungen"
L["OPTIONS_RESTOCKER_REMIND"] = "Nachschub-Erinnerungen in der Stadt aktivieren"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Gibt eine Chat-Erinnerung aus, wenn deiner Nachschubliste etwas fehlt und du ein Gasthaus oder eine Stadt erreichst oder dich beim Anmelden bereits dort befindest."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Nachschub-Erinnerungen beim Händler aktivieren"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Meldet alle offenen Nachschubposten, wenn du ein Händlerfenster schließt."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Nachschub-Erinnerungen bei der Bank aktivieren"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "Meldet alle offenen Nachschubposten, wenn du die Bank schließt."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Goldreserve aktivieren"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"Beim Auffüllen wird das Gold, das du hier zurücklegst, nie ausgegeben."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Legt fest, wie viel Gold dir beim Auffüllen immer bleibt."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Legt fest, ob die Erinnerung nur eine Zeile umfasst oder für jeden fehlenden Gegenstand eine Zeile hinzufügt."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Wie ausführlich"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Einfach"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Ausführlich"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Ton abspielen"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Spielt zusätzlich zur Erinnerung einen Hinweiston ab, falls im Chat gerade viel los ist."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Klicke, um den Hinweiston zu hören."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenster der Nachschubliste"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Wähle, wann sich deine Nachschubliste von selbst öffnet."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
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
	"Alle Einstellungen des Bereitschaftsberichts auf ihre Standardwerte zurücksetzen? Das schaltet auch den Bericht selbst wieder aus."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Fehlende Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Fehlende Gegenstände"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Charakter"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Meldet ein fehlendes Fläschchen. Ein Fläschchen oder je ein Kampf- und ein Wächterelixier gelten als abgedeckt."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Meldet einen fehlenden "%s"-Buff. Dazu muss Buff-Essen unter Verbrauchsgüter-Makros aktiviert sein.'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Meldet einen fehlenden "%s"-Buff deines Tiers. Dazu müssen Tierfutter-Buffs unter Verbrauchsgüter-Makros aktiviert sein, und dein Tier muss draußen sein.'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"Meldet fehlende Schriftrollen-Buffs. Dazu müssen Schriftrollen-Buffs unter Verbrauchsgüter-Makros aktiviert sein, und es werden nur die dort gewählten Schriftrollentypen geprüft."
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
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Ablaufende Buffs innerhalb von"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Nennt jeden Buff auf dir, der bald abläuft, nicht nur die, die Good to Go anwendet, und ist unabhängig von der Buff-Erneuerung unter Verbrauchsgüter-Makros."
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
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Inventory-Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Eine Liste namens "%s" existiert bereits.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Kein Gegenstand mit ID %d."
L["RESTOCKER_DISABLED"] = "Der Restocker ist aus. Schalte ihn unter Optionen > AddOns > Good to Go > Restocker ein."
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
    Features/Inventory-Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Dieser Händler führt nicht alle Zutaten, die deine Gifte benötigen. Es wird keine davon gekauft."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Vergiss nicht, deine Vorräte aufzufüllen, solange du in der Stadt bist!"

--[[
    Headline for the merchant and bank reminders, which report on the way out
    rather than nudging on arrival, so the count is the message. The in-town
    reminder keeps its own line above.

    The count is of restocking orders -- Restock List rows with Buy switched on
    that are still short in your bags -- so it never says "items", and never
    puts a bare count after "short": "short 9 apples" reads as nine apples
    missing, while the number here is nine ROWS, each short by anything from one
    juice to a full stack. "Order" can only mean a line on a list, and it is the
    word the code uses (BuildPurchaseOrder, purchaseOrders).

    "Outstanding" is load-bearing, not decoration. "Restocking order" alone can
    be read as the sequence restocking happens in, and the list UI is sortable,
    so the word forcing the purchase-order sense has to stay beside the noun.
    Same job as "filled" on RESTOCKER_RESTOCKED_ONE -- never print the bare
    noun without one of them.
]]
L["RESTOCKER_STILL_SHORT_ONE"] = "1 Nachschubposten offen."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d Nachschubposten offen."

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
    Verbose follow-up line, one per short item: { have, wanted, item link }.
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
    deliberately not mentioned here: the mini-map's Restocker Report owns the
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
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "Nicht genug Gold, um das Auffüllen abzuschließen."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Du hast weniger als %s. Das Auffüllen geht weiter, sobald du mehr hast."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[Name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Legt eine Liste mit diesem Namen an."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Löscht die Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Benennt die aktuelle Liste auf diesen Namen um."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Ersetzt die aktuelle Liste durch eine Kopie der Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_USE"] = "Weist diesem Charakter die Liste mit diesem Namen zu."

--[[
    Starter List pop-up, the staples window: offers staples at login when the
    Restock List is empty, and on demand from the Restock List window's Pick
    Staples button. The staples logic is in
    Features/Inventory-Restocker/Restocker-Starter-List.lua, the window in
    Features/Inventory-Restocker/Restocker-Starter-Window.lua. The six
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
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Wir haben schon ein paar Grundvorräte für deine Klasse angehakt, damit du loslegen kannst."
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
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Setze das fertige Gift auf deine Liste, und Good to Go kauft die Zutaten automatisch bei jedem Händler, der sie alle führt."
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
L["RESTOCKER_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Alle Gegenstände in deinen Taschen, die noch nicht auf dieser Liste stehen. Klicke auf einen, um ihn hinzuzufügen."
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
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Klicke, um diesem Charakter eine andere Nachschubliste zuzuweisen oder eine neue anzulegen."
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
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Bank"
L["RESTOCKER_ROW_MERCHANT"] = "Händler"
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
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Klicke auf die Überschrift, um dies für alle angezeigten Gegenstände festzulegen."
L["RESTOCKER_BULK_ON"] = "%d angezeigte aktivieren"
L["RESTOCKER_BULK_OFF"] = "%d angezeigte deaktivieren"

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
    The status line under the list. The orders count itself is
    RESTOCKER_STILL_SHORT_ONE / _MANY above, and the all-stocked line is
    MINIMAP_RESTOCKER_STOCKED, so the window, the reminders and the mini-map
    tooltip say the same thing in the same words.

    NO_ORDERS is the in-between: nothing for a merchant to fill, but a row with
    Buy off is still short in the bags (its Keep number is yellow), so the
    congratulation would be untrue. "Outstanding" stays beside the noun, as in
    the counts.

    REPORT_MORE closes the orders tooltip when the list is longer than it shows:
    %d is how many were left out. REMOVED_ITEM's %s is the item's icon and name,
    and UNDO is the button beside it that puts the item back; UNDO_TOOLTIP
    renders in the title slot.
]]
L["RESTOCKER_NO_ORDERS"] = "Keine Nachschubposten offen."
L["RESTOCKER_REPORT_MORE"] = "Und %d weitere."
L["RESTOCKER_REMOVED_ITEM"] = "%s entfernt."
L["RESTOCKER_UNDO"] = "Rückgängig"
L["RESTOCKER_UNDO_TOOLTIP"] = "Diesen Gegenstand wieder auf die Liste setzen"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Diesen Gegenstand von der Nachschubliste entfernen"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Du kannst das unten im Fenster rückgängig machen."
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
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Benötigter Ruf"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% Rabatt)"
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
	"Klicke, um festzulegen, welchen Ruf ein Händler voraussetzt, bevor Good to Go bei ihm kauft, was auch den Preis senkt: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Mit einem Strich wird bei jedem Händler gekauft."

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

-- MIGRATION (remove after 2026-11-25): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Deine Einstellungen aus %s wurden kopiert."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go hat deine Einstellungen aus %s kopiert und %s abgeschaltet, das es ersetzt. Jetzt neu laden, damit die alte Version nicht mehr läuft?"
L["POPUP_LEGACY_RELOAD_TURNED_OFF"] =
	"Good to Go hat %s abgeschaltet, das es ersetzt. Jetzt neu laden, damit die alte Version nicht mehr läuft?"
L["POPUP_LEGACY_RELOAD_ACCEPT"] = "Jetzt neu laden"
L["POPUP_LEGACY_LATER"] = "Später"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go hat %s gefunden, installiert, aber deaktiviert. Die Einstellungen übernehmen? Dabei werden die alten Add-ons wieder aktiviert und dein Interface neu geladen, danach wird ein weiteres Neuladen angeboten, um sie wieder abzuschalten."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go hat %s gefunden, installiert, aber deaktiviert. Die Einstellungen und Nachschublisten übernehmen? Dabei werden die alten Add-ons wieder aktiviert und dein Interface neu geladen, danach wird ein weiteres Neuladen angeboten, um sie wieder abzuschalten."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Übernehmen"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "Nein, danke"

--------------------------------------------------------------------------------
-- Automated Appreciation
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "%s hat dich mit %s gebufft!"
L["MESSAGE_GAVE_YOU"] = "%s hat dir %s gegeben!"
L["MESSAGE_GAVE_GROUP"] = "%s hat deiner Gruppe %s gegeben!"
L["MESSAGE_USED_ITEM"] = "%s hat %s bei dir benutzt!"
L["MESSAGE_USED_SPELL"] = "%s hat %s auf dich gewirkt!"
L["MESSAGE_SET_OUT"] = "%s hat %s aufgestellt!"
L["MESSAGE_OPENED"] = "%s hat %s geöffnet!"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "Danke für %s"
L["MESSAGE_SELECT_PLAYER"] = "Nimm zuerst einen Spieler ins Ziel."
L["MESSAGE_CANT_THANK_SELF"] = "Du kannst dir nicht selbst danken!"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "Unbekannter Zauber"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "Buffs von Fremden"
L["STRANGERS_ENABLE"] = "Dank für Buffs von Fremden aktivieren"
L["STRANGERS_DESCRIPTION"] = "Dankt Spielern außerhalb deiner Gruppe, wenn sie dich in der offenen Welt buffen."
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "Lob-Abklingzeit"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"Legt die Verzögerung zwischen einer Lobrunde und der nächsten fest, ganz gleich, wer dich gebufft hat. Bei null wird jeder Buff gelobt."
L["STRANGERS_SOURCE_COOLDOWN"] = "Lob-Abklingzeit für denselben Spieler"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"Legt die Verzögerung fest, bevor derselbe Spieler erneut gelobt wird. Bei null wird jeder Buff gelobt."
L["STRANGERS_MIN_DURATION"] = "Minimale Buff-Dauer"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"Ignoriert Buffs, die kürzer als dieser Wert sind. Bei null wird auf jeden Buff reagiert."

-- Combat Buffs
L["TAB_COMBAT_BUFFS"] = "Kampf-Buffs"
L["TEAMMATES_DESCRIPTION"] =
	"Dankt Gruppen- und Schlachtzugsmitgliedern für Buffs und Abklingzeiten, die sie auf dich wirken."
-- Shown on WoW Forever only.
L["TEAMMATES_FOREVER_WARNING"] =
	"Das funktioniert auf WoW Forever wahrscheinlich nicht richtig. Das Spiel verbirgt oft, wer einen Buff auf dich gewirkt hat, vor allem im Kampf, sodass viele Buffs ohne Dank bleiben."

-- Group Service Alerts
L["TAB_GROUP_SERVICE_ALERTS"] = "Gruppendienst-Hinweise"
L["SERVICES_DESCRIPTION"] =
	"Reagiert, wenn jemand Hilfe für deine Gruppe aufstellt: Festmähler, Seelenbrunnen, Portale und Reparaturbots."

-- Sharing Good News
L["TAB_SHARING_GOOD_NEWS"] = "Gute Neuigkeiten teilen"
L["GOOD_NEWS_DESCRIPTION"] =
	"Lass die Spieler, die du buffst, wissen, was du auf sie gewirkt hast und, bei kurzen Buffs, wie lange es anhält."
L["GOOD_NEWS_SCOPE"] = "Empfänger"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "Jeder, den du buffst"
L["GOOD_NEWS_SCOPE_GROUP"] = "Nur Gruppenmitglieder"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"Legt fest, wer die Guten Neuigkeiten zugeflüstert bekommt: jeder, den du buffst, oder nur deine Gruppenmitglieder."
L["GOOD_NEWS_MESSAGES_HEADER"] = "Nachricht für Gute Neuigkeiten"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "Das Flüstern, das die Spieler erhalten, die du buffst."
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] =
	"Legt fest, was das Flüstern sagt. Lass das Feld leer, um den Standardtext zu verwenden."
L["GOOD_NEWS_MESSAGE_LIMIT"] = "Maximale Länge: %d."
L["GOOD_NEWS_MESSAGE_TOKENS"] = "%a wird zum Fähigkeitslink, samt Dauer, wenn sie unter einer Minute liegt."
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "für %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "Verfolgte Fähigkeiten"
L["TRACKED_GROUP_ITEMS"] = "Gegenstände"
L["TRACKED_ITEM_PENDING"] = "Gegenstand #%d"
L["TRACKED_SPELL_PENDING"] = "Zauber #%d"

-- Shared by Sharing Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "Flüsternachricht"
L["WHISPER_MESSAGE_RESET"] = "Zurücksetzen"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "Setzt die Flüsternachricht auf den Standardtext zurück."

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "Dankesflüstern und Emotes"
L["NOTIFICATIONS_HEADER"] = "Benachrichtigungen"
L["PRAISE_DESCRIPTION"] = "Was der andere Spieler sieht: ein Dankesflüstern, ein Emote oder beides."
L["NOTIFICATIONS_DESCRIPTION"] = "Was nur du bekommst: eine Textmeldung, einen Ton oder beides."

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "Emotes auswählen"

L["PRAISE_WHISPER_ENABLE"] = "Dankesflüstern aktivieren"
L["PRAISE_WHISPER_DESCRIPTION"] = "Flüstert dem Spieler, der dich gebufft hat, ein Dankeschön zu."
L["PRAISE_EMOTES_ENABLE"] = "Emotes aktivieren"
L["PRAISE_EMOTES_DESCRIPTION"] =
	"Zeigt deine Wertschätzung mit einem Emote. Emotes werden zurückgehalten, solange du im Kampf bist."
L["PRAISE_DELAY_ENABLE"] = "Lob-Verzögerung aktivieren"
L["PRAISE_DELAY_DESCRIPTION"] =
	"Wartet einen Moment vor dem Flüstern und dem Emote, damit dein Dank nicht im selben Augenblick wie der Buff eintrifft. Benachrichtigungen bleiben unberührt."
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "Legt fest, wie lange gewartet wird, bevor Flüstern und Emote gesendet werden."

L["NOTIFICATIONS_PRINT_ENABLE"] = "Textmeldungen aktivieren"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "Gibt eine Nachricht aus, die nur du siehst, wenn du einen Buff erhältst."
L["NOTIFICATIONS_SOUND_ENABLE"] = "Soundeffekte aktivieren"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "Spielt einen Ton ab, wenn du einen Buff erhältst. Nur du hörst ihn."
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Spielt den Ton ab, damit du ihn hören kannst, bevor du ihn aktivierst."

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "Portale"
L["GROUP_RESISTANCE_CAULDRONS"] = "Widerstandskessel"
L["GROUP_REPAIR_BOTS"] = "Reparaturbots"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Buff-Dienst"
L["BUFF_DUTY_DESCRIPTION"] = "Zeigt, wem deine Buffs fehlen. Klicke auf ein Symbol, um zu wirken."
L["BUFF_DUTY_ENABLE"] = "Buff-Dienst aktivieren"
L["BUFF_DUTY_NO_BUFFS"] =
	"Deine Klasse hat keine Buffs auf dieser Liste, daher erscheint das Fenster bei diesem Charakter nie."
-- When to Show: Solo, In Party and In Raid, each with Always or In Instance, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Wann anzeigen"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Legt fest, wann das Fenster erscheinen kann."
L["BUFF_DUTY_WHEN_SOLO"] = "Solo"
L["BUFF_DUTY_WHEN_SOLO_DESCRIPTION"] =
	"Zeigt das Fenster, während du nicht in einer Gruppe oder einem Schlachtzug bist."
L["BUFF_DUTY_WHEN_PARTY"] = "In Gruppe"
L["BUFF_DUTY_WHEN_PARTY_DESCRIPTION"] = "Zeigt das Fenster, während du in einer Gruppe bist."
L["BUFF_DUTY_WHEN_RAID"] = "Im Schlachtzug"
L["BUFF_DUTY_WHEN_RAID_DESCRIPTION"] = "Zeigt das Fenster, während du in einem Schlachtzug bist."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Legt fest, wo das Fenster erscheint: überall oder nur in Dungeons, Schlachtzügen, Schlachtfeldern und Arenen."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Immer"
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
L["BUFF_DUTY_FAVOR_ENABLE"] = "Gefallen erwidern"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Listet die Fremden auf, die dich kürzlich gebufft haben, samt den Buffs, die du ihnen zurückgeben kannst. Rechtsklicke auf ein Symbol, um jemanden von der Liste zu nehmen."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Legt fest, wie lange ein Fremder nach seinem letzten Buff auf der Liste bleibt."
L["BUFF_DUTY_TARGET_ENABLE"] = "Dein Ziel"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Listet dein Ziel auf, wenn es ein Spieler außerhalb deiner Gruppe ist, dem ein Buff fehlt, den du geben kannst."
L["BUFF_DUTY_ASK_OTHERS"] = "Andere Klassen um Buffs bitten"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Zeigt unter „Fehlende Gruppenbuffs“ die Schlachtzugsbuffs, die deiner Gruppe fehlen, und wie viele jeweils einen brauchen. Linksklicke auf einen, um deine Gruppe darum zu bitten, oder rechtsklicke, um die Spieler anzuflüstern, die ihn wirken können."
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
L["BUFF_DUTY_TANKS_SOLO"] = "Wenn nicht in einer Gruppe"
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

L["BUFF_DUTY_SELF_DESCRIPTION"] = "Deine eigenen Buffs, oben im Fenster angeheftet."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "ein beliebiger Aspekt genügt"
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
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Waffenbuffs"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Hake an, was jede Waffe tragen soll. Das Fenster bietet es an, wenn es fehlt oder bald abläuft, sofern es in deinen Taschen ist und zur Waffe passt."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "Erneuern"
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
	"Zeigt oben im Fenster die Buffs, die nur du dir selbst geben kannst, etwa eine Rüstung oder Inneres Feuer, wenn sie fehlen oder bald ablaufen. Welche, legst du unter Selbstbuffs fest."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Deine Waffenbuffs"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Zeigt die Gifte, Waffenverzauberungen, Öle, Steine und Köder, die deinen Waffen fehlen oder bald ablaufen, zusammen mit deinen Selbstbuffs oben im Fenster. Klicke auf einen Eintrag, um ihn aufzutragen. Welche, legst du unter Waffenbuffs fest."

-- The window itself
L["BUFF_DUTY_SELF_HEADER"] = "Selbstbuffs"
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "Fehlende Selbstbuffs"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "Fehlende Gruppenbuffs"
L["BUFF_DUTY_FAVOR_HEADER"] = "Gefallen erwidern"
L["BUFF_DUTY_TARGET_HEADER"] = "Ziel"
L["BUFF_DUTY_TOOLTIP_CAST"] = "Klicken, um auf %s zu wirken."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Klicken, um es auf die Waffe in deiner %s aufzutragen."
L["BUFF_DUTY_TOOLTIP_USE"] = "Niemand in deiner Gruppe hat einen Seelenstein. Klicken, um einen auf %s anzuwenden."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Niemand in deiner Gruppe hat einen Seelenstein. Klicken, um einen herzustellen."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Klicken, um auf %s samt Gruppe zu wirken."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Klicken, um %s ins Ziel zu nehmen und zu wirken."
L["BUFF_DUTY_TOOLTIP_DISMISS"] = "Rechtsklick, um %s von der Liste zu nehmen."
-- A Party-Buffs icon's tooltip: a raid buff your group is missing, and its count.
L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"] = "Fehlt oder läuft bald ab: %d"
-- A Party-Buffs icon's clicks, beside Left-Click and Right-Click: one asks the party or raid, the other whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_GROUP"] = "Buff in der Gruppe anfordern"
L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_WHISPER"] = "Buff direkt anfordern"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s fehlt %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s fehlt %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d Spielern fehlt der Buff %s."
-- Your own chat, after a Right-Click: who was whispered, then the buff's link.
L["BUFF_DUTY_OTHERS_SENT"] = "%s wegen %s angeflüstert."
-- The window's close button: the class name in its color, then the options command.
L["BUFF_DUTY_CLOSED"] =
	"Buff-Dienst ist für die Klasse %s aus. Um ihn wieder einzuschalten, mache Shift + Linksklick auf den Minikarten-Button oder gib %s ein."

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEY"] = "Buff-Knopf"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Warte darauf, dass %s in Reichweite kommt."
L["BUFF_KEY_DONE"] = "Nichts mehr zu buffen."
L["BUFF_KEY_OFF"] = "Buff-Dienst ist aus."

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "Dankeschön-Knopf"
L["BUTTON_DESCRIPTION"] =
	"Flüstere deinem Ziel zu und bedenke es mit einem Emote, alles mit einem einzigen Tastendruck. Höflichkeit, automatisiert."
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "Dankeschön-Knopf %d"
L["BUTTON_EMOTE"] = "Emote"
L["BUTTON_EMOTE_DESCRIPTION"] =
	"Legt das Emote fest, das dieser Knopf bei deinem Ziel ausführt, oder Keine für kein Emote."
L["BUTTON_EMOTE_NONE"] = "Keine"
L["BUTTON_ICON"] = "Symbol"
L["BUTTON_ICON_DESCRIPTION"] =
	"Legt das Symbol fest, das das Makro dieses Knopfes in deiner Makroliste und auf deinen Aktionsleisten zeigt."
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "Standard"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = 'Makro "%s" aktivieren'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] =
	"Erstellt ein Makro namens %s und löscht es wieder, sobald du dies ausschaltest."
L["BUTTON_WHISPER_DESCRIPTION"] =
	"Legt fest, was dieser Knopf deinem Ziel zuflüstert. Bleibt das Feld leer, wird nichts geflüstert."

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "Danke, du bist spitze! (="
--[[
    The star marker (left off on WoW Forever) and " // GtG" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "Du hast %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "Ihr jubelt <Target> zu."
L["EMOTE_DRINK_DESCRIPTION"] = "Ihr erhebt Euer Glas auf <Target>."
L["EMOTE_FLEX_DESCRIPTION"] = "Ihr lasst vor <Target> Eure Muskeln spielen."
L["EMOTE_GRIN_DESCRIPTION"] = "Ihr grinst <Target> schelmisch an."
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "Ihr gebt <Target> ein High-Five."
L["EMOTE_PRAISE_DESCRIPTION"] = "Ihr lobt <Target>."
L["EMOTE_SALUTE_DESCRIPTION"] = "Ihr grüßt <Target> voller Respekt."
L["EMOTE_SMILE_DESCRIPTION"] = "Ihr lächelt <Target> an."
L["EMOTE_THANK_DESCRIPTION"] = "Ihr dankt <Target>."
L["EMOTE_WHOA_DESCRIPTION"] = "Ihr ruft <Target> 'Boah!' zu."
L["EMOTE_WINK_DESCRIPTION"] = "Ihr zwinkert <Target> zu."
L["EMOTE_YES_DESCRIPTION"] = "Ihr nickt <Target> zu."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- the window's first tab and its title before "// Good to Go"

-- Page: Sections
L["SECTION_UNLEARNED"] = "Nicht erlernt"
L["SECTION_CONSUMABLES"] = "GtG-Verbrauchsgüter"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Makrotext"
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
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "Auf alle %s anwenden"
L["MENU_ONCE_PER_COMBAT"] = "Einmal pro Kampf wirken"
L["MENU_ONCE_PER_TARGET"] = "Einmal pro Ziel wirken"
L["MENU_HIDE_ERRORS"] = "Fehlermeldungen ausblenden"
L["MENU_MUTE_ERRORS"] = "Fehlergeräusche stummschalten"
L["MENU_SWITCH_TO"] = "Zu %s wechseln"
L["MENU_START_AUTO_ATTACK"] = "Automatischen Angriff starten"
L["MENU_STOP_ATTACK"] = "Angriff beenden"
L["MENU_START_AUTO_SHOT"] = "Automatischen Schuss starten"
L["MENU_START_PET_ATTACK"] = "Begleiterangriff starten"
L["MENU_START_WAND"] = "Zauberstab starten"
L["MENU_STOP_CASTING"] = "Zaubern abbrechen"
L["MENU_STOP_CASTING_NOTE"] =
	"Nutze Zaubern abbrechen für Zauber, die nicht warten können, etwa Unterbrechungen und Bannzauber."
L["MENU_STOP_IF_CHANNELING"] = "Makro beim Kanalisieren stoppen"
L["MENU_STOP_IF_STEALTHED"] = "Makro in Verstohlenheit stoppen"
L["MENU_DUPLICATE"] = "Duplizieren"
L["MENU_DELETE"] = "Löschen"
L["MENU_DELETE_USED_ONE"] = "Löschen (auf 1 Leiste)"
L["MENU_DELETE_USED"] = "Löschen (auf %d Leisten)"
L["MENU_DELETE_DESCRIPTION"] =
	"Löscht dieses Makro aus deinen Makros, wodurch es von deinen Aktionsleisten verschwindet, und setzt alle seine Optionen zurück. Klicke oder ziehe es auf der Seite, um es neu zu erstellen."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Nimmt diese Kopie von der Seite und löscht sie aus deinen Makros, wodurch sie von deinen Aktionsleisten verschwindet."
L["MENU_DELETE_CONFIRM"] =
	"%s löschen? Es verschwindet von deinen Aktionsleisten, und seine Optionen werden zurückgesetzt."
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
L["MENU_ENABLED"] = "Aktiviert"
L["MENU_HIGHEST"] = "Höchster"
L["MENU_HIGHEST_DESCRIPTION"] = "Wirkt den höchsten Rang, den du kennst."
L["MENU_RANK_DYNAMIC"] = "Dynamisch"
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
L["MENU_ADD_FOCUS"] = "Fokus-Kopie hinzufügen"
L["MENU_REMOVE_FOCUS"] = "Fokus-Kopie entfernen"
L["MENU_FOCUS_DESCRIPTION"] =
	"Fügt der Seite ein zweites Makro hinzu, das auf deinen Fokus wirkt und danach auf dein Ziel."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Fügt der Seite eine weitere Kopie dieses Makros mit diesen Optionen hinzu, damit du sie anders einrichten kannst."
L["MENU_MAKE_DEFAULT"] = "Als Standard für %s festlegen"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"Jedes Makro unter %s, das du nicht selbst eingestellt hast, startet mit den Optionen dieses Makros."
L["MENU_DEFAULT_SET"] = "%s starten jetzt mit diesen Optionen."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Bedingungen"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Öffnet neben dem Zauberbuch den Bereich Bedingungen, in dem das Makro einen anderen Zauber wirken kann, wenn eine Bedingung zutrifft, etwa gehaltenes Shift oder Skillung 2."
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
	"Öffnet neben dem Zauberbuch den Bereich Zauberfolge, in dem jedes Drücken des Makros den nächsten Zauber der Reihe nach wirkt, etwa Verderbnis, dann Fluch der Pein, dann Feuerbrand."
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
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	'Stoppt endgültig: Ohne etwas, das sie neu startet, bleibt die Folge auf NULL, bis sich das Makro ändert oder du dein Interface neu lädst. Wähle unter "Neu starten, wenn" einen Auslöser.'
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'Wartet, solange "Wirken, wenn beschworen" %s wirkt, das eine eigene Zauberzeile schreibt. Schalte das ab, um die Folge zu nutzen.'
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d-Schritt-Folge"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Alle Zauberränge anzeigen"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Gruppierte Zauber anzeigen"
L["SETTINGS_SHOW_UNLEARNED"] = "Nicht erlernte Zauber anzeigen"
L["SETTINGS_MARK_ALL_PLACED"] = "Alle Zauber als platziert markieren"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Kein Makro auf dieser Seite leuchtet mehr, ob es auf deinen Leisten liegt oder nicht. Ein Zauber, den du später erlernst, leuchtet weiter, bis du ihn platzierst."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "Nicht platzierte Zauber hervorheben"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	"Lässt jedes Makro leuchten, das nicht auf deinen Leisten liegt. Schalte es ab, um alle als platziert zu markieren, wie mit der Schaltfläche Alle Zauber als platziert markieren."
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
L["SUBTEXT_FOCUS"] = "Fokus"
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
L["SUBTEXT_NO_TOGGLE"] = "Bleibt an"
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
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Alle Makros in %s zurücksetzen"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s hat wieder seine Standardoptionen."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Jedes Makro in %s hat wieder seine Standardoptionen."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Verwirft die Optionen, die du bei jedem Zauber hier eingestellt hast, sodass alle wieder ihren Standards folgen. Fokus-Kopien und Duplikate bleiben erhalten."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Die Optionen zurücksetzen, die du bei jedem Zauber in %s eingestellt hast? Alle folgen dann wieder ihren Standards."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s-Makro"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Die Zauber deiner Klasse als Ein-Klick-Makros."
L["TOOLTIP_KEY_CLICK"] = "Klicken"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Erweitertes Zauberbuch öffnen"

-- Page: Layout
L["PAGE_EMPTY"] = "Noch keine Makros. Besuche deinen Klassenlehrer, um deine ersten Zauber zu erlernen."
L["PAGE_NO_MATCHES"] = "Keine Makros passen zum Filter."
L["PAGE_FILTER"] = "Zauber filtern"
L["FILTER_ALL_SCHOOLS"] = "Alle Schulen"
L["FILTER_ALL_CATEGORIES"] = "Alle Kategorien"
L["PAGE_MACRO_SLOTS"] = "Makroplätze"
L["TOOLTIP_MACRO_SLOTS"] =
	"Jedes Makro, das du platzierst, belegt einen Makroplatz. Charakterplätze gehören diesem Charakter und werden zuerst belegt. Allgemeine Plätze teilen sich alle Charaktere deines Accounts."
L["PAGE_MACRO_GENERAL"] = "Allgemein"
L["PAGE_MACRO_CHARACTER"] = "Charakter"
L["PAGE_NO_MATCHES_FOR"] = 'Keine Zauber passen zu "%s".'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Settings for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "Einstellungen für alle %d %s"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Schaltet eine Option für jeden Zauber dieser Kategorie auf einmal ein oder aus. Zauber, die noch nicht auf deinen Leisten liegen, behalten die Einstellung für den Moment, in dem du sie platzierst."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(Fortsetzung)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Was kommt als Nächstes?"
L["WHATS_NEXT_EMPTY"] = "Keine Zauber aufzulisten."
L["WHATS_NEXT_ALL_SOURCES"] = "Alle Quellen"
L["WHATS_NEXT_ANY_LEVEL"] = "Jede Stufe"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Jetzt verfügbar"
L["WHATS_NEXT_STATUS_SOON"] = "Bald verfügbar"
L["WHATS_NEXT_STATUS_LATER"] = "Noch nicht verfügbar"
L["WHATS_NEXT_STATUS_MISSING"] = "Fehlende Voraussetzungen"
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
-- TRANSLATORS: %1$s is the pet's name, %2$d its level, %3$s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%1$s, Stufe-%2$d-%3$s"
-- TRANSLATORS: %1$d is the training points the pet has left, %2$d its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Trainingspunkte: %1$d von %2$d"
L["WHATS_NEXT_PET_NO_PET"] = "Kein Begleiter draußen: Angezeigt wird, was du mit Wildtierausbildung gelernt hast."
L["WHATS_NEXT_PET_NO_DEMON"] = "Kein Dämon draußen: Beschwöre einen, um zu sehen, was er bereits kann."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Bereit zum Lehren"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Fähigkeiten anderer Familien"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Bereit zum Lehren"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Andere Familie"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Tierausbilder"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Zähmen"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Dämonenausbilder"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Benötigte Begleiterstufe"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Trainingspunkte"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Ein Tierausbilder bringt sie dir bei. Lehre sie dann deinem Begleiter mit Wildtierausbildung."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Zähme ein Wildtier, das sie kennt, und kämpfe an seiner Seite, bis du sie erlernst. Lehre sie dann mit Wildtierausbildung jedem Begleiter, der sie lernen kann."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "Du kennst sie. Lehre sie deinem Begleiter mit Wildtierausbildung."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Kauf ihr Grimoire bei einem Dämonenausbilder und benutze es, während der Dämon beschworen ist, der sie lernt."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimoire"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Ihr Grimoire ist in deinen Taschen. Benutze es, während dieser Dämon beschworen ist."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Dein Begleiter kann sie nicht lernen."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Wildtiere, die sie kennen"
-- TRANSLATORS: %1$s is a beast's name, %2$s its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%1$s (%2$s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "Und %d weitere."

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
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Wirkt außerhalb des Kampfes den nächsten Buff, den dein Buff-Dienst-Fenster anbietet, einen pro Tastendruck. Waffenbuffs bleiben ein Klick im Fenster. Um die Taste aus einem Makro zu drücken, verwende %s."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Fähigkeiten-Tooltips von Was kommt als Nächstes?"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"Der Tooltip jeder Fähigkeit listet ihre Ränge und die Stufe, die jeder braucht: grün für Ränge, die du kennst, rot für Ränge, die du jetzt trainieren könntest, es aber noch nicht getan hast, und gelb für Ränge, die noch kommen. So prüfst du schnell selbst, ob du immer deinen besten Rang nutzt, damit du immer dein Bestes geben kannst. Im Kampf werden die Ränge nicht angezeigt, damit deine Tooltips kurz bleiben, wenn es darauf ankommt."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Fähigkeiten-Tooltips von Was kommt als Nächstes? aktivieren"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Fügt die Ränge jeder Fähigkeit ihrem Tooltip auf deinen Aktionsleisten, im Zauberbuch des Spiels und in anderen Add-ons hinzu. Ausgeschaltet bleiben diese Tooltips so, wie das Spiel sie zeigt. Das eigene Fenster des Erweiterten Zauberbuchs zeigt die Ränge in jedem Fall."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Makros löschen"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Löscht die Makros, die das Erweiterte Zauberbuch erstellt hat, und nimmt sie damit auch von deinen Aktionsleisten. Deine eigenen Makros bleiben unberührt, und die Seite erstellt jedes davon neu, wenn du es anklickst oder ziehst."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Charaktermakros löschen"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Löscht die Makros des Erweiterten Zauberbuchs aus dem Makro-Reiter dieses Charakters. Deine anderen Charaktere behalten ihre, bis du dort dasselbe tust."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Alle Makros des Erweiterten Zauberbuchs auf diesem Charakter löschen? Sie verschwinden auch von deinen Aktionsleisten."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Allgemeine Makros löschen"
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
L["KIND_ENEMY"] = "Zauber gegen Feinde"
L["KIND_ENEMY_DESCRIPTION"] = "Zauber, die du auf einen Feind wirkst, etwa Angriffe und Schwächungen."
L["KIND_FRIENDLY"] = "Freundliche Zauber"
L["KIND_FRIENDLY_DESCRIPTION"] = "Zauber, die du auf einen Verbündeten wirkst, etwa Heilungen."
L["KIND_BUFF"] = "Stärkungszauber"
L["KIND_BUFF_DESCRIPTION"] = "Zauber, die einem Verbündeten eine anhaltende Stärkung geben."
L["KIND_RESURRECT"] = "Wiederbelebungen"
L["KIND_RESURRECT_DESCRIPTION"] = "Zauber, die du auf einen toten Verbündeten wirkst, um ihn zurückzuholen."
L["KIND_ANYONE"] = "Zauber für Freund oder Feind"
L["KIND_ANYONE_DESCRIPTION"] = "Zauber, die du auf einen Verbündeten oder einen Feind wirken kannst."
L["KIND_GROUND"] = "Bodenzauber"
L["KIND_GROUND_DESCRIPTION"] = "Zauber, die du auf dem Boden platzierst."
L["KIND_FORM"] = "Gestalten, Haltungen und Aspekte"
L["KIND_FORM_DESCRIPTION"] = "Zauber, die aktiv bleiben, bis du sie ausschaltest oder wechselst."
L["KIND_SELF"] = "Selbst- und Flächenzauber"
L["KIND_SELF_DESCRIPTION"] = "Zauber ohne Ziel, die auf dich oder um dich herum wirken."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Erweitertes Zauberbuch ein-/ausblenden"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "Aus Sicherheitsgründen kann die Tastenbelegung im Kampf nicht geöffnet werden."
L["KEY_BINDINGS_LOCATION"] = "Öffne das Spielmenü, dann %s, dann %s, und suche den Abschnitt Good to Go."
L["ERROR_MACRO_SLOTS_FULL"] = "Keine freien Makroplätze. Lösche ein Makro in /macro, um Platz zu schaffen."
L["CHAT_MACROS_DELETED"] = "Gelöschte Makros: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'Das Makro "%s" ist mit seinen Optionen %d Bytes lang, mehr als die %d, die ein Makro fasst. Schalte eine Option ab, um es zu kürzen.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'Das Makro "%s" ist %d Bytes lang, mehr als die %d, die ein Makro fasst, daher wird seine letzte Zeile abgeschnitten.'
