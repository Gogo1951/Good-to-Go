local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
	The binding system reads only globals: Bindings.xml calls a global function, and the Key Bindings list reads
	BINDING_NAME_<name>. The client saves keys against the name attribute, so renaming it unbinds every player.
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

function GoodToGo_ToggleSpellbook()
	if ns.ToggleSpellbookPage then
		ns.ToggleSpellbookPage()
	end
end
