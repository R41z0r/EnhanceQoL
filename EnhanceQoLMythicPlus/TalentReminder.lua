local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_MythicPlus")

addon.MythicPlus.variables.knownLoadout = {}
addon.MythicPlus.variables.specNames = {}
addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID()
addon.MythicPlus.variables.seasonMapInfo = {}
addon.MythicPlus.variables.seasonMapHash = {}

local function createSeasonInfo()
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
					local mID
					if type(data.mapID) == "table" then
						mID = data.mapID[cId]
					else
						mID = data.mapID
					end
					if mID and cModeIDLookup[cId] and not addon.MythicPlus.variables.seasonMapHash[mID] then
						local mapName = C_ChallengeMode.GetMapUIInfo(cId)
						table.insert(addon.MythicPlus.variables.seasonMapInfo, { name = mapName, id = mID })
						addon.MythicPlus.variables.seasonMapHash[mID] = true
					end
				end
			end
		end
	end
	table.sort(addon.MythicPlus.variables.seasonMapInfo, function(a, b) return a.name < b.name end)
end

function addon.MythicPlus.functions.getAllLoadouts()
	if #addon.MythicPlus.variables.seasonMapInfo == 0 then createSeasonInfo() end
	addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID()
	addon.MythicPlus.variables.knownLoadout = {}
	addon.MythicPlus.variables.specNames = {}
	for i = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(addon.variables.unitClassID) do
		local specID, specName = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
		addon.MythicPlus.variables.knownLoadout[specID] = {}
		table.insert(addon.MythicPlus.variables.specNames, { text = specName, value = specID })
		for _, v in pairs(C_ClassTalents.GetConfigIDsBySpecID(specID)) do
			local info = C_Traits.GetConfigInfo(v)
			if info then addon.MythicPlus.variables.knownLoadout[specID][info.ID] = info.name end
		end
		if TalentLoadoutEx then
			if TalentLoadoutEx[addon.variables.unitClass] and TalentLoadoutEx[addon.variables.unitClass][i] then
				for _, v in pairs(TalentLoadoutEx[addon.variables.unitClass][i]) do
					addon.MythicPlus.variables.knownLoadout[specID][v.text .. "_" .. v.name] = "TLE: " .. v.name
				end
			end
		end
		if #addon.MythicPlus.variables.knownLoadout[specID] then addon.MythicPlus.variables.knownLoadout[specID][0] = "" end
	end
end

local function deleteFrame(element)
	if element then
		element:Hide()
		element:SetScript("OnShow", nil)
		element:SetScript("OnHide", nil)
		element:SetParent(nil)
		element = nil
	end
	if ChangeTalentUIPopup then ChangeTalentUIPopup = nil end
end

local function GetIndexForConfigID(configID)
	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
	for i, id in ipairs(configIDs) do
		if id == configID then return i end
	end
	return nil -- Falls nicht gefunden
end

local function GetConfigName(configID)
	if configID then
		if type(configID) == "number" then
			local info = C_Traits.GetConfigInfo(configID)
			if info then return info.name end
		elseif
			type(configID) == "string"
			and addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID]
			and addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID][configID]
		then
			return addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID][configID]
		end
	end
	return "Unknown"
end

local function showPopup(actTalent, requiredTalent)
	local playedMusic = false
	if ChangeTalentUIPopup and ChangeTalentUIPopup:IsShown() then
		playedMusic = true
		deleteFrame(ChangeTalentUIPopup)
	end

	local curName = GetConfigName(actTalent)
	local newName = GetConfigName(requiredTalent)

	local reloadFrame = CreateFrame("Frame", "ChangeTalentUIPopup", UIParent, "BasicFrameTemplateWithInset")
	reloadFrame:SetSize(500, 200) -- Breite und Höhe
	reloadFrame:SetPoint("TOP", UIParent, "TOP", 0, -200) -- Zentriert auf dem Bildschirm
	reloadFrame:SetFrameStrata("DIALOG")

	reloadFrame.title = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reloadFrame.title:SetPoint("TOP", reloadFrame, "TOP", 0, -6)
	reloadFrame.title:SetText(L["WrongTalents"])

	reloadFrame.curTalentHeadling = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	reloadFrame.curTalentHeadling:SetPoint("TOP", reloadFrame, "TOP", 0, -30)
	reloadFrame.curTalentHeadling:SetText(L["ActualTalents"])

	reloadFrame.curTalent = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	reloadFrame.curTalent:SetPoint("TOP", reloadFrame, "TOP", 0, addon.functions.getHeightOffset(reloadFrame.curTalentHeadling) - 5)
	reloadFrame.curTalent:SetText("|cffff0000" .. curName .. "|r")

	reloadFrame.reqTalentHeadling = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	reloadFrame.reqTalentHeadling:SetPoint("TOP", reloadFrame, "TOP", 0, addon.functions.getHeightOffset(reloadFrame.curTalent) - 15)
	reloadFrame.reqTalentHeadling:SetText(L["RequiredTalents"])

	reloadFrame.reqTalent = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	reloadFrame.reqTalent:SetPoint("TOP", reloadFrame, "TOP", 0, addon.functions.getHeightOffset(reloadFrame.reqTalentHeadling) - 5)
	reloadFrame.reqTalent:SetText("|cff00ff00" .. newName .. "|r")

	local reloadButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
	reloadButton:SetSize(120, 30)
	reloadButton:SetPoint("BOTTOMLEFT", reloadFrame, "BOTTOMLEFT", 10, 10)
	if type(requiredTalent) == "number" then
		reloadButton:SetText(SWITCH)
		reloadButton:SetScript("OnClick", function()
			if InCombatLockdown() then return end
			local talentIndex = GetIndexForConfigID(requiredTalent)
			if talentIndex then ClassTalentHelper.SwitchToLoadoutByIndex(talentIndex) end
			deleteFrame(ChangeTalentUIPopup)
		end)
	else
		reloadFrame.reqTalent:SetText("|cff00ff00" .. newName .. "|r\n\n" .. L["useTalentLoadoutEx"])
		reloadButton:SetText(L["OpenTalents"])
		reloadButton:SetScript("OnClick", function()
			if InCombatLockdown() then return end
			PlayerSpellsMicroButton:Click()
		end)
	end

	local cancelButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
	cancelButton:SetSize(120, 30)
	cancelButton:SetPoint("BOTTOMRIGHT", reloadFrame, "BOTTOMRIGHT", -10, 10)
	cancelButton:SetText(CLOSE)
	cancelButton:SetScript("OnClick", function() deleteFrame(ChangeTalentUIPopup) end)

	if addon.db["talentReminderSoundOnDifference"] and not playedMusic then PlaySound(11466, "Master") end
	reloadFrame:Show()
	local maxHeight = addon.functions.getHeightOffset(reloadFrame.reqTalent) * -1

	local minButton = reloadButton:GetWidth() + cancelButton:GetWidth() + 40
	local maxWidth = max(
		max(reloadFrame.curTalentHeadling:GetStringWidth(), reloadFrame.curTalent:GetStringWidth(), reloadFrame.reqTalentHeadling:GetStringWidth(), reloadFrame.reqTalent:GetStringWidth()),
		minButton
	)

	reloadFrame:SetSize(maxWidth + 20, max(120, (maxHeight + 50)))
end

local function showWarning(info)
	if ChangeTalentUIWarning and ChangeTalentUIWarning:IsShown() then deleteFrame(ChangeTalentUIWarning) end

	local reloadFrame = CreateFrame("Frame", "ChangeTalentUIWarning", UIParent, "BasicFrameTemplateWithInset")
	reloadFrame:SetSize(500, 200)
	reloadFrame:SetPoint("TOP", UIParent, "TOP", 0, -200)
	reloadFrame:SetFrameStrata("DIALOG")

	reloadFrame.title = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reloadFrame.title:SetPoint("TOP", reloadFrame, "TOP", 0, -6)
	reloadFrame.title:SetText(L["DeletedLoadout"])

	reloadFrame.curTalentHeadling = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	reloadFrame.curTalentHeadling:SetPoint("TOP", reloadFrame, "TOP", 0, -30)
	reloadFrame.curTalentHeadling:SetText(L["MissingTalentLoadout"])

	reloadFrame.curTalent = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	reloadFrame.curTalent:SetPoint("TOP", reloadFrame, "TOP", 0, addon.functions.getHeightOffset(reloadFrame.curTalentHeadling) - 5)
	reloadFrame.curTalent:SetText(info)

	local cancelButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
	cancelButton:SetSize(120, 30)
	cancelButton:SetPoint("BOTTOM", reloadFrame, "BOTTOM", -10, 10)
	cancelButton:SetText(ACCEPT)
	cancelButton:SetScript("OnClick", function()
		addon.MythicPlus.functions.checkRemovedLoadout(true)
		reloadFrame:Hide()
		reloadFrame:SetScript("OnShow", nil)
		reloadFrame:SetScript("OnHide", nil)
		reloadFrame:SetParent(nil)
		reloadFrame = nil
		ChangeTalentUIWarning = nil
	end)

	reloadFrame:Show()
	local maxHeight = addon.functions.getHeightOffset(reloadFrame.curTalent) * -1

	local minButton = cancelButton:GetWidth() + 40
	local maxWidth = max(max(reloadFrame.curTalentHeadling:GetStringWidth(), reloadFrame.curTalent:GetStringWidth()), minButton) + 50
	reloadFrame:SetSize(maxWidth + 20, max(120, (maxHeight + 50)))
end

local frameLoad = CreateFrame("Frame")

local function checkLoadout(isReadycheck)
	if nil == addon.MythicPlus.variables.currentSpecID then addon.MythicPlus.variables.currentSpecID = PlayerUtil.GetCurrentSpecID() end
	if addon.db["talentReminderLoadOnReadyCheck"] and not isReadycheck then
		deleteFrame(ChangeTalentUIPopup)
		return
	end
	if
		addon.db["talentReminderEnabled"]
		and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID]
		and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID]
		and IsInInstance()
	then
		if #addon.MythicPlus.variables.seasonMapInfo == 0 then createSeasonInfo() end
		local _, _, difficulty, _, _, _, _, mapID = GetInstanceInfo()
		if
			difficulty == 23
			and mapID
			and addon.MythicPlus.variables.seasonMapHash[mapID]
			and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID][mapID]
		then
			local reqTalent = addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][addon.MythicPlus.variables.currentSpecID][mapID]
			if
				reqTalent
				and addon.MythicPlus.variables.knownLoadout
				and addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID]
				and addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID][reqTalent]
			then
				local actTalent = C_ClassTalents.GetLastSelectedSavedConfigID(addon.MythicPlus.variables.currentSpecID)
				if type(reqTalent) == "number" and reqTalent > 0 then
					if actTalent ~= reqTalent then
						showPopup(actTalent, reqTalent)
					else
						deleteFrame(ChangeTalentUIPopup)
					end
				elseif type(reqTalent) == "string" and string.len(reqTalent) > 0 then
					if C_Traits.GenerateImportString(C_ClassTalents.GetActiveConfigID()) ~= reqTalent:gsub("_.*$", "") then
						showPopup(actTalent, reqTalent)
					else
						deleteFrame(ChangeTalentUIPopup)
					end
				end
			else
				deleteFrame(ChangeTalentUIPopup)
			end
		end
	elseif (ChangeTalentUIPopup and ChangeTalentUIPopup:IsVisible()) or (ChangeTalentUIWarning and ChangeTalentUIWarning:IsVisible()) then
		deleteFrame(ChangeTalentUIPopup)
	end
end

function addon.MythicPlus.functions.checkLoadout() checkLoadout() end
function addon.MythicPlus.functions.createSeasonInfo() createSeasonInfo() end
function addon.MythicPlus.functions.checkRemovedLoadout(clear)
	local tRemoved = {}
	for _, cbData in pairs(addon.MythicPlus.variables.seasonMapInfo) do
		for i = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(addon.variables.unitClassID) do
			local specID, specName = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
			if
				addon.db["talentReminderSettings"]
				and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID]
				and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][specID]
			then
				if
					addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][specID]
					and addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][specID][cbData.id]
					and not addon.MythicPlus.variables.knownLoadout[specID][addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][specID][cbData.id]]
				then
					if clear then
						addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][specID][cbData.id] = nil
					else
						table.insert(tRemoved, { spec = specName, dungeon = cbData.name })
					end
				end
			end
		end
	end

	if #tRemoved > 0 then
		local specGroups = {}
		for _, data in ipairs(tRemoved) do
			if not specGroups[data.spec] then specGroups[data.spec] = {} end
			table.insert(specGroups[data.spec], data.dungeon)
		end

		local fullMsg = {}
		for spec, dungeons in pairs(specGroups) do
			local list = spec .. ": " .. #dungeons .. " " .. DUNGEONS
			table.insert(fullMsg, list)
		end
		if #fullMsg then showWarning(table.concat(fullMsg, "\n")) end
	end
end

local firstLoad = true
local eventHandlers = {
	["TRAIT_CONFIG_CREATED"] = function()
		addon.MythicPlus.functions.getAllLoadouts()
		checkLoadout()
		addon.MythicPlus.functions.checkRemovedLoadout()
		addon.MythicPlus.functions.refreshTalentFrameIfOpen()
	end,
	["TRAIT_CONFIG_DELETED"] = function(arg1)
		addon.MythicPlus.functions.getAllLoadouts()
		checkLoadout()
		addon.MythicPlus.functions.checkRemovedLoadout()
		addon.MythicPlus.functions.refreshTalentFrameIfOpen()
	end,
	["TRAIT_CONFIG_UPDATED"] = function()
		C_Timer.After(0.2, function()
			addon.MythicPlus.functions.getAllLoadouts()
			checkLoadout()
			addon.MythicPlus.functions.checkRemovedLoadout()
			addon.MythicPlus.functions.refreshTalentFrameIfOpen()
		end)
	end,
	["READY_CHECK"] = function()
		if addon.db["talentReminderLoadOnReadyCheck"] then checkLoadout(true) end
	end,
	["ZONE_CHANGED_NEW_AREA"] = function() checkLoadout() end,
	["PLAYER_ENTERING_WORLD"] = function()
		if firstLoad then
			firstLoad = false
			C_Timer.After(1, function()
				addon.MythicPlus.functions.getAllLoadouts()
				addon.MythicPlus.functions.checkRemovedLoadout()
				checkLoadout()
				frameLoad:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end)
		end
	end,
}

local function registerEvents(frame)
	for event in pairs(eventHandlers) do
		frame:RegisterEvent(event)
	end
end
local function eventHandler(self, event, ...)
	if addon.db["talentReminderEnabled"] then
		if eventHandlers[event] then eventHandlers[event](...) end
	end
end
registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)
