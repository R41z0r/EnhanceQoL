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

addon.MythicPlus = {}
addon.LMythicPlus = {} -- Locales for MythicPlus
addon.MythicPlus.functions = {}

addon.MythicPlus.Buttons = {}
addon.MythicPlus.nrOfButtons = 0
addon.MythicPlus.variables = {}

-- PullTimer
addon.MythicPlus.variables.handled = false
addon.MythicPlus.variables.breakIt = false

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
