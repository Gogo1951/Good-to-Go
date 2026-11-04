local _, ns = ...

--[[
    Where the Buff Window stands: restoring its saved corner onto the anchor
    frame Buff-Window-Frame.lua creates, saving it after a drag, and moving a
    position saved the old way.
]]

--------------------------------------------------------------------------------
-- Position
--------------------------------------------------------------------------------

-- Where the window's top-right corner sits until it is first dragged: a little right of and above the middle of the screen.
local DEFAULT_X, DEFAULT_Y = 190, 160

local TOP_RIGHT = "TOPRIGHT"

local function RestorePosition(anchor)
	local point = ns.db.global.buffWindow.point
	anchor:ClearAllPoints()
	if point and point.corner == TOP_RIGHT then
		anchor:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", point[1], point[2])
	elseif point then
		-- MIGRATION (remove after 2026-11-29): a top-left corner saved before; ns.MigrateBuffWindowPosition moves it.
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", point[1], point[2])
	else
		anchor:SetPoint("TOPRIGHT", UIParent, "CENTER", DEFAULT_X, DEFAULT_Y)
	end
end
ns.RestoreBuffWindowPosition = RestorePosition

--[[
    Saved as the top-right corner, so a window that grows or shrinks with the
    list keeps its title bar's close button where the player put it: the
    window grows left and down from it.
]]
function ns.SaveBuffWindowPosition(anchor)
	ns.db.global.buffWindow.point = { anchor:GetRight(), anchor:GetTop(), corner = TOP_RIGHT }
end

--[[
    MIGRATION (remove after 2026-11-29): the window used to save its top-left
    corner. Once it has a size, that becomes the top-right corner the same
    window stands at, so the first redraw after the update leaves it where it
    was.
]]
function ns.MigrateBuffWindowPosition(anchor)
	local point = ns.db.global.buffWindow.point
	if point and point.corner ~= TOP_RIGHT then
		ns.db.global.buffWindow.point = { point[1] + anchor:GetWidth(), point[2], corner = TOP_RIGHT }
		RestorePosition(anchor)
	end
end
