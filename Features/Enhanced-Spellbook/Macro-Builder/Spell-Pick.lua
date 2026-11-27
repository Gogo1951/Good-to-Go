local _, ns = ...
local L = ns.L
local INFO = ns.COLORS_RGB.INFO
local Widgets = ns.PanelWidgets
local Box = Widgets.Box

local FIELD_FILL = Widgets.COLORS.FIELD_FILL

--------------------------------------------------------------------------------
-- Pick Mode
--------------------------------------------------------------------------------

--[[
	An owner is { panel (takes the keyboard; its page shows the overlay), pickOf(macro) (nil for one it can't
	take), actionKey, cannotPickKey (locale keys), apply(index, pick), redraw(), update() }.
]]

local picking -- the slot index waiting for a spell
local owner

-- It takes no clicks, so they reach the tiles under it.
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
	banner:SetHeight(32)
	Box(banner, FIELD_FILL, { INFO.r, INFO.g, INFO.b })
	local text = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("CENTER")
	text:SetText(L["CONDITIONALS_PICK_BANNER"])
	banner:SetWidth(math.ceil(text:GetStringWidth()) + 32)
	overlay:Hide()
	panel.overlay = overlay
	return overlay
end

local function ShowPicking(who, on)
	if who and who.panel then
		PickOverlay(who):SetShown(on)
		who.panel:EnableKeyboard(on)
	end
end

--[[
	The panel takes the keyboard so Escape ends pick mode rather than closing the window; it never starts in
	combat, where a frame can't take the keyboard, and combat ends it.
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

function ns.IsPickingSpellFor(who, index)
	return picking ~= nil and owner == who and picking == index
end

function ns.StartSpellPick(who, index)
	if InCombatLockdown() then
		ns.ShowUIError(ERR_NOT_IN_COMBAT)
		return
	end
	SetPicking(index, who)
end

function ns.PickSpellOf(macro)
	return owner and owner.pickOf(macro) or nil
end

function ns.PickActionText()
	return L[owner and owner.actionKey or "CONDITIONALS_ACTION_USE"]
end

function ns.CannotPickText()
	return L[owner and owner.cannotPickKey or "CONDITIONALS_CANNOT_PICK"]
end

-- A tile that can't be picked leaves pick mode on, with the game's error line saying why.
function ns.PickSpell(macro)
	local index, who = picking, owner
	local pick = who and who.pickOf(macro)
	if not pick then
		ns.ShowUIError(L["ADDON_SHORT_NAME"] .. " // " .. L[who and who.cannotPickKey or "CONDITIONALS_CANNOT_PICK"])
		return
	end
	SetPicking(nil, who)
	who.apply(index, pick)
end

-- Another add-on's or the player's macro gives the spell it would cast now.
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

-- Returns whether the cursor held a spell the slot takes.
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
