local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Macro Runtime Globals
--------------------------------------------------------------------------------

-- Global on purpose: /run cannot see the add-on namespace. "GtG" is short because every byte counts.

local macroFireState = {}

-- The same [combat] test the body's own lines use picks which item the press fired.
function GtGFire(itemID, outOfCombatID)
	if outOfCombatID and not UnitAffectingCombat("player") then
		itemID = outOfCombatID
	end
	macroFireState.lastID = itemID
	macroFireState.lastTime = GetTime()
end

-- A wrong-zone error within a second of a press names the item in a bug report.
function ns.OnMacroUiErrorMessage(message)
	if not (macroFireState.lastTime and (GetTime() - macroFireState.lastTime) < 1.0) then
		return
	end
	if message ~= ERR_ITEM_WRONG_ZONE then
		return
	end

	local mapID = C_Map.GetBestMapForUnit("player") or "0"
	local zone = GetZoneText() or "?"
	local subzone = GetSubZoneText() or ""
	if subzone == "" then
		subzone = zone
	end

	local itemID = macroFireState.lastID or 0
	local link = ns.GetItemHyperlink(itemID)

	ns:PrintMessage(string.format(L["MESSAGE_BUG_REPORT"], link, itemID, zone, subzone, mapID, ns.LINKS.DISCORD))
	macroFireState.lastTime = 0
end

-- A spell this client lacks resolves to nil, so GtGTip stays silent rather than name it.
local PET_SKILL_SPELL_IDS = {
	ns.CALL_PET_SPELL_ID,
	ns.DISMISS_PET_SPELL_ID,
	ns.FEED_PET_SPELL_ID,
	ns.REVIVE_PET_SPELL_ID,
}

local function ResolvePetSkillsTip()
	local names = {}
	for index = 1, 4 do
		local spellID = PET_SKILL_SPELL_IDS[index]
		names[index] = spellID and C_Spell.GetSpellName(spellID)
		if not names[index] then
			return nil
		end
	end
	return string.format(L["TIP_PET_NO_SKILLS_FORMAT"], unpack(names))
end

local function ResolveTipText(key)
	if ns.TIP_MESSAGES[key] then
		return ns.TIP_MESSAGES[key]
	end
	if key == "noPetSkills" then
		return ResolvePetSkillsTip()
	end
	if ns.MISSING_SPELL_MESSAGE_IDS[key] then
		local name = C_Spell.GetSpellName(ns.MISSING_SPELL_MESSAGE_IDS[key])
		if not name then
			return nil
		end
		return string.format(L["TIP_DONT_KNOW_SPELL"], name)
	end
	return nil
end

function GtGTip(key)
	local text = ResolveTipText(key)
	if text then
		ns:PrintMessage(text)
	end
end

-- The " 1" sentinel makes SecureCmdOptionParse return "1" or nil, whatever it does with an empty action.
function GtGTipIf(condition, key)
	if SecureCmdOptionParse(condition .. " 1") then
		GtGTip(key)
	end
end

--[[
    The body passes the English type key, keeping bodies and state keys
    locale-free; an unknown key prints raw so a stale body still says something.
]]
function ns.BuildNoItemLine(typeName, canMake)
	local config = ns.MACRO_CONFIG[typeName]
	local label = config and config.label or typeName
	if canMake and config then
		local key = ns.isWarlock and "TIP_EMPTY_CREATE" or "TIP_EMPTY_CONJURE"
		return string.format(L[key], label, config.macro)
	end
	return string.format(L["MESSAGE_NO_ITEM"], label)
end

function GtGNoItem(typeName, canMake)
	ns:PrintMessage(ns.BuildNoItemLine(typeName, canMake))
end

-- Only this popup: a Delete Item or any other open confirmation is left alone.
function GtGReplace()
	if StaticPopup_Visible("REPLACE_ENCHANT") then
		C_Item.ReplaceEnchant()
		StaticPopup_Hide("REPLACE_ENCHANT")
	end
end

--[[
    MIGRATION (remove after 2026-12-08): the names these callbacks had before
    the GtG prefix. A macro body written under them can still be pressed before
    its next rewrite, such as after logging in mid-combat.
]]
ConnoisseurFire = GtGFire
ConnoisseurTip = GtGTip
ConnoisseurTipIf = GtGTipIf
ConnoisseurNoItem = GtGNoItem
