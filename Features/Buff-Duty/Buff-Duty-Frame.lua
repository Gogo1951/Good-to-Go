local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.MenuKit

local GetColor = ns.GetColor
local UpdateCooldowns = ns.UpdateBuffDutyCooldowns
local UpdateRange = ns.UpdateBuffDutyRange

local Layout = ns.buffDutyLayout
local Signature = Layout.Signature
local GridSlots = Layout.GridSlots
local PlaceLines = Layout.PlaceLines

--[[
    Every list icon is a secure button, so nothing here lays the window out
    in combat; the caller redraws once it ends. Mid-fight only alpha (the
    range fade) and the cooldown swipes change.

    Two frames stack so combat visibility and our own never fight: the anchor
    belongs to a secure state driver (Hide in Combat), and the content inside
    it is shown and hidden here, out of combat only.
]]

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local ICON_GAP = Layout.ICON_GAP
-- The max keeps a long title-and-realm name from pushing the icons across the screen.
local MIN_NAME_WIDTH = 64
local MAX_NAME_WIDTH = 256
-- Whole steps, so a slightly longer name doesn't nudge the window wider.
local NAME_STEP = 16
local NAME_GAP = Layout.NAME_GAP
local MAIN_GRID = Layout.MAIN_GRID
local FOLD_INDENT = Layout.FOLD_INDENT
local MEMBER_INDENT = 0
local PARTIES_PER_ROW = 2
local COLUMN_GAP = 16
local PET_INDENT = 16
--[[
    The window is laid out by Menu-Kit's numbers (Style Guide → WINDOWS):
    Kit.WINDOW_EDGE from the plate to the text on every side, the body from
    Kit.WINDOW_BODY_TOP, every line a Kit.ROW_HEIGHT row, a Kit.WINDOW_SPACER
    between groups, and the Options line as Kit.PlaceOptionsLine sets it.
]]
local EDGE = Kit.WINDOW_EDGE
local CLOSE_SIZE = Kit.WINDOW_HEADER_HEIGHT
local TITLE_CLOSE_GAP = 8

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local anchor, content, title, keyHint, footer, footerDivider

-- Set when a drag is let go in combat, so ns.ApplyBuffDutySettings stops and saves it once combat ends.
local stopPending = false
local labels, usedLabels = {}, 0
local pool = ns.buffDutyIconPool
local icons = pool.buttons
local lastSignature
local held = Layout.held

local function ForgetHeldLayout()
	held.columns, held.nameWidth, held.partyBuffs = {}, 0, 0
end

local function RosterKey()
	return (IsInRaid() and "raid" or "party") .. GetNumGroupMembers()
end

local function SnapUp(value, step)
	return math.ceil(value / step) * step
end

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

local function AcquireLabel()
	usedLabels = usedLabels + 1
	local label = labels[usedLabels]
	if not label then
		label = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		label:SetJustifyH("LEFT")
		label:SetWordWrap(false)
		labels[usedLabels] = label
	end
	return label
end

--------------------------------------------------------------------------------
-- Render
--------------------------------------------------------------------------------

-- Width 0 measures the whole name, not what fit the last layout's column.
local function MeasureLabel(text, indent)
	local label = AcquireLabel()
	label:SetWidth(0)
	label:SetText(text)
	return label, indent + label:GetStringWidth()
end

local function ReleaseAll()
	for i = 1, usedLabels do
		labels[i]:Hide()
	end
	for i = 1, pool.used do
		icons[i]:Hide()
		icons[i].spec = nil
	end
	usedLabels, pool.used = 0, 0
	ns.ReleaseBuffDutyOtherIcons()
	Layout.ReleaseFoldButtons()
	Layout.ReleaseMenuButtons()
end

-- Party-Buffs isn't in `sections`: the Buff Key never casts them and their icons aren't secure.
local PARTY_BUFFS_GRID = "partyBuffs"

-- Rows in cast order instead of by column: the next cast leftmost.
local CAST_ORDER_KINDS = { self = true, target = true, favor = true }

-- An icon the key never casts (Winterfall Firewater) has no rank and goes after the rest.
local function CastRanks(sections)
	local ordered = {}
	for _, section in ipairs(sections) do
		if CAST_ORDER_KINDS[section.kind] then
			ordered[#ordered + 1] = section
		end
	end
	local ranks = {}
	for index, spec in ipairs(ns.BuffDuty.CastOrder(ordered)) do
		ranks[spec] = index
	end
	return ranks
end

local function InCastOrder(specs, ranks)
	local sorted, place = {}, {}
	for index, spec in ipairs(specs) do
		sorted[index] = spec
		place[spec] = index
	end
	table.sort(sorted, function(a, b)
		local rankA, rankB = ranks[a] or math.huge, ranks[b] or math.huge
		if rankA ~= rankB then
			return rankA < rankB
		end
		return place[a] < place[b]
	end)
	return sorted
end

-- Shown while Cast Next Buff has no key; it wraps to the window's width rather than widening it.
local function KeyHintText()
	local info = GetColor("INFO")
	local help = GetColor("HELP")
	return help
		.. L["BUFF_DUTY_KEY_TIP"]:format(
			info .. L["OPTIONS_COMMAND"] .. "|r" .. help,
			info .. L["BUFF_KEY"] .. "|r" .. help
		)
		.. "|r"
end

function ns.RenderBuffDuty(sections, otherBuffs)
	if InCombatLockdown() or not content then
		return
	end
	otherBuffs = otherBuffs or {}

	local roster = RosterKey()
	if roster ~= held.roster then
		ForgetHeldLayout()
		held.roster = roster
		lastSignature = nil
	end

	local showKeyHint = not GetBindingKey(ns.BUFF_KEY_COMMAND)
	local signature = Signature(sections, otherBuffs) .. (showKeyHint and "|?keyHint" or "")
	if signature ~= lastSignature then
		lastSignature = signature
		ReleaseAll()

		--[[
		    Two passes: every label is measured before any is placed, because
		    the icon column starts where the longest name ends.
		]]
		local top, partyRows = {}, {}
		local parties = 0
		local nameWidth = MIN_NAME_WIDTH
		-- Once any line has a menu, every line's icons end before the arrow's column.
		local anyMenu = false
		local partyBuffsPlaced = #otherBuffs == 0
		local castRanks
		local function AddPartyBuffs()
			partyBuffsPlaced = true
			local label, labelWidth = MeasureLabel(GetColor("TITLE") .. L["BUFF_DUTY_ASK_OTHERS"] .. "|r", 0)
			top[#top + 1] = {
				label = label,
				indent = 0,
				specs = {},
				partyBuffs = otherBuffs,
				grid = PARTY_BUFFS_GRID,
				header = true,
				sectionEnd = true,
			}
			nameWidth = math.max(nameWidth, labelWidth)
		end
		for _, section in ipairs(sections) do
			if not partyBuffsPlaced and section.kind ~= "self" then
				AddPartyBuffs()
			end
			local lines = top
			if section.party then
				parties = parties + 1
				local index = math.ceil(parties / PARTIES_PER_ROW)
				partyRows[index] = partyRows[index] or {}
				lines = {}
				table.insert(partyRows[index], lines)
			end
			local grid = section.grid or MAIN_GRID
			local packed = CAST_ORDER_KINDS[section.kind] or false
			local function Measure(text, indent, specs, lineGrid, header, from)
				local label, width = MeasureLabel(text, indent)
				if packed then
					castRanks = castRanks or CastRanks(sections)
					specs = InCastOrder(specs, castRanks)
				end
				local line = {
					label = label,
					indent = indent,
					specs = specs,
					grid = lineGrid,
					header = header,
					packed = packed,
					menu = from.menu,
				}
				if from.menu then
					anyMenu = true
				end
				if from.missing then
					line.missingLabel, line.missingWidth =
						MeasureLabel(GetColor("OFF") .. L["BUFF_DUTY_MISSING_INVENTORY"] .. "|r", 0)
				end
				lines[#lines + 1] = line
				nameWidth = math.max(nameWidth, width)
				return line
			end
			-- Each icon's tooltip is headed by its section; a party member's go by their own name (Buff-Duty-Icons.lua).
			local function TagSection(specs, sectionTitle)
				for _, spec in ipairs(specs) do
					spec.sectionTitle = sectionTitle
				end
			end
			TagSection(section.icons, section.label)
			for _, row in ipairs(section.rows) do
				TagSection(row.icons, not section.party and section.label or nil)
			end
			-- A raid group's name sits past its fold glyph.
			local head = Measure(
				GetColor("TITLE") .. section.label .. "|r",
				section.foldable and FOLD_INDENT or 0,
				section.icons,
				grid,
				true,
				section
			)
			if section.foldable then
				head.fold = { subgroup = section.subgroup, folded = section.folded or false }
			end
			for _, row in ipairs(section.rows) do
				-- A row can set its own indent: the weapon hands sit flush with their header.
				Measure(
					row.label,
					row.indent or (row.pet and PET_INDENT or MEMBER_INDENT),
					row.icons,
					row.grid or grid,
					nil,
					row
				)
			end
			lines[#lines].sectionEnd = true
		end
		if not partyBuffsPlaced then
			AddPartyBuffs()
		end
		nameWidth = math.max(math.min(SnapUp(nameWidth, NAME_STEP), MAX_NAME_WIDTH), held.nameWidth)
		held.nameWidth = nameWidth

		local offsetsByGrid, iconWidths = GridSlots(sections)
		held.partyBuffs = math.max(held.partyBuffs, #otherBuffs)
		iconWidths[PARTY_BUFFS_GRID] = held.partyBuffs * (ICON_SIZE + ICON_GAP) - ICON_GAP
		local function ColumnWidth(grid)
			return nameWidth + NAME_GAP + math.max(iconWidths[grid] or 0, ICON_SIZE)
		end
		-- A line's Missing Inventory! sits after its icons and widens the line.
		local function ContentWidth()
			local width = 0
			for _, line in ipairs(top) do
				width =
					math.max(width, ColumnWidth(line.grid) + (line.missingWidth and line.missingWidth + ICON_GAP or 0))
			end
			local partyWidth = ColumnWidth(MAIN_GRID)
			local partyColumns = math.min(parties, PARTIES_PER_ROW)
			if partyColumns > 0 then
				width = math.max(width, (partyColumns - 1) * (partyWidth + COLUMN_GAP) + partyWidth)
			end
			return width
		end

		-- Never narrower than the title plus the close button; a large font widens the name column to fit.
		local arrowSpace = anyMenu and math.ceil(footer.arrow:GetStringWidth()) + ICON_GAP or 0
		local minWidth = math.ceil(title:GetStringWidth()) + TITLE_CLOSE_GAP + CLOSE_SIZE - arrowSpace
		local width = ContentWidth()
		if width < minWidth then
			nameWidth = SnapUp(nameWidth + (minWidth - width), NAME_STEP)
			width = ContentWidth()
		end
		--[[
		    With one column the rounding's extra goes to the names; with parties
		    side by side it widens the gap, since wider names would widen each
		    party. held.nameWidth is set before this, so rounding never builds on
		    itself.
		]]
		local windowWidth = Kit.WindowWidth(width + arrowSpace)
		if math.min(parties, PARTIES_PER_ROW) <= 1 then
			nameWidth = nameWidth + (windowWidth - EDGE * 2 - arrowSpace - width)
			width = ContentWidth()
		end

		-- Every line's icons end before the arrow column, so they line up and each arrow ends where Options' does.
		local right = windowWidth - EDGE - arrowSpace
		local y, bottom =
			PlaceLines(top, EDGE, right, -Kit.WINDOW_BODY_TOP, nameWidth, offsetsByGrid, iconWidths, anyMenu)
		local partyWidth = ColumnWidth(MAIN_GRID)
		for _, partyRow in ipairs(partyRows) do
			local nextY = y
			for index, lines in ipairs(partyRow) do
				-- The rounding's extra width widens the gap, so the last party's icons end at the right edge too.
				local x = EDGE + (index - 1) * (partyWidth + COLUMN_GAP + right - EDGE - width)
				local partyY, partyBottom =
					PlaceLines(lines, x, x + partyWidth, y, nameWidth, offsetsByGrid, iconWidths)
				nextY = math.min(nextY, partyY)
				bottom = math.min(bottom, partyBottom)
			end
			y = nextY
		end

		-- The foot: a spacer, the separator and the Options line, then the key hint a spacer under it.
		y = Kit.PlaceOptionsLine(footer, footerDivider, bottom)
		if showKeyHint then
			y = y - Kit.WINDOW_SPACER
			keyHint:SetWidth(windowWidth - EDGE * 2)
			keyHint:SetText(KeyHintText())
			keyHint:ClearAllPoints()
			keyHint:SetPoint("TOPLEFT", content, "TOPLEFT", EDGE, y)
			keyHint:Show()
			y = y - math.ceil(keyHint:GetStringHeight())
		else
			keyHint:Hide()
		end
		-- 16 under the last text, the hint's or the Options line's, never rounded.
		local windowHeight = Kit.WindowHeight(y, showKeyHint)

		anchor:SetSize(windowWidth, windowHeight)
		-- MIGRATION (remove after 2026-11-29)
		ns.MigrateBuffDutyPosition(anchor)
	end

	content:Show()
	pool.rosterStale = false
	UpdateCooldowns()
	UpdateRange()
	ns.StartBuffDutyRangeTicker()
end

--[[
    Stripped before the redraw, so if it fails no button is left to cast an
    NPC's buff on the player you targeted next.
]]
function ns.DropBuffDutyTargetIcons()
	if InCombatLockdown() or not content then
		return
	end
	for i = 1, pool.used do
		local button = icons[i]
		local unit = button.spec and button.spec.unit
		if unit == "target" or unit == "targetpet" then
			ns.SetBuffButtonAttributes(button, nil)
			button.spec = nil
			button:Hide()
		end
	end
	lastSignature = nil
end

function ns.HideBuffDuty()
	if InCombatLockdown() or not content then
		return
	end
	content:Hide()
	ForgetHeldLayout()
	lastSignature = nil
	pool.rosterStale = false
	ns.HideBuffDutyRoster()
	ns.StopBuffDutyRangeTicker()
end

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

-- False when combat blocks it (the state driver and anchor are protected), so the caller retries after.
function ns.ApplyBuffDutySettings()
	if InCombatLockdown() or not anchor then
		return false
	end
	-- A drag let go in combat ends here, where the anchor may move again.
	if stopPending then
		stopPending = false
		anchor:StopMovingOrSizing()
		ns.SaveBuffDutyPosition(anchor)
	end
	if ns.db.global.buffWindow.hideInCombat then
		RegisterStateDriver(anchor, "visibility", "[combat] hide; show")
	else
		UnregisterStateDriver(anchor, "visibility")
		anchor:Show()
	end
	ns.RestoreBuffDutyPosition(anchor)
	-- A settings change can change how the list is drawn without changing its rows.
	lastSignature = nil
	ForgetHeldLayout()
	return true
end

-- Only the plate fades, and it isn't secure, so this works in combat. preview shows a percent unsaved.
function ns.ApplyBuffDutyOpacity(preview)
	local plate = content and content.menuKitPlate
	if plate then
		local percent = preview or ns.db.global.buffWindow.windowOpacity or 80
		plate:SetAlpha(math.max(0, math.min(100, percent)) / 100)
	end
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function ns.CreateBuffDutyFrame()
	anchor = CreateFrame("Frame", nil, UIParent)
	anchor:SetSize(1, 1)
	anchor:SetMovable(true)
	anchor:SetClampedToScreen(true)
	anchor:SetFrameStrata("MEDIUM")

	content = CreateFrame("Frame", nil, anchor)
	pool.content = content
	content:SetAllPoints(anchor)
	Kit.AddPlate(content)
	ns.ApplyBuffDutyOpacity()
	content:EnableMouse(true)
	content:RegisterForDrag("LeftButton")
	-- So a drag of a locked window saves no position.
	local moving = false
	content:SetScript("OnDragStart", function()
		if not ns.db.global.buffWindow.locked and not InCombatLockdown() then
			moving = true
			anchor:StartMoving()
		end
	end)
	--[[
	    StopMovingOrSizing re-anchors to the nearest screen point (often
	    CENTER), so a resize would grow from the middle; re-applying the saved
	    top-right keeps the close button fixed.
	]]
	content:SetScript("OnDragStop", function()
		if not moving then
			return
		end
		moving = false
		if InCombatLockdown() then
			stopPending = true
			ns.QueueBuffDutySettings()
			return
		end
		anchor:StopMovingOrSizing()
		ns.SaveBuffDutyPosition(anchor)
		ns.RestoreBuffDutyPosition(anchor)
	end)

	--[[
	    Closing goes through the redraw's own gate, so the next roster or aura
	    change can't reopen it.
	]]
	title = Kit.AddWindowHeader(content, L["TAB_BUFF_DUTY"], ns.CloseBuffDuty)

	keyHint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	keyHint:SetJustifyH("LEFT")
	keyHint:SetJustifyV("TOP")
	keyHint:SetWordWrap(true)
	keyHint:Hide()

	--[[
	    The line opens Buff Duty's own options menu in place of the kit's,
	    which is left unused: that one menu also opens from the mini-map.
	]]
	footer, footerDivider = Kit.AddOptionsLine(content, L["BUFF_DUTY_MENU_OPTIONS"], function()
		return {}
	end)
	local function OpenOptions(self)
		ns.ShowBuffDutyOptions(self)
	end
	footer:SetScript("OnEnter", OpenOptions)
	footer:SetScript("OnClick", OpenOptions)

	content:Hide()
end
