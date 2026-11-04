local _, ns = ...

--[[
    The secure attributes a Buff Window icon or the Buff Key casts with:
    one spec, written onto a SecureActionButtonTemplate button out of combat.
]]

--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------

--[[
    Left button only ("type1"): a right-click finds no "type2" and no bare
    "type" to fall back on, so it casts nothing and is free for dismissing a
    favor. Every attribute is written on every use, nil included, because a
    pooled button still carries whatever its last spec set; a nil spec clears
    them all. Shared with the Buff Key, which writes the same attributes.
]]
function ns.SetBuffButtonAttributes(button, spec)
	if not spec then
		for _, key in ipairs({ "type1", "spell", "item", "unit", "macrotext", "target-slot" }) do
			button:SetAttribute(key, nil)
		end
		return
	end
	--[[
	    The weapon a poison goes on: the template uses this slot once the item
	    leaves the cursor waiting on one.
	]]
	button:SetAttribute("target-slot", spec.targetSlot)
	if spec.macrotext then
		button:SetAttribute("type1", "macro")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", nil)
		button:SetAttribute("macrotext", spec.macrotext)
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
