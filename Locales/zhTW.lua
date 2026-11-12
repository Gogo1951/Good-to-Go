local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "zhTW")
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
	"版本 %s。設定（包括停用此訊息的選項）位於 選項 > 插件 > Good to Go。喜歡這個插件嗎？告訴朋友，在 CurseForge 上收藏它，或在它的 GitHub 頁面上點擊 Star。(="
L["OPTIONS_LEVEL_UP_TITLE"] = "幫助 Good to Go 升級"
L["OPTIONS_LEVEL_UP_THANKS"] = "感謝你選擇 Good to Go！"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- 繃帶"
L["MACRO_EXPLOSIVES"] = "- 爆炸物"
L["MACRO_FEED_PET"] = "- 餵養寵物"
L["MACRO_FOOD"] = "- 食物"
L["MACRO_HEALTH_POTION"] = "- 治療藥水"
L["MACRO_HEALTHSTONE"] = "- 治療石"
L["MACRO_MANA_GEM"] = "- 法力寶石"
L["MACRO_MANA_POTION"] = "- 法力藥水"
L["MACRO_POISONS"] = "- 毒藥"
L["MACRO_SOULSTONE"] = "- 靈魂石"
L["MACRO_WATER"] = "- 水"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = "、"
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s和%s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s和%s"
-- A name with a detail after it: a Spellbook note and its settings ("Target (Mouseover, Self)"), or a pet and its owner.
L["NAME_WITH_DETAIL_FORMAT"] = "%s（%s）"
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

L["DIET_BREAD"] = "麵包"
L["DIET_CHEESE"] = "乳酪"
L["DIET_FISH"] = "魚"
L["DIET_FRUIT"] = "水果"
L["DIET_FUNGUS"] = "蘑菇"
L["DIET_MEAT"] = "肉"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"看來你發現了一個錯誤！%s (%s) 無法在 %s > %s (%s) 使用。請將此問題回報給我們，以便修正。謝謝！%s"
L["MESSAGE_NO_ITEM"] = "背包中未找到合適的%s。"
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"你的巨集欄位已滿，部分 Good to Go 巨集無法建立。請刪除不再使用的巨集來騰出欄位，或在 選項 > 插件 > Good to Go > 消耗品巨集 中關閉不需要的 Good to Go 巨集。"
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"你的巨集已準備就緒。輸入 %s，開啟%s分頁，然後將 - 食物、- 水 等巨集拖到你的快捷列上。"
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s 已加入此角色的忽略列表。"
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "已從此角色的忽略列表中清除 1 件物品。"
L["MESSAGE_IGNORE_CLEARED_MANY"] = "已從此角色的忽略列表中清除 %d 件物品。"

L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"

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

L["READINESS_TITLE"] = "就緒報告"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s%s"
L["READINESS_CLAUSE_SEPARATOR"] = "。"

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "缺少增益："
L["READINESS_EXPIRING"] = "即將到期："
L["READINESS_MISSING_ITEMS"] = "缺少物品："
L["READINESS_DAMAGED_GEAR"] = "受損裝備："
L["READINESS_CHARACTER"] = "角色："
L["READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備："

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
L["READINESS_FLASK"] = "精煉藥劑或 2 種藥劑"
L["READINESS_PET_FORMAT"] = "%s（寵物）"
L["READINESS_SCROLLS"] = "卷軸"
L["READINESS_SOULSTONE"] = "靈魂石未啟用"
L["READINESS_HEALTHSTONE"] = "治療石"
L["READINESS_MANA_GEM"] = "法力寶石"
L["READINESS_HEALING_POTION"] = "治療藥水"
L["READINESS_MANA_POTION"] = "法力藥水"
L["READINESS_BANDAGES"] = "繃帶"
L["READINESS_PVP_ON"] = "PvP 已開啟"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d 分鐘"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 不足 1 分鐘"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s（%s）"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 個未使用的天賦點"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d 個未使用的天賦點"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "你目前沒有任何對寵物有用的食物。"
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "你目前還沒有學會%s、%s、%s或%s。"
L["TIP_NO_HAND_POISON"] = "這把武器所選的毒藥已用完。"

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "你目前還沒有學會%s。"

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "你的背包裡沒有%s了。右鍵點擊 %s 製造更多。"
L["TIP_EMPTY_CREATE"] = "你的背包裡沒有%s了。右鍵點擊 %s 製造一顆。"

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "增益食物"
L["FEATURE_SCROLL_BUFFS"] = "卷軸增益"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "增益食物與卷軸"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'使用提供"%s"的食物，並在進食前補上缺少的卷軸增益。'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "當前食物"
L["MINIMAP_BEST_PET_FOOD"] = "當前寵物食物"
L["MINIMAP_MAIN_HAND_POISON"] = "主手毒藥"
L["MINIMAP_OFF_HAND_POISON"] = "副手毒藥"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "忽略列表"
L["MINIMAP_IGNORE_COUNT"] = "%d 件物品"
L["MENU_IGNORE"] = "忽略"
L["MENU_CLEAR_IGNORE"] = "清除忽略列表"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 報告"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d 項未完成訂單"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "恭喜，你的補給已全部備齊！"
L["MINIMAP_RESTOCKER_EMPTY"] = "你的清單是空的。"

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "補貨清單"
L["MENU_RESTOCKER_DESCRIPTION"] = "購買你清單上的物品，並在銀行存取。"
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 右鍵點擊"
L["MENU_OPTIONS"] = "GtG 選項"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

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
L["NOTE_MACRO_FEED_PET"] = "餵養寵物巨集"
L["NOTE_MACRO_FOOD_WATER"] = "食物與水巨集"
L["NOTE_MACRO_MANA_GEM"] = "法力寶石巨集"
L["NOTE_MACRO_HEALTHSTONE"] = "治療石巨集"
L["NOTE_MACRO_SOULSTONE"] = "靈魂石巨集"
L["NOTE_MACRO_POISONS"] = "毒藥巨集"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "召喚、餵養或復活"
L["NOTE_PET_MEND_CLICK"] = "右鍵點擊，或戰鬥中點擊"
L["NOTE_HOLD_SHIFT"] = "按住 Shift"
L["NOTE_PET_FORCE_REVIVE"] = "強制復活"
L["NOTE_HOLD_CONTROL"] = "按住 Ctrl"
L["NOTE_PET_DISMISS"] = "解散"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "製造"
L["NOTE_CREATE"] = "製造"
L["NOTE_RIGHT_CLICK_AGAIN"] = "再次右鍵點擊"
L["NOTE_LOWER_RANK_BACKUP"] = "低等級備用"
L["NOTE_MAGE_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造。"
L["NOTE_WARLOCK_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造一顆治療石。"

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "毒藥視窗"
L["NOTE_POISONS_REPLACED"] = "自動替換舊毒藥。"

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "繃帶"
L["LABEL_EXPLOSIVE"] = "爆炸物"
L["LABEL_FOOD"] = "食物"
L["LABEL_HEALTH_POTION"] = "治療藥水"
L["LABEL_HEALTHSTONE"] = "治療石"
L["LABEL_MANA_GEM"] = "法力寶石"
L["LABEL_MANA_POTION"] = "法力藥水"
L["LABEL_PET_FOOD"] = "寵物食物"
L["LABEL_POISON"] = "毒藥"
L["LABEL_SOULSTONE"] = "靈魂石"
L["LABEL_WATER"] = "水"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "已啟用"
L["MINIMAP_DISABLED"] = "已停用"
L["MINIMAP_TOGGLE"] = "切換"
L["MINIMAP_OPEN"] = "開啟"
L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_MIDDLE_CLICK"] = "中鍵點擊"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 左鍵點擊"

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
L["GROUP_CONTEXT_SOLO"] = "單人"
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "不在隊伍或團隊中時。"
L["GROUP_CONTEXT_PARTY"] = "隊伍"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] = "在隊伍中時，包括透過地城搜尋器進入的地城。"
L["GROUP_CONTEXT_RAID"] = "團隊"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] = "在團隊中時。戰場中的團隊算作戰場。"
L["GROUP_CONTEXT_BATTLEGROUND"] = "戰場"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] = "在戰場或競技場內時，無論你在哪種隊伍中。"
L["GROUP_CONTEXT_NEVER"] = "從不"

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
	"選擇你的食物巨集在哪些等級提供%s：任何等級、僅練等時或僅滿等時。下方的核取方塊選擇在哪些隊伍中。"
L["OPTIONS_MODE_CAPTION"] = "使用時機"
L["OPTIONS_GROUPS_NONE"] = "沒有勾選任何項目，因此永遠不會使用。"
L["LEVEL_FILTER_ANY"] = "任何等級"
L["LEVEL_FILTER_LEVELING"] = "練等時"
L["LEVEL_FILTER_MAX_LEVEL"] = "滿等時"

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
L["INVENTORY_REPORT_TITLE"] = "庫存報告"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "背包 %s，銀行 %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "背包 %s"
L["INVENTORY_REPORT_BANK"] = "銀行 %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "總計 %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"自動更新的巨集，總是使用你最好的食物、水、藥水和治療石；自動購買材料與彈藥並存入銀行的補貨清單；一鍵施放缺少的增益；以及為每個法術產生的滑鼠指向巨集。"

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "強化法術書"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"從法術書的新分頁一鍵為每個職業法術建立滑鼠指向、游標施放與自我施放巨集，不需要任何巨集語法。巨集會隨你升級、訓練和切換天賦自動更新。右鍵點擊即可加入專注目標、停止施法、自動攻擊、寵物攻擊或飾品。"
L["SPELLBOOK_IS_OFF"] = "強化法術書已關閉。請在 選項 > 插件 > Good to Go > 強化法術書 中開啟。"

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "登入時在聊天視窗中輸出歡迎訊息。"

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "啟用小地圖按鈕"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "顯示小地圖按鈕。"

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
L["OPTIONS_FEATURES_HEADER"] = "功能"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"顯示一個視窗，列出隊伍中所有缺少你可施放增益的人。點擊圖示即可施放。"
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"根據你的補貨清單保持背包物資充足，向商人購買並在背包與銀行之間搬運物品，物資不足時也會提醒你。關閉後以上功能全部停止，包括補貨清單視窗。你的清單仍會保留。"
L["SWITCH_SPELLBOOK"] = "啟用強化法術書"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"在你的法術書中加入一個分頁，為你的法術建立滑鼠指向、游標施放與自我施放巨集，並隨你升級和訓練保持更新。關閉後會隱藏該分頁並停止更新。它絕不會刪除巨集；要刪除請使用強化法術書面板上的刪除巨集按鈕。"
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"要關閉強化法術書嗎？它的分頁會從你的法術書中移除，它建立的巨集也不再隨你升級和訓練更新。這不會刪除那些巨集：它們會以目前的樣子留在你的快捷列上。"
L["SWITCH_MACROS"] = "啟用消耗品巨集"
L["SWITCH_MACROS_DESCRIPTION"] =
	'隨著背包內容變化，讓你的食物、水、藥水和其他消耗品巨集始終指向背包中最好的物品。關閉後會停止更新，每個巨集都保持最後的狀態。它絕不會刪除巨集；要刪除請在消耗品巨集面板的"要建立的巨集"中取消勾選。'
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"要關閉消耗品巨集嗎？你的巨集將不再隨背包變化而更新，因此某個按鈕可能會一直嘗試使用你已用完的物品。這不會刪除那些巨集：它們會以目前的樣子留在你的快捷列上。"
L["SWITCH_INVENTORY_REPORT"] = "啟用庫存報告"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"在物品提示中加入你的背包、銀行以及本伺服器其他角色身上各有多少件該物品。如果其他插件已經顯示這些數量，可以將它關閉。"
L["SWITCH_READINESS_REPORT"] = "啟用就緒報告"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"準備確認開始時，輸出一份僅你可見的清單，列出你仍需處理的事項，例如缺少的增益、藥水或受損的裝備。你已準備就緒時則不會輸出任何內容。"

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "啟用 Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "範例：%s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "開啟你的補貨清單。"

L["OPTIONS_LEVEL_UP_INTRO"] =
	"這個插件由熱愛這款遊戲、希望讓每個人都盡可能玩得開心的玩家打造。我們永遠不會請求捐款。真正讓我們滿足的，是知道我們的努力讓你的遊戲體驗更好了一點。如果確實如此，我們很想聽你說說！"
L["OPTIONS_LEVEL_UP_WAYS"] = "以下是你可以幫助我們接觸更多玩家的幾種方式。"
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 分享回饋：發現了錯誤或有新點子？請在 Discord 上告訴我們。你的回饋能幫助我們改進插件，也隨時歡迎提交拉取請求。"
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 告訴朋友：認識可能會喜歡這個插件的人嗎？告訴他們吧。口耳相傳能幫助更多玩家發現優秀的插件。"
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• 在 CurseForge 上收藏：打開下方的 CurseForge 連結，登入後點擊 Download 按鈕下方的星號。收藏能幫助更多玩家發現這個插件。"
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• 在 GitHub 上點 Star：打開下方的 GitHub 連結，登入後點擊右上角的 Star。星號能幫助專案取得更多免費開發者工具的資格。"

L["OPTIONS_FEEDBACK"] = "回饋與支援"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "回饋與支援連結"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "要複製連結，請點擊其輸入框，然後按 Ctrl+A 和 Ctrl+C。"
L["OPTIONS_VERSION"] = "版本 %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "消耗品巨集"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go 會為每種消耗品各建立一個巨集，並隨著背包變化保持更新，讓你快捷列上的按鈕始終取用你身上最好的物品。請在下方選擇要建立哪些巨集，然後設定每個巨集如何挑選物品。"

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "在按鈕上顯示巨集名稱"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"在你的快捷列按鈕上顯示巨集名稱文字，Good to Go 預設會隱藏這些文字。"

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "要建立的巨集"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	'選擇 Good to Go 要建立並維護哪些巨集。關閉某個巨集也會將其移除。它們位於巨集視窗的"一般巨集指令"標籤頁中，可直接拖到你的快捷列上。'
L["OPTIONS_OPEN_MACRO_WINDOW"] = "開啟巨集視窗"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	'開啟遊戲的巨集視窗並切換到"一般巨集指令"標籤頁，這些巨集就在那裡。'
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "建立並維護此巨集，取消勾選時會將其移除。"

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "食物與水"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"你的食物和水巨集會使用背包中最好的食物和飲料。這些選項可以讓增益食物、卷軸或魔法製造的食物和水優先，並讓補貨清單中的食物和水最後使用。"

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "優先增益食物"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益時，優先使用可提供該增益的食物，競技場中除外。'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "啟用卷軸增益"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"你的食物巨集第一次按下時會使用缺少的卷軸，再按一次則進食；以友方玩家為目標或身處競技場時會跳過卷軸。"
L["OPTIONS_SCROLL_TYPES"] = "在檢查中包含卷軸類型"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "保護"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = '檢查缺少的增益時包含"%s"。'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "優先使用魔法製造的食物與水"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'魔法製造的食物和水不花錢，並會在你離線後不久消失，因此你的食物和水巨集會優先使用它們，即使背包裡有恢復量更高的物品。開啟"優先增益食物"時，增益食物仍然最先使用。'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"選擇魔法製造的食物和水在哪些等級優先：任何等級、僅練等時或僅滿等時。下方的核取方塊選擇在哪些隊伍中。"

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "最後使用補貨清單中的食物與水"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"當兩種食物或飲料恢復量相同時，你的食物和水巨集會先使用不在補貨清單上的那種，把 Restocker 購買的留到以後。"

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "藥水與治療石"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"巨集在戰鬥中無法更改（這是暴雪的限制），因此每個藥水和治療石巨集都預先包含你最好的物品以及最多兩個備用物品。在較長的戰鬥中，圖示和提示可能會過時並顯示錯誤的物品，但點擊該巨集將始終使用你背包中實際擁有的最佳物品。"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "非戰鬥時在藥水巨集中使用食物與水"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"非戰鬥時，你的治療藥水巨集會食用你最好的食物，法力藥水巨集會飲用你最好的水。戰鬥中則照舊使用你的藥水。卷軸、寵物食物和魔法製造仍保留在食物和水巨集中。"
L["OPTIONS_COMBINE_HEALTHSTONES"] = "將治療石合併到治療藥水巨集中"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"將你最好的治療石加入治療藥水巨集的底部，這樣按一次即可同時使用藥水和治療石。"

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "法力寶石與符文"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s、%s以及另外幾種法力物品，都與法力寶石共用冷卻時間。符文使用時會消耗生命力，因此除非你選擇加入，否則法力寶石巨集不會包含其中任何一種。"
L["OPTIONS_INCLUDE_MANA_RUNES"] = "將符文與其他法力物品加入法力寶石巨集"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"將你的%s、%s，以及任何其他與法力寶石共用冷卻時間的法力物品，和你的法力寶石一同排序，這樣當其中某件物品是你的最佳選擇，或你的法力寶石用完時，法力寶石巨集就會使用該物品。"

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "增益重新施加"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"巨集在戰鬥中無法更改，因此戰鬥中途到期的增益會一直缺失，直到戰鬥結束。"
L["OPTIONS_REAPPLY"] = "重新施加即將到期的增益"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"將剩餘時間低於你所設門檻的增益食物、卷軸增益和寵物食物增益視為已到期，讓你的巨集在開怪前提供新的增益。"
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，你的巨集就會提供新的增益。"
L["REAPPLY_THRESHOLD_ONE"] = "當剩餘不足 1 分鐘時"
L["REAPPLY_THRESHOLD_MANY"] = "當剩餘不足 %d 分鐘時"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "寵物食物增益"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = '少數食物會為你的寵物提供專屬的"%s"增益。'
L["OPTIONS_USE_PET_BUFFS"] = "使用寵物食物增益"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'當你的寵物缺少"%s"增益時，將寵物食物加入你的食物巨集，競技場中除外。'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "在檢查中包含寵物食物類型"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "爆炸物"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 選項會跳過目標指示圈，直接將爆炸物在你腳下引爆，非常適合目標處於近戰距離時使用。另一個鍵則照常投擲。"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "點擊方式"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"選擇用哪個鍵投擲爆炸物，用哪個鍵將它在你腳下引爆。"
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "左鍵點擊 @player"
L["EXPLOSIVES_MODE_TOSS"] = "左鍵點擊投擲"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "職業與種族"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"這些選項會針對某個職業或種族調整你的巨集。所有區塊在每個角色上都會顯示。"

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "職業選項：%s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "種族選項：%s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"需要 DruidMacroHelper 插件。開啟後，你的治療藥水、法力藥水和治療石巨集會讓你脫離形態、使用物品，再讓你回到熊形態或獵豹形態，取決於你在核取方塊旁選擇的那個。"
L["OPTIONS_DRUID_MACRO_HELPER"] = "啟用 DruidMacroHelper 整合"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"使用 DruidMacroHelper (/dmh) 為治療藥水、法力藥水和治療石建立變形巨集。"
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] = "選擇你的變形巨集在使用物品後讓你返回哪種形態。"
L["DRUID_FORM_BEAR"] = "返回熊形態"
L["DRUID_FORM_CAT"] = "返回獵豹形態"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"讓毒藥巨集始終裝載每種毒藥類型可用的最高等級。左鍵塗抹副手，右鍵塗抹主手，既有毒藥會自動替換。"
L["OPTIONS_POISON_MAIN_HAND"] = "主手毒藥類型"
L["OPTIONS_POISON_OFF_HAND"] = "副手毒藥類型"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在右鍵點擊時塗抹到主手的毒藥。"
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在左鍵點擊時塗抹到副手的毒藥。"
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "啟用進食時潛行"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "將%s加入你的食物巨集中，以便你在進食時潛行。"

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "啟用喝水時潛行"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "將%s加入你的水巨集中，以便你在喝水時潛行。"
L["OPTIONS_STEALTH_PICK_ONE"] =
	"專業提示：只選一個。你可以同時進食和喝水，但潛行後再進食或喝水會解除潛行。"

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"選取一個你殺死的人型生物或不死族，你的巨集會在%s不在冷卻中時施放它，節省你的食物和飲料。如果無法施放（屍體超出距離，或該技能正在冷卻），則照常進食或喝水。"
L["OPTIONS_CANNIBALIZE_EATING"] = "使用%s代替進食"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"當你的目標是%s可用的屍體且該技能不在冷卻中時，你的食物巨集會施放它而不是進食。否則照常進食。卷軸和增益食物仍然優先。"
L["OPTIONS_CANNIBALIZE_DRINKING"] = "使用%s代替喝水"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"當你的目標是%s可用的屍體且該技能不在冷卻中時，你的水巨集會施放它而不是喝水。否則照常喝水。增益飲料仍然優先。"

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"當%s冷卻完畢時，你的食物巨集會施放它而不是進食，以節省食物。冷卻期間，巨集會照常進食。"
L["OPTIONS_RAPID_REGENERATION_EATING"] = "使用%s代替進食"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"當%s冷卻完畢時，你的食物巨集會施放它而不是進食。否則照常進食。卷軸和增益食物仍然優先。戰鬥中無法進食，每次按下都會施放它。"

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
L["TAB_IGNORE_LIST"] = "忽略列表"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"被忽略的物品永遠不會被任何巨集選用。食物、水、藥水，任何東西都一樣。全域列表對所有角色生效；角色列表只對該角色生效。右鍵點擊小地圖按鈕可忽略你當前的最佳食物。"
L["OPTIONS_IGNORE_GLOBAL"] = "全域"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "將此物品移至全域列表，使其在所有角色上都被忽略。"
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "從背包新增"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"從你身上的物品中挑選。開啟選項介面時背包會關閉，所以這可以代替把物品拖到這裡。"
L["OPTIONS_IGNORE_ADD_ID"] = "以物品 ID 新增"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"輸入物品 ID，或在此輸入框取得焦點時按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "輸入物品 ID，或按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_REMOVE"] = "移除"
L["OPTIONS_IGNORE_EMPTY"] = "此列表為空。"
L["OPTIONS_IGNORE_CLEAR"] = "清空列表"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"移除此列表中的所有物品。列表為空的角色會從左側的清單中消失，除非是你目前正在玩的角色。"
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "移除此列表中的所有物品？此動作無法復原。"
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "正在載入 ID：%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"根據你的補貨清單保持背包物資充足，自動向商人購買，並在背包與銀行之間搬運物品。輸入 %s 開啟清單。"
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "在銀行開啟"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "造訪銀行時開啟你的補貨清單。"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "在商人處開啟"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "造訪商人時開啟你的補貨清單。"
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "提醒"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] = "選擇何時提醒你補貨清單存量不足。"
L["OPTIONS_RESTOCKER_REMIND"] = "啟用城鎮補貨提醒"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"當補貨清單尚有缺口，且你抵達旅店或城市，或登入時已身處其中，在聊天中輸出提醒。"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "啟用商人補貨提醒"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] = "關閉商人視窗時，回報所有未完成的補貨訂單。"
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "啟用銀行補貨提醒"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "關閉銀行時，回報所有未完成的補貨訂單。"

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "金幣儲備"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] = "預留一部分金幣，向商人購買時絕不動用。"
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "啟用金幣儲備"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "補貨絕不會花掉你在此預留的金幣。"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "設定補貨始終為你保留的金幣數量。"

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"選擇提醒只有一行，還是為你缺少的每件物品各加一行。"
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "提醒詳細程度"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "簡潔"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "詳細"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "播放音效"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "在提醒的同時播放提示音，適合聊天繁忙的時候。"
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "點擊試聽提示音。"

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "補貨清單視窗"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "選擇你的補貨清單何時自動開啟。"

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"在物品提示中顯示你在本伺服器所有角色上共有多少件該物品。"
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "已記錄的角色"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "遺忘"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"要遺忘 %s 嗎？該角色的背包和銀行將不再顯示於任何物品提示中，其補貨清單選擇也會被清除。再次登入該角色時會重新記錄。"

-- Readiness Report
L["TAB_READINESS_REPORT"] = "就緒報告"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"準備確認開始時，輸出一份僅你可見的清單，列出仍需處理的事項；如果你已準備就緒，則完全不會輸出任何內容。"

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "重置就緒報告設定"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] = "將本頁的所有核取方塊和兩個門檻恢復為預設值。"
L["OPTIONS_READINESS_RESET_CONFIRM"] = "要將就緒報告的所有設定重置為預設值嗎？"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "缺少增益"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "缺少物品"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "角色"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"缺少精煉藥劑時提醒。一瓶精煉藥劑，或作戰藥劑與守護藥劑各一瓶，均視為已滿足。"
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益時提醒。需要在消耗品巨集中開啟增益食物。'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'你的寵物缺少"%s"增益時提醒。需要在消耗品巨集中開啟寵物食物增益，且寵物已召喚。'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"缺少卷軸增益時提醒。需要在消耗品巨集中開啟卷軸增益，且只檢查在那裡選取的卷軸類型。"
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"當隊伍中沒有人身上有生效的靈魂石時提醒；背包裡的靈魂石不算。僅提醒能製造靈魂石的術士。"
L["OPTIONS_READINESS_MAIN_HAND"] = "主手武器增益"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"主手武器沒有臨時附魔時提醒。任何附魔都算，且隊伍中有薩滿時不會回報此項。"
L["OPTIONS_READINESS_OFF_HAND"] = "副手武器增益"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"副手武器沒有臨時附魔時提醒。任何附魔都算：磨刀石、油劑、毒藥或薩滿的武器增益。"
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"主手武器缺少臨時附魔時提醒。盜賊和薩滿需要兩項：毒藥或武器灌注，加上油劑或磨刀石；其他職業有任意一項即可。"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"副手武器缺少臨時附魔時提醒。盜賊需要兩項：毒藥，加上油劑或磨刀石；其他職業有任意一項即可。"
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "增益到期時間少於"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"列出你身上所有即將到期的增益，不僅限於 Good to Go 施加的那些；此設定與消耗品巨集中的增益重新施加各自獨立。"
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s 分鐘"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 分鐘"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，報告才會列出它。"

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"當你身上沒有治療石時提醒。僅當隊伍中有可以索取的術士，或你自己就是術士時才提醒。"
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"當你身上沒有法力寶石時提醒。僅提醒能製造法力寶石的法師。"
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"當你身上沒有治療藥水時提醒，因為戰鬥中沒人能遞給你藥水。"
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"當你身上沒有法力藥水時提醒。僅當你的角色是使用法力的職業時才提醒。"
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] = "當你身上沒有%s技能允許使用的繃帶時提醒。"
L["OPTIONS_READINESS_DURABILITY"] = "受損裝備低於"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"連結耐久度低於該值的每件已裝備物品；按單件計算，因此即使只有一把武器損壞也會顯示。"
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"設定物品耐久度降到多低時，報告才會連結它。"

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "目前天賦"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "輸出你的天賦分配，以及尚未使用的點數。"
L["OPTIONS_READINESS_PVP"] = "PvP 標記開啟"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "當你的 PvP 標記開啟時發出警告。"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"連結不該出現在戰鬥中的已裝備物品，比如騎乘裝備或釣魚裝備。"

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "等級守望"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"留意你的隊伍中有誰施放了低於自己可用等級的法術，並告訴對方訓練師那裡有更高等級在等著。遊戲自動降低的等級（例如對低等級玩家施放的增益）永遠不會被回報。"
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s 仍在運作，因此等級守望暫時保持沉默，以免你的隊伍對每個低等級法術都聽到兩次提醒。Good to Go 已停用它並啟用了等級守望；重新載入後即由等級守望接手。"

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s（%s）"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "等級 %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"小提醒，沒什麼大不了的：你剛剛用的是%s，%d級就有更新的等級了。更新一下快捷列或去找訓練師，馬上就 Good to Go。"
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"小提醒，沒什麼大不了的：你的寵物%s剛剛用的是%s，寵物%d級就有更新的等級了。用訓練野獸教牠，馬上就 Good to Go。"
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"小提醒，沒什麼大不了的：你的%s剛剛用的是%s，%d級就有更新的等級了。去惡魔訓練師那裡買本魔典，馬上就 Good to Go。"
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"不想再收到這類提示？回覆 %s，我就不會再因為法術等級密語你了。這個號碼對所有使用 Good to Go 的人都有效。"
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] = "了解，我不會再傳等級提示給你了。"
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'%s 傳送了免打擾號碼，等級守望現在會忽略此玩家。可在等級守望的"已忽略的玩家"中復原。'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"你施放了%s，而%s從%d級起即可取得。去找訓練師或更新你的快捷列吧。"
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "你的寵物%s施放了%s，而%s從寵物%d級起即可取得。"
L["RANK_WATCH_PRINT_SELF_DEMON"] = "你的%s施放了%s，而%s從%d級起即可取得。"
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s 施放了%s，而%s對其來說從%d級起即可取得。"
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] = "%s 的寵物%s施放了%s，而%s對牠來說從寵物%d級起即可取得。"
L["RANK_WATCH_PRINT_OTHER_DEMON"] = "%s 的%s施放了%s，而%s對牠來說從%d級起即可取得。"
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s 會密語對方。"

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "啟用等級守望"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"當有人施放了低於自己可用等級的法術時，提醒你並密語你的隊伍成員，讓對方知道該去找訓練師了。"

L["RANK_WATCH_MESSAGES_HEADER"] = "通知"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] = "等級守望如何告知玩家他們施放了低等級法術。"
L["RANK_WATCH_WHISPER"] = "密語隊伍成員"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"密語施放了低等級法術的隊伍成員。當你的隊伍中有多名玩家使用等級守望或 Rank Sentinel 時，只有其中一人會傳送密語。"
L["RANK_WATCH_PRINT"] = "輸出隊伍成員的低等級法術"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"在你的聊天視窗中輸出隊伍成員施放的低等級法術。你自己的低等級法術一律會輸出。"
L["RANK_WATCH_GRACE_HEADER"] = "寬限期"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"新的法術等級要等施法者超過其學習等級若干級（由此處設定）後才會回報，這樣就不會有人因為剛剛達到、還來不及訓練的法術等級而收到提醒。"
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "滿等寬限期"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"對於已滿等的角色，學習等級距滿等在這麼多級以內的法術等級不會被回報。設為 0 時，他們可擁有的每個法術等級都會被回報。"
L["RANK_WATCH_GRACE_LEVELING"] = "練等寬限期"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"對於仍在練等的角色，學習等級與其目前等級相差在這麼多級以內的法術等級不會被回報，讓他們有時間去找訓練師。"
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 級"
L["RANK_WATCH_GRACE_LEVELS"] = "%d 級"

L["RANK_WATCH_OPT_OUT_HEADER"] = "免打擾"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'等級守望第一次密語某人時，會接著傳送對方的免打擾號碼。這個號碼由對方的名字產生，因此所有使用 Good to Go 的人傳出的號碼都相同。如果對方在密語或任何你看得到的聊天頻道中說出這個號碼，就會被加入"已忽略的玩家"，之後再也不會收到你發出的等級提醒。若要自行忽略某人，請選取對方並輸入 /gtg ignore。'
L["RANK_WATCH_WHISPERER_HEADER"] = "由誰為隊伍回報"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"當你的隊伍中有多人使用等級守望或 Rank Sentinel 時，只有其中一人會傳送密語，這樣施放了低等級法術的玩家只會收到一次提醒，而不是每個人都提醒一遍。其他人只會在自己的聊天視窗中輸出。以下是目前負責傳送密語的人。"
L["RANK_WATCH_WHISPERER_SELF"] = "由你傳送。"
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "由 %s 傳送，所以你只會看到聊天輸出。"
L["RANK_WATCH_WHISPERER_NONE"] = "無人：密語隊伍成員已關閉。"

-- Ability Alerts While Leveling: the Rank Watch panel's section for the level-up prints (LEVEL_UP_SPELLS and the rest)
L["RANK_WATCH_LEVEL_UP_HEADER"] = "升級時的技能提醒"
L["RANK_WATCH_LEVEL_UP_DESCRIPTION"] =
	"升級時，聊天框會列出職業訓練師可以教你的技能，每個都附有圖示和可懸停查看的連結。它有自己的開關，無論等級守望是否開啟都會生效。"
L["RANK_WATCH_LEVEL_UP"] = "升級時通告新技能"
L["RANK_WATCH_LEVEL_UP_TOGGLE_DESCRIPTION"] = "列出剛達到的等級解鎖的技能。"
L["RANK_WATCH_LEVEL_UP_PAST"] = "包含跳過的技能"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] = "新增一行，列出之前等級中你還沒有學習的技能。"
L["RANK_WATCH_LEVEL_UP_PET"] = "包含寵物技能"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] =
	"為獵人新增寵物訓練師的技能，為術士新增惡魔訓練師的魔典，均為新等級解鎖的內容。"
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "包含跳過的寵物技能"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] =
	"僅限獵人：新增一行，列出之前等級中你還沒有學習的寵物訓練師技能。術士不會顯示這一行，因為惡魔未被召喚時，遊戲不會告訴你它學過哪些魔典。"

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "已忽略的玩家"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "等級守望永遠不會回報這些玩家。"
L["RANK_WATCH_IGNORED_NONE"] = "目前沒有。"
L["RANK_WATCH_IGNORED_REMOVE"] = "取消忽略"
L["RANK_WATCH_IGNORE_TARGET"] = "忽略目標"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "將你目前選取的玩家加入列表。"
L["RANK_WATCH_IGNORE_ADDED"] = "等級守望現在會忽略 %s。"
L["RANK_WATCH_IGNORE_NOT_FOUND"] = "找不到 %s。請與對方組隊或選取對方，然後再試一次。"
L["RANK_WATCH_IGNORE_NO_TARGET"] = "請選取一名玩家，或輸入 /gtg ignore 名字。"
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore 名字"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"等級守望將不再回報該玩家。不加名字時，會忽略你的目標。"

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"等級守望會回報的法術等級，依職業列出。取消勾選你刻意降級使用的等級，等級守望就不會理會它。所有技能都會列出。等級守望預設不監看的技能，例如治療法術、天賦以及等級 1 的灼燒，一開始為未勾選。技能的最高等級會顯示為灰色，因為沒有比它更高的等級。"
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s（%d級）"
L["RANK_WATCH_RANK_DESCRIPTION"] = "有更高等級可用時回報此等級。"
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "最高等級。沒有比它更高的等級，因此永遠不會被回報。"
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s寵物"
L["RANK_WATCH_TRACK_ALL"] = "全部勾選"
L["RANK_WATCH_TRACK_NONE"] = "全部取消勾選"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '已存在名為"%s"的清單。'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "沒有 ID 為 %d 的物品。"
L["RESTOCKER_DISABLED"] = "Restocker 已關閉。請在 選項 > 插件 > Good to Go > Restocker 中開啟。"
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = "沒有名為 %s 的補貨清單。"
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"補貨完成。開啟銀行時按住 Shift 可跳過補貨。輸入 %s 編輯你的補貨清單。"
L["RESTOCKER_STOPPED_BOTH_FULL"] = "補貨已停止。你的背包和銀行都已滿。"
L["RESTOCKER_STOPPED_BANK_FULL"] = "補貨已停止。你的銀行已滿；請騰出一格後重新開啟。"
L["RESTOCKER_STOPPED_BAG_FULL"] = "補貨已停止。你的背包已滿；請騰出一格後重新開啟銀行。"
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "補貨已停止。無法繼續進行。"
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "補貨已停止。無法移動：%s。"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s（多餘）"
L["RESTOCKER_STOPPED_ERROR"] = "補貨因錯誤而停止：%s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"這個商人沒有販售你的毒藥所需的全部材料。跳過購買這些材料。"
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "在城裡的時候別忘了補貨！"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "還有 1 項補貨訂單未完成。"
L["RESTOCKER_STILL_SHORT_MANY"] = "還有 %d 項補貨訂單未完成。"

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "你的補貨清單已升級。"
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d 升級為 %sx%d。"

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
L["RESTOCKER_RESTOCKED_ONE"] = "已完成 1 項補貨訂單。"
L["RESTOCKER_RESTOCKED_MANY"] = "已完成 %d 項補貨訂單。"

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "有 1 項補貨訂單僅部分完成。"
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "有 %d 項補貨訂單僅部分完成。"
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "背包在全部購買完成前就已裝滿。"
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "金幣不足，無法完成補貨。"
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] = "你的金幣不足%s。金幣增加後將繼續補貨。"

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[名稱]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "新增一個以該名稱命名的清單。"
L["RESTOCKER_HELP_PROFILE_DELETE"] = "刪除該名稱的清單。"
L["RESTOCKER_HELP_PROFILE_RENAME"] = "將當前清單重新命名為該名稱。"
L["RESTOCKER_HELP_PROFILE_COPY"] = "用該名稱的清單副本取代當前清單。"
L["RESTOCKER_HELP_PROFILE_USE"] = "將此角色切換到該名稱的清單。"

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
L["STARTER_POPUP_TITLE"] = "基礎物資"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "完成"
L["STARTER_POPUP_INTRO_LOGIN"] = "我們已為你的職業勾選了一些基礎物資，幫你快速上手。"
L["STARTER_POPUP_INTRO_EMPTY"] = "你的補貨清單是空的，我們來新增一些物品好讓你上手。"
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "挑選你想保持備足的基礎物資。"
L["STARTER_POPUP_INTRO_HOW"] =
	"你勾選的一切都會在你開啟商人或銀行時自動補足。大多數基礎物資會隨著等級提升自動升級，所以你手上永遠是目前最好的。"
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "你隨時可以輸入 %s 來調整這份清單，或稍後新增更多物品。"
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "食物與水"
L["STARTER_POPUP_FOOD_HEADER"] = "食物"
L["STARTER_POPUP_AMMO_HEADER"] = "彈藥"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "子彈"
L["STARTER_POPUP_ARROWS"] = "箭矢"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "材料與工具"
L["STARTER_POPUP_POISONS_HEADER"] = "毒藥"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s ：將成品毒藥加入你的清單，Good to Go 會在任何販售全部所需材料的商人處自動購買這些材料。"
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"將 %s 加入你的補貨清單，在背包中保留 %d 個，並隨著你的等級自動升級。"
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "將 %s 加入補貨清單，並在背包中保留 %d 個。"
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 疊"
L["STARTER_POPUP_STACK_MANY"] = "%d 疊"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "要保持備足多少疊，每疊 %d 個。"
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"要保持備足多少個；這些物品無法堆疊，因此每個都會佔用一個背包格。"

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "補貨清單"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "篩選物品……"
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "清除"
L["RESTOCKER_ADD_BUTTON"] = "新增"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "挑選基礎物資"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"從適合你職業和等級的基礎物資中選擇：食物、水、彈藥、毒藥和施法材料。勾選一項即可將其加入此清單，取消勾選則會將其移除。"
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "新增物品"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"將背包中的物品拖曳到這裡或此視窗的任意位置，或輸入物品 ID 後按 Enter。"
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "拖曳物品或輸入物品 ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "請改為輸入物品 ID。"
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "已在此清單中。"
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "從背包新增物品"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] = "你背包中尚未加入此清單的所有物品，隨時可以新增。"
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "背包中沒有可新增的物品"

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
L["RESTOCKER_PROFILE_LABEL"] = "清單"
L["RESTOCKER_PROFILE_TOOLTIP"] = "為此角色切換到其他補貨清單，或新建一個清單。"
L["RESTOCKER_USED_BY"] = "使用者：%s"
L["RESTOCKER_MANAGE"] = "管理清單"
L["RESTOCKER_MANAGE_TOOLTIP"] = "新建一個清單，或複製、重新命名、刪除此清單。"
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "新清單"
L["RESTOCKER_MANAGE_COPY"] = "將此清單複製為新清單"
L["RESTOCKER_RENAME_PROFILE"] = "重新命名此清單"
L["RESTOCKER_MANAGE_DELETE"] = "刪除此清單"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 副本"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s（%d）"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "重新命名"
L["RESTOCKER_RENAME_TOOLTIP"] = "重新命名此清單，對所有使用它的角色生效。"
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "確定要刪除此清單嗎？"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s 也在使用此清單，下次登入時將進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s 也在使用此清單，下次登入時將各自進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SWITCH"] = "你將切換到 %s。"
L["RESTOCKER_DELETE_LIST_LAST"] = "這是僅剩的一個清單，因此你將從一個新的空清單開始。"
L["RESTOCKER_DELETE_LIST_FINAL"] = "此操作無法復原。"
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "隨等級升級"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"允許 Good to Go 在你升級時，將食物、水、彈藥、毒藥、藥水和職業施法材料升級為更好的物品。"

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "升級"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "物品"
L["RESTOCKER_COLUMN_WITHDRAW"] = "取出"
L["RESTOCKER_COLUMN_DEPOSIT"] = "存入"
L["RESTOCKER_COLUMN_REPUTATION"] = "聲望"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "保留"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "此標題可為目前顯示的所有物品設定此項。"
L["RESTOCKER_BULK_ON"] = "為顯示的 %d 件物品開啟"
L["RESTOCKER_BULK_OFF"] = "為顯示的 %d 件物品關閉"

L["RESTOCKER_GROUP_OTHER"] = "未分類"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "新加入"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "全部物品"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "此清單中還沒有物品"
L["RESTOCKER_EMPTY_BODY"] =
	"挑選食物、水或職業施法材料等基礎物資，或透過上方的選單新增背包中的任何物品。此清單中的物品會自動補足或存入你的銀行，讓你的背包保持整潔。"
L["RESTOCKER_EMPTY_DROP_HINT"] = "將物品拖曳到此視窗的任意位置也能新增。"
L["RESTOCKER_NO_MATCH_FILTER"] = "此清單中沒有符合篩選條件的物品。"
L["RESTOCKER_NO_MATCH_GROUP"] = "此分類中已沒有物品。"

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
L["RESTOCKER_NO_ORDERS"] = "沒有未完成的補貨訂單。"
L["RESTOCKER_REPORT_MORE"] = "還有 %d 項。"
L["RESTOCKER_REMOVED_ITEM"] = "已移除 %s。"
L["RESTOCKER_UNDO"] = "復原"
L["RESTOCKER_UNDO_TOOLTIP"] = "將此物品放回清單"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "將此物品從補貨清單中移除"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "你可以在清單頂端復原此操作。"
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "在背包中保留"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'要在背包中保留多少個。背包中的數量少於此數時，該數字會顯示為黃色；若設為 0 並開啟"存入"，則會將其全部存入銀行。'
L["RESTOCKER_BUY_LABEL"] = "購買"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "向商人購買"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "商人視窗開啟時，向商人購買所需數量。"

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "額外"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "額外購買"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"買下商人此物品的全部限量存貨（即每次只有少量、會慢慢刷新的商品），即使超出你的保留數量。"
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "存入銀行"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"銀行開啟時，將多餘的物品存入銀行；若保留欄填寫 0，則全部存入。"
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "從銀行取出"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "銀行開啟時，從銀行取出所需物品。"

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "所需聲望"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s（優惠 %d%%）"
L["RESTOCKER_REPUTATION_ANY"] = "任意"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "所需商人聲望"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"設定 Good to Go 向商人購買前，該商人所需的聲望等級；聲望還會降低價格：%s 5%%，%s 10%%，%s 15%%，%s 20%%。短橫線表示向任何商人購買。"

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此無法額外購買。'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此聲望要求不適用。'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "此物品沒有可升級的更好版本。"

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go 已停用被它取代的 %s。要立即重新載入，讓舊插件停止運作嗎？"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "立即重新載入"
L["POPUP_REPLACED_LATER"] = "稍後"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "已複製你的 %s 設定。"

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go 已從 %s 複製你的設定，並停用了被它取代的 %s。要立即重新載入，讓舊插件停止運作嗎？"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go 發現已安裝但被停用的 %s。要將設定移轉過來嗎？這會重新啟用舊插件並重新載入介面，之後會再提供一次重新載入，將它們再次停用。"
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go 發現已安裝但被停用的 %s。要將設定和補貨清單移轉過來嗎？這會重新啟用舊插件並重新載入介面，之後會再提供一次重新載入，將它們再次停用。"
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "移轉過來"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "不用了，謝謝"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "隊伍增益"
L["RANK_WATCH_TRACKED_HEADER"] = "回報的法術等級"
L["TRACKED_ITEM_PENDING"] = "物品 #%d"
L["TRACKED_SPELL_PENDING"] = "法術 #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "播放該音效，讓你在開啟前先試聽。"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "增益值班"
L["BUFF_DUTY_DESCRIPTION"] = "顯示誰缺少你的增益。點擊圖示即可施放。"
L["BUFF_DUTY_ENABLE"] = "啟用增益值班"
L["BUFF_DUTY_NO_BUFFS"] =
	"你的職業沒有此列表中的增益，因此該視窗在這個角色上永遠不會出現。"
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "顯示時機"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "選擇視窗何時可以出現。"
L["BUFF_DUTY_WHEN_NONE"] = "沒有勾選任何項目，因此視窗永遠不會出現。"
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"增益值班在此處隱藏。遊戲不允許插件在這個區域查看增益，因此無法判斷誰缺少增益。"
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"設定視窗在哪裡顯示：任何地方，或僅在副本內，例如地城或團隊副本。"
L["BUFF_DUTY_WHERE_ALWAYS"] = "任何地方"
L["BUFF_DUTY_WHERE_INSTANCE"] = "在副本中"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "在玩這些職業時顯示視窗。"
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "在玩此職業時顯示視窗。"
L["BUFF_DUTY_HEADER"] = "視窗"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "讓視窗留在你放置的位置，或在戰鬥中不擋視線。"
L["BUFF_DUTY_LOCK"] = "鎖定視窗"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "使視窗無法移動。解鎖後，可拖曳其背景來移動視窗。"
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "戰鬥中隱藏"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"在戰鬥中隱藏視窗。戰鬥中列表無法更新，因此保持顯示的視窗會停留在最後的狀態，直到戰鬥結束。"
L["BUFF_DUTY_SHOW_HEADER"] = "在視窗中顯示"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"將你自己的增益、為你施放增益的陌生人以及你的目標加入視窗。"
L["BUFF_DUTY_FAVOR_ENABLE"] = "禮尚往來"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"列出最近為你施放增益的陌生人，以及你可以回贈他們的增益。右鍵點擊圖示可將某人從列表中移除。"
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] = "設定陌生人在最後一次施放增益後保留在列表中的時間。"
L["BUFF_DUTY_TARGET_ENABLE"] = "你的目標"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"當你的目標是缺少你可施放增益的隊伍外玩家時，將其列出。"
L["BUFF_DUTY_ASK_OTHERS"] = "請其他職業提供增益"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	'在"缺少的隊伍增益"下顯示你的隊伍缺少的團隊增益，以及各有多少人需要。左鍵點擊可向隊伍請求該增益，右鍵點擊則密語能施放它的玩家。'
L["BUFF_DUTY_REFRESH"] = "剩餘低於此值時補充"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"設定增益剩餘時間低於多少時視為缺失，方便你在增益消失前及時補上。持續時間不超過此值的增益，只有在消失後才會視為缺失。"
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "視為坦克"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"沒有自身職責時，誰能獲得你提供給坦克的增益，例如荊棘術。"
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"設定此職業的玩家何時視為坦克。他們自己的坦克或治療者職責始終優先。"
L["BUFF_DUTY_TANKS_PETS"] = "寵物"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"設定寵物何時視為坦克。寵物也會獲得你提供給所有人的增益。"
L["BUFF_DUTY_TANKS_NEVER"] = "從不"
L["BUFF_DUTY_TANKS_SOLO"] = "單人時"
L["BUFF_DUTY_TANKS_ALWAYS"] = "總是"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "關閉"
L["BUFF_DUTY_AUDIENCE_TANK"] = "坦克"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "治療者"
L["BUFF_DUTY_AUDIENCE_ALL"] = "所有人"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "設定 %s 提供給誰。"
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"選擇每個增益提供給誰。坦克和治療者依隊伍職責判定，但在團隊中只有被設為%s的玩家才算坦克。沒有職責的人視為傷害輸出，除非下方的視為坦克另有設定。"

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "自身增益"
L["BUFF_DUTY_SELF_DESCRIPTION"] = "你自己的增益，固定在視窗頂部。"
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "任意一種守護即可"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "任意一種護甲即可"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "任意一種光環即可"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "任意一種護盾即可"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "任意一種護甲即可"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "兩種惡魔增益任意一種即可"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "關閉"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "缺失時"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "剩餘不足%s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"設定 %s 何時顯示：從不、消失後，或剩餘時間少於此值時。"
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "武器增益"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"勾選每把武器應保持的效果。當效果缺失或即將結束，且物品在你的背包中並適用於該武器時，視窗會提供它。"
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "重新施加"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"設定武器增益何時再次提供：消失後，或剩餘時間少於此值時。"
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "油"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "磨刀石"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "魚餌"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"提供%s，用於你的%s武器。當武器上沒有任何已勾選的選項時，會提供你擁有的每一種。"
L["BUFF_DUTY_SELF_ENABLE"] = "你的自身增益"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"當只能對自己施放的增益（例如護甲類法術或心靈之火）缺失或即將結束時，將其顯示在視窗頂部。可在自身增益中選擇要顯示哪些。"
L["BUFF_DUTY_WEAPON_ENABLE"] = "你的武器增益"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"將武器上缺失或即將結束的毒藥、武器強化、油、磨刀石和魚餌，與你的自身增益一起顯示在視窗頂部。點擊即可施加。可在武器增益中選擇要顯示哪些。"

-- The window itself
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "缺少的自身增益"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "缺少的隊伍增益"
L["BUFF_DUTY_FAVOR_HEADER"] = "禮尚往來"
L["BUFF_DUTY_TARGET_HEADER"] = "目標"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "對 %s 施放。"
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "施加到你的%s武器。"
L["BUFF_DUTY_TOOLTIP_USE"] = "你的隊伍中沒有人有靈魂石。對 %s 使用一顆。"
L["BUFF_DUTY_TOOLTIP_CREATE"] = "你的隊伍中沒有人有靈魂石。製造一顆。"
L["BUFF_DUTY_TOOLTIP_GROUP"] = "對 %s 及其隊伍施放。"
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "選取 %s 為目標並施放。"
-- A Party Buffs icon's tooltip, its click hints: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "在%s中請求增益"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "密語可施放者"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s缺少%s。"
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s缺少%s。"
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d名玩家缺少%s增益。"
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	'增益值班已隱藏，直到下次登入或重新載入介面。要立即恢復，請 Shift + 左鍵點擊小地圖按鈕。要為%1$s職業保持關閉，請在 %4$s 的"%3$s"下取消勾選"%2$s"。'

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "增益按鈕"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "正在等待 %s 進入範圍。"
L["BUFF_KEY_DONE"] = "沒有需要施放的增益了。"
L["BUFF_KEY_OFF"] = "增益值班已關閉。"
--[[
    The Buff Duty window's last line while the Buff Button has no key: the Buff
    Button's name (BUFF_KEY), the root panel's Key Bindings header
    (OPTIONS_KEY_BINDINGS_HEADER), then the options command.
]]
L["BUFF_DUTY_KEY_HINT"] =
	'你知道嗎？為%s綁定一個按鍵，每按一次就會施放清單中的下一個增益。可在"%s"中設定（%s）。'

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "未學會"
L["SECTION_CONSUMABLES"] = "GtG 消耗品"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "巨集內容"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "動態等級"
L["MENU_DYNAMIC_RANK_NOTE"] = "動態等級依友方玩家的等級決定，只在非戰鬥狀態下更新。"
L["MENU_CAST_AT_CURSOR"] = "在游標處施放"
L["MENU_TARGET_NEAREST_ENEMY"] = "選取最近的敵人"
L["MENU_TARGET_NEAREST_FRIEND"] = "選取最近的友方"
L["MENU_CAST_IF_SUMMONED"] = "寵物已召喚時施放%s"
L["MENU_NEVER_TURN_OFF"] = "永不關閉"
L["MENU_LEAVE_FORM_BEFORE"] = "施法前取消形態"
L["MENU_RIGHT_CLICK_FOR"] = "右鍵點擊：%s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "右鍵點擊：群體版本"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "套用至所有%s"
L["MENU_ONCE_PER_COMBAT"] = "每場戰鬥施放一次"
L["MENU_ONCE_PER_TARGET"] = "每個目標施放一次"
L["MENU_HIDE_ERRORS"] = "隱藏錯誤"
L["MENU_MUTE_ERRORS"] = "錯誤靜音"
L["MENU_SWITCH_TO"] = "切換為%s"
L["MENU_START_AUTO_ATTACK"] = "開始自動攻擊"
L["MENU_STOP_ATTACK"] = "停止攻擊"
L["MENU_START_AUTO_SHOT"] = "開始自動射擊"
L["MENU_START_PET_ATTACK"] = "開始寵物攻擊"
L["MENU_START_WAND"] = "開始魔杖射擊"
L["MENU_STOP_CASTING"] = "停止施法"
L["MENU_STOP_CASTING_NOTE"] = "對斷法、驅散這類不能等待的法術使用停止施法。"
L["MENU_STOP_IF_CHANNELING"] = "引導時不施放"
L["MENU_STOP_IF_STEALTHED"] = "潛行時不施放"
L["MENU_DUPLICATE"] = "複製"
L["MENU_DELETE"] = "刪除"
L["MENU_DELETE_USED_ONE"] = "刪除（用於 1 個快捷列）"
L["MENU_DELETE_USED"] = "刪除（用於 %d 個快捷列）"
L["MENU_DELETE_DESCRIPTION"] =
	"從你的巨集中刪除此巨集，這也會將它從快捷列上移除，並重設它的所有選項。在頁面上點擊或拖曳它即可重新建立。"
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"將此副本從頁面移除，並從你的巨集中刪除，這也會將它從快捷列上移除。"
L["MENU_DELETE_CONFIRM"] = "要刪除 %s 嗎？它會從你的快捷列上移除，且選項會被重設。"
L["MENU_GROUP_RANK"] = "等級"
L["MENU_GROUP_WHEN"] = "時機"
L["MENU_GROUP_FIRST"] = "先執行"
L["MENU_GROUP_THEN"] = "再執行"
L["MENU_GROUP_ERRORS"] = "錯誤訊息"
L["MENU_GROUP_GROUPED"] = "同組法術"
L["MENU_GROUP_TARGET"] = "目標"
L["MENU_PRIORITY_1"] = "第一優先"
L["MENU_PRIORITY_2"] = "第二優先"
L["MENU_PRIORITY_3"] = "第三優先"
L["MENU_PRIORITY_DESCRIPTION"] =
	"巨集依序嘗試的對象。無法接受該法術的對象會被跳過；若都無法接受，則像一般法術一樣施放。"
L["MENU_UNIT_NONE"] = "無"
L["MENU_UNIT_NONE_DESCRIPTION"] = "清單到此結束。"
L["MENU_UNIT_TARGET"] = "目標"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "在目標能接受該法術時，對你的目標施放。"
L["MENU_UNIT_SELF"] = "自己"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	"對你自己施放。你永遠能接受，因此排在自己之後的對象都不會被嘗試。"
L["MENU_UNIT_PET"] = "寵物"
L["MENU_UNIT_PET_DESCRIPTION"] = "在你的寵物已召喚且能接受該法術時，對寵物施放。"
L["MENU_UNIT_FOCUS"] = "專注目標"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "在你有專注目標且它能接受該法術時，對專注目標施放。"
L["MENU_UNIT_TARGETS_TARGET"] = "目標的目標"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"在目標的目標能接受該法術時對其施放，例如你選取的敵人正在攻擊的坦克。"
L["MENU_UNIT_MOUSEOVER"] = "滑鼠指向"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"對游標下的對象施放，無論是在遊戲世界中還是在頭像框架上，只要對方能接受該法術。"
L["MENU_OPTIONS_COUNT"] = "%d 個選項"
L["MENU_ENABLED"] = "已啟用"
L["MENU_HIGHEST"] = "最高"
L["MENU_HIGHEST_DESCRIPTION"] = "施放你已學會的最高等級。"
L["MENU_RANK_DYNAMIC"] = "動態等級"
L["MENU_FIXED_RANK_DESCRIPTION"] = "無論角色等級為何，總是施放%s。"
L["MENU_ANY_TIME"] = "任何時候"
L["MENU_ANY_TIME_DESCRIPTION"] = "戰鬥中或非戰鬥時都會施放。"
L["MENU_IN_COMBAT"] = "戰鬥中"
L["MENU_IN_COMBAT_DESCRIPTION"] = "只在戰鬥中施放。非戰鬥時巨集不做任何事，包括其中的物品。"
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"只在非戰鬥時施放。戰鬥中巨集不做任何事，包括其中的物品。"
L["MENU_EVERY_PRESS"] = "每次按下"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "每次按下都會施放。"
L["MENU_GROUP_VERSION_DESCRIPTION"] = "右鍵點擊施放%s。左鍵點擊仍施放%s。"
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"允許巨集施放%s。在此勾選的法術中，巨集會施放你最後學會的那個，因此會隨你訓練而升級。"
L["MENU_GROUPED_SPELL_NOT_LEARNED"] = "尚未學會。現在勾選，學會後巨集就會使用它。"
L["MENU_PET_DESCRIPTION"] = "當你的%s已召喚時，巨集會施放%s，而不是再次召喚它。"
L["MENU_STANCE_DESCRIPTION"] = "先切換為%s，除非你已處於該狀態。"
L["MENU_USE_ITEM_DESCRIPTION"] =
	"在施法前使用。物品依你勾選的順序使用，每個後方的數字表示它的順位。"
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "使用%s"
L["MENU_ADD_FOCUS"] = "新增專注目標副本"
L["MENU_REMOVE_FOCUS"] = "移除專注目標副本"
L["MENU_FOCUS_DESCRIPTION"] =
	"在頁面上新增第二個巨集，先對你的專注目標施放，再對你的目標施放。"
L["MENU_REMOVE_FOCUS_DESCRIPTION"] = "將專注目標副本從頁面移除，並刪除它的巨集。"
L["MENU_DUPLICATE_DESCRIPTION"] =
	"在頁面上新增此巨集的另一個副本，以目前這些選項為起點，讓你可以做不同的設定。"
L["MENU_MAKE_DEFAULT"] = "設為%s的預設"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] = "%s中所有你未自行設定的巨集，都會以此巨集的選項為起點。"
L["MENU_DEFAULT_SET"] = "%s現在會以這些選項為起點。"

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "條件"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"在強化法術書視窗旁開啟條件面板，讓巨集在條件符合時施放不同的法術，例如按住 Shift 或天賦 2。"
L["MENU_RIGHT_CLICK_TAKEN"] = "某個條件已使用右鍵點擊。移除該條件才能開啟此項。"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "條件"
L["CONDITIONALS_HINT"] = "由上往下檢查；第一個符合的條件會施放。"
L["CONDITIONALS_OTHERWISE"] = "否則"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "且"
L["CONDITIONALS_AND_MENU"] = "新增第二個條件"
L["CONDITIONALS_AND_DESCRIPTION"] = "新增第二個條件。只有兩個條件都符合時，該列才會施放。"
L["CONDITIONALS_DROP_SECOND"] = "移除此條件"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "該列重新只檢查第一個條件。"
L["CONDITIONALS_ADD"] = "+ 新增條件"
L["CONDITIONALS_ADD_DESCRIPTION"] = "在底部新增一列。先選擇條件，再選擇要施放的法術。"
L["CONDITIONALS_ADD_LIMIT"] =
	"最多 %d 列。每一列都會增加巨集內容的長度，而巨集最多只能容納 255 位元組。"
L["CONDITIONALS_PICK_SPELL"] = "選擇法術"
L["CONDITIONALS_PICKING"] = "點擊頁面上的法術"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"點擊這裡，再點擊頁面上的法術，讓它在這一列施放。也可以將法術從頁面拖曳到此欄位。"
L["CONDITIONALS_PICK_BANNER"] = "點擊法術以使用它。按 Esc 或右鍵點擊取消。"
L["CONDITIONALS_CANNOT_PICK"] = "只有已學會的法術才能由條件施放。"
L["CONDITIONALS_EMPTY"] =
	"還沒有條件。新增一個，即可在按住 Shift、戰鬥中等情況下施放其他法術。"
L["CONDITIONALS_SHADOWED"] =
	"永遠不會施放：只要此列符合，上方的第 %d 列也一定符合，且會先施放。"
L["CONDITIONALS_KEY_DRAG"] = "將法術拖曳到這裡"
L["CONDITIONALS_ACTION_DROP"] = "在此列施放"
L["CONDITIONALS_ACTION_PICK"] = "從頁面選擇"
L["CONDITIONALS_ACTION_USE"] = "用於條件"
L["CONDITIONALS_ACTION_CANCEL"] = "取消選擇"
L["CONDITIONALS_REMOVE"] = "移除"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "移除此列。"
L["CONDITIONALS_REORDER"] = "重新排序"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"拖曳到另一列上，將此列移到該處。第一個符合的列會施放。"
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s：%s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "按住 Shift"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "按下巨集時按住 Shift 即符合。"
L["CONDITION_CTRL"] = "按住 Ctrl"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "按下巨集時按住 Ctrl 即符合。"
L["CONDITION_ALT"] = "按住 Alt"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "按下巨集時按住 Alt 即符合。"
L["CONDITION_RIGHT_CLICK"] = "右鍵點擊"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "在快捷列上右鍵點擊巨集時符合。"
L["CONDITION_IN_COMBAT"] = "戰鬥中"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "你在戰鬥中時符合。"
L["CONDITION_OUT_OF_COMBAT"] = "非戰鬥時"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "你不在戰鬥中時符合。"
L["CONDITION_SPEC_1"] = "天賦 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "你的第一套天賦啟用時符合。"
L["CONDITION_SPEC_2"] = "天賦 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "你的第二套天賦啟用時符合。"
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s（目前）"
L["CONDITION_COMBAT_BLOCKED"] =
	'"時機"設為"戰鬥中"或"非戰鬥時"時無法使用。巨集在另一種情況下本來就不做任何事，因此這個條件會永遠符合，或永遠不符合。'
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	'同組法術已開啟"右鍵點擊：%s"，右鍵點擊已被佔用，因此無法使用。關閉該選項即可在此使用右鍵點擊。'
L["SUBTEXT_CONDITIONALS_ONE"] = "1 個條件"
L["SUBTEXT_CONDITIONALS"] = "%d 個條件"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "施法序列"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"在強化法術書視窗旁開啟施法序列面板，讓巨集每按一次就依序施放下一個法術，例如腐蝕術、痛苦詛咒，然後獻祭。"
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d 步"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "施法序列"
L["CAST_SEQUENCE_HINT"] = "每按一次施放下一步。施放失敗的步驟會在下次按下時再次嘗試。"
L["CAST_SEQUENCE_FIRST"] = "第一步"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "巨集本身的法術永遠是第一步。"
L["CAST_SEQUENCE_ADD"] = "+ 新增步驟"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "在最後新增一個步驟。然後選擇它要施放的法術。"
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"巨集本身的法術之後最多 %d 步。每一步都會增加巨集內容的長度，而巨集最多只能容納 255 位元組。"
L["CAST_SEQUENCE_CANNOT_PICK"] = "只有已學會的法術才能成為施法序列中的步驟，射擊除外。"
L["CAST_SEQUENCE_ACTION_DROP"] = "在此步驟施放"
L["CAST_SEQUENCE_ACTION_USE"] = "用於施法序列"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "移除此步驟。"
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "拖曳到另一個步驟上，將此步驟移到該處。"
L["CAST_SEQUENCE_END"] = "最後一步之後"
L["CAST_SEQUENCE_END_LOOP"] = "重新開始"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] = "下次按下會再次施放巨集本身的法術，序列循環進行。"
L["CAST_SEQUENCE_END_STOP"] = "停止（NULL）"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"以 NULL 結束，這是一個沒有人會的法術，因此之後再按都不會施放任何東西，直到重設讓序列重新開始。"
L["CAST_SEQUENCE_END_STOP_SHORT"] = "停止"
L["CAST_SEQUENCE_RESET"] = "重新開始的時機"
L["CAST_SEQUENCE_RESET_NEVER"] = "從不"
L["CAST_SEQUENCE_RESET_TARGET"] = "目標改變"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "你更換目標時，序列從第一步重新開始。"
L["CAST_SEQUENCE_RESET_COMBAT"] = "戰鬥結束"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] = "你脫離戰鬥時，序列從第一步重新開始。"
L["CAST_SEQUENCE_RESET_SHIFT"] = "按住 Shift"
L["CAST_SEQUENCE_RESET_CTRL"] = "按住 Ctrl"
L["CAST_SEQUENCE_RESET_ALT"] = "按住 Alt"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"按住此鍵按下巨集時，序列會重新開始，施放第一步。"
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "閒置秒數"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] = "巨集這麼久沒有按下時，序列會重新開始。"
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "關閉"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "閒置 %d 秒"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	'永久停止：沒有任何方式讓它重新開始，序列會停在 NULL，直到巨集變更或你重新載入介面。請在"重新開始的時機"中選擇一種重設方式。'
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'"寵物已召喚時施放"正在施放%s，並會寫入自己的施法指令行，因此序列暫停作用。關閉該選項即可使用序列。'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"點擊這裡，再點擊頁面上的法術，讓它在此步驟施放。也可以將法術從頁面拖曳到此欄位。"
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d 步序列"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "顯示所有法術等級"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "顯示同組法術"
L["SETTINGS_SHOW_UNLEARNED"] = "顯示未學會的法術"
L["SETTINGS_MARK_ALL_PLACED"] = "將所有法術標記為已放置"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"本頁的所有巨集不再發光，無論是否在你的快捷列上。之後學會的法術在放置前仍會發光。"
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "醒目顯示未放置的法術"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	'讓所有不在快捷列上的巨集發光。關閉此項會將它們全部標記為已放置，效果與"將所有法術標記為已放置"按鈕相同。'
L["SORT_BY_CATEGORY"] = "依類別排序"
L["SORT_BY_SCHOOL"] = "依系別排序"
L["SORT_DESCRIPTION"] =
	"將頁面上的巨集依類別分組（每個法術的用途，例如攻擊、治療或防禦冷卻技），或依系別分組（法術所屬的法術書分頁）。"
L["CATEGORY_ATTACKS"] = "攻擊"
L["CATEGORY_FINISHERS"] = "終結技"
L["CATEGORY_CROWD_CONTROL"] = "群體控制"
L["CATEGORY_HYBRID"] = "混合"
L["CATEGORY_HEALS"] = "治療"
L["CATEGORY_BUFFS"] = "增益"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "進攻冷卻技"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "防禦冷卻技"
L["CATEGORY_SELF_BUFFS"] = "自身增益"
L["CATEGORY_SHOCKS"] = "震擊"
L["CATEGORY_TRAPS"] = "陷阱"
L["CATEGORY_TOTEMS"] = "圖騰"
L["CATEGORY_SEALS"] = "聖印"
L["CATEGORY_BLESSINGS"] = "祝福"
L["CATEGORY_CURSES"] = "詛咒"
L["CATEGORY_PETS"] = "寵物"
L["CATEGORY_TELEPORTS"] = "傳送與傳送門"
L["CATEGORY_UTILITY"] = "輔助"
L["CATEGORY_THREAT"] = "嘲諷與仇恨"
L["SUBCATEGORY_BASIC_ATTACKS"] = "基本攻擊"
L["CATEGORY_STANCES"] = "姿態"
L["CATEGORY_FORMS"] = "形態"
L["CATEGORY_AURAS"] = "光環"
L["CATEGORY_ASPECTS"] = "守護"
L["CATEGORY_RACIALS"] = "種族技能"
L["CATEGORY_TRACKING"] = "追蹤"
L["CATEGORY_PROFESSIONS"] = "專業技能"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "專注目標"
L["SUBTEXT_PET"] = "寵物"
L["SUBTEXT_CURSOR"] = "游標"
L["SUBTEXT_STANCE"] = "姿態"
L["SUBTEXT_USE_ITEMS"] = "使用物品"
L["SUBTEXT_PET_ATTACK"] = "寵物攻擊"
L["SUBTEXT_DYNAMIC_RANK"] = "動態等級"
L["SUBTEXT_DYNAMIC_ITEM"] = "動態物品"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "動態等級，動態物品"
L["SUBTEXT_MAX_RANK"] = "最高等級"
L["SUBTEXT_TARGET_ENEMY"] = "最近敵人"
L["SUBTEXT_TARGET_FRIEND"] = "最近友方"
L["SUBTEXT_TARGET_PRIORITY"] = "目標"
L["SUBTEXT_GROUPED_SPELLS"] = "同組"
L["SUBTEXT_ONCE_PER_COMBAT"] = "每戰一次"
L["SUBTEXT_ONCE_PER_TARGET"] = "每目標一次"
L["SUBTEXT_COMBAT_ONLY"] = "僅戰鬥中"
L["SUBTEXT_NO_COMBAT"] = "非戰鬥時"
L["SUBTEXT_LEAVE_FORM"] = "取消形態"
L["SUBTEXT_NO_TOGGLE"] = "永不關閉"
L["SUBTEXT_WAND"] = "魔杖"
L["SUBTEXT_START_ATTACK"] = "自動攻擊"
L["SUBTEXT_STOP_ATTACK"] = "停止攻擊"
L["SUBTEXT_STOP_CASTING"] = "停止施法"
L["SUBTEXT_STOP_IF_CHANNELING"] = "引導時不施放"
L["SUBTEXT_STOP_IF_STEALTHED"] = "潛行時不施放"
L["SUBTEXT_HIDE_ERRORS"] = "隱藏錯誤"
L["SUBTEXT_MUTE_ERRORS"] = "錯誤靜音"
L["SUBTEXT_OPTIONS_COUNT"] = "%d 個選項"
L["SUBTEXT_TOO_LONG"] = "過長"
L["SUBTEXT_LEARN_LEVEL"] = "%d級"
L["SUBTEXT_TALENT"] = "天賦"
L["SUBTEXT_LEARN_RANK"] = "學習%s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s，%s"
L["SUBTEXT_TEACH_PET"] = "教給寵物"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "尚未學會"
L["TOOLTIP_LEARN_LEVEL"] = "你的職業訓練師在%d級時傳授。"
L["TOOLTIP_LEARN_TALENT"] = "透過天賦學會。"
L["TOOLTIP_NOT_ON_BARS"] = "不在你的快捷列上"
L["TOOLTIP_TOO_LONG"] = "過長：%d / %d 位元組。關閉一個選項來縮短它。"
L["TOOLTIP_OPTIONS_ON"] = "已開啟選項：%s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "點擊或拖曳"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "放到你的快捷列上"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "右鍵點擊"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "巨集選項"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "中鍵點擊"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "重設巨集選項"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "重設%s中的所有巨集"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s已恢復為預設選項。"
L["CHAT_CATEGORY_OPTIONS_RESET"] = "%s中的每個巨集都已恢復為預設選項。"
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"清除你在此處每個法術上設定的選項，讓每個法術重新遵循預設值。專注目標副本和複製出的巨集會保留。"
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"要重設你在%s中每個法術上設定的選項嗎？每個法術都會重新遵循預設值。"

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s巨集"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "把你的職業法術做成一鍵巨集。"
L["TOOLTIP_KEY_CLICK"] = "點擊"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "開啟強化法術書"

-- Page: Layout
L["PAGE_EMPTY"] = "還沒有巨集。去找你的職業訓練師學習第一批法術。"
L["PAGE_NO_MATCHES"] = "沒有符合篩選條件的巨集。"
L["PAGE_FILTER"] = "篩選法術"
L["FILTER_ALL_SCHOOLS"] = "所有系別"
L["FILTER_ALL_CATEGORIES"] = "所有類別"
L["PAGE_MACRO_SLOTS"] = "巨集欄位"
L["TOOLTIP_MACRO_SLOTS"] =
	"你放置的每個巨集都會佔用一個巨集欄位。角色欄位專屬於這個角色，並優先佔用。一般欄位由你帳號中的所有角色共用。"
L["PAGE_MACRO_GENERAL"] = "一般"
L["PAGE_MACRO_CHARACTER"] = "角色"
L["PAGE_NO_MATCHES_FOR"] = '沒有符合"%s"的法術。'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Options for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "全部 %d 個%s的選項"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"一次為此類別中的每個法術開啟或關閉某個選項。尚未放到快捷列上的法術會保留該設定，等你放置時套用。"
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "（續）"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "接下來學什麼？"
L["WHATS_NEXT_EMPTY"] = "沒有可列出的法術。"
L["WHATS_NEXT_ALL_SOURCES"] = "所有來源"
L["WHATS_NEXT_ANY_LEVEL"] = "任何等級"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "（%s）"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LEVEL_UP_SPELLS_PAIR_FORMAT or LEVEL_UP_SPELLS_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), & [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "你現在可以學習%s。"
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "別忘了，你還可以學習%s。"
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "你的寵物現在可以學習%s。"
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "別忘了，你的寵物還可以學習%s。"
L["LEVEL_UP_DEMON_SPELLS"] = "你的惡魔現在可以學習%s。"
L["LEVEL_UP_SPELLS_PAIR_FORMAT"] = "%s和%s"
L["LEVEL_UP_SPELLS_LAST_FORMAT"] = "%s和%s"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "現在可學"
L["WHATS_NEXT_STATUS_SOON"] = "即將可學"
L["WHATS_NEXT_STATUS_LATER"] = "尚無法學習"
L["WHATS_NEXT_STATUS_MISSING"] = "缺少前置條件"
L["WHATS_NEXT_STATUS_TALENT"] = "未取得的天賦"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "未取得的天賦與符文"
L["WHATS_NEXT_STATUS_KNOWN"] = "已學會"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "現在可學"
L["WHATS_NEXT_SHORT_SOON"] = "即將可學"
L["WHATS_NEXT_SHORT_LATER"] = "尚未可學"
L["WHATS_NEXT_SHORT_MISSING"] = "需要其他法術"
L["WHATS_NEXT_SHORT_TALENT"] = "未取得"
L["WHATS_NEXT_SHORT_KNOWN"] = "已學會"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "初始法術"
L["WHATS_NEXT_SOURCE_TRAINER"] = "訓練師"
L["WHATS_NEXT_SOURCE_BOOK"] = "書籍"
L["WHATS_NEXT_SOURCE_QUEST"] = "任務"
L["WHATS_NEXT_SOURCE_TALENT"] = "天賦"
L["WHATS_NEXT_SOURCE_RUNE"] = "符文"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "學習來源"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "需要等級"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "你的職業一開始就會。"
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "由你的職業訓練師傳授。"
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "由物品傳授，例如來自地城或團隊副本的書。"
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "由職業任務傳授。你的職業訓練師可以為你指引。"
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "投入一點天賦點數即可學會。"
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "銘刻它的符文即可學會。"
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "請先學會%s。"
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "%s的等級"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + 點擊"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "在聊天中連結"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "依可學狀態排序"
L["WHATS_NEXT_SORT_LEVEL"] = "依等級排序"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	'"依可學狀態排序"會把現在能學的法術排在最前，已學會的排在最後。"依等級排序"會把每個法術列在學習它所需的等級之下。'
L["WHATS_NEXT_SHOW_KNOWN"] = "顯示已學會的法術"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "同時列出你已學會的法術，排在其他法術之後。"
L["WHATS_NEXT_SHOW_TALENTS"] = "顯示未取得的天賦"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "顯示未取得的天賦與符文"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"同時列出你尚未取得的天賦法術。這些法術需投入天賦點數學會，而不是向訓練師學習。"

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "寵物法術書"
L["PET_SPELLBOOK_EMPTY"] = "你的寵物沒有可列出的法術。"
L["PET_SPELLBOOK_NO_PET"] = "寵物未召喚。召喚你的寵物以查看牠的法術。"
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "技能"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "被動"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "自動施放：開"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "自動施放：關"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "寵物接下來學什麼？"
L["WHATS_NEXT_PET_EMPTY"] = "沒有可列出的寵物技能。"
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s，%d級%s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "訓練點數：剩餘 %d / 共 %d"
L["WHATS_NEXT_PET_NO_PET"] = "寵物未召喚：顯示你透過訓練野獸學會的技能。"
L["WHATS_NEXT_PET_NO_DEMON"] = "惡魔未召喚：召喚一隻以查看牠已經會的技能。"

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "可以傳授"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "其他家族的技能"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "可以傳授"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "其他家族"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "寵物訓練師"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "馴服"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "惡魔訓練師"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "需要寵物等級"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "訓練點數"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"由寵物訓練師傳授給你。之後再用訓練野獸傳授給你的寵物。"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"馴服一隻會此技能的野獸，並與牠並肩作戰直到你學會。之後再用訓練野獸傳授給任何能學會它的寵物。"
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "你已學會。用訓練野獸將它傳授給你的寵物。"
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"向惡魔訓練師購買它的魔典，然後在會學習它的惡魔被召喚時使用。"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "魔典"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] = "它的魔典在你的背包中。在召喚此惡魔時使用。"
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "你的寵物無法學會它。"
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "會此技能的野獸"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s（%s）"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "還有 %d 隻。"

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	'"依可學狀態排序"會把寵物現在能學的技能排在最前，已經會的排在最後。"依等級排序"會把每個技能列在所需的寵物等級之下。'
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "顯示已會的技能"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"同時列出你的寵物已經會的技能，排在其他技能之後。沒有召喚寵物的獵人會看到自己已學會的技能。"
L["WHATS_NEXT_PET_SHOW_OTHER"] = "顯示其他家族的技能"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"同時列出你的寵物無法學會的技能，例如狼學不會的豹的潛伏，或其他惡魔的技能。"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "按鍵設定"
L["OPTIONS_KEY_SET"] = "設定按鍵"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "開啟遊戲的按鍵設定清單，Good to Go 在其中有自己的分類。"
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"開啟或關閉強化法術書。它在你的法術書中也有自己的分頁。"
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"在非戰鬥中，每按一次就施放增益值班視窗提供的下一個增益。武器增益仍需在視窗上點擊。若要從巨集中觸發，請使用 %s。"
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "法術等級提示"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"每個技能的提示都會列出它的各個等級及所需的角色等級：白色是你已學會的等級，綠色是你現在就能訓練的等級，灰色是之後才能學的等級。這能讓你快速自我檢查是否在使用最高等級，好讓你隨時發揮最佳水準。戰鬥中不會顯示這些等級，讓你的提示在關鍵時刻保持簡短。"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "啟用法術等級提示"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"在快捷列、遊戲內建法術書及其他插件中，將每個技能的等級加入它的提示。關閉後，這些提示會維持遊戲原本的樣子。強化法術書自己的視窗無論如何都會顯示這些等級。"
L["OPTIONS_DELETE_MACROS_HEADER"] = "刪除巨集"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"刪除強化法術書建立的巨集，同時會將它們從快捷列上移除。你自己的巨集絕不會被改動，在頁面上點擊或拖曳任一個巨集即可重新建立。"
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "刪除角色巨集"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"從此角色的巨集分頁中刪除強化法術書的巨集。你的其他角色會保留各自的巨集，直到你在那些角色上也這樣做。"
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"刪除此角色上強化法術書的所有巨集？它們也會從你的快捷列上移除。"
L["OPTIONS_DELETE_GENERAL_MACROS"] = "刪除一般巨集"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"從一般巨集分頁中刪除強化法術書的巨集。該分頁由帳號內所有角色共用，因此你的其他角色也會失去那裡的巨集。"
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"刪除強化法術書的所有一般巨集？帳號內所有角色都會失去它們，並且它們也會從你的快捷列上移除。"

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"在法術本身的巨集之後，為你已學會的每個較低等級各列出一個巨集，每個都固定施放該等級。"
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"列出你已學會的同組法術中的每一個，例如純淨術和清潔術。關閉時只列出最後學會的那個，但其他法術的巨集仍會更新。"
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"在未學會分類中列出你尚未學會的職業法術，方便提前放置它們的巨集。"

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "把法術放在游標所指的位置，不出現瞄準圈。"
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "施放友方玩家等級所能接受的最高等級。"
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] = "先停止你正在施放的法術，讓這個法術立刻施放。"
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "先停止你的近戰自動攻擊。"
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"你在引導法術時不做任何事，因此按下也絕不會打斷引導。"
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"你在潛行時不做任何事，因此按下也絕不會打破潛行或潛伏。"
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "先取消你目前的形態，以便施放法術。"
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] = "當你沒有選取活著的敵人時，先選取最近的敵人。"
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] = "當你沒有選取活著的友方時，先選取最近的友方。"
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "同時讓你的寵物攻擊你的目標。"
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "施法後開始你的近戰自動攻擊。"
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "施法後開始自動射擊或魔杖射擊。"
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "施放一次，直到你的目標改變前不再施放。"
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"施放一次，直到戰鬥結束或你的目標改變前不再施放。"
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"再次按下巨集時保持形態或守護開啟，而不是將其關閉。"
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "清除巨集在畫面上留下的紅色錯誤文字。"
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "巨集執行期間關閉錯誤音效。"
L["KIND_ENEMY"] = "敵對法術"
L["KIND_ENEMY_DESCRIPTION"] = "對敵人施放的法術，例如攻擊和減益效果。"
L["KIND_FRIENDLY"] = "友方法術"
L["KIND_FRIENDLY_DESCRIPTION"] = "對友方施放的法術，例如治療。"
L["KIND_BUFF"] = "增益法術"
L["KIND_BUFF_DESCRIPTION"] = "為友方施加持久增益效果的法術。"
L["KIND_RESURRECT"] = "復活法術"
L["KIND_RESURRECT_DESCRIPTION"] = "對死亡的友方施放、讓他們復活的法術。"
L["KIND_ANYONE"] = "友方或敵方法術"
L["KIND_ANYONE_DESCRIPTION"] = "既可以對友方也可以對敵人施放的法術。"
L["KIND_GROUND"] = "地面目標法術"
L["KIND_GROUND_DESCRIPTION"] = "放置在地面上的法術。"
L["KIND_FORM"] = "形態、姿態與守護"
L["KIND_FORM_DESCRIPTION"] = "在你關閉或切換之前一直保持的法術。"
L["KIND_SELF"] = "自身與範圍法術"
L["KIND_SELF_DESCRIPTION"] = "沒有目標，對自己或周圍施放的法術。"

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "開啟/關閉強化法術書"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟按鍵設定清單。"
L["KEY_BINDINGS_LOCATION"] = "開啟遊戲選單，依序進入 %s 和 %s，找到 Good to Go 分類。"
L["ERROR_MACRO_SLOTS_FULL"] = "沒有空的巨集欄位。請在 /macro 中刪除一個巨集來騰出位置。"
L["ERROR_MACRO_WINDOW_OPEN"] = "請先關閉巨集視窗。"
L["CHAT_MACROS_DELETED"] = "已刪除巨集：%d"
L["CHAT_MACRO_TOO_LONG"] =
	'"%s"巨集在開啟選項後為 %d 位元組，超過了巨集能容納的 %d 位元組。關閉一個選項來縮短它。'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'"%s"巨集長度為 %d 位元組，超過了巨集能容納的 %d 位元組，因此最後一行被截斷。'
