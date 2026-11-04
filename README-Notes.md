# Good to Go // Notes

> Where Good to Go departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

## Exceptions

### Feature switches on each add-on's heading page

- **Departs from:** OPTIONS PANEL → Main Page Layout, the root panel's Features and Key Bindings sections.
- **Instead:** Each merged add-on (Connoisseur, Restocker, Thanks for the Buff, Spellbook) has a heading page under the root that holds its own on/off switches, each key binding sits on the page of the feature it drives, and the root holds only the welcome and mini-map toggles and /Commands.
- **Why:** Good to Go is four add-ons in one, and the maintainer keeps each one's settings together under its own name.

### Buff Duty window title uses the Short Name

- **Departs from:** ADD-ON NAMES, window titles shaped `Title // Full Name`.
- **Instead:** The Buff Duty window is titled with the Short Name, as `Buff Duty // GtG`.
- **Why:** It is a small floating window whose title bar can't hold the Full Name beside its close button.

### Pet diet words in Locales

- **Departs from:** GAME NAMES, game names never enter `Locales/`.
- **Instead:** The six `DIET_*` values are the client's own diet words, which the Feed Pet macro matches against the pet's diets.
- **Why:** The client names a pet's diets only as words and has no ID lookup for them.

### Thank You Button whisper is unbranded

- **Departs from:** MESSAGES, sent messages shaped `{rtN} Message // Short Name`.
- **Instead:** The Thank You Button's whisper goes out as written, with no target marker and no Short Name sign-off.
- **Why:** The button sends the player's own thank-you, which should read as their words, not the add-on's.

### Docked Spell Book panels titled by spell

- **Departs from:** ADD-ON NAMES, window titles shaped `Title // Full Name`.
- **Instead:** The panels docked beside the Spell Book window are titled with the spell they edit, as `Fireball // Conditionals`.
- **Why:** They are part of the Spell Book window, whose own title already carries the Full Name.

### Per-character records kept off the profile

- **Departs from:** SAVED VARIABLES → The Two Models, per-character state in `ns.db.profile`.
- **Instead:** Each character's chosen Restock List lives in `ns.db.global`, and the record of character macros the Spellbook made lives in AceDB's `char` scope, so Reset Profile leaves both alone.
- **Why:** A profile reset must not lose which list a character shops from, or forget macros the add-on made and must still be able to clean up.

### English beast names in the Pet What's Next? tooltip

- **Departs from:** GAME NAMES, code never shows a name from a data row.
- **Instead:** The hunter's Pet What's Next? tooltip names tameable beasts in English, from the data file, on every client.
- **Why:** The client has no creature-name-by-ID lookup on every flavor, and an English name is more useful than none.
