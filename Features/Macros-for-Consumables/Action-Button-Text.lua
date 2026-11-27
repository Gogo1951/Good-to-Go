local _, ns = ...

--------------------------------------------------------------------------------
-- Macro-Name Visibility
--------------------------------------------------------------------------------

--[[
    Hidden by default: players who see macro names on buttons blame this add-on.
    Alpha survives the SetText calls on an action change, so one pass holds until
    the font strings are rebuilt; PLAYER_ENTERING_WORLD re-applies it. The nil
    guard is for bar add-ons that remove a font string.
]]
local ACTION_BAR_PREFIXES = {
	"ActionButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
}

function ns.ApplyMacroNameVisibility()
	local alpha = (ns.db and ns.db.global and ns.db.global.showMacroNames) and 1 or 0
	for _, prefix in ipairs(ACTION_BAR_PREFIXES) do
		for i = 1, 12 do
			local name = _G[prefix .. i .. "Name"]
			if name then
				name:SetAlpha(alpha)
			end
		end
	end
end

function ns.ToggleMacroNames(value)
	ns.db.global.showMacroNames = value
	ns.ApplyMacroNameVisibility()
end
