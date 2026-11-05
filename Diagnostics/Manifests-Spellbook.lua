local ADDON_NAME, ns = ...

local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

local function Global(name)
	return {
		name,
		function()
			return _G[name] ~= nil
		end,
	}
end

local function Method(namespace, name, label)
	return {
		label or (namespace .. "." .. name),
		function()
			local owner = _G[namespace]
			return type(owner) == "table" and type(owner[name]) == "function"
		end,
	}
end

local function Template(name)
	return {
		"Template " .. name,
		function()
			return type(C_XMLUtil) == "table" and C_XMLUtil.GetTemplateInfo(name) ~= nil
		end,
	}
end

--[[
	Existence and shape checks only: read-only, no side effects. One row per API the Spellbook calls or
	guards. Every pair the add-on picks between at load is listed as both halves, and a FAIL on one half is
	the report working: it says which branch this client took. The spellbook read (C_SpellBook's skill lines,
	or the spell tab globals) picks ns.ForEachClassSpell; the tooltip reads (C_TooltipInfo's getters, or the
	hidden scan tooltip's Set methods) pick ns.ReadTooltipLines and ns.GetTrainerServiceSpellId; the macro
	slot limits come from Constants.MacroConsts or the MAX_*_MACROS globals; the spellbook itself is
	Blizzard_PlayerSpells with Features/Spellbook/Spellbook-Tabs.lua on the Retail engine, SpellBookFrame on the Classic engine;
	the page's header, settings cog and paging arrows each fall back without their template.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	Method("C_AddOns", "GetAddOnMetadata"),
	Method("C_AddOns", "GetAddOnInfo"),
	Method("C_AddOns", "GetNumAddOns"),
	Method("C_AddOns", "IsAddOnLoaded"),
	Method("C_Seasons", "GetActiveSeason"),
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},

	-- The spellbook read, Retail-engine half.
	Method("C_SpellBook", "GetNumSpellBookSkillLines"),
	Method("C_SpellBook", "GetSpellBookSkillLineInfo"),
	Method("C_SpellBook", "GetSpellBookItemInfo"),
	{
		"Enum.SpellBookSpellBank.Player and Enum.SpellBookItemType.Spell",
		function()
			return type(Enum) == "table"
				and type(Enum.SpellBookSpellBank) == "table"
				and Enum.SpellBookSpellBank.Player ~= nil
				and type(Enum.SpellBookItemType) == "table"
				and Enum.SpellBookItemType.Spell ~= nil
		end,
	},
	-- The spellbook read, Classic-engine half.
	Global("GetNumSpellTabs"),
	Global("GetSpellTabInfo"),
	Global("GetSpellBookItemInfo"),
	Global("GetSpellBookItemName"),
	Global("GetSpellBookItemTexture"),
	Global("IsPassiveSpell"),
	Global("BOOKTYPE_SPELL"),
	-- MoP Classic's Call Pet flyout, which the Classic-engine read lists as one macro.
	Global("GetFlyoutInfo"),
	Global("GetFlyoutSlotInfo"),

	-- Every spell the page names, sorts or builds a macro for.
	Method("C_Spell", "GetSpellName"),
	Method("C_Spell", "GetSpellInfo"),
	Method("C_Spell", "GetSpellTexture"),
	Method("C_Spell", "GetSpellSubtext"),
	Method("C_Spell", "IsSpellHarmful"),
	Method("C_Spell", "SpellHasRange"),
	Method("C_Spell", "IsSpellPassive"),
	Method("C_Spell", "RequestLoadSpellData"),
	Method("C_Spell", "GetSpellLevelLearned", "C_Spell.GetSpellLevelLearned (guarded)"),
	-- Sorting a spell with a minute's cooldown under Offensive Cooldowns (Page-Categories.lua).
	Global("GetSpellBaseCooldown"),
	-- ns.IsSpellKnown and ns.IsPlayerSpell (Features/Utilities.lua) read these, never the deprecated globals.
	Method("C_SpellBook", "IsSpellInSpellBook"),
	Method("C_SpellBook", "IsSpellKnown"),
	Method("C_CreatureInfo", "GetCreatureFamilyInfo"),
	Method("C_Item", "GetItemSpell"),
	Global("GetShapeshiftFormInfo"),
	Global("GetNumShapeshiftForms"),
	Global("GetInventoryItemLink"),
	Global("GetInventoryItemTexture"),
	-- The Shoot macro (Ranged-Attacks.lua): the ranged weapon worn, and the [worn:] name of each weapon type.
	Method("C_Item", "GetItemInfoInstant"),
	{
		"C_Item.GetItemSubClassInfo or GetItemSubClassInfo",
		function()
			return (type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function")
				or type(GetItemSubClassInfo) == "function"
		end,
	},

	-- The tooltip reads, Retail-engine half.
	Method("C_TooltipInfo", "GetSpellByID"),
	Method("C_TooltipInfo", "GetItemByID"),
	Method("C_TooltipInfo", "GetInventoryItem"),
	Method("C_TooltipInfo", "GetTrainerService"),
	-- The macro buttons' own tooltip.
	Method("GameTooltip", "SetSpellByID"),
	-- The tooltip reads, Classic-engine half: the scan tooltip's methods, probed on GameTooltip, which has them too.
	Method("GameTooltip", "SetInventoryItem", "Hidden scan tooltip SetInventoryItem (legacy)"),
	Method("GameTooltip", "SetTrainerService", "Hidden scan tooltip SetTrainerService (legacy)"),
	Method("GameTooltip", "GetSpell", "Hidden scan tooltip GetSpell (legacy)"),
	Method("GameTooltip", "SetHyperlink", "Hidden scan tooltip SetHyperlink (legacy)"),

	-- Writing and placing the macros.
	Global("CreateMacro"),
	Global("EditMacro"),
	Global("DeleteMacro"),
	Global("GetMacroInfo"),
	Global("GetNumMacros"),
	-- The macro slot limits, Retail-engine half then Classic-engine half.
	{
		"Constants.MacroConsts",
		function()
			return type(Constants) == "table" and type(Constants.MacroConsts) == "table"
		end,
	},
	Global("MAX_ACCOUNT_MACROS"),
	Global("MAX_CHARACTER_MACROS"),
	Global("PickupMacro"),
	Global("GetActionInfo"),
	Global("GetActionText"),
	Global("InCombatLockdown"),
	-- The in-combat and slots-full errors, and the Hide Errors option's /run line.
	Method("UIErrorsFrame", "AddMessage"),
	Method("UIErrorsFrame", "Clear"),
	-- The Mute Errors option's sound settings.
	Method("C_CVar", "GetCVar"),
	Method("C_CVar", "SetCVar"),

	-- Recording trainer spells.
	Global("GetNumTrainerServices"),
	Global("GetTrainerServiceLevelReq"),
	Global("IsTradeskillTrainer"),
	-- a Hunter trainer's pet abilities are left out where the client can tell them apart
	{
		"IsTrainerServiceLearnSpell (guarded)",
		function()
			return type(IsTrainerServiceLearnSpell) == "function"
		end,
	},
	Method("C_Trainer", "GetTrainerType"),
	{
		"Enum.TrainerType",
		function()
			return type(Enum) == "table" and type(Enum.TrainerType) == "table"
		end,
	},

	-- The Retail-engine spellbook and Features/Spellbook/Spellbook-Tabs.lua, whose tab hides under the gamepad UI.
	Global("PlayerSpellsFrame"),
	Method("EventRegistry", "RegisterCallback"),
	Global("RunNextFrame"),
	Method("InputUtil", "IsGamepadUIEnabled", "InputUtil.IsGamepadUIEnabled (guarded)"),
	Global("HideUIPanel"),
	-- The tab art Spellbook-Tabs.lua draws (its SKIN atlases).
	{
		"Atlases spellbook-Tab-Frame (tab, active, glow)",
		function()
			return type(C_Texture) == "table"
				and type(C_Texture.GetAtlasInfo) == "function"
				and C_Texture.GetAtlasInfo("spellbook-Tab-Frame-glow-gradient-C60") ~= nil
		end,
	},
	-- The page's controls (Spellbook-Controls.lua), each modern template guarded with a fallback.
	Template("WowStyle1DropdownTemplate"),
	Template("SearchBoxTemplate"),
	Template("InputBoxTemplate"),
	Global("PixelUtil"),
	Global("StaticPopup_Show"),
	-- The macro list's item macros (Consumable-Macros.lua) and What's Next?'s grimoire names.
	Global("GetMacroIndexByName"),
	Global("GetMacroBody"),
	Global("GetMacroItem"),
	Method("C_Item", "GetItemIconByID"),
	Method("C_Item", "GetItemNameByID"),
	-- The spell-ranks tooltip (Spell-Ranks-Tooltip.lua) adds its lines per showing and resets on clear.
	{
		"GameTooltip OnTooltipCleared",
		function()
			return type(GameTooltip) == "table" and GameTooltip:HasScript("OnTooltipCleared")
		end,
	},
	-- The Classic-engine spellbook.
	Global("SpellBookFrame"),
	Global("SpellBookSkillLineTab1"),
	Global("UISpecialFrames"),
	Template("PortraitFrameTemplate"),
	Template("BasicFrameTemplate"),
	{
		"SpellBookFrame.Update",
		function()
			return type(SpellBookFrame) == "table" and type(SpellBookFrame.Update) == "function"
		end,
	},
	Global("hooksecurefunc"),
	-- The page itself, on either book.
	Method("C_XMLUtil", "GetTemplateInfo"),
	Method("C_Texture", "GetAtlasInfo"),
	Method("MenuUtil", "CreateContextMenu"),
	-- An open menu holds the button's tooltip back, and a radio keeps the menu open by answering Refresh.
	Method("Menu", "GetManager", "Menu.GetManager (guarded)"),
	{
		"MenuResponse.Refresh",
		function()
			return type(MenuResponse) == "table" and MenuResponse.Refresh ~= nil
		end,
	},
	--[[
		The Conditionals (Features/Spellbook/Macro-Builder/Conditionals.lua and Features/Spellbook/Macro-Builder/Conditionals-Panel.lua,
		with the shared Docked-Panel.lua and Panel-Widgets.lua): the
		Spec conditions are offered only where a talent group count says the character has two specs, the
		Retail-engine count first, then the Classic-engine one, and the menu marks the spec active now, read the
		same two ways; a spell dropped on a slot is read off the cursor;
		the panel docks with its own close and Add Condition buttons.
	]]
	Method("C_SpecializationInfo", "GetNumSpecGroups", "C_SpecializationInfo.GetNumSpecGroups (guarded)"),
	Global("GetNumTalentGroups"),
	Method("C_SpecializationInfo", "GetActiveSpecGroup", "C_SpecializationInfo.GetActiveSpecGroup (guarded)"),
	Global("GetActiveTalentGroup"),
	Global("GetCursorInfo"),
	Global("ClearCursor"),
	Global("GetMacroSpell"),
	Template("UIPanelCloseButton"),
	Template("UIPanelButtonTemplate"),
	--[[
		The What's Next? tab (Features/Spellbook/Whats-Next/Whats-Next.lua and Features/Spellbook/Whats-Next/Whats-Next-Page.lua): a
		talent's level is read off its tier in the Classic-engine talent tree; shift-click links a row's spell
		in chat; the window's tabs under its bottom edge, the Classic tab first, then the shared panel tab.
	]]
	{
		"GetNumTalentTabs (guarded, ns.GetNumTalentTabs)",
		function()
			return type(GetNumTalentTabs) == "function"
		end,
	},
	Global("GetNumTalents"),
	Global("GetTalentInfo"),
	Method("C_Spell", "GetSpellLink", "C_Spell.GetSpellLink (guarded)"),
	Global("IsModifiedClick"),
	Global("ChatEdit_InsertLink"),
	Template("CharacterFrameTabButtonTemplate"),
	Template("PanelTabButtonTemplate"),
	Global("PanelTemplates_SelectTab"),
	Global("PanelTemplates_DeselectTab"),
	Global("PanelTemplates_TabResize"),
	--[[
		The Pet What's Next? tab (Features/Spellbook/Whats-Next/Whats-Next-Pet.lua): the hunter's pet out, its family's ID
		(UnitCreatureFamily's second return, read where the client gives it), the abilities the pet knows from
		its spellbook (C_SpellBook.IsSpellKnown, listed above), its training points where the client has them,
		whether a warlock's grimoire is in the bags, and the zones the tooltip names for the beasts that teach
		an ability.
	]]
	{
		"HasPetUI (guarded)",
		function()
			return type(HasPetUI) == "function"
		end,
	},
	Global("UnitCreatureFamily"),
	Method("C_Item", "GetItemCount"),
	{
		"Enum.SpellBookSpellBank.Pet",
		function()
			return type(Enum) == "table"
				and type(Enum.SpellBookSpellBank) == "table"
				and Enum.SpellBookSpellBank.Pet ~= nil
		end,
	},
	{
		"GetPetTrainingPoints (guarded)",
		function()
			return type(GetPetTrainingPoints) == "function"
		end,
	},
	Method("C_Map", "GetAreaInfo"),
	--[[
		The Pet Spell Book tab (Features/Spellbook/Whats-Next/Pet-Spellbook.lua): how many spells the pet's book holds, then
		each slot read, its autocast read and the slot picked up through C_SpellBook where the client has its
		item calls (the Retail engine), else through the older globals (Era and TBC). One route passing whole is
		enough; the report says which one this client has.
	]]
	{
		"C_SpellBook.HasPetSpells or HasPetSpells",
		function()
			return type(C_SpellBook.HasPetSpells) == "function" or type(HasPetSpells) == "function"
		end,
	},
	{
		"Pet spellbook slots (C_SpellBook item calls or the older globals)",
		function()
			local modern = type(C_SpellBook.GetSpellBookItemInfo) == "function"
				and type(C_SpellBook.PickupSpellBookItem) == "function"
			local older = type(GetSpellBookItemInfo) == "function"
				and type(GetSpellBookItemName) == "function"
				and type(GetSpellBookItemTexture) == "function"
				and type(IsPassiveSpell) == "function"
				and type(GetSpellAutocast) == "function"
				and type(PickupSpellBookItem) == "function"
				and type(bit) == "table"
			return modern or older
		end,
	},
	-- The C_SpellBook route's autocast read: without it, every pet spell shows autocast off.
	Method("C_SpellBook", "GetSpellBookItemAutoCast", "C_SpellBook.GetSpellBookItemAutoCast (guarded)"),

	Method("Settings", "OpenToCategory"),
	--[[
		The key binding: its toggle (GoodToGo_ToggleSpellbook) opens the add-on's own page, and the
		Spellbook panel shows the bound key. Then the three routes ns:OpenKeyBindings tries for the
		Set Key button, in its order; one route passing whole is enough, and the report says which one this
		client has.
	]]
	Global("GetBindingKey"),
	{
		"GetBindingText (guarded)",
		function()
			return type(GetBindingText) == "function"
		end,
	},
	{
		"Settings.KEYBINDINGS_CATEGORY_ID",
		function()
			return type(Settings) == "table" and Settings.KEYBINDINGS_CATEGORY_ID ~= nil
		end,
	},
	Method("SettingsPanel", "GetCategoryList"),
	{
		"SettingsPanel category list GetAllCategories",
		function()
			if not (type(SettingsPanel) == "table" and type(SettingsPanel.GetCategoryList) == "function") then
				return false
			end
			local ok, list = pcall(SettingsPanel.GetCategoryList, SettingsPanel)
			return ok and type(list) == "table" and type(list.GetAllCategories) == "function"
		end,
	},
	{
		"KeyBindingFrame_LoadUI (legacy)",
		function()
			return type(KeyBindingFrame_LoadUI) == "function" or type(KeyBindingFrame) == "table"
		end,
	},
	Global("ShowUIPanel"),
	-- MIGRATION (remove after 2026-12-03): moving a key from the binding's old name at login.
	Global("SetBinding"),
	Global("SaveBindings"),
	Global("GetCurrentBindingSet"),
	Method("C_Timer", "After"),
})

--------------------------------------------------------------------------------
-- Shared Reads
--------------------------------------------------------------------------------

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

local function Shown(text)
	return (tostring(text):gsub("\r?\n", "\\n"):gsub("|", "||"))
end

-- A value that may be secret on WoW Forever, as text that never tests it.
local function PlainText(value)
	if ns.IsPlain(value) then
		return tostring(value)
	end
	return "<secret>"
end

-- A yes or no that may be secret on WoW Forever, read without testing it.
local function PlainYesNo(value)
	if ns.IsPlain(value) then
		return YesNo(value)
	end
	return "<secret>"
end

-- How many of the spell IDs this client has no name for yet: those rows wait on SPELL_DATA_LOAD_RESULT.
local function UnnamedCount(ids)
	local count = 0
	for _, id in ipairs(ids) do
		if not C_Spell.GetSpellName(id) then
			count = count + 1
		end
	end
	return count
end

local function PlayerClass()
	return select(2, UnitClass("player"))
end

local function ClassLists()
	return ns.CLASS_SPELL_LISTS and ns.CLASS_SPELL_LISTS[PlayerClass()]
end

-- An entry of a class list is a spell ID, or a table of every rank's ID.
local function EntryIds(entry)
	return type(entry) == "table" and entry or { entry }
end

-- How many of a list's entries this client names, and the IDs of the ones it doesn't.
local function ResolvedCount(entries)
	local resolved, missing = 0, {}
	for _, entry in ipairs(entries or {}) do
		local named = false
		for _, id in ipairs(EntryIds(entry)) do
			if C_Spell.GetSpellName(id) then
				named = true
			end
		end
		if named then
			resolved = resolved + 1
		else
			missing[#missing + 1] = tostring(EntryIds(entry)[1])
		end
	end
	return resolved, missing
end

local function ListLine(label, entries)
	local resolved, missing = ResolvedCount(entries)
	local line = string.format("  %s: %d of %d named", label, resolved, #(entries or {}))
	if #missing > 0 then
		line = line .. " (no name for " .. table.concat(missing, ", ") .. ")"
	end
	return line
end

-- The class lists of spell IDs Features/Spellbook/Class-Config.lua resolves to names.
local LIST_KEYS = {
	"mouseoverEnemy",
	"mouseoverFriend",
	"resurrect",
	"utility",
	"attacks",
	"crowdControl",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"heals",
	"noCooldown",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"threat",
	"buffs",
	"cursor",
	"stealth",
	"noToggle",
	"extraSpells",
}
-- Every list of spell IDs the data files hold: the channeled lists no feature reads still ship, so Validate Data checks them.
local DATA_LIST_KEYS = {
	"mouseoverEnemy",
	"mouseoverFriend",
	"resurrect",
	"utility",
	"attacks",
	"crowdControl",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"heals",
	"noCooldown",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"threat",
	"buffs",
	"cursor",
	"channeled",
	"stealth",
	"noToggle",
	"extraSpells",
}
local PER_SPELL_OPTIONS = {
	"cursor",
	"focus",
	"pet",
	"stance",
	"petAttack",
	"stopCast",
	"startAttack",
	"noToggle",
	"targetRank",
	"fixedRank",
	"targetEnemy",
	"targetFriend",
	"combatOnly",
	"noCombat",
	"oncePerCombat",
	"oncePerTarget",
	"stopAttack",
	"stopIfChanneling",
	"stopIfStealthed",
	"hideErrors",
	"muteErrors",
	"cancelForm",
	"autoShot",
	"groupVersion",
	"useItems",
	"groupedSpells",
	"targetPriority",
	"conditionals",
	"castSequence",
	"castSequenceEnd",
	"castSequenceReset",
}

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------

--[[
	The spells the page gates options on for the player's class: the ranged attack the after-cast option
	starts, the Warrior stances a stance option switches to, each summon spell with the pet ability it
	casts while that pet is out, and the ranged weapon attacks the Shoot macro folds when more than one is
	known. Built from the flavor's data, so it follows the data folder this client loaded. The probe reads
	its own list: the shared one holds other features' rows in their own shape.
]]
local SPELLBOOK_SPELLS = {}
do
	local lists = ClassLists()
	if lists and lists.autoShot then
		SPELLBOOK_SPELLS[#SPELLBOOK_SPELLS + 1] = { label = "ranged attack", id = lists.autoShot }
	end
	for _, id in ipairs(lists and lists.stanceSlots or {}) do
		SPELLBOOK_SPELLS[#SPELLBOOK_SPELLS + 1] = { label = "stance", id = id }
	end
	for summonId, pet in pairs(lists and lists.petAbilities or {}) do
		SPELLBOOK_SPELLS[#SPELLBOOK_SPELLS + 1] = { label = "summon", id = summonId }
		SPELLBOOK_SPELLS[#SPELLBOOK_SPELLS + 1] = { label = "pet ability", id = pet.abilityId }
	end
	for _, attack in ipairs(ns.RANGED_ATTACKS or {}) do
		SPELLBOOK_SPELLS[#SPELLBOOK_SPELLS + 1] = { label = "ranged weapon attack", id = attack.id }
	end
end
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_SPELLS, SPELLBOOK_SPELLS)

local function SpellLine(spell)
	return string.format(
		"  %s %d: %s, IsPlayerSpell %s, IsSpellKnown %s",
		spell.label,
		spell.id,
		tostring(C_Spell.GetSpellName(spell.id) or "NIL"),
		tostring(ns.IsPlayerSpell(spell.id)),
		tostring(ns.IsSpellKnown(spell.id))
	)
end

--------------------------------------------------------------------------------
-- Page Context
--------------------------------------------------------------------------------

--[[
	The Retail-engine tab hides whenever the book isn't visible, the gamepad UI is on or the Spellbook is off
	(SpellbookTabs:Sync in Features/Spellbook/Spellbook-Tabs.lua), and steps around other add-ons' launchers,
	each watched for showing.
]]
local function RetailBookLine(lines, spellbookTabs, tab)
	local book = spellbookTabs.book
	if not book then
		return
	end
	lines[#lines + 1] = string.format(
		"  book visible %s; gamepad UI %s; tab button shown %s; other add-ons' launchers watched %d",
		YesNo(book:IsVisible()),
		YesNo(InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()),
		YesNo(tab and tab.button and tab.button:IsShown()),
		CountKeys(spellbookTabs.hookedForeign)
	)
	-- placed right of the native tabs, or down the book's right edge once the row reaches the search box
	local left, bottom
	if tab and tab.button then
		left, bottom = tab.button:GetRect()
	end
	lines[#lines + 1] = string.format(
		"  tab button at left %s, bottom %s, scale %s",
		left and string.format("%.0f", left) or "not placed",
		bottom and string.format("%.0f", bottom) or "not placed",
		tab and tab.button and string.format("%.2f", tab.button:GetScale()) or "none"
	)
end

--[[
	The Classic-engine tab lines up under the class's last skill line tab, falling back to the last one shown,
	and hides over the pet book or another of the book's tabs (Features/Spellbook/Spellbook-Host-Classic.lua).
]]
local function ClassicBookLine(lines)
	local count = GetNumSpellTabs and GetNumSpellTabs() or 0
	local anchor = _G["SpellBookSkillLineTab" .. count]
	lines[#lines + 1] = string.format(
		"  the tab lines up under skill line tab %d, which is shown %s (else under the last shown tab)",
		count,
		YesNo(anchor and anchor:IsShown())
	)
end

-- The window's tabs, made only with a tab template to hang them from, and its scale, shrunk to fit the screen.
local function WindowLine(lines)
	local window = _G.GoodToGoSpellbookFrame
	if not window then
		return
	end
	lines[#lines + 1] = string.format(
		"  window tabs made %s (CharacterFrameTabButtonTemplate %s, PanelTabButtonTemplate %s), scale %.2f",
		tostring(window.numTabs or 0),
		YesNo(ns.HasTemplate("CharacterFrameTabButtonTemplate")),
		YesNo(ns.HasTemplate("PanelTabButtonTemplate")),
		window:GetScale()
	)
end

local function HostLines(lines)
	local spellbookTabs = ns.SpellbookTabs
	if spellbookTabs then
		local tab = spellbookTabs.byId[ADDON_NAME]
		lines[#lines + 1] = string.format(
			"Spellbook: Retail-engine; Blizzard_PlayerSpells loaded %s, attached %s, tab registered %s; page window built %s, shown %s",
			YesNo(C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells")),
			YesNo(spellbookTabs.book ~= nil),
			YesNo(tab ~= nil),
			YesNo(_G.GoodToGoSpellbookFrame ~= nil),
			YesNo(_G.GoodToGoSpellbookFrame and _G.GoodToGoSpellbookFrame:IsShown())
		)
		RetailBookLine(lines, spellbookTabs, tab)
	else
		lines[#lines + 1] = string.format(
			"Spellbook: Classic-engine; SpellBookFrame present %s, shown %s, book type %s (the tab shows for %s or none); page window built %s, shown %s",
			YesNo(SpellBookFrame ~= nil),
			YesNo(SpellBookFrame and SpellBookFrame:IsShown()),
			tostring(SpellBookFrame and SpellBookFrame.bookType),
			tostring(BOOKTYPE_SPELL),
			YesNo(_G.GoodToGoSpellbookFrame ~= nil),
			YesNo(_G.GoodToGoSpellbookFrame and _G.GoodToGoSpellbookFrame:IsShown())
		)
		ClassicBookLine(lines)
	end
	WindowLine(lines)
	lines[#lines + 1] = string.format(
		"Window tabs: What's Next? loaded %s; Pet Spell Book offered to this class %s; Pet What's Next? offered (data for this class's pets) %s",
		YesNo(ns.BuildWhatsNextPage ~= nil),
		YesNo(ns.HasPetSpellbook and ns.HasPetSpellbook()),
		YesNo(ns.HasWhatsNextPet and ns.HasWhatsNextPet())
	)
end

local function ClassListLines(lines)
	local lists = ClassLists()
	if not lists then
		lines[#lines + 1] = "Class lists: none for this class on this flavor"
		return
	end
	lines[#lines + 1] = "Class lists:"
	for _, key in ipairs(LIST_KEYS) do
		lines[#lines + 1] = ListLine(key, lists[key])
	end
	local stances, stancesNamed = 0, 0
	for spellId, stanceIds in pairs(lists.stances or {}) do
		stances = stances + 1
		local named = C_Spell.GetSpellName(spellId) ~= nil
		for _, stanceId in ipairs(stanceIds) do
			named = named and C_Spell.GetSpellName(stanceId) ~= nil
		end
		stancesNamed = stancesNamed + (named and 1 or 0)
	end
	lines[#lines + 1] = string.format("  stances: %d of %d named with all their stances", stancesNamed, stances)
	-- the forms a spell needs, which head its run under Sort By Category
	local formIds, seenForm = {}, {}
	for _, ids in pairs(lists.forms or {}) do
		for _, id in ipairs(ids) do
			if not seenForm[id] then
				seenForm[id] = true
				formIds[#formIds + 1] = id
			end
		end
	end
	table.sort(formIds)
	lines[#lines + 1] = ListLine("forms (the forms a spell needs)", formIds)
	for summonId, pet in pairs(lists.petAbilities or {}) do
		local family = C_CreatureInfo.GetCreatureFamilyInfo(pet.familyId)
		lines[#lines + 1] = string.format(
			"  pet: %s casts %s while [pet:%s] (family %d)",
			tostring(C_Spell.GetSpellName(summonId) or ("NIL " .. summonId)),
			tostring(C_Spell.GetSpellName(pet.abilityId) or ("NIL " .. pet.abilityId)),
			tostring(family and family.name or "NIL"),
			pet.familyId
		)
	end
end

--[[
	The one option the class lists still decide, read off ns.ClassConfig, which resolves them on first use: a
	ranged attack named on this client offers its Start option. The focus copy is the one option a flavor
	decides, asked of ns.OffersOption with an enemy spell. Every other option is offered to every class.
]]
local function ClassGateLines(lines)
	local config = ns.ClassConfig()
	lines[#lines + 1] =
		string.format("Ranged attack for the Add Attack option: %s", tostring(config.autoShot or "none"))
	lines[#lines + 1] =
		string.format("Focus copies offered on this flavor: %s", YesNo(ns.OffersOption({ target = "harm" }, "focus")))
end

-- The stance bar's forms, each by slot as a stance option's [stance:n] counts it.
local function StanceFormLines(lines)
	local forms = {}
	for index = 1, GetNumShapeshiftForms() or 0 do
		local spellID = select(4, GetShapeshiftFormInfo(index))
		forms[#forms + 1] = string.format("%d %s", index, tostring(spellID and C_Spell.GetSpellName(spellID) or "NIL"))
	end
	lines[#lines + 1] =
		string.format("Stance bar forms: %d%s", #forms, #forms > 0 and (" (" .. table.concat(forms, ", ") .. ")") or "")
end

-- How many of the bundled trainer rows apply to this character, as Features/Spellbook/Unlearned-Spells.lua filters them.
local function TrainerRowsForPlayer()
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	local count = 0
	for _, row in ipairs((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}) do
		if (not row.faction or row.faction == faction) and (not row.race or row.race == race) then
			count = count + 1
		end
	end
	return count
end

--[[
	Right-Click For Group Version is offered on a spell only when this client names both halves of its
	GROUP_VERSIONS pair and the spellbook holds the group version, both read by name as the page reads them.
]]
local function GroupVersionLines(lines)
	local learned = {}
	pcall(ns.ForEachClassSpell, function(name)
		if name then
			learned[name] = true
		end
	end)
	local pairsTotal, named, offered = 0, 0, {}
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or {}) do
		pairsTotal = pairsTotal + 1
		local single, group = C_Spell.GetSpellName(singleId), C_Spell.GetSpellName(groupId)
		if single and group then
			named = named + 1
			if learned[single] then
				offered[#offered + 1] =
					string.format("%s -> %s (group version learned %s)", single, group, YesNo(learned[group]))
			end
		end
	end
	table.sort(offered)
	lines[#lines + 1] = string.format("Group versions: %d of %d pairs named on this client", named, pairsTotal)
	for _, line in ipairs(offered) do
		lines[#lines + 1] = "  " .. line
	end
end

local function SpellbookLines(lines)
	local total, byLine, order = 0, {}, {}
	local ok, problem = pcall(ns.ForEachClassSpell, function(_, _, _, lineName, line)
		total = total + 1
		local key = string.format("%s %s", tostring(line), tostring(lineName))
		if not byLine[key] then
			byLine[key] = 0
			order[#order + 1] = key
		end
		byLine[key] = byLine[key] + 1
	end)
	if not ok then
		lines[#lines + 1] = "Spellbook spells: (read failed: " .. Shown(problem) .. ")"
		return
	end
	lines[#lines + 1] = string.format(
		"Spellbook spells (castable, every rank): %d, read through %s",
		total,
		C_SpellBook.GetNumSpellBookSkillLines and "C_SpellBook's skill lines" or "the spell tab globals"
	)
	for _, key in ipairs(order) do
		lines[#lines + 1] = string.format("  skill line %s: %d", key, byLine[key])
	end
end

--[[
	What ns.ForEachClassSpell (Features/Spellbook/Class-Spells.lua) leaves out of the book, read the same way
	it reads it: passives, other entry types, hidden or off-spec skill lines and entries, and, on Classic Era
	outside Season of Discovery, the season's rune abilities its book can list (ID ns.SOD_FIRST_SPELL_ID and
	up). A spell in none of these that is still missing from the page is one the client gave no name.
]]
local function BookSkipLines(lines)
	local hidesOtherSeason = ns.FLAVOR == "Vanilla" and not ns.IS_DISCOVERY
	local function otherSeason(id)
		return hidesOtherSeason and id ~= nil and id >= ns.SOD_FIRST_SPELL_ID
	end
	local skipped = { passive = 0, otherType = 0, hiddenLine = 0, offSpec = 0, otherSeason = 0 }
	local ok, problem = pcall(function()
		if C_SpellBook.GetNumSpellBookSkillLines then
			local bank = Enum.SpellBookSpellBank.Player
			for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
				local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
				if info and (info.shouldHide or info.offSpecID) then
					skipped.hiddenLine = skipped.hiddenLine + info.numSpellBookItems
				elseif info then
					for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
						local item = C_SpellBook.GetSpellBookItemInfo(slot, bank)
						if item and item.itemType ~= Enum.SpellBookItemType.Spell then
							skipped.otherType = skipped.otherType + 1
						elseif item and item.isPassive then
							skipped.passive = skipped.passive + 1
						elseif item and item.isOffSpec then
							skipped.offSpec = skipped.offSpec + 1
						elseif item and otherSeason(item.spellID or item.actionID) then
							skipped.otherSeason = skipped.otherSeason + 1
						end
					end
				end
			end
		else
			for line = 1, GetNumSpellTabs() do
				local _, _, offset, numSlots = GetSpellTabInfo(line)
				for slot = offset + 1, offset + numSlots do
					local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
					if itemType ~= "SPELL" and not (itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID) then
						skipped.otherType = skipped.otherType + 1
					elseif itemType == "SPELL" and IsPassiveSpell(slot, BOOKTYPE_SPELL) then
						skipped.passive = skipped.passive + 1
					elseif itemType == "SPELL" and otherSeason(id) then
						skipped.otherSeason = skipped.otherSeason + 1
					end
				end
			end
		end
	end)
	if not ok then
		lines[#lines + 1] = "  left out of the page: (read failed: " .. Shown(problem) .. ")"
		return
	end
	lines[#lines + 1] = string.format(
		"  left out of the page: passive %d, not a spell %d, hidden or off-spec skill lines %d, off-spec %d; Season of Discovery spells hidden on this client %s (from ID %s), %d in the book",
		skipped.passive,
		skipped.otherType,
		skipped.hiddenLine,
		skipped.offSpec,
		YesNo(hidesOtherSeason),
		tostring(ns.SOD_FIRST_SPELL_ID),
		skipped.otherSeason
	)
end

--[[
	The Call Pet flyout (flyout 9, as Data/Game-IDs names it), which the Classic-engine read lists as
	one macro under its book name, cast as the first of its spells the player knows, and leaves its spells
	out; with none known, the flyout is left out too. MoP Classic's book holds it; Era and TBC have none.
]]

local function CallPetFlyoutLines(lines)
	if ns.SpellbookTabs or type(GetFlyoutInfo) ~= "function" then
		return
	end
	local found = false
	for line = 1, GetNumSpellTabs() do
		local _, _, offset, numSlots = GetSpellTabInfo(line)
		for slot = offset + 1, offset + numSlots do
			local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
			if itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID then
				found = true
			end
		end
	end
	if not found then
		lines[#lines + 1] = "Call Pet flyout: not in the book"
		return
	end
	local _, _, numSlots, isKnown = GetFlyoutInfo(ns.CALL_PET_FLYOUT_ID)
	local members, memberIds = {}, {}
	for flyoutSlot = 1, numSlots or 0 do
		local spellId, _, slotKnown = GetFlyoutSlotInfo(ns.CALL_PET_FLYOUT_ID, flyoutSlot)
		if spellId then
			memberIds[spellId] = true
		end
		members[#members + 1] = string.format(
			"%s %s known %s",
			tostring(spellId),
			tostring(spellId and C_Spell.GetSpellName(spellId) or "NIL"),
			YesNo(slotKnown)
		)
	end
	lines[#lines + 1] = string.format(
		"Call Pet flyout: in the book, flyout known %s, %s slots%s",
		YesNo(isKnown),
		tostring(numSlots),
		#members > 0 and (" (" .. table.concat(members, "; ") .. ")") or ""
	)
	-- the macro the page last built for it, as the page writes it
	for _, macro in ipairs(ns.macros or {}) do
		if memberIds[macro.spellID] and not macro.focus and not macro.copy then
			lines[#lines + 1] = string.format("  page macro %s: %s", Shown(macro.macroName), Shown(macro.body))
		end
	end
end

local function PageListLines(lines)
	local byCategory, order = {}, {}
	local kinds = { unlearned = 0, focus = 0, copy = 0, hidden = 0 }
	for _, macro in ipairs(ns.macros or {}) do
		local category = tostring(macro.category)
		if not byCategory[category] then
			byCategory[category] = 0
			order[#order + 1] = category
		end
		byCategory[category] = byCategory[category] + 1
		for kind in pairs(kinds) do
			if macro[kind] then
				kinds[kind] = kinds[kind] + 1
			end
		end
	end
	local consumablesOk, consumables = pcall(ns.ConsumablePageMacros)
	-- hidden: a grouped spell a later one replaced, a folded specialization or ranged attack, still rewritten
	lines[#lines + 1] = string.format(
		"Page list (as of the page's last redraw): %d macros; unlearned %d, focus copies %d, Duplicate copies %d, kept off the page %d; Consumable Macros shown %s",
		#(ns.macros or {}),
		kinds.unlearned,
		kinds.focus,
		kinds.copy,
		kinds.hidden,
		consumablesOk and tostring(#consumables) or ("(read failed: " .. Shown(consumables) .. ")")
	)
	if #(ns.macros or {}) == 0 then
		lines[#lines + 1] =
			"  (empty: the page fills its list when it first opens, so open the Spellbook page and run this again)"
	end
	for _, category in ipairs(order) do
		lines[#lines + 1] = string.format("  %s: %d", category, byCategory[category])
	end
	local hidden = {}
	for _, macro in ipairs(ns.macros or {}) do
		if macro.hidden then
			hidden[#hidden + 1] = Shown(macro.label or macro.name)
		end
	end
	if #hidden > 0 then
		lines[#lines + 1] = "  kept off the page: " .. table.concat(hidden, ", ")
	end
	local byKind = {}
	for _, kind in ipairs(ns.MACRO_KINDS) do
		local count = 0
		for _, macro in ipairs(ns.macros or {}) do
			if macro.kind == kind.key and not macro.focus then
				count = count + 1
			end
		end
		byKind[#byKind + 1] = kind.key .. "=" .. count
	end
	lines[#lines + 1] = "  by kind: " .. table.concat(byKind, ", ")
	--[[
		A rank choice is offered only on a spell with more than one rank whose learn level is known (the trainer
		data, this character's trainers, then the client's own lookup where it has one)
	]]
	local fixed, dynamic = 0, 0
	for _, macro in ipairs(ns.macros or {}) do
		if not macro.focus then
			fixed = fixed + (ns.OffersFixedRank(macro) and 1 or 0)
			dynamic = dynamic + (ns.OffersTargetRank(macro) and 1 or 0)
		end
	end
	lines[#lines + 1] = string.format(
		"  ranks: a fixed rank offered on %d, Dynamic Rank on %d; client learn-level lookup %s",
		fixed,
		dynamic,
		YesNo(C_Spell.GetSpellLevelLearned ~= nil)
	)
end

-- Each value of field across rows, as "key=count", order's keys first.
local function CountBy(rows, field, order)
	local counts, parts = {}, {}
	for _, row in ipairs(rows) do
		local key = tostring(row[field])
		counts[key] = (counts[key] or 0) + 1
	end
	for _, key in ipairs(order or {}) do
		parts[#parts + 1] = key .. "=" .. (counts[key] or 0)
		counts[key] = nil
	end
	for key, count in pairs(counts) do
		parts[#parts + 1] = key .. "=" .. count
	end
	return table.concat(parts, ", ")
end

--[[
	The filter box text and the filter each open page holds: the Spell Book page's (ns.spellbookPages), with
	the page of its strip it shows, and, found among the window's children by the rows they carry, the What's
	Next? pages'. A row a filter leaves out, or on another page of the strip, is missing only from that page.
]]
local function PageFilterLines(lines)
	local filters = {}
	for _, page in ipairs(ns.spellbookPages or {}) do
		local strip = page.pagingControls
		filters[#filters + 1] = string.format(
			'Spell Book shown %s, text "%s", filter %s, page %s of %s',
			YesNo(page:IsVisible()),
			Shown(page.filterText or ""),
			tostring(page.groupFilter or "all"),
			tostring(strip and strip:GetCurrentPage()),
			tostring(strip and strip:GetMaxPages())
		)
	end
	local window = _G.GoodToGoSpellbookFrame
	for _, child in ipairs(window and { window:GetChildren() } or {}) do
		if child.isPetPage ~= nil and child.rows then
			filters[#filters + 1] = string.format(
				'%s shown %s, text "%s", source %s, %d rows',
				child.isPetPage and "a pet page" or "What's Next?",
				YesNo(child:IsVisible()),
				Shown(child.filterText or ""),
				tostring(child.sourceFilter or "all"),
				#child.rows
			)
		end
	end
	lines[#lines + 1] = "Page filters: " .. (filters[1] and table.concat(filters, "; ") or "no page built yet")
end

-- The spell IDs What's Next? builds its rows from: the trainer rows for you, the recorded ones, the extra spells.
local function WhatsNextSourceIds()
	local ids = {}
	for _, row in ipairs(ns.ClassTrainerRows()) do
		ids[#ids + 1] = row.id
	end
	for id in pairs(ns.RecordedTrainerSpellLevels()) do
		ids[#ids + 1] = id
	end
	for _, entry in ipairs(ns.ClassExtraSpells()) do
		ids[#ids + 1] = type(entry) == "table" and entry[1] or entry
	end
	return ids
end

--[[
	What's Next? (Features/Spellbook/Whats-Next/Whats-Next.lua): its settings, the talent tree its talent
	levels come from (none on the Retail engine), and the rows it builds now by status and source. A spell
	whose name isn't loaded yet is skipped until it arrives, and counted here; Known and talent rows show only
	with their settings on.
]]
local function WhatsNextLines(lines, profile)
	if not ns.WhatsNextRows then
		lines[#lines + 1] = "What's Next?: not loaded"
		return
	end
	lines[#lines + 1] = string.format(
		"What's Next?: sort by %s, show known %s, show talents %s; talent tree tabs %s",
		tostring(profile.whatsNextSort),
		OnOff(profile.whatsNextShowKnown),
		OnOff(profile.whatsNextShowTalents),
		tostring(ns.GetNumTalentTabs())
	)
	local ok, rows = pcall(ns.WhatsNextRows)
	if not ok then
		lines[#lines + 1] = "  rows: (read failed: " .. Shown(rows) .. ")"
		return
	end
	lines[#lines + 1] = string.format(
		"  rows %d from %d trainer rows for you, %d recorded, %d class list extra spells (%d with no spell data yet); by status %s; by source %s",
		#rows,
		#ns.ClassTrainerRows(),
		CountKeys(ns.RecordedTrainerSpellLevels()),
		#ns.ClassExtraSpells(),
		UnnamedCount(WhatsNextSourceIds()),
		CountBy(rows, "status", ns.WHATS_NEXT_STATUSES),
		CountBy(rows, "source", ns.WHATS_NEXT_SOURCES)
	)
end

--[[
	The pet tabs (Features/Spellbook/Whats-Next/Whats-Next-Pet.lua and Pet-Spellbook.lua): the pet out as they
	read it, its spellbook's size and the rows the Pet Spell Book lists from it, and the Pet What's Next?
	settings and rows by status, with the abilities skipped while their names aren't loaded. With no pet out, a
	hunter's statuses are its own Beast Training, and nothing reads as known for a warlock.
]]
local function PetLines(lines, profile)
	if not ns.WhatsNextPet then
		return
	end
	local hasUI, isHunterPet
	if HasPetUI then
		hasUI, isHunterPet = HasPetUI()
	end
	local pet = ns.WhatsNextPet(true)
	local remaining, total = ns.WhatsNextPetTrainingPoints()
	local bookOk, bookRows = pcall(ns.PetSpellbookRows)
	lines[#lines + 1] = string.format(
		"Pet: out %s, pet UI %s, hunter pet %s; level %s, family %s (ID %s); training points %s of %s; pet spellbook slots %s, Pet Spell Book rows %s",
		YesNo(UnitExists("pet")),
		YesNo(hasUI),
		YesNo(isHunterPet),
		PlainText(pet and pet.level),
		PlainText(pet and pet.family),
		tostring(pet and pet.familyID or "none"),
		tostring(remaining),
		tostring(total),
		tostring(ns.GetNumPetSpells and ns.GetNumPetSpells()),
		bookOk and tostring(#bookRows) or ("(read failed: " .. Shown(bookRows) .. ")")
	)
	if not (ns.HasWhatsNextPet and ns.HasWhatsNextPet()) then
		return
	end
	local abilityIds = {}
	local abilities = PlayerClass() == "WARLOCK" and ns.DEMON_ABILITIES or ns.PET_ABILITIES
	for _, row in ipairs(abilities or {}) do
		abilityIds[#abilityIds + 1] = row.id
	end
	local ok, rows = pcall(ns.WhatsNextPetRows)
	lines[#lines + 1] = string.format(
		"  Pet What's Next?: show known %s, show other families %s; %s; %d of %d abilities with no spell data yet",
		OnOff(profile.whatsNextPetShowKnown),
		OnOff(profile.whatsNextPetShowOtherFamilies),
		ok and string.format("rows %d, by status %s", #rows, CountBy(rows, "status", ns.WHATS_NEXT_PET_STATUSES))
			or ("rows: (read failed: " .. Shown(rows) .. ")"),
		UnnamedCount(abilityIds),
		#abilityIds
	)
end

-- The Conditionals and Cast Sequence panels docked beside the window, and a Conditionals spell pick under way.
local function DockedPanelLine(lines)
	local conditionals, castSequence = _G.GoodToGoConditionalsPanel, _G.GoodToGoCastSequencePanel
	lines[#lines + 1] = string.format(
		"Docked panels: Conditionals built %s, shown %s, picking a spell %s; Cast Sequence built %s, shown %s",
		YesNo(conditionals ~= nil),
		YesNo(conditionals and conditionals:IsShown()),
		YesNo(ns.IsPickingConditionalSpell and ns.IsPickingConditionalSpell()),
		YesNo(castSequence ~= nil),
		YesNo(castSequence and castSequence:IsShown())
	)
end

--[[
	The state most likely to explain a "the tab isn't there", "a spell is missing" or "an option isn't offered"
	report: who the player is and which data folder and spellbook this client gave them, whether the page's tab
	and page exist, what hides the Retail-engine tab and where it sits, what the Classic-engine tab lines up
	under, which window tabs this character gets and whether they were made, how much of the class lists this
	client could name (an ID it can't name never matches, so that spell loses its options), the spells,
	stance bar forms and class and flavor gates the options depend on, the group versions on offer, what the
	spellbook holds by skill line, what the page leaves out of it and its Call Pet flyout, every page setting
	and filter and the page of the strip it shows, which class options apply, the unlearned-spells sources and
	how many still wait on spell data, the What's Next? and pet tabs' settings and rows, the options panel and
	key binding routes, the docked panels, and what the page last listed, with the macros kept off it and the
	rank choices it offers. Existence/value reads only.
]]
function ns:BuildPageContextReport()
	local lines = { ns.GetDiagnosticClientHeader(), "" }
	local _, race = UnitRace("player")
	lines[#lines + 1] = string.format(
		"Player: %s %s %s level %d, in combat %s; expansion %s",
		tostring(UnitFactionGroup("player")),
		tostring(race),
		tostring(PlayerClass()),
		UnitLevel("player") or 0,
		YesNo(InCombatLockdown()),
		tostring(ns.EXPANSION)
	)
	lines[#lines + 1] = "Spellbook enabled (the add-on's switch for this feature): "
		.. YesNo(ns.IsSpellbookEnabled and ns.IsSpellbookEnabled())
	HostLines(lines)
	lines[#lines + 1] = ""
	ClassListLines(lines)
	lines[#lines + 1] = "Spells the options gate on:"
	if #SPELLBOOK_SPELLS == 0 then
		lines[#lines + 1] = "  (none for this class)"
	end
	for _, spell in ipairs(SPELLBOOK_SPELLS) do
		lines[#lines + 1] = SpellLine(spell)
	end
	StanceFormLines(lines)
	ClassGateLines(lines)
	GroupVersionLines(lines)
	SpellbookLines(lines)
	BookSkipLines(lines)
	CallPetFlyoutLines(lines)

	lines[#lines + 1] = ""
	local profile = ns.db and ns.db.profile
	if profile then
		lines[#lines + 1] = string.format(
			"Profile: %s; login message %s",
			tostring(ns.db:GetCurrentProfile()),
			OnOff(ns.db.global.showWelcome)
		)
		lines[#lines + 1] = string.format(
			"Page settings: show unlearned %s (unlearned file loaded %s), show all spell ranks %s (offered on this flavor %s), show grouped spells %s, count spells on bars %s, marked placed %d, sort by %s",
			OnOff(profile.showUnlearned),
			YesNo(ns.ForEachUnlearnedSpell ~= nil),
			OnOff(profile.showAllRanks),
			YesNo(ns.HAS_SPELL_RANKS),
			OnOff(profile.showGroupedSpells),
			OnOff(profile.countSpellsOnBars),
			CountKeys(profile.markedPlaced),
			tostring(profile.pageSort)
		)
		PageFilterLines(lines)
		lines[#lines + 1] = string.format(
			"Dynamic Rank: on for any macro %s; a new target or mouseover rewrites those macros only out of combat (in combat now %s)",
			YesNo(ns.AnyTargetRank()),
			YesNo(InCombatLockdown())
		)
		local kindDefaults = {}
		for _, kind in ipairs(ns.MACRO_KINDS) do
			local on = {}
			for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
				if ns.KindDefault(kind.key, key) then
					on[#on + 1] = key
				end
			end
			if ns.KindOffersTargetPriority(kind.key) then
				on[#on + 1] = "targets:" .. table.concat(ns.KindTargetPriority(kind.key), ">")
			end
			kindDefaults[#kindDefaults + 1] = kind.key .. "=" .. (#on > 0 and table.concat(on, "+") or "none")
		end
		lines[#lines + 1] = "Kind defaults: " .. table.concat(kindDefaults, ", ")
		local counts = {}
		for _, key in ipairs(PER_SPELL_OPTIONS) do
			counts[#counts + 1] = key .. "=" .. CountKeys(profile[key])
		end
		local copies = 0
		for _, numbers in pairs(profile.macroCopies) do
			copies = copies + #numbers
		end
		lines[#lines + 1] = "Per-spell settings saved: "
			.. table.concat(counts, ", ")
			.. string.format("; Duplicate copies %d, of %d spells", copies, CountKeys(profile.macroCopies))
		lines[#lines + 1] = "Conditionals: Spec conditions offered (dual spec) " .. tostring(ns.HasDualSpec())
		lines[#lines + 1] = string.format(
			"Unlearned sources: bundled trainer rows %d (%d for your faction and race), recorded by this character %d, class list extra spells %d; %d of those with no spell data yet, skipped until it loads",
			#((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}),
			TrainerRowsForPlayer(),
			CountKeys((profile.trainerSpells or {})[PlayerClass()]),
			#ns.ClassExtraSpells(),
			UnnamedCount(WhatsNextSourceIds())
		)
		WhatsNextLines(lines, profile)
		PetLines(lines, profile)
	else
		lines[#lines + 1] = "Profile: (database not loaded)"
	end
	local settingsRoute = type(Settings) == "table"
		and Settings.OpenToCategory
		and ns.optionsFrames
		and ns.optionsFrames.categoryID
	lines[#lines + 1] = string.format(
		"Options panel: category id %s, /gtg opens it through %s",
		tostring(ns.optionsFrames and ns.optionsFrames.categoryID),
		settingsRoute and "Settings.OpenToCategory" or "AceConfigDialog:Open"
	)
	local keys = { GetBindingKey("GOODTOGO_TOGGLE_SPELLBOOK") }
	local oldKeys = { GetBindingKey("MACROSPELLBOOK_TOGGLE") }
	lines[#lines + 1] = string.format(
		"Key binding: GOODTOGO_TOGGLE_SPELLBOOK %s; old name MACROSPELLBOOK_TOGGLE %s (moved over at an out-of-combat login); it calls GoodToGo_ToggleSpellbook (present %s), which opens %s",
		keys[1] and table.concat(keys, ", ") or "not bound",
		oldKeys[1] and table.concat(oldKeys, ", ") or "not bound",
		YesNo(type(GoodToGo_ToggleSpellbook) == "function"),
		not ns.ToggleSpellbookPage and "nothing, no spellbook host loaded" or "the page's window"
	)
	DockedPanelLine(lines)

	lines[#lines + 1] = ""
	PageListLines(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Macro Context
--------------------------------------------------------------------------------

-- The sound settings the Mute Errors option turns off around its cast and puts back within a second.
local MUTE_ERRORS_CVARS = { "Sound_EnableSFX", "Sound_EnableErrorSpeech" }

local function MuteErrorsLine(lines)
	local values = {}
	for _, cvar in ipairs(MUTE_ERRORS_CVARS) do
		values[#values + 1] = string.format("%s %s", cvar, tostring(C_CVar.GetCVar(cvar)))
	end
	lines[#lines + 1] = string.format(
		"Mute Errors: %d macros use it; %s; GtGMute global present %s",
		CountKeys(ns.db.profile.muteErrors),
		table.concat(values, ", "),
		YesNo(type(GtGMute) == "function")
	)
end

-- Tags carried by more than one WoW macro: a lookup by tag finds only the first, so the rest are never rewritten.
local function SharedTagCount()
	local numAccount, _, numCharacter = ns.MacroCounts()
	local first, seen, shared = ns.MaxAccountMacros(), {}, 0
	local function read(index)
		local tag = ns.BodyTag(select(3, GetMacroInfo(index)))
		if tag then
			seen[tag] = (seen[tag] or 0) + 1
			if seen[tag] == 2 then
				shared = shared + 1
			end
		end
	end
	for index = 1, numAccount or 0 do
		read(index)
	end
	for index = first + 1, first + (numCharacter or 0) do
		read(index)
	end
	return shared
end

local DYNAMIC_RANK_MACROS_SHOWN = 12

--[[
	Dynamic Rank (Features/Spellbook/Dynamic-Rank.lua): a macro counts as placed when its WoW macro exists and a
	bar holds it by name or by the tag its body carries, as the rewrite reads it; with none placed a new target
	rewrites nothing, and with none placed that tries the mouseover a new mouseover rewrites nothing either.
	A macro names a lower rank only for a unit that is there, can be helped and shows its level, and only when
	it casts its own spell (not a grouped one), not at the cursor and with no fixed rank set. The text it would
	write for the units now, against its WoW macro's, says whether a rewrite is still due.
]]
local function DynamicRankLines(lines, indexes, barNames)
	local onBars, tagsOnBars = {}, {}
	for _, name in pairs(barNames) do
		onBars[name] = true
		local tag = ns.MacroNameTag(name)
		if tag then
			tagsOnBars[tag] = true
		end
	end
	local total, placed, placedMouseover, detail = 0, 0, 0, {}
	for _, macro in ipairs(ns.macros or {}) do
		if ns.IsOptionOn(macro, "targetRank") then
			total = total + 1
			local tag = ns.MacroTag(macro)
			local index = indexes.tags[tag]
			local onBar = index ~= nil and (onBars[ns.WowMacroName(macro)] or tagsOnBars[tag]) == true
			local mouseover = ns.TriesUnit(macro, "mouseover")
			if onBar then
				placed = placed + 1
				placedMouseover = placedMouseover + (mouseover and 1 or 0)
			end
			if #detail < DYNAMIC_RANK_MACROS_SHOWN then
				local bodyOk, body = pcall(ns.MacroBody, macro)
				local holds = not index and "no WoW macro"
					or not bodyOk and ("(read failed: " .. Shown(body) .. ")")
					or YesNo(select(3, GetMacroInfo(index)) == body)
				detail[#detail + 1] = string.format(
					"  %s: on a bar %s, tries the mouseover %s, ranks known %d (right-click spell's %d), casts its own spell %s, fixed rank %s, at the cursor %s; WoW macro holds the text for the units now %s",
					Shown(macro.label or macro.name),
					YesNo(onBar),
					YesNo(mouseover),
					#(macro.ranks or {}),
					#(macro.rightClickRanks or {}),
					YesNo(ns.CastSpellName(macro) == macro.name),
					tostring(ns.FixedRank(macro) or "none"),
					YesNo(ns.IsOptionOn(macro, "cursor")),
					holds
				)
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Dynamic Rank: %d macros, %d on the action bars, %d of those try the mouseover; target there %s, can be helped %s, level %s; mouseover there %s, can be helped %s, level %s",
		total,
		placed,
		placedMouseover,
		PlainYesNo(UnitExists("target")),
		PlainYesNo(UnitCanAssist("player", "target")),
		PlainText(UnitLevel("target")),
		PlainYesNo(UnitExists("mouseover")),
		PlainYesNo(UnitCanAssist("player", "mouseover")),
		PlainText(UnitLevel("mouseover"))
	)
	for _, line in ipairs(detail) do
		lines[#lines + 1] = line
	end
	if total > #detail then
		lines[#lines + 1] = string.format("  (and %d more)", total - #detail)
	end
end

--[[
	A trainer's window, while it is open: a tradeskill or pet trainer is never recorded, and only the services
	its filters list are.
]]
local function TrainerWindowLine(lines)
	local frame = _G.ClassTrainerFrame
	if not (frame and frame:IsShown()) then
		lines[#lines + 1] = "  trainer window: not open"
		return
	end
	local typeFilter = _G.GetTrainerServiceTypeFilter
	local filters = {}
	for _, kind in ipairs({ "available", "unavailable", "used" }) do
		filters[#filters + 1] = kind .. " " .. (typeFilter and YesNo(typeFilter(kind)) or "unknown")
	end
	lines[#lines + 1] = string.format(
		"  trainer window: open, %d services, tradeskill trainer %s, trainer type %s; filters %s",
		GetNumTrainerServices() or 0,
		YesNo(IsTradeskillTrainer and IsTradeskillTrainer()),
		tostring(C_Trainer and C_Trainer.GetTrainerType and C_Trainer.GetTrainerType()),
		table.concat(filters, ", ")
	)
end

--[[
	The state behind "clicking a macro does nothing", "my own macro was left alone" or "the macro didn't
	update": the Spellbook's switch and combat, free macro slots (character macros spill into general ones once
	full) and whether a new one can be created, which macros the add-on recorded as its own and for whom, each
	page macro as ns.FindMacroIndex finds it (by its tag line, or by name for a macro from before the tags,
	which the next sync tags), page macros too long to write or out of step with their WoW macro, tags two WoW
	macros share, untagged macros sharing a page macro's name that the page leaves alone, a replaced spell's
	macro waiting to be taken over, the Conditionals rows, Cast Sequence steps and Cast Sequences left out of
	the text, the Dynamic Rank macros, where they are placed and the units they rank for, what is on the
	action bars, what the Delete Macros buttons would count, the equipped items with a Use: effect, the Mute
	Errors sound settings, and the trainer recording. Existence/value reads only.
]]
function ns:BuildMacroContextReport()
	local lines = { ns.GetDiagnosticClientHeader(), "" }
	lines[#lines + 1] = "Spellbook enabled: "
		.. YesNo(ns.IsSpellbookEnabled and ns.IsSpellbookEnabled())
		.. " (while off, nothing rewrites the macros)"
	lines[#lines + 1] = "In combat: "
		.. YesNo(InCombatLockdown())
		.. " (a macro change made in combat is written when combat ends)"
	local numAccount, maxAccount, numCharacter, maxCharacter = ns.MacroCounts()
	lines[#lines + 1] = string.format(
		"Macros: %d of %d general, %d of %d character (limits from %s)",
		numAccount or 0,
		maxAccount,
		numCharacter or 0,
		maxCharacter,
		(type(Constants) == "table" and type(Constants.MacroConsts) == "table") and "Constants.MacroConsts"
			or (MAX_ACCOUNT_MACROS and MAX_CHARACTER_MACROS) and "the MAX_*_MACROS globals"
			or "the fallback, Blizzard_MacroUI not loaded yet"
	)
	-- a page macro is created when first dragged off the page, in a character slot, else a general one
	local characterFull = (numCharacter or 0) >= maxCharacter
	local generalFull = (numAccount or 0) >= maxAccount
	lines[#lines + 1] = string.format(
		"New macros: character slots full %s, general slots full %s; a new page macro can be created %s",
		YesNo(characterFull),
		YesNo(generalFull),
		YesNo(not (characterFull and generalFull))
	)
	if not ns.db then
		lines[#lines + 1] = "(database not loaded)"
		return table.concat(lines, "\n")
	end
	local thisCharacter, otherCharacters, shared = 0, 0, 0
	for _, record in pairs(ns.db.global.ownedMacros) do
		if record == ns.MacroOwnerKey() then
			thisCharacter = thisCharacter + 1
		elseif type(record) == "string" then
			otherCharacters = otherCharacters + 1
		else
			shared = shared + 1
		end
	end
	lines[#lines + 1] = string.format(
		"Recorded as the add-on's: general %d this character's, %d other characters', %d shared (from before owners were recorded, or a retired equipment macro); character %d; tag line IDs handed out %d (register holds %d)",
		thisCharacter,
		otherCharacters,
		shared,
		CountKeys(ns.db.char.ownedMacros),
		ns.db.global.macroTagCount,
		CountKeys(ns.db.global.macroTags)
	)

	local counts = { tag = 0, owned = 0, claim = 0, adopt = 0, missing = 0, tooLong = 0, outOfStep = 0 }
	local leftAlone, tooLong = {}, {}
	local indexes = ns.ReadMacroIndexes()
	for _, macro in ipairs(ns.macros or {}) do
		if #macro.body > ns.MACRO_BODY_MAX_LENGTH then
			counts.tooLong = counts.tooLong + 1
			tooLong[#tooLong + 1] = string.format("%s (%d)", Shown(macro.label or macro.name), #macro.body)
		end
		local index, found = ns.FindMacroIndex(macro, indexes)
		if index == 0 then
			counts.missing = counts.missing + 1
		else
			counts[found] = counts[found] + 1
			if select(3, GetMacroInfo(index)) ~= macro.body then
				counts.outOfStep = counts.outOfStep + 1
			end
		end
		local wowName = ns.WowMacroName(macro)
		if found ~= "owned" and found ~= "claim" and found ~= "adopt" and indexes.names[wowName] then
			leftAlone[#leftAlone + 1] = wowName
		end
	end
	lines[#lines + 1] = string.format(
		"Page macros (as of the page's last redraw, %d in the list): %d found by tag; by name, from before the tags, %d this character's, %d to claim, %d to adopt; %d not created yet; %d of those found out of step with the page; %d over %d bytes, never written%s",
		#(ns.macros or {}),
		counts.tag,
		counts.owned,
		counts.claim,
		counts.adopt,
		counts.missing,
		counts.outOfStep,
		counts.tooLong,
		ns.MACRO_BODY_MAX_LENGTH,
		tooLong[1] and (" (" .. table.concat(tooLong, ", ") .. ")") or ""
	)
	lines[#lines + 1] = string.format(
		"Tags carried by more than one WoW macro: %d; a replaced spell's macro waiting for the spell that took its place: %s",
		SharedTagCount(),
		YesNo(ns.HandOverDue())
	)
	lines[#lines + 1] = "Names shared with an untagged macro the page leaves alone (the player's own, or another character's): "
		.. (leftAlone[1] and table.concat(leftAlone, ", ") or "none")

	--[[
		A Conditionals row without a spell or a condition this client knows, or one the panel shows faded (a
		condition the macro can't use, or shadowed by an earlier row), is left out of the macro text, and so is
		a row whose spell isn't loaded yet or a ranged row with no ranged attack known. A Cast Sequence step
		whose spell isn't loaded is left out, and a Cast Sequence a pet summon blocks writes nothing.
	]]
	local withRows, rowsWritten, rowsSkipped, rowsUnloaded = 0, 0, 0, 0
	local sequences, sequencesBlocked, stepsUnloaded = 0, 0, 0
	local rangedKnown = #ns.KnownRangedAttacks() > 0
	for _, macro in ipairs(ns.macros or {}) do
		local rows = ns.Conditionals(macro)
		if #rows > 0 then
			withRows = withRows + 1
			-- written as ns.ConditionalClauses writes a row: a spell, a condition this client knows, nothing skipping it
			for index, row in ipairs(rows) do
				local known = false
				for _, key in ipairs(row.when or {}) do
					known = known or ns.ConditionRow(key) ~= nil
				end
				if not (ns.ConditionalHasSpell(row) and known and not ns.ConditionalSkipReason(macro, index)) then
					rowsSkipped = rowsSkipped + 1
				elseif row.ranged and not rangedKnown or not row.ranged and not ns.ConditionalSpellText(row) then
					rowsUnloaded = rowsUnloaded + 1
				else
					rowsWritten = rowsWritten + 1
				end
			end
		end
		if ns.CastSequenceStepCount(macro) > 0 or ns.CastSequenceStops(macro) then
			sequences = sequences + 1
			if ns.CastSequenceBlockReason(macro) then
				sequencesBlocked = sequencesBlocked + 1
			end
			for _, step in ipairs(ns.CastSequenceSteps(macro)) do
				if step.spellID and not ns.ConditionalSpellText(step) then
					stepsUnloaded = stepsUnloaded + 1
				end
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Conditionals: %d macros with rows, %d rows written, %d left out, %d with no spell to write yet; Cast Sequence: %d macros with steps, %d blocked, %d steps whose spell isn't loaded",
		withRows,
		rowsWritten,
		rowsSkipped,
		rowsUnloaded,
		sequences,
		sequencesBlocked,
		stepsUnloaded
	)
	local barOk, barNames = pcall(ns.BarMacroNames)
	if barOk then
		DynamicRankLines(lines, indexes, barNames)
	else
		lines[#lines + 1] = "Dynamic Rank: (bar read failed: " .. Shown(barNames) .. ")"
	end

	local scanOk, bars = pcall(ns.ScanActionBars)
	if scanOk then
		local placed = 0
		for _, macro in ipairs(ns.macros or {}) do
			if ns.IsOnActionBars(macro, bars) then
				placed = placed + 1
			end
		end
		lines[#lines + 1] = string.format(
			"Action bars: %d macros, %d spells; %d page macros count as placed",
			CountKeys(bars.macros),
			CountKeys(bars.spells),
			placed
		)
	else
		lines[#lines + 1] = "Action bars: (read failed: " .. Shown(bars) .. ")"
	end
	-- each button is grayed out while its list holds none of the add-on's macros
	lines[#lines + 1] = string.format(
		"Delete Macros buttons would delete: general %d, character %d",
		ns.CountAddonMacros(true),
		ns.CountAddonMacros(false)
	)

	local usableOk, usable = pcall(ns.UsableSlots)
	if usableOk then
		local slots = {}
		for _, entry in ipairs(usable) do
			slots[#slots + 1] = string.format("%d %s", entry.slot, Shown(ns.SlotLabel(entry.slot)))
		end
		lines[#lines + 1] = "Equipped items with a Use: effect: " .. (slots[1] and table.concat(slots, "; ") or "none")
	else
		lines[#lines + 1] = "Equipped items with a Use: effect: (read failed: " .. Shown(usable) .. ")"
	end

	MuteErrorsLine(lines)
	lines[#lines + 1] = string.format(
		"Trainer recording (a class trainer's window, while the Spellbook is on: %s): file loaded %s, %d spells recorded on this character",
		YesNo(ns.IsSpellbookEnabled()),
		YesNo(ns.OnTrainerShow ~= nil),
		CountKeys((ns.db.profile.trainerSpells or {})[PlayerClass()])
	)
	TrainerWindowLine(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
	Every game record the Spellbook names by ID, for the Localization tab's Game Names report: the client
	strings it reads or matches, the slot names its Use Items options show, every spell and creature family
	in the player's class lists and the forms that head a run under Sort By Category, every GROUP_VERSIONS
	spell and the class's SPELL_GROUPS spells, the shared page spells and profession specializations it
	files and folds by name, the basic attacks, the ranged attack the after-cast option starts, the Shoot
	macro's ranged attacks with the weapon type each [worn:] condition names, every trainer spell the
	Unlearned section and What's Next? can list with the spells a rank waits on, and the pet abilities,
	grimoires and beast zones the Pet What's Next? tab shows, each read as the features read it. The rank
	text a fixed or Dynamic Rank macro writes ("Rank 3") is the spell's subtext, so every trainer rank above
	the first (a row that requires an earlier one) has a rank row too. The class-list, trainer and pet rows
	are the player's class only, the class whose page this character sees. A spell or item loads late, so
	its rows ask for it.
]]

local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

local function SpellRow(constant, kind, id, read)
	return {
		constant = constant,
		kind = kind,
		id = id,
		lookup = function()
			return read(id)
		end,
		request = function()
			C_Spell.RequestLoadSpellData(id)
		end,
	}
end

local function FamilyRow(constant, id)
	return {
		constant = constant,
		kind = "creatureFamily",
		id = id,
		lookup = function()
			local info = C_CreatureInfo.GetCreatureFamilyInfo(id)
			return info and info.name
		end,
	}
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, {
	-- { constant, kind, id, lookup, request }
	UiLabel("SETTINGS"),
	UiLabel("PAGE_NUMBER"),
	UiLabel("NOT_BOUND"),
	UiLabel("KEY_BINDINGS"),
	UiLabel("SETTINGS_KEYBINDINGS_LABEL"),
	UiLabel("GAMEMENU_OPTIONS"),
	UiLabel("ITEM_SPELL_TRIGGER_ONUSE"),
	UiLabel("ERR_NOT_IN_COMBAT"),
	UiLabel("HEADSLOT"),
	UiLabel("NECKSLOT"),
	UiLabel("SHOULDERSLOT"),
	UiLabel("SHIRTSLOT"),
	UiLabel("CHESTSLOT"),
	UiLabel("WAISTSLOT"),
	UiLabel("LEGSSLOT"),
	UiLabel("FEETSLOT"),
	UiLabel("WRISTSLOT"),
	UiLabel("HANDSSLOT"),
	UiLabel("FINGER0SLOT_UNIQUE"),
	UiLabel("FINGER1SLOT_UNIQUE"),
	UiLabel("TRINKET0SLOT_UNIQUE"),
	UiLabel("TRINKET1SLOT_UNIQUE"),
	UiLabel("BACKSLOT"),
	UiLabel("MAINHANDSLOT"),
	UiLabel("SECONDARYHANDSLOT"),
	UiLabel("RANGEDSLOT"),
	UiLabel("TABARDSLOT"),
})

do
	local lists = ClassLists()
	local rows, seen =
		ns.DIAGNOSTIC_NAME_LOOKUPS,
		{ spell = {}, spellRank = {}, creatureFamily = {}, itemSubclass = {}, item = {}, area = {} }
	local function Add(kind, id, row)
		if not seen[kind][id] then
			seen[kind][id] = true
			rows[#rows + 1] = row
		end
	end
	local function AddSpell(constant, id)
		Add("spell", id, SpellRow(constant, "spell", id, C_Spell.GetSpellName))
	end
	local function AddRank(constant, id)
		Add("spellRank", id, SpellRow(constant, "spellRank", id, C_Spell.GetSpellSubtext))
	end
	local function AddFamily(constant, id)
		Add("creatureFamily", id, FamilyRow(constant, id))
	end
	local function AddEntries(constant, entries)
		for position, entry in ipairs(entries or {}) do
			for _, id in ipairs(EntryIds(entry)) do
				AddSpell(string.format("%s[%d]", constant, position), id)
			end
		end
	end
	if lists then
		for _, key in ipairs(LIST_KEYS) do
			AddEntries(key, lists[key])
		end
		for _, id in ipairs(lists.stanceSlots or {}) do
			AddSpell("stanceSlots", id)
		end
		for spellId, stanceIds in pairs(lists.stances or {}) do
			AddSpell("stances", spellId)
			for _, stanceId in ipairs(stanceIds) do
				AddSpell("stances", stanceId)
			end
		end
		for summonId, pet in pairs(lists.petAbilities or {}) do
			AddSpell("petAbilities", summonId)
			AddSpell("petAbilities", pet.abilityId)
			AddFamily("petAbilities", pet.familyId)
		end
	end
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or {}) do
		AddSpell("GROUP_VERSIONS", singleId)
		AddSpell("GROUP_VERSIONS", groupId)
	end
	for _, ids in ipairs((ns.SPELL_GROUPS or {})[PlayerClass()] or {}) do
		for _, id in ipairs(ids) do
			AddSpell("SPELL_GROUPS", id)
		end
	end
	if lists and lists.autoShot then
		AddSpell("autoShot", lists.autoShot)
	end
	for _, ids in pairs(lists and lists.forms or {}) do
		for _, id in ipairs(ids) do
			AddSpell("forms", id)
		end
	end
	local sections = {}
	for section in pairs(ns.SHARED_PAGE_SPELLS or {}) do
		sections[#sections + 1] = section
	end
	table.sort(sections)
	for _, section in ipairs(sections) do
		AddEntries("SHARED_PAGE_SPELLS." .. section, ns.SHARED_PAGE_SPELLS[section])
	end
	for _, ids in ipairs(ns.PROFESSION_SPECIALIZATIONS or {}) do
		for _, id in ipairs(ids) do
			AddSpell("PROFESSION_SPECIALIZATIONS", id)
		end
	end
	for _, id in ipairs(ns.BASIC_ATTACK_SPELL_IDS or {}) do
		AddSpell("BASIC_ATTACK_SPELL_IDS", id)
	end
	if ns.SHOOT_SPELL_ID then
		AddSpell("SHOOT_SPELL_ID", ns.SHOOT_SPELL_ID)
	end
	for _, attack in ipairs(ns.RANGED_ATTACKS or {}) do
		AddSpell("RANGED_ATTACKS", attack.id)
		Add("itemSubclass", attack.subclass, {
			constant = "RANGED_ATTACKS",
			kind = "itemSubclass",
			id = attack.subclass,
			lookup = function()
				return ns.RangedWornName(attack)
			end,
		})
	end
	for _, row in ipairs((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}) do
		AddSpell("TRAINER_SPELLS", row.id)
		if row.requires then
			AddRank("TRAINER_SPELLS", row.id)
		end
		-- What's Next? names the spells a rank waits on
		for _, id in ipairs(row.requires or {}) do
			AddSpell("TRAINER_SPELLS requires", id)
		end
	end
	local abilities = PlayerClass() == "HUNTER" and ns.PET_ABILITIES
		or PlayerClass() == "WARLOCK" and ns.DEMON_ABILITIES
		or {}
	local abilitiesConstant = PlayerClass() == "HUNTER" and "PET_ABILITIES" or "DEMON_ABILITIES"
	for _, row in ipairs(abilities) do
		AddSpell(abilitiesConstant, row.id)
		if row.item then
			Add("item", row.item, {
				constant = abilitiesConstant,
				kind = "item",
				id = row.item,
				lookup = function()
					return C_Item.GetItemNameByID(row.item)
				end,
				request = function()
					C_Item.RequestLoadItemDataByID(row.item)
				end,
			})
		end
	end
	if PlayerClass() == "HUNTER" then
		local zones = {}
		for _, beast in pairs(ns.TAMEABLE_BEASTS or {}) do
			if beast[4] and not seen.area[beast[4]] then
				seen.area[beast[4]] = true
				zones[#zones + 1] = beast[4]
			end
		end
		table.sort(zones)
		for _, zone in ipairs(zones) do
			rows[#rows + 1] = {
				constant = "TAMEABLE_BEASTS",
				kind = "area",
				id = zone,
				lookup = function()
					return C_Map.GetAreaInfo(zone)
				end,
			}
		end
	end
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
	One entry per data file, and one report row per entry on the Data tab. The class lists and trainer spells
	are keyed by class token, so their collectors walk every class and answer once per spell ID, keeping the
	class and where the ID sits as its DATA_* values; a class list entry with several rank IDs answers once
	per rank. The group versions answer once per half of each pair, naming the other half.
]]
local function KeyValue(key)
	return key
end

local function RowField(field)
	return function(_, row)
		local value = type(row) == "table" and row[field] or nil
		if type(value) == "table" then
			return table.concat(value, ",")
		end
		return value
	end
end

local function CollectClassListSpells(listsByClass)
	local entries = {}
	local function Add(classToken, list, entry)
		for _, id in ipairs(EntryIds(entry)) do
			entries[#entries + 1] = { id = id, key = classToken, row = { list = list } }
		end
	end
	for classToken, lists in pairs(listsByClass) do
		for _, key in ipairs(DATA_LIST_KEYS) do
			for _, entry in ipairs(lists[key] or {}) do
				Add(classToken, key, entry)
			end
		end
		if lists.autoShot then
			Add(classToken, "autoShot", lists.autoShot)
		end
		for _, id in ipairs(lists.stanceSlots or {}) do
			Add(classToken, "stanceSlots", id)
		end
		for spellId, stanceIds in pairs(lists.stances or {}) do
			Add(classToken, "stances", spellId)
			for _, stanceId in ipairs(stanceIds) do
				Add(classToken, "stances", stanceId)
			end
		end
		for summonId, pet in pairs(lists.petAbilities or {}) do
			Add(classToken, "petAbilities", summonId)
			Add(classToken, "petAbilities", pet.abilityId)
		end
	end
	return entries
end

-- GROUP_VERSIONS is keyed by the single-target spell; each pair answers once per half.
local function CollectGroupVersionSpells(groupBySingle)
	local entries = {}
	for singleId, groupId in pairs(groupBySingle) do
		entries[#entries + 1] = { id = singleId, row = { half = "single", pair = groupId } }
		entries[#entries + 1] = { id = groupId, row = { half = "group", pair = singleId } }
	end
	return entries
end

local function CollectTrainerSpells(spellsByClass)
	local entries = {}
	for classToken, rows in pairs(spellsByClass) do
		for _, row in ipairs(rows) do
			entries[#entries + 1] = { id = row.id, key = classToken, row = row }
		end
	end
	return entries
end

-- A plain list of spell IDs (BASIC_ATTACK_SPELL_IDS).
local function CollectSpellIds(ids)
	local entries = {}
	for _, id in ipairs(ids) do
		entries[#entries + 1] = { id = id }
	end
	return entries
end

-- RANGED_ATTACKS rows carry their spell as id.
local function CollectRangedAttacks(rows)
	local entries = {}
	for _, row in ipairs(rows) do
		entries[#entries + 1] = { id = row.id, row = row }
	end
	return entries
end

-- SPELL_GROUPS lists each class's groups of IDs; every ID answers once, naming the rest of its group.
local function CollectSpellGroupSpells(groupsByClass)
	local entries = {}
	for classToken, groups in pairs(groupsByClass) do
		for _, ids in ipairs(groups) do
			for _, id in ipairs(ids) do
				local others = {}
				for _, other in ipairs(ids) do
					if other ~= id then
						others[#others + 1] = other
					end
				end
				entries[#entries + 1] = { id = id, key = classToken, row = { group = others } }
			end
		end
	end
	return entries
end

-- SHARED_PAGE_SPELLS is keyed by page section; an entry with several IDs answers once per ID.
local function CollectSharedPageSpells(spellsBySection)
	local entries = {}
	for section, list in pairs(spellsBySection) do
		for _, entry in ipairs(list) do
			for _, id in ipairs(EntryIds(entry)) do
				entries[#entries + 1] = { id = id, key = section }
			end
		end
	end
	return entries
end

-- PROFESSION_SPECIALIZATIONS rows open on the profession; each specialization answers naming it.
local function CollectSpecializations(rows)
	local entries = {}
	for _, row in ipairs(rows) do
		for index, id in ipairs(row) do
			entries[#entries + 1] = { id = id, row = { profession = index > 1 and row[1] or nil } }
		end
	end
	return entries
end

-- PET_ABILITIES and DEMON_ABILITIES rows carry the pet's spell as id; field reads the hunter's teach spell or the grimoire.
local function CollectAbilityField(field)
	return function(rows)
		local entries = {}
		for _, row in ipairs(rows) do
			if row[field] then
				entries[#entries + 1] = { id = row[field], row = row }
			end
		end
		return entries
	end
end

-- PET_ABILITY_BEASTS is keyed by the pet's spell, holding the beasts that know it.
local function CollectAbilityBeasts(beastsBySpell)
	local entries = {}
	for spellId, beasts in pairs(beastsBySpell) do
		entries[#entries + 1] = { id = spellId, row = { beasts = #beasts } }
	end
	return entries
end

-- TAMEABLE_BEASTS rows end on the beast's zone; each zone answers once, with how many beasts live there.
local function CollectBeastZones(beastsByNpc)
	local counts = {}
	for _, beast in pairs(beastsByNpc) do
		local zone = beast[4]
		if zone then
			counts[zone] = (counts[zone] or 0) + 1
		end
	end
	local entries = {}
	for zone, count in pairs(counts) do
		entries[#entries + 1] = { id = zone, row = { beasts = count } }
	end
	return entries
end

-- EXTRA_SPELL_SOURCES rows are { source, level }.
local function RowIndex(index)
	return function(_, row)
		return type(row) == "table" and row[index] or nil
	end
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	-- { label, sources = { { table, kind, rowId or collect, dataColumns } } }
	{
		label = "Game-IDs",
		sources = {
			{ table = "BASIC_ATTACK_SPELL_IDS", kind = "spell", collect = CollectSpellIds },
			{ table = "RANGED_ATTACKS", kind = "spell", collect = CollectRangedAttacks },
		},
	},
	{
		label = "Class-Spell-Lists",
		sources = {
			{
				table = "CLASS_SPELL_LISTS",
				kind = "spell",
				collect = CollectClassListSpells,
				dataColumns = { { "DATA_CLASS", KeyValue }, { "DATA_LIST", RowField("list") } },
			},
		},
	},
	{
		label = "Trainer-Spells",
		sources = {
			{
				table = "TRAINER_SPELLS",
				kind = "spell",
				collect = CollectTrainerSpells,
				dataColumns = {
					{ "DATA_CLASS", KeyValue },
					{ "DATA_LEVEL", RowField("level") },
					{ "DATA_REQUIRES", RowField("requires") },
					{ "DATA_FACTION", RowField("faction") },
					{ "DATA_RACE", RowField("race") },
					{ "DATA_TALENT", RowField("talent") },
				},
			},
		},
	},
	{
		label = "Group-Versions",
		sources = {
			{
				table = "GROUP_VERSIONS",
				kind = "spell",
				collect = CollectGroupVersionSpells,
				dataColumns = { { "DATA_HALF", RowField("half") }, { "DATA_PAIR", RowField("pair") } },
			},
			{
				table = "SPELL_GROUPS",
				kind = "spell",
				collect = CollectSpellGroupSpells,
				dataColumns = { { "DATA_CLASS", KeyValue }, { "DATA_GROUP", RowField("group") } },
			},
		},
	},
	{
		label = "Shared-Page-Spells",
		sources = {
			{
				table = "SHARED_PAGE_SPELLS",
				kind = "spell",
				collect = CollectSharedPageSpells,
				dataColumns = { { "DATA_SECTION", KeyValue } },
			},
			{
				table = "PROFESSION_SPECIALIZATIONS",
				kind = "spell",
				collect = CollectSpecializations,
				dataColumns = { { "DATA_PROFESSION", RowField("profession") } },
			},
		},
	},
	{
		label = "Spell-Sources",
		sources = {
			{
				table = "EXTRA_SPELL_SOURCES",
				kind = "spell",
				rowId = KeyValue,
				dataColumns = { { "DATA_SOURCE", RowIndex(1) }, { "DATA_LEVEL", RowIndex(2) } },
			},
		},
	},
	{
		label = "Pet-Abilities",
		sources = {
			{
				table = "PET_ABILITIES",
				kind = "spell",
				collect = CollectAbilityField("id"),
				dataColumns = {
					{ "DATA_LEVEL", RowField("level") },
					{ "DATA_SOURCE", RowField("source") },
					{ "DATA_TEACH", RowField("teach") },
					{ "DATA_TP", RowField("tp") },
					{ "DATA_FAMILIES", RowField("families") },
				},
			},
			{
				table = "PET_ABILITIES",
				kind = "spell",
				collect = CollectAbilityField("teach"),
				dataColumns = { { "DATA_LEVEL", RowField("level") }, { "DATA_PET_SPELL", RowField("id") } },
			},
			{
				table = "DEMON_ABILITIES",
				kind = "spell",
				collect = CollectAbilityField("id"),
				dataColumns = {
					{ "DATA_LEVEL", RowField("level") },
					{ "DATA_GRIMOIRE", RowField("item") },
					{ "DATA_FAMILIES", RowField("families") },
				},
			},
			{
				table = "DEMON_ABILITIES",
				kind = "item",
				collect = CollectAbilityField("item"),
				dataColumns = { { "DATA_LEVEL", RowField("level") }, { "DATA_PET_SPELL", RowField("id") } },
			},
			{
				table = "PET_ABILITY_BEASTS",
				kind = "spell",
				collect = CollectAbilityBeasts,
				dataColumns = { { "DATA_BEASTS", RowField("beasts") } },
			},
			{
				table = "TAMEABLE_BEASTS",
				kind = "area",
				collect = CollectBeastZones,
				dataColumns = { { "DATA_BEASTS", RowField("beasts") } },
			},
			-- The beasts' NPC IDs: no client call names an NPC from its ID, so the table reports its size.
			{ table = "TAMEABLE_BEASTS", kind = "other" },
		},
	},
})
