local _, ns = ...

--------------------------------------------------------------------------------
-- Profiles Panel
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 panel, nothing added. noDefaultProfiles (the
    second argument) hides the suggested realm, class and "Default" profiles
    while the move off Default runs: a character put on Default would be moved
    off it again at its next login.
]]
function ns.BuildProfilesOptions()
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(
		ns.db,
		true -- MIGRATION (remove after 2026-12-08)
	)
end
