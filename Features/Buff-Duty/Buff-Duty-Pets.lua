local _, ns = ...
local Data = ns.Data

--[[
    Buff-Duty-Pets -- a pet's row on Buff Duty's list: which buffs it takes,
    whether it can take any (not a borrowed mob, not phase-shifted), the
    owner's class read off it, and its label. Shared with the other Buff Duty
    files through ns.BuffDuty.
]]

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local Has = BuffDuty.Has
local SingleIcon = BuffDuty.SingleIcon
local CountsAsTank = BuffDuty.CountsAsTank
local IsPhaseShifted = BuffDuty.IsPhaseShifted

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

-- A pet's inline icon in front of its name, the window's icon size.
local LABEL_ICON_SIZE = Data.BUFF_DUTY_ICON_SIZE

--[[
    A pet's row label: its summoning spell's icon, then the name in its owner's
    class color. A warlock's demon is told apart by the creature ID in its GUID
    ("Pet-0-server-instance-zone-npc-spawn"); every other pet wears Call Pet.
]]
local function PetNPCID(unit)
	local guid = UnitGUID(unit)
	return ns.IsPlain(guid) and guid and tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")) or nil
end

--[[
    The class of a pet's owner, read off the pet: a known demon is a warlock's,
    and a pet that runs on Focus is a hunter's beast. The tooltip's "'s Pet" or
    "'s Minion" (`guessed`) is the last resort only -- on Classic Era it named
    the owner without matching the wording that gives the class away.
]]
function BuffDuty.PetOwnerClass(unit, guessed)
	local npcID = PetNPCID(unit)
	if npcID and ns.BUFF_DUTY_PET_ICONS.demons[npcID] then
		return "WARLOCK"
	end
	local powerType = UnitPowerType(unit)
	if ns.IsPlain(powerType) and Enum.PowerType.Focus and powerType == Enum.PowerType.Focus then
		return "HUNTER"
	end
	return guessed
end

local function PetLabel(unit, name, ownerClass)
	local icons = ns.BUFF_DUTY_PET_ICONS
	local npcID = PetNPCID(unit)
	local spell = (npcID and icons.demons[npcID]) or icons.beast
	local texture = spell and C_Spell.GetSpellTexture(spell)
	-- The same 5-pixel trim the window's buttons give every spell icon's border.
	local icon = texture
			and ("|T" .. texture .. ":" .. LABEL_ICON_SIZE .. ":" .. LABEL_ICON_SIZE .. ":0:0:64:64:5:59:5:59|t ")
		or ""
	return icon .. (ns.GetClassColor(ownerClass) or ns.GetColor("HELP")) .. name .. "|r"
end

--------------------------------------------------------------------------------
-- Pets
--------------------------------------------------------------------------------

--[[
    A pet takes the buffs offered to Everyone, and those offered to Tanks while
    Count as Tanks says pets do (by default only while you're not grouped:
    solo, a pet is usually what holds aggro) -- never those for Healers. It has
    no role of its own, and its "class" is the creature's, not a player class.
    Whether it has mana is read off its power bar instead, so a warlock's demon
    gets Intellect and a hunter's beast doesn't.
]]
local function PetWants(buff, unit)
	if buff.audience == Data.BUFF_AUDIENCE.TANK then
		if not CountsAsTank(Data.TANK_WHEN_PET) then
			return false
		end
	elseif buff.audience ~= Data.BUFF_AUDIENCE.ALL then
		return false
	end
	if buff.manaOnly then
		local powerType = UnitPowerType(unit)
		return ns.IsPlain(powerType) and powerType == Enum.PowerType.Mana
	end
	return true
end

--[[
    A mob that only borrows the pet slot -- a priest's Mind Control, a warlock's
    Enslave Demon -- until it breaks free. UnitIsCharmed alone misses a mind-
    controlled mob on Classic Era, so a pet that is neither a known demon nor a
    Focus beast (PetOwnerClass) and has no pet family is taken for one too: a
    humanoid has none, while a real pet's family names it ("Imp", "Cat").
]]
local function IsCharmedPet(unit)
	if UnitIsCharmed(unit) then
		return true
	end
	return not BuffDuty.PetOwnerClass(unit) and not UnitCreatureFamily(unit)
end

--[[
    A pet the window can't do anything for drops off the list rather than hold
    its owner's row, and the window, up: one out of sight (another zone, or
    past the client's view -- its buffs aren't sent and no cast reaches it),
    one the game won't let you help (UnitCanAssist), and on WoW Forever one
    whose identity is kept secret. A secret or missing answer to either
    question keeps the pet on: only a readable "no" drops it.

    A phase-shifted imp drops off too: nothing can reach it until it phases
    back in.
]]
local function CanBuffPet(unit)
	if not UnitExists(unit) or UnitIsPlayer(unit) or UnitIsDeadOrGhost(unit) then
		return false
	end
	if ns.IsUnitIdentitySecret(unit) then
		return false
	end
	local visible = UnitIsVisible(unit)
	if ns.IsPlain(visible) and not visible then
		return false
	end
	local canAssist = UnitCanAssist("player", unit)
	if ns.IsPlain(canAssist) and not canAssist then
		return false
	end
	return not IsPhaseShifted(unit) and not IsCharmedPet(unit)
end
BuffDuty.CanBuffPet = CanBuffPet

--------------------------------------------------------------------------------
-- Holds
--------------------------------------------------------------------------------

--[[
    GUID -> buff key -> GetTime() until which the pet isn't offered that buff
    even though it reads as missing.

    A pet's buffs reach the client less reliably than a player's, so a cast
    that went off on it (BuffDuty.NotePetCast) is taken at its word: the buff
    is held for as long as your cast of it lasts, less the Refresh Under time,
    whether or not the aura ever shows. If it does show, Has sees it first
    and the hold never matters.

    A cast the game refused outright -- not a valid target (BuffDuty.NotePetRefused)
    -- holds that buff for as long as the pet stays around: clicking again
    would only fail again.
]]
local holds = {}

-- How long a cast on a pet is trusted when you haven't seen how long that buff lasts yet.
local PET_HOLD_FALLBACK = 600
-- The shortest a cast on a pet is trusted, however soon it would want a refresh.
local PET_HOLD_MINIMUM = 60

local function BuffByKey(key)
	for _, buff in ipairs(buffs) do
		if buff.key == key then
			return buff
		end
	end
	return nil
end

local function Hold(guid, key, untilTime)
	if not (ns.IsPlain(guid) and guid and key) then
		return
	end
	holds[guid] = holds[guid] or {}
	holds[guid][key] = untilTime
end

function BuffDuty.NotePetCast(guid, key)
	local buff = BuffByKey(key)
	if not buff then
		return
	end
	local threshold = buff.refreshSeconds or BuffDuty.refreshSeconds
	local trusted = math.max((BuffDuty.MyDuration(buff) or PET_HOLD_FALLBACK) - threshold, PET_HOLD_MINIMUM)
	Hold(guid, key, GetTime() + trusted)
end

function BuffDuty.NotePetRefused(guid, key)
	Hold(guid, key, math.huge)
end

local function IsHeld(guid, key)
	local byKey = guid and holds[guid]
	local untilTime = byKey and byKey[key]
	if not untilTime then
		return false
	end
	if GetTime() < untilTime then
		return true
	end
	byKey[key] = nil
	return false
end

-- Drops every hold but those on the GUIDs in `keep`, from BuffDuty.PruneAuraCache.
function BuffDuty.PrunePetHolds(keep)
	for guid in pairs(holds) do
		if not keep[guid] then
			holds[guid] = nil
		end
	end
end

-- The pet token that goes with a group member's token.
function BuffDuty.PetUnitOf(unit)
	if unit == "player" then
		return "pet"
	end
	local prefix, index = unit:match("^(%a+)(%d+)$")
	return prefix and (prefix .. "pet" .. index) or nil
end

--[[
    A pet's row: its missing buffs, cast at `castUnit` (the pet's own token in
    the party list, "target" or "targetpet" in the Target list). Nil when it
    needs nothing. Under its owner it is indented and named alone; standing on
    its own (a targeted stranger's pet) it carries `ownerName` in brackets
    instead, "Valko (Kiib)", since the owner has no row of their own above it.
]]
function BuffDuty.PetRow(unit, castUnit, ownerClass, ownerName)
	if not unit or not CanBuffPet(unit) then
		return nil
	end
	BuffDuty.ReadAuras(unit)
	-- With any of its auras unreadable, a buff it looks to be missing may only be hidden from us.
	if not BuffDuty.AurasReadable() then
		return nil
	end
	local guid = UnitGUID(unit)
	guid = ns.IsPlain(guid) and guid or nil
	local name = GetUnitName(unit, false) or ""
	local icons = {}
	for _, buff in ipairs(buffs) do
		if buff.singleName and PetWants(buff, unit) then
			local has, expires, duration = Has(buff, unit)
			--[[
			    Once Has agrees the pet has the buff, a hold on it has done its
			    job: from here on Has alone decides. One that is only seen (it
			    reads as weaker, or running low, right after your cast landed)
			    keeps its hold until that runs out, so a version Has misjudges
			    on a pet can't bring the row straight back.
			]]
			if has and guid and holds[guid] then
				holds[guid][buff.key] = nil
			end
			if not has and not IsHeld(guid, buff.key) then
				icons[#icons + 1] = BuffDuty.WithTimeLeft(SingleIcon(buff, unit, castUnit, name), expires, duration)
			end
		end
	end
	if #icons == 0 then
		return nil
	end
	if ownerName then
		return {
			label = PetLabel(unit, ns.L["NAME_WITH_DETAIL_FORMAT"]:format(name, ownerName), ownerClass),
			icons = icons,
		}
	end
	return { label = PetLabel(unit, name, ownerClass), icons = icons, pet = true }
end
