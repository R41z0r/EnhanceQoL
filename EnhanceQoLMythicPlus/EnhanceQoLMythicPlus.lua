local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

local frameLoad = CreateFrame("Frame")

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
                    addon.MythicPlus.functions.addButton(ChallengesKeystoneFrame, "ReadyCheck", L["ReadyCheck"],
                        function(self, button)
                            if self:GetText() == L["ReadyCheck"] then
                                DoReadyCheck()
                                self:SetText(L["ReadyCheckWaiting"])
                            end
                        end)
                    -- Button for Pulltimer
                    addon.MythicPlus.functions.addButton(ChallengesKeystoneFrame, "PullTimer", L["PullTimer"],
                        function(self, button)
                            if addon.MythicPlus.variables.handled == false then
                                addon.MythicPlus.Buttons["PullTimer"]:SetText(L["Stating"])
                                addon.MythicPlus.variables.breakIt = false
                                addon.MythicPlus.variables.handled = true
                                local x = nil
                                -- Set time based on settings choosen
                                if button == 'RightButton' then
                                    x = addon.db["pullTimerShortTime"]
                                else
                                    x = addon.db["pullTimerLongTime"]
                                end
                                local cTime = x

                                C_Timer.NewTicker(1, function(self)
                                    if addon.MythicPlus.variables.breakIt then
                                        self:Cancel()
                                        C_PartyInfo.DoCountdown(0)
                                        if addon.db["noChatOnPullTimer"] == false then
                                            SendChatMessage("PULL Canceled", "Party")
                                        end
                                        C_ChatInfo.SendAddonMessage("D4", ("PT\t%s\t%d"):format(0, instanceId),
                                            IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
                                    end

                                    if x == 0 then
                                        self:Cancel()
                                        addon.MythicPlus.variables.handled = false
                                        if addon.db["noChatOnPullTimer"] == false then
                                            SendChatMessage(">>PULL NOW<<", "Party")
                                        end
                                        if addon.db["autoKeyStart"] == false then
                                            addon.MythicPlus.Buttons["PullTimer"]:SetText(L["PullTimer"])
                                        elseif addon.db["autoKeyStart"] and nil ~=
                                            C_ChallengeMode.GetSlottedKeystoneInfo() then
                                            C_ChallengeMode.StartChallengeMode()
                                            ChallengesKeystoneFrame:Hide()
                                        end
                                    else
                                        if x == cTime then
                                            local _, _, _, _, _, _, _, id = GetInstanceInfo()
                                            local instanceId = tonumber(id) or 0
                                            if addon.db["PullTimerType"] == 2 or addon.db["PullTimerType"] == 4 then
                                                C_PartyInfo.DoCountdown(cTime)
                                            end
                                            if addon.db["PullTimerType"] == 3 or addon.db["PullTimerType"] == 4 then
                                                C_ChatInfo.SendAddonMessage("D4",
                                                    ("PT\t%s\t%d"):format(cTime, instanceId), IsInGroup(2) and
                                                        "INSTANCE_CHAT" or "RAID")
                                            end
                                        end
                                        if addon.MythicPlus.variables.breakIt == false then
                                            if addon.db["cancelPullTimerOnClick"] == true then
                                                addon.MythicPlus.Buttons["PullTimer"]:SetText(
                                                    addon.LMythicPlus["Cancel"] .. " (" .. x .. ")")
                                            else
                                                addon.MythicPlus.Buttons["PullTimer"]:SetText(
                                                    addon.LMythicPlus["Pull"] .. " (" .. x .. ")")
                                            end
                                        end
                                        if addon.MythicPlus.variables.breakIt == false then
                                            if addon.db["noChatOnPullTimer"] == false then
                                                SendChatMessage(format(("PULL in %ds"), x), "Party")
                                            end
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
                        if addon.db["closeBagsOnKeyInsert"] and addon.db["closeBagsOnKeyInsert"] == true then
                            CloseAllBags()
                        end
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

local function skipRolecheck()
    local tank, healer, dps = false, false, false
    local role = UnitGroupRolesAssigned("player")
    if role == "NONE" then
        role = GetSpecializationRole(GetSpecialization());
    end
    if role == "TANK" then
        tank = true;
    elseif role == "DAMAGER" then
        dps = true;
    elseif role == "HEALER" then
        healer = true;
    end
    if LFDRoleCheckPopupRoleButtonTank.checkButton:IsEnabled() then
        LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(tank);
    end
    if LFDRoleCheckPopupRoleButtonHealer.checkButton:IsEnabled() then
        LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(healer);
    end
    if LFDRoleCheckPopupRoleButtonDPS.checkButton:IsEnabled() then
        LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(dps);
    end
    LFDRoleCheckPopupAcceptButton:Enable();
    LFDRoleCheckPopupAcceptButton:Click();
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

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- loadMain()
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        checkKeyStone()
    elseif event == "READY_CHECK_FINISHED" and ChallengesKeystoneFrame and addon.MythicPlus.Buttons["ReadyCheck"] then
        addon.MythicPlus.Buttons["ReadyCheck"]:SetText(L["ReadyCheck"])
    elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" and addon.db["groupfinderAppText"] then
        toggleGroupApplication(true)
    elseif event == "LFG_ROLE_CHECK_SHOW" and addon.db["groupfinderSkipRolecheck"] and UnitInParty("player") then
        skipRolecheck()
    end
end

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

-- Extend the option menu
-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Mythic Plus"])
frame.tabs = {}
frame:SetScript("OnSizeChanged", function(self, width, height)
    for i, tab in ipairs(frame.tabs) do
        tab:SetSize(width - 5, height - 35)
    end
end)
function frame:ShowTab(id)
    for _, tabContent in pairs(self.tabs) do
        tabContent:Hide()
    end
    if self.tabs[id] then
        self.tabs[id]:Show()
    end
end

local function hideElements(elements, value)
    for _, element in pairs(elements) do
        if value then
            element:Show()
        else
            element:Hide()
        end
    end
end

local tabFrameDungeonBrowser = addon.MythicPlus.functions.createTabFrame(L["DungeonBrowser"], frame)
local cbGroupFinderAppText = addon.functions.createCheckbox("groupfinderAppText", tabFrameDungeonBrowser,
    L["groupfinderAppText"], 10, -10)
cbGroupFinderAppText:SetScript("OnClick", function(self)
    addon.db["groupfinderAppText"] = self:GetChecked()
    toggleGroupApplication(self:GetChecked())
end)

local cbGroupFinderSkipRolecheck = addon.functions.createCheckbox("groupfinderSkipRolecheck", tabFrameDungeonBrowser,
    L["groupfinderSkipRolecheck"], 10, (addon.functions.getHeightOffset(cbGroupFinderAppText) - 10))

-- Tab Keystone
local tabFrameKeystone = addon.MythicPlus.functions.createTabFrame(L["Keystone"], frame)

-- local header = addon.functions.createHeader(frame, L[addonName], 0, -10)
local cbKeyInsert = addon.functions.createCheckbox("autoInsertKeystone", tabFrameKeystone,
    L["Automatically insert keystone"], 10, -10)

local cbCloseBags = addon.functions.createCheckbox("closeBagsOnKeyInsert", tabFrameKeystone,
    L["Close all bags on keystone insert"], 10, (addon.functions.getHeightOffset(cbKeyInsert) - 10))

local cbCancelOnPullTimer = addon.functions.createCheckbox("cancelPullTimerOnClick", tabFrameKeystone,
    L["Cancel Pull Timer on click"], 10, (addon.functions.getHeightOffset(cbCloseBags) - 5))

local cbNoChatOnPullTimer = addon.functions.createCheckbox("noChatOnPullTimer", tabFrameKeystone,
    L["noChatOnPullTimer"], 10, (addon.functions.getHeightOffset(cbCancelOnPullTimer) - 5))

local cbAutoKeyStart = addon.functions.createCheckbox("autoKeyStart", tabFrameKeystone, L["autoKeyStart"], 10,
    (addon.functions.getHeightOffset(cbNoChatOnPullTimer) - 5))

local labelPullTimerType = addon.functions.createDropdown("PullTimerType", tabFrameKeystone, {{
    text = L["None"],
    value = 1
}, {
    text = L["Blizzard Pull Timer"],
    value = 2
}, {
    text = L["DBM / BigWigs Pull Timer"],
    value = 3
}, {
    text = L["Both"],
    value = 4
}}, 150, L["Pull Timer Type"], 10, addon.functions.getHeightOffset(cbAutoKeyStart) - 10, addon.db["PullTimerType"])

local longSlider = addon.functions.createSlider("pullTimerLongTime", tabFrameKeystone, L["sliderLongTime"], 15,
    (addon.functions.getHeightOffset(labelPullTimerType) - 60), addon.db["pullTimerLongTime"], 1, 60, "s")

local shortSlider = addon.functions.createSlider("pullTimerShortTime", tabFrameKeystone, L["sliderShortTime"], 15,
    (addon.functions.getHeightOffset(longSlider) - 25), addon.db["pullTimerShortTime"], 1, 60, "s")

-- Potion Tracker
local hideListPotion = {}
local tabFramePotionCooldown = addon.MythicPlus.functions.createTabFrame(L["Potion Tracker"], frame)

local labelPotionTracker = addon.functions.createLabel(tabFramePotionCooldown, L["potionTrackerHeadline"], 0, -10,
    "TOP", "TOP")

local cbPotionTrackerEnabled = addon.functions.createCheckbox("potionTracker", tabFramePotionCooldown,
    L["potionTracker"], 10, (addon.functions.getHeightOffset(labelPotionTracker) - 10))
cbPotionTrackerEnabled:SetScript("OnClick", function(self)
    hideElements(hideListPotion, self:GetChecked())
    addon.db["potionTracker"] = self:GetChecked()
    if self:GetChecked() == false then
        addon.MythicPlus.functions.resetCooldownBars()
    end
end)
local btnToggleAnchor = addon.functions.createButton(tabFramePotionCooldown, 10,
    (addon.functions.getHeightOffset(cbPotionTrackerEnabled) - 10), 140, 25, L["Toggle Anchor"], function(self)
        if addon.MythicPlus.anchorFrame:IsShown() then
            addon.MythicPlus.anchorFrame:Hide()
            self:SetText(L["Toggle Anchor"])
        else
            self:SetText(L["Save Anchor"])
            addon.MythicPlus.anchorFrame:Show()
        end
    end)
table.insert(hideListPotion, btnToggleAnchor)

local cbPotionTrackerUpwards = addon.functions.createCheckbox("potionTrackerUpwardsBar", tabFramePotionCooldown,
    L["potionTrackerUpwardsBar"], 10, (addon.functions.getHeightOffset(btnToggleAnchor) - 10))
cbPotionTrackerUpwards:SetScript("OnClick", function(self)
    addon.db["potionTrackerUpwardsBar"] = self:GetChecked()
    addon.MythicPlus.functions.updateBars()
end)
table.insert(hideListPotion, cbPotionTrackerUpwards)

local cbPotionTrackerClassColors = addon.functions.createCheckbox("potionTrackerClassColor", tabFramePotionCooldown,
    L["potionTrackerClassColor"], 10, (addon.functions.getHeightOffset(cbPotionTrackerUpwards) - 10))
cbPotionTrackerClassColors:SetScript("OnClick", function(self)
    addon.db["potionTrackerClassColor"] = self:GetChecked()
end)
table.insert(hideListPotion, cbPotionTrackerClassColors)

local cbPotionTrackerDisableRaid = addon.functions.createCheckbox("potionTrackerDisableRaid", tabFramePotionCooldown,
    L["potionTrackerDisableRaid"], 10, (addon.functions.getHeightOffset(cbPotionTrackerClassColors) - 10))
cbPotionTrackerDisableRaid:SetScript("OnClick", function(self)
    addon.db["potionTrackerDisableRaid"] = self:GetChecked()
end)
cbPotionTrackerDisableRaid:SetScript("OnClick", function(self)
    addon.db["potionTrackerDisableRaid"] = self:GetChecked()
    if self:GetChecked() == true and UnitInRaid("player") then
        addon.MythicPlus.functions.resetCooldownBars()
    end
end)

table.insert(hideListPotion, cbPotionTrackerDisableRaid)

local cbPotionTrackerShowTooltip = addon.functions.createCheckbox("potionTrackerShowTooltip", tabFramePotionCooldown,
    L["potionTrackerShowTooltip"], 10, (addon.functions.getHeightOffset(cbPotionTrackerDisableRaid) - 10))

table.insert(hideListPotion, cbPotionTrackerShowTooltip)

local cbPotionTrackerShowHealpot = addon.functions.createCheckbox("potionTrackerHealingPotions", tabFramePotionCooldown,
    L["potionTrackerHealingPotions"], 10, (addon.functions.getHeightOffset(cbPotionTrackerShowTooltip) - 10))

table.insert(hideListPotion, cbPotionTrackerShowHealpot)

-- Bigger frame for all Options
addon.frame:SetSize(500, 550)

hideElements(hideListPotion, addon.db["potionTracker"])

