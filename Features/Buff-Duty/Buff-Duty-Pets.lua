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

-- A pet's inline icon in front of its name, sized to the small font.
local LABEL_ICON_SIZE = 14

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

-- A phase-shifted imp drops off the list: nothing can reach it until it phases back in.
local function CanBuffPet(unit)
	return UnitExists(unit)
		and not UnitIsPlayer(unit)
		and not UnitIsDeadOrGhost(unit)
		and not IsPhaseShifted(unit)
		and not IsCharmedPet(unit)
end
BuffDuty.CanBuffPet = CanBuffPet

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
	local name = GetUnitName(unit, false) or ""
	local icons = {}
	for _, buff in ipairs(buffs) do
		if buff.singleName and PetWants(buff, unit) then
			local has, expires, duration = Has(buff, unit)
			if not has then
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
