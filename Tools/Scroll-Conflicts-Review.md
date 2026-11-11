# Scroll conflictSpells vs wago.tools: review

What this covers: whether wago.tools DB2 data can fill each scroll type's `conflictSpells` in
`Data/{Game}/Scrolls-{Game}.lua`, what the first run found per flavor, and which stacking questions only an
in-game test can answer. No data file has been edited.

- Script: [Check-Scroll-Conflicts.py](Check-Scroll-Conflicts.py)
- Generated per-flavor diff: [Scroll-Conflicts-Report.md](Scroll-Conflicts-Report.md). Run on 2026-11-11 against Era
  1.15.9.70576 (Vanilla and Discovery), WoW Forever 1.60.1.70888, TBC Anniversary 2.5.6.70577, Titan 3.80.2.70522,
  Mists 5.5.4.70631 and Mainline 12.1.5.70783.

## Short version

1. **The client data can list candidates, but it can't say what stacks.** No DB2 table records buff exclusivity:
   no spell groups, no stacking rules. The server decides. The script can list every spell that raises a stat and
   say where a player gets it. Whether a candidate blocks a scroll still takes an in-game test.
2. **The current tables check out against their builds.** On Vanilla, Discovery, Camelot and TBC, every listed
   amount matches the build and nothing is stale. Mists amounts scale with level and can't be checked from DB2
   alone (see Mists below).
3. **The gaps are whole families of buffs, not missed elixirs.** These are never listed anywhere: Mark/Gift of the
   Wild, food and drink, potions, the five "Permanent" Blasted Lands buffs, Gift of Friendship and similar holiday
   buffs, and world buffs. Each family needs one stacking answer. After that, the fill is mechanical.

## 1. Which tables carry what

| Need | Table.field | Notes |
|---|---|---|
| Stat buff | `SpellEffect`: `Effect` 6/35/65 (aura, party aura, raid aura), `EffectAura` 29 (Mod Stat), `EffectMiscValue_0` 0 Str, 1 Agi, 2 Sta, 3 Int, 4 Spi, −1 all | Mark of the Wild and Songflower use −1 |
| Armor (Protection) | `SpellEffect`: `EffectAura` 22 (Mod Resistance) with bit 1 in `EffectMiscValue_0`; on WoW Forever, aura **674** instead | Forever moved every armor buff to 674 and kept 22 for spell resistances |
| Amount | `EffectBasePoints + EffectDieSides` (Era, TBC, Mists); `EffectBasePointsF` (Forever, which dropped the int columns) | Mists: `Coefficient` > 0 means the amount scales with level through SpellScaling. The base isn't the tooltip. |
| Name | `SpellName.Name_lang` | |
| From an item | `ItemEffect.SpellID` + `TriggerType` (0/5 on use, 1 equip, 2 proc), `ParentItemID`; Forever: `ItemXItemEffect` | `Item.InventoryType` ≠ 0 means gear. `Item.ClassID` doesn't work: Jujus and the Blasted Lands crystals are quest-class (12) |
| Class spell | `SpellClassOptions.SpellClassSet` (3 Mage … 11 Shaman; **13 = potions/elixirs**) | Cross-checked against the repo's own Trainer-Spells / Class-Spell-Lists so NPC copies drop out |
| Passive (talent, racial, item stat) | `SpellMisc.Attributes_0 & 0x40` | |
| Enchant | `SpellItemEnchantment.EffectArg_n` where `Effect_n` is 1 or 3 | |
| Triggered buffs | `SpellEffect.EffectTriggerSpell` with `Effect` 64 | The Unstable Flasks and Bloodberry Elixir keep their stat on a child spell |
| Duration | `SpellMisc.DurationIndex` → `SpellDuration.Duration` | |

**Exclusivity, checked and not found:** `SpellCategories.Category` is a cooldown category (0 for every scroll).
`SpellAuraOptions.CumulativeAura` only limits stacks of one spell. `SpellAuraRestrictions` is empty for all of
these. The only client fields that bear on stacking are the ones an emulator reasons from:
`SpellClassOptions.SpellClassSet` and `SpellCategories.DispelType`. The script reads both and shows a **CMaNGOS**
column. It's a lead, not an answer, for the reason below.

### What the emulators do (and why that isn't enough)

- **CMaNGOS** (classic and tbc): the rule lives in code,
  [SpellStacking.cpp](https://github.com/cmangos/mangos-classic/blob/6ec7482732db96ee669bae2ff4e3dbc9a1f4cc58/src/game/Spells/SpellStacking.cpp#L252-L286).
  For two buffs on the same stat:
  - A family-13 (potion) spell always stacks: elixirs, flasks, Zanza.
  - A scroll (family 0, Magic) excludes any other Magic buff, and the stronger one wins: class buffs, Jujus, other
    scrolls.
  - Armor only clashes family 0 with family 0.
  - Songflower Serenade and Echeyakee's Grace are hard-coded to stack.
- **TrinityCore 3.3.5** reads it from data, in the
  [spell_group SQL](https://github.com/TrinityCore/TrinityCore/blob/3.3.5/sql/old/3.3.5a/TDB53_to_TDB54_updates/world/2014_06_15_02_world_spell_group.sql#L471-L535):
  - Each scroll chain shares an EXCLUSIVE_HIGHEST group with its class buff (Fortitude, Arcane Intellect, Divine
    Spirit).
  - Scrolls are in neither the Battle nor the Guardian elixir group.
  - Group 1087 puts every scroll in one group with Mark of the Wild. That matters if Wrath ever gets scroll data.
- **Blizzard's servers are neither.** On Era, Elixir of the Mongoose is confirmed to block Scroll of Agility
  (GitHub issue #3, and a player-tested
  [forum report](https://us.forums.blizzard.com/en/wow/t/am-i-remembering-wrong/1648868)). CMaNGOS says those two
  stack. So the "same stat, stronger wins" rule the tables use now fits Era better than CMaNGOS does, but it's
  confirmed for one pair only.

## 2. Findings per flavor

Counts are from the generated report: *Missing* = consumables and taught class spells that raise the stat and
aren't listed. Spells the script set aside are in folded tables there: passives, enchants, gear, pet auras, SoD
IDs, untaught class copies, and spells with no player source.

### Vanilla (Era 1.15.9.70576)

The listed amounts all match the build, and nothing is stale.

Missing, grouped by what to do with them:

- **Decide as a family (in-game test):**
  - **Mark/Gift of the Wild**: +12 all stats and 285 armor at top rank (9885, 21850, and lower ranks).
    - Stats: below every top scroll, so listing it only hides the lower scroll ranks.
    - Protection: 285 armor beats Scroll of Protection IV (240), so listing it would hide Protection IV whenever the
      player has MotW. That is the case that matters most.
  - **Gift of Friendship** (27664–27671): +30 to one stat for 1h, Love is in the Air. Stronger than every scroll.
  - **Permanent Blasted Lands buffs**: Ground Scorpok Assay 30173, Cerebral Cortex Compound 30175, Lung Juice
    Cocktail 30164, Gizzard Gum 30177, R.O.I.D.S. 30178. The file already lists Permanent Spirit of Zanza (30336),
    and whatever reason put it there applies to these five too. Add all five or drop 30336.
  - **Food and drink**: Well Fed tiers, Rumsey Rum, Kreeg's Stout Beatdown, Gordok Green Grog, Alterac Spring Water,
    Blessed Sunfruit and the like. They're all at or below the top scroll, so they would only hide lower ranks.
  - **Potions**: Greater Stoneshield (+2000 armor, 2m), Lesser Stoneshield, Mighty Rage (+60 Str, 20s), Fervor.
    They're short. Listing one hides the scroll line for under two minutes if they conflict, and wrongly hides it if
    they stack. Recommend leaving potions out either way.
- **Leave out (obviously not conflicts):**
  - Protection's class self-buffs: Inner Fire, Devotion Aura, Frost/Ice Armor, Demon Skin/Armor. The file's own
    notes already say Protection stacks with these, and CMaNGOS agrees.
  - Raptor Punch (+4 Int, 5m), Guile of the Raptor (+12 Agi): trivial.
- **Already listed, but not a spell a player casts:** these NPC copies of class buffs are on no trainer or class
  list. They're harmless to keep, and dropping them is fine too:
  - Arcane Intellect 16876, 13326 and 364161
  - Power Word: Fortitude 23947, 23948 and 13864
  - Divine Spirit 16875
- **Songflower Serenade** (15366, +15 all stats) has no item on Era, so the script files it as a world buff. CMaNGOS
  hard-codes it to stack. It needs a test, but it only matters for the lower scroll ranks.

### Discovery (same Era build)

Everything in Vanilla applies here too. SoD adds:

- **Warmed Rumsey with Cream** (460332): +30 Stamina and +100 Spirit, more than any scroll.
- SoD Well Fed buffs 1225778–1225780 (+25 Str/Agi, +10 Sta).
- Speak with the Dead? (426606, +1 all stats, Elixir of Coalesced Regret).
- Songflower Serenade now comes from an item too (Scroll of Overwhelming Power 228227), so it shows as a
  consumable.

### Camelot (WoW Forever 1.60.1.70888)

The listed amounts match, including the raised Fortitude ranks and the new Forever elixirs. Nothing is stale.

- **Not consistent with Vanilla:** Permanent Spirit of Zanza 30336 (+50 Sta/Spi) is listed in Vanilla but missing
  here.
- **New on Forever, worth a look:**
  - **Grounded** (1251692): +100 Intellect for 30m, from Charged Stone 251723. Far above any scroll.
  - **Elixir of Endless Intellect** (1327736): +2 Intellect for 1h. The amount is odd, so check the tooltip.
  - Mark of the Wild on Forever: +16 all stats and 385 armor, lasting **1h**. Forever also has two MotW IDs no
    class list knows, 1291335 and 1310503. Find out which ID players actually get.
- **Probably a stale ID:** Arcane Brilliance 23028 is listed, but Camelot's trainer and class lists don't know it.
  Check whether Forever renumbered it.
- The same families as Vanilla need a decision: MotW/GotW, Gift of Friendship, the Permanent buffs, food, potions.
- Forever's client still carries SoD's spells and items, such as Elixir of the Honey Badger 1213904. The script
  drops any item Forever's ItemSparse doesn't name, and files spell IDs from 400000 to 1240000 as SoD. That
  1240000 bound was read off the data. Forever's own IDs seen so far start at 1248xxx.

### TBC (Anniversary 2.5.6.70577)

The listed amounts match, and nothing is stale.

- **Unstable Flasks** (Bandit, Beast, Elder, Physician, Soldier, Sorcerer) and **Bloodberry Elixir** are missing.
  - Their stats sit on a triggered child spell: 40577–40588 and 45374.
  - Mists lists the parent IDs (40567 and so on), and the script counts a parent as covering its child.
  - Which of the two IDs shows on the player's aura is unchecked.
- **Permanent Spirit of Zanza** 30336 (+50) is missing. Spirit of Zanza 24382 is listed at +25, which is its
  amount on this build.
- **Food matters more here.** A lot of TBC Well Fed buffs give +20 Stamina or Spirit, which equals the top scroll's
  amount. If food were listed, it would hide Scroll of Stamina V. Food is very likely its own stacking category, so
  leave it out, or spot-check once.
- **Potions:** Insane Strength Potion (+120 Str), Potion of Heroes (+70), Ironshield (+2500 armor). Leave them out,
  as in Vanilla.

### Mists (5.5.4.70631)

- **79 listed amounts scale with level** (`Coefficient` > 0). The DB2 base points differ from what the file lists:
  for example Flask of Battle 92729 has base 450 and is listed as 300.
  - Checking these needs SpellScaling plus the gtSpellScaling game table, or the tooltip at level 90.
  - The script reports them as "scaled" and doesn't compare amounts.
- **Flask of Battle is a server-side pick, so the script can't trace it.** Item 65455 casts 92679, and the server
  then applies one of 92725, 92729, 92730 or 92731. No client row links them (they're named after the flask whose
  stat they copy), so the script files them as "no player source". The entries are right. This is a limit of
  reading only client data. (79638–79640 are named "Enhanced Strength/Agility/Intellect", which is just the aura
  name of Alchemist's Flask.)
- **Missing:**
  - Mists and Cataclysm food (Well Fed up to +300)
  - Cataclysm battle potions: Tol'vir Agility, Volcanic Power, Golem's Strength, Earthen Armor
  - Visions of Insanity (+500 all stats)
  - The Mists potions: Jade Serpent, Mogu Power, Virmen's Bite, Mountains
  - Juju Power and Juju Guile
  - Long tails of holiday and novelty buffs
  - Recommend the same family rules as above.

### Wrath, Mainline

The scroll tables are empty, so there's nothing to diff. The script still maps them, to `wow_classic_titan` and
`wow`, for when they get data.

## 3. In-game tests, most useful first

For each test, apply the other buff first and then use the scroll. If you get "A more powerful spell is already
active", or the scroll doesn't apply, they conflict. Also try it the other way round, because a weaker buff may be
silently overwritten.

| # | Flavor | Test | What it decides |
|---|---|---|---|
| 1 | Era | Spirit of Zanza + Scroll of Stamina IV, and + Scroll of Spirit IV | Zanza is listed at 50, so today it hides both scroll lines for 2h. CMaNGOS and TrinityCore both say they stack. If they do, we're hiding a usable scroll. |
| 2 | Era | Elixir of Giants (or Juju Power) + Scroll of Strength IV | Whether Mongoose-blocks-Agility generalises to every same-stat elixir and Juju. That's the basis of every consumable entry. |
| 3 | Era | Mark of the Wild (rank 7) + Scroll of Protection IV | MotW's armor beats Protection IV. Decides whether MotW/GotW goes into Protection. |
| 4 | Era | Mark of the Wild + Scroll of Agility I or II | Whether MotW's all-stat aura conflicts at all for stats. It only matters for low scrolls. |
| 5 | Era | Gift of Friendship (+30) + the matching scroll | Holiday buffs, all stronger than scrolls. |
| 6 | Era | Songflower Serenade + any scroll | World buffs. |
| 7 | Era | Well Fed (Heavy Kodo Stew) + Scroll of Stamina | Food as a family. |
| 8 | Era | Greater Stoneshield Potion + Scroll of Protection IV | Potions as a family (low stakes). |
| 9 | TBC | Unstable Flask of the Bandit: `/dump` the aura's spell ID, then use Scroll of Agility V | Which ID to list, and whether it blocks. |
| 10 | TBC | +20 Stamina Well Fed + Scroll of Stamina V | Food at equal strength. |
| 11 | Camelot | Grounded (Charged Stone) + Scroll of Intellect IV; read Elixir of Endless Intellect's tooltip | New Forever consumables. |
| 12 | Camelot | Which Mark of the Wild ID a druid's cast leaves: 9885, 1291335 or 1310503 | Which IDs to list if test 3 says MotW conflicts. |
| 13 | Mists | Tooltip amounts at 90 for the scaled list | Mists amounts. |

## 4. Proposed fill rules, once the tests are in

- **Keep:** item-use consumables and trainer-taught class buffs cast on others, at the build's amount. These are the
  script's `consumable` and `class` buckets, minus the families below that tests rule out.
- **Drop without a test:** passives, enchants and equip procs, on-use gear, pet auras, SoD IDs on Vanilla and
  Camelot, spells with no player source, Protection's class self-buffs, and potions under 2 minutes.
- **Decided by tests 1–8:** food and drink, MotW/GotW, holiday buffs, world buffs, the Permanent buffs.

A follow-up could turn these rules into keep/drop lists in the script. Then `--lua` would print paste-ready tables,
and the How We Got the Data notes could name the script and build. Today `--lua` prints the listed rows plus every
missing consumable and class buff, for hand pruning.

## 5. Rerunning

```bash
python3 Tools/Check-Scroll-Conflicts.py --flavor all --report Tools/Scroll-Conflicts-Report.md
```

```bash
python3 Tools/Check-Scroll-Conflicts.py --flavor Camelot --build 1.60.1.70888 --lua
```

The newest build per product comes from `https://wago.tools/api/builds`. CSVs are cached per build in the system
temp folder (`--cache` changes it). `--full` lists every row of the folded buckets.
