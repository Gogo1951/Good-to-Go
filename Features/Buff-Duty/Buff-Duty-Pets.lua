local _, ns = ...
local Data = ns.Data

local BuffDuty = ns.BuffDuty
local buffs = BuffDuty.buffs
local Has = BuffDuty.Has
local SingleIcon = BuffDuty.SingleIcon
local CountsAsTank = BuffDuty.CountsAsTank
local IsPhaseShifted = BuffDuty.IsPhaseShifted

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

local LABEL_ICON_SIZE = Data.BUFF_DUTY_LABEL_ICON_SIZE

-- A warlock's demon is told apart by the creature ID in its GUID ("Pet-0-server-instance-zone-npc-spawn").
local function PetNPCID(unit)
	local guid = UnitGUID(unit)
	return ns.IsPlain(guid) and guid and tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")) or nil
end

--[[
    The tooltip's guess is the last resort only: on Classic Era it names the
    owner without the wording that gives the class away.
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
	local icon = texture
			and ("|T" .. texture .. ":" .. LABEL_ICON_SIZE .. ":" .. LABEL_ICON_SIZE .. ":0:0:64:64:5:59:5:59|t ")
		or ""
	return icon .. (ns.GetClassColor(ownerClass) or ns.GetColor("HELP")) .. name .. "|r"
end

--------------------------------------------------------------------------------
-- Pets
--------------------------------------------------------------------------------

--[[
    A pet's "class" is the creature's, so mana is read off its power bar. On
    WoW Forever a pet takes no stat buffs, so only rows marked pets = true.
]]
local function PetWants(buff, unit)
	if ns.BUFF_DUTY_PETS_FLAGGED_ONLY and not buff.pets then
		return false
	end
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
    UnitIsCharmed alone misses a mind-controlled mob on Classic Era, so a pet
    with no owner class and no creature family counts too: a humanoid has
    none, a real pet's family names it. A secret answer keeps the pet on.
]]
local function IsCharmedPet(unit)
	if ns.IsPlainTrue(UnitIsCharmed(unit)) then
		return true
	end
	local family = UnitCreatureFamily(unit)
	return not BuffDuty.PetOwnerClass(unit) and ns.IsPlain(family) and not family
end

--[[
    A pet the window can't help drops off rather than hold its owner's row,
    and the window, up. Only a readable "no" drops it.
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
    GUID -> buff key -> GetTime() the hold ends. A pet's buffs reach the client
    less reliably than a player's, so a cast that went off is taken at its
    word; a refused one holds while the pet stays around.
]]
local holds = {}

-- Until you've seen how long the buff lasts.
local PET_HOLD_FALLBACK = 600
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
BuffDuty.IsHeld = IsHeld

function BuffDuty.PrunePetHolds(keep)
	for guid in pairs(holds) do
		if not keep[guid] then
			holds[guid] = nil
		end
	end
end

function BuffDuty.PetUnitOf(unit)
	if unit == "player" then
		return "pet"
	end
	local prefix, index = unit:match("^(%a+)(%d+)$")
	return prefix and (prefix .. "pet" .. index) or nil
end

local function HeldIcons(unit, castUnit, name, wants)
	local guid = UnitGUID(unit)
	guid = ns.IsPlain(guid) and guid or nil
	local icons = {}
	for _, buff in ipairs(buffs) do
		if buff.singleName and wants(buff, unit) then
			local has, expires, duration = Has(buff, unit)
			--[[
			    Only Has agreeing clears a hold. One merely seen (weaker, or low,
			    right after your cast) keeps its hold, so a version Has misjudges
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
	return icons
end

-- Standing alone (a targeted stranger's pet) it carries `ownerName`, "Valko (Kiib)", since no owner row is above it.
function BuffDuty.PetRow(unit, castUnit, ownerClass, ownerName)
	if not unit or not CanBuffPet(unit) then
		return nil
	end
	BuffDuty.ReadAuras(unit)
	-- With any of its auras unreadable, a buff it looks to be missing may only be hidden from us.
	if not BuffDuty.AurasReadable() then
		return nil
	end
	local name = GetUnitName(unit, false) or ""
	local icons = HeldIcons(unit, castUnit, name, PetWants)
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
