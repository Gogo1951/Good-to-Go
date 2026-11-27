local _, ns = ...
local TITLE = ns.COLORS_RGB.TITLE
local L = ns.L
local HideTooltip = ns.HideTooltip

local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local FOOTER_HEIGHT, FRAME_BORDER = ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER

local function nop() end

function ns.BuildWhatsNextControls(page, model, Layout, SourceLabel)
	local CreateDropdown, AddMenuTooltip = ns.CreateSpellbookDropdown, ns.AddSpellbookMenuTooltip
	local rowY = -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2)
	local function startOver()
		page.pagingControls:SetCurrentPage(1)
		Layout()
	end

	local options
	if model.toggles then
		options = ns.CreateSpellbookGearButton(page, 16)
		page.options = options
		options:SetPoint("RIGHT", page, "TOPRIGHT", -8, rowY)
		options:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText(SETTINGS, TITLE.r, TITLE.g, TITLE.b, 1, true)
			GameTooltip:Show()
		end)
		options:SetScript("OnClick", function(self)
			HideTooltip(self)
			ns.OpenMacroMenuPanels(self, function(_, rootDescription)
				rootDescription:CreateHeader(SETTINGS, L["ADDON_SHORT_NAME"])
				local toggles = type(model.toggles) == "function" and model.toggles() or model.toggles
				for _, toggle in ipairs(toggles) do
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
			end, true)
		end)
	end

	page.filterBox = ns.CreateSpellbookFilterBox(page, L["PAGE_FILTER"], function(text)
		if text ~= (page.filterText or "") then
			page.filterText = text
			startOver()
		end
	end)

	if model.sources then
		-- Offers only the sources the rows have, and forgets a pick no row has any more.
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
		sourceButton = CreateDropdown(page, 160, function(_, rootDescription)
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
		-- shared by the What's Next? tabs
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
		sortButton = CreateDropdown(page, 160, function(_, rootDescription)
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
			sortButton:SetPoint("RIGHT", page, "TOPRIGHT", -8, rowY)
		end
		page.sortButton = sortButton
	else
		page.UpdateSortLabel = nop
	end

	ns.ApplySpellbookElvUISkin(page)

	page.counts = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.counts:SetPoint("LEFT", page, "BOTTOMLEFT", 16, FRAME_BORDER + FOOTER_HEIGHT / 2)
	page.footerText = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.footerText:SetPoint("RIGHT", page, "BOTTOMRIGHT", -16, FRAME_BORDER + FOOTER_HEIGHT / 2)
end
