local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Client Emote Catalog
--------------------------------------------------------------------------------

--[[
    Every emote the RUNNING client can perform, read from its own EMOTE<n>_TOKEN
    and EMOTE<n>_CMD<n> globals rather than from a list kept in this add-on.

    Deliberately not a data file. The set differs per expansion, so a
    hand-maintained copy would be correct on exactly one client and quietly wrong
    on the others -- and it is a long list to get wrong. Reading the client means
    a dropdown built from this offers precisely what this build can perform, and
    Diagnostics can export the same list from any flavor without a code change.

    Two traps the scan has to respect. Indices are SPARSE (Era jumps 171 -> 304),
    so it cannot stop at the first gap. And a few tokens appear twice under
    different indices (INCOMING, FLEE), so tokens are deduped -- the dropdown
    should not offer the same emote twice.

    Sorted by the slash command players recognize, not by token or index. Built
    once on demand; these globals do not change during a session.
]]
local EMOTE_SCAN_CEILING = 1000 -- backstop only, for a client without MAXEMOTEINDEX

local emoteCatalog, emoteTokens

local function BuildEmoteCatalog()
	emoteCatalog, emoteTokens = {}, {}

	--[[
	    The client's own list of emotes that play a voice line. Absent on some
	    builds, in which case the voice column simply reads unknown.
	]]
	local voice = {}
	if type(TextEmoteSpeechList) == "table" then
		for _, entry in pairs(TextEmoteSpeechList) do
			voice[tostring(entry)] = true
		end
	end

	for index = 1, (MAXEMOTEINDEX or EMOTE_SCAN_CEILING) do
		local token = _G["EMOTE" .. index .. "_TOKEN"]
		if token and not emoteTokens[token] then
			--[[
			    CMD1 is the primary; the rest are aliases, and the client repeats the
			    whole set once per locale, so exact repeats are dropped.
			]]
			local aliases, seen = {}, {}
			for c = 1, 8 do
				local command = _G["EMOTE" .. index .. "_CMD" .. c]
				if command and command ~= "" and not seen[command] then
					seen[command] = true
					aliases[#aliases + 1] = command
				end
			end
			local entry = {
				index = index,
				token = token,
				command = aliases[1] or ("/" .. token:lower()),
				aliases = table.concat(aliases, " "),
				voice = voice[token] == true,
			}
			emoteTokens[token] = entry
			emoteCatalog[#emoteCatalog + 1] = entry
		end
	end

	table.sort(emoteCatalog, function(a, b)
		return a.command < b.command
	end)
end

-- Every client emote, sorted by slash command.
function ns.GetEmoteCatalog()
	if not emoteCatalog then
		BuildEmoteCatalog()
	end
	return emoteCatalog
end

-- Is this token something the running client can actually perform?
function ns.IsClientEmote(token)
	if not emoteTokens then
		BuildEmoteCatalog()
	end
	return token ~= nil and emoteTokens[token] ~= nil
end

-- The slash command this client gives an emote token, in its own language.
function ns.GetEmoteCommand(token)
	if not emoteTokens then
		BuildEmoteCatalog()
	end
	local entry = emoteTokens[token]
	return entry and entry.command or ("/" .. token:lower())
end

--------------------------------------------------------------------------------
-- Sound
--------------------------------------------------------------------------------

--[[
    The sound plays on the Master channel so it stays audible for players who
    run with game sound effects turned down. The file name must match
    Includes/Sounds/ exactly.
]]
local SOUND_ROOT = "Interface/AddOns/" .. ADDON_NAME .. "/Includes/Sounds/"

-- Any buff landing on you shares this one, stranger or teammate alike.
function ns.PlayBuffSound()
	PlaySoundFile(SOUND_ROOT .. "Buff.ogg", "Master")
end
