local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "koKR")
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
	"버전 %s. 설정(이 메시지 비활성화 옵션 포함)은 설정 > 애드온 > Good to Go에 있습니다. 이 애드온이 마음에 드시나요? 친구에게 알려 주거나, CurseForge에서 즐겨찾기에 추가하거나, GitHub에서 스타를 눌러 주세요. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Good to Go의 레벨 업을 도와주세요"
L["OPTIONS_LEVEL_UP_THANKS"] = "Good to Go를 선택해 주셔서 감사합니다!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- 붕대"
L["MACRO_EXPLOSIVES"] = "- 폭발물"
L["MACRO_FEED_PET"] = "- 먹이 주기"
L["MACRO_FOOD"] = "- 음식"
L["MACRO_HEALTH_POTION"] = "- 치유 물약"
L["MACRO_HEALTHSTONE"] = "- 생명석"
L["MACRO_MANA_GEM"] = "- 마나 보석"
L["MACRO_MANA_POTION"] = "- 마나 물약"
L["MACRO_POISONS"] = "- 독"
L["MACRO_SOULSTONE"] = "- 영혼석"
L["MACRO_WATER"] = "- 물"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s, %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s, %s"
-- A name with a detail after it: a Spellbook note and its settings ("Target (Mouseover, Self)"), or a pet and its owner.
L["NAME_WITH_DETAIL_FORMAT"] = "%s (%s)"
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = "."

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

L["DIET_BREAD"] = "빵"
L["DIET_CHEESE"] = "치즈"
L["DIET_FISH"] = "생선"
L["DIET_FRUIT"] = "과일"
L["DIET_FUNGUS"] = "버섯"
L["DIET_MEAT"] = "고기"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"버그를 발견한 것 같습니다! %s (%s) 아이템은 %s > %s (%s)에서 사용할 수 없습니다. 수정할 수 있도록 제보해 주세요. 감사합니다! %s"
L["MESSAGE_NO_ITEM"] = "가방에서 적합한 %s 아이템을 찾지 못했습니다."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"매크로 칸이 가득 차서 일부 Good to Go 매크로를 만들지 못했습니다. 더 이상 쓰지 않는 매크로를 삭제해 칸을 비우거나, 설정 > 애드온 > Good to Go > 소모품 매크로에서 필요 없는 Good to Go 매크로를 끄세요."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"매크로가 준비되었습니다. %s 명령어를 입력하고 %s 탭을 연 다음, - 음식, - 물 등의 매크로를 행동 단축바로 끌어다 놓으세요."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s 아이템이 이 캐릭터의 차단 목록에 추가되었습니다."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "이 캐릭터의 차단 목록에서 아이템 1개를 제거했습니다."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "이 캐릭터의 차단 목록에서 아이템 %d개를 제거했습니다."

L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 인터페이스를 열 수 없습니다."

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

L["READINESS_TITLE"] = "준비 보고서"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "부족한 버프:"
L["READINESS_EXPIRING"] = "곧 만료:"
L["READINESS_MISSING_ITEMS"] = "부족한 아이템:"
L["READINESS_DAMAGED_GEAR"] = "손상된 장비:"
L["READINESS_CHARACTER"] = "캐릭터:"
L["READINESS_QUESTIONABLE_GEAR"] = "비전투용 장비 착용:"

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
L["READINESS_FLASK"] = "영약 또는 비약 2종"
L["READINESS_PET_FORMAT"] = "%s (소환수)"
L["READINESS_SCROLLS"] = "두루마리"
L["READINESS_SOULSTONE"] = "영혼석 비활성"
L["READINESS_HEALTHSTONE"] = "생명석"
L["READINESS_MANA_GEM"] = "마나 보석"
L["READINESS_HEALING_POTION"] = "치유 물약"
L["READINESS_MANA_POTION"] = "마나 물약"
L["READINESS_BANDAGES"] = "붕대"
L["READINESS_PVP_ON"] = "PvP 활성"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d분"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 1분 미만"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "미사용 특성 포인트 1점"
L["READINESS_UNSPENT_TALENTS_MANY"] = "미사용 특성 포인트 %d점"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "현재 소환수에게 줄 수 있는 적절한 먹이가 없습니다."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "현재 다음 주문을 배우지 않았습니다: %s, %s, %s, %s."
L["TIP_NO_HAND_POISON"] = "이 무기용으로 선택한 독이 다 떨어졌습니다."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "현재 %s 기술을 배우지 않았습니다."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "가방에 %s이(가) 없습니다. %s을(를) 우클릭하여 더 창조하세요."
L["TIP_EMPTY_CREATE"] = "가방에 %s이(가) 없습니다. %s을(를) 우클릭하여 하나 창조하세요."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "버프 음식"
L["FEATURE_SCROLL_BUFFS"] = "두루마리 버프"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "버프 음식 및 두루마리"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'"%s" 음식을 사용하고, 음식을 먹기 전에 빠진 두루마리 버프를 적용합니다.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "현재 음식"
L["MINIMAP_BEST_PET_FOOD"] = "현재 소환수 음식"
L["MINIMAP_MAIN_HAND_POISON"] = "주장비 독"
L["MINIMAP_OFF_HAND_POISON"] = "보조장비 독"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "차단 목록"
L["MINIMAP_IGNORE_COUNT"] = "아이템 %d개"
L["MENU_IGNORE"] = "차단"
L["MENU_CLEAR_IGNORE"] = "차단 목록 초기화"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 보고서"
L["MINIMAP_RESTOCKER_NEEDED"] = "미완료 주문 %d건"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "축하합니다, 필요한 물품을 모두 갖췄습니다!"
L["MINIMAP_RESTOCKER_EMPTY"] = "목록이 비어 있습니다."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "보충 목록"
L["MENU_RESTOCKER_DESCRIPTION"] = "목록에 있는 아이템을 구매하고 은행에 보관합니다."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 우클릭"
L["MENU_OPTIONS"] = "GtG 설정"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 휠클릭"

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
L["NOTE_MACRO_FEED_PET"] = "먹이 주기 매크로"
L["NOTE_MACRO_FOOD_WATER"] = "음식 및 물 매크로"
L["NOTE_MACRO_MANA_GEM"] = "마나 보석 매크로"
L["NOTE_MACRO_HEALTHSTONE"] = "생명석 매크로"
L["NOTE_MACRO_SOULSTONE"] = "영혼석 매크로"
L["NOTE_MACRO_POISONS"] = "독 매크로"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "부르기, 먹이 주기 또는 되살리기"
L["NOTE_PET_MEND_CLICK"] = "우클릭 또는 전투 중"
L["NOTE_HOLD_SHIFT"] = "Shift 누른 채"
L["NOTE_PET_FORCE_REVIVE"] = "강제 되살리기"
L["NOTE_HOLD_CONTROL"] = "Ctrl 누른 채"
L["NOTE_PET_DISMISS"] = "소환해제"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "창조"
L["NOTE_CREATE"] = "창조"
L["NOTE_RIGHT_CLICK_AGAIN"] = "다시 우클릭"
L["NOTE_LOWER_RANK_BACKUP"] = "낮은 등급 예비"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"레벨이 낮은 플레이어를 대상으로 지정하면 그 레벨에 맞게 창조합니다."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"레벨이 낮은 플레이어를 대상으로 지정하면 그 레벨에 맞는 생명석을 창조합니다."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "독 조제 창"
L["NOTE_POISONS_REPLACED"] = "기존 독을 자동으로 교체합니다."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "붕대"
L["LABEL_EXPLOSIVE"] = "폭발물"
L["LABEL_FOOD"] = "음식"
L["LABEL_HEALTH_POTION"] = "치유 물약"
L["LABEL_HEALTHSTONE"] = "생명석"
L["LABEL_MANA_GEM"] = "마나 보석"
L["LABEL_MANA_POTION"] = "마나 물약"
L["LABEL_PET_FOOD"] = "소환수 음식"
L["LABEL_POISON"] = "독"
L["LABEL_SOULSTONE"] = "영혼석"
L["LABEL_WATER"] = "물"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "켜짐"
L["MINIMAP_DISABLED"] = "꺼짐"
L["MINIMAP_TOGGLE"] = "켜기/끄기"
L["MINIMAP_OPEN"] = "열기"
L["MINIMAP_LEFT_CLICK"] = "좌클릭"
L["MINIMAP_RIGHT_CLICK"] = "우클릭"
L["MINIMAP_MIDDLE_CLICK"] = "휠클릭"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 좌클릭"

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
L["GROUP_CONTEXT_SOLO"] = "혼자"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "파티나 공격대에 속하지 않았을 때."
L["GROUP_CONTEXT_PARTY"] = "파티"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] = "파티에 속했을 때. 파티 찾기로 들어간 던전도 포함됩니다."
L["GROUP_CONTEXT_RAID"] = "공격대"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] = "공격대에 속했을 때. 전장의 공격대는 전장으로 칩니다."
L["GROUP_CONTEXT_BATTLEGROUND"] = "전장"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] =
	"전장이나 투기장 안에 있을 때. 어떤 그룹이든 상관없습니다."
L["GROUP_CONTEXT_NEVER"] = "안 함"

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
	"음식 매크로에서 %s 기능을 사용할 레벨을 선택합니다: 모든 레벨, 레벨업 중일 때만, 또는 최고 레벨일 때만. 아래 체크박스로 그룹을 선택합니다."
L["OPTIONS_MODE_CAPTION"] = "사용 시점"
L["OPTIONS_GROUPS_NONE"] = "아무것도 체크되지 않아 사용되지 않습니다."
L["LEVEL_FILTER_ANY"] = "모든 레벨에서"
L["LEVEL_FILTER_LEVELING"] = "레벨업 중일 때"
L["LEVEL_FILTER_MAX_LEVEL"] = "최고 레벨일 때"

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
L["INVENTORY_REPORT_TITLE"] = "보유량 보고서"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "가방 %s, 은행 %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "가방 %s"
L["INVENTORY_REPORT_BANK"] = "은행 %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "합계 %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"최고의 음식, 물, 물약, 생명석으로 자동 갱신되는 매크로, 재료와 탄약을 자동으로 구매하고 은행에 보관하는 보충 목록, 클릭 한 번으로 시전하는 빠진 버프, 그리고 모든 주문의 마우스오버 매크로."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "향상된 마법책"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"모든 직업 주문에 대한 마우스오버, 커서, 자신 시전 매크로를 새 마법책 탭에서 클릭 한 번으로 만들며, 매크로 문법은 몰라도 됩니다. 레벨업하거나 주문을 배우거나 특성을 바꾸면 자동으로 갱신됩니다. 우클릭하면 주시 대상, 시전 중지, 자동 공격, 소환수 공격, 장신구를 추가할 수 있습니다."
L["SPELLBOOK_IS_OFF"] =
	"향상된 마법책이 꺼져 있습니다. 설정 > 애드온 > Good to Go > 향상된 마법책에서 켜세요."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "환영 메시지 활성화"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "로그인 시 대화창에 환영 메시지를 출력합니다."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "미니맵 버튼 활성화"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "미니맵 버튼을 표시합니다."

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
L["OPTIONS_FEATURES_HEADER"] = "기능"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"파티나 공격대에서 내가 걸어 줄 수 있는 버프가 없는 사람을 모두 보여 주는 창을 표시합니다. 아이콘을 클릭하면 그 버프를 시전합니다."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"보충 목록에 따라 가방을 채워 두며, 상인에게서 구매하고 은행과 가방 사이에서 아이템을 옮기고, 물품이 부족해지면 알려 줍니다. 끄면 보충 목록 창을 포함해 이 모든 기능이 멈춥니다. 목록은 그대로 저장됩니다."
L["SWITCH_SPELLBOOK"] = "향상된 마법책 활성화"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"마법책에 탭을 추가하여 주문의 마우스오버, 커서, 자신 시전 매크로를 만들고, 레벨업하거나 주문을 배울 때마다 최신 상태로 유지합니다. 끄면 탭이 숨겨지고 갱신이 멈춥니다. 매크로를 삭제하지는 않으며, 삭제는 향상된 마법책 패널의 매크로 삭제 버튼으로 합니다."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"향상된 마법책을 끄시겠습니까? 마법책에서 탭이 사라지고, 이 기능이 만든 매크로는 레벨업하거나 주문을 배워도 더 이상 갱신되지 않습니다. 매크로가 삭제되지는 않으며, 지금 모습 그대로 행동 단축바에 남습니다."
L["SWITCH_MACROS"] = "소모품 매크로 활성화"
L["SWITCH_MACROS_DESCRIPTION"] =
	"가방 내용이 바뀔 때마다 음식, 물, 물약 등 소모품 매크로가 가방 속 가장 좋은 아이템을 사용하도록 유지합니다. 끄면 갱신이 멈추고 모든 매크로가 마지막 상태로 남습니다. 매크로를 삭제하지는 않으며, 삭제하려면 소모품 매크로 패널의 생성할 매크로에서 체크를 해제하세요."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"소모품 매크로를 끄시겠습니까? 가방 내용이 바뀌어도 매크로가 갱신되지 않으므로, 이미 다 쓴 아이템을 버튼이 계속 사용하려 할 수 있습니다. 매크로가 삭제되지는 않으며, 지금 모습 그대로 행동 단축바에 남습니다."
L["SWITCH_INVENTORY_REPORT"] = "보유량 보고서 활성화"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"아이템 툴팁에 가방, 은행, 그리고 이 서버의 다른 캐릭터가 가진 개수를 추가합니다. 다른 애드온이 이미 이 개수를 표시한다면 끄세요."
L["SWITCH_READINESS_REPORT"] = "준비 보고서 활성화"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"전투 준비 확인이 시작되면 빠진 버프나 물약, 손상된 장비처럼 아직 해결해야 할 것을 나만 볼 수 있게 출력합니다. 준비가 끝났다면 아무것도 출력하지 않습니다."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Restocker 활성화"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "예시: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 인터페이스를 엽니다."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "보충 목록을 엽니다."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"이 애드온은 이 게임을 사랑하고 모두가 최대한 재미있게 즐기기를 바라는 플레이어들이 만들었습니다. 저희는 절대 후원을 요청하지 않습니다. 저희의 작업이 여러분의 게임을 조금이라도 더 좋게 만든다는 것이 가장 큰 보람입니다. 그렇다면 꼭 이야기를 들려주세요!"
L["OPTIONS_LEVEL_UP_WAYS"] =
	"더 많은 플레이어에게 다가갈 수 있도록 도와주실 수 있는 몇 가지 방법을 소개합니다."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 피드백 공유: 버그를 발견하셨거나 아이디어가 있으신가요? Discord에서 알려 주세요. 여러분의 피드백은 애드온을 개선하는 데 도움이 되며, 풀 리퀘스트도 언제나 환영합니다."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 친구에게 알리기: 이 애드온을 좋아할 만한 분을 알고 계신가요? 그분께 알려 주세요. 입소문은 더 많은 플레이어가 좋은 애드온을 발견하는 데 도움이 됩니다."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• CurseForge에서 즐겨찾기: 아래 CurseForge 링크를 열고 로그인한 다음, Download 버튼 아래의 별을 클릭하세요. 즐겨찾기는 더 많은 플레이어가 이 애드온을 발견하는 데 도움이 됩니다."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• GitHub에서 스타 누르기: 아래 GitHub 링크를 열고 로그인한 다음, 오른쪽 위의 Star 버튼을 클릭하세요. 스타는 프로젝트가 더 많은 무료 개발자 도구를 이용할 자격을 얻는 데 도움이 됩니다."

L["OPTIONS_FEEDBACK"] = "피드백 및 지원"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "피드백 및 지원 링크"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "링크를 복사하려면 해당 상자를 클릭한 다음 Ctrl+A와 Ctrl+C를 누르세요."
L["OPTIONS_VERSION"] = "버전 %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "소모품 매크로"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go는 소모품마다 매크로를 하나씩 만들고 가방 내용이 바뀔 때마다 최신 상태로 유지하므로, 단축바의 버튼은 항상 지금 가진 가장 좋은 아이템을 사용합니다. 아래에서 만들 매크로를 고른 다음, 각 매크로가 아이템을 고르는 방식을 설정하세요."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "버튼에 매크로 이름 표시"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Good to Go가 기본적으로 숨기는 매크로 이름 텍스트를 행동 단축바 버튼에 표시합니다."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "생성할 매크로"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Good to Go가 생성하고 관리할 매크로를 선택하세요. 매크로를 끄면 해당 매크로도 삭제됩니다. 매크로는 매크로 창의 일반 매크로 탭에 있으며, 바로 행동 단축바로 끌어다 놓을 수 있습니다."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "매크로 창 열기"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"게임의 매크로 창을 이 매크로들이 있는 일반 매크로 탭으로 엽니다."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"이 매크로를 생성하고 관리하며, 체크를 해제하면 삭제합니다."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "음식 및 물"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"음식 및 물 매크로는 가방에 있는 가장 좋은 음식과 음료를 사용합니다. 이 옵션들로 버프 음식, 두루마리, 창조된 음식과 물을 먼저 사용하고, 보충 목록의 음식과 물은 나중에 사용하게 할 수 있습니다."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "버프 음식 우선"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'투기장을 제외하고, "%s" 버프가 없을 때 해당 버프를 주는 음식을 우선 사용합니다.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "두루마리 버프 활성화"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"음식 매크로를 처음 누르면 빠진 두루마리 버프를 적용하고 다음에 누르면 음식을 먹으며, 아군 플레이어를 대상으로 지정했거나 투기장에 있을 때는 두루마리를 건너뜁니다."
L["OPTIONS_SCROLL_TYPES"] = "확인할 두루마리 유형 포함"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "보호"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "빠진 버프를 확인할 때 %s 유형을 포함합니다."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "창조된 음식 및 물 먼저 사용"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'창조된 음식과 물은 비용이 들지 않고 접속을 종료하면 곧 사라지므로, 가방에 더 많이 회복하는 아이템이 있더라도 음식 및 물 매크로가 이를 가장 먼저 사용합니다. "버프 음식 우선"이 켜져 있으면 버프 음식이 여전히 가장 먼저입니다.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"창조된 음식과 물을 먼저 사용할 레벨을 선택합니다: 모든 레벨, 레벨업 중일 때만, 또는 최고 레벨일 때만. 아래 체크박스로 그룹을 선택합니다."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "보충 목록의 음식 및 물 나중에 사용"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"회복량이 같은 음식이나 음료가 둘 있으면, 음식 및 물 매크로가 보충 목록에 없는 것을 먼저 사용하고 Restocker가 구매한 것은 나중을 위해 남겨 둡니다."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "물약 및 생명석"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"전투 중에는 매크로를 변경할 수 없으므로(블리자드 제한 사항), 각 물약 및 생명석 매크로는 가장 좋은 아이템과 최대 2개의 예비 아이템으로 미리 구성됩니다. 긴 전투에서는 아이콘과 툴팁이 갱신되지 않아 잘못된 아이템을 표시할 수 있지만, 매크로를 클릭하면 항상 가방에 실제로 있는 가장 좋은 아이템을 사용합니다."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "비전투 시 물약 매크로에서 음식 및 물 사용"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"전투 중이 아닐 때 치유 물약 매크로는 가장 좋은 음식을 먹고, 마나 물약 매크로는 가장 좋은 물을 마십니다. 전투 중에는 평소처럼 물약을 사용합니다. 두루마리, 소환수 음식, 창조 주문은 계속 음식 및 물 매크로가 담당합니다."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "생명석을 치유 물약 매크로에 결합"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"가장 좋은 생명석을 치유 물약 매크로의 하단에 추가하여, 한 번 누르면 물약과 생명석을 모두 사용합니다."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "마나 보석 및 룬"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s, 그리고 몇몇 다른 마나 회복 아이템은 마나 보석과 재사용 대기시간을 공유합니다. 룬은 사용할 때 생명력이 소모되므로, 직접 추가하지 않으면 마나 보석 매크로는 이들을 모두 제외합니다."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "룬 및 기타 마나 회복 아이템을 마나 보석 매크로에 추가"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"%s, %s, 그리고 마나 보석과 재사용 대기시간을 공유하는 다른 마나 회복 아이템도 마나 보석과 함께 우선순위를 매겨, 그중 하나가 가장 좋은 선택이거나 보석이 다 떨어졌을 때 마나 보석 매크로가 이를 사용합니다."

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "버프 재적용"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"전투 중에는 매크로를 변경할 수 없으므로, 전투 도중 만료된 버프는 전투가 끝날 때까지 사라진 채로 남습니다."
L["OPTIONS_REAPPLY"] = "만료 임박 버프 재적용"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"남은 시간이 설정한 기준값보다 적은 버프 음식, 두루마리 버프, 소환수 음식 버프를 만료된 것으로 간주하여, 전투 전에 매크로가 새 버프를 제안합니다."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"버프가 만료되기 얼마 전부터 매크로가 새 버프를 제안할지 설정합니다."
L["REAPPLY_THRESHOLD_ONE"] = "1분 미만 남았을 때"
L["REAPPLY_THRESHOLD_MANY"] = "%d분 미만 남았을 때"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "소환수 음식 버프"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = '일부 음식은 소환수에게 별도의 "%s" 버프를 줍니다.'
L["OPTIONS_USE_PET_BUFFS"] = "소환수 음식 버프 사용"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'투기장을 제외하고, 소환수에게 "%s" 버프가 없을 때 음식 매크로에 소환수 음식을 추가합니다.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "확인할 소환수 음식 유형 포함"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "폭발물"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 옵션은 조준 원 없이 폭발물을 발밑에서 바로 터뜨립니다. 대상이 근접 거리일 때 이상적입니다. 다른 클릭은 평소처럼 폭발물을 던집니다."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "클릭 할당"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"어떤 클릭으로 폭발물을 던지고 어떤 클릭으로 발밑에서 터뜨릴지 선택합니다."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "좌클릭 @player"
L["EXPLOSIVES_MODE_TOSS"] = "좌클릭 던지기"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "직업 및 종족"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"특정 직업이나 종족에 맞게 매크로를 조정하는 옵션입니다. 모든 항목은 모든 캐릭터에서 표시됩니다."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "직업 옵션: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "종족 옵션: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"DruidMacroHelper 애드온이 필요합니다. 켜면 치유 물약, 마나 물약, 생명석 매크로가 변신을 풀고 아이템을 사용한 뒤, 확인란 옆에서 고른 곰 변신 또는 표범 변신으로 다시 변신시킵니다."
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper 연동 활성화"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"DruidMacroHelper(/dmh)를 사용하여 치유 물약, 마나 물약, 생명석에 대한 변신 매크로를 생성합니다."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"변신 매크로로 아이템을 사용한 뒤 복귀할 형태를 선택합니다."
L["DRUID_FORM_BEAR"] = "곰으로 복귀"
L["DRUID_FORM_CAT"] = "표범으로 복귀"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"독 매크로를 각 독 종류의 사용 가능한 최고 등급으로 유지합니다. 좌클릭은 보조장비에, 우클릭은 주장비에 바르며, 기존 독은 자동으로 교체됩니다."
L["OPTIONS_POISON_MAIN_HAND"] = "주장비 독 종류"
L["OPTIONS_POISON_OFF_HAND"] = "보조장비 독 종류"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"독 매크로를 우클릭할 때 주장비에 바를 독을 선택합니다."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"독 매크로를 좌클릭할 때 보조장비에 바를 독을 선택합니다."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "먹을 때 은신 사용"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"음식 매크로에 %s 주문을 추가하여 음식을 먹는 동안 은신합니다."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "마실 때 은신 사용"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"물 매크로에 %s 주문을 추가하여 물을 마시는 동안 은신합니다."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"프로 팁: 하나만 선택하세요. 먹기와 마시기는 동시에 할 수 있지만, 은신한 뒤에 먹거나 마시면 은신이 풀립니다."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"처치한 인간형 또는 언데드를 대상으로 지정하면, 재사용 대기 중이 아닐 때 매크로가 %s 주문을 시전하여 음식과 음료를 아낍니다. 시전할 수 없으면(시체가 너무 멀거나 주문이 재사용 대기 중이면) 평소처럼 먹거나 마십니다."
L["OPTIONS_CANNIBALIZE_EATING"] = "음식 대신 %s 사용"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"대상이 %s 주문을 사용할 수 있는 시체이고 주문이 재사용 대기 중이 아니면, 음식 매크로가 음식을 먹는 대신 이 주문을 시전합니다. 그 외에는 평소처럼 음식을 먹습니다. 두루마리와 버프 음식이 여전히 먼저입니다."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "물 대신 %s 사용"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"대상이 %s 주문을 사용할 수 있는 시체이고 주문이 재사용 대기 중이 아니면, 물 매크로가 물을 마시는 대신 이 주문을 시전합니다. 그 외에는 평소처럼 물을 마십니다. 버프 음료가 여전히 먼저입니다."

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"%s이(가) 재사용 대기 중이 아니면 음식 매크로가 음식을 먹는 대신 이 주문을 시전하여 음식을 아낍니다. 재사용 대기 중이면 평소처럼 음식을 먹습니다."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "음식 대신 %s 사용"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"%s이(가) 재사용 대기 중이 아니면 음식 매크로가 음식을 먹는 대신 이 주문을 시전합니다. 그 외에는 평소처럼 음식을 먹습니다. 두루마리와 버프 음식이 여전히 먼저입니다. 음식을 먹을 수 없는 전투 중에는 누를 때마다 이 주문을 시전합니다."

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
L["TAB_IGNORE_LIST"] = "차단 목록"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"차단한 아이템은 어떤 매크로에서도 선택되지 않습니다. 음식, 물, 물약 등 무엇이든 해당됩니다. 전체 목록은 모든 캐릭터에 적용되고, 캐릭터 목록은 해당 캐릭터에만 적용됩니다. 미니맵 버튼을 우클릭하면 현재 가장 좋은 음식을 차단합니다."
L["OPTIONS_IGNORE_GLOBAL"] = "전체"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"이 아이템을 전체 목록으로 옮겨 모든 캐릭터에서 차단합니다."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "가방에서 추가"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"가지고 있는 아이템 중 하나를 고르세요. 설정 인터페이스가 열리면 가방이 닫히므로, 아이템을 여기로 끌어다 놓는 대신 사용합니다."
L["OPTIONS_IGNORE_ADD_ID"] = "아이템 ID로 추가"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"아이템 ID를 입력하거나, 이 입력란이 선택된 상태에서 대화창의 아이템 링크를 Shift + 클릭하세요."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"아이템 ID를 입력하거나, 대화창의 아이템 링크를 Shift + 클릭하세요."
L["OPTIONS_IGNORE_REMOVE"] = "제거"
L["OPTIONS_IGNORE_EMPTY"] = "목록이 비어 있습니다."
L["OPTIONS_IGNORE_CLEAR"] = "목록 비우기"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"이 목록에서 모든 아이템을 제거합니다. 목록이 빈 캐릭터는 지금 플레이 중인 캐릭터가 아니면 왼쪽 목록에서 사라집니다."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "이 목록에서 모든 아이템을 제거할까요? 되돌릴 수 없습니다."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "ID 불러오는 중: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"보충 목록에 따라 가방을 채워 두며, 상인에게서 구매하고 은행과 가방 사이에서 아이템을 옮기는 작업을 자동으로 처리합니다. 목록을 열려면 %s 명령어를 입력하세요."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "은행에서 열기"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "은행을 방문하면 보충 목록을 엽니다."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "상인 방문 시 열기"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "상인을 방문하면 보충 목록을 엽니다."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "알림"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] =
	"보충 목록의 물품이 부족할 때 언제 알림을 받을지 선택하세요."
L["OPTIONS_RESTOCKER_REMIND"] = "마을 보충 알림 사용"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"보충 목록에 부족한 것이 있고 여관이나 도시에 도착하거나 이미 그곳에 있는 상태로 접속했을 때 대화창에 알림을 표시합니다."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "상인 보충 알림 사용"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"상인 창을 닫을 때 미완료 보충 주문이 있으면 알려 줍니다."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "은행 보충 알림 사용"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"은행을 닫을 때 미완료 보충 주문이 있으면 알려 줍니다."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "예비 골드"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] =
	"상인에게서 구매할 때 절대 쓰지 않을 골드를 따로 남겨 둡니다."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "예비 골드 사용"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"여기서 따로 남겨 둔 골드는 보충에 절대 사용하지 않습니다."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] =
	"보충 후에도 항상 남겨 둘 골드 양을 설정합니다."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"알림을 한 줄로만 표시할지, 부족한 아이템마다 한 줄씩 추가할지 선택합니다."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "알림 상세도"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "간단히"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "자세히"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "소리 재생"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"대화창이 바쁠 때를 위해 알림과 함께 경고음을 재생합니다."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "클릭하면 경고음을 들어 볼 수 있습니다."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "보충 목록 창"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "보충 목록이 자동으로 열릴 시점을 선택하세요."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"이 서버에 있는 모든 캐릭터를 통틀어 아이템을 몇 개 가지고 있는지 해당 아이템의 툴팁에 표시합니다."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "기록된 캐릭터"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "잊기"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"%s 캐릭터를 잊을까요? 그 캐릭터의 가방과 은행 정보가 모든 아이템 툴팁에서 사라지고, 보충 목록 선택도 초기화됩니다. 그 캐릭터로 다시 접속하면 다시 기록됩니다."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "준비 보고서"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"전투 준비 확인이 시작되면 아직 해결해야 할 항목을 자신만 볼 수 있는 목록으로 출력하고, 준비가 되어 있으면 아무것도 출력하지 않습니다."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "준비 보고서 설정 초기화"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"이 페이지의 모든 체크박스와 두 기준값을 기본값으로 되돌립니다."
L["OPTIONS_READINESS_RESET_CONFIRM"] = "준비 보고서의 모든 설정을 기본값으로 초기화할까요?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "부족한 버프"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "부족한 아이템"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "캐릭터"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"영약이 없으면 알려 줍니다. 영약 하나, 또는 전투 비약과 수호 비약 각 하나가 있으면 충족된 것으로 봅니다."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'"%s" 버프가 없으면 알려 줍니다. 소모품 매크로에서 버프 음식을 켜야 합니다.'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'소환수에게 "%s" 버프가 없으면 알려 줍니다. 소모품 매크로에서 소환수 음식 버프를 켜야 하며, 소환수를 불러낸 상태여야 합니다.'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"빠진 두루마리 버프를 알려 줍니다. 소모품 매크로에서 두루마리 버프를 켜야 하며, 그곳에서 선택한 두루마리 유형만 확인합니다."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"그룹 내 누구에게도 영혼석이 활성화되어 있지 않으면 알려 줍니다. 가방에 있는 영혼석은 인정하지 않습니다. 영혼석을 창조할 수 있는 흑마법사에게만 알려 줍니다."
L["OPTIONS_READINESS_MAIN_HAND"] = "주장비 무기 버프"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"주장비 무기에 일시적인 강화 효과가 없으면 알려 줍니다. 어떤 강화든 인정하며, 그룹에 주술사가 있으면 알리지 않습니다."
L["OPTIONS_READINESS_OFF_HAND"] = "보조장비 무기 버프"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"보조장비 무기에 일시적인 강화 효과가 없으면 알려 줍니다. 어떤 강화든 인정합니다: 숫돌, 무게추, 오일, 독, 주술사 무기 버프."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"주장비 무기에 일시적인 강화 효과가 부족하면 알려 줍니다. 도적과 주술사는 독이나 무기 강화 하나와 오일이나 숫돌 하나, 총 두 가지가 필요하고, 다른 직업은 아무것이나 하나면 됩니다."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"보조장비 무기에 일시적인 강화 효과가 부족하면 알려 줍니다. 도적은 독 하나와 오일이나 숫돌 하나, 총 두 가지가 필요하고, 다른 직업은 아무것이나 하나면 됩니다."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "버프 만료 기준 시간"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Good to Go가 거는 버프뿐 아니라 곧 만료될 내 모든 버프를 알려 주며, 소모품 매크로의 버프 재적용과는 별개입니다."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s분"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1분"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"버프가 만료되기 얼마 전부터 보고서에 표시할지 설정합니다."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"생명석을 하나도 가지고 있지 않으면 알려 줍니다. 부탁할 흑마법사가 그룹에 있거나, 자신이 흑마법사일 때만 알려 줍니다."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"마나 보석을 하나도 가지고 있지 않으면 알려 줍니다. 마나 보석을 창조할 수 있는 마법사에게만 알려 줍니다."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"전투 중에는 아무도 물약을 건네줄 수 없으므로, 치유 물약을 하나도 가지고 있지 않으면 알려 줍니다."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"마나 물약을 하나도 가지고 있지 않으면 알려 줍니다. 마나를 사용하는 직업으로 플레이할 때만 알려 줍니다."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"현재 %s 숙련도로 사용할 수 있는 붕대를 하나도 가지고 있지 않으면 알려 줍니다."
L["OPTIONS_READINESS_DURABILITY"] = "손상된 장비 (내구도 기준)"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"내구도가 이 값보다 낮은 착용 장비를 모두 링크하며, 장비별로 측정하므로 무기 하나만 부서져도 표시됩니다."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"장비의 내구도가 얼마나 떨어지면 보고서에 링크할지 설정합니다."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "현재 특성"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"특성 분배와 아직 사용하지 않은 포인트를 출력합니다."
L["OPTIONS_READINESS_PVP"] = "PvP 상태 켜짐"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "PvP 상태가 켜져 있으면 경고합니다."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "비전투용 장비 착용"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"승마 장비나 낚시 장비처럼 전투에 어울리지 않는 착용 장비를 링크합니다."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "주문 레벨 감시"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"그룹에서 시전자가 쓸 수 있는 것보다 낮은 레벨로 시전된 주문을 감시하고, 상급자에게 더 높은 레벨이 기다리고 있다고 알려 줍니다. 레벨이 낮은 플레이어에게 거는 버프처럼 게임이 스스로 낮추는 레벨은 절대 알리지 않습니다."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s이(가) 아직 실행 중이므로, 그룹원이 낮은 레벨 알림을 두 번씩 받지 않도록 주문 레벨 감시는 조용히 있습니다. Good to Go가 그 애드온을 끄고 주문 레벨 감시를 켜 두었습니다. UI를 다시 불러오면 주문 레벨 감시가 이어서 맡습니다."

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s (%s)"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "레벨 %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"참고로, 별건 아닌데 %s을(를) 쓰셨어요. %d레벨부터 상위 레벨을 배울 수 있어요. 행동 단축바를 바꾸시거나 상급자에게 들르시면 바로 Good to Go!"
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"참고로, 별건 아닌데 소환수 %s이(가) %s을(를) 썼어요. 소환수 %d레벨부터 상위 레벨을 배울 수 있어요. 야수 조련으로 가르쳐 주시면 바로 Good to Go!"
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"참고로, 별건 아닌데 소환하신 %s이(가) %s을(를) 썼어요. %d레벨부터 상위 레벨을 배울 수 있어요. 악마 조련사에게서 마법서를 구하시면 바로 Good to Go!"
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"이런 팁이 필요 없으시면 답장으로 %s만 보내 주세요. 그러면 주문 레벨 관련 귓속말을 다시는 보내지 않을게요. 이 번호는 Good to Go를 쓰는 누구에게나 통해요."
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] = "알겠어요, 이제 주문 레벨 팁은 보내지 않을게요."
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	"%s 님이 수신 거부 번호를 보내서 이제 주문 레벨 감시가 이 플레이어를 제외합니다. 주문 레벨 감시의 제외한 플레이어에서 되돌릴 수 있습니다."
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"%s을(를) 시전했습니다. %s은(는) %d레벨부터 배울 수 있습니다. 상급자를 찾아가거나 행동 단축바를 갱신하세요."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] =
	"소환수 %s이(가) %s을(를) 시전했습니다. %s은(는) 소환수 %d레벨부터 배울 수 있습니다."
L["RANK_WATCH_PRINT_SELF_DEMON"] =
	"내 %s이(가) %s을(를) 시전했습니다. %s은(는) %d레벨부터 배울 수 있습니다."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] =
	"%s 님이 %s을(를) 시전했습니다. 이 플레이어는 %s을(를) %d레벨부터 배울 수 있습니다."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] =
	"%s 님의 소환수 %s이(가) %s을(를) 시전했습니다. 이 소환수는 %s을(를) 소환수 %d레벨부터 배울 수 있습니다."
L["RANK_WATCH_PRINT_OTHER_DEMON"] =
	"%s 님의 %s이(가) %s을(를) 시전했습니다. 이 악마는 %s을(를) %d레벨부터 배울 수 있습니다."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "귓속말은 %s 님이 보냅니다."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "주문 레벨 감시 활성화"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"누군가 배울 수 있는 것보다 낮은 레벨로 주문을 시전하면 나에게 알려 주고 그룹원에게 귓속말을 보내, 상급자를 찾아가도록 알려 줍니다."

L["RANK_WATCH_MESSAGES_HEADER"] = "알림"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] =
	"주문 레벨 감시가 낮은 레벨을 시전한 플레이어에게 알리는 방법입니다."
L["RANK_WATCH_WHISPER"] = "그룹원에게 귓속말"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"낮은 레벨을 시전한 그룹원에게 귓속말을 보냅니다. 그룹에서 여러 명이 주문 레벨 감시나 Rank Sentinel을 사용하면 그중 한 명만 귓속말을 보냅니다."
L["RANK_WATCH_PRINT"] = "그룹원의 낮은 레벨 출력"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"그룹원의 낮은 레벨을 대화창에 출력합니다. 내 낮은 레벨은 항상 출력됩니다."
L["RANK_WATCH_GRACE_HEADER"] = "유예 기간"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"시전자의 레벨이 새 주문 레벨의 습득 레벨을 이 값만큼 넘어서기 전까지는 알리지 않으므로, 막 도달해 아직 배울 시간이 없었던 레벨 때문에 알림을 받는 사람이 없습니다."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "최고 레벨 유예 기간"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"최고 레벨 캐릭터의 경우, 최고 레벨과 이 값 이내로 차이 나는 레벨에서 배우는 주문 레벨은 알리지 않습니다. 0이면 배울 수 있는 모든 주문 레벨을 알립니다."
L["RANK_WATCH_GRACE_LEVELING"] = "레벨업 중 유예 기간"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"아직 레벨업 중인 캐릭터의 경우, 자기 레벨과 이 값 이내로 차이 나는 레벨에서 배우는 주문 레벨은 알리지 않아 상급자를 찾아갈 시간을 줍니다."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1레벨"
L["RANK_WATCH_GRACE_LEVELS"] = "%d레벨"

L["RANK_WATCH_OPT_OUT_HEADER"] = "수신 거부"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	"주문 레벨 감시가 누군가에게 처음 귓속말을 보내면, 이어서 그 사람의 수신 거부 번호를 알려 줍니다. 번호는 이름으로 만들어지므로 Good to Go를 쓰는 누구에게서나 같습니다. 그 사람이 귓속말이나 내가 볼 수 있는 대화 채널에서 이 번호를 말하면 제외한 플레이어에 추가되어, 다시는 나에게서 주문 레벨 알림을 받지 않습니다. 직접 누군가를 제외하려면 대상으로 지정하고 /gtg ignore를 입력하세요."
L["RANK_WATCH_WHISPERER_HEADER"] = "그룹 알림 담당자"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"그룹에서 여러 명이 주문 레벨 감시나 Rank Sentinel을 사용하면 그중 한 명만 귓속말을 보내므로, 낮은 레벨을 시전한 플레이어는 모두에게서가 아니라 한 번만 알림을 받습니다. 나머지는 자기 대화창에만 출력합니다. 지금 귓속말을 보내는 사람은 다음과 같습니다."
L["RANK_WATCH_WHISPERER_SELF"] = "나입니다."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s 님이 보내므로, 나는 출력만 봅니다."
L["RANK_WATCH_WHISPERER_NONE"] = "없음: 그룹원에게 귓속말이 꺼져 있습니다."

-- Ability Alerts While Leveling: the Rank Watch panel's section for the level-up prints (LEVEL_UP_SPELLS and the rest)
L["RANK_WATCH_LEVEL_UP_HEADER"] = "레벨업 시 기술 알림"
L["RANK_WATCH_LEVEL_UP_DESCRIPTION"] =
	"레벨이 오르면 직업 전문가에게서 배울 수 있는 기술을 아이콘과 마우스를 올려 볼 수 있는 링크와 함께 대화창에 표시합니다. 주문 레벨 감시가 켜져 있든 아니든 별도의 스위치로 작동합니다."
L["RANK_WATCH_LEVEL_UP"] = "레벨업 시 새 기술 알림"
L["RANK_WATCH_LEVEL_UP_TOGGLE_DESCRIPTION"] =
	"방금 도달한 레벨에서 새로 배울 수 있는 기술을 표시합니다."
L["RANK_WATCH_LEVEL_UP_PAST"] = "건너뛴 기술 포함"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] =
	"이전 레벨에서 아직 배우지 않은 기술을 한 줄로 추가합니다."
L["RANK_WATCH_LEVEL_UP_PET"] = "소환수 기술 포함"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] =
	"새 레벨에서 배울 수 있는 사냥꾼의 야수 조련사 기술이나 흑마법사의 악마 훈련사 마법서를 추가합니다."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "건너뛴 소환수 기술 포함"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] =
	"사냥꾼 전용: 이전 레벨에서 아직 배우지 않은 야수 조련사 기술을 한 줄로 추가합니다. 흑마법사는 이 줄이 표시되지 않습니다. 악마가 소환되어 있지 않으면 어떤 마법서를 배웠는지 게임이 알려주지 않기 때문입니다."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "제외한 플레이어"
L["RANK_WATCH_IGNORED_DESCRIPTION"] =
	"주문 레벨 감시는 이 플레이어들에 대해 절대 알리지 않습니다."
L["RANK_WATCH_IGNORED_NONE"] = "아직 없습니다."
L["RANK_WATCH_IGNORED_REMOVE"] = "제외 해제"
L["RANK_WATCH_IGNORE_TARGET"] = "대상 제외"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "대상으로 지정한 플레이어를 목록에 추가합니다."
L["RANK_WATCH_IGNORE_ADDED"] = "이제 주문 레벨 감시가 %s 님을 제외합니다."
L["RANK_WATCH_IGNORE_NOT_FOUND"] =
	"%s 님을 찾을 수 없습니다. 그룹을 맺거나 대상으로 지정한 다음 다시 시도하세요."
L["RANK_WATCH_IGNORE_NO_TARGET"] = "플레이어를 대상으로 지정하거나 /gtg ignore 이름을 입력하세요."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore 이름"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"주문 레벨 감시가 그 플레이어를 더 이상 알리지 않습니다. 이름을 생략하면 대상을 제외합니다."

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"주문 레벨 감시가 알리는 주문 레벨을 직업별로 보여 줍니다. 일부러 낮춰 쓰는 레벨은 체크를 해제하면 주문 레벨 감시가 알리지 않습니다. 모든 능력이 표시됩니다. 치유, 특성, 불태우기 레벨 1처럼 주문 레벨 감시가 기본적으로 감시하지 않는 능력은 체크가 해제된 상태로 시작합니다. 능력의 가장 높은 레벨은 그 위가 없으므로 회색으로 표시됩니다."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (요구 레벨 %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "더 높은 레벨을 배울 수 있으면 이 레벨을 알립니다."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "가장 높은 레벨입니다. 그 위가 없으므로 알리지 않습니다."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s 소환수"
L["RANK_WATCH_TRACK_ALL"] = "모두 체크"
L["RANK_WATCH_TRACK_NONE"] = "모두 체크 해제"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '"%s" 이름의 목록이 이미 있습니다.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "ID %d인 아이템 없음"
L["RESTOCKER_DISABLED"] =
	"Restocker가 꺼져 있습니다. 설정 > 애드온 > Good to Go > Restocker에서 켜세요."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = "%s(이)라는 보충 목록이 없습니다."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"보충이 완료되었습니다. 은행을 열 때 Shift를 누르고 있으면 보충을 건너뜁니다. 보충 목록을 편집하려면 %s 명령어를 입력하세요."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "보충이 중단되었습니다. 가방과 은행이 모두 가득 찼습니다."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"보충이 중단되었습니다. 은행이 가득 찼습니다. 칸을 비우고 다시 여세요."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"보충이 중단되었습니다. 가방이 가득 찼습니다. 칸을 비우고 은행을 다시 여세요."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "보충이 중단되었습니다. 더 이상 진행할 수 없습니다."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "보충이 중단되었습니다. 옮기지 못함: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (초과분)"
L["RESTOCKER_STOPPED_ERROR"] = "오류로 보충이 중단되었습니다: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"이 상인은 독에 필요한 재료를 전부 취급하지는 않습니다. 재료 구매를 모두 건너뜁니다."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "마을에 있는 동안 잊지 말고 보충하세요!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "보충 주문 1건이 남아 있습니다."
L["RESTOCKER_STILL_SHORT_MANY"] = "보충 주문 %d건이 남아 있습니다."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "보충 목록이 업그레이드되었습니다."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d에서 %sx%d(으)로 업그레이드되었습니다."

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
L["RESTOCKER_RESTOCKED_ONE"] = "보충 주문 1건을 완료했습니다."
L["RESTOCKER_RESTOCKED_MANY"] = "보충 주문 %d건을 완료했습니다."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "보충 주문 1건을 일부만 채웠습니다."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "보충 주문 %d건을 일부만 채웠습니다."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "모든 아이템을 구매하기 전에 가방이 가득 찼습니다."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "보충을 마치기에 골드가 부족합니다."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"골드가 %s 미만입니다. 골드가 더 생기면 보충을 다시 시작합니다."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[이름]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "해당 이름의 목록을 추가합니다."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "해당 이름의 목록을 삭제합니다."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "현재 목록의 이름을 해당 이름으로 바꿉니다."
L["RESTOCKER_HELP_PROFILE_COPY"] = "현재 목록을 해당 이름의 목록 복사본으로 바꿉니다."
L["RESTOCKER_HELP_PROFILE_USE"] = "이 캐릭터가 해당 이름의 목록을 사용하도록 전환합니다."

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
L["STARTER_POPUP_TITLE"] = "기본 물품"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "완료"
L["STARTER_POPUP_INTRO_LOGIN"] =
	"시작하실 수 있도록 직업에 맞는 기본 물품 몇 가지를 체크해 두었습니다."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"보충 목록이 비어 있으니, 시작할 수 있도록 아이템을 몇 가지 추가해 봅시다."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "계속 채워 둘 기본 물품을 고르세요."
L["STARTER_POPUP_INTRO_HOW"] =
	"체크한 항목은 상인이나 은행을 열 때마다 자동으로 보충됩니다. 대부분의 기본 물품은 레벨이 오르면 스스로 상위 등급으로 바뀌므로, 항상 구할 수 있는 가장 좋은 물건을 갖게 됩니다."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"%s 명령어를 입력하면 언제든지 이 목록을 조정하거나 아이템을 더 추가할 수 있습니다."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "음식 및 물"
L["STARTER_POPUP_FOOD_HEADER"] = "음식"
L["STARTER_POPUP_AMMO_HEADER"] = "탄약"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "탄환"
L["STARTER_POPUP_ARROWS"] = "화살"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "재료 및 도구"
L["STARTER_POPUP_POISONS_HEADER"] = "독"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : 완성된 독을 목록에 추가하면, 재료를 모두 취급하는 상인이라면 어디서든 Good to Go가 재료를 자동으로 구매합니다."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"%s을(를) 보충 목록에 추가하고, 가방에 %d개를 유지하며 레벨에 맞춰 상위 등급으로 바꿔 줍니다."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"%s을(를) 보충 목록에 추가하고 가방에 %d개를 유지합니다."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1묶음"
L["STARTER_POPUP_STACK_MANY"] = "%d묶음"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "계속 채워 둘 묶음 수를 정하며, 한 묶음은 %d개입니다."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"계속 채워 둘 개수를 정하며, 이 아이템은 겹쳐지지 않으므로 하나당 가방 한 칸을 차지합니다."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "보충 목록"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "아이템 필터..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "지우기"
L["RESTOCKER_ADD_BUTTON"] = "추가"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "기본 물품 고르기"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"음식, 물, 탄약, 독, 재료 중에서 직업과 레벨에 맞는 기본 물품을 고르세요. 체크하면 이 목록에 추가되고, 체크를 해제하면 제거됩니다."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "아이템 추가"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"가방에서 아이템을 끌어다 여기나 이 창의 아무 곳에나 놓거나, 아이템 ID를 입력하고 Enter를 누르세요."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "아이템 놓기 또는 ID 입력"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "대신 ID를 입력하세요."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "이미 이 목록에 있습니다."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "가방에서 아이템 추가"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"가방에 있지만 아직 이 목록에 없는 모든 아이템으로, 바로 추가할 수 있습니다."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "가방에 추가할 아이템 없음"

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
L["RESTOCKER_PROFILE_LABEL"] = "목록"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"이 캐릭터가 사용할 보충 목록을 다른 목록으로 바꾸거나 새 목록을 시작합니다."
L["RESTOCKER_USED_BY"] = "사용 중: %s"
L["RESTOCKER_MANAGE"] = "목록 관리"
L["RESTOCKER_MANAGE_TOOLTIP"] =
	"새 목록을 시작하거나, 이 목록을 복사하거나 이름을 바꾸거나 삭제할 수 있습니다."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "새 목록"
L["RESTOCKER_MANAGE_COPY"] = "이 목록을 새 목록으로 복사"
L["RESTOCKER_RENAME_PROFILE"] = "이 목록 이름 바꾸기"
L["RESTOCKER_MANAGE_DELETE"] = "이 목록 삭제"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 복사본"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "이름 바꾸기"
L["RESTOCKER_RENAME_TOOLTIP"] =
	"이 목록을 사용하는 모든 캐릭터에서 이 목록의 이름을 바꿉니다."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "이 목록을 정말 삭제하시겠습니까?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s도 이 목록을 사용 중이며, 다음 접속 시 같은 이름의 빈 목록으로 시작하게 됩니다."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s도 이 목록을 사용 중이며, 다음 접속 시 각자 같은 이름의 빈 목록으로 시작하게 됩니다."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "이 캐릭터는 %s 목록으로 전환됩니다."
L["RESTOCKER_DELETE_LIST_LAST"] =
	"남은 목록이 이것뿐이므로, 이 캐릭터는 새로운 빈 목록으로 시작합니다."
L["RESTOCKER_DELETE_LIST_FINAL"] = "되돌릴 수 없습니다."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "레벨에 맞춰 업그레이드"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"레벨이 오르면 Good to Go가 음식, 물, 탄약, 독, 물약, 직업 재료를 더 좋은 아이템으로 업그레이드하도록 허용합니다."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "업그레이드"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "아이템"
L["RESTOCKER_COLUMN_WITHDRAW"] = "꺼내기"
L["RESTOCKER_COLUMN_DEPOSIT"] = "보관"
L["RESTOCKER_COLUMN_REPUTATION"] = "평판"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "유지"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "열 제목으로 표시된 모든 아이템에 이 설정을 적용합니다."
L["RESTOCKER_BULK_ON"] = "표시된 아이템 %d개 켜기"
L["RESTOCKER_BULK_OFF"] = "표시된 아이템 %d개 끄기"

L["RESTOCKER_GROUP_OTHER"] = "미분류"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "신규"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "모든 아이템"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "아직 이 목록에 아무것도 없습니다"
L["RESTOCKER_EMPTY_BODY"] =
	"음식, 물, 직업 재료 같은 기본 물품을 고르거나, 위 메뉴에서 가방에 있는 아이템을 무엇이든 추가하세요. 이 목록에 있는 아이템은 자동으로 계속 채워지거나 은행에 보관되므로 가방이 깔끔하게 유지됩니다."
L["RESTOCKER_EMPTY_DROP_HINT"] = "이 창의 아무 곳에나 아이템을 끌어다 놓아도 추가됩니다."
L["RESTOCKER_NO_MATCH_FILTER"] = "이 목록에 필터와 일치하는 항목이 없습니다."
L["RESTOCKER_NO_MATCH_GROUP"] = "이 분류에 남은 항목이 없습니다."

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
L["RESTOCKER_NO_ORDERS"] = "미완료 보충 주문이 없습니다."
L["RESTOCKER_REPORT_MORE"] = "그 외 %d건이 더 있습니다."
L["RESTOCKER_REMOVED_ITEM"] = "제거됨: %s"
L["RESTOCKER_UNDO"] = "되돌리기"
L["RESTOCKER_UNDO_TOOLTIP"] = "목록에 이 아이템 다시 추가"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "보충 목록에서 이 아이템 제거"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "목록 위쪽에서 되돌릴 수 있습니다."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "가방에 유지"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"가방에 유지할 개수입니다. 가방에 이보다 적게 있으면 숫자가 노란색이 되며, 보관이 켜진 상태에서 0이면 전부 은행으로 보냅니다."
L["RESTOCKER_BUY_LABEL"] = "구매"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "상인에게서 구매"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "상인 창이 열려 있을 때 상인에게서 필요한 수량을 구매합니다."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "여분"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "여분 구매"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"상인이 가진 이 아이템의 한정 재고, 즉 조금씩 천천히 다시 채워지는 상품을 유지 개수를 넘더라도 모두 구매합니다."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "은행에 보관"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"은행이 열려 있을 때 초과분을 은행에 보관하며, 유지 열이 0이면 전부 보관합니다."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "은행에서 꺼내기"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "은행이 열려 있을 때 필요한 아이템을 은행에서 꺼냅니다."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "필요 평판"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% 할인)"
L["RESTOCKER_REPUTATION_ANY"] = "무관"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "필요한 상인 평판"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Good to Go가 상인에게서 구매하는 데 필요한 평판 단계를 설정하며, 이 평판으로 가격도 할인됩니다: %s 5%%, %s 10%%, %s 15%%, %s 20%%. 대시(-)로 표시되면 어느 상인에게서나 구매합니다."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"이 아이템은 구매가 꺼져 있어 여분으로 구매할 것이 없습니다."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"이 아이템은 구매가 꺼져 있어 평판 단계가 적용되지 않습니다."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "이 아이템에는 업그레이드할 상위 등급이 없습니다."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go로 대체되는 %s을(를) Good to Go가 꺼 두었습니다. 기존 애드온이 더 이상 실행되지 않도록 지금 UI를 다시 불러올까요?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "지금 다시 불러오기"
L["POPUP_REPLACED_LATER"] = "나중에"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "%s 설정을 복사했습니다."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go가 %s에서 설정을 복사했으며, Good to Go로 대체되는 %s은(는) 꺼 두었습니다. 기존 애드온이 더 이상 실행되지 않도록 지금 UI를 다시 불러올까요?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go가 설치되어 있지만 꺼져 있는 %s을(를) 찾았습니다. 설정을 가져올까요? 기존 애드온을 다시 켜고 UI를 다시 불러온 다음, 기존 애드온을 다시 끌 수 있도록 한 번 더 다시 불러오기를 제안합니다."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go가 설치되어 있지만 꺼져 있는 %s을(를) 찾았습니다. 설정과 보충 목록을 가져올까요? 기존 애드온을 다시 켜고 UI를 다시 불러온 다음, 기존 애드온을 다시 끌 수 있도록 한 번 더 다시 불러오기를 제안합니다."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "가져오기"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "괜찮습니다"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "그룹 버프"
L["RANK_WATCH_TRACKED_HEADER"] = "알릴 주문 레벨"
L["TRACKED_ITEM_PENDING"] = "아이템 #%d"
L["TRACKED_SPELL_PENDING"] = "주문 #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] =
	"켜기 전에 미리 들어 볼 수 있도록 효과음을 재생합니다."

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "버프 당번"
L["BUFF_DUTY_DESCRIPTION"] =
	"내 버프가 빠진 사람을 보여 줍니다. 아이콘을 클릭하면 시전합니다."
L["BUFF_DUTY_ENABLE"] = "버프 당번 활성화"
L["BUFF_DUTY_NO_BUFFS"] =
	"당신의 직업에는 이 목록에 있는 버프가 없으므로 이 캐릭터에서는 창이 표시되지 않습니다."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "표시 조건"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "창이 나타날 때를 선택합니다."
L["BUFF_DUTY_WHEN_NONE"] = "아무것도 체크되지 않아 창이 표시되지 않습니다."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"이곳에서는 버프 당번이 숨겨집니다. 이 지역에서는 게임이 애드온에 버프를 보여 주지 않아 누구에게 버프가 없는지 알 수 없습니다."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"창을 표시할 곳을 정합니다: 어디서나, 또는 던전이나 공격대 같은 인스턴스 안에서만."
L["BUFF_DUTY_WHERE_ALWAYS"] = "어디서나"
L["BUFF_DUTY_WHERE_INSTANCE"] = "인스턴스 안"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "이 직업들로 플레이할 때 창을 표시합니다."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "이 직업으로 플레이할 때 창을 표시합니다."
L["BUFF_DUTY_HEADER"] = "창"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] =
	"창을 놓아 둔 자리에 두거나, 전투 중에는 방해되지 않게 치워 둡니다."
L["BUFF_DUTY_LOCK"] = "창 잠금"
L["BUFF_DUTY_LOCK_DESCRIPTION"] =
	"창이 움직이지 않도록 고정합니다. 잠금을 해제하면 배경을 끌어서 옮길 수 있습니다."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "전투 중 숨기기"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"전투 중에는 창을 숨깁니다. 전투 중에는 목록을 갱신할 수 없으므로, 창을 표시해 두면 전투가 끝날 때까지 마지막 상태가 유지됩니다."
L["BUFF_DUTY_SHOW_HEADER"] = "창에 표시"
L["BUFF_DUTY_SHOW_DESCRIPTION"] = "자신의 버프, 버프를 준 낯선 사람, 대상을 창에 추가합니다."
L["BUFF_DUTY_FAVOR_ENABLE"] = "보답하기"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"최근 당신에게 버프를 준 낯선 사람과 그들에게 돌려줄 수 있는 버프를 보여 줍니다. 아이콘을 우클릭하면 해당 플레이어를 목록에서 제외합니다."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] =
	"낯선 사람이 마지막 버프 후 목록에 남아 있는 시간을 설정합니다."
L["BUFF_DUTY_TARGET_ENABLE"] = "내 대상"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"대상이 그룹 외부의 플레이어이고 당신이 줄 수 있는 버프가 빠져 있으면 대상을 보여 줍니다."
L["BUFF_DUTY_ASK_OTHERS"] = "다른 직업에게 버프 요청"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"파티에 없는 공격대 버프를 누락된 파티 버프 항목에 표시하고, 각 버프가 필요한 인원 수도 보여 줍니다. 좌클릭하면 파티에 요청하고, 우클릭하면 그 버프를 걸 수 있는 플레이어에게 귓속말을 보냅니다."
L["BUFF_DUTY_REFRESH"] = "갱신 기준 시간"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"버프의 남은 시간이 얼마 이하가 되면 누락으로 간주할지 설정하여, 버프가 사라지기 전에 다시 걸 수 있게 합니다. 지속시간이 이 값 이하인 버프는 사라진 뒤에만 누락으로 간주합니다."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "방어 전담으로 간주"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"자신의 역할이 없는 대상 중 누가 방어 전담에게 제공하는 버프(예: 가시)를 받을지 정합니다."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"이 직업의 플레이어를 언제 방어 전담으로 간주할지 설정합니다. 플레이어에게 방어 전담이나 치유 전담 역할이 있으면 항상 그 역할이 우선합니다."
L["BUFF_DUTY_TANKS_PETS"] = "소환수"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"소환수를 언제 방어 전담으로 간주할지 설정합니다. 소환수는 모두에게 제공하는 버프도 받습니다."
L["BUFF_DUTY_TANKS_NEVER"] = "안 함"
L["BUFF_DUTY_TANKS_SOLO"] = "혼자일 때"
L["BUFF_DUTY_TANKS_ALWAYS"] = "항상"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "끄기"
L["BUFF_DUTY_AUDIENCE_TANK"] = "방어 전담"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "치유 전담"
L["BUFF_DUTY_AUDIENCE_ALL"] = "모두"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "%s을(를) 제공할 대상을 설정합니다."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"각 버프를 누구에게 제공할지 선택합니다. 방어 전담과 치유 전담은 그룹 역할을 따르지만, 공격대에서는 %s(으)로 지정된 플레이어만 방어 전담으로 간주합니다. 역할이 없으면 공격 전담으로 간주합니다. 단, 아래 방어 전담으로 간주에서 다르게 설정했다면 그 설정을 따릅니다."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "자기 버프"
L["BUFF_DUTY_SELF_DESCRIPTION"] = "자신의 버프로, 창 맨 위에 고정됩니다."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "상 중 하나면 충분"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "갑옷 중 하나면 충분"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "오라 중 하나면 충분"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "보호막 중 하나면 충분"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "갑옷 중 하나면 충분"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "두 악마 버프 중 하나면 충분"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "끄기"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "없을 때"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "%s 미만"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"%s을(를) 언제 표시할지 설정합니다. 표시 안 함, 사라졌을 때, 남은 시간이 이 값보다 적을 때 중에서 선택합니다."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "무기 버프"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"각 무기에 무엇을 유지할지 선택하세요. 가방에 있고 무기에 맞으면, 없거나 곧 끝날 때 창에 표시됩니다."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "다시 적용"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"무기 버프를 다시 제공할 때를 설정합니다. 사라졌을 때, 남은 시간이 이 값보다 적을 때 중에서 선택합니다."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "오일"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "숫돌"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "미끼"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"%s을(를) %s 무기용으로 제공합니다. 선택한 항목이 무기에 하나도 없으면, 가지고 있는 항목을 각각 제공합니다."
L["BUFF_DUTY_SELF_ENABLE"] = "내 자기 버프"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"갑옷 주문이나 내면의 열정처럼 자신에게만 걸 수 있는 버프가 없거나 곧 끝날 때 창 맨 위에 표시합니다. 어떤 버프를 표시할지는 자기 버프에서 고르세요."
L["BUFF_DUTY_WEAPON_ENABLE"] = "내 무기 버프"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"무기에 없거나 곧 끝나는 독, 무기 강화, 오일, 숫돌, 미끼를 창 맨 위에 자기 버프와 함께 표시합니다. 클릭하면 적용합니다. 표시할 항목은 무기 버프에서 고르세요."

-- The window itself
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "누락된 자기 버프"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "누락된 파티 버프"
L["BUFF_DUTY_FAVOR_HEADER"] = "보답하기"
L["BUFF_DUTY_TARGET_HEADER"] = "대상"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "%s에게 시전합니다."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "%s 무기에 적용합니다."
L["BUFF_DUTY_TOOLTIP_USE"] =
	"파티에 영혼석을 지닌 사람이 없습니다. %s에게 영혼석을 사용합니다."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "파티에 영혼석을 지닌 사람이 없습니다. 영혼석을 만듭니다."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "%s와(과) 그 파티에게 시전합니다."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "%s을(를) 대상으로 지정하고 시전합니다."
-- A Party Buffs icon's tooltip, its click hints: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "%s에 버프 요청"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "시전 가능한 플레이어에게 귓속말"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s 님에게 %s 버프가 없습니다."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s 님에게 %s 버프가 없습니다."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d명에게 %s 버프가 없습니다."
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"버프 당번이 다음 접속이나 재시작 전까지 숨겨졌습니다. 지금 다시 보려면 미니맵 버튼을 Shift + 좌클릭하세요. %1$s 직업에서 계속 꺼 두려면 %4$s 설정의 %3$s에서 %2$s의 체크를 해제하세요."

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "버프 버튼"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "%s님이 사거리 안에 들어오기를 기다리는 중입니다."
L["BUFF_KEY_DONE"] = "더 걸 버프가 없습니다."
L["BUFF_KEY_OFF"] = "버프 당번이 꺼져 있습니다."
--[[
    The Buff Duty window's last line while the Buff Button has no key: the Buff
    Button's name (BUFF_KEY), the root panel's Key Bindings header
    (OPTIONS_KEY_BINDINGS_HEADER), then the options command.
]]
L["BUFF_DUTY_KEY_HINT"] =
	"알고 계셨나요? %s에 단축키를 지정하면 누를 때마다 여기 있는 다음 버프를 겁니다. 설정은 %s 항목(%s)에서 할 수 있습니다."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "배우지 않음"
L["SECTION_CONSUMABLES"] = "GtG 소모품"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "매크로 내용"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "동적 레벨"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"동적 레벨은 우호적인 플레이어의 레벨에 맞춰지며, 전투 중이 아닐 때만 갱신됩니다."
L["MENU_CAST_AT_CURSOR"] = "커서 위치에 시전"
L["MENU_TARGET_NEAREST_ENEMY"] = "가장 가까운 적 대상 지정"
L["MENU_TARGET_NEAREST_FRIEND"] = "가장 가까운 아군 대상 지정"
L["MENU_CAST_IF_SUMMONED"] = "소환수가 있으면 %s 시전"
L["MENU_NEVER_TURN_OFF"] = "끄지 않기"
L["MENU_LEAVE_FORM_BEFORE"] = "시전 전에 변신 해제"
L["MENU_RIGHT_CLICK_FOR"] = "우클릭 시 %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "우클릭 시 그룹 버전"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "모든 %s에 적용"
L["MENU_ONCE_PER_COMBAT"] = "전투당 한 번 시전"
L["MENU_ONCE_PER_TARGET"] = "대상당 한 번 시전"
L["MENU_HIDE_ERRORS"] = "오류 숨기기"
L["MENU_MUTE_ERRORS"] = "오류 음소거"
L["MENU_SWITCH_TO"] = "%s(으)로 전환"
L["MENU_START_AUTO_ATTACK"] = "자동 공격 시작"
L["MENU_STOP_ATTACK"] = "공격 중지"
L["MENU_START_AUTO_SHOT"] = "자동 사격 시작"
L["MENU_START_PET_ATTACK"] = "소환수 공격 시작"
L["MENU_START_WAND"] = "마법봉 시작"
L["MENU_STOP_CASTING"] = "시전 중지"
L["MENU_STOP_CASTING_NOTE"] =
	"차단이나 해제처럼 기다릴 수 없는 주문에는 시전 중지를 사용하세요."
L["MENU_STOP_IF_CHANNELING"] = "정신 집중 중 안 함"
L["MENU_STOP_IF_STEALTHED"] = "은신 중 안 함"
L["MENU_DUPLICATE"] = "복제"
L["MENU_DELETE"] = "삭제"
L["MENU_DELETE_USED_ONE"] = "삭제 (단축바 1개에서 사용 중)"
L["MENU_DELETE_USED"] = "삭제 (단축바 %d개에서 사용 중)"
L["MENU_DELETE_DESCRIPTION"] =
	"이 매크로를 매크로 목록에서 삭제하여 행동 단축바에서도 제거하고, 모든 옵션을 초기화합니다. 페이지에서 클릭하거나 끌어다 놓으면 다시 만들 수 있습니다."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"이 복사본을 페이지에서 제거하고 매크로 목록에서 삭제하여 행동 단축바에서도 제거합니다."
L["MENU_DELETE_CONFIRM"] =
	"%s을(를) 삭제할까요? 행동 단축바에서 제거되고 옵션이 초기화됩니다."
L["MENU_GROUP_RANK"] = "레벨"
L["MENU_GROUP_WHEN"] = "시점"
L["MENU_GROUP_FIRST"] = "먼저"
L["MENU_GROUP_THEN"] = "그다음"
L["MENU_GROUP_ERRORS"] = "오류 메시지"
L["MENU_GROUP_GROUPED"] = "묶음 주문"
L["MENU_GROUP_TARGET"] = "대상"
L["MENU_PRIORITY_1"] = "1순위"
L["MENU_PRIORITY_2"] = "2순위"
L["MENU_PRIORITY_3"] = "3순위"
L["MENU_PRIORITY_DESCRIPTION"] =
	"매크로가 차례로 시도할 대상입니다. 주문을 받을 수 없는 대상은 건너뛰며, 아무도 받을 수 없으면 일반 주문처럼 시전합니다."
L["MENU_UNIT_NONE"] = "없음"
L["MENU_UNIT_NONE_DESCRIPTION"] = "목록을 여기서 끝냅니다."
L["MENU_UNIT_TARGET"] = "대상"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "대상이 주문을 받을 수 있으면 대상에게 시전합니다."
L["MENU_UNIT_SELF"] = "자신"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"자신에게 시전합니다. 자신은 항상 주문을 받을 수 있으므로, 자신 뒤의 항목은 시도되지 않습니다."
L["MENU_UNIT_PET"] = "소환수"
L["MENU_UNIT_PET_DESCRIPTION"] =
	"소환수를 불러냈고 소환수가 주문을 받을 수 있으면 소환수에게 시전합니다."
L["MENU_UNIT_FOCUS"] = "주시 대상"
L["MENU_UNIT_FOCUS_DESCRIPTION"] =
	"주시 대상이 있고 주시 대상이 주문을 받을 수 있으면 주시 대상에게 시전합니다."
L["MENU_UNIT_TARGETS_TARGET"] = "대상의 대상"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"대상의 대상이 주문을 받을 수 있으면 대상의 대상에게 시전합니다. 예를 들어 내가 대상으로 잡은 적이 공격하고 있는 방어 전담이 해당됩니다."
L["MENU_UNIT_MOUSEOVER"] = "마우스오버"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"필드나 유닛 프레임에서 커서 아래에 있는 대상이 주문을 받을 수 있으면 그 대상에게 시전합니다."
L["MENU_OPTIONS_COUNT"] = "옵션 %d개"
L["MENU_ENABLED"] = "켜짐"
L["MENU_HIGHEST"] = "최고 레벨"
L["MENU_HIGHEST_DESCRIPTION"] = "알고 있는 가장 높은 레벨로 시전합니다."
L["MENU_RANK_DYNAMIC"] = "동적 레벨"
L["MENU_FIXED_RANK_DESCRIPTION"] = "캐릭터 레벨과 관계없이 항상 %s(으)로 시전합니다."
L["MENU_ANY_TIME"] = "항상"
L["MENU_ANY_TIME_DESCRIPTION"] = "전투 중이든 아니든 시전합니다."
L["MENU_IN_COMBAT"] = "전투 중"
L["MENU_IN_COMBAT_DESCRIPTION"] =
	"전투 중에만 시전합니다. 전투 중이 아닐 때는 아이템을 포함해 매크로가 아무것도 하지 않습니다."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"전투 중이 아닐 때만 시전합니다. 전투 중에는 아이템을 포함해 매크로가 아무것도 하지 않습니다."
L["MENU_EVERY_PRESS"] = "누를 때마다"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "누를 때마다 시전합니다."
L["MENU_GROUP_VERSION_DESCRIPTION"] =
	"우클릭하면 %s을(를) 시전합니다. 좌클릭하면 그대로 %s을(를) 시전합니다."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"매크로가 %s을(를) 시전할 수 있게 합니다. 여기서 체크한 주문 중 가장 나중에 배운 주문을 시전하므로, 주문을 배울수록 상위 주문으로 바뀝니다."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] =
	"아직 배우지 않았습니다. 지금 체크해 두면 배우는 즉시 매크로에 반영됩니다."
L["MENU_PET_DESCRIPTION"] =
	"%s을(를) 불러낸 동안에는 다시 소환하는 대신 매크로가 %s을(를) 시전합니다."
L["MENU_STANCE_DESCRIPTION"] = "이미 그 상태가 아니라면 먼저 %s(으)로 전환합니다."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"시전 전에 사용합니다. 아이템은 체크한 순서대로 사용되며, 각 아이템 뒤의 숫자가 그 순서를 나타냅니다."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "%s 사용"
L["MENU_ADD_FOCUS"] = "주시 대상용 복사본 추가"
L["MENU_REMOVE_FOCUS"] = "주시 대상용 복사본 제거"
L["MENU_FOCUS_DESCRIPTION"] =
	"주시 대상에게, 그다음에는 대상에게 시전하는 두 번째 매크로를 페이지에 추가합니다."
L["MENU_REMOVE_FOCUS_DESCRIPTION"] =
	"주시 대상용 복사본을 페이지에서 제거하고 그 매크로를 삭제합니다."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"이 옵션으로 시작하는 이 매크로의 복사본을 페이지에 하나 더 추가하여, 다르게 설정할 수 있게 합니다."
L["MENU_MAKE_DEFAULT"] = "%s의 기본값으로 설정"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"%s 아래에서 직접 설정하지 않은 모든 매크로가 이 매크로의 옵션으로 시작합니다."
L["MENU_DEFAULT_SET"] = "이제 %s 매크로가 이 옵션으로 시작합니다."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "조건"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"향상된 마법책 창 옆에 조건 패널을 엽니다. 이 패널에서는 Shift를 누르고 있거나 특성 2일 때처럼 조건이 맞으면 매크로가 다른 주문을 시전하게 할 수 있습니다."
L["MENU_RIGHT_CLICK_TAKEN"] =
	"조건 중 하나가 우클릭을 사용하고 있습니다. 이 기능을 켜려면 그 조건을 제거하세요."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "조건"
L["CONDITIONALS_HINT"] = "위에서부터 차례로 확인하며, 처음 일치하는 줄을 시전합니다."
L["CONDITIONALS_OTHERWISE"] = "그 외"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "그리고"
L["CONDITIONALS_AND_MENU"] = "두 번째 조건 추가"
L["CONDITIONALS_AND_DESCRIPTION"] =
	"두 번째 조건을 추가합니다. 두 조건이 모두 일치할 때만 이 줄을 시전합니다."
L["CONDITIONALS_DROP_SECOND"] = "이 조건 제거"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "이 줄이 다시 첫 번째 조건만 확인합니다."
L["CONDITIONALS_ADD"] = "+ 조건 추가"
L["CONDITIONALS_ADD_DESCRIPTION"] =
	"맨 아래에 줄을 추가합니다. 조건을 고른 다음 시전할 주문을 고르세요."
L["CONDITIONALS_ADD_LIMIT"] =
	"최대 %d줄까지 추가할 수 있습니다. 줄마다 매크로 내용이 늘어나며, 매크로 내용은 255바이트까지 담을 수 있습니다."
L["CONDITIONALS_PICK_SPELL"] = "주문 고르기"
L["CONDITIONALS_PICKING"] = "페이지에서 주문 클릭"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"여기를 클릭한 다음 페이지에서 주문을 클릭하면 이 줄에서 그 주문을 시전합니다. 또는 페이지에서 주문을 이 칸으로 끌어다 놓으세요."
L["CONDITIONALS_PICK_BANNER"] = "사용할 주문을 클릭하세요. Esc나 우클릭으로 취소합니다."
L["CONDITIONALS_CANNOT_PICK"] = "배운 주문만 조건으로 시전할 수 있습니다."
L["CONDITIONALS_EMPTY"] =
	"아직 조건이 없습니다. 조건을 추가하면 Shift를 누르고 있을 때, 전투 중일 때 등에 다른 주문을 시전할 수 있습니다."
L["CONDITIONALS_SHADOWED"] =
	"시전되지 않음: 이 줄이 일치할 때마다 위의 %d번 줄도 일치하므로 그 줄이 먼저 시전됩니다."
L["CONDITIONALS_KEY_DRAG"] = "여기로 주문 끌어 놓기"
L["CONDITIONALS_ACTION_DROP"] = "이 줄에서 시전"
L["CONDITIONALS_ACTION_PICK"] = "페이지에서 고르기"
L["CONDITIONALS_ACTION_USE"] = "조건에 사용"
L["CONDITIONALS_ACTION_CANCEL"] = "고르기 취소"
L["CONDITIONALS_REMOVE"] = "제거"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "이 줄을 제거합니다."
L["CONDITIONALS_REORDER"] = "순서 변경"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"다른 줄 위로 끌어다 놓으면 이 줄이 그 자리로 옮겨집니다. 처음 일치하는 줄이 시전됩니다."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Shift 누름"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "매크로를 누를 때 Shift를 누르고 있으면 일치합니다."
L["CONDITION_CTRL"] = "Ctrl 누름"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "매크로를 누를 때 Ctrl을 누르고 있으면 일치합니다."
L["CONDITION_ALT"] = "Alt 누름"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "매크로를 누를 때 Alt를 누르고 있으면 일치합니다."
L["CONDITION_RIGHT_CLICK"] = "우클릭"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "행동 단축바의 매크로를 우클릭하면 일치합니다."
L["CONDITION_IN_COMBAT"] = "전투 중"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "전투 중일 때 일치합니다."
L["CONDITION_OUT_OF_COMBAT"] = "비전투"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "전투 중이 아닐 때 일치합니다."
L["CONDITION_SPEC_1"] = "특성 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "첫 번째 특성이 활성화되어 있으면 일치합니다."
L["CONDITION_SPEC_2"] = "특성 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "두 번째 특성이 활성화되어 있으면 일치합니다."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (현재)"
L["CONDITION_COMBAT_BLOCKED"] =
	"시점이 전투 중 또는 비전투로 설정된 동안에는 사용할 수 없습니다. 매크로가 이미 반대 상황에서는 아무것도 하지 않으므로, 이 조건은 항상 일치하거나 절대 일치하지 않습니다."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	'묶음 주문에서 "우클릭 시 %s"이(가) 켜져 있어 이미 우클릭을 사용하고 있으므로 사용할 수 없습니다. 여기서 우클릭을 사용하려면 그 설정을 끄세요.'
L["SUBTEXT_CONDITIONALS_ONE"] = "조건 1개"
L["SUBTEXT_CONDITIONALS"] = "조건 %d개"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "시전 순서"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"향상된 마법책 창 옆에 시전 순서 패널을 엽니다. 이 패널에서는 매크로를 누를 때마다 부패, 고통의 저주, 제물처럼 다음 주문을 순서대로 시전하게 할 수 있습니다."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d단계"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "시전 순서"
L["CAST_SEQUENCE_HINT"] =
	"누를 때마다 다음 단계를 시전합니다. 실패한 단계는 다음에 누를 때 다시 시도합니다."
L["CAST_SEQUENCE_FIRST"] = "첫 단계"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "매크로 자체의 주문이 항상 처음입니다."
L["CAST_SEQUENCE_ADD"] = "+ 단계 추가"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] =
	"맨 끝에 단계를 추가합니다. 그런 다음 시전할 주문을 고르세요."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"매크로 자체의 주문 뒤로 최대 %d단계까지 추가할 수 있습니다. 단계마다 매크로 내용이 늘어나며, 매크로 내용은 255바이트까지 담을 수 있습니다."
L["CAST_SEQUENCE_CANNOT_PICK"] =
	"배운 주문만 시전 순서의 단계가 될 수 있으며, 사격은 제외됩니다."
L["CAST_SEQUENCE_ACTION_DROP"] = "이 단계에서 시전"
L["CAST_SEQUENCE_ACTION_USE"] = "시전 순서에 사용"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "이 단계를 제거합니다."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] =
	"다른 단계 위로 끌어다 놓으면 이 단계가 그 자리로 옮겨집니다."
L["CAST_SEQUENCE_END"] = "마지막 단계 이후"
L["CAST_SEQUENCE_END_LOOP"] = "처음부터 다시"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"다음에 누르면 매크로 자체의 주문을 다시 시전하며, 순서가 계속 반복됩니다."
L["CAST_SEQUENCE_END_STOP"] = "정지 (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"아무도 모르는 주문인 NULL에서 끝나므로, 초기화로 순서가 처음부터 다시 시작될 때까지는 더 눌러도 아무것도 시전하지 않습니다."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "정지"
L["CAST_SEQUENCE_RESET"] = "처음부터 다시 시작 조건"
L["CAST_SEQUENCE_RESET_NEVER"] = "안 함"
L["CAST_SEQUENCE_RESET_TARGET"] = "대상 변경 시"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "대상을 바꾸면 순서를 첫 단계부터 다시 시작합니다."
L["CAST_SEQUENCE_RESET_COMBAT"] = "전투 종료 시"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] =
	"전투에서 벗어나면 순서를 첫 단계부터 다시 시작합니다."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Shift 누름"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl 누름"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt 누름"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"이 키를 누른 채 매크로를 누르면 순서를 처음부터 다시 시작하여 첫 단계를 시전합니다."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "입력 없음 시간(초)"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"매크로를 이 시간 동안 누르지 않으면 순서를 처음부터 다시 시작합니다."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "끄기"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d초 동안 입력 없음"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"완전히 정지합니다: 처음부터 다시 시작할 조건이 없으므로, 매크로가 바뀌거나 UI를 다시 불러올 때까지 순서가 NULL에 머무릅니다. 처음부터 다시 시작 조건에서 초기화 조건을 고르세요."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'"소환수가 있으면 시전"이 %s을(를) 시전하는 동안에는 대기합니다. 이 옵션은 자체 시전 줄을 쓰기 때문입니다. 시전 순서를 사용하려면 그 옵션을 끄세요.'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"여기를 클릭한 다음 페이지에서 주문을 클릭하면 이 단계에서 그 주문을 시전합니다. 또는 페이지에서 주문을 이 칸으로 끌어다 놓으세요."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d단계 순서"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "모든 주문 레벨 표시"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "묶음 주문 표시"
L["SETTINGS_SHOW_UNLEARNED"] = "배우지 않은 주문 표시"
L["SETTINGS_MARK_ALL_PLACED"] = "모든 주문을 배치됨으로 표시"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"단축바에 있든 없든 이 페이지의 모든 매크로가 더 이상 빛나지 않습니다. 나중에 배우는 주문은 배치할 때까지 계속 빛납니다."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "배치하지 않은 주문 강조"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	'단축바에 없는 모든 매크로를 빛나게 합니다. 끄면 "모든 주문을 배치됨으로 표시" 버튼처럼 모두 배치된 것으로 표시합니다.'
L["SORT_BY_CATEGORY"] = "분류별 정렬"
L["SORT_BY_SCHOOL"] = "계열별 정렬"
L["SORT_DESCRIPTION"] =
	"페이지의 매크로를 분류(공격, 치유, 방어 쿨기처럼 각 주문의 용도) 또는 계열(주문이 속한 마법책 탭)별로 묶습니다."
L["CATEGORY_ATTACKS"] = "공격"
L["CATEGORY_FINISHERS"] = "마무리 일격"
L["CATEGORY_CROWD_CONTROL"] = "군중 제어"
L["CATEGORY_HYBRID"] = "복합"
L["CATEGORY_HEALS"] = "치유"
L["CATEGORY_BUFFS"] = "버프"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "공격 쿨기"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "방어 쿨기"
L["CATEGORY_SELF_BUFFS"] = "자기 버프"
L["CATEGORY_SHOCKS"] = "충격"
L["CATEGORY_TRAPS"] = "덫"
L["CATEGORY_TOTEMS"] = "토템"
L["CATEGORY_SEALS"] = "문장"
L["CATEGORY_BLESSINGS"] = "축복"
L["CATEGORY_CURSES"] = "저주"
L["CATEGORY_PETS"] = "소환수"
L["CATEGORY_TELEPORTS"] = "순간이동 및 차원문"
L["CATEGORY_UTILITY"] = "보조"
L["CATEGORY_THREAT"] = "도발 및 위협"
L["SUBCATEGORY_BASIC_ATTACKS"] = "기본 공격"
L["CATEGORY_STANCES"] = "태세"
L["CATEGORY_FORMS"] = "변신"
L["CATEGORY_AURAS"] = "오라"
L["CATEGORY_ASPECTS"] = "상"
L["CATEGORY_RACIALS"] = "종족 특성"
L["CATEGORY_TRACKING"] = "추적"
L["CATEGORY_PROFESSIONS"] = "전문 기술"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "주시 대상"
L["SUBTEXT_PET"] = "소환수"
L["SUBTEXT_CURSOR"] = "커서"
L["SUBTEXT_STANCE"] = "태세"
L["SUBTEXT_USE_ITEMS"] = "아이템 사용"
L["SUBTEXT_PET_ATTACK"] = "소환수 공격"
L["SUBTEXT_DYNAMIC_RANK"] = "동적 레벨"
L["SUBTEXT_DYNAMIC_ITEM"] = "동적 아이템"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "동적 레벨, 동적 아이템"
L["SUBTEXT_MAX_RANK"] = "최고 레벨"
L["SUBTEXT_TARGET_ENEMY"] = "가까운 적"
L["SUBTEXT_TARGET_FRIEND"] = "가까운 아군"
L["SUBTEXT_TARGET_PRIORITY"] = "대상"
L["SUBTEXT_GROUPED_SPELLS"] = "묶음"
L["SUBTEXT_ONCE_PER_COMBAT"] = "전투당 1회"
L["SUBTEXT_ONCE_PER_TARGET"] = "대상당 1회"
L["SUBTEXT_COMBAT_ONLY"] = "전투 중만"
L["SUBTEXT_NO_COMBAT"] = "비전투"
L["SUBTEXT_LEAVE_FORM"] = "변신 해제"
L["SUBTEXT_NO_TOGGLE"] = "끄지 않기"
L["SUBTEXT_WAND"] = "마법봉"
L["SUBTEXT_START_ATTACK"] = "자동 공격"
L["SUBTEXT_STOP_ATTACK"] = "공격 중지"
L["SUBTEXT_STOP_CASTING"] = "시전 중지"
L["SUBTEXT_STOP_IF_CHANNELING"] = "정신 집중 중 안 함"
L["SUBTEXT_STOP_IF_STEALTHED"] = "은신 중 안 함"
L["SUBTEXT_HIDE_ERRORS"] = "오류 숨김"
L["SUBTEXT_MUTE_ERRORS"] = "오류 음소거"
L["SUBTEXT_OPTIONS_COUNT"] = "옵션 %d개"
L["SUBTEXT_TOO_LONG"] = "너무 김"
L["SUBTEXT_LEARN_LEVEL"] = "%d레벨"
L["SUBTEXT_TALENT"] = "특성"
L["SUBTEXT_LEARN_RANK"] = "%s 배우기"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "소환수에게 가르치기"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "아직 배우지 않음"
L["TOOLTIP_LEARN_LEVEL"] = "직업 상급자에게 %d레벨에 배울 수 있습니다."
L["TOOLTIP_LEARN_TALENT"] = "특성으로 배웁니다."
L["TOOLTIP_NOT_ON_BARS"] = "행동 단축바에 없음"
L["TOOLTIP_TOO_LONG"] = "너무 김: %d / %d바이트. 옵션을 하나 꺼서 줄이세요."
L["TOOLTIP_OPTIONS_ON"] = "켜진 옵션: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "클릭 또는 드래그"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "행동 단축바에 배치"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "우클릭"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "매크로 옵션"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "휠클릭"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "매크로 옵션 초기화"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "%s의 모든 매크로 초기화"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s의 옵션이 기본값으로 돌아갔습니다."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "%s의 모든 매크로가 기본 옵션으로 돌아갔습니다."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"여기 있는 각 주문에 설정한 옵션을 지워, 모두 다시 기본값을 따르게 합니다. 주시 대상용 복사본과 복제본은 그대로 남습니다."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"%s의 모든 주문에 설정한 옵션을 초기화할까요? 각 주문이 다시 기본값을 따릅니다."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s 매크로"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "직업 주문을 원클릭 매크로로 제공합니다."
L["TOOLTIP_KEY_CLICK"] = "클릭"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "향상된 마법책 열기"

-- Page: Layout
L["PAGE_EMPTY"] = "아직 매크로가 없습니다. 직업 상급자를 찾아가 첫 주문을 배우세요."
L["PAGE_NO_MATCHES"] = "필터와 일치하는 매크로가 없습니다."
L["PAGE_FILTER"] = "주문 필터"
L["FILTER_ALL_SCHOOLS"] = "모든 계열"
L["FILTER_ALL_CATEGORIES"] = "모든 분류"
L["PAGE_MACRO_SLOTS"] = "매크로 칸"
L["TOOLTIP_MACRO_SLOTS"] =
	"배치하는 매크로마다 매크로 칸을 하나씩 차지합니다. 캐릭터 칸은 이 캐릭터 전용이며 먼저 채워집니다. 일반 칸은 계정의 모든 캐릭터가 함께 씁니다."
L["PAGE_MACRO_GENERAL"] = "일반"
L["PAGE_MACRO_CHARACTER"] = "캐릭터"
L["PAGE_NO_MATCHES_FOR"] = '"%s"와(과) 일치하는 주문이 없습니다.'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Options for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "%d개 %s 전체 옵션"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"이 분류의 모든 주문에 대해 옵션을 한 번에 켜거나 끕니다. 아직 단축바에 없는 주문은 나중에 배치할 때를 위해 설정을 기억합니다."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(계속)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "다음 배울 주문"
L["WHATS_NEXT_EMPTY"] = "표시할 주문이 없습니다."
L["WHATS_NEXT_ALL_SOURCES"] = "모든 습득처"
L["WHATS_NEXT_ANY_LEVEL"] = "모든 레벨"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LEVEL_UP_SPELLS_PAIR_FORMAT or LEVEL_UP_SPELLS_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), & [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "이제 배울 수 있는 주문: %s"
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "잊지 마세요, 이것도 배울 수 있습니다: %s"
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "이제 소환수가 배울 수 있는 기술: %s"
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "잊지 마세요, 소환수가 이것도 배울 수 있습니다: %s"
L["LEVEL_UP_DEMON_SPELLS"] = "이제 악마가 배울 수 있는 기술: %s"
L["LEVEL_UP_SPELLS_PAIR_FORMAT"] = "%s, %s"
L["LEVEL_UP_SPELLS_LAST_FORMAT"] = "%s, %s"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "지금 배울 수 있음"
L["WHATS_NEXT_STATUS_SOON"] = "곧 배울 수 있음"
L["WHATS_NEXT_STATUS_LATER"] = "아직 배울 수 없음"
L["WHATS_NEXT_STATUS_MISSING"] = "선행 조건 미충족"
L["WHATS_NEXT_STATUS_TALENT"] = "선택하지 않은 특성"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "선택하지 않은 특성 및 룬"
L["WHATS_NEXT_STATUS_KNOWN"] = "배운 주문"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "지금 가능"
L["WHATS_NEXT_SHORT_SOON"] = "곧 가능"
L["WHATS_NEXT_SHORT_LATER"] = "아직 불가"
L["WHATS_NEXT_SHORT_MISSING"] = "다른 주문 필요"
L["WHATS_NEXT_SHORT_TALENT"] = "미선택"
L["WHATS_NEXT_SHORT_KNOWN"] = "배움"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "시작 주문"
L["WHATS_NEXT_SOURCE_TRAINER"] = "상급자"
L["WHATS_NEXT_SOURCE_BOOK"] = "책"
L["WHATS_NEXT_SOURCE_QUEST"] = "퀘스트"
L["WHATS_NEXT_SOURCE_TALENT"] = "특성"
L["WHATS_NEXT_SOURCE_RUNE"] = "룬"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "습득처"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "요구 레벨"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "처음부터 가지고 있는 직업 주문입니다."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "직업 상급자가 가르쳐 줍니다."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "던전이나 공격대에서 얻는 책 같은 아이템으로 배웁니다."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] =
	"직업 퀘스트로 배웁니다. 직업 상급자가 퀘스트를 안내해 줄 수 있습니다."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "특성 포인트를 투자하면 배웁니다."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "룬을 각인하면 배웁니다."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "먼저 %s을(를) 배우세요."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "%s 레벨 목록"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + 클릭"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "대화창에 링크"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "배울 수 있는 순으로 정렬"
L["WHATS_NEXT_SORT_LEVEL"] = "레벨순 정렬"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	'"배울 수 있는 순으로 정렬"은 지금 배울 수 있는 주문을 맨 위에, 이미 아는 주문을 맨 아래에 표시합니다. "레벨순 정렬"은 모든 주문을 배우는 레벨 아래에 표시합니다.'
L["WHATS_NEXT_SHOW_KNOWN"] = "배운 주문 표시"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "이미 배운 주문도 나머지 뒤에 표시합니다."
L["WHATS_NEXT_SHOW_TALENTS"] = "선택하지 않은 특성 표시"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "선택하지 않은 특성 및 룬 표시"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"선택하지 않은 특성 주문도 표시합니다. 이 주문은 상급자가 아니라 특성 포인트를 투자해서 배웁니다."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "소환수 마법책"
L["PET_SPELLBOOK_EMPTY"] = "소환수에게 표시할 주문이 없습니다."
L["PET_SPELLBOOK_NO_PET"] = "소환수가 없습니다. 소환수를 불러내면 주문을 볼 수 있습니다."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "능력"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "지속 효과"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "자동 시전 켜짐"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "자동 시전 꺼짐"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "소환수 다음 배울 기술"
L["WHATS_NEXT_PET_EMPTY"] = "표시할 소환수 기술이 없습니다."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s, %d레벨 %s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "훈련 포인트: %d / %d"
L["WHATS_NEXT_PET_NO_PET"] = "소환수 없음: 야수 조련으로 배운 기술을 표시합니다."
L["WHATS_NEXT_PET_NO_DEMON"] = "악마 없음: 악마를 소환하면 이미 아는 기술을 볼 수 있습니다."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "가르칠 수 있음"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "다른 종류의 기술"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "가르칠 수 있음"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "다른 종류"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "야수 조련사"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "길들이기"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "악마 조련사"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "요구 소환수 레벨"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "훈련 포인트"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"야수 조련사에게 배운 다음, 야수 조련으로 소환수에게 가르치세요."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"이 기술을 아는 야수를 길들이고 기술을 배울 때까지 함께 싸우세요. 그런 다음 야수 조련으로 이 기술을 배울 수 있는 소환수에게 가르치세요."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] =
	"이미 알고 있습니다. 야수 조련으로 소환수에게 가르치세요."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"악마 조련사에게서 마법서를 구매한 다음, 그 기술을 배우는 악마를 소환한 상태에서 사용하세요."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "마법서"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] =
	"가방에 마법서가 있습니다. 이 악마를 소환한 상태에서 사용하세요."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "소환수가 배울 수 없습니다."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "이 기술을 아는 야수"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s (%s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "그 외 %d마리가 더 있습니다."

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	'"배울 수 있는 순으로 정렬"은 소환수가 지금 배울 수 있는 기술을 맨 위에, 이미 아는 기술을 맨 아래에 표시합니다. "레벨순 정렬"은 모든 기술을 필요한 소환수 레벨 아래에 표시합니다.'
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "배운 기술 표시"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"소환수가 이미 아는 기술도 나머지 뒤에 표시합니다. 소환수를 불러내지 않은 사냥꾼은 자신이 배운 기술을 봅니다."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "다른 종류의 기술 표시"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"늑대가 배울 수 없는 살쾡이의 숨기나 다른 악마의 기술처럼, 소환수가 배울 수 없는 기술도 표시합니다."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "단축키 설정"
L["OPTIONS_KEY_SET"] = "단축키 지정"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "Good to Go 전용 항목이 있는 게임의 단축키 설정 목록을 엽니다."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"향상된 마법책을 열고 닫습니다. 마법책에도 전용 탭이 있습니다."
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"전투 중이 아닐 때 누를 때마다 버프 당번 창이 제안하는 다음 버프를 하나씩 시전합니다. 무기 버프는 계속 창에서 클릭해야 합니다. 매크로에서 누르려면 %s을(를) 사용하세요."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "주문 레벨 툴팁"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"모든 능력의 툴팁에 주문 레벨과 각 레벨에 필요한 캐릭터 레벨을 표시합니다: 이미 아는 레벨은 흰색, 지금 배울 수 있는 레벨은 초록색, 앞으로 배울 레벨은 회색입니다. 가장 좋은 레벨을 쓰고 있는지 빠르게 스스로 확인할 수 있어, 언제나 최고의 실력으로 플레이할 수 있습니다. 전투 중에는 레벨이 표시되지 않으므로, 중요한 순간에는 툴팁이 짧게 유지됩니다."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "주문 레벨 툴팁 활성화"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"행동 단축바, 게임의 마법책, 다른 애드온에서 보이는 각 능력의 툴팁에 주문 레벨을 추가합니다. 끄면 이 툴팁은 게임 기본 상태로 표시됩니다. 향상된 마법책 창에는 어느 쪽이든 주문 레벨이 표시됩니다."
L["OPTIONS_DELETE_MACROS_HEADER"] = "매크로 삭제"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"향상된 마법책이 만든 매크로를 삭제하며, 행동 단축바에서도 사라집니다. 직접 만든 매크로는 절대 건드리지 않으며, 페이지에서 클릭하거나 끌어 놓으면 다시 만들어집니다."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "캐릭터 매크로 삭제"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"이 캐릭터의 매크로 탭에서 향상된 마법책의 매크로를 삭제합니다. 다른 캐릭터는 그 캐릭터에서 같은 작업을 할 때까지 매크로를 유지합니다."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"이 캐릭터의 향상된 마법책 매크로를 모두 삭제할까요? 행동 단축바에서도 사라집니다."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "일반 매크로 삭제"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"계정의 모든 캐릭터가 공유하는 일반 매크로 탭에서 향상된 마법책의 매크로를 삭제하므로, 다른 캐릭터도 그곳의 매크로를 잃습니다."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"향상된 마법책의 일반 매크로를 모두 삭제할까요? 계정의 모든 캐릭터가 잃게 되며, 행동 단축바에서도 사라집니다."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"주문마다 알고 있는 하위 레벨의 매크로를 그 주문 뒤에 표시하며, 각 매크로는 항상 해당 레벨로 시전합니다."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"순화와 정화처럼 같은 묶음에 속한, 알고 있는 모든 주문을 표시합니다. 끄면 가장 나중에 배운 주문만 표시되지만, 나머지 매크로도 계속 갱신됩니다."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"아직 배우지 않은 직업 주문을 배우지 않음 항목에 표시하여, 매크로를 미리 배치할 수 있게 합니다."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] =
	"대상 지정 원 없이 커서가 가리키는 곳에 주문을 놓습니다."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] =
	"우호적인 플레이어의 레벨에 맞는 가장 높은 레벨로 시전합니다."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"시전 중인 주문을 먼저 멈춰서 이 주문이 바로 나가게 합니다."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "근접 자동 공격을 먼저 멈춥니다."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"주문을 정신 집중하는 동안에는 아무것도 하지 않아서, 눌러도 정신 집중이 끊기지 않습니다."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"은신 중에는 아무것도 하지 않아서, 눌러도 은신이나 숨기가 풀리지 않습니다."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"현재 변신을 먼저 해제해서 주문을 시전할 수 있게 합니다."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"살아 있는 적을 대상으로 잡고 있지 않으면 가장 가까운 적을 먼저 대상으로 지정합니다."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"살아 있는 아군을 대상으로 잡고 있지 않으면 가장 가까운 아군을 먼저 대상으로 지정합니다."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "소환수도 대상을 공격하게 합니다."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "시전한 뒤 근접 자동 공격을 시작합니다."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "시전한 뒤 자동 사격이나 마법봉을 시작합니다."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] =
	"한 번 시전한 뒤에는 대상이 바뀔 때까지 다시 시전하지 않습니다."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"한 번 시전한 뒤에는 전투가 끝나거나 대상이 바뀔 때까지 다시 시전하지 않습니다."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"매크로를 다시 눌러도 변신이나 상을 끄지 않고 계속 유지합니다."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "매크로가 화면에 남기는 빨간 오류 문구를 지웁니다."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "매크로가 실행되는 동안 오류 소리를 끕니다."
L["KIND_ENEMY"] = "적 대상 주문"
L["KIND_ENEMY_DESCRIPTION"] = "공격이나 약화 효과처럼 적에게 시전하는 주문입니다."
L["KIND_FRIENDLY"] = "아군 대상 주문"
L["KIND_FRIENDLY_DESCRIPTION"] = "치유처럼 아군에게 시전하는 주문입니다."
L["KIND_BUFF"] = "강화 효과"
L["KIND_BUFF_DESCRIPTION"] = "아군에게 오래 지속되는 강화 효과를 거는 주문입니다."
L["KIND_RESURRECT"] = "부활"
L["KIND_RESURRECT_DESCRIPTION"] = "죽은 아군을 되살리기 위해 시전하는 주문입니다."
L["KIND_ANYONE"] = "아군 또는 적 대상 주문"
L["KIND_ANYONE_DESCRIPTION"] = "아군이나 적 모두에게 시전할 수 있는 주문입니다."
L["KIND_GROUND"] = "지면 지정 주문"
L["KIND_GROUND_DESCRIPTION"] = "지면에 배치하는 주문입니다."
L["KIND_FORM"] = "변신, 태세 및 상"
L["KIND_FORM_DESCRIPTION"] = "끄거나 다른 것으로 바꿀 때까지 유지되는 주문입니다."
L["KIND_SELF"] = "자신 및 광역 주문"
L["KIND_SELF_DESCRIPTION"] = "대상 없이 자신이나 주변에 시전하는 주문입니다."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "향상된 마법책 열기/닫기"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "안전을 위해 전투 중에는 단축키 설정 목록을 열 수 없습니다."
L["KEY_BINDINGS_LOCATION"] = "게임 메뉴를 열고 %s, %s 순으로 들어가 Good to Go 항목을 찾으세요."
L["ERROR_MACRO_SLOTS_FULL"] =
	"빈 매크로 칸이 없습니다. /macro에서 매크로를 삭제해 자리를 만드세요."
L["ERROR_MACRO_WINDOW_OPEN"] = "먼저 매크로 창을 닫으세요."
L["CHAT_MACROS_DELETED"] = "삭제한 매크로: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'"%s" 매크로는 옵션을 켠 상태로 %d바이트라서 매크로 최대 길이인 %d바이트를 넘습니다. 옵션을 하나 꺼서 줄이세요.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'"%s" 매크로는 %d바이트로 매크로 최대 길이인 %d바이트를 넘으므로 마지막 줄이 잘립니다.'
