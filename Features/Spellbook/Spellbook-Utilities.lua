local _, ns = ...

--------------------------------------------------------------------------------
-- Spell Ranks
--------------------------------------------------------------------------------

-- Spells came in ranks until Cataclysm, so only these flavors offer Show All Spell Ranks.
ns.HAS_SPELL_RANKS = ns.EXPANSION ~= nil and ns.EXPANSION <= 3

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
	return ns.GetColor("TITLE") .. ns.L["ADDON_SHORT_NAME"] .. " // " .. ns.L["TAB_ENHANCED_SPELLBOOK"] .. "|r"
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
