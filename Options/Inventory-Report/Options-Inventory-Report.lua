local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Header = Kit.Header
local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Inventory Report Panel
--------------------------------------------------------------------------------

--[[
    The counts Features/Inventory-Report/Inventory-Report-Tooltip.lua adds to
    item tooltips, on a page of its own in the tree. Its name is the
    tooltip block's own title (INVENTORY_REPORT_TITLE), so the panel and the
    tooltip cannot name it two ways.

    The switch is read at every tooltip, so switching it takes effect on the
    next one without a reload. Not a Restocker settings key: it sits on
    ns.db.global itself (Data/Default-Settings.lua).
]]

-- Whatever the report's switch turns off leaves the page with it.
local function ReportOff()
	return not ns.db.global.inventoryReport
end

--[[
    Recorded Characters: one row per other character on this realm the
    Inventory Report holds, A to Z, the name in its class color (no realm:
    every row is on this one), with a remove icon that asks before it forgets them
    (ns.ForgetRecordedCharacter). Only this realm's, the same characters the
    tooltip reads (Inventory-Report-Tooltip.lua): the saved table is
    account-wide, so it also holds characters from the client's other realms
    and from a WTF folder copied in from another game version, none of whom
    the tooltip can show here. Added to args only while there is one, so
    the section isn't there at all otherwise, and hidden while the report is
    off; the panel is built afresh each time it draws.
]]
local function AddRecordedCharacters(args, order)
	local ownKey = ns.GetCharacterKey()
	local realm = GetRealmName()
	local keys = {}
	for key, record in pairs(ns.db.global.inventory) do
		if key ~= ownKey and type(record) == "table" and record.name and record.realm == realm then
			keys[#keys + 1] = key
		end
	end
	if #keys == 0 then
		return
	end
	local inventory = ns.db.global.inventory
	-- A to Z whatever the case, as the tooltip lists them; the key only settles two characters that share a name.
	table.sort(keys, function(a, b)
		local nameA, nameB = inventory[a].name:lower(), inventory[b].name:lower()
		if nameA ~= nameB then
			return nameA < nameB
		end
		return a < b
	end)

	args.spaceRecorded0 = Spacer(order, ReportOff)
	args.headerRecorded = Header(L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"], order + 0.1, ReportOff)
	args.spaceRecorded1 = Spacer(order + 0.2, ReportOff)
	for index, key in ipairs(keys) do
		local record = inventory[key]
		local color = ns.GetClassColor(record.class) or GetColor("TEXT")
		-- The remove icon is the item lists' own; every panel repaints after, so the row goes without a reopen.
		args["recorded_" .. index] = Kit.Row(order + 0.3 + index / 1000, ReportOff, {
			{
				type = "description",
				name = color .. record.name .. "|r",
				fontSize = "medium",
				width = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_REMOVE_ICON_WIDTH,
			},
			{
				type = "execute",
				name = "",
				desc = L["INVENTORY_REPORT_FORGET_CHARACTER"],
				image = "Interface/Buttons/UI-GroupLoot-Pass-Up",
				imageWidth = 16,
				imageHeight = 16,
				width = ns.OPTIONS_REMOVE_ICON_WIDTH,
				confirm = true,
				confirmText = L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"]:format(color .. record.name .. "|r"),
				func = function()
					ns.ForgetRecordedCharacter(key)
					ns.RefreshSettings()
				end,
			},
		})
	end
end

--[[
    The Example: the block an item's tooltip gets, under the item's name as
    the tooltip leads with it, for a consumable in the bags
    (ns.GetInventoryReportExampleItem; a Hearthstone without one). Drawn
    through the tooltip's own builder, so it reads the same. A tooltip puts
    the counts at its right edge, which a panel line cannot, so each row is a
    name cell and a counts cell. Built with the page, which is built afresh
    each time it draws, so it follows the bags; shown only while the report is
    on.
]]
local function AddExample(args, order)
	if ReportOff() then
		return
	end
	local itemID = ns.GetInventoryReportExampleItem()
	local lines = ns.GetInventoryReportLines(itemID, true)
	if not lines then
		return
	end
	if not C_Item.IsItemDataCachedByID(itemID) then
		ns.WarmItemCache({ itemID }, "InventoryReportExample", ns.RefreshSettings)
	end

	-- Kit.Example supplies the spacer and the label; its one-string body gives way to the two-cell rows.
	local example = Kit.Example(order, ReportOff, function()
		return ""
	end)
	example.args.lines = nil
	local leftWidth = Kit.PAIR_WIDTH - Kit.SUB_INDENT_WIDTH
	local function Cell(text, width)
		return { type = "description", name = text, fontSize = "medium", width = width }
	end

	example.args.item = Kit.SubRow(3, nil, { Cell(ns.GetItemLabel(itemID), Kit.ROW_WIDTH - Kit.SUB_INDENT_WIDTH) })
	for index, line in ipairs(lines) do
		local cells = line[2] and { Cell(line[1], leftWidth), Cell(line[2], Kit.PAIR_WIDTH) }
			or { Cell(line[1], Kit.ROW_WIDTH - Kit.SUB_INDENT_WIDTH) }
		example.args["line" .. index] = Kit.SubRow(3 + index / 100, nil, cells)
	end
	args.exampleInventory = example
end

--[[
    The line under the switch: how many characters on this realm the report
    holds, this one among them, while it is on; nothing while it is off.
]]
local function StatusText()
	if ReportOff() then
		return nil
	end
	local realm, count = GetRealmName(), 0
	for _, record in pairs(ns.db.global.inventory) do
		if type(record) == "table" and record.name and record.realm == realm then
			count = count + 1
		end
	end
	if count == 1 then
		return L["INVENTORY_REPORT_STATUS_ONE"]
	end
	return L["INVENTORY_REPORT_STATUS"]:format(count)
end

-- Page order: the description, the switch and its status, its Example, then the characters the report has recorded.
function ns.BuildInventoryReportOptions()
	local options = {
		type = "group",
		name = L["INVENTORY_REPORT_TITLE"],
		args = {
			descInventory = Desc(GetColor("BODY") .. L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] .. "|r", 1),
			spaceInventory = Spacer(2),
			toggleInventoryReport = Kit.FeatureSwitch("inventoryReport", 3),
			statusInventoryReport = Kit.StatusLine(StatusText, 3.5),
		},
	}
	AddExample(options.args, 4)
	AddRecordedCharacters(options.args, 10)
	return options
end
