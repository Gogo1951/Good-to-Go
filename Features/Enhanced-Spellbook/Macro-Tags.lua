local _, ns = ...

--[[
	The tag line ("#4K") ends every macro the add-on writes; WoW skips "#" lines it doesn't know. Tags are handed
	out in turn, never hashed, since a hash this short couldn't promise two macros never share one.
	UNASSIGNED_TAG is never handed out, so an untagged body's length is already right.
]]
local TAG_PREFIX = "#"
local TAG_DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local TAG_WIDTH = 2
local UNASSIGNED_TAG = "00"

--[[
	Read from the client, not ns.db.keys.char, which AceDB can take from the placeholder name before the
	character is named, making one key for several characters.
]]
function ns.MacroOwnerKey()
	return ns.GetCharacterProfileName() or ns.db.keys.char
end

local function MacroIdentity(macro)
	local kind = macro.copy and "copy" .. macro.copy or macro.rankID and "rank " .. macro.rankID or "spell"
	return ns.MacroOwnerKey() .. ":" .. kind .. ":" .. ns.MacroSpellKey(macro)
end

ns.MacroIdentity = MacroIdentity

function ns.HasSpellMacroTag(baseID)
	return ns.db.global.macroTags[MacroIdentity({ baseID = baseID })] ~= nil
end

local function MoveTag(fromMacro, toMacro)
	local tags, fromIdentity, toIdentity = ns.db.global.macroTags, MacroIdentity(fromMacro), MacroIdentity(toMacro)
	if not tags[fromIdentity] or tags[toIdentity] then
		return false
	end
	tags[toIdentity], tags[fromIdentity] = tags[fromIdentity], nil
	return true
end

-- from and to are Rank 1 IDs; returns whether the spell's own tag moved (never onto one already tagged).
function ns.HandOverMacroTag(from, to, copies)
	if not MoveTag({ baseID = from }, { baseID = to }) then
		return false
	end
	for _, number in ipairs(copies) do
		MoveTag({ baseID = from, copy = number }, { baseID = to, copy = number })
	end
	return true
end

-- The nth tag, n from 1: n in base 62, padded to TAG_WIDTH digits.
local function TagNumber(n)
	local base, digits = #TAG_DIGITS, ""
	repeat
		local digit = n % base
		digits = TAG_DIGITS:sub(digit + 1, digit + 1) .. digits
		n = math.floor(n / base)
	until n == 0
	return string.rep("0", TAG_WIDTH - #digits) .. digits
end

function ns.MacroTag(macro)
	return ns.db.global.macroTags[MacroIdentity(macro)] or UNASSIGNED_TAG
end

function ns.BodyTag(body)
	local tag = body and ("\n" .. body):match("\n" .. TAG_PREFIX .. "(%w%w%w?)\n*$")
	return tag ~= UNASSIGNED_TAG and tag or nil
end

function ns.TaggedBody(macro, body)
	return (body:gsub("\n+$", "")) .. "\n" .. TAG_PREFIX .. ns.MacroTag(macro)
end

function ns.UntaggedBody(body)
	return (("\n" .. body):gsub("\n" .. TAG_PREFIX .. "%w%w%w?\n*$", ""):sub(2))
end

--[[
	Skips any tag a WoW macro's body already carries: Macro Spellbook hands out tags from the same sequence,
	and a lookup by tag would find its macro and rewrite it.
]]
function ns.AssignMacroTag(macro)
	local global = ns.db.global
	local identity = MacroIdentity(macro)
	if global.macroTags[identity] then
		return
	end
	local inUse = ns.ReadMacroIndexes().tags
	local tag
	repeat
		global.macroTagCount = global.macroTagCount + 1
		tag = TagNumber(global.macroTagCount)
	until not inUse[tag]
	global.macroTags[identity] = tag
	macro.body = ns.TaggedBody(macro, ns.UntaggedBody(macro.body))
end
