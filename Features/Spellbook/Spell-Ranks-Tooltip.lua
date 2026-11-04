local _, ns = ...
local L = ns.L

--[[
	A spell's ranks and the level each needs, "GtG // Firebolt Ranks" and a line for each (ns.AddSpellRanksTooltip;
	the What's Next? rows, Features/Spellbook/Whats-Next-Page.lua, use ns.SpellRankRows and ns.AddSpellRankLines),
	under every spell tooltip the game shows: action bars, the game's own spell book, other add-ons. Tooltips that
	add the ranks themselves (the Spell Book page's tiles, the What's Next? rows) set ns.spellTooltipHasOwnRanks
	around their SetSpellByID so the lines aren't doubled.
]]

--[[
	Before the hovered rank in the tooltip's list of ranks, and before every other rank a gap as wide: the same
	arrow cropped to its clear top-left pixel, so each rank's text starts in the same place.
]]
local RANK_MARKER = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:0|t "
local RANK_SPACER = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:0:0:0:0:16:16:0:1:0:1|t "

--[[
	The ranks of row's spell among rows, by level: the rows of the same name (an extraSpells row, Polymorph
	(Pig), isn't one of its namesake's ranks), from all of them, whatever a page's filters hide.
]]
local function RankRows(rows, row)
	local ranks = {}
	for _, other in ipairs(rows) do
		if other.name == row.name and (not other.extra) == not row.extra then
			ranks[#ranks + 1] = other
		end
	end
	table.sort(ranks, function(a, b)
		if (a.level or 0) ~= (b.level or 0) then
			return (a.level or 0) < (b.level or 0)
		end
		return a.id < b.id
	end)
	return ranks
end
ns.SpellRankRows = RankRows

--[[
	A rank's colour (ns.SPELL_RANK_COLORS): known; its level reached and not trained; or its level still to
	come. A pet's rank waits on the pet's level, the rest on the player's.
]]
local function RankColor(rank, level)
	local kind
	if rank.status == "KNOWN" then
		kind = "KNOWN"
	elseif rank.status == "SOON" or rank.status == "LATER" or (rank.level or 0) > level then
		kind = "NOT_YET"
	else
		kind = "LEARNABLE"
	end
	return ns.GetColor(ns.SPELL_RANK_COLORS[kind])
end

--[[
	"GtG // Firebolt Ranks", then each rank of row's spell among rows in its ns.SPELL_RANK_COLORS colour, row's own
	rank marked, with the level it needs in the silver of helper text.
]]
local function AddRankLines(rows, row)
	GameTooltip:AddLine(
		ns.GetColor("INFO")
			.. L["ADDON_SHORT_NAME"]
			.. "|r "
			.. ns.GetColor("SEPARATOR")
			.. "//|r "
			.. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(L["WHATS_NEXT_TOOLTIP_RANKS"]:format(row.name))
	)
	local pet = ns.WhatsNextPet and ns.WhatsNextPet(true)
	for _, rank in ipairs(RankRows(rows, row)) do
		local label = (rank.subtext and rank.subtext ~= "") and rank.subtext or rank.name
		-- a pet ability's row says whether it's ready to teach; a class spell's has no ready
		local level = rank.ready ~= nil and pet and pet.level or UnitLevel("player")
		GameTooltip:AddDoubleLine(
			(rank == row and RANK_MARKER or RANK_SPACER) .. RankColor(rank, level) .. label .. "|r",
			ns.GetColor("HELP") .. (rank.level and L["SUBTEXT_LEARN_LEVEL"]:format(rank.level) or "") .. "|r"
		)
	end
end
ns.AddSpellRankLines = AddRankLines

--[[
	Adds the ranks of spellID's spell to GameTooltip, for a tooltip outside the What's Next? tabs: the Spell Book
	page's tiles (Features/Spellbook/Macro-Button.lua) and the Pet Spell Book's rows. pet reads the pet's
	abilities (ns.WhatsNextPetRows) rather than the class's (ns.WhatsNextRows); blankFirst puts a blank line
	above them; rows, where given, stands in for either (CachedRows, below).
	Returns whether it added any: nothing for a spell the rows don't hold or with one rank.
]]
function ns.AddSpellRanksTooltip(spellID, pet, blankFirst, rows)
	rows = rows or (pet and ns.WhatsNextPetRows() or ns.WhatsNextRows())
	local row
	for _, candidate in ipairs(rows) do
		if candidate.id == spellID then
			row = candidate
			break
		end
	end
	-- a spell the rows don't list by this ID (a rank the data leaves out) still finds its namesakes
	if not row then
		local name = ns.SpellName(spellID)
		row = name and { id = spellID, name = name } or nil
	end
	if not row or #RankRows(rows, row) < 2 then
		return false
	end
	if blankFirst then
		GameTooltip:AddLine(" ")
	end
	AddRankLines(rows, row)
	return true
end

-- An action bar's tooltip refreshes several times a second; the rows behind it are rebuilt at most once a second.
local ROWS_LIFETIME = 1
local cache = {}

local function CachedRows(pet)
	local key = pet and "pet" or "class"
	local entry = cache[key]
	local now = GetTime()
	if not entry or now - entry.at > ROWS_LIFETIME then
		entry = { at = now, rows = pet and ns.WhatsNextPetRows() or ns.WhatsNextRows() }
		cache[key] = entry
	end
	return entry.rows
end

-- One set of rank lines per showing, though the client may report the same spell more than once.
local added = false

local function AddRanks(tooltip, spellID)
	if tooltip ~= GameTooltip or added or ns.spellTooltipHasOwnRanks or not ns.IsSpellbookEnabled() then
		return
	end
	-- in combat a spell's tooltip stays the game's own, short
	if InCombatLockdown() then
		return
	end
	if not spellID or not ns.IsPlain(spellID) or not ns.AddSpellRanksTooltip then
		return
	end
	-- the class's spells first, then a hunter's beast's or a warlock's demon's abilities
	if
		ns.AddSpellRanksTooltip(spellID, false, true, CachedRows(false))
		or (ns.HasWhatsNextPet() and ns.AddSpellRanksTooltip(spellID, true, true, CachedRows(true)))
	then
		added = true
		tooltip:Show()
	end
end

GameTooltip:HookScript("OnTooltipCleared", function()
	added = false
end)

ns.AddSpellTooltipPostCall(AddRanks)
