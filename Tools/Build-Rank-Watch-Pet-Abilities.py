"""
Builds Data/{Game}/Rank-Watch-Pet-Abilities-{Game}.lua: the hunter pet and warlock demon ladders Rank Watch reports
to a pet's owner.

Read from each flavor's own Pet-Abilities-{Game}.lua, the tables the Enhanced Spellbook's Pet What's Next reads:
PET_ABILITIES (one row per rank, level the pet's) and DEMON_ABILITIES (one row per grimoire, level the warlock's,
which is the demon's: a demon is summoned at its warlock's level). Each row's trailing comment names it,
"Bite (Rank 3)", and the rows are grouped into ladders by that name.

Left out:
  - passive abilities (Great Stamina, the resistances), which are never cast;
  - an ability with one rank, which has nothing to compare.

DEMON_ABILITIES lists grimoires, so it lacks the rank a demon knows when first summoned (Firebolt Rank 1);
DEMON_STARTING_RANKS adds those, since an imp still casting Firebolt Rank 1 is the case most worth reporting.

WoW Forever (Camelot) has no Pet-Abilities table: its pets learn as they level, with no Beast Training or
grimoires, but still by rank. Its ladders come from the client's own DB2 tables on wago.tools instead, every
ranked spell on a pet skill line (SkillLineAbility), its rank from Spell's subtext and its level from
SpellLevels. Download these as CSV for WAGO_BUILD into one folder and pass it with --wago:

    https://wago.tools/db2/SkillLineAbility/csv?build=1.60.1.70450
    https://wago.tools/db2/SpellName/csv?build=1.60.1.70450
    https://wago.tools/db2/Spell/csv?build=1.60.1.70450
    https://wago.tools/db2/SpellLevels/csv?build=1.60.1.70450

Run from the add-on root:

    python3 Tools/Build-Rank-Watch-Pet-Abilities.py [--wago /path/to/csv/folder]

Without --wago, Camelot's file is left as it is. Flavors with no ranked pets (Mists) get an empty table.
"""

import csv
import os
import re
import sys

FLAVORS = ["Vanilla", "Discovery", "TBC"]
EMPTY_FLAVORS = ["Mists", "Wrath", "Mainline"]

WAGO_FLAVOR = "Camelot"
WAGO_BUILD = "1.60.1.70450"
WAGO_TABLES = ["SkillLineAbility", "SpellName", "Spell", "SpellLevels"]

# SkillLine IDs of the pet skill lines on WoW Forever, by the class whose pets learn them.
WARLOCK_SKILL_LINES = {188, 189, 204, 205, 206, 207, 2887}  # Imp, Felhunter, Voidwalker, Succubus, Infernal, Doomguard, Felguard
HUNTER_SKILL_LINES = {
    203, 208, 209, 210, 211, 212, 213, 214, 215, 217, 218, 236, 251, 270, 653, 654, 655, 656, 2897, 3015, 3016,
}  # each beast family's "Pet - " line, and Pet - Generic (270)

# Ranked spells on those lines that are not a pet's cast: Beast Training's old pet talents, the heal Devour
# Magic leaves, and Lava Breath, whose two "ranks" share one level and are two Core Hound versions, not a ladder.
WAGO_SKIP = {
    "Pet Aggression",
    "Pet Hardiness",
    "Pet Recovery",
    "Pet Resistance",
    "Devour Magic Effect",
    "Lava Breath",
}

DISCOVERY_GUARD = {
    "Vanilla": "if ns.IS_DISCOVERY then\n\treturn\nend\n\n",
    "Discovery": "if not ns.IS_DISCOVERY then\n\treturn\nend\n\n",
}

PASSIVE = {
    "Arcane Resistance",
    "Fire Resistance",
    "Frost Resistance",
    "Nature Resistance",
    "Shadow Resistance",
    "Great Stamina",
    "Natural Armor",
    "Cobra Reflexes",
}

# The rank each demon knows on summon, which no grimoire teaches: { id, rank, level, name }.
DEMON_STARTING_RANKS = [
    (3110, 1, 1, "Firebolt"),
    (3716, 1, 10, "Torment"),
    (7814, 1, 20, "Lash of Pain"),
    (19505, 1, 30, "Devour Magic"),
]

COMMENT = re.compile(r"\},\s*--\s*(.+?)\s*$")
NAME_RANK = re.compile(r"^(.+?) \(Rank (\d+)\)$")
LEVEL = re.compile(r"\blevel = (\d+)")
SPELL = re.compile(r"\bid = (\d+)")


def read_table(text, name):
    """{ name: { id: (rank, level) } } from one table, every row's id, level and comment."""
    start = text.find("ns.%s = {" % name)
    if start < 0:
        return {}
    end = text.find("\n}\n", start)
    body = text[start:end].split("\n")[1:]
    ladders, chunk = {}, []
    for line in body:
        chunk.append(line)
        match = COMMENT.search(line)
        if not match:
            continue
        entry, chunk = "\n".join(chunk), []
        label = match.group(1)
        named = NAME_RANK.match(label)
        if not named or "(Passive)" in label:
            continue
        ability, rank = named.group(1), int(named.group(2))
        if ability in PASSIVE:
            continue
        level, spell = LEVEL.search(entry), SPELL.search(entry)
        if not (level and spell):
            continue
        ladders.setdefault(ability, {}).setdefault(int(spell.group(1)), (rank, int(level.group(1))))
    return ladders


def build(flavor, root):
    path = os.path.join(root, "Data", flavor, "Pet-Abilities-%s.lua" % flavor)
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    hunter = read_table(text, "PET_ABILITIES")
    warlock = read_table(text, "DEMON_ABILITIES")
    if warlock:
        for spell, rank, level, ability in DEMON_STARTING_RANKS:
            if ability in warlock:
                warlock[ability].setdefault(spell, (rank, level))
    by_class = {}
    for class_token, ladders in (("HUNTER", hunter), ("WARLOCK", warlock)):
        kept = []
        for ability in sorted(ladders):
            rows = sorted(
                ({"id": spell, "rank": rank, "level": level} for spell, (rank, level) in ladders[ability].items()),
                key=lambda row: (row["level"], row["rank"]),
            )
            if len(rows) > 1:
                kept.append({"name": ability, "ranks": rows})
        if kept:
            by_class[class_token] = kept
    return by_class


def build_from_wago(folder):
    """The same { class: [ { name, ranks } ] } as build(), from the client's DB2 tables as wago.tools CSVs."""

    def rows(table):
        with open(os.path.join(folder, table + ".csv"), encoding="utf-8", newline="") as handle:
            return list(csv.DictReader(handle))

    names = {row["ID"]: row["Name_lang"] for row in rows("SpellName")}
    subtexts = {row["ID"]: row["NameSubtext_lang"] or "" for row in rows("Spell")}
    levels = {}
    for row in rows("SpellLevels"):
        levels.setdefault(row["SpellID"], int(row["SpellLevel"]))
    ladders = {"HUNTER": {}, "WARLOCK": {}}
    for row in rows("SkillLineAbility"):
        line, spell = int(row["SkillLine"]), row["Spell"]
        class_token = "WARLOCK" if line in WARLOCK_SKILL_LINES else "HUNTER" if line in HUNTER_SKILL_LINES else None
        rank = re.match(r"Rank (\d+)$", subtexts.get(spell, ""))
        ability = names.get(spell)
        if not class_token or not rank or not ability or ability in PASSIVE or ability in WAGO_SKIP:
            continue
        level = levels.get(spell)
        if level is None:
            continue
        ladders[class_token].setdefault(ability, {})[int(spell)] = (int(rank.group(1)), level)
    by_class = {}
    for class_token, abilities in ladders.items():
        kept = []
        for ability in sorted(abilities):
            ranks = sorted(
                ({"id": spell, "rank": rank, "level": level} for spell, (rank, level) in abilities[ability].items()),
                key=lambda row: (row["level"], row["rank"]),
            )
            if len(ranks) > 1:
                kept.append({"name": ability, "ranks": ranks})
        if kept:
            by_class[class_token] = kept
    return by_class


def write(flavor, by_class, root, notes=None):
    path = os.path.join(root, "Data", flavor, "Rank-Watch-Pet-Abilities-%s.lua" % flavor)
    out = ["local _, ns = ...\n\n", DISCOVERY_GUARD.get(flavor, "")]
    out.append("-- [ownerClassToken] = { { { id, rank, level }, ... }, ... }, -- each pet ability's ranks, lowest first\n")
    if not by_class:
        out.append("ns.RANK_WATCH_PET_ABILITIES = {}\n")
    else:
        out.append("ns.RANK_WATCH_PET_ABILITIES = {\n")
        for class_token in ("HUNTER", "WARLOCK"):
            abilities = by_class.get(class_token)
            if not abilities:
                continue
            out.append("\t%s = {\n" % class_token)
            for ability in abilities:
                out.append("\t\t{\n")
                for row in ability["ranks"]:
                    out.append("\t\t\t{ id = %d, rank = %d, level = %d },\n" % (row["id"], row["rank"], row["level"]))
                out.append("\t\t}, -- %s\n" % ability["name"])
            out.append("\t},\n")
        out.append("}\n")
    out.append(notes or HOW_WE_GOT_THE_DATA[bool(by_class)].format(flavor=flavor))
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("".join(out))
    return path


HOW_WE_GOT_THE_DATA = {
    True: """
--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Built by Tools/Build-Rank-Watch-Pet-Abilities.py from Pet-Abilities-{flavor}.lua: PET_ABILITIES under HUNTER, DEMON_ABILITIES under WARLOCK, grouped by each row's comment.
	- level is the pet's level: a hunter pet's own, and for a demon its warlock's, which a demon is summoned at.
	- Passive abilities and abilities with one rank are left out. Each demon's summon-time rank (Firebolt Rank 1, Torment Rank 1, Lash of Pain Rank 1, Devour Magic Rank 1) is added, since no grimoire teaches it.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
""",
    False: """
--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Empty: this flavor's pets learn their abilities as they level, with no ranks to train, or no TOC lists this folder.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
""",
}


WAGO_NOTES = """
--[[
How We Got the Data

Last Validated
	2026-11-08, from wago.tools build {build}

Notes
	- Built by Tools/Build-Rank-Watch-Pet-Abilities.py --wago from the client's own DB2 tables: every ranked spell on a pet skill line in SkillLineAbility (each beast family's "Pet - " line and Pet - Generic under HUNTER, the Imp, Felhunter, Voidwalker, Succubus, Infernal, Doomguard and Felguard lines under WARLOCK), its rank from Spell's subtext and its level from SpellLevels.
	- WoW Forever's pets learn these as they level, with no Beast Training or grimoires; level is the pet's level, a demon's being its warlock's.
	- Passive abilities (the resistances, Great Stamina, Natural Armor), Beast Training's old pet talents, Devour Magic Effect, Lava Breath and abilities with one rank are left out. A rank this client lacks is dropped at login (Rank-Watch-Lookups.lua OnClient).

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
{links}

QuestieDB
	None.
]]
"""


def main():
    root = os.getcwd()
    if not os.path.isdir(os.path.join(root, "Data")):
        sys.exit("Run from the Good to Go add-on root.")
    if "--wago" in sys.argv:
        index = sys.argv.index("--wago")
        if index + 1 >= len(sys.argv):
            sys.exit("--wago needs the folder holding the CSVs.")
        by_class = build_from_wago(sys.argv[index + 1])
        links = "\n".join("\thttps://wago.tools/db2/%s?build=%s" % (table, WAGO_BUILD) for table in WAGO_TABLES)
        notes = WAGO_NOTES.format(build=WAGO_BUILD, links=links)
        path = write(WAGO_FLAVOR, by_class, root, notes)
        for class_token, abilities in by_class.items():
            print("%s %s: %s" % (WAGO_FLAVOR, class_token, ", ".join(a["name"] for a in abilities)))
        print("  -> " + path)
    for flavor in FLAVORS:
        by_class = build(flavor, root)
        path = write(flavor, by_class, root)
        for class_token, abilities in by_class.items():
            print("%s %s: %s" % (flavor, class_token, ", ".join(a["name"] for a in abilities)))
        print("  -> " + path)
    for flavor in EMPTY_FLAVORS:
        print("%s: empty -> %s" % (flavor, write(flavor, {}, root)))


if __name__ == "__main__":
    main()
