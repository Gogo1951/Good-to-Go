local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per WoW API the add-on depends on, scanned from across
    Features/ and Options/. Every API the code guards for existence (e.g.
    C_Bank.FetchPurchasedBankTabIDs) or reaches through a modern->legacy fallback gets a
    row of its own — modern and legacy listed separately — so the manifest stays
    one-to-one with the code's guards and the report shows exactly what each
    client provides.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnInfo",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnInfo) == "function"
		end,
	},
	{
		"C_AddOns.GetNumAddOns",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetNumAddOns) == "function"
		end,
	},
	-- The legacy import (Features/Core.lua) turns the add-ons this one replaces off, or on for one character to read them.
	{
		"C_AddOns.DisableAddOn",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.DisableAddOn) == "function"
		end,
	},
	{
		"C_AddOns.EnableAddOn",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.EnableAddOn) == "function"
		end,
	},
	-- The options' item lists ask whether a row's item is cached before naming it (Options/Options-Item-Lists.lua).
	{
		"C_Item.IsItemDataCachedByID",
		function()
			return type(C_Item) == "table" and type(C_Item.IsItemDataCachedByID) == "function"
		end,
	},
	-- Decides Season of Discovery's data folder (Data/Flavor.lua), which is only ever asked on Classic Era.
	{
		"C_Seasons.GetActiveSeason (Classic Era only)",
		function()
			return type(C_Seasons) == "table" and type(C_Seasons.GetActiveSeason) == "function"
		end,
	},
	--[[
	    C_Container is the container surface on all three target clients, so both
	    readers are probed there and nowhere else. Neither carries a legacy
	    fallback nor may be given one, so there is no legacy row to pair with
	    either.
	]]
	{
		"C_Container.GetContainerNumSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumSlots) == "function"
		end,
	},
	{
		"C_Container.GetContainerItemInfo",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function"
		end,
	},
	--[[
	    Every spell name the macros cast and the panels show, on every client:
	    without it no /cast line can be written.
	]]
	{
		"C_Spell.GetSpellName",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function"
		end,
	},
	-- The Forsaken Cannibalize line reads the spell's cooldown (Tools-Forsaken.lua).
	{
		"C_Spell.GetSpellCooldown",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function"
		end,
	},
	{
		"C_Map.GetBestMapForUnit",
		function()
			return type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function"
		end,
	},
	--[[
	    The route ns.OpenOptionsPanel docks the panel with
	    (Options/Options.lua). A client that does not provide it falls through
	    to AceConfigDialog, which opens a standalone floating window instead of
	    docking -- so a report where this row FAILs is the one that explains a
	    panel the player says opened in the wrong place.
	]]
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
		end,
	},
	--[[
	    A frame method, read off UIParent because every frame shares one
	    metatable. The Restocker window calls SetResizeBounds unconditionally as
	    it is built, so a FAIL here means that window errors when it opens.
	]]
	{
		"Frame:SetResizeBounds",
		function()
			return type(UIParent.SetResizeBounds) == "function"
		end,
	},
	{
		"IsInInstance",
		function()
			return type(IsInInstance) == "function"
		end,
	},
	--[[
	    All three load-bearing for the Restocker's entering-town reminder:
	    IsResting is the signal it keys off, UnitOnTaxi is what keeps a flight
	    path over a town from counting as arriving in one, and PlaySoundFile
	    plays the optional alert.
	]]
	{
		"IsResting",
		function()
			return type(IsResting) == "function"
		end,
	},
	{
		"UnitOnTaxi",
		function()
			return type(UnitOnTaxi) == "function"
		end,
	},
	{
		"PlaySoundFile",
		function()
			return type(PlaySoundFile) == "function"
		end,
	},
	{
		"C_Item.GetItemCount",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemCount) == "function"
		end,
	},
	{
		"C_Item.GetItemInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemQualityColor",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemQualityColor) == "function"
		end,
	},
	-- Validate Data: item existence, and the instant fields every item row carries.
	{
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	--[[
	    Called by ns.WarmItemCache (Options/Options-Item-Lists.lua): without it an
	    options item list can only show ids the client already cached, so the
	    rows sit on their loading text until something else pulls the data.
	]]
	{
		"C_Item.RequestLoadItemDataByID",
		function()
			return type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function"
		end,
	},
	-- Validate Data's other item columns.
	{
		"C_Item.GetItemSpell",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSpell) == "function"
		end,
	},
	{
		"C_Item.GetDetailedItemLevelInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetDetailedItemLevelInfo) == "function"
		end,
	},
	-- Validate Data's stat read goes through ns.GetItemStats, which takes whichever of the pair this client ships.
	{
		"C_Item.GetItemStats",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemStats) == "function"
		end,
	},
	{
		"GetItemStats (legacy)",
		function()
			return type(GetItemStats) == "function"
		end,
	},
	{
		"C_Item.GetItemClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemClassInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemSubClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function"
		end,
	},
	{
		"GetMacroIndexByName",
		function()
			return type(GetMacroIndexByName) == "function"
		end,
	},
	{
		"CreateMacro",
		function()
			return type(CreateMacro) == "function"
		end,
	},
	{
		"EditMacro",
		function()
			return type(EditMacro) == "function"
		end,
	},
	{
		"DeleteMacro",
		function()
			return type(DeleteMacro) == "function"
		end,
	},
	{
		"GetMacroBody",
		function()
			return type(GetMacroBody) == "function"
		end,
	},
	{
		"GetNumMacros",
		function()
			return type(GetNumMacros) == "function"
		end,
	},
	-- The Macros panel's Open Macros Window button calls it unguarded.
	{
		"MacroFrame_LoadUI",
		function()
			return type(MacroFrame_LoadUI) == "function"
		end,
	},
	--[[
	    The shims in Utilities that Forever needs: each client should PASS
	    exactly one side of every pair -- the namespaced reader on Forever, the
	    legacy global on Era and TBC.
	]]
	{
		"C_PetInfo.GetPetFoodTypes",
		function()
			return type(C_PetInfo) == "table" and type(C_PetInfo.GetPetFoodTypes) == "function"
		end,
	},
	{
		"GetPetFoodTypes (legacy)",
		function()
			return type(GetPetFoodTypes) == "function"
		end,
	},
	{
		"C_SkillInfo.GetNumSkillLines",
		function()
			return type(C_SkillInfo) == "table" and type(C_SkillInfo.GetNumSkillLines) == "function"
		end,
	},
	{
		"C_SkillInfo.GetSkillLineInfo",
		function()
			return type(C_SkillInfo) == "table" and type(C_SkillInfo.GetSkillLineInfo) == "function"
		end,
	},
	-- Forever reads a profession's rank by ID (Scanner-Character.lua); where this FAILs, the skill list is read by name.
	{
		"C_SkillInfo.GetSkillLineInfoByID",
		function()
			return type(C_SkillInfo) == "table" and type(C_SkillInfo.GetSkillLineInfoByID) == "function"
		end,
	},
	{
		"GetNumSkillLines (legacy)",
		function()
			return type(GetNumSkillLines) == "function"
		end,
	},
	{
		"GetSkillLineInfo (legacy)",
		function()
			return type(GetSkillLineInfo) == "function"
		end,
	},
	-- A collapsed profession header is opened to read its rank, then closed again (ns.ExpandSkillHeader); with neither route, a collapsed header's ranks go unread.
	{
		"C_SkillInfo.ExpandSkillHeader and CollapseSkillHeader, or the globals",
		function()
			local modern = type(C_SkillInfo) == "table"
				and type(C_SkillInfo.ExpandSkillHeader) == "function"
				and type(C_SkillInfo.CollapseSkillHeader) == "function"
			return modern or (type(ExpandSkillHeader) == "function" and type(CollapseSkillHeader) == "function")
		end,
	},
	-- The First Aid labels name their skill line through this on every client, and Era and TBC find a rank by it.
	{
		"C_TradeSkillUI.GetTradeSkillDisplayName",
		function()
			return type(C_TradeSkillUI) == "table" and type(C_TradeSkillUI.GetTradeSkillDisplayName) == "function"
		end,
	},
	{
		"C_QuestLog.GetNumQuestLogEntries",
		function()
			return type(C_QuestLog) == "table" and type(C_QuestLog.GetNumQuestLogEntries) == "function"
		end,
	},
	{
		"C_QuestLog.GetInfo",
		function()
			return type(C_QuestLog) == "table" and type(C_QuestLog.GetInfo) == "function"
		end,
	},
	{
		"GetNumQuestLogEntries (legacy)",
		function()
			return type(GetNumQuestLogEntries) == "function"
		end,
	},
	{
		"GetQuestLogTitle (legacy)",
		function()
			return type(GetQuestLogTitle) == "function"
		end,
	},
	{
		"C_MerchantFrame.GetItemInfo",
		function()
			return type(C_MerchantFrame) == "table" and type(C_MerchantFrame.GetItemInfo) == "function"
		end,
	},
	{
		"GetMerchantItemInfo (legacy)",
		function()
			return type(GetMerchantItemInfo) == "function"
		end,
	},
	--[[
	    The level cap behind the Leveling and Max Level modes (ns.GetMaxPlayerLevel
	    in Utilities), the smaller of these two, which all three clients ship.
	    Consumable Macros Context prints what each one answers.
	]]
	{
		"GetMaxPlayerLevel",
		function()
			return type(GetMaxPlayerLevel) == "function"
		end,
	},
	{
		"GetMaxLevelForPlayerExpansion",
		function()
			return type(GetMaxLevelForPlayerExpansion) == "function"
		end,
	},
	-- Forever's bank is its purchased tabs; Era and TBC read BANK_CONTAINER and the bank bags instead.
	{
		"C_Bank.FetchPurchasedBankTabIDs",
		function()
			return type(C_Bank) == "table" and type(C_Bank.FetchPurchasedBankTabIDs) == "function"
		end,
	},
	{
		"BANK_CONTAINER (legacy)",
		function()
			return type(BANK_CONTAINER) == "number"
		end,
	},
	{
		"C_UnitAuras.GetBuffDataByIndex",
		function()
			return type(C_UnitAuras) == "table" and type(C_UnitAuras.GetBuffDataByIndex) == "function"
		end,
	},
	{
		"C_Secrets.ShouldAurasBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldAurasBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.CanCompareUnitTokens",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.CanCompareUnitTokens) == "function"
		end,
	},
	{
		"C_Secrets.ShouldCooldownsBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldCooldownsBeSecret) == "function"
		end,
	},
	-- Behind ns.IsSecretValue, which answers false where it FAILs (Era and TBC).
	{
		"issecretvalue",
		function()
			return type(issecretvalue) == "function"
		end,
	},
	--[[
	    Behind ns.GetPlayerFullName, which a character is saved and shown under.
	    RegionalUniqueNamesEnabled is Forever's alone: where it FAILs (Era and
	    TBC) a character has the one name and UnitNameUnmodified is never asked.
	    A FAIL on Forever means characters are keyed by first name only again.
	]]
	{
		"RegionalUniqueNamesEnabled",
		function()
			return type(RegionalUniqueNamesEnabled) == "function"
		end,
	},
	{
		"UnitNameUnmodified",
		function()
			return type(UnitNameUnmodified) == "function"
		end,
	},
	--[[
	    The Readiness Report's surface. Every one of these is reached only when
	    its own switch is on, and nothing isolates a probe, so a missing one
	    stops the whole report -- and does it silently, since a client with
	    scriptErrors off swallows the error. A FAIL here is the fastest
	    explanation for "I turned that on and the report went quiet". The
	    exceptions are GetNumTalentTabs and UnitCharacterPoints, which the
	    probes reach through ns accessors that answer nil where the client lacks
	    them: they FAIL on Forever as expected, and their lines never show there.
	]]
	{
		"GetWeaponEnchantInfo",
		function()
			return type(GetWeaponEnchantInfo) == "function"
		end,
	},
	{
		"GetInventoryItemDurability",
		function()
			return type(GetInventoryItemDurability) == "function"
		end,
	},
	{
		"GetInventoryItemLink",
		function()
			return type(GetInventoryItemLink) == "function"
		end,
	},
	{
		"GetNumTalentTabs",
		function()
			return type(GetNumTalentTabs) == "function"
		end,
	},
	{
		"C_SpecializationInfo.GetSpecializationInfo",
		function()
			return type(C_SpecializationInfo) == "table"
				and type(C_SpecializationInfo.GetSpecializationInfo) == "function"
		end,
	},
	-- Asked only from Mists on, for the one specialization the Spec line names.
	{
		"C_SpecializationInfo.GetSpecialization",
		function()
			return type(C_SpecializationInfo) == "table" and type(C_SpecializationInfo.GetSpecialization) == "function"
		end,
	},
	{
		"UnitCharacterPoints",
		function()
			return type(UnitCharacterPoints) == "function"
		end,
	},
	{
		"UnitIsPVP",
		function()
			return type(UnitIsPVP) == "function"
		end,
	},
	{
		"C_Container.GetItemCooldown",
		function()
			return type(C_Container) == "table" and type(C_Container.GetItemCooldown) == "function"
		end,
	},
	-- Validate Data reads spells through these.
	{
		"C_Spell.RequestLoadSpellData",
		function()
			return type(C_Spell) == "table" and type(C_Spell.RequestLoadSpellData) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_Spell.IsSpellDataCached",
		function()
			return type(C_Spell) == "table" and type(C_Spell.IsSpellDataCached) == "function"
		end,
	},
	--[[
	    Validate Data's tooltip text (ns.GetTooltipLines in Utilities): Forever
	    reads the C_TooltipInfo pair, and Era and TBC a hidden scan tooltip,
	    probed through the GameTooltip methods it inherits so the check creates
	    nothing. Forever passes both, since its tooltips are built from that
	    same data.
	]]
	{
		"C_TooltipInfo.GetItemByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetItemByID) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetSpellByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetSpellByID) == "function"
		end,
	},
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	{
		"C_SpellBook.IsSpellInSpellBook",
		function()
			return type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellInSpellBook) == "function"
		end,
	},
	{
		"C_SpellBook.IsSpellKnown",
		function()
			return type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellKnown) == "function"
		end,
	},
	{
		"SecureCmdOptionParse",
		function()
			return type(SecureCmdOptionParse) == "function"
		end,
	},
	{
		"C_Timer.After",
		function()
			return type(C_Timer) == "table" and type(C_Timer.After) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	-- Restocker's load-bearing surface (merchant buying and bank restocking).
	{
		"GetMerchantNumItems",
		function()
			return type(GetMerchantNumItems) == "function"
		end,
	},
	{
		"GetMerchantItemLink",
		function()
			return type(GetMerchantItemLink) == "function"
		end,
	},
	{
		"GetMerchantItemID",
		function()
			return type(GetMerchantItemID) == "function"
		end,
	},
	{
		"BuyMerchantItem",
		function()
			return type(BuyMerchantItem) == "function"
		end,
	},
	{
		"UnitReaction",
		function()
			return type(UnitReaction) == "function"
		end,
	},
	{
		"GetNetStats",
		function()
			return type(GetNetStats) == "function"
		end,
	},
	{
		"C_Container.GetContainerNumFreeSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumFreeSlots) == "function"
		end,
	},
	{
		"C_Container.PickupContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.PickupContainerItem) == "function"
		end,
	},
	{
		"C_Container.SplitContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.SplitContainerItem) == "function"
		end,
	},
	{
		"C_Container.UseContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.UseContainerItem) == "function"
		end,
	},
	{
		"GetCursorInfo",
		function()
			return type(GetCursorInfo) == "function"
		end,
	},
	{
		"CursorHasItem",
		function()
			return type(CursorHasItem) == "function"
		end,
	},
	{
		"ClearCursor",
		function()
			return type(ClearCursor) == "function"
		end,
	},
	-- The Gold Reserve's floor is checked against this before every merchant purchase.
	{
		"GetMoney",
		function()
			return type(GetMoney) == "function"
		end,
	},
	-- The Restocker sorts bag slots by the family of what each holds (Restocker-Bags.lua).
	{
		"C_Item.GetItemFamily",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemFamily) == "function"
		end,
	},
	-- The mini-map icon, the options item rows and the Restock List's footer draw item icons through this.
	{
		"C_Item.GetItemIconByID",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemIconByID) == "function"
		end,
	},
	-- The rank text a Warlock's Healthstone /cast line carries (Smart-Spell.lua).
	{
		"C_Spell.GetSpellSubtext",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellSubtext) == "function"
		end,
	},
	--[[
	    The Forsaken Cannibalize line (Tools-Forsaken.lua): the target's creature
	    type, and the two C_Secrets questions asked before the type and the
	    cooldown are read. Where these FAIL, the line never shows.
	]]
	{
		"UnitCreatureType",
		function()
			return type(UnitCreatureType) == "function"
		end,
	},
	{
		"C_Secrets.ShouldUnitIdentityBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldUnitIdentityBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldSpellCooldownBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldSpellCooldownBeSecret) == "function"
		end,
	},
	-- The Class & Race panel's Night Elf header names the race through this.
	{
		"C_CreatureInfo.GetRaceInfo",
		function()
			return type(C_CreatureInfo) == "table" and type(C_CreatureInfo.GetRaceInfo) == "function"
		end,
	},
	--[[
	    The Inventory Report's way into item tooltips (Inventory-Report-Tooltip.lua):
	    Forever hands every item tooltip to a TooltipDataProcessor post-call,
	    and Era and TBC fire OnTooltipSetItem instead. Each client should PASS
	    one side; where both FAIL the tooltip block never shows.
	]]
	{
		"TooltipDataProcessor.AddTooltipPostCall",
		function()
			return type(TooltipDataProcessor) == "table" and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
		end,
	},
	{
		"GameTooltip OnTooltipSetItem (legacy)",
		function()
			return type(GameTooltip) == "table"
				and type(GameTooltip.HasScript) == "function"
				and GameTooltip:HasScript("OnTooltipSetItem") == true
		end,
	},
	--[[
	    The same two ways into spell tooltips (ns.AddSpellTooltipPostCall in
	    Features/Utilities.lua): the post-call above where the client has it,
	    else OnTooltipSetSpell. Where both FAIL, no spell tooltip line shows.
	]]
	{
		"GameTooltip OnTooltipSetSpell (legacy)",
		function()
			return type(GameTooltip) == "table"
				and type(GameTooltip.HasScript) == "function"
				and GameTooltip:HasScript("OnTooltipSetSpell") == true
		end,
	},
	-- The standing labels in the Restock List's reputation column (ns.GetStandingLabel).
	{
		"GetText",
		function()
			return type(GetText) == "function"
		end,
	},
	-- The Taint Log box's read and its two buttons.
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
})

--------------------------------------------------------------------------------
-- Consumable Macros Context
--------------------------------------------------------------------------------

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES = "The best tool for 'my macro didn't update' reports."
	.. " "
	.. "Best for 'a Buff Key keeps casting the same buff' reports: it records every cast of a spell Buff Duty offers."
	.. " "
	.. "Best for 'the page never fills in', 'a macro doesn't update' or 'the glow is wrong' reports."

--[[
    The spells the add-on gates on, for Consumable Macros Context's spell knowledge
    lines. A spell this client's data folder doesn't carry has a nil id and
    gets no line.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_SPELLS, {
	-- { spellID, label }
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureFood, "Conjure Food (Rank 1)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureWater, "Conjure Water (Rank 1)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureManaGem, "Conjure Mana Agate" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noRitualOfRefreshment, "Ritual of Refreshment" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noCreateHealthstone, "Create Healthstone (Minor)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noCreateSoulstone, "Create Soulstone (Minor)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noRitualOfSouls, "Ritual of Souls" },
	{ ns.CALL_PET_SPELL_ID, "Call Pet" },
	{ ns.FEED_PET_SPELL_ID, "Feed Pet" },
	{ ns.MEND_PET_SPELL_ID, "Mend Pet" },
	{ ns.REVIVE_PET_SPELL_ID, "Revive Pet" },
	{ ns.DISMISS_PET_SPELL_ID, "Dismiss Pet" },
	{ ns.SHADOWMELD_SPELL_ID, "Shadowmeld" },
	{ ns.CANNIBALIZE_SPELL_ID, "Cannibalize" },
	{ ns.RAPID_REGENERATION_SPELL_ID, "Rapid Regeneration" },
	{ ns.POISONS_SPELL_ID, "Poisons" },
	{ ns.STEALTH_SPELL_ID, "Stealth" },
	{ ns.DRUID_BEAR_FORM_SPELL_ID, "Bear Form" },
	{ ns.DRUID_DIRE_BEAR_FORM_SPELL_ID, "Dire Bear Form" },
	{ ns.DRUID_CAT_FORM_SPELL_ID, "Cat Form" },
	{ ns.GOBLIN_ENGINEER_SPELL_ID, "Goblin Engineer" },
})

--[[
    Existence/value reads only (same read-only contract as the API checks). The
    probe for "my macro does nothing" reports: every reason a macro can sit
    still, each with its current value -- a switch off, combat or the Macro
    window holding writes back, a full macro book, a body at the length cap, a
    class, race, level, group or target gate, a scroll buff already covered, a
    spell not known, a pet diet the add-on can't read, an item not loaded --
    then what the last scan picked and the spells the add-on gates on. Restocker Context covers the Restocker and the Inventory Report,
    Readiness Report the ready check, and Display Context the mini-map button.
]]

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- The keys of a set table that are switched on, sorted and comma-joined.
local function EnabledKeys(set)
	local keys = {}
	for key, value in pairs(set or {}) do
		if value then
			keys[#keys + 1] = tostring(key)
		end
	end
	table.sort(keys)
	return #keys > 0 and table.concat(keys, ", ") or "(none)"
end

local function ItemText(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	return string.format("%d (%s)", itemID, name or "name not loaded")
end

-- An aura expiration as the buff snapshot keeps it: nil absent, 0 no duration.
local function ExpirationText(expiration)
	if expiration == nil then
		return "off"
	end
	if expiration == 0 then
		return "on, no duration"
	end
	return string.format("on, %.0f s left", expiration - GetTime())
end

local function AppendCharacter(lines)
	local _, classToken = UnitClass("player")
	local _, raceToken = UnitRace("player")
	local _, instanceType = IsInInstance()
	lines[#lines + 1] = "-- Character --"
	lines[#lines + 1] = string.format(
		"Saved variables loaded: %s // Profile: %s",
		YesNo(ns.db),
		tostring(ns.db and ns.db:GetCurrentProfile())
	)
	lines[#lines + 1] = string.format(
		"Class: %s // Race: %s // Level: %s // Cached level: %s",
		tostring(classToken),
		tostring(raceToken),
		tostring(UnitLevel("player")),
		tostring(ns.cachedPlayerLevel)
	)

	-- The cap the Leveling and Max Level modes compare against, and what each reader answers.
	lines[#lines + 1] = string.format(
		"Max level: %s // GetMaxPlayerLevel: %s // GetMaxLevelForPlayerExpansion: %s",
		tostring(ns.GetMaxPlayerLevel()),
		tostring(GetMaxPlayerLevel and GetMaxPlayerLevel()),
		tostring(GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
	)

	-- The flags every class and race gate reads, set once at login (Scanner-Character.lua).
	lines[#lines + 1] = string.format(
		"Read as: Hunter %s, Druid %s, Mage %s, Warlock %s, Rogue %s, Night Elf %s, Forsaken %s",
		YesNo(ns.isHunter),
		YesNo(ns.isDruid),
		YesNo(ns.isMage),
		YesNo(ns.isWarlock),
		YesNo(ns.isRogue),
		YesNo(ns.isNightElf),
		YesNo(ns.isForsaken)
	)
	-- Until the login setup runs, every flag above reads "no" and no macro knows its spells.
	lines[#lines + 1] = string.format("Character setup run: %s", YesNo(ns.spellCache ~= nil))

	-- Every When to Use's checkboxes read the group context (ns.IsUseWhenActive).
	lines[#lines + 1] = string.format(
		"In group: %s // In raid: %s // Group context: %s",
		YesNo(IsInGroup()),
		YesNo(IsInRaid()),
		ns.GetGroupContext()
	)

	-- Zone-locked and arena-only items read the cached map and the instance type.
	lines[#lines + 1] = string.format(
		"Map: %s // Cached map: %s // Instance: %s // Resting: %s",
		tostring(C_Map.GetBestMapForUnit("player")),
		tostring(ns.cachedMapID),
		tostring(instanceType),
		YesNo(IsResting())
	)

	-- A friendly player target drops the scrolls and downranks the conjures to their level.
	lines[#lines + 1] = string.format(
		"Dead: %s // Ghost: %s // Target: %s // Friendly player target: %s",
		YesNo(UnitIsDead("player")),
		YesNo(UnitIsGhost("player")),
		YesNo(UnitExists("target")),
		YesNo(ns.HasFriendlyPlayerTarget())
	)

	--[[
	    The profession ranks the scanner's usability gates read (0 = unlearned).
	    Where they are read from the skill list by name, the read opens a
	    collapsed header and closes it again, unless the client can't.
	]]
	local byID = C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID
	local readBy = "by ID"
	if not byID then
		local collapsed = false
		for index = 1, ns.GetNumSkillLines() or 0 do
			local _, isHeader, isExpanded = ns.GetSkillLineInfo(index)
			if isHeader and not isExpanded then
				collapsed = true
				break
			end
		end
		readBy = string.format(
			"from the skill list by name, a header collapsed: %s, headers can open: %s",
			YesNo(collapsed),
			YesNo(ns.ExpandSkillHeader and ns.CollapseSkillHeader)
		)
	end
	lines[#lines + 1] = string.format(
		"Skills: First Aid %s // Alchemy %s // Engineering %s // read %s",
		tostring(ns.currentFirstAidSkill),
		tostring(ns.currentAlchemySkill),
		tostring(ns.currentEngineeringSkill),
		readBy
	)
end

--[[
    Every macro the add-on keeps, as it stands in the General tab. Feed Pet and
    Poisons build only for their class, so their switch alone never makes them.
]]
local CLASS_ONLY_MACROS = {
	["Feed Pet"] = " (Hunters only)",
	["Poisons"] = " (Rogues only)",
}

local function AppendMacroWriting(lines)
	local global = ns.db and ns.db.global
	lines[#lines + 1] = "-- Macro writing --"
	lines[#lines + 1] = string.format(
		"Macros switch: %s (off leaves every macro as it last was)",
		OnOff(global and global.macrosEnabled)
	)
	lines[#lines + 1] =
		string.format("In combat lockdown: %s (writes wait until combat ends)", YesNo(InCombatLockdown()))
	lines[#lines + 1] =
		string.format("Macro window open: %s (writes wait until it closes)", YesNo(MacroFrame and MacroFrame:IsShown()))
	-- The writes held for the macro window resume when it closes, a hook set once its add-on loads (Engine.lua).
	lines[#lines + 1] =
		string.format("Macro window add-on loaded: %s", YesNo(C_AddOns.IsAddOnLoaded("Blizzard_MacroUI")))
	--[[
	    An old add-on this one replaces, still running, rewrites the same macros
	    (ns.REPLACED_ADDONS). It is turned off at login, but runs on until the
	    player reloads.
	]]
	local replacedRunning = {}
	for _, folder in ipairs(ns.REPLACED_ADDONS) do
		if C_AddOns.IsAddOnLoaded(folder) then
			replacedRunning[#replacedRunning + 1] = folder
		end
	end
	lines[#lines + 1] = string.format(
		"Replaced add-ons still running: %s",
		#replacedRunning > 0 and table.concat(replacedRunning, ", ") or "(none)"
	)
	--[[
	    Macro names on action buttons are hidden by fading each button's name
	    text (Action-Button-Text.lua); a bar add-on that removes those texts
	    leaves nothing to fade.
	]]
	local nameTexts = 0
	for _, prefix in ipairs({
		"ActionButton",
		"MultiBarLeftButton",
		"MultiBarRightButton",
		"MultiBarBottomLeftButton",
		"MultiBarBottomRightButton",
		"MultiBar5Button",
		"MultiBar6Button",
		"MultiBar7Button",
	}) do
		for index = 1, 12 do
			if _G[prefix .. index .. "Name"] then
				nameTexts = nameTexts + 1
			end
		end
	end
	local firstName = _G.ActionButton1Name
	lines[#lines + 1] = string.format(
		"Macro names on buttons: %s // name texts found: %d of 96 // first button's text alpha: %s",
		OnOff(global and global.showMacroNames),
		nameTexts,
		tostring(firstName and firstName:GetAlpha())
	)
	-- The same room test ns.TryCreateMacro makes before it creates a macro (Writer.lua).
	local generalUsed = GetNumMacros() or 0
	local generalCap = MAX_ACCOUNT_MACROS or 120
	lines[#lines + 1] = string.format(
		"General macros: %d of %d used, %d kept free // room for a new macro: %s (a full book stops new macros)",
		generalUsed,
		generalCap,
		ns.MACRO_SLOT_CUSHION,
		YesNo((generalCap - generalUsed) > ns.MACRO_SLOT_CUSHION)
	)

	--[[
	    A body at the length cap has shed its optional lines (Body-Builder.lua's
	    trim), and the items a body uses show whether it still matches the
	    last scan's picks below.
	]]
	local typeNames = {}
	for typeName in pairs(ns.MACRO_CONFIG) do
		typeNames[#typeNames + 1] = typeName
	end
	table.sort(typeNames)
	for _, typeName in ipairs(typeNames) do
		local macroName = ns.MACRO_CONFIG[typeName].macro
		local state = "NOT WRITTEN"
		if (GetMacroIndexByName(macroName) or 0) > 0 then
			local body = GetMacroBody(macroName) or ""
			local itemIDs, seen = {}, {}
			for itemID in string.gmatch(body, "item:(%d+)") do
				if not seen[itemID] then
					seen[itemID] = true
					itemIDs[#itemIDs + 1] = itemID
				end
			end
			state = string.format(
				"written, %d of %d bytes, items: %s",
				#body,
				ns.MACRO_BODY_MAX_LENGTH,
				#itemIDs > 0 and table.concat(itemIDs, ", ") or "(none)"
			)
		end
		lines[#lines + 1] = string.format(
			"[%s] %s: %s, %s%s",
			ns.IsMacroEnabled(typeName) and "on " or "off",
			typeName,
			macroName,
			state,
			CLASS_ONLY_MACROS[typeName] or ""
		)
	end
end

--[[
    Each ticked scroll type: the best scroll the last scan's bags hold for it,
    by Scanner-Scrolls.lua's rules (class, Ignore List; never level), and the
    snapshot readings that say whether its buff is already covered -- the
    scroll's own buff, or a conflicting buff at least as large. While aura
    data is restricted the snapshot holds its last reading.
]]
local function AppendScrollTypes(lines, profile)
	local snapshot = ns.GetPlayerBuffSnapshot()
	lines[#lines + 1] = string.format("Well Fed now: %s", ExpirationText(snapshot.wellFedExpiration))
	if not (profile.useScrolls and profile.scrollTypes) then
		return
	end
	local counts = ns.scannedItemCounts or {}
	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local data = ns.SCROLL_DATA[scrollType]
		if profile.scrollTypes[scrollType] and data then
			local bestID, bestAmount = ns.FindBestScroll(scrollType, counts)
			local aura = snapshot.scrolls[scrollType] or {}
			lines[#lines + 1] = string.format(
				"  %s: best scroll in bags %s, amount %s // its buff %s // largest conflicting buff %s",
				tostring(scrollType),
				ItemText(bestID),
				tostring(bestAmount),
				ExpirationText(aura.expiration),
				tostring(aura.conflictAmount)
			)
		end
	end
end

-- A When to Use as saved: the contexts ticked, then the level filter.
local function UseWhenText(profile, prefix)
	local ticked = {}
	for _, context in ipairs(ns.GROUP_CONTEXTS) do
		if ns.IsGroupContextOn(profile[prefix .. "In"], context) then
			ticked[#ticked + 1] = context
		end
	end
	return (#ticked > 0 and table.concat(ticked, ",") or "none") .. "; " .. tostring(profile[prefix .. "Level"])
end

local function AppendChoices(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		return
	end
	local global = ns.db.global
	lines[#lines + 1] = "-- Choices that steer the picks --"
	lines[#lines + 1] = string.format(
		"Buff food: %s (%s) // in force now: %s",
		OnOff(profile.useBuffFood),
		UseWhenText(profile, "buffFood"),
		YesNo(ns.allowBuffFood)
	)

	-- What holds buff food back while it is on (Scanner-Inventory.lua), as the last scan read it.
	local targetingSelf = ns.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")
	lines[#lines + 1] = string.format(
		"Buff food held back by: Well Fed %s, targeting yourself %s, arena %s // aura data restricted now: %s",
		YesNo(ns.wellFedState),
		YesNo(targetingSelf),
		YesNo(select(2, IsInInstance()) == "arena"),
		YesNo(ns.AreAurasSecret())
	)
	lines[#lines + 1] = string.format(
		"Conjured first: %s (%s) // in force now: %s",
		OnOff(profile.useConjuredFirst),
		UseWhenText(profile, "conjuredFirst"),
		YesNo(ns.allowConjuredFirst)
	)
	-- Restock List last reads the list the Restocker has loaded, so it does nothing until that list is in.
	lines[#lines + 1] = string.format(
		"Restock List last: %s // in force now: %s // list it reads: %s",
		OnOff(profile.useRestockLast),
		YesNo(ns.allowRestockLast),
		tostring(ns.restockSettings and ns.restockSettings.currentList)
	)
	lines[#lines + 1] = string.format(
		"Scrolls: %s (%s) // types: %s // picked now: %s",
		OnOff(profile.useScrolls),
		UseWhenText(profile, "scrolls"),
		EnabledKeys(profile.scrollTypes),
		(ns.scrollOverrideIDs and #ns.scrollOverrideIDs > 0) and table.concat(ns.scrollOverrideIDs, ", ") or "(none)"
	)
	AppendScrollTypes(lines, profile)
	-- Tracked means every gate passes: the switch, its mode, the level the food needs, and a live pet of any class.
	lines[#lines + 1] = string.format(
		"Pet buff food: %s (%s) // types: %s // tracked now: %s // picked now: %s",
		OnOff(profile.usePetBuffFood),
		UseWhenText(profile, "petBuffFood"),
		EnabledKeys(profile.petBuffTypes),
		YesNo(ns.ShouldTrackPetFood()),
		tostring(ns.petBuffOverrideID)
	)
	lines[#lines + 1] = string.format(
		"Early re-application: %s (%s s)",
		OnOff(profile.earlyReapply),
		tostring(profile.earlyReapplyThreshold)
	)
	lines[#lines + 1] = string.format(
		"Healthstones in Health Potion: %s // Mana runes with Mana Gem: %s // Food and water in potion macros: %s",
		OnOff(profile.combineHealthstones),
		OnOff(profile.includeManaRunes),
		OnOff(profile.potionsUseFoodAndWater)
	)
	lines[#lines + 1] = string.format("Explosive clicks: %s", tostring(profile.explosivesClickMode))
	lines[#lines + 1] = string.format(
		"Ignore List: %d on this character, %d on Global // categories with an ignored item in bags: %s",
		CountKeys(profile.ignoreList),
		CountKeys(global.ignoreList),
		EnabledKeys(ns.scannedIgnoredTypes)
	)

	-- The cache lasts the session and is never saved, so it is built from this load's data folder.
	lines[#lines + 1] = string.format(
		"Item cache: %d items this session // data folder %s",
		ns.CountCachedItems(),
		tostring(ns.DATA_FOLDER)
	)

	--[[
	    A consumable in the last scan's bags with no cached record waits on
	    the server's item info: it competes in no macro until that arrives
	    (Scanner-Inventory.lua, Item-Cache.lua).
	]]
	local waiting = {}
	for itemID in pairs(ns.scannedItemCounts or {}) do
		local isScroll = ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[itemID]
		if not isScroll and ns.HasRawData(itemID) and not ns.GetCachedItemData(itemID) then
			waiting[#waiting + 1] = itemID
		end
	end
	table.sort(waiting)
	lines[#lines + 1] = string.format(
		"Bag consumables waiting on item info: %d%s",
		#waiting,
		#waiting > 0 and (" (" .. table.concat(waiting, ", ") .. ")") or ""
	)
end

local function CannibalizeCooldownText()
	local spellID = ns.CANNIBALIZE_SPELL_ID
	if not spellID then
		return "(no spell on this client)"
	end
	if ns.IsSpellCooldownSecret(spellID) then
		return "restricted right now"
	end
	local cooldown = C_Spell.GetSpellCooldown(spellID)
	if not (cooldown and cooldown.duration and cooldown.duration > 0) then
		return "ready"
	end
	return string.format("%.1f s left", cooldown.startTime + cooldown.duration - GetTime())
end

-- Whether any add-on has registered this slash command; the Druid Macro Helper bodies call /dmh.
local function SlashCommandExists(command)
	for key, value in pairs(_G) do
		if type(key) == "string" and string.sub(key, 1, 6) == "SLASH_" and type(value) == "string" then
			if string.lower(value) == command then
				return true
			end
		end
	end
	return false
end

--[[
    Pet diets arrive as names in the client's language, and Feed Pet reads them
    through ns.PET_DIET_MAP, whose non-English rows come from the DIET_* locale
    strings. An UNMAPPED diet is food Feed Pet never offers.
]]
local function PetDietText()
	if not UnitExists("pet") then
		return "(no pet out)"
	end
	local ok, diets = pcall(ns.GetPetFoodTypes)
	if not ok then
		return "ERROR: " .. tostring(diets)
	end
	local parts = {}
	for _, diet in ipairs(diets or {}) do
		parts[#parts + 1] = string.format("%s -> %s", tostring(diet), tostring(ns.PET_DIET_MAP[diet] or "UNMAPPED"))
	end
	return #parts > 0 and table.concat(parts, ", ") or "(none)"
end

--[[
    Each pet food in the last scan's bags and the rule it meets in Feed Pet's
    pick (Tools-Hunters-Pet-Food.lua): the Ignore List, the pet's diet, more
    than 10 levels under the pet, or an objective of a quest in the log.
]]
local function AppendPetFoods(lines)
	if not (ns.isHunter and UnitExists("pet")) then
		return
	end
	local petLevel = UnitLevel("pet") or 0
	local ok, diets = pcall(ns.GetPetFoodTypes)
	local dietSet = {}
	for _, diet in ipairs(ok and diets or {}) do
		local dietID = ns.PET_DIET_MAP[diet]
		if dietID then
			dietSet[dietID] = true
		end
	end
	local questSet = {}
	for index = 1, ns.GetNumQuestLogEntries() or 0 do
		local questID = ns.GetQuestLogQuestID(index)
		if questID then
			questSet[questID] = true
		end
	end
	local foodIDs = {}
	for itemID in pairs(ns.scannedItemCounts or {}) do
		if ns.PET_FOOD_DATA[itemID] then
			foodIDs[#foodIDs + 1] = itemID
		end
	end
	table.sort(foodIDs)
	if #foodIDs == 0 then
		lines[#lines + 1] = "Pet foods in bags: (none)"
		return
	end
	for _, itemID in ipairs(foodIDs) do
		local foodLevel, foodDiet, _, questIDs = unpack(ns.PET_FOOD_DATA[itemID])
		local held = false
		for _, questID in ipairs(questIDs or {}) do
			if questSet[questID] then
				held = true
			end
		end
		local verdict
		if ns.IsIgnored(itemID) then
			verdict = "on the Ignore List"
		elseif not dietSet[foodDiet] then
			verdict = "not in the pet's diet"
		elseif petLevel - foodLevel > 10 then
			verdict = "more than 10 levels under the pet"
		elseif held then
			verdict = "kept for a quest in the log"
		elseif foodLevel > petLevel then
			verdict = "above the pet's level (used only when nothing fits)"
		else
			verdict = "fits"
		end
		lines[#lines + 1] =
			string.format("Pet food in bags: %s, level %s: %s", ItemText(itemID), tostring(foodLevel), verdict)
	end
end

local function AppendClassAndRace(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		return
	end
	lines[#lines + 1] = "-- Class and race extras --"
	lines[#lines + 1] = string.format(
		"Stealth Eating: %s // Stealth name: %s // Shadowmeld name: %s",
		OnOff(profile.enableStealthEating),
		tostring(ns.stealthSpellName),
		tostring(ns.shadowmeldSpellName)
	)
	lines[#lines + 1] = string.format("Shadowmeld Drinking: %s", OnOff(profile.enableShadowmeldDrinking))
	lines[#lines + 1] = string.format(
		"Cannibalize: eating %s, drinking %s (restores mana on this client: %s) // name: %s",
		OnOff(profile.enableCannibalizeEating),
		OnOff(profile.enableCannibalizeDrinking),
		YesNo(ns.CANNIBALIZE_RESTORES_MANA),
		tostring(ns.cannibalizeSpellName)
	)
	-- Tools-Forsaken.lua is new in the TOCs, so a client updated while running lacks it until a restart.
	if ns.TargetIsCannibalizable then
		-- nil while the client restricts the target's identity (Forever, mid-fight), which the macro treats as no.
		local cannibalizable = ns.TargetIsCannibalizable()
		lines[#lines + 1] = string.format(
			"Cannibalize now: target Humanoid or Undead %s // cooldown %s",
			cannibalizable == nil and "restricted right now" or YesNo(cannibalizable),
			CannibalizeCooldownText()
		)
	else
		lines[#lines + 1] = "Cannibalize now: Tools-Forsaken.lua not loaded (restart the client)"
	end
	-- Rapid Regeneration exists only on WoW Forever (Tools-Troll.lua).
	if ns.RAPID_REGENERATION_SPELL_ID then
		lines[#lines + 1] = string.format(
			"Rapid Regeneration: eating %s // name: %s",
			OnOff(profile.enableRapidRegenerationEating),
			tostring(ns.rapidRegenerationSpellName)
		)
	end
	-- A buff-food pick takes Cannibalize's place in the eating macro (Tools-Forsaken.lua).
	local foodPick = ns.bestSelection and ns.bestSelection.Food
	lines[#lines + 1] = string.format("Food pick is buff food: %s", YesNo(foodPick and foodPick.isBuffFood))
	-- The macros write /dmh lines only while DruidMacroHelper is loaded (Integration-Druid-Macro-Helper.lua).
	lines[#lines + 1] = string.format(
		"Druid Macro Helper: %s // return form: %s // DruidMacroHelper loaded: %s // /dmh command present: %s",
		OnOff(profile.enableDruidMacroHelper),
		tostring(profile.druidReturnForm),
		YesNo(C_AddOns.IsAddOnLoaded("DruidMacroHelper")),
		YesNo(SlashCommandExists("/dmh"))
	)
	-- Best form first, as the integration picks it; with none known the standard body is written.
	local formSpellIDs = profile.druidReturnForm == "cat" and { ns.DRUID_CAT_FORM_SPELL_ID }
		or { ns.DRUID_DIRE_BEAR_FORM_SPELL_ID, ns.DRUID_BEAR_FORM_SPELL_ID }
	local returnFormName
	for _, spellID in ipairs(formSpellIDs) do
		if ns.KnowsAny({ { spellID } }) then
			returnFormName = C_Spell.GetSpellName(spellID)
			break
		end
	end
	lines[#lines + 1] = string.format(
		"Druid Macro Helper wraps: %s (Druids only) // return form known: %s",
		EnabledKeys(ns.DRUID_MACRO_HELPER_TYPES),
		tostring(returnFormName)
	)
	lines[#lines + 1] = string.format(
		"Pet: out %s, dead %s // dead-pet flag: %s // spells named: Call %s, Feed %s, Mend %s, Revive %s, Dismiss %s",
		YesNo(UnitExists("pet")),
		YesNo(UnitIsDead("pet")),
		YesNo(ns.petDeadDismissed),
		YesNo(ns.callPetSpellName),
		YesNo(ns.feedPetSpellName),
		YesNo(ns.mendPetSpellName),
		YesNo(ns.revivePetSpellName),
		YesNo(ns.dismissPetSpellName)
	)
	-- Feed Pet offers food by the pet's level, and the pet food buff decides whether buff food is wanted.
	local petBuffExpires = UnitExists("pet") and ns.GetPetFoodBuffExpiration()
	lines[#lines + 1] = string.format(
		"Pet level: %s // pet food buff: %s",
		tostring(UnitExists("pet") and UnitLevel("pet") or nil),
		petBuffExpires and string.format("on, %.0f s left", petBuffExpires - GetTime()) or "off"
	)
	lines[#lines + 1] = "Pet diets: " .. PetDietText()
	lines[#lines + 1] = "Feed Pet pick: " .. ItemText(ns.bestPetFoodID)
	-- Feed Pet's shape by the pet spells known (Tools-Hunters.lua): A has no food line at all.
	local feedPetTier = "C (every pet spell)"
	if not (ns.feedPetSpellName and ns.revivePetSpellName and ns.callPetSpellName and ns.dismissPetSpellName) then
		feedPetTier = "A (a Feed, Revive, Call or Dismiss Pet not known: tip only, no food)"
	elseif not ns.mendPetSpellName then
		feedPetTier = "B (no Mend Pet)"
	end
	lines[#lines + 1] = string.format("Feed Pet tier: %s (Hunters only)", feedPetTier)
	AppendPetFoods(lines)
	lines[#lines + 1] = string.format(
		"Poisons known: %s // main hand: %s -> %s // off hand: %s -> %s",
		YesNo(ns.POISONS_SPELL_ID and (ns.IsSpellKnown(ns.POISONS_SPELL_ID) or ns.IsPlayerSpell(ns.POISONS_SPELL_ID))),
		tostring(profile.mainHandPoisonGroup),
		ItemText((ns.GetBestPoisonForHand("main"))),
		tostring(profile.offHandPoisonGroup),
		ItemText((ns.GetBestPoisonForHand("off")))
	)
end

local function AppendSelection(lines)
	lines[#lines + 1] = "-- Best-item selection --"
	lines[#lines + 1] = string.format("bestFoodID: %s", tostring(ns.bestFoodID))
	lines[#lines + 1] = string.format("bestPetFoodID: %s", tostring(ns.bestPetFoodID))

	--[[
	    Per-category winners from the last ScanBags pass (ns.bestSelection is
	    the scanner's live best table). The read-out for "category X didn't
	    update" reports: it shows exactly what the scanner picked plus the
	    tiebreak inputs (value/price/count) the comparison ladder ordered on,
	    and the ranked topIDs for multi-use types, none of which bestFoodID
	    alone can reveal.
	]]
	local selection = ns.bestSelection
	if next(selection or {}) == nil then
		lines[#lines + 1] = "No scan has completed yet."
		return
	end
	local categories = {}
	for typeName in pairs(selection) do
		categories[#categories + 1] = typeName
	end
	table.sort(categories)
	for _, typeName in ipairs(categories) do
		local entry = selection[typeName]
		local detail = string.format(
			"id=%s value=%s price=%s count=%s",
			tostring(entry.id),
			tostring(entry.value),
			tostring(entry.price),
			tostring(entry.count)
		)
		if entry.topIDs and #entry.topIDs > 0 then
			detail = detail .. " topIDs=" .. table.concat(entry.topIDs, ",")
		end
		lines[#lines + 1] = string.format("%s: %s", typeName, detail)
	end
end

--[[
    The ignoreTarget and checkUnique flags each macro's resolver hands
    ns.GetSmartSpell (Tools-Mages.lua, Tools-Warlocks.lua), so the "casts:"
    line names what the macro would cast. A list not named here, like the
    food and water conjures, takes the defaults.
]]
local CONJURE_CAST_FLAGS = {
	MageCreateTable = { true },
	MageCreateManaGem = { true, true },
	WarlockCreateHealthstone = { false, true },
	WarlockCreateSoulwell = { true },
	WarlockCreateSoulstone = { true, false },
}

local function AppendSpells(lines)
	lines[#lines + 1] = "-- Spell knowledge --"
	for _, entry in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local spellID, label = entry[1], entry[2]
		if spellID then
			local known = ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)
			local name = C_Spell.GetSpellName(spellID)
			lines[#lines + 1] = string.format(
				"[%s] %s (%d)%s",
				known and "KNOWN" or "  -  ",
				label,
				spellID,
				name and (" = " .. name) or " (no name on this client)"
			)
		end
	end

	-- Each conjure ladder: how many of its ranks are known, and what the macros' /cast line would name now.
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Conjure ranks --"
	local listNames = {}
	for listName in pairs(ns.CONJURE_SPELLS) do
		listNames[#listNames + 1] = listName
	end
	table.sort(listNames)
	for _, listName in ipairs(listNames) do
		local list = ns.CONJURE_SPELLS[listName]
		local known = 0
		for _, row in ipairs(list) do
			if ns.IsSpellKnown(row[1]) or ns.IsPlayerSpell(row[1]) then
				known = known + 1
			end
		end
		local flags = CONJURE_CAST_FLAGS[listName] or {}
		local castName = ns.GetSmartSpell(list, flags[1], flags[2])
		lines[#lines + 1] =
			string.format("%s: %d of %d ranks known // casts: %s", listName, known, #list, tostring(castName))
	end
	-- A friendly player target below your level caps the rank of what you conjure for them (Smart-Spell.lua).
	lines[#lines + 1] = string.format(
		"Friendly player target: %s // target level: %s",
		YesNo(ns.HasFriendlyPlayerTarget()),
		tostring(UnitLevel("target"))
	)
end

function ns:BuildConnoisseurContextReport()
	local lines = { GetClientHeader(), "" }
	AppendCharacter(lines)
	lines[#lines + 1] = ""
	AppendMacroWriting(lines)
	lines[#lines + 1] = ""
	AppendChoices(lines)
	lines[#lines + 1] = ""
	AppendClassAndRace(lines)
	lines[#lines + 1] = ""
	AppendSelection(lines)
	lines[#lines + 1] = ""
	AppendSpells(lines)
	return (table.concat(lines, "\n"):gsub("|", "||"))
end

--------------------------------------------------------------------------------
-- Item Selection
--------------------------------------------------------------------------------

--[[
    The "why did it pick that?" read-out. For every category that goes through
    the scanner's ranking ladder, prints the winner and the runners-up it beat,
    each tagged with the RANKING_PRIORITY field that decided the pair (see
    Features/Macros-for-Consumables/Scanner/Scanner-Ranking.lua). Reads only what the last scan left behind;
    it never rescans, so the report can never disagree with the macros the
    player is actually looking at. Then every consumable in that scan's bags
    with the usability gate it meets, read from its cached record against the
    level, skills and map the scan reads.
]]

local function DescribeItem(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	if name then
		return string.format("%d (%s)", itemID, name)
	end
	return string.format("%d (name not cached)", itemID)
end

local function AppendCategoryLines(lines, typeName, entry, candidates)
	lines[#lines + 1] = string.format("%s: %s", typeName, DescribeItem(entry and entry.id))

	if entry and entry.id then
		lines[#lines + 1] = string.format(
			"    won with value=%s price=%s count=%s",
			tostring(entry.value),
			tostring(entry.price),
			tostring(entry.count)
		)
	end

	if entry and entry.topIDs and #entry.topIDs > 0 then
		lines[#lines + 1] = "    stacked /use order: " .. table.concat(entry.topIDs, ", ")
	end

	if not candidates or #candidates < 2 then
		return
	end

	for i = 2, #candidates do
		local candidate = candidates[i]
		lines[#lines + 1] = string.format(
			"    beat %s on %s (value=%s price=%s count=%s)",
			DescribeItem(candidate.id),
			candidate.decidedBy or "nothing (identical record)",
			tostring(candidate.value),
			tostring(candidate.price),
			tostring(candidate.count)
		)
	end
end

--[[
    The first usability gate a cached record fails, in the scan's order
    (Scanner-Inventory.lua), or nil when it passes them all.
]]
local function FailedGate(data, inArena)
	local playerLevel = ns.cachedPlayerLevel or 1
	if data.requiredLevel > playerLevel then
		return string.format("needs level %d (cached level %d)", data.requiredLevel, playerLevel)
	end
	local skills = {
		{ "First Aid", data.requiredFirstAid, ns.currentFirstAidSkill },
		{ "Alchemy", data.requiredAlchemy, ns.currentAlchemySkill },
		{ "Engineering", data.requiredEngineering, ns.currentEngineeringSkill },
	}
	for _, skill in ipairs(skills) do
		local required, current = skill[2] or 0, skill[3] or 0
		if required > 0 and required > current then
			return string.format("needs %s %d (read as %d)", skill[1], required, current)
		end
	end
	local spellID = data.requiredSpellID
	if spellID and not (ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)) then
		return string.format("needs spell %d, not known", spellID)
	end
	if data.zones and not (ns.cachedMapID ~= nil and data.zones[ns.cachedMapID] == true) then
		return string.format("zone-locked, not usable on cached map %s", tostring(ns.cachedMapID))
	end
	if data.arenaOnly and not inArena then
		return "arena only"
	end
	if inArena then
		local itemType = data.itemType
		local isFoodOrWater = itemType == "food" or itemType == "water" or itemType == "foodwater"
		if itemType == "potion" or (isFoodOrWater and not data.arenaUsable) then
			return "blocked in an arena"
		end
	end
	return nil
end

--[[
    A consumable with no cached record waits on the server's item info and
    competes nowhere; one that passes every gate names each macro that took it,
    and each that turned it away (buff food held back, runes not added, no heal
    value). An ignored item competes nowhere and only counts as carried, for
    the Readiness Report.
]]
local function AppendBagGates(lines)
	local inArena = select(2, IsInInstance()) == "arena"
	local itemIDs = {}
	for itemID in pairs(ns.scannedItemCounts or {}) do
		if not (ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[itemID]) and ns.HasRawData(itemID) then
			itemIDs[#itemIDs + 1] = itemID
		end
	end
	table.sort(itemIDs)
	if #itemIDs == 0 then
		lines[#lines + 1] = "(no consumables in the last scan's bags)"
		return
	end
	for _, itemID in ipairs(itemIDs) do
		local data = ns.GetCachedItemData(itemID)
		local verdict
		if not data then
			verdict = "no current cached record (waits on item info, competes in nothing)"
		else
			local failed = FailedGate(data, inArena)
			local ignored = ns.IsIgnored(itemID)
			if failed then
				verdict = failed .. (ignored and " // on the Ignore List" or "")
			else
				local took, refused = {}, {}
				for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS or {}) do
					if definition.itemTypes and definition.itemTypes[data.itemType] then
						if not definition.accepts or definition.accepts(data) then
							took[#took + 1] = definition.typeName
						else
							refused[#refused + 1] = definition.typeName
						end
					end
				end
				verdict = string.format(
					"%s %s%s",
					ignored and "usable but on the Ignore List, counts as carried for" or "usable, competes in",
					#took > 0 and table.concat(took, ", ") or "(none)",
					#refused > 0 and (" // turned away by " .. table.concat(refused, ", ")) or ""
				)
			end
		end
		lines[#lines + 1] = string.format(
			"%s x%d [%s]: %s",
			DescribeItem(itemID),
			ns.scannedItemCounts[itemID] or 0,
			type(data) == "table" and tostring(data.itemType) or "?",
			verdict
		)
	end
end

function ns:BuildSelectionReport()
	local lines = { GetClientHeader(), "" }

	local selection = ns.bestSelection
	local candidates = ns.diagnosticCandidates

	if next(selection or {}) == nil then
		lines[#lines + 1] = "No scan has completed yet. Trigger one by looting an item or changing zone."
		-- What holds every scan back (Engine.lua's ns.UpdateMacros, and the login setup before it).
		lines[#lines + 1] = string.format(
			"In combat lockdown: %s // Macro window open: %s // Character setup run: %s",
			YesNo(InCombatLockdown()),
			YesNo(MacroFrame and MacroFrame:IsShown()),
			YesNo(ns.spellCache ~= nil)
		)
		return table.concat(lines, "\n")
	end

	--[[
	    Candidate retention starts when the tools are enabled, so a report run
	    before the next scan has winners but no runners-up. Say so rather than
	    letting an empty list read as "nothing else was in the running."
	]]
	local retained = false
	for _, list in pairs(candidates) do
		if #list > 0 then
			retained = true
			break
		end
	end

	lines[#lines + 1] = string.format("allowBuffFood (live scan preference): %s", tostring(ns.allowBuffFood))
	lines[#lines + 1] = string.format("allowConjuredFirst (live scan preference): %s", tostring(ns.allowConjuredFirst))
	lines[#lines + 1] = string.format("allowRestockLast (live scan preference): %s", tostring(ns.allowRestockLast))
	lines[#lines + 1] = string.format("Runners-up kept (these tools on): %s", YesNo(ns.diagnostics.enabled))
	if not retained then
		lines[#lines + 1] = ""
		lines[#lines + 1] =
			"No candidates were retained: the last scan ran before these tools were enabled. Trigger a rescan (loot something, or change zone) and run this again to see the runners-up."
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Ranked by the selection ladder --"

	local typeNames = {}
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS or {}) do
		if definition.itemTypes then
			typeNames[#typeNames + 1] = definition.typeName
		end
	end
	table.sort(typeNames)

	for _, typeName in ipairs(typeNames) do
		AppendCategoryLines(lines, typeName, selection[typeName], candidates[typeName])
	end

	--[[
	    The custom definitions own their whole update and resolve their item
	    outside the ladder (the Hunter pet-food scan, the Rogue poison walk),
	    so they have no candidate list to show. Naming them keeps the report
	    honest about what it does and does not cover.
	]]
	local customNames = {}
	for _, definition in ipairs(ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS or {}) do
		customNames[#customNames + 1] = definition.typeName
	end
	table.sort(customNames)

	if #customNames > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "-- Resolved outside the ladder (no candidate ranking) --"
		for _, typeName in ipairs(customNames) do
			lines[#lines + 1] = string.format("%s: resolved by its own builder at macro-update time", typeName)
		end
		lines[#lines + 1] = string.format("Feed Pet current pick: %s", DescribeItem(ns.bestPetFoodID))
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Bag consumables and the gate each one meets --"
	AppendBagGates(lines)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    The Readiness Report as it would print right now, without waiting for a
    ready check. Read-only: it asks the same probes the report asks and prints
    nothing to chat.

    The report has two silences that look identical from a chat window, "you
    are ready" and "it never ran", and only one of them is a bug. Rendering it
    on demand separates them in one button press, and the switch states below
    say which lines were even eligible to speak.

    Color escapes are stripped: reports are plain text, and a |cff pasted into
    a bug report is noise.
]]
local READINESS_SWITCHES = {
	"readinessFlask",
	"readinessWellFed",
	"readinessPetWellFed",
	"readinessScrolls",
	"readinessSoulstone",
	"readinessMainHandBuff",
	"readinessOffHandBuff",
	"readinessExpiring",
	"readinessHealthstone",
	"readinessManaGem",
	"readinessHealingPotion",
	"readinessManaPotion",
	"readinessBandages",
	"readinessDurability",
	"readinessSpec",
	"readinessPvP",
	"readinessQuestionableGear",
}

function ns:BuildReadinessDiagnosticReport()
	local lines = { GetClientHeader(), "" }

	local reports = ns.db and ns.db.global
	if not reports then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = string.format("Report enabled: %s", tostring(reports.readinessReportEnabled))
	-- An arena drops the buff, expiring and missing-item clauses, and an arena or battleground the PvP entry.
	lines[#lines + 1] = string.format("Instance type: %s", tostring(select(2, IsInInstance())))
	-- A ready check can only start in a group, so solo the report never runs.
	lines[#lines + 1] = string.format(
		"In group: %s // In raid: %s // Members: %d",
		tostring(IsInGroup()),
		tostring(IsInRaid()),
		GetNumGroupMembers() or 0
	)
	-- While aura data is restricted (Forever, mid-fight) a ready check prints nothing at all.
	lines[#lines + 1] = string.format("Aura data restricted now: %s", tostring(ns.AreAurasSecret()))

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- What it would print now --"

	-- The report walks auras, and on Forever a restricted aura read throws.
	if ns.AreAurasSecret() then
		lines[#lines + 1] = "(aura data is restricted right now -- run this report again out of combat)"
	else
		-- A probe that throws must still leave a report, or this button shows nothing at all.
		local ok, body = pcall(ns.BuildReadinessLines, select(2, IsInInstance()) == "arena")
		if not ok then
			lines[#lines + 1] = "ERROR: " .. tostring(body)
		elseif not body then
			lines[#lines + 1] = "(nothing -- this character has nothing the report would name)"
		else
			lines[#lines + 1] = ns.L["READINESS_TITLE"]
			for _, line in ipairs(body) do
				lines[#lines + 1] = line
			end
		end

		--[[
		    The gates behind each line besides its own switch
		    (Readiness-Report.lua): a line whose gate is closed stays silent
		    even while what it checks is missing. Item lines stay silent before
		    the first bag scan, and count an ignored item as carried.
		]]
		local profile = ns.db.profile
		local okGates, gates = pcall(function()
			local mainHandMissing, offHandMissing = ns.GetMissingWeaponBuffs()
			local gemsCarried = 0
			for gemID in pairs(ns.MANA_GEMS) do
				gemsCarried = gemsCarried + (ns.scannedItemCounts[gemID] or 0)
			end
			local snapshot = ns.GetPlayerBuffSnapshot()
			-- A ticked type counts as covered by its own scroll buff or by any conflicting buff.
			local scrollCoverage = {}
			for scrollType, enabled in pairs(profile.scrollTypes or {}) do
				if enabled then
					local entry = snapshot.scrolls[scrollType]
					scrollCoverage[#scrollCoverage + 1] = string.format(
						"%s %s",
						tostring(scrollType),
						YesNo(entry and (entry.expiration or entry.conflictAmount))
					)
				end
			end
			table.sort(scrollCoverage)
			-- What each item line reads from the last scan: an ignored item counts as carried.
			local function Carried(typeName)
				local entry = ns.bestSelection and ns.bestSelection[typeName]
				if not entry then
					return "not scanned"
				end
				if entry.id then
					return tostring(entry.id)
				end
				return ns.scannedIgnoredTypes[typeName] and "only ignored ones" or "none"
			end
			local lowestPercent, lowestSlot
			for slot = 1, 19 do
				local current, maximum = GetInventoryItemDurability(slot)
				if current and maximum and maximum > 0 then
					local percent = current / maximum * 100
					if not lowestPercent or percent < lowestPercent then
						lowestPercent, lowestSlot = percent, slot
					end
				end
			end
			return {
				-- The report's own checks: each switch together with every gate the report puts on it.
				string.format(
					"Asked at all: Well Fed %s, Scrolls %s, Soulstone %s, Mana Gem %s",
					YesNo(ns.ReadinessAsksWellFed(profile, reports)),
					YesNo(ns.ReadinessAsksScrolls(profile, reports)),
					YesNo(ns.ReadinessAsksSoulstone(reports)),
					YesNo(ns.ReadinessAsksManaGem(reports))
				),
				string.format(
					"Well Fed: buff food %s, When to Use holds %s // Scrolls: %s, When to Use holds %s",
					OnOff(profile.useBuffFood),
					YesNo(ns.IsUseWhenActive(profile, "buffFood")),
					OnOff(profile.useScrolls),
					YesNo(ns.IsUseWhenActive(profile, "scrolls"))
				),
				-- Any Well Fed aura or pet food buff counts, however little of it is left.
				string.format(
					"Well Fed now: %s // pet food buff now: %s // scroll types covered: %s // scrolls in bags to use: %s",
					ExpirationText(snapshot.wellFedExpiration),
					ExpirationText(ns.GetPetFoodBuffExpiration()),
					#scrollCoverage > 0 and table.concat(scrollCoverage, ", ") or "(none ticked)",
					(ns.scrollOverrideIDs and #ns.scrollOverrideIDs > 0) and table.concat(ns.scrollOverrideIDs, ", ")
						or "(none)"
				),
				-- An empty flask or elixir table reads as covered, so the Flask line stays silent.
				string.format(
					"Flask: TBC or later %s, has one %s, flask ids %d, elixir ids %d // Pet Well Fed: tracked %s",
					YesNo(ns.EXPANSION >= 2),
					YesNo(ns.HasFlaskOrElixirs()),
					CountKeys(ns.FLASK_BUFF_IDS),
					CountKeys(ns.ELIXIR_BUFF_IDS),
					YesNo(ns.ShouldTrackPetFood())
				),
				string.format(
					"Soulstone: Warlock %s, knows Create Soulstone %s, one up in the group %s, stones on cooldown %s",
					YesNo(ns.isWarlock),
					YesNo(ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulstone)),
					YesNo(ns.GroupHasSoulstone()),
					YesNo(ns.SoulstonesOnCooldown())
				),
				string.format(
					"Weapon buffs missing: main hand %s, off hand %s // Shaman in party (covers the main hand) %s",
					YesNo(mainHandMissing),
					YesNo(offHandMissing),
					YesNo(ns.PartyHasClass("SHAMAN"))
				),
				string.format(
					"Warlock in group (Healthstone) %s // knows Conjure Mana Gem %s // uses mana %s // talent tabs %s",
					YesNo(ns.GroupHasClass("WARLOCK")),
					YesNo(ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateManaGem)),
					YesNo(ns.PlayerUsesMana()),
					tostring(ns.GetNumTalentTabs and ns.GetNumTalentTabs())
				),
				string.format(
					"Bags scanned: %s // categories with an ignored item: %s // Mana Gems carried: %d",
					YesNo(next(ns.bestSelection or {}) ~= nil),
					EnabledKeys(ns.scannedIgnoredTypes),
					gemsCarried
				),
				string.format(
					"Carried at the last scan: Healthstone %s, Health Potion %s, Mana Potion %s, Bandage %s",
					Carried("Healthstone"),
					Carried("Health Potion"),
					Carried("Mana Potion"),
					Carried("Bandage")
				),
				-- Expiring skips an aura whose whole duration fits inside the window.
				string.format(
					"Buffs inside the expiring window now: %d // lowest durability now: %s // slots under the threshold: %d",
					#ns.GetExpiringBuffs(reports.readinessExpiringThreshold or 0),
					lowestPercent and string.format("%.0f%% (slot %d)", lowestPercent, lowestSlot)
						or "(nothing damageable)",
					#ns.GetDamagedGear(reports.readinessDurabilityThreshold or 0)
				),
				string.format(
					"Non-combat gear worn now: %d // item ids on the non-combat list: %d",
					#ns.GetQuestionableEquipment(),
					CountKeys(ns.QUESTIONABLE_EQUIPMENT)
				),
				-- The spec reads nil until the talent data loads and the points nil when none are unspent; the line drops a nil.
				string.format(
					"Spec: %s // unspent talent points: %s // PvP flagged: %s",
					tostring(ns.GetCurrentSpecializationLabel()),
					tostring(ns.GetUnspentTalentPoints()),
					YesNo(ns.IsPvPFlagged())
				),
			}
		end)
		lines[#lines + 1] = ""
		lines[#lines + 1] = "-- Each line's other gates --"
		if okGates then
			for _, line in ipairs(gates) do
				lines[#lines + 1] = line
			end
		else
			lines[#lines + 1] = "ERROR: " .. tostring(gates)
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Category switches --"
	for _, key in ipairs(READINESS_SWITCHES) do
		lines[#lines + 1] = string.format("[%s] %s", reports[key] and "ON " or "   ", key)
	end
	-- Damaged Gear names a slot only under the durability percent, Expiring a buff only inside the window.
	lines[#lines + 1] = string.format(
		"Thresholds: durability under %s%% // expiring within %s s",
		tostring(reports.readinessDurabilityThreshold),
		tostring(reports.readinessExpiringThreshold)
	)

	local text = table.concat(lines, "\n")
	-- Item links (Damaged / Non-Combat Gear) survive the color strip; escaping them makes the paste plain text.
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|", "||"))
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
    A conjure row's name as the macros' /cast line writes it (Smart-Spell.lua's
    CastName): a row carrying a rank number adds the client's own rank text, so
    the name is right in every locale.
]]
local function ConjureCastName(row)
	local name = C_Spell.GetSpellName(row[1])
	if not name then
		return nil
	end
	if row[3] then
		local subtext = C_Spell.GetSpellSubtext(row[1])
		if subtext and subtext ~= "" then
			return name .. "(" .. subtext .. ")"
		end
	end
	return name
end

local function SortedKeys(tbl)
	local keys = {}
	for key in pairs(tbl or {}) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return keys
end

--[[
    Every record Consumable Macros shows or matches by the name this client gives it,
    for the Localization tab's Game Names report, each read through the call
    its feature makes. A record this client's folder doesn't carry has a nil id
    and gets no row. Spells and items load late, so their rows add request,
    which the report calls and polls. The Blizzard UI labels are globals, so
    each one's id is its own name; the reputation standings come in the
    player's gender, as the Restock List's column shows them.
]]
local nameLookups = {}

local function AddLookup(constant, kind, id, lookup, request)
	if id ~= nil then
		nameLookups[#nameLookups + 1] =
			{ constant = constant, kind = kind, id = id, lookup = lookup, request = request }
	end
end

local function AddSpellLookup(constant, spellID, lookup)
	AddLookup(constant, "spell", spellID, lookup or function()
		return C_Spell.GetSpellName(spellID)
	end, function()
		C_Spell.RequestLoadSpellData(spellID)
	end)
end

local function AddItemLookup(constant, itemID, lookup)
	AddLookup(constant, "item", itemID, lookup or function()
		return (C_Item.GetItemInfo(itemID))
	end, function()
		C_Item.RequestLoadItemDataByID(itemID)
	end)
end

local function AddUiLabel(constant, lookup)
	AddLookup(constant, "uiLabel", constant, lookup or function()
		return _G[constant]
	end)
end

-- Spells cast or named by their own constant: the stealths, Cannibalize, the pet and Druid form spells.
for _, constant in ipairs({
	"CALL_PET_SPELL_ID",
	"CANNIBALIZE_SPELL_ID",
	"DISMISS_PET_SPELL_ID",
	"DRUID_BEAR_FORM_SPELL_ID",
	"DRUID_CAT_FORM_SPELL_ID",
	"DRUID_DIRE_BEAR_FORM_SPELL_ID",
	"FEED_PET_SPELL_ID",
	"MEND_PET_SPELL_ID",
	"POISONS_SPELL_ID",
	"RAPID_REGENERATION_SPELL_ID",
	"REVIVE_PET_SPELL_ID",
	"SHADOWMELD_SPELL_ID",
	"STEALTH_SPELL_ID",
}) do
	AddSpellLookup(constant, ns[constant])
end
AddSpellLookup("WELL_FED_SPELL_ID", ns.WELL_FED_SPELL_ID, ns.GetWellFedName)

-- The spells the "you don't know <spell>" tips name (Runtime.lua).
for _, key in ipairs(SortedKeys(ns.MISSING_SPELL_MESSAGE_IDS)) do
	AddSpellLookup("MISSING_SPELL_MESSAGE_IDS." .. key, ns.MISSING_SPELL_MESSAGE_IDS[key])
end

-- Every conjure rank, as the /cast line names it.
for _, listName in ipairs(SortedKeys(ns.CONJURE_SPELLS)) do
	for index, row in ipairs(ns.CONJURE_SPELLS[listName]) do
		AddSpellLookup(string.format("CONJURE_SPELLS.%s[%d]", listName, index), row[1], function()
			return ConjureCastName(row)
		end)
	end
end

--[[
    The skill lines the profession gates find in the skill list on Era and TBC
    (Scanner-Character.lua), First Aid through the accessor the options read.
]]
AddLookup("FIRST_AID_SKILL_LINE_ID", "skillLine", ns.FIRST_AID_SKILL_LINE_ID, ns.GetFirstAidName)
for _, constant in ipairs({ "ALCHEMY_SKILL_LINE_ID", "ENGINEERING_SKILL_LINE_ID" }) do
	local skillLineID = ns[constant]
	AddLookup(constant, "skillLine", skillLineID, function()
		return C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID)
	end)
end

-- The Class & Race panel's headers.
for _, constant in ipairs({ "NIGHT_ELF_RACE_ID", "TROLL_RACE_ID", "UNDEAD_RACE_ID" }) do
	local raceID = ns[constant]
	AddLookup(constant, "race", raceID, function()
		local info = C_CreatureInfo.GetRaceInfo(raceID)
		return info and info.raceName
	end)
end
for _, classToken in ipairs({ "DRUID", "ROGUE" }) do
	AddLookup("LOCALIZED_CLASS_NAMES_MALE." .. classToken, "class", classToken, function()
		return LOCALIZED_CLASS_NAMES_MALE[classToken]
	end)
end

--[[
    The runes the Mana Gem texts name, the pet foods the Pet Food Buffs toggles
    name, and each poison group by its first item.
]]
AddItemLookup("DEMONIC_RUNE_ITEM_ID", ns.DEMONIC_RUNE_ITEM_ID)
AddItemLookup("DARK_RUNE_ITEM_ID", ns.DARK_RUNE_ITEM_ID)
for _, itemID in ipairs(SortedKeys(ns.PET_BUFF_FOODS)) do
	AddItemLookup(string.format("PET_BUFF_FOODS[%d]", itemID), itemID)
end
for _, groupID in ipairs(SortedKeys(ns.POISON_GROUP_BASE_ITEMS)) do
	AddItemLookup(
		string.format("POISON_GROUP_BASE_ITEMS[%s]", tostring(groupID)),
		ns.POISON_GROUP_BASE_ITEMS[groupID],
		function()
			return ns.GetPoisonGroupName(groupID)
		end
	)
end

--[[
    The staples window's rows named by an item rather than a label. Which tier
    names the row follows the character's level and list, so every tier item of
    the category's ladder gets a row, each once, and the report checks every name
    the window can show for any character. A ladder this client carries no tiers
    for adds nothing. Every other ladder's tiers follow, each item once: the
    staples tooltip, the upgrade chat lines and the Upgrade Example name them.
    So does the reminders' Example, by ns.SAMPLE_RESTOCK_ITEM_ID.
]]
local tierSeen = {}
for _, category in ipairs(ns.GetStarterCategories()) do
	if not category.label then
		for index, tier in ipairs(category.chain.tiers) do
			local itemID = tier[2]
			if not tierSeen[itemID] then
				tierSeen[itemID] = true
				AddItemLookup(string.format("STARTER_LIST_CATEGORIES.%s[%d]", category.key, index), itemID)
			end
		end
	end
end
for chainIndex, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS or {}) do
	for tierIndex, tier in ipairs(chain.tiers) do
		local itemID = tier[2]
		if not tierSeen[itemID] then
			tierSeen[itemID] = true
			AddItemLookup(string.format("CONSUMABLE_UPGRADE_CHAINS[%d].tiers[%d]", chainIndex, tierIndex), itemID)
		end
	end
end
AddItemLookup("SAMPLE_RESTOCK_ITEM_ID", ns.SAMPLE_RESTOCK_ITEM_ID)

-- The Readiness Report Example's non-combat gear: the lowest item id on the list.
local firstQuestionableID
for itemID in pairs(ns.QUESTIONABLE_EQUIPMENT or {}) do
	if not firstQuestionableID or itemID < firstQuestionableID then
		firstQuestionableID = itemID
	end
end
AddItemLookup(string.format("QUESTIONABLE_EQUIPMENT[%s]", tostring(firstQuestionableID)), firstQuestionableID)

--[[
    Blizzard UI labels the add-on shows (the weapon slots, the scroll stats, the
    pop-up buttons, the macro tab the macros-ready message names) and the error
    texts its handlers match a UI_ERROR_MESSAGE against, and UNKNOWNOBJECT,
    which marks a character name not yet known.
]]
for _, constant in ipairs({
	"GENERAL_MACROS",
	"MAINHANDSLOT",
	"SECONDARYHANDSLOT",
	"SPELL_STAT1_NAME",
	"SPELL_STAT2_NAME",
	"SPELL_STAT3_NAME",
	"SPELL_STAT4_NAME",
	"SPELL_STAT5_NAME",
	"YES",
	"NO",
	"CANCEL",
	"ERR_ITEM_WRONG_ZONE",
	"SPELL_FAILED_TARGETS_DEAD",
	"UNKNOWNOBJECT",
}) do
	AddUiLabel(constant)
end
for _, standing in ipairs(ns.REPUTATION_STANDINGS) do
	if standing.value > 0 then
		AddUiLabel("FACTION_STANDING_LABEL" .. standing.value, function()
			return ns.GetStandingLabel(standing.value)
		end)
	end
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, nameLookups)

-- Shared with Message Length (Message-Length-Macros-for-Consumables.lua), which writes the same /cast names.
ns.DiagnosticConjureCastName = ConjureCastName
ns.DiagnosticSortedKeys = SortedKeys

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per data file, and one report row per entry on the Data tab
    (Diagnostics/Options-Diagnostics.lua). Each entry's label is the
    table-name part of its file name, so ns.DataSourceFileName can name the
    file this client's folder built. Each source names the static table on ns
    and its kind: "spell" or "item" for ids the client can look up, "other"
    for ids no client API reads, which report their row count. Ids are reached
    through rowId(key, row) over the table's pairs, or through collect(tbl)
    for a table not keyed by the id it holds, which returns { id, key, row }
    entries, each id once. Adding a data file adds an entry here, and the
    panel and the validator pick it up with no second list.
]]
local function KeyIsId(key)
	return key
end

local function KeyValue(key)
	return key
end

--[[
    A collect function from a walk over the table: walk(tbl, add) calls
    add(id, key, row) for every id it finds, and an id found twice is kept
    once.
]]
local function Collector(walk)
	return function(tbl)
		local entries, seen = {}, {}
		walk(tbl, function(id, key, row)
			if id ~= nil and not seen[id] then
				seen[id] = true
				entries[#entries + 1] = { id = id, key = key, row = row }
			end
		end)
		return entries
	end
end

local CollectValues = Collector(function(tbl, add)
	for key, id in pairs(tbl) do
		add(id, key, id)
	end
end)

-- One field of every row, by index for row arrays and by name for keyed rows.
local function CollectColumn(field)
	return Collector(function(tbl, add)
		for key, row in pairs(tbl) do
			add(row[field], key, row)
		end
	end)
end

-- Every id in a table whose values are lists of ids.
local CollectListValues = Collector(function(tbl, add)
	for key, list in pairs(tbl) do
		for _, id in ipairs(list) do
			add(id, key, list)
		end
	end
end)

local CollectUpgradeTierItems = Collector(function(chains, add)
	for index, chain in ipairs(chains) do
		for _, tier in ipairs(chain.tiers) do
			add(tier[2], index, tier)
		end
	end
end)

local CollectRecipeReagents = Collector(function(recipes, add)
	for index, recipe in ipairs(recipes) do
		for _, reagent in ipairs(recipe[2]) do
			add(reagent[1], index, reagent)
		end
	end
end)

local function CollectScrollColumn(field)
	return Collector(function(scrollData, add)
		for scrollType, data in pairs(scrollData) do
			for _, row in ipairs(data.items) do
				add(row[field], scrollType, row)
			end
		end
	end)
end

local CollectScrollConflictSpells = Collector(function(scrollData, add)
	for scrollType, data in pairs(scrollData) do
		for spellID in pairs(data.conflictSpells) do
			add(spellID, scrollType, data)
		end
	end
end)

local CollectConjureSpells = Collector(function(conjureSpells, add)
	for listName, spellList in pairs(conjureSpells) do
		for _, entry in ipairs(spellList) do
			add(entry[1], listName, entry)
		end
	end
end)

--[[
    Game-IDs-{Game}.lua's single-id constants hold the id itself rather than a
    table, so each kind's constants are validated by name through these lists:
    the collect reads ns[name], and DATA_CONSTANT names the constant on its row.
]]
ns.DIAGNOSTIC_SPELL_ID_CONSTANTS = {
	"CALL_PET_SPELL_ID",
	"CANNIBALIZE_SPELL_ID",
	"DISMISS_PET_SPELL_ID",
	"DRUID_BEAR_FORM_SPELL_ID",
	"DRUID_CAT_FORM_SPELL_ID",
	"DRUID_DIRE_BEAR_FORM_SPELL_ID",
	"FEED_PET_SPELL_ID",
	"GLOBAL_COOLDOWN_SPELL_ID",
	"GOBLIN_ENGINEER_SPELL_ID",
	"MEND_PET_SPELL_ID",
	"POISONS_SPELL_ID",
	"RAPID_REGENERATION_SPELL_ID",
	"REVIVE_PET_SPELL_ID",
	"SHADOWMELD_SPELL_ID",
	"SHOOT_SPELL_ID",
	"STEALTH_SPELL_ID",
	"WELL_FED_SPELL_ID",
}

ns.DIAGNOSTIC_ITEM_ID_CONSTANTS = {
	"DARK_RUNE_ITEM_ID",
	"DEMONIC_RUNE_ITEM_ID",
	"SAMPLE_RESTOCK_ITEM_ID",
}

--[[
    The IDs no lookup kind reads: Game Names checks the skill lines' and the
    races' names instead, the Call Pet flyout's is counted only, and
    SOD_FIRST_SPELL_ID is a threshold, the lowest spell ID the season's
    abilities use, not one spell.
]]
ns.DIAGNOSTIC_OTHER_ID_CONSTANTS = {
	"ALCHEMY_SKILL_LINE_ID",
	"CALL_PET_FLYOUT_ID",
	"ENGINEERING_SKILL_LINE_ID",
	"FIRST_AID_SKILL_LINE_ID",
	"NIGHT_ELF_RACE_ID",
	"SOD_FIRST_SPELL_ID",
	"TROLL_RACE_ID",
	"UNDEAD_RACE_ID",
}

local CollectConstants = Collector(function(names, add)
	for _, name in ipairs(names) do
		add(ns[name], name, name)
	end
end)

local CONSTANT_COLUMN = { "DATA_CONSTANT", KeyValue }

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	-- { label, sources = { { table, kind, rowId or collect, dataColumns } } }
	{
		label = "Bandages",
		sources = { { table = "BANDAGES", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Conjure-Spells",
		sources = {
			{ table = "CONJURE_SPELLS", kind = "spell", collect = CollectConjureSpells },
			{ table = "MISSING_SPELL_MESSAGE_IDS", kind = "spell", collect = CollectValues },
		},
	},
	{
		label = "Conjured-Items",
		sources = {
			{ table = "CONJURED_ITEM_IDS_BY_SPELL", kind = "spell", rowId = KeyIsId },
			{ table = "CONJURED_ITEM_IDS_BY_SPELL", kind = "item", collect = CollectListValues },
		},
	},
	{
		label = "Consumable-Upgrade-Paths",
		sources = { { table = "CONSUMABLE_UPGRADE_CHAINS", kind = "item", collect = CollectUpgradeTierItems } },
	},
	{
		label = "Elixirs",
		sources = {
			{ table = "FLASK_BUFF_IDS", kind = "spell", rowId = KeyIsId },
			{ table = "ELIXIR_BUFF_IDS", kind = "spell", rowId = KeyIsId },
		},
	},
	{
		label = "Explosives",
		sources = {
			{ table = "EXPLOSIVES", kind = "item", rowId = KeyIsId },
			{ table = "EXPLOSIVES", kind = "spell", collect = CollectColumn(4) },
		},
	},
	{
		label = "Food-and-Water",
		sources = { { table = "FOOD_AND_WATER", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Game-IDs",
		sources = {
			{
				table = "DIAGNOSTIC_SPELL_ID_CONSTANTS",
				kind = "spell",
				collect = CollectConstants,
				dataColumns = { CONSTANT_COLUMN },
			},
			{
				table = "DIAGNOSTIC_ITEM_ID_CONSTANTS",
				kind = "item",
				collect = CollectConstants,
				dataColumns = { CONSTANT_COLUMN },
			},
			{ table = "PET_BUFF_FOODS", kind = "item", rowId = KeyIsId },
			{ table = "PET_BUFF_FOODS", kind = "spell", collect = CollectColumn(1) },
			{ table = "DIAGNOSTIC_OTHER_ID_CONSTANTS", kind = "other" },
			{ table = "CANNIBALIZE_CREATURE_TYPE_IDS", kind = "other" },
		},
	},
	{
		label = "Healthstones",
		sources = { { table = "HEALTHSTONES", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Macro-Default-Items",
		sources = { { table = "MACRO_DEFAULT_ITEM_IDS", kind = "item", collect = CollectValues } },
	},
	{
		label = "Mana-Gems",
		sources = {
			{ table = "MANA_GEMS", kind = "item", rowId = KeyIsId },
			{ table = "MANA_RUNES", kind = "item", rowId = KeyIsId },
		},
	},
	{
		label = "Pet-Foods",
		sources = { { table = "PET_FOOD_DATA", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Poison-Recipes",
		sources = {
			{ table = "POISON_RECIPES", kind = "item", collect = CollectColumn(1) },
			{ table = "POISON_RECIPES", kind = "item", collect = CollectRecipeReagents },
		},
	},
	{
		label = "Poisons",
		sources = {
			{ table = "POISON_DATA", kind = "item", rowId = KeyIsId },
			{ table = "POISON_GROUP_BASE_ITEMS", kind = "item", collect = CollectValues },
		},
	},
	{
		label = "Potions",
		sources = { { table = "POTIONS", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Questionable-Equipment",
		sources = { { table = "QUESTIONABLE_EQUIPMENT", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Scrolls",
		sources = {
			{ table = "SCROLL_DATA", kind = "item", collect = CollectScrollColumn(1) },
			{ table = "SCROLL_DATA", kind = "spell", collect = CollectScrollColumn(2) },
			{ table = "SCROLL_DATA", kind = "spell", collect = CollectScrollConflictSpells },
		},
	},
	{
		label = "Soulstones",
		sources = {
			{ table = "SOULSTONES", kind = "item", rowId = KeyIsId },
			{ table = "SOULSTONE_BUFF_SPELL_IDS", kind = "spell", collect = CollectValues },
		},
	},
	{
		label = "Well-Fed-Buffs",
		sources = {
			{ table = "WELL_FED_BUFF_IDS", kind = "spell", rowId = KeyIsId },
			{ table = "WELL_FED_ICON_IDS", kind = "other" },
		},
	},
})
