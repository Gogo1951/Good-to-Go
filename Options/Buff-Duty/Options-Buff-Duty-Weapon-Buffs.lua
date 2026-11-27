local _, ns = ...
local Data = ns.Data
local L = ns.L
local Kit = ns.OptionsKit

-- Everything is listed whatever is in your bags, since these settings are account-wide.

-- The two hand columns share the control column, so they sit where a dropdown would.
local COLUMN_WIDTH = Kit.CONTROL_WIDTH / 2

-- An item not cached yet shows its placeholder and is warmed, so the panel repaints once it loads.
local function WeaponChoiceName(entry)
	local id = entry.ids[1]
	if entry.items then
		local name = C_Item.GetItemInfo(id)
		if name then
			return name
		end
		Kit.WarmItems({ id }, ns.OPTIONS_REGISTRY.BuffDutyWeaponBuffs)
		return L["LOADING_ITEM"]:format(id)
	end
	return C_Spell.GetSpellName(id) or L["TRACKED_SPELL_PENDING"]:format(id)
end

local function WeaponChoiceIcon(entry)
	if entry.items then
		return C_Item.GetItemIconByID(entry.ids[1])
	end
	return C_Spell.GetSpellTexture(entry.ids[1])
end

-- `handKey(hand)` names the hand's table in `list()`.
local function DefineGrid(args, choices, hands, list, handKey)
	local has = {}
	for _, hand in ipairs(hands) do
		has[hand] = true
	end

	local captions = { Kit.Label("", nil, Kit.LABEL_WIDTH) }
	for _, hand in ipairs(Data.WEAPON_HAND_ORDER) do
		if has[hand] then
			captions[#captions + 1] = Kit.Label(ns.WEAPON_HAND_LABELS[hand], nil, COLUMN_WIDTH)
		end
	end
	args.columns = Kit.Row(1, nil, captions)

	for index, entry in ipairs(choices) do
		local link = entry.items and ("item:" .. entry.items[1].id) or ns.SpellTooltipLink(entry.ids)
		local cells = {
			ns.OptionsAbilityLabel(function()
				local icon = WeaponChoiceIcon(entry)
				local name = WeaponChoiceName(entry)
				return icon and ("|T" .. icon .. ":16|t " .. name) or name
			end, nil, Kit.LABEL_WIDTH, link),
		}

		for _, hand in ipairs(Data.WEAPON_HAND_ORDER) do
			if has[hand] then
				local handName = ns.WEAPON_HAND_LABELS[hand]
				cells[#cells + 1] = {
					type = "toggle",
					name = "",
					desc = function()
						return L["BUFF_DUTY_WEAPON_PICK_DESCRIPTION"]:format(WeaponChoiceName(entry), handName)
					end,
					width = COLUMN_WIDTH,
					get = function()
						return ns.BuffDuty.WeaponChoiceOn(list(), handKey(hand), entry.key)
					end,
					set = function(_, value)
						local settings = list()
						local key = handKey(hand)
						settings[key] = settings[key] or {}
						settings[key][entry.key] = value
						ns.RefreshBuffDuty()
					end,
				}
			end
		end
		args["choice_" .. entry.key] = Kit.Row(10 + index, nil, cells)
	end
end

-- A group with no title, which AceConfig draws with no box.
local function AddSection(args, key, title, order)
	args[key .. "Header"] = Kit.Header(title, order - 0.3)
	args[key .. "Space"] = Kit.Spacer(order - 0.2)
	args[key] = { type = "group", name = "", order = order, inline = true, args = {} }
	args[key .. "After"] = Kit.Spacer(order + 0.5)
	return args[key].args
end

function ns.BuildBuffDutyWeaponBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = Kit.SubPanelTitle(L["TAB_BUFF_DUTY"], L["BUFF_DUTY_WEAPON_PANEL_HEADER"]),
		type = "group",
		args = {
			descIntro = Kit.Desc(L["BUFF_DUTY_WEAPON_DESCRIPTION"], 1),
			spaceIntro = Kit.Spacer(2),
		},
	}
	ns.AddBuffDutyRowControls(options.args, "weapons", 3)

	local function Picks()
		return Settings().weaponPicks
	end
	local function Items()
		return Settings().weaponItems
	end

	-- Rogues and shamans first, each class's choices sorted by name.
	local byClass, classes = {}, {}
	for _, entry in ipairs(ns.BuffDuty.weaponEntries) do
		local class = entry.row.class
		if not byClass[class] then
			byClass[class] = {}
			classes[#classes + 1] = class
		end
		table.insert(byClass[class], entry)
	end
	table.sort(classes)

	local boxOrder = 10
	for _, class in ipairs(classes) do
		local choices = byClass[class]
		table.sort(choices, function(a, b)
			return WeaponChoiceName(a) < WeaponChoiceName(b)
		end)
		local rows = AddSection(options.args, "class_" .. class, LOCALIZED_CLASS_NAMES_MALE[class] or class, boxOrder)
		DefineGrid(rows, choices, ns.BUFF_DUTY_WEAPON_HANDS[class] or {}, Picks, function(hand)
			return class .. "_" .. hand
		end)
		boxOrder = boxOrder + 1
	end

	-- Then Oils, Stones and Lures, each strongest first by item level, then by name.
	local byKind = {}
	for _, entry in ipairs(ns.BuffDuty.weaponItemEntries) do
		byKind[entry.kind] = byKind[entry.kind] or {}
		table.insert(byKind[entry.kind], entry)
	end
	for _, kind in ipairs(Data.WEAPON_ITEM_KINDS) do
		if byKind[kind] then
			table.sort(byKind[kind], function(a, b)
				if a.itemLevel ~= b.itemLevel then
					return a.itemLevel > b.itemLevel
				end
				return WeaponChoiceName(a) < WeaponChoiceName(b)
			end)
			local rows = AddSection(options.args, "kind_" .. kind, L["BUFF_DUTY_WEAPON_KIND_" .. kind], boxOrder)
			local hands = Data.WEAPON_ITEM_KIND_HANDS[kind] or Data.WEAPON_HAND_ORDER
			DefineGrid(rows, byKind[kind], hands, Items, function(hand)
				return hand
			end)
			boxOrder = boxOrder + 1
		end
	end

	ns.AddFeatureOffLine(options.args, "buffWindow.enabled", {
		isOn = function()
			return Settings().weaponEnabled
		end,
		name = "BUFF_DUTY_WEAPON_ENABLE",
		page = "TAB_BUFF_DUTY",
	})
	return options
end
