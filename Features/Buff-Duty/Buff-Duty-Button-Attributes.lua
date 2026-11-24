local _, ns = ...

--[[
    The secure attributes a Buff Duty window icon or the Buff Key casts with:
    one spec, written onto a SecureActionButtonTemplate button out of combat.
]]

--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------

--[[
    What a /use line names an item by: its name, which reads it at a unit
    ([@player]) where "item:<id>" didn't on WoW Forever. The item is in your
    bags, so its name is known; "item:<id>" if it somehow isn't.
]]
local function ItemUseName(spec)
	local name = spec.itemId and C_Item.GetItemNameByID(spec.itemId)
	if ns.IsPlain(name) and name and name ~= "" then
		return name
	end
	return spec.item
end

--[[
    Left button only ("type1"): a right-click finds no "type2" and no bare
    "type" to fall back on, so it casts nothing and is free for dismissing a
    favor. Every attribute is written on every use, nil included, because a
    pooled button still carries whatever its last spec set; a nil spec clears
    them all, and so does an ask (Buff-Duty-Asks.lua), whose click whispers
    from PreClick and casts nothing, and so does a cast held back from a
    PvP-flagged player (spec.pvpFlagged), whose click says so instead.
    Shared with the Buff Key, which writes the same attributes.
]]
function ns.SetBuffButtonAttributes(button, spec)
	if not spec or spec.ask or spec.pvpFlagged then
		for _, key in ipairs({ "type1", "spell", "item", "unit", "macrotext", "target-slot" }) do
			button:SetAttribute(key, nil)
		end
		return
	end
	--[[
	    The weapon a poison, oil, stone or lure goes on: the template uses this
	    slot once the item leaves the cursor waiting on one.
	]]
	button:SetAttribute("target-slot", spec.targetSlot)
	--[[
	    A Self Buffs item goes through a /use line, since the template's item
	    action aimed at "player" used nothing on WoW Forever:
	      - Buff food and Winterfall Firewater: "/use item:<id>", the line the
	        Food macro eats with.
	      - A scroll is read at someone, so its line names you, by the scroll's
	        name: "/use [@player] Scroll of Spirit". Bare, it answered "Target
	        is not a player" with nothing targeted, and "[@player] item:<id>"
	        read nothing at all.
	    A weapon item keeps the template's item action and target-slot, which
	    applies it from a click, the key and a macro's /click alike; as a macro
	    line, /click GtGBuffKey ran it as a macro inside one and it never landed.
	]]
	local macrotext = spec.macrotext
	if not macrotext and spec.item then
		if spec.scroll then
			macrotext = "/use [@player] " .. ItemUseName(spec)
		elseif spec.selfItem then
			macrotext = "/use " .. spec.item
		end
	end
	if macrotext then
		button:SetAttribute("type1", "macro")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", nil)
		button:SetAttribute("macrotext", macrotext)
	elseif spec.item then
		-- "item:12345", resolved by the template the way /use resolves it.
		button:SetAttribute("type1", "item")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", spec.item)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	else
		button:SetAttribute("type1", "spell")
		--[[
		    Rank text ("Name(Rank 2)") casts that exact rank through the secure
		    template's CastSpellByName; a bare name casts your highest. Not a spell
		    ID: the template hands a number to CastSpellByID, and on Classic Era a
		    lower rank's ID cast nothing. Group buffs pass their highest rank's
		    text too: Prayer of Fortitude's bare name cast Rank 1.
		]]
		button:SetAttribute("spell", spec.castSpell or spec.spellName)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	end
end
