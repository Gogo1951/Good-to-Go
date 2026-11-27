local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    AceDB copies scalar and table defaults into the saved table (rawset) when
    a scope is first accessed; only */** wildcards resolve through a
    metatable. An explicit value, false included, is never overridden.

    `profile` is per-character: a level-15 alt and a raiding 60 want
    different buff food, scrolls differ by class, and two Rogues want their
    own poison pairs. `global` holds only what has a concrete reason to be
    account-wide, given on each key; showWelcome and showMacroNames are
    client-wide preferences.
]]
--[[
    The types the class gets use from, never by spec. Read once at load, so
    the defaults follow whoever is playing: a profile stores only the types
    its player changed. Every type gets a key, so an untouched off type reads
    false, not nil.
]]
local function DefaultScrollTypes()
	local _, classToken = UnitClass("player")
	local types = {}
	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local data = ns.SCROLL_DATA[scrollType]
		local classes = data and data.classes
		types[scrollType] = classes == "ALL" or (type(classes) == "table" and tContains(classes, classToken)) or false
	end
	return types
end

ns.DATABASE_DEFAULTS = {
	profile = {
		-- The character's half of the Ignore List; the Global half keeps the same key on `global`.
		ignoreList = {},
		--[[
		    Use Conjured Food & Water First: on, but only while leveling, when free
		    conjured food matters; at max level a raider wants the best.

		    Every consumable's When to Use is a pair: <prefix>In, ticked per group
		    context, and <prefix>Level, one of ns.LEVEL_FILTER_ORDER.
		]]
		useConjuredFirst = true,
		conjuredFirstIn = { solo = true, party = true, raid = true, battleground = true },
		conjuredFirstLevel = "leveling",
		useRestockLast = false,
		potionsUseFoodAndWater = false,
		combineHealthstones = false,
		includeManaRunes = false,
		-- Refresh Food Buffs Under: on at three minutes (seconds), so a buff can't lapse mid-fight unseen.
		earlyReapply = true,
		earlyReapplyThreshold = 180,
		--[[
		    Eat Buff Food When Already Well Fed: on for WoW Forever, where buff food
		    is cheap and nearly all anyone carries; off elsewhere, where it's worth
		    saving for the buff.
		]]
		useBuffFoodWhenFed = ns.FLAVOR == "Camelot",
		scrollTypes = DefaultScrollTypes(),
		--[[
		    Pet buff food is a min-maxer's tool (level 55+, a live pet, a steady
		    supply of Kibler's Bits or Sporeling Snacks), so a new user should never
		    meet it uninvited. Leave this false.
		]]
		usePetBuffFood = false,
		petBuffFoodIn = { solo = true, party = true, raid = true, battleground = true },
		petBuffFoodLevel = "any",
		petBuffTypes = {
			KiblersBits = true,
			SporelingSnacks = true,
		},
		-- "atplayer" fires [@player] on left-click and the toss on right-click; "toss" swaps them.
		explosivesClickMode = "atplayer",
		enableDruidMacroHelper = false,
		druidReturnForm = "bear",
		enableShadowmeldDrinking = false,
		--[[
		    Stealth Eating: one key for Stealth (Rogues) and Shadowmeld (other Night
		    Elves). Per-character, so a Night Elf Druid enabling it never switches it
		    on for the account's Rogues.
		]]
		enableStealthEating = false,
		-- Drinking only takes effect where Cannibalize restores mana (ns.CANNIBALIZE_RESTORES_MANA).
		enableCannibalizeEating = false,
		enableCannibalizeDrinking = false,
		-- Troll Rapid Regeneration: only WoW Forever has the spell.
		enableRapidRegenerationEating = false,
		enableRapidRegenerationBandage = false,
		-- ns.POISON_GROUP_BASE_ITEMS group IDs (4 = Instant Poison).
		mainHandPoisonGroup = 4,
		offHandPoisonGroup = 4,
		-- Fishing Lure steps: the gear waits until ticked; fishing food and a lure are ticked from the start.
		fishingEquipPole = false,
		fishingEquipPants = false,
		fishingEquipHat = false,
		fishingEquipBoots = false,
		fishingEquipGloves = false,
		fishingUseFood = true,
		fishingUseLure = true,
	},
	global = {
		showWelcome = true,
		-- Master switches, account-wide like the shared macros and lists they govern.
		macrosEnabled = true,
		restockerEnabled = true,
		spellbookEnabled = true,
		--[[
		    `lists` live on global so a profile switch or Reset Profile can never
		    empty a hand-built list or re-offer the Starter List. `listChoices` is
		    keyed by profileKeys name and kept off the profile, so two characters
		    sharing a profile still shop from lists of their own.

		    Reminders ship Simple: a reminder is a nudge. restockLowThreshold is the
		    percent of a row's amount below which it counts as low.

		    The Gold Reserve ships on at 1 gold, low enough that nobody notices it
		    until a merchant run would leave them broke; one floor for every
		    character. goldReserveAmount is whole gold.
		]]
		restocker = {
			lists = {},
			listChoices = {},
			framePosition = {},
			staplesPosition = {},
			restockReminderChat = true,
			restockReminderSound = true,
			restockReminderMode = "simple",
			merchantReminder = true,
			merchantReminderMode = "simple",
			bankReminder = true,
			bankReminderMode = "simple",
			restockLowThreshold = 80,
			autoOpenAtBank = false,
			autoOpenAtMerchant = false,
			goldReserve = true,
			goldReserveAmount = 1,
		},
		--[[
		    The Inventory Report ships ON: it only adds lines to a tooltip the player
		    asked for. The switch exists because most auction add-ons print their own
		    counts, and a player running one wants a single set. A display preference
		    for the account.
		]]
		inventoryReport = true,
		--[[
		    Every character's last-known bags and bank, by ns.GetCharacterKey(), each
		    place packed as "itemID:count" pairs. Account-wide: its point is showing
		    one character what the others hold, and a profile reset must not wipe it.
		]]
		inventory = {},
		--[[
		    The Global half of the Ignore List, outside the profiles so it reaches
		    all of them and no profile reset empties it.
		]]
		ignoreList = {},
		--[[
		    Off, so the add-on hides the macro names Blizzard began showing again on
		    the action bars.
		]]
		showMacroNames = false,
		--[[
		    A behavior preference, not a consumable choice, so it and every category
		    under it are answered once for the account. Silence is the normal output,
		    so a switch here should only ever ADD a line about something broken.

		    Ships ON: it speaks only at a ready check, privately. Deliberately a NEW
		    key: the retired readinessReport's saved values belong to its old meaning.
		]]
		readinessReportEnabled = true,
		--[[
		    Ships ON: the things a player can fix in the few seconds a ready
		    check gives them, or fix before the pull. Well Fed, the weapon buffs
		    and buffs about to lapse are their own to fix. A Warlock can hand
		    over a Healthstone or put a soulstone up, and a Mage conjures their
		    own gem; those three gate on who can fix them, so none can nag
		    someone who cannot answer it: the Healthstone on a Warlock being in
		    the group, the soulstone and the gem on the player being that class.
		    Damaged gear is the one thing that breaks mid-pull.

		    Ships OFF: what a player may not carry by choice. Scrolls, the pet's
		    food and the flask are min-maxing, and an empty potion or bandage
		    slot mid-pull is not something anyone can act on.
		]]
		-- Missing Buffs
		readinessFlask = false,
		readinessWellFed = true,
		readinessPetWellFed = false,
		readinessScrolls = false,
		readinessSoulstone = true,
		readinessMainHandBuff = true,
		readinessOffHandBuff = true,
		--[[
		    Seconds. Apart from the macros' earlyReapplyThreshold, and covering every
		    aura; both ship at three minutes, so the two agree until the player sets
		    them apart.
		]]
		readinessExpiring = true,
		readinessExpiringThreshold = 180,

		-- Missing Items
		readinessHealthstone = true,
		readinessManaGem = true,
		readinessHealingPotion = false,
		readinessManaPotion = false,
		readinessBandages = false,
		--[[
		    Percent, compared against the LOWEST equipped item rather than an
		    average: one weapon at 5% is the thing that breaks mid-pull, and an
		    average hides it behind seventeen healthy pieces.
		]]
		readinessDurability = true,
		readinessDurabilityThreshold = 20,

		-- Character
		readinessSpec = false,
		readinessPvP = false,
		readinessQuestionableGear = false,
		--[[
		    Account-wide because the macros live in the shared General tab: a
		    character switch only rewrites their bodies. Poisons starts off, since
		    Buff Duty offers poisons too; Fishing Lure starts off: it's for players
		    who fish.
		]]
		enabledMacros = {
			["Bandage"] = true,
			["Explosive"] = true,
			["Feed Pet"] = true,
			["Fishing Lure"] = false,
			["Food"] = true,
			["Health Potion"] = true,
			["Healthstone"] = true,
			["Mana Gem"] = true,
			["Mana Potion"] = true,
			["Poisons"] = false,
			["Soulstone"] = true,
			["Water"] = true,
		},
		-- LibDBIcon owns this subtable; on `global`, so no profile switch or reset moves the button.
		minimap = {
			hide = false,
		},
		--[[
		    Account-wide: one character sees and mails the others, and no profile
		    reset can forget an alt's gold.
		      enabled    the feature's switch. Ships ON: it only adds a tab to
		                 the mailbox, and never mails anything unless clicked.
		      skipSmall  Skip Top-Ups Under 1g: Replenish leaves out a character short
		                 by less than 1g, which isn't worth a mail's postage.
		      characters each character's record by ns.GetCharacterKey(): name,
		                 realm, class, faction, money and when it was seen, what
		                 it keeps, and gold the bank mailed it that's on its way.
		      banks      the bank's key for each realm and faction, as
		                 "Realm|Faction": mail can't cross either.
		]]
		currencyReplenish = {
			enabled = true,
			skipSmall = true,
			characters = {},
			banks = {},
		},
	},
}

--------------------------------------------------------------------------------
-- Feature Defaults
--------------------------------------------------------------------------------

--[[
    Each feature below adds its own keys to the table above. Two features
    declaring one key would share a setting without meaning to, so it stops the
    load instead.
]]
local function AddDefaults(scope, defaults)
	ns.DATABASE_DEFAULTS[scope] = ns.DATABASE_DEFAULTS[scope] or {}
	local target = ns.DATABASE_DEFAULTS[scope]
	for key, value in pairs(defaults) do
		assert(target[key] == nil, "Duplicate default: " .. scope .. "." .. key)
		target[key] = value
	end
end

--------------------------------------------------------------------------------
-- Spellbook Defaults
--------------------------------------------------------------------------------

--[[
    Trainer spells and macro options ride the profile, since which spells a
    page lists is per class. Which macros the add-on made is a fact, not a
    setting, so it lives in global and char, where no profile reset can lose it.
]]
local SPELLBOOK_DEFAULTS = {
	global = {
		ownedMacros = {}, -- general (account-wide) macros the add-on created, by WoW macro name: the creating character's key
		-- each WoW macro's tag line ID (see ns.MacroTag), by what the macro is for, and how many were handed out
		macroTags = {},
		macroTagCount = 0,
		-- What's Next ranks under the game's own spell tooltips: a display preference for the account.
		abilityTooltipRanks = true,
		windowPosition = {}, -- one spot for every character
	},
	profile = {
		showAllRanks = false,
		showGroupedSpells = false,
		showUnlearned = false,
		countSpellsOnBars = true,
		pageSort = "category", -- "category" (by kind of macro) or "school" (by spellbook tab); see ns.PageSort
		-- the What's Next? tab: "availability" (by status) or "level" (by learn level); see ns.WhatsNextSort
		whatsNextSort = "availability",
		whatsNextShowKnown = true,
		whatsNextShowTalents = true,
		-- the Pet What's Next? tab, which shares whatsNextSort; see ns.WhatsNextPetShowsKnown
		whatsNextPetShowKnown = true,
		whatsNextPetShowOtherFamilies = false,
		markedPlaced = {}, -- macros marked placed from the page's settings menu, by macro identity
		--[[
		    kind -> option -> boolean. Buffs start on Dynamic Rank, since a buff's
		    rank can't land on a player too far below its level, and on Right-Click
		    For the group (or single) version.
		]]
		kindDefaults = {
			enemy = {},
			friendly = {},
			buff = { targetRank = true, groupVersion = true },
			resurrect = {},
			anyone = {},
			ground = {},
			form = {},
			self = {},
		},
		cursor = {},
		pet = {},
		stance = {},
		petAttack = {},
		stopCast = {},
		startAttack = {},
		noToggle = {},
		targetRank = {},
		fixedRank = {},
		targetEnemy = {},
		targetFriend = {},
		combatOnly = {},
		noCombat = {},
		oncePerCombat = {},
		oncePerTarget = {},
		stopAttack = {},
		stopIfChanneling = {},
		stopIfStealthed = {},
		hideErrors = {},
		muteErrors = {},
		cancelForm = {},
		autoShot = {},
		groupVersion = {},
		groupedSpells = {},
		targetPriority = {}, -- each spell's own target priority, as a list of units (see ns.TargetPriority)
		conditionals = {}, -- each spell's Conditionals rows, in order (see ns.Conditionals)
		castSequence = {}, -- each spell's Cast Sequence steps after its own, in order (see ns.CastSequenceSteps)
		castSequenceEnd = {}, -- "stop" where a spell's Cast Sequence stops on NULL rather than starting over
		castSequenceReset = {}, -- each spell's Cast Sequence resets, where not the default (see ns.CastSequenceResetText)
		useItems = {},
		-- "general" where a spell's WoW macro goes in the General list rather than the character's own (see ns.MacroTab)
		macroTab = {},
		macroCopies = {}, -- the Duplicate copies of each spell's macro, by its Rank 1 ID, as a list of copy numbers
		trainerSpells = {}, -- by class token, then spell id -> required level (see Features/Enhanced-Spellbook/Trainer-Recording.lua)
	},
	char = {
		ownedMacros = {}, -- character macros the add-on created, by WoW macro name
	},
}

AddDefaults("global", SPELLBOOK_DEFAULTS.global)
AddDefaults("profile", SPELLBOOK_DEFAULTS.profile)
AddDefaults("char", SPELLBOOK_DEFAULTS.char)

--------------------------------------------------------------------------------
-- Buff Duty Defaults
--------------------------------------------------------------------------------

-- Account-wide: none of these is about one character, so every character buffs the same way.
AddDefaults("global", {
	--[[
	    On by default: it is self-only, and appears only when there is something
	    you can fix. `audience` (Data.BUFF_AUDIENCE) is keyed by the row's first
	    single-target id and seeds from this client's Buff-Duty-Spells defaults.
	    `point` is nil until the window is first dragged.
	]]
	buffWindow = {
		enabled = true,
		--[[
		    showWhere covers the first three contexts (a battleground is always an
		    instance). An unset class reads as ticked. Paladins start off: most of
		    them run Pally Power for their blessings.
		]]
		showIn = { solo = true, party = true, raid = true, battleground = true },
		showWhere = { solo = "ALWAYS", party = "ALWAYS", raid = "INSTANCE" },
		showClasses = {
			PALADIN = false,
		},
		locked = false,
		hideInCombat = true,
		-- Background only, in percent; 80 is the menus' own plate.
		windowOpacity = 80,
		-- Minutes left under which a buff counts as missing.
		refreshMinutes = 3,
		--[[
		    When each class takes Tanks buffs (Thorns) without a role of its own. A
		    class with no entry is NEVER; classes that can fight in melee, and pets,
		    start SOLO.
		]]
		tankWhen = {
			DEATHKNIGHT = "SOLO",
			DRUID = "SOLO",
			MONK = "SOLO",
			PALADIN = "SOLO",
			ROGUE = "SOLO",
			SHAMAN = "SOLO",
			WARRIOR = "SOLO",
			PET = "SOLO",
		},
		-- selfRefresh is keyed by the row's first rank id, seeded from this client's BUFF_DUTY_SELF_SPELLS.
		selfEnabled = true,
		selfRefresh = {},
		-- Keyed "ROGUE_MAIN" and so on, then the row's first id. Unset reads as ticked.
		weaponPicks = {},
		-- weaponItems: "MAIN" or "OFF", then the item id. Unset reads as ticked.
		weaponEnabled = true,
		weaponItems = {},
		-- rowKey: whether the Cast Next Buff key uses a category; Elixirs and Other Buffs are a click only until turned on.
		rowWhen = {
			self = "ALWAYS",
			food = "ALWAYS",
			weapons = "ALWAYS",
			scrolls = "ALWAYS",
			elixirs = "ALWAYS",
			other = "ALWAYS",
		},
		rowKey = { self = true, food = true, weapons = true, scrolls = true, elixirs = false, other = false },
		--[[
		    Self-Buffs and Weapon Buffs keep theirs in selfEnabled and weaponEnabled.
		    Well Fed, Scrolls and Flasks or Elixirs have no default here: each is
		    seeded once from selfRefresh's wellFed, scrolls and elixirs keys, so each
		    flavor's own default carries over.
		]]
		rowOn = { other = true },
		-- 0 is When Missing.
		rowShow = { self = 3, food = 3, weapons = 3, scrolls = 3, elixirs = 3, other = 3 },
		-- Show Missing Inventory. Self-Buffs has none: spells need no bags.
		rowOut = { food = false, weapons = false, scrolls = false, elixirs = false, other = false },
		favorEnabled = true,
		favorSeconds = 40,
		targetEnabled = true,
		-- Whether the Target row also lists a friendly NPC you can buff.
		targetNPCs = true,
		-- askTargetMessage has no default here, like askMessage below.
		askTarget = true,
		-- Off holds buffs back from PvP-flagged players while you aren't flagged, since buffing them flags you.
		buffPvPFlagged = false,
		-- By item id. Unset reads as on, so food picked up later is offered.
		buffFoodOff = {},
		-- By item id. Unset reads as on.
		elixirOff = {},
		scrollOff = {},
		-- askMessage has no default here: unset, it goes out in the chosen language's default.
		askOtherClasses = true,
		audience = {},
	},
})

--------------------------------------------------------------------------------
-- Rank Watch Defaults
--------------------------------------------------------------------------------

--[[
    Account-wide: a behavior preference, and the casts already reported are a
    fact about the other players. Off until the player turns it on.

    untracked, by spell ID: true for a rank unticked, false for a default-off
    rank ticked; an untouched rank follows the data, so a new rank needs no
    seeding. announced keys "<caster GUID>-<caster level>-<spell ID>", the
    shape standalone Rank Sentinel records and sends with NOTIFY, so the two
    never report one cast twice; forgotten when announcedVersion stops
    matching ns.Version.
]]
AddDefaults("global", {
	rankWatch = {
		enabled = false,
		whisper = true, -- whisper a group member who used a low rank, when this client is the one chosen to
		print = true, -- print a group member's low rank in your own chat
		graceMaxLevel = 0, -- levels a max-level character gets to train a rank before it's reported
		graceLeveling = 4, -- the same for a character still leveling
		untracked = {},
		ignoredPlayers = {}, -- caster GUID -> name, never reported
		ignoredClasses = {}, -- caster GUID -> class token, to draw the Ignored Players list in class colors
		-- The whispers' own text has no default here: unset, each goes out in the chosen language's default.
		announced = {},
		announcedVersion = "",
		--[[
		    Ability Alerts While Leveling: its own switch, on from the start, since it
		    only ever talks to the player and only on a ding.
		]]
		levelUpAlerts = true, -- on a ding, print the trainer spells the new level opened
		levelUpAlertsPast = true, -- and the ones from earlier levels not learned yet
		levelUpAlertsPet = true, -- and a hunter's pet trainer ranks, or a warlock's grimoires, the level opened
		levelUpAlertsPetPast = true, -- and a hunter's pet trainer ranks from earlier levels not learned yet
		importedStandalone = false, -- MIGRATION (remove after 2026-12-08): the standalone add-on's settings were copied in
	},
})

--------------------------------------------------------------------------------
-- Message Language Defaults
--------------------------------------------------------------------------------

-- One setting for both features: the players you talk to read one language, whichever feature is talking.
AddDefaults("global", {
	messageLanguage = ns.Data.DEFAULT_MESSAGE_LANGUAGE,
})
