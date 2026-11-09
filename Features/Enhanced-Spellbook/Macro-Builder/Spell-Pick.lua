local _, ns = ...
local L = ns.L
local INFO = ns.COLORS_RGB.INFO
local SizedFontString = ns.SizedFontString
local Widgets = ns.PanelWidgets
local Box = Widgets.Box

local FIELD_FILL = Widgets.COLORS.FIELD_FILL
local NO_ROWS = {}

--[[
	The spells in the docked panels' slots, a Conditionals row's and a Cast Sequence step's: what one casts, read
	from the client now, the pick a page macro or a dragged spell gives it, and pick mode, which fills one from
	the page.
]]

--------------------------------------------------------------------------------
-- Slot Spells
--------------------------------------------------------------------------------

--[[
	What a row casts, read from the client now: its name and, for a row fixed to a rank, that rank's text, or nil
	while the spell's data isn't loaded. A ranged row names the client's Shoot.
]]
function ns.ConditionalSpellName(row)
	if row.ranged then
		return C_Spell.GetSpellName(ns.SHOOT_SPELL_ID), nil
	end
	local name = row.spellID and C_Spell.GetSpellName(row.spellID)
	local rank = name and row.fixed and C_Spell.GetSpellSubtext(row.spellID)
	return name, rank ~= "" and rank or nil
end

-- What a row casts, as the macro text names it: "Frostbolt", or "Frostbolt(Rank 1)" for a row fixed to a rank.
function ns.ConditionalSpellText(row)
	local name, rank = ns.ConditionalSpellName(row)
	return name and name .. (rank and "(" .. rank .. ")" or "")
end

-- Whether a spell ID is one of the macro's known ranks.
local function IsKnownRank(macro, spellID)
	for _, rank in ipairs(macro.ranks or NO_ROWS) do
		if rank.id == spellID then
			return true
		end
	end
	return false
end

--[[
	The spell a page macro gives a row, as { spellID, fixed, ranged }, or nil for one that can't be picked: a
	consumable's, which is an item, and a spell not learned yet. A rank's own macro, or one with a Fixed Rank,
	gives that rank, fixed; the Shoot macro gives ranged, the attack for whatever ranged weapon is worn.
]]
function ns.ConditionalSpellOf(macro)
	if macro.consumable or macro.unlearned then
		return nil
	end
	if macro.rangedAttacks then
		return { ranged = true }
	end
	local fixedID = ns.FixedRankID(macro)
	if fixedID then
		return { spellID = fixedID, fixed = true }
	end
	local top = macro.ranks and macro.ranks[1]
	return { spellID = top and top.id or macro.spellID }
end

--[[
	A spell from a spellbook or an action bar, by its ID, as a row's pick: fixed when it's a lower rank than the
	highest its page macro knows, so the rank dragged is the rank cast. The page macro is found by the rank's ID
	among its known ranks, never by name.
]]
function ns.ConditionalPickOfSpell(spellID)
	for _, macro in ipairs(ns.macros or NO_ROWS) do
		if not macro.copy and not macro.focus and not macro.rank and IsKnownRank(macro, spellID) then
			if macro.ranks[1].id ~= spellID then
				return { spellID = spellID, fixed = true }
			end
			break
		end
	end
	return { spellID = spellID }
end

--------------------------------------------------------------------------------
-- Pick Mode
--------------------------------------------------------------------------------

--[[
	Pick mode, for the panels docked beside the Spell Book: a slot waiting for the next spell clicked on the page,
	or a spell dropped on it from the cursor. The Conditionals panel (Features/Enhanced-Spellbook/Macro-Builder/Conditionals-Panel.lua)
	and the Cast Sequence panel (Features/Enhanced-Spellbook/Macro-Builder/Cast-Sequence-Panel.lua) each start it for a slot of theirs,
	as an owner: { panel, the frame that takes the keyboard and whose page shows the overlay; pickOf(macro), the
	pick a page macro gives a slot, or nil for one it can't; actionKey, the locale key of a tile's Click line;
	cannotPickKey, the locale key of the error line for one it can't; apply(index, pick), which fills the slot; redraw() and update(), which draw the page and the
	panel again }.
]]

local picking -- the index of the slot waiting for a spell, while the page is in pick mode
local owner -- the panel's owner whose slot it is

--[[
	The page's look in pick mode: a blue edge around the parchment and a banner across its top saying what a
	click does. It takes no clicks, so they reach the tiles under it. Each panel keeps its own.
]]
local function PickOverlay(who)
	local panel = who.panel
	if panel.overlay then
		return panel.overlay
	end
	local parchment = panel.page.parchment
	local overlay = CreateFrame("Frame", nil, parchment)
	overlay:SetAllPoints()
	overlay:SetFrameLevel(parchment:GetFrameLevel() + 50)
	overlay:EnableMouse(false)
	-- each edge as { one corner, the other, the setter for its thickness }
	for _, edge in ipairs({
		{ "TOPLEFT", "TOPRIGHT", "SetHeight" },
		{ "BOTTOMLEFT", "BOTTOMRIGHT", "SetHeight" },
		{ "TOPLEFT", "BOTTOMLEFT", "SetWidth" },
		{ "TOPRIGHT", "BOTTOMRIGHT", "SetWidth" },
	}) do
		local line = overlay:CreateTexture(nil, "OVERLAY")
		line:SetColorTexture(INFO.r, INFO.g, INFO.b)
		line:SetPoint(edge[1])
		line:SetPoint(edge[2])
		line[edge[3]](line, 2)
	end
	local banner = CreateFrame("Frame", nil, overlay)
	banner:SetPoint("TOP", 0, -8)
	banner:SetHeight(26)
	Box(banner, FIELD_FILL, { INFO.r, INFO.g, INFO.b })
	local text = SizedFontString(banner, "GameFontHighlight", 13, "OVERLAY")
	text:SetPoint("CENTER")
	text:SetText(L["CONDITIONALS_PICK_BANNER"])
	banner:SetWidth(math.ceil(text:GetStringWidth()) + 28)
	overlay:Hide()
	panel.overlay = overlay
	return overlay
end

-- Shows or hides an owner's pick mode look: the overlay, and the keyboard its panel takes.
local function ShowPicking(who, on)
	if who and who.panel then
		PickOverlay(who):SetShown(on)
		who.panel:EnableKeyboard(on)
	end
end

--[[
	Starts or ends pick mode for an owner's slot (index, or nil to end it). While it is on, the owner's panel
	takes the keyboard so Escape ends it rather than closing the window; it never starts in combat, where a
	frame can't take the keyboard, and combat ends it. Starting it for one panel ends it for the other.
]]
local function SetPicking(index, who)
	if owner and owner ~= who then
		ShowPicking(owner, false)
	end
	picking, owner = index, index and who or nil
	if who then
		ShowPicking(who, index ~= nil)
		who.redraw()
		who.update()
	end
end

function ns.IsPickingSpell()
	return picking ~= nil
end

ns.SetSpellPicking = SetPicking

function ns.CancelSpellPick()
	if picking then
		SetPicking(nil, owner)
	end
end

-- Whether pick mode is on for an owner's slot at index.
function ns.IsPickingSpellFor(who, index)
	return picking ~= nil and owner == who and picking == index
end

-- Starts pick mode for an owner's slot, or says it can't in combat.
function ns.StartSpellPick(who, index)
	if InCombatLockdown() then
		ns.ShowUIError(ERR_NOT_IN_COMBAT)
		return
	end
	SetPicking(index, who)
end

-- The pick a page macro gives the slot waiting in pick mode, or nil, for a tile that can't fill it.
function ns.PickSpellOf(macro)
	return owner and owner.pickOf(macro) or nil
end

-- A tile's tooltip in pick mode, in the words of the panel whose slot is waiting: what a click does with it.
function ns.PickActionText()
	return L[owner and owner.actionKey or "CONDITIONALS_ACTION_USE"]
end

-- And why a tile can't fill the slot.
function ns.CannotPickText()
	return L[owner and owner.cannotPickKey or "CONDITIONALS_CANNOT_PICK"]
end

--[[
	A page tile clicked in pick mode (Features/Enhanced-Spellbook/Macro-Button.lua): its spell fills the slot waiting for
	one. A tile that can't be picked leaves pick mode on, with the game's error line saying why.
]]
function ns.PickSpell(macro)
	local index, who = picking, owner
	local pick = who and who.pickOf(macro)
	if not pick then
		ns.ShowUIError(L[who and who.cannotPickKey or "CONDITIONALS_CANNOT_PICK"])
		return
	end
	SetPicking(nil, who)
	who.apply(index, pick)
end

--[[
	The spell on the cursor as a slot's pick, or nil: a page macro dragged from its tile gives pickOf(macro),
	another macro the spell it would cast now, a spell from a spellbook or an action bar its own ID, at the rank
	dragged (ns.ConditionalPickOfSpell).
]]
local function SpellFromCursor(pickOf)
	local kind, id, _, spellID = GetCursorInfo()
	if kind == "macro" then
		local indexes = ns.ReadMacroIndexes()
		for _, macro in ipairs(ns.macros) do
			if ns.FindMacroIndex(macro, indexes) == id then
				return pickOf(macro)
			end
		end
		local spell = GetMacroSpell(id)
		if type(spell) == "string" then
			local info = C_Spell.GetSpellInfo(spell)
			spell = info and info.spellID
		end
		return type(spell) == "number" and { spellID = spell } or nil
	elseif kind == "spell" and spellID then
		return ns.ConditionalPickOfSpell(spellID)
	end
	return nil
end

-- Fills an owner's slot from the cursor and clears it; returns whether the cursor held a spell it takes.
function ns.DropSpellOnSlot(who, index)
	local pick = SpellFromCursor(who.pickOf)
	if not pick then
		return false
	end
	ClearCursor()
	ns.CancelSpellPick()
	who.apply(index, pick)
	return true
end
