local _, ns = ...
local L = ns.L

--[[
    A hidden secure button, since an add-on's slash command can't cast.
    PreClick picks and writes the attributes, the template casts, PostClick
    clears them. Attributes are locked in combat, so a press mid-fight casts
    only what a Bloodrage-first press left on the button.
]]

local BuffDuty = ns.BuffDuty

-- A macro's /click finds the button by this exact, case-sensitive name.
local KEY_BUTTON = "GtGBuffKey"

-- As Bindings.xml names it.
ns.BUFF_KEY_COMMAND = "CLICK " .. KEY_BUTTON .. ":LeftButton"

ns.BUFF_KEY_MACRO = "/click " .. KEY_BUTTON

--[[
    MIGRATION (remove after 2026-12-03): the button's name before the GtG name.
    A key still bound to its command moves over at login (ns.MigrateBuffKeys),
    and the old name stays an alias for the button, so a player's own macro
    that still types /click TFTBBuffIndividual keeps pressing it. Bindings.xml
    doesn't declare the old command: an older Thanks for the Buff declares
    it too, and the client warns on a duplicate. A saved CLICK key needs no
    declaration, and the alias answers it.
]]
local OLD_KEY_BUTTON = "TFTBBuffIndividual"
local OLD_KEY_COMMAND = "CLICK " .. OLD_KEY_BUTTON .. ":LeftButton"

_G["BINDING_NAME_" .. ns.BUFF_KEY_COMMAND] = L["BUFF_KEY"]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Bridges the moment before the aura shows up.
local BUFF_SKIP_SECONDS = 3
local RESURRECTION_SKIP_SECONDS = 60
-- A favor's by-name cast simply fails once they've moved off, so the key moves past them and one stranger doesn't stall the list.
local FAVOR_RETRY_SECONDS = 30
-- A Resurrection takes 10 seconds to cast.
local PENDING_SECONDS = 15

local recent = {} -- "<GUID or party>:<spell name>" -> GetTime() it stops being skipped
local pending -- { key, ids, seconds, expires }: the last press, until its cast goes off

--------------------------------------------------------------------------------
-- Skipping
--------------------------------------------------------------------------------

-- An item goes by item and weapon slot, so a scroll read a moment ago isn't read again before its aura shows.
local function SkipKey(spec)
	local name = spec.spellName
	if not name then
		if spec.itemId and (spec.selfItem or spec.weapon) then
			return "item:" .. spec.itemId .. ":" .. tostring(spec.targetSlot or "")
		end
		return nil
	end
	if spec.subgroup then
		return "party" .. spec.subgroup .. ":" .. name
	end
	-- Its own key, so a failed favor cast doesn't make the Target row's icon for them wait out the retry.
	if spec.favorGUID then
		return "favor:" .. spec.favorGUID .. ":" .. name
	end
	local guid = spec.unit and UnitGUID(spec.unit)
	if ns.IsPlain(guid) and guid then
		return guid .. ":" .. name
	end
	return nil
end

local function Skipped(spec, now)
	local key = SkipKey(spec)
	return key and recent[key] and recent[key] > now
end
BuffDuty.BuffKeySkipped = Skipped

--------------------------------------------------------------------------------
-- Remembering Casts
--------------------------------------------------------------------------------

local function Remember(spec)
	local now = GetTime()
	for key, expires in pairs(recent) do
		if expires <= now then
			recent[key] = nil
		end
	end
	local key = SkipKey(spec)
	if not key then
		pending = nil
		return
	end
	if spec.favorGUID then
		recent[key] = now + FAVOR_RETRY_SECONDS
	end
	local ids = {}
	for _, id in ipairs(spec.castIds or { spec.spellId }) do
		ids[id] = true
	end
	-- An item's cast goes off as the item's own spell.
	if spec.itemId and not spec.spellId then
		local _, itemSpellId = C_Item.GetItemSpell(spec.itemId)
		if ns.IsPlain(itemSpellId) and itemSpellId then
			ids[itemSpellId] = true
		end
	end
	pending = {
		key = key,
		ids = ids,
		seconds = spec.isResurrection and RESURRECTION_SKIP_SECONDS or BUFF_SKIP_SECONDS,
		expires = now + PENDING_SECONDS,
	}
end

-- Matched against every rank the press could go off as (castIds).
function ns.OnBuffKeyCastSucceeded(unit, spellID)
	if not pending or not ns.IsPlain(unit) or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	local now = GetTime()
	if now > pending.expires then
		pending = nil
		return
	end
	if pending.ids[spellID] then
		recent[pending.key] = now + pending.seconds
		pending = nil
	end
end

--------------------------------------------------------------------------------
-- Buttons
--------------------------------------------------------------------------------

--[[
    A key press sends down and up; a macro's /click a lone up. useOnKeyDown
    false makes the template act on the up half for both, or a key-down
    player's /click casts nothing. Both halves write attributes; only the up
    half remembers and notifies. The up half reuses the down half's pick.
]]
local PRESS_REUSE_SECONDS = 1
local downPick -- { at, spec, waitingOn, flagged, askSpec }: the down half's pick, until its up half

local function PickForPress(down)
	local now = GetTime()
	local earlier = downPick
	downPick = nil
	if not down and earlier and now - earlier.at <= PRESS_REUSE_SECONDS then
		return earlier.spec, earlier.waitingOn, earlier.flagged, earlier.askSpec
	end
	local spec, waitingOn, flagged, askSpec = BuffDuty.PickBuffKeySpec()
	if down then
		downPick = { at = now, spec = spec, waitingOn = waitingOn, flagged = flagged, askSpec = askSpec }
	end
	return spec, waitingOn, flagged, askSpec
end

--[[
    A press would restart a meal, stand you up or cut a cast. An unreadable
    cast or channel counts, so a doubtful press stays quiet.
]]
local function Busy()
	if SpellIsTargeting() then
		return true
	end
	local casting = UnitCastingInfo("player")
	if not ns.IsPlain(casting) or casting then
		return true
	end
	local channeling = UnitChannelInfo("player")
	if not ns.IsPlain(channeling) or channeling then
		return true
	end
	return BuffDuty.IsEating() and true or false
end

local function OnKeyPreClick(self, _, down)
	local acting = not down
	if InCombatLockdown() then
		-- Silent; the locked button keeps only a Bloodrage-first press's buff.
		downPick = nil
		return
	end
	if Busy() then
		downPick = nil
		ns.SetBuffButtonAttributes(self, nil)
		self.lastSpec = nil
		return
	end
	local spec, waitingOn, flagged, askSpec = PickForPress(down)
	ns.SetBuffButtonAttributes(self, spec)
	self.lastSpec = spec
	if not acting then
		return
	end
	local asked = askSpec and ns.AskTargetForBuffs(askSpec)
	if spec then
		if spec.confirmReplace then
			ns.ExpectReplaceEnchant()
		end
		Remember(spec)
		ns.NoteBuffCastAttempt(spec)
	elseif asked then
		-- The whisper was the press: nothing left to cast, and no notice over it.
		return
	elseif flagged then
		ns:PrintMessage(L["BUFF_DUTY_PVP_FLAGGED"]:format(flagged))
	elseif waitingOn then
		ns.ShowUINotice(L["BUFF_KEY_WAITING"]:format(waitingOn))
	elseif not BuffDuty.isSetUp or not ns.IsBuffDutyTrackingForClass() then
		ns.ShowUINotice(L["BUFF_KEY_OFF"])
	elseif ns.AreAurasSecret() then
		ns.ShowUINotice(L["BUFF_DUTY_AURAS_HIDDEN"])
	elseif BuffDuty.ShowsHere() and not UnitIsDeadOrGhost("player") then
		-- Done only when the list was there to finish; hidden here or dead, the key stays quiet.
		ns.ShowUINotice(L["BUFF_KEY_DONE"])
	end
end

local function OnKeyPostClick(self, _, down)
	if InCombatLockdown() then
		return
	end
	local spec = not down and self.lastSpec
	--[[
	    A Bloodrage-first press leaves the buff's own cast on the button:
	    Bloodrage can start combat and lock it, and the next press casts the buff.
	]]
	if spec and spec.rageFirst then
		ns.SetBuffButtonAttributes(self, { spellName = spec.spellName, castSpell = spec.castSpell, unit = spec.unit })
	else
		ns.SetBuffButtonAttributes(self, nil)
	end
end

local keyButton = CreateFrame("Button", KEY_BUTTON, UIParent, "SecureActionButtonTemplate")
-- Both halves, or the button is dead for players who cast on key down.
keyButton:RegisterForClicks("AnyUp", "AnyDown")
keyButton:SetAttribute("useOnKeyDown", false)
keyButton:SetScript("PreClick", OnKeyPreClick)
keyButton:SetScript("PostClick", OnKeyPostClick)
keyButton:Hide()
-- MIGRATION (remove after 2026-12-03)
_G[OLD_KEY_BUTTON] = keyButton

-- Bindings are locked in combat, so a /reload mid-fight tries again next login.
function ns.MigrateBuffKeys()
	if InCombatLockdown() then
		return
	end
	local moved = false
	-- MIGRATION (remove after 2026-12-03)
	for _, key in ipairs({ GetBindingKey(OLD_KEY_COMMAND) }) do
		SetBinding(key, ns.BUFF_KEY_COMMAND)
		moved = true
	end
	if moved then
		SaveBindings(GetCurrentBindingSet())
	end
end
