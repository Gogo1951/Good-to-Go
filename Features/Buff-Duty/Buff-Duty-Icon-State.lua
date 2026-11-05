local _, ns = ...

--[[
    Buff-Duty-Icon-State -- what the Buff Duty window's icons show between
    redraws: the cooldown swipe and the range fade. Both only touch alpha and
    the cooldown frames, which the client lets change on a protected button
    mid-fight, so neither waits for combat to end.
]]

local OUT_OF_RANGE_ALPHA = 0.35
local RANGE_INTERVAL = 0.5

--[[
    The list's icon pool, filled by Buff-Duty-Frame.lua: `buttons` holds every
    icon made, the first `used` of them in use, and `content` is the frame they
    sit in, set once the window is built.
]]
local pool = { buttons = {}, used = 0 }
ns.buffDutyIconPool = pool

local rangeTicker

--------------------------------------------------------------------------------
-- Cooldowns
--------------------------------------------------------------------------------

local GetItemCooldown = C_Container.GetItemCooldown

-- Each spell's cooldown, read once per pass of ns.UpdateBuffDutyCooldowns: false where the client had none.
local cooldownsThisPass = {}

-- An item icon (a poison, a Soulstone) shows the item's own cooldown; a spell icon its spell's.
local function GetCooldown(spec)
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
    Draws each icon's cooldown the way an action button does, global cooldown
    included. Every rank shares one cooldown, so the spec's own id is enough. A
    value the client keeps secret leaves the swipe as it was rather than
    erroring; the next update after combat corrects it.

    With no cooldown running, an icon for a buff that is running low (not gone)
    shows how much of it is left as a sliver: reversed, so the bright part is
    the time remaining and the dark part the time spent. No countdown, ours or
    a cooldown-count add-on's (noCooldownCount): the sliver alone reads at a
    glance. It ends whole once the buff runs out.

    Not while Forever keeps cooldowns secret: each read would come back
    unreadable.
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
end

ns.SetBuffDutyEventHandler("SPELL_UPDATE_COOLDOWN", OnSpellUpdateCooldown)

--------------------------------------------------------------------------------
-- Range
--------------------------------------------------------------------------------

local IsItemInRange = C_Item.IsItemInRange

--[[
    An item used on someone (a Soulstone) asks the item's own range out of
    combat only, and falls back on the buffs' check in combat or when the
    client has no answer. The Buff Key asks it too.
]]
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
    Set when the group or the target changes mid-fight. The icons can't be
    rebuilt until combat ends, so the ones still showing may name someone who
    left, moved party or is no longer targeted; they stay dimmed until Buff-Duty-Frame.lua next draws or hides the
    list, which clears it.
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
