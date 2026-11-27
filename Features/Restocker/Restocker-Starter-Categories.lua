local _, ns = ...

--------------------------------------------------------------------------------
-- Starter List Categories
--------------------------------------------------------------------------------

--[[
    Holds no game IDs, so one table serves every client: `chainKey` names a
    ladder the loaded flavor folder supplies, and Restocker-Starter-List.lua
    drops a row whose ladder that folder lacks.
]]

--[[
    Counts are whole stacks, and a stack is whatever the item stacks to (an
    Ankh is 5 on Era, 10 on TBC), so no row carries a size. Ammo's cap fills an
    18-slot quiver. countsItems makes a plain count for an item that never
    stacks, declared here because the labels draw before a cold item resolves.
    A category sets maxStacks or choices, never both.
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

-- The English keys are always present alongside the localized aliases.
local PET_DIET_MAP = ns.PET_DIET_MAP

local POISON_GROUP = ns.POISON_GROUPS

--[[
    `classes` is who is offered a row (absent: everyone); `defaultFor` who gets
    it pre-ticked. A Death Knight row needs no expansion gate: only a folder
    with its ladder offers it.
]]
local AMMO_CLASSES = { HUNTER = true, WARRIOR = true, ROGUE = true }
local MANA_CLASSES =
	{ DRUID = true, HUNTER = true, MAGE = true, PALADIN = true, PRIEST = true, SHAMAN = true, WARLOCK = true }

--[[
    A row standing for a kind of item carries a label (food reuses the DIET_
    keys, as the pet-food tooltips do); the rest show the client's name for the
    item a tick would add, or with namesFirstTier the ladder's first. Order here
    is for the maintainer; display order is computed (SectionCategories).
]]
ns.STARTER_LIST_CATEGORIES = {
	-- Food, everyone. Bread ticked for all; meat for hunters, whose pet eats it too.
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
	    Poisons, rogues. Each ladder opens at its spell's training level, so no
	    level gate; Atrophic, Numbing, Occult and Sebacious exist only in the
	    Discovery folder.
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
	-- Reagents & Tools. The Hearthstone, offered to all, shows that anything can go on the list.
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
	-- Soul Shards never stack, so the dropdown counts bag slots (countsItems).
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
