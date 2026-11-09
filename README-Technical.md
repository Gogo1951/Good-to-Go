# Good to Go // Technical Reference

> Code map for working on Good to Go: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/Good-to-Go/blob/main/README.md).

## File Map

```
Good-to-Go/
├── .gitattributes                                  Shared from Common-Core
├── .github/                                        Issue forms and the Common-Core callers
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml                              Kept per add-on: blank-issue, Discord and CurseForge links
│   │   ├── defect.yml                              Shared from Common-Core: the Defect form
│   │   └── request.yml                             Shared from Common-Core: the Request form
│   └── workflows/
│       ├── ci.yml                                  Calls Common-Core: shared files, LF, externals, luac, luacheck, StyLua
│       ├── issue-labels.yml                        Calls Common-Core: labels a new Defect by its Issue Type
│       └── package.yml                             Calls Common-Core: library refresh, then the CurseForge and Wago release
├── .gitignore                                      Shared from Common-Core
├── .luacheckrc                                     Lint config: WoW read globals, the add-on's globals, slash commands, popups
├── .pkgmeta                                        Externals; ignore list keeps READMEs, Tools, Data/Wrath, Data/Mainline out of the zip
├── Bindings.xml                                    Spellbook toggle, Buff Key CLICK binding, hidden migration binding
├── Data/                                           Static game data and ID-free constants
│   ├── Camelot/                                    WoW Forever's tables
│   ├── Data.lua                                    Names, replaced and legacy lists, palette, ceilings, registry, macro config, Staples rows, ns.Data
│   ├── Default-Settings.lua                        ns.DATABASE_DEFAULTS with scope reasons; AddDefaults blocks per feature
│   ├── Discovery/                                  Season of Discovery's tables, guarded opposite to Data/Vanilla/
│   ├── Flavor.lua                                  ns.FLAVOR from the TOC, ns.EXPANSION, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── LICENSE-Pet-Data                            MIT notice for the pet ability and tameable beast rows
│   ├── LICENSE-Trainer-Data                        MIT notice for the trainer spell rows
│   ├── Mainline/                                   Forward-prep; no TOC lists it, .pkgmeta ignores it
│   ├── Mists/                                      Mists of Pandaria Classic's tables
│   ├── TBC/                                        TBC Anniversary's tables
│   ├── Vanilla/                                    Classic Era's tables; each file returns early on Season of Discovery
│   └── Wrath/                                      Forward-prep; no TOC lists it, .pkgmeta ignores it
├── Diagnostics/                                    Copied framework; Manifests.lua plus Manifests-* and Message-Length-* are this add-on's part
├── Features/                                       One folder per feature; Core.lua owns the event frame
│   ├── Announcements.lua                           Prints, the sent format, whisper queue, buff ask builder, FormatDuration
│   ├── Buff-Duty/                                  Click-to-cast window of buffs you can give, and the Buff Key
│   │   ├── Buff-Duty-Auras.lua                     GUID aura cache, dirty set and generation, strengths, bounce memory, Has
│   │   ├── Buff-Duty-Button-Attributes.lua         ns.SetBuffButtonAttributes, shared by the window and the Buff Key
│   │   ├── Buff-Duty-Cast-Results.lua              Aura-bounced refusals; the Forever resurrection note
│   │   ├── Buff-Duty-Castable.lua                  Creates ns.BuffDuty; BuildBuffs, RankFor, HasAnythingToOffer
│   │   ├── Buff-Duty-Events.lua                    Event module, ns.SetBuffDutyEventHandler, subscriptions, safety pause; loads first
│   │   ├── Buff-Duty-Favors.lua                    Return the Favor memory; combat-log and Forever aura detection
│   │   ├── Buff-Duty-Frame.lua                     Anchor and content frames, secure icon pool, grids, signature, Hide in Combat
│   │   ├── Buff-Duty-Groups.lua                    Party sections, group icons, member and pet rows
│   │   ├── Buff-Duty-Icon-State.lua                Icon pool table, swipes and time-left sliver, range ticker, stale dim
│   │   ├── Buff-Duty-Key-Picker.lua                What the Buff Key casts next
│   │   ├── Buff-Duty-Keys.lua                      GtGBuffKey button, skip memory, press reuse, binding migrations
│   │   ├── Buff-Duty-Lookups.lua                   Data rows to live entries, weapon layers, BuildCategories
│   │   ├── Buff-Duty-Other-Classes.lua             Party-Buffs counts, ask cooldowns, ask and whisper senders
│   │   ├── Buff-Duty-Outsiders.lua                 Target and Return the Favor sections
│   │   ├── Buff-Duty-Party-Buffs.lua               Party-Buffs plain icons and their hover menu
│   │   ├── Buff-Duty-Pets.lua                      Pet rows, owner class, charmed and phase-shift checks
│   │   ├── Buff-Duty-Position.lua                  Position saved by the top-right corner, and its migration
│   │   ├── Buff-Duty-Resurrections.lua             Resurrection icon and pending suppression
│   │   ├── Buff-Duty-Self.lua                      Self Buffs section and the Soulstone icon
│   │   ├── Buff-Duty-Settings.lua                  Seeds and cleans audience, selfRefresh, tankWhen, weapon choices; migrations
│   │   ├── Buff-Duty-Units.lua                     Who can be buffed, roles, range, labels, SingleIcon
│   │   ├── Buff-Duty-Weapons.lua                   Enchant reads, layers, imbue landing, weapon rows, REPLACE_ENCHANT accept
│   │   └── Buff-Duty.lua                           Refresh, ShowsHere, debounce, backstop, per-class switch, setup
│   ├── Core.lua                                    ns.EVENT_NAMES, the one event frame, replaced and legacy add-ons, database init, prunes, ApplyProfile, welcome
│   ├── Enhanced-Spellbook/                         Own spellbook window, a macro per spell, What's Next
│   │   ├── Action-Bars.lua                         Action-bar scan for glows and bar counts
│   │   ├── Category-Menu.lua                       Category gear menu, applied to every macro under it
│   │   ├── Class-Config.lua                        Empties other classes' data; resolves class lists; PAGE_TAGS
│   │   ├── Class-Spells.lua                        ns.ForEachClassSpell across both book engines
│   │   ├── Consumable-Macros.lua                   Read-only Consumable Macros tiles on the page
│   │   ├── Dynamic-Rank.lua                        Target and mouseover rank rewrites, mouseover poll, pre-combat rewrite
│   │   ├── Group-Handover.lua                      A learned successor takes a replaced spell's macro
│   │   ├── Grouped-Spells.lua                      ns.SPELL_GROUPS ticks
│   │   ├── Key-Bindings.lua                        GoodToGo_ToggleSpellbook and the binding migration
│   │   ├── LICENSE-Enhanced-Spellbook              MIT notice shipped with the folder
│   │   ├── Macro-Body.lua                          Macro text: CastBody, RankFor, stance line, MacroBody
│   │   ├── Macro-Builder/                          ns.macros builder, Conditionals, Cast Sequence, docked panels
│   │   │   ├── Cast-Sequence-Panel.lua             Cast Sequence panel
│   │   │   ├── Cast-Sequence.lua                   Steps, resets, tail text
│   │   │   ├── Conditionals-Panel.lua              Conditionals panel
│   │   │   ├── Conditionals-Rows.lua               Conditionals rows and condition menus
│   │   │   ├── Conditionals.lua                    ns.CONDITIONS, row data, clauses
│   │   │   ├── Docked-Panel.lua                    Shared panel shell and byte meter
│   │   │   ├── Macro-Builder.lua                   ns.CollectMacros: focus, copy and rank macros, folds
│   │   │   ├── Panel-Widgets.lua                   Controls the docked panels share
│   │   │   └── Spell-Pick.lua                      Spell pick mode and cursor drops
│   │   ├── Macro-Button-Notes.lua                  Tile notes and tooltip wording
│   │   ├── Macro-Button.lua                        A macro tile: click, drag, tooltip, glow
│   │   ├── Macro-Copies.lua                        Duplicates, COPIED_SETTINGS, resets, settings handover
│   │   ├── Macro-Delete.lua                        Delete one or all; remove a focus copy
│   │   ├── Macro-Kinds.lua                         ns.MACRO_KINDS, ns.MacroKind, ns.DEFAULTABLE_OPTIONS
│   │   ├── Macro-Lookup.lua                        Slot limits, FindMacroIndex, ownership, legacy names
│   │   ├── Macro-Menu-Sections.lua                 Right-click menu sections
│   │   ├── Macro-Menu-Utilities.lua                Menu helpers, Make Default, rebuilt-macro lookup
│   │   ├── Macro-Menu.lua                          A macro's right-click menu
│   │   ├── Macro-Options.lua                       Settings keys, OFFERED predicates, option get and set
│   │   ├── Macro-Sync.lua                          SyncMacro and SyncAt, PickupMacro, 255 guard, combat queue, Macro UI wait
│   │   ├── Macro-Tags.lua                          Tag line, tag register, MacroOwnerKey, MacroIdentity
│   │   ├── Menu-Utilities.lua                      Menu pieces shared with the category menu
│   │   ├── Mute-Errors.lua                         Global GtGMute
│   │   ├── Page-Categories.lua                     ns.PAGE_CATEGORIES and the category mapping
│   │   ├── Page-Settings.lua                       Page toggles, sort, Mark All Placed
│   │   ├── Ranged-Attacks.lua                      Folds the ranged attacks into one Shoot macro
│   │   ├── Spell-Ranks-Tooltip.lua                 Rank lines under every spell tooltip, and their cache
│   │   ├── Spell-Ranks.lua                         The character's trainer rows, learn levels, ReadSpellbook
│   │   ├── Spellbook-Controls.lua                  Controls row, settings menu, legend, slot counts
│   │   ├── Spellbook-Core.lua                      Master switch, event module and handler map, login migrations
│   │   ├── Spellbook-Events.lua                    RefreshOpenPages, RefreshMacros, next-frame coalesced handlers
│   │   ├── Spellbook-Host-Classic.lua              Vanilla, TBC and Mists: launcher tab on SpellBookFrame
│   │   ├── Spellbook-Host-Modern.lua               Camelot only: registers the launcher tab
│   │   ├── Spellbook-Page-Layout.lua               Row packing and pagination
│   │   ├── Spellbook-Page-Order.lua                Sort order, filters, category grouping
│   │   ├── Spellbook-Page-Parchment.lua            Parchment art
│   │   ├── Spellbook-Page.lua                      The Spell Book page: collect, sync, draw
│   │   ├── Spellbook-Paging.lua                    Custom page strip
│   │   ├── Spellbook-Tabs.lua                      Camelot only: side tabs on PlayerSpellsFrame
│   │   ├── Spellbook-Utilities.lua                 HAS_SPELL_RANKS, ns.SpellName, TrimMacroName, frame pool, gear button
│   │   ├── Spellbook-Widgets.lua                   Filter box, dropdown, menu tooltip, ElvUI skin
│   │   ├── Spellbook-Window.lua                    GoodToGoSpellbookFrame, tabs, fit-to-screen, docking
│   │   ├── Target-Priority.lua                     The target-priority option
│   │   ├── Trainer-Lookup.lua                      A trainer service's spell ID
│   │   ├── Trainer-Recording.lua                   Records class trainer services into the profile
│   │   ├── Unlearned-Spells.lua                    ns.ForEachUnlearnedSpell
│   │   ├── Usable-Items.lua                        Equipped Use: items
│   │   └── Whats-Next/                             What's Next, Pet What's Next and Pet Spell Book tabs
│   │       ├── Pet-Spellbook.lua                   Pet spellbook rows and its class gate
│   │       ├── Whats-Next-Controls.lua             Controls row and footer
│   │       ├── Whats-Next-Layout.lua               Sections and pagination
│   │       ├── Whats-Next-Models.lua               The three page models; beast list in tooltips
│   │       ├── Whats-Next-Page.lua                 Shared page builder
│   │       ├── Whats-Next-Pet.lua                  Pet and demon ability rows
│   │       └── Whats-Next.lua                      Class rows, sources, statuses
│   ├── Inventory-Report/                           Every character's bags and bank in item tooltips
│   │   ├── Inventory-Report-Recording.lua          Snapshots and packed format; handlers run by the Restocker module
│   │   └── Inventory-Report-Tooltip.lua            Tooltip block and its delayed hook
│   ├── Item-Info.lua                               Session item memo, remembered misses, GET_ITEM_INFO_RECEIVED waiters, hand-built links
│   ├── Key-Bindings.lua                            Binding header, ns:OpenKeyBindings, General panel binding repaint
│   ├── Macros-for-Consumables/                     The consumable macros: scan, rank, compose, write
│   │   ├── Action-Button-Text.lua                  Macro-name text on action buttons, by font-string alpha
│   │   ├── Character-Key-Migration.lua             MIGRATION only: Forever characters re-keyed by whole name
│   │   ├── Default-Profile-Migration.lua           MIGRATION only: characters moved off Default; list choices carried
│   │   ├── Ignore-List.lua                         Character and Global Ignore Lists, logout prune
│   │   ├── Item-Cache.lua                          Session-only consumable records, CONSUMABLE_TABLES, cold retry budget
│   │   ├── Macros/                                 Definition protocol, engine, writer, one file per macro
│   │   │   ├── Bandage.lua
│   │   │   ├── Body-Builder.lua                    Standard body, OOC block, byte trims, ns.BuildStateKey
│   │   │   ├── Definitions.lua                     Definition protocol and ns.RegisterMacroType
│   │   │   ├── Engine.lua                          ns.UpdateMacros, Macro UI deferral, ns.ResetMacroState
│   │   │   ├── Explosive.lua                       At-player or toss click layout
│   │   │   ├── Food.lua                            Buff food, pet-buff override, scroll mode, Stealth Eating
│   │   │   ├── Health-Potion.lua                   Ranked, healthstone stacking, OOC food
│   │   │   ├── Healthstone.lua
│   │   │   ├── Integration-Druid-Macro-Helper.lua  DruidMacroHelper-wrapped potion and healthstone bodies
│   │   │   ├── Mana-Gem.lua                        Optional mana runes
│   │   │   ├── Mana-Potion.lua                     Ranked, OOC water
│   │   │   ├── Runtime.lua                         GtG* macro globals, wrong-zone bug report, Connoisseur aliases
│   │   │   ├── Signatures.lua                      Friendly-target test; target and group signatures
│   │   │   ├── Smart-Spell.lua                     Conjure rank pick
│   │   │   ├── Soulstone.lua
│   │   │   ├── Tools-Forsaken.lua                  Cannibalize lines; shared racial cooldown timer
│   │   │   ├── Tools-Hunters-Pet-Food.lua          Pet food pick, quest signature, pet-buff override
│   │   │   ├── Tools-Hunters.lua                   Feed Pet macro tiers, dead-pet detection
│   │   │   ├── Tools-Mages.lua                     Mage conjure resolvers
│   │   │   ├── Tools-Rogues.lua                    The Poisons macro
│   │   │   ├── Tools-Troll.lua                     Rapid Regeneration lead cast
│   │   │   ├── Tools-Warlocks.lua                  Healthstone and Soulstone resolvers
│   │   │   ├── Water.lua                           Shadowmeld drinking
│   │   │   └── Writer.lua                          ns.WriteMacroBody, ns.TryCreateMacro, delete
│   │   ├── Macros-for-Consumables-Core.lua         Event module, two-flag throttle, combat-guard ordering, profile re-apply
│   │   ├── Macros-for-Consumables-Utilities.lua    Mode test, max level, Well Fed and First Aid names
│   │   └── Scanner/                                Bag scan, auras, ranking ladder
│   │       ├── Scanner-Auras.lua                   Shared aura snapshot, early re-application, baselines, UNIT_AURA
│   │       ├── Scanner-Character.lua               Class and race flags, spell names, profession ranks
│   │       ├── Scanner-Diagnostics.lua             Selection candidates, kept only while Diagnostics is on
│   │       ├── Scanner-Inventory.lua               ns.ScanBags: bag walk, usability gates, dispatch
│   │       ├── Scanner-Ranking.lua                 RANKING_PRIORITY, winners, ranked lists
│   │       └── Scanner-Scrolls.lua                 Best scroll per type; scroll overrides
│   ├── Minimap-Button.lua                          The one LDB object and button, click actions, tooltip blocks
│   ├── Rank-Watch/                                 Low ranks cast in the group; no Mists TOC loads it
│   │   ├── LICENSE-Rank-Watch                      MIT notice for Rank Sentinel
│   │   ├── Rank-Watch-Check.lua                    The low-rank check, messages, whisper queue, opt-out codes
│   │   ├── Rank-Watch-Cluster.lua                  RANKSENTINEL leader election and NOTIFY sharing
│   │   ├── Rank-Watch-Core.lua                     Event module, switch, standalone add-on handling, ignore command, reset listener
│   │   ├── Rank-Watch-Detection-Combat-Log.lua     Vanilla and TBC TOCs: combat-log detection
│   │   ├── Rank-Watch-Detection-Forever.lua        Camelot TOC: cast handshake, pet, auras, damage meter
│   │   └── Rank-Watch-Lookups.lua                  Ladders joined by ns.SPELL_GROUPS, tracked state, rank text
│   ├── Readiness-Report/                           The private report printed on a ready check
│   │   ├── Readiness-Report-Example.lua            The panel's sample lines
│   │   ├── Readiness-Report-Probes.lua             Stateless live reads
│   │   └── Readiness-Report.lua                    Line assembly and the READY_CHECK module
│   ├── Restocker/                                  Restock Lists, merchant buying, bank restocking, reminders, upgrades, Staples
│   │   ├── Restocker-Bags.lua                      Bag and bank container lists, slot scans, empty-slot placement
│   │   ├── Restocker-Bank-Moves.lua                Single bank and bag moves, overshoot pull, BankHasRestockSpace
│   │   ├── Restocker-Bank-State.lua                Run state, bank open and close, visit flags
│   │   ├── Restocker-Bank-Tidy.lua                 Partial-stack count and one-merge consolidation
│   │   ├── Restocker-Bank-Visit.lua                Run coroutine, watchdogs, in-flight and lock gates, ping-paced OnUpdate
│   │   ├── Restocker-Core.lua                      Login setup, logout packing, master switch
│   │   ├── Restocker-Crafting-Reagents.lua         Poison recipe index and the reagent order
│   │   ├── Restocker-Events.lua                    Handler table, WhileEnabled, module dispatcher (Inventory Report's too)
│   │   ├── Restocker-Inventory-Model.lua           The summary and slots model a scan returns
│   │   ├── Restocker-List.lua                      Add, remove, undo, New flags, cold-item queues
│   │   ├── Restocker-Merchant.lua                  Purchase orders, reagent gate, buy loop, delivery report
│   │   ├── Restocker-Purchase-Space.lua            The bag-space budget a merchant run spends down
│   │   ├── Restocker-Reminders.lua                 Reminder lines and the in-town arrival reminder
│   │   ├── Restocker-Saved-Format.lua              One-line row codec, inflated at login, packed at logout
│   │   ├── Restocker-Saved-Lists.lua               Named lists and each character's choice
│   │   ├── Restocker-Shortfall.lua                 BuildGroceryList, shortfall marks, after-visit reminder
│   │   ├── Restocker-Slash-Command.lua             The /restock parser
│   │   ├── Restocker-Starter-List.lua              Staples logic: rows, ticks, stacks, login trigger
│   │   ├── Restocker-Starter-Window.lua            The Staples window
│   │   ├── Restocker-Trace.lua                     ns.RestockerDebug into the Event Log
│   │   ├── Restocker-Upgrade.lua                   Level-ladder upgrades
│   │   ├── Restocker-Window-Bag-Menu.lua           Add Item From Bags menu
│   │   ├── Restocker-Window-Categories.lua         Item-type pane
│   │   ├── Restocker-Window-Column-Header.lua      Column captions and bands
│   │   ├── Restocker-Window-Columns.lua            COLUMNS, measured widths, layout walk
│   │   ├── Restocker-Window-Filter.lua             View building, groups, filter, sort; pure data
│   │   ├── Restocker-Window-Footer.lua             Orders status and the undo offer
│   │   ├── Restocker-Window-Frame.lua              Portrait frame shared with Staples, bands, ElvUI skin
│   │   ├── Restocker-Window-Header.lua             Filter, add box, Pick Staples
│   │   ├── Restocker-Window-List-Bar.lua           List selector, Manage Lists, Used by, rename
│   │   ├── Restocker-Window-Menus.lua              Reputation and column menus (AceGUI)
│   │   ├── Restocker-Window-Render.lua             ns.UpdateRestockList redraw, shortfall and cold-row repaints
│   │   ├── Restocker-Window-Reputation.lua         Standing labels and discount text
│   │   ├── Restocker-Window-Rows.lua               Pooled rows: Keep box, toggle cells, remove
│   │   ├── Restocker-Window-Widgets.lua            CloseRestockMenus, cursor drop-add, tooltips
│   │   └── Restocker-Window.lua                    Window build, geometry, show, hide, toggle
│   └── Utilities.lua                               Colors, client-difference accessors, secret-value tests, character names and keys, spell links
├── Good-to-Go_Camelot.toc                          WoW Forever
├── Good-to-Go_Mists.toc                            Mists of Pandaria Classic
├── Good-to-Go_TBC.toc                              TBC Anniversary
├── Good-to-Go_Vanilla.toc                          Classic Era, Season of Discovery included
├── Includes/
│   ├── Images/                                     Icon and window art
│   ├── Libraries/                                  Vendored libraries, refreshed from .pkgmeta at release
│   └── Sounds/                                     Low-Battery.ogg, the Restocker reminder
├── LICENSE                                         MIT
├── Locales/                                        AceLocale strings; enUS.lua is the source of truth
├── Options/                                        AceConfig panels, one folder per feature
│   ├── Buff-Duty/                                  Buff Duty panel and its Tracked Abilities, Self-Buffs and Weapon Buffs sub-panels
│   ├── Enhanced-Spellbook/                         Switch, tooltip ranks, Delete Macros
│   ├── Inventory-Report/                           Switch and Recorded Characters
│   ├── Macros-for-Consumables/                     Consumable Macros, Class & Race, Ignore List
│   ├── Options-Feedback-Support.lua                Level Up note, links, version line
│   ├── Options-General.lua                         Root panel: welcome, mini-map, feature switches, key bindings, /Commands
│   ├── Options-Profiles.lua                        Stock AceDBOptions table with the migration's noDefaultProfiles
│   ├── Options-Utilities.lua                       Row builders, FEATURE_SWITCHES, item lists, item-cache warming, custom widgets
│   ├── Options.lua                                 Registration and tree order, ns:OpenOptionsPanel and its combat guard, slash commands
│   ├── Rank-Watch/                                 Rank Watch, Tracked Abilities and Ignored Players; no Mists TOC loads it
│   ├── Readiness-Report/                           Readiness switches built from SECTIONS; Reset
│   └── Restocker/                                  Switch, Gold Reserve, reminders, auto-open toggles
├── README-Notes.md                                 Where Good to Go departs from the Style Guide
├── README-Technical.md                             This document
├── README-Testing.md                               Manual test plan
├── README.md                                       Player documentation
└── Tools/                                          Rank Watch data builders; .pkgmeta keeps them out of the zip
    ├── Build-Rank-Watch-Abilities.py               Merges Rank Sentinel onto Rank-Watch-Abilities-{Game}.lua; the file's rows win
    └── Build-Rank-Watch-Pet-Abilities.py           Writes Rank-Watch-Pet-Abilities-{Game}.lua; Camelot only with --wago
```

## Architecture

### Flavors and Load Order

- **TOC order** (all four): libraries, `Locales/` (enUS first), `Data/Flavor.lua`, `Data/Data.lua`, the flavor's `Data/{Game}/` files, `Data/Default-Settings.lua` (reads those tables), `Features/Core.lua`, `Utilities.lua`, `Announcements.lua`, `Key-Bindings.lua`, `Item-Info.lua`, the feature folders, `Minimap-Button.lua`, `Diagnostics/`, `Options/` with `Options/Options.lua` last.
- **`ns.FLAVOR` comes from the TOC's `## X-Flavor`**, never the client: Forever's `WOW_PROJECT_ID` has changed value once already. `ns.EXPANSION` maps it in `Data/Flavor.lua`; `ns.IS_DISCOVERY` is Vanilla plus an active season; `ns.DATA_FOLDER` names the folder that built the tables.
- **Seven flavor folders, one complete copy each.** All carry the same files, and an empty table stands in where a flavor has no rows, so feature code never asks which flavor built a table. The Vanilla TOC lists `Data/Vanilla/` then `Data/Discovery/`. The Vanilla files open with `if ns.IS_DISCOVERY then return end` and the Discovery files with the opposite, so only one set builds. `Data/Wrath/` and `Data/Mainline/` are forward-prep: no TOC lists them.
- **How the TOCs differ** besides the data folder:
  - Camelot loads `Rank-Watch-Detection-Forever.lua` where Vanilla and TBC load `Rank-Watch-Detection-Combat-Log.lua`.
  - Camelot loads `Spellbook-Tabs.lua` and `Spellbook-Host-Modern.lua` where the others load `Spellbook-Host-Classic.lua`.
  - Mists loads no `Features/Rank-Watch/` or `Options/Rank-Watch/` file. It still loads the Rank Watch data and diagnostics files, which test that the functions exist before calling them.
- **Names.** The folder, `ADDON_NAME` and the AceLocale name are `Good-to-Go`. The saved table is `ns.SAVED_VARIABLES_NAME`, and `ns.OLD_SAVED_VARIABLES_NAME` is the table from before the rename. Frames, bindings and popups carry `GoodToGo`. Anything a macro body calls carries the shorter `GtG`, since every byte counts against the 255-byte ceiling.
- **`ns.Version`** comes from TOC metadata and reads `"Dev"` while it still holds `@project-version@`.
- **Two homes for constants.** Buff Duty and Rank Watch constants sit on `ns.Data` (`Data.SAFETY_PAUSE`, `Data.RANK_WATCH`, `Data.WEAPON_LAYERS`). Everything else sits directly on `ns`.

### Event Loop

- **One frame for the whole add-on** (`Features/Core.lua`), so the Diagnostics Event Log taps every event in one place (`ns:LogEvent`, gated on `ns.diagnostics.logging`).
- **`ns.EVENT_NAMES`** is the one list. The dispatcher and Diagnostics' Event Registration report both read it. `COMBAT_LOG_EVENT_UNFILTERED` is appended only when `ns.FLAVOR ~= "Camelot"`.
- **Event modules.** Each feature calls `ns.RegisterEventModule(name, dispatch)` and subscribes with `ns.SetModuleEvent(name, event, on, ...units)`.
  - `SetModuleEvent` asserts that the event is known and the module exists, so a typo stops the load.
  - `RefreshRegistration` registers each event once while any module wants it. It uses `RegisterUnitEvent` only while every subscriber filters to the same two units or fewer; otherwise the dispatch loop filters on the first argument.
  - Modules hear an event in load order: `KeyBindings`, `ItemInfo`, `ConsumableMacros`, `ReadinessReport`, `Restocker`, `RankWatch` (not on Mists), `BuffDuty`, `Spellbook`.
- **Features subscribe only while on.** Each master switch subscribes and releases its own events.
- **Handler tables behind modules.** Several features keep one handler per event behind their module: `ns.SetBuffDutyEventHandler`, `ns.SetRankWatchHandler`, `ns.restockerEventHandlers`, and the Spellbook's `EVENT_HANDLERS` map of `ns:On<X>` names, resolved when the event fires. A second registration silently replaces the first.
- **Core's own events.** `CORE_EVENTS` stay registered and Core handles them before any module:
  1. `PLAYER_LOGIN`: `TurnOffReplacedAddons`, `InitializeDatabase`, `ns.RegisterOptionsPanels`, `ns.RegisterMinimapIcon`. None of it is protected, so a login mid-combat still runs it.
  2. `PLAYER_ENTERING_WORLD`: `ns:PrintWelcome` once a session, then the legacy or replaced-add-on popups.
  3. `PLAYER_LOGOUT`: `SaveProfileChoiceWhenUnnamed`.
- **Pacing by feature:**

| Feature | Pacing |
|---|---|
| Consumable Macros | Two flags (`isUpdatePending`, `isTickScheduled`) on an OnUpdate tick, `UPDATE_THROTTLE` after the first request of a burst; not debounced to the last |
| Buff Duty | One-flag `REFRESH_DELAY` timer every trigger funnels through; `BACKSTOP_INTERVAL` ticker for expiry, deaths and disconnects; `RANGE_INTERVAL` alpha ticker; `Data.SAFETY_PAUSE` after every loading screen |
| Enhanced Spellbook | Next-frame coalescing behind one pending flag per kind of work (`Spellbook-Events.lua`); `MOUSEOVER_POLL_SECONDS` poll for Dynamic Rank |
| Restocker | None per event; a 1 s literal guard against a doubled `MERCHANT_SHOW`; a ping-paced OnUpdate for the bank run |
| Rank Watch (Forever) | `METER_POLL` damage-meter poll out of combat and after it |

### Combat Lockdown

- **Refuse, never queue.** `ns:OpenOptionsPanel` is the one gate for `/gtg`, `/restock config` and Shift + Middle-Click. `ns:OpenKeyBindings` refuses the same way with `CHAT_KEY_BINDINGS_IN_COMBAT`.
- **Consumable Macros defer.**
  - `ns.UpdateMacros` in combat calls `ns.RequestUpdate` and returns. An armed tick that finds combat disarms itself, and events below `OnEvent`'s combat guard only set pending.
  - `PLAYER_REGEN_ENABLED` re-reads anything put off (`ns.RereadProfessionSkillsIfPending`, `ns.RereadTargetIfPending`), then re-requests.
  - A forced rebuild keeps its force across the wait, because `UpdateMacros(true)` wipes the state keys before the combat check.
  - Some handlers sit above the guard on purpose (signatures, baselines, `PLAYER_LEVEL_UP`, logout), so a value that changes and changes back mid-fight still reads as changed afterward.
- **The Enhanced Spellbook defers syncs and refuses actions.**
  - `ns.SyncAllMacros` in combat calls `ns.QueueMacroSync`; `ns:OnPlayerRegenEnabled` (`Macro-Sync.lua`) runs `RefreshMacros`.
  - `ns.PickupMacro`, the three deletes and `ns.StartSpellPick` refuse with `ERR_NOT_IN_COMBAT`.
  - Dynamic Rank, tooltip ranks, `CloseGameSpellbook` and the binding migration skip silently.
  - `PLAYER_REGEN_DISABLED` runs `ns.RewriteRanksBeforeCombat`, the last moment Dynamic Rank macros can change, and cancels spell pick.
- **Buff Duty's buttons are secure.**
  - Refresh, render, hide, the settings apply and drag-start all refuse. A settings change queues behind `settingsPending`.
  - A roster or target change mid-fight dims icons (`ns.MarkBuffDutyRosterStale`, `OUT_OF_RANGE_ALPHA`). Only alpha and the `CooldownFrameTemplate` children change in combat.
  - `PLAYER_REGEN_ENABLED` applies pending settings, prunes the aura cache, marks every aura dirty and refreshes.
  - Hide in Combat is a state driver (`[combat] hide; show`) on the anchor frame, so the client hides it without the add-on touching a protected frame.
- **The Inventory Report defers one scan:** `bagsChangedInCombat`, rescanned on `PLAYER_REGEN_ENABLED`.
- **The Restocker has no combat guard.** Nothing it does is protected, a merchant or bank window can't open in combat, and a logout mid-combat must still pack the lists. The Staples login trigger skips a login that lands in combat.
- **Skipped and retried at next login:** `RetireAutomatedAppreciation`'s macro deletes, `ns.MigrateSpellbookBinding`, `ns.MigrateBuffKeys`.

### Item Data Caching

- **Session memo** (`ns.GetItemData`, `Features/Item-Info.lua`). It is keyed by whatever the caller asked with (an ID on hot paths, a link at a merchant) and thrown away at logout.
  - `ns.GetItemHyperlink` builds a white `|Hitem:ID|h[name]|h` link by hand while the item is cold, which the client resolves on hover.
  - `failedItemIDs` (`Options-Utilities.lua`) keeps IDs the server refused, so they are never requested again.
- **Waiters.** `ns.RequestItemInfoEvents(key)` and `ns.ReleaseItemInfoEvents(key)` are keyed, not counted. `GET_ITEM_INFO_RECEIVED` floods at login, so it stays registered only while a waiter exists.
  - Keys: `"scan"` (consumable retry), `"restocker"`, `"options:<registryName>"` through `ns.WarmItemCache`, and the Staples window's own key.
  - Answers fan out in order: `ns.OnRestockerItemInfoReceived`, then `ns.OnOptionsItemInfoReceived`, then `ns.OnConsumableItemInfoReceived`. The last rebuilds only when `ns.HasRawData`.
- **Remembered misses** are kept only for a numeric ID, and only while a waiter listens. The client answers once, so a miss taken while nobody listens would strand the item. The last release wipes them all, and each answer reaches `ns.ForgetItemDataMiss` before anything retries. The comments in `Item-Info.lua` explain why time-scoped misses were rejected.
- **Consumable cache** (`Item-Cache.lua`): a file-local, session-only table holding consumables only. A non-consumable returns `"IGNORE"` with no API call. `CONSUMABLE_TABLES` names each data table and the column where its item facts start. A row without facts falls back to `C_Item.GetItemInfo`. A cold item sets `dataRetry`; `ns.RegisterDataRetry` keys in `"scan"` and retries up to `DATA_RETRY_MAX_ATTEMPTS` (2 s interval, literal). The event outlives the budget so a late answer still rebuilds, and a clean scan refunds the budget.
- **The Restocker** parks adds, upgrades and Staples ticks on cold items rather than writing a row with the wrong name (Restocker below).

### Characters and Profiles

- **AceDB can open the database under a placeholder name.** The newest AceDB among enabled add-ons loads and reads the character's name once, possibly before the client has named the character. `UseOwnProfileWhenUnnamed` moves to the profile saved under the real name at login, and `SaveProfileChoiceWhenUnnamed` saves the choice under the real name at logout and drops the placeholder entry.
- **Copied-WTF characters are pruned** right after `AceDB:New` (`PruneOtherClientCharacters`, with `PruneOtherClientGlobals` for `restocker.listChoices` and Inventory Report records). The rule is a key's shape: `" - "` on realm clients, `"First Last"` on Forever. On Forever an older AceDB's `First - RuleSet` key (`Gogodruid - PvE`) is kept until the Default-Profile-Migration shim comes out (`IsOlderForeverKey`, MIGRATION 2026-12-08), so `CarryOlderForeverSettings` can still read it.
- **Two character-key formats, never mixed** (`Features/Utilities.lua`):

| Key | Shape | Readers | Used by |
|---|---|---|---|
| AceDB profile name | `Name - Realm`; `First Last` on Forever | `ns.GetCharacterProfileName`, `ns.ProfileNameForCharacter`, `ns.SplitCharacterProfileName` | `profileKeys`, profiles, `restocker.listChoices`, `ns.MacroOwnerKey` |
| Add-on character key | Whole name, then `-Realm` with spaces closed up | `ns.GetCharacterKey` | `global.inventory`, Diagnostics, the Forever re-key migration |

- `ns.GetPlayerFullName` reads `UnitNameUnmodified`, adds the surname with `CHARACTERNAME_SURNAME_SEPARATOR`, and never doubles one already present, so two Forever characters sharing a first name never share an entry.
- **Every profile change re-applies.** `ns:ApplyProfile` runs on `OnProfileChanged`, `OnProfileReset` and `OnProfileCopied`. It calls `ns.ApplyConsumableMacrosProfile`, `ns.ApplyBuffDutyProfile` and `ns.ApplySpellbookProfile`, then `NotifyChange` for every `ns.OPTIONS_REGISTRY` panel. The callbacks are wired last in `InitializeDatabase`, so the migrations' profile switches fire no handler.

### Replaced and Legacy Add-ons

- **`ns.REPLACED_ADDONS`** (`Data/Data.lua`, Connoisseur & Restocker today) is permanent, not a migration. Any of them running at login is turned off for every character before the database opens (`TurnOffReplacedAddons`), and `GOODTOGO_REPLACED_RELOAD` is offered, since the old copy keeps rewriting the same macros until a reload.
- **`ns.LEGACY_ADDONS`** is a migration: Connoisseur & Restocker, Macro Spellbook, Rank Sentinel.
  - The client loads an add-on's saved variables only while it is on. So a loaded one has its settings copied once through `LEGACY_IMPORTERS`, before AceDB opens: legacy wins key by key, and Restock Lists merge by name.
  - The record is `global.legacyImported[sv]`, either `LEGACY_IMPORT_VERSION` or `"declined"`.
  - An installed-but-off one gets `GOODTOGO_LEGACY_IMPORT`. Accept turns it on and reloads; Decline is saved; Escape (`noCancelOnEscape`) asks again next login. While it is pending, `ns.IsLegacyImportPending()` keeps Staples shut.
  - Macro Spellbook and Rank Sentinel are only turned off here. Rank Watch imports its own settings.
- **Automated Appreciation is retired** (`RetireAutomatedAppreciation`). It nils the old global keys and `legacyImported.TFTBDB`. Out of combat, it deletes the `- Thank` and `- GtG 2..5` macros, but only when a macro's trimmed body is still its own `/thankyou[n]` command and no `SLASH_*` alias claims that command. Thanks for the Buff is its own add-on again: Good to Go never imports it, never turns it off and sends no thank-yous.

### Consumable Macros

**Events** (`Macros-for-Consumables-Core.lua`, module `ConsumableMacros`):

- Plain events subscribe at file load; `UNIT_PET` is filtered to the player. Three subscribe on demand through `ns.SetEventRegistered`:
  - `UNIT_AURA` (player and pet), only while buff food, scrolls or pet buff food is live (`ns.UpdateAuraTracking`).
  - `QUEST_LOG_UPDATE`, Hunters only.
  - `UNIT_SPELLCAST_SUCCEEDED`, decided once at login: Mage, Warlock, Forsaken, or Troll with Rapid Regeneration.
- Busy events diff before requesting: `ns.TargetSignatureChanged`, `ns.GroupSignatureChanged`, `ns.OnUnitAura` (Well Fed, scroll baseline, pet buff), `ns.PetFoodQuestsChanged`.
- `PLAYER_ENTERING_WORLD` re-hides macro names (`ns.ApplyMacroNameVisibility`, alpha only, combat-safe) and requests now and again 3 s later (literal).
- Re-application recheck: one-shot `ScheduleExpiryRecheck` (`Scanner-Auras.lua`). Racial cooldowns rebuild through `ns.RacialSpellReady` (`Tools-Forsaken.lua`, shared with Troll).

**Scan → Rank → Compose → Write** (`ns.UpdateMacros(forced)`, `Macros/Engine.lua`):

1. **Scan** (`ns.ScanBags`, `Scanner/Scanner-Inventory.lua`).
   - Takes one aura snapshot (`ns.UpdateAuraTracking`) and passes it down.
   - Sets the gates `ns.allowBuffFood`, `ns.allowConjuredFirst` and `ns.allowRestockLast`, and captures the Restock List in use.
   - Walks `ns.CARRIED_BAG_IDS` into `ns.scannedItemCounts` and `ns.scannedItemLinks`. Scroll and pet-buff overrides are forced nil in an arena.
   - Per item: skip scrolls, `ns.CacheItemData`, then the usability gates (level, First Aid, Alchemy, Engineering, `requiredSpellID`, zones, `arenaOnly`, arena blocks).
   - Dispatches to **every** definition whose `itemTypes` claims the item and whose `accepts` passes. An ignored item only sets `ns.scannedIgnoredTypes[type]`.
2. **Rank** (`Scanner/Scanner-Ranking.lua`).
   - One ordered list, `RANKING_PRIORITY`, drives both `IsBetter` (single winner) and `CompareRankedCandidates` (ranked types) through `CompareRecords`, which also returns the deciding field for Diagnostics. It ends on item ID for determinism.
   - Ranked types keep up to `ns.MULTI_USE_MAX_ITEMS`.
   - Selection tables build lazily on the first scan, because definitions register after the scanner loads. Winners publish as `ns.bestSelection`.
3. **Compose.**
   - With `macrosEnabled` off the scan still runs (plus `ns.ScanPetFood` and the mini-map icon), because the Readiness Report and the mini-map read it. Nothing is created, rewritten or deleted.
   - Per standard definition: delete the macro if its `enabledMacros` entry is off. Otherwise run, in order: `modifyItem`; `corpseSpell` / `leadSpell`; ranked `useIDs` (types in `ns.MULTI_USE_MACRO_TYPES` only); `getStackIDs`; the `outOfCombatTypeName` item behind `potionsUseFoodAndWater`; `ns.BuildDruidMacroOverride`; `buildModeOverride`.
   - The body is the first of: the mode body, the class (DruidMacroHelper) body, the standard body (`Body-Builder.lua`).
   - Custom definitions run afterward with their own state: Feed Pet (`Tools-Hunters.lua`, `currentPetFoodState`) and Poisons (`Tools-Rogues.lua`, `currentPoisonState`).
4. **Write** (`Macros/Writer.lua`). `ns.WriteMacroBody` is the one writer.
   - It creates through `ns.TryCreateMacro`: General tab (`perCharacter` omitted), paused at `ns.MACRO_SLOT_CUSHION` with a once-per-session warning, resuming on its own when a slot frees.
   - It calls `EditMacro` only when `GetMacroBody` differs.
   - It returns false on a failed write, and every caller then leaves its state key unset.

**State keys and bodies:**

- Two layers stop a double write: the per-type state key in `currentMacroState`, recorded only after the write landed, and the writer's body comparison.
- The key format is documented above `ns.BuildStateKey`. It is lossless over every body input. The mode key (`SCROLLS:`) and DruidMacroHelper key (`DMH:`) use disjoint prefixes, and a standard key starts with a digit or `none`, so every mode change rewrites the macro. `ns.ResetMacroState` wipes every key, the scroll baseline and the signatures.
- **Blizzard Macro UI.** It saves its edit box back on close, reverting a write the state key already recorded. `ns.UpdateMacros` therefore marks pending while `MacroFrame` is shown, and a one-time `OnHide` hook (`EnsureMacroUIHook`, armed on every pass) resets state and requests. A first open and close before any update is the one gap.
- Standard payload:

```
#showtooltip item:<id>
<conjure block>
/run GtGFire(<id>[,<oocID>])
<OOC block>
/use item:<id>   (up to ns.MULTI_USE_MAX_ITEMS ranked lines)
```

  With nothing in bags the item line becomes `/run GtGNoItem("<type>"[,1])`, or a `GtGTip` when the class can conjure one.
- **Byte trims** against `ns.MACRO_BODY_MAX_LENGTH`, in order: Cannibalize lines, stacked healthstones, ranked fallbacks from the bottom (never rank 1), out-of-combat stealth, the out-of-combat block, the appended line. A body still too long is written anyway, with one `ns.WarnOnce` per macro. DruidMacroHelper trims its own `/use` lines, stealth and OOC block, then falls back to the standard body. Feed Pet sheds Dismiss, then Revive.
- **Multi-use macros** fall through to the next ranked item once the best runs out mid-combat, where the macro can't be rewritten. That is safe only because every item in those types shares one cooldown.
- **`enabledMacros` is account-wide while the choices are per-character.** The macros live in the shared General tab, so which ones exist is one choice for the account; a character switch only rewrites bodies.
- **Conjures** (`ns.GetSmartSpell`): the rank is pinned with `C_Spell.GetSpellSubtext` when the data row carries one. Food, Water and Healthstone downrank for a low-level friendly target; Mana Gem, Soulstone, Refreshment Table and Soulwell ignore the target. Healthstone and Mana Gem skip a tier already carried (`checkUnique`).
- **Arenas** are detected live (`IsInInstance`), never by zone list.
- **On Forever** scrolls trigger the GCD, so the scroll body fires one scroll per press.
- **DruidMacroHelper's return form** is a setting, not tracked: a macro can't be rewritten after a mid-combat form change.

**Macro runtime globals.** Macro `/run` lines can't see `ns`, so these are globals with short names:

| Global | File | Does |
|---|---|---|
| `GtGFire(id, oocID)` | `Macros/Runtime.lua` | Stamps the item; an `ERR_ITEM_WRONG_ZONE` within 1 s prints a bug report naming it |
| `GtGTip`, `GtGTipIf` | `Macros/Runtime.lua` | Tip from `ns.TIP_MESSAGES`; `GtGTipIf` appends a `" 1"` sentinel to its conditional |
| `GtGNoItem(type, canMake)` | `Macros/Runtime.lua` | The no-item print |
| `GtGReplace()` | `Macros/Runtime.lua` | Accepts `REPLACE_ENCHANT` |
| `GtGMute(on)` | `Enhanced-Spellbook/Mute-Errors.lua` | Zeroes the `MUTED_CVARS` that are on; restores exactly what it read, with a backstop timer |
| `GoodToGo_ToggleSpellbook()` | `Enhanced-Spellbook/Key-Bindings.lua` | `Bindings.xml` toggle |
| `GtGBuffKey` (frame) | `Buff-Duty-Keys.lua` | Hidden secure button the Buff Key clicks |

The `Connoisseur*` aliases of `GtGFire`, `GtGTip`, `GtGTipIf` and `GtGNoItem` stay until their migration expires, because macros Connoisseur & Restocker wrote still call them.

**Ignore List** (`Ignore-List.lua`):

- It has two halves, `profile.ignoreList` and `global.ignoreList`, read through `ns.IsIgnored`.
- Promoting an item to Global clears it from every profile.
- `ns.GetIgnoreListForScope` reads other profiles straight from `ns.db.sv.profiles` and creates a table only on a write.
- The logout prune drops only IDs that `C_Item.DoesItemExistByID` denies, since Era and Season of Discovery share the file.
- Every edit calls `ns.ResetMacroState` and `ns.UpdateMacros(true)`.

### Readiness Report

- Module `ReadinessReport`. `READY_CHECK` is subscribed only while `readinessReportEnabled` (`ns.SyncReadinessReportEvents`). It goes silent while `ns.AreAurasSecret()`.
- `ns.BuildReadinessLines(inArena)` returns nil when nothing is wrong. It ignores the master switch, so Diagnostics can render it on demand.
- **Silence is the feature.** A category with nothing wrong prints nothing, and a clean character prints nothing at all. A switch may only ever add a line about something broken. Durability names each equipped item under the threshold, never an average, since one weapon near zero is what breaks mid-pull.
- Item lines read the last scan (`ns.bestSelection`, with `ns.scannedIgnoredTypes` counting as carried). The Mana Gem line reads raw `ns.scannedItemCounts` against `ns.MANA_GEMS`.
- Weapon lines use `ns.BuffDuty.ReadWeaponEnchants`. `ns.WEAPON_ENCHANTS_STACK` raises the wanted count to two. A Shaman in the party waives the main hand, except where enchants stack.
- In an arena the buff, expiring and item clauses drop; the PvP clause also drops in battlegrounds. The probes in `Readiness-Report-Probes.lua` are stateless.
- The panel's Example (`ns.BuildReadinessSampleLines`) shares the `ns.ReadinessAsks*` gates.

### Inventory Report

- **No module of its own.** `ns.inventoryEventHandlers` is dispatched by the Restocker's module (`Restocker-Events.lua`) and subscribed through `ns.SyncRestockerEvents`. `ns.InitializeInventoryReport` runs from the Restocker's `PLAYER_LOGIN`.
- Record: `global.inventory[ns.GetCharacterKey()]` holds `{ name, realm, class, guid, bags, bank }`, each place one line of `id:count` pairs sorted by ID.
- Bags are read at `PLAYER_ENTERING_WORLD` and `BAG_UPDATE_DELAYED`; a read with a 0-slot backpack is ignored. The bank is read on `BANKFRAME_OPENED`, again after `BANK_SETTLE_DELAY`, and on bag updates while open.
- **Logout writes only what was last read**: on Forever the containers can read empty at `PLAYER_LOGOUT`. A GUID match drops a renamed character's old record.
- The tooltip hooks after `TOOLTIP_HOOK_DELAY`, so its block lands under other add-ons' lines. It goes through `ns.AddItemTooltipPostCall` on `GameTooltip` and `ItemRefTooltip`, and a weak-keyed set blocks doubled calls. It shows this character live, then other same-realm characters. A zero total shows nothing unless the item has a Keep on the current Restock List.

### Restocker

The feature is "Restocker"; its window is the Restock List; its starter popup is "Staples". In code, Staples is still the "Starter List" (`Restocker-Starter-*.lua`, `ns.STARTER_LIST_CATEGORIES`).

#### Lifecycle

- Module `Restocker` (`Restocker-Events.lua`). It has one handler per event in `ns.restockerEventHandlers`, every one wrapped in `WhileEnabled` except `PLAYER_LOGOUT`. Anything else wanting an event already in the table calls from that handler: `ns.OnRestockerEnteringWorld` covers the arrival reminder, the Staples trigger and the upgrade catch-up.
- Login (`ns.InitializeRestocker`, `Restocker-Core.lua`): `InflateSavedRestockItems`, `InitializeCharacterRestockList`, `PruneEmptyOrphanRestockLists`, events, bag definitions, `SetupCraftingRecipes`, `CreateRestockWindow`.
- Logout: `SaveRestockWindowGeometry`, then `DeflateRestockItemsForSave` last (every row is a string from then on), then `currentList = nil`.
- `ns.SetRestockerEnabled` off: closes Staples, ends any bank or merchant visit (no `_CLOSED` event will reach a sleeping handler), hides the window. `/restock` refuses every subcommand but `help` and `config` while it is off.

#### Lists and Choices (`Restocker-Saved-Lists.lua`)

- Lists live at `global.restocker.lists[name][itemID]`. Each character's choice is `listChoices[profileName]` on global, so two characters sharing a profile keep their own lists and Reset Profile can't empty a hand-built list (a README-Notes exception).
- `ns.UseRestockList` is the single write point for a choice.
- `IsListNameTaken` counts both existing lists and names other characters still point at, because those would recreate the list at login. `FreeClassListName` numbers a class name rather than joining another character's list.
- Deleting a list lands on `ns.GetRestockListAfterDelete`. New List and Copy open the rename; Cancel calls `ns.DiscardMadeRestockList`, which deletes the new list only while its rows are unchanged.

#### Saved Format (`Restocker-Saved-Format.lua`)

- Each row packs to `"itemName, amount, stash, fromBank, buy, reaction, upgrade, buyExtra"` at logout and inflates at login.
- Every field is always written. Data starts at the first numeric field, and the leading name is a label that is never read back; `ns.RefreshRestockItemName` supplies the live name.
- `buy` and `upgrade` are nil-means-on, `buyExtra` nil-means-off. A new field is a new trailing field with its own default.

#### Merchant (`Restocker-Merchant.lua`)

- On `MERCHANT_SHOW` (Shift skips), `RestockFromMerchant` builds the poison reagent order and gates it all-or-nothing (`VendorStocksAllReagents`), since half a recipe crafts nothing.
- It then builds one order per Buy row, counting bags by item ID only, gated by the vendor's reaction (`UnitReaction("npc")`).
- The budget is `GetMoney()` less the Gold Reserve, plus a `ns.NewBagSpace` snapshot (`Restocker-Purchase-Space.lua`), which fills partial stacks, then a matching specialty bag, then a general bag. Both are spent down locally, because nothing changes until the server answers.
- `PurchaseMerchantItem` buys in stack-sized chunks, skips extended-cost slots, caps at a limited slot's stock, and lets Buy Extra take a limited slot's whole stock. It never sells.
- The report waits for delivery: the run parks as `pendingRun` until `ns.SettleMerchantBuys` on `BAG_UPDATE_DELAYED` or `BUY_SETTLE_TIMEOUT`, and counts units delivered, not units sent. The close reminder waits behind it (`ns.AfterMerchantBuysLand`).
- `ns.merchantIsOpen` is the hard gate the bank run reads. `ns.REPUTATION_STANDINGS` discounts are labels only; the reaction gate is the only enforcement.

#### Bank Run (`Restocker-Bank-State.lua`, `-Bank-Visit.lua`, `-Bank-Moves.lua`, `-Bank-Tidy.lua`, `-Bags.lua`)

- On `BANKFRAME_OPENED` (Shift or an empty list skips), `ns.StartRestockBankRun` reloads the bank bags every time (`ns.LoadRestockBankBags`; on Forever, the `C_Bank` tabs the player bought) and starts a coroutine.
- An OnUpdate ticks at `ComputeUpdateInterval()`: 3× the higher ping with a floor, both literals.
- Each step of `RunRestockLogic`:
  1. Aborts while `ns.merchantIsOpen`.
  2. Rescans. A foreign item on the cursor is waited out for `MAX_STUCK_STEPS`, then cleared.
  3. Waits up to `MAX_INFLIGHT_STEPS` while a bag-plus-bank total has dropped (a move in flight). Also waits while any list item is locked.
  4. Stops with `StuckMessage` after `MAX_STUCK_STEPS` with no fall in remaining work.
  5. Makes one move: stash first if the bank has a free general slot, else pull first.
  6. Never finishes inside `BANK_SETTLE_DELAY`, since the bank may still read empty.
- Keep amounts freeze per run (`RestockState:Wanted`). Enter in a Keep box restarts the run.
- After a stuck step, a pull overshoots with a whole stack, and the excess is stashed back even without Store (`overshotItems`).
- Placement always names an empty slot (`BagDefinition:PutCursorItem`), and every path ends in `ClearCursor()`.
- The tidy phase merges partial stacks within the bags, then within the bank, never across, until `CountRestockPartialStacks` stops falling. `RESTOCKER_COMPLETE` prints only if something moved.
- `ns.restockPlayerBags` are where items may be put; `ns.restockCountedBags` adds the reagent bag for counting and stashing.

#### Shortfall, Reminders, Upgrades

- `ns.BuildGroceryList` (`Restocker-Shortfall.lua`) is the one source for the mini-map report, every reminder and the footer. It counts bags only, includes Buy rows only and leaves out reagents. `ns.IsRestockItemShort` drives the Keep mark.
- Town reminder (`Restocker-Reminders.lua`): fires on a not-resting to resting edge (a taxi forces not-resting), with `REMINDER_COOLDOWN`, `ARRIVAL_SETTLE_DELAY` and `LOGIN_SETTLE_DELAY`. A `/reload` seeds silently (`ns.ArmRestockerReminders`). The sound is `ns.RESTOCK_ALERT_SOUND`. Close reminders wait `SETTLE_DELAY`; the bank reminder fires only if that visit's run started.
- Upgrades (`Restocker-Upgrade.lua`): `ns.CONSUMABLE_UPGRADE_CHAINS`, sorted by rank at load. A row moves only forward to the best tier at or below the level; merging into an existing row sums amounts. They run on `PLAYER_LEVEL_UP` with the event's level and as a catch-up on `PLAYER_ENTERING_WORLD`. A cold target parks as `pendingUpgrade`.

#### Staples (`Restocker-Starter-List.lua`, `-Starter-Window.lua`)

- At load, each row's `chainKey` is replaced by `row.chain`, mutating the data table; rows whose chain is missing on the flavor drop. A row is offered when its class matches and its ladder has an item at the player's level.
- Login trigger, fresh logins only: after `STARTER_POPUP_DELAY`, at `STARTER_MIN_LEVEL` or above, on an empty list, out of combat, not while `ns.IsLegacyImportPending()`. It pre-ticks the `defaultFor` rows, opens the Restock List, then the popup.
- While open, the popup takes the Restock List off `UISpecialFrames` and hands it back a frame after it hides.

#### Window

- A hand-built portrait frame shared with Staples (`Restocker-Window-Frame.lua`, `ns.RESTOCK_WINDOW_BANDS`).
- `ns.UpdateRestockList` (`Restocker-Window-Render.lua`) is the full redraw. It closes every menu first, since pooled rows rebind, and calls `ns.RequestUpdate` when membership changes and `profile.useRestockLast` is on. `ns.RefreshRestockShortfall` repaints only marks and status.
- Groups are keyed by classID via `GetItemInfoInstant`, which needs no item cache.
- `COLUMNS` (`Restocker-Window-Columns.lua`) drives header and rows; widths are measured from the font.
- Menus are AceGUI `Dropdown-Pullout`s closed by `ns.CloseRestockMenus`, never `UIDropDownMenu`. The Staples stack picker is `WowStyle1DropdownTemplate`.
- A visit opens the window only with `autoOpenAtMerchant` / `autoOpenAtBank`, and closes it only if that visit opened it (`ns.restockWindowOpenedByVisit`). Geometry is written whole at logout.
- The Keep box saves on every keystroke; an emptied box saves 0, which stores all of that item at the bank. Undo is one step deep (`ns.restockLastRemoved`).

### Sent Messages (`Features/Announcements.lua`)

- Every automated line is `{rt1} body // GtG`, built by `SignOff`. `ns:BuildWhisperMessage` (Rank Watch, whispered Buff Duty asks) and `ns:BuildAnnounceMessage` (Buff Duty's group ask) wrap it.
- `MarkerPrefix` drops `ns.TARGET_MARKER` from non-whispers on Forever, which blocks raid-marker tokens in group chat.
- `TrimSentBody` trims closing punctuation as whole UTF-8 sequences (`CLOSING_MARKS`) and drops leading `¡ ¿` (`OPENING_MARKS`). Bodies carry links, so pipes stay.
- Whispers queue `WHISPER_GAP` apart (`QueueWhisper`); an empty queue sends at once. Group channel: `ns:GetGroupChatChannel`.
- `ns:BuildBuffRequestMessage` names up to `ASK_MAX_NAMES` players, else counts them.
- `ResolvePlurals` resolves the client's `|4` plural escapes, but only inside `ns.FormatDuration`. Nothing on the send path resolves them.

### Buff Duty

#### Events and Flow

- Module `BuffDuty`. Each event has one handler, set through `ns.SetBuffDutyEventHandler` (`Buff-Duty-Events.lua`).
- `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD` and the regen events are always on. `WINDOW_EVENTS` subscribe only while `ns.IsBuffDutyOnForClass()` (`ns.UpdateBuffDutyEvents`), which also runs the backstop.
- `UNIT_AURA` is unfiltered: nameplate units arrive and are dropped by string in `ns.OnBuffDutyUnitAura`.
- `Data.SAFETY_PAUSE` after every `PLAYER_ENTERING_WORLD` (`StartSafetyPause`, token-voided, read by `ns.IsBuffDutyReady`) gates resurrect and favor detection.
- `ns.SetupBuffDuty` runs once at login: `BuildLookup` (drops IDs the client lacks), `BuildCategories`, `PopulateBuffDutyAudience`, `BuildBuffs`, the frame, the settings apply, `ns.MigrateBuffKeys`.
- `Refresh` hides the window while the switch is off, nothing is on offer, `ns.AreAurasSecret()`, or `ShowsHere` fails. Otherwise:
  1. `BuffDuty.BuildSections`: Self (self buffs, Soulstone, weapons), Target then Return the Favor (Target claims a GUID first), then one section per subgroup and pets.
  2. Party-Buffs.
  3. `ns.RenderBuffDuty`.
- Sections are plain tables; only `Buff-Duty-Frame.lua` draws. The redraw is skipped when `Signature()` is unchanged. A `held` layout keeps the width stable until the roster key changes.

#### The Window and Casting

- Two frames: `anchor` on `UIParent`, owned by the Hide in Combat driver, and `content` inside it. Icons are pooled `SecureActionButtonTemplate` buttons.
- The close button runs `ns.CloseBuffDuty` (off for this class only); the template's click would hide a protected parent. The title uses the Short Name (README-Notes).
- `ns.SetBuffButtonAttributes` writes every key, nil included, on every use, because buttons are pooled. Only `type1` is set, so right-click dismisses a favor instead of casting.
- Spells cast by rank text, `Name(Rank N)` from `C_Spell.GetSpellSubtext`: on Classic Era a lower rank's ID casts nothing, and a bare group-buff name casts Rank 1. Resurrections and Create Soulstone cast by bare name, since each tier is its own spell. Weapon items use `item` + `target-slot`.
- An outsider out of sight gets `/cleartarget` / `/targetexact NAME` / `/cast [help] Name(Rank N)`.

#### Reading Auras (`Buff-Duty-Auras.lua`)

- A GUID-keyed cache, so a roster change only prunes it. `UNIT_AURA` marks a GUID dirty; `MarkAllAurasDirty` bumps a generation.
- `myStrengths` sums your own casts' `points`. `bounced` is filled by `NoteBounce` from `SPELL_FAILED_AURA_BOUNCED` within `BOUNCE_WINDOW` (`Buff-Duty-Cast-Results.lua`).
- `Has` decides in this order: bounce match, strength compare, rank compare (`RankFor`), the time rule (`refreshSeconds`), the exclusive family. A buff running low returns its expiry for the reversed sliver.
- `RankFor` caps by `RANK_LEVEL_GAP` over the target's level only where `ns.EXPANSION <= 3`.

#### Who Gets What

- `RoleOf` checks, in order: the Main Tank mark, the assigned role (tank only outside a raid), the player's own LFG roles, `tankWhen[class]`.
- Pets take `ALL` buffs, plus `TANK` per `tankWhen.PET`, never `HEALER`. `manaOnly` is judged by the pet's power type. Charmed or phase-shifted pets are skipped, and so are pets out of sight (`UnitIsVisible`), ones `UnitCanAssist` refuses, ones whose identity is secret on Forever, and ones with any unreadable aura (`BuffDuty.AurasReadable`); only a readable "no" skips.
- Pet holds (`Buff-Duty-Pets.lua`): a cast the window or key aimed at a pet that goes off (`ns.OnBuffCastSucceeded`) holds that buff for your cast's learned duration (`BuffDuty.MyDuration`, else `PET_HOLD_FALLBACK`) less the refresh time; a bad-target refusal (`PET_REFUSALS`) holds it while the pet stays around. `Has` agreeing clears a hold; `PruneAuraCache` drops holds on GUIDs no longer watched.
- `ns.IsBuffInRange` tries spell range, then `UnitIsVisible`, then `UnitInRange`. An unknown or secret answer reads as in range.

#### Buff Key (`Buff-Duty-Keys.lua`, `Buff-Duty-Key-Picker.lua`)

- A hidden `GtGBuffKey` secure button bound to `ns.BUFF_KEY_COMMAND`, because a slash command can't cast. PreClick picks a spec and writes attributes, the template casts, PostClick clears them. The up half reuses the down pick within `PRESS_REUSE_SECONDS`.
- Candidate order: dead target, group dead, favors, target, self, parties (target's subgroup first).
- `GroupChoices` takes the group version when it is cheaper by mana, when a member can take no single rank, or when costs are unknown and it reaches two or more. A group buff waits until every member is in sight.
- Weapon icons and `hasCooldown` icons (using a soulstone) are never picked; Create Soulstone is.
- Skip memory: `BUFF_SKIP_SECONDS`, `RESURRECTION_SKIP_SECONDS`, `FAVOR_RETRY_SECONDS`.
- "On cooldown" means ending after the GCD, read from `ns.GLOBAL_COOLDOWN_SPELL_ID` where the flavor's Game-IDs defines it, else the first known class spell whose cooldown is the GCD alone.

#### Other Sections

- **Weapons** (`Buff-Duty-Weapons.lua`): each hand is asked about the layers in `Data.WEAPON_LAYERS`. Where `ns.WEAPON_ENCHANTS_STACK` (Camelot) holds, poisons, Shaman imbues and `ns.BUFF_DUTY_WEAPON_IMBUE_ITEMS` fill IMBUE and other items fill TEMPORARY; elsewhere it is one layer. `ReadWeaponEnchants` reads `C_Item.GetWeaponEnchantInfo` on Forever. Shaman imbues are offered only where they land. `REPLACE_ENCHANT` is auto-accepted within `REPLACE_WINDOW` of a weapon click.
- **Party-Buffs** (`Buff-Duty-Other-Classes.lua`, `-Party-Buffs.lua`): counts non-exclusive `group` rows the player can't cast that the group lacks. Its icons are plain buttons whose click does nothing, so nothing is sent by accident. A hover menu offers Ask (group) and Whisper (every other player of that class), each with its own `ASK_COOLDOWN`.
- **Return the Favor** (`Buff-Duty-Favors.lua`):
  - Off Camelot: combat-log `BUFF` events on the player from a friendly, outsider-flagged player GUID. Affiliation, because cross-realm names break name lookups.
  - On Camelot: the player's own `UNIT_AURA` `addedAuras`, with the caster from `sourceUnit` or `C_UnitAuras.GetAuraCasterGUID`, skipped in combat or while secret.
  - Capped at `Data.BUFF_DUTY_FAVOR_MAX` and kept `favorSeconds`. There is deliberately no players-in-range list: it would depend on friendly nameplates.
- **Resurrections**: `RESURRECT_PENDING_SECONDS` after `SPELL_RESURRECT`. On Camelot, the player's own cast succeeding within `RESURRECT_CAST_SECONDS` stands in.
- **Soulstone**: hidden while anyone in the group carries one.
- Buff Duty never waits on item info (`GetItemCount`, `GetItemIconByID`); only the Weapon Buffs panel warms items.

### Rank Watch

The standalone Rank Sentinel add-on, brought home. It reports a spell cast at a lower rank than the caster could have: a print for the player's own casts, and a whisper to, or a print about, a group member.

- **Events.** Module `RankWatch`, with one handler per event via `ns.SetRankWatchHandler`. `ns.SyncRankWatchEvents` subscribes `EVENTS` plus `ns.RANK_WATCH_CHAT_EVENTS` while `ns.IsRankWatchActive()` (on, and the standalone add-on not loaded), then calls the loaded detection file's `ns.SyncRankWatchDetection` and `ns.SyncRankWatchCluster`.
- **Mists has no Rank Watch code.** Outside callers test that a function exists first: the panel registration (`ns.BuildRankWatchOptions`), the feature switch (`ns.SetRankWatchEnabled`), `/gtg ignore` (`ns.IgnoreRankWatchPlayer`), Diagnostics (`ns.RankWatchSettings`).
- **Ladders** (`Rank-Watch-Lookups.lua`, `ns.BuildRankWatchLookups` at login): built from `ns.RANK_WATCH_ABILITIES` per class, minus ranks the client lacks, joined across one `ns.SPELL_GROUPS` group. `ns.RANK_WATCH_PET_ABILITIES` ladders are never joined, and their level is the pet's.
  - `ns.RankWatchReportableLookup` is the fast reject.
  - A row's tracked state is its `off` default, overridden by `rankWatch.untracked`.
- **The check** (`ns.CheckRankWatchCast`, `Rank-Watch-Check.lua`):
  - Skips PvP instances, ignored players, charmed units, enemies and unreadable levels.
  - The ceiling is the lowest of: the caster's level, and their first-seen level this session, each less the grace (`graceMaxLevel` at the cap, else `graceLeveling`); and, for a cast on another friendly player, that player's level plus `Data.RANK_WATCH.TARGET_LEVEL_RANGE`. The game lowers a buff's rank by itself to fit a target.
  - Pet casts check the pet's level and report to the owner.
- **Dedupe**: once per caster and ladder a session, and saved as `guid-level-spellID` in `rankWatch.announced`, keyed the way the standalone add-on keys `NOTIFY`. Wiped when `announcedVersion ~= ns.Version`.
- **Whisper queue**:
  - Held in combat or while dead; a target in combat retries after `TARGET_BUSY_RETRY`.
  - Waits for the client's rank text (`ns.RankWatchHasRankText`, `RANK_TEXT_RETRY` × `RANK_TEXT_TRIES`) and drops the whisper rather than send the data's rank number.
  - The first whisper to a player is followed by an opt-out line. `ns.RankWatchOptOutCode` is a name hash, so every copy computes the same code, and saying it in any watched chat adds the sender to Ignored Players.
  - The player's own casts always print.
- **Cluster** (`Rank-Watch-Cluster.lua`): every copy, Good to Go's and the standalone add-on's, speaks over `Data.RANK_WATCH.COMM_PREFIX` (`RANKSENTINEL`), so the two elect one leader.
  - Messages: `JOIN` after `JOIN_DELAY`, `LEAD`, and `NOTIFY` / `SYNC` (validated by `ANNOUNCED_KEY_PATTERN`).
  - Only the leader whispers, and a leader with whispers off doesn't claim the lead. Nothing is sent in PvP instances.
- **Detection, combat log** (Vanilla, TBC): `SPELL_CAST_SUCCESS` from group sources. A pet-ladder cast resolves its owner (`PetAndOwner`). A friendly destination passes its level, and a cast whose destination level is unreadable is dropped.
- **Detection, Forever** (no combat log, other players' cast IDs hidden):
  - Own casts: `UNIT_SPELLCAST_SENT` → `SUCCEEDED` by castGUID (`PENDING_TTL`), with the recipient from `ResolveCastTargetUnit`.
  - Own pet: `SUCCEEDED` on `pet`.
  - Others' buffs: group `UNIT_AURA` `addedAuras`, never while secret.
  - Others' damage and heals: `C_DamageMeter` every `METER_POLL`. The first read is a baseline, and a spell counts only when its total moved. Heals are capped by the lowest group level, and pet spells are checked as the owner's pet.
- **The standalone add-on**: while it runs, Rank Watch stays quiet (`TakeOverFromStandalone` every such login), and its settings are copied in once (`importedStandalone`).

### Enhanced Spellbook

#### Hosts and the Window

- `GoodToGoSpellbookFrame` (`Spellbook-Window.lua`, `WINDOW_WIDTH` × `WINDOW_HEIGHT`) replaces the game's book rather than docking to it: on show, `ns.CloseGameSpellbook` hides the native book, out of combat only.
  - It is built lazily on the first toggle; until then `ns:RefreshOpenPages()` returns false.
  - `FitToScreen` only shrinks, counting the docked panel.
- `TABS`: Spell Book, What's Next?, Pet Spell Book (class gate, `ns.HasPetSpellbook`), Pet What's Next? (data gate, `ns.HasWhatsNextPet`; Camelot's pet tables are empty).
- **Classic host** (Vanilla, TBC, Mists): a tab parented to `UIParent`, anchored under the class's last skill-line tab, hooked with `HookScript` and `hooksecurefunc` only.
- **Modern host** (Camelot): `Spellbook-Tabs.lua` stacks side tabs down `PlayerSpellsFrame`'s right edge. It steps past other add-ons' tab-sized frames (`NextFreeColumnSlot`) and attaches on `ADDON_LOADED` for `Blizzard_PlayerSpells`.
- Every launcher and window frame is parented to `UIParent` and only anchored to Blizzard frames. The page strip is custom: Blizzard's paging template reads a format string the Classic clients lack.

#### Events

- Module `Spellbook` (`Spellbook-Core.lua`). `EVENT_HANDLERS` maps each event to an `ns:On<X>` name resolved when it fires, so later files supply the handlers. `WHILE_OFF_EVENTS` dispatch even with the feature off.
- `ns.SetSpellbookEnabled(false)` hides the window; macros freeze as last written.
- `SPELLS_CHANGED` with no page open wipes `ns.macros` for a lazy rebuild, unless `ns.GroupSpellLearned()` or `ns.HandOverDue()`, which rebuild and sync now.
- `SPELL_DATA_LOAD_RESULT` redraws only for IDs the add-on requested (`ns.SpellName` requests each ID once).

#### Build → Sync → Draw

1. **`ns.CollectMacros`** (`Macro-Builder/Macro-Builder.lua`):
   - Resolves class config and reads the book (`ReadSpellbook`, `ns.ForEachClassSpell`). Season of Discovery IDs at or above `ns.SOD_FIRST_SPELL_ID` are hidden on a non-Discovery realm.
   - Makes one macro per spell, then focus copies (not on Vanilla), Duplicates (`macroCopies`), rank copies (`ns.ShowsAllRanks`) and unlearned spells.
   - Folds profession specializations and the ranged attacks into one Shoot macro with `[worn:<client subclass>]` clauses. Folded macros are hidden on the page but still synced.
2. **`ns.SyncAllMacros`**: `ReadMacroIndexes` once, then `ns.SyncMacro` each.
   - `FindMacroIndex` looks up by tag, then by name, then by the legacy names.
   - `SyncAt` rewrites only when the body differs and fits `ns.MACRO_BODY_MAX_LENGTH` (`ns.WarnOnce` otherwise). It renames legacy and replaced-spell names, and keeps a name the player chose.
   - While `MacroFrame` is shown every sync is a no-op. A one-time `OnHide` hook re-syncs on close.
3. **Draw** (`Spellbook-Page.lua`): `ns.SpellbookPageCategories`, `PackRows` / `Paginate`, `ns.SetMacroButton` per tile. Glows come from `ns.ScanActionBars`, which matches bar macros by name or tag and bar spells by name, so any rank counts.
4. **Pickup** (`ns.PickupMacro`) creates the macro: a character slot while one is free, else General, with a real boolean `perCharacter`. It assigns the tag and re-measures, because a three-character tag adds a byte.

- Every menu or panel change runs `ns.RefreshSpellbookPage`, which rebuilds every `ns.macros` entry. Menus re-find their macro (`ns.MacroMenuRebuiltMacro`), and panels re-find theirs by `SettingsKey`.

#### Macros per Spell

- **Settings keys** (`Macro-Options.lua`): the Rank 1 ID (`BaseSpellID`), `id#n` for a Duplicate, `id@rankID` for a rank copy, `consumable:<type>` for a Consumable Macros tile. A key survives rank-ups and locale changes.
- An option is stored only where it differs from its kind default (`SetOption`). Choices of one are stored whole, and `kindDefaults` values are stored as true or false, never nil.
- **Names**: `ns.MACRO_NAME_PREFIX` plus the name trimmed to `ns.MACRO_NAME_MAX_LENGTH` by `ns.TrimMacroName`, which never splits a UTF-8 character. The suffixes come from the locale (`MACRO_NAME_FOCUS_SUFFIX`, `MACRO_NAME_RANK_SUFFIX`).
- **Kinds**: `ns.MACRO_KINDS` / `ns.MacroKind` (`Macro-Kinds.lua`) decide the offered options (`OFFERED`) and defaults (`ns.DEFAULTABLE_OPTIONS`).
- **Body order** (`Macro-Body.lua`):
  1. `#showtooltip`
  2. One `/stopmacro`, ahead of the mute, so a stopped press never leaves sound muted.
  3. `GtGMute(1)`, `/stopattack`, `/stopcasting`, `/cancelform`, target line.
  4. `/use` slots, stance line.
  5. The cast line: Conditionals rows, then Right-Click group clauses, then target priority.
  6. Auto shot, `/startattack`, `/petattack`, error clear, `GtGMute()`.
  7. The tag line.

  Shape: `/cast [mod:shift] Frost Nova; [@mouseover,harm,nodead][] Fireball` then `#a7`.
- Limits: `ns.CONDITIONALS_MAX_ROWS`, `ns.CONDITIONALS_MAX_CONDITIONS`, `ns.CAST_SEQUENCE_MAX_STEPS`. `oncePerCombat` / `oncePerTarget` become a `/castsequence reset=… X, NULL`.
- **Dynamic Rank** (`RankFor`, `RANK_LEVEL_GAP`) writes the highest rank fit for the target's level. It rewrites only while such a macro is on a bar (`PlacedRankMacros`), and never in combat. Mouseover leaving fires no event, so it is polled. Secret units fall back to the top rank.

#### Tags and Ownership (`Macro-Tags.lua`, `Macro-Lookup.lua`, `Macro-Delete.lua`)

- A macro's last line is its tag: `#` plus base-62 digits (`TAG_WIDTH`, growing to three). `UNASSIGNED_TAG` holds the length until the macro is written.
- `global.macroTags[identity]` maps `MacroOwnerKey:spell|focus|copyN|rank <id>:<spellKey>` to its tag, so a renamed or moved macro is still found and a re-placed one gets its old tag back.
  - `ns.MacroOwnerKey` uses the profile name, not `ns.db.keys.char`, which can be a placeholder.
  - `AssignMacroTag` skips tags already in any body, so Macro Spellbook's tags never collide.
- **Ownership** lives where no profile change can lose it: `global.ownedMacros[name] = ownerKey` for General macros, `char.ownedMacros[name] = true` for character macros (a README-Notes exception). Delete removes only macros with a handed-out tag **and** an ownership record, highest index first.
- **Group handover** (`Group-Handover.lua`): a learned successor in `ns.SPELL_GROUPS` takes the old spell's tag, settings, focus copy and Duplicates if it has no macro yet, and the sync renames the macro. This runs even with no page open.

#### Ranks, Trainers, What's Next

- Ranks exist where `ns.HAS_SPELL_RANKS` (not Mists).
- Learn levels come, in order, from `ns.ClassTrainerRows` (filtered by faction and race), then `profile.trainerSpells[class]` (recorded at class trainers by `Trainer-Recording.lua`), then `C_Spell.GetSpellLevelLearned`.
- `Class-Config.lua` empties every other class in `CLASS_SPELL_LISTS` and `TRAINER_SPELLS` at load.
- Forever's book keeps only the top rank, so a rank at or below the highest known counts as known.
- What's Next is computed live: statuses `ns.WHATS_NEXT_STATUSES`, sources `ns.WHATS_NEXT_SOURCES`. The three pages differ only by model (`ns.WHATS_NEXT_MODELS`). The Pet What's Next tooltip names beasts in English from data (README-Notes).
- Tooltip ranks (`Spell-Ranks-Tooltip.lua`) are gated by `global.abilityTooltipRanks`, the switch and out-of-combat. Their cache is keyed by player and pet level and cleared by `ns.InvalidateSpellRankRows`.

#### Docked Panels

- Conditionals and Cast Sequence share the `Docked-Panel.lua` shell, one docked at a time. They take the keyboard only in pick mode. The byte meter turns gold at `METER_WARNING`.
- Pick mode (`Spell-Pick.lua`) is owner-based and takes a tile click or a cursor drop.

### Mini-map Button (`Features/Minimap-Button.lua`)

- One LDB object for every feature, positioned from `global.minimap`, so a profile change never moves it. On Camelot the icon is fitted by hand, because LibDBIcon's `ResetButtonIcon` errors when another add-on replaced the icon.

| Click | Does |
|---|---|
| Left-Click | Toggles buff food and scrolls as a pair |
| Shift + Left-Click | Toggles Buff Duty for this class (`ns.SetBuffDutyForClass`) |
| Right-Click | Ignores the Food macro's pick (`ns.bestFoodID`) |
| Shift + Right-Click | `ns.ToggleRestockWindow` |
| Middle-Click | Clears this character's Ignore List |
| Shift + Middle-Click | Options, through the combat gate |

- Tooltip blocks cap at `LIST_MAX_ROWS`. The Restocker block reads `ns.BuildGroceryList`, and `ns.AddConsumableMacroNotes` is reused by the Spellbook tiles.

### Options Shell (`Options/`)

- `ns.RegisterOptionsPanels` (called from Core once `ns.db` exists) registers the General root, then each feature in `ns.FEATURE_GROUPS` order with sub-panels nested by category ID, then Profiles, Feedback & Support, and Diagnostics. Most panels register a builder function, so they rebuild on open.
- `FEATURE_SWITCHES` (`Options-Utilities.lua`) draws each master switch on the root and atop its panel. `confirmOff` applies to the Spellbook and Consumable Macros switches.
- Shared builders: `ns.BuildItemListOptions`, `ns.OptionsSubRow` (load-bearing for layout), the Example-line builders, `ns.MODE_VALUES`.
- Slash commands (`Options.lua`): `/gtg`, where `/gtg ignore Name` goes to Rank Watch (README-Notes), and `/restock` (`ns.HandleRestockerCommand`).

### Diagnostics

- **Off at every login, never saved** (`ns.diagnostics`).
- `Diagnostics/Manifests.lua` declares `ns.DIAGNOSTIC_API_CHECKS`, `ns.DIAGNOSTIC_SPELLS`, `ns.DIAGNOSTIC_NAME_LOOKUPS` and `ns.DIAGNOSTIC_DATA_SOURCES`. Each `Manifests-<Feature>.lua` appends to them through `ns.AppendDiagnosticRows`, which drops a repeated API label and merges data sources that share a label.
- The Event Log drops only `SPELL_UPDATE_COOLDOWN`. Firehoses are classified per firing (`ns:SuppressUncorrelatedMessage`), and `ns:LogEventNow` lets a handler log one decoded.
- Validate Data looks every data row up on this client and prints TSV for the Data Review. Message Length builds every sent line and macro body at its widest without sending or writing them; run it on ruRU.

## Files That Change Together

- **New registered event**: `ns.EVENT_NAMES` in `Features/Core.lua` (flavor-guarded if a client lacks it); `ns.SetModuleEvent` on and off at the feature's switch, or the feature's own list (`WINDOW_EVENTS`, `EVENTS`, `EVENT_HANDLERS` + `EVENT_UNITS`); a handler in the module's dispatcher or handler table, shared if the event is already taken.
- **New event module**: `ns.RegisterEventModule` in a file whose TOC position sets its dispatch order, in every TOC that should load it.
- **New data table**: a file in all seven `Data/{Game}/` folders (empty where no rows; Vanilla and Discovery files carry the guard); listed in all four TOCs between `Data/Data.lua` and `Data/Default-Settings.lua`; a `ns.DIAGNOSTIC_DATA_SOURCES` row.
- **New saved setting**: its `ns.DATABASE_DEFAULTS` key (or the feature's `AddDefaults` block) with its scope reason beside it; its options row; its locale keys in `Locales/enUS.lua`; a hook in `ns:ApplyProfile` if it is applied imperatively; a Diagnostics context line.
- **New feature master switch**: `FEATURE_SWITCHES` + `ns.FEATURE_GROUPS` (`Options-Utilities.lua`); a global default; `SWITCH_*` locale keys.
- **New options panel**: `ns.OPTIONS_REGISTRY` key (`Data/Data.lua`); `RegisterChild` in `ns.RegisterOptionsPanels`; the builder file in each TOC before `Options/Options.lua`; a locale title.
- **New key binding**: `Bindings.xml`; `BINDING_NAME_*` in the feature file and `.luacheckrc`; a row in `KeyBindings()` (`Options-General.lua`).
- **New client-divergent API**: an accessor in `Features/Utilities.lua` that answers nil where missing; an API row in the feature's `Diagnostics/Manifests-*.lua`; `.luacheckrc` read globals.
- **New slash command, popup or macro global**: the code, plus the `.luacheckrc` `SLASH_*`, `SlashCmdList`, `StaticPopupDialogs` field or global.
- **New consumable macro**: `ns.MACRO_CONFIG` (`Data/Data.lua`) with `MACRO_*` / `LABEL_*` keys (a shipped name never changes); `ns.MACRO_DEFAULT_ITEM_IDS` in every `Macro-Default-Items-{Game}.lua`; `Macros/<Name>.lua` calling `ns.RegisterMacroType`, listed in all four TOCs among the definition files; `enabledMacros[type]` in `Data/Default-Settings.lua`; a toggle row in `Options-Macros.lua`; multi-use needs both `ranked = true` and `ns.MULTI_USE_MACRO_TYPES`; conjures need `CONJURE_SHAPES` (`Message-Length-Macros-for-Consumables.lua`); class-only custom macros need `CLASS_ONLY_MACROS` (Manifests); DruidMacroHelper needs `ns.DRUID_MACRO_HELPER_TYPES` / `GUARDS`.
- **New consumable item type**: the table in every flavor folder and TOC; a `CONSUMABLE_TABLES` entry (`Item-Cache.lua`); a branch in `ns.CacheItemData`; any new gate in `ns.ScanBags` mirrored in `FailedGate` (Manifests); a data-source row.
- **New ranking step**: `RANKING_PRIORITY`, `FillRecord`, `ResetBest` (`Scanner-Ranking.lua`) and `CopyCandidateRecord` (`Scanner-Diagnostics.lua`), as a real boolean.
- **New body-shaping consumable setting**: profile default; panel row whose setter calls `ns.ResetMacroState()` + `ns.RequestUpdate()` or uses `ns.ToggleMacroSetting`; folded into the state key (`stateExtras`, an `appendBlock` flag, or `ns.BuildStateKey`); `AURA_TRACKED_SETTINGS` (`Engine.lua`) if it changes aura tracking; `ns.TargetSignatureChanged` or `ns.GroupSignatureChanged` if it reads target or group state.
- **New Readiness switch**: a `readiness*` global default (the prefix is what Reset reaches); a `SECTIONS` row (`Options-Readiness-Report.lua`); `READINESS_SWITCHES` (Manifests); the check (`Readiness-Report.lua`); the sample (`Readiness-Report-Example.lua`), sharing a `ns.ReadinessAsks*` gate.
- **New Restocker row field**: `ItemToString` / `ItemFromString` as a trailing field with its default; `ns.AddRestockItem` and `ns.AddStarterCategory` defaults; for a column, `COLUMNS`, `COLUMN_STATE`, `COLUMN_TOGGLE`, `COLUMN_SET`; the row counts in `Manifests-Restocker.lua`.
- **New Restocker setting**: `restocker` defaults; a control in `Options-Restocker.lua`; locale keys; a context line in `Manifests-Restocker.lua`.
- **New Staples row**: `ns.STARTER_LIST_CATEGORIES` (`Data/Data.lua`); a matching chain in every `Consumable-Upgrade-Paths-{Game}.lua` (`chainKey` forms `food:<diet>`, `poison:<group>`, `reagent:<name>` or a chain `kind`); a label key only for a kind-of-item row; a new `section` needs a block in `OfferedSections()` and a header key.
- **New Buff Duty party buff**: a row in `ns.BUFF_DUTY_SPELLS` in every `Buff-Duty-Spells-{Game}.lua` (legend atop the file); nothing else for an ordinary row.
- **New Buff Duty self buff sharing an exclusive family**: `ns.BUFF_DUTY_SELF_SPELLS` rows in each flavor file, plus `BUFF_DUTY_SELF_NOTE_<FAMILY>` in every locale.
- **New Buff Duty window setting**: `buffWindow` default; a panel row whose setter calls `ns.RefreshBuffDuty`; cleaning in `PopulateBuffDutyAudience` for a choice list; a line in `ns:BuildBuffDutyContextReport`.
- **New Rank Watch setting Reset Profile should reach**: `rankWatch` default plus `RESET_KEYS` (`Rank-Watch-Core.lua`).
- **New sent message**: locale key; built through `ns:BuildWhisperMessage` or `ns:BuildAnnounceMessage`; a row in `ns.DIAGNOSTIC_MESSAGES` (`Manifests-Buff-Duty.lua`) or the Rank Watch Message Length report.
- **New class spell**: its ID in the right lists of `Class-Spell-Lists-{Game}.lua`; a `Trainer-Spells-{Game}.lua` row, or `extraSpells` plus `ns.EXTRA_SPELL_SOURCES`; group spells in `ns.SPELL_GROUPS` / `ns.GROUP_VERSIONS`.
- **New page category**: `ns.PAGE_CATEGORIES` + `TAG_CATEGORIES` (`Page-Categories.lua`); the tag in `PAGE_TAGS` (`Class-Config.lua`); the tag list in the class lists or `ns.SHARED_PAGE_SPELLS`; a `CATEGORY_*` key.
- **New macro kind**: `ns.MACRO_KINDS` + a `ns.MacroKind` branch; `kindDefaults.<kind>`; `KIND_*` keys; `PRIORITY_KINDS` / `LEFT_OUT_UNITS` and `KIND_CATEGORIES` where relevant.
- **New Spellbook macro option**: a profile table; an `OFFERED` predicate; its line in `Macro-Body.lua`; `ns.DEFAULTABLE_OPTIONS` or `COPIED_SETTINGS` so Duplicates, resets and handover carry it; its menu entry (`Menu-Utilities.lua` or `Macro-Menu-Sections.lua`, plus `Category-Menu.lua`); `OPTION_SUBTEXTS`; `MENU_*` / `SUBTEXT_*` keys; a Message Length check.
- **New Spellbook event**: `EVENT_HANDLERS` (+ `EVENT_UNITS`) in `Spellbook-Core.lua`; `ns.EVENT_NAMES`; an `ns:On<Name>` handler whose name is unique across all of `ns`.
- **New Conditionals condition, Cast Sequence reset, What's Next status or source, or window tab**: `ns.CONDITIONS`, `ns.CAST_SEQUENCE_RESETS`, `ns.WHATS_NEXT_STATUSES` (+ `ns.WHATS_NEXT_INKS` / `ns.WHATS_NEXT_BRIGHT` and `RankState`), `ns.WHATS_NEXT_SOURCES`, or `TABS`, each with its locale keys.

## Saved Variables

- **`GoodToGoDB`** (`ns.SAVED_VARIABLES_NAME`): the one table, managed by AceDB-3.0 with `ns.DATABASE_DEFAULTS` from `Data/Default-Settings.lua`. Each feature's block is added through `AddDefaults`, which asserts no two features declare the same key.
- **`BagsBuffsButtonsDB`** (`ns.OLD_SAVED_VARIABLES_NAME`): the table from before the rename, listed in every TOC only for its migration.
- **Model: Per-Character.** `AceDB:New` takes no third argument, so every character lands on its own profile.
  - **Reset Profile clears that character's profile only.** `global` and `char` survive, and `OnProfileReset` re-applies.
  - **Profile** holds what differs by character: consumable choices, the Ignore List's character half, the Spellbook's per-spell options, `kindDefaults`, Duplicates, `markedPlaced` and recorded `trainerSpells`.
  - **Global** holds, each with its reason beside its key: presentation (`showWelcome`, `showMacroNames`, `minimap`, `abilityTooltipRanks`); master switches and `readiness*`; what every character shares on the client (`enabledMacros`, `ownedMacros`, `macroTags`, `macroTagCount`); data the player built or the add-on gathered (`restocker`, `inventory`, the Ignore List's Global half); `buffWindow`; `rankWatch`. `legacyImported` is written raw, before AceDB opens.
  - Two README-Notes exceptions keep per-character records off the profile so Reset Profile can't reach them: `restocker.listChoices` on global, and `char.ownedMacros`.
  - Rank Watch's reset listener resets `RESET_KEYS` and wipes `untracked` on `OnProfileReset`, even though `rankWatch` is global.
- **Seeding.** Nothing seeds a list on empty. `buffWindow.audience` and `selfRefresh` fill only keys the player never saved, from the rows' defaults (`PopulateBuffDutyAudience`). Values the dropdowns don't offer are dropped, but keys this client lacks are kept, since Era and Season of Discovery share the file. Staples writes its pre-ticks only when it opens. The Readiness panel's Reset writes every `readiness*` default back except the master switch.
- AceDB strips every value equal to its default at logout, so an empty default subtable is nil by the time the add-on's own logout handler runs.

### Migration Chain

Every piece is tagged `MIGRATION (remove after YYYY-MM-DD)` where it sits. In run order within `InitializeDatabase`: `MoveRenamedSettings`, `ImportLegacySettings`, `AceDB:New`, the prune, `UseOwnProfileWhenUnnamed`, `RetireAutomatedAppreciation`, `ns.RetireSavedItemCache`, `ns.RekeyCharactersByFullName`, `ns.MoveCharactersOntoOwnProfiles`, then the callbacks. The feature migrations run at login or on first use.

- **2026-11-18**: Buff Duty `petsAsTanks` / `petsAsTanksWhen` become `tankWhen.PET` (`Buff-Duty-Settings.lua`).
- **2026-11-21**:
  - Self buffs go from 5 minutes to 3 and Soulstone When Missing to 3, tracked by `buffWindow.selfRefreshMigrated` (`Buff-Duty-Settings.lua`; default in `Default-Settings.lua`).
  - The old `TFTBBuffGroup` key moves (`ns.MigrateBuffKeys`, `Buff-Duty-Keys.lua`).
- **2026-11-23**: Spellbook names from before the prefix (`LegacyMacroName`) and the `"claim"` / `"adopt"` ownership states (`Macro-Lookup.lua`, `Macro-Sync.lua`).
- **2026-11-26**:
  - The Spellbook's `~` prefix (`OLD_PREFIX`, `OldPrefixName`).
  - In `Spellbook-Core.lua` `OnPlayerLogin`: Custom Macros lists and `global.professionSkills` dropped, flat `trainerSpells` moved under the class, and macro records moved from `ns.db.keys.char` to `ns.MacroOwnerKey`.
- **2026-11-29**: Buff Duty's top-left position becomes top-right (`ns.MigrateBuffDutyPosition`, `Buff-Duty-Position.lua`, called from `ns.RenderBuffDuty`).
- **2026-12-03**:
  - The rename (`MoveRenamedSettings`, `ns.OLD_SAVED_VARIABLES_NAME`, the TOC entry).
  - The hidden `MACROSPELLBOOK_TOGGLE` binding and `ns.MigrateSpellbookBinding`.
  - The `TFTBBuffIndividual` alias and its key move.
- **2026-12-08**:
  - **Legacy import**: `ImportLegacySettings`, `LEGACY_IMPORTERS`, `OfferLegacySteps`, `GOODTOGO_LEGACY_IMPORT`, `ns.LEGACY_ADDONS`, the `IsLegacyImportPending` gate, `CHAT_LEGACY_*` / `POPUP_LEGACY_*` in every locale, the `.luacheckrc` popup field. `ns.REPLACED_ADDONS` and `TurnOffReplacedAddons` stay.
  - **Core retirements**: `RetireAutomatedAppreciation`; `ns.RetireSavedItemCache`, which clears the old per-profile item cache keys.
  - **Connoisseur & Restocker repairs**: `Character-Key-Migration.lua` (Forever list choices and inventory records re-keyed by whole name), then `Default-Profile-Migration.lua` (older Forever profile carried, characters moved off `Default`, list choices carried to `listChoices`), their TOC lines, and `noDefaultProfiles` in `Options-Profiles.lua`.
  - **Macro callbacks**: the `Connoisseur*` aliases (`Runtime.lua`, `.luacheckrc`).
  - **Rank Watch**: `ImportStandaloneSettings`, `StandaloneProfile`, `importedStandalone`, the `maxLevelOnly` removal in `ns.RankWatchSettings`, `RankSentinelDB` in `.luacheckrc`.
  - **Restocker**: the type-before-name saved line, empty legacy `Name-Realm` lists kept by the prune, `starterListDismissed` cleared, the guarded `ns.InitializeInventoryReport` call.
  - **Spellbook**: `markedPlaced` keyed by WoW macro name (`Page-Settings.lua`).

## Pitfalls & Why

**Macros**

- **Editing macros in combat**: silently blocked. Consumable Macros route through `ns.RequestUpdate()` and the Spellbook through `ns.QueueMacroSync`; both replay after combat.
- **Writing a macro while the Blizzard Macro UI is open**: its save-back reverts the write after the state key recorded it. Both features defer while `MacroFrame` is shown; never write around that guard.
- **A body input missing from the state key**: the macro silently goes stale. Keys are lossless, and override modes use disjoint prefixes.
- **Recording a state key when the write failed**: a full General tab blocks every retry. Keep `ns.WriteMacroBody`'s false return meaningful.
- **Passing a non-boolean `perCharacter` to `CreateMacro`**: the client boolean-checks it. Consumable macros omit it (General), and the Spellbook passes a real boolean.
- **Changing a shipped macro name** (`MACRO_*`, the Spellbook prefix): it creates a second macro and strands the old one on every bar. Macros are found by name.
- **Setting `ranked` without `ns.MULTI_USE_MACRO_TYPES`, or the reverse**: the scanner reads one and the engine the other. Set both, and only where every item shares one cooldown.
- **Moving a Consumable Macros handler below `OnEvent`'s combat guard**: it misses mid-fight changes, and signatures and baselines drift.
- **A new bag-reading override**: scroll, pet-buff, pet-food and poison selection bypass the scan's gates, so each checks `ns.IsIgnored` and usability itself. A new one must too.
- **Holding the aura snapshot**: `ns.GetPlayerBuffSnapshot()` returns one shared buffer the next call overwrites. Take one per pass and pass it down. While auras are secret it returns the last readable snapshot; never reset it to empty, which reads as "no buffs".
- **Keeping or writing scan output**: `ns.scannedItemCounts`, `ns.scannedItemLinks`, `ns.scannedIgnoredTypes` and `ns.bestSelection` are wiped and refilled in place every scan.
- **A new cast trigger for Consumable Macros**: `UNIT_SPELLCAST_SUCCEEDED` registration is decided once at login by class and race. Change both `ns.SpellCastChangesMacros` and that registration.
- **Iteration order in a pick**: `pairs()` order churns rewrites. `RANKING_PRIORITY` and the pet food pick both end on item ID.
- **Localizing `ns.IsOptionOn`, `ns.UseItemSlots`, `ns.WarnOnce` or `ns.HandOverMacro` as file locals in the Spellbook**: it breaks Message Length, which swaps those `ns` fields for one build.
- **Editing a Conditionals row or Cast Sequence step in place**: Duplicates share rows (`ns.DuplicateMacro` copies shallowly). Setters copy (`CopyRows`, `CopySteps`) and store fresh tables.
- **Holding an `ns.macros` entry across a change**: every refresh rebuilds them all. Re-find by `ns.SettingsKey`.
- **Two `ns:On<Event>` methods with one name**: the later file silently wins, since the Spellbook resolves handlers by name on the shared `ns`. Its pet and bag handlers are prefixed (`OnSpellbookUnitPet`) because `ns.OnUnitPet` belongs to Feed Pet.
- **Deleting by tag alone**: a player's own `#end` line looks like a tag. Delete requires a handed-out tag and an ownership record.
- **Reading a bar macro through `GetActionInfo`**: a macro showing a spell returns the spell ID. Use `GetActionText` (`ns.ActionMacroName`).
- **Matching stances or forms by tooltip text**: some locales name forms apart from their spells. Use the class lists' IDs.
- **Reading another class's `CLASS_SPELL_LISTS` or `TRAINER_SPELLS`**: `Class-Config.lua` empties them at load.
- **Turning the Spellbook off**: `RefreshMacros` no-ops for every caller, so macros freeze as written. Deliberate.
- **Right-Click For with a Conditionals `rightClick` row**: the two block each other. `MakeDefault` keeps it off per macro (`keepOff`).

**Secure frames and the client**

- **Changing a Buff Duty button outside `ns.SetBuffButtonAttributes`, or in combat**: pooled buttons keep stale attributes, and protected changes are blocked.
- **Casting a buff by spell ID or bare name**: on Classic Era a lower rank's ID casts nothing, and a bare group-buff name casts Rank 1. Cast by rank text; only resurrections and Create Soulstone go by bare name.
- **Closing Buff Duty through the template's close click**: it hides a protected parent. The button runs `ns.CloseBuffDuty`.
- **Shuffling the Buff Duty TOC order**: files capture earlier files' functions and tables at load (`Buff-Duty-Frame.lua` captures Icon-State and Party-Buffs, most files capture Castable's `ns.BuffDuty` and `RankFor`, several call `ns.SetBuffDutyEventHandler` at load). `Buff-Duty-Key-Picker.lua` looks up `BuffDuty.BuffKeySkipped` at call time on purpose, because Keys loads after it.
- **Shuffling the scanner TOC order**: `Scanner-Inventory.lua` captures `ns.ScanRanking` fields at load. Keep Ranking, Diagnostics, Inventory; `Engine.lua` captures `ns.MACRO_CONFIG`.
- **Aliasing `ns.MODE_VALUES` at load in `Minimap-Button.lua`**: it is nil there, since `Options-Utilities.lua` loads later. It is read at call time.
- **A list of possibly-nil sections in `ipairs`**: it stops at the first nil, dropping Return the Favor after an empty Target. Append sections one by one.
- **Parenting a frame to a Blizzard panel**: it stays protected for good. Parent to `UIParent` and anchor beside it, as every Spellbook launcher does.
- **`UIDropDownMenu` in the Restock List**: its shared globals leave taint. Use an AceGUI pullout that joins `ns.CloseRestockMenus`.
- **Registering `COMBAT_LOG_EVENT_UNFILTERED` on Forever**: `ADDON_ACTION_FORBIDDEN`, which `pcall` can't catch. It is in `ns.EVENT_NAMES` only off Camelot, and the combat-log files stay out of the Camelot TOC.
- **Calling `GetItemInfo`, `GetSpellInfo`, `UnitBuff`, `IsSpellKnown` or `IsPlayerSpell` as globals**: Forever has dropped them or keeps them only in a deprecation layer. Use `C_Item`, `C_Spell`, `C_UnitAuras`, `ns.IsSpellKnown`, `ns.IsPlayerSpell`.
- **An API one client lacks**: put it behind a `Features/Utilities.lua` accessor that answers nil there, with a Diagnostics row. `ns.OnReadyCheck` calls its probes unguarded, so one error silences the whole report on that client.
- **Mists APIs that exist but throw** ("API unsupported"): `GetNumTalentTabs` is gated on `ns.EXPANSION < 5`, and `GetNumSpecGroups` is tried before `GetNumTalentGroups`.
- **Comparing a secret value on Forever**: it errors. Test with `ns.IsPlain` or `ns.IsSecretValue`, and ask `ns.AreAurasSecret()` before reading auras.
- **Treating `NUM_BAG_SLOTS + 1` as the reagent bag**: on Era, TBC and Mists it is a bank bag. Use `ns.GetReagentBagID()` / `ns.CARRIED_BAG_IDS`.
- **The native `GetSpellLink` in chat**: on Classic the link lacks `:0` and the chat validator strips it. `ns.GetSpellLink` builds it by hand.
- **Fitting the mini-map icon with `SetButtonIcon`**: it errors when another add-on swapped the icon.
- **Reading `UnitLevel("player")` in a `PLAYER_LEVEL_UP` handler**: it still returns the old level. Every feature passes the event's argument.
- **Testing a new file with `/reload`**: the client reads a TOC's file list only at startup. Restart the client.

**Restocker**

- **`UseContainerItem` while a merchant is open**: it sells. The bank run aborts on `ns.merchantIsOpen`, and the merchant code has no sell path.
- **`PutItemInBag` or `PutItemInBackpack` in the bank run**: both clear the cursor even when the server refuses, so "did it land" always reads yes. Name an empty slot (`BagDefinition:PutCursorItem`).
- **Leaving a split on the cursor**: the next split fails. Every placement path ends in `ClearCursor()`.
- **Deducting from a plan optimistically**: a move that didn't land goes unnoticed. The run rescans every step, and the watchdog stops it.
- **Live-reading Keep during a bank run**: a half-typed number would move stock, and an empty box saves 0 (store everything). Read `RestockState:Wanted`; Enter restarts the run.
- **Treating a row as a table after `DeflateRestockItemsForSave`**: it is a string by then, which is why it runs last at logout.
- **Folding a default-on flag into `x and false or nil`**: it yields nil for every input, so the off state never saves (see `ItemFromString`).
- **Counting items by name**: an unresolved name reads as 0 and buys a full stack. Count by item ID.
- **Parking an add under a link**: the retry looks up by numeric item ID.
- **Counting bank stock in the reagent order**: the add-on stashes the excess itself, so the reagents would never be bought. `BuildCraftingPurchaseOrder` counts bags only.
- **A `_CLOSED` event with no open**: loading screens fire them. Close handlers key off `merchantIsOpen` / `bankIsOpen`.
- **Closing pooled-row menus late**: a pick lands on a rebound row. `UpdateRestockList` closes menus first.
- **Re-reading a Staples row's `chainKey`**: it is replaced by `row.chain` at load.
- **A Restocker handler that skips `WhileEnabled`**: it runs with the feature off; only logout runs unwrapped. The Inventory Report rides the same dispatcher, so a Restocker event change can affect it.

**Saved data and characters**

- **The prune runs before the Connoisseur & Restocker repairs**: a key shape the prune reads as another client's is gone before any migration sees it. Forever's older `First - RuleSet` keys survive only through `IsOlderForeverKey` (`Features/Core.lua`); a new migration reading another such key needs the same exemption.
- **Indexing a default subtable at logout**: AceDB has already stripped empty defaults. Write whole values, as `ns.SaveRestockWindowGeometry` does.
- **Changing a shipped default**: AceDB stripped every value equal to the old default, so every player still on it moves to the new one.
- **Reusing a retired key's name**: whatever players saved under the old meaning reads straight back.
- **Mixing the two character keys**: AceDB profile names and `ns.GetCharacterKey()` differ in shape. Go through the readers in `Features/Utilities.lua`.
- **Naming a character with `UnitName` alone**: on Forever that is the first name only. Use `ns.GetPlayerFullName` / `ns.GetCharacterKey`.
- **Putting a setting in the wrong scope**: the profile is one character's own. Add to global only for a concrete account-wide reason, written beside the key.
- **Two features declaring one default**: `AddDefaults` stops the load.
- **Calling `ns.RankWatchSettings()` from a probe**: it writes (a migration). Diagnostics reads `global.rankWatch` directly.
- **A remembered item miss outliving its answer**: the item is stranded for the session. Every answer reaches `ns.ForgetItemDataMiss` first, and anything parked on an item keeps its waiter keyed in (`ns.SyncRestockItemInfoSubscription`). A new waiter must release its key, or `GET_ITEM_INFO_RECEIVED` stays registered.

**Messages and data**

- **A `|4` plural escape in a sent line**: `SendChatMessage` drops the whole line, and nothing on the send path resolves it. Run client duration strings through `ns.FormatDuration`.
- **Whispering a line built for group chat**: on Forever it loses the Star. A whispered Buff Duty ask passes `isWhisper` to `ns:BuildBuffRequestMessage`.
- **Rank Watch on Mists**: absent by TOC, not by empty data. A new outside caller must test that the function exists.
- **Rerunning `Tools/Build-Rank-Watch-Abilities.py`**: it merges onto the shipped tables, keeping every row and ability they hold (off ladders, level-less rows, Forever's corrections) and their How We Got the Data block; it adds a Rank Sentinel rank only when the flavor's own Trainer-Spells or Class-Spell-Lists knows the spell, and prints what it kept, added and left out. On unchanged sources it rewrites every file byte for byte. A row its reader can't parse stops it rather than being dropped. The pet tool leaves Camelot untouched without `--wago`.
- **Editing one flavor folder's copy of a row**: the seven copies are separate. Check the ID in every folder.
- **An all-clear line in the Readiness Report**: silence is the feature.
- **Legacy popup Escape**: means "ask again next login", not decline (`noCancelOnEscape`).
