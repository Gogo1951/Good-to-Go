local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
	WoW's binding system reads only globals, so the binding costs two: Bindings.xml can only call a global
	function, and the Key Bindings list labels a binding with the BINDING_NAME_<name> global matching its
	name attribute. Bindings.xml itself is found at the add-on root by the client and is never listed in the
	TOC.

	The name attribute is also what the client saves a player's key against, so a renamed binding comes back
	unbound for everyone who had set it unless their keys are moved over (ns.MigrateSpellbookBinding).
]]

BINDING_NAME_GOODTOGO_TOGGLE_SPELLBOOK = L["BINDING_TOGGLE_PAGE"]

--[[
	MIGRATION (remove after 2026-12-03): run at login. A key still bound to the binding's name before the GtG
	name moves to the current one. Bindings are locked in combat, so a /reload mid-fight tries again next login.
]]
function ns.MigrateSpellbookBinding()
	if InCombatLockdown() then
		return
	end
	local keys = { GetBindingKey("MACROSPELLBOOK_TOGGLE") }
	if not keys[1] then
		return
	end
	for _, key in ipairs(keys) do
		SetBinding(key, "GOODTOGO_TOGGLE_SPELLBOOK")
	end
	SaveBindings(GetCurrentBindingSet())
end

-- Opens or closes the page's own window (ns.ToggleSpellbookPage, Spellbook-Window.lua).
function GoodToGo_ToggleSpellbook()
	if ns.ToggleSpellbookPage then
		ns.ToggleSpellbookPage()
	end
end
