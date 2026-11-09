local _, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Rank Watch Ignored Players Panel
--------------------------------------------------------------------------------

--[[
    "Ignored Players", under Rank Watch: the players it never reports, added from the current target and removed
    one by one. Account-wide, like every Rank Watch setting, and keyed by GUID so a renamed player stays ignored.
    Not hidden behind the Rank Watch switch: a choice worth making before turning it on. Registered as a
    function, so the list and the Ignore Target button follow the target on every redraw.
]]

local function Ignored()
	return ns.RankWatchSettings().ignoredPlayers
end

local function IgnoredClasses()
	return ns.RankWatchSettings().ignoredClasses
end

--[[
    A row's class: the one stored when the player was ignored, else the client's own record of that GUID, which
    it holds for anyone seen this session (entries made before classes were stored, or imported from the
    standalone add-on). A class found that way is kept, so the color survives the next login.
]]
local function ClassOf(guid)
	local classes = IgnoredClasses()
	if classes[guid] then
		return classes[guid]
	end
	local _, class = GetPlayerInfoByGUID(guid)
	if ns.IsPlain(class) and class then
		classes[guid] = class
		return class
	end
	return nil
end

local function Refresh()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.RankWatchIgnored)
end

-- The target, when it is another player who can be ignored.
local function IgnorableTarget()
	return ns.RankWatchIgnorableUnit("target")
end

local function AddIgnoredRows(args, startOrder)
	local ignored = Ignored()
	local sorted = {}
	for guid, name in pairs(ignored) do
		sorted[#sorted + 1] = { guid = guid, name = name }
	end
	table.sort(sorted, function(a, b)
		return a.name < b.name
	end)
	if #sorted == 0 then
		args.ignoredNone = Desc(ns.OptionsSubLabel(L["RANK_WATCH_IGNORED_NONE"]), startOrder)
		return
	end
	for index, entry in ipairs(sorted) do
		local order = startOrder + index * 0.01
		local color = ns.GetClassColor(ClassOf(entry.guid)) or ns.GetColor("TEXT")
		args["ignored" .. index] = ns.OptionsRowLabel(color .. entry.name .. "|r", order)
		args["ignoredRemove" .. index] = ns.OptionsRemoveIcon(L["RANK_WATCH_IGNORED_REMOVE"], order + 0.001, function()
			ignored[entry.guid] = nil
			IgnoredClasses()[entry.guid] = nil
			Refresh()
		end)
		args["ignoredBreak" .. index] = { type = "description", name = "", width = "full", order = order + 0.002 }
	end
end

function ns.BuildRankWatchIgnoredOptions()
	local options = {
		name = ns.SubPanelTitle(L["TAB_RANK_WATCH"], L["RANK_WATCH_IGNORED_HEADER"]),
		type = "group",
		args = {
			description = Desc(L["RANK_WATCH_IGNORED_DESCRIPTION"], 1),
			space0 = Spacer(2),
			ignoreTarget = {
				type = "execute",
				name = L["RANK_WATCH_IGNORE_TARGET"],
				desc = L["RANK_WATCH_IGNORE_TARGET_DESCRIPTION"],
				order = 3,
				disabled = function()
					return IgnorableTarget() == nil
				end,
				func = function()
					local guid, name, class = IgnorableTarget()
					if guid then
						Ignored()[guid] = name
						IgnoredClasses()[guid] = class
						Refresh()
					end
				end,
			},
			space1 = Spacer(4),
		},
	}
	AddIgnoredRows(options.args, 10)
	return options
end
