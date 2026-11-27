local _, ns = ...
local L = ns.L

--[[
    Ability Alerts While Leveling, on its own switch: it runs whether Rank Watch or the Enhanced Spellbook is
    on or not, since the What's Next? rows it reads need neither.

		Good to Go // You can now learn [Bash] and [Moonfire] (Rank 3).
		Good to Go // Don't forget, you can also learn [Moonfire] (Rank 2).
		Good to Go // Your pet can now learn [Great Stamina] (Rank 4).
		Good to Go // Don't forget, your pet can also learn [Growl] (Rank 3).
]]

local MODULE = "LevelUpAlerts"

-- A hunter tames its first pet at 10, so no pet line prints before then (Growl's rank 1 is a level 1 row).
local HUNTER_PET_LEVEL = 10

local function Settings()
	return ns.RankWatchSettings()
end

--------------------------------------------------------------------------------
-- Lines
--------------------------------------------------------------------------------

-- "A", "A and B", "A, B, and C".
local function JoinSpells(parts)
	if #parts == 1 then
		return parts[1]
	elseif #parts == 2 then
		return L["LIST_PAIR_FORMAT"]:format(parts[1], parts[2])
	end
	local head = table.concat(parts, L["LIST_SEPARATOR"], 1, #parts - 1)
	return L["LIST_LAST_FORMAT"]:format(head, parts[#parts])
end

local function RankOf(row)
	return row.subtext and tonumber(row.subtext:match("%d+"))
end

-- A spell's higher rank first; a rank 1 shows no rank. Nil for no rows.
local function SpellsLine(formatKey, rows)
	if #rows == 0 then
		return nil
	end
	table.sort(rows, function(a, b)
		if a.name ~= b.name then
			return a.name < b.name
		end
		return (RankOf(a) or 0) > (RankOf(b) or 0)
	end)
	local parts = {}
	for _, row in ipairs(rows) do
		local text = ns.GetSpellLink(row.id) or row.name
		if (RankOf(row) or 1) > 1 then
			text = text .. " " .. L["WHATS_NEXT_SUBTEXT"]:format(row.subtext)
		end
		parts[#parts + 1] = text
	end
	return L[formatKey]:format(JoinSpells(parts))
end

local function IsWarlock()
	return select(2, UnitClass("player")) == "WARLOCK"
end

local function Add(lines, line)
	lines[#lines + 1] = line
end

--[[
    A hunter's pet ranks read against the hunter's level, since the hunter buys them; taming ranks are left
    out, since no trainer teaches them. On WoW Forever only the pet out knows what it has learned. A warlock
    gets only this level's demon ranks: what a demon learned leaves no trace while it is away, so there's no
    telling which were skipped.
]]
local function LevelUpLines(level)
	local settings, lines = Settings(), {}
	if not settings or not settings.levelUpAlerts then
		return lines
	end

	local opened, waiting = {}, {}
	for _, row in ipairs(ns.WhatsNextRows(level)) do
		if row.source == "TRAINER" and row.status == "AVAILABLE" then
			local list = row.level == level and opened or waiting
			list[#list + 1] = row
		end
	end
	Add(lines, SpellsLine("LEVEL_UP_SPELLS", opened))
	if settings.levelUpAlertsPast then
		Add(lines, SpellsLine("LEVEL_UP_SPELLS_NOT_LEARNED", waiting))
	end

	if not settings.levelUpAlertsPet or not (ns.HasWhatsNextPet and ns.HasWhatsNextPet()) then
		return lines
	end
	local warlock = IsWarlock()
	if not warlock and level < HUNTER_PET_LEVEL then
		return lines
	end
	local petOpened, petWaiting = {}, {}
	local petRows, pet = ns.WhatsNextPetRows(level)
	for _, row in ipairs(petRows) do
		local fromTrainer, ready = warlock, true
		if row.source == "TRAINER" then
			fromTrainer = not row.ready
		elseif row.source == "HUNTER_TRAINER" then
			-- With no pet out nothing reads as known, and nothing earlier is listed as waiting.
			fromTrainer = row.status ~= "KNOWN" and row.status ~= "OTHER"
			ready = pet ~= nil and row.status == "AVAILABLE"
		end
		if fromTrainer and row.level == level then
			petOpened[#petOpened + 1] = row
		elseif fromTrainer and ready and not warlock and row.level < level then
			petWaiting[#petWaiting + 1] = row
		end
	end
	Add(lines, SpellsLine(warlock and "LEVEL_UP_DEMON_SPELLS" or "LEVEL_UP_PET_SPELLS", petOpened))
	if settings.levelUpAlertsPetPast and not warlock then
		Add(lines, SpellsLine("LEVEL_UP_PET_SPELLS_NOT_LEARNED", petWaiting))
	end
	return lines
end

--------------------------------------------------------------------------------
-- The Options Panel's Example
--------------------------------------------------------------------------------

local function SampleRow(id)
	local name = ns.SpellName(id)
	if not name then
		return nil
	end
	return { id = id, name = name, subtext = C_Spell.GetSpellSubtext(id) }
end

-- Two rows from the first level of 10 or more that has two, and one from the level before it.
local function SampleSets(list, include)
	local byLevel, levels = {}, {}
	for _, row in ipairs(list or {}) do
		local sample = include(row) and row.level and SampleRow(row.id)
		if sample then
			if not byLevel[row.level] then
				byLevel[row.level] = {}
				levels[#levels + 1] = row.level
			end
			table.insert(byLevel[row.level], sample)
		end
	end
	table.sort(levels)
	for index = 2, #levels do
		local samples = byLevel[levels[index]]
		if levels[index] >= 10 and #samples >= 2 then
			return { samples[1], samples[2] }, { byLevel[levels[index - 1]][1] }
		end
	end
	return {}, {}
end

local function FromClassTrainer(row)
	return not (row.talent or row.book or row.quest)
end

-- A class without a pet borrows a hunter's pet trainer, so the pet lines still show.
function ns.LevelUpAlertExample()
	local settings, lines = Settings(), {}
	local opened, waiting = SampleSets(ns.ClassTrainerRows(), FromClassTrainer)
	Add(lines, SpellsLine("LEVEL_UP_SPELLS", opened))
	if settings.levelUpAlertsPast then
		Add(lines, SpellsLine("LEVEL_UP_SPELLS_NOT_LEARNED", waiting))
	end
	if settings.levelUpAlertsPet then
		local warlock = IsWarlock() and ns.DEMON_ABILITIES ~= nil
		local list = warlock and ns.DEMON_ABILITIES or ns.PET_ABILITIES
		local petOpened, petWaiting = SampleSets(list, function(row)
			return warlock or row.source == "TRAINER" or row.source == "HUNTER_TRAINER"
		end)
		Add(lines, SpellsLine(warlock and "LEVEL_UP_DEMON_SPELLS" or "LEVEL_UP_PET_SPELLS", petOpened))
		if settings.levelUpAlertsPetPast and not warlock then
			Add(lines, SpellsLine("LEVEL_UP_PET_SPELLS_NOT_LEARNED", petWaiting))
		end
	end
	return lines
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- level is the event's: UnitLevel still reports the old one while PLAYER_LEVEL_UP fires.
ns.RegisterEventModule(MODULE, function(event, level)
	if event == "PLAYER_LEVEL_UP" then
		for _, line in ipairs(LevelUpLines(level)) do
			ns:PrintMessage(line)
		end
	end
end)

ns.SetModuleEvent(MODULE, "PLAYER_LEVEL_UP", true)
