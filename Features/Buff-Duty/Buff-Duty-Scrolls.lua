local _, ns = ...
local L = ns.L

local BuffDuty = ns.BuffDuty

local GetItemCount = C_Item.GetItemCount

-- Live bag counts, so a scroll just looted counts on the next redraw without waiting on the macros' bag scan.
local liveItemCounts = setmetatable({}, {
	__index = function(_, itemId)
		if ns.db.global.buffWindow.scrollOff[itemId] then
			return 0
		end
		return GetItemCount(itemId)
	end,
})

--[[
    A stronger elixir or class buff already on you covers a scroll type, as
    it does for the Food macro. The icons sit a tenth apart in Scrolls'
    column so the grid keeps them together and in order.
]]
function BuffDuty.AddScrollIcons(buff, icons)
	local types = ns.db.profile.scrollTypes
	if not types or ns.AreAurasSecret() then
		return
	end
	local snapshot = ns.GetPlayerBuffSnapshot()
	local now = GetTime()
	local name = GetUnitName("player", false) or ""
	for index, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local itemId, amount
		if types[scrollType] then
			itemId, amount = ns.FindBestScroll(scrollType, liveItemCounts)
		end
		local aura = itemId and snapshot.scrolls[scrollType]
		local covered = aura and aura.conflictAmount and aura.conflictAmount >= (amount or 0)
		local expires = aura and aura.expiration
		if aura and not covered and (expires == nil or (expires ~= 0 and expires - now < buff.refreshSeconds)) then
			icons[#icons + 1] = {
				itemId = itemId,
				item = "item:" .. itemId,
				selfItem = true,
				column = buff.column + index / 10,
				unit = "player",
				targetName = name,
				scroll = true,
				hint = L["BUFF_DUTY_TOOLTIP_READ"],
			}
		end
	end
end

-- Says no while auras can't be read (secret on WoW Forever, in combat).
function BuffDuty.ScrollsMissing()
	local types = ns.db.profile.scrollTypes
	if not types or ns.AreAurasSecret() then
		return false
	end
	local snapshot = ns.GetPlayerBuffSnapshot()
	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local aura = types[scrollType] and snapshot.scrolls[scrollType]
		if
			aura
			and aura.expiration == nil
			and not aura.conflictAmount
			and not ns.FindBestScroll(scrollType, liveItemCounts)
		then
			return true
		end
	end
	return false
end
