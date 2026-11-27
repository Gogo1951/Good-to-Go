local _, ns = ...
local PixelInset = ns.PixelInset

-- One screen pixel thick along axis ("HORIZONTAL" or "VERTICAL").
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

local PARCHMENT_COLOR = ns.HexToColorList("D8C399")
local VIGNETTE_COLOR = ns.HexToColorList("5C3C16") -- the aged edges, darker toward the border
local EDGE_COLOR = ns.HexToColorList("0B0B0B")
local INNER_EDGE_COLOR = ns.HexToColorList("6B5A3E")

-- Forever's parchment, where this build has it; otherwise the parchment color with darkened edges
local ATLAS_PAGE_LEFT, ATLAS_PAGE_RIGHT = "spellbook-Page-Left-C60", "spellbook-Page-Right-C60"
local VIGNETTE_WIDTH, VIGNETTE_ALPHA = 46, 0.24
--[[
	Forever's page art has a dark band along its top for the game's own headers: the crop cuts past it and part
	of its fade, so each first header sits on lighter paper. The paper curls in at each outer edge and runs flat
	to the spine, so the columns shift toward the spine to sit evenly between the two.
]]
local ART_TOP_CROP = 0.12
local ART_SPINE_SHIFT = 6

local function SetCroppedAtlas(texture, atlas)
	texture:SetAtlas(atlas)
	local left, top, _, bottom, right = texture:GetTexCoord()
	texture:SetTexCoord(left, right, top + (bottom - top) * ART_TOP_CROP, bottom)
end

-- Sets parchment.spineShift, how far each page's columns move toward the spine (0 without the art).
local function DrawParchment(parchment)
	parchment.spineShift = 0
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
		SetCroppedAtlas(left, ATLAS_PAGE_LEFT)
		left:SetPoint("TOPLEFT", paper)
		left:SetPoint("BOTTOMRIGHT", paper, "BOTTOM")
		local right = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
		SetCroppedAtlas(right, ATLAS_PAGE_RIGHT)
		right:SetPoint("TOPLEFT", paper, "TOP")
		right:SetPoint("BOTTOMRIGHT", paper)
		parchment.spineShift = ART_SPINE_SHIFT
		return
	end
	local base = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
	base:SetAllPoints(paper)
	base:SetColorTexture(unpack(PARCHMENT_COLOR))
	-- a strip down each edge, the aged color fading to clear toward the middle
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

-- shared with the What's Next? pages
ns.SpellbookPixelLine = PixelLine
ns.DrawSpellbookParchment = DrawParchment
