local _, ns = ...
local L = ns.L
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local PixelLine = ns.SpellbookPixelLine
local FramePool = ns.SpellbookFramePool
local Bright = ns.WhatsNextBright
local MODELS = ns.WHATS_NEXT_MODELS
local Sections, Paginate = ns.WhatsNextSections, ns.WhatsNextPaginate
local BuildControls = ns.BuildWhatsNextControls
local METRICS = ns.WHATS_NEXT_METRICS

--[[
	The What's Next? tabs' pages in the Spell Book window (Features/Spellbook/Spellbook-Window.lua): the class
	spells, a hunter's or warlock's pet abilities, and the pet's own spellbook. Each is on the same parchment as
	the Spell Book page, two columns to a page, with a controls row along the top (filter box, source filter,
	sort, settings gear) and a footer of counts along the bottom. Sort By Availability lists the rows under each
	status, the ones to learn now first and Known last; Sort By Level under each learn level. The three pages
	differ only in their model, ns.WHATS_NEXT_MODELS (Features/Spellbook/Whats-Next/Whats-Next-Models.lua): the rows,
	statuses, sources, settings and tooltip lines. How the rows are ordered and filled into columns is
	Whats-Next-Layout.lua's, and the controls row and footer Whats-Next-Controls.lua's.
]]

-- The window's bands and the parchment's padding, as Features/Spellbook/Spellbook-Page.lua sets them.
local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local FOOTER_HEIGHT, FRAME_BORDER = ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER
local PARCHMENT_SIDE, PAGER_HEIGHT = ns.SPELLBOOK_PARCHMENT_SIDE, ns.SPELLBOOK_PAGER_HEIGHT
local COLUMN_TOP, COLUMN_SIDE = ns.SPELLBOOK_COLUMN_TOP, ns.SPELLBOOK_COLUMN_SIDE

-- A section's header and the space under it, then each spell's row, as Whats-Next-Layout.lua lays them out.
local HEADER_HEIGHT, HEADER_GAP, ROW_HEIGHT = METRICS.HEADER_HEIGHT, METRICS.HEADER_GAP, METRICS.ROW_HEIGHT
local ICON_SIZE = 22
local HEADER_SIZE, CONTINUED_SIZE, NAME_SIZE, NOTE_SIZE = 16, 12, 13, 12
--[[
	the row's right-hand fields: the source, then the level (or, sorted by level, the status). The source is as
	wide as the page's widest source label, so "Demon Trainer" stays on one line, and never narrower than
	MIN_SOURCE_WIDTH, so the columns line up between pages with short labels.
]]
local MIN_SOURCE_WIDTH, LEVEL_WIDTH, STATUS_WIDTH = 64, 64, 124
local EMPTY_WIDTH = 448 -- the empty note's wrap width, a Spell Book column's

local INK, FADED_INK = ns.INK_COLOR, ns.FADED_INK_COLOR
local HEADER_INK, RULE_COLOR = ns.SPELLBOOK_HEADER_INK, ns.SPELLBOOK_RULE_COLOR
local CONTINUED_INK, DIVIDER_COLOR = ns.SPELLBOOK_CONTINUED_INK, ns.SPELLBOOK_DIVIDER_COLOR
local INKS = ns.WHATS_NEXT_INKS
local FADED_SUBTEXT = CreateColor(unpack(FADED_INK)) -- made once, for the rank text every row wraps in it

local pages = {} -- each built page, for ns.RefreshWhatsNext

-- A spell's name with its rank (or "Passive") after it in faded ink, as "Rend (Rank 2)".
local function NameWithSubtext(name, subtext)
	if not subtext or subtext == "" then
		return name
	end
	return name .. " " .. FADED_SUBTEXT:WrapTextInColorCode(L["WHATS_NEXT_SUBTEXT"]:format(subtext))
end

--------------------------------------------------------------------------------
-- Page
--------------------------------------------------------------------------------

-- Builds a page for model in frame, which covers the window; returns the page.
local function BuildPage(frame, model)
	local page = frame
	page.rows = {}
	page.isPetPage = model ~= MODELS.CLASS

	local function SourceLabel(source)
		return source and model.sourceLabel(source) or ""
	end

	----------------------------------------------------------------------------
	-- Frames
	----------------------------------------------------------------------------

	-- A section's header: its name, "(Continued)" where it carries on from the column before, and a rule.
	local function CreateHeader()
		local header = CreateFrame("Frame", nil, page.parchment.paper)
		header:SetHeight(HEADER_HEIGHT)
		header.Text = SizedFontString(header, "GameFontNormalLarge", HEADER_SIZE)
		header.Text:SetShadowOffset(0, 0)
		header.Text:SetPoint("LEFT")
		header.Continued = SizedFontString(header, "GameFontNormal", CONTINUED_SIZE)
		header.Continued:SetTextColor(unpack(CONTINUED_INK))
		header.Continued:SetShadowOffset(0, 0)
		local rule = PixelLine(header, "ARTWORK", RULE_COLOR)
		rule:SetPoint("LEFT", header.Continued, "RIGHT", 8, 0)
		rule:SetPoint("RIGHT")
		return header
	end

	local function ShowRowTooltip(self)
		local row = self.row
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		-- the rows add their own ranks below, so the tooltip hook (Spell-Ranks-Tooltip.lua) stays out
		ns.spellTooltipHasOwnRanks = true
		GameTooltip:SetSpellByID(row.id)
		ns.spellTooltipHasOwnRanks = nil
		if not model.hideTooltipStatus then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(Bright(row.status, model.statusLabel(row.status)))
		end
		model.addTooltip(row, model)
		if not model.hideTooltipStatus and #ns.SpellRankRows(page.rows, row) > 1 then
			GameTooltip:AddLine(" ")
			ns.AddSpellRankLines(page.rows, row)
		end
		if C_Spell.GetSpellLink then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(
				ns.GetColor("INFO") .. L["TOOLTIP_KEY_SHIFT_CLICK"] .. "|r",
				ns.GetColor("INFO") .. L["TOOLTIP_ACTION_LINK_IN_CHAT"] .. "|r"
			)
		end
		GameTooltip:Show()
	end

	--[[
		Shift-click puts the spell's link in the chat box, as the game's own book does; on a page that places
		spells, a plain click picks it up.
	]]
	local function ClickRow(self)
		if IsModifiedClick("CHATLINK") then
			local link = C_Spell.GetSpellLink and C_Spell.GetSpellLink(self.row.id)
			if link then
				ChatEdit_InsertLink(link)
			end
		elseif model.pickup then
			model.pickup(self.row)
		end
	end

	-- One spell's row: its icon, its name and rank, and at its right the source and the level or status.
	local function CreateRow()
		local button = CreateFrame("Button", nil, page.parchment.paper)
		button:SetHeight(ROW_HEIGHT)
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetSize(ICON_SIZE, ICON_SIZE)
		button.icon:SetPoint("LEFT")
		button.right = SizedFontString(button, "GameFontNormal", NOTE_SIZE)
		button.right:SetShadowOffset(0, 0)
		button.right:SetJustifyH("RIGHT")
		button.right:SetPoint("RIGHT")
		button.source = SizedFontString(button, "GameFontNormal", NOTE_SIZE)
		button.source:SetShadowOffset(0, 0)
		button.source:SetTextColor(unpack(FADED_INK))
		button.source:SetJustifyH("RIGHT")
		button.source:SetWidth(page.sourceWidth)
		button.source:SetWordWrap(false)
		button.source:SetPoint("RIGHT", button.right, "LEFT", -8, 0)
		button.name = SizedFontString(button, "GameFontNormal", NAME_SIZE)
		button.name:SetShadowOffset(0, 0)
		button.name:SetJustifyH("LEFT")
		button.name:SetWordWrap(false)
		button.name:SetPoint("LEFT", button.icon, "RIGHT", 6, 0)
		button.name:SetPoint("RIGHT", button.source, "LEFT", -8, 0)
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints()
		highlight:SetColorTexture(INK[1], INK[2], INK[3], 0.08)
		button:SetScript("OnEnter", ShowRowTooltip)
		button:SetScript("OnLeave", HideTooltip)
		button:SetScript("OnClick", ClickRow)
		if model.pickup then
			button:RegisterForDrag("LeftButton")
			button:SetScript("OnDragStart", function(self)
				model.pickup(self.row)
			end)
		end
		return button
	end

	local function SetRow(button, row, byLevel)
		button.row = row
		button.icon:SetTexture(row.icon)
		-- known, or not this pet's to learn: faded
		local faded = row.status == "KNOWN" or row.status == "OTHER"
		button.icon:SetDesaturated(faded)
		button.name:SetText(NameWithSubtext(row.name, row.subtext))
		button.name:SetTextColor(unpack(faded and FADED_INK or INK))
		button.source:SetText(SourceLabel(row.source))
		button.right:SetTextColor(unpack(INKS[row.status]))
		if model.rightText then
			button.right:SetWidth(STATUS_WIDTH)
			button.right:SetText(model.rightText(row))
		elseif byLevel then
			button.right:SetWidth(STATUS_WIDTH)
			button.right:SetText(model.shortLabel(row.status))
		else
			button.right:SetWidth(LEVEL_WIDTH)
			button.right:SetText(row.level and L["SUBTEXT_LEARN_LEVEL"]:format(row.level) or "")
		end
	end

	----------------------------------------------------------------------------
	-- Layout
	----------------------------------------------------------------------------

	-- The footer on the dark frame: how many rows are in each counted status, and the model's own text at its right.
	local function UpdateFooter(context)
		local counts = {}
		for _, row in ipairs(page.rows) do
			counts[row.status] = (counts[row.status] or 0) + 1
		end
		local parts = {}
		for _, status in ipairs(model.counts) do
			parts[#parts + 1] = Bright(status, model.statusLabel(status))
				.. " "
				.. ns.GetColor("TEXT")
				.. (counts[status] or 0)
				.. "|r"
		end
		page.counts:SetText(table.concat(parts, "   "))
		page.footerText:SetText(model.footer and model.footer(context) or "")
	end

	local function Layout()
		page.headers:ReleaseAll()
		page.rowButtons:ReleaseAll()
		local controls = page.pagingControls
		local sections = Sections(page, model)
		if #sections == 0 then
			local text = page.filterText or ""
			local empty = type(model.empty) == "function" and model.empty(page.context) or L[model.empty]
			page.empty:SetText(text ~= "" and L["PAGE_NO_MATCHES_FOR"]:format(text) or empty)
			page.empty:Show()
			controls:SetMaxPages(1)
			controls:Hide()
			return
		end
		page.empty:Hide()
		local paper = page.parchment.paper
		local columns = Paginate(sections, paper:GetHeight() - COLUMN_TOP - PAGER_HEIGHT)
		local maxPages = math.ceil(#columns / 2)
		controls:SetMaxPages(maxPages)
		controls:Show()

		local byLevel = model.sortDescription and ns.WhatsNextSort() == "level"
		local current = math.min(controls:GetCurrentPage(), maxPages)
		local half = paper:GetWidth() / 2
		local width = half - 2 * COLUMN_SIDE
		local shift = page.parchment.spineShift -- toward the spine, as the Spell Book page does
		for side = 1, 2 do
			local x = (side - 1) * half + COLUMN_SIDE + (side == 1 and shift or -shift)
			for _, block in ipairs(columns[(current - 1) * 2 + side] or {}) do
				local top = COLUMN_TOP + block.y
				local header = page.headers:Acquire()
				header:SetPoint("TOPLEFT", paper, "TOPLEFT", x, -top)
				header:SetWidth(width)
				header.Text:SetText(block.section.name)
				header.Text:SetTextColor(unpack(block.section.status and INKS[block.section.status] or HEADER_INK))
				-- an empty "(Continued)" sits flush against the name, so the rule starts where it always does
				header.Continued:SetText(block.continued and L["PAGE_CONTINUED"] or "")
				header.Continued:SetPoint("LEFT", header.Text, "RIGHT", block.continued and 6 or 0, 0)
				top = top + HEADER_HEIGHT + HEADER_GAP
				for r = block.first, block.last do
					local button = page.rowButtons:Acquire()
					button:SetPoint("TOPLEFT", paper, "TOPLEFT", x, -top)
					button:SetWidth(width)
					SetRow(button, block.section.rows[r], byLevel)
					top = top + ROW_HEIGHT
				end
			end
		end
	end

	--[[
		Reads the rows again and redraws, the sort's label included, since a profile switch can change the sort.
		level is the level to read them against, for PLAYER_LEVEL_UP; nil reads the player's.
	]]
	function page.Refresh(level)
		local rows, context = model.rows(level)
		page.rows, page.context = rows, context
		if page.UpdateSortLabel then
			page.UpdateSortLabel()
		end
		page.UpdateSourceFilter()
		UpdateFooter(context)
		Layout()
	end

	----------------------------------------------------------------------------
	-- Build
	----------------------------------------------------------------------------

	local parchment = CreateFrame("Frame", nil, page)
	page.parchment = parchment
	parchment:SetPoint("TOPLEFT", PARCHMENT_SIDE, -(TITLE_HEIGHT + CONTROLS_HEIGHT))
	parchment:SetPoint("BOTTOMRIGHT", -PARCHMENT_SIDE, FRAME_BORDER + FOOTER_HEIGHT)
	parchment:SetClipsChildren(true)
	ns.DrawSpellbookParchment(parchment)
	local divider = PixelLine(parchment.paper, "BORDER", DIVIDER_COLOR, "VERTICAL")
	divider:SetPoint("TOP", 0, -COLUMN_TOP / 2)
	divider:SetPoint("BOTTOM", 0, PAGER_HEIGHT)

	-- the source column's width: its widest label, measured in the rows' own font
	local measure = SizedFontString(page, "GameFontNormal", NOTE_SIZE)
	measure:Hide()
	page.sourceWidth = MIN_SOURCE_WIDTH
	for _, source in ipairs(model.sources or {}) do
		measure:SetText(SourceLabel(source))
		page.sourceWidth = math.max(page.sourceWidth, math.ceil(measure:GetStringWidth()) + 2)
	end

	page.headers = FramePool(CreateHeader)
	page.rowButtons = FramePool(CreateRow)

	page.empty = parchment.paper:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.empty:SetTextColor(unpack(INK))
	page.empty:SetShadowOffset(0, 0)
	page.empty:SetPoint("CENTER", 0, PAGER_HEIGHT / 2)
	page.empty:SetWidth(EMPTY_WIDTH)
	page.empty:SetWordWrap(true)

	BuildControls(page, model, Layout, SourceLabel)

	-- the page strip along the parchment's bottom; the wheel turns the page anywhere on the parchment
	local controls = ns.CreatePagingControls(page, parchment.paper)
	page.pagingControls = controls
	controls:SetPoint("BOTTOMLEFT", parchment.paper, "BOTTOMLEFT", 14, 0)
	controls:SetPoint("BOTTOMRIGHT", parchment.paper, "BOTTOMRIGHT", -14, 0)
	function page:OnPageChanged()
		Layout()
	end
	parchment:EnableMouseWheel(true)
	parchment:SetScript("OnMouseWheel", function(_, delta)
		if controls:IsShown() then
			controls:OnMouseWheel(delta)
		end
	end)

	page:SetScript("OnShow", function()
		page.Refresh()
	end)
	pages[#pages + 1] = page
	return page
end

-- Builds the class spells' page in frame; the window shows it for the What's Next? tab.
function ns.BuildWhatsNextPage(frame)
	BuildPage(frame, MODELS.CLASS)
end

-- Builds the pet's spellbook page in frame; the window shows it for the Pet Spell Book tab.
function ns.BuildPetSpellbookPage(frame)
	BuildPage(frame, MODELS.PET_BOOK)
end

-- Builds the pet abilities' page in frame; the window shows it for a hunter's or warlock's Pet What's Next? tab.
function ns.BuildWhatsNextPetPage(frame)
	BuildPage(frame, MODELS.PET)
end

--[[
	Redraws whichever of these pages is open, after the spells known, the player's level or the pet change
	(Features/Spellbook/Spellbook-Events.lua); level as page.Refresh takes it.
]]
function ns.RefreshWhatsNext(level)
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			page.Refresh(level)
		end
	end
end

-- The same for the pet tabs alone, after a pet change, which the class's spells don't follow.
function ns.RefreshWhatsNextPet()
	for _, page in ipairs(pages) do
		if page.isPetPage and page:IsVisible() then
			page.Refresh()
		end
	end
end

-- Whether a pet tab is open.
function ns.IsWhatsNextPetShown()
	for _, page in ipairs(pages) do
		if page.isPetPage and page:IsVisible() then
			return true
		end
	end
	return false
end

function ns.IsWhatsNextShown()
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			return true
		end
	end
	return false
end
