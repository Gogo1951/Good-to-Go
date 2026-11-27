local _, ns = ...
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH
local PREFIX = RANK_WATCH.COMM_PREFIX

--------------------------------------------------------------------------------
-- Rank Watch Cluster
--------------------------------------------------------------------------------

--[[
        One whisperer per group, elected over the standalone add-on's own prefix and messages so the two share one
        leader. AceComm sends a short message as it is, so plain add-on messages read and write the same lines:

      JOIN|<name>,<release>    Sent to the group on joining it or reloading: who whispers here? A leader
                               turning off sends one too, handing the lead back.
      LEAD|<name>,<release>    The answer, whispered back to the joiner; also sent to the group to take the lead.
      NOTIFY|<key>             A cast just reported, keyed as settings.announced keys it, so nobody repeats it.
      SYNC|<key>               The standalone add-on's bulk copy of its reported casts; read like NOTIFY.

    Names are UnitName's short names, as the standalone add-on sends them. A message AceComm split into parts
    starts with a control byte; none of these ever needs splitting, so those are ignored.
]]

local ANNOUNCED_KEY_PATTERN = "^Player%-[%x%-]+%-%d+%-%d+$"

local lead -- the short name of whoever whispers for the group
local wasInGroup = false

local function MyName()
	return UnitName("player")
end

-- Battlegrounds and arenas are left alone, as the standalone add-on leaves them.
local function Send(message, channel, target)
	if not channel or ns.IsInPvPInstance() then
		return
	end
	pcall(C_ChatInfo.SendAddonMessage, PREFIX, message, channel, target)
end

local function Broadcast(command, data)
	Send(command .. "|" .. data, ns:GetGroupChatChannel())
end

local function Release(name)
	return name .. "," .. RANK_WATCH.COMM_RELEASE
end

-- Takes the lead for the group, as the standalone add-on does, only while this copy will whisper.
local function ClaimLead()
	lead = MyName()
	local settings = ns.RankWatchSettings()
	if settings and settings.whisper then
		Broadcast("LEAD", Release(lead))
	end
end

function ns.BroadcastRankWatchNotify(key)
	Broadcast("NOTIFY", key)
end

local function GroupUnitOf(name)
	local prefix, count = "party", GetNumSubgroupMembers()
	if IsInRaid() then
		prefix, count = "raid", GetNumGroupMembers()
	end
	for i = 1, count do
		local unit = prefix .. i
		local unitName = UnitName(unit)
		if ns.IsPlain(unitName) and unitName == name then
			return unit
		end
	end
	return nil
end

local function IsInMyGroup(name)
	return name == MyName() or GroupUnitOf(name) ~= nil
end

--[[
    "self", the leader's name, or nil when this client leads with whispers off. A leader gone offline can't
    whisper, so this client takes the lead back.
]]
function ns.RankWatchWhisperer()
	local me = MyName()
	if lead and lead ~= me and IsInGroup() then
		local unit = GroupUnitOf(lead)
		local connected = unit and UnitIsConnected(unit)
		if unit and ns.IsPlain(connected) and not connected then
			ClaimLead()
		end
	end
	if not lead or lead == me or not IsInGroup() then
		local settings = ns.RankWatchSettings()
		return settings and settings.whisper and "self" or nil
	end
	return lead
end

function ns.RankWatchLeadName()
	return lead or MyName()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnChatMsgAddon(prefix, text, _, sender)
	if
		not (ns.IsPlain(prefix) and ns.IsPlain(text) and ns.IsPlain(sender))
		or prefix ~= PREFIX
		or type(text) ~= "string"
	then
		return
	end
	if text == "" or text:byte(1) < 32 or Ambiguate(sender or "", "short") == MyName() then
		return
	end
	local command, data = strsplit("|", text, 2)
	if not data then
		return
	end
	local settings = ns.RankWatchSettings()
	if command == "NOTIFY" or command == "SYNC" then
		-- Saved for good, so only a key shaped as ns.CheckRankWatchCast writes one: caster GUID, level, spell ID.
		if data:match(ANNOUNCED_KEY_PATTERN) then
			settings.announced[data] = true
		end
	elseif command == "LEAD" then
		local name = strsplit(",", data)
		if name and name ~= "" and IsInMyGroup(name) then
			--[[
			    Two copies that each took the lead (joining at once, or both claiming after the leader left) would
			    otherwise each adopt the other and nobody would whisper. The lower name keeps it and says so again;
			    the other adopts it, as a standalone Rank Sentinel adopts any LEAD.
			]]
			local me = MyName()
			if lead == me and settings.whisper and me < name then
				Broadcast("LEAD", Release(me))
			else
				lead = name
			end
		end
	elseif command == "JOIN" then
		--[[
		    A JOIN from the leader itself means it has just turned on again or is handing the lead back (it
		    turned off), so a copy that whispers takes the lead rather than naming the leader back to it. A
		    leader with whispers off stays silent, so a joiner who whispers keeps the lead it gave itself.
		]]
		local leadName = ns.RankWatchLeadName()
		if leadName ~= MyName() and Ambiguate(sender, "short") == leadName and settings.whisper then
			ClaimLead()
		elseif leadName ~= MyName() or settings.whisper then
			Send("LEAD|" .. Release(leadName), "WHISPER", sender)
		end
	end
end
ns.SetRankWatchHandler("CHAT_MSG_ADDON", OnChatMsgAddon)

-- A leader who leaves hands the lead to every copy left, each holding it until the next LEAD arrives.
local function OnGroupRosterUpdate()
	local inGroup = IsInGroup()
	if inGroup and not wasInGroup then
		lead = MyName()
		C_Timer.After(RANK_WATCH.JOIN_DELAY, function()
			if ns.IsRankWatchActive() and IsInGroup() then
				Broadcast("JOIN", Release(MyName()))
			end
		end)
	elseif not inGroup then
		lead = MyName()
	elseif lead and not IsInMyGroup(lead) then
		ClaimLead()
	end
	wasInGroup = inGroup
end
ns.SetRankWatchHandler("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)

-- A leader turning off sends one JOIN first, so every copy left takes the lead back and re-elects.
function ns.SyncRankWatchCluster(active)
	C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
	if not active and IsInGroup() and lead == MyName() then
		Broadcast("JOIN", Release(MyName()))
	end
	lead = MyName()
	wasInGroup = IsInGroup()
	if active and wasInGroup then
		Broadcast("JOIN", Release(MyName()))
	end
end
