local _, ns = ...

--[[
	A trainer window's services: the spell each one teaches, read by Features/Enhanced-Spellbook/Trainer-Recording.lua.
]]

--[[
	The spell ID of a trainer window's service. Forever and Retail hand it over through
	C_TooltipInfo.GetTrainerService; the Classic engine shows the service on the hidden scan tooltip and reads
	the spell back with GetSpell. Resolved once at load.
]]
if C_TooltipInfo and C_TooltipInfo.GetTrainerService then
	function ns.GetTrainerServiceSpellId(index)
		local data = C_TooltipInfo.GetTrainerService(index)
		return data and data.id
	end
else
	function ns.GetTrainerServiceSpellId(index)
		local scanTooltip = ns.GetScanTooltip()
		scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		scanTooltip:SetTrainerService(index)
		local _, spellId = scanTooltip:GetSpell()
		scanTooltip:Hide()
		return spellId
	end
end
