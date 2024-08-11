local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

-- Addition für Potion Cooldown tracker
local allowedSpells = {
    -- Tinker Engineering
    [55004] = {
        duration = 60,
        isInvis = false,
        text = L["Tinker"]
    }, -- Nitro boost - Shares CD with combat potions but only 60s
    -- [255974] = 300, --Personal Space Amplifier - Shares CD with combat potions but only 60s --Wurde wohl rausgepatcht

    -- Dragonflight
    [371028] = {
        duration = 300,
        isInvis = false
    }, -- Elemental potion of ultimate power
    [371134] = {
        duration = 300,
        isInvis = true
    }, -- Potion of the Hushed Zephyr
    [371024] = {
        duration = 300,
        isInvis = false
    }, -- Elemental potion of power
    [371622] = {
        duration = 300,
        isInvis = false
    }, -- Residual Neural Channeling Agent
    [372046] = {
        duration = 300,
        isInvis = false
    }, -- Bottled Putrescence
    [371055] = {
        duration = 300,
        isInvis = false
    }, -- Delicate Suspension of Spores
    [371152] = {
        duration = 300,
        isInvis = false
    }, -- Potion of Chilled Clarity
    -- [371653] = 120, -- Potion of Frozen Fatality (Feign death out of combat)
    [371033] = {
        duration = 300,
        isInvis = false
    }, -- Potion of chilled focus
    [371167] = {
        duration = 300,
        isInvis = false
    }, -- Potion of Gusts
    [370816] = {
        duration = 300,
        isInvis = false
    }, -- Potion of Shocking disclosure
    [423414] = {
        duration = 300,
        isHealpot = true
    }, -- Potion of Withering Dreams
    [370607] = {
        duration = 300
    }, -- Aerated Mana Potion - Count as Combatpotion
    [415569] = {
        duration = 300,
        isHealpot = true
    }, -- Dreamwalker's Healing Potion
    [370511] = {
        duration = 300,
        isHealpot = true
    }, -- Refreshing Healing Potion

    -- Battle for Azeroth
    [279153] = {
        duration = 300,
        isInvis = false
    }, -- Battle Potion of Strength
    [279154] = {
        duration = 300,
        isInvis = false
    }, -- Battle Potion of Stamina
    [279151] = {
        duration = 300,
        isInvis = false
    }, -- Battle Potion of Int
    [279152] = {
        duration = 300,
        isInvis = false
    }, -- Battle Potion of Agi

    -- The War Within
    [431932] = {
        duration = 300,
        isInvis = false
    }, -- Tempered Potion
    [431422] = {
        duration = 300,
        isInvis = false
    }, -- Slumbering Soul Serum
    [431941] = {
        duration = 300,
        isInvis = false
    }, -- Potion of the Reborn Cheetah
    [431432] = {
        duration = 300,
        isInvis = false
    }, -- Draugth of Shocking Revelations
    [431925] = {
        duration = 300,
        isInvis = false
    }, -- Frontline Potion
    [453040] = {
        duration = 300,
        isInvis = false
    }, -- Potion Bomb of Speed
    [453162] = {
        duration = 300,
        isInvis = false
    }, -- Potion Bomb of Recobery
    [453205] = {
        duration = 300,
        isInvis = false
    }, -- Potion Bomb of Power
    [431914] = {
        duration = 300,
        isInvis = false
    }, -- Potion of Unwavering Focus
    [431424] = {
        duration = 600,
        isInvis = true
    }, -- Potion of Silent Footfalls
    [431419] = {
        duration = 600,
        isInvis = false
    }, -- Cavedweller's Delight Heal/Mana Pot counts as combat, -- Potion of Silent Footfalls
    [431418] = {
        duration = 600,
        isInvis = false
    }, -- Algari Mana Potion
    [431416] = {
        duration = 600,
        isInvis = false,
        isHealpot = true
    }, -- Algari Healing Potion
    [460074] = {
        duration = 600,
        isInvis = false,
        isHealpot = true
    } -- Grotesque Vial

    -- [279153] = 300, --
    -- [279153] = 300, --
    -- [279153] = 300, --

    -- [279153] = 300, --
}
local activeBars = {}
local frameAnchor = CreateFrame("StatusBar", nil, UIParent)
addon.MythicPlus.anchorFrame = frameAnchor

function addon.MythicPlus.functions.resetCooldownBars()
    -- Entferne alle aktiven Cooldown-Balken
    for i, bar in ipairs(activeBars) do
        bar:Hide()
    end
    activeBars = {}
end

function addon.MythicPlus.functions.updateBars()
    local yOffset = 0
    local newActiveBars = {}

    table.sort(activeBars, function(a, b)
        return a:GetValue() < b:GetValue()
    end)

    for _, bar in ipairs(activeBars) do
        if bar:IsShown() then
            -- Neupositionierung des Balkens
            if addon.db["potionTrackerUpwardsBar"] then
                bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, yOffset)
            else
                bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, -yOffset)
            end
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

local function createCooldownBar(spellID, anchorFrame, playerName, unit)
    local potInfo = allowedSpells[spellID]
    local duration = potInfo.duration

    if string.len(playerName) > 6 then
        playerName = string.sub(playerName, 1, 6)
    end

    local textLeft = playerName
    if potInfo.isInvis then
        textLeft = textLeft .. " - " .. L["InvisPotion"]
    end
    if potInfo.isHealpot then
        if addon.db["potionTrackerHealingPotions"] == false then
            return
        end
        textLeft = textLeft .. " - " .. L["HealingPotion"]
    end
    if potInfo.text then
        textLeft = textLeft .. " - " .. potInfo.text
    end

    local frame = CreateFrame("StatusBar", nil, UIParent, "BackdropTemplate")
    frame:SetSize(anchorFrame:GetWidth() - addon.db["CooldownTrackerBarHeight"], addon.db["CooldownTrackerBarHeight"]) -- Größe des Balkens
    frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame:SetMinMaxValues(0, duration)
    frame:SetValue(duration)
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
    if addon.db["potionTrackerClassColor"] then
        local rPerc, gPerc, bPerc = GetClassColor(select(2, UnitClass(unit)))
        frame:SetStatusBarColor(rPerc, gPerc, bPerc)
    end
    frame:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
    local spellName, _, spellIcon
    if potInfo.isInvis then
        spellIcon = 136153 -- Invis icon
    elseif potInfo.isHealpot then
        spellIcon = 134756
    else
        -- Zaubername und Restzeit anzeigen
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            spellIcon = spellInfo.iconID
        else
            spellName, _, spellIcon = GetSpellInfo(spellID)
        end
    end
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.text:SetPoint("LEFT", frame, "LEFT", 3, 0)
    frame.text:SetText(textLeft)

    frame.time = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.time:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

    -- Spell-Icon hinzufügen
    frame.icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon:SetSize(addon.db["CooldownTrackerBarHeight"], addon.db["CooldownTrackerBarHeight"]) -- Größe des Icons
    frame.icon:SetPoint("LEFT", frame, "RIGHT", 0, 0) -- Position am rechten Ende des Balkens
    frame.icon:SetTexture(spellIcon) -- Setzt das Icon des Spells

    if addon.db["potionTrackerShowTooltip"] then
        frame.icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellID) -- SpellID verwenden, um Tooltip anzuzeigen
            GameTooltip:Show()
        end)
        frame.icon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
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
            self.time:SetText(timeText)
        else
            self:SetScript("OnUpdate", nil)
            self:Hide()
            addon.MythicPlus.functions.updateBars()
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
frameAnchor.text:SetText(L["Drag me to position Cooldownbars"])

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

local function createBar(arg1, arg3)

    -- Finde die Position des neuen Balkens
    local yOffset = 0
    for _, bar in pairs(activeBars) do
        if bar:IsVisible() then
            yOffset = yOffset + bar:GetHeight() + 5 -- 5px Abstand
        end
    end
    -- Erstelle und positioniere den neuen Balken
    local bar = createCooldownBar(arg3, frameAnchor, select(1, UnitName(arg1)), arg1)
    if nil ~= bar then
        table.insert(activeBars, bar)
        bar:Show()
        addon.MythicPlus.functions.updateBars()
    end
end

local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if addon.db["potionTracker"] then
        local isInRaid = UnitInRaid("player")
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            if nil == allowedSpells[arg3] then
                return
            elseif arg1 == "player" and isInRaid then
                return
            elseif (arg1 == "player" and not isInRaid) then
                createBar(arg1, arg3)
                return
            elseif UnitInParty(arg1) and not UnitInRaid(arg1) then
                createBar(arg1, arg3)
                return
            elseif addon.db["potionTrackerDisableRaid"] == false and UnitInRaid(arg1) then
                createBar(arg1, arg3)
                return
            end
        elseif event == "CHALLENGE_MODE_RESET" then
            addon.MythicPlus.functions.resetCooldownBars()
        end
    end
end

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)
frameAnchor:Hide()
