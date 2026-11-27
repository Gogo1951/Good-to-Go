local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Ignore List Panel
--------------------------------------------------------------------------------

--[[
    Each scope group closes over its own scope key, so a pane always acts on the
    list shown. No drop target: the game closes the bags when options open, so
    Add from Bags stands in for a drag.
]]

-- Promote, not copy: ns.SetIgnoredInScope clears a newly global item off every character's list.
local function PromoteColumn()
	return {
		type = "execute",
		name = L["OPTIONS_IGNORE_GLOBAL"],
		desc = L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"],
		width = ns.OPTIONS_PROMOTE_WIDTH,
		func = function(itemID)
			ns.SetIgnoredInScope(ns.IGNORE_SCOPE_GLOBAL, itemID, true)
		end,
	}
end

local function BuildScopeArgs(scopeKey)
	local isGlobalScope = scopeKey == ns.IGNORE_SCOPE_GLOBAL

	local args = Kit.ItemList({
		rowWidth = ns.OPTIONS_TREE_ROW_WIDTH,
		startOrder = 3,
		registryName = ns.OPTIONS_REGISTRY.IgnoreList,
		getSourceTable = function()
			return ns.GetIgnoreListForScope(scopeKey)
		end,
		onAdd = function(itemID)
			ns.SetIgnoredInScope(scopeKey, itemID, true)
		end,
		onRemove = function(itemID)
			ns.SetIgnoredInScope(scopeKey, itemID, false)
		end,
		onClear = function()
			ns.ClearIgnoreListInScope(scopeKey)
			-- An emptied list leaves the tree, so point it back at the character playing.
			if not isGlobalScope and scopeKey ~= ns.db:GetCurrentProfile() then
				local status = LibStub("AceConfigDialog-3.0"):GetStatusTable(ns.OPTIONS_REGISTRY.IgnoreList)
				status.groups = status.groups or {}
				status.groups.selected = ns.db:GetCurrentProfile()
			end
		end,
		addFromBags = true,
		labels = {
			fromBagsName = L["OPTIONS_IGNORE_ADD_FROM_BAGS"],
			fromBagsDesc = L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"],
			addName = L["OPTIONS_IGNORE_ADD_ID"],
			addHelp = L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"],
			addInvalid = L["OPTIONS_IGNORE_ADD_ID_INVALID"],
			removeDesc = L["OPTIONS_IGNORE_REMOVE"],
			empty = L["OPTIONS_IGNORE_EMPTY"],
			clearName = L["OPTIONS_IGNORE_CLEAR"],
			clearDesc = L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"],
			clearConfirm = L["OPTIONS_IGNORE_CLEAR_CONFIRM"],
		},
		-- Global has nowhere to promote to; its item cell absorbs the column so the remove icon stays put.
		actionColumn = (not isGlobalScope) and PromoteColumn() or nil,
	})

	args.spacerTop = Kit.Spacer(2)

	return args
end

local function ScopeGroup(name, order, scopeKey)
	return {
		type = "group",
		name = name,
		order = order,
		args = BuildScopeArgs(scopeKey),
	}
end

function ns.BuildIgnoreListOptions()
	-- On the root, a tree group renders its non-group args once above the tree, not in every pane.
	local args = {
		descIntro = Kit.Desc(L["OPTIONS_IGNORE_LIST_DESCRIPTION"], 1),
		spacerIntro = Kit.Spacer(2),
	}
	ns.AddFeatureOffLine(args, "macrosEnabled")

	-- Keyed by scope, not position: the tree remembers its selection by arg key.
	args[ns.IGNORE_SCOPE_GLOBAL] = ScopeGroup(L["OPTIONS_IGNORE_GLOBAL"], 3, ns.IGNORE_SCOPE_GLOBAL)

	-- A blank row, as Magic Eraser's lists have; disabled tree rows take no mouse input.
	args.spacerCharacters = {
		type = "group",
		name = " ",
		order = 4,
		disabled = true,
		args = {},
	}

	if ns.db then
		local profiles = ns.db:GetProfiles()
		table.sort(profiles)

		local currentProfile = ns.db:GetCurrentProfile()
		local classes = ns.GetClassesByProfileName()
		local _, playerClass = UnitClass("player")
		classes[currentProfile] = playerClass
		local order = 10

		for _, profileName in ipairs(profiles) do
			-- Empty lists are left out, except the character playing, so a first item can go in.
			local ignoreList = ns.GetIgnoreListForScope(profileName)
			if profileName == currentProfile or (ignoreList and next(ignoreList) ~= nil) then
				local classColor = ns.GetClassColor(classes[profileName])
				local displayName = classColor and (classColor .. profileName .. "|r") or profileName
				args[profileName] = ScopeGroup(displayName, order, profileName)
				order = order + 1
			end
		end
	end

	return {
		type = "group",
		name = Kit.SubPanelTitle(L["TAB_CONSUMABLE_MACROS"], L["TAB_IGNORE_LIST"]),
		childGroups = "tree",
		args = args,
	}
end
