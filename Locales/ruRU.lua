local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "ruRU")
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
	"Версия %s. Настройки (включая возможность отключить это сообщение) находятся в меню Настройки > Модификации > Good to Go. Нравится этот аддон? Расскажите другу, добавьте его в избранное на CurseForge или поставьте ему звезду на GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Помогите Good to Go прокачаться"
L["OPTIONS_LEVEL_UP_THANKS"] = "Спасибо, что выбрали Good to Go!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Бинты"
L["MACRO_EXPLOSIVES"] = "- Взрывчатка"
L["MACRO_FEED_PET"] = "- Корм. питомца"
L["MACRO_FOOD"] = "- Еда"
L["MACRO_HEALTH_POTION"] = "- Леч. зелье"
L["MACRO_HEALTHSTONE"] = "- Кам. здоровья"
L["MACRO_MANA_GEM"] = "- Мана-камень"
L["MACRO_MANA_POTION"] = "- Зелье маны"
L["MACRO_POISONS"] = "- Яды"
L["MACRO_SOULSTONE"] = "- Кам. души"
L["MACRO_WATER"] = "- Вода"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s и %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s и %s"
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

L["DIET_BREAD"] = "Хлеб"
L["DIET_CHEESE"] = "Сыр"
L["DIET_FISH"] = "Рыба"
L["DIET_FRUIT"] = "Фрукты"
L["DIET_FUNGUS"] = "Грибы"
L["DIET_MEAT"] = "Мясо"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Похоже, вы нашли ошибку! Предмет %s (%s) нельзя использовать в локации %s > %s (%s). Пожалуйста, сообщите об этом, чтобы мы могли её исправить. Спасибо! %s"
L["MESSAGE_NO_ITEM"] = "%s: в ваших сумках нет ничего подходящего."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Некоторые макросы Good to Go не удалось создать, потому что все ячейки макросов заняты. Освободите ячейку, удалив ненужные макросы, или отключите лишние макросы Good to Go в меню Настройки > Модификации > Good to Go > Макросы расходуемых предметов."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Ваши макросы готовы. Введите %s, откройте вкладку %s и перетащите - Еда, - Вода и остальные на панели команд."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s теперь в списке игнорирования этого персонажа."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] =
	"Из списка игнорирования этого персонажа убран 1 предмет."
L["MESSAGE_IGNORE_CLEARED_MANY"] =
	"Из списка игнорирования этого персонажа убрано предметов: %d."

L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности интерфейс настроек нельзя открыть в бою."

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

L["READINESS_TITLE"] = "Отчёт о готовности"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Не хватает баффов:"
L["READINESS_EXPIRING"] = "Скоро истекает:"
L["READINESS_MISSING_ITEMS"] = "Не хватает предметов:"
L["READINESS_DAMAGED_GEAR"] = "Повреждённое снаряжение:"
L["READINESS_CHARACTER"] = "Персонаж:"
L["READINESS_QUESTIONABLE_GEAR"] = "Надето небоевое снаряжение:"

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
L["READINESS_FLASK"] = "Настой или 2 эликсира"
L["READINESS_PET_FORMAT"] = "%s (питомец)"
L["READINESS_SCROLLS"] = "Свитки"
L["READINESS_SOULSTONE"] = "Камень души не активен"
L["READINESS_HEALTHSTONE"] = "Камень здоровья"
L["READINESS_MANA_GEM"] = "Мана-камень"
L["READINESS_HEALING_POTION"] = "Лечебное зелье"
L["READINESS_MANA_POTION"] = "Зелье маны"
L["READINESS_BANDAGES"] = "Бинты"
L["READINESS_PVP_ON"] = "PvP включён"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d мин"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s меньше 1 мин"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 нераспределённое очко талантов"
L["READINESS_UNSPENT_TALENTS_MANY"] = "Нераспределённых очков талантов: %d"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] =
	"В данный момент у вас нет подходящей еды для питомца."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] =
	"В данный момент вы не знаете способности %s, %s, %s или %s."
L["TIP_NO_HAND_POISON"] = "Выбранный яд для этого оружия закончился."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "В данный момент вы не знаете способность %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] =
	"%s: в сумках не осталось. ПКМ по %s, чтобы сотворить ещё."
L["TIP_EMPTY_CREATE"] =
	"%s: в сумках не осталось. ПКМ по %s, чтобы создать новый."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Еда с эффектом"
L["FEATURE_SCROLL_BUFFS"] = "Баффы от свитков"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Еда с эффектом и свитки"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Использует еду, дающую эффект "%s", и применяет недостающие баффы от свитков, прежде чем вы начнёте есть.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Текущая еда"
L["MINIMAP_BEST_PET_FOOD"] = "Текущая еда для питомца"
L["MINIMAP_MAIN_HAND_POISON"] = "Яд для правой руки"
L["MINIMAP_OFF_HAND_POISON"] = "Яд для левой руки"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Список игнорирования"
L["MINIMAP_IGNORE_COUNT"] = "Предметов: %d"
L["MENU_IGNORE"] = "Игнорировать"
L["MENU_CLEAR_IGNORE"] = "Очистить список игнорирования"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Отчёт Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "Невыполненных заказов: %d"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Поздравляем, запасы полностью пополнены!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Ваш список пуст."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Список пополнения"
L["MENU_RESTOCKER_DESCRIPTION"] =
	"Покупает предметы из вашего списка и складывает их в банк."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + ПКМ"
L["MENU_OPTIONS"] = "Настройки GtG"
L["MENU_OPTIONS_KEYBIND"] = "Shift + СКМ"

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
L["NOTE_MACRO_FEED_PET"] = 'Макрос "Корм. питомца"'
L["NOTE_MACRO_FOOD_WATER"] = 'Макросы "Еда" и "Вода"'
L["NOTE_MACRO_MANA_GEM"] = 'Макрос "Мана-камень"'
L["NOTE_MACRO_HEALTHSTONE"] = 'Макрос "Кам. здоровья"'
L["NOTE_MACRO_SOULSTONE"] = 'Макрос "Кам. души"'
L["NOTE_MACRO_POISONS"] = 'Макрос "Яды"'

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Призвать, накормить или воскресить"
L["NOTE_PET_MEND_CLICK"] = "ПКМ или в бою"
L["NOTE_HOLD_SHIFT"] = "Удерживая Shift"
L["NOTE_PET_FORCE_REVIVE"] = "Принудительно воскресить"
L["NOTE_HOLD_CONTROL"] = "Удерживая Ctrl"
L["NOTE_PET_DISMISS"] = "Прогнать"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Сотворить"
L["NOTE_CREATE"] = "Создать"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Ещё раз ПКМ"
L["NOTE_LOWER_RANK_BACKUP"] = "Запас рангом ниже"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Выберите целью игрока более низкого уровня, чтобы сотворить еду или воду для его уровня."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Выберите целью игрока более низкого уровня, чтобы создать Камень здоровья для его уровня."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Окно ядов"
L["NOTE_POISONS_REPLACED"] = "Автоматически заменяет старые яды."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Бинты"
L["LABEL_EXPLOSIVE"] = "Взрывчатка"
L["LABEL_FOOD"] = "Еда"
L["LABEL_HEALTH_POTION"] = "Лечебное зелье"
L["LABEL_HEALTHSTONE"] = "Камень здоровья"
L["LABEL_MANA_GEM"] = "Мана-камень"
L["LABEL_MANA_POTION"] = "Зелье маны"
L["LABEL_PET_FOOD"] = "Еда для питомца"
L["LABEL_POISON"] = "Яд"
L["LABEL_SOULSTONE"] = "Камень души"
L["LABEL_WATER"] = "Вода"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Включено"
L["MINIMAP_DISABLED"] = "Отключено"
L["MINIMAP_TOGGLE"] = "Переключить"
L["MINIMAP_OPEN"] = "Открыть"
L["MINIMAP_LEFT_CLICK"] = "ЛКМ"
L["MINIMAP_RIGHT_CLICK"] = "ПКМ"
L["MINIMAP_MIDDLE_CLICK"] = "СКМ"
L["MINIMAP_SHIFT_LEFT"] = "Shift + ЛКМ"

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
L["GROUP_CONTEXT_SOLO"] = "Соло"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "Когда вы не в группе или рейде."
L["GROUP_CONTEXT_PARTY"] = "Группа"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] =
	"Когда вы в группе, в том числе в подземелье через поиск группы."
L["GROUP_CONTEXT_RAID"] = "Рейд"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] =
	"Когда вы в рейде. Рейд на поле боя считается полем боя."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Поле боя"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] =
	"Когда вы на поле боя или арене, в любой группе."
L["GROUP_CONTEXT_NEVER"] = "Никогда"

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
	'Выбирает, на каких уровнях ваш макрос Еды предлагает "%s": на любом уровне, только до максимального уровня или только на максимальном уровне. Флажки ниже выбирают, в каких группах.'
L["OPTIONS_MODE_CAPTION"] = "Когда использовать"
L["OPTIONS_GROUPS_NONE"] =
	"Ничего не отмечено, поэтому это никогда не используется."
L["LEVEL_FILTER_ANY"] = "На любом уровне"
L["LEVEL_FILTER_LEVELING"] = "До максимального уровня"
L["LEVEL_FILTER_MAX_LEVEL"] = "На максимальном уровне"

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
L["INVENTORY_REPORT_TITLE"] = "Отчёт об инвентаре"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Сумки %s, Банк %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Сумки %s"
L["INVENTORY_REPORT_BANK"] = "Банк %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Всего %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Самообновляемые макросы для лучшей еды, воды, зелий и камней здоровья, список пополнения, который сам покупает и убирает в банк реагенты и боеприпасы, недостающие баффы в один клик и макросы по наведению для каждого заклинания."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Улучшенная книга заклинаний"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Макросы при наведении, у курсора и на себя для каждого заклинания класса создаются в один клик на новой вкладке книги заклинаний, без синтаксиса макросов. Они обновляются, когда вы повышаете уровень, обучаетесь и меняете специализацию. ПКМ, чтобы добавить фокус, прерывание заклинания, автоатаку, атаку питомца или аксессуары."
L["SPELLBOOK_IS_OFF"] =
	"Улучшенная книга заклинаний выключена. Включите её в меню Настройки > Модификации > Good to Go > Улучшенная книга заклинаний."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] =
	"Выводит приветственное сообщение в чат при входе в игру."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Включить кнопку на миникарте"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Показывает кнопку на миникарте."

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
L["OPTIONS_FEATURES_HEADER"] = "Функции"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Показывает окно со всеми участниками группы, которым не хватает баффа, доступного вам. Нажмите на значок, чтобы применить его."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Поддерживает запасы в сумках по списку пополнения: покупает у торговцев, перемещает предметы в банк и из банка и напоминает, когда что-то заканчивается. При выключении всё это прекращается, включая окно списка пополнения. Ваши списки сохраняются."
L["SWITCH_SPELLBOOK"] = "Включить улучшенную книгу заклинаний"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	'Добавляет в книгу заклинаний вкладку, которая создаёт макросы при наведении, у курсора и на себя для ваших заклинаний и обновляет их, когда вы повышаете уровень и обучаетесь. При выключении вкладка скрывается, а обновления прекращаются. Макросы при этом не удаляются; для этого служат кнопки в разделе "Удаление макросов" на панели "Улучшенная книга заклинаний".'
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Выключить улучшенную книгу заклинаний? Её вкладка исчезнет из книги заклинаний, а созданные ею макросы перестанут обновляться при повышении уровня и обучении. Сами макросы не удаляются: они останутся на панелях команд в нынешнем виде."
L["SWITCH_MACROS"] = "Включить макросы расходуемых предметов"
L["SWITCH_MACROS_DESCRIPTION"] =
	'Следит, чтобы ваши макросы еды, воды, зелий и других расходуемых предметов указывали на лучший предмет в сумках, когда их содержимое меняется. При выключении обновления прекращаются, и каждый макрос остаётся в последнем состоянии. Макросы при этом не удаляются; чтобы удалить макрос, снимите его флажок в разделе "Какие макросы создавать" на панели "Макросы расходуемых предметов".'
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Выключить макросы расходуемых предметов? Ваши макросы перестанут обновляться при изменении содержимого сумок, и кнопка может тянуться к уже израсходованному предмету. Сами макросы не удаляются: они останутся на панелях команд в нынешнем виде."
L["SWITCH_INVENTORY_REPORT"] = "Включить отчёт об инвентаре"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Добавляет в подсказку предмета, сколько таких предметов у вас в сумках, в банке и у других ваших персонажей в этом игровом мире. Выключите, если эти данные уже показывает другой аддон."
L["SWITCH_READINESS_REPORT"] = "Включить отчёт о готовности"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Когда начинается проверка готовности, выводит видимый только вам список того, что ещё нужно исправить, например недостающий бафф, зелье или повреждённое снаряжение. Если вы готовы, ничего не пишет."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Включить Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Пример: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает интерфейс настроек этого аддона."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Открывает ваш список пополнения."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Этот аддон создали игроки, которые любят эту игру и хотят сделать её как можно интереснее для всех. Мы никогда не попросим пожертвований. Больше всего нас радует знать, что наша работа хоть немного улучшает для вас игру. Если это так, мы будем рады об этом услышать!"
L["OPTIONS_LEVEL_UP_WAYS"] =
	"Вот несколько способов помочь нам охватить больше игроков."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Поделитесь отзывом: нашли ошибку или есть идея? Сообщите нам в Discord. Ваши отзывы помогают нам улучшать аддон, а пул-реквесты всегда приветствуются."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Расскажите другу: знаете кого-то, кому может понравиться этот аддон? Расскажите ему. Сарафанное радио помогает большему числу игроков находить отличные аддоны."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Добавьте в избранное на CurseForge: откройте ссылку на CurseForge ниже, войдите в аккаунт и нажмите на звёздочку под кнопкой Download. Избранное помогает большему числу игроков находить этот аддон."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Поставьте звезду на GitHub: откройте ссылку на GitHub ниже, войдите в аккаунт и нажмите Star в правом верхнем углу. Звёзды помогают проекту получить доступ к большему числу бесплатных инструментов для разработчиков."

L["OPTIONS_FEEDBACK"] = "Обратная связь и поддержка"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Ссылки для обратной связи и поддержки"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] =
	"Чтобы скопировать ссылку, щёлкните по её полю, затем нажмите Ctrl+A и Ctrl+C."
L["OPTIONS_VERSION"] = "Версия %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "Макросы расходуемых предметов"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go создаёт по одному макросу на каждый тип расходуемых предметов и обновляет его вслед за содержимым сумок, так что кнопка на панели всегда тянется к лучшему предмету, который у вас есть. Выберите ниже, какие макросы создавать, а затем настройте, как каждый из них выбирает предмет."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Включить названия макросов на кнопках"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Показывает названия макросов на кнопках панелей команд. По умолчанию Good to Go скрывает эти названия."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Какие макросы создавать"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	'Выберите, какие макросы Good to Go будет создавать и поддерживать. Отключённый макрос также удаляется. Они находятся на вкладке "Общие макросы" окна макросов, и их можно сразу перетащить на панели команд.'
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Открыть окно макросов"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	'Открывает игровое окно макросов на вкладке "Общие макросы", где хранятся эти макросы.'
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"Создаёт и поддерживает этот макрос, а при снятии флажка удаляет его."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Еда и вода"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Ваши макросы Еды и Воды используют лучшую еду и питьё из ваших сумок. Эти настройки позволяют ставить на первое место еду с эффектом, свитки или сотворенные еду и воду, а еду и воду из списка пополнения ставить на последнее."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Предпочитать еду с эффектом"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Предпочитает еду, дающую эффект "%s", если он отсутствует, кроме как на аренах.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Включить баффы от свитков"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Ваш макрос Еды при первом нажатии применяет недостающие свитки, а при следующем использует еду, пропуская свитки, если целью выбран дружественный игрок или вы находитесь на арене."
L["OPTIONS_SCROLL_TYPES"] = "Включить типы свитков в проверку"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Защита"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Включает в проверку недостающих баффов: %s."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Сначала использовать сотворенные еду и воду"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Ваши макросы Еды и Воды используют сотворенные еду и воду раньше всего остального, даже если в сумках есть что-то, что восполняет больше, ведь они ничего не стоят и исчезают вскоре после выхода из игры. Еда с эффектом по-прежнему идёт первой, пока включено "Предпочитать еду с эффектом".'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Выбирает, на каких уровнях сотворенные еда и вода идут первыми: на любом уровне, только до максимального уровня или только на максимальном уровне. Флажки ниже выбирают, в каких группах."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] =
	"Использовать еду и воду из списка пополнения в последнюю очередь"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Из двух видов еды или питья, восполняющих одинаковое количество, ваши макросы Еды и Воды используют тот, которого нет в вашем списке пополнения, сохраняя купленное по списку на потом."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Зелья и камни здоровья"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Макросы не могут изменяться во время боя (это ограничение Blizzard), поэтому каждый макрос Зелья и Камня здоровья создаётся заранее с вашим лучшим предметом и до двух запасных вариантов. В затяжных боях иконка и подсказка могут устареть и показывать не тот предмет, но клик по макросу всегда будет использовать лучший предмет, который у вас действительно есть в сумках."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] =
	"Использовать еду и воду в макросах зелий вне боя"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Вне боя ваш макрос Лечебного зелья использует вашу лучшую еду, а макрос Зелья маны лучшую воду. В бою они, как и раньше, используют ваши зелья. Свитки, еда для питомца и сотворение остаются в макросах Еды и Воды."
L["OPTIONS_COMBINE_HEALTHSTONES"] =
	"Объединить Камни здоровья в макрос Лечебного зелья"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Добавляет ваш лучший Камень здоровья в конец макроса Лечебного зелья, поэтому одно нажатие использует и зелье, и Камень здоровья."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Мана-камни и руны"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s и ещё несколько предметов для восполнения маны имеют общее время восстановления с мана-камнями. Использование рун отнимает здоровье, поэтому макрос Мана-камня не включает ни один из этих предметов, пока вы сами их не добавите."
L["OPTIONS_INCLUDE_MANA_RUNES"] =
	"Добавить руны и другие предметы для восполнения маны в макрос Мана-камня"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Учитывает наравне с мана-камнями такие предметы, как %s и %s, а также любые другие предметы для восполнения маны с общим с ними временем восстановления, так что макрос Мана-камня использует такой предмет, когда это лучший вариант или когда у вас закончились камни."

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "Обновление баффов"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Макросы не могут изменяться во время боя, поэтому, если бафф истечёт посреди боя, его не будет до конца боя."
L["OPTIONS_REAPPLY"] = "Обновлять истекающие баффы"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Считает истёкшими баффы от еды с эффектом, свитков и еды для питомцев, если до их окончания осталось меньше заданного порога, чтобы макросы предложили новые ещё до начала боя."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Задаёт, за сколько времени до истечения баффа макросы предложат новый."
L["REAPPLY_THRESHOLD_ONE"] = "Когда осталось < 1 минуты"
L["REAPPLY_THRESHOLD_MANY"] = "Когда осталось < %d минут"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Баффы от еды для питомцев"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] =
	'Некоторая еда даёт вашему питомцу собственный эффект "%s".'
L["OPTIONS_USE_PET_BUFFS"] = "Использовать баффы от еды для питомцев"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Добавляет еду для питомца в ваш макрос Еды, когда у питомца нет эффекта "%s", кроме как на аренах.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Включить типы еды для питомцев в проверку"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Взрывчатка"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"Вариант @player пропускает прицельный круг и подрывает взрывчатку прямо у ваших ног. Идеально, когда цель в ближнем бою. Другой кнопкой мыши вы бросаете взрывчатку как обычно."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Назначение кнопок"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Выбирает, какая кнопка мыши бросает взрывчатку, а какая подрывает её у ваших ног."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "ЛКМ @player"
L["EXPLOSIVES_MODE_TOSS"] = "ЛКМ Бросок"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Класс и раса"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Эти настройки меняют ваши макросы для конкретного класса или расы. Все разделы видны на любом персонаже."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Настройки класса: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Расовые настройки: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Требуется аддон DruidMacroHelper. Если включено, ваши макросы Лечебного зелья, Зелья маны и Камня здоровья выводят вас из облика, используют предмет и возвращают в Облик медведя или Облик кошки, смотря что вы выберете рядом с флажком."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Включить интеграцию DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Создаёт макросы смены облика для лечебных зелий, зелий маны и камней здоровья с помощью DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Выбирает облик, в который вас возвращают макросы смены облика после использования предмета."
L["DRUID_FORM_BEAR"] = "Вернуться в облик медведя"
L["DRUID_FORM_CAT"] = "Вернуться в облик кошки"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Держит макрос Ядов заряженным лучшим доступным рангом каждого типа яда. ЛКМ наносит яд на левую руку, ПКМ на правую, а нанесённые яды заменяются автоматически."
L["OPTIONS_POISON_MAIN_HAND"] = "Тип яда для правой руки"
L["OPTIONS_POISON_OFF_HAND"] = "Тип яда для левой руки"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Выбирает яд, который ваш макрос Ядов наносит на правую руку по ПКМ."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Выбирает яд, который ваш макрос Ядов наносит на левую руку по ЛКМ."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Включить незаметность при еде"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	'Добавляет способность "%s" в макрос Еды, чтобы вы уходили в незаметность во время еды.'

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Включить незаметность при питье"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	'Добавляет способность "%s" в макрос Воды, чтобы вы уходили в незаметность во время питья.'
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Совет профи: выберите что-то одно. Есть и пить можно одновременно, но еда или питьё после ухода в незаметность прервёт её."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	'Возьмите в цель убитого гуманоида или нежить, и ваш макрос применит способность "%s", пока она готова, экономя еду и питьё. Если это невозможно (труп вне досягаемости или способность восстанавливается), он, как обычно, использует еду или питьё.'
L["OPTIONS_CANNIBALIZE_EATING"] = 'Использовать "%s" вместо еды'
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	'Пока в цели труп, на котором срабатывает способность "%s", и она готова, макрос Еды применяет её вместо еды. Иначе он, как обычно, использует еду. Свитки и еда с эффектом по-прежнему идут первыми.'
L["OPTIONS_CANNIBALIZE_DRINKING"] = 'Использовать "%s" вместо питья'
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	'Пока в цели труп, на котором срабатывает способность "%s", и она готова, макрос Воды применяет её вместо питья. Иначе он, как обычно, использует воду. Напитки с эффектом по-прежнему идут первыми.'

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	'Пока способность "%s" готова, макрос Еды применяет её вместо еды, экономя пищу. Пока она восстанавливается, макрос, как обычно, использует еду.'
L["OPTIONS_RAPID_REGENERATION_EATING"] = 'Использовать "%s" вместо еды'
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	'Пока способность "%s" готова, макрос Еды применяет её вместо еды. Иначе он, как обычно, использует еду. Свитки и еда с эффектом по-прежнему идут первыми. В бою, где есть нельзя, каждое нажатие применяет её.'

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
L["TAB_IGNORE_LIST"] = "Список игнорирования"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	'Игнорируемые предметы никогда не выбираются ни одним макросом. Еда, вода, зелья, что угодно. Список "Общий" действует для всех персонажей; список персонажа действует только для него. ПКМ по кнопке на миникарте, чтобы игнорировать вашу текущую лучшую еду.'
L["OPTIONS_IGNORE_GLOBAL"] = "Общий"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	'Переносит этот предмет в список "Общий", чтобы он игнорировался на всех персонажах.'
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Добавить из сумок"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Выберите любой предмет из тех, что вы несёте. Сумки закрываются при открытии интерфейса настроек, поэтому это заменяет перетаскивание предмета сюда."
L["OPTIONS_IGNORE_ADD_ID"] = "Добавить по ID предмета"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Введите ID предмета или сделайте Shift + Клик по ссылке на предмет в чате, пока это поле активно."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Введите ID предмета или сделайте Shift + Клик по ссылке на предмет в чате."
L["OPTIONS_IGNORE_REMOVE"] = "Убрать"
L["OPTIONS_IGNORE_EMPTY"] = "Список пуст."
L["OPTIONS_IGNORE_CLEAR"] = "Очистить список"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Убирает все предметы из этого списка. Персонаж с пустым списком исчезает из списка слева, если только это не тот, за которого вы играете."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] =
	"Убрать все предметы из этого списка? Это действие нельзя отменить."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Загрузка ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Поддерживает запасы в ваших сумках по списку пополнения, автоматически покупая у торговцев и перемещая предметы в банк и из банка. Введите %s, чтобы открыть список."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Открывать в банке"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] =
	"Открывает ваш список пополнения при посещении банка."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Открывать у торговца"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] =
	"Открывает ваш список пополнения при посещении торговца."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Напоминания"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"Выберите, когда вам сообщать, что запасы по списку пополнения на исходе."
L["OPTIONS_RESTOCKER_REMIND"] = "Включить напоминания о пополнении в городе"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Выводит напоминание в чат, когда вам не хватает чего-то из списка пополнения и вы добираетесь до таверны или города либо уже находитесь в них при входе в игру."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] =
	"Включить напоминания о пополнении у торговца"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Сообщает о невыполненных заказах на пополнение, если такие есть, когда вы закрываете окно торговца."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Включить напоминания о пополнении в банке"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Сообщает о невыполненных заказах на пополнение, если такие есть, когда вы закрываете банк."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Запас золота"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"Отложите золото, которое никогда не будет тратиться на покупки у торговцев."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Включить запас золота"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"Пополнение никогда не тратит золото, отложенное здесь."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] =
	"Задаёт, сколько золота пополнение всегда оставляет вам."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Выбирает, состоит ли напоминание из одной строки или добавляет по строке на каждый недостающий предмет."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Насколько подробно"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Кратко"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Подробно"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Проигрывать звук"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Проигрывает сигнал вместе с напоминанием на случай, если в чате оживлённо."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Нажмите, чтобы прослушать сигнал."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Окно списка пополнения"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] =
	"Выберите, когда ваш список пополнения будет открываться сам."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Показывает в подсказке предмета, сколько таких предметов есть у всех ваших персонажей в этом игровом мире."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Сохранённые персонажи"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Забыть"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"Забыть персонажа %s? Его сумки и банк пропадут из всех подсказок предметов, а выбранный им список пополнения будет сброшен. При входе в игру этим персонажем данные запишутся снова."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Отчёт о готовности"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Когда начинается проверка готовности, выводит видимый только вам список того, что ещё нужно исправить, а если вы готовы, не пишет ничего."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Сбросить настройки отчёта о готовности"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Возвращает все флажки и оба порога на этой странице к значениям по умолчанию."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Сбросить все настройки отчёта о готовности к значениям по умолчанию?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Не хватает баффов"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Не хватает предметов"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Персонаж"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Сообщает об отсутствии настоя. Настой либо один боевой и один охранный эликсир засчитываются."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Сообщает об отсутствии эффекта "%s". Требуется включённая еда с эффектом на панели "Макросы расходуемых предметов".'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Сообщает об отсутствии у питомца эффекта "%s". Требуются включённые баффы от еды для питомцев на панели "Макросы расходуемых предметов" и призванный питомец.'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	'Сообщает о недостающих баффах от свитков. Требуются включённые баффы от свитков на панели "Макросы расходуемых предметов"; проверяются только выбранные там типы свитков.'
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Сообщает, когда ни на ком из вашей группы нет активного Камня души; камень в сумке не считается. Сообщается только чернокнижнику, который может его создать."
L["OPTIONS_READINESS_MAIN_HAND"] = "Бафф оружия (правая рука)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Сообщает, если на оружии в правой руке нет временного улучшения. Засчитывается любое улучшение; если в вашей группе есть шаман, эта проверка не срабатывает."
L["OPTIONS_READINESS_OFF_HAND"] = "Бафф оружия (левая рука)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Сообщает, если на оружии в левой руке нет временного улучшения. Засчитывается любое улучшение: камень, масло, яд или шаманский бафф оружия."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Сообщает, если на оружии в правой руке не хватает временного улучшения. От разбойников и шаманов требуется два: яд или чары оружия вместе с маслом или камнем; от остальных достаточно одного любого."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Сообщает, если на оружии в левой руке не хватает временного улучшения. От разбойников требуется два: яд вместе с маслом или камнем; от остальных достаточно одного любого."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Баффы истекают в течение"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	'Называет все баффы на вас, которые скоро истекут, а не только те, что применяет Good to Go. Не зависит от обновления баффов на панели "Макросы расходуемых предметов".'
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s мин"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 мин"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Задаёт, за сколько времени до истечения баффа отчёт назовёт его."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Сообщает, когда у вас нет Камня здоровья. Сообщается, только когда в группе есть чернокнижник, у которого можно попросить камень, или когда вы сами чернокнижник."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Сообщает, когда у вас нет мана-камня. Сообщается только магу, который может его сотворить."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Сообщает, когда у вас нет лечебного зелья, ведь посреди боя вам его никто не передаст."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Сообщает, когда у вас нет зелья маны. Сообщается, только если вы играете за класс, использующий ману."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	'Сообщает, когда у вас нет бинтов, которые позволяет использовать ваш навык "%s".'
L["OPTIONS_READINESS_DURABILITY"] = "Повреждённое снаряжение ниже"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Приводит ссылки на все надетые предметы с прочностью ниже этого значения, считая по каждому предмету отдельно, так что даже одно сломанное оружие будет видно."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Задаёт, насколько низко должна упасть прочность предмета, чтобы отчёт привёл ссылку на него."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Текущая специализация"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Выводит распределение талантов и очки, которые вы ещё не потратили."
L["OPTIONS_READINESS_PVP"] = "Включён режим PvP"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] =
	"Предупреждает, когда у вас включён режим PvP."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Надето небоевое снаряжение"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Приводит ссылки на надетые предметы, которым не место в бою, например снаряжение для верховой езды или рыбалки."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "Дозор рангов"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Следит, не применяет ли кто-то в вашей группе заклинание более низкого ранга, чем мог бы, и подсказывает ему, что у учителя его ждёт ранг повыше. О ранге, который игра понижает сама, например при баффе на игрока низкого уровня, никогда не сообщается."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s всё ещё работает, поэтому дозор рангов молчит, чтобы ваша группа не слышала о каждом низком ранге дважды. Good to Go отключил его и включил дозор рангов; перезагрузите интерфейс, чтобы дозор рангов взял дело на себя."

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s (%s)"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Уровень %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"Кстати, ничего страшного, но вы использовали %s. С %d-го уровня есть ранг повыше. Обновите панели команд или загляните к учителю, и вы будете Good to Go."
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"Кстати, ничего страшного, но ваш питомец %s использовал %s. С %d-го уровня питомца есть ранг повыше. Обучите его с помощью Дрессировки, и вы будете Good to Go."
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"Кстати, ничего страшного, но ваш %s использовал %s. С %d-го уровня есть ранг повыше. Купите гримуар у учителя демонов, и вы будете Good to Go."
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"Не хотите получать такие подсказки? Ответьте %s, и я больше не буду писать вам о рангах заклинаний. Ваш номер работает с любым, у кого стоит Good to Go."
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] =
	"Принято, больше никаких подсказок о рангах от меня."
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'Игрок %s прислал свой номер отказа, и теперь дозор рангов его игнорирует. Отменить это можно в разделе "Игнорируемые игроки" дозора рангов.'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"Вы применили %s, а %s можно получить с %d-го уровня. Загляните к учителю или обновите панели команд."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] =
	"Ваш питомец %s применил %s, а %s можно получить с %d-го уровня питомца."
L["RANK_WATCH_PRINT_SELF_DEMON"] =
	"Ваш %s применил %s, а %s можно получить с %d-го уровня."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] =
	"Игрок %s применил %s, хотя может получить %s с %d-го уровня."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"Питомец игрока %s (%s) применил %s, хотя может получить %s с %d-го уровня питомца."
L["RANK_WATCH_PRINT_OTHER_DEMON"] =
	"Демон игрока %s (%s) применил %s, хотя может получить %s с %d-го уровня."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "Шепнёт ему %s."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Включить дозор рангов"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Сообщает вам и пишет шепотом участникам группы, когда кто-то применяет заклинание более низкого ранга, чем мог бы, чтобы он знал, что пора к учителю."

L["RANK_WATCH_MESSAGES_HEADER"] = "Оповещения"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] =
	"Как дозор рангов сообщает игроку, что тот применил низкий ранг."
L["RANK_WATCH_WHISPER"] = "Шептать участникам группы"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Пишет шепотом участнику группы, который применил низкий ранг. Если дозор рангов или Rank Sentinel есть у нескольких игроков в группе, шепчет только один из них."
L["RANK_WATCH_PRINT"] = "Выводить низкие ранги группы"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"Выводит в ваш чат низкий ранг участника группы. Ваши собственные низкие ранги выводятся всегда."
L["RANK_WATCH_GRACE_HEADER"] = "Отсрочка"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"О новом ранге не сообщается, пока заклинатель не перерастёт уровень его изучения на столько уровней, чтобы никто не слышал о ранге, до которого только что дорос и который ещё не успел изучить."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Отсрочка на максимальном уровне"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"Для персонажа на максимальном уровне не трогает ранги, изучаемые в пределах стольких уровней от максимума. При 0 сообщается о каждом доступном ему ранге."
L["RANK_WATCH_GRACE_LEVELING"] = "Отсрочка при прокачке"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"Для персонажа, который ещё качается, не трогает ранги, изучаемые в пределах стольких уровней от его собственного, давая ему время добраться до учителя."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 уровень"
L["RANK_WATCH_GRACE_LEVELS"] = "Уровней: %d"

L["RANK_WATCH_OPT_OUT_HEADER"] = "Отказ от подсказок"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'Шепнув кому-то впервые, дозор рангов следом присылает ему номер отказа. Номер получается из имени игрока, поэтому он одинаков у всех, у кого стоит Good to Go. Если игрок назовёт его шепотом или в любом видимом вам чате, он попадёт в раздел "Игнорируемые игроки" и больше никогда не услышит от вас о рангах. Чтобы самому оставить кого-то в покое, возьмите его в цель и введите /gtg ignore.'
L["RANK_WATCH_WHISPERER_HEADER"] = "Кто сообщает за группу"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"Если дозор рангов или Rank Sentinel есть у нескольких игроков в группе, шепот отправляет только один из них, чтобы игрок, применивший низкий ранг, услышал об этом один раз, а не от всех. Остальные лишь выводят сообщение в свой чат. Здесь показано, кто отправляет шепот сейчас."
L["RANK_WATCH_WHISPERER_SELF"] = "Вы."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s, поэтому вы видите только сообщение в чате."
L["RANK_WATCH_WHISPERER_NONE"] = 'Никто: "Шептать участникам группы" выключено.'

-- Ability Alerts While Leveling: the Rank Watch panel's section for the level-up prints (LEVEL_UP_SPELLS and the rest)
L["RANK_WATCH_LEVEL_UP_HEADER"] = "Оповещения о способностях при повышении уровня"
L["RANK_WATCH_LEVEL_UP_DESCRIPTION"] = "При повышении уровня в чате появляется список способностей, которые для вас есть у классового наставника, каждая со значком и ссылкой для наведения. У этого свой переключатель, независимо от того, включён ли Дозор рангов."
L["RANK_WATCH_LEVEL_UP"] = "Сообщать о новых способностях при повышении уровня"
L["RANK_WATCH_LEVEL_UP_TOGGLE_DESCRIPTION"] = "Перечисляет способности, которые открываются на только что полученном уровне."
L["RANK_WATCH_LEVEL_UP_PAST"] = "Включать пропущенные способности"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] = "Добавляет строку со способностями прошлых уровней, которые вы ещё не изучили."
L["RANK_WATCH_LEVEL_UP_PET"] = "Включать способности питомца"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] = "Добавляет способности наставника питомцев для охотников или гримуары наставника демонов для чернокнижников, которые открываются на новом уровне."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "Включать пропущенные способности питомца"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] = "Только для охотников: добавляет строку со способностями наставника питомцев прошлых уровней, которые вы ещё не изучили. Чернокнижники эту строку не получают: игра не сообщает, какие гримуары изучил демон, пока он не призван."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Игнорируемые игроки"
L["RANK_WATCH_IGNORED_DESCRIPTION"] =
	"Дозор рангов никогда не сообщает об этих игроках."
L["RANK_WATCH_IGNORED_NONE"] = "Пока никого."
L["RANK_WATCH_IGNORED_REMOVE"] = "Не игнорировать"
L["RANK_WATCH_IGNORE_TARGET"] = "Игнорировать цель"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] =
	"Добавляет в список игрока, которого вы взяли в цель."
L["RANK_WATCH_IGNORE_ADDED"] = "Дозор рангов теперь игнорирует игрока %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"Не удаётся найти игрока %s. Вступите с ним в группу или возьмите его в цель, затем попробуйте снова."
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Возьмите игрока в цель или введите /gtg ignore Имя."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Имя"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"Дозор рангов перестаёт сообщать об этом игроке. Без имени игнорирует вашу цель."

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"Ранги, о которых сообщает дозор рангов, по классам. Снимите флажок с ранга, который вы понижаете намеренно, и дозор рангов оставит его в покое. Показаны все способности. Те, за которыми дозор рангов по умолчанию не следит, например исцеления, таланты и Ожог 1-го ранга, изначально без флажка. Высший ранг способности затенён, ведь выше него ничего нет."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (с %d-го уровня)"
L["RANK_WATCH_RANK_DESCRIPTION"] =
	"Сообщает об этом ранге, когда доступен более высокий."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] =
	"Высший ранг. Выше него ничего нет, поэтому о нём никогда не сообщается."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s: питомцы"
L["RANK_WATCH_TRACK_ALL"] = "Отметить все"
L["RANK_WATCH_TRACK_NONE"] = "Снять все"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Список с именем "%s" уже существует.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Нет предмета с ID %d."
L["RESTOCKER_DISABLED"] =
	"Restocker выключен. Включите его в меню Настройки > Модификации > Good to Go > Restocker."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = "Нет списка пополнения с названием %s."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Пополнение завершено. Удерживайте Shift при открытии банка, чтобы пропустить пополнение. Введите %s, чтобы изменить список пополнения."
L["RESTOCKER_STOPPED_BOTH_FULL"] =
	"Пополнение остановлено. Ваши сумки и банк переполнены."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Пополнение остановлено. Ваш банк переполнен; освободите ячейку и откройте его снова."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Пополнение остановлено. Ваши сумки переполнены; освободите ячейку и откройте банк снова."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Пополнение остановлено. Продвижения нет."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] =
	"Пополнение остановлено. Не удалось переместить: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (лишнее)"
L["RESTOCKER_STOPPED_ERROR"] = "Пополнение остановлено из-за ошибки: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"У этого торговца есть не все ингредиенты, необходимые для ваших ядов. Ни один из них не будет куплен."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Не забудьте пополнить запасы, пока вы в городе!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 заказ на пополнение не выполнен."
L["RESTOCKER_STILL_SHORT_MANY"] = "Не выполнено заказов на пополнение: %d."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Ваш список пополнения улучшен."
L["RESTOCKER_UPGRADED_ITEM"] = "Было: %sx%d, стало: %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 заказ на пополнение выполнен."
L["RESTOCKER_RESTOCKED_MANY"] = "Выполнено заказов на пополнение: %d."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 заказ на пополнение выполнен частично."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] =
	"Частично выполнено заказов на пополнение: %d."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] =
	"Сумки заполнились раньше, чем удалось всё купить."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] =
	"Недостаточно золота, чтобы завершить пополнение."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"У вас меньше %s. Пополнение продолжится, когда золота станет больше."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[имя]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Добавляет список с этим именем."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Удаляет список с этим именем."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Даёт текущему списку указанное имя."
L["RESTOCKER_HELP_PROFILE_COPY"] =
	"Заменяет текущий список копией списка с этим именем."
L["RESTOCKER_HELP_PROFILE_USE"] =
	"Переключает этого персонажа на список с этим именем."

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
L["STARTER_POPUP_TITLE"] = "Припасы"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Готово"
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Для начала мы отметили несколько припасов для вашего класса."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Ваш список пополнения пуст, так что давайте добавим несколько предметов для начала."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"Выберите припасы, которые хотите держать в запасе."
L["STARTER_POPUP_INTRO_HOW"] =
	"Всё, что вы отметите, будет автоматически пополняться при открытии окна торговца или банка. Большинство припасов сами улучшаются по мере роста уровня, так что у вас всегда будет лучшее из доступного."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Вы всегда можете изменить этот список или добавить предметы позже, введя %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Еда и вода"
L["STARTER_POPUP_FOOD_HEADER"] = "Еда"
L["STARTER_POPUP_AMMO_HEADER"] = "Боеприпасы"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Пули"
L["STARTER_POPUP_ARROWS"] = "Стрелы"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Реагенты и инструменты"
L["STARTER_POPUP_POISONS_HEADER"] = "Яды"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Добавьте готовый яд в список, и Good to Go будет автоматически покупать ингредиенты у любого торговца, который продаёт их все."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Добавляет предмет %s в список пополнения, держит в сумках %d шт. и улучшает их по мере роста уровня."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Добавляет предмет %s в список пополнения и держит в сумках %d шт."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 стопка"
L["STARTER_POPUP_STACK_MANY"] = "Стопок: %d"
L["STARTER_POPUP_STACKS_DESCRIPTION"] =
	"Сколько стопок держать в запасе, по %d в каждой."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Сколько держать в запасе, каждый предмет в отдельной ячейке сумки, так как они не складываются в стопки."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Список пополнения"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Фильтр предметов..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Очистить"
L["RESTOCKER_ADD_BUTTON"] = "Добавить"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Выбрать припасы"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Выберите из припасов для вашего класса и уровня: еда, вода, боеприпасы, яды и реагенты. Отмеченный предмет добавляется в этот список, а при снятии отметки убирается из него."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Добавить предмет"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Перетащите предмет из сумок сюда или в любое место этого окна либо введите ID предмета и нажмите Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Перетащите или введите ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Лучше введите ID предмета."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Уже в этом списке."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Добавить из сумок"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Все предметы из ваших сумок, которых ещё нет в этом списке, готовые к добавлению."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "В сумках нечего добавить"

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
L["RESTOCKER_PROFILE_LABEL"] = "Список"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Переключает этого персонажа на другой список пополнения или создаёт новый."
L["RESTOCKER_USED_BY"] = "Используют: %s"
L["RESTOCKER_MANAGE"] = "Управлять списками"
L["RESTOCKER_MANAGE_TOOLTIP"] =
	"Создайте новый список либо скопируйте, переименуйте или удалите этот."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Новый список"
L["RESTOCKER_MANAGE_COPY"] = "Копировать этот список в новый"
L["RESTOCKER_RENAME_PROFILE"] = "Переименовать этот список"
L["RESTOCKER_MANAGE_DELETE"] = "Удалить этот список"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s (копия)"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Переименовать"
L["RESTOCKER_RENAME_TOOLTIP"] =
	"Переименовывает этот список для всех персонажей, которые его используют."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Вы уверены, что хотите удалить этот список?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s тоже использует этот список и при входе в игру получит пустой список с тем же именем."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s тоже используют этот список, и каждый при входе в игру получит пустой список с тем же именем."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Вы переключитесь на список %s."
L["RESTOCKER_DELETE_LIST_LAST"] =
	"Это единственный оставшийся список, поэтому вы начнёте с нового пустого списка."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Это нельзя отменить."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Улучшать по мере роста уровня"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Позволяет Good to Go заменять еду, воду, боеприпасы, яды, зелья и классовые реагенты на более качественные по мере роста уровня."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Улучшение"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Предмет"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Взять"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Сложить"
L["RESTOCKER_COLUMN_REPUTATION"] = "Реп."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Норма"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] =
	"Заголовок задаёт это для всех видимых предметов."
L["RESTOCKER_BULK_ON"] = "Включить для видимых (%d)"
L["RESTOCKER_BULK_OFF"] = "Отключить для видимых (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Прочее"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Новые"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Все предметы"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "В этом списке пока ничего нет"
L["RESTOCKER_EMPTY_BODY"] =
	"Выберите припасы, такие как еда, вода или классовые реагенты, либо добавьте что угодно из сумок через меню выше. Предметы из этого списка автоматически пополняются или складываются в банк, так что в ваших сумках всегда порядок."
L["RESTOCKER_EMPTY_DROP_HINT"] =
	"Предмет также можно добавить, перетащив его в любое место этого окна."
L["RESTOCKER_NO_MATCH_FILTER"] = "Ничто в этом списке не подходит под ваш фильтр."
L["RESTOCKER_NO_MATCH_GROUP"] = "В этой категории ничего не осталось."

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
L["RESTOCKER_NO_ORDERS"] = "Невыполненных заказов на пополнение нет."
L["RESTOCKER_REPORT_MORE"] = "И ещё %d."
L["RESTOCKER_REMOVED_ITEM"] = "Убрано: %s."
L["RESTOCKER_UNDO"] = "Отменить"
L["RESTOCKER_UNDO_TOOLTIP"] = "Вернуть этот предмет в список"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Убрать этот предмет из списка пополнения"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Это можно отменить вверху списка."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Норма в сумках"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'Сколько держать в сумках. Число становится жёлтым, пока в сумках меньше нормы, а норма 0 при включённом "Сложить" отправляет в банк всё.'
L["RESTOCKER_BUY_LABEL"] = "Купить"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Покупать у торговца"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Покупает нужное количество у торговца, когда открыто окно торговца."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Сверх"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Покупать сверх нормы"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Выкупает у торговца весь ограниченный запас этого предмета, который он понемногу пополняет, даже сверх вашей нормы."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Складывать в банк"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	'Складывает лишние предметы в банк, когда он открыт, или все, если в столбце "Норма" указан 0.'
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Брать из банка"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] =
	"Берёт нужные предметы из банка, когда он открыт."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Требуемая репутация"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (скидка %d%%)"
L["RESTOCKER_REPUTATION_ANY"] = "Любая"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Требуемая репутация у торговца"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Задаёт уровень репутации, начиная с которого Good to Go покупает у торговца; репутация также снижает цену: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Прочерк означает покупку у любого торговца."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	'Для этого предмета отключено "Купить", поэтому покупать сверх нормы нечего.'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	'Для этого предмета отключено "Купить", поэтому репутация не учитывается.'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] =
	"Для этого предмета нет более качественной замены."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go отключил то, что он заменяет: %s. Перезагрузить интерфейс сейчас, чтобы старая версия перестала работать?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Перезагрузить"
L["POPUP_REPLACED_LATER"] = "Позже"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Настройки %s скопированы."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go скопировал ваши настройки из %s и отключил то, что он заменяет: %s. Перезагрузить интерфейс сейчас, чтобы старая версия перестала работать?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go обнаружил установленные, но отключённые аддоны: %s. Перенести настройки? Старые аддоны будут снова включены, а интерфейс перезагружен, после чего вам предложат ещё одну перезагрузку, чтобы снова их отключить."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go обнаружил установленные, но отключённые аддоны: %s. Перенести настройки и списки пополнения? Старые аддоны будут снова включены, а интерфейс перезагружен, после чего вам предложат ещё одну перезагрузку, чтобы снова их отключить."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Перенести"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "Нет, спасибо"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Баффы группы"
L["RANK_WATCH_TRACKED_HEADER"] = "Отслеживаемые ранги"
L["TRACKED_ITEM_PENDING"] = "Предмет #%d"
L["TRACKED_SPELL_PENDING"] = "Заклинание #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] =
	"Воспроизводит звук, чтобы вы могли услышать его до включения."

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Дежурство по баффам"
L["BUFF_DUTY_DESCRIPTION"] =
	"Показывает, кому не хватает ваших баффов. Нажмите на значок, чтобы применить."
L["BUFF_DUTY_ENABLE"] = "Включить дежурство по баффам"
L["BUFF_DUTY_NO_BUFFS"] =
	"У вашего класса нет баффов из этого списка, поэтому на этом персонаже окно никогда не появится."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Когда показывать"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Выберите, когда может появляться окно."
L["BUFF_DUTY_WHEN_NONE"] =
	"Ничего не отмечено, поэтому окно никогда не появится."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"Дежурство по баффам здесь скрыто. Игра не показывает аддонам баффы в этой зоне, поэтому оно не может понять, кому их не хватает."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Определяет, где показывается окно: везде или только внутри инстанса, например подземелья или рейда."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Везде"
L["BUFF_DUTY_WHERE_INSTANCE"] = "В подземелье"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] =
	"Показывает окно, когда вы играете этими классами."
L["BUFF_DUTY_CLASS_DESCRIPTION"] =
	"Показывает окно, когда вы играете этим классом."
L["BUFF_DUTY_HEADER"] = "Окно"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] =
	"Оставьте окно там, где вы его поставили, или уберите его с глаз в бою."
L["BUFF_DUTY_LOCK"] = "Закрепить окно"
L["BUFF_DUTY_LOCK_DESCRIPTION"] =
	"Не дает перемещать окно. Когда оно откреплено, перетаскивайте его за фон."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Скрывать в бою"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Скрывает окно во время боя. В бою список не может обновляться, поэтому оставленное на экране окно сохраняет последнее состояние до конца боя."
L["BUFF_DUTY_SHOW_HEADER"] = "Показывать в окне"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Добавьте в окно свои баффы, незнакомцев, наложивших на вас баффы, и вашу цель."
L["BUFF_DUTY_FAVOR_ENABLE"] = "Ответная любезность"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Показывает незнакомцев, недавно наложивших на вас баффы, и баффы, которыми вы можете им ответить. ПКМ по значку, чтобы убрать игрока из списка."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Задает, как долго незнакомец остается в списке после своего последнего баффа."
L["BUFF_DUTY_TARGET_ENABLE"] = "Ваша цель"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Показывает вашу цель, если это игрок вне вашей группы, которому не хватает баффа, доступного вам."
L["BUFF_DUTY_ASK_OTHERS"] = "Просить баффы у других классов"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	'Показывает в разделе "Нет баффов группы" рейдовые баффы, которых не хватает вашей группе, и сколько игроков нуждается в каждом. ЛКМ по баффу, чтобы попросить его у группы, или ПКМ, чтобы шепотом обратиться к игрокам, которые могут его наложить.'
L["BUFF_DUTY_REFRESH"] = "Обновлять, если осталось меньше"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Задает, при каком оставшемся времени бафф считается отсутствующим, чтобы вы успели обновить его до того, как он спадет. Бафф, который длится не дольше этого времени, учитывается только после того, как спадет."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Считать танками"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Кто получает баффы, которые вы предлагаете танкам, например Шипы, если у игрока нет своей роли."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Задает, когда игроки этого класса считаются танками. Роль танка или лекаря, если она у них есть, всегда важнее."
L["BUFF_DUTY_TANKS_PETS"] = "Питомцы"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Задает, когда питомцы считаются танками. Питомцы также получают баффы, которые вы предлагаете всем."
L["BUFF_DUTY_TANKS_NEVER"] = "Никогда"
L["BUFF_DUTY_TANKS_SOLO"] = "В одиночку"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Всегда"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Выкл."
L["BUFF_DUTY_AUDIENCE_TANK"] = "Танки"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Лекари"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Все"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Задает, кому предлагать %s."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Выберите, кому предлагать каждый бафф. Танки и лекари определяются по роли в группе, но в рейде танками считаются только игроки с отметкой %s. Все без роли считаются бойцами, если в разделе Считать танками ниже не указано иное."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Баффы на себя"
L["BUFF_DUTY_SELF_DESCRIPTION"] =
	"Ваши собственные баффы, закрепленные вверху окна."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "подойдет любой дух"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "подойдет любая броня"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "подойдет любая аура"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "подойдет любой щит"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "подойдет любая броня"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] =
	"подойдет любой из двух демонических баффов"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Выкл."
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Если нет"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Меньше, чем %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Задает, когда показывать %s: никогда, после окончания действия или когда осталось меньше этого времени."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Баффы оружия"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Отметьте, что должно быть на каждом оружии. Окно предложит это, когда эффекта нет или он скоро закончится, если предмет есть в сумках и подходит к оружию."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "Наносить снова"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Задает, когда бафф оружия предлагается снова: после окончания действия или когда осталось меньше этого времени."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Масла"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Камни"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Приманки"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Предлагает %s для оружия (%s). Пока на оружии нет ни одного из отмеченных вариантов, предлагается каждый, который у вас есть."
L["BUFF_DUTY_SELF_ENABLE"] = "Ваши баффы на себя"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Показывает вверху окна баффы, которые вы можете наложить только на себя, например броню или Внутренний огонь, когда их нет или они скоро закончатся. Выберите нужные в разделе Баффы на себя."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Ваши баффы оружия"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Показывает яды, чары оружия, масла, камни и приманки, которых нет на вашем оружии или которые скоро закончатся, вместе с баффами на себя вверху окна. Нажмите на один из них, чтобы нанести его. Выберите нужные в разделе Баффы оружия."

-- The window itself
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "Нет баффов на себя"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "Нет баффов группы"
L["BUFF_DUTY_FAVOR_HEADER"] = "Ответная любезность"
L["BUFF_DUTY_TARGET_HEADER"] = "Цель"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Применяет к игроку %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Наносит на оружие (%s)."
L["BUFF_DUTY_TOOLTIP_USE"] =
	"Ни у кого в группе нет камня души. Использует его на игроке %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Ни у кого в группе нет камня души. Создаёт его."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Применяет к игроку %s и его группе."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Выбирает игрока %s целью и применяет."
-- A Party Buffs icon's tooltip, its click hints: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "Попросить бафф (%s)"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "Шепнуть тем, кто может наложить"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s: нет %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s: нет %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d чел. без %s."
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	'Дежурство по баффам скрыто до следующего входа в игру или перезагрузки интерфейса. Чтобы вернуть его сейчас, нажмите Shift + ЛКМ по кнопке у миникарты. Чтобы оставить его выключенным для класса %s, снимите отметку "%s" в разделе "%s" в настройках %s.'

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Кнопка баффов"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Ожидание, пока игрок %s окажется в радиусе действия."
L["BUFF_KEY_DONE"] = "Больше нечего накладывать."
L["BUFF_KEY_OFF"] = "Дежурство по баффам выключено."
--[[
    The Buff Duty window's last line while the Buff Button has no key: the Buff
    Button's name (BUFF_KEY), the root panel's Key Bindings header
    (OPTIONS_KEY_BINDINGS_HEADER), then the options command.
]]
L["BUFF_DUTY_KEY_HINT"] =
	'А вы знали? Назначьте клавишу для "%s", и каждое нажатие будет накладывать следующий бафф из этого списка. Это делается в разделе "%s" в %s.'

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Не изучено"
L["SECTION_CONSUMABLES"] = "Расходуемые предметы GtG"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Текст макроса"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Динамический уровень"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Динамический уровень зависит от уровня дружественного игрока и обновляется только вне боя."
L["MENU_CAST_AT_CURSOR"] = "Применять у курсора"
L["MENU_TARGET_NEAREST_ENEMY"] = "Выбрать ближайшего врага"
L["MENU_TARGET_NEAREST_FRIEND"] = "Выбрать ближайшего союзника"
L["MENU_CAST_IF_SUMMONED"] = "Применять %s, если питомец призван"
L["MENU_NEVER_TURN_OFF"] = "Не выключать"
L["MENU_LEAVE_FORM_BEFORE"] = "Выходить из облика перед применением"
L["MENU_RIGHT_CLICK_FOR"] = "ПКМ: %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "ПКМ: групповая версия"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "Применить ко всем: %s"
L["MENU_ONCE_PER_COMBAT"] = "Применять раз за бой"
L["MENU_ONCE_PER_TARGET"] = "Применять раз на цель"
L["MENU_HIDE_ERRORS"] = "Скрывать ошибки"
L["MENU_MUTE_ERRORS"] = "Заглушать ошибки"
L["MENU_SWITCH_TO"] = "Переходить в %s"
L["MENU_START_AUTO_ATTACK"] = "Начинать автоатаку"
L["MENU_STOP_ATTACK"] = "Прекращать атаку"
L["MENU_START_AUTO_SHOT"] = "Начинать автоматическую стрельбу"
L["MENU_START_PET_ATTACK"] = "Начинать атаку питомца"
L["MENU_START_WAND"] = "Начинать стрельбу жезлом"
L["MENU_STOP_CASTING"] = "Прерывать заклинание"
L["MENU_STOP_CASTING_NOTE"] =
	"Используйте Прерывать заклинание для заклинаний, которые не могут ждать, например прерываний и рассеиваний."
L["MENU_STOP_IF_CHANNELING"] = "Не при поддержании"
L["MENU_STOP_IF_STEALTHED"] = "Не в незаметности"
L["MENU_DUPLICATE"] = "Дублировать"
L["MENU_DELETE"] = "Удалить"
L["MENU_DELETE_USED_ONE"] = "Удалить (на 1 панели)"
L["MENU_DELETE_USED"] = "Удалить (панелей: %d)"
L["MENU_DELETE_DESCRIPTION"] =
	"Удаляет этот макрос из ваших макросов, тем самым убирая его с панелей команд, и сбрасывает все его параметры. Нажмите на него на странице или перетащите, чтобы создать заново."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Убирает эту копию со страницы и удаляет её из ваших макросов, тем самым убирая её с панелей команд."
L["MENU_DELETE_CONFIRM"] =
	"Удалить %s? Макрос исчезнет с панелей команд, а его параметры будут сброшены."
L["MENU_GROUP_RANK"] = "Уровень"
L["MENU_GROUP_WHEN"] = "Когда"
L["MENU_GROUP_FIRST"] = "Сначала"
L["MENU_GROUP_THEN"] = "Затем"
L["MENU_GROUP_ERRORS"] = "Сообщения об ошибках"
L["MENU_GROUP_GROUPED"] = "Сгруппированные заклинания"
L["MENU_GROUP_TARGET"] = "Цель"
L["MENU_PRIORITY_1"] = "Первый приоритет"
L["MENU_PRIORITY_2"] = "Второй приоритет"
L["MENU_PRIORITY_3"] = "Третий приоритет"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Кого макрос пробует по очереди. Вариант пропускается, если на него нельзя применить заклинание, а если не подходит ни один, макрос срабатывает как обычное заклинание."
L["MENU_UNIT_NONE"] = "Нет"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Здесь список заканчивается."
L["MENU_UNIT_TARGET"] = "Цель"
L["MENU_UNIT_TARGET_DESCRIPTION"] =
	"Применяет к вашей цели, если на неё можно применить заклинание."
L["MENU_UNIT_SELF"] = "На себя"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	'Применяет к вам. На вас заклинание можно применить всегда, поэтому варианты после "На себя" никогда не проверяются.'
L["MENU_UNIT_PET"] = "Питомец"
L["MENU_UNIT_PET_DESCRIPTION"] =
	"Применяет к вашему питомцу, если он призван и на него можно применить заклинание."
L["MENU_UNIT_FOCUS"] = "Фокус"
L["MENU_UNIT_FOCUS_DESCRIPTION"] =
	"Применяет к вашему фокусу, если он есть и на него можно применить заклинание."
L["MENU_UNIT_TARGETS_TARGET"] = "Цель цели"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Применяет к цели вашей цели, например к танку, которого бьёт выбранный вами враг, если на неё можно применить заклинание."
L["MENU_UNIT_MOUSEOVER"] = "Под курсором"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Применяет к тому, кто под вашим курсором, в мире или на рамке, если на него можно применить заклинание."
L["MENU_OPTIONS_COUNT"] = "Параметров: %d"
L["MENU_ENABLED"] = "Включено"
L["MENU_HIGHEST"] = "Высший"
L["MENU_HIGHEST_DESCRIPTION"] =
	"Применяет высший известный вам уровень заклинания."
L["MENU_RANK_DYNAMIC"] = "Динамический уровень"
L["MENU_FIXED_RANK_DESCRIPTION"] =
	"Всегда применяет %s, независимо от уровня персонажа."
L["MENU_ANY_TIME"] = "В любое время"
L["MENU_ANY_TIME_DESCRIPTION"] = "Применяется в бою и вне боя."
L["MENU_IN_COMBAT"] = "В бою"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Применяется только в бою. Вне боя макрос ничего не делает, включая его предметы."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Применяется только вне боя. В бою макрос ничего не делает, включая его предметы."
L["MENU_EVERY_PRESS"] = "Каждое нажатие"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Применяется при каждом нажатии."
L["MENU_GROUP_VERSION_DESCRIPTION"] =
	"ПКМ применяет %s. ЛКМ по-прежнему применяет %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Позволяет макросу применять %s. Из отмеченных здесь заклинаний он применяет изученное последним, так что макрос растёт вместе с вашим обучением."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] =
	"Ещё не изучено. Отметьте сейчас, и макрос начнёт его использовать, как только вы его изучите."
L["MENU_PET_DESCRIPTION"] =
	"Пока призван %s, макрос применяет %s, а не призывает его снова."
L["MENU_STANCE_DESCRIPTION"] = "Сначала включает: %s (если ещё не включено)."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Использует предмет перед применением. Предметы используются в том порядке, в котором вы их отметили, а число после каждого показывает его место."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Использовать: %s"
L["MENU_ADD_FOCUS"] = "Добавить копию для фокуса"
L["MENU_REMOVE_FOCUS"] = "Убрать копию для фокуса"
L["MENU_FOCUS_DESCRIPTION"] =
	"Добавляет на страницу второй макрос, который применяется к фокусу, а затем к вашей цели."
L["MENU_REMOVE_FOCUS_DESCRIPTION"] =
	"Убирает копию для фокуса со страницы и удаляет её макрос."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Добавляет на страницу ещё одну копию этого макроса с этими же параметрами, чтобы вы могли настроить её иначе."
L["MENU_MAKE_DEFAULT"] = "Сделать стандартным для: %s"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"Все макросы категории %s, которые вы не настраивали сами, получают параметры этого макроса."
L["MENU_DEFAULT_SET"] = "%s: теперь эти параметры используются по умолчанию."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Условия"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Открывает панель условий рядом с окном улучшенной книги заклинаний, где макрос может применять другое заклинание при выполнении условия, например при зажатом Shift или во второй специализации."
L["MENU_RIGHT_CLICK_TAKEN"] =
	"ПКМ занята одним из условий. Удалите его, чтобы включить это."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Условия"
L["CONDITIONALS_HINT"] =
	"Проверяются сверху вниз; срабатывает первое подходящее."
L["CONDITIONALS_OTHERWISE"] = "Иначе"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "и"
L["CONDITIONALS_AND_MENU"] = "Добавить второе условие"
L["CONDITIONALS_AND_DESCRIPTION"] =
	"Добавляет второе условие. Строка срабатывает, только если выполнены оба."
L["CONDITIONALS_DROP_SECOND"] = "Убрать это условие"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] =
	"Строка снова проверяет только первое условие."
L["CONDITIONALS_ADD"] = "+ Добавить условие"
L["CONDITIONALS_ADD_DESCRIPTION"] =
	"Добавляет строку внизу. Выберите для неё условие, а затем заклинание."
L["CONDITIONALS_ADD_LIMIT"] =
	"Максимум строк: %d. Каждая удлиняет текст макроса, а он вмещает 255 байт."
L["CONDITIONALS_PICK_SPELL"] = "Выбрать заклинание"
L["CONDITIONALS_PICKING"] = "Нажмите на заклинание на странице"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Нажмите здесь, а затем на заклинание на странице, чтобы применять его в этой строке. Или перетащите заклинание со страницы в эту ячейку."
L["CONDITIONALS_PICK_BANNER"] =
	"Нажмите на заклинание, чтобы выбрать его. Esc или ПКМ для отмены."
L["CONDITIONALS_CANNOT_PICK"] =
	"Условие может применять только изученное заклинание."
L["CONDITIONALS_EMPTY"] =
	"Условий пока нет. Добавьте условие, чтобы применять другое заклинание при зажатом Shift, в бою и не только."
L["CONDITIONALS_SHADOWED"] =
	"Никогда не срабатывает: строка %d выше выполняется всякий раз, когда выполняется эта, и срабатывает первой."
L["CONDITIONALS_KEY_DRAG"] = "Перетащите заклинание сюда"
L["CONDITIONALS_ACTION_DROP"] = "Применять в этой строке"
L["CONDITIONALS_ACTION_PICK"] = "Выбрать на странице"
L["CONDITIONALS_ACTION_USE"] = "Использовать в условии"
L["CONDITIONALS_ACTION_CANCEL"] = "Отменить выбор"
L["CONDITIONALS_REMOVE"] = "Убрать"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Убирает эту строку."
L["CONDITIONALS_REORDER"] = "Переместить"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Перетащите на другую строку, чтобы переместить эту туда. Срабатывает первая подходящая строка."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Зажат Shift"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] =
	"Выполняется, если при нажатии макроса зажат Shift."
L["CONDITION_CTRL"] = "Зажат Ctrl"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] =
	"Выполняется, если при нажатии макроса зажат Ctrl."
L["CONDITION_ALT"] = "Зажат Alt"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Выполняется, если при нажатии макроса зажат Alt."
L["CONDITION_RIGHT_CLICK"] = "ПКМ"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] =
	"Выполняется, когда вы нажимаете ПКМ по макросу на панели команд."
L["CONDITION_IN_COMBAT"] = "В бою"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Выполняется, пока вы в бою."
L["CONDITION_OUT_OF_COMBAT"] = "Вне боя"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Выполняется, пока вы вне боя."
L["CONDITION_SPEC_1"] = "Специализация 1"
L["CONDITION_SPEC_1_DESCRIPTION"] =
	"Выполняется, пока активна ваша первая специализация."
L["CONDITION_SPEC_2"] = "Специализация 2"
L["CONDITION_SPEC_2_DESCRIPTION"] =
	"Выполняется, пока активна ваша вторая специализация."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (текущая)"
L["CONDITION_COMBAT_BLOCKED"] =
	'Недоступно, пока для "Когда" выбрано "В бою" или "Вне боя". Макрос и так ничего не делает в другом случае, поэтому это условие выполнялось бы всегда или никогда.'
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	'Недоступно, пока в разделе "Сгруппированные заклинания" включено "ПКМ: %s", которое уже занимает ПКМ. Отключите его, чтобы использовать ПКМ здесь.'
L["SUBTEXT_CONDITIONALS_ONE"] = "1 условие"
L["SUBTEXT_CONDITIONALS"] = "Условий: %d"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Последовательность"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Открывает панель последовательности рядом с окном улучшенной книги заклинаний, где каждое нажатие макроса применяет следующее заклинание по порядку, например Порчу, затем Проклятие агонии, затем Жертвенный огонь."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "Шагов: %d"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Последовательность"
L["CAST_SEQUENCE_HINT"] =
	"Каждое нажатие применяет следующий шаг. Неудавшийся шаг повторяется при следующем нажатии."
L["CAST_SEQUENCE_FIRST"] = "Первым"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] =
	"Собственное заклинание макроса всегда идёт первым."
L["CAST_SEQUENCE_ADD"] = "+ Добавить шаг"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] =
	"Добавляет шаг в конец. Затем выберите для него заклинание."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Максимум шагов после собственного заклинания макроса: %d. Каждый удлиняет текст макроса, а он вмещает 255 байт."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	'Шагом последовательности может быть только изученное заклинание, кроме "Выстрела".'
L["CAST_SEQUENCE_ACTION_DROP"] = "Применять на этом шаге"
L["CAST_SEQUENCE_ACTION_USE"] = "Использовать в последовательности"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Убирает этот шаг."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] =
	"Перетащите на другой шаг, чтобы переместить этот туда."
L["CAST_SEQUENCE_END"] = "После последнего шага"
L["CAST_SEQUENCE_END_LOOP"] = "Начать заново"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"Следующее нажатие снова применяет собственное заклинание макроса, и последовательность идёт по кругу."
L["CAST_SEQUENCE_END_STOP"] = "Стоп (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Заканчивается на NULL, заклинании, которого никто не знает, поэтому дальнейшие нажатия ничего не применяют, пока сброс не запустит последовательность заново."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Стоп"
L["CAST_SEQUENCE_RESET"] = "Начинать заново, когда"
L["CAST_SEQUENCE_RESET_NEVER"] = "Никогда"
L["CAST_SEQUENCE_RESET_TARGET"] = "Сменилась цель"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] =
	"Запускает последовательность заново с первого шага, когда вы меняете цель."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Закончился бой"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] =
	"Запускает последовательность заново с первого шага, когда вы выходите из боя."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Зажат Shift"
L["CAST_SEQUENCE_RESET_CTRL"] = "Зажат Ctrl"
L["CAST_SEQUENCE_RESET_ALT"] = "Зажат Alt"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Нажатие макроса с зажатой клавишей запускает последовательность заново, применяя первый шаг."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Секунд бездействия"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Запускает последовательность заново, если макрос не нажимали в течение этого времени."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Выкл."
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d сек. бездействия"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	'Остановится навсегда: без условия сброса последовательность останется на NULL, пока макрос не изменится или вы не перезагрузите интерфейс. Выберите сброс в разделе "Начинать заново, когда".'
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'Ожидает, пока "Применять, если питомец призван" применяет %s: у этого параметра своя строка применения. Отключите его, чтобы использовать последовательность.'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Нажмите здесь, а затем на заклинание на странице, чтобы применять его на этом шаге. Или перетащите заклинание со страницы в эту ячейку."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "Шагов: %d"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Показывать все уровни заклинаний"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Показывать сгруппированные заклинания"
L["SETTINGS_SHOW_UNLEARNED"] = "Показывать неизученные заклинания"
L["SETTINGS_MARK_ALL_PLACED"] = "Отметить все заклинания как размещённые"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Ни один макрос на этой странице больше не светится, есть он на ваших панелях или нет. Заклинание, изученное позже, светится, пока вы его не разместите."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "Подсвечивать неразмещённые заклинания"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	'Подсвечивает каждый макрос, которого нет на ваших панелях. Отключите, чтобы отметить их все как размещённые, как кнопка "Отметить все заклинания как размещённые".'
L["SORT_BY_CATEGORY"] = "Сортировать по категории"
L["SORT_BY_SCHOOL"] = "Сортировать по школе"
L["SORT_DESCRIPTION"] =
	"Группирует макросы на странице по категории, то есть по назначению заклинания, например атаки, исцеление или защитные способности, или по школе, то есть по вкладкам книги заклинаний, из которых они взяты."
L["CATEGORY_ATTACKS"] = "Атаки"
L["CATEGORY_FINISHERS"] = "Завершающие приёмы"
L["CATEGORY_CROWD_CONTROL"] = "Контроль"
L["CATEGORY_HYBRID"] = "Гибридные"
L["CATEGORY_HEALS"] = "Исцеление"
L["CATEGORY_BUFFS"] = "Баффы"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Атакующие способности"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Защитные способности"
L["CATEGORY_SELF_BUFFS"] = "Баффы на себя"
L["CATEGORY_SHOCKS"] = "Шоки"
L["CATEGORY_TRAPS"] = "Ловушки"
L["CATEGORY_TOTEMS"] = "Тотемы"
L["CATEGORY_SEALS"] = "Печати"
L["CATEGORY_BLESSINGS"] = "Благословения"
L["CATEGORY_CURSES"] = "Проклятия"
L["CATEGORY_PETS"] = "Питомцы"
L["CATEGORY_TELEPORTS"] = "Телепорты и порталы"
L["CATEGORY_UTILITY"] = "Вспомогательные"
L["CATEGORY_THREAT"] = "Провокация и угроза"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Основные атаки"
L["CATEGORY_STANCES"] = "Стойки"
L["CATEGORY_FORMS"] = "Облики"
L["CATEGORY_AURAS"] = "Ауры"
L["CATEGORY_ASPECTS"] = "Духи"
L["CATEGORY_RACIALS"] = "Расовые"
L["CATEGORY_TRACKING"] = "Выслеживание"
L["CATEGORY_PROFESSIONS"] = "Профессии"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Фокус"
L["SUBTEXT_PET"] = "Питомец"
L["SUBTEXT_CURSOR"] = "Курсор"
L["SUBTEXT_STANCE"] = "Стойка"
L["SUBTEXT_USE_ITEMS"] = "Предметы"
L["SUBTEXT_PET_ATTACK"] = "Атака питомца"
L["SUBTEXT_DYNAMIC_RANK"] = "Дин. уровень"
L["SUBTEXT_DYNAMIC_ITEM"] = "Дин. предмет"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Дин. уровень, Дин. предмет"
L["SUBTEXT_MAX_RANK"] = "Высший уровень"
L["SUBTEXT_TARGET_ENEMY"] = "Ближ. враг"
L["SUBTEXT_TARGET_FRIEND"] = "Ближ. союзник"
L["SUBTEXT_TARGET_PRIORITY"] = "Цель"
L["SUBTEXT_GROUPED_SPELLS"] = "Группа"
L["SUBTEXT_ONCE_PER_COMBAT"] = "Раз за бой"
L["SUBTEXT_ONCE_PER_TARGET"] = "Раз на цель"
L["SUBTEXT_COMBAT_ONLY"] = "Только в бою"
L["SUBTEXT_NO_COMBAT"] = "Вне боя"
L["SUBTEXT_LEAVE_FORM"] = "Выход из облика"
L["SUBTEXT_NO_TOGGLE"] = "Не выключать"
L["SUBTEXT_WAND"] = "Жезл"
L["SUBTEXT_START_ATTACK"] = "Автоатака"
L["SUBTEXT_STOP_ATTACK"] = "Стоп атака"
L["SUBTEXT_STOP_CASTING"] = "Стоп каст"
L["SUBTEXT_STOP_IF_CHANNELING"] = "Не при поддержании"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Не в незаметности"
L["SUBTEXT_HIDE_ERRORS"] = "Без ошибок"
L["SUBTEXT_MUTE_ERRORS"] = "Без звука ошибок"
L["SUBTEXT_OPTIONS_COUNT"] = "Параметров: %d"
L["SUBTEXT_TOO_LONG"] = "Не умещается"
L["SUBTEXT_LEARN_LEVEL"] = "%d ур."
L["SUBTEXT_TALENT"] = "Талант"
L["SUBTEXT_LEARN_RANK"] = "Изучить: %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Обучить питомца"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Еще не изучено"
L["TOOLTIP_LEARN_LEVEL"] = "Учитель вашего класса обучает этому на %d уровне."
L["TOOLTIP_LEARN_TALENT"] = "Изучается через таланты."
L["TOOLTIP_NOT_ON_BARS"] = "Нет на ваших панелях команд"
L["TOOLTIP_TOO_LONG"] =
	"Слишком длинный: %d / %d байт. Отключите параметр, чтобы сократить его."
L["TOOLTIP_OPTIONS_ON"] = "Включенные параметры: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Клик или перетаскивание"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Разместить на панелях команд"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "ПКМ"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Параметры макроса"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "СКМ"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Сбросить параметры макроса"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Сбросить все макросы: %s"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s: параметры возвращены к стандартным."
L["CHAT_CATEGORY_OPTIONS_RESET"] =
	"%s: параметры всех макросов возвращены к стандартным."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Сбрасывает параметры, заданные вами для каждого заклинания здесь, чтобы все они снова следовали стандартным настройкам. Копии для фокуса и дубликаты сохраняются."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Сбросить параметры, заданные вами для всех заклинаний в категории %s? Каждое снова будет следовать стандартным настройкам."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "Макрос: %s"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] =
	"Заклинания вашего класса в виде макросов в один клик."
L["TOOLTIP_KEY_CLICK"] = "Клик"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Открыть улучшенную книгу заклинаний"

-- Page: Layout
L["PAGE_EMPTY"] =
	"Макросов пока нет. Посетите учителя своего класса, чтобы изучить первые заклинания."
L["PAGE_NO_MATCHES"] = "Нет макросов, подходящих под фильтр."
L["PAGE_FILTER"] = "Фильтр заклинаний"
L["FILTER_ALL_SCHOOLS"] = "Все школы"
L["FILTER_ALL_CATEGORIES"] = "Все категории"
L["PAGE_MACRO_SLOTS"] = "Ячейки макросов"
L["TOOLTIP_MACRO_SLOTS"] =
	"Каждый размещенный макрос занимает ячейку макроса. Ячейки персонажа принадлежат этому персонажу и заполняются первыми. Общие ячейки делят все персонажи вашей учетной записи."
L["PAGE_MACRO_GENERAL"] = "Общие"
L["PAGE_MACRO_CHARACTER"] = "Персонаж"
L["PAGE_NO_MATCHES_FOR"] = 'Нет заклинаний, подходящих под "%s".'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Options for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "Настройки для всех (%d): %s"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Включает или отключает параметр сразу для всех заклинаний этой категории. Заклинания, которых ещё нет на ваших панелях, получат эту настройку, когда вы их разместите."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(продолжение)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Что дальше?"
L["WHATS_NEXT_EMPTY"] = "Нет заклинаний для показа."
L["WHATS_NEXT_ALL_SOURCES"] = "Все источники"
L["WHATS_NEXT_ANY_LEVEL"] = "Любой уровень"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LEVEL_UP_SPELLS_PAIR_FORMAT or LEVEL_UP_SPELLS_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), & [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "Теперь вы можете изучить: %s."
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "Не забудьте, вы также можете изучить: %s."
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "Теперь ваш питомец может изучить: %s."
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "Не забудьте, ваш питомец также может изучить: %s."
L["LEVEL_UP_DEMON_SPELLS"] = "Теперь ваши демоны могут изучить: %s."
L["LEVEL_UP_SPELLS_PAIR_FORMAT"] = "%s и %s"
L["LEVEL_UP_SPELLS_LAST_FORMAT"] = "%s и %s"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Доступно сейчас"
L["WHATS_NEXT_STATUS_SOON"] = "Скоро"
L["WHATS_NEXT_STATUS_LATER"] = "Пока недоступно"
L["WHATS_NEXT_STATUS_MISSING"] = "Не выполнены требования"
L["WHATS_NEXT_STATUS_TALENT"] = "Не взятые таланты"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Не взятые таланты и руны"
L["WHATS_NEXT_STATUS_KNOWN"] = "Изучено"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Доступно сейчас"
L["WHATS_NEXT_SHORT_SOON"] = "Скоро"
L["WHATS_NEXT_SHORT_LATER"] = "Пока нет"
L["WHATS_NEXT_SHORT_MISSING"] = "Нужно другое заклинание"
L["WHATS_NEXT_SHORT_TALENT"] = "Не взято"
L["WHATS_NEXT_SHORT_KNOWN"] = "Изучено"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Начальное заклинание"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Учитель"
L["WHATS_NEXT_SOURCE_BOOK"] = "Книга"
L["WHATS_NEXT_SOURCE_QUEST"] = "Задание"
L["WHATS_NEXT_SOURCE_TALENT"] = "Талант"
L["WHATS_NEXT_SOURCE_RUNE"] = "Руна"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Источник"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Требуемый уровень"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Доступно вашему классу с самого начала."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Обучает учитель вашего класса."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] =
	"Обучает предмет, например книга из подземелья или рейда."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] =
	"Обучает классовое задание. Учитель вашего класса подскажет, где его взять."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] =
	"Потратьте на него очко талантов, чтобы изучить."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Выгравируйте его руну, чтобы изучить."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Сначала изучите %s."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "%s: уровни"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + клик"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Ссылка в чат"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Сортировать по доступности"
L["WHATS_NEXT_SORT_LEVEL"] = "Сортировать по уровню"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	'"Сортировать по доступности" сначала показывает заклинания, которые можно изучить сейчас, а изученные в конце. "Сортировать по уровню" показывает каждое заклинание под уровнем, на котором оно изучается.'
L["WHATS_NEXT_SHOW_KNOWN"] = "Показывать изученные заклинания"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] =
	"Также показывает уже изученные заклинания, после остальных."
L["WHATS_NEXT_SHOW_TALENTS"] = "Показывать не взятые таланты"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Показывать не взятые таланты и руны"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Также показывает заклинания из талантов, которые вы не взяли. Их изучают, тратя очки талантов, а не у учителя."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Книга заклинаний питомца"
L["PET_SPELLBOOK_EMPTY"] = "У вашего питомца нет заклинаний для показа."
L["PET_SPELLBOOK_NO_PET"] =
	"Питомец не призван. Призовите питомца, чтобы увидеть его заклинания."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Способности"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Пассивные"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Автоприменение вкл."
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Автоприменение выкл."

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Что дальше у питомца?"
L["WHATS_NEXT_PET_EMPTY"] = "Нет способностей питомца для показа."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s, уровень %d, %s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Очки обучения: %d из %d"
L["WHATS_NEXT_PET_NO_PET"] =
	"Питомец не призван: показано то, что вы изучили с помощью Дрессировки."
L["WHATS_NEXT_PET_NO_DEMON"] =
	"Демон не призван: призовите его, чтобы увидеть, что он уже знает."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Можно обучить"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Способности других семейств"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Можно обучить"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Другое семейство"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Учитель питомцев"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Приручение"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Учитель демонов"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Требуемый уровень питомца"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Очки обучения"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Вас обучает учитель питомцев. Затем обучите этому питомца с помощью Дрессировки."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Приручите зверя, который это знает, и сражайтесь вместе с ним, пока не изучите. Затем обучите этому любого питомца, который может это изучить, с помощью Дрессировки."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] =
	"Вы это знаете. Обучите этому питомца с помощью Дрессировки."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Купите гримуар у учителя демонов, затем используйте его, когда призван демон, который может это изучить."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Гримуар"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"Гримуар есть в ваших сумках. Используйте его, когда призван этот демон."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Ваш питомец не может это изучить."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Звери, которые это знают"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s (%s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "И ещё %d."

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	'"Сортировать по доступности" сначала показывает способности, которые питомец может изучить сейчас, а известные ему в конце. "Сортировать по уровню" показывает каждую способность под требуемым уровнем питомца.'
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Показывать известные способности"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Также показывает способности, которые питомец уже знает, после остальных. Охотник без призванного питомца видит те, что изучил сам."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Показывать способности других семейств"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Также показывает способности, которые ваш питомец не может изучить, например Крадущегося зверя кошки для волка или способности другого демона."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Назначение клавиш"
L["OPTIONS_KEY_SET"] = "Назначить клавишу"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Открывает в игре список назначения клавиш, где у Good to Go есть свой раздел."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Открывает и закрывает улучшенную книгу заклинаний. У неё также есть своя вкладка в вашей книге заклинаний."
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Применяет следующий бафф, предлагаемый окном дежурства по баффам, по одному за нажатие, вне боя. Баффы оружия по-прежнему накладываются кликом по окну. Чтобы нажимать эту кнопку из макроса, используйте %s."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Подсказки уровней заклинаний"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"Подсказка каждой способности показывает её уровни и уровень персонажа, нужный для каждого: белым известные вам, зелёным те, что можно изучить уже сейчас, и серым ещё недоступные. Это быстрая самопроверка, что вы используете лучший уровень заклинания и всегда играете на пределе возможностей. В бою уровни не показываются, чтобы подсказки оставались короткими, когда это важно."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Включить подсказки уровней заклинаний"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Добавляет уровни каждой способности в её подсказку на панелях команд, в игровой книге заклинаний и в других аддонах. При выключении эти подсказки остаются такими, какими их показывает игра. Собственное окно улучшенной книги заклинаний показывает уровни в любом случае."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Удаление макросов"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Удаляет макросы, созданные улучшенной книгой заклинаний, и тем самым убирает их с панелей команд. Ваши собственные макросы не затрагиваются, а страница создаст любой из них заново, если нажать на него или перетащить."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Удалить макросы персонажа"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Удаляет макросы улучшенной книги заклинаний со вкладки макросов этого персонажа. Другие ваши персонажи сохранят свои, пока вы не сделаете то же самое на них."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Удалить все макросы улучшенной книги заклинаний на этом персонаже? Они также исчезнут с панелей команд."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Удалить общие макросы"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	'Удаляет макросы улучшенной книги заклинаний со вкладки "Общие макросы", общей для всех персонажей вашей учётной записи, поэтому другие ваши персонажи тоже их там лишатся.'
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Удалить все общие макросы улучшенной книги заклинаний? Их лишатся все персонажи вашей учётной записи, и они также исчезнут с панелей команд."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Показывает после основного макроса заклинания отдельный макрос для каждого известного вам более низкого уровня, и каждый из них всегда применяет свой уровень."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Показывает все известные вам заклинания из группы, например Омовение и Очищение. Если выключено, показывается только изученное последним, но макросы остальных всё равно обновляются."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Показывает еще не изученные заклинания класса в разделе Не изучено, чтобы вы могли заранее разместить их макросы."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] =
	"Размещает заклинание там, куда указывает курсор, без круга выбора цели."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] =
	"Применяет самый высокий уровень заклинания, доступный для уровня дружественного игрока."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Сначала прерывает то, что вы применяете, чтобы это заклинание сработало сразу."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] =
	"Сначала прекращает вашу автоатаку в ближнем бою."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Ничего не делает, пока вы поддерживаете заклинание, поэтому нажатие никогда не прервет поддержание."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Ничего не делает, пока вы в незаметности, поэтому нажатие никогда не прервет Незаметность или Крадущегося зверя."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Сначала выводит из текущего облика, чтобы заклинание можно было применить."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Сначала выбирает ближайшего врага, если у вас в цели нет живого врага."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Сначала выбирает ближайшего союзника, если у вас в цели нет живого союзника."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] =
	"Также отправляет питомца атаковать вашу цель."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] =
	"Начинает автоатаку в ближнем бою после применения."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] =
	"Начинает Автоматическую стрельбу или стрельбу жезлом после применения."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] =
	"Применяется один раз и больше не применяется, пока не сменится цель."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Применяется один раз и больше не применяется, пока не закончится бой или не сменится цель."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Оставляет облик или дух включённым при повторном нажатии макроса, а не выключает его."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] =
	"Убирает красный текст ошибки, который макрос оставляет на экране."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] =
	"Отключает звук ошибки, пока выполняется макрос."
L["KIND_ENEMY"] = "Заклинания против врагов"
L["KIND_ENEMY_DESCRIPTION"] =
	"Заклинания, применяемые к врагу, например атаки и ослабления."
L["KIND_FRIENDLY"] = "Дружественные заклинания"
L["KIND_FRIENDLY_DESCRIPTION"] =
	"Заклинания, применяемые к союзнику, например исцеление."
L["KIND_BUFF"] = "Баффы"
L["KIND_BUFF_DESCRIPTION"] = "Заклинания, дающие союзнику длительный бафф."
L["KIND_RESURRECT"] = "Воскрешение"
L["KIND_RESURRECT_DESCRIPTION"] =
	"Заклинания, которые вы применяете к мёртвому союзнику, чтобы вернуть его к жизни."
L["KIND_ANYONE"] = "Заклинания для союзника или врага"
L["KIND_ANYONE_DESCRIPTION"] =
	"Заклинания, которые можно применить и к союзнику, и к врагу."
L["KIND_GROUND"] = "Заклинания по земле"
L["KIND_GROUND_DESCRIPTION"] = "Заклинания, которые вы размещаете на земле."
L["KIND_FORM"] = "Облики, стойки и духи"
L["KIND_FORM_DESCRIPTION"] =
	"Заклинания, которые действуют, пока вы их не отключите или не смените."
L["KIND_SELF"] = "Заклинания на себя и по области"
L["KIND_SELF_DESCRIPTION"] =
	"Заклинания без цели, применяемые на себя или вокруг себя."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Показать/скрыть улучшенную книгу заклинаний"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"В целях безопасности список назначения клавиш нельзя открыть во время боя."
L["KEY_BINDINGS_LOCATION"] =
	"Откройте меню игры, затем %s, затем %s, и найдите раздел Good to Go."
L["ERROR_MACRO_SLOTS_FULL"] =
	"Нет свободных ячеек для макросов. Удалите макрос в /macro, чтобы освободить место."
L["ERROR_MACRO_WINDOW_OPEN"] = "Сначала закройте окно макросов."
L["CHAT_MACROS_DELETED"] = "Удалено макросов: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'Макрос "%s" с включенными параметрами занимает %d байт, больше %d, которые вмещает макрос. Отключите параметр, чтобы сократить его.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'Макрос "%s" занимает %d байт, больше %d, которые вмещает макрос, поэтому его последняя строка обрезана.'
