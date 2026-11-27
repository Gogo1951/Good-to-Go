local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

local Desc = Kit.Desc
local Spacer = Kit.Spacer

--------------------------------------------------------------------------------
-- Currency Replenish Panel
--------------------------------------------------------------------------------

-- The bank and each character's keeps are set in the mailbox window, not here.

local function FeatureOff()
	return not ns.db.global.currencyReplenish.enabled
end

function ns.BuildCurrencyReplenishOptions()
	return {
		type = "group",
		name = L["TAB_CURRENCY_REPLENISH"],
		args = {
			descReplenish = Desc(GetColor("BODY") .. L["OPTIONS_CURRENCY_REPLENISH_DESCRIPTION"] .. "|r", 1),
			spaceReplenish = Spacer(2),
			toggleReplenish = Kit.FeatureSwitch("currencyReplenish.enabled", 3),
			toggleSkipSmall = {
				type = "toggle",
				name = L["CURRENCY_REPLENISH_SKIP_SMALL"],
				desc = L["CURRENCY_REPLENISH_SKIP_SMALL_DESCRIPTION"],
				order = 4,
				width = "full",
				hidden = FeatureOff,
				get = function()
					return ns.db and ns.db.global.currencyReplenish.skipSmall
				end,
				set = function(_, value)
					ns.db.global.currencyReplenish.skipSmall = value
					ns.CurrencyReplenish.Changed()
					ns.RefreshSettings()
				end,
			},
		},
	}
end
