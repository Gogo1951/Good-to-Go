local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Restock List Slash Command
--------------------------------------------------------------------------------

--[[
    TEXT is restored for the tail, since ns.PrintMessage wraps the whole body in
    TEXT. Subcommand words stay English: they are what the parser matches.
]]
local function SlashHelpLine(subcommand, description)
	return GetColor("INFO")
		.. L["RESTOCKER_COMMAND"]
		.. " "
		.. subcommand
		.. "|r"
		.. GetColor("TEXT")
		.. "  "
		.. description
end

local NAME = L["RESTOCKER_HELP_NAME_PLACEHOLDER"]

local RESTOCKER_COMMANDS = {
	show = SlashHelpLine("show", L["RESTOCKER_COMMAND_DESCRIPTION"]),
	config = SlashHelpLine("config", L["OPTIONS_COMMAND_DESCRIPTION"]),
	profile = {
		add = SlashHelpLine("profile add " .. NAME, L["RESTOCKER_HELP_PROFILE_ADD"]),
		delete = SlashHelpLine("profile delete " .. NAME, L["RESTOCKER_HELP_PROFILE_DELETE"]),
		rename = SlashHelpLine("profile rename " .. NAME, L["RESTOCKER_HELP_PROFILE_RENAME"]),
		copy = SlashHelpLine("profile copy " .. NAME, L["RESTOCKER_HELP_PROFILE_COPY"]),
		use = SlashHelpLine("profile use " .. NAME, L["RESTOCKER_HELP_PROFILE_USE"]),
	},
}

-- The order help prints in: the table above is keyed for lookups, and pairs() would shuffle it.
local COMMAND_ORDER = { "show", "config", "profile" }
local PROFILE_SUBCOMMAND_ORDER = { "add", "delete", "rename", "copy", "use" }

-- withinHelp: PrintHelp has already printed the title, so it prints once.
local function PrintProfileHelp(withinHelp)
	if not withinHelp then
		ns:PrintMessage(L["RESTOCKER_HELP_TITLE"])
	end
	for _, subcommand in ipairs(PROFILE_SUBCOMMAND_ORDER) do
		ns:PrintMessage(RESTOCKER_COMMANDS.profile[subcommand])
	end
end

local function PrintHelp()
	ns:PrintMessage(L["RESTOCKER_HELP_TITLE"])
	for _, eachCommand in ipairs(COMMAND_ORDER) do
		if eachCommand == "profile" then
			PrintProfileHelp(true)
		else
			ns:PrintMessage(RESTOCKER_COMMANDS[eachCommand])
		end
	end
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

local NAMES_EXISTING_LIST = { delete = true, copy = true, use = true }

function ns.HandleRestockerCommand(args)
	local command, rest = strtrim(args or ""):match("^(%S*)%s*(.-)$")
	command = command:lower()

	-- The master switch stops every command but help and config, which opens the panel that turns it back on.
	if command ~= "help" and command ~= "config" and not ns.IsRestockerEnabled() then
		ns:PrintMessage(L["RESTOCKER_DISABLED"])
		return
	end

	if command == "show" then
		ns.ShowRestockWindow()
	elseif command == "profile" then
		if rest == "" then
			PrintProfileHelp()
			return
		end

		local subcommand, name = rest:match("^(%S*)%s*(.-)$")
		subcommand = subcommand:lower()

		-- A missing name prints the usage line rather than erroring on a nil table key.
		if name == "" and RESTOCKER_COMMANDS.profile[subcommand] then
			ns:PrintMessage(RESTOCKER_COMMANDS.profile[subcommand])
			return
		end

		if NAMES_EXISTING_LIST[subcommand] and ns.restockSettings.lists[name] == nil then
			ns:PrintMessage(L["RESTOCKER_LIST_NOT_FOUND"]:format(name))
			return
		end

		if subcommand == "add" then
			ns.AddRestockList(name)
		elseif subcommand == "delete" then
			-- A Restock List has no undo, so this asks first, with the window's own Delete confirm.
			ns.ConfirmDeleteRestockList(name)
		elseif subcommand == "rename" then
			ns.RenameCurrentRestockList(name)
		elseif subcommand == "use" then
			ns.SwitchRestockList(name)
		elseif subcommand == "copy" then
			-- The copy replaces the list in use, which has no undo, so this asks first.
			ns.ConfirmCopyIntoCurrentRestockList(name)
		else
			PrintProfileHelp()
			return
		end
	elseif command == "help" then
		PrintHelp()
		return
	elseif command == "config" then
		ns:OpenOptionsPanel("Restocker")
		return
	elseif command == "" then
		-- Opening redraws by itself (OnShow).
		ns.ToggleRestockWindow()
	else
		-- A word it doesn't know says so and lists the commands, rather than guessing and opening the window.
		local helpCommand = GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. " help|r" .. GetColor("TEXT")
		ns:PrintMessage(L["RESTOCKER_SLASH_UNKNOWN"]:format(command, helpCommand))
		PrintHelp()
	end
end
