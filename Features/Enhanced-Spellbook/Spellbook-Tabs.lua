local _, ns = ...
local BODY = ns.COLORS_RGB.BODY
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip

--[[
	The page's launcher tab on the Retail-engine spellbook (Blizzard_PlayerSpells), for
	Features/Enhanced-Spellbook/Spellbook-Host-Modern.lua: a tab that runs its onClick and lights while isSelected says so.

	Placement: side tabs in the Classic style, stacked down the window's right edge from the height of the native
	skill line tabs, skipping over tab-sized frames from other add-ons that sit on that edge. Only frames that
	overlap the next free slot push it along, so an add-on that places itself after these tabs can't make them
	leapfrog each other.

	Every frame here is parented to UIParent and only anchored over the book: a frame parented to a Blizzard
	panel stays protected, and in combat could no longer be shown, moved or scaled. Nothing Blizzard owns is
	written to.
]]

local TAB_WIDTH, TAB_HEIGHT, GAP = 32, 32, 17 -- the Classic book's skill line tab size and spacing

local SpellbookTabs = {
	tabs = {},
	byId = {},
	owned = {}, -- every frame this file creates, so none is taken for another add-on's
	hookedForeign = {},
}

ns.SpellbookTabs = SpellbookTabs

local function Own(frame)
	SpellbookTabs.owned[frame] = true
	return frame
end

local function MakeTab(parent, icon)
	local button = Own(CreateFrame("Button", nil, parent))
	button:SetSize(TAB_WIDTH, TAB_HEIGHT)
	-- the same art as the Classic host's side tab (Features/Enhanced-Spellbook/Spellbook-Host-Classic.lua)
	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
	background:SetSize(64, 64)
	background:SetPoint("TOPLEFT", -3, 11)
	button:SetNormalTexture(icon)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button.checked = button:CreateTexture(nil, "OVERLAY")
	button.checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	button.checked:SetBlendMode("ADD")
	button.checked:SetAllPoints()
	button.checked:Hide()
	return button
end

local function SelectTab(button, selected)
	button.checked:SetShown(selected)
end

--[[
	left, bottom, right, top in screen pixels, so frames with different scales compare. Nothing for an unplaced
	frame, or one whose rect is secret on Forever (the game's own aura container): its numbers can't be used.
]]
local function ScreenRect(frame)
	local left, bottom, width, height = frame:GetRect()
	if
		not left
		or ns.IsSecretValue(left)
		or ns.IsSecretValue(bottom)
		or ns.IsSecretValue(width)
		or ns.IsSecretValue(height)
	then
		return
	end
	local scale = frame:GetEffectiveScale()
	return left * scale, bottom * scale, (left + width) * scale, (bottom + height) * scale
end

-- shown, tab-sized frames we don't own: other add-ons' launchers
local function CollectObstacles(tabScreenWidth, tabScreenHeight)
	local rects = {}
	local seen = {}
	local function Scan(parent)
		if not parent then
			return
		end
		for _, child in ipairs({ parent:GetChildren() }) do
			if not seen[child] and not SpellbookTabs.owned[child] and not child:IsForbidden() and child:IsVisible() then
				seen[child] = true
				local left, bottom, right, top = ScreenRect(child)
				if left then
					local width, height = right - left, top - bottom
					if
						width > tabScreenWidth * 0.4
						and width < tabScreenWidth * 2
						and height > tabScreenHeight * 0.4
						and height < tabScreenHeight * 2
					then
						rects[#rects + 1] = { frame = child, left = left, bottom = bottom, right = right, top = top }
					end
				end
			end
		end
	end
	Scan(PlayerSpellsFrame)
	Scan(SpellbookTabs.book)
	Scan(UIParent)
	return rects
end

--[[
	Frames Blizzard keeps under a key on the spells frame or the book (the book itself, the talents page, the
	close, minimize and settings buttons), so they're never taken for another add-on's launcher.
]]
local function BlizzardFrames()
	local set = {}
	for _, parent in ipairs({ PlayerSpellsFrame, SpellbookTabs.book }) do
		for _, value in pairs(parent) do
			if type(value) == "table" then
				set[value] = true
			end
		end
	end
	return set
end

-- first free spot down the edge, pushed past every obstacle that overlaps the slot
local function NextFreeColumnSlot(obstacles, y, height, left, right, gap)
	local moved = true
	while moved do
		moved = false
		for _, rect in ipairs(obstacles) do
			if rect.bottom < y and rect.top > y - height and rect.left < right and rect.right > left then
				y = rect.bottom - gap
				moved = true
			end
		end
	end
	return y
end

--[[
	reuse keeps the launchers found by the last full look, for a page turn or a search keystroke, which move
	nothing around the book; every show, resize and launcher appearing looks again.
]]
function SpellbookTabs:Layout(reuse)
	local book = self.book
	-- the whole window, so the tabs hang off its border whether it shows the talents too or only the book
	local window = PlayerSpellsFrame
	local scale = book:GetEffectiveScale()
	local _, windowBottom, windowRight, windowTop = ScreenRect(window)
	if not windowRight then
		return
	end
	local width, height, gap = TAB_WIDTH * scale, TAB_HEIGHT * scale, GAP * scale
	local obstacles = reuse and self.obstacles or CollectObstacles(width, height)
	self.obstacles = obstacles

	-- other add-ons' launchers sit where these tabs go, down the window's right edge
	local blizzard = BlizzardFrames()
	for _, rect in ipairs(obstacles) do
		local byEdge = rect.left > windowRight - width / 2
			and rect.left < windowRight + width
			and rect.top < windowTop + height
			and rect.bottom > windowBottom
		if byEdge and not blizzard[rect.frame] then
			self:HookLauncher(rect.frame)
		end
	end
	-- the first tab lines up with the top of the native skill line tabs, the way the Classic book's side tabs start
	local tabsTop = book.CategoryTabSystem and select(4, ScreenRect(book.CategoryTabSystem))
	local columnTop = tabsTop or (windowTop - 60 * scale)
	for _, tab in ipairs(self.tabs) do
		local button = tab.button
		button:ClearAllPoints()
		columnTop = NextFreeColumnSlot(obstacles, columnTop, height, windowRight, windowRight + width, gap)
		button:SetPoint("TOPLEFT", window, "TOPRIGHT", 0, (columnTop - windowTop) / scale)
		columnTop = columnTop - height - gap
	end
end

function SpellbookTabs:Sync(reuse)
	local book = self.book
	if not book then
		return
	end
	local gamepad = InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()
	-- with the Spellbook switched off, its tab goes too: it is the only one registered
	if gamepad or not book:IsVisible() or #self.tabs == 0 or not ns.IsSpellbookEnabled() then
		for _, tab in ipairs(self.tabs) do
			tab.button:Hide()
		end
		return
	end

	-- the buttons hang off UIParent, so they take the book's scale and sit in its strata, under its border
	local scale = book:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local strata, level = PlayerSpellsFrame:GetFrameStrata(), PlayerSpellsFrame.NineSlice:GetFrameLevel() - 5
	for _, tab in ipairs(self.tabs) do
		local button = tab.button
		button:SetScale(scale)
		button:SetFrameStrata(strata)
		button:SetFrameLevel(level)
		SelectTab(button, tab.isSelected ~= nil and tab.isSelected())
		button:Show()
	end
	self:Layout(reuse)
end

-- One sync next frame however many ask; it looks for launchers afresh unless every request said reuse.
function SpellbookTabs:RequestSync(reuse)
	if not reuse then
		self.lookAgain = true
	end
	if self.queued then
		return
	end
	self.queued = true
	RunNextFrame(function()
		local lookAgain = SpellbookTabs.lookAgain
		SpellbookTabs.queued, SpellbookTabs.lookAgain = false, false
		SpellbookTabs:Sync(not lookAgain)
	end)
end

-- other add-ons lay out on the same show/resize events, so look again once they've settled
local function Relayout()
	SpellbookTabs:RequestSync()
	C_Timer.After(0.2, function()
		SpellbookTabs:RequestSync()
	end)
end

-- another add-on's launcher can appear after ours were placed, so lay out again when it shows
function SpellbookTabs:HookLauncher(launcher)
	if self.hookedForeign[launcher] or not launcher:HasScript("OnShow") then
		return
	end
	self.hookedForeign[launcher] = true
	launcher:HookScript("OnShow", Relayout)
end

function SpellbookTabs:CreateButton(tab)
	local button = MakeTab(UIParent, tab.icon)
	tab.button = button
	button:Hide()
	button:SetScript("OnClick", function()
		tab.onClick()
	end)
	button:SetScript("OnEnter", function(tabButton)
		GameTooltip:SetOwner(tabButton, "ANCHOR_RIGHT")
		GameTooltip:SetText(tab.name)
		if tab.description then
			GameTooltip:AddLine(tab.description, BODY.r, BODY.g, BODY.b, true)
		end
		if tab.hint then
			GameTooltip:AddDoubleLine(GetColor("INFO") .. tab.hint[1] .. "|r", GetColor("INFO") .. tab.hint[2] .. "|r")
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", HideTooltip)
	button:SetScript("OnHide", HideTooltip)
end

function SpellbookTabs:Attach()
	if self.book then
		return
	end
	local book = PlayerSpellsFrame.SpellBookFrame
	self.book = book

	for _, tab in ipairs(self.tabs) do
		self:CreateButton(tab)
	end

	local function Request()
		SpellbookTabs:RequestSync()
	end
	for _, event in ipairs({ "SpellBookFrame.Show", "SpellBookFrame.Hide" }) do
		EventRegistry:RegisterCallback("PlayerSpellsFrame." .. event, Request, SpellbookTabs)
	end
	EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged", function()
		SpellbookTabs:RequestSync(true)
	end, SpellbookTabs)
	book:HookScript("OnSizeChanged", Relayout)
	book:HookScript("OnShow", Relayout)
	book:HookScript("OnHide", function()
		SpellbookTabs:Sync()
	end)
	self:RequestSync()
end

--[[
	info is { name (the tab's tooltip title), description (a white line under it), hint ({ key, action }, a
	blue pair under that), icon (texture path or fileID), onClick() (what a click runs), isSelected() (when to
	light it) }; description, hint and isSelected are optional.
]]
function SpellbookTabs:RegisterTab(id, info)
	if self.byId[id] then
		return self.byId[id]
	end
	local tab = {
		id = id,
		name = info.name,
		description = info.description,
		hint = info.hint,
		icon = info.icon or ns.QUESTION_MARK_ICON,
		onClick = info.onClick,
		isSelected = info.isSelected,
	}
	self.tabs[#self.tabs + 1] = tab
	self.byId[id] = tab
	if self.book then
		self:CreateButton(tab)
		self:RequestSync()
	end
	return tab
end

--[[
	The game's book (Blizzard_PlayerSpells) loads on demand, often only when it first opens, so the tab attaches
	when it loads, through the Spellbook's dispatcher (Spellbook-Core.lua), or at once if it already has.
	Attached, nothing else here needs ADDON_LOADED, so it is dropped.
]]
function ns:OnAddonLoaded(addonName)
	if addonName == "Blizzard_PlayerSpells" then
		SpellbookTabs:Attach()
		ns.SetModuleEvent("Spellbook", "ADDON_LOADED", false)
	end
end

if C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
	SpellbookTabs:Attach()
else
	ns.SetModuleEvent("Spellbook", "ADDON_LOADED", true)
end
