local _, ns = ...
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip
local PixelInset = ns.PixelInset
local CreateGearButton = ns.CreateSpellbookGearButton
local Layout = ns.LayoutSpellbookPage
local Refresh = ns.RefreshSpellbookPage

local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local FOOTER_HEIGHT, FRAME_BORDER = ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER

-- the footer, on the dark frame
local LEGEND_COLOR = ns.HexToColorList("BFBFBF")
local GLOW_SWATCH = ns.HexToColorList("FFE27A")
local GLOW_SWATCH_FILL = ns.HexToColorList("2E2A24")

local function SlotCount(label, used, max)
	local count = used .. "/" .. max
	local color = GetColor(used >= max and "OFF" or "TEXT")
	return GetColor("MUTED") .. label .. "|r " .. color .. count .. "|r"
end

local function UpdateMacroCount(page)
	local numAccount, maxAccount, numCharacter, maxCharacter = ns.MacroCounts()
	page.macroCount:SetText(
		GetColor("TITLE")
			.. L["PAGE_MACRO_SLOTS"]
			.. "|r   "
			.. SlotCount(L["PAGE_MACRO_GENERAL"], numAccount, maxAccount)
			.. "   "
			.. SlotCount(L["PAGE_MACRO_CHARACTER"], numCharacter, maxCharacter)
	)
end

ns.UpdateSpellbookMacroCount = UpdateMacroCount

local AddMenuTooltip = ns.AddSpellbookMenuTooltip
local ApplyElvUISkin = ns.ApplySpellbookElvUISkin
local CreateDropdown = ns.CreateSpellbookDropdown
local CreateFilterBox = ns.CreateSpellbookFilterBox

-- The legend: a dark square ringed in the glow's gold, for a spell not on the bars yet.
local function BuildLegend(page)
	local glow = CreateFrame("Frame", nil, page)
	glow:SetSize(16, 16)
	glow:SetPoint("LEFT", page, "BOTTOMLEFT", 16, FRAME_BORDER + FOOTER_HEIGHT / 2)
	local ring = glow:CreateTexture(nil, "BACKGROUND")
	ring:SetAllPoints()
	ring:SetColorTexture(unpack(GLOW_SWATCH))
	local fill = glow:CreateTexture(nil, "BORDER")
	fill:SetColorTexture(unpack(GLOW_SWATCH_FILL))
	PixelInset(fill, glow, 2)
	local label = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetTextColor(unpack(LEGEND_COLOR))
	label:SetPoint("LEFT", glow, "RIGHT", 4, 0)
	label:SetText(L["TOOLTIP_NOT_ON_BARS"])
	page.legendLabel = label
end

function ns.BuildSpellbookControls(page)
	local function SetupSettingsMenu(_, rootDescription)
		rootDescription:CreateHeader(SETTINGS, L["ADDON_SHORT_NAME"])
		-- the page's list toggles, each changing which macros it lists, so it starts again from its first page
		local function listToggle(labelKey, descKey, getter, setter)
			AddMenuTooltip(
				rootDescription:CreateCheckbox(L[labelKey], getter, function()
					setter(not getter())
					page.pagingControls:SetCurrentPage(1)
					Refresh(page)
				end),
				labelKey,
				descKey
			)
		end
		if ns.HAS_SPELL_RANKS then
			listToggle(
				"SETTINGS_SHOW_ALL_RANKS",
				"OPTIONS_SHOW_ALL_RANKS_DESCRIPTION",
				ns.ShowsAllRanks,
				ns.SetShowAllRanks
			)
		end
		listToggle(
			"SETTINGS_SHOW_GROUPED_SPELLS",
			"OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION",
			ns.ShowsGroupedSpells,
			ns.SetShowGroupedSpells
		)
		if ns.ForEachUnlearnedSpell then
			listToggle(
				"SETTINGS_SHOW_UNLEARNED",
				"OPTIONS_SHOW_UNLEARNED_DESCRIPTION",
				ns.ShowsUnlearned,
				ns.SetShowUnlearned
			)
		end
		-- Listed only while something is marked, since there's nothing to undo otherwise.
		if ns.HasPlacedMarks() then
			rootDescription:CreateSpacer()
			rootDescription:CreateDivider()
			AddMenuTooltip(
				rootDescription:CreateButton(L["SETTINGS_HIGHLIGHT_AGAIN"], function()
					ns.ClearPlacedMarks()
					ns:OnActionbarSlotChanged() -- redraws the glows, and brings Mark All Spells as Placed back
				end),
				"SETTINGS_HIGHLIGHT_AGAIN",
				"SETTINGS_HIGHLIGHT_AGAIN_DESCRIPTION"
			)
		end
	end

	-- the controls row: on the dark frame under the title, from clear of the portrait to the frame's right
	local rowY = -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2)

	-- the page-wide settings menu, from the gear at the row's right end
	local options = CreateGearButton(page, 16)
	page.options = options
	options:SetPoint("RIGHT", page, "TOPRIGHT", -8, rowY)
	options:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(SETTINGS, TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:AddLine(L["TOOLTIP_PAGE_SETTINGS_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	options:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.OpenMacroMenuPanels(self, SetupSettingsMenu, true)
	end)

	local filterBox = CreateFilterBox(page, L["PAGE_FILTER"], function(text)
		if text ~= (page.filterText or "") then
			page.filterText = text
			page.pagingControls:SetCurrentPage(1)
			Layout(page)
		end
	end)
	page.filterBox = filterBox

	-- Offers only the groups the page's macros fill, in page order, and forgets its pick when the sort changes.
	local function FilterChoices()
		local choices, seen = {}, {}
		if ns.PageSort() == "category" then
			for _, macro in ipairs(ns.macros) do
				if not macro.unlearned and not seen[macro.category] then
					seen[macro.category] = true
					choices[#choices + 1] = { macro.category, macro.category }
				end
			end
			return choices
		end
		for _, macro in ipairs(ns.macros) do
			local key = not macro.unlearned and not macro.hidden and ns.PageCategory(macro)
			if key then
				seen[key] = true
			end
		end
		for _, row in ipairs(ns.PAGE_CATEGORIES) do
			if seen[row.key] then
				choices[#choices + 1] = { row.key, L[row.labelKey] }
			end
		end
		return choices
	end
	local function AllLabel()
		return ns.PageSort() == "category" and L["FILTER_ALL_SCHOOLS"] or L["FILTER_ALL_CATEGORIES"]
	end
	local function FilterLabel()
		for _, choice in ipairs(FilterChoices()) do
			if choice[1] == page.groupFilter then
				return choice[2]
			end
		end
		return AllLabel()
	end
	local filterButton
	local function pickFilter(value)
		page.groupFilter = value
		if not filterButton.SetupMenu then
			filterButton:SetText(FilterLabel())
		end
		page.pagingControls:SetCurrentPage(1)
		Layout(page)
	end
	filterButton = CreateDropdown(page, 160, function(_, rootDescription)
		rootDescription:CreateRadio(AllLabel(), function()
			return page.groupFilter == nil
		end, function()
			pickFilter(nil)
		end)
		for _, choice in ipairs(FilterChoices()) do
			rootDescription:CreateRadio(choice[2], function()
				return page.groupFilter == choice[1]
			end, function()
				pickFilter(choice[1])
			end)
		end
	end)
	filterButton:SetPoint("LEFT", filterBox, "RIGHT", 8, 0)
	page.filterButton = filterButton
	-- redraws the dropdown's choices and label, dropping a pick the page no longer offers
	function page.UpdateFilterButton()
		if FilterLabel() == AllLabel() then
			page.groupFilter = nil
		end
		if filterButton.GenerateMenu then
			filterButton:GenerateMenu()
		else
			filterButton:SetText(FilterLabel())
		end
	end
	page.UpdateFilterButton()

	local SORTS = { { "category", "SORT_BY_CATEGORY" }, { "school", "SORT_BY_SCHOOL" } }
	local function SortLabel()
		for _, sort in ipairs(SORTS) do
			if sort[1] == ns.PageSort() then
				return L[sort[2]]
			end
		end
		return L[SORTS[1][2]]
	end
	local sortButton
	sortButton = CreateDropdown(page, 160, function(_, rootDescription)
		for _, sort in ipairs(SORTS) do
			AddMenuTooltip(
				rootDescription:CreateRadio(L[sort[2]], function()
					return ns.PageSort() == sort[1]
				end, function()
					ns.SetPageSort(sort[1])
					if not sortButton.SetupMenu then
						sortButton:SetText(SortLabel())
					end
					-- the filter dropdown offers the other grouping now, so its pick no longer applies
					page.groupFilter = nil
					page.UpdateFilterButton()
					page.pagingControls:SetCurrentPage(1)
					Layout(page)
				end),
				sort[2],
				"SORT_DESCRIPTION"
			)
		end
	end)
	if not sortButton.SetupMenu then
		sortButton:SetText(SortLabel())
	end
	-- at the row's right, beside the settings gear: how the page is ordered, apart from what it shows
	sortButton:SetPoint("RIGHT", page.options, "LEFT", -8, 0)
	page.sortButton = sortButton
	sortButton.SortLabel = SortLabel

	-- the footer: the legend at its left, the macro slot counts at its right
	BuildLegend(page)

	-- At once and without asking, since the settings menu undoes it; shown only while some macro glows.
	local markPlaced = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.markPlaced = markPlaced
	markPlaced:SetText(L["SETTINGS_MARK_ALL_PLACED"])
	markPlaced:SetSize(markPlaced:GetFontString():GetStringWidth() + 32, 22)
	markPlaced:SetPoint("LEFT", page.legendLabel, "RIGHT", 16, 0)
	markPlaced:SetScript("OnClick", function()
		ns.MarkAllPlaced()
		markPlaced:Hide() -- nothing glows now
		ns:OnActionbarSlotChanged() -- redraws the glows
	end)
	markPlaced:SetScript("OnEnter", function(self)
		ns.SetTooltipOwner(self)
		GameTooltip:SetText(L["SETTINGS_MARK_ALL_PLACED"], TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:AddLine(L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	markPlaced:SetScript("OnLeave", HideTooltip)
	ApplyElvUISkin(page)

	page.macroCount = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.macroCount:SetPoint("RIGHT", page, "BOTTOMRIGHT", -16, FRAME_BORDER + FOOTER_HEIGHT / 2)
	-- a font string takes no hover, so a frame over the counts carries its tooltip
	local slotsHover = CreateFrame("Frame", nil, page)
	slotsHover:SetAllPoints(page.macroCount)
	slotsHover:EnableMouse(true)
	slotsHover:SetScript("OnEnter", function(self)
		ns.SetTooltipOwner(self)
		GameTooltip:SetText(L["PAGE_MACRO_SLOTS"], TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:AddLine(L["TOOLTIP_MACRO_SLOTS"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	slotsHover:SetScript("OnLeave", HideTooltip)
	slotsHover:SetScript("OnHide", HideTooltip)
end

-- bars is ns.ScanActionBars's result when the caller has it.
function ns.UpdateMarkPlacedButton(page, bars)
	page.markPlaced:SetShown(ns.AnyMacroGlows(bars or ns.ScanActionBars()))
end
