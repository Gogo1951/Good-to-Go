local _, ns = ...

--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------

-- Aimed at "player", "item:<id>" used nothing on WoW Forever; the item's name works.
local function ItemUseName(spec)
	local name = spec.itemId and C_Item.GetItemNameByID(spec.itemId)
	if ns.IsPlain(name) and name and name ~= "" then
		return name
	end
	return spec.item
end

--[[
    Only "type1", so a right-click casts nothing and is free for dismissing a
    favor. Every attribute is written on every use, nil included, because a
    pooled button keeps whatever its last spec set. An ask or a PvP hold
    clears them all: its click only whispers or warns from PreClick.
]]
function ns.SetBuffButtonAttributes(button, spec)
	if not spec or spec.ask or spec.pvpFlagged then
		for _, key in ipairs({ "type1", "spell", "item", "unit", "macrotext", "target-slot" }) do
			button:SetAttribute(key, nil)
		end
		return
	end
	button:SetAttribute("target-slot", spec.targetSlot)
	--[[
	    Trap: on WoW Forever a Buff Key macro line never went off (a /use from
	    /click GtGBuffKey, a /target + /cast from the key), and why isn't
	    known. So self items use the item action by name, never a /use line;
	    weapon items keep "item:<id>" + target-slot, which apply everywhere.
	]]
	local macrotext = spec.macrotext
	if macrotext then
		button:SetAttribute("type1", "macro")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", nil)
		button:SetAttribute("macrotext", macrotext)
	elseif spec.item then
		button:SetAttribute("type1", "item")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", spec.selfItem and ItemUseName(spec) or spec.item)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	else
		button:SetAttribute("type1", "spell")
		--[[
		    Rank text ("Name(Rank 2)"), never a spell ID: on Classic Era a lower
		    rank's ID casts nothing, and a group buff's bare name casts Rank 1.
		]]
		button:SetAttribute("spell", spec.castSpell or spec.spellName)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	end
end
