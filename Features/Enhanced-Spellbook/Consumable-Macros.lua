local _, ns = ...
local L = ns.L

--[[
	Consumable Macros writes and owns these WoW macros; the page only shows the ones that exist and picks them
	up, never creating, rewriting or tagging one.
]]

-- In the Consumable Macros panel's order, keyed by ns.MACRO_CONFIG's type.
local TYPES = {
	"Bandage",
	"Explosive",
	"Feed Pet",
	"Fishing Lure",
	"Food",
	"Health Potion",
	"Healthstone",
	"Mana Gem",
	"Mana Potion",
	"Poisons",
	"Soulstone",
	"Water",
}

-- For these classes the macro also casts a ranked spell, so the note reads Dynamic Rank too.
local SPELL_CLASSES = {
	["Feed Pet"] = "HUNTER",
	["Food"] = "MAGE",
	["Healthstone"] = "WARLOCK",
	["Mana Gem"] = "MAGE",
	["Soulstone"] = "WARLOCK",
	["Water"] = "MAGE",
}

-- The type's default item's icon while the bags hold nothing it can use.
function ns.ReadConsumableMacro(macro)
	local index = GetMacroIndexByName(macro.wowName)
	local body = index > 0 and GetMacroBody(index) or nil
	local itemName, itemLink
	if index > 0 then
		itemName, itemLink = GetMacroItem(index)
	end
	local defaultItem = ns.MACRO_DEFAULT_ITEM_IDS[macro.type]
	macro.body = body or ""
	macro.itemName, macro.itemLink = itemName, itemLink
	macro.icon = (itemLink and C_Item.GetItemIconByID(itemLink))
		or (defaultItem and C_Item.GetItemIconByID(defaultItem))
		or ns.QUESTION_MARK_ICON
end

-- wowName is Consumable Macros' own ("- Food"), in place of the page's prefix.
function ns.ConsumablePageMacros()
	local macros = {}
	local playerClass = select(2, UnitClass("player"))
	for position, macroType in ipairs(TYPES) do
		local config = ns.MACRO_CONFIG[macroType]
		if config and GetMacroIndexByName(config.macro) > 0 then
			local macro = {
				consumable = true,
				type = macroType,
				name = (config.macro:gsub("^%- ", "")),
				wowName = config.macro,
				macroName = config.macro,
				category = L["SECTION_CONSUMABLES"],
				priority = position,
				dynamicRank = SPELL_CLASSES[macroType] == playerClass,
			}
			ns.ReadConsumableMacro(macro)
			macros[#macros + 1] = macro
		end
	end
	return macros
end
