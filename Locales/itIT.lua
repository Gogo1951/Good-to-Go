local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "itIT")
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
	"Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > AddOn > Good to Go. Ti piace questo add-on? Parlane a un amico, aggiungilo ai preferiti su CurseForge o dagli una stella su GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Aiuta Good to Go a salire di livello"
L["OPTIONS_LEVEL_UP_THANKS"] = "Grazie per aver scelto Good to Go!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Benda"
L["MACRO_EXPLOSIVES"] = "- Esplosivi"
L["MACRO_FEED_PET"] = "- Nutri Famiglio"
L["MACRO_FOOD"] = "- Cibo"
L["MACRO_HEALTH_POTION"] = "- Poz. Salute"
L["MACRO_HEALTHSTONE"] = "- Pietra Salute"
L["MACRO_MANA_GEM"] = "- Gemma di Mana"
L["MACRO_MANA_POTION"] = "- Poz. Mana"
L["MACRO_POISONS"] = "- Veleni"
L["MACRO_SOULSTONE"] = "- Pietra Anima"
L["MACRO_WATER"] = "- Acqua"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names or spells in a sentence, such as a buff ask or a level-up line ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s e %s"
-- Joins the last one to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s e %s"
-- Joins two choices in a sentence, such as the buffs an ask to your target names ("[Fortitude] or [Shadow Protection]").
L["LIST_OR_PAIR_FORMAT"] = "%s o %s"
-- Joins the last choice to the ones before it, already joined with LIST_SEPARATOR ("[Fortitude], [Shadow Protection], or [Divine Spirit]").
L["LIST_OR_LAST_FORMAT"] = "%s o %s"
-- Closes a hover list cut short: %d is how many more it holds, such as the Restock List's Short Items or the beasts that know a pet ability.
L["LIST_MORE_SENTENCE"] = "E altri %d."
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

L["DIET_BREAD"] = "Pane"
L["DIET_CHEESE"] = "Formaggio"
L["DIET_FISH"] = "Pesce"
L["DIET_FRUIT"] = "Frutta"
L["DIET_FUNGUS"] = "Funghi"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sembra che tu abbia trovato un bug! Non è possibile usare %s (%s) in %s > %s (%s). Segnalacelo, così potremo risolverlo. Grazie! %s"
L["MESSAGE_NO_ITEM"] = "%s: nessun oggetto adatto trovato nelle tue borse."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Alcune macro di Good to Go non sono state create perché i tuoi spazi macro sono pieni. Libera uno spazio eliminando le macro che non usi più, oppure disattiva le macro di Good to Go che non ti servono in Opzioni > AddOn > Good to Go > Macro dei consumabili."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Le tue macro sono pronte. Digita %s, apri la scheda %s e trascina - Cibo, - Acqua e le altre sulle tue barre delle azioni."
-- The mini-map button's Right-Click, or the menu's Ignore row. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s ora è nella lista ignorati di questo personaggio."
-- A click on an item in the mini-map menu's Ignore List. %s is the item's link.
L["MESSAGE_IGNORE_REMOVED"] = "%s non è più nella lista ignorati di questo personaggio."
-- The mini-map button's Middle-Click: %d is how many items it took off the list, exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "Rimosso 1 oggetto dalla lista ignorati di questo personaggio."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "Rimossi %d oggetti dalla lista ignorati di questo personaggio."

L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per sicurezza, l'interfaccia delle opzioni non può essere aperta durante il combattimento."

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

L["READINESS_TITLE"] = "Rapporto di preparazione"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Potenziamenti mancanti:"
L["READINESS_EXPIRING"] = "In scadenza:"
L["READINESS_MISSING_ITEMS"] = "Oggetti mancanti:"
L["READINESS_DAMAGED_GEAR"] = "Equipaggiamento danneggiato:"
L["READINESS_CHARACTER"] = "Personaggio:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento:"

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
L["READINESS_FLASK"] = "Tonico o 2x elisir"
L["READINESS_PET_FORMAT"] = "%s (famiglio)"
L["READINESS_SCROLLS"] = "Pergamene"
-- The switch for the Scrolls line.
L["FEATURE_SCROLL_BUFFS"] = "Potenziamenti delle pergamene"
L["READINESS_SOULSTONE"] = "Pietra dell'Anima inattiva"
L["READINESS_HEALTHSTONE"] = "Pietra della Salute"
L["READINESS_MANA_GEM"] = "Gemma di Mana"
L["READINESS_HEALING_POTION"] = "Pozione di Cura"
L["READINESS_MANA_POTION"] = "Pozione di Mana"
L["READINESS_BANDAGES"] = "Bende"
L["READINESS_PVP_ON"] = "PvP attivo"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s meno di 1 min"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto talento non speso"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d punti talento non spesi"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Al momento non hai alcun cibo utile per il tuo famiglio."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Al momento non conosci %s, %s, %s o %s."
L["TIP_NO_HAND_POISON"] = "Hai esaurito il veleno scelto per quest'arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Al momento non conosci %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "%s: non ne hai più nelle borse. Fai clic destro su %s per evocarne ancora."
L["TIP_EMPTY_CREATE"] = "%s: non ne hai più nelle borse. Fai clic destro su %s per crearne una."

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
L["MINIMAP_BEST_FOOD"] = "Cibo attuale"

-- The Ignore List block: its heading, the row that ignores the current food, and the row that clears the list.
L["MINIMAP_IGNORE_LIST"] = "Lista ignorati"
L["MENU_IGNORE"] = "Ignora"
L["MENU_CLEAR_IGNORE"] = "Svuota lista ignorati"

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
L["MINIMAP_RESTOCKER_STOCKED"] = "Complimenti, hai le scorte al completo!"
L["MINIMAP_RESTOCKER_EMPTY"] = "La tua lista è vuota."
L["MINIMAP_RESTOCKER_NOTHING_LOW"] = "Non sei a corto di nulla e non hai finito niente."

--[[
    The mini-map menu's Restocker block: a line saying what the list is
    for, and the click its Open row names.
    "Your list" in the description and in MINIMAP_RESTOCKER_EMPTY is this
    list. The Options row is always the menu's last, its click on its right.
]]
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra e deposita in banca gli oggetti della tua lista."
L["MENU_CLICK_SHIFT_RIGHT"] = "Maiusc + clic destro"
L["MENU_OPTIONS"] = "Opzioni di GtG"
L["MENU_CLICK_SHIFT_LEFT"] = "Maiusc + clic sinistro"
L["MENU_CLICK_SHIFT_MIDDLE"] = "Maiusc + clic centrale"
-- The Restocker block's Open row hover while the Restocker is off.
L["MENU_RESTOCKER_OPEN_OFF_DESCRIPTION"] = "Apre la tua Lista di rifornimento. Attiva il Restocker per usarla."

-- Buff Duty's block in the menu while its close button has hidden it: the word on its right, and the note under it.
L["MENU_BUFF_DUTY_PAUSED"] = "In pausa"
L["MENU_BUFF_DUTY_PAUSED_NOTE"] =
	"Nascosto finché non entri in un gruppo, rientri nel gioco o ricarichi l'interfaccia."

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
L["NOTE_MACRO_FEED_PET"] = "Macro Nutri Famiglio"
L["NOTE_MACRO_FOOD_WATER"] = "Macro Cibo e Acqua"
L["NOTE_MACRO_MANA_GEM"] = "Macro Gemma di Mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro Pietra Salute"
L["NOTE_MACRO_SOULSTONE"] = "Macro Pietra Anima"
L["NOTE_MACRO_POISONS"] = "Macro Veleni"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Richiama, nutri o rianima"
L["NOTE_PET_MEND_CLICK"] = "Clic destro, o in combattimento"
L["NOTE_HOLD_SHIFT"] = "Tieni premuto Maiusc"
L["NOTE_PET_FORCE_REVIVE"] = "Forza la rianimazione"
L["NOTE_HOLD_CONTROL"] = "Tieni premuto Ctrl"
L["NOTE_PET_DISMISS"] = "Congeda"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down (NOTE_CONJURE_LOWER_RANK, NOTE_CREATE_LOWER_RANK), since the bags
    hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Evoca"
L["NOTE_CREATE"] = "Crea"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Clic destro di nuovo"
L["NOTE_CONJURE_LOWER_RANK"] = "Evoca il grado inferiore"
L["NOTE_CREATE_LOWER_RANK"] = "Crea il grado inferiore"
L["NOTE_MAGE_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per evocare in base al suo livello."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per crearne una in base al suo livello."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Finestra dei veleni"
L["NOTE_POISONS_REPLACED"] = "Sostituisce automaticamente i vecchi veleni."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map menu. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Benda"
L["LABEL_EXPLOSIVE"] = "Esplosivo"
L["LABEL_FOOD"] = "Cibo"
L["LABEL_HEALTH_POTION"] = "Pozione di Salute"
L["LABEL_HEALTHSTONE"] = "Pietra della Salute"
L["LABEL_MANA_GEM"] = "Gemma di Mana"
L["LABEL_MANA_POTION"] = "Pozione di Mana"
L["LABEL_PET_FOOD"] = "Cibo per famigli"
L["LABEL_POISON"] = "Veleno"
L["LABEL_SOULSTONE"] = "Pietra dell'Anima"
L["LABEL_WATER"] = "Acqua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map menu: the Toggle and Open rows, and the button clicks rows name on their right.

L["MENU_TOGGLE"] = "Attiva/disattiva"
L["MENU_OPEN"] = "Apri"
L["MENU_CLICK_LEFT"] = "Clic sinistro"
L["MENU_CLICK_RIGHT"] = "Clic destro"
L["MENU_CLICK_MIDDLE"] = "Clic centrale"

-- The words on the right of a block's title.
L["MENU_ON"] = "Attivo"
L["MENU_OFF"] = "Disattivo"

-- The note after a list cut short at eight rows: %d is how many more there are, so it is never one.
L["MENU_MORE"] = "Altri %d"

--[[
    More Features, the row that opens the flyout of every feature without a
    block of its own, and its right side: how many of those are on and off,
    side by side ("4 On, 3 Off"), so the On count can take its own color.
]]
L["MENU_MORE_FEATURES"] = "Altre funzioni"
L["MENU_FEATURE_COUNT_ON"] = "%d attive"
L["MENU_FEATURE_COUNT_OFF"] = "%d disattive"

-- The mini-map menu's Enhanced Spellbook block, above the class macros: a line saying what it's for, then Open (MENU_OPEN),
-- as Shift + Left-Click on the button does. MENU_OPEN_SPELLBOOK is the click line on the spellbook tab's tooltip.
L["MENU_SPELLBOOK_DESCRIPTION"] = "Macro mouseover per ogni incantesimo, create con un clic."
L["MENU_OPEN_SPELLBOOK"] = "Apri il Libro degli incantesimi avanzato"

-- The body of Buff Duty's Toggle tooltip in the mini-map menu, under the Enable option's name. %s is the client's name for the player's class.
L["MENU_BUFF_DUTY_TOGGLE_CLASS_DESCRIPTION"] =
	"Attiva o disattiva il turno dei potenziamenti mentre giochi con la classe %s. Le tue altre classi mantengono la propria impostazione."

-- The row opening the class's macro notes, in the class color. %s is the client's name for the player's class.
L["MENU_CLASS_MACROS"] = "Macro (%s)"

--------------------------------------------------------------------------------
-- Group Contexts
--------------------------------------------------------------------------------

--[[
    The checkboxes for when a feature acts by group, on every panel that has
    them, always in this order. Each description is the checkbox's hover text,
    saying when that context holds: a battleground or arena is always
    Battleground, even though its group is a raid.
]]
L["GROUP_CONTEXT_SOLO"] = "Da solo"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "Quando non sei in un gruppo o in un'incursione."
L["GROUP_CONTEXT_PARTY"] = "Gruppo"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] =
	"Quando sei in un gruppo, anche in una spedizione trovata con la ricerca di gruppo."
L["GROUP_CONTEXT_RAID"] = "Incursione"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] =
	"Quando sei in un'incursione. L'incursione di un campo di battaglia conta come Campo di battaglia."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Campo di battaglia"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] =
	"Quando sei in un campo di battaglia o in un'arena, qualunque sia il tuo gruppo."

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
	'Determina a quali livelli la tua macro Cibo propone "%s": a qualsiasi livello, solo mentre sali di livello o solo al livello massimo. Le caselle qui sotto determinano in quali gruppi.'
L["OPTIONS_MODE_CAPTION"] = "Quando usarlo"
L["OPTIONS_GROUPS_NONE"] = "Non è spuntato nulla, quindi non viene mai usato."
L["LEVEL_FILTER_ANY"] = "A qualsiasi livello"
L["LEVEL_FILTER_LEVELING"] = "Mentre sali di livello"
L["LEVEL_FILTER_MAX_LEVEL"] = "Al livello massimo"

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
L["INVENTORY_REPORT_TITLE"] = "Rapporto di inventario"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Borse %s, Banca %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Borse %s"
L["INVENTORY_REPORT_BANK"] = "Banca %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Totale %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macro che si aggiornano da sole con il tuo cibo, acqua, pozioni e Pietre della Salute migliori, una lista di rifornimento che compra e deposita in banca reagenti e munizioni, potenziamenti mancanti con un clic, avvisi sui gradi bassi degli incantesimi e macro mouseover per ogni incantesimo."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Libro degli incantesimi avanzato"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Macro al passaggio del mouse, sul cursore e su te stesso per ogni incantesimo di classe, create con un clic da una nuova scheda del libro degli incantesimi, senza sintassi delle macro. Si aggiornano quando sali di livello, ti addestri o cambi specializzazione. Fai clic destro per aggiungere focus, interruzione del lancio, attacco automatico, attacco del famiglio o monili."
L["SPELLBOOK_IS_OFF"] =
	"Il Libro degli incantesimi avanzato è disattivato. Attivalo in Opzioni > AddOn > Good to Go > Libro degli incantesimi avanzato."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Attiva il messaggio di benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Mostra un messaggio di benvenuto in chat all'accesso."

-- Mini-map Button
L["OPTIONS_MINIMAP_BUTTON"] = "Attiva il pulsante della minimappa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Mostra il pulsante della minimappa."

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
L["OPTIONS_FEATURES_HEADER"] = "Funzionalità"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Mostra una finestra con tutti i membri del tuo gruppo a cui manca un potenziamento che puoi dare. Fai clic su un'icona per lanciarlo."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Tiene rifornite le tue borse in base alla tua lista di rifornimento, comprando dai mercanti e spostando oggetti da e verso la banca, e ti avvisa quando le scorte scarseggiano. Se lo disattivi si ferma tutto, compresa la finestra della lista di rifornimento. Le tue liste restano salvate."
L["SWITCH_SPELLBOOK"] = "Attiva il Libro degli incantesimi avanzato"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Aggiunge al tuo libro degli incantesimi una scheda che crea macro al passaggio del mouse, sul cursore e su te stesso per i tuoi incantesimi, e le tiene aggiornate mentre sali di livello e ti addestri. Se lo disattivi, la scheda sparisce e gli aggiornamenti si fermano. Non elimina mai una macro: lo fanno i pulsanti Elimina macro nella pagina Libro degli incantesimi avanzato."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Disattivare il Libro degli incantesimi avanzato? La sua scheda scompare dal libro degli incantesimi e le macro che ha creato smettono di aggiornarsi mentre sali di livello e ti addestri. Non vengono eliminate: restano sulle tue barre delle azioni così come sono ora."
L["SWITCH_MACROS"] = "Attiva le macro dei consumabili"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Mantiene le tue macro di cibo, acqua, pozioni e altri consumabili puntate sul miglior oggetto nelle tue borse man mano che il contenuto cambia. Se lo disattivi, gli aggiornamenti si fermano e ogni macro resta com'era l'ultima volta. Non elimina mai una macro: per farlo, togli la spunta in Macro da creare nella pagina Macro dei consumabili."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Disattivare le macro dei consumabili? Le tue macro smettono di aggiornarsi quando cambia il contenuto delle borse, quindi un pulsante potrebbe continuare a cercare un oggetto che hai finito. Non vengono eliminate: restano sulle tue barre delle azioni così come sono ora."
L["SWITCH_INVENTORY_REPORT"] = "Attiva il Rapporto di inventario"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Aggiunge al tooltip di un oggetto quanti ne hai nelle borse, in banca e sugli altri personaggi di questo reame. Disattivalo se un altro add-on mostra già questi conteggi."
L["SWITCH_READINESS_REPORT"] = "Attiva il Rapporto di preparazione"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Quando inizia un appello, mostra in privato un elenco di ciò che devi ancora sistemare, come un potenziamento mancante, una pozione o l'equipaggiamento danneggiato. Non dice nulla se sei pronto."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Attiva il Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Esempio"

-- A Reset button, which puts the settings it sits under, or the whisper box beside it, back to their defaults.
L["OPTIONS_RESET"] = "Ripristina"
L["OPTIONS_FEATURE_OFF_STATUS"] =
	"La funzione %s è disattivata, quindi queste impostazioni non vengono usate. Il suo interruttore è nella pagina %s."

--[[
    The whisper composer around every whisper a player words themselves, on the Buff Duty and Rank Watch
    panels: the language they go out in, the caption and Reset button (OPTIONS_RESET) beside each box, the
    tooltip on the marker and the "// GtG" either side of it, the line shown when a whisper is too long, and the
    test button.
    The whispers' default text lives in Data/Message-Languages.lua, not here.
]]
L["SEND_MESSAGES_IN"] = "Invia i messaggi in"
L["SEND_MESSAGES_IN_DESCRIPTION"] =
	"Imposta la lingua in cui Good to Go scrive quando sussurra agli altri giocatori. Scegliendo un'altra lingua viene inserito il suo testo predefinito, a meno che tu non abbia scritto il tuo."
L["WHISPER_TEXT"] = "Messaggio sussurrato"
L["WHISPER_TEXT_RESET_DESCRIPTION"] = "Riporta questo sussurro al testo predefinito nella lingua in cui invii."
L["WHISPER_SIGN_OFF_DESCRIPTION"] =
	"Aggiunto a ogni sussurro inviato da Good to Go, così gli altri giocatori capiscono che arriva da un add-on."
L["WHISPER_TOO_LONG"] = "Troppo lungo, quindi verrà inviato il testo predefinito."
L["WHISPER_TEST"] = "Inviami una prova"
L["WHISPER_TEST_DESCRIPTION"] = "Ti sussurra l'esempio, così lo vedi esattamente come lo vedranno gli altri giocatori."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Apre la tua lista di rifornimento."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Questo add-on è stato creato da giocatori che amano questo gioco e vogliono renderlo il più divertente possibile per tutti. Non chiederemo mai donazioni. La vera soddisfazione è sapere che il nostro lavoro rende il gioco un po' migliore per te. Se è così, ci piacerebbe saperlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Ecco alcuni modi in cui puoi aiutarci a raggiungere più giocatori."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Condividi il tuo feedback: Hai trovato un bug o hai un'idea? Faccelo sapere su Discord. Il tuo feedback ci aiuta a migliorare l'add-on, e le pull request sono sempre benvenute."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Dillo a un amico: Conosci qualcuno a cui potrebbe piacere questo add-on? Parlagliene. Il passaparola aiuta più giocatori a scoprire ottimi add-on."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Preferito su CurseForge: Apri il link di CurseForge qui sotto, accedi e clicca sulla stella sotto il pulsante Download. I preferiti aiutano più giocatori a scoprire l'add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Stella su GitHub: Apri il link di GitHub qui sotto, accedi e clicca su Star in alto a destra. Le stelle aiutano il progetto ad accedere a più strumenti gratuiti per sviluppatori."

L["OPTIONS_FEEDBACK"] = "Feedback e supporto"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Link di feedback e supporto"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Per copiare un link, clicca sulla sua casella, poi premi Ctrl+A e Ctrl+C."
L["OPTIONS_VERSION"] = "Versione %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's headerless Enable Consumable Macros toggle; Enable
    Macro Names on Buttons sits under Action Bars at the foot of the page.
]]
L["TAB_CONSUMABLE_MACROS"] = "Macro dei consumabili"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go crea una macro per ogni consumabile e la tiene aggiornata mentre il contenuto delle tue borse cambia, così il pulsante sulla barra punta sempre al miglior oggetto che hai con te. Scegli qui sotto quali macro creare; le impostazioni di ciascuna sono in una pagina propria, sotto questa."

-- Action Bars, at the foot of the Consumable Macros page: Macro Names on Buttons
L["OPTIONS_ACTION_BARS_HEADER"] = "Barre delle azioni"
L["OPTIONS_MACRO_NAMES"] = "Attiva i nomi delle macro sui pulsanti"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Mostra sui pulsanti della barra delle azioni il nome delle macro, che Good to Go nasconde per impostazione predefinita."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Macro da creare"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Scegli quali macro Good to Go crea e mantiene. Disattivarne una la rimuove anche. Si trovano nella scheda Macro generali della finestra delle macro, pronte da trascinare sulle tue barre delle azioni."
L["OPTIONS_MACROS_WINDOW"] = "Finestra delle macro"
L["OPTIONS_OPEN"] = "Apri"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Apre la finestra delle macro del gioco sulla scheda Macro generali, dove si trovano queste macro."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea e mantiene questa macro e la rimuove quando togli la spunta."

--[[
    Food & Drinks, the page under Consumable Macros (Options-Food-Drinks.lua).
    OPTIONS_FOOD_WATER_HEADER is its label in the settings tree and the end of
    its title. Its sections: Which Food Comes First (Use Conjured Food & Water
    First, Use Restock List Food & Water Last, Eat Buff Food When Already Well
    Fed), then the class and race options that change how you eat and drink.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Cibo e bevande"
L["OPTIONS_FOOD_DRINKS_DESCRIPTION"] =
	"Le tue macro Cibo e Acqua mangiano e bevono il meglio che hai con te. Queste opzioni cambiano cosa conta come il meglio e come mangi e bevi. Il cibo potenziante e le pergamene, usati per i loro potenziamenti, sono nella pagina Potenziamenti personali del Turno dei potenziamenti."
L["OPTIONS_FOOD_ORDER_HEADER"] = "Quale cibo viene prima"
L["OPTIONS_FOOD_ORDER_DESCRIPTION"] =
	"Tra due cibi o bevande, le tue macro usano quello che ripristina di più. Queste opzioni cambiano quell'ordine."

--[[
    Eat Buff Food When Already Well Fed, last under Which Food Comes First,
    and in Buff Duty's Buff Food flyout. %s in its hover text is the client's
    name for the Well Fed buff.
]]
L["OPTIONS_BUFF_FOOD_WHEN_FED"] = "Mangia cibo potenziante anche se già Ben nutrito"
L["OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT"] =
	'Le tue macro Cibo e Acqua trattano il cibo potenziante come qualsiasi altro cibo e mangiano quello che ripristina di più. Disattivato, lo conserva perché il Turno dei potenziamenti te lo offra quando ti serve "%s", a meno che non sia tutto ciò che hai.'

-- The scroll types on Buff Duty's Self-Buffs page. The other five are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_TYPES"] = "Includi i tipi di pergamena nel controllo"
L["OPTIONS_SCROLL_PROTECTION"] = "Protezione"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Include "%s" nel controllo dei potenziamenti mancanti.'

-- Use Conjured Food & Water First, the first option under Which Food Comes First.
L["OPTIONS_CONJURED_FIRST"] = "Usa prima cibo e acqua evocati"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	"Le tue macro Cibo e Acqua usano cibo e acqua evocati prima di qualsiasi altra cosa, anche se qualcosa nelle tue borse ripristina di più, perché non costano nulla e svaniscono poco dopo la disconnessione."
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Determina a quali livelli cibo e acqua evocati hanno la precedenza: a qualsiasi livello, solo mentre sali di livello o solo al livello massimo. Le caselle qui sotto determinano in quali gruppi."

-- Use Restock List Food & Water Last, the second option under Which Food Comes First.
L["OPTIONS_RESTOCK_LAST"] = "Usa per ultimi cibo e acqua della lista di rifornimento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Tra due cibi o bevande che ripristinano la stessa quantità, le tue macro Cibo e Acqua usano quello che non è nella tua lista di rifornimento, conservando per dopo ciò che compra il Restocker."

--[[
    The pages under Consumable Macros for the smaller macro families
    (Options-Potions-Mana-Gems.lua and its neighbors): each TAB_* is its label in the settings tree
    and the end of its title, and each *_DESCRIPTION the intro under it.
    Explosives takes OPTIONS_EXPLOSIVES_HEADER.
]]
L["TAB_POTIONS_MANA_GEMS"] = "Pozioni e gemme di mana"
L["OPTIONS_POTIONS_MANA_GEMS_DESCRIPTION"] =
	"Le tue macro Pozione di Salute, Pozione di Mana e Gemma di Mana usano il meglio che hai con te, con alternative per quando finisce."
L["TAB_BANDAGES"] = "Bende"
L["OPTIONS_BANDAGES_DESCRIPTION"] =
	"La tua macro Benda usa la benda che cura di più tra quelle consentite dalla tua abilità di Primo Soccorso."
-- The Bandages page's line under its description, pointing at the settings that change the Bandage macro.
L["OPTIONS_BANDAGES_SUMMARY"] =
	"Per tenere una benda fuori dalla macro, aggiungila alla lista ignorati. La scelta per la Rigenerazione rapida dei troll è nella pagina Cibo e bevande."
L["TAB_HEALTHSTONE"] = "Pietra della Salute"
L["OPTIONS_HEALTHSTONE_DESCRIPTION"] =
	"La tua macro Pietra della Salute usa la tua miglior pietra della salute, con alternative. Con uno stregone, il clic destro ne crea una e il clic centrale crea un Pozzo delle Anime, se lo conosci."

-- Potions & Healthstones, the first section on Potions & Mana Gems.
L["OPTIONS_POTIONS_HEADER"] = "Pozioni e Pietre della Salute"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Le macro non possono cambiare durante il combattimento (questa è una restrizione della Blizzard), quindi ogni macro per Pozioni e Pietre della Salute è pre-costruita con il tuo miglior oggetto più fino a due alternative. Nei combattimenti più lunghi, l'icona e il tooltip possono diventare obsoleti e mostrare l'oggetto sbagliato, ma cliccando sulla macro verrà sempre utilizzato il miglior oggetto che hai effettivamente nelle borse."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usa cibo e acqua nelle macro delle pozioni fuori dal combattimento"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuori dal combattimento, la tua macro Pozione di Salute mangia il tuo miglior cibo e la tua macro Pozione di Mana beve la tua miglior acqua. In combattimento, usano le tue pozioni come prima. Il cibo per famigli e l'evocazione restano nelle macro Cibo e Acqua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combina le Pietre della Salute nella macro Pozione di Salute"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Aggiunge la tua migliore Pietra della Salute in fondo alla macro Pozione di Salute, così una singola pressione usa una pozione e una Pietra della Salute."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemme di Mana e rune"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s e alcuni altri oggetti per il mana condividono il tempo di recupero con le Gemme di Mana. Usare le rune costa salute, quindi la macro Gemma di Mana esclude tutti questi oggetti, a meno che tu non li aggiunga."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Aggiungi le rune e gli altri oggetti per il mana alla macro Gemma di Mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Inserisce nella stessa classifica delle tue Gemme di Mana %s, %s e ogni altro oggetto per il mana che ne condivide il tempo di recupero, così la macro Gemma di Mana ne usa uno quando è la tua opzione migliore o quando hai finito le gemme."

-- Refresh Pet Food Under, closing the Hunter section on Class Macros: "Refresh Under", as Buff Duty names its timing.
L["OPTIONS_REAPPLY"] = "Rinnova il cibo del famiglio sotto"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera scaduto il potenziamento del cibo del tuo famiglio quando resta meno tempo della tua soglia, così la tua macro Cibo te ne propone uno nuovo prima dello scontro."
--[[
    Threshold dropdown, beside the Refresh Pet Food Under toggle, whose label
    carries the "under", so the values are plain durations.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza può arrivare un potenziamento prima che le tue macro te ne propongano uno nuovo."
L["REAPPLY_THRESHOLD_ONE"] = "1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "%d minuti"

-- Pet Food Buffs, in the Hunter section on Class Macros. OPTIONS_PET_HEADER names the feature in its When to Use hover text.
L["OPTIONS_PET_HEADER"] = "Potenziamenti del cibo per famigli"
-- The summary line under Class Macros' Hunter header.
L["OPTIONS_CLASS_MACROS_HUNTER_SUMMARY"] = "Tieni il tuo famiglio ben nutrito con la tua macro Cibo."
L["OPTIONS_USE_PET_BUFFS"] = "Usa i potenziamenti del cibo per famigli"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Aggiunge il cibo per famigli alla tua macro Cibo quando al tuo famiglio manca "%s", tranne nelle arene.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Includi i tipi di cibo per famigli nel controllo"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Esplosivi"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"L'opzione @player salta il reticolo di puntamento e fa detonare l'esplosivo ai tuoi piedi. Ideale quando il bersaglio è in mischia. L'altro clic lancia l'esplosivo come al solito."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Assegnazione dei clic"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Determina quale clic lancia l'esplosivo e quale lo fa detonare ai tuoi piedi."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic sinistro: @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic sinistro: lancio"

--[[
    Class Macros panel (Options-Class-Macros.lua), nested under Consumable Macros. TAB_CLASS_MACROS
    is its label in the settings tree and the end of its title; OPTIONS_CLASS_MACROS_DESCRIPTION is the
    intro beneath it. The class and race headers below also head Food & Drinks' racial sections.
]]
L["TAB_CLASS_MACROS"] = "Macro di classe"
L["OPTIONS_CLASS_MACROS_DESCRIPTION"] =
	"Queste opzioni modellano le macro di una singola classe: Nutri Famiglio, Pietra dell'Anima e Veleni si attivano in Macro dei consumabili, e ogni sezione compare su ogni personaggio."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Opzioni di classe: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Opzioni razziali: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Richiede l'add-on DruidMacroHelper. Se attivo, le tue macro Pozione di Salute, Pozione di Mana e Pietra della Salute ti fanno uscire dalla forma, usano l'oggetto e ti riportano in Forma d'Orso o Forma Felina, quella che scegli accanto alla casella."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Usa DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macro di mutaforma per Pozioni di Salute, Pozioni di Mana e Pietre della Salute utilizzando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Determina la forma in cui le tue macro di mutaforma ti riportano dopo l'uso dell'oggetto."
L["DRUID_FORM_BEAR"] = "Torna in Forma d'Orso"
L["DRUID_FORM_CAT"] = "Torna in Forma Felina"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro Veleni carica con il miglior grado utilizzabile di ogni tipo di veleno: clic sinistro applica alla mano secondaria, clic destro alla mano primaria, e i veleni esistenti vengono sostituiti automaticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo di veleno mano primaria"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo di veleno mano secondaria"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano primaria con il clic destro."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano secondaria con il clic sinistro."
-- The summary line under Food & Drinks' Rogue header.
L["OPTIONS_FOOD_DRINKS_ROGUE_SUMMARY"] =
	"Entra in furtività mentre ti siedi a mangiare, così riposi senza essere visto."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating and
    drinking toggles. In both hover texts %s is the client's name for the
    spell the macro appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Attiva la furtività mentre mangi"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "Aggiunge %s alla tua macro Cibo per renderti furtivo mentre mangi."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Attiva la furtività mentre bevi"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "Aggiunge %s alla tua macro Acqua per renderti furtivo mentre bevi."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Scegline uno. Puoi mangiare e bere allo stesso tempo, ma mangiare o bere dopo esserti reso furtivo interromperà la furtività."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Prendi come bersaglio un umanoide o un non morto che hai ucciso e la tua macro usa %s finché l'abilità è pronta, risparmiando cibo e bevande. Se non può (il cadavere è fuori portata o l'abilità è in ricarica), mangia o beve come al solito."
L["OPTIONS_CANNIBALIZE_EATING"] = "Usa %s invece di mangiare"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Finché il tuo bersaglio è un cadavere su cui funziona %s e l'abilità è pronta, la tua macro Cibo la usa invece di mangiare. Altrimenti mangia come al solito."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Usa %s invece di bere"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Finché il tuo bersaglio è un cadavere su cui funziona %s e l'abilità è pronta, la tua macro Acqua la usa invece di bere. Altrimenti beve come al solito. Le bevande potenzianti hanno comunque la precedenza."

--[[
    Trolls, headed with the client's name for the race. In the five texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"%s ti cura anche in combattimento, dove non puoi mangiare. La tua macro Cibo può usarla in combattimento e la tua macro Benda fuori dal combattimento, risparmiando le bende."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "Usa %s invece di mangiare in combattimento"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"In combattimento, dove non puoi mangiare, la tua macro Cibo usa %s al suo posto. Fuori dal combattimento mangia come al solito."
L["OPTIONS_RAPID_REGENERATION_BANDAGE"] = "Usa %s invece di una benda fuori dal combattimento"
L["OPTIONS_RAPID_REGENERATION_BANDAGE_DESCRIPTION"] =
	"Fuori dal combattimento, finché %s non è in recupero, la tua macro Benda la usa al suo posto, risparmiando le bende. In recupero, o in combattimento, usa una benda come al solito."

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
L["TAB_IGNORE_LIST"] = "Lista ignorati"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Gli oggetti ignorati non vengono mai scelti da nessuna macro. Cibo, acqua, pozioni, qualsiasi cosa. La lista Globale vale per tutti i personaggi; quella di un personaggio vale solo per lui. Fai clic destro sul pulsante della minimappa per ignorare il tuo miglior cibo attuale."
L["OPTIONS_IGNORE_GLOBAL"] = "Globale"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Sposta questo oggetto nella lista Globale, così viene ignorato su tutti i personaggi."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Aggiungi dalle borse"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Scegli qualsiasi cosa tu abbia con te. Le borse si chiudono quando si apre l'interfaccia delle opzioni, quindi questo sostituisce il trascinamento di un oggetto qui."
L["OPTIONS_IGNORE_ADD_ID"] = "Aggiungi tramite ID oggetto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat mentre questo campo è attivo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat."
L["OPTIONS_IGNORE_REMOVE"] = "Rimuovi"
L["OPTIONS_IGNORE_EMPTY"] = "Questa lista è vuota."
L["OPTIONS_IGNORE_CLEAR"] = "Svuota lista"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Rimuove tutti gli oggetti da questa lista. Un personaggio con la lista vuota sparisce dall'elenco a sinistra, a meno che non sia quello che stai giocando."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] =
	"Rimuovere tutti gli oggetti da questa lista? L'operazione non può essere annullata."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Caricamento ID: %d"
-- %d is how many of an item you carry, after its name in a menu ("x12").
L["ITEM_QUANTITY"] = "x%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene rifornite le tue borse in base alla tua lista di rifornimento, comprando dai mercanti e spostando automaticamente gli oggetti da e verso la banca. Digita %s per aprire la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Apri in banca"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti la banca."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Apri dal mercante"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti un mercante."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Promemoria"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"Scegli quando ricevere un avviso se ti mancano oggetti della lista di rifornimento."
-- Low Means Under, the dropdown above the three reminders: the share of a row's amount below which they call it low. Its values are percentages, written the same in every locale.
L["OPTIONS_RESTOCKER_LOW_THRESHOLD"] = "Poco significa sotto il"
L["OPTIONS_RESTOCKER_LOW_THRESHOLD_DESCRIPTION"] =
	"Un oggetto conta come poco quando ne hai meno di questa quota di quanto chiede la tua lista di rifornimento, e come finito quando non ne hai più. Sopra la soglia non viene menzionato."
L["OPTIONS_RESTOCKER_REMIND"] = "Attiva i promemoria di rifornimento in città"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Mostra un promemoria in chat quando ti resta poco o hai finito qualcosa della tua lista di rifornimento e raggiungi una locanda o una città, o ti trovi già in una all'accesso."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Attiva i promemoria di rifornimento dal mercante"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Segnala ciò di cui ti resta poco o che hai finito quando chiudi la finestra di un mercante."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Attiva i promemoria di rifornimento in banca"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Segnala ciò di cui ti resta poco o che hai finito quando chiudi la banca."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Riserva d'oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"Metti da parte l'oro che gli acquisti dai mercanti non spenderanno mai."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Attiva la riserva d'oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "Il rifornimento non spende mai l'oro che metti da parte qui."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Imposta quanto oro il rifornimento ti lascia sempre."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item it counted (out, then low), showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown under each reminder,
    beside its How Much to Say caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Determina se il promemoria sia una sola riga o ne aggiunga una per ogni oggetto di cui ti resta poco o che hai finito."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Livello di dettaglio"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Semplice"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Dettagliato"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Riproduci suono"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Riproduce un avviso insieme al promemoria, per quando la chat è affollata."
L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"] = "Riproduce subito questo suono, che il suono sia attivo o no."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Finestra della lista di rifornimento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Scegli quando la tua lista di rifornimento si apre da sola."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description. Its switch is SWITCH_INVENTORY_REPORT, under Features.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Mostra nel tooltip di un oggetto quanti ne possiedi, contando tutti i tuoi personaggi di questo reame."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Personaggi registrati"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Dimentica"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"Dimenticare %s? Le sue borse e la sua banca spariscono dai tooltip di tutti gli oggetti e la sua scelta della lista di rifornimento viene cancellata. Accedendo con quel personaggio verrà registrato di nuovo."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Rapporto di preparazione"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quando parte un appello, mostra in chat una lista privata di ciò che va ancora sistemato e, se sei pronto, non dice proprio nulla."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Ripristina le impostazioni del rapporto di preparazione"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Riporta ai valori predefiniti ogni casella ed entrambe le soglie di questa pagina."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Ripristinare tutte le impostazioni del rapporto di preparazione ai valori predefiniti?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Potenziamenti mancanti"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Oggetti mancanti"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaggio"
-- The summary line under each of the Readiness Report's three headers.
L["OPTIONS_READINESS_BUFFS_SUMMARY"] = "I potenziamenti che dovresti avere prima dello scontro."
L["OPTIONS_READINESS_ITEMS_SUMMARY"] =
	"I consumabili che dovresti avere con te, e l'equipaggiamento che vale la pena riparare."
L["OPTIONS_READINESS_CHARACTER_SUMMARY"] = "Impostazioni del tuo personaggio facili da dimenticare."

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Segnala se manca un tonico. Basta un tonico, oppure un elisir di combattimento e un elisir di protezione."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] = 'Segnala se ti manca il potenziamento "%s".'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Segnala se al tuo famiglio manca il potenziamento "%s". Richiede Usa i potenziamenti del cibo per famigli attivo nella pagina Macro di classe e un famiglio evocato.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Segnala i potenziamenti delle pergamene mancanti, per i tipi di pergamena spuntati nella pagina Potenziamenti personali del Turno dei potenziamenti."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Segnala quando nessuno nel tuo gruppo ha una Pietra dell'Anima attiva; una rimasta in una borsa non conta. Segnalato solo a uno Stregone che può crearne una."
L["OPTIONS_READINESS_MAIN_HAND"] = "Potenziamento arma (mano primaria)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano primaria senza incantamento temporaneo. Conta qualsiasi incantamento, e resta in silenzio quando nel tuo gruppo c'è uno Sciamano."
L["OPTIONS_READINESS_OFF_HAND"] = "Potenziamento arma (mano secondaria)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano secondaria senza incantamento temporaneo. Conta qualsiasi incantamento: una pietra, un olio, un veleno o un potenziamento d'arma da Sciamano."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Segnala un'arma nella mano primaria a cui manca un incantamento temporaneo. A Ladri e Sciamani ne servono due, un veleno o un'infusione accanto a un olio o una pietra; agli altri, uno qualsiasi."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Segnala un'arma nella mano secondaria a cui manca un incantamento temporaneo. Ai Ladri ne servono due, un veleno accanto a un olio o una pietra; agli altri, uno qualsiasi."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Class Macros page has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Potenziamenti in scadenza entro"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Elenca ogni potenziamento su di te che sta per scadere, non solo quelli applicati da Good to Go, ed è separato da Rinnova i potenziamenti in scadenza nella pagina Macro di classe."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minuti"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza deve essere un potenziamento perché il rapporto lo elenchi."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Pietra della Salute. Segnalato solo quando c'è uno Stregone nel gruppo a cui chiederla, o quando lo Stregone sei tu."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Gemma di Mana. Segnalato solo a un Mago che può evocarne una."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di cura, perché nessuno può passartene una in pieno combattimento."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di mana. Segnalato solo quando giochi con una classe che usa il mana."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna benda che la tua abilità in %s ti permetta di usare."
L["OPTIONS_READINESS_DURABILITY"] = "Equipaggiamento danneggiato sotto"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Mostra il collegamento di ogni oggetto equipaggiato con integrità inferiore a questa soglia, calcolata oggetto per oggetto, così compare anche una sola arma rotta."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto deve scendere l'integrità di un oggetto perché il rapporto ne mostri il collegamento."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Specializzazione attuale"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Mostra la distribuzione dei talenti e gli eventuali punti che non hai speso."
L["OPTIONS_READINESS_PVP"] = "PvP attivo"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avvisa quando la tua modalità PvP è attiva."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Mostra il collegamento degli oggetti equipaggiati che non c'entrano con un combattimento, come l'attrezzatura da equitazione o da pesca."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its whispers are the
    player's to word on the Rank Watch panel, with their default text in Data/Message-Languages.lua; its prints
    are fixed. Rank Sentinel is the standalone add-on Rank Watch replaces; its name stays as written in every
    locale.
]]
L["TAB_RANK_WATCH"] = "Controllo dei gradi"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Sorveglia il tuo gruppo alla ricerca di incantesimi lanciati a un grado inferiore a quello che chi li lancia potrebbe usare, e gli fa sapere che un grado più alto lo aspetta dal suo istruttore. Un grado che il gioco abbassa da solo, come un potenziamento su un giocatore di basso livello, non viene mai segnalato."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s è ancora attivo, quindi il Controllo dei gradi di Good to Go resta in silenzio per evitare che il tuo gruppo venga avvisato due volte di ogni grado basso. Good to Go ha disattivato quell'add-on e attivato il proprio Controllo dei gradi; ricarica l'interfaccia per lasciare il posto al Controllo dei gradi di Good to Go."

-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Grado %d"

-- Printed when a group member whispers "Opt Out". %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'%s ti ha sussurrato "Opt Out", quindi il Controllo dei gradi ora ignora questo giocatore. Puoi annullare da Giocatori ignorati, nel Controllo dei gradi.'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"Hai lanciato %s, ma %s è disponibile dal livello %d. Visita il tuo istruttore o aggiorna le barre delle azioni."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "Il tuo famiglio %s ha lanciato %s, ma %s è disponibile dal livello %d del famiglio."
L["RANK_WATCH_PRINT_SELF_DEMON"] = "Il tuo demone %s ha lanciato %s, ma %s è disponibile dal livello %d."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s ha lanciato %s, ma ha a disposizione %s dal livello %d."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"Il famiglio di %s, %s, ha lanciato %s, ma ha a disposizione %s dal livello %d del famiglio."
L["RANK_WATCH_PRINT_OTHER_DEMON"] = "Il demone di %s, %s, ha lanciato %s, ma ha a disposizione %s dal livello %d."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s glielo farà sapere con un sussurro."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Attiva il Controllo dei gradi"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Avvisa te, e sussurra ai membri del tuo gruppo, quando qualcuno lancia un incantesimo a un grado inferiore a quello che potrebbe usare, così sa che deve passare dal suo istruttore."

L["RANK_WATCH_MESSAGES_HEADER"] = "Notifiche"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] = "Come il Controllo dei gradi avvisa un giocatore che ha lanciato un grado basso."
L["RANK_WATCH_WHISPER"] = "Sussurra ai membri del gruppo"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Sussurra a un membro del gruppo che ha lanciato un grado basso. Quando più giocatori del tuo gruppo usano il Controllo dei gradi o Rank Sentinel, solo uno di loro sussurra."
--[[
    The tip's whisper composer, under the whisper toggle: one box for the caster's own low rank, one for a
    hunter's pet, one for a warlock's demon.
    TRANSLATORS: keep {spell}, {level} and {pet} exactly as written; they are the tokens players type into the
    whisper. In the TOKENS lines each %s is a token, in the order shown, drawn in blue.
]]
L["RANK_WATCH_TIP_MESSAGE_DESCRIPTION"] =
	"Imposta cosa sussurra Good to Go a un membro del gruppo che ha lanciato un grado basso. {spell} diventa l'incantesimo e il grado lanciati, e {level} il livello in cui arriva un grado più alto. Lascialo vuoto per non inviare alcun sussurro."
L["RANK_WATCH_TIP_TOKENS"] = "Segnaposto: %s l'incantesimo e il grado lanciati, %s il livello del grado più alto"
L["RANK_WATCH_TIP_PET_MESSAGE"] = "Sussurro per il famiglio"
L["RANK_WATCH_TIP_PET_MESSAGE_DESCRIPTION"] =
	"Imposta cosa sussurra Good to Go a un cacciatore il cui famiglio ha lanciato un grado basso. {pet} diventa il nome del famiglio, {spell} l'incantesimo e il grado lanciati, e {level} il livello del famiglio in cui arriva un grado più alto. Lascialo vuoto per non inviare alcun sussurro."
L["RANK_WATCH_TIP_PET_TOKENS"] =
	"Segnaposto: %s il nome del famiglio, %s l'incantesimo e il grado, %s il livello del famiglio per il grado più alto"
L["RANK_WATCH_TIP_DEMON_MESSAGE"] = "Sussurro per il demone"
L["RANK_WATCH_TIP_DEMON_MESSAGE_DESCRIPTION"] =
	"Imposta cosa sussurra Good to Go a uno stregone il cui demone ha lanciato un grado basso. {pet} diventa il tipo di demone, come l'imp, {spell} l'incantesimo e il grado lanciati, e {level} il livello in cui arriva un grado più alto. Lascialo vuoto per non inviare alcun sussurro."
L["RANK_WATCH_TIP_DEMON_TOKENS"] =
	"Segnaposto: %s il tipo di demone, %s l'incantesimo e il grado, %s il livello del grado più alto"
L["RANK_WATCH_PRINT"] = "Mostra i gradi bassi dei membri del gruppo"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"Mostra nella tua chat il grado basso di un membro del gruppo. I tuoi gradi bassi vengono sempre mostrati."
L["RANK_WATCH_GRACE_HEADER"] = "Periodo di tolleranza"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"Un nuovo grado non viene segnalato finché chi lancia non ha superato il suo livello di questo numero di livelli, così nessuno viene avvisato di un grado appena raggiunto che non ha ancora avuto tempo di apprendere."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Tolleranza al livello massimo"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"Per un personaggio al livello massimo, ignora qualsiasi grado appreso entro questo numero di livelli dal massimo. A 0, viene segnalato ogni grado che potrebbe avere."
L["RANK_WATCH_GRACE_LEVELING"] = "Tolleranza mentre si sale di livello"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"Per un personaggio che sta ancora salendo di livello, ignora qualsiasi grado appreso entro questo numero di livelli dal suo, dandogli il tempo di raggiungere un istruttore."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 livello"
L["RANK_WATCH_GRACE_LEVELS"] = "%d livelli"

--[[
    The opt-out whispers' composer, under the tip's, while Whisper Group Members is on: the offer sent with a
    player's second tip in a session, and the reply to a group member who whispers "Opt Out" back.
    TRANSLATORS: keep "Opt Out" in English; it is the words a player whispers back, and Good to Go listens for
    exactly those.
]]
L["RANK_WATCH_OPT_OUT_MESSAGE"] = "Offerta di esclusione"
L["RANK_WATCH_OPT_OUT_MESSAGE_DESCRIPTION"] =
	'Imposta cosa sussurra Good to Go subito dopo il secondo consiglio sui gradi a un giocatore in una sessione. Digli di rispondere "Opt Out". Lascialo vuoto per non inviare l\'offerta.'
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE"] = "Risposta all'esclusione"
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE_DESCRIPTION"] =
	'Imposta cosa risponde Good to Go con un sussurro a un membro del gruppo che sussurra "Opt Out". Lascialo vuoto per non inviare risposta.'
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'La seconda volta che il Controllo dei gradi sussurra a qualcuno in una sessione, gli spiega subito dopo come escludersi. Se ti sussurra "Opt Out" mentre è nel tuo gruppo, finisce tra i Giocatori ignorati, gli rispondi per confermare e non riceverà mai più tuoi messaggi sui gradi. Per lasciare in pace qualcuno di tua iniziativa, selezionalo come bersaglio e digita /gtg ignore.'
--[[
    Who whispers for your group: a silver line under Whisper Group Members. %s is one of the three answers
    below, RANK_WATCH_WHISPERER_SELF, _OTHER or _NONE.
]]
L["RANK_WATCH_WHO_WHISPERS_FORMAT"] = "Chi sussurra per il tuo gruppo in questo momento: %s"
L["RANK_WATCH_WHISPERER_SELF"] = "Tu."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s, quindi tu vedi solo il messaggio in chat."
L["RANK_WATCH_WHISPERER_NONE"] = "Nessuno: Sussurra ai membri del gruppo è disattivato."

--[[
    Ability Alerts While Leveling: the panel for the level-up prints (LEVEL_UP_SPELLS and the rest), under
    Enhanced Spellbook. RANK_WATCH_LEVEL_UP_HEADER is its name in the settings tree, the page title and the
    mini-map menu; its switch is SWITCH_ABILITY_ALERTS, also in the root panel's Features section.
]]
L["RANK_WATCH_LEVEL_UP_HEADER"] = "Avvisi abilità durante il livellamento"
L["ABILITY_ALERTS_DESCRIPTION"] =
	"Quando sali di livello, la chat elenca le abilità che il tuo istruttore di classe ha per te, ognuna con la sua icona e un link su cui passare il mouse."
L["SWITCH_ABILITY_ALERTS"] = "Attiva gli avvisi abilità durante il livellamento"
L["SWITCH_ABILITY_ALERTS_DESCRIPTION"] =
	"Quando sali di livello, elenca in chat le abilità che il tuo istruttore di classe ha per te."
L["RANK_WATCH_LEVEL_UP_PAST"] = "Includi le abilità saltate"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] =
	"Aggiunge una riga per le abilità dei livelli precedenti che non hai ancora imparato."
L["RANK_WATCH_LEVEL_UP_PET"] = "Includi le abilità del famiglio"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] =
	"Aggiunge le abilità dell'addestratore di famigli per i cacciatori, o i grimori dell'addestratore di demoni per gli stregoni, che si sbloccano al tuo nuovo livello."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "Includi le abilità del famiglio saltate"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] =
	"Solo cacciatori: aggiunge una riga per le abilità dell'addestratore di famigli dei livelli precedenti che non hai ancora imparato. Gli stregoni non ricevono questa riga, perché il gioco non indica quali grimori un demone ha imparato finché non è evocato."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Giocatori ignorati"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "Il Controllo dei gradi non segnala mai questi giocatori."
L["RANK_WATCH_IGNORED_NONE"] = "Ancora nessuno."
L["RANK_WATCH_IGNORED_REMOVE"] = "Non ignorare più"
L["RANK_WATCH_IGNORE_TARGET"] = "Ignora bersaglio"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "Aggiunge alla lista il giocatore che hai selezionato."
L["RANK_WATCH_IGNORE_ADDED"] = "Il Controllo dei gradi ora ignora %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"Impossibile trovare %s. Forma un gruppo con questo giocatore o selezionalo, poi riprova."
-- %s is the command, /gtg ignore Name (RANK_WATCH_IGNORE_COMMAND), drawn in blue.
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Seleziona un giocatore, oppure digita %s."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Nome"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"Il Controllo dei gradi smette di segnalare quel giocatore. Senza nome, ignora il tuo bersaglio."

-- Reported Ranks, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"I gradi segnalati dal Controllo dei gradi, classe per classe. Togli la spunta a un grado che abbassi di proposito e il Controllo dei gradi lo lascerà stare. Ogni abilità è elencata. Quelle che il Controllo dei gradi non sorveglia per impostazione predefinita, come cure, talenti e Bruciatura di grado 1, partono senza spunta. Il grado più alto di un'abilità è in grigio, perché non c'è nulla sopra."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (livello %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "Segnala questo grado quando ne è disponibile uno più alto."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "Il grado più alto. Non c'è nulla sopra, quindi non viene mai segnalato."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "Famigli (%s)"
L["RANK_WATCH_TRACK_ALL"] = "Spunta tutto"
L["RANK_WATCH_TRACK_ALL_DESCRIPTION"] = "Segnala ogni grado sotto il più alto in questa pagina."
-- Asked before Check All or Uncheck All goes through; %s is the page's class, or its pets ("Hunter Pets").
L["RANK_WATCH_TRACK_ALL_CONFIRM"] = "Segnalare ogni grado sotto il più alto nella pagina %s?"
L["RANK_WATCH_UNTRACK_ALL_CONFIRM"] = "Smettere di segnalare tutti i gradi nella pagina %s?"
L["RANK_WATCH_TRACK_NONE"] = "Togli tutte le spunte"
L["RANK_WATCH_TRACK_NONE_DESCRIPTION"] = "Smette di segnalare tutti i gradi di questa pagina."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Esiste già una lista chiamata "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "L'ID %d non esiste."
L["RESTOCKER_DISABLED"] = "Il Restocker è disattivato. Attivalo in Opzioni > AddOn > Good to Go > Restocker."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = 'Nessuna lista di rifornimento chiamata "%s".'
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Rifornimento completato. Tieni premuto Maiusc mentre apri la banca per saltare il rifornimento. Digita %s per modificare la tua lista di rifornimento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Rifornimento interrotto. Le tue borse e la tua banca sono piene."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Rifornimento interrotto. La tua banca è piena; libera uno spazio e riaprila."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Rifornimento interrotto. Le tue borse sono piene; libera uno spazio e riapri la banca."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Rifornimento interrotto. Nessun progresso possibile."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Rifornimento interrotto. Impossibile spostare: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (in eccesso)"
L["RESTOCKER_STOPPED_ERROR"] = "Rifornimento interrotto a causa di un errore: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Questo mercante non vende tutti gli ingredienti necessari ai tuoi veleni. Non ne verrà comprato nessuno."
-- Printed on reaching an inn or a city while something on the Restock List is low or out. %s is the counts sentence (RESTOCKER_LOW_ONE and the rest, below).
L["RESTOCKER_TOWN_REMINDER"] = "Ricorda di fare rifornimento mentre sei in città! %s"

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
L["RESTOCKER_SHORT_BUY"] = "Mancano %d oggetti, %d da comprare."
L["RESTOCKER_SHORT_ONE_BUY"] = "Manca 1 oggetto, 1 da comprare."
L["RESTOCKER_SHORT_NONE_TO_BUY"] = "Mancano %d oggetti. Prendili dalla banca."
L["RESTOCKER_SHORT_ONE_NONE_TO_BUY"] = "Manca 1 oggetto. Prendilo dalla banca."
L["RESTOCKER_SHORT_ITEMS_TITLE"] = "Oggetti mancanti"

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
L["RESTOCKER_LOW_ONE"] = "Ti resta poco di 1 oggetto."
L["RESTOCKER_LOW_MANY"] = "Ti resta poco di %d oggetti."
L["RESTOCKER_OUT_ONE"] = "Hai finito 1 oggetto."
L["RESTOCKER_OUT_MANY"] = "Hai finito %d oggetti."
L["RESTOCKER_OUT_AND_LOW_ONE"] = "Hai finito 1 oggetto, e ti resta poco di %d."
L["RESTOCKER_OUT_AND_LOW_MANY"] = "Hai finito %d oggetti, e ti resta poco di %d."
L["RESTOCKER_STILL_LOW_ONE"] = "Ti resta ancora poco di 1 oggetto."
L["RESTOCKER_STILL_LOW_MANY"] = "Ti resta ancora poco di %d oggetti."
L["RESTOCKER_STILL_OUT_ONE"] = "Ti manca ancora del tutto 1 oggetto."
L["RESTOCKER_STILL_OUT_MANY"] = "Ti mancano ancora del tutto %d oggetti."
L["RESTOCKER_STILL_OUT_AND_LOW_ONE"] = "Ti manca ancora del tutto 1 oggetto, e ti resta poco di %d."
L["RESTOCKER_STILL_OUT_AND_LOW_MANY"] = "Ti mancano ancora del tutto %d oggetti, e ti resta poco di %d."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "La tua lista di rifornimento è stata migliorata."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d diventa %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 ordine di rifornimento evaso."
L["RESTOCKER_RESTOCKED_MANY"] = "%d ordini di rifornimento evasi."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 ordine di rifornimento evaso in parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d ordini di rifornimento evasi in parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Le tue borse si sono riempite prima che fosse comprato tutto."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "Oro insufficiente per completare il rifornimento."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing was bought at this merchant; the second sentence says where
    the reserve is changed, by the options panel's own path.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Hai meno di %s, la riserva d'oro che hai messo da parte, quindi non è stato comprato nulla. Modificala in Opzioni > AddOn > Good to Go > Restocker."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nome]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Aggiunge una lista con quel nome."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con quel nome."
-- Printed for a /restock word the command doesn't know, before the command list. The first %s is the word typed, the second /restock help, drawn in blue.
L["RESTOCKER_SLASH_UNKNOWN"] = 'Comando Restocker sconosciuto: "%s". Digita %s per l\'elenco.'
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Rinomina la lista attuale con quel nome."
L["RESTOCKER_HELP_PROFILE_COPY"] =
	"Sostituisce la lista attuale con una copia della lista con quel nome, dopo averti chiesto conferma."
--[[
    TRANSLATORS: /restock profile copy's confirm. The first %s is the list in
    use, which is replaced, the second the list copied, both in gold.
    ALSO_USED_BY follows it when another character uses the list in use: the
    first %s is the list, the second their names, joined like the window's
    Used By line. REPLACE is the confirm's button.
]]
L["RESTOCKER_PROFILE_COPY_CONFIRM"] =
	"Sostituire tutto il contenuto di %s con una copia di %s? L'operazione non può essere annullata."
L["RESTOCKER_PROFILE_COPY_CONFIRM_ALSO_USED_BY"] = "%s è usata anche da %s."
L["RESTOCKER_REPLACE"] = "Sostituisci"
L["RESTOCKER_HELP_PROFILE_USE"] = "Assegna a questo personaggio la lista con quel nome."

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
L["STARTER_POPUP_TITLE"] = "Beni essenziali"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Fatto"
-- Gray, in the Staples window's body when no staple fits this character yet.
L["STARTER_NOTHING_TO_OFFER"] = "Ancora niente da aggiungere per la tua classe e il tuo livello."
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Abbiamo aggiunto alcuni beni essenziali della tua classe alla tua lista di rifornimento. Togli la spunta a quelli che non vuoi."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"La tua lista di rifornimento è vuota, quindi aggiungiamo qualche oggetto per iniziare."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Scegli i beni essenziali che vuoi tenere di scorta."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tutto ciò che spunti viene rifornito automaticamente ogni volta che apri un mercante o la tua banca. La maggior parte dei beni essenziali migliora da sola man mano che sali di livello, così avrai sempre il meglio disponibile."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Puoi sempre modificare questa lista, o aggiungere altri oggetti in seguito, digitando %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Cibo e acqua"
L["STARTER_POPUP_FOOD_HEADER"] = "Cibo"
L["STARTER_POPUP_AMMO_HEADER"] = "Munizioni"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Proiettili"
L["STARTER_POPUP_ARROWS"] = "Frecce"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenti e strumenti"
L["STARTER_POPUP_POISONS_HEADER"] = "Veleni"
-- %s is the client's name for the Rogue class, rogue-colored, and the colon follows it directly.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s: aggiungi il veleno finito alla tua lista e Good to Go comprerà automaticamente gli ingredienti da qualsiasi mercante che li venda tutti."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse e migliorandoli man mano che sali di livello."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pila"
L["STARTER_POPUP_STACK_MANY"] = "%d pile"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Quante pile tenere di scorta, dove una pila equivale a %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Quanti tenerne di scorta, ognuno in uno spazio a sé nelle borse, perché non si impilano."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Lista di rifornimento"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtra oggetti..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Cancella"
L["RESTOCKER_ADD_BUTTON"] = "Aggiungi"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Scegli beni essenziali"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Scegli tra i beni essenziali per la tua classe e il tuo livello: cibo, acqua, munizioni, veleni e reagenti. Spuntarne uno lo aggiunge a questa lista e togliere la spunta lo rimuove."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Aggiungi un oggetto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Trascina un oggetto dalle tue borse qui o in qualsiasi punto di questa finestra, oppure digita un ID oggetto e premi Invio."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Trascina o digita l'ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Digita invece un ID."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Già in questa lista."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Aggiungi oggetto dalle borse"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Ogni oggetto nelle tue borse che non è ancora in questa lista, pronto da aggiungere."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nulla da aggiungere dalle tue borse"

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
L["RESTOCKER_PROFILE_LABEL"] = "Lista"
L["RESTOCKER_PROFILE_TOOLTIP"] = "Assegna a questo personaggio un'altra lista di rifornimento, o ne inizia una nuova."
L["RESTOCKER_USED_BY"] = "Usata da %s"
L["RESTOCKER_MANAGE"] = "Gestisci liste"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Inizia una nuova lista, oppure copia, rinomina o elimina questa."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nuova lista"
L["RESTOCKER_MANAGE_COPY"] = "Copia questa lista in una nuova"
L["RESTOCKER_RENAME_PROFILE"] = "Rinomina questa lista"
L["RESTOCKER_MANAGE_DELETE"] = "Elimina questa lista"
-- TRANSLATORS: gray on Delete This List's right, how many characters use the list ("Used by 2").
L["RESTOCKER_LIST_USED_BY_COUNT"] = "Usata da %d"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Copia"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Rinomina"
L["RESTOCKER_RENAME_TOOLTIP"] = "Rinomina questa lista per tutti i personaggi che la usano."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Vuoi davvero eliminare questa lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "Anche %s la usa e, all'accesso, troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"Anche %s la usano e, all'accesso, ognuno troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Passerai alla lista %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "È l'unica lista rimasta, quindi ripartirai da una nuova lista vuota."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Questa azione non può essere annullata."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Migliora salendo di livello"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permette a Good to Go di migliorare cibo, acqua, munizioni, veleni, pozioni e reagenti di classe, passando a oggetti migliori man mano che sali di livello."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Migliora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Oggetto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Preleva"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Deposita"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Tieni"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens; SHOWN, gray on their right, is how many of the items shown
    the column can be set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "L'intestazione imposta questa opzione per tutti gli oggetti mostrati."
L["RESTOCKER_BULK_ON"] = "Attiva"
L["RESTOCKER_BULK_OFF"] = "Disattiva"
L["RESTOCKER_BULK_SHOWN"] = "%d mostrati"

L["RESTOCKER_GROUP_OTHER"] = "Altro"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuovi"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Tutti gli oggetti"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Questa lista è ancora vuota"
L["RESTOCKER_EMPTY_BODY"] =
	"Scegli beni essenziali come cibo, acqua o reagenti di classe, oppure aggiungi qualsiasi cosa dalle tue borse con il menu qui sopra. Gli oggetti in questa lista vengono tenuti di scorta o depositati in banca automaticamente, così le tue borse restano in ordine."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Puoi anche aggiungere un oggetto trascinandolo ovunque in questa finestra."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nessun oggetto in questa lista corrisponde al tuo filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "Non è rimasto nulla in questa categoria."

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
L["RESTOCKER_REMOVED_ITEM"] = "Hai rimosso %s."
L["RESTOCKER_UNDO"] = "Annulla"
L["RESTOCKER_UNDO_TOOLTIP"] = "Rimetti questo oggetto nella lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Rimuovi questo oggetto dalla lista di rifornimento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puoi annullare dalla sua riga finché la lista non cambia."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Tieni nelle borse"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'Quanti tenerne nelle borse. Il numero diventa giallo finché le tue borse ne contengono di meno, e 0 con "Deposita" attivo manda tutto in banca.'
L["RESTOCKER_BUY_LABEL"] = "Compra"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Compra dal mercante"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra dal mercante la quantità necessaria quando la finestra del mercante è aperta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Compra extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra da un mercante tutta la scorta limitata di questo oggetto, cioè la merce che vende pochi pezzi alla volta e rifornisce lentamente, anche oltre il numero della colonna Tieni."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Deposita in banca"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Deposita in banca gli oggetti in eccesso quando la banca è aperta, oppure tutti se nella colonna Tieni imposti 0."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Preleva dalla banca"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Preleva dalla banca gli oggetti necessari quando la banca è aperta."

-- Required-reputation control (per-item vendor gate).
--[[
    A standing's discount, gray on its row's right in the standings menu. The
    standings are the client's own labels (FACTION_STANDING_LABEL5 to 8), so
    only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT"] = "%d%% di sconto"
L["RESTOCKER_REPUTATION_ANY"] = "Qualsiasi"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputazione richiesta con il mercante"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Imposta la reputazione che un mercante richiede prima che Good to Go compri da lui, il che riduce anche il prezzo: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Con un trattino compra da qualsiasi mercante."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi non c\'è nulla di extra da comprare.'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi la reputazione non si applica.'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Questo oggetto non ha una versione migliore a cui passare."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go ha disattivato %s, che sostituisce. Vuoi ricaricare ora, così la vecchia copia smette di funzionare?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Ricarica ora"
L["POPUP_REPLACED_LATER"] = "Più tardi"
-- The Spellbook's confirm buttons, each naming what it does; the other button is the client's Cancel.
L["POPUP_DELETE"] = "Elimina"
L["POPUP_RESET"] = "Ripristina"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Impostazioni di %s copiate."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go ha copiato le tue impostazioni da %s e ha disattivato %s, che sostituisce. Vuoi ricaricare ora, così la vecchia copia smette di funzionare?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go ha trovato %s installato ma disattivato. Vuoi importare le impostazioni? Questo riattiva i vecchi add-on e ricarica l'interfaccia, poi propone un altro ricaricamento per disattivarli di nuovo."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go ha trovato %s installato ma disattivato. Vuoi importare le impostazioni e le liste di rifornimento? Questo riattiva i vecchi add-on e ricarica l'interfaccia, poi propone un altro ricaricamento per disattivarli di nuovo."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Importale"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "No, grazie"

--------------------------------------------------------------------------------
-- Options: Group Buffs and Reported Ranks
--------------------------------------------------------------------------------

-- The Group Buffs and Reported Ranks panels' titles, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Potenziamenti di gruppo"
L["RANK_WATCH_TRACKED_HEADER"] = "Gradi segnalati"
L["TRACKED_ITEM_PENDING"] = "Oggetto #%d"
L["TRACKED_SPELL_PENDING"] = "Incantesimo #%d"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Turno dei potenziamenti"
L["BUFF_DUTY_DESCRIPTION"] =
	"Mostra a chi mancano i tuoi potenziamenti. Clicca su un'icona per lanciare il potenziamento."
L["BUFF_DUTY_ENABLE"] = "Attiva il turno dei potenziamenti"
L["BUFF_DUTY_NO_BUFFS"] =
	"La tua classe non ha potenziamenti in questa lista, quindi la finestra non compare mai con questo personaggio."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Quando mostrare"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Scegli quando la finestra può apparire."
L["BUFF_DUTY_WHEN_NONE"] = "Non è spuntato nulla, quindi la finestra non compare mai."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"Il turno dei potenziamenti è nascosto qui. Il gioco non permette agli add-on di vedere i potenziamenti in questa zona, quindi non può sapere a chi ne manca uno."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Imposta dove appare la finestra: ovunque, o solo in un'istanza, come una spedizione o un'incursione."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Ovunque"
L["BUFF_DUTY_WHERE_INSTANCE"] = "In istanza"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Mostra la finestra quando giochi queste classi."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Mostra la finestra quando giochi questa classe."
L["BUFF_DUTY_HEADER"] = "Finestra"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Tieni la finestra dove l'hai messa, o toglila di mezzo in combattimento."
L["BUFF_DUTY_LOCK"] = "Blocca la finestra"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "Impedisce di spostare la finestra. Quando è sbloccata, trascinala dallo sfondo."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Nascondi in combattimento"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Nasconde la finestra durante il combattimento. In combattimento la lista non può aggiornarsi, quindi una finestra lasciata visibile mantiene il suo ultimo stato fino alla fine del combattimento."
L["BUFF_DUTY_SHOW_HEADER"] = "Mostra nella finestra"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Aggiungi alla finestra i tuoi potenziamenti, gli sconosciuti che ti hanno potenziato e il tuo bersaglio."
-- Return the Favor, Your Target and Ask for Buffs each name both their switch and the window row it adds.
L["BUFF_DUTY_FAVOR_ENABLE"] = "Ricambia il favore"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Elenca gli sconosciuti che ti hanno potenziato di recente, con i potenziamenti che puoi restituire loro. Clic destro su un'icona per togliere qualcuno dalla lista."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Imposta per quanto tempo uno sconosciuto resta nella lista dopo il suo ultimo potenziamento."
L["BUFF_DUTY_TARGET_ENABLE"] = "Il tuo bersaglio"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Elenca il tuo bersaglio quando è un giocatore fuori dal tuo gruppo a cui manca un potenziamento che puoi lanciare."
L["BUFF_DUTY_TARGET_NPCS"] = "Includi PNG"
L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"] =
	"Elenca anche un PNG amico che hai come bersaglio, come il soldato ferito di una missione, con i potenziamenti che puoi lanciargli."
-- Under Your Target: an Ask row of the buffs of theirs you're missing, whispered for on a click or Cast Next Buff.
L["BUFF_DUTY_ASK_TARGET"] = "Chiedi potenziamenti al tuo bersaglio"
L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"] =
	"Quando il tuo bersaglio può darti un potenziamento che ti manca, lo mostra in una riga Chiedi sotto di lui. Cliccalo, o premi Lancia il prossimo potenziamento, per sussurrargli una richiesta gentile. A nessuno viene chiesto lo stesso potenziamento più di una volta ogni 5 minuti."
--[[
    The ask to your target's composer, under Ask Your Target for Buffs.
    TRANSLATORS: keep {name} and {spells} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {name} then {spells}, drawn in blue.
]]
L["BUFF_DUTY_ASK_TARGET_MESSAGE_DESCRIPTION"] =
	"Imposta cosa Good to Go sussurra al tuo bersaglio quando gli chiedi un potenziamento dalla riga Chiedi. {name} diventa il suo nome e {spells} i potenziamenti richiesti. Lascia vuoto per non inviare sussurri."
L["BUFF_DUTY_ASK_TARGET_TOKENS"] = "Segnaposto: %s il suo nome, %s i potenziamenti"
L["BUFF_DUTY_ASK_OTHERS"] = "Chiedi potenziamenti"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Aggiunge alla finestra una riga Chiedi potenziamenti: i potenziamenti d'incursione che mancano al tuo gruppo, con quanti giocatori ne hanno bisogno. Fai clic sinistro su uno per chiederlo al tuo gruppo, oppure clic destro per sussurrare ai giocatori che possono lanciarlo."
--[[
    The whispered ask's composer, under Ask for Buffs.
    TRANSLATORS: keep {names} and {spell} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {names} then {spell}, drawn in blue.
]]
L["BUFF_DUTY_ASK_MESSAGE_DESCRIPTION"] =
	"Imposta cosa sussurra Good to Go ai giocatori che possono lanciare un potenziamento mancante quando ci fai clic destro sotto Chiedi potenziamenti. {names} diventa i giocatori a cui manca, o quanti sono, e {spell} il potenziamento. Lascialo vuoto per non inviare alcun sussurro."
L["BUFF_DUTY_ASK_TOKENS"] = "Segnaposto: %s i giocatori a cui manca, o quanti sono, %s il potenziamento"
-- Group Buffs page: the Refresh section around Refresh Under.
L["BUFF_DUTY_REFRESH_HEADER"] = "Rinnovo"
L["BUFF_DUTY_REFRESH_SUMMARY"] = "Riproponi un potenziamento prima che svanisca."
L["BUFF_DUTY_REFRESH"] = "Rinnova sotto"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Imposta sotto quale tempo residuo un potenziamento viene considerato mancante, così puoi rinnovarlo prima che svanisca. Un potenziamento che non dura più di questo tempo conta solo quando è svanito."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Considera come difensori"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Chi riceve i potenziamenti che offri ai Difensori, come Spine, quando non ha un ruolo proprio."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Imposta quando i giocatori di questa classe contano come difensori. Un ruolo da difensore o guaritore che abbiano ha sempre la precedenza."
L["BUFF_DUTY_TANKS_PETS"] = "Famigli"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Imposta quando i famigli contano come difensori. I famigli ricevono anche i potenziamenti che offri a Tutti."
L["BUFF_DUTY_TANKS_NEVER"] = "Mai"
L["BUFF_DUTY_TANKS_SOLO"] = "Da solo"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Sempre"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Disattivato"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Difensori"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Guaritori"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Tutti"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Imposta a chi offrire %s."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Scegli a chi offrire ogni potenziamento. Difensori e Guaritori si basano sul ruolo nel gruppo, ma in incursione contano come difensori solo i giocatori designati come %s. Chi non ha un ruolo conta come Assaltatore, a meno che Considera come difensori qui sotto non indichi altrimenti."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Potenziamenti personali"
L["BUFF_DUTY_SELF_DESCRIPTION"] =
	"Ogni potenziamento che puoi lanciare su te stesso, fissato in cima alla finestra. Ci sono anche i tuoi potenziamenti di gruppo, per quando li hai tu: in Potenziamenti di gruppo scegli chi altro li riceve."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "vale un aspetto qualsiasi"
L["BUFF_DUTY_SELF_NOTE_BLESSING"] = "vale una qualsiasi delle tue benedizioni"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "vale un'armatura qualsiasi"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "vale un'aura qualsiasi"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "vale uno scudo qualsiasi"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "vale un'armatura qualsiasi"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "vale uno qualsiasi dei due potenziamenti demoniaci"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Disattivato"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Se manca"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Meno di %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Imposta quando compare %s: mai, quando l'effetto è finito, o quando ne resta meno di questo tempo."
-- The Self-Buffs panel's last box: consumables any class keeps up on itself (Winterfall Firewater), with a muted note after its name.
L["BUFF_DUTY_SELF_ITEMS_HEADER"] = "Consumabili"
L["BUFF_DUTY_SELF_ITEMS_NOTE"] = "se ne hai uno nelle borse"
--[[
    Hover text on the Consumables box's Well Fed row, whose buff food is
    whichever the Food macro would eat. %s is the client's name for Well Fed.
]]
L["BUFF_DUTY_WELL_FED_DESCRIPTION_FORMAT"] =
	'Compare mentre ti manca "%s" e hai con te cibo potenziante. Cliccalo nella finestra per mangiare il migliore.'
-- The Consumables box's Scrolls row: one icon per scroll buff you're missing, for the types checked under it.
L["BUFF_DUTY_SCROLLS"] = "Pergamene"
L["BUFF_DUTY_SCROLLS_DESCRIPTION"] =
	"Mostra una pergamena per ogni potenziamento delle pergamene che ti manca, finché hai con te quella pergamena. Cliccane una nella finestra per leggerla. I tipi di pergamena controllati sono quelli spuntati qui sotto."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Potenziamenti delle armi"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Spunta cosa deve avere ogni arma. La finestra lo propone quando manca o sta per scadere, se è nelle tue borse ed è adatto all'arma."
-- The one timing for every weapon buff, at the top of the panel, captioned Refresh Under (BUFF_DUTY_REFRESH).
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Imposta quando un potenziamento dell'arma viene proposto di nuovo: quando l'effetto è finito, o quando ne resta meno di questo tempo."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Oli"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Pietre"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Esche"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Offre %s per la tua arma (%s). Finché l'arma non ha nessuna delle scelte spuntate, viene offerta ognuna di quelle che possiedi."
L["BUFF_DUTY_SELF_ENABLE"] = "I tuoi potenziamenti personali"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Mostra in cima alla finestra i tuoi potenziamenti quando mancano o stanno per scadere: quelli che solo tu puoi lanciare su te stesso, come un'armatura o Fuoco Interiore, e i tuoi potenziamenti di gruppo su di te. Scegli quali in Potenziamenti personali."
L["BUFF_DUTY_WEAPON_ENABLE"] = "I tuoi potenziamenti delle armi"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Mostra i veleni, le infusioni, gli oli, le pietre e le esche che mancano alle tue armi o stanno per scadere, insieme ai tuoi potenziamenti personali in cima alla finestra. Cliccane uno per applicarlo. Scegli quali in Potenziamenti delle armi."

-- The window itself
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Lo lancia su %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Lo applica alla tua arma (%s)."
L["BUFF_DUTY_TOOLTIP_USE"] = "Nessuno nel tuo gruppo ha una Pietra dell'Anima. Ne usa una su %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Nessuno nel tuo gruppo ha una Pietra dell'Anima. Ne crea una."
-- A Firestone or Spellstone icon with none in the bags conjures one.
L["BUFF_DUTY_TOOLTIP_CREATE_WEAPON"] = "Nessuna nelle tue borse. Ne crea una."
-- A Self-Buffs consumable's icon (Winterfall Firewater).
L["BUFF_DUTY_TOOLTIP_USE_ITEM"] = "Ne usa uno dalle tue borse."
L["BUFF_DUTY_TOOLTIP_READ"] = "Ne legge una dalle tue borse."
--[[
    The Options line at the foot of the Buff Duty window, and the menu it opens: the window's switches, its
    consumables and weapon buffs. %s in the weapon row's hover is the poison, imbue, oil, stone or lure.
]]
L["BUFF_DUTY_MENU_OPTIONS"] = "Opzioni"
L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"] = "Offre %s nella finestra quando a un'arma manca il suo potenziamento."
L["BUFF_DUTY_MENU_ALL_SETTINGS"] = "Tutte le impostazioni del Turno dei potenziamenti"
L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"] =
	"Apre le impostazioni del Turno dei potenziamenti, con ogni tempistica, classe e potenziamento che la finestra può mostrare."
-- The Options menu's Window Opacity row, and its flyout of 0% to 100%. %d is the percent.
L["BUFF_DUTY_MENU_OPACITY"] = "Opacità della finestra"
L["BUFF_DUTY_MENU_OPACITY_DESCRIPTION"] =
	"Imposta quanto è opaco lo sfondo della finestra del Turno dei potenziamenti. Testo e icone restano invariati."
L["BUFF_DUTY_MENU_OPACITY_PERCENT"] = "%d%%"
-- The Options menu's Buff Food row, and its flyout of the buff food in your bags. In the food row's hover, the first %s is the food, the second the Well Fed buff's name.
L["BUFF_DUTY_MENU_BUFF_FOOD"] = "Cibo potenziante"
L["BUFF_DUTY_MENU_FOOD_DESCRIPTION_FORMAT"] =
	'Offre %s quando ti serve "%s". Disattivato, lo salta per il miglior cibo potenziante successivo nelle tue borse.'
L["BUFF_DUTY_MENU_NO_BUFF_FOOD"] = "Nessun cibo potenziante nelle tue borse."
-- The Self-Buffs buff food icon, while you aren't Well Fed.
L["BUFF_DUTY_TOOLTIP_EAT"] = "Ne mangia uno dalle tue borse. Resta seduto finché non sei Ben nutrito."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Lo lancia su %s e sul suo gruppo."
-- A raid group icon's tooltip, its last line: the members who need it (%s, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT).
L["BUFF_DUTY_TOOLTIP_NEEDS"] = "Ne hanno bisogno: %s."
-- A Return the Favor icon: the click targets them and casts; a right-click drops them from the list.
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Seleziona %s come bersaglio e lancia. Clic destro per toglierlo da questa lista."
-- The Ask row under Target: its label (%s is the target's name in their class color), and its icons' tooltip: who the whisper goes to, or, once asked, who and the whole minutes until they can be asked again.
L["BUFF_DUTY_ASK_TARGET_ROW"] = "Chiedi a %s"
L["BUFF_DUTY_TOOLTIP_ASK_TARGET"] = "Sussurra a %s per chiederlo."
L["BUFF_DUTY_TOOLTIP_ASKED"] = "Chiesto a %s. Puoi chiedere di nuovo tra %d min."
-- An Ask for Buffs icon's menu, its ask rows: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it: %s is one or two names (LIST_PAIR_FORMAT), or BUFF_DUTY_OTHERS_ASK_PEOPLE past two.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "Chiedi il potenziamento (%s)"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "Sussurra a %s"
-- An Ask for Buffs menu's name row, on the right: the whole minutes left on that player's buff, or Missing once there is none.
L["BUFF_DUTY_OTHERS_MINUTES"] = "%d min"
L["BUFF_DUTY_OTHERS_MISSING"] = "Mancante"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "A %s manca %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "A %s manca %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "A %d giocatori manca il potenziamento %s."
-- The whispered ask's {names} past five missing players, when the player has written their own whisper, and the Ask for Buffs menu's whisper row past two players. %d is how many.
L["BUFF_DUTY_OTHERS_ASK_PEOPLE"] = "%d giocatori"
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"Il turno dei potenziamenti è nascosto finché non entri in un gruppo, fino al prossimo accesso o ricaricamento. Per riaverlo subito, fai clic sinistro sul pulsante della minimappa. Per tenerlo disattivato per la classe %s, togli la spunta da %s alla voce %s in %s."

-- The Cast Next Buff key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Lancia il prossimo potenziamento"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "In attesa che %s sia a portata."
L["BUFF_KEY_DONE"] = "Niente più da potenziare."
L["BUFF_KEY_OFF"] = "Il turno dei potenziamenti è disattivato."
--[[
    The Buff Duty window's last line, under Options, while the Cast Next Buff key has none: the options
    command (OPTIONS_COMMAND), then the key's name (BUFF_KEY). Kept to about three lines at the window's
    narrowest, with the command near the start so a line never breaks inside it.
]]
L["BUFF_DUTY_KEY_TIP"] = "In %s, assegna un tasto a %s per lanciare questi potenziamenti con un solo tasto."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Non appresi"
L["SECTION_CONSUMABLES"] = "Macro dei consumabili"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Testo della macro"
L["MENU_GROUP_MACRO_STORAGE"] = "Archiviazione macro"
L["MENU_MACRO_TAB_CHARACTER"] = "Personaggio"
L["MENU_MACRO_TAB_CHARACTER_DESCRIPTION"] =
	"Tiene questa macro tra le macro del tuo personaggio, che vede solo questo personaggio. Usa Generali finché quegli spazi sono pieni."
L["MENU_MACRO_TAB_GENERAL"] = "Generali"
L["MENU_MACRO_TAB_GENERAL_DESCRIPTION"] =
	"Tiene questa macro tra le macro generali condivise da tutto l'account, risparmiando gli spazi del personaggio. Usa quelle del personaggio finché Generali è pieno."
L["MENU_MACRO_TAB_NOTE"] = "Sposta subito la macro e la lascia sulle tue barre delle azioni."
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Grado dinamico"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Il grado dinamico, basato sul livello di un giocatore amico, si aggiorna solo fuori dal combattimento."
L["MENU_CAST_AT_CURSOR"] = "Lancia sul cursore"
L["MENU_TARGET_NEAREST_ENEMY"] = "Seleziona il nemico più vicino"
L["MENU_TARGET_NEAREST_FRIEND"] = "Seleziona l'alleato più vicino"
L["MENU_CAST_IF_SUMMONED"] = "Lancia %s se evocato"
L["MENU_NEVER_TURN_OFF"] = "Non disattivare mai"
L["MENU_LEAVE_FORM_BEFORE"] = "Esci dalla forma prima del lancio"
L["MENU_RIGHT_CLICK_FOR"] = "Clic destro per %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Clic destro per la versione di gruppo"
-- TRANSLATORS: the category menu's title and its gear's tooltip; %d is how many spells it lists, %s its name ("All 6 Heals").
L["MENU_CATEGORY_TITLE"] = "%2$s (%1$d)"
L["MENU_ONCE_PER_COMBAT"] = "Lancia una volta per combattimento"
L["MENU_ONCE_PER_TARGET"] = "Lancia una volta per bersaglio"
L["MENU_HIDE_ERRORS"] = "Nascondi errori"
L["MENU_MUTE_ERRORS"] = "Silenzia errori"
L["MENU_SWITCH_TO"] = "Passa a %s"
L["MENU_START_AUTO_ATTACK"] = "Avvia l'attacco automatico"
L["MENU_STOP_ATTACK"] = "Ferma l'attacco"
L["MENU_START_AUTO_SHOT"] = "Avvia il tiro automatico"
L["MENU_START_PET_ATTACK"] = "Avvia l'attacco del famiglio"
L["MENU_START_WAND"] = "Avvia la bacchetta"
L["MENU_STOP_CASTING"] = "Interrompi il lancio"
L["MENU_STOP_CASTING_NOTE"] =
	"Usa Interrompi il lancio per gli incantesimi che non possono aspettare, come interruzioni e dissoluzioni."
L["MENU_STOP_IF_CHANNELING"] = "Non mentre canalizzi"
L["MENU_STOP_IF_STEALTHED"] = "Non mentre sei furtivo"
L["MENU_DUPLICATE"] = "Duplica"
L["MENU_DELETE"] = "Elimina"
L["MENU_DELETE_USED_ONE"] = "Usata su 1 barra"
L["MENU_DELETE_USED"] = "Usata su %d barre"
L["MENU_DELETE_DESCRIPTION"] =
	"Elimina questa macro, il che la toglie dalle barre delle azioni, e ne ripristina tutte le opzioni. Cliccala o trascinala nella pagina per crearla di nuovo."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Toglie questa copia dalla pagina e la elimina dalle tue macro, il che la toglie dalle barre delle azioni."
L["MENU_DELETE_CONFIRM"] = "Eliminare %s? Verrà tolta dalle barre delle azioni e le sue opzioni verranno ripristinate."
-- The same ask for a macro on none of your bars.
L["MENU_DELETE_CONFIRM_UNUSED"] = "Eliminare %s? Le sue opzioni verranno ripristinate."
L["MENU_GROUP_RANK"] = "Grado"
L["MENU_GROUP_WHEN"] = "Quando"
L["MENU_GROUP_FIRST"] = "Prima"
L["MENU_GROUP_THEN"] = "Poi"
L["MENU_GROUP_ERRORS"] = "Messaggi di errore"
L["MENU_GROUP_GROUPED"] = "Incantesimi raggruppati"
L["MENU_GROUP_TARGET"] = "Bersaglio"
L["MENU_PRIORITY_1"] = "Prima priorità"
L["MENU_PRIORITY_2"] = "Seconda priorità"
L["MENU_PRIORITY_3"] = "Terza priorità"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Chi la macro prova, uno dopo l'altro. Ognuno viene saltato quando non può ricevere l'incantesimo e, se nessuno può, la macro lancia come farebbe l'incantesimo normale."
L["MENU_UNIT_NONE"] = "Nessuno"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Termina l'elenco qui."
L["MENU_UNIT_TARGET"] = "Bersaglio"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Lancia sul tuo bersaglio, se può ricevere l'incantesimo."
L["MENU_UNIT_SELF"] = "Te stesso"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"Lancia su di te. Puoi sempre riceverlo, quindi nulla dopo Te stesso viene mai provato."
L["MENU_UNIT_PET"] = "Famiglio"
L["MENU_UNIT_PET_DESCRIPTION"] = "Lancia sul tuo famiglio, se è evocato e può ricevere l'incantesimo."
L["MENU_UNIT_FOCUS"] = "Focus"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "Lancia sul tuo focus, se ne hai uno e può ricevere l'incantesimo."
L["MENU_UNIT_TARGETS_TARGET"] = "Bersaglio del bersaglio"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Lancia sul bersaglio del tuo bersaglio, come il difensore colpito dal nemico che hai selezionato, se può ricevere l'incantesimo."
L["MENU_UNIT_MOUSEOVER"] = "Sotto il mouse"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Lancia su chi si trova sotto il cursore, nel mondo o su un riquadro dell'unità, se può ricevere l'incantesimo."
L["MENU_OPTIONS_COUNT"] = "%d opzioni"
L["MENU_HIGHEST"] = "Grado massimo"
L["MENU_HIGHEST_DESCRIPTION"] = "Lancia il grado più alto che conosci."
L["MENU_FIXED_RANK_DESCRIPTION"] = "Lancia sempre %s, a qualsiasi livello."
L["MENU_ANY_TIME"] = "Sempre"
L["MENU_ANY_TIME_DESCRIPTION"] = "Lancia sia in combattimento sia fuori."
L["MENU_IN_COMBAT"] = "In combattimento"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Lancia solo in combattimento. Fuori dal combattimento la macro non fa nulla, oggetti compresi."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Lancia solo fuori dal combattimento. In combattimento la macro non fa nulla, oggetti compresi."
L["MENU_EVERY_PRESS"] = "A ogni pressione"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Lancia ogni volta che la premi."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "Il clic destro lancia %s. Il clic sinistro lancia comunque %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Permette alla macro di lanciare %s. Tra gli incantesimi spuntati qui, lancia l'ultimo che hai appreso, così migliora man mano che ti addestri."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] = "Non ancora appreso. Spuntalo ora e la macro lo userà appena lo apprendi."
L["MENU_PET_DESCRIPTION"] = "Finché %s è in campo, la macro lancia %s invece di ripetere l'evocazione."
L["MENU_STANCE_DESCRIPTION"] = "Passa prima a %s, se non è già attiva."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Lo usa prima del lancio. Gli oggetti vengono usati nell'ordine in cui li spunti e il numero dopo ciascuno ne indica la posizione."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Usa %s"
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Aggiunge alla pagina un'altra copia di questa macro, partendo da queste opzioni, così puoi configurarla in modo diverso."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Condizioni"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Apre il pannello Condizioni accanto alla finestra del Libro degli incantesimi avanzato, dove la macro può lanciare un incantesimo diverso quando una condizione è soddisfatta, come Maiusc premuto o Spec. 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "Una condizione usa il clic destro. Rimuovila per attivare questa opzione."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Condizioni"
L["CONDITIONALS_HINT"] = "Controllate dall'alto in basso; lancia la prima soddisfatta."
L["CONDITIONALS_OTHERWISE"] = "Altrimenti"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "e"
L["CONDITIONALS_AND_MENU"] = "Aggiungi seconda condizione"
L["CONDITIONALS_AND_DESCRIPTION"] =
	"Aggiunge una seconda condizione. La riga lancia solo quando entrambe sono soddisfatte."
L["CONDITIONALS_DROP_SECOND"] = "Rimuovi questa condizione"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "La riga torna a controllare solo la sua prima condizione."
L["CONDITIONALS_ADD"] = "+ Aggiungi condizione"
L["CONDITIONALS_ADD_DESCRIPTION"] =
	"Aggiunge una riga in fondo. Scegli la sua condizione, poi l'incantesimo da lanciare."
L["CONDITIONALS_ADD_LIMIT"] =
	"Fino a %d righe. Ognuna si aggiunge al testo della macro, che contiene al massimo 255 byte."
L["CONDITIONALS_PICK_SPELL"] = "Scegli un incantesimo"
L["CONDITIONALS_PICKING"] = "Clicca su un incantesimo nella pagina"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Clicca qui, poi clicca su un incantesimo nella pagina per lanciarlo in questa riga. Oppure trascina un incantesimo dalla pagina su questo spazio."
L["CONDITIONALS_PICK_BANNER"] = "Clicca su un incantesimo per usarlo. Esc o clic destro per annullare."
L["CONDITIONALS_CANNOT_PICK"] = "Solo un incantesimo appreso può essere lanciato da una condizione."
L["CONDITIONALS_EMPTY"] =
	"Ancora nessuna condizione. Aggiungine una per lanciare un altro incantesimo mentre tieni premuto Maiusc, in combattimento e altro ancora."
L["CONDITIONALS_SHADOWED"] =
	"Non lancia mai: la riga %d più in alto è soddisfatta ogni volta che lo è questa, e lancia per prima."
L["CONDITIONALS_KEY_DRAG"] = "Trascina qui un incantesimo"
L["CONDITIONALS_ACTION_DROP"] = "Lancialo in questa riga"
L["CONDITIONALS_ACTION_PICK"] = "Scegli dalla pagina"
L["CONDITIONALS_ACTION_USE"] = "Usa in una condizione"
L["CONDITIONALS_ACTION_CANCEL"] = "Annulla la scelta"
L["CONDITIONALS_REMOVE"] = "Rimuovi"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Rimuove questa riga."
L["CONDITIONALS_REORDER"] = "Riordina"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Trascina su un'altra riga per spostare lì questa. Lancia la prima riga soddisfatta."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Maiusc premuto"
L["CONDITION_SHIFT_SHORT"] = "Maiusc"
L["CONDITION_SHIFT_DESCRIPTION"] = "Soddisfatta quando tieni premuto Maiusc mentre premi la macro."
L["CONDITION_CTRL"] = "Ctrl premuto"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "Soddisfatta quando tieni premuto Ctrl mentre premi la macro."
L["CONDITION_ALT"] = "Alt premuto"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Soddisfatta quando tieni premuto Alt mentre premi la macro."
L["CONDITION_RIGHT_CLICK"] = "Clic destro"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "Soddisfatta quando fai clic destro sulla macro nella barra delle azioni."
L["CONDITION_IN_COMBAT"] = "In combattimento"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Soddisfatta mentre sei in combattimento."
L["CONDITION_OUT_OF_COMBAT"] = "Fuori dal combattimento"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Soddisfatta mentre sei fuori dal combattimento."
L["CONDITION_SPEC_1"] = "Spec. 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Soddisfatta mentre è attiva la tua prima specializzazione dei talenti."
L["CONDITION_SPEC_2"] = "Spec. 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Soddisfatta mentre è attiva la tua seconda specializzazione dei talenti."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (attuale)"
L["CONDITION_COMBAT_BLOCKED"] =
	"Non disponibile mentre Quando è impostato su In combattimento o Fuori dal combattimento. Nell'altro caso la macro già non fa nulla, quindi questa condizione sarebbe sempre soddisfatta, o mai."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"Non disponibile mentre in Incantesimi raggruppati è attivo Clic destro per %s, che usa già il clic destro. Disattivalo per usare qui il clic destro."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 condizione"
L["SUBTEXT_CONDITIONALS"] = "%d condizioni"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Sequenza di lancio"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Apre il pannello Sequenza di lancio accanto alla finestra del Libro degli incantesimi avanzato, dove ogni pressione della macro lancia l'incantesimo successivo in ordine, come Corruzione, poi Maledizione dell'Agonia, poi Immolazione."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d passi"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Sequenza di lancio"
L["CAST_SEQUENCE_HINT"] =
	"Ogni pressione lancia il passo successivo. Un passo che fallisce viene ritentato alla pressione seguente."
L["CAST_SEQUENCE_FIRST"] = "Primo"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "L'incantesimo della macro viene sempre per primo."
L["CAST_SEQUENCE_ADD"] = "+ Aggiungi passo"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Aggiunge un passo alla fine. Poi scegli l'incantesimo da lanciare."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Fino a %d passi dopo quello della macro. Ognuno si aggiunge al testo della macro, che contiene al massimo 255 byte."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"Solo un incantesimo appreso, e non Spara, può essere un passo di una sequenza di lancio."
L["CAST_SEQUENCE_ACTION_DROP"] = "Lancialo in questo passo"
L["CAST_SEQUENCE_ACTION_USE"] = "Usa nella sequenza di lancio"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Rimuove questo passo."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Trascina su un altro passo per spostare lì questo."
L["CAST_SEQUENCE_END"] = "Dopo l'ultimo passo"
L["CAST_SEQUENCE_END_LOOP"] = "Ricomincia"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"La pressione successiva lancia di nuovo l'incantesimo della macro e la sequenza ricomincia il giro."
L["CAST_SEQUENCE_END_STOP"] = "Ferma (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Termina su NULL, un incantesimo che nessuno conosce, quindi le pressioni successive non lanciano nulla finché un azzeramento non fa ricominciare la sequenza."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Ferma"
L["CAST_SEQUENCE_RESET"] = "Ricomincia quando"
L["CAST_SEQUENCE_RESET_NEVER"] = "Mai"
L["CAST_SEQUENCE_RESET_TARGET"] = "Cambia il bersaglio"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "Fa ricominciare la sequenza dal primo passo quando cambi bersaglio."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Finisce il combattimento"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] =
	"Fa ricominciare la sequenza dal primo passo quando esci dal combattimento."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Maiusc premuto"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl premuto"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt premuto"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Premere la macro tenendo premuto questo tasto fa ricominciare la sequenza, lanciando il primo passo."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Secondi di inattività"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Fa ricominciare la sequenza quando la macro non viene premuta per questo tempo."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Disattivato"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d secondi di inattività"
-- TRANSLATORS: the Seconds Idle row's value, the seconds it waits ("5 Seconds").
L["CAST_SEQUENCE_RESET_SECONDS_VALUE"] = "%d secondi"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"Si ferma per sempre: senza nulla che la faccia ricominciare, la sequenza resta su NULL finché la macro non cambia o non ricarichi l'interfaccia. Scegli un azzeramento in Ricomincia quando."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	"In attesa mentre Lancia se evocato lancia %s, che scrive una propria riga di lancio. Disattivalo per usare la sequenza."
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Clicca qui, poi clicca su un incantesimo nella pagina per lanciarlo in questo passo. Oppure trascina un incantesimo dalla pagina su questo spazio."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "Sequenza di %d passi"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Mostra tutti i gradi degli incantesimi"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Mostra gli incantesimi raggruppati"
L["SETTINGS_SHOW_UNLEARNED"] = "Mostra gli incantesimi non appresi"
L["SETTINGS_MARK_ALL_PLACED"] = "Segna tutti gli incantesimi come piazzati"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Nessuna macro di questa pagina si illumina più, che sia sulle tue barre o no. Un incantesimo che impari in seguito resta illuminato finché non lo piazzi. Evidenzia di nuovo gli incantesimi non piazzati, nel menu dell'ingranaggio, lo annulla."
L["SETTINGS_HIGHLIGHT_AGAIN"] = "Evidenzia di nuovo gli incantesimi non piazzati"
L["SETTINGS_HIGHLIGHT_AGAIN_DESCRIPTION"] =
	"Annulla Segna tutti gli incantesimi come piazzati, così ogni incantesimo che non è sulle tue barre torna a illuminarsi."
L["SORT_BY_CATEGORY"] = "Ordina per categoria"
L["SORT_BY_SCHOOL"] = "Ordina per scuola"
L["SORT_DESCRIPTION"] =
	"Raggruppa le macro della pagina per categoria, cioè lo scopo di ogni incantesimo, come Attacchi, Cure o Abilità difensive, oppure per scuola, cioè le schede del libro degli incantesimi da cui provengono."
L["CATEGORY_ATTACKS"] = "Attacchi"
L["CATEGORY_FINISHERS"] = "Mosse finali"
L["CATEGORY_CROWD_CONTROL"] = "Controllo dei nemici"
L["CATEGORY_HYBRID"] = "Ibridi"
L["CATEGORY_HEALS"] = "Cure"
L["CATEGORY_BUFFS"] = "Potenziamenti"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Abilità offensive"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Abilità difensive"
L["CATEGORY_SELF_BUFFS"] = "Potenziamenti personali"
L["CATEGORY_SHOCKS"] = "Shock"
L["CATEGORY_TRAPS"] = "Trappole"
L["CATEGORY_TOTEMS"] = "Totem"
L["CATEGORY_SEALS"] = "Sigilli"
L["CATEGORY_BLESSINGS"] = "Benedizioni"
L["CATEGORY_CURSES"] = "Maledizioni"
L["CATEGORY_PETS"] = "Famigli"
L["KIND_RESURRECT"] = "Resurrezioni"
L["CATEGORY_TELEPORTS"] = "Teletrasporti e portali"
L["CATEGORY_UTILITY"] = "Utilità"
L["CATEGORY_THREAT"] = "Provocazioni e minaccia"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Attacchi base"
L["CATEGORY_STANCES"] = "Posture"
L["CATEGORY_FORMS"] = "Forme"
L["CATEGORY_AURAS"] = "Aure"
L["CATEGORY_ASPECTS"] = "Aspetti"
L["CATEGORY_RACIALS"] = "Razziali"
L["CATEGORY_TRACKING"] = "Rilevamento"
L["CATEGORY_PROFESSIONS"] = "Professioni"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_PET"] = "Famiglio"
L["SUBTEXT_CURSOR"] = "Cursore"
L["SUBTEXT_STANCE"] = "Postura"
L["SUBTEXT_USE_ITEMS"] = "Usa oggetti"
L["SUBTEXT_PET_ATTACK"] = "Attacco famiglio"
L["SUBTEXT_DYNAMIC_RANK"] = "Grado din."
L["SUBTEXT_DYNAMIC_ITEM"] = "Oggetto din."
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Grado din., Oggetto din."
L["SUBTEXT_MAX_RANK"] = "Grado massimo"
L["SUBTEXT_TARGET_ENEMY"] = "Nemico vicino"
L["SUBTEXT_TARGET_FRIEND"] = "Alleato vicino"
L["SUBTEXT_TARGET_PRIORITY"] = "Bersaglio"
L["SUBTEXT_GROUPED_SPELLS"] = "Raggruppati"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1 per combatt."
L["SUBTEXT_ONCE_PER_TARGET"] = "1 per bersaglio"
L["SUBTEXT_COMBAT_ONLY"] = "Solo in combatt."
L["SUBTEXT_NO_COMBAT"] = "Fuori combatt."
L["SUBTEXT_LEAVE_FORM"] = "Esce da forma"
L["SUBTEXT_NO_TOGGLE"] = "Mai disattivare"
L["SUBTEXT_WAND"] = "Bacchetta"
L["SUBTEXT_START_ATTACK"] = "Attacco auto"
L["SUBTEXT_STOP_ATTACK"] = "Ferma attacco"
L["SUBTEXT_STOP_CASTING"] = "Interrompe"
L["SUBTEXT_STOP_IF_CHANNELING"] = "Non se canalizzi"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Non se furtivo"
L["SUBTEXT_HIDE_ERRORS"] = "Senza errori"
L["SUBTEXT_MUTE_ERRORS"] = "Errori muti"
L["SUBTEXT_OPTIONS_COUNT"] = "%d opzioni"
L["SUBTEXT_TOO_LONG"] = "Troppo lunga"
L["SUBTEXT_LEARN_LEVEL"] = "Livello %d"
L["SUBTEXT_TALENT"] = "Talento"
L["SUBTEXT_LEARN_RANK"] = "Impara %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Insegna al famiglio"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Non ancora appreso"
L["TOOLTIP_LEARN_LEVEL"] = "Il tuo istruttore di classe lo insegna al livello %d."
L["TOOLTIP_LEARN_TALENT"] = "Si impara dai tuoi talenti."
L["TOOLTIP_NOT_ON_BARS"] = "Non è sulle tue barre delle azioni"
L["TOOLTIP_TOO_LONG"] = "Troppo lunga: %d / %d byte. Disattiva un'opzione per accorciarla."
L["TOOLTIP_OPTIONS_ON"] = "Opzioni attive: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clic o trascina"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Piazza sulle tue barre delle azioni"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clic destro"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Opzioni della macro"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Clic centrale"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Ripristina le opzioni della macro"
-- TRANSLATORS: the category menu's last action; %d and %s as in MENU_CATEGORY_TITLE ("Reset All 6 Heals").
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Ripristina %2$s (%1$d)"
L["CHAT_MACRO_OPTIONS_RESET"] = "La macro %s è tornata alle opzioni predefinite."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Ogni macro in %s è tornata alle opzioni predefinite."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Elimina le opzioni che hai impostato su ogni incantesimo qui, così ognuno torna a seguire le sue impostazioni predefinite. Le copie per il focus e i duplicati restano."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Ripristinare le opzioni che hai impostato su ogni incantesimo in %s? Ognuno tornerà a seguire le sue impostazioni predefinite."
-- A middle-click on a macro, asked first. %s is the macro.
L["MENU_RESET_MACRO_CONFIRM"] = "Ripristinare le opzioni di %s? Tornerà a seguire le sue impostazioni predefinite."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "Macro %s"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Gli incantesimi della tua classe come macro a un clic."
-- The click line beneath it reuses MENU_OPEN_SPELLBOOK.
L["TOOLTIP_KEY_CLICK"] = "Clic"
-- What's Next rows' click lines: a spell row turns the Enhanced Spellbook to its tile, a pet ability row opens the Pet Spellbook tab.
L["WHATS_NEXT_CLICK_SPELL"] = "Mostra nel Libro degli incantesimi avanzato"
L["WHATS_NEXT_CLICK_PET"] = "Mostra nel Libro del famiglio"

-- Page: Layout
L["PAGE_EMPTY"] = "Ancora nessuna macro. Visita il tuo istruttore di classe per imparare i tuoi primi incantesimi."
L["PAGE_NO_MATCHES"] = "Nessuna macro corrisponde al filtro. Svuota la casella del filtro per vederle tutte."
L["PAGE_FILTER"] = "Filtra incantesimi"
L["FILTER_ALL_SCHOOLS"] = "Tutte le scuole"
L["FILTER_ALL_CATEGORIES"] = "Tutte le categorie"
L["PAGE_MACRO_SLOTS"] = "Spazi per le macro"
L["TOOLTIP_MACRO_SLOTS"] =
	"Ogni macro che piazzi occupa uno spazio per le macro. Gli spazi del personaggio appartengono a questo personaggio e si riempiono per primi. Gli spazi generali sono condivisi da tutti i personaggi del tuo account."
L["PAGE_MACRO_GENERAL"] = "Generali"
L["PAGE_MACRO_CHARACTER"] = "Personaggio"
L["PAGE_NO_MATCHES_FOR"] = 'Nessun incantesimo corrisponde a "%s".'
-- A category gear's tooltip and menu title for a category of one spell; more take MENU_CATEGORY_TITLE.
L["PAGE_CATEGORY_SETTINGS_ONE"] = "Opzioni per questo incantesimo"
-- The body of the page's Settings gear tooltip, under its title SETTINGS.
L["TOOLTIP_PAGE_SETTINGS_DESCRIPTION"] = "Scegli quali incantesimi mostra la pagina."
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Attiva o disattiva un'opzione per tutti gli incantesimi di questa categoria in una volta. Gli incantesimi non ancora sulle tue barre mantengono l'impostazione per quando li piazzerai."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(continua)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Cosa c'è dopo?"
L["WHATS_NEXT_EMPTY"] = "Nessun incantesimo da elencare."
-- The same page while Show Known Spells is off: %s is that toggle's name (WHATS_NEXT_SHOW_KNOWN).
L["WHATS_NEXT_EMPTY_KNOWN_HIDDEN"] =
	"Al momento non c'è niente di nuovo da imparare. Spunta %s nel menu dell'ingranaggio per vedere cosa hai imparato."
L["WHATS_NEXT_ALL_SOURCES"] = "Tutte le fonti"
L["WHATS_NEXT_ANY_LEVEL"] = "Qualsiasi livello"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LIST_PAIR_FORMAT or LIST_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), and [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "Ora puoi imparare %s."
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "Non dimenticare: puoi anche imparare %s."
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "Il tuo famiglio ora può imparare %s."
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "Non dimenticare: il tuo famiglio può anche imparare %s."
L["LEVEL_UP_DEMON_SPELLS"] = "I tuoi demoni ora possono imparare %s."

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Disponibili ora"
L["WHATS_NEXT_STATUS_SOON"] = "In arrivo"
L["WHATS_NEXT_STATUS_LATER"] = "Non ancora disponibili"
L["WHATS_NEXT_STATUS_MISSING"] = "Serve un altro incantesimo"
L["WHATS_NEXT_STATUS_TALENT"] = "Talenti non presi"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Talenti e rune non presi"
L["WHATS_NEXT_STATUS_KNOWN"] = "Conosciuti"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Disponibile ora"
L["WHATS_NEXT_SHORT_SOON"] = "In arrivo"
L["WHATS_NEXT_SHORT_LATER"] = "Non ancora"
L["WHATS_NEXT_SHORT_MISSING"] = "Serve un altro incantesimo"
L["WHATS_NEXT_SHORT_TALENT"] = "Non preso"
L["WHATS_NEXT_SHORT_KNOWN"] = "Conosciuto"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Incantesimo iniziale"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Istruttore"
L["WHATS_NEXT_SOURCE_BOOK"] = "Libro"
L["WHATS_NEXT_SOURCE_QUEST"] = "Missione"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talento"
L["WHATS_NEXT_SOURCE_RUNE"] = "Runa"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Si impara da"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Livello richiesto"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "La tua classe lo possiede fin dall'inizio."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Lo insegna il tuo istruttore di classe."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "Lo insegna un oggetto, come un libro trovato in una spedizione o in un'incursione."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "Lo insegna una missione di classe. Il tuo istruttore di classe può indicartela."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Spendi un punto talento per impararlo."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Incidi la sua runa per impararlo."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Prima impara %s."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "Gradi di %s"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Maiusc + clic"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Collega in chat"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Ordina per disponibilità"
L["WHATS_NEXT_SORT_LEVEL"] = "Ordina per livello"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Ordina per disponibilità elenca prima gli incantesimi che puoi imparare ora e per ultimi quelli che conosci. Ordina per livello elenca ogni incantesimo sotto il livello in cui si impara."
L["WHATS_NEXT_SHOW_KNOWN"] = "Mostra gli incantesimi conosciuti"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Elenca anche gli incantesimi che hai già appreso, dopo gli altri."
L["WHATS_NEXT_SHOW_TALENTS"] = "Mostra i talenti non presi"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Mostra i talenti e le rune non presi"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Elenca anche gli incantesimi dei talenti che non hai preso. Si imparano spendendo punti talento, non da un istruttore."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Libro del famiglio"
L["PET_SPELLBOOK_EMPTY"] = "Il tuo famiglio non ha incantesimi da elencare."
L["PET_SPELLBOOK_NO_PET"] = "Nessun famiglio evocato. Evoca il tuo famiglio per vederne gli incantesimi."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Abilità"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Passive"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Lancio automatico attivo"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Lancio automatico disattivato"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Famiglio: cosa c'è dopo?"
L["WHATS_NEXT_PET_EMPTY"] = "Nessuna abilità del famiglio da elencare."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s, livello %d, %s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Punti addestramento: %d su %d"
L["WHATS_NEXT_PET_NO_PET"] =
	"Nessun famiglio evocato: vengono mostrate le abilità che hai appreso con Addestramento bestie."
L["WHATS_NEXT_PET_NO_PET_SUMMON"] = "Nessun famiglio evocato: richiama il tuo famiglio per vedere cosa conosce già."
L["WHATS_NEXT_PET_NO_DEMON"] = "Nessun demone evocato: evocane uno per vedere cosa conosce già."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Pronte da insegnare"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Abilità di altre famiglie"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Pronta da insegnare"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Altra famiglia"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Istruttore di famigli"
L["WHATS_NEXT_PET_SOURCE_HUNTER_TRAINER"] = "Istruttore dei cacciatori"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Addomesticamento"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Istruttore di demoni"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Livello del famiglio richiesto"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Punti addestramento"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Te la insegna un istruttore di famigli. Poi insegnala al tuo famiglio con Addestramento bestie."
L["WHATS_NEXT_PET_TOOLTIP_HOW_HUNTER_TRAINER"] =
	"Il tuo istruttore dei cacciatori la insegna al famiglio che hai evocato."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Addomestica una bestia che la conosce e combatti al suo fianco finché non la impari. Poi insegnala con Addestramento bestie a qualsiasi famiglio in grado di impararla."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING_NEW_PET"] =
	"Addomestica una bestia che la conosce e il tuo nuovo famiglio la avrà già. Niente la insegna a un famiglio che hai già."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "La conosci. Insegnala al tuo famiglio con Addestramento bestie."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Compra il suo grimorio da un istruttore di demoni, poi usalo mentre è evocato il demone che la impara."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER_TEACHES"] = "Il tuo istruttore dei demoni la insegna."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimorio"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Il suo grimorio è nelle tue borse. Usalo mentre questo demone è evocato."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Il tuo famiglio non può impararla."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Bestie che la conoscono"

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Ordina per disponibilità elenca prima le abilità che il tuo famiglio può imparare ora e per ultime quelle che conosce. Ordina per livello elenca ogni abilità sotto il livello del famiglio richiesto."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Mostra le abilità conosciute"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Elenca anche le abilità che il tuo famiglio conosce già, dopo le altre. Un Cacciatore senza famiglio evocato vede quelle che ha appreso."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Mostra le abilità di altre famiglie"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Elenca anche le abilità che il tuo famiglio non può imparare, come Aggirarsi di un felino per un lupo, o quelle di un altro demone."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Assegnazione tasti"
L["OPTIONS_KEY_SET"] = "Assegna tasto"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Apre l'elenco di assegnazione tasti del gioco, dove Good to Go ha una sezione tutta sua."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Apre e chiude il Libro degli incantesimi avanzato. Ha anche una scheda tutta sua nel tuo libro degli incantesimi."
-- The macro line, /click GtGBuffKey, sits in a box under this to copy (a translation may still place it with %s).
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Lancia il prossimo potenziamento proposto dalla finestra del turno dei potenziamenti, uno per pressione, fuori dal combattimento. Per premerlo da una macro, copiaci la riga qui sotto: cliccala, poi premi Ctrl+A e Ctrl+C."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Tooltip dei gradi degli incantesimi"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"Il tooltip di ogni abilità elenca i suoi gradi e il livello richiesto da ciascuno: bianco per i gradi che conosci, verde per quelli che potresti apprendere ora e grigio per quelli ancora da venire. È un rapido controllo per assicurarti di usare il grado migliore, così puoi sempre giocare al meglio. I gradi non compaiono durante il combattimento, così i tooltip restano brevi quando conta."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Attiva i tooltip dei gradi degli incantesimi"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Aggiunge i gradi di ogni abilità al suo tooltip sulle barre delle azioni, nel libro degli incantesimi del gioco e in altri add-on. Se disattivato, quei tooltip restano come li mostra il gioco. La finestra del Libro degli incantesimi avanzato mostra comunque i gradi."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Elimina macro"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Elimina le macro create dal Libro degli incantesimi avanzato, togliendole anche dalle tue barre delle azioni. Le tue macro non vengono mai toccate, e la pagina ricrea ognuna di esse quando la clicchi o la trascini."
-- The two rows' captions, each beside a Delete button (OPTIONS_DELETE).
L["OPTIONS_DELETE_CHARACTER_MACROS_CAPTION"] = "Macro di questo personaggio"
L["OPTIONS_DELETE_GENERAL_MACROS_CAPTION"] = "Macro generali"
L["OPTIONS_DELETE"] = "Elimina"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Elimina le macro del Libro degli incantesimi avanzato dalla scheda macro di questo personaggio. Gli altri tuoi personaggi tengono le loro finché non fai lo stesso su di loro."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Eliminare tutte le macro del Libro degli incantesimi avanzato di questo personaggio? Vengono tolte anche dalle tue barre delle azioni."
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Elimina le macro del Libro degli incantesimi avanzato dalla scheda Macro generali, condivisa da tutti i personaggi del tuo account, quindi anche gli altri tuoi personaggi perdono lì le loro."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Eliminare tutte le macro generali del Libro degli incantesimi avanzato? Tutti i personaggi del tuo account le perdono, e vengono tolte anche dalle tue barre delle azioni."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Elenca una macro per ogni grado inferiore che conosci di un incantesimo, dopo quella dell'incantesimo stesso, ognuna delle quali lancia sempre il suo grado."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Elenca ogni incantesimo che conosci di un gruppo di incantesimi, come Purificazione e Detersione. Se disattivato, viene elencato solo l'ultimo appreso, anche se le macro degli altri continuano ad aggiornarsi."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Elenca gli incantesimi di classe che non hai ancora appreso in una sezione Non appresi, così puoi piazzare le loro macro in anticipo."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Piazza l'incantesimo dove punta il cursore, senza cerchio di selezione."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lancia il grado più alto che il livello del giocatore amico consente."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Interrompe prima ciò che stai lanciando, così questo incantesimo parte subito."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Ferma prima il tuo attacco automatico in mischia."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Non fa nulla mentre canalizzi un incantesimo, così una pressione non interrompe mai la canalizzazione."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Non fa nulla mentre sei furtivo, così una pressione non interrompe mai Furtività o Aggirarsi."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Esce prima dalla tua forma attuale, così l'incantesimo può essere lanciato."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Seleziona prima il nemico più vicino quando non hai un nemico vivo come bersaglio."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Seleziona prima l'alleato più vicino quando non hai un alleato vivo come bersaglio."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Manda anche il tuo famiglio ad attaccare il tuo bersaglio."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Avvia il tuo attacco automatico in mischia dopo il lancio."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Avvia Tiro automatico o la tua bacchetta dopo il lancio."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lancia una volta, poi non più finché non cambia il tuo bersaglio."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lancia una volta, poi non più finché il combattimento non finisce o il tuo bersaglio non cambia."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Mantiene attivi la forma o l'aspetto quando premi di nuovo la macro, invece di disattivarli."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Cancella il testo di errore rosso che la macro lascia sullo schermo."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Silenzia il suono di errore mentre la macro è in esecuzione."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Mostra/nascondi il Libro degli incantesimi avanzato"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Per sicurezza, l'elenco di assegnazione tasti non può essere aperto durante il combattimento."
L["KEY_BINDINGS_LOCATION"] = "Apri il menu di gioco, poi %s, poi %s, e cerca la sezione Good to Go."

-- Macro errors and prints: the Enhanced Spellbook's, then the Consumable Macros' too-long notice.
L["ERROR_MACRO_SLOTS_FULL"] =
	"Nessuno spazio libero per le macro. Elimina qualcuna delle tue macro in /m per fare spazio."
L["ERROR_MACRO_WINDOW_OPEN"] = "Chiudi prima la finestra delle macro."
L["CHAT_MACROS_DELETED"] = "%d macro eliminate."
L["CHAT_MACROS_DELETED_ONE"] = "1 macro eliminata."
L["CHAT_MACRO_TOO_LONG"] =
	'La macro "%s" è di %d byte con le sue opzioni attive, oltre i %d che una macro può contenere. Disattiva un\'opzione per accorciarla.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'La macro "%s" è di %d byte, oltre i %d che una macro può contenere, quindi la sua ultima riga viene tagliata.'
