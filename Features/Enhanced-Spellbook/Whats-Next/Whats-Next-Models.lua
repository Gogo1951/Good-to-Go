local _, ns = ...
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local L = ns.L
local GetColor = ns.GetColor
local MUTED = ns.COLORS_RGB.MUTED
local BRIGHT = ns.WHATS_NEXT_BRIGHT

--[[
	The models of the What's Next? tabs' pages (Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Page.lua), ns.WHATS_NEXT_MODELS:
	the class spells this character can learn, is about to, or already has, from ns.WhatsNextRows
	(Features/Enhanced-Spellbook/Whats-Next/Whats-Next.lua); for a hunter or warlock its pet's abilities, from ns.WhatsNextPetRows
	(Features/Enhanced-Spellbook/Whats-Next/Whats-Next-Pet.lua); and the pet's own spellbook, from ns.PetSpellbookRows
	(Features/Enhanced-Spellbook/Whats-Next/Pet-Spellbook.lua). The three pages differ only in their model: the rows, statuses,
	sources, settings and tooltip lines.
]]

-- the most tameable beasts a pet ability's tooltip names before "And N more"
local MAX_BEASTS = 6

local function Bright(status, text)
	return "|cff" .. BRIGHT[status] .. text .. "|r"
end
ns.WhatsNextBright = Bright

-- A label and its value on one tooltip line, the label in the title color.
local function AddPair(label, value)
	GameTooltip:AddDoubleLine(label, value, TITLE.r, TITLE.g, TITLE.b, BODY.r, BODY.g, BODY.b)
end

local function AddBody(text)
	GameTooltip:AddLine(text, BODY.r, BODY.g, BODY.b, true)
end

--[[
	What each page lists and how, as { rows, statuses, sources, counts, statusLabel, shortLabel, sourceLabel,
	shows, toggles, sortDescription, empty, addTooltip, footer, rightText, pickup, hideTooltipStatus }:
	  rows(level)         the rows and a context the footer reads; level as ns.RefreshWhatsNext takes it
	  statuses, sources   in the order Sort By Availability and the source filter list them; no sources, no
	                      source filter
	  counts              the statuses the footer counts, or a function giving them
	  statusLabel(status) a status's name, for its heading, the tooltip and the footer
	  shortLabel(status)  a status's short name, at a row's right
	  sourceLabel(source) a source's name, for the source filter and the tooltip
	  shows(row)          whether the settings let a row show
	  toggles             the settings gear's checkboxes, each { label key, description key, getter, setter },
	                      or a function giving them when the gear opens; none, no gear
	  sortDescription     the sort dropdown's tooltip; none, no sort, the rows only under their statuses
	  empty               the empty note's key, or a function of the context giving its text
	  addTooltip(row, model) the tooltip's lines after the status
	  footer(context)     the text at the footer's right, or nil
	  rightText(row)      the text at a row's right in place of its level, where given
	  pickup(row)         puts the row's spell on the cursor for a click or drag, where given
	  hideTooltipStatus   leaves the status line out of the tooltip
]]

local CLASS_MODEL = {
	rows = function(level)
		return ns.WhatsNextRows(level)
	end,
	statuses = ns.WHATS_NEXT_STATUSES,
	sources = ns.WHATS_NEXT_SOURCES,
	counts = { "AVAILABLE", "SOON", "LATER", "MISSING" },
	-- Season of Discovery's talents not taken include its runes.
	statusLabel = function(status)
		if status == "TALENT" and ns.IS_DISCOVERY then
			return L["WHATS_NEXT_STATUS_TALENT_RUNE"]
		end
		return L["WHATS_NEXT_STATUS_" .. status]
	end,
	shortLabel = function(status)
		return L["WHATS_NEXT_SHORT_" .. status]
	end,
	sourceLabel = function(source)
		return L["WHATS_NEXT_SOURCE_" .. source]
	end,
	shows = function(row)
		if row.status == "KNOWN" and not ns.WhatsNextShowsKnown() then
			return false
		end
		return row.status ~= "TALENT" or ns.WhatsNextShowsTalents()
	end,
	toggles = {
		{
			"WHATS_NEXT_SHOW_KNOWN",
			"WHATS_NEXT_SHOW_KNOWN_DESCRIPTION",
			ns.WhatsNextShowsKnown,
			ns.SetWhatsNextShowKnown,
		},
		{
			ns.IS_DISCOVERY and "WHATS_NEXT_SHOW_TALENTS_RUNES" or "WHATS_NEXT_SHOW_TALENTS",
			"WHATS_NEXT_SHOW_TALENTS_DESCRIPTION",
			ns.WhatsNextShowsTalents,
			ns.SetWhatsNextShowTalents,
		},
	},
	sortDescription = "WHATS_NEXT_SORT_DESCRIPTION",
	-- With known spells hidden, an empty page points at the toggle that lists them.
	empty = function()
		if ns.WhatsNextShowsKnown() then
			return L["WHATS_NEXT_EMPTY"]
		end
		return L["WHATS_NEXT_EMPTY_KNOWN_HIDDEN"]:format(L["WHATS_NEXT_SHOW_KNOWN"])
	end,
	addTooltip = function(row, model)
		if row.source then
			AddPair(L["WHATS_NEXT_TOOLTIP_SOURCE"], model.sourceLabel(row.source))
		end
		if row.level then
			AddPair(L["WHATS_NEXT_TOOLTIP_LEVEL"], tostring(row.level))
		end
		if row.status == "KNOWN" then
			return
		end
		-- how it's learned, then what it waits on
		local how = row.source and L["WHATS_NEXT_TOOLTIP_HOW_" .. row.source]
		if how then
			AddBody(how)
		end
		for _, id in ipairs(row.status == "MISSING" and row.waitsOn or {}) do
			local name = ns.SpellName(id)
			if name then
				local subtext = C_Spell.GetSpellSubtext(id)
				if subtext and subtext ~= "" then
					name = name .. " " .. L["WHATS_NEXT_SUBTEXT"]:format(subtext)
				end
				GameTooltip:AddLine(Bright("MISSING", L["WHATS_NEXT_TOOLTIP_NEEDS"]:format(name)), nil, nil, nil, true)
			end
		end
	end,
}

--[[
	The beasts that teach a pet ability rank by taming, the ones the hunter can tame by now first (highest
	first, so the nearest to its level lead), then the rest from the lowest: "Forest Spider (5-6)" with its
	zone at the right, up to MAX_BEASTS of them and a count of the rest.
]]
local function AddBeasts(beasts)
	local level = UnitLevel("player")
	local list = {}
	for _, id in ipairs(beasts) do
		local beast = ns.TAMEABLE_BEASTS[id]
		if beast then
			list[#list + 1] = beast
		end
	end
	table.sort(list, function(a, b)
		local aTameable, bTameable = a[2] <= level, b[2] <= level
		if aTameable ~= bTameable then
			return aTameable
		end
		if aTameable then
			return a[2] > b[2]
		end
		return a[2] < b[2]
	end)
	if #list == 0 then
		return
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["WHATS_NEXT_PET_TOOLTIP_BEASTS"], TITLE.r, TITLE.g, TITLE.b)
	for i = 1, math.min(#list, MAX_BEASTS) do
		local beast = list[i]
		local levels = beast[2] == beast[3] and tostring(beast[2]) or (beast[2] .. "-" .. beast[3])
		local zone = C_Map.GetAreaInfo(beast[4]) or ""
		-- a beast still above your level in the palette's gray, so it reads as not yet
		local ink = beast[2] <= level and BODY or MUTED
		local r, g, b = ink.r, ink.g, ink.b
		GameTooltip:AddDoubleLine(L["WHATS_NEXT_PET_TOOLTIP_BEAST"]:format(beast[1], levels), zone, r, g, b, r, g, b)
	end
	if #list > MAX_BEASTS then
		AddBody(L["WHATS_NEXT_PET_TOOLTIP_MORE"]:format(#list - MAX_BEASTS))
	end
end

--[[
	The footer of both pet tabs: the pet out, its level and family, and its training points left; or that there's
	none out, and what the statuses read instead: the hunter's Beast Training, or nothing where there's none
	(WoW Forever).
]]
local function PetFooter(pet)
	if not pet then
		return L[ns.WhatsNextPetUsesBeastTraining() and "WHATS_NEXT_PET_NO_PET" or "WHATS_NEXT_PET_NO_PET_SUMMON"]
	end
	local text = L["WHATS_NEXT_PET_FOOTER"]:format(pet.name or "", pet.level or 0, pet.family or "")
	local left, total = ns.WhatsNextPetTrainingPoints()
	if left and total > 0 then
		text = text .. "   " .. L["WHATS_NEXT_PET_FOOTER_TRAINING_POINTS"]:format(left, total)
	end
	return text
end

local PET_STATUSES = { TEACH = true, OTHER = true }

--[[
	A grimoire whose name hasn't loaded reads as loading, and the item is asked for; when it arrives, the row
	tooltip still showing it is drawn again. The shared GET_ITEM_INFO_RECEIVED subscription (Features/Item-Info.lua)
	is held only while a grimoire is waited on.
]]
local GRIMOIRE_WAITER = "WhatsNextGrimoire"
local waitingGrimoires = {}

local function GrimoireName(itemID)
	local name = C_Item.GetItemNameByID(itemID)
	if name then
		return name
	end
	waitingGrimoires[itemID] = true
	ns.RequestItemInfoEvents(GRIMOIRE_WAITER)
	C_Item.RequestLoadItemDataByID(itemID)
	return GetColor("MUTED") .. L["LOADING_ITEM"]:format(itemID) .. "|r"
end

function ns.OnWhatsNextItemInfoReceived(itemID)
	if not waitingGrimoires[itemID] then
		return
	end
	waitingGrimoires[itemID] = nil
	if next(waitingGrimoires) == nil then
		ns.ReleaseItemInfoEvents(GRIMOIRE_WAITER)
	end
	local owner = GameTooltip:IsShown() and GameTooltip:GetOwner()
	if owner and owner.row and owner.row.item == itemID and owner:IsMouseOver() then
		owner:GetScript("OnEnter")(owner)
	end
end

--[[
	A rank is ready to teach only through a warlock's grimoire or a hunter's Beast Training; WoW Forever's hunter
	trainer teaches the pet out directly, so there the footer has no Ready to Teach count.
]]
local PET_COUNTS = { "TEACH", "AVAILABLE", "SOON", "LATER" }
local PET_COUNTS_NO_TEACH = { "AVAILABLE", "SOON", "LATER" }

local SHOW_KNOWN_TOGGLE = {
	"WHATS_NEXT_PET_SHOW_KNOWN",
	"WHATS_NEXT_PET_SHOW_KNOWN_DESCRIPTION",
	ns.WhatsNextPetShowsKnown,
	ns.SetWhatsNextPetShowKnown,
}
local SHOW_OTHER_TOGGLE = {
	"WHATS_NEXT_PET_SHOW_OTHER",
	"WHATS_NEXT_PET_SHOW_OTHER_DESCRIPTION",
	ns.WhatsNextPetShowsOtherFamilies,
	ns.SetWhatsNextPetShowOtherFamilies,
}

local PET_MODEL = {
	rows = function(level)
		return ns.WhatsNextPetRows(level)
	end,
	statuses = ns.WHATS_NEXT_PET_STATUSES,
	sources = ns.WHATS_NEXT_PET_SOURCES,
	counts = function()
		if ns.IsWhatsNextPetWarlock() or ns.WhatsNextPetUsesBeastTraining() then
			return PET_COUNTS
		end
		return PET_COUNTS_NO_TEACH
	end,
	-- the pet's own statuses have their own labels; the rest read as the class tab's
	statusLabel = function(status)
		return L[(PET_STATUSES[status] and "WHATS_NEXT_PET_STATUS_" or "WHATS_NEXT_STATUS_") .. status]
	end,
	shortLabel = function(status)
		return L[(PET_STATUSES[status] and "WHATS_NEXT_PET_SHORT_" or "WHATS_NEXT_SHORT_") .. status]
	end,
	sourceLabel = function(source)
		return L["WHATS_NEXT_PET_SOURCE_" .. source]
	end,
	shows = function(row)
		if row.status == "KNOWN" then
			return ns.WhatsNextPetShowsKnown()
		end
		return row.status ~= "OTHER" or ns.WhatsNextPetShowsOtherFamilies()
	end,
	-- Show Other Families' Abilities only where some rank is limited to some families
	toggles = function()
		if ns.WhatsNextPetHasFamilies() then
			return { SHOW_KNOWN_TOGGLE, SHOW_OTHER_TOGGLE }
		end
		return { SHOW_KNOWN_TOGGLE }
	end,
	sortDescription = "WHATS_NEXT_PET_SORT_DESCRIPTION",
	empty = "WHATS_NEXT_PET_EMPTY",
	addTooltip = function(row, model)
		AddPair(L["WHATS_NEXT_TOOLTIP_SOURCE"], model.sourceLabel(row.source))
		-- a demon's rank and WoW Forever's hunter ranks ask for the player's level, Beast Training for the pet's
		local playerLevel = row.item or row.source == "DEMON_TRAINER" or ns.WhatsNextPetReadsHunterLevel(row)
		AddPair(L[playerLevel and "WHATS_NEXT_TOOLTIP_LEVEL" or "WHATS_NEXT_PET_TOOLTIP_LEVEL"], tostring(row.level))
		if row.item then
			AddPair(L["WHATS_NEXT_PET_TOOLTIP_GRIMOIRE"], GrimoireName(row.item))
		end
		if row.tp then
			AddPair(L["WHATS_NEXT_PET_TOOLTIP_TRAINING_POINTS"], tostring(row.tp))
		end
		if row.status == "KNOWN" then
			return
		elseif row.status == "OTHER" then
			AddBody(L["WHATS_NEXT_PET_TOOLTIP_OTHER"])
			return
		end
		-- what to do next: teach it, or get it first
		if row.ready then
			AddBody(L[row.item and "WHATS_NEXT_PET_TOOLTIP_GRIMOIRE_IN_BAGS" or "WHATS_NEXT_PET_TOOLTIP_HUNTER_KNOWS"])
		else
			--[[
				WoW Forever has no Beast Training, so a taming rank comes only with the beast tamed, and no grimoires,
				so the demon trainer teaches a demon's rank itself
			]]
			local how = "WHATS_NEXT_PET_TOOLTIP_HOW_" .. row.source
			if row.source == "TAMING" and not ns.WhatsNextPetUsesBeastTraining() then
				how = "WHATS_NEXT_PET_TOOLTIP_HOW_TAMING_NEW_PET"
			elseif row.source == "DEMON_TRAINER" and not row.item then
				how = "WHATS_NEXT_PET_TOOLTIP_HOW_DEMON_TRAINER_TEACHES"
			end
			AddBody(L[how])
			if row.beasts then
				AddBeasts(row.beasts)
			end
		end
	end,
	footer = function(pet)
		if not pet and ns.IsWhatsNextPetWarlock() then
			return L["WHATS_NEXT_PET_NO_DEMON"]
		end
		return PetFooter(pet)
	end,
}

-- The pet's spellbook: no source filter, sort or settings, its abilities then its passives, each placeable on a bar.
local PET_BOOK_MODEL = {
	rows = function()
		return ns.PetSpellbookRows()
	end,
	statuses = ns.PET_SPELLBOOK_STATUSES,
	counts = {},
	-- the spell's own tooltip says what it is; a section name adds nothing
	hideTooltipStatus = true,
	statusLabel = function(status)
		return L["PET_SPELLBOOK_STATUS_" .. status]
	end,
	shortLabel = function(status)
		return L["PET_SPELLBOOK_STATUS_" .. status]
	end,
	shows = function()
		return true
	end,
	empty = function(pet)
		return L[pet and "PET_SPELLBOOK_EMPTY" or "PET_SPELLBOOK_NO_PET"]
	end,
	-- whether the pet casts it on its own, where it can
	rightText = function(row)
		if not row.autocastAllowed then
			return ""
		end
		return L[row.autocastOn and "PET_SPELLBOOK_AUTOCAST_ON" or "PET_SPELLBOOK_AUTOCAST_OFF"]
	end,
	addTooltip = function(row)
		if ns.HasWhatsNextPet() then
			ns.AddSpellRanksTooltip(row.id, true, true)
		end
		if not row.passive then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(
				GetColor("INFO") .. L["TOOLTIP_KEY_CLICK_DRAG"] .. "|r",
				GetColor("INFO") .. L["TOOLTIP_ACTION_PLACE_ON_BAR"] .. "|r"
			)
		end
	end,
	pickup = function(row)
		if not row.passive then
			ns.PickupPetSpell(row.slot)
		end
	end,
	footer = function(pet)
		return pet and PetFooter(pet) or ""
	end,
}

ns.WHATS_NEXT_MODELS = { CLASS = CLASS_MODEL, PET = PET_MODEL, PET_BOOK = PET_BOOK_MODEL }
