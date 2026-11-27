local _, ns = ...

--------------------------------------------------------------------------------
-- Position
--------------------------------------------------------------------------------

local DEFAULT_X, DEFAULT_Y = 192, 160

local TOP_RIGHT = "TOPRIGHT"

local function RestorePosition(anchor)
	local point = ns.db.global.buffWindow.point
	anchor:ClearAllPoints()
	if point and point.corner == TOP_RIGHT then
		anchor:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", point[1], point[2])
	elseif point then
		-- MIGRATION (remove after 2026-11-29): a top-left corner saved before; ns.MigrateBuffDutyPosition moves it.
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", point[1], point[2])
	else
		anchor:SetPoint("TOPRIGHT", UIParent, "CENTER", DEFAULT_X, DEFAULT_Y)
	end
end
ns.RestoreBuffDutyPosition = RestorePosition

-- The top-right corner, so the window grows left and down and its close button stays where the player put it.
function ns.SaveBuffDutyPosition(anchor)
	ns.db.global.buffWindow.point = { anchor:GetRight(), anchor:GetTop(), corner = TOP_RIGHT }
end

function ns.HasSavedBuffDutyPosition()
	return ns.db ~= nil and ns.db.global.buffWindow.point ~= nil
end

-- Out of combat only: the anchor is protected in combat.
function ns.ResetBuffDutyPosition()
	if InCombatLockdown() then
		return
	end
	ns.db.global.buffWindow.point = nil
	ns.ApplyBuffDutySettings()
end

--[[
    MIGRATION (remove after 2026-11-29): the window used to save its top-left
    corner. Once it has a size, that becomes the top-right corner the same
    window stands at, so the first redraw after the update leaves it where it
    was.
]]
function ns.MigrateBuffDutyPosition(anchor)
	local point = ns.db.global.buffWindow.point
	if point and point.corner ~= TOP_RIGHT then
		ns.db.global.buffWindow.point = { point[1] + anchor:GetWidth(), point[2], corner = TOP_RIGHT }
		RestorePosition(anchor)
	end
end
