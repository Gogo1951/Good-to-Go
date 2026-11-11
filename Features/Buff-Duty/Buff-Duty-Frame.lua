local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor
local AcquireOtherIcon = ns.AcquireBuffDutyOtherIcon
local SetOtherIcon = ns.SetBuffDutyOtherIcon
local UpdateCooldowns = ns.UpdateBuffDutyCooldowns
local UpdateRange = ns.UpdateBuffDutyRange

--[[
    The Buff Duty window's frames: draws the sections Features/Buff-Duty/Buff-Duty.lua builds
    as a click-to-cast list. Every list icon is a SecureActionButtonTemplate button,
    because casting a spell from a click is protected -- and that one fact shapes
    this file. A secure button's attributes, position and visibility can only
    change out of combat, so everything that lays the window out refuses to run
    in combat, and the caller redraws once combat ends. Mid-fight only alpha
    (the range fade), which the client allows on a protected frame, and the
    cooldown swipes, plain children of the buttons, still change.

    The Party-Buffs icons and their hover menu are
    Buff-Duty-Party-Buffs.lua; the icons' cooldown swipes and range fade are
    Buff-Duty-Icon-State.lua; the icons' secure attributes are
    Buff-Duty-Button-Attributes.lua; the window's saved position is
    Buff-Duty-Position.lua.

    Two frames stack so combat visibility and our own never fight: the anchor
    belongs to a secure state driver (Hide in Combat), and the content inside it
    is shown and hidden by this file, out of combat only. The content carries a
    title bar whose close button hides Buff Duty until the next login or
    reload, saving nothing (ns.CloseBuffDuty).
]]

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

--[[
    Also how tall every line's content stands, a bare header included: the
    window's top and bottom edges are measured from it, so a line keeps its
    room whether or not a buff icon is showing, and the window holds still as
    icons come and go.
]]
local ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE
local ICON_GAP = 4
-- An icon plus the same 4-pixel gap between rows as between icons.
local ROW_HEIGHT = ICON_SIZE + ICON_GAP
--[[
    Extra room under each section (a party, Return the Favor, Target), so one
    party's last member doesn't crowd the next party's header.
]]
local SECTION_GAP = 4
--[[
    The name column fits the longest name on the list, between these bounds:
    never narrower than a short name needs to look tidy, and never so wide that a
    long title-and-realm string pushes the icons off across the screen.
]]
local MIN_NAME_WIDTH = 64
local MAX_NAME_WIDTH = 256
--[[
    The name column grows in whole steps of this, not to the pixel, so a
    slightly longer name doesn't nudge the window wider.
]]
local NAME_STEP = 16
-- Room between the end of the longest name and the first icon.
local NAME_GAP = 8
-- A member's role icon lines up with the header above it.
local MEMBER_INDENT = 0
--[[
    Parties sit two to a row, reading across -- 1 2, then 3 4 -- and the
    columns stand this far apart.
]]
local PARTIES_PER_ROW = 2
local COLUMN_GAP = 16
-- A pet sits one step further in, under its owner.
local PET_INDENT = 16
local PADDING = 8
--[[
    The title bar: one icon-high row for the title and close button, then a
    32-point gap before the first section so the title doesn't read as one of them.
]]
local TITLE_HEIGHT = ICON_SIZE
local TITLE_GAP = 32
local CLOSE_SIZE = 22
-- Room between the end of the title and the close button.
local TITLE_CLOSE_GAP = 8

local BACKDROP = Data.BUFF_DUTY_BACKDROP

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local anchor, content, title, keyHint
local labels, usedLabels = {}, 0
-- The list's icons, shared with the cooldown and range passes (Buff-Duty-Icon-State.lua).
local pool = ns.buffDutyIconPool
local icons = pool.buttons
local lastSignature

--[[
    What the window holds on to while it stays up for the same group, so it
    keeps its width as buffs are cast: every grid's columns any icon has used
    (a buff cast on everyone leaves its column empty rather than pulling the
    icons left under the cursor), the widest name column, and the most
    Party-Buffs icons. Let go when the window hides (everything's buffed), the
    group's size changes, or a setting changes (ns.ApplyBuffDutySettings).
]]
local held = { columns = {}, nameWidth = 0, partyBuffs = 0 }

local function ForgetHeldLayout()
	held.columns, held.nameWidth, held.partyBuffs = {}, 0, 0
end

local function RosterKey()
	return (IsInRaid() and "raid" or "party") .. GetNumGroupMembers()
end

-- value rounded up to the next whole step
local function SnapUp(value, step)
	return math.ceil(value / step) * step
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

local function OnIconEnter(self)
	local spec = self.spec
	if not spec then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if spec.itemId then
		GameTooltip:SetItemByID(spec.itemId)
	else
		GameTooltip:SetSpellByID(spec.spellId)
	end
	GameTooltip:AddLine(" ")
	--[[
	    Who the click lands on, not which click: every icon here casts on a
	    click. A Self Buffs weapon or Soulstone icon brings its own line, already
	    worded.
	]]
	local hint = spec.hint
	if not hint then
		local text = (spec.favorGUID and L["BUFF_DUTY_TOOLTIP_FAVOR"])
			or (spec.isGroup and L["BUFF_DUTY_TOOLTIP_GROUP"])
			or L["BUFF_DUTY_TOOLTIP_CAST"]
		hint = text:format(spec.targetName)
	end
	GameTooltip:AddLine(GetColor("HELP") .. hint .. "|r", 1, 1, 1, true)
	GameTooltip:Show()
end

local function OnIconLeave()
	GameTooltip:Hide()
end

--[[
    PreClick, because the secure click fires the game's "replace your
    enchant?" question before PostClick runs (Buff-Duty-Weapons.lua answers it).
    Every cast is noted too, so a "more powerful spell" refusal can be pinned
    on who it was aimed at (ns.NoteBuffCastAttempt).
]]
local function OnIconPreClick(self, button)
	if button ~= "LeftButton" or not self.spec then
		return
	end
	if self.spec.confirmReplace then
		ns.ExpectReplaceEnchant()
	end
	ns.NoteBuffCastAttempt(self.spec)
end

--[[
    Right-click on a favor drops that stranger from the list. Buttons register
    both up and down (below), so this answers the up half only.
]]
local function OnIconPostClick(self, button, down)
	if button == "RightButton" and not down and self.spec and self.spec.favorGUID then
		ns.DismissFavor(self.spec.favorGUID)
	end
end

local function AcquireIcon()
	pool.used = pool.used + 1
	local button = icons[pool.used]
	if not button then
		button = CreateFrame("Button", nil, content, "SecureActionButtonTemplate")
		button:SetSize(ICON_SIZE, ICON_SIZE)
		--[[
		    Both halves: the secure template acts on the one ActionButtonUseKeyDown
		    names and ignores the other, so registering only "AnyUp" leaves the
		    button dead for anyone casting on key down.
		]]
		button:RegisterForClicks("AnyUp", "AnyDown")
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		-- Trims the baked-in border every spell icon carries.
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		--[[
		    The action bar's own swipe and countdown, so a buff still on cooldown
		    reads exactly as it would on a bar (OmniCC and friends pick it up too).
		    A plain child of the secure button, so it updates freely in combat.
		]]
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cooldown:SetAllPoints()
		button.cooldown:SetHideCountdownNumbers(false)
		-- The template's numbers are sized for a 36-pixel bar button; ours is 16 (Data.BUFF_DUTY_ICON_SIZE).
		if button.cooldown.SetCountdownFont then
			button.cooldown:SetCountdownFont("GameFontHighlightSmallOutline")
		end
		button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
		button:SetScript("OnEnter", OnIconEnter)
		button:SetScript("OnLeave", OnIconLeave)
		button:SetScript("PreClick", OnIconPreClick)
		button:SetScript("PostClick", OnIconPostClick)
		icons[pool.used] = button
	end
	return button
end

local function SetIcon(button, spec)
	button.spec = spec
	if spec.itemId then
		button.icon:SetTexture(C_Item.GetItemIconByID(spec.itemId))
	else
		button.icon:SetTexture(C_Spell.GetSpellTexture(spec.spellId))
	end
	ns.SetBuffButtonAttributes(button, spec)
	button:Show()
end

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

local function AcquireLabel()
	usedLabels = usedLabels + 1
	local label = labels[usedLabels]
	if not label then
		label = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		label:SetJustifyH("LEFT")
		label:SetWordWrap(false)
		labels[usedLabels] = label
	end
	return label
end

--------------------------------------------------------------------------------
-- Render
--------------------------------------------------------------------------------

--[[
    Everything a redraw would write, as one string, so an unchanged list (the
    usual result of a raid's constant aura traffic) skips the redraw entirely.
]]
local function Signature(sections, otherBuffs)
	local parts = {}
	-- The names too: the hover list is read off the spec the last redraw set.
	for _, spec in ipairs(otherBuffs) do
		parts[#parts + 1] = "!" .. spec.key .. ":" .. table.concat(spec.recipients, ",")
		for _, group in ipairs(spec.groups) do
			parts[#parts + 1] = group.label .. ":" .. table.concat(group.names, ",")
		end
	end
	local function AddIcons(list)
		for _, spec in ipairs(list) do
			parts[#parts + 1] = spec.column
				.. ":"
				.. (spec.castSpell or spec.spellName or spec.item or ("item:" .. tostring(spec.itemId)))
				.. "@"
				.. (spec.unit or "")
				.. (spec.targetSlot or "")
				.. (spec.macrotext or "")
				.. "~"
				.. (spec.buffExpires or "")
		end
	end
	for _, section in ipairs(sections) do
		parts[#parts + 1] = "#" .. (section.grid or "") .. section.label
		AddIcons(section.icons)
		for _, row in ipairs(section.rows) do
			parts[#parts + 1] = (row.pet and ">>" or ">") .. (row.grid or "") .. row.label
			AddIcons(row.icons)
		end
	end
	return table.concat(parts, "|")
end

--[[
    A width of 0 lets the text run unconstrained, so the measure is the whole
    name rather than whatever fit the last layout's column.
]]
local function MeasureLabel(text, indent)
	local label = AcquireLabel()
	label:SetWidth(0)
	label:SetText(text)
	return label, indent + label:GetStringWidth()
end

--[[
    `offsets` maps a buff's column to how far its icon sits from the grid's
    first, in pixels. `x` is the left edge of the window column the row sits
    in, `y` the row's middle.
]]
local function PlaceRow(line, x, y, nameWidth, offsets)
	local label, indent = line.label, line.indent
	label:ClearAllPoints()
	label:SetPoint("LEFT", content, "TOPLEFT", x + indent, y)
	label:SetWidth(nameWidth - indent)
	label:Show()

	local left = x + nameWidth + NAME_GAP
	for _, spec in ipairs(line.specs) do
		local button = AcquireIcon()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + offsets[spec.column], y)
		SetIcon(button, spec)
	end
	-- The Party-Buffs header's icons: plain buttons, side by side from the first icon column.
	for index, spec in ipairs(line.partyBuffs or {}) do
		local button = AcquireOtherIcon(content)
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + (index - 1) * (ICON_SIZE + ICON_GAP), y)
		SetOtherIcon(button, spec)
	end
end

--[[
    The icons sit in a grid: one column per buff, so a buff lines up down the
    whole window and a party's group buff sits over the single one it
    replaces. A member who doesn't need a buff leaves its cell empty. Only the
    columns some icon uses are kept, in buff order, so a buff nobody needs
    leaves no gap.

    A section can name its own grid (Self Buffs does): its columns are other
    buffs than the parties', so lining them up with the parties' would only
    push them right. A row can name one too (each weapon hand does), so its
    icons start at the left whatever the header's hold. Returns grid ->
    (column -> pixels from the first icon), and grid -> the icons' whole
    width. The party columns share one grid, so a buff sits at the same place
    in each. The columns the window holds (held.columns) are kept too.
]]
local MAIN_GRID = "main"

local function GridSlots(sections)
	local used = held.columns
	local function Mark(grid, list)
		used[grid] = used[grid] or {}
		for _, spec in ipairs(list) do
			used[grid][spec.column] = true
		end
	end
	for _, section in ipairs(sections) do
		local grid = section.grid or MAIN_GRID
		Mark(grid, section.icons)
		for _, row in ipairs(section.rows) do
			Mark(row.grid or grid, row.icons)
		end
	end

	local offsetsByGrid, widths = {}, {}
	for grid, columnSet in pairs(used) do
		local columns = {}
		for column in pairs(columnSet) do
			columns[#columns + 1] = column
		end
		table.sort(columns)
		local offsets, x = {}, 0
		for slot, column in ipairs(columns) do
			if slot > 1 then
				x = x + ICON_SIZE + ICON_GAP
			end
			offsets[column] = x
		end
		offsetsByGrid[grid] = offsets
		widths[grid] = #columns > 0 and x + ICON_SIZE or 0
	end
	return offsetsByGrid, widths
end

--[[
    Places a run of lines down from `y`, the first one's middle. Returns where
    the next run's first middle goes, and the lowest edge this run drew.
]]
local function PlaceLines(lines, x, y, nameWidth, offsetsByGrid)
	local bottom = y
	for _, line in ipairs(lines) do
		if line.spaceBefore then
			y = y - ROW_HEIGHT
		end
		PlaceRow(line, x, y, nameWidth, offsetsByGrid[line.grid])
		bottom = y - ICON_SIZE / 2
		y = y - ROW_HEIGHT
		if line.sectionEnd then
			y = y - SECTION_GAP
		end
	end
	return y, bottom
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
end

--[[
    `otherBuffs` is the Party-Buffs section's icons: the raid buffs your group
    is missing (Buff-Duty-Other-Classes.lua). Not a section of its own in
    `sections`, since the Buff Key never casts them and their icons aren't
    secure buttons, but drawn like one, under Self-Buffs.
]]
local PARTY_BUFFS_GRID = "partyBuffs"

--[[
    The window's last line while the Buff Button has no key: a blank row under
    everything else, then a tip pointing at the Key Bindings section. It wraps
    to the window's width rather than widening it, and goes away once a key is
    bound (UPDATE_BINDINGS asks for a redraw, Features/Key-Bindings.lua).
]]
local function KeyHintText()
	local info = GetColor("INFO")
	local help = GetColor("HELP")
	return help
		.. L["BUFF_DUTY_KEY_HINT"]:format(
			info .. L["BUFF_KEY"] .. "|r" .. help,
			L["OPTIONS_KEY_BINDINGS_HEADER"],
			info .. L["OPTIONS_COMMAND"] .. "|r" .. help
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
		    Two passes: every label is measured before any is placed, because the
		    icon column starts where the longest name ends. The sections before
		    the parties (Self-Buffs, Party-Buffs, Target, Return the Favor) run down the top;
		    the parties go under them PARTIES_PER_ROW to a row, so a full raid's
		    eight groups stand four rows high instead of running off the screen.
		]]
		local top, partyRows = {}, {}
		local parties = 0
		local nameWidth = MIN_NAME_WIDTH
		local partyBuffsPlaced = #otherBuffs == 0
		local function AddPartyBuffs()
			partyBuffsPlaced = true
			local label, labelWidth = MeasureLabel(GetColor("TITLE") .. L["BUFF_DUTY_PARTY_BUFFS_HEADER"] .. "|r", 0)
			top[#top + 1] = {
				label = label,
				indent = 0,
				specs = {},
				partyBuffs = otherBuffs,
				grid = PARTY_BUFFS_GRID,
				header = true,
				sectionEnd = true,
				-- a blank row between Self-Buffs and Party-Buffs, as under the title
				spaceBefore = #top > 0,
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
			local function Measure(text, indent, specs, lineGrid, header)
				local label, width = MeasureLabel(text, indent)
				lines[#lines + 1] = { label = label, indent = indent, specs = specs, grid = lineGrid, header = header }
				nameWidth = math.max(nameWidth, width)
			end
			Measure(GetColor("TITLE") .. section.label .. "|r", 0, section.icons, grid, true)
			for _, row in ipairs(section.rows) do
				-- A row can set its own indent: the weapon hands sit flush with their header.
				Measure(row.label, row.indent or (row.pet and PET_INDENT or MEMBER_INDENT), row.icons, row.grid or grid)
			end
			lines[#lines].sectionEnd = true
		end
		if not partyBuffsPlaced then
			AddPartyBuffs()
		end
		nameWidth = math.max(math.min(SnapUp(nameWidth, NAME_STEP), MAX_NAME_WIDTH), held.nameWidth)
		held.nameWidth = nameWidth

		-- A window column: the names, then as many icons as its grid keeps.
		local offsetsByGrid, iconWidths = GridSlots(sections)
		held.partyBuffs = math.max(held.partyBuffs, #otherBuffs)
		iconWidths[PARTY_BUFFS_GRID] = held.partyBuffs * (ICON_SIZE + ICON_GAP) - ICON_GAP
		local function ColumnWidth(grid)
			return nameWidth + NAME_GAP + math.max(iconWidths[grid] or 0, ICON_SIZE)
		end
		local function ContentWidth()
			local width = 0
			for _, line in ipairs(top) do
				width = math.max(width, ColumnWidth(line.grid))
			end
			local partyWidth = ColumnWidth(MAIN_GRID)
			local partyColumns = math.min(parties, PARTIES_PER_ROW)
			if partyColumns > 0 then
				width = math.max(width, (partyColumns - 1) * (partyWidth + COLUMN_GAP) + partyWidth)
			end
			return width
		end

		--[[
		    The close button sits over the far-right icon column (see
		    CreateBuffDutyFrame), so the window is never narrower than the
		    title plus that column. A short list widens its name column to make
		    up the difference, which pushes the icons right until the last one
		    sits under the close button.
		]]
		local minWidth = math.ceil(title:GetStringWidth()) + TITLE_CLOSE_GAP + (CLOSE_SIZE + ICON_SIZE) / 2
		local width = ContentWidth()
		if width < minWidth then
			nameWidth = SnapUp(nameWidth + (minWidth - width), NAME_STEP)
			width = ContentWidth()
		end

		--[[
		    Rows sit ROW_HEIGHT apart, middle to middle, but the first and last
		    are measured by what they show: TITLE_GAP under the title bar to the
		    top of the first line's content, and PADDING from the bottom of the
		    lowest's to the window's edge, the same as the sides. The parties in a
		    row start level, and the next row starts under the taller of them.
		]]
		local firstMiddle = -(PADDING + TITLE_HEIGHT + TITLE_GAP + ICON_SIZE / 2)
		local y, bottom = PlaceLines(top, PADDING, firstMiddle, nameWidth, offsetsByGrid)
		local partyWidth = ColumnWidth(MAIN_GRID)
		for _, partyRow in ipairs(partyRows) do
			local nextY = y
			for index, lines in ipairs(partyRow) do
				local x = PADDING + (index - 1) * (partyWidth + COLUMN_GAP)
				local partyY, partyBottom = PlaceLines(lines, x, y, nameWidth, offsetsByGrid)
				nextY = math.min(nextY, partyY)
				bottom = math.min(bottom, partyBottom)
			end
			y = nextY
		end

		-- A blank row, then the tip, its top where that row's content would end.
		if showKeyHint then
			local hintTop = bottom - ROW_HEIGHT - ICON_GAP
			keyHint:ClearAllPoints()
			keyHint:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, hintTop)
			keyHint:SetWidth(width)
			keyHint:SetText(KeyHintText())
			keyHint:Show()
			bottom = hintTop - math.ceil(keyHint:GetStringHeight())
		else
			keyHint:Hide()
		end

		anchor:SetSize(PADDING * 2 + width, -bottom + PADDING)
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
    Your target changed: every icon that casts at "target" or "targetpet" now
    aims at someone the window never looked at, so each is stripped and hidden
    before the redraw. If the redraw then fails, no button is left behind to
    cast an NPC's buff on the player you targeted next.
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

--[[
    Applies Hide in Combat and the saved position. Returns false when combat
    blocks it -- the state driver and the anchor are both protected then -- so
    the caller can apply it again once combat ends.
]]
function ns.ApplyBuffDutySettings()
	if InCombatLockdown() or not anchor then
		return false
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

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function ns.CreateBuffDutyFrame()
	anchor = CreateFrame("Frame", nil, UIParent)
	anchor:SetSize(1, 1)
	anchor:SetMovable(true)
	anchor:SetClampedToScreen(true)
	anchor:SetFrameStrata("MEDIUM")

	content = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
	pool.content = content
	content:SetAllPoints(anchor)
	content:SetBackdrop(BACKDROP)
	content:SetBackdropColor(0, 0, 0, 0.75)
	content:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	content:EnableMouse(true)
	content:RegisterForDrag("LeftButton")
	content:SetScript("OnDragStart", function()
		if not ns.db.global.buffWindow.locked and not InCombatLockdown() then
			anchor:StartMoving()
		end
	end)
	--[[
	    StopMovingOrSizing re-anchors the frame to whichever screen point is
	    nearest (often CENTER), so a resize after a drag would grow from the
	    middle. Re-applying the saved top-right keeps the close button fixed. The
	    anchor holds the secure icons, so a drag let go once combat has begun
	    waits for it to end before re-anchoring.
	]]
	content:SetScript("OnDragStop", function()
		anchor:StopMovingOrSizing()
		ns.SaveBuffDutyPosition(anchor)
		if InCombatLockdown() then
			ns.QueueBuffDutySettings()
			return
		end
		ns.RestoreBuffDutyPosition(anchor)
	end)

	-- Titled like the other windows, the add-on's name last: "Buff Duty // GtG".
	title = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("LEFT", content, "TOPLEFT", PADDING, -(PADDING + TITLE_HEIGHT / 2))
	title:SetText(
		GetColor("TEXT")
			.. L["TAB_BUFF_DUTY"]
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//|r "
			.. GetColor("INFO")
			.. L["ADDON_SHORT_NAME"]
			.. "|r"
	)

	--[[
	    Closing hides the window for the session (ns.CloseBuffDuty) through the
	    redraw's own gate, so the next roster or aura change can't reopen it.
	    The template's own click hides its parent, which is protected (it holds
	    the secure icons), so the script is replaced outright.
	]]
	local close = CreateFrame("Button", nil, content, "UIPanelCloseButton")
	close:SetSize(CLOSE_SIZE, CLOSE_SIZE)
	-- Centered over the far-right icon column, which ends PADDING from the edge.
	close:SetPoint("CENTER", content, "TOPRIGHT", -(PADDING + ICON_SIZE / 2), -(PADDING + TITLE_HEIGHT / 2))
	close:SetScript("OnClick", ns.CloseBuffDuty)

	-- The Buff Button tip under the list (KeyHintText); placed and shown by RenderBuffDuty.
	keyHint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	keyHint:SetJustifyH("LEFT")
	keyHint:SetJustifyV("TOP")
	keyHint:SetWordWrap(true)
	keyHint:Hide()

	content:Hide()
end
