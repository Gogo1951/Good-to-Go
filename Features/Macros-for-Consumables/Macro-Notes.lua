local _, ns = ...
local GetColor = ns.GetColor
local L = ns.L

local KnowsAny = ns.KnowsAny

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

-- HELP rather than INFO: these are clicks on a macro, and blue marks a click on the mini-map button.
local function AddMacroNotes(tooltip, macroName, rows, closingNote)
	tooltip:AddLine(GetColor("TITLE") .. macroName .. "|r")
	for _, row in ipairs(rows) do
		tooltip:AddDoubleLine(GetColor("HELP") .. row[1] .. "|r", GetColor("HELP") .. row[2] .. "|r")
	end
	if closingNote then
		tooltip:AddLine(GetColor("HELP") .. closingNote .. "|r", 1, 1, 1, true)
	end
end

local function KnownSpellName(spellList)
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return C_Spell.GetSpellName(data[1])
		end
	end
	return nil
end

--[[
    Each builder returns item blocks { itemID, itemLink, slot }, then a notes
    block { title, rows, note, types } per macro, types naming the consumable
    macros it covers. A row { click, job } is listed only for a known spell.
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
				{ L["MENU_CLICK_LEFT"], L["NOTE_APPLY_OFF_HAND"] },
				{ L["MENU_CLICK_RIGHT"], L["NOTE_APPLY_MAIN_HAND"] },
				{ L["MENU_CLICK_MIDDLE"], L["NOTE_OPEN_POISONS_WINDOW"] },
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

-- Built fresh every call: the items and known spells change as the player plays.
function ns.GetClassMacroNotes()
	local className, playerClass = UnitClass("player")
	local buildNotes = CLASS_NOTES[playerClass]
	local blocks = buildNotes and buildNotes()
	if not blocks or #blocks == 0 then
		return nil
	end
	return className, playerClass, blocks
end

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
