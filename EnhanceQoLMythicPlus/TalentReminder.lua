local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

addon.MythicPlus.variables.knownLoadout = {}
addon.MythicPlus.variables.specNames = {}
addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID()
addon.MythicPlus.variables.seasonMapInfo = {}
addon.MythicPlus.variables.seasonMapHash = {}

local cModeIDs = C_ChallengeMode.GetMapTable()
local cModeIDLookup = {}
for _, id in ipairs(cModeIDs) do
	cModeIDLookup[id] = true
end

for _, section in pairs(addon.MythicPlus.variables.portalCompendium) do
	for spellID, data in pairs(section.spells) do
		if data.mapID and data.cId then
			for cId in pairs(data.cId) do
				if cModeIDLookup[cId] and not addon.MythicPlus.variables.seasonMapHash[data.mapID] then
					local mapName = C_ChallengeMode.GetMapUIInfo(cId)
					table.insert(addon.MythicPlus.variables.seasonMapInfo, { name = mapName, id = data.mapID })
					addon.MythicPlus.variables.seasonMapHash[data.mapID] = true
				end
			end
		end
	end
end
table.sort(addon.MythicPlus.variables.seasonMapInfo, function(a, b) return a.name < b.name end)

function addon.MythicPlus.functions.getAllLoadouts()
	addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID()
	addon.MythicPlus.variables.knownLoadout = {}
	addon.MythicPlus.variables.specNames = {}
	for i = 1, GetNumSpecializationsForClassID(addon.variables.unitClassID) do
		local specID, specName = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
		addon.MythicPlus.variables.knownLoadout[specID] = {}
		table.insert(addon.MythicPlus.variables.specNames, { text = specName, value = specID })
		for _, v in pairs(C_ClassTalents.GetConfigIDsBySpecID(specID)) do
			local info = C_Traits.GetConfigInfo(v)
			if info then addon.MythicPlus.variables.knownLoadout[specID][info.ID] = info.name end
		end
		if #addon.MythicPlus.variables.knownLoadout[specID] then addon.MythicPlus.variables.knownLoadout[specID][0] = "" end
	end
end

local frameLoad = CreateFrame("Frame")

local function checkLoadout()
	if nil == addon.MythicPlus.variables.currentSpecID then addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID() end
	if
		addon.db["talentReminderEnabled"]
		and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID]
		and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID]
		and IsInInstance()
	then
		local _, _, difficulty, _, _, _, _, mapID = GetInstanceInfo()
		if mapID and addon.MythicPlus.variables.seasonMapHash[mapID] and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID][mapID] then
			print(
				C_ClassTalents.GetLastSelectedSavedConfigID(addon.MythicPlus.variables.currentSpecID)
					== addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID][mapID]
			)
			--addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID][cbData.id]
		end
	end
end

local eventHandlers = {
	["TRAIT_CONFIG_CREATED"] = function() addon.MythicPlus.functions.getAllLoadouts() end,
	["TRAIT_CONFIG_DELETED"] = function() addon.MythicPlus.functions.getAllLoadouts() end,
	["TRAIT_CONFIG_UPDATED"] = function() addon.MythicPlus.functions.getAllLoadouts() end,
	["ZONE_CHANGED_NEW_AREA"] = function() checkLoadout() end,
	["PLAYER_ENTERING_WORLD"] = function() checkLoadout() end,
}

local function registerEvents(frame)
	for event in pairs(eventHandlers) do
		frame:RegisterEvent(event)
	end
end
local function eventHandler(self, event, ...)
	if eventHandlers[event] then eventHandlers[event](...) end
end
registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)

--/dump EnhanceQoL.MythicPlus.functions.getAllLoadouts()
