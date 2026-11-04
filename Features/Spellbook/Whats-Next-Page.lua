local _, ns = ...
local TITLE = ns.COLORS_RGB.TITLE
local L = ns.L
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local PixelLine = ns.SpellbookPixelLine
local FramePool = ns.SpellbookFramePool
local NameBefore = ns.SpellNameBefore
local Bright = ns.WhatsNextBright
local MODELS = ns.WHATS_NEXT_MODELS

--[[
	The What's Next? tabs' pages in the Spell Book window (Features/Spellbook/Spellbook-Window.lua): the class
	spells, a hunter's or warlock's pet abilities, and the pet's own spellbook. Each is on the same parchment as
	the Spell Book page, two columns to a page, with a controls row along the top (filter box, source filter,
	sort, settings gear) and a footer of counts along the bottom. Sort By Availability lists the rows under each
	status, the ones to learn now first and Known last; Sort By Level under each learn level. The three pages
	differ only in their model, ns.WHATS_NEXT_MODELS (Features/Spellbook/Whats-Next-Models.lua): the rows,
	statuses, sources, settings and tooltip lines.
]]

-- The window's bands and the parchment's padding, as Features/Spellbook/Spellbook-Page.lua sets them.
local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local FOOTER_HEIGHT, FRAME_BORDER = ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER
local PARCHMENT_SIDE, PAGER_HEIGHT = ns.SPELLBOOK_PARCHMENT_SIDE, ns.SPELLBOOK_PAGER_HEIGHT
local COLUMN_TOP, COLUMN_SIDE = ns.SPELLBOOK_COLUMN_TOP, ns.SPELLBOOK_COLUMN_SIDE

-- A section's header, the space under it and the space over the next one; then each spell's row.
local HEADER_HEIGHT, HEADER_GAP, SECTION_GAP = 20, 6, 18
local ROW_HEIGHT, ICON_SIZE = 26, 22
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

local function nop() end

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

	local STATUS_RANK = {}
	for rank, status in ipairs(model.statuses) do
		STATUS_RANK[status] = rank
	end

	local function SourceLabel(source)
		return source and model.sourceLabel(source) or ""
	end

	----------------------------------------------------------------------------
	-- Order
	----------------------------------------------------------------------------

	-- Whether a row passes the filters: its name holds the filter text, it's from the picked source, and it's shown.
	local function PassesFilters(row)
		local text = page.filterText
		if text and text ~= "" and not ns.FilterLower(row.name):find(ns.FilterLower(text), 1, true) then
			return false
		end
		if page.sourceFilter and row.source ~= page.sourceFilter then
			return false
		end
		return model.shows(row)
	end

	-- Rows without a level sort as level 0: nothing holds them back.
	local function LevelOf(row)
		return row.level or 0
	end

	local function ByName(a, b)
		if a.name ~= b.name then
			return NameBefore(a.name, b.name)
		end
		return a.id < b.id
	end

	--[[
		The filtered rows as sections, each { name, status, rows }: under each status in the model's order, by
		level then name within it; or, sorted by level, under each learn level, by status then name. status is
		the section's own status, for its header's ink, or nil under a level.
	]]
	local function Sections()
		local rows = {}
		for _, row in ipairs(page.rows) do
			if PassesFilters(row) then
				rows[#rows + 1] = row
			end
		end
		local byLevel = model.sortDescription and ns.WhatsNextSort() == "level"
		table.sort(rows, function(a, b)
			local aStatus, bStatus = STATUS_RANK[a.status], STATUS_RANK[b.status]
			if byLevel then
				if LevelOf(a) ~= LevelOf(b) then
					return LevelOf(a) < LevelOf(b)
				end
				if aStatus ~= bStatus then
					return aStatus < bStatus
				end
				return ByName(a, b)
			end
			if aStatus ~= bStatus then
				return aStatus < bStatus
			end
			if LevelOf(a) ~= LevelOf(b) then
				return LevelOf(a) < LevelOf(b)
			end
			return ByName(a, b)
		end)
		local sections, section = {}, nil
		for _, row in ipairs(rows) do
			local name
			if byLevel then
				name = row.level and L["SUBTEXT_LEARN_LEVEL"]:format(row.level) or L["WHATS_NEXT_ANY_LEVEL"]
			else
				name = model.statusLabel(row.status)
			end
			if not section or section.name ~= name then
				section = { name = name, status = not byLevel and row.status or nil, rows = {} }
				sections[#sections + 1] = section
			end
			section.rows[#section.rows + 1] = row
		end
		return sections
	end

	--[[
		Fills columns in order (page 1 left, page 1 right, page 2 left, ...) with section blocks, each
		{ section, first, last, continued, y }. A section takes as many rows as the column has room for under
		its header; the rest carry on at the top of the next column under its header again, marked continued.
		It moves whole to the next column when not even its header and one row fit.
	]]
	local function Paginate(sections, height)
		local columns, column, y = {}, nil, 0
		local function nextColumn()
			column, y = {}, 0
			columns[#columns + 1] = column
		end
		nextColumn()
		for _, section in ipairs(sections) do
			local first, continued = 1, false
			while first <= #section.rows do
				local gap = #column > 0 and SECTION_GAP or 0
				local fit = math.floor((height - y - gap - HEADER_HEIGHT - HEADER_GAP) / ROW_HEIGHT)
				if fit < 1 and #column > 0 then
					nextColumn()
				else
					-- an empty column always takes at least one row, so a section can never stall
					local last = math.min(#section.rows, first + math.max(fit, 1) - 1)
					column[#column + 1] =
						{ section = section, first = first, last = last, continued = continued, y = y + gap }
					y = y + gap + HEADER_HEIGHT + HEADER_GAP + (last - first + 1) * ROW_HEIGHT
					first = last + 1
					if first <= #section.rows then
						continued = true
						nextColumn()
					end
				end
			end
		end
		if #column == 0 and #columns > 1 then
			columns[#columns] = nil
		end
		return columns
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
				.. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tostring(counts[status] or 0))
		end
		page.counts:SetText(table.concat(parts, "   "))
		page.footerText:SetText(model.footer and model.footer(context) or "")
	end

	local function Layout()
		page.headers:ReleaseAll()
		page.rowButtons:ReleaseAll()
		local controls = page.pagingControls
		local sections = Sections()
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
		for side = 1, 2 do
			local x = (side - 1) * half + COLUMN_SIDE
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
	-- Controls
	----------------------------------------------------------------------------

	local function BuildControls()
		local CreateDropdown, AddMenuTooltip = ns.CreateSpellbookDropdown, ns.AddSpellbookMenuTooltip
		local rowY = -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2)
		local function startOver()
			page.pagingControls:SetCurrentPage(1)
			Layout()
		end

		local options
		if model.toggles then
			-- the settings gear at the row's right end: which rows besides the ones to learn it lists
			options = ns.CreateSpellbookGearButton(page, 22)
			page.options = options
			options:SetPoint("RIGHT", page, "TOPRIGHT", -10, rowY)
			options:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				GameTooltip:SetText(SETTINGS, TITLE.r, TITLE.g, TITLE.b, 1, true)
				GameTooltip:Show()
			end)
			options:SetScript("OnClick", function(self)
				HideTooltip(self)
				MenuUtil.CreateContextMenu(self, function(_, rootDescription)
					rootDescription:CreateTitle(SETTINGS)
					for _, toggle in ipairs(model.toggles) do
						local labelKey, descKey, getter, setter = unpack(toggle)
						AddMenuTooltip(
							rootDescription:CreateCheckbox(L[labelKey], getter, function()
								setter(not getter())
								startOver()
							end),
							labelKey,
							descKey
						)
					end
				end)
			end)
		end

		-- the filter box: only the rows whose names hold its text, as it is typed
		page.filterBox = ns.CreateSpellbookFilterBox(page, L["PAGE_FILTER"], function(text)
			if text ~= (page.filterText or "") then
				page.filterText = text
				startOver()
			end
		end)

		if model.sources then
			--[[
				The source filter: one source, or all of them (page.sourceFilter nil). It offers only the sources the
				rows have, and forgets a pick no row has any more.
			]]
			local function SourceChoices()
				local present = {}
				for _, row in ipairs(page.rows or {}) do
					if row.source then
						present[row.source] = true
					end
				end
				local choices = {}
				for _, source in ipairs(model.sources) do
					if present[source] then
						choices[#choices + 1] = source
					end
				end
				return choices
			end
			local function SourceLabelOrAll()
				return page.sourceFilter and SourceLabel(page.sourceFilter) or L["WHATS_NEXT_ALL_SOURCES"]
			end
			local sourceButton
			local function pickSource(source)
				page.sourceFilter = source
				if not sourceButton.SetupMenu then
					sourceButton:SetText(SourceLabelOrAll())
				end
				startOver()
			end
			sourceButton = CreateDropdown(page, 150, function(_, rootDescription)
				rootDescription:CreateRadio(L["WHATS_NEXT_ALL_SOURCES"], function()
					return page.sourceFilter == nil
				end, function()
					pickSource(nil)
				end)
				for _, source in ipairs(SourceChoices()) do
					rootDescription:CreateRadio(SourceLabel(source), function()
						return page.sourceFilter == source
					end, function()
						pickSource(source)
					end)
				end
			end)
			sourceButton:SetPoint("LEFT", page.filterBox, "RIGHT", 8, 0)
			page.filterButton = sourceButton
			function page.UpdateSourceFilter()
				local offered = false
				for _, source in ipairs(SourceChoices()) do
					offered = offered or source == page.sourceFilter
				end
				if not offered then
					page.sourceFilter = nil
				end
				if sourceButton.GenerateMenu then
					sourceButton:GenerateMenu()
				else
					sourceButton:SetText(SourceLabelOrAll())
				end
			end
		else
			page.UpdateSourceFilter = nop
		end

		if model.sortDescription then
			-- the sort: Sort By Availability or Sort By Level (ns.WhatsNextSort), shared by the What's Next? tabs
			local SORTS = { { "availability", "WHATS_NEXT_SORT_AVAILABILITY" }, { "level", "WHATS_NEXT_SORT_LEVEL" } }
			local function SortLabel()
				for _, sort in ipairs(SORTS) do
					if sort[1] == ns.WhatsNextSort() then
						return L[sort[2]]
					end
				end
				return L[SORTS[1][2]]
			end
			local sortButton
			sortButton = CreateDropdown(page, 170, function(_, rootDescription)
				for _, sort in ipairs(SORTS) do
					AddMenuTooltip(
						rootDescription:CreateRadio(L[sort[2]], function()
							return ns.WhatsNextSort() == sort[1]
						end, function()
							ns.SetWhatsNextSort(sort[1])
							if not sortButton.SetupMenu then
								sortButton:SetText(SortLabel())
							end
							startOver()
						end),
						sort[2],
						model.sortDescription
					)
				end
			end)
			-- the other tab may have changed the shared sort while this one was hidden
			function page.UpdateSortLabel()
				if sortButton.GenerateMenu then
					sortButton:GenerateMenu()
				else
					sortButton:SetText(SortLabel())
				end
			end
			page.UpdateSortLabel()
			if options then
				sortButton:SetPoint("RIGHT", options, "LEFT", -8, 0)
			else
				sortButton:SetPoint("RIGHT", page, "TOPRIGHT", -10, rowY)
			end
			page.sortButton = sortButton
		else
			page.UpdateSortLabel = nop
		end

		ns.ApplySpellbookElvUISkin(page)

		-- the footer: the counts at its left, the model's own text at its right
		page.counts = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		page.counts:SetPoint("LEFT", page, "BOTTOMLEFT", 12, FRAME_BORDER + FOOTER_HEIGHT / 2)
		page.footerText = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		page.footerText:SetPoint("RIGHT", page, "BOTTOMRIGHT", -12, FRAME_BORDER + FOOTER_HEIGHT / 2)
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
	page.empty:SetTextColor(unpack(HEADER_INK))
	page.empty:SetShadowOffset(0, 0)
	page.empty:SetPoint("CENTER", 0, PAGER_HEIGHT / 2)
	page.empty:SetWidth(EMPTY_WIDTH)
	page.empty:SetWordWrap(true)

	BuildControls()

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
