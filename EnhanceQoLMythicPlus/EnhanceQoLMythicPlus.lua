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
frameLoad:RegisterEvent("READY_CHECK_FINISHED")

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- loadMain()
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        checkKeyStone()
    elseif event == "READY_CHECK_FINISHED" and ChallengesKeystoneFrame and addon.MythicPlus.Buttons["ReadyCheck"] then
        addon.MythicPlus.Buttons["ReadyCheck"]:SetText(L["ReadyCheck"])
    end
end

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Mythic Plus"])

local header = addon.functions.createHeader(frame, L[addonName], 0, -10)
local cbKeyInsert = addon.functions.createCheckbox("autoInsertKeystone", frame, L["Automatically insert keystone"], 10,
    (addon.functions.getHeightOffset(header) - 10))

local cbCloseBags = addon.functions.createCheckbox("closeBagsOnKeyInsert", frame,
    L["Close all bags on keystone insert"], 10, (addon.functions.getHeightOffset(cbKeyInsert) - 10))

local cbCancelOnPullTimer = addon.functions.createCheckbox("cancelPullTimerOnClick", frame,
    L["Cancel Pull Timer on click"], 10, (addon.functions.getHeightOffset(cbCloseBags) - 5))

local cbNoChatOnPullTimer = addon.functions.createCheckbox("noChatOnPullTimer", frame, L["noChatOnPullTimer"], 10,
    (addon.functions.getHeightOffset(cbCancelOnPullTimer) - 5))

local cbAutoKeyStart = addon.functions.createCheckbox("autoKeyStart", frame, L["autoKeyStart"], 10,
    (addon.functions.getHeightOffset(cbNoChatOnPullTimer) - 5))

local labelPullTimerType = addon.functions.createDropdown("PullTimerType", frame, {{
    text = L["None"],
    value = 1
},{
    text = L["Blizzard Pull Timer"],
    value = 2
}, {
    text = L["DBM / BigWigs Pull Timer"],
    value = 3
}, {
    text = L["Both"],
    value = 4
}}, 150, L["Pull Timer Type"], 10, addon.functions.getHeightOffset(cbAutoKeyStart) - 10, addon.db["PullTimerType"])

local longSlider = addon.functions.createSlider("pullTimerLongTime", frame, L["sliderLongTime"], 15,
    (addon.functions.getHeightOffset(labelPullTimerType) - 60), addon.db["pullTimerLongTime"], 1, 60, "s")

local shortSlider = addon.functions.createSlider("pullTimerShortTime", frame, L["sliderShortTime"], 15,
    (addon.functions.getHeightOffset(longSlider) - 25), addon.db["pullTimerShortTime"], 1, 60, "s")

