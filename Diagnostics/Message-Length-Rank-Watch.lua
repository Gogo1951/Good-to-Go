local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local ShownText = ns.DiagnosticShownText

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- The longest name a character or a hunter's pet can have, in letters.
local NAME_MAX_LETTERS = 12

-- A rank as a whisper names it, unlinked: the client's spell name and rank text, in bytes.
local function RankBytes(row)
	local name = C_Spell.GetSpellName(row.id) or tostring(row.id)
	return #name + #ns.RankWatchRankText(row)
end

--[[
    The rank with the longest name in this locale among the ladders given, as the cast a whisper names, with its
    ladder's top rank as the better one. Only a rank with one above it is ever reported, so a ladder's top rank is
    never the cast.
]]
local function LongestCast(byClass, owner)
	local castRow, betterRow, longest
	for class, list in pairs(byClass) do
		if not owner or class == owner then
			for _, ladder in ipairs(list) do
				for index = 1, #ladder.rows - 1 do
					local bytes = RankBytes(ladder.rows[index])
					if not longest or bytes > longest then
						castRow, betterRow, longest = ladder.rows[index], ladder.rows[#ladder.rows], bytes
					end
				end
			end
		end
	end
	return castRow, betterRow
end

--[[
    Every whisper Rank Watch sends, built through its own ns.BuildRankWatchWhisper with the rank whose name runs
    longest in this locale and a 12-letter pet name, each with its byte length against the chat limit, OVER past
    it. The builder links the spell, and names it unlinked when the link won't fit; the line says which it took.
    Then the opt-out offer and its answer. It builds strings only: nothing is sent.
]]
function ns:BuildRankWatchMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	if not ns.BuildRankWatchWhisper then
		lines[#lines + 1] = "Rank Watch is not part of this flavor."
		return table.concat(lines, "\n")
	end
	local petName = string.rep("W", NAME_MAX_LETTERS)
	local whispers = {
		{ label = "Rank Watch whisper", ladders = ns.RankWatchLadders() },
		{
			label = "Rank Watch whisper, a hunter's pet",
			ladders = ns.RankWatchPetLadders(),
			owner = "HUNTER",
			pet = { name = petName, isDemon = false },
		},
		{
			label = "Rank Watch whisper, a warlock's demon",
			ladders = ns.RankWatchPetLadders(),
			owner = "WARLOCK",
			pet = { name = petName, isDemon = true },
		},
	}
	for _, whisper in ipairs(whispers) do
		local castRow, betterRow = LongestCast(whisper.ladders, whisper.owner)
		if castRow then
			local text = ns.BuildRankWatchWhisper(castRow, betterRow, whisper.pet)
			lines[#lines + 1] = string.format(
				"[%s] %s: %d / %d bytes, %s",
				#text > ns.CHAT_MESSAGE_MAX_LENGTH and "OVER" or "OK",
				whisper.label,
				#text,
				ns.CHAT_MESSAGE_MAX_LENGTH,
				text:find("|H", 1, true) and "with the spell linked" or "with the spell named, unlinked"
			)
			lines[#lines + 1] = "    " .. ShownText(text)
		else
			lines[#lines + 1] = string.format("%s: no ability with two ranks on this client.", whisper.label)
		end
	end
	--[[
	    The opt-out offer and its answer, each built as Rank-Watch-Check.lua sends it: the offer with the
	    four-digit code your own name gets, the answer through the whisper rule ns:Announce takes.
	]]
	for _, whisper in ipairs({
		{ label = "Rank Watch opt-out offer", text = ns.BuildRankWatchOptOutWhisper(UnitName("player")) },
		{
			label = "Rank Watch opt-out answer",
			text = ns:BuildWhisperMessage("RANK_WATCH_MESSAGE_OPT_OUT_DONE"),
		},
	}) do
		local text = whisper.text or ""
		lines[#lines + 1] = string.format(
			"[%s] %s: %d / %d bytes",
			#text > ns.CHAT_MESSAGE_MAX_LENGTH and "OVER" or "OK",
			whisper.label,
			#text,
			ns.CHAT_MESSAGE_MAX_LENGTH
		)
		lines[#lines + 1] = "    " .. ShownText(text)
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] =
		"A demon is named by its kind and a hunter's pet by its own name; either in a non-Latin script takes 2 or 3 bytes a letter, so a pet's whisper can run longer than shown."
	return table.concat(lines, "\n")
end
