local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

-- Addition für Potion Cooldown tracker?
local allowedSpells = {
    [428332] = 30,
    [2484] = 30,
    [8004] = 10,
    [431949] = 300, -- Parasol
    [10060] = 120, -- Power Infusion
    [586] = 20,
    [371028] = 300, -- Elemental potion of ultimate power
    [371024] = 300 -- Elemental potion of power
}

local activeBars = {}
local frameAnchor = CreateFrame("StatusBar", nil, UIParent)
addon.MythicPlus.anchorFrame = frameAnchor

local function resetCooldownBars()
    -- Entferne alle aktiven Cooldown-Balken
    for i, bar in ipairs(activeBars) do
        bar:Hide()
    end
    activeBars = {}
    print("Cooldowns wurden zurückgesetzt.")
end

local function updateBars()
    local yOffset = 0
    local newActiveBars = {}

    for _, bar in ipairs(activeBars) do
        if bar:IsShown() then
            -- Neupositionierung des Balkens
            bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, -yOffset)
            yOffset = yOffset + bar:GetHeight() + 1 -- 5px Abstand
            table.insert(newActiveBars, bar)
        else
            -- Entferne den unsichtbaren Balken
            bar:Hide()
            bar:SetScript("OnUpdate", nil)
        end
    end

    activeBars = newActiveBars
end

local function createCooldownBar(spellID, duration, anchorFrame, playerName)
    local frame = CreateFrame("StatusBar", nil, UIParent, "BackdropTemplate")
    frame:SetSize(anchorFrame:GetWidth() - addon.db["CooldownTrackerBarHeight"], addon.db["CooldownTrackerBarHeight"]) -- Größe des Balkens
    frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame:SetMinMaxValues(0, duration)
    frame:SetValue(0)
    frame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
    -- Hintergrund (leicht schwarzer Rahmen)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 3,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz

    -- Zaubername und Restzeit anzeigen
    local spellName, _, spellIcon = GetSpellInfo(spellID)
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.text:SetPoint("LEFT", frame, "LEFT", 3, 0)
    frame.text:SetText(playerName)

    frame.time = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.time:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

    -- Spell-Icon hinzufügen
    frame.icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon:SetSize(addon.db["CooldownTrackerBarHeight"], addon.db["CooldownTrackerBarHeight"]) -- Größe des Icons
    frame.icon:SetPoint("LEFT", frame, "RIGHT", 0, 0) -- Position am rechten Ende des Balkens
    frame.icon:SetTexture(spellIcon) -- Setzt das Icon des Spells
    

    -- Timer Update
    frame.timeElapsed = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.timeElapsed = self.timeElapsed + elapsed
        if self.timeElapsed < duration then
            local timeLeft = duration - self.timeElapsed
            local timeText

            if timeLeft > 60 then
                local minutes = math.floor(timeLeft / 60)
                local seconds = math.floor(timeLeft % 60)
                timeText = string.format("%d:%02d", minutes, seconds) .. "m"
            elseif timeLeft < 10 then
                timeText = string.format("%.1f", timeLeft) .. "s" -- Anzeige mit einer Nachkommastelle
            else
                timeText = string.format("%.0f", timeLeft) .. "s"
            end

            self:SetValue(timeLeft)
            self.text:SetText(playerName)
            self.time:SetText(timeText)
        else
            self:SetScript("OnUpdate", nil)
            self:Hide()
            updateBars()
        end
    end)

    return frame
end

-- Main
frameAnchor:SetSize(200, 30) -- Größe des Balkens
frameAnchor:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
frameAnchor:SetStatusBarColor(0, 0.65, 0) -- Green color
frameAnchor:SetMinMaxValues(0, 10)
frameAnchor:SetValue(10)
frameAnchor:ClearAllPoints()
frameAnchor:SetMovable(true)
frameAnchor:EnableMouse(true)
frameAnchor:RegisterForDrag("LeftButton")
frameAnchor.text = frameAnchor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frameAnchor.text:SetPoint("CENTER", frameAnchor, "CENTER")
frameAnchor.text:SetText("Drag me to position Cooldownbars")

frameAnchor:SetScript("OnDragStart", frameAnchor.StartMoving)
frameAnchor:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Position speichern
    local point, _, _, xOfs, yOfs = self:GetPoint()
    addon.db["CooldownTrackerPoint"] = point
    addon.db["CooldownTrackerX"] = xOfs
    addon.db["CooldownTrackerY"] = yOfs
end)
-- Frame-Position wiederherstellen
local function RestorePosition()
    if addon.db["CooldownTrackerPoint"] and addon.db["CooldownTrackerX"] and addon.db["CooldownTrackerY"] then
        frameAnchor:ClearAllPoints()
        frameAnchor:SetPoint(addon.db["CooldownTrackerPoint"], UIParent, addon.db["CooldownTrackerPoint"],
            addon.db["CooldownTrackerX"], addon.db["CooldownTrackerY"])
    end
end

-- Frame wiederherstellen und überprüfen, wenn das Addon geladen wird
frameAnchor:SetScript("OnShow", function()
    RestorePosition()
end)
RestorePosition()

frameAnchor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frameAnchor:RegisterEvent("CHALLENGE_MODE_RESET")
frameAnchor:RegisterEvent("ADDON_LOADED")

local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if event == "UNIT_SPELLCAST_SUCCEEDED" and (arg1 == "player" or (UnitInParty(arg1) or UnitInRaid(arg1))) and
        allowedSpells[arg3] then
        -- Finde die Position des neuen Balkens
        local yOffset = 0
        for _, bar in pairs(activeBars) do
            if bar:IsVisible() then
                yOffset = yOffset + bar:GetHeight() + 5 -- 5px Abstand
            end
        end
        -- Erstelle und positioniere den neuen Balken
        local bar = createCooldownBar(arg3, allowedSpells[arg3], frameAnchor, select(1, UnitName(arg1)))
        bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, -yOffset)
        bar:Show()
        print(bar, yOffset)
        -- Füge den Balken zur aktiven Liste hinzu
        table.insert(activeBars, bar)
    elseif event == "CHALLENGE_MODE_RESET" then
        resetCooldownBars()
    end
end

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)
frameAnchor:Hide()