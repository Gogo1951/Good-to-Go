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
    The page is named by the tooltip block's own title, so the two can't name it
    two ways. The switch sits on ns.db.global itself, not the Restocker's settings.
]]

local function ReportOff()
	return not ns.db.global.inventoryReport
end

--[[
    This realm's only, as the tooltip reads: the saved table is account-wide, so
    it also holds other realms' characters and ones from a copied WTF folder.
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

-- A tooltip puts the counts at its right edge, which a panel line can't, so each row is two cells.
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

function ns.BuildInventoryReportOptions()
	local options = {
		type = "group",
		name = L["INVENTORY_REPORT_TITLE"],
		args = {
			descInventory = Desc(GetColor("BODY") .. L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] .. "|r", 1),
			spaceInventory = Spacer(2),
			toggleInventoryReport = Kit.FeatureSwitch("inventoryReport", 3),
		},
	}
	AddExample(options.args, 4)
	AddRecordedCharacters(options.args, 10)
	return options
end
