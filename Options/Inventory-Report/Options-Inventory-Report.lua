local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

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

-- Repaint the panel so a forgotten character's row goes without a reopen.
local function Refresh()
	LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.InventoryReport)
end

--[[
    Recorded Characters: one row per other character the Inventory Report
    holds, A to Z, the name in its class color and then its realm, with a
    remove icon that asks before it forgets them
    (ns.ForgetRecordedCharacter). Added to args only while there is one, so
    the section isn't there at all otherwise; the panel is built afresh each
    time it draws.
]]
local function AddRecordedCharacters(args, order)
	local ownKey = ns.GetCharacterKey()
	local keys = {}
	for key, record in pairs(ns.db.global.inventory) do
		if key ~= ownKey and type(record) == "table" and record.name then
			keys[#keys + 1] = key
		end
	end
	if #keys == 0 then
		return
	end
	local inventory = ns.db.global.inventory
	table.sort(keys, function(a, b)
		local nameA, nameB = inventory[a].name, inventory[b].name
		if nameA ~= nameB then
			return nameA < nameB
		end
		return a < b
	end)

	args.spaceRecorded0 = Spacer(order)
	args.headerRecorded = Header(L["INVENTORY_REPORT_RECORDED_CHARACTERS_HEADER"], order + 0.1)
	args.spaceRecorded1 = Spacer(order + 0.2)
	for index, key in ipairs(keys) do
		local record = inventory[key]
		local color = ns.GetClassColor(record.class) or GetColor("TEXT")
		args["recorded_" .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = order + 0.3 + index / 1000,
			args = {
				name = {
					type = "description",
					name = color .. record.name .. "|r " .. GetColor("HELP") .. (record.realm or "") .. "|r",
					fontSize = "medium",
					width = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_REMOVE_ICON_WIDTH,
					order = 1,
				},
				forget = ns.OptionsRemoveIcon(L["INVENTORY_REPORT_FORGET_CHARACTER"], 2, function()
					ns.ForgetRecordedCharacter(key)
					Refresh()
				end, L["INVENTORY_REPORT_FORGET_CHARACTER_CONFIRM"]:format(color .. record.name .. "|r")),
			},
		}
	end
end

-- Page order: the description, the switch, then the characters the report has recorded.
function ns.BuildInventoryReportOptions()
	local options = {
		type = "group",
		name = L["INVENTORY_REPORT_TITLE"],
		args = {
			descInventory = Desc(GetColor("BODY") .. L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] .. "|r", 1),
			spaceInventory = Spacer(2),
			toggleInventoryReport = ns.OptionsFeatureSwitch("InventoryReport", 3),
		},
	}
	AddRecordedCharacters(options.args, 10)
	return options
end
