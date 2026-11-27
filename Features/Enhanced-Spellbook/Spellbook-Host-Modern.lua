local ADDON_NAME, ns = ...

local ICON_ADDON = ns.ICON_ADDON

local SpellbookTabs = ns.SpellbookTabs

SpellbookTabs:RegisterTab(ADDON_NAME, {
	name = ns.L["TAB_ENHANCED_SPELLBOOK"],
	description = ns.L["SPELLBOOK_TAB_DESCRIPTION"],
	hint = { ns.L["TOOLTIP_KEY_CLICK"], ns.L["MENU_OPEN_SPELLBOOK"] },
	icon = ICON_ADDON,
	onClick = ns.ToggleSpellbookWindow,
	isSelected = ns.IsSpellbookWindowShown,
})

ns.OnSpellbookWindowToggled(function()
	SpellbookTabs:RequestSync()
end)

-- Not in combat, where hiding the protected book is blocked.
function ns.CloseGameSpellbook()
	if PlayerSpellsFrame and PlayerSpellsFrame:IsShown() and not InCombatLockdown() then
		HideUIPanel(PlayerSpellsFrame)
	end
end

function ns.SyncSpellbookHost()
	SpellbookTabs:RequestSync()
end
