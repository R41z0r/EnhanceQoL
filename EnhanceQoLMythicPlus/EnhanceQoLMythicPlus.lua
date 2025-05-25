local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_MythicPlus")

local frameLoad = CreateFrame("Frame")

local brButton
local defaultButtonSize = 60
local defaultFontSize = 16

local function removeBRFrame()
	if brButton then
		brButton:Hide()
		brButton:SetParent(nil)
		brButton:SetScript("OnClick", nil)
		brButton:SetScript("OnEnter", nil)
		brButton:SetScript("OnLeave", nil)
		brButton:SetScript("OnUpdate", nil)
		brButton:SetScript("OnEvent", nil)
		brButton:SetScript("OnDragStart", nil)
		brButton:SetScript("OnDragStop", nil)
		brButton:UnregisterAllEvents()
		brButton:ClearAllPoints()
		brButton = nil
	end
end

local function createBRFrame()
	removeBRFrame()
	if not addon.db["mythicPlusBRTrackerEnabled"] then return end
	if UnitInParty("player") and IsInInstance() and select(3, GetInstanceInfo()) == 8 then
		brButton = CreateFrame("Button", nil, UIParent)
		brButton:SetSize(addon.db["mythicPlusBRButtonSize"], addon.db["mythicPlusBRButtonSize"])
		brButton:SetPoint(addon.db["mythicPlusBRTrackerPoint"], UIParent, addon.db["mythicPlusBRTrackerPoint"], addon.db["mythicPlusBRTrackerX"], addon.db["mythicPlusBRTrackerY"])

		if addon.db["mythicPlusBRTrackerLocked"] == false then
			brButton:SetMovable(true)
			brButton:EnableMouse(true)
			brButton:RegisterForDrag("LeftButton")

			brButton:SetScript("OnDragStart", brButton.StartMoving)
			brButton:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				local point, _, _, xOfs, yOfs = self:GetPoint()
				addon.db["mythicPlusBRTrackerPoint"] = point
				addon.db["mythicPlusBRTrackerX"] = xOfs
				addon.db["mythicPlusBRTrackerY"] = yOfs
			end)
		end

		local bg = brButton:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(brButton)
		bg:SetColorTexture(0, 0, 0, 0.8)

		local icon = brButton:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints(brButton)
		icon:SetTexture(136080)
		brButton.icon = icon

		local scaleFactor = addon.db["mythicPlusBRButtonSize"] / defaultButtonSize
		local newFontSize = math.floor(defaultFontSize * scaleFactor + 0.5)

		brButton.cooldownFrame = CreateFrame("Cooldown", nil, brButton, "CooldownFrameTemplate")
		brButton.cooldownFrame:SetAllPoints(brButton)
		brButton.cooldownFrame.cooldownSet = false
		brButton.cooldownFrame:SetSwipeColor(0, 0, 0, 0.3)
		brButton.cooldownFrame:SetCountdownAbbrevThreshold(600)
		brButton.cooldownFrame:SetScale(scaleFactor)
		brButton.cooldownFrame:SetDrawEdge(false)

		brButton.charges = brButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		brButton.charges:SetPoint("BOTTOMRIGHT", brButton, "BOTTOMRIGHT", -3, 3)
		brButton.charges:SetFont(addon.variables.defaultFont, newFontSize, "OUTLINE")
	end
end

local function setBRInfo(info)
	if brButton and brButton.cooldownFrame and info then
		local current = info.currentCharges
		local max = info.maxCharges

		if current < max then
			if brButton.cooldownFrame.charges ~= current or brButton.cooldownFrame.startTime ~= info.cooldownStartTime then
				brButton.cooldownFrame:SetCooldown(info.cooldownStartTime, info.cooldownDuration, info.chargeModRate)
				brButton.cooldownFrame.startTime = info.cooldownStartTime
				brButton.cooldownFrame.charges = current

				if current > 0 then
					brButton.charges:SetTextColor(0, 1, 0)
					brButton.icon:SetDesaturated(false)
					brButton.cooldownFrame:SetSwipeColor(0, 0, 0, 0.3)
					brButton.charges:Show()
				else
					brButton.cooldownFrame:SetSwipeColor(0, 0, 0, 1)
					brButton.icon:SetDesaturated(true)
					brButton.charges:SetTextColor(1, 0, 0)
					brButton.charges:Hide()
				end
			end
		else
			brButton.cooldownFrame:Clear()
			brButton.charges:SetTextColor(0, 1, 0)
		end
		brButton.charges:SetText(current)
	end
end

hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "UpdateTime", function(self, elapsedTime)
	if addon.db["mythicPlusBRTrackerEnabled"] then
		if not brButton or not brButton.cooldownFrame or not brButton.cooldownFrame.cooldownSet then
			createBRFrame()
			if brButton and brButton.cooldownFrame then
				brButton.cooldownFrame.cooldownSet = true
				local info = C_Spell.GetSpellCharges(20484)
				setBRInfo(info)
			end
		end
	end

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

local function GetScenarioPercent(criteriaIndex)
	local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)
	if criteriaInfo and criteriaInfo.isWeightedProgress then
		local sValue = criteriaInfo.quantity
		if criteriaInfo.quantityString then
			sValue = tonumber(string.sub(criteriaInfo.quantityString, 1, string.len(criteriaInfo.quantityString) - 1)) / criteriaInfo.totalQuantity * 100
			sValue = math.floor(sValue * 100 + 0.5) / 100
		end
		return sValue
	end
	return nil
end

hooksecurefunc(ScenarioTrackerProgressBarMixin, "SetValue", function(self, percentage)
	if addon.db["mythicPlusTruePercent"] then
		if not IsInInstance() or not self:IsVisible() then return end
		local _, _, diff = GetInstanceInfo()
		if diff ~= 8 then return end -- only in mythic challenge mode
		local sData = C_ScenarioInfo.GetScenarioStepInfo()
		if nil == sData then return end

		local truePercent
		if self.criteriaIndex then self.criteriaIndex = nil end
		for criteriaIndex = 1, sData.numCriteria do
			if nil == truePercent then
				truePercent = GetScenarioPercent(criteriaIndex)
				if truePercent then
					self.Bar.Label:SetFormattedText(truePercent .. "%%")
					self.percentage = percentage
				end
			end
		end
	end
end)

local function createButtons()
	if not addon.db["enableKeystoneHelperNewUI"] then
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
								addon.MythicPlus.Buttons["PullTimer"]:SetText(L["Cancel"] .. " (" .. x .. ")")
							else
								addon.MythicPlus.Buttons["PullTimer"]:SetText(L["Pull"] .. " (" .. x .. ")")
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
	else
		addon.MythicPlus.functions.addRCButton()
		addon.MythicPlus.functions.addPullButton()
	end
end

local function checkKeyStone()
	addon.MythicPlus.variables.handled = false -- reset handle on Keystoneframe open
	addon.MythicPlus.functions.removeExistingButton()
	if not addon.db["enableKeystoneHelper"] then return end
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
					-- Button for ReadyCheck and Pulltimer
					if UnitInParty("player") and UnitIsGroupLeader("player") then createButtons() end

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
frameLoad:RegisterEvent("READY_CHECK_FINISHED")
frameLoad:RegisterEvent("LFG_ROLE_CHECK_SHOW")
frameLoad:RegisterEvent("RAID_TARGET_UPDATE")
frameLoad:RegisterEvent("PLAYER_ROLES_ASSIGNED")
frameLoad:RegisterEvent("READY_CHECK")
frameLoad:RegisterEvent("GROUP_ROSTER_UPDATE")
frameLoad:RegisterEvent("SPELL_UPDATE_CHARGES")
frameLoad:RegisterEvent("ENCOUNTER_END")

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
	if addon.db["mythicPlusNoHealerMark"] and UnitInParty("player") and UnitGroupRolesAssigned("player") == "HEALER" then
		local rIndex = GetRaidTargetIndex("player")
		if nil ~= rIndex then SetRaidTarget("player", 0) end
	end

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
		if addon.db["enableKeystoneHelper"] then checkKeyStone() end
	elseif event == "READY_CHECK_FINISHED" and ChallengesKeystoneFrame and addon.MythicPlus.Buttons["ReadyCheck"] then
		addon.MythicPlus.Buttons["ReadyCheck"]:SetText(L["ReadyCheck"])
	elseif event == "RAID_TARGET_UPDATE" and checkCondition() then
		C_Timer.After(0.5, function() checkRaidMarker() end)
	elseif event == "PLAYER_ROLES_ASSIGNED" and checkCondition() then
		setActTank()
		checkRaidMarker()
	elseif event == "GROUP_ROSTER_UPDATE" and checkCondition() then
		setActTank()
		checkRaidMarker()
	elseif event == "READY_CHECK" and checkCondition() then
		setActTank()
		checkRaidMarker()
	elseif event == "SPELL_UPDATE_CHARGES" then
		if IsInInstance() and select(3, GetInstanceInfo()) == 8 then
			if not brButton or not brButton.cooldownFrame then createBRFrame() end
			local info = C_Spell.GetSpellCharges(20484)
			setBRInfo(info)
		else
			removeBRFrame()
		end
	elseif event == "ENCOUNTER_END" then
		removeBRFrame()
	end
end

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

local function addDungeonBrowserFrame(container) end

local function addKeystoneFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["enableKeystoneHelper"],
			var = "enableKeystoneHelper",
			func = function(self, _, value)
				addon.db["enableKeystoneHelper"] = value
				container:ReleaseChildren()
				addKeystoneFrame(container)
				if _G["ChallengesKeystoneFrame"] and ChallengesKeystoneFrame:IsShown() then checkKeyStone() end
			end,
		},
	}
	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["enableKeystoneHelper"] then
		local groupEnabled = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupEnabled)

		local data = {
			{
				text = L["Automatically insert keystone"],
				var = "autoInsertKeystone",
			},
			{
				text = L["enableKeystoneHelperNewUI"],
				var = "enableKeystoneHelperNewUI",
				func = function(self, _, value)
					addon.db["enableKeystoneHelperNewUI"] = value
					if _G["ChallengesKeystoneFrame"] and ChallengesKeystoneFrame:IsShown() then checkKeyStone() end
				end,
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
				func = function(self, _, value) addon.db["mythicPlusTruePercent"] = value end,
			},
			{
				text = L["mythicPlusChestTimer"],
				var = "mythicPlusChestTimer",
			},
			{
				text = L["groupfinderShowPartyKeystone"],
				var = "groupfinderShowPartyKeystone",
				func = function(self, _, value)
					addon.db["groupfinderShowPartyKeystone"] = value
					addon.MythicPlus.functions.togglePartyKeystone()
				end,
				desc = L["groupfinderShowPartyKeystoneDesc"],
			},
		}

		table.sort(data, function(a, b) return a.text < b.text end)

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value) addon.db[cbData.var] = value end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupEnabled:AddChild(cbElement)
		end

		local list, order = addon.functions.prepareListForDropdown({ [1] = L["None"], [2] = L["Blizzard Pull Timer"], [3] = L["DBM / BigWigs Pull Timer"], [4] = L["Both"] })

		local dropPullTimerType = addon.functions.createDropdownAce(L["PullTimer"], list, order, function(self, _, value) addon.db["PullTimerType"] = value end)
		dropPullTimerType:SetValue(addon.db["PullTimerType"])
		dropPullTimerType:SetFullWidth(false)
		dropPullTimerType:SetWidth(200)
		groupEnabled:AddChild(dropPullTimerType)
		groupEnabled:AddChild(addon.functions.createSpacerAce())

		local longSlider = addon.functions.createSliderAce(L["sliderLongTime"] .. ": " .. addon.db["pullTimerLongTime"] .. "s", addon.db["pullTimerLongTime"], 0, 60, 1, function(self, _, value2)
			addon.db["pullTimerLongTime"] = value2
			self:SetLabel(L["sliderLongTime"] .. ": " .. value2 .. "s")
		end)
		longSlider:SetFullWidth(false)
		longSlider:SetWidth(300)
		groupEnabled:AddChild(longSlider)

		groupEnabled:AddChild(addon.functions.createSpacerAce())

		local shortSlider = addon.functions.createSliderAce(L["sliderShortTime"] .. ": " .. addon.db["pullTimerShortTime"] .. "s", addon.db["pullTimerShortTime"], 0, 60, 1, function(self, _, value2)
			addon.db["pullTimerShortTime"] = value2
			self:SetLabel(L["sliderShortTime"] .. ": " .. value2 .. "s")
		end)
		shortSlider:SetFullWidth(false)
		shortSlider:SetWidth(300)
		groupEnabled:AddChild(shortSlider)
	end
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

local function addBRFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	groupCore:SetTitle(L["brTrackerHeadline"])

	local cbBREnabled = addon.functions.createCheckboxAce(L["mythicPlusBRTrackerEnabled"], addon.db["mythicPlusBRTrackerEnabled"], function(self, _, value)
		addon.db["mythicPlusBRTrackerEnabled"] = value
		createBRFrame()
		container:ReleaseChildren()
		addBRFrame(container)
	end)
	groupCore:AddChild(cbBREnabled)

	if addon.db["mythicPlusBRTrackerEnabled"] then
		local data = {
			{
				text = L["mythicPlusBRTrackerLocked"],
				var = "mythicPlusBRTrackerLocked",
				func = function(self, _, value)
					addon.db["mythicPlusBRTrackerLocked"] = value
					createBRFrame()
				end,
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

		local sButtonSize = addon.functions.createSliderAce(
			L["mythicPlusBRButtonSizeHeadline"] .. ": " .. addon.db["mythicPlusBRButtonSize"],
			addon.db["mythicPlusBRButtonSize"],
			20,
			100,
			1,
			function(self, _, value2)
				addon.db["mythicPlusBRButtonSize"] = value2
				createBRFrame()
				self:SetLabel(L["mythicPlusBRButtonSizeHeadline"] .. ": " .. value2)
			end
		)
		groupCore:AddChild(sButtonSize)
	end
end

local function addTeleportFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	groupCore:SetTitle(L["teleportsHeadline"])

	local cbTeleportsEnabled = addon.functions.createCheckboxAce(L["teleportEnabled"], addon.db["teleportFrame"], function(self, _, value)
		addon.db["teleportFrame"] = value
		container:ReleaseChildren()
		addTeleportFrame(container)
		addon.MythicPlus.functions.toggleFrame()
	end)
	groupCore:AddChild(cbTeleportsEnabled)

	-- if addon.db["teleportFrame"] then
	local data = {
		{
			text = L["teleportsEnableCompendium"],
			var = "teleportsEnableCompendium",
			func = function(self, _, value)
				addon.db["teleportsEnableCompendium"] = value
				container:ReleaseChildren()
				addTeleportFrame(container)
				addon.MythicPlus.functions.toggleFrame()
			end,
		},
		{
			text = L["portalHideMissing"],
			var = "portalHideMissing",
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
	-- end

	if addon.db["teleportsEnableCompendium"] then
		local groupCompendiumAddition = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCompendiumAddition)
		groupCompendiumAddition:SetTitle(L["teleportCompendiumAdditionHeadline"])
		local data = {
			{
				text = L["hideActualSeason"],
				var = "hideActualSeason",
			},
			{
				text = L["portalShowDungeonTeleports"],
				var = "portalShowDungeonTeleports",
			},
			{
				text = L["portalShowRaidTeleports"],
				var = "portalShowRaidTeleports",
			},
			{
				text = L["portalShowEngineering"],
				var = "portalShowEngineering",
			},
			{
				text = L["portalShowToyHearthstones"],
				var = "portalShowToyHearthstones",
			},
			{
				text = L["portalShowClassTeleport"],
				var = "portalShowClassTeleport",
			},
			{
				text = L["portalShowMagePortal"],
				var = "portalShowMagePortal",
			},
		}

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value)
				addon.db[cbData.var] = value
				addon.MythicPlus.functions.toggleFrame()
			end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupCompendiumAddition:AddChild(cbElement)
		end

		local groupCompendium = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCompendium)
		groupCompendium:SetTitle(L["teleportCompendiumHeadline"])
		data = {}

		local sortedIndexes = {}
		for key, _ in pairs(addon.MythicPlus.variables.portalCompendium) do
			table.insert(sortedIndexes, key)
		end

		table.sort(sortedIndexes, function(a, b) return a > b end)

		for _, key in ipairs(sortedIndexes) do
			local v = addon.MythicPlus.variables.portalCompendium[key]
			table.insert(data, {
				text = HIDE .. " " .. v.headline,
				var = "teleportsCompendiumHide" .. v.headline,
			})
		end

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value)
				addon.db[cbData.var] = value
				addon.MythicPlus.functions.toggleFrame()
			end
			if cbData.func then uFunc = cbData.func end
			local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
			groupCompendium:AddChild(cbElement)
		end
	end

	scroll:DoLayout()
	wrapper:DoLayout()
end

local function addAutoMarkFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local cbAutoMarkTank = addon.functions.createCheckboxAce(L["autoMarkTankInDungeon"]:format(TANK), addon.db["autoMarkTankInDungeon"], function(self, _, value)
		addon.db["autoMarkTankInDungeon"] = value
		if value and UnitInParty("player") and not UnitInRaid("player") and select(1, IsInInstance()) == true then
			setActTank()
			checkRaidMarker()
		end
		container:ReleaseChildren()
		addAutoMarkFrame(container)
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
			{ text = L["mythicPlusIgnoreNormal"]:format(PLAYER_DIFFICULTY1), var = "mythicPlusIgnoreNormal" },
			{ text = L["mythicPlusIgnoreHeroic"]:format(PLAYER_DIFFICULTY2), var = "mythicPlusIgnoreHeroic" },
			{ text = L["mythicPlusIgnoreEvent"]:format(BATTLE_PET_SOURCE_7), var = "mythicPlusIgnoreEvent" },
			{ text = L["mythicPlusIgnoreMythic"]:format(PLAYER_DIFFICULTY6), var = "mythicPlusIgnoreMythic" },
			{ text = L["mythicPlusIgnoreTimewalking"]:format(PLAYER_DIFFICULTY_TIMEWALKER), var = "mythicPlusIgnoreTimewalking" },
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
	local labelExplanation = addon.functions.createLabelAce("|cffffd700" .. L["autoMarkTankExplanation"]:format(TANK, COMMUNITY_MEMBER_ROLE_NAME_LEADER, TANK) .. "|r", nil, nil, 14)
	labelExplanation:SetFullWidth(true)
	groupCore:AddChild(labelExplanation)

	local groupHealer = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupHealer)
	local data = {
		{
			text = L["mythicPlusNoHealerMark"],
			var = "mythicPlusNoHealerMark",
			func = function(self, _, value)
				addon.db["mythicPlusNoHealerMark"] = value
				checkCondition()
			end,
		},
	}

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupHealer:AddChild(cbElement)
	end
end

local function addObjectiveTrackerFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["mythicPlusEnableObjectiveTracker"],
			var = "mythicPlusEnableObjectiveTracker",
			func = function(self, _, value)
				addon.db["mythicPlusEnableObjectiveTracker"] = value
				container:ReleaseChildren()
				addObjectiveTrackerFrame(container)
				addon.MythicPlus.functions.setObjectiveFrames()
			end,
			desc = L["mythicPlusEnableObjectiveTrackerDesc"],
		},
	}
	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, cbData.desc)
		groupCore:AddChild(cbElement)
	end
	if addon.db["mythicPlusEnableObjectiveTracker"] then
		local list, order = addon.functions.prepareListForDropdown({ [1] = L["HideTracker"], [2] = L["collapse"] })

		local dropHideCollapseTracker = addon.functions.createDropdownAce(L["mythicPlusObjectiveTrackerSetting"], list, order, function(self, _, value)
			addon.db["mythicPlusObjectiveTrackerSetting"] = value
			addon.MythicPlus.functions.setObjectiveFrames()
		end)
		if addon.db["mythicPlusObjectiveTrackerSetting"] then dropHideCollapseTracker:SetValue(addon.db["mythicPlusObjectiveTrackerSetting"]) end

		groupCore:AddChild(dropHideCollapseTracker)
	end
end

local function addGroupFilterFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["mythicPlusEnableDungeonFilter"],
			var = "mythicPlusEnableDungeonFilter",
			func = function(self, _, value)
				addon.db["mythicPlusEnableDungeonFilter"] = value
				if value then
					addon.MythicPlus.functions.addDungeonFilter()
				else
					addon.MythicPlus.functions.removeDungeonFilter()
				end
				container:ReleaseChildren()
				addGroupFilterFrame(container)
			end,
		},
	}
	if addon.db["mythicPlusEnableDungeonFilter"] then
		table.insert(data, {
			text = L["mythicPlusEnableDungeonFilterClearReset"],
			var = "mythicPlusEnableDungeonFilterClearReset",
			func = function(self, _, value) addon.db["mythicPlusEnableDungeonFilterClearReset"] = value end,
		})
	end

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupCore:AddChild(cbElement)
	end
end

local function addRatingFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["groupfinderShowDungeonScoreFrame"]:format(DUNGEON_SCORE),
			var = "groupfinderShowDungeonScoreFrame",
			func = function(self, _, value)
				addon.db["groupfinderShowDungeonScoreFrame"] = value
				addon.MythicPlus.functions.toggleFrame()
			end,
		},
	}

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupCore:AddChild(cbElement)
	end
end

local activeTalentContainer
local function addTalentFrame(container)
	activeTalentContainer = container

	addon.MythicPlus.functions.getAllLoadouts()

	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["talentReminderEnabled"],
			var = "talentReminderEnabled",
			func = function(self, _, value)
				addon.db["talentReminderEnabled"] = value
				container:ReleaseChildren()
				addTalentFrame(container)
				addon.MythicPlus.functions.checkLoadout()
			end,
			desc = L["talentReminderEnabledDesc"]:format(PLAYER_DIFFICULTY6, PLAYER_DIFFICULTY_MYTHIC_PLUS),
		},
	}

	if addon.db["talentReminderEnabled"] then
		table.insert(data, {
			text = L["talentReminderLoadOnReadyCheck"]:format(READY_CHECK),
			var = "talentReminderLoadOnReadyCheck",
			func = function(self, _, value)
				addon.db["talentReminderLoadOnReadyCheck"] = value
				addon.MythicPlus.functions.checkLoadout()
			end,
		})
		table.insert(data, {
			text = L["talentReminderSoundOnDifference"],
			var = "talentReminderSoundOnDifference",
			func = function(self, _, value)
				addon.db["talentReminderSoundOnDifference"] = value
				addon.MythicPlus.functions.checkLoadout()
			end,
		})
	end

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc, desc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["talentReminderEnabled"] then
		local groupTalent = addon.functions.createContainer("TabGroup", "Flow")

		groupTalent:SetFullWidth(true) -- Nimmt die volle Breite des Parents

		groupTalent:SetTabs(addon.MythicPlus.variables.specNames)
		groupTalent:SetCallback("OnGroupSelected", function(tabContainer, event, group)
			tabContainer:ReleaseChildren()
			if not addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID] then addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID] = {} end
			if not addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][group] then addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][group] = {} end

			for _, cbData in pairs(addon.MythicPlus.variables.seasonMapInfo) do
				local list, order = addon.functions.prepareListForDropdown(addon.MythicPlus.variables.knownLoadout[group])

				local dropPullTimerType = addon.functions.createDropdownAce(cbData.name, list, order, function(self, _, value)
					addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][group][cbData.id] = value
					C_Timer.After(1, function() addon.MythicPlus.functions.checkLoadout() end)
				end)
				if dropPullTimerType.label and dropPullTimerType.label.SetFont then dropPullTimerType.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
				if addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][group][cbData.id] then
					dropPullTimerType:SetValue(addon.db["talentReminderSettings"][addon.variables.unitPlayerGUID][group][cbData.id])
				else
					dropPullTimerType:SetValue(0)
				end
				dropPullTimerType:SetFullWidth(false)
				dropPullTimerType:SetWidth(200)
				tabContainer:AddChild(dropPullTimerType)
				local spacer = addon.AceGUI:Create("Label")
				spacer:SetWidth(20) -- 20 Pixel Freiraum
				spacer:SetText("") -- Leer
				tabContainer:AddChild(spacer)
			end
			C_Timer.After(0.1, function()
				scroll:DoLayout()
				wrapper:DoLayout()
			end)
		end)
		if addon.MythicPlus.variables.currentSpecID and addon.MythicPlus.variables.knownLoadout[addon.MythicPlus.variables.currentSpecID] then
			groupTalent:SelectTab(addon.MythicPlus.variables.currentSpecID)
		else
			groupTalent:SelectTab(addon.MythicPlus.variables.specNames[1].value)
		end

		wrapper:AddChild(groupTalent)

		if TalentLoadoutEx then
			local groupInfo = addon.functions.createContainer("InlineGroup", "List")
			groupInfo:SetTitle(INFO)
			wrapper:AddChild(groupInfo)

			local labelHeadlineExplain = addon.functions.createLabelAce("|cffffd700" .. L["labelExplainedlineTLE"] .. "|r", nil, nil, 14)
			groupInfo:AddChild(labelHeadlineExplain)
			labelHeadlineExplain:SetFullWidth(true)
			groupInfo:AddChild(addon.functions.createSpacerAce())

			local btnToggleAnchor = addon.functions.createButtonAce(L["ReloadLoadouts"], 220, function(self)
				addon.MythicPlus.functions.getAllLoadouts()
				addon.MythicPlus.functions.checkRemovedLoadout()
				addon.MythicPlus.functions.refreshTalentFrameIfOpen()
			end)
			local fs = btnToggleAnchor.frame:GetFontString()
			btnToggleAnchor:SetWidth(fs:GetStringWidth() + 50)
			groupInfo:AddChild(btnToggleAnchor)
		end
	end
end
function addon.MythicPlus.functions.refreshTalentFrameIfOpen()
	if activeTalentContainer and addon.variables.statusTable.selected == "mythicplus\001talents" then
		activeTalentContainer:ReleaseChildren()
		addTalentFrame(activeTalentContainer)
	end
end

addon.variables.statusTable.groups["mythicplus"] = true
addon.functions.addToTree(nil, {
	value = "mythicplus",
	text = L["Mythic Plus"],
	children = {
		{ value = "keystone", text = L["Keystone"] },
		{ value = "automark", text = L["AutoMark"] },
		{ value = "potiontracker", text = L["Potion Tracker"] },
		{ value = "teleports", text = L["Teleports"] },
		{ value = "brtracker", text = L["BRTracker"] },
		{ value = "rating", text = DUNGEON_SCORE },
		{ value = "talents", text = L["TalentReminder"] },
		{ value = "objectivetracker", text = HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL },
		{ value = "groupfilter", text = L["groupFilter"] },
	},
})

function addon.MythicPlus.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	-- Prüfen, welche Gruppe ausgewählt wurde
	if group == "mythicplus\001keystone" then
		addKeystoneFrame(container)
	elseif group == "mythicplus\001potiontracker" then
		addPotionTrackerFrame(container)
	elseif group == "mythicplus\001automark" then
		addAutoMarkFrame(container)
	elseif group == "mythicplus\001teleports" then
		addTeleportFrame(container)
	elseif group == "mythicplus\001brtracker" then
		addBRFrame(container)
	elseif group == "mythicplus\001rating" then
		addRatingFrame(container)
	elseif group == "mythicplus\001talents" then
		addTalentFrame(container)
	elseif group == "mythicplus\001groupfilter" then
		addGroupFilterFrame(container)
	elseif group == "mythicplus\001objectivetracker" then
		addObjectiveTrackerFrame(container)
	end
end

if addon.db["mythicPlusEnableDungeonFilter"] then addon.MythicPlus.functions.addDungeonFilter() end
