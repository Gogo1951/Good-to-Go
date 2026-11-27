local _, ns = ...

-- nil or "" conditions are skipped; "" when nothing is left, so a plain cast stays "/cast Name".
local function Condition(...)
	local parts = {}
	for i = 1, select("#", ...) do
		local condition = select(i, ...)
		if condition and condition ~= "" then
			parts[#parts + 1] = condition
		end
	end
	return #parts > 0 and "[" .. table.concat(parts, ",") .. "]" or ""
end

--[[
	A clause is { condition, unit, spell, own = true }: spell nil means spellFor(unit); own marks the macro's own
	clauses, as against a Conditionals row's or a right-click's. Neighboring clauses that cast the same spell
	share it ("[@mouseover,help,nodead][] Name"). With reset the line is a /castsequence of each spell then
	nothing, so it casts once until that reset. With a sequence ({ reset, tail }) only the own clauses go on
	through the tail; the others cast their one spell, as a /cast would.
]]
local function CastLine(clauses, spellFor, reset, sequence)
	local groups = {}
	for _, clause in ipairs(clauses) do
		local condition = Condition(clause[1])
		local spell = clause[3] or spellFor(clause[2])
		local own = clause.own == true
		local last = groups[#groups]
		if last and last.spell == spell and last.own == own then
			last.condition = last.condition .. (condition ~= "" and condition or "[]")
		else
			groups[#groups + 1] = { condition = condition, spell = spell, own = own }
		end
	end
	local parts = {}
	for i, group in ipairs(groups) do
		local resetText, tail = reset, reset and ", NULL" or ""
		if sequence then
			resetText, tail = group.own and sequence.reset or nil, group.own and sequence.tail or ""
		end
		parts[i] = (group.condition ~= "" and group.condition .. " " or "")
			.. (resetText and "reset=" .. resetText .. " " or "")
			.. group.spell
			.. tail
	end
	return ((reset or sequence) and "/castsequence " or "/cast ") .. table.concat(parts, "; ")
end

-- Any further below a rank's level and the cast fails with "Target is too low level".
local RANK_LEVEL_GAP = 10

--[[
	nil for the highest rank, which a plain cast already picks. An absent or unhelpable unit means the cast lands
	on the player; an unknown level (UnitLevel's -1) or a unit Forever keeps secret in combat takes the highest too.
]]
local function RankFor(ranks, unit)
	if not unit or unit == "player" or ns.IsUnitIdentitySecret(unit) then
		return nil
	end
	local exists, canAssist, level = UnitExists(unit), UnitCanAssist("player", unit), UnitLevel(unit)
	if not (ns.IsPlain(exists) and ns.IsPlain(canAssist) and ns.IsPlain(level)) then
		return nil
	end
	if not exists or not canAssist or not level or level <= 0 then
		return nil
	end
	for i, rank in ipairs(ranks) do
		if level >= rank.level - RANK_LEVEL_GAP then
			return i > 1 and rank.text or nil
		end
	end
	return ranks[#ranks].text -- too low for any rank; the lowest fails with the game's own message
end

-- What MacroBody writes with no options on, before the tag line.
function ns.BareBody(name)
	return "#showtooltip\n/cast " .. name
end

-- A Warrior stance not learned yet takes its slot from stanceSlots, the order they are learned in.
local function StanceSlot(stance)
	local config = ns.ClassConfig()
	local stanceId = config.stanceIds[stance]
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		if spellID and spellID == stanceId then
			return i
		end
	end
	return config.stanceSlots[stance]
end

-- e.g. "/cast [nostance:1/3] Battle Stance\n", or "" when the first stance's slot is unknown.
local function StanceLine(stances)
	if not StanceSlot(stances[1]) then
		return ""
	end
	local slots = {}
	for _, stance in ipairs(stances) do
		slots[#slots + 1] = StanceSlot(stance)
	end
	return "/cast [nostance:" .. table.concat(slots, "/") .. "] " .. stances[1] .. "\n"
end

--[[
	Only the class lists' stances count: a tooltip names forms, which some locales (esES) name apart from the
	stance spells.
]]
function ns.StancesOf(name)
	local config = ns.ClassConfig()
	if not config.hasStances then
		return nil
	end
	return config.stances[name]
end

-- The target last is the plain cast, and the player always takes it, so nothing after the player is ever tried.
local function TargetClauses(list, target, life)
	local clauses = {}
	for i, unit in ipairs(list) do
		if unit == "player" then
			clauses[#clauses + 1] = { "@player", "player" }
			return clauses
		elseif unit == "target" then
			if i == #list then
				break
			end
			clauses[#clauses + 1] = { target .. "," .. life, "target" }
		else
			clauses[#clauses + 1] = { "@" .. unit .. "," .. target .. "," .. life, unit }
		end
	end
	clauses[#clauses + 1] = { "", "target" }
	return clauses
end

local function CastBody(macro)
	--[[
		One /stopmacro covers stopIfChanneling, stopIfStealthed and the combat check, so a stopped press does
		nothing at all, and sits ahead of the mute so it never leaves the sounds muted.
	]]
	local combatCheck = ns.CombatCheck(macro)
	local stops = (ns.IsOptionOn(macro, "stopIfChanneling") and "[channeling]" or "")
		.. (ns.IsOptionOn(macro, "stopIfStealthed") and "[stealth]" or "")
		.. (combatCheck == "combatOnly" and "[nocombat]" or combatCheck == "noCombat" and "[combat]" or "")
	-- oncePerCombat also resets when the target changes, so a new pull mid-combat can take the cast again
	local perCombat = ns.IsOptionOn(macro, "oncePerCombat")
	local perTarget = perCombat or ns.IsOptionOn(macro, "oncePerTarget")
	local reset = perCombat and "combat/target" or perTarget and "target" or nil
	local stopCast = ns.IsOptionOn(macro, "stopCast") and "/stopcasting\n"
	local useLines = {}
	for i, slot in ipairs(ns.UseItemSlots(macro)) do
		useLines[i] = "/use " .. slot .. "\n"
	end
	local use = table.concat(useLines)
	local stance = ns.IsOptionOn(macro, "stance") and StanceLine(macro.stances) or ""
	--[[
		a once-per /castsequence's button would show the step after the cast, so it names the spell; a Cast
		Sequence shows its next step on purpose
	]]
	local namesSpell = stance ~= "" or use ~= "" or reset ~= nil
	local cast = ns.CastSpellName(macro)
	local shown = cast
	if ns.IsOptionOn(macro, "pet") then
		shown = "[pet:" .. macro.petFamily .. "] " .. macro.petAbility .. "; " .. shown
	end
	local header = "#showtooltip"
		.. (namesSpell and " " .. shown or "")
		.. "\n"
		.. (stops ~= "" and "/stopmacro " .. stops .. "\n" or "")
		.. (ns.IsOptionOn(macro, "muteErrors") and "/run GtGMute(1)\n" or "")
		.. (ns.IsOptionOn(macro, "stopAttack") and "/stopattack\n" or "")
		.. (stopCast or "")
		.. (ns.IsOptionOn(macro, "cancelForm") and "/cancelform\n" or "")
		.. (ns.IsOptionOn(macro, "targetEnemy") and "/cleartarget [dead][help]\n/targetenemy [noexists]\n" or "")
		.. (ns.IsOptionOn(macro, "targetFriend") and "/cleartarget [dead][harm]\n/targetfriend [noexists]\n" or "")
		.. use
		.. stance
	-- "!Name" refreshes a form or aspect that is on instead of canceling it
	local prefix = ns.IsOptionOn(macro, "noToggle") and "!" or ""
	-- the ranks are the spell's own, so a grouped spell cast in its place takes its highest
	local ownSpell = cast == macro.name
	local targetRank = ownSpell and ns.IsOptionOn(macro, "targetRank")
	local fixedRank = ownSpell and not targetRank and ns.FixedRank(macro)
	local name = cast
	local target = macro.target
	local function spellFor(unit)
		local rank = fixedRank or (targetRank and macro.ranks and RankFor(macro.ranks, unit))
		return prefix .. name .. (rank and "(" .. rank .. ")" or "")
	end
	local spell = spellFor(nil)
	local life = macro.kind == "resurrect" and "dead" or "nodead"
	local clauses = TargetClauses(ns.TargetPriority(macro), target, life)
	if ns.IsOptionOn(macro, "cursor") then
		clauses = { { "@cursor" } }
	end
	-- the macro's own clauses, which a Cast Sequence carries on from
	for _, clause in ipairs(clauses) do
		clause.own = true
	end
	-- one clause per ranged attack by [worn:], so a weapon swapped mid-fight needs no rewrite
	if macro.rangedAttacks then
		local worn = {}
		for _, attack in ipairs(ns.RANGED_ATTACKS) do
			local attackName = ns.SpellName(attack.id)
			local wornName = ns.RangedWornName(attack)
			-- a weapon the client can't name gets no clause, rather than an English one that never matches
			if attackName and wornName and macro.rangedAttacks[attackName] then
				local condition = "worn:" .. wornName
				for _, clause in ipairs(clauses) do
					local unitCondition = clause[1] or ""
					worn[#worn + 1] = {
						(unitCondition ~= "" and unitCondition .. "," or "") .. condition,
						clause[2],
						prefix .. attackName,
					}
				end
			end
		end
		clauses = worn
	end
	--[[
		right-click clauses go ahead; with Dynamic Rank they take their own ranks, so a right-click on a low-level
		target doesn't fail as too low level
	]]
	if ns.IsOptionOn(macro, "groupVersion") then
		local rightClick, ranks = ns.RightClickSpell(macro), macro.rightClickRanks
		local dynamic = ns.IsOptionOn(macro, "targetRank") and ranks
		local clicks = {}
		for i, clause in ipairs(clauses) do
			local rank = dynamic and RankFor(ranks, clause[2])
			clicks[i] = {
				"btn:2" .. ((clause[1] or "") ~= "" and "," .. clause[1] or ""),
				clause[2],
				rightClick .. (rank and "(" .. rank .. ")" or ""),
			}
		end
		for _, clause in ipairs(clauses) do
			clicks[#clicks + 1] = clause
		end
		clauses = clicks
	end
	if ns.IsOptionOn(macro, "pet") then
		-- [pet:X] matches the pet's creature family, so another demon being out still summons this one
		clauses = { { "pet:" .. macro.petFamily, nil, macro.petAbility }, { "", nil, spell } }
		reset = nil
	end
	-- Conditionals rows first, so the first that matches casts and the macro's own clauses are what is left
	local rows = ns.ConditionalClauses(macro)
	for _, clause in ipairs(clauses) do
		rows[#rows + 1] = clause
	end
	local sequence = ns.IsCastSequenceOn(macro)
		and { reset = ns.CastSequenceResetText(macro), tail = ns.CastSequenceTail(macro) }
	return header .. CastLine(rows, spellFor, reset, sequence or nil)
end

--[[
	"!" never stops Auto Shot; /startattack skips stealth, where Pick Pocket, Sap or Distract would pull the
	player out of it.
]]
function ns.MacroBody(macro)
	return ns.TaggedBody(
		macro,
		CastBody(macro)
			.. (ns.IsOptionOn(macro, "autoShot") and "\n/cast !" .. ns.ClassConfig().autoShot or "")
			.. (ns.IsOptionOn(macro, "startAttack") and "\n/startattack [nostealth]" or "")
			.. (ns.IsOptionOn(macro, "petAttack") and "\n/petattack" or "")
			.. (ns.IsOptionOn(macro, "hideErrors") and "\n/run UIErrorsFrame:Clear()" or "")
			.. (ns.IsOptionOn(macro, "muteErrors") and "\n/run GtGMute()" or "")
	)
end
