local ADDON_NAME, ns = ...
local L = ns.L

local Kit = ns.MenuKit
local CR = ns.CurrencyReplenish
local GoldMath = ns.GoldMath

-- Whole gold. Other Amount types any other.
local KEEPS_CHOICES = { 1, 5, 10, 25, 50, 100, 500, 1000 }
local MAX_KEEPS_LETTERS = 7

CR.KEEPS_POPUP = "GOODTOGO_CURRENCY_REPLENISH_KEEPS"

function CR.Gold(gold)
	return CR.Money(gold * GoldMath.COPPER_PER_GOLD)
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

-- At line height a texture is square, so this blank takes the check's room whatever the font.
local CHECK_ROOM = "|TInterface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Blank:0|t"

function CR.BankEntries()
	local entries = {}
	local bankKey = CR.BankKey()
	for _, item in ipairs(CR.Roster()) do
		local key = item.key
		entries[#entries + 1] = {
			kind = "choice",
			left = ns.ClassColoredName(item.record.name or "?", item.record.class),
			selected = key == bankKey,
			closes = true,
			onClick = function()
				CR.SetBank(key)
			end,
		}
	end
	return entries
end

local function AskOtherAmount(key)
	local record = CR.Settings().characters[key]
	if record then
		StaticPopup_Show(CR.KEEPS_POPUP, ns.ClassColoredName(record.name, record.class), nil, key)
	end
end

--[[
    Each row's words sit on the menu's right, so the kit lines up their right
    edges. A typed Other Amount shows as its own checked row, in its place.
]]
function CR.KeepsEntries()
	local key = CR.keepsFor
	local record = key and CR.Settings().characters[key]
	if not record then
		return {}
	end
	local keeps = record.keeps
	local function Row(text, picked, color, onClick)
		return {
			kind = "value",
			-- Every row has something on its left, the check or the same room, so no one row is laid out unlike the rest.
			left = picked and Kit.CHECK_MARK or CHECK_ROOM,
			right = text,
			rightColor = color or (picked and "VALUE" or "BODY"),
			closes = true,
			onClick = onClick,
		}
	end
	local function Pick(gold)
		return function()
			CR.SetKeeps(key, gold)
		end
	end
	local amounts = {}
	local listed = keeps == nil
	for _, gold in ipairs(KEEPS_CHOICES) do
		amounts[#amounts + 1] = gold
		listed = listed or keeps == gold
	end
	if not listed then
		amounts[#amounts + 1] = keeps
	end
	table.sort(amounts, function(a, b)
		return a > b
	end)
	local entries = {}
	for _, gold in ipairs(amounts) do
		entries[#entries + 1] = Row(CR.Gold(gold), keeps == gold, nil, Pick(gold))
	end
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = Row(L["CURRENCY_REPLENISH_OTHER_AMOUNT"], false, nil, function()
		AskOtherAmount(key)
	end)
	entries[#entries + 1] = Row(L["MENU_OFF"], keeps == nil, "MUTED", Pick(nil))
	-- Not on the character being played: it would be recorded again the next time its gold changed.
	if key ~= CR.OwnKey() then
		entries[#entries + 1] = { kind = "separator" }
		entries[#entries + 1] = {
			kind = "action",
			left = L["CURRENCY_REPLENISH_REMOVE_CHARACTER"],
			leftColor = "OFF",
			closes = true,
			onClick = function()
				CR.RemoveCharacter(key)
			end,
		}
	end
	return entries
end

function CR.OptionsEntries()
	local settings = CR.Settings()
	local entries = {
		{
			kind = "toggle",
			left = L["CURRENCY_REPLENISH_SKIP_SMALL"],
			on = settings.skipSmall,
			onClick = function()
				settings.skipSmall = not settings.skipSmall
			end,
		},
	}
	entries[#entries + 1] = { kind = "spacer" }
	entries[#entries + 1] = { kind = "separator" }
	entries[#entries + 1] = {
		kind = "action",
		left = L["CURRENCY_REPLENISH_ALL_SETTINGS"],
		closes = true,
		onClick = function()
			ns:OpenOptionsPanel("CurrencyReplenish")
		end,
	}
	return entries
end

--------------------------------------------------------------------------------
-- Other Amount
--------------------------------------------------------------------------------

local function PopupEditBox(popup)
	return popup.GetEditBox and popup:GetEditBox() or popup.editBox or popup.EditBox
end

local function AcceptOtherAmount(popup, key)
	local box = PopupEditBox(popup)
	local gold = box and tonumber(box:GetText())
	gold = gold and math.floor(gold) or nil
	CR.SetKeeps(key, (gold and gold > 0) and gold or nil)
end

StaticPopupDialogs[CR.KEEPS_POPUP] = {
	text = L["CURRENCY_REPLENISH_KEEPS_FOR"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = MAX_KEEPS_LETTERS,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(self, key)
		local box = PopupEditBox(self)
		local record = CR.Settings().characters[key]
		if box then
			box:SetNumeric(true)
			box:SetText(record and record.keeps and tostring(record.keeps) or "")
			box:HighlightText()
			box:SetFocus()
		end
	end,
	OnAccept = function(self, key)
		AcceptOtherAmount(self, key)
	end,
	EditBoxOnEnterPressed = function(box)
		local popup = box:GetParent()
		AcceptOtherAmount(popup, popup.data)
		popup:Hide()
	end,
	EditBoxOnEscapePressed = function(box)
		box:GetParent():Hide()
	end,
}
