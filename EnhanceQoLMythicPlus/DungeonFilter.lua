local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_MythicPlus")

addon.functions.InitDBValue("mythicPlusDungeonFilters", {})
if addon.db["mythicPlusDungeonFilters"][UnitGUID("player")] == nil then addon.db["mythicPlusDungeonFilters"][UnitGUID("player")] = {} end

local pDb = addon.db["mythicPlusDungeonFilters"][UnitGUID("player")]

local appliedLookup = {}

local ACTIVE_STATUS = {
	applied = true,
	invited = true,
	inviteaccepted = true,
	pending = true,
}

local function UpdateAppliedCache()
	wipe(appliedLookup)
	for _, appID in ipairs(C_LFGList.GetApplications()) do
		local resultID, status = C_LFGList.GetApplicationInfo(appID)
		if resultID and ACTIVE_STATUS[status] then appliedLookup[resultID] = true end
	end
end

local LUST_CLASSES = { SHAMAN = true, MAGE = true, HUNTER = true, EVOKER = true }
local BR_CLASSES = { DRUID = true, WARLOCK = true, DEATHKNIGHT = true, PALADIN = true }

local SearchInfoCache = {}

local function SoftCollect()
	local ticks = 0
	local frame = CreateFrame("Frame")
	frame:SetScript("OnUpdate", function(self)
		local done = collectgarbage("step", 50000)
		ticks = ticks + 1
		if done or ticks > 20 then self:SetScript("OnUpdate", nil) end
		self:Hide()
		self:SetParent(nil)
		frame = nil
	end)
end

local function PopulateInfoCache()
	SoftCollect()
	wipe(SearchInfoCache)
	local panel = LFGListFrame.SearchPanel
	local dp = panel.ScrollBox and panel.ScrollBox:GetDataProvider()
	if not dp then return end
	for _, element in dp:EnumerateEntireRange() do
		local resultID = element.resultID or element.id
		if resultID then SearchInfoCache[resultID] = C_LFGList.GetSearchResultInfo(resultID) end
	end
end

local playerIsLust = LUST_CLASSES[addon.variables.unitClass]
local playerIsBR = BR_CLASSES[addon.variables.unitClass]

local drop = LFGListFrame.SearchPanel.FilterButton
local originalSetupGen
local initialAllEntries = {}
local removedResults = {}

local titleScore1 = LFGListFrame:CreateFontString(nil, "OVERLAY")
titleScore1:SetFont(addon.variables.defaultFont, 13, "OUTLINE")
titleScore1:SetPoint("TOPRIGHT", PVEFrameLeftInset, "TOPRIGHT", -10, -5)
titleScore1:Hide()

drop:HookScript("OnHide", function()
	originalSetupGen = nil
	titleScore1:Hide()
	wipe(SearchInfoCache)
	SoftCollect()
end)

hooksecurefunc(drop, "SetupMenu", function(self, blizzGen)
	if not addon.db["mythicPlusEnableDungeonFilter"] then return end
	local panel = LFGListFrame.SearchPanel
	if panel.categoryID ~= 2 then return end
	if originalSetupGen and blizzGen ~= originalSetupGen then return end
	originalSetupGen = originalSetupGen or blizzGen

	local function EQOL_Generator(menu, root)
		blizzGen(menu, root)

		root:CreateTitle("")

		root:CreateTitle(addonName)
		root:CreateCheckbox(L["Partyfit"], function() return pDb["partyFit"] end, function() pDb["partyFit"] = not pDb["partyFit"] end)
		if not playerIsLust then
			root:CreateCheckbox(L["BloodlustAvailable"], function() return pDb["bloodlustAvailable"] end, function() pDb["bloodlustAvailable"] = not pDb["bloodlustAvailable"] end)
		end
		if not playerIsBR then
			root:CreateCheckbox(L["BattleResAvailable"], function() return pDb["battleResAvailable"] end, function() pDb["battleResAvailable"] = not pDb["battleResAvailable"] end)
		end
		if addon.variables.unitRole == "DAMAGER" then
			root:CreateCheckbox(
				(L["NoSameSpec"]):format(addon.variables.unitSpecName .. " " .. select(1, UnitClass("player"))),
				function() return pDb["NoSameSpec"] end,
				function() pDb["NoSameSpec"] = not pDb["NoSameSpec"] end
			)
		end
	end
	self:SetupMenu(EQOL_Generator)
	self.isSet = true
end)

local function MyCustomFilter(info)
	if appliedLookup[info.searchResultID] then return true end
	local groupTankCount, groupHealerCount, groupDPSCount = 0, 0, 0
	local hasLust, hasBR, hasSameSpec = false, false, false
	if info.numMembers == 5 then return false end
	for i = 1, info.numMembers do
		local mData = C_LFGList.GetSearchResultPlayerInfo(info.searchResultID, i)

		if mData.assignedRole == "TANK" then
			groupTankCount = groupTankCount + 1
		elseif mData.assignedRole == "HEALER" then
			groupHealerCount = groupHealerCount + 1
		elseif mData.assignedRole == "DAMAGER" then
			groupDPSCount = groupDPSCount + 1
		end
		if LUST_CLASSES[mData.classFilename] then
			hasLust = true
		elseif BR_CLASSES[mData.classFilename] then
			hasBR = true
		end
		if mData.classFilename == addon.variables.unitClass and mData.specName == addon.variables.unitSpecName then hasSameSpec = true end
	end

	if addon.variables.unitRole == "DAMAGER" and pDb["NoSameSpec"] and hasSameSpec then return false end

	if pDb["partyFit"] then
		-- Party-queue role availability check
		local needTanks, needHealers, needDPS = 0, 0, 0
		local partySize = GetNumGroupMembers()
		if partySize > 1 then
			-- Count roles in the player's party
			for i = 1, partySize do
				local unit = (i == 1) and "player" or ("party" .. (i - 1))
				local role = UnitGroupRolesAssigned(unit)
				if role == "TANK" then
					needTanks = needTanks + 1
				elseif role == "HEALER" then
					needHealers = needHealers + 1
				elseif role == "DAMAGER" then
					needDPS = needDPS + 1
				end
			end
		else
			-- solo or solo party also nur meine Rolle mit reinnehmen
			local role = addon.variables.unitRole
			if role == "TANK" then
				needTanks = needTanks + 1
			elseif role == "HEALER" then
				needHealers = needHealers + 1
			elseif role == "DAMAGER" then
				needDPS = needDPS + 1
			end
		end

		-- check for basic group requirement
		if needTanks > 1 then return false end
		if needHealers > 1 then return false end
		if needDPS > 3 then return false end

		if (1 - groupTankCount) < needTanks then return false end
		if (1 - groupHealerCount) < needHealers then return false end
		if (3 - groupDPSCount) < needDPS then return false end
		local freeSlots = 5 - info.numMembers
		if freeSlots < partySize then return false end
	end

	local partyHasLust, partyHasBR = false, false
	for i = 1, GetNumGroupMembers() do
		local unit = (i == 1) and "player" or ("party" .. (i - 1))
		local _, class = UnitClass(unit)
		if class and LUST_CLASSES[class] then partyHasLust = true end
		if class and BR_CLASSES[class] then partyHasBR = true end
	end

	local missingProviders = 0
	if pDb["bloodlustAvailable"] then
		if not hasLust and not partyHasLust then
			if groupTankCount == 0 then missingProviders = missingProviders + 1 end
			missingProviders = missingProviders + 1
		end
	end
	if pDb["battleResAvailable"] then
		if not hasBR and not partyHasBR then missingProviders = missingProviders + 1 end
	end

	local slotsAfterJoin = 5 - info.numMembers - 1
	if slotsAfterJoin < missingProviders then return false end
	return true
end

local function ApplyEQOLFilters(isInitial)
	if not drop:IsVisible() then return end
	if not addon.db["mythicPlusEnableDungeonFilter"] then return end
	if
		(not pDb["bloodlustAvailable"] or playerIsLust)
		and (not pDb["battleResAvailable"] or playerIsBR)
		and not pDb["partyFit"]
		and (not pDb["NoSameSpec"] or addon.variables.unitRole ~= "DAMAGER")
	then
		titleScore1:Hide()
		return
	end
	if GameTooltip:IsShown() then
		if not addon.eqolTooltipHooked then
			addon.eqolTooltipHooked = true
			GameTooltip:HookScript("OnHide", function()
				addon.eqolTooltipHooked = nil
				ApplyEQOLFilters(false)
			end)
		end
		return
	end
	local panel = LFGListFrame.SearchPanel
	if panel.categoryID ~= 2 then
		titleScore1:Hide()
		return
	end
	local dp = panel.ScrollBox and panel.ScrollBox:GetDataProvider()
	if not dp then return end

	-- On initial call, record total entries before removal
	if isInitial or not initialAllEntries then
		initialAllEntries = {}
		removedResults = {}
		for _, element in dp:EnumerateEntireRange() do
			local resultID = element.resultID or element.id
			if resultID then initialAllEntries[resultID] = true end
		end
	end

	for _, element in dp:EnumerateEntireRange() do
		local resultID = element.resultID or element.id
		if resultID then
			if resultID then initialAllEntries[resultID] = true end
			local info = SearchInfoCache[resultID]
			if info and not MyCustomFilter(info) then dp:Remove(element) end
		end
	end

	local removedCount = 0
	for _, v in pairs(initialAllEntries) do
		if v == false then removedCount = removedCount + 1 end
	end
	titleScore1:SetFormattedText((L["filteredTextEntries"]):format(removedCount))
	titleScore1:Show()
	panel.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end

local f

function addon.MythicPlus.functions.addDungeonFilter()
	if LFGListFrame.SearchPanel.FilterButton:IsShown() then
		LFGListFrame:Hide()
		LFGListFrame:Show()
	end
	f = CreateFrame("Frame")
	UpdateAppliedCache()
	f:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	f:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	f:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
	f:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	f:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	f:SetScript("OnEvent", function(_, event, ...)
		if not drop:IsVisible() then return end
		if not addon.db["mythicPlusEnableDungeonFilter"] then return end
		if event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
			PopulateInfoCache()
			ApplyEQOLFilters(true)
		elseif event == "LFG_LIST_SEARCH_RESULT_UPDATED" then
			local resultID = ...
			if resultID then SearchInfoCache[resultID] = C_LFGList.GetSearchResultInfo(resultID) end
			ApplyEQOLFilters(false)
		elseif event == "LFG_LIST_AVAILABILITY_UPDATE" then
			PopulateInfoCache()
			ApplyEQOLFilters(true)
		elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
			if drop then drop.eqolWrapped = nil end
		elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" or event == "LFG_LIST_APPLICATION_STATUS_UPDATED" or event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
			UpdateAppliedCache()
			ApplyEQOLFilters(false) -- <- direkt hinterher filtern
		end
	end)
end

function addon.MythicPlus.functions.removeDungeonFilter()
	if f then
		f:UnregisterAllEvents()
		f:Hide()
		f:SetScript("OnEvent", nil)
		f = nil
		wipe(SearchInfoCache)
		titleScore1:Hide()
		if LFGListFrame.SearchPanel.FilterButton:IsShown() then
			LFGListFrame:Hide()
			LFGListFrame:Show()
		end
	end
end

LFGListFrame.SearchPanel.FilterButton.ResetButton:HookScript("OnClick", function()
	if not addon.db["mythicPlusEnableDungeonFilter"] then return end
	if not addon.db["mythicPlusEnableDungeonFilterClearReset"] then return end
	pDb["bloodlustAvailable"] = false
	pDb["battleResAvailable"] = false
	pDb["partyFit"] = false
	pDb["NoSameSpec"] = false
end)
