local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

local portalSpells = { -- Dragonflight
[354464] = {text = "MISTS"}, [354462] = {text = "NW"}, [464256] = {text = "SIEG", faction = FACTION_HORDE},
[445418] = {text = "SIEG", faction = FACTION_ALLIANCE}, [445414] = {text = "DAWN"}, [445417] = {text = "COT"},
[445269] = {text = "SV"}, [445424] = {text = "GB"}, [445416] = {text = "ARAK"}}

local portalCompendium = {[1] = {headline = EXPANSION_NAME10,
                                 spells = {[445269] = {text = "SV"}, [445416] = {text = "COT"},
                                           [445414] = {text = "DAWN"}, [445417] = {text = "ARAK"}}},
                          [2] = {headline = EXPANSION_NAME9,
                                 spells = {[424197] = {text = "DOTI"}, [393256] = {text = "RLP"},
                                           [393262] = {text = "NO"}, [393267] = {text = "BRH"},
                                           [393273] = {text = "AA"}, [393276] = {text = "NELT"},
                                           [393279] = {text = "AV"}, [393283] = {text = "HOI"},
                                           [393222] = {text = "ULD"}, [432254] = {text = "VOTI"},
                                           [432258] = {text = "AMIR"}, [432257] = {text = "ASC"}}},
                          [3] = {headline = EXPANSION_NAME8,
                                 spells = {[354462] = {text = "NW"}, [354463] = {text = "PF"},
                                           [354464] = {text = "MISTS"}, [354465] = {text = "HOA"},
                                           [354466] = {text = "SOA"}, [354467] = {text = "TOP"},
                                           [354468] = {text = "DOS"}, [354469] = {text = "SD"},
                                           [367416] = {text = "TAZA"}, [373190] = {text = "CN"},
                                           [373192] = {text = "SFO"}, [373191] = {text = "SOD"}}},
                          [4] = {headline = EXPANSION_NAME7,
                                 spells = {[410071] = {text = "FH"}, [410074] = {text = "UR"},
                                           [373274] = {text = "MECH"}, [424167] = {text = "WM"},
                                           [424187] = {text = "AD"}, [445418] = {text = "SIEG"}}},
                          [5] = {headline = EXPANSION_NAME6,
                                 spells = {[424153] = {text = "BRH"}, [393766] = {text = "COS"},
                                           [424163] = {text = "DHT"}, [393764] = {text = "HOV"},
                                           [410078] = {text = "NL"}, [373262] = {text = "KARA"}}},
                          [6] = {headline = EXPANSION_NAME5,
                                 spells = {[159897] = {text = "AUCH"}, [159895] = {text = "BSM"},
                                           [159901] = {text = "EB"}, [159900] = {text = "GD"}, [159896] = {text = "ID"},
                                           [159899] = {text = "SBG"}, [159898] = {text = "SR"},
                                           [159902] = {text = "UBRS"}}}, [7] = {headline = EXPANSION_NAME4,
                                                                                spells = {[131225] = {text = "GSS"},
                                                                                          [131222] = {text = "MP"},
                                                                                          [131232] = {text = "SCHO"},
                                                                                          [131231] = {text = "SH"},
                                                                                          [131229] = {text = "SM"},
                                                                                          [131228] = {text = "SN"},
                                                                                          [131206] = {text = "SPM"},
                                                                                          [131205] = {text = "SB"},
                                                                                          [131204] = {text = "TJS"}}},
                          [8] = {headline = EXPANSION_NAME3,
                                 spells = {[445424] = {text = "GB"}, [424142] = {text = "TOTT"},
                                           [410080] = {text = "VP"}}}}

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

-- Compendium
local frameAnchorCompendium = CreateFrame("Frame", "DungeonTeleportFrameCompendium", DungeonTeleportFrame,
    "BackdropTemplate")
frameAnchorCompendium:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Hintergrund
edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Rahmen
edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
frameAnchorCompendium:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz

-- Überschrift hinzufügen
local titleCompendium = frameAnchorCompendium:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleCompendium:SetPoint("TOP", 0, -10)
local mSeasonTitleCompendium = L["DungeonCompendium"]
titleCompendium:SetFormattedText(mSeasonTitleCompendium)
frameAnchorCompendium:SetSize(titleCompendium:GetStringWidth() + 20, 170) -- Breite x Höhe
frameAnchorCompendium:SetPoint("TOPLEFT", DungeonTeleportFrame, "TOPRIGHT", 0, 0)

local activeBars = {}
addon.MythicPlus.portalFrame = frameAnchor

local buttonSize = 30
local spacing = 20
local spacingCompendium = 10
local hSpacing = 30
local hSpacingCompendium = 10

local function CreatePortalButtonsWithCooldown(frame, spells)
    -- Entferne alle bestehenden Buttons
    for _, button in pairs(frame.buttons or {}) do
        button:Hide()
        button:ClearAllPoints()
    end
    frame.buttons = {}

    -- Sortiere und filtere die bekannten Spells
    local sortedSpells = {}
    for spellID, data in pairs(spells) do
        local known = IsSpellKnown(spellID)
        if (not data.faction or data.faction == faction) and
            (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known)) then
            table.insert(sortedSpells, {spellID = spellID, text = data.text, iconID = data.iconID, isKnown = known})
        end
    end

    -- Sortiere alphabetisch nach Text
    table.sort(sortedSpells, function(a, b) return a.text < b.text end)

    -- Berechne dynamische Anzahl der Buttons
    local totalButtons = #sortedSpells
    local buttonsPerRow = math.ceil(totalButtons / 2)
    local totalButtonWidth = (buttonSize * buttonsPerRow) + (spacing * (buttonsPerRow - 1))
    local frameWidth = math.max(totalButtonWidth + 40, title:GetStringWidth() + 20)
    local initialSpacing = math.max(0, (frameWidth - totalButtonWidth) / 2)

    -- Dynamische Höhe
    local rows = math.ceil(totalButtons / buttonsPerRow)
    local frameHeight = math.max(title:GetStringHeight() + 20, 40 + rows * (buttonSize + hSpacing))
    frame:SetSize(frameWidth, frameHeight)

    -- Erstelle neue Buttons
    local index = 1
    for _, spellData in ipairs(sortedSpells) do
        local spellID = spellData.spellID
        local spellInfo = C_Spell.GetSpellInfo(spellID)

        -- Button erstellen
        local button = CreateFrame("Button", "PortalButton" .. index, frame, "SecureActionButtonTemplate")
        button:SetSize(buttonSize, buttonSize)
        button.spellID = spellID

        -- Hintergrund
        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(button)
        bg:SetColorTexture(0, 0, 0, 0.8)

        -- Rahmen
        local border = button:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(1, 1, 1, 1)

        -- Highlight/Glow-Effekt bei Mouseover
        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(button)
        highlight:SetColorTexture(1, 1, 0, 0.4) -- Gelber Glow mit 30% Transparenz
        button:SetHighlightTexture(highlight)

        -- Positionierung
        local row = math.ceil(index / buttonsPerRow) - 1
        local col = (index - 1) % buttonsPerRow
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", initialSpacing + col * (buttonSize + spacing),
            -40 - row * (buttonSize + hSpacing))

        -- Icon
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(button)
        icon:SetTexture(spellInfo.iconID or "Interface\\ICONS\\INV_Misc_QuestionMark")
        button.icon = icon

        -- Überprüfen, ob der Zauber bekannt ist
        if not spellData.isKnown then
            icon:SetDesaturated(true) -- Macht das Icon grau/schwarzweiß
            icon:SetAlpha(0.5) -- Optional: Reduziert die Sichtbarkeit
            button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
        else
            isKnown[spellID] = true
            icon:SetDesaturated(false)
            icon:SetAlpha(1) -- Normale Sichtbarkeit
            button:EnableMouse(true) -- Aktiviert Klicks
        end

        -- Cooldown-Spirale
        button.cooldownFrame = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cooldownFrame:SetAllPoints(button)

        -- Sichere Aktion (CastSpell)
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", spellID)
        button:RegisterForClicks("AnyUp", "AnyDown")

        -- Text und Tooltip
        local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", button, "BOTTOM", 0, -2)
        label:SetText(spellData.text)

        button:SetScript("OnEnter", function(self)
            if addon.db["portalShowTooltip"] then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(spellID)
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Button speichern
        table.insert(frame.buttons, button)
        index = index + 1
    end
end

local function CreatePortalCompendium(frame, compendium)
    -- Entferne alle bestehenden Elemente
    for _, button in pairs(frame.buttons or {}) do
        button:Hide()
        button:ClearAllPoints()
    end
    for _, headline in pairs(frame.headline or {}) do
        headline:Hide()
        headline:ClearAllPoints()
    end
    frame.buttons = {}
    frame.headline = {}

    -- Initiale Position
    local currentYOffset = 0 - titleCompendium:GetStringHeight() - 20 -- Startabstand vom oberen Rand
    local maxWidth = 0

    -- Durchlaufe die Reihenfolge in `compendium`
    for _, section in ipairs(compendium) do
        -- Überschrift (Headline)
        local headline = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        headline:SetPoint("TOP", frame, "TOP", 0, currentYOffset)
        headline:SetText(section.headline)
        currentYOffset = currentYOffset - headline:GetStringHeight() - 10 -- Abstand für Buttons
        table.insert(frame.headline, headline)

        local sortedSpells = {}
        for spellID, data in pairs(section.spells) do
            local known = IsSpellKnown(spellID)
            if (not data.faction or data.faction == faction) and
                (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known)) then
                table.insert(sortedSpells, {spellID = spellID, text = data.text, iconID = data.iconID, isKnown = known})
            end
        end
        table.sort(sortedSpells, function(a, b) return a.text < b.text end)

        -- Buttons generieren
        local buttonsPerRow = math.ceil(#sortedSpells)
        local totalButtonWidth = (buttonSize * buttonsPerRow) + (spacingCompendium * (buttonsPerRow - 1))
        maxWidth = math.max(maxWidth, totalButtonWidth + 20)

        local index = 0
        for _, spellData in ipairs(sortedSpells) do
            local spellID = spellData.spellID
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            local row = math.floor(index / buttonsPerRow)
            local col = index % buttonsPerRow

            -- Button erstellen
            local button = CreateFrame("Button", "CompendiumButton" .. index, frame, "SecureActionButtonTemplate")
            button:SetSize(buttonSize, buttonSize)
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col * (buttonSize + spacingCompendium),
                currentYOffset - row * (buttonSize + hSpacingCompendium))
            button.spellID = spellID

            -- Hintergrund
            local bg = button:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(button)
            bg:SetColorTexture(0, 0, 0, 0.8)

            -- Rahmen
            local border = button:CreateTexture(nil, "BORDER")
            border:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(1, 1, 1, 1)

            -- Highlight/Glow-Effekt
            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints(button)
            highlight:SetColorTexture(1, 1, 0, 0.4)
            button:SetHighlightTexture(highlight)

            -- Icon
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(button)
            icon:SetTexture(spellInfo.iconID or "Interface\\ICONS\\INV_Misc_QuestionMark")
            button.icon = icon

            -- Überprüfen, ob der Zauber bekannt ist
            if not spellData.isKnown then
                icon:SetDesaturated(true) -- Macht das Icon grau/schwarzweiß
                icon:SetAlpha(0.5) -- Optional: Reduziert die Sichtbarkeit
                button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
            else
                isKnown[spellID] = true
                icon:SetDesaturated(false)
                icon:SetAlpha(1) -- Normale Sichtbarkeit
                button:EnableMouse(true) -- Aktiviert Klicks
            end

            -- Cooldown-Spirale
            button.cooldownFrame = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            button.cooldownFrame:SetAllPoints(button)

            -- Sichere Aktion (CastSpell)
            button:SetAttribute("type", "spell")
            button:SetAttribute("spell", spellID)
            button:RegisterForClicks("AnyUp", "AnyDown")

            -- Text und Tooltip
            local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOP", button, "BOTTOM", 0, -2)
            label:SetText(spellData.text)

            -- Tooltip
            button:SetScript("OnEnter", function(self)
                if addon.db["portalShowTooltip"] then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetSpellByID(spellID)
                    GameTooltip:Show()
                end
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)

            table.insert(frame.buttons, button)
            index = index + 1
        end

        -- Höhe für die nächste Sektion berechnen
        local rows = math.ceil(#sortedSpells / buttonsPerRow)
        currentYOffset = currentYOffset - rows * (buttonSize + hSpacingCompendium + 10)
    end

    -- Frame-Größe dynamisch anpassen
    frame:SetSize(maxWidth, math.abs(currentYOffset) + 20)
end

local function checkCooldown()
    CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
    CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
    for _, button in pairs(frameAnchor.buttons or {}) do
        if isKnown[button.spellID] then
            local cooldownData = C_Spell.GetSpellCooldown(button.spellID)
            if cooldownData and cooldownData.isEnabled then
                button.cooldownFrame:SetCooldown(cooldownData.startTime, cooldownData.duration, cooldownData.modRate)
            else
                button.cooldownFrame:SetCooldown(0, 0)
            end
        end
    end

    for _, button in pairs(frameAnchorCompendium.buttons or {}) do
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
-- Buttons erstellen

frameAnchor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frameAnchor:RegisterEvent("ENCOUNTER_END")
frameAnchor:RegisterEvent("ADDON_LOADED")
frameAnchor:RegisterEvent("SPELL_DATA_LOAD_RESULT")

local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if addon.db["teleportFrame"] then
        if event == "ADDON_LOADED" and arg1 == addonName then
            CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
            CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            if portalSpells[arg3] then waitCooldown(arg3) end
        elseif event == "ENCOUNTER_END" and arg3 == 8 then
            C_Timer.After(0.1, function() checkCooldown() end)
        elseif event == "SPELL_DATA_LOAD_RESULT" and portalSpells[arg1] then
            print("Loaded", portalSpells[arg1].text)
        end
    end
end

function addon.MythicPlus.functions.toggleFrame()
    if addon.db["teleportFrame"] == true then
        frameAnchor:Show()
        CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
        if addon.db["teleportsEnableCompendium"] then
            frameAnchorCompendium:Show()
            CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
        else
            frameAnchorCompendium:Hide()
        end
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
    else
        frameAnchor:Hide()
    end
end

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)

PVEFrame:HookScript("OnShow", function(self) addon.MythicPlus.functions.toggleFrame() end)
