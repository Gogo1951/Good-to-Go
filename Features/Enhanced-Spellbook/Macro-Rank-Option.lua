local _, ns = ...
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local StoreSetting = ns.StoreMacroSetting
local MacroDefault = ns.MacroDefault
local NO_SLOTS = ns.NO_SLOTS

-- Not a resurrection, whose dead friend is never the player.
local function TargetsLivingFriend(macro)
	return macro.target == "help" and macro.kind ~= "resurrect"
end
ns.TargetsLivingFriend = TargetsLivingFriend

local function TargetsFriendOrAnyone(macro)
	return TargetsLivingFriend(macro) or macro.target == "exists"
end

-- Also where the right-click spell has more than one rank known (Arcane Brilliance for Arcane Intellect).
function ns.OffersTargetRank(macro)
	local function ranked(ranks)
		return ranks ~= nil and #ranks > 1
	end
	return not macro.rank
		and TargetsFriendOrAnyone(macro)
		and (ranked(macro.ranks) or (ns.RightClickSpell(macro) ~= nil and ranked(macro.rightClickRanks)))
end

-- Unknown ranks count here but can't be chosen. A rank's own macro is fixed to its rank, so offers no choice.
function ns.OffersFixedRank(macro)
	return not macro.rank and macro.ranks ~= nil
end

-- nil when the saved rank isn't among the known ranks.
local function FixedRankEntry(macro)
	local id = macro.rankID or (ns.OffersFixedRank(macro) and SpellSettings("fixedRank")[SettingsKey(macro)])
	for _, rank in ipairs(id and macro.ranks or NO_SLOTS) do
		if rank.id == id then
			return rank
		end
	end
	return nil
end

-- "Rank 3", as this client words it
function ns.FixedRank(macro)
	if macro.rank then
		return macro.rank
	end
	local rank = FixedRankEntry(macro)
	return rank and rank.text
end

function ns.FixedRankID(macro)
	local rank = FixedRankEntry(macro)
	return rank and rank.id
end

-- A fixed rank's text, "targetRank", or nil for the highest rank.
function ns.AbilityRank(macro)
	return ns.IsOptionOn(macro, "targetRank") and "targetRank" or ns.FixedRank(macro)
end

--[[
	A fixed rank is saved by spell ID, not text. "targetRank" is stored explicitly unless the whole choice is the
	kind's default, so a fixed rank stays fixed when Dynamic Rank later becomes the default.
]]
function ns.SetAbilityRank(macro, choice)
	local isTarget = choice == "targetRank"
	local isDefault = (choice == nil or isTarget) and isTarget == (MacroDefault(macro, "targetRank") and true or false)
	if isDefault then
		StoreSetting(macro, "targetRank", nil)
	else
		StoreSetting(macro, "targetRank", isTarget)
	end
	local id
	for _, rank in ipairs(choice and choice ~= "targetRank" and macro.ranks or NO_SLOTS) do
		if rank.text == choice then
			id = rank.id
		end
	end
	SpellSettings("fixedRank")[SettingsKey(macro)] = id
end
