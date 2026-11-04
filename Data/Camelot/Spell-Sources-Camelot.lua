local _, ns = ...

-- [spellId] = { source, level }, -- Spell Name
ns.EXTRA_SPELL_SOURCES = {
	-- Druid
	[5487] = { "QUEST", 10 }, -- Bear Form
	[6807] = { "QUEST", 10 }, -- Maul: rank 1, from the Bear Form quest
	[768] = { "TRAINER", 20 }, -- Cat Form
	[1066] = { "QUEST", 16 }, -- Aquatic Form
	[8946] = { "QUEST", 14 }, -- Cure Poison
	[18960] = { "TRAINER", 10 }, -- Teleport: Moonglade

	-- Hunter
	[1515] = { "QUEST", 10 }, -- Tame Beast
	[5149] = { "QUEST", 10 }, -- Beast Training
	[883] = { "QUEST", 10 }, -- Call Pet
	[2641] = { "QUEST", 10 }, -- Dismiss Pet
	[6991] = { "QUEST", 10 }, -- Feed Pet
	[982] = { "QUEST", 10 }, -- Revive Pet

	-- Mage
	[28272] = { "QUEST", 60 }, -- Polymorph (Pig)

	-- Paladin
	[7328] = { "QUEST", 12 }, -- Redemption
	[5502] = { "QUEST", 20 }, -- Sense Undead
	[13819] = { "QUEST", 40 }, -- Summon Warhorse
	[23214] = { "QUEST", 60 }, -- Summon Charger

	-- Rogue
	[14278] = { "TALENT" }, -- Ghostly Strike
	[14183] = { "TALENT" }, -- Premeditation
	[16511] = { "TALENT" }, -- Hemorrhage
	[14185] = { "TALENT" }, -- Preparation
	[14251] = { "TALENT" }, -- Riposte
	[13877] = { "TALENT" }, -- Blade Flurry
	[13750] = { "TALENT" }, -- Adrenaline Rush
	[14166] = { "TALENT" }, -- Improved Slice and Dice

	-- Shaman
	[8071] = { "QUEST", 4 }, -- Stoneskin Totem
	[3599] = { "QUEST", 10 }, -- Searing Totem
	[5394] = { "QUEST", 20 }, -- Healing Stream Totem

	-- Warlock
	[18288] = { "TALENT" }, -- Amplify Curse
	[18223] = { "TALENT" }, -- Curse of Exhaustion
	[18788] = { "TALENT" }, -- Demonic Sacrifice
	[18708] = { "TALENT" }, -- Fel Domination
	[19028] = { "TALENT" }, -- Soul Link
	[697] = { "QUEST", 10 }, -- Summon Voidwalker
	[712] = { "QUEST", 20 }, -- Summon Succubus
	[713] = { "QUEST", 20 }, -- Summon Incubus
	[691] = { "QUEST", 30 }, -- Summon Felhunter
	[1122] = { "QUEST", 50 }, -- Inferno
	[18540] = { "QUEST", 60 }, -- Ritual of Doom

	-- Warrior
	[71] = { "QUEST", 10 }, -- Defensive Stance
	[355] = { "QUEST", 10 }, -- Taunt
	[7386] = { "QUEST", 10 }, -- Sunder Armor
	[2458] = { "QUEST", 30 }, -- Berserker Stance
	[20252] = { "QUEST", 30 }, -- Intercept
	[12975] = { "TALENT" }, -- Last Stand
	[12809] = { "TALENT" }, -- Concussion Blow
	[23922] = { "TALENT" }, -- Shield Slam
	[12323] = { "TALENT" }, -- Piercing Howl
	[12328] = { "TALENT" }, -- Death Wish
	[23881] = { "TALENT" }, -- Bloodthirst
	[12292] = { "TALENT" }, -- Sweeping Strikes
	[12294] = { "TALENT" }, -- Mortal Strike
}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Where each class list's extraSpells entry (Data/Camelot/Class-Spell-Lists-Camelot.lua) is learned, and at what level, for the What's Next? tab (Features/Spellbook/Whats-Next.lua). The trainer rows (Data/Camelot/Trainer-Spells-Camelot.lua) say their own source: a plain row is the trainer, book marks a book and talent a talent. extraSpells entries carry no source, so this table gives one.
	- Keyed by the entry's first ID, the one the tab lists.
	- source is QUEST (a class quest teaches it), TRAINER (the class trainer, though the trainer rows leave it out, mostly forms and spells a quest unlocks), BOOK (an item teaches it) or TALENT (a talent with no trainer ranks).
	- level is the level the quest, trainer or book asks for. A TALENT row has none: the tab reads the talent's tier from the client's talent tree.
	- Checked against CMaNGOS classic-db: a QUEST row is a quest's reward (quest_template RewSpell and RewSpellCast, through the teaching spell's Learn Spell effect), a TRAINER row is on its trainer lists (npc_trainer, npc_trainer_template), and a BOOK row an item's learn spell (item_template). level is the quest's MinLevel, the trainer's reqlevel or the item's RequiredLevel. Warrior's Taunt and Sunder Armor come with the Defensive Stance quest (Path of Defense), and Intercept with Berserker Stance's (The Affray). Polymorph (Pig) is the reward of Fragmented Magic.
	- Teleport: Moonglade has no trainer, quest or item in CMaNGOS; it stays TRAINER, where Wowhead's comments put it, until a client check confirms it.
	- An extraSpells entry missing here shows with no source: WoW Forever's own spells (Templar's Bulwark, Swift Judgement, Light's Vigil, Mutilate, Venom, Wrack, Bane of Havoc, Spearing Strike), whose source isn't known yet.
	- Copied from Data/Vanilla/, less Summon Dreadsteed, which this client's class lists don't have.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
