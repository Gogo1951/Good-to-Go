local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "ptBR")
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
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) ficam em Opções > AddOns > Good to Go. Gostando deste addon? Conte para um amigo, favorite-o no CurseForge ou clique em Star na página dele no GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Ajude o Good to Go a subir de nível"
L["OPTIONS_LEVEL_UP_THANKS"] = "Obrigado por escolher o Good to Go!"

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

L["MACRO_BANDAGE"] = "- Bandagem"
L["MACRO_EXPLOSIVES"] = "- Explosivos"
L["MACRO_FEED_PET"] = "- Alim. Ajudante"
L["MACRO_FOOD"] = "- Comida"
L["MACRO_HEALTH_POTION"] = "- Poção de Cura"
L["MACRO_HEALTHSTONE"] = "- Pedra de Vida"
L["MACRO_MANA_GEM"] = "- Gema de Mana"
L["MACRO_MANA_POTION"] = "- Poção de Mana"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Pedra de Alma"
L["MACRO_WATER"] = "- Água"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s e %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s e %s"
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

L["DIET_BREAD"] = "Pão"
L["DIET_CHEESE"] = "Queijo"
L["DIET_FISH"] = "Peixe"
L["DIET_FRUIT"] = "Fruta"
L["DIET_FUNGUS"] = "Fungo"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Parece que você encontrou um bug! %s (%s) não pode ser usado em %s > %s (%s). Por favor, informe o problema para que possamos corrigi-lo. Obrigado! %s"
L["MESSAGE_NO_ITEM"] = "Nenhum item adequado do tipo %s encontrado nas suas bolsas."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Algumas macros do Good to Go não puderam ser criadas porque seus espaços de macro estão cheios. Libere um espaço excluindo macros que você não usa mais, ou desative as macros do Good to Go de que você não precisa em Opções > AddOns > Good to Go > Macros de Consumíveis."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Suas macros estão prontas. Digite %s, abra a aba %s e arraste - Comida, - Água e as demais para suas barras de ação."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s agora está na Lista de Ignorados deste personagem."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "1 item removido da Lista de Ignorados deste personagem."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "%d itens removidos da Lista de Ignorados deste personagem."

L["CHAT_OPTIONS_IN_COMBAT"] = "Por segurança, a interface de opções não pode ser aberta durante o combate."

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

L["READINESS_TITLE"] = "Relatório de Prontidão"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Buffs faltando:"
L["READINESS_EXPIRING"] = "Expirando em breve:"
L["READINESS_MISSING_ITEMS"] = "Itens faltando:"
L["READINESS_DAMAGED_GEAR"] = "Equipamento danificado:"
L["READINESS_CHARACTER"] = "Personagem:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipamento não combativo equipado:"

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
L["READINESS_FLASK"] = "Frasco ou 2x elixires"
L["READINESS_PET_FORMAT"] = "%s (ajudante)"
L["READINESS_SCROLLS"] = "Pergaminhos"
L["READINESS_SOULSTONE"] = "Pedra da Alma inativa"
L["READINESS_HEALTHSTONE"] = "Pedra de Vida"
L["READINESS_MANA_GEM"] = "Gema de Mana"
L["READINESS_HEALING_POTION"] = "Poção de Cura"
L["READINESS_MANA_POTION"] = "Poção de Mana"
L["READINESS_BANDAGES"] = "Bandagens"
L["READINESS_PVP_ON"] = "JxJ ativado"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s menos de 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 ponto de talento não gasto"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d pontos de talento não gastos"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Atualmente você não tem nenhuma comida útil para o seu ajudante."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Você ainda não aprendeu %s, %s, %s ou %s."
L["TIP_NO_HAND_POISON"] = "Você está sem o veneno escolhido para esta arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Você ainda não aprendeu %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "Sem %s nas suas bolsas. Clique com o botão direito em %s para conjurar mais."
L["TIP_EMPTY_CREATE"] = "Sem %s nas suas bolsas. Clique com o botão direito em %s para criar uma."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Comida com Buff"
L["FEATURE_SCROLL_BUFFS"] = "Buffs de Pergaminho"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Comida com Buff e Pergaminhos"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Usa comida que concede "%s" e aplica os buffs de pergaminho que faltam antes de você comer.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Comida atual"
L["MINIMAP_BEST_PET_FOOD"] = "Comida de Ajudante atual"
L["MINIMAP_MAIN_HAND_POISON"] = "Veneno da Mão Principal"
L["MINIMAP_OFF_HAND_POISON"] = "Veneno da Mão Secundária"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista de Ignorados"
L["MINIMAP_IGNORE_COUNT"] = "%d itens"
L["MENU_IGNORE"] = "Ignorar"
L["MENU_CLEAR_IGNORE"] = "Limpar Lista de Ignorados"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Relatório do Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d pedidos pendentes"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Parabéns, seu estoque está completo!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Sua lista está vazia."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista de reabastecimento"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra e guarda no banco os itens da sua lista."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + clique direito"
L["MENU_OPTIONS"] = "Opções do GtG"
L["MENU_OPTIONS_KEYBIND"] = "Shift + clique do meio"

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
L["NOTE_MACRO_FEED_PET"] = "Macro de Alim. Ajudante"
L["NOTE_MACRO_FOOD_WATER"] = "Macros de Comida e Água"
L["NOTE_MACRO_MANA_GEM"] = "Macro de Gema de Mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro de Pedra de Vida"
L["NOTE_MACRO_SOULSTONE"] = "Macro de Pedra de Alma"
L["NOTE_MACRO_POISONS"] = "Macro de Venenos"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Chamar, alimentar ou reviver"
L["NOTE_PET_MEND_CLICK"] = "Clique direito, ou em combate"
L["NOTE_HOLD_SHIFT"] = "Segure Shift"
L["NOTE_PET_FORCE_REVIVE"] = "Forçar reviver"
L["NOTE_HOLD_CONTROL"] = "Segure Ctrl"
L["NOTE_PET_DISMISS"] = "Dispensar"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Conjurar"
L["NOTE_CREATE"] = "Criar"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Clique direito de novo"
L["NOTE_LOWER_RANK_BACKUP"] = "Reserva de grau inferior"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Selecione como alvo um jogador de nível mais baixo para conjurar de acordo com o nível dele."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Selecione como alvo um jogador de nível mais baixo para criar uma de acordo com o nível dele."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Janela de Venenos"
L["NOTE_POISONS_REPLACED"] = "Substitui os venenos antigos automaticamente."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandagem"
L["LABEL_EXPLOSIVE"] = "Explosivo"
L["LABEL_FOOD"] = "Comida"
L["LABEL_HEALTH_POTION"] = "Poção de Cura"
L["LABEL_HEALTHSTONE"] = "Pedra de Vida"
L["LABEL_MANA_GEM"] = "Gema de Mana"
L["LABEL_MANA_POTION"] = "Poção de Mana"
L["LABEL_PET_FOOD"] = "Comida de Ajudante"
L["LABEL_POISON"] = "Veneno"
L["LABEL_SOULSTONE"] = "Pedra da Alma"
L["LABEL_WATER"] = "Água"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Ativado"
L["MINIMAP_DISABLED"] = "Desativado"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPEN"] = "Abrir"
L["MINIMAP_LEFT_CLICK"] = "Clique esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Clique direito"
L["MINIMAP_MIDDLE_CLICK"] = "Clique do meio"
L["MINIMAP_SHIFT_LEFT"] = "Shift + clique esquerdo"

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
	"Escolhe quando sua macro de Comida oferece %s: sempre, ou apenas quando você estiver jogando sozinho, em grupo ou raide, em raide, subindo de nível ou no nível máximo."
L["OPTIONS_MODE_CAPTION"] = "Quando usar"
L["MODE_ALWAYS"] = "Sempre"
L["MODE_SOLO"] = "Jogando sozinho"
L["MODE_PARTY"] = "Em grupo ou raide"
L["MODE_RAID"] = "Em raide"
L["MODE_LEVELING"] = "Subindo de nível"
L["MODE_MAX_LEVEL"] = "No nível máximo"

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
L["INVENTORY_REPORT_TITLE"] = "Relatório de Inventário"
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
	"Macros que se atualizam sozinhas com sua melhor comida, água, poções e Pedras de Vida, uma lista de reabastecimento que compra e guarda no banco reagentes e munição, buffs que faltam com um clique, sussurros de agradecimento automáticos e macros de mouseover para cada feitiço."

-- Options: tree labels
L["TAB_ENHANCED_SPELLBOOK"] = "Grimório Aprimorado"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Macros sob o mouse, no cursor e em si mesmo para cada feitiço de classe, criadas com um clique a partir de uma nova aba do grimório, sem sintaxe de macro. Elas se atualizam quando você sobe de nível, treina e troca de especialização. Clique com o botão direito para adicionar foco, parar lançamento, ataque automático, ataque do ajudante ou berloques."
L["SPELLBOOK_IS_OFF"] =
	"O Grimório Aprimorado está desativado. Ative-o em Opções > AddOns > Good to Go > Grimório Aprimorado."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Ativar mensagem de boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Exibe uma mensagem de boas-vindas no chat ao entrar no jogo."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Ativar botão do minimapa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Mostra o botão do minimapa."

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
L["OPTIONS_FEATURES_HEADER"] = "Recursos"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Mostra uma janela com todos do seu grupo que estão sem um buff que você pode dar. Clique em um ícone para lançá-lo."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Mantém suas bolsas abastecidas a partir da sua lista de reabastecimento, comprando dos mercadores e movendo itens de e para o banco, e avisa quando algo está acabando. Desativado, tudo isso para, inclusive a janela da lista de reabastecimento. Suas listas continuam salvas."
L["SWITCH_SPELLBOOK"] = "Ativar Grimório Aprimorado"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Adiciona ao seu grimório uma aba que cria macros sob o mouse, no cursor e em si mesmo para seus feitiços, e as mantém atualizadas conforme você sobe de nível e treina. Desativado, a aba some e as atualizações param. Nunca exclui uma macro; os botões de Excluir macros no painel do Grimório Aprimorado fazem isso."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Desativar o Grimório Aprimorado? A aba sai do seu grimório, e as macros que ele criou param de se atualizar conforme você sobe de nível e treina. Isso não as exclui: elas continuam nas suas barras de ação como estão agora."
L["SWITCH_MACROS"] = "Ativar Macros de Consumíveis"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Mantém suas macros de Comida, Água, Poção e outros consumíveis apontadas para o melhor item das suas bolsas conforme elas mudam. Desativado, as atualizações param e cada macro fica como estava por último. Nunca exclui uma macro; desmarcá-la em Quais macros criar, no painel Macros de Consumíveis, faz isso."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Desativar as Macros de Consumíveis? Suas macros param de se atualizar conforme suas bolsas mudam, então um botão pode continuar tentando usar um item que já acabou. Isso não as exclui: elas continuam nas suas barras de ação como estão agora."
L["SWITCH_INVENTORY_REPORT"] = "Ativar Relatório de Inventário"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Adiciona à dica de interface de um item quantas unidades você tem nas bolsas, no banco e nos seus outros personagens deste reino. Desative se outro addon já mostra essas contagens."
L["SWITCH_READINESS_REPORT"] = "Ativar Relatório de Prontidão"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"Quando uma verificação de jogadores prontos começa, exibe uma lista privada de tudo o que você ainda precisa resolver, como um buff, uma poção ou um equipamento danificado. Não diz nada quando você está pronto."
L["SWITCH_STRANGER_BUFFS_DESCRIPTION"] =
	"Agradece aos jogadores de fora do seu grupo com um sussurro, uma expressão ou ambos quando eles buffam você pelo mundo."
L["SWITCH_GOOD_NEWS"] = "Ativar Compartilhar boas notícias"
L["SWITCH_GOOD_NEWS_DESCRIPTION"] =
	"Sussurra aos jogadores que você buffa o que você lançou neles e, quando o buff é curto, quanto tempo ele dura."
L["SWITCH_COMBAT_BUFFS"] = "Ativar agradecimentos por buffs de combate"
L["SWITCH_COMBAT_BUFFS_DESCRIPTION"] =
	"Agradece aos membros do seu grupo e da raide com um sussurro, uma expressão ou ambos quando eles lançam um buff ou uma habilidade com recarga em você."
L["SWITCH_SERVICE_ALERTS"] = "Ativar Alertas de serviços do grupo"
L["SWITCH_SERVICE_ALERTS_DESCRIPTION"] =
	"Avisa você, e agradece ao jogador, quando alguém disponibiliza um banquete, poço de almas, portal ou robô de reparo para o seu grupo."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Ativar Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Exemplo: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste addon."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre sua lista de reabastecimento."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Este addon foi criado por jogadores que amam este jogo e querem deixá-lo o mais divertido possível para todos. Nunca vamos pedir doações. A verdadeira satisfação é saber que nosso trabalho deixa o jogo um pouco melhor para você. Se for o caso, adoraríamos saber!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Veja algumas formas de nos ajudar a alcançar mais jogadores."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Envie seu feedback: Encontrou um bug ou teve uma ideia? Conte para a gente no Discord. Seu feedback nos ajuda a melhorar o addon, e pull requests são sempre bem-vindos."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Conte para um amigo: Conhece alguém que pode gostar deste addon? Conte para essa pessoa. O boca a boca ajuda mais jogadores a descobrir ótimos addons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorite no CurseForge: Abra o link do CurseForge abaixo, entre na sua conta e clique na estrela abaixo do botão Download. Os favoritos ajudam mais jogadores a descobrir o addon."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Dê uma estrela no GitHub: Abra o link do GitHub abaixo, entre na sua conta e clique em Star no canto superior direito. As estrelas ajudam o projeto a se qualificar para mais ferramentas gratuitas de desenvolvimento."

L["OPTIONS_FEEDBACK"] = "Feedback e suporte"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Links de feedback e suporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Para copiar um link, clique na caixa dele e pressione Ctrl+A e Ctrl+C."
L["OPTIONS_VERSION"] = "Versão %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "Macros de Consumíveis"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"O Good to Go cria uma macro por consumível e a mantém atualizada conforme suas bolsas mudam, então o botão na sua barra sempre busca o melhor item que você está carregando. Escolha abaixo quais macros criar e depois defina como cada uma escolhe seu item."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Ativar nomes de macro nos botões"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Mostra o nome das macros nos botões da sua barra de ações, texto que o Good to Go oculta por padrão."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Quais macros criar"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Escolha quais macros o Good to Go cria e mantém. Desativar uma também a remove. Elas ficam na aba Macros gerais da janela de macros, prontas para arrastar para suas barras de ação."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Abrir janela de macros"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Abre a janela de macros do jogo na aba Macros gerais, onde ficam estas macros."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Cria e mantém esta macro, e a remove quando você desmarca esta opção."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Comida e água"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Suas macros de Comida e Água usam a melhor comida e bebida das suas bolsas. Estas opções podem colocar primeiro a comida com buff, os pergaminhos ou a comida e água conjuradas, e por último a comida e água da lista de reabastecimento."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Priorizar Comida com Buff"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Prioriza comida que concede o buff "%s" quando o buff estiver faltando, exceto nas Arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Ativar Buffs de Pergaminho"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Sua macro de Comida aplica os pergaminhos que faltam no primeiro clique e come no seguinte, ignorando os pergaminhos quando você tem um jogador amigável como alvo ou está em uma Arena."
L["OPTIONS_SCROLL_TYPES"] = "Incluir tipos de pergaminho na verificação"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Proteção"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Inclui %s na verificação de buffs faltando."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usar primeiro comida e água conjuradas"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Suas macros de Comida e Água usam comida e água conjuradas antes de qualquer outra coisa, mesmo quando algo nas suas bolsas restaurar mais, já que elas não custam nada e somem pouco depois que você sai do jogo. A comida com buff continua vindo primeiro enquanto "Priorizar Comida com Buff" estiver ativado.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Escolhe quando comida e água conjuradas vêm primeiro: sempre, ou apenas quando você estiver jogando sozinho, em grupo ou raide, em raide, subindo de nível ou no nível máximo."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Usar por último comida e água da lista de reabastecimento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Entre duas comidas ou bebidas que restauram a mesma quantidade, suas macros de Comida e Água usam a que não está na sua lista de reabastecimento, guardando para depois o que o Restocker compra."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Poções e Pedras de Vida"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"As macros não podem ser alteradas durante o combate (isso é uma restrição da Blizzard), então cada macro de Poção e Pedra de Vida é pré-construída com seu melhor item mais até duas alternativas. Em lutas mais longas, o ícone e a dica de interface podem ficar desatualizados e mostrar o item errado, mas clicar na macro sempre usará o melhor item que você realmente tem nas suas bolsas."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usar comida e água nas macros de Poção fora de combate"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fora de combate, sua macro de Poção de Cura come sua melhor comida e sua macro de Poção de Mana bebe sua melhor água. Em combate, elas usam suas poções como antes. Pergaminhos, comida de ajudante e conjuração continuam nas macros de Comida e Água."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combinar Pedras de Vida na macro de Poção de Cura"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Adiciona sua melhor Pedra de Vida ao final da macro de Poção de Cura, para que um clique use uma poção e uma Pedra de Vida."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemas de Mana e Runas"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s e alguns outros itens de mana compartilham o tempo de recarga com as Gemas de Mana. As runas custam vida ao serem usadas, então a macro de Gema de Mana deixa todos esses itens de fora, a menos que você os adicione."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Adicionar Runas e outros itens de mana à macro de Gema de Mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Classifica %s, %s e qualquer outro item de mana que compartilhe o tempo de recarga das Gemas de Mana, junto com suas Gemas de Mana, para que a macro de Gema de Mana use um deles quando for sua melhor opção ou quando você estiver sem gemas."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Reaplicação de buffs"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"As macros não podem ser alteradas durante o combate, então um buff que expira no meio da luta continua ausente até o combate terminar."
L["OPTIONS_REAPPLY"] = "Reaplicar buffs prestes a expirar"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera expirados Comida com Buff, Buffs de Pergaminho e Buffs de Comida de Ajudante que tenham menos tempo restante que o seu limite, para que suas macros ofereçam um novo antes do combate."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Define o quão perto de expirar um buff pode chegar antes que suas macros ofereçam um novo."
L["REAPPLY_THRESHOLD_ONE"] = "Quando restar < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Quando restarem < %d minutos"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Buffs de Comida de Ajudante"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'Algumas comidas dão ao seu ajudante um buff "%s" próprio.'
L["OPTIONS_USE_PET_BUFFS"] = "Usar Buffs de Comida de Ajudante"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Adiciona comida de ajudante à sua macro de Comida quando falta o buff "%s" no seu ajudante, exceto nas Arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Incluir tipos de Comida de Ajudante na verificação"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosivos"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"A opção @player pula o retículo de mira e detona o explosivo aos seus pés. Ideal quando o alvo está no corpo a corpo. Seu outro clique arremessa o explosivo normalmente."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Configuração de cliques"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Escolhe qual clique arremessa o explosivo e qual o detona aos seus pés."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clique esquerdo @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clique esquerdo arremessar"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Classe e Raça"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Estas opções ajustam suas macros para uma classe ou raça. Todas as seções aparecem em todos os personagens."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Opções de classe: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Opções raciais: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Requer o addon DruidMacroHelper. Ativado, suas macros de Poção de Cura, Poção de Mana e Pedra de Vida tiram você da forma, usam o item e colocam você de volta em Forma de Urso ou Forma de Felino, a que você escolher ao lado da caixa de seleção."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Ativar integração do DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Cria macros de mudança de forma para Poções de Cura, Poções de Mana e Pedras de Vida usando o DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Escolhe para qual forma suas macros de mudança de forma fazem você voltar depois de usar o item."
L["DRUID_FORM_BEAR"] = "Voltar para Urso"
L["DRUID_FORM_CAT"] = "Voltar para Felino"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantém a macro de Venenos carregada com o melhor grau utilizável de cada tipo de veneno: clique esquerdo aplica na mão secundária, clique direito na mão principal, e venenos existentes são substituídos automaticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo de veneno da mão principal"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo de veneno da mão secundária"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Escolhe o veneno que sua macro de Venenos aplica na sua mão principal com o clique direito."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Escolhe o veneno que sua macro de Venenos aplica na sua mão secundária com o clique esquerdo."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Ativar furtividade ao comer"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"Anexa %s à sua macro de Comida para que você entre em furtividade enquanto come."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Ativar furtividade ao beber"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"Anexa %s à sua macro de Água para que você entre em furtividade enquanto bebe."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Dica pro: Escolha um. Você pode comer e beber ao mesmo tempo, mas comer ou beber depois de entrar em furtividade quebrará sua furtividade."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Tenha como alvo um humanoide ou morto-vivo que você matou e sua macro lança %s enquanto o feitiço estiver pronto, poupando sua comida e bebida. Se não puder (o cadáver está fora de alcance ou o feitiço está em recarga), ela come ou bebe como sempre."
L["OPTIONS_CANNIBALIZE_EATING"] = "Usar %s em vez de comer"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Enquanto seu alvo for um cadáver em que %s funcione e o feitiço estiver pronto, sua macro de Comida o lança em vez de comer. Caso contrário, ela come como sempre. Pergaminhos e comida com buff continuam tendo prioridade."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Usar %s em vez de beber"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Enquanto seu alvo for um cadáver em que %s funcione e o feitiço estiver pronto, sua macro de Água o lança em vez de beber. Caso contrário, ela bebe como sempre. Bebidas com buff continuam tendo prioridade."

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
L["TAB_IGNORE_LIST"] = "Lista de Ignorados"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Itens ignorados nunca são escolhidos por nenhuma macro. Comida, água, poções, qualquer coisa. A lista Global vale para todos os personagens; a lista de um personagem vale só para ele. Clique com o botão direito no botão do minimapa para ignorar sua melhor comida atual."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Move este item para a lista Global, para que seja ignorado em todos os personagens."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Adicionar das bolsas"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Escolha qualquer coisa que você carrega. As bolsas se fecham quando a interface de opções abre, então isto substitui arrastar um item para cá."
L["OPTIONS_IGNORE_ADD_ID"] = "Adicionar por ID do item"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Digite um ID de item, ou dê Shift + Clique em um link de item no chat enquanto este campo estiver ativo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Digite um ID de item, ou dê Shift + Clique em um link de item no chat."
L["OPTIONS_IGNORE_REMOVE"] = "Remover"
L["OPTIONS_IGNORE_EMPTY"] = "Esta lista está vazia."
L["OPTIONS_IGNORE_CLEAR"] = "Limpar lista"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Remove todos os itens desta lista. Um personagem com a lista vazia sai da lista à esquerda, a menos que seja o que você está jogando."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "Remover todos os itens desta lista? Isso não pode ser desfeito."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Carregando ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantém suas bolsas abastecidas a partir da sua lista de reabastecimento, comprando dos mercadores e movendo itens de e para o banco automaticamente. Digite %s para abrir a lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Abrir no banco"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre sua lista de reabastecimento quando você visita o banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir no mercador"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre sua lista de reabastecimento quando você visita um mercador."
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Lembretes"
L["OPTIONS_RESTOCKER_REMIND"] = "Ativar lembretes de reabastecimento na cidade"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Exibe um lembrete no chat quando falta algo na sua lista de reabastecimento e você chega a uma estalagem ou cidade, ou já está em uma ao entrar no jogo."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Ativar lembretes de reabastecimento no mercador"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa quaisquer pedidos de reabastecimento pendentes quando você fecha a janela de um mercador."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Ativar lembretes de reabastecimento no banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa quaisquer pedidos de reabastecimento pendentes quando você fecha o banco."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Ativar reserva de ouro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "O reabastecimento nunca gasta o ouro que você separar aqui."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Define quanto ouro o reabastecimento sempre deixa com você."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Escolhe se o lembrete fica em uma única linha ou adiciona uma linha para cada item em falta."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "Quanto detalhar"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simples"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Detalhado"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Tocar som"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Toca um alerta junto com o lembrete, para quando o chat está agitado."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Clique para ouvir o alerta."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Janela da lista de reabastecimento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Escolha quando sua lista de reabastecimento se abre sozinha."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Mostra na dica de interface de um item quantas unidades dele você possui, somando todos os seus personagens neste reino."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Personagens registrados"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Esquecer"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"Esquecer %s? As bolsas e o banco desse personagem saem de todas as dicas de itens, e a escolha de lista de reabastecimento dele é apagada. Entrar no jogo com ele o registra novamente."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Relatório de Prontidão"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quando uma verificação de jogadores prontos começa, exibe uma lista privada do que ainda precisa ser resolvido e não diz absolutamente nada quando está tudo pronto."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Redefinir configurações do Relatório de Prontidão"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Restaura todas as caixas de seleção e os dois limites desta página para os valores padrão."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Redefinir todas as configurações do Relatório de Prontidão para o padrão? Isso também desliga o próprio relatório de novo."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Buffs faltando"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Itens faltando"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personagem"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Avisa quando falta um frasco. Um frasco, ou um elixir de batalha e um elixir guardião, já é suficiente."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Avisa quando falta o buff "%s". Requer Comida com Buff ativada em Macros de Consumíveis.'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Avisa quando falta o buff "%s" no seu ajudante. Requer Buffs de Comida de Ajudante ativado em Macros de Consumíveis, e um ajudante invocado.'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"Avisa quando faltam buffs de pergaminho. Requer Buffs de Pergaminho ativado em Macros de Consumíveis, e verifica só os tipos de pergaminho selecionados lá."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Avisa quando ninguém do seu grupo tem uma Pedra da Alma ativa; uma guardada na bolsa não conta. Só avisa um Bruxo que possa criar uma."
L["OPTIONS_READINESS_MAIN_HAND"] = "Buff de arma (Mão Principal)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Avisa quando a arma da mão principal não tem encantamento temporário. Qualquer encantamento conta, e o aviso não aparece quando há um Xamã no seu grupo."
L["OPTIONS_READINESS_OFF_HAND"] = "Buff de arma (Mão Secundária)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Avisa quando a arma da mão secundária não tem encantamento temporário. Qualquer encantamento conta: uma pedra, um óleo, um veneno ou um buff de arma de Xamã."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buffs expirando em até"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Lista todos os buffs em você que estão prestes a expirar, não só os que o Good to Go aplica, e é independente da Reaplicação de buffs em Macros de Consumíveis."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutos"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Define o quão perto de expirar um buff precisa estar para que o relatório o liste."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma Pedra de Vida. Só avisa quando há um Bruxo no grupo a quem pedir, ou quando o Bruxo é você."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma Gema de Mana. Só avisa um Mago que possa conjurar uma."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma poção de cura, já que ninguém pode entregar uma para você no meio da luta."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma poção de mana. Só avisa quando você está jogando com uma classe que usa mana."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma bandagem que sua perícia em %s permita usar."
L["OPTIONS_READINESS_DURABILITY"] = "Equipamento danificado abaixo de"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Mostra o link de cada item equipado abaixo dessa durabilidade, medida por item para que uma única arma quebrada ainda apareça."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Define o quão baixa a durabilidade de um item precisa ficar para que o relatório mostre o link dele."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Especialização atual"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Mostra sua distribuição de talentos, e os pontos que você não gastou."
L["OPTIONS_READINESS_PVP"] = "Marcação JxJ ativa"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avisa quando sua marcação JxJ está ativa."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipamento não combativo equipado"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Mostra o link de itens equipados que não têm lugar em combate, como equipamento de montaria ou de pesca."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Inventory-Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Já existe uma lista chamada "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Não há item com ID %d."
L["RESTOCKER_DISABLED"] = "O Restocker está desativado. Ative-o em Opções > AddOns > Good to Go > Restocker."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Reabastecimento concluído. Segure Shift ao abrir o banco para pular o reabastecimento. Digite %s para editar sua lista de reabastecimento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Reabastecimento interrompido. Suas bolsas e seu banco estão cheios."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Reabastecimento interrompido. Seu banco está cheio; libere um espaço e reabra-o."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Reabastecimento interrompido. Suas bolsas estão cheias; libere um espaço e reabra o banco."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Reabastecimento interrompido. Nenhum progresso foi possível."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Reabastecimento interrompido. Não foi possível mover: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (excedente)"
L["RESTOCKER_STOPPED_ERROR"] = "Reabastecimento interrompido por um erro: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Inventory-Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Este mercador não tem todos os ingredientes de que seus venenos precisam. Nenhum será comprado."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Não se esqueça de reabastecer enquanto estiver na cidade!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 pedido de reabastecimento pendente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d pedidos de reabastecimento pendentes."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Sua lista de reabastecimento recebeu melhorias."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d passa a %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 pedido de reabastecimento atendido."
L["RESTOCKER_RESTOCKED_MANY"] = "%d pedidos de reabastecimento atendidos."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 pedido de reabastecimento atendido em parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d pedidos de reabastecimento atendidos em parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Suas bolsas encheram antes de tudo ser comprado."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "Ouro insuficiente para concluir o reabastecimento."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] = "Você tem menos de %s. O reabastecimento será retomado quando você tiver mais."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nome]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Adiciona uma lista com esse nome."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Exclui a lista com esse nome."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renomeia a lista atual para esse nome."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Substitui a lista atual por uma cópia da lista com esse nome."
L["RESTOCKER_HELP_PROFILE_USE"] = "Troca este personagem para a lista com esse nome."

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
L["STARTER_POPUP_TITLE"] = "Básicos"
L["STARTER_POPUP_INTRO_LOGIN"] = "Marcamos alguns básicos da sua classe para você começar."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Sua lista de reabastecimento está vazia, então vamos adicionar alguns itens para você começar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Escolha os básicos que você quer manter abastecidos."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tudo o que você marcar é reabastecido automaticamente sempre que você visitar um mercador ou o seu banco. A maioria dos básicos melhora sozinha conforme você sobe de nível, então você sempre terá o melhor disponível."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "Você sempre pode ajustar esta lista, ou adicionar mais itens depois, digitando %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Comida e água"
L["STARTER_POPUP_FOOD_HEADER"] = "Comida"
L["STARTER_POPUP_AMMO_HEADER"] = "Munição"
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
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagentes e ferramentas"
L["STARTER_POPUP_POISONS_HEADER"] = "Venenos"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Adicione o veneno pronto à sua lista, e o Good to Go compra os ingredientes automaticamente em qualquer mercador que venda todos eles."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Adiciona %s à sua lista de reabastecimento, mantendo %d nas suas bolsas e melhorando-os conforme você sobe de nível."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Adiciona %s à sua lista de reabastecimento, mantendo %d nas suas bolsas."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pilha"
L["STARTER_POPUP_STACK_MANY"] = "%d pilhas"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Quantas pilhas manter em estoque, sendo que uma pilha equivale a %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Quantos manter em estoque, cada um em seu próprio espaço na bolsa, já que não empilham."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Lista de reabastecimento"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar itens..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Limpar"
L["RESTOCKER_ADD_BUTTON"] = "Adicionar"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Escolher básicos"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Escolha entre os básicos da sua classe e do seu nível: comida, água, munição, venenos e reagentes. Ao marcar um, ele é adicionado a esta lista; ao desmarcá-lo, ele é removido."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Adicionar um item"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Solte um item das suas bolsas aqui ou em qualquer lugar desta janela, ou digite um ID de item e pressione Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Solte o item ou digite o ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Em vez disso, digite o ID."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Já está nesta lista."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Adicionar das bolsas"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Todos os itens das suas bolsas que ainda não estão nesta lista. Clique em um para adicioná-lo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nada nas suas bolsas para adicionar"

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
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Clique para trocar este personagem para outra lista de reabastecimento, ou para começar uma nova."
L["RESTOCKER_USED_BY"] = "Usada por %s"
L["RESTOCKER_MANAGE"] = "Gerenciar listas"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Comece uma nova lista, ou copie, renomeie ou exclua esta."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nova lista"
L["RESTOCKER_MANAGE_COPY"] = "Copiar esta lista para uma nova"
L["RESTOCKER_RENAME_PROFILE"] = "Renomear esta lista"
L["RESTOCKER_MANAGE_DELETE"] = "Excluir esta lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Cópia"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renomear"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renomeia esta lista para todos os personagens que a usam."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Tem certeza de que deseja excluir esta lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s também a usa e, ao entrar no jogo, terá uma lista vazia com o mesmo nome."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s também a usam e, ao entrar no jogo, cada um terá uma lista vazia com o mesmo nome."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Você passará a usar %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "É a única lista que resta, então você começará com uma nova lista vazia."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Isso não pode ser desfeito."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Melhorar conforme você sobe de nível"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permite que o Good to Go substitua comida, água, munição, venenos, poções e reagentes de classe por itens melhores conforme você sobe de nível."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banco"
L["RESTOCKER_ROW_MERCHANT"] = "Mercador"
L["RESTOCKER_ROW_UPGRADE"] = "Melhoria"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Item"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Pegar"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Guardar"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Manter"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Clique no cabeçalho para definir isto em todos os itens exibidos."
L["RESTOCKER_BULK_ON"] = "Ativar nos exibidos (%d)"
L["RESTOCKER_BULK_OFF"] = "Desativar nos exibidos (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Outros"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Novos"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Todos os itens"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Nada nesta lista ainda"
L["RESTOCKER_EMPTY_BODY"] =
	"Escolha básicos como comida, água ou reagentes de classe, ou adicione qualquer coisa das suas bolsas pelo menu acima. Os itens desta lista são mantidos em estoque ou guardados no seu banco automaticamente, deixando suas bolsas organizadas."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Soltar um item em qualquer lugar desta janela também o adiciona."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nada nesta lista corresponde ao seu filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "Não resta nada nesta categoria."

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
L["RESTOCKER_NO_ORDERS"] = "Nenhum pedido de reabastecimento pendente."
L["RESTOCKER_REPORT_MORE"] = "E mais %d."
L["RESTOCKER_REMOVED_ITEM"] = "Você removeu %s."
L["RESTOCKER_UNDO"] = "Desfazer"
L["RESTOCKER_UNDO_TOOLTIP"] = "Devolver este item à lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Remover este item da lista de reabastecimento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Você pode desfazer isso na parte inferior da janela."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Manter nas suas bolsas"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Quantos manter nas suas bolsas. O número fica amarelo enquanto suas bolsas tiverem menos, e 0, com Guardar ativado, envia tudo para o banco."
L["RESTOCKER_BUY_LABEL"] = "Comprar"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Comprar do mercador"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra a quantidade necessária do mercador quando a janela do mercador está aberta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Comprar extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra todo o estoque limitado que um mercador tem deste item, as mercadorias de poucas unidades que ele repõe devagar, mesmo acima do valor da coluna Manter."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar no banco"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda os itens excedentes no banco quando o banco está aberto, ou todos eles com 0 na coluna Manter."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Pegar do banco"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Pega os itens necessários do banco quando o banco está aberto."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputação exigida"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de desconto)"
L["RESTOCKER_REPUTATION_ANY"] = "Qualquer"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputação exigida com o mercador"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Clique para definir a reputação que um mercador exige antes que o Good to Go compre dele, o que também reduz o preço: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Com um traço, compra de qualquer mercador."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Comprar está desativado para este item, então não há nada extra para comprar."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Comprar está desativado para este item, então nenhuma reputação se aplica."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Este item não tem uma versão melhor para substituí-lo."

-- MIGRATION (remove after 2026-11-25): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Suas configurações do %s foram copiadas."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"O Good to Go copiou suas configurações do %s e desativou o %s, que ele substitui. Recarregar agora para que a cópia antiga pare de rodar?"
L["POPUP_LEGACY_RELOAD_TURNED_OFF"] =
	"O Good to Go desativou o %s, que ele substitui. Recarregar agora para que a cópia antiga pare de rodar?"
L["POPUP_LEGACY_RELOAD_ACCEPT"] = "Recarregar agora"
L["POPUP_LEGACY_LATER"] = "Depois"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"O Good to Go encontrou instalado, mas desativado: %s. Trazer as configurações? Isso reativa os addons antigos e recarrega sua interface, depois oferece mais uma recarga para desativá-los de novo."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"O Good to Go encontrou instalado, mas desativado: %s. Trazer as configurações e as listas de reabastecimento? Isso reativa os addons antigos e recarrega sua interface, depois oferece mais uma recarga para desativá-los de novo."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Trazer tudo"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "Não, obrigado"

--------------------------------------------------------------------------------
-- Automated Appreciation
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "%s buffou você com %s!"
L["MESSAGE_GAVE_YOU"] = "%s deu %s a você!"
L["MESSAGE_GAVE_GROUP"] = "%s deu %s ao seu grupo!"
L["MESSAGE_USED_ITEM"] = "%s usou %s em você!"
L["MESSAGE_USED_SPELL"] = "%s lançou %s em você!"
L["MESSAGE_SET_OUT"] = "%s colocou %s!"
L["MESSAGE_OPENED"] = "%s abriu %s!"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "Obrigado por %s"
L["MESSAGE_SELECT_PLAYER"] = "Primeiro, selecione um jogador como alvo."
L["MESSAGE_CANT_THANK_SELF"] = "Você não pode agradecer a si mesmo!"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "Feitiço desconhecido"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "Buffs de estranhos"
L["STRANGERS_ENABLE"] = "Ativar agradecimentos por buffs de estranhos"
L["STRANGERS_DESCRIPTION"] = "Agradeça aos jogadores de fora do seu grupo quando eles buffarem você no mundo aberto."
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "Recarga dos agradecimentos"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"Define o intervalo entre uma rodada de agradecimentos e a próxima, não importa quem buffou você. Defina como zero para agradecer todos os buffs."
L["STRANGERS_SOURCE_COOLDOWN"] = "Recarga de agradecimento ao mesmo jogador"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"Define o intervalo entre agradecimentos dirigidos ao mesmo jogador. Defina como zero para agradecer todos os buffs."
L["STRANGERS_MIN_DURATION"] = "Duração mínima do buff"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"Ignora buffs com duração menor que este valor. Defina como zero para reagir a todos os buffs."

-- Combat Buffs
L["TAB_COMBAT_BUFFS"] = "Buffs de combate"
L["TEAMMATES_DESCRIPTION"] =
	"Agradeça aos membros do grupo e da raide pelos buffs e habilidades com recarga que eles lançam em você."
-- Shown on WoW Forever only.
L["TEAMMATES_FOREVER_WARNING"] =
	"Isto provavelmente não funcionará direito no WoW Forever. O jogo muitas vezes oculta quem lançou um buff em você, principalmente durante o combate, então muitos buffs ficam sem agradecimento."

-- Group Service Alerts
L["TAB_GROUP_SERVICE_ALERTS"] = "Alertas de serviços do grupo"
L["SERVICES_DESCRIPTION"] =
	"Reaja quando alguém disponibiliza ajuda para o seu grupo: banquetes, poços de almas, portais e robôs de reparo."

-- Sharing Good News
L["TAB_SHARING_GOOD_NEWS"] = "Compartilhar boas notícias"
L["GOOD_NEWS_DESCRIPTION"] =
	"Avise os jogadores que você buffa sobre o que lançou neles e, nos buffs curtos, quanto tempo dura."
L["GOOD_NEWS_SCOPE"] = "Destinatários"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "Qualquer um que você buffar"
L["GOOD_NEWS_SCOPE_GROUP"] = "Apenas membros do grupo"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"Define quem recebe um sussurro de boas notícias: qualquer um que você buffar ou apenas os membros do seu grupo."
L["GOOD_NEWS_MESSAGES_HEADER"] = "Mensagem de boas notícias"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "O sussurro que os jogadores que você buffa recebem."
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] = "Define o que o sussurro diz. Deixe em branco para usar o texto padrão."
L["GOOD_NEWS_MESSAGE_LIMIT"] = "Comprimento máximo: %d."
L["GOOD_NEWS_MESSAGE_TOKENS"] = "%a vira o link da habilidade, com a duração quando ela é menor que um minuto."
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "por %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "Habilidades rastreadas"
L["TRACKED_GROUP_ITEMS"] = "Itens"
L["TRACKED_ITEM_PENDING"] = "Item nº %d"
L["TRACKED_SPELL_PENDING"] = "Feitiço nº %d"

-- Shared by Sharing Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "Mensagem de sussurro"
L["WHISPER_MESSAGE_RESET"] = "Redefinir"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "Redefine a mensagem de sussurro para o texto padrão."

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "Sussurros de agradecimento e expressões"
L["NOTIFICATIONS_HEADER"] = "Notificações"
L["PRAISE_DESCRIPTION"] = "O que o outro jogador vê: um sussurro de agradecimento, uma expressão ou ambos."
L["NOTIFICATIONS_DESCRIPTION"] = "O que só você recebe: um aviso de texto, um som ou ambos."

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "Selecionar expressões"

L["PRAISE_WHISPER_ENABLE"] = "Ativar sussurros de agradecimento"
L["PRAISE_WHISPER_DESCRIPTION"] = "Sussurra um agradecimento ao jogador que buffou você."
L["PRAISE_EMOTES_ENABLE"] = "Ativar expressões"
L["PRAISE_EMOTES_DESCRIPTION"] =
	"Mostra sua gratidão com uma expressão. As expressões ficam retidas enquanto você está em combate."
L["PRAISE_DELAY_ENABLE"] = "Ativar atraso do agradecimento"
L["PRAISE_DELAY_DESCRIPTION"] =
	"Espera um momento antes do sussurro e da expressão, para que seu agradecimento não chegue no mesmo instante que o buff. As notificações não são afetadas."
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "Define quanto tempo esperar antes de enviar o sussurro e a expressão."

L["NOTIFICATIONS_PRINT_ENABLE"] = "Ativar avisos de texto"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "Exibe uma mensagem que só você vê quando recebe um buff."
L["NOTIFICATIONS_SOUND_ENABLE"] = "Ativar efeitos sonoros"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "Toca um som quando você recebe um buff. Só você ouve."
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Toca o som para você ouvi-lo antes de ativá-lo."

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "Portais"
L["GROUP_RESISTANCE_CAULDRONS"] = "Caldeirões de Resistência"
L["GROUP_REPAIR_BOTS"] = "Robôs de Reparo"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Plantão de buffs"
L["BUFF_DUTY_DESCRIPTION"] = "Mostra quem está sem os seus buffs. Clique em um ícone para lançar."
L["BUFF_DUTY_ENABLE"] = "Ativar Plantão de buffs"
L["BUFF_DUTY_NO_BUFFS"] = "Sua classe não tem buffs nesta lista, então a janela nunca aparece neste personagem."
-- When to Show: Solo, In Party and In Raid, each with Always or In Instance, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "Quando mostrar"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Escolha quando a janela pode aparecer."
L["BUFF_DUTY_WHEN_SOLO"] = "Sozinho"
L["BUFF_DUTY_WHEN_SOLO_DESCRIPTION"] = "Mostra a janela quando você não está em grupo ou raide."
L["BUFF_DUTY_WHEN_PARTY"] = "Em grupo"
L["BUFF_DUTY_WHEN_PARTY_DESCRIPTION"] = "Mostra a janela quando você está em grupo."
L["BUFF_DUTY_WHEN_RAID"] = "Em raide"
L["BUFF_DUTY_WHEN_RAID_DESCRIPTION"] = "Mostra a janela quando você está em raide."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Define onde a janela aparece: em qualquer lugar, ou só dentro de masmorras, raides, campos de batalha e arenas."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Sempre"
L["BUFF_DUTY_WHERE_INSTANCE"] = "Em instância"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Mostra a janela quando você joga com estas classes."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Mostra a janela quando você joga com esta classe."
L["BUFF_DUTY_HEADER"] = "Janela"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Mantenha a janela onde você a deixou, ou tire-a do caminho em combate."
L["BUFF_DUTY_LOCK"] = "Travar janela"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "Impede que a janela seja movida. Destravada, arraste-a pelo fundo."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Ocultar em combate"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Oculta a janela durante o combate. A lista não pode ser atualizada em combate, então uma janela deixada à mostra mantém o último estado até o combate terminar."
L["BUFF_DUTY_SHOW_HEADER"] = "Mostrar na janela"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"Adicione à janela os seus próprios buffs, os estranhos que buffaram você e o seu alvo."
L["BUFF_DUTY_FAVOR_ENABLE"] = "Retribuir o favor"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Lista os estranhos que buffaram você recentemente, com os buffs que você pode devolver a eles. Clique com o botão direito em um ícone para tirar alguém da lista."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"Define por quanto tempo um estranho fica na lista após o último buff dele."
L["BUFF_DUTY_TARGET_ENABLE"] = "Seu alvo"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Lista o seu alvo quando ele é um jogador de fora do seu grupo sem um buff que você pode dar."
L["BUFF_DUTY_ASK_OTHERS"] = "Pedir buffs a outras classes"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Mostra em “Buffs de grupo faltando” os buffs de raide que faltam ao seu grupo, com quantos jogadores precisam de cada um. Clique com o botão esquerdo em um para pedi-lo ao seu grupo, ou com o botão direito para sussurrar aos jogadores que podem lançá-lo."
L["BUFF_DUTY_REFRESH"] = "Renovar abaixo de"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Define com quanto tempo restante um buff passa a contar como ausente, para que você possa renová-lo antes que ele acabe. Um buff que não dura mais do que isso só conta depois que acaba."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Contar como tanques"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Quem recebe os buffs que você oferece a Tanques, como Espinhos, quando não tem uma função própria."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Define quando os jogadores desta classe contam como tanques. Uma função de tanque ou curador que eles tenham sempre vem primeiro."
L["BUFF_DUTY_TANKS_PETS"] = "Ajudantes"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"Define quando os ajudantes contam como tanques. Os ajudantes também recebem os buffs que você oferece a Todos."
L["BUFF_DUTY_TANKS_NEVER"] = "Nunca"
L["BUFF_DUTY_TANKS_SOLO"] = "Quando não estiver em grupo"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Sempre"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Desativado"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Tanques"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Curadores"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Todos"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Define para quem oferecer %s."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Escolha para quem cada buff é oferecido. Tanques e Curadores seguem a função no grupo, mas em raide só contam como tanques os jogadores marcados como %s. Quem não tiver função conta como Dano, a menos que Contar como tanques, abaixo, diga o contrário."

L["BUFF_DUTY_SELF_DESCRIPTION"] = "Seus próprios buffs, fixados no topo da janela."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "qualquer aspecto conta"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "qualquer armadura conta"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "qualquer aura conta"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "qualquer escudo conta"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "qualquer armadura conta"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "qualquer um dos dois buffs demoníacos conta"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Desativado"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "Quando faltar"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Menos de %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Define quando %s aparece: nunca, quando acabar ou quando restar menos que esse tempo."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Buffs de arma"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Marque o que cada arma deve ter. A janela oferece quando estiver faltando ou acabando, se estiver nas suas bolsas e servir na arma."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "Reaplicar"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Define quando um buff de arma é oferecido de novo: quando acabar ou quando restar menos que esse tempo."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Óleos"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Pedras"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Iscas"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Oferece %s para a sua arma (%s). Enquanto a arma não tiver nenhuma das opções marcadas, cada uma que você tiver é oferecida."
L["BUFF_DUTY_SELF_ENABLE"] = "Seus buffs próprios"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Mostra no topo da janela os buffs que só você pode lançar em si mesmo, como uma armadura ou Fogo Interior, quando estão faltando ou acabando. Escolha quais em Buffs próprios."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Seus buffs de arma"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Mostra os venenos, imbuições, óleos, pedras e iscas que estão faltando ou acabando nas suas armas, junto com seus buffs próprios no topo da janela. Clique em um para aplicá-lo. Escolha quais em Buffs de arma."

-- The window itself
L["BUFF_DUTY_SELF_HEADER"] = "Buffs próprios"
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "Buffs próprios faltando"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "Buffs de grupo faltando"
L["BUFF_DUTY_FAVOR_HEADER"] = "Retribuir o favor"
L["BUFF_DUTY_TARGET_HEADER"] = "Alvo"
L["BUFF_DUTY_TOOLTIP_CAST"] = "Clique para lançar em %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Clique para aplicar na sua arma (%s)."
L["BUFF_DUTY_TOOLTIP_USE"] = "Ninguém no seu grupo tem uma Pedra da Alma. Clique para usar uma em %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Ninguém no seu grupo tem uma Pedra da Alma. Clique para criar uma."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Clique para lançar em %s e no grupo dele."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Clique para selecionar %s como alvo e lançar."
L["BUFF_DUTY_TOOLTIP_DISMISS"] = "Clique com o botão direito para tirar %s da lista."
-- A Party-Buffs icon's tooltip: a raid buff your group is missing, and its count.
L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"] = "Faltando ou acabando: %d"
-- A Party-Buffs icon's clicks, beside Left-Click and Right-Click: one asks the party or raid, the other whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_GROUP"] = "Pedir bônus ao grupo"
L["BUFF_DUTY_OTHERS_TOOLTIP_ASK_WHISPER"] = "Pedir bônus diretamente"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s está sem %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s estão sem %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d pessoas estão sem o buff %s."
-- Your own chat, after a Right-Click: who was whispered, then the buff's link.
L["BUFF_DUTY_OTHERS_SENT"] = "Sussurrado para %s sobre %s."
-- The window's close button: the class name in its color, then the options command.
L["BUFF_DUTY_CLOSED"] =
	"O Plantão de buffs está desativado para a classe %s. Para reativá-lo, use Shift + clique esquerdo no botão do minimapa ou digite %s."

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEY"] = "Botão de buff"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Esperando %s chegar ao alcance."
L["BUFF_KEY_DONE"] = "Nada mais para buffar."
L["BUFF_KEY_OFF"] = "O Plantão de buffs está desativado."

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "Botão de agradecimento"
L["BUTTON_DESCRIPTION"] =
	"Sussurre e faça uma expressão para o seu alvo com uma única tecla. Gentileza, automatizada."
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "Botão de agradecimento %d"
L["BUTTON_EMOTE"] = "Expressão"
L["BUTTON_EMOTE_DESCRIPTION"] =
	"Define a expressão que este botão faz para o seu alvo, ou Nenhuma para não fazer expressão."
L["BUTTON_EMOTE_NONE"] = "Nenhuma"
L["BUTTON_ICON"] = "Ícone"
L["BUTTON_ICON_DESCRIPTION"] =
	"Define o ícone que a macro deste botão mostra na sua lista de macros e nas suas barras de ação."
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "Padrão"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = 'Ativar a macro "%s"'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] = "Cria uma macro chamada %s e a apaga quando você desativa esta opção."
L["BUTTON_WHISPER_DESCRIPTION"] =
	"Define o que este botão sussurra para o seu alvo. Deixe em branco para não enviar sussurro."

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "Valeu, você é demais! (="
--[[
    The star marker (left off on WoW Forever) and " // GtG" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "Você tem %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "Você torce por <Target>."
L["EMOTE_DRINK_DESCRIPTION"] = "Você ergue um brinde a <Target>."
L["EMOTE_FLEX_DESCRIPTION"] = "Você exibe seus músculos para <Target>."
L["EMOTE_GRIN_DESCRIPTION"] = "Você dá um sorriso malicioso para <Target>."
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "Você dá um toca-aqui em <Target>."
L["EMOTE_PRAISE_DESCRIPTION"] = "Você elogia <Target>."
L["EMOTE_SALUTE_DESCRIPTION"] = "Você saúda <Target> com respeito."
L["EMOTE_SMILE_DESCRIPTION"] = "Você sorri para <Target>."
L["EMOTE_THANK_DESCRIPTION"] = "Você agradece a <Target>."
L["EMOTE_WHOA_DESCRIPTION"] = "Você exclama 'Uau!' para <Target>."
L["EMOTE_WINK_DESCRIPTION"] = "Você pisca para <Target>."
L["EMOTE_YES_DESCRIPTION"] = "Você acena com a cabeça para <Target>."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- the window's first tab and its title before "// Good to Go"

-- Page: Sections
L["SECTION_UNLEARNED"] = "Não aprendidos"
L["SECTION_CONSUMABLES"] = "Consumíveis do GtG"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Texto da macro"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Grau dinâmico"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"O grau dinâmico, baseado no nível de um jogador amistoso, só é atualizado fora de combate."
L["MENU_CAST_AT_CURSOR"] = "Lançar no cursor"
L["MENU_TARGET_NEAREST_ENEMY"] = "Selecionar o inimigo mais próximo"
L["MENU_TARGET_NEAREST_FRIEND"] = "Selecionar o aliado mais próximo"
L["MENU_CAST_IF_SUMMONED"] = "Lançar %s se invocado"
L["MENU_NEVER_TURN_OFF"] = "Nunca desativar"
L["MENU_LEAVE_FORM_BEFORE"] = "Sair da forma antes de lançar"
L["MENU_RIGHT_CLICK_FOR"] = "Clique direito para %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Clique direito para versão de grupo"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "Aplicar a todos: %s"
L["MENU_ONCE_PER_COMBAT"] = "Lançar uma vez por combate"
L["MENU_ONCE_PER_TARGET"] = "Lançar uma vez por alvo"
L["MENU_HIDE_ERRORS"] = "Ocultar mensagens de erro"
L["MENU_MUTE_ERRORS"] = "Silenciar sons de erro"
L["MENU_SWITCH_TO"] = "Mudar para %s"
L["MENU_START_AUTO_ATTACK"] = "Iniciar ataque automático"
L["MENU_STOP_ATTACK"] = "Parar ataque"
L["MENU_START_AUTO_SHOT"] = "Iniciar disparo automático"
L["MENU_START_PET_ATTACK"] = "Iniciar ataque do ajudante"
L["MENU_START_WAND"] = "Iniciar varinha"
L["MENU_STOP_CASTING"] = "Parar lançamento"
L["MENU_STOP_CASTING_NOTE"] =
	"Use Parar lançamento em feitiços que não podem esperar, como interrupções e dissipações."
L["MENU_STOP_IF_CHANNELING"] = "Parar macro se canalizando"
L["MENU_STOP_IF_STEALTHED"] = "Parar macro se em furtividade"
L["MENU_DUPLICATE"] = "Duplicar"
L["MENU_DELETE"] = "Excluir"
L["MENU_DELETE_USED_ONE"] = "Excluir (usada em 1 barra)"
L["MENU_DELETE_USED"] = "Excluir (usada em %d barras)"
L["MENU_DELETE_DESCRIPTION"] =
	"Exclui esta macro das suas macros, o que a tira das suas barras de ação, e redefine todas as opções dela. Clique nela ou arraste-a na página para criá-la de novo."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Tira esta cópia da página e a exclui das suas macros, o que a tira das suas barras de ação."
L["MENU_DELETE_CONFIRM"] = "Excluir %s? Ela sai das suas barras de ação, e as opções dela são redefinidas."
L["MENU_GROUP_RANK"] = "Grau"
L["MENU_GROUP_WHEN"] = "Quando"
L["MENU_GROUP_FIRST"] = "Primeiro"
L["MENU_GROUP_THEN"] = "Depois"
L["MENU_GROUP_ERRORS"] = "Mensagens de erro"
L["MENU_GROUP_GROUPED"] = "Feitiços agrupados"
L["MENU_GROUP_TARGET"] = "Alvo"
L["MENU_PRIORITY_1"] = "Primeira prioridade"
L["MENU_PRIORITY_2"] = "Segunda prioridade"
L["MENU_PRIORITY_3"] = "Terceira prioridade"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Quem a macro tenta, em ordem. Cada um é ignorado quando não pode receber o feitiço e, quando nenhum pode, ela lança como o feitiço normal lançaria."
L["MENU_UNIT_NONE"] = "Nenhum"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Encerra a lista aqui."
L["MENU_UNIT_TARGET"] = "Alvo"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Lança no seu alvo, quando ele pode receber o feitiço."
L["MENU_UNIT_SELF"] = "Você mesmo"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"Lança em você. Você sempre pode recebê-lo, então nada depois de Você mesmo é tentado."
L["MENU_UNIT_PET"] = "Ajudante"
L["MENU_UNIT_PET_DESCRIPTION"] = "Lança no seu ajudante, quando ele está invocado e pode receber o feitiço."
L["MENU_UNIT_FOCUS"] = "Foco"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "Lança no seu foco, quando você tem um e ele pode receber o feitiço."
L["MENU_UNIT_TARGETS_TARGET"] = "Alvo do alvo"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Lança no alvo do seu alvo, como o tanque que o inimigo selecionado está atacando, quando ele pode receber o feitiço."
L["MENU_UNIT_MOUSEOVER"] = "Sob o mouse"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Lança em quem estiver sob o cursor, no mundo ou em um quadro de unidade, quando puder receber o feitiço."
L["MENU_OPTIONS_COUNT"] = "%d opções"
L["MENU_ENABLED"] = "Ativado"
L["MENU_HIGHEST"] = "Mais alto"
L["MENU_HIGHEST_DESCRIPTION"] = "Lança o grau mais alto que você conhece."
L["MENU_RANK_DYNAMIC"] = "Dinâmico"
L["MENU_FIXED_RANK_DESCRIPTION"] = "Sempre lança %s, em qualquer nível."
L["MENU_ANY_TIME"] = "A qualquer momento"
L["MENU_ANY_TIME_DESCRIPTION"] = "Lança dentro ou fora de combate."
L["MENU_IN_COMBAT"] = "Em combate"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"Lança só em combate. Fora de combate a macro não faz nada, incluindo os itens dela."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"Lança só fora de combate. Em combate a macro não faz nada, incluindo os itens dela."
L["MENU_EVERY_PRESS"] = "Toda vez"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Lança toda vez que você aperta a macro."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "Um clique direito lança %s. Um clique esquerdo ainda lança %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Permite que a macro lance %s. Dos feitiços marcados aqui, ela lança o último que você aprendeu, então evolui conforme você treina."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] =
	"Ainda não aprendido. Marque agora e a macro passa a usá-lo quando você o aprender."
L["MENU_PET_DESCRIPTION"] = "Com %s em campo, a macro lança %s em vez de invocar de novo."
L["MENU_STANCE_DESCRIPTION"] = "Muda para %s primeiro, a menos que já esteja em uso."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Usa o item antes do lançamento. Os itens são usados na ordem em que você os marca, e o número depois de cada um mostra a posição dele."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Usar %s"
L["MENU_ADD_FOCUS"] = "Adicionar cópia de foco"
L["MENU_REMOVE_FOCUS"] = "Remover cópia de foco"
L["MENU_FOCUS_DESCRIPTION"] = "Adiciona à página uma segunda macro que lança no seu foco e depois no seu alvo."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Adiciona outra cópia desta macro à página, começando com estas opções, para que você possa configurá-la de outro jeito."
L["MENU_MAKE_DEFAULT"] = "Tornar padrão para %s"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"Toda macro em %s que você não configurou por conta própria começa com as opções desta macro."
L["MENU_DEFAULT_SET"] = "%s agora começam com estas opções."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Condicionais"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Abre o painel Condicionais ao lado do Grimório, onde a macro pode lançar outro feitiço quando uma condição é atendida, como Shift pressionado ou Especialização 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "Uma condicional usa o clique direito. Remova-a para ativar isto."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Condicionais"
L["CONDITIONALS_HINT"] = "Verificadas de cima para baixo; a primeira que corresponder é lançada."
L["CONDITIONALS_OTHERWISE"] = "Caso contrário"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "e"
L["CONDITIONALS_AND_MENU"] = "Adicionar segunda condição"
L["CONDITIONALS_AND_DESCRIPTION"] = "Adiciona uma segunda condição. A linha só lança quando ambas são atendidas."
L["CONDITIONALS_DROP_SECOND"] = "Remover esta condição"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "A linha volta a verificar só a primeira condição."
L["CONDITIONALS_ADD"] = "+ Adicionar condição"
L["CONDITIONALS_ADD_DESCRIPTION"] =
	"Adiciona uma linha no final. Escolha a condição dela e depois o feitiço que ela lança."
L["CONDITIONALS_ADD_LIMIT"] = "Até %d linhas. Cada uma aumenta o texto da macro, que comporta 255 bytes."
L["CONDITIONALS_PICK_SPELL"] = "Escolher um feitiço"
L["CONDITIONALS_PICKING"] = "Clique em um feitiço na página"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Clique aqui e depois em um feitiço na página para lançá-lo nesta linha. Ou arraste um feitiço da página para este espaço."
L["CONDITIONALS_PICK_BANNER"] = "Clique em um feitiço para usá-lo. Esc ou clique direito cancela."
L["CONDITIONALS_CANNOT_PICK"] = "Só um feitiço aprendido pode ser lançado por uma condicional."
L["CONDITIONALS_EMPTY"] =
	"Nenhuma condição ainda. Adicione uma para lançar outro feitiço enquanto Shift estiver pressionado, em combate e mais."
L["CONDITIONALS_SHADOWED"] =
	"Nunca lança: a linha %d acima corresponde sempre que esta corresponde, e lança primeiro."
L["CONDITIONALS_KEY_DRAG"] = "Arraste um feitiço para cá"
L["CONDITIONALS_ACTION_DROP"] = "Lançar nesta linha"
L["CONDITIONALS_ACTION_PICK"] = "Escolher na página"
L["CONDITIONALS_ACTION_USE"] = "Usar em condicional"
L["CONDITIONALS_ACTION_CANCEL"] = "Cancelar escolha"
L["CONDITIONALS_REMOVE"] = "Remover"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Remove esta linha."
L["CONDITIONALS_REORDER"] = "Reordenar"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Arraste para outra linha para movê-la para lá. A primeira linha que corresponder é lançada."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Shift pressionado"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "Corresponde quando você segura Shift ao apertar a macro."
L["CONDITION_CTRL"] = "Ctrl pressionado"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "Corresponde quando você segura Ctrl ao apertar a macro."
L["CONDITION_ALT"] = "Alt pressionado"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Corresponde quando você segura Alt ao apertar a macro."
L["CONDITION_RIGHT_CLICK"] = "Clique direito"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] =
	"Corresponde quando você clica com o botão direito na macro na sua barra de ação."
L["CONDITION_IN_COMBAT"] = "Em combate"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Corresponde enquanto você está em combate."
L["CONDITION_OUT_OF_COMBAT"] = "Fora de combate"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Corresponde enquanto você está fora de combate."
L["CONDITION_SPEC_1"] = "Especialização 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Corresponde enquanto sua primeira especialização de talentos está ativa."
L["CONDITION_SPEC_2"] = "Especialização 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Corresponde enquanto sua segunda especialização de talentos está ativa."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (atual)"
L["CONDITION_COMBAT_BLOCKED"] =
	"Indisponível enquanto Quando estiver definido como Em combate ou Fora de combate. A macro já não faz nada na outra situação, então isto sempre corresponderia, ou nunca."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"Indisponível enquanto Feitiços agrupados estiver com Clique direito para %s ativado, que já ocupa o clique direito. Desative isso para usar o clique direito aqui."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 condicional"
L["SUBTEXT_CONDITIONALS"] = "%d condicionais"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Sequência de lançamento"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Abre o painel Sequência de lançamento ao lado do Grimório, onde cada clique na macro lança o próximo feitiço em ordem, como Corrupção, depois Maldição da Agonia, depois Imolar."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d etapas"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Sequência de lançamento"
L["CAST_SEQUENCE_HINT"] =
	"Cada clique lança a próxima etapa. Uma etapa que falha é tentada de novo no clique seguinte."
L["CAST_SEQUENCE_FIRST"] = "Primeiro"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "O feitiço da própria macro sempre vem primeiro."
L["CAST_SEQUENCE_ADD"] = "+ Adicionar etapa"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Adiciona uma etapa no final. Depois escolha o feitiço que ela lança."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Até %d etapas depois do feitiço da macro. Cada uma aumenta o texto da macro, que comporta 255 bytes."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"Só um feitiço aprendido, e não Atirar, pode ser uma etapa de uma sequência de lançamento."
L["CAST_SEQUENCE_ACTION_DROP"] = "Lançar nesta etapa"
L["CAST_SEQUENCE_ACTION_USE"] = "Usar na sequência de lançamento"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Remove esta etapa."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Arraste para outra etapa para movê-la para lá."
L["CAST_SEQUENCE_END"] = "Depois da última etapa"
L["CAST_SEQUENCE_END_LOOP"] = "Recomeçar"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"O próximo clique lança de novo o feitiço da própria macro, e a sequência recomeça."
L["CAST_SEQUENCE_END_STOP"] = "Parar (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Termina em NULL, um feitiço que ninguém conhece, então os próximos cliques não lançam nada até que uma redefinição recomece a sequência."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Parar"
L["CAST_SEQUENCE_RESET"] = "Recomeçar quando"
L["CAST_SEQUENCE_RESET_NEVER"] = "Nunca"
L["CAST_SEQUENCE_RESET_TARGET"] = "Mudança de alvo"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "Recomeça a sequência na primeira etapa quando você muda de alvo."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Fim do combate"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] = "Recomeça a sequência na primeira etapa quando você sai de combate."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Shift pressionado"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl pressionado"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt pressionado"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Apertar a macro com esta tecla pressionada recomeça a sequência, lançando a primeira etapa."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Segundos sem uso"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Recomeça a sequência quando a macro não é apertada por esse tempo."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Desativado"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d segundos sem uso"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"Para de vez: sem nada para recomeçá-la, a sequência fica em NULL até a macro mudar ou você recarregar a interface. Escolha uma redefinição em Recomeçar quando."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	"Fica em espera enquanto Lançar se invocado lança %s, que escreve uma linha de lançamento própria. Desative isso para usar a sequência."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "Sequência de %d etapas"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Mostrar todos os graus dos feitiços"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Mostrar feitiços agrupados"
L["SETTINGS_SHOW_UNLEARNED"] = "Mostrar feitiços não aprendidos"
L["SETTINGS_MARK_ALL_PLACED"] = "Marcar todos os feitiços como colocados"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Nenhuma macro desta página brilha mais, esteja ou não nas suas barras. Um feitiço que você aprender depois continua brilhando até ser colocado."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "Destacar feitiços não colocados"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	"Faz brilhar toda macro que não está nas suas barras. Desative para marcar todas como colocadas, como o botão Marcar todos os feitiços como colocados."
L["SORT_BY_CATEGORY"] = "Ordenar por categoria"
L["SORT_BY_SCHOOL"] = "Ordenar por escola"
L["SORT_DESCRIPTION"] =
	"Agrupa as macros da página por categoria, a função de cada feitiço, como Ataques, Curas ou Recargas defensivas, ou por escola, as abas do grimório de onde eles vêm."
L["CATEGORY_ATTACKS"] = "Ataques"
L["CATEGORY_FINISHERS"] = "Finalizadores"
L["CATEGORY_CROWD_CONTROL"] = "Controle de multidão"
L["CATEGORY_HYBRID"] = "Híbridos"
L["CATEGORY_HEALS"] = "Curas"
L["CATEGORY_BUFFS"] = "Bônus"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Recargas ofensivas"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Recargas defensivas"
L["CATEGORY_SELF_BUFFS"] = "Bônus próprios"
L["CATEGORY_SHOCKS"] = "Choques"
L["CATEGORY_TRAPS"] = "Armadilhas"
L["CATEGORY_TOTEMS"] = "Totens"
L["CATEGORY_SEALS"] = "Selos"
L["CATEGORY_BLESSINGS"] = "Bênçãos"
L["CATEGORY_CURSES"] = "Maldições"
L["CATEGORY_PETS"] = "Ajudantes"
L["CATEGORY_TELEPORTS"] = "Teleportes e portais"
L["CATEGORY_UTILITY"] = "Utilidade"
L["CATEGORY_THREAT"] = "Provocações e ameaça"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Ataques básicos"
L["CATEGORY_STANCES"] = "Posturas"
L["CATEGORY_FORMS"] = "Formas"
L["CATEGORY_AURAS"] = "Auras"
L["CATEGORY_ASPECTS"] = "Aspectos"
L["CATEGORY_RACIALS"] = "Raciais"
L["CATEGORY_TRACKING"] = "Rastreamento"
L["CATEGORY_PROFESSIONS"] = "Profissões"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Foco"
L["SUBTEXT_PET"] = "Ajudante"
L["SUBTEXT_CURSOR"] = "No cursor"
L["SUBTEXT_STANCE"] = "Postura"
L["SUBTEXT_USE_ITEMS"] = "Usar itens"
L["SUBTEXT_PET_ATTACK"] = "Ataque ajudante"
L["SUBTEXT_DYNAMIC_RANK"] = "Grau dinâm."
L["SUBTEXT_DYNAMIC_ITEM"] = "Item dinâm."
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Grau dinâm., Item dinâm."
L["SUBTEXT_MAX_RANK"] = "Grau máximo"
L["SUBTEXT_TARGET_ENEMY"] = "Inimigo próximo"
L["SUBTEXT_TARGET_FRIEND"] = "Aliado próximo"
L["SUBTEXT_TARGET_PRIORITY"] = "Alvo"
L["SUBTEXT_GROUPED_SPELLS"] = "Agrupado"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1 por combate"
L["SUBTEXT_ONCE_PER_TARGET"] = "1 por alvo"
L["SUBTEXT_COMBAT_ONLY"] = "Só em combate"
L["SUBTEXT_NO_COMBAT"] = "Fora de combate"
L["SUBTEXT_LEAVE_FORM"] = "Sai da forma"
L["SUBTEXT_NO_TOGGLE"] = "Fica ativo"
L["SUBTEXT_WAND"] = "Varinha"
L["SUBTEXT_START_ATTACK"] = "Ataque auto."
L["SUBTEXT_STOP_ATTACK"] = "Para ataque"
L["SUBTEXT_STOP_CASTING"] = "Para lançam."
L["SUBTEXT_STOP_IF_CHANNELING"] = "Não ao canalizar"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Não em furtividade"
L["SUBTEXT_HIDE_ERRORS"] = "Sem erros"
L["SUBTEXT_MUTE_ERRORS"] = "Erros mudos"
L["SUBTEXT_OPTIONS_COUNT"] = "%d opções"
L["SUBTEXT_TOO_LONG"] = "Muito longa"
L["SUBTEXT_LEARN_LEVEL"] = "Nível %d"
L["SUBTEXT_TALENT"] = "Talento"
L["SUBTEXT_LEARN_RANK"] = "Aprender %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Ensinar ao ajudante"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Ainda não aprendido"
L["TOOLTIP_LEARN_LEVEL"] = "Seu instrutor de classe ensina no nível %d."
L["TOOLTIP_LEARN_TALENT"] = "Aprendido pelos seus talentos."
L["TOOLTIP_NOT_ON_BARS"] = "Não está nas suas barras de ação"
L["TOOLTIP_TOO_LONG"] = "Longa demais: %d / %d bytes. Desative uma opção para encurtá-la."
L["TOOLTIP_OPTIONS_ON"] = "Opções ativadas: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clicar ou arrastar"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Colocar nas suas barras de ação"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clique direito"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Opções da macro"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Clique do meio"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Redefinir opções da macro"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Redefinir todas as macros em %s"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s voltou às opções padrão."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Todas as macros em %s voltaram às opções padrão."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Descarta as opções que você definiu em cada feitiço daqui, para que todos voltem a seguir os padrões. Cópias de foco e duplicatas permanecem."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Redefinir as opções que você definiu em todos os feitiços de %s? Cada um volta a seguir os padrões."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "Macro de %s"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Os feitiços da sua classe como macros de um clique."
L["TOOLTIP_KEY_CLICK"] = "Clicar"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Abrir Grimório Aprimorado"

-- Page: Layout
L["PAGE_EMPTY"] = "Ainda não há macros. Visite seu instrutor de classe para aprender seus primeiros feitiços."
L["PAGE_NO_MATCHES"] = "Nenhuma macro corresponde ao filtro."
L["PAGE_FILTER"] = "Filtrar feitiços"
L["FILTER_ALL_SCHOOLS"] = "Todas as escolas"
L["FILTER_ALL_CATEGORIES"] = "Todas as categorias"
L["PAGE_MACRO_SLOTS"] = "Espaços de macro"
L["TOOLTIP_MACRO_SLOTS"] =
	"Cada macro que você coloca ocupa um espaço de macro. Os espaços de personagem são deste personagem e são preenchidos primeiro. Os espaços gerais são compartilhados por todos os personagens da sua conta."
L["PAGE_MACRO_GENERAL"] = "Gerais"
L["PAGE_MACRO_CHARACTER"] = "Personagem"
L["PAGE_NO_MATCHES_FOR"] = 'Nenhum feitiço corresponde a "%s".'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Settings for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "Configurações para os %d feitiços de %s"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Ativa ou desativa uma opção para todos os feitiços desta categoria de uma vez. Feitiços que ainda não estão nas suas barras guardam a configuração para quando você os colocar."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(continuação)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "Próximos Passos"
L["WHATS_NEXT_EMPTY"] = "Nenhum feitiço para listar."
L["WHATS_NEXT_ALL_SOURCES"] = "Todas as origens"
L["WHATS_NEXT_ANY_LEVEL"] = "Qualquer nível"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Disponível agora"
L["WHATS_NEXT_STATUS_SOON"] = "Em breve"
L["WHATS_NEXT_STATUS_LATER"] = "Ainda indisponível"
L["WHATS_NEXT_STATUS_MISSING"] = "Requisitos pendentes"
L["WHATS_NEXT_STATUS_TALENT"] = "Talentos não escolhidos"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Talentos e runas não escolhidos"
L["WHATS_NEXT_STATUS_KNOWN"] = "Conhecidos"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Disponível agora"
L["WHATS_NEXT_SHORT_SOON"] = "Em breve"
L["WHATS_NEXT_SHORT_LATER"] = "Ainda não"
L["WHATS_NEXT_SHORT_MISSING"] = "Requer outro feitiço"
L["WHATS_NEXT_SHORT_TALENT"] = "Não escolhido"
L["WHATS_NEXT_SHORT_KNOWN"] = "Conhecido"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Feitiço inicial"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Instrutor"
L["WHATS_NEXT_SOURCE_BOOK"] = "Livro"
L["WHATS_NEXT_SOURCE_QUEST"] = "Missão"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talento"
L["WHATS_NEXT_SOURCE_RUNE"] = "Runa"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Aprendido com"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Nível necessário"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Sua classe já começa com ele."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Seu instrutor de classe o ensina."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "Um item o ensina, como um livro de uma masmorra ou raide."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "Uma missão de classe o ensina. Seu instrutor de classe pode indicar o caminho."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Gaste um ponto de talento nele para aprendê-lo."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Grave a runa dele para aprendê-lo."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Aprenda %s primeiro."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "Graus de %s"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + clique"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Mostrar link no chat"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Ordenar por disponibilidade"
L["WHATS_NEXT_SORT_LEVEL"] = "Ordenar por nível"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Ordenar por disponibilidade lista primeiro os feitiços que você pode aprender agora e por último os que você já conhece. Ordenar por nível lista cada feitiço sob o nível em que ele é aprendido."
L["WHATS_NEXT_SHOW_KNOWN"] = "Mostrar feitiços conhecidos"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Também lista os feitiços que você já aprendeu, depois dos demais."
L["WHATS_NEXT_SHOW_TALENTS"] = "Mostrar talentos não escolhidos"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Mostrar talentos e runas não escolhidos"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Também lista os feitiços de talento que você não escolheu. Eles são aprendidos gastando pontos de talento, não com um instrutor."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Grimório do Ajudante"
L["PET_SPELLBOOK_EMPTY"] = "Seu ajudante não tem feitiços para listar."
L["PET_SPELLBOOK_NO_PET"] = "Nenhum ajudante invocado. Invoque seu ajudante para ver os feitiços dele."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Habilidades"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Passivas"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Automático ativado"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Automático desativado"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Próximos Passos do Ajudante"
L["WHATS_NEXT_PET_EMPTY"] = "Nenhuma habilidade de ajudante para listar."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: %1$s is the pet's name, %2$d its level, %3$s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%1$s, nível %2$d, %3$s"
-- TRANSLATORS: %1$d is the training points the pet has left, %2$d its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Pontos de treinamento: %1$d de %2$d"
L["WHATS_NEXT_PET_NO_PET"] = "Nenhum ajudante invocado: mostrando o que você aprendeu com Treinamento de Feras."
L["WHATS_NEXT_PET_NO_DEMON"] = "Nenhum demônio invocado: invoque um para ver o que ele já conhece."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Pronto para ensinar"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Habilidades de outras famílias"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Pronto para ensinar"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Outra família"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Instrutor de ajudantes"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Domesticação"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Instrutor de demônios"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Nível de ajudante necessário"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Pontos de treinamento"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"Um instrutor de ajudantes a ensina a você. Depois ensine-a ao seu ajudante com Treinamento de Feras."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Domestique uma fera que a conheça e lute ao lado dela até aprendê-la. Depois ensine-a a qualquer ajudante que possa aprendê-la com Treinamento de Feras."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "Você a conhece. Ensine-a ao seu ajudante com Treinamento de Feras."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Compre o grimório dela com um instrutor de demônios e use-o enquanto o demônio que a aprende estiver invocado."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimório"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"O grimório dela está nas suas bolsas. Use-o enquanto este demônio estiver invocado."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Seu ajudante não pode aprendê-la."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Feras que a conhecem"
-- TRANSLATORS: %1$s is a beast's name, %2$s its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%1$s (%2$s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "E mais %d."

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Ordenar por disponibilidade lista primeiro as habilidades que seu ajudante pode aprender agora e por último as que ele já conhece. Ordenar por nível lista cada habilidade sob o nível de ajudante que ela exige."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Mostrar habilidades conhecidas"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Também lista as habilidades que seu ajudante já conhece, depois das demais. Um caçador sem ajudante invocado vê as que ele mesmo aprendeu."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Mostrar habilidades de outras famílias"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Também lista as habilidades que seu ajudante não pode aprender, como Espreitar de um felino para um lobo, ou as de outro demônio."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Teclas de atalho"
L["OPTIONS_KEY_SET"] = "Definir tecla"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Abre a lista de teclas de atalho do jogo, onde o Good to Go tem sua própria seção."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Abre e fecha o Grimório Aprimorado. Ele também tem sua própria aba no seu grimório."
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Lança o próximo buff que a janela do Plantão de buffs oferece, um por clique, fora de combate. Buffs de arma continuam sendo um clique na janela. Para acioná-lo a partir de uma macro, use %s."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Dicas de habilidade dos Próximos Passos"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"A dica de cada habilidade lista seus graus e o nível que cada um exige: verde para os graus que você conhece, vermelho para os que você poderia treinar agora mas não treinou, e amarelo para os que ainda virão. É uma checagem rápida de que você está sempre usando seu melhor grau, para jogar sempre no seu melhor. Os graus não aparecem durante o combate, para que suas dicas fiquem curtas quando mais importa."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Ativar dicas de habilidade dos Próximos Passos"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Adiciona os graus de cada habilidade à dica dela nas suas barras de ação, no grimório do jogo e em outros addons. Desativado, essas dicas ficam como o jogo as mostra. A própria janela do Grimório Aprimorado mostra os graus de qualquer forma."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Excluir macros"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Exclui as macros que o Grimório Aprimorado criou, o que também as tira das suas barras de ação. Suas próprias macros nunca são tocadas, e a página recria qualquer uma delas quando você clica nela ou a arrasta."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Excluir macros do personagem"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Exclui as macros do Grimório Aprimorado da aba de macros deste personagem. Seus outros personagens mantêm as deles até você fazer o mesmo neles."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Excluir todas as macros do Grimório Aprimorado deste personagem? Elas também saem das suas barras de ação."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Excluir macros gerais"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Exclui as macros do Grimório Aprimorado da aba Macros gerais, compartilhada por todos os personagens da sua conta, então seus outros personagens também perdem as deles ali."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Excluir todas as macros gerais do Grimório Aprimorado? Todos os personagens da sua conta as perdem, e elas também saem das suas barras de ação."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Lista uma macro para cada grau inferior que você conhece de um feitiço, depois da macro do próprio feitiço, cada uma sempre lançando o seu grau."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Lista todos os feitiços que você conhece de um grupo de feitiços, como Purificar e Purificação. Desativado, só o último aprendido é listado, embora as macros dos outros continuem se atualizando."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Lista os feitiços de classe que você ainda não aprendeu numa seção Não aprendidos, para você colocar as macros deles antes."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Posiciona o feitiço onde o cursor aponta, sem círculo de mira."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lança o grau mais alto que o nível do jogador amistoso permite."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Para primeiro o que você estiver lançando, para que este feitiço saia na hora."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Para primeiro seu ataque automático corpo a corpo."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Não faz nada enquanto você canaliza um feitiço, então apertar nunca interrompe a canalização."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Não faz nada enquanto você está em furtividade, então apertar nunca interrompe Furtividade ou Espreitar."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "Sai primeiro da sua forma atual, para que o feitiço possa ser lançado."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Seleciona primeiro o inimigo mais próximo quando você não tem nenhum inimigo vivo como alvo."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Seleciona primeiro o aliado mais próximo quando você não tem nenhum aliado vivo como alvo."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Manda também seu ajudante atacar o seu alvo."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Inicia seu ataque automático corpo a corpo depois do lançamento."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Inicia Disparo Automático ou sua varinha depois do lançamento."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lança uma vez e não de novo até seu alvo mudar."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lança uma vez e não de novo até o combate acabar ou seu alvo mudar."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Mantém a forma ou o aspecto ativo quando você aperta a macro de novo, em vez de desativá-lo."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Limpa o texto de erro vermelho que a macro deixa na tela."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Silencia o som de erro enquanto a macro é executada."
L["KIND_ENEMY"] = "Feitiços contra inimigos"
L["KIND_ENEMY_DESCRIPTION"] = "Feitiços lançados em um inimigo, como ataques e penalidades."
L["KIND_FRIENDLY"] = "Feitiços amistosos"
L["KIND_FRIENDLY_DESCRIPTION"] = "Feitiços lançados em um aliado, como curas."
L["KIND_BUFF"] = "Bônus"
L["KIND_BUFF_DESCRIPTION"] = "Feitiços que dão a um aliado um bônus duradouro."
L["KIND_RESURRECT"] = "Ressurreições"
L["KIND_RESURRECT_DESCRIPTION"] = "Feitiços que você lança em um aliado morto para trazê-lo de volta."
L["KIND_ANYONE"] = "Feitiços para aliado ou inimigo"
L["KIND_ANYONE_DESCRIPTION"] = "Feitiços que podem ser lançados em um aliado ou em um inimigo."
L["KIND_GROUND"] = "Feitiços no chão"
L["KIND_GROUND_DESCRIPTION"] = "Feitiços que você posiciona no chão."
L["KIND_FORM"] = "Formas, posturas e aspectos"
L["KIND_FORM_DESCRIPTION"] = "Feitiços que ficam ativos até você desligá-los ou trocar por outro."
L["KIND_SELF"] = "Feitiços pessoais e de área"
L["KIND_SELF_DESCRIPTION"] = "Feitiços sem alvo, lançados em você ou ao seu redor."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Mostrar/ocultar Grimório Aprimorado"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "Por segurança, a lista de teclas de atalho não pode ser aberta durante o combate."
L["KEY_BINDINGS_LOCATION"] = "Abra o menu do jogo, depois %s, depois %s, e procure a seção Good to Go."
L["ERROR_MACRO_SLOTS_FULL"] = "Não há espaços de macro livres. Apague uma macro em /macro para abrir espaço."
L["CHAT_MACROS_DELETED"] = "Macros excluídas: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'A macro "%s" tem %d bytes com as opções ativadas, acima dos %d que cabem em uma macro. Desative uma opção para encurtá-la.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'A macro "%s" tem %d bytes, acima dos %d que cabem em uma macro, então a última linha dela é cortada.'
