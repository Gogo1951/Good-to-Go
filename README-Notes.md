# Good to Go // Notes

> Where Good to Go departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

## Exceptions

### Buff Duty window title uses the Short Name

- **Departs from:** ADD-ON NAMES, window titles shaped `Title // Full Name`.
- **Instead:** The Buff Duty window is titled with the Short Name, as `Buff Duty // GtG`.
- **Why:** It is a small floating window whose title bar can't hold the Full Name beside its close button.

### Pet diet words in Locales

- **Departs from:** GAME NAMES, game names never enter `Locales/`.
- **Instead:** The six `DIET_*` values are the client's own diet words, which the Feed Pet macro matches against the pet's diets.
- **Why:** The client names a pet's diets only as words and has no ID lookup for them.

### Docked Spellbook panels titled by spell

- **Departs from:** ADD-ON NAMES, window titles shaped `Title // Full Name`.
- **Instead:** The panels docked beside the Spellbook window are titled with the spell they edit, as `Fireball // Conditionals`.
- **Why:** They are part of the Spellbook window, whose own title already carries the Full Name.

### Per-character records kept off the profile

- **Departs from:** SAVED VARIABLES → The Two Models, per-character state in `ns.db.profile`.
- **Instead:** Each character's chosen Restock List lives in `ns.db.global`, and the record of character macros the Spellbook made lives in AceDB's `char` scope, so Reset Profile leaves both alone.
- **Why:** A profile reset must not lose which list a character shops from, or forget macros the add-on made and must still be able to clean up.

### Star marker shared with Thanks for the Buff

- **Departs from:** MESSAGES → Target Marker, two add-ons never collide.
- **Instead:** Messages sent to other players carry the Star, `{rt1}`, the same marker as Thanks for the Buff.
- **Why:** Buff Duty's buff asks came from Thanks for the Buff, and the same marker keeps them familiar to the players who receive them. Good to Go no longer sends thank-yous, so the two add-ons' messages never say the same thing.

### English beast names in the Pet What's Next? tooltip

- **Departs from:** GAME NAMES, code never shows a name from a data row.
- **Instead:** The hunter's Pet What's Next? tooltip names tameable beasts in English, from the data file, on every client.
- **Why:** The client has no creature-name-by-ID lookup on every flavor, and an English name is more useful than none.

### Options command takes an ignore argument

- **Departs from:** OPTIONS PANEL → Slash Commands, the options command takes no arguments.
- **Instead:** `/gtg ignore Name` adds a player to Rank Watch's Ignored Players, and `/gtg` with anything else still opens the Options Interface.
- **Why:** Ignoring a player is reached from the add-on's one command rather than a second literal.
