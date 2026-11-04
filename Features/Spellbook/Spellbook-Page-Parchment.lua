local _, ns = ...
local PixelInset = ns.PixelInset

--[[
	The Spell Book page's parchment (Features/Spellbook/Spellbook-Page.lua), which the What's Next? pages
	(Features/Spellbook/Whats-Next-Page.lua) share, and the one-pixel lines its rules and divider are drawn with.
]]

-- A solid line texture on parent, one screen pixel thick along the given axis ("HORIZONTAL" or "VERTICAL").
local function PixelLine(parent, layer, color, axis)
	local line = parent:CreateTexture(nil, layer)
	line:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	local setter = axis == "VERTICAL" and "SetWidth" or "SetHeight"
	if PixelUtil then
		PixelUtil[setter](line, 1, 1)
	else
		line[setter](line, 1)
	end
	return line
end

-- The parchment's colours.
local PARCHMENT_COLOR = { 0.847, 0.765, 0.6 }
local VIGNETTE_COLOR = { 0.36, 0.235, 0.086 } -- the aged edges, darker toward the border
local EDGE_COLOR = { 0.043, 0.043, 0.043 }
local INNER_EDGE_COLOR = { 0.42, 0.353, 0.243 }

-- Forever's parchment, where this build has it; otherwise the parchment colour with darkened edges
local ATLAS_PAGE_LEFT, ATLAS_PAGE_RIGHT = "spellbook-Page-Left-C60", "spellbook-Page-Right-C60"
local VIGNETTE_WIDTH, VIGNETTE_ALPHA = 46, 0.24

--[[
	The parchment: a black edge and a thin brown line inside it, then Forever's page art where the build has
	it, else the parchment colour with its edges darkened.
]]
local function DrawParchment(parchment)
	local edge = parchment:CreateTexture(nil, "BACKGROUND", nil, -8)
	edge:SetAllPoints()
	edge:SetColorTexture(unpack(EDGE_COLOR))
	local inner = parchment:CreateTexture(nil, "BACKGROUND", nil, -7)
	inner:SetColorTexture(unpack(INNER_EDGE_COLOR))
	PixelInset(inner, parchment, 2)
	local paper = CreateFrame("Frame", nil, parchment)
	PixelInset(paper, parchment, 3)
	parchment.paper = paper
	if C_Texture.GetAtlasInfo(ATLAS_PAGE_LEFT) and C_Texture.GetAtlasInfo(ATLAS_PAGE_RIGHT) then
		local left = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
		left:SetAtlas(ATLAS_PAGE_LEFT)
		left:SetPoint("TOPLEFT", paper)
		left:SetPoint("BOTTOMRIGHT", paper, "BOTTOM")
		local right = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
		right:SetAtlas(ATLAS_PAGE_RIGHT)
		right:SetPoint("TOPLEFT", paper, "TOP")
		right:SetPoint("BOTTOMRIGHT", paper)
		return
	end
	local base = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
	base:SetAllPoints(paper)
	base:SetColorTexture(unpack(PARCHMENT_COLOR))
	-- a strip down each edge, the aged colour fading to clear toward the middle
	if not CreateColor then
		return
	end
	local dark = CreateColor(VIGNETTE_COLOR[1], VIGNETTE_COLOR[2], VIGNETTE_COLOR[3], VIGNETTE_ALPHA)
	local clear = CreateColor(VIGNETTE_COLOR[1], VIGNETTE_COLOR[2], VIGNETTE_COLOR[3], 0)
	local function strip(point, relative, horizontal, from, to)
		local texture = parchment:CreateTexture(nil, "BACKGROUND", nil, -5)
		texture:SetColorTexture(1, 1, 1)
		texture:SetPoint(point, paper, point)
		texture:SetPoint(relative, paper, relative)
		if horizontal then
			texture:SetWidth(VIGNETTE_WIDTH)
		else
			texture:SetHeight(VIGNETTE_WIDTH)
		end
		pcall(texture.SetGradient, texture, horizontal and "HORIZONTAL" or "VERTICAL", from, to)
	end
	strip("TOPLEFT", "BOTTOMLEFT", true, dark, clear)
	strip("TOPRIGHT", "BOTTOMRIGHT", true, clear, dark)
	strip("BOTTOMLEFT", "BOTTOMRIGHT", false, dark, clear)
	strip("TOPLEFT", "TOPRIGHT", false, clear, dark)
end

-- the What's Next? tab's page (Features/Spellbook/Whats-Next-Page.lua) shares the parchment and its drawing
ns.SpellbookPixelLine = PixelLine
ns.DrawSpellbookParchment = DrawParchment
