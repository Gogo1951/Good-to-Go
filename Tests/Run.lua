--[[
    Offline tests. Dev-only: never listed in a TOC, and kept out of the release
    by .pkgmeta. Run from the add-on root with Lua 5.1, the version WoW embeds:
    lua5.1 Tests/Run.lua

    Event subscriptions: ns.SetModuleEvent asserts on any event missing from
    ns.EVENT_NAMES in Features/Core.lua, and that assert stops the feature's
    load at a player's login. This reads every Lua file the TOCs load and fails
    on any event a feature subscribes to, handles or lists that ns.EVENT_NAMES
    doesn't name, so the gap shows here instead.
]]

local failures = 0

local function Check(name, passed, detail)
	print((passed and "PASS " or "FAIL ") .. name)
	if not passed then
		failures = failures + 1
		if detail then
			print(detail)
		end
	end
end

local function ReadFile(path)
	local file = assert(io.open(path, "rb"))
	local text = file:read("*a")
	file:close()
	return (text:gsub("\r\n", "\n"))
end

--------------------------------------------------------------------------------
-- Tokenizer
--------------------------------------------------------------------------------

--[[
    Just enough of Lua 5.1's lexer to read names, strings and punctuation with
    their line numbers. Comments are dropped, and escapes are left as written,
    since an event name never holds one.
]]

local function CountNewlines(source, first, last)
	local _, count = source:sub(first, last):gsub("\n", "")
	return count
end

local function Tokenize(source)
	local tokens = {}
	local position, line, length = 1, 1, #source
	local function Push(kind, value)
		tokens[#tokens + 1] = { kind = kind, value = value, line = line }
	end
	while position <= length do
		local char = source:sub(position, position)
		if char == "\n" then
			line = line + 1
			position = position + 1
		elseif char:find("%s") then
			position = position + 1
		elseif source:find("^%-%-", position) then
			local level = source:match("^%-%-%[(=*)%[", position)
			local stop
			if level then
				local _, close = source:find("]" .. level .. "]", position + #level + 4, true)
				stop = close or length
			else
				stop = (source:find("\n", position, true) or length + 1) - 1
			end
			line = line + CountNewlines(source, position, stop)
			position = stop + 1
		elseif source:find("^%[=*%[", position) then
			local level = source:match("^%[(=*)%[", position)
			local open = #level + 2
			local _, close = source:find("]" .. level .. "]", position + open, true)
			close = close or length
			Push("string", source:sub(position + open, close - open))
			line = line + CountNewlines(source, position, close)
			position = close + 1
		elseif char == '"' or char == "'" then
			local index = position + 1
			while index <= length do
				local current = source:sub(index, index)
				if current == "\\" then
					index = index + 2
				elseif current == char or current == "\n" then
					break
				else
					index = index + 1
				end
			end
			Push("string", source:sub(position + 1, index - 1))
			line = line + CountNewlines(source, position, index)
			position = index + 1
		elseif char:find("[%a_]") then
			local name = source:match("^[%w_]+", position)
			Push("name", name)
			position = position + #name
		elseif char:find("%d") then
			position = position + #source:match("^%d[%w%.]*", position)
		else
			local op = source:match("^%.%.%.", position)
				or source:match("^[=~<>]=", position)
				or source:match("^%.%.", position)
				or char
			Push("op", op)
			position = position + #op
		end
	end
	return tokens
end

--------------------------------------------------------------------------------
-- Event Scanner
--------------------------------------------------------------------------------

local function IsEventShaped(text)
	return text:find("^[A-Z][A-Z0-9_]*_[A-Z0-9_]+$") ~= nil
end

-- A table or loop variable whose name says it holds events: EVENTS, EVENT_HANDLERS, eventHandlers, event.
local function NamesEvents(name)
	return name:lower():find("event", 1, true) ~= nil
end

--[[
    A call that subscribes to an event or attaches its handler: ns.SetModuleEvent and the features' wrappers,
    ns.SetEventRegistered, ns.SetRankWatchEvent, ns.SetBuffDutyEventHandler, ns.SetRankWatchHandler. The
    Diagnostics log's own entries (ns:LogEventNow("RESTOCKER_TRACE", ...)) are not events and don't match.
]]
local function SubscribesEvents(name)
	return name:find("^Set%w*Event") ~= nil or name:find("^Set%w*Handler$") ~= nil
end

local function Is(token, kind, value)
	return token ~= nil and token.kind == kind and (value == nil or token.value == value)
end

local function IsSeparator(token)
	return Is(token, "op", "{") or Is(token, "op", ",") or Is(token, "op", ";")
end

local BLOCK_OPENERS = { ["function"] = true, ["if"] = true, ["do"] = true, ["repeat"] = true }
local BLOCK_CLOSERS = { ["end"] = true, ["until"] = true }

--[[
    Reads the top level of the table constructor whose "{" is tokens[open]:
    each key (KEY = or ["KEY"] =) and each bare string item. Values below the
    top level -- nested tables, function bodies -- are skipped. Returns the
    index of the closing "}".
]]
local function ReadConstructor(tokens, open, owner, Found)
	local depth, blocks = 0, 0
	local index = open
	while tokens[index] do
		local token = tokens[index]
		if token.kind == "op" and (token.value == "{" or token.value == "(" or token.value == "[") then
			if depth == 1 and blocks == 0 and token.value == "[" and IsSeparator(tokens[index - 1]) then
				if Is(tokens[index + 1], "string") and Is(tokens[index + 2], "op", "]") then
					Found(tokens[index + 1], owner)
				end
			end
			depth = depth + 1
		elseif token.kind == "op" and (token.value == "}" or token.value == ")" or token.value == "]") then
			depth = depth - 1
			if depth == 0 then
				return index
			end
		elseif token.kind == "name" and BLOCK_OPENERS[token.value] then
			blocks = blocks + 1
		elseif token.kind == "name" and BLOCK_CLOSERS[token.value] then
			blocks = blocks - 1
		elseif depth == 1 and blocks == 0 and IsSeparator(tokens[index - 1]) then
			local nextToken = tokens[index + 1]
			if token.kind == "name" and Is(nextToken, "op", "=") then
				Found(token, owner)
			elseif
				token.kind == "string"
				and (Is(nextToken, "op", ",") or Is(nextToken, "op", ";") or Is(nextToken, "op", "}"))
			then
				Found(token, owner)
			end
		end
		index = index + 1
	end
	return index
end

--[[
    Every event name a file subscribes to, handles or lists, as
    { event, line, owner }. owner is the table a constructor or table.insert
    fills, so the caller can tell ns.EVENT_NAMES' own entries apart. It reads:
      - a table constructor assigned to a name that says events (EVENTS = { ... }, EVENT_HANDLERS = { KEY = ... })
      - an inline list a for loop over events walks (for _, event in ipairs({ ... }))
      - table.insert into such a table
      - a comparison against the dispatcher's event (event == "KEY")
      - a string argument to a call that subscribes or attaches a handler (ns.SetModuleEvent(MODULE, "KEY", ...))
]]
local function ScanEvents(source)
	local tokens = Tokenize(source)
	local found = {}
	local function Found(token, owner)
		if IsEventShaped(token.value) then
			found[#found + 1] = { event = token.value, line = token.line, owner = owner }
		end
	end

	for index, token in ipairs(tokens) do
		local nextToken = tokens[index + 1]
		if token.kind == "name" then
			if NamesEvents(token.value) and Is(nextToken, "op", "=") and Is(tokens[index + 2], "op", "{") then
				ReadConstructor(tokens, index + 2, token.value, Found)
			elseif token.value == "for" then
				local cursor, loopsEvents = index + 1, false
				while Is(tokens[cursor], "name") or Is(tokens[cursor], "op", ",") do
					if Is(tokens[cursor], "name", "in") then
						break
					end
					if tokens[cursor].kind == "name" and NamesEvents(tokens[cursor].value) then
						loopsEvents = true
					end
					cursor = cursor + 1
				end
				local iterator = tokens[cursor + 1]
				if
					loopsEvents
					and Is(tokens[cursor], "name", "in")
					and (Is(iterator, "name", "ipairs") or Is(iterator, "name", "pairs"))
					and Is(tokens[cursor + 2], "op", "(")
					and Is(tokens[cursor + 3], "op", "{")
				then
					ReadConstructor(tokens, cursor + 3, nil, Found)
				end
			elseif
				token.value == "table"
				and Is(nextToken, "op", ".")
				and Is(tokens[index + 2], "name", "insert")
				and Is(tokens[index + 3], "op", "(")
			then
				local cursor = index + 4
				while tokens[cursor] and not Is(tokens[cursor], "op", ",") and not Is(tokens[cursor], "op", ")") do
					cursor = cursor + 1
				end
				local target = tokens[cursor - 1]
				if
					Is(tokens[cursor], "op", ",")
					and Is(target, "name")
					and NamesEvents(target.value)
					and Is(tokens[cursor + 1], "string")
				then
					Found(tokens[cursor + 1], target.value)
				end
			elseif token.value:lower() == "event" and (Is(nextToken, "op", "==") or Is(nextToken, "op", "~=")) then
				if Is(tokens[index + 2], "string") then
					Found(tokens[index + 2])
				end
			elseif SubscribesEvents(token.value) and Is(nextToken, "op", "(") then
				-- The call's own arguments only: an inline handler's body compares combat-log subevents, not events.
				local depth, blocks, cursor = 0, 0, index + 1
				while tokens[cursor] do
					local current = tokens[cursor]
					if current.kind == "name" and BLOCK_OPENERS[current.value] then
						blocks = blocks + 1
					elseif current.kind == "name" and BLOCK_CLOSERS[current.value] then
						blocks = blocks - 1
					elseif
						current.kind == "op" and (current.value == "(" or current.value == "{" or current.value == "[")
					then
						depth = depth + 1
					elseif
						current.kind == "op" and (current.value == ")" or current.value == "}" or current.value == "]")
					then
						depth = depth - 1
						if depth == 0 then
							break
						end
					elseif depth == 1 and blocks == 0 and current.kind == "string" then
						Found(current)
					end
					cursor = cursor + 1
				end
			end
		elseif token.kind == "string" and (Is(nextToken, "op", "==") or Is(nextToken, "op", "~=")) then
			local other = tokens[index + 2]
			if Is(other, "name") and other.value:lower() == "event" then
				Found(token)
			end
		end
	end
	return found
end

-- The events a scan found that aren't in `known`, leaving out the list's own entries.
local function MissingEvents(found, known, listName)
	local missing = {}
	for _, entry in ipairs(found) do
		if (listName == nil or entry.owner ~= listName) and not known[entry.event] then
			missing[#missing + 1] = entry
		end
	end
	return missing
end

local function EventSet(found, listName)
	local set, count = {}, 0
	for _, entry in ipairs(found) do
		if entry.owner == listName and not set[entry.event] then
			set[entry.event] = true
			count = count + 1
		end
	end
	return set, count
end

--------------------------------------------------------------------------------
-- The Scanner Itself
--------------------------------------------------------------------------------

do
	local KNOWN = { PLAYER_LOGIN = true, SPELLS_CHANGED = true, UNIT_PET = true }
	local cases = {
		{
			"an event map's key (the PET_BAR_UPDATE gap)",
			'local EVENT_HANDLERS = {\n\tSPELLS_CHANGED = "OnSpellsChanged",\n\tPET_BAR_UPDATE = "OnPetBarUpdate",\n}',
			"PET_BAR_UPDATE",
		},
		{ "an event list's item", 'local EVENTS = { "SPELLS_CHANGED", "BAG_UPDATE_DELAYED" }', "BAG_UPDATE_DELAYED" },
		{ "a bracketed key", 'local ALWAYS_EVENTS = { ["MERCHANT_SHOW"] = true }', "MERCHANT_SHOW" },
		{
			"a handler map's key, ns field",
			"ns.restockerEventHandlers = {\n\tBANKFRAME_OPENED = function() end,\n}",
			"BANKFRAME_OPENED",
		},
		{
			"an inline loop list",
			'for _, event in ipairs({ "PLAYER_LOGIN", "READY_CHECK" }) do\n\tns.SetModuleEvent(MODULE, event, true)\nend',
			"READY_CHECK",
		},
		{ "table.insert into an event list", 'table.insert(WINDOW_EVENTS, "UNIT_AURA")', "UNIT_AURA" },
		{ "a direct subscription", 'ns.SetModuleEvent(MODULE, "TRAINER_SHOW", true)', "TRAINER_SHOW" },
		{ "a wrapper's subscription", 'ns.SetEventRegistered("UNIT_AURA", true, "player")', "UNIT_AURA" },
		{ "a handler attached by name", 'ns.SetBuffDutyEventHandler("REPLACE_ENCHANT", OnReplace)', "REPLACE_ENCHANT" },
		{
			"a handler attached without Event in the name",
			'ns.SetRankWatchHandler("PLAYER_ALIVE", On)',
			"PLAYER_ALIVE",
		},
		{ "a dispatcher comparison", 'if event == "UPDATE_BINDINGS" then end', "UPDATE_BINDINGS" },
	}
	for _, case in ipairs(cases) do
		local missing = MissingEvents(ScanEvents(case[2]), KNOWN)
		Check("scanner reads " .. case[1], #missing == 1 and missing[1].event == case[3])
	end

	local quiet = table.concat({
		'local EVENT_UNITS = { UNIT_PET = { "player" } }',
		"ns.restockerEventHandlers = {",
		"\tSPELLS_CHANGED = function()",
		'\t\tlocal NOT_EVENT, OTHER = Read("ADDON_TITLE", "BUTTON_LABEL")',
		'\t\treturn L["SOME_KEY"]',
		"\tend,",
		"}",
		'-- EVENTS = { "IN_A_COMMENT" }',
		'local text = L["EVENT_LOG_TITLE"]',
		'print("NOT_AN_EVENT")',
		'ns:LogEventNow("RESTOCKER_TRACE", message)',
		'ns.SetRankWatchHandler("UNIT_PET", function()',
		'\tif subevent ~= "SPELL_CAST_SUCCESS" then return end',
		"end)",
	}, "\n")
	local missing = MissingEvents(ScanEvents(quiet), KNOWN)
	local names = {}
	for _, entry in ipairs(missing) do
		names[#names + 1] = entry.event
	end
	Check(
		"scanner skips function bodies, comments, log entries and other strings",
		#missing == 0,
		table.concat(names, ", ")
	)
end

--------------------------------------------------------------------------------
-- Every Subscription Is in ns.EVENT_NAMES
--------------------------------------------------------------------------------

local TOCS = {
	"Good-to-Go_Vanilla.toc",
	"Good-to-Go_TBC.toc",
	"Good-to-Go_Mists.toc",
	"Good-to-Go_Camelot.toc",
}

-- The add-on's own Lua files, every flavor's, in first-listed order. Libraries and locales subscribe to nothing.
local function LoadedFiles()
	local files, seen = {}, {}
	for _, toc in ipairs(TOCS) do
		for line in ReadFile(toc):gmatch("[^\n]+") do
			local path = line:gsub("\\", "/"):match("^%s*(.-)%s*$")
			local skipped = path:find("^#") or path:find("^Includes/") or path:find("^Locales/")
			if not skipped and path:find("%.lua$") and not seen[path] then
				seen[path] = true
				files[#files + 1] = path
			end
		end
	end
	return files
end

do
	local CORE = "Features/Core.lua"
	local LIST = "EVENT_NAMES"

	-- Every flavor's entries: Core adds the combat log outside Forever, as the feature that subscribes to it does.
	local known, count = EventSet(ScanEvents(ReadFile(CORE)), LIST)
	Check("ns.EVENT_NAMES reads from " .. CORE, count > 0 and known.PLAYER_LOGIN == true)

	local files = LoadedFiles()
	Check("the TOCs list the add-on's files", #files > 0)

	local gaps, readsPetBar = {}, false
	for _, path in ipairs(files) do
		local found = ScanEvents(ReadFile(path))
		for _, entry in ipairs(found) do
			if path == "Features/Enhanced-Spellbook/Spellbook-Core.lua" and entry.event == "PET_BAR_UPDATE" then
				readsPetBar = true
			end
		end
		for _, entry in ipairs(MissingEvents(found, known, LIST)) do
			gaps[#gaps + 1] =
				string.format("    %s:%d: %s is missing from ns.EVENT_NAMES in %s", path, entry.line, entry.event, CORE)
		end
	end
	Check("the scan reaches Enhanced Spellbook's event map", readsPetBar)
	Check("every event a feature subscribes to is in ns.EVENT_NAMES", #gaps == 0, table.concat(gaps, "\n"))
end

--------------------------------------------------------------------------------
-- Forever Never Registers the Combat Log
--------------------------------------------------------------------------------

--[[
    Registering COMBAT_LOG_EVENT_UNFILTERED on WoW Forever raises
    ADDON_ACTION_FORBIDDEN, so Rank Watch's combat-log detection must stay out
    of Good-to-Go_Camelot.toc. A shared file may still name the event, but only
    behind a flavor check against "Camelot" (as Features/Core.lua and
    Buff-Duty-Events.lua do), so a Camelot-listed file that names it without
    one fails here.
]]
do
	local TOC = "Good-to-Go_Camelot.toc"
	local trapped = {}
	for line in ReadFile(TOC):gmatch("[^\n]+") do
		local path = line:gsub("\\", "/"):match("^%s*(.-)%s*$")
		local skipped = path:find("^#") or path:find("^Includes/") or path:find("^Locales/")
		if not skipped and path:find("%.lua$") then
			local source = ReadFile(path)
			local guarded = source:find('ns%.FLAVOR%s*~=%s*"Camelot"') ~= nil
			for _, entry in ipairs(ScanEvents(source)) do
				if entry.event == "COMBAT_LOG_EVENT_UNFILTERED" and not guarded then
					trapped[#trapped + 1] = string.format("    %s:%d names it with no Camelot check", path, entry.line)
				end
			end
		end
	end
	Check(TOC .. " lists no file that registers the combat log", #trapped == 0, table.concat(trapped, "\n"))
end

--------------------------------------------------------------------------------
-- Other-Client Characters
--------------------------------------------------------------------------------

--[[
    Features/Core.lua's prune of characters copied in from another game
    version (Style Guide: SAVED VARIABLES, Other-Client Characters), run in
    both directions against AceDB-shaped tables. Its functions are lifted out
    of Core by their source text and run in a sandbox, so nothing else in the
    file loads.
]]
local function LoadPrune()
	local source = ReadFile("Features/Core.lua")
	local first = source:find("local REALM_KEY_SEPARATOR", 1, true)
	local header = source:find("local function PruneOtherClientCharacters", 1, true)
	local last = header and source:find("\nend\n", header, true)
	if not (first and last) then
		return nil
	end
	local chunk = assert(loadstring(source:sub(first, last + 4) .. "return PruneOtherClientCharacters", "Core prune"))
	return function(db)
		setfenv(chunk, {
			ns = { db = db },
			type = type,
			pairs = pairs,
			ipairs = ipairs,
			GetRealmName = function()
				return "Realm"
			end,
		})
		chunk()()
	end
end

-- An AceDB-shaped saved table holding each character key, each on a profile of its own name.
local function SeededDB(currentKey, characterKeys)
	local sv = { char = {}, profileKeys = {}, profiles = { Default = { kept = true } } }
	for _, key in ipairs(characterKeys) do
		sv.char[key] = { seen = true }
		sv.profileKeys[key] = key
		sv.profiles[key] = { mine = true }
	end
	return { keys = { char = currentKey, profile = currentKey }, sv = sv, global = {} }
end

local function Kept(db, key)
	return db.sv.char[key] ~= nil and db.sv.profileKeys[key] ~= nil and db.sv.profiles[key] ~= nil
end

local function Gone(db, key)
	return db.sv.char[key] == nil and db.sv.profileKeys[key] == nil and db.sv.profiles[key] == nil
end

do
	local Prune = LoadPrune()
	Check("the other-client prune reads from Features/Core.lua", Prune ~= nil)
	if Prune then
		-- Forever: a realm client's character goes, Default stays.
		local forever = SeededDB("First Last", { "First Last", "Name - Realm", "First - PvE" })
		Prune(forever)
		Check("Forever drops a copied realm character", Gone(forever, "Name - Realm"))
		Check("Forever keeps its own character", Kept(forever, "First Last"))
		Check("Forever leaves the Default profile", forever.sv.profiles.Default ~= nil)
		-- MIGRATION (remove after 2026-12-08): the older Forever name (IsOlderForeverKey) stays for its copy.
		Check("Forever keeps an older Forever name", Kept(forever, "First - PvE"))

		-- A realm client: a Forever character goes, another realm's character stays.
		local realm = SeededDB("Me - Realm", { "Me - Realm", "First Last", "Other - OtherRealm" })
		Prune(realm)
		Check("a realm client drops a copied Forever character", Gone(realm, "First Last"))
		Check("a realm client keeps another realm's character", Kept(realm, "Other - OtherRealm"))
		Check("a realm client keeps its own character", Kept(realm, "Me - Realm"))
	end
end

--------------------------------------------------------------------------------
-- Event Log Noise
--------------------------------------------------------------------------------

--[[
    Diagnostics/Event-Log.lua's capture filter (Build Reference: Event Log
    Noise), run in a sandbox against UI_ERROR_MESSAGE, which carries its
    message id first. ns.IsCorrelatedMessage stands in for Buff Duty's
    allowlist, correlating only CORRELATED_ID.
]]
local CORRELATED_ID = 300
local NOISE_ID = 51

local function LoadEventLog()
	local chunk = assert(loadstring(ReadFile("Diagnostics/Event-Log.lua"), "Event-Log"))
	local ns = {
		diagnostics = {},
		GetDiagnosticClientHeader = function()
			return "Header"
		end,
		IsCorrelatedMessage = function(event, id)
			return event == "UI_ERROR_MESSAGE" and id == CORRELATED_ID
		end,
	}
	setfenv(chunk, {
		bit = { band = function() end },
		GetTime = function()
			return 0
		end,
		rawget = rawget,
		select = select,
		type = type,
		pairs = pairs,
		ipairs = ipairs,
		tostring = tostring,
		unpack = unpack,
		string = string,
		table = table,
		_G = {},
	})
	chunk("Good-to-Go", ns)
	return ns
end

do
	local ns = LoadEventLog()
	ns:StartEventLog()
	for _ = 1, 100 do
		ns:LogEvent("UI_ERROR_MESSAGE", NOISE_ID, "Ability is not ready yet.")
	end
	local counters = ns.diagnostics.suppressed.UI_ERROR_MESSAGE
	local report = ns:BuildEventLogReport()
	Check(
		"event log folds uncorrelated spam into one counted row",
		#ns.diagnostics.log == 0
			and counters ~= nil
			and counters[NOISE_ID] ~= nil
			and counters[NOISE_ID].count == 100
			and report:find("UI_ERROR_MESSAGE(51, Ability is not ready yet.) x100", 1, true) ~= nil,
		report
	)

	ns:LogEvent("UI_ERROR_MESSAGE", CORRELATED_ID, "A more powerful spell is already active.")
	Check(
		"event log keeps a correlated id as a full line",
		#ns.diagnostics.log == 1
			and ns.diagnostics.log[1]:find("UI_ERROR_MESSAGE(300, A more powerful spell", 1, true) ~= nil,
		ns.diagnostics.log[1]
	)

	ns:LogEvent("UI_ERROR_MESSAGE", "no id")
	Check(
		"event log keeps a firing with no id verbatim",
		#ns.diagnostics.log == 2 and ns.diagnostics.log[2]:find("UI_ERROR_MESSAGE(no id)", 1, true) ~= nil,
		ns.diagnostics.log[2]
	)
end

--------------------------------------------------------------------------------

print(failures == 0 and "All tests passed." or string.format("%d test(s) failed.", failures))
if failures > 0 then
	os.exit(1)
end
