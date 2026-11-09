local _, ns = ...
local Data = ns.Data
local L = ns.L

-- Your weapons' row in the Buff Duty window's Self section: the poisons, imbues, oils and stones to put on each hand.

local BuffDuty = ns.BuffDuty
local weaponBuffs = BuffDuty.weaponBuffs
local weaponByEnchant = BuffDuty.weaponByEnchant

local IMBUE, TEMPORARY = Data.WEAPON_LAYERS.IMBUE, Data.WEAPON_LAYERS.TEMPORARY
local MAIN_SLOT, OFF_SLOT = Data.WEAPON_HAND_SLOTS.MAIN, Data.WEAPON_HAND_SLOTS.OFF

-- The client's own "Main Hand" and "Off Hand", for the tooltip and the options panel.
ns.WEAPON_HAND_LABELS = { MAIN = INVTYPE_WEAPONMAINHAND, OFF = INVTYPE_WEAPONOFFHAND }

local GetItemCount = C_Item.GetItemCount

--------------------------------------------------------------------------------
-- Weapons
--------------------------------------------------------------------------------

local WEAPON_CLASS = Enum.ItemClass and Enum.ItemClass.Weapon or 2
local FISHING_POLE = Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole or 20

--[[
    The weapon subclass in a hand, or nil when it holds no weapon: an off hand
    holding a shield or a book, or nothing, has nothing to ask for.
]]
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

--[[
    Whether a pick takes on a hand's weapon. A weapon item names the weapon
    types its spell takes (a subclass mask): a sharpening stone wants an edge,
    a weightstone a blunt weapon, a lure a fishing pole. A poison, an imbue,
    or an item naming none takes any weapon but a fishing pole.
]]
local function PickFits(pick, subclass)
	if not pick.types or pick.types == 0 then
		return subclass ~= FISHING_POLE
	end
	return bit.band(pick.types, bit.lshift(1, subclass)) ~= 0
end

--[[
    The layer an enchant on a weapon is in: the layer of the row that puts it
    on, else, for one no row names, the client's own word for it. All one
    layer where a weapon holds a single temporary enchant.
]]
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
    WoW Forever's C_Item.GetWeaponEnchantInfo(weaponSlot): a list per hand,
    one entry for each enchant, permanent ones included. Only the temporary
    and imbue ones count. A secret field skips its entry, as if bare.
]]
local function ReadModernEnchants(worn)
	local types, slots = Enum.ItemEnchantType, Enum.WeaponSlot
	for slot, weaponSlot in pairs({ [MAIN_SLOT] = slots.MainHand, [OFF_SLOT] = slots.OffHand }) do
		local list = C_Item.GetWeaponEnchantInfo(weaponSlot)
		if ns.IsPlain(list) and type(list) == "table" then
			for _, info in ipairs(list) do
				local has = ns.IsPlain(info) and info.hasEnchant
				local kind, left, enchant = has and info.enchantType, has and info.timeLeft, has and info.enchantID
				if
					ns.IsPlain(has)
					and has
					and ns.IsPlain(kind)
					and (kind == types.Temporary or kind == types.Imbue)
					and ns.IsPlain(left)
					and left
				then
					enchant = ns.IsPlain(enchant) and enchant or nil
					local hand = worn[slot]
					hand[#hand + 1] = { seconds = left / 1000, enchant = enchant, layer = WornLayer(enchant, kind) }
				end
			end
		end
	end
end

--[[
    The older GetWeaponEnchantInfo: one enchant per hand. It has returned
    three values per hand on some clients and four (with the enchant id) on
    others, so the off hand is found by counting.
]]
local function ReadLegacyEnchants(worn)
	local count = select("#", GetWeaponEnchantInfo())
	local stride = count >= 8 and 4 or 3
	local values = { GetWeaponEnchantInfo() }
	for index, slot in ipairs({ MAIN_SLOT, OFF_SLOT }) do
		local base = (index - 1) * stride
		local has, expiration = values[base + 1], values[base + 2]
		if ns.IsPlain(has) and has and ns.IsPlain(expiration) and expiration then
			local enchant = stride == 4 and values[base + 4]
			enchant = ns.IsPlain(enchant) and enchant or nil
			worn[slot][1] = { seconds = expiration / 1000, enchant = enchant, layer = WornLayer(enchant) }
		end
	end
end

--[[
    Each hand's temporary enchants, by slot: a list of { seconds left,
    enchant id (nil where the client names none), layer }. Empty for a bare
    weapon. Diagnostics reads it too.
]]
function BuffDuty.ReadWeaponEnchants()
	local worn = { [MAIN_SLOT] = {}, [OFF_SLOT] = {} }
	if C_Item.GetWeaponEnchantInfo and Enum.ItemEnchantType and Enum.WeaponSlot then
		ReadModernEnchants(worn)
	else
		ReadLegacyEnchants(worn)
	end
	return worn
end

--[[
    Whether a pick on the weapon has time enough left by its own setting.
    One whose whole duration (the row's, from the data) is no longer than
    that time only needs offering once it's gone, as in Has, so a 5-minute
    Classic Era imbue under "Under 5 Minutes" isn't asked for the moment it
    lands.
]]
local function PickHolds(pick, seconds)
	local threshold = pick.refreshSeconds
	return (pick.durationSeconds and pick.durationSeconds <= threshold) or seconds >= threshold
end

--[[
    Whether a hand's layer is covered: it carries one of the hand's picks in
    that layer with time enough left. A client that names no enchant lets
    any enchant count, held to the most lenient pick.
]]
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

--[[
    The picks a hand needs offered, layer by layer. None of a layer while
    the weapon carries one of its picks with time enough left; every pick of
    it otherwise (nothing in that layer, one running low, or one not
    picked), so the player chooses -- a rogue topping up Instant Poison can
    switch to Deadly. On WoW Forever a poison on the weapon still leaves its
    stones offered, and a stone its poisons.
]]
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

-- Whether a hand carries any enchant in a layer.
local function Carries(worn, slot, layer)
	for _, enchant in ipairs(worn[slot]) do
		if enchant.layer == layer then
			return true
		end
	end
	return false
end

--[[
    The hand a shaman's next imbue goes on. The spell picks for itself and
    can't be pointed at a weapon: the main hand, unless it already has an
    imbue and a bare off-hand weapon is waiting. So only that hand's imbue
    is offered, and an off hand running low waits until it's gone -- casting
    then would land on the main hand and replace what's there. Where layers
    stack, only the imbue layer counts: a stone doesn't send it elsewhere.
]]
local function ImbueLandsOn(worn)
	local layer = ns.WEAPON_ENCHANTS_STACK and IMBUE or TEMPORARY
	if Carries(worn, MAIN_SLOT, layer) and not Carries(worn, OFF_SLOT, layer) and HoldsWeapon(OFF_SLOT) then
		return OFF_SLOT
	end
	return MAIN_SLOT
end
BuffDuty.ImbueLandsOn = ImbueLandsOn

--[[
    Whether you're somewhere a weapon item works, for one that only works in
    certain places: an instance it names, by the map ID GetInstanceInfo
    reports, or an outdoor zone it names, by C_Map.GetBestMapForUnit's map.
    Asked at every refresh, so the backstop catches a zone change.
]]
local function InItemZones(zones)
	local instanceId = select(8, GetInstanceInfo())
	if ns.IsPlain(instanceId) and tContains(zones.instances or {}, instanceId) then
		return true
	end
	local uiMapId = C_Map.GetBestMapForUnit("player")
	return ns.IsPlain(uiMapId) and uiMapId ~= nil and tContains(zones.uiMaps or {}, uiMapId)
end

-- The best item of a pick in your bags that your level can use, { id, level, itemLevel? }, or nil.
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
    An item's button (a poison, oil, stone or lure) names its hand by
    target-slot: using the item leaves the cursor waiting on a weapon, and the
    secure template picks that slot. An imbue never asks -- see ImbueLandsOn
    -- so its button just casts. Either way the game's "replace your
    enchant?" question is answered for you (confirmReplace): the click was
    the answer. The Buff Key passes every weapon icon by (weapon). `level`
    ranks what it uses, for SortWeaponIcons: an oil's, stone's or lure's item
    level, a poison's required level, or an imbue rank's learn level.
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

--[[
    A hand's icons left to right: your class's poisons or imbues, then the
    items in the imbue layer (a Firestone), then the oils, stones and lures,
    each by the level of what it uses, highest first -- Instant Poison IV
    (44) before Deadly Poison II (38), Solid Sharpening Stone before Rough.
    Each hand's row is its own grid, so the icons' order is their columns.
]]
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

--[[
    A hand's row label: the equipped weapon's icon, then the client's "Main
    Hand" or "Off Hand", so the row says which weapon its icons go on.
]]
local function WeaponRowLabel(hand)
	local name = ns.WEAPON_HAND_LABELS[hand.hand]
	local texture = GetInventoryItemTexture("player", hand.slot)
	if not ns.IsPlain(texture) or not texture then
		return name
	end
	return ("|T%s:%d:%d|t %s"):format(texture, Data.BUFF_DUTY_ICON_SIZE, Data.BUFF_DUTY_ICON_SIZE, name)
end

--[[
    Putting a poison or imbue over the one a weapon already has makes the game
    ask first (REPLACE_ENCHANT). A click on a weapon icon was the answer, so
    the question is accepted when it comes within a moment of one.
]]
local REPLACE_WINDOW = 2
local replaceClickedAt

-- Called by a weapon icon's PreClick.
function ns.ExpectReplaceEnchant()
	replaceClickedAt = GetTime()
end

--[[
    The game's own popup may open before or after this runs, so it is closed
    on the next frame too.
]]
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

--[[
    One row per hand holding a weapon, with the picks it can still take, for
    the Self section (BuffDuty.AddSelfSection). Nothing while the weapons'
    switch is off, which leaves weaponBuffs empty.
]]
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
			if specs[1] then
				SortWeaponIcons(specs)
				rows[#rows + 1] =
					{ label = WeaponRowLabel(hand), icons = specs, grid = "weapon" .. hand.hand, indent = 0 }
			end
		end
	end
end
