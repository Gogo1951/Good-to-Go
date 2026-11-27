local _, ns = ...

-- Swipe and range fade touch only alpha and cooldown frames, which may change on a protected button in combat.

local OUT_OF_RANGE_ALPHA = 0.35
local RANGE_INTERVAL = 0.5

-- Filled by Buff-Duty-Icons.lua: the first `used` of `buttons` are in use.
local pool = { buttons = {}, used = 0 }
ns.buffDutyIconPool = pool

local rangeTicker

--------------------------------------------------------------------------------
-- Cooldowns
--------------------------------------------------------------------------------

local GetItemCooldown = C_Container.GetItemCooldown

local cooldownsThisPass = {}

local function GetCooldown(spec)
	if spec.ask then
		local BuffDuty = ns.BuffDuty
		local at = BuffDuty.AskedAt(spec.ask.guid, spec.askKey)
		if at then
			return at, BuffDuty.ASK_TARGET_COOLDOWN, 1
		end
		return 0, 0, 1
	end
	if spec.itemId then
		local start, duration = GetItemCooldown(spec.itemId)
		return start, duration, 1
	end
	local info = cooldownsThisPass[spec.spellId]
	if info == nil then
		info = C_Spell.GetSpellCooldown(spec.spellId) or false
		cooldownsThisPass[spec.spellId] = info
	end
	if info then
		return info.startTime, info.duration, info.modRate
	end
	return nil
end

--[[
    Every rank shares one cooldown, so the spec's own id is enough. A secret
    value leaves the swipe as it was; the next update after combat corrects
    it. The time-left sliver is reversed and hides countdown add-ons
    (noCooldownCount), so it reads at a glance.
]]
function ns.UpdateBuffDutyCooldowns()
	local content = pool.content
	if not content or not content:IsVisible() or ns.AreCooldownsSecret() then
		return
	end
	local now = GetTime()
	wipe(cooldownsThisPass)
	for i = 1, pool.used do
		local button = pool.buttons[i]
		local spec = button.spec
		local start, duration, modRate
		if spec then
			start, duration, modRate = GetCooldown(spec)
		end
		if ns.IsPlain(start) and ns.IsPlain(duration) then
			local cooldown = button.cooldown
			if start and duration and duration > 0 then
				cooldown:SetReverse(false)
				cooldown:SetHideCountdownNumbers(false)
				cooldown.noCooldownCount = nil
				cooldown:SetCooldown(start, duration, modRate or 1)
			elseif spec.buffExpires and spec.buffExpires > now then
				cooldown:SetReverse(true)
				cooldown:SetHideCountdownNumbers(true)
				cooldown.noCooldownCount = true
				cooldown:SetCooldown(spec.buffExpires - spec.buffDuration, spec.buffDuration)
			else
				cooldown:Clear()
			end
		end
	end
end

local function OnSpellUpdateCooldown()
	ns.UpdateBuffDutyCooldowns()
	ns.BuffDuty.CheckRageFirst()
end

ns.SetBuffDutyEventHandler("SPELL_UPDATE_COOLDOWN", OnSpellUpdateCooldown)

--------------------------------------------------------------------------------
-- Range
--------------------------------------------------------------------------------

local IsItemInRange = C_Item.IsItemInRange

-- An item's own range is asked out of combat only; in combat or with no answer, the buffs' check stands in.
local function InRange(spec)
	if spec.itemId and spec.unit and not InCombatLockdown() then
		local isPlayer = UnitIsUnit(spec.unit, "player")
		if ns.IsPlain(isPlayer) and not isPlayer then
			local inRange = IsItemInRange(spec.itemId, spec.unit)
			if ns.IsPlain(inRange) and inRange ~= nil then
				return inRange and true or false
			end
		end
	end
	return ns.IsBuffInRange(spec.unit, spec.spellName)
end
ns.IsBuffSpecInRange = InRange

--[[
    Set when the group or target changes mid-fight: the icons can't be rebuilt
    until combat ends and may name someone gone, so they stay dimmed until the
    next draw or hide.
]]
pool.rosterStale = false

function ns.UpdateBuffDutyRange()
	if not pool.content or not pool.content:IsVisible() then
		return
	end
	for i = 1, pool.used do
		local button = pool.buttons[i]
		local spec = button.spec
		local inRange = not pool.rosterStale and (not spec or InRange(spec))
		button:SetAlpha(inRange and 1 or OUT_OF_RANGE_ALPHA)
	end
end

function ns.MarkBuffDutyRosterStale()
	pool.rosterStale = true
	ns.UpdateBuffDutyRange()
end

function ns.StartBuffDutyRangeTicker()
	if not rangeTicker then
		rangeTicker = C_Timer.NewTicker(RANGE_INTERVAL, ns.UpdateBuffDutyRange)
	end
end

function ns.StopBuffDutyRangeTicker()
	if rangeTicker then
		rangeTicker:Cancel()
		rangeTicker = nil
	end
end
