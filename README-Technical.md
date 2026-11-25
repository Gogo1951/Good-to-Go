# Good to Go // Technical Reference

> Code map for working on Good to Go: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/Good-to-Go/blob/main/README.md).

## File Map

```
Good-to-Go/
├── .gitattributes                                  Shared from Common-Core: LF everywhere, binary art
├── .github/                                        Issue forms and the Common-Core callers
│   ├── ISSUE_TEMPLATE/                             New-issue page
│   │   ├── config.yml                              Kept per add-on: blank-issue, Discord and CurseForge links; CI never checks it
│   │   ├── defect.yml                              Shared from Common-Core: the Defect form
│   │   └── request.yml                             Shared from Common-Core: the Request form
│   └── workflows/                                  Common-Core workflow callers, copied unchanged; CI fails on drift
│       ├── ci.yml                                  Calls Common-Core: shared files, LF, externals, luac, luacheck, StyLua, Tests/Run.lua
│       ├── issue-labels.yml                        Calls Common-Core: fills a new issue's missing Area, Priority or Type label
│       └── package.yml                             Calls Common-Core: a tag push releases to CurseForge and Wago; a manual run is a dry run
├── .gitignore                                      Shared from Common-Core
├── .luacheckrc                                     Lint config: lua51, WoW read globals, the add-on's own globals, slash commands, popups; Includes/ excluded
├── .pkgmeta                                        Library externals; ignore list keeps dotfiles, LICENSE, READMEs, Tests, Tools, Data/Wrath, Data/Mainline out of the zip
├── Bindings.xml                                    Spellbook toggle, Buff Key CLICK binding, hidden MIGRATION binding; loaded by the client, in no TOC
├── Data/                                           Static game data and ID-free constants
│   ├── Camelot/                                    WoW Forever's tables
│   ├── Data.lua                                    Saved-variables names, ns.REPLACED_ADDONS and MIGRATION ns.LEGACY_ADDONS, palette and class colors, sample names, links, chat and macro ceilings, target marker, ns.OPTIONS_REGISTRY, group contexts and level filters, constants for every feature (ns.Data)
│   ├── Default-Settings.lua                        The ns.DATABASE_DEFAULTS table with each global key's scope reason; AddDefaults blocks for the Spellbook, Buff Duty, Rank Watch and messageLanguage; class-built scrollTypes defaults
│   ├── Discovery/                                  Season of Discovery's tables; each file returns early unless ns.IS_DISCOVERY
│   ├── Flavor.lua                                  Flavor from the TOC: ns.FLAVOR, ns.EXPANSION, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── LICENSE-Pet-Data                            MIT notice for the pet ability and tameable beast rows
│   ├── LICENSE-Trainer-Data                        MIT notice for the trainer spell rows
│   ├── Mainline/                                   Forward-prep; no TOC lists it, .pkgmeta ignores it
│   ├── Message-Languages.lua                       Send Messages In: Data.MESSAGE_LANGUAGES (every editable whisper's default per locale), Data.EDITABLE_MESSAGES (where each saved text lives), the get/set/language-switch accessors
│   ├── Mists/                                      Mists of Pandaria Classic's tables
│   ├── TBC/                                        TBC Anniversary's tables
│   ├── Vanilla/                                    Classic Era's tables; each file returns early on Season of Discovery
│   └── Wrath/                                      Forward-prep; no TOC lists it, .pkgmeta ignores it
├── Diagnostics/                                    Copied framework; this add-on's part is Manifests.lua, the Manifests-<Feature>.lua rows and the Message-Length-<Feature>.lua builders
├── Features/                                       One folder per feature; Core.lua owns the event frame
│   ├── Announcements.lua                           Prints and WarnOnce; sent-line sign-off, the one Send, whisper queue; group buff ask; editable-whisper fill/build pairs; group chat channel; Send Test to Me
│   ├── Buff-Duty/                                  Click-to-cast window of buffs you can give, its category and Options menus, and the Buff Key
│   │   ├── Buff-Duty-Asks.lua                      Ask Your Target for Buffs: the Target's Ask row, the per-player ask cooldown, the whisper
│   │   ├── Buff-Duty-Auras.lua                     GUID aura cache, dirty set and generation, strengths, durations, bounce memory, Has, Carries
│   │   ├── Buff-Duty-Button-Attributes.lua         The one attribute writer, ns.SetBuffButtonAttributes, shared by the window and the Buff Key; self consumables used by item name; asks and PvP holds clear it
│   │   ├── Buff-Duty-Cast-Results.lua              Cast attempts, aura-bounced and pet refusals, pet and NPC cast follow-through, the Forever resurrection note
│   │   ├── Buff-Duty-Castable.lua                  Creates ns.BuffDuty and its shared tables; BuildBuffs, CastText, KnownRanks, RankFor, HasAnythingToOffer
│   │   ├── Buff-Duty-Elixirs.lua                   Flasks or Elixirs section: carried elixirs by ns.ELIXIR_BUFF_IDS slot or group, elixirOff, its Missing Inventory test
│   │   ├── Buff-Duty-Events.lua                    Event module, handler table, subscriptions, UNIT_FLAGS PvP watch, combat-log sync, safety pause; loads first
│   │   ├── Buff-Duty-Favors.lua                    Return the Favor memory; combat-log and Forever aura detection
│   │   ├── Buff-Duty-Frame.lua                     Anchor and content frames, render and hide, kit window header and Options line, cast-order packing, Hide in Combat, key tip, Window Opacity on the plate
│   │   ├── Buff-Duty-Groups.lua                    Party sections, group icons, member and pet rows, raid group folding
│   │   ├── Buff-Duty-Icon-State.lua                Creates the icon pool; cooldown and ask-wait swipes, time-left sliver, range fade, stale dim
│   │   ├── Buff-Duty-Icons.lua                     Secure list icons: acquire from the pool, tooltip, ask mark, PreClick and PostClick
│   │   ├── Buff-Duty-Key-Picker.lua                What the Buff Key casts next: candidates, readiness, GCD, mana, reach, PvP pass-over; GroupChoices, CastOrder
│   │   ├── Buff-Duty-Keys.lua                      GtGBuffKey button, Busy check, targeting who it casts on, skip memory, press reuse, binding migration
│   │   ├── Buff-Duty-Layout.lua                    Redraw signature, held layout, icon grids, packed lines, category arrows and name buttons, Missing Inventory, fold buttons, line placing
│   │   ├── Buff-Duty-Lookups.lua                   Data rows to live entries (Well Fed, Scrolls and Elixirs entries included), weapon layers, BuildCategories
│   │   ├── Buff-Duty-NPCs.lua                      Targeted friendly NPC row and its buff cycle
│   │   ├── Buff-Duty-Options-Menu.lua              One Menu Kit menu for the window's lines: Options, each category's menu, When to Use and Show, Your Target, Window Opacity with hover preview; ns.SCROLL_TYPE_LABELS; shared with the mini-map menu
│   │   ├── Buff-Duty-Other-Classes.lua             Party-Buffs counts, ask cooldowns, group ask and class whisper senders
│   │   ├── Buff-Duty-Outsiders.lua                 Target and Return the Favor sections, pet owner from the tooltip
│   │   ├── Buff-Duty-Party-Buffs.lua               Party-Buffs plain icons, their clicks, the hover menu on ns.MenuKit
│   │   ├── Buff-Duty-Pets.lua                      Pet rows, pet holds, owner class, charmed check
│   │   ├── Buff-Duty-Position.lua                  Position saved by the top-right corner, Reset Position, and its MIGRATION
│   │   ├── Buff-Duty-Resurrections.lua             Resurrection pick, resurrection icon, pending suppression
│   │   ├── Buff-Duty-Self.lua                      Your sections, one per category: self and own group buffs, Bloodrage first, Soulstone, Well Fed, scrolls, elixirs, other items; Missing Inventory tests; IsEating
│   │   ├── Buff-Duty-Settings.lua                  Seeds and cleans audience, selfRefresh, tankWhen, weapon choices, the category tables; RowOn, RowShows, RowOnKey, RowOut, RowExists
│   │   ├── Buff-Duty-Switches.lua                  Feature and per-class switches, the two tracking predicates, close for the session and its Paused read
│   │   ├── Buff-Duty-Units.lua                     Who can be buffed, roster hold, roles, Wants, range, phase shift, PvP-flag hold, labels, SingleIcon
│   │   ├── Buff-Duty-Weapons.lua                   Enchant reads, layers, imbue landing, weapon rows, a hand's Missing Inventory, REPLACE_ENCHANT accept
│   │   └── Buff-Duty.lua                           Refresh, ShowsHere, debounce, backstop, event handlers, setup
│   ├── Core.lua                                    Version, ns.EVENT_NAMES, event modules and dispatch, InitializeDatabase with its migration order, other-client prune, unnamed-profile fix, ns:ApplyProfile, welcome, lifecycle
│   ├── Enhanced-Spellbook/                         Own spellbook window, a macro per spell, What's Next
│   │   ├── Action-Bars.lua                         Action-bar scan for glows, Mark Placed and placement; bar slots of a macro index
│   │   ├── Category-Menu.lua                       Category header menu, applying an option to every macro under it; category reset
│   │   ├── Class-Config.lua                        Empties other classes' data; resolves tags, groups, forms, toggles; PAGE_TAGS
│   │   ├── Class-Spells.lua                        Walk of class and profession spells across both book engines
│   │   ├── Consumable-Macros.lua                   Read-only Consumable Macros tiles on the page
│   │   ├── Dynamic-Rank.lua                        Rewrites placed target-rank macros as units change; mouseover poll; pre-combat rewrite
│   │   ├── Group-Handover.lua                      A learned successor takes a replaced spell's macro and settings
│   │   ├── Grouped-Spells.lua                      Grouped spells option, one macro casting a group
│   │   ├── Key-Bindings.lua                        GoodToGo_ToggleSpellbook; MIGRATION 2026-12-03 binding move
│   │   ├── LICENSE-Enhanced-Spellbook              MIT notice shipped with the folder
│   │   ├── Macro-Body.lua                          Macro text: CastBody, RankFor, stance line, MacroBody
│   │   ├── Macro-Builder/                          The ns.macros builder, Conditionals, Cast Sequence, docked panels
│   │   │   ├── Cast-Sequence-Panel.lua             Cast Sequence docked panel; End and Reset menus
│   │   │   ├── Cast-Sequence.lua                   Steps, resets, tail text, setters
│   │   │   ├── Conditionals-Panel.lua              Conditionals docked panel shell; shared UI table
│   │   │   ├── Conditionals-Rows.lua               Conditionals panel rows and condition menus
│   │   │   ├── Conditionals.lua                    Conditions, skip and block reasons, clauses, setters
│   │   │   ├── Docked-Panel.lua                    Shared panel shell, heading, row anchor under the hint, footer text and byte meter
│   │   │   ├── Macro-Builder.lua                   CollectMacros: every page macro, Duplicates, rank copies, folds, unlearned
│   │   │   ├── Panel-Widgets.lua                   Slots, dropdowns, grips and remove buttons the panels share
│   │   │   ├── Slot-Spells.lua                     Spell shown in a Conditionals or Cast Sequence slot, by ID
│   │   │   └── Spell-Pick.lua                      Owner-based spell pick mode and cursor drops
│   │   ├── Macro-Button-Notes.lua                  Tile option subtext and learnable-rank note
│   │   ├── Macro-Button.lua                        A page tile: click, drag, tooltip, glow, middle-click reset
│   │   ├── Macro-Copies.lua                        Duplicates, COPIED_SETTINGS and KEPT_SETTINGS, resets, settings moves
│   │   ├── Macro-Delete.lua                        Delete Macros for one list; delete one page macro; delete confirm
│   │   ├── Macro-Kinds.lua                         Macro kinds, the kind decision, shipped kind defaults
│   │   ├── Macro-Lookup.lua                        Slot limits, names, icons, FindMacroIndex, ownership; MIGRATION 2026-11-26 legacy names
│   │   ├── Macro-Menu-Panels.lua                   Every Spellbook pop-up menu on Menu-Kit panels: element tree, sub-menus, refresh, close
│   │   ├── Macro-Menu-Sections.lua                 Tile menu sections: Target, Grouped, Rank, Conditionals, Cast Sequence, When, First, Then, Errors
│   │   ├── Macro-Menu-Utilities.lua                Group values, macro text lines, featured options and tips, rebuilt-macro lookup
│   │   ├── Macro-Menu.lua                          A tile's right-click menu: order, Macro Storage, Macro Text, Duplicate, Delete
│   │   ├── Macro-Options.lua                       Option defaults, OFFERED predicates, option get and set
│   │   ├── Macro-Rank-Option.lua                   Target-rank and fixed-rank options
│   │   ├── Macro-Settings.lua                      Per-spell settings keys, storage, the option key list
│   │   ├── Macro-Sync.lua                          SyncMacro and SyncAt, PickupMacro, length guard, combat queue, Macro UI wait
│   │   ├── Macro-Tab.lua                           Macro Storage: which macro list a macro lives in; moving it between lists
│   │   ├── Macro-Tags.lua                          Tag line, identities, tag assignment, tag handover
│   │   ├── Menu-Utilities.lua                      Menu tooltips and notes, Auto Shot label, When/First/Then/Errors option tables
│   │   ├── Mute-Errors.lua                         Global GtGMute
│   │   ├── Page-Categories.lua                     Category and subcategory of each tile
│   │   ├── Page-Settings.lua                       Page toggles, sort, Mark Placed records; MIGRATION 2026-12-08 name lookup
│   │   ├── Ranged-Attacks.lua                      Folds the ranged attacks into one Shoot macro
│   │   ├── Spell-Rank-Lines.lua                    Rank rows, states and labels; tooltip rank lines
│   │   ├── Spell-Ranks-Tooltip.lua                 Ability tooltip ranks hook and its level-keyed cache
│   │   ├── Spell-Ranks.lua                         Known and unknown ranks, learn levels, baseID
│   │   ├── Spellbook-Controls.lua                  Page settings gear, filter and sort dropdowns, Mark All Placed, macro count
│   │   ├── Spellbook-Core.lua                      Master switch, event module and handler map, login migrations, profile apply
│   │   ├── Spellbook-Events.lua                    Event handlers, next-frame coalescing, RefreshMacros
│   │   ├── Spellbook-Host-Classic.lua              Vanilla, TBC and Mists: launcher tab under the skill-line tabs
│   │   ├── Spellbook-Host-Modern.lua               Camelot only: registers the launcher tab
│   │   ├── Spellbook-Page-Layout.lua               Row packing and pagination
│   │   ├── Spellbook-Page-Order.lua                Filters, sort, category order
│   │   ├── Spellbook-Page-Parchment.lua            Parchment art
│   │   ├── Spellbook-Page.lua                      The Spell Book page: collect, sync, draw, refresh listeners
│   │   ├── Spellbook-Paging.lua                    Custom page strip
│   │   ├── Spellbook-Tabs.lua                      Camelot only: side tabs on PlayerSpellsFrame, stepping past other add-ons
│   │   ├── Spellbook-Utilities.lua                 Spell name requests, UTF-8 trim, tooltip title and click lines, shared widgets and helpers
│   │   ├── Spellbook-Widgets.lua                   Filter box, controls-row dropdown, menu tooltips, ElvUI skin
│   │   ├── Spellbook-Window.lua                    GoodToGoSpellbookFrame, tabs, fit to screen, saved position and Reset Position, panel docking
│   │   ├── Target-Priority.lua                     Target priority units and per-kind lists
│   │   ├── Trainer-Recording.lua                   Records class trainer spells and levels per class
│   │   ├── Unlearned-Spells.lua                    Walk of trainer spells not yet known
│   │   ├── Usable-Items.lua                        Equipped Use: slots for the use-items option
│   │   └── Whats-Next/                             What's Next, Pet What's Next and Pet Spell Book tabs
│   │       ├── Pet-Spellbook.lua                   Pet Spell Book rows, pickup and class gate
│   │       ├── Whats-Next-Controls.lua             Settings gear, filter, source and sort controls; footer
│   │       ├── Whats-Next-Layout.lua               Metrics, sections and column pagination
│   │       ├── Whats-Next-Models.lua               The three page models; grimoire names; beast list in tooltips
│   │       ├── Whats-Next-Page.lua                 Shared list page builder, row clicks, tooltip, refresh
│   │       ├── Whats-Next-Pet.lua                  Pet and demon ability rows, pet settings
│   │       └── Whats-Next.lua                      Class rows, statuses, sources, sort and show settings
│   ├── Group-Context-Migration.lua                 MIGRATION only (2026-12-11): Buff Duty showSolo/Party/Raid and each profile's consumable <prefix>Mode onto the four context checkboxes
│   ├── Inventory-Report/                           Every character's bags and bank in item tooltips
│   │   ├── Inventory-Report-Recording.lua          Snapshots, packed format, shutdown save, Forget; handlers run by the Restocker module
│   │   └── Inventory-Report-Tooltip.lua            Tooltip block, other-character cache, Example item, delayed hook
│   ├── Item-Info.lua                               Session item memo, remembered misses, keyed GET_ITEM_INFO_RECEIVED waiters, window warming, item links and labels
│   ├── Key-Bindings.lua                            BINDING_HEADER_GOODTOGO, ns:OpenKeyBindings routes, UPDATE_BINDINGS repaint
│   ├── Legacy-Migration.lua                        MIGRATION only (2026-12-08): legacy settings import (Connoisseur's Poisons macro kept on), its notices and popups; Automated Appreciation settings and Thank You macros retired
│   ├── Macros-for-Consumables/                     The consumable macros: scan, rank, compose, write; also the scroll and buff food pickers Buff Duty reads
│   │   ├── Action-Button-Text.lua                  Macro-name text on action buttons by font-string alpha, ACTION_BAR_PREFIXES, the names toggle
│   │   ├── Character-Key-Migration.lua             MIGRATION only: Forever characters re-keyed by whole name in listsByCharacter and inventory
│   │   ├── Default-Profile-Migration.lua           MIGRATION only: characters moved off Default; older Forever settings and Restock List choices carried
│   │   ├── Ignore-List.lua                         Character and Global Ignore Lists, scopes, mini-map add, remove and clear, logout prune
│   │   ├── Item-Cache.lua                          Session-only consumable records, CONSUMABLE_TABLES, cold-item retry budget; ns.RetireSavedItemCache is MIGRATION
│   │   ├── Macro-Notes.lua                         Class click notes and item blocks for the mini-map menu and Spellbook tiles
│   │   ├── Macros/                                 Definition protocol, engine, writer, one file per macro, class and race tools
│   │   │   ├── Bandage.lua                         Single winner; Troll Rapid Regeneration as its out-of-combat lead cast
│   │   │   ├── Body-Builder.lua                    Standard body, out-of-combat block, corpse, combat and lead lines, byte trims, ns.BuildStateKey
│   │   │   ├── Definitions.lua                     Definition and conjure protocols, ns.RegisterMacroType, ns.MacroDefinitionByType
│   │   │   ├── Engine.lua                          The pipeline ns.UpdateMacros, Macro UI deferral, ns.ToggleMacroSetting, ns.ResetMacroState, master switch
│   │   │   ├── Explosive.lua                       At-player or toss click layout, EX state flag
│   │   │   ├── Food.lua                            Buff food ranking, pet-buff override, Stealth Eating, Cannibalize, Rapid Regeneration combat cast
│   │   │   ├── Health-Potion.lua                   Ranked; healthstone stacking; out-of-combat food
│   │   │   ├── Healthstone.lua                     Ranked; Warlock conjure clicks
│   │   │   ├── Integration-Druid-Macro-Helper.lua  DruidMacroHelper-wrapped potion and healthstone bodies, their trim and DMH state key
│   │   │   ├── Mana-Gem.lua                        Ranked; optional mana runes
│   │   │   ├── Mana-Potion.lua                     Ranked; out-of-combat water
│   │   │   ├── Runtime.lua                         GtG macro globals, wrong-zone bug report, no-item line; Connoisseur aliases are MIGRATION
│   │   │   ├── Signatures.lua                      Friendly-target test; target and group signatures
│   │   │   ├── Smart-Spell.lua                     Conjure lists sorted at load; rank pick and cast name
│   │   │   ├── Soulstone.lua                       Single winner; Warlock conjure click
│   │   │   ├── Tools-Forsaken.lua                  Cannibalize target test, switch test and cast
│   │   │   ├── Tools-Hunters-Pet-Food.lua          Pet food pick, quest signature, pet-buff override
│   │   │   ├── Tools-Hunters.lua                   Feed Pet tiers and trim, pet spells, dead-pet detection
│   │   │   ├── Tools-Mages.lua                     Mage conjure resolvers
│   │   │   ├── Tools-Rogues.lua                    The Poisons macro and on-demand poison picks
│   │   │   ├── Tools-Troll.lua                     Rapid Regeneration: Food combat line, Bandage out-of-combat line
│   │   │   ├── Tools-Warlocks.lua                  Healthstone and Soulstone resolvers
│   │   │   ├── Water.lua                           Stealth Drinking; Cannibalize where it restores mana
│   │   │   └── Writer.lua                          The one writer ns.WriteMacroBody, ns.TryCreateMacro, delete, macros-ready line
│   │   ├── Macros-for-Consumables-Core.lua         Event module ConsumableMacros, two-flag throttle, combat-guard ordering, profile re-apply
│   │   ├── Macros-for-Consumables-Utilities.lua    When to Use test, max level, racial cooldown timer, KnowsAny, game names
│   │   └── Scanner/                                Bag scan, auras, scrolls, ranking ladder
│   │       ├── Scanner-Auras.lua                   Scroll lookups, shared player aura snapshot, early re-application, pet food gate and UNIT_AURA
│   │       ├── Scanner-Character.lua               Class and race flags, spell names, conjure spell cache, profession ranks
│   │       ├── Scanner-Diagnostics.lua             Selection candidates, kept only while Diagnostics is on
│   │       ├── Scanner-Inventory.lua               The scan ns.ScanBags: bag walk, usability gates, dispatch, Buff Duty's buff food pick
│   │       ├── Scanner-Ranking.lua                 RANKING_PRIORITY, winners, ranked lists
│   │       └── Scanner-Scrolls.lua                 Best scroll per type and missing scrolls, for Buff Duty, Readiness and Diagnostics
│   ├── Menu-Kit.lua                                Shared Menu Kit copy, unedited: plate, entry kinds, panel layout, cursor tests, Kit.CreateMenu, the game's menus and AceGUI pullouts dressed on the plate
│   ├── Minimap-Button.lua                          LDB launcher, LibDBIcon registration and hand-fitted icon on Camelot, food icon, show and hide
│   ├── Minimap-Menu.lua                            The mini-map menu on Menu Kit panels: blocks, the button's one kept click, flyouts, Buff Duty menu hand-off, placement, close timer, ns.ShowMenu and kin
│   ├── Rank-Watch/                                 Low ranks cast in the group, plus Ability Alerts While Leveling; no Mists TOC loads it
│   │   ├── LICENSE-Rank-Watch                      MIT notice for Rank Sentinel
│   │   ├── Rank-Watch-Check.lua                    The low-rank check, ceiling, dedupe, messages, whisper queue, Opt Out listener and offer
│   │   ├── Rank-Watch-Cluster.lua                  RANKSENTINEL leader election, JOIN and LEAD, offline-leader takeover, handback on turning off, NOTIFY and SYNC sharing
│   │   ├── Rank-Watch-Core.lua                     Settings accessor, event module and handler table, switch, standalone add-on, ignore command, reset listener, login migrations
│   │   ├── Rank-Watch-Detection-Combat-Log.lua     Vanilla and TBC TOCs: combat-log detection
│   │   ├── Rank-Watch-Detection-Forever.lua        Camelot TOC: own-cast handshake, own pet, group auras, damage meter
│   │   ├── Rank-Watch-Level-Up.lua                 Ability Alerts While Leveling: trainer spells printed on a ding; own module, always subscribed; the panel Example
│   │   └── Rank-Watch-Lookups.lua                  Ladders joined by ns.SPELL_GROUPS, pet ladders, fast reject, tracked state, best rank, rank text
│   ├── Readiness-Report/                           The private report printed on a ready check
│   │   ├── Readiness-Report-Example.lua            The panel's sample lines
│   │   ├── Readiness-Report-Probes.lua             Stateless live reads: group, soulstones, expiring auras, flask, weapons, gear, talents, mana
│   │   └── Readiness-Report.lua                    Clauses, ns.ReadinessAsks gates, line assembly, the ReadinessReport module
│   ├── Replaced-Addons.lua                         Permanent: turns off ns.REPLACED_ADDONS at login and offers the reload; shares the turned-off titles with the legacy import
│   ├── Restock-Reminders-Migration.lua             MIGRATION only (2026-12-13): every restock reminder mode back onto Simple, once
│   ├── Restocker/                                  Restock Lists, merchant buying, bank restocking, reminders, upgrades, Staples, the Restock List window
│   │   ├── Restocker-Bags.lua                      Player and bank container lists, bag-type test, slot scans, empty-slot placement, Add Item From Bags item scan
│   │   ├── Restocker-Bank-Moves.lua                Single bank and bag moves, overshoot pull, BankHasRestockSpace
│   │   ├── Restocker-Bank-State.lua                Run state, Keep freeze, cursor clearing, remaining work, stuck message, bank open and close
│   │   ├── Restocker-Bank-Tidy.lua                 Partial-stack count and one-merge consolidation
│   │   ├── Restocker-Bank-Visit.lua                Run coroutine, watchdogs, in-flight and lock gates, ping-paced OnUpdate, restart carry-over
│   │   ├── Restocker-Core.lua                      Login setup, logout packing, master switch
│   │   ├── Restocker-Crafting-Reagents.lua         Poison recipe index and the reagent order
│   │   ├── Restocker-Events.lua                    Handler table, WhileEnabled, module dispatcher (the Inventory Report's too), event sync
│   │   ├── Restocker-Inventory-Model.lua           The summary and slots model a scan returns, best-fit merge slot
│   │   ├── Restocker-List.lua                      Add, remove, undo, New flags, item-data waits and their subscription
│   │   ├── Restocker-Merchant-Report.lua           Delivery wait, the run's report, out-of-gold line
│   │   ├── Restocker-Merchant.lua                  Purchase orders, reagent gate, buy loop, merchant open and close
│   │   ├── Restocker-Purchase-Space.lua            The bag-space budget a merchant run spends down
│   │   ├── Restocker-Reminders.lua                 Low and out split, reminder headlines and lines, the footer's headline
│   │   ├── Restocker-Saved-Format.lua              One-line row codec, inflated at login, packed at logout
│   │   ├── Restocker-Saved-Lists.lua               Named lists, each character's choice, list users, new, copy, rename, discard, delete, prune
│   │   ├── Restocker-Shortfall.lua                 Shortfall and grocery lists, short-row test, order counts, after-visit reminder
│   │   ├── Restocker-Slash-Command.lua             The /restock parser and help
│   │   ├── Restocker-Starter-Categories.lua        Staples rows: ns.STARTER_LIST_CATEGORIES, caps, choices, classes, pre-ticks
│   │   ├── Restocker-Starter-List.lua              Staples logic: chain resolution, ticks, stacks, names, login trigger
│   │   ├── Restocker-Starter-Sections.lua          Staples sections, display order, stack choices and labels
│   │   ├── Restocker-Starter-Window.lua            The Staples window: layout, stack menus, saved position and Reset Position, Done and login hint, Escape handoff
│   │   ├── Restocker-Town-Reminder.lua             In-town arrival reminder, taxi rule, arming, login item requests
│   │   ├── Restocker-Trace.lua                     Trace lines (ns.RestockerDebug) into the Event Log
│   │   ├── Restocker-Upgrade.lua                   Level-ladder upgrades, tier sort by rank, upgradable test
│   │   ├── Restocker-Window-Bag-Menu.lua           Add Item From Bags field and its AceGUI pullout
│   │   ├── Restocker-Window-Categories.lua         Item-type pane, group selection, measured pane width
│   │   ├── Restocker-Window-Cells.lua              Toggle and reputation cells: state, toggle, paint, tooltips
│   │   ├── Restocker-Window-Column-Header.lua      Column captions, Keep heading, group bands, bulk-set headings
│   │   ├── Restocker-Window-Columns.lua            COLUMNS, measured widths, layout walk, row metrics, shared colors
│   │   ├── Restocker-Window-Filter.lua             View building, groups, filter, sort; pure data
│   │   ├── Restocker-Window-Footer.lua             Status line: short and to-buy counts, its short-items tooltip
│   │   ├── Restocker-Window-Frame.lua              Portrait frame shared with Staples, bands, body inset, header buttons, ElvUI skin
│   │   ├── Restocker-Window-Header.lua             Filter, add box, Add, Pick Staples, bag menu placement, add notices
│   │   ├── Restocker-Window-List-Bar.lua           Footer list controls: selector and its menu, Used by line
│   │   ├── Restocker-Window-List-Manage.lua        Manage Lists menu, Delete and Copy confirms, rename field
│   │   ├── Restocker-Window-Menus.lua              The shared kit dropdown ns.RestockMenu, choice rows, reputation menu, column bulk-set menu
│   │   ├── Restocker-Window-Render.lua             The full redraw ns.UpdateRestockList, shortfall and cold-row repaints, removed-row signature, row pool
│   │   ├── Restocker-Window-Reputation.lua         Standing labels, menu text, Rep tooltip body
│   │   ├── Restocker-Window-Rows.lua               Pooled rows: Keep box, remove and Undo buttons, item binding, removed-row look
│   │   ├── Restocker-Window-Widgets.lua            Menu closer ns.CloseRestockMenus, cursor drop-add, control click, menu field, tooltips
│   │   └── Restocker-Window.lua                    Window build, geometry, saved spot and Reset Position, empty state, Escape membership, show, hide, toggle, visit open and close
│   └── Utilities.lua                               Colors, UI error line, client-difference accessors, secret tests, tooltip reads, character profile names and keys, spell links, group context, unit by GUID, durations, tooltip side, kit-dressed dropdowns
├── Good-to-Go_Camelot.toc                          WoW Forever
├── Good-to-Go_Mists.toc                            Mists of Pandaria Classic; no Rank Watch feature or options files
├── Good-to-Go_TBC.toc                              TBC Anniversary
├── Good-to-Go_Vanilla.toc                          Classic Era, Season of Discovery included
├── Includes/                                       Vendored assets
│   ├── Images/                                     Icon, window and menu art; Menu-Plate.tga is the Menu Kit's plate
│   ├── Libraries/                                  Vendored libraries, refreshed from .pkgmeta externals at release
│   └── Sounds/                                     Low-Battery.ogg, the restock reminder sound (ns.RESTOCK_ALERT_SOUND)
├── LICENSE                                         MIT
├── Locales/                                        AceLocale strings; enUS.lua is the source of truth
├── Options/                                        AceConfig panels: shared kit, shell files, one folder per feature
│   ├── Buff-Duty/                                  Buff Duty panel and its Group Buffs, Self-Buffs, Well Fed, Weapon Buffs, Scrolls, Flasks or Elixirs and Other Buffs sub-panels
│   │   ├── Options-Buff-Duty-Buffs.lua             Group Buffs: Refresh Under, Count as Tanks, each class's audience dropdowns
│   │   ├── Options-Buff-Duty-Consumables.lua       Well Fed, Scrolls (scroll types, profile), Flasks or Elixirs and Other Buffs pages, each opening with its category's controls
│   │   ├── Options-Buff-Duty-Self-Buffs.lua        Self-Buffs tree: the category's controls, then a page per class, each buff On or Off
│   │   ├── Options-Buff-Duty-Utilities.lua         Builders only these panels use: class list, refresh labels, spell dropdown and toggle rows, ns.AddBuffDutyRowControls, ability labels
│   │   ├── Options-Buff-Duty-Weapon-Buffs.lua      Weapon Buffs: the category's controls, per-hand checkbox grids for class picks and weapon items
│   │   └── Options-Buff-Duty.lua                   Main panel: feature switch, When to Show, Classes, the category switches, Other Players with both ask composers and Buff PvP-Flagged Players, window settings with Reset Position
│   ├── Enhanced-Spellbook/                         Spellbook panel and its Ability Alerts sub-panel
│   │   ├── Options-Ability-Alerts.lua              Ability Alerts While Leveling panel: switch, three sub-toggles, example; not in the Mists TOC
│   │   └── Options-Enhanced-Spellbook.lua          Switch, Reset Position, ability tooltip ranks, Delete Macros buttons per list
│   ├── Inventory-Report/                           Inventory Report panel
│   │   └── Options-Inventory-Report.lua            Switch, Example, Recorded Characters with Forget
│   ├── Macros-for-Consumables/                     Consumable Macros and its pages: Food & Drinks, Potions & Mana Gems, Bandages, Healthstone, Explosives, Class Macros, Ignore List
│   │   ├── Options-Bandages.lua                    Bandages page: description only
│   │   ├── Options-Class-Macros.lua                Class Macros page: DruidMacroHelper and return form, Pet Food Buffs, poison hands (hidden while the Poisons macro is off)
│   │   ├── Options-Explosives.lua                  Explosives page: click layout (hidden while the macro is off)
│   │   ├── Options-Food-Drinks.lua                 Food & Drinks page: conjured first, Restock List last, buff food when Well Fed, Refresh Food Buffs Under, stealth and racial eating
│   │   ├── Options-Healthstone.lua                 Healthstone page: healthstones in the Health Potion macro
│   │   ├── Options-Ignore-List.lua                 Ignore List tree: Global, then characters; add, promote, remove, clear
│   │   ├── Options-Macros-Utilities.lua            Shared page builder ns.MacroOptions: page wrapper, toggles, When to Use rows, rune text; loads before every page
│   │   ├── Options-Macros.lua                      Consumable Macros panel: switch, Which Macros to Create, Macros Window, no-item Example, Action Bars
│   │   └── Options-Potions-Mana-Gems.lua           Potions & Mana Gems page: out-of-combat food and water, mana runes
│   ├── Options-Feature-Switches.lua                Master switch records ns.FEATURES, Rank Watch and Ability Alerts inserted where loaded; ns.FindFeature
│   ├── Options-Feedback-Support.lua                Feedback & Support: Level Up paragraphs, links, version line
│   ├── Options-General.lua                         Root panel: welcome, mini-map toggle, Features switches, Key Bindings rows, Commands
│   ├── Options-Kit.lua                             Shared Options Kit copy, unedited: grid, rows, switches, Example lines, Reset, HideAllExcept, item lists, registry, guarded opener, ns.RefreshSettings
│   ├── Options-Message-Composer.lua                Whisper composer ns.DefineWhisperComposer: Send Messages In, per-whisper box with marker and sign-off captions, Reset (grayed at the default), tokens, Too Long line, Example, Send Test to Me
│   ├── Options-Profiles.lua                        Stock AceDBOptions profiles table; MIGRATION noDefaultProfiles argument
│   ├── Options-Utilities.lua                       Kit strings, Good to Go's own widths, group context checkboxes, switch-off status, feature-off line, printed Example lines
│   ├── Options-Widgets.lua                         Icon checkbox AceGUI widget type
│   ├── Options.lua                                 Panel registration and tree order, PrepareTree homes, slash commands
│   ├── Rank-Watch/                                 Rank Watch, Reported Ranks and Ignored Players panels; no Mists TOC loads it
│   │   ├── Options-Rank-Watch-Ignored.lua          Ignored Players: Ignore Target, rows by name with remove icon, class back-fill
│   │   ├── Options-Rank-Watch-Tracked.lua          Reported Ranks: tree of classes and pet pages, a box per rank, Check All and Uncheck All
│   │   └── Options-Rank-Watch.lua                  Rank Watch panel: switch, standalone notice, grace periods, Whisper with its composers, Print, Examples
│   ├── Readiness-Report/                           Readiness Report panel
│   │   └── Options-Readiness-Report.lua            Switch, rows built from SECTIONS, Example, Reset
│   └── Restocker/                                  Restocker settings page
│       └── Options-Restocker.lua                   Switch, Gold Reserve, reminders with modes and Examples, low threshold, auto-open toggles, Reset Position for both windows; all hidden while off
├── README-Notes.md                                 Where Good to Go departs from the Style Guide
├── README-Technical.md                             This document
├── README-Testing.md                               Manual test plan
├── README.md                                       Player documentation
├── Tests/                                          Offline tests; never in a TOC, .pkgmeta ignores it
│   └── Run.lua                                     Runs on Lua 5.1 from the add-on root, called by CI: event names, Forever combat log, other-client prune, event log noise
└── Tools/                                          Data builders and checks; .pkgmeta keeps them out of the zip
    ├── Build-Rank-Watch-Abilities.py               Merges Rank Sentinel onto Rank-Watch-Abilities-{Game}.lua; the file's rows win
    ├── Build-Rank-Watch-Pet-Abilities.py           Rewrites Rank-Watch-Pet-Abilities-{Game}.lua whole; Camelot only with --wago
    ├── Check-Scroll-Conflicts.py                   Diffs Scrolls-{Game}.lua conflictSpells against wago.tools stat auras; writes no data file
    ├── Group-Context-Rules.html                    Design page for the group context checkboxes; the code wins where they differ
    ├── Scroll-Conflicts-Report.md                  Generated per-flavor report of that check
    └── Scroll-Conflicts-Review.md                  Findings, stacking research and in-game tests for that report
```

## Architecture

### Event Loop

- **One frame for the whole add-on** (`eventFrame`, `Features/Core.lua`), so the Diagnostics Event Log taps every event in one place (`ns:LogEvent`, gated on `ns.diagnostics.logging`, read first so logging-off is free).
- **`ns.EVENT_NAMES`** is the one list. Readers: Core's `KNOWN_EVENTS`, Diagnostics' Event Registration report (`ns:RunEventChecks`, `Diagnostics/Code-Reports.lua`), `Diagnostics/Options-Diagnostics.lua`, `Tests/Run.lua`. Flavor-guarded appends: `COMBAT_LOG_EVENT_UNFILTERED` only when `ns.FLAVOR ~= "Camelot"`; `PLAYER_FOCUS_CHANGED` only when `ns.FLAVOR ~= "Vanilla"` (the Spellbook's `EVENT_HANDLERS` repeats that guard).
- **Event modules.** `ns.RegisterEventModule(name, dispatch)`; subscribe or release with `ns.SetModuleEvent(name, event, enabled, ...units)`.
  - `SetModuleEvent` asserts the event is in `KNOWN_EVENTS` and the module exists, so a gap stops the load; `Tests/Run.lua` catches it first.
  - Units after `enabled` make the subscription unit-filtered: the module hears only firings whose first argument is one of its units.
  - `RefreshRegistration` unregisters and re-registers the event on every call: registered while any module (or `CORE_EVENTS`) wants it; `RegisterUnitEvent` only while every subscriber filters and the union is two units or fewer (the API's limit), else plain `RegisterEvent` with per-module filtering in the dispatch loop.
  - Dispatch has no `pcall`: an error in one module's handler ends that firing for every module after it.
- **Modules hear an event in registration order, which is TOC load order:** `KeyBindings`, `ItemInfo`, `ConsumableMacros`, `ReadinessReport`, `Restocker` (the Inventory Report's `ns.inventoryEventHandlers` ride it, gated on `ns.db.global.inventoryReport`), `RankWatch`, `LevelUpAlerts` (neither on Mists), `BuffDuty`, `Spellbook`.
- **Wrappers and handler tables behind modules:** `ns.SetEventRegistered` (Consumable Macros), `ns.SetRankWatchEvent`; `ns.SetBuffDutyEventHandler`, `ns.SetRankWatchHandler`, `ns.restockerEventHandlers`, `ns.inventoryEventHandlers`, and the Spellbook's `EVENT_HANDLERS` map of `ns:On<X>` names resolved when the event fires. A second handler for one event silently replaces the first.
- **Features subscribe only while on**, each master switch subscribing and releasing its own events. Heard regardless, on purpose:
  - Every module's own `PLAYER_LOGIN`, subscribed at file load (ReadinessReport, Restocker, RankWatch, BuffDuty, Spellbook); Restocker's `PLAYER_LOGOUT` (`ALWAYS_EVENTS`); BuffDuty's `PLAYER_ENTERING_WORLD` and both `PLAYER_REGEN_*` (a change made in combat, switching off included, waits for combat to end).
  - `ConsumableMacros`: no master switch over its events; its scan feeds the Readiness Report, the mini-map and Buff Duty (`ns.bestBuffFoodID`, `ns.carriedBuffFoods`). Its `DEFERRED_EVENTS` subscribe on demand (`UNIT_AURA` via `ns.UpdateAuraTracking`, `QUEST_LOG_UPDATE` for hunters, the cast events per class at login).
  - `KeyBindings` (`UPDATE_BINDINGS`) and `LevelUpAlerts` (`PLAYER_LEVEL_UP`, its switches read inside `LevelUpLines`).
  - Spellbook's `ADDON_LOADED` (`WHILE_OFF_EVENTS`; `Spellbook-Tabs.lua` subscribes and releases it itself, Camelot only). Its trainer events (`LOGIN_REGISTERED_EVENTS`) wait for login to show `Trainer-Recording.lua` loaded.
  - `ReadinessReport` syncs `READY_CHECK` at login and from its switch (`ns.SyncReadinessReportEvents`).
  - `ItemInfo` holds `GET_ITEM_INFO_RECEIVED` only while a waiter exists (Caching).
- **Core's own events.** `CORE_EVENTS` stay registered; Core handles them before any module:
  1. `PLAYER_LOGIN`: `ns.TurnOffReplacedAddons`, `InitializeDatabase`, `ns.RegisterOptionsPanels` (the Profiles panel binds to `ns.db`), `ns.RegisterMinimapIcon`. Only then do modules hear `PLAYER_LOGIN`, so `ns.db` exists for them. Nothing protected, so a mid-combat login still runs it. An error here leaves every module's login unrun and `ns.db` possibly nil at logout (`Restocker-Events.lua` checks).
  2. `PLAYER_ENTERING_WORLD`: `ns:PrintWelcome` once a session (`welcomePrinted`): `CHAT_LOADED` if `showWelcome`, then `ns.PrintLegacyNotices`, then `ns.OfferLegacySteps` or else `ns.OfferReplacedReload`.
  3. `PLAYER_LOGOUT`: `SaveProfileChoiceWhenUnnamed`.
- **Outside the dispatcher:** `Features/Menu-Kit.lua`'s `WatchItem` registers `GET_ITEM_INFO_RECEIVED` on a frame of its own (shared copy; never unregistered once a cold item is shown); `Spellbook-Tabs.lua` uses `EventRegistry` callbacks; `Spellbook-Host-Classic.lua` uses `hooksecurefunc`. None reach the Event Log.
- **Pacing by feature:**

| Feature | Pacing |
|---|---|
| Consumable Macros | Two flags (`isUpdatePending`, `isTickScheduled`) on an OnUpdate tick, `UPDATE_THROTTLE` after the first request of a burst; not debounced to the last. Cold items retry on a literal timer, at most `DATA_RETRY_MAX_ATTEMPTS` |
| Buff Duty | One-flag `REFRESH_DELAY` timer every trigger funnels through (`ns.RequestBuffDutyRefresh`); `BACKSTOP_INTERVAL` ticker for expiry, deaths and disconnects; `RANGE_INTERVAL` alpha ticker; `Data.SAFETY_PAUSE` after every loading screen |
| Enhanced Spellbook | Next-frame coalescing behind one pending flag per kind of work (`Spellbook-Events.lua`); Dynamic Rank's one pending scope (`QueueRankRewrite`) and `MOUSEOVER_POLL_SECONDS` poll |
| Restocker | A literal guard against a doubled `MERCHANT_SHOW`; a ping-paced OnUpdate for the bank run; `BUY_SETTLE_TIMEOUT` behind the merchant report; `SETTLE_DELAY` before closing reminders; `ARRIVAL_SETTLE_DELAY`, `LOGIN_SETTLE_DELAY` and `REMINDER_COOLDOWN` for the town reminder; `STARTER_POPUP_DELAY`; Staples repaints coalesced to one per frame |
| Rank Watch | Held whispers retry on one armed timer (`ArmRetry`: `TARGET_BUSY_RETRY`, `RANK_TEXT_RETRY`); sends ride the shared whisper gap; `JOIN` after `JOIN_DELAY`; Forever: `METER_POLL` damage-meter ticker out of combat plus one read on leaving combat |
| Inventory Report | Bank re-read after `BANK_SETTLE_DELAY`; tooltip hook after `TOOLTIP_HOOK_DELAY` |

### Combat Lockdown

- **Refuse, never queue.** `ns:OpenOptionsPanel` (`Options/Options-Kit.lua`) is the one gate for `/gtg`, `/restock config` and the menu's Options row. `ns:OpenKeyBindings` (`Features/Key-Bindings.lua`) refuses the same way with `CHAT_KEY_BINDINGS_IN_COMBAT`. The Macros panel's Open Macros Window (`OpenMacroWindow`, `Options-Macros.lua`) refuses with `CHAT_OPTIONS_IN_COMBAT`.
- **Consumable Macros defer.**
  - `ns.UpdateMacros` (`Engine.lua`) in combat calls `ns.RequestUpdate` and returns. `ns.RequestUpdate` in combat only sets pending; an armed tick that finds combat disarms itself; events below `OnEvent`'s guard only set pending.
  - `PLAYER_REGEN_ENABLED` re-reads what was put off (`ns.RereadProfessionSkillsIfPending`, `ns.RereadTargetIfPending`), then re-requests if anything is pending.
  - A forced rebuild keeps its force across the wait: `UpdateMacros(true)` wipes `currentMacroState` before the combat check.
  - Handlers above the guard keep signatures current mid-fight. Baselines below it stay honest because every scan re-records them.
  - Forever hides target identity mid-fight: `ns.TargetSignatureChanged` reads nothing and owes the reading. Profession skill reads wait for combat end or the Skills frame closing (`ns.DeferProfessionSkillsRead`, `Scanner-Character.lua`).
- **The Enhanced Spellbook defers syncs and refuses actions.**
  - `ns.SyncAllMacros` (and the gear-change sync in `Spellbook-Events.lua`) in combat calls `ns.QueueMacroSync`; `ns:OnPlayerRegenEnabled` (`Macro-Sync.lua`) runs `RefreshMacros` if pending.
  - `ns.PickupMacro`, `ns.DeleteAddonMacros`, `ns.DeletePageMacro` and `ns.SetMacroTab` refuse with a chat print (`ERROR_MACRO_COMBAT`); `ns.StartSpellPick` refuses with `ERR_NOT_IN_COMBAT` through `ns.ShowUIError`.
  - Tooltip ranks, `ns.CloseGameSpellbook` (both hosts), docked-panel keys, the docked panels' pick on an empty last slot and `ns.MigrateSpellbookBinding` skip silently.
  - Dynamic Rank skips too (`RanksRewritable`); `ns:OnPlayerRegenEnabled` always queues `ns.QueueRankRewriteAll`, since the target or mouseover may have changed meanwhile. `PLAYER_REGEN_DISABLED` (`ns:OnPlayerRegenDisabled`) runs `ns.RewriteRanksBeforeCombat` (the last moment such macros can change) and `ns.CancelSpellPick`.
- **Buff Duty's buttons are secure.**
  - Refresh, `ns.RenderBuffDuty`, `ns.HideBuffDuty`, `ns.DropBuffDutyTargetIcons`, `ns.ApplyBuffDutySettings`, `BuffDuty.ToggleGroupFold` and drag-start all refuse. A settings change (or a drag let go in combat) queues behind `settingsPending` (`ns.QueueBuffDutySettings`).
  - A roster or target change mid-fight dims icons (`ns.MarkBuffDutyRosterStale`, `OUT_OF_RANGE_ALPHA`). Only alpha and the `CooldownFrameTemplate` children change in combat; an item icon's range check is skipped.
  - `PLAYER_REGEN_ENABLED` applies pending settings, prunes the aura cache and requests a full refresh.
  - Hide in Combat is a state driver (`[combat] hide; show`, `Buff-Duty-Frame.lua`) on the anchor frame, so the client hides it without the add-on touching a protected frame.
  - A Buff Key press in combat is silent: it clears its pick, and only a Bloodrage-first press's leftover buff on the button casts. Asking the target for buffs (`ns.AskTargetForBuffs`, `BuffDuty.CanAskTarget`) is refused in combat. Camelot's aura favors are not read in combat or while auras are secret.
- **The Inventory Report defers one read:** `bagsChangedInCombat`, read on `PLAYER_REGEN_ENABLED`. A mid-fight logout saves the bags as of the fight's start.
- **The Readiness Report doesn't wait.** It only reads auras and the last scan, and is silent while auras are secret.
- **Rank Watch holds off:** whisper checks skip in combat or while dead (`Rank-Watch-Check.lua`); Forever's meter reads report nothing mid-fight and take the finished fight on `PLAYER_REGEN_ENABLED`.
- **The Restocker has no combat guard.** Nothing it does is protected, a merchant or bank window can't open in combat, and a logout mid-combat must still pack the lists. The Staples login trigger skips a login that lands in combat.
- **Skipped and retried at next login:** `ns.RetireAutomatedAppreciation`'s macro deletes, `ns.MigrateSpellbookBinding`, `ns.MigrateBuffKeys`.

### Main Pipeline: Consumable Macros

**Events** (`Macros-for-Consumables-Core.lua`, module `ConsumableMacros`):

- Subscribed all session whatever `macrosEnabled` says: its scan feeds the Readiness Report, the mini-map and Buff Duty's Well Fed and scroll icons. `EVENTS` subscribe at load except `DEFERRED_EVENTS`, which go through `ns.SetEventRegistered`:
  - `UNIT_PET`, player only, at load.
  - `UNIT_AURA` (`ns.UpdateAuraTracking`, re-registers only when the wanted units change): `player` while the bags hold buff food (`ns.carriesBuffFood`, set at the end of each scan), `pet` while Pet Food Buffs is live. Scrolls are Buff Duty's, which watches its own.
  - `QUEST_LOG_UPDATE`, Hunters only, re-decided every arrival (`RefreshArrivalState`).
  - `UNIT_SPELLCAST_SUCCEEDED`, decided once at login (`InitializeConsumableMacros`): Mage, Warlock, Forsaken, Troll with Rapid Regeneration, Hunter. `UNIT_SPELLCAST_SENT`: Hunters only.
- **Above `OnEvent`'s combat guard, on purpose:** `PLAYER_LOGIN`, `UI_ERROR_MESSAGE`, `UNIT_PET`, `PLAYER_LEVEL_UP`, `PLAYER_LOGOUT` (Ignore List prune), `PLAYER_TARGET_CHANGED`, `GROUP_ROSTER_UPDATE`, both spellcast events, `SKILL_LINES_CHANGED` (in combat only `ns.DeferProfessionSkillsRead`), and `PLAYER_ENTERING_WORLD`'s `ns.ApplyMacroNameVisibility` (alpha only). A value that changes and changes back mid-fight still reads as changed afterward. Below the guard, combat only sets `isUpdatePending`.
- Busy events diff before requesting: `ns.TargetSignatureChanged`, `ns.GroupSignatureChanged`, `ns.OnUnitAura` (Well Fed while carrying buff food, the pet food buff), `ns.PetFoodQuestsChanged`, `ns.UpdateProfessionSkills`, `ns.SpellCastChangesMacros` (a conjure in `ns.spellCache`, Cannibalize, Rapid Regeneration; a secret spell ID requests anyway).
- `PLAYER_LEVEL_UP` takes the level from the event (`UnitLevel` still reads the old one), re-resolves Hunter spells and wipes state. `PLAYER_ENTERING_WORLD` refreshes `ns.cachedPlayerLevel` / `ns.cachedMapID` and aura tracking, then requests now and again after a literal delay. `ns.OnConsumableItemInfoReceived` requests only for an item `ns.HasRawData` knows.
- Self-timed rebuilds: `ScheduleExpiryRecheck` (`Scanner-Auras.lua`, a buff crossing the early re-application threshold fires no event); `ns.RacialSpellReady` (`Macros-for-Consumables-Utilities.lua`, Cannibalize and Rapid Regeneration; a secret or global cooldown counts as on cooldown); `ns.RegisterDataRetry` (`Item-Cache.lua`).

**Scan → Rank → Compose → Write** (`ns.UpdateMacros(forced)`, `Macros/Engine.lua`):

1. **Scan** (`ns.ScanBags`, `Scanner/Scanner-Inventory.lua`).
   - Refreshes `ns.cachedMapID` and calls `ns.UpdateAuraTracking`, which also reads `ns.wellFedState` (group or level changes flip Pet Food Buffs with no call of their own).
   - Sets `ns.buffFoodRank` (`"last"`, or false under `useBuffFoodWhenFed`), `ns.buffFoodFirst` (no Well Fed and auras readable), `ns.excludeBuffFood` (targeting yourself, a plain-food testing aid), `ns.allowConjuredFirst` (`useConjuredFirst` and `ns.IsUseWhenActive(settings, "conjuredFirst")`), `ns.allowRestockLast`, and hands the current Restock List to `Ranking.SetScanRestockList`.
   - Walks `ns.CARRIED_BAG_IDS` into `ns.scannedItemCounts` / `ns.scannedItemLinks`. `ns.petBuffOverrideID` (`ns.FindPetBuffOverride`) is forced nil in an arena or while `ns.AreAurasSecret()`.
   - Per item: skip scrolls (`ns.SCROLL_ITEM_LOOKUP`), `ns.CacheItemData`, then the usability gates (level, First Aid, Alchemy, Engineering, `requiredSpellID`, zones, `arenaOnly`; an arena drops potions and food or water without `arenaUsable`).
   - Buff Duty's buff food, in the same walk: every usable, unignored buff food goes in `ns.carriedBuffFoods`; the best not in Buff Duty's `buffWindow.buffFoodOff`, ranked with `buffFood = "first"`, becomes `ns.bestBuffFoodID`, and a change calls `ns.RequestBuffDutyRefresh`.
   - Dispatches to **every** definition whose `itemTypes` claims the item and whose `accepts` passes. An ignored item only sets `ns.scannedIgnoredTypes[type]`.
2. **Rank** (`Scanner/Scanner-Ranking.lua`, shared as `ns.ScanRanking`).
   - One list, `RANKING_PRIORITY`, drives `IsBetter` (single winner) and `CompareRankedCandidates` (ranked types) through `CompareRecords`, which also returns the deciding field for Diagnostics. It ends on item ID for determinism.
   - Gated steps: buff food (`Ranking.BuffFoodRank(definition)`, shared with Diagnostics: `"first"` for Buff Duty's pick and for a `buffFoodFirstWhenUnfed` definition under `ns.buffFoodFirst`, else `ns.buffFoodRank` where `allowBuffFood`), conjured-first, restock-last (Food and Water only). Ranked lists run with all three gates and `preferHybrid` off.
   - Ranked types keep up to `ns.MULTI_USE_MAX_ITEMS` in `topIDs`, from a per-type record pool. Every comparison field is filled by `FillRecord` alone.
   - Selection tables build lazily on the first scan (`BuildSelectionTables`), because definitions register after the scanner loads. Winners publish as `ns.bestSelection`; Food also publishes `ns.bestFoodID` / `ns.bestFoodLink`.
3. **Compose.**
   - With `macrosEnabled` off the scan still runs, plus `ns.ScanPetFood` (Hunters), `ns.UpdateMinimapIcon` and `ns.RefreshMenu`. Nothing is created, rewritten or deleted.
   - Per standard definition: delete the macro if `ns.IsMacroEnabled` is false. Otherwise, in order: `modifyItem`; `corpseSpell` / `leadSpell` / `combatSpell` (each only while the body uses the scanned pick); ranked `useIDs` (`ns.MULTI_USE_MACRO_TYPES` only); `getStackIDs` (with no main item the stack becomes the whole body under `stackTypeName`'s DruidMacroHelper guards); the `outOfCombatTypeName` pick behind `potionsUseFoodAndWater`, with that type's `stealthSpell` and `corpseSpell` via `ns.MacroDefinitionByType`; `ns.BuildDruidMacroOverride`.
   - The body is the DruidMacroHelper body when it applies, else the standard body (`conjure`, `appendBlock`, `ns.BuildStateKey`, `ns.BuildStandardBody`).
   - Custom definitions run afterward with their own state: Feed Pet (`Tools-Hunters.lua`, `currentPetFoodState`) and Poisons (`Tools-Rogues.lua`, `currentPoisonState`). Unticked, each deletes its macro on any class (it sits in the shared General tab); ticked, each updates only on its class. Poisons is deleted wherever `ns.POISONS_SPELL_ID` is nil.
4. **Write** (`Macros/Writer.lua`). `ns.WriteMacroBody` is the one writer.
   - Creates through `ns.TryCreateMacro`: General tab (`perCharacter` omitted), refused once free slots fall to `ns.MACRO_SLOT_CUSHION` with a once-per-session `MESSAGE_MACRO_SLOTS_ARE_FULL`, resuming on its own when a slot frees.
   - A successful create schedules one `MESSAGE_MACROS_READY_TAB` per pass on a literal timer, since no single place knows the pass ended.
   - `EditMacro` only when `GetMacroBody` differs, always with `ns.QUESTION_MARK_ICON`.
   - Returns false on a failed write; every caller then leaves its state key unset.

**State keys and bodies:**

- Two layers stop a double write: the per-type key in `currentMacroState`, recorded only after the write landed, and the writer's body comparison.
- The key format is documented above `ns.BuildStateKey` and is lossless over every body input. Disjoint prefixes: DruidMacroHelper `DMH:` (carries the return form's spell ID), standard starts with a digit or `none`. `ns.ResetMacroState` wipes every key (Feed Pet and Poisons included), the pet food reading (`ns.ResetScrollBuffTracking`) and the target and group signatures.
- **Blizzard Macro UI.** It saves its edit box back on close, reverting a write the key already recorded. While `MacroFrame` is shown `ns.UpdateMacros` only marks pending (`ns.MarkUpdatePending`); a one-time `OnHide` hook (`EnsureMacroUIHook`, tried on every pass) resets state and requests. A first open and close before any update is the one gap.
- Standard payload, top to bottom (each line only when its input is set):

```
#showtooltip item:<id>   (or a [nocombat] lead / [combat] / [dead] spell form, or [combat] potion; food out of combat)
<conjure block>, /cast [dead] <corpse>, /cast [combat] <combat> + /stopmacro [combat], /cast [nocombat] <lead> + /stopmacro [nocombat]
/run GtGFire(<id>[,<oocID>])
<OOC block>   (/cast [nocombat,dead], /use [nocombat], /cast [nocombat,nostealth], /stopmacro [nocombat])
/use item:<id> (up to ns.MULTI_USE_MAX_ITEMS ranked lines), stacked /use lines, appendBlock
```

  With nothing in bags the item line becomes `/run GtGTip("<noItemMiss>")` while the class can learn the conjure but hasn't, `/run GtGNoItem("<type>",1)` while it knows it, else `/run GtGNoItem("<type>")`; a corpse cast adds `/stopmacro [dead]` above it.
- **Byte trims** against `ns.MACRO_BODY_MAX_LENGTH`, in order: Cannibalize lines, stacked healthstones, ranked fallbacks from the bottom (never rank 1), the OOC stealth, the OOC block, the appended line, the combat and lead casts. Each rebuilds through `ns.BuildStandardBody` with that input dropped. A body still too long is written anyway, with one `ns.WarnOnce` per macro. DruidMacroHelper trims its own `/use` lines, then stealth, then the OOC block, then falls back to the standard body. Feed Pet sheds Dismiss, then Revive.
- **Multi-use macros** fall through to the next ranked item once the best runs out mid-combat, where the macro can't be rewritten. Safe only because every item in those types shares one cooldown (mana runes share the gems'); healthstone stacking is the opposite case (separate cooldowns, one press fires one of each).
- **`enabledMacros`, `macrosEnabled` and `showMacroNames` are account-wide while the choices are per-character.** The macros live in the shared General tab, so which ones exist is one choice for the account; `ns.ApplyConsumableMacrosProfile` (from `ns:ApplyProfile`) only rebuilds bodies and aura tracking. Back on, `ns.SetMacrosEnabled` rewrites every body.
- **Conjures** (`ns.GetSmartSpell`): `Smart-Spell.lua` sorts every `ns.CONJURE_SPELLS` list in place at load, best first. Rank text comes from `C_Spell.GetSpellSubtext` only when the row carries a rank number. Food, Water and Healthstone downrank for a lower-level friendly target; Mana Gem, Soulstone, Refreshment Table and Soulwell ignore the target. Healthstone and Mana Gem skip a tier already carried (`checkUnique`, `ns.CONJURED_ITEM_IDS_BY_SPELL`). Fallback: the lowest rank actually known. A flavor with no table or Soulwell rows writes no middle-click.
- **Arenas** are detected live (`IsInInstance`), never by zone list.
- **Forsaken Cannibalize** (`Tools-Forsaken.lua`, `ns.CannibalizeCast`): a `corpseSpell` on Food and, only where `ns.CANNIBALIZE_RESTORES_MANA`, on Water. Written only while off cooldown, the target's creature type is in `ns.CANNIBALIZE_CREATURE_TYPE_IDS`, and the pick isn't buff food (only eating that gives Well Fed); the macro's `[dead]` decides the rest. The target is read only while `ns.CannibalizeSwitchedOn`.
- **Troll Rapid Regeneration** (`Tools-Troll.lua`), Forever only (`ns.RAPID_REGENERATION_SPELL_ID` nil elsewhere), two switches:
  - `enableRapidRegenerationEating`: Food's `combatSpell` (`ns.RapidRegenerationCombatCast`), `/cast [combat]` + `/stopmacro [combat]` on every body that eats its own pick, cooldown ignored, since nobody eats in combat and the body can't change there.
  - `enableRapidRegenerationBandage`: Bandage's `leadSpell` (`ns.RapidRegenerationBandageCast`), `/cast [nocombat]` + `/stopmacro [nocombat]` only while off cooldown; rebuilt by the cast (`UNIT_SPELLCAST_SUCCEEDED`) and by `ns.RacialSpellReady`'s timer. In combat the macro always bandages.
- **Stealth Eating** is one `enableStealthEating` key: Stealth for Rogues, Shadowmeld for other Night Elves. Stealth Drinking (`enableShadowmeldDrinking`) is Night Elves only. The panel makes the two exclusive. Never on a body with no item or the pet-buff override.
- **DruidMacroHelper** applies only with that add-on loaded, the switch on and the return form known (bear tries Dire Bear Form first). The return form is a setting, not tracked: a macro can't be rewritten after a mid-combat form change.
- **Feed Pet tiers** (`Tools-Hunters.lua`): a tip-only stub while a pet spell besides Mend is missing; a cascade plus a tip without Mend Pet; the full cascade. `ns.petDeadDismissed` is set by `SPELL_FAILED_TARGETS_DEAD` only within `CALL_PET_ERROR_WINDOW` of sending Call Pet, and cleared by a live pet or a successful Call or Revive Pet.
- **Pet food** (`ns.ScanPetFood`) reads the same pass's `ns.scannedItemCounts`, so it runs only inside an update pass after `ns.ScanBags`; Feed Pet runs it even with the macro off, since the mini-map and Diagnostics read `ns.bestPetFoodID`. None in an arena.
- **Pet Food Buffs** gate on `ns.ShouldTrackPetFood` (`Scanner-Auras.lua`), shared with the Readiness Report so the report never asks for a buff the macro won't apply. Any class with a live pet; a flavor with no `ns.PET_BUFF_FOODS` rows runs none of it.
- **Poison picks** resolve on demand (`ns.GetBestPoisonForHand`), never published.

**Buff food, scrolls and the aura snapshot** (what the macros hand Buff Duty):

- While you lack Well Fed the Food macro eats buff food first, ahead of conjured (`buffFoodFirstWhenUnfed`, `ns.buffFoodFirst`). Otherwise Food and Water rank it with the rest (`useBuffFoodWhenFed`) or last, so a bag holding only buff food still feeds you. Buff Duty's Well Fed icon uses `ns.bestBuffFoodID`; its category menu lists `ns.carriedBuffFoods`, writes `buffWindow.buffFoodOff` and calls `ns.RequestUpdate`, and toggles `useBuffFoodWhenFed` through `ns.ToggleMacroSetting`.
- Scrolls never enter a macro; the scan skips them. `Scanner-Auras.lua` builds `ns.SCROLL_ITEM_LOOKUP`, sorts each `ns.SCROLL_DATA` type's items by required level in place, builds reverse maps from buff and conflict spell IDs to types, and fills a missing table or list with empties logged in `ns.SCROLL_DATA_GAPS`.
- `ns.FindBestScroll(type, counts)` (`Scanner-Scrolls.lua`): the first carried scroll in level order; only a class token and the Ignore List skip one; level never gates. `ns.FindMissingScrolls(counts, snapshot)`: the best scroll per ticked `scrollTypes` type, in `ns.SCROLL_CHECK_ORDER`, whose buff `ns.HasScrollBuff` says is missing. Readers: the Readiness Report and Diagnostics. Buff Duty (`AddScrollIcons`, `Buff-Duty-Self.lua`) calls `ns.FindBestScroll` with a live `GetItemCount` proxy and reads the snapshot raw against its own refresh time.
- `ns.HasScrollBuff`: own buff of any rank counts through `BuffCountsAsActive` (early re-application); a conflicting buff covers only at an equal or larger amount and is exempt from the threshold (a stronger buff can't be overwritten).
- `ns.GetPlayerBuffSnapshot`: one walk of the player's buffs into a shared buffer (`wellFedExpiration`, `scrolls[type].expiration` / `.conflictAmount`); nil means absent, 0 means no duration. While auras are secret it returns the last readable snapshot. Readers: Readiness Report, Buff Duty, Diagnostics. The pet has its own probe (`ns.GetPetFoodBuffExpiration`).

**Ignore List** (`Ignore-List.lua`):

- Two additive halves, `profile.ignoreList` and `global.ignoreList`, read through `ns.IsIgnored`.
- `ns.GetIgnoreListForScope(scope, createIfMissing)` reads other profiles straight from `ns.db.sv.profiles` and creates a table only on a write. Promoting an item to Global clears it from every profile.
- Mini-map edits (`ns.IgnoreItem`, `ns.UnignoreItem`, `ns.ClearIgnoreList`) act on this character's list only and return what changed for the chat line.
- Every edit calls `ns.ResetMacroState` and `ns.UpdateMacros(true)`.
- Overrides read raw bag counts, so each honors the Ignore List itself: scrolls, pet buff food, pet food, poisons, Buff Duty's buff food.
- The logout prune drops only IDs `C_Item.DoesItemExistByID` denies, since Era and Season of Discovery share the file.

**Class notes** (`Macro-Notes.lua`): `ns.GetClassMacroNotes` (Hunter, Mage, Rogue, Warlock; item blocks then notes blocks) feeds the mini-map menu's [Class] Macros row; `ns.AddConsumableMacroNotes` feeds the Spellbook's Consumable Macros tile tooltips. A row only for a spell known.

**Options** (`Options/Macros-for-Consumables/`):

- `Options-Macros.lua`: the switch, Which Macros to Create (`MacroToggle` on `global.enabledMacros`, the default item's icon), Open Macros Window (refused in combat), the no-item Example (`ns.BuildNoItemLine`), Action Bars. `Kit.HideAllExcept` keeps only the switch and Action Bars while off, since the names toggle hides every button's name.
- Pages nest under it in `RegisterMacrosPanels` (`Options/Options.lua`): Food & Drinks, Potions & Mana Gems, Bandages, Healthstone, Explosives, Class Macros, Ignore List. Each page wraps through `ns.MacroOptions.Page` (the feature-off line; settings stay editable while off).
- `ns.MacroOptions` (`Options-Macros-Utilities.lua`): `Toggle` (through `ns.ToggleMacroSetting`; `clears` makes a pair exclusive), `BodyToggle`, `Changed` (reset, request, repaint), `ModeSubRow` / `UseWhenGroups` for a When to Use, `ManaRuneText`.
- Every section shows on every character; the only gates are flavor ones (`ns.CANNIBALIZE_RESTORES_MANA`, `ns.RAPID_REGENERATION_SPELL_ID`, `ns.PET_BUFF_FOODS`, `ns.POISONS_SPELL_ID`).

### Caching

- **Session memo** (`ns.GetItemData`, `Features/Item-Info.lua`) over `C_Item.GetItemInfo`, keyed by whatever the caller asked with (an ID on hot paths, a link at a merchant: two keys, two entries), never saved. For names, icons and links of any item; consumable facts come from the consumable cache below.
  - `ns.GetItemHyperlink` builds a white `|Hitem:ID|h[name]|h` link by hand while the item is cold (`LOADING_ITEM` as the name when none is given); the client resolves it on hover. `ns.GetItemLabel` / `ns.UnbracketItemLink` give the bracketless form for the add-on's own windows; chat keeps brackets.
- **Waiters.** `ns.RequestItemInfoEvents(key)` / `ns.ReleaseItemInfoEvents(key)` are keyed, not counted; `GET_ITEM_INFO_RECEIVED` floods at login, so it stays registered only while a waiter exists. A release by a key not waiting is a no-op.
  - Keys: `"scan"` (`ns.RegisterDataRetry`, `Item-Cache.lua`), `"restocker"` (`ns.SyncRestockItemInfoSubscription`), `"window:<windowKey>"` through `ns.WarmItemCache` (the Staples window), and `GRIMOIRE_WAITER` (`Whats-Next-Models.lua`).
  - The `ItemInfo` dispatcher ignores the event name and fans every answer out in order: `ns.OnRestockerItemInfoReceived` (forgets the miss, retries parked rows), the file-local `OnWindowItemInfoReceived`, `ns.OnConsumableItemInfoReceived` (rebuilds only when `ns.HasRawData`), `ns.OnWhatsNextItemInfoReceived`. Each feature hook is existence-tested.
- **Window warming** (`ns.WarmItemCache(itemIDs, windowKey, onArrive)`, `onArrive` asserted): requests each cold ID, holds the window's waiter until every ID it handed in is answered, calls `onArrive` per answer. Never requests an ID already cached, already failed this session (file-local `failedItemIDs`) or one `C_Item.DoesItemExistByID` denies, since no answer may come and the wait would hold the event all session. A failed ID's row keeps its loading text.
- **Options panels don't use the event.** `Kit.WarmItems` (`Options/Options-Kit.lua`) polls every `WARM_RETRY_SECONDS` up to `WARM_MAX_ATTEMPTS` per registry name and `NotifyChange`s when one lands. The Menu Kit has its own watcher (Event Loop).
- **Remembered misses** (`rememberedMisses`) are kept only for a numeric ID and only while a waiter listens: the client answers once, so a miss taken while nobody listens would strand the item. The last release wipes them all; each answer reaches `ns.ForgetItemDataMiss` (from `ns.OnRestockerItemInfoReceived`) before anything retries. The comments in `Item-Info.lua` explain why frame- or time-scoped misses were rejected.
- **Consumable cache** (`Item-Cache.lua`): file-local, session-only, consumables only. A non-consumable returns `"IGNORE"` with no API call. `CONSUMABLE_TABLES` names each data table and the column where its item facts start. A row without facts falls back to `C_Item.GetItemInfo`. A cold item calls `ns.RegisterDataRetry`, which keys in `"scan"` and retries on a literal 2-second timer up to `DATA_RETRY_MAX_ATTEMPTS`. The event outlives the budget so a late answer still rebuilds; `ns.UnregisterDataRetry` refunds the budget.
- **The Restocker** parks adds, upgrades and Staples ticks on cold items rather than writing a row with the wrong name (Restocker → Adding and Removing).

### Flavors and Load Order

- **TOC order** (all four): libraries, `Locales/` (enUS first), `Data/Flavor.lua`, `Data/Data.lua`, `Data/Message-Languages.lua`, the flavor's `Data/{Game}/` files (Vanilla: `Data/Vanilla/` then `Data/Discovery/`), `Data/Default-Settings.lua`; then `Features/`: `Core.lua`, `Replaced-Addons.lua`, `Legacy-Migration.lua`, `Utilities.lua`, `Menu-Kit.lua`, `Minimap-Menu.lua`, `Group-Context-Migration.lua`, `Restock-Reminders-Migration.lua`, `Announcements.lua`, `Key-Bindings.lua`, `Item-Info.lua`; the feature folders (Consumable Macros, Readiness Report, Restocker, Inventory Report, Rank Watch, Buff Duty, Enhanced Spellbook); `Macro-Notes.lua` + `Minimap-Button.lua`; `Diagnostics/` (`Diagnostics-Core.lua`, `Manifests.lua`, the `Manifests-*`, the framework reports, the `Message-Length-*`, `Report-Runner.lua` last); `Options/` (`Options-Kit.lua` first, `Diagnostics/Options-Diagnostics.lua` next to last, `Options/Options.lua` last).
  - MIGRATION files carry a `# MIGRATION (remove after ...)` comment line in every TOC.
- **Load-time reads pin that order:**
  - `Core.lua` reads `ns.FLAVOR` for the event-list guards.
  - `Default-Settings.lua` reads `ns.SCROLL_DATA` (flavor folder), `ns.SCROLL_CHECK_ORDER` (`Data.lua`) and `Data.DEFAULT_MESSAGE_LANGUAGE` (`Message-Languages.lua`).
  - `Utilities.lua` derives `ns.COLORS` / `ns.COLORS_RGB` from `ns.PALETTE`, lowercases `ns.SPELL_LINK_COLOR` and reads `ns.EXPANSION`.
  - `Announcements.lua` and `Item-Info.lua` capture `ns.GetColor`; `Minimap-Menu.lua` captures `ns.MenuKit`; `Legacy-Migration.lua` captures `ns.turnedOffAddOnTitles`, `ns.AddOnTitle`, `ns.JoinAddOnTitles` from `Replaced-Addons.lua`.
  - `Key-Bindings.lua`, `Item-Info.lua` and every feature's events file call `ns.RegisterEventModule` / `ns.SetModuleEvent` at load, so `Core.lua` comes first, and their order is dispatch order.
  - `Report-Runner.lua` builds one Data report per `ns.DIAGNOSTIC_DATA_SOURCES` row at load, so every manifest loads before it.
  - Feature files capture each other's `ns` fields at load; each feature section names the captures that matter.
- **`ns.FLAVOR` comes from the TOC's `## X-Flavor`**, never the client: Forever's `WOW_PROJECT_ID` has changed value once. `ns.EXPANSION` maps it (`Data/Flavor.lua`); Camelot maps to 1: it is game content, not client engine (Forever runs the Retail client), so engine differences are API-probed (`Features/Utilities.lua`). `ns.IS_DISCOVERY` is Vanilla plus the active season (`C_Seasons`); `ns.DATA_FOLDER` names the folder that built the tables (Validate Data and the client headers print it).
- **Seven flavor folders, one complete copy each.** Same file set everywhere; an empty table stands in where a flavor has no rows, so feature code never asks which flavor built a table. Vanilla files open with `if ns.IS_DISCOVERY then return end`, Discovery files with the opposite, so one set builds. `Data/Wrath/` and `Data/Mainline/` are forward-prep: no TOC lists them, `.pkgmeta` ignores them, the `Tools/` scripts still write them.
- **How the TOCs differ** besides the data folder and `## Interface`:
  - Camelot loads `Rank-Watch-Detection-Forever.lua` where Vanilla and TBC load `Rank-Watch-Detection-Combat-Log.lua`.
  - Camelot loads `Spellbook-Tabs.lua` and `Spellbook-Host-Modern.lua` where the others load `Spellbook-Host-Classic.lua`.
  - Mists loads no `Features/Rank-Watch/` file (Ability Alerts While Leveling, `Rank-Watch-Level-Up.lua`, included) and no `Options/Rank-Watch/` file or `Options/Enhanced-Spellbook/Options-Ability-Alerts.lua`. It still loads the Rank Watch data files, `Manifests-Rank-Watch.lua` and `Message-Length-Rank-Watch.lua`.
  - Header lines shared by all four: `## SavedVariables: GoodToGoDB, BagsBuffsButtonsDB` (the second MIGRATION), `## Version: @project-version@`, the CurseForge and Wago IDs, localized `## Category-*`.
- **Names.** Folder, `ADDON_NAME` and AceLocale name: `Good-to-Go`. Saved table `ns.SAVED_VARIABLES_NAME`; `ns.OLD_SAVED_VARIABLES_NAME` is the pre-rename table (MIGRATION). Frames, bindings and popups carry `GoodToGo`; anything a macro body calls carries `GtG`, since every byte counts against `ns.MACRO_BODY_MAX_LENGTH`.
- **`ns.Version`** (`Core.lua`) reads TOC `Version` and is `"Dev"` while it still holds `@project-version@`.
- **Two homes for constants.** Buff Duty, Rank Watch and message-language constants sit on `ns.Data` (`Data.SAFETY_PAUSE`, `Data.RANK_WATCH`, `Data.WEAPON_LAYERS`, `Data.MESSAGE_LANGUAGES`, `Data.EDITABLE_MESSAGES`, `Data.DEFAULT_MESSAGE_LANGUAGE`). Everything else sits directly on `ns`.

### Group Contexts

Every setting that turns a feature on or off by group follows the same rules.

- **One answer.** `ns.GetGroupContext()` (`Features/Utilities.lua`) returns one of `ns.GROUP_CONTEXTS` (`Data/Data.lua`), the first that holds of `battleground` (`ns.IsInPvPInstance`: battleground or arena, whatever the group), `raid`, `party`, `solo`. A battleground's raid is a Battleground, never a Raid. Instance groups (LFR, group-finder dungeons) count like home groups.
- **One shape.** A setting saves `{ solo, party, raid, battleground }` booleans, all `true` by default, read through `ns.IsGroupContextOn(table[, context])`. A missing table or entry reads as ticked.
- **One control.** Four checkboxes in that order with `GROUP_CONTEXT_<KEY>` labels: `ns.OptionsGroupContextRow` (sub-option row) or `ns.OptionsGroupContextToggle` (one box); `ns.OptionsGroupContextNone` adds the red line while none is ticked (`Options/Options-Utilities.lua`).
- **Extra filters narrow, never replace.** Buff Duty's Anywhere / In Instance (`showWhere`, no Battleground entry: a battleground is always an instance) and the consumables' level filter (`<prefix>Level`, one of `ns.LEVEL_FILTER_ORDER`; labels in the local `LEVEL_FILTER_VALUES`, `Options-Macros-Utilities.lua`) can only switch off a ticked context.
- **Who uses it.** Buff Duty's When to Show (`buffWindow.showIn`, `BuffDuty.ShowsHere`, which the Buff Key asks too); each consumable's When to Use (`<prefix>In` + `<prefix>Level` through `ns.IsUseWhenActive(settings, prefix)`, for `petBuffFood` and `conjuredFirst`); Count as Tanks' SOLO (`CountsAsTank`, `Buff-Duty-Units.lua`). Plumbing that only picks a chat channel or unit prefix (`ns:GetGroupChatChannel`, `ns.GetUnitByGUID`) reads `IsInRaid` / `IsInGroup` itself.
- **Change detection.** `ns.GroupSignatureChanged` (`Macros/Signatures.lua`) diffs the context itself, so entering or leaving a battleground rescans the macros; every group read in `ns.IsUseWhenActive` must stay inside it. Buff Duty re-checks on `GROUP_ROSTER_UPDATE` and every `PLAYER_ENTERING_WORLD`.
- **A ticked box that can't work says so.** Where the game hides auras (`ns.AreAurasSecret()`), Buff Duty prints `BUFF_DUTY_AURAS_HIDDEN` once a session (`ns.WarnOnce`) when When to Show would otherwise show the window.

### Characters and Profiles

- **AceDB can open the database under a placeholder name.** The newest AceDB among enabled add-ons loads and reads the character's name once, possibly before the client named the character (or, with an AceDB older than minor 39 on Forever, the first name only). `UseOwnProfileWhenUnnamed` (`Core.lua`) moves to the profile saved under the real name at login; `SaveProfileChoiceWhenUnnamed` saves the choice under the real name at `PLAYER_LOGOUT` and drops the placeholder's `profileKeys` entry. Both key off `ns.SplitCharacterProfileName` returning nil for a key naming no character. So a character's own key is `ns.GetCharacterProfileName() or ns.db.keys.char` (`ns.MacroOwnerKey`, the Restocker's own-key reader in `Restocker-Saved-Lists.lua`), never `ns.db.keys.char` alone.
- **Copied-WTF characters are pruned** right after `AceDB:New` (`PruneOtherClientCharacters`): `char`, `profileKeys` and, unless still in use, `profiles` entries, in the root table and every namespace. `PruneOtherClientGlobals` then drops `restocker.listChoices` by key shape and Inventory Report records by name and realm (README-Notes exception). The rule is a key's shape: `" - "` (`REALM_KEY_SEPARATOR`) on realm clients, `"First Last"` on Forever. On Forever an older AceDB's `First - RuleSet` key (`FOREVER_RULE_SETS`) is kept (`IsOlderForeverKey`, MIGRATION 2026-12-08; README-Notes exception) so `CarryOlderForeverSettings` (`Default-Profile-Migration.lua`) can read it.
- **Two character-key formats, never mixed** (`Features/Utilities.lua`, Character Profile Names / Character Keys):

| Key | Shape | Readers | Used by |
|---|---|---|---|
| AceDB profile name | `Name - Realm`; `First Last` (literal space) on Forever | `ns.GetCharacterProfileName`, `ns.ProfileNameForCharacter`, `ns.SplitCharacterProfileName` | `profileKeys`, profiles, `restocker.listChoices`, `ns.MacroOwnerKey`, `ns.GetClassesByProfileName`, Rank Watch's read of Rank Sentinel's `profileKeys` |
| Add-on character key | Whole name, then `-Realm` with spaces closed up (no suffix where the client names no realm) | `ns.GetCharacterKey` | `global.inventory`, the Inventory Report panel, Diagnostics, `Character-Key-Migration.lua`, the legacy `listsByCharacter` lookup |

- `ns.GetPlayerFullName` (Utilities' Client Differences) reads `UnitNameUnmodified` (the name AceDB saves under, not a display restyle), adds the surname with the client's `CHARACTERNAME_SURNAME_SEPARATOR`, and never doubles one already present (an early beta's `UnitName` gave the whole name). Off Forever it is `UnitName`. `ns.GetCharacterProfileName` returns nil while the client answers `UNKNOWNOBJECT`; on Forever (`RegionalUniqueNamesEnabled`) it joins with a literal space, not the separator.
- **Every profile change re-applies.** `ns:ApplyProfile` runs on `OnProfileChanged`, `OnProfileReset`, `OnProfileCopied`: `ns.ApplyConsumableMacrosProfile`, `ns.ApplyBuffDutyProfile`, `ns.ApplySpellbookProfile` (each existence-tested), `ns:ApplyMinimapButton`, then `ns.RefreshSettings`. The Restock List in use is the character's choice, not the profile's, so a switch leaves it. The callbacks are wired last in `InitializeDatabase`, so the migrations' profile switches fire no handler. Rank Watch registers its own `OnProfileReset` listener at its login (`resetListener`, `Rank-Watch-Core.lua`).
- **Profiles panel** (`Options/Options-Profiles.lua`): the stock AceDBOptions table, no locale keys of ours. Its `noDefaultProfiles` argument (MIGRATION 2026-12-08) hides the realm, class and "Default" suggestions while `ns.MoveCharactersOntoOwnProfiles` runs, since a character put on Default would be moved off again next login.

### Replaced and Legacy Add-ons

- **`ns.REPLACED_ADDONS`** (`Data/Data.lua`: Connoisseur & Restocker, and Rank Sentinel under both folder names, matching `Data.RANK_WATCH.STANDALONE_FOLDERS`) is permanent, not a migration: a player can install Good to Go or turn the old add-on back on long after the import is gone. Any of them loaded at login is turned off for every character before the database opens (`ns.TurnOffReplacedAddons`, `Features/Replaced-Addons.lua`), and `GOODTOGO_REPLACED_RELOAD` is offered once in the world (`ns.OfferReplacedReload` from `ns:PrintWelcome`), since the old copy keeps rewriting the same macros (or double-reporting ranks) until a reload. `ns.turnedOffAddOnTitles`, `ns.AddOnTitle`, `ns.JoinAddOnTitles` are exported for the legacy import.
- **`ns.LEGACY_ADDONS`** is a migration (`Features/Legacy-Migration.lua`, 2026-12-08): Connoisseur & Restocker (`ConnoisseurDB`), Macro Spellbook, Rank Sentinel (both folders). Only `ConnoisseurDB` has an importer.
  - The client loads an add-on's saved variables only while it is on, so a loaded one is copied once through `LEGACY_IMPORTERS`, raw, before AceDB opens: legacy wins key by key, keys only Good to Go has are kept, Restock Lists merge by name. The Connoisseur importer also writes `enabledMacros.Poisons = true` where unset (Connoisseur's Poisons default was on), so an import on any login, after `poisonsDefaultMigrated` is stamped included, keeps the macro past Good to Go's off default.
  - The record is `global.legacyImported[sv]`: `LEGACY_IMPORT_VERSION` or `"declined"`; any other value (the first rule's `true`) imports again. `ns.ImportLegacySettings` creates `GoodToGoDB.global.legacyImported` on every login, fresh installs included.
  - Loaded legacy add-ons not in `ns.REPLACED_ADDONS` are turned off here and join `ns.turnedOffAddOnTitles`.
  - An installed-but-off one (`GetAddOnInfo` reason `"DISABLED"`) gets `GOODTOGO_LEGACY_IMPORT` (`POPUP_LEGACY_IMPORT_LISTS` text when `ConnoisseurDB` is pending, else `_SETTINGS`). Accept enables it for this character only and reloads; Decline saves `"declined"`; Escape (`noCancelOnEscape`) asks again next login. While pending, `ns.IsLegacyImportPending()` keeps Staples shut. The question waits while any add-on was just turned off.
  - After a copy, `ns.OfferLegacySteps` swaps `GOODTOGO_REPLACED_RELOAD`'s text to `POPUP_LEGACY_RELOAD_COPIED` and shows it with the copied and turned-off titles; it returns whether it asked, else `ns:PrintWelcome` falls back to `ns.OfferReplacedReload`. `ns.PrintLegacyNotices` prints `CHAT_LEGACY_IMPORTED` lines after the welcome.
  - Macro Spellbook and Rank Sentinel are only turned off here; Rank Watch imports Rank Sentinel's settings itself in the same session (`ImportStandaloneSettings`, `Rank-Watch-Core.lua`).
- **Automated Appreciation is retired** (`ns.RetireAutomatedAppreciation`, same file): nils `RETIRED_SETTINGS` keys and `legacyImported.TFTBDB`; out of combat, deletes `RETIRED_MACROS` only when a macro's trimmed body is still exactly its own `/thankyou[n]` command and no `SLASH_*` alias claims that command (`IsSlashCommandTaken`). Thanks for the Buff is its own add-on: never imported, never turned off.

### Sent Messages (`Features/Announcements.lua`)

- **Prints** (player only): `ns.BuildPrintLine` (the `Good to Go //` prefix, white body; panels' Example lines draw it), `ns:PrintMessage`, `ns.WarnOnce(message[, key])` once per session per key.
- **Every line to other players** is `{rt1} body // GtG`, built by `SignOff` (`ns.TARGET_MARKER` + `TrimSentBody` + `ADDON_SHORT_NAME`), on every channel and client: Forever blocks marker tokens only in numbered channels, which the add-on never sends to. The Star is shared with Thanks for the Buff (README-Notes exception). Every send goes through local `Send` (`C_ChatInfo.SendChatMessage`), which drops a nil channel or empty message.
- `TrimSentBody` trims closing punctuation as whole UTF-8 sequences (`CLOSING_MARKS`, full-width CJK included) and drops a leading `¡ ¿` (`OPENING_MARKS`). Bodies carry links, so pipes and braces stay.
- **Fixed-key lines**: `BuildSent(formatKey, ...)` (nil for a key with no text) behind `ns:BuildAnnounceMessage` (build to measure) and `ns:Announce(channel, target, formatKey, ...)` (build and `Deliver`: a whisper through the queue, anything else at once). An already-built line goes through `ns:QueueAutomatedWhisper`.
- Whispers queue `WHISPER_GAP` apart (`QueueWhisper`) against the server squelch; an empty queue sends at once.
- Group buff ask: `ns:SayBuffRequest` / `ns:BuildBuffRequestMessage(names, count, link)` pick `BUFF_DUTY_OTHERS_ASK_ONE` / `_NAMES` / `_COUNT` (`BuffRequestParts`); counts instead of names past `ASK_MAX_NAMES` (exported as `ns.BUFF_ASK_MAX_NAMES` for Diagnostics) or when names and count disagree (`AsksByCount`). `ns.JoinNames` lists names with the `LIST_*` formats; `JoinChoices` uses `LIST_OR_*`. `ns:GetGroupChatChannel`: `INSTANCE_CHAT`, then `RAID`, then `PARTY`.
- **Editable whispers** (`buffAsk`, `buffAskTarget`, `rankWatchTip` / `Pet` / `Demon`, `rankWatchOptOut`, `rankWatchOptOutDone`) are the player's own text with `{word}` tokens filled through `FillTokens` (gsub with a function, so `%` is literal and an unknown token stays as typed). Each has a fill/build pair: `ns.FillBuffAskWhisper` / `ns:BuildBuffAskWhisper`, `ns.FillBuffAskTargetWhisper` / `ns:BuildBuffAskTargetWhisper` (`{name}`, `{spells}` joined as choices), `ns.FillRankWatchTipWhisper` / `ns:BuildRankWatchTipWhisper` (field from `ns.RankWatchTipField(form)`), `ns.FillOptOutOfferWhisper` / `ns:BuildOptOutOfferWhisper`, `ns.FillOptOutDoneWhisper` / `ns:BuildOptOutDoneWhisper`.
  - Fill builds as typed, any length, so panels can flag Too Long. Build (`BuildEditable`) returns nil for empty text, the chosen language's default when over `ns.CHAT_MESSAGE_MAX_LENGTH`, nil when even the default is. Example lines, Too Long, Send Test to Me (`ns:WhisperTestToSelf`) and real sends all use them.
  - The buff ask swaps in `buffAskOne` / `buffAskCount` only while the text is still the default, matching the group ask's grammar. The tip tries the linked spell, then the bare name, and never cuts a message (a cut could break a link).
- **Message languages** (`Data/Message-Languages.lua`). Defaults live in `Data.MESSAGE_LANGUAGES` (one row per locale, every field), not `Locales/`, because AceLocale loads only the client's file and an English client may whisper in German. `Data.EDITABLE_MESSAGES` maps each field to its `ns.db.global` table (`buffWindow` or `rankWatch`) and key; unset means the language's default, `""` sends nothing.
  - `ns.GetMessageLanguage` reads `global.messageLanguage`; a code no longer listed reads as `Data.DEFAULT_MESSAGE_LANGUAGE`. `ns.GetMessageLanguageInfo(locale)` is nil for an unlisted locale (enGB). `ns.GetMessageText` / `ns.GetDefaultMessage(field[, locale])`. `ns.SetMessageText` trims and clears a text equal to the default to nil so it follows the language; `ns.SetMessageLanguage` clears texts still on the old default and never replaces written text.
- **Composer** (`ns.DefineWhisperComposer(args, spec, order)`, `Options/Options-Message-Composer.lua`), called from `Options-Buff-Duty.lua` (two composers: the target ask's shows Send Messages In only while the group ask's is hidden, `spec.languageHidden`) and `Options-Rank-Watch.lua`. Marker and `// GtG` are captions beside the box because the build adds them. No live count: the panel redraws only on save.
- `ResolvePlurals` (`Utilities.lua`) resolves the client's `|4` plural escapes, only inside `ns.FormatDuration`. Nothing on the send path resolves them.

### Key Bindings (`Features/Key-Bindings.lua`, `Bindings.xml`)

- `Bindings.xml` is loaded by the client on its own, never listed in a TOC. Three bindings: `GOODTOGO_TOGGLE_SPELLBOOK` (calls `GoodToGo_ToggleSpellbook()`), `CLICK GtGBuffKey:LeftButton` (no body; clicks the hidden secure button), and the hidden `MACROSPELLBOOK_TOGGLE` (MIGRATION, the toggle's pre-GtG name).
- Every binding's `category="BINDING_HEADER_GOODTOGO"`, the global set to `L["ADDON_TITLE"]` in `Features/Key-Bindings.lua`, which gives Good to Go its own section; `"ADDONS"` would bury it under the shared AddOns header. Keys are saved against the binding's name, so a section move keeps them and a rename needs a key move.
- **Labels sit beside each feature:** `BINDING_NAME_GOODTOGO_TOGGLE_SPELLBOOK` in `Enhanced-Spellbook/Key-Bindings.lua`; the Buff Key's `_G["BINDING_NAME_" .. ns.BUFF_KEY_COMMAND]` in `Buff-Duty-Keys.lua` (`ns.BUFF_KEY_COMMAND`, `ns.BUFF_KEY_MACRO` also feed the General panel).
- **Key moves at login:** `ns.MigrateSpellbookBinding` (Spellbook login) and `ns.MigrateBuffKeys` (`ns.SetupBuffDuty`) rebind with `SetBinding`, then `SaveBindings(GetCurrentBindingSet())`; both skip in combat and retry next login. The Buff Key's old `CLICK TFTBBuffIndividual:LeftButton` is deliberately not declared (an older Thanks for the Buff declares it; a duplicate warns every login); the old button name stays an alias, so a saved key still works.
- `ns:OpenKeyBindings` (the General panel's Set Key buttons, rows listed in `Options/Options-General.lua`) refuses in combat, then tries at click time: `Settings.KEYBINDINGS_CATEGORY_ID`; the Settings panel's category list searched by `KEY_BINDINGS` / `SETTINGS_KEYBINDINGS_LABEL`; `KeyBindingFrame` via `KeyBindingFrame_LoadUI`; else a `KEY_BINDINGS_LOCATION` chat line in the client's own menu labels. `Manifests-Enhanced-Spellbook.lua` has an API row per route.
- `UPDATE_BINDINGS` (always heard) calls `ns.RefreshSettings` and `ns.RequestBuffDutyRefresh` (the Buff Key tip shows only while that key is unbound).

**Globals that macros, bindings and secure clicks call** (macro `/run` lines can't see `ns`):

| Global | File | Does |
|---|---|---|
| `GtGFire(id, oocID)` | `Macros/Runtime.lua` | Stamps the item (the OOC one out of combat); an `ERR_ITEM_WRONG_ZONE` within a literal second prints `MESSAGE_BUG_REPORT` naming it |
| `GtGTip`, `GtGTipIf` | `Macros/Runtime.lua` | Tip from `ns.TIP_MESSAGES`, `ns.MISSING_SPELL_MESSAGE_IDS` or the built `noPetSkills`; `GtGTipIf` appends a `" 1"` sentinel to its conditional |
| `GtGNoItem(type, canMake)` | `Macros/Runtime.lua` | The no-item print, via `ns.BuildNoItemLine` (also the panel's Example) |
| `GtGReplace()` | `Macros/Runtime.lua` | Accepts the `REPLACE_ENCHANT` popup only |
| `GtGMute(on)` | `Enhanced-Spellbook/Mute-Errors.lua` | Zeroes the `MUTED_CVARS` that are on; restores exactly what it read, with a one-second backstop timer |
| `GoodToGo_ToggleSpellbook()` | `Enhanced-Spellbook/Key-Bindings.lua` | `Bindings.xml` toggle; calls `ns.ToggleSpellbookPage` if loaded |
| `GtGBuffKey` (frame) | `Buff-Duty/Buff-Duty-Keys.lua` | Hidden secure button the Buff Key clicks; `TFTBBuffIndividual` aliases it until its migration expires |

The `Connoisseur*` aliases of `GtGFire`, `GtGTip`, `GtGTipIf` and `GtGNoItem` stay until their migration expires, because macros Connoisseur & Restocker wrote still call them. Every global here is in `.luacheckrc` `globals`.

### Readiness Report

- Module `ReadinessReport`. `READY_CHECK` is subscribed only while `readinessReportEnabled` (`ns.SyncReadinessReportEvents`, at login and from the switch), independent of `macrosEnabled`. `ns.OnReadyCheck` goes silent while `ns.AreAurasSecret()`. No group test: a ready check never fires solo.
- `ns.BuildReadinessLines(inArena)` returns nil when nothing is wrong. It ignores the master switch, so Diagnostics renders it on demand.
- **Silence is the feature.** A category with nothing wrong prints nothing, and a clean character prints nothing at all. A switch may only ever add a line about something broken. Durability names each equipped item under the threshold, never an average, since one weapon near zero is what breaks mid-pull.
- Lines are `ns.ReadinessLine`s of `ns.ReadinessClause`s, each through `ns:PrintMessage`, `READINESS_TITLE` first. Lines are appended one at a time, never `ipairs` over a literal with holes.
- Gates (`ns.ReadinessAsks*`), shared with the Example: Well Fed answers to `readinessWellFed` alone; Scrolls to `readinessScrolls` while any `scrollTypes` type is ticked; Soulstone and Mana Gem need the class and its conjure known; Healthstone needs a Warlock in the group (`ns.GroupHasClass`); Pet Well Fed uses `ns.ShouldTrackPetFood`; Mana Potion needs `ns.PlayerUsesMana`; Flask only from TBC on (`ns.EXPANSION`).
- Buff lines read one `ns.GetPlayerBuffSnapshot`. Scrolls ask when a ticked type has no buff and no conflict at all, or `ns.FindMissingScrolls(ns.scannedItemCounts, snapshot)` finds a stronger scroll carried. Soulstone asks the group (`ns.GroupHasSoulstone`) and stays quiet while `ns.SoulstonesOnCooldown`.
- Item lines read the last scan (`ns.bestSelection`, with `ns.scannedIgnoredTypes` counting as carried) and are silent before the first scan. The Mana Gem line reads raw `ns.scannedItemCounts` against `ns.MANA_GEMS`, since runes can win the category.
- Weapon lines: `ns.GetMissingWeaponBuffs` (`Readiness-Report-Probes.lua`) over `ns.BuffDuty.ReadWeaponEnchants`. `ns.WEAPON_ENCHANTS_STACK` raises the wanted count to two on a hand `ns.BUFF_DUTY_WEAPON_HANDS` names, once a `ns.BUFF_DUTY_WEAPON_ENCHANTS` row is in level. A Shaman in the party (`ns.PartyHasClass`) waives the main hand, except where enchants stack.
- Expiring Soon (`ns.GetExpiringBuffs`) covers every helpful aura, skipping ones without a duration or whose whole duration is at or under the threshold.
- In an arena the buff, expiring and item clauses drop; the PvP clause also drops in battlegrounds.
- The panel (`Options-Readiness-Report.lua`): intro, switch, then rows built from `SECTIONS` (each hides with the switch, a threshold also with its own row), the Example (`ns.BuildReadinessSampleLines`), and Reset last. Reset is never hidden, grays while `ReadinessAtDefaults`, and writes every `readiness*` global default back except the master switch.

### Inventory Report

- **No module of its own.** `ns.inventoryEventHandlers` is dispatched by the Restocker's module (`Restocker-Events.lua`), only while `global.inventoryReport` is on, and subscribed through `ns.SyncRestockerEvents`. `ns.InitializeInventoryReport` runs from the Restocker's `PLAYER_LOGIN`, after `ns.InitializeRestocker`, existence-tested.
- Record: `global.inventory[ns.GetCharacterKey()]` holds `{ name, realm, class, guid, bags, bank }`, each place one line of `id:count` pairs sorted by ID. The Restock List reads `class` to color characters. At login another key with this GUID is dropped (rename or transfer), and this key with another GUID loses its bags and bank (a deleted namesake).
- Bags are read at `PLAYER_ENTERING_WORLD` and `BAG_UPDATE_DELAYED` (in combat only flagged, read on `PLAYER_REGEN_ENABLED`); a read with a 0-slot backpack is ignored. The bank is read on `BANKFRAME_OPENED`, again after `BANK_SETTLE_DELAY`, and on bag updates while open. Bank containers come from `ns.BankBagIDs` (`Features/Utilities.lua`).
- **The save writes only what was last read** (`bagCounts`, `bankCounts`): on Forever the containers can read empty at logout. Nil means never read, and the saved line stands. It runs from AceDB's `OnDatabaseShutdown` callback (`SaveSnapshot`), not `PLAYER_LOGOUT`, since AceDB's own logout handler runs first and strips `inventoryReport = true` as a default.
- `ns.ForgetRecordedCharacter` (the panel's Forget) drops another character's record and its `restocker.listChoices` entry, then `ns.ResetInventoryReportOthers`.
- The tooltip hooks after `TOOLTIP_HOOK_DELAY`, so its block lands under other add-ons' lines. It goes through `ns.AddItemTooltipPostCall` on `GameTooltip` and `ItemRefTooltip`; a weak-keyed set, cleared on `OnTooltipCleared`, blocks doubled calls. It shows this character live, then other same-realm characters (unpacked once per login). A zero total shows nothing unless the item has a Keep on the current Restock List.
  - Block shape (`ns.GetInventoryReportLines`): `REPORT_HEADER` (title gold, short name gray on the right, the Spellbook's tooltip-title shape), one double line per holder with this character first, then a Total row last. Count words in `LABEL_COLOR`, numbers white.
- The panel (`Options-Inventory-Report.lua`): switch (`ns.SetInventoryReportEnabled`, reads the bags at once when turned on), the Example (`ns.GetInventoryReportExampleItem`, drawn through `ns.GetInventoryReportLines(itemID, true)`, warmed with `ns.WarmItemCache`), Recorded Characters. Everything below the switch hides while it's off.

### Restocker

The feature is "Restocker"; its window is the Restock List; its starter popup is "Staples". In code Staples is still the "Starter List" (`Restocker-Starter-*.lua`, `ns.STARTER_LIST_CATEGORIES`, `ns.ShowStarterListPopup`). `/restock profile ...` and `RESTOCKER_*_PROFILE*` keys mean a Restock List, not an AceDB profile. "Keep" is the UI word for a row's `amount`.

#### Lifecycle

- Module `Restocker` (`Restocker-Events.lua`). One handler per event in `ns.restockerEventHandlers`, all wrapped in `WhileEnabled` except `PLAYER_LOGOUT`. A second use of an event calls from its existing handler: `ns.OnRestockerEnteringWorld` runs the arrival check, the Staples trigger and the upgrade catch-up.
- `EVENTS` is the union of the Restocker's and the Inventory Report's; `ns.SyncRestockerEvents` subscribes each only while a switched-on feature has a handler (`ALWAYS_EVENTS`: login, logout). `PLAYER_REGEN_ENABLED` is the Inventory Report's alone. `GET_ITEM_INFO_RECEIVED` is not in the table: `Features/Item-Info.lua` hands it to `ns.OnRestockerItemInfoReceived`.
- No combat guard on the dispatcher: nothing touches a protected function, and a mid-combat logout must still pack.
- Login (`ns.InitializeRestocker`, `Restocker-Core.lua`): `ns.restockSettings = ns.db.global.restocker`, row pools and `ns.restockHiddenFrame`, `ns.InflateSavedRestockItems`, `ns.InitializeCharacterRestockList`, `ns.PruneEmptyOrphanRestockLists`, `ns.InitializeRestockerEvents`, `ns.InitializeRestockBagDefinitions`, `ns.SetupCraftingRecipes`, `ns.CreateRestockWindow`; then the dispatcher runs `ns.InitializeInventoryReport` and `ns.SyncRestockerEvents`. `ns.restockSettings` is an empty table until then, so option getters index something.
- Logout (`ns.OnRestockerLogout`): `ns.SaveRestockWindowGeometry(true)` (size only, so a never-dragged window keeps no spot), then `ns.DeflateRestockItemsForSave` (every row is a string from then on), then `currentList = nil`.
- `ns.SetRestockerEnabled` (reached through `ns.FEATURES`' `apply`, `Options/Options-Feature-Switches.lua`): on arms the reminders silently (`ns.ArmRestockerReminders`) and runs the upgrades; off closes Staples, ends any bank or merchant visit (`ns.EndRestockBankVisit`, `ns.EndRestockMerchantVisit`: no `_CLOSED` reaches a sleeping handler) and hides the window. `ns.ShowRestockWindow` / `ns.ToggleRestockWindow` print `RESTOCKER_DISABLED` while off; `/restock` refuses every subcommand but `help` and `config`.

#### Inventory Report riding the module

- `ns.inventoryEventHandlers` (`Inventory-Report-Recording.lua`) is dispatched after the Restocker's handler for the same event, only while `ns.db` exists and `global.inventoryReport` is on. Its switch (`ns.SetInventoryReportEnabled`) calls `ns.SyncRestockerEvents`. A Restocker event change can therefore change what the report hears.

#### Lists and Choices (`Restocker-Saved-Lists.lua`)

- Lists live at `global.restocker.lists[name][itemID]`. Each character's choice is `listChoices[<profile name>]` on global, so two characters sharing a profile keep their own lists and Reset Profile can't empty a hand-built list (README-Notes exception). `OwnCharacterKey` asks `ns.GetCharacterProfileName()` before `ns.db.keys.char`, which can be AceDB's placeholder.
- `ns.UseRestockList` is the single write point for `currentList` and the choice; it also clears New flags, undo, group selection and scroll.
- A fresh character gets its class name via `FreeClassListName`, numbered (`RESTOCKER_LIST_NAME_NUMBERED`) rather than joining another character's list. `IsListNameTaken` counts existing lists and names other characters still point at, because `ns.InitializeCharacterRestockList` recreates a missing chosen list at their login.
- `ns.GetRestockListNames` is the one A-to-Z order (selector menu and delete landing). `ns.GetRestockListUsers` lists a list's characters with class tokens (`ns.GetClassesByProfileName`), this character read from the client and the placeholder key skipped; `othersOnly` for the confirms.
- New List (`ns.CreateRestockList`) and Copy (`ns.CloneCurrentRestockList`) switch to the made list, snapshot its rows (`madeList`) and open the rename told the previous list. Escape or Cancel calls `ns.DiscardMadeRestockList`, which deletes it only while its rows equal the snapshot, then `ns.SwitchRestockList(previous)`.
- Delete lands on `ns.GetRestockListAfterDelete` (top list, maybe another character's; the confirm names it) through `ns.UseRestockList`, not `ns.SwitchRestockList`, and stops any bank run. Deleting the last list makes a fresh class-named one, named after the old name is freed.
- `ns.SwitchRestockList` refuses a missing name, restarts an open bank run, and rebuys at an open merchant (`ns.ResetMerchantRestockThrottle` + `ns.RestockFromMerchant`) unless Shift skipped the visit. The rebuy waits behind `ns.AfterMerchantBuysLand`, since a run counts only what is already in the bags.
- `ns.CopyIntoCurrentRestockList` replaces the list in use wholesale. Rename re-points every character's choice to the new name.

#### Saved Format (`Restocker-Saved-Format.lua`)

- Each row packs to `"itemName, amount, stash, fromBank, buy, reaction, upgrade, buyExtra"` at logout and inflates at login. No item ID (the key is it), no item type (read live by `ns.GetRestockItemTypeName`).
- Every field is always written. Data starts at the first numeric field; the leading name is a label never read back (inflate nils `itemName`), and `ns.RefreshRestockItemName` supplies the live name.
- `buy` and `upgrade` are nil-means-on; `buyExtra`, `stash`, `fromBank` nil-means-off. A new field is a new trailing field with its own default; no version stamp.

#### Adding and Removing (`Restocker-List.lua`)

- `ns.AddRestockItem` takes an ID, a name or a link. New rows: one stack, Buy/Store/Take on, Extra off; flagged New, New group selected, scrolled to top. Refusals go through `ns.ShowRestockAddNotice` (the add box's placeholder while the window is open, chat otherwise). A cold item parks under its numeric ID in `ns.restockItemWait`.
- `ns.RemoveRestockItem` keeps `ns.restockLastRemoved = { item, listName }`; the row stays drawn in place, grayed, with Undo where its remove button was (`ns.UndoRestockRemove`). One step deep. Dropped when the render's `ListSignature` (every row field but `itemName` and tables, plus filter and category) changes, on `ns.ClearRestockNewItems`, and when Staples opens (`ns.ForgetRestockRemoval`).
- Four queues wait on item data: parked adds, `pendingUpgrade`, pending Staples ticks, `ns.restockColdRows`. `ns.SyncRestockItemInfoSubscription` holds the `"restocker"` waiter only while one is non-empty. A `false` answer drops the upgrade target and Staples tick and tells a parked add.

#### Merchant (`Restocker-Merchant.lua`, `-Merchant-Report.lua`, `-Purchase-Space.lua`, `-Crafting-Reagents.lua`)

- `MERCHANT_SHOW` sets `ns.merchantIsOpen`; Shift sets `ns.merchantBuyingSkipped` and skips. `ns.RestockFromMerchant` returns on an empty list or within the literal doubled-show throttle; it first reports any run still waiting (`ns.ReportPendingMerchantRun`).
- Reagent order (`ns.BuildCraftingPurchaseOrder`): recipes from `ns.POISON_RECIPES` (`ns.SetupCraftingRecipes`), Buy rows only, bags only. A reagent the list also keeps has its Keep taken off the bag count first, so the merged order is Keep plus crafts. Gated all-or-nothing (`VendorStocksAllReagents`); `RESTOCKER_REAGENTS_SKIPPED` only when the vendor stocked some.
- One order per Buy row, bags counted by item ID, gated by the vendor's reaction (`UnitReaction("npc")`) against the row's `reaction`. Extra rows get an order even at zero owed.
- Budget: `GetMoney()` less the Gold Reserve, plus a `ns.NewBagSpace` snapshot spent down by `ns.ClaimBagSpace` (partial stacks, then a matching specialty bag, then a general bag). Both are spent locally, because nothing changes until the server answers.
- `PurchaseMerchantItem` buys in stack-sized chunks (capped by `GetMerchantItemMaxStack`, which also stands in for a cold item's stack), prices per batch quantity, skips unpurchasable and extended-cost slots, caps at a limited slot's stock and lets Extra take a limited slot's whole stock (nothing on an unlimited slot). It counts units, not calls, and never sells.
- The report waits for delivery: `ns.AwaitMerchantRun` parks `pendingRun` until `ns.SettleMerchantBuys` (`BAG_UPDATE_DELAYED`) sees every order's units or `BUY_SETTLE_TIMEOUT`, and reports units delivered against `startCount`. Out-of-gold (`ns.BuildOutOfGoldLine`, names the reserve when the purse started at or under it) and bags-full lines follow. The close reminder waits behind it (`ns.AfterMerchantBuysLand`).
- `ns.merchantIsOpen` is the hard gate the bank run reads. `ns.REPUTATION_STANDINGS` discounts are labels only; the reaction gate is the only enforcement.

#### Bank Run (`Restocker-Bank-State.lua`, `-Bank-Visit.lua`, `-Bank-Moves.lua`, `-Bank-Tidy.lua`, `-Bags.lua`)

- On `BANKFRAME_OPENED` (Shift skips the whole visit), `ns.StartRestockBankRun` reloads the bank bags every time (`ns.LoadRestockBankBags` over `ns.BankBagIDs`, `Features/Utilities.lua`, shared with the Inventory Report; on Forever the `C_Bank` tabs bought) and calls `ns.RestartBankRestock`. An empty list starts nothing and stops a run already going.
- `ns.RestartBankRestock` builds a fresh `RestockState` and coroutine; a restart within the same visit carries `overshotItems` and `movedAny` over.
- An OnUpdate ticks at `ComputeUpdateInterval()` (a multiple of the higher ping with a floor, both literals). Lock gate: waits while one of the list's items is locked, for at most `MAX_STUCK_STEPS` ticks (`lockedTicks`), then resumes so the cursor clear and the watchdog can act.
- Each step of `RunRestockLogic`:
  1. Aborts while `ns.merchantIsOpen`. Reloads the bank bags while the run holds none (Forever's tab list can be empty at open).
  2. Rescans (`RestockState:Rescan`). A foreign item on the cursor is waited out for `MAX_STUCK_STEPS`, then cleared; our own is cleared at once.
  3. In-flight gate: waits up to `MAX_INFLIGHT_STEPS` while a bag-plus-bank total has dropped.
  4. Watchdog: stops with `StuckMessage` after `MAX_STUCK_STEPS` with remaining work unchanged. Work that grew counts as change.
  5. One move: stash first while `ns.BankHasRestockSpace()` (a free general slot), else pull first. A pull after a stuck step overshoots with a whole stack (`overshotItems`), stashed back even without Store.
  6. Never finishes inside `BANK_SETTLE_DELAY`, since the bank may still read empty.
- Keep amounts freeze per run (`RestockState:Wanted`). Reopening the bank, Enter in a Keep box or any list change restarts the run.
- Placement names an empty slot (`BagDefinition:PutCursorItem`), which leaves the cursor alone so the caller can try the next bag; merge onto a partial stack is the last resort; a failed placement ends in `ClearCursor()`. Withdrawals take whole stacks first (`UseContainerItem`), splitting only the remainder; deposits pick candidates across all bags smallest first.
- Tidy phase, every list item whatever its toggles: merges partial stacks within the bags, then within the bank, never across, until `ns.CountRestockPartialStacks` stops falling. `RESTOCKER_COMPLETE` prints only if something moved.
- `ns.restockPlayerBags` are where items may be put; `ns.restockCountedBags` adds the reagent bag (`ns.GetReagentBagID`) for counting, locks and stashing.
- A coroutine error prints `RESTOCKER_STOPPED_ERROR` and stops; reopening the bank retries.
- No manual trigger in Diagnostics, on purpose: that panel is read-only. `ns.RestockerDebug` writes `TRACE_*` lines (`ns.DiagnosticsStrings`) to the Event Log only while logging.

#### Shortfall and Reminders (`Restocker-Shortfall.lua`, `-Reminders.lua`, `-Town-Reminder.lua`)

- Bags only, by item ID, everywhere. `ns.IsRestockItemShort` is the one test (Keep 0 is never short), and drives the Keep mark.
- Which list feeds which surface:
  - `ns.BuildRestockShortfallList`: every short row, Buy on or off, sorted by live name. Split by `ns.BuildRestockReminderLists` into out (none in bags) and low (below `restockLowThreshold`, one of `ns.RESTOCK_LOW_THRESHOLDS`); rows at or above the line are never mentioned. Feeds every reminder and the mini-map menu, so the two never disagree. Unsplit, it feeds the footer tooltip.
  - `ns.CountRestockOrders`: the footer's (orders, short) in one pass, by the same rules.
  - `ns.BuildGroceryList`: short Buy rows, no reagents, no reaction gate. Read only by Diagnostics.
  - The merchant run ignores the threshold.
- Each reminder has a mode key (`restockReminderMode`, `merchantReminderMode`, `bankReminderMode`): `ns.REMINDER_SIMPLE` prints the headline only, `ns.REMINDER_VERBOSE` adds a line per out item, then low item (`ns.BuildRestockShortfallLines`, also the panel's Examples). Headlines: `ns.RestockTownHeadline` (nudge + counts), `ns.RestockClosingHeadline` ("still" form), both on `ns.RestockReminderCounts` / `COUNT_KEYS`.
- Closing reminders (`ns.RemindRestockShortfallAfterVisit`) wait `SETTLE_DELAY`; the merchant's waits for its buys first, and the bank's fires only if that visit's run started.
- Town reminder (`Restocker-Town-Reminder.lua`):
  - Fires on a not-resting to resting edge, from `PLAYER_UPDATE_RESTING`, `PLAYER_ENTERING_WORLD` (no resting event follows a loading screen) and `PLAYER_CONTROL_GAINED` (landing, after `ARRIVAL_SETTLE_DELAY`). A taxi counts as not in town.
  - Does nothing until armed. Login requests the list's cold items, then checks after `LOGIN_SETTLE_DELAY`; a `/reload` arms silently after `ARRIVAL_SETTLE_DELAY`; other loading screens check after `ARRIVAL_SETTLE_DELAY`. Delayed checks re-test loaded, armed and the master switch.
  - `REMINDER_COOLDOWN` runs from the last reminder printed. `restockReminderSound` plays `ns.RESTOCK_ALERT_SOUND` only with the chat line.

#### Upgrades (`Restocker-Upgrade.lua`)

- `ns.CONSUMABLE_UPGRADE_CHAINS` tiers are sorted by rank (third field) in place at load and indexed in `UPGRADE_INDEX`. A row moves only forward to the best tier at or below the level; merging into an existing row sums amounts. Each swap prints a line naming both tiers.
- Runs on `PLAYER_LEVEL_UP` with the event's level, as a catch-up on `PLAYER_ENTERING_WORLD`, on switching the Restocker on, and on item answers while pending. A cold target parks as `pendingUpgrade`; a target the server refused (`failedTargets`) is never waited on.
- `ns.CanUpgradeRestockItem` (a ladder of more than one tier) decides whether the Upgrade cell applies. `ns.BestChainItemID` is what Staples adds through, so a tick starts on the tier the upgrader would pick.

#### Staples (`Restocker-Starter-Categories.lua`, `-Starter-List.lua`, `-Starter-Sections.lua`, `-Starter-Window.lua`)

- Rows: `ns.STARTER_LIST_CATEGORIES`, holding no game IDs; `classes` decides who is offered a row, `defaultFor` who gets it pre-ticked; `maxStacks` or `choices`, `defaultStacks`, `countsItems`, `fixedAmount`, `namesFirstTier`, `label` shape the dropdown and name.
- At load `Restocker-Starter-List.lua` resolves each `chainKey` through `CHAINS_BY_KEY`, sets `row.chain` and nils `chainKey`, mutating the table; rows whose ladder the flavor lacks drop.
- A row is offered when its class matches and its ladder has an item at the player's level. A tick adds the best tier with the hand-add defaults; unticking removes every tier and cancels a pending tick. Picking a stack count on an unticked row ticks it. The count's home is the listed row's amount while ticked, `selectedStacks` (session) otherwise.
- Display order is computed (`SectionCategories`): dropdown rows first, fixed-amount after, A to Z by shown name, cold names last. `OfferedSections` builds food-and-water, poisons (with note), ammo, reagents; empty sections drop.
- Login trigger, fresh logins only (`ns.OnStarterListEnteringWorld` then `ns.MaybeShowStarterListPopup`): after `STARTER_POPUP_DELAY`, at `STARTER_MIN_LEVEL` or above, on an empty list, something offered, out of combat, not while `ns.IsLegacyImportPending()`. It pre-ticks the `defaultFor` rows, then opens Staples alone (`ns.ShowStarterListPopup(true)`); Done opens the Restock List and the footer hint names the command, on that route only. No don't-show-again: the pre-ticks fill the list.
- Window: `GoodToGoStaplesFrame` on the shared portrait frame, DIALOG strata, height fitted to content between `WINDOW_MIN_HEIGHT` and `WINDOW_MAX_HEIGHT`, intro text by route (`IntroText`). Cold items warm through `ns.WarmItemCache` and repaint once per frame. Stack dropdown: a `UIPanelButtonTemplate` button opening the Restock List's kit menu (`ns.RestockMenu:Open(…, "click")`, rows from `ns.RestockChoiceRow` via `StacksEntries`; it hides its own tooltip first), never `WowStyle1DropdownTemplate` or the game's context menu (the maintainer's choice). Height snaps up to `HEIGHT_STEP`. Position: `staplesPosition`, written whole on drag stop, centered until then (`PlaceWindow`); `ns.HasSavedStaplesPosition` / `ns.ResetStaplesPosition`. While open it takes the Restock List off `UISpecialFrames` and hands it back a frame after it hides; OnHide clears New flags and redraws.

#### Window

- A hand-built portrait frame shared with Staples (`Restocker-Window-Frame.lua`, `ns.RESTOCK_WINDOW_BANDS`). Header bar (`Restocker-Window-Header.lua`): filter at left; at right Pick Staples, with Add, the add box and the bag menu chained leftward off it. Footer: list controls at left (`-List-Bar.lua`, `-List-Manage.lua`), status line at right (`-Footer.lua`). The "Used by" line truncates and ends short of the status (`ns.SetRestockUsersLineEnd`). Both footer runs sit a fixed step up from the window's bottom edge (`FOOTER_Y`, the list bar's `bottom`), not centered in the footer band. The column header is a fixed `ns.restockColumnHeaderHeight`: the group bands' line over a `CAPTION_HEIGHT` caption tier (`Restocker-Window-Column-Header.lua`), not sized from the font.
- An item dropped anywhere joins the list: every control goes through `ns.SetRestockControlClick` (or calls `ns.AddRestockItemFromCursor` itself), and that always clears the cursor. No Shift+Click insert: that routes through `ChatFrameUtil.InsertLink`.
- `ns.UpdateRestockList` (`Restocker-Window-Render.lua`) is the full redraw. It closes the kit menu and bag menu first (pooled rows rebind), drops a stale removed row, calls `ns.RequestUpdate` when membership changes and `profile.useRestockLast` is on, watches cold rows only while shown, keeps a Keep box's focus on the item being typed, and records `ns.GetRestockShownItems` (removed row excluded) for the column menus. `ns.RefreshRestockShortfall` repaints only Keep marks and status.
- Groups are keyed by classID via `C_Item.GetItemInfoInstant`, which needs no item cache, or the sentinels `GROUP_NEW` / `GROUP_OTHER`. The filter (2+ characters) matches name, type or ID, folds Latin and Cyrillic capitals and counts UTF-8 characters; New rows always pass. The category pane counts after the filter and keeps a selected group at zero.
- `COLUMNS` (`Restocker-Window-Columns.lua`) drives header and rows through one walk (`ns.LayoutRestockColumns`); widths are measured from the captions (and standings, and Keep digits in `ChatFontNormal`), re-applied by `ns.restockColumnWidthSerial`. Cells (`Restocker-Window-Cells.lua`) read `COLUMN_STATE`; Extra and Rep are not applicable with Buy off, Upgrade without a ladder. A heading's menu sets that column on every shown row where it applies (`COLUMN_SET`).
- Menus: one Menu-Kit menu, `ns.RestockMenu` (`Kit.CreateMenu`, `publish = false`, FULLSCREEN_DIALOG), shared by the reputation, column, list, Manage Lists and Staples stack-size menus, `menu:Open(anchor, entries, onClose, upward, how)`; every caller passes `how = "click"`, so the kit's longer click close delay applies (hover is the default). Hung `MENU_GAP_POINTS` under its anchor or over it (footer menus open upward); it closes on hover-out, Escape, a pick (`closes` added to every `onClick` entry unless `keepOpen`), window hide and redraw. Choice rows with a right column come from `ns.RestockChoiceRow` (VALUE color when picked); a column menu row with nothing to set is `disabled`. The bag menu is the window's one AceGUI `Dropdown-Pullout` (it scrolls), plated by `ns.MenuKit.PlatePullout`; each item shows its carried count and its own tooltip. `ns.CloseRestockMenus` closes all of them. Never `UIDropDownMenu`.
- The list selector and bag menu are read-only `InputBoxTemplate` fields (`ns.CreateRestockMenuField`), not AceGUI Dropdowns: ElvUI's AceGUI skin would move the geometry neighbors anchor to.
- Confirms: Delete (`GOODTOGO_RESTOCKER_DELETE_LIST`, names others on the list and the landing list) and slash Copy (`GOODTOGO_RESTOCKER_COPY_LIST`) carry their list names as popup data.
- A visit opens the window only with `autoOpenAtMerchant` / `autoOpenAtBank`, and closes it only if that visit opened it (`ns.restockWindowOpenedByVisit`). Geometry (`framePosition`) is written whole on drag stop and resize, size only at logout; until a spot is saved `PlaceFrame` puts the window at the right edge. `ns.HasSavedRestockWindowPosition` / `ns.ResetRestockWindowPosition` (keeps the size). `MIN_WIDTH` is built on the category pane's cap.
- The Keep box saves on every keystroke; an emptied box saves nothing and leaving it restores the amount it held at focus. Typing 0 keeps none in the bags (with Store, all to the bank). Enter restarts an open bank run.

#### Slash Command (`Restocker-Slash-Command.lua`)

- `ns.HandleRestockerCommand` (from `Options/Options.lua`): bare `/restock` toggles the window; `show`, `config`, `help`, `profile add|delete|rename|copy|use <name>`. `delete` and `copy` ask through the window's confirms; names in `NAMES_EXISTING_LIST` must exist. An unknown word prints `RESTOCKER_SLASH_UNKNOWN` and help. Help opens with `RESTOCKER_HELP_TITLE`, printed once. Subcommand words stay English.

#### Options (`Options/Restocker/Options-Restocker.lua`)

- `ns.BuildRestockerOptions`: description, `Kit.FeatureSwitch("restockerEnabled")`, Gold Reserve (toggle, amount from `ns.GOLD_RESERVE_AMOUNTS`, Example via `ns.BuildOutOfGoldLine`), Reminders (threshold row hidden while all three are off; three toggles with Simple/Verbose rows, `ReminderModes` + `REMINDER_MODE_ORDER`; in-town sound row; Examples through `ns.BuildRestockShortfallLines` on `ns.SAMPLE_RESTOCK_ITEM_ID`), window auto-open toggles, two Reset Position rows (Restock List, Staples), each grayed while nothing is saved. All settings read through `ns.restockSettings`.
- `Kit.HideAllExcept` wraps every arg's `hidden` so only the description and switch show while the Restocker is off.

### Buff Duty

#### Load Order

- Same order in all four TOCs: Events, Icon-State, Party-Buffs, Icons, Layout, Frame, Button-Attributes, Position, Castable, Lookups, Settings, Auras, Units, Resurrections, Pets, NPCs, Weapons, Elixirs, Self, Favors, Asks, Outsiders, Other-Classes, Groups, `Buff-Duty.lua`, Switches, Cast-Results, Key-Picker, Keys, Options-Menu. Options: Utilities, then the main panel, Buffs, Self-Buffs, Weapon-Buffs, Consumables.
- Drawing files load before `ns.BuffDuty` exists (Castable creates it) and never touch it at load.
- Load-time captures: Icons takes Icon-State's pool; Layout takes Icons' and Party-Buffs' acquire/set functions; Frame takes Icon-State's update functions and `ns.buffDutyLayout`; logic files take Castable's tables, `RankFor`, `KnownRanks`; Pets takes Auras' `Has` and Units' `SingleIcon`/`CountsAsTank`/`IsPhaseShifted`; NPCs takes Pets' `IsHeld`; Outsiders and Groups take `PetRow`; `Buff-Duty.lua` takes `HasAnythingToOffer`, `PetUnitOf` and the dirty markers. Options-Menu creates its one Menu Kit menu at load (needs `Features/Menu-Kit.lua` earlier) and defines `ns.SCROLL_TYPE_LABELS`, which the Scrolls page and `BuffDuty.RowExists` read. Icon-State, Weapons, Cast-Results, Events and `Buff-Duty.lua` call `ns.SetBuffDutyEventHandler` at load.
- Call-time lookups on purpose: Key-Picker reads `BuffDuty.BuffKeySkipped` (Keys loads after it); Auras calls `BuffDuty.PrunePetHolds` / `PruneNPCCycles`; Self calls `BuffDuty.GlobalCooldownEnd` (Key-Picker) and `BuffDuty.AddElixirIcons` / `ElixirsMissing`; Frame calls `BuffDuty.CastOrder` (Key-Picker); Icons and Icon-State call `BuffDuty.AskedAt` (Asks); Outsiders calls `BuffDuty.TargetAskRow`; Groups calls `BuffDuty.GroupChoices`; `NoteResurrect` checks `ns.RequestBuffDutyRefresh` exists.
- `BuffDuty.soulstoneEntry`, `soulstoneBuff` and `resurrection` are replaced, not refilled: read them off `BuffDuty` each time. `entries`, `buffs`, `selfBuffs`, `selfItemBuffs`, `weaponBuffs` and the lookups are wiped and refilled in place, so capturing them is safe.

#### Events and Flow

- Module `BuffDuty`; one handler per event via `ns.SetBuffDutyEventHandler` (`Buff-Duty-Events.lua`). Handlers live with their data: `SPELL_UPDATE_COOLDOWN` in Icon-State, `REPLACE_ENCHANT` in Weapons, `UI_ERROR_MESSAGE` in Cast-Results, roster/pet/target/spells/inventory/bags/regen in `Buff-Duty.lua`, the rest (aura, cast succeeded, power, combat log, login, entering world) in Events.
- **Two predicates** (`Buff-Duty-Switches.lua`): `ns.IsBuffDutyTrackingForClass()` is `buffWindow.enabled` plus your class not unticked in `showClasses`; `ns.IsBuffDutyOnForClass()` adds the unsaved `hiddenThisSession`. `ns.IsBuffDutyHiddenThisSession()` (a close in force while Tracking holds) is what the mini-map menu shows as Paused and the context report as `closedThisSession`. `WINDOW_EVENTS` (`ns.UpdateBuffDutyEvents`), the backstop (`ns.SetBuffDutyWatching`), the aura handler and the combat-log sync follow Tracking, so a closed window keeps fresh auras for the key. `Refresh` and the mini-map toggle (`ns.SetBuffDutyForClass`, Left-Click and the menu row) use OnForClass.
- Always on: `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, both regen events. `UNIT_INVENTORY_CHANGED`, `UNIT_SPELLCAST_SUCCEEDED` and `UNIT_POWER_UPDATE` are player-only (`EVENT_UNITS`); `UNIT_POWER_UPDATE` is subscribed for warriors only (Bloodrage first reads rage). `UNIT_FLAGS` is a window event: `OnUnitFlags` keeps a PvP flag per watched unit (player, target, party, raid) and refreshes only when one flips. `UPDATE_BINDINGS` arrives through the `KeyBindings` module (`Features/Key-Bindings.lua`), which calls `ns.RequestBuffDutyRefresh` for the key tip.
- **Combat log** (`SyncCombatLog`): off Camelot only (`READS_COMBAT_LOG`), and only while Tracking and (`favorEnabled` or `BuffDuty.resurrection` known). Re-synced with the window's events and on `SPELLS_CHANGED` (`ns.SyncBuffDutyCombatLog`).
- `UNIT_AURA` is unfiltered: `ns.OnBuffDutyUnitAura` drops anything outside `WATCHED_UNITS` before the class check, and does nothing in combat. On Camelot the player's own `UNIT_AURA` also feeds `ns.NoteFavorFromAuras` once ready.
- `Data.SAFETY_PAUSE` after every `PLAYER_ENTERING_WORLD` (`StartSafetyPause`, token-voided, read by `ns.IsBuffDutyReady`): login and loading screens replay auras as new, so combat-log resurrects/favors and Camelot's aura favors wait.
- `ns.SetupBuffDuty` once at login: `BuildLookup` (drops spell IDs the client lacks), `ns.buffDutyCategories` and `ns.buffDutySelfCategories` (self entries, every group-buff entry, the Soulstone; `selfItemEntries` (self items, Well Fed, Scrolls, Elixirs) are their categories' own), `ns.PopulateBuffDutyAudience`, `BuildBuffs`, `ns.CreateBuffDutyFrame`, the settings apply, `ns.MigrateBuffKeys`, `isSetUp`, a refresh, `ns.UpdateBuffDutyEvents` (which starts the backstop and runs `OnSpellsChanged`).
- `ns.RefreshBuffDuty` is every panel and menu setter's entry: `BuildBuffs`, settings apply, `MarkAllAurasDirty`, refresh, `ns.UpdateBuffDutyEvents`, `ns.RefreshSettings`. `ns.ApplyBuffDutyProfile` (from Core's profile callbacks) re-populates then refreshes: `buffWindow` is account-wide, but `scrollTypes` rides the profile.
- **`Refresh`** (debounced by `ns.RequestBuffDutyRefresh`, `REFRESH_DELAY`) refuses in combat. It hides the window when OnForClass fails, `HasAnythingToShow` fails (nothing castable, Party-Buffs not watched (`WatchesPartyBuffs`: grouped and `askOtherClasses`) and target asks not watched (`WatchesTargetAsks`: `targetEnabled` and `askTarget`)), or `ShowsHere` fails (Group Contexts). While `ns.AreAurasSecret()` it hides and warns once (`BUFF_DUTY_AURAS_HIDDEN`). Otherwise, under `BuffDuty.HoldGroupMembers(true)` (one roster read per redraw):
  1. `BuffDuty.BuildSections`: sets `refreshSeconds` from `refreshMinutes` and `inShadowform`; your category sections (`AddSelfSection`), then Target and Return the Favor (`AddOutsiderSections`), then one section per subgroup (`AddGroupSections`).
  2. `BuffDuty.BuildOtherClassBuffs` (Party-Buffs).
  3. `ns.RenderBuffDuty(sections, otherBuffs)`. Party-Buffs alone keeps the window up.
- Build and render each run under `xpcall(…, geterrorhandler())`: an error hides the window rather than leave buttons that cast at whoever `target` names now.
- `BuffDuty.ShutOut(buff)`: while in Shadowform (`SHADOWFORM_SPELL_ID`, read once per build) a `noShadowform` buff or resurrection gets no icon.
- **Target change** out of combat: `ns.DropBuffDutyTargetIcons` strips and hides every icon aimed at `target` / `targetpet` (ask icons included), then `Refresh` runs at once, skipping `REFRESH_DELAY`. In combat it only dims.
- **Backstop** (`BACKSTOP_INTERVAL`): prunes the aura cache and requests a refresh, for expiries, deaths, disconnects and zone changes that send no event.
- `BAG_UPDATE_DELAYED` / `UNIT_INVENTORY_CHANGED` request a redraw (self items, scrolls, elixirs, weapon items read the bags live). Buff food arrives separately: the consumables scanner (`Scanner-Inventory.lua`) calls `ns.RequestBuffDutyRefresh` when `ns.bestBuffFoodID` changes.

#### The Window (`Buff-Duty-Frame.lua`, `-Layout.lua`, `-Icons.lua`, `-Icon-State.lua`)

- Two frames: `anchor` on `UIParent`, owned by the Hide in Combat state driver, and `content` (Menu Kit plate via `Kit.AddPlate`, drag, the kit's window header via `Kit.AddWindowHeader`, Options line, key tip) shown and hidden by the add-on out of combat only.
- **Window Opacity** (`buffWindow.windowOpacity`, choices `Data.BUFF_DUTY_OPACITY_CHOICES`): `ns.ApplyBuffDutyOpacity(preview)` sets the alpha of `content.menuKitPlate` alone, so text and icons stay solid; the plate isn't secure, so it works in combat. Applied once at `ns.CreateBuffDutyFrame`, then only by the Options menu. Its only home is that menu: no panel row.
- Sections are plain tables `{ kind, label, icons, rows, grid?, menu?, missing?, party?, subgroup?, foldable?, folded? }`; only the frame files draw. Kinds: `self` (one per category), `target`, `favor`, `party`. Rows: `{ label, icons, pet?, npc?, grid?, indent?, menu? }`.
- **Packed lines**: `self`, `target` and `favor` lines (`CAST_ORDER_KINDS`) line their icons up side by side against the right edge in the Buff Key's order (`CastRanks` from `BuffDuty.CastOrder`, `InCastOrder`), the next cast leftmost, with no column gaps. Party lines keep their grids.
- **Category lines**: a line with `menu` gets a name button and an arrow button in a right column (`Layout.ARROW_SPACE`), both opening `ns.ShowBuffDutyMenu(owner, menu)`; Weapon Buffs' hand rows carry `"weapons:"..hand`. Pooled per menu key, released with the icons (`Layout.ReleaseMenuButtons`). A `missing` line shows `BUFF_DUTY_MISSING_INVENTORY` (OFF color) at its right, which widens the content.
- `Signature()` strings everything a redraw writes (fold state, Party-Buffs' recipients and hover names, each icon's PvP hold, menu keys and missing flags included), plus `|?keyHint` while the key is unbound; an unchanged one skips the redraw. `RosterKey()` (raid/party plus member count) changing drops the held layout.
- **Held layout** (`Layout.held`): grid columns ever used, widest name column, most Party-Buffs icons, so the window keeps its width as buffs land. Dropped on hide, roster-key change and `ns.ApplyBuffDutySettings`.
- **Grids**: one column per buff (`buff.column`, numeric, sorted), so a party's group icon sits over the single one it replaces; only used columns are kept. Own grids: each category (`"self_" .. row`), each weapon hand (`"weapon" .. hand`), the Ask row (`"ask"`), Party-Buffs (`PARTY_BUFFS_GRID`). Resurrection uses `RESURRECTION_COLUMN`, left of every buff; scroll and elixir icons sit at fractions of their entry's column.
- Layout: names measured first (`MIN_NAME_WIDTH`..`MAX_NAME_WIDTH`, snapped to `NAME_STEP`); top sections run down, the Party-Buffs header (`BUFF_DUTY_ASK_OTHERS`) placed before the first non-self section; parties go `PARTIES_PER_ROW` to a row, `COLUMN_GAP` apart. Width rounds up to `WINDOW_STEP`, at least `MIN_WINDOW_WIDTH` and never narrower than title plus close button; the rounding's extra goes to the names with one window column, else to the gap between parties. Height rounds up to `WINDOW_STEP` too, the extra going above the Options divider so the foot keeps `PADDING`.
- **Foot**: the kit's divider and Options line (`Kit.AddOptionsLine`, `BUFF_DUTY_MENU_OPTIONS`), `FOOTER_HEIGHT` high and reaching `FOOTER_INSET` past the text on each side; its hover or click calls `ns.ShowBuffDutyOptions(self)`; works in combat. While `ns.BUFF_KEY_COMMAND` is unbound, `SECTION_SPACE` then `KeyHintText` (`BUFF_DUTY_KEY_TIP`) ends the window, wrapped to its width, never widening it.
- **Raid folding** (`Buff-Duty-Groups.lua`, fold buttons in Layout): in a raid every party section is `foldable`, folded until its header is clicked (`BuffDuty.ToggleGroupFold`, ignored in combat). `unfolded` lasts the session, wiped by `BuffDuty.ResetGroupFolds` when a roster update finds you out of a raid. Both kinds show only `GroupChoices`' picks. Folded: `GroupChoices` runs on the party's rows before folding drops them, then `FoldedIcons` adds one counted single per other buff a member needs (Thorns, or a group buff not worth casting; one member's own cast, in range if any), rows only resurrections. Unfolded: rows lose the singles the picks cover (`UncoveredRows`). Raid group icons carry `count` (red, centered) and `needs` (tooltip names). Fold buttons forward drags to `content`'s drag scripts.
- **Icons** are pooled `SecureActionButtonTemplate` buttons registered `AnyUp` and `AnyDown`. PreClick (left button): an ask whispers on the up half (`ns.AskTargetForBuffs`) and returns; a `spec.pvpFlagged` icon prints `BUFF_DUTY_PVP_FLAGGED` on the up half and returns; otherwise `ns.ExpectReplaceEnchant` for `confirmReplace` specs and `ns.NoteBuffCastAttempt`. PostClick's right-button up half dismisses a favor (`ns.DismissFavor`). An ask icon wears `askMark`.
- **Icon tooltip** (`OnIconEnter`, anchored by `ns.SetTooltipOwner`): the spell or item, a spacer, then a gold heading: `spec.sectionTitle` (stamped by `TagSection` in `ns.RenderBuffDuty`: the section's label, but nil on a party's rows) else `spec.targetName`, so a party member's icons go by their name. `spec.needs` (raid group icons) adds a white names line. Then ask wording (`BUFF_DUTY_TOOLTIP_ASK_TARGET` / `_ASKED` with minutes left), else `spec.hint` (Weapon Buffs, Soulstone, bag items), else a click line: job in INFO (`BUFF_DUTY_TOOLTIP_GROUP` / `_CAST`) and `TOOLTIP_KEY_CLICK` in MUTED, plus a favor's `BUFF_DUTY_TOOLTIP_TAKE_OFF` / `TOOLTIP_KEY_RIGHT_CLICK` line.
- **Icon state** between redraws: cooldown swipe per spec (an ask's wait from `BuffDuty.AskedAt`, item cooldown for item specs, one spell read per pass), else the reversed time-left sliver from `buffExpires`/`buffDuration` with countdown hidden (`noCooldownCount`); skipped while `ns.AreCooldownsSecret()`. Range fade every `RANGE_INTERVAL` to `OUT_OF_RANGE_ALPHA`; `pool.rosterStale` dims everything until the next draw or hide.
- **Close button**: script replaced with `ns.CloseBuffDuty` (sets `hiddenThisSession`, prints `BUFF_DUTY_CLOSED`). Cleared by login/reload, joining a group from none (`ns.NoteBuffDutyGroup` on `GROUP_ROSTER_UPDATE`, which a closed window still hears; resynced without clearing when the window's events turn on), `ns.SetBuffDutyOn(true)` (feature switch, mini-map toggle), or ticking your own class (`ns.ShowBuffDutyAgain`). While it holds, the mini-map menu's Buff Duty row reads Paused with `MENU_BUFF_DUTY_PAUSED_NOTE`. Title from `Kit.WindowTitle` (README-Notes).
- **Position** (`Buff-Duty-Position.lua`): saved as the top-right corner, so the window grows left and down from the close button. Drag only when unlocked and out of combat (`moving` flag, so a locked drag saves nothing); `OnDragStop` saves then re-applies the corner, or, let go in combat, sets `stopPending` and queues it (`ns.QueueBuffDutySettings`) for `ns.ApplyBuffDutySettings`. `ns.HasSavedBuffDutyPosition` / `ns.ResetBuffDutyPosition` (refused in combat) back the panel's Reset Position row.

#### Category and Options Menus (`Buff-Duty-Options-Menu.lua`)

- One `Kit.CreateMenu` menu (`ADDON_NAME .. "BuffDutyOptions"`, so Escape closes it; `publish = false`). `Open` sets `rootKey`, shows it beside its line (`menu:Show(owner, "line")`) and keeps the line lit (`LockHighlight`) until it hides. Keys (`EntriesFor`): `"options"`, `"cat:<row>"`, `"cat:weapons:<hand>"`, `"when:<row>"`, `"show:<row>"`, `"target"`, `"opacity"`; `flyouts` builds any key on demand.
- **A category menu** (`CategoryEntries`): Show in Buff Duty (`BuffDuty.SetRowOn`); When to Use and Show, value rows opening `when:` / `show:` (`rowWhen`, `rowShow`); Use with Cast Next Buff (`rowKey`); Show Missing Inventory (`rowOut`, not on self); then the items (`ITEM_ROWS`): `AddSpellRows` (`SetSelfItemOn`), `AddFoodRows` (`buffFoodOff`, `ns.RequestUpdate`, then `useBuffFoodWhenFed` via `ns.ToggleMacroSetting`), `AddScrollRows` (every scroll type into profile `scrollTypes`, then carried scrolls into `scrollOff`), `AddElixirRows` (`elixirOff`), `AddOtherRows`, `AddWeaponRows` (one hand, or every hand from Options).
- **The Options menu** (`OptionsEntries`): Show in Window (a category toggle per `RowExists` row, hover opening its `cat:` menu), Other Players (`OTHER_PLAYERS`: `askOtherClasses`, `targetEnabled` with the `target` submenu (`targetNPCs`, `askTarget`), `favorEnabled`, `buffPvPFlagged`), Window (Window Opacity, opening `opacity`), then All Buff Duty Settings (`ns:OpenOptionsPanel("BuffDuty")`, also `ns.HideMenu`).
- **Opacity preview**: every panel's `onEnterRow` is `OnEnterRow` (set in the `Render` override); hovering a choice with `entry.preview` shows it unsaved; `EndPreview` puts the saved one back on another row, when the frame's `OnUpdate` finds the cursor off that panel, or on hide. A click saves `windowOpacity`.
- `afterChange` drops the preview, calls `ns.RefreshBuffDuty` and `menu:Refresh`.
- API: `ns.ShowBuffDutyMenu(owner, key)` (a category line), `ns.ShowBuffDutyOptions(owner)` (the Options line, the mini-map menu's Buff Duty row), `ns.HideBuffDutyOptions(within)` (only when its owner sits inside `within`, or always with nil), `ns.IsCursorOverBuffDutyOptions` (keeps the mini-map menu open while this one is used).

#### Casting

- `ns.SetBuffButtonAttributes` writes every key, nil included, on every use (pooled buttons); a nil spec, an ask or a `pvpFlagged` spec clears them all.
- **PvP hold** (`BuffDuty.PvPFlaggedTarget`, `Buff-Duty-Units.lua`): while you aren't flagged and `buffPvPFlagged` is off, the name of a flagged player a cast would reach: its unit, a group buff's party, or your own party for a `party` self buff (Battle Shout). `ns.SetBuffDutyIcon` stores it as `spec.pvpFlagged`. Only `type1`, so a right-click casts nothing and is free for dismissing a favor.
- Kinds: `macrotext` → macro; `item` → the template's item action at `unit`, a `spec.selfItem` (buff food, scrolls, elixirs, Other Buffs) named by its item name (`ItemUseName`), anything else (weapon items with `target-slot`, the Soulstone) by `item:<id>`; else spell by `castSpell or spellName` at `unit`.
- Spells cast by rank text, `BuffDuty.CastText` (`Name(subtext)` from `C_Spell.GetSpellSubtext`, bare name when none): group buffs (`groupCastText`), single ranks, self buffs, imbues and resurrections (`BuffDuty.PickResurrection`). Create Soulstone and a warlock stone's `create` rank cast by bare name, since each tier is its own spell.
- Return the Favor buttons target by name: `TargetMacro` writes `/cleartarget`, `/targetexact NAME`, `/cast [help] <castText>`. Clearing first makes a miss cast nothing; the player is left targeted on purpose, so the window sees the buff land.
- **Bloodrage first** (`Buff-Duty-Self.lua` `WithRageFirst`): a warrior short on rage for a rage-costing self buff (Battle Shout), with Bloodrage known (`ns.BLOODRAGE_SPELL_ID`) and off its own cooldown past the GCD, gets `macrotext` `/cast Bloodrage` + `/cast <buff>` and `rageFirst`. `rageFirstDrawn` remembers each drawn answer; `BuffDuty.CheckRageFirst` (on rage `UNIT_POWER_UPDATE` and `SPELL_UPDATE_COOLDOWN`, skipped in combat) requests a redraw only when one would change.
- Weapon items use `item` + `target-slot`; imbues cast at the player and land where the game puts them.

#### Reading Auras (`Buff-Duty-Auras.lua`)

- GUID-keyed cache. `UNIT_AURA` marks a GUID dirty; `MarkAllAurasDirty` bumps a generation. A record is re-read when dirty, of an older generation, or when its unit died, revived or changed connection. A secret GUID reads into a throwaway record.
- `ReadAuras(unit)` selects a record for `Has`, `Carries` and `AurasReadable` to read. A secret spell ID marks the record unreadable.
- `myStrengths` (your casts' summed `points`, wiped on `SPELLS_CHANGED` via `ForgetMyStrengths`) and `myDurations` (kept; `BuffDuty.MyDuration`).
- `bounced` is filled by `BuffDuty.NoteBounce` (searches `buffs` and `selfBuffs`), read straight off the unit, on `SPELL_FAILED_AURA_BOUNCED` within `BOUNCE_WINDOW` (`Buff-Duty-Cast-Results.lua`).
- `Has(buff, unit)` order: bounce match, strength compare (both known), rank compare (`RankFor` at the unit's level), the time rule (`buff.refreshSeconds` or `BuffDuty.refreshSeconds`; a buff no longer than that counts only once gone), then another of your own auras in the same exclusive family. Running low returns its expiry and duration for the sliver. Party-Buffs and asks pass buff-shaped tables with empty `ranks`, so any version counts by time.
- `RankFor` caps by `RANK_LEVEL_GAP` below the learn level only where `ns.EXPANSION <= 3` (`HAS_RANK_LEVEL_GAP`); an unknown or secret level takes the top rank.
- `BuffDuty.PruneAuraCache` keeps pet, target, targetpet, the group and their pets, and prunes `bounced`, pet holds and NPC cycles to the same set.
- Well Fed, scrolls, elixirs and the eating check read the player's auras directly (`Buff-Duty-Self.lua`, `ns.GetPlayerBuffSnapshot`), not this cache.

#### Who Gets What

- `BuffDuty.RoleOf`, in order: the Main Tank mark asked exactly (`ns.GetPartyAssignment("MAINTANK", unit, true)`), the assigned role (tank only outside a raid), your own LFG roles (tank only outside a raid), then `CountsAsTank(class)` from `tankWhen` (SOLO means `ns.GetGroupContext() == "solo"`). Otherwise damage.
- `BuffDuty.Wants`: `manaOnly` skips `Data.NO_MANA_CLASSES`, `noCasters` skips `Data.CASTER_CLASSES`, then the buff's audience.
- **Groups**: one section per subgroup with something missing. A party gets a group icon (only while grouped) once any member lacks the buff; its target is the first in-range member; its sliver shows only when every missing member has some time left. A member's pet row keeps the member listed. Pets don't count toward group icons. A dead member gets one resurrection icon. You are left out (`member.isPlayer` from `GroupMembers`): your own group buffs are Self's. Raid folding above.
- **Pets** (`Buff-Duty-Pets.lua`): with `ns.BUFF_DUTY_PETS_FLAGGED_ONLY` (Camelot) `PetWants` offers only rows marked `pets = true`. Skipped when dead, identity secret, out of sight, not assistable, phase-shifted, charmed (`UnitIsCharmed`, or no `PetOwnerClass` and no creature family), or any aura unreadable. Only a readable "no" skips. Pets take `ALL`, plus `TANK` per `tankWhen.PET` (`Data.TANK_WHEN_PET`), never `HEALER`; `manaOnly` by power type. Owner class: known demon NPC ID (`ns.BUFF_DUTY_PET_ICONS.demons`) → warlock, Focus → hunter, else the tooltip's guess.
- **Pet holds**: a cast aimed at a pet that goes off (`ns.OnBuffCastSucceeded`) holds that buff for `MyDuration` (else `PET_HOLD_FALLBACK`) less the refresh time, at least `PET_HOLD_MINIMUM`. A refusal in `PET_REFUSALS` (client strings) holds it while the pet stays watched. `Has` agreeing clears a hold.
- **Friendly NPCs** (`Buff-Duty-NPCs.lua`): the Target section's row via `BuffDuty.NPCRow`, only while `targetNPCs` (Include NPCs, under Your Target on the panel and in the Options menu's `target` submenu) is on, gated by `BuffDuty.CanBuffNPC` (not a player or player-controlled, alive, identity readable, in sight, a readable yes from `UnitCanAssist`). Every buff regardless of audience; `noCasters` by NPC class, `manaOnly` by power.
  - **A cycle, not aura reads**: `cycled[guid]` records each cast (`BuffDuty.NoteNPCCast`, when the attempt was `isNPC`: not a player, not player-controlled). The row offers what this round hasn't had, then starts over.
  - Refusals hold through the pet hold table (`IsHeld`). The row carries `npc = true`.
- **Outsiders** (`Buff-Duty-Outsiders.lua`): Target claims a GUID before Return the Favor. Target section skipped while `targetEnabled` is off or its identity is secret. Dead friendly target: resurrection row only. Targeted outsider pet: one row named "Pet (Owner)", owner from tooltip lines (`OWNER_FORMATS`, `ns.ReadTooltipLines`). Targeted player: their row (while they or their pet need something), then the Ask row (needs no row above it), then `targetpet`; a favor's `given` keeps updating while targeted.
- `ns.IsBuffInRange`: player and untestable units in range; phase-shifted out; then spell range, `UnitIsVisible`, `UnitInRange`. Unknown or secret reads as in range. `ns.IsBuffSpecInRange` asks an item's own range out of combat first (Soulstone).
- `BuffDuty.IsPhaseShifted` reads `ns.GAME_IDS.PHASE_SHIFT_SPELL_ID` (absent means never), cached per frame.

#### Buff Key (`Buff-Duty-Keys.lua`, `Buff-Duty-Key-Picker.lua`)

- A hidden `GtGBuffKey` secure button, created at file load, bound to `ns.BUFF_KEY_COMMAND`; macros use `ns.BUFF_KEY_MACRO`. A slash command can't cast. PreClick picks and writes attributes, the template casts, PostClick clears.
- `useOnKeyDown` false and both halves registered, so a key press and a macro's lone up both act on the up half. The up half reuses the down half's pick within `PRESS_REUSE_SECONDS`; only the up half remembers, notes the attempt, whispers an ask, and notifies. `/click` finds the button by its exact, case-sensitive name.
- The key casts on someone else the way a window click does (spell + `unit`) and never changes your target. On WoW Forever its macro lines never went off, from the key or a `/click` (a `/target` + `/cast` line, and a self item's `/use`); why isn't known. Self Buffs items use the template's item action by name at `player` for the same reason. Favors keep their own macro.
- Silent presses: in combat (button left as it was), and while `Busy()` (cursor targeting, casting or channeling (unreadable counts), or `BuffDuty.IsEating()`), which also clears the button.
- Candidate order (`Candidates`): dead friendly target, group dead; target ask icons; target non-NPC rows; favors (after the target, since a favor's macro clears it); self icons (not `castLast`, not weapons or self consumables); parties (target's subgroup first: `GroupChoices`, then a folded header's counted singles, then uncovered row singles; pets always singles); `castLast` self icons (Shadowform); scrolls; weapon rows; elixirs; other buffs; Well Fed; a targeted NPC's row last. A spec whose `dutyRow` is off the key (`BuffDuty.RowOnKey`) is never added. `BuffDuty.CastOrder` is the same list without `now`, for the window's packed lines.
- Never candidates: Winterfall Firewater and other plain self items (window click only); specs with their own cooldown (`HasCooldown`: `GetSpellBaseCooldown` above zero, or an item's `hasCooldown`, i.e. using a Soulstone). Create Soulstone is.
- `PickNext` needs set up, enabled, auras readable, `ShowsHere`, alive. The first ask icon that `BuffDuty.CanAskTarget` (out of combat, off its cooldown) comes back fourth, and the press whispers it alongside its cast; the cast is the first ready and reachable, passing over a PvP hold (`BuffDuty.PvPFlaggedTarget`, returned third as `flagged`); else the first `"unusable"` one (so its error shows); else who it waits on.
- With nothing cast: a held-back PvP pick prints `BUFF_DUTY_PVP_FLAGGED`; else a UI notice: `BUFF_KEY_WAITING`, `BUFF_KEY_OFF` (Tracking fails), `BUFF_DUTY_AURAS_HIDDEN`, or `BUFF_KEY_DONE` (only when `ShowsHere` and alive).
- `GroupChoices(section, now)` takes the group version when no single icon exists, or when reach is positive, it is cheaper (a member with no single icon; else mana via `C_Spell.GetSpellPowerCost`; else reach of two or more) and not unusable. With `now` a just-cast group buff covers its column; the window calls it without `now` (both kinds of raid header).
- `Reachable`: a group spec waits until every missing member is in sight (out of sight and not AFK holds it), then needs one in range.
- Skip memory (`recent`, keyed by GUID, party or favor plus spell name, or `item:<id>:<slot>` for consumables and weapon items): `BUFF_SKIP_SECONDS`, `RESURRECTION_SKIP_SECONDS` once the cast is heard (`pending`, `PENDING_SECONDS`; an item matches its item spell), `FAVOR_RETRY_SECONDS` at press time.
- PostClick after a `rageFirst` press leaves the buff's own spell cast on the button: Bloodrage may start combat, locking the button, and the next press casts the buff.
- "On cooldown" means ending after the GCD: `ns.GLOBAL_COOLDOWN_SPELL_ID` where the flavor's Game-IDs defines it (Mists), else the first known rank of your own Buff Duty rows whose base cooldown is the GCD alone (`BuffDuty.GlobalCooldownEnd`).

#### Your Categories (`Buff-Duty-Self.lua`, `Buff-Duty-Settings.lua`)

- **Categories** are `Data.BUFF_DUTY_ROWS`: self, food (Well Fed, titled `BuffDuty.WellFedLabel`), weapons, scrolls, elixirs, other. Each has its own settings in `buffWindow`: Show in Buff Duty (`BuffDuty.RowOn` / `SetRowOn`: `selfEnabled` and `weaponEnabled` for the first two, else `rowOn[row] ~= false`), When to Use (`rowWhen`, `Data.BUFF_DUTY_ROW_WHEN`; `BuffDuty.RowShows`, a battleground's group counting as a raid), Show (`rowShow`, `Data.BUFF_DUTY_ROW_SHOW_CHOICES`; `BuffDuty.RowShowSeconds`, 0 for When Missing), Use with Cast Next Buff (`rowKey`, `BuffDuty.RowOnKey`), Show Missing Inventory (`rowOut`, `BuffDuty.RowOut`, never self). `BuffDuty.RowExists` leaves out a category the client can't fill.
- `AddSelfSection` skips while dead and adds one `self`-kind section per category with an icon or a `missing` line, in `BUFF_DUTY_ROWS` order: grid `"self_" .. row`, `menu = row` (Weapon Buffs instead carries a row per hand, each `menu = "weapons:" .. hand`). `TagRow` sets `spec.dutyRow`, which the Buff Key reads. `needsPet` waits for a live pet.
- **Missing Inventory** (`missing`, only with `RowOut` and no icon): `FoodMissing`, `ScrollsMissing`, `BuffDuty.ElixirsMissing`, `OtherMissing`, and a hand's own test in Weapons. Each says no while auras can't be read.
- `selfRefresh[key]` now only says on or off (`BuffDuty.SelfItemOn` / `SetSelfItemOn`: any value but `SELF_REFRESH_OFF` is on); the timing is the category's Show. Self buffs, your group buffs on you and the Soulstone take `RowShowSeconds("self")`; self items their own category's.
- **Your group buffs on you**: `BuildBuffs` adds a self buff per class `BUFF_DUTY_SPELLS` row you know whose `selfRefresh[key]` is on (`isGroupBuff`, single-target ranks, `groupId` for `Has`'s strength check), skipping `manaOnly`/`noCasters` by your class. Group Buffs' audience is for everyone else. Seeded from the row's `selfDefault`, else 3 (on) for a row whose `default` is ALL and Off otherwise.
- **Soulstone**: hidden while anyone in the group carries one. Best stone in bags → first healer in item range, else first healer, else you; no stone → Create Soulstone on you.
- **Self consumables** (`selfItemEntries`, any class, built in `BuildLookup`, keyed apart from spell ids; `BuildBuffs` keeps each while its category is on, Other Buffs also needing `SelfItemOn`):
  - Other Buffs (`ns.BUFF_DUTY_SELF_ITEMS`, key `"item:<id>"`): shown while one is in your bags and `Has` finds none of its auras in time.
  - **Well Fed** (key `"wellFed"`, only where `ns.WELL_FED_SPELL_ID` and a Well Fed table exist): uses `ns.bestBuffFoodID`, the consumables scanner's pick (Ignore List, arena and `buffFoodOff` already applied). `WellFedAura` reads the longest Well Fed aura by `ns.WELL_FED_BUFF_IDS` or `ns.WELL_FED_ICON_IDS`; nothing while an aura is secret or while you eat or drink (`EatingMatcher`: Food/Drink spell names, the food's own item spell).
  - **Scrolls** (key `"scrolls"`, where `ns.SCROLL_DATA` has a live lowest scroll buff of the first `ns.SCROLL_CHECK_ORDER` type): `AddScrollIcons` adds an icon per type ticked in `ns.db.profile.scrollTypes`, in `SCROLL_CHECK_ORDER`, using `ns.FindBestScroll(type, liveItemCounts)` (live `GetItemCount`, 0 for a scroll in `scrollOff`; the finder applies the Ignore List and class-locked scrolls) and `ns.GetPlayerBuffSnapshot().scrolls[type]` (missing, or under the Scrolls timing; a stronger elixir or class buff, `conflictAmount`, covers it). Nothing while auras are secret.
  - **Flasks or Elixirs** (key `"elixirs"`, where the client knows `ns.ELIXIR_BUFF_IDS`; `Buff-Duty-Elixirs.lua`): `BuffDuty.CarriedElixirs` lists one bag item per elixir buff, leaving out Other Buffs' items, scrolls and (for the window) the Ignore List. Each buff's value is its slot (`"BATTLE"` / `"GUARDIAN"` from TBC on), a non-stacking group, or `true` for alone; `ReadElixirAuras` marks what your buffs take, a flask (`ns.FLASK_BUFF_IDS`) both slots where `ns.EXPANSION >= 2`. `AddElixirIcons` offers an elixir whose own buff is under the Show time, or whose slot or group is free, never one in `elixirOff`; icons sit at the entry's column plus index/100.
  - Old switches as seeds: `selfRefresh`' Well Fed, Scrolls and Elixirs values (When Missing where the flavor sets `ns.BUFF_DUTY_ITEM_BUFFS_SHOWN` (Camelot), else Off) seed `rowOn` once for a category never set.
- `ns.BuffDutyHasClassRows` is true for every class once any weapon item or consumable entry exists.

#### Other Sections

- **Weapons** (`Buff-Duty-Weapons.lua`): one row per hand holding a weapon (not a fishing pole unless a lure fits). Picks are your class's poisons/imbues/warlock stones on `ns.BUFF_DUTY_WEAPON_HANDS[class]` hands plus any-class items (`Data.WEAPON_ITEM_KIND_HANDS`), each ticked per hand (`BuffDuty.WeaponChoiceOn`), all on the weapons category's Show.
  - Layers (`Data.WEAPON_LAYERS`): where `ns.WEAPON_ENCHANTS_STACK` (Camelot) holds, poisons, imbues and `ns.BUFF_DUTY_WEAPON_IMBUE_ITEMS` are IMBUE, other items TEMPORARY; elsewhere one layer. A layer is covered by any of its picks with time left; otherwise every pick of it is offered.
  - `BuffDuty.ReadWeaponEnchants` reads `ns.GetWeaponEnchants()` and files each enchant into a layer (`WornLayer`).
  - Items: `PickFits` subclass mask, zones (`InItemZones`), best bag item for your level. Imbues only on `BuffDuty.ImbueLandsOn`'s hand. Icons sorted class picks, imbue layer, level.
  - Warlock stones (Camelot): Firestone and Spellstone are WARLOCK item rows in `ns.BUFF_DUTY_WEAPON_ENCHANTS` (main hand). A row's `create` ranks become the pick's `create` (best known, `KnownRanks`); with no stone of the line in the bags the icon casts it by bare name, else applies the best stone by `target-slot`. No Soul Shard check.
  - `REPLACE_ENCHANT` is auto-accepted within `REPLACE_WINDOW` of a weapon click or key press (`ns.ExpectReplaceEnchant`), popup hidden this frame and next.
- **Party-Buffs** (`Buff-Duty-Other-Classes.lua`, `-Party-Buffs.lua`): non-exclusive `group` rows whose audience isn't Off and that you can't cast, counted per missing member. Shown only while that class is in the group (connected, alive) or is yours, and a `talent` row only once someone carries it.
  - Icons are plain buttons on the header, count in red. Click asks the group (`ns.AskGroupForBuff` → `ns:SayBuffRequest`), right-click whispers every other player of that class (`ns.WhisperOtherClassBuff`, the composer's `buffAsk` text, nothing when emptied). Each way has its own `ASK_COOLDOWN` per buff (`ns.CanAskForBuff`).
  - Hover opens `GoodToGoPartyBuffsMenu` on `ns.MenuKit`: header, names party by party with minutes left or Missing, then both asks as clickable rows (`disabled` while cooling, the shortcut in the tooltip via `BUFF_DUTY_OTHERS_SHORTCUT_LEFT` / `_RIGHT`; whisper row absent with no recipients), time left in VALUE color. Opens `MENU_GAP` off the icon, stays open while the cursor is on the icon or menu, closes `CLOSE_DELAY` after, redraws every `REFRESH_INTERVAL`, and Escape closes it (`UISpecialFrames`).
- **Return the Favor** (`Buff-Duty-Favors.lua`):
  - Off Camelot: combat-log `BUFF` on you from a friendly, outsider-flagged source; `ns.NoteFavor` then requires a player GUID. Flags, because cross-realm names break name lookups.
  - Camelot: your own `UNIT_AURA` `addedAuras` (never a full update, in combat or while secret); caster from `sourceUnit`, else `C_UnitAuras.GetAuraCasterGUID` (pcall) and `UnitNameFromGUID` with the realm's spaces stripped.
  - Capped at `Data.BUFF_DUTY_FAVOR_MAX` (oldest evicted), kept `favorSeconds`. Dropped on joining your group, when every buff you can give is on them, or on right-click. Rows newest first. No players-in-range list: it would depend on friendly nameplates.
- **Ask Your Target for Buffs** (`Buff-Duty-Asks.lua`, switch `askTarget` under Your Target):
  - `BuffDuty.TargetAskRow` adds an "Ask Name" row (`BUFF_DUTY_ASK_TARGET_ROW`, grid `ask`) under a targeted outsider player: rows of their class (never yours) their level has learned (lowest rank), audience not Off, `Wants` for you, missing per `Has` with no ranks. A `talent` row only once the target carries it; one per `exclusive` family; never a `noAsk` row. Skipped while either of you is in combat or they're AFK/DND (`Approachable`).
  - Icons share one `spec.ask` table (guid, name, short, specs) and each has `askKey`. The click (PreClick, up half) and the Buff Key call `ns.AskTargetForBuffs`: only while they are still targeted and out of combat, one whisper (`buffAskTarget` via `ns.GetMessageText`, `ns:BuildBuffAskTargetWhisper`; links, else names when too long) naming every buff on the row not asked within `ASK_COOLDOWN` (per GUID and buff, `BuffDuty.ASK_TARGET_COOLDOWN`), sent through `ns:QueueAutomatedWhisper`. Nothing printed.
  - The window counts it as something to show (`WatchesTargetAsks`), so a class with nothing to cast still sees it.
- **Resurrections** (`Buff-Duty-Resurrections.lua`): no icon for ghosts, offline, incoming resurrection, or within `RESURRECT_PENDING_SECONDS` of `SPELL_RESURRECT`. On Camelot, your own resurrect cast succeeding within `RESURRECT_CAST_SECONDS` of the click stands in (`ns.OnResurrectCastSucceeded`).
- Buff Duty never waits on item info (`C_Item.GetItemCount`, `GetItemIconByID`); only the Weapon Buffs panel warms items (`Kit.WarmItems`).

#### Options (`Options/Buff-Duty/`)

- Registered in `Options/Options.lua` (`RegisterBuffDutyPanels`), in order: `BuffDuty`, `BuffDutyBuffs`, `BuffDutySelfBuffs` (`Kit.PrepareTree` reopening on your class), `BuffDutyFood` (titled `BuffDuty.WellFedLabel()`), `BuffDutyWeaponBuffs`, `BuffDutyScrolls`, `BuffDutyElixirs`, `BuffDutyOther`.
- Main panel: `Kit.FeatureSwitch("buffWindow.enabled")` (twin of the root's, both through `ns.SetBuffDutyOn`); everything below hides while it is off. `noBuffs` status line from `ns.BuffDutyHasClassRows`. When to Show: `ns.OptionsGroupContextToggle` rows with a `showWhere` dropdown via `Kit.ToggleRow` (none for Battleground). Classes from `ns.OptionsClassList`. Show in Window: a switch per category in `BUFF_DUTY_ROWS` order (`selfEnabled`, `weaponEnabled`, and `CategoryToggle` rows for the rest, hidden unless `RowExists`). Other Players (`BUFF_DUTY_MENU_OTHER_PLAYERS`): `askOtherClasses` (composer `buffAsk` at 10.3, Example after), `targetEnabled` with `Kit.SubToggleRow`s `targetNPCs` and `askTarget` (composer `buffAskTarget` at 12.2), `favorEnabled` with `favorSeconds` on one `Kit.ToggleRow`, `buffPvPFlagged`. Window: `locked`, `hideInCombat`, Reset Position (`Kit.ResetRow`, grayed in combat or with nothing saved). Send Messages In shows on the first visible composer (`languageHidden`).
- Sub-panels are not hidden by the switch (`ns.AddFeatureOffLine` instead; each category page also names its category's switch while it is off, by a function for Well Fed's client-supplied name). Every class is listed (account-wide).
- Each category page opens with `ns.AddBuffDutyRowControls(args, row, order)` (`Options-Buff-Duty-Utilities.lua`): Show in Buff Duty, When to Use, Show, Use with Cast Next Buff, Show Missing Inventory (not self), the same settings as the category menu. Items use `ns.DefineSpellToggleRow` (On or Off through `SetSelfItemOn`).
- Self-Buffs is a tree (`childGroups = "tree"`): the category's controls, then one page per class keyed by the token. Rows use `Kit.TREE_LABEL_WIDTH`/`TREE_CONTROL_WIDTH`. The page header appends `BUFF_DUTY_SELF_NOTE_<FAMILY>` for a family with two or more entries.
- `Options-Buff-Duty-Consumables.lua` (`BuildPage`): Well Fed, Scrolls (the profile's `scrollTypes` checkboxes, labels from `ns.SCROLL_TYPE_LABELS`), Flasks or Elixirs, Other Buffs (a toggle row per item). Weapon Buffs: the category's controls, then its per-hand grids.
- `ns.OptionsClassList` is `ns.CLASS_SPELL_LISTS` keys plus every Buff Duty row's class.

#### Diagnostics

- `ns:BuildBuffDutyContextReport` (`Diagnostics/Manifests-Buff-Duty.lua`): switches, gates, per-buff knowledge and readiness, Well Fed and buff food (`buffFoodOff`), scrolls (`scrollOff`), elixirs (`elixirOff`), asks, weapons, Soulstone, key binding, old bindings and the attributes the key's last press set (`type1`, `spell`, `item`, `unit`, `macrotext`), then group and target as the window reads them. Skips the group read in combat. Its `GroupUnits`, `HeldBuffs`, `ReadWellFed`, `ScrollLines`, `AskLines` and weapon subclass reads re-implement the window's.
- `ScrollLines` ends with `CampBenefitLines`, and `Manifests-Macros-for-Consumables.lua` carries a guarded `C_TooltipInfo.GetUnitBuffByAuraInstanceID` API check plus Validate Data rows, all reading `ns.SCROLL_DATA[type].campBenefits`, `ns.CAMP_BENEFITS_SPELL_ID` and `ns.CAMP_BENEFIT_LINE_NAMES`. No data file or scanner defines these (see Pitfalls).
- `ns.DIAGNOSTIC_MESSAGES` (single function, assigned in the manifest) feeds `ns:BuildBuffDutyMessageLengthReport` (`Diagnostics/Message-Length-Buff-Duty.lua`).
- `ns.IsCorrelatedMessage` (event log): any Buff Duty data spell ID for `UNIT_SPELLCAST_SUCCEEDED`, the learned bounce error type (`ns.IsBuffBounceError`) for `UI_ERROR_MESSAGE`.

### Rank Watch

Does the standalone Rank Sentinel add-on's job. Reports a spell cast at a lower rank than the caster could have: a print for the player's own casts; a whisper to, and/or a print about, a group member. Off by default.

- **Loading.** Vanilla, TBC and Camelot TOCs list `Features/Rank-Watch/`, `Options/Rank-Watch/` and `Options/Enhanced-Spellbook/Options-Ability-Alerts.lua`; Camelot loads `Rank-Watch-Detection-Forever.lua` where the others load `Rank-Watch-Detection-Combat-Log.lua`. Mists loads only the (empty) data files and the two Diagnostics files.
  - Outside callers test that a function exists first: `ns.SetRankWatchEnabled` (`Options-Feature-Switches.lua`, at file load, gates both feature records), `ns.BuildRankWatchOptions` / `ns.BuildAbilityAlertsOptions` (`Options.lua` registration), `ns.IgnoreRankWatchPlayer` (`/gtg ignore`, the root panel's Commands line), `ns.RankWatchSettings` (`Manifests-Rank-Watch.lua`), `ns.BuildRankWatchWhisper` (`Message-Length-Rank-Watch.lua`), `ns.IsRankWatchActive` (`Diagnostics/Event-Log.lua`).
- **Events.** Module `RankWatch`; each file hands its handlers to `Rank-Watch-Core.lua` via `ns.SetRankWatchHandler` (one handler per event, a table, not a list). `ns.SyncRankWatchEvents` subscribes Core's `EVENTS` (includes `CHAT_MSG_WHISPER` for "Opt Out") while `ns.IsRankWatchActive()` (on, and no standalone add-on loaded), then calls the loaded detection file's `ns.SyncRankWatchDetection` and `ns.SyncRankWatchCluster`; going inactive also `ns.ClearRankWatchQueue`. Detection files subscribe their own events through `ns.SetRankWatchEvent` (unit filters allowed). Callers of the sync: `ns.SetRankWatchEnabled`, the Whisper toggle's setter (so the cluster re-JOINs), the reset listener, login.
- **Login** (`OnPlayerLogin`, Core): find the standalone add-on, migrations (Saved Variables), `TakeOverFromStandalone`, `ForgetOnNewVersion`, `ns.BuildRankWatchLookups`, `ns.ResetRankWatchSession`, the standalone notice, sync, then register `resetListener` on `OnProfileReset`.
- **Ladders** (`Rank-Watch-Lookups.lua`): built at login from `ns.RANK_WATCH_ABILITIES` per class, each rank dropped when `C_Spell.DoesSpellExist` says the client lacks it (Forever renumbered some), joined across one `ns.SPELL_GROUPS` group into the first (`isGroup`), sorted by learn level (stable by arrival). Keyed by first rank's spell ID (`ladder.id`), which the Reported Ranks panel uses. A one-rank ladder is kept for the panel.
  - `ns.RANK_WATCH_PET_ABILITIES` ladders sit under the owner's class with `isPet`, never joined; their level is the pet's.
  - `ns.RankWatchReportableLookup` is the fast reject every detection path and the Event Log call first: tracked and not the top rank.
  - Tracked state (`ns.IsRankWatchRankTracked`): the row's `off` flag, overridden by `rankWatch.untracked[id]` (true = unticked, false = ticked though `off`). `ns.SetRankWatchRankTracked` clears the entry when it matches the data default.
  - `ns.RankWatchBestIndex`: a row with no `level` is never the better rank.
  - Rank text: `ns.RankWatchRankText` prefers the client's subtext (requesting it when missing), falls back to the data's `rank` (print only); `ns.RankWatchHasRankText` gates whispers.
- **The check** (`ns.CheckRankWatchCast(cast)`, `cast = { guid, unit, spellID, recipientLevel, petUnit, petGUID }`):
  - Drops: unknown or untracked rank, inactive, a pet ladder without `petUnit` (or the reverse), non-player GUID, ignored player, PvP instance (`ns.IsInPvPInstance`), charmed or enemy unit, unreadable level (`ns.RankWatchUnitLevel`, nil for a secret identity).
  - Ceiling (`Ceiling`): lowest of caster level and their first-seen level this session (`session.firstLevel`), each less the grace (`graceMaxLevel` when the owner is at `ns.GetMaxPlayerLevel()`, else `graceLeveling`); and for a cast on another friendly player, `recipientLevel + Data.RANK_WATCH.TARGET_LEVEL_RANGE` (the game lowers a buff's rank by itself to fit a target).
  - Pet casts: the pet's level and GUID set the ceiling; the owner is ignored, picks the grace, and is told.
- **Dedupe**: once per owner and ladder a session (`session.notified`), and saved as `<owner GUID>-<caster level>-<spellID>` in `rankWatch.announced` (caster level is the pet's for a pet cast), the key shape the standalone add-on's `NOTIFY` uses; broadcast via `ns.BroadcastRankWatchNotify`. Wiped when `announcedVersion ~= ns.Version` (`ForgetOnNewVersion`).
- **Messages**: self casts always print (`ns.BuildRankWatchSelfLine`); others print when `print` is on (`ns.BuildRankWatchOtherLine`, naming the whisperer when it's someone else). Pet forms use `_PET` / `_DEMON` locale keys (`MessageKey`); `ns.RankWatchPetInfo` names a hunter pet by name, a demon by creature family. The tip whisper is editable (`ns.BuildRankWatchWhisper` → `ns:BuildRankWatchTipWhisper` in `Announcements.lua`, form from `ns.RankWatchTipForm`, fields `rankWatchTip` / `rankWatchTipPet` / `rankWatchTipDemon` via `ns.RankWatchTipField`); the print is fixed.
- **Whisper queue** (`session.queue`, `ns.ProcessRankWatchQueue`):
  - Held in combat or while dead; a target in combat retries after `TARGET_BUSY_RETRY`; `AFTER_COMBAT` after `PLAYER_REGEN_ENABLED` / `PLAYER_ALIVE` / `PLAYER_UNGHOST`.
  - Built only once the client's rank text is in (`RANK_TEXT_RETRY` × `RANK_TEXT_TRIES`, timed from the first check, not the cast), else dropped rather than sent with the data's number.
  - Rechecked at send: dropped if the player is now ignored, Whisper went off, or another copy leads.
  - Sends through `ns:QueueAutomatedWhisper` (the shared spaced whisper queue in `Announcements.lua`). An emptied tip sends nothing and counts toward no offer.
- **Opt out**: a player's second reminder in a session is followed by the offer (`ns.BuildRankWatchOptOutWhisper`, field `rankWatchOptOut`), once a session per player (`session.offered`); no setting gates it beyond Whisper. A whisper of exactly `OPT_OUT_WORDS` (trimmed, any case) from a current `party`/`raid` unit adds them to Ignored Players and gets the reply (`rankWatchOptOutDone`) plus a print.
- **Cluster** (`Rank-Watch-Cluster.lua`): every copy, Good to Go's and the standalone add-on's, speaks over `Data.RANK_WATCH.COMM_PREFIX`, so the two elect one leader; plain add-on messages read like the standalone's AceComm single-part ones (a leading control byte means a split message, ignored).
  - `JOIN` (after `JOIN_DELAY` on joining; on turning on in a group; from a leader turning off, handing the lead back), `LEAD` (whispered to a joiner or broadcast to claim), `NOTIFY` / `SYNC` (saved only when matching `ANNOUNCED_KEY_PATTERN`). Release number is `COMM_RELEASE`. A JOIN from the leader itself makes a copy with Whisper on claim the lead.
  - Only the leader whispers (`ns.RankWatchWhisperer` → `"self"`, a name, or nil; `ns.RankWatchLeadName` for the panel). `ns.RankWatchWhisperer` claims the lead from a leader its group unit (`GroupUnitOf`) reads as offline. A copy with Whisper off doesn't broadcast a claim. Two self-claimed leaders: the lower name keeps it. Nothing is sent in PvP instances. Names are short `UnitName` names, as the standalone sends.
- **Detection, combat log** (Vanilla, TBC): `SPELL_CAST_SUCCESS` from group-affiliated sources. Pet-ladder casts resolve the owner (`PetAndOwner`). A friendly destination other than caster/owner, a group member's pet included (`PetAndOwner`), passes its level (`RecipientLevel`); unreadable drops the cast.
- **Detection, Forever** (no combat log; other players' cast IDs hidden):
  - Own casts: `UNIT_SPELLCAST_SENT` → `SUCCEEDED` by castGUID (`pending`, swept after `PENDING_TTL`); recipient by name through `ResolveCastTargetUnit` (`CAST_AT_UNITS`, your own pet included, then the group); an enemy caps nothing, an unresolvable name drops the cast.
  - Own pet: `SUCCEEDED` on `pet` (`CheckPetCast`); a helpful spell in a group is capped by `LowestGroupLevel`.
  - Others' buffs: group `UNIT_AURA` `addedAuras` (never while `ns.AreAurasSecret()`); bearer is the recipient; the player's own auras and casters resolving only to target/focus/mouseover are skipped.
  - Others' damage and heals: `C_DamageMeter` on a `METER_POLL` ticker, never in combat, plus a read on `PLAYER_REGEN_ENABLED`. First read after joining or turning on is a baseline; a spell counts when its total moved. Heals capped by `LowestGroupLevel`; damage uncapped. Pet spells (folded into the owner's list) are checked as that owner's pet while it is still out (`PetOf`). Out of a group the totals are wiped.
- **Standalone add-on** (`Data.RANK_WATCH.STANDALONE_FOLDERS`): while it runs Rank Watch stays quiet and prints `RANK_WATCH_STANDALONE` at login and on turning on; the panel shows the same as a status line. `TakeOverFromStandalone` switches Rank Watch on every such login unless Rank Sentinel's own profile was off; `Features/Replaced-Addons.lua` turns it off (`ns.REPLACED_ADDONS`).
- **`/gtg ignore [Name]`** (`ns.IgnoreRankWatchPlayer`): the target, or a group member / target / focus / mouseover by name (`FindNamedUnit`, case-insensitive, full or short); keyed by GUID through `ns.RankWatchIgnorableUnit`, class stored for coloring.

#### Ability Alerts While Leveling

- Code stays in `Rank-Watch-Level-Up.lua`: module `LevelUpAlerts`, always subscribed to `PLAYER_LEVEL_UP`; gated per ding by `rankWatch.levelUpAlerts` (sub-options `levelUpAlertsPast`, `levelUpAlertsPet`, `levelUpAlertsPetPast`), not by Rank Watch's switch or the standalone add-on. Not on Mists (file not loaded).
- Its own feature switch: an `ns.FEATURES` record on `rankWatch.levelUpAlerts` with no `apply` (the kit writes the value; nothing to subscribe), inserted after Enhanced Spellbook. So it is on the root panel's Features, More Features, and atop its page.
- Uses the event's level argument (`UnitLevel` still reports the old one) and reads `ns.WhatsNextRows` / `ns.WhatsNextPetRows` (Enhanced Spellbook's What's Next?), which work with the Spellbook off.
- Class lines: `source == "TRAINER"` rows still `AVAILABLE`, split into this level's and earlier ones.
- Pet lines (only with `ns.HasWhatsNextPet()`): hunters from `HUNTER_PET_LEVEL`; Beast Training (`TRAINER`) rows whose spell the hunter hasn't learned (`not row.ready`); Forever's `HUNTER_TRAINER` rows not `KNOWN`/`OTHER`, earlier ones only with a pet out and `AVAILABLE`; taming ranks never. Warlocks: only this level's demon rows, never a "skipped" line.
- Panel: `Options/Enhanced-Spellbook/Options-Ability-Alerts.lua` (registry `AbilityAlerts`), a sub-panel of Enhanced Spellbook, registered only where `ns.BuildAbilityAlertsOptions` loads (`RegisterSpellbookPanels`, `Options.lua`). `Kit.FeatureSwitch("rankWatch.levelUpAlerts")`, three `Kit.SubToggleRow`s (pet-past hidden while pet is off), Example; sub-rows and Example hide while the switch is off.
- `ns.LevelUpAlertExample` builds the panel Example from `ns.ClassTrainerRows` and `ns.PET_ABILITIES` / `ns.DEMON_ABILITIES` (`SampleSets`).

#### Rank Watch Panels

- `Options-Rank-Watch.lua`: description, `Kit.FeatureSwitch("rankWatch.enabled")` (applies through `ns.SetRankWatchEnabled`), standalone status line, Grace Periods (`GraceRow` × 2, `GRACE_MAX`), Messages: Whisper toggle, then under it while Whisper is on the who-whispers line (`WhispererHelper`), the tip composer, the opt-out description and the opt-out offer/reply composer (`language = false`); then Print and its Example. `Kit.HideAllExcept` (last in the builder) leaves only description, switch and standalone notice while off.
  - Composer slots: tip at 11.1 (fills to 11.49), opt-out at 12 (fills to 12.29); see `ns.DefineWhisperComposer`'s fill rule.
  - Examples use the player's own class's ladder (`SampleRows`), `SamplePetRows`, `ns.SAMPLE_NAMES`, `ns.SAMPLE_PET_NAME`, the Imp family name via `ns.IMP_CREATURE_FAMILY_ID` (`SampleDemonName`), through the real builders (`ns.FillRankWatchTipWhisper`, `ns:BuildRankWatchTipWhisper`, `ns.BuildRankWatchOtherLine`).
- Reported Ranks (`Options-Rank-Watch-Tracked.lua`, registry `RankWatchTracked`): tree of classes by localized name, each followed by a `<CLASS>_PETS` page where pets have ranks; one inline group per ladder, sorted by plain title (`SortKey`); top rank disabled and shown checked while any lower rank is tracked. Each page has Check All / Uncheck All (confirmed with the page's plain name, grayed when nothing would change). `Kit.PrepareTree` in `RegisterRankWatchPanels` sets the tree width and reselects the player's class on every close.
- Ignored Players (`Options-Rank-Watch-Ignored.lua`): Ignore Target (`Kit.ButtonRow` captioned `RANK_WATCH_IGNORE_TARGET_CAPTION`, disabled without an ignorable target), rows by name with the remove icon; adding and removing print `RANK_WATCH_IGNORE_ADDED` / `_REMOVED`; `ClassOf` back-fills `ignoredClasses` from `GetPlayerInfoByGUID`.
- Both sub-panels are builder functions (rebuilt on repaint), not hidden behind the switch; `ns.AddFeatureOffLine` says when it's off.

#### Rank Watch Diagnostics

- `ns:BuildRankWatchContextReport` (Report-Runner `rankWatch`): switches, gates, whisperer (re-derived without calling `ns.RankWatchWhisperer`, which would claim the lead; names whether the leader is online), prefix registration, how casts are seen per flavor, ladder counts, untracked choices, ranks lacking client rank text, announced count, group levels, own ladders' best rank, Ability Alerts state and next-level counts (`NextPetLine`). Reads `ns.db.global.rankWatch` raw.
- `ns:BuildRankWatchMessageLengthReport` (Report-Runner `messagesRankWatch`): each tip form built with the locale's longest rank name and a `NAME_MAX_LETTERS` pet name, then the opt-out offer and reply.
- Manifest rows (empty on Mists): cluster and combat-log / damage-meter API checks, rank name and subtext lookups for the player's class, Validate Data sources for both Rank Watch tables.

### Enhanced Spellbook

#### Hosts and the Window

- `GoodToGoSpellbookFrame` (`Spellbook-Window.lua`, `WINDOW_WIDTH` × `WINDOW_HEIGHT`, on `UIParent`, in `UISpecialFrames`) replaces the game's book rather than docking to it: OnShow runs `ns.CloseGameSpellbook`, out of combat only.
  - Built lazily on the first `ns.ToggleSpellbookWindow` (`ns.ToggleSpellbookPage` is the same function); until then `ns:RefreshOpenPages()` returns false. The toggle prints `SPELLBOOK_IS_OFF` while the feature is off.
  - `FitToScreen` only shrinks, counting the docked panel's width and `TAB_HEIGHT`, inside `SCREEN_MARGIN`.
  - Position: `global.windowPosition` (one spot for every character), placed by `PlaceWindow`, saved on drag stop (`SavePosition`; `ns.SaveSpellbookWindowPosition` from a docked panel's drag too). `ns.HasSavedSpellbookWindowPosition` / `ns.ResetSpellbookWindowPosition` back the options page's Reset Position row. Title from `ns.MenuKit.WindowTitle`.
  - `selectedTab` survives closing. Leaving tab 1 hides the docked panels. `ns.ShowSpellbookTab(index)` with `ns.SPELLBOOK_TAB_BOOK` / `ns.SPELLBOOK_TAB_PET_BOOK`.
  - Tab buttons prefer `CharacterFrameTabButtonTemplate`, else `PanelTabButtonTemplate`; text capped at `TAB_MAX_TEXT_WIDTH`.
- `TABS`: Spell Book, What's Next?, Pet Spell Book (class gate, `ns.HasPetSpellbook`; Mage only where `ns.EXPANSION` is TBC or later), Pet What's Next? (data gate, `ns.HasWhatsNextPet`). There is no macro tab: "Macro Tab" in code means Macro Storage (`Macro-Tab.lua`).
- **Classic host** (`Spellbook-Host-Classic.lua`, Vanilla/TBC/Mists TOCs): a tab on `UIParent`, `AnchorSkillLineTab` under the `GetNumSpellTabs()`th skill-line tab (else the last shown), shown only for the spell `bookType`. Hooked with `HookScript` and `hooksecurefunc(book, "Update")` only.
- **Modern host** (`Spellbook-Host-Modern.lua` + `Spellbook-Tabs.lua`, Camelot): `ns.SpellbookTabs:RegisterTab` stacks side tabs down `PlayerSpellsFrame`'s right edge.
  - Steps past other add-ons' tab-sized frames (`CollectObstacles`, `NextFreeColumnSlot`); its own frames sit in `owned`, Blizzard's are excluded.
  - `ScreenRect` guards `IsAnchoringRestricted`, `pcall` and `ns.IsSecretValue` on foreign frames.
  - Hidden on the gamepad UI, an invisible book, or the Spellbook off. Takes the book's scale and sits under its `NineSlice` strata.
  - Attaches on `ADDON_LOADED` for `Blizzard_PlayerSpells` (`ns:OnAddonLoaded`, which then drops the event; subscribed by this file only when the add-on isn't loaded yet) and EventRegistry callbacks.
- `ns.SyncSpellbookHost` exists in both hosts; `ns.SetSpellbookEnabled` calls it.
- Every launcher and window frame is parented to `UIParent` (or the add-on's own window) and only anchored to Blizzard frames.
- The page strip is custom (`Spellbook-Paging.lua`): Blizzard's paging template reads a format string the Classic clients lack. `SetMaxPages` / `SetCurrentPage` never fire `OnPageChanged`.
- Binding: `BINDING_NAME_GOODTOGO_TOGGLE_SPELLBOOK` → global `GoodToGo_ToggleSpellbook` (`Key-Bindings.lua`).
- **Tooltips** share two helpers (`Spellbook-Utilities.lua`): `ns.AddSpellbookTooltipTitle(title)` (title gold, `ADDON_SHORT_NAME` gray on the right: tabs, tiles, tooltip ranks, What's Next ranks; the Inventory Report copies the shape) and `ns.AddSpellbookClickLine(job, click)` (job blue left, click gray right, one line per click). Anchored by `ns.SetTooltipOwner`.

#### Menus

- Every Spellbook pop-up menu runs through `ns.OpenMacroMenuPanels(owner, generator, beside)` (`Macro-Menu-Panels.lua`), drawn on Menu-Kit panels (`Kit.CreatePanel`, one per level `GoodToGoSpellMenu<level>`, up to `MAX_DEPTH`); Style Guide MENUS owns the look.
  - Users: the tile menu (`ns.ShowMacroMenu`), the category menu (`ns.ShowCategoryMenu`), the page and What's Next settings gears, the Conditionals condition menu, the Cast Sequence End and Reset menus. Only the controls-row dropdowns (`CreateSpellbookDropdown`, `Spellbook-Widgets.lua`) use `ns.SetupKitDropdown` / `ns.MenuKit.OpenContextMenu` instead.
  - The generator is written against the game's menu description API (`CreateButton`, `CreateCheckbox`, `CreateRadio`, `CreateTitle`, `CreateDivider`, `CreateSpacer`, `SetTooltip`, `SetEnabled`) plus its own `CreateHeader`, `CreateText`, `SetValue`, `SetNote`, `SetLabel`, `SetSetting` (a sub-menu that sets something draws as the kit's value row), so sections read as game-menu code. A checkbox with a value shows it in On's place; a disabled element is gray on both sides.
  - A leaf button is an action and closes unless its callback returns `MenuResponse.Refresh`; a checkbox or radio redraws in place unless it returns `MenuResponse.CloseAll`. The Conditionals condition menu and Cast Sequence End menu redraw in place on a pick. A redraw reruns the whole generator and reopens open sub-menus by label (`ChildByKey`).
  - Closes after `CLOSE_DELAY` off the owner and panels, when the owner hides, or on Escape (level 1 in `UISpecialFrames`). Opens at the cursor, or with `beside` off the owner's corner toward the roomier side (`FLYOUT_ROOM`). `ns.IsMacroMenuPanelsShown` keeps tile hover effects quiet (`MenuOpen`, `Macro-Button.lua`).
- **Tile menu** (`Macro-Menu.lua`): only for macros with `ns.HasOptions` (not consumables). `menuState` carries the macro and `change(set)`, which runs the setter, `ns.RefreshSpellbookPage`, then re-finds the macro (`ns.MacroMenuRebuiltMacro`).
  - Order: header; Conditionals and Cast Sequence (open their panels); featured checkboxes (`ns.MacroMenuFeaturedOptions`); Target, Grouped Spells, Rank; When; First and Then; Error Messages; Macro Storage; Macro Text (length vs `ns.MACRO_BODY_MAX_LENGTH`, lines from `ns.MacroMenuBodyLines`); divider; Duplicate (`ns.OffersDuplicate`); Delete (bar count via `ns.MacroBarCount`, always confirmed through `ns.ConfirmDelete`).
  - Sections live in `Macro-Menu-Sections.lua` (`ns.MacroMenu<Section>`), helpers in `Macro-Menu-Utilities.lua`, tooltips, notes and the When/First/Then/Errors tables in `Menu-Utilities.lua` (`ns.MENU_DESCRIPTIONS`, `ns.MENU_NOTES`, `ns.MENU_COMBAT`, `ns.MENU_REPEAT`, `ns.MENU_FIRST`, `ns.MENU_ERRORS`, `ns.MenuThenOptions`).
- **Category menu** (`Category-Menu.lua`, header of a page category): applies cursor/noToggle, Target, Grouped Right-Click, Rank (Highest or Dynamic only), When, First, Then, Errors to every macro under it; Reset uses `ns.ResetMacroSettings`.
- Middle-click on a tile asks (`GOODTOGO_RESET_MACRO`), then `ns.ResetMacroSettings`.

#### Events

- Module `Spellbook` (`Spellbook-Core.lua`, `ns.RegisterEventModule`). `EVENT_HANDLERS` maps each event to an `ns:On<X>` name resolved when it fires, so later files supply the handlers.
  - `PLAYER_FOCUS_CHANGED` only when `ns.FLAVOR ~= "Vanilla"`.
  - `EVENT_UNITS` filters unit events (`UNIT_PET`, `UNIT_LEVEL`, `UNIT_TARGET`).
  - `WHILE_OFF_EVENTS` dispatch with the feature off. `LOGIN_REGISTERED_EVENTS` (trainer events) subscribe only once the handler exists. `OWNER_REGISTERED_EVENTS` are subscribed by their own file (`Spellbook-Tabs.lua`).
  - PLAYER_LOGIN runs `OnPlayerLogin` migrations, then `ns.MigrateSpellbookBinding`, before subscribing.
- `ns.SetSpellbookEnabled(true)` invalidates usable slots and rank rows, then `RefreshMacros`; `false` hides the window. Macros freeze as last written.
- `ns.ApplySpellbookProfile` (from `Features/Core.lua` ApplyProfile, only while on): rank rows, `RefreshMacros`, `RefreshWhatsNext`.
- `ns:RefreshMacros()`: no-op while off; refreshes the open pages, else `CollectMacros` + `SyncAllMacros`.
- `SPELLS_CHANGED` (`spellsPending`): invalidates rank rows, refreshes What's Next, `ns.GroupSpellLearned()`. With no page open it wipes `ns.macros` for a lazy rebuild, and rebuilds and syncs now only when a group spell was learned or `ns.HandOverDue()`.
- `SPELL_DATA_LOAD_RESULT` acts only on `ns.TakePendingRank` hits, or `ns.TakeRequestedSpell` hits while unlearned spells or What's Next show (`ns.SpellName` requests each ID once).
- `SKILL_LINES_CHANGED` (`OnSpellbookSkillLinesChanged`) only where `ns.READS_PROFESSIONS`, and only when `ProfessionsKey` changes.
- `PLAYER_EQUIPMENT_CHANGED`: invalidates usable slots; redraw only in combat, else `ns.QueueMacroSync`.
- `PLAYER_LEVEL_UP` passes the event's level on (`UnitLevel` is stale during the event).
- Pet changes (`petPending`): pet rank rows only, `ns.QueueRankRewriteFor("pet")`, redraw only when a pet tab shows.
- `ACTIONBAR_SLOT_CHANGED` → glows and Mark Placed redraw + `ns.OnRankBarSlotChanged`. `PLAYER_REGEN_DISABLED` → `ns.RewriteRanksBeforeCombat` + `ns.CancelSpellPick`. `UPDATE_MACROS` → tile and macro-count redraw.

#### Build → Sync → Draw

1. **`ns.CollectMacros`** (`Macro-Builder/Macro-Builder.lua`):
   - Wipes `ns.macros`, `ns.MarkRankBodiesStale`, `ns.ResolveClassConfig`, `ns.ReadSpellbook`, then `ns.ForEachClassSpell`.
   - One macro per spell (`MakeMacro`; `ns.HandOverMacro` runs before it is made), then Duplicates (`ns.MacroCopies`, `MakeCopyMacro`), rank copies (`ns.ShowsAllRanks`, `MakeRankMacro`), unlearned spells (`ns.ForEachUnlearnedSpell`). A grouped spell superseded by a learned later one is hidden unless `ns.ShowsGroupedSpells()`.
   - Discovery spells at or above `ns.SOD_FIRST_SPELL_ID` are hidden off Discovery (`HIDES_SOD_SPELLS`, `Class-Spells.lua`).
   - `FoldSpecializations` (`ns.PROFESSION_SPECIALIZATIONS`) and `ns.FoldRangedAttacks` (one Shoot macro with `[worn:]` clauses; carrier is the first already tagged, else the first learned). Folded macros are hidden on the page but still synced.
2. **`ns.SyncAllMacros`** (`Macro-Sync.lua`): `ns.ReadMacroIndexes` once (tags and names, character macros first), then `ns.SyncMacro` each.
   - `ns.FindMacroIndex` looks up by tag, then by name (`PickTagged`), then by legacy names; returns index, how found, shared flag.
   - `SyncAt` rewrites only a changed body that `Fits` `ns.MACRO_BODY_MAX_LENGTH` (`ns.WarnOnce` keyed `tooLong:` plus `ns.MacroIdentity`; `ns.MacroBlockReason`). Renames legacy, old-prefix and replaced-spell names, moving the ownership record; records a player-chosen name as owned when the tag matches and isn't shared.
   - While `MacroFrame` is shown every sync is a no-op (`ns.IsMacroUIOpen`). A one-time `OnHide` hook marks rank bodies stale and re-syncs.
   - In combat it queues (`ns.QueueMacroSync`); `ns:OnPlayerRegenEnabled` flushes it and queues `ns.QueueRankRewriteAll`.
3. **Draw** (`Spellbook-Page.lua`): `ns.SpellbookPageCategories`, `ns.PackSpellbookRows` / `ns.PaginateSpellbook`, `ns.SetMacroButton` per tile. One `ns.ScanActionBars` per layout feeds Mark Placed and glows; tagged bar macros match by tag only, bar spells by name so any rank counts. Refresh then fires `ns.OnSpellbookPageRefreshed` listeners (docked panels).
4. **Pickup** (`ns.PickupMacro`): consumable tiles only pick up their macro (`wowName`). Otherwise creates the WoW macro in the list `ns.MacroCreatePerCharacter` picks (a real boolean): the macro's Macro Storage list first, the other once that is full, nil when both are (`ERROR_MACRO_SLOTS_FULL`). Assigns the tag and re-checks `Fits`, because a wider tag adds a byte; records ownership; `ns.ForgetPlacedRankMacros`.

- Every menu or panel change runs `ns.RefreshSpellbookPage`, which rebuilds every `ns.macros` entry. Menus re-find their macro (`ns.MacroMenuRebuiltMacro`); panels re-find theirs by `SettingsKey` (`CurrentMacro`, `Docked-Panel.lua`).

#### Macro Storage (`Macro-Tab.lua`)

- Setting `macroTab`: `"general"` (`ns.MACRO_TAB_GENERAL`) or nil for Character (`ns.MACRO_TAB_CHARACTER`, the default); read by `ns.MacroTab`, chosen in the tile menu's Macro Storage.
- `ns.SetMacroTab` refuses in combat, with the Macro UI open, or when the other list lacks free slots for every macro that moves (`ERROR_MACRO_SLOTS_FULL`), leaving the choice unchanged. Then it moves every page macro sharing the `SettingsKey` whose WoW macro sits in the other list (`MoveTo`): `CreateMacro` in the new list with `ns.WowMacroIcon`, ownership record moved (`OwnedList`, `OwnerRecord`), each bar slot re-placed (`ns.MacroBarSlots`), old one deleted, then `ns.ForgetPlacedRankMacros`.
- Created before the delete because creating in one list never shifts the other's indexes. The icon comes from the add-on, not `GetMacroInfo`, which returns the spell's icon for a question-mark macro.
- A General macro still belongs to its character through the tag identity (`ns.MacroOwnerKey`).
- `macroTab` is kept by Duplicate and Delete's reset (`KEPT_SETTINGS`, `Macro-Copies.lua`) but not by the middle-click or category reset (`ns.ResetMacroSettings` resets `COPIED_SETTINGS` only), since the WoW macro stays where it is.

#### Macros per Spell

- **Settings keys** (`Macro-Settings.lua`): `ns.MacroSpellKey` = the Rank 1 ID (`BaseSpellID`, preferring `ranks.baseID` from `ReadSpellbook`) or `consumable:<type>`; `ns.SettingsKey` adds `#n` for a Duplicate, `@rankID` for a rank copy. Each option is a profile table keyed by these (`ns.SpellSettings`). Survives rank-ups and locale changes. The file's header lists every option key.
- **Defaults** (`Macro-Options.lua`): `SetOption` stores nil when equal to `ns.MacroDefault`. `SetChoice` stores every key of a choice true/false unless the whole choice matches defaults.
- **Kinds** (`Macro-Kinds.lua`): `ns.MACRO_KINDS`; `ns.MacroKind` decides in order cursor, buff, resurrect, target, form, self. `ns.KindDefault` reads the shipped `kindDefaults` (`SPELLBOOK_DEFAULTS`) for `ns.DEFAULTABLE_OPTIONS`; nothing in the UI writes a kind default. A kind's target list (`kindDefaults[kind].targetPriority`) is read by `ns.KindTargetPriority`.
- **Offered options**: the `OFFERED` predicate table (`ns.OffersOption`). Once-per options not with a Cast Sequence or pet; `startAttack` hidden on friendly, buff and resurrect kinds unless already on.
- **Ranks** (`Macro-Rank-Option.lua`): `targetRank` (Dynamic Rank) offered with more than one known rank on help or exists targets (`ns.OffersTargetRank`); `fixedRank` stores a spell ID (`ns.FixedRankID`). `ns.SetAbilityRank` stores `targetRank` explicitly unless the whole choice is default.
- **Duplicates** (`Macro-Copies.lua`): `ns.DuplicateMacro` copies `OWN_SETTINGS` (`COPIED_SETTINGS` + `KEPT_SETTINGS`), list tables one level deep. `ns.ResetMacroOptions` (Delete) clears `OWN_SETTINGS`; `ns.ResetMacroSettings` clears `COPIED_SETTINGS`; `ns.MoveSpellSettings` moves `OWN_SETTINGS` (handover).
- **Icons** (`ns.WowMacroIcon`): the question mark, so `#showtooltip` picks the spell's icon. A profession's macro gets its tile's icon, because the game resolves a profession's name to the wrong icon; sync sets that icon on existing profession macros and leaves every other icon to the player.
- **Names** (`ns.WowMacroName`): `macro.wowName`, else `ns.MACRO_NAME_PREFIX` plus the name trimmed by `ns.TrimMacroName` (UTF-8 safe) to `ns.MACRO_NAME_MAX_LENGTH`; rank copies add `MACRO_NAME_RANK_SUFFIX`.
- **Body order** (`CastBody` / `ns.MacroBody`, `Macro-Body.lua`):
  1. `#showtooltip` (names the spell when use items, a stance or a reset would steal it)
  2. One `/stopmacro`, ahead of the mute, so a stopped press never leaves sound muted.
  3. `GtGMute(1)`, `/stopattack`, `/stopcasting`, `/cancelform`, then `/cleartarget [dead][help]` + `/targetenemy [noexists]` (or the `[harm]` / `/targetfriend` pair).
  4. `/use` slots, stance line (`StanceSlot`: `stanceIds` against `GetShapeshiftFormInfo`, else `stanceSlots`).
  5. The cast line (`CastLine`): Conditionals rows, then `btn:2` group clauses, then target priority (`TargetClauses`; `player` ends the list, a last-place target becomes the plain cast). The pet option replaces the clauses; Cast Sequence via `ns.CastSequenceResetText` / `ns.CastSequenceTail`. Neighbouring clauses casting one spell merge.
  6. Auto shot, `/startattack [nostealth]`, `/petattack`, error clear, `GtGMute()`.
  7. The tag line (`ns.TaggedBody`).

  Shape: `/cast [mod:shift] Frost Nova; [@mouseover,harm,nodead][] Fireball` then `#a7`.
- Limits: `ns.CONDITIONALS_MAX_ROWS`, `ns.CONDITIONALS_MAX_CONDITIONS`, `ns.CAST_SEQUENCE_MAX_STEPS`. `oncePerCombat` / `oncePerTarget` become `/castsequence reset=… X, NULL`.
- **Conditionals** (`Conditionals.lua`): `ns.CONDITIONS`; `ns.ConditionBlockReason` (combat conditions vs the macro's combat check; `rightClick` vs `groupVersion`); `ns.ConditionalSkipReason` greys a row shadowed by an earlier superset row (an earlier ranged row never shadows). A ranged row writes one clause per `ns.KnownRangedAttacks`. Slot spells: `ns.ConditionalSpellOf` / `ns.ConditionalPickOfSpell` (`Slot-Spells.lua`), by ID never by name.
- **Cast Sequence** (`Cast-Sequence.lua`): not on the ranged macro (`ns.OffersCastSequence`); blocked while pet is on (`ns.CastSequenceBlockReason`); on with steps or stop-on-NULL alone (`ns.IsCastSequenceOn`); default resets (`DEFAULT_RESETS`) stored as nil.
- **Dynamic Rank** (`Dynamic-Rank.lua`, `RankFor` in `Macro-Body.lua`, `RANK_LEVEL_GAP`) writes the highest rank fit for the unit's level.
  - Top rank (nil) for the player, a secret identity, a non-plain value, an unhelpable unit or an unknown level.
  - Rewrites only macros on a bar (`PlacedRankMacros`, by tag else name; cached until `ns.ForgetPlacedRankMacros`, `ns.MarkRankBodiesStale` or a changed bar slot), and only for the units those macros watch (`UNITS_WATCHED`).
  - `QueueRankRewrite`: one pending scope; two units in one burst become "all". Unchanged bodies are skipped once synced (`rankBodiesSynced`).
  - Never in combat; `PLAYER_REGEN_DISABLED` runs `ns.RewriteRanksBeforeCombat` synchronously, `ns:OnPlayerRegenEnabled` queues `ns.QueueRankRewriteAll`.
  - Mouseover leaving fires no event, so it is polled (`MOUSEOVER_POLL_SECONDS`); a secret mouseover identity counts as gone.
- **Mute** (`GtGMute`, `Mute-Errors.lua`): zeroes the on `MUTED_CVARS`, restores exactly what it read; a one-second timer backstops a press that never reaches `GtGMute()`; a second mute while muted no-ops.

#### Tags and Ownership (`Macro-Tags.lua`, `Macro-Lookup.lua`, `Macro-Delete.lua`)

- A macro's last line is its tag (`ns.BodyTag` reads only that line): `TAG_PREFIX` plus base-62 `TAG_DIGITS`, padded to `TAG_WIDTH` and growing past it. `UNASSIGNED_TAG` holds the length until the macro is written.
- `global.macroTags[identity]`: `ns.MacroIdentity` = `MacroOwnerKey:spell|copyN|rank <rankID>:<spellKey>`, so a renamed or moved macro is still found and a re-placed one gets its old tag back.
  - `ns.MacroOwnerKey` uses `ns.GetCharacterProfileName()`, not `ns.db.keys.char`, which can be a placeholder.
  - `ns.AssignMacroTag` skips tags already in any body (Macro Spellbook uses the same scheme) and bumps `global.macroTagCount`.
- **Ownership** lives where no profile change can lose it: `global.ownedMacros[name] = ownerKey` for General macros, `char.ownedMacros[name] = true` for character macros (`ns.OwnedMacroList`, `ns.MacroOwnerRecord`; README-Notes exception). `ns.LegacyOwnership` returns "owned" or nil.
- **Delete Macros** (`ns.DeleteAddonMacros(general)`, Options buttons with `ns.CountAddonMacros`): only macros with a handed-out tag **and** an ownership record (`AddonMacroIndexes`), highest index first; refuses in combat or with the Macro UI open; refreshes first when enabled. `ns.DeletePageMacro` deletes one WoW macro and its record, then removes a Duplicate (`ns.RemoveMacroCopy`) or resets options (`ns.ResetMacroOptions`).
- Slot limits: `Constants.MacroConsts`, then the globals, then a literal (`ns.MaxAccountMacros`, `ns.MaxCharacterMacros`).
- **Group handover** (`Group-Handover.lua`): a learned successor (`ns.ReplacedSpells`) with no macro of its own takes the old spell's tag and settings (`ns.HandOverMacroTag` with each Duplicate's, `ns.MoveSpellSettings`), and the sync renames the macro. Runs even with no page open. `ns.GroupSpellLearned` only notes on its first call.

#### Ranks, Trainers, What's Next

- Ranks exist where `ns.HAS_SPELL_RANKS`.
- `ns.ReadSpellbook` (`Spell-Ranks.lua`): known ranks, plus unknown ranks above the highest known only (the book keeps only the top rank on some clients). `baseID` is the lowest rank, taken before that filter. Falls back to `C_Spell.GetSpellLevelLearned` for a level `LearnLevels` lacks.
- Learn levels (`LearnLevels`), in order: `ns.ClassTrainerRows` (faction and race filtered), `ns.RecordedTrainerSpellLevels` (`profile.trainerSpells[class]`, recorded by `Trainer-Recording.lua` through `ns.GetTrainerServiceSpellId`, skipping pet services and `ns.IsPetAbilitySpell`), then a same-name `requires` → level 1.
- `Class-Config.lua` empties every other class in `CLASS_SPELL_LISTS` and `TRAINER_SPELLS` at load, keeping the keys. `ns.ResolveClassConfig` waits for a group until all its names load; forms and toggles come from the stance bar.
- What's Next is computed live (`ns.WhatsNextRows(level)`, `ns.WhatsNextPetRows(level)`): statuses `ns.WHATS_NEXT_STATUSES` / `ns.WHATS_NEXT_PET_STATUSES`, sources `ns.WHATS_NEXT_SOURCES` / `ns.WHATS_NEXT_PET_SOURCES`. A known later rank marks lower ranks known. Ability Alerts While Leveling (`Features/Rank-Watch/Rank-Watch-Level-Up.lua`) reads both, with the Spellbook on or off.
- The three list pages differ only by model (`ns.WHATS_NEXT_MODELS`, `Whats-Next-Models.lua`): one builder (`Whats-Next-Page.lua`), controls (`ns.BuildWhatsNextControls`, `Whats-Next-Controls.lua`: settings gear from `model.toggles`, filter box, source filter offering only sources present, the shared sort `ns.WhatsNextSort`), layout (`ns.WhatsNextSections`, `ns.WhatsNextPaginate`, `ns.WHATS_NEXT_METRICS`). A class row click opens that spell's Spell Book page (`ns.SpellbookPagesBySpellName`); a known pet row opens the Pet Spell Book tab.
- The Pet What's Next tooltip names beasts in English from data (`ns.TAMEABLE_BEASTS`, `MAX_BEASTS`; README-Notes). Grimoire names load through `ns.RequestItemInfoEvents` (`GRIMOIRE_WAITER`); `Features/Item-Info.lua` calls `ns.OnWhatsNextItemInfoReceived`.
- Tooltip ranks (`Spell-Ranks-Tooltip.lua`, rows from `Spell-Rank-Lines.lua`) hook through `ns.AddSpellTooltipPostCall`. Gated by GameTooltip only, once per tooltip, `ns.spellTooltipHasOwnRanks` (set around the page's own `SetSpellByID`), the switch, `global.abilityTooltipRanks`, out of combat and `ns.IsPlain`. Cache keyed by player and pet level, cleared by `ns.InvalidateSpellRankRows(petOnly)`.
- Options (`Options/Enhanced-Spellbook/`): `ns.BuildSpellbookOptions` holds only what can't live on the book (switch, tooltip ranks, Delete Macros per list); the page settings live on the book's gear. `Options-Ability-Alerts.lua` (`ns.BuildAbilityAlertsOptions`) is the Ability Alerts panel only; its logic is Rank Watch's (see Rank Watch).

#### Docked Panels (`Macro-Builder/`)

- Conditionals and Cast Sequence share the `Docked-Panel.lua` shell (`ns.DockedPanel`), one docked at a time, parented to the window; dragging the panel moves the window. Showing docks `PANEL_WIDTH` (`ns.DockSpellbookPanel`).
- Rows hang off the hint (`panel.hint`) through `Docked.SetRowPoint(panel, region, y)`, `ROWS_GAP` below it, so the rows follow the hint's height rather than a fixed top offset.
- They take the keyboard only in pick mode; Escape cancels the pick; nothing in combat. The footer shows the untagged text; its byte meter measures the whole body, tag included (what the game stores), gold at `METER_WARNING`, red over `ns.MACRO_BODY_MAX_LENGTH`.
- `Conditionals-Panel.lua` builds the shell and `ns.ConditionalsUI`, which `Conditionals-Rows.lua` (loaded after) fills with rows. Widgets come from `ns.PanelWidgets` (colors `ns.CONDITIONALS_COLORS`).
- Pick mode (`Spell-Pick.lua`) is owner-based (`ns.SetSpellPicking`); starting one owner's pick ends the other's. Takes a tile click or a cursor drop (`ns.DropSpellOnSlot`; a page macro on the cursor is read back through `ns.FindMacroIndex`, else `GetMacroSpell`). `ns.StartSpellPick` refuses in combat.

### Mini-map Button and Menu (`Features/Minimap-Button.lua`, `Features/Minimap-Menu.lua`, `Features/Menu-Kit.lua`)

- **Button.** `ns.dataBrokerObject` is an LDB `launcher`: icon and clicks, no text. Hover (`OnEnter` → `ns.HandleLauncherEnter`, not `OnTooltipShow`) opens the menu; `OnLeave` is a no-op because the menu closes itself.
  - Registered once from Core's `PLAYER_LOGIN` (`ns.RegisterMinimapIcon`), after `ns.db`, against `ns.db.global.minimap`, so a profile change never moves it. `ns:ApplyMinimapButton` is the one show/hide path (`LibDBIcon:Refresh`), called by the root panel's toggle and `ns:ApplyProfile`.
  - Icon is the Food macro's pick (`ns.bestFoodID`, else `ns.MACRO_DEFAULT_ITEM_IDS["Food"]`, else `DEFAULT_ICON`). `ns.UpdateMinimapIcon` sets only the data object's `icon`; displays redraw from it. Called by `ns.RefreshSettings` and by the macro engine after each scan.
  - On Camelot (and Mainline) the icon is resized, re-centered and masked by hand, because LibDBIcon's `SetButtonIcon` path errors when another add-on replaced the icon.
- **Built on the kit's v1 path.** `Minimap-Menu.lua` makes two `Kit.CreatePanel`s (the menu, named `ADDON_NAME .. "Menu"` and listed in `UISpecialFrames`; one flyout at +20 frame level) and does its own placement, flyout, close timer and redraw. It does not use `Kit.CreateMenu`, `Kit.FeatureBlock`, `Kit.MoreFeatures`, `Kit.OptionsRow` or `Menu:HandleClick`; it defines `ns.ShowMenu`, `ns.HideMenu`, `ns.RefreshMenu`, `ns.IsMenuShown`, `ns.IsMenuFrame`, `ns.OpenFlyout` itself, and keeps local copies of `OptionTooltip`, `OnOff`, `AddList`, `MoreFeatures`. Strings go to the kit once through `Kit.SetText`.
- **Clicks.** The button keeps one click job: Right-Click ignores the current food. `ns.RunButtonClick` (from `ns.HandleLauncherClick`, defined after `BuildMainEntries`) builds the main entries and runs the row whose `click` matches the button (with a `Shift` prefix when held), so a click and its row can't disagree; false without `ns.db` or a match. The kit names a row's `click` gray on the row's right (`MENU_CLICK_RIGHT`).
  - Left-Click has no row: it falls through to `ns.ShowMenu(…, "click")`, opened with the longer `CLICK_CLOSE_DELAY`; a second click while a click holds it closes it. Middle-Click and the Shift clicks do nothing.
  - Rows: `ActionRow(label, run, tooltip, click)` (blue, its `click` named on the right, else nothing) and `ToggleRow(flip, tooltip)` (a feature switch). Every row click ends in `AfterChange` (`ns.RefreshSettings`).
- **Menu layout** (`BuildMainEntries`, top to bottom; the kit adds a spacer above every heading):
  - Header: add-on title, `ns.Version`.
  - Current Food (`AddCurrentFood`): `item` row with bag count, or the no-food note; Ignore (`ActionRow`, `click = "RightButton"`, tooltip `MENU_IGNORE_DESCRIPTION`).
  - Buff Duty (`AddBuffDuty`): On/Off from `ns.IsBuffDutyOnForClass`, except a session close (`ns.IsBuffDutyHiddenThisSession`) reads `MENU_BUFF_DUTY_PAUSED` and adds a `note` under the description. While on the title is a `submenu` keyed `BUFF_DUTY_WINDOW` that opens the Buff Duty window's own Options menu (`ns.ShowBuffDutyOptions`, `Buff-Duty-Options-Menu.lua`) beside the row; while off a plain `status`. Description; Toggle (`ToggleRow`), tooltip adds `MENU_BUFF_DUTY_TOGGLE_CLASS_DESCRIPTION`.
  - Restocker (`AddRestocker`): On/Off; description; while on, `AddRestockOrders` lists out then low rows from `ns.BuildRestockReminderLists` (same source as the entering-town reminder, so they never disagree), or an empty-list / stocked / nothing-low line. Toggle (`ToggleRow`); Open always, but while off it is `MUTED` with no `onClick` and a tooltip saying why (`MENU_RESTOCKER_OPEN_OFF_DESCRIPTION`).
  - Enhanced Spellbook (`AddSpellbook`), always: title with On/Off, description, Toggle (`FlipFeature`, which asks through the record's `confirm` before turning off, as More Features does), Open while on. Kept out of More Features by `SPELLBOOK_SETTING`, though its record has no `block`.
  - [Class] Macros (`AddClassMacros`, from `ns.GetClassMacroNotes` in `Macro-Notes.lua`): class-colored `submenu` opening the `macros` flyout (`section` per block, `value` rows: verb left, click right), then `item` rows for blocks without notes. Absent for a class with no notes or no known spells.
  - Ignore List (`AddIgnoreList`): this character's list only (Global lives in the panel), sorted by name with loading items last by ID; each `item` row unignores on click (`ns.UnignoreItem`, chat line), `Kit.REMOVE_ICON` shown on hover (`rightOnHover`, `ItemRow`'s `rightColor` MUTED), its own `tooltip` (the item, a spacer, `IGNORE_LIST_CLICK_HINT`); Clear Ignore List. Absent while empty.
  - More Features (`AddMoreFeatures`): `submenu` with an On/Off count, opening the `features` flyout of every `ns.FEATURES` record without `block` and not the Spellbook (and passing `gate`, if set), one `toggle` row each through `FlipFeature`.
  - Spacer, separator, Options.
- **Lists** cap at `LIST_MAX` rows, then a "N more" note (`AddList`).
- **Two homes.** Every menu write goes through the setter its options control uses: `feature.apply`, or `ns.OptionsKit.Set` for a record without one (`SetFeature`, shared shape with `Kit.FeatureSwitch`), `ns.SetBuffDutyForClass` (the window's close button and the Buff Duty panel's class toggles), `ns.IgnoreItem` / `ns.UnignoreItem` / `ns.ClearIgnoreList` (Ignore List panel). Reads use the same paths: `IsFeatureOn` resolves through `ns.OptionsKit.Get`. Toggle and More Features tooltips reuse the switch's `caption` / `desc`; a More Features row with `confirm` asks through `GOODTOGO_MENU_FEATURE_OFF` with the switch's own confirm text.
- **Opening and closing.** `ns.ShowMenu(anchor, flyoutKey, how)` anchors to the mini-map button or any LDB display's frame; returns early without `ns.db`; a reopen on the same anchor keeps place and flyout. `PositionMenu` picks the corner away from the screen edges once per open. `OnUpdate` closes it `HOVER_CLOSE_DELAY` (or `CLICK_CLOSE_DELAY`) after the cursor leaves button, menu, flyout and the Buff Duty menu (`ns.IsCursorOverBuffDutyOptions`), or when the anchor hides. Escape through `UISpecialFrames`. Entering a submenu row opens its flyout (`menu.onEnterRow` → `ns.OpenFlyout`); any other row closes it.
  - `RenderFlyout`: the `BUFF_DUTY_WINDOW` key hides the menu's own flyout and hands off to `ns.ShowBuffDutyOptions(row)`; every other key calls `ns.HideBuffDutyOptions(menu)`, which closes that menu only when it hangs off a row inside this one. `OnHide` does the same.
- **Redraw.** `ns.RefreshMenu` rebuilds in place while shown. Restocker and Ignore List rows whose items aren't cached report loading, and `Render` redraws once after `LOADING_RETRY`.
- **Menu Kit** (`ns.MenuKit`, `Features/Menu-Kit.lua`): shared copy, generic. Reads `ns.PALETTE`, `ns.L`, `ns.db`, `ns.FEATURES`, `ns:OpenOptionsPanel`.
  - Panels on a nine-sliced `Menu-Plate.tga` (`Kit.AddPlate`, half scale, `PLATE_ALPHA`), strata DIALOG, clamped, mouse-enabled. `Panel:Render(entries[, context])` lays out the kinds in the header comment (header, spacer, section, status, submenu, separator, action, toggle, choice, item, value, description, note; v1 `hint`); option kinds indent by `OPTION_INDENT`; notes and descriptions wrap to the settled width; re-layout only when `LooksKey` changes, clicks always rebind. Item rows read name, quality, icon from the client and watch `GET_ITEM_INFO_RECEIVED`, which refreshes only `Kit.CreateMenu` menus (`Kit.RefreshAll`).
  - `Kit.IsCursorOver` reads `GetCursorPosition`, not `IsMouseOver`, so a controller's virtual cursor counts. `Kit.IsInside` walks parents.
  - `Kit.CreateMenu(spec)`: a menu with sub-menus to `MAX_DEPTH`, its own placement (`hover`/`click`/`line`/`cursor`) and close timer. The first one created without `publish = false` becomes `Kit.mainMenu` and overwrites `ns.ShowMenu` and kin. Good to Go's callers, both `publish = false`: the Restock List dropdown (`Restocker-Window-Menus.lua`) and Buff Duty's category and Options menu (`Buff-Duty-Options-Menu.lua`).
  - Rows register `AnyUp`. An entry's `click` of `"RightButton"` is named gray on the row's right (`TEXT.clicks`, `MENU_CLICK_RIGHT`). The main menu never scrolls; flyouts and dropdown lists (`scrollable`) scroll past `SCROLL_ROWS`. An entry's `helper` adds a HELP sentence under its tooltip (or an item's) after a spacer (`AddHelper`). VALUE and HELP colors fall back through `PALETTE_FALLBACK`. `HandleClick`: Left-Click opens the menu and holds it, or closes it when a click already holds it.
  - Other consumers: `Macro-Menu-Panels.lua` (Spellbook right-click menu on `Kit.CreatePanel`), `Buff-Duty-Frame.lua` (`Kit.AddWindowHeader`, `Kit.AddOptionsLine`, `Kit.WindowTitle`), `Buff-Duty-Party-Buffs.lua`; `Kit.WindowTitle` also titles the Spellbook and Restock List windows.
  - The game's menus in the kit's dress: `Kit.OpenContextMenu(owner, generator)` (and `Kit.Submenu`, `Kit.AddMenuHeader`) wraps `MenuUtil.CreateContextMenu`, clearing the menu's backgrounds (a skin's `backdrop` included) and laying the plate under it on acquire, restored on release. `ns.SetupKitDropdown` (`Features/Utilities.lua`) does the same for a game `DropdownButton`. `Kit.PlatePullout` swaps an AceGUI pullout's backdrop for the plate and puts it back on release, since AceGUI pools pullouts across add-ons.

### Options Shell (`Options/`)

- **Options Kit** (`Options-Kit.lua`, `ns.OptionsKit`): shared copy, never edited here (contents: the kit's own header and sections). Good to Go relies on: the grid published as `ns.OPTIONS_*`; `Kit.Get` / `Kit.Set` / `Kit.GetChoice` (store + dotted path, resolved on every read and write, never captured); row builders; `Kit.FeatureSwitch` / `Kit.FeatureSwitches`; `Kit.StatusLine` / `Kit.WarningLine`; `Kit.Example` / `Kit.SentLine` / `Kit.PrintedLine`; `Kit.ResetRow`; `Kit.ButtonRow` / `Kit.SubToggleRow`; `Kit.HideAllExcept`; `Kit.ItemList` + `Kit.WarmItems` + `Kit.ITEM_LINK_WIDGET`; `Kit.RegisterPanel` / `Kit.SubPanelTitle` / `Kit.PrepareTree`.
  - Strings reach it once through `Kit.SetText` in `Options-Utilities.lua`.
  - `ns.RefreshSettings` lives here: `NotifyChange` on every `ns.OPTIONS_REGISTRY` name, then `ns.RefreshMenu`, then `ns.UpdateMinimapIcon`. `Kit.Set`, `Kit.FeatureSwitch`, `Kit.ResetRow`, `Kit.ItemList` and every menu click end in it.
  - `ns:OpenOptionsPanel(key)` and `ns.IsOptionsPanelOpen` (no caller) live here too; panels open by the category ID captured at `Kit.RegisterPanel`.
- **Features** (`Options-Feature-Switches.lua`): `ns.FEATURES`, one record per master switch in the kit's record shape (`store`, `setting`, `name`, `caption`, `desc`, optional `apply`, `confirm`, `block`). All live in `ns.db.global`. Order is the menu's: blocks (Buff Duty, Restocker), then the rest, matching the settings tree. Drives the root panel's switches (`Kit.FeatureSwitches`), each panel's own switch (`Kit.FeatureSwitch(setting)`), More Features, `ns.AddFeatureOffLine`.
  - `block = true` (Buff Duty, Restocker) keeps a feature out of More Features. `confirm` on Spellbook and Consumable Macros (off freezes macros, which a player could read as deletion). A record without `apply` (Ability Alerts) is written straight to its path.
  - Where `ns.SetRankWatchEnabled` loaded, `table.insert` puts Ability Alerts at index 4 (after Enhanced Spellbook) and Rank Watch at 6 (after Consumable Macros).
  - `ns.FindFeature` errors on an unknown setting; safe from `Minimap-Menu.lua` because it is called at draw time.
- **Feature pages hide while off.** A feature's own panel calls `Kit.HideAllExcept(args, Off, keep)` last in its builder, keeping description, switch and any notice (Rank Watch, Restocker, Consumable Macros). Sub-pages stay editable and open with `ns.AddFeatureOffLine(args, setting[, pageSwitch])`: a silver line naming the off feature (or, with `pageSwitch = { isOn, name, page? }`, the sub-switch and, when given, the page holding it; `name` may be a function) plus a spacer, at orders 0.1 / 0.2. The sub-switch wording comes from `ns.OptionsSwitchOffStatus(name, page)`.
- **Registration** (`Options.lua`): `ns.RegisterOptionsPanels`, from Core's `PLAYER_LOGIN` after `ns.db` (the Profiles label is read from the AceDBOptions table). Order of `Kit.RegisterPanel` calls is the tree order: General root; Buff Duty (+ Group Buffs, Self-Buffs, Well Fed, Weapon Buffs, Scrolls, Flasks or Elixirs, Other Buffs); Restocker; Enhanced Spellbook (+ Ability Alerts, where loaded); Consumable Macros (+ Food & Drinks, Potions & Mana Gems, Bandages, Healthstone, Explosives, Class Macros, Ignore List); Rank Watch (+ Reported Ranks, Ignored Players, where loaded); Inventory Report; Readiness Report; Profiles; Feedback & Support; Diagnostic Tools. Every builder is registered as a function (rebuilt on every repaint).
  - `Kit.PrepareTree` (tree width `Kit.TREE_PIXELS`, reselect `home()` on every close): Self-Buffs and Reported Ranks on the player's class, Ignore List on the current profile.
- **Shared helpers** (`Options-Utilities.lua`): Good to Go's widths on the kit grid (`ns.OPTIONS_PROMOTE_WIDTH`, `ns.OPTIONS_LINK_WIDTH`); `ns.OptionsGroupContextToggle` / `ns.OptionsGroupContextRow` / `ns.OptionsGroupContextNone` / `ns.NoGroupContextTicked`; `ns.AddFeatureOffLine` / `ns.OptionsSwitchOffStatus`; `ns.PrintedExampleLines`; `ns.OptionsSpellDescription`; `ns.OptionsProfileSettings`. Feature-only helpers live in `Options/<Feature>/Options-<Feature>-Utilities.lua`.
- **Widgets** (`Options-Widgets.lua`): `ns.ICON_CHECKBOX_WIDGET_TYPE` (named in `Data/Data.lua`), the stock checkbox re-placed for an icon gap (`ns.RESTOCK_ICON_TEXT_GAP`) after image set, press and release; registered under its own name so other add-ons' checkboxes are untouched; set to nil where AceGUI has no stock CheckBox. Also `ns.OPTIONS_ICON_TEXCOORDS`. The item link cell is the kit's.
- **Root panel** (`Options-General.lua`): intro, Welcome Message (`global.showWelcome`), Enable Mini-map Button (inverse of `global.minimap.hide`, then `ns:ApplyMinimapButton`), Features (`Kit.FeatureSwitches`), Key Bindings rows from `KeyBindings()` (key text, Set Key → `ns:OpenKeyBindings`; the Buff Key row adds a copyable macro box; repainted by `OnUpdateBindings` in `Features/Key-Bindings.lua`), Commands (`/gtg`, `/restock`, Rank Watch's ignore line where loaded).
- **Feedback & Support** (`Options-Feedback-Support.lua`): `PARAGRAPHS` locale keys, `LINKS` read-only boxes from `ns.LINKS`, version line.
- **Item lists.** `Kit.ItemList(spec)` (Add from Bags, Add Item, sorted rows, optional action column and tag, Restore Defaults / Clear List at the foot); cold rows warm through `Kit.WarmItems` (bounded poll per registry name). Windows outside the options use `ns.WarmItemCache` (`Features/Item-Info.lua`) instead.
- **Slash commands** (`Options.lua`): `/gtg` opens the root, except `/gtg ignore Name` goes to `ns.IgnoreRankWatchPlayer` where loaded (README-Notes exception); `/restock` → `ns.HandleRestockerCommand`.

### Diagnostics

- **Off at every login, never saved** (`ns.diagnostics`, plain runtime table at file scope in `Diagnostics-Core.lua`). Turning the toggle off stops the log and clears every report. Strings are plain English in `ns.DiagnosticsStrings`, never in `Locales/`; the panel is titled `ns.DiagnosticsStrings.TAB` and registered by `Diagnostics/Options-Diagnostics.lua`, next to last in the Options group.
- **This add-on's part.** Everything else in `Diagnostics/` is the copied framework.
  - `Manifests.lua` creates empty `ns.DIAGNOSTIC_API_CHECKS` (`{ label, check }`), `ns.DIAGNOSTIC_SPELLS`, `ns.DIAGNOSTIC_NAME_LOOKUPS`, `ns.DIAGNOSTIC_DATA_SOURCES` (`{ label, sources = { ... } }`) and `ns.AppendDiagnosticRows`, which skips an API check whose label is already present and merges data-source rows sharing a label (Game-IDs: several features, one report).
  - `Manifests-<Feature>.lua` (Macros-for-Consumables, Restocker, Buff-Duty, Enhanced-Spellbook, Rank-Watch): each feature's API rows, data sources and context reports; `Manifests-Buff-Duty.lua` also defines `ns.DIAGNOSTIC_MESSAGES`.
  - `Message-Length-<Feature>.lua` (Macros-for-Consumables, Buff-Duty, Enhanced-Spellbook, Rank-Watch): build every sent line and macro body at its widest through the add-on's own builders, against its byte ceiling, sending and writing nothing; `Report-Runner.lua` calls each builder (`ns:BuildConnoisseurMessageLengthReport` and siblings). The widest-encoding locale (usually ruRU) is the canary.
- **Event Registration** (`ns:RunEventChecks`, `Code-Reports.lua`) probes each `ns.EVENT_NAMES` entry with `C_EventUtils.IsEventValid` and a register/unregister on a probe frame.
- **Event Log** (`Event-Log.lua`): `ns.DIAGNOSTIC_EVENT_EXCLUDE` is deliberately empty, since every registered firehose is sometimes signal. Firehoses are classified per firing in `ns:SuppressUncorrelatedMessage`: id-carrying events by `ns.MESSAGE_ID_FILTERED_EVENTS` (logged when a feature correlates them through Buff Duty's `ns.IsCorrelatedMessage` or the file's own `ConnoisseurCorrelates`, else counted), id-less ones by `GATED_EVENTS` (the handler's own test, or a decoder that writes the firing through `ns:LogEventNow`). `SPELL_UPDATE_COOLDOWN` is gated: folded as a swipe-only firing unless Bloodrage starts or ends its own cooldown (`DecodeBloodrageCooldown`, last answer in `bloodrageCooling`, only while Buff Duty tracks for your class). `UNIT_FLAGS` is gated the same way: logged only when a watched unit's PvP flag changes (`DecodePvPFlag`, its own copy of each unit's last flag).
- Validate Data looks every data row up on this client and prints TSV per kind, titled by `ns.DATA_FOLDER`'s file.

### Tests (`Tests/Run.lua`)

- Never in a TOC; `.pkgmeta` ignores `Tests`. Runs on Lua 5.1 (WoW's version; it uses `loadstring` / `setfenv`) from the add-on root: `lua5.1 Tests/Run.lua`; CI runs it through Common-Core. Exits 1 on any failure.
- **Event names**: a minimal Lua tokenizer; reads every `.lua` file the four TOCs list (not `Includes/`, `Locales/`) and fails on an event-shaped string `ns.EVENT_NAMES` lacks, found in: a table constructor assigned to an events-named variable, an events loop's inline list, `table.insert` into an events-named table, `event ==` / `~=` comparisons, or the own arguments of a `Set*Event*` / `Set*Handler` call. Self-tests the scanner on fixed cases first, and checks it reaches the Spellbook's `EVENT_HANDLERS` (`PET_BAR_UPDATE` in `Spellbook-Core.lua`).
- **Forever combat log**: a Camelot-TOC file naming `COMBAT_LOG_EVENT_UNFILTERED` fails unless its source holds the literal `ns.FLAVOR ~= "Camelot"` somewhere.
- **Other-client prune**: lifts `Core.lua`'s source from `local REALM_KEY_SEPARATOR` through the first `\nend\n` after `local function PruneOtherClientCharacters`, runs it in a sandbox (`type`, `pairs`, `ipairs`, `GetRealmName`, `ns.db`) both directions, including the older Forever name (MIGRATION).
- **Event log noise**: runs `Diagnostics/Event-Log.lua` in a sandbox against `UI_ERROR_MESSAGE` folding, correlated ids and id-less firings.

## Files That Change Together

- **New registered event**: add to `ns.EVENT_NAMES` (`Features/Core.lua`; behind a flavor guard if any client lacks it, repeated wherever a subscriber names it); subscribe through the module's `ns.SetModuleEvent` or wrapper (`ns.SetEventRegistered`, `ns.SetRankWatchEvent`) and its switch's sync; handler in the dispatch or handler map; if a firehose, classify it in `Diagnostics/Event-Log.lua` (`ns.DIAGNOSTIC_EVENT_EXCLUDE`, `ns.MESSAGE_ID_FILTERED_EVENTS` or `GATED_EVENTS`); run `Tests/Run.lua`.
- **New event module**: `ns.RegisterEventModule` in a file listed after `Features/Core.lua` in every TOC that loads the feature (its TOC position sets dispatch order); subscribe `PLAYER_LOGIN` at file load if it sets up at login; a new subscription wrapper must match `Set*Event*` / `Set*Handler` or `Tests/Run.lua` can't see it.
- **New flavor / TOC**: `Good-to-Go_<Flavor>.toc` (`## X-Flavor`, `## Interface`, its `Data/<Flavor>/` lines, host and detection file picks); `ns.EXPANSION` map in `Data/Flavor.lua`; a complete `Data/<Flavor>/` with the full file set; `TOCS` in `Tests/Run.lua`; drop its `.pkgmeta` ignore if it was forward-prep (`Data/Wrath`, `Data/Mainline`); flavor guards in `ns.EVENT_NAMES` and the Spellbook's `EVENT_HANDLERS`; `Tools/*.py` flavor lists (`FLAVORS`, `EMPTY_FLAVORS`, `FLAVOR_ORDER`).
- **New key binding**: `<Binding name=... category="BINDING_HEADER_GOODTOGO">` in `Bindings.xml`; its `BINDING_NAME_<name>` label beside the feature (plus `.luacheckrc` `globals` unless set through `_G[...]`); the global function its body calls (plus `.luacheckrc`); a Set Key row in `Options/Options-General.lua`; locale strings in `Locales/`; a rename also needs a login key move (`ns.MigrateBuffKeys` pattern) and, for a named binding, a hidden old declaration.
- **New client-difference API**: accessor in `Features/Utilities.lua` (and its Client Differences comment list); API rows in the feature's `Diagnostics/Manifests-<Feature>.lua` (modern and legacy separately); `.luacheckrc` `read_globals`.
- **New Lua file**: every TOC that should load it (Mists' Rank Watch exceptions); an existing file calling into it this release existence-tests the call (players who update mid-session and `/reload` don't have it).
- **New Diagnostics manifest or Message Length report**: `Diagnostics/Manifests-<Feature>.lua` / `Message-Length-<Feature>.lua` in all four TOCs, between `Manifests.lua` and `Report-Runner.lua`; the report entry and its strings in `Report-Runner.lua` / `ns.DiagnosticsStrings`.
- **New add-on global, slash command or popup**: `.luacheckrc` `globals` (`SlashCmdList` / `StaticPopupDialogs` fields).
- **New saved setting**: its key in `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`) or the feature's `AddDefaults` block, profile unless a concrete account-wide reason is written beside it; its options row; locale keys in every `Locales/*.lua`; a hook in `ns:ApplyProfile` if it is profile-scoped and applied imperatively; Rank Watch's `RESET_KEYS` if Reset Profile should reach it; a Diagnostics context line.
- **New setting that acts by group**: a `{ solo, party, raid, battleground }` default, all `true`; read through `ns.IsGroupContextOn` (or `ns.IsUseWhenActive` for a consumable's `<prefix>In` + `<prefix>Level` pair); `ns.OptionsGroupContextRow` or `ns.OptionsGroupContextToggle` plus `ns.OptionsGroupContextNone` on its panel; a Diagnostics context line. Consumable group reads are already inside `ns.GroupSignatureChanged`.
- **Changing a shipped default**: the default; for a change existing players must not feel, a raw migration before `AceDB:New` that writes the old value explicitly where the key is absent, with its own stamp written right after `AceDB:New` (`KeepPoisonsMacro` / `poisonsDefaultMigrated`, `Core.lua`); the defaults comment.
- **New locale key**: the same section of every `Locales/*.lua` (all eleven carry every key; `enUS.lua` is the default locale); never a whisper default (that is `Data.MESSAGE_LANGUAGES`) or a game name (Style Guide).
- **New fixed-key line to other players**: locale key(s); sent through `ns:Announce(channel, target, key, ...)` or a builder in `Features/Announcements.lua` over `ns:BuildAnnounceMessage`; a row in `ns.DIAGNOSTIC_MESSAGES` (`Diagnostics/Manifests-Buff-Duty.lua`) or the Rank Watch Message Length report.
- **New editable whisper**: a field in every `Data.MESSAGE_LANGUAGES` row (and the TRANSLATORS token list if it has new tokens); a `Data.EDITABLE_MESSAGES` entry (scope, key); a fill/build pair in `Features/Announcements.lua` (`SignOff`, `FillTokens`, `BuildEditable`); the send site; a `ns.DefineWhisperComposer` message on its panel; a note in the feature's defaults comment that the key has no default; a Diagnostics text-state line and a Message Length row.
- **New message language**: a `Data.MESSAGE_LANGUAGES` row with `locale`, native `name` and every field; nothing else (the dropdown, `ns.GetMessageLanguageInfo` and `MigrateMessageLanguage` read the table).
- **New replaced add-on**: its folder in `ns.REPLACED_ADDONS` (`Data/Data.lua`); nothing else (turn-off and popup read the list).
- **New one-time migration**: a `MIGRATION (remove after YYYY-MM-DD)` tag at every touch point (code, TOC lines, `.luacheckrc`, `Bindings.xml`, locales, Tests, Diagnostics); a dedicated file lists its removal pieces; its tagged line in all four TOCs; its call in `InitializeDatabase` at the right point (raw before `AceDB:New`, or after the prune, `UseOwnProfileWhenUnnamed` and the stamps and before the callbacks) or in its module's login; existence-tested if called from a file older than it (a `/reload` doesn't load new TOC files); a stamp written for fresh installs too if it must run once; its line in `### Migration Chain`.
- **Removing a migration**: grep its date's tag across the add-on (`.lua`, `.toc`, `.luacheckrc`, `Bindings.xml`) and delete each touch point plus the untagged ones its chain line names; its `### Migration Chain` line; any README-Notes exception that names the date.
- **New consumable macro**: `ns.MACRO_CONFIG` (`Data/Data.lua`) with `MACRO_*` / `LABEL_*` keys (a shipped name never changes); `ns.MACRO_DEFAULT_ITEM_IDS` in every `Macro-Default-Items-{Game}.lua`; `Macros/<Name>.lua` calling `ns.RegisterMacroType`, in all four TOCs among the definition files; `enabledMacros[type]` in `Data/Default-Settings.lua`; a `MacroToggle` row in `Options-Macros.lua`; a page under Consumable Macros if it has settings; multi-use needs both `ranked = true` and `ns.MULTI_USE_MACRO_TYPES`; conjures need `CONJURE_SHAPES` (`Message-Length-Macros-for-Consumables.lua`) and, for non-default `GetSmartSpell` flags, `CONJURE_CAST_FLAGS` (Manifests); class-only custom macros need `CLASS_ONLY_MACROS` (Manifests); DruidMacroHelper needs `ns.DRUID_MACRO_HELPER_TYPES` / `ns.DRUID_MACRO_HELPER_GUARDS`; class click notes in `Macro-Notes.lua` if it has clicks.
- **New consumable item type**: the table in every flavor folder and TOC; a `CONSUMABLE_TABLES` entry with its facts column (`Item-Cache.lua`); a branch in `ns.CacheItemData`; any new gate in `ns.ScanBags` mirrored in `FailedGate` (Manifests); a `ns.DIAGNOSTIC_DATA_SOURCES` row (Manifests).
- **New ranking step**: `RANKING_PRIORITY`, `FillRecord`, `ResetBest` (`Scanner-Ranking.lua`) and `CopyCandidateRecord` (`Scanner-Diagnostics.lua`), as a real boolean; a gated step also needs its gate threaded through `CompareRecords`, `IsBetter`, `RetainCandidate`, `CaptureDiagnosticCandidates`, both `IsBetter` calls in `ns.ScanBags` (the definition dispatch and Buff Duty's buff food pick) and a definition field.
- **New standard-body input** (a hook like `combatSpell`): the protocol comment in `Definitions.lua`; the hook call in `ns.UpdateMacros`, passed to both `ns.BuildStandardBody` and `ns.BuildStateKey`; a state-key flag and the format comment; every recursive trim call passing it on, plus its place in the trim order; the DruidMacroHelper body if it applies there; `LongestBodyFor` in `Message-Length-Macros-for-Consumables.lua`.
- **New body-shaping consumable setting**: profile default; a row on its page through `ns.MacroOptions.Toggle` / `BodyToggle` (or a setter calling `ns.MacroOptions.Changed`); folded into the state key (`stateExtras`, an `appendBlock` flag, or `ns.BuildStateKey`); an explicit `ns.UpdateAuraTracking()` if it changes aura tracking (as `usePetBuffFood` does); `ns.TargetSignatureChanged` or `ns.GroupSignatureChanged` if it reads target or group state; a line in `AppendChoices` / `AppendClassAndRace` (Manifests).
- **New When to Use pair**: `<prefix>In` + `<prefix>Level` defaults; `ns.IsUseWhenActive(settings, prefix)` at the read; `ns.MacroOptions.ModeSubRow` plus `UseWhenGroups` on its page; a `UseWhenText` line (Manifests).
- **New page under Consumable Macros**: an `ns.OPTIONS_REGISTRY` key (`Data/Data.lua`); `Kit.RegisterPanel(key, builder, title, "Macros")` at its place in `RegisterMacrosPanels` (`Options/Options.lua`); the builder file returning `ns.MacroOptions.Page`, after `Options-Macros-Utilities.lua` in all four TOCs; a locale title.
- **New Readiness switch**: a `readiness*` global scalar default (the prefix is what Reset and `ReadinessAtDefaults` reach); a `SECTIONS` row (`Options-Readiness-Report.lua`); `READINESS_SWITCHES` and a gate line in `ns:BuildReadinessDiagnosticReport` (Manifests); the check (`Readiness-Report.lua`); the sample (`Readiness-Report-Example.lua`), sharing a `ns.ReadinessAsks*` gate; any new API in the Manifests API rows; a client gap behind a `Features/Utilities.lua` accessor.
- **New player buff the snapshot tracks**: its field reset and filled in `ns.GetPlayerBuffSnapshot` (`Scanner-Auras.lua`); readers in `Readiness-Report.lua`, `Buff-Duty-Self.lua` and the Manifests reports.
- **New scroll type**: rows (with `classes`) in every `Scrolls-{Game}.lua`; `ns.SCROLL_CHECK_ORDER` (`Data/Data.lua`), which `DefaultScrollTypes` (`Data/Default-Settings.lua`) and every scroll walk read; a `SCROLL_TYPES` row (`Buff-Duty-Options-Menu.lua`, published as `ns.SCROLL_TYPE_LABELS`), which the Scrolls page and the Scrolls menu both list.
- **New macro runtime global**: `Runtime.lua`; `.luacheckrc` globals; byte cost against `ns.MACRO_BODY_MAX_LENGTH` in every body that writes it.
- **New action bar for name hiding**: `ACTION_BAR_PREFIXES` (`Action-Button-Text.lua`) and the copy in `AppendMacroWriting` (Manifests).
- **New Inventory Report record field**: `ns.InitializeInventoryReport`; readers in `OtherCharacters` (tooltip), `AddRecordedCharacters` and `StatusText` (panel) and the Restock List's class coloring.
- **New Restocker row field**: `ItemToString` / `ItemFromString` as a trailing field with its default; `ns.AddRestockItem` and `ns.AddStarterCategory` defaults; the row counts in `ns:BuildRestockerContextReport` (`Diagnostics/Manifests-Restocker.lua`).
- **New Restock List column**: the row field above; a `COLUMNS` entry and a starting `ns.restockColumnWidths` width (`Restocker-Window-Columns.lua`); `COLUMN_STATE` / `COLUMN_TOGGLE` / `NOT_APPLICABLE_REASON` (`Restocker-Window-Cells.lua`); `COLUMN_SET` (`Restocker-Window-Menus.lua`); a `GROUP_TONE` entry for a new band (`Restocker-Window-Column-Header.lua`); caption, title and body locale keys; `MIN_WIDTH` in `Restocker-Window.lua` if the row no longer fits.
- **New Restocker setting**: `global.restocker` default (`Data/Default-Settings.lua`); a control in `ns.BuildRestockerOptions` (hidden with the switch automatically); locale keys; a context line in `Manifests-Restocker.lua`.
- **New reminder mode**: an `ns.REMINDER_*` constant (`Data/Data.lua`); `ReminderModes` + `REMINDER_MODE_ORDER` and the line `ReminderExample` picks (`Options-Restocker.lua`); a branch in `ns.BuildRestockShortfallLines`; `OPTIONS_RESTOCKER_MODE_*` key.
- **New reminder (another moment)**: enabled and mode defaults (`Data/Default-Settings.lua`); `ReminderToggle` / `ReminderModeRow` / `ReminderExample` rows and `AllRemindersOff` (`Options-Restocker.lua`); a headline builder and `COUNT_KEYS` keys if its wording differs (`Restocker-Reminders.lua`); the call through `ns.RemindRestockShortfallAfterVisit` or `ns.PrintRestockShortfall`; `Manifests-Restocker.lua` line.
- **New Staples row**: `ns.STARTER_LIST_CATEGORIES` (`Restocker-Starter-Categories.lua`); a matching chain in every `Consumable-Upgrade-Paths-{Game}.lua` (key forms in `CHAINS_BY_KEY`, `Restocker-Starter-List.lua`); a label key only for a kind-of-item row.
- **New Staples category (section)**: the rows above with the new `section`; a block in `OfferedSections` (`Restocker-Starter-Sections.lua`) and a `STARTER_POPUP_*_HEADER` key.
- **New Restocker event**: a `WhileEnabled` entry in `ns.InitializeRestockerEvents` and the name in `EVENTS` (`Restocker-Events.lua`); a second use of an existing event calls from its handler.
- **New Inventory Report event**: a handler in `ns.inventoryEventHandlers` (`Inventory-Report-Recording.lua`) and the name in `EVENTS` (`Restocker-Events.lua`).
- **New wait on item data**: its queue in `ns.SyncRestockItemInfoSubscription` and a drain (plus failed-answer drop) in `ns.OnRestockerItemInfoReceived`; call the sync after every add to it.
- **New list operation**: go through `ns.UseRestockList` (or call `ns.ClearRestockNewItems` when not switching); `ns.UpdateRestockListWidgets`; `ns.UpdateRestockList`; `ns.StartRestockBankRun` if `ns.bankIsOpen`; a merchant rebuy as `ns.SwitchRestockList` does it; a confirm carrying the list name as popup data if it can't be undone.
- **New window menu**: entries through `ns.RestockMenu:Open` (Menu-Kit entry kinds; `ns.RestockChoiceRow` for choices), a close function added to `ns.CloseRestockMenus` that checks `IsOpenFor` its anchor, `ns.CloseRestockMenus()` before opening; closed in `ns.UpdateRestockList` if a redraw would stale it.
- **New window control**: `ns.SetRestockControlClick` so a carried item drops instead of clicking; the `ns.ApplyRestockerElvUISkin` lists in `ns.CreateRestockWindow`; a parent of the header bar or footer bar, never the window.
- **New `/restock` subcommand**: `RESTOCKER_COMMANDS` and `COMMAND_ORDER` / `PROFILE_SUBCOMMAND_ORDER`, `NAMES_EXISTING_LIST` if it names a list, a branch in `ns.HandleRestockerCommand`, its help locale key.
- **New Buff Duty party buff**: a row in `ns.BUFF_DUTY_SPELLS` in every `Buff-Duty-Spells-{Game}.lua` (legend atop the file); nothing else for an ordinary row (Party-Buffs, asks, the self copy, the event-log filter and Validate Data read the table). `noAsk` keeps it off the Ask row; `selfDefault` sets whether Self-Buffs starts with it on.
- **New Buff Duty self buff sharing an exclusive family**: `ns.BUFF_DUTY_SELF_SPELLS` rows in each flavor file, plus `BUFF_DUTY_SELF_NOTE_<FAMILY>` in every locale.
- **New Other Buffs consumable** (any class): a `ns.BUFF_DUTY_SELF_ITEMS` row `{ item id, auras = { spell ids }, default }` in each flavor file; it lands on the Other Buffs page and in the Other Buffs menu.
- **New Buff Duty category**: `Data.BUFF_DUTY_ROWS` (window, menu and Key order); `rowWhen` / `rowKey` / `rowShow` / `rowOut` (and `rowOn` unless it keeps its own switch) defaults in `buffWindow`; `BuffDuty.RowOn` / `RowExists` branches; a `selfItemEntries` entry in `BuffDuty.BuildLookup` with a string key and its flag carried by `BuildBuffs` into `selfItemBuffs`; an icon builder, its `AddSection` and Missing Inventory test in `BuffDuty.AddSelfSection`; a `/use` line in `ns.SetBuffButtonAttributes` unless its specs are plain `selfItem`s; its place in `Candidates` (`Buff-Duty-Key-Picker.lua`); `ITEM_ROWS` and `CategoryName` in `Buff-Duty-Options-Menu.lua`; an options page (`Options-Buff-Duty-Consumables.lua`, `ns.OPTIONS_REGISTRY` key, `RegisterBuffDutyPanels`) and a `CategoryToggle` on the main panel; locale keys; lines in `ns:BuildBuffDutyContextReport`.
- **New Buff Duty switch**: `buffWindow` default (`Data/Default-Settings.lua`); a `Toggle` on the main panel (`Options-Buff-Duty.lua`, a `Kit.SubToggleRow` if it sits under another); an `OTHER_PLAYERS` row or submenu entry (`TargetEntries`) in `Buff-Duty-Options-Menu.lua`; label and `_DESCRIPTION` locale keys in every locale; a line in `ns:BuildBuffDutyContextReport`; `HasAnythingToShow` / `ns.OnBuffDutyUnitAura`'s gate in `Buff-Duty.lua` if it can keep the window up with nothing castable; `SyncCombatLog`'s `wanted` if it needs the combat log.
- **New Buff Duty window setting** (non-switch): `buffWindow` default; a panel row whose setter calls `ns.RefreshBuffDuty`; any choice list in `Data/Data.lua` plus cleaning in `PopulateBuffDutyAudience`; locale keys; a line in `ns:BuildBuffDutyContextReport`.
- **New Buff Duty event**: `WINDOW_EVENTS` or the always-on list, plus `EVENT_UNITS` for a unit filter (`Buff-Duty-Events.lua`); the handler via `ns.SetBuffDutyEventHandler` in the owning file; `ns.EVENT_NAMES` in `Features/Core.lua` (`Tests/Run.lua` checks).
- **New section kind**: its adder in `BuffDuty.BuildSections`, appended singly; the frame's top/party split and Party-Buffs placement (`section.kind`, `section.party`); `Candidates` in `Buff-Duty-Key-Picker.lua`, or the key never casts it; `Signature` if it carries a new section field.
- **New row kind on an existing section** (as the Ask row): its builder called from the section's adder; a grid name if its columns aren't the buffs' (`row.grid`); spec fields in `ns.SetBuffButtonAttributes` and `Signature`; PreClick / tooltip handling in `Buff-Duty-Icons.lua`; its place in `Candidates` and `PickNext`; `HasAnythingToShow` if it needs nothing castable; context report lines.
- **New spec field that changes what a button does**: `ns.SetBuffButtonAttributes` (and its nil-clear key list); `Signature` in `Buff-Duty-Layout.lua`, or an unchanged signature skips the redraw; `SkipKey` in `Buff-Duty-Keys.lua` if the key can use it.
- **New weapon item kind**: `Data.WEAPON_ITEM_KINDS`, `Data.WEAPON_ITEM_KIND_HANDS` if hand-limited, `BUFF_DUTY_WEAPON_KIND_<KIND>` in every locale, the rows' kind field.
- **New Buff Duty file**: all four TOCs, after every file it captures at load and before every file that captures it.
- **New macro kind**: `ns.MACRO_KINDS` + a `ns.MacroKind` branch (`Macro-Kinds.lua`); `kindDefaults.<kind>` (`SPELLBOOK_DEFAULTS`, `Data/Default-Settings.lua`); `KIND_*` keys; `PRIORITY_KINDS` / `LEFT_OUT_UNITS` / `HELPFUL_KINDS` (`Target-Priority.lua`) and `KIND_CATEGORIES` (`Page-Categories.lua`) where relevant.
- **New Spellbook macro option**: a profile table in `SPELLBOOK_DEFAULTS`; the key in `Macro-Settings.lua`'s option list; an `OFFERED` predicate (`Macro-Options.lua`); its line in `Macro-Body.lua`; `ns.DEFAULTABLE_OPTIONS`, `COPIED_SETTINGS` or `KEPT_SETTINGS` (`Macro-Copies.lua`) so Duplicates, resets and handover carry it; its menu entry (`Menu-Utilities.lua` tables or `Macro-Menu-Sections.lua` / `Macro-Menu.lua`, plus `Category-Menu.lua`); `OPTION_SUBTEXTS` (`Macro-Button-Notes.lua`); `MENU_*` / `SUBTEXT_*` keys; `PER_SPELL_OPTIONS` (`Diagnostics/Manifests-Enhanced-Spellbook.lua`); a Message Length check.
- **New Spellbook pop-up menu**: a generator for `ns.OpenMacroMenuPanels` (`Macro-Menu-Panels.lua`); a new element method there if it needs a row kind the kit draws but the description lacks; `MENU_*` keys.
- **New Spellbook event**: `EVENT_HANDLERS` (+ `EVENT_UNITS`) in `Spellbook-Core.lua`; `ns.EVENT_NAMES` (`Features/Core.lua`); an `ns:On<Name>` handler whose name is unique across all of `ns`; `LOGIN_REGISTERED_EVENTS` / `WHILE_OFF_EVENTS` if it needs either.
- **New Conditionals condition**: `ns.CONDITIONS` (`Conditionals.lua`); `ns.ConditionBlockReason` if it clashes; locale keys.
- **New Cast Sequence reset**: `ns.CAST_SEQUENCE_RESETS` (`Cast-Sequence.lua`); locale keys.
- **New What's Next status or source**: `ns.WHATS_NEXT_STATUSES` (+ `ns.WHATS_NEXT_INKS` / `ns.WHATS_NEXT_BRIGHT` in `Data/Data.lua`) or `ns.WHATS_NEXT_SOURCES`; pet ones in `ns.WHATS_NEXT_PET_STATUSES` / `ns.WHATS_NEXT_PET_SOURCES`; `PET_COUNTS` / `PET_COUNTS_NO_TEACH` for pet statuses; locale keys.
- **New window tab or page**: `TABS` (`Spellbook-Window.lua`, with a gate if conditional); a page builder (`ns.Build<X>Page`, `Whats-Next-Page.lua` for a list page); a model in `ns.WHATS_NEXT_MODELS` (`Whats-Next-Models.lua`) for a list tab; a `ns.SPELLBOOK_TAB_*` index if other code opens it; a refresh hook in `Spellbook-Events.lua` if events change it; locale keys.
- **New login-pair API** (one call on Classic, another on Camelot): both halves in the API checks of `Manifests-Enhanced-Spellbook.lua`.
- **New Spellbook file**: all four TOCs, after every file whose `ns` field it captures at load and before every file that captures its fields.
- **New feature**: an `ns.FEATURES` record (`Options/Options-Feature-Switches.lua`) at its menu/tree position, with `SWITCH_*` locale keys; its `global` default in `Data/Default-Settings.lua`; an `apply` setter that writes, subscribes/releases its events and ends in `ns.RefreshSettings` (omit `apply` only when writing the value is all it takes); its panel: `Kit.FeatureSwitch(setting)` atop it and `Kit.HideAllExcept` last in the builder; an `ns.OPTIONS_REGISTRY` key and a `Kit.RegisterPanel` call at the matching position in `ns.RegisterOptionsPanels`; `ns.AddFeatureOffLine` on each sub-page; the More Features row comes free unless `block = true`, which needs a hand-built `Add<Feature>` block in `BuildMainEntries` (`Minimap-Menu.lua`); a Diagnostics context line. A flavor-conditional feature also needs an existence-tested insert like Rank Watch's (literal index).
- **New options panel**: an `ns.OPTIONS_REGISTRY` key (`Data/Data.lua`, tree order); a `Kit.RegisterPanel(key, builder, title[, parentKey])` call in `ns.RegisterOptionsPanels` (`Options/Options.lua`), whose call order is the tree order; `Kit.SubPanelTitle` for a sub-panel's page name; `Kit.PrepareTree` after it for a tree group; the builder file in each TOC before `Options/Options.lua`; a locale title.
- **New mini-map menu row that changes a setting**: call the same setter its options control uses (`feature.apply` or `ns.OptionsKit.Set`); tooltip from the option's caption / desc (`OptionTooltip`); `ToggleRow` or `ActionRow`; ends in `AfterChange`; a cold item row must report loading so `Render` retries.
- **New mini-map block** (a `block = true` feature, or one excluded like `SPELLBOOK_SETTING`): `Add<Feature>` in `BuildMainEntries` (title with `OnOff`, description locale key, Toggle via `ToggleRow`); if its title opens a flyout, a `FLYOUTS[key]` builder and a `submenu` key on the title.
- **New button click job**: a `click` key on its main-menu `ActionRow` (`ns.RunButtonClick` finds it there); the button comment in `Minimap-Button.lua`. Left-Click stays the menu's.
- **New slash command**: `SLASH_*` / `SlashCmdList` in `Options/Options.lua`; the `SLASH_*` global in `.luacheckrc`; a Commands line in `Options/Options-General.lua`.
- **Renaming the menu frame**: `Kit.CreatePanel(ADDON_NAME .. "Menu", UIParent)` (`Minimap-Menu.lua`) and `MenuClosesOnEscape` (`Diagnostics/Settings-Reports.lua`).
- **New Rank Watch setting Reset Profile should reach**: `rankWatch` default (`Data/Default-Settings.lua`); `RESET_KEYS` (`Rank-Watch-Core.lua`); its control in `Options-Rank-Watch.lua` (outside the composer slots; hidden by `Kit.HideAllExcept` while off unless kept; `hidden = WhisperOff` if it belongs under Whisper); locale keys; a line in `ns:BuildRankWatchContextReport`.
- **New Ability Alerts While Leveling option**: `rankWatch` default; `RESET_KEYS`; a `SubToggle` in `Options/Enhanced-Spellbook/Options-Ability-Alerts.lua`; `LevelUpLines` and `ns.LevelUpAlertExample`; the Alerts line and `NextPetLine` in `Manifests-Rank-Watch.lua`; locale keys.
- **Pet-line rule or `HUNTER_PET_LEVEL`**: `LevelUpLines` (`Rank-Watch-Level-Up.lua`) and its copy in `NextPetLine` / `HUNTER_PET_LEVEL` (`Manifests-Rank-Watch.lua`).
- **New Rank Watch editable whisper**: a field in every `Data.MESSAGE_LANGUAGES` row and a `Data.EDITABLE_MESSAGES` row with `scope = "rankWatch"` (`Data/Message-Languages.lua`); a fill/build pair in `Features/Announcements.lua`; the send site; a message in a `ns.DefineWhisperComposer` block in `Options-Rank-Watch.lua` (its slot grows by 0.1 per message; keep clear of the next order); a `TextState` in `Manifests-Rank-Watch.lua`; a row in `Message-Length-Rank-Watch.lua`; no AceDB default.
- **New Rank Watch print line**: `RANK_WATCH_PRINT_*` key (plus `_PET` / `_DEMON` forms) in every locale; builder in `Rank-Watch-Check.lua`; the panel Example if shown.
- **New detection event**: `ns.EVENT_NAMES` (`Features/Core.lua`, enforced by `Tests/Run.lua`); `ns.SetRankWatchHandler`; subscription in the detection file's `ns.SyncRankWatchDetection` (or Core's `EVENTS` for every flavor); a decode in `Diagnostics/Event-Log.lua` if it should be logged.
- **New Rank Watch constant**: `Data.RANK_WATCH` (`Data/Data.lua`); a Context report line if it gates anything.
- **Announced key or cluster message shape**: `ns.CheckRankWatchCast`, `ANNOUNCED_KEY_PATTERN` (`Rank-Watch-Cluster.lua`), the `rankWatch` comment in `Data/Default-Settings.lua`; must stay what the standalone Rank Sentinel sends and reads.
- **New outside caller of Rank Watch code**: an existence test, since Mists loads none of it.

## Saved Variables

- **`GoodToGoDB`** (`ns.SAVED_VARIABLES_NAME`, must match every TOC's `## SavedVariables`): the one table, AceDB-3.0 with `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`). Feature blocks join through `AddDefaults`, which asserts no two features declare one key.
- **`BagsBuffsButtonsDB`** (`ns.OLD_SAVED_VARIABLES_NAME`): pre-rename table, second on every TOC's `## SavedVariables`, only for `MoveRenamedSettings` (2026-12-03).
- **Other-client prune** (not a migration; Style Guide → Other-Client Characters): `PruneOtherClientCharacters` right after `AceDB:New`, then `PruneOtherClientGlobals` over `global.restocker.listChoices` and `global.inventory` (README-Notes exception).
- **Unnamed-character guard** (not a migration): AceDB may read the client's placeholder name; `UseOwnProfileWhenUnnamed` moves the character onto its real-name profile, `SaveProfileChoiceWhenUnnamed` (logout) saves the choice under the real name.
- **Model: Per-Character.** `AceDB:New` takes no default-profile argument, so every character lands on a profile named for it.
  - Reset Profile clears that character's profile only; `global` and `char` survive, and `OnProfileReset` re-applies. Exception: Rank Watch's reset listener writes `RESET_KEYS` back on `global.rankWatch` (README-Notes).
  - **Profile**: consumable choices (`<prefix>In` / `<prefix>Level`, poison groups, Stealth/racial eating, `scrollTypes`, which Buff Duty and the Readiness Report read: README-Notes exception), the Ignore List's character half, the Spellbook's display preferences, per-spell option tables, `kindDefaults`, `macroCopies`, `markedPlaced`, `trainerSpells` (by class).
  - **Global**, each with its reason beside its key: presentation (`showWelcome`, `showMacroNames`, `minimap`, `abilityTooltipRanks`, `inventoryReport`); master switches (`macrosEnabled`, `restockerEnabled`, `spellbookEnabled`, `readinessReportEnabled`; Buff Duty's and Rank Watch's `enabled` live in their blocks) and `readiness*`; what every character shares on the client (`enabledMacros`, `ownedMacros`, `macroTags`, `macroTagCount`); data the player built or the add-on gathered (`restocker`, `inventory`, the Ignore List's Global half); `buffWindow`; `rankWatch`; `messageLanguage` (one language for both features' whispers).
  - Written without a default: `legacyImported`, `messageLanguageMigrated`, `poisonsDefaultMigrated`, `restocker.remindersMovedOntoSimple`, `buffWindow.point`, every editable whisper's text (`Data.EDITABLE_MESSAGES`).
  - Window spots, each saved on drag stop: `global.windowPosition` (Spellbook), `restocker.framePosition`, `restocker.staplesPosition`, `buffWindow.point`. Each has a Reset Position row.
  - Two README-Notes exceptions keep per-character records off the profile so Reset Profile can't reach them: `restocker.listChoices` on global, and `char.ownedMacros`.
- **Seeding.** Nothing seeds a list on empty. `scrollTypes`' defaults are built at file load by `DefaultScrollTypes` from each `ns.SCROLL_DATA` type's `classes` and the logged-in class, so the defaults table differs by class. `useBuffFoodWhenFed` defaults by flavor. Buff Duty's `audience` / `selfRefresh` seed per row, and `rowOn` for food, scrolls and elixirs once from their `selfRefresh` keys (`PopulateBuffDutyAudience`). Editable whisper texts have no default key; unset means the language's default.
- **AceDB quirks the code leans on**: scalar and table defaults are copied into the live table on first access, so after `AceDB:New` a migration can't tell a saved value from a default by reading normally (hence `rawget` / `rawset`, and raw reads of `_G[ns.SAVED_VARIABLES_NAME]` before `New`); a profile nobody has loaded holds only what differs; every value equal to its default is stripped at logout, so an empty default subtable is nil by the time the add-on's own logout handler runs.

### By Feature

- **Consumable Macros and reports.** Which macros exist (`enabledMacros`, read through `ns.IsMacroEnabled`, missing = on) is account-wide because the macros live in the General tab. Other profiles' Ignore Lists are read raw from `ns.db.sv.profiles`. The item cache is session-only. Retired keys `useBuffFood`, `buffFoodIn`, `buffFoodLevel`, `useScrolls`, `scrollsIn`, `scrollsLevel` stay in older profiles; nothing reads or clears them. The Inventory Report writes from AceDB's `OnDatabaseShutdown`, before AceDB strips defaults. Readiness Reset writes defaults straight across (master switch excepted), safe only while every `readiness*` default is a scalar.
- **Restocker.** All global, so a profile switch or Reset Profile can't empty a list and one Gold Reserve holds back every alt. Each character's choice is keyed by its AceDB profile name and outlives a deleted character; `currentList` is runtime only, cleared at logout (`ns.OnRestockerLogout`). `framePosition` is written whole, since AceDB strips an empty default subtable before the add-on's logout handler. No seeding: a character with no choice gets an empty class-named list at login (`ns.InitializeCharacterRestockList`). Rows are one-line strings on disk (`Restocker-Saved-Format.lua`).
- **Buff Duty.** All in `global.buffWindow` (every character buffs the same way) except `scrollTypes` (README-Notes exception) and `useBuffFoodWhenFed`, the consumable macros' setting the Well Fed menu also toggles, both on the profile. Each category's settings are tables keyed by `Data.BUFF_DUTY_ROWS` (`rowOn`, `rowWhen`, `rowShow`, `rowKey`, `rowOut`); `selfRefresh` values only mean on or off now. Seeding (`PopulateBuffDutyAudience`) fills only keys never saved, from row defaults, drops values the dropdowns don't offer and keeps keys this client lacks, since Era and Season of Discovery share the file. Unset per-class, weapon, `buffFoodOff`, `scrollOff` and `elixirOff` choices read as on. Never saved: the session close, favors, holds, NPC cycles, raid folds, ask times, the aura cache, skip memory.
- **Enhanced Spellbook.** Tags and ownership are facts about the WoW macro lists, kept on `global` and `char` and keyed by `ns.MacroOwnerKey`, so no profile switch or reset loses them; everything else is profile. Per-spell option tables (`macroTab` included) are keyed by `ns.SettingsKey` and store nil at the default. `kindDefaults` is shipped data, read only, apart from a kind's `targetPriority` list.
- **Rank Watch.** On `global`, but Reset Profile reaches it (README-Notes exception): `resetListener.OnProfileReset` writes `RESET_KEYS` back from `ns.DATABASE_DEFAULTS.global.rankWatch` and wipes `untracked`, keeping Ignored Players, the announced record and the whisper texts. No seeding: an untouched rank follows its data `off` flag. `ns.RankWatchSettings()` writes (a migration), so probes read `ns.db.global.rankWatch` directly.
- **Mini-map.** LibDBIcon's table on `global`, so a profile switch or reset never moves or hides the button.
- **Diagnostics.** Never saved.

### Migration Chain

Run order, one line each: when it runs, what it does, removal date, the pieces that come out with it.

`PLAYER_LOGIN`, Core first (`Features/Core.lua`):
1. `ns.TurnOffReplacedAddons` (`Replaced-Addons.lua`): permanent, not a migration.
2. `MoveRenamedSettings`, raw (2026-12-03): `BagsBuffsButtonsDB` becomes `GoodToGoDB` while ours is missing or empty. Out: the function, `ns.OLD_SAVED_VARIABLES_NAME` (`Data.lua`), the second `## SavedVariables` entry and its comment in every TOC.
3. `MigrateMessageLanguage`, raw (2026-12-13): an account asking or tipping in whispers gets its client locale as `messageLanguage`; before the import so only Good to Go's own data counts. Out: the function, its call, the `messageLanguageMigrated` stamp (step 8; the saved stamp is harmless).
4. `ns.ImportLegacySettings`, raw (2026-12-08): see Replaced and Legacy Add-ons. Out: all of `Features/Legacy-Migration.lua` and its TOC lines, `ns.LEGACY_ADDONS` (`Data.lua`), the call, the `ns.PrintLegacyNotices` call and `ns.OfferLegacySteps` test in `ns:PrintWelcome` (keep `ns.OfferReplacedReload`), the `ns.IsLegacyImportPending` gate (`Restocker-Starter-List.lua`), the `CHAT_LEGACY_*` / `POPUP_LEGACY_*` block in every locale, `GOODTOGO_LEGACY_IMPORT` in `.luacheckrc`, the legacyImported lines in `Diagnostics/Manifests-Macros-for-Consumables.lua`. `ns.REPLACED_ADDONS` and `Replaced-Addons.lua` stay.
5. `KeepPoisonsMacro`, raw (2026-12-19): an account with saved settings (ignoring the import's own `legacyImported`) and no Poisons entry gets `enabledMacros.Poisons = true` before the default flipped off reaches it. A Connoisseur account is covered by the importer itself (step 4), on whichever login the import lands. Out: `HasSavedSettings`, the function, its call, the `poisonsDefaultMigrated` stamp (step 8), the sentence in the `enabledMacros` defaults comment.
6. `AceDB:New`.
7. `PruneOtherClientCharacters` (permanent), then `UseOwnProfileWhenUnnamed` (permanent). The prune's `IsOlderForeverKey` branch is 2026-12-08: out with `FOREVER_RULE_SETS`, `IsOlderForeverKey`, the tagged check in `Tests/Run.lua`, the README-Notes exception.
8. Stamps `global.messageLanguageMigrated` (2026-12-13) and `global.poisonsDefaultMigrated` (2026-12-19), fresh installs included, so steps 3 and 5 never fire later.
9. `ns.MoveGroupSettingsOntoCheckboxes` (2026-12-11, `Group-Context-Migration.lua`), before any profile copy: `buffWindow.showSolo` / `showParty` / `showRaid` become `showIn` (Battleground takes Raid's answer), `*Where` keys move into `showWhere`; each profile's `<prefix>Mode` becomes `<prefix>In` + `<prefix>Level`. Out: the file, its TOC lines, the call.
10. `ns.MoveRestockRemindersOntoSimple` (2026-12-13, `Restock-Reminders-Migration.lua`), existence-tested: all three reminder modes written Simple once, marked `remindersMovedOntoSimple`. Out: the file, its TOC lines, the guarded call, the untagged "moved onto Simple" field in `Diagnostics/Manifests-Restocker.lua`.
11. `ns.RetireAutomatedAppreciation` (2026-12-08, `Legacy-Migration.lua`): goes with step 4's file.
12. `ns.RetireSavedItemCache` (2026-12-08, `Item-Cache.lua`): `itemCache` / `itemCacheVersion` / `itemCacheFolder` off every profile. Out: the function and its call.
13. `ns.RekeyCharactersByFullName` then `ns.MoveCharactersOntoOwnProfiles` (2026-12-08), in that order: Forever first-name keys in `listsByCharacter` / `inventory` move to whole-name keys; characters on Default get their own profile copies, Forever older-name settings carry over, list choices move into `listChoices`, profiles' `restockList` retires. Out: `Character-Key-Migration.lua`, `Default-Profile-Migration.lua`, their TOC lines and calls, the `noDefaultProfiles` argument and sentence in `Options/Options-Profiles.lua`, step 7's `IsOlderForeverKey` pieces.
14. The profile callbacks; then `ns.RegisterOptionsPanels`, `ns.RegisterMinimapIcon`.

Load time:
15. `Connoisseur*` callback aliases (2026-12-08, `Macros/Runtime.lua`, plus `.luacheckrc` globals).
16. `_G.TFTBBuffIndividual` alias for the Buff Key button (2026-12-03, `OLD_KEY_BUTTON`, `Buff-Duty-Keys.lua`); the hidden `MACROSPELLBOOK_TOGGLE` binding and its comment (2026-12-03, `Bindings.xml`).

Each module's `PLAYER_LOGIN`, in TOC load order:
17. Restocker `ns.InitializeRestocker` (2026-12-08): `starterListDismissed` cleared (`Restocker-Core.lua`); saved lines with a type ahead of the name still read (`ItemFromString`, `Restocker-Saved-Format.lua`); empty legacy `Name-Realm` lists kept by `ns.PruneEmptyOrphanRestockLists` (`Restocker-Saved-Lists.lua`); then the existence-tested `ns.InitializeInventoryReport` call (`Restocker-Events.lua`).
18. Rank Watch `OnPlayerLogin` (`Rank-Watch-Core.lua`): `maxLevelOnly` dropped in `ns.RankWatchSettings` and `ImportStandaloneSettings` / `StandaloneProfile` (2026-12-08; out with the `importedStandalone` default, `RankSentinelDB` in `.luacheckrc`, the untagged "Rank Sentinel's settings brought over" line in `Manifests-Rank-Watch.lua`); `optOutOffered` dropped and an `optOutMessage` holding `{code}` reset (2026-12-15).
19. Buff Duty `ns.SetupBuffDuty`: `ns.MigrateBuffKeys` moves keys bound to `OLD_KEY_COMMAND` (2026-12-03, with step 16's alias).
20. Spellbook `OnPlayerLogin` (`Spellbook-Core.lua`): `customMacros` / `customMacrosSeeded` off every profile, `global.professionSkills` dropped, flat `trainerSpells` moved under the class, macro records moved from `ns.db.keys.char` to `ns.MacroOwnerKey` (all 2026-11-26); Forever hunter-trainer pet abilities purged from every profile's `trainerSpells` via `ns.IsPetAbilitySpell` (2026-12-13); `ns.MigrateSpellbookBinding` (2026-12-03, `Enhanced-Spellbook/Key-Bindings.lua`, with its `SetBinding` / `SaveBindings` / `GetCurrentBindingSet` rows in `Manifests-Enhanced-Spellbook.lua`).

`PLAYER_ENTERING_WORLD`:
21. `ns:PrintWelcome`: `ns.PrintLegacyNotices`, `ns.OfferLegacySteps` (2026-12-08, step 4).
22. Restocker `ns.OnRestockerArrival` and the `PLAYER_UPDATE_RESTING` / `PLAYER_CONTROL_GAINED` handlers existence-tested, plus `ns.ArmRestockerReminders` in `ns.SetRestockerEnabled` (2026-12-13: `Restocker-Town-Reminder.lua` is new; out: the tests, keeping the calls).

On use:
23. Buff Duty's first render: `ns.MigrateBuffDutyPosition` turns a saved top-left corner into top-right (2026-11-29; out with its call in `ns.RenderBuffDuty`, `Buff-Duty-Frame.lua`, and `RestorePosition`'s top-left branch).
24. Spellbook macro sync and lookup: the `~` prefix (2026-11-26: `OLD_PREFIX`, `OldPrefixName`, `ns.OLD_MACRO_PREFIX`) in `Macro-Lookup.lua` and `Macro-Sync.lua`.
25. `ns.IsMarkedPlaced` reads marks saved by WoW macro name (2026-12-08, `Page-Settings.lua`).

## Pitfalls & Why

### Secure frames and the client

- **Registering `COMBAT_LOG_EVENT_UNFILTERED` on Forever**: `ADDON_ACTION_FORBIDDEN`, which `pcall` can't catch. It is in `ns.EVENT_NAMES` only off Camelot, Buff Duty guards its subscription (`READS_COMBAT_LOG`), the combat-log detection file stays out of the Camelot TOC, and `Tests/Run.lua` fails a Camelot-listed file naming it without a literal `ns.FLAVOR ~= "Camelot"`.
- **Registering an event the client lacks**: it throws. `PLAYER_FOCUS_CHANGED` joins `ns.EVENT_NAMES` only off Vanilla, and the Spellbook's `EVENT_HANDLERS` repeats the guard; a new client-specific event needs both.
- **Calling `ns.SetModuleEvent` with an event missing from `ns.EVENT_NAMES`**: the assert aborts the calling file mid-load at a player's login. `Tests/Run.lua` catches it, but only for subscriptions shaped the way its scanner reads.
- **A handler that errors**: dispatch has no `pcall`, so every module after it misses that firing. An error in Core's `PLAYER_LOGIN` setup skips every module's login.
- **Expecting a unit-filtered subscription from `RegisterUnitEvent` with three units**: the API takes two; past that Core registers unfiltered and filters per module in Lua.
- **Registering events on a frame of your own**: it bypasses `ns.EVENT_NAMES`, the Event Log and the Event Registration report. Only the shared Menu Kit's item watcher does it.
- **Calling `GetItemInfo`, `GetSpellInfo`, `UnitBuff`, `IsSpellKnown` or `IsPlayerSpell` as globals**: Forever has dropped them or keeps them only in a deprecation layer (`loadDeprecationFallbacks`). Use `C_Item`, `C_Spell`, `C_UnitAuras`, `ns.IsSpellKnown`, `ns.IsPlayerSpell` (both read `C_SpellBook`).
- **An API one client lacks**: put it behind a `Features/Utilities.lua` accessor resolved once at load that answers nil (or neutral) there, with a Diagnostics row. `ns.OnReadyCheck` calls its probes unguarded, so one error silences the whole report on that client.
- **Mists APIs that exist but throw** ("API unsupported"): `ns.GetNumTalentTabs` is gated on `ns.EXPANSION < 5`; `ns.GetNumSpecGroups` tries `C_SpecializationInfo`, then `GetNumSpecGroups`, before `GetNumTalentGroups`.
- **Reading `ns.EXPANSION` as the client engine**: Camelot is 1 (Classic content) on the Retail client. Probe the API instead.
- **Comparing a secret value on Forever**: it errors. Test with `ns.IsPlain` / `ns.IsPlainTrue` / `ns.IsPlainYes` or `ns.IsSecretValue`, and ask `ns.AreAurasSecret()` (and `ns.IsUnitIdentitySecret`, `ns.AreCooldownsSecret`, `ns.IsSpellCooldownSecret`, `ns.CanCompareUnitTokens`, which touch `C_Secrets` only on Camelot) before reading. `ns.GetUnitByGUID` treats an unreadable GUID as no match.
- **Treating `NUM_BAG_SLOTS + 1` as the reagent bag**: on Era, TBC and Mists it is a bank bag. Use `ns.GetReagentBagID()` / `ns.CARRIED_BAG_IDS`.
- **Choosing the bank layout from what `C_Bank` answers**: Forever's purchased-tab list is empty until the answer arrives. `ns.BankBagIDs` picks the layout once, by whether the API exists.
- **The native `GetSpellLink` in chat**: on Classic the link lacks `:0` and the chat validator strips it. `ns.GetSpellLink` builds it by hand with `ns.SPELL_LINK_COLOR` lowercased; native is the fallback only when the name won't resolve.
- **Sending `D_MINUTES` and friends to chat raw**: their `|4` plural escape makes `SendChatMessage` drop the whole line. Format through `ns.FormatDuration`.
- **Reading a tooltip unprotected**: `ns.GetTooltipLines` can throw on an odd ID; its caller (`Diagnostics-Core.lua`) wraps it in `pcall`, and a new caller must too. The hidden tooltip (`ns.GetScanTooltip`) is shared, so reads through it stay synchronous.
- **Naming a frame template a client may lack**: ask `ns.HasTemplate` first.
- **Reading `IsInGroup` / `IsInRaid` to decide whether a feature acts**: a battleground's raid would read as Raid. Use `ns.GetGroupContext` / `ns.IsGroupContextOn`; only channel and unit-prefix plumbing reads them directly.
- **Testing a new file with `/reload`**: the client reads a TOC's file list only at startup. Restart the client. Shipped code relies on it too: a call from an existing file into one new this release is existence-tested (`ns.MoveRestockRemindersOntoSimple`, `ns.ArmRestockerReminders`, `ns.OnRestockerArrival`, `ns.InitializeInventoryReport`), so a player who updates mid-session and reloads doesn't error.
- **Whispering a pet's name**: it bounces as "No player named". Whisper paths gate on `ns.IsPlayerGUID`.
- **Editing a file under `Includes/Libraries/`**: `.pkgmeta` externals replace it at release. Change upstream or work around it in add-on code.

### Item info and caching

- **Remembering a miss while no waiter listens**: the client answers once; with the event unregistered the answer lands unheard and the miss would strand the item all session. `ns.GetItemData` remembers only ID-keyed misses while a waiter exists.
- **Retrying before forgetting the miss**: every retry asks `ns.GetItemData` again. `ns.OnRestockerItemInfoReceived` runs first in the fan-out and calls `ns.ForgetItemDataMiss`; a new consumer that retries must run after it.
- **Holding a waiter on an ID that may never answer**: an unknown or already-failed ID keeps `GET_ITEM_INFO_RECEIVED` on for the session. `ns.WarmItemCache` skips them; a hand-rolled waiter must too.
- **Releasing a waiter twice, or by a key never requested**: harmless by design (keyed, no-op), so release liberally.
- **Using `ns.WarmItemCache` in an options panel, or `Kit.WarmItems` in a window**: panels poll by registry name and repaint through `NotifyChange`; windows hold a `GET_ITEM_INFO_RECEIVED` waiter and remember failed IDs (`failedItemIDs`).

### Saved data and characters

- **Reordering `InitializeDatabase`**: `MigrateMessageLanguage` must read the raw table before the legacy import fills it and before AceDB copies defaults in (a value at its default is simply absent there). `KeepPoisonsMacro` must run before `AceDB:New`; a Connoisseur account's Poisons entry comes from the importer, not from it. Both stamps go right after `AceDB:New` so a fresh install never runs either later. `ns.MoveGroupSettingsOntoCheckboxes` must precede any profile copy. `ns.RekeyCharactersByFullName` must precede `ns.MoveCharactersOntoOwnProfiles`, which finds entries by whole name. Callbacks last, so migration profile switches fire no `ns:ApplyProfile`.
- **Testing "fresh install" on the raw table after the import**: `ns.ImportLegacySettings` always creates `GoodToGoDB.global.legacyImported`, so the table is never empty after it. Ignore that key (`HasSavedSettings`), or test before the import (`MigrateMessageLanguage`'s `next(sv) == nil`).
- **The prune runs before the Connoisseur & Restocker repairs**: a key shape the prune reads as another client's is gone before any migration sees it. Forever's older `First - RuleSet` keys survive only through `IsOlderForeverKey`; a new migration reading another such key needs the same exemption.
- **Editing the prune's shape in `Core.lua`**: `Tests/Run.lua` (`LoadPrune`) lifts the source from `local REALM_KEY_SEPARATOR` to the end of `PruneOtherClientCharacters` and runs it with only `type`, `pairs`, `ipairs`, `GetRealmName`. Renaming either anchor, moving code out of that span, or calling another global inside it fails CI.
- **Reading a migrated key normally after `AceDB:New`**: AceDB has copied defaults in, so a default reads like a saved value. The group-context migration uses `rawget` / `rawset`; the reminder migration writes Simple rather than clearing, since a cleared key would read nil until the next login.
- **Indexing a default subtable at logout**: AceDB has already stripped empty defaults. Write whole values, as `ns.SaveRestockWindowGeometry` does.
- **Changing a shipped default**: AceDB stripped every value equal to the old default, so every player still on it moves to the new one. Where they must not, write the old value explicitly first (`KeepPoisonsMacro`).
- **Treating `scrollTypes`' defaults as fixed**: they are built per logged-in class at load (`DefaultScrollTypes`). Nothing may compare a saved value against them across characters.
- **Reusing a retired key's name**: whatever players saved under the old meaning reads straight back (`readinessReportEnabled` is a new key for this reason).
- **Keying by `ns.db.keys.char`**: in a session where AceDB loaded before the client named the character, it is a placeholder. Use `ns.GetCharacterProfileName()` with `ns.db.keys.char` only as the fallback.
- **Mixing the two character keys**: AceDB profile names and `ns.GetCharacterKey()` differ in shape, and on Forever the profile name joins with a literal space while `ns.GetPlayerFullName` uses the client's surname separator. Go through the readers in `Features/Utilities.lua`.
- **Naming a character with `UnitName` alone**: on Forever that is the first name only. Use `ns.GetPlayerFullName` / `ns.GetCharacterKey` / `ns.GetCharacterProfileName`.
- **Putting a setting in the wrong scope**: the profile is one character's own. Add to global only for a concrete account-wide reason, written beside the key.
- **Two features declaring one default**: `AddDefaults` stops the load.
- **Dropping `noDefaultProfiles` early**: the Profiles picker would offer "Default", and `ns.MoveCharactersOntoOwnProfiles` moves any character on it off again next login. It comes out with that migration.
- **A remembered item miss outliving its answer**: the item is stranded for the session. Every answer reaches `ns.ForgetItemDataMiss` first, and anything parked on an item keeps its waiter keyed in (`ns.SyncRestockItemInfoSubscription`). A new waiter must release its key, or `GET_ITEM_INFO_RECEIVED` stays registered.
- **Warming an ID that can't answer**: `ns.WarmItemCache` skips cached, failed and nonexistent IDs; a new warmer that requests them could hold the event all session.

### Messages and data

- **A `|4` plural escape in a sent line**: `SendChatMessage` drops the whole line, and nothing on the send path resolves it. Run client duration strings through `ns.FormatDuration` (`Utilities.lua`).
- **Sending a marked line to a numbered channel**: Forever blocks raid-marker tokens there. `SignOff` always adds `{rt1}`, which is safe only because sends go to whispers and group chat; a new channel kind must leave the marker off.
- **Calling `C_ChatInfo.SendChatMessage` directly**: skips the nil-channel / empty-line guard and the whisper queue. Go through `ns:Announce`, `ns:QueueAutomatedWhisper`, `ns:SayBuffRequest`.
- **`string.format` on an editable whisper's saved text**: a stray `%` breaks it. Tokens fill through `FillTokens` (gsub with a function, so values are literal).
- **Putting a whisper's default text in `Locales/`**: AceLocale loads only the client's locale, so another Send Messages In language would have no text. Defaults live in `Data.MESSAGE_LANGUAGES`; keep `"Opt Out"` English in every row, since Rank Watch listens for exactly those words (`OPT_OUT_WORDS`).
- **Editing a language's `buffAsk` default alone**: `buffAskOne` / `buffAskCount` replace it while the text is the default, so the three must keep matching grammar.
- **Saving a whisper text equal to the default**: `ns.SetMessageText` clears it to nil on purpose so it follows a later language change; `""` is kept and sends nothing.
- **Closing punctuation in a sent body**: `TrimSentBody` always strips it before the sign-off; a translation using another closing mark needs it in `CLOSING_MARKS`, matched as whole UTF-8 sequences.
- **Chat length in characters**: `ns.CHAT_MESSAGE_MAX_LENGTH` is bytes; non-Latin locales spend 2-3 per character.
- **Moving `Data/Message-Languages.lua` in the TOC**: `Data/Default-Settings.lua` reads `Data.DEFAULT_MESSAGE_LANGUAGE` at load, so it must stay before it.
- **Editing `POPUP_REPLACED_RELOAD` to change the after-import popup**: `ns.OfferLegacySteps` swaps `GOODTOGO_REPLACED_RELOAD`'s text to `POPUP_LEGACY_RELOAD_COPIED` at runtime.
- **Legacy popup Escape**: means "ask again next login", not decline (`noCancelOnEscape`).

### Consumable Macros and Reports

- **Editing macros in combat**: silently blocked. Consumable Macros route through `ns.RequestUpdate()`; the write replays after combat.
- **Writing a macro while the Blizzard Macro UI is open**: its save-back reverts the write after the state key recorded it. `ns.UpdateMacros` defers while `MacroFrame` is shown; never write around that guard.
- **A body input missing from the state key**: the macro silently goes stale. Keys are lossless, override modes use disjoint prefixes.
- **Recording a state key when the write failed**: a full General tab blocks every retry. Keep `ns.WriteMacroBody`'s false return meaningful.
- **Passing a non-boolean `perCharacter` to `CreateMacro`**: the client boolean-checks it. Consumable macros omit it (General).
- **Changing a shipped macro name** (`MACRO_*`): it creates a second macro and strands the old one on every bar. Macros are found by name.
- **Setting `ranked` without `ns.MULTI_USE_MACRO_TYPES`, or the reverse**: the scanner reads one and the engine (and Message Length) the other. Set both, and only where every item shares one cooldown.
- **Moving a Consumable Macros handler below `OnEvent`'s combat guard**: it misses mid-fight changes and signatures drift. Below-guard baselines are kept honest only because every scan re-records them; a new baseline needs the same.
- **A new bag-reading override**: scroll, pet-buff, pet-food, poison and Buff Duty buff food selection bypass the scan's gates, so each checks the Ignore List and usability itself. A new one must too.
- **Holding the aura snapshot**: `ns.GetPlayerBuffSnapshot()` returns one shared buffer the next call overwrites. Take one per pass and pass it down. While auras are secret it returns the last readable snapshot; never reset it to empty, which reads as "no buffs".
- **Keeping or writing scan output**: `ns.scannedItemCounts`, `ns.scannedItemLinks`, `ns.scannedIgnoredTypes`, `ns.carriedBuffFoods` and `ns.bestSelection` are wiped and refilled in place every scan. `ns.ScanPetFood` outside an update pass reads a stale snapshot.
- **Putting buff food first in the Water macro, or in Food while Well Fed**: eating for Well Fed is otherwise Buff Duty's icon; `ns.buffFoodRank` is only `"last"` or false. `"first"` comes only through `Ranking.BuffFoodRank`: Buff Duty's own pick, and the Food macro (`buffFoodFirstWhenUnfed`) under `ns.buffFoodFirst`.
- **Ranking buff food apart from `Ranking.BuffFoodRank`**: the scan and Diagnostics both ask it, so they always pick the same item; a caller reading `ns.buffFoodRank` directly misses the Well Fed case.
- **Expecting the Food macro to see Well Fed come and go without buff food in the bags**: player `UNIT_AURA` is registered only while `ns.carriesBuffFood`, the one time Well Fed changes what Food eats; `ns.wellFedState` is otherwise read at the top of each scan.
- **Gating Feed Pet's or Poisons' delete on the class**: both sit in the General tab every character shares, so an unticked one must be deleted wherever it's found; only the update stays on its class.
- **Changing what Buff Duty's buff food pick depends on without a rescan**: `ns.bestBuffFoodID` is decided only in `ns.ScanBags` (reading Buff Duty's `buffWindow.buffFoodOff`), so a setting that changes it must call `ns.RequestUpdate`.
- **Dropping Buff Duty from a TOC**: `ns.ScanBags` calls `ns.RequestBuffDutyRefresh` unguarded whenever the buff food pick changes.
- **`ns.HasScrollBuff` looks read-only**: through `BuffCountsAsActive` it arms `ScheduleExpiryRecheck`, a throttled macro rebuild. Readiness and Diagnostics calling it cost one extra pass, harmless; don't call it on a hot path.
- **`ns.ResetScrollBuffTracking` by its name**: it resets only the pet food reading; scrolls have no tracking in the macros.
- **A new cast trigger**: `UNIT_SPELLCAST_SUCCEEDED` registration is decided once at login by class and race (`InitializeConsumableMacros`). Change both `ns.SpellCastChangesMacros` and that registration.
- **Adding a `ns.BuildStandardBody` input without threading it through the trims**: each trim rebuilds by calling itself with one input dropped; a trim that forgets the new argument silently writes a body without it. Message Length's `LongestBodyFor` also calls it positionally (it passes no `leadCast` / `combatCast`).
- **Anything new that reads the target**: it must join `ns.TargetSignatureChanged` (friendly player, self, friendly level, cannibalizable), or its macro goes stale on a target change.
- **Gating a scroll on its required level**: deliberate that it doesn't. The level only sorts the list.
- **Iteration order in a pick**: `pairs()` order churns rewrites. `RANKING_PRIORITY`, the pet food pick and the poison lists all end on item ID; expiring auras end on name.
- **Data row order meaning anything**: `Smart-Spell.lua` sorts `ns.CONJURE_SPELLS`, `Scanner-Auras.lua` sorts `ns.SCROLL_DATA` items, `Tools-Hunters-Pet-Food.lua` sorts `ns.PET_BUFF_FOODS` and `Tools-Rogues.lua` sorts `ns.POISON_DATA` groups, all at load; Diagnostics' `CONJURE_SPELLS.<list>[n]` indices are the sorted order.
- **Marking a non-flag-2 item conjured**: `isConjured` comes only from the food table's arena column value for conjured; zero-price or "Conjured Item" foods are ordinary on purpose.
- **Moving a burn-first step above `value`**: a zone-locked weak potion would beat a strong one. They are tiebreaks only, never bonuses.
- **Shuffling the TOC order**: `Scanner-Inventory.lua` captures `ns.ScanRanking` at load after `Scanner-Ranking.lua` builds it and `Scanner-Diagnostics.lua` adds to it; `Engine.lua`, `Tools-Hunters.lua`, `Tools-Rogues.lua` capture `ns.MACRO_CONFIG`; `Readiness-Report.lua` captures `ns.GroupHasClass` / `ns.PartyHasClass` from Probes; the Example captures `ns.ReadinessClause` / `ns.ReadinessLine`; `Inventory-Report-Recording.lua` captures `ns.BankBagIDs` (`Features/Utilities.lua`); `Macro-Notes.lua` captures `ns.KnowsAny`; `Options-Macros-Utilities.lua` must load before every page file.
- **Message Length printing a real warning**: it builds through `ns.BuildStandardBody`, whose still-too-long `ns.WarnOnce` can fire in chat and spend that macro's once-per-session warning.
- **A table default under `readiness*`**: Readiness Reset would alias `ns.DATABASE_DEFAULTS` and `ReadinessAtDefaults` would never match. Keep them scalar, and keep non-category keys off the prefix.
- **A Readiness probe that can throw**: `ns.OnReadyCheck` calls probes unguarded, so one error silences the whole report on that client. Put client gaps behind a `Features/Utilities.lua` accessor that answers nil.
- **An all-clear line in the Readiness Report**: silence is the feature.
- **Reading containers for the Inventory Report at logout**: Forever's containers can read empty then; only last-read snapshots are written.
- **Saving the Inventory Report from `PLAYER_LOGOUT`**: AceDB's logout handler runs first and strips `inventoryReport = true` as a default, so the switch reads off and nothing saves. `SaveSnapshot` rides `OnDatabaseShutdown`, which fires before the strip.
- **Hooking the Inventory Report tooltip at load**: its block would land above other add-ons'. `TOOLTIP_HOOK_DELAY` is deliberate; items hovered in the first seconds show no block.
- **Treating the Inventory Report as its own module**: it rides the Restocker's dispatcher; a Restocker event change can affect it.

### Restocker

- **`UseContainerItem` while a merchant is open**: it sells. The bank run aborts on `ns.merchantIsOpen`, and the merchant code has no sell path.
- **`PutItemInBag` or `PutItemInBackpack` in the bank run**: both clear the cursor even when the server refuses, so "did it land" always reads yes. Name an empty slot (`BagDefinition:PutCursorItem`).
- **Testing a slot empty by its link**: the link is nil for a cold item too, so placement lands on an occupied slot. `PutCursorItem` tests `C_Container.GetContainerItemInfo`.
- **Clearing the cursor inside `PutCursorItem`**: the caller can no longer try the next bag. It leaves the item; the callers clear after the last attempt.
- **Leaving a split on the cursor**: the next split fails. Every failed placement and the tidy top-off end in `ClearCursor()`.
- **Trusting a container's free-slot count**: on Era and TBC the main bank reports slots the scan can't find, and a specialty bag's free slots can't take most items. Placement keeps trying the next bag; `BagTypeAccepts` filters by item family.
- **Deducting from a plan optimistically**: a move that didn't land goes unnoticed. The run rescans every step, and the watchdog stops it.
- **Counting only a fall in remaining work as progress**: on Forever the bank's contents arrive late and an overshoot adds stash work, so the run would stop as stuck. The watchdog counts any change.
- **Acting on a scan with a move in flight**: nothing is locked mid-transit, so the total dips and the run pulls a duplicate or finishes early. The in-flight gate waits `MAX_INFLIGHT_STEPS`.
- **Waiting on a lock with no limit**: one of ours held on the cursor, or a lock the server never clears, would freeze the run. The lock gate gives up after `MAX_STUCK_STEPS` ticks (`lockedTicks`).
- **Clearing a cursor item that isn't ours**: it snaps back the player's own drag. `ClearCursorForScan` clears only list items at once and waits out anything else.
- **Retrying a stash into a full bank first**: it starves every pull. Pull first while `ns.BankHasRestockSpace()` is false.
- **Resetting `overshotItems` on a restart**: a Store-off row keeps the whole stack the add-on overshot with. `ns.RestartBankRestock` carries it (and `movedAny`) within a visit.
- **Live-reading Keep during a bank run**: a half-typed number would move stock. Read `RestockState:Wanted`; Enter restarts the run.
- **Treating an emptied Keep box as 0**: 0 means keep none (store all with Store). An empty box saves nothing and restores on focus loss.
- **Reading a row control's item through `GetParent()`**: pooled rows rebind, so it points at another item. Every control carries `self.item`, rebound by `ns.UpdateRestockListRow`.
- **Keeping a Keep box bound across a redraw**: the next keystroke sets another row's amount. The render nils `amountBox.item` and clears focus before release, then refocuses the box now showing the typed item.
- **A remove's double-click**: the redraw puts the next row's button under the second click. `DOUBLE_CLICK_GUARD_SECONDS` ignores it.
- **Feeding the column menus the render list**: it includes the removed row. Read `ns.GetRestockShownItems`, which leaves it out, as the category counts do.
- **A table-valued row field**: `ListSignature` skips tables (an edit there won't drop the Undo row) and the saved format can't pack one.
- **Treating a row as a table after `ns.DeflateRestockItemsForSave`**: it is a string by then, which is why it runs last at logout.
- **Folding a default-on flag into `x and false or nil`**: it yields nil for every input, so the off state never saves (see `ItemFromString`).
- **Reading a nil flag with plain `not`**: `buyFromMerchant` and `upgrade` default on, `buyExtra`, `stashToBank`, `restockFromBank` off. `COLUMN_STATE` encodes each; `COLUMN_SET` writes explicit booleans.
- **Counting items by name**: an unresolved name reads as 0 and buys a full stack. Count by item ID.
- **Parking an add under a link**: the retry looks up by numeric item ID. Input with no ID is refused, or its key would hold `GET_ITEM_INFO_RECEIVED` all session; a typed ID with no item is refused up front (`C_Item.DoesItemExistByID`).
- **Counting bank stock in the reagent order**: the add-on stashes the excess itself, so the reagents would never be bought. `ns.BuildCraftingPurchaseOrder` counts bags only.
- **Buying half a recipe**: vials without dust craft nothing. The reagent order is all-or-nothing per vendor; a sold-out limited slot counts as not stocked.
- **Letting a reagent surplus go negative**: it shrinks the listed row's order it merges into. The reagent order floors at 0 and takes a listed reagent's Keep off the bag count first.
- **Counting buy calls, or bags right after sending**: two stacks is two calls, and bags update only on `BAG_UPDATE`. Orders count units; the report counts units delivered after `ns.AwaitMerchantRun`.
- **One call for a limited slot holding more than a stack**: the server refuses it yet the order would read filled. Every purchase goes through the chunked loop.
- **Buying at an open merchant through `ns.OnRestockerMerchantShow`**: its throttle and Shift check swallow a list switch. `ns.SwitchRestockList` resets the throttle and calls `ns.RestockFromMerchant`.
- **Rebuying on a list switch before the last run's buys land**: a run counts only what is already in the bags, so it buys the in-flight items again. The switch waits behind `ns.AfterMerchantBuysLand`.
- **Saving the Restock List's spot at logout**: a never-dragged window would gain a saved spot and lose its right-edge default. Logout saves size only (`ns.SaveRestockWindowGeometry(true)`); drag and resize save the spot.
- **Putting Staples' stack menu back on `WowStyle1DropdownTemplate` or the game's context menu**: the maintainer chose the kit's menu on every client; it is a plain button opening `ns.RestockMenu`.
- **Switching lists from a delete**: `ns.SwitchRestockList` reruns the buy and bank run. Delete uses `ns.UseRestockList` and stops the bank run.
- **Re-reading `currentList` in a confirm's OnAccept**: the window isn't locked behind the popup, so a switch redirects it. Delete carries the name as data; Copy carries `{ source, target }` and acts only while `target` is still current.
- **Writing `settings.currentList` directly**: the character's choice, New flags and group selection go stale. Use `ns.UseRestockList`.
- **Auto-joining an existing class-named list**: the new character's Staples ticks and upgrades write into someone else's list. `FreeClassListName` numbers; `IsListNameTaken` also counts dangling choices.
- **A `_CLOSED` event with no open**: loading screens fire them, sometimes twice. Close handlers key off `merchantIsOpen` / `bankIsOpen`.
- **Switching the Restocker off mid-visit and waiting for `_CLOSED`**: the sleeping handler never sees it and the open flag sticks. `ns.SetRestockerEnabled` ends both visits itself.
- **Comparing reminders against the footer**: reminders and the mini-map split every short row by the threshold; the footer counts and lists every short row unsplit; `ns.BuildGroceryList` (Buy rows only) is Diagnostics'. Pick the list that matches the surface.
- **Upgrading off `UnitLevel` inside `PLAYER_LEVEL_UP`**: it still reads the old level. Pass the event's level through.
- **A resting event during a load**: it would consume the transition the login is about to report. The town reminder does nothing until `PLAYER_ENTERING_WORLD` arms it, and a `/reload` arms silently.
- **Printing a Verbose reminder with cold links**: a "Loading item" chat link never updates. Login requests the list's items and waits `LOGIN_SETTLE_DELAY`.
- **Closing pooled-row menus late**: a pick lands on a rebound row. `ns.UpdateRestockList` closes them first; the reputation pick is also pinned to the item it opened for.
- **Closing `ns.RestockMenu` without checking its anchor**: one kit menu serves every Restock List menu, so it shuts another control's menu. The list and Manage closers test `IsOpenFor`; the reputation and column closers don't, because a redraw wants any open kit menu gone.
- **Releasing the bag pullout on close**: an Execute item closes its pullout from inside its own OnClick, freeing it mid-handler. Built once, `Clear()` and scrolled to top at open.
- **Using `UIDropDownMenu` in the window**: it taints shared frames. The kit menu and the one plated AceGUI pullout only.
- **An AceGUI Dropdown for a field**: ElvUI's AceGUI skin restyles it alone and moves the geometry its neighbors anchor to. Fields are `ns.CreateRestockMenuField`.
- **Escape with Staples open**: one press closes every `UISpecialFrames` window. Staples takes the Restock List off and hands it back a frame later, after `CloseSpecialWindows` finishes walking.
- **Reading `openedFromLogin` after hiding Staples**: OnHide clears it. Done reads it first, then hides, then opens the Restock List.
- **Anchoring a header or footer control to the window**: it lands mid-window behind the list. Parent to the header bar or footer bar.
- **Re-reading a Staples row's `chainKey`**: it is replaced by `row.chain` at load.
- **Reading a ladder by row order or level**: tiers are sorted by rank (third field) at load in `Restocker-Upgrade.lua`; same-level tiers are settled by rank.
- **Keying item groups by name**: a translated New or Other can equal a client class name. Keys are classIDs and sentinels.
- **`string.lower` or `#` in the filter**: ASCII-only fold and byte length. `Fold` and `CharacterCount`.
- **Raising the category pane's cap alone**: the item name loses its floor. `MIN_WIDTH` (`Restocker-Window.lua`) is built on `GROUP_PANE_MAX_WIDTH`.
- **Measuring with a font not yet loaded**: it reads 0 at login. Column widths re-measure until resolved (`ns.ResolveRestockColumns`); buttons keep their width on a 0 (`ns.FitRestockerHeaderButton`, `ns.FitRestockButton`).
- **A Restocker handler that skips `WhileEnabled`**: it runs with the feature off; only logout runs unwrapped. The Inventory Report rides the same dispatcher, so a Restocker event change can affect it.
- **Dropping an `EVENTS` name the Restocker doesn't handle**: `PLAYER_REGEN_ENABLED` is the Inventory Report's, which reads a fight's bag changes once it ends.
- **A new Restocker option outside the switch**: `Kit.HideAllExcept` hides every arg not in its keep list while the Restocker is off; add a key there only if it must stay visible.
- **Adding a manual bank-run trigger to Diagnostics**: that panel is read-only and the run moves items. Reopening the bank, Enter or a list switch restarts it.

### Buff Duty

- **Changing a Buff Duty button outside `ns.SetBuffButtonAttributes`, or in combat**: pooled buttons keep stale attributes, and protected changes are blocked.
- **Casting a buff by spell ID or bare name**: on Classic Era a lower rank's ID casts nothing, and a bare group-buff or resurrection name casts Rank 1. Cast by `BuffDuty.CastText`; only Create Soulstone and a warlock stone's create go by bare name (each tier its own spell, so a rank suffix names nothing).
- **Setting `type` or `type2` on a window button**: right-click would cast. Only `type1` is set, leaving right-click to dismiss a favor.
- **Registering a secure button for `AnyUp` only, or dropping the Buff Key's `useOnKeyDown` false**: dead for players who cast on key down, or a macro's lone up casts nothing.
- **Acting on both halves of a click**: buttons hear down and up. The ask whisper, the key's `Remember` / `NoteBuffCastAttempt` and notices run on the up half only, or they fire twice.
- **Putting a Buff Key cast back into a macro line** (`/target` + `/cast`, or a self item's `/use`): on Forever those lines never went off, from the key or a `/click GtGBuffKey`, and why isn't known. Casts on others go as spell + `unit` and never change your target; Return the Favor's targeting macro is the one macro left.
- **Naming a self consumable by `item:<id>`**: aimed at `player` it used nothing on Forever. `spec.selfItem` goes to the item action by name (`ItemUseName`). Weapon items are the opposite: keep `item:<id>` + `target-slot`, which apply from a click, the key and `/click` alike.
- **Returning an ask as the Buff Key's pick**: an ask casts nothing, so the press would only whisper. `PickNext` returns the first askable icon fourth and keeps looking for the cast; `OnKeyPreClick` whispers it and casts in the same press, and skips the notice when the whisper was all it did.
- **Giving an ask spec castable attributes**: `ns.SetBuffButtonAttributes` clears an ask's on purpose, so the click only whispers. Its `unit = "target"` is also what lets `ns.DropBuffDutyTargetIcons` strip it on a target change.
- **Moving `ns.ExpectReplaceEnchant` to PostClick**: the secure click raises `REPLACE_ENCHANT` before PostClick runs, so the popup is never answered.
- **Clearing the Buff Key fully after a Bloodrage-first press**: Bloodrage can start combat and lock the button; PostClick leaves the buff's own cast on it so the next press still casts.
- **Closing Buff Duty through the template's close click**: it hides a protected parent. The button runs `ns.CloseBuffDuty`.
- **Gating Buff Duty's data on `ns.IsBuffDutyOnForClass`**: after a close the Buff Key would cast from stale auras. Events, backstop, aura handler and combat-log sync follow `ns.IsBuffDutyTrackingForClass`; only the window's visibility follows OnForClass.
- **Leaving Buff Duty's target icons up past a target change, or after a failed redraw**: their buttons cast at whoever `target` now names, an NPC's buff on a player included. `ns.DropBuffDutyTargetIcons` strips them before the immediate `Refresh`, and `Refresh` hides the window when build or render errors. Two `xpcall` guards there are deliberate (README-Notes).
- **Moving a targeted NPC's row up the Buff Key's order**: its cycle never empties, so the key would never reach the group.
- **Letting the Buff Key press while eating, casting or targeting**: another press would restart the meal, stand you up, or cut the cast. `Busy()` keeps it silent; the Well Fed icon also hides while you eat, or a second click spends a second food.
- **Passing `now` to `GroupChoices` from the window**: the drawn raid headers would follow the key's press memory. The window calls it without `now`; only the key weighs recent casts.
- **Calling `GroupChoices` for a folded raid header after `ResurrectionRows`**: it weighs a group cast against the members' singles, which folding drops from the rows. `AddGroupSections` calls it on `party.rows` first, then folds.
- **Treating every header icon as a group cast**: a folded raid header also holds counted single casts (`FoldedIcons`); `GroupChoices` skips non-`isGroup` specs and `AddParty` adds them separately.
- **Moving Return the Favor ahead of your target in `Candidates`**: a favor's macro clears your target to find the stranger by name. The target's rows come first; their icons leave once their buffs land, and the key moves on.
- **Fading Window Opacity on `content` or `anchor`**: text and icons would fade too, and `anchor` belongs to the Hide in Combat state driver. Only `content.menuKitPlate` takes the alpha.
- **A new way to show an opacity preview without `EndPreview`**: the window keeps the hovered value, unsaved, until the next apply. Hovering another row, the cursor leaving the panel and the menu hiding all restore the saved one.
- **A cast reaching a PvP-flagged player that skips `BuffDuty.PvPFlaggedTarget`**: buffing them flags you. The window icon (`spec.pvpFlagged`, attributes cleared), the key's `PickNext` and `Signature` all read it; a new group-reaching self buff needs `party` set so your party is checked.
- **Refreshing on every `UNIT_FLAGS`**: it fires for every flag on every unit. `OnUnitFlags` watches only player, target, party and raid, and refreshes only when a PvP flag flips.
- **Reading `selfRefresh` as a timing**: its values now only say on or off (`BuffDuty.SelfItemOn`); the timing is the category's Show (`BuffDuty.RowShowSeconds`). A stored 3 or 5 is just "on".
- **Leaving `dutyRow` off a category's icons**: the Buff Key's `Candidates` reads it for Use with Cast Next Buff (`RowOnKey`); untagged, a category the player kept off the key still gets pressed.
- **Leaving a field out of `Signature`**: an otherwise unchanged list skips the redraw and the button keeps the old attributes, the hover menu the old names, or a fold glyph its old state.
- **Making a `column` non-numeric or reusing one in a grid**: `GridSlots` sorts columns numerically; scroll icons sit at `buff.column + index / 10` and elixir icons at `+ index / 100` to stay together after their column, and resurrections at `RESURRECTION_COLUMN` (0).
- **Shuffling the Buff Duty TOC order**: files capture earlier files' functions and tables at load (Load Order above). Key-Picker reads `BuffDuty.BuffKeySkipped` at call time because Keys loads after it.
- **Capturing `BuffDuty.soulstoneBuff`, `soulstoneEntry` or `resurrection` in a local**: each rebuild replaces the table, so the local goes stale. Read them off `BuffDuty`.
- **A list of possibly-nil sections or rows in `ipairs`**: it stops at the first nil, dropping Return the Favor after an empty Target, or the pet row after a missing Ask row. `AddOutsiderSections` and `TargetSection` append one by one.
- **Calling `BuffDuty.GroupMembers` expecting a fresh read during a redraw**: `HoldGroupMembers` hands back one read for the whole redraw. Hold only around one synchronous pass.
- **Giving a pet row its own `Has` verdict over a hold**: pet auras reach the client unreliably, so a seen-but-weaker version keeps its hold until it runs out; only `Has` agreeing clears it.
- **Expecting Well Fed to follow the bags at once**: it reads `ns.bestBuffFoodID` from the consumables scanner, which redraws Buff Duty when the pick changes. A buff food switch must call `ns.RequestUpdate` (the Well Fed menu does); `ns.RefreshBuffDuty` alone keeps the old pick.
- **Reading scroll counts from the scanner's bag table**: the window passes live counts (`liveItemCounts`) to `ns.FindBestScroll` so a looted scroll shows on the next redraw; the finder applies the Ignore List itself, since raw counts skip the scanner's filter.
- **Changing the Options menu's close logic for one owner**: the mini-map menu opens the same menu; `ns.HideBuffDutyOptions(within)` and `ns.IsCursorOverBuffDutyOptions` keep both the window's lines and the mini-map menu working.
- **Hand-building the category and Options menu, the Party-Buffs menu or the window's header and foot**: they are Menu Kit (`Kit.CreateMenu`, kit panels, `Kit.AddWindowHeader`, `Kit.AddOptionsLine`) so they match every other Gogo menu; the window plate is `Kit.AddPlate` for the same reason.
- **"Fixing" the window's title, 20-point icons or per-character scroll types to the Style Guide**: each is a README-Notes exception (title bar too small for the Full Name; size chosen by eye; scrolls differ per character).
- **Subscribing `UNIT_POWER_UPDATE` for every class**: it is only read for a warrior's rage (Bloodrage first); anyone else would hear every mana tick.
- **Rewriting `READS_COMBAT_LOG` in `Buff-Duty-Events.lua`**: `Tests/Run.lua` requires the literal `ns.FLAVOR ~= "Camelot"` in any Camelot-listed file naming `COMBAT_LOG_EVENT_UNFILTERED`; registering it on Forever raises `ADDON_ACTION_FORBIDDEN`.
- **Adding a combat-log consumer without widening `SyncCombatLog`**: the event is subscribed only while Return the Favor is on or a resurrection is known.
- **Changing `ReadWeaponEnchants`' return shape**: the Readiness Report (`Readiness-Report-Probes.lua`), the consumable macros' manifest and the context report read it.
- **Changing the window's group read, holds, Well Fed read, ask filters or weapon fit without the context report**: `Manifests-Buff-Duty.lua` re-implements `GroupUnits`, the held-buff list, `ReadWellFed`, the scroll and ask checks and the weapon subclass read for its lines.
- **Treating a ticked weapon choice for an unknown ID as junk**: Era and Season of Discovery share `weaponPicks`; one client's poison is the other's to keep.
- **Trusting the context report's camp benefit lines**: `CampBenefitLines` and the consumables manifest's camp rows read `campBenefits`, `CAMP_BENEFITS_SPELL_ID` and `CAMP_BENEFIT_LINE_NAMES`, which nothing defines, so they always report no camp item; neither the scroll check (`Scanner-Auras.lua`) nor Buff Duty reads a camp item. Defining the data alone changes only Diagnostics.
- **Tagging party rows with `sectionTitle`**: `TagSection` leaves it nil there on purpose, so a party member's icon tooltip falls back to `targetName` instead of the party's label.

### Rank Watch

- **A second `ns.SetRankWatchHandler` for an event**: it silently replaces the first. `Rank-Watch-Detection-Forever.lua` replaces Check's `PLAYER_REGEN_ENABLED` on purpose and so must schedule `ns.ProcessRankWatchQueue` itself; any new handler for a shared event must carry the old one's work.
- **Load order of detection files**: they capture `local Check = ns.CheckRankWatchCast` at file load, so they must load after `Rank-Watch-Check.lua`.
- **Rank Watch on Mists**: absent by TOC, not by empty data. A new outside caller must test that the function exists; Diagnostics append empty rows when `ns.RankWatchSettings` is missing.
- **Whispering the data's rank number**: TBC's sheet numbers a joined group's ranks through the whole group, so it can disagree with the reader's spellbook. Whispers wait for client rank text and are dropped otherwise; only prints fall back.
- **Changing the announced key or cluster messages**: the standalone Rank Sentinel shares `RANKSENTINEL`, `NOTIFY` keys and LEAD/JOIN; a different shape double-reports or breaks election. `COMM_RELEASE` is a value Rank Sentinel reads as its own dev build, so it never nags its users to update.
- **Saving a `NOTIFY` / `SYNC` key unchecked**: it persists in `announced` for good; only `ANNOUNCED_KEY_PATTERN` matches are kept.
- **A leader with Whisper off**: it doesn't claim, and `ns.RankWatchWhisperer` returns nil when it leads, so nobody in the group whispers. Deliberate: a silent copy must not hold the lead from a joiner who whispers.
- **Calling `ns.RankWatchWhisperer` from a probe**: it claims the lead from an offline leader and tells the group. The Context report works the answer out itself.
- **A leader turning off silently**: the others would keep naming it and nobody would whisper. It broadcasts `JOIN` first, and a JOIN from the leader makes a whispering copy claim.
- **Changing Whisper without re-syncing**: the panel's Whisper setter calls `ns.SyncRankWatchEvents` so the cluster re-JOINs and claims (or stops claiming) the lead; a new writer of `whisper` must too.
- **`ns.GetUnitByGUID` also matches target/focus/mouseover**: a match is not group membership. Forever's `CheckAura` rejects those caster units, and `OnChatMsgWhisper` accepts only a `party` or `raid` unit, so a targeted non-member can't opt out.
- **Translating "Opt Out"**: the listener matches the English literal `OPT_OUT_WORDS`; every language's offer keeps it in English (`Data/Message-Languages.lua` header).
- **Recording every rank's tracked state explicitly**: freezes it against later data changes. `ns.SetRankWatchRankTracked` clears an entry that matches the data's `off` default.
- **Calling `ns.RankWatchSettings()` from a probe**: it writes (a migration). The Context report reads `global.rankWatch` directly, though it still calls `ns.IsRankWatchActive()`, which goes through the accessor.
- **Treating a pet cast's ceiling as the owner's**: a hunter pet can trail its hunter, so the pet's level is the ceiling and the `announced` key carries it; the owner's level only picks the grace period.
- **Composer order slots**: `Options-Rank-Watch.lua` gives 11.1–11.49 to the tip composer and 12–12.29 to the opt-out composer; a new control placed there interleaves with composer rows, and a new message grows its slot by 0.1.
- **Adding a Rank Watch panel control after `Kit.HideAllExcept`**: it wraps only args present when called, so a later arg stays visible while Rank Watch is off. Add controls before it; add a key to its keep list only if it should show while off.
- **Expecting Rank Watch's switch to stop the level-up prints**: Ability Alerts While Leveling is its own switch (`rankWatch.levelUpAlerts`), its module always subscribed. Reset Profile does turn it back on (`RESET_KEYS`).
- **Adding an AceDB default for a whisper text key**: it would never read nil, so the text could not follow the Send Messages In language or be told apart from an edit.
- **Rerunning `Tools/Build-Rank-Watch-Abilities.py`**: merges onto the shipped tables, keeping every row and ability (off ladders, level-less rows, Forever's corrections) and their How We Got the Data block; adds a Rank Sentinel rank only when the flavor's own Trainer-Spells or Class-Spell-Lists knows the spell, and prints what it kept, added and left out. On unchanged sources it rewrites every file byte for byte (verified against `../Rank-Sentinel`). An unreadable existing row stops it.
- **Rerunning `Tools/Build-Rank-Watch-Pet-Abilities.py`**: rebuilds Vanilla, Discovery and TBC whole from `Pet-Abilities-{Game}.lua` and rewrites Mists/Wrath/Mainline empties, replacing each file's hand-set How We Got the Data block (Last Validated, Vanilla's wago.tools links) with its "Never"/"None" template; any hand edit to those tables is lost. Camelot is untouched without `--wago`. Restore the footers after a run.

### Enhanced Spellbook

- **Localizing `ns.IsOptionOn`, `ns.UseItemSlots`, `ns.WarnOnce` or `ns.HandOverMacro` as file locals in the Spellbook**: breaks Message Length (`Diagnostics/Message-Length-Enhanced-Spellbook.lua`), which swaps those `ns` fields for one pcall'd `CollectMacros`. Call them through `ns`.
- **Capturing an `ns` function as a file local before its file loads**: several files capture `ns.X` at load (`Spellbook-Events.lua` takes `ns.RefreshSpellbookPage`, `ns.UpdateSpellbookMacroCount`, `ns.spellbookPages`; `Conditionals-Rows.lua` fills `ns.ConditionalsUI`), so the TOC order is load-bearing. Keep a new provider ahead of its consumers in every TOC.
- **Editing a Conditionals row or Cast Sequence step in place**: Duplicates share rows (`ns.DuplicateMacro` copies one level only). Setters copy (`CopyRows`, `CopySteps`) and store fresh tables.
- **Holding an `ns.macros` entry across a change**: every refresh rebuilds them all. Re-find by `ns.SettingsKey` (panels) or `ns.MacroMenuRebuiltMacro` (menus).
- **A menu callback that forgets its return value**: in `ns.OpenMacroMenuPanels` an action closes the menu unless it returns `MenuResponse.Refresh`, and a checkbox or radio redraws unless it returns `MenuResponse.CloseAll`.
- **Two sibling sub-menus with one label**: a redraw reopens open sub-menus by label (`ChildByKey`), so the first match wins.
- **Opening a Spellbook menu through the game's `MenuUtil` or a skin add-on**: Style Guide MENUS asks for the kit's panels; route through `ns.OpenMacroMenuPanels`. Only the controls-row dropdowns go through `ns.SetupKitDropdown`.
- **Two `ns:On<Event>` methods with one name**: the later file silently wins, since handlers resolve by name on the shared `ns`. The Spellbook prefixes its pet, level, target, bag and skill handlers (`OnSpellbookUnitPet`) because `ns.OnUnitPet` belongs to Feed Pet.
- **Deleting by tag alone**: a player's own `#end` line looks like a tag. Delete requires a handed-out tag and an ownership record.
- **Moving a WoW macro between lists by delete then create, or by re-reading its icon**: deleting first shifts that list's indexes, and `GetMacroInfo` returns the spell's icon for a question-mark macro. `MoveTo` creates first with `ns.WowMacroIcon`, re-places every bar slot, then deletes; `ns.SetMacroTab` checks free slots for every sharing macro before moving any.
- **Resetting `macroTab` with the other options**: the setting must match where the WoW macro actually is. `ns.ResetMacroSettings` leaves it (`KEPT_SETTINGS`); only Delete (`ns.ResetMacroOptions`) clears it, after the WoW macro is gone.
- **Reading a bar macro through `GetActionInfo`**: a macro showing a spell returns the spell ID. Use `GetActionText` (`ns.ActionMacroName`); `ns.ActionMacroTag` reads by index where possible, since stored names are cut short and two macros can share one.
- **Matching stances or forms by tooltip text**: some locales name forms apart from their spells. Use the class lists' IDs (`StanceSlot`, `RequiredForms`).
- **Keying a spell's settings by its lowest known rank**: on Forever a replaced Rank 1 is in neither the known nor unknown list, so the key would move and settings vanish. `ReadSpellbook` records `baseID` before that filter; `BaseSpellID` prefers it.
- **Reading another class's `CLASS_SPELL_LISTS` or `TRAINER_SPELLS`**: `Class-Config.lua` empties them at load.
- **Turning the Spellbook off**: `RefreshMacros` no-ops for every caller, so macros freeze as written. Deliberate.
- **Right-Click For (`groupVersion`) with a Conditionals `rightClick` row**: the two block each other. The tile menu disables Right-Click when `ns.ConditionalsUseRightClick`; the category menu's Grouped skips macros with a `rightClick` row.
- **Writing a macro while the Macro UI is open**: the Blizzard Macro UI saves its edit box back over the selected macro on selection change and hide, reverting the rewrite. Every sync, `ns.SetMacroTab` and Delete refuse while `MacroFrame` is shown; the `OnHide` hook catches up.
- **Measuring a body before its tag exists**: the tag can widen past `TAG_WIDTH`. `UNASSIGNED_TAG` reserves the length, and `ns.PickupMacro` re-checks `Fits` after `AssignMacroTag`.
- **Reading `UnitLevel("player")` inside `PLAYER_LEVEL_UP`**: stale. `OnPlayerLevelUp` passes the event's level.
- **Treating a secret mouseover or unit as readable (Forever, combat)**: errors or wrong ranks. `HasMouseover` counts a secret identity as gone; `RankFor` falls back to the top rank.
- **Parenting a frame to a Blizzard panel**: it stays protected for good. Every launcher hangs off `UIParent` and is only anchored to the book.
- **Probing another add-on's frame in `Spellbook-Tabs.lua`**: anchoring may be restricted or values secret. `ScreenRect` guards with `IsAnchoringRestricted`, `pcall`, `ns.IsSecretValue`.
- **Looking up a slot spell by name**: ranks share a name. `ns.ConditionalPickOfSpell` goes by ID.

### Mini-map, Options and Diagnostics

- **Editing `Options/Options-Kit.lua` or `Features/Menu-Kit.lua` in place**: both headers say copied unchanged from Common-Core and checked byte for byte by CI. Change the shared source and sync. Their comments are generic and partly not this add-on's (the Options Kit places `ns.FEATURES` in `Options-Utilities.lua`, it is in `Options-Feature-Switches.lua`; the Menu Kit names another add-on's plate and describes `Kit.CreateMenu` publishing `ns.ShowMenu`, which Good to Go's menu doesn't use); leave them.
- **Two `Kit`s**: in `Minimap-Menu.lua` and the Buff Duty / Spellbook menu files, `Kit` is `ns.MenuKit`; the options kit is reached as `ns.OptionsKit`. In `Options/`, `Kit` is the options kit.
- **Touching other files' `ns` fields at load in `Minimap-Menu.lua` or `Minimap-Button.lua`**: `Minimap-Menu.lua` loads right after `Menu-Kit.lua`, before every feature folder and the Options group; `ns.OptionsKit`, `ns.FEATURES`, `ns.FindFeature`, the Buff Duty menu functions and the feature setters are nil then. All are read at draw and click time.
- **A new `Kit.CreateMenu` without `publish = false`**: the first such menu becomes `Kit.mainMenu` and overwrites `ns.ShowMenu`, `ns.HideMenu`, `ns.RefreshMenu`, `ns.IsMenuShown`, `ns.IsMenuFrame`, `ns.OpenFlyout`, which `Minimap-Menu.lua` defines for the mini-map menu.
- **Setting `opensOptions` or `click` on an `ns.FEATURES` record**: the kit's record shape lists them, but Good to Go's own `MoreFeatures` / `FLYOUTS.features` honor only `block` and `gate`; nothing reads them.
- **Writing a setting without `ns.RefreshSettings`**: its other home (menu or panel) and the icon go stale. The menu's `AfterChange` covers its own rows; any other writer must call it.
- **A feature whose switch needs side effects but has no `apply`**: the kit and the menu then just write the value (fine for Ability Alerts, read per ding); events would never subscribe.
- **Setting `block = true` without writing a block**: the feature vanishes from the menu, since `block` only removes it from More Features.
- **Reordering `ns.FEATURES` alone**: the settings tree follows the hand-written `Kit.RegisterPanel` order in `ns.RegisterOptionsPanels`, so the two drift. Rank Watch's and Ability Alerts' `table.insert` indices are literals too.
- **Giving a main-menu row `click = "LeftButton"`**: `ns.RunButtonClick` runs first, so that row would take Left-Click from the menu's open, hold and close. Only Right-Click has a job, and only main-menu rows are searched, so a `click` on a flyout row does nothing.
- **Reading Buff Duty's menu status from the global switch**: the menu reads `ns.IsBuffDutyOnForClass`, which includes a close for this session, and shows that close as Paused (`ns.IsBuffDutyHiddenThisSession`); the same Toggle turns it back on.
- **Closing the Buff Duty menu from the mini-map menu with `ns.HideBuffDutyOptions()`**: without `within` it also closes the one a Buff Duty window line opened. The mini-map menu passes itself.
- **Dropping `ns.IsCursorOverBuffDutyOptions` from the menu's `OnUpdate`**: the Buff Duty menu is its own frame on `UIParent`, not a child of the mini-map menu, so the mini-map menu would close under the cursor while it's used.
- **Treating the Enhanced Spellbook as a More Features row**: it has its own block, though its record has no `block`; `SPELLBOOK_SETTING` keeps it out of More Features. Its Toggle goes through `FlipFeature` so turning it off still asks.
- **An uncached item row on the mini-map menu**: the kit's `GET_ITEM_INFO_RECEIVED` watcher refreshes only `Kit.CreateMenu` menus. The mini-map menu redraws once after `LOADING_RETRY`, and only when a builder returns loading (`AddRestockOrders`, `AddIgnoreList`).
- **Capturing `ns.db.profile` (or any settings table) in a panel**: a profile switch replaces it. Kit getters resolve store + path on every read.
- **Using `ns.WarmItemCache` in an options panel, or `Kit.WarmItems` in a window**: panels poll by registry name and repaint through `NotifyChange`; windows hold a `GET_ITEM_INFO_RECEIVED` waiter and remember failed IDs (`failedItemIDs`, `Features/Item-Info.lua`).
- **Fitting the mini-map icon with `SetButtonIcon`**: its `ResetButtonIcon` calls `icon:UpdateCoord()`, which errors when another add-on swapped the icon. `ns.RegisterMinimapIcon` sizes and masks it by hand.
- **Setting the button's texture directly**: displays redraw from the data object's `icon`; `ns.UpdateMinimapIcon` writes only that.
- **Loading a `Manifests-*.lua` after `Report-Runner.lua`, or appending data sources at runtime**: the Data tab's reports are built from `ns.DIAGNOSTIC_DATA_SOURCES` once, at load; late rows get no report.
- **Two different data files sharing a manifest label**: `ns.AppendDiagnosticRows` merges them into one report. Only Game-IDs does it deliberately.
- **Two features adding the same API check label**: the second is dropped silently, so one row must cover both callers' guard.
- **Localizing a Diagnostics string**: they stay plain English in `ns.DiagnosticsStrings`, never in `Locales/`.
- **A fixed anchor (`ANCHOR_RIGHT`, `ANCHOR_TOP`) on the add-on's own widget tooltips**: it runs off the screen's edge and disagrees with the menus. `ns.SetTooltipOwner` (`Features/Utilities.lua`) opens left or right and up or down by the same screen halves Menu-Kit uses.
- **Expecting a Right-Click hint in a menu row's tooltip**: the kit draws a row's kept `click` gray on the row's right (`TEXT.clicks`); its name comes from the `clicks` map handed to `Kit.SetText`.

### Tests and lint

- **A subscription wrapper `Tests/Run.lua` can't see**: its scanner reads only `Set*Event*` / `Set*Handler` call arguments, events-named tables and loops, and `event ==` comparisons. Name new wrappers and tables to match.
- **Editing between `local REALM_KEY_SEPARATOR` and the end of `PruneOtherClientCharacters` in `Core.lua`**: the prune test runs that span in a sandbox with only `type`, `pairs`, `ipairs`, `GetRealmName` and `ns.db`. A helper there that reads another global or `ns` field fails it; moving or renaming either marker breaks the lift.
- **A Camelot-listed file naming the combat log**: the test passes the whole file if the literal `ns.FLAVOR ~= "Camelot"` appears anywhere in it, so the guard must actually sit on the subscription.
- **Moving `PET_BAR_UPDATE` out of `Spellbook-Core.lua`'s map**: the scanner's reach check looks for it there.
- **Using a WoW API or global `.luacheckrc` doesn't list**: CI's luacheck fails. WoW names go in `read_globals`; the add-on's own globals, `SlashCmdList` and `StaticPopupDialogs` fields in `globals`. The shared Kits carry inline `-- luacheck:` lines instead.
