local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "frFR")
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
	"Version %s. Les réglages (y compris l'option pour désactiver ce message) se trouvent dans Options > Add-ons > Good to Go. Vous aimez cet add-on ? Parlez-en à un ami, ajoutez-le à vos favoris sur CurseForge ou cliquez sur Star sur sa page GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Aidez Good to Go à monter de niveau"
L["OPTIONS_LEVEL_UP_THANKS"] = "Merci d'avoir choisi Good to Go !"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Bandage"
L["MACRO_EXPLOSIVES"] = "- Explosifs"
L["MACRO_FEED_PET"] = "- Nourrir fam."
L["MACRO_FOOD"] = "- Manger"
L["MACRO_HEALTH_POTION"] = "- Pot. Soins"
L["MACRO_HEALTHSTONE"] = "- Pierre"
L["MACRO_MANA_GEM"] = "- Gemme de mana"
L["MACRO_MANA_POTION"] = "- Pot. Mana"
L["MACRO_POISONS"] = "- Poisons"
L["MACRO_SOULSTONE"] = "- Pierre d'âme"
L["MACRO_WATER"] = "- Boire"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s et %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s et %s"
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

L["DIET_BREAD"] = "Pain"
L["DIET_CHEESE"] = "Fromage"
L["DIET_FISH"] = "Poisson"
L["DIET_FRUIT"] = "Fruit"
L["DIET_FUNGUS"] = "Champignon"
L["DIET_MEAT"] = "Viande"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"On dirait que vous avez trouvé un bug ! %s (%s) est inutilisable dans %s > %s (%s). Veuillez nous le signaler pour que nous puissions le corriger. Merci ! %s"
L["MESSAGE_NO_ITEM"] = "Aucun objet approprié de type %s trouvé dans vos sacs."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Certaines macros de Good to Go n'ont pas pu être créées car vos emplacements de macro sont pleins. Libérez un emplacement en supprimant les macros dont vous ne vous servez plus, ou désactivez les macros de Good to Go dont vous n'avez pas besoin dans Options > Add-ons > Good to Go > Macros de consommables."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Vos macros sont prêtes. Tapez %s, ouvrez l'onglet %s, puis faites glisser - Manger, - Boire et les autres sur vos barres d'action."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s figure désormais dans la liste d'exclusion de ce personnage."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "1 objet retiré de la liste d'exclusion de ce personnage."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "%d objets retirés de la liste d'exclusion de ce personnage."

L["CHAT_OPTIONS_IN_COMBAT"] = "Par mesure de sécurité, l'interface des options ne peut pas être ouverte en combat."

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

L["READINESS_TITLE"] = "Rapport de préparation"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Améliorations manquantes :"
L["READINESS_EXPIRING"] = "Expiration imminente :"
L["READINESS_MISSING_ITEMS"] = "Objets manquants :"
L["READINESS_DAMAGED_GEAR"] = "Équipement endommagé :"
L["READINESS_CHARACTER"] = "Personnage :"
L["READINESS_QUESTIONABLE_GEAR"] = "Équipement hors combat porté :"

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
L["READINESS_FLASK"] = "Flacon ou 2x élixirs"
L["READINESS_PET_FORMAT"] = "%s (familier)"
L["READINESS_SCROLLS"] = "Parchemins"
L["READINESS_SOULSTONE"] = "Pierre d'âme inactive"
L["READINESS_HEALTHSTONE"] = "Pierre de soins"
L["READINESS_MANA_GEM"] = "Gemme de mana"
L["READINESS_HEALING_POTION"] = "Potion de soins"
L["READINESS_MANA_POTION"] = "Potion de mana"
L["READINESS_BANDAGES"] = "Bandages"
L["READINESS_PVP_ON"] = "JcJ activé"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s moins d'1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 point de talent non dépensé"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d points de talent non dépensés"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Vous n'avez actuellement aucune nourriture utile pour votre familier."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Vous ne connaissez actuellement pas %s, %s, %s ou %s."
L["TIP_NO_HAND_POISON"] = "Vous n'avez plus le poison choisi pour cette arme."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Vous ne connaissez actuellement pas %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "%s : il n'y en a plus dans vos sacs. Faites un clic droit sur %s pour en invoquer d'autres."
L["TIP_EMPTY_CREATE"] = "%s : il n'y en a plus dans vos sacs. Faites un clic droit sur %s pour en créer une."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Nourriture à amélioration"
L["FEATURE_SCROLL_BUFFS"] = "Améliorations de parchemins"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Nourriture à amélioration et parchemins"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Utilise la nourriture conférant "%s" et applique les améliorations de parchemins manquantes avant que vous ne mangiez.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Nourriture actuelle"
L["MINIMAP_BEST_PET_FOOD"] = "Nourriture actuelle du familier"
L["MINIMAP_MAIN_HAND_POISON"] = "Poison de main droite"
L["MINIMAP_OFF_HAND_POISON"] = "Poison de main gauche"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Liste d'exclusion"
L["MINIMAP_IGNORE_COUNT"] = "%d objets"
L["MENU_IGNORE"] = "Ignorer"
L["MENU_CLEAR_IGNORE"] = "Vider la liste d'exclusion"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Rapport Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d commandes en attente"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Félicitations, vos réserves sont au complet !"
L["MINIMAP_RESTOCKER_EMPTY"] = "Votre liste est vide."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Liste de réapprovisionnement"
L["MENU_RESTOCKER_DESCRIPTION"] = "Achète et range à la banque les objets de votre liste."
L["MENU_RESTOCKER_KEYBIND"] = "Maj + Clic droit"
L["MENU_OPTIONS"] = "Options de GtG"
L["MENU_OPTIONS_KEYBIND"] = "Maj + Clic milieu"

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
L["NOTE_MACRO_FEED_PET"] = "Macro Nourrir fam."
L["NOTE_MACRO_FOOD_WATER"] = "Macros Manger et Boire"
L["NOTE_MACRO_MANA_GEM"] = "Macro Gemme de mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro Pierre"
L["NOTE_MACRO_SOULSTONE"] = "Macro Pierre d'âme"
L["NOTE_MACRO_POISONS"] = "Macro Poisons"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Appeler, nourrir ou ressusciter"
L["NOTE_PET_MEND_CLICK"] = "Clic droit, ou en combat"
L["NOTE_HOLD_SHIFT"] = "Maintenir Maj"
L["NOTE_PET_FORCE_REVIVE"] = "Forcer la résurrection"
L["NOTE_HOLD_CONTROL"] = "Maintenir Ctrl"
L["NOTE_PET_DISMISS"] = "Renvoyer"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Invoquer"
L["NOTE_CREATE"] = "Créer"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Nouveau clic droit"
L["NOTE_LOWER_RANK_BACKUP"] = "Rang inférieur en secours"
L["NOTE_MAGE_TARGET_LEVEL"] = "Ciblez un joueur de niveau inférieur pour invoquer à son niveau."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Ciblez un joueur de niveau inférieur pour en créer une à son niveau."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Fenêtre Poisons"
L["NOTE_POISONS_REPLACED"] = "Remplace automatiquement les anciens poisons."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandage"
L["LABEL_EXPLOSIVE"] = "Explosif"
L["LABEL_FOOD"] = "Nourriture"
L["LABEL_HEALTH_POTION"] = "Potion de soins"
L["LABEL_HEALTHSTONE"] = "Pierre de soins"
L["LABEL_MANA_GEM"] = "Gemme de mana"
L["LABEL_MANA_POTION"] = "Potion de mana"
L["LABEL_PET_FOOD"] = "Nourriture pour familier"
L["LABEL_POISON"] = "Poison"
L["LABEL_SOULSTONE"] = "Pierre d'âme"
L["LABEL_WATER"] = "Eau"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Activé"
L["MINIMAP_DISABLED"] = "Désactivé"
L["MINIMAP_TOGGLE"] = "Activer/désactiver"
L["MINIMAP_OPEN"] = "Ouvrir"
L["MINIMAP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_MIDDLE_CLICK"] = "Clic milieu"
L["MINIMAP_SHIFT_LEFT"] = "Maj + Clic gauche"

--------------------------------------------------------------------------------
-- Group Contexts
--------------------------------------------------------------------------------

--[[
    The checkboxes for when a feature acts by group, on every panel that has
    them, always in this order. Each description is the checkbox's hover text,
    saying when that context holds: a battleground or arena is always
    Battleground, even though its group is a raid. GROUP_CONTEXT_NEVER is the
    mini-map tooltip's label for a feature on with none of them ticked.
]]
L["GROUP_CONTEXT_SOLO"] = "Solo"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "Quand vous n'êtes pas en groupe ou en raid."
L["GROUP_CONTEXT_PARTY"] = "Groupe"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] =
	"Quand vous êtes en groupe, y compris dans un donjon de l'outil de recherche de groupe."
L["GROUP_CONTEXT_RAID"] = "Raid"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] =
	"Quand vous êtes en raid. Le raid d'un champ de bataille compte comme Champ de bataille."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Champ de bataille"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] =
	"Quand vous êtes dans un champ de bataille ou une arène, quel que soit votre groupe."
L["GROUP_CONTEXT_NEVER"] = "Jamais"

--------------------------------------------------------------------------------
-- When to Use
--------------------------------------------------------------------------------

--[[
    Every consumable's When to Use (Prioritize Buff Food, Enable Scroll
    Buffs, Use Pet Food Buffs, and Use Conjured Food & Water First): the level
    filter dropdown, then the group context checkboxes (GROUP_CONTEXT_*) under
    it. %s in OPTIONS_MODE_DESCRIPTION is the feature's name,
    FEATURE_BUFF_FOOD, FEATURE_SCROLL_BUFFS or OPTIONS_PET_HEADER; the
    conjured dropdown has hover text of its own. Each level value carries its
    own "when", since most dropdowns sit beside their toggle with no caption.
    Leveling means below the client's max level. OPTIONS_GROUPS_NONE shows in
    red under the checkboxes while none is ticked.

    In the mini-map tooltip, the Buff Food & Scrolls block, while a switch is
    on but its When to Use doesn't hold, shows the level label holding it back
    in place of MINIMAP_ENABLED, so every level label has to read as a state
    too. When the checkboxes hold it back, it lists the ticked contexts'
    labels instead, or GROUP_CONTEXT_NEVER with none.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	'Détermine à quels niveaux votre macro Nourriture propose "%s" : à tout niveau, seulement en montant en niveau ou seulement au niveau maximum. Les cases ci-dessous déterminent dans quels groupes.'
L["OPTIONS_MODE_CAPTION"] = "Quand l'utiliser"
L["OPTIONS_GROUPS_NONE"] = "Rien n'est coché, cela n'est donc jamais utilisé."
L["LEVEL_FILTER_ANY"] = "À tout niveau"
L["LEVEL_FILTER_LEVELING"] = "En montant en niveau"
L["LEVEL_FILTER_MAX_LEVEL"] = "Au niveau maximum"

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
L["INVENTORY_REPORT_TITLE"] = "Rapport d'inventaire"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Sacs %s, Banque %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Sacs %s"
L["INVENTORY_REPORT_BANK"] = "Banque %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Total %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Des macros qui se mettent à jour seules pour votre meilleure nourriture, eau, potions et pierres de soins, une liste de réapprovisionnement qui achète et range en banque composants et munitions, les améliorations manquantes en un clic et des macros de survol pour chaque sort."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Grimoire enrichi"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Des macros au survol, au curseur et sur soi pour chaque sort de classe, créées en un clic depuis un nouvel onglet du grimoire, sans aucune syntaxe de macro. Elles se mettent à jour quand vous montez de niveau, vous entraînez ou changez de spécialisation. Clic droit pour ajouter la focalisation, l'arrêt de l'incantation, l'attaque automatique, l'attaque du familier ou les bijoux."
L["SPELLBOOK_IS_OFF"] =
	"Le Grimoire enrichi est désactivé. Activez-le dans Options > Add-ons > Good to Go > Grimoire enrichi."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Affiche un message de bienvenue dans le chat lors de la connexion."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Activer le bouton de la minicarte"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Affiche le bouton de la minicarte."

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
L["OPTIONS_FEATURES_HEADER"] = "Fonctionnalités"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Affiche une fenêtre listant tous les membres de votre groupe à qui il manque une amélioration que vous pouvez donner. Cliquez sur une icône pour la lancer."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Garde vos sacs approvisionnés grâce à votre liste de réapprovisionnement, en achetant chez les marchands et en déplaçant des objets vers et depuis la banque, et vous prévient quand vous commencez à manquer. Désactivé, tout s'arrête, y compris la fenêtre de la liste de réapprovisionnement. Vos listes restent enregistrées."
L["SWITCH_SPELLBOOK"] = "Activer le Grimoire enrichi"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Ajoute à votre grimoire un onglet qui crée des macros au survol, au curseur et sur soi pour vos sorts, et les tient à jour quand vous montez de niveau et vous entraînez. Désactivé, l'onglet est masqué et les mises à jour s'arrêtent. Aucune macro n'est jamais supprimée ; ce sont les boutons Supprimer les macros du panneau Grimoire enrichi qui s'en chargent."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Désactiver le Grimoire enrichi ? Son onglet quitte votre grimoire, et les macros qu'il a créées ne se mettent plus à jour quand vous montez de niveau et vous entraînez. Elles ne sont pas supprimées : elles restent sur vos barres d'action telles qu'elles sont maintenant."
L["SWITCH_MACROS"] = "Activer les macros de consommables"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Garde vos macros Nourriture, Eau, Potion et autres macros de consommables pointées sur le meilleur objet de vos sacs, au fil de leurs changements. Désactivé, les mises à jour s'arrêtent et chaque macro reste telle qu'elle était. Aucune macro n'est jamais supprimée ; c'est en la décochant sous Macros à créer, dans le panneau Macros de consommables, qu'on la supprime."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Désactiver les macros de consommables ? Vos macros ne se mettent plus à jour quand vos sacs changent, si bien qu'un bouton peut continuer à chercher un objet que vous avez épuisé. Elles ne sont pas supprimées : elles restent sur vos barres d'action telles qu'elles sont maintenant."
L["SWITCH_INVENTORY_REPORT"] = "Activer le rapport d'inventaire"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Ajoute à l'infobulle d'un objet combien vous en avez dans vos sacs, à la banque et sur vos autres personnages de ce royaume. Désactivez-le si un autre add-on affiche déjà ces quantités."
L["SWITCH_READINESS_REPORT"] = "Activer le rapport de préparation"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Quand un appel commence, affiche une liste privée de tout ce qu'il vous reste à régler, comme une amélioration manquante, une potion ou un équipement endommagé. Ne dit rien quand vous êtes prêt."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Activer le Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Exemple : %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Ouvre votre liste de réapprovisionnement."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Cet add-on a été créé par des joueurs qui aiment ce jeu et veulent le rendre aussi amusant que possible pour tout le monde. Nous ne demanderons jamais de dons. Notre vraie satisfaction, c'est de savoir que notre travail rend le jeu un peu meilleur pour vous. Si c'est le cas, nous serions ravis de le savoir !"
L["OPTIONS_LEVEL_UP_WAYS"] = "Voici quelques façons de nous aider à toucher plus de joueurs."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Donnez votre avis : Vous avez trouvé un bug ou vous avez une idée ? Dites-le-nous sur Discord. Vos retours nous aident à améliorer l'add-on, et les pull requests sont toujours les bienvenues."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Parlez-en à un ami : Vous connaissez quelqu'un qui pourrait aimer cet add-on ? Parlez-lui-en. Le bouche-à-oreille aide plus de joueurs à découvrir de bons add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favori sur CurseForge : Ouvrez le lien CurseForge ci-dessous, connectez-vous et cliquez sur l'étoile sous le bouton Download. Les favoris aident plus de joueurs à découvrir l'add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star sur GitHub : Ouvrez le lien GitHub ci-dessous, connectez-vous et cliquez sur Star en haut à droite. Les étoiles aident le projet à accéder à davantage d'outils gratuits pour les développeurs."

L["OPTIONS_FEEDBACK"] = "Commentaires et assistance"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Liens de commentaires et d'assistance"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Pour copier un lien, cliquez dans sa case, puis appuyez sur Ctrl+A et Ctrl+C."
L["OPTIONS_VERSION"] = "Version %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "Macros de consommables"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go crée une macro par consommable et la tient à jour au fil des changements dans vos sacs, pour que le bouton de votre barre aille toujours chercher le meilleur objet que vous transportez. Choisissez ci-dessous les macros à créer, puis réglez la façon dont chacune choisit son objet."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Activer les noms de macro sur les boutons"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Affiche le nom des macros sur les boutons de vos barres d'action, que Good to Go masque par défaut."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Macros à créer"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Choisissez les macros que Good to Go crée et gère. En désactiver une la supprime aussi. Elles se trouvent dans l'onglet Macros générales de la fenêtre des macros, prêtes à être glissées sur vos barres d'action."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Ouvrir la fenêtre des macros"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Ouvre la fenêtre des macros du jeu sur son onglet Macros générales, où se trouvent ces macros."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crée et gère cette macro, et la supprime quand la case est décochée."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Nourriture et eau"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Vos macros Nourriture et Eau utilisent la meilleure nourriture et la meilleure boisson de vos sacs. Ces options peuvent faire passer en premier la nourriture à amélioration, les parchemins ou la nourriture et l'eau invoquées, et en dernier la nourriture et l'eau de la liste de réapprovisionnement."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Prioriser la nourriture à amélioration"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Priorise la nourriture conférant l\'amélioration "%s" si elle est absente, sauf en arène.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Activer les améliorations de parchemins"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Votre macro Nourriture applique les parchemins manquants à la première pression, puis vous fait manger à la suivante ; elle ignore les parchemins quand vous ciblez un joueur allié ou que vous êtes en arène."
L["OPTIONS_SCROLL_TYPES"] = "Types de parchemins à vérifier"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Protection"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Inclut "%s" lors de la vérification des améliorations manquantes.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Utiliser d'abord la nourriture et l'eau invoquées"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Vos macros Nourriture et Eau utilisent la nourriture et l\'eau invoquées avant tout le reste, même si un objet de vos sacs rend davantage, car elles ne coûtent rien et disparaissent peu après la déconnexion. La nourriture à amélioration reste prioritaire tant que "Prioriser la nourriture à amélioration" est activé.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Détermine à quels niveaux la nourriture et l'eau invoquées passent en premier : à tout niveau, seulement en montant en niveau ou seulement au niveau maximum. Les cases ci-dessous déterminent dans quels groupes."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Utiliser en dernier la nourriture et l'eau de la liste de réapprovisionnement"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Entre deux nourritures ou boissons qui rendent la même quantité, vos macros Nourriture et Eau utilisent celle qui n'est pas sur votre liste de réapprovisionnement, et gardent pour plus tard ce qu'achète le Restocker."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Potions et Pierres de soins"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Les macros ne peuvent pas être modifiées en combat (c'est une restriction de Blizzard), chaque macro de Potion et de Pierre de soins est donc pré-générée avec votre meilleur objet et jusqu'à deux options de secours. Lors de longs combats, l'icône et l'infobulle peuvent devenir obsolètes et afficher le mauvais objet, mais cliquer sur la macro utilisera toujours le meilleur objet que vous possédez réellement dans vos sacs."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Utiliser la nourriture et l'eau dans les macros de potion hors combat"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Hors combat, votre macro de Potion de soins vous fait manger votre meilleure nourriture et votre macro de Potion de mana vous fait boire votre meilleure eau. En combat, elles utilisent vos potions comme avant. Les parchemins, la nourriture pour familier et l'invocation restent dans les macros Nourriture et Eau."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combiner les Pierres de soins dans la macro de Potion de soins"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Ajoute votre meilleure Pierre de soins à la fin de la macro de Potion de soins, de sorte qu'une seule pression utilise une potion et une Pierre de soins."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemmes de mana et runes"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s et quelques autres objets de mana partagent le temps de recharge des Gemmes de mana. Comme les runes coûtent des points de vie, la macro Gemme de mana les laisse tous de côté, sauf si vous les ajoutez."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Ajouter les runes et autres objets de mana à la macro Gemme de mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Intègre %s, %s, ainsi que tout autre objet de mana qui partage le temps de recharge des Gemmes de mana, au classement de vos Gemmes de mana, pour que la macro Gemme de mana utilise l'un d'eux quand c'est votre meilleure option ou quand vous n'avez plus de gemmes."

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "Renouvellement des améliorations"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Les macros ne peuvent pas être modifiées en combat, donc une amélioration qui expire en plein combat reste absente jusqu'à la fin du combat."
L["OPTIONS_REAPPLY"] = "Renouveler les améliorations qui expirent"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considère comme expirées la Nourriture à amélioration, les Améliorations de parchemins et les Améliorations de nourriture pour familier dont le temps restant est inférieur à votre seuil, afin que vos macros en proposent une nouvelle avant le combat."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Définit à quel point une amélioration peut être proche d'expirer avant que vos macros en proposent une nouvelle."
L["REAPPLY_THRESHOLD_ONE"] = "Quand il reste < 1 minute"
L["REAPPLY_THRESHOLD_MANY"] = "Quand il reste < %d minutes"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Améliorations de nourriture pour familier"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] =
	'Certains aliments confèrent à votre familier sa propre amélioration "%s".'
L["OPTIONS_USE_PET_BUFFS"] = "Utiliser les améliorations de nourriture pour familier"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	"Ajoute de la nourriture pour familier à votre macro Nourriture quand votre familier n'a pas l'amélioration \"%s\", sauf en arène."
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Types de nourriture pour familier à vérifier"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosifs"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"L'option @player ignore le réticule de ciblage et déclenche l'explosif à vos pieds. Idéal quand votre cible est au corps à corps. Votre autre clic le lance comme d'habitude."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Attribution des clics"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Détermine quel clic lance l'explosif et lequel le déclenche à vos pieds."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic gauche : @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic gauche : lancer"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Classe et race"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Ces options adaptent vos macros à une classe ou à une race. Chaque section s'affiche sur tous les personnages."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Options de classe : %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Options raciales : %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Nécessite l'add-on DruidMacroHelper. Activé, vos macros de Potion de soins, de Potion de mana et de Pierre de soins vous font quitter votre forme par powershifting, utilisent l'objet et vous remettent en Forme d'ours ou en Forme de félin, selon ce que vous choisissez à côté de la case."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Activer l'intégration de DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crée des macros de powershifting pour les potions de soins, les potions de mana et les pierres de soins à l'aide de DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Détermine la forme dans laquelle vos macros de powershifting vous ramènent après l'utilisation de l'objet."
L["DRUID_FORM_BEAR"] = "Retour en ours"
L["DRUID_FORM_CAT"] = "Retour en félin"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Garde la macro Poisons chargée avec le meilleur rang utilisable de chaque type de poison. Clic gauche pour la main gauche, clic droit pour la main droite ; les poisons existants sont remplacés automatiquement."
L["OPTIONS_POISON_MAIN_HAND"] = "Type de poison de main droite"
L["OPTIONS_POISON_OFF_HAND"] = "Type de poison de main gauche"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Détermine le poison que votre macro Poisons applique à votre main droite lors d'un clic droit."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Détermine le poison que votre macro Poisons applique à votre main gauche lors d'un clic gauche."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Activer le camouflage en mangeant"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"Ajoute %s à votre macro Nourriture pour vous camoufler pendant que vous mangez."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Activer le camouflage en buvant"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"Ajoute %s à votre macro Eau pour vous camoufler pendant que vous buvez."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Astuce de pro : Choisissez-en un. Vous pouvez manger et boire en même temps, mais manger ou boire après vous être camouflé rompra le camouflage."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Ciblez un humanoïde ou un mort-vivant que vous avez tué et votre macro lance %s tant que le sort est prêt, ce qui économise votre nourriture et votre boisson. Si elle ne peut pas (le cadavre est hors de portée ou le sort est en recharge), elle mange ou boit comme d'habitude."
L["OPTIONS_CANNIBALIZE_EATING"] = "Utiliser %s au lieu de manger"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Tant que votre cible est un cadavre sur lequel %s fonctionne et que le sort est prêt, votre macro Nourriture le lance au lieu de manger. Sinon, elle mange comme d'habitude. Les parchemins et la nourriture à amélioration restent prioritaires."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Utiliser %s au lieu de boire"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Tant que votre cible est un cadavre sur lequel %s fonctionne et que le sort est prêt, votre macro Eau le lance au lieu de boire. Sinon, elle boit comme d'habitude. Les boissons à amélioration restent prioritaires."

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"Tant que %s est disponible, votre macro Nourriture le lance au lieu de manger, ce qui économise votre nourriture. Une fois le sort en recharge, elle mange comme d'habitude."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "Utiliser %s au lieu de manger"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"Tant que %s est disponible, votre macro Nourriture le lance au lieu de manger. Sinon, elle mange comme d'habitude. Les parchemins et la nourriture à amélioration restent prioritaires. En combat, où l'on ne peut pas manger, chaque appui le lance."

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
L["TAB_IGNORE_LIST"] = "Liste d'exclusion"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Les objets ignorés ne sont jamais choisis par aucune macro. Nourriture, eau, potions, tout. La liste globale couvre tous les personnages ; celle d'un personnage ne couvre que lui. Faites un clic droit sur le bouton de la minicarte pour ignorer votre meilleure nourriture du moment."
L["OPTIONS_IGNORE_GLOBAL"] = "Globale"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Déplace cet objet vers la liste globale, afin qu'il soit ignoré sur tous les personnages."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Ajouter depuis les sacs"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Choisissez n'importe quel objet que vous transportez. Les sacs se ferment à l'ouverture de l'interface des options, ceci remplace donc le glisser-déposer d'un objet ici."
L["OPTIONS_IGNORE_ADD_ID"] = "Ajouter par ID d'objet"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Saisissez un ID d'objet, ou faites Maj + Clic sur un lien d'objet dans le chat pendant que ce champ est actif."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Saisissez un ID d'objet, ou faites Maj + Clic sur un lien d'objet dans le chat."
L["OPTIONS_IGNORE_REMOVE"] = "Retirer"
L["OPTIONS_IGNORE_EMPTY"] = "Cette liste est vide."
L["OPTIONS_IGNORE_CLEAR"] = "Vider la liste"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Retire tous les objets de cette liste. Un personnage dont la liste est vide disparaît de la liste de gauche, sauf s'il s'agit de celui que vous jouez."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "Retirer tous les objets de cette liste ? Cette action est irréversible."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Chargement de l'ID : %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Garde vos sacs approvisionnés grâce à votre liste de réapprovisionnement, en achetant chez les marchands et en déplaçant automatiquement les objets entre vos sacs et la banque. Tapez %s pour ouvrir la liste."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Ouvrir à la banque"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] =
	"Ouvre votre liste de réapprovisionnement quand vous vous rendez à la banque."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Ouvrir chez le marchand"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] =
	"Ouvre votre liste de réapprovisionnement quand vous vous rendez chez un marchand."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Rappels"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"Choisissez quand être prévenu qu'il vous manque des objets de votre liste de réapprovisionnement."
L["OPTIONS_RESTOCKER_REMIND"] = "Activer les rappels de réapprovisionnement en ville"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Affiche un rappel dans le chat quand il vous manque des objets de votre liste de réapprovisionnement et que vous arrivez dans une auberge ou une ville, ou que vous vous y trouvez déjà à la connexion."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activer les rappels de réapprovisionnement chez le marchand"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Signale les éventuelles commandes de réapprovisionnement en attente quand vous fermez une fenêtre de marchand."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activer les rappels de réapprovisionnement à la banque"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Signale les éventuelles commandes de réapprovisionnement en attente quand vous fermez la banque."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Réserve d'or"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"Mettez de côté de l'or que les achats chez les marchands ne dépensent jamais."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Activer la réserve d'or"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"Le réapprovisionnement ne dépense jamais l'or que vous mettez de côté ici."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] =
	"Définit la quantité d'or que le réapprovisionnement vous laisse toujours."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Détermine si le rappel tient en une seule ligne ou ajoute une ligne pour chaque objet qui vous manque."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Niveau de détail"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Détaillé"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Jouer un son"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Joue une alerte en même temps que le rappel, pour quand le chat est chargé."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Cliquez pour écouter l'alerte."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenêtre de la liste de réapprovisionnement"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Choisissez quand votre liste de réapprovisionnement s'ouvre d'elle-même."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Affiche dans l'infobulle d'un objet combien vous en possédez, sur l'ensemble de vos personnages de ce royaume."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Personnages enregistrés"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Oublier"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"Oublier %s ? Ses sacs et sa banque disparaissent de toutes les infobulles d'objet, et son choix de liste de réapprovisionnement est effacé. Se reconnecter avec ce personnage l'enregistre à nouveau."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Rapport de préparation"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quand un appel commence, affiche une liste privée de ce qu'il reste à corriger, et ne dit rien du tout quand vous êtes prêt."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Réinitialiser les réglages du rapport de préparation"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Remet chaque case à cocher et les deux seuils de cette page à leurs valeurs par défaut."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Réinitialiser tous les réglages du rapport de préparation à leurs valeurs par défaut ?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Améliorations manquantes"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Objets manquants"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personnage"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Signale un flacon manquant. Un flacon, ou un élixir de bataille et un élixir du gardien, compte comme couvert."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	"Signale l'absence de l'amélioration \"%s\". Nécessite que la nourriture à amélioration soit activée dans Macros de consommables."
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	"Signale l'absence de l'amélioration \"%s\" sur votre familier. Nécessite que les améliorations de nourriture pour familier soient activées dans Macros de consommables, et un familier présent."
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"Signale les améliorations de parchemins manquantes. Nécessite que les améliorations de parchemins soient activées dans Macros de consommables, et ne vérifie que les types de parchemins qui y sont sélectionnés."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Signale quand aucun membre de votre groupe n'a de Pierre d'âme active ; une pierre dans un sac ne compte pas. Signalé uniquement à un démoniste capable d'en créer une."
L["OPTIONS_READINESS_MAIN_HAND"] = "Amélioration d'arme (main droite)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Signale une arme en main droite sans enchantement temporaire. Tout enchantement compte, et rien n'est signalé quand il y a un chaman dans votre groupe."
L["OPTIONS_READINESS_OFF_HAND"] = "Amélioration d'arme (main gauche)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Signale une arme en main gauche sans enchantement temporaire. Tout enchantement compte : une pierre, une huile, un poison ou une amélioration d'arme de chaman."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Signale une arme en main droite à laquelle il manque un enchantement temporaire. Les voleurs et les chamans en ont besoin de deux, un poison ou une imprégnation à côté d'une huile ou d'une pierre ; les autres, d'un seul, quel qu'il soit."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Signale une arme en main gauche à laquelle il manque un enchantement temporaire. Les voleurs en ont besoin de deux, un poison à côté d'une huile ou d'une pierre ; les autres, d'un seul, quel qu'il soit."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Améliorations expirant sous"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Nomme chaque amélioration sur vous qui est sur le point d'expirer, pas seulement celles que Good to Go applique. Ce seuil est distinct du renouvellement des améliorations de Macros de consommables."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutes"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Définit à quel point une amélioration doit être proche d'expirer pour que le rapport la nomme."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Signale quand vous ne portez aucune Pierre de soins. Signalé uniquement quand un démoniste de votre groupe peut vous en donner une, ou quand le démoniste, c'est vous."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Signale quand vous ne portez aucune Gemme de mana. Signalé uniquement à un mage capable d'en invoquer une."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Signale quand vous ne portez aucune potion de soins, car personne ne peut vous en passer une en plein combat."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Signale quand vous ne portez aucune potion de mana. Signalé uniquement quand vous jouez une classe qui utilise du mana."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Signale quand vous ne portez aucun bandage que votre compétence en %s vous permet d'utiliser."
L["OPTIONS_READINESS_DURABILITY"] = "Équipement endommagé sous"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Affiche le lien de chaque objet équipé dont la durabilité est inférieure à ce seuil, mesurée objet par objet pour qu'une seule arme cassée apparaisse quand même."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Définit jusqu'où la durabilité d'un objet doit baisser pour que le rapport en affiche le lien."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Spécialisation actuelle"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Affiche votre répartition de talents, et les points que vous n'avez pas dépensés."
L["OPTIONS_READINESS_PVP"] = "Marqueur JcJ actif"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avertit quand vous portez un marqueur JcJ."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Équipement hors combat porté"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Affiche le lien des objets équipés qui n'ont rien à faire dans un combat, comme l'équipement d'équitation ou de pêche."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "Veille des rangs"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Surveille votre groupe pour repérer les sorts lancés à un rang inférieur à celui que le lanceur pourrait avoir, et le prévient qu'un rang supérieur l'attend chez son maître. Un rang que le jeu abaisse de lui-même, comme une amélioration lancée sur un joueur de bas niveau, n'est jamais signalé."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s fonctionne toujours, donc la Veille des rangs reste silencieuse pour que votre groupe n'entende pas parler deux fois de chaque rang inférieur. Good to Go l'a désactivé et a activé la Veille des rangs ; rechargez l'interface pour que la Veille des rangs prenne le relais."

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s (%s)"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Rang %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"Pour info, rien de grave, mais tu as utilisé %s. Il existe un rang supérieur dès le niveau %d. Mets à jour tes barres d'action ou passe voir ton maître de classe, et tu seras Good to Go."
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"Pour info, rien de grave, mais ton familier %s a utilisé %s. Il existe un rang supérieur dès le niveau %d du familier. Enseigne-le-lui avec Dressage des bêtes et tu seras Good to Go."
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"Pour info, rien de grave, mais ton démon (%s) a utilisé %s. Il existe un rang supérieur dès le niveau %d. Prends son grimoire chez un maître des démons et tu seras Good to Go."
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"Tu préfères ne plus recevoir ce genre de conseils ? Réponds %s et je ne te chuchoterai plus au sujet des rangs de sorts. Ton numéro fonctionne avec tous ceux qui utilisent Good to Go."
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] = "C'est noté, plus de conseils sur les rangs de ma part."
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	"%s a envoyé son numéro de désinscription, la Veille des rangs l'ignore donc désormais. Vous pouvez annuler cela dans Joueurs ignorés, sous Veille des rangs."
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"Vous avez lancé %s, et %s est disponible dès le niveau %d. Rendez visite à votre maître de classe ou mettez à jour vos barres d'action."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "Votre familier %s a lancé %s, et %s lui est accessible dès le niveau %d."
L["RANK_WATCH_PRINT_SELF_DEMON"] = "Votre démon (%s) a lancé %s, et %s est disponible dès le niveau %d."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s a lancé %s, et %s lui est accessible dès le niveau %d."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"Le familier %2$s de %1$s a lancé %3$s, et %4$s lui est accessible dès le niveau %5$d."
L["RANK_WATCH_PRINT_OTHER_DEMON"] =
	"Le démon (%2$s) de %1$s a lancé %3$s, et %4$s est disponible dès le niveau %5$d."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s lui enverra un chuchotement."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Activer la Veille des rangs"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Vous prévient, et chuchote aux membres de votre groupe, quand quelqu'un lance un sort à un rang inférieur à celui qu'il pourrait avoir, pour qu'il sache qu'il doit passer voir son maître."

L["RANK_WATCH_MESSAGES_HEADER"] = "Notifications"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] =
	"Comment la Veille des rangs prévient un joueur qu'il a lancé un rang inférieur."
L["RANK_WATCH_WHISPER"] = "Chuchoter aux membres du groupe"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Chuchote au membre du groupe qui a lancé un rang inférieur. Quand plusieurs joueurs de votre groupe utilisent la Veille des rangs ou Rank Sentinel, un seul d'entre eux chuchote."
L["RANK_WATCH_PRINT"] = "Afficher les rangs inférieurs du groupe"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"Affiche dans votre chat le rang inférieur lancé par un membre du groupe. Vos propres rangs inférieurs s'affichent toujours."
L["RANK_WATCH_GRACE_HEADER"] = "Délai de grâce"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"Un nouveau rang n'est signalé qu'une fois que le lanceur a dépassé son niveau d'autant de niveaux, pour que personne n'entende parler d'un rang qu'il vient tout juste d'atteindre et n'a pas encore eu le temps d'apprendre."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Délai de grâce au niveau maximum"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"Pour un personnage au niveau maximum, laisse de côté tout rang appris à ce nombre de niveaux du maximum, ou moins. À 0, chaque rang qu'il pourrait avoir est signalé."
L["RANK_WATCH_GRACE_LEVELING"] = "Délai de grâce en montant en niveau"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"Pour un personnage qui monte encore en niveau, laisse de côté tout rang appris à ce nombre de niveaux du sien ou moins, pour lui laisser le temps d'aller voir un maître."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 niveau"
L["RANK_WATCH_GRACE_LEVELS"] = "%d niveaux"

L["RANK_WATCH_OPT_OUT_HEADER"] = "Désinscription"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	"La première fois que la Veille des rangs chuchote à quelqu'un, elle lui envoie ensuite son numéro de désinscription. Ce numéro dépend de son nom, il est donc le même pour tous ceux qui utilisent Good to Go. S'il le dit dans un chuchotement ou dans n'importe quel canal que vous voyez, il rejoint les Joueurs ignorés et n'entend plus jamais parler de rangs de votre part. Pour laisser vous-même quelqu'un tranquille, ciblez-le et tapez /gtg ignore."
L["RANK_WATCH_WHISPERER_HEADER"] = "Qui prévient pour votre groupe"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"Quand plusieurs joueurs de votre groupe utilisent la Veille des rangs ou Rank Sentinel, un seul d'entre eux envoie les chuchotements, pour qu'un joueur qui lance un rang inférieur n'en entende parler qu'une fois au lieu de l'entendre de tout le monde. Les autres l'affichent seulement dans leur propre chat. Voici qui les envoie en ce moment."
L["RANK_WATCH_WHISPERER_SELF"] = "Vous."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s, vous ne voyez donc que le message dans le chat."
L["RANK_WATCH_WHISPERER_NONE"] = "Personne : Chuchoter aux membres du groupe est désactivé."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Joueurs ignorés"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "La Veille des rangs ne signale jamais ces joueurs."
L["RANK_WATCH_IGNORED_NONE"] = "Personne pour l'instant."
L["RANK_WATCH_IGNORED_REMOVE"] = "Ne plus ignorer"
L["RANK_WATCH_IGNORE_TARGET"] = "Ignorer la cible"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "Ajoute à la liste le joueur que vous ciblez."
L["RANK_WATCH_IGNORE_ADDED"] = "La Veille des rangs ignore désormais %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"Impossible de trouver %s. Groupez-vous avec ce joueur ou ciblez-le, puis réessayez."
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Ciblez un joueur, ou tapez /gtg ignore Nom."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Nom"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"La Veille des rangs cesse de signaler ce joueur. Sans nom, ignore votre cible."

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"Les rangs que signale la Veille des rangs, classe par classe. Décochez un rang inférieur que vous utilisez exprès et la Veille des rangs le laisse tranquille. Toutes les capacités sont listées. Celles que la Veille des rangs ne surveille pas par défaut, comme les soins, les talents et Brûlure rang 1, sont décochées au départ. Le rang le plus élevé d'une capacité est grisé, puisque rien n'est au-dessus."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (niveau %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "Signale ce rang quand un rang supérieur est disponible."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "Le rang le plus élevé. Rien n'est au-dessus, il n'est donc jamais signalé."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "Familiers (%s)"
L["RANK_WATCH_TRACK_ALL"] = "Tout cocher"
L["RANK_WATCH_TRACK_NONE"] = "Tout décocher"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Une liste nommée "%s" existe déjà.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Aucun objet d'ID %d."
L["RESTOCKER_DISABLED"] = "Le Restocker est désactivé. Activez-le dans Options > Add-ons > Good to Go > Restocker."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = "Aucune liste de réapprovisionnement nommée %s."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Réapprovisionnement terminé. Maintenez Maj en ouvrant la banque pour ignorer le réapprovisionnement. Tapez %s pour modifier votre liste de réapprovisionnement."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Réapprovisionnement arrêté. Vos sacs et votre banque sont pleins."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Réapprovisionnement arrêté. Votre banque est pleine ; libérez un emplacement et rouvrez-la."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Réapprovisionnement arrêté. Vos sacs sont pleins ; libérez un emplacement et rouvrez la banque."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Réapprovisionnement arrêté. Aucun progrès possible."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Réapprovisionnement arrêté. Impossible de déplacer : %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (en trop)"
L["RESTOCKER_STOPPED_ERROR"] = "Réapprovisionnement arrêté à cause d'une erreur : %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Ce marchand ne vend pas tous les ingrédients dont vos poisons ont besoin. Aucun ne sera acheté."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "N'oubliez pas de vous réapprovisionner tant que vous êtes en ville !"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 commande de réapprovisionnement en attente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d commandes de réapprovisionnement en attente."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Votre liste de réapprovisionnement a été mise à niveau."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d devient %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 commande de réapprovisionnement honorée."
L["RESTOCKER_RESTOCKED_MANY"] = "%d commandes de réapprovisionnement honorées."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 commande de réapprovisionnement partiellement honorée."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d commandes de réapprovisionnement partiellement honorées."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Vos sacs se sont remplis avant que tout soit acheté."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "Pas assez d'or pour terminer le réapprovisionnement."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Vous avez moins de %s. Le réapprovisionnement reprendra quand vous en aurez plus."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nom]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Ajoute une liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Supprime la liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renomme la liste actuelle avec ce nom."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Remplace la liste actuelle par une copie de la liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_USE"] = "Fait passer ce personnage à la liste portant ce nom."

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
L["STARTER_POPUP_TITLE"] = "Produits de base"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Terminé"
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Nous avons coché quelques produits de base pour votre classe afin de vous aider à démarrer."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Votre liste de réapprovisionnement est vide, alors ajoutons quelques objets pour bien démarrer."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Choisissez les produits de base à garder en réserve."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tout ce que vous cochez est réapprovisionné automatiquement dès que vous ouvrez un marchand ou votre banque. La plupart des produits de base s'améliorent d'eux-mêmes à mesure que vous montez en niveau, pour que vous ayez toujours le meilleur disponible."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Vous pouvez à tout moment ajuster cette liste, ou ajouter d'autres objets plus tard, en tapant %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Nourriture et eau"
L["STARTER_POPUP_FOOD_HEADER"] = "Nourriture"
L["STARTER_POPUP_AMMO_HEADER"] = "Munitions"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Balles"
L["STARTER_POPUP_ARROWS"] = "Flèches"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Composants et outils"
L["STARTER_POPUP_POISONS_HEADER"] = "Poisons"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Ajoutez le poison fini à votre liste, et Good to Go achète automatiquement les ingrédients chez tout marchand qui les vend tous."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Ajoute %s à votre liste de réapprovisionnement, en gardant %d dans vos sacs et en les améliorant à mesure que vous montez en niveau."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Ajoute %s à votre liste de réapprovisionnement et garde %d dans vos sacs."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pile"
L["STARTER_POPUP_STACK_MANY"] = "%d piles"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Nombre de piles à garder en réserve, une pile valant %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Nombre d'exemplaires à garder en réserve, chacun dans son propre emplacement de sac puisqu'ils ne s'empilent pas."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Liste de réapprovisionnement"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrer les objets..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Effacer"
L["RESTOCKER_ADD_BUTTON"] = "Ajouter"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Choisir des produits de base"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Choisissez parmi les produits de base de votre classe et de votre niveau : nourriture, eau, munitions, poisons et composants. Cocher un produit l'ajoute à cette liste ; le décocher l'en retire."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Ajouter un objet"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Déposez un objet depuis vos sacs ici ou n'importe où sur cette fenêtre, ou saisissez un ID d'objet et appuyez sur Entrée."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Déposer objet ou saisir ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Saisissez plutôt un ID."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Déjà dans cette liste."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Ajouter depuis vos sacs"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Tous les objets de vos sacs qui ne figurent pas encore sur cette liste, prêts à être ajoutés."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Rien à ajouter depuis vos sacs"

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
	"Fait passer ce personnage à une autre liste de réapprovisionnement, ou en commence une nouvelle."
L["RESTOCKER_USED_BY"] = "Utilisée par %s"
L["RESTOCKER_MANAGE"] = "Gérer les listes"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Commencez une nouvelle liste, ou copiez, renommez ou supprimez celle-ci."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nouvelle liste"
L["RESTOCKER_MANAGE_COPY"] = "Copier cette liste dans une nouvelle"
L["RESTOCKER_RENAME_PROFILE"] = "Renommer cette liste"
L["RESTOCKER_MANAGE_DELETE"] = "Supprimer cette liste"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Copie"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renommer"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renomme cette liste pour tous les personnages qui l'utilisent."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Voulez-vous vraiment supprimer cette liste ?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s l'utilise aussi et retrouvera une liste vide du même nom à sa prochaine connexion."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s l'utilisent aussi et retrouveront chacun une liste vide du même nom à leur prochaine connexion."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Vous passerez à la liste %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "C'est la seule liste restante, vous commencerez donc avec une nouvelle liste vide."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Cette action est irréversible."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Améliorer au fil des niveaux"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permet à Good to Go de remplacer la nourriture, l'eau, les munitions, les poisons, les potions et les composants de classe par de meilleurs objets à mesure que vous montez en niveau."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Améliorer"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Objet"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Retirer"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Ranger"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rép."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Garder"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "L'en-tête applique ce réglage à tous les objets affichés."
L["RESTOCKER_BULK_ON"] = "Activer pour les objets affichés (%d)"
L["RESTOCKER_BULK_OFF"] = "Désactiver pour les objets affichés (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Autre"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nouveaux"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Tous les objets"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Rien sur cette liste pour l'instant"
L["RESTOCKER_EMPTY_BODY"] =
	"Choisissez des produits de base comme la nourriture, l'eau ou les composants de classe, ou ajoutez n'importe quel objet de vos sacs avec le menu ci-dessus. Les objets de cette liste sont automatiquement gardés en réserve ou rangés à la banque, pour que vos sacs restent désencombrés."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Déposer un objet n'importe où sur cette fenêtre l'ajoute aussi."
L["RESTOCKER_NO_MATCH_FILTER"] = "Rien sur cette liste ne correspond à votre filtre."
L["RESTOCKER_NO_MATCH_GROUP"] = "Il ne reste rien dans cette catégorie."

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
L["RESTOCKER_NO_ORDERS"] = "Aucune commande de réapprovisionnement en attente."
L["RESTOCKER_REPORT_MORE"] = "Et %d de plus."
L["RESTOCKER_REMOVED_ITEM"] = "Objet retiré : %s."
L["RESTOCKER_UNDO"] = "Annuler"
L["RESTOCKER_UNDO_TOOLTIP"] = "Remettre cet objet sur la liste"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Retirer cet objet de la liste de réapprovisionnement"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Vous pouvez annuler cette action en haut de la liste."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Garder dans vos sacs"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Nombre d'exemplaires à garder dans vos sacs. Ce nombre passe au jaune tant que vos sacs en contiennent moins, et 0 avec Ranger activé envoie tout à la banque."
L["RESTOCKER_BUY_LABEL"] = "Acheter"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Acheter chez le marchand"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Achète la quantité nécessaire chez le marchand quand sa fenêtre est ouverte."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Surplus"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Acheter en surplus"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Achète tout le stock limité de cet objet chez un marchand, ces marchandises vendues au compte-gouttes qu'il réapprovisionne peu à peu, même au-delà de votre quantité à garder."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Ranger à la banque"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Range les objets en trop à la banque quand elle est ouverte, ou la totalité si la colonne Garder indique 0."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Retirer de la banque"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Retire les objets nécessaires de la banque quand elle est ouverte."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Réputation requise"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de remise)"
L["RESTOCKER_REPUTATION_ANY"] = "Aucune"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Réputation requise auprès du marchand"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Définit la réputation qu'un marchand exige avant que Good to Go n'achète chez lui, ce qui réduit aussi le prix : %s 5%%, %s 10%%, %s 15%%, %s 20%%. Avec un tiret, Good to Go achète chez n'importe quel marchand."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Acheter est désactivé pour cet objet, il n'y a donc rien à acheter en surplus."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Acheter est désactivé pour cet objet, la réputation requise ne s'applique donc pas."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Cet objet n'a pas de meilleure version vers laquelle évoluer."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go a désactivé %s, qu'il remplace. Recharger maintenant pour que l'ancienne version cesse de fonctionner ?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Recharger maintenant"
L["POPUP_REPLACED_LATER"] = "Plus tard"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Vos réglages de %s ont été copiés."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go a copié vos réglages depuis %s et a désactivé %s, qu'il remplace. Recharger maintenant pour que l'ancienne version cesse de fonctionner ?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go a détecté une installation désactivée de %s. Récupérer les réglages ? Cela réactive les anciens add-ons et recharge votre interface, puis vous propose un nouveau rechargement pour les désactiver à nouveau."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go a détecté une installation désactivée de %s. Récupérer les réglages et les listes de réapprovisionnement ? Cela réactive les anciens add-ons et recharge votre interface, puis vous propose un nouveau rechargement pour les désactiver à nouveau."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Les récupérer"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "Non merci"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Améliorations de groupe"
L["RANK_WATCH_TRACKED_HEADER"] = "Rangs signalés"
L["TRACKED_ITEM_PENDING"] = "Objet #%d"
L["TRACKED_SPELL_PENDING"] = "Sort #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Joue le son pour que vous puissiez l'écouter avant de l'activer."

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Corvée d'améliorations"
L["BUFF_DUTY_DESCRIPTION"] = "Indique qui n'a pas vos améliorations. Cliquez sur une icône pour lancer le sort."
L["BUFF_DUTY_ENABLE"] = "Activer la corvée d'améliorations"
L["BUFF_DUTY_NO_BUFFS"] =
	"Votre classe n'a aucune amélioration dans cette liste, la fenêtre n'apparaît donc jamais sur ce personnage."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Quand afficher"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Choisissez quand la fenêtre peut apparaître."
L["BUFF_DUTY_WHEN_NONE"] = "Rien n'est coché, la fenêtre n'apparaît donc jamais."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"La corvée d'améliorations est masquée ici. Le jeu ne laisse pas les add-ons voir les améliorations dans cette zone, elle ne peut donc pas savoir à qui il en manque une."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Définit où la fenêtre s'affiche : partout, ou seulement dans une instance, comme un donjon ou un raid."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Partout"
L["BUFF_DUTY_WHERE_INSTANCE"] = "En instance"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Affiche la fenêtre quand vous jouez ces classes."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Affiche la fenêtre quand vous jouez cette classe."
L["BUFF_DUTY_HEADER"] = "Fenêtre"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Gardez la fenêtre là où vous l'avez placée, ou écartez-la pendant le combat."
L["BUFF_DUTY_LOCK"] = "Verrouiller la fenêtre"
L["BUFF_DUTY_LOCK_DESCRIPTION"] =
	"Empêche la fenêtre d'être déplacée. Déverrouillée, faites-la glisser par son arrière-plan."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Masquer en combat"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Masque la fenêtre pendant le combat. La liste ne peut pas se mettre à jour en combat, donc une fenêtre laissée affichée garde son dernier état jusqu'à la fin du combat."
L["BUFF_DUTY_SHOW_HEADER"] = "Afficher dans la fenêtre"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Ajoutez à la fenêtre vos propres améliorations, les inconnus qui vous ont amélioré et votre cible."
L["BUFF_DUTY_FAVOR_ENABLE"] = "Rendre la pareille"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Liste les inconnus qui vous ont amélioré récemment, avec les améliorations que vous pouvez leur rendre. Faites un clic droit sur une icône pour retirer quelqu'un de la liste."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Définit combien de temps un inconnu reste dans la liste après sa dernière amélioration."
L["BUFF_DUTY_TARGET_ENABLE"] = "Votre cible"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Liste votre cible quand c'est un joueur hors de votre groupe à qui il manque une amélioration que vous pouvez lancer."
L["BUFF_DUTY_ASK_OTHERS"] = "Demander des améliorations aux autres classes"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Affiche sous \"Améliorations de groupe manquantes\" les améliorations de raid qui manquent à votre groupe, avec le nombre de joueurs concernés par chacune. Clic gauche sur l'une d'elles pour la demander à votre groupe, ou clic droit pour chuchoter aux joueurs qui peuvent la lancer."
L["BUFF_DUTY_REFRESH"] = "Renouveler sous"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Définit en dessous de quel temps restant une amélioration est considérée comme manquante, pour que vous puissiez la renouveler avant qu'elle ne disparaisse. Une amélioration qui ne dure pas plus longtemps que cela n'est comptée qu'une fois disparue."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Compter comme tanks"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Qui reçoit les améliorations que vous proposez aux Tanks, comme Épines, quand il n'a pas de rôle défini."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Définit quand les joueurs de cette classe comptent comme tanks. Un rôle de tank ou de soigneur qu'ils ont passe toujours en premier."
L["BUFF_DUTY_TANKS_PETS"] = "Familiers"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Définit quand les familiers comptent comme tanks. Les familiers reçoivent aussi les améliorations que vous proposez à Tous."
L["BUFF_DUTY_TANKS_NEVER"] = "Jamais"
L["BUFF_DUTY_TANKS_SOLO"] = "En solo"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Toujours"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Désactivé"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Tanks"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Soigneurs"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Tous"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Définit à qui proposer %s."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Choisissez à qui chaque amélioration est proposée. Tanks et Soigneurs dépendent du rôle dans le groupe, mais en raid, seuls les joueurs désignés %s comptent comme tanks. Quiconque n'a pas de rôle compte comme Dégâts, sauf indication contraire de Compter comme tanks ci-dessous."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Améliorations personnelles"
L["BUFF_DUTY_SELF_DESCRIPTION"] = "Vos propres améliorations, épinglées en haut de la fenêtre."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "n'importe quel aspect compte"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "n'importe quelle armure compte"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "n'importe quelle aura compte"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "n'importe quel bouclier compte"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "n'importe quelle armure compte"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "l'un ou l'autre effet démoniaque compte"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Désactivé"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Si absente"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Moins de %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Définit quand %s s'affiche : jamais, une fois l'effet terminé, ou quand il en reste moins que cette durée."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Améliorations d'arme"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Cochez ce que chaque arme doit porter. La fenêtre le propose quand il manque ou arrive bientôt à expiration, s'il est dans vos sacs et convient à l'arme."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "Réappliquer"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Définit quand une amélioration d'arme est proposée de nouveau : une fois l'effet terminé, ou quand il en reste moins que cette durée."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Huiles"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Pierres"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Appâts"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Propose %s pour votre arme (%s). Tant que l'arme ne porte aucun de vos choix cochés, chacun de ceux que vous possédez est proposé."
L["BUFF_DUTY_SELF_ENABLE"] = "Vos améliorations personnelles"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Affiche en haut de la fenêtre les améliorations que vous seul pouvez vous lancer, comme une armure ou Feu intérieur, quand elles manquent ou arrivent bientôt à expiration. Choisissez lesquelles dans Améliorations personnelles."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Vos améliorations d'arme"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Affiche les poisons, imprégnations, huiles, pierres et appâts qui manquent à vos armes ou arrivent bientôt à expiration, avec vos améliorations personnelles en haut de la fenêtre. Cliquez sur l'un d'eux pour l'appliquer. Choisissez lesquelles dans Améliorations d'arme."

-- The window itself
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "Améliorations personnelles manquantes"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "Améliorations de groupe manquantes"
L["BUFF_DUTY_FAVOR_HEADER"] = "Rendre la pareille"
L["BUFF_DUTY_TARGET_HEADER"] = "Cible"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Lance le sort sur %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "S'applique à votre arme (%s)."
L["BUFF_DUTY_TOOLTIP_USE"] = "Personne dans votre groupe n'a de pierre d'âme. En utilise une sur %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Personne dans votre groupe n'a de pierre d'âme. En crée une."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Lance le sort sur %s et son groupe."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Cible %s et lance le sort."
-- A Party Buffs icon's menu: a raid buff your group is missing, and its count.
L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"] = "Manquant ou bientôt expiré : %d"
-- The menu's rows: the first asks the party or raid for the buff (its name), the second whispers the players who can cast it (their names).
L["BUFF_DUTY_OTHERS_MENU_ASK_GROUP"] = "Demander %s à votre groupe"
L["BUFF_DUTY_OTHERS_MENU_WHISPER"] = "Chuchoter à %s"
--[[
    The ask either row sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s n'a pas %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s n'ont pas %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d joueurs n'ont pas l'amélioration %s."
-- Your own chat, after the Whisper row: who was whispered, then the buff's link.
L["BUFF_DUTY_OTHERS_SENT"] = "Chuchoté à %s au sujet de %s."
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"La corvée d'améliorations est masquée jusqu'à votre prochaine connexion ou un rechargement. Pour la réafficher maintenant, faites Maj + Clic gauche sur le bouton de la minicarte. Pour la garder désactivée pour la classe %s, décochez %s sous %s dans %s."

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Bouton d'amélioration"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "En attente que %s soit à portée."
L["BUFF_KEY_DONE"] = "Plus rien à améliorer."
L["BUFF_KEY_OFF"] = "La corvée d'améliorations est désactivée."
--[[
    The Buff Duty window's last line while the Buff Button has no key: the Buff
    Button's name (BUFF_KEY), the root panel's Key Bindings header
    (OPTIONS_KEY_BINDINGS_HEADER), then the options command.
]]
L["BUFF_DUTY_KEY_HINT"] =
	"Le saviez-vous ? Attribuez une touche au %s : chaque pression lance l'amélioration suivante de cette liste. Réglez-la dans %s, via %s."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Non apprises"
L["SECTION_CONSUMABLES"] = "Consommables GtG"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Texte de la macro"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Rang dynamique"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Le rang dynamique, basé sur le niveau d'un joueur allié, ne se met à jour qu'hors combat."
L["MENU_CAST_AT_CURSOR"] = "Lancer au curseur"
L["MENU_TARGET_NEAREST_ENEMY"] = "Cibler l'ennemi le plus proche"
L["MENU_TARGET_NEAREST_FRIEND"] = "Cibler l'allié le plus proche"
L["MENU_CAST_IF_SUMMONED"] = "Lancer %s s'il est invoqué"
L["MENU_NEVER_TURN_OFF"] = "Ne jamais désactiver"
L["MENU_LEAVE_FORM_BEFORE"] = "Quitter la forme avant de lancer"
L["MENU_RIGHT_CLICK_FOR"] = "Clic droit pour %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Clic droit pour la version de groupe"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "Appliquer à toute la catégorie %s"
L["MENU_ONCE_PER_COMBAT"] = "Lancer une fois par combat"
L["MENU_ONCE_PER_TARGET"] = "Lancer une fois par cible"
L["MENU_HIDE_ERRORS"] = "Masquer les erreurs"
L["MENU_MUTE_ERRORS"] = "Couper le son des erreurs"
L["MENU_SWITCH_TO"] = "Passer en %s"
L["MENU_START_AUTO_ATTACK"] = "Lancer l'attaque automatique"
L["MENU_STOP_ATTACK"] = "Arrêter l'attaque"
L["MENU_START_AUTO_SHOT"] = "Lancer le tir automatique"
L["MENU_START_PET_ATTACK"] = "Lancer l'attaque du familier"
L["MENU_START_WAND"] = "Lancer la baguette"
L["MENU_STOP_CASTING"] = "Interrompre l'incantation"
L["MENU_STOP_CASTING_NOTE"] =
	"Utilisez Interrompre l'incantation pour les sorts qui ne peuvent pas attendre, comme les interruptions et les dissipations."
L["MENU_STOP_IF_CHANNELING"] = "Pas en canalisation"
L["MENU_STOP_IF_STEALTHED"] = "Pas en camouflage"
L["MENU_DUPLICATE"] = "Dupliquer"
L["MENU_DELETE"] = "Supprimer"
L["MENU_DELETE_USED_ONE"] = "Supprimer (utilisée sur 1 barre)"
L["MENU_DELETE_USED"] = "Supprimer (utilisée sur %d barres)"
L["MENU_DELETE_DESCRIPTION"] =
	"Supprime cette macro de vos macros, ce qui la retire de vos barres d'action, et réinitialise toutes ses options. Cliquez dessus ou faites-la glisser depuis la page pour la recréer."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Retire cette copie de la page et la supprime de vos macros, ce qui la retire de vos barres d'action."
L["MENU_DELETE_CONFIRM"] = "Supprimer %s ? Elle quitte vos barres d'action et ses options sont réinitialisées."
L["MENU_GROUP_RANK"] = "Rang"
L["MENU_GROUP_WHEN"] = "Quand"
L["MENU_GROUP_FIRST"] = "D'abord"
L["MENU_GROUP_THEN"] = "Ensuite"
L["MENU_GROUP_ERRORS"] = "Messages d'erreur"
L["MENU_GROUP_GROUPED"] = "Sorts groupés"
L["MENU_GROUP_TARGET"] = "Cible"
L["MENU_PRIORITY_1"] = "Première priorité"
L["MENU_PRIORITY_2"] = "Deuxième priorité"
L["MENU_PRIORITY_3"] = "Troisième priorité"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Les cibles que la macro essaie, dans l'ordre. Chacune est ignorée si elle ne peut pas recevoir le sort, et si aucune ne le peut, la macro le lance comme le ferait le sort seul."
L["MENU_UNIT_NONE"] = "Aucune"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Termine la liste ici."
L["MENU_UNIT_TARGET"] = "Cible"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Lance le sort sur votre cible, si elle peut le recevoir."
L["MENU_UNIT_SELF"] = "Soi-même"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"Lance le sort sur vous. Vous pouvez toujours le recevoir, donc rien après Soi-même n'est jamais essayé."
L["MENU_UNIT_PET"] = "Familier"
L["MENU_UNIT_PET_DESCRIPTION"] = "Lance le sort sur votre familier, s'il est présent et peut le recevoir."
L["MENU_UNIT_FOCUS"] = "Focalisation"
L["MENU_UNIT_FOCUS_DESCRIPTION"] =
	"Lance le sort sur votre focalisation, si vous en avez une et qu'elle peut le recevoir."
L["MENU_UNIT_TARGETS_TARGET"] = "Cible de la cible"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Lance le sort sur la cible de votre cible, comme le tank que frappe l'ennemi que vous ciblez, si elle peut le recevoir."
L["MENU_UNIT_MOUSEOVER"] = "Survol"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Lance le sort sur l'unité qui se trouve sous votre curseur, dans le monde ou sur un cadre d'unité, si elle peut le recevoir."
L["MENU_OPTIONS_COUNT"] = "%d options"
L["MENU_ENABLED"] = "Activé"
L["MENU_HIGHEST"] = "Le plus élevé"
L["MENU_HIGHEST_DESCRIPTION"] = "Lance le rang le plus élevé que vous connaissez."
L["MENU_RANK_DYNAMIC"] = "Rang dynamique"
L["MENU_FIXED_RANK_DESCRIPTION"] = "Lance toujours %s, quel que soit le niveau."
L["MENU_ANY_TIME"] = "À tout moment"
L["MENU_ANY_TIME_DESCRIPTION"] = "Lance le sort en combat comme hors combat."
L["MENU_IN_COMBAT"] = "En combat"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Lance le sort uniquement en combat. Hors combat, la macro ne fait rien, objets compris."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Lance le sort uniquement hors combat. En combat, la macro ne fait rien, objets compris."
L["MENU_EVERY_PRESS"] = "À chaque pression"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Lance le sort chaque fois que vous appuyez."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "Un clic droit lance %s. Un clic gauche lance toujours %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Permet à la macro de lancer %s. Parmi les sorts cochés ici, elle lance celui que vous avez appris en dernier, et progresse donc au fil de votre entraînement."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] =
	"Pas encore appris. Cochez-le maintenant et la macro l'utilisera dès que vous l'aurez appris."
L["MENU_PET_DESCRIPTION"] = "Tant que votre %s est présent, la macro lance %s au lieu de l'invoquer à nouveau."
L["MENU_STANCE_DESCRIPTION"] = "Passe d'abord en %s, sauf si vous y êtes déjà."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"L'utilise avant le sort. Les objets sont utilisés dans l'ordre où vous les cochez, et le numéro après chacun indique sa place."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Utiliser %s"
L["MENU_ADD_FOCUS"] = "Ajouter une copie focalisation"
L["MENU_REMOVE_FOCUS"] = "Retirer la copie focalisation"
L["MENU_FOCUS_DESCRIPTION"] =
	"Ajoute à la page une seconde macro qui lance le sort sur votre focalisation, puis sur votre cible."
L["MENU_REMOVE_FOCUS_DESCRIPTION"] = "Retire la copie focalisation de la page et supprime sa macro."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Ajoute une autre copie de cette macro à la page, avec ces options au départ, pour que vous puissiez la régler différemment."
L["MENU_MAKE_DEFAULT"] = "Définir par défaut pour %s"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"Chaque macro de la catégorie %s que vous n'avez pas réglée vous-même démarre avec les options de cette macro."
L["MENU_DEFAULT_SET"] = "Les macros de la catégorie %s démarrent désormais avec ces options."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Conditions"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Ouvre le panneau Conditions à côté de la fenêtre du Grimoire enrichi, où la macro peut lancer un autre sort quand une condition est remplie, comme Maj enfoncée ou Spé 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "Une condition utilise le clic droit. Retirez-la pour activer cette option."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Conditions"
L["CONDITIONALS_HINT"] = "Vérifiées de haut en bas ; la première remplie lance son sort."
L["CONDITIONALS_OTHERWISE"] = "Sinon"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "et"
L["CONDITIONALS_AND_MENU"] = "Ajouter une seconde condition"
L["CONDITIONALS_AND_DESCRIPTION"] =
	"Ajoute une seconde condition. La ligne ne lance son sort que si les deux sont remplies."
L["CONDITIONALS_DROP_SECOND"] = "Retirer cette condition"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "La ligne vérifie de nouveau sa première condition seule."
L["CONDITIONALS_ADD"] = "+ Ajouter une condition"
L["CONDITIONALS_ADD_DESCRIPTION"] = "Ajoute une ligne en bas. Choisissez sa condition, puis le sort qu'elle lance."
L["CONDITIONALS_ADD_LIMIT"] = "Jusqu'à %d lignes. Chacune s'ajoute au texte de la macro, limité à 255 octets."
L["CONDITIONALS_PICK_SPELL"] = "Choisir un sort"
L["CONDITIONALS_PICKING"] = "Cliquez sur un sort de la page"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Cliquez ici, puis cliquez sur un sort de la page pour le lancer dans cette ligne. Vous pouvez aussi faire glisser un sort de la page sur cet emplacement."
L["CONDITIONALS_PICK_BANNER"] = "Cliquez sur un sort pour l'utiliser. Échap ou clic droit pour annuler."
L["CONDITIONALS_CANNOT_PICK"] = "Seul un sort appris peut être lancé par une condition."
L["CONDITIONALS_EMPTY"] =
	"Aucune condition pour l'instant. Ajoutez-en une pour lancer un autre sort quand Maj est enfoncée, en combat, et plus encore."
L["CONDITIONALS_SHADOWED"] =
	"Ne lance jamais rien : la ligne %d au-dessus est remplie chaque fois que celle-ci l'est, et lance son sort en premier."
L["CONDITIONALS_KEY_DRAG"] = "Glissez un sort ici"
L["CONDITIONALS_ACTION_DROP"] = "Le lancer dans cette ligne"
L["CONDITIONALS_ACTION_PICK"] = "Choisir sur la page"
L["CONDITIONALS_ACTION_USE"] = "Utiliser dans une condition"
L["CONDITIONALS_ACTION_CANCEL"] = "Annuler la sélection"
L["CONDITIONALS_REMOVE"] = "Retirer"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Retire cette ligne."
L["CONDITIONALS_REORDER"] = "Réordonner"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Faites-la glisser sur une autre ligne pour l'y déplacer. La première ligne remplie lance son sort."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s : %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Maj enfoncée"
L["CONDITION_SHIFT_SHORT"] = "Maj"
L["CONDITION_SHIFT_DESCRIPTION"] = "Remplie quand vous maintenez Maj en appuyant sur la macro."
L["CONDITION_CTRL"] = "Ctrl enfoncée"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "Remplie quand vous maintenez Ctrl en appuyant sur la macro."
L["CONDITION_ALT"] = "Alt enfoncée"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Remplie quand vous maintenez Alt en appuyant sur la macro."
L["CONDITION_RIGHT_CLICK"] = "Clic droit"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] =
	"Remplie quand vous faites un clic droit sur la macro dans votre barre d'action."
L["CONDITION_IN_COMBAT"] = "En combat"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Remplie quand vous êtes en combat."
L["CONDITION_OUT_OF_COMBAT"] = "Hors combat"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Remplie quand vous êtes hors combat."
L["CONDITION_SPEC_1"] = "Spé 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Remplie quand votre première spécialisation de talents est active."
L["CONDITION_SPEC_2"] = "Spé 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Remplie quand votre seconde spécialisation de talents est active."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (actuelle)"
L["CONDITION_COMBAT_BLOCKED"] =
	"Indisponible quand l'option Quand est réglée sur En combat ou Hors combat. La macro ne fait déjà rien dans l'autre cas, donc cette condition serait toujours remplie, ou jamais."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"Indisponible quand Clic droit pour %s est activé dans Sorts groupés, ce qui utilise déjà le clic droit. Désactivez cette option pour utiliser le clic droit ici."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 condition"
L["SUBTEXT_CONDITIONALS"] = "%d conditions"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Séquence de sorts"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Ouvre le panneau Séquence de sorts à côté de la fenêtre du Grimoire enrichi, où chaque pression sur la macro lance le sort suivant dans l'ordre, comme Corruption, puis Malédiction d'agonie, puis Immolation."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d étapes"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Séquence de sorts"
L["CAST_SEQUENCE_HINT"] =
	"Chaque pression lance l'étape suivante. Une étape qui échoue est retentée à la pression suivante."
L["CAST_SEQUENCE_FIRST"] = "En premier"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "Le sort propre à la macro passe toujours en premier."
L["CAST_SEQUENCE_ADD"] = "+ Ajouter une étape"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Ajoute une étape à la fin. Choisissez ensuite le sort qu'elle lance."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Jusqu'à %d étapes après celle de la macro. Chacune s'ajoute au texte de la macro, limité à 255 octets."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"Seul un sort appris, à l'exception de Tir, peut être une étape d'une séquence de sorts."
L["CAST_SEQUENCE_ACTION_DROP"] = "Le lancer à cette étape"
L["CAST_SEQUENCE_ACTION_USE"] = "Utiliser dans la séquence de sorts"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Retire cette étape."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Faites-la glisser sur une autre étape pour l'y déplacer."
L["CAST_SEQUENCE_END"] = "Après la dernière étape"
L["CAST_SEQUENCE_END_LOOP"] = "Recommencer"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"La pression suivante relance le sort propre à la macro, et la séquence tourne en boucle."
L["CAST_SEQUENCE_END_STOP"] = "Arrêt (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Se termine sur NULL, un sort que personne ne connaît : les pressions suivantes ne lancent rien jusqu'à ce qu'une réinitialisation relance la séquence."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Arrêt"
L["CAST_SEQUENCE_RESET"] = "Recommencer quand"
L["CAST_SEQUENCE_RESET_NEVER"] = "Jamais"
L["CAST_SEQUENCE_RESET_TARGET"] = "La cible change"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "Reprend la séquence à sa première étape quand vous changez de cible."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Le combat se termine"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] =
	"Reprend la séquence à sa première étape quand vous quittez le combat."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Maj enfoncée"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl enfoncée"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt enfoncée"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Appuyer sur la macro en maintenant cette touche reprend la séquence au début, en lançant sa première étape."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Secondes d'inactivité"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Reprend la séquence au début quand la macro n'a pas été utilisée depuis ce délai."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Désactivé"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d secondes d'inactivité"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"S'arrête pour de bon : sans rien pour la relancer, la séquence reste sur NULL jusqu'à ce que la macro change ou que vous rechargiez votre interface. Choisissez une réinitialisation dans Recommencer quand."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	"En attente tant que l'option Lancer s'il est invoqué lance %s, car elle écrit sa propre ligne de lancement. Désactivez-la pour utiliser la séquence."
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Cliquez ici, puis cliquez sur un sort de la page pour le lancer à cette étape. Vous pouvez aussi faire glisser un sort de la page sur cet emplacement."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "Séquence en %d étapes"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Afficher tous les rangs des sorts"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Afficher les sorts groupés"
L["SETTINGS_SHOW_UNLEARNED"] = "Afficher les sorts non appris"
L["SETTINGS_MARK_ALL_PLACED"] = "Marquer tous les sorts comme placés"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Plus aucune macro de cette page ne brille, qu'elle soit sur vos barres ou non. Un sort appris plus tard brille tant que vous ne l'avez pas placé."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "Mettre en surbrillance les sorts non placés"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	"Fait briller chaque macro qui n'est pas sur vos barres. Désactivez cette option pour toutes les marquer comme placées, comme le bouton Marquer tous les sorts comme placés."
L["SORT_BY_CATEGORY"] = "Trier par catégorie"
L["SORT_BY_SCHOOL"] = "Trier par école"
L["SORT_DESCRIPTION"] =
	"Regroupe les macros de la page par catégorie, c'est-à-dire l'usage de chaque sort, comme Attaques, Soins ou Temps de recharge défensifs, ou par école, c'est-à-dire les onglets du grimoire dont elles proviennent."
L["CATEGORY_ATTACKS"] = "Attaques"
L["CATEGORY_FINISHERS"] = "Coups de grâce"
L["CATEGORY_CROWD_CONTROL"] = "Contrôle de foule"
L["CATEGORY_HYBRID"] = "Hybride"
L["CATEGORY_HEALS"] = "Soins"
L["CATEGORY_BUFFS"] = "Améliorations"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Temps de recharge offensifs"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Temps de recharge défensifs"
L["CATEGORY_SELF_BUFFS"] = "Améliorations personnelles"
L["CATEGORY_SHOCKS"] = "Horions"
L["CATEGORY_TRAPS"] = "Pièges"
L["CATEGORY_TOTEMS"] = "Totems"
L["CATEGORY_SEALS"] = "Sceaux"
L["CATEGORY_BLESSINGS"] = "Bénédictions"
L["CATEGORY_CURSES"] = "Malédictions"
L["CATEGORY_PETS"] = "Familiers"
L["CATEGORY_TELEPORTS"] = "Téléportations et portails"
L["CATEGORY_UTILITY"] = "Utilitaires"
L["CATEGORY_THREAT"] = "Provocations et menace"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Attaques de base"
L["CATEGORY_STANCES"] = "Postures"
L["CATEGORY_FORMS"] = "Formes"
L["CATEGORY_AURAS"] = "Auras"
L["CATEGORY_ASPECTS"] = "Aspects"
L["CATEGORY_RACIALS"] = "Capacités raciales"
L["CATEGORY_TRACKING"] = "Pistage"
L["CATEGORY_PROFESSIONS"] = "Métiers"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Focalisation"
L["SUBTEXT_PET"] = "Familier"
L["SUBTEXT_CURSOR"] = "Curseur"
L["SUBTEXT_STANCE"] = "Posture"
L["SUBTEXT_USE_ITEMS"] = "Objets"
L["SUBTEXT_PET_ATTACK"] = "Attaque familier"
L["SUBTEXT_DYNAMIC_RANK"] = "Rang dyn."
L["SUBTEXT_DYNAMIC_ITEM"] = "Objet dyn."
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Rang dyn., Objet dyn."
L["SUBTEXT_MAX_RANK"] = "Rang maximum"
L["SUBTEXT_TARGET_ENEMY"] = "Ennemi proche"
L["SUBTEXT_TARGET_FRIEND"] = "Allié proche"
L["SUBTEXT_TARGET_PRIORITY"] = "Cible"
L["SUBTEXT_GROUPED_SPELLS"] = "Groupés"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1x par combat"
L["SUBTEXT_ONCE_PER_TARGET"] = "1x par cible"
L["SUBTEXT_COMBAT_ONLY"] = "En combat"
L["SUBTEXT_NO_COMBAT"] = "Hors combat"
L["SUBTEXT_LEAVE_FORM"] = "Quitte la forme"
L["SUBTEXT_NO_TOGGLE"] = "Jamais désactivé"
L["SUBTEXT_WAND"] = "Baguette"
L["SUBTEXT_START_ATTACK"] = "Attaque auto"
L["SUBTEXT_STOP_ATTACK"] = "Stop attaque"
L["SUBTEXT_STOP_CASTING"] = "Interrompt"
L["SUBTEXT_STOP_IF_CHANNELING"] = "Pas en canalisation"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Pas en camouflage"
L["SUBTEXT_HIDE_ERRORS"] = "Sans erreurs"
L["SUBTEXT_MUTE_ERRORS"] = "Erreurs muettes"
L["SUBTEXT_OPTIONS_COUNT"] = "%d options"
L["SUBTEXT_TOO_LONG"] = "Trop longue"
L["SUBTEXT_LEARN_LEVEL"] = "Niveau %d"
L["SUBTEXT_TALENT"] = "Talent"
L["SUBTEXT_LEARN_RANK"] = "Apprendre %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Enseigner au familier"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Pas encore appris"
L["TOOLTIP_LEARN_LEVEL"] = "Votre maître de classe l'enseigne au niveau %d."
L["TOOLTIP_LEARN_TALENT"] = "S'apprend avec vos talents."
L["TOOLTIP_NOT_ON_BARS"] = "Pas sur vos barres d'action"
L["TOOLTIP_TOO_LONG"] = "Trop longue : %d / %d octets. Désactivez une option pour la raccourcir."
L["TOOLTIP_OPTIONS_ON"] = "Options activées : %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clic ou glisser"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Placer sur vos barres d'action"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clic droit"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Options de la macro"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Clic milieu"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Réinitialiser les options de la macro"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Réinitialiser toutes les macros de %s"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s a retrouvé ses options par défaut."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Toutes les macros de %s ont retrouvé leurs options par défaut."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Efface les options que vous avez réglées sur chaque sort de cette catégorie, pour que chacun suive de nouveau ses réglages par défaut. Les copies focalisation et les doublons sont conservés."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Réinitialiser les options que vous avez réglées sur chaque sort de %s ? Chacun suivra de nouveau ses réglages par défaut."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "Macro %s"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Les sorts de votre classe en macros à un clic."
L["TOOLTIP_KEY_CLICK"] = "Clic"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Ouvrir le Grimoire enrichi"

-- Page: Layout
L["PAGE_EMPTY"] = "Pas encore de macros. Rendez visite à votre maître de classe pour apprendre vos premiers sorts."
L["PAGE_NO_MATCHES"] = "Aucune macro ne correspond au filtre."
L["PAGE_FILTER"] = "Filtrer les sorts"
L["FILTER_ALL_SCHOOLS"] = "Toutes les écoles"
L["FILTER_ALL_CATEGORIES"] = "Toutes les catégories"
L["PAGE_MACRO_SLOTS"] = "Emplacements de macros"
L["TOOLTIP_MACRO_SLOTS"] =
	"Chaque macro que vous placez occupe un emplacement de macro. Les emplacements de personnage appartiennent à ce personnage et se remplissent en premier. Les emplacements généraux sont partagés par tous les personnages de votre compte."
L["PAGE_MACRO_GENERAL"] = "Générales"
L["PAGE_MACRO_CHARACTER"] = "Personnage"
L["PAGE_NO_MATCHES_FOR"] = 'Aucun sort ne correspond à "%s".'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Options for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "Options des %d sorts de la catégorie %s"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Active ou désactive une option pour tous les sorts de cette catégorie à la fois. Les sorts pas encore placés sur vos barres conservent le réglage pour le moment où vous les placerez."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(suite)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Et ensuite ?"
L["WHATS_NEXT_EMPTY"] = "Aucun sort à afficher."
L["WHATS_NEXT_ALL_SOURCES"] = "Toutes les sources"
L["WHATS_NEXT_ANY_LEVEL"] = "Tous les niveaux"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Disponibles maintenant"
L["WHATS_NEXT_STATUS_SOON"] = "Bientôt disponibles"
L["WHATS_NEXT_STATUS_LATER"] = "Pas encore disponibles"
L["WHATS_NEXT_STATUS_MISSING"] = "Prérequis manquants"
L["WHATS_NEXT_STATUS_TALENT"] = "Talents non pris"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Talents et runes non pris"
L["WHATS_NEXT_STATUS_KNOWN"] = "Connus"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Disponible"
L["WHATS_NEXT_SHORT_SOON"] = "Bientôt"
L["WHATS_NEXT_SHORT_LATER"] = "Pas encore"
L["WHATS_NEXT_SHORT_MISSING"] = "Requiert un autre sort"
L["WHATS_NEXT_SHORT_TALENT"] = "Non pris"
L["WHATS_NEXT_SHORT_KNOWN"] = "Connu"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Sort de départ"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Maître de classe"
L["WHATS_NEXT_SOURCE_BOOK"] = "Livre"
L["WHATS_NEXT_SOURCE_QUEST"] = "Quête"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talent"
L["WHATS_NEXT_SOURCE_RUNE"] = "Rune"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Source d'apprentissage"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Niveau requis"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Votre classe commence avec ce sort."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Votre maître de classe l'enseigne."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "Un objet l'enseigne, comme un livre trouvé en donjon ou en raid."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "Une quête de classe l'enseigne. Votre maître de classe peut vous y orienter."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Dépensez un point de talent dessus pour l'apprendre."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Gravez sa rune pour l'apprendre."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Apprenez d'abord %s."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "Rangs de %s"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Maj + Clic"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Insérer un lien dans le chat"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Trier par disponibilité"
L["WHATS_NEXT_SORT_LEVEL"] = "Trier par niveau"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Trier par disponibilité affiche d'abord les sorts que vous pouvez apprendre maintenant, et en dernier ceux que vous connaissez. Trier par niveau classe chaque sort sous le niveau auquel il s'apprend."
L["WHATS_NEXT_SHOW_KNOWN"] = "Afficher les sorts connus"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Affiche aussi les sorts que vous avez déjà appris, après les autres."
L["WHATS_NEXT_SHOW_TALENTS"] = "Afficher les talents non pris"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Afficher les talents et runes non pris"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Affiche aussi les sorts de talent que vous n'avez pas pris. Ils s'apprennent en dépensant des points de talent, pas auprès d'un maître."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Grimoire du familier"
L["PET_SPELLBOOK_EMPTY"] = "Votre familier n'a aucun sort à afficher."
L["PET_SPELLBOOK_NO_PET"] = "Aucun familier présent. Invoquez votre familier pour voir ses sorts."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Capacités"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Passif"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Incantation auto activée"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Incantation auto désactivée"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Familier : et ensuite ?"
L["WHATS_NEXT_PET_EMPTY"] = "Aucune capacité de familier à afficher."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%1$s, %3$s de niveau %2$d"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Points de dressage : %d sur %d"
L["WHATS_NEXT_PET_NO_PET"] = "Aucun familier présent : affichage de ce que vous avez appris avec Dressage des bêtes."
L["WHATS_NEXT_PET_NO_DEMON"] = "Aucun démon présent : invoquez-en un pour voir ce qu'il connaît déjà."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Prêtes à enseigner"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Capacités d'autres familles"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Prête à enseigner"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Autre famille"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Maître des familiers"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Apprivoisement"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Maître des démons"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Niveau de familier requis"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Points de dressage"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Un maître des familiers vous l'enseigne. Enseignez-la ensuite à votre familier avec Dressage des bêtes."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Apprivoisez une bête qui la connaît et combattez à ses côtés jusqu'à l'apprendre. Enseignez-la ensuite avec Dressage des bêtes à tout familier capable de l'apprendre."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] =
	"Vous la connaissez. Enseignez-la à votre familier avec Dressage des bêtes."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Achetez son grimoire auprès d'un maître des démons, puis utilisez-le pendant que le démon qui l'apprend est invoqué."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimoire"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Son grimoire est dans vos sacs. Utilisez-le pendant que ce démon est invoqué."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Votre familier ne peut pas l'apprendre."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Bêtes qui la connaissent"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s (%s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "Et %d de plus."

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Trier par disponibilité affiche d'abord les capacités que votre familier peut apprendre maintenant, et en dernier celles qu'il connaît. Trier par niveau classe chaque capacité sous le niveau de familier requis."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Afficher les capacités connues"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Affiche aussi les capacités que votre familier connaît déjà, après les autres. Un chasseur sans familier présent voit celles qu'il a apprises."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Afficher les capacités d'autres familles"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Affiche aussi les capacités que votre familier ne peut pas apprendre, comme Rôder du félin pour un loup, ou celles d'un autre démon."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Raccourcis clavier"
L["OPTIONS_KEY_SET"] = "Définir la touche"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "Ouvre la liste des raccourcis clavier du jeu, où Good to Go a sa propre section."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Ouvre et ferme le Grimoire enrichi. Il a aussi son propre onglet dans votre grimoire."
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Lance la prochaine amélioration proposée par votre fenêtre de corvée d'améliorations, une par pression, hors combat. Les améliorations d'arme se lancent toujours d'un clic sur la fenêtre. Pour l'activer depuis une macro, utilisez %s."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Infobulles des rangs de sorts"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"L'infobulle de chaque capacité liste ses rangs et le niveau requis pour chacun : en blanc les rangs que vous connaissez, en vert ceux que vous pourriez apprendre dès maintenant, et en gris ceux qui restent à venir. C'est un moyen rapide de vérifier que vous utilisez votre meilleur rang, pour toujours jouer à votre meilleur niveau. Les rangs ne s'affichent pas en combat, pour que vos infobulles restent courtes quand ça compte."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Activer les infobulles des rangs de sorts"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Ajoute les rangs de chaque capacité à son infobulle sur vos barres d'action, dans le grimoire du jeu et dans d'autres add-ons. Désactivé, ces infobulles restent telles que le jeu les affiche. La fenêtre du Grimoire enrichi affiche les rangs dans tous les cas."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Supprimer les macros"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Supprime les macros créées par le Grimoire enrichi, ce qui les retire aussi de vos barres d'action. Vos propres macros ne sont jamais touchées, et la page recrée chacune d'elles quand vous cliquez dessus ou la faites glisser."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Supprimer les macros du personnage"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Supprime les macros du Grimoire enrichi de l'onglet de macros de ce personnage. Vos autres personnages gardent les leurs jusqu'à ce que vous fassiez de même sur eux."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Supprimer toutes les macros du Grimoire enrichi sur ce personnage ? Elles sont aussi retirées de vos barres d'action."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Supprimer les macros générales"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Supprime les macros du Grimoire enrichi de l'onglet Macros générales, partagé par tous les personnages de votre compte : vos autres personnages y perdent donc aussi les leurs."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Supprimer toutes les macros générales du Grimoire enrichi ? Tous les personnages de votre compte les perdent, et elles sont aussi retirées de vos barres d'action."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Liste une macro pour chaque rang inférieur que vous connaissez d'un sort, après celle du sort lui-même, chacune lançant toujours son rang."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Liste chaque sort que vous connaissez d'un groupe de sorts, comme Purification et Épuration. Désactivé, seul le dernier appris est listé, mais les macros des autres continuent de se mettre à jour."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Liste les sorts de classe que vous n'avez pas encore appris dans une section Non apprises, pour placer leurs macros à l'avance."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Place le sort là où pointe votre curseur, sans cercle de ciblage."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lance le rang le plus élevé que permet le niveau du joueur allié."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Interrompt d'abord ce que vous incantez, pour que ce sort parte aussitôt."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Arrête d'abord votre attaque automatique de mêlée."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Ne fait rien pendant que vous canalisez un sort, donc un appui ne rompt jamais la canalisation."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Ne fait rien pendant que vous êtes camouflé, donc un appui ne rompt jamais Camouflage ou Rôder."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Quitte d'abord votre forme actuelle, pour que le sort puisse être lancé."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Cible d'abord l'ennemi le plus proche quand vous n'avez aucun ennemi vivant en cible."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Cible d'abord l'allié le plus proche quand vous n'avez aucun allié vivant en cible."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Envoie aussi votre familier attaquer votre cible."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Lance votre attaque automatique de mêlée après l'incantation."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Lance Tir automatique ou votre baguette après l'incantation."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lance une fois, puis plus avant que votre cible change."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lance une fois, puis plus avant la fin du combat ou un changement de cible."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Garde la forme ou l'aspect actif quand vous appuyez de nouveau sur la macro, au lieu de le désactiver."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Efface le texte d'erreur rouge que la macro laisse à l'écran."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Coupe le son d'erreur pendant que la macro s'exécute."
L["KIND_ENEMY"] = "Sorts offensifs"
L["KIND_ENEMY_DESCRIPTION"] = "Les sorts lancés sur un ennemi, comme vos attaques et affaiblissements."
L["KIND_FRIENDLY"] = "Sorts amicaux"
L["KIND_FRIENDLY_DESCRIPTION"] = "Les sorts lancés sur un allié, comme vos soins."
L["KIND_BUFF"] = "Améliorations"
L["KIND_BUFF_DESCRIPTION"] = "Les sorts qui donnent à un allié une amélioration durable."
L["KIND_RESURRECT"] = "Résurrections"
L["KIND_RESURRECT_DESCRIPTION"] = "Les sorts lancés sur un allié mort pour le ramener à la vie."
L["KIND_ANYONE"] = "Sorts pour allié ou ennemi"
L["KIND_ANYONE_DESCRIPTION"] = "Les sorts qui peuvent viser un allié ou un ennemi."
L["KIND_GROUND"] = "Sorts ciblés au sol"
L["KIND_GROUND_DESCRIPTION"] = "Les sorts que vous placez au sol."
L["KIND_FORM"] = "Formes, postures et aspects"
L["KIND_FORM_DESCRIPTION"] = "Les sorts qui restent actifs jusqu'à ce que vous les coupiez ou en changiez."
L["KIND_SELF"] = "Sorts personnels et de zone"
L["KIND_SELF_DESCRIPTION"] = "Les sorts sans cible, lancés sur vous ou autour de vous."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Afficher/masquer le Grimoire enrichi"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Par mesure de sécurité, la liste des raccourcis clavier ne peut pas être ouverte en combat."
L["KEY_BINDINGS_LOCATION"] = "Ouvrez le menu du jeu, puis %s, puis %s, et cherchez la section Good to Go."
L["ERROR_MACRO_SLOTS_FULL"] =
	"Aucun emplacement de macro libre. Supprimez une macro dans /macro pour faire de la place."
L["ERROR_MACRO_WINDOW_OPEN"] = "Fermez d'abord la fenêtre des macros."
L["CHAT_MACROS_DELETED"] = "Macros supprimées : %d"
L["CHAT_MACRO_TOO_LONG"] =
	'La macro "%s" fait %d octets avec ses options activées, au-delà des %d qu\'une macro peut contenir. Désactivez une option pour la raccourcir.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'La macro "%s" fait %d octets, au-delà des %d qu\'une macro peut contenir : sa dernière ligne est donc coupée.'
