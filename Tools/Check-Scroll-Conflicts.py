"""
Checks each flavor's Data/{Game}/Scrolls-{Game}.lua conflictSpells tables against wago.tools DB2 exports.

A scroll type is covered (ns.HasScrollBuff) while the player has the scroll's own buff, or a conflictSpells buff at
least as strong. Those lists were cross-checked by hand. This script lists every spell on a flavor's build that
raises the scroll's stat, sorts each one by where a player gets it, and diffs the list against the shipped table:

  - A stat buff is a SpellEffect row with Effect 6 (Apply Aura), 35 (Area Aura: Party) or 65 (Area Aura: Raid) and
    EffectAura 29 (Mod Stat) with EffectMiscValue_0 = 0 Strength, 1 Agility, 2 Stamina, 3 Intellect, 4 Spirit, or -1
    every stat (Mark of the Wild, Songflower Serenade). Protection is armor: EffectAura 22 (Mod Resistance) or 674 (the
    armor aura WoW Forever uses) with bit 1 (physical) set in EffectMiscValue_0. The amount is EffectBasePoints +
    EffectDieSides on builds that still export them (Era, Discovery, TBC), else EffectBasePointsF.
  - Its source is read from the client tables: ItemEffect (and ItemXItemEffect where ParentItemID is gone) for items
    that cast it on use, Item.InventoryType to tell gear (equippable) from consumables, SpellItemEnchantment for enchants,
    SpellClassOptions.SpellClassSet for class spells, SpellMisc Attributes_0 bit 0x40 for passives (talents, racials,
    item stats). A spell another spell triggers (Effect 64, or a periodic-trigger aura 23) takes its parent's source.
  - Nothing in the client says which buffs stack. Spell groups and stacking rules live on the server, so this script
    only proposes candidates; whether a candidate really blocks a scroll is a question for an in-game test. The
    CMaNGOS column says what that emulator's stacking code would do, from SpellClassSet and SpellCategories.DispelType,
    as a lead for which tests matter.

Each flavor's report has the candidates the table is missing (consumables and class buffs), listed entries whose
amount differs on this build, listed entries that no longer raise that stat (stale), and the filtered buckets
(passives, enchants and equip procs, gear on-use, pet auras, and spells with no player source: NPC, quest and world
buffs) folded away for review.

Run from the add-on root:

    python3 Tools/Check-Scroll-Conflicts.py --flavor Vanilla --flavor Camelot --report Tools/Scroll-Conflicts-Report.md
    python3 Tools/Check-Scroll-Conflicts.py --flavor all --report Tools/Scroll-Conflicts-Report.md
    python3 Tools/Check-Scroll-Conflicts.py --flavor TBC --build 2.5.6.70577 --lua

The build defaults to the newest one wago.tools lists for the flavor's product. CSVs are cached per build under
--cache (default: a folder in the system temp directory), so reruns don't download again. --lua prints each scroll
type's conflictSpells table as it would read with the missing consumables and class buffs added and amounts taken
from the build; it never writes the data files.
"""

import argparse
import csv
import json
import os
import re
import sys
import tempfile
import urllib.request

# Good to Go flavor folder -> wago.tools product.
PRODUCTS = {
    "Vanilla": "wow_classic_era",
    "Discovery": "wow_classic_era",
    "Camelot": "wowf",
    "TBC": "wow_anniversary",
    "Wrath": "wow_classic_titan",
    "Mists": "wow_classic",
    "Mainline": "wow",
}
FLAVOR_ORDER = ["Vanilla", "Discovery", "Camelot", "TBC", "Wrath", "Mists", "Mainline"]

# The Era client carries Season of Discovery's spells and items too. SoD's are numbered past these; Vanilla files
# such spells under their own bucket and ignores such items as a source, instead of calling them missing.
DISCOVERY_FIRST_SPELL = 400000
DISCOVERY_FIRST_ITEM = 200000
# WoW Forever's client grew from the same tree and still carries SoD's spells; its own new spells start past this.
# Camelot files spells between the two bounds under the SoD bucket too. Both bounds are read off the data, not
# published anywhere, so a spell near one is worth a look.
FOREVER_FIRST_SPELL = 1240000

STAT_INDEX = {"Strength": 0, "Agility": 1, "Stamina": 2, "Intellect": 3, "Spirit": 4}
ARMOR_TYPE = "Protection"
ALL_STATS = -1

AURA_EFFECTS = {"6", "35", "65"}
PET_AURA_EFFECT = "119"
MOD_STAT = "29"
ARMOR_AURAS = {"22", "674"}
TRIGGER_SPELL = "64"
PERIODIC_TRIGGER = "23"
PASSIVE = 0x40
ITEM_USE_TRIGGERS = {"0", "5"}
ITEM_EQUIP_TRIGGERS = {"1", "2"}
ENCHANT_SPELL_EFFECTS = {"1", "3"}
# An on-use item that can be equipped (Item.InventoryType set) is gear; any other is a consumable, whatever its
# Item.ClassID: Jujus and the Blasted Lands crystals are quest-class (12) items.
DEAD_ITEM = re.compile(r"^(Deprecated|Test|TEST|Monster - |\[PH\])")
SHORT_MS = 10 * 60 * 1000

CLASS_SETS = {
    3: "Mage", 4: "Warrior", 5: "Warlock", 6: "Priest", 7: "Druid", 8: "Rogue", 9: "Hunter", 10: "Paladin",
    11: "Shaman", 15: "Death Knight", 53: "Monk", 107: "Demon Hunter", 224: "Evoker",
}

# Bucket order in the report. "consumable" and "class" are the ones a player carries into the scroll decision.
KEEP = ["consumable", "class"]
FILTERED = {
    "discovery": "Season of Discovery spell IDs (carried by this client, not part of this flavor)",
    "untaught": "Class-family spells no trainer or class list teaches (NPC copies, procs, set bonuses)",
    "passive": "Passive auras (talents, racials, item stats, shapeshift passives)",
    "enchant": "Item enchants and equip/proc effects",
    "gear": "On-use gear (trinkets and the like)",
    "pet": "Pet auras",
    "other": "No player source in the client data (NPC, quest, world and GM buffs)",
}

# CMaNGOS (src/game/Spells/SpellStacking.cpp) decides same-stat stacking from two client fields: SpellClassSet 13
# (potion family: elixirs, flasks, Zanza) always stacks, and a scroll (family 0, DispelType 1 Magic) excludes any other
# Magic buff on the same stat, the stronger one winning. Armor clashes only family 0 with family 0. Two buffs are hard
# coded to stack with everything. Blizzard's servers are not CMaNGOS: on Era, Elixir of the Mongoose is confirmed to
# block Scroll of Agility (GitHub issue #3), which this rule says stacks. So the hint is a lead, never an answer.
POTION_FAMILY = 13
DISPEL_MAGIC = 1
CMANGOS_ALWAYS_STACK = {5320, 15366}  # Echeyakee's Grace, Songflower Serenade

FILTERED_CAP = 12

TABLES = [
    "SpellEffect", "SpellName", "SpellMisc", "SpellDuration", "SpellClassOptions", "SpellCategories",
    "SpellItemEnchantment",
    "ItemEffect", "ItemXItemEffect", "Item", "ItemSparse",
]

SCROLL_TYPE = re.compile(r"^\t([A-Za-z]+) = \{\s*$")
SCROLL_ITEM = re.compile(r"^\t\t\t\{ (\d+), (\d+), (\d+), (\d+)(?:, \"[A-Z]+\")? \}, -- (.+?)\s*$")
CONFLICT_ROW = re.compile(r"^\t\t\t\[(\d+)\] = (\d+), -- (.+?)\s*$")
TRAINER_ROW = re.compile(r"\bid = (\d+)\b")
CLASS_LIST_LINE = re.compile(r"^\t\t\t\{ ([\d, ]+) \}, --")


# --------------------------------------------------------------------------------------------------------------------
# wago.tools
# --------------------------------------------------------------------------------------------------------------------


def fetch(url, path):
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    request = urllib.request.Request(url, headers={"User-Agent": "Good-to-Go-Tools/1.0"})
    with urllib.request.urlopen(request, timeout=300) as response:
        data = response.read()
    with open(path + ".part", "wb") as handle:
        handle.write(data)
    os.replace(path + ".part", path)
    return path


def latest_build(product, cache):
    path = os.path.join(cache, "builds.json")
    if os.path.exists(path):
        os.remove(path)  # always fresh; it's small
    fetch("https://wago.tools/api/builds", path)
    with open(path, encoding="utf-8") as handle:
        builds = json.load(handle)
    if product not in builds or not builds[product]:
        sys.exit("wago.tools lists no builds for product %s" % product)
    return builds[product][0]["version"]


def load_table(name, build, cache):
    folder = os.path.join(cache, build)
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, name + ".csv")
    try:
        fetch("https://wago.tools/db2/%s/csv?build=%s" % (name, build), path)
    except Exception as error:  # a table a build doesn't have (ItemXItemEffect on Era) reads as empty
        print("  %s: not loaded (%s)" % (name, error), file=sys.stderr)
        return []
    with open(path, encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def as_int(value, default=0):
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default


# --------------------------------------------------------------------------------------------------------------------
# Build data
# --------------------------------------------------------------------------------------------------------------------


class Build:
    def __init__(self, build, cache):
        self.build = build
        tables = {name: load_table(name, build, cache) for name in TABLES}

        self.names = {as_int(r["ID"]): r.get("Name_lang", "") for r in tables["SpellName"]}

        durations = {as_int(r["ID"]): as_int(r.get("Duration")) for r in tables["SpellDuration"]}
        self.passive = set()
        self.duration = {}
        for row in tables["SpellMisc"]:
            if as_int(row.get("DifficultyID")) != 0:
                continue
            spell = as_int(row["SpellID"])
            if as_int(row.get("Attributes_0")) & PASSIVE:
                self.passive.add(spell)
            self.duration[spell] = durations.get(as_int(row.get("DurationIndex")), 0)

        self.class_set = {}
        for row in tables["SpellClassOptions"]:
            family = as_int(row.get("SpellClassSet"))
            if family:
                self.class_set[as_int(row["SpellID"])] = family

        self.dispel = {
            as_int(r["SpellID"]): as_int(r.get("DispelType"))
            for r in tables["SpellCategories"] if as_int(r.get("DifficultyID")) == 0
        }

        self.enchant = set()
        for row in tables["SpellItemEnchantment"]:
            for index in range(3):
                if row.get("Effect_%d" % index) in ENCHANT_SPELL_EFFECTS:
                    self.enchant.add(as_int(row.get("EffectArg_%d" % index)))
        self.enchant.discard(0)

        item_class = {as_int(r["ID"]): as_int(r.get("InventoryType")) for r in tables["Item"]}
        item_name = {as_int(r["ID"]): r.get("Display_lang", "") for r in tables["ItemSparse"]}
        effect_items = {}
        for row in tables["ItemXItemEffect"]:
            effect_items.setdefault(as_int(row["ItemEffectID"]), []).append(as_int(row["ItemID"]))
        # spell -> [(trigger type, item id, inventory type, item name)]
        self.items = {}
        for row in tables["ItemEffect"]:
            spell = as_int(row.get("SpellID"))
            if not spell:
                continue
            parents = [as_int(row["ParentItemID"])] if row.get("ParentItemID") else effect_items.get(as_int(row["ID"]), [])
            for item in parents:
                # an item ItemSparse doesn't name isn't in this client's game (SoD leftovers on Forever)
                if not item_name.get(item) or DEAD_ITEM.match(item_name[item]):
                    continue
                self.items.setdefault(spell, []).append(
                    (row.get("TriggerType", ""), item, item_class.get(item, ""), item_name.get(item, ""))
                )

        # stat buffs: spell -> {stat key: amount}; trigger parents: spell -> {parent}
        has_base_points = tables["SpellEffect"] and "EffectBasePoints" in tables["SpellEffect"][0]
        self.stats = {}
        self.scaled = set()
        self.children = {}
        self.targets = {}
        self.pet_only = set()
        self.parents = {}
        for row in tables["SpellEffect"]:
            if as_int(row.get("DifficultyID")) != 0:
                continue
            spell = as_int(row["SpellID"])
            effect, aura = row.get("Effect"), row.get("EffectAura")
            trigger = as_int(row.get("EffectTriggerSpell"))
            if trigger and (effect == TRIGGER_SPELL or (effect in AURA_EFFECTS and aura == PERIODIC_TRIGGER)):
                self.parents.setdefault(trigger, set()).add(spell)
                if effect == TRIGGER_SPELL:
                    self.children.setdefault(spell, set()).add(trigger)
            if effect not in AURA_EFFECTS and effect != PET_AURA_EFFECT:
                continue
            if has_base_points:
                amount = as_int(row.get("EffectBasePoints")) + as_int(row.get("EffectDieSides"))
            else:
                amount = round(float(row.get("EffectBasePointsF") or 0))
            misc = as_int(row.get("EffectMiscValue_0"))
            keys = []
            if aura == MOD_STAT:
                keys = [stat for stat, index in STAT_INDEX.items() if misc in (index, ALL_STATS)]
            elif aura in ARMOR_AURAS and misc & 1:
                keys = [ARMOR_TYPE]
            if not keys:
                continue
            if effect == PET_AURA_EFFECT:
                self.pet_only.add(spell)
            if float(row.get("Coefficient") or 0) > 0:  # Mists on: the amount scales with level (SpellScaling)
                self.scaled.add(spell)
            for key in keys:
                bucket = self.stats.setdefault(spell, {})
                bucket[key] = bucket.get(key, 0) + amount
            self.targets.setdefault(spell, set()).update(
                t for t in (row.get("ImplicitTarget_0"), row.get("ImplicitTarget_1")) if t and t != "0"
            )

    def item_sources(self, spell, depth=2):
        """Items that cast this spell, directly or through a parent that triggers it."""
        found = list(self.items.get(spell, []))
        if depth:
            for parent in self.parents.get(spell, ()):
                found += self.item_sources(parent, depth - 1)
        return found

    def classify(self, spell, flavor, taught):
        """(bucket, source text) for one stat buff. taught: spell IDs the flavor's trainer and class lists know."""
        if flavor == "Vanilla" and spell >= DISCOVERY_FIRST_SPELL:
            return "discovery", ""
        if flavor == "Camelot" and DISCOVERY_FIRST_SPELL <= spell < FOREVER_FIRST_SPELL:
            return "discovery", ""
        if spell in self.passive:
            return "passive", self.class_name(spell)
        if spell in self.enchant:
            return "enchant", "enchant"
        family = self.class_set.get(spell)
        if family in CLASS_SETS and (not taught or spell in taught):
            return "class", CLASS_SETS[family]
        items = self.item_sources(spell)
        if flavor == "Vanilla":
            items = [i for i in items if i[1] < DISCOVERY_FIRST_ITEM]
        used = [i for i in items if i[0] in ITEM_USE_TRIGGERS]
        consumables = [i for i in used if not i[2]]
        if consumables:
            return "consumable", describe_items(consumables)
        if used:
            return "gear", describe_items(used)
        if any(i[0] in ITEM_EQUIP_TRIGGERS for i in items):
            return "enchant", describe_items(items)
        if family in CLASS_SETS:
            return "untaught", CLASS_SETS[family]
        if spell in self.pet_only:
            return "pet", ""
        return "other", self.class_name(spell)

    def cmangos_hint(self, spell, scroll_type):
        """What CMaNGOS's stacking code would do with this buff and the scroll: "stacks" or "excl"."""
        family, dispel = self.class_set.get(spell, 0), self.dispel.get(spell, 0)
        if spell in CMANGOS_ALWAYS_STACK or family == POTION_FAMILY:
            return "stacks"
        if scroll_type == ARMOR_TYPE:
            return "excl" if family == 0 and dispel == DISPEL_MAGIC else "stacks"
        return "excl" if dispel == DISPEL_MAGIC else "stacks"

    def class_name(self, spell):
        return CLASS_SETS.get(self.class_set.get(spell), "")

    def target_text(self, spell):
        targets = self.targets.get(spell, set())
        if targets == {"1"}:
            return "self"
        if targets & {"20", "37", "56", "61", "45", "30"}:
            return "group"
        if targets & {"21", "25"}:
            return "friend"
        return ",".join(sorted(targets)) or "?"

    def duration_text(self, spell):
        ms = self.duration.get(spell, 0)
        if ms <= 0:
            return "∞" if ms < 0 else "-"
        minutes = ms // 60000
        if minutes >= 60 and minutes % 60 == 0:
            return "%dh" % (minutes // 60)
        return "%dm" % minutes if minutes else "%ds" % (ms // 1000)


def describe_items(items):
    seen = []
    for _, item, _, name in items:
        text = "%s (%d)" % (name or "item", item)
        if text not in seen:
            seen.append(text)
    return ", ".join(seen[:3]) + (" +%d" % (len(seen) - 3) if len(seen) > 3 else "")


# --------------------------------------------------------------------------------------------------------------------
# Shipped tables
# --------------------------------------------------------------------------------------------------------------------


def read_scrolls(path):
    """{type: {"items": [(item, buff, level, amount, name)], "conflicts": {spell: (amount, name)}}}"""
    data = {}
    current = section = None
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            header = SCROLL_TYPE.match(line)
            if header:
                current = header.group(1)
                data[current] = {"items": [], "conflicts": {}}
                continue
            if current is None:
                continue
            stripped = line.strip()
            if stripped.startswith("items = {"):
                section = "items"
            elif stripped.startswith("conflictSpells = {"):
                section = "conflicts"
            elif section == "items" and SCROLL_ITEM.match(line):
                m = SCROLL_ITEM.match(line)
                data[current]["items"].append(tuple(int(v) for v in m.groups()[:4]) + (m.group(5),))
            elif section == "conflicts" and CONFLICT_ROW.match(line):
                m = CONFLICT_ROW.match(line)
                data[current]["conflicts"][int(m.group(1))] = (int(m.group(2)), m.group(3))
            if line.startswith("}"):
                current = None
    return data


def read_taught_ids(root, flavor):
    """Spell IDs Trainer-Spells-{Game}.lua or Class-Spell-Lists-{Game}.lua know, i.e. spells a player can cast."""
    taught = set()
    path = os.path.join(root, "Data", flavor, "Trainer-Spells-%s.lua" % flavor)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as handle:
            taught |= {int(m) for m in TRAINER_ROW.findall(handle.read())}
    path = os.path.join(root, "Data", flavor, "Class-Spell-Lists-%s.lua" % flavor)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as handle:
            for line in handle:
                match = CLASS_LIST_LINE.match(line)
                if match:
                    taught |= {int(v) for v in re.findall(r"\d+", match.group(1))}
    return taught


# --------------------------------------------------------------------------------------------------------------------
# Diff and report
# --------------------------------------------------------------------------------------------------------------------


def check_flavor(flavor, build, data, scrolls, taught):
    """Per scroll type: candidates by bucket, missing, amount changes, stale."""
    result = {}
    scroll_buffs = {item[1] for entry in scrolls.values() for item in entry["items"]}
    for scroll_type, entry in scrolls.items():
        own = {item[1] for item in entry["items"]}
        top = max((item[3] for item in entry["items"]), default=0)
        buckets = {}
        for spell, stats in data.stats.items():
            amount = stats.get(scroll_type)
            if amount is None or spell in own or amount < 0 or (amount == 0 and spell not in data.scaled):
                continue
            bucket, source = data.classify(spell, flavor, taught)
            if spell in scroll_buffs:
                bucket, source = "other", "another scroll's buff"
            row = {
                "spell": spell, "name": data.names.get(spell, "?"), "amount": amount, "source": source,
                "target": data.target_text(spell), "duration": data.duration_text(spell),
                "short": 0 < data.duration.get(spell, 0) < SHORT_MS, "stats": stats,
                "scaled": spell in data.scaled, "cmangos": data.cmangos_hint(spell, scroll_type),
            }
            buckets.setdefault(bucket, []).append(row)
        for rows in buckets.values():
            rows.sort(key=lambda r: (-r["amount"], r["name"], r["spell"]))

        listed = entry["conflicts"]
        by_id = {row["spell"]: (bucket, row) for bucket, rows in buckets.items() for row in rows}
        # A listed spell whose stat sits on a spell it triggers (the Unstable Flasks, Bloodberry Elixir) covers that
        # child too; the child isn't missing, and the parent isn't stale.
        via = {}
        for spell in listed:
            if spell not in by_id:
                for child in sorted(data.children.get(spell, ())):
                    if child in by_id:
                        via[spell] = child
        covered = set(listed) | set(via.values())
        missing = [dict(row, bucket=bucket) for bucket in KEEP for row in buckets.get(bucket, [])
                   if row["spell"] not in covered]
        changed, stale, scaled, triggered = [], [], [], []
        for spell, (amount, name) in sorted(listed.items(), key=lambda kv: -kv[1][0]):
            if spell in via:
                child = by_id[via[spell]][1]
                triggered.append({"spell": spell, "name": name, "listed": amount, "child": child})
                continue
            if spell not in by_id:
                stats = data.stats.get(spell)
                why = "not in SpellName on this build" if spell not in data.names else (
                    "raises %s, not %s" % (", ".join(sorted(stats)), scroll_type) if stats else "no %s aura" % scroll_type
                )
                stale.append({"spell": spell, "name": name, "amount": amount, "why": why})
                continue
            bucket, row = by_id[spell]
            if row["scaled"]:
                scaled.append({"spell": spell, "name": name, "listed": amount, "build": row["amount"]})
            elif row["amount"] != amount:
                changed.append({"spell": spell, "name": name, "listed": amount, "build": row["amount"], "bucket": bucket})
        result[scroll_type] = {
            "buckets": buckets, "missing": missing, "changed": changed, "stale": stale, "listed": listed, "top": top,
            "scaled": scaled, "triggered": triggered,
        }
    return result


def amount_text(row):
    return "scaled (base %d)" % row["amount"] if row.get("scaled") else str(row["amount"])


def md_escape(text):
    return str(text).replace("|", "\\|")


def row_note(row, top, scroll_type):
    notes = []
    if row["amount"] < top:
        notes.append("weaker than best scroll (%d)" % top)
    if row["short"]:
        notes.append("short")
    others = sorted(k for k in row["stats"] if k != scroll_type)
    if others:
        notes.append("also " + ", ".join(others))
    return "; ".join(notes)


MISSING_GROUPS = [
    ("Consumables", lambda bucket, row: bucket == "consumable"),
    ("Class buffs cast on others", lambda bucket, row: bucket == "class" and row["target"] != "self"),
    ("Class self-buffs and auras", lambda bucket, row: bucket == "class" and row["target"] == "self"),
]


def by_spell(r):
    if "_by_spell" not in r:
        r["_by_spell"] = {row["spell"]: row for rows in r["buckets"].values() for row in rows}
    return r["_by_spell"]


def render(flavor, build, result, out, cap):
    product = PRODUCTS[flavor]
    out.append("## %s — %s %s\n" % (flavor, product, build))
    if not result:
        out.append("No scroll types in Data/%s/Scrolls-%s.lua; nothing to diff.\n" % (flavor, flavor))
        return
    out.append("| Scroll type | Listed | Missing | Amount differs | Stale | Scaled (unchecked) |")
    out.append("|---|---:|---:|---:|---:|---:|")
    for scroll_type, r in result.items():
        out.append("| %s | %d | %d | %d | %d | %d |" % (
            scroll_type, len(r["listed"]), len(r["missing"]), len(r["changed"]), len(r["stale"]), len(r["scaled"])))
    out.append("")
    for scroll_type, r in result.items():
        out.append("### %s (best scroll %d)\n" % (scroll_type, r["top"]))
        if r["missing"]:
            for title, test in MISSING_GROUPS:
                rows = [row for row in r["missing"] if test(row["bucket"], row)]
                if not rows:
                    continue
                out.append("Missing — %s:\n" % title.lower())
                out.append("| Spell | Name | Amount | Source | Target | Duration | CMaNGOS | Notes |")
                out.append("|---:|---|---:|---|---|---|---|---|")
                for row in rows:
                    out.append("| %d | %s | %s | %s | %s | %s | %s | %s |" % (
                        row["spell"], md_escape(row["name"]), amount_text(row), md_escape(row["source"]), row["target"],
                        row["duration"], row["cmangos"], md_escape(row_note(row, r["top"], scroll_type))))
                out.append("")
        else:
            out.append("Missing: none.\n")
        if r["changed"]:
            out.append("Amount differs on this build:\n")
            out.append("| Spell | Name | Listed | Build | Bucket |")
            out.append("|---:|---|---:|---:|---|")
            for row in r["changed"]:
                out.append("| %d | %s | %d | %d | %s |" % (
                    row["spell"], md_escape(row["name"]), row["listed"], row["build"], row["bucket"]))
            out.append("")
        stacking = [
            "%d %s" % (spell, name) for spell, (amount, name) in r["listed"].items()
            if spell in by_spell(r) and by_spell(r)[spell]["cmangos"] == "stacks"
        ]
        if stacking:
            out.append("Listed entries CMaNGOS's rule would let stack with the scroll: %s\n" % ", ".join(stacking))
        if r["triggered"]:
            out.append("Listed spells whose %s sits on a spell they trigger (which ID the player's aura carries is"
                       " unchecked):\n" % scroll_type)
            for row in r["triggered"]:
                out.append("- %d %s (listed %d) → %d %s (%s)" % (
                    row["spell"], row["name"], row["listed"], row["child"]["spell"], row["child"]["name"],
                    amount_text(row["child"])))
            out.append("")
        if r["scaled"]:
            out.append("Listed spells whose amount scales with level on this build (listed amount kept, not"
                       " compared): %s\n" % ", ".join("%d %s (listed %d, base %d)" % (
                           row["spell"], row["name"], row["listed"], row["build"]) for row in r["scaled"]))
        if r["stale"]:
            out.append("Stale — listed but not a %s buff on this build:\n" % scroll_type)
            out.append("| Spell | Name | Listed | Why |")
            out.append("|---:|---|---:|---|")
            for row in r["stale"]:
                out.append("| %d | %s | %d | %s |" % (row["spell"], md_escape(row["name"]), row["amount"], row["why"]))
            out.append("")
        listed_other = [
            (bucket, row) for bucket in FILTERED for row in r["buckets"].get(bucket, []) if row["spell"] in r["listed"]
        ]
        if listed_other:
            out.append("Listed entries the client data files under a filtered bucket (kept; check by hand):\n")
            for bucket, row in listed_other:
                out.append("- %d %s (%d) — %s%s" % (
                    row["spell"], row["name"], row["amount"], bucket, ", " + row["source"] if row["source"] else ""))
            out.append("")
        for bucket, label in FILTERED.items():
            rows = [row for row in r["buckets"].get(bucket, []) if row["spell"] not in r["listed"]]
            if not rows:
                continue
            out.append("<details><summary>Filtered: %s — %d</summary>\n" % (label, len(rows)))
            out.append("| Spell | Name | Amount | Source | Target | Duration |")
            out.append("|---:|---|---:|---|---|---|")
            for row in rows[:cap]:
                out.append("| %d | %s | %s | %s | %s | %s |" % (
                    row["spell"], md_escape(row["name"]), amount_text(row), md_escape(row["source"]), row["target"],
                    row["duration"]))
            if cap is not None and len(rows) > cap:
                out.append("\n…and %d more, strongest first above; --full lists them all." % (len(rows) - cap))
            out.append("\n</details>\n")


def render_lua(flavor, result, data):
    """The conflictSpells tables as they'd read with the missing rows added: class buffs first, then the rest."""
    lines = ["-- %s (%s)" % (flavor, data.build)]
    for scroll_type, r in result.items():
        rows = {}
        for spell, (amount, name) in r["listed"].items():
            build_amount = next(
                (row["amount"] for rows_ in r["buckets"].values() for row in rows_ if row["spell"] == spell), None)
            rows[spell] = (build_amount if build_amount is not None else amount, name,
                           data.class_set.get(spell) in CLASS_SETS and spell not in data.items)
        for row in r["missing"]:
            rows[row["spell"]] = (row["amount"], row["name"], row["bucket"] == "class")
        ordered = sorted(rows.items(), key=lambda kv: (not kv[1][2], -kv[1][0], kv[1][1], kv[0]))
        lines.append("\t%s = {" % scroll_type)
        lines.append("\t\tconflictSpells = {")
        for spell, (amount, name, _) in ordered:
            lines.append("\t\t\t[%d] = %d, -- %s" % (spell, amount, name))
        lines.append("\t\t},")
        lines.append("\t},")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--flavor", action="append", required=True,
                        help="Flavor folder (%s) or 'all'; repeat for several" % ", ".join(FLAVOR_ORDER))
    parser.add_argument("--build", help="wago.tools build, e.g. 1.15.9.70576 (only with a single flavor)")
    parser.add_argument("--root", default=".", help="Add-on root (default: current directory)")
    parser.add_argument("--cache", default=os.path.join(tempfile.gettempdir(), "good-to-go-wago"),
                        help="Folder for downloaded CSVs")
    parser.add_argument("--report", help="Write the markdown report here instead of stdout")
    parser.add_argument("--lua", action="store_true", help="Print suggested conflictSpells tables to stdout")
    parser.add_argument("--full", action="store_true",
                        help="List every row of the filtered buckets (default: the %d strongest)" % FILTERED_CAP)
    args = parser.parse_args()

    flavors = FLAVOR_ORDER if "all" in args.flavor else args.flavor
    for flavor in flavors:
        if flavor not in PRODUCTS:
            sys.exit("Unknown flavor %s" % flavor)
    if args.build and len(flavors) != 1:
        sys.exit("--build needs exactly one --flavor")
    os.makedirs(args.cache, exist_ok=True)

    out = []
    builds = {}
    for flavor in flavors:
        build = args.build or latest_build(PRODUCTS[flavor], args.cache)
        print("%s: %s %s" % (flavor, PRODUCTS[flavor], build), file=sys.stderr)
        if build not in builds:
            builds[build] = Build(build, args.cache)
        data = builds[build]
        scrolls = read_scrolls(os.path.join(args.root, "Data", flavor, "Scrolls-%s.lua" % flavor))
        result = check_flavor(flavor, build, data, scrolls, read_taught_ids(args.root, flavor))
        render(flavor, build, result, out, None if args.full else FILTERED_CAP)
        if args.lua and result:
            print(render_lua(flavor, result, data))
            print()

    text = "\n".join(out) + "\n"
    if args.report:
        with open(args.report, "w", encoding="utf-8") as handle:
            handle.write(text)
        print("Wrote %s" % args.report, file=sys.stderr)
    elif not args.lua:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
