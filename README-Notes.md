# Good to Go // Notes

> Where Good to Go departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

## Exceptions

### Pet diet words in Locales

- **Departs from:** GAME NAMES, game names never enter `Locales/`.
- **Instead:** The six `DIET_*` values are the client's own diet words, which the Feed Pet macro matches against the pet's diets.
- **Why:** The client names a pet's diets only as words and has no ID lookup for them.

### Docked Spellbook panels titled by spell

- **Departs from:** ADD-ON NAMES, window titles shaped `Title // Full Name`.
- **Instead:** The panels docked beside the Spellbook window are titled with the spell they edit, as `Fireball // Conditionals`.
- **Why:** They are part of the Spellbook window, whose own title already names the add-on.

### Per-character records kept off the profile

- **Departs from:** SAVED VARIABLES → The Two Models, per-character state in `ns.db.profile`.
- **Instead:** Each character's chosen Restock List lives in `ns.db.global`, and the record of character macros the Spellbook made lives in AceDB's `char` scope, so Reset Profile leaves both alone.
- **Why:** A profile reset must not lose which list a character shops from, or forget macros the add-on made and must still be able to clean up.

### English beast names in the Pet What's Next? tooltip

- **Departs from:** GAME NAMES, code never shows a name from a data row.
- **Instead:** The hunter's Pet What's Next? tooltip names tameable beasts in English, from the data file, on every client.
- **Why:** The client has no creature-name-by-ID lookup on every flavor, and an English name is more useful than none.

### Other-client cleanup reaches account-wide records

- **Departs from:** SAVED VARIABLES → Other-Client Characters, use this code as written.
- **Instead:** The prune also drops other-client characters' Restock List choices, Inventory Report records and Currency Replenish records from `ns.db.global`, telling a realm-free record by its name's shape and, for one with no surname, by its realm.
- **Why:** Those records are keyed by character outside AceDB's `char` and `profileKeys`, so the stock prune leaves copied characters in the Restock List and the Inventory Report.

### Older Forever character keys kept until 2026-12-08

- **Departs from:** SAVED VARIABLES → Other-Client Characters, the prune carries no `MIGRATION` tag.
- **Instead:** A tagged branch in `IsOtherClientKey` keeps Forever keys shaped "First Name - Rule Set" from an older AceDB.
- **Why:** The Default-Profile migration reads those keys after the prune, and pruning them first would lose those characters' settings.

### Rank Watch's reset reaches its account-wide settings

- **Departs from:** SAVED VARIABLES → Reset, Reset Profile clears only the active profile.
- **Instead:** Resetting a profile also turns Rank Watch off and clears its Reported Ranks choices in `ns.db.global`.
- **Why:** Rank Watch's settings are shared by every character, and Reset Profile is the one place a player expects to put them back.

### Readiness Report Example shows several lines

- **Departs from:** OPTIONS PANEL → Example Lines, one sample line, never a title.
- **Instead:** The Readiness Report's Example shows up to three of its lines, and its title when no check is switched on.
- **Why:** The report's lines differ by check, so one line can't show what the chosen checks will print.

### Options command takes an ignore argument

- **Departs from:** OPTIONS PANEL → Slash Commands, the options command takes no arguments.
- **Instead:** `/gtg ignore Name` adds a player to Rank Watch's Ignored Players, and `/gtg` with anything else still opens the Options Interface.
- **Why:** Ignoring a player is reached from the add-on's one command rather than a second literal.

### Title Case capitalizes "on", "off" and "yet" outside prepositions

- **Departs from:** TONE AND COPY → English, Title Case's lowercase word list.
- **Instead:** Titles capitalize "on", "off" and "yet" wherever the word is not acting as a preposition or conjunction, as in "Turn On", "Options On" and "Not Yet Available".
- **Why:** Lowercased, a word that belongs to the verb reads as a typo in game.

### Buff Duty scroll choices kept per character

- **Departs from:** SAVED VARIABLES → The Two Models, a feature's settings live in one scope.
- **Instead:** Buff Duty's Scrolls choices, which scroll types it offers, live on the character's profile while its other settings are account-wide.
- **Why:** Which scrolls are worth offering differs from character to character, so each keeps its own choices.

### Buff Duty's window builds inside one error guard

- **Departs from:** COMPATIBILITY, wrap the risky call, never a block.
- **Instead:** Buff Duty builds its whole window inside one `xpcall`, so an error in any row reports itself and leaves the window empty until a redraw succeeds.
- **Why:** A half-built window of secure buttons could cast the wrong spell, and an empty one can't.

### Buff Duty icons are 20 points

- **Departs from:** SPACING SCALE, every size on 2, 4, 8, 16, 32, 64, 128.
- **Instead:** Buff Duty's icons are 20 points, its rows 24, and its icon grids step by 24.
- **Why:** The maintainer chose 20 by eye: 16 was too small, and 20 looked better than 24.

### Windows move from anywhere

- **Departs from:** WINDOWS, a window moves by its title bar only.
- **Instead:** Every window moves when dragged from anywhere on it, its headers and names included.
- **Why:** The maintainer prefers a window that moves wherever it is grabbed.

### Buff Duty's window settings live in its flyout

- **Departs from:** MINIMAP MENU → Two Homes for Every Setting, the options panel is complete.
- **Instead:** Buff Duty's Window Opacity and its choices to skip a buff food, scroll or elixir are set only in the Options flyout on its window.
- **Why:** They are about the window itself, so they are changed while looking at it.

### Escape leaves Buff Duty open

- **Departs from:** WINDOWS, the close button and Escape close it.
- **Instead:** Only Buff Duty's close button hides its window; Escape opens the game menu and leaves the window up.
- **Why:** The maintainer keeps the window up through Escape.

### Macros Window refusal reuses the Options combat line

- **Departs from:** OPTIONS PANEL → Combat Guard, its refusal line used nowhere else.
- **Instead:** The Macros Window button's refusal in combat prints the same line as the options command.
- **Why:** The maintainer keeps one combat refusal line for both.

### Fishing Lure and Poisons macros start off

- **Departs from:** DATA → Default-Settings.lua, a macro the add-on writes starts on.
- **Instead:** The Fishing Lure and Poisons macros start off, and a player ticks them on in Consumable Macros.
- **Why:** Most characters never fish, and Buff Duty already offers poisons.
