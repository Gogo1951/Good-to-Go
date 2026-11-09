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
    Recorded Characters: one row per other character on this realm the
    Inventory Report holds, A to Z, the name in its class color (no realm:
    every row is on this one), with a remove icon that asks before it forgets them
    (ns.ForgetRecordedCharacter). Only this realm's, the same characters the
    tooltip reads (Inventory-Report-Tooltip.lua): the saved table is
    account-wide, so it also holds characters from the client's other realms
    and from a WTF folder copied in from another game version, none of whom
    the tooltip can show here. Added to args only while there is one, so
    the section isn't there at all otherwise; the panel is built afresh each
    time it draws.
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
					name = color .. record.name .. "|r",
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
