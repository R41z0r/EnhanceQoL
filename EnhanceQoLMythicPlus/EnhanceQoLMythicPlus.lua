local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

local frameLoad = CreateFrame("Frame")

hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "UpdateTime", function(self, elapsedTime)
	if addon.db["mythicPlusChestTimer"] then
		local timeLeft = math.max(0, self.timeLimit - elapsedTime)
		local chest3Time = self.timeLimit * 0.4
		local chest2Time = self.timeLimit * 0.2

		if not self.CustomTextAdded then
			self.ChestTimeText2 = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			self.ChestTimeText2:SetPoint("TOPLEFT", self.TimeLeft, "TOPRIGHT", 3, 2) -- Position rechts unter der Statusleiste
			self.ChestTimeText3 = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			self.ChestTimeText3:SetPoint("BOTTOMLEFT", self.TimeLeft, "BOTTOMRIGHT", 3, 0) -- Position rechts unter der Statusleiste
			self.CustomTextAdded = true
		end

		if timeLeft > 0 then
			local chestText3 = ""
			local chestText2 = ""

			if timeLeft >= chest3Time then chestText3 = string.format("+3: %s", SecondsToClock(timeLeft - chest3Time)) end
			if timeLeft >= chest2Time then chestText2 = string.format("+2: %s", SecondsToClock(timeLeft - chest2Time)) end

			self.ChestTimeText2:SetText(chestText2)
			self.ChestTimeText3:SetText(chestText3)
		else
			self.ChestTimeText2:SetText("")
			self.ChestTimeText3:SetText("")
		end
	elseif self.CustomTextAdded then
		self.CustomTextAdded = false
		if self.ChestTimeText2 then
			self.ChestTimeText2:Hide()
			self.ChestTimeText2 = nil
		end
		if self.ChestTimeText3 then
			self.ChestTimeText3:Hide()
			self.ChestTimeText3 = nil
		end
	end
end)

local didApplyPatch = false
local originalFunc = ScenarioObjectiveTracker.UpdateCriteria
local patchedFunc = function(self, numCriteria)
	if not self:ShouldShowCriteria() then return end
	local objectivesBlock = self.ObjectivesBlock
	for criteriaIndex = 1, numCriteria do
		local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)
		if criteriaInfo then
			local criteriaString = criteriaInfo.description
			if not criteriaInfo.isWeightedProgress and not criteriaInfo.isFormatted then
				criteriaString = string.format("%d/%d %s", criteriaInfo.quantity, criteriaInfo.totalQuantity, criteriaInfo.description)
			end
			local line
			if criteriaInfo.completed then
				local existingLine = objectivesBlock:GetExistingLine(criteriaIndex)
				line = objectivesBlock:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"])
				line.Icon:Show()
				line.Icon:SetAtlas("ui-questtracker-tracker-check", false)
				if existingLine and (not line.state or line.state == ObjectiveTrackerAnimLineState.Present) then line:SetState(ObjectiveTrackerAnimLineState.Completing) end
			else
				line = objectivesBlock:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE)
				line.Icon:Show()
				line.Icon:SetAtlas("ui-questtracker-objective-nub", false)
			end
			-- progress bar
			if criteriaInfo.isWeightedProgress and not criteriaInfo.completed then
				local pb = objectivesBlock:AddProgressBar(criteriaIndex, self.progressBarLineSpacing)

				--@modified function
				local sValue = criteriaInfo.quantity
				if criteriaInfo.quantityString then
					sValue = tonumber(string.sub(criteriaInfo.quantityString, 1, string.len(criteriaInfo.quantityString) - 1)) / criteriaInfo.totalQuantity * 100
					sValue = math.floor(sValue * 100 + 0.5) / 100
				end
				ScenarioObjectiveTracker.trueValue = sValue
				local oFunc = ScenarioTrackerProgressBarMixin.SetValue
				local pFunc = function(self, percentage, trueValue)
					self.Bar:SetValue(percentage)
					if trueValue then
						self.Bar.Label:SetFormattedText(trueValue .. "%%")
					else
						self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percentage)
					end
					self.percentage = percentage
				end
				pb.SetValue = pFunc
				pb:SetValue(criteriaInfo.quantity, sValue)
				--@modified function end
			end

			-- timer
			if criteriaInfo.duration > 0 and criteriaInfo.elapsed <= criteriaInfo.duration then objectivesBlock:AddTimerBar(criteriaInfo.duration, GetTime() - criteriaInfo.elapsed) end
		end
	end
end

local function toggleHookToPercentBar()
	if addon.db["mythicPlusTruePercent"] then
		if IsInInstance() == false then
			if didApplyPatch then
				ScenarioObjectiveTracker.UpdateCriteria = originalFunc
				didApplyPatch = false
			end
			return
		end
		if didApplyPatch then return end
		didApplyPatch = true
		ScenarioObjectiveTracker.UpdateCriteria = patchedFunc
	elseif didApplyPatch then
		ScenarioObjectiveTracker.UpdateCriteria = originalFunc
		didApplyPatch = false
	end
end

ScenarioObjectiveTracker:HookScript("OnShow", function(self) toggleHookToPercentBar() end)

local function checkKeyStone()
	addon.MythicPlus.variables.handled = false -- reset handle on Keystoneframe open
	addon.MythicPlus.functions.removeExistingButton()
	local GetContainerNumSlots = C_Container.GetContainerNumSlots
	local GetContainerItemID = C_Container.GetContainerItemID
	local UseContainerItem = C_Container.UseContainerItem
	local GetContainerItemInfo = C_Container.GetContainerItemInfo

	local kId = C_MythicPlus.GetOwnedKeystoneMapID()
	local mapId = select(8, GetInstanceInfo())
	if nil ~= kId and mapId == kId then
		for container = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(container) do
				local id = GetContainerItemID(container, slot)
				if id == 180653 then
					-- Button for ReadyCheck
					addon.MythicPlus.functions.addButton(ChallengesKeystoneFrame, "ReadyCheck", L["ReadyCheck"], function(self, button)
						if self:GetText() == L["ReadyCheck"] then
							DoReadyCheck()
							self:SetText(L["ReadyCheckWaiting"])
						end
					end)
					-- Button for Pulltimer
					addon.MythicPlus.functions.addButton(ChallengesKeystoneFrame, "PullTimer", L["PullTimer"], function(self, button)
						if addon.MythicPlus.variables.handled == false then
							addon.MythicPlus.Buttons["PullTimer"]:SetText(L["Stating"])
							addon.MythicPlus.variables.breakIt = false
							addon.MythicPlus.variables.handled = true
							local x = nil
							-- Set time based on settings choosen
							if button == "RightButton" then
								x = addon.db["pullTimerShortTime"]
							else
								x = addon.db["pullTimerLongTime"]
							end
							local cTime = x

							C_Timer.NewTicker(1, function(self)
								if addon.MythicPlus.variables.breakIt then
									self:Cancel()
									C_PartyInfo.DoCountdown(0)
									if addon.db["noChatOnPullTimer"] == false then SendChatMessage("PULL Canceled", "Party") end
									C_ChatInfo.SendAddonMessage("D4", ("PT\t%s\t%d"):format(0, instanceId), IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
								end

								if x == 0 then
									self:Cancel()
									addon.MythicPlus.variables.handled = false
									if addon.db["noChatOnPullTimer"] == false then SendChatMessage(">>PULL NOW<<", "Party") end
									if addon.db["autoKeyStart"] == false then
										addon.MythicPlus.Buttons["PullTimer"]:SetText(L["PullTimer"])
									elseif addon.db["autoKeyStart"] and nil ~= C_ChallengeMode.GetSlottedKeystoneInfo() then
										C_ChallengeMode.StartChallengeMode()
										ChallengesKeystoneFrame:Hide()
									end
								else
									if x == cTime then
										local _, _, _, _, _, _, _, id = GetInstanceInfo()
										local instanceId = tonumber(id) or 0
										if addon.db["PullTimerType"] == 2 or addon.db["PullTimerType"] == 4 then C_PartyInfo.DoCountdown(cTime) end
										if addon.db["PullTimerType"] == 3 or addon.db["PullTimerType"] == 4 then
											C_ChatInfo.SendAddonMessage("D4", ("PT\t%s\t%d"):format(cTime, instanceId), IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
										end
									end
									if addon.MythicPlus.variables.breakIt == false then
										if addon.db["cancelPullTimerOnClick"] == true then
											addon.MythicPlus.Buttons["PullTimer"]:SetText(addon.LMythicPlus["Cancel"] .. " (" .. x .. ")")
										else
											addon.MythicPlus.Buttons["PullTimer"]:SetText(addon.LMythicPlus["Pull"] .. " (" .. x .. ")")
										end
									end
									if addon.MythicPlus.variables.breakIt == false then
										if addon.db["noChatOnPullTimer"] == false then SendChatMessage(format("PULL in %ds", x), "Party") end
									end
								end
								x = x - 1
							end)
						else
							if addon.db["cancelPullTimerOnClick"] == true then
								self:SetText(L["PullTimer"])
								addon.MythicPlus.variables.breakIt = true
								addon.MythicPlus.variables.handled = false
							end
						end
					end)
					if addon.db["autoInsertKeystone"] and addon.db["autoInsertKeystone"] == true then
						UseContainerItem(container, slot)
						if addon.db["closeBagsOnKeyInsert"] and addon.db["closeBagsOnKeyInsert"] == true then CloseAllBags() end
					end
					break
				end
			end
		end
	end
end

-- Registriere das Event
frameLoad:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
frameLoad:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
frameLoad:RegisterEvent("READY_CHECK_FINISHED")
frameLoad:RegisterEvent("LFG_ROLE_CHECK_SHOW")
frameLoad:RegisterEvent("RAID_TARGET_UPDATE")
frameLoad:RegisterEvent("PLAYER_ROLES_ASSIGNED")
frameLoad:RegisterEvent("READY_CHECK")
frameLoad:RegisterEvent("GROUP_ROSTER_UPDATE")
frameLoad:RegisterEvent("PLAYER_ENTERING_WORLD")

local function skipRolecheck()
	local tank, healer, dps = false, false, false
	local role = UnitGroupRolesAssigned("player")
	if role == "NONE" then role = GetSpecializationRole(GetSpecialization()) end
	if role == "TANK" then
		tank = true
	elseif role == "DAMAGER" then
		dps = true
	elseif role == "HEALER" then
		healer = true
	end
	if LFDRoleCheckPopupRoleButtonTank.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(tank) end
	if LFDRoleCheckPopupRoleButtonHealer.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(healer) end
	if LFDRoleCheckPopupRoleButtonDPS.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(dps) end
	LFDRoleCheckPopupAcceptButton:Enable()
	LFDRoleCheckPopupAcceptButton:Click()
end

local function toggleGroupApplication(value)
	if value then
		-- Hide overlay and text label
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Label:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Background:Hide()
		-- Hide the 3 animated texture icons
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:Hide()
	else
		-- Hide overlay and text label
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Label:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Background:Show()
		-- Hide the 3 animated texture icons
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:Show()
	end
end

local function setActTank()
	if UnitGroupRolesAssigned("player") == "TANK" then
		addon.MythicPlus.actTank = "player"
		return
	end
	for i = 1, 4 do
		local unit = "party" .. i
		if UnitGroupRolesAssigned(unit) == "TANK" then
			addon.MythicPlus.actTank = unit
			return
		end
	end
	addon.MythicPlus.actTank = nil
end

local function checkRaidMarker()
	if nil == addon.MythicPlus.actTank then setActTank() end
	if nil ~= addon.MythicPlus.actTank then
		if UnitInParty(addon.MythicPlus.actTank) then
			local rIndex = GetRaidTargetIndex(addon.MythicPlus.actTank)
			if nil == rIndex then
				SetRaidTarget(addon.MythicPlus.actTank, addon.db["autoMarkTankInDungeonMarker"])
			elseif rIndex ~= addon.db["autoMarkTankInDungeonMarker"] and UnitGroupRolesAssigned("player") == "TANK" then
				SetRaidTarget(addon.MythicPlus.actTank, addon.db["autoMarkTankInDungeonMarker"])
			elseif rIndex ~= addon.db["autoMarkTankInDungeonMarker"] and UnitIsGroupLeader("player") then
				SetRaidTarget(addon.MythicPlus.actTank, addon.db["autoMarkTankInDungeonMarker"])
			end
		end
	end
end

local function checkCondition()
	--@debug@
	-- No Automark for healer when it's me
	if UnitInParty("player") and UnitGroupRolesAssigned("player") == "HEALER" then
		local rIndex = GetRaidTargetIndex("player")
		if nil ~= rIndex then SetRaidTarget("player", 0) end
	end
	--@end-debug@

	if addon.db["autoMarkTankInDungeon"] then
		local _, _, difficultyID, difficultyName = GetInstanceInfo()
		if difficultyID == 1 and addon.db["mythicPlusIgnoreNormal"] then return false end
		if difficultyID == 2 and addon.db["mythicPlusIgnoreHeroic"] then return false end
		if difficultyID == 19 and addon.db["mythicPlusIgnoreEvent"] then return false end
		if (difficultyID == 23 or difficultyID == 150) and addon.db["mythicPlusIgnoreMythic"] then return false end
		if difficultyID == 24 and addon.db["mythicPlusIgnoreTimewalking"] then return false end
		if UnitInParty("player") and not UnitInRaid("player") and select(1, IsInInstance()) == true then return true end
	end
	return false
end

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2, arg3, arg4)
	if event == "ADDON_LOADED" and arg1 == addonName then
		-- loadMain()
	elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
		if InCombatLockdown() then return end
		checkKeyStone()
	elseif event == "READY_CHECK_FINISHED" and ChallengesKeystoneFrame and addon.MythicPlus.Buttons["ReadyCheck"] then
		addon.MythicPlus.Buttons["ReadyCheck"]:SetText(L["ReadyCheck"])
	elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" and addon.db["groupfinderAppText"] then
		if InCombatLockdown() then return end
		toggleGroupApplication(true)
	elseif event == "LFG_ROLE_CHECK_SHOW" and addon.db["groupfinderSkipRolecheck"] and UnitInParty("player") then
		skipRolecheck()
	elseif event == "RAID_TARGET_UPDATE" and checkCondition() then
		C_Timer.After(0.5, function() checkRaidMarker() end)
	elseif event == "PLAYER_ROLES_ASSIGNED" and checkCondition() then
		setActTank()
		checkRaidMarker()
	elseif event == "GROUP_ROSTER_UPDATE" and checkCondition() then
		setActTank()
		checkRaidMarker()
	elseif event == "PLAYER_ENTERING_WORLD" then
		toggleHookToPercentBar()
	elseif event == "READY_CHECK" and checkCondition() then
		setActTank()
		checkRaidMarker()
	end
end

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

local function addDungeonBrowserFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["None"], [2] = L["Enemies"], [3] = L["Friendly"], [4] = L["Both"] })

	local data = {
		{
			text = L["groupfinderAppText"],
			var = "groupfinderAppText",
			func = function(self, _, value)
				addon.db["groupfinderAppText"] = value
				toggleGroupApplication(value)
			end,
		},
		{ text = L["groupfinderSkipRolecheck"], var = "groupfinderSkipRolecheck", func = function(self, _, value) addon.db["groupfinderSkipRolecheck"] = value end },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func)
		groupCore:AddChild(cbElement)
	end
end

local function addKeystoneFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["Automatically insert keystone"],
			var = "autoInsertKeystone",
		},
		{
			text = L["Close all bags on keystone insert"],
			var = "closeBagsOnKeyInsert",
		},
		{
			text = L["Cancel Pull Timer on click"],
			var = "cancelPullTimerOnClick",
		},
		{
			text = L["noChatOnPullTimer"],
			var = "noChatOnPullTimer",
		},
		{
			text = L["autoKeyStart"],
			var = "autoKeyStart",
		},
		{
			text = L["mythicPlusTruePercent"],
			var = "mythicPlusTruePercent",
			func = function(self, _, value)
				addon.db["mythicPlusTruePercent"] = value
				if value == true and didApplyPatch == false then
				end
				if ScenarioObjectiveTracker:IsShown() then toggleHookToPercentBar() end
			end,
		},
		{
			text = L["mythicPlusChestTimer"],
			var = "mythicPlusChestTimer",
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupCore:AddChild(cbElement)
	end

	local list, order = addon.functions.prepareListForDropdown({ [1] = L["None"], [2] = L["Blizzard Pull Timer"], [3] = L["DBM / BigWigs Pull Timer"], [4] = L["Both"] })

	local dropPullTimerType = addon.functions.createDropdownAce(L["Pull Timer "], list, order, function(self, _, value) addon.db["PullTimerType"] = value end)
	dropPullTimerType:SetValue(addon.db["PullTimerType"])
	dropPullTimerType:SetFullWidth(false)
	dropPullTimerType:SetWidth(200)
	groupCore:AddChild(dropPullTimerType)
	groupCore:AddChild(addon.functions.createSpacerAce())

	local longSlider = addon.functions.createSliderAce(L["sliderLongTime"] .. ": " .. addon.db["pullTimerLongTime"] .. "s", addon.db["pullTimerLongTime"], 0, 60, 1, function(self, _, value2)
		addon.db["pullTimerLongTime"] = value2
		self:SetLabel(L["sliderLongTime"] .. ": " .. value2 .. "s")
	end)
	longSlider:SetFullWidth(false)
	longSlider:SetWidth(300)
	groupCore:AddChild(longSlider)

	groupCore:AddChild(addon.functions.createSpacerAce())

	local shortSlider = addon.functions.createSliderAce(L["sliderShortTime"] .. ": " .. addon.db["pullTimerShortTime"] .. "s", addon.db["pullTimerShortTime"], 0, 60, 1, function(self, _, value2)
		addon.db["pullTimerShortTime"] = value2
		self:SetLabel(L["sliderShortTime"] .. ": " .. value2 .. "s")
	end)
	shortSlider:SetFullWidth(false)
	shortSlider:SetWidth(300)
	groupCore:AddChild(shortSlider)
end

local function addPotionTrackerFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	groupCore:SetTitle(L["potionTrackerHeadline"])

	local cbPotionTrackerEnabled = addon.functions.createCheckboxAce(L["potionTracker"], addon.db["potionTracker"], function(self, _, value)
		addon.db["potionTracker"] = value
		container:ReleaseChildren()
		addPotionTrackerFrame(container)
		if value == false then addon.MythicPlus.functions.resetCooldownBars() end
	end)
	groupCore:AddChild(cbPotionTrackerEnabled)

	if addon.db["potionTracker"] then
		groupCore:AddChild(addon.functions.createSpacerAce())

		local btnToggleAnchor = addon.functions.createButtonAce(L["Toggle Anchor"], 140, function(self)
			if addon.MythicPlus.anchorFrame:IsShown() then
				addon.MythicPlus.anchorFrame:Hide()
				self:SetText(L["Toggle Anchor"])
			else
				self:SetText(L["Save Anchor"])
				addon.MythicPlus.anchorFrame:Show()
			end
		end)
		groupCore:AddChild(btnToggleAnchor)
		groupCore:AddChild(addon.functions.createSpacerAce())

		local data = {
			{
				text = L["potionTrackerUpwardsBar"],
				var = "potionTrackerUpwardsBar",
				func = function(self, _, value)
					addon.db["potionTrackerUpwardsBar"] = value
					addon.MythicPlus.functions.updateBars()
				end,
			},
			{
				text = L["potionTrackerClassColor"],
				var = "potionTrackerClassColor",
			},
			{
				text = L["potionTrackerDisableRaid"],
				var = "potionTrackerDisableRaid",
				func = function(self, _, value)
					addon.db["potionTrackerDisableRaid"] = value
					if value == true and UnitInRaid("player") then addon.MythicPlus.functions.resetCooldownBars() end
				end,
			},
			{
				text = L["potionTrackerShowTooltip"],
				var = "potionTrackerShowTooltip",
			},
			{
				text = L["potionTrackerHealingPotions"],
				var = "potionTrackerHealingPotions",
			},
			{
				text = L["potionTrackerOffhealing"],
				var = "potionTrackerOffhealing",
			},
		}

		table.sort(data, function(a, b) return a.text < b.text end)

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value) addon.db[cbData.var] = value end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupCore:AddChild(cbElement)
		end
	end
end

local function addTeleportFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	groupCore:SetTitle(L["teleportsHeadline"])
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["None"], [2] = L["Enemies"], [3] = L["Friendly"], [4] = L["Both"] })

	local cbTeleportsEnabled = addon.functions.createCheckboxAce(L["teleportEnabled"], addon.db["teleportFrame"], function(self, _, value)
		addon.db["teleportFrame"] = value
		container:ReleaseChildren()
		addTeleportFrame(container)
		addon.MythicPlus.functions.toggleFrame()
	end)
	groupCore:AddChild(cbTeleportsEnabled)

	if addon.db["teleportFrame"] then
		local data = {
			{
				text = L["teleportsEnableCompendium"],
				var = "teleportsEnableCompendium",
			},
			{
				text = L["portalHideMissing"],
				var = "portalHideMissing",
			},
			{
				text = L["hideActualSeason"],
				var = "hideActualSeason",
			},
			{
				text = L["portalShowTooltip"],
				var = "portalShowTooltip",
				func = function(self, _, value) addon.db["portalShowTooltip"] = value end,
			},
		}

		table.sort(data, function(a, b) return a.text < b.text end)

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value)
				addon.db[cbData.var] = value
				addon.MythicPlus.functions.toggleFrame()
			end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupCore:AddChild(cbElement)
		end
	end
end

local function addMiscFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local cbAutoMarkTank = addon.functions.createCheckboxAce(L["autoMarkTankInDungeon"], addon.db["autoMarkTankInDungeon"], function(self, _, value)
		addon.db["autoMarkTankInDungeon"] = value
		if value and UnitInParty("player") and not UnitInRaid("player") and select(1, IsInInstance()) == true then
			setActTank()
			checkRaidMarker()
		end
		container:ReleaseChildren()
		addMiscFrame(container)
	end)
	groupCore:AddChild(cbAutoMarkTank)

	if addon.db["autoMarkTankInDungeon"] then
		local list, order = addon.functions.prepareListForDropdown({
			[1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:20|t",
			[2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:20|t",
			[3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:20|t",
			[4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:20|t",
			[5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:20|t",
			[6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:20|t",
			[7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:20|t",
			[8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:20|t",
		})

		local dropTankMark = addon.functions.createDropdownAce(L["autoMarkTankInDungeonMarker"], list, order, function(self, _, value) addon.db["autoMarkTankInDungeonMarker"] = value end)
		dropTankMark:SetValue(addon.db["autoMarkTankInDungeonMarker"])
		dropTankMark:SetFullWidth(false)
		dropTankMark:SetWidth(100)
		groupCore:AddChild(dropTankMark)

		groupCore:AddChild(addon.functions.createSpacerAce())

		local data = {
			{ text = L["mythicPlusIgnoreNormal"], var = "mythicPlusIgnoreNormal" },
			{ text = L["mythicPlusIgnoreHeroic"], var = "mythicPlusIgnoreHeroic" },
			{ text = L["mythicPlusIgnoreEvent"], var = "mythicPlusIgnoreEvent" },
			{ text = L["mythicPlusIgnoreMythic"], var = "mythicPlusIgnoreMythic" },
			{ text = L["mythicPlusIgnoreTimewalking"], var = "mythicPlusIgnoreTimewalking" },
		}

		-- table.sort(data, function(a, b) return a.text < b.text end)

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value) addon.db[cbData.var] = value end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupCore:AddChild(cbElement)
		end
	end

	groupCore:AddChild(addon.functions.createSpacerAce())
	local labelExplanation = addon.functions.createLabelAce("|cffffd700" .. L["autoMarkTankExplanation"] .. "|r", nil, nil, 14)
	labelExplanation:SetFullWidth(true)
	groupCore:AddChild(labelExplanation)
end

addon.variables.statusTable.groups["mythicplus"] = true
addon.functions.addToTree(nil, {
	value = "mythicplus",
	text = L["Mythic Plus"],
	children = {
		{ value = "dungeonbrowser", text = L["DungeonBrowser"] },
		{ value = "keystone", text = L["Keystone"] },
		{ value = "misc", text = L["Misc"] },
		{ value = "potiontracker", text = L["Potion Tracker"] },
		{ value = "teleports", text = L["Teleports"] },
	},
})

function addon.MythicPlus.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	-- Prüfen, welche Gruppe ausgewählt wurde
	if group == "mythicplus\001dungeonbrowser" then
		addDungeonBrowserFrame(container)
	elseif group == "mythicplus\001keystone" then
		addKeystoneFrame(container)
	elseif group == "mythicplus\001potiontracker" then
		addPotionTrackerFrame(container)
	elseif group == "mythicplus\001misc" then
		addMiscFrame(container)
	elseif group == "mythicplus\001teleports" then
		addTeleportFrame(container)
	end
end
