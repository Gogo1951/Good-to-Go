local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Lines appear in hook order and this block belongs under other add-ons', so
    it hooks after they have. Cost: an item hovered in the first seconds shows
    no report. An add-on loaded on demand later still lands below.
]]
local TOOLTIP_HOOK_DELAY = 5

-- Matches the other add-ons' tooltip blocks.
local ROW_INDENT = " "

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

-- Unpacked once per login: they are logged out, so nothing this session changes them.
local others, othersRecord

function ns.ResetInventoryReportOthers()
	others, othersRecord = nil, nil
end

local function OtherCharacters()
	local record = ns.GetInventoryRecord()
	if others and othersRecord == record then
		return others
	end

	others, othersRecord = {}, record
	local realm = GetRealmName()
	for key, entry in pairs(ns.db.global.inventory) do
		if entry ~= record and entry.realm == realm and entry.name then
			others[#others + 1] = {
				key = key,
				name = entry.name,
				class = entry.class,
				bags = ns.UnpackInventoryCounts(entry.bags),
				bank = entry.bank and ns.UnpackInventoryCounts(entry.bank) or nil,
			}
		end
	end

	table.sort(others, function(a, b)
		local left, right = a.name:lower(), b.name:lower()
		if left ~= right then
			return left < right
		end
		return a.key < b.key
	end)
	return others
end

local function KeepAmount(itemID)
	local settings = ns.restockSettings
	local list = settings and settings.lists and settings.lists[settings.currentList]
	local row = list and list[itemID]
	if type(row) == "table" and (row.amount or 0) > 0 then
		return row.amount
	end
end

local TEXT_COLOR = GetColor("TEXT")

local REPORT_HEADER = {
	GetColor("TITLE") .. L["INVENTORY_REPORT_TITLE"] .. "|r",
	GetColor("MUTED") .. L["ADDON_SHORT_NAME"] .. "|r",
}

-- Words gray, numbers white; the gray resumes after each number for the words behind it.
local LABEL_COLOR = GetColor("MUTED")

local function Count(value)
	return TEXT_COLOR .. value .. "|r" .. LABEL_COLOR
end

-- Nil when both are 0.
local function Counts(bags, bank)
	if bags > 0 and bank > 0 then
		return format(L["INVENTORY_REPORT_COUNTS"], Count(bags), Count(bank))
	elseif bags > 0 then
		return format(L["INVENTORY_REPORT_BAG"], Count(bags))
	elseif bank > 0 then
		return format(L["INVENTORY_REPORT_BANK"], Count(bank))
	end
end

local function CharacterRow(name, class, bags, bank)
	local counts = Counts(bags, bank)
	return {
		ROW_INDENT .. (ns.GetClassColor(class) or TEXT_COLOR) .. name .. "|r",
		counts and (LABEL_COLOR .. counts .. "|r"),
	}
end

--[[
    Lines of { left, right }. An item on the Restock List always reports, so a
    list item nobody holds says so. `always` is the panel's Example, which must
    draw something.
]]
function ns.GetInventoryReportLines(itemID, always)
	local record = ns.GetInventoryRecord()
	if not (record and ns.db and ns.db.global.inventoryReport) then
		return nil
	end

	local bankCounts = ns.GetInventoryBankCounts()
	local bags = C_Item.GetItemCount(itemID, false) or 0
	local bank = bankCounts and bankCounts[itemID] or 0
	local total = bags + bank

	local holders = {}
	for _, other in ipairs(OtherCharacters()) do
		local otherBags = other.bags[itemID] or 0
		local otherBank = other.bank and other.bank[itemID] or 0
		if otherBags + otherBank > 0 then
			holders[#holders + 1] = { character = other, bags = otherBags, bank = otherBank }
			total = total + otherBags + otherBank
		end
	end

	local keep = KeepAmount(itemID)
	if total == 0 and not keep and not always then
		return nil
	end

	local lines = { REPORT_HEADER }

	lines[#lines + 1] = CharacterRow(record.name, record.class, bags, bank)

	for _, holder in ipairs(holders) do
		lines[#lines + 1] = CharacterRow(holder.character.name, holder.character.class, holder.bags, holder.bank)
	end

	lines[#lines + 1] = {
		ROW_INDENT .. LABEL_COLOR .. L["INVENTORY_REPORT_TOTAL"] .. "|r",
		TEXT_COLOR .. total .. "|r",
	}

	return lines
end

--------------------------------------------------------------------------------
-- Example Item
--------------------------------------------------------------------------------

local CONSUMABLE_CLASS_ID = Enum.ItemClass and Enum.ItemClass.Consumable or 0

--[[
    The carried consumable the most characters hold, to show off the most rows;
    ties by count, then lowest id, so it holds still between draws.
]]
function ns.GetInventoryReportExampleItem()
	local carried = {}
	for _, bagID in ipairs(ns.CARRIED_BAG_IDS) do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemID = C_Container.GetContainerItemID(bagID, slot)
			if itemID and not carried[itemID] then
				local classID = select(6, C_Item.GetItemInfoInstant(itemID))
				if classID == CONSUMABLE_CLASS_ID then
					carried[itemID] = true
				end
			end
		end
	end

	local bestID, bestHolders, bestCount
	for itemID in pairs(carried) do
		local holders, count = 1, C_Item.GetItemCount(itemID, false) or 0
		for _, other in ipairs(OtherCharacters()) do
			local held = (other.bags[itemID] or 0) + (other.bank and other.bank[itemID] or 0)
			if held > 0 then
				holders, count = holders + 1, count + held
			end
		end
		local better = not bestID
			or holders > bestHolders
			or (holders == bestHolders and (count > bestCount or (count == bestCount and itemID < bestID)))
		if better then
			bestID, bestHolders, bestCount = itemID, holders, count
		end
	end
	return bestID or ns.HEARTHSTONE_ITEM_ID
end

--------------------------------------------------------------------------------
-- Tooltip Hooks
--------------------------------------------------------------------------------

-- Era can fire OnTooltipSetItem twice for one tooltip (a recipe and what it makes); this stops a second block.
local reported = setmetatable({}, { __mode = "k" })

local function AddReport(tooltip, itemID)
	if not itemID or reported[tooltip] or ns.IsSecretValue(itemID) then
		return
	end
	if tooltip.IsForbidden and tooltip:IsForbidden() then
		return
	end

	local lines = ns.GetInventoryReportLines(itemID)
	if not lines then
		return
	end

	reported[tooltip] = true
	tooltip:AddLine(" ")
	for _, line in ipairs(lines) do
		if line[2] then
			tooltip:AddDoubleLine(line[1], line[2], 1, 1, 1, 1, 1, 1)
		else
			tooltip:AddLine(line[1], 1, 1, 1)
		end
	end
end

local function OnTooltipCleared(tooltip)
	reported[tooltip] = nil
end

-- A hook cannot be removed, so it is installed once however often login runs.
local tooltipsHooked = false

-- Not the comparison tooltips: they would only repeat the block.
local function HookTooltips()
	if tooltipsHooked then
		return
	end
	tooltipsHooked = true

	local tooltips = { GameTooltip, ItemRefTooltip }
	for _, tooltip in ipairs(tooltips) do
		tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
	end

	ns.AddItemTooltipPostCall(tooltips, AddReport)
end

function ns.HookInventoryReportTooltipsLater()
	C_Timer.After(TOOLTIP_HOOK_DELAY, HookTooltips)
end
