local _, ns = ...
local BODY = ns.COLORS_RGB.BODY
local L = ns.L
local HideTooltip = ns.HideTooltip

--[[
	The tab is parented to UIParent and only anchored to the book, and the book is only hooked, so its own
	buttons stay untainted.
]]

local ICON_ADDON = ns.ICON_ADDON

local TAB_GAP = 17 -- the space the book leaves between its skill line tabs

local book = SpellBookFrame
local tab

-- The tab shows only over the book's own spell pages, never the pet book or another tab of it.
local function ShowsSpells()
	return book:IsShown() and (book.bookType == nil or book.bookType == BOOKTYPE_SPELL)
end

local function SyncTab()
	tab.checked:SetShown(ns.IsSpellbookWindowShown())
end

--[[
	The class's last spell tab: other add-ons fill the book's spare slots (WhatsTraining takes the second to
	last), and under the last shown tab ours would fall off the bottom of the book.
]]
local function AnchorSkillLineTab()
	local classLast = GetNumSpellTabs and _G["SpellBookSkillLineTab" .. GetNumSpellTabs()]
	if classLast and classLast:IsShown() then
		return classLast
	end
	local last
	local i = 1
	while _G["SpellBookSkillLineTab" .. i] do
		local skillLineTab = _G["SpellBookSkillLineTab" .. i]
		if skillLineTab:IsShown() then
			last = skillLineTab
		end
		i = i + 1
	end
	return last
end

local function Sync()
	local shown = ShowsSpells() and ns.IsSpellbookEnabled()
	tab:SetShown(shown)
	if shown then
		tab:ClearAllPoints()
		local last = AnchorSkillLineTab()
		if last then
			tab:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -TAB_GAP)
		else
			tab:SetPoint(SpellBookSkillLineTab1:GetPoint(1))
		end
		tab:SetFrameStrata(book:GetFrameStrata())
		tab:SetFrameLevel(book:GetFrameLevel() + 30)
	end
	SyncTab()
end

local function CreateTab()
	tab = CreateFrame("Button", nil, UIParent)
	tab:SetSize(32, 32)
	tab:Hide()
	local background = tab:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
	background:SetSize(64, 64)
	background:SetPoint("TOPLEFT", -3, 11)
	tab:SetNormalTexture(ICON_ADDON)
	tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	tab.checked = tab:CreateTexture(nil, "OVERLAY")
	tab.checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	tab.checked:SetBlendMode("ADD")
	tab.checked:SetAllPoints()
	tab.checked:Hide()
	tab:SetScript("OnClick", ns.ToggleSpellbookWindow)
	tab:SetScript("OnEnter", function(self)
		ns.SetTooltipOwner(self)
		ns.AddSpellbookTooltipTitle(L["TAB_ENHANCED_SPELLBOOK"])
		GameTooltip:AddLine(L["SPELLBOOK_TAB_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		ns.AddSpellbookClickLine(L["MENU_OPEN_SPELLBOOK"], L["TOOLTIP_KEY_CLICK"])
		GameTooltip:Show()
	end)
	tab:SetScript("OnLeave", HideTooltip)
	tab:SetScript("OnHide", HideTooltip)
end

-- Not in combat, where hiding the protected book is blocked; it stays open behind the window.
function ns.CloseGameSpellbook()
	if book:IsShown() and not InCombatLockdown() then
		HideUIPanel(book)
	end
end

CreateTab()
ns.SyncSpellbookHost = Sync -- the master switch shows or hides the tab at once
ns.OnSpellbookWindowToggled(SyncTab)
book:HookScript("OnShow", Sync)
book:HookScript("OnHide", Sync)
-- The book's own update runs on every page or book-type change and whenever the skill line tabs change.
if book.Update then
	hooksecurefunc(book, "Update", Sync)
end
