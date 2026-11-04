local _, ns = ...
local L = ns.L

--[[
    The Restock List's reputation wording: a required standing's label, its
    entry in the standings menu, and the Rep column's explanation.

    Loads before Restocker-Window-Columns.lua, whose column definitions hold
    the Rep column's tooltip body from load.
]]

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

--[[
    A required-reputation standing's label, by its reaction code. No requirement
    is our own word; a standing is the client's, in the player's gender, picked
    the way the reputation pane picks it.
]]
function ns.GetStandingLabel(reaction)
	if not reaction or reaction == 0 then
		return ns.L["RESTOCKER_REPUTATION_ANY"]
	end
	return GetText("FACTION_STANDING_LABEL" .. reaction, UnitSex("player"))
end

-- The standings themselves are Data/Data.lua's; these two format them.
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS

local function ReputationStandingByValue(value)
	value = value or 0
	for _, standing in ipairs(REPUTATION_STANDINGS) do
		if standing.value == value then
			return standing
		end
	end
	return REPUTATION_STANDINGS[1] -- default to "Any"
end

-- Menu label, e.g. "Honored  (10% off)"
local function ReputationMenuText(standing)
	local label = ns.GetStandingLabel(standing.value)
	if standing.discount and standing.discount > 0 then
		return string.format(L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"], label, standing.discount)
	end
	return label
end

-- The Rep column's explanation, naming the four standings by the client's own labels.
local function ReputationTooltipBody()
	local labels = {}
	for index = 2, #REPUTATION_STANDINGS do
		labels[#labels + 1] = ns.GetStandingLabel(REPUTATION_STANDINGS[index].value)
	end
	return string.format(L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"], unpack(labels))
end

ns.RestockReputationStandingByValue = ReputationStandingByValue
ns.RestockReputationMenuText = ReputationMenuText
ns.RestockReputationTooltipBody = ReputationTooltipBody
