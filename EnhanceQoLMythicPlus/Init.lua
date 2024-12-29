local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

-- PullTimer
addon.functions.InitDBValue("autoInsertKeystone", false)
addon.functions.InitDBValue("closeBagsOnKeyInsert", false)
addon.functions.InitDBValue("noChatOnPullTimer", false)
addon.functions.InitDBValue("autoKeyStart", false)
addon.functions.InitDBValue("cancelPullTimerOnClick", true)
addon.functions.InitDBValue("pullTimerShortTime", 5)
addon.functions.InitDBValue("pullTimerLongTime", 10)
addon.functions.InitDBValue("PullTimerType", 4)

-- Cooldown Tracker
addon.functions.InitDBValue("CooldownTrackerPoint", "CENTER")
addon.functions.InitDBValue("CooldownTrackerX", 0)
addon.functions.InitDBValue("CooldownTrackerY", 0)
addon.functions.InitDBValue("CooldownTrackerBarHeight", 30)

-- Potion Tracker
addon.functions.InitDBValue("potionTracker", false)
addon.functions.InitDBValue("potionTrackerUpwardsBar", false)
addon.functions.InitDBValue("potionTrackerDisableRaid", true)
addon.functions.InitDBValue("potionTrackerShowTooltip", true)
addon.functions.InitDBValue("potionTrackerHealingPotions", false)
addon.functions.InitDBValue("potionTrackerOffhealing", false)

-- Dungeon Browser
addon.functions.InitDBValue("groupfinderAppText", true)
addon.functions.InitDBValue("groupfinderSkipRolecheck", true)

-- Misc
addon.functions.InitDBValue("autoMarkTankInDungeon", false)
addon.functions.InitDBValue("autoMarkTankInDungeonMarker", 6)

addon.MythicPlus = {}
addon.LMythicPlus = {} -- Locales for MythicPlus
addon.MythicPlus.functions = {}

addon.MythicPlus.Buttons = {}
addon.MythicPlus.nrOfButtons = 0
addon.MythicPlus.variables = {}

-- Teleports
addon.functions.InitDBValue("teleportFrame", false)
addon.functions.InitDBValue("portalHideMissing", false)
addon.functions.InitDBValue("portalShowTooltip", false)
addon.functions.InitDBValue("teleportsEnableCompendium", false)

-- PullTimer
addon.MythicPlus.variables.handled = false
addon.MythicPlus.variables.breakIt = false

addon.MythicPlus.variables.resetCooldownEncounterDifficult =
    {[3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [9] = true, [14] = true, [15] = true, [16] = true,
     [17] = true, [18] = true, [33] = true, [151] = true, [208] = true -- delves
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
    if UnitIsGroupLeader("Player") == false then button:Hide() end
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
