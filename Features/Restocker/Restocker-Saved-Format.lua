local _, ns = ...

--------------------------------------------------------------------------------
-- Saved Item Format
--------------------------------------------------------------------------------

local function CleanItem(item, itemID)
	item.itemID = itemID
	return item
end

--[[
    One string per item, so the SavedVariables file holds one line per item (a
    table would expand across many). The key is the itemID; the name is a label
    never read back. No version stamp: data starts at the first numeric field,
    and a missing trailing field reads as its flag's default, so a new field is
    appended.
    Field order: itemName, amount, stashToBank, restockFromBank, buyFromMerchant,
                 reaction, upgrade, buyExtra.  Booleans are 1 / 0.
    MIGRATION (remove after 2026-12-08): so a line saved with a type ahead of the name still reads, and the next save rewrites it in the current form.
]]

local function ItemToString(item)
	local parts = {}
	parts[#parts + 1] = item.itemName or ""
	parts[#parts + 1] = item.amount or 0
	parts[#parts + 1] = item.stashToBank and 1 or 0
	parts[#parts + 1] = item.restockFromBank and 1 or 0
	-- buyFromMerchant and upgrade default on (nil), so only false writes 0.
	parts[#parts + 1] = (item.buyFromMerchant == false) and 0 or 1
	--[[
	    Both trailing fields go out every time. Upgrade sits behind reaction, so
	    writing reaction only when set would shift upgrade into its position.
	]]
	parts[#parts + 1] = (item.reaction and item.reaction > 0) and item.reaction or 0
	parts[#parts + 1] = (item.upgrade == false) and 0 or 1
	parts[#parts + 1] = item.buyExtra and 1 or 0
	return table.concat(parts, ", ")
end

local function ItemFromString(line, key)
	local itemID = tonumber(key)
	local fields = {}
	for _, part in ipairs({ strsplit(",", line) }) do
		fields[#fields + 1] = strtrim(part)
	end

	--[[
	    The label is the leading run of non-numeric fields, skipped whole; the
	    numeric data (amount, flags, [reaction]) follows.
	    MIGRATION (remove after 2026-12-08): a line saved with a type ahead of the name skips the same way.
	]]
	local dataStart
	for j = 1, #fields do
		if tonumber(fields[j]) ~= nil then
			dataStart = j
			break
		end
	end
	dataStart = dataStart or (#fields + 1)

	local amount = tonumber(fields[dataStart]) or 0
	local stash = tonumber(fields[dataStart + 1])
	local fromBank = tonumber(fields[dataStart + 2])
	local buy = tonumber(fields[dataStart + 3])
	local reaction = tonumber(fields[dataStart + 4]) or 0
	local upgradeFlag = tonumber(fields[dataStart + 5])
	local extra = tonumber(fields[dataStart + 6])

	--[[
	    Never fold these into "x and false or nil": it yields nil for every input,
	    so the off state never saves.
	]]
	local buyFromMerchant = nil
	if buy == 0 then
		buyFromMerchant = false
	end

	local upgrade = nil
	if upgradeFlag == 0 then
		upgrade = false
	end

	return {
		itemID = itemID,
		amount = amount,
		stashToBank = (stash == 1) or nil,
		restockFromBank = (fromBank == 1) or nil,
		buyFromMerchant = buyFromMerchant,
		reaction = reaction > 0 and reaction or nil,
		upgrade = upgrade,
		-- Off unless a 1 says so, so a line from before this field reads as off.
		buyExtra = (extra == 1) or nil,
	}
end

--[[
    Tolerates tables a crash left behind. The saved name is dropped: it goes
    stale after a language switch or a rename, so itemName stays nil until
    ns.RefreshRestockItemName asks the client.
]]
function ns.InflateSavedRestockItems(db)
	for _, list in pairs(db.lists or {}) do
		for key, item in pairs(list) do
			if type(item) == "string" then
				list[key] = ItemFromString(item, key)
			elseif type(item) == "table" then
				CleanItem(item, tonumber(key) or item.itemID)
				item.itemName = nil
			end
		end
	end
end

local function DeflateSavedItems(db)
	for _, list in pairs(db.lists or {}) do
		for key, item in pairs(list) do
			if type(item) == "table" then
				list[key] = ItemToString(item)
			end
		end
	end
end

function ns.DeflateRestockItemsForSave()
	DeflateSavedItems(ns.restockSettings)
end
