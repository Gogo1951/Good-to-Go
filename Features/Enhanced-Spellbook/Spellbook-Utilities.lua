local _, ns = ...
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Spell Ranks
--------------------------------------------------------------------------------

-- Spells came in ranks until Cataclysm, so only these flavors offer Show All Spell Ranks.
ns.HAS_SPELL_RANKS = ns.EXPANSION ~= nil and ns.EXPANSION <= 3

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

-- A hex color ("D8C399") as the { r, g, b } list the texture calls unpack.
function ns.HexToColorList(hex)
	local rgb = ns.HexToRGB(hex)
	return { rgb.r, rgb.g, rgb.b }
end

--------------------------------------------------------------------------------
-- Spell Names
--------------------------------------------------------------------------------

--[[
	Spell ids asked for once, so an id that never loads can't keep the page redrawing: true while the answer
	is outstanding, "answered" once SPELL_DATA_LOAD_RESULT has brought it.
]]
local requested = {}

-- A spell's name, or nil while its data isn't loaded (it is then requested); every Spellbook file shares it.
function ns.SpellName(id)
	local name = C_Spell.GetSpellName(id)
	if not name and not requested[id] then
		requested[id] = true
		C_Spell.RequestLoadSpellData(id)
	end
	return name
end

-- Whether id is a spell ns.SpellName asked the client for and is still waiting on; marks it answered.
function ns.TakeRequestedSpell(id)
	if requested[id] == true then
		requested[id] = "answered"
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Text
--------------------------------------------------------------------------------

--[[
	Lua's lower() folds only the Latin letters, so a Russian name typed in lower case would never match its
	capital. Cyrillic capitals are two UTF-8 bytes: А-П (\208\144-\208\159) step to \208\176-\208\191,
	Р-Я (\208\160-\208\175) to \209\128-\209\143, and Ё (\208\129) to \209\145.
]]
local function LowerCyrillic(second)
	local byte = second:byte()
	if byte == 129 then
		return "\209\145"
	elseif byte <= 159 then
		return "\208" .. string.char(byte + 32)
	end
	return "\209" .. string.char(byte - 32)
end

-- text in lower case for the pages' filter boxes, Cyrillic included.
function ns.FilterLower(text)
	return (text:lower():gsub("\208([\129\144-\175])", LowerCyrillic))
end

--------------------------------------------------------------------------------
-- Frames
--------------------------------------------------------------------------------

function ns.HideTooltip(owner)
	if GameTooltip:IsOwned(owner) then
		GameTooltip:Hide()
	end
end

-- The heading of the tooltip on the game spellbook's tab: "GtG // Enhanced Spellbook", gold like a tooltip title.
function ns.SpellbookTabTitle()
	return GetColor("TITLE") .. ns.L["ADDON_SHORT_NAME"] .. " // " .. ns.L["TAB_ENHANCED_SPELLBOOK"] .. "|r"
end

--[[
	Pins region inside parent, offset UI units in from every edge, snapped to whole screen pixels and never
	less than offset pixels, so a 1-unit edge drawn around it stays one pixel at any UI scale.
]]
function ns.PixelInset(region, parent, offset)
	region:ClearAllPoints()
	if PixelUtil then
		PixelUtil.SetPoint(region, "TOPLEFT", parent, "TOPLEFT", offset, -offset, offset, offset)
		PixelUtil.SetPoint(region, "BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset, offset, offset)
	else
		region:SetPoint("TOPLEFT", offset, -offset)
		region:SetPoint("BOTTOMRIGHT", -offset, offset)
	end
end

--[[
	A font string in a FontObject's face at a size of its own, so a UI skin that changes the game's fonts
	(ElvUI) still sets its face.
]]
function ns.SizedFontString(parent, fontObject, size, layer)
	local fontString = parent:CreateFontString(nil, layer or "ARTWORK", fontObject)
	local face, _, flags = fontString:GetFont()
	if face then
		fontString:SetFont(face, size, flags)
	end
	return fontString
end

--[[
	A pool of frames made by create, shared by the Spell Book and What's Next? pages: Acquire hands out pooled
	frames in order; ReleaseAll hides the ones from the last layout.
]]
function ns.SpellbookFramePool(create)
	local pool = { used = 0 }
	function pool:Acquire()
		self.used = self.used + 1
		local frame = self[self.used] or create()
		self[self.used] = frame
		frame:ClearAllPoints()
		frame:Show()
		return frame
	end
	function pool:ReleaseAll()
		for i = 1, #self do
			self[i]:Hide()
		end
		self.used = 0
	end
	return pool
end

-- the small dark buttons that hold the gold gear
local GEAR_FILL = ns.HexToColorList("2A2520")
local GEAR_EDGE = ns.HexToColorList("8C7A52")

-- A small dark square button with the gold gear: a category's settings, or a page's.
function ns.CreateSpellbookGearButton(parent, size)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(size, size)
	local edge = button:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints()
	edge:SetColorTexture(unpack(GEAR_EDGE))
	local fill = button:CreateTexture(nil, "BORDER")
	fill:SetColorTexture(unpack(GEAR_FILL))
	ns.PixelInset(fill, button, 1)
	local gear = button:CreateTexture(nil, "ARTWORK")
	gear:SetTexture(ns.TEXTURE_GEAR)
	local gold = ns.COLORS_RGB.TITLE
	gear:SetVertexColor(gold.r, gold.g, gold.b)
	local glyphSize = math.floor(size * 0.62 + 0.5)
	gear:SetSize(glyphSize, glyphSize)
	gear:SetPoint("CENTER")
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(fill)
	highlight:SetColorTexture(1, 1, 1, 0.12)
	-- nudged while held down, like the game's buttons
	button:SetScript("OnMouseDown", function()
		gear:SetPoint("CENTER", 1, -1)
	end)
	button:SetScript("OnMouseUp", function()
		gear:SetPoint("CENTER")
	end)
	button:SetScript("OnLeave", ns.HideTooltip)
	return button
end

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
	A WoW macro name cut to at most maxBytes (default ns.MACRO_NAME_MAX_LENGTH), backing up to the start of
	any UTF-8 character the cut would split, so a Russian, Korean or Chinese name never ends in a broken byte.
]]
function ns.TrimMacroName(name, maxBytes)
	maxBytes = maxBytes or ns.MACRO_NAME_MAX_LENGTH
	local cut = maxBytes + 1
	while cut > 1 and (name:byte(cut) or 0) >= 0x80 and name:byte(cut) < 0xC0 do
		cut = cut - 1
	end
	return name:sub(1, cut - 1)
end
