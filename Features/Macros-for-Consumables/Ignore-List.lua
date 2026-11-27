local _, ns = ...

--------------------------------------------------------------------------------
-- Ignore List
--------------------------------------------------------------------------------

-- Additive: an item on either the profile's list or the Global list is hidden from every macro.
function ns.GetIgnoreList()
	if not ns.db then
		return nil
	end
	return ns.db.profile.ignoreList
end

function ns.GetGlobalIgnoreList()
	if not ns.db then
		return nil
	end
	return ns.db.global.ignoreList
end

function ns.IsIgnored(itemID)
	local ignoreList = ns.GetIgnoreList()
	if ignoreList and ignoreList[itemID] then
		return true
	end
	local globalIgnoreList = ns.GetGlobalIgnoreList()
	return (globalIgnoreList and globalIgnoreList[itemID]) and true or false
end

--[[
    Forced: a body that already names a newly ignored item must be rewritten.
    UpdateMacros defers itself in combat and while the Macro UI is open.
]]
local function RefreshMacros()
	ns.ResetMacroState()
	ns.UpdateMacros(true)
end

--[[
    Mini-map edits act on this character's list only, the one its menu shows.
    Add never toggles: while the rebuild waits (combat, Macro UI open) the
    button still offers the same food, and a second click must not unignore it.
]]
function ns.IgnoreItem(itemID)
	if not itemID then
		return false
	end
	local ignoreList = ns.GetIgnoreList()
	if not ignoreList or ignoreList[itemID] then
		return false
	end
	ignoreList[itemID] = true
	RefreshMacros()
	ns.RefreshSettings()
	return true
end

function ns.UnignoreItem(itemID)
	local ignoreList = ns.GetIgnoreList()
	if not (itemID and ignoreList and ignoreList[itemID]) then
		return false
	end
	ignoreList[itemID] = nil
	RefreshMacros()
	ns.RefreshSettings()
	return true
end

-- No confirmation: the mini-map menu's Clear Ignore List row is a deliberate quick-clear.
function ns.ClearIgnoreList()
	local ignoreList = ns.GetIgnoreList()
	local cleared = 0
	if ignoreList then
		for _ in pairs(ignoreList) do
			cleared = cleared + 1
		end
		wipe(ignoreList)
	end
	RefreshMacros()
	ns.RefreshSettings()
	return cleared
end

--------------------------------------------------------------------------------
-- Ignore List Scopes
--------------------------------------------------------------------------------

--[[
    The current profile goes through ns.db.profile so an edit lands on the list
    the scanner reads. Others come raw from ns.db.sv.profiles: AceDB builds only
    the current one and strips default-valued tables at logout, so only a write
    creates what is missing.
]]
function ns.GetIgnoreListForScope(scopeKey, createIfMissing)
	if not (ns.db and scopeKey) then
		return nil
	end

	if scopeKey == ns.IGNORE_SCOPE_GLOBAL then
		return ns.GetGlobalIgnoreList()
	end

	if scopeKey == ns.db:GetCurrentProfile() then
		return ns.GetIgnoreList()
	end

	local profiles = ns.db.sv and ns.db.sv.profiles
	if not profiles then
		return nil
	end

	local profile = profiles[scopeKey]
	if type(profile) ~= "table" then
		if not createIfMissing then
			return nil
		end
		profile = {}
		profiles[scopeKey] = profile
	end

	local ignoreList = profile.ignoreList
	if type(ignoreList) ~= "table" then
		if not createIfMissing then
			return nil
		end
		ignoreList = {}
		profile.ignoreList = ignoreList
	end

	return ignoreList
end

--[[
    A globally ignored item lives in one place only. The direct pass after the
    loop covers a current profile AceDB has not yet written into sv.profiles.
]]
local function ClearFromAllProfiles(itemID)
	local profiles = ns.db.sv and ns.db.sv.profiles
	if profiles then
		for _, profile in pairs(profiles) do
			if type(profile) == "table" and type(profile.ignoreList) == "table" then
				profile.ignoreList[itemID] = nil
			end
		end
	end

	local ignoreList = ns.GetIgnoreList()
	if ignoreList then
		ignoreList[itemID] = nil
	end
end

-- Removing from Global restores nobody's entry: there is no record of who held it.
function ns.SetIgnoredInScope(scopeKey, itemID, isIgnored)
	if not itemID then
		return
	end

	local ignoreList = ns.GetIgnoreListForScope(scopeKey, isIgnored and true or false)
	if not ignoreList then
		return
	end

	ignoreList[itemID] = isIgnored and true or nil

	if isIgnored and scopeKey == ns.IGNORE_SCOPE_GLOBAL then
		ClearFromAllProfiles(itemID)
	end

	RefreshMacros()
end

function ns.ClearIgnoreListInScope(scopeKey)
	local ignoreList = ns.GetIgnoreListForScope(scopeKey)
	if ignoreList then
		wipe(ignoreList)
	end
	RefreshMacros()
end

--------------------------------------------------------------------------------
-- Pruning
--------------------------------------------------------------------------------

--[[
    Drops only IDs the client doesn't know at all: Era and Season of Discovery
    share the file but build different data folders, so pruning against this
    folder's data would erase the other's entries.
]]
local function PruneOneList(ignoreList)
	if not ignoreList then
		return
	end
	for itemID in pairs(ignoreList) do
		if not C_Item.DoesItemExistByID(itemID) then
			ignoreList[itemID] = nil
		end
	end
end

function ns.OnIgnoreListPlayerLogout()
	PruneOneList(ns.GetIgnoreList())
	PruneOneList(ns.GetGlobalIgnoreList())
end
