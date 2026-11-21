local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "esES")
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
	"Versión %s. Los ajustes (incluida la opción de desactivar este mensaje) están en Opciones > Accesorios > Good to Go. ¿Te gusta este addon? Cuéntaselo a un amigo, márcalo como favorito en CurseForge o dale una estrella en GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Ayuda a Good to Go a subir de nivel"
L["OPTIONS_LEVEL_UP_THANKS"] = "¡Gracias por elegir Good to Go!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Venda"
L["MACRO_EXPLOSIVES"] = "- Explosivos"
L["MACRO_FEED_PET"] = "- Alim. mascota"
L["MACRO_FOOD"] = "- Comida"
L["MACRO_HEALTH_POTION"] = "- Poc. Salud"
L["MACRO_HEALTHSTONE"] = "- Piedra"
L["MACRO_MANA_GEM"] = "- Gema de maná"
L["MACRO_MANA_POTION"] = "- Poc. Maná"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Piedra de alma"
L["MACRO_WATER"] = "- Agua"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names or spells in a sentence, such as a buff ask or a level-up line ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s y %s"
-- Joins the last one to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s y %s"
-- Joins two choices in a sentence, such as the buffs an ask to your target names ("[Fortitude] or [Shadow Protection]").
L["LIST_OR_PAIR_FORMAT"] = "%s o %s"
-- Joins the last choice to the ones before it, already joined with LIST_SEPARATOR ("[Fortitude], [Shadow Protection], or [Divine Spirit]").
L["LIST_OR_LAST_FORMAT"] = "%s o %s"
-- Closes a hover list cut short: %d is how many more it holds, such as the Restock List's Short Items or the beasts that know a pet ability.
L["LIST_MORE_SENTENCE"] = "Y %d más."
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

L["DIET_BREAD"] = "Pan"
L["DIET_CHEESE"] = "Queso"
L["DIET_FISH"] = "Pescado"
L["DIET_FRUIT"] = "Fruta"
L["DIET_FUNGUS"] = "Hongo"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"¡Parece que has encontrado un error! %s (%s) no se puede usar en %s > %s (%s). Por favor, avísanos para que podamos corregirlo. ¡Gracias! %s"
L["MESSAGE_NO_ITEM"] = "No hay ningún objeto adecuado de tipo %s en tus bolsas."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"No se han podido crear algunas macros de Good to Go porque tus espacios de macros están llenos. Libera un espacio borrando macros que ya no uses, o desactiva las macros de Good to Go que no necesites en Opciones > Accesorios > Good to Go > Macros de consumibles."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Tus macros están listas. Escribe %s, abre la pestaña %s y arrastra - Comida, - Agua y las demás a tus barras de acción."
-- The mini-map button's Right-Click, or the menu's Ignore row. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s está ahora en la lista de ignorados de este personaje."
-- A click on an item in the mini-map menu's Ignore List. %s is the item's link.
L["MESSAGE_IGNORE_REMOVED"] = "%s ya no está en la lista de ignorados de este personaje."
-- The mini-map button's Middle-Click: %d is how many items it took off the list, exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "Se ha quitado 1 objeto de la lista de ignorados de este personaje."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "Se han quitado %d objetos de la lista de ignorados de este personaje."

L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la interfaz de opciones no se puede abrir durante el combate."

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

L["READINESS_TITLE"] = "Informe de preparación"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Beneficios que faltan:"
L["READINESS_EXPIRING"] = "A punto de expirar:"
L["READINESS_MISSING_ITEMS"] = "Objetos que faltan:"
L["READINESS_DAMAGED_GEAR"] = "Equipo dañado:"
L["READINESS_CHARACTER"] = "Personaje:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate:"

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
L["READINESS_FLASK"] = "Frasco o 2x elixires"
L["READINESS_PET_FORMAT"] = "%s (mascota)"
L["READINESS_SCROLLS"] = "Pergaminos"
-- The switch for the Scrolls line.
L["FEATURE_SCROLL_BUFFS"] = "Beneficios de pergaminos"
L["READINESS_SOULSTONE"] = "Piedra de alma inactiva"
L["READINESS_HEALTHSTONE"] = "Piedra de salud"
L["READINESS_MANA_GEM"] = "Gema de maná"
L["READINESS_HEALING_POTION"] = "Poción de curación"
L["READINESS_MANA_POTION"] = "Poción de maná"
L["READINESS_BANDAGES"] = "Vendas"
L["READINESS_PVP_ON"] = "JcJ activado"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s menos de 1 min"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto de talento sin gastar"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d puntos de talento sin gastar"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Actualmente no tienes ninguna comida útil para tu mascota."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Actualmente no conoces %s, %s, %s o %s."
L["TIP_NO_HAND_POISON"] = "Te has quedado sin el veneno elegido para esta arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Actualmente no conoces %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "No tienes %s en las bolsas. Haz clic derecho en %s para conjurar más."
L["TIP_EMPTY_CREATE"] = "No tienes %s en las bolsas. Haz clic derecho en %s para crear una."

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
L["MINIMAP_BEST_FOOD"] = "Comida actual"

-- The Ignore List block: its heading, the row that ignores the current food, and the row that clears the list.
L["MINIMAP_IGNORE_LIST"] = "Lista de ignorados"
L["MENU_IGNORE"] = "Ignorar"
L["MENU_CLEAR_IGNORE"] = "Borrar lista de ignorados"

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
L["MINIMAP_RESTOCKER_STOCKED"] = "¡Felicidades, lo tienes todo abastecido!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Tu lista está vacía."
L["MINIMAP_RESTOCKER_NOTHING_LOW"] = "Nada escasea ni está agotado."

--[[
    The mini-map menu's Restocker block: a line saying what the list is
    for, and the click its Open row names.
    "Your list" in the description and in MINIMAP_RESTOCKER_EMPTY is this
    list. The Options row is always the menu's last, its click on its right.
]]
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra y guarda en el banco los objetos de tu lista."
L["MENU_CLICK_SHIFT_RIGHT"] = "Mayús + Clic derecho"
L["MENU_OPTIONS"] = "Opciones de GtG"
L["MENU_CLICK_SHIFT_LEFT"] = "Mayús + Clic izquierdo"
L["MENU_CLICK_SHIFT_MIDDLE"] = "Mayús + Clic central"
-- The Restocker block's Open row hover while the Restocker is off.
L["MENU_RESTOCKER_OPEN_OFF_DESCRIPTION"] = "Abre tu Lista de reabastecimiento. Activa el Restocker para usarla."

-- Buff Duty's block in the menu while its close button has hidden it: the word on its right, and the note under it.
L["MENU_BUFF_DUTY_PAUSED"] = "En pausa"
L["MENU_BUFF_DUTY_PAUSED_NOTE"] = "Oculto hasta que te unas a un grupo, vuelvas a conectarte o recargues."

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
L["NOTE_MACRO_FEED_PET"] = "Macro de Alim. mascota"
L["NOTE_MACRO_FOOD_WATER"] = "Macros de Comida y Agua"
L["NOTE_MACRO_MANA_GEM"] = "Macro de Gema de maná"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro de Piedra"
L["NOTE_MACRO_SOULSTONE"] = "Macro de Piedra de alma"
L["NOTE_MACRO_POISONS"] = "Macro de Venenos"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Llamar, alimentar o revivir"
L["NOTE_PET_MEND_CLICK"] = "Clic derecho o en combate"
L["NOTE_HOLD_SHIFT"] = "Mantén Mayús"
L["NOTE_PET_FORCE_REVIVE"] = "Forzar revivir"
L["NOTE_HOLD_CONTROL"] = "Mantén Ctrl"
L["NOTE_PET_DISMISS"] = "Retirar"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down (NOTE_CONJURE_LOWER_RANK, NOTE_CREATE_LOWER_RANK), since the bags
    hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Conjurar"
L["NOTE_CREATE"] = "Crear"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Otro clic derecho"
L["NOTE_CONJURE_LOWER_RANK"] = "Conjurar rango inferior"
L["NOTE_CREATE_LOWER_RANK"] = "Crear rango inferior"
L["NOTE_MAGE_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para conjurar lo adecuado a su nivel."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para crear una adecuada a su nivel."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Ventana de Venenos"
L["NOTE_POISONS_REPLACED"] = "Reemplaza automáticamente los venenos anteriores."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map menu. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Venda"
L["LABEL_EXPLOSIVE"] = "Explosivo"
L["LABEL_FOOD"] = "Comida"
L["LABEL_HEALTH_POTION"] = "Poción de salud"
L["LABEL_HEALTHSTONE"] = "Piedra de salud"
L["LABEL_MANA_GEM"] = "Gema de maná"
L["LABEL_MANA_POTION"] = "Poción de maná"
L["LABEL_PET_FOOD"] = "Comida de mascota"
L["LABEL_POISON"] = "Veneno"
L["LABEL_SOULSTONE"] = "Piedra de alma"
L["LABEL_WATER"] = "Agua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map menu: the Toggle and Open rows, and the button clicks rows name on their right.

L["MENU_TOGGLE"] = "Alternar"
L["MENU_OPEN"] = "Abrir"
L["MENU_CLICK_LEFT"] = "Clic izquierdo"
L["MENU_CLICK_RIGHT"] = "Clic derecho"
L["MENU_CLICK_MIDDLE"] = "Clic central"

-- The words on the right of a block's title.
L["MENU_ON"] = "Activado"
L["MENU_OFF"] = "Desactivado"

-- The note after a list cut short at eight rows: %d is how many more there are, so it is never one.
L["MENU_MORE"] = "%d más"

--[[
    More Features, the row that opens the flyout of every feature without a
    block of its own, and its right side: how many of those are on and off,
    side by side ("4 On, 3 Off"), so the On count can take its own color.
]]
L["MENU_MORE_FEATURES"] = "Más funciones"
L["MENU_FEATURE_COUNT_ON"] = "%d activadas"
L["MENU_FEATURE_COUNT_OFF"] = "%d desactivadas"

-- The mini-map menu's Enhanced Spellbook block, above the class macros: a line saying what it's for, then Open (MENU_OPEN),
-- as Shift + Left-Click on the button does. MENU_OPEN_SPELLBOOK is the click line on the spellbook tab's tooltip.
L["MENU_SPELLBOOK_DESCRIPTION"] = "Macros de mouseover para cada hechizo, creadas con un clic."
L["MENU_OPEN_SPELLBOOK"] = "Abrir el libro de hechizos mejorado"

-- The body of Buff Duty's Toggle tooltip in the mini-map menu, under the Enable option's name. %s is the client's name for the player's class.
L["MENU_BUFF_DUTY_TOGGLE_CLASS_DESCRIPTION"] =
	"Activa o desactiva el Turno de beneficios mientras juegas como %s. Tus otras clases mantienen su propio ajuste."

-- The row opening the class's macro notes, in the class color. %s is the client's name for the player's class.
L["MENU_CLASS_MACROS"] = "Macros de %s"

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
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "Cuando no estás en un grupo o banda."
L["GROUP_CONTEXT_PARTY"] = "Grupo"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] = "Cuando estás en un grupo, también en una mazmorra del buscador de grupos."
L["GROUP_CONTEXT_RAID"] = "Banda"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] =
	"Cuando estás en una banda. La banda de un campo de batalla cuenta como Campo de batalla."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Campo de batalla"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] = "Cuando estás en un campo de batalla o una arena, sea cual sea tu grupo."

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
	'Elige en qué niveles tu macro de Comida ofrece "%s": a cualquier nivel, solo mientras subes de nivel o solo al nivel máximo. Las casillas de abajo eligen en qué grupos.'
L["OPTIONS_MODE_CAPTION"] = "Cuándo usar"
L["OPTIONS_GROUPS_NONE"] = "No hay nada marcado, así que esto nunca se usa."
L["LEVEL_FILTER_ANY"] = "A cualquier nivel"
L["LEVEL_FILTER_LEVELING"] = "Subiendo de nivel"
L["LEVEL_FILTER_MAX_LEVEL"] = "Al nivel máximo"

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
L["INVENTORY_REPORT_TITLE"] = "Informe de inventario"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Bolsas %s, Banco %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Bolsas %s"
L["INVENTORY_REPORT_BANK"] = "Banco %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Total %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macros que se actualizan solas con tu mejor comida, agua, pociones y piedras de salud, una lista de reabastecimiento que compra y guarda en el banco componentes y munición, beneficios que faltan con un clic, avisos de rangos de hechizo bajos y macros de mouseover para cada hechizo."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Libro de hechizos mejorado"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Macros al pasar el ratón, en el cursor y sobre ti mismo para cada hechizo de clase, creadas con un clic desde una nueva pestaña del libro de hechizos y sin sintaxis de macros. Se actualizan al subir de nivel, entrenar y cambiar de especialización. Con clic derecho añades foco, detener lanzamiento, ataque automático, ataque de mascota o abalorios."
L["SPELLBOOK_IS_OFF"] =
	"El Libro de hechizos mejorado está desactivado. Actívalo en Opciones > Accesorios > Good to Go > Libro de hechizos mejorado."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Muestra un mensaje de bienvenida en el chat al iniciar sesión."

-- Mini-map Button
L["OPTIONS_MINIMAP_BUTTON"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Muestra el botón del minimapa."

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
L["OPTIONS_FEATURES_HEADER"] = "Funciones"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Muestra una ventana con todos los miembros de tu grupo a los que les falta un beneficio que puedes dar. Haz clic en un icono para lanzarlo."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Mantiene tus bolsas abastecidas según tu lista de reabastecimiento, comprando a los mercaderes y moviendo objetos al banco y desde él, y te avisa cuando te quedas corto. Al desactivarlo se detiene todo, incluida la ventana de la lista de reabastecimiento. Tus listas siguen guardadas."
L["SWITCH_SPELLBOOK"] = "Activar Libro de hechizos mejorado"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Añade a tu libro de hechizos una pestaña que crea macros al pasar el ratón, en el cursor y sobre ti mismo para tus hechizos, y las mantiene al día a medida que subes de nivel y entrenas. Al desactivarlo se oculta la pestaña y se detienen las actualizaciones. Nunca borra una macro; eso lo hacen los botones Borrar macros de la página Libro de hechizos mejorado."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"¿Desactivar el Libro de hechizos mejorado? Su pestaña desaparece de tu libro de hechizos y las macros que creó dejan de actualizarse al subir de nivel y entrenar. Esto no las borra: se quedan en tus barras de acción tal como están ahora."
L["SWITCH_MACROS"] = "Activar Macros de consumibles"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Mantiene tus macros de Comida, Agua, Pociones y demás consumibles apuntando al mejor objeto de tus bolsas a medida que estas cambian. Al desactivarlo se detienen las actualizaciones y cada macro se queda como estaba. Nunca borra una macro; eso lo hace desmarcarla en Qué macros crear, en la página Macros de consumibles."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"¿Desactivar Macros de consumibles? Tus macros dejan de actualizarse cuando cambian tus bolsas, así que un botón puede seguir buscando un objeto que ya has gastado. Esto no las borra: se quedan en tus barras de acción tal como están ahora."
L["SWITCH_INVENTORY_REPORT"] = "Activar Informe de inventario"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Añade a la descripción de un objeto cuántos tienes en las bolsas, en el banco y en tus otros personajes de este reino. Desactívalo si otro addon ya muestra estos recuentos."
L["SWITCH_READINESS_REPORT"] = "Activar Informe de preparación"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Cuando empieza una comprobación de quiénes están listos, muestra una lista privada de lo que aún tienes que arreglar, como un beneficio que falta, una poción o equipo dañado. No dice nada si estás listo."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Activar Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Ejemplo"

-- A Reset button, which puts the settings it sits under, or the whisper box beside it, back to their defaults.
L["OPTIONS_RESET"] = "Restablecer"
L["OPTIONS_FEATURE_OFF_STATUS"] =
	"La función %s está desactivada, así que estos ajustes no se usan. Su interruptor está en la página %s."

--[[
    The whisper composer around every whisper a player words themselves, on the Buff Duty and Rank Watch
    panels: the language they go out in, the caption and Reset button (OPTIONS_RESET) beside each box, the
    tooltip on the marker and the "// GtG" either side of it, the line shown when a whisper is too long, and the
    test button.
    The whispers' default text lives in Data/Message-Languages.lua, not here.
]]
L["SEND_MESSAGES_IN"] = "Enviar mensajes en"
L["SEND_MESSAGES_IN_DESCRIPTION"] =
	"Elige el idioma en el que Good to Go escribe cuando susurra a otros jugadores. Al elegir otro idioma se pone su texto predeterminado, salvo que hayas escrito el tuyo."
L["WHISPER_TEXT"] = "Mensaje de susurro"
L["WHISPER_TEXT_RESET_DESCRIPTION"] = "Devuelve este susurro al texto predeterminado en el idioma en el que envías."
L["WHISPER_SIGN_OFF_DESCRIPTION"] =
	"Se añade a cada susurro que envía Good to Go, para que otros jugadores sepan que viene de un addon."
L["WHISPER_TOO_LONG"] = "Demasiado largo, así que se enviará el texto predeterminado."
L["WHISPER_TEST"] = "Enviarme una prueba"
L["WHISPER_TEST_DESCRIPTION"] = "Te susurra el ejemplo para que lo veas exactamente como lo verán otros jugadores."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este addon."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre tu lista de reabastecimiento."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Este addon lo han creado jugadores que aman este juego y quieren que sea lo más divertido posible para todos. Nunca pediremos donaciones. La verdadera satisfacción es saber que nuestro trabajo hace que el juego sea un poco mejor para ti. Si es así, ¡nos encantaría saberlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Estas son algunas formas en que puedes ayudarnos a llegar a más jugadores."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Comparte tu opinión: ¿Has encontrado un error o tienes una idea? Dínoslo en Discord. Tus comentarios nos ayudan a mejorar el addon, y las pull requests siempre son bienvenidas."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Cuéntaselo a un amigo: ¿Conoces a alguien a quien le podría gustar este addon? Háblale de él. El boca a boca ayuda a que más jugadores descubran grandes addons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorito en CurseForge: Abre el enlace de CurseForge de abajo, inicia sesión y haz clic en la estrella bajo el botón Download. Los favoritos ayudan a que más jugadores descubran el addon."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Dale una estrella en GitHub: Abre el enlace de GitHub de abajo, inicia sesión y haz clic en Star, arriba a la derecha. Las estrellas ayudan al proyecto a optar a más herramientas gratuitas para desarrolladores."

L["OPTIONS_FEEDBACK"] = "Comentarios y soporte"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Enlaces de comentarios y soporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Para copiar un enlace, haz clic en su casilla y pulsa Ctrl+A y Ctrl+C."
L["OPTIONS_VERSION"] = "Versión %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's headerless Enable Consumable Macros toggle; Enable
    Macro Names on Buttons sits under Action Bars at the foot of the page.
]]
L["TAB_CONSUMABLE_MACROS"] = "Macros de consumibles"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go crea una macro por consumible y la mantiene al día conforme cambian tus bolsas, de modo que el botón de tu barra siempre busca el mejor objeto que llevas encima. Elige abajo qué macros crear; los ajustes de cada una están en su propia página, debajo de esta."

-- Action Bars, at the foot of the Consumable Macros page: Macro Names on Buttons
L["OPTIONS_ACTION_BARS_HEADER"] = "Barras de acción"
L["OPTIONS_MACRO_NAMES"] = "Activar nombres de macro en los botones"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Muestra el nombre de la macro en los botones de tu barra de acción, un texto que Good to Go oculta por defecto."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Qué macros crear"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Elige qué macros crea y mantiene Good to Go. Al desactivar una, también se elimina. Están en la pestaña Macros generales de la ventana de macros, listas para arrastrarlas a tus barras de acción."
L["OPTIONS_MACROS_WINDOW"] = "Ventana de macros"
L["OPTIONS_OPEN"] = "Abrir"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Abre la ventana de macros del juego en su pestaña Macros generales, donde están estas macros."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea y mantiene esta macro, y la elimina al desmarcar la casilla."

--[[
    Food & Drinks, the page under Consumable Macros (Options-Food-Drinks.lua).
    OPTIONS_FOOD_WATER_HEADER is its label in the settings tree and the end of
    its title. Its sections: Which Food Comes First (Use Conjured Food & Water
    First, Use Restock List Food & Water Last, Eat Buff Food When Already Well
    Fed), then the class and race options that change how you eat and drink.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Comida y bebida"
L["OPTIONS_FOOD_DRINKS_DESCRIPTION"] =
	"Tus macros de Comida y Agua comen y beben lo mejor que llevas. Estas opciones cambian qué cuenta como lo mejor y cómo comes y bebes. La comida con beneficio y los pergaminos, que se usan por sus beneficios, están en la página Beneficios propios del Turno de beneficios."
L["OPTIONS_FOOD_ORDER_HEADER"] = "Qué comida va primero"
L["OPTIONS_FOOD_ORDER_DESCRIPTION"] =
	"Entre dos comidas o bebidas, tus macros usan la que más restaura. Estas opciones cambian ese orden."

--[[
    Eat Buff Food When Already Well Fed, last under Which Food Comes First,
    and in Buff Duty's Buff Food flyout. %s in its hover text is the client's
    name for the Well Fed buff.
]]
L["OPTIONS_BUFF_FOOD_WHEN_FED"] = "Comer comida con beneficio aunque ya estés Bien alimentado"
L["OPTIONS_BUFF_FOOD_AS_FOOD_DESCRIPTION_FORMAT"] =
	'Tus macros de Comida y Agua tratan la comida con beneficio como cualquier otra comida y comen lo que más restaure. Desactivado, la guarda para que el Turno de beneficios te la ofrezca cuando necesites "%s", salvo que sea lo único que llevas.'

-- The scroll types on Buff Duty's Self-Buffs page. The other five are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_TYPES"] = "Incluir tipos de pergaminos en la comprobación"
L["OPTIONS_SCROLL_PROTECTION"] = "Protección"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Incluye %s al comprobar los beneficios que faltan."

-- Use Conjured Food & Water First, the first option under Which Food Comes First.
L["OPTIONS_CONJURED_FIRST"] = "Usar primero la comida y el agua mágicas"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	"Tus macros de Comida y Agua usan la comida y el agua mágicas antes que cualquier otra cosa, aunque algo de tus bolsas restaure más, ya que no cuestan nada y desaparecen poco después de cerrar sesión."
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Elige en qué niveles la comida y el agua mágicas van primero: a cualquier nivel, solo mientras subes de nivel o solo al nivel máximo. Las casillas de abajo eligen en qué grupos."

-- Use Restock List Food & Water Last, the second option under Which Food Comes First.
L["OPTIONS_RESTOCK_LAST"] = "Usar al final la comida y el agua de la lista de reabastecimiento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Entre dos comidas o bebidas que restauran la misma cantidad, tus macros de Comida y Agua usan la que no está en tu lista de reabastecimiento, y guardan para más tarde lo que compra el Restocker."

--[[
    The pages under Consumable Macros for the smaller macro families
    (Options-Potions-Mana-Gems.lua and its neighbors): each TAB_* is its label in the settings tree
    and the end of its title, and each *_DESCRIPTION the intro under it.
    Explosives takes OPTIONS_EXPLOSIVES_HEADER.
]]
L["TAB_POTIONS_MANA_GEMS"] = "Pociones y gemas de maná"
L["OPTIONS_POTIONS_MANA_GEMS_DESCRIPTION"] =
	"Tus macros de Poción de salud, Poción de maná y Gema de maná usan lo mejor que llevas, con alternativas para cuando se acabe."
L["TAB_BANDAGES"] = "Vendas"
L["OPTIONS_BANDAGES_DESCRIPTION"] =
	"Tu macro de Venda usa la venda que más cura de entre las que permite tu habilidad de Primeros auxilios."
-- The Bandages page's line under its description, pointing at the settings that change the Bandage macro.
L["OPTIONS_BANDAGES_SUMMARY"] =
	"Para dejar una venda fuera de la macro, añádela a la lista de ignorados. La opción de Regeneración rápida de los trols está en la página Comida y bebida."
L["TAB_HEALTHSTONE"] = "Piedra de salud"
L["OPTIONS_HEALTHSTONE_DESCRIPTION"] =
	"Tu macro de Piedra de salud usa tu mejor piedra de salud, con alternativas. Con un brujo, el clic derecho crea una y el clic central crea un Pozo de almas, si lo conoces."

-- Potions & Healthstones, the first section on Potions & Mana Gems.
L["OPTIONS_POTIONS_HEADER"] = "Pociones y Piedras de salud"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Las macros no pueden cambiar durante el combate (es una restricción de Blizzard), por lo que cada macro de Poción y Piedra de salud se crea previamente con tu mejor objeto más hasta dos alternativas. En combates largos, el icono y la descripción pueden quedar obsoletos y mostrar un objeto equivocado, pero al hacer clic en la macro siempre se usará el mejor objeto que realmente tengas en tus bolsas."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usar comida y agua en las macros de Poción fuera de combate"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuera de combate, tu macro de Poción de salud come tu mejor comida y tu macro de Poción de maná bebe tu mejor agua. En combate, usan tus pociones como siempre. La comida de mascota y los hechizos de conjuración siguen en las macros de Comida y Agua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combinar Piedras de salud en la macro de Poción de salud"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Añade tu mejor Piedra de salud al final de la macro de Poción de salud, para que al presionar una vez se use una poción y una Piedra de salud."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemas de maná y runas"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s y algunos otros objetos de maná comparten tiempo de reutilización con las Gemas de maná. Las runas cuestan salud al usarlas, así que la macro de Gema de maná los deja fuera a todos a menos que los añadas."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Añadir runas y otros objetos de maná a la macro de Gema de maná"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Clasifica %s, %s y cualquier otro objeto de maná que comparta tiempo de reutilización con las Gemas de maná, junto a tus gemas, para que la macro de Gema de maná use uno de ellos cuando sea tu mejor opción o cuando te quedes sin gemas."

-- Refresh Pet Food Under, closing the Hunter section on Class Macros: "Refresh Under", as Buff Duty names its timing.
L["OPTIONS_REAPPLY"] = "Renovar comida de mascota con menos de"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera expirado el beneficio de comida de tu mascota cuando le quede menos tiempo que tu umbral, para que tu macro de Comida ofrezca uno nuevo antes del combate."
--[[
    Threshold dropdown, beside the Refresh Pet Food Under toggle, whose label
    carries the "under", so the values are plain durations.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto puede acercarse un beneficio a expirar antes de que tus macros ofrezcan uno nuevo."
L["REAPPLY_THRESHOLD_ONE"] = "1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "%d minutos"

-- Pet Food Buffs, in the Hunter section on Class Macros. OPTIONS_PET_HEADER names the feature in its When to Use hover text.
L["OPTIONS_PET_HEADER"] = "Beneficios de comida de mascota"
-- The summary line under Class Macros' Hunter header.
L["OPTIONS_CLASS_MACROS_HUNTER_SUMMARY"] = "Mantén a tu mascota bien alimentada con tu macro de Comida."
L["OPTIONS_USE_PET_BUFFS"] = "Usar beneficios de comida de mascota"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Añade comida de mascota a tu macro de Comida cuando a tu mascota le falta el beneficio "%s", excepto en arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Incluir tipos de comida de mascota en la comprobación"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosivos"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"La opción @player omite la retícula de selección y detona el explosivo justo a tus pies. Ideal cuando tu objetivo está a distancia cuerpo a cuerpo. Tu otro clic lanza el explosivo como siempre."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Asignación de clics"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] = "Elige qué clic lanza el explosivo y cuál lo detona a tus pies."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic izquierdo @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic izquierdo Lanzar"

--[[
    Class Macros panel (Options-Class-Macros.lua), nested under Consumable Macros. TAB_CLASS_MACROS
    is its label in the settings tree and the end of its title; OPTIONS_CLASS_MACROS_DESCRIPTION is the
    intro beneath it. The class and race headers below also head Food & Drinks' racial sections.
]]
L["TAB_CLASS_MACROS"] = "Macros de clase"
L["OPTIONS_CLASS_MACROS_DESCRIPTION"] =
	"Estas opciones ajustan las macros de una clase concreta: Alimentar mascota, Piedra de alma y Venenos se activan en Macros de consumibles, y cada sección se muestra en todos los personajes."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Opciones de clase: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Opciones raciales: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Necesita el addon DruidMacroHelper. Si está activado, tus macros de Poción de salud, Poción de maná y Piedra de salud te sacan de la forma, usan el objeto y te devuelven a Forma de oso o Forma felina, la que elijas junto a la casilla."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Usar DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macros de cambio de forma para pociones de salud, pociones de maná y piedras de salud usando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Elige la forma a la que te devuelven tus macros de cambio de forma después de usar el objeto."
L["DRUID_FORM_BEAR"] = "Volver a Forma de oso"
L["DRUID_FORM_CAT"] = "Volver a Forma felina"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro de Venenos cargada con el mejor rango utilizable de cada tipo de veneno: clic izquierdo aplica a tu mano secundaria, clic derecho a tu mano principal, y los venenos existentes se reemplazan automáticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo de veneno de mano principal"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo de veneno de mano secundaria"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano principal con clic derecho."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano secundaria con clic izquierdo."
-- The summary line under Food & Drinks' Rogue header.
L["OPTIONS_FOOD_DRINKS_ROGUE_SUMMARY"] = "Entra en sigilo al sentarte a comer, para descansar sin que te vean."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating and
    drinking toggles. In both hover texts %s is the client's name for the
    spell the macro appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Activar sigilo al comer"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "Añade %s a tu macro de Comida para entrar en sigilo mientras comes."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Activar sigilo al beber"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "Añade %s a tu macro de Agua para entrar en sigilo mientras bebes."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Elige uno. Puedes comer y beber a la vez, pero comer o beber después de entrar en sigilo lo romperá."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Selecciona como objetivo a un humanoide o no-muerto que hayas matado y tu macro lanzará %s mientras el hechizo esté listo, ahorrando tu comida y bebida. Si no puede (el cadáver está fuera de alcance o el hechizo está en reutilización), come o bebe como siempre."
L["OPTIONS_CANNIBALIZE_EATING"] = "Usar %s en lugar de comer"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Mientras tu objetivo sea un cadáver en el que funcione %s y el hechizo esté listo, tu macro de Comida lo lanza en lugar de comer. Si no, come como siempre."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Usar %s en lugar de beber"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Mientras tu objetivo sea un cadáver en el que funcione %s y el hechizo esté listo, tu macro de Agua lo lanza en lugar de beber. Si no, bebe como siempre. Las bebidas con beneficio siguen teniendo prioridad."

--[[
    Trolls, headed with the client's name for the race. In the five texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"%s te cura incluso en combate, donde no puedes comer. Tu macro de Comida puede lanzarlo en combate y tu macro de Venda fuera de él, y así ahorras vendas."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "Usar %s en lugar de comer en combate"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"En combate, donde no puedes comer, tu macro de Comida lanza %s en su lugar. Fuera de combate come como siempre."
L["OPTIONS_RAPID_REGENERATION_BANDAGE"] = "Usar %s en lugar de vendarte fuera de combate"
L["OPTIONS_RAPID_REGENERATION_BANDAGE_DESCRIPTION"] =
	"Fuera de combate, mientras %s esté disponible, tu macro de Venda lo lanza en su lugar y así ahorras vendas. En reutilización, o en combate, se venda como siempre."

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
L["TAB_IGNORE_LIST"] = "Lista de ignorados"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ninguna macro elige nunca los objetos ignorados. Comida, agua, pociones, lo que sea. La lista Global se aplica a todos los personajes; la de un personaje, solo a ese. Haz clic derecho en el botón del minimapa para ignorar tu mejor comida actual."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Mueve este objeto a la lista Global, para que se ignore en todos los personajes."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Añadir desde las bolsas"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Elige cualquier cosa que lleves. Las bolsas se cierran al abrir la interfaz de opciones, así que esto sustituye a arrastrar un objeto hasta aquí."
L["OPTIONS_IGNORE_ADD_ID"] = "Añadir por ID de objeto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat mientras este campo está activo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat."
L["OPTIONS_IGNORE_REMOVE"] = "Quitar"
L["OPTIONS_IGNORE_EMPTY"] = "Esta lista está vacía."
L["OPTIONS_IGNORE_CLEAR"] = "Vaciar lista"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Quita todos los objetos de esta lista. Un personaje con la lista vacía desaparece de la lista de la izquierda, salvo que sea el que estás jugando."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "¿Quitar todos los objetos de esta lista? No se puede deshacer."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Cargando ID: %d"
-- %d is how many of an item you carry, after its name in a menu ("x12").
L["ITEM_QUANTITY"] = "x%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene tus bolsas abastecidas según tu lista de reabastecimiento, comprando a los mercaderes y moviendo objetos desde y hacia el banco automáticamente. Escribe %s para abrir la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Abrir en el banco"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar el banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir con el mercader"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar a un mercader."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Recordatorios"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"Elige cuándo se te avisa de que te faltan objetos de tu lista de reabastecimiento."
-- Low Means Under, the dropdown above the three reminders: the share of a row's amount below which they call it low. Its values are percentages, written the same in every locale.
L["OPTIONS_RESTOCKER_LOW_THRESHOLD"] = "Poco significa menos del"
L["OPTIONS_RESTOCKER_LOW_THRESHOLD_DESCRIPTION"] =
	"Un objeto cuenta como poco cuando tienes menos de esta parte de lo que pide tu lista de reabastecimiento, y como agotado cuando no tienes ninguno. Por encima, no se menciona."
L["OPTIONS_RESTOCKER_REMIND"] = "Activar recordatorios de reabastecimiento en la ciudad"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Muestra un recordatorio en el chat cuando te queda poco o se te ha agotado algo de tu lista de reabastecimiento y llegas a una posada o una ciudad, o ya estás en una al iniciar sesión."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activar recordatorios de reabastecimiento en el mercader"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa de lo que aún te queda poco o tienes agotado al cerrar la ventana de un mercader."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activar recordatorios de reabastecimiento en el banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa de lo que aún te queda poco o tienes agotado al cerrar el banco."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Reserva de oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"Aparta una cantidad de oro que las compras a los mercaderes nunca tocan."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Activar reserva de oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "El reabastecimiento nunca gasta el oro que apartes aquí."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Establece cuánto oro te deja siempre el reabastecimiento."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item it counted (out, then low), showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown under each reminder,
    beside its How Much to Say caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Elige si el recordatorio es una sola línea o añade una línea por cada objeto del que te queda poco o que tienes agotado."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Nivel de detalle"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Detallado"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Reproducir sonido"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Reproduce un aviso junto al recordatorio, para cuando el chat está muy movido."
L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"] = "Reproduce este sonido ahora, esté o no activado el sonido."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Ventana de la lista de reabastecimiento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Elige cuándo se abre sola tu lista de reabastecimiento."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description. Its switch is SWITCH_INVENTORY_REPORT, under Features.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Muestra en la descripción de un objeto cuántas unidades tienes entre todos tus personajes de este reino."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Personajes registrados"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Olvidar"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"¿Olvidar a %s? Sus bolsas y su banco desaparecen de la descripción de todos los objetos, y se borra su elección de lista de reabastecimiento. Al iniciar sesión con ese personaje se vuelve a registrar."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Informe de preparación"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Cuando empieza una comprobación de quiénes están listos, muestra una lista privada de lo que aún falta por arreglar, y no dice nada en absoluto si estás preparado."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Restablecer ajustes del informe de preparación"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Restablece a sus valores por defecto todas las casillas y ambos umbrales de esta página."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"¿Restablecer todos los ajustes del informe de preparación a sus valores por defecto?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Beneficios que faltan"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Objetos que faltan"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaje"
-- The summary line under each of the Readiness Report's three headers.
L["OPTIONS_READINESS_BUFFS_SUMMARY"] = "Beneficios que deberías tener antes del combate."
L["OPTIONS_READINESS_ITEMS_SUMMARY"] = "Consumibles que deberías llevar encima y equipo que vale la pena reparar."
L["OPTIONS_READINESS_CHARACTER_SUMMARY"] = "Ajustes de tu personaje que es fácil olvidar."

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Avisa si te falta un frasco. Un frasco, o un elixir de batalla y un elixir guardián, cuenta como cubierto."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] = 'Avisa si te falta el beneficio "%s".'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Avisa si a tu mascota le falta el beneficio "%s". Necesita Usar beneficios de comida de mascota activado en la página Macros de clase, y una mascota invocada.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Avisa de los beneficios de pergaminos que faltan, para los tipos de pergamino marcados en la página Beneficios propios del Turno de beneficios."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Avisa cuando nadie de tu grupo tiene una Piedra de alma activa; una guardada en una bolsa no cuenta. Solo avisa a los brujos que pueden crearla."
L["OPTIONS_READINESS_MAIN_HAND"] = "Beneficio de arma (mano principal)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano principal no tiene un encantamiento temporal. Cuenta cualquier encantamiento, y guarda silencio cuando hay un chamán en tu grupo."
L["OPTIONS_READINESS_OFF_HAND"] = "Beneficio de arma (mano secundaria)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano secundaria no tiene un encantamiento temporal. Cuenta cualquier encantamiento: una piedra, un aceite, un veneno o un beneficio de arma de chamán."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Avisa si al arma de tu mano principal le falta un encantamiento temporal. A pícaros y chamanes se les piden dos, un veneno o imbuición junto a un aceite o una piedra; a los demás, uno cualquiera."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Avisa si al arma de tu mano secundaria le falta un encantamiento temporal. A los pícaros se les piden dos, un veneno junto a un aceite o una piedra; a los demás, uno cualquiera."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Class Macros page has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Beneficios que expiran en menos de"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Nombra todos los beneficios que tienes a punto de expirar, no solo los que aplica Good to Go, y es independiente de Renovar beneficios a punto de expirar en la página Macros de clase."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutos"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe acercarse un beneficio a expirar para que el informe lo nombre."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Piedra de salud. Solo avisa cuando hay un brujo en tu grupo al que pedirla, o cuando el brujo eres tú."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Gema de maná. Solo avisa a los magos que pueden conjurarla."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de curación, ya que nadie puede darte una en plena pelea."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de maná. Solo avisa cuando juegas con una clase que usa maná."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna venda que tu habilidad de %s te permita usar."
L["OPTIONS_READINESS_DURABILITY"] = "Equipo dañado por debajo de"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Enlaza cada objeto equipado por debajo de esta durabilidad, medida por objeto para que un arma rota siga apareciendo."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe bajar la durabilidad de un objeto para que el informe lo enlace."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Especialización actual"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "Muestra tu reparto de talentos y los puntos que no hayas gastado."
L["OPTIONS_READINESS_PVP"] = "Marca JcJ activada"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avisa cuando tu marca JcJ está activa."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Enlaza los objetos equipados que no tienen cabida en un combate, como el equipo de montar o de pesca."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its whispers are the
    player's to word on the Rank Watch panel, with their default text in Data/Message-Languages.lua; its prints
    are fixed. Rank Sentinel is the standalone add-on Rank Watch replaces; its name stays as written in every
    locale.
]]
L["TAB_RANK_WATCH"] = "Vigía de rangos"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Vigila a tu grupo por si alguien lanza un hechizo con un rango inferior al que podría usar, y le avisa de que tiene un rango superior esperándole en su instructor. Nunca se avisa de un rango que el juego reduce por sí solo, como un beneficio lanzado sobre un jugador de nivel bajo."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s sigue en ejecución, así que el Vigía de rangos de Good to Go se mantiene en silencio para que tu grupo no reciba dos veces cada aviso de rango bajo. Good to Go ha desactivado ese addon y ha activado su propio Vigía de rangos; recarga para que el Vigía de rangos de Good to Go tome el relevo."

-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Rango %d"

-- Printed when a group member whispers "Opt Out". %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'%s te ha susurrado "Opt Out", así que ahora el Vigía de rangos lo ignora. Puedes deshacerlo en Jugadores ignorados, dentro de Vigía de rangos.'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"Has lanzado %s, y %s está disponible desde el nivel %d. Visita a tu instructor o actualiza tus barras de acción."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "Tu mascota %s ha lanzado %s, y %s está disponible desde el nivel de mascota %d."
L["RANK_WATCH_PRINT_SELF_DEMON"] = "Tu %s ha lanzado %s, y %s está disponible desde el nivel %d."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s ha lanzado %s, y tiene disponible %s desde el nivel %d."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"La mascota de %s, %s, ha lanzado %s, y tiene disponible %s desde el nivel de mascota %d."
L["RANK_WATCH_PRINT_OTHER_DEMON"] = "El demonio de %s (%s) ha lanzado %s, y tiene disponible %s desde el nivel %d."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s le susurrará."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Activar Vigía de rangos"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Te avisa a ti, y susurra a los miembros de tu grupo, cuando alguien lanza un hechizo con un rango inferior al que podría usar, para que sepan que deben visitar a su instructor."

L["RANK_WATCH_MESSAGES_HEADER"] = "Notificaciones"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] = "Cómo avisa el Vigía de rangos a un jugador de que ha lanzado un rango bajo."
L["RANK_WATCH_WHISPER"] = "Susurrar a miembros del grupo"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Susurra a un miembro del grupo que ha lanzado un rango bajo. Cuando varios jugadores de tu grupo usan el Vigía de rangos o Rank Sentinel, solo uno de ellos susurra."
--[[
    The tip's whisper composer, under the whisper toggle: one box for the caster's own low rank, one for a
    hunter's pet, one for a warlock's demon.
    TRANSLATORS: keep {spell}, {level} and {pet} exactly as written; they are the tokens players type into the
    whisper. In the TOKENS lines each %s is a token, in the order shown, drawn in blue.
]]
L["RANK_WATCH_TIP_MESSAGE_DESCRIPTION"] =
	"Define lo que Good to Go susurra a un miembro del grupo que ha lanzado un rango bajo. {spell} se convierte en el hechizo y el rango que lanzó, y {level} en el nivel en el que hay un rango más alto. Déjalo vacío para no enviar ningún susurro."
L["RANK_WATCH_TIP_TOKENS"] = "Comodines: %s el hechizo y el rango que lanzó, %s el nivel del rango más alto"
L["RANK_WATCH_TIP_PET_MESSAGE"] = "Susurro de mascota"
L["RANK_WATCH_TIP_PET_MESSAGE_DESCRIPTION"] =
	"Define lo que Good to Go susurra a un cazador cuya mascota ha lanzado un rango bajo. {pet} se convierte en el nombre de la mascota, {spell} en el hechizo y el rango que lanzó, y {level} en el nivel de mascota en el que hay un rango más alto. Déjalo vacío para no enviar ningún susurro."
L["RANK_WATCH_TIP_PET_TOKENS"] =
	"Comodines: %s el nombre de la mascota, %s el hechizo y el rango, %s el nivel de mascota del rango más alto"
L["RANK_WATCH_TIP_DEMON_MESSAGE"] = "Susurro de demonio"
L["RANK_WATCH_TIP_DEMON_MESSAGE_DESCRIPTION"] =
	"Define lo que Good to Go susurra a un brujo cuyo demonio ha lanzado un rango bajo. {pet} se convierte en el tipo de demonio, como diablillo, {spell} en el hechizo y el rango que lanzó, y {level} en el nivel en el que hay un rango más alto. Déjalo vacío para no enviar ningún susurro."
L["RANK_WATCH_TIP_DEMON_TOKENS"] =
	"Comodines: %s el tipo de demonio, %s el hechizo y el rango, %s el nivel del rango más alto"
L["RANK_WATCH_PRINT"] = "Mostrar rangos bajos del grupo"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"Muestra en tu chat el rango bajo de un miembro del grupo. Tus propios rangos bajos siempre se muestran."
L["RANK_WATCH_GRACE_HEADER"] = "Periodo de gracia"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"No se avisa de un rango nuevo hasta que el lanzador haya superado su nivel en esta cantidad de niveles, para que nadie reciba avisos de un rango que acaba de alcanzar y que aún no ha tenido tiempo de entrenar."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Periodo de gracia al nivel máximo"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"Para un personaje en el nivel máximo, no avisa de ningún rango que se aprenda a esta cantidad de niveles del máximo o menos. Con 0, se avisa de todos los rangos que podría tener."
L["RANK_WATCH_GRACE_LEVELING"] = "Periodo de gracia al subir de nivel"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"Para un personaje que aún sube de nivel, no avisa de ningún rango que se aprenda a esta cantidad de niveles del suyo o menos, para darle tiempo a llegar a un instructor."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 nivel"
L["RANK_WATCH_GRACE_LEVELS"] = "%d niveles"

--[[
    The opt-out whispers' composer, under the tip's, while Whisper Group Members is on: the offer sent with a
    player's second tip in a session, and the reply to a group member who whispers "Opt Out" back.
    TRANSLATORS: keep "Opt Out" in English; it is the words a player whispers back, and Good to Go listens for
    exactly those.
]]
L["RANK_WATCH_OPT_OUT_MESSAGE"] = "Oferta de baja"
L["RANK_WATCH_OPT_OUT_MESSAGE_DESCRIPTION"] =
	'Define lo que Good to Go susurra justo después del segundo consejo de rango que recibe un jugador en una sesión. Dile que responda "Opt Out". Déjalo vacío para no enviar la oferta.'
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE"] = "Respuesta de baja"
L["RANK_WATCH_OPT_OUT_DONE_MESSAGE_DESCRIPTION"] =
	'Define lo que Good to Go responde por susurro a un miembro del grupo que le susurra "Opt Out". Déjalo vacío para no enviar respuesta.'
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'La segunda vez que el Vigía de rangos susurra a alguien en una sesión, le explica a continuación cómo darse de baja. Si te susurra "Opt Out" mientras está en tu grupo, pasa a Jugadores ignorados, le respondes para confirmarlo y nunca más le avisarás de rangos. Para dejar en paz a alguien tú mismo, selecciónalo y escribe /gtg ignore.'
--[[
    Who whispers for your group: a silver line under Whisper Group Members. %s is one of the three answers
    below, RANK_WATCH_WHISPERER_SELF, _OTHER or _NONE.
]]
L["RANK_WATCH_WHO_WHISPERS_FORMAT"] = "Quién susurra por tu grupo ahora mismo: %s"
L["RANK_WATCH_WHISPERER_SELF"] = "Tú."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s, así que tú solo ves el mensaje en el chat."
L["RANK_WATCH_WHISPERER_NONE"] = "Nadie: Susurrar a miembros del grupo está desactivado."

--[[
    Ability Alerts While Leveling: the panel for the level-up prints (LEVEL_UP_SPELLS and the rest), under
    Enhanced Spellbook. RANK_WATCH_LEVEL_UP_HEADER is its name in the settings tree, the page title and the
    mini-map menu; its switch is SWITCH_ABILITY_ALERTS, also in the root panel's Features section.
]]
L["RANK_WATCH_LEVEL_UP_HEADER"] = "Avisos de habilidades al subir de nivel"
L["ABILITY_ALERTS_DESCRIPTION"] =
	"Al subir de nivel, el chat muestra las habilidades que tu instructor de clase tiene para ti, cada una con su icono y un enlace sobre el que puedes pasar el ratón."
L["SWITCH_ABILITY_ALERTS"] = "Activar avisos de habilidades al subir de nivel"
L["SWITCH_ABILITY_ALERTS_DESCRIPTION"] =
	"Al subir de nivel, muestra en el chat las habilidades que tu instructor de clase tiene para ti."
L["RANK_WATCH_LEVEL_UP_PAST"] = "Incluir habilidades que te saltaste"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] =
	"Añade una línea con las habilidades de niveles anteriores que aún no has aprendido."
L["RANK_WATCH_LEVEL_UP_PET"] = "Incluir habilidades de mascota"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] =
	"Añade las habilidades del instructor de mascotas para cazadores, o los grimorios del instructor de demonios para brujos, que se desbloquean en tu nuevo nivel."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "Incluir habilidades de mascota que te saltaste"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] =
	"Solo cazadores: añade una línea con las habilidades del instructor de mascotas de niveles anteriores que aún no has aprendido. Los brujos no reciben esta línea, porque el juego no indica qué grimorios ha aprendido un demonio mientras no está invocado."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Jugadores ignorados"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "El Vigía de rangos nunca informa sobre estos jugadores."
L["RANK_WATCH_IGNORED_NONE"] = "Nadie por ahora."
L["RANK_WATCH_IGNORED_REMOVE"] = "Dejar de ignorar"
L["RANK_WATCH_IGNORE_TARGET"] = "Ignorar objetivo"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "Añade a la lista al jugador que tienes seleccionado."
L["RANK_WATCH_IGNORE_ADDED"] = "El Vigía de rangos ahora ignora a %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"No se encuentra a %s. Agrúpate con ese jugador o selecciónalo, y vuelve a intentarlo."
-- %s is the command, /gtg ignore Name (RANK_WATCH_IGNORE_COMMAND), drawn in blue.
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Selecciona a un jugador o escribe %s."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Nombre"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"El Vigía de rangos deja de informar sobre ese jugador. Sin nombre, ignora a tu objetivo."

-- Reported Ranks, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"Los rangos de los que informa el Vigía de rangos, clase por clase. Desmarca un rango que bajes a propósito y el Vigía de rangos lo dejará en paz. Se muestran todas las habilidades. Las que el Vigía de rangos no vigila por defecto, como las curaciones, los talentos y Abrasar (Rango 1), empiezan desmarcadas. El rango más alto de cada habilidad aparece en gris, ya que no hay nada por encima."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (nivel %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "Informa de este rango cuando hay uno superior disponible."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "El rango más alto. No hay nada por encima, así que nunca se informa de él."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "Mascotas de %s"
L["RANK_WATCH_TRACK_ALL"] = "Marcar todo"
L["RANK_WATCH_TRACK_ALL_DESCRIPTION"] = "Informa de todos los rangos por debajo del más alto en esta página."
-- Asked before Check All or Uncheck All goes through; %s is the page's class, or its pets ("Hunter Pets").
L["RANK_WATCH_TRACK_ALL_CONFIRM"] = "¿Informar de todos los rangos por debajo del más alto en la página %s?"
L["RANK_WATCH_UNTRACK_ALL_CONFIRM"] = "¿Dejar de informar de todos los rangos en la página %s?"
L["RANK_WATCH_TRACK_NONE"] = "Desmarcar todo"
L["RANK_WATCH_TRACK_NONE_DESCRIPTION"] = "Deja de informar de todos los rangos de esta página."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Ya existe una lista llamada "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "El ID %d no existe."
L["RESTOCKER_DISABLED"] = "El Restocker está desactivado. Actívalo en Opciones > Accesorios > Good to Go > Restocker."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = 'No hay ninguna lista de reabastecimiento llamada "%s".'
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Reabastecimiento completado. Mantén Mayús al abrir el banco para omitir el reabastecimiento. Escribe %s para editar tu lista de reabastecimiento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Reabastecimiento detenido. Tus bolsas y tu banco están llenos."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Reabastecimiento detenido. Tu banco está lleno; libera un espacio y vuelve a abrirlo."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Reabastecimiento detenido. Tus bolsas están llenas; libera un espacio y vuelve a abrir el banco."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Reabastecimiento detenido. No se pudo avanzar."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Reabastecimiento detenido. No se pudo mover: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (sobrante)"
L["RESTOCKER_STOPPED_ERROR"] = "Reabastecimiento detenido por un error: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Este mercader no tiene todos los ingredientes que necesitan tus venenos. No se comprará ninguno."
-- Printed on reaching an inn or a city while something on the Restock List is low or out. %s is the counts sentence (RESTOCKER_LOW_ONE and the rest, below).
L["RESTOCKER_TOWN_REMINDER"] = "¡Recuerda reabastecerte ahora que estás en la ciudad! %s"

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
L["RESTOCKER_SHORT_BUY"] = "Faltan %d objetos, %d para comprar."
L["RESTOCKER_SHORT_ONE_BUY"] = "Falta 1 objeto, 1 para comprar."
L["RESTOCKER_SHORT_NONE_TO_BUY"] = "Faltan %d objetos. Sácalos de tu banco."
L["RESTOCKER_SHORT_ONE_NONE_TO_BUY"] = "Falta 1 objeto. Sácalo de tu banco."
L["RESTOCKER_SHORT_ITEMS_TITLE"] = "Objetos que faltan"

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
L["RESTOCKER_LOW_ONE"] = "Te queda poco de 1 objeto."
L["RESTOCKER_LOW_MANY"] = "Te queda poco de %d objetos."
L["RESTOCKER_OUT_ONE"] = "Se te ha agotado 1 objeto."
L["RESTOCKER_OUT_MANY"] = "Se te han agotado %d objetos."
L["RESTOCKER_OUT_AND_LOW_ONE"] = "Se te ha agotado 1 objeto, y te queda poco de %d."
L["RESTOCKER_OUT_AND_LOW_MANY"] = "Se te han agotado %d objetos, y te queda poco de %d."
L["RESTOCKER_STILL_LOW_ONE"] = "Aún te queda poco de 1 objeto."
L["RESTOCKER_STILL_LOW_MANY"] = "Aún te queda poco de %d objetos."
L["RESTOCKER_STILL_OUT_ONE"] = "Aún tienes agotado 1 objeto."
L["RESTOCKER_STILL_OUT_MANY"] = "Aún tienes agotados %d objetos."
L["RESTOCKER_STILL_OUT_AND_LOW_ONE"] = "Aún tienes agotado 1 objeto, y te queda poco de %d."
L["RESTOCKER_STILL_OUT_AND_LOW_MANY"] = "Aún tienes agotados %d objetos, y te queda poco de %d."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Tu lista de reabastecimiento se ha mejorado."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d pasa a %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 pedido de reabastecimiento completado."
L["RESTOCKER_RESTOCKED_MANY"] = "%d pedidos de reabastecimiento completados."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 pedido de reabastecimiento completado en parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d pedidos de reabastecimiento completados en parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Tus bolsas se han llenado antes de poder comprarlo todo."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "No tienes oro suficiente para terminar el reabastecimiento."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing was bought at this merchant; the second sentence says where
    the reserve is changed, by the options panel's own path.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Tienes menos de %s, la reserva de oro que apartaste, así que no se ha comprado nada. Cámbiala en Opciones > Accesorios > Good to Go > Restocker."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nombre]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Añade una lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con ese nombre."
-- Printed for a /restock word the command doesn't know, before the command list. The first %s is the word typed, the second /restock help, drawn in blue.
L["RESTOCKER_SLASH_UNKNOWN"] = 'Comando de Restocker desconocido: "%s". Escribe %s para ver la lista.'
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renombra la lista actual a ese nombre."
L["RESTOCKER_HELP_PROFILE_COPY"] =
	"Reemplaza la lista actual por una copia de la lista con ese nombre, tras pedir confirmación."
--[[
    TRANSLATORS: /restock profile copy's confirm. The first %s is the list in
    use, which is replaced, the second the list copied, both in gold.
    ALSO_USED_BY follows it when another character uses the list in use: the
    first %s is the list, the second their names, joined like the window's
    Used By line. REPLACE is the confirm's button.
]]
L["RESTOCKER_PROFILE_COPY_CONFIRM"] = "¿Reemplazar todo el contenido de %s por una copia de %s? No se puede deshacer."
L["RESTOCKER_PROFILE_COPY_CONFIRM_ALSO_USED_BY"] = "%s también es usada por %s."
L["RESTOCKER_REPLACE"] = "Reemplazar"
L["RESTOCKER_HELP_PROFILE_USE"] = "Hace que este personaje use la lista con ese nombre."

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
L["STARTER_POPUP_TITLE"] = "Básicos"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Listo"
-- Gray, in the Staples window's body when no staple fits this character yet.
L["STARTER_NOTHING_TO_OFFER"] = "Todavía no hay nada que añadir para tu clase y nivel."
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Hemos añadido algunos básicos de tu clase a tu lista de reabastecimiento. Desmarca los que no quieras."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Tu lista de reabastecimiento está vacía, así que vamos a añadir algunos objetos para empezar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Elige los básicos que quieres mantener abastecidos."
L["STARTER_POPUP_INTRO_HOW"] =
	"Todo lo que marques se reabastece automáticamente cada vez que visitas a un mercader o tu banco. La mayoría de los básicos se mejoran solos según subes de nivel, así que siempre tendrás lo mejor disponible."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Siempre puedes ajustar esta lista, o añadir más objetos más adelante, escribiendo %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Comida y agua"
L["STARTER_POPUP_FOOD_HEADER"] = "Comida"
L["STARTER_POPUP_AMMO_HEADER"] = "Munición"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Balas"
L["STARTER_POPUP_ARROWS"] = "Flechas"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Componentes y herramientas"
L["STARTER_POPUP_POISONS_HEADER"] = "Venenos"
-- %s is the client's name for the Rogue class, rogue-colored, and the colon follows it directly.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s: Añade el veneno terminado a tu lista y Good to Go comprará los ingredientes automáticamente en cualquier mercader que los venda todos."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Añade %s a tu lista de reabastecimiento, manteniendo %d en tus bolsas y mejorándolos según subes de nivel."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Añade %s a tu lista de reabastecimiento y mantiene %d en tus bolsas."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 montón"
L["STARTER_POPUP_STACK_MANY"] = "%d montones"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Cuántos montones mantener abastecidos, a razón de %d por montón."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Cuántos mantener abastecidos, cada uno en su propio espacio de la bolsa, ya que no se apilan."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Lista de reabastecimiento"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Borrar"
L["RESTOCKER_ADD_BUTTON"] = "Añadir"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Elegir básicos"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Elige entre los básicos de tu clase y nivel: comida, agua, munición, venenos y componentes. Al marcar uno se añade a esta lista, y al desmarcarlo se quita."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Añadir un objeto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Suelta un objeto de tus bolsas aquí o en cualquier parte de esta ventana, o escribe un ID de objeto y pulsa Intro."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Suelta objeto o escribe ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Escribe el ID del objeto."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Ya está en esta lista."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Añadir objeto desde tus bolsas"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Todos los objetos de tus bolsas que aún no están en esta lista, listos para añadir."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nada en tus bolsas que añadir"

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
L["RESTOCKER_PROFILE_TOOLTIP"] = "Hace que este personaje use otra lista de reabastecimiento, o empieza una nueva."
L["RESTOCKER_USED_BY"] = "Usada por %s"
L["RESTOCKER_MANAGE"] = "Gestionar listas"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Empieza una lista nueva, o copia, renombra o elimina esta."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Lista nueva"
L["RESTOCKER_MANAGE_COPY"] = "Copiar esta lista en una nueva"
L["RESTOCKER_RENAME_PROFILE"] = "Renombrar esta lista"
L["RESTOCKER_MANAGE_DELETE"] = "Eliminar esta lista"
-- TRANSLATORS: gray on Delete This List's right, how many characters use the list ("Used by 2").
L["RESTOCKER_LIST_USED_BY_COUNT"] = "Usada por %d"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - copia"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renombrar"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renombra esta lista para todos los personajes que la usan."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "¿Seguro que quieres eliminar esta lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s también la usa y, al iniciar sesión, encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s también la usan y, al iniciar sesión, cada uno encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Pasarás a usar %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es la única lista que queda, así que empezarás con una nueva y vacía."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Esto no se puede deshacer."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mejorar al subir de nivel"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permite que Good to Go mejore la comida, el agua, la munición, los venenos, las pociones y los componentes de clase a objetos mejores según subes de nivel."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Mejora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Objeto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Sacar"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Guardar"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Mantener"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens; SHOWN, gray on their right, is how many of the items shown
    the column can be set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "El encabezado ajusta esto en todos los objetos mostrados."
L["RESTOCKER_BULK_ON"] = "Activar"
L["RESTOCKER_BULK_OFF"] = "Desactivar"
L["RESTOCKER_BULK_SHOWN"] = "%d mostrados"

L["RESTOCKER_GROUP_OTHER"] = "Otros"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuevos"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Todos los objetos"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Aún no hay nada en esta lista"
L["RESTOCKER_EMPTY_BODY"] =
	"Elige básicos como comida, agua o componentes de clase, o añade cualquier cosa de tus bolsas con el menú de arriba. Los objetos de esta lista se mantienen abastecidos o se guardan en tu banco automáticamente, para que tus bolsas queden despejadas."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Soltar un objeto en cualquier parte de esta ventana también lo añade."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nada de esta lista coincide con tu filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "No queda nada en esta categoría."

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
L["RESTOCKER_REMOVED_ITEM"] = "Se ha quitado %s."
L["RESTOCKER_UNDO"] = "Deshacer"
L["RESTOCKER_UNDO_TOOLTIP"] = "Devolver este objeto a la lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Quitar este objeto de la lista de reabastecimiento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puedes deshacerlo en su fila hasta que cambie la lista."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Mantener en tus bolsas"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Cuántos mantener en tus bolsas. El número se muestra en amarillo mientras tus bolsas tengan menos, y 0 con Guardar activado lo envía todo al banco."
L["RESTOCKER_BUY_LABEL"] = "Comprar"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Comprar al mercader"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra al mercader la cantidad necesaria cuando la ventana del mercader está abierta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Comprar de más"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra todas las existencias limitadas que un mercader tenga de este objeto, esos pocos artículos que repone lentamente, incluso por encima de tu cifra de Mantener."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar en el banco"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda en el banco los objetos sobrantes cuando el banco está abierto, o todos ellos si pones 0 en la columna Mantener."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Sacar del banco"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Saca del banco los objetos necesarios cuando el banco está abierto."

-- Required-reputation control (per-item vendor gate).
--[[
    A standing's discount, gray on its row's right in the standings menu. The
    standings are the client's own labels (FACTION_STANDING_LABEL5 to 8), so
    only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT"] = "%d%% de descuento"
L["RESTOCKER_REPUTATION_ANY"] = "Cualquiera"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputación requerida con el mercader"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Elige la reputación necesaria con un mercader antes de que Good to Go le compre, lo que además rebaja el precio: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Con un guion, compra a cualquier mercader."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no hay nada extra que comprar."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no se aplica ninguna reputación."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Este objeto no tiene ninguna versión superior a la que mejorar."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go ha desactivado %s, al que sustituye. ¿Recargar ahora para que la copia antigua deje de ejecutarse?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Recargar ahora"
L["POPUP_REPLACED_LATER"] = "Más tarde"
-- The Spellbook's confirm buttons, each naming what it does; the other button is the client's Cancel.
L["POPUP_DELETE"] = "Borrar"
L["POPUP_RESET"] = "Restablecer"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Se han copiado tus ajustes de %s."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go ha copiado tus ajustes de %s y ha desactivado %s, al que sustituye. ¿Recargar ahora para que la copia antigua deje de ejecutarse?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go ha encontrado esto instalado pero desactivado: %s. ¿Traer los ajustes? Esto vuelve a activar los addons antiguos y recarga tu interfaz; después te ofrece otra recarga para volver a desactivarlos."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go ha encontrado esto instalado pero desactivado: %s. ¿Traer los ajustes y las listas de reabastecimiento? Esto vuelve a activar los addons antiguos y recarga tu interfaz; después te ofrece otra recarga para volver a desactivarlos."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Traerlos"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "No, gracias"

--------------------------------------------------------------------------------
-- Options: Group Buffs and Reported Ranks
--------------------------------------------------------------------------------

-- The Group Buffs and Reported Ranks panels' titles, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Beneficios de grupo"
L["RANK_WATCH_TRACKED_HEADER"] = "Rangos notificados"
L["TRACKED_ITEM_PENDING"] = "Objeto #%d"
L["TRACKED_SPELL_PENDING"] = "Hechizo #%d"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Turno de beneficios"
L["BUFF_DUTY_DESCRIPTION"] = "Muestra a quién le faltan tus beneficios. Haz clic en un icono para lanzarlo."
L["BUFF_DUTY_ENABLE"] = "Activar Turno de beneficios"
L["BUFF_DUTY_NO_BUFFS"] =
	"Tu clase no tiene beneficios en esta lista, así que la ventana nunca aparece con este personaje."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Cuándo mostrar"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Elige cuándo puede aparecer la ventana."
L["BUFF_DUTY_WHEN_NONE"] = "No hay nada marcado, así que la ventana nunca aparece."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"El Turno de beneficios está oculto aquí. El juego no deja que los addons vean los beneficios en esta zona, así que no puede saber a quién le falta uno."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Define dónde se muestra la ventana: en cualquier lugar, o solo dentro de una instancia, como una mazmorra o una banda."
L["BUFF_DUTY_WHERE_ALWAYS"] = "En cualquier lugar"
L["BUFF_DUTY_WHERE_INSTANCE"] = "En instancia"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Muestra la ventana cuando juegas estas clases."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Muestra la ventana cuando juegas esta clase."
L["BUFF_DUTY_HEADER"] = "Ventana"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Mantén la ventana donde la dejaste, o apártala durante el combate."
L["BUFF_DUTY_LOCK"] = "Bloquear ventana"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "Impide que la ventana se mueva. Desbloqueada, arrástrala desde el fondo."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Ocultar en combate"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Oculta la ventana durante el combate. La lista no se puede actualizar en combate, así que si dejas la ventana visible, conserva su último estado hasta que termine el combate."
L["BUFF_DUTY_SHOW_HEADER"] = "Mostrar en la ventana"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Añade a la ventana tus propios beneficios, los desconocidos que te han beneficiado y tu objetivo."
-- Return the Favor, Your Target and Ask for Buffs each name both their switch and the window row it adds.
L["BUFF_DUTY_FAVOR_ENABLE"] = "Devolver el favor"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Muestra a los desconocidos que te han beneficiado hace poco, con los beneficios que puedes devolverles. Haz clic derecho en un icono para quitar a alguien de la lista."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Establece cuánto tiempo permanece un desconocido en la lista tras su último beneficio."
L["BUFF_DUTY_TARGET_ENABLE"] = "Tu objetivo"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Muestra a tu objetivo cuando es un jugador de fuera de tu grupo al que le falta un beneficio que puedes dar."
L["BUFF_DUTY_TARGET_NPCS"] = "Incluir PNJ"
L["BUFF_DUTY_TARGET_NPCS_DESCRIPTION"] =
	"También muestra a un PNJ amistoso que tengas como objetivo, como el soldado herido de una misión, con los beneficios que puedes darle."
-- Under Your Target: an Ask row of the buffs of theirs you're missing, whispered for on a click or Cast Next Buff.
L["BUFF_DUTY_ASK_TARGET"] = "Pedir beneficios a tu objetivo"
L["BUFF_DUTY_ASK_TARGET_DESCRIPTION"] =
	"Cuando tu objetivo puede darte un beneficio que te falta, lo muestra en una fila Pedir debajo de él. Haz clic en él, o pulsa Lanzar siguiente beneficio, para susurrarle una petición amable. A nadie se le pide el mismo beneficio más de una vez cada 5 minutos."
--[[
    The ask to your target's composer, under Ask Your Target for Buffs.
    TRANSLATORS: keep {name} and {spells} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {name} then {spells}, drawn in blue.
]]
L["BUFF_DUTY_ASK_TARGET_MESSAGE_DESCRIPTION"] =
	"Define lo que Good to Go le susurra a tu objetivo cuando le pides un beneficio desde la fila Pedir. {name} se convierte en su nombre y {spells} en los beneficios que pides. Déjalo vacío para no enviar susurro."
L["BUFF_DUTY_ASK_TARGET_TOKENS"] = "Comodines: %s su nombre, %s los beneficios"
L["BUFF_DUTY_ASK_OTHERS"] = "Pedir beneficios"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Añade a la ventana una fila Pedir beneficios: los beneficios de banda que necesita tu grupo y cuántos jugadores necesitan cada uno. Haz clic izquierdo en uno para pedírselo a tu grupo, o clic derecho para susurrar a los jugadores que pueden lanzarlo."
--[[
    The whispered ask's composer, under Ask for Buffs.
    TRANSLATORS: keep {names} and {spell} exactly as written; they are the tokens players type into the whisper.
    In the TOKENS line each %s is a token, {names} then {spell}, drawn in blue.
]]
L["BUFF_DUTY_ASK_MESSAGE_DESCRIPTION"] =
	"Define lo que Good to Go susurra a los jugadores que pueden lanzar un beneficio que falta cuando haces clic derecho en él en Pedir beneficios. {names} se convierte en los jugadores a los que les falta, o en cuántos son, y {spell} en el beneficio. Déjalo vacío para no enviar ningún susurro."
L["BUFF_DUTY_ASK_TOKENS"] = "Comodines: %s los jugadores a los que les falta, o cuántos son, %s el beneficio"
-- Group Buffs page: the Refresh section around Refresh Under.
L["BUFF_DUTY_REFRESH_HEADER"] = "Renovar"
L["BUFF_DUTY_REFRESH_SUMMARY"] = "Vuelve a ofrecer un beneficio antes de que expire."
L["BUFF_DUTY_REFRESH"] = "Renovar con menos de"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Establece con cuánto tiempo restante un beneficio pasa a contar como ausente, para que puedas renovarlo antes de que expire. Un beneficio que no dura más que esto solo cuenta cuando ya ha desaparecido."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Contar como tanques"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Quién recibe los beneficios que ofreces a Tanques, como Espinas, cuando no tiene un rol propio."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Establece cuándo los jugadores de esta clase cuentan como tanques. Un rol de tanque o sanador que tengan siempre tiene prioridad."
L["BUFF_DUTY_TANKS_PETS"] = "Mascotas"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Establece cuándo las mascotas cuentan como tanques. Las mascotas también reciben los beneficios que ofreces a Todos."
L["BUFF_DUTY_TANKS_NEVER"] = "Nunca"
L["BUFF_DUTY_TANKS_SOLO"] = "En solitario"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Siempre"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Desactivado"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Tanques"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Sanadores"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Todos"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Establece a quién se le ofrece %s."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Elige a quién se ofrece cada beneficio. Tanques y Sanadores se asignan por rol de grupo, pero en banda solo cuentan como tanques los jugadores marcados como %s. Quien no tenga rol cuenta como Daño, salvo que Contar como tanques, más abajo, indique otra cosa."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Beneficios propios"
L["BUFF_DUTY_SELF_DESCRIPTION"] =
	"Todos los beneficios que puedes lanzarte a ti mismo, fijados en la parte superior de la ventana. Tus beneficios de grupo también están aquí, para cuando los llevas tú: en Beneficios de grupo eliges quién más los recibe."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "cualquier aspecto cuenta"
L["BUFF_DUTY_SELF_NOTE_BLESSING"] = "cualquiera de tus bendiciones cuenta"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "cualquier armadura cuenta"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "cualquier aura cuenta"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "cualquier escudo cuenta"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "cualquier armadura cuenta"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "cualquiera de los dos beneficios de demonio cuenta"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Desactivado"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Si falta"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Menos de %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Establece cuándo aparece %s: nunca, cuando ya no está activo o cuando le queda menos de este tiempo."
-- The Self-Buffs panel's last box: consumables any class keeps up on itself (Winterfall Firewater), with a muted note after its name.
L["BUFF_DUTY_SELF_ITEMS_HEADER"] = "Consumibles"
L["BUFF_DUTY_SELF_ITEMS_NOTE"] = "si tienes uno en las bolsas"
--[[
    Hover text on the Consumables box's Well Fed row, whose buff food is
    whichever the Food macro would eat. %s is the client's name for Well Fed.
]]
L["BUFF_DUTY_WELL_FED_DESCRIPTION_FORMAT"] =
	'Se muestra mientras te falte "%s" y lleves comida con beneficio. Haz clic en él en la ventana para comer la mejor que tengas.'
-- The Consumables box's Scrolls row: one icon per scroll buff you're missing, for the types checked under it.
L["BUFF_DUTY_SCROLLS"] = "Pergaminos"
L["BUFF_DUTY_SCROLLS_DESCRIPTION"] =
	"Muestra un pergamino por cada beneficio de pergamino que te falte mientras lleves ese pergamino. Haz clic en uno en la ventana para leerlo. Los tipos de pergamino que vigila son los marcados abajo."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Beneficios de arma"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Marca lo que debe llevar cada arma. La ventana lo ofrece cuando falta o está por agotarse, si lo tienes en las bolsas y es apto para el arma."
-- The one timing for every weapon buff, at the top of the panel, captioned Refresh Under (BUFF_DUTY_REFRESH).
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Establece cuándo se vuelve a ofrecer un beneficio de arma: cuando ya no está activo o cuando le queda menos de este tiempo."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Aceites"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Piedras"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Cebos"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Ofrece %s para tu arma (%s). Mientras el arma no lleve ninguna de las opciones marcadas, se ofrece cada una que tengas."
L["BUFF_DUTY_SELF_ENABLE"] = "Tus beneficios propios"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Muestra en la parte superior de la ventana tus propios beneficios cuando faltan o están por agotarse: los que solo puedes lanzarte a ti mismo, como una armadura o Fuego interno, y tus beneficios de grupo sobre ti. Elige cuáles en Beneficios propios."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Tus beneficios de arma"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Muestra los venenos, imbuiciones, aceites, piedras y cebos que faltan o están por agotarse en tus armas, junto con tus beneficios propios en la parte superior de la ventana. Haz clic en uno para aplicarlo. Elige cuáles en Beneficios de arma."

-- The window itself
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Lo lanza sobre %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Lo aplica a tu arma (%s)."
L["BUFF_DUTY_TOOLTIP_USE"] = "Nadie en tu grupo tiene una piedra de alma. Usa una sobre %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Nadie en tu grupo tiene una piedra de alma. Crea una."
-- A Firestone or Spellstone icon with none in the bags conjures one.
L["BUFF_DUTY_TOOLTIP_CREATE_WEAPON"] = "No tienes ninguna en las bolsas. Crea una."
-- A Self-Buffs consumable's icon (Winterfall Firewater).
L["BUFF_DUTY_TOOLTIP_USE_ITEM"] = "Usa uno de tus bolsas."
L["BUFF_DUTY_TOOLTIP_READ"] = "Lee uno de tus bolsas."
--[[
    The Options line at the foot of the Buff Duty window, and the menu it opens: the window's switches, its
    consumables and weapon buffs. %s in the weapon row's hover is the poison, imbue, oil, stone or lure.
]]
L["BUFF_DUTY_MENU_OPTIONS"] = "Opciones"
L["BUFF_DUTY_MENU_WEAPON_DESCRIPTION_FORMAT"] = "Ofrece %s en la ventana cuando a un arma le falta su beneficio."
L["BUFF_DUTY_MENU_ALL_SETTINGS"] = "Todos los ajustes del Turno de beneficios"
L["BUFF_DUTY_MENU_ALL_SETTINGS_DESCRIPTION"] =
	"Abre los ajustes del Turno de beneficios, con cada momento, clase y beneficio que la ventana puede mostrar."
-- The Options menu's Window Opacity row, and its flyout of 0% to 100%. %d is the percent.
L["BUFF_DUTY_MENU_OPACITY"] = "Opacidad de la ventana"
L["BUFF_DUTY_MENU_OPACITY_DESCRIPTION"] =
	"Ajusta lo opaco que es el fondo de la ventana del Turno de beneficios. El texto y los iconos no cambian."
L["BUFF_DUTY_MENU_OPACITY_PERCENT"] = "%d%%"
-- The Options menu's Buff Food row, and its flyout of the buff food in your bags. In the food row's hover, the first %s is the food, the second the Well Fed buff's name.
L["BUFF_DUTY_MENU_BUFF_FOOD"] = "Comida con beneficio"
L["BUFF_DUTY_MENU_FOOD_DESCRIPTION_FORMAT"] =
	'Ofrece %s cuando necesitas "%s". Desactivado, lo salta y pasa a la siguiente mejor comida con beneficio de tus bolsas.'
L["BUFF_DUTY_MENU_NO_BUFF_FOOD"] = "No hay comida con beneficio en tus bolsas."
-- The Self-Buffs buff food icon, while you aren't Well Fed.
L["BUFF_DUTY_TOOLTIP_EAT"] = "Come una de tus bolsas. Quédate sentado hasta estar Bien alimentado."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Lo lanza sobre %s y su grupo."
-- A raid group icon's tooltip, its last line: the members who need it (%s, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT).
L["BUFF_DUTY_TOOLTIP_NEEDS"] = "Lo necesitan: %s."
-- A Return the Favor icon: the click targets them and casts; a right-click drops them from the list.
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Selecciona a %s como objetivo y lo lanza. Haz clic derecho para quitarlo de esta lista."
-- The Ask row under Target: its label (%s is the target's name in their class color), and its icons' tooltip: who the whisper goes to, or, once asked, who and the whole minutes until they can be asked again.
L["BUFF_DUTY_ASK_TARGET_ROW"] = "Pedir a %s"
L["BUFF_DUTY_TOOLTIP_ASK_TARGET"] = "Le susurra a %s para pedírselo."
L["BUFF_DUTY_TOOLTIP_ASKED"] = "Pedido a %s. Podrás volver a pedir en %d min."
-- An Ask for Buffs icon's menu, its ask rows: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it: %s is one or two names (LIST_PAIR_FORMAT), or BUFF_DUTY_OTHERS_ASK_PEOPLE past two.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "Pedir beneficio en %s"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "Susurrar a %s"
-- An Ask for Buffs menu's name row, on the right: the whole minutes left on that player's buff, or Missing once there is none.
L["BUFF_DUTY_OTHERS_MINUTES"] = "%d min"
L["BUFF_DUTY_OTHERS_MISSING"] = "Falta"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "A %s le falta %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "A %s les falta %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "A %d personas les falta el beneficio %s."
-- The whispered ask's {names} past five missing players, when the player has written their own whisper, and the Ask for Buffs menu's whisper row past two players. %d is how many.
L["BUFF_DUTY_OTHERS_ASK_PEOPLE"] = "%d personas"
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"El Turno de beneficios está oculto hasta que te unas a un grupo, vuelvas a conectarte o recargues. Para recuperarlo ahora, haz clic izquierdo en el botón del minimapa. Para dejarlo desactivado para la clase %s, desmarca %s en %s, dentro de %s."

-- The Cast Next Buff key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Lanzar siguiente beneficio"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Esperando a que %s esté a tu alcance."
L["BUFF_KEY_DONE"] = "No queda nada por lanzar."
L["BUFF_KEY_OFF"] = "El Turno de beneficios está desactivado."
--[[
    The Buff Duty window's last line, under Options, while the Cast Next Buff key has none: the options
    command (OPTIONS_COMMAND), then the key's name (BUFF_KEY). Kept to about three lines at the window's
    narrowest, with the command near the start so a line never breaks inside it.
]]
L["BUFF_DUTY_KEY_TIP"] = "En %s, asigna una tecla a %s para lanzar estos beneficios con una sola tecla."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Sin aprender"
L["SECTION_CONSUMABLES"] = "Macros de consumibles"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Texto de la macro"
L["MENU_GROUP_MACRO_STORAGE"] = "Almacenamiento de macro"
L["MENU_MACRO_TAB_CHARACTER"] = "Personaje"
L["MENU_MACRO_TAB_CHARACTER_DESCRIPTION"] =
	"Guarda esta macro en las macros de tu personaje, que solo ve este personaje. Usa General mientras esos espacios estén llenos."
L["MENU_MACRO_TAB_GENERAL"] = "General"
L["MENU_MACRO_TAB_GENERAL_DESCRIPTION"] =
	"Guarda esta macro en las macros generales que comparte toda tu cuenta y ahorra espacios del personaje. Usa las de tu personaje mientras General esté lleno."
L["MENU_MACRO_TAB_NOTE"] = "Mueve la macro ahora y la mantiene en tus barras de acción."
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Rango dinámico"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"El rango dinámico, basado en el nivel de un jugador amistoso, solo se actualiza fuera de combate."
L["MENU_CAST_AT_CURSOR"] = "Lanzar en el cursor"
L["MENU_TARGET_NEAREST_ENEMY"] = "Seleccionar el enemigo más cercano"
L["MENU_TARGET_NEAREST_FRIEND"] = "Seleccionar el aliado más cercano"
L["MENU_CAST_IF_SUMMONED"] = "Lanzar %s si está invocado"
L["MENU_NEVER_TURN_OFF"] = "No desactivar nunca"
L["MENU_LEAVE_FORM_BEFORE"] = "Salir de la forma antes de lanzar"
L["MENU_RIGHT_CLICK_FOR"] = "Clic derecho para %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Clic derecho para versión de grupo"
-- TRANSLATORS: the category menu's title and its gear's tooltip; %d is how many spells it lists, %s its name ("All 6 Heals").
L["MENU_CATEGORY_TITLE"] = "%2$s (%1$d)"
L["MENU_ONCE_PER_COMBAT"] = "Lanzar una vez por combate"
L["MENU_ONCE_PER_TARGET"] = "Lanzar una vez por objetivo"
L["MENU_HIDE_ERRORS"] = "Ocultar errores"
L["MENU_MUTE_ERRORS"] = "Silenciar errores"
L["MENU_SWITCH_TO"] = "Cambiar a %s"
L["MENU_START_AUTO_ATTACK"] = "Iniciar ataque automático"
L["MENU_STOP_ATTACK"] = "Detener ataque"
L["MENU_START_AUTO_SHOT"] = "Iniciar disparo automático"
L["MENU_START_PET_ATTACK"] = "Iniciar ataque de mascota"
L["MENU_START_WAND"] = "Iniciar varita"
L["MENU_STOP_CASTING"] = "Detener lanzamiento"
L["MENU_STOP_CASTING_NOTE"] =
	"Usa Detener lanzamiento en hechizos que no pueden esperar, como interrupciones y disipaciones."
L["MENU_STOP_IF_CHANNELING"] = "No al canalizar"
L["MENU_STOP_IF_STEALTHED"] = "No en sigilo"
L["MENU_DUPLICATE"] = "Duplicar"
L["MENU_DELETE"] = "Borrar"
L["MENU_DELETE_USED_ONE"] = "En 1 barra"
L["MENU_DELETE_USED"] = "En %d barras"
L["MENU_DELETE_DESCRIPTION"] =
	"Borra esta macro, lo que la quita de tus barras de acción, y restablece todas sus opciones. Haz clic en ella o arrástrala desde la página para volver a crearla."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Quita esta copia de la página y la borra de tus macros, lo que la quita de tus barras de acción."
L["MENU_DELETE_CONFIRM"] = "¿Borrar %s? Desaparecerá de tus barras de acción y sus opciones se restablecerán."
-- The same ask for a macro on none of your bars.
L["MENU_DELETE_CONFIRM_UNUSED"] = "¿Borrar %s? Sus opciones se restablecerán."
L["MENU_GROUP_RANK"] = "Rango"
L["MENU_GROUP_WHEN"] = "Cuándo"
L["MENU_GROUP_FIRST"] = "Primero"
L["MENU_GROUP_THEN"] = "Después"
L["MENU_GROUP_ERRORS"] = "Mensajes de error"
L["MENU_GROUP_GROUPED"] = "Hechizos agrupados"
L["MENU_GROUP_TARGET"] = "Objetivo"
L["MENU_PRIORITY_1"] = "Primera prioridad"
L["MENU_PRIORITY_2"] = "Segunda prioridad"
L["MENU_PRIORITY_3"] = "Tercera prioridad"
L["MENU_PRIORITY_DESCRIPTION"] =
	"A quién lo intenta la macro, por orden. Se omite a cada uno cuando no puede recibir el hechizo y, si ninguno puede, se lanza como lo haría el hechizo normal."
L["MENU_UNIT_NONE"] = "Ninguno"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Termina la lista aquí."
L["MENU_UNIT_TARGET"] = "Objetivo"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Lo lanza sobre tu objetivo, cuando puede recibir el hechizo."
L["MENU_UNIT_SELF"] = "Tú mismo"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"Lo lanza sobre ti. Siempre puedes recibirlo, así que nunca se intenta nada después de Tú mismo."
L["MENU_UNIT_PET"] = "Mascota"
L["MENU_UNIT_PET_DESCRIPTION"] = "Lo lanza sobre tu mascota, cuando está invocada y puede recibir el hechizo."
L["MENU_UNIT_FOCUS"] = "Foco"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "Lo lanza sobre tu foco, cuando tienes uno y puede recibir el hechizo."
L["MENU_UNIT_TARGETS_TARGET"] = "Objetivo del objetivo"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Lo lanza sobre el objetivo de tu objetivo, como el tanque al que golpea el enemigo que tienes seleccionado, cuando puede recibir el hechizo."
L["MENU_UNIT_MOUSEOVER"] = "Bajo el cursor"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Lo lanza sobre quien esté bajo tu cursor, en el mundo o en un marco de unidad, cuando puede recibir el hechizo."
L["MENU_OPTIONS_COUNT"] = "%d opciones"
L["MENU_HIGHEST"] = "Rango máximo"
L["MENU_HIGHEST_DESCRIPTION"] = "Lanza el rango más alto que conoces."
L["MENU_FIXED_RANK_DESCRIPTION"] = "Siempre lanza %s, a cualquier nivel."
L["MENU_ANY_TIME"] = "Siempre"
L["MENU_ANY_TIME_DESCRIPTION"] = "Lanza dentro o fuera de combate."
L["MENU_IN_COMBAT"] = "En combate"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Solo lanza en combate. Fuera de combate la macro no hace nada, incluidos sus objetos."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Solo lanza fuera de combate. En combate la macro no hace nada, incluidos sus objetos."
L["MENU_EVERY_PRESS"] = "Cada pulsación"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Lanza cada vez que la pulsas."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "Un clic derecho lanza %s. Un clic izquierdo sigue lanzando %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Permite que la macro lance %s. De los hechizos marcados aquí, lanza el último que aprendiste, así que sube a medida que entrenas."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] = "Aún no aprendido. Márcalo ahora y la macro lo usará en cuanto lo aprendas."
L["MENU_PET_DESCRIPTION"] = "Mientras tu %s esté invocado, la macro lanza %s en lugar de volver a invocarlo."
L["MENU_STANCE_DESCRIPTION"] = "Cambia primero a %s, salvo que ya estés en ella."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Lo usa antes del lanzamiento. Los objetos van en el orden en que los marques, y el número junto a cada uno indica su posición."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Usar %s"
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Añade a la página otra copia de esta macro, empezando con estas opciones, para que puedas configurarla de otra forma."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Condicionales"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Abre el panel Condicionales junto a la ventana del Libro de hechizos mejorado, donde la macro puede lanzar otro hechizo cuando se cumple una condición, como mantener Mayús o Especialización 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "Un condicional usa el clic derecho. Quítalo para activar esto."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Condicionales"
L["CONDITIONALS_HINT"] = "Se comprueban de arriba abajo; lanza el primero que se cumple."
L["CONDITIONALS_OTHERWISE"] = "Si no"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "y"
L["CONDITIONALS_AND_MENU"] = "Añadir segunda condición"
L["CONDITIONALS_AND_DESCRIPTION"] = "Añade una segunda condición. La fila solo lanza cuando se cumplen ambas."
L["CONDITIONALS_DROP_SECOND"] = "Quitar esta condición"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "La fila vuelve a comprobar solo su primera condición."
L["CONDITIONALS_ADD"] = "+ Añadir condición"
L["CONDITIONALS_ADD_DESCRIPTION"] = "Añade una fila al final. Elige su condición y luego el hechizo que lanza."
L["CONDITIONALS_ADD_LIMIT"] = "Hasta %d filas. Cada una se suma al texto de la macro, que admite 255 bytes."
L["CONDITIONALS_PICK_SPELL"] = "Elegir un hechizo"
L["CONDITIONALS_PICKING"] = "Haz clic en un hechizo de la página"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Haz clic aquí y luego en un hechizo de la página para lanzarlo en esta fila. O arrastra un hechizo de la página a esta casilla."
L["CONDITIONALS_PICK_BANNER"] = "Haz clic en un hechizo para usarlo. Esc o clic derecho para cancelar."
L["CONDITIONALS_CANNOT_PICK"] = "Un condicional solo puede lanzar un hechizo aprendido."
L["CONDITIONALS_EMPTY"] =
	"Aún no hay condiciones. Añade una para lanzar otro hechizo mientras mantienes Mayús, en combate y más."
L["CONDITIONALS_SHADOWED"] = "Nunca lanza: la fila %d de arriba se cumple siempre que esta lo hace, y lanza antes."
L["CONDITIONALS_KEY_DRAG"] = "Arrastra un hechizo aquí"
L["CONDITIONALS_ACTION_DROP"] = "Lanzarlo en esta fila"
L["CONDITIONALS_ACTION_PICK"] = "Elegir de la página"
L["CONDITIONALS_ACTION_USE"] = "Usar en un condicional"
L["CONDITIONALS_ACTION_CANCEL"] = "Cancelar selección"
L["CONDITIONALS_REMOVE"] = "Quitar"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Quita esta fila."
L["CONDITIONALS_REORDER"] = "Reordenar"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Arrástrala sobre otra fila para moverla allí. Lanza la primera fila que se cumple."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Mayús pulsado"
L["CONDITION_SHIFT_SHORT"] = "Mayús"
L["CONDITION_SHIFT_DESCRIPTION"] = "Se cumple mientras mantienes Mayús al pulsar la macro."
L["CONDITION_CTRL"] = "Ctrl pulsado"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "Se cumple mientras mantienes Ctrl al pulsar la macro."
L["CONDITION_ALT"] = "Alt pulsado"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Se cumple mientras mantienes Alt al pulsar la macro."
L["CONDITION_RIGHT_CLICK"] = "Clic derecho"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "Se cumple cuando haces clic derecho en la macro de tu barra de acción."
L["CONDITION_IN_COMBAT"] = "En combate"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Se cumple mientras estás en combate."
L["CONDITION_OUT_OF_COMBAT"] = "Fuera de combate"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Se cumple mientras estás fuera de combate."
L["CONDITION_SPEC_1"] = "Especialización 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Se cumple mientras tu primera especialización de talentos está activa."
L["CONDITION_SPEC_2"] = "Especialización 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Se cumple mientras tu segunda especialización de talentos está activa."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (actual)"
L["CONDITION_COMBAT_BLOCKED"] =
	"No disponible mientras Cuándo esté en En combate o Fuera de combate. La macro ya no hace nada en el otro caso, así que esto se cumpliría siempre o nunca."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"No disponible mientras Hechizos agrupados tenga activado Clic derecho para %s, que ya ocupa el clic derecho. Desactívalo para usar el clic derecho aquí."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 condicional"
L["SUBTEXT_CONDITIONALS"] = "%d condicionales"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Secuencia de lanzamiento"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Abre el panel Secuencia de lanzamiento junto a la ventana del Libro de hechizos mejorado, donde cada pulsación de la macro lanza el siguiente hechizo por orden, como Corrupción, luego Maldición de agonía y luego Inmolar."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d pasos"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Secuencia de lanzamiento"
L["CAST_SEQUENCE_HINT"] =
	"Cada pulsación lanza el siguiente paso. Un paso que falla se vuelve a intentar en la siguiente pulsación."
L["CAST_SEQUENCE_FIRST"] = "Primero"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "El hechizo de la propia macro siempre va primero."
L["CAST_SEQUENCE_ADD"] = "+ Añadir paso"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Añade un paso al final. Luego elige el hechizo que lanza."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Hasta %d pasos después del de la macro. Cada uno se suma al texto de la macro, que admite 255 bytes."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"Solo un hechizo aprendido, y no Disparar, puede ser un paso de una secuencia de lanzamiento."
L["CAST_SEQUENCE_ACTION_DROP"] = "Lanzarlo en este paso"
L["CAST_SEQUENCE_ACTION_USE"] = "Usar en la secuencia de lanzamiento"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Quita este paso."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Arrástralo sobre otro paso para moverlo allí."
L["CAST_SEQUENCE_END"] = "Tras el último paso"
L["CAST_SEQUENCE_END_LOOP"] = "Volver a empezar"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"La siguiente pulsación vuelve a lanzar el hechizo de la propia macro, y la secuencia da la vuelta."
L["CAST_SEQUENCE_END_STOP"] = "Detener (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Termina en NULL, un hechizo que nadie conoce, así que las siguientes pulsaciones no lanzan nada hasta que un reinicio vuelva a empezar la secuencia."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Detener"
L["CAST_SEQUENCE_RESET"] = "Volver a empezar cuando"
L["CAST_SEQUENCE_RESET_NEVER"] = "Nunca"
L["CAST_SEQUENCE_RESET_TARGET"] = "Cambia el objetivo"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] =
	"Vuelve a empezar la secuencia por su primer paso cuando cambias de objetivo."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Termina el combate"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] =
	"Vuelve a empezar la secuencia por su primer paso cuando sales de combate."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Mayús pulsado"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl pulsado"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt pulsado"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Pulsar la macro con esta tecla mantenida vuelve a empezar la secuencia y lanza su primer paso."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Segundos inactiva"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Vuelve a empezar la secuencia cuando la macro lleva este tiempo sin pulsarse."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Desactivado"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d segundos inactiva"
-- TRANSLATORS: the Seconds Idle row's value, the seconds it waits ("5 Seconds").
L["CAST_SEQUENCE_RESET_SECONDS_VALUE"] = "%d segundos"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"Se detiene para siempre: sin nada que la reinicie, la secuencia se queda en NULL hasta que la macro cambie o recargues la interfaz. Elige un reinicio en Volver a empezar cuando."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'En espera mientras la opción "Lanzar %s si está invocado" esté activa, ya que escribe su propia línea de lanzamiento. Desactívala para usar la secuencia.'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Haz clic aquí y luego en un hechizo de la página para lanzarlo en este paso. O arrastra un hechizo de la página a esta casilla."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "Secuencia de %d pasos"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Mostrar todos los rangos de hechizo"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Mostrar hechizos agrupados"
L["SETTINGS_SHOW_UNLEARNED"] = "Mostrar hechizos sin aprender"
L["SETTINGS_MARK_ALL_PLACED"] = "Marcar todos los hechizos como colocados"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Ninguna macro de esta página vuelve a brillar, esté o no en tus barras. Un hechizo que aprendas después seguirá brillando hasta que lo coloques. Volver a resaltar hechizos sin colocar, en el menú del engranaje, lo deshace."
L["SETTINGS_HIGHLIGHT_AGAIN"] = "Volver a resaltar hechizos sin colocar"
L["SETTINGS_HIGHLIGHT_AGAIN_DESCRIPTION"] =
	"Deshace Marcar todos los hechizos como colocados, así que cada hechizo que no esté en tus barras vuelve a brillar."
L["SORT_BY_CATEGORY"] = "Ordenar por categoría"
L["SORT_BY_SCHOOL"] = "Ordenar por escuela"
L["SORT_DESCRIPTION"] =
	"Agrupa las macros de la página por categoría, es decir, para qué sirve cada hechizo, como Ataques, Curaciones o Reutilizaciones defensivas, o por escuela, las pestañas del libro de hechizos de las que proceden."
L["CATEGORY_ATTACKS"] = "Ataques"
L["CATEGORY_FINISHERS"] = "Remates"
L["CATEGORY_CROWD_CONTROL"] = "Control de masas"
L["CATEGORY_HYBRID"] = "Híbridos"
L["CATEGORY_HEALS"] = "Curaciones"
L["CATEGORY_BUFFS"] = "Beneficios"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Reutilizaciones ofensivas"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Reutilizaciones defensivas"
L["CATEGORY_SELF_BUFFS"] = "Beneficios propios"
L["CATEGORY_SHOCKS"] = "Choques"
L["CATEGORY_TRAPS"] = "Trampas"
L["CATEGORY_TOTEMS"] = "Tótems"
L["CATEGORY_SEALS"] = "Sellos"
L["CATEGORY_BLESSINGS"] = "Bendiciones"
L["CATEGORY_CURSES"] = "Maldiciones"
L["CATEGORY_PETS"] = "Mascotas"
L["KIND_RESURRECT"] = "Resurrecciones"
L["CATEGORY_TELEPORTS"] = "Teletransportes y portales"
L["CATEGORY_UTILITY"] = "Utilidad"
L["CATEGORY_THREAT"] = "Provocaciones y amenaza"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Ataques básicos"
L["CATEGORY_STANCES"] = "Actitudes"
L["CATEGORY_FORMS"] = "Formas"
L["CATEGORY_AURAS"] = "Auras"
L["CATEGORY_ASPECTS"] = "Aspectos"
L["CATEGORY_RACIALS"] = "Raciales"
L["CATEGORY_TRACKING"] = "Rastreo"
L["CATEGORY_PROFESSIONS"] = "Profesiones"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_PET"] = "Mascota"
L["SUBTEXT_CURSOR"] = "En cursor"
L["SUBTEXT_STANCE"] = "Actitud"
L["SUBTEXT_USE_ITEMS"] = "Usar objetos"
L["SUBTEXT_PET_ATTACK"] = "Ataque mascota"
L["SUBTEXT_DYNAMIC_RANK"] = "Rango dinám."
L["SUBTEXT_DYNAMIC_ITEM"] = "Objeto dinám."
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Rango dinám., Objeto dinám."
L["SUBTEXT_MAX_RANK"] = "Rango máximo"
L["SUBTEXT_TARGET_ENEMY"] = "Enemigo cercano"
L["SUBTEXT_TARGET_FRIEND"] = "Aliado cercano"
L["SUBTEXT_TARGET_PRIORITY"] = "Objetivo"
L["SUBTEXT_GROUPED_SPELLS"] = "Agrupado"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1 por combate"
L["SUBTEXT_ONCE_PER_TARGET"] = "1 por objetivo"
L["SUBTEXT_COMBAT_ONLY"] = "Solo combate"
L["SUBTEXT_NO_COMBAT"] = "Fuera de combate"
L["SUBTEXT_LEAVE_FORM"] = "Salir de forma"
L["SUBTEXT_NO_TOGGLE"] = "Nunca desactivar"
L["SUBTEXT_WAND"] = "Varita"
L["SUBTEXT_START_ATTACK"] = "Ataque auto."
L["SUBTEXT_STOP_ATTACK"] = "Detener ataque"
L["SUBTEXT_STOP_CASTING"] = "Detener lanz."
L["SUBTEXT_STOP_IF_CHANNELING"] = "No al canalizar"
L["SUBTEXT_STOP_IF_STEALTHED"] = "No en sigilo"
L["SUBTEXT_HIDE_ERRORS"] = "Ocultar errores"
L["SUBTEXT_MUTE_ERRORS"] = "Silenciar errores"
L["SUBTEXT_OPTIONS_COUNT"] = "%d opciones"
L["SUBTEXT_TOO_LONG"] = "Muy larga"
L["SUBTEXT_LEARN_LEVEL"] = "Nivel %d"
L["SUBTEXT_TALENT"] = "Talento"
L["SUBTEXT_LEARN_RANK"] = "Aprender %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Enseñar a mascota"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Aún sin aprender"
L["TOOLTIP_LEARN_LEVEL"] = "Tu instructor de clase lo enseña a nivel %d."
L["TOOLTIP_LEARN_TALENT"] = "Se aprende con tus talentos."
L["TOOLTIP_NOT_ON_BARS"] = "No está en tus barras de acción"
L["TOOLTIP_TOO_LONG"] = "Demasiado larga: %d / %d bytes. Desactiva una opción para acortarla."
L["TOOLTIP_OPTIONS_ON"] = "Opciones activadas: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clic o arrastrar"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Colocar en tus barras de acción"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clic derecho"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Opciones de la macro"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Clic central"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Restablecer opciones de la macro"
-- TRANSLATORS: the category menu's last action; %d and %s as in MENU_CATEGORY_TITLE ("Reset All 6 Heals").
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Restablecer %2$s (%1$d)"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s vuelve a tener sus opciones predeterminadas."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Todas las macros de %s vuelven a tener sus opciones predeterminadas."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Descarta las opciones que configuraste en cada hechizo de aquí, para que todos vuelvan a seguir sus valores predeterminados. Las copias de foco y los duplicados se conservan."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"¿Restablecer las opciones que configuraste en todos los hechizos de %s? Cada uno volverá a seguir sus valores predeterminados."
-- A middle-click on a macro, asked first. %s is the macro.
L["MENU_RESET_MACRO_CONFIRM"] = "¿Restablecer las opciones de %s? Volverá a seguir sus valores predeterminados."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "Macro de %s"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Los hechizos de tu clase como macros de un clic."
-- The click line beneath it reuses MENU_OPEN_SPELLBOOK.
L["TOOLTIP_KEY_CLICK"] = "Clic"
-- What's Next rows' click lines: a spell row turns the Enhanced Spellbook to its tile, a pet ability row opens the Pet Spellbook tab.
L["WHATS_NEXT_CLICK_SPELL"] = "Mostrar en el libro de hechizos mejorado"
L["WHATS_NEXT_CLICK_PET"] = "Mostrar en el libro de hechizos de mascota"

-- Page: Layout
L["PAGE_EMPTY"] = "Aún no hay macros. Visita a tu instructor de clase para aprender tus primeros hechizos."
L["PAGE_NO_MATCHES"] = "Ninguna macro coincide con el filtro. Vacía el cuadro del filtro para verlas todas."
L["PAGE_FILTER"] = "Filtrar hechizos"
L["FILTER_ALL_SCHOOLS"] = "Todas las escuelas"
L["FILTER_ALL_CATEGORIES"] = "Todas las categorías"
L["PAGE_MACRO_SLOTS"] = "Espacios de macros"
L["TOOLTIP_MACRO_SLOTS"] =
	"Cada macro que colocas ocupa un espacio de macro. Los espacios de personaje son de este personaje y se llenan primero. Los espacios generales los comparten todos los personajes de tu cuenta."
L["PAGE_MACRO_GENERAL"] = "Generales"
L["PAGE_MACRO_CHARACTER"] = "Personaje"
L["PAGE_NO_MATCHES_FOR"] = 'Ningún hechizo coincide con "%s".'
-- A category gear's tooltip and menu title for a category of one spell; more take MENU_CATEGORY_TITLE.
L["PAGE_CATEGORY_SETTINGS_ONE"] = "Opciones de este hechizo"
-- The body of the page's Settings gear tooltip, under its title SETTINGS.
L["TOOLTIP_PAGE_SETTINGS_DESCRIPTION"] = "Elige qué hechizos muestra la página."
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Activa o desactiva una opción para todos los hechizos de esta categoría a la vez. Los hechizos que aún no están en tus barras guardan el ajuste para cuando los coloques."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(continuación)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "¿Qué viene ahora?"
L["WHATS_NEXT_EMPTY"] = "No hay hechizos que mostrar."
-- The same page while Show Known Spells is off: %s is that toggle's name (WHATS_NEXT_SHOW_KNOWN).
L["WHATS_NEXT_EMPTY_KNOWN_HIDDEN"] =
	"Ahora mismo no hay nada nuevo que aprender. Marca %s en el menú del engranaje para ver lo que ya has aprendido."
L["WHATS_NEXT_ALL_SOURCES"] = "Todos los orígenes"
L["WHATS_NEXT_ANY_LEVEL"] = "Cualquier nivel"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LIST_PAIR_FORMAT or LIST_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), and [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "Ya puedes aprender %s."
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "No lo olvides: también puedes aprender %s."
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "Tu mascota ya puede aprender %s."
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "No lo olvides: tu mascota también puede aprender %s."
L["LEVEL_UP_DEMON_SPELLS"] = "Tus demonios ya pueden aprender %s."

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Disponible ahora"
L["WHATS_NEXT_STATUS_SOON"] = "Próximamente"
L["WHATS_NEXT_STATUS_LATER"] = "Aún no disponible"
L["WHATS_NEXT_STATUS_MISSING"] = "Requiere otro hechizo"
L["WHATS_NEXT_STATUS_TALENT"] = "Talentos no elegidos"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Talentos y runas no elegidos"
L["WHATS_NEXT_STATUS_KNOWN"] = "Conocidos"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Disponible ahora"
L["WHATS_NEXT_SHORT_SOON"] = "Próximamente"
L["WHATS_NEXT_SHORT_LATER"] = "Aún no"
L["WHATS_NEXT_SHORT_MISSING"] = "Requiere otro hechizo"
L["WHATS_NEXT_SHORT_TALENT"] = "No elegido"
L["WHATS_NEXT_SHORT_KNOWN"] = "Conocido"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Hechizo inicial"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Instructor"
L["WHATS_NEXT_SOURCE_BOOK"] = "Libro"
L["WHATS_NEXT_SOURCE_QUEST"] = "Misión"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talento"
L["WHATS_NEXT_SOURCE_RUNE"] = "Runa"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Origen"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Nivel requerido"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Tu clase empieza con él."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Te lo enseña tu instructor de clase."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "Lo enseña un objeto, como un libro de una mazmorra o de una banda."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] =
	"Lo enseña una misión de clase. Tu instructor de clase puede indicarte dónde empieza."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Gasta un punto de talento en él para aprenderlo."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Graba su runa para aprenderlo."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Aprende antes %s."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "Rangos de %s"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Mayús + Clic"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Enlazar en el chat"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Ordenar por disponibilidad"
L["WHATS_NEXT_SORT_LEVEL"] = "Ordenar por nivel"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Ordenar por disponibilidad muestra primero los hechizos que puedes aprender ahora y al final los que ya conoces. Ordenar por nivel muestra cada hechizo bajo el nivel en que se aprende."
L["WHATS_NEXT_SHOW_KNOWN"] = "Mostrar hechizos conocidos"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Muestra también, después del resto, los hechizos que ya has aprendido."
L["WHATS_NEXT_SHOW_TALENTS"] = "Mostrar talentos no elegidos"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Mostrar talentos y runas no elegidos"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Muestra también los hechizos de talento que no has elegido. Esos se aprenden gastando puntos de talento, no con un instructor."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Libro de hechizos de mascota"
L["PET_SPELLBOOK_EMPTY"] = "Tu mascota no tiene hechizos que mostrar."
L["PET_SPELLBOOK_NO_PET"] = "No tienes mascota invocada. Invoca a tu mascota para ver sus hechizos."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Habilidades"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Pasivas"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Autolanzar activado"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Autolanzar desactivado"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "¿Qué viene ahora? (mascota)"
L["WHATS_NEXT_PET_EMPTY"] = "No hay habilidades de mascota que mostrar."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s, nivel %d, %s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Puntos de adiestramiento: %d de %d"
L["WHATS_NEXT_PET_NO_PET"] = "No tienes mascota invocada: se muestra lo que has aprendido con Adiestrar bestia."
L["WHATS_NEXT_PET_NO_PET_SUMMON"] = "No tienes mascota invocada: invoca a tu mascota para ver lo que ya sabe."
L["WHATS_NEXT_PET_NO_DEMON"] = "No tienes ningún demonio invocado: invoca uno para ver lo que ya sabe."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Listo para enseñar"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Habilidades de otras familias"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Listo para enseñar"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Otra familia"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Instructor de mascotas"
L["WHATS_NEXT_PET_SOURCE_HUNTER_TRAINER"] = "Instructor de cazadores"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Doma"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Instructor de demonios"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Nivel de mascota requerido"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Puntos de adiestramiento"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Te la enseña un instructor de mascotas. Después enséñasela a tu mascota con Adiestrar bestia."
L["WHATS_NEXT_PET_TOOLTIP_HOW_HUNTER_TRAINER"] =
	"Tu instructor de cazadores se la enseña a la mascota que tengas invocada."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Doma una bestia que la conozca y lucha a su lado hasta aprenderla. Después enséñasela con Adiestrar bestia a cualquier mascota que pueda aprenderla."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING_NEW_PET"] =
	"Doma una bestia que la conozca y tu nueva mascota la traerá consigo. Nada se la enseña a una mascota que ya tengas."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "Ya la conoces. Enséñasela a tu mascota con Adiestrar bestia."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Compra su grimorio a un instructor de demonios y úsalo mientras esté invocado el demonio que lo aprende."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER_TEACHES"] = "Tu instructor de demonios la enseña."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimorio"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Tienes su grimorio en las bolsas. Úsalo mientras este demonio esté invocado."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Tu mascota no puede aprenderla."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Bestias que la conocen"

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Ordenar por disponibilidad muestra primero las habilidades que tu mascota puede aprender ahora y al final las que ya conoce. Ordenar por nivel muestra cada habilidad bajo el nivel de mascota que requiere."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Mostrar habilidades conocidas"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Muestra también, después del resto, las habilidades que tu mascota ya conoce. Un cazador sin mascota invocada ve las que ha aprendido."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Mostrar habilidades de otras familias"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Muestra también las habilidades que tu mascota no puede aprender, como Acechar de un felino para un lobo, o las de otro demonio."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Asignación de teclas"
L["OPTIONS_KEY_SET"] = "Asignar tecla"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Abre la lista de asignación de teclas del juego, donde Good to Go tiene su propia sección."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Abre y cierra el Libro de hechizos mejorado. También tiene su propia pestaña en tu libro de hechizos."
-- The macro line, /click GtGBuffKey, sits in a box under this to copy (a translation may still place it with %s).
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Lanza el siguiente beneficio que ofrece tu ventana de Turno de beneficios, uno por pulsación, fuera de combate. Para pulsarlo desde una macro, copia en ella la línea de abajo: haz clic en la línea y pulsa Ctrl+A y Ctrl+C."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Rangos de hechizo en descripciones"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"La descripción de cada habilidad muestra sus rangos y el nivel que requiere cada uno: en blanco los rangos que conoces, en verde los que podrías entrenar ya y en gris los que están por llegar. Es una forma rápida de comprobar que usas tu mejor rango, para que siempre juegues a tu mejor nivel. Los rangos no se muestran en combate, para que tus descripciones sean breves cuando más importa."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Activar rangos de hechizo en descripciones"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Añade los rangos de cada habilidad a su descripción en tus barras de acción, en el libro de hechizos del juego y en otros addons. Al desactivarlo, esas descripciones quedan como las muestra el juego. La ventana del Libro de hechizos mejorado muestra los rangos en cualquier caso."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Borrar macros"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Borra las macros que creó el Libro de hechizos mejorado, lo que también las quita de tus barras de acción. Tus propias macros nunca se tocan, y la página vuelve a crear cualquiera de ellas cuando haces clic en ella o la arrastras."
-- The two rows' captions, each beside a Delete button (OPTIONS_DELETE).
L["OPTIONS_DELETE_CHARACTER_MACROS_CAPTION"] = "Macros de este personaje"
L["OPTIONS_DELETE_GENERAL_MACROS_CAPTION"] = "Macros generales"
L["OPTIONS_DELETE"] = "Borrar"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Borra las macros del Libro de hechizos mejorado de la pestaña de macros de este personaje. Tus otros personajes conservan las suyas hasta que hagas lo mismo con ellos."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"¿Borrar todas las macros del Libro de hechizos mejorado de este personaje? También desaparecen de tus barras de acción."
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Borra las macros del Libro de hechizos mejorado de la pestaña Macros generales, que comparten todos los personajes de tu cuenta, así que tus otros personajes también pierden las suyas ahí."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"¿Borrar todas las macros generales del Libro de hechizos mejorado? Todos los personajes de tu cuenta las pierden, y también desaparecen de tus barras de acción."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Muestra una macro por cada rango inferior que conozcas de un hechizo, después de la del propio hechizo, y cada una lanza siempre su rango."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Muestra todos los hechizos que conoces de un grupo de hechizos, como Purificar y Limpiar. Si está desactivado, solo se muestra el último aprendido, aunque las macros de los demás se siguen actualizando."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Muestra los hechizos de clase que aún no has aprendido en una sección Sin aprender, para que puedas colocar sus macros antes."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Coloca el hechizo donde apunta el cursor, sin círculo de selección."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lanza el rango más alto que admite el nivel del jugador amistoso."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Detiene primero lo que estés lanzando, para que este hechizo salga al instante."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Detiene primero tu ataque automático cuerpo a cuerpo."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"No hace nada mientras canalizas un hechizo, así que pulsarla nunca rompe la canalización."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"No hace nada mientras estás en sigilo, así que pulsarla nunca rompe Sigilo ni Acechar."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "Sale primero de tu forma actual, para que se pueda lanzar el hechizo."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Selecciona primero al enemigo más cercano cuando no tienes ningún enemigo vivo como objetivo."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Selecciona primero al aliado más cercano cuando no tienes ningún aliado vivo como objetivo."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Envía también a tu mascota a atacar a tu objetivo."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Inicia tu ataque automático cuerpo a cuerpo después del lanzamiento."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Inicia Disparo automático o tu varita después del lanzamiento."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lanza una vez y no vuelve a hacerlo hasta que cambie tu objetivo."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lanza una vez y no vuelve a hacerlo hasta que termine el combate o cambie tu objetivo."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Mantiene activa la forma o el aspecto cuando vuelves a pulsar la macro, en lugar de desactivarlo."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Borra el texto de error rojo que la macro deja en pantalla."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Silencia el sonido de error mientras se ejecuta la macro."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Mostrar/ocultar Libro de hechizos mejorado"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Como medida de seguridad, la lista de asignación de teclas no se puede abrir durante el combate."
L["KEY_BINDINGS_LOCATION"] = "Abre el menú del juego, luego %s, luego %s, y busca la sección Good to Go."

-- Macro errors and prints: the Enhanced Spellbook's, then the Consumable Macros' too-long notice.
L["ERROR_MACRO_SLOTS_FULL"] = "No hay espacios de macros libres. Borra algunas de tus macros en /m para hacer sitio."
L["ERROR_MACRO_WINDOW_OPEN"] = "Cierra primero la ventana de macros."
L["CHAT_MACROS_DELETED"] = "Se han borrado %d macros."
L["CHAT_MACROS_DELETED_ONE"] = "Se ha borrado 1 macro."
L["CHAT_MACRO_TOO_LONG"] =
	'La macro "%s" ocupa %d bytes con sus opciones activadas, más de los %d que admite una macro. Desactiva una opción para acortarla.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'La macro "%s" ocupa %d bytes, más de los %d que admite una macro, así que su última línea queda cortada.'
