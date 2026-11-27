local _, ns = ...

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

-- Append |r at the point of use.
local COLOR_PREFIX = "|cff"

local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = COLOR_PREFIX .. hex
end

ns.COLORS = COLORS

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

-- Exposed so every color stays the hex it was chosen as, never hand-divided decimals.
function ns.HexToRGB(hex)
	return {
		r = tonumber(hex:sub(1, 2), 16) / 255,
		g = tonumber(hex:sub(3, 4), 16) / 255,
		b = tonumber(hex:sub(5, 6), 16) / 255,
	}
end

-- Derived at load, so a palette edit reaches drawn frames and colored text together.
ns.COLORS_RGB = {}
for key, hex in pairs(ns.PALETTE) do
	ns.COLORS_RGB[key] = ns.HexToRGB(hex)
end

local function ShowUIMessage(text, key)
	local color = ns.COLORS_RGB[key]
	UIErrorsFrame:AddMessage(text, color.r, color.g, color.b)
end

function ns.ShowUIError(text)
	ShowUIMessage(text, "OFF")
end

function ns.ShowUINotice(text)
	ShowUIMessage(text, "TITLE")
end

-- Away from the screen's edges, by the same halves Menu-Kit opens its menus by.
local TOOLTIP_ANCHORS = {
	up = { left = "ANCHOR_LEFT", right = "ANCHOR_RIGHT" },
	down = { left = "ANCHOR_BOTTOMLEFT", right = "ANCHOR_BOTTOMRIGHT" },
}

function ns.SetTooltipOwner(owner)
	local x, y = owner:GetCenter()
	local scale = owner:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
	local openDown = (y or 0) * scale > UIParent:GetHeight() / 2
	GameTooltip:SetOwner(owner, TOOLTIP_ANCHORS[openDown and "down" or "up"][openLeft and "left" or "right"])
end

-- nil for an unknown class, so each caller picks its own fallback. Append |r at the point of use.
function ns.GetClassColor(classToken)
	local hex = classToken and ns.CLASS_COLORS[classToken]
	return hex and (COLOR_PREFIX .. hex) or nil
end

-- For a line drawn in the TEXT color, which picks up again after the name.
function ns.ClassColoredName(name, classToken)
	local color = ns.GetClassColor(classToken)
	return color and (color .. name .. "|r" .. ns.GetColor("TEXT")) or name
end

-- White for a class the table does not hold.
function ns.ClassName(classToken)
	return (ns.GetClassColor(classToken) or ns.GetColor("TEXT"))
		.. (LOCALIZED_CLASS_NAMES_MALE[classToken] or classToken)
		.. "|r"
end

--------------------------------------------------------------------------------
-- Spell Knowledge
--------------------------------------------------------------------------------

--[[
    On Forever IsSpellKnown and IsPlayerSpell exist only in the deprecation
    layer, which the loadDeprecationFallbacks CVar switches off, so these read
    C_SpellBook. Callers wanting "does the player know it" test both.
]]
function ns.IsSpellKnown(spellID)
	return C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, false)
end

function ns.IsPlayerSpell(spellID)
	return C_SpellBook.IsSpellKnown(spellID)
end

--------------------------------------------------------------------------------
-- Client Differences
--------------------------------------------------------------------------------

--[[
    One accessor per API the engines differ on, resolved once here so every
    caller agrees and Diagnostics' API Endpoints show which side a client took.
    Each answers on every client, neutrally where the client lacks the API:

      ns.FetchPurchasedBankTabIDs()  Forever's character bank is the C_Bank
                                     tabs the player bought; nil on Era and
                                     TBC, which have BANK_CONTAINER and bags.
      ns.BankBagIDs()                The character bank's container IDs, the
                                     main bank first: those tabs on Forever,
                                     BANK_CONTAINER and seven bags elsewhere.
      ns.GetReagentBagID()           Forever's equipped reagent bag; nil on
                                     Era, TBC and Mists, which have none.
      ns.GetNumTalentTabs()          The classic talent trees; nil from MoP on,
                                     whose talents are specializations.
      ns.UnitCharacterPoints(unit)   Unspent talent points; nil on Forever.
      ns.IsSecretValue(value)        Forever's secret values; false elsewhere.
      ns.GetPlayerFullName()         This character's name: the first name and
                                     surname on Forever, the one name on Era
                                     and TBC.
      ns.GetNumQuestLogEntries(),    The quest log: a quest ID, nil for a
      ns.GetQuestLogQuestID(index)   header line.
      ns.GetNumSkillLines(),         The skill list, in the legacy return order.
      ns.GetSkillLineInfo(index),
      ns.ExpandSkillHeader(index),   Opening and closing a skill header; nil
      ns.CollapseSkillHeader(index)  where the client has neither call.
      ns.GetPetFoodTypes()           The pet's diets, as a list.
      ns.GetMerchantItemInfo(index)  A merchant slot, in the legacy return
                                     order as far as the eighth value, whether
                                     the slot costs something besides gold.
      ns.GetMerchantItemID(index)    The item a merchant slot sells; nil where
                                     the client has no such reader.
      ns.GetPartyAssignment(...),    The group's Main Tank mark, assigned
      ns.UnitGroupRolesAssigned(u),  role, your own group-finder roles, and a
      ns.GetLFGRoles(),              resurrection on its way to a unit; each
      ns.UnitHasIncomingResurrection nil where the client lacks the call.
      ns.AddItemTooltipPostCall(     Runs a function with each item tooltip of
        tooltips, func)              those given and its item ID: Retail's
                                     TooltipDataProcessor on Forever, the
                                     OnTooltipSetItem script on Era and TBC.
      ns.AddSpellTooltipPostCall(    The same for every spell tooltip, with
        func)                        its spell ID.
      ns.GetPetSpellBookSlot(slot),  The pet's spellbook: a slot's spell, how
      ns.GetNumPetSpells(),          many slots it has, and the pickup that
      ns.PickupPetSpellBookItem(s)   puts a slot's spell on the cursor.
      ns.GetNumSpecGroups(),         Dual spec's talent groups and the active
      ns.GetActiveSpecGroup()        one; nil where the client can't say.

    Forever runs on the Retail client, which has dropped the legacy quest,
    skill, pet and merchant readers for namespaced ones that return a table;
    Era and TBC have only the legacy globals. Spell names need no shim: every
    call site reads C_Spell.GetSpellName, which all three clients ship.
]]
-- Bank bag ids follow the player's own, offset by NUM_BAG_SLOTS: 5..10 on Classic Era (six slots), 5..11 on TBC.
local BANK_BAG_COUNT = 7

--[[
    Chosen by whether the client has bank tabs at all, never by what the tab
    list answers: the bought tabs change at any visit and read empty until the
    answer is in. Era's seventh bank bag holds no slots, so it reads as empty.
]]
if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
	function ns.FetchPurchasedBankTabIDs()
		return C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Character)
	end

	function ns.BankBagIDs()
		return ns.FetchPurchasedBankTabIDs() or {}
	end
else
	function ns.FetchPurchasedBankTabIDs()
		return nil
	end

	function ns.BankBagIDs()
		local bagIDs = { BANK_CONTAINER }
		for index = 1, BANK_BAG_COUNT do
			bagIDs[#bagIDs + 1] = NUM_BAG_SLOTS + index
		end
		return bagIDs
	end
end

-- Elsewhere the container after the player's bags is a bank bag, so it must never be read as theirs.
if (NUM_REAGENTBAG_SLOTS or 0) > 0 then
	local reagentBagID = Enum.BagIndex and Enum.BagIndex.ReagentBag or (NUM_BAG_SLOTS + 1)
	function ns.GetReagentBagID()
		return reagentBagID
	end
else
	function ns.GetReagentBagID()
		return nil
	end
end

-- The bags the player carries, backpack first, then Forever's reagent bag where there is one.
ns.CARRIED_BAG_IDS = {}
for bagID = 0, NUM_BAG_SLOTS do
	ns.CARRIED_BAG_IDS[#ns.CARRIED_BAG_IDS + 1] = bagID
end
if ns.GetReagentBagID() then
	ns.CARRIED_BAG_IDS[#ns.CARRIED_BAG_IDS + 1] = ns.GetReagentBagID()
end

--[[
    From MoP on there are no talent trees, only specializations. MoP Classic
    still has the GetNumTalentTabs global, but calling it raises "API
    unsupported in this version", so the classic trees count as missing there.
]]
if GetNumTalentTabs and ns.EXPANSION < 5 then
	ns.GetNumTalentTabs = GetNumTalentTabs
else
	function ns.GetNumTalentTabs()
		return nil
	end
end

if UnitCharacterPoints then
	ns.UnitCharacterPoints = UnitCharacterPoints
else
	function ns.UnitCharacterPoints()
		return nil
	end
end

if issecretvalue then
	ns.IsSecretValue = issecretvalue
else
	function ns.IsSecretValue()
		return false
	end
end

--[[
    Wherever the add-on saves or names a Forever character, it is this whole
    name, never the first name alone.

    UnitNameUnmodified, as AceDB keys its records: a saved name must not follow
    display restyling. The surname is added only when the first value doesn't
    already end with it: an earlier beta gave the whole name there, and saved
    files hold keys in that shape.
]]
if RegionalUniqueNamesEnabled then
	local separatorConstants = Constants.CharacterNameSeparatorConsts
	local SURNAME_SEPARATOR = separatorConstants and separatorConstants.CHARACTERNAME_SURNAME_SEPARATOR or " "

	function ns.GetPlayerFullName()
		local name, surname = UnitNameUnmodified("player")
		if name and surname and surname ~= "" and RegionalUniqueNamesEnabled() then
			local ending = SURNAME_SEPARATOR .. surname
			if name:sub(-#ending) ~= ending then
				name = name .. ending
			end
		end
		return name
	end
else
	function ns.GetPlayerFullName()
		return (UnitName("player"))
	end
end

-- Whether this client ships a frame template, asked before CreateFrame names one it may lack.
function ns.HasTemplate(template)
	return C_XMLUtil.GetTemplateInfo(template) ~= nil
end

if C_QuestLog and C_QuestLog.GetInfo then
	ns.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local info = C_QuestLog.GetInfo(questIndex)
		if info and not info.isHeader then
			return info.questID
		end
	end
else
	ns.GetNumQuestLogEntries = GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questIndex)
		if not isHeader then
			return questID
		end
	end
end

if C_SkillInfo and C_SkillInfo.GetSkillLineInfo then
	ns.GetNumSkillLines = C_SkillInfo.GetNumSkillLines

	function ns.GetSkillLineInfo(skillIndex)
		local info = C_SkillInfo.GetSkillLineInfo(skillIndex)
		if info then
			return info.name, info.isHeader, not info.isCollapsed, info.rank
		end
	end
else
	ns.GetNumSkillLines = GetNumSkillLines
	ns.GetSkillLineInfo = GetSkillLineInfo
end

--[[
    { main = list, off = list }, each entry { timeLeft (ms), enchantID?,
    enchantType? }. Forever's call lists permanent enchants too, so only
    temporary and imbue ones are kept. The older call has returned three or
    four values per hand by client, so the off hand is found by counting. A
    secret field skips its entry.
]]
if C_Item.GetWeaponEnchantInfo and Enum.ItemEnchantType and Enum.WeaponSlot then
	function ns.GetWeaponEnchants()
		local types, slots = Enum.ItemEnchantType, Enum.WeaponSlot
		local worn = { main = {}, off = {} }
		for hand, weaponSlot in pairs({ main = slots.MainHand, off = slots.OffHand }) do
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
						local entries = worn[hand]
						entries[#entries + 1] =
							{ timeLeft = left, enchantID = ns.IsPlain(enchant) and enchant or nil, enchantType = kind }
					end
				end
			end
		end
		return worn
	end
else
	function ns.GetWeaponEnchants()
		local worn = { main = {}, off = {} }
		local count = select("#", GetWeaponEnchantInfo())
		local stride = count >= 8 and 4 or 3
		local values = { GetWeaponEnchantInfo() }
		for index, hand in ipairs({ "main", "off" }) do
			local base = (index - 1) * stride
			local has, expiration = values[base + 1], values[base + 2]
			if ns.IsPlain(has) and has and ns.IsPlain(expiration) and expiration then
				local enchant = stride == 4 and values[base + 4]
				worn[hand][1] = { timeLeft = expiration, enchantID = ns.IsPlain(enchant) and enchant or nil }
			end
		end
		return worn
	end
end

ns.ExpandSkillHeader = (C_SkillInfo and C_SkillInfo.ExpandSkillHeader) or ExpandSkillHeader
ns.CollapseSkillHeader = (C_SkillInfo and C_SkillInfo.CollapseSkillHeader) or CollapseSkillHeader

-- Whether the client keeps professions apart from the spell tabs, readable through GetProfessions.
ns.READS_PROFESSIONS = (GetProfessions and GetProfessionInfo and C_SpellBook.GetNumSpellBookSkillLines) and true
	or false

if C_PetInfo and C_PetInfo.GetPetFoodTypes then
	ns.GetPetFoodTypes = C_PetInfo.GetPetFoodTypes
else
	function ns.GetPetFoodTypes()
		return { GetPetFoodTypes() }
	end
end

if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
	function ns.GetMerchantItemInfo(index)
		local info = C_MerchantFrame.GetItemInfo(index)
		if info then
			return info.name,
				info.texture,
				info.price,
				info.stackCount,
				info.numAvailable,
				info.isPurchasable,
				info.isUsable,
				info.hasExtendedCost
		end
	end
else
	ns.GetMerchantItemInfo = GetMerchantItemInfo
end

local function Missing()
	return nil
end

ns.GetMerchantItemID = GetMerchantItemID or Missing
ns.GetPartyAssignment = GetPartyAssignment or Missing
ns.UnitGroupRolesAssigned = UnitGroupRolesAssigned or Missing
ns.GetLFGRoles = GetLFGRoles or Missing
ns.UnitHasIncomingResurrection = UnitHasIncomingResurrection or Missing

local MASK_SPELL_ID = 0xFFFFFF -- the old API packs a pet spellbook entry's flags above its spell ID

--[[
    A slot as { id, name, subtext, icon, passive, autocastAllowed, autocastOn },
    or nil for a command or an empty slot.
]]
if C_SpellBook.GetSpellBookItemInfo then
	function ns.GetPetSpellBookSlot(slot)
		local bank = Enum.SpellBookSpellBank.Pet
		local item = C_SpellBook.GetSpellBookItemInfo(slot, bank)
		if not item or not item.spellID or item.itemType == Enum.SpellBookItemType.None then
			return nil
		end
		local allowed, on = false, false
		if C_SpellBook.GetSpellBookItemAutoCast then
			allowed, on = C_SpellBook.GetSpellBookItemAutoCast(slot, bank)
		end
		return {
			id = item.spellID,
			name = item.name,
			subtext = item.subName,
			icon = item.iconID,
			passive = item.isPassive,
			autocastAllowed = allowed,
			autocastOn = on,
		}
	end
else
	function ns.GetPetSpellBookSlot(slot)
		local book = BOOKTYPE_PET or "pet"
		local _, id = GetSpellBookItemInfo(slot, book)
		local name, subtext = GetSpellBookItemName(slot, book)
		id = id and bit.band(id, MASK_SPELL_ID)
		-- a command's ID isn't a spell's, so its name doesn't match the one the client gives that ID
		if not id or not name or C_Spell.GetSpellName(id) ~= name then
			return nil
		end
		local allowed, on = GetSpellAutocast(slot, book)
		return {
			id = id,
			name = name,
			subtext = subtext,
			icon = GetSpellBookItemTexture(slot, book),
			passive = IsPassiveSpell(slot, book),
			autocastAllowed = allowed,
			autocastOn = on,
		}
	end
end

ns.GetNumPetSpells = C_SpellBook.HasPetSpells or HasPetSpells

if C_SpellBook.PickupSpellBookItem then
	function ns.PickupPetSpellBookItem(slot)
		C_SpellBook.PickupSpellBookItem(slot, Enum.SpellBookSpellBank.Pet)
	end
else
	function ns.PickupPetSpellBookItem(slot)
		PickupSpellBookItem(slot, BOOKTYPE_PET or "pet")
	end
end

-- GetNumSpecGroups first: MoP Classic still defines GetNumTalentGroups but throws "API unsupported" on a call.
ns.GetNumSpecGroups = C_SpecializationInfo and C_SpecializationInfo.GetNumSpecGroups
	or GetNumSpecGroups
	or GetNumTalentGroups
	or Missing
ns.GetActiveSpecGroup = C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup
	or GetActiveTalentGroup
	or Missing

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType then
	function ns.AddItemTooltipPostCall(tooltips, func)
		local wanted = {}
		for _, tooltip in ipairs(tooltips) do
			wanted[tooltip] = true
		end
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if wanted[tooltip] then
				func(tooltip, data and data.id)
			end
		end)
	end
else
	function ns.AddItemTooltipPostCall(tooltips, func)
		local function OnTooltipSetItem(tooltip)
			local _, link = tooltip:GetItem()
			func(tooltip, link and tonumber(link:match("item:(%d+)")))
		end
		for _, tooltip in ipairs(tooltips) do
			tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
		end
	end
end

--[[
    On the Retail client a bar slot holding a macro (every Spell Book macro)
    fills a Macro tooltip, not a Spell one; its first line's tooltipID is the
    spell it shows, so those count too.
]]
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType then
	function ns.AddSpellTooltipPostCall(func)
		local SPELL = Enum.TooltipDataType.Spell
		TooltipDataProcessor.AddTooltipPostCall(SPELL, function(tooltip, data)
			func(tooltip, data and data.id)
		end)
		local MACRO = Enum.TooltipDataType.Macro
		if MACRO then
			TooltipDataProcessor.AddTooltipPostCall(MACRO, function(tooltip, data)
				local line = data and ns.IsPlain(data.lines) and data.lines and data.lines[1]
				if not line then
					return
				end
				local lineType, spellID = line.tooltipType, line.tooltipID
				if not (ns.IsPlain(lineType) and ns.IsPlain(spellID)) or not spellID then
					return
				end
				if lineType == nil or lineType == SPELL then
					func(tooltip, spellID)
				end
			end)
		end
	end
elseif GameTooltip:HasScript("OnTooltipSetSpell") then
	function ns.AddSpellTooltipPostCall(func)
		GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip)
			func(tooltip, select(2, tooltip:GetSpell()))
		end)
	end
else
	function ns.AddSpellTooltipPostCall() end
end

--------------------------------------------------------------------------------
-- Secret Values
--------------------------------------------------------------------------------

-- True when a value is safe to compare, concatenate, or send; secret values error on all three.
function ns.IsPlain(value)
	return not (issecretvalue and issecretvalue(value))
end

-- Forever answers some unit questions (charmed, enemy, attackable) with a secret boolean; it counts as false.
function ns.IsPlainTrue(value)
	return ns.IsPlain(value) and value == true
end

-- True for any readable truthy answer, for the unit questions that answer with a number (UnitInRaid's raid index).
function ns.IsPlainYes(value)
	return ns.IsPlain(value) and value and true or false
end

--[[
    On WoW Forever, unit identity, aura data and cooldowns go secret in
    combat. Ask these before reading any of them; each is always false on the
    other flavors.
]]
function ns.IsUnitIdentitySecret(unit)
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldUnitIdentityBeSecret(unit)
end

function ns.AreAurasSecret()
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldAurasBeSecret()
end

function ns.AreCooldownsSecret()
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldCooldownsBeSecret()
end

function ns.IsSpellCooldownSecret(spellID)
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldSpellCooldownBeSecret(spellID)
end

-- Always true on the other flavors.
function ns.CanCompareUnitTokens(unit, otherUnit)
	return ns.FLAVOR ~= "Camelot" or C_Secrets.CanCompareUnitTokens(unit, otherUnit)
end

--------------------------------------------------------------------------------
-- Item Stats
--------------------------------------------------------------------------------

ns.GetItemStats = C_Item.GetItemStats or GetItemStats

--------------------------------------------------------------------------------
-- Tooltip Text
--------------------------------------------------------------------------------

--[[
    Plain lines, a right-hand column kept after " >> ", color escapes
    stripped: C_TooltipInfo where it ships, else a hidden tooltip. A read can
    throw on an odd id, so callers protect it.
]]
local SCAN_TOOLTIP_NAME = "GoodToGoScanTooltip"
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }
local scanTooltip

local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

local function ReadTooltipData(kind, id)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](id)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

-- Every read through it is synchronous, so readers share one.
function ns.GetScanTooltip()
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	return scanTooltip, SCAN_TOOLTIP_NAME
end

local function ReadScanTooltipWith(setter, ...)
	ns.GetScanTooltip()
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	scanTooltip[setter](scanTooltip, ...)
	local lines = {}
	for index = 1, scanTooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. index]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	scanTooltip:Hide()
	return lines
end

local function ReadScanTooltip(kind, id)
	return ReadScanTooltipWith("SetHyperlink", kind .. ":" .. id)
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

-- getter and setter name the same fill, e.g. "GetInventoryItem" and "SetInventoryItem".
function ns.ReadTooltipLines(getter, setter, ...)
	if not (C_TooltipInfo and C_TooltipInfo[getter]) then
		return ReadScanTooltipWith(setter, ...)
	end
	local lines = {}
	local data = C_TooltipInfo[getter](...)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

-- The Classic engine has no GetTrainerService, so the hidden tooltip shows the service and GetSpell reads it.
if C_TooltipInfo and C_TooltipInfo.GetTrainerService then
	function ns.GetTrainerServiceSpellId(index)
		local data = C_TooltipInfo.GetTrainerService(index)
		return data and data.id
	end
else
	function ns.GetTrainerServiceSpellId(index)
		ns.GetScanTooltip()
		scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		scanTooltip:SetTrainerService(index)
		local _, spellId = scanTooltip:GetSpell()
		scanTooltip:Hide()
		return spellId
	end
end

--------------------------------------------------------------------------------
-- Character Profile Names
--------------------------------------------------------------------------------

--[[
    The name AceDB keys a character's profile by: "Name - Realm" on realm
    clients, "First Last" on Forever (AceDB-3.0 minor 39 on). These three are
    the only places that spell the format out:

      ns.GetCharacterProfileName()
          nil while the client still answers with its "Unknown" placeholder.
      ns.ProfileNameForCharacter(name, realm)
      ns.SplitCharacterProfileName(profileKey)
          nil for a key that names no character: the placeholder's, or on
          Forever an older AceDB's first name and rule set ("Name - PvE").

    Not the add-on's own character key (ns.GetCharacterKey).
]]
local function HasRegionalNames()
	return RegionalUniqueNamesEnabled ~= nil and RegionalUniqueNamesEnabled()
end

function ns.ProfileNameForCharacter(name, realm)
	if HasRegionalNames() then
		return name
	end
	return name .. " - " .. realm
end

-- Read off the Inventory Report's records, refreshed at every login, so a class is known from a first login.
function ns.GetClassesByProfileName()
	local classes = {}
	for _, record in pairs(ns.db.global.inventory) do
		if type(record) == "table" and record.name and record.realm then
			classes[ns.ProfileNameForCharacter(record.name, record.realm)] = record.class
		end
	end
	return classes
end

function ns.GetCharacterProfileName()
	local name, surname = (UnitNameUnmodified or UnitName)("player")
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	if HasRegionalNames() then
		return surname and (name .. " " .. surname) or name
	end
	return name .. " - " .. GetRealmName()
end

function ns.SplitCharacterProfileName(profileKey)
	local name, realm
	if not HasRegionalNames() then
		name, realm = profileKey:match("^(.-) %- (.+)$")
	elseif not profileKey:find(" - ", 1, true) then
		name = profileKey
	end
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	return name, realm
end

--------------------------------------------------------------------------------
-- Character Keys
--------------------------------------------------------------------------------

-- "-Realm" as it ends a character's key, the realm's spaces closed up; empty where the client names no realm.
local function RealmSuffix()
	local realm = ((GetRealmName() or ""):gsub("%s+", ""))
	if realm == "" then
		return ""
	end
	return "-" .. realm
end

-- The whole name (first name and surname on Forever), then the realm.
function ns.GetCharacterKey()
	return (ns.GetPlayerFullName() or "Unknown") .. RealmSuffix()
end

--------------------------------------------------------------------------------
-- Spell Links
--------------------------------------------------------------------------------

--[[
    Trap: Classic's native GetSpellLink drops the trailing ":0", and the chat
    validator strips such a link to the bare name. So the link is built by
    hand, color lowercased as the client writes it; native is the fallback
    only when the name won't resolve.
]]
local C_SPELL_LINK = ns.SPELL_LINK_COLOR:lower()

function ns.GetSpellLink(spellId)
	local name = C_Spell.GetSpellName(spellId)
	if name then
		return ("|cff" .. C_SPELL_LINK .. "|Hspell:%d:0|h[%s]|h|r"):format(spellId, name)
	end
	local link = C_Spell.GetSpellLink(spellId)
	if link and link ~= "" then
		return link
	end
	return nil
end

--------------------------------------------------------------------------------
-- GUID Helpers
--------------------------------------------------------------------------------

--[[
    The GUID's own type is authoritative, unlike the combat log's TYPE_PLAYER
    flag. Guards the whisper paths: a whisper to a pet bounces as "No player
    named".
]]
function ns.IsPlayerGUID(guid)
	return type(guid) == "string" and guid:sub(1, 7) == "Player-"
end

--------------------------------------------------------------------------------
-- Instance Type
--------------------------------------------------------------------------------

function ns.IsInPvPInstance()
	local _, instanceType = IsInInstance()
	return instanceType == "pvp" or instanceType == "arena"
end

--------------------------------------------------------------------------------
-- Group Context
--------------------------------------------------------------------------------

--[[
    Where the player is, for every setting that turns on or off by group: the
    first of these that holds, as one of ns.GROUP_CONTEXTS.
      battleground  inside a battleground or an arena, whatever the group
      raid          in a raid group, home or instance (LFR included)
      party         in any other group (group finder dungeons included)
      solo          in no group
    A feature asks ns.IsGroupContextOn, not IsInGroup or IsInRaid, to decide
    when it acts; picking a chat channel or unit prefix still reads them.
]]
function ns.GetGroupContext()
	if ns.IsInPvPInstance() then
		return "battleground"
	end
	if IsInRaid() then
		return "raid"
	end
	if IsInGroup() then
		return "party"
	end
	return "solo"
end

-- A missing table or entry reads as ticked, the way every such setting starts.
function ns.IsGroupContextOn(showIn, context)
	if type(showIn) ~= "table" then
		return true
	end
	return showIn[context or ns.GetGroupContext()] ~= false
end

--------------------------------------------------------------------------------
-- Unit Resolution
--------------------------------------------------------------------------------

--[[
    By GUID, not combat-log name: cross-realm names arrive as "Name-Realm" and
    never resolve to a unit. A secret GUID errors on compare, so it simply
    doesn't match.
]]
local POINTED_UNITS = { "target", "focus", "mouseover" }

local function HasGUID(unit, guid)
	local unitGUID = UnitGUID(unit)
	return ns.IsPlain(unitGUID) and unitGUID == guid
end

function ns.GetUnitByGUID(guid)
	if not ns.IsPlain(guid) or not guid then
		return nil
	end
	if HasGUID("player", guid) then
		return "player"
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		local unit = prefix .. i
		if UnitExists(unit) and HasGUID(unit, guid) then
			return unit
		end
	end
	for _, unit in ipairs(POINTED_UNITS) do
		if UnitExists(unit) and HasGUID(unit, guid) then
			return unit
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Durations
--------------------------------------------------------------------------------

--[[
    Trap: the client's duration strings (D_MINUTES) carry a |4 plural escape
    the UI expands only at render time; SendChatMessage silently drops a line
    still holding one. Resolving it lets the units come from the client's own
    localization. Slavic locales list a third form and get their rule.
]]
local function ResolvePlurals(text)
	return (
		text:gsub("(%d+)(%s*)|4([^;]*);", function(count, gap, body)
			local forms = {}
			for form in body:gmatch("[^:]+") do
				forms[#forms + 1] = form
			end
			if #forms == 0 then
				return count .. gap
			end

			local number = tonumber(count) or 0
			local pick
			if #forms >= 3 then
				local mod10, mod100 = number % 10, number % 100
				if mod10 == 1 and mod100 ~= 11 then
					pick = forms[1] -- 1, 21, 31...
				elseif mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
					pick = forms[2] -- 2-4, 22-24...
				else
					pick = forms[3]
				end
			else
				pick = (number == 1) and forms[1] or (forms[2] or forms[1])
			end
			return count .. gap .. pick
		end)
	)
end

--[[
    The largest whole unit, since durations run to round numbers. The hour
    rung stays for any caller: re-deriving the ladder elsewhere walks back into
    the plural-escape trap.
]]
local function FormatDuration(seconds)
	seconds = math.floor((seconds or 0) + 0.5)
	local template, count
	if seconds >= 3600 then
		template, count = D_HOURS, math.floor(seconds / 3600 + 0.5)
	elseif seconds >= 60 then
		template, count = D_MINUTES, math.floor(seconds / 60 + 0.5)
	else
		template, count = D_SECONDS, seconds
	end
	return ResolvePlurals(template:format(count))
end
ns.FormatDuration = FormatDuration

--------------------------------------------------------------------------------
-- Game Dropdowns in the Kit's Dress
--------------------------------------------------------------------------------

--[[
    Each time the list opens its background (the game's, or a skin's) goes
    clear with the plate under it; both come back when the game pools the frame.
]]
local function UndressDropdownList(frame)
	if frame.menuKitPlate then
		frame.menuKitPlate:Hide()
	end
	for region, alpha in pairs(frame.goodToGoHidden or {}) do
		region:SetAlpha(alpha)
	end
	frame.goodToGoHidden = nil
end

local function DressDropdownList(frame)
	frame.goodToGoHidden = frame.goodToGoHidden or {}
	local function Clear(region)
		if region and region.GetAlpha and not frame.goodToGoHidden[region] then
			frame.goodToGoHidden[region] = region:GetAlpha()
			region:SetAlpha(0)
		end
	end
	for _, region in ipairs({ frame:GetRegions() }) do
		if region.GetDrawLayer and region:GetDrawLayer() == "BACKGROUND" then
			Clear(region)
		end
	end
	Clear(frame.NineSlice)
	Clear(frame.backdrop)
	Clear(frame.Background)
	ns.MenuKit.AddPlate(frame)
end

function ns.SetupKitDropdown(dropdown, setup)
	dropdown:SetupMenu(function(owner, rootDescription, ...)
		setup(owner, rootDescription, ...)
		rootDescription:AddMenuAcquiredCallback(DressDropdownList)
		rootDescription:AddMenuReleasedCallback(UndressDropdownList)
	end)
end
