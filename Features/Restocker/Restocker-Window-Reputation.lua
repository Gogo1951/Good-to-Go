local _, ns = ...
local L = ns.L

-- Loads before Restocker-Window-Columns.lua, whose column definitions read the Rep tooltip at load.

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

-- No requirement is our own word; a standing is the client's, in the player's gender.
function ns.GetStandingLabel(reaction)
	if not reaction or reaction == 0 then
		return L["RESTOCKER_REPUTATION_ANY"]
	end
	return GetText("FACTION_STANDING_LABEL" .. reaction, UnitSex("player"))
end

local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS

local function ReputationStandingByValue(value)
	value = value or 0
	for _, standing in ipairs(REPUTATION_STANDINGS) do
		if standing.value == value then
			return standing
		end
	end
	return REPUTATION_STANDINGS[1]
end

-- Menu label: the standing, and its discount for the row's right side ("10% Off"), or nil.
local function ReputationMenuText(standing)
	local label = ns.GetStandingLabel(standing.value)
	if standing.discount and standing.discount > 0 then
		return label, string.format(L["RESTOCKER_REPUTATION_DISCOUNT"], standing.discount)
	end
	return label
end

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
