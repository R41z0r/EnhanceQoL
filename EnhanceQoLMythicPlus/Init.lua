local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

if nil == addon.db["autoInsertKeystone"] then
    addon.db["autoInsertKeystone"] = false
end
if nil == addon.db["closeBagsOnKeyInsert"] then
    addon.db["closeBagsOnKeyInsert"] = false
end
if nil == addon.db["noChatOnPullTimer"] then
    addon.db["noChatOnPullTimer"] = false
end
if nil == addon.db["autoKeyStart"] then
    addon.db["autoKeyStart"] = false
end
if nil == addon.db["cancelPullTimerOnClick"] then
    addon.db["cancelPullTimerOnClick"] = true
end
if nil == addon.db["pullTimerShortTime"] then
    addon.db["pullTimerShortTime"] = 5
end
if nil == addon.db["pullTimerLongTime"] then
    addon.db["pullTimerLongTime"] = 10
end
if nil == addon.db["PullTimerType"] or addon.db["PullTimerType"] == 0 then
    addon.db["PullTimerType"] = 4
end
if nil == addon.db["PullTimerType"] or addon.db["PullTimerType"] == 0 then
    addon.db["PullTimerType"] = 4
end

-- Cooldown Tracker
if nil == addon.db["CooldownTrackerPoint"] then
    addon.db["CooldownTrackerPoint"] = "CENTER"
end
if nil == addon.db["CooldownTrackerX"] then
    addon.db["CooldownTrackerX"] = 0
end
if nil == addon.db["CooldownTrackerY"] then
    addon.db["CooldownTrackerY"] = 0
end

if nil == addon.db["CooldownTrackerBarHeight"] then
    addon.db["CooldownTrackerBarHeight"] = 30
end

if nil == addon.db["potionTracker"] then
    addon.db["potionTracker"] = false
end

if nil == addon.db["potionTrackerUpwardsBar"] then
    addon.db["potionTrackerUpwardsBar"] = false
end
if nil == addon.db["potionTrackerDisableRaid"] then
    addon.db["potionTrackerDisableRaid"] = true
end
if nil == addon.db["potionTrackerShowTooltip"] then
    addon.db["potionTrackerShowTooltip"] = true
end
if nil == addon.db["potionTrackerHealingPotions"] then
    addon.db["potionTrackerHealingPotions"] = false
end

-- Dungeon Browser
if nil == addon.db["groupfinderAppText"] then
    addon.db["groupfinderAppText"] = true
end
if nil == addon.db["groupfinderSkipRolecheck"] then
    addon.db["groupfinderSkipRolecheck"] = true
end

addon.MythicPlus = {}
addon.LMythicPlus = {} -- Locales for MythicPlus
addon.MythicPlus.functions = {}

addon.MythicPlus.Buttons = {}
addon.MythicPlus.nrOfButtons = 0
addon.MythicPlus.variables = {}
addon.MythicPlus.variables.numOfTabs = 0

-- PullTimer
addon.MythicPlus.variables.handled = false
addon.MythicPlus.variables.breakIt = false

addon.MythicPlus.variables.resetCooldownEncounterDifficult = {
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [9] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [33] = true,
    [151] = true
}

function addon.MythicPlus.functions.addButton(frame, name, text, call)
    local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    button:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, (addon.MythicPlus.nrOfButtons * -40))
    button:SetSize(140, 40)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormalLarge")
    button:SetHighlightFontObject("GameFontHighlightLarge")
    button:RegisterForClicks("RightButtonDown", "LeftButtonDown")
    button:SetScript("OnClick", call)
    if UnitIsGroupLeader("Player") == false then
        button:Hide()
    end
    addon.MythicPlus.Buttons[name] = button
    addon.MythicPlus.nrOfButtons = addon.MythicPlus.nrOfButtons + 1
end

function addon.MythicPlus.functions.removeExistingButton()

    for _, button in pairs(addon.MythicPlus.Buttons) do
        if button then
            button:Hide() -- Versteckt den Button
            button:SetParent(nil) -- Entfernt den Parent-Frame

            -- Entferne alle registrierten Event-Handler und Scripte
            button:SetScript("OnClick", nil)
            button:SetScript("OnEnter", nil)
            button:SetScript("OnLeave", nil)
            button:SetScript("OnUpdate", nil)
            button:SetScript("OnEvent", nil)

            -- Entferne alle Texturen und andere Frames
            button:UnregisterAllEvents()
            button:ClearAllPoints()
        end
    end
    addon.MythicPlus.Buttons = {}
    addon.MythicPlus.nrOfButtons = 0
end

function addon.MythicPlus.functions.createTabFrame(text, frame)
    addon.MythicPlus.variables.numOfTabs = addon.MythicPlus.variables.numOfTabs + 1
    local tab1 = addon.functions.createTabButton(frame, addon.MythicPlus.variables.numOfTabs, text)
    tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

    PanelTemplates_SetNumTabs(frame, addon.MythicPlus.variables.numOfTabs)
    PanelTemplates_SetTab(frame, 1)

    frame.tabs[addon.MythicPlus.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.tabs[addon.MythicPlus.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
    frame.tabs[addon.MythicPlus.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -2 - (tab1:GetHeight()))

    if addon.MythicPlus.variables.numOfTabs == 1 then
        frame.tabs[addon.MythicPlus.variables.numOfTabs]:Show()
    else
        frame.tabs[addon.MythicPlus.variables.numOfTabs]:Hide()
    end
    return frame.tabs[addon.MythicPlus.variables.numOfTabs]
end
