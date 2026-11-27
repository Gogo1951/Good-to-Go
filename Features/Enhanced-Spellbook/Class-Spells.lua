local _, ns = ...

-- By ID: the book shows some spells under a name /cast can't use (Call Pet as "Call" plus the pet's name).
local function CastName(id, bookName)
	return id and C_Spell.GetSpellName(id) or bookName
end

--[[
	MoP Classic's book holds Call Pet as a flyout plus its five spells as entries of their own, pet or not.
	/cast Call Pet works, so the flyout is one macro under its book name and the five are left out.
]]

-- the flyout's spell IDs and the first one known (for the icon and tooltip), or nil without the flyout
local function CallPetFlyout()
	local found
	for line = 1, GetNumSpellTabs() do
		local _, _, offset, numSlots = GetSpellTabInfo(line)
		for slot = offset + 1, offset + numSlots do
			local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
			if itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID then
				found = true
			end
		end
	end
	if not found then
		return nil
	end
	local members, firstKnown = {}, nil
	local _, _, numSlots = GetFlyoutInfo(ns.CALL_PET_FLYOUT_ID)
	for flyoutSlot = 1, numSlots or 0 do
		local spellId, _, isKnown = GetFlyoutSlotInfo(ns.CALL_PET_FLYOUT_ID, flyoutSlot)
		if spellId then
			members[spellId] = true
			if isKnown and not firstKnown then
				firstKnown = spellId
			end
		end
	end
	return members, firstKnown
end

--[[
	Classic Era shares its client with Season of Discovery, and its book can list SoD's rune abilities
	(Metamorphosis : Demon Charge) though Era can't cast them.
]]
local HIDES_SOD_SPELLS = ns.FLAVOR == "Vanilla" and not ns.IS_DISCOVERY

local function IsOtherSeasonSpell(id)
	return HIDES_SOD_SPELLS and id ~= nil and id >= ns.SOD_FIRST_SPELL_ID
end

--[[
	The Retail engine keeps professions out of the skill lines, so they're read after them as one more line.
	GetProfessions returns nil for a slot with nothing learned, so its values are walked by count.
]]
local function ForEachProfessionSlot(fn, ...)
	if not GetProfessionInfo then
		return
	end
	for i = 1, select("#", ...) do
		local index = select(i, ...)
		if index then
			local _, _, _, _, numAbilities, spellOffset = GetProfessionInfo(index)
			for slot = (spellOffset or 0) + 1, (spellOffset or 0) + (numAbilities or 0) do
				fn(slot)
			end
		end
	end
end

--[[
	fn(name, icon, spellId, skillLineName, skillLineIndex, subName) for every learned, castable spell, in skill
	line order; subName is the book's "Rank 3" or nil.
]]
if C_SpellBook.GetNumSpellBookSkillLines then
	function ns.ForEachClassSpell(fn)
		local bank = Enum.SpellBookSpellBank.Player
		local function visit(slot, lineName, line)
			local item = C_SpellBook.GetSpellBookItemInfo(slot, bank)
			if item and item.itemType == Enum.SpellBookItemType.Spell and not item.isPassive and not item.isOffSpec then
				local id = item.spellID or item.actionID
				if not IsOtherSeasonSpell(id) then
					fn(CastName(id, item.name), item.iconID, id, lineName, line, item.subName)
				end
			end
		end
		local numLines = C_SpellBook.GetNumSpellBookSkillLines()
		for line = 1, numLines do
			local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
			if info and not info.shouldHide and not info.offSpecID then
				for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
					visit(slot, info.name, line)
				end
			end
		end
		if GetProfessions then
			local professionsName = ns.L["CATEGORY_PROFESSIONS"]
			ForEachProfessionSlot(function(slot)
				visit(slot, professionsName, numLines + 1)
			end, GetProfessions())
		end
	end
else
	function ns.ForEachClassSpell(fn)
		local callPetSpells, callPetId = CallPetFlyout()
		for line = 1, GetNumSpellTabs() do
			local lineName, _, offset, numSlots = GetSpellTabInfo(line)
			for slot = offset + 1, offset + numSlots do
				local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
				if
					itemType == "SPELL"
					and not IsPassiveSpell(slot, BOOKTYPE_SPELL)
					and not IsOtherSeasonSpell(id)
					and not (callPetSpells and callPetSpells[id])
				then
					local name, subName = GetSpellBookItemName(slot, BOOKTYPE_SPELL)
					fn(CastName(id, name), GetSpellBookItemTexture(slot, BOOKTYPE_SPELL), id, lineName, line, subName)
				elseif itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID and callPetId then
					fn(
						GetSpellBookItemName(slot, BOOKTYPE_SPELL),
						GetSpellBookItemTexture(slot, BOOKTYPE_SPELL),
						callPetId,
						lineName,
						line
					)
				end
			end
		end
	end
end
