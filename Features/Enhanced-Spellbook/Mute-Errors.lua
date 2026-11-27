--[[
	The game plays an error's sound while the macro's /cast line runs, so muting around that line silences it;
	the spell's own sound still plays, since the cast starts after the macro ends. Each setting goes back to
	exactly what was read, and a timer backstops a press whose last line never runs.
]]
local MUTED_CVARS = { "Sound_EnableSFX", "Sound_EnableErrorSpeech" }
local mutedValues -- cvar -> the value read before muting, while muted

local function RestoreSounds()
	if not mutedValues then
		return
	end
	for cvar, value in pairs(mutedValues) do
		C_CVar.SetCVar(cvar, value)
	end
	mutedValues = nil
end

function GtGMute(on)
	if not on then
		RestoreSounds()
		return
	end
	if mutedValues then
		return
	end
	mutedValues = {}
	for _, cvar in ipairs(MUTED_CVARS) do
		local value = C_CVar.GetCVar(cvar)
		if value and value ~= "0" then
			mutedValues[cvar] = value
			C_CVar.SetCVar(cvar, "0")
		end
	end
	C_Timer.After(1, RestoreSounds)
end
