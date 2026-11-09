local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "zhCN")
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
	"版本 %s。设置（包括关闭此消息的选项）位于 选项 > 插件 > Good to Go。喜欢这个插件吗？告诉朋友，在 CurseForge 上收藏它，或在 GitHub 上为它点 Star。(="
L["OPTIONS_LEVEL_UP_TITLE"] = "帮助 Good to Go 升级"
L["OPTIONS_LEVEL_UP_THANKS"] = "感谢你选择 Good to Go！"

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

L["MACRO_BANDAGE"] = "- 绷带"
L["MACRO_EXPLOSIVES"] = "- 爆炸物"
L["MACRO_FEED_PET"] = "- 喂养宠物"
L["MACRO_FOOD"] = "- 食物"
L["MACRO_HEALTH_POTION"] = "- 治疗药水"
L["MACRO_HEALTHSTONE"] = "- 治疗石"
L["MACRO_MANA_GEM"] = "- 法力宝石"
L["MACRO_MANA_POTION"] = "- 法力药水"
L["MACRO_POISONS"] = "- 毒药"
L["MACRO_SOULSTONE"] = "- 灵魂石"
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

L["DIET_BREAD"] = "面包"
L["DIET_CHEESE"] = "奶酪"
L["DIET_FISH"] = "鱼"
L["DIET_FRUIT"] = "水果"
L["DIET_FUNGUS"] = "蘑菇"
L["DIET_MEAT"] = "肉"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"看来你发现了一个错误！%s（%s）无法在 %s > %s（%s）使用。请将此问题报告给我们，以便修复。谢谢！%s"
L["MESSAGE_NO_ITEM"] = "背包中未找到合适的%s。"
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"你的宏栏位已满，部分 Good to Go 宏无法创建。删除不再使用的宏以腾出栏位，或在 选项 > 插件 > Good to Go > 消耗品宏 中关闭你不需要的 Good to Go 宏。"
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	'你的宏已准备就绪。输入 %s，打开%s标签页，把"- 食物"、"- 水"和其他宏拖到你的动作条上。'
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s 已加入此角色的忽略列表。"
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "已从此角色的忽略列表中清除 1 件物品。"
L["MESSAGE_IGNORE_CLEARED_MANY"] = "已从此角色的忽略列表中清除 %d 件物品。"

L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"

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

L["READINESS_TITLE"] = "就绪报告"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s%s"
L["READINESS_CLAUSE_SEPARATOR"] = "。"

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "缺少增益："
L["READINESS_EXPIRING"] = "即将到期："
L["READINESS_MISSING_ITEMS"] = "缺少物品："
L["READINESS_DAMAGED_GEAR"] = "受损装备："
L["READINESS_CHARACTER"] = "角色："
L["READINESS_QUESTIONABLE_GEAR"] = "装备了非战斗装备："

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
L["READINESS_FLASK"] = "合剂或 2 种药剂"
L["READINESS_PET_FORMAT"] = "%s（宠物）"
L["READINESS_SCROLLS"] = "卷轴"
L["READINESS_SOULSTONE"] = "灵魂石未激活"
L["READINESS_HEALTHSTONE"] = "治疗石"
L["READINESS_MANA_GEM"] = "法力宝石"
L["READINESS_HEALING_POTION"] = "治疗药水"
L["READINESS_MANA_POTION"] = "法力药水"
L["READINESS_BANDAGES"] = "绷带"
L["READINESS_PVP_ON"] = "PvP 已开启"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d 分钟"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 不足 1 分钟"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s（%s）"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 个未使用的天赋点"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d 个未使用的天赋点"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "你目前没有任何对宠物有用的食物。"
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "你目前还没有学会%s、%s、%s或%s。"
L["TIP_NO_HAND_POISON"] = "这把武器所选的毒药已用完。"

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "你目前还没有学会%s。"

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "你的背包里没有%s了。右键点击 %s 制造更多。"
L["TIP_EMPTY_CREATE"] = "你的背包里没有%s了。右键点击 %s 制造一颗。"

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "增益食物"
L["FEATURE_SCROLL_BUFFS"] = "卷轴增益"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "增益食物与卷轴"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'使用提供"%s"的食物，并在进食前补上缺少的卷轴增益。'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "当前食物"
L["MINIMAP_BEST_PET_FOOD"] = "当前宠物食物"
L["MINIMAP_MAIN_HAND_POISON"] = "主手毒药"
L["MINIMAP_OFF_HAND_POISON"] = "副手毒药"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 报告"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d 项未完成订单"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "恭喜，你的补给已全部备齐！"
L["MINIMAP_RESTOCKER_EMPTY"] = "你的清单是空的。"

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "补货清单"
L["MENU_RESTOCKER_DESCRIPTION"] = "购买你清单上的物品，并在银行存取。"
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 右键点击"
L["MENU_OPTIONS"] = "GtG 选项"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 中键点击"

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
L["NOTE_MACRO_FEED_PET"] = "喂养宠物宏"
L["NOTE_MACRO_FOOD_WATER"] = "食物与水宏"
L["NOTE_MACRO_MANA_GEM"] = "法力宝石宏"
L["NOTE_MACRO_HEALTHSTONE"] = "治疗石宏"
L["NOTE_MACRO_SOULSTONE"] = "灵魂石宏"
L["NOTE_MACRO_POISONS"] = "毒药宏"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "召唤、喂养或复活"
L["NOTE_PET_MEND_CLICK"] = "右键点击，或战斗中点击"
L["NOTE_HOLD_SHIFT"] = "按住 Shift"
L["NOTE_PET_FORCE_REVIVE"] = "强制复活"
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
L["NOTE_CONJURE"] = "制造"
L["NOTE_CREATE"] = "制造"
L["NOTE_RIGHT_CLICK_AGAIN"] = "再次右键点击"
L["NOTE_LOWER_RANK_BACKUP"] = "低等级备用"
L["NOTE_MAGE_TARGET_LEVEL"] = "以等级较低的玩家为目标，即可按其等级制造。"
L["NOTE_WARLOCK_TARGET_LEVEL"] = "以等级较低的玩家为目标，即可按其等级制造一颗治疗石。"

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "毒药窗口"
L["NOTE_POISONS_REPLACED"] = "自动替换旧毒药。"

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "绷带"
L["LABEL_EXPLOSIVE"] = "爆炸物"
L["LABEL_FOOD"] = "食物"
L["LABEL_HEALTH_POTION"] = "治疗药水"
L["LABEL_HEALTHSTONE"] = "治疗石"
L["LABEL_MANA_GEM"] = "法力宝石"
L["LABEL_MANA_POTION"] = "法力药水"
L["LABEL_PET_FOOD"] = "宠物食物"
L["LABEL_POISON"] = "毒药"
L["LABEL_SOULSTONE"] = "灵魂石"
L["LABEL_WATER"] = "水"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "已启用"
L["MINIMAP_DISABLED"] = "已禁用"
L["MINIMAP_TOGGLE"] = "切换"
L["MINIMAP_OPEN"] = "打开"
L["MINIMAP_LEFT_CLICK"] = "左键点击"
L["MINIMAP_RIGHT_CLICK"] = "右键点击"
L["MINIMAP_MIDDLE_CLICK"] = "中键点击"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 左键点击"

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
	"选择你的食物宏何时提供%s：总是提供，或仅在单人时、小队或团队中、团队中、练级时或满级时提供。"
L["OPTIONS_MODE_CAPTION"] = "使用时机"
L["MODE_ALWAYS"] = "总是"
L["MODE_SOLO"] = "单人时"
L["MODE_PARTY"] = "在小队或团队中时"
L["MODE_RAID"] = "在团队中时"
L["MODE_LEVELING"] = "练级时"
L["MODE_MAX_LEVEL"] = "满级时"

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
L["INVENTORY_REPORT_TITLE"] = "库存报告"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "背包 %s，银行 %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "背包 %s"
L["INVENTORY_REPORT_BANK"] = "银行 %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "总计 %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"自动更新的宏，总是使用你最好的食物、水、药水和治疗石；自动购买材料和弹药并存入银行的补货清单；一键施放缺失的增益；以及为每个法术生成的鼠标悬停宏。"

-- Options: tree labels
L["TAB_ENHANCED_SPELLBOOK"] = "增强法术书"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"在法术书的新标签页中一键为每个职业法术生成鼠标悬停、光标和自我施法宏，无需任何宏语法。它们会随着你升级、训练和切换天赋自动更新。右键点击可添加焦点、停止施法、自动攻击、宠物攻击或饰品。"
L["SPELLBOOK_IS_OFF"] = "增强法术书已关闭。请在 选项 > 插件 > Good to Go > 增强法术书 中开启。"

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "启用欢迎消息"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "登录时在聊天框中输出欢迎消息。"

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "启用小地图按钮"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "显示小地图按钮。"

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
	"显示一个窗口，列出队伍中所有缺少你能施放的增益的成员。点击图标即可施放。"
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"按照你的补货清单为背包备足补给：从商人处购买、在银行存取物品，并在存量不足时提醒你。关闭后这些功能全部停止，补货清单窗口也不再可用。你的清单仍会保存。"
L["SWITCH_SPELLBOOK"] = "启用增强法术书"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	'在你的法术书中添加一个标签页，为你的法术生成鼠标悬停、光标和自我施法宏，并在你升级和训练时保持更新。关闭后隐藏该标签页并停止更新。它从不删除宏，删除宏需使用增强法术书面板上的"删除宏"按钮。'
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"关闭增强法术书？它的标签页会从法术书中移除，它生成的宏也不再随你升级和训练而更新。这不会删除它们：它们会按现在的样子留在你的动作条上。"
L["SWITCH_MACROS"] = "启用消耗品宏"
L["SWITCH_MACROS_DESCRIPTION"] =
	'随着背包变化，让你的食物、水、药水和其他消耗品宏始终指向背包中最好的物品。关闭后停止更新，每个宏保持最后的状态。它从不删除宏，要删除宏，请在消耗品宏面板的"要创建的宏"中取消勾选。'
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"关闭消耗品宏？你的宏不再随背包变化而更新，按钮可能会继续去取你已经用完的物品。这不会删除它们：它们会按现在的样子留在你的动作条上。"
L["SWITCH_INVENTORY_REPORT"] = "启用库存报告"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"在物品的鼠标提示中显示你的背包、银行以及本服务器其他角色各有多少件该物品。如果其他插件已显示这些数量，可以将其关闭。"
L["SWITCH_READINESS_REPORT"] = "启用就绪报告"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"就位确认开始时，私下列出你仍需处理的问题，例如缺少的增益、药水或受损的装备。一切就绪时不会输出任何内容。"

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "启用 Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "示例：%s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "打开你的补货清单。"

L["OPTIONS_LEVEL_UP_INTRO"] =
	"这个插件由热爱这款游戏、希望让每个人都尽可能玩得开心的玩家打造。我们永远不会请求捐款。真正让我们满足的，是知道我们的工作让你的游戏体验更好了一点。如果确实如此，我们很想听你说说！"
L["OPTIONS_LEVEL_UP_WAYS"] = "以下是你可以帮助我们触达更多玩家的几种方式。"
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 分享反馈：发现了错误或有新想法？请在 Discord 上告诉我们。你的反馈能帮助我们改进插件，也随时欢迎提交拉取请求。"
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 告诉朋友：认识可能会喜欢这个插件的人吗？告诉他们吧。口口相传能帮助更多玩家发现优秀的插件。"
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• 在 CurseForge 上收藏：打开下方的 CurseForge 链接，登录后点击 Download 按钮下方的星标。收藏能帮助更多玩家发现这个插件。"
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• 在 GitHub 上点 Star：打开下方的 GitHub 链接，登录后点击右上角的 Star。星标能帮助项目获得更多免费开发者工具的资格。"

L["OPTIONS_FEEDBACK"] = "反馈与支持"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "反馈与支持链接"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "要复制链接，请点击其输入框，然后按 Ctrl+A 和 Ctrl+C。"
L["OPTIONS_VERSION"] = "版本 %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "消耗品宏"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go 会为每种消耗品各建立一个宏，并随着背包变化保持更新，让你动作条上的按钮始终取用你身上最好的物品。请在下方选择要创建哪些宏，然后设置每个宏如何挑选物品。"

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "启用按钮上的宏名称"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"在你的动作条按钮上显示宏名称文字，Good to Go 默认会隐藏这些文字。"

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "要创建的宏"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	'选择 Good to Go 要创建并维护哪些宏。关闭某个宏也会将其移除。它们位于宏界面的"通用宏"标签页中，可直接拖到你的动作条上。'
L["OPTIONS_OPEN_MACRO_WINDOW"] = "打开宏界面"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	'打开游戏的宏界面并切换到"通用宏"标签页，这些宏就在那里。'
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "创建并维护此宏，取消勾选时会将其移除。"

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "食物与水"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"你的食物和水宏会使用背包中最好的食物和饮料。这些选项可以让增益食物、卷轴或魔法制造的食物和水优先，并让补货清单中的食物和水最后使用。"

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "优先增益食物"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益时，优先使用可提供该增益的食物，竞技场中除外。'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "启用卷轴增益"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"你的食物宏第一次按下时会使用缺少的卷轴，再按一次则进食；以友方玩家为目标或身处竞技场时会跳过卷轴。"
L["OPTIONS_SCROLL_TYPES"] = "在检查中包含卷轴类型"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "保护"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = '检查缺少的增益时包含"%s"。'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "优先使用魔法制造的食物与水"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'魔法制造的食物和水不花钱，并会在你下线后不久消失，因此你的食物和水宏会优先使用它们，即使背包里有恢复量更高的物品。开启"优先增益食物"时，增益食物仍然最先使用。'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"选择魔法制造的食物和水何时优先：总是优先，或仅在单人时、小队或团队中、团队中、练级时或满级时优先。"

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "最后使用补货清单中的食物与水"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"当两种食物或饮料恢复量相同时，你的食物和水宏会先使用不在补货清单上的那种，把补货清单购买的留到以后。"

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "药水与治疗石"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"宏在战斗中无法更改（这是暴雪的限制），因此每个药水和治疗石宏都预先包含你最好的物品以及最多两个备用物品。在较长的战斗中，图标和提示可能会过时并显示错误的物品，但点击该宏将始终使用你背包中实际拥有的最佳物品。"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "非战斗时在药水宏中使用食物与水"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"非战斗时，你的治疗药水宏会食用你最好的食物，法力药水宏会饮用你最好的水。战斗中则照旧使用你的药水。卷轴、宠物食物和魔法制造仍保留在食物和水宏中。"
L["OPTIONS_COMBINE_HEALTHSTONES"] = "将治疗石合并到治疗药水宏中"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"将你最好的治疗石添加到治疗药水宏的底部，这样按一次即可同时使用药水和治疗石。"

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "法力宝石与符文"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s、%s以及另外几种法力物品，都与法力宝石共享冷却时间。符文使用时会消耗生命值，因此除非你选择加入，否则法力宝石宏不会包含其中任何一种。"
L["OPTIONS_INCLUDE_MANA_RUNES"] = "将符文与其他法力物品加入法力宝石宏"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"将你的%s、%s，以及任何其他与法力宝石共享冷却时间的法力物品，和你的法力宝石一同排序，这样当其中某件物品是你的最佳选择，或你的法力宝石用完时，法力宝石宏就会使用该物品。"

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "增益补充"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"宏在战斗中无法更改，因此战斗中途到期的增益会一直缺失，直到战斗结束。"
L["OPTIONS_REAPPLY"] = "补充即将到期的增益"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"将剩余时间低于你所设阈值的增益食物、卷轴增益和宠物食物增益视为已到期，让你的宏在开怪前提供新的增益。"
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"设置增益离到期还剩多久时，你的宏就会提供新的增益。"
L["REAPPLY_THRESHOLD_ONE"] = "当剩余不足 1 分钟时"
L["REAPPLY_THRESHOLD_MANY"] = "当剩余不足 %d 分钟时"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "宠物食物增益"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = '少数食物会为你的宠物提供专属的"%s"增益。'
L["OPTIONS_USE_PET_BUFFS"] = "使用宠物食物增益"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'当你的宠物缺少"%s"增益时，将宠物食物加入你的食物宏，竞技场中除外。'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "在检查中包含宠物食物类型"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "爆炸物"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 选项会跳过目标指示圈，直接将爆炸物在你脚下引爆，非常适合目标处于近战距离时使用。另一个键则照常投掷。"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "点击方式"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"选择用哪个键投掷爆炸物，用哪个键将它在你脚下引爆。"
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "左键点击 @player"
L["EXPLOSIVES_MODE_TOSS"] = "左键点击投掷"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "职业与种族"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"这些选项会针对某个职业或种族调整你的宏。所有分区在每个角色上都会显示。"

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "职业选项：%s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "种族选项：%s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"需要 DruidMacroHelper 插件。开启后，你的治疗药水、法力药水和治疗石宏会让你脱离形态、使用物品，再让你回到熊形态或猎豹形态，取决于你在复选框旁选择的那个。"
L["OPTIONS_DRUID_MACRO_HELPER"] = "启用 DruidMacroHelper 整合"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"使用 DruidMacroHelper (/dmh) 为治疗药水、法力药水和治疗石构建变形宏。"
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] = "选择你的变形宏在使用物品后让你返回哪种形态。"
L["DRUID_FORM_BEAR"] = "返回熊形态"
L["DRUID_FORM_CAT"] = "返回猎豹形态"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"让毒药宏始终装载每种毒药类型可用的最高等级。左键涂抹副手，右键涂抹主手，已有毒药会自动替换。"
L["OPTIONS_POISON_MAIN_HAND"] = "主手毒药类型"
L["OPTIONS_POISON_OFF_HAND"] = "副手毒药类型"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] = "选择你的毒药宏在右键点击时涂抹到主手的毒药。"
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] = "选择你的毒药宏在左键点击时涂抹到副手的毒药。"
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "启用进食时潜行"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "将%s添加到你的食物宏中，以便你在进食时潜行。"

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "启用喝水时潜行"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "将%s添加到你的水宏中，以便你在喝水时潜行。"
L["OPTIONS_STEALTH_PICK_ONE"] =
	"专业提示：只选一个。你可以同时进食和喝水，但潜行后再进食或喝水会解除潜行。"

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"选中一个你杀死的人型生物或亡灵，你的宏会在%s不在冷却中时施放它，节省你的食物和饮料。如果无法施放（尸体超出距离，或该技能正在冷却），则照常进食或喝水。"
L["OPTIONS_CANNIBALIZE_EATING"] = "使用%s代替进食"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"当你的目标是%s可用的尸体且该技能不在冷却中时，你的食物宏会施放它而不是进食。否则照常进食。卷轴和增益食物仍然优先。"
L["OPTIONS_CANNIBALIZE_DRINKING"] = "使用%s代替喝水"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"当你的目标是%s可用的尸体且该技能不在冷却中时，你的水宏会施放它而不是喝水。否则照常喝水。增益饮料仍然优先。"

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"当%s冷却完毕时，你的食物宏会施放它而不是进食，以节省食物。冷却期间，宏会照常进食。"
L["OPTIONS_RAPID_REGENERATION_EATING"] = "使用%s代替进食"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"当%s冷却完毕时，你的食物宏会施放它而不是进食。否则照常进食。卷轴和增益食物仍然优先。"

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
	"被忽略的物品永远不会被任何宏选用。食物、水、药水，任何东西都一样。全局列表对所有角色生效；角色列表只对该角色生效。右键点击小地图按钮可忽略你当前的最佳食物。"
L["OPTIONS_IGNORE_GLOBAL"] = "全局"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "将此物品移至全局列表，使其在所有角色上都被忽略。"
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "从背包添加"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"从你携带的物品中任选一件。打开选项界面时背包会关闭，所以这里代替了把物品拖到此处的操作。"
L["OPTIONS_IGNORE_ADD_ID"] = "按物品 ID 添加"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"输入物品 ID，或在此输入框处于焦点时按住 Shift + 点击聊天中的物品链接。"
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "输入物品 ID，或按住 Shift + 点击聊天中的物品链接。"
L["OPTIONS_IGNORE_REMOVE"] = "移除"
L["OPTIONS_IGNORE_EMPTY"] = "此列表为空。"
L["OPTIONS_IGNORE_CLEAR"] = "清空列表"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"移除此列表中的所有物品。列表为空的角色会从左侧列表中消失，除非是你当前正在玩的角色。"
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "移除此列表中的所有物品？此操作无法撤销。"
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "正在载入 ID：%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"根据你的补货清单保持背包物资充足，自动向商人购买，并在背包与银行之间搬运物品。输入 %s 打开清单。"
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "在银行打开"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "访问银行时打开你的补货清单。"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "在商人处打开"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "访问商人时打开你的补货清单。"
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "提醒"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] = "选择何时提醒你补货清单存量不足。"
L["OPTIONS_RESTOCKER_REMIND"] = "启用城镇补货提醒"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"当补货清单尚有缺口，且你抵达旅店或城市，或登录时已身处其中，在聊天中输出提醒。"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "启用商人补货提醒"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] = "关闭商人窗口时，报告所有未完成的补货订单。"
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "启用银行补货提醒"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "关闭银行时，报告所有未完成的补货订单。"

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "金币储备"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] = "预留一部分金币，向商人购买时绝不动用。"
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "启用金币储备"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "补货永远不会花掉你在此预留的金币。"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "设置补货始终为你保留的金币数量。"

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"选择提醒只有一行，还是为你缺少的每件物品各加一行。"
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "提醒详略"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "简洁"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "详细"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "播放声音"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "在提醒的同时播放提示音，适合聊天繁忙的时候。"
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "点击试听提示音。"

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "补货清单窗口"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "选择你的补货清单何时自动打开。"

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"在物品提示中显示你在本服务器所有角色上共有多少件该物品。"
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "已记录的角色"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "忘记"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"忘记 %s？该角色的背包和银行数量将从所有物品提示中移除，其补货清单选择也会被清除。再次登录该角色时会重新记录。"

-- Readiness Report
L["TAB_READINESS_REPORT"] = "就绪报告"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"就位确认开始时，输出一份仅你可见的清单，列出仍需处理的事项；如果你已准备就绪，则完全不会输出任何内容。"

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "重置就绪报告设置"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] = "将本页的所有复选框和两个阈值恢复为默认值。"
L["OPTIONS_READINESS_RESET_CONFIRM"] = "将就绪报告的所有设置重置为默认值？"

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
	"缺少合剂时提醒。一瓶合剂，或战斗药剂与守护药剂各一瓶，均视为已满足。"
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益时提醒。需要在消耗品宏中开启增益食物。'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'你的宠物缺少"%s"增益时提醒。需要在消耗品宏中开启宠物食物增益，并且宠物在场。'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"缺少卷轴增益时提醒。需要在消耗品宏中开启卷轴增益，并且只检查在那里选中的卷轴类型。"
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"当队伍中没有人身上有生效的灵魂石时提醒；背包里的灵魂石不算。仅提醒能制造灵魂石的术士。"
L["OPTIONS_READINESS_MAIN_HAND"] = "主手武器增益"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"主手武器没有临时附魔时提醒。任何附魔都算，且队伍中有萨满祭司时不会报告此项。"
L["OPTIONS_READINESS_OFF_HAND"] = "副手武器增益"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"副手武器没有临时附魔时提醒。任何附魔都算：磨刀石、油剂、毒药或萨满祭司的武器增益。"
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"主手武器缺少临时附魔时提醒。潜行者和萨满祭司需要两项：毒药或武器灌注，加上油剂或磨刀石；其他职业有任意一项即可。"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"副手武器缺少临时附魔时提醒。潜行者需要两项：毒药，加上油剂或磨刀石；其他职业有任意一项即可。"
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "增益到期时间少于"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"列出你身上所有即将到期的增益，不只是 Good to Go 施加的那些；此项与消耗品宏中的增益补充互不相关。"
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s 分钟"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 分钟"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"设置增益离到期还剩多久时，报告才会列出它。"

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"当你身上没有治疗石时提醒。仅当队伍中有可以索要的术士，或你自己就是术士时才提醒。"
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"当你身上没有法力宝石时提醒。仅提醒能制造法力宝石的法师。"
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"当你身上没有治疗药水时提醒，因为战斗中没人能递给你药水。"
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"当你身上没有法力药水时提醒。仅当你的角色是使用法力的职业时才提醒。"
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] = "当你身上没有%s技能允许使用的绷带时提醒。"
L["OPTIONS_READINESS_DURABILITY"] = "受损装备低于"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"链接耐久度低于该值的每件已装备物品；按单件计算，因此即使只有一把武器损坏也会显示。"
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"设置物品耐久度降到多低时，报告才会链接它。"

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "当前天赋"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "输出你的天赋分配，以及尚未使用的点数。"
L["OPTIONS_READINESS_PVP"] = "PvP 标记开启"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "当你的 PvP 标记开启时发出警告。"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "装备了非战斗装备"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"链接不该出现在战斗中的已装备物品，比如骑乘装备或钓鱼装备。"

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "等级守望"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"留意你的队伍中有谁施放了低于自己可用等级的法术，并告诉对方训练师那里有更高等级在等着。游戏自动降低的等级（例如对低等级玩家施放的增益）永远不会被报告。"
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s 仍在运行，因此等级守望暂时保持沉默，以免你的队伍对每个低等级法术都听到两次提醒。Good to Go 已关闭它并开启了等级守望；重载界面后即由等级守望接手。"

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s（%s）"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "等级 %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"友情提示，没啥大不了的：你刚才用的是%s，%d级就有更新的等级了。更新一下动作条或者去找训练师，马上就 Good to Go。"
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"友情提示，没啥大不了的：你的宠物%s刚才用的是%s，宠物%d级就有更新的等级了。用训练野兽教给它，马上就 Good to Go。"
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"友情提示，没啥大不了的：你的%s刚才用的是%s，%d级就有更新的等级了。去恶魔训练师那里买本魔典，马上就 Good to Go。"
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"不想再收到这类提示？回复 %s，我就不会再因为法术等级密语你了。这个号码对所有使用 Good to Go 的人都有效。"
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] = "收到，我不会再给你发等级提示了。"
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	'%s 发送了免打扰号码，等级守望现在会忽略此玩家。可在等级守望的"已忽略的玩家"中撤销。'
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"你施放了%s，而%s从%d级起即可获得。去找训练师或更新你的动作条吧。"
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "你的宠物%s施放了%s，而%s从宠物%d级起即可获得。"
L["RANK_WATCH_PRINT_SELF_DEMON"] = "你的%s施放了%s，而%s从%d级起即可获得。"
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s 施放了%s，而%s对其来说从%d级起即可获得。"
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] = "%s 的宠物%s施放了%s，而%s对它来说从宠物%d级起即可获得。"
L["RANK_WATCH_PRINT_OTHER_DEMON"] = "%s 的%s施放了%s，而%s对它来说从%d级起即可获得。"
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s 会密语对方。"

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "启用等级守望"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"当有人施放了低于自己可用等级的法术时，提醒你并密语你的队伍成员，让对方知道该去找训练师了。"

L["RANK_WATCH_MESSAGES_HEADER"] = "通知"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] = "等级守望如何告知玩家他们施放了低等级法术。"
L["RANK_WATCH_WHISPER"] = "密语队伍成员"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"密语施放了低等级法术的队伍成员。当你的队伍中有多名玩家运行等级守望或 Rank Sentinel 时，只有其中一人会发送密语。"
L["RANK_WATCH_PRINT"] = "输出队伍成员的低等级法术"
L["RANK_WATCH_PRINT_DESCRIPTION"] =
	"在你的聊天框中输出队伍成员施放的低等级法术。你自己的低等级法术总是会输出。"
L["RANK_WATCH_GRACE_HEADER"] = "宽限期"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"新的法术等级要等施法者超过其学习等级若干级（由此处设定）后才会报告，这样没人会因为刚刚达到、还没来得及训练的法术等级而收到提醒。"
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "满级宽限期"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"对于已满级的角色，学习等级在满级以下这么多级以内的法术等级不会被报告。设为 0 时，他们可拥有的每个法术等级都会被报告。"
L["RANK_WATCH_GRACE_LEVELING"] = "练级宽限期"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"对于仍在练级的角色，学习等级与其当前等级相差在这么多级以内的法术等级不会被报告，给他们时间去找训练师。"
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 级"
L["RANK_WATCH_GRACE_LEVELS"] = "%d 级"

L["RANK_WATCH_OPT_OUT_HEADER"] = "免打扰"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	'等级守望第一次密语某人时，会接着发送对方的免打扰号码。这个号码由对方的名字生成，因此所有使用 Good to Go 的人发出的号码都相同。如果对方在密语或任何你能看到的聊天频道中说出这个号码，就会被加入"已忽略的玩家"，之后再也不会收到你发出的等级提醒。若要自己忽略某人，请选中对方并输入 /gtg ignore。'
L["RANK_WATCH_WHISPERER_HEADER"] = "由谁为队伍报告"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"当你的队伍中有多人运行等级守望或 Rank Sentinel 时，只有其中一人会发送密语，这样施放了低等级法术的玩家只会收到一次提醒，而不是每个人都提醒一遍。其他人只会在自己的聊天框中输出。以下是目前负责发送密语的人。"
L["RANK_WATCH_WHISPERER_SELF"] = "由你发送。"
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "由 %s 发送，所以你只会看到聊天输出。"
L["RANK_WATCH_WHISPERER_NONE"] = "无人：密语队伍成员已关闭。"

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "已忽略的玩家"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "等级守望永远不会报告这些玩家。"
L["RANK_WATCH_IGNORED_NONE"] = "暂时没有。"
L["RANK_WATCH_IGNORED_REMOVE"] = "取消忽略"
L["RANK_WATCH_IGNORE_TARGET"] = "忽略目标"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "将你当前选中的玩家加入列表。"
L["RANK_WATCH_IGNORE_ADDED"] = "等级守望现在会忽略 %s。"
L["RANK_WATCH_IGNORE_NOT_FOUND"] = "找不到 %s。请与对方组队或选中对方，然后再试一次。"
L["RANK_WATCH_IGNORE_NO_TARGET"] = "请选中一名玩家，或输入 /gtg ignore 名字。"
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore 名字"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"等级守望将不再报告该玩家。不带名字时，忽略你的目标。"

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"等级守望要报告的法术等级，按职业列出。取消勾选你有意降级使用的等级，等级守望就不会理会它。所有技能都会列出。等级守望默认不监视的技能，例如治疗法术、天赋以及等级 1 的灼烧，初始为未勾选。技能的最高等级显示为灰色，因为没有比它更高的等级。"
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s（%d级）"
L["RANK_WATCH_RANK_DESCRIPTION"] = "有更高等级可用时报告此等级。"
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "最高等级。没有比它更高的等级，因此永远不会被报告。"
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s宠物"
L["RANK_WATCH_TRACK_ALL"] = "全部勾选"
L["RANK_WATCH_TRACK_NONE"] = "全部取消勾选"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '已存在名为"%s"的清单。'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "没有 ID 为 %d 的物品。"
L["RESTOCKER_DISABLED"] = "Restocker 已关闭。请在 选项 > 插件 > Good to Go > Restocker 中开启。"
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"补货完成。打开银行时按住 Shift 可跳过补货。输入 %s 编辑你的补货清单。"
L["RESTOCKER_STOPPED_BOTH_FULL"] = "补货已停止。你的背包和银行都已满。"
L["RESTOCKER_STOPPED_BANK_FULL"] = "补货已停止。你的银行已满；请腾出一格后重新打开。"
L["RESTOCKER_STOPPED_BAG_FULL"] = "补货已停止。你的背包已满；请腾出一格后重新打开银行。"
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "补货已停止。无法继续进行。"
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "补货已停止。无法移动：%s。"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s（多余）"
L["RESTOCKER_STOPPED_ERROR"] = "补货因错误而停止：%s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"这个商人没有出售你的毒药所需的全部材料。跳过购买这些材料。"
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "在城里的时候别忘了补货！"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "还有 1 项补货订单未完成。"
L["RESTOCKER_STILL_SHORT_MANY"] = "还有 %d 项补货订单未完成。"

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "你的补货清单已升级。"
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d 升级为 %sx%d。"

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
L["RESTOCKER_RESTOCKED_ONE"] = "已完成 1 项补货订单。"
L["RESTOCKER_RESTOCKED_MANY"] = "已完成 %d 项补货订单。"

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "有 1 项补货订单仅部分完成。"
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "有 %d 项补货订单仅部分完成。"
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "背包在全部购买完成前就已装满。"
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "金币不足，无法完成补货。"
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] = "你的金币不足%s。金币增加后将继续补货。"

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[名称]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "添加一个以该名称命名的清单。"
L["RESTOCKER_HELP_PROFILE_DELETE"] = "删除该名称的清单。"
L["RESTOCKER_HELP_PROFILE_RENAME"] = "将当前清单重命名为该名称。"
L["RESTOCKER_HELP_PROFILE_COPY"] = "用该名称的清单副本替换当前清单。"
L["RESTOCKER_HELP_PROFILE_USE"] = "将此角色切换到该名称的清单。"

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
L["STARTER_POPUP_TITLE"] = "基础物资"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "完成"
L["STARTER_POPUP_INTRO_LOGIN"] = "我们已为你的职业勾选了一些基础物资，帮你快速上手。"
L["STARTER_POPUP_INTRO_EMPTY"] = "你的补货清单是空的，我们来添加一些物品好让你上手。"
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "挑选你想保持备足的基础物资。"
L["STARTER_POPUP_INTRO_HOW"] =
	"你勾选的一切都会在你打开商人或银行时自动补足。大多数基础物资会随着等级提升自动升级，所以你手上永远是当前最好的。"
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "你随时可以输入 %s 来调整这份清单，或稍后添加更多物品。"
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "食物与水"
L["STARTER_POPUP_FOOD_HEADER"] = "食物"
L["STARTER_POPUP_AMMO_HEADER"] = "弹药"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "子弹"
L["STARTER_POPUP_ARROWS"] = "箭矢"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "施法材料与工具"
L["STARTER_POPUP_POISONS_HEADER"] = "毒药"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s：将成品毒药加入你的清单，Good to Go 会在任何出售全部所需材料的商人处自动购买这些材料。"
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"将 %s 加入你的补货清单，在背包中保留 %d 个，并随着你的等级自动升级。"
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "将 %s 加入补货清单，并在背包中保留 %d 个。"
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 组"
L["STARTER_POPUP_STACK_MANY"] = "%d 组"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "要保持备足多少组，每组 %d 个。"
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"要保持备足多少个；这些物品无法堆叠，因此每个都会占用一个背包格。"

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "补货清单"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "筛选物品……"
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "清除"
L["RESTOCKER_ADD_BUTTON"] = "添加"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "挑选基础物资"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"从适合你职业和等级的基础物资中选择：食物、水、弹药、毒药和施法材料。勾选一项即可将其加入此清单，取消勾选则会将其移除。"
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "添加物品"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"将背包中的物品拖到这里或此窗口的任意位置，或输入物品 ID 后按回车。"
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "拖入物品或输入物品 ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "请改为输入物品 ID。"
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "已在此清单中。"
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "从背包添加物品"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] = "你背包中尚未加入此清单的所有物品，随时可以添加。"
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "背包中没有可添加的物品"

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
L["RESTOCKER_PROFILE_LABEL"] = "清单"
L["RESTOCKER_PROFILE_TOOLTIP"] = "为此角色切换到其他补货清单，或新建一个清单。"
L["RESTOCKER_USED_BY"] = "使用者：%s"
L["RESTOCKER_MANAGE"] = "管理清单"
L["RESTOCKER_MANAGE_TOOLTIP"] = "新建一个清单，或复制、重命名、删除此清单。"
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "新清单"
L["RESTOCKER_MANAGE_COPY"] = "将此清单复制为新清单"
L["RESTOCKER_RENAME_PROFILE"] = "重命名此清单"
L["RESTOCKER_MANAGE_DELETE"] = "删除此清单"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 副本"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s（%d）"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "重命名"
L["RESTOCKER_RENAME_TOOLTIP"] = "重命名此清单，对所有使用它的角色生效。"
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "确定要删除此清单吗？"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s 也在使用此清单，下次登录时将进入一个同名的空清单。"
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s 也在使用此清单，下次登录时将各自进入一个同名的空清单。"
L["RESTOCKER_DELETE_LIST_SWITCH"] = "你将切换到 %s。"
L["RESTOCKER_DELETE_LIST_LAST"] = "这是仅剩的一个清单，因此你将从一个新的空清单开始。"
L["RESTOCKER_DELETE_LIST_FINAL"] = "此操作无法撤销。"
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "随等级升级"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"允许 Good to Go 在你升级时，将食物、水、弹药、毒药、药水和职业施法材料升级为更好的物品。"

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "升级"

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
L["RESTOCKER_COLUMN_REPUTATION"] = "声望"
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
L["RESTOCKER_COLUMN_BULK_HINT"] = "此标题可为当前显示的所有物品设置此项。"
L["RESTOCKER_BULK_ON"] = "为显示的 %d 件物品开启"
L["RESTOCKER_BULK_OFF"] = "为显示的 %d 件物品关闭"

L["RESTOCKER_GROUP_OTHER"] = "未分类"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "新增"
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
L["RESTOCKER_EMPTY_TITLE"] = "此清单中还没有物品"
L["RESTOCKER_EMPTY_BODY"] =
	"挑选食物、水或职业施法材料等基础物资，或通过上方的菜单添加背包中的任何物品。此清单中的物品会自动补足或存入你的银行，让你的背包保持整洁。"
L["RESTOCKER_EMPTY_DROP_HINT"] = "将物品拖到此窗口的任意位置也能添加。"
L["RESTOCKER_NO_MATCH_FILTER"] = "此清单中没有符合筛选条件的物品。"
L["RESTOCKER_NO_MATCH_GROUP"] = "此分类中已没有物品。"

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
L["RESTOCKER_NO_ORDERS"] = "没有未完成的补货订单。"
L["RESTOCKER_REPORT_MORE"] = "还有 %d 项。"
L["RESTOCKER_REMOVED_ITEM"] = "已移除 %s。"
L["RESTOCKER_UNDO"] = "撤销"
L["RESTOCKER_UNDO_TOOLTIP"] = "将此物品放回清单"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "将此物品从补货清单中移除"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "你可以在清单顶部撤销此操作。"
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "在背包中保留"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'要在背包中保留多少个。背包中的数量少于此数时，该数字会显示为黄色；若设为 0 并开启"存入"，则会将其全部存入银行。'
L["RESTOCKER_BUY_LABEL"] = "购买"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "向商人购买"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "商人窗口打开时，向商人购买所需数量。"

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "额外"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "额外购买"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"买下商人此物品的全部限量库存（即每次只有少量、会慢慢刷新的商品），即使超出你的保留数量。"
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "存入银行"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"银行打开时，将多余的物品存入银行；若保留栏填写 0，则全部存入。"
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "从银行取出"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "银行打开时，从银行取出所需物品。"

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "所需声望"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s（优惠 %d%%）"
L["RESTOCKER_REPUTATION_ANY"] = "任意"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "所需商人声望"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"设置 Good to Go 向商人购买前所需的声望等级；声望还会降低价格：%s 5%%，%s 10%%，%s 15%%，%s 20%%。短横线表示向任何商人购买。"

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = '此物品的"购买"已关闭，因此无法额外购买。'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = '此物品的"购买"已关闭，因此声望要求不适用。'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "此物品没有可升级的更好版本。"

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] =
	"Good to Go 已关闭被它取代的 %s。现在重载界面，让旧插件停止运行吗？"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "立即重载"
L["POPUP_REPLACED_LATER"] = "稍后"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "已复制你的 %s 设置。"

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go 已从 %s 复制了你的设置，并关闭了被它取代的 %s。现在重载界面，让旧插件停止运行吗？"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go 发现已安装但被关闭的 %s。要把设置迁移过来吗？这会重新开启旧插件并重载界面，之后会再提供一次重载，将它们重新关闭。"
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go 发现已安装但被关闭的 %s。要把设置和补货清单迁移过来吗？这会重新开启旧插件并重载界面，之后会再提供一次重载，将它们重新关闭。"
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "迁移过来"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "不用了，谢谢"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "队伍增益"
L["RANK_WATCH_TRACKED_HEADER"] = "报告的法术等级"
L["TRACKED_ITEM_PENDING"] = "物品 #%d"
L["TRACKED_SPELL_PENDING"] = "法术 #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "播放该音效，让你在开启前先试听。"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "增益值班"
L["BUFF_DUTY_DESCRIPTION"] = "显示谁缺少你的增益。点击图标即可施放。"
L["BUFF_DUTY_ENABLE"] = "启用增益值班"
L["BUFF_DUTY_NO_BUFFS"] =
	"你的职业没有此列表中的增益，因此该窗口在这个角色上永远不会出现。"
-- When to Show: Solo, In Party and In Raid, each with Always or In Instance, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "显示时机"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "选择窗口何时可以出现。"
L["BUFF_DUTY_WHEN_SOLO"] = "单人"
L["BUFF_DUTY_WHEN_SOLO_DESCRIPTION"] = "不在小队或团队中时显示窗口。"
L["BUFF_DUTY_WHEN_PARTY"] = "在小队中"
L["BUFF_DUTY_WHEN_PARTY_DESCRIPTION"] = "在小队中时显示窗口。"
L["BUFF_DUTY_WHEN_RAID"] = "在团队中"
L["BUFF_DUTY_WHEN_RAID_DESCRIPTION"] = "在团队中时显示窗口。"
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"设置窗口在哪里显示：任何地方，或仅在地下城、团队副本、战场和竞技场内。"
L["BUFF_DUTY_WHERE_ALWAYS"] = "总是"
L["BUFF_DUTY_WHERE_INSTANCE"] = "在副本中"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "在玩这些职业时显示窗口。"
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "在玩此职业时显示窗口。"
L["BUFF_DUTY_HEADER"] = "窗口"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "让窗口留在你放置的位置，或在战斗中不挡视线。"
L["BUFF_DUTY_LOCK"] = "锁定窗口"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "使窗口无法移动。解锁后，可拖动其背景来移动窗口。"
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "战斗中隐藏"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"在战斗中隐藏窗口。战斗中列表无法更新，因此保持显示的窗口会停留在最后的状态，直到战斗结束。"
L["BUFF_DUTY_SHOW_HEADER"] = "在窗口中显示"
L["BUFF_DUTY_SHOW_DESCRIPTION"] =
	"将你自己的增益、为你施放增益的陌生人以及你的目标加入窗口。"
L["BUFF_DUTY_FAVOR_ENABLE"] = "礼尚往来"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"列出最近为你施放增益的陌生人，以及你可以回赠他们的增益。右键点击图标可将某人从列表中移除。"
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] = "设置陌生人在最后一次施放增益后保留在列表中的时间。"
L["BUFF_DUTY_TARGET_ENABLE"] = "你的目标"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"当你的目标是缺少你可施放增益的队伍外玩家时，将其列出。"
L["BUFF_DUTY_ASK_OTHERS"] = "向其他职业请求增益"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	'在"缺少的队伍增益"下显示你的队伍缺少的团队增益，以及每种增益有多少人需要。左键点击一个即可向队伍请求，右键点击则密语能施放它的玩家。'
L["BUFF_DUTY_REFRESH"] = "剩余低于此值时补充"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"设置增益剩余时间低于多少时视为缺失，方便你在增益消失前及时补上。持续时间不超过此值的增益，只有在消失后才会视为缺失。"
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "视为坦克"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"没有自身职责时，谁能获得你提供给坦克的增益，例如荆棘术。"
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"设置此职业的玩家何时视为坦克。他们自己的坦克或治疗职责始终优先。"
L["BUFF_DUTY_TANKS_PETS"] = "宠物"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] =
	"设置宠物何时视为坦克。宠物也会获得你提供给所有人的增益。"
L["BUFF_DUTY_TANKS_NEVER"] = "从不"
L["BUFF_DUTY_TANKS_SOLO"] = "不在队伍中时"
L["BUFF_DUTY_TANKS_ALWAYS"] = "总是"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "关闭"
L["BUFF_DUTY_AUDIENCE_TANK"] = "坦克"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "治疗"
L["BUFF_DUTY_AUDIENCE_ALL"] = "所有人"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "设置 %s 提供给谁。"
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"选择每个增益提供给谁。坦克和治疗按队伍职责判定，但在团队中只有被设为%s的玩家才算坦克。没有职责的人视为伤害输出，除非下方的视为坦克另有设置。"

L["BUFF_DUTY_SELF_DESCRIPTION"] = "你自己的增益，固定在窗口顶部。"
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "任意一种守护即可"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "任意一种护甲即可"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "任意一种光环即可"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "任意一种护盾即可"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "任意一种护甲即可"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "两种恶魔增益任意一种即可"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "关闭"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "缺失时"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "剩余不足%s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"设置 %s 何时显示：从不、消失后，或剩余时间少于此值时。"
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "武器增益"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"勾选每把武器应保持的效果。当效果缺失或即将结束，且物品在你的背包中并适用于该武器时，窗口会提供它。"
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "重新施加"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"设置武器增益何时再次提供：消失后，或剩余时间少于此值时。"
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "油"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "磨刀石"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "鱼饵"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"提供%s，用于你的%s武器。当武器上没有任何已勾选的选项时，会提供你拥有的每一种。"
L["BUFF_DUTY_SELF_ENABLE"] = "你的自身增益"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"当只能对自己施放的增益（例如护甲类法术或心灵之火）缺失或即将结束时，将其显示在窗口顶部。可在自身增益中选择要显示哪些。"
L["BUFF_DUTY_WEAPON_ENABLE"] = "你的武器增益"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"将武器上缺失或即将结束的毒药、武器强化、油、磨刀石和鱼饵，与你的自身增益一起显示在窗口顶部。点击即可施加。可在武器增益中选择要显示哪些。"

-- The window itself
L["BUFF_DUTY_SELF_HEADER"] = "自身增益"
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "缺少的自身增益"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "缺少的队伍增益"
L["BUFF_DUTY_FAVOR_HEADER"] = "礼尚往来"
L["BUFF_DUTY_TARGET_HEADER"] = "目标"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "对 %s 施放。"
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "施加到你的%s武器。"
L["BUFF_DUTY_TOOLTIP_USE"] = "你的队伍中没有人有灵魂石。对 %s 使用一块。"
L["BUFF_DUTY_TOOLTIP_CREATE"] = "你的队伍中没有人有灵魂石。制造一块。"
L["BUFF_DUTY_TOOLTIP_GROUP"] = "对 %s 及其小队施放。"
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "选中 %s 为目标并施放。"
-- A Party-Buffs icon's menu: a raid buff your group is missing, and its count.
L["BUFF_DUTY_OTHERS_TOOLTIP_COUNT"] = "缺少或即将消失：%d"
-- The menu's rows: the first asks the party or raid for the buff (its name), the second whispers the players who can cast it (their names).
L["BUFF_DUTY_OTHERS_MENU_ASK_GROUP"] = "向队伍请求%s"
L["BUFF_DUTY_OTHERS_MENU_WHISPER"] = "密语 %s"
--[[
    The ask either row sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s缺少%s。"
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s缺少%s。"
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d名玩家缺少%s增益。"
-- Your own chat, after the Whisper row: who was whispered, then the buff's link.
L["BUFF_DUTY_OTHERS_SENT"] = "已向 %s 发送%s的密语。"
-- The window's close button: the class name, the class name again for its checkbox, the When to Show
-- header, then the options command.
L["BUFF_DUTY_CLOSED"] =
	'已为%1$s职业关闭增益值班。要重新开启，请 Shift + 左键点击小地图按钮，或在 %4$s 的"%3$s"下勾选"%2$s"。'

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "增益按钮"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "正在等待 %s 进入范围。"
L["BUFF_KEY_DONE"] = "没有需要施放的增益了。"
L["BUFF_KEY_OFF"] = "增益值班已关闭。"

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "未学会"
L["SECTION_CONSUMABLES"] = "GtG 消耗品"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "宏文本"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "动态等级"
L["MENU_DYNAMIC_RANK_NOTE"] = "动态等级根据友方玩家的等级决定，只在非战斗状态下更新。"
L["MENU_CAST_AT_CURSOR"] = "在光标处施放"
L["MENU_TARGET_NEAREST_ENEMY"] = "选择最近的敌人"
L["MENU_TARGET_NEAREST_FRIEND"] = "选择最近的友方"
L["MENU_CAST_IF_SUMMONED"] = "宠物已召唤时施放%s"
L["MENU_NEVER_TURN_OFF"] = "永不关闭"
L["MENU_LEAVE_FORM_BEFORE"] = "施法前取消形态"
L["MENU_RIGHT_CLICK_FOR"] = "右键点击施放%s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "右键点击施放群体版本"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "应用到所有%s"
L["MENU_ONCE_PER_COMBAT"] = "每场战斗施放一次"
L["MENU_ONCE_PER_TARGET"] = "每个目标施放一次"
L["MENU_HIDE_ERRORS"] = "隐藏错误"
L["MENU_MUTE_ERRORS"] = "错误静音"
L["MENU_SWITCH_TO"] = "切换为%s"
L["MENU_START_AUTO_ATTACK"] = "开始自动攻击"
L["MENU_STOP_ATTACK"] = "停止攻击"
L["MENU_START_AUTO_SHOT"] = "开始自动射击"
L["MENU_START_PET_ATTACK"] = "开始宠物攻击"
L["MENU_START_WAND"] = "开始魔杖射击"
L["MENU_STOP_CASTING"] = "停止施法"
L["MENU_STOP_CASTING_NOTE"] = "对打断、驱散这类不能等待的法术使用停止施法。"
L["MENU_STOP_IF_CHANNELING"] = "引导时不施放"
L["MENU_STOP_IF_STEALTHED"] = "潜行时不施放"
L["MENU_DUPLICATE"] = "复制"
L["MENU_DELETE"] = "删除"
L["MENU_DELETE_USED_ONE"] = "删除（用于 1 个动作条）"
L["MENU_DELETE_USED"] = "删除（用于 %d 个动作条）"
L["MENU_DELETE_DESCRIPTION"] =
	"从你的宏中删除此宏，这会将它从动作条上移除，并重置它的所有选项。在本页点击或拖动它即可重新生成。"
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"将此副本从本页移除，并从你的宏中删除，这会将它从动作条上移除。"
L["MENU_DELETE_CONFIRM"] = "删除 %s？它会从你的动作条上移除，选项也会重置。"
L["MENU_GROUP_RANK"] = "等级"
L["MENU_GROUP_WHEN"] = "时机"
L["MENU_GROUP_FIRST"] = "首先"
L["MENU_GROUP_THEN"] = "然后"
L["MENU_GROUP_ERRORS"] = "错误信息"
L["MENU_GROUP_GROUPED"] = "合并法术"
L["MENU_GROUP_TARGET"] = "目标"
L["MENU_PRIORITY_1"] = "第一优先"
L["MENU_PRIORITY_2"] = "第二优先"
L["MENU_PRIORITY_3"] = "第三优先"
L["MENU_PRIORITY_DESCRIPTION"] =
	"宏依次尝试的对象。某个对象无法承受该法术时会被跳过；如果都不行，就像普通法术一样施放。"
L["MENU_UNIT_NONE"] = "无"
L["MENU_UNIT_NONE_DESCRIPTION"] = "列表到此结束。"
L["MENU_UNIT_TARGET"] = "目标"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "当你的目标可以承受该法术时，对其施放。"
L["MENU_UNIT_SELF"] = "自己"
L["MENU_UNIT_SELF_DESCRIPTION"] =
	'对你自己施放。你总是可以承受，因此"自己"之后的对象永远不会被尝试。'
L["MENU_UNIT_PET"] = "宠物"
L["MENU_UNIT_PET_DESCRIPTION"] = "当你的宠物在场且可以承受该法术时，对其施放。"
L["MENU_UNIT_FOCUS"] = "焦点"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "当你有焦点目标且它可以承受该法术时，对其施放。"
L["MENU_UNIT_TARGETS_TARGET"] = "目标的目标"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"当目标的目标可以承受该法术时，对其施放，例如你所选敌人正在攻击的坦克。"
L["MENU_UNIT_MOUSEOVER"] = "鼠标悬停"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"当你光标下的单位（无论在游戏世界中还是在单位框体上）可以承受该法术时，对其施放。"
L["MENU_OPTIONS_COUNT"] = "%d 个选项"
L["MENU_ENABLED"] = "已启用"
L["MENU_HIGHEST"] = "最高"
L["MENU_HIGHEST_DESCRIPTION"] = "施放你已学会的最高等级。"
L["MENU_RANK_DYNAMIC"] = "动态等级"
L["MENU_FIXED_RANK_DESCRIPTION"] = "无论什么等级，总是施放%s。"
L["MENU_ANY_TIME"] = "任何时候"
L["MENU_ANY_TIME_DESCRIPTION"] = "战斗中和非战斗时都会施放。"
L["MENU_IN_COMBAT"] = "战斗中"
L["MENU_IN_COMBAT_DESCRIPTION"] = "仅在战斗中施放。非战斗时宏不做任何事，包括其中的物品。"
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] =
	"仅在非战斗时施放。战斗中宏不做任何事，包括其中的物品。"
L["MENU_EVERY_PRESS"] = "每次按下"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "每次按下都会施放。"
L["MENU_GROUP_VERSION_DESCRIPTION"] = "右键点击施放%s。左键点击仍然施放%s。"
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"让宏可以施放%s。在这里勾选的法术中，宏会施放你最后学会的那个，因此它会随着你的训练而升级。"
L["MENU_GROUPED_SPELL_NOT_LEARNED"] = "尚未学会。现在勾选，学会后宏就会使用它。"
L["MENU_PET_DESCRIPTION"] = "当你的%s在场时，宏会施放%s，而不是再次召唤它。"
L["MENU_STANCE_DESCRIPTION"] = "先切换到%s，除非你已经处于该状态。"
L["MENU_USE_ITEM_DESCRIPTION"] =
	"在施法前使用。物品按你勾选的顺序使用，每项后面的数字表示它的顺序。"
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "使用%s"
L["MENU_ADD_FOCUS"] = "添加焦点副本"
L["MENU_REMOVE_FOCUS"] = "移除焦点副本"
L["MENU_FOCUS_DESCRIPTION"] = "在本页添加第二个宏，先对你的焦点施放，然后是你的目标。"
L["MENU_REMOVE_FOCUS_DESCRIPTION"] = "将焦点副本从本页移除，并删除它的宏。"
L["MENU_DUPLICATE_DESCRIPTION"] =
	"在本页再添加一个此宏的副本，初始选项与此相同，方便你进行不同的设置。"
L["MENU_MAKE_DEFAULT"] = "设为%s的默认设置"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] = "%s下所有你未自行设置过的宏，都会以此宏的选项开始。"
L["MENU_DEFAULT_SET"] = "%s现在会以这些选项开始。"

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "条件"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"在增强法术书窗口旁打开条件面板，在条件满足时（例如按住 Shift 或使用天赋 2），宏可以施放另一个法术。"
L["MENU_RIGHT_CLICK_TAKEN"] = "某个条件已使用右键点击。移除它才能开启此项。"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "条件"
L["CONDITIONALS_HINT"] = "从上到下检查；第一个满足的条件会施放。"
L["CONDITIONALS_OTHERWISE"] = "否则"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "且"
L["CONDITIONALS_AND_MENU"] = "添加第二个条件"
L["CONDITIONALS_AND_DESCRIPTION"] = "添加第二个条件。只有两者都满足时，这一行才会施放。"
L["CONDITIONALS_DROP_SECOND"] = "移除此条件"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "这一行重新只检查第一个条件。"
L["CONDITIONALS_ADD"] = "+ 添加条件"
L["CONDITIONALS_ADD_DESCRIPTION"] = "在底部添加一行。先选择它的条件，再选择它施放的法术。"
L["CONDITIONALS_ADD_LIMIT"] =
	"最多 %d 行。每一行都会增加宏文本的长度，而宏文本最多 255 字节。"
L["CONDITIONALS_PICK_SPELL"] = "选择法术"
L["CONDITIONALS_PICKING"] = "点击本页上的法术"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"点击这里，然后点击本页上的一个法术，让这一行施放它。也可以把本页上的法术拖到这个栏位上。"
L["CONDITIONALS_PICK_BANNER"] = "点击一个法术来使用它。按 Esc 或右键点击取消。"
L["CONDITIONALS_CANNOT_PICK"] = "只有已学会的法术才能由条件施放。"
L["CONDITIONALS_EMPTY"] =
	"还没有条件。添加一个，就能在按住 Shift、战斗中等情况下施放另一个法术。"
L["CONDITIONALS_SHADOWED"] =
	"永远不会施放：上方第 %d 行在这一行满足时也必定满足，并且会先施放。"
L["CONDITIONALS_KEY_DRAG"] = "把法术拖到这里"
L["CONDITIONALS_ACTION_DROP"] = "在这一行施放"
L["CONDITIONALS_ACTION_PICK"] = "从本页选择"
L["CONDITIONALS_ACTION_USE"] = "用于条件"
L["CONDITIONALS_ACTION_CANCEL"] = "取消选择"
L["CONDITIONALS_REMOVE"] = "移除"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "移除这一行。"
L["CONDITIONALS_REORDER"] = "调整顺序"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"拖到另一行上，把这一行移到那里。第一个满足的行会施放。"
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s：%s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "按住 Shift"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "按下宏时按住 Shift 即满足。"
L["CONDITION_CTRL"] = "按住 Ctrl"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "按下宏时按住 Ctrl 即满足。"
L["CONDITION_ALT"] = "按住 Alt"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "按下宏时按住 Alt 即满足。"
L["CONDITION_RIGHT_CLICK"] = "右键点击"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "在动作条上右键点击该宏时满足。"
L["CONDITION_IN_COMBAT"] = "战斗中"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "你处于战斗中时满足。"
L["CONDITION_OUT_OF_COMBAT"] = "非战斗"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "你不在战斗中时满足。"
L["CONDITION_SPEC_1"] = "天赋 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "你的第一套天赋启用时满足。"
L["CONDITION_SPEC_2"] = "天赋 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "你的第二套天赋启用时满足。"
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s（当前）"
L["CONDITION_COMBAT_BLOCKED"] =
	'"时机"设为"战斗中"或"非战斗"时不可用。宏在另一种状态下本来就不做任何事，因此这个条件要么总是满足，要么永远不满足。'
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	'"合并法术"中开启了"右键点击施放%s"时不可用，它已经占用了右键点击。关闭它才能在这里使用右键点击。'
L["SUBTEXT_CONDITIONALS_ONE"] = "1 个条件"
L["SUBTEXT_CONDITIONALS"] = "%d 个条件"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "施法序列"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"在增强法术书窗口旁打开施法序列面板，每次按下宏都会按顺序施放下一个法术，例如先腐蚀术，然后痛苦诅咒，再然后献祭。"
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d 步"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "施法序列"
L["CAST_SEQUENCE_HINT"] = "每次按下施放下一步。失败的步骤会在下次按下时重试。"
L["CAST_SEQUENCE_FIRST"] = "第一步"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "宏本身的法术总是最先施放。"
L["CAST_SEQUENCE_ADD"] = "+ 添加步骤"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "在末尾添加一个步骤，然后选择它施放的法术。"
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"宏本身的法术之后最多 %d 步。每一步都会增加宏文本的长度，而宏文本最多 255 字节。"
L["CAST_SEQUENCE_CANNOT_PICK"] = "只有已学会的法术才能作为施法序列中的步骤，射击除外。"
L["CAST_SEQUENCE_ACTION_DROP"] = "在这一步施放"
L["CAST_SEQUENCE_ACTION_USE"] = "用于施法序列"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "移除这一步。"
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "拖到另一步上，把这一步移到那里。"
L["CAST_SEQUENCE_END"] = "最后一步之后"
L["CAST_SEQUENCE_END_LOOP"] = "重新开始"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] = "下次按下会再次施放宏本身的法术，序列循环进行。"
L["CAST_SEQUENCE_END_STOP"] = "停止（NULL）"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"以 NULL 结束，这是一个无人知晓的法术，因此之后再按也不会施放任何东西，直到重置让序列重新开始。"
L["CAST_SEQUENCE_END_STOP_SHORT"] = "停止"
L["CAST_SEQUENCE_RESET"] = "重新开始的时机"
L["CAST_SEQUENCE_RESET_NEVER"] = "从不"
L["CAST_SEQUENCE_RESET_TARGET"] = "切换目标"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "当你切换目标时，序列从第一步重新开始。"
L["CAST_SEQUENCE_RESET_COMBAT"] = "战斗结束"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] = "当你脱离战斗时，序列从第一步重新开始。"
L["CAST_SEQUENCE_RESET_SHIFT"] = "按住 Shift"
L["CAST_SEQUENCE_RESET_CTRL"] = "按住 Ctrl"
L["CAST_SEQUENCE_RESET_ALT"] = "按住 Alt"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] = "按住此键按下宏时，序列重新开始，施放第一步。"
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "闲置秒数"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"当宏在这么长时间内没有被按下时，序列重新开始。"
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "关闭"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "闲置 %d 秒"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	'永久停止：没有任何东西能让它重新开始，序列会一直停在 NULL，直到宏发生变化或你重载界面。请在"重新开始的时机"中选择一种重置方式。'
L["CAST_SEQUENCE_PET_BLOCKED"] =
	'"宠物已召唤时施放"正在施放%s，它会写入自己的施法行，因此暂不可用。关闭它才能使用施法序列。'
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"点击这里，然后点击本页上的一个法术，让这一步施放它。也可以把本页上的法术拖到这个栏位上。"
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d 步序列"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "显示所有法术等级"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "显示合并法术"
L["SETTINGS_SHOW_UNLEARNED"] = "显示未学会的法术"
L["SETTINGS_MARK_ALL_PLACED"] = "将所有法术标记为已放置"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"本页的所有宏不再发光，无论是否在你的动作条上。之后学会的法术在放置前仍会发光。"
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "高亮未放置的法术"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	'让所有不在你动作条上的宏发光。关闭它就会把它们全部标记为已放置，效果和"将所有法术标记为已放置"按钮相同。'
L["SORT_BY_CATEGORY"] = "按类别排序"
L["SORT_BY_SCHOOL"] = "按系别排序"
L["SORT_DESCRIPTION"] =
	"将本页的宏按类别分组，即每个法术的用途，例如攻击、治疗或防御冷却；或按系别分组，即它们所在的法术书标签页。"
L["CATEGORY_ATTACKS"] = "攻击"
L["CATEGORY_FINISHERS"] = "终结技"
L["CATEGORY_CROWD_CONTROL"] = "控制"
L["CATEGORY_HYBRID"] = "混合"
L["CATEGORY_HEALS"] = "治疗"
L["CATEGORY_BUFFS"] = "增益"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "进攻冷却"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "防御冷却"
L["CATEGORY_SELF_BUFFS"] = "自身增益"
L["CATEGORY_SHOCKS"] = "震击"
L["CATEGORY_TRAPS"] = "陷阱"
L["CATEGORY_TOTEMS"] = "图腾"
L["CATEGORY_SEALS"] = "圣印"
L["CATEGORY_BLESSINGS"] = "祝福"
L["CATEGORY_CURSES"] = "诅咒"
L["CATEGORY_PETS"] = "宠物"
L["CATEGORY_TELEPORTS"] = "传送与传送门"
L["CATEGORY_UTILITY"] = "辅助"
L["CATEGORY_THREAT"] = "嘲讽与仇恨"
L["SUBCATEGORY_BASIC_ATTACKS"] = "基础攻击"
L["CATEGORY_STANCES"] = "姿态"
L["CATEGORY_FORMS"] = "形态"
L["CATEGORY_AURAS"] = "光环"
L["CATEGORY_ASPECTS"] = "守护"
L["CATEGORY_RACIALS"] = "种族技能"
L["CATEGORY_TRACKING"] = "追踪"
L["CATEGORY_PROFESSIONS"] = "专业技能"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "焦点"
L["SUBTEXT_PET"] = "宠物"
L["SUBTEXT_CURSOR"] = "光标"
L["SUBTEXT_STANCE"] = "姿态"
L["SUBTEXT_USE_ITEMS"] = "使用物品"
L["SUBTEXT_PET_ATTACK"] = "宠物攻击"
L["SUBTEXT_DYNAMIC_RANK"] = "动态等级"
L["SUBTEXT_DYNAMIC_ITEM"] = "动态物品"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "动态等级，动态物品"
L["SUBTEXT_MAX_RANK"] = "最高等级"
L["SUBTEXT_TARGET_ENEMY"] = "最近敌人"
L["SUBTEXT_TARGET_FRIEND"] = "最近友方"
L["SUBTEXT_TARGET_PRIORITY"] = "目标"
L["SUBTEXT_GROUPED_SPELLS"] = "合并"
L["SUBTEXT_ONCE_PER_COMBAT"] = "每战一次"
L["SUBTEXT_ONCE_PER_TARGET"] = "每目标一次"
L["SUBTEXT_COMBAT_ONLY"] = "仅战斗中"
L["SUBTEXT_NO_COMBAT"] = "非战斗"
L["SUBTEXT_LEAVE_FORM"] = "取消形态"
L["SUBTEXT_NO_TOGGLE"] = "永不关闭"
L["SUBTEXT_WAND"] = "魔杖"
L["SUBTEXT_START_ATTACK"] = "自动攻击"
L["SUBTEXT_STOP_ATTACK"] = "停止攻击"
L["SUBTEXT_STOP_CASTING"] = "停止施法"
L["SUBTEXT_STOP_IF_CHANNELING"] = "引导时不施放"
L["SUBTEXT_STOP_IF_STEALTHED"] = "潜行时不施放"
L["SUBTEXT_HIDE_ERRORS"] = "隐藏错误"
L["SUBTEXT_MUTE_ERRORS"] = "错误静音"
L["SUBTEXT_OPTIONS_COUNT"] = "%d 个选项"
L["SUBTEXT_TOO_LONG"] = "过长"
L["SUBTEXT_LEARN_LEVEL"] = "%d级"
L["SUBTEXT_TALENT"] = "天赋"
L["SUBTEXT_LEARN_RANK"] = "学习%s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s，%s"
L["SUBTEXT_TEACH_PET"] = "教给宠物"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "尚未学会"
L["TOOLTIP_LEARN_LEVEL"] = "你的职业训练师在%d级时教授。"
L["TOOLTIP_LEARN_TALENT"] = "通过天赋学会。"
L["TOOLTIP_NOT_ON_BARS"] = "不在你的动作条上"
L["TOOLTIP_TOO_LONG"] = "过长：%d / %d 字节。关闭一个选项来缩短它。"
L["TOOLTIP_OPTIONS_ON"] = "已开启选项：%s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "点击或拖动"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "放到你的动作条上"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "右键点击"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "宏选项"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "中键点击"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "重置宏选项"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "重置%s中的所有宏"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s已恢复为默认选项。"
L["CHAT_CATEGORY_OPTIONS_RESET"] = "%s中的所有宏都已恢复为默认选项。"
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"清除你在这里每个法术上设置的选项，让它们重新遵循默认设置。焦点副本和复制的宏会保留。"
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"重置你在%s中每个法术上设置的选项？它们都会重新遵循默认设置。"

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s宏"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "把你的职业法术做成一键宏。"
L["TOOLTIP_KEY_CLICK"] = "点击"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "打开增强法术书"

-- Page: Layout
L["PAGE_EMPTY"] = "还没有宏。去找你的职业训练师学习第一批法术。"
L["PAGE_NO_MATCHES"] = "没有符合筛选条件的宏。"
L["PAGE_FILTER"] = "筛选法术"
L["FILTER_ALL_SCHOOLS"] = "所有系别"
L["FILTER_ALL_CATEGORIES"] = "所有类别"
L["PAGE_MACRO_SLOTS"] = "宏栏位"
L["TOOLTIP_MACRO_SLOTS"] =
	"你放置的每个宏都会占用一个宏栏位。角色栏位专属于这个角色，并优先占用。通用栏位由你账号中的所有角色共享。"
L["PAGE_MACRO_GENERAL"] = "通用"
L["PAGE_MACRO_CHARACTER"] = "角色"
L["PAGE_NO_MATCHES_FOR"] = '没有符合"%s"的法术。'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Settings for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "全部 %d 个%s的设置"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"一次为此类别中的所有法术开启或关闭某个选项。尚未放到动作条上的法术会保留该设置，等你放置时生效。"
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "（续）"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "接下来学什么？"
L["WHATS_NEXT_EMPTY"] = "没有可列出的法术。"
L["WHATS_NEXT_ALL_SOURCES"] = "所有来源"
L["WHATS_NEXT_ANY_LEVEL"] = "任意等级"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "（%s）"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "现在可学"
L["WHATS_NEXT_STATUS_SOON"] = "即将可学"
L["WHATS_NEXT_STATUS_LATER"] = "暂不可学"
L["WHATS_NEXT_STATUS_MISSING"] = "缺少前置条件"
L["WHATS_NEXT_STATUS_TALENT"] = "未选的天赋"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "未选的天赋和符文"
L["WHATS_NEXT_STATUS_KNOWN"] = "已学会"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "现在可学"
L["WHATS_NEXT_SHORT_SOON"] = "即将可学"
L["WHATS_NEXT_SHORT_LATER"] = "暂不可学"
L["WHATS_NEXT_SHORT_MISSING"] = "需要其他法术"
L["WHATS_NEXT_SHORT_TALENT"] = "未选"
L["WHATS_NEXT_SHORT_KNOWN"] = "已学会"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "初始法术"
L["WHATS_NEXT_SOURCE_TRAINER"] = "训练师"
L["WHATS_NEXT_SOURCE_BOOK"] = "书籍"
L["WHATS_NEXT_SOURCE_QUEST"] = "任务"
L["WHATS_NEXT_SOURCE_TALENT"] = "天赋"
L["WHATS_NEXT_SOURCE_RUNE"] = "符文"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "学习来源"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "需要等级"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "你的职业一开始就会。"
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "由你的职业训练师教授。"
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "通过物品学会，例如地下城或团队副本中掉落的书籍。"
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "通过职业任务学会。你的职业训练师可以为你指路。"
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "在它上面花费一个天赋点即可学会。"
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "雕刻它的符文即可学会。"
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "先学会%s。"
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "%s的等级"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + 点击"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "在聊天中链接"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "按可学状态排序"
L["WHATS_NEXT_SORT_LEVEL"] = "按等级排序"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"按可学状态排序时，现在就能学的法术排在最前，已学会的排在最后。按等级排序时，每个法术都列在学习它所需的等级下。"
L["WHATS_NEXT_SHOW_KNOWN"] = "显示已学会的法术"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "同时列出你已学会的法术，排在其余法术之后。"
L["WHATS_NEXT_SHOW_TALENTS"] = "显示未选的天赋"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "显示未选的天赋和符文"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"同时列出你未选的天赋法术。这些需要花费天赋点学会，而不是向训练师学习。"

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "宠物法术书"
L["PET_SPELLBOOK_EMPTY"] = "你的宠物没有可列出的法术。"
L["PET_SPELLBOOK_NO_PET"] = "宠物不在场。召唤你的宠物来查看它的法术。"
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "技能"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "被动"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "自动施法开启"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "自动施法关闭"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "宠物接下来学什么？"
L["WHATS_NEXT_PET_EMPTY"] = "没有可列出的宠物技能。"
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s，%d级%s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "训练点数：%d / %d"
L["WHATS_NEXT_PET_NO_PET"] = "宠物不在场：显示你通过训练野兽学会的技能。"
L["WHATS_NEXT_PET_NO_DEMON"] = "恶魔不在场：召唤一个来查看它已经掌握的技能。"

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "可以教授"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "其他家族的技能"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "可以教授"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "其他家族"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "宠物训练师"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "驯服"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "恶魔训练师"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "需要宠物等级"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "训练点数"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] = "由宠物训练师教给你。然后用训练野兽教给你的宠物。"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"驯服一只掌握它的野兽，并与它并肩作战，直到你学会它。然后用训练野兽教给任何能学会它的宠物。"
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "你已学会。用训练野兽教给你的宠物。"
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"从恶魔训练师处购买它的魔典，然后在能学会它的恶魔被召唤时使用。"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "魔典"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] = "它的魔典在你的背包里。在召唤此恶魔时使用。"
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "你的宠物无法学会它。"
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "掌握它的野兽"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s（%s）"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "还有 %d 个。"

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"按可学状态排序时，你的宠物现在就能学的技能排在最前，已掌握的排在最后。按等级排序时，每个技能都列在它所需的宠物等级下。"
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "显示已掌握的技能"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"同时列出你的宠物已掌握的技能，排在其余技能之后。没有宠物在场的猎人会看到自己已学会的技能。"
L["WHATS_NEXT_PET_SHOW_OTHER"] = "显示其他家族的技能"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"同时列出你的宠物无法学会的技能，例如对狼来说豹的潜伏，或其他恶魔的技能。"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "按键设置"
L["OPTIONS_KEY_SET"] = "设置按键"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "打开游戏的按键设置列表，Good to Go 在其中有自己的分类。"
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"打开或关闭增强法术书。它在你的法术书中也有自己的标签页。"
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"非战斗时，每按一次施放你的增益值班窗口提供的下一个增益。武器增益仍需在窗口上点击。要在宏中按下它，请使用 %s。"
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "法术等级提示"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"每个技能的鼠标提示都会列出它的各个等级及每级所需的角色等级：白色表示已学会，绿色表示现在就能训练，灰色表示以后才能学。这能让你快速自查是否在使用最高等级，始终发挥最佳水平。战斗中不会显示这些等级，让你的提示在关键时刻保持简短。"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "启用法术等级提示"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"在动作条、游戏法术书和其他插件中，把每个技能的等级加入它的鼠标提示。关闭后这些提示保持游戏原样。增强法术书自己的窗口无论如何都会显示等级。"
L["OPTIONS_DELETE_MACROS_HEADER"] = "删除宏"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"删除增强法术书创建的宏，这也会将它们从动作条上移除。你自己的宏绝不会被改动，在页面上点击或拖动任意一个法术即可重新创建它的宏。"
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "删除角色宏"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"从此角色的宏标签页中删除增强法术书的宏。你的其他角色会保留各自的宏，直到你在那些角色上也这样做。"
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"删除此角色上增强法术书的所有宏？它们也会从你的动作条上移除。"
L["OPTIONS_DELETE_GENERAL_MACROS"] = "删除通用宏"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"从通用宏标签页中删除增强法术书的宏。该标签页由账号内所有角色共享，因此你的其他角色也会失去那里的这些宏。"
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"删除增强法术书的所有通用宏？账号内所有角色都会失去它们，它们也会从你的动作条上移除。"

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"在法术本身的宏之后，为你已学会的每个较低等级各列出一个宏，每个宏总是施放对应等级。"
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"列出你已学会的某个法术组中的所有法术，例如净化术和清洁术。关闭时只列出最后学会的那个，但其他法术的宏仍会更新。"
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"在未学会分类中列出你尚未学会的职业法术，方便提前放置它们的宏。"

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "把法术放在光标所指的位置，不出现瞄准圈。"
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "施放友方玩家等级所能接受的最高等级。"
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] = "先停止你正在施放的法术，让这个法术立刻施放。"
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "先停止你的近战自动攻击。"
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"你在引导法术时不做任何事，因此按下也绝不会打断引导。"
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"你在潜行时不做任何事，因此按下也绝不会打破潜行或潜伏。"
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "先取消你当前的形态，以便施放法术。"
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] = "当你没有选中活着的敌人时，先选择最近的敌人。"
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] = "当你没有选中活着的友方时，先选择最近的友方。"
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "同时让你的宠物攻击你的目标。"
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "施法后开始你的近战自动攻击。"
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "施法后开始自动射击或魔杖射击。"
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "施放一次，直到你的目标改变前不再施放。"
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"施放一次，直到战斗结束或你的目标改变前不再施放。"
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"再次按下宏时保持形态或守护开启，而不是将其关闭。"
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "清除宏在屏幕上留下的红色错误文字。"
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "宏运行期间关闭错误音效。"
L["KIND_ENEMY"] = "敌对法术"
L["KIND_ENEMY_DESCRIPTION"] = "对敌人施放的法术，例如攻击和减益效果。"
L["KIND_FRIENDLY"] = "友方法术"
L["KIND_FRIENDLY_DESCRIPTION"] = "对友方施放的法术，例如治疗。"
L["KIND_BUFF"] = "增益法术"
L["KIND_BUFF_DESCRIPTION"] = "为友方施加持久增益效果的法术。"
L["KIND_RESURRECT"] = "复活法术"
L["KIND_RESURRECT_DESCRIPTION"] = "对死亡的友方施放、让其复活的法术。"
L["KIND_ANYONE"] = "友方或敌方法术"
L["KIND_ANYONE_DESCRIPTION"] = "既可以对友方也可以对敌人施放的法术。"
L["KIND_GROUND"] = "地面目标法术"
L["KIND_GROUND_DESCRIPTION"] = "放置在地面上的法术。"
L["KIND_FORM"] = "形态、姿态和守护"
L["KIND_FORM_DESCRIPTION"] = "在你关闭或切换之前一直保持的法术。"
L["KIND_SELF"] = "自身和范围法术"
L["KIND_SELF_DESCRIPTION"] = "没有目标，对自己或周围施放的法术。"

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "打开/关闭增强法术书"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开按键设置列表。"
L["KEY_BINDINGS_LOCATION"] = "打开游戏菜单，依次进入 %s 和 %s，找到 Good to Go 分类。"
L["ERROR_MACRO_SLOTS_FULL"] = "没有空余的宏栏位。请在 /macro 中删除一个宏来腾出位置。"
L["ERROR_MACRO_WINDOW_OPEN"] = "请先关闭宏界面。"
L["CHAT_MACROS_DELETED"] = "已删除宏：%d"
L["CHAT_MACRO_TOO_LONG"] =
	'"%s"宏在开启选项后为 %d 字节，超过了宏能容纳的 %d 字节。关闭一个选项来缩短它。'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'"%s"宏有 %d 字节，超过了宏能容纳的 %d 字节，因此最后一行被截断。'
