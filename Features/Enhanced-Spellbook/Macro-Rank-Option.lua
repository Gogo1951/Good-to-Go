local _, ns = ...
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local StoreSetting = ns.StoreMacroSetting
local MacroDefault = ns.MacroDefault
local NO_SLOTS = ns.NO_SLOTS

--[[
	A page macro's ability rank: whether it offers Target Rank or a fixed rank, the rank it is fixed to, and
	the choice of one among the highest rank, Target Rank and a fixed rank.
]]

--[[
	Whether a spell can be cast on a living friend (not a resurrection, whose dead friend is never the player)
	or on anyone, which is what Target Rank needs (ns.OffersTargetRank).
]]
local function TargetsLivingFriend(macro)
	return macro.target == "help" and macro.kind ~= "resurrect"
end
ns.TargetsLivingFriend = TargetsLivingFriend

local function TargetsFriendOrAnyone(macro)
	return TargetsLivingFriend(macro) or macro.target == "exists"
end

--[[
	A friendly spell with more than one rank known offers "targetRank", and so does one whose right-click
	spell has (Arcane Brilliance, right-clicking for Arcane Intellect), which takes its ranks the same way.
]]
function ns.OffersTargetRank(macro)
	local function ranked(ranks)
		return ranks ~= nil and #ranks > 1
	end
	return not macro.rank
		and TargetsFriendOrAnyone(macro)
		and (ranked(macro.ranks) or (ns.RightClickSpell(macro) ~= nil and ranked(macro.rightClickRanks)))
end

--[[
	A spell with more than one rank, known or not, offers a fixed rank (see ns.AbilityRank); only its known
	ranks (macro.ranks) can be chosen, the rest (macro.unknownRanks) are listed as not known. A rank's own
	macro is fixed to its rank, so offers no choice.
]]
function ns.OffersFixedRank(macro)
	return not macro.rank and macro.ranks ~= nil
end

--[[
	The known rank the macro is fixed to, from its saved spell ID, or nil when it isn't, or that rank isn't among
	its known ranks. A rank's own macro is always fixed to its rank.
]]
local function FixedRankEntry(macro)
	local id = macro.rankID or (ns.OffersFixedRank(macro) and SpellSettings("fixedRank")[SettingsKey(macro)])
	for _, rank in ipairs(id and macro.ranks or NO_SLOTS) do
		if rank.id == id then
			return rank
		end
	end
	return nil
end

-- The text of the rank the macro is fixed to ("Rank 3"), as this client words it, or nil.
function ns.FixedRank(macro)
	if macro.rank then
		return macro.rank
	end
	local rank = FixedRankEntry(macro)
	return rank and rank.text
end

-- The spell ID of the rank the macro is fixed to, or nil.
function ns.FixedRankID(macro)
	local rank = FixedRankEntry(macro)
	return rank and rank.id
end

--[[
	The macro's ability rank, a choice of one: a known rank's text it always casts (see ns.FixedRank),
	"targetRank" (by the level of who it casts on), or nil for the highest rank, the default.
]]
function ns.AbilityRank(macro)
	return ns.IsOptionOn(macro, "targetRank") and "targetRank" or ns.FixedRank(macro)
end

--[[
	choice is as ns.AbilityRank gives it; a fixed rank is saved by its spell ID, not its text. "targetRank" is
	stored explicitly unless the whole choice matches the kind's default (Dynamic Rank, or the highest rank),
	so a fixed rank stays fixed when Dynamic Rank later becomes the default.
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
