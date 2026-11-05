# Good to Go // Technical Reference

This document combines architecture notes and contribution guidance for developers working on Good to Go. For end-user documentation, see [README.md](https://github.com/Gogo1951/Good-to-Go/blob/main/README.md).

## File Map

```
Good-to-Go/
├── .gitattributes                                  Shared from Common-Core
├── .github/                                        The issue forms and the three Common-Core callers
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml                              Started from Common-Core, kept per add-on: the blank-issue, Discord and CurseForge links
│   │   ├── defect.yml                              Shared from Common-Core: the Defect form, whose Issue Type picks a label
│   │   └── request.yml                             Shared from Common-Core: the Request form
│   └── workflows/
│       ├── ci.yml                                  Calls Common-Core: shared files, LF storage, externals, Lua 5.1 syntax, luacheck and StyLua
│       ├── issue-labels.yml                        Calls Common-Core: labels a new Defect by its Issue Type
│       └── package.yml                             Calls Common-Core: library refresh, then the CurseForge and Wago release
├── .gitignore                                      Shared from Common-Core
├── .luacheckrc                                     Lint config; every WoW global read, and the add-on's own globals
├── .pkgmeta                                        Externals, and the ignore list that keeps Data/Wrath/ and Data/Mainline/ out of the zip
├── Bindings.xml                                    Toggle Enhanced Spellbook, the Buff Key, and two hidden bindings kept for a migration
├── Data/                                           Static game data and the ID-free constants
│   ├── Camelot/                                    WoW Forever's tables
│   ├── Data.lua                                    Locale init, palette, registry names, ceilings, marker, macro config, Staples rows, Buff Duty choices
│   ├── Default-Settings.lua                        ns.DATABASE_DEFAULTS, each feature's block added through AddDefaults
│   ├── Discovery/                                  Season of Discovery's tables; the Vanilla TOC lists them after Data/Vanilla/
│   ├── Flavor.lua                                  Flavor identity and the data folder this client built; canonical copy
│   ├── LICENSE-Pet-Data                            MIT notice for Tamed, the source of the pet ability and tameable beast rows
│   ├── LICENSE-Trainer-Data                        MIT notice for What's Training, the source of the trainer spell rows
│   ├── Mainline/                                   Forward-prep; no TOC lists it, and .pkgmeta ignores it
│   ├── Mists/                                      Mists of Pandaria Classic's tables
│   ├── TBC/                                        TBC Anniversary's tables
│   ├── Vanilla/                                    Classic Era's tables; each file opens with the Season of Discovery guard
│   └── Wrath/                                      Forward-prep; no TOC lists it, and .pkgmeta ignores it
├── Diagnostics/                                    Diagnostic Tools, off at every login and never saved
│   ├── Code-Reports.lua                            Event Registration, API Endpoints and Library Versions reports
│   ├── Diagnostics-Core.lua                        ns.diagnostics runtime state, the plain-English strings, the enable gate
│   ├── Event-Log.lua                               The 500-entry event ring buffer and the Taint Log toggle
│   ├── Localization-Reports.lua                    Locale context and the Game Names lookups
│   ├── Manifests-Automated-Appreciation.lua        API rows, context and emote reports, ns.DIAGNOSTIC_MESSAGES, Buff Duty's data sources too
│   ├── Manifests-Buff-Duty.lua                     Buff Duty context report
│   ├── Manifests-Inventory-Restocker.lua           Restocker API rows and context report
│   ├── Manifests-Macros-for-Consumables.lua        API rows, Consumable Macros, Item Selection and Readiness reports, lookups, data sources
│   ├── Manifests-Spellbook.lua                     API rows, page and macro context reports, lookups, data sources
│   ├── Manifests.lua                               The shared manifest tables and ns.AppendDiagnosticRows
│   ├── Message-Length-Automated-Appreciation.lua   Every sent message at its widest, against 255 bytes
│   ├── Message-Length-Macros-for-Consumables.lua   Consumable macro bodies at their longest
│   ├── Message-Length-Spellbook.lua                Spellbook macros with every option on
│   ├── Options-Diagnostics.lua                     The Diagnostic Tools panel
│   ├── Report-Runner.lua                           Report registry and tabs; one Validate Data report per data file
│   ├── Settings-Reports.lua                        Display, other add-ons and saved-variables reports
│   └── Validate-Data.lua                           Looks every data row up on this client and prints TSV for the Data Review
├── Features/                                       Every feature, one folder each; Core.lua owns the event frame
│   ├── Announcements.lua                           PrintMessage, the branded sent format, emotes, Good News queue and plural resolution
│   ├── Automated-Appreciation/                     Praise, Service Alerts, Good News and the Thank You Button
│   │   ├── Automated-Appreciation-Core.lua         Feature switches, the event module, the firehose on/off logic
│   │   ├── Automated-Appreciation-Utilities.lua    The client's own emote list and the buff sound
│   │   ├── Buff-Tracking-Combat-Log.lua            Buffs from others through the combat log; every TOC but Camelot's
│   │   ├── Buff-Tracking-Forever.lua               Buffs from others through UNIT_AURA; the Camelot TOC only
│   │   ├── Buff-Tracking.lua                       The 3-second safety pause, pet owners, Service Alerts
│   │   ├── Good-News.lua                           Whispers for buffs you cast, by the SENT then SUCCEEDED handshake
│   │   ├── Praise.lua                              Cooldown table, 45-second whisper floor, ns.HandleTracked and ns.HandleStrangersBuff
│   │   ├── Thank-You-Button.lua                    The five Thank You macros and ns.RunThankYou
│   │   └── Tracked-Lookups.lua                     Aura, cast and given lookups from ns.TRACKED_ABILITIES; seeds the watched lists
│   ├── Buff-Duty/                                  The click-to-cast window of buffs you can give
│   │   ├── Buff-Duty-Auras.lua                     GUID-keyed aura cache, dirty and generation flags, Has, bounce memory
│   │   ├── Buff-Duty-Button-Attributes.lua         Secure attributes for one spec, shared by the window and the Buff Key
│   │   ├── Buff-Duty-Cast-Results.lua              Aura-bounced errors, and the Forever resurrection note
│   │   ├── Buff-Duty-Castable.lua                  ns.BuffDuty, the castable buff list, RankFor
│   │   ├── Buff-Duty-Events.lua                    The event module and its subscriptions; loads first
│   │   ├── Buff-Duty-Frame.lua                     Window frames, secure icon pool, layout, redraw signature, Hide in Combat
│   │   ├── Buff-Duty-Groups.lua                    Party sections and group-buff icons
│   │   ├── Buff-Duty-Icon-State.lua                Icon pool, cooldown swipes, time-left slivers, the 0.5-second range ticker
│   │   ├── Buff-Duty-Key-Picker.lua                What the Buff Key casts next
│   │   ├── Buff-Duty-Keys.lua                      The hidden GtGBuffKey secure button and its skip memory
│   │   ├── Buff-Duty-Lookups.lua                   Data rows to live entries, options categories
│   │   ├── Buff-Duty-Other-Classes.lua             Party-Buffs counts of missing raid buffs, and the asks
│   │   ├── Buff-Duty-Outsiders.lua                 The Target and Return the Favor sections
│   │   ├── Buff-Duty-Pets.lua                      Pet rows and pet owner class
│   │   ├── Buff-Duty-Position.lua                  Window position, saved by its top-right corner
│   │   ├── Buff-Duty-Resurrections.lua             Resurrection icons and the 60-second pending suppression
│   │   ├── Buff-Duty-Self.lua                      Self Buffs and the Soulstone icon
│   │   ├── Buff-Duty-Settings.lua                  Seeds and cleans the audience, self, weapon and tank settings
│   │   ├── Buff-Duty-Party-Buffs.lua               The Party-Buffs icons and their tooltip
│   │   ├── Buff-Duty-Units.lua                     Who can be buffed, roles, range, labels, SingleIcon
│   │   ├── Buff-Duty-Weapons.lua                   Weapon-enchant rows and the REPLACE_ENCHANT auto-accept
│   │   └── Buff-Duty.lua                           Refresh, 0.3-second debounce, 3-second backstop, ShowsHere, setup
│   ├── Core.lua                                    ns.EVENT_NAMES, the one event frame, database lifecycle, legacy import, welcome
│   ├── Inventory-Report/                           Every character's bags and bank, shown in item tooltips
│   │   ├── Inventory-Report-Recording.lua          Per-character snapshots, packed one line per place
│   │   └── Inventory-Report-Tooltip.lua            The tooltip block, hooked 5 seconds after login
│   ├── Inventory-Restocker/                        The Restock List: merchant buying, bank restocking, reminders
│   │   ├── Restocker-Bags.lua                      Bag and bank containers, slot scans, single-move primitives
│   │   ├── Restocker-Bank-State.lua                Bank open state, the run's frozen targets, bank open and close
│   │   ├── Restocker-Bank-Tidy.lua                 Merges partial bank stacks once every target is met
│   │   ├── Restocker-Bank-Visit.lua                The bank run's coroutine, one move per paced tick, watchdogs
│   │   ├── Restocker-Crafting-Reagents.lua         Poison recipe index and the all-or-nothing reagent order
│   │   ├── Restocker-Events.lua                    Login init, one handler per event, the master switch
│   │   ├── Restocker-Inventory-Model.lua           The summary and slots model a scan returns
│   │   ├── Restocker-List.lua                      Adding items, cold-item queues, ns.OnRestockerItemInfoReceived
│   │   ├── Restocker-Merchant.lua                  Purchase orders, money and bag budgets, the buy loop
│   │   ├── Restocker-Purchase-Space.lua            The bag-space budget a merchant run spends down
│   │   ├── Restocker-Reminders.lua                 Reminder text and the in-town arrival reminder
│   │   ├── Restocker-Saved-Format.lua              One-line saved-row codec, inflated at login, packed at logout
│   │   ├── Restocker-Saved-Lists.lua               Named lists and each character's choice
│   │   ├── Restocker-Shortfall.lua                 The grocery list and the after-visit reminder
│   │   ├── Restocker-Slash-Command.lua             The /restock parser
│   │   ├── Restocker-Starter-List.lua              Staples logic: rows, ticks, stack counts, the login trigger
│   │   ├── Restocker-Starter-Window.lua            The Staples window
│   │   ├── Restocker-Trace.lua                     RESTOCKER_TRACE entries into the Event Log
│   │   ├── Restocker-Upgrade.lua                   Level-ladder upgrades
│   │   ├── Restocker-Window-Bag-Menu.lua           Add Item From Bags menu
│   │   ├── Restocker-Window-Categories.lua         Item-type pane
│   │   ├── Restocker-Window-Column-Header.lua      Header row
│   │   ├── Restocker-Window-Columns.lua            Column grid and metrics
│   │   ├── Restocker-Window-Filter.lua             Grouping and filtering, pure data
│   │   ├── Restocker-Window-Footer.lua             Orders status and the undo offer
│   │   ├── Restocker-Window-Frame.lua              Shared portrait frame and bands
│   │   ├── Restocker-Window-Header.lua             Filter, add box, Pick Staples
│   │   ├── Restocker-Window-List-Bar.lua           List selector, Manage, Used by, rename
│   │   ├── Restocker-Window-Menus.lua              Reputation and column menus, AceGUI pullouts
│   │   ├── Restocker-Window-Render.lua             Redraw and the cold-row watch
│   │   ├── Restocker-Window-Reputation.lua         Standing labels and discount text
│   │   ├── Restocker-Window-Rows.lua               Keep box, toggle cells, remove and undo
│   │   ├── Restocker-Window-Widgets.lua            Menu closing, cursor drop-add, tooltips
│   │   └── Restocker-Window.lua                    Window build, geometry, show, hide, toggle
│   ├── Item-Info.lua                               Session C_Item.GetItemInfo memo and the shared GET_ITEM_INFO_RECEIVED waiters
│   ├── Macros-for-Consumables/                     The consumable macros: scan, rank, compose, write
│   │   ├── Action-Button-Text.lua                  Macro-name text on action buttons, by font-string alpha
│   │   ├── Character-Key-Migration.lua             MIGRATION only: Forever characters re-keyed by whole name
│   │   ├── Default-Profile-Migration.lua           MIGRATION only: characters moved off the shared Default profile
│   │   ├── Ignore-List.lua                         Character and Global Ignore Lists
│   │   ├── Item-Cache.lua                          Persisted per-profile item cache and the cold-item retry budget
│   │   ├── Macros/                                 One definition per macro, the engine and the writer
│   │   │   ├── Bandage.lua
│   │   │   ├── Body-Builder.lua                    Standard body, state key, the 255-byte trims
│   │   │   ├── Definitions.lua                     The definition protocol and registry
│   │   │   ├── Engine.lua                          ns.UpdateMacros, state keys, the Macro UI deferral
│   │   │   ├── Explosive.lua                       The at-player or toss click layout
│   │   │   ├── Food.lua                            Scroll mode, Stealth Eating and Cannibalize blocks
│   │   │   ├── Health-Potion.lua                   Healthstone-only body in an arena; food out of combat
│   │   │   ├── Healthstone.lua
│   │   │   ├── Integration-Druid-Macro-Helper.lua  Wraps potion and healthstone bodies in DruidMacroHelper lines
│   │   │   ├── Mana-Gem.lua
│   │   │   ├── Mana-Potion.lua                     Mana runes; water out of combat
│   │   │   ├── Runtime.lua                         GtGFire, GtGTip, GtGTipIf, GtGNoItem, GtGReplace
│   │   │   ├── Signatures.lua                      Target and group change signatures
│   │   │   ├── Smart-Spell.lua                     Conjure rank pick and downranking
│   │   │   ├── Soulstone.lua
│   │   │   ├── Tools-Forsaken.lua                  Cannibalize gating and its cooldown rebuild
│   │   │   ├── Tools-Hunters-Pet-Food.lua          Pet food scan and pet buff food
│   │   │   ├── Tools-Hunters.lua                   The Feed Pet macro and its pet-spell tiers
│   │   │   ├── Tools-Mages.lua                     Conjure resolvers for food, water and mana gems
│   │   │   ├── Tools-Rogues.lua                    The Poisons macro
│   │   │   ├── Tools-Warlocks.lua                  Conjure resolvers for healthstones and soulstones
│   │   │   ├── Water.lua                           Shadowmeld Drinking and Cannibalize drinking
│   │   │   └── Writer.lua                          ns.WriteMacroBody, the one writer; General-tab creation
│   │   ├── Macros-for-Consumables-Core.lua         Event module, the two-flag 0.5-second throttle, profile re-apply
│   │   ├── Macros-for-Consumables-Utilities.lua    Mode test, max level, Well Fed and First Aid names
│   │   └── Scanner/                                The bag scan and the ranking ladder
│   │       ├── Scanner-Auras.lua                   Shared aura snapshot, buff probes, early re-application
│   │       ├── Scanner-Character.lua               Class and race flags, spell names, profession ranks
│   │       ├── Scanner-Diagnostics.lua             Item Selection candidates, kept only while Diagnostics is on
│   │       ├── Scanner-Inventory.lua               ns.ScanBags: the bag walk, usability gates, dispatch
│   │       ├── Scanner-Ranking.lua                 RANKING_PRIORITY and the ranked lists
│   │       └── Scanner-Scrolls.lua                 Scroll overrides
│   ├── Minimap-Button.lua                          The one LDB object and mini-map button every feature shares
│   ├── Readiness-Report/                           The private report printed on a ready check
│   │   ├── Readiness-Report-Example.lua            The options panel's sample line
│   │   ├── Readiness-Report-Probes.lua             Stateless live reads
│   │   └── Readiness-Report.lua                    Line assembly and the READY_CHECK module
│   ├── Spellbook/                                  Enhanced Spellbook: its own window, macros per spell, What's Next
│   │   ├── Action-Bars.lua                         Which macros and spells sit on the 180 action slots
│   │   ├── Category-Menu.lua                       A category header's menu, applied to every macro under it
│   │   ├── Class-Config.lua                        ns.CLASS_SPELL_LISTS resolved to client names
│   │   ├── Class-Spells.lua                        ns.ForEachClassSpell, read from the book
│   │   ├── Consumable-Macros.lua                   Consumable Macros' macros on the page, read-only
│   │   ├── Dynamic-Rank.lua                        Target and mouseover rank rewrites, out of combat only
│   │   ├── Group-Handover.lua                      A replaced spell hands its macro to its successor
│   │   ├── Grouped-Spells.lua                      ns.SPELL_GROUPS ticks
│   │   ├── Key-Bindings.lua                        Binding globals and GoodToGo_ToggleSpellbook
│   │   ├── LICENSE-Spellbook                       MIT notice shipped with the Spellbook folder
│   │   ├── Macro-Body.lua                          Macro text generation
│   │   ├── Macro-Builder/                          ns.macros, Conditionals, Cast Sequence and the docked panels
│   │   │   ├── Cast-Sequence-Panel.lua             The docked Cast Sequence panel
│   │   │   ├── Cast-Sequence.lua                   Cast Sequence data and its tail
│   │   │   ├── Conditionals-Panel.lua              The docked Conditionals panel
│   │   │   ├── Conditionals-Pick.lua               Spell pick mode
│   │   │   ├── Conditionals-Rows.lua               Conditionals panel rows
│   │   │   ├── Conditionals.lua                    Conditionals rows and clauses
│   │   │   ├── Docked-Panel.lua                    The docked panels' shared shell and byte meter
│   │   │   ├── Macro-Builder.lua                   ns.CollectMacros builds ns.macros
│   │   │   └── Panel-Widgets.lua                   Controls the docked panels share
│   │   ├── Macro-Button-Notes.lua                  Tile notes and tooltip wording
│   │   ├── Macro-Button.lua                        A macro tile: click, drag, tooltip, glow
│   │   ├── Macro-Copies.lua                        Duplicate copies
│   │   ├── Macro-Delete.lua                        Delete one macro or all the add-on made
│   │   ├── Macro-Kinds.lua                         The eight macro kinds and their defaults
│   │   ├── Macro-Menu-Sections.lua                 Right-click menu sections
│   │   ├── Macro-Menu-Utilities.lua                Right-click menu helpers
│   │   ├── Macro-Menu.lua                          The right-click menu
│   │   ├── Macro-Options.lua                       Per-spell options and the OFFERED predicates
│   │   ├── Macro-Sync.lua                          Find, create and rewrite WoW macros; slots, 255 guard, combat queue
│   │   ├── Macro-Tags.lua                          The #XX tag line and the account-wide tag register
│   │   ├── Menu-Utilities.lua                      Menu pieces shared with the category menu
│   │   ├── Mute-Errors.lua                         GtGMute
│   │   ├── Page-Categories.lua                     ns.PAGE_CATEGORIES
│   │   ├── Page-Settings.lua                       Page settings and Mark All Placed
│   │   ├── Ranged-Attacks.lua                      Folds the ranged attacks into one Shoot macro
│   │   ├── Spell-Ranks-Tooltip.lua                 What's Next ranks under the game's spell tooltips
│   │   ├── Spell-Ranks.lua                         Known and unknown ranks and learn levels
│   │   ├── Spellbook-Controls.lua                  Filter box, dropdowns, gear, legend, slot counts
│   │   ├── Spellbook-Core.lua                      Master switch, event module, login migrations
│   │   ├── Spellbook-Events.lua                    Next-frame coalesced redraws and macro syncs
│   │   ├── Spellbook-Host-Classic.lua              Launcher tab on SpellBookFrame; Vanilla, TBC and Mists TOCs
│   │   ├── Spellbook-Host-Modern.lua               Launcher on the Retail-engine book; Camelot TOC only
│   │   ├── Spellbook-Page-Layout.lua               Row packing and pagination
│   │   ├── Spellbook-Page-Parchment.lua            Parchment art
│   │   ├── Spellbook-Page.lua                      The Spell Book tab: order, categories, columns, refresh
│   │   ├── Spellbook-Paging.lua                    The page strip
│   │   ├── Spellbook-Tabs.lua                      Tab placement beside the Retail-engine book; Camelot TOC only
│   │   ├── Spellbook-Utilities.lua                 HAS_SPELL_RANKS, Cyrillic folding, TrimMacroName
│   │   ├── Spellbook-Window.lua                    GoodToGoSpellbookFrame and its four tabs
│   │   ├── Target-Priority.lua                     The target-priority option
│   │   ├── Trainer-Lookup.lua                      A trainer service's spell ID
│   │   ├── Trainer-Recording.lua                   Records class trainer services into the profile
│   │   ├── Unlearned-Spells.lua                    ns.ForEachUnlearnedSpell
│   │   ├── Usable-Items.lua                        Equipped Use: items
│   │   └── Whats-Next/                             The What's Next and pet tabs
│   │       ├── Pet-Spellbook.lua                   The Pet Spell Book tab
│   │       ├── Whats-Next-Controls.lua             What's Next controls
│   │       ├── Whats-Next-Layout.lua               What's Next layout
│   │       ├── Whats-Next-Models.lua               The three page models; tameable beasts
│   │       ├── Whats-Next-Page.lua                 What's Next page frame
│   │       ├── Whats-Next-Pet.lua                  Pet ability rows
│   │       └── Whats-Next.lua                      Class rows and their statuses
│   └── Utilities.lua                               Colors, client-difference accessors, secret-value tests, character names and keys
├── Good-to-Go_Camelot.toc                          WoW Forever
├── Good-to-Go_Mists.toc                            Mists of Pandaria Classic
├── Good-to-Go_TBC.toc                              TBC Anniversary
├── Good-to-Go_Vanilla.toc                          Classic Era, Season of Discovery included
├── Includes/                                       Vendored libraries and art
│   ├── Images/                                     Icon and window art
│   ├── Libraries/                                  Vendored libraries, refreshed from .pkgmeta at release
│   └── Sounds/                                     Buff.ogg and Low-Battery.ogg
├── LICENSE                                         MIT; .pkgmeta keeps it out of the zip
├── Locales/                                        AceLocale strings; enUS.lua is the source of truth
├── Options/                                        AceConfig panels, one per feature
│   ├── Automated-Appreciation/                     Stranger Buffs, Combat Buffs, Good News, Service Alerts, Thank You Button
│   ├── Buff-Duty/                                  Buff Duty and its three sub-panels
│   ├── Inventory-Report/                           Switch and Recorded Characters
│   ├── Inventory-Restocker/                        Restocker panel
│   ├── Macros-for-Consumables/                     Consumable Macros, Class & Race, Ignore List
│   ├── Options-Feedback-Support.lua                Level Up note, the four links, the version line
│   ├── Options-General.lua                         Root panel: welcome, mini-map, feature switches, key bindings, /Commands
│   ├── Options-Profiles.lua                        Stock AceDBOptions table, with noDefaultProfiles for a migration
│   ├── Options-Utilities.lua                       Row builders, feature switch rows, item lists, custom AceGUI widgets
│   ├── Options.lua                                 Registration, ns:OpenOptionsPanel and its combat guard, slash commands
│   ├── Readiness-Report/                           Readiness Report switches
│   └── Spellbook/                                  Spellbook switch, tooltip ranks, Delete Macros
├── README-Notes.md                                 Where Good to Go departs from the Style Guide
├── README-Technical.md                             This document
├── README-Testing.md                               Manual test plan
└── README.md                                       End-user documentation
```

**Static game data lives in seven flavor folders, one complete copy per flavor** (Style Guide → DATA → Flavor Folders). Each TOC lists `Data/Flavor.lua`, `Data/Data.lua`, its own folder, then `Data/Default-Settings.lua`, which reads the folder's tables. The Vanilla TOC lists `Data/Vanilla/` and then `Data/Discovery/`. Their files open with opposite `ns.IS_DISCOVERY` guards, so a Season of Discovery realm builds only Discovery's tables. No TOC lists `Data/Wrath/` or `Data/Mainline/`: they are forward-prep, and `.pkgmeta` keeps them out of the zip. Every folder declares the same tables whole, an empty one where the flavor has no rows, so feature code never checks which flavor built a table. How each folder's rows were chosen is in that file's closing `How We Got the Data` block, never here.

**The four TOCs differ in three files.** The Camelot TOC loads `Buff-Tracking-Forever.lua` in place of `Buff-Tracking-Combat-Log.lua`, and `Spellbook-Tabs.lua` plus `Spellbook-Host-Modern.lua` in place of `Spellbook-Host-Classic.lua`. Vanilla, TBC and Mists load the same feature files. The interface numbers are 11509 (Vanilla), 20506 (TBC), 16001 (Camelot) and 50504 (Mists).

**Names.** The installed folder, `ADDON_NAME` and the AceLocale name are all `Good-to-Go` (every locale file's `NewLocale` literal). The SavedVariables table is `GoodToGoDB` (`ns.SAVED_VARIABLES_NAME`). Players see the Full Name `Good to Go` (`ADDON_TITLE`) and the Short Name `GtG` (`ADDON_SHORT_NAME`). Global names carry `GoodToGo` for frames, bindings and popups, and the shorter `GtG` for anything a macro body calls, where every byte counts against the 255-byte ceiling.

**Good to Go replaces three add-ons**, and much of its migration code exists to bring their players over: Connoisseur & Restocker (Consumable Macros, the Restock List, the Inventory and Readiness Reports), Thanks for the Buff (Automated Appreciation and Buff Duty) and Macro Spellbook (the Enhanced Spellbook). The table name before the rename to Good to Go was `BagsBuffsButtonsDB`.

## Architecture

### Event Loop

**One frame for the whole add-on.** `Features/Core.lua` owns the only event frame, so the Diagnostics Event Log taps every event in one place. `ns.EVENT_NAMES` lists every event the add-on uses. `COMBAT_LOG_EVENT_UNFILTERED` is appended only when `ns.FLAVOR ~= "Camelot"`, because registering it on WoW Forever raises `ADDON_ACTION_FORBIDDEN`. Diagnostics' Event Registration report reads the same list, so the dispatcher and the report cannot drift.

Each feature is an **event module** with a dispatcher of its own:

```lua
ns.RegisterEventModule("Restocker", function(event, ...) ... end)
ns.SetModuleEvent("Restocker", "MERCHANT_SHOW", true)          -- subscribe
ns.SetModuleEvent("ConsumableMacros", "UNIT_PET", true, "player") -- unit-filtered
ns.SetModuleEvent("Restocker", "MERCHANT_SHOW", false)         -- release
```

`ns.SetModuleEvent` asserts the event is in `ns.EVENT_NAMES` and the module exists, so a typo stops the load instead of silently never firing. The frame registers an event once, while any module wants it. It uses `RegisterUnitEvent` only while every subscriber filters to the same two units or fewer; otherwise it registers unfiltered and the dispatch loop filters by the event's first argument. Modules hear an event in the order they loaded. The modules are `ItemInfo`, `ConsumableMacros`, `ReadinessReport`, `Restocker`, `AutomatedAppreciation`, `ThankYouMacros`, `BuffDuty` and `Spellbook`.

**Features subscribe only while they are on.** Each master switch subscribes and releases its feature's events, so a feature that is off costs nothing per event. `GET_ITEM_INFO_RECEIVED` is the clearest case: it floods during login, so `ItemInfo` registers it only while some waiter is keyed in (Item Data Caching). Several features keep their own one-handler-per-event table behind their module (`ns.SetBuffDutyEventHandler`, `ns.SetEventHandler` for Automated Appreciation, `ns.restockerEventHandlers`, the Spellbook's `ns:On<Event>` lookup). A second handler for the same event in one of those tables silently replaces the first.

**Lifecycle.** Core handles `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD` and `PLAYER_LOGOUT` itself, before any module, and keeps them registered whoever subscribes:

1. `PLAYER_LOGIN`: `InitializeDatabase()` (the migrations, `AceDB:New`, the profile callbacks), then `ns.RegisterOptionsPanels()` (the Profiles panel binds to `ns.db`), then `ns.RegisterMinimapIcon()`. Only then does each module hear `PLAYER_LOGIN`. None of this touches a protected function, so it runs even on a login mid-combat.
2. `PLAYER_ENTERING_WORLD`: the welcome line, once per session, since this event refires on every loading screen.
3. `PLAYER_LOGOUT`: saves the session's profile choice under the character's real name (Characters and Profiles).

**Each feature paces its own work:**

| Feature | Pacing |
|---|---|
| Consumable Macros | Two-flag OnUpdate throttle, 0.5 s after the first request of a burst (not debounced to the last) |
| Buff Duty | One `C_Timer.After(0.3)` refresh flag; a 3 s backstop ticker for expiry, deaths and disconnects that fire no event; a 0.5 s range ticker |
| Enhanced Spellbook | Next-frame coalescing (`C_Timer.After(0, ...)` behind a pending flag) per kind of work; a 0.2 s mouseover poll for Dynamic Rank |
| Restock List | None per event; a 1 s guard against a doubled `MERCHANT_SHOW`, and a latency-paced OnUpdate for the bank run |
| Automated Appreciation | A 3 s safety pause after setup and every loading screen; per-source cooldowns |

### Combat Lockdown

**The options opener refuses outright.** `ns:OpenOptionsPanel` checks `InCombatLockdown()` first, prints `CHAT_OPTIONS_IN_COMBAT` and returns. It never queues the open, so the slash command, the mini-map's Shift + Middle-Click and `/restock config` all answer the same way.

What each feature does instead:

- **Consumable Macros defer.** Macro writes are blocked in combat. `ns.RequestUpdate` in combat sets `isUpdatePending` without arming the tick; an armed tick that finds combat disarms itself; events below the module's combat guard just set the flag. `PLAYER_REGEN_ENABLED` re-requests. A forced rebuild keeps its force across the wait because `ns.UpdateMacros(true)` wipes its state keys before the combat check. The same pending flag covers the Blizzard Macro UI (State Encoding). Some inputs are recorded mid-combat on purpose (the target and group signatures, the pet-food quest signature, the scroll aura baseline), so a value that changes and changes back during a fight is not read as unchanged afterward.
- **The Enhanced Spellbook defers its syncs and refuses its actions.** `SyncAllMacros` in combat calls `QueueMacroSync`, and `PLAYER_REGEN_ENABLED` runs `ns:RefreshMacros`. Picking a macro up (which can create it), both deletes, spell pick mode and opening Key Bindings refuse with `ERR_NOT_IN_COMBAT` or a print. `PLAYER_REGEN_DISABLED` runs `RewriteRanksBeforeCombat`, the last moment Dynamic Rank macros can change.
- **Buff Duty's buttons are secure.** A secure button's attributes, position and visibility change only out of combat; alpha and its cooldown children may change in combat. Refresh, render, hide, the settings apply and drag-start all refuse in combat. A settings change queues behind `settingsPending`. A roster or target change marks the window stale, which dims every icon to alpha 0.35 until the next render. `PLAYER_REGEN_ENABLED` re-applies pending settings, marks every aura dirty and refreshes. Hide in Combat is a state driver (`[combat] hide; show`), so the client hides the window without the add-on touching a protected frame.
- **Thank You macros defer.** `ReconcileMacros` in combat subscribes the `ThankYouMacros` module to `PLAYER_REGEN_ENABLED` and runs then.
- **The Inventory Report defers one scan.** `BAG_UPDATE_DELAYED` in combat sets `bagsChangedInCombat`, and `PLAYER_REGEN_ENABLED` rescans.
- **The Restock List has no combat guard.** Nothing it does is protected, a merchant or bank window cannot open in combat, and a logout mid-combat must still pack the lists.
- **The Readiness Report doesn't wait for combat** but goes silent while auras are secret on WoW Forever.

### Scan → Rank → Compose → Write

The Consumable Macros pipeline, from `ns.UpdateMacros` (`Macros/Engine.lua`):

1. **Scan** (`ns.ScanBags`, `Scanner/Scanner-Inventory.lua`). Refresh the map ID; take **one** aura snapshot (`ns.UpdateAuraTracking`); work out `inArena`, whether the player targets themself, and the mode gates (`ns.allowBuffFood`, `ns.allowConjuredFirst`, `ns.allowRestockLast`); set the scan's Restock List. Walk bags `0..NUM_BAG_SLOTS` into item counts and slots, published read-only as `ns.scannedItemCounts` and `ns.scannedItemLinks`. Outside arenas, find the scroll and pet-buff overrides. Per item: skip scrolls, get or build its cache entry, apply the usability gates (level, First Aid, Alchemy, Engineering, required spell, zones, arena-only and arena-blocked), then dispatch to **every** definition whose `itemTypes` claims it and whose `accepts` passes. An ignored item only marks its type as having had something ignored.
2. **Rank** (`Scanner/Scanner-Ranking.lua`). A `ranked` definition collects candidates and sorts once, keeping the top `ns.MULTI_USE_MAX_ITEMS` (3). Others keep a running winner through `IsBetter`. Both compare with `CompareRecords` over `RANKING_PRIORITY`: buff food (gated), conjured first (gated), percent, value, off the Restock List (gated), conjured, zones, soulbound (`bindType == 1`), price, high stack (more than 10), hybrid, count, then item ID for determinism. The burn-first steps sit below value on purpose.
3. **Compose** (`Engine.lua`, `Body-Builder.lua`). If `macrosEnabled` is off, stop here: nothing is created, rewritten or deleted. For each standard definition: delete the macro if its `enabledMacros` entry is off, apply `modifyItem` and `corpseSpell`, take the ranked `useIDs` (only for types in `ns.MULTI_USE_MACRO_TYPES`), the stacked healthstones and the out-of-combat item, then the DruidMacroHelper override and `buildModeOverride`. The body comes from the first that answers: the mode body, the class body, then the standard body (`conjure`, `appendBlock`, `ns.BuildStateKey`, `ns.BuildStandardBody`). Feed Pet and Poisons run their own `customUpdate` afterward. The mini-map icon updates last.
4. **Write** (`Macros/Writer.lua`). `ns.WriteMacroBody` is the one writer. It creates a missing macro through `ns.TryCreateMacro`, or calls `EditMacro` only when `GetMacroBody(name)` differs from the new body. It returns false when the write failed, and every caller then leaves its state key unset.

### Item Data Caching

**Two caches, for different questions.**

- **The session memo** (`ns.GetItemData`, `Features/Item-Info.lua`) answers for any item: name, link, icon, stack size. It is keyed by whatever the caller asked with (an ID on the hot paths, a link at a merchant) and thrown away at logout. `ns.GetItemHyperlink` builds a white `|Hitem:ID|h[name]|h` link by hand while an item is cold, which the client resolves on hover, so a print names the item even on a fresh login.
- **The consumable cache** (`ns.db.profile.itemCache`, `Features/Macros-for-Consumables/Item-Cache.lua`) is persisted and enriched from the consumable tables, and holds only consumables. A non-consumable returns `"IGNORE"` without a `C_Item.GetItemInfo` call or a cache write. It is deliberately not in `ns.DATABASE_DEFAULTS`: `ns.EnsureItemCache` creates it at login and after every profile change, and throws it away when `ns.Version` changes or `ns.DATA_FOLDER` changes (Classic Era and Season of Discovery share a saved-variables file). An entry missing `itemID` is from an older schema and is rebuilt.

**Cold nils.** `C_Item.GetItemInfo` returns nothing until the client has resolved an item. Every feature that waits on one keys itself in with `ns.RequestItemInfoEvents(key)`: the bag scan (`"scan"`), the Restock List (`"restocker"`), each options panel through `ns.WarmItemCache`, Buff Duty and Automated Appreciation's Tracked panels. The last `ns.ReleaseItemInfoEvents` unregisters the event. Each answer reaches the Restock List first, then the options panels, then the consumable macros (which rebuild only when `ns.HasRawData(itemID)`).

- **The scan** sets `dataRetry` when a consumable comes back cold. `ns.RegisterDataRetry` keys in `"scan"` and retries every 2 s, up to 10 times. The event stays registered past the budget so a late answer still rebuilds; a clean scan refunds the budget and releases the event.
- **The Restock List** parks an add, an upgrade or a Staples tick on the cold item rather than writing a row with the wrong name, and stays keyed in while any of its four queues (parked adds, pending upgrades, pending Staples ticks, cold rows in the open window) holds something.
- **A miss is remembered** (`rememberedMisses`) only for an ID, and only while some waiter listens: during a login the same cold item is asked about over and over. A miss taken while nobody listens is never remembered, because the client announces its answer once, and with the event unregistered that answer lands unheard. The last waiter out drops every remembered miss for the same reason, and each answer heard reaches `ns.ForgetItemDataMiss` before anything retries.

### State Encoding

**Consumable Macros.** Two layers keep a write from happening twice: a per-type state key in `currentMacroState`, recorded only once the write landed, and the `GetMacroBody(name) ~= body` test in the writer. The standard key is lossless over every input that shapes the body:

```
ITEMIDS(+HS:stack)?(_C(_M:)(_R:)(_MR:)(_MM:)(_NI:))?(_EX:mode)?(_SM|_SE)?(_OOC:id(:S)?(:CN)?)?(_CN)?
```

`ITEMIDS` is the comma-joined ranked list for a multi-use type, else the one ID or `none`. The overrides keep disjoint namespaces: the Food macro's scroll mode is `SCROLLS:<ids>`, and the DruidMacroHelper body is `DMH:<form>:<formSpellID>:<ids>...`. A standard key always begins with a digit or `none`, so every transition between modes rewrites the macro. Feed Pet (`currentPetFoodState`) and Poisons (`currentPoisonState`) keep keys of their own. `ns.ResetMacroState` wipes all of them, plus the scroll aura baseline and the target and group signatures.

**The Blizzard Macro UI** saves its edit box back when it closes, which would revert a write made while it was open after the state key had recorded it. `ns.UpdateMacros` therefore defers while `MacroFrame:IsShown()`, and a one-time `MacroFrame:HookScript("OnHide")` resets the state and requests a rebuild on close. The hook is installed on every pass, so a first open and close with no update in between is the one gap.

**Enhanced Spellbook.** A macro's settings are keyed by its spell's Rank 1 ID, so they survive rank-ups and a locale change. Its WoW macro is found by a tag line (Enhanced Spellbook below), and `SyncAt` rewrites a body only when it differs and fits.

**Buff Duty.** `RenderBuffDuty` skips a redraw whose signature string (column, cast spell, unit, slot, macro text and buff expiry per icon) is unchanged. `ApplyBuffDutySettings` resets it.

## Characters and Profiles

**AceDB can open the database under a placeholder name.** The newest AceDB among the enabled add-ons is the one that loads, and it reads the character's name once, as the library loads. When that happens before the client has named the character, every such login would share one profile, and with it another character's settings and Restock List. `UseOwnProfileWhenUnnamed` (Core) puts the character on the profile saved under its real name at `PLAYER_LOGIN`, and `SaveProfileChoiceWhenUnnamed` saves the choice under the real name at logout and drops the placeholder's entry. An AceDB older than the vendored one, which on WoW Forever reads a first name and no surname, is caught the same way.

**Two character-key formats, never mixed** (`Features/Utilities.lua`):

| Key | Shape | Used by |
|---|---|---|
| AceDB's profile name | `Name - Realm`; on WoW Forever the first name and surname, space-separated, no realm | `profileKeys`, each character's own profile, `restocker.listChoices`, the Spellbook's `MacroOwnerKey` |
| The add-on's character key | The whole name, then `-Realm` with the realm's spaces closed up | `ns.db.global.inventory`, Diagnostics, the two Consumable Macros key migrations |

Only `ns.GetCharacterProfileName`, `ns.ProfileNameForCharacter` and `ns.SplitCharacterProfileName` spell out AceDB's format, and only `ns.GetCharacterKey` the add-on's. On WoW Forever a character's whole name is its first name and surname (`ns.GetPlayerFullName`, which reads `UnitNameUnmodified`), so two characters sharing a first name never share an entry.

**Every profile change re-applies.** `ns:ApplyProfile` runs on `OnProfileChanged`, `OnProfileReset` and `OnProfileCopied`. It calls `ns.ApplyConsumableMacrosProfile`, `ns.ApplyAutomatedAppreciationProfile` and `ns.ApplySpellbookProfile`, then `NotifyChange` for every registered panel. The Restock List in use is the character's own choice, not the profile's, so a switch leaves it alone.

## Macro Runtime Globals

Macro bodies run `/run` in the global environment, which cannot see the namespace, so these are globals. Each name is short because every byte counts against the 255-byte ceiling.

| Global | Called by | Does |
|---|---|---|
| `GtGFire(itemID, outOfCombatID)` | Every consumable body with an item in bags | Stamps the item and time, so a `UI_ERROR_MESSAGE` for a wrong-zone item within 1 s prints a bug report naming it. With `outOfCombatID`, the same `[combat]` test the body uses picks which one fired |
| `GtGTip(key)`, `GtGTipIf(cond, key)` | Consumable bodies | Prints a tip from `ns.TIP_MESSAGES`; `GtGTipIf` appends a `" 1"` sentinel to its conditional |
| `GtGNoItem(type, canMake)` | A body with nothing in bags | Prints `MESSAGE_NO_ITEM` with the type's label |
| `GtGReplace()` | Consumable bodies | The replace prompt |
| `GtGMute(on)` | Spellbook macros with Mute Errors | Zeroes `Sound_EnableSFX` and `Sound_EnableErrorSpeech`; `GtGMute()` restores exactly what it read, and a 1 s timer restores anyway |
| `GoodToGo_ToggleSpellbook()` | `Bindings.xml` | Toggles the Enhanced Spellbook window |
| `GtGBuffKey` (a frame) | The Buff Key binding and `/click GtGBuffKey` | The hidden secure button that casts the next buff |

The `Connoisseur*` names the callbacks had before the GtG prefix are aliased until their migration expires, since macros already written still call them.

## Consumable Macros

**Eleven macros, all in the General tab.** `ns.MACRO_CONFIG` lists Bandage, Explosive, Feed Pet, Food, Health Potion, Healthstone, Mana Gem, Mana Potion, Poisons, Soulstone and Water. Each name is a `MACRO_*` locale key starting with `"- "`, at most 16 characters. `ns.TryCreateMacro` omits `CreateMacro`'s `perCharacter` argument so the macro lands in General, and pauses creation once the General tab has `ns.MACRO_SLOT_CUSHION` (0) free slots left, with a once-per-session warning; creation resumes on its own once a slot frees.

**Why `enabledMacros` is account-wide while the consumable choices are per-character.** The macros live in the shared General tab, so which ones exist must be one choice for the account. A character switch never adds or removes a macro: it only rewrites the shared bodies to that character's best items.

**Multi-use macros.** Health Potion, Healthstone, Mana Gem and Mana Potion stack up to three ranked `/use` lines. Once the best item runs out mid-combat, where the macro cannot be rewritten, the press falls through to the next. This is safe only because every item in those categories shares one item cooldown, so a press still consumes exactly one.

**Body shapes.** A Mage's Food macro with an item in bags and both conjures known:

```
#showtooltip item:<food>
/cast [btn:3] <Ritual of Refreshment>; [btn:2] <Conjure Food(Rank N)>;
/stopmacro [btn:3][btn:2]
/run GtGFire(<food>)
/use item:<food>
```

The Health Potion with Use Food & Water in Potion Macros Out of Combat and Combine Healthstones on:

```
#showtooltip [combat] item:<pot1>; item:<food>
/run GtGFire(<pot1>,<food>)
/use [nocombat] item:<food>
/stopmacro [nocombat]
/use item:<pot1>
/use item:<pot2>
/use item:<hs1>
```

With nothing in bags the item line becomes `/run GtGNoItem("<type>"[,1])`, or a `GtGTip` when the class can learn the conjure.

**The 255-byte trims.** Every guard measures `#body` in bytes, never characters (`ns.MACRO_BODY_MAX_LENGTH`). The standard body trims in this order: rebuild without the Cannibalize lines; drop stacked healthstones, then ranked fallbacks from the bottom (never rank 1); drop the stealth line, then the out-of-combat block; drop the appended block. A body still too long is written anyway, with one `ns.WarnOnce` per macro name. A DruidMacroHelper body drops `/use` lines from the bottom, then stealth, then the out-of-combat block, and otherwise falls back to the standard body. Feed Pet drops its Dismiss shortcut, then its Revive shortcut.

**Modes.** Buff food, scrolls, pet buff food and conjured-first each run in one of `ns.MODE_ORDER`: always, solo, party, raid, leveling (below max level), maxlevel. Use Conjured Food & Water First ships on in leveling mode: free conjured food matters while leveling, while a raider at max level wants the best. Early re-application (`earlyReapply`, 180 s) counts a food, scroll or pet buff under the threshold as already expired, so the macro offers a fresh one before a pull; an expiring buff schedules its own recheck at `remaining - threshold + 1` s.

**Arenas.** `select(2, IsInInstance()) == "arena"` is detected live, never by zone list. It turns off the scroll and pet-buff overrides and buff food, makes potions and any food or water without `arenaUsable` unusable, makes `arenaOnly` items usable, and gives the Health Potion a healthstone-only body.

**Class and race extras.**

- **Feed Pet** has three tiers: a print-only stub when Feed, Revive, Call or Dismiss Pet is unknown; no Mend Pet; then the full cascade (`[mod:ctrl]` Dismiss, `[mod:shift][@pet,dead]` Revive, `[nopet]` Call, `[btn:2][combat]` Mend, then Feed). A dead pet that was dismissed is detected from `SPELL_FAILED_TARGETS_DEAD`. Pet food picks the happy bracket (0 to 10 levels below the pet), then above-pet food, skipping quest objectives.
- **Poisons** pick a poison group per hand (`mainHandPoisonGroup`, `offHandPoisonGroup`, keyed by `ns.POISON_GROUP_BASE_ITEMS`).
- **Conjures** pin the rank with the client's `C_Spell.GetSpellSubtext`. Healthstone and Mana Gem downrank for a low-level friendly target and check the unique-carry limit; Soulstone doesn't. Refreshment Table and Soulwell ignore the target and appear only where the flavor's data has rows for them.
- **Forsaken** try Cannibalize first while the target is Humanoid or Undead and the spell is off cooldown; drinking takes effect only where `ns.CANNIBALIZE_RESTORES_MANA` (true in the Camelot and Mists folders). A cooldown timer rebuilds the body as Cannibalize comes back.
- **Stealth Eating** appends Stealth for Rogues and Shadowmeld for other Night Elves; one key serves both.
- **DruidMacroHelper** wraps the two potions and the healthstone in `/dmh` lines for a Druid with the option on and the add-on loaded. The return form is fixed rather than tracked, because a macro cannot be rewritten after a form change mid-combat.
- On WoW Forever scrolls trigger the global cooldown, so the scroll body fires one scroll per press.

**The Ignore List** has two halves under one key: `ns.db.profile.ignoreList` for the character and `ns.db.global.ignoreList` for every character. Promoting an item to Global clears it from every profile's list. Reading another profile's list goes straight to `ns.db.sv.profiles` and creates the table only on a write. Logout prunes only IDs `C_Item.DoesItemExistByID` denies, since Classic Era and Season of Discovery share the file. Every edit calls `ns.ResetMacroState` and `ns.UpdateMacros(true)`.

## Readiness Report

On `READY_CHECK`, a private report naming what still needs fixing. It prints to the player only, through `PrintMessage`: a title, then up to three lines built from `Label : a, b` clauses.

1. **Missing Buffs and Expiring Soon**: flask (TBC and later; a flask or two distinct elixirs), Well Fed, the pet's Well Fed, scrolls, soulstone (a Warlock who knows it, none up in the group, off cooldown), main hand (waived with a Shaman in the party), off hand (enchantable off-hands only), and any helpful aura under the threshold whose full duration exceeds it.
2. **Missing Items and Damaged Gear**: Healthstone (only with a Warlock in the group), Mana Gem (Mages), healing and mana potions, bandages, read from the last bag scan's `ns.bestSelection`; then any equipped item under the durability threshold.
3. **Character and Non-combat Gear**: the spec label, unspent talent points, the PvP flag, and equipped non-combat gear (`ns.QUESTIONABLE_EQUIPMENT` and fishing poles).

**Silence is the feature.** A category with nothing wrong prints nothing, and a clean character prints nothing at all; `ns.BuildReadinessLines` returns nil and nothing prints. That is what lets it cover this much without becoming noise, so a switch may only ever add a line about something broken. The switches that ship on are the things a player can fix in the seconds a ready check gives them, gated on who can fix them (the Healthstone on a Warlock being in the group, the soulstone and gem on the player's class). The durability threshold compares the lowest item, not an average, since one weapon at 5% is what breaks mid-pull. In an arena the buff, expiring, item and PvP clauses drop. The probes in `Readiness-Report-Probes.lua` are stateless.

## Restock List

### Characters and Lists

Lists are account-wide: `ns.db.global.restocker.lists[listName][itemID]`. Which list a character uses is `restocker.listChoices[profileName]`, kept on global and not on a profile, so two characters sharing a profile still shop from lists of their own and Reset Profile can never empty a hand-built list (a README-Notes exception). `ns.InitializeCharacterRestockList` gives a character with no choice a list named for its class, numbered on collision ("Warrior (2)"); it never joins an existing list of that name on its own, and names other characters have chosen count as taken. `UseRestockList` is the single write point for a choice. Renaming a list re-points every character on it; deleting the list in use lands on the alphabetically first remaining list.

### The Saved Format

Each row packs into one line at `PLAYER_LOGOUT` and inflates at `PLAYER_LOGIN` (`Restocker-Saved-Format.lua`):

```
lists[listName][itemID] = "itemName, amount, stash, fromBank, buy, reaction, upgrade, buyExtra"
```

Booleans are `1`/`0`. Buy and upgrade default on (only `0` turns them off), buyExtra off, and a missing trailing field reads as its default, which is how a new field is added. There is no version stamp. A comma in an item's name truncates it until the client renames it.

### Merchant Orders

On `MERCHANT_SHOW` (Shift held skips the visit), `RestockFromMerchant` builds the crafting reagent order, applies the all-or-nothing reagent gate, reads the vendor's reaction, and builds one order per row with Buy on: `max(0, amount - bags)`, for rows whose `reaction` is at or below the vendor's. The budget is `GetMoney()` minus the Gold Reserve, and a `NewBagSpace` snapshot. Every purchase goes out synchronously in one loop, spending both budgets down locally, because money and bags don't change until the server answers. It buys in stack-size chunks (a limited slot holding more than one stack too), skips slots with an extended cost, caps at a limited slot's count, and lets a Buy Extra row take a limited slot's whole stock. Bag space fills partial stacks first, then a matching specialty bag, then a general bag. The add-on never sells. A summary prints once, then out-of-gold and bags-full lines.

**Reagents** come from `ns.POISON_RECIPES`. The need is the crafted item's shortfall times the reagent count, less what the bags hold beyond the reagent row's own Keep. They are bought only if the vendor stocks every reagent still needed, since half a recipe crafts nothing.

**Reputation.** `ns.REPUTATION_STANDINGS` carries each standing's discount for the window's labels ("Honored (10% off)"). The discount is informational; the only enforcement is the reaction gate.

### Bank Restocking

On `BANKFRAME_OPENED` (Shift held skips), the bank run starts as a coroutine in `Restocker-Bank-Visit.lua`, one move per tick. The tick interval is `max(0.140, 3 * max(pingHome, pingWorld) / 1000)` s, so a laggy connection gets more time per move. Each step:

1. Aborts if a merchant is open, because `UseContainerItem` sells there.
2. Rescans. A foreign item on the cursor is waited out for 5 steps, then cleared.
3. Waits up to 3 steps while a bag-plus-bank total has dropped (a move still in flight).
4. Stops with a stuck message after 5 steps with no progress.
5. Issues one move: stash first, unless the bank has no free general slot, then pull first.

Withdrawals take from the last bank bag first: a whole stack by `UseContainerItem`, a part by `SplitContainerItem` onto a named empty slot. Placement always names an empty slot and never calls `PutItemInBackpack` or `PutItemInBag`, which clear the cursor even when the server refuses, so "did it land" would always read yes. Keep amounts freeze for the run; Enter in a Keep box restarts it. Once every target is met, the tidy phase merges partial bank stacks until the count stops falling for 5 steps. The completion line prints only if something moved. On WoW Forever the bank is the `C_Bank` character tabs the player bought (`ns.FetchPurchasedBankTabIDs`), reloaded at every open.

### Reminders and Upgrades

**Reminders.** In town, the reminder fires on a not-resting to resting edge (`PLAYER_UPDATE_RESTING`, `PLAYER_ENTERING_WORLD`, `PLAYER_CONTROL_GAINED`), with a taxi forcing not-resting, a 60 s cooldown, and settle delays of 2 s on arrival and 5 s on login. A `/reload` seeds the state silently. Verbose mode adds a have and wanted line per item, since in town the detail is the point; at a merchant or bank the player is already looking at the window that fixes it, so those default to simple. The after-visit reminders fire 0.3 s after the window closes.

**Upgrades.** `ns.CONSUMABLE_UPGRADE_CHAINS` holds one ladder per staple family, each tier `{ minLevel, itemID, rank }`. A row moves only forward, to the best tier at or below the player's level with a higher rank; a target already on the list sums the amounts. It runs at `PLAYER_LEVEL_UP` with the event's level (`UnitLevel` still reads the old one there) and as a catch-up at every `PLAYER_ENTERING_WORLD`. Rows with upgrade off are skipped.

### Staples

The Staples window offers starter rows from `ns.STARTER_LIST_CATEGORIES`, each tied to an upgrade chain by `chainKey` (`food:<diet>`, `poison:<group>`, `reagent:<name>`, or a chain's `kind`). A row whose chain is missing on the flavor drops silently, and a row is offered only if its ladder has an item at the player's level. The popup opens at level 6 or above, on an empty list, on a fresh login (not a reload), after 3 s, out of combat, and never while the legacy import question is open (`ns.IsLegacyImportPending`).

### The Window

Hand-built on a portrait frame. All its menus are `AceGUI` Dropdown-Pullouts, never `UIDropDownMenu`, whose shared global frames leave taint behind; each closes through `ns.CloseRestockMenus`. A visit opens the window only with `autoOpenAtMerchant` or `autoOpenAtBank`, and closes it only if that visit opened it. Geometry is written whole at logout (`ns.SaveRestockWindowGeometry`), since AceDB has already stripped an empty default subtable by then. The Keep box saves on every keystroke, and an emptied box saves 0, which stores all of that item at the bank.

## Inventory Report

**Recording.** `ns.db.global.inventory[ns.GetCharacterKey()]` holds `{ name, realm, class, guid, bags, bank }`, each place one line of `itemID:count` pairs sorted by ID. Bags are read at `PLAYER_ENTERING_WORLD` and `BAG_UPDATE_DELAYED` (a read with a 0-slot backpack is ignored); the bank at `BANKFRAME_OPENED`, again 0.5 s later, and on every bag update while it is open. **Logout writes only what was last read**: on WoW Forever the containers can read as empty at `PLAYER_LOGOUT`. A renamed character's old record is dropped by GUID. The record's class colors characters in the Restock and Ignore Lists (`ns.GetClassesByProfileName`).

**Tooltip.** Hooked 5 s after login, so the block lands under other add-ons' lines, on `GameTooltip` and `ItemRefTooltip` through `ns.AddItemTooltipPostCall`: `TooltipDataProcessor` on WoW Forever, `OnTooltipSetItem` on the others. A weak-keyed set blocks the doubled call Classic Era makes for recipes. It shows this character first (live bags plus the bank snapshot), then other same-realm characters holding the item, A to Z. A zero total shows nothing unless the item is on the current Restock List with a Keep above 0. The `inventoryReport` switch exists because most auction add-ons print their own counts under the same items.

## Automated Appreciation

### Detecting Buffs From Others

Two paths, chosen by the TOC:

- **Combat log** (`Buff-Tracking-Combat-Log.lua`, every TOC but Camelot's). `SPELL_AURA_APPLIED` and `SPELL_AURA_REFRESH` both count as a buff landing, so a rebuff earns the same thanks; `SPELL_CAST_SUCCESS` is a cast; `SPELL_RESURRECT` a revive. A stranger is an aura from a player GUID with the friendly-reaction and outsider-affiliation flags; a teammate has the mine, party or raid flags. Affiliation flags are used because cross-realm `Name-Realm` sources break name lookups. A pet is credited to its owner, or the event dropped, never the pet itself: the whisper would bounce and the print would thank an animal.
- **UNIT_AURA** (`Buff-Tracking-Forever.lua`, Camelot only). Subscribed for the player alone, and only while praise is on. It stops when not ready, in combat or while auras are secret, reads only `addedAuras`, and finds the caster from `aura.sourceUnit` or `C_UnitAuras.GetAuraCasterGUID`, every value checked with `ns.IsPlain`. A buff that lands while blocked is skipped, never queued, and a recast of a buff already on the player isn't seen.

Both paths call `ns.NoteFavor` for strangers, which feeds Buff Duty's Return the Favor section. Readiness is a `Data.SAFETY_PAUSE` (3 s) timer, armed at setup and on every `LOADING_SCREEN_DISABLED`, with a token so a stale timer does nothing.

### Praise

`ns.HandleStrangersBuff` and `ns.HandleTracked` (`Praise.lua`) print, play the sound, whisper and emote.

- **Strangers**: the buff must still be on the player and last at least `minBuffDuration` (21 s). Print and sound fire every time. The whisper and emote pass two cooldowns, `praise:all` (`praiseCooldown`, ships 0) and `praise:<guid>` (`cooldown`, 3 s), stamped only when one is actually cleared to go.
- **Teammates and Services**: no praise cooldowns, since a teammate's cooldown is worth acknowledging every time it lands.
- **Under every setting** sits a 45 s whisper floor per recipient (`whisper:<guid>`). Emotes skip in combat, checked again at delivery. A nil emote target means no emote, because `PerformEmote(token, nil)` falls back to the player's current target.

### Service Alerts

Feasts, portals and other no-aura group help reach the combat log unreliably, so they come from `UNIT_SPELLCAST_SUCCEEDED`. That event reaches strangers too, so the caster must be a player in the group and not the player; a 10 s `service:<guid>` cooldown also folds the several unit tokens one cast fires on.

### Good News

Whispers for buffs the player casts on others (`Good-News.lua`). The combat log never reports buffs on players outside the group, so it uses a handshake: `UNIT_SPELLCAST_SENT` names the recipient (resolved through target, mouseover, focus, then party and raid tokens), the cast parks by cast GUID for 15 s, and `UNIT_SPELLCAST_SUCCEEDED` releases it. A resurrection stays parked until `SPELL_RESURRECT` proves it, because jumper cables and Defibrillate report a cast even when they fail. Dedupe is 10 s per recipient and spell. The duration is read 0.1 s after landing.

The template is the player's, with one token, `%a`, replaced by a gsub function (a typed `%` would make `string.format` error) with the ability link plus a "for N Seconds" clause when the rounded duration is under 60 s. The client's `|4` plural escapes are resolved first: `SendChatMessage` rejects any message still holding one and drops the whole line. Over 255 bytes, the message rebuilds with the default template, then without the duration; it is never cut, since a cut could break the link. Whispers go out 0.35 s apart, because a raid-wide buff lands on every recipient in the same instant and a burst risks the server's chat squelch. The options box caps the template at 120 bytes.

### Sent Format and the Thank You Button

Every automated message goes through `ns:BuildAnnounceMessage`: `{rt1} body // GtG`, the Star left off on WoW Forever, which blocks raid-marker tokens in chat. The body's closing punctuation is trimmed as whole UTF-8 sequences (full-width marks included) and Spanish `¡ ¿` openers dropped. Item and spell links pass through, so pipes are not stripped.

The Thank You Button is the exception (README-Notes): `ns:Whisper` sends the player's own words with no marker and no sign-off. Five buttons come from `Data.THANK_YOU_BUTTONS`: `- Thank` (`/thankyou`, a random emote from a checklist) and `- GtG 2` to `- GtG 5` (`/thankyou2` to `/thankyou5`, one chosen emote). Button 1 ships on; 2 to 5 start off, each on its own icon. `ReconcileMacros` creates missing macros while the account holds fewer than 120, re-reading the count each pass, fixes icons and deletes the macros of buttons switched off. A press needs a player target who isn't the player; the whisper also needs the same faction and a non-secret identity.

## Buff Duty

### The Window

Two frames: `anchor` on `UIParent`, owned by the Hide in Combat state driver, and `content` inside it, which the add-on shows and hides. Every icon is a pooled `SecureActionButtonTemplate` button registered for `AnyUp` and `AnyDown` (the template acts on whichever half `ActionButtonUseKeyDown` names). Sections run Self, Target, Return the Favor, then one per party, two parties to a row. The title is `Buff Duty // GtG` (README-Notes). The close button's click is replaced with `ns.CloseBuffDuty`, which turns Buff Duty off for the current class only; the template's own click would hide a protected parent.

**Click to cast** (`ns.SetBuffButtonAttributes`). Only `type1` is set, so right-click casts nothing and dismisses a favor instead. Every attribute is rewritten on every use, because buttons are pooled. A spell is cast by rank text, `Name(Rank 2)` from `C_Spell.GetSpellSubtext`, never by ID: on Classic Era a lower rank's ID casts nothing. The Soulstone and resurrections cast by bare name, since each tier is its own spell. An outsider out of sight gets a macro:

```
/cleartarget
/targetexact NAME
/cast [help] Name(Rank N)
```

### Reading Auras

The cache is keyed by GUID, so a roster change only prunes it. `UNIT_AURA` marks one GUID dirty; `MarkAllAurasDirty` bumps a generation and drops records not read in the last one. `Has(buff, unit)` decides, in order: a version that bounced with the same expiration counts as had; known strengths compare (stronger is had, weaker missing); otherwise a higher single rank is had and a lower one missing, group and Greater versions going by time; then the time rule (had when permanent, or at least the refresh threshold remains); and exclusive families count as had. A buff running low comes back with its expiry, and the icon draws a reversed time-left sliver.

Thresholds: party buffs at `refreshMinutes` (3, 5 or 10), self buffs per buff (`selfRefresh`), weapons at `weaponRefresh`.

**Ranks for low-level targets.** On flavors where `ns.EXPANSION <= 3`, `RankFor` returns the highest known rank whose learn level is at most 10 above the target's; with none, there is no icon.

**Who gets what.** `RoleOf` reads the Main Tank mark, then the assigned role (tank only outside a raid), then the player's own group-finder roles, then `tankWhen[class]`. Pets take every buff, plus tank buffs per `tankWhen.PET`; a phase-shifted or charmed pet is skipped. Group icons appear only while grouped and target the first member in range. Range tries `C_Spell.IsSpellInRange`, then `UnitIsVisible`, then `UnitInRange`; an unknown answer reads as in range.

**WoW Forever.** While `ns.AreAurasSecret()`, the window hides and the Buff Key picks nothing: a secret value can't be compared. Every GUID, spell ID and expiry is read through `ns.IsPlain`, and a range answer that comes back secret reads as in range.

### The Buff Key

A hidden `GtGBuffKey` secure button, bound as `CLICK GtGBuffKey:LeftButton`; a slash command can't cast, hence the button. PreClick picks a spec and writes the attributes, the template casts, PostClick clears them. The up half reuses the down half's pick within 1 s. Candidates run: a dead friendly target, the group's dead, favors, the target, self buffs, then parties (the target's subgroup first); weapon icons never. A group version wins when it costs less mana than the singles, a member is too low for the single, or costs are unknown and it reaches two or more. Skip memory: 3 s after a buff, 60 s after a resurrection, 30 s for a favor. "On cooldown" means ending after the GCD, read on Vanilla, TBC and Season of Discovery from the first known class spell whose base cooldown is the GCD alone.

### Other Sections

- **Cast results.** `SPELL_FAILED_AURA_BOUNCED` within 2 s of a cast records every version on the unit with its expiration (`NoteBounce`), so a stronger buff someone else cast stops being offered.
- **Resurrections.** The target must be dead, not a ghost, connected and with no resurrection incoming; a `SPELL_RESURRECT` adds a 60 s pending entry. On WoW Forever, with no combat log, the player's own cast succeeding within 15 s stands in.
- **Weapons.** A hand needs nothing while one of its picks holds with enough time left. Items must fit the weapon subclass; a Shaman imbue is offered only for the hand it lands on. `REPLACE_ENCHANT` is auto-accepted within 2 s of a weapon click.
- **Soulstone.** Hidden while anyone in the group carries one; otherwise it goes on a healer in range, the first healer, or the player, and the Buff Key never picks it.
- **Party-Buffs.** A section under Self-Buffs that counts the raid buffs other classes could give that the group is missing; left-click asks the group, right-click whispers that class, each with a 10 s cooldown.
- **Return the Favor.** Up to 5 strangers who buffed the player, for `favorSeconds`. There is deliberately no players-in-range list: it would depend on friendly nameplates.

**Load order is load-bearing.** Several files capture earlier files' functions as locals at load, so the TOC order (Events, Icon-State, Party-Buffs, Frame, ..., Keys) cannot be shuffled.

## Enhanced Spellbook

### Hosts and the Window

`GoodToGoSpellbookFrame` (1060 by 640, `UIParent`, in `UISpecialFrames`) replaces the game's spellbook rather than docking to it: showing it closes the game's book with `HideUIPanel`, out of combat only. It only shrinks to fit the screen. Four tabs: Spell Book, What's Next?, Pet Spell Book and Pet What's Next?, the last two only where the class has pet data. The launcher is chosen by the TOC:

- **Classic host** (Vanilla, TBC, Mists): a tab parented to `UIParent`, anchored under the class's last skill-line tab so it doesn't land under other add-ons' tabs, hooked with `HookScript` and `hooksecurefunc` only.
- **Modern host** (Camelot): `Spellbook-Tabs.lua` hangs Classic-style side tabs down the right edge of `PlayerSpellsFrame`, starting level with the native skill-line tabs and stepping past other add-ons' frames of tab size, attaching on `ADDON_LOADED` for `Blizzard_PlayerSpells`.

Every launcher and window frame is parented to `UIParent` and only anchored to Blizzard frames, because a frame parented to a Blizzard panel stays protected for good. The page strip is custom: Blizzard's paging template reads a format string the Classic clients don't define.

### Macros per Spell

`ns.CollectMacros` makes one macro per spell in the book, plus focus copies (not on Vanilla, which has no focus), Duplicates, rank copies when Show All Spell Ranks is on, and unlearned spells; it folds profession specializations and the ranged attacks (Throw, Shoot Bow, Gun and Crossbow become one Shoot macro with `[worn:<subclass>]` clauses, the subclass named by the client). Settings keys: the Rank 1 ID, `1120#2` for a Duplicate, `133@8400` for a rank copy, `consumable:<type>` for a Consumable Macros tile. The WoW macro name is `-` plus the spell name, at most 15 bytes, trimmed without cutting a UTF-8 character, with ` @F`, ` N` or ` R3` suffixes.

**Kinds.** Eight kinds (enemy, friendly, buff, resurrect, anyone, ground, form, self) decide which options a spell is offered and what it starts with (`profile.kindDefaults`, stored as true or false). Buffs start on Dynamic Rank and Right-Click For group version.

**Body order** (`Macro-Body.lua`): `#showtooltip`; `/stopmacro` for channeling, stealth or combat state, ahead of the mute so a stopped press never leaves sound muted; `/run GtGMute(1)`, `/stopattack`, `/stopcasting`, `/cancelform`; `/targetenemy` or `/targetfriend`; `/use` slots; the stance line; the cast line; auto shot, `/startattack`, `/petattack`, error clearing, `/run GtGMute()`; the tag line. Clauses casting the same spell merge:

```
#showtooltip
/cast [mod:shift] Frost Nova; [@mouseover,harm,nodead][] Fireball
#a7
```

Conditionals allow 8 rows of 2 conditions; a Cast Sequence 7 steps, resetting on target and combat by default. **Dynamic Rank** writes the highest rank whose learn level minus 10 is at or below the target's level, rewriting only while such a macro is actually on a bar, and never in combat; mouseover leaving fires no event, so it is polled every 0.2 s.

### Tags and Ownership

A macro's last line is its tag: `#` and two base-62 characters (three after 3,843 tags). `ns.db.global.macroTags` maps an identity (`<ownerKey>:<spell|focus|copyN|rank ID>:<spellKey>`) to its tag, so a macro the player renamed or moved is still found, and a deleted macro placed again gets its old tag back. Tags already in any macro body are skipped, so Macro Spellbook's tags never collide. `SyncAt` matches by tag first, then by name, rewrites a body that differs and fits, renames from a legacy name, and keeps a name the player chose.

Picking up a macro creates it in a character slot while one is free, else General. Which macros the add-on made is recorded where no profile change can lose it: `ns.db.global.ownedMacros[name] = ownerKey` for General, `ns.db.char.ownedMacros[name] = true` for character macros (a README-Notes exception). Delete Macros removes only macros carrying a handed-out tag **and** an ownership record, highest index first. The 255-byte guard refuses a write that doesn't fit and warns once per macro; a body is measured again after tagging, since a three-character tag adds a byte. The docked panels' meter turns gold at 90%.

### Ranks, Trainers and What's Next

Ranks exist where `ns.EXPANSION <= 3` (`HAS_SPELL_RANKS`), which leaves Mists out. Learn levels merge the static `ns.TRAINER_SPELLS` rows (filtered to the class, faction and race), the levels recorded at the player's own trainers (`profile.trainerSpells[class][spellID]`, from `TRAINER_SHOW` and `TRAINER_UPDATE`, class trainers only), and `C_Spell.GetSpellLevelLearned`. Class-Config keeps only the player's class of the large class and trainer tables. Season of Discovery spell IDs (at or above `ns.SOD_FIRST_SPELL_ID`) are hidden on a non-Discovery Vanilla realm.

What's Next is computed live from the static data: each row is Available, Soon (within 2 levels), Later, Missing, Talent or Known, sourced from start, trainer, book, quest, talent or rune (Season of Discovery). The Pet What's Next tab names tameable beasts in English from the data file (a README-Notes exception: the client can't name a creature it hasn't seen). WoW Forever ships empty pet ability tables, so that tab doesn't appear there. The ranks under the game's own spell tooltips (`abilityTooltipRanks`) skip in combat.

**Group handover.** When a newly learned spell replaces one in `ns.SPELL_GROUPS`, it takes over the old spell's tag, settings, focus copy and Duplicates, if it has no macro of its own yet, and the sync renames the macro. This runs even with no page open.

## Mini-map Button

One LDB object and button for every feature. Its position lives in `ns.db.global.minimap`, so a profile change never moves it.

| Click | Does |
|---|---|
| Left-Click | Toggles buff food and scrolls |
| Shift + Left-Click | Toggles Buff Duty |
| Right-Click | Adds the Food macro's current pick to the Ignore List |
| Shift + Right-Click | Toggles the Restock List window, as a bare `/restock` |
| Middle-Click | Clears the Ignore List |
| Shift + Middle-Click | Opens the options panel, checked first |

## Diagnostics

**Off at every login, never saved.** `ns.diagnostics.enabled` is runtime state; off, the panel shows only its warning and the toggle, and turning it off stops the Event Log and clears every output. Each `Diagnostics/Manifests-<Feature>.lua` appends rows to the shared tables in `Manifests.lua` (`ns.DIAGNOSTIC_API_CHECKS`, `_SPELLS`, `_NAME_LOOKUPS`, `_DATA_SOURCES`); a repeated API label prints once, and two data sources with one label merge. `Tracked-Lookups.lua` replaces `ns.DIAGNOSTIC_SPELLS` at login, so the load-time rows are kept under `ns.DIAGNOSTIC_SPELL_ROWS`.

- **Event Log**: 500 entries, 8 arguments each cut at 255 characters. `COMBAT_LOG_EVENT_UNFILTERED`, `UNIT_AURA` and `SPELL_UPDATE_COOLDOWN` are left out and logged decoded by their handlers; the feature hooks check `ns.diagnostics.logging` first, so logging off is free.
- **Validate Data**: one report per data file, looking every row up on this client in batches of 100 and printing TSV to paste. Its output is what the Data Review applies.
- **Message Length**: every sent message and macro body at its widest, against 255 bytes, in the locale the client runs. Run it on ruRU, the overflow canary.

## Saved Variables

One table, `GoodToGoDB`, managed by AceDB-3.0 with `ns.DATABASE_DEFAULTS` from `Data/Default-Settings.lua`. The TOCs also list `BagsBuffsButtonsDB`, the table from before the rename, until its migration expires.

**Model: Per-Character.** `AceDB:New` takes no third argument, and every character lands on a profile of its own, named as AceDB names it. The consumable choices, the Ignore List's character half, the Spellbook's macro options and recorded trainer spells, and the derived item cache ride the profile, because a level-15 alt and a raiding 60 want different food, scrolls differ by class, and two Rogues want their own poisons. **Reset Profile clears that character's profile only**; everything on `ns.db.global` survives. Global holds what the account shares, each with a reason written beside its key in `Default-Settings.lua`:

- **Presentation**: `showWelcome`, `showMacroNames`, `minimap`, `inventoryReport`, `abilityTooltipRanks`.
- **What every character shares on the client**: `enabledMacros` and `macrosEnabled` (the General macro tab), `ownedMacros`, `macroTags`, `macroTagCount`.
- **Data the player built or the add-on gathered**: `restocker` (the lists, each character's list choice, the window and reminder settings, the Gold Reserve) and `restockerEnabled`; `inventory`; the Ignore List's Global half.
- **Behavior preferences answered once for the account**: `readinessReportEnabled` and every `readiness*` switch; `spellbookEnabled`.
- **Automated Appreciation and Buff Duty**, none of it about one character: `strangers`, `teammates`, `services`, `goodNews`, `buffWindow`, `watchedBuffs`, `slash` to `slash5`.
- **The legacy import's record**, `legacyImported`, written by the migration.

Two README-Notes exceptions put per-character records off the profile so Reset Profile leaves them alone: each character's Restock List choice (`restocker.listChoices`) and the character macros the Spellbook made (`ns.db.char.ownedMacros`).

**AceDB applies the defaults itself**, copying scalar and table defaults into the saved table when a scope is first touched and leaving an explicit `false` alone; there is no hand-rolled merge, and no `x = x or default`. Each feature's block is added through `AddDefaults`, which asserts no two features declare the same key. At logout AceDB strips every value equal to its default, so an empty default subtable is nil by the time the add-on's own logout handler runs.

**Default lists.** Nothing seeds a list on empty. The settings maps fill a key only where the player never saved one: `watchedBuffs` and `goodNews.watched` from the `received` and `given` columns of the client's `ns.TRACKED_ABILITIES`, `buffWindow.audience` and `selfRefresh` from the Buff-Duty-Spells defaults. Keys the current client lacks are kept, since Classic Era and Season of Discovery share these settings. The Staples window writes its default ticks only when it opens. The Readiness panel's Reset writes every `readiness*` default back except the master switch.

### Migration Chain

Every piece is tagged `MIGRATION (remove after YYYY-MM-DD)` where it sits; delete everything so tagged once its date passes.

- **2026-11-18**: Buff Duty's pets toggle becomes `tankWhen.PET` (`Buff-Duty-Settings.lua`).
- **2026-11-21**: Buff Duty self buffs move from 5 minutes to 3 (`selfRefreshMigrated`); the Group Buff key's old `TFTBBuffGroup` command.
- **2026-11-23**: Spellbook macros named before the `-` prefix, and the "claim" and "adopt" ownership states (`Macro-Sync.lua`).
- **2026-11-25**: the legacy add-on import (`ImportLegacySettings`, its popups, locale keys and `ns.LEGACY_ADDONS`); Connoisseur & Restocker's repairs, run before the profile callbacks are wired (`ns.RekeyCharactersByFullName` in `Character-Key-Migration.lua`, then `ns.MoveCharactersOntoOwnProfiles` in `Default-Profile-Migration.lua`, and the Profiles panel's `noDefaultProfiles`); the Restock List's old saved-line shape, empty legacy `Name-Realm` lists, the retired Staples answer and the guarded Inventory Report call; stale `"IGNORE"` cache entries; the `- TFTB 2..5` Thank You macro names.
- **2026-11-26**: the `Connoisseur*` macro callbacks; the Spellbook's `~` prefix, retired Custom Macros and Profession Tooltips data, flat `trainerSpells`, and macro records keyed by `ns.db.keys.char`.
- **2026-11-29**: Buff Duty's position saved by its top-left corner.
- **2026-12-03**: the rename, `BagsBuffsButtonsDB` into `GoodToGoDB` (`MoveRenamedSettings`), and its TOC entry; the `- BBB 2..5` Thank You macro names; the hidden `MACROSPELLBOOK_TOGGLE` and `TFTBBuffIndividual` bindings with `ns.MigrateSpellbookBinding` and `ns.MigrateBuffKeys`.

**The legacy import** runs at login, before AceDB opens the table, once per old add-on. The client loads an add-on's saved variables only while that add-on is on, so: one that is on has its settings copied in (winning key by key, keys only Good to Go has kept, Restock Lists merged by name), then every old add-on still running is turned off and a reload offered so the old copy stops rewriting the same macros; one that is installed but off prompts the player, Yes turning it on and reloading into the first case, No remembered as `"declined"`. Thanks for the Buff's single shared profile becomes account-wide settings. Macro Spellbook is only turned off.

## Adding a New Consumable Macro

1. Add `ns.MACRO_CONFIG[typeName]` in `Data/Data.lua` with its `MACRO_*` and `LABEL_*` keys, in `Locales/enUS.lua` only. The macro name is at most 16 characters and never changes once shipped.
2. Add `ns.MACRO_DEFAULT_ITEM_IDS[typeName]` in every folder's `Macro-Default-Items-{Game}.lua`; the no-item line reads it.
3. For a new item category: a table in all seven flavor folders (declared empty where a flavor has none, each listed in its TOC's folder block before `Data/Default-Settings.lua`), a test in `ns.HasRawData`, a branch in `ns.CacheItemData` setting a new item type, and any new usability gate in `ns.ScanBags`.
4. Create `Features/Macros-for-Consumables/Macros/<Name>.lua` calling `ns.RegisterMacroType` (protocol in `Definitions.lua`), and list it in all four TOCs after `Engine.lua`. Register as the file loads: the selection tables are built on the first scan.
5. For a multi-use type, set `ranked = true` **and** add it to `ns.MULTI_USE_MACRO_TYPES` (the scanner reads one, the engine the other), and only if every item shares one cooldown.
6. Put every input that shapes the body into the state key, through `stateExtras` or an `appendBlock` flag. Its setter calls `ns.ResetMacroState()` then `ns.RequestUpdate()`, or `ns.ToggleMacroSetting`.
7. Add `enabledMacros[typeName] = true` in `Data/Default-Settings.lua` and its toggle row in `Options/Macros-for-Consumables/Options-Macros.lua`.
8. Check the body against 255 bytes on ruRU with Diagnostics' Message Length report (Style Guide → MESSAGES → Message Length).

A new ranking step goes into `RANKING_PRIORITY`, `FillRecord`, `ResetBest` and `CopyCandidateRecord`, built as a real boolean.

## Adding a New Registered Event

1. Add it to `ns.EVENT_NAMES` in `Features/Core.lua`, so the dispatcher and Diagnostics pick it up together. An event one client lacks needs a flavor guard there, as `COMBAT_LOG_EVENT_UNFILTERED` has; registering a name the client doesn't know throws.
2. Subscribe with `ns.SetModuleEvent(<module>, EVENT, true[, units])` where the feature turns on, and release it where it turns off.
3. Handle it in the module's dispatcher, or its handler table. If the table already has the event, share that entry.

## Adding a New Buff Duty Buff

1. Add a row to `ns.BUFF_DUTY_SPELLS` in each folder's `Buff-Duty-Spells-{Game}.lua`, using the legend at the top of the file: `class`, `single` ranks lowest first with learn levels, `group` IDs ascending, `greater` IDs (counted, never cast), `exclusive`, `manaOnly`, `noCasters`, `talent`, and a `default` audience from `Data.BUFF_AUDIENCE`.
2. Nothing else for an ordinary row. `BuildLookup` drops IDs the client lacks, the audience seeds from `default`, the Tracked Abilities panel lists it, and a non-exclusive `group` row joins the Party-Buffs counts.
3. Self buffs go in `ns.BUFF_DUTY_SELF_SPELLS`; a class with two or more self buffs in one exclusive family needs a `BUFF_DUTY_SELF_NOTE_<FAMILY>` key in `enUS.lua`. Weapon enchants, weapon items, the Soulstone and resurrections have their own tables in the same file.

## Adding a New Tracked Ability

Add a row to `ns.TRACKED_ABILITIES` in each folder's `Tracked-Abilities-{Game}.lua`, per its legend: `type` (SOLO, GROUP or SERVICE), `detect` (AURA, CAST or RESURRECT), whether it is `received` (Teammate Buffs and Service Alerts) and `given` (Good News), and its triggers. Lookups, seeding and the Tracked panels follow from the row. A RESURRECT row waits for `SPELL_RESURRECT`; never detect a revive from its cast.

## Adding a New Staples Row

Add a row to `ns.STARTER_LIST_CATEGORIES` in `Data/Data.lua` (field documentation above the table), with a `chainKey` matching a chain in every folder's `Consumable-Upgrade-Paths-{Game}.lua`. A row whose chain is missing on a flavor is dropped there silently. A label goes in `enUS.lua` only when the row stands for a kind of item; otherwise the client names the item.

## Adding to the Enhanced Spellbook

- **A class spell**: its ID in the class's lists in `Class-Spell-Lists-{Game}.lua` (which set its target, kind and page tag) and a trainer row in `Trainer-Spells-{Game}.lua`. A spell no trainer covers goes in `extraSpells`, with a source in `ns.EXTRA_SPELL_SOURCES`.
- **A page category**: an entry in `ns.PAGE_CATEGORIES` and its mapping in `Page-Categories.lua`; a new list tag also needs `PAGE_TAGS` in `Class-Config.lua`.
- **A macro kind**: a row in `ns.MACRO_KINDS`, a branch in `ns.MacroKind`, and a `kindDefaults[kind] = {}` default.
- **A macro option**: an `OFFERED` predicate in `Macro-Options.lua`, its line in `Macro-Body.lua`, a profile table in `Data/Default-Settings.lua`, and an entry in `DEFAULTABLE_OPTIONS` if kinds may default it (Duplicates copy from that list). Check the longest body with Diagnostics' Message Length report.

## Adding a Thank You Button

Add a row to `Data.THANK_YOU_BUTTONS`: its settings key, macro name and slash command. Its defaults, options section, macro and command all generate from the list. Its whisper is the player's own text, so it carries no marker and no sign-off.

## Changing the Shape of Saved Data

Ship a migration for the data players already have, supported for 30 days, every piece tagged `MIGRATION (remove after YYYY-MM-DD)` (Style Guide → SAVED VARIABLES → Migration Windows). Nil a retired key inside the migration, and never reuse a retired key's name: whatever players saved under the old meaning reads straight back. A Restock List field is a new trailing field in the saved line, defaulting when absent. A new field in the consumable cache's schema extends the stale-schema nil-test in `ns.ScanBags`, since every dev copy reads `Dev` and never invalidates on version.

## Localization

- **`enUS.lua` is the source of truth** and the only file passing AceLocale's `true` default-fallback flag. Every string originates there; the other ten locales translate its key set and fall back to English for any key they lack. They belong to the Localization Review (`07 - Localization Review.md`): add new keys to `enUS.lua` only, and never hand-edit the others during ordinary work.
- **Placeholders.** `%s` and `%d` count, type and order must match `enUS` per key in every locale, or the string crashes at runtime. The Good News template uses its own `%a` token, substituted by gsub.
- **Game names never go in `Locales/`.** Spells, items, skills, races, classes and Blizzard UI labels are stored as IDs or tokens and named by the client (Style Guide → GAME NAMES). The single IDs live in `Data/{Game}/Game-IDs-{Game}.lua` (`STEALTH_SPELL_ID`, `SHADOWMELD_SPELL_ID`, `CANNIBALIZE_SPELL_ID`, the druid forms, the pet spells, `POISONS_SPELL_ID`, `WELL_FED_SPELL_ID`, `ns.GAME_IDS`) and go through `C_Spell.GetSpellName`, ranks through `C_Spell.GetSpellSubtext`. `FIRST_AID_SKILL_LINE_ID`, `ALCHEMY_SKILL_LINE_ID` and `ENGINEERING_SKILL_LINE_ID` are compared by ID on WoW Forever and by the skill line's display name on Classic Era and TBC. `NIGHT_ELF_RACE_ID` and `UNDEAD_RACE_ID` go through `C_CreatureInfo.GetRaceInfo`, classes through `LOCALIZED_CLASS_NAMES_*`, items through `C_Item.GetItemInfo`, zones through `C_Map.GetAreaInfo`, and the ranged weapon subclasses through `GetItemSubClassInfo`. Diagnostics' Game Names report checks every row of `ns.DIAGNOSTIC_NAME_LOOKUPS`. Two departures are README-Notes exceptions: the six `DIET_*` pet diet words, and the English beast names in the Pet What's Next tooltip.
- **Macro names are identity.** Macros are found by name, so a shipped `MACRO_*` value never changes in any locale; the Thank You macros' names come from `Data.THANK_YOU_BUTTONS` and stay unlocalized for the same reason.
- **Join text through the locale**, with `LIST_SEPARATOR` and the Readiness clause keys, never a literal `", "`.
- **Not localized**: the Diagnostics strings, plain English by design.

The Spanish file pairing, the overflow canary (ruRU) and the output ceilings are per Style Guide → LOCALIZATION and MESSAGES → Message Length. Good to Go has both ceilings: `ns.MACRO_BODY_MAX_LENGTH` for every macro body and `ns.CHAT_MESSAGE_MAX_LENGTH` for every whisper and group message.

## Common Pitfalls

- **Editing macros in combat**: silently blocked. Consumable Macros route through `ns.RequestUpdate()` and the Spellbook through `QueueMacroSync`; both replay on `PLAYER_REGEN_ENABLED`.
- **Writing a macro while the Blizzard Macro UI is open**: its save-back reverts the write after the state key recorded it. `ns.UpdateMacros` defers while `MacroFrame:IsShown()`; never write around that guard.
- **A body input missing from the state key**: the macro silently goes stale. Keys are lossless, and override modes use disjoint prefixes.
- **Recording a state key when the write failed**: a full General tab blocks every retry. `ns.WriteMacroBody` returns false and callers leave the state unset.
- **Passing a number as `CreateMacro`'s `perCharacter`**: the client boolean-checks it. Consumable and Thank You macros omit it (General); the Spellbook passes a real boolean.
- **Reading target or group state without joining its signature**: `PLAYER_TARGET_CHANGED` and `GROUP_ROSTER_UPDATE` rebuild only when `ns.TargetSignatureChanged` or `ns.GroupSignatureChanged` sees a change.
- **A new override that reads the bags directly**: scroll, pet-buff, poison and pet-food selection bypass the scan's gates, so each checks `ns.IsIgnored` and usability itself. A new one must too.
- **Holding the aura snapshot**: `ns.GetPlayerBuffSnapshot()` returns one shared buffer the next call overwrites. Take one per scan and pass it down. On WoW Forever it returns the last readable snapshot while auras are secret; never reset to empty, which reads as "no buffs".
- **Reading `UnitLevel("player")` in a `PLAYER_LEVEL_UP` handler**: it still returns the old level. Use the event's argument.
- **`UseContainerItem` at a merchant sells the item**: the bank run aborts whenever `ns.merchantIsOpen`.
- **`PutItemInBag` or `PutItemInBackpack` in the bank run**: both clear the cursor even when refused. Name an empty slot, as `Restocker-Bags.lua` does.
- **A Restock List handler that ignores the master switch**: wrap it in `WhileEnabled`; only logout runs unwrapped.
- **Counting Restock List items by name**: an unresolved name reads as 0 and buys a full stack. Count by itemID.
- **Folding a default-on flag into `x and false or nil`**: it yields nil for every input, so the off state never saves (see `ItemFromString`).
- **A remembered item miss outliving its answer**: the item is stranded for the session. Every answer must reach `ns.ForgetItemDataMiss` before a retry, and anything parked on an item keeps its waiter keyed in (`ns.SyncRestockItemInfoSubscription`).
- **Calling the legacy globals** (`GetItemInfo`, `GetSpellInfo`, `UnitBuff`, `IsSpellKnown`): WoW Forever has dropped them. Call `C_Item`, `C_Spell` and `C_UnitAuras` directly, and `ns.IsSpellKnown` / `ns.IsPlayerSpell`.
- **An API one client lacks**: put it behind an accessor in `Features/Utilities.lua` that answers nil there, with a Diagnostics API row. `ns.OnReadyCheck` calls its probes unguarded, so one error silences the whole report on that client.
- **Comparing a secret value on WoW Forever**: it errors. Test with `ns.IsPlain`, and ask `ns.AreAurasSecret()` before reading auras.
- **Registering `COMBAT_LOG_EVENT_UNFILTERED` on WoW Forever**: `ADDON_ACTION_FORBIDDEN`, which `pcall` can't catch. It is in `ns.EVENT_NAMES` only off Camelot, and the combat-log files stay out of the Camelot TOC.
- **Changing a Buff Duty button outside its attribute writer, or in combat**: pooled buttons keep stale attributes, and protected changes are blocked. Go through `ns.SetBuffButtonAttributes`, out of combat.
- **Casting a buff by spell ID**: on Classic Era a lower rank's ID casts nothing. Cast by rank text; the Soulstone and resurrections by bare name.
- **Parenting a frame to a Blizzard panel**: it stays protected for good. Parent to `UIParent` and anchor beside it, as every Spellbook launcher does.
- **Blizzard dropdowns in a hand-built window**: `UIDropDownMenu` leaves taint behind. Use an AceGUI Dropdown-Pullout that joins `ns.CloseRestockMenus`.
- **`PerformEmote(token, nil)`**: it emotes at the current target. Resolve a target or skip the emote.
- **A `|4` plural escape in a sent message**: `SendChatMessage` drops the whole line. Resolve it first, as `ResolvePlurals` does.
- **Crediting a pet's buff to the pet**: the whisper bounces. Credit the owner or drop the event.
- **Detecting a revive from its cast**: jumper cables and Defibrillate report a cast even when they fail. Wait for `SPELL_RESURRECT`.
- **Reading the bags at `PLAYER_LOGOUT`**: on WoW Forever they can read as empty. Read while playing and write that down at logout.
- **Indexing a default subtable at logout**: AceDB has already stripped empty defaults. Write whole values, as `ns.SaveRestockWindowGeometry` does.
- **Changing a shipped default**: AceDB stripped every value equal to the old default, so every player still on it moves to the new one. It is a behavior change, not just a new-install change.
- **Mixing the two character keys**: AceDB's profile names and `ns.GetCharacterKey()` differ in shape. Go through the readers in `Features/Utilities.lua`.
- **Naming a character with `UnitName` alone**: on WoW Forever that is the first name. Use `ns.GetPlayerFullName` and `ns.GetCharacterKey`.
- **Putting a setting on the wrong scope**: the profile is one character's own. Add to global only for a concrete account-wide reason, written beside the key.
- **Two features declaring one default**: `AddDefaults` stops the load. Pick a key of your own.
- **An all-clear line in the Readiness Report**: silence is the feature.
- **A Readiness switch added in one place**: it also needs its panel row, Diagnostics' `READINESS_SWITCHES`, and the `readiness` prefix so the panel's Reset reaches it.
- **Shuffling the TOC order in Buff Duty or Automated Appreciation**: files capture earlier files' functions at load, so a later file loaded early captures nil.
- **Editing one flavor folder's copy of a row**: the seven copies are separate. Look the ID up in every folder and say which copies you changed and why.
- **Changing a shipped macro name**: it creates a second macro and strands the old one on every action bar.
- **Testing a new file with `/reload`**: the client reads a TOC's file list only when it starts. Restart the client.
- **Pushing code that is unformatted or doesn't lint**: CI fails the PR. Run `stylua --syntax lua51`, `luac -p` and `luacheck .` from the add-on root before committing.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/Gogo1951/Good-to-Go/issues), as a Defect or a Request.
- **Bug reports**: include game version and locale, class and level, repro steps, and the relevant macro body or chat output. The Diagnostic Tools panel (the last entry under Good to Go in the Options Interface) builds pasteable reports; its Event Log and context reports answer most "my macro didn't update" and "the window did nothing" tickets.
- **Discord**: <https://discord.gg/eh8hKq992Q>.
- **PR guidelines**: keep a PR to one change; match house style (StyLua defaults with `--syntax lua51`, a clean `luac -p` and a clean `luacheck .`); ship a migration supported for 30 days with any change to saved data's shape, every piece tagged `MIGRATION (remove after YYYY-MM-DD)`; check any macro body or chat message change against its 255-byte ceiling on ruRU with Diagnostics' Message Length report (Style Guide → MESSAGES → Message Length); and update this document when the architecture or the file map changes.
- **PR descriptions say what a player will notice**, in plain language, the way release notes do: what changes in game and why it matters to them. Commit messages carry the developer detail.
