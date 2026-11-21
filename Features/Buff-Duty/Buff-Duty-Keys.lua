local _, ns = ...
local L = ns.L

--[[
    The Buff Key: a key binding that casts the next buff on Buff Duty's list,
    one press at a time, the way Pally Power's auto-buff keys do. A
    resurrection on your dead target, then on your group's dead, then your
    target, Return the Favor, your self-buffs, and your group -- your
    target's party first. Each cast on someone else targets them
    (TargetWhoItsFor), and the key never puts your old target back. A press can also whisper your target an ask for a buff of
    theirs you're missing (Buff-Duty-Asks.lua), before the buffs you can
    give them. For each buff a party is missing, the key casts the group
    version when it costs less mana than buffing everyone it would reach one
    at a time, and the single one otherwise (AddParty, in
    Buff-Duty-Key-Picker.lua, which makes the pick).

    The key is a hidden SecureActionButtonTemplate button bound by
    Bindings.xml ("CLICK <button>:LeftButton"), and a macro reaches the same
    button with "/click GtGBuffKey" -- the way Pally Power's macros
    click its buttons. The name is case-sensitive. A slash command of our own
    can't do it: the game only lets its own secure code cast, and an add-on's
    command never is. Casting from a key press is
    protected, so the pick happens in PreClick: it reads the group fresh,
    builds the same sections the window draws (ns.BuffDuty.BuildSections),
    writes the first castable icon's attributes onto the button, and the
    secure template casts it. PostClick clears them again. All of it needs
    combat to be over -- a secure button's attributes are locked in combat
    -- so a press mid-fight does nothing, except the buff a Bloodrage-first
    press left on the button (OnKeyPostClick), which it then casts. So does a press while you're eating
    or drinking, casting or channeling (Busy): it would start the meal over,
    stand you up, or cut the cast short.
]]

local BuffDuty = ns.BuffDuty

-- The button's global name, which a macro's /click types.
local KEY_BUTTON = "GtGBuffKey"

-- The binding command, as Bindings.xml names it; the options panel binds keys to it.
ns.BUFF_KEY_COMMAND = "CLICK " .. KEY_BUTTON .. ":LeftButton"

-- The macro line, shown under the binding on the options panel.
ns.BUFF_KEY_MACRO = "/click " .. KEY_BUTTON

--[[
    MIGRATION (remove after 2026-11-21): The Group Buff key's command, from before the one key picked group buffs
    on its own. Its button is gone; a key still bound to it moves over at
    login (ns.MigrateBuffKeys).
]]
local OLD_GROUP_COMMAND = "CLICK TFTBBuffGroup:LeftButton"

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

-- The name the game's Key Bindings list shows (the add-on's header is set in Features/Key-Bindings.lua).
_G["BINDING_NAME_" .. ns.BUFF_KEY_COMMAND] = L["BUFF_KEY"]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
    How long a cast the key just made keeps it off that player and buff.
    A buff only needs to bridge the moment before its aura shows up; a
    resurrection waits out the minute its target has to accept it.
]]
local BUFF_SKIP_SECONDS = 3
local RESURRECTION_SKIP_SECONDS = 60
--[[
    A Return the Favor icon targets the stranger by name, and simply fails
    when they've moved off. The key moves past them for this long after a
    press, so one stranger out of reach doesn't stall the list; a cast that
    does go off is then held for BUFF_SKIP_SECONDS like any other
    (ns.OnBuffKeyCastSucceeded).
]]
local FAVOR_RETRY_SECONDS = 30
-- How long a press waits to hear its cast went off; a Resurrection takes 10 seconds.
local PENDING_SECONDS = 15

local recent = {} -- "<GUID or party>:<spell name>" -> GetTime() it stops being skipped
local pending -- { key, ids, seconds, expires }: the last press, until its cast goes off

--------------------------------------------------------------------------------
-- Skipping
--------------------------------------------------------------------------------

--[[
    What a press remembers a cast by: who it went on (a party, for a group
    buff) and the spell's name. An item the key uses on you (a scroll, buff
    food, a poison) by the item and the weapon slot it went on, so a scroll
    read a moment ago isn't read again before its aura shows.
]]
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
	--[[
	    Its own key: the favor's macro targets the stranger, and if the cast
	    then fails (a press inside the global cooldown) the Target section's
	    icon for them shouldn't wait out the favor's retry.
	]]
	if spec.favorGUID then
		return "favor:" .. spec.favorGUID .. ":" .. name
	end
	local guid = spec.unit and UnitGUID(spec.unit)
	if ns.IsPlain(guid) and guid then
		return guid .. ":" .. name
	end
	return nil
end

-- Whether a press a moment ago already cast this, and the key waits on its aura; the picker asks it too.
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

--[[
    Called from Buff-Duty-Events.lua's UNIT_SPELLCAST_SUCCEEDED handler. The
    cast is matched by spell ID against every rank the press could go off as:
    a group buff's castIds list every group rank, and a resurrection's list
    every rank of it, whichever one its rank text casts.
]]
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
    A key press reaches the button twice, down and up, while a macro's
    /click sends a single up. The button sets useOnKeyDown to false (below),
    so the secure template acts on the up half for both, whatever
    ActionButtonUseKeyDown says -- otherwise a key-down player's /click
    would cast nothing. Both halves write the attributes, so a client that
    acted on the other half would still cast; only the up half remembers
    the cast and shows a message.

    A pick reads the whole group, so a press picks once: the up half reuses
    the down half's pick, nothing having been cast in between, unless the key
    was held longer than PRESS_REUSE_SECONDS. A /click's lone up picks for
    itself.
]]
local PRESS_REUSE_SECONDS = 1
local downPick -- { at, spec, waitingOn }: the down half's pick, until its up half

local function PickForPress(down)
	local now = GetTime()
	local earlier = downPick
	downPick = nil
	if not down and earlier and now - earlier.at <= PRESS_REUSE_SECONDS then
		return earlier.spec, earlier.waitingOn
	end
	local spec, waitingOn = BuffDuty.PickBuffKeySpec()
	if down then
		downPick = { at = now, spec = spec, waitingOn = waitingOn }
	end
	return spec, waitingOn
end

--[[
    Eating or drinking, casting, channeling, or the cursor waiting on a
    target (a poison used from your bags, waiting on a weapon). A cast or
    channel that can't be read counts as one, so a doubtful press stays quiet.
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

--[[
    A spell the key casts on someone else targets them as it goes: a party
    member, a pet, the player a group buff is aimed at. Whatever was targeted
    before isn't put back. Your own buffs, your current target, a favor
    (whose macro already targets the stranger) and items are left as written.
    Unit tokens and rank text are the add-on's own, so the line is safe to
    build; it stays far under the macro's 255 characters.
]]
local function TargetWhoItsFor(button, spec)
	if not spec or spec.ask or spec.macrotext or spec.item then
		return
	end
	local unit = spec.unit
	local castText = spec.castSpell or spec.spellName
	if not unit or not castText or unit == "player" or unit == "target" then
		return
	end
	local isSelf = UnitIsUnit(unit, "player")
	if not ns.IsPlain(isSelf) or isSelf or not UnitExists(unit) then
		return
	end
	button:SetAttribute("type1", "macro")
	button:SetAttribute("spell", nil)
	button:SetAttribute("unit", nil)
	button:SetAttribute("macrotext", "/target " .. unit .. "\n/cast [@" .. unit .. "] " .. castText)
end

local function OnKeyPreClick(self, _, down)
	local acting = not down
	if InCombatLockdown() then
		--[[
		    Silent, like a busy press below. The button is locked as it was left:
		    empty, but for a Bloodrage-first press's buff (OnKeyPostClick).
		]]
		downPick = nil
		return
	end
	if Busy() then
		-- Nothing on the button, so the template casts nothing, and no message.
		downPick = nil
		ns.SetBuffButtonAttributes(self, nil)
		self.lastSpec = nil
		return
	end
	local spec, waitingOn = PickForPress(down)
	ns.SetBuffButtonAttributes(self, spec)
	TargetWhoItsFor(self, spec)
	self.lastSpec = spec
	if not acting then
		return
	end
	if spec and spec.ask then
		-- An ask casts nothing (its attributes are cleared): the whisper goes out here.
		ns.AskTargetForBuffs(spec)
	elseif spec then
		-- A weapon buff's "replace your enchant?" is answered, as for a click on its icon.
		if spec.confirmReplace then
			ns.ExpectReplaceEnchant()
		end
		Remember(spec)
		ns.NoteBuffCastAttempt(spec)
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
	    A Bloodrage-first press (rageFirst, Buff-Duty-Self.lua) leaves its
	    buff's own cast on the button: Bloodrage can start combat, which locks
	    the button, and the next press then casts the buff.
	]]
	if spec and spec.rageFirst then
		ns.SetBuffButtonAttributes(self, { spellName = spec.spellName, castSpell = spec.castSpell, unit = spec.unit })
	else
		ns.SetBuffButtonAttributes(self, nil)
	end
end

local keyButton = CreateFrame("Button", KEY_BUTTON, UIParent, "SecureActionButtonTemplate")
-- Both halves, as the window's own buttons do; see OnKeyPreClick.
keyButton:RegisterForClicks("AnyUp", "AnyDown")
keyButton:SetAttribute("useOnKeyDown", false)
keyButton:SetScript("PreClick", OnKeyPreClick)
keyButton:SetScript("PostClick", OnKeyPostClick)
keyButton:Hide()
-- MIGRATION (remove after 2026-12-03)
_G[OLD_KEY_BUTTON] = keyButton

--[[
    Run from Buff Duty's setup at login. A key still bound to an old
    command now presses this button: the Group Buff key's, since this one
    picks group buffs itself, and this button's own under its old name. Each
    move is its own loop, so each deletes on its own date. Once moved,
    nothing is left to move. Bindings are locked in combat, so a /reload
    mid-fight tries again next login.
]]
function ns.MigrateBuffKeys()
	if InCombatLockdown() then
		return
	end
	local moved = false
	-- MIGRATION (remove after 2026-11-21)
	for _, key in ipairs({ GetBindingKey(OLD_GROUP_COMMAND) }) do
		SetBinding(key, ns.BUFF_KEY_COMMAND)
		moved = true
	end
	-- MIGRATION (remove after 2026-12-03)
	for _, key in ipairs({ GetBindingKey(OLD_KEY_COMMAND) }) do
		SetBinding(key, ns.BUFF_KEY_COMMAND)
		moved = true
	end
	if moved then
		SaveBindings(GetCurrentBindingSet())
	end
end
