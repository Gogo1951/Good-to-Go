local L = LibStub("AceLocale-3.0"):NewLocale("Good-to-Go", "enUS", true)
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
	"Version %s. Settings (including the option to disable this message) are under Options > AddOns > Good to Go. Enjoying this add-on? Tell a friend, Favorite it on CurseForge, or Star it on GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Help Good to Go Level Up"
L["OPTIONS_LEVEL_UP_THANKS"] = "Thanks for choosing Good to Go!"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Bandage"
L["MACRO_EXPLOSIVES"] = "- Explosives"
L["MACRO_FEED_PET"] = "- Feed Pet"
L["MACRO_FOOD"] = "- Food"
L["MACRO_HEALTH_POTION"] = "- Health Potion"
L["MACRO_HEALTHSTONE"] = "- Healthstone"
L["MACRO_MANA_GEM"] = "- Mana Gem"
L["MACRO_MANA_POTION"] = "- Mana Potion"
L["MACRO_POISONS"] = "- Poisons"
L["MACRO_SOULSTONE"] = "- Soulstone"
L["MACRO_WATER"] = "- Water"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of any list the add-on shows, such as a Readiness Report clause or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- Joins two names in a sentence ("Katz and Aero").
L["LIST_PAIR_FORMAT"] = "%s and %s"
-- Joins the last name to the ones before it, already joined with LIST_SEPARATOR ("Katz, Aero, and Spek").
L["LIST_LAST_FORMAT"] = "%s, and %s"
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

L["DIET_BREAD"] = "Bread"
L["DIET_CHEESE"] = "Cheese"
L["DIET_FISH"] = "Fish"
L["DIET_FRUIT"] = "Fruit"
L["DIET_FUNGUS"] = "Fungus"
L["DIET_MEAT"] = "Meat"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Looks like you found a bug! %s (%s) can't be used in %s > %s (%s). Please report this so we can get it fixed. Thanks! %s"
L["MESSAGE_NO_ITEM"] = "No suitable %s found in your bags."
L["MESSAGE_MACRO_SLOTS_ARE_FULL"] =
	"Some Good to Go macros couldn't be created because your macro slots are full. Free up a slot by deleting macros you no longer use, or turn off any Good to Go macros you don't need under Options > AddOns > Good to Go > Consumable Macros."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. The first %s is "/m", the game's own macro
    command, colored at the call site; the second is the client's own name for
    the macro window's tab of account-wide macros (GENERAL_MACROS). The macro
    names are this locale's own MACRO_FOOD and MACRO_WATER values, written
    exactly as this locale ships them.
]]
L["MESSAGE_MACROS_READY_TAB"] =
	"Your macros are ready. Type %s, open the %s tab, and drag - Food, - Water, and the rest onto your action bars."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s is now on this character's Ignore List."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "Cleared 1 item from this character's Ignore List."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "Cleared %d items from this character's Ignore List."

L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."

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

L["READINESS_TITLE"] = "Readiness Report"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Missing Buffs :"
L["READINESS_EXPIRING"] = "Expiring Soon :"
L["READINESS_MISSING_ITEMS"] = "Missing Items :"
L["READINESS_DAMAGED_GEAR"] = "Damaged Gear :"
L["READINESS_CHARACTER"] = "Character :"
L["READINESS_QUESTIONABLE_GEAR"] = "Non-Combat Gear Equipped :"

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
L["READINESS_FLASK"] = "Flask or 2x Elixirs"
L["READINESS_PET_FORMAT"] = "%s (Pet)"
L["READINESS_SCROLLS"] = "Scrolls"
L["READINESS_SOULSTONE"] = "Soulstone Inactive"
L["READINESS_HEALTHSTONE"] = "Healthstone"
L["READINESS_MANA_GEM"] = "Mana Gem"
L["READINESS_HEALING_POTION"] = "Healing Potion"
L["READINESS_MANA_POTION"] = "Mana Potion"
L["READINESS_BANDAGES"] = "Bandages"
L["READINESS_PVP_ON"] = "PvP Flagged"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s under 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 Unspent Talent Point"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d Unspent Talent Points"

--------------------------------------------------------------------------------
-- GtGTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run GtGTip("key") or GtGTipIf, and TIP_EMPTY_* via GtGNoItem. See Features/Macros-for-Consumables/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "You don't currently have any food that is useful for your pet."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "You don't currently know %s, %s, %s, or %s."
L["TIP_NO_HAND_POISON"] = "You're out of the selected poison for this weapon."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "You don't currently know %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "No %s in your bags. Right-Click %s to conjure more."
L["TIP_EMPTY_CREATE"] = "No %s in your bags. Right-Click %s to create one."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Buff Food"
L["FEATURE_SCROLL_BUFFS"] = "Scroll Buffs"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. Buff Duty's block takes its title and description
    from TAB_BUFF_DUTY and BUFF_DUTY_DESCRIPTION.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Buff Food & Scrolls"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] = "Uses %s food and applies missing scroll buffs before you eat."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Current Food"
L["MINIMAP_BEST_PET_FOOD"] = "Current Pet Food"
L["MINIMAP_MAIN_HAND_POISON"] = "Main Hand Poison"
L["MINIMAP_OFF_HAND_POISON"] = "Off Hand Poison"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Ignore List"
L["MINIMAP_IGNORE_COUNT"] = "%d Items"
L["MENU_IGNORE"] = "Ignore"
L["MENU_CLEAR_IGNORE"] = "Clear Ignore List"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker Report"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d Orders Outstanding"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Congratulations, you're fully stocked up!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Your list is empty."

--[[
    The Restock List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restock List"
L["MENU_RESTOCKER_DESCRIPTION"] = "Buys and banks the items on your list."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + Right-Click"
L["MENU_OPTIONS"] = "GtG Options"
L["MENU_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

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
L["NOTE_MACRO_FEED_PET"] = "Feed Pet Macro"
L["NOTE_MACRO_FOOD_WATER"] = "Food & Water Macros"
L["NOTE_MACRO_MANA_GEM"] = "Mana Gem Macro"
L["NOTE_MACRO_HEALTHSTONE"] = "Healthstone Macro"
L["NOTE_MACRO_SOULSTONE"] = "Soulstone Macro"
L["NOTE_MACRO_POISONS"] = "Poisons Macro"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Call, Feed, or Revive"
L["NOTE_PET_MEND_CLICK"] = "Right-Click, or in Combat"
L["NOTE_HOLD_SHIFT"] = "Hold Shift"
L["NOTE_PET_FORCE_REVIVE"] = "Force Revive"
L["NOTE_HOLD_CONTROL"] = "Hold Ctrl"
L["NOTE_PET_DISMISS"] = "Dismiss"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Conjure"
L["NOTE_CREATE"] = "Create"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Right-Click Again"
L["NOTE_LOWER_RANK_BACKUP"] = "Lower-Rank Backup"
L["NOTE_MAGE_TARGET_LEVEL"] = "Target a lower-level player to conjure for their level."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Target a lower-level player to create one for their level."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Poisons Window"
L["NOTE_POISONS_REPLACED"] = "Replaces old poisons automatically."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from GtGNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandage"
L["LABEL_EXPLOSIVE"] = "Explosive"
L["LABEL_FOOD"] = "Food"
L["LABEL_HEALTH_POTION"] = "Health Potion"
L["LABEL_HEALTHSTONE"] = "Healthstone"
L["LABEL_MANA_GEM"] = "Mana Gem"
L["LABEL_MANA_POTION"] = "Mana Potion"
L["LABEL_PET_FOOD"] = "Pet Food"
L["LABEL_POISON"] = "Poison"
L["LABEL_SOULSTONE"] = "Soulstone"
L["LABEL_WATER"] = "Water"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Enabled"
L["MINIMAP_DISABLED"] = "Disabled"
L["MINIMAP_TOGGLE"] = "Toggle"
L["MINIMAP_OPEN"] = "Open"
L["MINIMAP_LEFT_CLICK"] = "Left-Click"
L["MINIMAP_RIGHT_CLICK"] = "Right-Click"
L["MINIMAP_MIDDLE_CLICK"] = "Middle-Click"
L["MINIMAP_SHIFT_LEFT"] = "Shift + Left-Click"

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
L["GROUP_CONTEXT_SOLO_DESCRIPTION"] = "While you're not in a party or raid."
L["GROUP_CONTEXT_PARTY"] = "Party"
L["GROUP_CONTEXT_PARTY_DESCRIPTION"] = "While you're in a party, including a group finder dungeon."
L["GROUP_CONTEXT_RAID"] = "Raid"
L["GROUP_CONTEXT_RAID_DESCRIPTION"] = "While you're in a raid. A battleground's raid counts as Battleground."
L["GROUP_CONTEXT_BATTLEGROUND"] = "Battleground"
L["GROUP_CONTEXT_BATTLEGROUND_DESCRIPTION"] = "While you're inside a battleground or an arena, whatever your group."
L["GROUP_CONTEXT_NEVER"] = "Never"

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
	"Chooses the levels at which your Food macro offers %s: any level, only while leveling, or only at max level. The checkboxes below choose which groups."
L["OPTIONS_MODE_CAPTION"] = "When to Use"
L["OPTIONS_GROUPS_NONE"] = "Nothing is checked, so this is never used."
L["LEVEL_FILTER_ANY"] = "At Any Level"
L["LEVEL_FILTER_LEVELING"] = "When Leveling"
L["LEVEL_FILTER_MAX_LEVEL"] = "When at Max Level"

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
L["INVENTORY_REPORT_TITLE"] = "Inventory Report"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Bag %s, Bank %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Bag %s"
L["INVENTORY_REPORT_BANK"] = "Bank %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Total %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Auto-updating macros for your best food, water, potions, and healthstones, a Restock List that auto-buys and banks reagents and ammo, click-to-cast missing buffs, and mouseover macros for every spell."

-- Enhanced Spellbook: its tree label, its panel's description, and the print when it's off.
L["TAB_ENHANCED_SPELLBOOK"] = "Enhanced Spellbook"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Mouseover, cursor, and self-cast macros for every class spell, built in one click from a new spellbook tab with no macro syntax. They update as you level, train, and swap specs. Right-Click to add focus, stop casting, auto attack, pet attack, or trinkets."
L["SPELLBOOK_IS_OFF"] =
	"The Enhanced Spellbook is off. Turn it on under Options > AddOns > Good to Go > Enhanced Spellbook."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Prints a welcome message in chat on login."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Enable Mini-map Button"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Shows the mini-map button."

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
L["OPTIONS_FEATURES_HEADER"] = "Features"
L["SWITCH_BUFF_DUTY_DESCRIPTION"] =
	"Shows a window of everyone in your group missing a buff you can give. Click an icon to cast it."
L["SWITCH_RESTOCKER_DESCRIPTION"] =
	"Keeps your bags stocked from your Restock List, buying from merchants and moving items to and from the bank, and reminds you when you run low. Off stops all of it, the Restock List window included. Your lists stay saved."
L["SWITCH_SPELLBOOK"] = "Enable Enhanced Spellbook"
L["SWITCH_SPELLBOOK_DESCRIPTION"] =
	"Adds a tab to your spellbook that builds mouseover, cursor, and self-cast macros for your spells, and keeps them current as you level and train. Off hides the tab and stops the updates. It never deletes a macro; the Delete Macros buttons on the Enhanced Spellbook panel do that."
L["SWITCH_SPELLBOOK_CONFIRM_OFF"] =
	"Turn off Enhanced Spellbook? Its tab leaves your spellbook, and the macros it made stop updating as you level and train. This doesn't delete them: they stay on your action bars as they are now."
L["SWITCH_MACROS"] = "Enable Consumable Macros"
L["SWITCH_MACROS_DESCRIPTION"] =
	"Keeps your Food, Water, Potion, and other consumable macros pointed at the best item in your bags as your bags change. Off stops the updates and leaves every macro as it last was. It never deletes a macro; unchecking one under Which Macros to Create on the Consumable Macros panel does that."
L["SWITCH_MACROS_CONFIRM_OFF"] =
	"Turn off Consumable Macros? Your macros stop updating as your bags change, so a button may keep reaching for an item you've used up. This doesn't delete them: they stay on your action bars as they are now."
L["SWITCH_INVENTORY_REPORT"] = "Enable Inventory Report"
L["SWITCH_INVENTORY_REPORT_DESCRIPTION"] =
	"Adds to an item's tooltip how many you have in your bags, in your bank, and on your other characters on this realm. Turn it off if another add-on already shows these counts."
L["SWITCH_READINESS_REPORT"] = "Enable Readiness Report"
L["SWITCH_READINESS_REPORT_DESCRIPTION"] =
	"When a ready check starts, prints a private list of anything you still need to fix, like a missing buff, potion, or damaged gear. Says nothing when you're ready."

-- Features: each feature's master switch, also on the panel that configures it.
L["OPTIONS_RESTOCKER_ENABLE"] = "Enable Restocker"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Example: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/gtg"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Opens your Restock List."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"This add-on was built by players who love this game and want to make it as fun as possible for everyone. We'll never ask for donations. The real satisfaction comes from knowing our work makes the game a little better for you. If it does, we'd love to hear about it!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Here are a few ways you can help us reach more players."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Share Feedback: Found a bug or have an idea? Let us know on Discord. Your feedback helps us improve the add-on, and pull requests are always welcome."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Tell a Friend: Know someone who might enjoy this add-on? Tell them about it. Word of mouth helps more players discover great add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorite on CurseForge: Open the CurseForge link below, sign in, and click the star beneath the Download button. Favorites help more players discover the add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star on GitHub: Open the GitHub link below, sign in, and click Star in the top right. Stars help the project qualify for more free developer tools."

L["OPTIONS_FEEDBACK"] = "Feedback & Support"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Feedback & Support Links"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "To copy a link, click its box, then press Ctrl+A and Ctrl+C."
L["OPTIONS_VERSION"] = "Version %s"

--[[
    Consumable Macros panel. TAB_CONSUMABLE_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Consumable Macros and
    Enable Macro Names on Buttons.
]]
L["TAB_CONSUMABLE_MACROS"] = "Consumable Macros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Good to Go builds one macro per consumable and keeps it current as your bags change, so the button on your bar always reaches for the best item you're carrying. Choose which macros to create below, then set how each one picks its item."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Enable Macro Names on Buttons"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Shows the macro name text on your action bar buttons, which Good to Go hides by default."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Which Macros to Create"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Choose which macros Good to Go creates and maintains. Turning one off also removes it. They're in the General tab of the Macros window, ready to drag onto your action bars."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Open Macros Window"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Opens the game's Macros window on its General tab, where these macros live."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Creates and maintains this macro, and removes it when unchecked."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Food & Water"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Your Food and Water macros use the best food and drink in your bags. These options can put buff food, scrolls, or conjured food and water first, and Restock List food and water last."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Prioritize Buff Food"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Prioritizes food that grants "%s" whenever the buff is missing, except in arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Enable Scroll Buffs"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Your Food macro applies missing scrolls on the first press and eats on the next, skipping scrolls when you target a friendly player or are in an arena."
L["OPTIONS_SCROLL_TYPES"] = "Include Scroll Types in Check"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Protection"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Includes %s when checking for missing buffs."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Use Conjured Food & Water First"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	"Your Food and Water macros use conjured food and water before anything else, even when something in your bags restores more, since it costs nothing and vanishes soon after you log out. Buff food still comes first while Prioritize Buff Food is on."
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Chooses the levels at which conjured food and water come first: any level, only while leveling, or only at max level. The checkboxes below choose which groups."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Use Restock List Food & Water Last"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Between two foods or drinks that restore the same amount, your Food and Water macros use the one that isn't on your Restock List, saving what the Restocker buys for later."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Potions & Healthstones"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Macros cannot change during combat (this is a Blizzard restriction), so each Potion and Healthstone macro is pre-built with your best item plus up to two fallbacks. In longer fights the icon and tooltip can go stale and show the wrong item, but clicking the macro will always use the best item you actually have in your bags."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Use Food & Water in Potion Macros Out of Combat"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Out of combat, your Health Potion macro eats your best food and your Mana Potion macro drinks your best water. In combat, they use your potions as before. Scrolls, pet food, and conjuring stay on the Food and Water macros."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combine Healthstones Into Health Potion Macro"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Adds your best Healthstone to the bottom of the Health Potion macro, so one press uses a potion and a Healthstone."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Mana Gems & Runes"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s, and a few other mana items share a cooldown with Mana Gems. The runes cost health to use, so the Mana Gem macro leaves all of them out unless you add them."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Add Runes & Other Mana Items to Mana Gem Macro"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Ranks your %s, your %s, and any other mana item that shares the Mana Gem cooldown, alongside your Mana Gems, so the Mana Gem macro uses one when it's your best option or when you're out of gems."

-- Buff Reapplication
L["OPTIONS_REAPPLY_HEADER"] = "Buff Reapplication"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Macros can't change during combat, so a buff that runs out mid-fight stays gone until the fight ends."
L["OPTIONS_REAPPLY"] = "Reapply Expiring Buffs"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Treats Buff Food, Scroll Buffs, and Pet Food Buffs with less time left than your threshold as expired, so your macros offer a fresh one before the pull."
--[[
    Threshold dropdown, beside the Reapply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Sets how close to expiring a buff can get before your macros offer a fresh one."
L["REAPPLY_THRESHOLD_ONE"] = "When < 1 Minute Left"
L["REAPPLY_THRESHOLD_MANY"] = "When < %d Minutes Left"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Pet Food Buffs"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'A few foods give your pet a "%s" buff of its own.'
L["OPTIONS_USE_PET_BUFFS"] = "Use Pet Food Buffs"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Adds pet food to your Food macro when your pet is missing "%s", except in arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Include Pet Food Types in Check"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosives"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"The @player option skips the targeting reticle and sets the explosive off right at your feet, ideal when your target is in melee range. Your other click tosses it as usual."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Click Layout"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Chooses which click tosses the explosive and which sets it off at your feet."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Left-Click @player"
L["EXPLOSIVES_MODE_TOSS"] = "Left-Click Toss"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Consumable Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Class & Race"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"These options shape your macros for one class or race. Every section shows on every character."

-- The class and race sections' headers; %s is the client's name for the class or race.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Class Options: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Racial Options: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Needs the DruidMacroHelper add-on. Turned on, your Health Potion, Mana Potion, and Healthstone macros powershift you out of form, use the item, and put you back in Bear or Cat Form, whichever you pick beside the checkbox."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Enable DruidMacroHelper Integration"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Builds powershifting macros for Health Potions, Mana Potions, and Healthstones using DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Chooses the form your powershifting macros return you to after using the item."
L["DRUID_FORM_BEAR"] = "Return to Bear"
L["DRUID_FORM_CAT"] = "Return to Cat"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Keeps the Poisons macro loaded with the best usable rank of each poison type. Left-Click applies to your Off Hand, Right-Click to your Main Hand, and existing poisons are replaced automatically."
L["OPTIONS_POISON_MAIN_HAND"] = "Main Hand Poison Type"
L["OPTIONS_POISON_OFF_HAND"] = "Off Hand Poison Type"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Chooses the poison your Poisons macro applies to your Main Hand on Right-Click."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Chooses the poison your Poisons macro applies to your Off Hand on Left-Click."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Enable Stealth Eating"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "Appends %s to your Food macro so you stealth while eating."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Enable Stealth Drinking"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "Appends %s to your Water macro so you stealth while drinking."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Pro Tip: Pick one. You can eat and drink at the same time, but eating or drinking after you stealth will break your stealth."

--[[
    Forsaken, headed with the client's name for the race (Undead). In the
    five texts below, %s is the client's name for Cannibalize. Drinking shows
    only where Cannibalize restores mana.
]]
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Target a Humanoid or Undead you've killed and your macro casts %s while it's off cooldown, saving your food and drink. If it can't (the corpse is out of reach, or the spell is on cooldown), it eats or drinks as usual."
L["OPTIONS_CANNIBALIZE_EATING"] = "Use %s Instead of Eating"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"While your target is a corpse %s works on and the spell is off cooldown, your Food macro casts it instead of eating. Otherwise it eats as usual. Scrolls and buff food still come first."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Use %s Instead of Drinking"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"While your target is a corpse %s works on and the spell is off cooldown, your Water macro casts it instead of drinking. Otherwise it drinks as usual. Buff drinks still come first."

--[[
    Trolls, headed with the client's name for the race. In the three texts
    below, %s is the client's name for Rapid Regeneration. WoW Forever only.
]]
L["OPTIONS_RAPID_REGENERATION_DESCRIPTION"] =
	"While %s is off cooldown, your Food macro casts it instead of eating, saving your food. Once it's on cooldown, the macro eats as usual."
L["OPTIONS_RAPID_REGENERATION_EATING"] = "Use %s Instead of Eating"
L["OPTIONS_RAPID_REGENERATION_EATING_DESCRIPTION"] =
	"While %s is off cooldown, your Food macro casts it instead of eating. Otherwise it eats as usual. Scrolls and buff food still come first. In combat, where nobody eats, every press casts it."

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
L["TAB_IGNORE_LIST"] = "Ignore List"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ignored items are never picked by any macro. Food, water, potions, anything. The Global list covers every character; a character's list covers only that one. Right-Click the mini-map button to ignore your current best food."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "Moves this item to the Global list, so it is ignored on every character."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Add From Bags"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Pick anything you're carrying. The bags close when the Options Interface opens, so this stands in for dragging an item here."
L["OPTIONS_IGNORE_ADD_ID"] = "Add by Item ID"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Type an item ID, or Shift + Click an item link in chat while this box has focus."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Type an item ID, or Shift + Click an item link in chat."
L["OPTIONS_IGNORE_REMOVE"] = "Remove"
L["OPTIONS_IGNORE_EMPTY"] = "This list is empty."
L["OPTIONS_IGNORE_CLEAR"] = "Clear List"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Removes every item from this list. A character whose list is empty drops off the list on the left, unless it's the one you're playing."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "Remove every item from this list? This can't be undone."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Loading ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Keeps your bags stocked from your Restock List, buying from merchants and moving items to and from the bank automatically. Type %s to open the list."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Open at Bank"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Opens your Restock List when you visit the bank."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Open at Merchant"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Opens your Restock List when you visit a merchant."
-- The header over the three reminder rows below, which follow the Gold Reserve section on the page, and its description.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Reminders"
L["OPTIONS_RESTOCKER_REMINDERS_DESCRIPTION"] = "Choose when you're told your Restock List is running short."
L["OPTIONS_RESTOCKER_REMIND"] = "Enable In-Town Restock Reminders"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Prints a chat reminder when your Restock List is short of something and you reach an inn or a city, or log in already standing in one."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Enable At-Merchant Restock Reminders"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Reports any outstanding restocking orders when you close a merchant window."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Enable At-Bank Restock Reminders"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "Reports any outstanding restocking orders when you close the bank."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text. HEADER
    and SECTION_DESCRIPTION head its section.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE_HEADER"] = "Gold Reserve"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_SECTION_DESCRIPTION"] = "Set aside gold that buying from merchants never spends."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Enable Gold Reserve"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "Restocking never spends the gold you set aside here."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Sets how much gold restocking always leaves you."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Chooses whether the reminder is a single line or adds a line for each item you're short on."
L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"] = "How Much to Say"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Verbose"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Play Sound"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "Plays an alert alongside the reminder, for when chat is busy."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Click to hear the alert."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Restock List Window"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Choose when your Restock List opens on its own."

--[[
    The Inventory Report's page, named by the report's own title
    (INVENTORY_REPORT_TITLE, in the Inventory Report section above): its
    description and its switch.
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Shows how many of an item you own, across your characters on this realm, in its tooltip."
-- The other characters the Inventory Report remembers, each with a remove icon. In the confirm, %s is the character's name.
L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"] = "Recorded Characters"
L["INVENTORY_REPORT_FORGET_CHARACTER"] = "Forget"
L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"] =
	"Forget %s? Their bags and bank leave every item tooltip, and their Restock List choice is cleared. Logging in on them records them again."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Readiness Report"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"When a ready check starts, prints a private list of what still needs fixing, and says nothing at all when you are ready."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Reset Readiness Report Settings"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] = "Returns every checkbox and both thresholds on this page to their defaults."
L["OPTIONS_READINESS_RESET_CONFIRM"] = "Reset every Readiness Report setting to its default?"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Missing Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Missing Items"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Character"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Reports a missing flask. A flask, or one battle elixir and one guardian elixir, counts as covered."
L["OPTIONS_READINESS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Reports a missing "%s" buff. Needs Buff Food turned on under Consumable Macros.'
L["OPTIONS_READINESS_PET_FOOD_BUFF_DESCRIPTION_FORMAT"] =
	'Reports your pet\'s missing "%s" buff. Needs Pet Food Buffs turned on under Consumable Macros, and a pet out.'
L["OPTIONS_READINESS_SCROLL_BUFFS_DESCRIPTION"] =
	"Reports missing scroll buffs. Needs Scroll Buffs turned on under Consumable Macros, and checks only the scroll types selected there."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Reports when no one in your group has a Soulstone active; one sitting in a bag doesn't count. Only reported to a Warlock who can create one."
L["OPTIONS_READINESS_MAIN_HAND"] = "Main Hand Weapon Buff"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Reports a Main Hand weapon with no temporary enchant. Any enchant counts, and it stays quiet when there is a Shaman in your group."
L["OPTIONS_READINESS_OFF_HAND"] = "Off Hand Weapon Buff"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Reports an Off Hand weapon with no temporary enchant. Any enchant counts: a stone, an oil, a poison, or a Shaman weapon buff."
-- WoW Forever, where an imbue sits beside an oil or stone (ns.WEAPON_ENCHANTS_STACK).
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION_STACKED"] =
	"Reports a Main Hand weapon missing a temporary enchant. Rogues and Shamans are asked for two, a poison or imbue beside an oil or stone; anyone else, for any one."
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION_STACKED"] =
	"Reports an Off Hand weapon missing a temporary enchant. Rogues are asked for two, a poison beside an oil or stone; anyone else, for any one."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Consumable Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buffs Expiring Within"
L["OPTIONS_READINESS_EXPIRING_BUFFS_DESCRIPTION"] =
	"Names every buff on you that is about to expire, not just the ones Good to Go applies, and is separate from Buff Reapplication under Consumable Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s Minutes"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 Minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Sets how close to expiring a buff must be for the report to name it."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Reports when you carry no Healthstone. Only reported when there's a Warlock in your group to ask, or when you're the Warlock."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Reports when you carry no Mana Gem. Only reported to a Mage who can conjure one."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Reports when you carry no healing potion, since nobody can hand you one mid-fight."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Reports when you carry no mana potion. Only reported when you're playing a class that uses mana."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] = "Reports when you carry no bandage your %s skill lets you use."
L["OPTIONS_READINESS_DURABILITY"] = "Damaged Gear Below"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Links every equipped item under this much durability, measured per item so one broken weapon still shows."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Sets how low an item's durability must fall for the report to link it."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Current Spec"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "Prints your talent spread, and any points you have not spent."
L["OPTIONS_READINESS_PVP"] = "PvP Flag On"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Warns when your PvP flag is up."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Non-Combat Gear Equipped"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Links equipped items that do not belong in a fight, such as riding or fishing gear."

--------------------------------------------------------------------------------
-- Rank Watch
--------------------------------------------------------------------------------

--[[
    Rank Watch tells a group member who cast a spell at a lower rank than they could have. Its messages are
    fixed, one whisper and one print, with nothing for the player to edit. Rank Sentinel is the standalone
    add-on Rank Watch replaces; its name stays as written in every locale.
]]
L["TAB_RANK_WATCH"] = "Rank Watch"
L["OPTIONS_RANK_WATCH_DESCRIPTION"] =
	"Watches your group for spells cast at a lower rank than the caster could have, and lets them know a higher rank is waiting at their trainer. A rank the game lowers on its own, like a buff on a low-level player, is never reported."
--[[
    Printed at login, and when the switch is turned on, while the standalone add-on runs; also shown on the
    panel. %s is the standalone add-on's title.
]]
L["RANK_WATCH_STANDALONE"] =
	"%s is still running, so Rank Watch stays quiet to keep your group from hearing about every low rank twice. Good to Go has turned it off and Rank Watch on; reload to let Rank Watch take over."

-- A spell and its rank in every message: "[Arcane Intellect] (Rank 3)". The first %s is the spell, the second its rank.
L["RANK_WATCH_SPELL_RANK"] = "%s (%s)"
-- A rank's number, where the client hasn't loaded the spell's own rank text yet.
L["RANK_WATCH_RANK"] = "Rank %d"

--[[
    The whisper to the caster. { the spell and rank they cast, the level a higher rank is learned at } Sent
    after the marker and before " // GtG", so "Good to Go" runs straight into the sign-off: "...and you'll be
    Good to Go // GtG". Casual on purpose; a stranger's whisper should read as a tip, not a correction.
]]
L["RANK_WATCH_MESSAGE_WHISPER"] =
	"FYI, no biggie, but you used %s. There's a newer rank at level %d. Update your action bars or visit your trainer and you'll be Good to Go."
--[[
    The whisper to a pet's owner, the same shape with the pet first. { the pet, the spell and rank it cast, the
    level a higher rank comes at } A hunter pet is named ("your pet Fluffy") and its level is its own; a demon is
    named by its kind ("your Imp"), and its level is the warlock's, which a grimoire asks for.
]]
L["RANK_WATCH_MESSAGE_WHISPER_PET"] =
	"FYI, no biggie, but your pet %s used %s. There's a newer rank at pet level %d. Teach it with Beast Training and you'll be Good to Go."
L["RANK_WATCH_MESSAGE_WHISPER_DEMON"] =
	"FYI, no biggie, but your %s used %s. There's a newer rank at level %d. Grab its grimoire from a demon trainer and you'll be Good to Go."
--[[
    Sent once per player, right after the first whisper they ever get from you, so a stranger's tip comes with a
    way to make it stop. Signed off like the whisper above it. %s is their opt-out number, made from their name,
    so it is the same from everyone running Good to Go.
]]
L["RANK_WATCH_MESSAGE_OPT_OUT"] =
	"Rather not get tips like this? Reply %s and I won't whisper you about spell ranks again. Your number works with anyone running Good to Go."
-- Sent back once to a player who whispered their opt-out number.
L["RANK_WATCH_MESSAGE_OPT_OUT_DONE"] = "Got it, no more rank tips from me."
-- Printed when a player says their opt-out number. %s is their name.
L["RANK_WATCH_OPT_OUT_ADDED"] =
	"%s sent their opt-out number, so Rank Watch now ignores them. Ignored Players under Rank Watch can undo it."
-- Printed when you cast a low rank yourself. { the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF"] =
	"You cast %s, and %s is available from level %d. Visit your trainer or update your action bars."
-- Printed when your own pet casts one. { the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_SELF_PET"] = "Your pet %s cast %s, and %s is available from pet level %d."
L["RANK_WATCH_PRINT_SELF_DEMON"] = "Your %s cast %s, and %s is available from level %d."
-- Printed when a group member casts one. { their name, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER"] = "%s cast %s, and %s is available to them from level %d."
-- A group member's pet. { the owner's name, the pet, the spell and rank, the higher spell and rank, its level }
L["RANK_WATCH_PRINT_OTHER_PET"] = "%s's pet %s cast %s, and %s is available to it from pet level %d."
L["RANK_WATCH_PRINT_OTHER_DEMON"] = "%s's %s cast %s, and %s is available to it from level %d."
-- Added after the print when another player's add-on whispers for the group. %s is that player's name.
L["RANK_WATCH_PRINT_WHISPERER"] = "%s will whisper them."

-- Features: the switch, also on the panel.
L["SWITCH_RANK_WATCH"] = "Enable Rank Watch"
L["SWITCH_RANK_WATCH_DESCRIPTION"] =
	"Tells you, and whispers your group members, when someone casts a spell at a lower rank than they could have, so they know to visit their trainer."

L["RANK_WATCH_MESSAGES_HEADER"] = "Notifications"
L["RANK_WATCH_MESSAGES_DESCRIPTION"] = "How Rank Watch lets a player know they cast a low rank."
L["RANK_WATCH_WHISPER"] = "Whisper Group Members"
L["RANK_WATCH_WHISPER_DESCRIPTION"] =
	"Whispers a group member who cast a low rank. When several players in your group run Rank Watch or Rank Sentinel, only one of them whispers."
L["RANK_WATCH_PRINT"] = "Print Group Members' Low Ranks"
L["RANK_WATCH_PRINT_DESCRIPTION"] = "Prints a group member's low rank in your chat. Your own low ranks always print."
L["RANK_WATCH_GRACE_HEADER"] = "Grace Period"
L["RANK_WATCH_GRACE_DESCRIPTION"] =
	"A new rank isn't reported until the caster has been past its level for this many levels, so nobody hears about a rank they only just reached and haven't had time to train."
L["RANK_WATCH_GRACE_MAX_LEVEL"] = "Grace Period at Max Level"
L["RANK_WATCH_GRACE_MAX_LEVEL_DESCRIPTION"] =
	"For a character at max level, leaves alone any rank learned within this many levels of it. At 0, every rank they could have is reported."
L["RANK_WATCH_GRACE_LEVELING"] = "Grace Period While Leveling"
L["RANK_WATCH_GRACE_LEVELING_DESCRIPTION"] =
	"For a character still leveling, leaves alone any rank learned within this many levels of their own, giving them time to get to a trainer."
-- The grace period dropdowns' choices: 1, then 0 and 2 to 5.
L["RANK_WATCH_GRACE_LEVEL"] = "1 Level"
L["RANK_WATCH_GRACE_LEVELS"] = "%d Levels"

L["RANK_WATCH_OPT_OUT_HEADER"] = "Opt Out"
L["RANK_WATCH_OPT_OUT_DESCRIPTION"] =
	"The first time Rank Watch whispers someone, it follows up with their opt-out number. The number comes from their name, so it's the same with everyone running Good to Go. If they say it in a whisper or any chat you can see, they go on Ignored Players and never hear from you about ranks again. To leave someone alone yourself, target them and type /gtg ignore."
L["RANK_WATCH_WHISPERER_HEADER"] = "Who Reports for Your Group"
L["RANK_WATCH_WHISPERER_DESCRIPTION"] =
	"When several people in your group run Rank Watch or Rank Sentinel, only one of them sends the whispers, so a player who casts a low rank hears about it once instead of from everyone. The others only print it in their own chat. This is who sends them right now."
L["RANK_WATCH_WHISPERER_SELF"] = "You do."
-- %s is the player whose Rank Watch or Rank Sentinel whispers for the group.
L["RANK_WATCH_WHISPERER_OTHER"] = "%s does, so you only see the print."
L["RANK_WATCH_WHISPERER_NONE"] = "Nobody: Whisper Group Members is off."

-- Ability Alerts While Leveling: the Rank Watch panel's section for the level-up prints (LEVEL_UP_SPELLS and the rest)
L["RANK_WATCH_LEVEL_UP_HEADER"] = "Ability Alerts While Leveling"
L["RANK_WATCH_LEVEL_UP_DESCRIPTION"] = "When you level, chat lists the abilities your class trainer has for you, each with its icon and a link you can hover. This runs on its own switch, whether Rank Watch is on or not."
L["RANK_WATCH_LEVEL_UP"] = "Announce New Abilities When You Level"
L["RANK_WATCH_LEVEL_UP_TOGGLE_DESCRIPTION"] = "Lists the abilities that open at the level you just reached."
L["RANK_WATCH_LEVEL_UP_PAST"] = "Include Abilities You Skipped"
L["RANK_WATCH_LEVEL_UP_PAST_DESCRIPTION"] = "Adds a line for abilities from earlier levels you haven't learned yet."
L["RANK_WATCH_LEVEL_UP_PET"] = "Include Pet Abilities"
L["RANK_WATCH_LEVEL_UP_PET_DESCRIPTION"] = "Adds the pet trainer's abilities for hunters, or the demon trainer's grimoires for warlocks, that open at your new level."
L["RANK_WATCH_LEVEL_UP_PET_PAST"] = "Include Pet Abilities You Skipped"
L["RANK_WATCH_LEVEL_UP_PET_PAST_DESCRIPTION"] = "Hunters only: adds a line for pet trainer abilities from earlier levels you haven't learned yet. Warlocks don't get this line, because the game doesn't say which grimoires a demon has learned while it's away."

-- Ignored Players, under Rank Watch.
L["RANK_WATCH_IGNORED_HEADER"] = "Ignored Players"
L["RANK_WATCH_IGNORED_DESCRIPTION"] = "Rank Watch never reports these players."
L["RANK_WATCH_IGNORED_NONE"] = "Nobody yet."
L["RANK_WATCH_IGNORED_REMOVE"] = "Stop Ignoring"
L["RANK_WATCH_IGNORE_TARGET"] = "Ignore Target"
L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"] = "Adds the player you have targeted to the list."
L["RANK_WATCH_IGNORE_ADDED"] = "Rank Watch now ignores %s."
L["RANK_WATCH_IGNORE_NOT_FOUND"] = "Can't find %s. Group with them or target them, then try again."
L["RANK_WATCH_IGNORE_NO_TARGET"] = "Target a player, or type /gtg ignore Name."
L["RANK_WATCH_IGNORE_COMMAND"] = "/gtg ignore Name"
L["RANK_WATCH_IGNORE_COMMAND_DESCRIPTION"] =
	"Rank Watch stops reporting that player. With no name, ignores your target."

-- Tracked Abilities, under Rank Watch.
L["RANK_WATCH_TRACKED_DESCRIPTION"] =
	"The ranks Rank Watch reports, class by class. Uncheck a rank you lower on purpose and Rank Watch leaves it alone. Every ability is listed. The ones Rank Watch doesn't watch by default, like heals, talents, and Rank 1 Scorch, start unchecked. An ability's highest rank is grayed out, since nothing is above it."
-- A rank's checkbox. %s is the rank ("Rank 3"), %d the level it is learned at.
L["RANK_WATCH_RANK_LEVEL"] = "%s (Level %d)"
L["RANK_WATCH_RANK_DESCRIPTION"] = "Reports this rank when a higher one is available."
L["RANK_WATCH_TOP_RANK_DESCRIPTION"] = "The highest rank. Nothing is above it, so it is never reported."
-- The tree entry after Hunter and Warlock listing their pets' and demons' abilities. %s is the class name.
L["RANK_WATCH_PETS"] = "%s Pets"
L["RANK_WATCH_TRACK_ALL"] = "Check All"
L["RANK_WATCH_TRACK_NONE"] = "Uncheck All"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'A list named "%s" already exists.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "No item has ID %d."
L["RESTOCKER_DISABLED"] = "The Restocker is off. Turn it on under Options > AddOns > Good to Go > Restocker."
-- %s is the list name the player typed after /restock profile use, delete or copy.
L["RESTOCKER_LIST_NOT_FOUND"] = "No Restock List named %s."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Restocking complete. Hold Shift while opening the bank to skip restocking. Type %s to edit your Restock List."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Restocking stopped. Both your bags and your bank are full."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Restocking stopped. Your bank is full; free a slot and reopen it."
L["RESTOCKER_STOPPED_BAG_FULL"] = "Restocking stopped. Your bags are full; free a slot and reopen the bank."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Restocking stopped. No progress could be made."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Restocking stopped. Couldn't move: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (extra)"
L["RESTOCKER_STOPPED_ERROR"] = "Restocking stopped due to an error: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] = "This merchant doesn't stock every ingredient your poisons need. Skipping them all."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Don't forget to restock while you're in town!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 restocking order outstanding."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d restocking orders outstanding."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Your Restock List has been upgraded."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d upgrades to %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 restocking order filled."
L["RESTOCKER_RESTOCKED_MANY"] = "%d restocking orders filled."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 restocking order partly filled."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d restocking orders partly filled."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Your bags filled up before everything was bought."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off or the purse started above it.
L["RESTOCKER_OUT_OF_GOLD"] = "Not enough gold to finish restocking."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] = "You have less than %s. Restocking will resume when you have more."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Adds a list with that name."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Deletes the list with that name."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renames the current list to that name."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Replaces the current list with a copy of that list."
L["RESTOCKER_HELP_PROFILE_USE"] = "Switches this character to the list with that name."

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
L["STARTER_POPUP_TITLE"] = "Staples"
-- The button at the Staples window's footer end that closes it once you've picked.
L["STARTER_POPUP_DONE"] = "Done"
L["STARTER_POPUP_INTRO_LOGIN"] = "We've checked a few staples for your class to get you started."
L["STARTER_POPUP_INTRO_EMPTY"] = "Your Restock List is empty, so let's add some items to get you started."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Pick the staples you want kept stocked."
L["STARTER_POPUP_INTRO_HOW"] =
	"Anything you check is automatically restocked whenever you open a merchant or your bank. Most staples upgrade themselves as you level, so you'll always have the best available."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "You can always adjust this list, or add more items later, by typing %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Food & Water"
L["STARTER_POPUP_FOOD_HEADER"] = "Food"
L["STARTER_POPUP_AMMO_HEADER"] = "Ammo"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Bullets"
L["STARTER_POPUP_ARROWS"] = "Arrows"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagents & Tools"
L["STARTER_POPUP_POISONS_HEADER"] = "Poisons"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Add the finished poison to your list, and Good to Go buys the ingredients automatically at any merchant that stocks them all."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Adds %s to your Restock List, keeping %d in your bags and upgrading them as you level."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Adds %s to your Restock List, keeping %d in your bags."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 Stack"
L["STARTER_POPUP_STACK_MANY"] = "%d Stacks"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "How many stacks to keep stocked, where one stack is %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] = "How many to keep stocked, each in its own bag slot since these do not stack."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Restock List"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filter items..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Clear"
L["RESTOCKER_ADD_BUTTON"] = "Add"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Pick Staples"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Choose from the staples for your class and level: food, water, ammo, poisons, and reagents. Checking one adds it to this list, and unchecking removes it."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Add an Item"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Drop an item from your bags here or anywhere on this window, or type an item ID and press Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Drop item or type item ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Type an item ID instead."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Already on this list."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Add Item From Bags"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] = "Every item in your bags that isn't on this list yet, ready to add."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nothing in Your Bags to Add"

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
L["RESTOCKER_PROFILE_LABEL"] = "List"
L["RESTOCKER_PROFILE_TOOLTIP"] = "Switches this character to another Restock List, or starts a new one."
L["RESTOCKER_USED_BY"] = "Used by %s"
L["RESTOCKER_MANAGE"] = "Manage Lists"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Start a new list, or copy, rename, or delete this one."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "New List"
L["RESTOCKER_MANAGE_COPY"] = "Copy This List Into a New One"
L["RESTOCKER_RENAME_PROFILE"] = "Rename This List"
L["RESTOCKER_MANAGE_DELETE"] = "Delete This List"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s Copy"
-- A list name already taken, numbered: a new list's class name ("Warrior (2)"), and a copy's name ("Fishing Copy 2").
L["RESTOCKER_LIST_NAME_NUMBERED"] = "%s (%d)"
L["RESTOCKER_LIST_NAME_COPY"] = "%s %d"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Rename"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renames this list for every character using it."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Are you sure you want to delete this list?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s uses it too, and will log in to an empty list with the same name."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] = "%s use it too, and will each log in to an empty list with the same name."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "You'll switch to %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "It's the only list left, so you'll start on a new, empty one."
L["RESTOCKER_DELETE_LIST_FINAL"] = "This can't be undone."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Upgrade as You Level"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Lets Good to Go upgrade food, water, ammo, poisons, potions, and class reagents to better items as you level."

--[[
    The Upgrade column's caption. The Bank and Merchant bands over the other
    columns are the client's own BANK and MERCHANT strings.
]]
L["RESTOCKER_ROW_UPGRADE"] = "Upgrade"

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
L["RESTOCKER_COLUMN_WITHDRAW"] = "Take"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Store"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Keep"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "The heading sets this for every item shown."
L["RESTOCKER_BULK_ON"] = "Turn On for %d Shown"
L["RESTOCKER_BULK_OFF"] = "Turn Off for %d Shown"

L["RESTOCKER_GROUP_OTHER"] = "Other"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "New"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "All Items"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Nothing on This List Yet"
L["RESTOCKER_EMPTY_BODY"] =
	"Pick staples like food, water, or class reagents, or add anything from your bags with the menu above. Items on this list are automatically kept stocked or deposited into your bank, keeping your bags clean."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Dropping an item anywhere on this window adds it too."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nothing on this list matches your filter."
L["RESTOCKER_NO_MATCH_GROUP"] = "Nothing left in this category."

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
L["RESTOCKER_NO_ORDERS"] = "No restocking orders outstanding."
L["RESTOCKER_REPORT_MORE"] = "And %d more."
L["RESTOCKER_REMOVED_ITEM"] = "Removed %s."
L["RESTOCKER_UNDO"] = "Undo"
L["RESTOCKER_UNDO_TOOLTIP"] = "Put This Item Back on the List"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Remove This Item From the Restock List"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "You can undo this from the top of the list."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Keep in Your Bags"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"How many to keep in your bags. The number turns yellow while your bags hold fewer, and 0 with Store on sends all of it to the bank."
L["RESTOCKER_BUY_LABEL"] = "Buy"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Buy From Merchant"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Buys the needed amount from the merchant when the merchant window is open."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Buy Extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Buys a merchant's whole limited stock of this item, the few-at-a-time goods it slowly restocks, even past your Keep amount."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Store in Bank"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Stores extra items in the bank when the bank is open, or all of them with 0 in the Keep column."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Take From Bank"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Takes needed items from the bank when the bank is open."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Required Reputation"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% off)"
L["RESTOCKER_REPUTATION_ANY"] = "Any"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Required Merchant Reputation"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Sets the standing a merchant needs before Good to Go buys from it, which also cuts the price: %s 5%%, %s 10%%, %s 15%%, %s 20%%. A dash buys from any merchant."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = "Buy is off for this item, so there is nothing to buy extra of."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = "Buy is off for this item, so no standing applies."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "This item has no better version to upgrade to."

-- The add-ons this one replaces, turned off at login whenever they run (ns.REPLACED_ADDONS).
L["POPUP_REPLACED_RELOAD"] = "Good to Go turned off %s, which it replaces. Reload now so the old copy stops running?"
L["POPUP_REPLACED_RELOAD_ACCEPT"] = "Reload Now"
L["POPUP_REPLACED_LATER"] = "Later"

-- MIGRATION (remove after 2026-12-08): the import from the add-ons this one replaces.
L["CHAT_LEGACY_IMPORTED"] = "Copied your %s settings."

L["POPUP_LEGACY_RELOAD_COPIED"] =
	"Good to Go copied your settings from %s and turned off %s, which it replaces. Reload now so the old copy stops running?"
L["POPUP_LEGACY_IMPORT_SETTINGS"] =
	"Good to Go found %s installed but turned off. Bring the settings over? This turns the old add-ons back on and reloads your UI, then offers one more reload to turn them off again."
L["POPUP_LEGACY_IMPORT_LISTS"] =
	"Good to Go found %s installed but turned off. Bring the settings and Restock Lists over? This turns the old add-ons back on and reloads your UI, then offers one more reload to turn them off again."
L["POPUP_LEGACY_IMPORT_ACCEPT"] = "Bring Them Over"
L["POPUP_LEGACY_IMPORT_DECLINE"] = "No Thanks"

--------------------------------------------------------------------------------
-- Options: Tracked Abilities
--------------------------------------------------------------------------------

-- The two Tracked Abilities panels' titles, Buff Duty's then Rank Watch's, and the stand-in for an item or spell whose name the client hasn't loaded yet.
L["BUFF_DUTY_TRACKED_HEADER"] = "Group Buffs"
L["RANK_WATCH_TRACKED_HEADER"] = "Reported Ranks"
L["TRACKED_ITEM_PENDING"] = "Item #%d"
L["TRACKED_SPELL_PENDING"] = "Spell #%d"

--------------------------------------------------------------------------------
-- Shared: Sound Preview
--------------------------------------------------------------------------------

L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Plays the sound so you can hear it before turning it on."

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_DUTY"] = "Buff Duty"
L["BUFF_DUTY_DESCRIPTION"] = "Shows who's missing your buffs. Click an icon to cast."
L["BUFF_DUTY_ENABLE"] = "Enable Buff Duty"
L["BUFF_DUTY_NO_BUFFS"] = "Your class has no buffs on this list, so the window never appears on this character."
-- When to Show: the group context checkboxes (GROUP_CONTEXT_*), Anywhere or In Instance beside the first three, then the classes.
L["BUFF_DUTY_WHEN_HEADER"] = "When to Show"
L["BUFF_DUTY_WHEN_DESCRIPTION"] = "Choose when the window can appear."
L["BUFF_DUTY_WHEN_NONE"] = "Nothing is checked, so the window never appears."
L["BUFF_DUTY_AURAS_HIDDEN"] =
	"Buff Duty is hidden here. The game doesn't let add-ons see buffs in this area, so it can't tell who is missing one."
L["BUFF_DUTY_WHERE_DESCRIPTION"] =
	"Sets where the window shows: anywhere, or only inside an instance, like a dungeon or raid."
L["BUFF_DUTY_WHERE_ALWAYS"] = "Anywhere"
L["BUFF_DUTY_WHERE_INSTANCE"] = "In Instance"
L["BUFF_DUTY_CLASSES_DESCRIPTION"] = "Show the window when you're playing these classes."
L["BUFF_DUTY_CLASS_DESCRIPTION"] = "Shows the window while you're playing this class."
L["BUFF_DUTY_HEADER"] = "Window"
L["BUFF_DUTY_WINDOW_DESCRIPTION"] = "Keep the window where you put it, or out of the way in combat."
L["BUFF_DUTY_LOCK"] = "Lock Window"
L["BUFF_DUTY_LOCK_DESCRIPTION"] = "Stops the window from moving. Unlocked, drag it by its background."
L["BUFF_DUTY_HIDE_IN_COMBAT"] = "Hide in Combat"
L["BUFF_DUTY_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Hides the window during combat. The list can't update in combat, so a window left showing keeps its last state until combat ends."
L["BUFF_DUTY_SHOW_HEADER"] = "Show in Window"
L["BUFF_DUTY_SHOW_DESCRIPTION"] = "Add your own buffs, the strangers who buffed you, and your target to the window."
L["BUFF_DUTY_FAVOR_ENABLE"] = "Return the Favor"
L["BUFF_DUTY_FAVOR_ENABLE_DESCRIPTION"] =
	"Lists the strangers who recently buffed you, with the buffs you can give them back. Right-Click an icon to take someone off the list."
L["BUFF_DUTY_FAVOR_SECONDS_DESCRIPTION"] = "Sets how long a stranger stays on the list after their last buff."
L["BUFF_DUTY_TARGET_ENABLE"] = "Your Target"
L["BUFF_DUTY_TARGET_ENABLE_DESCRIPTION"] =
	"Lists your target when they are a player outside your group missing a buff you can give."
L["BUFF_DUTY_ASK_OTHERS"] = "Ask Other Classes for Buffs"
L["BUFF_DUTY_ASK_OTHERS_DESCRIPTION"] =
	"Under Missing Party Buffs, shows the raid buffs your group needs and how many players need each. Left-Click one to ask your group for it, or Right-Click to whisper the players who can cast it."
L["BUFF_DUTY_REFRESH"] = "Refresh Under"
L["BUFF_DUTY_REFRESH_DESCRIPTION"] =
	"Sets how little time a buff can have left before it counts as missing, so you can top it up before it drops. A buff that lasts no longer than this only counts once it's gone."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_DUTY_TANKS_HEADER"] = "Count as Tanks"
L["BUFF_DUTY_TANKS_DESCRIPTION"] =
	"Who gets the buffs you offer to Tanks, like Thorns, when they have no role of their own."
L["BUFF_DUTY_TANKS_CLASS_DESCRIPTION"] =
	"Sets when players of this class count as tanks. A tank or healer role they have always comes first."
L["BUFF_DUTY_TANKS_PETS"] = "Pets"
L["BUFF_DUTY_TANKS_PETS_DESCRIPTION"] = "Sets when pets count as tanks. Pets also get the buffs you offer to Everyone."
L["BUFF_DUTY_TANKS_NEVER"] = "Never"
L["BUFF_DUTY_TANKS_SOLO"] = "When Solo"
L["BUFF_DUTY_TANKS_ALWAYS"] = "Always"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_DUTY_AUDIENCE_OFF"] = "Off"
L["BUFF_DUTY_AUDIENCE_TANK"] = "Tanks"
L["BUFF_DUTY_AUDIENCE_HEALER"] = "Healers"
L["BUFF_DUTY_AUDIENCE_ALL"] = "Everyone"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_DUTY_AUDIENCE_DESCRIPTION"] = "Sets who %s is offered to."
-- %s is the game's own Main Tank label.
L["BUFF_DUTY_BUFFS_DESCRIPTION"] =
	"Choose who's offered each buff. Tanks and Healers go by group role, but in a raid only players marked %s count as tanks. Anyone without a role counts as Damage, unless Count as Tanks below says otherwise."

-- The Self-Buffs panel, under Buff Duty: its name and description.
L["BUFF_DUTY_SELF_HEADER"] = "Self-Buffs"
L["BUFF_DUTY_SELF_DESCRIPTION"] = "Your own buffs, pinned to the top of the window."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_DUTY_SELF_NOTE_ASPECT"] = "any one aspect counts"
L["BUFF_DUTY_SELF_NOTE_MAGE_ARMOR"] = "any one armor counts"
L["BUFF_DUTY_SELF_NOTE_PALADIN_AURA"] = "any one aura counts"
L["BUFF_DUTY_SELF_NOTE_SHAMAN_SHIELD"] = "any one shield counts"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_ARMOR"] = "any one armor counts"
L["BUFF_DUTY_SELF_NOTE_WARLOCK_DEMON"] = "either demon buff counts"
L["BUFF_DUTY_SELF_REFRESH_OFF"] = "Off"
L["BUFF_DUTY_SELF_REFRESH_MISSING"] = "When Missing"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_DUTY_SELF_REFRESH_UNDER"] = "Under %s"
L["BUFF_DUTY_SELF_REFRESH_DESCRIPTION"] =
	"Sets when %s shows: never, once it's gone, or once it has less than this left."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_DUTY_WEAPON_PANEL_HEADER"] = "Weapon Buffs"
L["BUFF_DUTY_WEAPON_DESCRIPTION"] =
	"Check what each weapon should carry. The window offers it when it's missing or running low, if it's in your bags and fits the weapon."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_DUTY_WEAPON_REFRESH"] = "Reapply"
L["BUFF_DUTY_WEAPON_REFRESH_DESCRIPTION"] =
	"Sets when a weapon buff is offered again: once it's gone, or once it has less than this left."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_DUTY_WEAPON_KIND_OIL"] = "Oils"
L["BUFF_DUTY_WEAPON_KIND_STONE"] = "Stones"
L["BUFF_DUTY_WEAPON_KIND_LURE"] = "Lures"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"] =
	"Offers %s for your %s. While the weapon carries none of your checked choices, each one you have is offered."
L["BUFF_DUTY_SELF_ENABLE"] = "Your Self-Buffs"
L["BUFF_DUTY_SELF_ENABLE_DESCRIPTION"] =
	"Shows the buffs only you can put on yourself, like an armor or Inner Fire, at the top of the window when they're missing or running low. Pick which ones under Self-Buffs."
L["BUFF_DUTY_WEAPON_ENABLE"] = "Your Weapon Buffs"
L["BUFF_DUTY_WEAPON_ENABLE_DESCRIPTION"] =
	"Shows the poisons, imbues, oils, stones, and lures your weapons are missing or running low on, with your self-buffs at the top of the window. Click one to put it on. Pick which ones under Weapon Buffs."

-- The window itself
-- The window's header over your own buffs and weapon rows (BUFF_DUTY_SELF_HEADER names the options panel).
L["BUFF_DUTY_MISSING_SELF_HEADER"] = "Missing Self-Buffs"
L["BUFF_DUTY_PARTY_BUFFS_HEADER"] = "Missing Party Buffs"
L["BUFF_DUTY_FAVOR_HEADER"] = "Return the Favor"
L["BUFF_DUTY_TARGET_HEADER"] = "Target"
-- A buff icon's tooltip ends with who the click lands on.
L["BUFF_DUTY_TOOLTIP_CAST"] = "Casts on %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_DUTY_TOOLTIP_WEAPON"] = "Applies to your %s."
L["BUFF_DUTY_TOOLTIP_USE"] = "Nobody in your group has a Soulstone. Uses one on %s."
L["BUFF_DUTY_TOOLTIP_CREATE"] = "Nobody in your group has a Soulstone. Creates one."
L["BUFF_DUTY_TOOLTIP_GROUP"] = "Casts on %s and their party."
L["BUFF_DUTY_TOOLTIP_FAVOR"] = "Targets %s and casts."
-- A Party Buffs icon's tooltip, its click hints: a click asks the group for the buff (PARTY, RAID, BATTLEGROUND or INSTANCE, the client's own word), a right-click whispers the players who can cast it.
L["BUFF_DUTY_OTHERS_HINT_ASK"] = "Ask for Buff in %s"
L["BUFF_DUTY_OTHERS_HINT_WHISPER"] = "Directly Message Buffers"
--[[
    The ask either click sends, signed off like every sent message ({star} ... // GtG), so it
    ends as a statement, not a question. Up to five missing players are named (ONE for one,
    NAMES for two to five, joined with LIST_PAIR_FORMAT or LIST_LAST_FORMAT), then the buff's link;
    past five, COUNT gives how many, then the link.
]]
L["BUFF_DUTY_OTHERS_ASK_ONE"] = "%s is missing %s."
L["BUFF_DUTY_OTHERS_ASK_NAMES"] = "%s are missing %s."
L["BUFF_DUTY_OTHERS_ASK_COUNT"] = "%d people are missing the %s buff."
--[[
    The window's close button: the class name, the class name again for its
    checkbox, the When to Show header, then the options command.
]]
L["BUFF_DUTY_CLOSED"] =
	"Buff Duty is hidden until you log in again or reload. To bring it back now, Shift + Left-Click the mini-map button. To keep it off for the %s class, uncheck %s under %s in %s."

-- The Buff Button key: its name in the game's Key Bindings list and the root panel's Key Bindings section, then the notices a press shows.
L["BUFF_KEY"] = "Buff Button"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Waiting on %s to get in range."
L["BUFF_KEY_DONE"] = "Nothing left to buff."
L["BUFF_KEY_OFF"] = "Buff Duty is off."
--[[
    The Buff Duty window's last line while the Buff Button has no key: the Buff
    Button's name (BUFF_KEY), the root panel's Key Bindings header
    (OPTIONS_KEY_BINDINGS_HEADER), then the options command.
]]
L["BUFF_DUTY_KEY_HINT"] =
	"Did you know? Bind a key to the %s and each press casts the next buff here. Set it under %s in %s."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- The window's first tab, and its title before "// Good to Go", is TAB_ENHANCED_SPELLBOOK (Options Panel above).

-- Page: Sections
L["SECTION_UNLEARNED"] = "Unlearned"
L["SECTION_CONSUMABLES"] = "GtG Consumables"

-- Page: WoW Macro Names. Each ends a macro's name, which WoW caps at 16 bytes in all; the spell name is cut to make room.
-- a focus copy's ("Heal @F")
L["MACRO_NAME_FOCUS_SUFFIX"] = " @F"
-- a lower rank's own macro ("Fireball R3"); %s is the rank's number
L["MACRO_NAME_RANK_SUFFIX"] = " R%s"

-- Page: Macro Menu
L["MACRO_TEXT"] = "Macro Text"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_DYNAMIC_RANK"] = "Dynamic Rank"
L["MENU_DYNAMIC_RANK_NOTE"] = "Dynamic Rank, based on a friendly player's level, only updates out of combat."
L["MENU_CAST_AT_CURSOR"] = "Cast at Cursor"
L["MENU_TARGET_NEAREST_ENEMY"] = "Target Nearest Enemy"
L["MENU_TARGET_NEAREST_FRIEND"] = "Target Nearest Friend"
L["MENU_CAST_IF_SUMMONED"] = "Cast %s If Summoned"
L["MENU_NEVER_TURN_OFF"] = "Never Turn Off"
L["MENU_LEAVE_FORM_BEFORE"] = "Leave Form Before Casting"
L["MENU_RIGHT_CLICK_FOR"] = "Right-Click for %s"
-- the category menu's version of it, for spells with different group versions
L["MENU_RIGHT_CLICK_GROUP"] = "Right-Click for Group Version"
-- TRANSLATORS: the category menu's title; %s is the category's name ("Apply to All Heals").
L["MENU_CATEGORY_TITLE"] = "Apply to All %s"
L["MENU_ONCE_PER_COMBAT"] = "Cast Once per Combat"
L["MENU_ONCE_PER_TARGET"] = "Cast Once per Target"
L["MENU_HIDE_ERRORS"] = "Hide Errors"
L["MENU_MUTE_ERRORS"] = "Mute Errors"
L["MENU_SWITCH_TO"] = "Switch to %s"
L["MENU_START_AUTO_ATTACK"] = "Start Auto Attack"
L["MENU_STOP_ATTACK"] = "Stop Attack"
L["MENU_START_AUTO_SHOT"] = "Start Auto Shot"
L["MENU_START_PET_ATTACK"] = "Start Pet Attack"
L["MENU_START_WAND"] = "Start Wand"
L["MENU_STOP_CASTING"] = "Stop Casting"
L["MENU_STOP_CASTING_NOTE"] = "Use Stop Casting on spells that can't wait, like interrupts and dispels."
L["MENU_STOP_IF_CHANNELING"] = "Not While Channeling"
L["MENU_STOP_IF_STEALTHED"] = "Not While Stealthed"
L["MENU_DUPLICATE"] = "Duplicate"
L["MENU_DELETE"] = "Delete"
L["MENU_DELETE_USED_ONE"] = "Delete (Used on 1 Bar)"
L["MENU_DELETE_USED"] = "Delete (Used on %d Bars)"
L["MENU_DELETE_DESCRIPTION"] =
	"Deletes this macro from your macros, which takes it off your action bars, and resets all its options. Click or drag it on the page to make it again."
L["MENU_DELETE_COPY_DESCRIPTION"] =
	"Takes this copy off the page and deletes it from your macros, which takes it off your action bars."
L["MENU_DELETE_CONFIRM"] = "Delete %s? It comes off your action bars, and its options reset."
L["MENU_GROUP_RANK"] = "Rank"
L["MENU_GROUP_WHEN"] = "When"
L["MENU_GROUP_FIRST"] = "First"
L["MENU_GROUP_THEN"] = "Then"
L["MENU_GROUP_ERRORS"] = "Error Messages"
L["MENU_GROUP_GROUPED"] = "Grouped Spells"
L["MENU_GROUP_TARGET"] = "Target"
L["MENU_PRIORITY_1"] = "First Priority"
L["MENU_PRIORITY_2"] = "Second Priority"
L["MENU_PRIORITY_3"] = "Third Priority"
L["MENU_PRIORITY_DESCRIPTION"] =
	"Who the macro tries, in turn. Each is skipped when it can't take the spell, and when none can, it casts as the plain spell would."
L["MENU_UNIT_NONE"] = "None"
L["MENU_UNIT_NONE_DESCRIPTION"] = "Ends the list here."
L["MENU_UNIT_TARGET"] = "Target"
L["MENU_UNIT_TARGET_DESCRIPTION"] = "Casts on your target, when it can take the spell."
L["MENU_UNIT_SELF"] = "Self"
L["MENU_UNIT_SELF_DESCRIPTION"] = "Casts on you. You can always take it, so nothing after Self is ever tried."
L["MENU_UNIT_PET"] = "Pet"
L["MENU_UNIT_PET_DESCRIPTION"] = "Casts on your pet, when it's out and can take the spell."
L["MENU_UNIT_FOCUS"] = "Focus"
L["MENU_UNIT_FOCUS_DESCRIPTION"] = "Casts on your focus, when you have one and it can take the spell."
L["MENU_UNIT_TARGETS_TARGET"] = "Target of Target"
L["MENU_UNIT_TARGETS_TARGET_DESCRIPTION"] =
	"Casts on your target's target, like the tank the enemy you're targeting is hitting, when it can take the spell."
L["MENU_UNIT_MOUSEOVER"] = "Mouseover"
L["MENU_UNIT_MOUSEOVER_DESCRIPTION"] =
	"Casts on whoever is under your cursor, in the world or on a unit frame, when they can take the spell."
L["MENU_OPTIONS_COUNT"] = "%d Options"
L["MENU_ENABLED"] = "Enabled"
L["MENU_HIGHEST"] = "Highest"
L["MENU_HIGHEST_DESCRIPTION"] = "Casts the highest rank you know."
L["MENU_RANK_DYNAMIC"] = "Dynamic Rank"
L["MENU_FIXED_RANK_DESCRIPTION"] = "Always casts %s, at any level."
L["MENU_ANY_TIME"] = "Any Time"
L["MENU_ANY_TIME_DESCRIPTION"] = "Casts in or out of combat."
L["MENU_IN_COMBAT"] = "In Combat"
L["MENU_IN_COMBAT_DESCRIPTION"] = "Casts only in combat. Out of combat the macro does nothing, its items included."
L["MENU_OUT_OF_COMBAT_DESCRIPTION"] = "Casts only out of combat. In combat the macro does nothing, its items included."
L["MENU_EVERY_PRESS"] = "Every Press"
L["MENU_EVERY_PRESS_DESCRIPTION"] = "Casts every time you press it."
L["MENU_GROUP_VERSION_DESCRIPTION"] = "A Right-Click casts %s. A Left-Click still casts %s."
L["MENU_GROUPED_SPELL_DESCRIPTION"] =
	"Lets the macro cast %s. Of the spells checked here, it casts the one you learned last, so it moves up as you train."
L["MENU_GROUPED_SPELL_NOT_LEARNED"] = "Not learned yet. Check it now and the macro takes it up once you learn it."
L["MENU_PET_DESCRIPTION"] = "While your %s is out, the macro casts %s instead of summoning it again."
L["MENU_STANCE_DESCRIPTION"] = "Switches to %s first, unless you're in it already."
L["MENU_USE_ITEM_DESCRIPTION"] =
	"Uses it before the cast. Items go in the order you check them, and the number after each shows its place."
-- an equipped item with a Use effect, in the First menu and the tooltip ("Use Trinket 1: Burst of Knowledge")
L["MENU_USE_SLOT"] = "Use %s"
L["MENU_ADD_FOCUS"] = "Add Focus Copy"
L["MENU_REMOVE_FOCUS"] = "Remove Focus Copy"
L["MENU_FOCUS_DESCRIPTION"] = "Adds a second macro to the page that casts on your focus, then your target."
L["MENU_REMOVE_FOCUS_DESCRIPTION"] = "Takes the focus copy off the page and deletes its macro."
L["MENU_DUPLICATE_DESCRIPTION"] =
	"Adds another copy of this macro to the page, starting with these options, so you can set it up differently."
L["MENU_MAKE_DEFAULT"] = "Make Default for %s"
L["MENU_MAKE_DEFAULT_DESCRIPTION"] =
	"Every macro under %s that you haven't set yourself starts with this macro's options."
L["MENU_DEFAULT_SET"] = "%s now start with these options."

-- Page: Conditionals
L["MENU_GROUP_CONDITIONALS"] = "Conditionals"
L["MENU_CONDITIONALS_DESCRIPTION"] =
	"Opens the Conditionals panel beside the Enhanced Spellbook window, where the macro can cast a different spell when a condition matches, like Shift held or Spec 2."
L["MENU_RIGHT_CLICK_TAKEN"] = "A Conditional uses Right-Click. Remove it to turn this on."
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Fireball // Conditionals").
L["CONDITIONALS_TITLE"] = "Conditionals"
L["CONDITIONALS_HINT"] = "Checked top to bottom; the first that matches casts."
L["CONDITIONALS_OTHERWISE"] = "Otherwise"
-- TRANSLATORS: joins a row's two conditions ("Spec 2 and Alt Held").
L["CONDITIONALS_AND"] = "and"
L["CONDITIONALS_AND_MENU"] = "Add Second Condition"
L["CONDITIONALS_AND_DESCRIPTION"] = "Adds a second condition. The row casts only when both match."
L["CONDITIONALS_DROP_SECOND"] = "Remove This Condition"
L["CONDITIONALS_DROP_SECOND_DESCRIPTION"] = "The row checks its first condition alone again."
L["CONDITIONALS_ADD"] = "+ Add Condition"
L["CONDITIONALS_ADD_DESCRIPTION"] = "Adds a row at the bottom. Pick its condition, then the spell it casts."
L["CONDITIONALS_ADD_LIMIT"] = "Up to %d rows. Each one adds to the macro text, which holds 255 bytes."
L["CONDITIONALS_PICK_SPELL"] = "Pick a Spell"
L["CONDITIONALS_PICKING"] = "Click a Spell on the Page"
L["CONDITIONALS_SLOT_DESCRIPTION"] =
	"Click here, then click a spell on the page to cast it in this row. Or drag a spell from the page onto this slot."
L["CONDITIONALS_PICK_BANNER"] = "Click a spell to use it. Esc or Right-Click cancels."
L["CONDITIONALS_CANNOT_PICK"] = "Only a learned spell can be cast by a conditional."
L["CONDITIONALS_EMPTY"] = "No conditions yet. Add one to cast another spell while Shift is held, in combat, and more."
L["CONDITIONALS_SHADOWED"] = "Never casts: row %d above matches whenever this one does, and casts first."
L["CONDITIONALS_KEY_DRAG"] = "Drag a Spell Here"
L["CONDITIONALS_ACTION_DROP"] = "Cast It in This Row"
L["CONDITIONALS_ACTION_PICK"] = "Pick From the Page"
L["CONDITIONALS_ACTION_USE"] = "Use in Conditional"
L["CONDITIONALS_ACTION_CANCEL"] = "Cancel Picking"
L["CONDITIONALS_REMOVE"] = "Remove"
L["CONDITIONALS_REMOVE_DESCRIPTION"] = "Removes this row."
L["CONDITIONALS_REORDER"] = "Reorder"
L["CONDITIONALS_REORDER_DESCRIPTION"] =
	"Drag onto another row to move this one there. The first row that matches casts."
-- TRANSLATORS: a row in short, for the macro menu's value and the spell's tooltip ("Shift: Frost Nova").
L["CONDITIONALS_SUMMARY"] = "%s: %s"
-- TRANSLATORS: a row's two conditions in short ("Spec 2 + Alt").
L["CONDITIONALS_JOIN"] = "%s + %s"
L["CONDITION_SHIFT"] = "Shift Held"
L["CONDITION_SHIFT_SHORT"] = "Shift"
L["CONDITION_SHIFT_DESCRIPTION"] = "Matches while you hold Shift as you press the macro."
L["CONDITION_CTRL"] = "Ctrl Held"
L["CONDITION_CTRL_SHORT"] = "Ctrl"
L["CONDITION_CTRL_DESCRIPTION"] = "Matches while you hold Ctrl as you press the macro."
L["CONDITION_ALT"] = "Alt Held"
L["CONDITION_ALT_SHORT"] = "Alt"
L["CONDITION_ALT_DESCRIPTION"] = "Matches while you hold Alt as you press the macro."
L["CONDITION_RIGHT_CLICK"] = "Right-Click"
L["CONDITION_RIGHT_CLICK_DESCRIPTION"] = "Matches when you Right-Click the macro on your action bar."
L["CONDITION_IN_COMBAT"] = "In Combat"
L["CONDITION_IN_COMBAT_DESCRIPTION"] = "Matches while you're in combat."
L["CONDITION_OUT_OF_COMBAT"] = "Out of Combat"
L["CONDITION_OUT_OF_COMBAT_DESCRIPTION"] = "Matches while you're out of combat."
L["CONDITION_SPEC_1"] = "Spec 1"
L["CONDITION_SPEC_1_DESCRIPTION"] = "Matches while your first talent spec is active."
L["CONDITION_SPEC_2"] = "Spec 2"
L["CONDITION_SPEC_2_DESCRIPTION"] = "Matches while your second talent spec is active."
-- TRANSLATORS: %s is "Spec 1" or "Spec 2", marking the talent spec active now in a condition's menu.
L["CONDITION_SPEC_CURRENT"] = "%s (Current)"
L["CONDITION_COMBAT_BLOCKED"] =
	"Not available while When is set to In Combat or Out of Combat. The macro already does nothing on the other side, so this would always match, or never."
L["CONDITION_RIGHT_CLICK_BLOCKED"] =
	"Not available while Grouped Spells has Right-Click for %s on, which already takes the Right-Click. Turn that off to use Right-Click here."
L["SUBTEXT_CONDITIONALS_ONE"] = "1 Conditional"
L["SUBTEXT_CONDITIONALS"] = "%d Conditionals"

-- Page: Cast Sequence
L["MENU_GROUP_CAST_SEQUENCE"] = "Cast Sequence"
L["MENU_CAST_SEQUENCE_DESCRIPTION"] =
	"Opens the Cast Sequence panel beside the Enhanced Spellbook window, where each press of the macro casts the next spell in order, like Corruption, then Curse of Agony, then Immolate."
-- TRANSLATORS: how many spells a Cast Sequence casts in turn, the macro's own included ("3 Steps").
L["MENU_CAST_SEQUENCE_STEPS"] = "%d Steps"
-- TRANSLATORS: the panel's title after the spell's name and "//" ("Corruption // Cast Sequence").
L["CAST_SEQUENCE_TITLE"] = "Cast Sequence"
L["CAST_SEQUENCE_HINT"] = "Each press casts the next step. A step that fails is tried again on the next press."
L["CAST_SEQUENCE_FIRST"] = "First"
L["CAST_SEQUENCE_FIRST_DESCRIPTION"] = "The macro's own spell always comes first."
L["CAST_SEQUENCE_ADD"] = "+ Add Step"
L["CAST_SEQUENCE_ADD_DESCRIPTION"] = "Adds a step at the end. Then pick the spell it casts."
L["CAST_SEQUENCE_ADD_LIMIT"] =
	"Up to %d steps after the macro's own. Each one adds to the macro text, which holds 255 bytes."
L["CAST_SEQUENCE_CANNOT_PICK"] = "Only a learned spell, and not Shoot, can be a step in a cast sequence."
L["CAST_SEQUENCE_ACTION_DROP"] = "Cast It in This Step"
L["CAST_SEQUENCE_ACTION_USE"] = "Use in Cast Sequence"
L["CAST_SEQUENCE_REMOVE_DESCRIPTION"] = "Removes this step."
L["CAST_SEQUENCE_REORDER_DESCRIPTION"] = "Drag onto another step to move this one there."
L["CAST_SEQUENCE_END"] = "After the Last Step"
L["CAST_SEQUENCE_END_LOOP"] = "Start Over"
L["CAST_SEQUENCE_END_LOOP_DESCRIPTION"] =
	"The next press casts the macro's own spell again, and the sequence goes around."
L["CAST_SEQUENCE_END_STOP"] = "Stop (NULL)"
L["CAST_SEQUENCE_END_STOP_DESCRIPTION"] =
	"Ends on NULL, a spell no one knows, so more presses cast nothing until a reset starts the sequence over."
L["CAST_SEQUENCE_END_STOP_SHORT"] = "Stop"
L["CAST_SEQUENCE_RESET"] = "Start Over When"
L["CAST_SEQUENCE_RESET_NEVER"] = "Never"
L["CAST_SEQUENCE_RESET_TARGET"] = "Target Changes"
L["CAST_SEQUENCE_RESET_TARGET_DESCRIPTION"] = "Starts the sequence over at its first step when you change targets."
L["CAST_SEQUENCE_RESET_COMBAT"] = "Combat Ends"
L["CAST_SEQUENCE_RESET_COMBAT_DESCRIPTION"] = "Starts the sequence over at its first step when you leave combat."
L["CAST_SEQUENCE_RESET_SHIFT"] = "Shift Held"
L["CAST_SEQUENCE_RESET_CTRL"] = "Ctrl Held"
L["CAST_SEQUENCE_RESET_ALT"] = "Alt Held"
L["CAST_SEQUENCE_RESET_MODIFIER_DESCRIPTION"] =
	"Pressing the macro with this key held starts the sequence over, casting its first step."
L["CAST_SEQUENCE_RESET_SECONDS_MENU"] = "Seconds Idle"
L["CAST_SEQUENCE_RESET_SECONDS_MENU_DESCRIPTION"] =
	"Starts the sequence over when the macro hasn't been pressed for this long."
L["CAST_SEQUENCE_RESET_SECONDS_OFF"] = "Off"
-- TRANSLATORS: a Cast Sequence reset after this many seconds without a press ("5 Seconds Idle").
L["CAST_SEQUENCE_RESET_SECONDS"] = "%d Seconds Idle"
L["CAST_SEQUENCE_STOP_NO_RESET"] =
	"Stops for good: with nothing to start it over, the sequence stays on NULL until the macro changes or you reload your UI. Pick a reset under Start Over When."
L["CAST_SEQUENCE_PET_BLOCKED"] =
	"Waits while Cast If Summoned casts %s, which writes a cast line of its own. Turn that off to use the sequence."
L["CAST_SEQUENCE_SLOT_DESCRIPTION"] =
	"Click here, then click a spell on the page to cast it in this step. Or drag a spell from the page onto this slot."
-- TRANSLATORS: the spell's note on the page, counting the spells its Cast Sequence casts in turn ("3-Step Sequence").
L["SUBTEXT_CAST_SEQUENCE"] = "%d-Step Sequence"

-- Page: Settings Menu
L["SETTINGS_SHOW_ALL_RANKS"] = "Show All Spell Ranks"
L["SETTINGS_SHOW_GROUPED_SPELLS"] = "Show Grouped Spells"
L["SETTINGS_SHOW_UNLEARNED"] = "Show Unlearned Spells"
L["SETTINGS_MARK_ALL_PLACED"] = "Mark All Spells as Placed"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Stops every macro on this page glowing, whether or not it's on your bars. A spell you learn later still glows until you place it."
L["SETTINGS_HIGHLIGHT_UNPLACED"] = "Highlight Unplaced Spells"
L["SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"] =
	"Makes every macro that isn't on your bars glow. Turn it off to mark them all placed, like the Mark All Spells as Placed button."
L["SORT_BY_CATEGORY"] = "Sort by Category"
L["SORT_BY_SCHOOL"] = "Sort by School"
L["SORT_DESCRIPTION"] =
	"Groups the page's macros by category, what each spell is for, like Attacks, Heals, or Defensive Cooldowns, or by school, the spellbook tabs they come from."
L["CATEGORY_ATTACKS"] = "Attacks"
L["CATEGORY_FINISHERS"] = "Finishing Moves"
L["CATEGORY_CROWD_CONTROL"] = "Crowd Control"
L["CATEGORY_HYBRID"] = "Hybrid"
L["CATEGORY_HEALS"] = "Heals"
L["CATEGORY_BUFFS"] = "Buffs"
L["CATEGORY_OFFENSIVE_COOLDOWNS"] = "Offensive Cooldowns"
L["CATEGORY_DEFENSIVE_COOLDOWNS"] = "Defensive Cooldowns"
L["CATEGORY_SELF_BUFFS"] = "Self-Buffs"
L["CATEGORY_SHOCKS"] = "Shocks"
L["CATEGORY_TRAPS"] = "Traps"
L["CATEGORY_TOTEMS"] = "Totems"
L["CATEGORY_SEALS"] = "Seals"
L["CATEGORY_BLESSINGS"] = "Blessings"
L["CATEGORY_CURSES"] = "Curses"
L["CATEGORY_PETS"] = "Pets"
L["CATEGORY_TELEPORTS"] = "Teleports and Portals"
L["CATEGORY_UTILITY"] = "Utility"
L["CATEGORY_THREAT"] = "Taunts and Threat"
L["SUBCATEGORY_BASIC_ATTACKS"] = "Basic Attacks"
L["CATEGORY_STANCES"] = "Stances"
L["CATEGORY_FORMS"] = "Forms"
L["CATEGORY_AURAS"] = "Auras"
L["CATEGORY_ASPECTS"] = "Aspects"
L["CATEGORY_RACIALS"] = "Racials"
L["CATEGORY_TRACKING"] = "Tracking"
L["CATEGORY_PROFESSIONS"] = "Professions"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Focus"
L["SUBTEXT_PET"] = "Pet"
L["SUBTEXT_CURSOR"] = "Cursor"
L["SUBTEXT_STANCE"] = "Stance"
L["SUBTEXT_USE_ITEMS"] = "Use Items"
L["SUBTEXT_PET_ATTACK"] = "Pet Attack"
L["SUBTEXT_DYNAMIC_RANK"] = "Dynamic Rank"
L["SUBTEXT_DYNAMIC_ITEM"] = "Dynamic Item"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Dynamic Rank, Dynamic Item"
L["SUBTEXT_MAX_RANK"] = "Max Rank"
L["SUBTEXT_TARGET_ENEMY"] = "Nearest Enemy"
L["SUBTEXT_TARGET_FRIEND"] = "Nearest Friend"
L["SUBTEXT_TARGET_PRIORITY"] = "Target"
L["SUBTEXT_GROUPED_SPELLS"] = "Grouped"
L["SUBTEXT_ONCE_PER_COMBAT"] = "Once per Combat"
L["SUBTEXT_ONCE_PER_TARGET"] = "Once per Target"
L["SUBTEXT_COMBAT_ONLY"] = "Combat Only"
L["SUBTEXT_NO_COMBAT"] = "Out of Combat"
L["SUBTEXT_LEAVE_FORM"] = "Leave Form"
L["SUBTEXT_NO_TOGGLE"] = "Never Turn Off"
L["SUBTEXT_WAND"] = "Wand"
L["SUBTEXT_START_ATTACK"] = "Auto Attack"
L["SUBTEXT_STOP_ATTACK"] = "Stop Attack"
L["SUBTEXT_STOP_CASTING"] = "Stop Casting"
L["SUBTEXT_STOP_IF_CHANNELING"] = "Not While Channeling"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Not While Stealthed"
L["SUBTEXT_HIDE_ERRORS"] = "Hide Errors"
L["SUBTEXT_MUTE_ERRORS"] = "Mute Errors"
L["SUBTEXT_OPTIONS_COUNT"] = "%d Options"
L["SUBTEXT_TOO_LONG"] = "Too Long"
L["SUBTEXT_LEARN_LEVEL"] = "Level %d"
L["SUBTEXT_TALENT"] = "Talent"
L["SUBTEXT_LEARN_RANK"] = "Learn %s"
L["SUBTEXT_SOURCE_LEVEL"] = "%s, %s"
L["SUBTEXT_TEACH_PET"] = "Teach Pet"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Not Learned Yet"
L["TOOLTIP_LEARN_LEVEL"] = "Your class trainer teaches it at level %d."
L["TOOLTIP_LEARN_TALENT"] = "Learned from your talents."
L["TOOLTIP_NOT_ON_BARS"] = "Not on Your Action Bars"
L["TOOLTIP_TOO_LONG"] = "Too long: %d / %d bytes. Turn an option off to shorten it."
L["TOOLTIP_OPTIONS_ON"] = "Options On: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Click or Drag"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Place on Your Action Bars"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Right-Click"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Macro Options"
L["TOOLTIP_KEY_MIDDLE_CLICK"] = "Middle-Click"
L["TOOLTIP_ACTION_RESET_OPTIONS"] = "Reset Macro Options"
L["TOOLTIP_ACTION_RESET_CATEGORY"] = "Reset All Macros in %s"
L["CHAT_MACRO_OPTIONS_RESET"] = "%s is back to its default options."
L["CHAT_CATEGORY_OPTIONS_RESET"] = "Every macro in %s is back to its default options."
L["MENU_RESET_CATEGORY_DESCRIPTION"] =
	"Drops the options you set on each spell here, so every one follows its defaults again. Focus copies and Duplicates stay."
L["MENU_RESET_CATEGORY_CONFIRM"] =
	"Reset the options you set on every spell in %s? Each one follows its defaults again."

-- TRANSLATORS: %s is a spell's name, heading its macro's part of a tile's tooltip after "GtG //" ("Immolate Macro").
L["TOOLTIP_MACRO_HEADING"] = "%s Macro"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Your class's spells as one-click macros."
L["TOOLTIP_KEY_CLICK"] = "Click"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Open Enhanced Spellbook"

-- Page: Layout
L["PAGE_EMPTY"] = "No macros yet. Visit your class trainer to learn your first spells."
L["PAGE_NO_MATCHES"] = "No macros match the filter."
L["PAGE_FILTER"] = "Filter Spells"
L["FILTER_ALL_SCHOOLS"] = "All Schools"
L["FILTER_ALL_CATEGORIES"] = "All Categories"
L["PAGE_MACRO_SLOTS"] = "Macro Slots"
L["TOOLTIP_MACRO_SLOTS"] =
	"Each macro you place takes a macro slot. Character slots belong to this character and fill first. General slots are shared by every character on your account."
L["PAGE_MACRO_GENERAL"] = "General"
L["PAGE_MACRO_CHARACTER"] = "Character"
L["PAGE_NO_MATCHES_FOR"] = 'No spells match "%s".'
-- TRANSLATORS: %d is how many spells the category lists, %s its name ("Options for All 6 Heals").
L["PAGE_CATEGORY_SETTINGS"] = "Options for All %d %s"
L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"] =
	"Turns an option on or off for every spell in this category at once. Spells not on your bars yet keep the setting for when you place them."
-- after a category's count, where it carries on from the column before
L["PAGE_CONTINUED"] = "(Continued)"

-- What's Next? Tab: the window's second tab and its title before "// Good to Go"
L["WHATS_NEXT_TITLE"] = "What's Next?"
L["WHATS_NEXT_EMPTY"] = "No spells to list."
L["WHATS_NEXT_ALL_SOURCES"] = "All Sources"
L["WHATS_NEXT_ANY_LEVEL"] = "Any Level"
-- TRANSLATORS: %s is a spell's rank or "Passive", after its name ("Rend (Rank 2)").
L["WHATS_NEXT_SUBTEXT"] = "(%s)"

-- TRANSLATORS: printed on a level-up; %s is the spells the character can learn now, joined with
-- LEVEL_UP_SPELLS_PAIR_FORMAT or LEVEL_UP_SPELLS_LAST_FORMAT ("[Bash], [Moonfire] (Rank 3), & [Rejuvenation]").
L["LEVEL_UP_SPELLS"] = "You can now learn %s."
-- printed under it: %s is the spells from earlier levels still not learned, joined the same way
L["LEVEL_UP_SPELLS_NOT_LEARNED"] = "Don't forget, you can also learn %s."
-- the same two for a hunter's pet, and a warlock's grimoires (the first only)
L["LEVEL_UP_PET_SPELLS"] = "Your pet can now learn %s."
L["LEVEL_UP_PET_SPELLS_NOT_LEARNED"] = "Don't forget, your pet can also learn %s."
L["LEVEL_UP_DEMON_SPELLS"] = "Your demons can now learn %s."
L["LEVEL_UP_SPELLS_PAIR_FORMAT"] = "%s & %s"
L["LEVEL_UP_SPELLS_LAST_FORMAT"] = "%s, & %s"

-- What's Next? Tab: section headers, and the counts in the footer
L["WHATS_NEXT_STATUS_AVAILABLE"] = "Available Now"
L["WHATS_NEXT_STATUS_SOON"] = "Coming Soon"
L["WHATS_NEXT_STATUS_LATER"] = "Not Yet Available"
L["WHATS_NEXT_STATUS_MISSING"] = "Missing Requirements"
L["WHATS_NEXT_STATUS_TALENT"] = "Talents Not Taken"
L["WHATS_NEXT_STATUS_TALENT_RUNE"] = "Talents and Runes Not Taken"
L["WHATS_NEXT_STATUS_KNOWN"] = "Known"

-- What's Next? Tab: each row's status at its right under Sort by Level
L["WHATS_NEXT_SHORT_AVAILABLE"] = "Available Now"
L["WHATS_NEXT_SHORT_SOON"] = "Coming Soon"
L["WHATS_NEXT_SHORT_LATER"] = "Not Yet"
L["WHATS_NEXT_SHORT_MISSING"] = "Needs Another Spell"
L["WHATS_NEXT_SHORT_TALENT"] = "Not Taken"
L["WHATS_NEXT_SHORT_KNOWN"] = "Known"

-- What's Next? Tab: where a spell is learned
L["WHATS_NEXT_SOURCE_START"] = "Starting Spell"
L["WHATS_NEXT_SOURCE_TRAINER"] = "Trainer"
L["WHATS_NEXT_SOURCE_BOOK"] = "Book"
L["WHATS_NEXT_SOURCE_QUEST"] = "Quest"
L["WHATS_NEXT_SOURCE_TALENT"] = "Talent"
L["WHATS_NEXT_SOURCE_RUNE"] = "Rune"

-- What's Next? Tab: a row's tooltip, under the spell's own
L["WHATS_NEXT_TOOLTIP_SOURCE"] = "Learned From"
L["WHATS_NEXT_TOOLTIP_LEVEL"] = "Required Level"
L["WHATS_NEXT_TOOLTIP_HOW_START"] = "Your class starts with it."
L["WHATS_NEXT_TOOLTIP_HOW_TRAINER"] = "Your class trainer teaches it."
L["WHATS_NEXT_TOOLTIP_HOW_BOOK"] = "An item teaches it, such as a book from a dungeon or raid."
L["WHATS_NEXT_TOOLTIP_HOW_QUEST"] = "A class quest teaches it. Your class trainer can point you to it."
L["WHATS_NEXT_TOOLTIP_HOW_TALENT"] = "Spend a talent point on it to learn it."
L["WHATS_NEXT_TOOLTIP_HOW_RUNE"] = "Engrave its rune to learn it."
-- TRANSLATORS: %s is a spell's name, with its rank where it has one ("Learn Rend (Rank 1) first.").
L["WHATS_NEXT_TOOLTIP_NEEDS"] = "Learn %s first."
-- TRANSLATORS: %s is a spell's name, heading the list of its ranks after "GtG //" ("Immolate Ranks").
L["WHATS_NEXT_TOOLTIP_RANKS"] = "%s Ranks"
L["TOOLTIP_KEY_SHIFT_CLICK"] = "Shift + Click"
L["TOOLTIP_ACTION_LINK_IN_CHAT"] = "Link in Chat"

-- What's Next? Tab: the sort dropdown and the settings menu
L["WHATS_NEXT_SORT_AVAILABILITY"] = "Sort by Availability"
L["WHATS_NEXT_SORT_LEVEL"] = "Sort by Level"
L["WHATS_NEXT_SORT_DESCRIPTION"] =
	"Sort by Availability lists the spells you can learn now first and the ones you know last. Sort by Level lists every spell under the level it's learned at."
L["WHATS_NEXT_SHOW_KNOWN"] = "Show Known Spells"
L["WHATS_NEXT_SHOW_KNOWN_DESCRIPTION"] = "Also lists the spells you've already learned, after the rest."
L["WHATS_NEXT_SHOW_TALENTS"] = "Show Talents Not Taken"
L["WHATS_NEXT_SHOW_TALENTS_RUNES"] = "Show Talents and Runes Not Taken"
L["WHATS_NEXT_SHOW_TALENTS_DESCRIPTION"] =
	"Also lists the talent spells you haven't taken. You learn those by spending talent points, not from a trainer."

-- Pet Spellbook Tab: a pet class's third tab and its title before "// Good to Go"
L["PET_SPELLBOOK_TITLE"] = "Pet Spellbook"
L["PET_SPELLBOOK_EMPTY"] = "Your pet has no spells to list."
L["PET_SPELLBOOK_NO_PET"] = "No pet out. Summon your pet to see its spells."
-- its section headers
L["PET_SPELLBOOK_STATUS_ABILITY"] = "Abilities"
L["PET_SPELLBOOK_STATUS_PASSIVE"] = "Passive"
-- at an ability's right: whether the pet casts it on its own
L["PET_SPELLBOOK_AUTOCAST_ON"] = "Autocast On"
L["PET_SPELLBOOK_AUTOCAST_OFF"] = "Autocast Off"

-- Pet What's Next? Tab: a hunter's or warlock's fourth tab and its title before "// Good to Go"
L["WHATS_NEXT_PET_TITLE"] = "Pet What's Next?"
L["WHATS_NEXT_PET_EMPTY"] = "No pet abilities to list."
-- the footer's right: the pet out, or that there's none
-- TRANSLATORS: the first %s is the pet's name, %d its level, the second %s its family ("Fang, Level 23 Wolf").
L["WHATS_NEXT_PET_FOOTER"] = "%s, Level %d %s"
-- TRANSLATORS: the first %d is the training points the pet has left, the second its total.
L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"] = "Training Points: %d of %d"
L["WHATS_NEXT_PET_NO_PET"] = "No pet out: showing what you've learned with Beast Training."
L["WHATS_NEXT_PET_NO_DEMON"] = "No demon out: summon one to see what it already knows."

-- Pet What's Next? Tab: the pet's own section headers (the rest are the What's Next? tab's)
L["WHATS_NEXT_PET_STATUS_TEACH"] = "Ready to Teach"
L["WHATS_NEXT_PET_STATUS_OTHER"] = "Other Families' Abilities"
L["WHATS_NEXT_PET_SHORT_TEACH"] = "Ready to Teach"
L["WHATS_NEXT_PET_SHORT_OTHER"] = "Other Family"

-- Pet What's Next? Tab: where the hunter learns an ability
L["WHATS_NEXT_PET_SOURCE_TRAINER"] = "Pet Trainer"
L["WHATS_NEXT_PET_SOURCE_TAMING"] = "Taming"
L["WHATS_NEXT_PET_SOURCE_DEMON_TRAINER"] = "Demon Trainer"

-- Pet What's Next? Tab: a row's tooltip, under the ability's own
L["WHATS_NEXT_PET_TOOLTIP_LEVEL"] = "Required Pet Level"
L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"] = "Training Points"
L["WHATS_NEXT_PET_TOOLTIP_HOW_TRAINER"] =
	"A pet trainer teaches it to you. Then teach it to your pet with Beast Training."
L["WHATS_NEXT_PET_TOOLTIP_HOW_TAMING"] =
	"Tame a beast that knows it and fight alongside it until you learn it. Then teach it to any pet that can learn it with Beast Training."
L["WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"] = "You know it. Teach it to your pet with Beast Training."
L["WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER"] =
	"Buy its grimoire from a demon trainer, then use it while the demon that learns it is summoned."
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"] = "Grimoire"
L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS"] = "Its grimoire is in your bags. Use it while this demon is summoned."
L["WHATS_NEXT_PET_TOOLTIP_OTHER"] = "Your pet can't learn it."
L["WHATS_NEXT_PET_TOOLTIP_BEASTS"] = "Beasts That Know It"
-- TRANSLATORS: the first %s is a beast's name, the second its level or level range ("Forest Spider (5-6)").
L["WHATS_NEXT_PET_TOOLTIP_BEAST"] = "%s (%s)"
-- TRANSLATORS: %d is how many more beasts know the ability than the tooltip names.
L["WHATS_NEXT_PET_TOOLTIP_MORE"] = "And %d more."

-- Pet What's Next? Tab: the sort's tooltip and the settings menu
L["WHATS_NEXT_PET_SORT_DESCRIPTION"] =
	"Sort by Availability lists the abilities your pet can learn now first and the ones it knows last. Sort by Level lists every ability under the pet level it needs."
L["WHATS_NEXT_PET_SHOW_KNOWN"] = "Show Known Abilities"
L["WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION"] =
	"Also lists the abilities your pet already knows, after the rest. A Hunter with no pet out sees the ones they've learned."
L["WHATS_NEXT_PET_SHOW_OTHER"] = "Show Other Families' Abilities"
L["WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION"] =
	"Also lists the abilities your pet can't learn, such as a cat's Prowl for a wolf, or another demon's."

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Key Bindings"
L["OPTIONS_KEY_SET"] = "Set Key"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "Opens the game's key binding list, where Good to Go has its own section."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Opens and closes Enhanced Spellbook. It also has its own tab in your spellbook."
-- %s is the macro line that presses the same key, /click GtGBuffKey.
L["OPTIONS_KEY_BINDING_BUFF_DESCRIPTION"] =
	"Casts the next buff your Buff Duty window offers, one per press, out of combat. Weapon buffs stay a click on the window. To press it from a macro, use %s."
L["OPTIONS_ABILITY_TOOLTIPS_HEADER"] = "Spell Rank Tooltips"
L["OPTIONS_ABILITY_TOOLTIPS_DESCRIPTION"] =
	"Every ability's tooltip lists its ranks and the level each one needs: white for ranks you know, green for ranks you could train now, and gray for ranks still to come. It's a quick self-check that you're using your best rank, so you can always play at your best. The ranks don't show during combat, so your tooltips stay short when it counts."
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE"] = "Enable Spell Rank Tooltips"
L["OPTIONS_ABILITY_TOOLTIPS_ENABLE_DESCRIPTION"] =
	"Adds each ability's ranks to its tooltip on your action bars, in the game's spellbook, and in other add-ons. Off leaves those tooltips as the game shows them. Enhanced Spellbook's own window shows the ranks either way."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Delete Macros"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Deletes the macros Enhanced Spellbook made, which also takes them off your action bars. Your own macros are never touched, and the page makes any of them again when you click or drag it."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Delete Character Macros"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Deletes Enhanced Spellbook's macros from this character's macro tab. Your other characters keep theirs until you do the same on them."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Delete all of Enhanced Spellbook's macros on this character? They come off your action bars too."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Delete General Macros"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Deletes Enhanced Spellbook's macros from the General macro tab, which every character on your account shares, so your other characters lose theirs there too."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Delete all of Enhanced Spellbook's General macros? Every character on your account loses them, and they come off your action bars too."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_ALL_RANKS_DESCRIPTION"] =
	"Lists a macro for each lower rank you know of a spell, after the spell's own, each always casting its rank."
L["OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION"] =
	"Lists every spell you know of a spell group, like Purify and Cleanse. Left off, only the last one learned is listed, though the others' macros still update."
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Lists the class spells you haven't learned yet in an Unlearned section, so you can place their macros early."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Places the spell where your cursor points, with no targeting circle."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Casts the highest rank the friendly player's level can take."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] = "Stops whatever you're casting first, so this spell goes off at once."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Stops your melee auto attack first."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Does nothing while you're channeling a spell, so a press never breaks the channel."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Does nothing while you're stealthed, so a press never breaks Stealth or Prowl."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "Leaves your current form first, so the spell can be cast."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Targets the nearest enemy first when you have no living enemy targeted."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Targets the nearest friend first when you have no living friend targeted."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Sends your pet to attack your target too."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Starts your melee auto attack after the cast."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Starts Auto Shot or your wand after the cast."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Casts once, then not again until your target changes."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Casts once, then not again until combat ends or your target changes."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Keeps the form or aspect on when you press the macro again, instead of turning it off."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Clears the red error text the macro leaves on screen."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Mutes the error sound while the macro runs."
L["KIND_ENEMY"] = "Enemy Spells"
L["KIND_ENEMY_DESCRIPTION"] = "Spells you cast on an enemy, like your attacks and debuffs."
L["KIND_FRIENDLY"] = "Friendly Spells"
L["KIND_FRIENDLY_DESCRIPTION"] = "Spells you cast on a friend, like your heals."
L["KIND_BUFF"] = "Buffs"
L["KIND_BUFF_DESCRIPTION"] = "Spells that give a friend a lasting buff."
L["KIND_RESURRECT"] = "Resurrections"
L["KIND_RESURRECT_DESCRIPTION"] = "Spells you cast on a dead friend to bring them back."
L["KIND_ANYONE"] = "Friend or Foe Spells"
L["KIND_ANYONE_DESCRIPTION"] = "Spells you can cast on a friend or an enemy."
L["KIND_GROUND"] = "Ground-Targeted Spells"
L["KIND_GROUND_DESCRIPTION"] = "Spells you place on the ground."
L["KIND_FORM"] = "Forms, Stances, and Aspects"
L["KIND_FORM_DESCRIPTION"] = "Spells that stay on until you turn them off or switch to another."
L["KIND_SELF"] = "Self and Area Spells"
L["KIND_SELF_DESCRIPTION"] = "Spells with no target, cast on yourself or around you."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Toggle Enhanced Spellbook"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "As a safety precaution, the key binding list cannot be opened during combat."
L["KEY_BINDINGS_LOCATION"] = "Open the game menu, then %s, then %s, and find the Good to Go section."
L["ERROR_MACRO_SLOTS_FULL"] = "No free macro slots. Delete a macro in /macro to make room."
L["ERROR_MACRO_WINDOW_OPEN"] = "Close the Macros window first."
L["CHAT_MACROS_DELETED"] = "Macros deleted: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'The "%s" macro is %d bytes with its options on, over the %d a macro holds. Turn an option off to shorten it.'
L["CHAT_CONSUMABLE_MACRO_TOO_LONG"] =
	'The "%s" macro is %d bytes, over the %d a macro holds, so its last line is cut off.'
