local _, ns = ...
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local L = ns.L
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local FramePool = ns.SpellbookFramePool
local CreateGearButton = ns.CreateSpellbookGearButton
local SpellbookPageCategories = ns.SpellbookPageCategories

--[[
	Lays ns.macros (built by Features/Enhanced-Spellbook/Macro-Builder/Macro-Builder.lua) out in the page's window (Features/Enhanced-Spellbook/Spellbook-Window.lua):
	the parchment with two columns and the page strip, between the controls along its top and the legend and macro
	slot counts along its bottom, which Features/Enhanced-Spellbook/Spellbook-Controls.lua builds. Each category is a block under its header; its spells flow two to a row into the
	very next free slot, a form's run labeled above its own tiles. Features/Enhanced-Spellbook/Macro-Button.lua owns each tile,
	Features/Enhanced-Spellbook/Macro-Menu.lua the right-click menu, Features/Enhanced-Spellbook/Category-Menu.lua the category menu, and Features/Enhanced-Spellbook/Spellbook-Paging.lua the page strip.
	Features/Enhanced-Spellbook/Spellbook-Events.lua redraws the page as the game changes. Features/Enhanced-Spellbook/Spellbook-Page-Parchment.lua
	draws the parchment, Features/Enhanced-Spellbook/Spellbook-Page-Layout.lua packs the rows and fills the columns,
	and Features/Enhanced-Spellbook/Spellbook-Page-Order.lua puts the macros in page order.
]]

-- The window's bands, in UI units from its edges, inside the portrait frame's border.
local TITLE_HEIGHT, CONTROLS_HEIGHT = 24, 32
local FOOTER_HEIGHT, FRAME_BORDER = 32, 4
local PARCHMENT_SIDE = 8
local PAGER_HEIGHT = 32
--[[
	Each column's padding inside the parchment. A page is half the paper (the window's width less its borders);
	at 1056 wide that leaves about 52 beside each 464-wide column, split so the column has room at the fold as
	well as at the page's outer edge (with the spine shift: about 15 at the fold, 37 at the edge).
]]
local COLUMN_TOP, COLUMN_SIDE = 12, 32

-- The flow inside a column (see PackRows and Paginate, in Features/Enhanced-Spellbook/Spellbook-Page-Layout.lua).
local SLOTS, GAP_X = 2, 16
local TILE_WIDTH, TILE_HEIGHT = ns.TILE_WIDTH, ns.TILE_HEIGHT
--[[
	The strip above each row of tiles: clear space, then a form's label, then a short gap to the tiles it names.
	The strip is sized so the space between one row's icons and the next is one icon tall (a 32 tile holds a 32
	icon), rows stepping 64 apart, and the label keeps its place against the tiles under it, so the
	space falls above the label.
]]
local ROW_STRIP_HEIGHT = 32
local LABEL_HEIGHT, LABEL_GAP = 13, 3
local LABEL_TOP_GAP = ROW_STRIP_HEIGHT - LABEL_HEIGHT - LABEL_GAP
local HEADER_HEIGHT = 20
local COLUMN_WIDTH = SLOTS * TILE_WIDTH + (SLOTS - 1) * GAP_X

--[[
	Every row is the same height: a label strip over its tiles, holding a form's label where the row has one and
	left empty otherwise, so rows step down evenly whether or not they're labeled. The strip is also the space
	between rows and under the header.
]]
local ROW_HEIGHT = LABEL_TOP_GAP + LABEL_HEIGHT + LABEL_GAP + TILE_HEIGHT

local HEADER_SIZE, CONTINUED_SIZE, LABEL_SIZE = 16, 12, 10

-- The ink on the parchment: oxblood for the headers and form labels, set apart from the spell names' near-black.
local HEADER_INK = ns.HEADER_INK_COLOR
local LABEL_INK = ns.LABEL_INK_COLOR
local CONTINUED_INK = ns.FADED_INK_COLOR
local RULE_COLOR = ns.HexToColorList("9C7F55")
local DIVIDER_COLOR = ns.HexToColorList("A68B60")

--[[
	A category's header: its name in dark ink, "(Continued)" in lighter ink where it carries on from the
	column before, a rule filling the width, and the gear that opens the category's menu. Layout sets the text
	and what the gear acts on.
]]
local function CreateHeader(page)
	local header = CreateFrame("Frame", nil, page.parchment.paper)
	header:SetSize(COLUMN_WIDTH, HEADER_HEIGHT)
	header.Text = SizedFontString(header, "GameFontNormalLarge", HEADER_SIZE)
	header.Text:SetTextColor(unpack(HEADER_INK))
	header.Text:SetShadowOffset(0, 0)
	header.Text:SetPoint("LEFT")
	header.Continued = SizedFontString(header, "GameFontNormal", CONTINUED_SIZE)
	header.Continued:SetTextColor(unpack(CONTINUED_INK))
	header.Continued:SetShadowOffset(0, 0)
	local gear = CreateGearButton(header, 16)
	header.gear = gear
	gear:SetPoint("RIGHT")
	local rule = ns.SpellbookPixelLine(header, "ARTWORK", RULE_COLOR)
	rule:SetPoint("LEFT", header.Continued, "RIGHT", 8, 0)
	rule:SetPoint("RIGHT", gear, "LEFT", -8, 0)
	gear:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(
			L["PAGE_CATEGORY_SETTINGS"]:format(#header.macros, header.name),
			TITLE.r,
			TITLE.g,
			TITLE.b,
			1,
			true
		)
		GameTooltip:AddLine(L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	gear:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.ShowCategoryMenu(self, header.name, header.macros, function()
			page.Refresh()
		end)
	end)
	return header
end

-- A form's label over its own tiles: its name in capitals, then a rule to the run's right edge, ending in a tick.
local function CreateSubLabel(page)
	local label = CreateFrame("Frame", nil, page.parchment.paper)
	label:SetHeight(LABEL_HEIGHT)
	label.Text = SizedFontString(label, "GameFontNormalSmall", LABEL_SIZE)
	label.Text:SetTextColor(unpack(LABEL_INK))
	label.Text:SetShadowOffset(0, 0)
	label.Text:SetPoint("LEFT")
	local rule = ns.SpellbookPixelLine(label, "ARTWORK", RULE_COLOR)
	rule:SetPoint("LEFT", label.Text, "RIGHT", 6, 0)
	rule:SetPoint("RIGHT")
	local tick = ns.SpellbookPixelLine(label, "ARTWORK", RULE_COLOR, "VERTICAL")
	tick:SetHeight(4)
	tick:SetPoint("TOPRIGHT", rule, "TOPRIGHT")
	return label
end

-- Draws one column's blocks, x and y its top left inside the paper.
local function DrawColumn(page, column, x, y, bars)
	for _, block in ipairs(column) do
		local category = block.category
		local top = y + block.y
		local header = page.headers:Acquire()
		header:SetPoint("TOPLEFT", page.parchment.paper, "TOPLEFT", x, -top)
		header.name, header.macros = category.name, category.macros
		header.Text:SetText(category.name)
		-- the gear only where a macro has options to set
		local settable = false
		for _, macro in ipairs(category.macros) do
			settable = settable or ns.HasOptions(macro)
		end
		header.gear:SetShown(settable)
		-- an empty "(Continued)" sits flush against the name, so the rule starts where it always does
		header.Continued:SetText(block.continued and L["PAGE_CONTINUED"] or "")
		header.Continued:SetPoint("LEFT", header.Text, "RIGHT", block.continued and 6 or 0, 0)
		top = top + HEADER_HEIGHT
		for r = block.first, block.last do
			local row = category.rows[r]
			local above = r > block.first and category.rows[r - 1] or nil
			local slot = 0
			for _, segment in ipairs(row.segments) do
				local left = x + slot * (TILE_WIDTH + GAP_X)
				if segment.sub and ns.SpellbookNeedsLabel(segment, above, slot) then
					local label = page.subheaders:Acquire()
					label:SetPoint("TOPLEFT", page.parchment.paper, "TOPLEFT", left, -(top + LABEL_TOP_GAP))
					label:SetWidth(ns.SpellbookRunWidth(#segment.macros))
					label.Text:SetText(segment.sub:upper())
				end
				local tileTop = top + LABEL_TOP_GAP + LABEL_HEIGHT + LABEL_GAP
				for k, macro in ipairs(segment.macros) do
					local button = page.buttons:Acquire()
					button:SetPoint(
						"TOPLEFT",
						page.parchment.paper,
						"TOPLEFT",
						left + (k - 1) * (TILE_WIDTH + GAP_X),
						-tileTop
					)
					ns.SetMacroButton(button, macro, bars)
				end
				slot = slot + #segment.macros
			end
			top = top + ROW_HEIGHT
		end
	end
end

-- Draws the current page: two columns of blocks, or the empty note when nothing is listed.
local function Layout(page)
	page.headers:ReleaseAll()
	page.subheaders:ReleaseAll()
	page.buttons:ReleaseAll()
	local controls = page.pagingControls
	page.markPlaced:SetShown(#ns.macros > 0)
	local categories = SpellbookPageCategories(page)
	if #categories == 0 then
		local text = page.filterText or ""
		page.empty:SetText(
			#ns.macros == 0 and L["PAGE_EMPTY"]
				or text ~= "" and L["PAGE_NO_MATCHES_FOR"]:format(text)
				or L["PAGE_NO_MATCHES"]
		)
		page.empty:Show()
		controls:SetMaxPages(1)
		controls:Hide()
		return
	end
	page.empty:Hide()

	for _, category in ipairs(categories) do
		category.rows = ns.PackSpellbookRows(category.groups)
	end
	local paper = page.parchment.paper
	local columns = ns.PaginateSpellbook(categories, paper:GetHeight() - COLUMN_TOP - PAGER_HEIGHT)
	local maxPages = math.ceil(#columns / 2)
	controls:SetMaxPages(maxPages)
	controls:Show()

	local current = math.min(controls:GetCurrentPage(), maxPages)
	local bars = ns.ScanActionBars()
	local half = paper:GetWidth() / 2
	local shift = page.parchment.spineShift -- toward the spine: right on the left page, left on the right
	for side = 1, 2 do
		local column = columns[(current - 1) * 2 + side]
		if column then
			local x = (side - 1) * half + COLUMN_SIDE + (side == 1 and shift or -shift)
			DrawColumn(page, column, x, COLUMN_TOP, bars)
		end
	end
end

local refreshListeners = {}

--[[
	Calls fn(page) after each refresh, so the Conditionals and Cast Sequence panels docked beside the window
	(Features/Enhanced-Spellbook/Macro-Builder/Conditionals-Panel.lua, Cast-Sequence-Panel.lua) follow the macros the
	refresh rebuilt.
]]
function ns.OnSpellbookPageRefreshed(fn)
	refreshListeners[#refreshListeners + 1] = fn
end

-- Rebuilds the list from the spellbook and the class lists, updates changed macros, then redraws.
local function Refresh(page)
	ns.CollectMacros()
	ns.SyncAllMacros()
	ns.UpdateSpellbookMacroCount(page)
	-- the sort can change outside the dropdown (the options panel, a profile change)
	if page.sortButton.GenerateMenu then
		page.sortButton:GenerateMenu()
	else
		page.sortButton:SetText(page.sortButton.SortLabel())
	end
	page.UpdateFilterButton() -- the schools or categories on offer follow the new list
	Layout(page)
	for _, fn in ipairs(refreshListeners) do
		fn(page)
	end
end

local pages = {} -- every page built, so a settings change can redraw the open one
ns.spellbookPages = pages -- read by Features/Enhanced-Spellbook/Spellbook-Events.lua

local function BuildPage(page)
	pages[#pages + 1] = page
	-- for the Display Context report
	page.geometry = { viewWidth = COLUMN_WIDTH, columns = SLOTS }
	function page.Refresh()
		Refresh(page)
	end

	local parchment = CreateFrame("Frame", nil, page)
	page.parchment = parchment
	parchment:SetPoint("TOPLEFT", PARCHMENT_SIDE, -(TITLE_HEIGHT + CONTROLS_HEIGHT))
	parchment:SetPoint("BOTTOMRIGHT", -PARCHMENT_SIDE, FRAME_BORDER + FOOTER_HEIGHT)
	parchment:SetClipsChildren(true)
	ns.DrawSpellbookParchment(parchment)
	local divider = ns.SpellbookPixelLine(parchment.paper, "BORDER", DIVIDER_COLOR, "VERTICAL")
	divider:SetPoint("TOP", 0, -COLUMN_TOP / 2)
	divider:SetPoint("BOTTOM", 0, PAGER_HEIGHT)

	page.headers = FramePool(function()
		return CreateHeader(page)
	end)
	page.subheaders = FramePool(function()
		return CreateSubLabel(page)
	end)
	page.buttons = FramePool(function()
		local button = ns.CreateMacroButton(parchment.paper)
		button.page = page -- the tile's menu redraws the page
		return button
	end)

	page.empty = parchment.paper:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.empty:SetTextColor(unpack(ns.INK_COLOR))
	page.empty:SetShadowOffset(0, 0)
	page.empty:SetPoint("CENTER", 0, PAGER_HEIGHT / 2)
	page.empty:SetWidth(COLUMN_WIDTH)
	page.empty:SetWordWrap(true)

	-- the controls row along the top and the footer along the bottom (Features/Enhanced-Spellbook/Spellbook-Controls.lua)
	ns.BuildSpellbookControls(page)

	-- the page strip along the parchment's bottom; the wheel turns the page anywhere on the parchment
	local controls = ns.CreatePagingControls(page, parchment.paper)
	page.pagingControls = controls
	controls:SetPoint("BOTTOMLEFT", parchment.paper, "BOTTOMLEFT", 14, 0)
	controls:SetPoint("BOTTOMRIGHT", parchment.paper, "BOTTOMRIGHT", -14, 0)
	function page:OnPageChanged()
		Layout(self)
	end
	parchment:EnableMouseWheel(true)
	parchment:SetScript("OnMouseWheel", function(_, delta)
		if controls:IsShown() then
			controls:OnMouseWheel(delta)
		end
	end)
end

ns.BuildSpellbookPage = BuildPage
ns.RefreshSpellbookPage = Refresh
ns.LayoutSpellbookPage = Layout

-- The window's bands, which Features/Enhanced-Spellbook/Spellbook-Controls.lua builds the controls row and the footer in.
ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT = TITLE_HEIGHT, CONTROLS_HEIGHT
ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER = FOOTER_HEIGHT, FRAME_BORDER
-- the parchment's place in the window, and the padding and page strip inside it
ns.SPELLBOOK_PARCHMENT_SIDE, ns.SPELLBOOK_PAGER_HEIGHT = PARCHMENT_SIDE, PAGER_HEIGHT
ns.SPELLBOOK_COLUMN_TOP, ns.SPELLBOOK_COLUMN_SIDE = COLUMN_TOP, COLUMN_SIDE
ns.SPELLBOOK_HEADER_INK, ns.SPELLBOOK_RULE_COLOR = HEADER_INK, RULE_COLOR
ns.SPELLBOOK_CONTINUED_INK, ns.SPELLBOOK_DIVIDER_COLOR = CONTINUED_INK, DIVIDER_COLOR
-- the flow inside a column, which Features/Enhanced-Spellbook/Spellbook-Page-Layout.lua packs and paginates by
ns.SPELLBOOK_SLOTS, ns.SPELLBOOK_GAP_X = SLOTS, GAP_X
ns.SPELLBOOK_HEADER_HEIGHT, ns.SPELLBOOK_ROW_HEIGHT = HEADER_HEIGHT, ROW_HEIGHT
