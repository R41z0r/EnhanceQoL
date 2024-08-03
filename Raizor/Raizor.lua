local addonName, addon = ...
local L = addon.L
-- Bibliotheken laden
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local LFGListFrame = _G.LFGListFrame

local RAIZ = select(2, ...)
RAIZ.C = {}

hooksecurefunc("LFGListSearchEntry_OnClick", function(s, button)
    local panel = LFGListFrame.SearchPanel
    if button ~= "RightButton" and LFGListSearchPanelUtil_CanSelectResult(s.resultID) and panel.SignUpButton:IsEnabled() then
        if panel.selectedResult ~= s.resultID then
            LFGListSearchPanel_SelectResult(panel, s.resultID)
        end
        LFGListSearchPanel_SignUp(panel)
    end
end)

LFGListApplicationDialog:HookScript("OnShow", function(self)
    if not RaizorDB.skipSignUpDialog then
        return
    end

    if self.SignUpButton:IsEnabled() and not IsShiftKeyDown() then
        self.SignUpButton:Click()
    end
end)

local didApplyPatch = false
local originalFunc = LFGListApplicationDialog_Show
local patchedFunc = function(self, resultID)
    if resultID then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);

        self.resultID = resultID;
        self.activityID = searchResultInfo.activityID;
    end
    LFGListApplicationDialog_UpdateRoles(self);
    StaticPopupSpecial_Show(self);
end

function RAIZ.PersistSignUpNote()
    if RaizorDB.persistSignUpNote then
        -- overwrite function with patched func missing the call to ClearApplicationTextFields
        LFGListApplicationDialog_Show = patchedFunc
        didApplyPatch = true
    elseif didApplyPatch then
        -- restore previously overwritten function
        LFGListApplicationDialog_Show = originalFunc
    end
end

function loadMain()
    -- Erstelle das Hauptframe
    local frame = CreateFrame("Frame", "MyAddonFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 400)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Position speichern
        local point, _, _, xOfs, yOfs = self:GetPoint()
        RaizorDB.point = point
        RaizorDB.x = xOfs
        RaizorDB.y = yOfs
    end)
    frame:Hide() -- Das Frame wird initial versteckt

    -- Titel des Frames
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText(addonName)


    -- Schleife zur Erzeugung der Checkboxen
    addon.frame = frame
    addon.checkboxes = {}
    addon.db = RaizorDB
    local checkbox = addon.functions.createCheckbox("skipSignUpDialog", frame, L["Quick signup"], 10, (-30*#addon.checkboxes-30))
    checkbox:SetChecked(RaizorDB["skipSignUpDialog"])

    local checkbox2 = addon.functions.createCheckbox("persistSignUpNote", frame, L["Persist LFG signup note"], 10, (-30*#addon.checkboxes-30))
    checkbox2:SetChecked(RaizorDB["persistSignUpNote"])

    -- Funktion zum Abrufen der Checkbox-Werte
    local function getCheckboxValues(self)
        local oldKey = {}
        for i, checkbox in ipairs(addon.checkboxes) do
            RaizorDB[checkbox:GetName()] = checkbox:GetChecked()
        end

        for key, value in pairs(addon.saveVariables) do
            RaizorDB[key] = value
        end

        if type(addon.updateAvailableDrinks) == "function" then
            --Update allowed drinks because of changed mana value
            addon.updateAllowedDrinks()
            addon.updateAvailableDrinks()
        end

        self:GetParent():Hide()
    end

    -- Button zum Abrufen der Checkbox-Werte
    local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    button:SetSize(140, 40)
    button:SetText("Save")
    button:SetNormalFontObject("GameFontNormalLarge")
    button:SetHighlightFontObject("GameFontHighlightLarge")
    button:SetScript("OnClick", getCheckboxValues)

    -- Slash-Command hinzufügen
    SLASH_RAIZOR1 = "/raizor"
    SLASH_RAIZOR2 = "/raizor resetframe"
    SlashCmdList["RAIZOR"] = function(msg)
        if msg == "resetframe" then
            -- Frame zurücksetzen
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER")
            RaizorDB.point = "CENTER"
            RaizorDB.x = 0
            RaizorDB.y = 0
            print("Raizor frame has been reset to the center.")
        else
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
        end
    end

    -- Datenobjekt für den Minimap-Button
    local RaizorLDB = LDB:NewDataObject("Raizor", {
        type = "launcher",
        text = "Raizor",
        icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\Icon.tga", -- Hier kannst du dein eigenes Icon verwenden
        OnClick = function(_, msg)
            if msg == "LeftButton" then
                if frame:IsShown() then
                    frame:Hide()
                else
                    frame:Show()
                end
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("Raizor")
            tt:AddLine("Left-Click to open the addon")
        end
    })

    -- Einstellungen für den Minimap-Button
    LDBIcon:Register("Raizor", RaizorLDB, RaizorDB)

    -- Frame für die Optionen
    local configFrame = CreateFrame("Frame", "RaizorConfigFrame", InterfaceOptionsFramePanelContainer)
    configFrame.name = "Raizor"

    -- Button für die Optionen
    local configButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configButton:SetSize(140, 40)
    configButton:SetPoint("TOPLEFT", 10, -10)
    configButton:SetText("Config")
    configButton:SetScript("OnClick", function()
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end)

    -- Frame zu den Interface-Optionen hinzufügen
    -- InterfaceOptions_AddCategory(configFrame)
    local category, layout = Settings.RegisterCanvasLayoutCategory(configFrame, configFrame.name);
    Settings.RegisterAddOnCategory(category);
    addon.settingsCategory = category

    -- Frame-Position wiederherstellen
    local function RestorePosition()
        if RaizorDB.point and RaizorDB.x and RaizorDB.y then
            frame:ClearAllPoints()
            frame:SetPoint(RaizorDB.point, UIParent, RaizorDB.point, RaizorDB.x, RaizorDB.y)
        end
    end

    -- Frame wiederherstellen und überprüfen, wenn das Addon geladen wird
    frame:SetScript("OnShow", function()
        RestorePosition()
    end)
end

-- Erstelle ein Frame für Events
local frameLoad = CreateFrame("Frame")

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Raizor" then
        -- Dein Code zur Initialisierung der Datenbank
        if not RaizorDB then
            RaizorDB = {}
        end
        loadMain()
        RAIZ.PersistSignUpNote()
    elseif type(addon.updateAvailableDrinks) == "function" then
        -- functions for DrinkMacro
        if event == "BAG_UPDATE_DELAYED" then
            addon.updateAvailableDrinks(false)
        elseif event == "PLAYER_LOGIN" or event == "PLAYER_REGEN_ENABLED" then
            --on login always load the macro
            --on PLAYER_REGEN_ENABLED always load, because we don't know if something changed in Combat
            addon.updateAvailableDrinks(true)
        elseif event == "PLAYER_LEVEL_UP" then
            --on level up, reload the complete list of allowed drinks
            addon.updateAllowedDrinks()
            addon.updateAvailableDrinks(true)
        end
    end
end

-- Registriere das Event
frameLoad:RegisterEvent("ADDON_LOADED")
frameLoad:RegisterEvent("PLAYER_LOGIN")
frameLoad:RegisterEvent("PLAYER_REGEN_ENABLED")
frameLoad:RegisterEvent("PLAYER_LEVEL_UP")
frameLoad:RegisterEvent("BAG_UPDATE_DELAYED")

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)
