local _, ns = ...
local Data = ns.Data
local L = ns.L

local BuffDuty = ns.BuffDuty
local weaponBuffs = BuffDuty.weaponBuffs
local weaponByEnchant = BuffDuty.weaponByEnchant
local weaponEntries = BuffDuty.weaponEntries
local weaponItemEntries = BuffDuty.weaponItemEntries
local KnownRanks = BuffDuty.KnownRanks

local IMBUE, TEMPORARY = Data.WEAPON_LAYERS.IMBUE, Data.WEAPON_LAYERS.TEMPORARY
local MAIN_SLOT, OFF_SLOT = Data.WEAPON_HAND_SLOTS.MAIN, Data.WEAPON_HAND_SLOTS.OFF

ns.WEAPON_HAND_LABELS = { MAIN = INVTYPE_WEAPONMAINHAND, OFF = INVTYPE_WEAPONOFFHAND }

local GetItemCount = C_Item.GetItemCount

--------------------------------------------------------------------------------
-- Weapons
--------------------------------------------------------------------------------

local WEAPON_CLASS = Enum.ItemClass and Enum.ItemClass.Weapon or 2
local FISHING_POLE = Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole or 20

-- Nil for an off hand holding a shield or a book: it has nothing to ask for.
local function WeaponSubclass(slot)
	local itemID = GetInventoryItemID("player", slot)
	if not ns.IsPlain(itemID) or not itemID then
		return nil
	end
	local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
	return classID == WEAPON_CLASS and subclassID or nil
end

local function HoldsWeapon(slot)
	local subclass = WeaponSubclass(slot)
	return subclass ~= nil and subclass ~= FISHING_POLE
end

-- A pick naming no subclass mask takes any weapon but a fishing pole.
local function PickFits(pick, subclass)
	if not pick.types or pick.types == 0 then
		return subclass ~= FISHING_POLE
	end
	return bit.band(pick.types, bit.lshift(1, subclass)) ~= 0
end

-- An enchant no row names goes by the client's own word for it.
local function WornLayer(enchant, enchantType)
	if not ns.WEAPON_ENCHANTS_STACK then
		return TEMPORARY
	end
	local entry = enchant and weaponByEnchant[enchant]
	if entry then
		return entry.layer
	end
	local types = Enum.ItemEnchantType
	return (types and enchantType == types.Imbue) and IMBUE or TEMPORARY
end

--[[
    Slot -> list of { seconds left, enchant id (nil where the client names
    none), layer }. The Readiness Report and Diagnostics read this shape too.
]]
function BuffDuty.ReadWeaponEnchants()
	local worn = { [MAIN_SLOT] = {}, [OFF_SLOT] = {} }
	local read = ns.GetWeaponEnchants()
	for slot, hand in pairs({ [MAIN_SLOT] = read.main, [OFF_SLOT] = read.off }) do
		for _, info in ipairs(hand) do
			local list = worn[slot]
			list[#list + 1] = {
				seconds = info.timeLeft / 1000,
				enchant = info.enchantID,
				layer = WornLayer(info.enchantID, info.enchantType),
			}
		end
	end
	return worn
end

--[[
    A pick no longer than the Show time counts only once gone, as in Has, so
    a 5-minute imbue under "Under 5 Minutes" isn't asked for as it lands.
]]
local function PickHolds(pick, seconds)
	local threshold = pick.refreshSeconds
	return (pick.durationSeconds and pick.durationSeconds <= threshold) or seconds >= threshold
end

-- A client that names no enchant lets any enchant count, held to the most lenient pick.
local function LayerHolds(picks, layer, on)
	for _, worn in ipairs(on) do
		if worn.layer == layer then
			for _, pick in ipairs(picks) do
				if
					pick.layer == layer
					and (not worn.enchant or pick.enchants[worn.enchant])
					and PickHolds(pick, worn.seconds)
				then
					return true
				end
			end
		end
	end
	return false
end

-- Every pick of an uncovered layer, so a rogue topping up Instant Poison can switch to Deadly.
local function PicksToOffer(hand, worn)
	local on, held, offer = worn[hand.slot], {}, {}
	for _, pick in ipairs(hand.picks) do
		local layer = pick.layer
		if held[layer] == nil then
			held[layer] = LayerHolds(hand.picks, layer, on)
		end
		if not held[layer] then
			offer[#offer + 1] = pick
		end
	end
	return offer
end

local function Carries(worn, slot, layer)
	for _, enchant in ipairs(worn[slot]) do
		if enchant.layer == layer then
			return true
		end
	end
	return false
end

--[[
    An imbue can't be pointed at a weapon: it lands on the main hand unless
    that has one and a bare off hand waits. So only that hand is offered, and
    a low off hand waits until gone, or the cast would replace the main
    hand's. Where layers stack, only the imbue layer counts.
]]
local function ImbueLandsOn(worn)
	local layer = ns.WEAPON_ENCHANTS_STACK and IMBUE or TEMPORARY
	if Carries(worn, MAIN_SLOT, layer) and not Carries(worn, OFF_SLOT, layer) and HoldsWeapon(OFF_SLOT) then
		return OFF_SLOT
	end
	return MAIN_SLOT
end
BuffDuty.ImbueLandsOn = ImbueLandsOn

-- Asked at every refresh, so the backstop catches a zone change.
local function InItemZones(zones)
	local instanceId = select(8, GetInstanceInfo())
	if ns.IsPlain(instanceId) and tContains(zones.instances or {}, instanceId) then
		return true
	end
	local uiMapId = C_Map.GetBestMapForUnit("player")
	return ns.IsPlain(uiMapId) and uiMapId ~= nil and tContains(zones.uiMaps or {}, uiMapId)
end

local function BestItem(items)
	local level = UnitLevel("player")
	for _, item in ipairs(items) do
		if (not ns.IsPlain(level) or level >= item.level) and GetItemCount(item.id) > 0 then
			return item
		end
	end
	return nil
end

--[[
    An item names its hand by target-slot, which the template uses once the
    cursor waits on a weapon; an imbue just casts. Either way the click is the
    answer to "replace your enchant?" (confirmReplace).
]]
local function WeaponIcon(hand, pick)
	if pick.zones and not InItemZones(pick.zones) then
		return nil
	end
	local handName = ns.WEAPON_HAND_LABELS[hand.hand]
	local spec = {
		targetName = handName,
		hint = L["BUFF_DUTY_TOOLTIP_WEAPON"]:format(handName),
		confirmReplace = true,
		weapon = true,
		classPick = pick.classPick,
		imbue = pick.layer == IMBUE,
	}
	if pick.items then
		local item = BestItem(pick.items)
		-- Conjured by bare name, which fires the best rank known: each tier is its own spell.
		if not item and pick.create then
			spec.spellId = pick.create.id
			spec.spellName = pick.create.name
			spec.castSpell = pick.create.name
			spec.unit = "player"
			spec.level = pick.create.level
			spec.confirmReplace = nil
			spec.hint = L["BUFF_DUTY_TOOLTIP_CREATE_WEAPON"]
			return spec
		end
		if not item then
			return nil
		end
		spec.itemId = item.id
		spec.item = "item:" .. item.id
		spec.targetSlot = hand.slot
		spec.level = item.itemLevel or item.level
	else
		local rank = pick.ranks[1]
		spec.spellId = rank.id
		spec.spellName = rank.name
		spec.castSpell = rank.castText
		spec.unit = "player"
		spec.level = rank.level
	end
	return spec
end

-- Each hand's row is its own grid, so the icons' order is their columns.
local function SortWeaponIcons(specs)
	table.sort(specs, function(a, b)
		if (a.classPick or false) ~= (b.classPick or false) then
			return a.classPick == true
		end
		if a.imbue ~= b.imbue then
			return a.imbue
		end
		if a.level ~= b.level then
			return a.level > b.level
		end
		return (a.itemId or a.spellId) < (b.itemId or b.spellId)
	end)
	for index, spec in ipairs(specs) do
		spec.column = index
	end
end

local function WeaponRowLabel(hand)
	local name = ns.WEAPON_HAND_LABELS[hand.hand]
	local texture = GetInventoryItemTexture("player", hand.slot)
	if not ns.IsPlain(texture) or not texture then
		return name
	end
	return ("|T%s:%d:%d|t %s"):format(texture, Data.BUFF_DUTY_LABEL_ICON_SIZE, Data.BUFF_DUTY_LABEL_ICON_SIZE, name)
end

-- A click on a weapon icon is the answer to REPLACE_ENCHANT, so one within this many seconds is accepted.
local REPLACE_WINDOW = 2
local replaceClickedAt

-- PreClick, never PostClick: the secure click raises REPLACE_ENCHANT before PostClick runs.
function ns.ExpectReplaceEnchant()
	replaceClickedAt = GetTime()
end

-- The game's popup may open before or after this runs, so it is closed on the next frame too.
local function OnReplaceEnchant()
	if not replaceClickedAt or GetTime() - replaceClickedAt > REPLACE_WINDOW then
		return
	end
	replaceClickedAt = nil
	C_Item.ReplaceEnchant()
	StaticPopup_Hide("REPLACE_ENCHANT")
	C_Timer.After(0, function()
		StaticPopup_Hide("REPLACE_ENCHANT")
	end)
end

ns.SetBuffDutyEventHandler("REPLACE_ENCHANT", OnReplaceEnchant)

-- An imbue is a spell, never missing; a warlock stone with none in the bags is conjured instead.
local function HandMissing(hand, worn, subclass)
	if worn[hand.slot][1] then
		return false
	end
	for _, pick in ipairs(hand.picks) do
		if pick.items and PickFits(pick, subclass) then
			return true
		end
	end
	return false
end

function BuffDuty.AddWeaponRows(rows)
	if #weaponBuffs == 0 then
		return
	end
	local worn = BuffDuty.ReadWeaponEnchants()
	local imbueSlot = ImbueLandsOn(worn)
	for _, hand in ipairs(weaponBuffs) do
		local subclass = WeaponSubclass(hand.slot)
		if subclass then
			local specs = {}
			for _, pick in ipairs(PicksToOffer(hand, worn)) do
				if PickFits(pick, subclass) and (pick.items or hand.slot == imbueSlot) then
					specs[#specs + 1] = WeaponIcon(hand, pick)
				end
			end
			local menu = "weapons:" .. hand.hand
			if specs[1] then
				SortWeaponIcons(specs)
				rows[#rows + 1] = {
					label = WeaponRowLabel(hand),
					icons = specs,
					grid = "weapon" .. hand.hand,
					indent = 0,
					menu = menu,
				}
			elseif BuffDuty.RowOut("weapons") and HandMissing(hand, worn, subclass) then
				rows[#rows + 1] = {
					label = WeaponRowLabel(hand),
					icons = {},
					grid = "weapon" .. hand.hand,
					indent = 0,
					menu = menu,
					missing = true,
				}
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Castable
--------------------------------------------------------------------------------

-- Items are looked for in your bags at each refresh, since bags change without SPELLS_CHANGED.
function BuffDuty.BuildWeaponBuffs(playerClass)
	wipe(weaponBuffs)
	local settings = ns.db.global.buffWindow
	local classHands = {}
	for _, hand in ipairs(ns.BUFF_DUTY_WEAPON_HANDS[playerClass] or {}) do
		classHands[hand] = true
	end
	for _, hand in ipairs(settings.weaponEnabled and Data.WEAPON_HAND_ORDER or {}) do
		local chosen = {}
		local show = BuffDuty.RowShowSeconds("weapons")
		local function Choose(entry, ranks, classPick)
			chosen[#chosen + 1] = {
				key = entry.key,
				ranks = ranks,
				items = entry.items,
				create = entry.create and KnownRanks({ ranks = entry.create })[1],
				enchants = entry.enchants,
				types = entry.types,
				zones = entry.zones,
				layer = entry.layer,
				refreshSeconds = show,
				durationSeconds = entry.row.duration and entry.row.duration * 60,
				classPick = classPick,
			}
		end
		for _, entry in ipairs(classHands[hand] and weaponEntries or {}) do
			local ranks = entry.ranks and KnownRanks(entry)
			if
				entry.row.class == playerClass
				and BuffDuty.WeaponChoiceOn(settings.weaponPicks, playerClass .. "_" .. hand, entry.key)
				and (entry.items or ranks[1])
			then
				Choose(entry, ranks, true)
			end
		end
		for _, entry in ipairs(weaponItemEntries) do
			local kindHands = Data.WEAPON_ITEM_KIND_HANDS[entry.kind]
			if
				(not kindHands or tContains(kindHands, hand))
				and BuffDuty.WeaponChoiceOn(settings.weaponItems, hand, entry.key)
			then
				Choose(entry)
			end
		end
		if chosen[1] then
			weaponBuffs[#weaponBuffs + 1] = {
				hand = hand,
				slot = Data.WEAPON_HAND_SLOTS[hand],
				picks = chosen,
			}
		end
	end
end
