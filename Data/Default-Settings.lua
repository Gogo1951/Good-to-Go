local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    The single AceDB-3.0 defaults table. Features/Core.lua passes this to
    AceDB:New, which applies the defaults itself -- there is no hand-rolled
    merge. Scalar and table defaults are physically copied into the saved
    table (copyDefaults via rawset) when a scope is first accessed; only
    */** wildcard defaults resolve through a metatable. An explicit user
    value, including false, is never overridden either way.

    The consumable settings live under `profile`, so they are per-character:
    each character gets a profile of its own, named as AceDB names the
    character (its first name and surname on WoW Forever, "Name - Realm" on
    Era and TBC), and can run a different set of consumables. That is the
    point -- a level-15 alt and a raiding 60 want different buff food, scrolls
    differ by class, and two Rogues want their own poison pairs. The stock
    Profiles panel (Options/Options-Profiles.lua) is therefore meaningful:
    switching, copying, or resetting a profile moves real settings, and two
    characters share a setup only when the player puts both on one profile.

    What stays under `global` (account-wide), each for a concrete reason rather
    than convenience:
      * showWelcome    -- one login greeting per account, not per character,
                          shared by every feature.
      * showMacroNames -- a client-wide action-bar appearance tweak.
      * macrosEnabled  -- the Macros master switch, account-wide for the same
                          reason as enabledMacros: the macros it freezes are
                          shared by every character.
      * restockerEnabled -- the Restocker master switch, kept with the Restock
                          Lists it governs, which are account-wide too.
      * readinessReportEnabled -- a behavior preference (does the Readiness
                          Report speak up on a ready check?) rather than a consumable choice.
      * enabledMacros  -- the macros themselves are account-wide: they live in
                          the shared General macro tab, so which ones exist has
                          to be one choice for the whole account. Keeping the
                          setting here means the two agree -- a character switch
                          never adds or removes a macro, it only rewrites the
                          shared bodies to that character's best items.
      * minimap        -- LibDBIcon reads this subtable directly and owns its
                          contents (position etc.), so keeping it off the
                          profile means switching, resetting, or deleting a
                          profile never moves the minimap button.
      * ignoreList     -- the Global half of the Ignore List, hiding an
                          item from every character's macros at once; the
                          character's half keeps the same key on the profile,
                          and Features/Macros-for-Consumables/Ignore-List.lua reads both.
      * readiness*     -- the per-category switches under
                          readinessReportEnabled, each answered once for the
                          account like the master toggle above it. Their own
                          reasons are on the keys.
      * restocker      -- the Restock Lists and the Restocker's settings,
                          shared by the account; a profile only picks which
                          list it uses. Its reason is on the key itself.
      * inventoryReport, inventory -- the item-tooltip counts and the
                          per-character snapshots behind them. Their reasons
                          are on the keys.

    No profile names a Restock List: which list a character uses is kept by
    character, in restocker.listChoices below, and
    ns.InitializeCharacterRestockList
    (Features/Restocker/Restocker-Saved-Lists.lua) gives a character without
    one a list named for its class.
]]
--[[
    Which scroll types start ticked: the ones the character's class gets use
    from, by each type's classes in Data/{Game}/Scrolls-{Game}.lua ("ALL" or
    class tokens). Stamina and Protection suit everyone; the rest go by class,
    never by spec. Read once at load, so the defaults are the logged-in
    character's: a profile only stores the types its player changed, and every
    other type follows the class of whoever is playing it. Every type in
    ns.SCROLL_CHECK_ORDER gets a key, so an untouched off type reads false
    rather than nil.
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
		--[[
		    The character's own half of the Ignore List, itemID to true: the
		    items hidden from the macros of whoever is on this profile. The
		    Global half keeps the same key on `global`, and
		    Features/Macros-for-Consumables/Ignore-List.lua reads both.
		]]
		ignoreList = {},
		--[[
		    Use Conjured Food & Water First: the Food and Water macros rank
		    conjured items above anything that restores more (buff food still
		    comes first). On by default, in every group context but only while
		    leveling (level filter "leveling", below max level): leveling is
		    when free conjured food matters, solo or in a dungeon with a Mage
		    friend, while at max level a raider wants the best. Per-character
		    like the other consumable choices.

		    Every consumable's When to Use is a pair: <prefix>In, ticked per
		    group context (ns.GROUP_CONTEXTS), and <prefix>Level, one of
		    ns.LEVEL_FILTER_ORDER. ns.IsUseWhenActive reads both.
		]]
		useConjuredFirst = true,
		conjuredFirstIn = { solo = true, party = true, raid = true, battleground = true },
		conjuredFirstLevel = "leveling",
		--[[
		    Use Restock List Food & Water Last: between two items that restore
		    the same amount, the Food and Water macros pick the one not on the
		    current Restock List, whatever its Keep amount. Off by default.
		]]
		useRestockLast = false,
		--[[
		    Use Food & Water in Potion Macros Out of Combat: the Health Potion
		    macro eats the Food macro's pick and the Mana Potion macro drinks
		    the Water macro's pick while the player is out of combat, the way
		    an older add-on's single button did. Off by default.
		]]
		potionsUseFoodAndWater = false,
		combineHealthstones = false,
		includeManaRunes = false,
		--[[
		    Early re-application: with earlyReapply on, a food/scroll/pet buff
		    whose remaining time is under earlyReapplyThreshold (seconds)
		    counts as already expired, so the macros offer a fresh application
		    before a pull. See BuffCountsAsActive in Scanner-Auras.lua. On by
		    default at three minutes, so a buff can't lapse mid-fight unseen.
		]]
		earlyReapply = true,
		earlyReapplyThreshold = 180,
		-- Prioritize Buff Food: on by default, at every level.
		useBuffFood = true,
		buffFoodIn = { solo = true, party = true, raid = true, battleground = true },
		buffFoodLevel = "any",
		--[[
		    Scrolls: on by default, at every level, for the types the class
		    can use (DefaultScrollTypes above). A scroll in the bags is there
		    to be read, and the Food macro only turns to scrolls while their
		    buff is missing.
		]]
		useScrolls = true,
		scrollsIn = { solo = true, party = true, raid = true, battleground = true },
		scrollsLevel = "any",
		scrollTypes = DefaultScrollTypes(),
		--[[
		    Off by default. Pet buff food
		    is a min-maxer's tool -- it needs level 55+, a live pet, and a
		    steady supply of Kibler's Bits or Sporeling Snacks -- so a new user
		    should never meet it uninvited. Leave this false.
		]]
		usePetBuffFood = false,
		petBuffFoodIn = { solo = true, party = true, raid = true, battleground = true },
		petBuffFoodLevel = "any",
		petBuffTypes = {
			KiblersBits = true,
			SporelingSnacks = true,
		},
		--[[
		    Explosive macro click layout: "atplayer" fires [@player] on
		    left-click and the standard toss on right-click; "toss" swaps
		    the buttons. See BuildExplosiveUseLine in Features/Macros-for-Consumables/Macros/Explosive.lua.
		]]
		explosivesClickMode = "atplayer",
		enableDruidMacroHelper = false,
		druidReturnForm = "bear",
		enableShadowmeldDrinking = false,
		--[[
		    Stealth Eating appends the character's stealth ability to the Food
		    macro -- Stealth for Rogues, Shadowmeld for other Night Elves. One
		    key serves both; the class/race gate lives in Food.lua's appendBlock.
		    Per-character, so a Night Elf Druid enabling it never switches it
		    on for the account's Rogues.
		]]
		enableStealthEating = false,
		--[[
		    Forsaken: the Food and Water macros try Cannibalize first while the
		    target is a Humanoid or Undead and the spell is off cooldown, and
		    eat or drink when it cannot cast (Features/Macros-for-Consumables/Macros/Tools-Forsaken.lua). Drinking only takes effect
		    where Cannibalize restores mana (ns.CANNIBALIZE_RESTORES_MANA).
		]]
		enableCannibalizeEating = false,
		enableCannibalizeDrinking = false,
		--[[
		    Troll: the Food macro casts Rapid Regeneration instead of eating
		    while the spell is off cooldown
		    (Features/Macros-for-Consumables/Macros/Tools-Troll.lua). Only WoW
		    Forever has the spell (ns.RAPID_REGENERATION_SPELL_ID).
		]]
		enableRapidRegenerationEating = false,
		--[[
		    Rogue poison groups per weapon slot, keyed by ns.POISON_GROUP_BASE_ITEMS
		    group IDs (4 = Instant Poison). See ns.POISON_GROUPS in Data/Data.lua.
		]]
		mainHandPoisonGroup = 4,
		offHandPoisonGroup = 4,
	},
	global = {
		showWelcome = true,
		--[[
		    The features' master switches, in the root panel's Features section
		    and atop each feature's own panel, all account-wide. Off, macrosEnabled
		    leaves every macro as it last was: nothing is created, rewritten or
		    deleted until it is back on. Off, restockerEnabled stops every part
		    of the Restocker, its window, /restock and the mini-map click
		    included; the lists stay saved. Off, spellbookEnabled hides the
		    Spellbook and its tab in the game's spellbook and stops keeping its
		    macros current; the macros it made stay as they last were.
		]]
		macrosEnabled = true,
		restockerEnabled = true,
		spellbookEnabled = true,
		--[[
		    The Restock List subsystem. `lists` are the player's own named
		    shopping lists, shared by every character, and the stock Reset
		    Profile control must never reach them. Putting them on global is
		    what guarantees that -- a profile switch or reset cannot empty a
		    hand-built list or re-offer the Starter List to a character that
		    already answered it. `listChoices` is which list each character
		    uses, keyed by the character's name as profileKeys holds it. It is
		    kept here and not on a profile, so two characters sharing a profile
		    still shop from lists of their own, and switching one never moves
		    the other.

		    The two reminder modes differ on purpose: in town you are away from
		    your bags and the detail is the whole point, while at a merchant or
		    a bank you are already looking at the window that fixes it.

		    The Gold Reserve ships on at 1 gold, a floor low enough that nobody
		    notices it until a merchant run would otherwise leave them broke. It
		    sits here with the lists, outside every profile: one floor for every
		    character, so a reserve set on one also holds back an alt with less.
		    goldReserveAmount is whole gold, one of ns.GOLD_RESERVE_AMOUNTS.
		]]
		restocker = {
			lists = {},
			listChoices = {},
			framePosition = {},
			restockReminderChat = true,
			restockReminderSound = true,
			restockReminderMode = "verbose",
			merchantReminder = true,
			merchantReminderMode = "simple",
			bankReminder = true,
			bankReminderMode = "simple",
			autoOpenAtBank = false,
			autoOpenAtMerchant = false,
			goldReserve = true,
			goldReserveAmount = 1,
		},
		--[[
		    The Inventory Report in item tooltips (Features/Inventory-Report/Inventory-Report-Tooltip.lua).
		    Ships ON: it only ever adds lines to a
		    tooltip the player asked for, and never acts. The switch exists
		    because most auction add-ons print their own counts under the same
		    items, and a player running one wants a single set. A display
		    preference for the account, like showMacroNames.
		]]
		inventoryReport = true,
		--[[
		    Every character's last-known bags and bank, keyed by character (the
		    Restocker's "Name-Realm" key), each place packed into one line of
		    "itemID:count" pairs by Features/Inventory-Report/Inventory-Report-Recording.lua. Account-wide
		    because its whole point is showing one character what the others
		    hold, and never a profile: switching or resetting one must not wipe
		    what an alt was carrying. Each record also holds the character's
		    name, realm and class, and the Restock List reads the class to color
		    the characters on a list.
		]]
		inventory = {},
		--[[
		    The Global half of the Ignore List, itemID to true: items hidden
		    from every character's macros, whatever profile the character is on.
		    Outside the profiles so that it reaches all of them, and so that
		    resetting one character's profile never empties it.
		]]
		ignoreList = {},
		--[[
		    Macro-name text on the default action bars. Off by default so the
		    add-on hides the names Blizzard recently began showing again; the
		    "Enable Macro Names on Buttons" toggle reads it directly, so checked
		    means the names show (see Features/Macros-for-Consumables/Action-Button-Text.lua).
		]]
		showMacroNames = false,
		--[[
		    The Readiness Report: on a ready check, a private report naming what
		    still needs fixing. A behavior preference -- whether you want
		    the report speaking up at all -- rather than a consumable choice, so
		    it is answered once for the account rather than per character, and so
		    is every category switch under it.

		    Silence is the report's normal output: a category with nothing wrong
		    prints nothing, and a clean character prints nothing at all. That is
		    what lets it cover this much without becoming noise, so a switch here
		    should only ever be able to ADD a line about something broken.

		    The report ships ON: it speaks only at a ready check, privately, and
		    only about something broken. The key is deliberately a NEW one rather
		    than the retired readinessReport, whose saved values belong to its
		    old meaning.
		]]
		readinessReportEnabled = true,
		--[[
		    Which categories the report covers. Each is answered once for the
		    account, like the master toggle above, and every one of them is dead
		    while readinessReportEnabled is off.

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
		    Buffs about to lapse, in seconds. Distinct from the Consumable Macros panel's
		    Buff Re-Application threshold, which decides when the MACROS treat a
		    buff as spent: this one only decides when the report mentions one,
		    and covers every aura on the character rather than the tracked ones.
		    Both ship at three minutes, so the report and the macros agree on
		    what counts as expiring until the player sets them apart.
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
		    Which macros Consumable Macros maintains. Account-wide because the macros
		    are: they live in the shared General macro tab, so unchecking one
		    removes the shared macro for every character. Feed Pet and Poisons
		    are class-gated on top of this toggle and build only for Hunters and
		    Rogues; the conjure-capable macros (Healthstone, Mana Gem,
		    Soulstone) are built for every class, with only their conjure clicks
		    class-gated.
		]]
		enabledMacros = {
			["Bandage"] = true,
			["Explosive"] = true,
			["Feed Pet"] = true,
			["Food"] = true,
			["Health Potion"] = true,
			["Healthstone"] = true,
			["Mana Gem"] = true,
			["Mana Potion"] = true,
			["Poisons"] = true,
			["Soulstone"] = true,
			["Water"] = true,
		},
		--[[
		    The main mini-map button's visibility. LibDBIcon reads `hide` from this subtable,
		    so it stays the single source of truth -- the "Enable Mini-map Button"
		    toggle is its inverse (hide = false means shown). LibDBIcon owns the
		    rest of the subtable (position, etc.); living under `global`, it is
		    untouched by profile switches and resets.
		]]
		minimap = {
			hide = false,
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
	Per-Character model: the recorded trainer spells differ from character to character, and the macro options
	ride the profile with them, since which spells a page lists is per class. Which macros the add-on made is a
	fact about the account's and the character's macro lists, not a setting, so it lives in global and char,
	where no profile change or reset can lose it.
]]
local SPELLBOOK_DEFAULTS = {
	global = {
		ownedMacros = {}, -- general (account-wide) macros the add-on created, by WoW macro name: the creating character's key
		-- each WoW macro's tag line ID (see ns.MacroTag), by what the macro is for, and how many were handed out
		macroTags = {},
		macroTagCount = 0,
		--[[
			the What's Next ranks under the game's own spell tooltips (Features/Enhanced-Spellbook/Spell-Ranks-Tooltip.lua):
			a display preference for the account, like inventoryReport. Enhanced Spellbook's own window shows its
			ranks either way.
		]]
		abilityTooltipRanks = true,
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
			the options each kind of macro starts with (see ns.MACRO_KINDS), as kind -> option -> true or
			false. Buffs start on Dynamic Rank, since a buff's rank can't land on a player too far below its level,
			and on Right-Click For the group (or single) version.
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
		focus = {},
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

--[[
    Buff Duty's settings, account-wide: none of them is about one character,
    so every character buffs the same way.
]]
AddDefaults("global", {
	--[[
		    Buff Duty: the click-to-cast list of group members missing a buff
		    you can give. On by default: it is self-only, and it
		    only appears when there is something you can fix. `audience` holds who
		    each buff is offered to (Data.BUFF_AUDIENCE), keyed by the row's first
		    single-target id, and seeds from the row defaults in this client's
		    Buff-Duty-Spells file. `point` is nil until the window is first
		    dragged, and until then its top-right corner sits a little right of
		    and above the middle of the screen.
		]]
	buffWindow = {
		enabled = true,
		--[[
			    When to Show: whether the window shows in each group context
			    (ns.GROUP_CONTEXTS), where it shows in the first three (one of
			    Data.BUFF_DUTY_WHERE; a battleground is always an instance),
			    and which of your classes it shows on, keyed by class token.
			    An unset class reads as ticked. Paladins start off: most of
			    them run Pally Power for their blessings.
			]]
		showIn = { solo = true, party = true, raid = true, battleground = true },
		showWhere = { solo = "ALWAYS", party = "ALWAYS", raid = "INSTANCE" },
		showClasses = {
			PALADIN = false,
		},
		locked = false,
		hideInCombat = true,
		--[[
			    Minutes left under which a buff counts as missing; one of
			    Data.BUFF_DUTY_REFRESH_CHOICES.
			]]
		refreshMinutes = 3,
		--[[
			    When each class, and pets (Data.TANK_WHEN_PET), take Tanks buffs
			    (Thorns) without a role of their own: one of Data.TANK_WHEN, keyed
			    by class token. A class with no entry is NEVER; the classes that
			    can fight in melee, and pets, start SOLO.
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
		--[[
			    The Self Buffs row's master switch, and when each self buff shows
			    (one of Data.SELF_REFRESH_CHOICES), keyed by the row's first rank
			    id and seeded from this client's BUFF_DUTY_SELF_SPELLS defaults.
			]]
		selfEnabled = true,
		selfRefresh = {},
		-- MIGRATION (remove after 2026-11-21): the selfRefresh keys already moved from 5 minutes to 3.
		selfRefreshMigrated = {},
		--[[
			    Whether each poison or imbue is ticked for each hand, keyed
			    "ROGUE_MAIN" and so on, then by the BUFF_DUTY_WEAPON_ENCHANTS
			    row's first id. Unset reads as ticked.
			]]
		weaponPicks = {},
		--[[
			    The Weapon Buffs switch, its one Reapply timing (one of
			    Data.WEAPON_REFRESH_CHOICES), and whether each oil, stone or
			    lure is ticked for each hand ("MAIN" or "OFF", then the item
			    id; unset reads as ticked).
			]]
		weaponEnabled = true,
		weaponRefresh = 3,
		weaponItems = {},
		favorEnabled = true,
		-- One of Data.BUFF_DUTY_FAVOR_CHOICES.
		favorSeconds = 40,
		targetEnabled = true,
		-- The Party-Buffs raid buffs, and the asks its clicks send.
		askOtherClasses = true,
		audience = {},
	},
})

--------------------------------------------------------------------------------
-- Rank Watch Defaults
--------------------------------------------------------------------------------

--[[
    Account-wide, like Buff Duty: whether to watch the group's ranks and how to speak up is a
    behavior preference, not a choice about one character, and the casts already reported are a fact about the
    other players, shared with every character who might group with them again. Off until the player turns it on.

    untracked holds the player's own choices on the Tracked Abilities panel, by spell ID: true for a rank they
    unticked, false for one the data starts off (Rank 1 Scorch and the like) that they ticked. A rank they never
    touched follows the data, so a rank added later starts at its default with no seeding. announced keys a reported cast as
    "<caster GUID>-<caster level>-<spell ID>", the shape the standalone Rank Sentinel add-on records and sends
    with NOTIFY, so the two never report the same cast twice; it is forgotten whenever announcedVersion stops
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
		optOutOffered = {}, -- caster GUID -> true, sent the one-time opt-out number whisper
		announced = {},
		announcedVersion = "",
		importedStandalone = false, -- MIGRATION (remove after 2026-12-08): the standalone add-on's settings were copied in
	},
})
