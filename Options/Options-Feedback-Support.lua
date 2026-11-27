local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Feedback & Support Panel
--------------------------------------------------------------------------------

local PARAGRAPHS = {
	"OPTIONS_LEVEL_UP_INTRO",
	"OPTIONS_LEVEL_UP_WAYS",
	"OPTIONS_LEVEL_UP_FEEDBACK",
	"OPTIONS_LEVEL_UP_FRIEND",
	"OPTIONS_LEVEL_UP_CURSEFORGE",
	"OPTIONS_LEVEL_UP_GITHUB",
	"OPTIONS_LEVEL_UP_THANKS",
}

-- { captionKey, linkKey }
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}

-- Narrower than a normal row's label cell: the label is one short word and the box holds a full URL.
local LINK_LABEL_WIDTH = 0.6

function ns.BuildFeedbackSupportOptions()
	local args = {}
	local order = 0

	for index, key in ipairs(PARAGRAPHS) do
		if index > 1 then
			order = order + 1
			args["spaceParagraph" .. index] = Kit.Spacer(order)
		end
		order = order + 1
		args["descParagraph" .. index] = Kit.Desc(L[key], order)
	end

	order = order + 1
	args.spaceLinks0 = Kit.Spacer(order)
	order = order + 1
	args.headerLinks = Kit.Header(L["OPTIONS_FEEDBACK_LINKS_HEADER"], order)

	for index, link in ipairs(LINKS) do
		local captionKey, linkKey = link[1], link[2]
		order = order + 1
		args["spaceLink" .. index] = Kit.Spacer(order)
		order = order + 1
		args["labelLink" .. index] = Kit.Label(GetColor("TITLE") .. L[captionKey] .. "|r", order, LINK_LABEL_WIDTH)
		order = order + 1
		args["urlLink" .. index] = {
			type = "input",
			name = "",
			order = order,
			width = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH,
			get = function()
				return ns.LINKS[linkKey]
			end,
			set = function() end,
		}
	end

	order = order + 1
	args.spaceCopyLink = Kit.Spacer(order)
	order = order + 1
	args.descCopyLink = Kit.Desc(GetColor("HELP") .. L["OPTIONS_COPY_LINK"] .. "|r", order)

	args.spaceVersion = {
		type = "description",
		name = " ",
		width = "full",
		order = 998,
	}
	args.versionLine = {
		type = "description",
		name = GetColor("INFO") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
		fontSize = "medium",
		order = 999,
	}

	return {
		name = L["OPTIONS_LEVEL_UP_TITLE"],
		type = "group",
		args = args,
	}
end
