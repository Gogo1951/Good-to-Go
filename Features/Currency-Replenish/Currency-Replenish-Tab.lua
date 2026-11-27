local ADDON_NAME, ns = ...
local L = ns.L

local Kit = ns.MenuKit
local CR = ns.CurrencyReplenish

--[[
    Parented to UIParent and anchored beside the mail window, never parented
    to it and never writing to it: a frame parented to a Blizzard panel
    stays protected for good, and anything written to the panel taints it.
]]

CR.TAB_SIZE = 40
CR.TAB_TOP = 96 -- down from the mail window's top: Play It Forward's gift tab is at 48
local ICON_SIZE = 32
local EDGE_SIZE = 16
local INSET = 4
-- The border at rest: the title gold, dimmed, so the lit tab stands out against it.
local REST_DIM = 0.55
local TITLE_RGB = { 1, 0.82, 0 }

local COINS_TEXTURE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Currency-Replenish"
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

local tab, menu

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

local function MenuEntries()
	local entries = {
		{ kind = "header", left = L["CURRENCY_REPLENISH"], right = L["ADDON_SHORT_NAME"] },
		Kit.Spacer(),
		{
			kind = "action",
			left = L["CURRENCY_REPLENISH_OPEN"],
			closes = true,
			onClick = function()
				CR.OpenWindow()
			end,
		},
	}
	Kit.OptionsRow(entries, L["MENU_OPTIONS"])
	return entries
end

local function ShowMenu()
	if not menu then
		menu = Kit.CreateMenu({ name = "GoodToGoCurrencyReplenishTabMenu", publish = false, build = MenuEntries })
	end
	menu:Show(tab, "hover")
end

--------------------------------------------------------------------------------
-- Tab
--------------------------------------------------------------------------------

local function OnTabClick()
	if menu then
		menu:Hide()
	end
	CR.ToggleWindow()
	-- A check button flips itself on every click; this puts it back to what the window says.
	CR.SyncTab()
end

local function Build()
	tab = CreateFrame("CheckButton", "GoodToGoCurrencyReplenishTab", UIParent, BACKDROP_TEMPLATE)
	tab:SetSize(CR.TAB_SIZE, CR.TAB_SIZE)
	if tab.SetBackdrop then
		tab:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = EDGE_SIZE,
			insets = { left = INSET, right = INSET, top = INSET, bottom = INSET },
		})
		tab:SetBackdropColor(0, 0, 0, 0.9)
	end

	local icon = tab:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("CENTER")
	icon:SetTexture(COINS_TEXTURE)

	local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(icon)
	highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	highlight:SetBlendMode("ADD")
	local checked = tab:CreateTexture(nil, "OVERLAY")
	checked:SetAllPoints(icon)
	checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	checked:SetBlendMode("ADD")
	tab:SetCheckedTexture(checked)

	tab:RegisterForClicks("LeftButtonUp")
	tab:SetScript("OnClick", OnTabClick)
	tab:SetScript("OnEnter", ShowMenu)
	tab:Hide()
end

local function Light(lit)
	tab:SetChecked(lit)
	if tab.SetBackdropBorderColor then
		local dim = lit and 1 or REST_DIM
		tab:SetBackdropBorderColor(TITLE_RGB[1] * dim, TITLE_RGB[2] * dim, TITLE_RGB[3] * dim, 1)
	end
end

--------------------------------------------------------------------------------
-- Which Mailbox Window
--------------------------------------------------------------------------------

--[[
    TSM's mail window has no name and its API says only whether it is up, so
    the tab finds it by the file that made it, as Play It Forward does. Without
    GetSourceLocation it finds nothing and the tab stays off TSM's window.
]]
local TSM_SOURCE = "TradeSkillMaster"

local tsmFrame
local hooked = setmetatable({}, { __mode = "k" })

local function TSMMailUp()
	if not (TSM_API and TSM_API.IsUIVisible) then
		return false
	end
	local ok, visible = pcall(TSM_API.IsUIVisible, "MAILING")
	return ok and visible == true
end

local function MadeByTSM(frame)
	if not frame.GetSourceLocation then
		return false
	end
	local ok, source = pcall(frame.GetSourceLocation, frame)
	return ok and type(source) == "string" and source:find(TSM_SOURCE, 1, true) ~= nil
end

local function FindTSMFrame()
	if tsmFrame and tsmFrame:IsShown() then
		return tsmFrame
	end
	tsmFrame = nil
	local best, bestArea = nil, 0
	for _, child in ipairs({ UIParent:GetChildren() }) do
		-- IsForbidden first: any other call on a frame the game locks away is an error.
		if not child:IsForbidden() and MadeByTSM(child) and child:IsShown() then
			local area = (child:GetWidth() or 0) * (child:GetHeight() or 0)
			if best == nil or area > bestArea then
				best, bestArea = child, area
			end
		end
	end
	if best and not hooked[best] then
		hooked[best] = true
		best:HookScript("OnShow", function()
			CR.SyncTab()
		end)
		best:HookScript("OnHide", function()
			CR.SyncTab()
		end)
	end
	tsmFrame = best
	return best
end

function CR.TabHost()
	if not (CR.IsEnabled() and CR.AtMailbox()) then
		return nil
	end
	if MailFrame and MailFrame:IsShown() then
		return MailFrame
	end
	if TSMMailUp() then
		return FindTSMFrame()
	end
	return nil
end

local anchoredTo

function CR.SyncTab()
	local host = CR.TabHost()
	if not tab then
		if not host then
			return
		end
		Build()
	end
	if host then
		if anchoredTo ~= host then
			tab:ClearAllPoints()
			tab:SetPoint("TOPLEFT", host, "TOPRIGHT", 0, -CR.TAB_TOP)
			anchoredTo = host
		end
		tab:Show()
		Light(CR.WindowShown())
	else
		tab:Hide()
		if menu then
			menu:Hide()
		end
	end
end

-- A mail add-on can put its window up a frame or two after the mailbox opens, so the tab asks again.
local SETTLE = 0.5

local function SyncTabSoon()
	CR.SyncTab()
	C_Timer.After(0, CR.SyncTab)
	C_Timer.After(SETTLE, CR.SyncTab)
end

CR.On("MAIL_SHOW", SyncTabSoon)

-- Next frame, so the mailbox has finished closing when it's asked.
CR.On("MAIL_CLOSED", function()
	C_Timer.After(0, function()
		if not CR.AtMailbox() then
			CR.CloseWindow()
		end
		CR.SyncTab()
	end)
end)

CR.On("PLAYER_LOGIN", function()
	-- MAIL_CLOSED doesn't fire on every way out of the mailbox; the mail window hiding is the other.
	if MailFrame then
		MailFrame:HookScript("OnShow", SyncTabSoon)
		MailFrame:HookScript("OnHide", function()
			C_Timer.After(0, function()
				if not CR.AtMailbox() then
					CR.CloseWindow()
				end
				CR.SyncTab()
			end)
		end)
	end
end)
