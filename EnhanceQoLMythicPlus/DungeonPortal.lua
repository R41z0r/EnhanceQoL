local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

-- Addition für Potion Cooldown tracker
local portalSpells = { -- Dragonflight
[354464] = {text = "MISTS"}, [354462] = {text = "NW"}, [464256] = {text = "SIEG", faction = FACTION_HORDE},
[445418] = {text = "SIEG", faction = FACTION_ALLIANCE}, [445414] = {text = "DAWN"}, [445417] = {text = "COT"},
[445269] = {text = "SV"}, [445424] = {text = "GB"}, [445416] = {text = "ARAK"},
-- [393256] = {text = "RLP"},
-- [393273] = {text = "AA"},
}

local isKnown = {}
local faction = UnitFactionGroup("player")
local initialStart = true

local frameAnchor = CreateFrame("Frame", "DungeonTeleportFrame", PVEFrame, "BackdropTemplate")
frameAnchor:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Hintergrund
edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Rahmen
edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
frameAnchor:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz

-- Überschrift hinzufügen
local title = frameAnchor:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
local mSeasonTitle = format(MYTHIC_DUNGEON_SEASON, "", 1)
title:SetFormattedText(mSeasonTitle:gsub("%(%s", "("))
frameAnchor:SetSize(title:GetStringWidth() + 20, 170) -- Breite x Höhe

local activeBars = {}
addon.MythicPlus.portalFrame = frameAnchor

local function checkCooldown()
    for _, button in pairs(frameAnchor.buttons or {}) do

        if (nil == isKnown[button.spellID] or not isKnown[button.spellID]) and IsSpellKnown(button.spellID) then
            isKnown[button.spellID] = true
            button.icon:SetDesaturated(false) -- Normale Farbe wiederherstellen
            button.icon:SetAlpha(1) -- Volle Sichtbarkeit
            button:EnableMouse(true) -- Aktiviert Klicks
        end

        if isKnown[button.spellID] then
            local cooldownData = C_Spell.GetSpellCooldown(button.spellID)
            if cooldownData and cooldownData.isEnabled then
                button.cooldownFrame:SetCooldown(cooldownData.startTime, cooldownData.duration, cooldownData.modRate)
            else
                button.cooldownFrame:SetCooldown(0, 0)
            end
        end
    end
end

local function waitCooldown(arg3)
    C_Timer.After(0.1, function()
        local cooldownData = C_Spell.GetSpellCooldown(arg3)
        if cooldownData.duration > 0 then
            checkCooldown()
        else
            waitCooldown(arg3)
        end
    end)
end

local buttonSize = 35
local spacing = 20
local hSpacing = 35

local function CreatePortalButtonsWithCooldown(frame, spells)
    local buttons = {}
    local sortedSpells = {}

    -- Erstelle eine sortierbare Liste aus der spells-Tabelle
    for spellID, data in pairs(spells) do
        if data.faction and faction == data.faction then
            table.insert(sortedSpells, {spellID = spellID, text = data.text, iconID = data.iconID})
        elseif nil == data.faction then
            table.insert(sortedSpells, {spellID = spellID, text = data.text, iconID = data.iconID})
        end
    end

    -- Sortiere die Liste alphabetisch nach dem `text`-Feld
    table.sort(sortedSpells, function(a, b) return a.text < b.text end)

    -- Dynamische Anzahl der Buttons
    local totalButtons = #sortedSpells
    local buttonsPerRow = math.ceil(totalButtons / 2) -- Dynamische Berechnung der Buttons pro Reihe
    local totalButtonWidth = (buttonSize * buttonsPerRow) + (spacing * (buttonsPerRow - 1))
    
    local frameWidth = math.max(totalButtonWidth + 40, title:GetStringWidth() + 20) -- Mindestbreite von 200 für Optik
    local initialSpacing = (frameWidth - totalButtonWidth) / 2

    -- Dynamische Höhe des Frames
    local rows = math.ceil(totalButtons / buttonsPerRow)
    local frameHeight = 40 + rows * (buttonSize + hSpacing)
    frame:SetSize(frameWidth, frameHeight) -- Setze die dynamische Breite und Höhe


    -- Buttons erstellen
    local index = 1
    for _, spellData in ipairs(sortedSpells) do
        local spellID = spellData.spellID
        local data = spells[spellID]

        local button = CreateFrame("Button", "PortalButton" .. index, frame, "SecureActionButtonTemplate")
        local spellInfo = C_Spell.GetSpellInfo(spellID)

        button:SetSize(buttonSize, buttonSize)
        button.spellID = spellID -- SpellID zum Button hinzufügen

        -- Hintergrund und Rahmen
        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(button)
        bg:SetColorTexture(0, 0, 0, 0.8)

        local border = button:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(1, 1, 1, 1)

        -- Position und Icon
        local row = math.ceil(index / buttonsPerRow) - 1
        local col = (index - 1) % buttonsPerRow
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", initialSpacing + col * (buttonSize + spacing),
            -40 - row * (buttonSize + hSpacing))

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(button)
        icon:SetTexture(spellInfo.iconID or "Interface\\ICONS\\INV_Misc_QuestionMark")

        -- Überprüfen, ob der Zauber bekannt ist
        if not IsSpellKnown(spellID) then
            icon:SetDesaturated(true) -- Macht das Icon grau/schwarzweiß
            icon:SetAlpha(0.5) -- Optional: Reduziert die Sichtbarkeit
            button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
        else
            isKnown[spellID] = true
            icon:SetDesaturated(false)
            icon:SetAlpha(1) -- Normale Sichtbarkeit
            button:EnableMouse(true) -- Aktiviert Klicks
        end

        -- Text und Tooltip
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", button, "BOTTOM", 0, -2)
        label:SetText(data.text)

        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellID)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Cooldown-Spirale hinzufügen
        button.cooldownFrame = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cooldownFrame:SetAllPoints(button)

        -- Sichere Aktion (CastSpell) konfigurieren
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", spellID)
        button:RegisterForClicks("AnyUp", "AnyDown")

        -- Button speichern
        table.insert(buttons, button)
        index = index + 1

        if index > totalButtons then break end
    end

    frame.buttons = buttons
    return buttons
end
-- Buttons erstellen

frameAnchor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frameAnchor:RegisterEvent("ENCOUNTER_END")
frameAnchor:RegisterEvent("ADDON_LOADED")

local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == addonName then
        CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        if portalSpells[arg3] then waitCooldown(arg3) end
    elseif event == "ENCOUNTER_END" and arg3 == 8 then
        C_Timer.After(0.1, function() checkCooldown() end)
    end
end

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)

PVEFrame:HookScript("OnShow", function(self)
    if initialStart then
        initialStart = false
        -- Based on RaiderIO Client place the Frame
        if nil ~= RaiderIO_ProfileTooltip then
            frameAnchor:SetPoint("TOPLEFT", RaiderIO_ProfileTooltip, "TOPRIGHT", 0, 0)
        else
            frameAnchor:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT", 0, 0)
        end
    end
    checkCooldown()
end)
