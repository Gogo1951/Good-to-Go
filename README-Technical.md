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
│       ├── ci.yml                                  Calls Common-Core: shared files, LF, externals, luac, luacheck, StyLua, Tests/Run.lua
│       ├── issue-labels.yml                        Calls Common-Core: fills a new issue's missing labels
│       └── package.yml                             Calls Common-Core: a tag push releases to CurseForge and Wago
├── .gitignore                                      Shared from Common-Core
├── .luacheckrc                                     Lint config: WoW read globals, the add-on's globals, slash commands, popups
├── .pkgmeta                                        Externals; ignore list keeps READMEs, Tests, Tools, Data/Wrath, Data/Mainline out of the zip
├── Bindings.xml                                    Spellbook toggle, Buff Key CLICK binding, hidden migration binding
├── Data/                                           Static game data and ID-free constants
│   ├── Camelot/                                    WoW Forever's tables
│   ├── Data.lua                                    Names, replaced and legacy lists, palette, ceilings, registry, macro config, ns.Data
│   ├── Default-Settings.lua                        The ns.DATABASE_DEFAULTS table with scope reasons; AddDefaults blocks per feature
│   ├── Discovery/                                  Season of Discovery's tables, guarded opposite to Data/Vanilla/
│   ├── Flavor.lua                                  Flavor from the TOC: ns.FLAVOR, ns.EXPANSION, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── LICENSE-Pet-Data                            MIT notice for the pet ability and tameable beast rows
│   ├── LICENSE-Trainer-Data                        MIT notice for the trainer spell rows
│   ├── Mainline/                                   Forward-prep; no TOC lists it, .pkgmeta ignores it
│   ├── Message-Languages.lua                       Send Messages In languages, every editable whisper's default text, saved-text accessors
│   ├── Mists/                                      Mists of Pandaria Classic's tables
│   ├── TBC/                                        TBC Anniversary's tables
│   ├── Vanilla/                                    Classic Era's tables; each file returns early on Season of Discovery
│   └── Wrath/                                      Forward-prep; no TOC lists it, .pkgmeta ignores it
├── Diagnostics/                                    Copied framework; this add-on's part is Manifests.lua plus Manifests-* and Message-Length-*
├── Features/                                       One folder per feature; Core.lua owns the event frame
│   ├── Announcements.lua                           Prints, WarnOnce, sent-line sign-off, whisper queue, buff ask and editable-whisper builders
│   ├── Buff-Duty/                                  Click-to-cast window of buffs you can give, and the Buff Key
│   │   ├── Buff-Duty-Auras.lua                     GUID aura cache, dirty set and generation, strengths, durations, bounce memory, Has
│   │   ├── Buff-Duty-Button-Attributes.lua         The one attribute writer, ns.SetBuffButtonAttributes, shared by the window and the Buff Key
│   │   ├── Buff-Duty-Cast-Results.lua              Cast attempts, aura-bounced and pet refusals, the Forever resurrection note
│   │   ├── Buff-Duty-Castable.lua                  Creates ns.BuffDuty; BuildBuffs, CastText, KnownRanks, RankFor, HasAnythingToOffer
│   │   ├── Buff-Duty-Events.lua                    Event module, handler table, subscriptions, combat-log sync, safety pause; loads first
│   │   ├── Buff-Duty-Favors.lua                    Return the Favor memory; combat-log and Forever aura detection
│   │   ├── Buff-Duty-Frame.lua                     Anchor and content frames, render and hide, title and close, Hide in Combat, key tip
│   │   ├── Buff-Duty-Groups.lua                    Party sections, group icons, member and pet rows
│   │   ├── Buff-Duty-Icon-State.lua                Creates the icon pool; cooldown swipes, time-left sliver, range fade, stale dim
│   │   ├── Buff-Duty-Icons.lua                     Secure list icons: acquire from the pool, tooltip, PreClick and PostClick
│   │   ├── Buff-Duty-Key-Picker.lua                What the Buff Key casts next: candidates, readiness, GCD, mana, reach
│   │   ├── Buff-Duty-Keys.lua                      GtGBuffKey button, skip memory, press reuse, binding migrations
│   │   ├── Buff-Duty-Layout.lua                    Redraw signature, held layout, icon grids, line placing
│   │   ├── Buff-Duty-Lookups.lua                   Data rows to live entries, weapon layers, BuildCategories
│   │   ├── Buff-Duty-NPCs.lua                      Targeted friendly NPC row and its buff cycle
│   │   ├── Buff-Duty-Other-Classes.lua             Party-Buffs counts, ask cooldowns, ask and whisper senders
│   │   ├── Buff-Duty-Outsiders.lua                 Target and Return the Favor sections, pet owner from the tooltip
│   │   ├── Buff-Duty-Party-Buffs.lua               Party-Buffs plain icons, their clicks, the hover menu on ns.MenuKit
│   │   ├── Buff-Duty-Pets.lua                      Pet rows, pet holds, owner class, charmed check
│   │   ├── Buff-Duty-Position.lua                  Position saved by the top-right corner, and its migration
│   │   ├── Buff-Duty-Resurrections.lua             Resurrection pick, resurrection icon, pending suppression
│   │   ├── Buff-Duty-Self.lua                      Self Buffs section and the Soulstone icon
│   │   ├── Buff-Duty-Settings.lua                  Seeds and cleans audience, selfRefresh, tankWhen, weapon choices; migrations
│   │   ├── Buff-Duty-Switches.lua                  Feature and per-class switches, the two tracking predicates, close for the session
│   │   ├── Buff-Duty-Units.lua                     Who can be buffed, roster hold, roles, range, phase shift, labels, SingleIcon
│   │   ├── Buff-Duty-Weapons.lua                   Enchant reads, layers, imbue landing, weapon rows, REPLACE_ENCHANT accept
│   │   └── Buff-Duty.lua                           Refresh, ShowsHere, debounce, backstop, event handlers, setup
│   ├── Core.lua                                    Event frame and dispatch, ns.EVENT_NAMES, InitializeDatabase, prune, ns:ApplyProfile
│   ├── Enhanced-Spellbook/                         Own spellbook window, a macro per spell, What's Next
│   │   ├── Action-Bars.lua                         Action-bar scan for glows, Mark Placed and placement
│   │   ├── Category-Menu.lua                       Category header menu, applying an option to every macro under it
│   │   ├── Class-Config.lua                        Empties other classes' data; resolves tags, groups, forms, toggles; PAGE_TAGS
│   │   ├── Class-Spells.lua                        Walk of class and profession spells across both book engines
│   │   ├── Consumable-Macros.lua                   Read-only Consumable Macros tiles on the page
│   │   ├── Dynamic-Rank.lua                        Rewrites placed target-rank macros as units change; mouseover poll; pre-combat rewrite
│   │   ├── Group-Handover.lua                      A learned successor takes a replaced spell's macro and settings
│   │   ├── Grouped-Spells.lua                      Grouped spells option, one macro casting a group
│   │   ├── Key-Bindings.lua                        GoodToGo_ToggleSpellbook and the binding migration
│   │   ├── LICENSE-Enhanced-Spellbook              MIT notice shipped with the folder
│   │   ├── Macro-Body.lua                          Macro text: CastBody, RankFor, stance line, MacroBody
│   │   ├── Macro-Builder/                          The ns.macros builder, Conditionals, Cast Sequence, docked panels
│   │   │   ├── Cast-Sequence-Panel.lua             Cast Sequence docked panel
│   │   │   ├── Cast-Sequence.lua                   Steps, resets, tail text, setters
│   │   │   ├── Conditionals-Panel.lua              Conditionals docked panel
│   │   │   ├── Conditionals-Rows.lua               Conditionals panel rows and condition menus
│   │   │   ├── Conditionals.lua                    Conditions, skip and block reasons, clauses, setters
│   │   │   ├── Docked-Panel.lua                    Shared panel shell, heading and byte meter
│   │   │   ├── Macro-Builder.lua                   CollectMacros: every page macro, copies, folds
│   │   │   ├── Panel-Widgets.lua                   Slots, dropdowns, grips and remove buttons the panels share
│   │   │   ├── Slot-Spells.lua                     Spell shown in a Conditionals or Cast Sequence slot, by ID
│   │   │   └── Spell-Pick.lua                      Owner-based spell pick mode and cursor drops
│   │   ├── Macro-Button-Notes.lua                  Tile option subtext and learnable-rank note
│   │   ├── Macro-Button.lua                        A page tile: click, drag, tooltip, glow
│   │   ├── Macro-Copies.lua                        Duplicates, COPIED_SETTINGS, resets, settings moves
│   │   ├── Macro-Delete.lua                        Delete one or all; remove a focus copy
│   │   ├── Macro-Kinds.lua                         Macro kinds, the kind decision, kind defaults
│   │   ├── Macro-Lookup.lua                        Slot limits, names, icons, FindMacroIndex, ownership, legacy names
│   │   ├── Macro-Menu-Sections.lua                 Right-click menu sections: target, rank, conditionals, sequence
│   │   ├── Macro-Menu-Utilities.lua                Menu text blocks, Make Default, rebuilt-macro lookup
│   │   ├── Macro-Menu.lua                          A tile's right-click menu
│   │   ├── Macro-Options.lua                       Option defaults, OFFERED predicates, option get and set
│   │   ├── Macro-Rank-Option.lua                   Target-rank and fixed-rank options
│   │   ├── Macro-Settings.lua                      Per-spell settings keys, storage, the option key list
│   │   ├── Macro-Sync.lua                          SyncMacro and SyncAt, PickupMacro, 255 guard, combat queue, Macro UI wait
│   │   ├── Macro-Tags.lua                          Tag line, identities, tag assignment
│   │   ├── Menu-Utilities.lua                      Menu tooltips, label helpers, simple option tables
│   │   ├── Mute-Errors.lua                         Global GtGMute
│   │   ├── Page-Categories.lua                     Category and subcategory of each tile
│   │   ├── Page-Settings.lua                       Page toggles, sort, Mark Placed records
│   │   ├── Ranged-Attacks.lua                      Folds the ranged attacks into one Shoot macro
│   │   ├── Spell-Rank-Lines.lua                    Rank rows, states and labels; tooltip rank lines
│   │   ├── Spell-Ranks-Tooltip.lua                 Ability tooltip ranks hook and its level-keyed cache
│   │   ├── Spell-Ranks.lua                         Known and unknown ranks, learn levels, baseID
│   │   ├── Spellbook-Controls.lua                  Settings menu, filter and sort dropdowns, macro count
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
│   │   ├── Spellbook-Utilities.lua                 Spell name requests, UTF-8 trim, shared widgets and helpers
│   │   ├── Spellbook-Widgets.lua                   Filter box, dropdown fallback, menu tooltips, ElvUI skin
│   │   ├── Spellbook-Window.lua                    GoodToGoSpellbookFrame, tabs, fit to screen, panel docking
│   │   ├── Target-Priority.lua                     Target priority units and per-kind defaults
│   │   ├── Trainer-Recording.lua                   Records class trainer spells and levels per class
│   │   ├── Unlearned-Spells.lua                    Walk of trainer spells not yet known
│   │   ├── Usable-Items.lua                        Equipped Use: slots for the use-items option
│   │   └── Whats-Next/                             What's Next, Pet What's Next and Pet Spell Book tabs
│   │       ├── Pet-Spellbook.lua                   Pet Spell Book rows, pickup and class gate
│   │       ├── Whats-Next-Controls.lua             Filter and sort controls, footer
│   │       ├── Whats-Next-Layout.lua               Metrics, sections and pagination
│   │       ├── Whats-Next-Models.lua               The three page models; grimoire names; beast list in tooltips
│   │       ├── Whats-Next-Page.lua                 Shared list page builder, tooltip, refresh
│   │       ├── Whats-Next-Pet.lua                  Pet and demon ability rows, pet settings
│   │       └── Whats-Next.lua                      Class rows, statuses, sources
│   ├── Group-Context-Migration.lua                 MIGRATION only: group settings onto the four context checkboxes
│   ├── Inventory-Report/                           Every character's bags and bank in item tooltips
│   │   ├── Inventory-Report-Recording.lua          Snapshots, packed format, Forget; handlers run by the Restocker module
│   │   └── Inventory-Report-Tooltip.lua            Tooltip block, other-character cache, delayed hook
│   ├── Item-Info.lua                               Session item memo, GET_ITEM_INFO_RECEIVED waiters, window warming, item links
│   ├── Key-Bindings.lua                            Binding section header, ns:OpenKeyBindings routes, UPDATE_BINDINGS repaint
│   ├── Legacy-Migration.lua                        MIGRATION only: legacy settings import and popups; Automated Appreciation retirement
│   ├── Macros-for-Consumables/                     The consumable macros: scan, rank, compose, write
│   │   ├── Action-Button-Text.lua                  Macro-name text on action buttons, by font-string alpha
│   │   ├── Character-Key-Migration.lua             MIGRATION only: Forever characters re-keyed by whole name
│   │   ├── Default-Profile-Migration.lua           MIGRATION only: characters moved off Default; list choices carried
│   │   ├── Ignore-List.lua                         Character and Global Ignore Lists, scopes, mini-map edits, logout prune
│   │   ├── Item-Cache.lua                          Session-only consumable records, CONSUMABLE_TABLES, cold retry budget
│   │   ├── Macro-Notes.lua                         Class click notes for the mini-map menu and Spellbook tiles
│   │   ├── Macros/                                 Definition protocol, engine, writer, one file per macro
│   │   │   ├── Bandage.lua
│   │   │   ├── Body-Builder.lua                    Standard body, OOC block, byte trims, ns.BuildStateKey
│   │   │   ├── Definitions.lua                     Definition and conjure protocols, ns.RegisterMacroType
│   │   │   ├── Engine.lua                          The pipeline ns.UpdateMacros, Macro UI deferral, ns.ToggleMacroSetting, ns.ResetMacroState
│   │   │   ├── Explosive.lua                       At-player or toss click layout
│   │   │   ├── Food.lua                            Buff food, pet-buff override, scroll mode, Stealth Eating, racial hooks
│   │   │   ├── Health-Potion.lua                   Ranked; healthstone stacking; OOC food
│   │   │   ├── Healthstone.lua                     Ranked; Warlock conjure clicks
│   │   │   ├── Integration-Druid-Macro-Helper.lua  DruidMacroHelper-wrapped potion and healthstone bodies
│   │   │   ├── Mana-Gem.lua                        Ranked; optional mana runes
│   │   │   ├── Mana-Potion.lua                     Ranked; OOC water
│   │   │   ├── Runtime.lua                         GtG* macro globals, wrong-zone bug report, Connoisseur aliases
│   │   │   ├── Signatures.lua                      Friendly-target test; target and group signatures
│   │   │   ├── Smart-Spell.lua                     Conjure lists sorted at load; rank pick
│   │   │   ├── Soulstone.lua                       Single winner; Warlock conjure click
│   │   │   ├── Tools-Forsaken.lua                  Cannibalize target test and cast
│   │   │   ├── Tools-Hunters-Pet-Food.lua          Pet food pick, quest signature, pet-buff override
│   │   │   ├── Tools-Hunters.lua                   Feed Pet tiers, pet spells, dead-pet detection
│   │   │   ├── Tools-Mages.lua                     Mage conjure resolvers
│   │   │   ├── Tools-Rogues.lua                    The Poisons macro and on-demand poison picks
│   │   │   ├── Tools-Troll.lua                     Rapid Regeneration lead cast and combat line
│   │   │   ├── Tools-Warlocks.lua                  Healthstone and Soulstone resolvers
│   │   │   ├── Water.lua                           Shadowmeld drinking; Cannibalize where it restores mana
│   │   │   └── Writer.lua                          The one writer ns.WriteMacroBody, ns.TryCreateMacro, delete, macros-ready line
│   │   ├── Macros-for-Consumables-Core.lua         Event module, two-flag throttle, combat-guard ordering, profile re-apply
│   │   ├── Macros-for-Consumables-Utilities.lua    When to Use test, max level, racial cooldown timer, game names
│   │   └── Scanner/                                Bag scan, auras, ranking ladder
│   │       ├── Scanner-Auras.lua                   Shared aura snapshot, early re-application, baselines, UNIT_AURA
│   │       ├── Scanner-Character.lua               Class and race flags, spell names, profession ranks
│   │       ├── Scanner-Diagnostics.lua             Selection candidates, kept only while Diagnostics is on
│   │       ├── Scanner-Inventory.lua               The scan ns.ScanBags: bag walk, usability gates, dispatch
│   │       ├── Scanner-Ranking.lua                 RANKING_PRIORITY, winners, ranked lists
│   │       └── Scanner-Scrolls.lua                 Best scroll per type; scroll overrides
│   ├── Menu-Kit.lua                                Shared Menu Kit copy: plates, entry kinds, layout, cursor tests
│   ├── Minimap-Button.lua                          LDB launcher, LibDBIcon registration, food icon, show and hide
│   ├── Minimap-Menu.lua                            The mini-map menu's contents, the button click table, flyouts, placement, close timer
│   ├── Rank-Watch/                                 Low ranks cast in the group; no Mists TOC loads it
│   │   ├── LICENSE-Rank-Watch                      MIT notice for Rank Sentinel
│   │   ├── Rank-Watch-Check.lua                    The low-rank check, messages, whisper queue, Opt Out handling
│   │   ├── Rank-Watch-Cluster.lua                  RANKSENTINEL leader election, NOTIFY and SYNC sharing
│   │   ├── Rank-Watch-Core.lua                     Settings accessor, event module, switch, standalone add-on, ignore command, reset listener
│   │   ├── Rank-Watch-Detection-Combat-Log.lua     Vanilla and TBC TOCs: combat-log detection
│   │   ├── Rank-Watch-Detection-Forever.lua        Camelot TOC: cast handshake, pet, group auras, damage meter
│   │   ├── Rank-Watch-Level-Up.lua                 Ability Alerts While Leveling: the trainer's spells printed on a ding
│   │   └── Rank-Watch-Lookups.lua                  Ladders joined by ns.SPELL_GROUPS, fast reject, tracked state, rank text
│   ├── Readiness-Report/                           The private report printed on a ready check
│   │   ├── Readiness-Report-Example.lua            The panel's sample lines
│   │   ├── Readiness-Report-Probes.lua             Stateless live reads: group, weapons, gear, talents
│   │   └── Readiness-Report.lua                    Clauses, ns.ReadinessAsks* gates, line assembly, the READY_CHECK module
│   ├── Replaced-Addons.lua                         Turns off ns.REPLACED_ADDONS at login, offers the reload
│   ├── Restock-Reminders-Migration.lua             MIGRATION only: every restock reminder mode onto Simple, once
│   ├── Restocker/                                  Restock Lists, merchant buying, bank restocking, reminders, upgrades, Staples
│   │   ├── Restocker-Bags.lua                      Bag and bank container lists, slot scans, empty-slot placement
│   │   ├── Restocker-Bank-Moves.lua                Single bank and bag moves, overshoot pull, BankHasRestockSpace
│   │   ├── Restocker-Bank-State.lua                Run state, Keep freeze, stuck message, bank open and close
│   │   ├── Restocker-Bank-Tidy.lua                 Partial-stack count and one-merge consolidation
│   │   ├── Restocker-Bank-Visit.lua                Run coroutine, watchdogs, in-flight and lock gates, ping-paced OnUpdate
│   │   ├── Restocker-Core.lua                      Login setup, logout packing, master switch
│   │   ├── Restocker-Crafting-Reagents.lua         Poison recipe index and the reagent order
│   │   ├── Restocker-Events.lua                    Handler table, WhileEnabled, module dispatcher (Inventory Report's too)
│   │   ├── Restocker-Inventory-Model.lua           The summary and slots model a scan returns, best-fit merge slot
│   │   ├── Restocker-List.lua                      Add, remove, undo, New flags, item-data waits and their subscription
│   │   ├── Restocker-Merchant-Report.lua           Delivery wait, the run's report, out-of-gold line
│   │   ├── Restocker-Merchant.lua                  Purchase orders, reagent gate, buy loop, merchant open and close
│   │   ├── Restocker-Purchase-Space.lua            The bag-space budget a merchant run spends down
│   │   ├── Restocker-Reminders.lua                 Low and out split, reminder headlines and lines
│   │   ├── Restocker-Saved-Format.lua              One-line row codec, inflated at login, packed at logout
│   │   ├── Restocker-Saved-Lists.lua               Named lists, each character's choice, new, copy, rename, delete, prune
│   │   ├── Restocker-Shortfall.lua                 Shortfall and grocery lists, short-row test, after-visit reminder
│   │   ├── Restocker-Slash-Command.lua             The /restock parser
│   │   ├── Restocker-Starter-Categories.lua        Staples rows: ns.STARTER_LIST_CATEGORIES, caps, classes, pre-ticks
│   │   ├── Restocker-Starter-List.lua              Staples logic: chain resolution, ticks, stacks, login trigger
│   │   ├── Restocker-Starter-Sections.lua          Staples sections, display order, stack choices and labels
│   │   ├── Restocker-Starter-Window.lua            The Staples window: layout, stack dropdowns, Escape handoff
│   │   ├── Restocker-Town-Reminder.lua             In-town arrival reminder, taxi rule, arming, login item requests
│   │   ├── Restocker-Trace.lua                     Trace lines (ns.RestockerDebug) into the Event Log
│   │   ├── Restocker-Upgrade.lua                   Level-ladder upgrades, tier sort by rank
│   │   ├── Restocker-Window-Bag-Menu.lua           Add Item From Bags menu
│   │   ├── Restocker-Window-Categories.lua         Item-type pane, group selection, measured pane width
│   │   ├── Restocker-Window-Cells.lua              Toggle and reputation cells: state, toggle, paint, tooltips
│   │   ├── Restocker-Window-Column-Header.lua      Column captions, Keep heading, group bands, bulk-set headings
│   │   ├── Restocker-Window-Columns.lua            COLUMNS, measured widths, layout walk, row metrics
│   │   ├── Restocker-Window-Filter.lua             View building, groups, filter, sort; pure data
│   │   ├── Restocker-Window-Footer.lua             Orders status and tooltip, the undo offer
│   │   ├── Restocker-Window-Frame.lua              Portrait frame shared with Staples, bands, ElvUI skin
│   │   ├── Restocker-Window-Header.lua             Filter, add box, Add, Pick Staples, add notices
│   │   ├── Restocker-Window-List-Bar.lua           Footer list controls: selector and its menu, Used by
│   │   ├── Restocker-Window-List-Manage.lua        Manage Lists menu, Delete confirm, rename field
│   │   ├── Restocker-Window-Menus.lua              Reputation menu and column bulk-set menu (AceGUI)
│   │   ├── Restocker-Window-Render.lua             The full redraw ns.UpdateRestockList, shortfall and cold-row repaints, row pool
│   │   ├── Restocker-Window-Reputation.lua         Standing labels, menu text, Rep tooltip body
│   │   ├── Restocker-Window-Rows.lua               Pooled rows: Keep box, remove, item binding
│   │   ├── Restocker-Window-Widgets.lua            Menu closer ns.CloseRestockMenus, cursor drop-add, menu fields, tooltips
│   │   └── Restocker-Window.lua                    Window build, geometry, empty state, show, hide, toggle
│   └── Utilities.lua                               Colors, client-difference accessors, secret tests, character keys, group context, spell links
├── Good-to-Go_Camelot.toc                          WoW Forever
├── Good-to-Go_Mists.toc                            Mists of Pandaria Classic; no Rank Watch feature or options files
├── Good-to-Go_TBC.toc                              TBC Anniversary
├── Good-to-Go_Vanilla.toc                          Classic Era, Season of Discovery included
├── Includes/
│   ├── Images/                                     Icon, window and menu art; Menu-Plate.tga is the Menu Kit's plate
│   ├── Libraries/                                  Vendored libraries, refreshed from .pkgmeta at release
│   └── Sounds/                                     Low-Battery.ogg, the restock reminder sound
├── LICENSE                                         MIT
├── Locales/                                        AceLocale strings; enUS.lua is the source of truth
├── Options/                                        AceConfig panels, one folder per feature
│   ├── Buff-Duty/                                  Buff Duty panel and its Group Buffs, Self-Buffs and Weapon Buffs sub-panels
│   ├── Enhanced-Spellbook/                         Switch, tooltip ranks, Delete Macros
│   ├── Inventory-Report/                           Switch and Recorded Characters with Forget
│   ├── Macros-for-Consumables/                     Consumable Macros, Class & Race, Ignore List
│   ├── Options-Feature-Switches.lua                Master switch records ns.FEATURES and ns.FindFeature
│   ├── Options-Feedback-Support.lua                Level Up paragraphs, links, version line
│   ├── Options-General.lua                         Root panel: welcome, mini-map, Features, Key Bindings, /Commands
│   ├── Options-Kit.lua                             Shared Options Kit copy: grid, rows, item lists, registry, guarded opener
│   ├── Options-Message-Composer.lua                Whisper composer: language, message rows, tokens, too-long line, Example, Send Test
│   ├── Options-Profiles.lua                        Stock AceDBOptions table with the migration's noDefaultProfiles
│   ├── Options-Utilities.lua                       Kit strings, Good to Go's own widths, group context checkboxes, feature-off line
│   ├── Options-Widgets.lua                         Icon checkbox AceGUI widget type
│   ├── Options.lua                                 Panel registration and tree order, /gtg and /restock
│   ├── Rank-Watch/                                 Rank Watch, Reported Ranks and Ignored Players; no Mists TOC loads it
│   ├── Readiness-Report/                           Readiness switches built from SECTIONS; Reset; Example
│   └── Restocker/                                  Switch, Gold Reserve, reminders and threshold, auto-open toggles
├── README-Notes.md                                 Where Good to Go departs from the Style Guide
├── README-Technical.md                             This document
├── README-Testing.md                               Manual test plan
├── README.md                                       Player documentation
├── Tests/
│   └── Run.lua                                     Offline tests, Lua 5.1, run by CI: event names, Forever combat log, prune, log noise
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

- **One frame for the whole add-on** (`Features/Core.lua`), so the Diagnostics Event Log taps every event in one place (`ns:LogEvent`, gated on `ns.diagnostics.logging`, read first so logging-off is free).
- **`ns.EVENT_NAMES`** is the one list; the dispatcher and Diagnostics' Event Registration report both read it. Flavor-guarded appends: `COMBAT_LOG_EVENT_UNFILTERED` only when `ns.FLAVOR ~= "Camelot"`; `PLAYER_FOCUS_CHANGED` only when `ns.FLAVOR ~= "Vanilla"`.
- **Event modules.** `ns.RegisterEventModule(name, dispatch)`; subscribe with `ns.SetModuleEvent(name, event, on, ...units)`.
  - `SetModuleEvent` asserts the event is in `KNOWN_EVENTS` and the module exists, so a typo stops the load. `Tests/Run.lua` catches a missing `ns.EVENT_NAMES` entry before that (Tests below).
  - `RefreshRegistration` registers each event once while any module (or `CORE_EVENTS`) wants it; `RegisterUnitEvent` only while every subscriber filters and the union is two units or fewer. The dispatch loop filters on the first argument per module.
- **Modules hear an event in load order:** `KeyBindings`, `ItemInfo`, `ConsumableMacros`, `ReadinessReport`, `Restocker` (the Inventory Report rides it), `RankWatch`, `LevelUpAlerts` (neither on Mists), `BuffDuty`, `Spellbook`.
- **Features subscribe only while on**, each master switch subscribing and releasing its own events. Exceptions, on purpose:
  - `ConsumableMacros` stays subscribed with `macrosEnabled` off: its scan feeds the Readiness Report and the mini-map.
  - `KeyBindings` (`UPDATE_BINDINGS`) and `LevelUpAlerts` (`PLAYER_LEVEL_UP`, its switches read inside `LevelUpLines`) are always on.
  - `ReadinessReport`'s `PLAYER_LOGIN` always runs, to sync `READY_CHECK` (`ns.SyncReadinessReportEvents`).
  - `ItemInfo` holds `GET_ITEM_INFO_RECEIVED` only while a waiter exists (Caching).
- **Handler tables behind modules:** `ns.SetBuffDutyEventHandler`, `ns.SetRankWatchHandler`, `ns.restockerEventHandlers`, and the Spellbook's `EVENT_HANDLERS` map of `ns:On<X>` names resolved when the event fires. A second registration silently replaces the first.
- **Core's own events.** `CORE_EVENTS` stay registered; Core handles them before any module:
  1. `PLAYER_LOGIN`: `ns.TurnOffReplacedAddons`, `InitializeDatabase`, `ns.RegisterOptionsPanels` (the Profiles panel binds to `ns.db`), `ns.RegisterMinimapIcon`. Only then do modules hear `PLAYER_LOGIN`. Nothing protected, so a mid-combat login still runs it.
  2. `PLAYER_ENTERING_WORLD`: `ns:PrintWelcome` once a session (`welcomePrinted`): `CHAT_LOADED` if `showWelcome`, then `ns.PrintLegacyNotices`, then `ns.OfferLegacySteps` or else `ns.OfferReplacedReload`.
  3. `PLAYER_LOGOUT`: `SaveProfileChoiceWhenUnnamed`.
- **Pacing by feature:**

| Feature | Pacing |
|---|---|
| Consumable Macros | Two flags (`isUpdatePending`, `isTickScheduled`) on an OnUpdate tick, `UPDATE_THROTTLE` after the first request of a burst; not debounced to the last. Cold items retry on a literal timer, at most `DATA_RETRY_MAX_ATTEMPTS` |
| Buff Duty | One-flag `REFRESH_DELAY` timer every trigger funnels through; `BACKSTOP_INTERVAL` ticker for expiry, deaths and disconnects; `RANGE_INTERVAL` alpha ticker; `Data.SAFETY_PAUSE` after every loading screen |
| Enhanced Spellbook | Next-frame coalescing behind one pending flag per kind of work (`Spellbook-Events.lua`); Dynamic Rank's one pending scope (`QueueRankRewrite`) and `MOUSEOVER_POLL_SECONDS` poll |
| Restocker | A literal guard against a doubled `MERCHANT_SHOW`; a ping-paced OnUpdate for the bank run; `BUY_SETTLE_TIMEOUT` behind the merchant report; `SETTLE_DELAY` before closing reminders; `ARRIVAL_SETTLE_DELAY`, `LOGIN_SETTLE_DELAY` and `REMINDER_COOLDOWN` for the town reminder; `STARTER_POPUP_DELAY`; Staples repaints coalesced to one per frame |
| Rank Watch | Held whispers retry on one armed timer (`ArmRetry`: `TARGET_BUSY_RETRY`, `RANK_TEXT_RETRY`); sends ride the shared whisper gap; `JOIN` after `JOIN_DELAY`; Forever: `METER_POLL` damage-meter ticker out of combat plus one read on leaving combat |
| Inventory Report | Bank re-read after `BANK_SETTLE_DELAY`; tooltip hook after `TOOLTIP_HOOK_DELAY` |

### Combat Lockdown

- **Refuse, never queue.** `ns:OpenOptionsPanel` (`Options-Kit.lua`) is the one gate for `/gtg`, `/restock config`, Shift + Middle-Click and the menu's Options row. `ns:OpenKeyBindings` (`Features/Key-Bindings.lua`) refuses the same way with `CHAT_KEY_BINDINGS_IN_COMBAT`. The Macros panel's Open Macros Window refuses with `CHAT_OPTIONS_IN_COMBAT`.
- **Consumable Macros defer.**
  - `ns.UpdateMacros` in combat calls `ns.RequestUpdate` and returns. `ns.RequestUpdate` in combat only sets pending; an armed tick that finds combat disarms itself; events below `OnEvent`'s guard only set pending.
  - `PLAYER_REGEN_ENABLED` re-reads what was put off (`ns.RereadProfessionSkillsIfPending`, `ns.RereadTargetIfPending`), then re-requests if anything is pending.
  - A forced rebuild keeps its force across the wait, because `UpdateMacros(true)` wipes the state keys before the combat check.
  - Handlers above the guard keep signatures current mid-fight (Consumable Macros → Events). Baselines below it stay honest because every scan re-records them.
  - Forever hides target identity mid-fight: `ns.TargetSignatureChanged` reads nothing and owes the reading. Profession header expansion waits for combat end or the Skills tab closing.
- **The Enhanced Spellbook defers syncs and refuses actions.**
  - `ns.SyncAllMacros` in combat calls `ns.QueueMacroSync`; `ns:OnPlayerRegenEnabled` (`Macro-Sync.lua`) runs `RefreshMacros` if pending.
  - `ns.PickupMacro`, `ns.DeleteAddonMacros`, `ns.DeletePageMacro`, `ns.RemoveFocusCopy` and `ns.StartSpellPick` refuse with `ERR_NOT_IN_COMBAT`.
  - Tooltip ranks, `ns.CloseGameSpellbook`, docked-panel keys and `ns.MigrateSpellbookBinding` skip silently.
  - Dynamic Rank skips too; `ns:OnPlayerRegenEnabled` always queues `ns.QueueRankRewriteAll`, since the target or mouseover may have changed meanwhile. `PLAYER_REGEN_DISABLED` runs `ns.RewriteRanksBeforeCombat` (the last moment such macros can change) and `ns.CancelSpellPick`.
- **Buff Duty's buttons are secure.**
  - Refresh, render, hide, `ns.DropBuffDutyTargetIcons`, the settings apply and drag-start all refuse. A settings change (or a drag let go in combat) queues behind `settingsPending`.
  - A roster or target change mid-fight dims icons (`ns.MarkBuffDutyRosterStale`, `OUT_OF_RANGE_ALPHA`). Only alpha and the `CooldownFrameTemplate` children change in combat.
  - `PLAYER_REGEN_ENABLED` applies pending settings, prunes the aura cache, marks every aura dirty and refreshes.
  - Hide in Combat is a state driver (`[combat] hide; show`) on the anchor frame, so the client hides it without the add-on touching a protected frame.
  - A Buff Key press in combat clears its pick and shows `ERR_NOT_IN_COMBAT`. Camelot's aura favors are not read in combat.
- **The Inventory Report defers one read:** `bagsChangedInCombat`, read on `PLAYER_REGEN_ENABLED`. A mid-fight logout saves the bags as of the fight's start.
- **The Readiness Report doesn't wait.** It only reads auras and the last scan, and is silent while auras are secret.
- **The Restocker has no combat guard.** Nothing it does is protected, a merchant or bank window can't open in combat, and a logout mid-combat must still pack the lists. The Staples login trigger skips a login that lands in combat.
- **Skipped and retried at next login:** `ns.RetireAutomatedAppreciation`'s macro deletes, `ns.MigrateSpellbookBinding`, `ns.MigrateBuffKeys`.

### Main Pipeline: Consumable Macros

**Events** (`Macros-for-Consumables-Core.lua`, module `ConsumableMacros`):

- Subscribed for the whole session, whatever `macrosEnabled` says (Event Loop). `UNIT_PET` is filtered to the player. On demand through `ns.SetEventRegistered`:
  - `UNIT_AURA` (player and pet), only while buff food, scrolls or pet buff food is live (`ns.UpdateAuraTracking`).
  - `QUEST_LOG_UPDATE`, Hunters only, re-decided every arrival (`RefreshArrivalState`).
  - `UNIT_SPELLCAST_SUCCEEDED`, decided once at login (`InitializeConsumableMacros`): Mage, Warlock, Forsaken, Troll with Rapid Regeneration, Hunter. `UNIT_SPELLCAST_SENT`: Hunters only.
- **Above `OnEvent`'s combat guard, on purpose:** `PLAYER_LOGIN`, `UI_ERROR_MESSAGE`, `UNIT_PET`, `PLAYER_LEVEL_UP`, `PLAYER_LOGOUT` (Ignore List prune), `PLAYER_TARGET_CHANGED`, `GROUP_ROSTER_UPDATE`, both spellcast events, `SKILL_LINES_CHANGED`, and `PLAYER_ENTERING_WORLD`'s `ns.ApplyMacroNameVisibility` (alpha only). A value that changes and changes back mid-fight still reads as changed afterward.
- Busy events diff before requesting: `ns.TargetSignatureChanged`, `ns.GroupSignatureChanged`, `ns.OnUnitAura` (Well Fed, scroll baseline, pet buff), `ns.PetFoodQuestsChanged`, `ns.UpdateProfessionSkills`, `ns.SpellCastChangesMacros` (a secret spell ID requests anyway).
- `PLAYER_LEVEL_UP` takes the level from the event, re-resolves Hunter spells and wipes state. `PLAYER_ENTERING_WORLD` refreshes `ns.cachedPlayerLevel` / `ns.cachedMapID` and aura tracking, then requests now and again after a literal delay.
- Re-application recheck: one-shot `ScheduleExpiryRecheck` (`Scanner-Auras.lua`). Racial cooldowns rebuild through `ns.RacialSpellReady` (`Macros-for-Consumables-Utilities.lua`, shared by Cannibalize and Rapid Regeneration); a secret cooldown counts as on cooldown.

**Scan → Rank → Compose → Write** (`ns.UpdateMacros(forced)`, `Macros/Engine.lua`):

1. **Scan** (`ns.ScanBags`, `Scanner/Scanner-Inventory.lua`).
   - One aura snapshot (`ns.UpdateAuraTracking` returns it), handed to `ns.FindScrollOverrides`.
   - Sets the gates `ns.allowBuffFood`, `ns.allowConjuredFirst`, `ns.allowRestockLast`, and hands the current Restock List to `Ranking.SetScanRestockList`.
   - Walks `ns.CARRIED_BAG_IDS` into `ns.scannedItemCounts` / `ns.scannedItemLinks`. `ns.scrollOverrideIDs` and `ns.petBuffOverrideID` are forced nil in an arena or while `ns.AreAurasSecret()`.
   - Per item: skip scrolls (`ns.SCROLL_ITEM_LOOKUP`), `ns.CacheItemData`, then the usability gates (level, First Aid, Alchemy, Engineering, `requiredSpellID`, zones, `arenaOnly`, arena blocks).
   - Dispatches to **every** definition whose `itemTypes` claims the item and whose `accepts` passes. An ignored item only sets `ns.scannedIgnoredTypes[type]`.
2. **Rank** (`Scanner/Scanner-Ranking.lua`).
   - One list, `RANKING_PRIORITY`, drives `IsBetter` (single winner) and `CompareRankedCandidates` (ranked types) through `CompareRecords`, which also returns the deciding field for Diagnostics. It ends on item ID for determinism.
   - Gated steps: buff food, conjured-first, restock-last (Food/Water only). Ranked lists run with all three gates and `preferHybrid` off.
   - Ranked types keep up to `ns.MULTI_USE_MAX_ITEMS` in `topIDs`, from a per-type record pool.
   - Selection tables build lazily on the first scan, because definitions register after the scanner loads. Winners publish as `ns.bestSelection`; Food also publishes `ns.bestFoodID` / `ns.bestFoodLink`.
3. **Compose.**
   - With `macrosEnabled` off the scan still runs, plus `ns.ScanPetFood` (Hunters), `ns.UpdateMinimapIcon` and `ns.RefreshMenu`. Nothing is created, rewritten or deleted.
   - Per standard definition: delete the macro if `ns.IsMacroEnabled` is false. Otherwise, in order: `modifyItem`; `corpseSpell` / `leadSpell` / `combatSpell` (each only while the body uses the scanned pick); ranked `useIDs` (`ns.MULTI_USE_MACRO_TYPES` only); `getStackIDs`; the `outOfCombatTypeName` item behind `potionsUseFoodAndWater`; `ns.BuildDruidMacroOverride`; `buildModeOverride(context)`.
   - The body is the first of: the mode body, the DruidMacroHelper body, the standard body (`Body-Builder.lua`).
   - Custom definitions run afterward with their own state: Feed Pet (`Tools-Hunters.lua`, `currentPetFoodState`) and Poisons (`Tools-Rogues.lua`, `currentPoisonState`). Each no-ops off its class, so other classes leave those macros as last written; Poisons is never made where `ns.POISONS_SPELL_ID` is nil.
4. **Write** (`Macros/Writer.lua`). `ns.WriteMacroBody` is the one writer.
   - Creates through `ns.TryCreateMacro`: General tab (`perCharacter` omitted), refused once free slots fall to `ns.MACRO_SLOT_CUSHION` with a once-per-session `MESSAGE_MACRO_SLOTS_ARE_FULL`, resuming on its own when a slot frees.
   - A successful create schedules one `MESSAGE_MACROS_READY_TAB` per pass on a literal timer, since no single place knows the pass ended.
   - `EditMacro` only when `GetMacroBody` differs, always with `ns.QUESTION_MARK_ICON`.
   - Returns false on a failed write; every caller then leaves its state key unset.

**State keys and bodies:**

- Two layers stop a double write: the per-type key in `currentMacroState`, recorded only after the write landed, and the writer's body comparison.
- The key format is documented above `ns.BuildStateKey` and is lossless over every body input. Disjoint prefixes: mode `SCROLLS:`, DruidMacroHelper `DMH:`, standard starts with a digit or `none`, so every mode change rewrites. `ns.ResetMacroState` wipes every key (Feed Pet and Poisons included), the scroll and pet baselines and the target and group signatures.
- **Blizzard Macro UI.** It saves its edit box back on close, reverting a write the key already recorded. While `MacroFrame` is shown `ns.UpdateMacros` only marks pending; a one-time `OnHide` hook (`EnsureMacroUIHook`, tried on every pass) resets state and requests. A first open and close before any update is the one gap.
- Standard payload, top to bottom:

```
#showtooltip item:<id>   (or a [combat] / [dead] spell form)
<conjure block>          (GtGTipIf miss tips, /cast [btn:3]… [btn:2]…, /stopmacro)
/cast [dead] <corpse spell>, /cast [combat] <combat spell> + /stopmacro [combat]
/run GtGFire(<id>[,<oocID>])
<OOC block>              (/cast [nocombat,dead], /use [nocombat], /cast [nocombat,nostealth], /stopmacro [nocombat])
/use item:<id>           (up to ns.MULTI_USE_MAX_ITEMS ranked lines), stacked /use lines, appendBlock
```

  With nothing in bags the item line becomes `/run GtGTip("<miss>")` when the class can learn the conjure, else `/run GtGNoItem("<type>"[,1])`. A `leadCast` replaces everything below the conjure clicks.
- **Byte trims** against `ns.MACRO_BODY_MAX_LENGTH`, in order: Cannibalize lines, stacked healthstones, ranked fallbacks from the bottom (never rank 1), OOC stealth, the OOC block, the appended line, the combat cast. Each rebuilds through `ns.BuildStandardBody` with that input dropped. A body still too long is written anyway, with one `ns.WarnOnce` per macro. Lead-cast bodies are never trimmed. DruidMacroHelper trims its own `/use` lines, stealth and OOC block, then falls back to the standard body. Feed Pet sheds Dismiss, then Revive.
- **Multi-use macros** fall through to the next ranked item once the best runs out mid-combat, where the macro can't be rewritten. Safe only because every item in those types shares one cooldown; healthstone stacking is the opposite case (separate cooldowns, one press fires one of each).
- **`enabledMacros` and `showMacroNames` are account-wide while the choices are per-character.** The macros live in the shared General tab, so which ones exist is one choice for the account; `ns.ApplyConsumableMacrosProfile` only rebuilds bodies and aura tracking.
- **Conjures** (`ns.GetSmartSpell`): `Smart-Spell.lua` sorts every `ns.CONJURE_SPELLS` list in place at load, best first. Rank text comes from `C_Spell.GetSpellSubtext` only when the row carries a rank number. Food, Water and Healthstone downrank for a lower-level friendly target; Mana Gem, Soulstone, Refreshment Table and Soulwell ignore the target. Healthstone and Mana Gem skip a tier already carried (`checkUnique`). Fallback: the lowest rank actually known.
- **Arenas** are detected live (`IsInInstance`), never by zone list.
- **On Forever** scrolls trigger the GCD, so the scroll body fires one scroll per press.
- **Scrolls: required level orders, never gates.** `ns.FindBestScroll` (`Scanner-Scrolls.lua`, shared with Diagnostics) takes the first carried scroll in the level-sorted list; only class and the Ignore List skip one. A conflicting buff blocks a scroll only at an equal or larger amount.
- **Forsaken Cannibalize** (`Tools-Forsaken.lua`): a `corpseSpell` on Food and, only where `ns.CANNIBALIZE_RESTORES_MANA`, on Water. Written only while off cooldown and the target's creature type is in `ns.CANNIBALIZE_CREATURE_TYPE_IDS`; the macro's `[dead]` decides the rest.
- **Troll Rapid Regeneration** (`Tools-Troll.lua`). Out of combat a `leadSpell` that replaces the action while off cooldown (`ns.RapidRegenerationCast`). In combat, where nobody eats and the macro can't be rewritten, every Food body that eats its own pick or reads scrolls carries `/cast [combat]` + `/stopmacro [combat]` (`ns.RapidRegenerationCombatCast`), cooldown or not; the pet-food override body doesn't.
- **Stealth Eating** is one `enableStealthEating` key: Stealth for Rogues, Shadowmeld for other Night Elves. Never on a body with no item or the pet-buff override.
- **DruidMacroHelper** applies only with that add-on loaded and the return form known. The return form is a setting, not tracked: a macro can't be rewritten after a mid-combat form change.
- **Feed Pet tiers** (`Tools-Hunters.lua`): a tip-only stub while a pet spell besides Mend is missing; a cascade plus a tip without Mend Pet; the full cascade. `ns.petDeadDismissed` is set by `SPELL_FAILED_TARGETS_DEAD` only within `CALL_PET_ERROR_WINDOW` of sending Call Pet, and cleared by a live pet or a successful Call or Revive Pet.
- **Pet food** (`ns.ScanPetFood`) reads the same pass's `ns.scannedItemCounts`, so it runs only inside an update pass after `ns.ScanBags`; Feed Pet runs it even with the macro off, since the mini-map and Diagnostics read `ns.bestPetFoodID`.
- **Poison picks** resolve on demand (`ns.GetBestPoisonForHand`), never published.

**Ignore List** (`Ignore-List.lua`):

- Two additive halves, `profile.ignoreList` and `global.ignoreList`, read through `ns.IsIgnored`.
- `ns.GetIgnoreListForScope(scope, createIfMissing)` reads other profiles straight from `ns.db.sv.profiles` and creates a table only on a write. Promoting an item to Global clears it from every profile.
- Mini-map edits (`ns.IgnoreItem`, `ns.ClearIgnoreList`) act on this character's list only.
- Every edit calls `ns.ResetMacroState` and `ns.UpdateMacros(true)`.
- The logout prune drops only IDs `C_Item.DoesItemExistByID` denies, since Era and Season of Discovery share the file.

**Class notes** (`Macro-Notes.lua`): `ns.GetClassMacroNotes` feeds the mini-map menu's [Class] Macros row; `ns.AddConsumableMacroNotes` feeds the Spellbook's Consumable Macros tile tooltips. A row only for a spell known.

### Caching

- **Session memo** (`ns.GetItemData`, `Features/Item-Info.lua`), keyed by whatever the caller asked with (an ID on hot paths, a link at a merchant), never saved.
  - `ns.GetItemHyperlink` builds a white `|Hitem:ID|h[name]|h` link by hand while the item is cold; the client resolves it on hover. `ns.GetItemLabel` / `ns.UnbracketItemLink` give the bracketless form for the add-on's own windows; chat keeps brackets.
- **Waiters.** `ns.RequestItemInfoEvents(key)` / `ns.ReleaseItemInfoEvents(key)` are keyed, not counted; `GET_ITEM_INFO_RECEIVED` floods at login, so it stays registered only while a waiter exists. A release by a key not waiting is a no-op.
  - Keys: `"scan"` (consumable retry, `ns.RegisterDataRetry`), `"restocker"` (`ns.SyncRestockItemInfoSubscription`), `"window:<windowKey>"` through `ns.WarmItemCache` (the Staples window), and the What's Next grimoire waiter (`GRIMOIRE_WAITER`).
  - Answers fan out in order: `ns.OnRestockerItemInfoReceived` (forgets the miss, retries parked rows), the file-local window handler, `ns.OnConsumableItemInfoReceived` (rebuilds only when `ns.HasRawData`), `ns.OnWhatsNextItemInfoReceived`.
- **Window warming** (`ns.WarmItemCache(itemIDs, windowKey, onArrive)`): requests each cold ID, holds the window's waiter until every ID it handed in is answered, calls `onArrive` per answer. Never requests an ID already cached, already failed this session (file-local `failedItemIDs`) or one `C_Item.DoesItemExistByID` denies, since no answer may come and the wait would hold the event all session.
- **Options panels don't use the event.** `Kit.WarmItems` (`Options/Options-Kit.lua`) polls `C_Item.GetItemInfo` every `WARM_RETRY_SECONDS` up to `WARM_MAX_ATTEMPTS` per registry name and `NotifyChange`s when one lands.
- **Remembered misses** are kept only for a numeric ID and only while a waiter listens: the client answers once, so a miss taken while nobody listens would strand the item. The last release wipes them all; each answer reaches `ns.ForgetItemDataMiss` before anything retries. The comments in `Item-Info.lua` explain why time-scoped misses were rejected.
- **Consumable cache** (`Item-Cache.lua`): file-local, session-only, consumables only. A non-consumable returns `"IGNORE"` with no API call. `CONSUMABLE_TABLES` names each data table and the column where its item facts start. A row without facts falls back to `C_Item.GetItemInfo`. A cold item sets `dataRetry`; `ns.RegisterDataRetry` keys in `"scan"` and retries up to `DATA_RETRY_MAX_ATTEMPTS`. The event outlives the budget so a late answer still rebuilds; `ns.UnregisterDataRetry` refunds the budget.
- **The Restocker** parks adds, upgrades and Staples ticks on cold items rather than writing a row with the wrong name (Restocker → Adding and Removing).

### Flavors and Load Order

- **TOC order** (all four): libraries, `Locales/` (enUS first), `Data/Flavor.lua`, `Data/Data.lua`, `Data/Message-Languages.lua`, the flavor's `Data/{Game}/` files, `Data/Default-Settings.lua`; then `Features/`: `Core.lua`, `Replaced-Addons.lua`, `Legacy-Migration.lua`, `Utilities.lua`, `Menu-Kit.lua`, `Minimap-Menu.lua`, `Group-Context-Migration.lua`, `Restock-Reminders-Migration.lua`, `Announcements.lua`, `Key-Bindings.lua`, `Item-Info.lua`; the feature folders (Consumable Macros, Readiness Report, Restocker, Inventory Report, Rank Watch, Buff Duty, Enhanced Spellbook); `Macro-Notes.lua` + `Minimap-Button.lua`; `Diagnostics/`; `Options/` (`Options-Kit.lua` first, `Diagnostics/Options-Diagnostics.lua` next to last, `Options/Options.lua` last).
- **Load-time reads pin that order:**
  - `Default-Settings.lua` reads `ns.SCROLL_DATA` (flavor folder), `ns.SCROLL_CHECK_ORDER` (`Data.lua`) and `Data.DEFAULT_MESSAGE_LANGUAGE` (`Message-Languages.lua`).
  - `Utilities.lua` derives colors from `ns.PALETTE` / `ns.SPELL_LINK_COLOR` and reads `ns.EXPANSION`.
  - `Announcements.lua` captures `ns.GetColor`; `Legacy-Migration.lua` captures `ns.turnedOffAddOnTitles`, `ns.AddOnTitle`, `ns.JoinAddOnTitles` from `Replaced-Addons.lua`.
  - `Key-Bindings.lua` and `Item-Info.lua` call `ns.RegisterEventModule` at load, so `Core.lua` comes first.
  - Feature files capture each other's `ns` fields at load; each feature section below names the captures that matter.
- **`ns.FLAVOR` comes from the TOC's `## X-Flavor`**, never the client: Forever's `WOW_PROJECT_ID` has changed value once. `ns.EXPANSION` maps it (`Data/Flavor.lua`); `ns.IS_DISCOVERY` is Vanilla plus an active season (`C_Seasons`); `ns.DATA_FOLDER` names the folder that built the tables.
- **Seven flavor folders, one complete copy each.** Same file set everywhere; an empty table stands in where a flavor has no rows, so feature code never asks which flavor built a table. The Vanilla TOC lists `Data/Vanilla/` then `Data/Discovery/`; Vanilla files open with `if ns.IS_DISCOVERY then return end`, Discovery files with the opposite, so one set builds. `Data/Wrath/` and `Data/Mainline/` are forward-prep: no TOC lists them.
- **How the TOCs differ** besides the data folder and `## Interface`:
  - Camelot loads `Rank-Watch-Detection-Forever.lua` where Vanilla and TBC load `Rank-Watch-Detection-Combat-Log.lua`.
  - Camelot loads `Spellbook-Tabs.lua` and `Spellbook-Host-Modern.lua` where the others load `Spellbook-Host-Classic.lua`.
  - Mists loads no `Features/Rank-Watch/` file (Ability Alerts While Leveling included) and no `Options/Rank-Watch/` file. It still loads the Rank Watch data and Diagnostics files (Rank Watch below).
- **Names.** Folder, `ADDON_NAME` and AceLocale name: `Good-to-Go`. Saved table `ns.SAVED_VARIABLES_NAME`; `ns.OLD_SAVED_VARIABLES_NAME` is the pre-rename table (MIGRATION). Frames, bindings and popups carry `GoodToGo`; anything a macro body calls carries `GtG`, since every byte counts against `ns.MACRO_BODY_MAX_LENGTH`.
- **`ns.Version`** (`Core.lua`) reads TOC `Version` and is `"Dev"` while it still holds `@project-version@`.
- **Two homes for constants.** Buff Duty, Rank Watch and message-language constants sit on `ns.Data` (`Data.SAFETY_PAUSE`, `Data.RANK_WATCH`, `Data.WEAPON_LAYERS`, `Data.MESSAGE_LANGUAGES`, `Data.EDITABLE_MESSAGES`). Everything else sits directly on `ns`.

### Group Contexts

Every setting that turns a feature on or off by group follows the same rules.

- **One answer.** `ns.GetGroupContext()` (`Utilities.lua`) returns one of `ns.GROUP_CONTEXTS` (`Data.lua`), the first that holds of `battleground` (`ns.IsInPvPInstance`: battleground or arena, whatever the group), `raid`, `party`, `solo`. A battleground's raid is a Battleground, never a Raid. Instance groups count like home groups.
- **One shape.** A setting saves `{ solo, party, raid, battleground }` booleans, all `true` by default, read through `ns.IsGroupContextOn(table[, context])`. A missing table or entry reads as ticked.
- **One control.** Four checkboxes in that order with `GROUP_CONTEXT_<KEY>` labels: `ns.OptionsGroupContextRow` (sub-option row) or `ns.OptionsGroupContextToggle` (one box); `ns.OptionsGroupContextNone` adds the red line while none is ticked (`Options-Utilities.lua`).
- **Extra filters narrow, never replace.** Buff Duty's Anywhere / In Instance (`showWhere`, no Battleground entry) and the consumables' level filter (`<prefix>Level`, `ns.LEVEL_FILTER_ORDER` in `Data.lua`, labels `ns.LEVEL_FILTER_VALUES` in `Utilities.lua`) can only switch off a ticked context.
- **Who uses it.** Buff Duty's When to Show (`buffWindow.showIn`, `BuffDuty.ShowsHere`); every consumable's When to Use (`<prefix>In` + `<prefix>Level`, `ns.IsUseWhenActive(settings, prefix)` for `buffFood`, `scrolls`, `petBuffFood`, `conjuredFirst`); Count as Tanks' SOLO (`Buff-Duty-Units.lua`); the mini-map menu's Waiting For note (`WaitingLabel`). Plumbing that only picks a chat channel or unit prefix (`ns:GetGroupChatChannel`, `ns.GetUnitByGUID`) reads `IsInRaid` / `IsInGroup` itself.
- **Change detection.** `ns.GroupSignatureChanged` diffs the context itself, so entering or leaving a battleground rescans the macros. Buff Duty re-checks on `GROUP_ROSTER_UPDATE` and every `PLAYER_ENTERING_WORLD`.
- **A ticked box that can't work says so.** Where the game hides auras (`ns.AreAurasSecret()`), Buff Duty prints `BUFF_DUTY_AURAS_HIDDEN` once a session (`ns.WarnOnce`) when When to Show would otherwise show the window.

### Characters and Profiles

- **AceDB can open the database under a placeholder name.** The newest AceDB among enabled add-ons loads and reads the character's name once, possibly before the client named the character (or, with an older AceDB on Forever, the first name only). `UseOwnProfileWhenUnnamed` moves to the profile saved under the real name at login; `SaveProfileChoiceWhenUnnamed` saves the choice under the real name at logout and drops the placeholder's `profileKeys` entry. Both key off `ns.SplitCharacterProfileName` returning nil for a key naming no character.
- **Copied-WTF characters are pruned** right after `AceDB:New` (`PruneOtherClientCharacters`): `char`, `profileKeys` and, unless still in use, `profiles` entries, in the root table and every namespace. `PruneOtherClientGlobals` then drops `restocker.listChoices` by key shape and Inventory Report records by name (a README-Notes exception). The rule is a key's shape: `" - "` on realm clients, `"First Last"` on Forever. On Forever an older AceDB's `First - RuleSet` key (`FOREVER_RULE_SETS`) is kept (`IsOlderForeverKey`, MIGRATION 2026-12-08) so `CarryOlderForeverSettings` (`Default-Profile-Migration.lua`) can read it.
- **Two character-key formats, never mixed** (`Features/Utilities.lua`):

| Key | Shape | Readers | Used by |
|---|---|---|---|
| AceDB profile name | `Name - Realm`; `First Last` (literal space) on Forever | `ns.GetCharacterProfileName`, `ns.ProfileNameForCharacter`, `ns.SplitCharacterProfileName` | `profileKeys`, profiles, `restocker.listChoices`, `ns.MacroOwnerKey`, `ns.GetClassesByProfileName` |
| Add-on character key | Whole name, then `-Realm` with spaces closed up | `ns.GetCharacterKey` | `global.inventory`, Diagnostics, the Forever re-key migration |

- `ns.GetPlayerFullName` reads `UnitNameUnmodified` (the name AceDB saves under, not a display restyle), adds the surname with the client's `CHARACTERNAME_SURNAME_SEPARATOR`, and never doubles one already present. `ns.GetCharacterProfileName` returns nil while the client answers `UNKNOWNOBJECT`.
- **Every profile change re-applies.** `ns:ApplyProfile` runs on `OnProfileChanged`, `OnProfileReset`, `OnProfileCopied`: `ns.ApplyConsumableMacrosProfile`, `ns.ApplyBuffDutyProfile`, `ns.ApplySpellbookProfile` (each existence-tested), `ns:ApplyMinimapButton`, then `ns.RefreshSettings`. The Restock List in use is the character's choice, not the profile's, so a switch leaves it. The callbacks are wired last in `InitializeDatabase`, so the migrations' profile switches fire no handler.

### Replaced and Legacy Add-ons

- **`ns.REPLACED_ADDONS`** (`Data/Data.lua`: Connoisseur & Restocker, and Rank Sentinel under both folder names, matching `Data.RANK_WATCH.STANDALONE_FOLDERS`) is permanent, not a migration. Any of them loaded at login is turned off for every character before the database opens (`ns.TurnOffReplacedAddons`, `Features/Replaced-Addons.lua`), and `GOODTOGO_REPLACED_RELOAD` is offered once in the world, since the old copy keeps rewriting the same macros (or double-reporting ranks) until a reload.
- **`ns.LEGACY_ADDONS`** is a migration (`Features/Legacy-Migration.lua`): Connoisseur & Restocker (`ConnoisseurDB`), Macro Spellbook, Rank Sentinel.
  - The client loads an add-on's saved variables only while it is on, so a loaded one is copied once through `LEGACY_IMPORTERS`, raw, before AceDB opens: legacy wins key by key, keys only Good to Go has are kept, Restock Lists merge by name.
  - The record is `global.legacyImported[sv]`: `LEGACY_IMPORT_VERSION` or `"declined"`; any other value imports again.
  - Loaded legacy add-ons not in `ns.REPLACED_ADDONS` are turned off here and join `ns.turnedOffAddOnTitles`.
  - An installed-but-off one gets `GOODTOGO_LEGACY_IMPORT`. Accept enables it for this character only and reloads; Decline saves `"declined"`; Escape (`noCancelOnEscape`) asks again next login. While pending, `ns.IsLegacyImportPending()` keeps Staples shut. The question waits while any add-on was just turned off.
  - After a copy, `ns.OfferLegacySteps` swaps `GOODTOGO_REPLACED_RELOAD`'s text to `POPUP_LEGACY_RELOAD_COPIED` instead of the plain reload.
  - Macro Spellbook and Rank Sentinel are only turned off here; Rank Watch imports Rank Sentinel's settings itself (`Rank-Watch-Core.lua`).
- **Automated Appreciation is retired** (`ns.RetireAutomatedAppreciation`, same file): nils `RETIRED_SETTINGS` keys and `legacyImported.TFTBDB`; out of combat, deletes `RETIRED_MACROS` only when a macro's trimmed body is still exactly its own `/thankyou[n]` command and no `SLASH_*` alias claims that command (`IsSlashCommandTaken`). Thanks for the Buff is its own add-on: never imported, never turned off.

### Sent Messages (`Features/Announcements.lua`)

- Every automated line is `{rt1} body // GtG`, built by `SignOff` (`MarkerPrefix` + `TrimSentBody` + `ADDON_SHORT_NAME`). Every send goes through local `Send` (`C_ChatInfo.SendChatMessage`), which drops a nil channel or empty message.
- `MarkerPrefix` drops `ns.TARGET_MARKER` from non-whispers on Forever, which blocks raid-marker tokens in group chat; whispers keep it.
- `TrimSentBody` trims closing punctuation as whole UTF-8 sequences (`CLOSING_MARKS`) and drops leading `¡ ¿` (`OPENING_MARKS`). Bodies carry links, so pipes stay.
- Senders: a line already built (and measured) goes through `ns:SayBuffRequest` (group, `ns:GetGroupChatChannel`) or `ns:QueueAutomatedWhisper`. `ns:WhisperTestToSelf` backs Send Test to Me.
- Whispers queue `WHISPER_GAP` apart (`QueueWhisper`); an empty queue sends at once.
- Group buff ask: `ns:BuildBuffRequestMessage(names, count, link)` names up to `ASK_MAX_NAMES`, else counts, via `ns:BuildAnnounceMessage`. `ns.JoinNames` lists names with the `LIST_*` locale formats.
- **Editable whispers** (Buff Duty's whispered ask; Rank Watch's tip, opt-out offer, opt-out reply) are the player's own text with `{word}` tokens filled through `FillTokens` (gsub with a function, so `%` is literal and an unknown token stays as typed). Each has a fill/build pair: `ns.FillBuffAskWhisper` / `ns:BuildBuffAskWhisper`, `ns.FillRankWatchTipWhisper` / `ns:BuildRankWatchTipWhisper` (field from `ns.RankWatchTipField(form)`), `ns.FillOptOutOfferWhisper` / `ns:BuildOptOutOfferWhisper`, `ns.FillOptOutDoneWhisper` / `ns:BuildOptOutDoneWhisper`.
  - Fill builds as typed, any length, so panels can flag Too Long. Build (`BuildEditable`) returns nil for empty text, the chosen language's default when over `ns.CHAT_MESSAGE_MAX_LENGTH`, nil when even the default is.
  - The buff ask swaps in `buffAskOne` / `buffAskCount` only while the text is still the default, matching the group ask's grammar. The tip tries the linked spell, then the bare name, and never cuts a message (a cut could break a link).
- **Message languages** (`Data/Message-Languages.lua`). Defaults live in `Data.MESSAGE_LANGUAGES` (one row per locale, every field), not `Locales/`, because AceLocale loads only the client's file and an English client may whisper in German. `Data.EDITABLE_MESSAGES` maps each field to its `ns.db.global` table and key; unset means the language's default, `""` sends nothing.
  - `ns.GetMessageLanguage` reads `global.messageLanguage`, falling back to `Data.DEFAULT_MESSAGE_LANGUAGE`. `ns.SetMessageText` clears a text equal to the default to nil so it follows the language; `ns.SetMessageLanguage` moves texts still on the old default and never replaces written text.
  - The panels' composer is `ns.DefineWhisperComposer` (`Options/Options-Message-Composer.lua`).
- `ResolvePlurals` (`Utilities.lua`) resolves the client's `|4` plural escapes, only inside `ns.FormatDuration`. Nothing on the send path resolves them.

### Key Bindings (`Features/Key-Bindings.lua`, `Bindings.xml`)

- `Bindings.xml` is loaded by the client on its own, never listed in a TOC. Every binding's `category="BINDING_HEADER_GOODTOGO"`, the global set to the add-on title here, which gives Good to Go its own section; `"ADDONS"` would bury it under the shared AddOns header. Keys are saved against the binding's name, so renaming one needs a key move.
- `ns:OpenKeyBindings` (the General panel's Set Key buttons) refuses in combat, then tries at click time: `Settings.KEYBINDINGS_CATEGORY_ID`; the Settings panel's category list searched by label; `KeyBindingFrame` via `KeyBindingFrame_LoadUI`; else a `KEY_BINDINGS_LOCATION` chat line. Diagnostics has an API row per route.
- `UPDATE_BINDINGS` repaints the General panel and calls `ns.RequestBuffDutyRefresh` (the Buff Key tip shows only while that key is unbound).

**Globals that macros, bindings and secure clicks call** (macro `/run` lines can't see `ns`):

| Global | File | Does |
|---|---|---|
| `GtGFire(id, oocID)` | `Macros/Runtime.lua` | Stamps the item (the OOC one out of combat); an `ERR_ITEM_WRONG_ZONE` within a literal second prints `MESSAGE_BUG_REPORT` naming it |
| `GtGTip`, `GtGTipIf` | `Macros/Runtime.lua` | Tip from `ns.TIP_MESSAGES`, `ns.MISSING_SPELL_MESSAGE_IDS` or the built `noPetSkills`; `GtGTipIf` appends a `" 1"` sentinel to its conditional |
| `GtGNoItem(type, canMake)` | `Macros/Runtime.lua` | The no-item print, via `ns.BuildNoItemLine` (also the panel's Example) |
| `GtGReplace()` | `Macros/Runtime.lua` | Accepts `REPLACE_ENCHANT` only |
| `GtGMute(on)` | `Enhanced-Spellbook/Mute-Errors.lua` | Zeroes the `MUTED_CVARS` that are on; restores exactly what it read, with a backstop timer |
| `GoodToGo_ToggleSpellbook()` | `Enhanced-Spellbook/Key-Bindings.lua` | `Bindings.xml` toggle (`BINDING_NAME_GOODTOGO_TOGGLE_SPELLBOOK`) |
| `GtGBuffKey` (frame) | `Buff-Duty/Buff-Duty-Keys.lua` | Hidden secure button the Buff Key clicks; `TFTBBuffIndividual` aliases it until its migration expires |

The `Connoisseur*` aliases of `GtGFire`, `GtGTip`, `GtGTipIf` and `GtGNoItem` stay until their migration expires, because macros Connoisseur & Restocker wrote still call them.

### Readiness Report

- Module `ReadinessReport`. `READY_CHECK` is subscribed only while `readinessReportEnabled` (`ns.SyncReadinessReportEvents`), independent of `macrosEnabled`. `ns.OnReadyCheck` goes silent while `ns.AreAurasSecret()`.
- `ns.BuildReadinessLines(inArena)` returns nil when nothing is wrong. It ignores the master switch, so Diagnostics renders it on demand.
- **Silence is the feature.** A category with nothing wrong prints nothing, and a clean character prints nothing at all. A switch may only ever add a line about something broken. Durability names each equipped item under the threshold, never an average, since one weapon near zero is what breaks mid-pull.
- Lines are `ns.ReadinessLine`s of `ns.ReadinessClause`s, each through `ns:PrintMessage`, `READINESS_TITLE` first.
- Gates (`ns.ReadinessAsks*`): a buff with a macro behind it needs both the profile's macro switch and When to Use and the account-wide report switch (`ns.ReadinessAsksWellFed`, `ns.ReadinessAsksScrolls`); class gates for Soulstone and Mana Gem; Healthstone needs a Warlock in the group (`ns.GroupHasClass`); Pet Well Fed uses `ns.ShouldTrackPetFood`, the macro override's gate.
- Item lines read the last scan (`ns.bestSelection`, with `ns.scannedIgnoredTypes` counting as carried) and are silent before the first scan. The Mana Gem line reads raw `ns.scannedItemCounts` against `ns.MANA_GEMS`, since runes can win the category.
- Weapon lines: `ns.GetMissingWeaponBuffs` (`Readiness-Report-Probes.lua`) over `ns.BuffDuty.ReadWeaponEnchants`. `ns.WEAPON_ENCHANTS_STACK` raises the wanted count to two. A Shaman in the party (`ns.PartyHasClass`) waives the main hand, except where enchants stack.
- In an arena the buff, expiring and item clauses drop; the PvP clause also drops in battlegrounds.
- The panel's Example (`ns.BuildReadinessSampleLines`) shares the clause builders and the `ns.ReadinessAsks*` gates. The panel's Reset writes every `readiness*` global default back except the master switch.

### Inventory Report

- **No module of its own.** `ns.inventoryEventHandlers` is dispatched by the Restocker's module (`Restocker-Events.lua`), only while `global.inventoryReport` is on, and subscribed through `ns.SyncRestockerEvents`. `ns.InitializeInventoryReport` runs from the Restocker's `PLAYER_LOGIN`, after `ns.InitializeRestocker`.
- Record: `global.inventory[ns.GetCharacterKey()]` holds `{ name, realm, class, guid, bags, bank }`, each place one line of `id:count` pairs sorted by ID. The Restock List reads `class` to color characters. At login another key with this GUID is dropped (rename or transfer), and this key with another GUID loses its bags and bank (a deleted namesake).
- Bags are read at `PLAYER_ENTERING_WORLD` and `BAG_UPDATE_DELAYED`; a read with a 0-slot backpack is ignored. The bank is read on `BANKFRAME_OPENED`, again after `BANK_SETTLE_DELAY`, and on bag updates while open.
- **Logout writes only what was last read** (`bagCounts`, `bankCounts`): on Forever the containers can read empty at `PLAYER_LOGOUT`. Nil means never read, and the saved line stands.
- `ns.ForgetRecordedCharacter` (the panel's Forget) drops another character's record and its `restocker.listChoices` entry.
- The tooltip hooks after `TOOLTIP_HOOK_DELAY`, so its block lands under other add-ons' lines. It goes through `ns.AddItemTooltipPostCall` on `GameTooltip` and `ItemRefTooltip`, and a weak-keyed set blocks doubled calls. It shows this character live, then other same-realm characters. A zero total shows nothing unless the item has a Keep on the current Restock List.

### Restocker

The feature is "Restocker"; its window is the Restock List; its starter popup is "Staples". In code, Staples is still the "Starter List" (`Restocker-Starter-*.lua`, `ns.STARTER_LIST_CATEGORIES`). `/restock profile ...` and `RESTOCKER_*_PROFILE*` keys mean a Restock List, not an AceDB profile.

#### Lifecycle

- Module `Restocker` (`Restocker-Events.lua`). One handler per event in `ns.restockerEventHandlers`, all wrapped in `WhileEnabled` except `PLAYER_LOGOUT`. Anything else wanting an event already in the table calls from that handler: `ns.OnRestockerEnteringWorld` runs the arrival check, the Staples trigger and the upgrade catch-up.
- `EVENTS` is the union of the Restocker's and the Inventory Report's; `ns.SyncRestockerEvents` subscribes each only while a switched-on feature has a handler. `GET_ITEM_INFO_RECEIVED` is not in the table: `Features/Item-Info.lua` hands it to `ns.OnRestockerItemInfoReceived`.
- Login (`ns.InitializeRestocker`, `Restocker-Core.lua`): `ns.restockSettings = ns.db.global.restocker`, `InflateSavedRestockItems`, `InitializeCharacterRestockList`, `PruneEmptyOrphanRestockLists`, events, bag definitions, `SetupCraftingRecipes`, `CreateRestockWindow`. `ns.restockSettings` is an empty table until then, so options getters index something.
- Logout: `SaveRestockWindowGeometry`, then `DeflateRestockItemsForSave` (every row is a string from then on), then `currentList = nil`.
- `ns.SetRestockerEnabled`: on arms the reminders silently (`ns.ArmRestockerReminders`) and runs the upgrades; off closes Staples, ends any bank or merchant visit (no `_CLOSED` event will reach a sleeping handler) and hides the window. `/restock` refuses every subcommand but `help` and `config` while it is off.

#### Lists and Choices (`Restocker-Saved-Lists.lua`)

- Lists live at `global.restocker.lists[name][itemID]`. Each character's choice is `listChoices[<profile name>]` on global, so two characters sharing a profile keep their own lists and Reset Profile can't empty a hand-built list (a README-Notes exception). `OwnCharacterKey` asks `ns.GetCharacterProfileName()` before `ns.db.keys.char`, which can be AceDB's placeholder.
- `ns.UseRestockList` is the single write point for `currentList` and the choice; it also clears New flags, undo, group selection and scroll.
- A fresh character gets its class name via `FreeClassListName`, numbered rather than joining another character's list. `IsListNameTaken` counts existing lists and names other characters still point at, because those would recreate the list at login.
- New List and Copy switch to the made list and open the rename; Escape or Cancel calls `ns.DiscardMadeRestockList`, which deletes it only while its rows equal the snapshot.
- Delete lands on `ns.GetRestockListAfterDelete` and goes through `ns.UseRestockList`, not `ns.SwitchRestockList`, so no merchant buy or bank run restarts. `ns.SwitchRestockList` restarts an open bank run and rebuys at an open merchant.

#### Saved Format (`Restocker-Saved-Format.lua`)

- Each row packs to `"itemName, amount, stash, fromBank, buy, reaction, upgrade, buyExtra"` at logout and inflates at login. No item ID (the key is it) and no item type (read live).
- Every field is always written. Data starts at the first numeric field; the leading name is a label never read back, and `ns.RefreshRestockItemName` supplies the live name.
- `buy` and `upgrade` are nil-means-on; `buyExtra`, `stash`, `fromBank` nil-means-off. A new field is a new trailing field with its own default.

#### Adding and Removing (`Restocker-List.lua`)

- `ns.AddRestockItem` takes an ID, a name or a link; refusals say so via `ns.ShowRestockAddNotice` (the add box's placeholder while the window is open, chat otherwise). A cold item parks under its numeric ID.
- `ns.RemoveRestockItem` keeps `ns.restockLastRemoved` for a one-step undo.
- Four queues wait on item data: parked adds, `pendingUpgrade`, pending Staples ticks, `ns.restockColdRows`. `ns.SyncRestockItemInfoSubscription` holds the `"restocker"` waiter only while one is non-empty.

#### Merchant (`Restocker-Merchant.lua`, `-Merchant-Report.lua`, `-Purchase-Space.lua`)

- `MERCHANT_SHOW` sets `ns.merchantIsOpen`; Shift sets `ns.merchantBuyingSkipped` and skips. `ns.RestockFromMerchant` returns on an empty list or within the literal doubled-show throttle.
- Reagent order (`ns.BuildCraftingPurchaseOrder`, `Restocker-Crafting-Reagents.lua`): from `ns.POISON_RECIPES`, for Buy rows only, bags only. Gated all-or-nothing (`VendorStocksAllReagents`), since half a recipe crafts nothing.
- One order per Buy row, bags counted by item ID, gated by the vendor's reaction (`UnitReaction("npc")`) against the row's `reaction`.
- Budget: `GetMoney()` less the Gold Reserve, plus a `ns.NewBagSpace` snapshot spent down by `ns.ClaimBagSpace` (partial stacks, then a matching specialty bag, then a general bag). Both are spent locally, because nothing changes until the server answers.
- `PurchaseMerchantItem` buys in stack-sized chunks, skips extended-cost slots, caps at a limited slot's stock and lets Buy Extra take a limited slot's whole stock. It counts units, not calls, and never sells.
- The report waits for delivery: `ns.AwaitMerchantRun` parks `pendingRun` until `ns.SettleMerchantBuys` (`BAG_UPDATE_DELAYED`) sees every order's units or `BUY_SETTLE_TIMEOUT`, and reports units delivered, not sent. The close reminder waits behind it (`ns.AfterMerchantBuysLand`).
- `ns.merchantIsOpen` is the hard gate the bank run reads. `ns.REPUTATION_STANDINGS` discounts are labels only; the reaction gate is the only enforcement.

#### Bank Run (`Restocker-Bank-State.lua`, `-Bank-Visit.lua`, `-Bank-Moves.lua`, `-Bank-Tidy.lua`, `-Bags.lua`)

- On `BANKFRAME_OPENED` (Shift skips the visit), `ns.StartRestockBankRun` reloads the bank bags every time (`ns.LoadRestockBankBags`; on Forever, the `C_Bank` tabs the player bought) and starts a coroutine.
- An OnUpdate ticks at `ComputeUpdateInterval()`: a multiple of the higher ping with a floor, both literals. A lock gate waits while a list item is locked.
- Each step of `RunRestockLogic`:
  1. Aborts while `ns.merchantIsOpen`. Reloads the bank bags while the run holds none: Forever's tab list can still be empty when the bank opens.
  2. Rescans. A foreign item on the cursor is waited out for `MAX_STUCK_STEPS`, then cleared.
  3. In-flight gate: waits up to `MAX_INFLIGHT_STEPS` while a bag-plus-bank total has dropped.
  4. Watchdog: stops with `StuckMessage` after `MAX_STUCK_STEPS` with remaining work unchanged. Work that grew counts as change, not a stall.
  5. One move: stash first if the bank has a free general slot, else pull first.
  6. Never finishes inside `BANK_SETTLE_DELAY`, since the bank may still read empty.
- Keep amounts freeze per run (`RestockState:Wanted`). Reopening the bank, Enter in a Keep box or any list switch restarts the run.
- After a stuck step, a pull overshoots with a whole stack, and the excess is stashed back even without Store (`overshotItems`).
- Placement names an empty slot (`BagDefinition:PutCursorItem`), which leaves the cursor alone so the caller can try the next bag; a failed placement ends in `ClearCursor()`.
- The tidy phase merges partial stacks within the bags, then within the bank, never across, until `CountRestockPartialStacks` stops falling. `RESTOCKER_COMPLETE` prints only if something moved.
- `ns.restockPlayerBags` are where items may be put; `ns.restockCountedBags` adds the reagent bag for counting, locks and stashing.
- No manual trigger in Diagnostics, on purpose: that panel is read-only. `ns.RestockerDebug` writes trace lines to the Event Log only while logging.

#### Shortfall and Reminders (`Restocker-Shortfall.lua`, `-Reminders.lua`, `-Town-Reminder.lua`)

- Bags only, by item ID, everywhere. `ns.IsRestockItemShort` is the one test, and drives the Keep mark.
- Three lists, each for its own surface:
  - `ns.BuildRestockShortfallList`: every short row, Buy on or off. Split by `ns.BuildRestockReminderLists` into out (none in bags) and low (below `restockLowThreshold`, one of `ns.RESTOCK_LOW_THRESHOLDS`); rows at or above the line are never mentioned. Feeds every reminder and the mini-map menu, so the two never disagree.
  - `ns.BuildGroceryList`: short Buy rows, no reagents. Feeds the footer tooltip.
  - `ns.CountRestockOrders`: the footer count, by the grocery list's rules.
  - The merchant run ignores the threshold.
- Each reminder has a mode key (`restockReminderMode`, `merchantReminderMode`, `bankReminderMode`): `ns.REMINDER_SIMPLE` prints the headline only, `ns.REMINDER_VERBOSE` adds a line per out item, then low item (`ns.BuildRestockShortfallLines`, also the panel's Examples).
- Closing reminders (`ns.RemindRestockShortfallAfterVisit`) wait `SETTLE_DELAY`; the merchant's waits for its buys, and the bank's fires only if that visit's run started.
- Town reminder (`Restocker-Town-Reminder.lua`):
  - Fires on a not-resting to resting edge, from `PLAYER_UPDATE_RESTING`, `PLAYER_ENTERING_WORLD` (no resting event follows a loading screen) and `PLAYER_CONTROL_GAINED` (landing, after `ARRIVAL_SETTLE_DELAY`). A taxi counts as not in town.
  - Does nothing until armed. Login requests the list's cold items, then checks after `LOGIN_SETTLE_DELAY`; a `/reload` arms silently; other loading screens check after `ARRIVAL_SETTLE_DELAY`.
  - `REMINDER_COOLDOWN` runs from the last reminder printed. `restockReminderSound` plays `ns.RESTOCK_ALERT_SOUND` only with the chat line.

#### Upgrades (`Restocker-Upgrade.lua`)

- `ns.CONSUMABLE_UPGRADE_CHAINS` tiers are sorted by rank in place at load. A row moves only forward to the best tier at or below the level; merging into an existing row sums amounts.
- Runs on `PLAYER_LEVEL_UP` with the event's level, as a catch-up on `PLAYER_ENTERING_WORLD`, on switching the Restocker on, and on item answers while pending. A cold target parks as `pendingUpgrade`; a target the server refused is never waited on.
- `ns.BestChainItemID` is what Staples adds through, so a tick starts on the tier the upgrader would pick.

#### Staples (`Restocker-Starter-Categories.lua`, `-Starter-List.lua`, `-Starter-Sections.lua`, `-Starter-Window.lua`)

- Rows: `ns.STARTER_LIST_CATEGORIES`, holding no game IDs; `classes` decides who is offered a row, `defaultFor` who gets it pre-ticked.
- At load `Restocker-Starter-List.lua` resolves each `chainKey` through `CHAINS_BY_KEY`, sets `row.chain` and nils `chainKey`, mutating the table; rows whose ladder the flavor lacks drop.
- A row is offered when its class matches and its ladder has an item at the player's level. A tick adds the best tier; unticking removes every tier.
- Login trigger, fresh logins only (`ns.OnStarterListEnteringWorld`): after `STARTER_POPUP_DELAY`, at `STARTER_MIN_LEVEL` or above, on an empty list, something offered, out of combat, not while `ns.IsLegacyImportPending()`. It pre-ticks the `defaultFor` rows, opens the Restock List, then the popup. No don't-show-again: the pre-ticks fill the list, so it never returns.
- Window: `GoodToGoStaplesFrame` on the shared portrait frame. Cold items warm through `ns.WarmItemCache` and repaint once per frame. While open it takes the Restock List off `UISpecialFrames` and hands it back a frame after it hides.

#### Window

- A hand-built portrait frame shared with Staples (`Restocker-Window-Frame.lua`, `ns.RESTOCK_WINDOW_BANDS`). Header: filter, adders, Pick Staples. Footer: list controls at left (`Restocker-Window-List-Bar.lua`, `-List-Manage.lua`), order count at right.
- An item dropped anywhere joins the list: every control goes through `ns.SetRestockControlClick`, and `ns.AddRestockItemFromCursor` always clears the cursor.
- `ns.UpdateRestockList` (`Restocker-Window-Render.lua`) is the full redraw. It closes every menu first, since pooled rows rebind, and calls `ns.RequestUpdate` when membership changes and `profile.useRestockLast` is on. `ns.RefreshRestockShortfall` repaints only marks and status.
- Groups are keyed by classID via `C_Item.GetItemInfoInstant`, which needs no item cache, or the sentinels `GROUP_NEW` / `GROUP_OTHER`. The filter folds Latin and Cyrillic capitals and counts UTF-8 characters.
- `COLUMNS` (`Restocker-Window-Columns.lua`) drives header and rows through one walk; widths are measured from the font. Cells (`Restocker-Window-Cells.lua`) read `COLUMN_STATE`; a heading's menu sets that column on every row shown (`COLUMN_SET`).
- Menus are AceGUI `Dropdown-Pullout`s closed by `ns.CloseRestockMenus`, never `UIDropDownMenu`. The Staples stack picker is `WowStyle1DropdownTemplate` where present.
- A visit opens the window only with `autoOpenAtMerchant` / `autoOpenAtBank`, and closes it only if that visit opened it (`ns.restockWindowOpenedByVisit`). Geometry is written whole on drag stop, resize and logout.
- The Keep box saves on every keystroke; an emptied box saves nothing and leaving it restores the amount it held at focus. Typing 0 keeps none in the bags (with Store, all to the bank).

### Buff Duty

#### Load Order

- Same order in all four TOCs: Events, Icon-State, Party-Buffs, Icons, Layout, Frame, Button-Attributes, Position, Castable, Lookups, Settings, Auras, Units, Resurrections, Pets, NPCs, Weapons, Self, Favors, Outsiders, Other-Classes, Groups, `Buff-Duty.lua`, Switches, Cast-Results, Key-Picker, Keys. Options: Utilities, then the main panel, Buffs, Self-Buffs, Weapon-Buffs.
- Drawing files load before `ns.BuffDuty` exists (Castable creates it) and never touch it at load.
- Load-time captures: Icons takes Icon-State's pool; Layout takes Icons' and Party-Buffs' acquire/set functions; Frame takes Icon-State's update functions and `ns.buffDutyLayout`; logic files take Castable's tables, `RankFor`, `KnownRanks`; Pets takes Auras' `Has` and Units' `SingleIcon`/`CountsAsTank`/`IsPhaseShifted`; NPCs takes Pets' `IsHeld`; Outsiders and Groups take `PetRow`; `Buff-Duty.lua` takes `PetUnitOf` and the dirty markers. Icon-State, Weapons, Cast-Results and `Buff-Duty.lua` call `ns.SetBuffDutyEventHandler` at load.
- Call-time lookups on purpose: Key-Picker reads `BuffDuty.BuffKeySkipped` (Keys loads after it); Auras calls `BuffDuty.PrunePetHolds` / `PruneNPCCycles`; `NoteResurrect` checks `ns.RequestBuffDutyRefresh` exists.
- `BuffDuty.soulstoneEntry`, `soulstoneBuff` and `resurrection` are replaced, not refilled: read them off `BuffDuty` each time. `entries`, `buffs`, `selfBuffs`, `weaponBuffs` and the lookups are wiped and refilled in place, so capturing them is safe.

#### Events and Flow

- Module `BuffDuty`; one handler per event via `ns.SetBuffDutyEventHandler` (`Buff-Duty-Events.lua`). Handlers live with their data: cooldown in Icon-State, `REPLACE_ENCHANT` in Weapons, `UI_ERROR_MESSAGE` in Cast-Results, roster/pet/target/spells/inventory/regen in `Buff-Duty.lua`, the rest in Events.
- **Two predicates** (`Buff-Duty-Switches.lua`): `ns.IsBuffDutyTrackingForClass()` is `buffWindow.enabled` plus your class not unticked in `showClasses`; `ns.IsBuffDutyOnForClass()` adds the unsaved `hiddenThisSession`. `WINDOW_EVENTS` (`ns.UpdateBuffDutyEvents`), the backstop (`ns.SetBuffDutyWatching`), the aura handler, the Buff Key and the Event Log's combat-log decode follow Tracking, so a closed window keeps fresh auras for the key. `Refresh` and the mini-map toggle (`ns.SetBuffDutyForClass`, Shift + Left-Click and the menu row) use OnForClass.
- Always on: `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, both regen events. `UNIT_INVENTORY_CHANGED` and `UNIT_SPELLCAST_SUCCEEDED` are player-only (`EVENT_UNITS`). `UPDATE_BINDINGS` arrives through the `KeyBindings` module (`Features/Key-Bindings.lua`), which calls `ns.RequestBuffDutyRefresh` for the key tip.
- **Combat log** (`SyncCombatLog`): off Camelot only (`READS_COMBAT_LOG`), and only while Tracking and (`favorEnabled` or `BuffDuty.resurrection` known). Re-synced with the window's events and on `SPELLS_CHANGED` (`ns.SyncBuffDutyCombatLog`).
- `UNIT_AURA` is unfiltered: `ns.OnBuffDutyUnitAura` drops anything outside `WATCHED_UNITS` before the class check, and does nothing in combat.
- `Data.SAFETY_PAUSE` after every `PLAYER_ENTERING_WORLD` (`StartSafetyPause`, token-voided, read by `ns.IsBuffDutyReady`): login and loading screens replay auras as new, so combat-log resurrects/favors and Camelot's aura favors wait.
- `ns.SetupBuffDuty` once at login: `BuildLookup` (drops spell IDs the client lacks), `ns.buffDutyCategories` and `ns.buffDutySelfCategories` (Soulstone listed with self buffs, then an `ITEMS` box for `BUFF_DUTY_SELF_ITEMS`), `ns.PopulateBuffDutyAudience`, `BuildBuffs`, `ns.CreateBuffDutyFrame`, the settings apply, `ns.MigrateBuffKeys`, `isSetUp`, a refresh, `ns.UpdateBuffDutyEvents` (which starts the backstop and runs `OnSpellsChanged`).
- `ns.RefreshBuffDuty` is every panel setter's entry: `BuildBuffs`, settings apply, `MarkAllAurasDirty`, refresh, `ns.UpdateBuffDutyEvents`. `ns.ApplyBuffDutyProfile` (from Core's profile callbacks) re-populates then refreshes, though `buffWindow` is account-wide.
- **`Refresh`** (debounced by `ns.RequestBuffDutyRefresh`, `REFRESH_DELAY`) refuses in combat. It hides the window when OnForClass fails, there is nothing to offer and Party-Buffs isn't watched (`WatchesPartyBuffs`: grouped and `askOtherClasses`), or `ShowsHere` fails (Group Contexts). While `ns.AreAurasSecret()` it hides and warns once (`BUFF_DUTY_AURAS_HIDDEN`). Otherwise, under `BuffDuty.HoldGroupMembers(true)` (one roster read per redraw):
  1. `BuffDuty.BuildSections`: Self (`AddSelfSection`), then Target and Return the Favor (`AddOutsiderSections`), then one section per subgroup (`AddGroupSections`). Sets `BuffDuty.refreshSeconds` from `refreshMinutes`.
  2. `BuffDuty.BuildOtherClassBuffs` (Party-Buffs).
  3. `ns.RenderBuffDuty(sections, otherBuffs)`. Party-Buffs alone keeps the window up.
- Build and render each run under `xpcall(…, geterrorhandler())`: an error hides the window rather than leave buttons that cast at whoever `target` names now.
- **Target change** out of combat: `ns.DropBuffDutyTargetIcons` strips and hides every icon aimed at `target` / `targetpet`, then `Refresh` runs at once, skipping `REFRESH_DELAY`. In combat it only dims.
- **Backstop** (`BACKSTOP_INTERVAL`): prunes the aura cache and requests a refresh, for expiries, deaths, disconnects and zone changes that send no event.
- **Buff Key tip**: while `ns.BUFF_KEY_COMMAND` is unbound, a blank row then `KeyHintText` (`BUFF_DUTY_KEY_HINT`) ends the window. It wraps to the window's width, never widens it, and joins the signature (`|?keyHint`).

#### The Window (`Buff-Duty-Frame.lua`, `-Layout.lua`, `-Icons.lua`, `-Icon-State.lua`)

- Two frames: `anchor` on `UIParent`, owned by the Hide in Combat state driver, and `content` (backdrop, drag, title, close, key tip) shown and hidden by the add-on out of combat only.
- Sections are plain tables `{ kind, label, icons, rows, grid?, party?, subgroup? }`; only the frame files draw. Rows: `{ label, icons, pet?, npc?, grid?, indent? }`.
- `Signature()` strings everything a redraw writes, Party-Buffs' recipients and hover names included; an unchanged one skips the redraw. `RosterKey()` (raid/party plus member count) changing drops the held layout.
- **Held layout** (`Layout.held`): grid columns ever used, widest name column, most Party-Buffs icons, so the window keeps its width as buffs land. Dropped on hide, roster-key change and `ns.ApplyBuffDutySettings`.
- **Grids**: one column per buff (`buff.column`), so a party's group icon sits over the single one it replaces; only used columns are kept. Self Buffs has its own grid (`"self"`), each weapon hand its own (`"weapon" .. hand`); resurrection uses `RESURRECTION_COLUMN`, left of every buff.
- Layout: names measured first (`MIN_NAME_WIDTH`..`MAX_NAME_WIDTH`, snapped to `NAME_STEP`); top sections run down, Party-Buffs header placed before the first non-self section; parties go `PARTIES_PER_ROW` to a row. The window is never narrower than the title plus the close button's column.
- **Icons** are pooled `SecureActionButtonTemplate` buttons registered `AnyUp` and `AnyDown`. PreClick (left button) calls `ns.ExpectReplaceEnchant` for weapon specs and `ns.NoteBuffCastAttempt`; PostClick's right-button up half dismisses a favor (`ns.DismissFavor`). Tooltip hint: `spec.hint`, else favor / group / cast wording with `targetName`.
- **Icon state** between redraws: cooldown swipe per spec (item cooldown for item specs, one spell read per pass), else the reversed time-left sliver from `buffExpires`/`buffDuration` with countdown hidden (`noCooldownCount`); skipped while `ns.AreCooldownsSecret()`. Range fade every `RANGE_INTERVAL` to `OUT_OF_RANGE_ALPHA`; `pool.rosterStale` dims everything until the next draw or hide.
- **Close button**: script replaced with `ns.CloseBuffDuty` (sets `hiddenThisSession`, prints `BUFF_DUTY_CLOSED`). Cleared by login/reload, `ns.SetBuffDutyOn(true)` (feature switch, mini-map toggle), or ticking your own class (`ns.ShowBuffDutyAgain`). Title is `TAB_BUFF_DUTY // ADDON_SHORT_NAME` (README-Notes).
- **Position** (`Buff-Duty-Position.lua`): saved as the top-right corner, so the window grows left and down from the close button. Drag only when unlocked and out of combat (`moving` flag, so a locked drag saves nothing); `OnDragStop` saves then re-applies the corner, or queues it (`ns.QueueBuffDutySettings`) in combat.

#### Casting

- `ns.SetBuffButtonAttributes` writes every key, nil included, on every use (pooled buttons); a nil spec clears them all. Only `type1`, so a right-click casts nothing and is free for dismissing a favor. Kinds: `macrotext` → macro, `item` (+ `target-slot`) → item, else spell by `castSpell or spellName` at `unit`.
- Spells cast by rank text, `BuffDuty.CastText` (`Name(subtext)` from `C_Spell.GetSpellSubtext`, bare name when none): group buffs (`groupCastText`), single ranks, self buffs, imbues and resurrections (`BuffDuty.PickResurrection`). Create Soulstone alone casts by bare name, since each tier is its own spell.
- Return the Favor buttons always target by name: `TargetMacro` writes `/cleartarget`, `/targetexact NAME`, `/cast [help] <castText>`. Clearing first makes a miss cast nothing; the player is left targeted on purpose, so the window sees the buff land.
- Weapon items use `item` + `target-slot`; imbues cast at the player and land where the game puts them.

#### Reading Auras (`Buff-Duty-Auras.lua`)

- GUID-keyed cache. `UNIT_AURA` marks a GUID dirty; `MarkAllAurasDirty` bumps a generation. A record is re-read when dirty, of an older generation, or when its unit died, revived or changed connection. A secret GUID reads into a throwaway record.
- `ReadAuras(unit)` selects a record for `Has`, `Carries` and `AurasReadable` to read. A secret spell ID marks the record unreadable.
- `myStrengths` (your casts' summed `points`, wiped on `SPELLS_CHANGED` via `ForgetMyStrengths`) and `myDurations` (kept; `BuffDuty.MyDuration`).
- `bounced` is filled by `BuffDuty.NoteBounce`, read straight off the unit, on `SPELL_FAILED_AURA_BOUNCED` within `BOUNCE_WINDOW` (`Buff-Duty-Cast-Results.lua`).
- `Has(buff, unit)` order: bounce match, strength compare (both known), rank compare (`RankFor` at the unit's level), the time rule (`buff.refreshSeconds` or `BuffDuty.refreshSeconds`; a buff no longer than that counts only once gone), then another of your own auras in the same exclusive family. Running low returns its expiry and duration for the sliver.
- `RankFor` caps by `RANK_LEVEL_GAP` below the learn level only where `ns.EXPANSION <= 3` (`HAS_RANK_LEVEL_GAP`); an unknown or secret level takes the top rank.
- `BuffDuty.PruneAuraCache` keeps pet, target, targetpet, the group and their pets, and prunes `bounced`, pet holds and NPC cycles to the same set.

#### Who Gets What

- `BuffDuty.RoleOf`, in order: the Main Tank mark asked exactly (`ns.GetPartyAssignment("MAINTANK", unit, true)`), the assigned role (tank only outside a raid), your own LFG roles (tank only outside a raid), then `CountsAsTank(class)` from `tankWhen` (SOLO means `ns.GetGroupContext() == "solo"`). Otherwise damage.
- `BuffDuty.Wants`: `manaOnly` skips `Data.NO_MANA_CLASSES`, `noCasters` skips `Data.CASTER_CLASSES`, then the buff's audience.
- **Groups**: one section per subgroup with something missing. A party gets a group icon (only while grouped) once any member lacks the buff; its target is the first in-range member; its sliver shows only when every missing member has some time left. A member's pet row keeps the member listed. Pets don't count toward group icons. A dead member gets one resurrection icon. You are left out (`member.isPlayer` from `GroupMembers`): your own group buffs are Self's.
- **Pets** (`Buff-Duty-Pets.lua`): on Camelot a pet takes no stat buffs, so with `ns.BUFF_DUTY_PETS_FLAGGED_ONLY` set `PetWants` offers only rows marked `pets = true` (Thorns; never Mark of the Wild). Skipped when dead, identity secret, out of sight, not assistable, phase-shifted, charmed (`UnitIsCharmed`, or no `PetOwnerClass` and no creature family), or any aura unreadable. Only a readable "no" skips. Pets take `ALL`, plus `TANK` per `tankWhen.PET`, never `HEALER`; `manaOnly` by power type. Owner class: known demon NPC ID (`ns.BUFF_DUTY_PET_ICONS.demons`) → warlock, Focus → hunter, else the tooltip's guess.
- **Pet holds**: a cast aimed at a pet that goes off (`ns.OnBuffCastSucceeded`) holds that buff for `MyDuration` (else `PET_HOLD_FALLBACK`) less the refresh time, at least `PET_HOLD_MINIMUM`. A refusal in `PET_REFUSALS` (client strings) holds it while the pet stays watched. `Has` agreeing clears a hold.
- **Friendly NPCs** (`Buff-Duty-NPCs.lua`): the Target section's row via `BuffDuty.NPCRow`, only while `targetNPCs` (Include NPCs, under Your Target) is on, gated by `BuffDuty.CanBuffNPC` (not a player or player-controlled, alive, identity readable, in sight, a readable yes from `UnitCanAssist`). Every buff regardless of audience; `noCasters` by NPC class, `manaOnly` by power.
  - **A cycle, not aura reads**: `cycled[guid]` records each cast (`BuffDuty.NoteNPCCast`, when the attempt was `isNPC`: not a player, not player-controlled). The row offers what this round hasn't had, then starts over.
  - Refusals hold through the pet hold table (`IsHeld`). The row carries `npc = true`.
- **Outsiders** (`Buff-Duty-Outsiders.lua`): Target claims a GUID before Return the Favor. Target section skipped while its identity is secret. Dead friendly target: resurrection row only. Targeted outsider pet: one row named "Pet (Owner)", owner from tooltip lines (`OWNER_FORMATS`, `ns.ReadTooltipLines`). Targeted player: their row plus `targetpet` under them; a favor's `given` keeps updating while targeted.
- `ns.IsBuffInRange`: player and untestable units in range; phase-shifted out; then spell range, `UnitIsVisible`, `UnitInRange`. Unknown or secret reads as in range. `ns.IsBuffSpecInRange` asks an item's own range out of combat first (Soulstone).
- `BuffDuty.IsPhaseShifted` reads `ns.GAME_IDS.PHASE_SHIFT_SPELL_ID` (absent means never), cached per frame.

#### Buff Key (`Buff-Duty-Keys.lua`, `Buff-Duty-Key-Picker.lua`)

- A hidden `GtGBuffKey` secure button, created at file load, bound to `ns.BUFF_KEY_COMMAND`; macros use `ns.BUFF_KEY_MACRO`. A slash command can't cast. PreClick picks and writes attributes, the template casts, PostClick clears.
- `useOnKeyDown` false and both halves registered, so a key press and a macro's lone up both act on the up half. The up half reuses the down half's pick within `PRESS_REUSE_SECONDS`; only the up half remembers and notifies.
- Candidate order (`Candidates`): dead friendly target, group dead, favors, target (non-NPC rows), self icons, parties (target's subgroup first, `GroupChoices` then uncovered singles; pets always singles), then a targeted NPC's row last.
- Never candidates: weapon specs; specs with their own cooldown (`HasCooldown`: `GetSpellBaseCooldown` above zero, or an item's `hasCooldown`, i.e. using a Soulstone). Create Soulstone is.
- `PickNext` needs set up, enabled, auras readable, `ShowsHere`, alive. First ready and reachable wins; else the first `"unusable"` one (so its error shows); else who it waits on.
- With nothing cast: in combat `ERR_NOT_IN_COMBAT`; else a UI notice: `BUFF_KEY_WAITING`, `BUFF_KEY_OFF` (Tracking fails), `BUFF_DUTY_AURAS_HIDDEN`, or `BUFF_KEY_DONE` (only when `ShowsHere` and alive).
- `GroupChoices` takes the group version when no single icon exists, or when reach is positive, it is cheaper (a member with no single icon; else mana via `C_Spell.GetSpellPowerCost`; else reach of two or more) and not unusable. A just-cast group buff covers its column.
- `Reachable`: a group spec waits until every missing member is in sight (out of sight and not AFK holds it), then needs one in range.
- Skip memory (`recent`, keyed by GUID, party or favor plus spell name): `BUFF_SKIP_SECONDS`, `RESURRECTION_SKIP_SECONDS` once the cast is heard (`pending`, `PENDING_SECONDS`), `FAVOR_RETRY_SECONDS` at press time.
- "On cooldown" means ending after the GCD: `ns.GLOBAL_COOLDOWN_SPELL_ID` where the flavor's Game-IDs defines it (Mists), else the first known rank of your own Buff Duty rows whose base cooldown is the GCD alone.

#### Other Sections

- **Self** (`Buff-Duty-Self.lua`): skipped while dead. `selfEnabled` gates self buffs and the Soulstone; weapon rows follow `weaponEnabled` alone (`weaponBuffs` empty). `needsPet` waits for a live pet. The header stands with only weapon rows.
- **Your group buffs on you**: `BuildBuffs` adds a self buff per class `BUFF_DUTY_SPELLS` row you know whose `selfRefresh[key]` isn't Off (`isGroupBuff`, single-target ranks, `groupId` for `Has`'s strength check), skipping `manaOnly`/`noCasters` by your class; built before the Soulstone and self items so their columns follow. Group Buffs' audience is for everyone else. Seeded from the row's `selfDefault`, else 3 for a row whose `default` is ALL and Off otherwise (Thorns: MISSING). `NoteBounce` searches `selfBuffs` too, for a row whose audience is Off.
- **Soulstone**: hidden while anyone in the group carries one. Best stone in bags → first healer in item range, else first healer, else you; no stone → Create Soulstone on you.
- **Self items** (`ns.BUFF_DUTY_SELF_ITEMS`, any class): Winterfall Firewater. Shown after the Soulstone while one is in your bags (`GetItemCount`) and `Has` finds none of its auras in time; keyed `"item:<id>"` in `selfRefresh` so it can't meet a spell id. Its icon uses the item on you; the Buff Key may use it too (no `hasCooldown`).
- **Weapons** (`Buff-Duty-Weapons.lua`): one row per hand holding a weapon (not a fishing pole unless a lure fits). Picks are your class's poisons/imbues/warlock stones on `ns.BUFF_DUTY_WEAPON_HANDS[class]` hands plus any-class items (`Data.WEAPON_ITEM_KIND_HANDS`), each ticked per hand (`BuffDuty.WeaponChoiceOn`), all on `weaponRefresh`.
  - Layers (`Data.WEAPON_LAYERS`): where `ns.WEAPON_ENCHANTS_STACK` (Camelot) holds, poisons, imbues and `ns.BUFF_DUTY_WEAPON_IMBUE_ITEMS` are IMBUE, other items TEMPORARY; elsewhere one layer. A layer is covered by any of its picks with time left; otherwise every pick of it is offered.
  - `BuffDuty.ReadWeaponEnchants` uses `C_Item.GetWeaponEnchantInfo` where it and its enums exist, else the legacy global (three or four values per hand, counted).
  - Items: `PickFits` subclass mask, zones (`InItemZones`), best bag item for your level. Imbues only on `BuffDuty.ImbueLandsOn`'s hand. Icons sorted class picks, imbue layer, level.
  - Warlock stones (Camelot): Firestone and Spellstone are WARLOCK item rows in `ns.BUFF_DUTY_WEAPON_ENCHANTS` (main hand), not weapon items. A row's `create` ranks become the pick's `create` (best known, `KnownRanks`); with no stone of the line in the bags the icon casts it by bare name (as Create Soulstone), else applies the best stone by `target-slot`. No Soul Shard check.
  - `REPLACE_ENCHANT` is auto-accepted within `REPLACE_WINDOW` of a weapon click (`ns.ExpectReplaceEnchant` from PreClick), popup hidden this frame and next.
- **Party-Buffs** (`Buff-Duty-Other-Classes.lua`, `-Party-Buffs.lua`): non-exclusive `group` rows whose audience isn't Off and that you can't cast, counted per missing member (`Has` with no ranks, so any version counts by time). Shown only while that class is in the group (connected, alive) or is yours, and a `talent` row only once someone carries it.
  - Icons are plain buttons on the Party-Buffs header, count in red. Click asks the group (`ns.AskGroupForBuff` → `ns:SayBuffRequest`), right-click whispers every other player of that class (`ns.WhisperOtherClassBuff`, the composer's `buffAsk` text, nothing when emptied). Each way has its own `ASK_COOLDOWN` per buff (`ns.CanAskForBuff`).
  - Hover opens `GoodToGoPartyBuffsMenu` on `ns.MenuKit`: header, names party by party with minutes left or Missing, then both asks as clickable rows (muted while cooling; whisper row absent with no recipients). It stays open while the cursor is on the icon or menu, closes `CLOSE_DELAY` after, redraws every `REFRESH_INTERVAL`, and Escape closes it (`UISpecialFrames`).
- **Return the Favor** (`Buff-Duty-Favors.lua`):
  - Off Camelot: combat-log `BUFF` on you from a friendly, outsider-flagged source; `ns.NoteFavor` then requires a player GUID. Flags, because cross-realm names break name lookups.
  - Camelot: your own `UNIT_AURA` `addedAuras` (never a full update, in combat or while secret); caster from `sourceUnit`, else `C_UnitAuras.GetAuraCasterGUID` (pcall) and `UnitNameFromGUID` with the realm's spaces stripped.
  - Capped at `Data.BUFF_DUTY_FAVOR_MAX` (oldest evicted), kept `favorSeconds`. Dropped on joining your group, when every buff you can give is on them, or on right-click. Rows newest first. No players-in-range list: it would depend on friendly nameplates.
- **Resurrections** (`Buff-Duty-Resurrections.lua`): no icon for ghosts, offline, incoming resurrection, or within `RESURRECT_PENDING_SECONDS` of `SPELL_RESURRECT`. On Camelot, your own resurrect cast succeeding within `RESURRECT_CAST_SECONDS` of the click stands in (`ns.OnResurrectCastSucceeded`).
- Buff Duty never waits on item info (`C_Item.GetItemCount`, `GetItemIconByID`); only the Weapon Buffs panel warms items (`Kit.WarmItems`).

#### Options (`Options/Buff-Duty/`)

- Main panel: `Kit.FeatureSwitch("buffWindow.enabled")` (twin of the root's, both through `ns.SetBuffDutyOn`); everything below hides while it is off. `noBuffs` status line from `ns.BuffDutyHasClassRows`. When to Show rows: `ns.OptionsGroupContextToggle` with a `showWhere` dropdown via `Kit.ToggleRow` (no Battleground dropdown). Classes from `ns.OptionsClassList`. Ask composer via `ns.DefineWhisperComposer` (field `buffAsk`).
- Sub-panels are not hidden by the switch (`ns.AddFeatureOffLine` instead): choices worth making before turning it on. Every class is listed (account-wide).
- Self-Buffs is a tree (`childGroups = "tree"`, `Kit.PrepareTree` reopening on your class): one page per class keyed by the token, then Consumables (`ITEMS`). Each page lists the class's self buffs, its group buffs and (warlock) the Soulstone, with `Kit.TREE_LABEL_WIDTH`/`TREE_CONTROL_WIDTH` rows. The page header appends `BUFF_DUTY_SELF_NOTE_<FAMILY>` for a family with two or more entries (BLESSING included).
- `ns.OptionsClassList` is `ns.CLASS_SPELL_LISTS` keys plus every Buff Duty row's class.

#### Diagnostics

- `ns:BuildBuffDutyContextReport` (`Manifests-Buff-Duty.lua`): switches, gates, per-buff knowledge and readiness, weapons, Soulstone, key binding and old bindings, then group and target as the window reads them. Skips the group read in combat. Its `GroupUnits` and weapon fit checks re-implement the window's.
- `ns.DIAGNOSTIC_MESSAGES` (single function, assigned here) feeds `ns:BuildBuffDutyMessageLengthReport`: longest group ask and whisper, one favor macro per castable buff.
- `ns.IsCorrelatedMessage` (event log): any Buff Duty data spell ID for `UNIT_SPELLCAST_SUCCEEDED`, the learned bounce error type (`ns.IsBuffBounceError`) for `UI_ERROR_MESSAGE`.
- The same file hosts rows for every feature: `ns.DIAGNOSTIC_API_CHECKS`, `ns.DIAGNOSTIC_NAME_LOOKUPS` (Game-IDs, classes, durations, UI labels), and the Game-IDs and Buff-Duty-Spells data sources.

### Rank Watch

Does the standalone Rank Sentinel add-on's job. Reports a spell cast at a lower rank than the caster could have: a print for the player's own casts; a whisper to, and/or a print about, a group member.

- **Loading.** Vanilla, TBC and Camelot TOCs list `Features/Rank-Watch/` and `Options/Rank-Watch/`; Camelot swaps `Rank-Watch-Detection-Forever.lua` for `Rank-Watch-Detection-Combat-Log.lua`. Mists loads only the (empty) data files and the two Diagnostics files.
  - Outside callers test that a function exists first: `ns.BuildRankWatchOptions` (`Options.lua` panel registration), `ns.SetRankWatchEnabled` (`Options-Feature-Switches.lua`, at file load), `ns.IgnoreRankWatchPlayer` (`/gtg ignore`, `Options-General.lua` help line), `ns.RankWatchSettings` (`Manifests-Rank-Watch.lua`), `ns.BuildRankWatchWhisper` (`Message-Length-Rank-Watch.lua`), `ns.IsRankWatchActive` (`Diagnostics/Event-Log.lua`).
- **Events.** Module `RankWatch`; each file hands its handlers to `Rank-Watch-Core.lua` via `ns.SetRankWatchHandler` (one handler per event). `ns.SyncRankWatchEvents` subscribes the shared `EVENTS` list (includes `CHAT_MSG_WHISPER` for "Opt Out") while `ns.IsRankWatchActive()` (on, and no standalone add-on loaded), then calls the loaded detection file's `ns.SyncRankWatchDetection` and `ns.SyncRankWatchCluster`; going inactive also `ns.ClearRankWatchQueue`. Detection files subscribe their own events through `ns.SetRankWatchEvent` (unit filters allowed).
- **Login** (`OnPlayerLogin`, Core): find the standalone add-on, migrations, `TakeOverFromStandalone`, `ForgetOnNewVersion`, `ns.BuildRankWatchLookups`, `ns.ResetRankWatchSession`, sync, then register the reset listener.
- **Ladders** (`Rank-Watch-Lookups.lua`): built at login from `ns.RANK_WATCH_ABILITIES` per class, each rank dropped when `C_Spell.DoesSpellExist` says the client lacks it (Forever renumbered some), joined across one `ns.SPELL_GROUPS` group into the first (`isGroup`), sorted by learn level (stable by arrival). Keyed by first rank's spell ID (`ladder.id`), which the Reported Ranks panel uses. A one-rank ladder is kept for the panel.
  - `ns.RANK_WATCH_PET_ABILITIES` ladders sit under the owner's class with `isPet`, never joined; their level is the pet's.
  - `ns.RankWatchReportableLookup` is the fast reject every detection path and the Event Log call first: tracked and not the top rank.
  - Tracked state: the row's `off` flag, overridden by `rankWatch.untracked[id]` (true = unticked, false = ticked though `off`). `ns.SetRankWatchRankTracked` clears the entry when it matches the data default.
  - `ns.RankWatchBestIndex`: a row with no `level` is never the better rank.
  - Rank text: `ns.RankWatchRankText` prefers the client's subtext, falls back to the data's `rank` (print only); `ns.RankWatchHasRankText` gates whispers.
- **The check** (`ns.CheckRankWatchCast(cast)`, `cast = { guid, unit, spellID, recipientLevel, petUnit, petGUID }`):
  - Drops: untracked rank, inactive, a pet ladder without `petUnit` (or the reverse), non-player GUID, ignored player, PvP instance (`ns.IsInPvPInstance`), charmed or enemy unit, unreadable level (`ns.RankWatchUnitLevel`).
  - Ceiling (`Ceiling`): lowest of caster level and their first-seen level this session (`session.firstLevel`), each less the grace (`graceMaxLevel` when the owner is at `ns.GetMaxPlayerLevel()`, else `graceLeveling`); and for a cast on another friendly player, `recipientLevel + Data.RANK_WATCH.TARGET_LEVEL_RANGE` (the game lowers a buff's rank by itself to fit a target).
  - Pet casts: the pet's level and GUID set the ceiling; the owner is ignored, picks the grace, and is told.
- **Dedupe**: once per owner and ladder a session (`session.notified`), and saved as `<owner GUID>-<caster level>-<spellID>` in `rankWatch.announced` (caster level is the pet's for a pet cast), the key shape the standalone add-on's `NOTIFY` uses; broadcast via `ns.BroadcastRankWatchNotify`. Wiped when `announcedVersion ~= ns.Version`.
- **Messages**: self casts always print (`ns.BuildRankWatchSelfLine`); others print when `print` is on (`ns.BuildRankWatchOtherLine`, naming the whisperer when it's someone else). Pet forms use `_PET` / `_DEMON` locale keys; `ns.RankWatchPetInfo` names a hunter pet by name, a demon by creature family. The tip whisper is editable (`ns.BuildRankWatchWhisper` → `ns:BuildRankWatchTipWhisper`, fields `rankWatchTip` / `rankWatchTipPet` / `rankWatchTipDemon`); the print is fixed.
- **Whisper queue** (`session.queue`, `ns.ProcessRankWatchQueue`):
  - Held in combat or while dead; a target in combat retries after `TARGET_BUSY_RETRY`; `AFTER_COMBAT` after `PLAYER_REGEN_ENABLED` / `PLAYER_ALIVE` / `PLAYER_UNGHOST`.
  - Built only once the client's rank text is in (`RANK_TEXT_RETRY` × `RANK_TEXT_TRIES`), else dropped rather than sent with the data's number.
  - Rechecked at send: dropped if the player is now ignored, Whisper went off, or another copy leads.
  - Sends through `ns:QueueAutomatedWhisper` (the shared spaced whisper queue in `Announcements.lua`). An emptied tip sends nothing and counts toward no offer.
- **Opt out**: a player's second reminder in a session is followed by the offer (`rankWatchOptOut`), once a session per player (`session.offered`). A whisper of exactly `OPT_OUT_WORDS` (trimmed, any case) from a group member adds them to Ignored Players and gets the reply (`rankWatchOptOutDone`) plus a print.
- **Cluster** (`Rank-Watch-Cluster.lua`): every copy, Good to Go's and the standalone add-on's, speaks over `Data.RANK_WATCH.COMM_PREFIX`, so the two elect one leader; plain add-on messages read like the standalone's AceComm single-part ones (a leading control byte means a split message, ignored).
  - `JOIN` (after `JOIN_DELAY` on joining; on turning on in a group), `LEAD` (whispered to a joiner or broadcast to claim), `NOTIFY` / `SYNC` (saved only when matching `ANNOUNCED_KEY_PATTERN`). Release number is `COMM_RELEASE`.
  - Only the leader whispers (`ns.RankWatchWhisperer` → `"self"`, a name, or nil). A copy with Whisper off doesn't broadcast a claim. Two self-claimed leaders: the lower name keeps it. Nothing is sent in PvP instances. Names are short `UnitName` names, as the standalone sends.
- **Detection, combat log** (Vanilla, TBC): `SPELL_CAST_SUCCESS` from group-affiliated sources. Pet-ladder casts resolve the owner (`PetAndOwner`). A friendly destination other than caster/owner passes its level; unreadable drops the cast.
- **Detection, Forever** (no combat log; other players' cast IDs hidden):
  - Own casts: `UNIT_SPELLCAST_SENT` → `SUCCEEDED` by castGUID (`pending`, swept after `PENDING_TTL`); recipient by name through `ResolveCastTargetUnit`; an enemy caps nothing, an unresolvable name drops the cast.
  - Own pet: `SUCCEEDED` on `pet` (`CheckPetCast`); a helpful spell in a group is capped by `LowestGroupLevel`.
  - Others' buffs: group `UNIT_AURA` `addedAuras` (never while `ns.AreAurasSecret()`); bearer is the recipient; the player's own auras and casters resolving only to target/focus/mouseover are skipped.
  - Others' damage and heals: `C_DamageMeter` on a `METER_POLL` ticker, never in combat, plus a read on `PLAYER_REGEN_ENABLED`. First read after joining or turning on is a baseline; a spell counts when its total moved. Heals capped by `LowestGroupLevel`; damage uncapped. Pet spells (folded into the owner's list) are checked as that owner's pet while it is still out (`PetOf`). Out of a group the totals are wiped.
- **Standalone add-on** (`Data.RANK_WATCH.STANDALONE_FOLDERS`): while it runs Rank Watch stays quiet and prints `RANK_WATCH_STANDALONE` once a session when on. `TakeOverFromStandalone` switches Rank Watch on every such login unless Rank Sentinel's own profile was off; `Features/Replaced-Addons.lua` turns it off (`ns.REPLACED_ADDONS`).
- **`/gtg ignore [Name]`** (`ns.IgnoreRankWatchPlayer`): the target, or a group member / target / focus / mouseover by name (case-insensitive, full or short); keyed by GUID, class stored for coloring.

#### Ability Alerts While Leveling

- `Rank-Watch-Level-Up.lua`, module `LevelUpAlerts`, always subscribed to `PLAYER_LEVEL_UP`; gated by `rankWatch.levelUpAlerts` (sub-options `levelUpAlertsPast`, `levelUpAlertsPet`, `levelUpAlertsPetPast`), not by Rank Watch's switch or the standalone add-on. Not on Mists (file not loaded).
- Uses the event's level argument (`UnitLevel` still reports the old one) and reads `ns.WhatsNextRows` / `ns.WhatsNextPetRows` (Enhanced Spellbook's What's Next?), which work with the Spellbook off.
- Class lines: `source == "TRAINER"` rows still `AVAILABLE`, split into this level's and earlier ones.
- Pet lines (only with `ns.HasWhatsNextPet()`): hunters from `HUNTER_PET_LEVEL`; Beast Training (`TRAINER`) rows whose spell the hunter hasn't learned (`not row.ready`); Forever's `HUNTER_TRAINER` rows not `KNOWN`/`OTHER`, earlier ones only with a pet out and `AVAILABLE`; taming ranks never. Warlocks: only this level's demon rows, never a "skipped" line.
- `ns.LevelUpAlertExample` builds the panel Example from `ns.ClassTrainerRows` and `ns.PET_ABILITIES` / `ns.DEMON_ABILITIES`.

#### Rank Watch Panels

- `Options-Rank-Watch.lua`: `Kit.FeatureSwitch("rankWatch.enabled")` (applies through `ns.SetRankWatchEnabled`), standalone notice, grace dropdowns (`GRACE_MAX`), whisper/print toggles (Whisper's setter re-syncs events so the cluster re-JOINs), two `ns.DefineWhisperComposer` blocks (tip forms at order 11.1+, opt-out offer/reply at 17.4+, the latter `language = false`), whisperer line, Ability Alerts rows and Example. Examples use the player's own class's ladder (`SampleRows`), `ns.SAMPLE_NAMES`, `ns.SAMPLE_PET_NAME`, `ns.SAMPLE_DEMON_FAMILY_ID`.
- Reported Ranks (`Options-Rank-Watch-Tracked.lua`, registry `RankWatchTracked`): tree of classes plus `<CLASS>_PETS` pages, one inline group per ladder, top rank disabled and shown checked while any lower rank is tracked. Opened on the player's class with `ns.OPTIONS_TREE_WIDTH` (`RegisterRankWatchPanels`, `Options.lua`).
- Ignored Players (`Options-Rank-Watch-Ignored.lua`): rows by name with remove icon; `ClassOf` back-fills `ignoredClasses` from `GetPlayerInfoByGUID`.
- Both sub-panels are built as functions (rebuild on reopen) and are not hidden behind the switch; `ns.AddFeatureOffLine` says when it's off.

#### Rank Watch Diagnostics

- `ns:BuildRankWatchContextReport` (Report-Runner `rankWatch`): switches, gates, whisperer, prefix registration, how casts are seen per flavor, ladder counts, untracked choices, ranks lacking client rank text, announced count, group levels, own ladders' best rank, Ability Alerts state and next-level counts. Reads `ns.db.global.rankWatch` raw.
- `ns:BuildRankWatchMessageLengthReport` (Report-Runner `messagesRankWatch`): each tip form built with the locale's longest rank name and a `NAME_MAX_LETTERS` pet name, then the opt-out offer and reply.
- Manifest rows (empty on Mists): cluster and combat-log / damage-meter API checks, rank name and subtext lookups for the player's class, Validate Data sources for both Rank Watch tables.

### Enhanced Spellbook

#### Hosts and the Window

- `GoodToGoSpellbookFrame` (`Spellbook-Window.lua`, `WINDOW_WIDTH` × `WINDOW_HEIGHT`, on `UIParent`, in `UISpecialFrames`) replaces the game's book rather than docking to it: OnShow runs `ns.CloseGameSpellbook`, out of combat only.
  - Built lazily on the first `ns.ToggleSpellbookWindow`; until then `ns:RefreshOpenPages()` returns false. The toggle prints `SPELLBOOK_IS_OFF` while the feature is off.
  - `FitToScreen` only shrinks, counting the docked panel's width and `TAB_HEIGHT`, inside `SCREEN_MARGIN`.
  - `selectedTab` survives closing. Leaving tab 1 hides the docked panels.
  - Tab buttons prefer `CharacterFrameTabButtonTemplate`, else `PanelTabButtonTemplate`; text capped at `TAB_MAX_TEXT_WIDTH`.
- `TABS`: Spell Book, What's Next?, Pet Spell Book (class gate, `ns.HasPetSpellbook`; Mage only where `ns.EXPANSION` is TBC or later), Pet What's Next? (data gate, `ns.HasWhatsNextPet`).
- **Classic host** (`Spellbook-Host-Classic.lua`, Vanilla/TBC/Mists TOCs): a tab on `UIParent`, `AnchorSkillLineTab` under the `GetNumSpellTabs()`th skill-line tab (else the last shown), shown only for the spell `bookType`. Hooked with `HookScript` and `hooksecurefunc(book, "Update")` only.
- **Modern host** (`Spellbook-Host-Modern.lua` + `Spellbook-Tabs.lua`, Camelot): `ns.SpellbookTabs:RegisterTab` stacks side tabs down `PlayerSpellsFrame`'s right edge.
  - Steps past other add-ons' tab-sized frames (`CollectObstacles`, `NextFreeColumnSlot`); its own frames sit in `owned`, Blizzard's are excluded.
  - `ScreenRect` guards `IsAnchoringRestricted`, `pcall` and `ns.IsSecretValue` on foreign frames.
  - Hidden on the gamepad UI, an invisible book, or the Spellbook off. Takes the book's scale and sits under its `NineSlice` strata.
  - Attaches on `ADDON_LOADED` for `Blizzard_PlayerSpells` (`ns:OnAddonLoaded`, which then drops the event) and EventRegistry callbacks.
- `ns.SyncSpellbookHost` exists in both hosts; `ns.SetSpellbookEnabled` calls it.
- Every launcher and window frame is parented to `UIParent` (or the add-on's own window) and only anchored to Blizzard frames.
- The page strip is custom (`Spellbook-Paging.lua`): Blizzard's paging template reads a format string the Classic clients lack. `SetMaxPages` / `SetCurrentPage` never fire `OnPageChanged`.
- Binding: `BINDING_NAME_GOODTOGO_TOGGLE_SPELLBOOK` → global `GoodToGo_ToggleSpellbook` (`Key-Bindings.lua`).

#### Events

- Module `Spellbook` (`Spellbook-Core.lua`, `ns.RegisterEventModule`). `EVENT_HANDLERS` maps each event to an `ns:On<X>` name resolved when it fires, so later files supply the handlers.
  - `PLAYER_FOCUS_CHANGED` only when `ns.FLAVOR ~= "Vanilla"`.
  - `EVENT_UNITS` filters unit events (`UNIT_PET`, `UNIT_LEVEL`, `UNIT_TARGET`).
  - `WHILE_OFF_EVENTS` dispatch with the feature off. `LOGIN_REGISTERED_EVENTS` (trainer events) subscribe only once the handler exists. `OWNER_REGISTERED_EVENTS` are subscribed by their own file (`Spellbook-Tabs.lua`).
  - PLAYER_LOGIN runs `OnPlayerLogin` migrations before subscribing.
- `ns.SetSpellbookEnabled(true)` invalidates usable slots and rank rows, then `RefreshMacros`; `false` hides the window. Macros freeze as last written.
- `ns.ApplySpellbookProfile` (from `Features/Core.lua` ApplyProfile): rank rows, `RefreshMacros`, `RefreshWhatsNext`.
- `ns:RefreshMacros()`: no-op while off; refreshes the open pages, else `CollectMacros` + `SyncAllMacros`.
- `SPELLS_CHANGED` (`spellsPending`): invalidates rank rows, refreshes What's Next. With no page open it wipes `ns.macros` for a lazy rebuild, unless `ns.GroupSpellLearned()` or `ns.HandOverDue()`, which rebuild and sync now.
- `SPELL_DATA_LOAD_RESULT` acts only on `ns.TakePendingRank` hits, or `ns.TakeRequestedSpell` hits while unlearned spells are listed (`ns.SpellName` requests each ID once).
- `SKILL_LINES_CHANGED` only where `ns.READS_PROFESSIONS`, and only when `ProfessionsKey` changes.
- `PLAYER_LEVEL_UP` passes the event's level on (`UnitLevel` is stale during the event).
- Pet changes (`petPending`): pet rank rows only, `QueueRankRewriteFor("pet")`, redraw only when a pet tab shows.
- `ACTIONBAR_SLOT_CHANGED` → glows redraw + `ns.OnRankBarSlotChanged`.

#### Build → Sync → Draw

1. **`ns.CollectMacros`** (`Macro-Builder/Macro-Builder.lua`):
   - Wipes `ns.macros`, `ns.MarkRankBodiesStale`, `ns.ResolveClassConfig`, `ns.ReadSpellbook`, then `ns.ForEachClassSpell`.
   - One macro per spell (`MakeMacro`; `ns.HandOverMacro` runs before it is made), then focus copies (not Vanilla), Duplicates (`macroCopies`), rank copies (`ns.ShowsAllRanks`), unlearned spells (`ns.ForEachUnlearnedSpell`).
   - Discovery spells at or above `ns.SOD_FIRST_SPELL_ID` are hidden off Discovery (`HIDES_SOD_SPELLS`, `Class-Spells.lua`).
   - `FoldSpecializations` (`ns.PROFESSION_SPECIALIZATIONS`) and `ns.FoldRangedAttacks` (one Shoot macro with `[worn:]` clauses; carrier is the first already tagged, else the first learned). Folded macros are hidden on the page but still synced.
2. **`ns.SyncAllMacros`** (`Macro-Sync.lua`): `ns.ReadMacroIndexes` once (tags and names, character macros first), then `ns.SyncMacro` each.
   - `ns.FindMacroIndex` looks up by tag, then by name (`PickTagged`), then by legacy names; returns index, how found, shared flag.
   - `SyncAt` rewrites only a changed body that `Fits` `ns.MACRO_BODY_MAX_LENGTH` (`ns.WarnOnce` keyed `tooLong:`). Renames legacy, old-prefix and replaced-spell names, moving the ownership record; records a player-chosen name as owned when the tag matches.
   - While `MacroFrame` is shown every sync is a no-op (`ns.IsMacroUIOpen`). A one-time `OnHide` hook marks rank bodies stale and re-syncs.
   - In combat it queues (`ns.QueueMacroSync`).
3. **Draw** (`Spellbook-Page.lua`): `ns.SpellbookPageCategories`, `ns.PackSpellbookRows` / `ns.PaginateSpellbook`, `ns.SetMacroButton` per tile. One `ns.ScanActionBars` per layout feeds Mark Placed and glows; tagged bar macros match by tag only, bar spells by name so any rank counts. Refresh then fires `ns.OnSpellbookPageRefreshed` listeners (docked panels).
4. **Pickup** (`ns.PickupMacro`) creates the macro: a character slot while one is free, else General (`ERROR_MACRO_SLOTS_FULL` when both are full), with a real boolean `perCharacter`. Assigns the tag and re-checks `Fits`, because a wider tag adds a byte. Consumable tiles only pick up.

- Every menu or panel change runs `ns.RefreshSpellbookPage`, which rebuilds every `ns.macros` entry. Menus re-find their macro (`ns.MacroMenuRebuiltMacro`); panels re-find theirs by `SettingsKey` (`CurrentMacro`, `Docked-Panel.lua`).

#### Macros per Spell

- **Settings keys** (`Macro-Settings.lua`): `MacroSpellKey` = the Rank 1 ID (`BaseSpellID`, preferring `ranks.baseID` from `ReadSpellbook`) or `consumable:<type>`; `SettingsKey` adds `#n` for a Duplicate, `@rankID` for a rank copy. Each option is a profile table keyed by these (`SpellSettings`). Survives rank-ups and locale changes. The file's header lists every option key.
- **Defaults** (`Macro-Options.lua`): `SetOption` stores nil when equal to `ns.MacroDefault`. `SetChoice` stores every key of a choice true/false unless the whole choice matches defaults. `kindDefaults` values (`ns.SetKindDefault`) are stored true/false, never nil, so turning a shipped default off sticks.
- **Kinds** (`Macro-Kinds.lua`): `ns.MACRO_KINDS`; `ns.MacroKind` decides in order cursor, buff, resurrect, target, form, self. Kinds set defaults (`ns.DEFAULTABLE_OPTIONS`, `ns.KindDefault`).
- **Offered options**: the `OFFERED` predicate table (`ns.OffersOption`). Focus not on Vanilla nor on copies or ranks; once-per options not with a Cast Sequence or pet; `startAttack` hidden on friendly kinds unless already on.
- **Ranks** (`Macro-Rank-Option.lua`): `targetRank` (Dynamic Rank) offered with more than one known rank on help or exists targets (`ns.OffersTargetRank`); `fixedRank` stores a spell ID (`ns.FixedRankID`). `ns.SetAbilityRank` stores `targetRank` explicitly unless the whole choice is default.
- **Icons** (`ns.WowMacroIcon`): the question mark, so `#showtooltip` picks the spell's icon. A profession's macro gets its tile's icon, because the game resolves a profession's name to the wrong icon; sync sets that icon on existing profession macros and leaves every other icon to the player.
- **Names** (`ns.WowMacroName`): `ns.MACRO_NAME_PREFIX` plus the name trimmed by `ns.TrimMacroName` (UTF-8 safe) to `ns.MACRO_NAME_MAX_LENGTH`; suffixes from locale (`MACRO_NAME_FOCUS_SUFFIX`, `MACRO_NAME_RANK_SUFFIX`).
- **Body order** (`CastBody` / `ns.MacroBody`, `Macro-Body.lua`):
  1. `#showtooltip` (names the spell when use items, a stance or a reset would steal it)
  2. One `/stopmacro`, ahead of the mute, so a stopped press never leaves sound muted.
  3. `GtGMute(1)`, `/stopattack`, `/stopcasting`, `/cancelform`, `/targetenemy` or `/targetfriend`.
  4. `/use` slots, stance line (`StanceSlot`: `stanceIds` against `GetShapeshiftFormInfo`, else `stanceSlots`).
  5. The cast line (`CastLine`): Conditionals rows, then `btn:2` group clauses, then target priority (`TargetClauses`; `player` ends the list, a last-place target becomes the plain cast). Neighbouring clauses casting one spell merge.
  6. Auto shot, `/startattack [nostealth]`, `/petattack`, error clear, `GtGMute()`.
  7. The tag line (`ns.TaggedBody`).

  Shape: `/cast [mod:shift] Frost Nova; [@mouseover,harm,nodead][] Fireball` then `#a7`.
- Limits: `ns.CONDITIONALS_MAX_ROWS`, `ns.CONDITIONALS_MAX_CONDITIONS`, `ns.CAST_SEQUENCE_MAX_STEPS`. `oncePerCombat` / `oncePerTarget` become `/castsequence reset=… X, NULL`.
- **Conditionals** (`Conditionals.lua`): `ns.CONDITIONS`; `ns.ConditionBlockReason` (combat conditions vs the macro's combat check; `rightClick` vs `groupVersion`); `ns.ConditionalSkipReason` greys a row shadowed by an earlier superset row (an earlier ranged row never shadows). A ranged row writes one clause per `ns.KnownRangedAttacks`. Slot spells: `ns.ConditionalSpellOf` / `ns.ConditionalPickOfSpell` (`Slot-Spells.lua`), by ID never by name.
- **Cast Sequence** (`Cast-Sequence.lua`): not on focus copies or the ranged macro; blocked while pet is on; on with steps or stop-on-NULL alone (`ns.IsCastSequenceOn`); default resets (`DEFAULT_RESETS`) stored as nil.
- **Dynamic Rank** (`Dynamic-Rank.lua`, `RankFor`, `RANK_LEVEL_GAP`) writes the highest rank fit for the unit's level.
  - Top rank (nil) for the player, a secret identity, a non-plain value, an unhelpable unit or an unknown level.
  - Rewrites only macros on a bar (`PlacedRankMacros`, by tag else name; cached until `ForgetPlacedRankMacros`, `ns.MarkRankBodiesStale` or a changed bar slot), and only for the units those macros watch (`UNITS_WATCHED`).
  - `QueueRankRewrite`: one pending scope; two units in one burst become "all". Unchanged bodies are skipped once synced (`rankBodiesSynced`).
  - Never in combat; `PLAYER_REGEN_DISABLED` runs `ns.RewriteRanksBeforeCombat` synchronously, `ns:OnPlayerRegenEnabled` queues `ns.QueueRankRewriteAll`.
  - Mouseover leaving fires no event, so it is polled (`MOUSEOVER_POLL_SECONDS`); a secret mouseover identity counts as gone.
- **Mute** (`GtGMute`, `Mute-Errors.lua`): zeroes the on `MUTED_CVARS`, restores exactly what it read; a literal one-second timer backstops a press that never reaches `GtGMute()`; a second mute while muted no-ops.

#### Tags and Ownership (`Macro-Tags.lua`, `Macro-Lookup.lua`, `Macro-Delete.lua`)

- A macro's last line is its tag (`ns.BodyTag` reads only that line): `TAG_PREFIX` plus base-62 `TAG_DIGITS`, padded to `TAG_WIDTH` and growing past it. `UNASSIGNED_TAG` holds the length until the macro is written.
- `global.macroTags[identity]`: `MacroIdentity` = `MacroOwnerKey:spell|focus|copyN|rank <id>:<spellKey>`, so a renamed or moved macro is still found and a re-placed one gets its old tag back.
  - `ns.MacroOwnerKey` uses `GetCharacterProfileName()`, not `ns.db.keys.char`, which can be a placeholder.
  - `ns.AssignMacroTag` skips tags already in any body (Macro Spellbook uses the same scheme) and bumps `global.macroTagCount`.
- **Ownership** lives where no profile change can lose it: `global.ownedMacros[name] = ownerKey` for General macros, `char.ownedMacros[name] = true` for character macros (`ns.OwnedMacroList`, `ns.MacroOwnerRecord`; README-Notes exception). `ns.LegacyOwnership` returns "owned", "claim" or nil.
- **Delete** (`ns.DeleteAddonMacros(general)`): only macros with a handed-out tag **and** an ownership record (`AddonMacroIndexes`), highest index first; refuses in combat or with the Macro UI open; refreshes first when enabled. `ns.DeletePageMacro` also deletes the focus copy and removes a Duplicate or resets options.
- Slot limits: `Constants.MacroConsts`, then the globals, then a literal (`ns.MaxAccountMacros`, `ns.MaxCharacterMacros`).
- **Group handover** (`Group-Handover.lua`): a learned successor (`ns.ReplacedSpells`) with no macro of its own takes the old spell's tag and settings (`ns.HandOverMacroTag`, `ns.MoveSpellSettings`: focus copy, Duplicates), and the sync renames the macro. Runs even with no page open. `ns.GroupSpellLearned` only notes on its first call.

#### Ranks, Trainers, What's Next

- Ranks exist where `ns.HAS_SPELL_RANKS`.
- `ns.ReadSpellbook` (`Spell-Ranks.lua`): known ranks, plus unknown ranks above the highest known only (the book keeps only the top rank on some clients). `baseID` is the lowest rank, taken before that filter.
- Learn levels (`LearnLevels`), in order: `ns.ClassTrainerRows` (faction and race filtered), `profile.trainerSpells[class]` (recorded by `Trainer-Recording.lua` through `ns.GetTrainerServiceSpellId`, skipping pet services and `ns.IsPetAbilitySpell`), a same-name `requires` → level 1, then `C_Spell.GetSpellLevelLearned`.
- `Class-Config.lua` empties every other class in `CLASS_SPELL_LISTS` and `TRAINER_SPELLS` at load, keeping the keys. `ns.ResolveClassConfig` waits for a group until all its names load; forms and toggles come from the stance bar.
- What's Next is computed live (`ns.WhatsNextRows(level)`, `ns.WhatsNextPetRows(level)`): statuses `ns.WHATS_NEXT_STATUSES` / `ns.WHATS_NEXT_PET_STATUSES`, sources `ns.WHATS_NEXT_SOURCES` / `ns.WHATS_NEXT_PET_SOURCES`. A known later rank marks lower ranks known. Rank Watch Level-Up reads both.
- The three list pages differ only by model (`ns.WHATS_NEXT_MODELS`, `Whats-Next-Models.lua`). The Pet What's Next tooltip names beasts in English from data (`ns.TAMEABLE_BEASTS`, `MAX_BEASTS`; README-Notes). Grimoire names load through `ns.RequestItemInfoEvents` (`GRIMOIRE_WAITER`); `Features/Item-Info.lua` calls `ns.OnWhatsNextItemInfoReceived`.
- Tooltip ranks (`Spell-Ranks-Tooltip.lua`, rows from `Spell-Rank-Lines.lua`) hook through `ns.AddSpellTooltipPostCall`. Gated by GameTooltip only, once per tooltip, `ns.spellTooltipHasOwnRanks` (set by the list pages around their own `SetSpellByID`), the switch, `global.abilityTooltipRanks`, out of combat and `ns.IsPlain`. Cache keyed by player and pet level, cleared by `ns.InvalidateSpellRankRows(petOnly)`.

#### Docked Panels (`Macro-Builder/`)

- Conditionals and Cast Sequence share the `Docked-Panel.lua` shell (`ns.DockedPanel`), one docked at a time, parented to the window; dragging the panel moves the window. Showing docks `PANEL_WIDTH` (`ns.DockSpellbookPanel`).
- They take the keyboard only in pick mode; Escape cancels the pick; nothing in combat. The footer's byte meter measures the untagged body and turns gold at `METER_WARNING`.
- Pick mode (`Spell-Pick.lua`) is owner-based (`ns.SetSpellPicking`); starting one owner's pick ends the other's. Takes a tile click or a cursor drop (`ns.DropSpellOnSlot`; a page macro on the cursor is read back through `FindMacroIndex`). `ns.StartSpellPick` refuses in combat.

### Mini-map Button and Menu (`Features/Minimap-Button.lua`, `Features/Minimap-Menu.lua`, `Features/Menu-Kit.lua`)

- **Button.** `ns.dataBrokerObject` is an LDB `launcher`: icon and clicks, no text. Hover (`OnEnter`, not `OnTooltipShow`) opens the menu; `OnLeave` is a no-op because the menu closes itself.
  - Registered once from Core's `PLAYER_LOGIN` (`ns.RegisterMinimapIcon`), after `ns.db`, against `ns.db.global.minimap`, so a profile change never moves it. `ns:ApplyMinimapButton` is the one show/hide path (`LibDBIcon:Refresh`), called by the root panel's toggle and `ns:ApplyProfile`.
  - Icon is the Food macro's pick (`ns.bestFoodID`, else `ns.MACRO_DEFAULT_ITEM_IDS["Food"]`, else `DEFAULT_ICON`). `ns.UpdateMinimapIcon` sets only the data object's `icon`; displays redraw from it. Called by `ns.RefreshSettings` and by the macro engine after each scan.
  - On Camelot (and Mainline) the icon is resized, re-centered and masked by hand, because LibDBIcon's `SetButtonIcon` path errors when another add-on replaced the icon.
- **Clicks.** One table, `CLICKS` in `Minimap-Menu.lua`, serves both the button (`ns.RunButtonClick`, from `ns.HandleLauncherClick`) and the menu rows that do the same job (`ClickRow` prints the click's name on the right), so a row can never name a click that does something else.

| Click | Does |
|---|---|
| Left-Click | Buff Food & Scrolls as a pair (`ToggleBuffFoodAndScrolls` → `ns.ToggleMacroSetting` for `useBuffFood` and `useScrolls`; either on turns both off) |
| Right-Click | Ignores the current food (`ns.IgnoreItem(ns.bestFoodID)`), says so in chat |
| Middle-Click | Clears this character's Ignore List (`ns.ClearIgnoreList`), no confirm, says how many in chat |
| Shift + Left-Click | Buff Duty for this class (`ns.SetBuffDutyForClass`) |
| Shift + Right-Click | `ns.ToggleRestockWindow` (only a chat line while the Restocker is off) |
| Shift + Middle-Click | Hides the menu, then `ns:OpenOptionsPanel` |

  - Before `ns.db` exists only the Options click runs; the rest are swallowed. Every button or row click ends in `ns.RefreshSettings`.
  - `HandleLauncherClick` opens the menu on an unclaimed Left-Click (with the longer `CLICK_CLOSE_DELAY`); unreachable while both Left-Clicks are in `CLICKS`, so hover is the only way in.
- **Menu layout** (`BuildMainEntries`, top to bottom):
  - Header: add-on title, `ns.Version`.
  - Current Food (`AddCurrentFood`): the food item row with its tooltip, or the no-food line; Ignore row (Right-Click).
  - Buff Food & Scrolls (`AddBuffFoodAndScrolls`): On / Off / Paused. Paused when a switch is on but `ns.IsUseWhenActive` fails; a Waiting For note names what it waits for (`WaitingLabel`: the `ns.LEVEL_FILTER_VALUES` label, or the ticked group contexts, or Never). Toggle row's tooltip names both options. Stays live while Consumable Macros is off (deliberate).
  - Buff Duty (`AddBuffDuty`): status from `ns.IsBuffDutyOnForClass` (so a session close reads Off); Toggle (Shift + Left-Click).
  - Restocker (`AddRestocker`): switch status; while on, `AddRestockOrders` lists out then low rows from `ns.BuildRestockReminderLists` (same source as the entering-town reminder, so they never disagree), or a stocked / nothing-low / empty-list line. Toggle row has no click (all six taken); Open row (Shift + Right-Click) only while on.
  - [Class] Macros (`AddClassMacros`, from `ns.GetClassMacroNotes` in `Macro-Notes.lua`): class-colored submenu opening the `macros` flyout, then item rows for blocks without notes. Absent for a class with no notes or no known spells.
  - Ignore List (`AddIgnoreList`): this character's list only (Global lives in the panel), sorted by name with loading items last by ID; Clear row (Middle-Click). Absent while empty.
  - More Features (`AddMoreFeatures`): submenu with an On/Off count, opening the `features` flyout of every `ns.FEATURES` record without `block` (and passing `gate`, if set), one toggle row each.
  - Separator, Options row (Shift + Middle-Click).
- **Lists** cap at `LIST_MAX` rows, then a "N more" note (`AddList`).
- **Two homes.** Every menu write goes through the setter its options control uses: `feature.apply` (shared with `Kit.FeatureSwitch`), `ns.ToggleMacroSetting` (Macros panel toggles), `ns.SetBuffDutyForClass` (writes `buffWindow.showClasses[class]`, the Buff Duty panel's class toggles), `ns.IgnoreItem` / `ns.ClearIgnoreList` (Ignore List panel). Reads use the same paths: `IsFeatureOn` resolves through `ns.OptionsKit.Get`. Toggle and More Features tooltips reuse the switch's `caption` / `desc`; a More Features row with `confirm` asks through `GOODTOGO_MENU_FEATURE_OFF` with the switch's own confirm text.
- **Opening and closing.** `ns.ShowMenu(anchor, flyoutKey, how)` anchors to the mini-map button or any LDB display's frame; returns early without `ns.db`. `PositionMenu` picks the corner away from the screen edges once per open. An `OnUpdate` closes it `HOVER_CLOSE_DELAY` (or `CLICK_CLOSE_DELAY`) after the cursor leaves button, menu and flyout, or when the anchor hides. Escape closes it through `UISpecialFrames` (frame name `ADDON_NAME .. "Menu"`). Entering a submenu row opens its flyout (`ns.OpenFlyout`); any other row closes it.
- **Redraw.** `ns.RefreshMenu` rebuilds in place while shown. Rows whose items aren't cached draw as placeholders and trigger one redraw after `LOADING_RETRY`.
- **Menu Kit** (`ns.MenuKit`): generic, knows nothing about Good to Go. Panels on a nine-sliced `Menu-Plate.tga` (`AddPlate`, half scale, `PLATE_ALPHA`), strata DIALOG, clamped. `Panel:Render(entries)` lays out entry kinds (header, spacer, section, submenu, separator, action, toggle, choice, status, hint, description, note), adds a spacer above every heading, wraps notes and descriptions to the settled width. `Kit.IsCursorOver` reads `GetCursorPosition`, not `IsMouseOver`, so a controller's virtual cursor counts. Item and value rows are `action` rows without `onClick` until the kit gains those kinds.

### Options Shell (`Options/`)

- **Options Kit** (`Options-Kit.lua`, `ns.OptionsKit`): shared copy, never edited here. Owns the grid (publishes `ns.OPTIONS_ROW_WIDTH`, `ns.OPTIONS_LABEL_WIDTH`, `ns.OPTIONS_TREE_WIDTH` and the rest), row builders (`Kit.Row`, `Kit.SubRow`, `Kit.LabelRow`, `Kit.ToggleRow`, `Kit.Pairs`, `Kit.FieldSets`, `Kit.Section`), `Kit.Example` / `Kit.SentLine` / `Kit.PrintedLine`, `Kit.StatusLine` / `Kit.WarningLine`, `Kit.ResetRow`, `Kit.HideAllExcept`, `Kit.ItemList` + `Kit.WarmItems` + `Kit.ITEM_LINK_WIDGET`, and the panel registry.
  - Strings reach it once through `Kit.SetText` in `Options-Utilities.lua`.
  - `ns.RefreshSettings` lives here: `NotifyChange` on every `ns.OPTIONS_REGISTRY` name, then `ns.RefreshMenu`, then `ns.UpdateMinimapIcon`. `Kit.Set`, `Kit.FeatureSwitch`, `Kit.ResetRow`, `Kit.ItemList` and every menu click end in it.
  - Settings are named by store + dotted path and resolved on every read and write (`Resolve`), never captured.
  - `ns:OpenOptionsPanel(key)` and `ns.IsOptionsPanelOpen` (no caller yet) live here too; panels are opened by the category ID captured at `Kit.RegisterPanel`.
- **Features** (`Options-Feature-Switches.lua`): `ns.FEATURES`, one record per master switch (`store`, `setting`, `name`, `caption`, `desc`, `apply`, optional `confirm`, `block`). All live in `ns.db.global`. Drives the root panel's switches (`Kit.FeatureSwitches`), each panel's own switch (`Kit.FeatureSwitch(setting)`), More Features, `ns.AddFeatureOffLine`. `block = true` (Buff Duty, Restocker) keeps a feature out of More Features. `confirm` on Spellbook and Consumable Macros (off freezes macros, which a player could read as deletion). Rank Watch is inserted only where `ns.SetRankWatchEnabled` loaded. `ns.FindFeature` errors on an unknown setting.
- **Registration** (`Options.lua`): `ns.RegisterOptionsPanels`, from Core's `PLAYER_LOGIN` after `ns.db` (the Profiles label is read from the AceDBOptions table). Order of `Kit.RegisterPanel` calls is the tree order: General root; Buff Duty (+ Group Buffs, Self-Buffs, Weapon Buffs); Restocker; Enhanced Spellbook; Consumable Macros (+ Class & Race, Ignore List); Rank Watch (+ Reported Ranks, Ignored Players, where loaded); Inventory Report; Readiness Report; Profiles; Feedback & Support; Diagnostic Tools. Builders are registered as functions (rebuilt on every repaint), except Profiles, a built table.
  - Ignore List uses `Kit.PrepareTree` (forced sidebar width, reopens on the current character every close). Reported Ranks seeds its tree width and class only when unset, so a dragged splitter sticks.
- **Shared helpers** (`Options-Utilities.lua`): Good to Go's widths on the kit grid (`ns.OPTIONS_INLINE_LABEL_WIDTH`, `ns.OPTIONS_ALIGNED_LABEL_WIDTH`, `ns.OPTIONS_PROMOTE_WIDTH`, `ns.OPTIONS_LINK_WIDTH`); `ns.OptionsGroupContextToggle` / `ns.OptionsGroupContextRow` / `ns.OptionsGroupContextNone` / `ns.NoGroupContextTicked`; `ns.AddFeatureOffLine` (a sub-page's line while its parent switch is off; settings stay editable); `ns.PrintedExampleLines`; `ns.OptionsSpellDescription`; `ns.OptionsProfileSettings`.
- **Widgets** (`Options-Widgets.lua`): `ns.ICON_CHECKBOX_WIDGET_TYPE`, the stock checkbox re-placed for an icon gap (`ns.RESTOCK_ICON_TEXT_GAP`) after image set, press and release; registered under its own name so other add-ons' checkboxes are untouched; set to nil where AceGUI has no stock CheckBox. The item link cell is the kit's.
- **Whisper composer** (`Options-Message-Composer.lua`): `ns.DefineWhisperComposer(args, spec, order)` for Buff Duty's ask and Rank Watch's whispers. Send Messages In (`ns.SetMessageLanguage`, omitted with `spec.language = false`); per message: caption, target-marker and `// GtG` sign-off as captions (added by the build, so not deletable), box, Reset, tokens line, too-long line when `message.fill` passes `ns.CHAT_MESSAGE_MAX_LENGTH` in bytes, Example via `Kit.SentLine("WHISPER", ...)`, Send Test to Me (`ns:WhisperTestToSelf`). No live count: the panel redraws only on save.
- **Root panel** (`Options-General.lua`): welcome, Enable Mini-map Button (inverse of `global.minimap.hide`, then `ns:ApplyMinimapButton`), Features, Key Bindings rows from `KeyBindings()` (key text, Set Key → `ns:OpenKeyBindings`; repainted by `OnUpdateBindings` in `Features/Key-Bindings.lua`), /Commands (Rank Watch's ignore line where loaded).
- **Item lists.** `Kit.ItemList(spec)` (Add from Bags, Add Item, sorted rows, optional action column and tag, Restore Defaults / Clear List at the foot); cold rows warm through `Kit.WarmItems` (bounded poll per registry name). Windows outside the options use `ns.WarmItemCache` (`Features/Item-Info.lua`) instead.
- **Slash commands** (`Options.lua`): `/gtg` opens the root, except `/gtg ignore Name` goes to `ns.IgnoreRankWatchPlayer` where loaded (README-Notes exception); `/restock` → `ns.HandleRestockerCommand`.

### Diagnostics

- **Off at every login, never saved** (`ns.diagnostics`, plain runtime table in `Diagnostics-Core.lua`). Turning the toggle off stops the log and clears every report.
- **Manifests contract** (`Diagnostics/Manifests.lua`): creates empty `ns.DIAGNOSTIC_API_CHECKS` (`{ label, check }`), `ns.DIAGNOSTIC_SPELLS`, `ns.DIAGNOSTIC_NAME_LOOKUPS`, `ns.DIAGNOSTIC_DATA_SOURCES` (`{ label, sources = { { table, kind, collect, ... } } }`). Each `Manifests-<Feature>.lua` appends through `ns.AppendDiagnosticRows`, which skips an API check whose label is already present and merges data-source rows sharing a label (Game-IDs: several features, one report).
  - `Report-Runner.lua` turns each `ns.DIAGNOSTIC_DATA_SOURCES` entry into a Data report at file load, so every manifest must load before it.
- **Event Log** (`Event-Log.lua`): drops only `SPELL_UPDATE_COOLDOWN` (`ns.DIAGNOSTIC_EVENT_EXCLUDE`). Firehoses are classified per firing in `ns:SuppressUncorrelatedMessage`: id-carrying events by `ns.MESSAGE_ID_FILTERED_EVENTS` (logged when a feature correlates them, else counted), id-less ones by `GATED_EVENTS` (the handler's own test, or a decoder that writes the firing through `ns:LogEventNow`).
- Validate Data looks every data row up on this client and prints TSV per kind. Message Length builds every sent line and macro body at its widest without sending or writing; the byte ceiling makes the widest-encoding locale (usually ruRU) the canary.
- The panel's name is plain English (`ns.DiagnosticsStrings.TAB`), registered last.

### Tests (`Tests/Run.lua`)

- Never in a TOC; `.pkgmeta` ignores `Tests`. Run with Lua 5.1 from the add-on root.
- **Event names**: tokenizes every Lua file the four TOCs list (not `Includes/`, `Locales/`) and fails on an event-shaped string it finds in an events-named table constructor, an events loop's inline list, `table.insert` into one, `event ==` / `~=` comparisons, or a `Set*Event*` / `Set*Handler` call's own arguments, that `ns.EVENT_NAMES` lacks. Self-tests the scanner on fixed cases first.
- **Forever combat log**: a Camelot-TOC file naming `COMBAT_LOG_EVENT_UNFILTERED` fails unless its source holds the literal `ns.FLAVOR ~= "Camelot"`.
- **Prune**: lifts `Core.lua`'s source from `local REALM_KEY_SEPARATOR` through the end of `PruneOtherClientCharacters`, runs it in a sandbox (`type`, `pairs`, `ipairs`, `GetRealmName`, `ns.db`) both directions, including the older Forever name.
- **Event log noise**: runs `Diagnostics/Event-Log.lua` in a sandbox against `UI_ERROR_MESSAGE` folding.

## Files That Change Together

- **New registered event**: `ns.EVENT_NAMES` in `Features/Core.lua` (flavor-guarded append if a client lacks it); `ns.SetModuleEvent` on and off at the feature's switch, or the feature's own list (`WINDOW_EVENTS`, `EVENTS`, `EVENT_HANDLERS` + `EVENT_UNITS`); a handler in the module's dispatcher or handler table, shared if the event is already taken. `Tests/Run.lua` catches a missed list entry.
- **New event module**: `ns.RegisterEventModule` in a file whose TOC position sets its dispatch order, in every TOC that should load it, after `Features/Core.lua`.
- **New data table**: a file in all seven `Data/{Game}/` folders (empty where no rows; Vanilla and Discovery files carry their guard); listed in all four TOCs between `Data/Message-Languages.lua` and `Data/Default-Settings.lua` (Vanilla TOC: both its folders); a `ns.DIAGNOSTIC_DATA_SOURCES` row via `ns.AppendDiagnosticRows` in the owning `Diagnostics/Manifests-*.lua`.
- **New saved setting**: its `ns.DATABASE_DEFAULTS` key (or the feature's `AddDefaults` block) with its scope reason beside it; its options row; locale keys in `Locales/enUS.lua`; a hook in `ns:ApplyProfile` if it is profile-scoped and applied imperatively; a Diagnostics context line.
- **New feature master switch**: an `ns.FEATURES` record (`Options/Options-Feature-Switches.lua`: `store`, `setting`, `name`, `caption`, `desc`, `apply`, optional `confirm`, `block`) with its `SWITCH_*` locale keys; its `global` default in `Data/Default-Settings.lua`; `Kit.FeatureSwitch(setting)` atop its panel; its panel's `Kit.RegisterPanel` at the matching position in `ns.RegisterOptionsPanels` (tree order is hand-written); the feature's event subscribe and release in its setter; `block = true` only with a hand-built block in `BuildMainEntries` (`Minimap-Menu.lua`), otherwise More Features picks it up.
- **New setting that acts by group**: a `{ solo, party, raid, battleground }` default, all `true`; read through `ns.IsGroupContextOn` (or `ns.IsUseWhenActive` for a consumable's `<prefix>In` + `<prefix>Level` pair); `ns.OptionsGroupContextRow` or `ns.OptionsGroupContextToggle` plus `ns.OptionsGroupContextNone` on its panel; the mini-map menu's `WaitingLabel` if it shows there; a Diagnostics context line. Consumable group reads are already inside `ns.GroupSignatureChanged`.
- **New options panel**: an `ns.OPTIONS_REGISTRY` key (`Data/Data.lua`, tree order); a `Kit.RegisterPanel(key, builder, title[, parentKey])` call in `ns.RegisterOptionsPanels` (`Options/Options.lua`), whose call order is the tree order; the builder file in each TOC before `Options/Options.lua`; a locale title.
- **New key binding**: `Bindings.xml` with `category="BINDING_HEADER_GOODTOGO"`; `BINDING_NAME_*` set in the feature file (plus `.luacheckrc` `globals` unless set through `_G[...]` as the Buff Key's is); a row in `KeyBindings()` (`Options/Options-General.lua`).
- **New client-divergent API**: an accessor in `Features/Utilities.lua` resolved once at load that answers nil (or neutral) where missing, listed in its Client Differences comment; an API row in the feature's `Diagnostics/Manifests-*.lua`; `.luacheckrc` read globals.
- **New slash command, popup or macro global**: the code (slash commands register in `Options/Options.lua`), plus the `.luacheckrc` `SLASH_*` global, `SlashCmdList` field, `StaticPopupDialogs` field or global.
- **New group-chat sent line**: locale key(s); a builder in `Features/Announcements.lua` over `ns:BuildAnnounceMessage`; sent through `ns:SayBuffRequest` / `ns:QueueAutomatedWhisper`; a row in `ns.DIAGNOSTIC_MESSAGES` (`Diagnostics/Manifests-Buff-Duty.lua`) or the Rank Watch Message Length report.
- **New editable whisper**: a field in every `Data.MESSAGE_LANGUAGES` row; an `Data.EDITABLE_MESSAGES` entry (scope, key); a Fill/Build pair in `Features/Announcements.lua` (`SignOff`, `FillTokens`, `BuildEditable`); a `ns.DefineWhisperComposer` call on its panel; a note in the feature's defaults comment that the key has no default; a Message Length row.
- **New message language**: a `Data.MESSAGE_LANGUAGES` row with `locale`, native `name` and every field; nothing else (the dropdown and `MigrateMessageLanguage` read the table).
- **New one-time migration**: a tagged `MIGRATION (remove after YYYY-MM-DD)` file listing its removal pieces; its tagged line in all four TOCs; its call in `InitializeDatabase` at the right point (raw before `AceDB:New`, or after the prune and before the callbacks), existence-tested if an older file calls it (a `/reload` doesn't load new TOC files); every tag at each touch point.
- **New consumable macro**: `ns.MACRO_CONFIG` (`Data/Data.lua`) with `MACRO_*` / `LABEL_*` keys (a shipped name never changes); `ns.MACRO_DEFAULT_ITEM_IDS` in every `Macro-Default-Items-{Game}.lua`; `Macros/<Name>.lua` calling `ns.RegisterMacroType`, in all four TOCs among the definition files; `enabledMacros[type]` in `Data/Default-Settings.lua`; a `MacroToggle` row in `Options-Macros.lua`; multi-use needs both `ranked = true` and `ns.MULTI_USE_MACRO_TYPES`; conjures need `CONJURE_SHAPES` (`Message-Length-Macros-for-Consumables.lua`) and, for non-default `GetSmartSpell` flags, `CONJURE_CAST_FLAGS` (Manifests); class-only custom macros need `CLASS_ONLY_MACROS` (Manifests); DruidMacroHelper needs `ns.DRUID_MACRO_HELPER_TYPES` / `ns.DRUID_MACRO_HELPER_GUARDS`; class click notes in `Macro-Notes.lua` if it has clicks.
- **New consumable item type**: the table in every flavor folder and TOC; a `CONSUMABLE_TABLES` entry with its facts column (`Item-Cache.lua`); a branch in `ns.CacheItemData`; any new gate in `ns.ScanBags` mirrored in `FailedGate` (Manifests); a `ns.DIAGNOSTIC_DATA_SOURCES` row (Manifests).
- **New ranking step**: `RANKING_PRIORITY`, `FillRecord`, `ResetBest` (`Scanner-Ranking.lua`) and `CopyCandidateRecord` (`Scanner-Diagnostics.lua`), as a real boolean; a gated step also needs its gate threaded through `CompareRecords`, `IsBetter`, `RetainCandidate`, `CaptureDiagnosticCandidates`, the dispatch in `ns.ScanBags` and a definition field.
- **New standard-body input** (a hook like `combatSpell`): the protocol comment in `Definitions.lua`; the hook call in `ns.UpdateMacros`, passed to both `ns.BuildStandardBody` and `ns.BuildStateKey`; a state-key flag and the format comment; every recursive trim call passing it on, plus its place in the trim order; the mode body if it applies there; `LongestBodyFor` in `Message-Length-Macros-for-Consumables.lua`.
- **New body-shaping consumable setting**: profile default; panel row whose setter calls `ns.ResetMacroState()` + `ns.RequestUpdate()` or `ns.ToggleMacroSetting`; folded into the state key (`stateExtras`, an `appendBlock` flag, or `ns.BuildStateKey`); `AURA_TRACKED_SETTINGS` (`Engine.lua`) or an explicit `ns.UpdateAuraTracking()` (as `usePetBuffFood` does) if it changes aura tracking; `ns.TargetSignatureChanged` or `ns.GroupSignatureChanged` if it reads target or group state; a line in `AppendChoices` / `AppendClassAndRace` (Manifests).
- **New When to Use pair**: `<prefix>In` + `<prefix>Level` defaults; `ns.IsUseWhenActive(settings, prefix)` at the read; `FeatureModeSelect` / `ModeSubRow` plus `UseWhenGroups` in `Options-Macros.lua`; `UseWhenText` line (Manifests).
- **New Readiness switch**: a `readiness*` global default (the prefix is what Reset reaches); a `SECTIONS` row (`Options-Readiness-Report.lua`); `READINESS_SWITCHES` and a gate line in `ns:BuildReadinessDiagnosticReport` (Manifests); the check (`Readiness-Report.lua`); the sample (`Readiness-Report-Example.lua`), sharing a `ns.ReadinessAsks*` gate; any new API in the Manifests API rows.
- **New macro runtime global**: `Runtime.lua`; `.luacheckrc` globals; byte cost against `ns.MACRO_BODY_MAX_LENGTH` in every body that writes it.
- **New action bar for name hiding**: `ACTION_BAR_PREFIXES` (`Action-Button-Text.lua`) and the copy in `AppendMacroWriting` (Manifests).
- **New Inventory Report record field**: `ns.InitializeInventoryReport`; readers in `OtherCharacters` (tooltip), `AddRecordedCharacters` (panel) and the Restock List's class coloring.
- **New Restocker row field**: `ItemToString` / `ItemFromString` as a trailing field with its default; `ns.AddRestockItem` and `ns.AddStarterCategory` defaults; for a column, `COLUMNS` (`Restocker-Window-Columns.lua`), `COLUMN_STATE` / `COLUMN_TOGGLE` / `NOT_APPLICABLE_REASON` (`Restocker-Window-Cells.lua`), `COLUMN_SET` (`Restocker-Window-Menus.lua`), caption/title/body locale keys; the row counts in `ns:BuildRestockerContextReport`.
- **New Restocker setting**: `global.restocker` default (`Data/Default-Settings.lua`); a control in `ns.BuildRestockerOptions`; locale keys; a context line in `Manifests-Restocker.lua`.
- **New reminder mode**: an `ns.REMINDER_*` constant (`Data/Data.lua`); `ReminderModes` + `REMINDER_MODE_ORDER` (`Options-Restocker.lua`); a branch in `ns.BuildRestockShortfallLines`; `OPTIONS_RESTOCKER_MODE_*` key.
- **New Staples row**: `ns.STARTER_LIST_CATEGORIES` (`Restocker-Starter-Categories.lua`); a matching chain in every `Consumable-Upgrade-Paths-{Game}.lua` (key forms in `CHAINS_BY_KEY`, `Restocker-Starter-List.lua`); a label key only for a kind-of-item row; a new `section` needs a block in `OfferedSections` (`Restocker-Starter-Sections.lua`) and a header key.
- **New Restocker event**: a `WhileEnabled` entry in `ns.InitializeRestockerEvents` and the name in `EVENTS` (`Restocker-Events.lua`); a second use of an existing event calls from its handler.
- **New wait on item data**: its queue in `ns.SyncRestockItemInfoSubscription` and a drain (plus failed-answer drop) in `ns.OnRestockerItemInfoReceived`; call the sync after every add to it.
- **New list operation**: go through `ns.UseRestockList` (or call `ns.ClearRestockNewItems` when not switching); `ns.UpdateRestockListWidgets`; `ns.UpdateRestockList`; `ns.StartRestockBankRun` if `ns.bankIsOpen`.
- **New window menu**: an AceGUI pullout with a close function added to `ns.CloseRestockMenus`; `ns.CloseRestockMenus()` before opening; closed in `ns.UpdateRestockList` if a redraw would stale it.
- **New window control**: `ns.SetRestockControlClick` so a carried item drops instead of clicking; `ns.ApplyRestockerElvUISkin` list in `ns.CreateRestockWindow`; a parent of the header bar or footer row, never the window.
- **New Buff Duty party buff**: a row in `ns.BUFF_DUTY_SPELLS` in every `Buff-Duty-Spells-{Game}.lua` (legend atop the file); nothing else for an ordinary row (Party-Buffs, the event-log filter and Validate Data read the table).
- **New Buff Duty self buff sharing an exclusive family**: `ns.BUFF_DUTY_SELF_SPELLS` rows in each flavor file, plus `BUFF_DUTY_SELF_NOTE_<FAMILY>` in every locale.
- **New Self-Buffs consumable** (any class): a `ns.BUFF_DUTY_SELF_ITEMS` row `{ item id, auras = { spell ids }, default }` in each flavor file; it lands in the Self-Buffs panel's Consumables box.
- **New Buff Duty window setting**: `buffWindow` default (`Data/Default-Settings.lua`); a panel row whose setter calls `ns.RefreshBuffDuty`; any choice list in `Data/Data.lua` plus cleaning in `PopulateBuffDutyAudience`; locale keys; a line in `ns:BuildBuffDutyContextReport`; `SyncCombatLog`'s `wanted` if it needs the combat log.
- **New Buff Duty event**: `WINDOW_EVENTS` or the always-on list, plus `EVENT_UNITS` for a unit filter (`Buff-Duty-Events.lua`); the handler via `ns.SetBuffDutyEventHandler` in the owning file; `ns.EVENT_NAMES` in `Features/Core.lua` (`Tests/Run.lua` checks).
- **New section kind**: its adder in `BuffDuty.BuildSections`, appended singly; the frame's top/party split and Party-Buffs placement (`section.kind`, `section.party`); `Candidates` in `Buff-Duty-Key-Picker.lua`, or the key never casts it.
- **New spec field that changes what a button does**: `ns.SetBuffButtonAttributes` (and its nil-clear key list); `Signature` in `Buff-Duty-Layout.lua`, or an unchanged signature skips the redraw.
- **New weapon item kind**: `Data.WEAPON_ITEM_KINDS`, `Data.WEAPON_ITEM_KIND_HANDS` if hand-limited, `BUFF_DUTY_WEAPON_KIND_<KIND>` in every locale, the rows' kind field.
- **New Buff Duty file**: all four TOCs, after every file it captures at load and before every file that captures it.
- **Removing the 2026-12-03 key migration**: `OLD_KEY_BUTTON`/`OLD_KEY_COMMAND` and the `_G` alias (`Buff-Duty-Keys.lua`), the `ns.MigrateBuffKeys` call (`Buff-Duty.lua`), the Bindings.xml comment, the old-binding lines in `Manifests-Buff-Duty.lua`.
- **New class spell**: its ID in the right lists of `Class-Spell-Lists-{Game}.lua`; a `Trainer-Spells-{Game}.lua` row, or `extraSpells` plus `ns.EXTRA_SPELL_SOURCES`; group spells in `ns.SPELL_GROUPS` / `ns.GROUP_VERSIONS`.
- **New page category**: `ns.PAGE_CATEGORIES` + `TAG_CATEGORIES` (`Page-Categories.lua`); the tag in `PAGE_TAGS` (`Class-Config.lua`, first tag wins); the tag list in the class lists or `ns.SHARED_PAGE_SPELLS`; a `CATEGORY_*` locale key.
- **New macro kind**: `ns.MACRO_KINDS` + a `ns.MacroKind` branch (`Macro-Kinds.lua`); `kindDefaults.<kind>` (`SPELLBOOK_DEFAULTS`, `Data/Default-Settings.lua`); `KIND_*` keys; `PRIORITY_KINDS` / `LEFT_OUT_UNITS` (`Target-Priority.lua`) and `KIND_CATEGORIES` where relevant.
- **New Spellbook macro option**: a profile table in `SPELLBOOK_DEFAULTS`; the key in `Macro-Settings.lua`'s option list; an `OFFERED` predicate (`Macro-Options.lua`); its line in `Macro-Body.lua`; `ns.DEFAULTABLE_OPTIONS` or `COPIED_SETTINGS` (`Macro-Copies.lua`) so Duplicates, resets and handover carry it; its menu entry (`Menu-Utilities.lua` tables or `Macro-Menu-Sections.lua`, plus `Category-Menu.lua`); `OPTION_SUBTEXTS` (`Macro-Button-Notes.lua`); `MENU_*` / `SUBTEXT_*` keys; `PER_SPELL_OPTIONS` (`Diagnostics/Manifests-Enhanced-Spellbook.lua`); a Message Length check.
- **New Spellbook event**: `EVENT_HANDLERS` (+ `EVENT_UNITS`) in `Spellbook-Core.lua`; `ns.EVENT_NAMES` (`Features/Core.lua`); an `ns:On<Name>` handler whose name is unique across all of `ns`; `LOGIN_REGISTERED_EVENTS` / `WHILE_OFF_EVENTS` if it needs either.
- **New Conditionals condition**: `ns.CONDITIONS` (`Conditionals.lua`); `ns.ConditionBlockReason` if it clashes; locale keys.
- **New Cast Sequence reset**: `ns.CAST_SEQUENCE_RESETS` (`Cast-Sequence.lua`); locale keys.
- **New What's Next status or source**: `ns.WHATS_NEXT_STATUSES` (+ `ns.WHATS_NEXT_INKS` / `ns.WHATS_NEXT_BRIGHT` in `Data/Data.lua`) or `ns.WHATS_NEXT_SOURCES`; pet ones in `ns.WHATS_NEXT_PET_STATUSES` / `ns.WHATS_NEXT_PET_SOURCES`; `PET_COUNTS` / `PET_COUNTS_NO_TEACH` for pet statuses; locale keys.
- **New window tab**: `TABS` (`Spellbook-Window.lua`); a page builder; a model in `ns.WHATS_NEXT_MODELS` for a list tab; locale keys.
- **New login-pair API** (one call on Classic, another on Camelot): both halves in the API checks of `Manifests-Enhanced-Spellbook.lua`.
- **New Rank Watch setting Reset Profile should reach**: `rankWatch` default (`Data/Default-Settings.lua`); `RESET_KEYS` (`Rank-Watch-Core.lua`); its control in `Options-Rank-Watch.lua`; locale keys; a line in `ns:BuildRankWatchContextReport`.
- **New Ability Alerts While Leveling option**: `rankWatch` default; `RESET_KEYS`; a `LevelUpSubRow` in `Options-Rank-Watch.lua`; `LevelUpLines` and `ns.LevelUpAlertExample`; the Alerts line and `NextPetLine` in `Manifests-Rank-Watch.lua`; locale keys.
- **Pet-line rule or `HUNTER_PET_LEVEL`**: `LevelUpLines` (`Rank-Watch-Level-Up.lua`) and its copy in `NextPetLine` / `HUNTER_PET_LEVEL` (`Manifests-Rank-Watch.lua`).
- **New Rank Watch editable whisper**: a field in every `Data.MESSAGE_LANGUAGES` row and a `Data.EDITABLE_MESSAGES` row with `scope = "rankWatch"` (`Data/Message-Languages.lua`); a fill/build pair in `Features/Announcements.lua`; the send site; a message in a `ns.DefineWhisperComposer` block in `Options-Rank-Watch.lua` (inside its order slot); a `TextState` in `Manifests-Rank-Watch.lua`; a row in `Message-Length-Rank-Watch.lua`; no AceDB default.
- **New Rank Watch print line**: `RANK_WATCH_PRINT_*` key (plus `_PET` / `_DEMON` forms) in every locale; builder in `Rank-Watch-Check.lua`; the panel Example if shown.
- **New detection event**: `ns.EVENT_NAMES` (`Features/Core.lua`, enforced by `Tests/Run.lua`); `ns.SetRankWatchHandler`; subscription in the detection file's `ns.SyncRankWatchDetection` (or Core's `EVENTS` for every flavor); a decode in `Diagnostics/Event-Log.lua` if it should be logged.
- **New Rank Watch constant**: `Data.RANK_WATCH` (`Data/Data.lua`); a Context report line if it gates anything.
- **Announced key or cluster message shape**: `ns.CheckRankWatchCast`, `ANNOUNCED_KEY_PATTERN` (`Rank-Watch-Cluster.lua`), the `rankWatch` comment in `Data/Default-Settings.lua`; must stay what the standalone Rank Sentinel sends and reads.
- **New outside caller of Rank Watch code**: an existence test, since Mists loads none of it.
- **New group setting shown in the menu**: only for a menu block's switch; for Buff Food & Scrolls, add its `{ switch, prefix }` pair to the loop in `AddBuffFoodAndScrolls` (`WaitingLabel` reads `<prefix>In` / `<prefix>Level`).
- **New menu row that changes a setting**: call the same setter its options control uses; tooltip from the option's caption / desc; a click only by adding a `CLICKS` entry (none free); ends in `AfterChange` (`ns.RefreshSettings`).
- **New button click job**: a `CLICKS` entry and its `MENU_CLICK_*` key; its menu row through `ClickRow`.
- **New diagnostic manifest file**: append through `ns.AppendDiagnosticRows`; TOC line after `Diagnostics/Manifests.lua` and before `Diagnostics/Report-Runner.lua` in every TOC.
- **Renaming the menu frame**: `Kit.CreatePanel(ADDON_NAME .. "Menu")` (`Minimap-Menu.lua`) and `MenuClosesOnEscape` (`Diagnostics/Settings-Reports.lua`).

## Saved Variables

- **`GoodToGoDB`** (`ns.SAVED_VARIABLES_NAME`): the one table, AceDB-3.0 with `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`). Feature blocks join through `AddDefaults`, which asserts no two features declare one key.
- **`BagsBuffsButtonsDB`** (`ns.OLD_SAVED_VARIABLES_NAME`): pre-rename table, second on every TOC's `## SavedVariables`, only for its migration.
- **Model: Per-Character.** `AceDB:New` takes no default-profile argument, so every character lands on a profile named for it.
  - Reset Profile clears that character's profile only; `global` and `char` survive, and `OnProfileReset` re-applies.
  - **Profile**: consumable choices (including `scrollTypes`, `<prefix>In` / `<prefix>Level`, poison groups), the Ignore List's character half, the Spellbook's per-spell option tables, `kindDefaults`, `macroCopies`, `markedPlaced`, `trainerSpells` (by class).
  - **Global**, each with its reason beside its key: presentation (`showWelcome`, `showMacroNames`, `minimap`, `abilityTooltipRanks`, `inventoryReport`); master switches (`macrosEnabled`, `restockerEnabled`, `spellbookEnabled`, `readinessReportEnabled`; Buff Duty's and Rank Watch's live in their blocks) and `readiness*`; what every character shares on the client (`enabledMacros`, `ownedMacros`, `macroTags`, `macroTagCount`); data the player built or the add-on gathered (`restocker`, `inventory`, the Ignore List's Global half); `buffWindow`; `rankWatch`; `messageLanguage` (one language for both features' whispers). `legacyImported` and `messageLanguageMigrated` have no defaults and are written directly.
  - Two README-Notes exceptions keep per-character records off the profile so Reset Profile can't reach them: `restocker.listChoices` on global, and `char.ownedMacros`.
- **Seeding.** Nothing seeds a list on empty. `scrollTypes`' defaults are built at file load by `DefaultScrollTypes` from each `ns.SCROLL_DATA` type's `classes` and the logged-in class, so the defaults table differs by class. Editable whisper texts have no default key; unset means the language's default.
- **AceDB quirks the code leans on**: scalar and table defaults are copied into the live table on first access, so after `AceDB:New` a migration can't tell a saved value from a default by reading normally (hence `rawget` / `rawset`, and raw reads of `_G[ns.SAVED_VARIABLES_NAME]` before `New`); a profile nobody has loaded holds only what differs; every value equal to its default is stripped at logout, so an empty default subtable is nil by the time the add-on's own logout handler runs.

### By Feature

- **Consumable Macros and reports.** Which macros exist (`enabledMacros`, read through `ns.IsMacroEnabled`, missing = on) is account-wide because the macros live in the General tab. Other profiles' Ignore Lists are read raw from `ns.db.sv.profiles`. The item cache is session-only. Readiness Reset writes defaults straight across, safe only while every `readiness*` default is a scalar.
- **Restocker.** All global, so a profile switch or Reset Profile can't empty a list and one Gold Reserve holds back every alt. Each character's choice is keyed by `ns.GetCharacterProfileName` and outlives a deleted character; `currentList` is runtime only. Rows are one-line strings on disk (`Restocker-Saved-Format.lua`).
- **Buff Duty.** All in `global.buffWindow` (every character buffs the same way). Seeding (`PopulateBuffDutyAudience`) fills only keys never saved, from row defaults, drops values the dropdowns don't offer and keeps keys this client lacks, since Era and Season of Discovery share the file. Unset per-class and weapon choices read as on. Never saved: the session close, favors, holds, NPC cycles, the aura cache, skip memory.
- **Enhanced Spellbook.** Tags and ownership are facts about the WoW macro lists, kept on `global` and `char` and keyed by `ns.MacroOwnerKey`, so no profile switch or reset loses them; everything else is profile. Option tables store nil at the default; `kindDefaults` stores true/false so an explicit off survives AceDB's merge.
- **Rank Watch.** On `global`, but Reset Profile reaches it (README-Notes exception): `resetListener.OnProfileReset` writes `RESET_KEYS` back from `ns.DATABASE_DEFAULTS.global.rankWatch` and wipes `untracked`, keeping Ignored Players, the announced record and the whisper texts. No seeding: an untouched rank follows its data `off` flag. `ns.RankWatchSettings()` writes (a migration), so probes read `ns.db.global.rankWatch` directly.
- **Mini-map.** LibDBIcon's table on `global`, so a profile switch or reset never moves or hides the button.
- **Diagnostics.** Never saved.

### Migration Chain

Run order in `PLAYER_LOGIN`: `ns.TurnOffReplacedAddons` (permanent), then `InitializeDatabase`:
1. `MoveRenamedSettings` (2026-12-03)
2. `MigrateMessageLanguage` (2026-12-13), raw, before the legacy import so only Good to Go's own saved data counts
3. `ns.ImportLegacySettings` (2026-12-08), raw
4. `AceDB:New`
5. `PruneOtherClientCharacters` (permanent; its `IsOlderForeverKey` branch is 2026-12-08)
6. `UseOwnProfileWhenUnnamed` (permanent)
7. `global.messageLanguageMigrated = true` stamp (2026-12-13), so fresh installs never run step 2 later
8. `ns.MoveGroupSettingsOntoCheckboxes` (2026-12-11), before any profile copy
9. `ns.MoveRestockRemindersOntoSimple` (2026-12-13), existence-tested
10. `ns.RetireAutomatedAppreciation` (2026-12-08)
11. `ns.RetireSavedItemCache` (2026-12-08)
12. `ns.RekeyCharactersByFullName` then `ns.MoveCharactersOntoOwnProfiles` (2026-12-08), in that order
13. the profile callbacks

Then each module's `PLAYER_LOGIN` (load order) runs its own: Restocker (`InitializeRestocker`), Rank Watch (`OnPlayerLogin`), Buff Duty (`ns.SetupBuffDuty`), Spellbook (`OnPlayerLogin`). `PLAYER_ENTERING_WORLD` runs `ns.PrintLegacyNotices` / `ns.OfferLegacySteps` from `ns:PrintWelcome`. Buff Duty's position moves on first render.

By removal date:

- 2026-11-18: Buff Duty `petsAsTanks` / `petsAsTanksWhen` become `tankWhen.PET` (`Buff-Duty-Settings.lua` `PopulateBuffDutyAudience`).
- 2026-11-21: self buffs stored at 5 move to 3 and the Soulstone's When Missing to 3, once per key via `buffWindow.selfRefreshMigrated` (`Buff-Duty-Settings.lua` `PopulateBuffDutyAudience`; default in `Data/Default-Settings.lua`).
- 2026-11-21: Group Buff key `OLD_GROUP_COMMAND` moves to the Buff Key (`Buff-Duty-Keys.lua` `ns.MigrateBuffKeys`).
- 2026-11-23: Spellbook pre-prefix macro names (`LEGACY_NAME_MAX_LENGTH`, `LegacyMacroName`, `ns.LegacyMacroName`) and the `"claim"` ownership state (`Macro-Lookup.lua` `ns.LegacyOwnership`, `Macro-Sync.lua` locals).
- 2026-11-26: Spellbook `~` prefix (`OLD_PREFIX`, `OldPrefixName`, `ns.OLD_MACRO_PREFIX`; `Macro-Lookup.lua`, `Macro-Sync.lua`).
- 2026-11-26: `Spellbook-Core.lua` `OnPlayerLogin`: `customMacros` / `customMacrosSeeded` dropped from every profile, `global.professionSkills` dropped, flat `trainerSpells` moved under the class, macro records moved from `ns.db.keys.char` to `ns.MacroOwnerKey`.
- 2026-11-29: Buff Duty top-left position becomes top-right (`ns.MigrateBuffDutyPosition`, `Buff-Duty-Position.lua`; called from `ns.RenderBuffDuty` in `Buff-Duty-Frame.lua`; the top-left branch of `RestorePosition`).
- 2026-12-03: the rename (`MoveRenamedSettings` in `Core.lua`, `ns.OLD_SAVED_VARIABLES_NAME` in `Data.lua`, the second `## SavedVariables` entry and its comment in every TOC).
- 2026-12-03: hidden `MACROSPELLBOOK_TOGGLE` binding (`Bindings.xml`) and `ns.MigrateSpellbookBinding` (`Enhanced-Spellbook/Key-Bindings.lua`, called from `Spellbook-Core.lua` `OnPlayerLogin`); its `SetBinding` / `SaveBindings` / `GetCurrentBindingSet` API rows (`Diagnostics/Manifests-Enhanced-Spellbook.lua`).
- 2026-12-03: `TFTBBuffIndividual` alias (`_G[OLD_KEY_BUTTON]`) and `OLD_KEY_COMMAND` key move (`Buff-Duty-Keys.lua`; the `ns.MigrateBuffKeys` call in `ns.SetupBuffDuty`, `Buff-Duty.lua`).
- 2026-12-08: legacy import: all of `Features/Legacy-Migration.lua` and its TOC lines, `ns.LEGACY_ADDONS` (`Data.lua`), the `ns.ImportLegacySettings` call and the `ns.PrintLegacyNotices` / `ns.OfferLegacySteps` test in `ns:PrintWelcome` (keep the `ns.OfferReplacedReload` call), the `ns.IsLegacyImportPending` gate (`Restocker-Starter-List.lua`), `CHAT_LEGACY_*` / `POPUP_LEGACY_*` in every locale, `GOODTOGO_LEGACY_IMPORT` in `.luacheckrc`, the legacyImported report (`Diagnostics/Manifests-Macros-for-Consumables.lua`). `ns.REPLACED_ADDONS` and `Features/Replaced-Addons.lua` stay.
- 2026-12-08: Core retirements: `ns.RetireAutomatedAppreciation` (`Legacy-Migration.lua`); `ns.RetireSavedItemCache` (`Item-Cache.lua`).
- 2026-12-08: Connoisseur & Restocker repairs: `Character-Key-Migration.lua` (`ns.RekeyCharactersByFullName`), `Default-Profile-Migration.lua` (`ns.MoveCharactersOntoOwnProfiles`), their TOC lines and calls, the `noDefaultProfiles` argument in `Options/Options-Profiles.lua`, `FOREVER_RULE_SETS` / `IsOlderForeverKey` in `Core.lua`, its test in `Tests/Run.lua`.
- 2026-12-08: macro callbacks: `Connoisseur*` aliases (`Macros/Runtime.lua`, `.luacheckrc`).
- 2026-12-08: Rank Watch: `StandaloneProfile` / `ImportStandaloneSettings` (`Rank-Watch-Core.lua`), `rankWatch.importedStandalone` default, the `maxLevelOnly` removal in `ns.RankWatchSettings`, `RankSentinelDB` in `.luacheckrc`.
- 2026-12-08: Restocker: type-before-name saved line (`Restocker-Saved-Format.lua`), empty legacy `Name-Realm` lists kept by `ns.PruneEmptyOrphanRestockLists` (`Restocker-Saved-Lists.lua`), `starterListDismissed` cleared (`Restocker-Core.lua`), the existence-tested `ns.InitializeInventoryReport` call (`Restocker-Events.lua`).
- 2026-12-08: Spellbook: `markedPlaced` read by WoW macro name (`Page-Settings.lua` `ns.IsMarkedPlaced`).
- 2026-12-11: group settings onto the four checkboxes (`Features/Group-Context-Migration.lua` `ns.MoveGroupSettingsOntoCheckboxes`, its TOC lines, the call in `InitializeDatabase`). `buffWindow.showSolo` / `showParty` / `showRaid` become `showIn` (Battleground takes Raid's answer), `*Where` keys move into `showWhere`; each profile's `<prefix>Mode` becomes `<prefix>In` + `<prefix>Level`.
- 2026-12-13: Send Messages In keeps a whispering account's client locale (`MigrateMessageLanguage` and the `messageLanguageMigrated` stamp in `Core.lua`; the stamp left in saved data is harmless).
- 2026-12-13: restock reminders onto Simple (`Features/Restock-Reminders-Migration.lua` `ns.MoveRestockRemindersOntoSimple`, its TOC lines, the guarded call in `InitializeDatabase`); leaves `remindersMovedOntoSimple`, harmless after removal; its untagged line in `Diagnostics/Manifests-Restocker.lua` goes too.
- 2026-12-13: Restocker existence tests for the new `Restocker-Town-Reminder.lua` (`ns.ArmRestockerReminders` in `Restocker-Core.lua` `ns.SetRestockerEnabled`; `ns.OnRestockerArrival` and the in-town handlers in `Restocker-Events.lua`).
- 2026-12-13: Forever hunter-trainer pet abilities purged from every profile's `trainerSpells` (`Spellbook-Core.lua` `OnPlayerLogin`, `ns.IsPetAbilitySpell`).
- 2026-12-15: Rank Watch `optOutOffered` dropped and an `optOutMessage` holding `{code}` reset to default (`Rank-Watch-Core.lua` `OnPlayerLogin`).

## Pitfalls & Why

### Secure frames and the client

- **Registering `COMBAT_LOG_EVENT_UNFILTERED` on Forever**: `ADDON_ACTION_FORBIDDEN`, which `pcall` can't catch. It is in `ns.EVENT_NAMES` only off Camelot, the combat-log files stay out of the Camelot TOC, and `Tests/Run.lua` fails a Camelot-listed file naming it without a literal `ns.FLAVOR ~= "Camelot"`.
- **Registering an event the client lacks**: it throws. `PLAYER_FOCUS_CHANGED` joins `ns.EVENT_NAMES` only off Vanilla; a new client-specific event needs the same guard.
- **Calling `GetItemInfo`, `GetSpellInfo`, `UnitBuff`, `IsSpellKnown` or `IsPlayerSpell` as globals**: Forever has dropped them or keeps them only in a deprecation layer (`loadDeprecationFallbacks`). Use `C_Item`, `C_Spell`, `C_UnitAuras`, `ns.IsSpellKnown`, `ns.IsPlayerSpell` (both read `C_SpellBook`).
- **An API one client lacks**: put it behind a `Features/Utilities.lua` accessor resolved once at load that answers nil (or neutral) there, with a Diagnostics row. `ns.OnReadyCheck` calls its probes unguarded, so one error silences the whole report on that client.
- **Mists APIs that exist but throw** ("API unsupported"): `ns.GetNumTalentTabs` is gated on `ns.EXPANSION < 5`, and `ns.GetNumSpecGroups` tries `GetNumSpecGroups` before `GetNumTalentGroups`.
- **Comparing a secret value on Forever**: it errors. Test with `ns.IsPlain` / `ns.IsPlainTrue` / `ns.IsPlainYes` or `ns.IsSecretValue`, and ask `ns.AreAurasSecret()` (and the other `C_Secrets` wrappers) before reading. `ns.GetUnitByGUID` treats an unreadable GUID as no match.
- **Treating `NUM_BAG_SLOTS + 1` as the reagent bag**: on Era, TBC and Mists it is a bank bag. Use `ns.GetReagentBagID()` / `ns.CARRIED_BAG_IDS`.
- **The native `GetSpellLink` in chat**: on Classic the link lacks `:0` and the chat validator strips it. `ns.GetSpellLink` builds it by hand with `ns.SPELL_LINK_COLOR` lowercased; native is the fallback only when the name won't resolve.
- **Reading `IsInGroup` / `IsInRaid` to decide whether a feature acts**: a battleground's raid would read as Raid. Use `ns.GetGroupContext` / `ns.IsGroupContextOn`; only channel and unit-prefix plumbing reads them directly.
- **Testing a new file with `/reload`**: the client reads a TOC's file list only at startup. Restart the client. Shipped code relies on it too: a call from an existing file into one new this release is existence-tested (`ns.MoveRestockRemindersOntoSimple`, `ns.ArmRestockerReminders`, `ns.OnRestockerArrival`), so a player who updates mid-session and reloads doesn't error.
- **Whispering a pet's name**: it bounces as "No player named". Whisper paths gate on `ns.IsPlayerGUID`.

### Saved data and characters

- **Reordering `InitializeDatabase`**: `MigrateMessageLanguage` must read the raw table before the legacy import fills it and before AceDB copies defaults in (a value at its default is simply absent there); the stamp goes right after `AceDB:New` so a fresh install never runs it later. `ns.MoveGroupSettingsOntoCheckboxes` must precede any profile copy. `ns.RekeyCharactersByFullName` must precede `ns.MoveCharactersOntoOwnProfiles`, which finds entries by whole name. Callbacks last, so migration profile switches fire no `ns:ApplyProfile`.
- **The prune runs before the Connoisseur & Restocker repairs**: a key shape the prune reads as another client's is gone before any migration sees it. Forever's older `First - RuleSet` keys survive only through `IsOlderForeverKey`; a new migration reading another such key needs the same exemption.
- **Editing the prune's shape in `Core.lua`**: `Tests/Run.lua` lifts the source from `local REALM_KEY_SEPARATOR` to the end of `PruneOtherClientCharacters` and runs it with only `type`, `pairs`, `ipairs`, `GetRealmName`. Renaming either anchor, moving code out of that span, or calling another global inside it fails CI.
- **Reading a migrated key normally after `AceDB:New`**: AceDB has copied defaults in, so a default reads like a saved value. The group-context migration uses `rawget` / `rawset`; the reminder migration writes Simple rather than clearing, since a cleared key would read nil until the next login.
- **Indexing a default subtable at logout**: AceDB has already stripped empty defaults. Write whole values, as `ns.SaveRestockWindowGeometry` does.
- **Changing a shipped default**: AceDB stripped every value equal to the old default, so every player still on it moves to the new one.
- **Treating `scrollTypes`' defaults as fixed**: they are built per logged-in class at load (`DefaultScrollTypes`). Nothing may compare a saved value against them across characters.
- **Reusing a retired key's name**: whatever players saved under the old meaning reads straight back (`readinessReportEnabled` is a new key for this reason).
- **Mixing the two character keys**: AceDB profile names and `ns.GetCharacterKey()` differ in shape, and on Forever the profile name joins with a literal space while `ns.GetPlayerFullName` uses the client's surname separator. Go through the readers in `Features/Utilities.lua`.
- **Naming a character with `UnitName` alone**: on Forever that is the first name only. Use `ns.GetPlayerFullName` / `ns.GetCharacterKey` / `ns.GetCharacterProfileName`.
- **Putting a setting in the wrong scope**: the profile is one character's own. Add to global only for a concrete account-wide reason, written beside the key.
- **Two features declaring one default**: `AddDefaults` stops the load.
- **A remembered item miss outliving its answer**: the item is stranded for the session. Every answer reaches `ns.ForgetItemDataMiss` first, and anything parked on an item keeps its waiter keyed in (`ns.SyncRestockItemInfoSubscription`). A new waiter must release its key, or `GET_ITEM_INFO_RECEIVED` stays registered.
- **Warming an ID that can't answer**: `ns.WarmItemCache` skips cached, failed and nonexistent IDs; a new warmer that requests them could hold the event all session.

### Messages and data

- **A `|4` plural escape in a sent line**: `SendChatMessage` drops the whole line, and nothing on the send path resolves it. Run client duration strings through `ns.FormatDuration` (`Utilities.lua`).
- **Whispering a line built for group chat**: on Forever it loses the Star. A whisper is built by its own builder (`ns:BuildBuffAskWhisper`, not `ns:BuildBuffRequestMessage`).
- **`string.format` on an editable whisper's saved text**: a stray `%` breaks it. Tokens fill through `FillTokens` (gsub with a function, so values are literal).
- **Putting a whisper's default text in `Locales/`**: AceLocale loads only the client's locale, so another Send Messages In language would have no text. Defaults live in `Data.MESSAGE_LANGUAGES`; keep `"Opt Out"` English in every row, since Rank Watch listens for exactly those words (`OPT_OUT_WORDS`).
- **Saving a whisper text equal to the default**: `ns.SetMessageText` clears it to nil on purpose so it follows a later language change; `""` is kept and sends nothing.
- **Chat length in characters**: `ns.CHAT_MESSAGE_MAX_LENGTH` is bytes; non-Latin locales spend 2-3 per character.
- **Editing `POPUP_REPLACED_RELOAD` to change the after-import popup**: `ns.OfferLegacySteps` swaps `GOODTOGO_REPLACED_RELOAD`'s text to `POPUP_LEGACY_RELOAD_COPIED` at runtime.
- **Legacy popup Escape**: means "ask again next login", not decline (`noCancelOnEscape`).
- **Adding a Rank Sentinel folder name**: `ns.REPLACED_ADDONS`, `ns.LEGACY_ADDONS` (until 2026-12-08) and `Data.RANK_WATCH.STANDALONE_FOLDERS` must agree.
- **Editing one flavor folder's copy of a row**: the seven copies are separate. Check the ID in every folder.
- **Declaring `CLICK TFTBBuffIndividual:LeftButton` in `Bindings.xml`**: an older Thanks for the Buff declares it too and the client warns every login. A saved CLICK key needs no declaration; the alias answers it.

### Consumable Macros and Reports

- **Editing macros in combat**: silently blocked. Consumable Macros route through `ns.RequestUpdate()`; the write replays after combat.
- **Writing a macro while the Blizzard Macro UI is open**: its save-back reverts the write after the state key recorded it. `ns.UpdateMacros` defers while `MacroFrame` is shown; never write around that guard.
- **A body input missing from the state key**: the macro silently goes stale. Keys are lossless, override modes use disjoint prefixes.
- **Recording a state key when the write failed**: a full General tab blocks every retry. Keep `ns.WriteMacroBody`'s false return meaningful.
- **Passing a non-boolean `perCharacter` to `CreateMacro`**: the client boolean-checks it. Consumable macros omit it (General).
- **Changing a shipped macro name** (`MACRO_*`): it creates a second macro and strands the old one on every bar. Macros are found by name.
- **Setting `ranked` without `ns.MULTI_USE_MACRO_TYPES`, or the reverse**: the scanner reads one and the engine (and Message Length) the other. Set both, and only where every item shares one cooldown.
- **Moving a Consumable Macros handler below `OnEvent`'s combat guard**: it misses mid-fight changes and signatures drift. Below-guard baselines are kept honest only because every scan re-records them; a new baseline needs the same.
- **A new bag-reading override**: scroll, pet-buff, pet-food and poison selection bypass the scan's gates, so each checks the Ignore List and usability itself. A new one must too.
- **Holding the aura snapshot**: `ns.GetPlayerBuffSnapshot()` returns one shared buffer the next call overwrites. Take one per pass and pass it down. While auras are secret it returns the last readable snapshot; never reset it to empty, which reads as "no buffs".
- **Keeping or writing scan output**: `ns.scannedItemCounts`, `ns.scannedItemLinks`, `ns.scannedIgnoredTypes` and `ns.bestSelection` are wiped and refilled in place every scan. `ns.ScanPetFood` outside an update pass reads a stale snapshot.
- **A new cast trigger**: `UNIT_SPELLCAST_SUCCEEDED` registration is decided once at login by class and race (`InitializeConsumableMacros`). Change both `ns.SpellCastChangesMacros` and that registration.
- **Adding a `ns.BuildStandardBody` input without threading it through the trims**: each trim rebuilds by calling itself with one input dropped; a trim that forgets the new argument silently writes a body without it. Message Length's `LongestBodyFor` also calls it positionally (it passes no `leadCast` / `combatCast`).
- **Anything new that reads the target**: it must join `ns.TargetSignatureChanged` (friendly player, self, friendly level, cannibalizable), or its macro goes stale on a target change.
- **Gating a scroll on its required level**: deliberate that it doesn't. The level only sorts the list.
- **Iteration order in a pick**: `pairs()` order churns rewrites. `RANKING_PRIORITY`, the pet food pick and the poison lists all end on item ID.
- **Data row order meaning anything**: `Smart-Spell.lua` sorts `ns.CONJURE_SPELLS` and `Scanner-Auras.lua` sorts `ns.SCROLL_DATA` items in place at load; Diagnostics' `CONJURE_SPELLS.<list>[n]` indices are the sorted order.
- **Marking a non-flag-2 item conjured**: `isConjured` comes only from the food table's arena column value for conjured; zero-price or "Conjured Item" foods are ordinary on purpose.
- **Moving a burn-first step above `value`**: a zone-locked weak potion would beat a strong one. They are tiebreaks only, never bonuses.
- **Shuffling the TOC order**: `Scanner-Inventory.lua` captures `ns.ScanRanking` (Ranking, then Diagnostics adds to it) at load; `Engine.lua`, `Tools-Hunters.lua`, `Tools-Rogues.lua` capture `ns.MACRO_CONFIG`; `Readiness-Report.lua` captures `ns.GroupHasClass` / `ns.PartyHasClass` from Probes; the Example captures `ns.ReadinessClause` / `ns.ReadinessLine`; `Inventory-Report-Recording.lua` captures `ns.BankBagIDs` (`Restocker-Bags.lua`); `Macro-Notes.lua` captures `ns.KnowsAny`.
- **Message Length printing a real warning**: it builds through `ns.BuildStandardBody`, whose still-too-long `ns.WarnOnce` can fire in chat and spend that macro's once-per-session warning.
- **A table default under `readiness*`**: Readiness Reset would alias `ns.DATABASE_DEFAULTS`. Keep them scalar, and keep non-category keys off the prefix.
- **A Readiness probe that can throw**: `ns.OnReadyCheck` calls probes unguarded, so one error silences the whole report on that client. Put client gaps behind a `Features/Utilities.lua` accessor that answers nil.
- **An all-clear line in the Readiness Report**: silence is the feature.
- **Reading containers for the Inventory Report at logout**: Forever's containers can read empty at `PLAYER_LOGOUT`; only last-read snapshots are written.
- **Hooking the Inventory Report tooltip at load**: its block would land above other add-ons'. `TOOLTIP_HOOK_DELAY` is deliberate; items hovered in the first seconds show no block.
- **Treating the Inventory Report as its own module**: it rides the Restocker's dispatcher; a Restocker event change can affect it.

### Restocker

- **`UseContainerItem` while a merchant is open**: it sells. The bank run aborts on `ns.merchantIsOpen`, and the merchant code has no sell path.
- **`PutItemInBag` or `PutItemInBackpack` in the bank run**: both clear the cursor even when the server refuses, so "did it land" always reads yes. Name an empty slot (`BagDefinition:PutCursorItem`).
- **Clearing the cursor inside `PutCursorItem`**: the caller can no longer try the next bag. It leaves the item; the callers clear after the last attempt.
- **Leaving a split on the cursor**: the next split fails. Every failed placement and the tidy top-off end in `ClearCursor()`.
- **Trusting a container's free-slot count**: on Era and TBC the main bank reports slots the scan can't find. Placement keeps trying the next bag.
- **Deducting from a plan optimistically**: a move that didn't land goes unnoticed. The run rescans every step, and the watchdog stops it.
- **Counting only a fall in remaining work as progress**: on Forever the bank's contents arrive late and an overshoot adds stash work, so the run would stop as stuck. The watchdog counts any change.
- **Acting on a scan with a move in flight**: nothing is locked mid-transit, so the total dips and the run pulls a duplicate or finishes early. The in-flight gate waits `MAX_INFLIGHT_STEPS`.
- **Live-reading Keep during a bank run**: a half-typed number would move stock. Read `RestockState:Wanted`; Enter restarts the run.
- **Treating an emptied Keep box as 0**: 0 means keep none (store all with Store). An empty box saves nothing and restores on focus loss.
- **Reading a row control's item through `GetParent()`**: pooled rows rebind, so it points at another item. Every control carries `self.item`, rebound by `ns.UpdateRestockListRow`.
- **Treating a row as a table after `DeflateRestockItemsForSave`**: it is a string by then, which is why it runs last at logout.
- **Folding a default-on flag into `x and false or nil`**: it yields nil for every input, so the off state never saves (see `ItemFromString`).
- **Reading a nil flag with plain `not`**: `buyFromMerchant` and `upgrade` default on, `buyExtra`, `stashToBank`, `restockFromBank` off. `COLUMN_STATE` encodes each; `COLUMN_SET` writes explicit booleans.
- **Counting items by name**: an unresolved name reads as 0 and buys a full stack. Count by item ID.
- **Parking an add under a link**: the retry looks up by numeric item ID. Input with no ID is refused, or its key would hold `GET_ITEM_INFO_RECEIVED` all session.
- **Counting bank stock in the reagent order**: the add-on stashes the excess itself, so the reagents would never be bought. `ns.BuildCraftingPurchaseOrder` counts bags only.
- **Buying half a recipe**: vials without dust craft nothing. The reagent order is all-or-nothing per vendor; a sold-out limited slot counts as not stocked.
- **Counting buy calls, or bags right after sending**: two stacks is two calls, and bags update only on `BAG_UPDATE`. Orders count units; the report counts units delivered after `ns.AwaitMerchantRun`.
- **Buying at an open merchant through `ns.OnRestockerMerchantShow`**: its throttle and Shift check swallow a list switch. `ns.SwitchRestockList` resets the throttle and calls `ns.RestockFromMerchant`.
- **Switching lists from a delete**: `ns.SwitchRestockList` reruns the buy and bank run. Delete uses `ns.UseRestockList` and stops the bank run.
- **Re-reading `currentList` in the Delete confirm's OnAccept**: the window isn't locked behind it, so a switch redirects the delete. The name rides as the popup's data.
- **Writing `settings.currentList` directly**: the character's choice, New flags and group selection go stale. Use `ns.UseRestockList`.
- **Auto-joining an existing class-named list**: the new character's Staples ticks and upgrades write into someone else's list. `FreeClassListName` numbers; `IsListNameTaken` also counts dangling choices.
- **A `_CLOSED` event with no open**: loading screens fire them, sometimes twice. Close handlers key off `merchantIsOpen` / `bankIsOpen`.
- **Comparing reminders against `ns.BuildGroceryList`**: reminders and the mini-map read every short row (Buy off too) split by the threshold; the footer reads Buy rows. Pick the list that matches the surface.
- **A resting event during a load**: it would consume the transition the login is about to report. The town reminder does nothing until `PLAYER_ENTERING_WORLD` arms it, and a `/reload` arms silently.
- **Printing a Verbose reminder with cold links**: a "Loading item" chat link never updates. Login requests the list's items and waits `LOGIN_SETTLE_DELAY`.
- **Closing pooled-row menus late**: a pick lands on a rebound row. `ns.UpdateRestockList` closes them first; the reputation menu's callback is also pinned to its item.
- **Releasing a reused pullout on close, or one per open**: an Execute item closes its pullout from inside its own OnClick, freeing it mid-handler. Build once, `Clear()` at open; only the reputation menu (Toggle items) is created and released per open.
- **Using `UIDropDownMenu` in the window**: it taints shared frames. AceGUI pullouts only.
- **Escape with Staples open**: one press closes every `UISpecialFrames` window. Staples takes the Restock List off and hands it back a frame later, after `CloseSpecialWindows` finishes walking.
- **Anchoring a header or footer control to the window**: it lands mid-window behind the list. Parent to the header bar or footer row.
- **Re-reading a Staples row's `chainKey`**: it is replaced by `row.chain` at load.
- **Reading a ladder by row order or level**: tiers are sorted by rank (third field) at load in `Restocker-Upgrade.lua`; same-level tiers are settled by rank.
- **Keying item groups by name**: a translated New or Other can equal a client class name. Keys are classIDs and sentinels.
- **`string.lower` or `#` in the filter**: ASCII-only fold and byte length. `Fold` and `CharacterCount`.
- **A Restocker handler that skips `WhileEnabled`**: it runs with the feature off; only logout runs unwrapped. The Inventory Report rides the same dispatcher, so a Restocker event change can affect it.
- **Adding a manual bank-run trigger to Diagnostics**: that panel is read-only and the run moves items. Reopening the bank, Enter or a list switch restarts it.

### Buff Duty

- **Changing a Buff Duty button outside `ns.SetBuffButtonAttributes`, or in combat**: pooled buttons keep stale attributes, and protected changes are blocked.
- **Casting a buff by spell ID or bare name**: on Classic Era a lower rank's ID casts nothing, and a bare group-buff or resurrection name casts Rank 1. Cast by `BuffDuty.CastText`; only Create Soulstone goes by bare name (each tier its own spell, so a rank suffix names nothing).
- **Setting `type` or `type2` on a window button**: right-click would cast. Only `type1` is set, leaving right-click to dismiss a favor.
- **Registering a secure button for `AnyUp` only, or dropping the Buff Key's `useOnKeyDown` false**: dead for players who cast on key down, or a macro's lone up casts nothing.
- **Moving `ns.ExpectReplaceEnchant` to PostClick**: the secure click raises `REPLACE_ENCHANT` before PostClick runs, so the popup is never answered.
- **Closing Buff Duty through the template's close click**: it hides a protected parent. The button runs `ns.CloseBuffDuty`.
- **Gating Buff Duty's data on `ns.IsBuffDutyOnForClass`**: after a close the Buff Key would cast from stale auras. Events, backstop, aura handler and key follow `ns.IsBuffDutyTrackingForClass`; only the window's visibility follows OnForClass.
- **Leaving Buff Duty's target icons up past a target change, or after a failed redraw**: their buttons cast at whoever `target` now names, an NPC's buff on a player included. `ns.DropBuffDutyTargetIcons` strips them before the immediate `Refresh`, and `Refresh` hides the window when build or render errors.
- **Moving a targeted NPC's row up the Buff Key's order**: its cycle never empties, so the key would never reach the group.
- **Leaving a field out of `Signature`**: an otherwise unchanged list skips the redraw and the button keeps the old attributes or the hover menu the old names.
- **Shuffling the Buff Duty TOC order**: files capture earlier files' functions and tables at load (Load Order above). Key-Picker reads `BuffDuty.BuffKeySkipped` at call time because Keys loads after it.
- **Capturing `BuffDuty.soulstoneBuff`, `soulstoneEntry` or `resurrection` in a local**: each rebuild replaces the table, so the local goes stale. Read them off `BuffDuty`.
- **A list of possibly-nil sections in `ipairs`**: it stops at the first nil, dropping Return the Favor after an empty Target. `AddOutsiderSections` appends one by one.
- **Calling `BuffDuty.GroupMembers` expecting a fresh read during a redraw**: `HoldGroupMembers` hands back one read for the whole redraw. Hold only around one synchronous pass.
- **Giving a pet row its own `Has` verdict over a hold**: pet auras reach the client unreliably, so a seen-but-weaker version keeps its hold until it runs out; only `Has` agreeing clears it.
- **Rewriting `READS_COMBAT_LOG` in `Buff-Duty-Events.lua`**: `Tests/Run.lua` requires the literal `ns.FLAVOR ~= "Camelot"` in any Camelot-listed file naming `COMBAT_LOG_EVENT_UNFILTERED`; registering it on Forever raises `ADDON_ACTION_FORBIDDEN`.
- **Adding a combat-log consumer without widening `SyncCombatLog`**: the event is subscribed only while Return the Favor is on or a resurrection is known.
- **Changing `ReadWeaponEnchants`' return shape**: the Readiness Report (`Readiness-Report-Probes.lua`) and the context report read it.
- **Changing the window's group read, weapon fit or hold logic without the context report**: `Manifests-Buff-Duty.lua` re-implements `GroupUnits`, `PickFits` and the held-buff list for its lines.
- **Treating a ticked weapon choice for an unknown ID as junk**: Era and Season of Discovery share `weaponPicks`; one client's poison is the other's to keep.

### Rank Watch

- **A second `ns.SetRankWatchHandler` for an event**: it silently replaces the first. `Rank-Watch-Detection-Forever.lua` replaces Check's `PLAYER_REGEN_ENABLED` on purpose and so must schedule `ns.ProcessRankWatchQueue` itself; any new handler for a shared event must carry the old one's work.
- **Load order of detection files**: they capture `local Check = ns.CheckRankWatchCast` at file load, so they must load after `Rank-Watch-Check.lua`.
- **Rank Watch on Mists**: absent by TOC, not by empty data. A new outside caller must test that the function exists; Diagnostics append empty rows when `ns.RankWatchSettings` is missing.
- **Whispering the data's rank number**: TBC's sheet numbers a joined group's ranks through the whole group, so it can disagree with the reader's spellbook. Whispers wait for client rank text and are dropped otherwise; only prints fall back.
- **Changing the announced key or cluster messages**: the standalone Rank Sentinel shares `RANKSENTINEL`, `NOTIFY` keys and LEAD/JOIN; a different shape double-reports or breaks election. `COMM_RELEASE` is a value Rank Sentinel reads as its own dev build, so it never nags its users to update.
- **Saving a `NOTIFY` / `SYNC` key unchecked**: it persists in `announced` for good; only `ANNOUNCED_KEY_PATTERN` matches are kept.
- **A leader with Whisper off**: it doesn't claim, and `ns.RankWatchWhisperer` returns nil when it leads, so nobody in the group whispers. Deliberate: a silent copy must not hold the lead from a joiner who whispers.
- **`ns.GetUnitByGUID` also matches target/focus/mouseover**: a match is not group membership. Forever's `CheckAura` rejects those caster units, and `OnChatMsgWhisper` accepts only a `party` or `raid` unit, so a targeted non-member can't opt out.
- **Translating "Opt Out"**: the listener matches the English literal `OPT_OUT_WORDS`; every language's offer keeps it in English (`Data/Message-Languages.lua` header).
- **Recording every rank's tracked state explicitly**: freezes it against later data changes. `ns.SetRankWatchRankTracked` clears an entry that matches the data's `off` default.
- **Calling `ns.RankWatchSettings()` from a probe**: it writes (a migration). The Context report reads `global.rankWatch` directly, though it still calls `ns.IsRankWatchActive()`, which goes through the accessor.
- **Treating a pet cast's ceiling as the owner's**: a hunter pet can trail its hunter, so the pet's level is the ceiling and the `announced` key carries it; the owner's level only picks the grace period.
- **Composer order slots**: `Options-Rank-Watch.lua` reserves orders 11.1–11.49 (tip composer) and 17.4–17.69 (opt-out composer); a new control placed there interleaves with composer rows.
- **Adding an AceDB default for a whisper text key**: it would never read nil, so the text could not follow the Send Messages In language or be told apart from an edit.
- **Rerunning `Tools/Build-Rank-Watch-Abilities.py`**: merges onto the shipped tables, keeping every row and ability (off ladders, level-less rows, Forever's corrections) and their How We Got the Data block; adds a Rank Sentinel rank only when the flavor's own Trainer-Spells or Class-Spell-Lists knows the spell, and prints what it kept, added and left out. On unchanged sources it rewrites every file byte for byte (verified against `../Rank-Sentinel`). An unreadable existing row stops it.
- **Rerunning `Tools/Build-Rank-Watch-Pet-Abilities.py`**: rebuilds Vanilla, Discovery and TBC whole from `Pet-Abilities-{Game}.lua` and rewrites Mists/Wrath/Mainline empties, replacing each file's hand-set How We Got the Data block (Last Validated, Vanilla's wago.tools links) with its "Never"/"None" template; any hand edit to those tables is lost. Camelot is untouched without `--wago`. Restore the footers after a run.

### Enhanced Spellbook

- **Localizing `ns.IsOptionOn`, `ns.UseItemSlots`, `ns.WarnOnce` or `ns.HandOverMacro` as file locals in the Spellbook**: breaks Message Length, which swaps those `ns` fields for one pcall'd `CollectMacros`. Call them through `ns`.
- **Capturing an `ns` function as a file local before its file loads**: several files capture `ns.X` at load (`Spellbook-Events.lua` takes `ns.RefreshSpellbookPage`, `ns.spellbookPages`), so the TOC order is load-bearing. Keep a new provider ahead of its consumers in every TOC.
- **Editing a Conditionals row or Cast Sequence step in place**: Duplicates share rows (`ns.DuplicateMacro` copies one level only). Setters copy (`CopyRows`, `CopySteps`) and store fresh tables.
- **Holding an `ns.macros` entry across a change**: every refresh rebuilds them all. Re-find by `ns.SettingsKey` (panels) or `ns.MacroMenuRebuiltMacro` (menus).
- **Two `ns:On<Event>` methods with one name**: the later file silently wins, since handlers resolve by name on the shared `ns`. The Spellbook prefixes its pet, level, target, bag and skill handlers (`OnSpellbookUnitPet`) because `ns.OnUnitPet` belongs to Feed Pet.
- **Deleting by tag alone**: a player's own `#end` line looks like a tag. Delete requires a handed-out tag and an ownership record.
- **Reading a bar macro through `GetActionInfo`**: a macro showing a spell returns the spell ID. Use `GetActionText` (`ns.ActionMacroName`); `ns.ActionMacroTag` reads by index where possible, since stored names are cut short and two macros can share one.
- **Matching stances or forms by tooltip text**: some locales name forms apart from their spells. Use the class lists' IDs (`StanceSlot`, `RequiredForms`).
- **Keying a spell's settings by its lowest known rank**: on Forever a replaced Rank 1 is in neither the known nor unknown list, so the key would move and settings vanish. `ReadSpellbook` records `baseID` before that filter; `BaseSpellID` prefers it.
- **Reading another class's `CLASS_SPELL_LISTS` or `TRAINER_SPELLS`**: `Class-Config.lua` empties them at load.
- **Turning the Spellbook off**: `RefreshMacros` no-ops for every caller, so macros freeze as written. Deliberate.
- **Right-Click For (`groupVersion`) with a Conditionals `rightClick` row**: the two block each other. `MacroMenuMakeDefault` keeps it off per macro (`keepOff`); the category menu's Grouped skips those macros.
- **Storing a kind default as nil**: AceDB would merge the shipped default back. `ns.SetKindDefault` stores true/false.
- **Writing a macro while the Macro UI is open**: the Blizzard Macro UI saves its edit box back over the selected macro on selection change and hide, reverting the rewrite. Every sync no-ops while `MacroFrame` is shown; the `OnHide` hook catches up.
- **Measuring a body before its tag exists**: the tag can widen past `TAG_WIDTH`. `UNASSIGNED_TAG` reserves the length, and `ns.PickupMacro` re-checks `Fits` after `AssignMacroTag`.
- **Reading `UnitLevel("player")` inside `PLAYER_LEVEL_UP`**: stale. `OnPlayerLevelUp` passes the event's level.
- **Treating a secret mouseover or unit as readable (Forever, combat)**: errors or wrong ranks. `HasMouseover` counts a secret identity as gone; `RankFor` falls back to the top rank.
- **Parenting a frame to a Blizzard panel**: it stays protected for good. Every launcher hangs off `UIParent` and is only anchored to the book.
- **Probing another add-on's frame in `Spellbook-Tabs.lua`**: anchoring may be restricted or values secret. `ScreenRect` guards with `IsAnchoringRestricted`, `pcall`, `ns.IsSecretValue`.
- **Looking up a slot spell by name**: ranks share a name. `ns.ConditionalPickOfSpell` goes by ID.

### Mini-map, Options and Diagnostics

- **Editing `Options/Options-Kit.lua` or `Features/Menu-Kit.lua` in place**: they are shared copies; CI checks the Options Kit byte for byte. Change the shared source and sync. Their comments are generic and partly not this add-on's (the Options Kit places `ns.FEATURES` in `Options-Utilities.lua`, it is in `Options-Feature-Switches.lua`; the Menu Kit names another add-on); leave them.
- **Two `Kit`s**: in `Minimap-Menu.lua`, `Kit` is `ns.MenuKit`; the options kit is reached as `ns.OptionsKit`. Elsewhere in `Options/`, `Kit` is the options kit.
- **Touching `ns.OptionsKit`, `ns.FEATURES` or `ns.FindFeature` at load in `Minimap-Menu.lua` or `Minimap-Button.lua`**: both load in the Features group, before the Options group; those are nil then. They are read at draw and click time.
- **Writing a setting without `ns.RefreshSettings`**: its other home (menu or panel) and the icon go stale. `ns.ToggleMacroSetting`, `ns.IgnoreItem` and `ns.ClearIgnoreList` notify only their own panels; the menu's `AfterChange` covers the rest.
- **Setting `block = true` without writing a block**: the feature vanishes from the menu, since `block` only removes it from More Features.
- **Reordering `ns.FEATURES` alone**: the settings tree follows the hand-written `Kit.RegisterPanel` order in `ns.RegisterOptionsPanels`, so the two drift. Rank Watch's `table.insert` index is a literal too.
- **Giving a menu row a seventh click**: all six button clicks are taken; a row without one uses `ToggleRow`. Removing a Left-Click entry from `CLICKS` makes Left-Click open the menu instead.
- **Reading Buff Duty's menu status from the global switch**: the menu reads `ns.IsBuffDutyOnForClass`, which includes a close for this session; the same click turns it back on.
- **Giving an item or value row an `onClick` or a heading kind**: they are `action` rows without a click on purpose, so the Menu Kit adds no heading gap above them.
- **Using `ns.WarmItemCache` in an options panel, or `Kit.WarmItems` in a window**: panels poll by registry name and repaint through `NotifyChange`; windows hold a `GET_ITEM_INFO_RECEIVED` waiter and remember failed IDs (`failedItemIDs`, `Features/Item-Info.lua`).
- **Loading a `Manifests-*.lua` after `Report-Runner.lua`, or appending data sources at runtime**: the Data tab's reports are built from `ns.DIAGNOSTIC_DATA_SOURCES` once, at load; late rows get no report.
- **Two different data files sharing a manifest label**: `ns.AppendDiagnosticRows` merges them into one report. Only Game-IDs does it deliberately.
- **Fitting the mini-map icon with `SetButtonIcon`**: its `ResetButtonIcon` calls `icon:UpdateCoord()`, which errors when another add-on swapped the icon. `ns.RegisterMinimapIcon` sizes and masks it by hand.
- **Setting the button's texture directly**: displays redraw from the data object's `icon`; `ns.UpdateMinimapIcon` writes only that.
