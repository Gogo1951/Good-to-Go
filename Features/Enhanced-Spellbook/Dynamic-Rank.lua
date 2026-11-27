local _, ns = ...

local MacroBody = ns.MacroBody

--[[
	Out of combat only: in combat a macro keeps its last ranks, so a lower rank is held only while the low-level
	unit is still there. Entering combat rewrites every one at once, the last moment the macros can change, so
	combat starts on the highest rank wherever no low-level unit is targeted or under the cursor.
]]
local pendingRankRewrite -- nil, or "all" or one of UNITS_WATCHED while a rewrite waits for the next frame
local WatchMouseover

--[[
	A rebuilt list's bodies were never written, so the next rewrite writes every one; after that only changed
	bodies are, so most mouseovers don't read the macro list at all.
]]
local rankBodiesSynced = false

-- The units besides the target whose change rewrites only the macros that try them.
local UNITS_WATCHED = { "mouseover", "focus", "pet", "targettarget" }

--[[
	{any = true, mouseover = true, ...}. Buff spells take Dynamic Rank by default, so the setting is on for
	nearly every character; without a placed macro a unit change does nothing and the list isn't rebuilt for it.
	Kept until the next build, a new macro or a changed bar slot, so dropping the list on SPELLS_CHANGED doesn't
	bring the rebuild back.
]]
local placedRankMacros
local barMacroNames = {}

local function PlacedRankMacros()
	if placedRankMacros == nil then
		if #ns.macros == 0 then
			ns.CollectMacros()
		end
		local tags = ns.ReadMacroIndexes().tags
		barMacroNames = ns.BarMacroNames()
		-- matched as ns.ScanActionBars matches: a tagged bar macro by its tag only, an untagged one by name
		local onBars, tagsOnBars = {}, {}
		for slot, name in pairs(barMacroNames) do
			local tag = ns.ActionMacroTag(slot)
			if tag then
				tagsOnBars[tag] = true
			else
				onBars[name] = true
			end
		end
		local placed = { any = false }
		for _, unit in ipairs(UNITS_WATCHED) do
			placed[unit] = false
		end
		for _, macro in ipairs(ns.macros) do
			local tag = ns.MacroTag(macro)
			if
				ns.IsOptionOn(macro, "targetRank")
				and tags[tag]
				and (onBars[ns.WowMacroName(macro)] or tagsOnBars[tag])
			then
				placed.any = true
				for _, unit in ipairs(UNITS_WATCHED) do
					placed[unit] = placed[unit] or ns.TriesUnit(macro, unit)
				end
			end
		end
		placedRankMacros = placed
	end
	return placedRankMacros
end

function ns.ForgetPlacedRankMacros()
	placedRankMacros = nil
end

-- scope "all" needs a placed macro at all, a unit (one of UNITS_WATCHED) a placed macro that tries it.
local function RanksRewritable(scope)
	if not (ns.db and ns.IsSpellbookEnabled() and not InCombatLockdown() and ns.AnyTargetRank()) then
		return false
	end
	local placed = PlacedRankMacros()
	return placed.any and (scope == "all" or placed[scope])
end

local function RewriteRankMacros()
	local scope = pendingRankRewrite
	local unitOnly = scope ~= "all" and scope
	pendingRankRewrite = nil
	if not RanksRewritable(scope) then
		return
	end
	if #ns.macros == 0 then
		ns.CollectMacros()
	end
	local writeAll = not rankBodiesSynced
	local changed = {}
	for _, macro in ipairs(ns.macros) do
		if ns.IsOptionOn(macro, "targetRank") and (writeAll or not unitOnly or ns.TriesUnit(macro, unitOnly)) then
			local body = MacroBody(macro)
			if writeAll or body ~= macro.body then
				macro.body = body
				changed[#changed + 1] = macro
			end
		end
	end
	rankBodiesSynced = true
	if #changed > 0 then
		local indexes = ns.ReadMacroIndexes()
		for _, macro in ipairs(changed) do
			ns.SyncMacro(macro, indexes)
		end
	end
	WatchMouseover()
end

local function QueueRankRewrite(scope)
	if not RanksRewritable(scope) then
		return
	end
	if not pendingRankRewrite then
		C_Timer.After(0, RewriteRankMacros)
		pendingRankRewrite = scope
	elseif pendingRankRewrite ~= scope then
		-- two different units changed in one burst
		pendingRankRewrite = "all"
	end
end

-- Catches up every rewrite skipped in combat.
function ns.QueueRankRewriteAll()
	QueueRankRewrite("all")
end

local MOUSEOVER_POLL_SECONDS = 0.2
local watchingMouseover = false

-- Forever keeps unit identity secret in combat, so the mouseover counts as gone until it can be read.
local function HasMouseover()
	return not ns.IsUnitIdentitySecret("mouseover") and ns.IsPlainTrue(UnitExists("mouseover"))
end

-- No event fires when the cursor leaves a unit, so the mouseover is polled until it goes.
local function PollMouseover()
	if RanksRewritable("mouseover") and HasMouseover() then
		C_Timer.After(MOUSEOVER_POLL_SECONDS, PollMouseover)
		return
	end
	watchingMouseover = false
	QueueRankRewrite("mouseover")
end

function WatchMouseover()
	if not watchingMouseover and PlacedRankMacros().mouseover and HasMouseover() then
		watchingMouseover = true
		C_Timer.After(MOUSEOVER_POLL_SECONDS, PollMouseover)
	end
end

function ns:OnPlayerTargetChanged()
	QueueRankRewrite("all")
end

function ns:OnUpdateMouseoverUnit()
	QueueRankRewrite("mouseover")
end

function ns:OnPlayerFocusChanged()
	QueueRankRewrite("focus")
end

-- Subscribed for "target" only: the target's target changed.
function ns:OnSpellbookUnitTarget()
	QueueRankRewrite("targettarget")
end

function ns.QueueRankRewriteFor(unit)
	QueueRankRewrite(unit)
end

-- Runs now, not on the next frame: combat is about to lock the macros.
function ns.RewriteRanksBeforeCombat()
	if RanksRewritable("all") then
		pendingRankRewrite = "all"
		RewriteRankMacros()
	end
end

--[[
	Slot 0 stands for any slot. Where no placed macro tried a watched unit, the skipped rewrites left ranks
	behind the units there now, so they are written at once rather than on the next target change.
]]
function ns.OnRankBarSlotChanged(slot)
	if slot and slot > 0 and ns.ActionMacroName(slot) == barMacroNames[slot] then
		return
	end
	local missed = false
	if placedRankMacros then
		for _, unit in ipairs(UNITS_WATCHED) do
			missed = missed or not placedRankMacros[unit]
		end
	end
	placedRankMacros = nil
	if missed then
		QueueRankRewrite("all")
	end
end

function ns.MarkRankBodiesStale()
	rankBodiesSynced = false
	placedRankMacros = nil
end
