local _, ns = ...

--------------------------------------------------------------------------------
-- Pet Food Scanning
--------------------------------------------------------------------------------

ns.bestPetFoodID = nil
ns.bestPetFoodLink = nil

local activeQuestIDs = {}

local function BuildActiveQuestSet()
	wipe(activeQuestIDs)
	for questIndex = 1, ns.GetNumQuestLogEntries() do
		local questID = ns.GetQuestLogQuestID(questIndex)
		-- Include completed-but-not-turned-in quests too: turn-in still consumes the items.
		if questID then
			activeQuestIDs[questID] = true
		end
	end
end

local petFoodQuestIDs

-- Two tables swapped every call, so QUEST_LOG_UPDATE's many firings allocate nothing.
local lastActiveFoodQuests, lastActiveFoodQuestCount
local currentActiveFoodQuests = {}

function ns.PetFoodQuestsChanged()
	if not petFoodQuestIDs then
		petFoodQuestIDs = {}
		for _, foodData in pairs(ns.PET_FOOD_DATA) do
			for _, questID in ipairs(foodData[4] or {}) do
				petFoodQuestIDs[questID] = true
			end
		end
	end

	BuildActiveQuestSet()
	wipe(currentActiveFoodQuests)
	local count = 0
	for questID in pairs(activeQuestIDs) do
		if petFoodQuestIDs[questID] then
			currentActiveFoodQuests[questID] = true
			count = count + 1
		end
	end

	local changed = lastActiveFoodQuests == nil or count ~= lastActiveFoodQuestCount
	if not changed then
		for questID in pairs(currentActiveFoodQuests) do
			if not lastActiveFoodQuests[questID] then
				changed = true
				break
			end
		end
	end

	lastActiveFoodQuests, currentActiveFoodQuests = currentActiveFoodQuests, lastActiveFoodQuests or {}
	lastActiveFoodQuestCount = count
	return changed
end

local function IsNeededForQuest(questIDs)
	for _, questID in ipairs(questIDs) do
		if activeQuestIDs[questID] then
			return true
		end
	end
	return false
end

--[[
    The lowest food level still giving full happiness (0-10 below the pet);
    failing that, the closest food above it. Reads the same pass's ScanBags
    snapshot rather than walking the bags again.
]]
function ns.ScanPetFood()
	ns.bestPetFoodID = nil
	ns.bestPetFoodLink = nil

	-- An arena blocks ordinary food, so the macro drops its food line there.
	if select(2, IsInInstance()) == "arena" then
		return
	end
	if not UnitExists("pet") or UnitIsDead("pet") or UnitIsGhost("pet") then
		return
	end

	local petLevel = UnitLevel("pet")
	if not petLevel or petLevel < 1 then
		return
	end

	local petDiets = ns.GetPetFoodTypes()
	if not petDiets or #petDiets == 0 then
		return
	end

	local dietSet = {}
	for _, dietName in ipairs(petDiets) do
		local dietID = ns.PET_DIET_MAP[dietName]
		if dietID then
			dietSet[dietID] = true
		end
	end

	if next(ns.scannedItemCounts) == nil then
		return
	end

	--[[
	    Re-records the signature too: the dispatcher skips the diff in combat, so
	    a change undone after the fight would otherwise read as no change.
	]]
	ns.PetFoodQuestsChanged()

	-- Raw bag counts skip the scanner's ignore filter, so check both lists here.
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	local bestID, bestLink
	local bestLevel = 999
	local bestPrice = 999999
	local bestCount = 999999

	local fallbackID, fallbackLink
	local fallbackLevel = 999
	local fallbackPrice = 999999
	local fallbackCount = 999999

	for id, totalCount in pairs(ns.scannedItemCounts) do
		local foodData = ns.PET_FOOD_DATA[id]

		if foodData and not (characterIgnoreList[id] or globalIgnoreList[id]) then
			local foodLevel = foodData[1]
			local foodDiet = foodData[2]
			local sellPrice = foodData[3]
			local questIDs = foodData[4]

			if dietSet[foodDiet] then
				local levelDelta = petLevel - foodLevel
				local inHappyBracket = (levelDelta >= 0 and levelDelta <= 10)
				local isAbovePet = (levelDelta < 0)

				if inHappyBracket or isAbovePet then
					local skipQuest = false
					if questIDs then
						skipQuest = IsNeededForQuest(questIDs)
					end

					if not skipQuest then
						if inHappyBracket then
							local isBetter
							if not bestID then
								isBetter = true
							elseif foodLevel ~= bestLevel then
								isBetter = foodLevel < bestLevel
							elseif sellPrice ~= bestPrice then
								isBetter = sellPrice < bestPrice
							elseif totalCount ~= bestCount then
								isBetter = totalCount < bestCount
							else
								-- pairs() order isn't stable, so full ties would swap picks and churn rewrites.
								isBetter = id < bestID
							end

							if isBetter then
								bestID = id
								bestLink = ns.scannedItemLinks[id]
								bestLevel = foodLevel
								bestPrice = sellPrice
								bestCount = totalCount
							end
						else
							-- No upper cap: a level-8 cat eats level-70 meat (verified on Classic Era).
							local isBetter
							if not fallbackID then
								isBetter = true
							elseif foodLevel ~= fallbackLevel then
								isBetter = foodLevel < fallbackLevel
							elseif sellPrice ~= fallbackPrice then
								isBetter = sellPrice < fallbackPrice
							elseif totalCount ~= fallbackCount then
								isBetter = totalCount < fallbackCount
							else
								isBetter = id < fallbackID
							end

							if isBetter then
								fallbackID = id
								fallbackLink = ns.scannedItemLinks[id]
								fallbackLevel = foodLevel
								fallbackPrice = sellPrice
								fallbackCount = totalCount
							end
						end
					end
				end
			end
		end
	end

	if bestID then
		ns.bestPetFoodID = bestID
		ns.bestPetFoodLink = bestLink
	else
		ns.bestPetFoodID = fallbackID
		ns.bestPetFoodLink = fallbackLink
	end
end

--------------------------------------------------------------------------------
-- Pet Buff Override
--------------------------------------------------------------------------------

ns.petBuffOverrideID = nil

-- Sorted once at load, highest rank first.
local PET_BUFF_FOODS_BY_RANK = {}
for itemID, row in pairs(ns.PET_BUFF_FOODS) do
	PET_BUFF_FOODS_BY_RANK[#PET_BUFF_FOODS_BY_RANK + 1] =
		{ itemID = itemID, rank = row[2], settingKey = row[3], requiredLevel = row[4] }
end
table.sort(PET_BUFF_FOODS_BY_RANK, function(a, b)
	return a.rank > b.rank
end)

function ns.FindPetBuffOverride(bagItemCounts)
	-- The Readiness Report shares this gate.
	if not ns.ShouldTrackPetFood() then
		return nil
	end

	if ns.HasPetFoodBuff() then
		return nil
	end

	local petTypes = ns.db.profile.petBuffTypes

	-- Raw bag counts skip the scanner's ignore filter, so check the Ignore List here.
	local playerLevel = ns.cachedPlayerLevel or 1
	for _, food in ipairs(PET_BUFF_FOODS_BY_RANK) do
		local itemID = food.itemID
		if
			petTypes[food.settingKey]
			and playerLevel >= food.requiredLevel
			and bagItemCounts[itemID]
			and bagItemCounts[itemID] > 0
			and not ns.IsIgnored(itemID)
		then
			return itemID
		end
	end

	return nil
end
