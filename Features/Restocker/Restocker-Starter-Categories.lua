local _, ns = ...

--[[
    The staples the Staples window can offer (ns.STARTER_LIST_CATEGORIES): one
    row per checkbox, with its section, ladder key, stack cap or choices, and
    who is offered it and who gets it pre-ticked. Read at load by
    Restocker-Starter-List.lua, which loads next.
]]

--------------------------------------------------------------------------------
-- Starter List Categories
--------------------------------------------------------------------------------

--[[
    What the staples pop-up can offer, one row per checkbox.
    Features/Restocker/Restocker-Starter-List.lua owns every decision made about
    these rows -- which ladder each resolves to, who is offered it, what a tick
    adds. This table only says what exists.

    One table serves every client because it holds no game IDs. `chainKey`
    names a ladder in ns.CONSUMABLE_UPGRADE_CHAINS, and the loaded flavor
    folder's own ladders supply the items; the feature file resolves the key
    at load and drops any row whose ladder that folder does not carry.
]]

--[[
    The popup asks for WHOLE STACKS, not raw counts, because stacks are the
    unit a bag slot thinks in. A stack is whatever the item itself stacks to,
    so no row below carries a size: the staples do not share one, and some
    differ by client. A Symbol of Divinity stacks to 5, a Symbol of Kings to
    100, and an Ankh to 5 on Classic Era but 10 on TBC.
    Features/Restocker/Restocker-Starter-List.lua reads the size off the item.

    A tick defaults to one stack -- or to defaultStacks, where one is the
    wrong opening offer -- and the dropdown beside it runs to a per-category
    cap: 18 for ammo, where a hunter genuinely fills an 18-slot quiver, and a
    tighter 4 everywhere else, where more stacks than that is just a heavier
    corpse run.

    countsItems turns the same dropdown into a plain count, which is what an
    item that never stacks needs: Soul Shards take a bag slot each, so the
    choice is how many slots to give them, and the dropdown says "20" rather
    than "20 Stacks". It is declared here rather than read off the item
    because the dropdown's labels are drawn before a cold item resolves.

    A category with an explicit choices list offers those counts INSTEAD of
    every number up to a cap. Soul Shards step in fours from 12 to 40 -- a
    soul bag's worth at each of the sizes a warlock actually carries -- which
    is the same question a forty-entry dropdown would ask, without the
    scrolling. maxStacks is the cap for the every-number kind and is what
    choices replaces, so a category sets one or the other, never both.

    A category with fixedAmount gets no dropdown at all: totems are tools
    you own one of.
]]
local FOOD_MAX_STACKS = 4
local AMMO_MAX_STACKS = 18
local POISON_MAX_STACKS = 4
local REAGENT_MAX_STACKS = 4
local SOUL_SHARD_CHOICES = { 12, 16, 20, 24, 28, 32, 36, 40 }
local SOUL_SHARD_DEFAULT = 20

--------------------------------------------------------------------------------
-- Ladder And Class Keys
--------------------------------------------------------------------------------

--[[
    Canonical diet numbering; the English keys are always present alongside
    the localized aliases.
]]
local PET_DIET_MAP = ns.PET_DIET_MAP

-- Canonical poison-group numbering.
local POISON_GROUP = ns.POISON_GROUPS

--[[
    Class sets. classes on a category is WHO IS OFFERED it (absent = every
    class); defaultFor is who gets it PRE-TICKED when the window opens. Mana
    classes get water ticked; the manaless still see the row, unticked -- a
    warrior can carry water for a druid friend, but nobody decides that for
    them. Death Knights exist on Wrath, Mists and Mainline clients, yet their
    entries need no expansion gate of their own: only the Wrath folder gives
    Corpse Dust a tier, and every other folder's empty ladder keeps the row
    from being offered.
]]
local AMMO_CLASSES = { HUNTER = true, WARRIOR = true, ROGUE = true }
local MANA_CLASSES =
	{ DRUID = true, HUNTER = true, MAGE = true, PALADIN = true, PRIEST = true, SHAMAN = true, WARLOCK = true }

--[[
    One entry per checkbox. section groups entries under the popup's
    headings.

    A row that stands for a kind of item -- a food, water, an ammo type --
    carries a label, and the food labels reuse the DIET_ keys so the popup
    names bread whatever the pet-food tooltips call it. Every other row has no
    label: it shows the client's own name for an item on its ladder, so it
    needs no translation and always reads as the item does in bags and at
    vendors. That item is the one a tick would add right now, or, for a row
    marked namesFirstTier, the ladder's first item -- the poison types, whose
    first item's name is the type's own ("Instant Poison").

    The order HERE is for the maintainer's eye -- grouped by section, then
    by class. Display order is the popup's to compute (SectionCategories in
    Features/Restocker/Restocker-Starter-Sections.lua): dropdown staples first, fixed-amount
    singles after, each run alphabetical by the name it shows.

    A category whose ladder went missing is dropped by
    Features/Restocker/Restocker-Starter-List.lua rather than crashing the popup
    open.
]]
ns.STARTER_LIST_CATEGORIES = {
	--[[
	    Food, everyone. Bread arrives ticked for all; meat ticked for hunters
	    (their pet eats it too).
	]]
	{
		key = "bread",
		section = "food",
		label = ns.L["DIET_BREAD"],
		chainKey = "food:" .. PET_DIET_MAP["Bread"],
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = "all",
	},
	{
		key = "cheese",
		section = "food",
		label = ns.L["DIET_CHEESE"],
		chainKey = "food:" .. PET_DIET_MAP["Cheese"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fish",
		section = "food",
		label = ns.L["DIET_FISH"],
		chainKey = "food:" .. PET_DIET_MAP["Fish"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fruit",
		section = "food",
		label = ns.L["DIET_FRUIT"],
		chainKey = "food:" .. PET_DIET_MAP["Fruit"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fungus",
		section = "food",
		label = ns.L["DIET_FUNGUS"],
		chainKey = "food:" .. PET_DIET_MAP["Fungus"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "meat",
		section = "food",
		label = ns.L["DIET_MEAT"],
		chainKey = "food:" .. PET_DIET_MAP["Meat"],
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = { HUNTER = true },
	},

	-- Water, everyone; pre-ticked for the classes that drink for mana.
	{
		key = "water",
		section = "water",
		label = ns.L["LABEL_WATER"],
		chainKey = "water",
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = MANA_CLASSES,
	},

	-- Ammo, launcher classes only.
	{
		key = "bullets",
		section = "ammo",
		label = ns.L["STARTER_POPUP_BULLETS"],
		chainKey = "bullet",
		maxStacks = AMMO_MAX_STACKS,
		classes = AMMO_CLASSES,
	},
	{
		key = "arrows",
		section = "ammo",
		label = ns.L["STARTER_POPUP_ARROWS"],
		chainKey = "arrow",
		maxStacks = AMMO_MAX_STACKS,
		classes = AMMO_CLASSES,
	},

	--[[
	    Poisons, their own headed section for rogues (alphabetical, like the
	    foods) -- the popup adds a note under its header that the ingredients
	    buy themselves. Availability does the level work: every ladder opens
	    at its spell's training level, so the section fills out as the rogue
	    earns each type -- and Anesthetic's all-TBC ladder simply never comes
	    up on Era. Atrophic, Numbing, Occult and Sebacious are Season of
	    Discovery's: only the Discovery folder has their ladders, so every
	    other client drops the rows.
	]]
	{
		key = "anesthetic",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.ANESTHETIC,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "atrophic",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.ATROPHIC,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "crippling",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.CRIPPLING,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "deadly",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.DEADLY,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "instant",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.INSTANT,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "mindnumbing",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.MIND_NUMBING,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "numbing",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.NUMBING,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "occult",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.OCCULT,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "sebacious",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.SEBACIOUS,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "wound",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.WOUND,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	--[[
	    Reagents & Tools. Hearthstone is offered to every class -- the worked
	    example that ANYTHING can go on the Restock List, not just the
	    consumables the add-on curates -- alongside each class's own entries.
	]]
	{
		key = "hearthstone",
		section = "reagents",
		chainKey = "reagent:hearthstone",
		fixedAmount = 1,
	},
	{
		key = "blindingpowder",
		section = "reagents",
		chainKey = "reagent:blinding-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "flashpowder",
		section = "reagents",
		chainKey = "reagent:flash-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { ROGUE = true },
	},
	-- A tool, not a consumable: you own one.
	{
		key = "thievestools",
		section = "reagents",
		chainKey = "reagent:thieves-tools",
		fixedAmount = 1,
		classes = { ROGUE = true },
	},

	{
		key = "corpsedust",
		section = "reagents",
		chainKey = "reagent:corpse-dust",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DEATHKNIGHT = true },
	},

	{
		key = "seeds",
		section = "reagents",
		chainKey = "reagent:seeds",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DRUID = true },
	},
	{
		key = "wilds",
		section = "reagents",
		chainKey = "reagent:wilds",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DRUID = true },
	},

	{
		key = "arcanepowder",
		section = "reagents",
		chainKey = "reagent:arcane-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},
	-- Light Feather serves the mage's Slow Fall and the priest's Levitate.
	{
		key = "lightfeather",
		section = "reagents",
		chainKey = "reagent:light-feather",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true, PRIEST = true },
	},
	{
		key = "teleportrunes",
		section = "reagents",
		chainKey = "reagent:rune-of-teleportation",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},
	{
		key = "portalrunes",
		section = "reagents",
		chainKey = "reagent:rune-of-portals",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},

	{
		key = "divinitysymbol",
		section = "reagents",
		chainKey = "reagent:symbol-of-divinity",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PALADIN = true },
	},
	{
		key = "kingssymbol",
		section = "reagents",
		chainKey = "reagent:symbol-of-kings",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PALADIN = true },
	},

	{
		key = "candles",
		section = "reagents",
		chainKey = "reagent:candles",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PRIEST = true },
	},

	{
		key = "ankh",
		section = "reagents",
		chainKey = "reagent:ankh",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	{
		key = "fishscales",
		section = "reagents",
		chainKey = "reagent:fish-scales",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	{
		key = "fishoil",
		section = "reagents",
		chainKey = "reagent:fish-oil",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	-- Totems are tools: one each, no dropdown.
	{
		key = "earthtotem",
		section = "reagents",
		chainKey = "reagent:earth-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "firetotem",
		section = "reagents",
		chainKey = "reagent:fire-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "watertotem",
		section = "reagents",
		chainKey = "reagent:water-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "airtotem",
		section = "reagents",
		chainKey = "reagent:air-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},

	{
		key = "figurine",
		section = "reagents",
		chainKey = "reagent:demonic-figurine",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { WARLOCK = true },
	},
	{
		key = "infernalstone",
		section = "reagents",
		chainKey = "reagent:infernal-stone",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { WARLOCK = true },
	},
	--[[
	    Soul Shards never stack, so their dropdown counts bag slots rather than
	    stacks (countsItems), offering the soul-bag sizes above and opening on
	    a middling one.
	]]
	{
		key = "soulshards",
		section = "reagents",
		chainKey = "reagent:soul-shard",
		countsItems = true,
		choices = SOUL_SHARD_CHOICES,
		defaultStacks = SOUL_SHARD_DEFAULT,
		classes = { WARLOCK = true },
	},
}
