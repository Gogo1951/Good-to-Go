local _, ns = ...
local Data = ns.Data

local RANK_WATCH = Data.RANK_WATCH
local PREFIX = RANK_WATCH.COMM_PREFIX

--------------------------------------------------------------------------------
-- Rank Watch Cluster
--------------------------------------------------------------------------------

--[[
    One whisperer per group. Every Rank Watch and every standalone Rank Sentinel in a group talks over the
    standalone add-on's own prefix (RANKSENTINEL) and its own messages, so the two elect one leader between
    them, and only the leader whispers; everyone else prints. The standalone add-on sends through AceComm, which
    sends a short message as it is, so plain add-on messages read and write the same lines:

      JOIN|<name>,<release>    Sent to the group on joining it or reloading: who whispers here?
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

--[[
    Who speaks for the group: "self" when this client whispers, the leader's name when another Rank Watch or
    Rank Sentinel does, or nil when this client leads with whispers off and nobody whispers.
]]
function ns.RankWatchWhisperer()
	local me = MyName()
	if not lead or lead == me or not IsInGroup() then
		local settings = ns.RankWatchSettings()
		return settings and settings.whisper and "self" or nil
	end
	return lead
end

-- The leader's name for the options panel.
function ns.RankWatchLeadName()
	return lead or MyName()
end

local function IsInMyGroup(name)
	if name == MyName() then
		return true
	end
	local prefix, count = "party", GetNumSubgroupMembers()
	if IsInRaid() then
		prefix, count = "raid", GetNumGroupMembers()
	end
	for i = 1, count do
		local unitName = UnitName(prefix .. i)
		if ns.IsPlain(unitName) and unitName == name then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnChatMsgAddon(prefix, text, _, sender)
	if prefix ~= PREFIX or not (ns.IsPlain(text) and ns.IsPlain(sender)) or type(text) ~= "string" then
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
			lead = name
		end
	elseif command == "JOIN" then
		-- A leader with whispers off stays silent, so a joiner who whispers keeps the lead it gave itself.
		local leadName = ns.RankWatchLeadName()
		if leadName ~= MyName() or settings.whisper then
			Send("LEAD|" .. Release(leadName), "WHISPER", sender)
		end
	end
end
ns.SetRankWatchHandler("CHAT_MSG_ADDON", OnChatMsgAddon)

--[[
    Joining a group asks who leads; a leader who leaves hands the lead back to every copy left, each of which
    takes it until the next LEAD arrives, as the standalone add-on does.
]]
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

-- Turning on in a group asks who leads, as a reload does; turning off forgets the leader.
function ns.SyncRankWatchCluster(active)
	C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
	lead = MyName()
	wasInGroup = IsInGroup()
	if active and wasInGroup then
		Broadcast("JOIN", Release(MyName()))
	end
end
