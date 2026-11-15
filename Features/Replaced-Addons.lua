local _, ns = ...
local L = ns.L

--[[
    Turning off the add-ons Good to Go replaces (ns.REPLACED_ADDONS) when one
    is running at login, and the reload offered afterward. Features/Core.lua
    calls ns.TurnOffReplacedAddons at login and ns.OfferReplacedReload once the
    player is in the world.
]]

--------------------------------------------------------------------------------
-- Replaced Add-ons
--------------------------------------------------------------------------------

--[[
    An add-on Good to Go replaces (ns.REPLACED_ADDONS) that runs alongside it
    rewrites the same macros, each undoing the other. So whenever one is
    running at login, it is turned off for every character and the player is
    offered a reload, since the old copy runs on until then. This outlives the
    settings import (Features/Legacy-Migration.lua): a player can install Good
    to Go, or turn the old add-on back on, long after the import is gone.
]]
-- Titles of the old add-ons turned off this session.
local turnedOff = {}
-- The legacy import adds the rest it turns off (Features/Legacy-Migration.lua).
ns.turnedOffAddOnTitles = turnedOff

local function AddOnTitle(folder)
	return C_AddOns.GetAddOnMetadata(folder, "Title") or folder
end

local function JoinTitles(titles)
	return table.concat(titles, L["LIST_SEPARATOR"])
end

-- Both shared with the legacy import (Features/Legacy-Migration.lua).
ns.AddOnTitle = AddOnTitle
ns.JoinAddOnTitles = JoinTitles

function ns.TurnOffReplacedAddons()
	for _, folder in ipairs(ns.REPLACED_ADDONS) do
		if C_AddOns.IsAddOnLoaded(folder) then
			C_AddOns.DisableAddOn(folder)
			turnedOff[#turnedOff + 1] = AddOnTitle(folder)
		end
	end
end

StaticPopupDialogs.GOODTOGO_REPLACED_RELOAD = {
	text = L["POPUP_REPLACED_RELOAD"],
	button1 = L["POPUP_REPLACED_RELOAD_ACCEPT"],
	button2 = L["POPUP_REPLACED_LATER"],
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Asked once the player is in the world, after the welcome line.
function ns.OfferReplacedReload()
	if #turnedOff > 0 then
		StaticPopup_Show("GOODTOGO_REPLACED_RELOAD", JoinTitles(turnedOff))
	end
end
