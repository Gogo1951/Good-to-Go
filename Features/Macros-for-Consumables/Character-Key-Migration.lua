local _, ns = ...

--------------------------------------------------------------------------------
-- Keying Forever Characters By Their Whole Names
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-12-08)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    three pieces together:
      1. this file
      2. its tagged line in all four flavor TOCs (Good-to-Go_Vanilla.toc,
         _TBC.toc, _Camelot.toc and _Mists.toc)
      3. the ns.RekeyCharactersByFullName() call in Features/Core.lua
]]

--[[
    Moves a Forever character's first-name key ("Gogodruid-Realm") in
    listsByCharacter and inventory to its whole-name key. Must run before
    ns.MoveCharactersOntoOwnProfiles, which finds entries by whole name.

    The old key's entry wins over one already under the new key: that one is
    a leftover from an early beta build. Only the character playing moves; a
    logged-out character's surname is unknown and profileKeys holds no realm,
    so matching by first name could hand its data to a namesake.
]]

local function ForEachCharacterTable(visit)
	local global = ns.db.global
	local restocker = global.restocker
	-- pairs, not ipairs: a table missing from a hand-edited file must not hide the ones after it.
	for _, keyed in pairs({ restocker.listsByCharacter, global.inventory }) do
		if type(keyed) == "table" then
			visit(keyed)
		end
	end
end

local function MoveCharacter(oldKey, newKey)
	ForEachCharacterTable(function(keyed)
		if keyed[oldKey] ~= nil then
			keyed[newKey] = keyed[oldKey]
			keyed[oldKey] = nil
		end
	end)
end

function ns.RekeyCharactersByFullName()
	local firstName = UnitName("player")
	local fullName = ns.GetPlayerFullName()
	-- Era and TBC have one name, so nothing moves.
	if not firstName or not fullName or fullName == firstName then
		return
	end

	-- The old key is the new one with the surname taken out.
	local newKey = ns.GetCharacterKey()
	MoveCharacter(firstName .. newKey:sub(#fullName + 1), newKey)
end
