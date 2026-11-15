local _, ns = ...
local GetColor = ns.GetColor
local L = ns.L

local KnowsAny = ns.KnowsAny

--[[
    The class notes for the consumable macros: for a hunter, mage, rogue or
    warlock, the items their class's macros will use and what each click on
    those macros does. The mini-map menu reads them whole
    (ns.GetClassMacroNotes, for its [Class] Macros row, its item rows and its
    flyout, in Features/Minimap-Menu.lua), and the Spellbook page draws one
    macro's worth under a consumable macro's tooltip
    (ns.AddConsumableMacroNotes).
]]

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    One macro's notes in a tooltip: its name, a row per click (the click on
    the left, what it does on the right), then an optional closing line. HELP
    rather than INFO: these are clicks on a macro, and blue marks a click on
    the mini-map button.
]]
local function AddMacroNotes(tooltip, macroName, rows, closingNote)
	tooltip:AddLine(GetColor("TITLE") .. macroName .. "|r")
	for _, row in ipairs(rows) do
		tooltip:AddDoubleLine(GetColor("HELP") .. row[1] .. "|r", GetColor("HELP") .. row[2] .. "|r")
	end
	if closingNote then
		tooltip:AddLine(GetColor("HELP") .. closingNote .. "|r", 1, 1, 1, true)
	end
end

-- The client's own name for the first spell on the list the player knows; nil when they know none.
local function KnownSpellName(spellList)
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return C_Spell.GetSpellName(data[1])
		end
	end
	return nil
end

--[[
    Each builder returns its class's blocks in order, or nothing while the
    character has none: an item block ({ itemID, itemLink, slot }) for each
    item the class's own macro will use, slot saying what it is for (a hand,
    or pet food), then a notes block ({ title, rows, note, types }) per macro,
    types naming the consumable macros it is about. A row is { click, job },
    the job a verb or what it fills, and is listed only for a spell the
    character knows.
]]
local function HunterNotes()
	if not ns.feedPetSpellName then
		return nil
	end

	local rows = { { L["MENU_CLICK_LEFT"], L["NOTE_PET_CALL_FEED_REVIVE"] } }
	if ns.mendPetSpellName then
		tinsert(rows, { L["NOTE_PET_MEND_CLICK"], ns.mendPetSpellName })
	end
	tinsert(rows, { L["NOTE_HOLD_SHIFT"], L["NOTE_PET_FORCE_REVIVE"] })
	tinsert(rows, { L["NOTE_HOLD_CONTROL"], L["NOTE_PET_DISMISS"] })

	return {
		{
			itemID = ns.bestPetFoodID,
			itemLink = ns.bestPetFoodLink,
			slot = L["LABEL_PET_FOOD"],
		},
		{ title = L["NOTE_MACRO_FEED_PET"], rows = rows, types = { "Feed Pet" } },
	}
end

local function MageNotes()
	local spells = ns.CONJURE_SPELLS
	local knowsFoodOrWater = KnowsAny(spells.MageCreateFood) or KnowsAny(spells.MageCreateWater)
	local ritualName = KnownSpellName(spells.MageCreateTable)
	local blocks = {}

	if knowsFoodOrWater or ritualName then
		local rows = {}
		if knowsFoodOrWater then
			tinsert(rows, { L["MENU_CLICK_RIGHT"], L["NOTE_CONJURE"] })
		end
		if ritualName then
			tinsert(rows, { L["MENU_CLICK_MIDDLE"], ritualName })
		end
		tinsert(blocks, {
			title = L["NOTE_MACRO_FOOD_WATER"],
			rows = rows,
			note = knowsFoodOrWater and L["NOTE_MAGE_TARGET_LEVEL"] or nil,
			types = { "Food", "Water" },
		})
	end

	if KnowsAny(spells.MageCreateManaGem) then
		tinsert(blocks, {
			title = L["NOTE_MACRO_MANA_GEM"],
			rows = {
				{ L["MENU_CLICK_RIGHT"], L["NOTE_CONJURE"] },
				{ L["NOTE_RIGHT_CLICK_AGAIN"], L["NOTE_CONJURE_LOWER_RANK"] },
			},
			types = { "Mana Gem" },
		})
	end

	return blocks
end

local function WarlockNotes()
	local spells = ns.CONJURE_SPELLS
	local knowsHealthstone = KnowsAny(spells.WarlockCreateHealthstone)
	local ritualName = KnownSpellName(spells.WarlockCreateSoulwell)
	local blocks = {}

	if knowsHealthstone or ritualName then
		local rows = {}
		if knowsHealthstone then
			tinsert(rows, { L["MENU_CLICK_RIGHT"], L["NOTE_CREATE"] })
			tinsert(rows, { L["NOTE_RIGHT_CLICK_AGAIN"], L["NOTE_CREATE_LOWER_RANK"] })
		end
		if ritualName then
			tinsert(rows, { L["MENU_CLICK_MIDDLE"], ritualName })
		end
		tinsert(blocks, {
			title = L["NOTE_MACRO_HEALTHSTONE"],
			rows = rows,
			note = knowsHealthstone and L["NOTE_WARLOCK_TARGET_LEVEL"] or nil,
			types = { "Healthstone" },
		})
	end

	if KnowsAny(spells.WarlockCreateSoulstone) then
		tinsert(blocks, {
			title = L["NOTE_MACRO_SOULSTONE"],
			rows = { { L["MENU_CLICK_RIGHT"], L["NOTE_CREATE"] } },
			types = { "Soulstone" },
		})
	end

	return blocks
end

local function RogueNotes()
	local poisons = ns.POISONS_SPELL_ID
	if not (poisons and (ns.IsSpellKnown(poisons) or ns.IsPlayerSpell(poisons))) then
		return nil
	end

	local mainID, mainLink = ns.GetBestPoisonForHand("main")
	local offID, offLink = ns.GetBestPoisonForHand("off")

	return {
		{
			itemID = mainID,
			itemLink = mainLink,
			slot = MAINHANDSLOT,
		},
		{
			itemID = offID,
			itemLink = offLink,
			slot = SECONDARYHANDSLOT,
		},
		{
			title = L["NOTE_MACRO_POISONS"],
			rows = {
				{ L["MENU_CLICK_LEFT"], SECONDARYHANDSLOT },
				{ L["MENU_CLICK_RIGHT"], MAINHANDSLOT },
				{ L["MENU_CLICK_MIDDLE"], L["NOTE_POISONS_WINDOW"] },
			},
			note = L["NOTE_POISONS_REPLACED"],
			types = { "Poisons" },
		},
	}
end

local CLASS_NOTES = {
	HUNTER = HunterNotes,
	MAGE = MageNotes,
	ROGUE = RogueNotes,
	WARLOCK = WarlockNotes,
}

--[[
    The player's class, by the client's name and its token, and its blocks in
    order, for the mini-map menu; nil when the class has no notes or the
    character knows none of the spells they are about, so a warrior gets no
    [Class] Macros row at all. The blocks are built fresh on every call, since
    the items and the known spells change as the player plays.
]]
function ns.GetClassMacroNotes()
	local className, playerClass = UnitClass("player")
	local buildNotes = CLASS_NOTES[playerClass]
	local blocks = buildNotes and buildNotes()
	if not blocks or #blocks == 0 then
		return nil
	end
	return className, playerClass, blocks
end

--[[
    The class-colored header and the notes block for one consumable macro
    type, as the mini-map menu's flyout lists them, for the Spellbook page's tooltip
    under the macro's text. False, drawing nothing, when the player's class
    has no notes for that macro.
]]
function ns.AddConsumableMacroNotes(tooltip, macroType)
	local className, playerClass = UnitClass("player")
	local buildNotes = CLASS_NOTES[playerClass]
	for _, block in ipairs(buildNotes and buildNotes() or {}) do
		if block.rows and tContains(block.types, macroType) then
			tooltip:AddLine((ns.GetClassColor(playerClass) or GetColor("TEXT")) .. className .. "|r")
			AddMacroNotes(tooltip, block.title, block.rows, block.note)
			return true
		end
	end
	return false
end
