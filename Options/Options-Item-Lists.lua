local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local format = string.format

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
    The item lists the options panels share: warming the item cache, reading
    an item typed or dropped in, sorting and naming items, and the list
    builder every item list panel uses. Split from Options/Options-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    C_Item.GetItemInfo answers nil for an item the client has not cached yet, which is
    the normal state for a list of item ids on a fresh login -- nothing has put
    those items in front of the player, so nothing has pulled their data. A panel
    that lists items renders those rows as L["LOADING_ITEM"] and hands the cold
    ids here.

    Each id is requested from the server, and the panel's registry name holds a
    GET_ITEM_INFO_RECEIVED waiter (ns.RequestItemInfoEvents) while any id it
    handed in is still outstanding. The shared item-info dispatcher
    (Features/Item-Info.lua) passes every answer to
    ns.OnOptionsItemInfoReceived below, which repaints the panels waiting on
    that id and releases a panel's waiter once nothing it asked about is left.
    A repaint that re-enters with still-cold ids, or a row added mid-load, just
    adds to the panel's pending set. An id the client has no item for, one
    whose answer already failed, or one already cached is never requested: no
    answer may come for it, so a wait on it could hold the event for the rest
    of the session.

    A window that is not an AceConfig panel (the Staples window) passes its own
    key and an onArrive to call in place of the repaint.
]]

-- registryName -> { [itemID] = true }, the ids each panel still waits on.
local warming = {}

-- registryName -> the function a non-AceConfig window repaints itself with.
local arriveHandlers = {}

-- [itemID] = true for every id whose answer came back failed this session.
local failedItemIDs = {}

local function WaiterKey(registryName)
	return "options:" .. registryName
end

function ns.WarmItemCache(itemIDs, registryName, onArrive)
	if not (itemIDs and itemIDs[1] and registryName) then
		return
	end
	arriveHandlers[registryName] = onArrive

	local pending = warming[registryName] or {}
	local requested = false
	for _, itemID in ipairs(itemIDs) do
		local cold = not C_Item.IsItemDataCachedByID(itemID)
		if cold and not failedItemIDs[itemID] and C_Item.DoesItemExistByID(itemID) then
			pending[itemID] = true
			C_Item.RequestLoadItemDataByID(itemID)
			requested = true
		end
	end
	if requested then
		warming[registryName] = pending
		ns.RequestItemInfoEvents(WaiterKey(registryName))
	end
end

--[[
    One GET_ITEM_INFO_RECEIVED answer, handed on by Features/Item-Info.lua's dispatcher
    after the Restocker has forgotten the item's remembered miss. A failed answer settles
    the wait too, and is remembered so the repaint that follows does not ask
    again: its row keeps its loading text.
]]
function ns.OnOptionsItemInfoReceived(itemID, success)
	if success ~= true then
		failedItemIDs[itemID] = true
	end
	for registryName, pending in pairs(warming) do
		if pending[itemID] then
			pending[itemID] = nil
			if arriveHandlers[registryName] then
				arriveHandlers[registryName]()
			else
				AceConfigRegistry:NotifyChange(registryName)
			end
			if next(pending) == nil then
				warming[registryName] = nil
				ns.ReleaseItemInfoEvents(WaiterKey(registryName))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

--[[
    Two shapes reach an add box: a bare id the player looked up, and a whole item
    link, which is what shift-clicking an item link in chat drops into a focused
    edit box. Anything else is rejected, so a stray word never becomes a row that
    renders as an unresolvable id forever.
]]
function ns.ParseItemInput(rawInput)
	if type(rawInput) ~= "string" then
		return nil
	end

	local itemID = tonumber(rawInput:match("item:(%d+)") or rawInput:match("^%s*(%d+)%s*$"))
	if itemID and itemID > 0 then
		return itemID
	end
	return nil
end

--------------------------------------------------------------------------------
-- Item Identifier Sort
--------------------------------------------------------------------------------

--[[
    Sorted by name, because a list ordered by id reads as random to the player.
    Items the client has not cached yet have no name to sort on, so they fall to
    the bottom by id rather than clustering under an empty string at the top;
    they re-sort into place as the panel repaints. Equal names tie-break on id,
    which makes the comparator a total order -- without it two identically named
    items compare equal and their rows reshuffle on every repaint. Each name is
    asked for once per sort, not once per comparison.
]]
function ns.SortItemIdentifiersByName(identifiers)
	local names = {}
	for _, identifier in ipairs(identifiers) do
		names[identifier] = C_Item.GetItemInfo(identifier) or ""
	end
	table.sort(identifiers, function(a, b)
		local nameA = names[a]
		local nameB = names[b]
		if nameA == nameB then
			return a < b
		end
		if nameA == "" then
			return false
		end
		if nameB == "" then
			return true
		end
		return nameA < nameB
	end)
end

--------------------------------------------------------------------------------
-- Item Display
--------------------------------------------------------------------------------

--[[
    One row's item, rendered for the ItemLink widget (Options-Widgets.lua): icon plus the item's
    name in its link's own color, so quality reads at a glance, and without the
    link's brackets (ns.UnbracketItemLink), which the icon makes redundant. An
    id the client has not answered for yet shows as loading text instead --
    ns.WarmItemCache repaints the panel as the data lands.
]]
function ns.GetItemDisplayName(itemID)
	local _, itemLink, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)

	if itemLink and icon then
		return format("|T%s:16|t %s", icon, ns.UnbracketItemLink(itemLink))
	elseif itemLink then
		return ns.UnbracketItemLink(itemLink)
	end

	return GetColor("MUTED") .. format(L["LOADING_ITEM"], itemID) .. "|r"
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
--------------------------------------------------------------------------------

--[[
    Every player-managed item list renders through here, so lists add and remove
    the same way in every panel. The caller supplies the labels, the source
    table, and the callbacks; this owns the shape. Spec:

      getSourceTable: function returning the table of itemID keys to list
      onAdd: function(itemID) adding an item to that source
      onRemove: function(itemID) removing one
      notifyKey: AceConfigRegistry name to NotifyChange on every mutation
      labels: { addName, addHelp, addInvalid, removeDesc, empty }
      rowWidth: optional total row budget, default ns.OPTIONS_ROW_WIDTH
      startOrder: optional first order, so a panel can seat its own head above
      actionColumn: optional per-row button, { width, name, desc, func(itemID) }
        (the Ignore List's Global button)
      addFromBags: optional true to put an Add from Bags picker above the add
        box, listing what the player carries that isn't on the list yet
        (labels then carry fromBagsName and fromBagsDesc)
      onClear: optional function emptying the list, for a Clear List button
        under the rows (labels then carry clearName, clearDesc, clearConfirm)

    Restore Defaults is deliberately absent: it belongs to lists that ship
    defaults, and every list here starts empty, so Clear List is what returns
    one to its default.
]]

--[[
    Remove is an icon, not a labeled button. An execute carrying an image renders
    as an AceGUI Icon; the stock Button insets its font string 15px from each
    edge, which in a column this narrow clips a caption to a sliver. The
    group-loot pass texture is already the game's own "get rid of this" mark, and
    name stays empty so the Icon draws no caption -- the label rides in desc,
    which AceConfigDialog shows on hover.
]]
local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
local REMOVE_ICON_SIZE = 16

-- A row's remove icon; confirmText, when given, asks first.
function ns.OptionsRemoveIcon(desc, order, func, confirmText)
	return {
		type = "execute",
		name = "",
		desc = desc,
		image = REMOVE_ICON,
		imageWidth = REMOVE_ICON_SIZE,
		imageHeight = REMOVE_ICON_SIZE,
		width = ns.OPTIONS_REMOVE_ICON_WIDTH,
		order = order,
		confirm = confirmText ~= nil,
		confirmText = confirmText,
		func = func,
	}
end

--[[
    The Add from Bags picker's choices: one entry per distinct item in the
    carried bags that the list doesn't hold yet, as icon and link, sorted by
    name. Built on every repaint, which the list panels get after each edit; an
    item looted while the panel stays open shows up on the next one. The game
    closes the bags when the options open, so this is the only way to pick an
    item without knowing its id.
]]
local function GetCarriedItemChoices(sourceTable)
	local values, sorting, seen = {}, {}, {}

	for _, bag in ipairs(ns.CARRIED_BAG_IDS) do
		for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local itemID = info and info.itemID
			if itemID and not seen[itemID] and not (sourceTable and sourceTable[itemID]) then
				seen[itemID] = true
				values[itemID] = ns.GetItemDisplayName(itemID)
				sorting[#sorting + 1] = itemID
			end
		end
	end

	ns.SortItemIdentifiersByName(sorting)
	return values, sorting
end

function ns.BuildItemListOptions(spec)
	local labels = spec.labels
	local rowWidth = spec.rowWidth or ns.OPTIONS_ROW_WIDTH
	local args = {}
	local order = spec.startOrder or 1

	--[[
	    Clear List goes last, under the rows, at normal width: the top of a list
	    is for finding and adding, and a rarely used reset shouldn't be the first
	    thing there. Ordered far past any row so it lands last however long the
	    list is, and shown only while the list holds something.
	]]
	if spec.onClear and next(spec.getSourceTable() or {}) ~= nil then
		args.spacerClear = ns.OptionsSpacer(9998)
		args.clearList = {
			type = "execute",
			name = labels.clearName,
			desc = labels.clearDesc,
			confirm = true,
			confirmText = labels.clearConfirm,
			order = 10000,
			func = function()
				spec.onClear()
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
	end

	--[[
	    The add rows' controls keep the standard control width, as Magic Eraser's
	    do, so a picked item's name has room; the label takes what the list's own
	    row budget leaves, so each row still ends where the item rows below it end.
	]]
	local addLabelWidth = rowWidth - ns.OPTIONS_CONTROL_WIDTH

	if spec.addFromBags then
		local values, sorting = GetCarriedItemChoices(spec.getSourceTable())

		args.addFromBagsLabel = ns.OptionsRowLabel(labels.fromBagsName, order, addLabelWidth)
		order = order + 1

		-- get returns nil so the picker reads empty again after each add.
		args.addFromBagsSelect = {
			type = "select",
			name = "",
			desc = labels.fromBagsDesc,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			values = values,
			sorting = sorting,
			disabled = function()
				return sorting[1] == nil
			end,
			get = function()
				return nil
			end,
			set = function(_, itemID)
				spec.onAdd(itemID)
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
		order = order + 1
	end

	args.addItemLabel = ns.OptionsRowLabel(labels.addName, order, addLabelWidth)
	order = order + 1

	--[[
	    get returns empty so the box clears itself on the repaint that follows
	    each add. validate rejects anything ParseItemInput cannot read and any id
	    this client has no item for, which is what keeps a typo out of the list
	    rather than into it as a dead row.
	]]
	args.addItemInput = {
		type = "input",
		name = "",
		desc = labels.addHelp,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		validate = function(_, value)
			local itemID = ns.ParseItemInput(value)
			return (itemID and C_Item.DoesItemExistByID(itemID)) and true or labels.addInvalid
		end,
		get = function()
			return ""
		end,
		set = function(_, value)
			local itemID = ns.ParseItemInput(value)
			if not itemID then
				return
			end
			spec.onAdd(itemID)
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end,
	}
	order = order + 1

	args.spacerRows = ns.OptionsSpacer(order)
	order = order + 1

	local identifiers = {}
	for itemID in pairs(spec.getSourceTable() or {}) do
		identifiers[#identifiers + 1] = itemID
	end

	if #identifiers == 0 then
		args.descEmpty = ns.OptionsDesc(GetColor("HELP") .. labels.empty .. "|r", order)
		return args
	end

	ns.SortItemIdentifiersByName(identifiers)

	local actionColumn = spec.actionColumn
	local itemWidth = rowWidth - ns.OPTIONS_REMOVE_ICON_WIDTH
	if actionColumn then
		itemWidth = itemWidth - actionColumn.width
	end

	local coldItemIDs = {}

	for _, itemID in ipairs(identifiers) do
		local capturedID = itemID

		if not C_Item.GetItemInfo(capturedID) then
			coldItemIDs[#coldItemIDs + 1] = capturedID
		end

		--[[
		    AceGUI's flow layout has no notion of a row: it packs widgets left to
		    right and wraps only when the next will not fit, so laid out flat,
		    cells from different items run together the moment the leftover space
		    takes the next item's name. An inline group with an empty name renders
		    as a bare SimpleGroup -- no border, no title, no padding -- at "fill"
		    width, and the flow layout always gives a fill widget its own line. The
		    cells then flow inside it, so every row breaks at the same points.
		]]
		local cells = {
			item = {
				type = "input",
				name = "",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				width = itemWidth,
				order = 1,
				get = function()
					return tostring(capturedID)
				end,
				set = function() end,
			},
		}

		if actionColumn then
			cells.action = {
				type = "execute",
				name = actionColumn.name,
				desc = actionColumn.desc,
				width = actionColumn.width,
				order = 2,
				func = function()
					actionColumn.func(capturedID)
					AceConfigRegistry:NotifyChange(spec.notifyKey)
				end,
			}
		end

		-- Removing one row takes one click and no confirm.
		cells.remove = ns.OptionsRemoveIcon(labels.removeDesc, 3, function()
			spec.onRemove(capturedID)
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end)

		args["item_" .. tostring(capturedID)] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = cells,
		}
		order = order + 1
	end

	ns.WarmItemCache(coldItemIDs, spec.notifyKey)

	return args
end
