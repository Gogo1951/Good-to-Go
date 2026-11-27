local _, ns = ...
local L = ns.L
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT

--------------------------------------------------------------------------------
-- Category Pane
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Category Selection
--------------------------------------------------------------------------------

--[[
    Never saved and reset when the window closes, so a session that ended
    filtered doesn't open on a half-empty list later. A group key, not an index:
    the groups change as items come and go.
]]
ns.restockSelectedGroup = nil

function ns.SelectRestockGroup(group)
	ns.restockSelectedGroup = group
	ns.UpdateRestockList()
	local scrollFrame = ns.restockWindow and ns.restockWindow.scrollFrame
	if scrollFrame then
		scrollFrame:SetVerticalScroll(0) -- a new selection starts at its top
	end
end

function ns.ClearRestockGroupSelection()
	ns.restockSelectedGroup = nil
end

-- The two grays are this pane's own states, not palette roles.
local GOLD = ns.COLORS_RGB.TITLE
local ROW_LABEL = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ROW_LABEL)
local ROW_COUNT = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ROW_COUNT)

local GROUP_ROW_HEIGHT = 16
local GROUP_ROW_INSET = 8
local GROUP_COUNT_WIDTH = 32

--[[
    Sized to the longest type name shown: the client localizes those, so no
    fixed width fits every locale. MIN_WIDTH (Restocker-Window.lua) is built on
    the cap, so the item name always keeps room.
]]
local GROUP_PANE_MIN_WIDTH = 128
local GROUP_PANE_MAX_WIDTH = 176

ns.restockGroupPaneWidth = GROUP_PANE_MIN_WIDTH
ns.RESTOCK_GROUP_PANE_GAP = 16 -- pane to table, space rather than a line
ns.RESTOCK_GROUP_ROW_INSET = GROUP_ROW_INSET -- where a type name starts

local measureFontString

-- Type names need no item cache, so this measures true even before the window is laid out.
function ns.ResolveRestockGroupPaneWidth()
	if not measureFontString then
		measureFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", BUTTON_FONT)
		measureFontString:Hide()
	end

	local labels = {
		[L["RESTOCKER_GROUP_ALL"]] = true,
		[L["RESTOCKER_GROUP_NEW"]] = true,
		[L["RESTOCKER_GROUP_OTHER"]] = true,
	}
	local settings = ns.restockSettings
	for _, list in pairs((settings and settings.lists) or {}) do
		for itemID in pairs(list) do
			local typeName = ns.GetRestockItemTypeName(tonumber(itemID))
			if typeName then
				labels[typeName] = true
			end
		end
	end

	local widest = 0
	for label in pairs(labels) do
		measureFontString:SetText(label)
		local width = measureFontString:GetStringWidth() or 0
		if width > widest then
			widest = width
		end
	end

	-- Name column, then the gap and the count column, then both insets.
	local needed = math.ceil(widest) + 4 + GROUP_COUNT_WIDTH + (GROUP_ROW_INSET * 2)
	ns.restockGroupPaneWidth = math.max(GROUP_PANE_MIN_WIDTH, math.min(GROUP_PANE_MAX_WIDTH, needed))
end

local function GetCategoryRow()
	for _, row in ipairs(ns.restockCategoryRowPool) do
		if not row.isInUse then
			return row
		end
	end

	local row = CreateFrame("Button", nil, ns.restockHiddenFrame)
	row:SetHeight(GROUP_ROW_HEIGHT)

	local selection = row:CreateTexture(nil, "BACKGROUND")
	selection:SetAllPoints(row)
	selection:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.14)
	selection:Hide()
	row.selected = selection

	row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2", "ADD")
	local highlight = row:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, 0.25)
	end

	local count = row:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(BUTTON_FONT)
	count:SetWidth(GROUP_COUNT_WIDTH)
	count:SetJustifyH("RIGHT")
	count:SetPoint("RIGHT", row, "RIGHT", -GROUP_ROW_INSET, 0)
	row.count = count

	-- No wrap, so a long type name truncates before its count.
	local name = row:CreateFontString(nil, "OVERLAY")
	name:SetFontObject(BUTTON_FONT)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	name:SetPoint("LEFT", row, "LEFT", GROUP_ROW_INSET, 0)
	name:SetPoint("RIGHT", count, "LEFT", -4, 0)
	row.name = name

	ns.SetRestockControlClick(row, function(self)
		ns.SelectRestockGroup(self.group)
	end)

	table.insert(ns.restockCategoryRowPool, row)
	return row
end

-- `group` is nil for the "All items" entry.
local function SetCategoryRow(row, label, count, group, isSelected)
	row.group = group
	row.name:SetText(label)
	row.count:SetText(tostring(count))
	row.selected:SetShown(isSelected)
	-- A zero-count category draws only while selected, so it needs no third state.
	if isSelected then
		row.name:SetTextColor(GOLD.r, GOLD.g, GOLD.b)
		row.count:SetTextColor(GOLD.r, GOLD.g, GOLD.b)
	else
		row.name:SetTextColor(ROW_LABEL.r, ROW_LABEL.g, ROW_LABEL.b)
		row.count:SetTextColor(ROW_COUNT.r, ROW_COUNT.g, ROW_COUNT.b)
	end
end

function ns.CreateRestockGroupPane(parent, listInset, topInset)
	local pane = CreateFrame("Frame", nil, parent)
	-- The same top and bottom insets the table uses, so the two line up row for row.
	pane:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -topInset)
	pane:SetPoint("BOTTOMLEFT", listInset, "BOTTOMLEFT", 8, ns.RESTOCK_LIST_BOTTOM_INSET)
	pane:SetWidth(ns.restockGroupPaneWidth)

	-- Wheel-only: UIPanelScrollFrameTemplate's bar would take width off the narrow pane for good.
	local scroll = CreateFrame("ScrollFrame", nil, pane)
	scroll:SetAllPoints(pane)

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(scroll:GetWidth(), 1)
	scroll:SetScrollChild(child)

	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		-- Clamped: an unclamped SetVerticalScroll scrolls a short list off the top.
		local maxScroll = math.max(0, self:GetScrollChild():GetHeight() - self:GetHeight())
		local target = self:GetVerticalScroll() - (delta * GROUP_ROW_HEIGHT * 2)
		self:SetVerticalScroll(math.max(0, math.min(maxScroll, target)))
	end)
	pane.scrollFrame = scroll
	pane.scrollChild = child

	ns.restockGroupPane = pane
	return pane
end

function ns.UpdateRestockGroupPane(items, view)
	local pane = ns.restockGroupPane
	if not pane then
		return
	end

	for _, row in ipairs(ns.restockCategoryRowPool) do
		row.isInUse = false
		row:SetParent(ns.restockHiddenFrame)
		row:Hide()
	end

	local groups, total = ns.BuildRestockGroupList(items, view)
	local child = pane.scrollChild
	-- GetWidth reads 0 before layout, which the first refill can beat, and rows resize only on refill.
	local width = pane.scrollFrame:GetWidth()
	if not width or width <= 0 then
		width = ns.restockGroupPaneWidth
	end
	local offset = 0

	local function Place(label, count, group)
		local row = GetCategoryRow()
		row.isInUse = true
		row:SetParent(child)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -offset)
		row:SetWidth(width)
		SetCategoryRow(row, label, count, group, ns.restockSelectedGroup == group)
		row:Show()
		offset = offset + GROUP_ROW_HEIGHT
	end

	Place(L["RESTOCKER_GROUP_ALL"], total, nil)
	offset = offset + 8 -- a break under All, which is not one of the types

	local selectedShown = (ns.restockSelectedGroup == nil)
	for _, group in ipairs(groups) do
		Place(group.label, group.count, group.group)
		if group.group == ns.restockSelectedGroup then
			selectedShown = true
		end
	end

	-- The selected category stays at zero when the filter empties it, so the empty list has a visible reason.
	if not selectedShown then
		Place(ns.GetRestockGroupLabel(ns.restockSelectedGroup), 0, ns.restockSelectedGroup)
	end

	child:SetWidth(width)
	child:SetHeight(math.max(1, offset))
end
